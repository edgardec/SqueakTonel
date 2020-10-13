"
A canvas which has a hidden form caching the events.  contentsOfArea:into: uses the cache, instead of the main canvas.  This is typically used with remote canvases, where querying the bits would involve a network transaction.

"
Class {
	#name : #CachingCanvas,
	#superclass : #PluggableCanvas,
	#instVars : [
		'cacheCanvas',
		'mainCanvas'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #'instance creation' }
CachingCanvas class >> on: aCanvas [
	^super new mainCanvas: aCanvas
]

{ #category : #'canvas methods' }
CachingCanvas >> allocateForm: extentPoint [

	^cacheCanvas form allocateForm: extentPoint
]

{ #category : #private }
CachingCanvas >> apply: aBlock [
	aBlock value: cacheCanvas.
	aBlock value: mainCanvas.
]

{ #category : #accessing }
CachingCanvas >> contentsOfArea: area  into: aForm [
	^cacheCanvas contentsOfArea: area  into: aForm
]

{ #category : #accessing }
CachingCanvas >> form [
	^cacheCanvas form
]

{ #category : #initialization }
CachingCanvas >> mainCanvas: mainCanvas0 [
	mainCanvas := mainCanvas0.
	cacheCanvas := FormCanvas extent: mainCanvas extent depth: mainCanvas depth.
]

{ #category : #'canvas methods' }
CachingCanvas >> showAt: pt  invalidRects: rects [

	mainCanvas showAt: pt  invalidRects: rects
]
