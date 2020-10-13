Class {
	#name : #BufferedCanvas,
	#superclass : #PluggableCanvas,
	#instVars : [
		'remote',
		'previousVersion',
		'lastTick',
		'dirtyRect',
		'mirrorOfScreen'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'as yet unclassified' }
BufferedCanvas >> asBufferedCanvas [

	^self
]

{ #category : #'as yet unclassified' }
BufferedCanvas >> checkIfTimeToDisplay [

	remote backlog > 0 ifTrue: [^self].	"why bother if network full?"
	dirtyRect ifNil: [^self].
	self sendDeltas.
	lastTick := Time millisecondClockValue.


]

{ #category : #'drawing-support' }
BufferedCanvas >> clipBy: aRectangle during: aBlock [

]

{ #category : #accessing }
BufferedCanvas >> clipRect [
	
	^0@0 extent: 99999@99999

]

{ #category : #'as yet unclassified' }
BufferedCanvas >> connection: connection clipRect: newClipRect transform: transform remoteCanvas: remoteCanvas [

	remote := remoteCanvas.
	lastTick := 0.

]

{ #category : #'Nebraska\/embeddedWorlds' }
BufferedCanvas >> displayIsFullyUpdated [

	self checkIfTimeToDisplay
]

{ #category : #'drawing-general' }
BufferedCanvas >> drawMorph: x [

]

{ #category : #accessing }
BufferedCanvas >> extent [

	^Display extent
]

{ #category : #other }
BufferedCanvas >> forceToScreen: rect [

	mirrorOfScreen ifNil: [
		mirrorOfScreen := (previousVersion ifNil: [Display]) deepCopy.
	].
	mirrorOfScreen copy: rect from: rect origin in: Display rule: Form over.
	dirtyRect := dirtyRect ifNil: [rect] ifNotNil: [dirtyRect merge: rect].

]

{ #category : #accessing }
BufferedCanvas >> origin [

	^0@0
]

{ #category : #'as yet unclassified' }
BufferedCanvas >> purgeOutputQueue [
]

{ #category : #'as yet unclassified' }
BufferedCanvas >> sendDeltas [
"
NebraskaDebug showStats: #sendDeltas
"
	| t deltas dirtyFraction |

	previousVersion ifNil: [
		previousVersion := Display deepCopy.
		remote 
			image: previousVersion 
			at: 0@0 
			sourceRect: previousVersion boundingBox 
			rule: Form paint.
		^remote forceToScreen: previousVersion boundingBox.
	].
	dirtyRect ifNil: [^self].
	t := Time millisecondClockValue.
	dirtyFraction := dirtyRect area / previousVersion boundingBox area roundTo: 0.0001.

	deltas := mirrorOfScreen deltaFrom: (previousVersion copy: dirtyRect) at: dirtyRect origin.
	previousVersion := mirrorOfScreen.
	mirrorOfScreen := nil.

	remote 
		image: deltas at: dirtyRect origin sourceRect: deltas boundingBox rule: Form reverse;
		forceToScreen: dirtyRect.

	t := Time millisecondClockValue - t.
	NebraskaDebug at: #sendDeltas add: {t. dirtyFraction. deltas boundingBox}.
	dirtyRect := nil.

]
