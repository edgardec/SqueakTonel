"
A canvas which draws to a terminal across the network.  Note that multiple RemoteCanvas's might exist for a single MREncoder, each having different transformations and clipping rectangles.
"
Class {
	#name : #RemoteCanvas,
	#superclass : #Canvas,
	#instVars : [
		'innerClipRect',
		'outerClipRect',
		'transform',
		'connection',
		'shadowColor'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
RemoteCanvas class >> connection: connection  clipRect: clipRect  transform: transform [
	^self new connection: connection clipRect: clipRect transform: transform
]

{ #category : #private }
RemoteCanvas >> apply: ignored [

	"added for the convenience of BufferedCanvas"
]

{ #category : #initialization }
RemoteCanvas >> asBufferedCanvas [

	| bufferedCanvas |

	bufferedCanvas := BufferedCanvas new.
	connection cachingEnabled: false.
	bufferedCanvas
		connection: connection
		clipRect: NebraskaServer extremelyBigRectangle
		transform: MorphicTransform identity
		remoteCanvas: self.
	^bufferedCanvas
]

{ #category : #accessing }
RemoteCanvas >> backlog [

	^connection backlog
]

{ #category : #drawing }
RemoteCanvas >> balloonFillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc [

	self drawCommand: [ :executor |
		executor balloonFillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc
	].
]

{ #category : #drawing }
RemoteCanvas >> balloonFillRectangle: aRectangle fillStyle: aFillStyle [

	self drawCommand: [ :executor |
		executor balloonFillRectangle: aRectangle fillStyle: aFillStyle
	].
]

{ #category : #'drawing-support' }
RemoteCanvas >> clipBy: aRectangle during: aBlock [
	| newCanvas newR |
	"Set a clipping rectangle active only during the execution of aBlock."

	newR := transform localBoundsToGlobal: aRectangle.

	newCanvas := RemoteCanvas 
		connection: connection 
		clipRect: (outerClipRect intersect: newR) 
		transform: transform.
	newCanvas privateShadowColor: shadowColor.
	aBlock value: newCanvas.
	connection shadowColor: shadowColor.
]

{ #category : #accessing }
RemoteCanvas >> clipRect [
	^innerClipRect
]

{ #category : #initialization }
RemoteCanvas >> connection: connection0 clipRect: clipRect0 transform: transform0 [
	connection := connection0.
	outerClipRect := clipRect0.
	transform := transform0.


	innerClipRect := transform globalBoundsToLocal: outerClipRect. 
]

{ #category : #accessing }
RemoteCanvas >> contentsOfArea: aRectangle into: aForm [
	"this should never be called; normally, RemoteCanvas's are used in conjunction with a CachingCanvas"

	self flag: #roundedRudeness.	

	"aForm fillWhite.
	^aForm"

	^Display getCanvas contentsOfArea: aRectangle into: aForm
]

{ #category : #private }
RemoteCanvas >> drawCommand: aBlock [
	"set up the connection for a drawing command, and then execute aBlock with the connection as an argument"
	connection updateTransform: transform andClipRect: outerClipRect.
	aBlock value: connection
]

{ #category : #'drawing-polygons' }
RemoteCanvas >> drawPolygon: vertices color: aColor borderWidth: bw borderColor: bc [
	self drawCommand: [ :c |
		c drawPolygon: vertices color: aColor borderWidth: bw borderColor: bc ]
]

{ #category : #'drawing-text' }
RemoteCanvas >> drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c [
	"Draw the given string in the given font and color clipped to the given rectangle. If the font is nil, the default font is used."
	"(innerClipRect intersects: (transform transformBoundsRect: boundsRect)) ifFalse: [ ^self ]."
		"clip rectangles seem to be all screwed up...."
	s isAllSeparators ifTrue: [ ^self ].   "is this correct??  it sure does speed things up!"
	self drawCommand: [ :executor |
		executor drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: (self isShadowDrawing ifTrue: [self shadowColor] ifFalse: [c])]
]

{ #category : #accessing }
RemoteCanvas >> extent [
	self flag: #hack.
	^1500@1500
]

{ #category : #'drawing-ovals' }
RemoteCanvas >> fillOval: bounds color: color borderWidth: borderWidth borderColor: borderColor [
	"Fill the given oval."
	self drawCommand: [ :executor |
		executor fillOval: bounds color: color borderWidth: borderWidth borderColor: borderColor
	].
]

{ #category : #'drawing-ovals' }
RemoteCanvas >> fillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc [
	"Fill the given oval."
	self shadowColor ifNotNil: [
		^self fillOval: aRectangle color: aFillStyle asColor borderWidth: bw borderColor: bc
	].
	(aFillStyle isBitmapFill and:[aFillStyle isKindOf: InfiniteForm]) ifTrue:[
		self flag: #fixThis.
		^self fillOval: aRectangle color: aFillStyle borderWidth: bw borderColor: bc
	].
	(aFillStyle isSolidFill) ifTrue:[
		^self fillOval: aRectangle color: aFillStyle asColor borderWidth: bw borderColor: bc
	].
	"Use a BalloonCanvas instead"
	self balloonFillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc
]

{ #category : #'drawing-rectangles' }
RemoteCanvas >> fillRectangle: aRectangle fillStyle: aFillStyle [
	"Fill the given rectangle."
	| pattern |
	(self isShadowDrawing not and: [self shadowColor notNil]) ifTrue:
		[^self fillRectangle: aRectangle color: self shadowColor].

	(aFillStyle isKindOf: InfiniteForm) ifTrue: [
		^self infiniteFillRectangle: aRectangle fillStyle: aFillStyle
	].

	(aFillStyle isSolidFill) 
		ifTrue:[^self fillRectangle: aRectangle color: aFillStyle asColor].
	"We have a very special case for filling with infinite forms"
	(aFillStyle isBitmapFill and:[aFillStyle origin = (0@0)]) ifTrue:[
		pattern := aFillStyle form.
		(aFillStyle direction = (pattern width @ 0) 
			and:[aFillStyle normal = (0@pattern height)]) ifTrue:[
				"Can use an InfiniteForm"
				^self fillRectangle: aRectangle color: (InfiniteForm with: pattern)].
	].
	"Use a BalloonCanvas instead"
	self balloonFillRectangle: aRectangle fillStyle: aFillStyle.
]

{ #category : #initialization }
RemoteCanvas >> flush [
	connection ifNotNil: [ connection flush ]
]

{ #category : #other }
RemoteCanvas >> forceToScreen: rect [

		self drawCommand: [ :exec |
			exec forceToScreen: rect ]
]

{ #category : #'drawing-rectangles' }
RemoteCanvas >> frameAndFillRectangle: bounds fillColor: fillColor borderWidth: borderWidth borderColor: borderColor [
	"Draw the rectangle using the given attributes"

	self drawCommand: [ :executor |
		executor 
			frameAndFillRectangle: bounds 
			fillColor: fillColor 
			borderWidth: borderWidth 
			borderColor: borderColor
	].
]

{ #category : #private }
RemoteCanvas >> image: aForm at: aPoint sourceRect: sourceRect rule: rule [
	"Draw the given form."
	self drawCommand: [ :executor |
		executor image: aForm at: aPoint sourceRect: sourceRect rule: rule
	].
]

{ #category : #drawing }
RemoteCanvas >> infiniteFillRectangle: aRectangle fillStyle: aFillStyle [

	self drawCommand: [ :c |
		c infiniteFillRectangle: aRectangle fillStyle: aFillStyle
	]
]

{ #category : #accessing }
RemoteCanvas >> isShadowDrawing [
	^ self shadowColor notNil
]

{ #category : #drawing }
RemoteCanvas >> line: point1 to: point2 width: width color: color [
	"Draw a line using the given width and color"
	self drawCommand: [ :executor |
		executor line: point1 to: point2 width: width color: color ]
]

{ #category : #accessing }
RemoteCanvas >> origin [
	^0@0
]

{ #category : #drawing }
RemoteCanvas >> paragraph: paragraph bounds: bounds color: c [

	| scanner |
	scanner := CanvasCharacterScanner new.
	scanner
		 canvas: self;
		text: paragraph text textStyle: paragraph textStyle;
		textColor: c; defaultTextColor: c.

	paragraph displayOn: self using: scanner at: bounds topLeft.

]

{ #category : #'drawing-support' }
RemoteCanvas >> privateShadowColor: x [

	shadowColor := x.

]

{ #category : #misc }
RemoteCanvas >> processIO [
	connection processIO
]

{ #category : #initialization }
RemoteCanvas >> purgeOutputQueue [

	connection purgeOutputQueue.
]

{ #category : #accessing }
RemoteCanvas >> shadowColor [

	^shadowColor
]

{ #category : #accessing }
RemoteCanvas >> shadowColor: x [

	connection shadowColor: (shadowColor := x).

]

{ #category : #'drawing-support' }
RemoteCanvas >> showAt: pt invalidRects: updateRects [
	updateRects do: [ :rect |
		self drawCommand: [ :exec |
			exec forceToScreen: rect ] ]
]

{ #category : #'drawing-images' }
RemoteCanvas >> stencil: stencilForm at: aPoint sourceRect: sourceRect color: aColor [
	"Flood this canvas with aColor wherever stencilForm has non-zero pixels"
	self drawCommand: [ :executor |
		executor stencil: stencilForm at: aPoint sourceRect: sourceRect color: aColor ]
]

{ #category : #'Nebraska\/embeddedWorlds' }
RemoteCanvas >> transform2By: aDisplayTransform clippingTo: aClipRect during: aBlock smoothing: cellSize [

	(aDisplayTransform isPureTranslation) ifTrue: [
		^self 
			transformBy: aDisplayTransform 
			clippingTo: aClipRect 
			during: aBlock 
			smoothing: cellSize
	].
	^super 
		transform2By: aDisplayTransform 
		clippingTo: aClipRect 
		during: aBlock 
		smoothing: cellSize

]

{ #category : #'drawing-support' }
RemoteCanvas >> transformBy: aDisplayTransform clippingTo: aClipRect during: aBlock smoothing: cellSize [
	| newCanvas |

	self flag: #bob.		"do tranform and clip work together properly?"
	newCanvas := RemoteCanvas 
		connection: connection 
		clipRect: (aClipRect intersect: outerClipRect)
		transform: (transform composedWith: aDisplayTransform).
	newCanvas privateShadowColor: shadowColor.
	aBlock value: newCanvas.
	connection shadowColor: shadowColor.
]

{ #category : #'drawing-support' }
RemoteCanvas >> translateBy: delta during: aBlock [
	self transformBy: (MorphicTransform offset: delta negated) clippingTo: outerClipRect during: aBlock smoothing: 1
]
