"
EToyChatMorph new open setIPAddress: '1.2.3.4'

""
EToyChatMorph represents a chat session with another person. Type your message in the top text pane and press cmd-S.
""
"
Class {
	#name : #NebraskaChatMorph,
	#superclass : #NebraskaChatOrBadgeMorph,
	#instVars : [
		'listener',
		'receivingPane',
		'myForm',
		'recipientForm',
		'acceptOnCR',
		'sendingPane'
	],
	#category : #'Nebraska-Morphs'
}

{ #category : #'as yet unclassified' }
NebraskaChatMorph class >> chatFrom: ipAddress name: senderName text: text [

	| chatWindow |

	chatWindow := self 
		chatWindowForIP: ipAddress 
		name: senderName 
		picture: (NebraskaSenderMorph pictureForIPAddress: ipAddress) 
		inWorld: self currentWorld.
	chatWindow
		chatFrom: ipAddress 
		name: senderName 
		text: text

]

{ #category : #'as yet unclassified' }
NebraskaChatMorph class >> chatWindowForIP: ipAddress name: senderName picture: aForm inWorld: aWorld [

	| makeANewOne aSenderBadge existing |

	existing := self instanceForIP: ipAddress inWorld: aWorld.
	existing ifNotNil: [^existing].
	makeANewOne := [
		self new
			recipientForm: aForm; 
			open; 
			setIPAddress: ipAddress
	].
	NebraskaCommunicatorMorph playArrivalSound.
	self doChatsInternalToBadge ifTrue: [
		aSenderBadge := NebraskaSenderMorph instanceForIP: ipAddress inWorld: aWorld.
		aSenderBadge ifNotNil: [
			aSenderBadge startChat: false.
			^aSenderBadge 
				findDeepSubmorphThat: [ :x | x isKindOf: NebraskaChatMorph] 
				ifAbsent: makeANewOne
		].
		aSenderBadge := NebraskaSenderMorph instanceForIP: ipAddress.
		aSenderBadge ifNotNil: [
			aSenderBadge := aSenderBadge veryDeepCopy.
			aSenderBadge 
				killExistingChat;
				openInWorld: aWorld;
				startChat: false.
			^aSenderBadge 
				findDeepSubmorphThat: [ :x | x isKindOf: NebraskaChatMorph] 
				ifAbsent: makeANewOne
		].
		(aSenderBadge := NebraskaSenderMorph new)
			userName: senderName 
			userPicture: aForm
			userEmail: 'unknown'  translated
			userIPAddress: ipAddress;
			position: 200@200;
			openInWorld: aWorld;
			startChat: false.
		^aSenderBadge 
			findDeepSubmorphThat: [ :x | x isKindOf: NebraskaChatMorph] 
			ifAbsent: makeANewOne
	].
	^makeANewOne value.


]

{ #category : #'parts bin' }
NebraskaChatMorph class >> descriptionForPartsBin [

	^ self partName: 	'Text chat' translatedNoop
		categories:		#()
		documentation:	'A tool for sending messages to other Squeak users' translatedNoop
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph class >> doChatsInternalToBadge [

	^true
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph class >> instanceForIP: ipAddress inWorld: aWorld [

	^self allInstances detect: [ :x | 
		x world == aWorld and: [x ipAddress = ipAddress]
	] ifNone: [nil]


]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> acceptTo: someText forMorph: aMorph [

	| betterText |

	betterText := self improveText: someText forMorph: aMorph.
	self 
		transmitStreamedObject: (betterText eToyStreamedRepresentationNotifying: self) 
		to: self ipAddress.
	aMorph setText: '' asText.
	self appendMessage: 
		self startOfMessageFromMe,
		' - ',
		betterText,
		String cr.

	^true
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> appendMessage: aText [

	receivingPane appendTextEtoy: aText.
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> chatFrom: ipAddress name: senderName text: text [

	| initialText attrib |

	recipientForm ifNil: [
		initialText := senderName asText allBold.
	] ifNotNil: [
		attrib := TextAnchor new anchoredMorph: recipientForm "asMorph".
		initialText := (String value: 1) asText.
		initialText addAttribute: attrib from: 1 to: 1.
	].
	self appendMessage: initialText,' - ',text,String cr.
	NebraskaCommunicatorMorph playArrivalSound.



]

{ #category : #initialization }
NebraskaChatMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ self standardBorderColor
]

{ #category : #initialization }
NebraskaChatMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 8
]

{ #category : #initialization }
NebraskaChatMorph >> defaultBounds [
"answer the default bounds for the receiver"
	^ 400 @ 100 extent: 200 @ 150
]

{ #category : #initialization }
NebraskaChatMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color paleYellow
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> getChoice: aSymbol [
	
	aSymbol == #acceptOnCR ifTrue: [^acceptOnCR ifNil: [true]].
	^false.

]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> improveText: someText forMorph: aMorph [

	| betterText conversions fontForAll |

	fontForAll := aMorph eToyGetMainFont.
	betterText := someText veryDeepCopy.
	conversions := OrderedCollection new.
	betterText runs withStartStopAndValueDo: [:start :stop :attributes |
		attributes do: [:att |
			(att isMemberOf: TextFontChange) ifTrue: [
				conversions add: {att. start. stop}
			]
		]
	].
	conversions do: [ :old |
		| newAttr |
		betterText removeAttribute: old first from: old second to: old third.
		newAttr := TextFontReference toFont: (fontForAll fontAt: old first fontNumber).
		newAttr fontNumber: old first fontNumber.
		betterText addAttribute: newAttr from: old second to: old third.
	].
	^betterText
]

{ #category : #initialization }
NebraskaChatMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	acceptOnCR := true.
	self listDirection: #topToBottom;
		 layoutInset: 0;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 rubberBandCells: false;
		 minWidth: 200;
		 minHeight: 200;
		 rebuild 
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> insetTheScrollbars [

	self allMorphsDo: [ :each | 
		(each isKindOf: PluggableTextMorph) ifTrue: [each retractable: false]
	].
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> ipAddress [
	
	^(fields at: #ipAddress) contents
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> open [
	
	^self openIn: self currentWorld
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> openIn: aWorld [

	"open an a chat window"

	aWorld ifNil: [^self].
	self 
		position: 400@100;
		extent:  200@150;
		openInWorld: aWorld.
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> rebuild [
	| r1 r2 |

	r1 := self addARow: {
		self simpleToggleButtonFor: self attribute: #acceptOnCR help: 'Send with Return?' translated.
		self inAColumn: {StringMorph new contents: 'Your message to:' translated; font: Preferences standardMenuFont; lock}.
		self textEntryFieldNamed: #ipAddress with: ''
					help: 'IP address for chat partner' translated.
	}.
	recipientForm ifNotNil: [
		r1 addMorphBack: recipientForm asMorph lock
	].
	sendingPane := PluggableTextMorph
				on: self
				text: nil
				accept: #acceptTo:forMorph:.
	sendingPane hResizing: #spaceFill; vResizing: #spaceFill.
	sendingPane font: Preferences standardMenuFont.
	self
		addMorphBack: sendingPane.
	r2 := self addARow: {self inAColumn: {StringMorph new contents: 'Replies' translated; font: Preferences standardMenuFont; lock}}.
	receivingPane := PluggableTextMorph
				on: self
				text: nil
				accept: nil.
	receivingPane font: Preferences standardMenuFont.
	receivingPane hResizing: #spaceFill; vResizing: #spaceFill.
	self
		addMorphBack: receivingPane.
	receivingPane spaceFillWeight: 3.
	{r1. r2} do: [ :each |
		each
			vResizing: #shrinkWrap; minHeight: 18;
			color: Color veryLightGray.
	].
	sendingPane acceptOnCR: (acceptOnCR ifNil: [acceptOnCR := true])
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> recipientForm: aForm [

	recipientForm := aForm.
	recipientForm ifNotNil: [recipientForm := recipientForm scaledToSize: 20@20].
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> reportError: aString [

	receivingPane appendTextEtoy: (aString asText addAttribute: TextColor red), String cr.
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> setIPAddress: aString [
	
	(fields at: #ipAddress) contents: aString
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> standardBorderColor [

	^Color darkGray
]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> startOfMessageFromMe [

	myForm ifNil: [
		myForm := NebraskaSenderMorph pictureForIPAddress: NetNameResolver localAddressString.
		myForm ifNotNil: [
			myForm := myForm scaledToSize: 20@20
		].
	].
	myForm ifNil: [
		^(Preferences defaultAuthorName asText allBold addAttribute: TextColor blue)
	].
	^(String value: 1) asText
		addAttribute: (TextAnchor new anchoredMorph: myForm);
		yourself


]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> toggleChoice: aSymbol [
	
	aSymbol == #acceptOnCR ifTrue: [
		acceptOnCR := (acceptOnCR ifNil: [true]) not.
		sendingPane ifNotNil: [sendingPane acceptOnCR: acceptOnCR].
		^self
	].


]

{ #category : #'as yet unclassified' }
NebraskaChatMorph >> transmittedObjectCategory [

	^NebraskaIncomingMessage typeKeyboardChat
]
