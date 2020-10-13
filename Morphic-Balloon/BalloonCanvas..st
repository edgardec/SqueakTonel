"
BalloonCanvas is a canvas using the BalloonEngine for drawing wherever possible. It has various methods which other canvases do not support due to the extra features of the balloon engine.
"
Class {
	#name : #BalloonCanvas,
	#superclass : #FormCanvas,
	#instVars : [
		'transform',
		'colorTransform',
		'engine',
		'aaLevel',
		'deferred'
	],
	#category : #'Morphic-Balloon'
}

{ #category : #accessing }
BalloonCanvas >> aaLevel [
	^aaLevel
]

{ #category : #accessing }
BalloonCanvas >> aaLevel: newLevel [
	"Only allow changes to aaLevel if we're working on >= 8 bit forms"
	form depth >= 8 ifFalse:[^self].
	aaLevel = newLevel ifTrue:[^self].
	self flush.	"In case there are pending primitives in the engine"
	aaLevel := newLevel.
	engine ifNotNil:[engine aaLevel: aaLevel].
]

{ #category : #converting }
BalloonCanvas >> asBalloonCanvas [
	^self
]

{ #category : #transforming }
BalloonCanvas >> colorTransformBy: aColorTransform [
	aColorTransform ifNil:[^self].
	colorTransform 
		ifNil:[colorTransform := aColorTransform]
		ifNotNil:[colorTransform := colorTransform composedWithLocal: aColorTransform]
]

{ #category : #copying }
BalloonCanvas >> copy [

	self flush.
	^super copy
]

{ #category : #accessing }
BalloonCanvas >> deferred [
	^deferred
]

{ #category : #accessing }
BalloonCanvas >> deferred: aBoolean [
	deferred == aBoolean ifTrue:[^self].
	self flush. "Force pending prims on screen"
	deferred := aBoolean.
	engine ifNotNil:[engine deferred: aBoolean].
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawBezier3Shape: vertices color: c borderWidth: borderWidth borderColor:
borderColor [
	self drawBezierShape: (Bezier3Segment convertBezier3ToBezier2:
vertices) color: c borderWidth: borderWidth borderColor: borderColor
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawBezierShape: vertices color: c borderWidth: borderWidth borderColor: borderColor [
	"Draw a boundary shape that is defined by a list of vertices.
	Each three subsequent vertices define a quadratic bezier segment.
	For lines, the control point should be set to either the start or the end
	of the bezier curve."
	| fillC borderC |
	fillC := self shadowColor ifNil:[c].
	borderC := self shadowColor ifNil:[borderColor].
	self ensuredEngine
		drawBezierShape: vertices
		fill: fillC
		borderWidth: borderWidth
		borderColor: borderC
		transform: transform.
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawCompressedShape: compressedShape [
	"Draw a compressed shape"
	self ensuredEngine
		drawCompressedShape: compressedShape
		transform: transform.
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawGeneralBezier3Shape: contours color: c borderWidth: borderWidth
borderColor: borderColor [
	| b2 |
	b2 := contours collect: [:b3 | Bezier3Segment
convertBezier3ToBezier2: b3 ].
	self drawGeneralBezierShape: b2 color: c borderWidth: borderWidth
borderColor: borderColor
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawGeneralBezierShape: contours color: c borderWidth: borderWidth borderColor: borderColor [
	"Draw a general boundary shape (e.g., possibly containing holes)"
	| fillC borderC |
	fillC := self shadowColor ifNil:[c].
	borderC := self shadowColor ifNil:[borderColor].
	self ensuredEngine
		drawGeneralBezierShape: contours
		fill: fillC
		borderWidth: borderWidth
		borderColor: borderC
		transform: transform.
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawGeneralPolygon: contours color: c borderWidth: borderWidth borderColor: borderColor [
	"Draw a general polygon (e.g., a polygon that can contain holes)"
	| fillC borderC |
	fillC := self shadowColor ifNil:[c].
	borderC := self shadowColor ifNil:[borderColor].
	self ensuredEngine
		drawGeneralPolygon: contours
		fill: fillC
		borderWidth: borderWidth
		borderColor: borderC
		transform: transform.
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawOval: r color: c borderWidth: borderWidth borderColor: borderColor [
	"Draw the oval defined by the given rectangle"
	| fillC borderC |
	fillC := self shadowColor ifNil:[c].
	borderC := self shadowColor ifNil:[borderColor].
	self ensuredEngine
		drawOval: r
		fill: fillC
		borderWidth: borderWidth
		borderColor: borderC
		transform: transform.
]

{ #category : #'drawing-polygons' }
BalloonCanvas >> drawPolygon: vertices fillStyle: aFillStyle [
	"Fill the given polygon."
	self drawPolygon: vertices fillStyle: aFillStyle borderWidth: 0 borderColor: nil
]

{ #category : #'drawing-polygons' }
BalloonCanvas >> drawPolygon: vertices fillStyle: aFillStyle borderWidth: borderWidth borderColor: borderColor [
	"Draw a simple polygon defined by the list of vertices."
	| fillC borderC |
	vertices ifEmpty: [ ^ self ].
	fillC := self shadowColor ifNil:[aFillStyle].
	borderC := self shadowColor ifNil:[borderColor].
	self ensuredEngine
		drawPolygon: (vertices copyWith: vertices first)
		fill: fillC
		borderWidth: borderWidth
		borderColor: borderC
		transform: transform.
]

{ #category : #'balloon drawing' }
BalloonCanvas >> drawRectangle: r color: c borderWidth: borderWidth borderColor: borderColor [
	"Draw a rectangle"
	| fillC borderC |
	fillC := self shadowColor ifNil:[c].
	borderC := self shadowColor ifNil:[borderColor].
	self ensuredEngine
		drawRectangle: r
		fill: fillC
		borderWidth: borderWidth
		borderColor: borderC
		transform: transform.
]

{ #category : #TODO }
BalloonCanvas >> drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c [
	(self ifNoTransformWithIn: boundsRect)
		ifTrue:[^super drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c]
]

{ #category : #accessing }
BalloonCanvas >> ensuredEngine [
	engine ifNil:[
		engine := BalloonEngine new.
		"engine := BalloonDebugEngine new"
		engine aaLevel: aaLevel.
		engine bitBlt: port.
		engine destOffset: origin.
		engine clipRect: clipRect.
		engine deferred: deferred.
		engine].
	engine colorTransform: colorTransform.
	engine edgeTransform: transform.
	^engine
]

{ #category : #drawing }
BalloonCanvas >> fillColor: c [
	"Note: This always fills, even if the color is transparent."
	"Note2: To achieve the above we must make sure that c is NOT transparent"
	self frameAndFillRectangle: form boundingBox 
		fillColor: (c alpha: 1.0)
		borderWidth: 0
		borderColor: nil
]

{ #category : #drawing }
BalloonCanvas >> fillOval: r color: c borderWidth: borderWidth borderColor: borderColor [
	"Draw a filled and outlined oval"
	"Note: The optimization test below should actually read:
		self ifNoTransformWithIn: (r insetBy: borderWidth // 2)
	but since borderWidth is assumed to be very small related to r we don't check it."

	(self ifNoTransformWithIn: r)
		ifTrue:[^super fillOval: r color: c borderWidth: borderWidth borderColor: borderColor].

	^self drawOval: (r insetBy: borderWidth // 2) 
			color: c 
			borderWidth: borderWidth 
			borderColor: borderColor
]

{ #category : #'drawing-ovals' }
BalloonCanvas >> fillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc [
	"Fill the given rectangle."
	^self drawOval: (aRectangle insetBy: bw // 2)
			color: aFillStyle "@@: Name confusion!!!"
			borderWidth: bw
			borderColor: bc

]

{ #category : #drawing }
BalloonCanvas >> fillRectangle: r color: c [
	"Fill the rectangle with the given color"
	^self frameAndFillRectangle: r
			fillColor: c
			borderWidth: 0
			borderColor: nil
]

{ #category : #'drawing-rectangles' }
BalloonCanvas >> fillRectangle: aRectangle fillStyle: aFillStyle [
	"Fill the given rectangle."
	^self drawRectangle: aRectangle
			color: aFillStyle "@@: Name confusion!!!"
			borderWidth: 0
			borderColor: nil

]

{ #category : #'drawing-rectangles' }
BalloonCanvas >> fillRoundRect: aRectangle radius: radius fillStyle: fillStyle [
	| points |
	radius asPoint <= (0@0) 
		ifTrue:[^self fillRectangle: aRectangle fillStyle: fillStyle].
	(radius * 2) asPoint >= aRectangle extent 
		ifTrue:[^self fillOval: aRectangle fillStyle: fillStyle].
	"decompose aRectangle into bezier form"
	points := self makeRoundRectShape: aRectangle radius: radius.
	"blast the bezier shape out"
	self
		drawBezierShape: points
		color: fillStyle
		borderWidth: 0
		borderColor: nil.

]

{ #category : #initialize }
BalloonCanvas >> flush [
	"Force all pending primitives onscreen"
	engine ifNotNil:[engine flush].
]

{ #category : #drawing }
BalloonCanvas >> frameAndFillRectangle: r fillColor: c borderWidth: borderWidth borderColor: borderColor [
	"Draw a filled and outlined rectangle"
	"Note: The optimization test below should actually read:
		self ifNoTransformWithIn: (r insetBy: borderWidth // 2)
	but since borderWidth is assumed to be very small related to r we don't check it."

	(self ifNoTransformWithIn: r)
		ifTrue:[^super frameAndFillRectangle: r fillColor: c borderWidth: borderWidth borderColor: borderColor].

	^self drawRectangle: (r insetBy: borderWidth // 2) 
			color: c 
			borderWidth: borderWidth 
			borderColor: borderColor
]

{ #category : #drawing }
BalloonCanvas >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth topLeftColor: topLeftColor bottomRightColor: bottomRightColor [
	"Draw a beveled or raised rectangle"
	| bw |

	"Note: The optimization test below should actually read:
		self ifNoTransformWithIn: (r insetBy: borderWidth // 2)
	but since borderWidth is assumed to be very small related to r we don't check it."

	(self ifNoTransformWithIn: r)
		ifTrue:[^super frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth topLeftColor: topLeftColor bottomRightColor: bottomRightColor].

	"Fill rectangle and draw top and left border"
	bw := borderWidth // 2.
	self drawRectangle: (r insetBy: bw)
		color: fillColor
		borderWidth: borderWidth
		borderColor: topLeftColor.
	"Now draw bottom right border."
	self drawPolygon: (Array with: r topRight + (bw negated@bw) 
							with: r bottomRight - bw asPoint
							with: r bottomLeft + (bw@bw negated))
		color: nil
		borderWidth: borderWidth
		borderColor: bottomRightColor.
]

{ #category : #drawing }
BalloonCanvas >> frameRectangle: r width: w color: c [
	"Draw a frame around the given rectangle"
	^self frameAndFillRectangle: r
			fillColor: Color transparent
			borderWidth: w
			borderColor: c
]

{ #category : #'drawing-rectangles' }
BalloonCanvas >> frameRoundRect: aRectangle radius: radius width: borderWidth color: borderColor [
	| outerPoints innerRect innerRadius innerPoints |
	(borderWidth isZero or:[borderColor isTransparent])
		ifTrue:[^self].
	radius asPoint <= (0@0) 
		ifTrue:[^self frameRectangle: aRectangle width: borderWidth color: borderColor].
	"decompose inner rectangle into bezier shape"
	innerRect := aRectangle insetBy: borderWidth.
	innerRect area <= 0 
		ifTrue:[^self fillRoundRect: aRectangle radius: radius fillStyle: borderColor].
	innerRadius := (radius - borderWidth) asPoint.
	innerPoints := self makeRoundRectShape: innerRect radius: innerRadius.
	"decompose outer rectangle into bezier shape"
	outerPoints := self makeRoundRectShape: aRectangle radius: radius.
	self
		drawGeneralBezierShape: (Array with: outerPoints with: innerPoints)
		color: borderColor
		borderWidth: 0
		borderColor: nil.
]

{ #category : #private }
BalloonCanvas >> ifNoTransformWithIn: box [
	"Return true if the current transformation does not affect the given bounding box"
	| delta |
	transform ifNil: [^true].
	delta := (transform localPointToGlobal: box origin) - box origin.
	^(transform localPointToGlobal: box corner) - box corner = delta
]

{ #category : #private }
BalloonCanvas >> image: aForm at: aPoint sourceRect: sourceRect rule: rule [
	| warp dstRect srcQuad dstOffset center |
	(self ifNoTransformWithIn: sourceRect) & false
		ifTrue:[^super image: aForm at: aPoint sourceRect: sourceRect rule: rule].
	dstRect := (transform localBoundsToGlobal: (aForm boundingBox translateBy: aPoint)).
	dstOffset := 0@0. "dstRect origin."
	"dstRect := 0@0 corner: dstRect extent."
	center := 0@0."transform globalPointToLocal: dstRect origin."
	srcQuad := transform globalPointsToLocal: (dstRect innerCorners).
	srcQuad := srcQuad collect:[:pt| pt - aPoint].
	warp := (WarpBlt toForm: form)
			sourceForm: aForm;
			cellSize: 2;  "installs a new colormap if cellSize > 1"
			combinationRule: Form over.
	warp copyQuad: srcQuad toRect: (dstRect translateBy: dstOffset).

	self frameRectangle: (aForm boundingBox translateBy: aPoint) color: Color green.

	"... TODO ... create a bitmap fill style from the form and use it for a simple rectangle."
]

{ #category : #initialize }
BalloonCanvas >> initialize [
	super initialize.
	aaLevel := 1.
	deferred := false.
]

{ #category : #testing }
BalloonCanvas >> isBalloonCanvas [
	^true
]

{ #category : #testing }
BalloonCanvas >> isVisible: aRectangle [
	^transform 
		ifNil:[super isVisible: aRectangle]
		ifNotNil:[super isVisible: (transform localBoundsToGlobal: aRectangle)]
]

{ #category : #TODO }
BalloonCanvas >> line: point1 to: point2 brushForm: brush [
	"Who's gonna use this?"
	| pt1 pt2 |
	self flush. "Sorry, but necessary..."
	transform 
		ifNil:[pt1 := point1. pt2 := point2]
		ifNotNil:[pt1 := transform localPointToGlobal: point1.
				pt2 := transform localPointToGlobal: point2].
	^super line: pt1 to: pt2 brushForm: brush
]

{ #category : #drawing }
BalloonCanvas >> line: pt1 to: pt2 width: w color: c [
	"Draw a line from pt1 to: pt2"

	(aaLevel = 1 and: [self ifNoTransformWithIn:(pt1 rect: pt2)])
		ifTrue:[^super line: pt1 to: pt2 width: w color: c].
	^self drawPolygon: (Array with: pt1 with: pt2)
		color: c
		borderWidth: w
		borderColor: c
]

{ #category : #private }
BalloonCanvas >> makeRoundRectShape: aRectangle radius: radius [
	"decompose a rounded rectangle into bezier form"
	| ovalDiameter rectExtent segments points endPoint seg idx offset rectOffset |
	ovalDiameter := (radius * 2) asPoint min: aRectangle extent.
	(ovalDiameter x <= 0 or: [ovalDiameter y <= 0]) ifTrue: [
		"degenerates into rectangle - just hand back four lines"
		| topLeft topRight bottomLeft bottomRight |
		topLeft := aRectangle topLeft.
		topRight := aRectangle topRight.
		bottomLeft := aRectangle bottomLeft.
		bottomRight := aRectangle bottomRight.

		points := Array new: 4 * 3.
		points at: 1 put: topLeft.
		points at: 2 put: topLeft.
		points at: 3 put: topRight.

		points at: 4 put: topRight.
		points at: 5 put: topRight.
		points at: 6 put: bottomRight.

		points at: 7 put: bottomRight.
		points at: 8 put: bottomRight.
		points at: 9 put: bottomLeft.

		points at: 10 put: bottomLeft.
		points at: 11 put: bottomLeft.
		points at: 12 put: topLeft.
		^points
	].
	rectExtent := aRectangle extent - ovalDiameter.
	rectOffset := aRectangle origin.
	segments := Bezier2Segment makeEllipseSegments: (0 @ 0 extent: ovalDiameter).
	"patch up the segments to include lines connecting the oval parts.
	we need: 8*3 points for the oval parts + 4*3 points for the connecting lines"
	points := Array new: 12 * 3.
	idx := 0.
	"Tweaked offsets to clean up curves. MAD"
	endPoint := segments last end + rectOffset + (0 @ -1).
	1 to: 8 by: 2 do: [:i |
		i = 1 ifTrue: [offset := rectOffset + (rectExtent x @ 0) + (1 @ -1)]. "top, tr"
		i = 3 ifTrue: [offset := rectOffset + rectExtent + (1 @ 1)]. "right, br"
		i = 5 ifTrue: [offset := rectOffset + (0 @ rectExtent y) + (0 @ 1)]. "bottom, bl"
		i = 7 ifTrue: [offset := rectOffset + (0 @ -1)]."left, tl"
		seg := segments at: i.
		"insert a line segment for the horizontal part of the round rect"
		points at: (idx := idx + 1) put: endPoint.
		points at: (idx := idx + 1) put: endPoint.
		points at: (idx := idx + 1) put: seg start + offset.
		"now the first half-arc"
		points at: (idx := idx + 1) put: seg start + offset.
		points at: (idx := idx + 1) put: seg via + offset.
		points at: (idx := idx + 1) put: seg end + offset.
		"the second half-arc"
		seg := segments at: i + 1.
		points at: (idx := idx + 1) put: seg start + offset.
		points at: (idx := idx + 1) put: seg via + offset.
		points at: (idx := idx + 1) put: seg end + offset.
		endPoint := seg end + offset.
	].
	^points
]

{ #category : #TODO }
BalloonCanvas >> paragraph: para bounds: bounds color: c [
	(self ifNoTransformWithIn: bounds)
		ifTrue:[^super paragraph: para bounds: bounds color: c].
]

{ #category : #drawing }
BalloonCanvas >> point: pt color: c [
	"Is there any use for this?"
	| myPt |
	transform 
		ifNil:[myPt := pt]
		ifNotNil:[myPt := transform localPointToGlobal: pt].
	^super point: myPt color: c
]

{ #category : #copying }
BalloonCanvas >> postCopy [

	super postCopy.
	^self resetEngine
]

{ #category : #transforming }
BalloonCanvas >> preserveStateDuring: aBlock [
	| state result |
	state := BalloonState new.
	state transform: transform.
	state colorTransform: colorTransform.
	state aaLevel: self aaLevel.
	result := aBlock value: self.
	transform := state transform.
	colorTransform := state colorTransform.
	self aaLevel: state aaLevel.
	^result
]

{ #category : #initialize }
BalloonCanvas >> resetEngine [
	engine := nil.
]

{ #category : #transforming }
BalloonCanvas >> transformBy: aTransform [
	aTransform ifNil:[^self].
	transform 
		ifNil:[transform := aTransform]
		ifNotNil:[transform := transform composedWithLocal: aTransform]
]

{ #category : #transforming }
BalloonCanvas >> transformBy: aDisplayTransform during: aBlock [
	| myTransform result |
	myTransform := transform.
	self transformBy: aDisplayTransform.
	result := aBlock value: self.
	transform := myTransform.
	^result
]
