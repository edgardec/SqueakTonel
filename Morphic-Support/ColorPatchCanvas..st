"
I generate patches of Morphic worlds that views below certain Morphs. This facility is used for the end-user scripting system.
"
Class {
	#name : #ColorPatchCanvas,
	#superclass : #FormCanvas,
	#instVars : [
		'stopMorph',
		'foundMorph',
		'doStop'
	],
	#category : #'Morphic-Support'
}

{ #category : #'drawing-support' }
ColorPatchCanvas >> clipBy: aRectangle during: aBlock [
	"Set a clipping rectangle active only during the execution of aBlock.
	Note: In the future we may want to have more general clip shapes - not just rectangles"
	| tempCanvas |
	tempCanvas := (self copyClipRect: aRectangle).
	aBlock value: tempCanvas.
	foundMorph := tempCanvas foundMorph.
]

{ #category : #accessing }
ColorPatchCanvas >> doStop [
	^doStop
]

{ #category : #accessing }
ColorPatchCanvas >> doStop: aBoolean [
	doStop := aBoolean
]

{ #category : #accessing }
ColorPatchCanvas >> foundMorph [
	^foundMorph
]

{ #category : #accessing }
ColorPatchCanvas >> foundMorph: aBoolean [
	foundMorph := aBoolean
]

{ #category : #'drawing-general' }
ColorPatchCanvas >> fullDrawMorph: aMorph [
	(foundMorph and:[doStop]) ifTrue:[^self]. "Found it and should stop"
	aMorph == stopMorph ifTrue:[
		"Never draw the stopMorph"
		foundMorph := true.
		^self].
	^super fullDrawMorph: aMorph.
]

{ #category : #'drawing-support' }
ColorPatchCanvas >> preserveStateDuring: aBlock [
	"Preserve the full canvas state during the execution of aBlock.
	Note: This does *not* include the state in the receiver (e.g., foundMorph)."
	| tempCanvas result |
	tempCanvas := self copy.
	result := aBlock value: tempCanvas.
	foundMorph := tempCanvas foundMorph.
	^result
]

{ #category : #initialization }
ColorPatchCanvas >> reset [
	"Initialize the receiver to act just as a FormCanvas"
	super reset.
	foundMorph := false.
	doStop := false.
	stopMorph := nil.
]

{ #category : #private }
ColorPatchCanvas >> setForm: aForm [
	"Initialize the receiver to act just as a FormCanvas"
	super setForm: aForm.
	stopMorph := nil.
	doStop := false.
	foundMorph := false.
]

{ #category : #accessing }
ColorPatchCanvas >> stopMorph [
	^stopMorph
]

{ #category : #accessing }
ColorPatchCanvas >> stopMorph: aMorph [
	stopMorph := aMorph
]

{ #category : #'drawing-support' }
ColorPatchCanvas >> transformBy: aDisplayTransform clippingTo: aClipRect during: aBlock smoothing: cellSize [
	"Note: This method has been originally copied from TransformationMorph."
	| innerRect patchRect sourceQuad warp start subCanvas |
	(aDisplayTransform isPureTranslation) ifTrue:[
		subCanvas := self copyOffset: aDisplayTransform offset negated truncated
							clipRect: aClipRect.
		aBlock value: subCanvas.
		foundMorph := subCanvas foundMorph.
		^self
	].
	"Prepare an appropriate warp from patch to innerRect"
	innerRect := aClipRect.
	patchRect := aDisplayTransform globalBoundsToLocal:
					(self clipRect intersect: innerRect).
	sourceQuad := (aDisplayTransform sourceQuadFor: innerRect)
					collect: [:p | p - patchRect topLeft].
	warp := self warpFrom: sourceQuad toRect: innerRect.
	warp cellSize: cellSize.

	"Render the submorphs visible in the clipping rectangle, as patchForm"
	start := (self depth = 1 and: [self isShadowDrawing not])
		"If this is true B&W, then we need a first pass for erasure."
		ifTrue: [1] ifFalse: [2].
	start to: 2 do:
		[:i | "If i=1 we first make a shadow and erase it for opaque whites in B&W"
		subCanvas := ColorPatchCanvas extent: patchRect extent depth: self depth.
		subCanvas stopMorph: stopMorph.
		subCanvas foundMorph: foundMorph.
		subCanvas doStop: doStop.
		i=1	ifTrue: [subCanvas shadowColor: Color black.
					warp combinationRule: Form erase]
			ifFalse: [self isShadowDrawing ifTrue:
					[subCanvas shadowColor: self shadowColor].
					warp combinationRule: Form paint].
		subCanvas
			translateBy: patchRect topLeft negated
			during: aBlock.
		i = 2 ifTrue:[foundMorph := subCanvas foundMorph].
		warp sourceForm: subCanvas form; warpBits.
		warp sourceForm: nil.  subCanvas := nil "release space for next loop"]

]

{ #category : #other }
ColorPatchCanvas >> translateBy: delta clippingTo: aRectangle during: aBlock [
	"Set a translation and clipping rectangle only during the execution of aBlock."
	| tempCanvas |
	tempCanvas := self copyOffset: delta clipRect: aRectangle.
	aBlock value: tempCanvas.
	foundMorph := tempCanvas foundMorph.
]

{ #category : #'drawing-support' }
ColorPatchCanvas >> translateBy: delta during: aBlock [
	"Set a translation only during the execution of aBlock."
	| tempCanvas |
	tempCanvas := self copyOffset: delta.
	aBlock value: tempCanvas.
	foundMorph := tempCanvas foundMorph.
]

{ #category : #'drawing-support' }
ColorPatchCanvas >> translateTo: newOrigin clippingTo: aRectangle during: aBlock [
	"Set a new origin and clipping rectangle only during the execution of aBlock."
	| tempCanvas |
	tempCanvas := self copyOrigin: newOrigin clipRect: aRectangle.
	aBlock value: tempCanvas.
	foundMorph := tempCanvas foundMorph.
]
