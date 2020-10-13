"
I am the handle in the right top of windows used for resizing them.
"
Class {
	#name : #TopRightGripMorph,
	#superclass : #CornerGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
TopRightGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin + (0@delta y) corner: oldBounds corner + (delta x @ 0))
]

{ #category : #drawing }
TopRightGripMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	
	self showHandle ifTrue: [
		aCanvas
			fillRoundRect: ((self topRight + ((self handleInset negated + self class gripThickness negated) @ self handleInset) extent: self class gripThickness @ self height) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).
		aCanvas
			fillRoundRect: ((self topLeft + (self handleInset negated @ self handleInset) extent: self width @ self class gripThickness) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).]
]

{ #category : #accessing }
TopRightGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (1 @ 0 corner: 1 @ 0)
		offsets: (0 @ 0 corner: 0 @ 0)
]

{ #category : #layout }
TopRightGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [

	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self topRight: owner topRight.
]

{ #category : #accessing }
TopRightGripMorph >> ptName [
	^#topRight
]

{ #category : #accessing }
TopRightGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #topRight
]
