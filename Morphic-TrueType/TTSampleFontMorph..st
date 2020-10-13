"
An example for using TrueType fonts.
"
Class {
	#name : #TTSampleFontMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'font',
		'transform',
		'smoothing'
	],
	#category : #'Morphic-TrueType'
}

{ #category : #'instance creation' }
TTSampleFontMorph class >> font: aTTFontDescription [
	^self new font: aTTFontDescription
]

{ #category : #connectors }
TTSampleFontMorph class >> fontWithoutString: aTTFontDescription [
	^self new fontWithoutString: aTTFontDescription
]

{ #category : #menus }
TTSampleFontMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addUpdating: #getSmoothingLevel action: #nextSmoothingLevel.
]

{ #category : #'halos and balloon help' }
TTSampleFontMorph >> addOptionalHandlesTo: aHalo box: box [
	aHalo addHandleAt: box center color: Color magenta icon: nil on: #mouseDown send: #createSample to: self.
]

{ #category : #drawing }
TTSampleFontMorph >> areasRemainingToFill: aRectangle [
	^ Array with: aRectangle
]

{ #category : #'halos and balloon help' }
TTSampleFontMorph >> balloonHelpTextForHandle: aHandle [
	aHandle eventHandler firstMouseSelector == #createSample
		ifTrue:[^'Create a sample string'].
	^super balloonHelpTextForHandle: aHandle
]

{ #category : #testing }
TTSampleFontMorph >> canDrawBorder: aBorderStyle [
	^aBorderStyle style == #simple
]

{ #category : #updating }
TTSampleFontMorph >> changed [
	self invalidRect: (self fullBounds expandBy: 1)
]

{ #category : #private }
TTSampleFontMorph >> computeTransform [
	| fullExtent scale |
	fullExtent := font bounds extent * 16.
	scale := self extent asFloatPoint / fullExtent asFloatPoint.
	transform := MatrixTransform2x3 withScale: scale.
	transform := transform composedWithGlobal: (MatrixTransform2x3 withOffset: self position).
	^transform
]

{ #category : #menu }
TTSampleFontMorph >> createSample [
	self world primaryHand attachMorph: (TTSampleStringMorph font: font)
]

{ #category : #initialization }
TTSampleFontMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
TTSampleFontMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #drawing }
TTSampleFontMorph >> drawCharactersOn: aCanvas [
	| glyph origin r offset cy m |
	0 to: 255 do: [:i |
		glyph := font at: i.
		origin := font bounds extent * ((i \\ 16) @ (i // 16)).
		r := origin extent: font bounds extent.
		offset := r center - glyph bounds center.
		cy := glyph bounds center y.
		m := MatrixTransform2x3 withOffset: 0@cy.
		m := m composedWithLocal: (MatrixTransform2x3 withScale: 1 @ -1).
		m := m composedWithLocal: (MatrixTransform2x3 withOffset: 0 @ cy negated).
		m := m composedWithGlobal: (MatrixTransform2x3 withOffset: offset).
		aCanvas asBalloonCanvas preserveStateDuring: [:balloonCanvas |
			balloonCanvas transformBy: m.
			balloonCanvas drawGeneralBezierShape: glyph contours
					color: color
					borderWidth: 0
					borderColor: Color black.
		].
	].
]

{ #category : #drawing }
TTSampleFontMorph >> drawOn: aCanvas [
	| origin extent offset |
	(font isNil) 
		ifTrue:[^aCanvas frameRectangle: self bounds color: Color black].
	origin := self position asIntegerPoint.
	extent := self extent asIntegerPoint.
	0 to: 16 do:[:i|
		offset := (extent x * i // 16) @ (extent y * i // 16).
		aCanvas line: origin x @ (origin y + offset y) 
				to: (origin x + extent x) @ (origin y + offset y)
				width: self borderWidth color: self borderColor.
		aCanvas line: (origin x + offset x) @ origin y 
				to: (origin x + offset x) @ (origin y + extent y)
				width: self borderWidth color: self borderColor.
	].
	aCanvas asBalloonCanvas preserveStateDuring:[:balloonCanvas|
		balloonCanvas transformBy: self transform.
		balloonCanvas aaLevel: self smoothing.
		self drawCharactersOn: balloonCanvas.
	].
]

{ #category : #geometry }
TTSampleFontMorph >> extent: extentPoint [
	super extent: extentPoint.
	transform := nil.
]

{ #category : #accessing }
TTSampleFontMorph >> font [
	^ font
]

{ #category : #accessing }
TTSampleFontMorph >> font: aTTFontDescription [
	| morph |
	font := aTTFontDescription.
	morph := (TTSampleStringMorph font: font).
	morph extent: morph extent * 2.
	morph color: Color magenta.
	self addMorphCentered: morph.
	morph position: morph position x @ (self bounds bottom + 10).
	self privateFullMoveBy: self fullBounds origin negated.
]

{ #category : #connectors }
TTSampleFontMorph >> fontWithoutString: aTTFontDescription [
	font := aTTFontDescription.

]

{ #category : #menu }
TTSampleFontMorph >> getSmoothingLevel [
	"Menu support"
	smoothing = 1
		ifTrue: [^ 'turn on smoothing' translated].
	smoothing = 2
		ifTrue: [^ 'more smoothing' translated].
	smoothing = 4
		ifTrue: [^ 'turn off smoothing' translated]
]

{ #category : #connectors }
TTSampleFontMorph >> glyphAt: position [
	^font at: (self glyphIndexAt: position).
]

{ #category : #connectors }
TTSampleFontMorph >> glyphIndexAt: position [
	| offset |
	offset := (position adhereTo: (bounds insetBy: 1)) - bounds origin.
	offset := (offset asFloatPoint / bounds extent) * 16.
	offset := offset truncated.
	^offset y * 16 + offset x
]

{ #category : #initialization }
TTSampleFontMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	smoothing := 4.
	self extent: 300 @ 300
]

{ #category : #'rotate scale and flex' }
TTSampleFontMorph >> newTransformationMorph [
	^MatrixTransformMorph new
]

{ #category : #menu }
TTSampleFontMorph >> nextSmoothingLevel [
	smoothing = 1
		ifTrue: [smoothing := 2]
		ifFalse: [smoothing = 2
			ifTrue: [smoothing := 4]
			ifFalse: [smoothing = 4
				ifTrue: [smoothing := 1]]].
	self changed
]

{ #category : #initialize }
TTSampleFontMorph >> open [
	^self openInWorld
]

{ #category : #initialization }
TTSampleFontMorph >> openInWorld [
	HandMorph attach: self
]

{ #category : #geometry }
TTSampleFontMorph >> position: pos [
	super position: pos.
	transform := nil.
]

{ #category : #connectors }
TTSampleFontMorph >> printOn: aStream [
	aStream nextPutAll: 'TTSampleFont(';
		nextPutAll: font familyName;
		nextPut: $)
]

{ #category : #private }
TTSampleFontMorph >> privateMoveBy: delta [
	super privateMoveBy: delta.
	transform := nil.
]

{ #category : #connectors }
TTSampleFontMorph >> selectGlyph [
	| retval done |
	"Modal glyph selector"
	done := false.
	self on: #mouseDown send: #selectGlyphBlock:event:from: to: self withValue: [ :glyph | retval := glyph. done := true. ].
	self on: #keyStroke send: #value to: [ done := true ].
	[ done ] whileFalse: [ self world doOneCycle ].
	self on: #mouseDown send: nil to: nil.
	self on: #keyStroke send: nil to: nil.
	^retval
]

{ #category : #connectors }
TTSampleFontMorph >> selectGlyphAndSendTo: aBlock [
	self on: #mouseDown send: #selectGlyphBlock:event:from: to: self withValue: aBlock.
]

{ #category : #connectors }
TTSampleFontMorph >> selectGlyphBlock: aBlock event: evt from: me [
	aBlock value: (self glyphAt: evt position).

]

{ #category : #accessing }
TTSampleFontMorph >> smoothing [
	^ smoothing
]

{ #category : #accessing }
TTSampleFontMorph >> smoothing: aNumber [
	smoothing := aNumber.
	self changed
]

{ #category : #accessing }
TTSampleFontMorph >> transform [
	^transform ifNil:[self computeTransform].
]

{ #category : #copying }
TTSampleFontMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here. If they were in the 
	tree being copied, fix them up, otherwise point to the originals!!"

	super veryDeepFixupWith: deepCopier.
	font := deepCopier references at: font ifAbsent: [font]
]

{ #category : #copying }
TTSampleFontMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all,
	but shared. Warning!! Every instance variable defined in this class
	must be handled.  We must also implement veryDeepFixupWith:.
	See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	"font := font"
	transform := transform veryDeepCopyWith: deepCopier.
	smoothing := smoothing veryDeepCopyWith: deepCopier
]
