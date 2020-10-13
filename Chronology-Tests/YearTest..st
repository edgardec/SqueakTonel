Class {
	#name : #YearTest,
	#superclass : #ClassTestCase,
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
YearTest >> classToBeTested [

	^ Year
]

{ #category : #Tests }
YearTest >> testCurrent [
	self assert:
		Year current start =
			((DateAndTime
				year: DateAndTime now year
				month: 1
				day: 1) offset: Year defaultOffset)
]

{ #category : #Tests }
YearTest >> testPreviousInLeapYear [

	| leap |
	leap := Year year: 2008.
	self assert: leap isLeapYear. 
	self assert: (Year year: (leap year - 1)) = leap previous 
]
