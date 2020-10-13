Class {
	#name : #NullTerminalMorph,
	#superclass : #NetworkTerminalMorph,
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #drawing }
NullTerminalMorph >> drawOn: aCanvas [

	aCanvas fillRectangle: self bounds fillStyle: Color orange.
	aCanvas frameRectangle: self bounds color: Color black
]

{ #category : #geometry }
NullTerminalMorph >> extent: newExtent [

	| aPoint |
	aPoint := 50@50.
	bounds extent = aPoint ifFalse: [
		self changed.
		bounds := bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed
	].
	eventEncoder sendViewExtent: newExtent
]

{ #category : #drawing }
NullTerminalMorph >> forceToFront: aRegion [
	"force the given region from the drawing form onto the background form"
	self updateBackgroundForm.


]
