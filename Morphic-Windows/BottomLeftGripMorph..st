"
I am the handle in the left bottom of windows used for resizing them.
"
Class {
	#name : #BottomLeftGripMorph,
	#superclass : #CornerGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
BottomLeftGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin + (delta x @ 0) corner: oldBounds corner + (0 @ delta y))
]

{ #category : #drawing }
BottomLeftGripMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	
	self showHandle ifTrue: [
		aCanvas
			fillRoundRect: ((self topLeft + (self handleInset @ self handleInset negated) extent: self class gripThickness @ self height) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).
		aCanvas
			fillRoundRect: ((self bottomLeft + (self handleInset @ (self handleInset negated + self class gripThickness negated)) extent: self width @ self class gripThickness) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).]
]

{ #category : #accessing }
BottomLeftGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (0 @ 1 corner: 0 @ 1)
		offsets: (0 @ 0 corner: 0 @ 0)
]

{ #category : #layout }
BottomLeftGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [

	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self bottomLeft: owner bottomLeft.
]

{ #category : #accessing }
BottomLeftGripMorph >> ptName [
	^#bottomLeft
]

{ #category : #accessing }
BottomLeftGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #bottomLeft
]
