"
I am a BroomMorph that pushes morphs up.
"
Class {
	#name : #BroomMorphUp,
	#superclass : #BroomMorphDown,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
BroomMorphUp >> affectedMorphs [
	"Answer all the morphs that I should be moving"
	| movedRect |
	movedRect := self bounds encompass: hotspot x @ lastHotspot y.
	^ owner submorphs
		select: [:m | movedRect
				intersects: (Rectangle
						left: m bounds left
						right: m bounds right
						top: m bounds bottom - 1
						bottom: m bounds bottom)]
]

{ #category : #drawing }
BroomMorphUp >> drawOn: aCanvas [
	| halfWidth |
	halfWidth := width + 1 // 2.
	aCanvas line: bounds topCenter + (0@halfWidth) to: bounds bottomCenter + (0@halfWidth negated) width: width color: self color.
	aCanvas line: bounds topLeft + (halfWidth @ halfWidth) to: bounds topRight + ((halfWidth) negated@halfWidth) width: width color: self color.
	aCanvas line: self hotspot + (span negated @ (width * 2)) to: self hotspot + (span negated @ 1) color: self color.
	aCanvas line: self hotspot + (span -1 @ (width * 2)) to: self hotspot + (span -1 @ 1) color: self color.

]

{ #category : #accessing }
BroomMorphUp >> hotspot: aPoint [ 
	| left right newBounds top |
	left := aPoint x - span min: bounds left.
	right := aPoint x + span max: bounds right.
	top := aPoint y min: start y.
	lastHotspot := hotspot.
	hotspot := aPoint x @ top.
	newBounds := Rectangle
				left: left
				right: right
				top: top
				bottom: top + bounds height.
	self bounds: newBounds
]

{ #category : #private }
BroomMorphUp >> positionMorph: m originalBounds: b [
	m bottom: (self top min: b bottom)
]

{ #category : #drawing }
BroomMorphUp >> resetExtent [
	| newBounds |
	newBounds := 0@0 extent: (2*span) @ (12 + width).
	self bounds: (newBounds align: newBounds topCenter with: hotspot)
]
