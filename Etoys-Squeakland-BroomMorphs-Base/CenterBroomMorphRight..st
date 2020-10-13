Class {
	#name : #CenterBroomMorphRight,
	#superclass : #BroomMorphRight,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
CenterBroomMorphRight >> affectedMorphs [
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
CenterBroomMorphRight >> positionMorph: m originalBounds: b [
	m center: (self right max: b center x) @ m center y
]
