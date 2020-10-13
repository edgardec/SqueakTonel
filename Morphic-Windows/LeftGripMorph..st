Class {
	#name : #LeftGripMorph,
	#superclass : #BorderGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
LeftGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin + (delta x @ 0) corner: oldBounds corner)
]

{ #category : #initialize }
LeftGripMorph >> defaultWidth [

	^ self class gripThickness
]

{ #category : #accessing }
LeftGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (0 @ 0 corner: 0 @ 1)
		offsets: (0 @ 0 corner: 0 @ 0)
]

{ #category : #initialize }
LeftGripMorph >> initialize [
	super initialize.
	self vResizing: #spaceFill.
]

{ #category : #layout }
LeftGripMorph >> layoutProportionallyInBounds: cellBounds positioning: cellPositioning [

	super layoutProportionallyInBounds: cellBounds positioning: cellPositioning.
	
	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self left: owner left.
	
	self top: owner top.
	self height: owner height.
]

{ #category : #accessing }
LeftGripMorph >> orientation [

	^ #vertical
]

{ #category : #accessing }
LeftGripMorph >> ptName [
	^#left
]

{ #category : #accessing }
LeftGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #left
]
