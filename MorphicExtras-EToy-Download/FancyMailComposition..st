Class {
	#name : #FancyMailComposition,
	#superclass : #Model,
	#instVars : [
		'messageText',
		'theLinkToInclude',
		'to',
		'subject'
	],
	#category : #'MorphicExtras-EToy-Download'
}

{ #category : #actions }
FancyMailComposition >> addAttachment [

	self changed: #acceptChanges.

	(FileChooserDialog openOn: FileDirectory default pattern: nil label: 'Choose attachment') ifNotNil: 
		[:fileName |
		FileStream readOnlyFileNamed: fileName do:
			[:file | 
			file binary.
			self messageText:
				((MailMessage from: self messageText asString)
					addAttachmentFrom: file withName: (FileDirectory localNameFor: fileName);  
				text)]]
]

{ #category : #private }
FancyMailComposition >> breakLines: aString  atWidth: width [
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
FancyMailComposition >> breakLinesInMessage: message [
	"reformat long lines in the specified message into shorter ones"
	self flag: #TODO. "Maybe deprecated"
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
FancyMailComposition >> buildButtonsWith: builder [

	| panel |
	panel := builder pluggablePanelSpec new.
	panel
		layout: #horizontal;
		children: OrderedCollection new.
	
	panel children addLast: (builder pluggableButtonSpec new
		model: self;
		label: 'send later';
		help: 'add this to the queue of messages to be sent';
		action: #submit;
		color: Color white;
		yourself).
		
	panel children addLast: (builder pluggableButtonSpec new
		model: self;
		label: 'send now';
		help: 'send this message immediately';
		action: #sendNow;
		color: Color white;
		yourself).

	panel children addLast: (builder pluggableButtonSpec new
		model: self;
		label: 'add attachment';
		help: 'send a file with the message';
		action: #addAttachment;
		color: Color white;
		yourself).

	^ panel
]

{ #category : #toolbuilder }
FancyMailComposition >> buildMessageTextWith: builder [

	^ builder pluggableTextSpec new
		model: self;
		getText: #messageText;
		setText: #messageText:;
		menu: #menuGet:shifted:;
		yourself
]

{ #category : #toolbuilder }
FancyMailComposition >> buildTextFieldsWith: builder [

	| panel |
	panel := builder pluggablePanelSpec new.
	panel
		layout: #vertical;
		children: OrderedCollection new.
	
	panel children addLast: (builder pluggableInputFieldSpec new
		model: self;
		help: 'To';
		getText: #to;
		setText: #to:;
		yourself).

	panel children addLast: (builder pluggableInputFieldSpec new
		model: self;
		help: 'Subject';
		getText: #subject;
		setText: #subject:;
		yourself).

	^ panel
]

{ #category : #toolbuilder }
FancyMailComposition >> buildWith: builder [

	^ builder build: (self buildWindowWith: builder specs: {
		(0 @ 0 corner: 1 @ 0.1) -> [self buildButtonsWith: builder].
		(0 @ 0.1 corner: 1 @ 0.3) -> [self buildTextFieldsWith: builder].
		(0 @ 0.3 corner: 1 @ 1) -> [self buildMessageTextWith: builder]. })
]

{ #category : #initialization }
FancyMailComposition >> celeste: aCeleste to: argTo subject: argSubject initialText: aText theLinkToInclude: linkText [ 
 "self new celeste: Celeste current to: 'danielv@netvision.net.il' subject: 'Mysubj' initialText: 'atext' theLinkToInclude: 'linkText'"

	to := argTo.
	subject := argSubject.
	messageText := aText.
	theLinkToInclude := linkText.
]

{ #category : #actions }
FancyMailComposition >> completeTheMessage [

	| newText strm |
	self changed: #acceptChanges.

	newText := String new: 200.
	strm := WriteStream on: newText.
	strm 
		nextPutAll: 'Content-Type: text/html'; cr;
		nextPutAll: 'From: ', MailSender userName; cr;
		nextPutAll: 'To: ',to; cr;
		nextPutAll: 'Subject: ',subject; cr;

		cr;
		nextPutAll: '<HTML><BODY><BR>';
		nextPutAll: messageText asStringToHtml;
		nextPutAll: '<BR><BR>',theLinkToInclude,'<BR></BODY></HTML>'.
	^strm contents
]

{ #category : #'user interface' }
FancyMailComposition >> defaultWindowColor [

	^ Color veryLightGray
]

{ #category : #'user interface' }
FancyMailComposition >> forgetIt [

	self changed: #close.
]

{ #category : #interface }
FancyMailComposition >> menuGet: aMenu shifted: shifted [
	
	aMenu addList: {
		{'find...(f)' translated.		#find}.
		{'find selection again (g)' translated.		#findAgain}.
			#-.
		{'accept (s)' translated. #accept}.
		{'send message' translated.  #submit}}.

	^aMenu.
]

{ #category : #accessing }
FancyMailComposition >> messageText [
	"return the current text"
	^messageText.

]

{ #category : #accessing }
FancyMailComposition >> messageText: aText [
	"change the current text"
	messageText := aText.
	self changed: #messageText.
	^true
]

{ #category : #'user interface' }
FancyMailComposition >> open [
	
	self flag: #refactor. "FancyMailComposition should probably be removed in favour of MailComposition."
	^ ToolBuilder open: self
]

{ #category : #'MailSender interface' }
FancyMailComposition >> sendMailMessage: aMailMessage [
	self messageText: aMailMessage text
]

{ #category : #actions }
FancyMailComposition >> sendNow [

	self submit: true

]

{ #category : #'MailSender interface' }
FancyMailComposition >> smtpServer [
	^MailSender smtpServer
]

{ #category : #accessing }
FancyMailComposition >> subject [

	^ subject

	
]

{ #category : #accessing }
FancyMailComposition >> subject: x [

	subject := x.
	self changed: #subject.
	^true
]

{ #category : #actions }
FancyMailComposition >> submit [

	self submit: false
]

{ #category : #actions }
FancyMailComposition >> submit: sendNow [

	| message |

	messageText := self breakLines: self completeTheMessage atWidth: 999.
	message := MailMessage from: messageText.
	SMTPClient
			deliverMailFrom: message from 
			to: (Array with: message to) 
			text: message text 
			usingServer: self smtpServer.
	self forgetIt.

]

{ #category : #accessing }
FancyMailComposition >> to [

	^to
]

{ #category : #accessing }
FancyMailComposition >> to: x [

	to := x.	
	self changed: #to.
	^true
	
]

{ #category : #'user interface' }
FancyMailComposition >> windowTitle [

	^ 'Mister Postman'
]
