"
I represent a week.

To find out what days of the week on which Squeak is fun, select the following expression, and print it:

Week dayNames
"
Class {
	#name : #Week,
	#superclass : #Timespan,
	#classVars : [
		'StartDay'
	],
	#pools : [
		'ChronologyConstants'
	],
	#category : #'Chronology-Core'
}

{ #category : #'squeak protocol' }
Week class >> dayNames [

	^ DayNames
]

{ #category : #'squeak protocol' }
Week class >> indexOfDay: aSymbol [

	^ DayNames indexOf: aSymbol
]

{ #category : #'smalltalk-80' }
Week class >> nameOfDay: anIndex [

	^ DayNames at: anIndex
]

{ #category : #'squeak protocol' }
Week class >> startDay [

	^ StartDay ifNil: [ StartDay
 := DayNames first ]

]

{ #category : #'squeak protocol' }
Week class >> startDay: aSymbol [

	(DayNames includes: aSymbol)
		ifTrue: [ StartDay := aSymbol ]
		ifFalse: [ self error: aSymbol, ' is not a recognised day name' ]
]

{ #category : #'squeak protocol' }
Week class >> starting: aDateAndTime duration: aDuration [
	"Override - the duration is always one week.
	 Week will start from the Week class>>startDay"

	| midnight delta adjusted |
	midnight := aDateAndTime asDateAndTime midnight.
	delta := ((midnight dayOfWeek + 7 - (DayNames indexOf: self startDay)) rem: 7) abs.
	adjusted := midnight - (Duration days: delta seconds: 0).

	^ super starting: adjusted duration: (Duration weeks: 1)
]

{ #category : #'squeak protocol' }
Week class >> weekdayStartIndex [
	^self indexOfDay: self startDay
]

{ #category : #'squeak protocol' }
Week >> asWeek [

	^ self
]

{ #category : #'squeak protocol' }
Week >> index [

	^ self asMonth dayOfWeek + self dayOfMonth - 2  // 7 + 1

]

{ #category : #'squeak protocol' }
Week >> printOn: aStream [

	aStream nextPutAll: 'a Week starting: '.
	self start printOn: aStream

]
