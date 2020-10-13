"
I represent a month.

For example, to get the number of days this month, you can evaluate the following expression:

Month current daysInMonth
"
Class {
	#name : #Month,
	#superclass : #Timespan,
	#pools : [
		'ChronologyConstants'
	],
	#category : #'Chronology-Core'
}

{ #category : #'smalltalk-80' }
Month class >> daysInMonth: indexOrName forYear: yearInteger [ 

	| index |
	index := indexOrName isInteger 
				ifTrue: [indexOrName]
				ifFalse: [self indexOfMonth: indexOrName].
	^ (DaysInMonth at: index)
			+ ((index = 2
					and: [Year isLeapYear: yearInteger])
						ifTrue: [1] ifFalse: [0])

]

{ #category : #'smalltalk-80' }
Month class >> indexOfMonth: aMonthName [


	1 to: 12 do: [ :i |  (aMonthName, '*' match: (MonthNames at: i)) ifTrue: [^i] ].
	self error: aMonthName , ' is not a recognized month name'.
]

{ #category : #'squeak protocol' }
Month class >> month: month year: year [ 
	"Create a Month for the given <year> and <month>.
	<month> may be a number or a String with the
	name of the month. <year> should be with 4 digits."
	^ self starting:
		(DateAndTime
			year: year
			month: month
			day: 1
			hour: 0
			minute: 0
			second: 0
			offset: self defaultOffset)
]

{ #category : #'smalltalk-80' }
Month class >> nameOfMonth: anIndex [

	^ MonthNames at: anIndex.
]

{ #category : #'squeak protocol' }
Month class >> readFrom: aStream [
	| m y |
	aStream skipSeparators.
	m := aStream upToAnyOf: CharacterSet separators.
	aStream skipSeparators.
	y := aStream upToEnd.
	^ self 
		month: m
		year: y asInteger

"Month readFrom: 'July 1998' readStream"
]

{ #category : #'squeak protocol' }
Month class >> starting: aDateAndTime duration: aDuration [ 
	"Override - a each month has a defined duration"
	| start adjusted days |
	start := aDateAndTime asDateAndTime.
	adjusted := DateAndTime
		year: start year
		month: start month
		day: 1
		hour: 0
		minute: 0
		second: 0
		offset: start offset.
	days := self
		daysInMonth: adjusted month
		forYear: adjusted year.
	^ super
		starting: adjusted
		duration: (Duration days: days)
]

{ #category : #'squeak protocol' }
Month >> asMonth [

	^ self
]

{ #category : #'squeak protocol' }
Month >> daysInMonth [

	^ self duration days.
]

{ #category : #'squeak protocol' }
Month >> index [

	^ self monthIndex
]

{ #category : #'squeak protocol' }
Month >> name [


	^ self monthName
]

{ #category : #'squeak protocol' }
Month >> previous [


	^ self class starting: (self start - 1)
]

{ #category : #'squeak protocol' }
Month >> printOn: aStream [


	aStream nextPutAll: self monthName, ' ', self year printString
]
