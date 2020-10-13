"
CalendarMorph, by Ricardo Moran, 2011, with some changes by Scott Wallace, January 2012.

A CalendarMorph is single-month calendar that is scriptable using tiles in its viewer.  It always has a 'selected' date, for which the correct month and year are shown; the actual day corresponding to the selected date is highlighted on the calendar.

"
Class {
	#name : #CalendarMorph,
	#superclass : #Morph,
	#instVars : [
		'date',
		'stepTime',
		'shouldUpdate'
	],
	#category : #'Etoys-Squeakland-Etoys-Calendar'
}

{ #category : #'viewer categories' }
CalendarMorph class >> additionsToViewerCategories [
	"Answer definitions for viewer categories of a Calendar."

	^ #(

		(#'calendar' (
			(slot date 'Shows the selected date' String readOnly Player getDate Player unused  )
			(slot day 'Shows the selected day and lets you modify it' Number readWrite Player getDay Player setDay: )
			(slot month 'Shows the selected month and lets you modify it' Number readWrite Player getMonth Player setMonth:  )
			(slot year 'Shows the selected year and lets you modify it' Number readWrite Player getYear Player setYear:  )

			(slot dayName 'Shows the name of the selected day' String readOnly Player getDayName Player unused  )
			(slot monthName 'Shows the name of the selected month' String readOnly Player getMonthName Player unused  )
			(slot dateFormat 'Lets you choose a format for displaying the date' DateFormat readWrite Player getDateFormat Player setDateFormat:  )

			(command goToToday 'Show the current month and highlight the current day on it')
			(slot julianDay 'The Julian day of the selected date' Number readWrite Player getJulianDay Player setJulianDay:)
)))
]

