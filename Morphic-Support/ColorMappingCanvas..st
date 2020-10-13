Class {
	#name : #ColorMappingCanvas,
	#superclass : #Canvas,
	#instVars : [
		'myCanvas'
	],
	#category : #'Morphic-Support'
}

{ #category : #'instance creation' }
ColorMappingCanvas class >> on: aCanvas [
	^self new on: aCanvas
]

{ #category : #'drawing-support' }
ColorMappingCanvas >> clipBy: aRectangle during: aBlock [
	"Set a clipping rectangle active only during the execution of aBlock.
	Note: In the future we may want to have more general clip shapes - not just rectangles"
	| oldCanvas |
	oldCanvas := myCanvas.
	myCanvas clipBy: aRectangle during:[:newCanvas|
		myCanvas := newCanvas.
		aBlock value: self].
	myCanvas := oldCanvas
]

{ #category : #accessing }
ColorMappingCanvas >> clipRect [
	^myCanvas clipRect
]

{ #category : #accessing }
ColorMappingCanvas >> depth [
	^myCanvas depth
]

{ #category : #'drawing-polygons' }
ColorMappingCanvas >> drawPolygon: vertices color: aColor borderWidth: bw borderColor: bc [
	"Draw the given polygon."
	^myCanvas
		drawPolygon: vertices
		color: aColor
		borderWidth: bw
		borderColor: (self mapColor: bc)
]

{ #category : #'drawing-text' }
ColorMappingCanvas >> drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c [
	"Draw the given string in the given font and color clipped to the given rectangle. If the font is nil, the default font is used."
	myCanvas
		drawString: s from: firstIndex to: lastIndex 
		in: boundsRect 
		font: fontOrNil 
		color: (self mapColor: c)
]

{ #category : #accessing }
ColorMappingCanvas >> extent [
	^myCanvas extent
]

{ #category : #'drawing-ovals' }
ColorMappingCanvas >> fillOval: r color: c borderWidth: borderWidth borderColor: borderColor [
	"Fill the given oval."
	myCanvas
		fillOval: r
		color: (self mapColor: c)
		borderWidth: borderWidth
		borderColor: (self mapColor: borderColor)
]

{ #category : #initialization }
ColorMappingCanvas >> flush [
	myCanvas flush.
]

{ #category : #accessing }
ColorMappingCanvas >> form [
	^myCanvas form
]

{ #category : #'drawing-rectangles' }
ColorMappingCanvas >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth borderColor: borderColor [
	"Draw the rectangle using the given attributes"
	myCanvas
		frameAndFillRectangle: r
		fillColor: (self mapColor: fillColor)
		borderWidth: borderWidth
		borderColor: (self mapColor: borderColor)
]

{ #category : #'drawing-rectangles' }
ColorMappingCanvas >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth topLeftColor: topLeftColor bottomRightColor: bottomRightColor [
	"Draw the rectangle using the given attributes"
	myCanvas
		frameAndFillRectangle: r 
		fillColor: (self mapColor: fillColor) 
		borderWidth: borderWidth 
		topLeftColor: (self mapColor: topLeftColor)
		bottomRightColor: (self mapColor: bottomRightColor)
]

{ #category : #'drawing-rectangles' }
ColorMappingCanvas >> frameAndFillRoundRect: aRectangle radius: cornerRadius fillStyle: fillStyle borderWidth: bw borderColor: bc [
	"Draw the rectangle using the given attributes"
	myCanvas
		frameAndFillRoundRect: aRectangle
		radius: cornerRadius
		fillStyle: (self mapFillStyle: fillStyle)
		borderWidth: bw
		borderColor: (self mapColor: bc)

]

{ #category : #private }
ColorMappingCanvas >> image: aForm at: aPoint sourceRect: sourceRect rule: rule [
	"Draw the given form. For the 'paint' combination rule use stenciling otherwise simply fill the source rectangle."
	^myCanvas image: aForm at: aPoint sourceRect: sourceRect rule: rule.
]

{ #category : #testing }
ColorMappingCanvas >> isShadowDrawing [
	^myCanvas isShadowDrawing
]

{ #category : #drawing }
ColorMappingCanvas >> line: pt1 to: pt2 width: w color: c [
	"Draw a line using the given width and color"
	myCanvas
		line: pt1
		to: pt2
		width: w
		color: (self mapColor: c).
]

{ #category : #private }
ColorMappingCanvas >> mapColor: aColor [
	^aColor
]

{ #category : #private }
ColorMappingCanvas >> mapFillStyle: aFillStyle [

	^ aFillStyle isGradientFill
		ifFalse: [self mapColor: aFillStyle asColor]
		ifTrue: [aFillStyle copy colorRamp: (aFillStyle colorRamp collect: [:assoc | assoc key -> (self mapColor: assoc value)])].

]

{ #category : #initialization }
ColorMappingCanvas >> on: aCanvas [
	myCanvas := aCanvas.
]

{ #category : #accessing }
ColorMappingCanvas >> origin [
	^myCanvas origin
]

{ #category : #drawing }
ColorMappingCanvas >> paragraph: paragraph bounds: bounds color: c [
	"Draw the given paragraph"
	myCanvas
		paragraph: paragraph
		bounds: bounds
		color: (self mapColor: c)
]

{ #category : #'drawing-support' }
ColorMappingCanvas >> preserveStateDuring: aBlock [
	"Preserve the full canvas state during the execution of aBlock"
	| oldCanvas result |
	oldCanvas := myCanvas.
	result := myCanvas preserveStateDuring:[:newCanvas|
		myCanvas := newCanvas.
		aBlock value: self].
	myCanvas := oldCanvas.
	^result
]

{ #category : #initialization }
ColorMappingCanvas >> reset [
	myCanvas reset.
]

{ #category : #'drawing-images' }
ColorMappingCanvas >> stencil: aForm at: aPoint color: aColor [
	myCanvas
		stencil: aForm
		at: aPoint
		color: (self mapColor: aColor)
]

{ #category : #'drawing-images' }
ColorMappingCanvas >> stencil: aForm at: aPoint sourceRect: aRect color: aColor [
	myCanvas
		stencil: aForm
		at: aPoint
		sourceRect: aRect
		color: (self mapColor: aColor)
]

{ #category : #'drawing-support' }
ColorMappingCanvas >> transformBy: aDisplayTransform clippingTo: aClipRect during: aBlock	 smoothing: cellSize [

	"Transform the receiver by the given display transformation during the execution of aBlock. The given clip rectangle defines the *global* (e.g., outer) rectangle against which the receiver should clip (which would be equivalent to 'self clipRect: aClipRect; transformBy: aDisplayTransform')."
	| oldCanvas |
	oldCanvas := myCanvas.
	myCanvas transformBy: aDisplayTransform
		clippingTo: aClipRect
		during: [:newCanvas |
				myCanvas := newCanvas.
				aBlock value: self]
		smoothing: cellSize.
	myCanvas := oldCanvas.
]

{ #category : #other }
ColorMappingCanvas >> translateBy: delta clippingTo: aRectangle during: aBlock [
	"Set a translation and clipping rectangle only during the execution of aBlock."
	| oldCanvas |
	oldCanvas := myCanvas.
	myCanvas translateBy: delta clippingTo: aRectangle during:[:newCanvas|
		myCanvas := newCanvas.
		aBlock value: self].
	myCanvas := oldCanvas.
]

{ #category : #'drawing-support' }
ColorMappingCanvas >> translateBy: delta during: aBlock [
	"Set a translation only during the execution of aBlock."
	| oldCanvas |
	oldCanvas := myCanvas.
	myCanvas translateBy: delta during:[:newCanvas|
		myCanvas := newCanvas.
		aBlock value: self].
	myCanvas := oldCanvas.
]

{ #category : #'drawing-support' }
ColorMappingCanvas >> translateTo: newOrigin clippingTo: aRectangle during: aBlock [
	"Set a new origin and clipping rectangle only during the execution of aBlock."
	| oldCanvas |
	oldCanvas := myCanvas.
	myCanvas translateTo: newOrigin clippingTo: aRectangle during:[:newCanvas|
		myCanvas := newCanvas.
		aBlock value: self].
	myCanvas := oldCanvas.
]
