"
This class is a representation of a watch.
The labels' font is changeble. Labels' font size increase or decrease when resizing me.

WatchMorph new openInWorld
(WatchMorph fontName: 'ComicPlain' bgColor: Color transparent centerColor: Color transparent) openInWorld		"" transparent ""
(WatchMorph fontName: 'ComicBold' bgColor: Color white centerColor: Color black) openInWorld

Structure:
	fontName		String -- the labels' font name
	cColor			Color -- center color
	handsColor		Color
	romanNumerals	Boolean
	antialias		Boolean
"
Class {
	#name : #WatchMorph,
	#superclass : #EllipseMorph,
	#instVars : [
		'fontName',
		'cColor',
		'handsColor',
		'romanNumerals',
		'antialias'
	],
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #'parts bin' }
WatchMorph class >> descriptionForPartsBin [
	"Answer a description for use in parts bins."

	^ self partName:	'Clock' translatedNoop
		categories:		#('Just for Fun')
		documentation:	'An analog clock face' translatedNoop
]

{ #category : #'instance creation' }
WatchMorph class >> fontName: aString bgColor: aColor centerColor: otherColor [
	^ self new
		fontName: aString;
		color: aColor;
		centerColor: otherColor
]

{ #category : #menus }
WatchMorph >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand."

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu addLine.
	aMenu addUpdating: #romanNumeralString action: #toggleRoman.
	aMenu addUpdating: #antiAliasString action: #toggleAntialias.
	aMenu addLine.
	aMenu add: 'change font...' translated action: #changeFont.
	aMenu balloonTextForLastItem: 'Allows you to change the font used to display the numbers.' translated.
	aMenu add: 'change hands color...' translated action: #changeHandsColor.
	aMenu balloonTextForLastItem: 'Allows you to specify a new color for the hands of the watch.  Note that actual *watch* color can be changed simply by using the halo''s recoloring handle.' translated.
	aMenu add: 'change center color...' translated action: #changeCenterColor.
	aMenu balloonTextForLastItem: 'Allows you to specify a new color to be used during PM hours for the center portion of the watch; during AM hours, a lighter shade of the same color will be used.' translated.
]

{ #category : #menus }
WatchMorph >> antiAliasString [
	^ (antialias
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'anti-aliasing' translated
]

{ #category : #accessing }
WatchMorph >> antialias: aBoolean [
	antialias := aBoolean
]

{ #category : #accessing }
WatchMorph >> centerColor: aColor [
	"Set the center color as indicated; map nil into transparent"

	cColor := aColor ifNil: [Color transparent]
]

{ #category : #menus }
WatchMorph >> changeCenterColor [
	"Let the user change the color of the center of the watch"

	ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self activeHand;
		target: self;
		selector: #centerColor:;
		originalColor: self color;
		putUpFor: self near: self fullBounds
]

{ #category : #menus }
WatchMorph >> changeFont [

	self fontName: ((SelectionMenu labelList: StrikeFont familyNames
							selections: StrikeFont familyNames) startUp
					ifNil: [^ self])
]

{ #category : #menus }
WatchMorph >> changeHandsColor [
	"Let the user change the color of the hands of the watch."

	ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self activeHand;
		target: self;
		selector: #handsColor:;
		originalColor: self color;
		putUpFor: self near: self fullBounds
]

{ #category : #updating }
WatchMorph >> createLabels [

	| numeral font h r |
	self removeAllMorphs.
	font := StrikeFont familyName: fontName size: (h := self height min: self width)//8.
	r := 1.0 - (1.4 * font height / h).
	1 to: 12 do:
		[:hour |
		numeral := romanNumerals
			ifTrue: [#('I' 'II' 'III' 'IV' 'V' 'VI' 'VII' ' VIII' 'IX' 'X' 'XI' 'XII') at: hour]
			ifFalse: [hour asString].
		self addMorphBack: ((StringMorph contents: numeral font: font emphasis: 1)
			center: (self radius: r hourAngle: hour)) lock].

]

{ #category : #initialization }
WatchMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color green
]

{ #category : #drawing }
WatchMorph >> drawOn: aCanvas [
	"Draw the watch on the given canvas"

	| pHour pMin pSec time centerColor |
	time := Time now.
	pHour := self radius: 0.6 hourAngle: time hours + (time minutes/60.0).
	pMin := self radius: 0.72 hourAngle: (time minutes / 5.0).
	pSec := self radius: 0.8 hourAngle: (time seconds / 5.0).
	centerColor := cColor
		ifNil:
			[Color transparent]
		ifNotNil:
			[time hours < 12
				ifTrue: [cColor muchLighter]
				ifFalse: [cColor]].

	antialias ifTrue:
		[aCanvas asBalloonCanvas
			aaLevel: 4;
			drawOval: (self bounds insetBy: self borderWidth // 2 + 1) color: self fillStyle
				borderWidth: self borderWidth borderColor: self borderColor;
			drawOval: (self bounds insetBy: self extent*0.35) color: centerColor
				borderWidth: 0 borderColor: Color black;
			drawPolygon: {self center. pHour}
				color: Color transparent borderWidth: 3 borderColor: handsColor;
			drawPolygon: {self center. pMin}
				color: Color transparent borderWidth: 2 borderColor: handsColor;
			drawPolygon: {self center. pSec}
				color: Color transparent borderWidth: 1 borderColor: handsColor]
		ifFalse:
			[super drawOn: aCanvas.
			aCanvas
				fillOval: (self bounds insetBy: self extent*0.35) color: centerColor;
				line: self center to: pHour width: 3 color: handsColor;
				line: self center to: pMin width: 2 color: handsColor;
				line: self center to: pSec width: 1 color: handsColor]

]

{ #category : #geometry }
WatchMorph >> extent: newExtent [

	super extent: newExtent.
	self createLabels
]

{ #category : #accessing }
WatchMorph >> fontName: aString [

	fontName := aString.
	self createLabels
]

{ #category : #accessing }
WatchMorph >> handsColor: aColor [

	handsColor := aColor
]

{ #category : #initialization }
WatchMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""

	self handsColor: Color red.
	self centerColor: Color gray.
	romanNumerals := false.
	antialias := false.
	fontName := 'NewYork'.
	self extent: 130 @ 130.
	self start
]

{ #category : #private }
WatchMorph >> radius: unitRadius hourAngle: hourAngle [
	"unitRadius goes from 0.0 at the center to 1.0 on the circumference.
	hourAngle runs from 0.0 clockwise around to 12.0 with wrapping."

	^ self center + (self extent * (Point r: 0.5 * unitRadius
									degrees: hourAngle * 30.0 - 90.0)).
]

{ #category : #menus }
WatchMorph >> romanNumeralString [
	"Answer a string governing the roman-numerals checkbox"
	^ (romanNumerals
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'roman numerals' translated
]

{ #category : #'stepping and presenter' }
WatchMorph >> step [

	self changed.
]

{ #category : #menus }
WatchMorph >> toggleAntialias [
	antialias := antialias not
]

{ #category : #menus }
WatchMorph >> toggleRoman [

	romanNumerals := romanNumerals not.
	self createLabels
]
