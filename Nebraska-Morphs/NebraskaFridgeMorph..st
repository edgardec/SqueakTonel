"
EToyFridgeMorph new openInWorld
"
Class {
	#name : #NebraskaFridgeMorph,
	#superclass : #NebraskaCommunicatorMorph,
	#instVars : [
		'recipients',
		'incomingRow',
		'recipientRow',
		'updateCounter',
		'groupMode'
	],
	#classVars : [
		'FridgeRecipients',
		'NewItems',
		'TheFridgeForm',
		'UpdateCounter'
	],
	#category : #'Nebraska-Morphs'
}

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph class >> addRecipient: aSenderMorph [

	self fridgeRecipients do: [ :each |
		aSenderMorph ipAddress = each ipAddress ifTrue: [^self]
	].
	self fridgeRecipients add: aSenderMorph.
	UpdateCounter := self updateCounter + 1

]

{ #category : #'parts bin' }
NebraskaFridgeMorph class >> descriptionForPartsBin [

	^ self partName: 	'Fridge' translatedNoop
		categories:		#()
		documentation:	'A tool for sending objects to other Squeak users' translatedNoop
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph class >> fridgeForm [

	| fridgeFileName |

	fridgeFileName := 'fridge.form'.
	TheFridgeForm ifNotNil: [^TheFridgeForm].
	(FileDirectory default fileExists: fridgeFileName) ifFalse: [^nil].
	^TheFridgeForm := Form fromFileNamed: fridgeFileName.
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph class >> fridgeRecipients [

	^FridgeRecipients ifNil: [FridgeRecipients := OrderedCollection new]
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph class >> newItem: newMorph [

	| theFridge fridgeWorld trialRect |

	theFridge := Project named: 'Fridge'.
	theFridge ifNil: [^self newItems add: newMorph].
	fridgeWorld := theFridge world.
	trialRect := fridgeWorld randomBoundsFor: newMorph.
	fridgeWorld 
		addMorphFront: (newMorph position: trialRect topLeft);
		startSteppingSubmorphsOf: newMorph

]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph class >> newItems [

	^NewItems ifNil: [NewItems := OrderedCollection new]
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph class >> removeRecipientWithIPAddress: ipString [

	FridgeRecipients := self fridgeRecipients reject: [ :each |
		ipString = each ipAddress
	].
	UpdateCounter := self updateCounter + 1

]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph class >> updateCounter [

	^UpdateCounter ifNil: [0]
]

{ #category : #layout }
NebraskaFridgeMorph >> acceptDroppingMorph: morphToDrop event: evt [

	| outData |

	(morphToDrop isKindOf: NewHandleMorph) ifTrue: [		"don't send these"
		^morphToDrop rejectDropMorphEvent: evt
	].
	self eToyRejectDropMorph: morphToDrop event: evt.		"we will keep a copy"
	(morphToDrop isKindOf: NebraskaSenderMorph) ifTrue: [
		self class addRecipient: morphToDrop.
		^self rebuild
	].
	self stopFlashing.
	"7 mar 2001 - remove #veryDeepCopy"
	outData := morphToDrop eToyStreamedRepresentationNotifying: self.
	self resetIndicator: #working.
	self class fridgeRecipients do: [ :each |
		self transmitStreamedObject: outData to: each ipAddress
	].


]

{ #category : #initialization }
NebraskaFridgeMorph >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
NebraskaFridgeMorph >> defaultBorderStyle [
	^ BorderStyle raised
]

{ #category : #initialization }
NebraskaFridgeMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 4
]

{ #category : #initialization }
NebraskaFridgeMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color paleRed
]

{ #category : #drawing }
NebraskaFridgeMorph >> drawOn: aCanvas [

	| f cache |
	f := self class fridgeForm ifNil: [^super drawOn: aCanvas].
	cache := Form extent: bounds extent depth: aCanvas depth.
	f
		displayInterpolatedIn: cache boundingBox truncated
		on: cache.
	cache replaceColor: Color black withColor: Color transparent.
	aCanvas 
		translucentImage: cache
		at: bounds origin.

]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> getChoice: aString [

	aString = 'group' ifTrue: [^groupMode ifNil: [true]].
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> groupToggleButton [
	self flag: #todo.
	^(self inAColumn: {
		(ThreePhaseButtonMorph checkBox)
			target: self;
			actionSelector: #toggleChoice:;
			arguments: {'group'};
			"getSelector: #getChoice:;"
			setBalloonText: 'Changes between group mode and individuals' translated;
			step
	}) hResizing: #shrinkWrap

]

{ #category : #'event handling' }
NebraskaFridgeMorph >> handlesMouseDown: globalEvt [

	| localCursorPoint |
	localCursorPoint := self globalPointToLocal: globalEvt cursorPoint.
	groupMode ifFalse: [
		self allMorphsDo: [ :each |
			(each isKindOf: NebraskaSenderMorph) ifTrue: [
				(each bounds containsPoint: localCursorPoint) ifTrue: [^false].
			].
		].
	].
	^true
]

{ #category : #'event handling' }
NebraskaFridgeMorph >> handlesMouseOver: globalEvt [

	^true
]

{ #category : #'event handling' }
NebraskaFridgeMorph >> handlesMouseOverDragging: globalEvt [

	^true
]

{ #category : #initialization }
NebraskaFridgeMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	groupMode := true.
	self listDirection: #topToBottom;
		 layoutInset: 10;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 setProperty: #normalBorderColor toValue: self borderColor;
		 setProperty: #flashingColors toValue: {Color red. Color yellow};
		 rebuild
]

{ #category : #'event handling' }
NebraskaFridgeMorph >> mouseDown: localEvt [

	self addMouseActionIndicatorsWidth: 15 color: (Color blue alpha: 0.7).

]

{ #category : #'event handling' }
NebraskaFridgeMorph >> mouseEnter: evt [

	^self mouseEnterEither: evt

]

{ #category : #'event handling' }
NebraskaFridgeMorph >> mouseEnterDragging: evt [

	^self mouseEnterEither: evt

]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> mouseEnterEither: evt [

	evt hand hasSubmorphs ifFalse: [
		^self addMouseActionIndicatorsWidth: 10 color: (Color blue alpha: 0.3).
	].
	(evt hand firstSubmorph isKindOf: NebraskaSenderMorph) ifTrue: [
		^self addMouseActionIndicatorsWidth: 10 color: (Color magenta alpha: 0.3).
	].
	self addMouseActionIndicatorsWidth: 10 color: (Color green alpha: 0.3).


]

{ #category : #'event handling' }
NebraskaFridgeMorph >> mouseLeave: evt [

	^self mouseLeaveEither: evt

]

{ #category : #'event handling' }
NebraskaFridgeMorph >> mouseLeaveDragging: evt [

	^self mouseLeaveEither: evt

]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> mouseLeaveEither: evt [

	self deleteAnyMouseActionIndicators.


]

{ #category : #'event handling' }
NebraskaFridgeMorph >> mouseUp: localEvt [

	(self containsPoint: localEvt cursorPoint) ifFalse: [^self].
	Project enterIfThereOrFind: 'Fridge'
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> noteRemovalOf: aSenderMorph [

	self class removeRecipientWithIPAddress: aSenderMorph ipAddress
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> rebuild [

	| row filler fudge people maxPerRow insetY |

	updateCounter := self class updateCounter.
	self removeAllMorphs.
	(self addARow: {
		filler := Morph new color: Color transparent; extent: 4@4.
	}) vResizing: #shrinkWrap.
	self addARow: {
		(StringMorph contents: 'the Fridge' translated) lock.
		self groupToggleButton.
	}.
	row := self addARow: {}.
	people := self class fridgeRecipients.
	maxPerRow := people size < 7 ifTrue: [2] ifFalse: [3].	
		"how big can this get before we need a different approach?"
	people do: [ :each |
		row submorphCount >= maxPerRow ifTrue: [row := self addARow: {}].
		row addMorphBack: (
			groupMode ifTrue: [
				(each userPicture scaledToSize: 35@35) asMorph lock
			] ifFalse: [
				each veryDeepCopy killExistingChat
			]
		)
	].
	fullBounds := nil.
	self fullBounds.
	"htsBefore := submorphs collect: [ :each | each height]."

	fudge := 20.
	insetY := self layoutInset.
	insetY isPoint ifTrue: [insetY := insetY y].
	filler extent: 
		4 @ (self height - filler height * 0.37 - insetY - self borderWidth - fudge) truncated.

	"self fixLayout.
	htsAfter := submorphs collect: [ :each | each height].
	{htsBefore. htsAfter} explore."


]

{ #category : #'stepping and presenter' }
NebraskaFridgeMorph >> step [

	super step.
	updateCounter = self class updateCounter ifFalse: [self rebuild].

]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> toggleChoice: aString [

	updateCounter := nil.		"force rebuild"
	aString = 'group' ifTrue: [^groupMode := (groupMode ifNil: [true]) not].

]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> transmittedObjectCategory [

	^NebraskaIncomingMessage typeFridge
]

{ #category : #'as yet unclassified' }
NebraskaFridgeMorph >> trulyFlashIndicator: aSymbol [

	| state |

	state := (self 
		valueOfProperty: #fridgeFlashingState
		ifAbsent: [false]) not.
	self setProperty: #fridgeFlashingState toValue: state.

	self 
		addMouseActionIndicatorsWidth: 15 
		color: (Color green alpha: (state ifTrue: [0.3] ifFalse: [0.7])). Beeper beep.
	"self world displayWorldSafely."
]

{ #category : #'dropping\/grabbing' }
NebraskaFridgeMorph >> wantsDroppedMorph: aMorph event: evt [

	^true
]
