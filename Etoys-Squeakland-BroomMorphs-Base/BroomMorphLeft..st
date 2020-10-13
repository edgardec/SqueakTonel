"
I am a BroomMorph that pushes morphs left.
"
Class {
	#name : #BroomMorphLeft,
	#superclass : #BroomMorphRight,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
BroomMorphLeft >> affectedMorphs [
	"Answer all the morphs that I should be moving"
	| movedRect |
	movedRect := self bounds encompass: lastHotspot x @ hotspot y.
	^ owner submorphs
		select: [:m | movedRect
				intersects: (Rectangle
						left: m bounds right - 1
						right: m bounds right
						top: m bounds top
						bottom: m bounds bottom)]
]

{ #category : #drawing }
BroomMorphLeft >> drawOn: aCanvas [
	| halfWidth |
	halfWidth := (width + 1 // 2).
	aCanvas line: bounds leftCenter + (halfWidth@0) to: bounds rightCenter + (halfWidth negated @0) width: width color: self color.
	aCanvas line: bounds topLeft + (halfWidth @ halfWidth) to: bounds bottomLeft + (halfWidth @halfWidth  negated) width: width color: self color.
	aCanvas line: self hotspot + (width * 2 @ (span negated)) to: self hotspot + (1 @ (span negated)) color: self color.
	aCanvas line: self hotspot + (width * 2 @ (span-1)) to: self hotspot + (1 @ (span-1)) color: self color.

]

{ #category : #accessing }
BroomMorphLeft >> hotspot: aPoint [ 
	| newBounds top bottom left |
	top := aPoint y - span min: bounds top.
	bottom := aPoint y + span max: bounds bottom.
	left := aPoint x min: start x.
	lastHotspot := hotspot.
	hotspot := left @ aPoint y.
	newBounds := Rectangle
				left: left
				right: left  + bounds width
				top: top
				bottom: bottom.
	self bounds: newBounds
]

{ #category : #private }
BroomMorphLeft >> positionMorph: m originalBounds: b [
	m right: (self left min: b right)
]

{ #category : #drawing }
BroomMorphLeft >> resetExtent [
	| newBounds |
	newBounds := 0@0 extent: (12 + width) @ (2*span).
	self bounds: (newBounds align: newBounds leftCenter with: hotspot)
]
