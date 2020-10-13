Class {
	#name : #GradientDisplayMorph,
	#superclass : #RectangleMorph,
	#category : #'Morphic-Widgets'
}

{ #category : #accessing }
GradientDisplayMorph >> colorRamp [
	^self fillStyle colorRamp
]

{ #category : #accessing }
GradientDisplayMorph >> colorRamp: aColorRamp [
	self fillStyle colorRamp: aColorRamp
]

{ #category : #drawing }
GradientDisplayMorph >> drawOn: aCanvas [ 
	"Draw a hatch pattern first."
	aCanvas
		fillRectangle: self innerBounds
		fillStyle: (InfiniteForm with: ColorPresenterMorph hatchForm).
	super drawOn: aCanvas
]

{ #category : #initialization }
GradientDisplayMorph >> initialize [
	| fill colorRamp |
	super initialize.
	"self hResizing: #spaceFill. "
	colorRamp := {0.0 -> Color green. 0.3 -> Color red. 0.7 -> Color black. 1.0 -> Color blue}.
	fill := GradientFillStyle ramp: colorRamp.
	fill origin: 0@0.
	fill direction: self bounds extent x @ 0.
	fill radial: false.
	self fillStyle: fill
]
