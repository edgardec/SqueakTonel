"
Abstract superclass for morphs that are used to select a component (R, G, B or A) of a colour.
"
Class {
	#name : #BracketSliderMorph,
	#superclass : #Slider,
	#instVars : [
		'getEnabledSelector',
		'enabled'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'accessing - ui' }
BracketSliderMorph >> adoptPaneColor: paneColor [ 
	"Pass on to the border too."
	super adoptPaneColor: paneColor.
	paneColor ifNil: [ ^ self ].
	self
		 fillStyle: self fillStyleToUse ;
		 borderStyle:
			(BorderStyle inset
				 width: 1 ;
				 baseColor: self color twiceDarker) ;
		 sliderColor:
			(self enabled
				ifTrue: [ paneColor twiceDarker ]
				ifFalse: [ self paneColor twiceDarker paler ])
]

{ #category : #'accessing - ui' }
BracketSliderMorph >> defaultColor [
	"Answer the default color/fill style for the receiver."
	
	^Color white
]

{ #category : #'accessing - ui' }
BracketSliderMorph >> defaultFillStyle [
	"Answer the defauolt fill style."

	^Color gray
]

{ #category : #accessing }
BracketSliderMorph >> disable [
	"Disable the receiver."
	
	self enabled: false
]

{ #category : #accessing }
BracketSliderMorph >> enable [
	"Enable the receiver."
	
	self enabled: true
]

{ #category : #accessing }
BracketSliderMorph >> enabled [
	"Answer the value of enabled"

	^ enabled
]

{ #category : #accessing }
BracketSliderMorph >> enabled: anObject [
	"Set the value of enabled"

	enabled = anObject ifTrue: [^self].
	enabled := anObject.
	self changed: #enabled.
	self
		adoptPaneColor: self color;
		changed
]

{ #category : #geometry }
BracketSliderMorph >> extent: aPoint [
	"Update the gradient directions."

	super extent: aPoint.
	self updateFillStyle
]

{ #category : #'accessing - ui' }
BracketSliderMorph >> fillStyleToUse [
	"Answer the fillStyle that should be used for the receiver."
	
	^self fillStyle
]

{ #category : #accessing }
BracketSliderMorph >> getEnabledSelector [
	"Answer the value of getEnabledSelector"

	^ getEnabledSelector
]

{ #category : #accessing }
BracketSliderMorph >> getEnabledSelector: aSymbol [
	"Set the value of getEnabledSelector"

	getEnabledSelector := aSymbol.
	self updateEnabled
]

{ #category : #'accessing - ui' }
BracketSliderMorph >> gradient [
	"Answer the gradient."

	self subclassResponsibility
]

{ #category : #'event handling' }
BracketSliderMorph >> handlesMouseDown: evt [
	"Answer true." 

	^true
]

{ #category : #initialization }
BracketSliderMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		enabled: true;
		fillStyle: self defaultFillStyle;
		borderStyle: (BorderStyle inset baseColor: self color; width: 1);
		sliderColor: Color black;
		clipSubmorphs: true
]

{ #category : #initialization }
BracketSliderMorph >> initializeSlider [
	"Make the slider raised."
	
	slider :=( BracketMorph newBounds: self totalSliderArea)
		horizontal: self orientation == #horizontal;
		color: self thumbColor;
		borderStyle: (BorderStyle raised baseColor: Color white; width: 1).
	sliderShadow := (BracketMorph newBounds: self totalSliderArea)
		horizontal: self orientation == #horizontal;
		color: self pagingArea color;
		borderStyle: (BorderStyle inset baseColor: (Color white alpha: 0.6); width: 1).
	slider on: #mouseMove send: #scrollAbsolute: to: self.
	slider on: #mouseDown send: #mouseDownInSlider: to: self.
	slider on: #mouseUp send: #mouseUpInSlider: to: self.
	"(the shadow must have the pagingArea as its owner to highlight properly)"
	self pagingArea addMorph: sliderShadow.
	sliderShadow hide.
	self addMorph: slider.
	self computeSlider.

]

{ #category : #layout }
BracketSliderMorph >> minHeight [
	"Answer the receiver's minimum height.
	Give it a bit of a chance..."
	
	^8 max: super minHeight
]

{ #category : #'event handling' }
BracketSliderMorph >> mouseDown: anEvent [
	"Set the value directly."
	
	self enabled ifTrue: [
		self
			scrollPoint: anEvent;
			computeSlider].
	super mouseDown: anEvent.
	self enabled ifFalse: [^self].
	anEvent hand newMouseFocus: slider event: anEvent.
	slider
		mouseEnter: anEvent copy;
		mouseDown: anEvent copy

]

{ #category : #'other events' }
BracketSliderMorph >> mouseDownInSlider: event [
	"Ignore if disabled."
	
	self enabled ifFalse: [^self].
	^super mouseDownInSlider: event
]

{ #category : #geometry }
BracketSliderMorph >> roomToMove [
	"Allow to run off the edges a bit."
	
	^self orientation == #horizontal
		ifTrue: [self totalSliderArea insetBy: ((self sliderThickness // 2@0) negated corner: (self sliderThickness // 2 + 1)@0)]
		ifFalse: [self totalSliderArea insetBy: (0@(self sliderThickness // 2) negated corner: 0@(self sliderThickness // 2 - (self sliderThickness \\ 2) + 1))]
]

{ #category : #scrolling }
BracketSliderMorph >> scrollAbsolute: event [
	"Ignore if disabled."
	
	self enabled ifFalse: [^self].
	^super scrollAbsolute: event
]

{ #category : #'event handling' }
BracketSliderMorph >> scrollPoint: event [
	"Scroll to the event position."
	
	| r p |
	r := self roomToMove.
	self orientation == #horizontal
		ifTrue: [r width = 0 ifTrue: [^ self]]
		ifFalse: [r height = 0 ifTrue: [^ self]].
	p := event position - (self sliderThickness // 2) adhereTo: r.
	self descending
		ifFalse:
			[self setValue: (self orientation == #horizontal 
				ifTrue: [(p x - r left) asFloat / r width]
				ifFalse: [(p y - r top) asFloat / r height])]
		ifTrue:
			[self setValue: (self orientation == #horizontal
				ifTrue: [(r right - p x) asFloat / r width]
				ifFalse:	[(r bottom - p y) asFloat / r height])]
]

{ #category : #'accessing - ui' }
BracketSliderMorph >> sliderColor: newColor [
	"Set the slider colour."
	
	super sliderColor: (self enabled ifTrue: [Color black] ifFalse: [self sliderShadowColor]).
	slider ifNotNil: [slider borderStyle baseColor: Color white]
]

{ #category : #'accessing - ui' }
BracketSliderMorph >> sliderShadowColor [
	"Answer the color for the slider shadow."
	
	^Color black alpha: 0.6
]

{ #category : #geometry }
BracketSliderMorph >> sliderThickness [
	"Answer the thickness of the slider."
	
	^((self orientation == #horizontal
		ifTrue: [self height]
		ifFalse: [self width]) // 2 max: 8) // 2 * 2 + 1
]

{ #category : #updating }
BracketSliderMorph >> update: aSymbol [
	"Update the value."
	
	super update: aSymbol.
	aSymbol == self getEnabledSelector ifTrue: [
		^self updateEnabled].
]

{ #category : #testing }
BracketSliderMorph >> updateEnabled [
	"Update the enablement state."

	self model ifNotNil: [
		self getEnabledSelector ifNotNil: [
			self enabled: (self model perform: self getEnabledSelector)]]
]

{ #category : #initialization }
BracketSliderMorph >> updateFillStyle [
	"Update the fill style directions."

	|b fs|
	fs := self fillStyle.
	fs isOrientedFill ifTrue: [
		b := self innerBounds.
		fs origin: b topLeft.
		fs direction: (self orientation == #horizontal
			ifTrue: [b width@0]
			ifFalse: [0@b height])]
]

{ #category : #initialization }
BracketSliderMorph >> updateSlider [

	super updateSlider.
	
	slider horizontal: self orientation == #horizontal.
	sliderShadow horizontal: self orientation == #horizontal.
]
