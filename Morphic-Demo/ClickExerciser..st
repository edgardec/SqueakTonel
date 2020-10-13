Class {
	#name : #ClickExerciser,
	#superclass : #RectangleMorph,
	#instVars : [
		'buttons'
	],
	#category : #'Morphic-Demo'
}

{ #category : #'parts bin' }
ClickExerciser class >> descriptionForPartsBin [
	"ClickExerciser descriptionForPartsBin"
	^ self partName:	'Exercise Click'
		categories:		#('Demo')
		documentation:	'An exerciser for click, double-click, and drag-click in morphic'
]

{ #category : #accessing }
ClickExerciser >> allSelectors [
^ #( #click: #doubleClick: #doubleClickTimeout: #startDrag:) 
]

{ #category : #accessing }
ClickExerciser >> alternateBorderColor [
"answer the alternate color/fill style for the receiver"
	^ Color yellow
]

{ #category : #accessing }
ClickExerciser >> alternateColor [
"answer the alternate color/fill style for the receiver"
	^ Color cyan
]

{ #category : #initialization }
ClickExerciser >> alternateSide [
"initial extent is square. We return an alternate height/width for drag to manipulate."
^ (self defaultSide asFloat * 1.618) rounded .

]

{ #category : #accessing }
ClickExerciser >> balloonText [
	^ 'Double-click on me to change my color; 
single-click on me to change border color;
hold mouse down within me and then move it to grow 
 or shrink. When I time out my border changes width.
Choose which of the above will work
by selecting the boxes in the middle.
See the boxes balloons.' translated
]

{ #category : #'event handling' }
ClickExerciser >> click: evt [
	self showBalloon: 'click' hand: evt hand.
	self borderColor: (self borderColor = self defaultBorderColor ifTrue: [self alternateBorderColor] ifFalse: [self defaultBorderColor])

]

{ #category : #accessing }
ClickExerciser >> defaultBorderColor [
"answer the alternate color/fill style for the receiver"
	^ Color black
]

{ #category : #accessing }
ClickExerciser >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color red
]

{ #category : #initialization }
ClickExerciser >> defaultSide [
"initial extent is square. We return the default height/width."
^ 100 .

]

{ #category : #'event handling' }
ClickExerciser >> doubleClick: evt [
	self showBalloon: 'doubleClick' hand: evt hand.
	self color: ((color = self alternateColor ) ifTrue: [self defaultColor] ifFalse: [self alternateColor])

]

{ #category : #'event handling' }
ClickExerciser >> doubleClickTimeout: evt [ 
	self showBalloon: 'ClickTimeout' hand: evt hand.
	self borderWidth: self borderWidth \\ 11 + 2
]

{ #category : #'event handling' }
ClickExerciser >> handlesMouseDown: evt [
	^ true
]

{ #category : #initialization }
ClickExerciser >> initButtons [
	| aButton positions |
	aButton := ThreePhaseButtonMorph checkBox. 
	positions := ((0@0) rect: aButton extent negated) corners + self center .
	buttons := positions collect: [ :p | ThreePhaseButtonMorph checkBox position: p; state: #on ] .
	buttons with: self allSelectors do: [ :b :s | b balloonText:  s asString ] .
	self removeAllMorphs .
	self addAllMorphs:  buttons .

]

{ #category : #initialization }
ClickExerciser >> initialize [
super initialize.
self extent: self defaultSide asPoint.
self initButtons .
]

{ #category : #'event handling' }
ClickExerciser >> mouseDown: evt [ 
	"Do nothing upon mouse-down except inform the hand to watch for a  
	double-click; wait until an ensuing click:, doubleClick:, or drag:  
	message gets dispatched"
	Preferences disable: #NewClickTest .
	evt hand
		waitForClicksOrDrag: self
		event: evt
		selectors: self selectors
		threshold: HandMorph dragThreshold
]

{ #category : #accessing }
ClickExerciser >> selectors [
^  self allSelectors with: buttons collect: [ :s :b | b isOn ifTrue: [ s ] ifFalse: [nil ] ] .
]

{ #category : #'event handling' }
ClickExerciser >> startDrag: evt [
	"We'll get a mouseDown first, some mouseMoves, and a mouseUp event last"
	| height width both  |
	"evt isMouseDown ifTrue:
		[self showBalloon: 'drag (mouse down)' hand: evt hand.
		self world displayWorld.
		(Delay forMilliseconds: 750) wait].
	evt isMouseUp ifTrue:
		[self showBalloon: 'drag (mouse up)' hand: evt hand].
	(evt isMouseUp or: [evt isMouseDown]) ifFalse:
		[self showBalloon: 'drag (mouse still down)' hand: evt hand].
	(self containsPoint: evt cursorPoint)
		ifFalse: [^ self]."
	self showBalloon: 'drag (mouse down)' hand: evt hand.

	width  := (self defaultSide max: self extent x) min: self alternateSide.
	height := (self defaultSide max: self extent y) min: self alternateSide.
	both  := self defaultSide + self alternateSide. 

self extent:	
 (((color = (self defaultColor)
		ifTrue:
			[ (both - height) @ width  ]
		ifFalse:
			[ height @ (both - width) ]) 
	max: self defaultSide asPoint) 
	min: self alternateSide asPoint )
	
	
]