{ #category : #'class initialization' }
CalendarMorph class >> assureDateFormatEstablished [
	"Make certain that there is a DateFormat vocabulary in the system's list."

	Vocabulary addStandardVocabulary: (SymbolListType new vocabularyName: #DateFormat;
				 symbols: #(#'dd/mm/yyyy' #'yyyy/mm/dd' #'mm/dd/yyyy')).
]

{ #category : #'parts bin' }
CalendarMorph class >> descriptionForPartsBin [
	"Answer a description for use in parts bins"

	^ self partName: 	'Calendar' translatedNoop
		categories:		{'Just for Fun' translatedNoop}
		documentation:	'A scriptable calendar' translatedNoop
]

{ #category : #'class initialization' }
CalendarMorph class >> initialize [
	"Class initialization."

	self assureDateFormatEstablished
]

{ #category : #actions }
CalendarMorph >> addDays: aNumber [
	[self date: (date addDays: aNumber)]
		on: Error
		do: ["Nothing"]
]

{ #category : #actions }
CalendarMorph >> addMonths: aNumber [
	[self date: (date addMonths: aNumber)]
		on: Error
		do: ["Nothing"]
]

{ #category : #building }
CalendarMorph >> buildMonthRow [
	^ self newRow
		addMorphBack: ((self newButtonWithContents: '<-') actionSelector: #previousMonth; target: self);
		addMorphBack: AlignmentMorph newVariableTransparentSpacer;
		addMorphBack: (date month name translated asMorph color: self labelsDefaultColor);
		addMorphBack: AlignmentMorph newVariableTransparentSpacer;
		addMorphBack: ((self newButtonWithContents: '->') actionSelector: #nextMonth; target: self)
]

{ #category : #building }
CalendarMorph >> buildYearRow [
	^ self newRow
		addMorphBack: ((self newButtonWithContents: '<-') actionSelector: #previousYear; target: self);
		addMorphBack: AlignmentMorph newVariableTransparentSpacer;
		addMorphBack: (date year name asMorph color: self labelsDefaultColor);
		addMorphBack: AlignmentMorph newVariableTransparentSpacer;
		addMorphBack: ((self newButtonWithContents: '->') actionSelector: #nextYear; target: self)
]

{ #category : #accessing }
CalendarMorph >> color: aColor [
	super color: aColor.
	shouldUpdate := true
]

{ #category : #accessing }
CalendarMorph >> date [
	^ date
]

{ #category : #accessing }
CalendarMorph >> date: aDate [
	date := aDate.
	shouldUpdate := true
]

{ #category : #building }
CalendarMorph >> dayInitialsRow [
	| newRow |
	newRow := self newRow.
	Week dayNames
		do: [:dayName|
			newRow addMorphBack: (TextMorph new 
				contentsWrapped: dayName translated first asString;
				textColor: self labelsDefaultColor;
				autoFit: false;
				width: 30;
				centered;
				lock)]
		separatedBy: [newRow addMorphBack: AlignmentMorph newVariableTransparentSpacer].
	^newRow 
]

{ #category : #accessing }
CalendarMorph >> fillStyle: aFillStyle [
	super fillStyle: aFillStyle.
	shouldUpdate := true
]

{ #category : #stepping }
CalendarMorph >> incrementStepTime [
	stepTime := (stepTime + 1) min: self maximumStepTime
]

{ #category : #initialize }
CalendarMorph >> initialColor [
	"Answer the color to use for a new Calendar."

	^  Color r: 0.516 g: 0.677 b: 1.0

"Note: Richo's initial implementation was to use a randomly-chosen color for each new Calendar, for which the code in this method would be:

	^ Color random

... but in this version, a standard, sedate color is used for each new calendar.   The user can of course change the color using the standard halo recolor tool"
]

{ #category : #initialize }
CalendarMorph >> initialize [
	"One-time initialization of a new calendar."

	super initialize.
	date := Date today.
	stepTime := self minimumStepTime.
	shouldUpdate := false.
	self layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: self initialColor;
		cornerStyle: #rounded;
		initializeSubmorphs
]

{ #category : #initialize }
CalendarMorph >> initializeSubmorphs [
	| weekRow dateButton |
	self addMorphBack: self buildYearRow;
		 addMorphBack: self buildMonthRow;
		 addMorphBack: self dayInitialsRow.
	date month weeks
		do: [:week | 
			weekRow := self newRow.
			week dates
				do: [:aDate | 
					dateButton := self newDateButtonWithContents: aDate dayOfMonth asString.
					dateButton actionSelector: #date:; 
						 target: self;
						 arguments: {aDate}.
					date = aDate
						ifTrue: [dateButton
								color: (self color
										mixed: 0.5
										with: (self color adjustSaturation: 1 brightness: 1))].
					date month ~= aDate month
						ifTrue: [dateButton color: self color.
							(dateButton findA: StringMorph)
								color: Color gray].
					weekRow addMorphBack: dateButton]
				separatedBy: [weekRow addMorphBack: AlignmentMorph newVariableTransparentSpacer].
			self addMorphBack: weekRow]
]

{ #category : #building }
CalendarMorph >> labelsDefaultColor [
	^ self color makeForegroundColor 
]

{ #category : #update }
CalendarMorph >> localeChanged [
	self update
]

{ #category : #stepping }
CalendarMorph >> maximumStepTime [
	^ 200
]

{ #category : #stepping }
CalendarMorph >> minimumStepTime [
	^ 20
]

{ #category : #building }
CalendarMorph >> newButtonWithContents: aByteString [ 
	^SimpleButtonMorph new 
		label: aByteString;
		color: (self color mixed: 0.5 with: Color gray);
		borderStyle: (BorderStyle raised width: 2)
]

{ #category : #building }
CalendarMorph >> newDateButtonWithContents: aByteString [ 
	^SimpleButtonMorph new
		label: aByteString;
		cornerStyle: #square;
		color: self color muchLighter;
		borderStyle: (BorderStyle raised width: 2);
		width: 30
]

{ #category : #building }
CalendarMorph >> newRow [
	^ AlignmentMorph newRow
		vResizing: #shrinkWrap;
		color: Color transparent
]

{ #category : #actions }
CalendarMorph >> nextMonth [
	self addMonths: 1
]

{ #category : #actions }
CalendarMorph >> nextYear [
	self addMonths: 12
]

{ #category : #actions }
CalendarMorph >> previousMonth [
	self addMonths: -1
]

{ #category : #actions }
CalendarMorph >> previousYear [
	self addMonths: -12
]

{ #category : #stepping }
CalendarMorph >> step [
	shouldUpdate
		ifTrue: [self update.
			stepTime := self minimumStepTime.
			shouldUpdate := false]
		ifFalse: [self incrementStepTime]
]

{ #category : #stepping }
CalendarMorph >> stepTime [
	^ stepTime 
]

{ #category : #update }
CalendarMorph >> update [
	self submorphsDo: [:m | m delete].
	self initializeSubmorphs 
]
