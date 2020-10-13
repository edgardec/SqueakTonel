Class {
	#name : #CenterBroomMorphDown,
	#superclass : #BroomMorphDown,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
CenterBroomMorphDown >> affectedMorphs [
	"Answer all the morphs that I should be moving"
	| movedRect |
	movedRect := self bounds encompass: hotspot x @ lastHotspot y.
	^ owner submorphs
		select: [:m | movedRect
				intersects: (Rectangle
						left: m bounds left
						right: m bounds right
						top: m bounds center y - 1
						bottom: m bounds center y + 1)]
]

{ #category : #private }
CenterBroomMorphDown >> positionMorph: m originalBounds: b [
	m center: m center x @ (self bottom max: b center y)
]
