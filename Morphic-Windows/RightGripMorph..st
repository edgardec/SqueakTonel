Class {
	#name : #RightGripMorph,
	#superclass : #BorderGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
RightGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin corner: oldBounds corner + (delta x @ 0))
]

{ #category : #initialize }
RightGripMorph >> defaultWidth [

	^ self class gripThickness
]

{ #category : #accessing }
RightGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (1 @ 0 corner: 1 @ 1)
		offsets: (0 @ 0 corner: 0 @ 0)
]

{ #category : #initialize }
RightGripMorph >> initialize [
	super initialize.
	self vResizing: #spaceFill.
]

{ #category : #layout }
RightGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [

	super layoutProportionallyInBounds: layoutBounds positioning: cellPositioning.
	
	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self right: owner right.
	
	self top: owner top.
	self height: owner height.
]

{ #category : #accessing }
RightGripMorph >> orientation [

	^ #vertical
]

{ #category : #accessing }
RightGripMorph >> ptName [
	^#right
]

{ #category : #accessing }
RightGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #right
]
