"
I represent a year.

Try me! Select the following expression and print it:

Year current daysInYear ""Try me again next leap year!""
"
Class {
	#name : #Year,
	#superclass : #Timespan,
	#category : #'Chronology-Core'
}

{ #category : #'squeak protocol' }
Year class >> current [
 
	^ self year: (DateAndTime now year)

]

{ #category : #'smalltalk-80' }
Year class >> daysInYear: yearInteger [

	^ 365 + ((self isLeapYear: yearInteger) ifTrue: [1] ifFalse: [0]).

]

{ #category : #'squeak protocol' }
Year class >> isLeapYear: aYearInteger [


	| adjustedYear |
	adjustedYear := aYearInteger > 0
		ifTrue: [aYearInteger]
		ifFalse: [(aYearInteger + 1) negated].

	"There was no year 0"
	^ ((adjustedYear \\ 4 ~= 0) or: [(adjustedYear \\ 100 = 0) and: [adjustedYear \\ 400 ~= 0]]) not
]

{ #category : #'smalltalk-80' }
Year class >> leapYear: yearInteger [ 

	^ (self isLeapYear: yearInteger)
		ifTrue: [1]
		ifFalse: [0]
]

{ #category : #'squeak protocol' }
Year class >> starting: aDateAndTime duration: aDuration [ 
	"Override - start from midnight"
	| midnight |
	midnight := aDateAndTime asDateAndTime midnight.

	^ super
		starting: midnight
		duration: (Duration days: (self daysInYear: midnight year))
]

{ #category : #'squeak protocol' }
Year class >> year: aYear [ 
	^ self starting:
		(DateAndTime
			year: aYear
			month: 1
			day: 1
			hour: 0
			minute: 0
			second: 0
			offset: self defaultOffset)
]

{ #category : #'squeak protocol' }
Year >> asYear [


	^ self
]

{ #category : #'squeak protocol' }
Year >> daysInMonth [


	self shouldNotImplement
]

{ #category : #'squeak protocol' }
Year >> daysInYear [

	^ self duration days.
]

{ #category : #'smalltalk-80' }
Year >> previous [
	"This implementation handles leap years correctly"
	
	^ self class year: (self year - 1)
]

{ #category : #'squeak protocol' }
Year >> printOn: aStream [

	aStream nextPutAll: 'a Year ('.
	self start year printOn: aStream.

	aStream nextPutAll: ')'

]
