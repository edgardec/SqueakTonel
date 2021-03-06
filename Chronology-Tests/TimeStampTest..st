"
This is the unit test for the class TimeStamp.
"
Class {
	#name : #TimeStampTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'timestamp',
		'aTimeStamp'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
TimeStampTest >> classToBeTested [

	^ self timestampClass
]

{ #category : #Coverage }
TimeStampTest >> selectorsToBeIgnored [

	| deprecated private special |

	deprecated := #().
	private := #( #printOn: ).
	special := #().

	^ super selectorsToBeIgnored, deprecated, private, special.
]

{ #category : #Running }
TimeStampTest >> setUp [

	timestamp := self timestampClass date: ('1-10-2000' asDate) time: ('11:55:00 am' asTime).

	aTimeStamp := TimeStamp readFrom: '1-02-2004 12:34:56 am' readStream
]

{ #category : #Running }
TimeStampTest >> tearDown [

	timestamp := nil.
]

{ #category : #Tests }
TimeStampTest >> testAccessing [

	| d t |
	d := '1-10-2000' asDate.
	t := '11:55:00 am' asTime.

	self
		assert: (timestamp offset: Date defaultOffset) date = d;
		assert: (timestamp offset: Date defaultOffset) time = t.

]

{ #category : #Tests }
TimeStampTest >> testArithmetic [

	| ts |
	ts := timestamp minusDays: 123.  	"9 September 1999, 11:55 am"
	ts := ts minusSeconds: 1056.			"9 September 1999, 11:37:24 am"
	ts := ts plusDays: 123.				"10 January 2000, 11:37:24 am"
	ts := ts plusSeconds: 1056.			"10 January 2000, 11:55 am"
	self
		assert: ts  = timestamp.

	
]

{ #category : #Tests }
TimeStampTest >> testArithmeticAcrossDateBoundary [

	| ts |
	ts := timestamp minusSeconds: ((11*3600) + (55*60) + 1).
	self
		assert: ts = ('1-9-2000 11:59:59 pm' asTimeStamp).

	
]

{ #category : #Tests }
TimeStampTest >> testComparing [

	| ts1 ts2 ts3 c1 c2 le |
	ts1 := self timestampClass date: ('01-10-2000' asDate) time: ('11:55:00 am' asTime).
	ts2 := self timestampClass date: ('07-26-2003' asDate) time: ('22:09:45 am' asTime).
	ts3 := self timestampClass date: ('05-28-1972' asDate) time: ('04:31:14 pm' asTime).

	self
		assert: ts1 = timestamp;
		assert: ts1 hash = timestamp hash;
		assert: timestamp = timestamp copy;
		assert: ts1 < ts2;
		deny: ts1 < ts3.

	c1 := self timestampClass current.
	c2 := self timestampClass current.
	le := (c1 <= c2).
	self assert: le.


]

{ #category : #Tests }
TimeStampTest >> testConverting [

	| d t |
	d := '1-10-2000' asDate.
	t := '11:55:00 am' asTime.

	self
		assert: timestamp asSeconds = (d asSeconds + t asSeconds);
		assert: timestamp asDate = d;
		assert: timestamp asTime = t;
		assert: timestamp asTimeStamp == timestamp;
		assert: timestamp dateAndTime = {d. t}.

]

{ #category : #testing }
TimeStampTest >> testDate [
	self assert: aTimeStamp date = '01-02-2004' asDate
]

{ #category : #testing }
TimeStampTest >> testDateAndTime [
	self assert: aTimeStamp dateAndTime
			= (Array with: '01-02-2004' asDate with: '00:34:56' asTime)
]

{ #category : #Tests }
TimeStampTest >> testFromSeconds [

	self
		assert: (self timestampClass fromSeconds: 3124958100) = timestamp.
]

{ #category : #Tests }
TimeStampTest >> testFromString [
	"This should signal an exception in 3.6beta as Time>>fromString: does not exist."

	self should: [ timestamp = (self timestampClass fromString: '1-10-2000 11:55:00 am') ] 


]

{ #category : #Tests }
TimeStampTest >> testInstanceCreation [

	self 
		should: [ self timestampClass midnight asDuration = (0 hours) ];
		should: [ self timestampClass noon asDuration = (12 hours) ].

]

{ #category : #testing }
TimeStampTest >> testMinusDays [
	self assert: (aTimeStamp minusDays: 5) dateAndTime
			= (Array with: '12-28-2003' asDate with: '00:34:56' asTime)
]

{ #category : #testing }
TimeStampTest >> testMinusSeconds [
	self assert: (aTimeStamp minusSeconds: 34 * 60 + 56) dateAndTime
			= (Array with: '01-02-2004' asDate with: '00:00:00' asTime)
]

{ #category : #testing }
TimeStampTest >> testMinusSecondsOverMidnight [
	self assert: (aTimeStamp minusSeconds: 34 * 60 + 57) dateAndTime
			= (Array with: '01-01-2004' asDate with: '23:59:59' asTime)
	"Bug The results are actual results are: #(1 January 2005 11:25:03 pm)"
]

{ #category : #testing }
TimeStampTest >> testPlusDays [
	self assert: (aTimeStamp plusDays: 366) dateAndTime
			= (Array with: '01-02-2005' asDate with: '00:34:56' asTime)
]

{ #category : #testing }
TimeStampTest >> testPlusSeconds [
	self assert: (aTimeStamp plusSeconds: 60 * 60 ) dateAndTime
			= (Array with: '01-02-2004' asDate with: '01:34:56' asTime)
]

{ #category : #testing }
TimeStampTest >> testPlusSecondsOverMidnight [
	self assert: (aTimeStamp plusSeconds: 24 * 60 * 60 + 1) dateAndTime
			= (Array with: '01-03-2004' asDate with: '00:34:57' asTime)
]

{ #category : #testing }
TimeStampTest >> testPrintOn [
	| ref ws |
	ref := '2 January 2004 12:34:56 am'.
	ws := '' writeStream.
	aTimeStamp printOn: ws.
	self assert: ws contents = ref
]

{ #category : #Tests }
TimeStampTest >> testPrinting [

	self	
		assert: timestamp printString = '10 January 2000 11:55 am'.

]

{ #category : #testing }
TimeStampTest >> testReadFromA1 [
	"Conversion to and from a string (with implied UTC offset) is equal if
	and only if the time stamp has zero offset."
	|ts|
	ts := TimeStamp current offset: Duration zero. "current as UTC"
	self assert: (ts = (TimeStamp fromString: ts asString)).
	ts := TimeStamp current offset: (Duration hours: 1).
	self deny: (ts = (TimeStamp fromString: ts asString)).

]

{ #category : #Tests }
TimeStampTest >> testSorting [

	| c1 c2 |
	c1 := self timestampClass current.
	c2 := self timestampClass current.

	self
		assert: (self timestampClass current) <= (self timestampClass current);
		assert: (c1 <= c2).



]

{ #category : #testing }
TimeStampTest >> testStoreOn [
	| ref ws |
	ref := '''2 January 2004 12:34:56 am'' asTimeStamp'.
	ws := '' writeStream.
	aTimeStamp storeOn: ws.
	self assert: ws contents = ref
]

{ #category : #testing }
TimeStampTest >> testTime [
	self assert: aTimeStamp time =  '00:34:56' asTime
]

{ #category : #testing }
TimeStampTest >> testTimeStamp [
	self assert: aTimeStamp = aTimeStamp asTimeStamp

]

{ #category : #Private }
TimeStampTest >> timestampClass [

	^ TimeStamp
]
