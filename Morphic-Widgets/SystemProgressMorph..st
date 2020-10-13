"
An single instance of this morph class is used to display progress while the system is busy, eg. while it receives code updates or does a fileIn. To give the user progress information you don't deal directly with SystemProgressMorph. You keep on using the well established way of progress notification, that has been a long time in the system, is widely used and does not depend on the existence of SystemProgressMorph. For more information on this look at the example in this class or look at the comment of the method displayProgressAt:from:to:during: in class String.

SystemProgressMorph is not meant to be used as a component inside other morphs.

You can switch back to the old style of progress display by disabling the morphicProgressStyle setting in the morphic section of the preferences.
"
Class {
	#name : #SystemProgressMorph,
	#superclass : #Morph,
	#instVars : [
		'activeSlots',
		'bars',
		'labels',
		'font',
		'lock',
		'requestedPosition',
		'textColor'
	],
	#classVars : [
		'BarHeight',
		'BarWidth',
		'Inset',
		'UniqueInstance'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #preferences }
SystemProgressMorph class >> applyUserInterfaceTheme [

	self initialize; reset.
]

{ #category : #'instance creation' }
SystemProgressMorph class >> close: aBlock [
	| slot |
	slot := aBlock value: SmallInteger maxVal. "This should prevent a redraw"
	aBlock receiver freeSlot: slot.
	

]

{ #category : #examples }
SystemProgressMorph class >> example [
	"SystemProgressMorph example"
	'Progress' 
		displayProgressFrom: 0 to: 1000
		during: [:bar | 0 to: 1000 do: [:i | bar value: i. (Delay forMilliseconds: 2) wait]]

]

{ #category : #examples }
SystemProgressMorph class >> exampleChangeLabel [
	"SystemProgressMorph exampleChangeLabel"
	| classes |
	classes := Smalltalk allClasses copyFrom: 1 to: 100.
	'InitialLabel' 
		displayProgressFrom: 0 to: classes size
		during: [:bar | 1 to: classes size do: [:i |
				bar value: i.
				bar value: i printString, '/', classes size printString, ' ', (classes at: i) printString.
				(Delay forMilliseconds: 100) wait]]

]

{ #category : #examples }
SystemProgressMorph class >> exampleLabelOnly [
	"SystemProgressMorph exampleLabelOnly"
	| words |
	words := #(zero one two three four five six seven eight nine ten) reversed.
	UIManager default informUserDuring: [:bar |
		words do: [:each|
			bar value: 'Countdown: ', each.
			(Delay forSeconds: 1) wait]].
]

{ #category : #'instance creation' }
SystemProgressMorph class >> informUserAt: aPoint during: workBlock [
	ProgressInitiationException 
		display: ' '
		at: aPoint 
		from: 0 
		to: 0 
		during: workBlock
]

{ #category : #'class initialization' }
SystemProgressMorph class >> initialize [
	"SystemProgressMorph initialize; reset"
	
	BarHeight := (8 * RealEstateAgent scaleFactor) rounded.
	BarWidth := (300 * RealEstateAgent scaleFactor) rounded.
	Inset := ((30@30) * RealEstateAgent scaleFactor) rounded.
]

{ #category : #'instance creation' }
SystemProgressMorph class >> label: shortDescription min: minValue max: maxValue [
"This method is no longer used, but kept for a while longer to ensure no difficulties updating via the trunk."
	^ self 
		position: Display center
		label: shortDescription
		min: minValue
		max: maxValue
]

{ #category : #'instance creation' }
SystemProgressMorph class >> new [
	^self shouldNotImplement
]

{ #category : #'instance creation' }
SystemProgressMorph class >> position: aPoint label: shortDescription min: minValue max: maxValue [ 
	UniqueInstance ifNil: [ UniqueInstance := super new ].
	^ UniqueInstance
		position: aPoint
		label: (shortDescription contractTo: 100)
		min: minValue asFloat
		max: maxValue asFloat
]

{ #category : #'instance creation' }
SystemProgressMorph class >> reset [
	"SystemProgressMorph reset"
	UniqueInstance ifNotNil: [UniqueInstance delete].
	UniqueInstance := nil.
]

{ #category : #preferences }
SystemProgressMorph class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the progress'' border.' }.
		{ #borderWidth. 'Borders'. 'Width of the progress'' border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the progress.' }.

		{ #font. 'Fonts'. 'Font for bar labels.' }.
		{ #textColor. 'Colors'. 'Color for bar labels.' }.
	}
]

{ #category : #'instance creation' }
SystemProgressMorph class >> uniqueInstance [

	^ UniqueInstance ifNil: [UniqueInstance := super new]
]

{ #category : #accessing }
SystemProgressMorph >> activeSlots [

	^ activeSlots
]

{ #category : #accessing }
SystemProgressMorph >> activeSlots: anObject [

	activeSlots := anObject
]

{ #category : #updating }
SystemProgressMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self setDefaultParameters.
]

{ #category : #accessing }
SystemProgressMorph >> bars [

	^ bars
]

{ #category : #accessing }
SystemProgressMorph >> bars: anObject [

	bars := anObject
]

{ #category : #private }
SystemProgressMorph >> createProgressBar [
	
	^ SystemProgressBarMorph new extent: BarWidth@BarHeight
]

{ #category : #private }
SystemProgressMorph >> createProgressLabel: aString [
	
	^ (StringMorph contents: aString font: self font)
		color: self textColor;
		yourself
]

{ #category : #'submorphs-add\/remove' }
SystemProgressMorph >> dismissViaHalo [
	self class reset
]

{ #category : #accessing }
SystemProgressMorph >> font [

	^ font
]

{ #category : #accessing }
SystemProgressMorph >> font: anObject [

	font := anObject.
	self labels select: [:ea | ea notNil] thenDo: [:ea | ea font: font].
]

{ #category : #private }
SystemProgressMorph >> freeSlot: number [
	number > 0 ifFalse: [^self].
	lock critical: [| label |
		label := self labels at: number.
		(label isNil or: [label owner isNil]) ifTrue: [^self]. "Has been freed before"
		label delete.
		(self bars at: number) delete.
		self activeSlots: self activeSlots - 1.
		self activeSlots = 0
			ifTrue: [self delete]
			ifFalse: [self reposition]]
]

{ #category : #initialization }
SystemProgressMorph >> initialize [
	super initialize.
	activeSlots := 0.
	bars := Array new: 10.
	labels := Array new: 10.
	lock := Semaphore forMutualExclusion.
	self setDefaultParameters;
		setProperty: #morphicLayerNumber toValue: self morphicLayerNumber;
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		cellPositioning: #topCenter;
		cellGap: 5;
		listCentering: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		layoutInset: Inset;
		minWidth: 150
]

{ #category : #private }
SystemProgressMorph >> label: shortDescription min: minValue max: maxValue [
	"For convenience. Do not change the current position."
	
	self
		position: self requestedPosition
		label: shortDescription
		min: minValue
		max: maxValue.

]

{ #category : #labelling }
SystemProgressMorph >> labelAt: progressBlock put: aString [
	"Change the label for the given progressBlock to aString."
	progressBlock value: aString
]

{ #category : #accessing }
SystemProgressMorph >> labels [

	^ labels
]

{ #category : #accessing }
SystemProgressMorph >> labels: anObject [

	labels := anObject
]

{ #category : #initialization }
SystemProgressMorph >> morphicLayerNumber [
	"progress morphs are behind menus and balloons, but in front of most other stuff"
	^self valueOfProperty: #morphicLayerNumber ifAbsent: [12].

]

{ #category : #private }
SystemProgressMorph >> nextSlotFor: shortDescription [
	
	lock critical: [ | label bar slots |
		slots := self labels size.
		self activeSlots = slots ifTrue: [^0].
		self activeSlots: self activeSlots + 1.
		1 to: slots do: [:index |
			label := (self labels at: index).
			label ifNil: [
				bar := self bars at: index put: self createProgressBar.
				label := self labels at: index put: (self createProgressLabel: shortDescription).
				self
					addMorphBack: label;
					addMorphBack: bar.
				^index].
			label owner ifNil: [
				bar := self bars at: index.
				label := self labels at: index.
				self
					addMorphBack: (label contents: shortDescription);
					addMorphBack: (bar barSize: 0).
				^index]]]
		
]

{ #category : #private }
SystemProgressMorph >> position: aPoint label: shortDescription min: minValue max: maxValue [
	| slot range barSize lastRefresh |
	self requestedPosition: aPoint.
	((range := maxValue - minValue) < 0 or: [(slot := self nextSlotFor: shortDescription) = 0])
		ifTrue: [^[:barVal| 0 ]].
	range <= 0 ifTrue: [self removeMorph: (self bars at: slot)].
	self reposition.
	self openInWorld.
	barSize := -1. "Enforces a inital draw of the morph"
	lastRefresh := 0.
	^[:barVal | | newBarSize |
		barVal isString ifTrue: [
			self setLabel: barVal at: slot.
			self currentWorld displayWorld].
		(barVal isNumber and: [range >= 1 and: [barVal between: minValue and: maxValue]]) ifTrue: [
			newBarSize := (barVal - minValue / range * BarWidth) truncated.
			newBarSize = barSize ifFalse: [
				barSize := newBarSize.
				(self bars at: slot) barSize: barSize.
				Time utcMicrosecondClock - lastRefresh > 25000 ifTrue: [
					self refreshWorld.
					lastRefresh := Time utcMicrosecondClock]]].
		slot]
]

{ #category : #private }
SystemProgressMorph >> recenter [
	| position |
"This method is no longer used, but kept for a while longer to ensure no difficulties updating via the trunk."
	"Put ourself in the center of the display"
	self align: self fullBounds center with: Display boundingBox center.
	"Check to see if labels are wider than progress bars. In that case do
	a centered instead of the default left aligned layout."
	position :=	self width > (Inset x * 2 + (self borderWidth * 2) + BarWidth)
					ifTrue: [#topCenter]
					ifFalse: [#leftCenter].
	self cellPositioning: position
]

{ #category : #private }
SystemProgressMorph >> reposition [
	"Put ourself in the requested position on the display, but ensure completely within the bounds of the display. Compute layout first via #fullBounds to get correct #center."

	self fullBounds. 
	self bounds:
		((self bounds
			align: self center
			with: (self requestedPosition ifNil: [ self center ]))
				translatedToBeWithin: self currentWorld bounds).
	
	"Check to see if labels are wider than progress bars. In that case do a centered instead of the default left aligned layout."
	self cellPositioning:
		(self layoutExtent x > BarWidth
			ifTrue: [ #topCenter ]
			ifFalse: [ #leftCenter ]).
]

{ #category : #accessing }
SystemProgressMorph >> requestedPosition [

	^ requestedPosition
]

{ #category : #accessing }
SystemProgressMorph >> requestedPosition: anObject [
	"only change the progress bar position if this is an occasion when the progress bar is opening with a single active bar. After that we don't want to change the position and leap around the screen"
	activeSlots 	< 1 ifTrue:[ requestedPosition := anObject]
]

{ #category : #initialization }
SystemProgressMorph >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: (self userInterfaceTheme color ifNil: [Color r: 0.9 g: 0.9 b: 0.9]);
		borderStyle: (self userInterfaceTheme borderStyle ifNil: [BorderStyle simple]) copy;
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color gray]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]).

	Preferences menuAppearance3d ifTrue: [self addDropShadow].

	self
		font: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]);
		textColor: (self userInterfaceTheme textColor ifNil: [Color black]).

	self
		updateColor: self
		color: self color
		intensity: 1.
]

{ #category : #labelling }
SystemProgressMorph >> setLabel: shortDescription at: slot [
	(self labels at: slot) contents: shortDescription.
	self reposition
]

{ #category : #'dropping\/grabbing' }
SystemProgressMorph >> slideToTrash: evt [
	"If the user needs to dismiss a progress morph by hand, start with a 
	fresh instance next time."
	self dismissViaHalo
]

{ #category : #accessing }
SystemProgressMorph >> textColor [

	^ textColor ifNil: [Color black]
]

{ #category : #accessing }
SystemProgressMorph >> textColor: aColor [

	textColor := aColor.
	self labels select: [:ea | ea notNil] thenDo: [:ea | ea color: textColor].
]

{ #category : #initialization }
SystemProgressMorph >> updateColor: aMorph color: aColor intensity: anInteger [ 
	"update the apareance of aMorph"
	| fill cc |
	MenuMorph gradientMenu
		ifFalse: [^ self].

	
	cc := aColor adjustSaturation: -0.08 brightness: 0.4.
	fill := GradientFillStyle ramp: {
		0.0 -> cc. 
		0.25 -> (aColor mixed: 0.5 with: cc). 
		1.0 -> aColor}.
	
	fill radial: false;
		origin: aMorph topLeft;
		direction: 0 @ aMorph height.
	aMorph fillStyle: fill
]

{ #category : #rounding }
SystemProgressMorph >> wantsRoundedCorners [

	^ MenuMorph roundedMenuCorners or: [super wantsRoundedCorners]
]
