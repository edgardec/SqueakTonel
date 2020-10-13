"
MagnifierMorph instances are magnifying lenses that magnify the morphs below them (if grabbed or if trackPointer is false) or the area around the mouse pointer.

Instance variables:

magnification	<Number> The magnification to use. If non-integer, smooths the magnified form.

trackPointer		<Boolean> If set, magnifies the area around the Hand. If not, magnfies the area underneath the magnifier center.

showPointer		<Boolean> If set, display a small reversed rectangle in the center of the lens. Also enables the display of Morphs in the Hand itself.

srcExtent		<Rectangle> The extent of the source rectangle.
		
Class variables:

RecursionLock	<MagnifierMorph|nil> Used to avoid infinite recursion when getting the source patch to display.
"
Class {
	#name : #MagnifierMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'magnification',
		'trackPointer',
		'srcExtent',
		'showPointer'
	],
	#classVars : [
		'RecursionLock'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #'parts bin' }
MagnifierMorph class >> descriptionForPartsBin [
	^ self partName:	'Magnifier' translatedNoop
		categories:		{'Just for Fun' translatedNoop}
		documentation:	'A magnifying glass' translatedNoop
]

{ #category : #'class initialization' }
MagnifierMorph class >> initialize [

	self registerInFlapsRegistry.
]

{ #category : #'instance creation' }
MagnifierMorph class >> newRound [
	"Answer a round Magnifier"

	| aMagnifier sm |
	aMagnifier := self new.
	sm := ScreeningMorph new position: aMagnifier position.
	sm addMorph: aMagnifier.
	sm addMorph: (EllipseMorph newBounds: aMagnifier bounds).
	sm setNameTo: 'Magnifier'.
	^ sm
]

{ #category : #'instance creation' }
MagnifierMorph class >> newShowingPointer [
	"Answer a Magnifier that also displays Morphs in the Hand and the Hand position"

	^(self new)
		showPointer: true;
		setNameTo: 'HandMagnifier';
		yourself
]

{ #category : #'class initialization' }
MagnifierMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#MagnifierMorph. #newRound. 'Magnifier' translatedNoop.	'A magnifying glass' translatedNoop}
						forFlapNamed: 'Widgets']
]

{ #category : #'parts bin' }
MagnifierMorph class >> supplementaryPartsDescriptions [
	^ {DescriptionForPartsBin
		formalName: 'RoundGlass' translatedNoop
		categoryList: {'Just for Fun' translatedNoop}
		documentation: 'A round magnifying glass' translatedNoop
		globalReceiverSymbol: #MagnifierMorph
		nativitySelector: #newRound.
		
	DescriptionForPartsBin
		formalName: 'Hand Magnifier' translatedNoop
		categoryList: #()
		documentation: 'A magnifying glass that also shows Morphs in the Hand and displays the Hand position.' translatedNoop
		globalReceiverSymbol: #MagnifierMorph
		nativitySelector: #newShowingPointer }
]

{ #category : #'class initialization' }
MagnifierMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menu }
MagnifierMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu
		addLine;
		add: 'magnification...' translated action: #chooseMagnification;
		addUpdating: #trackingPointerString action: #toggleTrackingPointer;
		addUpdating: #showingPointerString action: #toggleShowingPointer.
]

{ #category : #accessing }
MagnifierMorph >> borderWidth: anInteger [
	"Grow outwards preserving innerBounds"
	| c |  
	c := self center.
	super borderWidth: anInteger.
	super extent: self defaultExtent.
	self center: c.
]

{ #category : #menu }
MagnifierMorph >> chooseMagnification [
	| result |
	result := UIManager default chooseFrom: #(1.5 2 4 8) values: #(1.5 2 4 8) 
		title:  ('Choose magnification
(currently {1})' translated format:{magnification}).
	(result isNil or: [result = magnification]) ifTrue: [^ self].
	magnification := result.
	self extent: self extent. "round to new magnification"
	self changed. "redraw even if extent wasn't changed"
]

{ #category : #menu }
MagnifierMorph >> chooseMagnification: evt [
	| handle origin aHand currentMag |
	currentMag := magnification.
	aHand := evt ifNil: [self currentHand] ifNotNil: [evt hand].
	origin := aHand position y.
	handle := HandleMorph new forEachPointDo:
		[:newPoint | self magnification: (newPoint y - origin) / 8.0 + currentMag].
	aHand attachMorph: handle.
	handle startStepping.
	self changed. "Magnify handle"
]

{ #category : #initialization }
MagnifierMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
MagnifierMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #geometry }
MagnifierMorph >> defaultExtent [
	^(srcExtent * magnification) truncated + (2 * self borderWidth)
]

{ #category : #drawing }
MagnifierMorph >> drawOn: aCanvas [
	super drawOn: aCanvas.		"border and fill"
	aCanvas isShadowDrawing ifFalse: [
		"Optimize because #magnifiedForm is expensive"
		aCanvas paintImage: self magnifiedForm at: self innerBounds origin]
]

{ #category : #geometry }
MagnifierMorph >> extent: aPoint [
	"Round to multiples of magnification"
	srcExtent := (aPoint - (2 * self borderWidth)) // magnification.
	^super extent: self defaultExtent
]

{ #category : #'event handling' }
MagnifierMorph >> handlesMouseDown: evt [
	^evt yellowButtonPressed
		or: [super handlesMouseDown: evt]
]

{ #category : #accessing }
MagnifierMorph >> hasTranslucentColor [
	"I may show what's behind me, so tell the hand to don't cache"
	^self sourceRect intersects: self bounds
]

{ #category : #initialization }
MagnifierMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.

	trackPointer := true.
	showPointer := false.
	magnification := 2.

	self extent: 128 @ 128
]

{ #category : #magnifying }
MagnifierMorph >> magnification: aNumber [
	| c |  
	magnification := aNumber min: 8 max: 0.5.
	magnification := magnification roundTo:
		(magnification < 3 ifTrue: [0.5] ifFalse: [1]).
	srcExtent := srcExtent min: (512@512) // magnification. "to prevent accidents"
	c := self center.
	super extent: self defaultExtent.
	self center: c.
]

{ #category : #magnifying }
MagnifierMorph >> magnifiedForm [
	"Answer the magnified form"
	| srcRect form exclusion magnified |
	srcRect := self sourceRectFrom: self sourcePoint.
	(RecursionLock isNil and: [ self showPointer or: [ srcRect intersects: self bounds ]])
		ifTrue: [RecursionLock := self.
			exclusion := self.
			form := self currentWorld
						patchAt: srcRect
						without: exclusion
						andNothingAbove: false.
			RecursionLock := nil]
		ifFalse: ["cheaper method if the source is not occluded"
			form := Display copy: srcRect].
	"smooth if non-integer scale"
	magnified := form
				magnify: form boundingBox
				by: magnification
				smoothing: (magnification isInteger
						ifTrue: [1]
						ifFalse: [2]).
	"display the pointer rectangle if desired"
	self showPointer
		ifTrue: [magnified
				reverse: (magnified center - (2 @ 2) extent: 4 @ 4)
				fillColor: Color white].
	^ magnified
]

{ #category : #'event handling' }
MagnifierMorph >> mouseDown: evt [
	evt yellowButtonPressed
		ifTrue: [self chooseMagnification: evt]
		ifFalse: [super mouseDown: evt]
]

{ #category : #menu }
MagnifierMorph >> showPointer [
	^showPointer ifNil: [ showPointer := false ].
]

{ #category : #accessing }
MagnifierMorph >> showPointer: aBoolean [
	"If aBoolean is true, display the current pointer position as a small square in the center of the lens."

	showPointer == aBoolean ifTrue: [ ^self ].
	showPointer := aBoolean.
	self changed.
]

{ #category : #menu }
MagnifierMorph >> showingPointerString [
	"Answer a string characterizing whether or not I'm showing the pointer."

	^ (self showPointer 
		ifTrue: ['<yes>']
		ifFalse: ['<no>']), 'show pointer' translated
]

{ #category : #magnifying }
MagnifierMorph >> sourcePoint [
	"If we are being dragged use our center, otherwise use pointer position"
	^(trackPointer not or: [owner notNil and: [owner isHandMorph]])
		ifTrue: [self isFlexed ifTrue:[owner center] ifFalse:[self center]]
		ifFalse: [self currentHand position]
]

{ #category : #magnifying }
MagnifierMorph >> sourceRect [
	^self sourceRectFrom: self sourcePoint

]

{ #category : #magnifying }
MagnifierMorph >> sourceRectFrom: aPoint [
	^ (aPoint extent: srcExtent) translateBy: (srcExtent // -2) + 1.

]

{ #category : #'stepping and presenter' }
MagnifierMorph >> step [
	self changed
]

{ #category : #'stepping and presenter' }
MagnifierMorph >> stepTime [
	^ 33 "ms = 30 frames-per-second"
]

{ #category : #menu }
MagnifierMorph >> toggleShowingPointer [
	self showPointer: self showPointer not
]

{ #category : #menu }
MagnifierMorph >> toggleTrackingPointer [
	trackPointer := trackPointer not
]

{ #category : #menu }
MagnifierMorph >> trackingPointerString [
	"Answer a string describing whether or not I'm currently tracking the pointer."

	^ (trackPointer
		ifTrue: ['<yes>']
		ifFalse: ['<no>']), 'track pointer' translated
]
