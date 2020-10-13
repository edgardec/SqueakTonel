"
I am a BroomMorph that pushes morphs down.
"
Class {
	#name : #BroomMorphDown,
	#superclass : #BroomMorph,
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #private }
BroomMorphDown >> affectedMorphs [
	"Answer all the morphs that I should be moving"
	| movedRect |
	movedRect := self bounds encompass: hotspot x @ lastHotspot y.
	^ owner submorphs
		select: [:m | movedRect
				intersects: (Rectangle
						left: m bounds left
						right: m bounds right
						top: m bounds top
						bottom: m bounds top + 1)]
]

{ #category : #drawing }
BroomMorphDown >> drawOn: aCanvas [
	| halfWidth |
	halfWidth := width + 1 // 2.
	aCanvas line: bounds topCenter + (0@halfWidth) to: bounds bottomCenter + (0@halfWidth negated) width: width color: self color.
	aCanvas line: bounds bottomLeft + (halfWidth @ halfWidth negated) to: bounds bottomRight + (halfWidth negated@halfWidth negated) width: width color: self color.
	aCanvas line: self hotspot + (span negated @ (width * -2)) to: self hotspot + (span negated @ -1) color: self color.
	aCanvas line: self hotspot + (span -1 @ (width * -2)) to: self hotspot + (span-1 @ -1) color: self color.

]

{ #category : #accessing }
BroomMorphDown >> hotspot: aPoint [ 
	| left right bottom newBounds |
	left := aPoint x - span min: bounds left.
	right := aPoint x + span max: bounds right.
	bottom := aPoint y max: start y.
	lastHotspot := hotspot.
	hotspot := aPoint x @ bottom.
	newBounds := Rectangle
				left: left
				right: right
				top: bottom - bounds height
				bottom: bottom.
	self bounds: newBounds.

]

{ #category : #private }
BroomMorphDown >> positionMorph: m originalBounds: b [
	m top: (self bottom max: b top)
]

{ #category : #drawing }
BroomMorphDown >> resetExtent [
	| newBounds |
	newBounds := 0@0 extent: (2*span) @ (12 + width).
	self bounds: (newBounds align: newBounds bottomCenter with: hotspot)
]
