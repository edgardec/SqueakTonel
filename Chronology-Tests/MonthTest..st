"
This is the unit test for the class Month.

"
Class {
	#name : #MonthTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'month'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
MonthTest >> classToBeTested [

	^ Month
]

{ #category : #Coverage }
MonthTest >> selectorsToBeIgnored [

	| deprecated private special |
	deprecated := #().
	private := #( #printOn: ).
	special := #( #next ).

	^ super selectorsToBeIgnored, deprecated, private, special.
]

{ #category : #Running }
MonthTest >> setUp [

	super setUp.
	month := Month month: 7 year: 1998.
]

{ #category : #Running }
MonthTest >> tearDown [

	super tearDown.
	month := nil.
]

{ #category : #Tests }
MonthTest >> testConverting [

	self assert: month asDate = '1 July 1998' asDate
]

{ #category : #Tests }
MonthTest >> testEnumerating [
	| weeks |
	weeks := OrderedCollection new.
	month weeksDo: [ :w | weeks add: w start ].
	0 to: 4 do: [ :i | weeks remove: (Week starting:  ('29 June 1998' asDate addDays: i * 7)) start ].
	self assert: weeks isEmpty
]

{ #category : #Tests }
MonthTest >> testIndexOfMonth [

	| m |
	m := #(#January #February #March #April #May #June #July #August #September #October #November #December).
	
	m withIndexDo: [:item :index | self assert: (Month indexOfMonth: item) = index].
	
	self should: [Month indexOfMonth: 1] raise: TestResult error.
	self should: [Month indexOfMonth: #'1'] raise: TestResult error.
	self should: [Month indexOfMonth: #Marsh] raise: TestResult error. "notice the misspell!"
	self should: [Month indexOfMonth: #UnexistingMonth] raise: TestResult error.
]

{ #category : #Tests }
MonthTest >> testInquiries [

	self 
		assert: month index = 7;
		assert: month name = #July;
		assert: month duration = (31 days).

]

{ #category : #Tests }
MonthTest >> testInstanceCreation [
	| m1 m2 |
	m1 := Month starting:  '4 July 1998' asDate.
	m2 := Month month: #July year: 1998.
	self
		assert: month = m1;
		assert: month = m2
]

{ #category : #Tests }
MonthTest >> testNameOfMonth [

	| m |
	m := #(#January #February #March #April #May #June #July #August #September #October #November #December).
	
	m withIndexDo: [:item :index | self assert: (Month nameOfMonth: index) = item].
	
	self should: [Month nameOfMonth: 0] raise: TestResult error.
	self should: [Month nameOfMonth: 13] raise: TestResult error.
	self should: [Month nameOfMonth: #January] raise: TestResult error.
]

{ #category : #Tests }
MonthTest >> testPreviousNext [
	| n p |
	n := month next.
	p := month previous.

	self
		assert: n year = 1998;
		assert: n index = 8;
		assert: p year = 1998;
		assert: p index = 6.


]

{ #category : #Tests }
MonthTest >> testPrinting [

	self 
		assert: month printString = 'July 1998'.

]

{ #category : #Tests }
MonthTest >> testReadFrom [

	| m |
	m := Month readFrom: 'July 1998' readStream.
	self 
		assert: m = month
]
