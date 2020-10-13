"
Decodes commands encoded by MREncoder, and draws them onto a canvas.
"
Class {
	#name : #CanvasDecoder,
	#superclass : #Object,
	#instVars : [
		'drawingCanvas',
		'clipRect',
		'transform',
		'connection',
		'fonts'
	],
	#classVars : [
		'CachedForms',
		'DecodeTable'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
CanvasDecoder class >> connection: aConnection [ 
	^(self new)
		connection: aConnection;
		yourself
]

{ #category : #decoding }
CanvasDecoder class >> decodeColor: string [
	| rgb a rgb1 rgb2 |
	rgb1 := string getInteger32: 1.
	rgb2 := string getInteger32: 5.
	a := string getInteger32: 9.
	rgb := rgb2 << 16 + rgb1.

	a < 255
		ifTrue: [ ^TranslucentColor basicNew setRgb: rgb  alpha: a/255.0 ]
		ifFalse: [ ^Color basicNew setRGB: rgb ]
]

{ #category : #decoding }
CanvasDecoder class >> decodeFillStyle: string [

	^DataStream unStream: string
]

{ #category : #decoding }
CanvasDecoder class >> decodeFont: fontString [

	^StrikeFont decodedFromRemoteCanvas: fontString.

]

{ #category : #decoding }
CanvasDecoder class >> decodeFontSet: fontString [

	^ StrikeFontSet decodedFromRemoteCanvas: fontString

]

{ #category : #decoding }
CanvasDecoder class >> decodeImage: string [
	| bitsStart depth width height bits rs numColors colorArray |

	bitsStart := string indexOf: $|.
	bitsStart = 0 ifTrue: [^nil].
	rs := ReadStream on: string.
	rs peek == $C ifTrue: [
		rs next.
		numColors := Integer readFromString: (rs upTo: $,).
		colorArray := Array new: numColors.
		1 to: numColors do: [ :i |
			colorArray at: i put: (self decodeColor: (rs next: 12))
		].
	].
	depth := Integer readFromString: (rs upTo: $,).
	width :=  Integer readFromString: (rs upTo: $,).
	height :=  Integer readFromString: (rs upTo: $|).

	bits := Bitmap newFromStream: rs upToEnd asByteArray readStream.

	colorArray ifNil: [
		^Form extent: width@height depth: depth bits: bits
	].
	^(ColorForm extent: width@height depth: depth bits: bits)
		colors: colorArray

]

{ #category : #decoding }
CanvasDecoder class >> decodeInteger: string [
	^Integer readFromString: string
]

{ #category : #decoding }
CanvasDecoder class >> decodePoint: string [
	| x y |
	x := string getInteger32: 1.
	y := string getInteger32: 5.

	^x@y
]

{ #category : #decoding }
CanvasDecoder class >> decodePoints: aString [
	^(aString findTokens: '|') asArray collect: [ :encPoint | self decodePoint: encPoint ]
]

{ #category : #decoding }
CanvasDecoder class >> decodeRectangle: string [
	| x y cornerX cornerY |
	x := string getInteger32: 1.
	y := string getInteger32: 5.
	cornerX := string getInteger32: 9.
	cornerY := string getInteger32: 13.

	^x@y corner: cornerX@cornerY
]

{ #category : #decoding }
CanvasDecoder class >> decodeTTCFont: fontString [

	"Decode a string that consists of <familyName> <pointSize> <emphasis> (e.g. 'ComicSansMS 12 0') into a proper instance."

	| first second |
	first := fontString indexOf: $  startingAt: 1.
	second := fontString indexOf: $  startingAt: first + 1.

	(first ~= 0 and: [second ~= 0]) ifTrue: [
		^ TTCFont familyName: (fontString copyFrom: 1 to: (first - 1))
			size: (fontString copyFrom: first + 1 to: second - 1) asNumber
				emphasized: (fontString copyFrom: second + 1 to: fontString size) asNumber.
	].

	^ TextStyle defaultFont.

]

{ #category : #decoding }
CanvasDecoder class >> decodeTransform: transformEnc [
	"decode an encoded transform"
	^DisplayTransform fromRemoteCanvasEncoding: transformEnc
]

{ #category : #'decode table modification' }
CanvasDecoder class >> decodeVerb: verb toSelector: selector [
	"verb is a single character which will be ferformed by my instances using selector"
	DecodeTable at: verb asciiValue + 1 put: selector.	
]

{ #category : #'class initialization' }
CanvasDecoder class >> initialize [
	"CanvasDecoder initialize"
	"Set up my cache and decode table if necessary."
	CachedForms ifNil: [CachedForms := Array new: 100].
	DecodeTable ifNotNil: [ ^self ].

	DecodeTable := Array new: 128.
	#((codeClip setClip:)
	(codeTransform setTransform:)
	(codeText drawText:)
	(codeLine drawLine:)
	(codeRect drawRect:)
	(codeBalloonRect drawBalloonRect:)
	(codeBalloonOval drawBalloonOval:)
	(codeInfiniteFill drawInfiniteFill:)
	(codeOval drawOval:)
	(codeImage drawImage:)
	(codeReleaseCache releaseImage:)
	(codePoly drawPoly:)
	(codeStencil drawStencil:)
	(codeForce forceToScreen:)
	(codeFont addFontToCache:)
	(codeFontSet addFontSetToCache:)
	(codeMultiText drawMultiText:) 
	(codeTTCFont addTTCFontToCache:)
	(codeExtentDepth extentDepth:)
	(codeShadowColor shadowColor:))
		do: [ :arr |
			(DecodeTable at: ((CanvasEncoder perform: arr first) asciiValue + 1)) ifNotNil: [self error: 'duplicated code'].
			DecodeTable
				at: ((CanvasEncoder perform: arr first) asciiValue + 1)
				put: arr second
		].

]

{ #category : #'class initialization' }
CanvasDecoder class >> reinitialize [
	"CanvasDecoder reinitialize"
	"Set up my cache and decode table, removing old contents."
	CachedForms := nil.
	DecodeTable := nil.
	self initialize.

]

{ #category : #decoding }
CanvasDecoder >> addFontSetToCache: command [

	| index font |
	index := self class decodeInteger: command second.
	font := self class decodeFontSet: command third.

	index > fonts size ifTrue: [
		| newFonts |
		newFonts  := Array new: index.
		newFonts replaceFrom: 1 to: fonts size with: fonts.
		fonts := newFonts ].

	fonts at: index put: font

]

{ #category : #decoding }
CanvasDecoder >> addFontToCache: command [
	| index font |
	index := self class decodeInteger: command second.
	font := self class decodeFont: command third.

	index > fonts size ifTrue: [
		| newFonts |
		newFonts  := Array new: index.
		newFonts replaceFrom: 1 to: fonts size with: fonts.
		fonts := newFonts ].

	fonts at: index put: font
]

{ #category : #decoding }
CanvasDecoder >> addTTCFontToCache: command [
	| index font |
	index := self class decodeInteger: command second.
	font := self class decodeTTCFont: command third.

	index > fonts size ifTrue: [
		| newFonts |
		newFonts  := Array new: index.
		newFonts replaceFrom: 1 to: fonts size with: fonts.
		fonts := newFonts ].

	fonts at: index put: font.

]

{ #category : #network }
CanvasDecoder >> connection: aStringSocket [
	"set this terminal to talk over the given socket"
	connection := aStringSocket
]

{ #category : #'shutting down' }
CanvasDecoder >> delete [
	connection ifNotNil: [ connection destroy ].
]

{ #category : #decoding }
CanvasDecoder >> drawBalloonOval: command [ 
	| aRectangle aFillStyle borderWidth borderColor |
	aRectangle := self class decodeRectangle: command second.
	aFillStyle := self class decodeFillStyle: command third.
	borderWidth := self class decodeInteger: command fourth.
	borderColor := self class decodeColor: (command fifth).
	self drawCommand: 
			[:c | 
			c asBalloonCanvas 
				fillOval: aRectangle
				fillStyle: aFillStyle
				borderWidth: borderWidth
				borderColor: borderColor]
]

{ #category : #decoding }
CanvasDecoder >> drawBalloonRect: command [ 
	| aRectangle aFillStyle |
	aRectangle := self class decodeRectangle: (command second).
	aFillStyle := self class decodeFillStyle: command third.
	self drawCommand: 
			[:c | 
			c asBalloonCanvas fillRectangle: aRectangle fillStyle: aFillStyle]
]

{ #category : #decoding }
CanvasDecoder >> drawCommand: aBlock [
	"call aBlock with the canvas it should actually draw on so that the clipping rectangle and transform are set correctly"
	drawingCanvas transformBy: transform clippingTo: clipRect during: aBlock
]

{ #category : #decoding }
CanvasDecoder >> drawImage: command [ 
	| image point sourceRect rule cacheID cacheNew previousImage |
	image := self class decodeImage: command second.
	point := self class decodePoint: command third.
	sourceRect := self class decodeRectangle: command fourth.
	rule := self class decodeInteger: command fifth.
	command size >= 7 
		ifTrue: 
			[false ifTrue: [self showSpaceUsed].	"debugging"
			cacheID := self class decodeInteger: (command sixth).
			cacheNew := (self class decodeInteger: command seventh) = 1.
			cacheID > 0 
				ifTrue: 
					[
					cacheNew 
						ifTrue: [CachedForms at: cacheID put: image]
						ifFalse: 
							[previousImage := CachedForms at: cacheID.
							image ifNil: [image := previousImage]
								ifNotNil: 
									[(previousImage notNil and: [image depth > 8]) 
										ifTrue: [image := previousImage addDeltasFrom: image].
									CachedForms at: cacheID put: image]]]].
	self drawCommand: 
			[:c | 
			c 
				image: image
				at: point
				sourceRect: sourceRect
				rule: rule]
]

{ #category : #decoding }
CanvasDecoder >> drawInfiniteFill: command [ 
	| aRectangle aFillStyle |
	aRectangle := self class decodeRectangle: (command second).
	aFillStyle := InfiniteForm with: (self class decodeImage: command third).
	self drawCommand: 
			[:c | 
			c asBalloonCanvas fillRectangle: aRectangle fillStyle: aFillStyle]
]

{ #category : #decoding }
CanvasDecoder >> drawLine: command [ 
	| verb pt1Enc pt2Enc widthEnc colorEnc pt1 pt2 width color |
	verb := command first.
	pt1Enc := command second.
	pt2Enc := command third.
	widthEnc := command fourth.
	colorEnc := command fifth.
""
	pt1 := self class decodePoint: pt1Enc.
	pt2 := self class decodePoint: pt2Enc.
	width := self class decodeInteger: widthEnc.
	color := self class decodeColor: colorEnc.
""
	self
		drawCommand: [:c | c
				line: pt1
				to: pt2
				width: width
				color: color]
]

{ #category : #decoding }
CanvasDecoder >> drawMultiText: command [

	| boundsEnc colorEnc  text bounds color fontIndexEnc fontIndex |

	text := WideString fromByteArray: (command at: 2) asByteArray.
	"text asByteArray printString displayAt: 800@0."
	"self halt."
	boundsEnc := command at: 3.
	fontIndexEnc := command at: 4.
	colorEnc := command at: 5.


	bounds := self class decodeRectangle: boundsEnc.
	fontIndex := self class decodeInteger: fontIndexEnc.
	color := self class decodeColor: colorEnc.

	self drawCommand: [ :c |
		c drawString: text in: bounds font: (fonts at: fontIndex) color: color ]

]

{ #category : #decoding }
CanvasDecoder >> drawOval: command [ 
	| verb rectEnc colorEnc borderWidthEnc borderColorEnc rect color borderWidth borderColor |
	verb := command first.
	rectEnc := command second.
	colorEnc := command third.
	borderWidthEnc := command fourth.
	borderColorEnc := command fifth.
	""
	rect := self class decodeRectangle: rectEnc.
	color := self class decodeColor: colorEnc.
	borderWidth := self class decodeInteger: borderWidthEnc.
	borderColor := self class decodeColor: borderColorEnc.
	""
	self
		drawCommand: [:c | c
				fillOval: rect
				color: color
				borderWidth: borderWidth
				borderColor: borderColor]
]

{ #category : #decoding }
CanvasDecoder >> drawPoly: command [ 
	| verticesEnc fillColorEnc borderWidthEnc borderColorEnc vertices fillColor borderWidth borderColor |
	fillColorEnc := command second.
	borderWidthEnc := command third.
	borderColorEnc := command fourth.
	verticesEnc := command copyFrom: 5 to: command size.
	fillColor := self class decodeColor: fillColorEnc.
	borderWidth := self class decodeInteger: borderWidthEnc.
	borderColor := self class decodeColor: borderColorEnc.
	vertices := verticesEnc collect: [:enc | self class decodePoint: enc].
	self drawCommand: 
			[:c | 
			c 
				drawPolygon: vertices
				color: fillColor
				borderWidth: borderWidth
				borderColor: borderColor]
]

{ #category : #decoding }
CanvasDecoder >> drawRect: command [ 
	| verb rectEnc fillColorEnc borderWidthEnc borderColorEnc rect fillColor borderWidth borderColor |
	verb := command first.
	rectEnc := command second.
	fillColorEnc := command third.
	borderWidthEnc := command fourth.
	borderColorEnc := command fifth.
	""
	rect := self class decodeRectangle: rectEnc.
	fillColor := self class decodeColor: fillColorEnc.
	borderWidth := self class decodeInteger: borderWidthEnc.
	borderColor := self class decodeColor: borderColorEnc.
	""
	self
		drawCommand: [:c | c
				frameAndFillRectangle: rect
				fillColor: fillColor
				borderWidth: borderWidth
				borderColor: borderColor]
]

{ #category : #decoding }
CanvasDecoder >> drawStencil: command [ 
	| stencilFormEnc locationEnc sourceRectEnc colorEnc stencilForm location sourceRect color |
	stencilFormEnc := command second.
	locationEnc := command third.
	sourceRectEnc := command fourth.
	colorEnc := command fifth.
	stencilForm := self class decodeImage: stencilFormEnc.
	location := self class decodePoint: locationEnc.
	sourceRect := self class decodeRectangle: sourceRectEnc.
	color := self class decodeColor: colorEnc.
	self drawCommand: 
			[:executor | 
			executor 
				stencil: stencilForm
				at: location
				sourceRect: sourceRect
				color: color]
]

{ #category : #decoding }
CanvasDecoder >> drawText: command [ 
	| boundsEnc colorEnc text bounds color fontIndexEnc fontIndex |
	text := command second.
	boundsEnc := command third.
	fontIndexEnc := command fourth.
	colorEnc := command fifth.
	bounds := self class decodeRectangle: boundsEnc.
	fontIndex := self class decodeInteger: fontIndexEnc.
	color := self class decodeColor: colorEnc.
	self drawCommand: 
			[:c | 
			c 
				drawString: text
				in: bounds
				font: (fonts at: fontIndex)
				color: color]
]

{ #category : #attributes }
CanvasDecoder >> drawingForm [
	"return the form that we are drawing on behind thescenes"
	^drawingCanvas form
]

{ #category : #decoding }
CanvasDecoder >> extentDepth: command [ 
	| depth extent |
	extent := self class decodePoint: (command second).
	depth := self class decodeInteger: (command third).
	drawingCanvas := FormCanvas extent: extent depth: depth
]

{ #category : #decoding }
CanvasDecoder >> forceToScreen: aCommand  withBlock: forceBlock [
	| region |
	region := self class decodeRectangle: aCommand second.
	forceBlock value: region.
]

{ #category : #initialization }
CanvasDecoder >> initialize [
	"set the canvas to draw on"
	drawingCanvas := FormCanvas extent: 100@100 depth: 16.
	clipRect := drawingCanvas extent.
	transform := MorphicTransform identity.

	fonts := Array new: 2.
]

{ #category : #decoding }
CanvasDecoder >> processCommand: command  onForceDo: forceBlock [
	"Decode the given string command and perform the required action.
	If the command is a forceToScreen command, also pass the forceBlock.
	The previous chained equality tests and conditionals have been replaced by a lookup table in my class variable DecodeTable, which is set in the class-side initialize method."
	| verb verbCode selector |
	command isEmpty ifTrue: [ ^self ].

	verb := command first.
	verbCode := verb first.

	selector := DecodeTable
		at: (verbCode asciiValue + 1)
		ifAbsent: [ self error: 'unknown command: ', verb ].

	"note: codeForce is the only odd one"
	^(selector == #forceToScreen:)
		ifTrue: [ self forceToScreen: command withBlock: forceBlock ]
		ifFalse: [ self perform: selector withArguments: { command } ]

]

{ #category : #network }
CanvasDecoder >> processIO [
	| command didSomething |
	connection ifNil: [ ^self ].
	connection processIO.
	didSomething := false.
	[ command := connection nextOrNil.  command notNil ] whileTrue: [
		didSomething := true.
		self processCommand: command ].

	^didSomething
]

{ #category : #network }
CanvasDecoder >> processIOOnForce: forceBlock [
	| command didSomething |
	connection ifNil: [ ^self ].
	connection processIO.
	didSomething := false.
	[ command := connection nextOrNil.  command notNil ] whileTrue: [
		didSomething := true.
		self processCommand: command onForceDo: forceBlock].

	^didSomething
]

{ #category : #decoding }
CanvasDecoder >> releaseImage: command [ 
	| cacheID |
	CachedForms ifNil: [^self].
	cacheID := self class decodeInteger: (command second).
	CachedForms at: cacheID put: nil
]

{ #category : #decoding }
CanvasDecoder >> setClip: command [ 
	| clipRectEnc |
	clipRectEnc := command second.
	clipRect := self class decodeRectangle: clipRectEnc
]

{ #category : #decoding }
CanvasDecoder >> setTransform: command [ 
	| transformEnc |
	transformEnc := command second.
	transform := self class decodeTransform: transformEnc
]

{ #category : #decoding }
CanvasDecoder >> shadowColor: command [

	drawingCanvas shadowColor: (
		command second = '0' ifTrue: [nil] ifFalse: [self class decodeColor: command second]
	)

]

{ #category : #decoding }
CanvasDecoder >> showSpaceUsed [

	| total |
	CachedForms ifNil: [^self].
	total := 0.
	CachedForms do: [ :each |
		each ifNotNil: [
			total := total + (each depth * each width * each height // 8).
		].
	].
	(total // 1024) printString,'     ',
	(Smalltalk garbageCollectMost // 1024) printString,'     ' displayAt: 0@0
]
