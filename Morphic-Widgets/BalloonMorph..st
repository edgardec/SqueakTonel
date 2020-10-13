"
A balloon with text used for the display of explanatory information.

Balloon help is integrated into Morphic as follows:
If a Morph has the property #balloonText, then it will respond to #showBalloon by adding a text balloon to the world, and to #deleteBalloon by removing the balloon.

Moreover, if mouseOverEnabled is true (see class msg), then the Hand will arrange to cause display of the balloon after the mouse has lingered over the morph for a while, and removal of the balloon when the mouse leaves the bounds of that morph.  In any case, the Hand will attempt to remove any such balloons before handling mouseDown events, or displaying other balloons.

Balloons should not be duplicated with veryDeepCopy unless their target is also duplicated at the same time.
"
Class {
	#name : #BalloonMorph,
	#superclass : #PolygonMorph,
	#instVars : [
		'target',
		'offsetFromTarget',
		'balloonOwner'
	],
	#classVars : [
		'BalloonColor',
		'BalloonFont'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #preferences }
BalloonMorph class >> balloonColor [

	self flag: #remove. "mt: We should remove this additional getter  in the future and use UI themes instead:"
	^ (UserInterfaceTheme current get: #color for: #BalloonMorph) ifNil: [(TranslucentColor r: 0.92 g: 0.92 b: 0.706 alpha: 0.749)]
]

{ #category : #preferences }
BalloonMorph class >> balloonColor: aColor [

	self flag: #remove. "mt: We should remove this additional setter in the future and use UI themes instead:"
	UserInterfaceTheme current set: #color for: #BalloonMorph to: aColor.
]

{ #category : #utility }
BalloonMorph class >> balloonFont [

	self flag: #remove. "mt: We should remove this additional getter  in the future and use UI themes instead:"
	^ (UserInterfaceTheme current get: #font for: #BalloonMorph) ifNil: [TextStyle defaultFont]
]

{ #category : #preferences }
BalloonMorph class >> balloonTextColor [

	self flag: #remove. "mt: We should remove this additional getter  in the future and use UI themes instead:"
	^ (UserInterfaceTheme current get: #textColor for: #BalloonMorph) ifNil: [Color black]
]

{ #category : #preferences }
BalloonMorph class >> balloonTextColor: aColor [

	self flag: #remove. "mt: We should remove this additional setter in the future and use UI themes instead:"
	UserInterfaceTheme current set: #textColor for: #BalloonMorph to: aColor.
]

{ #category : #utility }
BalloonMorph class >> chooseBalloonFont [
	"BalloonMorph chooseBalloonFont"

	Preferences 
		chooseFontWithPrompt:  'Ballon Help font...' translated
		andSendTo: self 
		withSelector: #setBalloonFontTo: 
		highlightSelector: #balloonFont
]

{ #category : #private }
BalloonMorph class >> getBestLocation: vertices for: morph corner: cornerName [
	"Try four rel locations of the balloon for greatest unclipped area.   12/99 sma"

	| rect maxArea verts rectCorner morphPoint mbc a mp dir bestVerts result usableArea |
	"wiz 1/8/2005 Choose rect independantly of vertice order or size. Would be nice it this took into account curveBounds but it does not." 
	rect := Rectangle encompassing: vertices.  
	maxArea := -1.
	verts := vertices.
	usableArea := (morph world ifNil: [self currentWorld]) viewBox.
	1 to: 4 do: [:i |
		dir := #(vertical horizontal) atWrap: i.
		verts := verts collect: [:p | p flipBy: dir centerAt: rect center].
		rectCorner := #(bottomLeft bottomRight topRight topLeft) at: i.
		morphPoint := #(topCenter topCenter bottomCenter bottomCenter) at: i.
		a := ((rect
			align: (rect perform: rectCorner)
			with: (mbc := morph boundsForBalloon perform: morphPoint))
				intersect: usableArea) area.
		(a > maxArea or: [a = rect area and: [rectCorner = cornerName]]) ifTrue:
			[maxArea := a.
			bestVerts := verts.
			mp := mbc]].
	result := bestVerts collect: [:p | p + (mp - bestVerts first)] "Inlined align:with:".
	^ result
]

{ #category : #private }
BalloonMorph class >> getTextMorph: aStringOrMorph for: balloonOwner [
	"Construct text morph."
	| m text |
	aStringOrMorph isMorph
		ifTrue: [m := aStringOrMorph]
		ifFalse: [BalloonFont
				ifNil: [text := aStringOrMorph]
				ifNotNil: [text := aStringOrMorph asText
									addAttribute: (TextFontReference toFont: balloonOwner balloonFont);
									addAttribute: (TextColor color: self balloonTextColor)].
			m := (TextMorph new contents: text) centered].
	m setToAdhereToEdge: #adjustedCenter.
	^ m
]

{ #category : #private }
BalloonMorph class >> getVertices: bounds [
	"Construct vertices for a balloon up and to left of anchor"

	| corners |
	corners := bounds corners atAll: #[1 4 3 2].
	^ (Array
		with: corners first + (0 - bounds width // 2 @ 0)
		with: corners first + (0 - bounds width // 4 @ (bounds height // 2))) , corners
]

{ #category : #utility }
BalloonMorph class >> setBalloonFontTo: aFont [

	self flag: #remove. "mt: We should remove this additional setter in the future and use UI themes instead:"
	UserInterfaceTheme current set: #font for: #BalloonMorph to: aFont.
]

{ #category : #'instance creation' }
BalloonMorph class >> string: str for: morph [
	^ self string: str for: morph corner: #bottomLeft
]

{ #category : #'instance creation' }
BalloonMorph class >> string: str for: morph corner: cornerName [ 
	"Make up and return a balloon for morph. Find the quadrant that 
	clips the text the least, using cornerName as a tie-breaker. tk 9/12/97"
	| text vertices balloon |
	balloon := self new.
	text := self
		getTextMorph: (str asString withNoLineLongerThan: Preferences maxBalloonHelpLineLength)
		for: morph.
	balloon userInterfaceTheme textColor ifNotNil:
		[:col | text color: col].
	balloon userInterfaceTheme font ifNotNil: [ : font | text font: font ].
	vertices := self getVertices: text bounds.
	vertices := self
		getBestLocation: vertices
		for: morph
		corner: cornerName.
	^ balloon
		 color: morph balloonColor ;
		 setVertices: vertices ;
		 addMorph: text ;
		 setTarget: morph
]

{ #category : #preferences }
BalloonMorph class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the balloon''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the balloon''s border.' }.
		{ #color. 'Colors', 'Color for the balloon background.' }.
		{ #font. 'Fonts'. 'Font for balloon text if not overridden by text attributes.' }.
		{ #textColor. 'Colors'. 'Color for the balloon text if not overridden by text attributes.' }.
	}
]

{ #category : #menus }
BalloonMorph >> adjustedCenter [
	"Return the center of the original textMorph box within the balloon."

	^ (self vertices last: 4) average rounded  
]

{ #category : #updating }
BalloonMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setDefaultParameters.
]

{ #category : #accessing }
BalloonMorph >> balloonOwner [
	^balloonOwner
]

{ #category : #initialization }
BalloonMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self beSmoothCurve.

	offsetFromTarget := 0 @ 0.
	
	self setDefaultParameters.
]

{ #category : #'WiW support' }
BalloonMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^5		"Balloons are very front-like things"
]

{ #category : #initialization }
BalloonMorph >> popUp [
	| w worldBounds |
	target ifNil: [^ self].
	target isInWorld ifFalse: [^ self].
	w := target world.
	self prepareToOpen.
	"So that if the translation below makes it overlap the receiver, it won't interfere with the rootMorphsAt: logic and hence cause flashing.  Without this, flashing happens, believe me!"
	((worldBounds := w bounds) containsRect: self bounds) ifFalse:
		[self bounds: (self bounds translatedToBeWithin: worldBounds)].
	self openInWorld.
	w activeHand addBalloonHelp: self.
	
]

{ #category : #initialization }
BalloonMorph >> popUpAt: point [

	self position: point.
	self popUp.
]

{ #category : #initialization }
BalloonMorph >> popUpAt: aPoint forHand: aHand [

	self popUpForHand: aHand.
]

{ #category : #initialization }
BalloonMorph >> popUpFor: aMorph hand: aHand [
	"Pop up the receiver as balloon help for the given hand"
	balloonOwner := aMorph.
	self popUpForHand: aHand.
]

{ #category : #initialization }
BalloonMorph >> popUpForHand: aHand [
	"Pop up the receiver as balloon help for the given hand"
	| worldBounds |
	self prepareToOpen.
	aHand world addMorphFront: self.
	"So that if the translation below makes it overlap the receiver, it won't
	interfere with the rootMorphsAt: logic and hence cause flashing.  Without
	this, flashing happens, believe me!"
	((worldBounds := aHand world bounds) containsRect: self bounds) ifFalse:
		[self bounds: (self bounds translatedToBeWithin: worldBounds)].
	aHand resetBalloonHelp: self.

]

{ #category : #private }
BalloonMorph >> prepareToOpen [
	"Override the color if not already set."
	self userInterfaceTheme color ifNotNil: [ : col | self color: col].
	self
		lock ;
		fullBounds ;
		setProperty: #morphicLayerNumber
		toValue: self morphicLayerNumber
]

{ #category : #initialization }
BalloonMorph >> setDefaultParameters [

	self
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [0]);
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color black]);
		color: (self userInterfaceTheme color ifNil: [TranslucentColor r: 0.92 g: 0.92 b: 0.706 alpha: 0.749]).
]

{ #category : #private }
BalloonMorph >> setTarget: aMorph [
	(target := aMorph) ifNotNil: [offsetFromTarget := self position - target position]
]

{ #category : #'stepping and presenter' }
BalloonMorph >> step [
	"Move with target."

	target ifNotNil: [self position: target position + offsetFromTarget].

]

{ #category : #'stepping and presenter' }
BalloonMorph >> stepTime [
	^ 0  "every cycle"
]
