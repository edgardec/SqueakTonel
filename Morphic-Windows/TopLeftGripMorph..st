"
I am the handle in the left top of windows used for resizing them.
"
Class {
	#name : #TopLeftGripMorph,
	#superclass : #CornerGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
TopLeftGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin + delta corner: oldBounds corner)
]

{ #category : #drawing }
TopLeftGripMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	
	self showHandle ifTrue: [
		aCanvas
			fillRoundRect: ((self topLeft + self handleInset asPoint extent: self class gripThickness @ self height) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).
		aCanvas
			fillRoundRect: ((self topLeft + self handleInset asPoint extent: self width @ self class gripThickness) insetBy: self handleInset)
			radius: 3
			fillStyle: (SolidFillStyle color: self handleColor).
		
		
		].
]

{ #category : #accessing }
TopLeftGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (0 @ 0 corner: 0 @ 0)
		offsets: (0 @ 0 corner: 0 @ 0)
]

{ #category : #layout }
TopLeftGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [
	
	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self topLeft: owner topLeft.
]

{ #category : #accessing }
TopLeftGripMorph >> ptName [
	^#topLeft
]

{ #category : #accessing }
TopLeftGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #topLeft
]
