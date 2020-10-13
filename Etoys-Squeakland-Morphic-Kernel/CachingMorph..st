"
This morph can be used to cache the picture of a morph that takes a long time to draw. It should be used with judgement, however, since heavy use of caching can consume large amounts of memory.
"
Class {
	#name : #CachingMorph,
	#superclass : #Morph,
	#instVars : [
		'damageRecorder',
		'cacheCanvas'
	],
	#category : #'Etoys-Squeakland-Morphic-Kernel'
}

{ #category : #initialization }
CachingMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color veryLightGray
]

{ #category : #drawing }
CachingMorph >> drawOn: aCanvas [

	submorphs isEmpty ifTrue: [^ super drawOn: aCanvas].

]

{ #category : #drawing }
CachingMorph >> fullDrawOn: aCanvas [
	(aCanvas isVisible: self fullBounds) ifFalse:[^self].
	self updateCacheCanvas: aCanvas.
	aCanvas cache: self fullBounds
			using: cacheCanvas form
			during:[:cachingCanvas| super fullDrawOn: cachingCanvas].

]

{ #category : #drawing }
CachingMorph >> imageForm [

	self updateCacheCanvas: Display getCanvas.
	^ cacheCanvas form offset: self fullBounds topLeft

]

{ #category : #initialization }
CachingMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	damageRecorder := DamageRecorder new
]

{ #category : #'change reporting' }
CachingMorph >> invalidRect: damageRect from: aMorph [
	"Record the given rectangle in the damage list."
	damageRecorder recordInvalidRect: (damageRect translateBy: self fullBounds origin negated).
	super invalidRect: damageRect from: aMorph
]

{ #category : #caching }
CachingMorph >> releaseCachedState [

	super releaseCachedState.
	cacheCanvas := nil.

]

{ #category : #'as yet unclassified' }
CachingMorph >> updateCacheCanvas: aCanvas [ 
	"Update the cached image of the morphs being held by this hand."

	| myBnds rectList |
	myBnds := self fullBounds.
	(cacheCanvas isNil or: [cacheCanvas extent ~= myBnds extent]) 
		ifTrue: 
			[cacheCanvas := (aCanvas allocateForm: myBnds extent) getCanvas.
			cacheCanvas translateBy: myBnds origin negated
				during: [:tempCanvas | super fullDrawOn: tempCanvas].
			^self].

	"incrementally update the cache canvas"
	rectList := damageRecorder 
				invalidRectsFullBounds: (0 @ 0 extent: myBnds extent).
	damageRecorder reset.
	rectList do: 
			[:r | 
			cacheCanvas 
				translateTo: myBnds origin negated
				clippingTo: r
				during: 
					[:c | 
					c fillColor: Color transparent.	"clear to transparent"
					super fullDrawOn: c]]
]
