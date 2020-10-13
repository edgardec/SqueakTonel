"
This is the unit test for the class MailMessage.
"
Class {
	#name : #MailMessageTest,
	#superclass : #TestCase,
	#category : #'NetworkTests-RFC822'
}

{ #category : #fixtures }
MailMessageTest >> fixtureMail [
	
	^ MailMessage empty
		from: self fixtureSenderMail;
		to: self fixtureReceiverMails;
		messageId: self fixtureMessageId;
		dateTime: self fixtureMessageDate;
		subject: self fixtureSubject;
		yourself
]

{ #category : #fixtures }
MailMessageTest >> fixtureMessageDate [

	^ DateAndTime year: 2017 month: 2 day: 5 hour: 14 minute: 15 
]

{ #category : #fixtures }
MailMessageTest >> fixtureMessageId [
	
	^ 'ijoisjdfoihasoidhfosihd@mail.com'
]

{ #category : #fixtures }
MailMessageTest >> fixtureReceiverMails [

	^ 'receiver@mail.com'
]

{ #category : #fixtures }
MailMessageTest >> fixtureSenderMail [

	^ 'sender@mail.com'
]

{ #category : #fixtures }
MailMessageTest >> fixtureSubject [

	^ 'This is the subject'
]

{ #category : #tests }
MailMessageTest >> testAttachmentsGetTheirOwnContentType [

	| message contentType |
	message := MailMessage empty 
		addAttachmentFrom: 'abcxxx' readStream withName: 'aTestingAttachment.pdf';
		body: ((MIMEDocument contentType: 'application/foo' content: 'This is the main text' squeakToUtf8) 
					charset: 'utf-8'; yourself).
		
	self assert: message attachments size equals: 1.

	contentType := (message attachments first fieldNamed: 'content-type' ifAbsent: [self fail])
					mainValue.
	self assert: contentType equals: 'application/pdf'.
			
]

{ #category : #tests }
MailMessageTest >> testAttachmentsReturnsTheAttachments [

	| fileName message |
	message := MailMessage empty 
		addAttachmentFrom: 'abcxxx' readStream withName: 'aTestingAttachment';
		body: ((MIMEDocument contentType: 'application/foo' content: 'This is the main text' squeakToUtf8) 
					charset: 'utf-8'; yourself).
		
	self assert: 1 equals: message attachments size.

	fileName := (message attachments first fieldNamed: 'content-disposition' ifAbsent: [self fail])
					parameterAt: 'filename' ifAbsent: [''].
					
	self assert: fileName equals: '"aTestingAttachment"'.
	
	fileName := (message attachments first fieldNamed: 'content-type' ifAbsent: [self fail])
					parameterAt: 'name' ifAbsent: [''].
			
	self assert: fileName equals: '"aTestingAttachment"'.
]

{ #category : #tests }
MailMessageTest >> testAttachmentsWorkWithVeryLongFilenames [

	| fileName message |
	message := MailMessage empty 
		addAttachmentFrom: 'abcxxx' readStream withName: 'aTestingAttachmentWithAVeryVeryVeryVeryVeryVeryVeryVeryLongName.file';
		body: ((MIMEDocument contentType: 'application/foo' content: 'This is the main text' squeakToUtf8) 
					charset: 'utf-8'; yourself).
		
	self assert: message attachments size equals: 1.

	fileName := (message attachments first fieldNamed: 'content-disposition' ifAbsent: [self fail])
					parameterAt: 'filename' ifAbsent: [''].
					
	self assert: '"aTestingAttachmentWithAVeryVeryVeryVeryVeryVeryVeryVeryLongName.file"' equals: fileName 
			
]

{ #category : #tests }
MailMessageTest >> testCreateAReplyForFrom [

	| replyMail |
	replyMail := MailMessage replyFor: self fixtureMail.
	self assert: self fixtureSenderMail equals: replyMail to.
]

{ #category : #tests }
MailMessageTest >> testCreateAReplyForReplyTo [

	| replyMail startMail |
	startMail := self fixtureMail
		setField: 'reply-to' toString: 'anothersender@mail.com';
		yourself.
	replyMail := MailMessage replyFor: startMail.
	self assert: 'anothersender@mail.com' equals: replyMail to.
]

{ #category : #tests }
MailMessageTest >> testCreateAReplyForReplyTos [

	| replyMail startMail |
	startMail := self fixtureMail
		setField: 'reply-to' toString: 'anothersender@mail.com, andanothersender@mail.com';
		yourself.
	replyMail := MailMessage replyFor: startMail.
	self 
		assert: {'anothersender@mail.com' . 'andanothersender@mail.com'} asSet
		equals: ((replyMail to findTokens: ',') collect: [:e | e withBlanksTrimmed]) asSet.
]

{ #category : #tests }
MailMessageTest >> testCreateAReplyHasANewSubject [

	| replyMail |
	replyMail := MailMessage replyFor: self fixtureMail.
	self assert: 'Re: ' , self fixtureSubject equals: replyMail subject.
]

{ #category : #testing }
MailMessageTest >> testCreateAReplyHasANewSubjectUnlessWasAlreadyReply [

	| replyMail startMail |
	startMail := self fixtureMail
		subject: 'Re: Subject';
		yourself.
	replyMail := MailMessage replyFor: startMail.
	self assert: 'Re: Subject' equals: replyMail subject.
]

{ #category : #tests }
MailMessageTest >> testCreateMailMessage [

	| newMail |
	newMail := MailMessage from: 'From: Al Gore <vicepresident@whitehouse.gov>
To: White House Transportation Coordinator <transport@whitehouse.gov>
Subject: [Map of a country]

there is a country map in this mail somewhere'.
	self assert: '[Map of a country]' equals: newMail subject
]

{ #category : #tests }
MailMessageTest >> testDateAndDateString [

	| newMail |
	newMail := MailMessage from: 'From: Al Gore <vicepresident@whitehouse.gov>
To: White House Transportation Coordinator <transport@whitehouse.gov>
Subject: [Map of a country]
Date: Mon, 12 Aug 2002 17:42:00 +0000

there is a country map in this mail somewhere'.

	self assert: (DateAndTime year: 2002 month: 8 day: 12 hour: 17 minute: 42 second: 0 offset: Timespan defaultOffset) equals: newMail date.
	self assert: '8/12/02' equals: newMail dateString.
]

{ #category : #tests }
MailMessageTest >> testDateStampFractionalSecondFormatting [
	self 
		assert: (MailMessage dateStamp: (DateAndTime year: 1901 month: 1 day: 1 hour: 0 minute: 0 second: 1.234 offset: Timespan defaultOffset))
		equals:  'Tue, 1 Jan 1901 00:00:01'
		description: 'RFC822 (and RFC2822) forbids non-integer seconds in dates'
]

{ #category : #tests }
MailMessageTest >> testReplyContainsInReplyTo [

	| replyMail |
	replyMail := MailMessage replyFor: self fixtureMail.
	self assert: self fixtureMessageId equals: (replyMail fieldNamed: 'in-reply-to' ifAbsent: [self fail]) mainValue.
]

{ #category : #tests }
MailMessageTest >> testReplyContainsReferences [

	| replyMail lastReply |
	replyMail := MailMessage replyFor: self fixtureMail.
	replyMail
		setField: 'message-id' toString: 'abc';
		from: 'me@mail.com'.
	lastReply := MailMessage replyFor: replyMail.
	
	self 
		assert: self fixtureMessageId , ', abc' 
		equals: (lastReply fieldNamed: 'references' ifAbsent: [self fail]) mainValue.
]

{ #category : #tests }
MailMessageTest >> testSendableVersionHasCorrectLineBreaks [

	| newMail longContent |
	"To create a string which is too long to very old recommendations
	of the mail message format, which is about 70 characters."
	longContent := ((1 to: 80) do: [:i | i asString]) joinSeparatedBy: ''.
	newMail := self fixtureMail.
	newMail body: ((MIMEDocument 
		contentType: MIMEDocument contentTypePlainText
		content: longContent)
			charset: 'UTF-8';
			yourself).
	newMail := MailMessage from: newMail asSendableText.
	self assert: (newMail bodyTextFormatted asString includesSubstring: longContent)
]
