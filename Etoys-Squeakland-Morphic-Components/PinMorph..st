Class {
	#name : #PinMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'component',
		'pinForm',
		'pinSpec',
		'wires'
	],
	#classVars : [
		'InputPinForm',
		'IoPinForm',
		'OutputPinForm'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #'new-morph participation' }
PinMorph class >> includeInNewMorphMenu [
	^ false
]

{ #category : #'class initialization' }
PinMorph class >> initialize [  "PinMorph initialize"
	OutputPinForm := Form extent: 8@8 depth: 1 fromArray:
			#( 0 3221225472 4026531840 4227858432 4278190080 4227858432 4026531840 3221225472)
		offset: 0@0.

	IoPinForm := Form extent: 8@8 depth: 1 fromArray:
			#( 0 402653184 1006632960 2113929216 4278190080 2113929216 1006632960 402653184)
		offset: 0@0.

	InputPinForm := OutputPinForm flipBy: #horizontal centerAt: 0@0.

]

{ #category : #variables }
PinMorph >> addModelVariable [
	| accessors |
	accessors := component model addVariableNamed: component knownName , pinSpec pinName.
	pinSpec modelReadSelector: accessors first modelWriteSelector: accessors second.
	component initFromPinSpecs.
	self connectedPins do: [:connectee | connectee shareVariableOf: self]
]

{ #category : #wires }
PinMorph >> addWire: aWireMorph [
	wires add: aWireMorph
]

{ #category : #wires }
PinMorph >> canDockWith: otherPin [
	"Later include data type compatibility and circularity as well"
	(pinSpec isInputOnly and: [otherPin pinSpec isInputOnly]) ifTrue: [^ false].
	(pinSpec isOutputOnly and: [otherPin pinSpec isOutputOnly]) ifTrue: [^ false].
	^ true
]

{ #category : #initialization }
PinMorph >> component: aComponent pinSpec: spec [
	component := aComponent.
	pinSpec := spec.
	pinSpec isInput ifTrue: [pinForm := InputPinForm].
	pinSpec isOutput ifTrue: [pinForm := OutputPinForm].
	pinSpec isInputOutput ifTrue: [pinForm := IoPinForm].
	self image: pinForm
]

{ #category : #wires }
PinMorph >> connectedPins [
	^ wires collect: [:w | w otherPinFrom: self]
]

{ #category : #'submorphs-add\/remove' }
PinMorph >> delete [
	self unwire.
	^ super delete
]

{ #category : #'event handling' }
PinMorph >> handlesMouseDown: evt [

	^ (evt yellowButtonPressed | evt blueButtonPressed) not

]

{ #category : #variables }
PinMorph >> hasVariable [
	^ pinSpec hasVariable
]

{ #category : #initialization }
PinMorph >> initialize [
	super initialize.
	wires := OrderedCollection new
]

{ #category : #wires }
PinMorph >> isIsolated [
	^ wires isEmpty
]

{ #category : #variables }
PinMorph >> mergeVariableWith: otherPin [
	"Change all pins with otherPin's selectors to these selectors,
	and then remove the slot and accessors for the old selectors"
	self removeModelVariable.
	self connectedPins do:
		[:connectee | connectee shareVariableOf: otherPin].
	self shareVariableOf: otherPin
]

{ #category : #'event handling' }
PinMorph >> mouseDown: event [
	"Unshifted action is to move the pin (see mouseMove:)"
	event shiftPressed ifTrue: [self startWiring: event].

]

{ #category : #'event handling' }
PinMorph >> mouseMove: evt [
	evt shiftPressed ifTrue: [^ self].
	self position: evt targetPoint.
	self updateImage
]

{ #category : #accessing }
PinMorph >> pinSpec [
	^ pinSpec
]

{ #category : #geometry }
PinMorph >> placeFromSpec [
	| side corners c1 c2 |
	side := pinSpec pinLoc asInteger.  "1..4 ccw from left"
	corners := owner bounds corners.
	c1 := corners at: side.
	c2 := corners atWrap: side+1.
	self position: (c1 + (c2 - c1 * pinSpec pinLoc fractionPart)).
	self updateImage.
]

{ #category : #geometry }
PinMorph >> position: p [ 
	"Adhere to owner bounds, and apply gridding"

	| r side p1 corners c1 c2 sideIndex |
	r := owner bounds.
	side := r sideNearestTo: p.
	p1 := r pointNearestTo: p.	"a point on the border"
	p1 := (side = #top or: [side = #left]) 
		ifTrue: [r topLeft + (p1 - r topLeft grid: 4 @ 4)]
		ifFalse: [ r bottomRight + (p1 - r bottomRight grid: 4 @ 4)].

	"Update pin spec(5) = side index + fraction along side"
	corners := r corners.
	sideIndex := #(#left #bottom #right #top) indexOf: side.
	c1 := corners at: sideIndex.
	c2 := corners atWrap: sideIndex + 1.
	pinSpec pinLoc: sideIndex + ((p1 dist: c1) / (c2 dist: c1) min: 0.99999).

	"Set new position with appropriate offset."
	side = #top ifTrue: [super position: p1 - (0 @ 8)].
	side = #left ifTrue: [super position: p1 - (8 @ 0)].
	side = #bottom ifTrue: [super position: p1].
	side = #right ifTrue: [super position: p1].
	wires do: [:w | w pinMoved]
]

{ #category : #variables }
PinMorph >> removeModelVariable [
	component model removeVariableNamed: pinSpec variableName.
	self removeVariableAccess
]

{ #category : #variables }
PinMorph >> removeVariableAccess [
	pinSpec modelReadSelector: nil modelWriteSelector: nil.
	component initFromPinSpecs
]

{ #category : #wires }
PinMorph >> removeWire: aWireMorph [
	wires remove: aWireMorph
]

{ #category : #variables }
PinMorph >> shareVariableOf: otherPin [
	pinSpec modelReadSelector: otherPin pinSpec modelReadSelector
			modelWriteSelector: otherPin pinSpec modelWriteSelector.
	component initFromPinSpecs
]

{ #category : #wires }
PinMorph >> startWiring: event [ 
	"Start wiring from this pin"

	| origin handle candidates candidate wiringColor wire |
	origin := self wiringEndPoint.
	candidates := OrderedCollection new.
	"Later this could be much faster if we define pinMorphsDo:
		so that it doesn't go too deep and bypasses non-widgets."
	self pasteUpMorph allMorphsDo: 
			[:m | 
			((m isMemberOf: PinMorph) and: [m canDockWith: self]) 
				ifTrue: [candidates add: m]].
	handle := NewHandleMorph new 
				followHand: event hand
				forEachPointDo: 
					[:newPoint | 
					candidate := candidates detect: [:m | m containsPoint: newPoint]
								ifNone: [nil].
					wiringColor := candidate isNil ifTrue: [Color black] ifFalse: [Color red].
					handle
						removeAllMorphs;
						addMorph: (PolygonMorph 
									vertices: (Array with: origin with: newPoint)
									color: Color black
									borderWidth: 1
									borderColor: wiringColor)]
				lastPointDo: 
					[:lastPoint | 
					(self wireTo: candidate) 
						ifTrue: 
							[wire := (WireMorph 
										vertices: (Array with: origin with: lastPoint)
										color: Color black
										borderWidth: 1
										borderColor: Color black) fromPin: self toPin: candidate.
							self pasteUpMorph addMorph: wire.
							self addWire: wire.
							candidate addWire: wire]].
	event hand world addMorph: handle.
	handle startStepping
]

{ #category : #wires }
PinMorph >> unwire [
	"Remove wires one by one.  Not fastest, but by far simplest"

	wires do: [:w | w delete].  "This is where all the work is done"
]

{ #category : #geometry }
PinMorph >> updateImage [
	"pinForm was made for right side.  Rotate/flip for other sides"

	bounds left < owner bounds left ifTrue:  "left side"
		[^ self image: (pinForm flipBy: #horizontal centerAt: 0@0)].
	bounds bottom > owner bounds bottom ifTrue:  "bottom"
		[^ self image: ((pinForm rotateBy: #left centerAt: 0@0)
								flipBy: #vertical centerAt: 0@0)].
	bounds right > owner bounds right ifTrue:  "right side"
		[^ self image: pinForm].
	bounds top < owner bounds top ifTrue:  "top"
		[^ self image: (pinForm rotateBy: #left centerAt: 0@0)].
self halt: 'uncaught pin geometry case'
]

{ #category : #wires }
PinMorph >> wireTo: otherPin [ 
	"Note must return true or false indicating success"

	(otherPin isNil or: [otherPin == self]) ifTrue: [^false].
	self hasVariable 
		ifTrue: 
			[otherPin hasVariable 
				ifTrue: [self mergeVariableWith: otherPin]
				ifFalse: [otherPin shareVariableOf: self]]
		ifFalse: 
			[otherPin hasVariable 
				ifTrue: [self shareVariableOf: otherPin]
				ifFalse: 
					[self addModelVariable.
					otherPin shareVariableOf: self]].
	component model changed: pinSpec modelReadSelector.
	^true
]

{ #category : #geometry }
PinMorph >> wiringEndPoint [
	| side |
	side := owner bounds sideNearestTo: bounds center.
	side = #left ifTrue: [^ self position + (0@4)].
	side = #bottom ifTrue: [^ self position + (4@7)].
	side = #right ifTrue: [^ self position + (7@4)].
	side = #top ifTrue: [^ self position + (4@0)]
]
