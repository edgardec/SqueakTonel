Class {
	#name : #GrafPort,
	#superclass : #BitBlt,
	#instVars : [
		'alpha',
		'fillPattern',
		'lastFont',
		'lastFontForegroundColor',
		'lastFontBackgroundColor'
	],
	#category : #'Morphic-Support'
}

{ #category : #accessing }
GrafPort >> alphaBits: a [
	alpha := a
]

{ #category : #copying }
GrafPort >> clippedBy: aRectangle [
	^ self copy clipBy: aRectangle
]

{ #category : #accessing }
GrafPort >> contentsOfArea: aRectangle into: aForm [
	destForm 
		displayOn: aForm 
		at:  aRectangle origin
		clippingBox: (0@0 extent: aRectangle extent).
	^aForm
]

{ #category : #copying }
GrafPort >> copyBits [
	"Override copybits to do translucency if desired"

	(combinationRule >= 30 and: [combinationRule <= 31]) 
		ifTrue: [
			self copyBitsTranslucent: (alpha ifNil: [255])]
		ifFalse: [super copyBits]
]

{ #category : #accessing }
GrafPort >> displayScannerFor: para foreground: foreColor background: backColor ignoreColorChanges: shadowMode [
	^ (DisplayScanner new text: para text textStyle: para textStyle
			foreground: foreColor background: backColor fillBlt: self
			ignoreColorChanges: shadowMode)
		setPort: self shallowCopy

]

{ #category : #'drawing support' }
GrafPort >> fillOval: rect [
	| centerX centerY nextY yBias xBias outer nextOuterX |
	rect area <= 0 ifTrue: [^ self].
	height := 1.
	yBias := rect height odd ifTrue: [0] ifFalse: [-1].
	xBias := rect width odd ifTrue: [1] ifFalse: [0].
	centerX := rect center x.
	centerY := rect center y.
	outer := EllipseMidpointTracer new on: rect.
	nextY := rect height // 2.
	[nextY > 0] whileTrue:[
		nextOuterX := outer stepInY.
		width := (nextOuterX bitShift: 1) + xBias.
		destX := centerX - nextOuterX.
		destY := centerY - nextY.
		self copyBits.
		destY := centerY + nextY + yBias.
		self copyBits.
		nextY := nextY - 1.
	].
	destY := centerY.
	height := 1 + yBias.
	width := rect width.
	destX := rect left.
	self copyBits.

]

{ #category : #accessing }
GrafPort >> fillPattern: anObject [
	fillPattern := anObject.
	self fillColor: anObject.
]

{ #category : #'drawing support' }
GrafPort >> fillRect: rect offset: aPoint [
	"The offset is really just for stupid InfiniteForms."
	| fc |
	fillPattern class == InfiniteForm ifTrue:[
		fc := halftoneForm.
		self fillColor: nil.
		fillPattern displayOnPort: ((self clippedBy: rect) colorMap: nil) at: aPoint.
		halftoneForm := fc.
		^self].

	destX := rect left.
	destY := rect top.
	sourceX := 0.
	sourceY := 0.
	width := rect width.
	height := rect height.
	self copyBits.
]

{ #category : #'drawing support' }
GrafPort >> fillRoundRect: aRectangle radius: radius [
	| nextY outer nextOuterX ovalDiameter rectExtent rectOffset rectX rectY rectWidth rectHeight ovalRadius ovalRect |
	aRectangle area <= 0 ifTrue: [^ self].
	ovalDiameter := (radius * 2) asPoint min: aRectangle extent.
	(ovalDiameter x <= 0 or:[ovalDiameter y <= 0]) ifTrue:[
		^self fillRect: aRectangle offset: 0@0.
	].
	"force diameter to be even - this simplifies lots of stuff"
	ovalRadius := (ovalDiameter x // 2) @ (ovalDiameter y // 2).
	(ovalRadius x <= 0 or:[ovalRadius y <= 0]) ifTrue:[
		^self fillRect: aRectangle offset: 0@0.
	].
	ovalDiameter := ovalRadius * 2.
	rectExtent := aRectangle extent - ovalDiameter.
	rectWidth := rectExtent x.
	rectHeight := rectExtent y.
	rectOffset := aRectangle origin + ovalRadius.
	rectX := rectOffset x.
	rectY := rectOffset y.

	ovalRect := ovalRadius negated extent: ovalDiameter.

	height := 1.
	outer := EllipseMidpointTracer new on: ovalRect.
	nextY := ovalRadius y.
	"upper and lower portions of round rect"
	[nextY > 0] whileTrue:[
		nextOuterX := outer stepInY.
		width := nextOuterX * 2 + rectWidth.
		destX := rectX - nextOuterX.
		destY := rectY - nextY.
		self copyBits.
		destY := rectY + nextY + rectHeight - 1.
		self copyBits.
		nextY := nextY - 1.
	].
	destX := aRectangle left.
	destY := rectOffset y.
	height := rectHeight.
	width := aRectangle width.
	self copyBits.

]

{ #category : #'drawing support' }
GrafPort >> frameOval: rect borderWidth: borderWidth [
	| centerX centerY nextY yBias xBias wp outer inner nextOuterX nextInnerX fillAlpha |
	rect area <= 0 ifTrue: [^ self].
	height := 1.
	wp := borderWidth asPoint.
	yBias := rect height odd ifTrue: [0] ifFalse: [-1].
	xBias := rect width odd ifTrue: [1] ifFalse: [0].
	centerX := rect center x.
	centerY := rect center y.
	outer := EllipseMidpointTracer new on: rect.
	inner := EllipseMidpointTracer new on: (rect insetBy: wp).
	nextY := rect height // 2.
	1 to: (wp y min: nextY) do:[:i|
		nextOuterX := outer stepInY.
		width := (nextOuterX bitShift: 1) + xBias.
		destX := centerX - nextOuterX.
		destY := centerY - nextY.
		self copyBits.
		destY := centerY + nextY + yBias.
		self copyBits.
		nextY := nextY - 1.
	].
	[nextY > 0] whileTrue:[
		nextOuterX := outer stepInY.
		nextInnerX := inner stepInY.
		destX := centerX - nextOuterX.
		destY := centerY - nextY.
		width := nextOuterX - nextInnerX.
		self copyBits.
		destX := centerX + nextInnerX + xBias.
		self copyBits.
		destX := centerX - nextOuterX.
		destY := centerY + nextY + yBias.
		self copyBits.
		destX := centerX + nextInnerX + xBias.
		self copyBits.
		nextY := nextY - 1.
	].
	destY := centerY.
	height := 1 + yBias.
	width := wp x.
	destX := rect left.
	self copyBits.
	destX := rect right - wp x.
	self copyBits.

]

{ #category : #'drawing support' }
GrafPort >> frameRect: rect borderWidth: borderWidth [
	sourceX := 0.
	sourceY := 0.
	(rect areasOutside: (rect insetBy: borderWidth)) do:
		[:edgeStrip | self destRect: edgeStrip; copyBits].

]

{ #category : #'drawing support' }
GrafPort >> frameRectBottom: rect height: h [

	destX := rect left + 1.
	destY := rect bottom - 1.
	width := rect width - 2.
	height := 1.
	1 to: h do: [:i |
		self copyBits.
		destX := destX + 1.
		destY := destY - 1.
		width := width - 2].

]

{ #category : #'drawing support' }
GrafPort >> frameRectRight: rect width: w [

	width := 1.
	height := rect height - 1.
	destX := rect right - 1.
	destY := rect top + 1.
	1 to: w do: [:i |
		self copyBits.
		destX := destX - 1.
		destY := destY + 1.
		height := height - 2].

]

{ #category : #'drawing support' }
GrafPort >> frameRoundRect: aRectangle radius: radius borderWidth: borderWidth [
	| nextY outer nextOuterX ovalDiameter rectExtent rectOffset rectX rectY rectWidth rectHeight ovalRadius ovalRect innerRadius innerDiameter innerRect inner nextInnerX wp |
	aRectangle area <= 0 ifTrue: [^ self].
	ovalDiameter := (radius * 2) asPoint min: aRectangle extent.
	(ovalDiameter x <= 0 or:[ovalDiameter y <= 0]) ifTrue:[
		^self fillRect: aRectangle offset: 0@0.
	].
	"force diameter to be even - this simplifies lots of stuff"
	ovalRadius := (ovalDiameter x // 2) @ (ovalDiameter y // 2).
	(ovalRadius x <= 0 or:[ovalRadius y <= 0]) ifTrue:[
		^self fillRect: aRectangle offset: 0@0.
	].
	wp := borderWidth asPoint.
	ovalDiameter := ovalRadius * 2.
	innerRadius := ovalRadius - borderWidth max: 0@0.
	innerDiameter := innerRadius * 2.

	rectExtent := aRectangle extent - ovalDiameter.
	rectWidth := rectExtent x.
	rectHeight := rectExtent y.

	rectOffset := aRectangle origin + ovalRadius.
	rectX := rectOffset x.
	rectY := rectOffset y.

	ovalRect := 0@0 extent: ovalDiameter.
	innerRect := 0@0 extent: innerDiameter.

	height := 1.
	outer := EllipseMidpointTracer new on: ovalRect.
	inner := EllipseMidpointTracer new on: innerRect.

	nextY := ovalRadius y.

	1 to: (wp y min: nextY) do:[:i|
		nextOuterX := outer stepInY.
		width := nextOuterX * 2 + rectWidth.
		destX := rectX - nextOuterX.
		destY := rectY - nextY.
		self copyBits.
		destY := rectY + nextY + rectHeight - 1.
		self copyBits.
		nextY := nextY - 1.
	].
	[nextY > 0] whileTrue:[
		nextOuterX := outer stepInY.
		nextInnerX := inner stepInY.
		destX := rectX - nextOuterX.
		destY := rectY - nextY.
		width := nextOuterX - nextInnerX.
		self copyBits.
		destX := rectX + nextInnerX + rectWidth.
		self copyBits.
		destX := rectX - nextOuterX.
		destY := rectY + nextY + rectHeight-1.
		self copyBits.
		destX := rectX + nextInnerX + rectWidth.
		self copyBits.
		nextY := nextY - 1.
	].

	destX := aRectangle left.
	destY := rectOffset y.
	height := rectHeight.
	width := wp x.
	self copyBits.
	destX := aRectangle right - width.
	self copyBits.
	innerRadius y = 0 ifTrue:[
		destX := aRectangle left + wp x.
		destY := rectY.
		width := rectWidth.
		height := wp y - ovalRadius y.
		self copyBits.
		destY := aRectangle bottom - wp y.
		self copyBits.
	].
]

{ #category : #'drawing support' }
GrafPort >> image: aForm at: aPoint sourceRect: sourceRect rule: rule [
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."

	sourceForm := aForm.
	combinationRule := rule.
	self sourceRect: sourceRect.
	self destOrigin: aPoint.
	self copyBits
]

{ #category : #'drawing support' }
GrafPort >> image: aForm at: aPoint sourceRect: sourceRect rule: rule alpha: sourceAlpha [
	"Draw the portion of the given Form defined by sourceRect at the given point using the given BitBlt combination rule."

	sourceForm := aForm.
	combinationRule := rule.
	self sourceRect: sourceRect.
	self destOrigin: aPoint.
	self copyBitsTranslucent: (alpha := (sourceAlpha * 255) truncated min: 255 max: 0).
]

{ #category : #private }
GrafPort >> installStrikeFont: aStrikeFont [

	^ self installStrikeFont: aStrikeFont foregroundColor: (lastFontForegroundColor ifNil: [Color black]) backgroundColor: (lastFontBackgroundColor ifNil: [Color transparent]).

]

{ #category : #private }
GrafPort >> installStrikeFont: aStrikeFont foregroundColor: foregroundColor backgroundColor: backgroundColor [
	super installStrikeFont: aStrikeFont foregroundColor: foregroundColor backgroundColor: backgroundColor.
	aStrikeFont glyphs depth = 1 ifTrue: [
		alpha := foregroundColor privateAlpha.
		"dynamically switch between blend modes to support translucent text"
		"To handle the transition from TTCFont to StrikeFont, rule 34 must be taken into account."
		alpha = 255 ifTrue:[
			combinationRule = 30 ifTrue: [combinationRule := Form over].
			combinationRule = 31 ifTrue: [combinationRule := Form paint].
			combinationRule = 34 ifTrue: [combinationRule := Form paint].
			combinationRule = 41 ifTrue: [combinationRule := Form paint]. "41 is  SPRmode"
		] ifFalse:[
			combinationRule = Form over ifTrue: [combinationRule := 30].
			combinationRule = Form paint ifTrue: [combinationRule := 31].
			combinationRule = 34 ifTrue: [combinationRule := 31].
			combinationRule = 41 ifTrue: [combinationRule := 31]. "41 is SPR mode"
		]
	].
	lastFont := aStrikeFont.
	lastFontForegroundColor := foregroundColor.
	lastFontBackgroundColor := backgroundColor.

]

{ #category : #private }
GrafPort >> installTTCFont: aTTCFont [

	^ self installTTCFont: aTTCFont foregroundColor: (lastFontForegroundColor ifNil: [Color black]) backgroundColor: (lastFontBackgroundColor ifNil: [Color transparent]).

]

{ #category : #private }
GrafPort >> installTTCFont: aTTCFont foregroundColor: foregroundColor backgroundColor: backgroundColor [

	super installTTCFont: aTTCFont foregroundColor: foregroundColor backgroundColor: backgroundColor.
	lastFont := aTTCFont.
	lastFontForegroundColor := foregroundColor.
	lastFontBackgroundColor := backgroundColor.

]

{ #category : #private }
GrafPort >> lastFont [

	^ lastFont.

]

{ #category : #accessing }
GrafPort >> lastFontForegroundColor [
	^lastFontForegroundColor
]

{ #category : #'drawing support' }
GrafPort >> stencil: stencilForm at: aPoint sourceRect: aRect [
	"Paint using aColor wherever stencilForm has non-zero pixels"
	self sourceForm: stencilForm;
		destOrigin: aPoint;
		sourceRect: aRect.
	self copyBits
]
