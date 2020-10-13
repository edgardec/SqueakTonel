"
Various loose functions in SM.
"
Class {
	#name : #SMUtilities,
	#superclass : #Object,
	#classVars : [
		'MailServer',
		'MasterServer'
	],
	#category : #'SMBase-UI'
}

{ #category : #'class initialization' }
SMUtilities class >> initialize [
	"Initialize server settings."

	"self initialize"

	MasterServer := nil.
	MailServer := nil
]

{ #category : #server }
SMUtilities class >> isServer [
	"Is this a running server?"
	
	^MasterServer notNil
]

{ #category : #private }
SMUtilities class >> mail: anAccount subject: sub message: msg [
	"Send a mail to the holder of <anAccount>."

	SMTPClient
		deliverMailFrom: 'squeakmap@squeak.org'
		to: {anAccount email}
		text:
('From: SqueakMap <squeakmap@squeak.org>
To: ', anAccount email, '
Subject: ', sub,
'
', msg, (self randomPhrase), ', SqueakMap') usingServer: MailServer
]

{ #category : #server }
SMUtilities class >> mailPassword: randomPass for: anAccount [
	"Change the password to a random generated one
	and mail it to the holder of the account."

	self mail: anAccount subject: 'New password at SqueakMap!' message:
'Hi!
An extra random password has been added for the account held by "', anAccount name, '":
"', randomPass, '"

You can login to SqueakMap at:

', MasterServer, '/login

The regular password still works, so if it was not you who requested this extra
random password you can safely just delete this email.

This extra password will stop working when you change your regular password.

'
]

{ #category : #server }
SMUtilities class >> mailPassword: aPassword forNew: anAccount [
	"Mail the password to the person who just registered the account."

	self mail: anAccount subject: 'Your new account at SqueakMap!' message:
'Hi!
You or someone else has registered an account on SqueakMap. You can login to it using this link:

',
MasterServer, '/autologin?u=', anAccount initials, '&p=', aPassword,
'

If it was not you who performed this registration you can safely just delete this email.

'
]

{ #category : #'class initialization' }
SMUtilities class >> mailServer: ipName masterServer: httpUrl [
	"Initialize server settings."

	MailServer := ipName.
	MasterServer := httpUrl
]

{ #category : #private }
SMUtilities class >> mailUserName [
	"Answer the mail user's name, but deal with some historical mail senders."

	| mailSender |
	mailSender := (Smalltalk at: #MailSender ifAbsent: [ Smalltalk at: #Celeste ifAbsent: []]).
	^mailSender
		ifNil: [ UIManager default request: 'What is your email address?' ]
		ifNotNil: [ mailSender userName ]
]

{ #category : #server }
SMUtilities class >> masterServer [
	"Return the master server url."

	^MasterServer
]

{ #category : #private }
SMUtilities class >> randomPhrase [
	"Pick a nice phrase."

	^#('Debug safely' 'Happy Squeaking' 'Just do it' 'Yours truly' 'Stay a Squeaker' 'Squeak rocks') atRandom
]

{ #category : #utilities }
SMUtilities class >> sendMail: aString [
	"Send the given mail message, but check for modern mail senders."

	

	Smalltalk at: #MailSender ifPresent: [ :mailSender |
		^mailSender sendMessage: ((Smalltalk at: #MailMessage) from: aString).
	].

	Smalltalk at: #MailComposition ifPresent: [ :mailComposition |
		^mailComposition new
			messageText:  aString;
			open
	].
	
	Smalltalk at: #Celeste ifPresent: [ :celeste |
		celeste isSmtpServerSet ifTrue: [
			Smalltalk at: #CelesteComposition ifPresent: [ :celesteComposition |
				^celesteComposition
					openForCeleste: celeste current 
					initialText: aString
			]
		]
	].

	Smalltalk at: #AdHocComposition ifPresent: [ :adHocComposition | | server |
		server := UIManager default request: 'What is your mail server for outgoing mail?'.
		^adHocComposition 
			openForCeleste: server
			initialText: aString
	].

	^self inform: 'Sorry, no known way to send the message'.
	 	
]

{ #category : #utilities }
SMUtilities class >> sendMailTo: recipient regardingPackageRelease: pr [
	"Send mail to the given recipient. Try to use the first of:
	- MailSender (with its registered composition class)
	- Celeste
	- AdHocComposition
	for compatibility with 3.5 and 3.6 images"

	self sendMail: (String streamContents: [:stream |
		stream
			nextPutAll: 'From: '; nextPutAll: self mailUserName; cr;
			nextPutAll: 'To: '; nextPutAll: recipient; cr;
			nextPutAll: 'Subject: Regarding '; nextPutAll: pr printName; cr])
]

{ #category : #utilities }
SMUtilities class >> stripEmailFrom: aString [
	"Picks out the email from:
		'Robert Robertson <rob@here.com>' => 'rob@here.com'
	Spamblockers 'no_spam', 'no_canned_ham' and 'spam_block'
	(case insensitive) will be filtered out."

	| lessThan moreThan email |
	lessThan := aString indexOf: $<.
	moreThan := aString indexOf: $>.
	(lessThan * moreThan = 0) ifTrue: [^ aString].
	email := (aString copyFrom: lessThan + 1 to: moreThan - 1) asLowercase.
	#('no_spam' 'no_canned_ham' 'spam_block') do: [:block | | pos |
		pos := email findString: block.
		pos = 0 ifFalse:[email := (email copyFrom: 1 to: pos - 1), (email copyFrom: pos + block size to: email size)]].
	^email
]

{ #category : #utilities }
SMUtilities class >> stripNameFrom: aString [
	"Picks out the name from:
		'Robert Robertson <rob@here.com>' => 'Robert Robertson'
	"

	| lessThan |
	lessThan := aString indexOf: $<.
	^(aString copyFrom: 1 to: lessThan - 1) withBlanksTrimmed 
]
