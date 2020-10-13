"
Note that when shadowDrawing is true, shadowStipple may be either a color, for a solid shadow of the given color, or it may be a stipple used to simulate gray shading when the display cannot support alpha blending.
"
Class {
	#name : #FormCanvas,
	#superclass : #Canvas,
	#instVars : [
		'origin',
		'clipRect',
		'form',
		'port',
		'shadowColor'
	],
	#category : #'Morphic-Support'
}

{ #category : #'instance creation' }
FormCanvas class >> extent: aPoint [

	^ self extent: aPoint depth: Display depth

]

{ #category : #'instance creation' }
FormCanvas class >> extent: extent depth: depth [

	^ self new setForm: (Form extent: extent depth: depth)
]

{ #category : #'instance creation' }
FormCanvas class >> extent: extent depth: depth origin: aPoint clipRect: aRectangle [

	^ self new
		setForm: (Form extent: extent depth: depth);
		setOrigin: aPoint clipRect: aRectangle;
		yourself
]

{ #category : #'instance creation' }
FormCanvas class >> on: aForm [

	^ self new setForm: aForm

]

{ #category : #testing }
FormCanvas class >> test1 [
	"FormCanvas test1"

	| canvas |
	canvas := FormCanvas extent: 200@200.
	canvas fillColor: (Color black).
	canvas line: 10@10 to: 50@30 width: 1 color: (Color red).
	canvas frameRectangle: ((20@20) corner: (120@120)) width: 4 color: (Color green).
	canvas point: 100@100 color: (Color black).
	canvas drawString: 'Hello, World!' at: 40@40 font: nil color: (Color cyan).
	canvas fillRectangle: ((10@80) corner: (31@121)) color: (Color magenta).
	canvas fillOval: ((10@80) corner: (31@121)) color: (Color cyan).
	canvas frameOval: ((40@80) corner: (61@121)) color: (Color blue).
	canvas frameOval: ((70@80) corner: (91@121)) width: 3 color: (Color red alpha: 0.2).
	canvas fillRectangle: ((130@30) corner: (170@80)) color: (Color lightYellow).
	canvas showAt: 0@0.

]

{ #category : #testing }
FormCanvas class >> test2 [
	"FormCanvas test2"

	| baseCanvas p |
	baseCanvas := FormCanvas extent: 200@200.
	p := Sensor cursorPoint.
	[Sensor anyButtonPressed] whileFalse: [
		baseCanvas translateBy: (Sensor cursorPoint - p) during:[:canvas|
			canvas fillColor: Color white.
			canvas line: 10@10 to: 50@30 width: 1 color: Color red.
			canvas frameRectangle: ((20@20) corner: (120@120)) width: 4 color: Color green.
			canvas point: 100@100 color: Color black.
			canvas drawString: 'Hello, World!' at: 40@40 font: nil color: Color cyan.
			canvas fillRectangle: ((10@80) corner: (31@121)) color: Color magenta.
			canvas fillOval: ((10@80) corner: (31@121)) color: Color cyan.
			canvas frameOval: ((40@80) corner: (61@121)) color: Color blue.
			canvas frameOval: ((70@80) corner: (91@121)) width: 3 color: Color red.
			canvas fillRectangle: ((130@30) corner: (170@80)) color: Color lightYellow.
			canvas showAt: 0@0]].

]

{ #category : #testing }
FormCanvas class >> test3 [
	"FormCanvas test3"

	| baseCanvas |
	baseCanvas := FormCanvas extent: 200@200.
	baseCanvas fillColor: Color white.
	baseCanvas translateBy: 10@10 during:[:canvas|
		canvas shadowColor: (Color black alpha: 0.5).
		canvas line: 10@10 to: 50@30 width: 1 color: Color red.
		canvas frameRectangle: ((20@20) corner: (120@120)) width: 4 color: Color green.
		canvas point: 100@100 color: Color black.
		canvas drawString: 'Hello, World!' at: 40@40 font: nil color: Color cyan.
		canvas fillRectangle: ((10@80) corner: (31@121)) color: Color magenta.
		canvas fillOval: ((10@80) corner: (31@121)) color: Color cyan.
		canvas frameOval: ((40@80) corner: (61@121)) color: Color blue.
		canvas frameOval: ((70@80) corner: (91@121)) width: 3 color: Color red.
		canvas fillRectangle: ((130@30) corner: (170@80)) color: Color lightYellow.
		canvas showAt: 0@0.
	].
]

{ #category : #accessing }
FormCanvas >> allocateForm: extentPoint [
	"Allocate a new form which is similar to the receiver"
	^form allocateForm: extentPoint
]

{ #category : #other }
FormCanvas >> asBalloonCanvas [
	^(BalloonCanvas on: form) setOrigin: origin clipRect: clipRect
]

{ #category : #converting }
FormCanvas >> asShadowDrawingCanvas [
	"Note: This is sort of an optimization here since since the logic is all there"
	^self copy shadowColor: (Color black alpha: 0.5)
]

{ #category : #converting }
FormCanvas >> asShadowDrawingCanvas: aColor [
	"Note: This is sort of an optimization here since since the logic is all there"
	^self copy shadowColor: aColor
]

{ #category : #'drawing-ovals' }
FormCanvas >> balloonFillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc [

	self asBalloonCanvas
		fillOval: aRectangle
		fillStyle: aFillStyle
		borderWidth: bw
		borderColor: bc
]

{ #category : #private }
FormCanvas >> balloonFillRectangle: aRectangle fillStyle: aFillStyle [

	self asBalloonCanvas fillRectangle: aRectangle fillStyle: aFillStyle.
]

{ #category : #private }
FormCanvas >> balloonFillRoundRect: aRectangle radius: radius fillStyle: fillStyle [
	^self asBalloonCanvas fillRoundRect: aRectangle radius: radius fillStyle: fillStyle
]

{ #category : #'drawing-support' }
FormCanvas >> clipBy: aRectangle during: aBlock [
	"Set a clipping rectangle active only during the execution of aBlock.
	Note: In the future we may want to have more general clip shapes - not just rectangles"
	^aBlock value: (self copyClipRect: aRectangle)
]

{ #category : #accessing }
FormCanvas >> clipRect [
	"Return the currently active clipping rectangle"
	^ clipRect translateBy: origin negated
]

{ #category : #accessing }
FormCanvas >> contentsOfArea: aRectangle into: aForm [
	| bb |
	self flush.
	bb := BitBlt toForm: aForm.
	bb sourceForm: form; combinationRule: Form over;
		sourceX: (aRectangle left + origin x); sourceY: (aRectangle top + origin y);
		width: aRectangle width; height: aRectangle height;
		copyBits.
	^aForm
]

{ #category : #copying }
FormCanvas >> copyClipRect: aRectangle [
	^ self copyOrigin: origin clipRect: (aRectangle translateBy: origin)

]

{ #category : #copying }
FormCanvas >> copyOffset: aPoint [
	^ self copyOrigin: origin + aPoint clipRect: clipRect
]

{ #category : #copying }
FormCanvas >> copyOffset: aPoint clipRect: sourceClip [
	"Make a copy of me offset by aPoint, and further clipped
	by sourceClip, a rectangle in the un-offset coordinates"
	^ self copyOrigin: aPoint + origin
		clipRect: ((sourceClip translateBy: origin) intersect: clipRect)
]

{ #category : #copying }
FormCanvas >> copyOrigin: aPoint clipRect: aRectangle [
	"Return a copy of this canvas with the given origin. The clipping rectangle of this canvas is the intersection of the given rectangle and the receiver's current clipping rectangle. This allows the clipping rectangles of nested clipping morphs to be composed."
	^ self copy
		setOrigin: aPoint
		clipRect: (clipRect intersect: aRectangle)
]

{ #category : #accessing }
FormCanvas >> depth [

	^ form depth

]

{ #category : #'drawing-polygons' }
FormCanvas >> drawPolygon: vertices color: aColor borderWidth: bw borderColor: bc [
	"Generalize for the BalloonCanvas"
	^self drawPolygon: vertices fillStyle: aColor borderWidth: bw borderColor: bc
]

{ #category : #'drawing-polygons' }
FormCanvas >> drawPolygon: vertices fillStyle: aFillStyle borderWidth: bw borderColor: bc [
	"Use a BalloonCanvas"
	self asBalloonCanvas 
		drawPolygon: vertices asArray
		fillStyle: (self shadowColor ifNil:[aFillStyle])
		borderWidth: bw 
		borderColor: bc
]

{ #category : #'drawing-text' }
FormCanvas >> drawString: aString from: firstIndex to: lastIndex at: aPoint font: fontOrNil color: c [
	| font |
	port colorMap: nil.
	font := fontOrNil ifNil: [TextStyle defaultFont].
	port combinationRule: Form paint.
	font installOn: port
		foregroundColor: (self shadowColor ifNil:[c]) 
		backgroundColor: Color transparent.
	font displayString: aString on: port 
		from: firstIndex to: lastIndex at: (origin + aPoint) kern: 0.
]

{ #category : #'drawing-text' }
FormCanvas >> drawString: aString from: firstIndex to: lastIndex in: bounds font: fontOrNil color: c [
	| font portRect |
	port colorMap: nil.
	portRect := port clipRect.
	port clipByX1: bounds left + origin x 
		y1: bounds top + origin y 
		x2: bounds right + origin x 
		y2: bounds bottom + origin y.
	font := fontOrNil ifNil: [TextStyle defaultFont].
	port combinationRule: Form paint.
	font installOn: port
		foregroundColor: (self shadowColor ifNil:[c]) 
		backgroundColor: Color transparent.
	font displayString: aString asString on: port 
		from: firstIndex to: lastIndex at: (bounds topLeft + origin) kern: 0.
	port clipRect: portRect.
]

{ #category : #accessing }
FormCanvas >> extent [

	^ form extent
]

{ #category : #drawing }
FormCanvas >> fillColor: c [
	"Note: This always fills, even if the color is transparent."
	self setClearColor: c.
	port fillRect: form boundingBox offset: origin.
]

{ #category : #'drawing-ovals' }
FormCanvas >> fillOval: r color: fillColor borderWidth: borderWidth borderColor: borderColor [
	| rect |
	"draw the border of the oval"
	rect := (r translateBy: origin) truncated.
	(borderWidth = 0 or: [borderColor isTransparent]) ifFalse:[
		self setFillColor: borderColor.
		(r area > 10000 or: [fillColor isTranslucent]) 
			ifTrue: [port frameOval: rect borderWidth: borderWidth]
			ifFalse: [port fillOval: rect]]. "faster this way"
	"fill the inside"
	fillColor isTransparent ifFalse:
		[self setFillColor: fillColor.
		port fillOval: (rect insetBy: borderWidth)].

]

{ #category : #'drawing-ovals' }
FormCanvas >> fillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc [
	"Fill the given oval."

	self flag: #bob.		"this and its siblings could be moved up to Canvas with the
						right #balloonFillOval:..."

	self shadowColor ifNotNil:
		[^self fillOval: aRectangle color: aFillStyle asColor borderWidth: bw borderColor: bc].
	(aFillStyle isBitmapFill and:[aFillStyle isKindOf: InfiniteForm]) ifTrue:[
		self flag: #fixThis.
		^self fillOval: aRectangle color: aFillStyle borderWidth: bw borderColor: bc].
	(aFillStyle isSolidFill) ifTrue:[
		^self fillOval: aRectangle color: aFillStyle asColor borderWidth: bw borderColor: bc].
	"Use a BalloonCanvas instead"
	self balloonFillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc
]

{ #category : #'drawing-rectangles' }
FormCanvas >> fillRectangle: aRectangle fillStyle: aFillStyle [
	"Fill the given rectangle."
	| pattern |
	self shadowColor ifNotNil:
		[^self fillRectangle: aRectangle color: aFillStyle asColor].

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

{ #category : #'drawing-rectangles' }
FormCanvas >> fillRoundRect: aRectangle radius: radius fillStyle: fillStyle [
	fillStyle isTransparent ifTrue:[^self].
	radius asPoint <= (0@0) 
		ifTrue:[^self fillRectangle: aRectangle fillStyle: fillStyle].
	fillStyle isSolidFill 
		ifFalse:[^self balloonFillRoundRect: aRectangle radius: radius fillStyle: fillStyle].
	self setFillColor: (shadowColor ifNil:[fillStyle asColor]).
	^port fillRoundRect: (aRectangle translateBy: origin) truncated radius: radius.

]

{ #category : #initialization }
FormCanvas >> finish [
	"If there are any pending operations on the receiver complete them. Do not return before all modifications have taken effect."
	form finish
]

{ #category : #other }
FormCanvas >> flushDisplay [
		Display deferUpdates: false; forceDisplayUpdate.
]

{ #category : #other }
FormCanvas >> forceToScreen:rect [
	^Display forceToScreen:rect.

]

{ #category : #accessing }
FormCanvas >> form [

	^ form
]

{ #category : #'drawing-rectangles' }
FormCanvas >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth borderColor: borderColor [
	| rect |
	rect := r translateBy: origin.
	"draw the border of the rectangle"
	borderColor isTransparent ifFalse:[
		self setFillColor: borderColor.
		(r area > 10000 or: [fillColor isTranslucent]) ifTrue: [
			port frameRect: rect borderWidth: borderWidth.
		] ifFalse: ["for small rectangles, it's faster to fill the entire outer rectangle
					than to compute and fill the border rects"
					port fillRect: rect offset: origin]].

	"fill the inside"
	fillColor isTransparent ifFalse:
		[self setFillColor: fillColor.
		port fillRect: (rect insetBy: borderWidth) offset: origin].
]

{ #category : #'drawing-rectangles' }
FormCanvas >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth topLeftColor: topLeftColor bottomRightColor: bottomRightColor [

	| w h rect |
	"First use quick code for top and left borders and fill"
	self frameAndFillRectangle: r
		fillColor: fillColor
		borderWidth: borderWidth
		borderColor: topLeftColor.
	
	"Return here for duplicate colors. Makes translucent borders work better."
	topLeftColor = bottomRightColor ifTrue: [^ self].

	"Now use slow code for bevelled bottom and right borders"
	bottomRightColor isTransparent ifFalse: [
		borderWidth isNumber
			ifTrue: [w := h := borderWidth]
			ifFalse: [w := borderWidth x.   h := borderWidth y].
		rect := r translateBy: origin.
		self setFillColor: bottomRightColor.
		port 
			 frameRectRight: rect width: w;
			 frameRectBottom: rect height: h].

]

{ #category : #'drawing-rectangles' }
FormCanvas >> frameAndFillRoundRect: aRectangle radius: cornerRadius fillStyle: fillStyle borderWidth: bw borderColor: bc [
	"Draw a rounded rectangle"
	self shadowColor ifNotNil:[
		^self fillRoundRect: aRectangle radius: cornerRadius fillStyle: shadowColor.
	].
	"see if the round rect is degenerate"
	cornerRadius asPoint <= (0@0) 
		ifTrue:[^self frameAndFillRectangle: aRectangle fillColor: fillStyle asColor borderWidth: bw borderColor: bc].
	"Okay it's a rounded rectangle"
	fillStyle isTransparent ifFalse:["fill interior"
		| innerRect radius |
		innerRect := aRectangle.
		radius := cornerRadius.
		bw isZero ifFalse:[
			innerRect := innerRect insetBy: bw.
			radius := radius - bw.
		].
		self fillRoundRect: innerRect radius: radius fillStyle: fillStyle.
	].
	self frameRoundRect: aRectangle radius: cornerRadius width: bw color: bc

]

{ #category : #'drawing-rectangles' }
FormCanvas >> frameRoundRect: aRectangle radius: radius width: borderWidth color: borderColor [
	"Frame a rounded rectangle with the given attributes."
	| innerRect |
	(borderWidth isZero or:[borderColor isTransparent])
		ifTrue:[^self].
	radius asPoint <= (0@0) 
		ifTrue:[^self frameRectangle: aRectangle width: borderWidth color: borderColor].
	"decompose inner rectangle into bezier shape"
	innerRect := aRectangle insetBy: borderWidth.
	innerRect area <= 0 
		ifTrue:[^self fillRoundRect: aRectangle radius: radius fillStyle: borderColor].
	self setFillColor: borderColor.
	port 
		frameRoundRect: (aRectangle translateBy: origin) truncated 
		radius: radius truncated 
		borderWidth: borderWidth truncated.

]

{ #category : #private }
FormCanvas >> image: aForm at: aPoint sourceRect: sourceRect rule: rule [ 
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."
	port colorMap: (aForm colormapIfNeededFor: form); fillColor: nil.
	port image: aForm at: aPoint + origin sourceRect: sourceRect rule: rule.
	(form depth = 32 and: [aForm depth = 16])
		ifTrue: [port image: nil at: aPoint + origin sourceRect: sourceRect rule: 40 "fixAlpha:with:"].

]

{ #category : #private }
FormCanvas >> image: aForm at: aPoint sourceRect: sourceRect rule: rule alpha: sourceAlpha [
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."
	port colorMap: (aForm colormapIfNeededFor: form); fillColor: nil.
	port image: aForm at: aPoint + origin sourceRect: sourceRect rule: rule alpha: sourceAlpha.
]

{ #category : #private }
FormCanvas >> infiniteFillRectangle: aRectangle fillStyle: aFillStyle [

	| additionalOffset rInPortTerms clippedPort targetTopLeft clipOffset ex |

	"this is a bit of a kludge to get the form to be aligned where I *think* it should be.
	something better is needed, but not now"

	additionalOffset := 0@0.
	ex := aFillStyle form extent.
	rInPortTerms := aRectangle translateBy: origin.
	clippedPort := port clippedBy: rInPortTerms.
	targetTopLeft := clippedPort clipRect topLeft truncateTo: ex.
	clipOffset := rInPortTerms topLeft - targetTopLeft.
	additionalOffset := (clipOffset \\ ex) - ex.
	^aFillStyle
		displayOnPort: clippedPort
		offsetBy: additionalOffset

]

{ #category : #testing }
FormCanvas >> isShadowDrawing [
	^ self shadowColor notNil
]

{ #category : #testing }
FormCanvas >> isVisible: aRectangle [
	"Optimization"
	(aRectangle right + origin x) < clipRect left	ifTrue: [^ false].
	(aRectangle left + origin x) > clipRect right	ifTrue: [^ false].
	(aRectangle bottom + origin y) < clipRect top	ifTrue: [^ false].
	(aRectangle top + origin y) > clipRect bottom	ifTrue: [^ false].
	^ true

]

{ #category : #drawing }
FormCanvas >> line: pt1 to: pt2 brushForm: brush [
	| offset |
	offset := origin.
	self setPaintColor: Color black.
	port sourceForm: brush; fillColor: nil;
		sourceRect: brush boundingBox;
		colorMap: (brush colormapIfNeededFor: form);
		drawFrom: (pt1 + offset) to: (pt2 + offset)
]

{ #category : #drawing }
FormCanvas >> line: pt1 to: pt2 width: w color: c [
	| offset |
	offset := origin - (w // 2) asPoint.
	self setFillColor: c.
	port width: w; height: w;
		drawFrom: (pt1 + offset) to: (pt2 + offset)
]

{ #category : #accessing }
FormCanvas >> origin [
	"Return the current origin for drawing operations"
	^ origin
]

{ #category : #drawing }
FormCanvas >> paragraph: para bounds: bounds color: c [

	| scanner |
	self setPaintColor: c.
	scanner := (port clippedBy: (bounds translateBy: origin)) displayScannerFor: para
		foreground: (self shadowColor ifNil:[c]) background: Color transparent
		ignoreColorChanges: self shadowColor notNil.
	para displayOn: (self copyClipRect: bounds) using: scanner at: origin+ bounds topLeft.

]

{ #category : #drawing }
FormCanvas >> point: pt color: c [

	form colorAt: (pt + origin) put: c.
]

{ #category : #private }
FormCanvas >> portClass [
	"Return the class used as port"
	^BitBlt asGrafPort
]

{ #category : #copying }
FormCanvas >> postCopy [
	"Let the copy have its own grafPort."

	super postCopy.
	self resetGrafPort

]

{ #category : #printing }
FormCanvas >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll:' on: '; print: form.
]

{ #category : #private }
FormCanvas >> privateClipRect [

	^clipRect
]

{ #category : #private }
FormCanvas >> privatePort [

	^port
]

{ #category : #private }
FormCanvas >> privateWarp: aForm transform: aTransform at: extraOffset sourceRect: sourceRect cellSize: cellSize [
	"Warp the given using the appropriate transform and offset."
	| globalRect sourceQuad warp tfm |
	tfm := aTransform.
	globalRect := tfm localBoundsToGlobal: sourceRect.
	sourceQuad := (tfm sourceQuadFor: globalRect) collect:[:p| p - sourceRect topLeft].
	extraOffset ifNotNil:[globalRect := globalRect translateBy: extraOffset].
     warp := (WarpBlt toForm: port destForm)
                combinationRule: Form paint;
                sourceQuad: sourceQuad destRect: (globalRect origin corner: globalRect corner+(1@1));
                clipRect: port clipRect.
	warp cellSize: cellSize.
	warp sourceForm: aForm.
	warp warpBits
]

{ #category : #drawing }
FormCanvas >> render: anObject [
	"Do some 3D operations with the object if possible"
	^self asBalloonCanvas render: anObject
]

{ #category : #initialization }
FormCanvas >> reset [

	origin := 0@0.							"origin of the top-left corner of this cavas"
	form ifNil:[
		"This code path will never be executed after the changes in setForm:
		are installed, so it can be removed in due time."
		clipRect := (0@0 corner: 10000@10000).
	] ifNotNil:[
		clipRect := (0@0 corner: form extent).	"default clipping rectangle"
	].
	self shadowColor: nil.
]

{ #category : #private }
FormCanvas >> resetGrafPort [
	"Private! Create a new grafPort for a new copy."

	port := self portClass toForm: form.
	port clipRect: clipRect.

]

{ #category : #private }
FormCanvas >> setClearColor: aColor [
	"Install a new clear color - e.g., a color is used for clearing the background"
	| clearColor |
	clearColor := aColor ifNil:[Color transparent].
	clearColor isColor ifFalse:[
		(clearColor isKindOf: InfiniteForm) ifFalse:[^self error:'Cannot install color'].
		^port fillPattern: clearColor; combinationRule: Form over].
	"Okay, so clearColor really *is* a color"
	port sourceForm: nil.
	port combinationRule: Form over.
	port fillPattern: clearColor.
	self depth = 8 ifTrue:[
		"Use a stipple pattern"
		port fillColor: (form balancedPatternFor: clearColor)].

]

{ #category : #private }
FormCanvas >> setFillColor: aColor [
	"Install a new color used for filling."
	| screen patternWord fillColor |
	fillColor := self shadowColor ifNil:[aColor].
	fillColor ifNil:[fillColor := Color transparent].
	fillColor isColor ifFalse:[
		(fillColor isKindOf: InfiniteForm) ifFalse:[^self error:'Cannot install color'].
		^port fillPattern: fillColor; combinationRule: Form over].
	"Okay, so fillColor really *is* a color"
	port sourceForm: nil.
	fillColor isTranslucent ifFalse:[
		port combinationRule: Form over.
		port fillPattern: fillColor.
		self depth = 8 ifTrue:[
			"In 8 bit depth it's usually a good idea to use a stipple pattern"
			port fillColor: (form balancedPatternFor: fillColor)].
		^self].
	"fillColor is some translucent color"

	self depth > 8 ifTrue:[
		"BitBlt setup for alpha masked transfer"
		port fillPattern: fillColor.
		self depth = 16
			ifTrue:[port alphaBits: fillColor privateAlpha; combinationRule: 30]
			ifFalse:[port combinationRule: Form blend].
		^self].
	"Can't represent actual transparency -- use stipple pattern"
	screen := Color translucentMaskFor: fillColor alpha depth: self depth.
	patternWord := form pixelWordFor: fillColor.
	port fillPattern: (screen collect: [:maskWord | maskWord bitAnd: patternWord]).
	port combinationRule: Form paint.

]

{ #category : #private }
FormCanvas >> setForm: aForm [

	form := aForm.
	port := self portClass toForm: form.
	self reset.
]

{ #category : #private }
FormCanvas >> setOrigin: aPoint clipRect: aRectangle [

	origin := aPoint.
	clipRect := aRectangle.
	port clipRect: aRectangle.

]

{ #category : #private }
FormCanvas >> setPaintColor: aColor [
	"Install a new color used for filling."
	| paintColor screen patternWord |
	paintColor := self shadowColor ifNil:[aColor].
	paintColor ifNil:[paintColor := Color transparent].
	paintColor isColor ifFalse:[
		(paintColor isKindOf: InfiniteForm) ifFalse:[^self error:'Cannot install color'].
		^port fillPattern: paintColor; combinationRule: Form paint].
	"Okay, so paintColor really *is* a color"
	port sourceForm: nil.
	(paintColor isTranslucent) ifFalse:[
		port fillPattern: paintColor.
		port combinationRule: Form paint.
		self depth = 8 ifTrue:[
			port fillColor: (form balancedPatternFor: paintColor)].
		^self].
	"paintColor is translucent color"

	self depth > 8 ifTrue:[
		"BitBlt setup for alpha mapped transfer"
		port fillPattern: paintColor.
		self depth = 16
			ifTrue:[port alphaBits: paintColor privateAlpha; combinationRule: 31]
			ifFalse:[port combinationRule: Form blend].
		^self].

	"Can't represent actual transparency -- use stipple pattern"
	screen := Color translucentMaskFor: paintColor alpha depth: self depth.
	patternWord := form pixelWordFor: paintColor.
	port fillPattern: (screen collect: [:maskWord | maskWord bitAnd: patternWord]).
	port combinationRule: Form paint

]

{ #category : #accessing }
FormCanvas >> shadowColor [
	^shadowColor
]

{ #category : #accessing }
FormCanvas >> shadowColor: aColor [
	shadowColor := aColor
]

{ #category : #other }
FormCanvas >> showAt: pt [

	^ form displayAt: pt
]

{ #category : #other }
FormCanvas >> showAt: pt invalidRects: updateRects [
	| blt |
	blt := (BitBlt toForm: Display)
		sourceForm: form;
		combinationRule: Form over.
	updateRects do:
		[:rect |
		blt sourceRect: rect;
			destOrigin: rect topLeft + pt;
			copyBits]
]

{ #category : #'drawing-images' }
FormCanvas >> stencil: stencilForm at: aPoint sourceRect: sourceRect color: aColor [
	"Flood this canvas with aColor wherever stencilForm has non-zero pixels"
	self setPaintColor: aColor.
	port colorMap: stencilForm maskingMap.
	port stencil: stencilForm
		at: aPoint + origin
		sourceRect: sourceRect.
]

{ #category : #'drawing-support' }
FormCanvas >> transformBy: aDisplayTransform clippingTo: aClipRect during: aBlock	 smoothing: cellSize [

	"Note: This method has been originally copied from TransformationMorph."
	| innerRect patchRect sourceQuad warp start subCanvas |
	(aDisplayTransform isPureTranslation) ifTrue:[
		^aBlock value: (self copyOffset: aDisplayTransform offset negated truncated
							clipRect: aClipRect)
	].
	"Prepare an appropriate warp from patch to innerRect"
	innerRect := aClipRect.
	patchRect := (aDisplayTransform globalBoundsToLocal: innerRect) truncated.
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
		subCanvas := self class extent: patchRect extent depth: self depth.
		i=1	ifTrue: [subCanvas shadowColor: Color black.
					warp combinationRule: Form erase]
			ifFalse: [self isShadowDrawing ifTrue:
					[subCanvas shadowColor: self shadowColor].
				warp combinationRule: (self depth = 32
					ifTrue: [Form blendAlphaScaled]
					ifFalse: [Form paint])].
		subCanvas
			translateBy: patchRect topLeft negated
			during: aBlock.
		warp sourceForm: subCanvas form; warpBits.
		warp sourceForm: nil.  subCanvas := nil "release space for next loop"]

]

{ #category : #'drawing-support' }
FormCanvas >> translateBy: delta during: aBlock [
	"Set a translation only during the execution of aBlock."
	^aBlock value: (self copyOffset: delta)
]

{ #category : #'drawing-support' }
FormCanvas >> translateTo: newOrigin clippingTo: aRectangle during: aBlock [
	"Set a new origin and clipping rectangle only during the execution of aBlock."
	aBlock value: (self copyOrigin: newOrigin clipRect: aRectangle)
]

{ #category : #other }
FormCanvas >> warpFrom: sourceQuad toRect: destRect [
        ^ (WarpBlt toForm: port destForm)
                combinationRule: Form paint;
                sourceQuad: sourceQuad destRect: (destRect translateBy: origin);
                clipRect: clipRect
]

{ #category : #'drawing-images' }
FormCanvas >> warpImage: aForm transform: aTransform at: extraOffset sourceRect: sourceRect cellSize: cellSize [
	"Warp the given using the appropriate transform and offset."
	| tfm |
	tfm := (MatrixTransform2x3 withOffset: origin) composedWithLocal: aTransform.
	^self privateWarp: aForm transform: tfm at: extraOffset sourceRect: sourceRect cellSize: cellSize
]
