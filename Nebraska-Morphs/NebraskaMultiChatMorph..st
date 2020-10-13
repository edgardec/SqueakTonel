Class {
	#name : #NebraskaMultiChatMorph,
	#superclass : #NebraskaChatMorph,
	#instVars : [
		'targetIPAddresses'
	],
	#category : #'Nebraska-Morphs'
}

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph class >> chatWindowForIP: ipAddress name: senderName picture: aForm inWorld: aWorld [

	^self allInstances 
		detect: [ :x | x world == aWorld] 
		ifNone: [
			NebraskaCommunicatorMorph playArrivalSound.
			self new open
		].


]

{ #category : #'parts bin' }
NebraskaMultiChatMorph class >> descriptionForPartsBin [

	^ self partName: 	'Text chat+' translatedNoop
		categories:		#()
		documentation:	'A tool for sending messages to several Squeak users at once' translatedNoop
		sampleImageForm: (Form
	extent: 25@25
	depth: 16
	fromArray: #( 1177640695 1593270007 1593270007 1593270007 1593270007 1593270007 1593270007 1593270007 1593270007 1593270007 1593270007 1593270007 1593245696 1593263665 1593270007 1593270007 1593270007 1177634353 1177628012 1177628012 1177640695 1593270007 1593270007 1593278463 2147450879 1316159488 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593274233 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1731723264 1593257324 762064236 762064236 762064236 762064236 762057894 762057894 762064236 762064236 762064236 762064236 762064236 1177616384 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593278459 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 2147188731 1870200832 1593274233 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1870229369 1731723264)
	offset: 0@0)
]

{ #category : #layout }
NebraskaMultiChatMorph >> acceptDroppingMorph: morphToDrop event: evt [

	(morphToDrop isKindOf: NebraskaSenderMorph) ifFalse: [
		^morphToDrop rejectDropMorphEvent: evt.
	].
	self eToyRejectDropMorph: morphToDrop event: evt.		"we don't really want it"
	self updateIPAddressField: targetIPAddresses,{morphToDrop ipAddress}.


]

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph >> acceptTo: someText forMorph: aMorph [

	| streamedMessage betterText |

	betterText := self improveText: someText forMorph: aMorph.
	streamedMessage := {targetIPAddresses. betterText} eToyStreamedRepresentationNotifying: self.
	targetIPAddresses do: [ :each |
		self 
			transmitStreamedObject: streamedMessage
			to: each.
	].
	aMorph setText: '' asText.
	self appendMessage: 
		self startOfMessageFromMe,
		' - ',
		betterText,
		String cr.

	^true
]

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph >> chatFrom: ipAddress name: senderName text: textPackage [

	super chatFrom: ipAddress name: senderName text: textPackage second.
	self updateIPAddressField: (
		targetIPAddresses,textPackage first,{ipAddress} 
			copyWithout: NetNameResolver localAddressString
	).

]

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph >> editEvent: anEvent for: aMorph [

	| answer initialText aFillInTheBlankMorph |

	(aMorph bounds containsPoint: anEvent cursorPoint) ifFalse: [^self].
	initialText := String streamContents: [ :strm |
		targetIPAddresses do: [ :each | strm nextPutAll: each; cr].
	].
	aFillInTheBlankMorph := FillInTheBlankMorph new
		setQuery: 'Who are you chatting with?' translated
		initialAnswer: initialText
		answerHeight: 250
		acceptOnCR: false.
	aFillInTheBlankMorph responseUponCancel: nil.
	self world addMorph: aFillInTheBlankMorph centeredNear: anEvent cursorPoint.
	answer := aFillInTheBlankMorph getUserResponse.
	answer ifNil: [^self].
	self updateIPAddressField: (answer findTokens: ' ',String cr).


]

{ #category : #initialization }
NebraskaMultiChatMorph >> initialize [

	targetIPAddresses := OrderedCollection new.
	super initialize.
	bounds := 0@0 extent: 350@350.
]

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph >> rebuild [
	| r1 r2 |

	r1 := self addARow: {
		self simpleToggleButtonFor: self attribute: #acceptOnCR help: 'Send with Return?' translated.
		self inAColumn: {StringMorph new contents: 'Multi chat with:' translated; lock}.
		self textEntryFieldNamed: #ipAddress with: ''
					help: 'Click to edit participant list' translated.
	}.
	sendingPane := PluggableTextMorph
				on: self
				text: nil
				accept: #acceptTo:forMorph:.
	sendingPane hResizing: #spaceFill; vResizing: #spaceFill.
	self
		addMorphBack: sendingPane.
	r2 := self addARow: {self inAColumn: {StringMorph new contents: 'Replies' translated; lock}}.
	receivingPane := PluggableTextMorph
				on: self
				text: nil
				accept: nil.
	receivingPane hResizing: #spaceFill; vResizing: #spaceFill.
	self
		addMorphBack: receivingPane.
	receivingPane spaceFillWeight: 3.
	{r1. r2} do: [ :each |
		each
			vResizing: #shrinkWrap; minHeight: 18;
			color: Color veryLightGray.
	].
	self updateIPAddressField: targetIPAddresses.
	sendingPane acceptOnCR: (acceptOnCR ifNil: [acceptOnCR := true]).
]

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph >> standardBorderColor [

	^Color veryLightGray
]

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph >> transmittedObjectCategory [

	^NebraskaIncomingMessage typeMultiChat
]

{ #category : #'as yet unclassified' }
NebraskaMultiChatMorph >> updateIPAddressField: newAddresses [
	
	targetIPAddresses := (
		newAddresses copyWithout: NetNameResolver localAddressString
	) asSet asArray sort.

	(fields at: #ipAddress) contents: targetIPAddresses size printString,' people'.
]

{ #category : #'dropping\/grabbing' }
NebraskaMultiChatMorph >> wantsDroppedMorph: aMorph event: evt [

	(aMorph isKindOf: NebraskaSenderMorph) ifFalse: [^false].
	(bounds containsPoint: evt cursorPoint) ifFalse: [^false].
	^true.
]
