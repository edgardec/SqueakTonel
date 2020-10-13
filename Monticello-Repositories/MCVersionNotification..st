Class {
	#name : #MCVersionNotification,
	#superclass : #Object,
	#instVars : [
		'version',
		'ancestor',
		'repository',
		'changes'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #'instance creation' }
MCVersionNotification class >> version: aVersion repository: aRepository [
	^ self basicNew initializeWithVersion: aVersion repository: aRepository
]

{ #category : #accessing }
MCVersionNotification >> fromAddress [
	^ 'monticello@beta4.com'
]

{ #category : #private }
MCVersionNotification >> initializeWithVersion: aVersion repository: aRepository [
	version := aVersion.
	repository := aRepository.
	ancestor := repository withCache closestAncestorVersionFor: version info ifNone: []. 
	changes := ancestor
				ifNil: [#()]
				ifNotNil: [(version snapshot patchRelativeToBase: ancestor snapshot) 							operations sorted]
]

{ #category : #accessing }
MCVersionNotification >> messageText [
	^ String streamContents:
		[:s |
		s nextPutAll: 'Committed to repository: ', repository description; cr; cr.
		s nextPutAll: version summary.
		changes isEmpty ifFalse:
			[s cr; cr.
			s nextPutAll: '-----------------------------------------------------'; cr.
			s nextPutAll: 'Changes since ', ancestor info name, ':'; cr.
			changes do:
			[:ea |
			s cr; nextPutAll: ea summary; cr.
			s nextPutAll: ea sourceString]]]
]

{ #category : #private }
MCVersionNotification >> messageTo: aString [
	| message |
	message := MailMessage empty.
	message setField: 'from' toString: self fromAddress.
	message setField: 'to' toString: aString.
	message setField: 'subject' toString: '[MC] ', version info name.
	message body: (MIMEDocument contentType: 'text/plain' content: self messageText).
	^ message
]

{ #category : #notifying }
MCVersionNotification >> notify: aString [
	| message |
	message := self messageTo: aString.
	SMTPClient
		deliverMailFrom: message from
		to: { message to }
		text: message text
		usingServer: MailSender smtpServer
]
