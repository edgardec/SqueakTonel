"
I simulate the effects of having a WarpBlit done in Postscript, by simply adjusting the coordinate system.

"
Class {
	#name : #PostscriptDummyWarp,
	#superclass : #Object,
	#instVars : [
		'canvas',
		'subCanvas',
		'transform'
	],
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #'instance creation' }
PostscriptDummyWarp class >> canvas:aCanvas [
	^self new canvas:aCanvas.
]

{ #category : #dummy }
PostscriptDummyWarp >> canvas [
	^canvas

]

{ #category : #dummy }
PostscriptDummyWarp >> canvas:newCanvas [
	canvas := newCanvas.

]

{ #category : #dummy }
PostscriptDummyWarp >> cellSize:newCellSize [
	^self.
]

{ #category : #dummy }
PostscriptDummyWarp >> colorMap:aMap [

]

{ #category : #dummy }
PostscriptDummyWarp >> combinationRule:newRule [
	^self.
]

{ #category : #dummy }
PostscriptDummyWarp >> drawPostscriptContext:aCanvas [
	canvas drawPostscriptContext:aCanvas.



]

{ #category : #dummy }
PostscriptDummyWarp >> preserveStateDuring: aBlock [

	^ canvas preserveStateDuring:
		"Note block arg must be self so various things get overridden properly"
		[:inner | aBlock value: self]


]

{ #category : #dummy }
PostscriptDummyWarp >> sourceForm:newForm [
	^self.
]

{ #category : #dummy }
PostscriptDummyWarp >> sourceQuad:aQuad destRect:aRect [

]

{ #category : #dummy }
PostscriptDummyWarp >> subCanvas:patchRect [
	subCanvas ifNil:
		[ subCanvas := PostscriptCanvas new reset setOrigin:patchRect topLeft clipRect: (-10000 @ -10000 extent: 20000 @ 20000)].
	^subCanvas.


]

{ #category : #dummy }
PostscriptDummyWarp >> transform [
	^transform.

]

{ #category : #dummy }
PostscriptDummyWarp >> transform:newTransform [
	transform := newTransform.
	^self.

]

{ #category : #dummy }
PostscriptDummyWarp >> transformBy:aTransform [
	canvas transformBy:aTransform.



]

{ #category : #dummy }
PostscriptDummyWarp >> warpBits [
	canvas preserveStateDuring:
		[:inner | 
		transform ifNotNil: [inner transformBy: transform].
		inner drawPostscriptContext:subCanvas].

]
