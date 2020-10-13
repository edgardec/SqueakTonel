Class {
	#name : #BottomGripMorph,
	#superclass : #BorderGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
BottomGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin corner: oldBounds corner + (0 @ delta y))
]

{ #category : #initialize }
BottomGripMorph >> defaultHeight [

	^ self class gripThickness
]

{ #category : #accessing }
BottomGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (0 @ 1 corner: 1 @ 1)
		offsets: (0 @ 0 corner: 0 @ 0)
]

{ #category : #initialize }
BottomGripMorph >> initialize [
	super initialize.
	self hResizing: #spaceFill.
]

{ #category : #layout }
BottomGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [

	super layoutProportionallyInBounds: layoutBounds positioning: cellPositioning.
	
	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self bottom: owner bottom.
]

{ #category : #accessing }
BottomGripMorph >> orientation [

	^ #horizontal
]

{ #category : #accessing }
BottomGripMorph >> ptName [
	^#bottom
]

{ #category : #accessing }
BottomGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #top
]
