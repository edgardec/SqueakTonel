"
I am a BroomMorph that pushes morphs right.
"
Class {
	#name : #BroomMorphRight,
	#superclass : #BroomMorph,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
BroomMorphRight >> affectedMorphs [
	"Answer all the morphs that I should be moving"
	| movedRect |
	movedRect := self bounds encompass: lastHotspot x @ hotspot y.
	^ owner submorphs
		select: [:m | movedRect
				intersects: (Rectangle
						left: m bounds left
						right: m bounds left + 1
						top: m bounds top
						bottom: m bounds bottom)]
]

{ #category : #drawing }
BroomMorphRight >> drawOn: aCanvas [
	| halfWidth |
	halfWidth := width + 1 // 2.
	aCanvas line: bounds leftCenter + (halfWidth@0) to: bounds rightCenter + (halfWidth negated @0) width: width color: self color.
	aCanvas line: bounds topRight + (halfWidth negated @ halfWidth) to: bounds bottomRight + (halfWidth negated@halfWidth negated) width: width color: self color.
	aCanvas line: self hotspot + (width * -2 @ (span negated)) to: self hotspot + (-1 @ (span negated)) color: self color.
	aCanvas line: self hotspot + (width * -2 @ (span-1)) to: self hotspot + (-1 @ (span-1)) color: self color.

]

{ #category : #accessing }
BroomMorphRight >> hotspot: aPoint [ 
	| newBounds top bottom right |
	top := aPoint y - span min: bounds top.
	bottom := aPoint y + span max: bounds bottom.
	right := aPoint x max: start x.
	lastHotspot := hotspot.
	hotspot := right @ aPoint y.
	newBounds := Rectangle
				left: right - bounds width
				right: right
				top: top
				bottom: bottom.
	self bounds: newBounds
]

{ #category : #private }
BroomMorphRight >> positionMorph: m originalBounds: b [
	m left: (self right max: b left)
]

{ #category : #accessing }
BroomMorphRight >> resetExtent [
	| newBounds |
	newBounds := 0@0 extent: (12 + width) @ (2*span).
	self bounds: (newBounds align: newBounds rightCenter with: hotspot)
]
