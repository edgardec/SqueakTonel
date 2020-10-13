Class {
	#name : #TextPlusPasteUpMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'theTextMorph',
		'showPageBreaks'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'new-morph participation' }
TextPlusPasteUpMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #layout }
TextPlusPasteUpMorph >> acceptDroppingMorph: aMorph event: evt [

	| allTextPlus |

	(aMorph isKindOf: NewHandleMorph) ifTrue: [^self].
	(aMorph isKindOf: GeeBookMorph) ifTrue: [^self].	"avoid looping"
	(aMorph isKindOf: TextPlusMorph) ifTrue: [
		^self addMorphBack: aMorph.
	].
	self addMorph: aMorph.

	allTextPlus := self allTextPlusMorphs.
	aMorph allMorphsDo: [ :each | 
		allTextPlus do: [ :e2 | e2 removeAlansAnchorFor: each].
	].
	(self nearestTextPlusMorphTo: aMorph) linkNewlyDroppedMorph: aMorph
]

{ #category : #menus }
TextPlusPasteUpMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addUpdating: #showPageBreaksString action: #togglePageBreaks.

]

{ #category : #private }
TextPlusPasteUpMorph >> allTextPlusMorphs [

	^submorphs select: [ :each | each isKindOf: TextPlusMorph]


]

{ #category : #drawing }
TextPlusPasteUpMorph >> disablePageBreaksWhile: aBlock [

	| save result |

	save := showPageBreaks.
	showPageBreaks := false.
	result := aBlock value.
	showPageBreaks := save.
	^result

]

{ #category : #drawing }
TextPlusPasteUpMorph >> drawOn: aCanvas [

	| clip rects |
	super drawOn: aCanvas.
	showPageBreaks == false ifTrue: [^self].

	clip := aCanvas clipRect.
	rects := self printer pageRectangles.
	rects do: [ :each |
		each bottom > clip bottom ifTrue: [^self].
		aCanvas 
			fillRectangle: (self left @ each bottom corner: self right @ each bottom + 1) 
			color: Color red
	].
]

{ #category : #'postscript canvases' }
TextPlusPasteUpMorph >> fullDrawForPrintingOn: aCanvas [

	self disablePageBreaksWhile: [self fullDrawOn: aCanvas].

]

{ #category : #initialization }
TextPlusPasteUpMorph >> initialize [

	super initialize.
	showPageBreaks := true.
	self addMorphBack: (TextPlusMorph new position: 4@4).

]

{ #category : #private }
TextPlusPasteUpMorph >> nearestTextPlusMorphTo: aMorph [

	^self allTextPlusMorphs inject: nil into: [ :best :each |
		self select: best or: each asClosestTo: aMorph
	]
]

{ #category : #drawing }
TextPlusPasteUpMorph >> printer [

	^GeePrinter new 
		pasteUp: self;
		printSpecs: self printSpecs
]

{ #category : #private }
TextPlusPasteUpMorph >> select: bestPrevious or: current asClosestTo: aMorph [

	bestPrevious ifNil: [^current].
	(bestPrevious bounds intersects: aMorph bounds) ifTrue: [^bestPrevious].
	(current bounds intersects: aMorph bounds) ifTrue: [^current].
	bestPrevious left < current left ifTrue: [
		^aMorph left < current left ifTrue: [bestPrevious] ifFalse: [current]
	].
	^aMorph left < bestPrevious left ifTrue: [current] ifFalse: [bestPrevious]

]

{ #category : #menus }
TextPlusPasteUpMorph >> showPageBreaksString [
	^ (showPageBreaks
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'show page breaks' translated
]

{ #category : #menus }
TextPlusPasteUpMorph >> textPlusMenuFor: aMorph [

	^(self nearestTextPlusMorphTo: aMorph) textPlusMenuFor: aMorph

]

{ #category : #menus }
TextPlusPasteUpMorph >> togglePageBreaks [

	showPageBreaks := showPageBreaks not.
	self changed
]

{ #category : #'dropping\/grabbing' }
TextPlusPasteUpMorph >> wantsDroppedMorph: aMorph event: evt [
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. The default implementation returns false.
NOTE: the event is assumed to be in global (world) coordinates."

	(aMorph isKindOf: NewHandleMorph) ifTrue: [^false].
	(aMorph isKindOf: GeeBookMorph) ifTrue: [^false].	"avoid looping"
	^super wantsDroppedMorph: aMorph event: evt
]
