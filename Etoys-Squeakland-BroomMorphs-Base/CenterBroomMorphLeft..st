Class {
	#name : #CenterBroomMorphLeft,
	#superclass : #BroomMorphLeft,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
CenterBroomMorphLeft >> affectedMorphs [
	"Answer all the morphs that I should be moving"
	| movedRect |
	movedRect := self bounds encompass: lastHotspot x @ hotspot y.
	^ owner submorphs
		select: [:m | movedRect
				intersects: (Rectangle
						left: m bounds center x - 1
						right: m bounds center x + 1
						top: m bounds top
						bottom: m bounds bottom)]
]

{ #category : #private }
CenterBroomMorphLeft >> positionMorph: m originalBounds: b [
	m center: (self left min: b center x) @ m center y
]
