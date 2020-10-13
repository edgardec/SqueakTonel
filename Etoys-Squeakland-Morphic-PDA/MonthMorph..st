"
A widget that displays the dates of a month in a table.
"
Class {
	#name : #MonthMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'month',
		'todayCache',
		'tileRect',
		'model'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #'as yet unclassified' }
MonthMorph class >> newWithModel: aModel [
	^ (self basicNew model: aModel) initialize
]

{ #category : #all }
MonthMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu 
		addLine;
		addUpdating: #startMondayOrSundayString action: #toggleStartMonday;
		add: 'jump to year...' translated action: #chooseYear.
]

{ #category : #controls }
MonthMorph >> chooseYear [

	| newYear yearString |
	newYear := (SelectionMenu selections:
					{'today'} , (month year - 5 to: month year + 5) , {'other...'})
						startUpWithCaption: 'Choose another year' translated.
	newYear ifNil: [^ self].
	newYear isNumber ifTrue:
		[^ self month: (Month month: month monthName year: newYear)].
	newYear = 'today' ifTrue:
		[^ self month: (Month starting: Date today)].
	yearString := FillInTheBlank 
					request: 'Type in a year' translated initialAnswer: Date today year asString.
	yearString ifNil: [^ self].
	newYear := yearString asNumber.
	(newYear between: 0 and: 9999) ifTrue:
		[^ self month: (Month month: month monthName year: newYear)].

]

{ #category : #initialization }
MonthMorph >> defaultColor [
	"answer the default color/fill style for the receiver"

	^ Color red
]

{ #category : #initialization }
MonthMorph >> highlightToday [

	todayCache := Date today.
	self allMorphsDo:
		[:m | (m isKindOf: SimpleSwitchMorph) ifTrue:
				[(m arguments isEmpty not and: [m arguments first = todayCache])
					ifTrue: [m borderWidth: 2; borderColor: Color yellow]
					ifFalse: [m borderWidth: 1; setSwitchState: m color = m onColor]]].


]

{ #category : #initialization }
MonthMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	tileRect := 0 @ 0 extent: 23 @ 19.
	self 
		layoutInset: 1;
		listDirection: #topToBottom;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		month: Month current.

	self rubberBandCells: false.
	self extent: 160 @ 130
]

{ #category : #initialization }
MonthMorph >> initializeHeader [
	| title sep frame button monthName |
	title := (self findA: WeekMorph) title.
	title hResizing: #spaceFill.
	"should be done by WeekMorph but isn't"
	title submorphsDo: [:m | m hResizing: #spaceFill].
	monthName := month name.
	self width < 160 
		ifTrue: 
			[monthName := (#(6 7 9) includes: month index) 
				ifTrue: [monthName copyFrom: 1 to: 4]
				ifFalse: [monthName copyFrom: 1 to: 3]].
	sep := (Morph new)
				color: Color transparent;
				extent: title width @ 1.
	self
		addMorph: sep;
		addMorph: title;
		addMorph: sep copy.
	button := (SimpleButtonMorph new)
				target: self;
				actWhen: #whilePressed;
				color: (Color 
							r: 0.8
							g: 0.8
							b: 0.8).
	frame := (AlignmentMorph new)
				color: Color transparent;
				listDirection: #leftToRight;
				hResizing: #spaceFill;
				vResizing: #shrinkWrap;
				layoutInset: 0.
	frame
		addMorph: (button
					label: '>>';
					actionSelector: #nextYear;
					width: 15);
		addMorph: ((button copy)
					label: '>';
					actionSelector: #next;
					width: 15);
		addMorph: (((AlignmentMorph new)
					color: Color transparent;
					listDirection: #topToBottom;
					wrapCentering: #center;
					cellPositioning: #topCenter;
					extent: (title fullBounds width - (button width * 3)) @ title height) 
						addMorph: (StringMorph new 
								contents: monthName , ' ' , month year printString));
		addMorph: ((button copy)
					label: '<';
					actionSelector: #previous;
					width: 15);
		addMorph: ((button copy)
					label: '<<';
					actionSelector: #previousYear;
					width: 15).
	"hResizing: #shrinkWrap;"
	self addMorph: frame
]

{ #category : #initialization }
MonthMorph >> initializeWeeks [
	| weeks |
	self removeAllMorphs.
	weeks := OrderedCollection new.
	month weeksDo:
		[ :w |
		weeks add: (WeekMorph newWeek: w month: month tileRect: tileRect model: model)].

	weeks reverseDo: 
		[ :w | 
		w hResizing: #spaceFill; vResizing: #spaceFill.
		"should be done by WeekMorph but isn't"
		w submorphsDo:[ :m | m hResizing: #spaceFill; vResizing: #spaceFill ].
		self addMorph: w ].

	self 
		initializeHeader;
		highlightToday.


]

{ #category : #initialization }
MonthMorph >> model: aModel [

	model := aModel
]

{ #category : #access }
MonthMorph >> month [
	^ month
]

{ #category : #controls }
MonthMorph >> month: aMonth [
	month := aMonth.
	model ifNotNil: [model setDate: nil fromButton: nil down: false].
	self initializeWeeks
]

{ #category : #controls }
MonthMorph >> next [
	self month: month next
]

{ #category : #controls }
MonthMorph >> nextYear [
	self month: (Month month: month month year: month year + 1)

]

{ #category : #controls }
MonthMorph >> previous [
	self month: month previous
]

{ #category : #controls }
MonthMorph >> previousYear [
	self month: (Month month: month month year: month year - 1)

]

{ #category : #access }
MonthMorph >> selectedDates [
	| answer |
	answer := OrderedCollection new.
	self submorphsDo:
		[:each |
		(each isKindOf: WeekMorph) ifTrue: [answer addAll: each selectedDates]].
	^ answer sort
]

{ #category : #controls }
MonthMorph >> startMondayOrSundayString [
	^((Week startDay = #Monday)  ifTrue: ['start Sunday'] ifFalse: ['start Monday']) 
		translated
]

{ #category : #'stepping and presenter' }
MonthMorph >> step [

	todayCache = Date today
		ifFalse: [self highlightToday  "Only happens once a day"]
]

{ #category : #testing }
MonthMorph >> stepTime [
	"Only time stepping matters is when you start up an image where an old date is selected"

	^ 3000  "Three seconds should be good enough response"
]

{ #category : #controls }
MonthMorph >> toggleStartMonday [

	(Week startDay = #Monday)
		ifTrue: [ Week startDay: #Sunday ]
		ifFalse: [ Week startDay: #Monday ].

	self initializeWeeks

]
