"
A gui for setting color and transparency. Behaviour can be changed with the Preference modalColorPickers.
"
Class {
	#name : #ColorPickerMorph,
	#superclass : #SketchMorph,
	#instVars : [
		'selectedColor',
		'sourceHand',
		'deleteOnMouseUp',
		'updateContinuously',
		'target',
		'selector',
		'argument',
		'originalColor',
		'theSelectorDisplayMorph',
		'command',
		'isModal',
		'clickedTranslucency',
		'noChart'
	],
	#classVars : [
		'ColorChart',
		'DragBox',
		'FeedbackBox',
		'RevertBox',
		'TransText',
		'TransparentBox'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'class initialization' }
ColorPickerMorph class >> colorPaletteForDepth: depth extent: chartExtent [
	"Display a palette of colors sorted horizontally by hue and vertically by lightness. Useful for eyeballing the color gamut of the display, or for choosing a color interactively."
	"Note: It is slow to build this palette, so it should be cached for quick access."
	"(Color colorPaletteForDepth: 16 extent: 190@60) display"

	| startHue palette transHt vSteps transCaption grayWidth hSteps y c x |
	palette := Form extent: chartExtent depth: depth.
	transCaption := "(DisplayText text: 'no color' asText textStyle: (TextConstants at: #ComicPlain)) form storeString"
		(Form extent: 34@9 depth: 1
			fromArray: #(0 0 256 0 256 0 3808663859 2147483648 2491688266 2147483648 2491688266 0 2491688266 0 2466486578 0 0 0)
			offset: 0@0).
	transHt := transCaption height.
	palette fillWhite: (0@0 extent: palette width@transHt).
	palette fillBlack: (0@transHt extent: palette width@1).
	transCaption displayOn: palette at: palette boundingBox topCenter - ((transCaption width // 2)@0).
	grayWidth := 10.
	startHue := 338.0.
	vSteps := palette height - transHt // 2.
	hSteps := palette width - grayWidth.
	x := 0.
	startHue to: startHue + 360.0 by: 360.0/hSteps do: [:h | | basicHue |
		basicHue := Color h: h asFloat s: 1.0 v: 1.0.
		y := transHt+1.
		0 to: vSteps do: [:n |
 			c := basicHue mixed: (n asFloat / vSteps asFloat) with: Color white.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y := y + 1].
		1 to: vSteps do: [:n |
 			c := Color black mixed: (n asFloat / vSteps asFloat) with: basicHue.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y := y + 1].
		x := x + 1].
	y := transHt + 1.
	1 to: vSteps * 2 do: [:n |
 		c := Color black mixed: (n asFloat / (vSteps*2) asFloat) with: Color white.
		palette fill: (x@y extent: 10@1) fillColor: c.
		y := y + 1].
	^ palette

]

{ #category : #'class initialization' }
ColorPickerMorph class >> initialize [
	"ColorPickerMorph initialize"

	ColorChart := ColorPickerMorph colorPaletteForDepth: 16 extent: 190@60.
	DragBox :=  (11@0) extent: 9@8.
	RevertBox := (ColorChart width - 20)@1 extent: 9@8.
	FeedbackBox := (ColorChart width - 10)@1 extent: 9@8.
	TransparentBox := DragBox topRight corner: RevertBox bottomLeft.

		ColorChart fillBlack: ((DragBox left - 1)@0 extent: 1@9).
		ColorChart fillBlack: ((TransparentBox left)@0 extent: 1@9).
		ColorChart fillBlack: ((FeedbackBox left - 1)@0 extent: 1@9).
		ColorChart fillBlack: ((RevertBox left - 1)@0 extent: 1@9).
		(Form dotOfSize: 5) displayOn: ColorChart at: DragBox center + (0@1).

	self localeChanged.
]

{ #category : #'class initialization' }
ColorPickerMorph class >> localeChanged [
	| formTranslator |
	formTranslator := NaturalLanguageFormTranslator localeID: Locale current localeID.
	TransText := formTranslator translate: 'translucent'.
	TransText
		ifNil: [TransText := Form
						extent: 63 @ 8
						depth: 1
						fromArray: #(4194306 1024 4194306 1024 15628058 2476592640 4887714 2485462016 1883804850 2486772764 4756618 2485462016 4748474 1939416064 0 0 )
						offset: 0 @ 0].
	TransText := ColorForm mappingWhiteToTransparentFrom: TransText
]

{ #category : #'class initialization' }
ColorPickerMorph class >> noColorCaption [
	| formTranslator |
	formTranslator := NaturalLanguageFormTranslator localeID: Locale current localeID.
	^ (formTranslator translate: 'no color')
		ifNil: [Form
				extent: 34 @ 9
				depth: 1
				fromArray: #(0 0 256 0 256 0 3808663859 2147483648 2491688266 2147483648 2491688266 0 2491688266 0 2466486578 0 0 0 )
				offset: 0 @ 0]

]

{ #category : #constants }
ColorPickerMorph class >> perniciousBorderColor [
	"Answer the color of the border lines of a color picker; this color gets reported as you drag the mouse through from the translucent box to the true color area, for example, and can cause some difficulties in some special cases, so it is faithfully reported here in this hard-coded fashion in order that energetic clients wishing to handle it as special-case it can do so."

	^ Color r: 0.0 g: 0.0 b: 0.032
]

{ #category : #menu }
ColorPickerMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	deleteOnMouseUp
		ifTrue: [aCustomMenu add: 'stay up' translated action: #toggleDeleteOnMouseUp]
		ifFalse: [aCustomMenu add: 'do not stay up' translated action: #toggleDeleteOnMouseUp].
	updateContinuously
		ifTrue: [aCustomMenu add: 'update only at end' translated action: #toggleUpdateContinuously]
		ifFalse: [aCustomMenu add: 'update continuously' translated action: #toggleUpdateContinuously].

]

{ #category : #other }
ColorPickerMorph >> addToWorld: world near: box [
	| goodLocation |
	goodLocation := self bestPositionNear: box inWorld: world.
	world allMorphsDo:
		[:p | (p isMemberOf: ColorPickerMorph) ifTrue:
		[(p ~~ self and: [p owner notNil and: [p target == target]]) ifTrue:
			[(p selector == selector and: [p argument == argument])
				ifTrue: [^ p comeToFront  "uncover existing picker"]
				ifFalse: ["place second picker relative to first"
						goodLocation := self bestPositionNear: p bounds inWorld: world]]]].
	self position: goodLocation.
	world addMorphFront: self.
	self changed

]

{ #category : #private }
ColorPickerMorph >> anchorAndRunModeless: aHand [
	"If user clicks on the drag-dot of a modal picker,
	anchor it, and change to modeless operation."

	aHand showTemporaryCursor: nil.  "revert to normal cursor"
	self initializeModal: false; originalColor: originalColor.  "reset as modeless"
	aHand flushEvents.  "Drop any events gathered during modal loop"
	aHand position: Sensor cursorPoint; grabMorph: self.  "Slip into drag operation"

]

{ #category : #accessing }
ColorPickerMorph >> argument [
	^argument
]

{ #category : #accessing }
ColorPickerMorph >> argument: anObject [
	argument := anObject
]

{ #category : #private }
ColorPickerMorph >> argumentsWith: aColor [
	"Return an argument array appropriate to this action selector"

	| nArgs |
	nArgs := selector ifNil:[0] ifNotNil:[selector numArgs].
	nArgs = 0 ifTrue:[^#()].
	nArgs = 1 ifTrue:[^ {aColor}].
	nArgs = 2 ifTrue:[^ {aColor. sourceHand}].
	nArgs = 3 ifTrue:[^ {aColor. argument. sourceHand}].

]

{ #category : #other }
ColorPickerMorph >> bestPositionNear: box inWorld: world [
	| points b |
	points := #(topCenter rightCenter bottomCenter leftCenter).  "possible anchors"
	1 to: 4 do:
		[:i |  "Try the four obvious anchor points"
		b := self bounds align: (self bounds perform: (points at: i))
					with: (box perform: (points atWrap: i + 2)).
		(world viewBox containsRect: b) ifTrue:
			[^ b topLeft"  Yes, it fits"]].

	^ 20@20  "when all else fails"

]

{ #category : #initialization }
ColorPickerMorph >> buildChartForm [
	| chartForm |
	chartForm := ColorChart deepCopy asFormOfDepth: Display depth.
	chartForm fill: ((TransparentBox left + 9)@0 extent: 1@9) fillColor: Color lightGray.
	chartForm fill: ((TransparentBox right - 10)@0 extent: 1@9) fillColor: Color lightGray.
	TransText displayOn: chartForm at: 62@0.
	Display depth = 32 ifTrue:
		["Set opaque bits for 32-bit display"
		chartForm fill: chartForm boundingBox rule: Form under
				fillColor: (Color r: 0.0 g: 0.0 b: 0.0 alpha: 1.0)].
	chartForm borderWidth: 1.
	self form: chartForm.
	selectedColor ifNotNil: [self updateAlpha: selectedColor alpha].
	self updateSelectorDisplay.


]

{ #category : #initialization }
ColorPickerMorph >> choseModalityFromPreference [
	"Decide whether to be modal or not by consulting the prevailing preference"

	self initializeModal: Preferences modalColorPickers
]

{ #category : #'geometry testing' }
ColorPickerMorph >> containsPoint: aPoint [ 
	^ (super containsPoint: aPoint)
		or: [RevertBox containsPoint: aPoint - self topLeft]
]

{ #category : #'submorphs-add\/remove' }
ColorPickerMorph >> delete [
	"The moment of departure has come.
	If the receiver has an affiliated command, finalize it and have the system remember it.
	In any case, delete the receiver"

	(selector isNil or: [ target isNil ]) ifFalse: [
		self rememberCommand: 
			(Command new
				cmdWording: 'color change' translated;
				undoTarget: target selector: selector arguments: (self argumentsWith: originalColor);
				redoTarget: target selector: selector arguments: (self argumentsWith: selectedColor)).
	].
	super delete
]

{ #category : #private }
ColorPickerMorph >> deleteAllBalloons [

	self submorphsDo: [:m | m deleteBalloon].

]

{ #category : #accessing }
ColorPickerMorph >> deleteOnMouseUp [

	^ deleteOnMouseUp

]

{ #category : #accessing }
ColorPickerMorph >> deleteOnMouseUp: aBoolean [

	deleteOnMouseUp := aBoolean.

]

{ #category : #drawing }
ColorPickerMorph >> drawOn: aCanvas [
	aCanvas depth = 1 ifTrue: [aCanvas fillRectangle: self bounds color: Color white].
	Display depth = originalForm depth ifFalse: [self buildChartForm].
	super drawOn: aCanvas
]

{ #category : #kedama }
ColorPickerMorph >> getColorFromKedamaWorldIfPossible: aGlobalPoint [

	self world submorphs do: [:sub |
		 (sub isKedamaMorph) ifTrue: [
			sub morphsAt: aGlobalPoint unlocked: false do: [:e |
				^ e colorAt: (aGlobalPoint - e topLeft).
			].
		].
	].
	^ nil.

]

{ #category : #'event handling' }
ColorPickerMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #other }
ColorPickerMorph >> indicateColorUnderMouse [
	"Track the mouse with the special eyedropper cursor, and accept whatever color is under the mouse as the currently-chosen color; reflect that choice in the feedback box, and return that color."

	| pt |
	self pickColorAt: (pt := Sensor cursorPoint).
	isModal ifTrue:
		[self activeHand position: pt.
		self world displayWorldSafely; runStepMethods].
	^ selectedColor	
]

{ #category : #'event handling' }
ColorPickerMorph >> inhibitDragging [

	^self hasProperty: #noDraggingThisPicker
]

{ #category : #initialization }
ColorPickerMorph >> initialize [
	"Initialize the receiver.  Obey the modalColorPickers preference when deciding how to configure myself.  This is not quite satisfactory -- we'd like to have explicit calls tell us things like whether whether to be modal, whether to allow transparency, but for the moment, in grand Morphic fashion, this is rather inflexibly all housed right here"

	super initialize.
	self clipSubmorphs: true.
	self buildChartForm.
	
	selectedColor := Color white.
	sourceHand := nil.
	deleteOnMouseUp := false.
	clickedTranslucency := false.
	updateContinuously := true.
	selector := nil.
	target := nil
]

{ #category : #initialization }
ColorPickerMorph >> initializeForPropertiesPanel [
	"Initialize the receiver.  If beModal is true, it will be a modal color picker, else not"

	isModal := false.
	self removeAllMorphs.
	self setProperty: #noDraggingThisPicker toValue: true.

	self addMorph: ((Morph newBounds: (RevertBox translateBy: self topLeft))
			color: Color transparent; setCenteredBalloonText: 'restore original color' translated).
	self addMorph: ((Morph newBounds: (FeedbackBox translateBy: self topLeft))
			color: Color transparent; setCenteredBalloonText: 'shows selected color' translated).
	self addMorph: ((Morph newBounds: (TransparentBox translateBy: self topLeft))
			color: Color transparent; setCenteredBalloonText: 'adjust translucency' translated).

	self buildChartForm.
	
	selectedColor ifNil: [selectedColor := Color white].
	sourceHand := nil.
	deleteOnMouseUp := false.
	updateContinuously := true.

]

{ #category : #initialization }
ColorPickerMorph >> initializeModal: beModal [
	"Initialize the receiver.  If beModal is true, it will be a modal color picker, else not"

	isModal := beModal.
	self removeAllMorphs.
	isModal ifFalse:
		[theSelectorDisplayMorph := AlignmentMorph newRow
			color: Color white;
			borderWidth: 1;
			borderColor: Color red;
			hResizing: #shrinkWrap;
			vResizing: #shrinkWrap;
			addMorph: (StringMorph contents: 'theSelector' translated).
		self addMorph: theSelectorDisplayMorph.

		self addMorph: (SimpleButtonMorph new borderWidth: 0;
			label: 'x' font: nil; color: Color transparent;
			actionSelector: #delete; target: self; useSquareCorners;
			position: self topLeft - (0@3); extent: 10@12;
			setCenteredBalloonText: 'dismiss color picker' translated)].

	self addMorph: ((Morph newBounds: (DragBox translateBy: self topLeft))
			color: Color transparent; setCenteredBalloonText: 'put me somewhere' translated).
	self addMorph: ((Morph newBounds: (RevertBox translateBy: self topLeft))
			color: Color transparent; setCenteredBalloonText: 'restore original color' translated).
	self addMorph: ((Morph newBounds: (FeedbackBox translateBy: self topLeft))
			color: Color transparent; setCenteredBalloonText: 'shows selected color' translated).
	self addMorph: ((Morph newBounds: (TransparentBox translateBy: self topLeft))
			color: Color transparent; setCenteredBalloonText: 'adjust translucency' translated).

	self buildChartForm.
	
	selectedColor ifNil: [selectedColor := Color white].
	sourceHand := nil.
	deleteOnMouseUp := false.
	updateContinuously := true.

]

{ #category : #'halos and balloon help' }
ColorPickerMorph >> isLikelyRecipientForMouseOverHalos [
	^ false
]

{ #category : #accessing }
ColorPickerMorph >> locationIndicator [
	
	^self valueOfProperty: #locationIndicator ifAbsent:[ | loc |
		loc := EllipseMorph new.
		loc color: Color transparent; 
			borderWidth: 1; 
			borderColor: Color red; 
			extent: 6@6.
		self setProperty: #locationIndicator toValue: loc.
		self addMorphFront: loc.
		loc]
]

{ #category : #private }
ColorPickerMorph >> modalBalloonHelpAtPoint: cursorPoint [ 
	self flag: #arNote.	"Throw this away. There needs to be another way."
	self submorphsDo: 
			[:m | 
			m wantsBalloon 
				ifTrue: 
					[(m valueOfProperty: #balloon) isNil
						ifTrue: 
							[(m containsPoint: cursorPoint) ifTrue: [m showBalloon: m balloonText]]
						ifFalse: [(m containsPoint: cursorPoint) ifFalse: [m deleteBalloon]]]]
]

{ #category : #'event handling' }
ColorPickerMorph >> mouseDown: evt [
	| localPt |
	localPt := evt cursorPoint - self topLeft.
	self deleteAllBalloons.
	clickedTranslucency := TransparentBox containsPoint: localPt.
	self inhibitDragging ifFalse: [
		(DragBox containsPoint: localPt)
			ifTrue: [^ evt hand grabMorph: self].
	].
	(RevertBox containsPoint: localPt)
		ifTrue: [^ self updateColor: originalColor feedbackColor: originalColor].
	self inhibitDragging ifFalse: [self comeToFront].
	sourceHand := evt hand.
	self startStepping.

]

{ #category : #'event handling' }
ColorPickerMorph >> mouseUp: evt [

	| c |
	self stopStepping.
	sourceHand := nil.
	deleteOnMouseUp ifTrue: [self delete].
	c := self getColorFromKedamaWorldIfPossible: evt cursorPoint.
	c ifNotNil: [selectedColor := c].
	self updateTargetColor.

]

{ #category : #accessing }
ColorPickerMorph >> originalColor: colorOrSymbol [ 
	"Set the receiver's original color.  It is at this point that a command is launched to represent the action of the picker, in support of Undo."

	originalColor := (colorOrSymbol isColor) 
				ifTrue: [colorOrSymbol]
				ifFalse: [Color lightGreen].
	originalForm fill: RevertBox fillColor: originalColor.
	selectedColor := originalColor.
	self updateAlpha: originalColor alpha.
	self locationIndicator 
		center: self topLeft + (self positionOfColor: originalColor)
]

{ #category : #private }
ColorPickerMorph >> pickColorAt: aGlobalPoint [ 

	| alpha selfRelativePoint pickedColor c |
	clickedTranslucency ifNil: [clickedTranslucency := false].
	selfRelativePoint := (self globalPointToLocal: aGlobalPoint) - self topLeft.
	(FeedbackBox containsPoint: selfRelativePoint) ifTrue: [^ self].
	(RevertBox containsPoint: selfRelativePoint)
		ifTrue: [^ self updateColor: originalColor feedbackColor: originalColor].

	"check for transparent color and update using appropriate feedback color "
	(TransparentBox containsPoint: selfRelativePoint) ifTrue:
		[clickedTranslucency ifFalse: [^ self].  "Can't wander into translucency control"
		alpha := (selfRelativePoint x - TransparentBox left - 10) asFloat /
							(TransparentBox width - 20)
							min: 1.0 max: 0.0.
					"(alpha roundTo: 0.01) printString , '   ' displayAt: 0@0." " -- debug"
		self 
			updateColor: (selectedColor alpha: alpha)
			feedbackColor: (selectedColor alpha: alpha).
		^ self].

	"pick up color, either inside or outside this world"
	clickedTranslucency ifTrue: [^ self].  "Can't wander out of translucency control"
	self locationIndicator visible: false. self refreshWorld.
	pickedColor := Display colorAt: aGlobalPoint.
	c := self getColorFromKedamaWorldIfPossible: aGlobalPoint.
	c ifNotNil: [pickedColor := c].
	self locationIndicator visible: true. self refreshWorld.
	self 
		updateColor: (
			(selectedColor isColor and: [selectedColor isTranslucentColor])
						ifTrue: [pickedColor alpha: selectedColor alpha]
						ifFalse: [pickedColor]
		)
		feedbackColor: pickedColor
]

{ #category : #menu }
ColorPickerMorph >> pickUpColorFor: aMorph [
	"Show the eyedropper cursor, and modally track the mouse through a mouse-down and mouse-up cycle"

      | aHand localPt c |
	aHand := aMorph ifNil: [self activeHand] ifNotNil: [aMorph activeHand].
	aHand ifNil: [aHand := self currentHand].
	self addToWorld: aHand world near: (aMorph ifNil: [aHand world]) fullBounds.
	self owner ifNil: [^ self].

	aHand showTemporaryCursor: (ScriptingSystem formAtKey: #Eyedropper) 
			hotSpotOffset: 6 negated @ 4 negated.    "<<<< the form was changed a bit??"

	self updateContinuously: false.
	[Sensor anyButtonPressed]
		whileFalse: 
			 [self trackColorUnderMouse].
	self deleteAllBalloons.

	localPt := Sensor cursorPoint - self topLeft.
	self inhibitDragging ifFalse: [
		(DragBox containsPoint: localPt) ifTrue:
			["Click or drag the drag-dot means to anchor as a modeless picker"
			^ self anchorAndRunModeless: aHand].
	].
	(clickedTranslucency := TransparentBox containsPoint: localPt)
		ifTrue: [selectedColor := originalColor].

	self updateContinuously: true.
	[Sensor anyButtonPressed]
		whileTrue:
			 [self updateTargetColorWith: self indicateColorUnderMouse].
	c := self getColorFromKedamaWorldIfPossible: Sensor cursorPoint.
	c ifNotNil: [selectedColor := c].
	aHand newMouseFocus: nil;
		showTemporaryCursor: nil;
		flushEvents.
	self delete.
		 
 
]

{ #category : #private }
ColorPickerMorph >> positionOfColor: aColor [
	"Compute the position of the given color in the color chart form"
	| rgbRect x y h s v |
	rgbRect := (0@0 extent: originalForm boundingBox extent) insetBy: (1@10 corner: 11@1).
	h := aColor hue.
	s := aColor saturation.
	v := aColor brightness.
	h = 0.0 ifTrue:["gray"
		^(rgbRect right + 6) @ (rgbRect height * (1.0 - v) + rgbRect top)].
	x := (h + 22 \\ 360 / 360.0 * rgbRect width) rounded.
	y := 0.5.
	s < 1.0 ifTrue:[y := y - (1.0 - s * 0.5)].
	v < 1.0 ifTrue:[y := y + (1.0 - v * 0.5)].
	y := (y * rgbRect height) rounded.
	^x@y + (1@10)
]

{ #category : #other }
ColorPickerMorph >> putUpFor: aMorph near: aRectangle [
	"Put the receiver up on the screen.   Note highly variant behavior depending on the setting of the #modalColorPickers preference"
	| layerNumber |
	aMorph isMorph ifTrue: [
		layerNumber := aMorph morphicLayerNumber.
		aMorph allOwnersDo:[:m|
			layerNumber := layerNumber min: m morphicLayerNumber].
		self setProperty: #morphicLayerNumber toValue: layerNumber - 0.1
	].

	isModal == true "backward compatibility"
		ifTrue:
			[self pickUpColorFor: aMorph]
		ifFalse:
			[self addToWorld:
				((aMorph notNil and: [aMorph world notNil])
					ifTrue:
						[aMorph world]
					ifFalse:
						[self currentWorld])
		  		near:
					(aRectangle ifNil:
						[aMorph ifNil: [100@100 extent: 1@1] ifNotNil: [aMorph fullBoundsInWorld]])]
]

{ #category : #accessing }
ColorPickerMorph >> selectedColor [

	^ selectedColor

]

{ #category : #accessing }
ColorPickerMorph >> selector [

	^ selector

]

{ #category : #accessing }
ColorPickerMorph >> selector: aSymbol [
	"Set the selector to be associated with the receiver.  Store it in the receiver's command, if appropriate"

	selector := aSymbol.
	self updateSelectorDisplay
]

{ #category : #accessing }
ColorPickerMorph >> sourceHand [

	^ sourceHand

]

{ #category : #accessing }
ColorPickerMorph >> sourceHand: aHand [

	sourceHand := aHand.

]

{ #category : #'stepping and presenter' }
ColorPickerMorph >> step [

	sourceHand ifNotNil:
		[self pickColorAt: sourceHand position].

]

{ #category : #'stepping and presenter' }
ColorPickerMorph >> stepTime [

	^ 50

]

{ #category : #accessing }
ColorPickerMorph >> target [

	^ target

]

{ #category : #accessing }
ColorPickerMorph >> target: anObject [ 
	target := anObject.
	selectedColor := (target respondsTo: #color)  
				ifTrue: [target color]
				ifFalse: [Color white]
]

{ #category : #menu }
ColorPickerMorph >> toggleDeleteOnMouseUp [

	deleteOnMouseUp := deleteOnMouseUp not.

]

{ #category : #menu }
ColorPickerMorph >> toggleUpdateContinuously [

	updateContinuously := updateContinuously not.

]

{ #category : #private }
ColorPickerMorph >> trackColorAt: aGlobalPoint [ 
	"Before the mouse comes down in a modal color picker, track the color under the cursor, and show it in the feedback box, but do not make transparency changes"

	| selfRelativePoint pickedColor |
	selfRelativePoint := (self globalPointToLocal: aGlobalPoint) - self topLeft.
	(FeedbackBox containsPoint: selfRelativePoint) ifTrue: [^ self].
	(RevertBox containsPoint: selfRelativePoint)
		ifTrue: [^ self updateColor: originalColor feedbackColor: originalColor].

	"check for transparent color and update using appropriate feedback color "
	(TransparentBox containsPoint: selfRelativePoint) ifTrue: [^ self].

	"pick up color, either inside or outside this world"
	pickedColor := Display colorAt: aGlobalPoint.
	self updateColor: (pickedColor alpha: originalColor alpha)
		feedbackColor: pickedColor
]

{ #category : #other }
ColorPickerMorph >> trackColorUnderMouse [
	"Track the mouse with the special eyedropper cursor, and accept whatever color is under the mouse as the currently-chosen color; reflect that choice in the feedback box, and return that color."

	| pt |
	selectedColor := originalColor.
	self trackColorAt: (pt := Sensor cursorPoint).
	isModal ifTrue:
		[self activeHand position: pt.
		self world displayWorldSafely; runStepMethods.
		self modalBalloonHelpAtPoint: pt].
	^ selectedColor	
]

{ #category : #private }
ColorPickerMorph >> updateAlpha: alpha [
	| sliderRect |
	sliderRect := (TransparentBox left + 10)@1 corner: (TransparentBox right - 9)@9.
	originalForm fill: (sliderRect withRight: sliderRect left + (alpha*sliderRect width))
				fillColor: Color lightGray.
	originalForm fillWhite: (sliderRect withLeft: sliderRect left + (alpha*sliderRect width)).
	originalForm fill: ((TransparentBox right - 9)@1 extent: 8@8)
				fillColor: (alpha < 1.0 ifTrue: [Color white] ifFalse: [Color lightGray]).
	TransText displayOn: originalForm at: 62@1 rule: Form paint.

]

{ #category : #private }
ColorPickerMorph >> updateColor: aColor feedbackColor: feedbackColor [
	"Set my selected color to the given color if it is different. Give user feedback. Inform the target of the change if the target and selector are not nil." 

	selectedColor = aColor ifTrue: [^ self].  "do nothing if color doesn't change"

	self updateAlpha: aColor alpha.
	originalForm fill: FeedbackBox fillColor: feedbackColor.
	self form: originalForm.
	selectedColor := aColor.
	updateContinuously ifTrue: [self updateTargetColor].
	self locationIndicator center: self topLeft + (self positionOfColor: feedbackColor).
]

{ #category : #accessing }
ColorPickerMorph >> updateContinuously [

	^ updateContinuously

]

{ #category : #accessing }
ColorPickerMorph >> updateContinuously: aBoolean [

	updateContinuously := aBoolean.

]

{ #category : #initialization }
ColorPickerMorph >> updateSelectorDisplay [
	theSelectorDisplayMorph ifNil: [^self].
	theSelectorDisplayMorph position: self bottomLeft.
	theSelectorDisplayMorph firstSubmorph contents: selector asString , ' ' , selectedColor printString
]

{ #category : #private }
ColorPickerMorph >> updateTargetColor [
	| nArgs |
	(target notNil and: [selector notNil]) 
		ifTrue: 
			[self updateSelectorDisplay.
			nArgs := selector numArgs.
			nArgs = 1 ifTrue: [^target perform: selector with: selectedColor].
			nArgs = 2 
				ifTrue: 
					[^target 
						perform: selector
						with: selectedColor
						with: sourceHand].
			nArgs = 3 
				ifTrue: 
					[^target 
						perform: selector
						with: selectedColor
						with: argument
						with: sourceHand]]
]

{ #category : #private }
ColorPickerMorph >> updateTargetColorWith: aColor [ 
	"Update the target so that it reflects aColor as the color choice"

	(target notNil and: [selector notNil]) 
		ifTrue: 
			[self updateSelectorDisplay.
			^target perform: selector withArguments: (self argumentsWith: aColor)]
]
