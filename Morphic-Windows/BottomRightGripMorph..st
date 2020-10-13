"
I am the handle in the right bottom of windows used for resizing them.
"
Class {
	#name : #BottomRightGripMorph,
	#superclass : #CornerGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
BottomRightGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin corner: oldBounds corner + delta)
]

{ #category : #drawing }
BottomRightGripMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	
	self showHandle ifTrue: [
		aCanvas
			fillRoundRect: ((self topRight + ((self handleInset negated + self class gripThickness negated) @ self handleInset negated) extent: self class gripThickness @ self height) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).
		aCanvas
			fillRoundRect: ((self bottomLeft + (self handleInset negated @ (self handleInset negated + self class gripThickness negated)) extent: self width @ self class gripThickness) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).]
]

{ #category : #accessing }
BottomRightGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (1 @ 1 corner: 1 @ 1)
		offsets: (0 @ 0 corner: 0 @ 0)
]

{ #category : #layout }
BottomRightGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [

	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self bottomRight: owner bottomRight.
]

{ #category : #accessing }
BottomRightGripMorph >> ptName [
	^#bottomRight
]

{ #category : #accessing }
BottomRightGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #bottomRight
]
