Class {
	#name : #MCSmtpRepository,
	#superclass : #MCWriteOnlyRepository,
	#instVars : [
		'email'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #configuring }
MCSmtpRepository class >> description [
	^ 'SMTP'
]

{ #category : #configuring }
MCSmtpRepository class >> morphicConfigure [
	| address |
	address := UIManager default request: 'Email address:'.
	^ address isEmpty ifFalse: [self new emailAddress: address]
]

{ #category : #private }
MCSmtpRepository >> basicStoreVersion: aVersion [
	MailSender sendMessage: (self messageForVersion: aVersion)
]

{ #category : #converting }
MCSmtpRepository >> bodyForVersion: aVersion [
	^ String streamContents:
		[ :s |
		s nextPutAll: 'from version info:'; cr; cr.
		s nextPutAll:  aVersion info summary]
]

{ #category : #'user interface' }
MCSmtpRepository >> description [
	^ 'mailto://', email
]

{ #category : #accessing }
MCSmtpRepository >> emailAddress: aString [
	email := aString	
]

{ #category : #converting }
MCSmtpRepository >> messageForVersion: aVersion [
	| message data |
	message := MailMessage empty.
	message setField: 'from' toString: MailSender userName.
	message setField: 'to' toString: email.
	message setField: 'subject' toString: (self subjectForVersion: aVersion). 

	message body:
		(MIMEDocument
			contentType: 'text/plain'
			content: (self bodyForVersion: aVersion)).

	"Prepare the gzipped data"
	data := RWBinaryOrTextStream on: String new.
	aVersion fileOutOn: data.
	message addAttachmentFrom: data reset withName: aVersion fileName.
	^ message
]

{ #category : #converting }
MCSmtpRepository >> subjectForVersion: aVersion [
	^ '[Package] ', aVersion info name
]
