Class {
	#name : #MailSender,
	#superclass : #AppRegistry,
	#classVars : [
		'SmtpServer',
		'SmtpServerPort',
		'UserEmail',
		'UserName',
		'UserPassword'
	],
	#category : #'System-Applications'
}

{ #category : #testing }
MailSender class >> isSmtpServerPortSet [
	^ SmtpServerPort notNil and: [SmtpServerPort isNumber]

]

{ #category : #testing }
MailSender class >> isSmtpServerSet [
	^ SmtpServer notNil and: [SmtpServer notEmpty]

]

{ #category : #testing }
MailSender class >> isUserEmailSet [
	^ UserEmail notNil and: [UserEmail notEmpty]

]

{ #category : #testing }
MailSender class >> isUserNameSet [
	^ UserName notNil and: [UserName notEmpty]

]

{ #category : #testing }
MailSender class >> isUserPasswordSet [
	^ UserPassword notNil and: [UserPassword notEmpty]

]

{ #category : #'initialize-release' }
MailSender class >> reset [

	UserName := UserPassword := UserEmail := SmtpServer := SmtpServerPort := nil.
]

{ #category : #communication }
MailSender class >> sendMessage: aMailMessage [

	self default ifNotNil: [self default sendMailMessage: aMailMessage]
]

{ #category : #settings }
MailSender class >> setSmtpServer [
	"Set the SMTP server used to send outgoing messages via"
	SmtpServer ifNil: [SmtpServer := ''].
	SmtpServer := UIManager default
		request: 'What is your mail server for outgoing mail?'
		initialAnswer: SmtpServer.

]

{ #category : #settings }
MailSender class >> setSmtpServerPort [
	"Set the SMTP server port used to send outgoing messages via"
	SmtpServerPort ifNil: [SmtpServerPort := 25].
	SmtpServerPort := (UIManager default
		request: 'What is your mail server port for outgoing mail?'
		initialAnswer: SmtpServerPort asString) asNumber.

]

{ #category : #settings }
MailSender class >> setUserEmail [
	"Change the user's email for use in composing messages."

	(UIManager default
			request: 'What is your email address?\(This is the address other people will reply to you)' withCRs
			initialAnswer: (UserEmail ifNil: [UserEmail := '']))
		ifNotNil: [:answer | UserEmail := answer]
]

{ #category : #settings }
MailSender class >> setUserName [

	(UIManager default
			request: 'What is your user name on the SMTP server?' withCRs
			initialAnswer: (UserName ifNil: [UserName := '']))
		ifNotNil: [:answer | UserName := answer]
]

{ #category : #settings }
MailSender class >> setUserPassword [

	UserPassword ifNil: [UserPassword := ''].
	(UIManager default
			requestPassword: 'What is your server passwort?' withCRs)
		ifNotNil: [:answer | UserPassword := answer]
]

{ #category : #accessing }
MailSender class >> smtpServer [
	"Answer the server for sending email"

	self isSmtpServerSet ifFalse: [self setSmtpServer].
	SmtpServer isEmpty ifTrue: [ self error: 'no SMTP server specified' ].

	^SmtpServer
]

{ #category : #accessing }
MailSender class >> smtpServerPort [
	"Answer the server for sending email"

	self isSmtpServerPortSet ifFalse: [self setSmtpServerPort].
	SmtpServerPort isNil ifTrue: [ self error: 'no SMTP server port specified' ].

	^SmtpServerPort
]

{ #category : #accessing }
MailSender class >> userEmail [
	"Answer the user name to be used for sending out messages."

	self isUserEmailSet ifFalse: [self setUserEmail].

	UserEmail isEmpty ifTrue: [ self error: 'no user email specified' ].

	^UserEmail
]

{ #category : #accessing }
MailSender class >> userName [
	"Answer the user name to be used for sending out messages."

	self isUserNameSet ifFalse: [self setUserName].

	UserName isEmpty ifTrue: [ self error: 'no user name specified' ].

	^UserName
]

{ #category : #accessing }
MailSender class >> userPassword [

	self isUserPasswordSet ifFalse: [self setUserPassword].

	UserPassword isEmpty ifTrue: [ self error: 'no user name specified' ].

	^ UserPassword
]
