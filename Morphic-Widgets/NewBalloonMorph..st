"
A balloon is a bubble with an optional tail. It contains rich text, which describes something about its balloon-owner.
"
Class {
	#name : #NewBalloonMorph,
	#superclass : #Morph,
	#instVars : [
		'balloonOwner',
		'textMorph',
		'maximumWidth',
		'orientation',
		'hasTail'
	],
	#classVars : [
		'UseNewBalloonMorph'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'instance creation' }
NewBalloonMorph class >> string: str for: morph [

	^ self string: str for: morph corner: #bottomLeft
]

{ #category : #'instance creation' }
NewBalloonMorph class >> string: message for: morph corner: symbol [

	^ self new
		balloonOwner: morph;
		setText: message;
		orientation: symbol;
		yourself
]

{ #category : #preferences }
NewBalloonMorph class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the balloon''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the balloon''s border.' }.
		{ #color. 'Colors', 'Color for the balloon background.' }.
		{ #font. 'Fonts'. 'Font for balloon text if not overridden by text attributes.' }.
		{ #textColor. 'Colors'. 'Color for the balloon text if not overridden by text attributes.' }.
	}
]

{ #category : #preferences }
NewBalloonMorph class >> useNewBalloonMorph [

	<preference: 'Use new-style help balloon morphs'
		category: #Morphic
		description: 'The new-style help balloon morphs are improved for better reading quality and support rich text.'
		type: #Boolean>
	^ UseNewBalloonMorph ifNil: [true]
]

{ #category : #preferences }
NewBalloonMorph class >> useNewBalloonMorph: aBoolean [

	UseNewBalloonMorph := aBoolean.
]

{ #category : #updating }
NewBalloonMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setDefaultParameters.
]

{ #category : #accessing }
NewBalloonMorph >> balloonOwner [

	^ balloonOwner
]

{ #category : #accessing }
NewBalloonMorph >> balloonOwner: aMorph [

	balloonOwner == aMorph ifTrue: [^ self].
	balloonOwner := aMorph.
	self updateColorsForBalloonOwner.
]

{ #category : #geometry }
NewBalloonMorph >> bubbleBounds [

	^ self bounds insetBy: (0 @ self tailHeight corner: 0 @ self tailHeight)
]

{ #category : #geometry }
NewBalloonMorph >> bubbleInset [

	^ 5@2
]

{ #category : #accessing }
NewBalloonMorph >> color: aColor [

	super color: aColor.
	self updateGradient.
]

{ #category : #drawing }
NewBalloonMorph >> drawDropShadowOn: aCanvas [

	aCanvas 
		translateBy: self shadowOffset 
		during: [ :shadowCanvas |
			(shadowCanvas isVisible: self bubbleBounds) ifTrue: [
				self wantsRoundedCorners
					ifTrue: [shadowCanvas fillRoundRect: self bubbleBounds radius: self cornerRadius fillStyle: self shadowColor]
					ifFalse: [shadowCanvas fillRectangle: self bubbleBounds fillStyle: self shadowColor]].
				
				self hasTail ifTrue: [
					shadowCanvas
						drawPolygon: self verticesForTail
						fillStyle: self shadowColor]].


]

{ #category : #drawing }
NewBalloonMorph >> drawOn: aCanvas [

	self fillStyle isColor
		ifFalse: [self fillStyle isGradientFill
				ifTrue: [self fillStyle direction: 0 @ self height]].
	"Bubble."
	self wantsRoundedCorners
		ifTrue: [aCanvas
			frameAndFillRoundRect: self bubbleBounds
			radius: self cornerRadius fillStyle: self fillStyle borderWidth: self borderStyle width borderColor: self borderStyle color]
		ifFalse: [aCanvas
			frameAndFillRectangle: self bubbleBounds
			fillStyle: self fillStyle
			borderStyle: self borderStyle].

	"Tail."
	self hasTail ifTrue: [
		self verticesForTail in: [:points |
			| pixelOffset |
			pixelOffset := points first y < points second y
				ifFalse: [points first x < points second x
					ifTrue: [self borderStyle width negated @ self borderStyle width] "bottomLeft"
					ifFalse: [self borderStyle width @ self borderStyle width]] "bottomRight"
				ifTrue: [points first x < points second x
					ifTrue: [self borderStyle width negated @ self borderStyle width negated] "topLeft"
					ifFalse: [self borderStyle width @ self borderStyle width negated]]. "topRight"

			aCanvas
				drawPolygon: points
				fillStyle: self fillStyle.
			aCanvas
				line: points first
				to: points second + pixelOffset
				width: self borderStyle width
				color: self borderStyle color.
			aCanvas
				line: points first
				to: points third + pixelOffset
				width: self borderStyle width
				color: self borderStyle color]]
]

{ #category : #accessing }
NewBalloonMorph >> hasTail [

	^ hasTail ifNil: [true]
]

{ #category : #accessing }
NewBalloonMorph >> hasTail: aBoolean [

	hasTail := aBoolean.
]

{ #category : #initialization }
NewBalloonMorph >> initialize [

	super initialize.
	
	self setDefaultParameters.
	
	textMorph := TextMorph new
		wrapFlag: false;
		lock;
		yourself.
	
	self addMorph: textMorph.
]

{ #category : #accessing }
NewBalloonMorph >> maximumWidth [

	^ maximumWidth ifNil: [
		maximumWidth := (self balloonOwner balloonFont widthOf: $m) * Preferences maxBalloonHelpLineLength]
]

{ #category : #accessing }
NewBalloonMorph >> maximumWidth: anInteger [

	maximumWidth := anInteger.
]

{ #category : #'WiW support' }
NewBalloonMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^5		"Balloons are very front-like things"
]

{ #category : #geometry }
NewBalloonMorph >> move: targetPoint [

	self perform: self orientation asSimpleSetter with: targetPoint.
]

{ #category : #accessing }
NewBalloonMorph >> orientation [
	"Encodes the position of the tail. #topLeft, #topRight, #bottomLeft, #bottomRight"
	
	^ orientation
]

{ #category : #accessing }
NewBalloonMorph >> orientation: aSymbol [

	orientation := aSymbol.
	self changed.
]

{ #category : #initialization }
NewBalloonMorph >> popUp [
	"No tail. Centered in the balloon owner. Do not remove other balloon helps."
	
	| w |	
	self balloonOwner ifNil: [^ self].
	self balloonOwner isInWorld ifFalse: [^ self].
	
	w := self balloonOwner world.
	
	self hasTail: false.
	self center: self balloonOwner center.
	self bounds: (self bounds translatedToBeWithin: w bounds).
	
	w activeHand addBalloonHelp: self.
	self openInWorld.
]

{ #category : #initialization }
NewBalloonMorph >> popUpAt: point [
	"Do not remove other balloon helps."
	
	| w h |	
	self balloonOwner ifNil: [^ self].
	self balloonOwner isInWorld ifFalse: [^ self].
	
	w := self balloonOwner world.
	h := w activeHand.
	
	self hasTail: true.
		
	#(bottomLeft topLeft bottomRight topRight) detect: [:nextOrientation |
		| pointWithOffset |
		self orientation: nextOrientation.
		pointWithOffset := point + self tailOffset.
		self move: pointWithOffset.
		self bounds: (self bounds translatedToBeWithin: w bounds).
		(self bounds perform: self orientation) = pointWithOffset] ifNone: ["Keep last try."].	
	
	w activeHand addBalloonHelp: self.
	self openInWorld.
]

{ #category : #initialization }
NewBalloonMorph >> popUpAt: point forHand: aHand [
	"Pop up the receiver as balloon help for the given hand"

	#(bottomLeft topLeft bottomRight topRight) detect: [:nextOrientation |
		| pointWithOffset |
		self orientation: nextOrientation.
		pointWithOffset := point + self tailOffset.
		self move: pointWithOffset.
		self bounds: (self bounds translatedToBeWithin: aHand world bounds).
		(self bounds perform: self orientation) = pointWithOffset] ifNone: ["Keep last try."].
		
	aHand world addMorphFront: self.
	aHand resetBalloonHelp: self.
]

{ #category : #initialization }
NewBalloonMorph >> popUpFor: aMorph hand: aHand [
	"Pop up the receiver as balloon help for the given hand. Ignore if the hand does not touch the morph."

	(aMorph boundsInWorld containsPoint: aHand position)
		ifFalse: [^ self "Ignore"].
		
	self balloonOwner: aMorph.
	self popUpForHand: aHand.
]

{ #category : #initialization }
NewBalloonMorph >> popUpForHand: aHand [

	self popUpAt: aHand position forHand: aHand.
]

{ #category : #initialization }
NewBalloonMorph >> setDefaultParameters [

	self
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]);
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color r: 0.46 g: 0.46 b: 0.353]);
		color: (self userInterfaceTheme color ifNil: [Color r: 0.92 g: 0.92 b: 0.706]);
		hasDropShadow: (Preferences menuAppearance3d and: [self color isTranslucent not]);
		shadowOffset: 1@1;
		shadowColor: (self color muchDarker muchDarker alpha: 0.333);
		orientation: #bottomLeft;
		cornerStyle: (MenuMorph roundedMenuCorners ifTrue: [#rounded] ifFalse: [#square]).
]

{ #category : #initialization }
NewBalloonMorph >> setText: stringOrText [

	| text |
	text := stringOrText asText.

	text hasColorAttribute ifFalse: [
		text addAttribute: (TextColor color: (self userInterfaceTheme textColor ifNil: [Color black]))].
	text hasFontAttribute ifFalse: [
		text addAttribute: (TextFontReference toFont: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]))].
	
	self textMorph wrapFlag: false.
	self textMorph newContents: text.
	self textMorph fullBounds.
	
	(self maximumWidth > 0 and: [self textMorph width > self maximumWidth])
		ifTrue: [
			self textMorph
				wrapFlag: true;
				width: self maximumWidth].
		
	self updateLayout.
]

{ #category : #geometry }
NewBalloonMorph >> tailHeight [
	
	^ 8
]

{ #category : #geometry }
NewBalloonMorph >> tailOffset [

	^ (Dictionary newFrom: {
		#topLeft -> (5@0).
		#topRight -> (-3@0).
		#bottomLeft -> (1@ -1).
		#bottomRight -> (-3 @ -3)}) at: self orientation
]

{ #category : #geometry }
NewBalloonMorph >> tailPosition [

	^ self innerBounds perform: self orientation
]

{ #category : #geometry }
NewBalloonMorph >> tailWidth [
	
	^ 15
]

{ #category : #'accessing - ui' }
NewBalloonMorph >> textMorph [

	^ textMorph
]

{ #category : #updating }
NewBalloonMorph >> updateColorsForBalloonOwner [
	
	self color: self balloonOwner balloonColor.
	
	"If the balloon owner has a custom balloon color, derive the balloon border color from it."
	self flag: #refactor. "mt: Add #balloonBorderColor *width etc. to Morph."
	(self balloonOwner hasProperty: #balloonColor)
		ifTrue: [self borderColor: (self color adjustBrightness: -0.2)].
]

{ #category : #updating }
NewBalloonMorph >> updateGradient [

	| cc fill |

	MenuMorph gradientMenu ifFalse: [^ self].
	
	cc := self color.
	fill := GradientFillStyle ramp: {
		0.0 -> Color white.
		0.15 -> (cc mixed: 0.5 with: Color white).
		0.5 -> cc.
		0.8 -> cc twiceDarker}.
	fill
		origin: self topLeft;
		direction: 0@self height.
	self fillStyle: fill.
]

{ #category : #layout }
NewBalloonMorph >> updateLayout [

	self textMorph fullBounds.
	self extent: self textMorph extent + (2* self bubbleInset) +  (0 @ (2*self tailHeight)).
	self textMorph center: self center.
]

{ #category : #drawing }
NewBalloonMorph >> verticesForTail [

	| offset factorX factorY tpos bpos |
	offset := 5 + (self wantsRoundedCorners
		ifTrue: [self cornerRadius]
		ifFalse: [0]).
	tpos := self tailPosition.
	factorX := tpos x < self center x ifTrue: [1] ifFalse: [-1].
	factorY := tpos y > self center y ifTrue: [1] ifFalse: [-1].
	bpos := self bubbleBounds perform: self orientation.
		
	^ {
		tpos.
		bpos + (((offset + self tailWidth) * factorX) @ (self borderStyle width negated * factorY)).
		bpos + ((offset * factorX) @ (self borderStyle width negated * factorY)).}
]
