"
This class implements the SMTP (mail sending) protocol specified in RFC 821.

HELO <SP> <domain> <CRLF>

MAIL <SP> FROM:<reverse-path> <CRLF>

RCPT <SP> TO:<forward-path> <CRLF>

DATA <CRLF>

RSET <CRLF>

SEND <SP> FROM:<reverse-path> <CRLF>

SOML <SP> FROM:<reverse-path> <CRLF>

SAML <SP> FROM:<reverse-path> <CRLF>

VRFY <SP> <string> <CRLF>

EXPN <SP> <string> <CRLF>

HELP [<SP> <string>] <CRLF>

NOOP <CRLF>

QUIT <CRLF>

TURN <CRLF>


"
Class {
	#name : #SMTPClient,
	#superclass : #TelnetProtocolClient,
	#classVars : [
		'UseTLSIfAvailable'
	],
	#category : #'Network-Protocols'
}

{ #category : #accessing }
SMTPClient class >> defaultPortNumber [
	^25
]

{ #category : #'sending mail' }
SMTPClient class >> deliverMailFrom: fromAddress to: recipientList text: messageText usingServer: serverName [
	"Deliver a single email to a list of users and then close the connection - for delivering multiple messages, it is best to create a single connection and send all mail over it.
	The serverName can include the port number - simply append ':587' for example to over ride the default port number.
	No user name or password is used in this method; see deliverMailFrom:to:text:usingServer:userName:password: for more.
	NOTE: the recipient list should be a collection of simple internet style addresses -- no '<>' or '()' stuff"

	self deliverMailFrom: fromAddress to: recipientList text: messageText usingServer: serverName userName: nil password: nil

]

{ #category : #'sending mail' }
SMTPClient class >> deliverMailFrom: fromAddress to: recipientList text: messageText usingServer: serverName userName: uNameString password: pwdString [
	"Deliver a single email to a list of users and then close the connection - for delivering multiple messages, it is best to create a single connection and send all mail over it.
	The serverName can include the port number - simply append ':587' for example to over ride the default port number.
	If uNameString or pwdString are non-nil, set the uid/pwd for the client. It is inadvisable to try setting a uid and not a pwd, or indeed vice versa.
	NOTE: the recipient list should be a collection of simple internet style addresses -- no '<>' or '()' stuff"

	| smtpClient |
	smtpClient := self new.
	
	uNameString ifNotNil:[smtpClient user: uNameString].
	pwdString ifNotNil:[smtpClient password: pwdString].
	smtpClient openOnHostNamed: serverName.
	[smtpClient mailFrom: fromAddress to: recipientList text: messageText.
	smtpClient quit]
		ensure: [smtpClient close]

]

{ #category : #example }
SMTPClient class >> example [
	"SMTPClient example"

	self deliverMailFrom: 'm.rueger@acm.org' to: #('m.rueger@acm.org') text:
'From: test
To: "not listed"
Subject: this is a test

Hello from Squeak!
'	usingServer: 'smtp.concentric.net'
]

{ #category : #example }
SMTPClient class >> example2 [
	"SMTPClient example2"

	self deliverMailFrom: 'm.rueger@acm.org' to: #('m.rueger@acm.org') text:
'Subject: this is a test

Hello from Squeak!
'	usingServer: 'smtp.concentric.net'
]

{ #category : #accessing }
SMTPClient class >> logFlag [
	^#smtp
]

{ #category : #'private protocol' }
SMTPClient >> data: messageData [
	"send the data of a message"
	"DATA <CRLF>"

	"inform the server we are sending the message data"
	self sendCommand: 'DATA'.
	self checkResponse.

	"process the data one line at a time"
	messageData linesDo:  [ :messageLine | | cookedLine |
		cookedLine := messageLine.
		(cookedLine beginsWith: '.') ifTrue: [ 
			"lines beginning with a dot must have the dot doubled"
			cookedLine := '.', cookedLine ].
		self sendCommand: cookedLine ].

	"inform the server the entire message text has arrived"
	self sendCommand: '.'.
	self checkResponse.
]

{ #category : #utility }
SMTPClient >> encodeString: aString [ 
	| str dec out |
	str := String new: (aString size * 4 / 3 + 3) ceiling.
	dec := Base64MimeConverter new.
	dec
		mimeStream: (out := WriteStream on: str);
		dataStream: (ReadStream on: aString);
		multiLine: false;
		mimeEncode.
	^out contents
]

{ #category : #'private protocol' }
SMTPClient >> initiateSession [
	"EHLO <SP> <domain> <CRLF>"

	self sendCommand: (self useHelo ifTrue:['HELO '] ifFalse: ['EHLO ']) , self localHostName.
	self checkResponse.
	
	self parseCapabilities: (self lastResponse lines allButFirst 
			collect: [:l | self valueOfResponseLine: l]).

	(self tlsIsActive not and: [self serverSupportsStarttls] and: [self wantsStarttls])
		ifTrue: [
			self starttls.
			self responseIsSuccess ifTrue: [
				self initiateSession ] ]
]

{ #category : #'public protocol' }
SMTPClient >> localHostName [
	"The local host name for purposes of identifying the the server.
	If nil, NetNameResolver localHostName will be used."

	^self connectionInfo at: #localHostName ifAbsent: [NetNameResolver localHostName]
]

{ #category : #'public protocol' }
SMTPClient >> localHostName: aString [
	"The local host name for purposes of identifying the the server.
	If nil, NetNameResolver localHostName will be used."

	^self connectionInfo at: #localHostName put: aString
]

{ #category : #'private protocol' }
SMTPClient >> login [
	"Send HELO first"
	self initiateSession.
	self user ifNil: [^self].
	self sendCommand: 'AUTH LOGIN ' , (self encodeString: self user).
	[self checkResponse]
		on: TelnetProtocolError
		do: [ :ex | ex isCommandUnrecognized ifTrue: [^ self] ifFalse: [ex pass]].
	self sendCommand: (self encodeString: self password).
	self checkResponse
]

{ #category : #'private protocol' }
SMTPClient >> mailFrom: fromAddress [
	" MAIL <SP> FROM:<reverse-path> <CRLF>"

	| address |
	address := (MailAddressParser addressesIn: fromAddress) first.

	self sendCommand: 'MAIL FROM: <', address, '>'.
	self checkResponse.
]

{ #category : #'public protocol' }
SMTPClient >> mailFrom: sender to: recipientList text: messageText [
	"deliver this mail to a list of users.  NOTE: the recipient list should be a collection of simple internet style addresses -- no '<>' or '()' stuff"

	self mailFrom: sender.
	recipientList do: [ :recipient |
		self recipient: recipient ].
	self data: messageText.

]

{ #category : #'private protocol' }
SMTPClient >> quit [
	"send a QUIT command.  This is polite to do, and indeed some servers might drop messages that don't have an associated QUIT"
	"QUIT <CRLF>"

	self sendCommand: 'QUIT'.
	self checkResponse.
]

{ #category : #'private protocol' }
SMTPClient >> recipient: aRecipient [
	"specify a recipient for the message.  aRecipient should be a bare email address"
	"RCPT <SP> TO:<forward-path> <CRLF>"

	self sendCommand: 'RCPT TO: <', aRecipient, '>'.
	self checkResponse.
]

{ #category : #'public protocol' }
SMTPClient >> useHelo [
	"If client use HELO instead of EHLO. HELO is the old protocol and
	an old server may require it instead of EHLO."

	^self connectionInfo at: #useHelo ifAbsent: [false]
]

{ #category : #'public protocol' }
SMTPClient >> useHelo: aBoolean [
	"Tell client to use HELO instead of EHLO. HELO is the old protocol and
	an old server may require it instead of EHLO."

	^self connectionInfo at: #useHelo put: aBoolean
]
