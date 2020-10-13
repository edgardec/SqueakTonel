"
Shows the current week as a row of buttons with numbers on. See MonthMorph
"
Class {
	#name : #WeekMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'week',
		'month',
		'tileRect'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #'new-morph participation' }
WeekMorph class >> includeInNewMorphMenu [
	"Return true for all classes that can be instantiated from the menu"
	^ false
]

{ #category : #'instance creation' }
WeekMorph class >> newWeek: aWeek month: aMonth tileRect: rect model: aModel [

	^ self basicNew initializeForWeek: aWeek month: aMonth tileRect: rect model: aModel

]

{ #category : #'instance creation' }
WeekMorph class >> on: aDate [
	^ self new
		week: aDate asWeek
		month: aDate asMonth
		model: nil
]

{ #category : #initialization }
WeekMorph >> initialize [

	^ self initializeForWeek: Date today asWeek
		month: Date today asMonth
		tileRect: (0@0 extent: 23@19)
		model: nil
]

{ #category : #all }
WeekMorph >> initializeDays: modelOrNil [
	| extent days tile |
	self removeAllMorphs.
	days := OrderedCollection new: 7.
	extent := self tile extent.
	week datesDo:
		[:each |
		tile := (self tileLabeled: each dayOfMonth printString) extent: extent.
		each month = month ifFalse:
			[tile color: Color gray; offColor: Color gray; onColor: Color veryLightGray].
		modelOrNil ifNotNil:
			[tile target: modelOrNil;
				actionSelector: #setDate:fromButton:down:;
				arguments: {each. tile}].
		days add: tile].
	days reverseDo: [:each | self addMorph: each]
]

{ #category : #all }
WeekMorph >> initializeForWeek: aWeek month: aMonth tileRect: rect model: aModel [

	super initialize.
	tileRect := rect.
	self 
		layoutInset: 0;
		color: Color transparent;
		listDirection: #leftToRight;
		hResizing: #shrinkWrap;
		disableDragNDrop;
		height: tileRect height.

	self week: aWeek month: aMonth model: aModel

]

{ #category : #all }
WeekMorph >> next [
	^ self class on: week next
]

{ #category : #all }
WeekMorph >> selectedDates [
	| answer |
	answer :=OrderedCollection new.
	self submorphsDo:
		[:each |
		((each respondsTo: #onColor) and: [each color = each onColor])
			ifTrue:
				[answer add:
					(Date
						newDay: each label asNumber
						month: week start monthName
						year: week start year)]].
	^ answer sort
]

{ #category : #all }
WeekMorph >> tile [
	| onColor offColor |
	offColor := Color r: 0.4 g: 0.8 b: 0.6.
	onColor := offColor alphaMixed: 1/2 with: Color white.
	^ SimpleSwitchMorph new
		offColor: offColor;
		onColor: onColor;
		borderWidth: 1;
		useSquareCorners;
		extent: tileRect extent
]

{ #category : #all }
WeekMorph >> tileLabeled: labelString [
	| onColor offColor |
	offColor := Color r: 0.4 g: 0.8 b: 0.6.
	onColor := offColor alphaMixed: 1/2 with: Color white.
	^ (SimpleSwitchMorph newWithLabel: labelString)
		offColor: offColor;
		onColor: onColor;
		borderWidth: 1;
		useSquareCorners;
		extent: tileRect extent;
		setSwitchState: false
]

{ #category : #all }
WeekMorph >> title [
	"Answer a title with the names of the days."
	| title extent days |
	title := AlignmentMorph new
		layoutInset: 0;
		color: Color red;
		listDirection: #leftToRight;
		vResizing: #shrinkWrap;
		height: tileRect height.
		extent := self tile extent.
		
	days := (Week startDay = #Monday)
		ifTrue: [ #(2 3 4 5 6 7 1) ]
		ifFalse: [ 1 to: 7 ].
		
	(days reverse collect: [:each | Date nameOfDay: each]) do:
		[:each |
		title addMorph:
			((self tileLabeled: (each copyFrom: 1 to: 2))
				extent: extent)].
	^ title
	
]

{ #category : #all }
WeekMorph >> week: aWeek month: aMonth model: aModel [
	week := aWeek.
	month := aMonth.
	self initializeDays: aModel
]
