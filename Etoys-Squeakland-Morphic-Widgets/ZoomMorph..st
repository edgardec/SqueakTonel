Class {
	#name : #ZoomMorph,
	#superclass : #TransformMorph,
	#instVars : [
		'fromMorph',
		'toMorph',
		'boundsSeq',
		'finalAction'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'new-morph participation' }
ZoomMorph class >> includeInNewMorphMenu [
	"Zooms aren't meaningful without initializations"
	^ false
]

{ #category : #initialization }
ZoomMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color transparent
]

{ #category : #'stepping and presenter' }
ZoomMorph >> step [

	boundsSeq isEmpty ifTrue:
		["If all done, then grant one final request and vanish"
		finalAction value.
		^ self delete].

	"Otherwise, zoom to the next rectangle"
	self zoomTo: boundsSeq removeFirst
]

{ #category : #testing }
ZoomMorph >> stepTime [

	^ 40
]

{ #category : #'as yet unclassified' }
ZoomMorph >> zoomFromMorph: m1 toMorph: m2 andThen: actionBlock [
	| nSteps topLeft r2 r1 extent ratio r mouthDeltas |
	fromMorph := m1.
	toMorph := m2.
	r1 := fromMorph fullBounds.
	r2 := toMorph fullBounds.
	finalAction := actionBlock.
	nSteps := 8.
	boundsSeq := OrderedCollection new.
	r := (1/nSteps) asFloat.
	ratio := r.
r1 := 105@326 corner: 130@348.
mouthDeltas := {-7@24. -6@21. -6@18. -4@14. -4@10. -3@8. -3@3. 0@0}.
	1 to: nSteps do:
		[:i | topLeft := ((r2 topLeft - r1 topLeft) * ratio) asIntegerPoint + r1 topLeft.
		extent := ((r2 extent - r1 extent) * ratio) asIntegerPoint + r1 extent.
		boundsSeq addLast: (topLeft + (mouthDeltas at: i) extent: extent).
		ratio := ratio + r].
	self addMorph: toMorph.
	self step
]

{ #category : #'as yet unclassified' }
ZoomMorph >> zoomTo: newBounds [
	| scale |
	self bounds: newBounds.
	scale := newBounds extent / toMorph fullBounds extent.
	self setOffset: toMorph position - self position angle: 0.0 scale: scale
]
