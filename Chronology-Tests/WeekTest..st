Class {
	#name : #WeekTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'week',
		'restoredStartDay'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
WeekTest >> classToBeTested [

	^ Week
]

{ #category : #Coverage }
WeekTest >> selectorsToBeIgnored [

	| deprecated private special |

	deprecated := #().
	private := #( #printOn: ).
	special := #( #next #do: ).

	^ super selectorsToBeIgnored, deprecated, private, special.
]

{ #category : #Running }
WeekTest >> setUp [
	"June 1998, 5th week"

	super setUp.
	restoredStartDay := Week startDay.
	Week startDay: #Sunday.
	week := Week starting: '4 July 1998' asDate
]

{ #category : #Running }
WeekTest >> tearDown [

	super tearDown.
	Week startDay: restoredStartDay.
	week := nil.


]

{ #category : #Tests }
WeekTest >> testDayNames [
	self assert: (Week dayNames) = #(#Sunday #Monday #Tuesday #Wednesday #Thursday #Friday #Saturday).
]

{ #category : #Tests }
WeekTest >> testEnumerating [

	| days |
	days := OrderedCollection new.
	0 to: 6 do: [ :i | days add: ('28 June 1998' asDate addDays: i) ].

	week datesDo: [ :d | days remove: d ].
	
	self assert: days isEmpty.

]

{ #category : #Tests }
WeekTest >> testIndexOfDay [
	| days |
	days := #(#Sunday #Monday #Tuesday #Wednesday #Thursday #Friday #Saturday).
	
	days withIndexDo: [:item :index | self assert: (Week indexOfDay: item) = index].
	
	"This should probably raise an error rather than returning 0."
	self assert: (Week indexOfDay: 0) = 0.
	self assert: (Week indexOfDay: 1) = 0.
	self assert: (Week indexOfDay: 7) = 0.
	self assert: (Week indexOfDay: 8) = 0.
	self assert: (Week indexOfDay: #Sunnyday) = 0.
]

{ #category : #Tests }
WeekTest >> testInquiries [

	self
		assert: week start asDate = '28 June 1998' asDate;
		assert: week end asDate = '4 July 1998' asDate;
		assert: week index = 5;
		assert: week duration = (7 days).

]

{ #category : #Tests }
WeekTest >> testNameOfDay [
	| days |
	days := #(#Sunday #Monday #Tuesday #Wednesday #Thursday #Friday #Saturday).
	
	days withIndexDo: [:item :index | self assert: (Week nameOfDay: index) = item].
	
	self should: [Week nameOfDay: 0] raise: TestResult error.
	self should: [Week nameOfDay: 8] raise: TestResult error.
	self should: [Week nameOfDay: #Sunday] raise: TestResult error.
]

{ #category : #Tests }
WeekTest >> testPreviousNext [
	self
		assert: week next = (Week starting: '6 July 1998' asDate);
		assert: week previous = (Week starting:  '22 June 1998' asDate)
]