Class {
	#name : #SecureSMTPClient,
	#superclass : #SMTPClient,
	#category : #'SqueakSSL-SMTP'
}

{ #category : #example }
SecureSMTPClient class >> exampleGMailFrom: gmailAddress to: rcvrAddress password: pw [
	"Sends email via secure smtp through GMail"

	| message smtpClient |
	smtpClient := self new.
	smtpClient user: gmailAddress.
	smtpClient password: pw.
	smtpClient openOnHost: (NetNameResolver addressForName: 'smtp.gmail.com') port: 465.

	message := MailMessage empty.
	message setField: 'from' toString: gmailAddress.
	message setField: 'to' toString: rcvrAddress.
	message setField: 'subject' toString: 'Hello World'.
	message body: 
		(MIMEDocument contentType: 'text/plain' content: 'bla bla bla').

	smtpClient mailFrom: gmailAddress to: {rcvrAddress} text: message text.
	smtpClient quit. 

]

{ #category : #private }
SecureSMTPClient >> ensureConnection [
	self isConnected
		ifTrue: [^self].
	self stream
		ifNotNil: [self stream close].

	self stream: (SecureSocketStream openConnectionToHost: self host port: self port timeout: self standardTimeout).
	self stream sslConnect.
	self checkResponse.
	self login
]
