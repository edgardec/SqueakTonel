"
a message being composed in a fancy way. The mail is send via the registered MailSender by default. Fields do not have to be saved, they are saved automatically on send. 
"
Class {
	#name : #MailComposition,
	#superclass : #Model,
	#instVars : [
		'mailMessage',
		'isSending'
	],
	#category : #'Network-MailSending'
}

{ #category : #'class initialization' }
MailComposition class >> initialize [

	MailSender register: self 
]

{ #category : #opening }
MailComposition class >> open [

	^ ToolBuilder default open: self
]

{ #category : #opening }
MailComposition class >> openOn: aMessage [

	^ ToolBuilder default open: (self new on: aMessage; yourself)
]

{ #category : #'MailSender interface' }
MailComposition class >> sendMailMessage: aMessage [

	self openOn: aMessage
]

{ #category : #'initialize-release' }
MailComposition class >> unload [

	MailSender unregister: self 
]

{ #category : #actions }
MailComposition >> addAttachment [

	self saveFields.
	(UIManager default chooseFileMatching: '*' label: 'Choose attachment') ifNotNil:
		[:fileName |
		FileStream readOnlyFileNamed: fileName do: 
			[:file |
			file binary.
			mailMessage
				addAttachmentFrom: file
				withName: (FileDirectory localNameFor: fileName)].
			self changed: #messageText]. 
]

{ #category : #private }
MailComposition >> addAttachment: stream named: attachmentName [

	stream binary.
	mailMessage
		addAttachmentFrom: stream
		withName: attachmentName
]

{ #category : #'ui constants' }
MailComposition >> addAttachmentButtonLabel [

	^ 'add attachment' translated
]

{ #category : #'ui constants' }
MailComposition >> bccLabel [

	^ 'BCC' translated
]

{ #category : #private }
MailComposition >> breakLines: aString  atWidth: width [
	"break lines in the given string into shorter lines"
	| result atAttachment |

	result := WriteStream on: (String new: (aString size * 50 // 49)).

	atAttachment := false.
	aString asString linesDo: [ :line | | start end | 
		(line beginsWith: '====') ifTrue: [ atAttachment := true ].
		atAttachment ifTrue: [
			"at or after an attachment line; no more wrapping for the rest of the message"
			result nextPutAll: line.  result cr ]
		ifFalse: [
			(line beginsWith: '>') ifTrue: [
				"it's quoted text; don't wrap it"
				result nextPutAll: line. result cr. ]
			ifFalse: [
				"regular old line.  Wrap it to multiple lines"
				start := 1.
					"output one shorter line each time through this loop"
				[ start + width <= line size ] whileTrue: [
	
					"find the end of the line"
					end := start + width - 1.
					[end >= start and: [ (line at: (end+1)) isSeparator not ]] whileTrue: [
						end := end - 1 ].
					end < start ifTrue: [
						"a word spans the entire width!"
						end := start + width - 1 ].

					"copy the line to the output"
					result nextPutAll: (line copyFrom: start to: end).
					result cr.

					"get ready for next iteration"
					start := end+1.
					(line at: start) isSeparator ifTrue: [ start := start + 1 ].
				].

				"write out the final part of the line"
				result nextPutAll: (line copyFrom: start to: line size).
				result cr.
			].
		].
	].

	^result contents
]

{ #category : #private }
MailComposition >> breakLinesInMessage: message [
	"reformat long lines in the specified message into shorter ones"
	message body  mainType = 'text' ifTrue: [
		"it's a single-part text message.  reformat the text"
		| newBodyText |
		newBodyText := self breakLines: message bodyText  atWidth: 72.
		message body: (MIMEDocument contentType: message body contentType content: newBodyText).

		^self ].

	message body isMultipart ifTrue: [
		"multipart message; process the top-level parts.  HACK: the parts are modified in place"
		message parts do: [ :part |
			part body mainType = 'text' ifTrue: [
				| newBodyText |
				newBodyText := self breakLines: part bodyText atWidth: 72.
				part body: (MIMEDocument contentType: part body contentType content: newBodyText) ] ].
		message regenerateBodyFromParts. ].
]

{ #category : #toolbuilder }
MailComposition >> buildButtonBarSpecWith: aBuilder [
	
	| buttonBarSpec |
	buttonBarSpec := aBuilder pluggablePanelSpec new
		children: OrderedCollection new;
		layout: #horizontal;
		frame: (LayoutFrame new
			leftFraction: 0 offset: 0;
			topFraction: 0 offset: 0;
			rightFraction: 1 offset: 0;
			bottomFraction: 0 offset: self buttonBarHeight);
		yourself.
	
	buttonBarSpec children add: (aBuilder pluggableButtonSpec new
		model: self;
		action: #sendMail;
		label: #sendMailButtonLabel;
		color: #sendMailButtonColor;
		yourself).
	
	buttonBarSpec children add: (aBuilder pluggableButtonSpec new
		model: self;
		action: #addAttachment;
		label: #addAttachmentButtonLabel;
		yourself).
		
	buttonBarSpec children add: (aBuilder pluggableButtonSpec new
		model: self;
		action: #removeAttachment;
		label: #removeAttachmentButtonLabel;
		yourself).
		
	^ buttonBarSpec
]

{ #category : #toolbuilder }
MailComposition >> buildWith: aBuilder [

	| spec |

	spec := self createSpecsWith: aBuilder.
	
	^ aBuilder build: spec
]

{ #category : #'ui constants' }
MailComposition >> buttonBarHeight [

	^ 25 "pixel"
]

{ #category : #'ui constants' }
MailComposition >> ccLabel [

	^ 'CC' translated
]

{ #category : #toolbuilder }
MailComposition >> createDetailsFieldsIn: detailsPanelSpec by: aBuilder [
	
   #((senderLabel messageSender messageSender:)
	(recipientLabel messageRecipient messageRecipient:)
	(ccLabel messageCC messageCC:)
	(bccLabel messageBCC messageBCC:)
	(subjectLabel messageSubject messageSubject:)) 
		do: [:config | detailsPanelSpec children add: 
				(self createFieldInputNamed: config first 
					getter: config second 
					setter: config third 
					with: aBuilder)]
	
]

{ #category : #toolbuilder }
MailComposition >> createFieldInputNamed: fieldLabelGetter getter: fieldGetter setter: fieldSetter with: aBuilder [

	^ aBuilder pluggableInputFieldSpec new
		model: self;
		indicateUnacceptedChanges: false;
		getText: fieldGetter;
		setText: fieldSetter;
		name: fieldGetter;
		frame: (LayoutFrame new
			leftFraction: 0 offset: 0;
			topFraction: 0 offset: 0;
			rightFraction: 1 offset: 0;
			bottomFraction: 0 offset: self lineHeight);
		help: fieldLabelGetter;
		yourself
]

{ #category : #toolbuilder }
MailComposition >> createSpecsWith: aBuilder [

	| detailsPanelSpec textSpec windowSpec |
	windowSpec := self createWindowSpecWith: aBuilder.	
	windowSpec children add: (self buildButtonBarSpecWith: aBuilder).
		
	detailsPanelSpec := aBuilder pluggablePanelSpec new
		children: OrderedCollection new;
		layout: #vertical;
		yourself.
	windowSpec children add: detailsPanelSpec.
	
	self createDetailsFieldsIn: detailsPanelSpec by: aBuilder.
	
	detailsPanelSpec children: detailsPanelSpec children reversed.
	detailsPanelSpec frame: (LayoutFrame new
			leftFraction: 0 offset: 0;
			topFraction: 0 offset: self buttonBarHeight;
			rightFraction: 1 offset: 0;
			bottomFraction: 0 offset: self buttonBarHeight + (detailsPanelSpec children size * self lineHeight)).
			
	textSpec := aBuilder pluggableTextSpec new
		model: self;
		indicateUnacceptedChanges: true;
		getText: #messageText;
		setText: #messageText:;
		name: #messageText;
		frame: (LayoutFrame new
			leftFraction: 0 offset: 0;
			topFraction: 0 offset: self buttonBarHeight + (detailsPanelSpec children size * self lineHeight);
			rightFraction: 1 offset: 0;
			bottomFraction: 1 offset: 0);
		yourself.	
	windowSpec children add: textSpec.
	
	^ windowSpec
]

{ #category : #toolbuilder }
MailComposition >> createWindowSpecWith: aBuilder [

	^ aBuilder pluggableWindowSpec new
		model: self;
		label: #dialogTitle;
		children: OrderedCollection new.
]

{ #category : #toolbuilder }
MailComposition >> dialogTitle [

	^ 'mail editor' translated
]

{ #category : #private }
MailComposition >> doSendMail [

	(SMTPClient openOnHostNamed: self smtpServer port: self smtpServerPort)
		user: self smtpUser;
		password: self smtpPassword;
		login;
		mailFrom: mailMessage from to: (mailMessage to findTokens: ',') text: mailMessage asSendableText.
]

{ #category : #'initialize-release' }
MailComposition >> initialize [

	mailMessage := MailMessage empty.
	isSending := false.
]

{ #category : #private }
MailComposition >> isSending [

	^ isSending
]

{ #category : #'ui constants' }
MailComposition >> lineHeight [

	^ 25 "pixel"
]

{ #category : #'access to mail object' }
MailComposition >> messageBCC [

	^ mailMessage bcc
]

{ #category : #'access to mail object' }
MailComposition >> messageBCC: emailAddresses [

	self flag: #TODO. "add validation"
	mailMessage bcc: emailAddresses asString.
	^ true
]

{ #category : #'access to mail object' }
MailComposition >> messageCC [

	^ mailMessage cc
]

{ #category : #'access to mail object' }
MailComposition >> messageCC: emailAddresses [

	self flag: #TODO. "add validation"
	mailMessage cc: emailAddresses asString.
	^ true
]

{ #category : #'access to mail object' }
MailComposition >> messageRecipient [

	^ mailMessage to
]

{ #category : #'access to mail object' }
MailComposition >> messageRecipient: emailAddresses [

	self flag: #TODO. "add validation"
	mailMessage to: emailAddresses asString.
	^ true
]

{ #category : #'access to mail object' }
MailComposition >> messageSender [

	^ mailMessage from
]

{ #category : #'access to mail object' }
MailComposition >> messageSender: emailAddress [

	self flag: #TODO. "add validation"
	mailMessage from: emailAddress asString.
	^ true
]

{ #category : #'access to mail object' }
MailComposition >> messageSubject [

	^ mailMessage subject
]

{ #category : #'access to mail object' }
MailComposition >> messageSubject: aSubject [

	self flag: #TODO. "add validation"
	mailMessage subject: aSubject asString.
	^ true
]

{ #category : #'access to mail object' }
MailComposition >> messageText [

	^ mailMessage bodyTextFormatted
]

{ #category : #'access to mail object' }
MailComposition >> messageText: aText [

	mailMessage body: ((MIMEDocument 
		contentType: MIMEDocument contentTypePlainText
		content: aText asString)
			charset: 'UTF-8';
			yourself).
	^ true
]

{ #category : #'initialize-release' }
MailComposition >> on: aMessage [

	mailMessage := aMessage
]

{ #category : #'initialize-release' }
MailComposition >> open [
	"open an interface"

	^ToolBuilder open: self label:  self dialogTitle
]

{ #category : #private }
MailComposition >> perform: selector orSendTo: otherTarget [

	(self respondsTo: selector)
		ifTrue: [^self perform: selector]
		ifFalse: [^otherTarget perform: selector]

	
]

{ #category : #'ui constants' }
MailComposition >> recipientLabel [

	^ 'Recipients' translated
]

{ #category : #actions }
MailComposition >> removeAttachment [
	
	| attachmentToBeRemoved |
	
	self saveFields.
	attachmentToBeRemoved := UIManager default 
		chooseFrom: (mailMessage attachments collect: [:m | m attachmentFileName ])
		values: mailMessage attachments 
		title: 'Choose attachment to be removed' translated.
	mailMessage removeAttachment: attachmentToBeRemoved.
	self changed: #messageText.
]

{ #category : #'ui constants' }
MailComposition >> removeAttachmentButtonLabel [

	^ 'remove attachment' translated
]

{ #category : #private }
MailComposition >> resetSending [

	isSending := false.
	self changed.
]

{ #category : #private }
MailComposition >> saveFields [
	
	(self dependents select: [:d | d hasUnacceptedEdits]) do: [:d | d accept].
]

{ #category : #actions }
MailComposition >> sendMail [

	self isSending ifFalse: [
		self saveFields.

		self setSending.
	
		[[self doSendMail] on: Error do: [:e | self resetSending. e signal].
		Project current addDeferredUIMessage: [self changed: #close].] 
			forkAt: 30.
			
		self 
			changed: #sendMailButtonLabel;
			changed: #sendMailButtonColor]
]

{ #category : #'ui constants' }
MailComposition >> sendMailButtonColor [

	^ self isSending
		ifTrue: [Color green lighter duller]
		ifFalse: [PluggableButtonMorph new userInterfaceTheme color]
]

{ #category : #'ui constants' }
MailComposition >> sendMailButtonLabel [

	^ (self isSending
		ifTrue: ['sending...']
		ifFalse: ['send mail']) translated
]

{ #category : #interface }
MailComposition >> sendMailMessage: aMailMessage [
	self messageText: aMailMessage text
]

{ #category : #'ui constants' }
MailComposition >> senderLabel [

	^ 'Sender' translated
]

{ #category : #private }
MailComposition >> setSending [

	isSending := true.
]

{ #category : #'MailSender interface' }
MailComposition >> smtpPassword [

	^ MailSender userPassword
]

{ #category : #'MailSender interface' }
MailComposition >> smtpServer [

	^ MailSender smtpServer
]

{ #category : #'MailSender interface' }
MailComposition >> smtpServerPort [

	^ MailSender smtpServerPort
]

{ #category : #'MailSender interface' }
MailComposition >> smtpUser [

	^ MailSender userName
]

{ #category : #'ui constants' }
MailComposition >> subjectLabel [

	^ 'Subject' translated
]
