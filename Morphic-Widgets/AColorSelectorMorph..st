"
ColorComponentSelector showing an alpha gradient over a hatched background.
"
Class {
	#name : #AColorSelectorMorph,
	#superclass : #BracketSliderMorph,
	#category : #'Morphic-Widgets'
}

{ #category : #accessing }
AColorSelectorMorph >> color: aColor [
	"Set the gradient colors."
	
	super color: aColor asNontranslucentColor.
	self fillStyle: self defaultFillStyle
]

{ #category : #'accessing - ui' }
AColorSelectorMorph >> defaultFillStyle [
	"Answer the hue gradient."

	^(GradientFillStyle colors: {self color alpha: 0. self color})
		origin: self topLeft;
		direction: (self orientation == #horizontal
					ifTrue: [self width@0]
					ifFalse: [0@self height])
]

{ #category : #drawing }
AColorSelectorMorph >> drawOn: aCanvas [ 
	"Draw a hatch pattern first."
	aCanvas
		fillRectangle: self innerBounds
		fillStyle: (InfiniteForm with: ColorPresenterMorph hatchForm).
	super drawOn: aCanvas
]

{ #category : #'visual properties' }
AColorSelectorMorph >> fillStyle: fillStyle [
	"If it is a color then override with gradient."
	
	fillStyle isColor
		ifTrue: [self color: fillStyle]
		ifFalse: [super fillStyle: fillStyle]
]

{ #category : #initialization }
AColorSelectorMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		value: 1.0;
		color: Color black
]
