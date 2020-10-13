Class {
	#name : #CenterBroomMorphUp,
	#superclass : #BroomMorphUp,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
CenterBroomMorphUp >> affectedMorphs [
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
CenterBroomMorphUp >> positionMorph: m originalBounds: b [
	m center: m center x @ (self top min: b center y)
]
