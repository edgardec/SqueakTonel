"
a URL specifying a mailing address; activating it triggers a mail-sender to start up, if one is present.
"
Class {
	#name : #MailtoUrl,
	#superclass : #GenericUrl,
	#category : #'Network-Url'
}

{ #category : #downloading }
MailtoUrl >> activate [
	"Activate a Celeste window for the receiver"

	MailSender sendMessage: (MailMessage from: self composeText)
]

{ #category : #downloading }
MailtoUrl >> composeText [
	"Answer the template for a new message."

	^ String streamContents: [:str |
		str nextPutAll: 'From: '.
		str nextPutAll: MailSender userName; cr.
		str nextPutAll: 'To: '.
		str nextPutAll: locator asString; cr.

		str nextPutAll: 'Subject: '; cr.

		str cr].
]
