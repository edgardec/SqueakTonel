Class {
	#name : #TopGripMorph,
	#superclass : #BorderGripMorph,
	#category : #'Morphic-Windows'
}

{ #category : #'target resize' }
TopGripMorph >> apply: delta [ 
	| oldBounds |
	oldBounds := self target bounds.
	self target
		bounds: (oldBounds origin + (0 @ delta y) corner: oldBounds corner)
]

{ #category : #initialize }
TopGripMorph >> defaultHeight [

	^ self class gripThickness
]

{ #category : #accessing }
TopGripMorph >> gripLayoutFrame [
	^ LayoutFrame
		fractions: (0 @ 0 corner: 1 @ 0)
		offsets: (0 @ 0 corner: 0@ 0)
]

{ #category : #initialize }
TopGripMorph >> initialize [
	super initialize.
	self hResizing: #spaceFill.
]

{ #category : #layout }
TopGripMorph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [

	super layoutProportionallyInBounds: layoutBounds positioning: cellPositioning.
	
	self flag: #workaround. "mt: We cannot know that our owner has always the correct new bounds at this time."
	self top: owner top.
]

{ #category : #accessing }
TopGripMorph >> orientation [

	^ #horizontal
]

{ #category : #accessing }
TopGripMorph >> ptName [
	^#top
]

{ #category : #accessing }
TopGripMorph >> resizeCursor [

	^ Cursor resizeForEdge: #top
]
