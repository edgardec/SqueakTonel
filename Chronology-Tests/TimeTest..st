"
This is the unit test for the class Time.


"
Class {
	#name : #TimeTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'time',
		'aTime',
		'localTimeZoneToRestore',
		'timeWithNanos',
		'localTimeZonePreferenceToRestore'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
TimeTest >> classToBeTested [

	^ self timeClass
]

{ #category : #Coverage }
TimeTest >> selectorsToBeIgnored [

	 | deprecated private special primitives timing benchmarks |

	deprecated := #().
	private := #( #print24:on: #print24:showSeconds:on: ).
	special := #( #< #= #new #printOn: #storeOn: ).
	primitives := #().
	timing := #( #millisecondClockValue #milliseconds:since: #millisecondsSince: ).
	benchmarks := #( #benchmarkMillisecondClock #benchmarkPrimitiveResponseDelay ). 

	^ super selectorsToBeIgnored, deprecated, private, special, primitives, timing, benchmarks.
]

{ #category : #Running }
TimeTest >> setUp [

	localTimeZoneToRestore := DateAndTime localTimeZone.
	localTimeZonePreferenceToRestore := DateAndTime automaticTimezone.
	DateAndTime localTimeZone: TimeZone default.
	time := self timeClass fromSeconds: 14567.		"4:02:47 am"
	aTime := self timeClass readFrom: '12:34:56 pm' readStream.
	timeWithNanos := self timeClass fromSeconds: 14567.42.

]

{ #category : #Running }
TimeTest >> tearDown [
	DateAndTime localTimeZone: localTimeZoneToRestore.
	DateAndTime automaticTimezone: localTimeZonePreferenceToRestore.
 
]

{ #category : #Tests }
TimeTest >> testAccessing [

	self
		assert: time hours = 4;
		assert: time minutes = 2;
		assert: time seconds = 47;
		assert: time asSeconds = 14567.

]

{ #category : #testing }
TimeTest >> testAddSeconds [
	self assert: (aTime addSeconds: 1) = (Time readFromString: '12:34:57').
	self assert: (aTime addSeconds: 60) = (Time readFromString: '12:35:56').	
	self assert: (aTime addSeconds: 3600) = (Time readFromString: '13:34:56').
	self assert: (aTime addSeconds: 24*60*60) = (Time readFromString: '12:34:56').
]

{ #category : #testing }
TimeTest >> testAddSecondsNanoSecondRollover [

	| time1 time2 time3 time4 time5 time6 time7 time8 |
	time1 := Time fromSeconds: 1.2s.
	time2 := time1 addSeconds: 1.3s.
	"n.b. use ticks second to access seconds instvar because #asSeconds is
	questionable and possibly subject to future change -dtl" 
	self assert: 2 equals: time2 ticks second.
	self assert: 500000000 equals: time2 nanoSecond.
	time3 := Time fromSeconds: 1.9s.
	time4 := time3 addSeconds: 1.2s.
	self assert: 3 equals: time4 ticks second.
	self assert: 100000000 equals: time4 nanoSecond.
	time5 := Time fromSeconds: 0.9s.
	time6 := time5 addSeconds: 0.2s.
	self assert: 1 equals: time6 ticks second.
	self assert: 100000000 equals: time6 nanoSecond.
	time7 := time5 addSeconds: 1.
	self assert: 1 equals: time7 ticks second.
	self assert: 900000000 equals: time7 nanoSecond.
	"midnight rollover"
	time8 := '11:59:59.505 pm' asTime addSeconds: 1.0101.
	self assert: 0 equals: time8 ticks second.
	self assert: 515100000 equals: time8 nanoSecond.

]

{ #category : #testing }
TimeTest >> testAddSecondsWithNanos [
	self assert: (timeWithNanos addSeconds: 1) = (Time readFromString: '4:02:48.42 am').
	self assert: (timeWithNanos addSeconds: 60) = (Time readFromString: '4:03:47.42 am').	
	self assert: (timeWithNanos addSeconds: 3600) = (Time readFromString: '5:02:47.42 am').
	self assert: (timeWithNanos addSeconds: 24*60*60) = (Time readFromString: '4:02:47.42 am').
	"rollover after midnight"
	self assert: (timeWithNanos addSeconds: 71832) = (Time readFromString: '11:59:59.42 pm').
	self assert: (timeWithNanos addSeconds: 71833) = (Time readFromString: '00:00:00.42 am').

]

{ #category : #testing }
TimeTest >> testAddTime [
	self assert: (aTime addTime: aTime) = (Time readFromString: '01:09:52').

]

{ #category : #Tests }
TimeTest >> testArithmetic [
	| t1 t2 t3 |
	t1 := time addSeconds: 70.		"4:03:57 am"
	self
		assert: t1 hours = 4;
		assert: t1 minutes = 3;
		assert: t1 seconds = 57.

	t2 := t1 addTime: (self timeClass fromSeconds: (60*60*5)).
	self
		assert: t2 hours = 9;
		assert: t2 minutes = 3;
		assert: t2 seconds = 57.

	t3 := t2 subtractTime: (self timeClass fromSeconds: (60*60*5) + 70).
	self
		assert: t3 = time.

]

{ #category : #testing }
TimeTest >> testAsDate [
	self assert: (aTime asDate) = (Date current)

]

{ #category : #testing }
TimeTest >> testAsDateAndTime [
	self assert: (aTime asDateAndTime) = (DateAndTime current midnight + aTime)

]

{ #category : #testing }
TimeTest >> testAsDuration [
	self assert: (aTime asDuration) = (Duration days: 0 hours: 12 minutes: 34 seconds: 56)

]

{ #category : #testing }
TimeTest >> testAsNanoSeconds [
	self assert: (aTime asNanoSeconds) = 45296000000000


]

{ #category : #testing }
TimeTest >> testAsSeconds [
	self assert: (aTime asSeconds) = 45296

]

{ #category : #testing }
TimeTest >> testAsTime [
	self assert: (aTime asTime) = aTime


]

{ #category : #testing }
TimeTest >> testAsTimeStamp [
	self assert: (aTime asTimeStamp) = (DateAndTime current midnight + aTime) asTimeStamp

]

{ #category : #testing }
TimeTest >> testAsWeek [
	self assert: aTime asWeek = (DateAndTime current midnight + aTime) asWeek

]

{ #category : #testing }
TimeTest >> testAsYear [
	self assert: aTime asYear = (DateAndTime current midnight + aTime) asYear

]

{ #category : #Tests }
TimeTest >> testComparing [
	| t1 t2 t3 |
	t1 := self timeClass fromSeconds: 14567.		"4:02:47 am"
	t2 := self timeClass fromSeconds: 5000.		"1:23:20 am"
	t3 := self timeClass fromSeconds: 80000.		"10:13:20 pm"

	self
		assert: time = t1;
		assert: time hash = t1 hash;
		assert: time = time copy.
	self
		deny: t1 < t2;
		assert: t1 < t3.
]

{ #category : #Tests }
TimeTest >> testConverting [

	self
		assert: time asSeconds = 14567.
]

{ #category : #testing }
TimeTest >> testDuration [
	self assert: aTime duration = 0 seconds
]

{ #category : #testing }
TimeTest >> testEqual [
	self assert: aTime = (Time readFromString: '12:34:56').
]

{ #category : #Tests }
TimeTest >> testFromSeconds [
	| t |
	t := self timeClass fromSeconds: 14567.
	self
		assert: t = time

]

{ #category : #Tests }
TimeTest >> testGeneralInquiries [
	| now d t dt epsilon |

	"vm clocks seem to work differently across platforms, so an epsilon is required"
	epsilon := 1. "second"
	now  := self timeClass dateAndTimeNow.
	self 
		assert: now size = 2;
		assert: (now last asSeconds - self timeClass now asSeconds) abs <= epsilon.

	self should: [ self timeClass timeWords ] raise: MessageNotUnderstood.

	d := '2 June 1973' asDate.
	t := '4:02:47 am' asTime.
	dt := self timeClass dateAndTimeFromSeconds: (2285280000 + 14567).
	self
		assert: dt = {d. t.}.

]

{ #category : #testing }
TimeTest >> testHash [
	self assert: aTime hash = (Character instSize > 0 ifTrue: [607004] ifFalse: [101409191])
]

{ #category : #testing }
TimeTest >> testHhmm24 [
	self assert: aTime hhmm24 = '1234'
]

{ #category : #testing }
TimeTest >> testHour [
	self assert: aTime hour =  12.
	self assert: aTime hour12 =  12.
	self assert: aTime hour24 =  12.
	self assert: aTime hours =  12.
]

{ #category : #testing }
TimeTest >> testHumanWordsForSecondsAgo [
	self assert: (Time humanWordsForSecondsAgo: 0.999999999)
			= 'a second ago'.
	self assert: (Time humanWordsForSecondsAgo: 44.99999999)
			= '44.99999999 seconds ago'.
	self assert: (Time humanWordsForSecondsAgo: 89.999999999)
			= 'a minute ago'.
	self assert: (Time humanWordsForSecondsAgo: 2699.999999999)
			= '44 minutes ago'.
	self assert: (Time humanWordsForSecondsAgo: 5399.999999999)
			= 'an hour ago'.
	self assert: (Time humanWordsForSecondsAgo: 64799.999999999)
			= '17 hours ago'.
	
]

{ #category : #testing }
TimeTest >> testHumanWordsForSecondsAgoWithDays [

	self assert: (Time humanWordsForSecondsAgo: 18 * 60 * 60)
					= 'yesterday'.
	self assert: (Time humanWordsForSecondsAgo: 24 * 60 * 60)
					= 'yesterday'.

]

{ #category : #testing }
TimeTest >> testLessThan [
	self assert: aTime < (Time readFromString: '12:34:57').
]

{ #category : #testing }
TimeTest >> testMeridianAbbreviation [
	self assert: aTime meridianAbbreviation =  'PM'.

]

{ #category : #testing }
TimeTest >> testMinute [
	self assert: aTime minute =  34.
	self assert: aTime minutes =  34

]

{ #category : #testing }
TimeTest >> testNanoSecond [
	self assert: aTime nanoSecond = 0
	"Right now all times all seconds"

]

{ #category : #Tests }
TimeTest >> testNew [
	
	self assert: self timeClass new asSeconds = 0
]

{ #category : #testing }
TimeTest >> testPrint24 [
	self assert: aTime print24 = '12:34:56'
]

{ #category : #testing }
TimeTest >> testPrint24On [
	| referenceString printed |
	referenceString := '12:34:56'.
	printed := WriteStream on: ''.
	aTime print24: true on: printed.
	self assert: printed contents = referenceString
]

{ #category : #testing }
TimeTest >> testPrint24OnWithPM [
	| referenceString printed |
	referenceString := '12:34:56 pm'.
	printed := WriteStream on: ''.
	aTime print24: false on: printed.
	^ self assert: printed contents = referenceString
]

{ #category : #testing }
TimeTest >> testPrint24OnWithoutSeconds [
	| referenceString printed |
	referenceString := '12:34'.
	printed := WriteStream on: ''.
	aTime print24: true showSeconds: false on: printed.
	self assert: printed contents = referenceString
]

{ #category : #testing }
TimeTest >> testPrintMinutes [
	self assert: aTime printMinutes = '12:34 pm'
]

{ #category : #testing }
TimeTest >> testPrintOn [
	| referenceString printed |
	referenceString := '12:34:56 pm'.
	printed := WriteStream on: ''.
	aTime printOn: printed.
	self assert: printed contents = referenceString
]

{ #category : #Tests }
TimeTest >> testPrinting [

	self	
		assert: time printString = '4:02:47 am';
		assert: time intervalString =  '4 hours 2 minutes 47 seconds';
		assert: time print24 = '04:02:47';
		assert: time printMinutes = '4:02 am';
		assert: time hhmm24 = '0402'.

]

{ #category : #Tests }
TimeTest >> testPrintingNanos [

	self	
		assert: timeWithNanos printString = '4:02:47.42 am';
		assert: timeWithNanos intervalString =  '4 hours 2 minutes 47 seconds';
		assert: timeWithNanos print24 = '04:02:47';
		assert: timeWithNanos printMinutes = '4:02 am';
		assert: timeWithNanos hhmm24 = '0402'.

]

{ #category : #Tests }
TimeTest >> testReadFrom [

	| t1 t2 |
	t1 := self timeClass readFrom: '4:02:47 am' readStream.
	t2 := self timeClass readFrom: '4:02:47.000 am' readStream.

	self
		assert: time = t1;
		assert: time = t2

]

{ #category : #testing }
TimeTest >> testSecond [
	self assert: aTime second =  56.
	self assert: aTime seconds =  56

]

{ #category : #Tests }
TimeTest >> testSqueakInquiries [
	| timewords totalseconds condensed corrected |
	self assert: 
		(self timeClass namesForTimes: #(2 10000023 10000026))
			= #('January, 1901' 'April, 1901, 4/26/1901, 5:47 pm' 'April, 1901, 4/26/1901, 5:47 pm').

	timewords := #(0.5 30 62 130 4000 10000 60000 86401) 
		collect: [ :ss | self timeClass humanWordsForSecondsAgo: ss ].
	self assert: 
		timewords = #('a second ago' '30 seconds ago' 'a minute ago' '2 minutes ago' 
			'an hour ago' '2 hours ago' '16 hours ago' 'yesterday').

	totalseconds :=  self timeClass totalSeconds.
	condensed := self timeClass condenseBunches: 
		(#(20 400 401  20000 20200 20300 40000 45000  200000 201000 202000) 
			collect: [:tt | totalseconds - tt]).
	corrected := condensed collect: [ :e | totalseconds - e ].
	self
		assert: (corrected includesAllOf: #(20 400 401 20000 40000 45000 200000)).

]

{ #category : #testing }
TimeTest >> testStoreOn [
	| referenceString stored |
	referenceString := '''12:34:56 pm'' asTime'.
	stored := WriteStream on: ''.
	aTime storeOn: stored.
	self assert: stored contents = referenceString
]

{ #category : #Tests }
TimeTest >> testStoring [

	self	
		assert: time storeString = '''4:02:47 am'' asTime';
		assert: time = ('4:02:47 am' asTime).

]

{ #category : #testing }
TimeTest >> testSubtractTime [
	self assert: (aTime subtractTime: aTime) = (Time readFrom: (ReadStream on: '00:00:00'))

]

{ #category : #testing }
TimeTest >> testTicks [
	self assert: aTime ticks = #(0 45296 0).
	self assert: aTime  = (Time new ticks: #(0 45296 0))
]

{ #category : #testing }
TimeTest >> testTimeStamp [
	self assert: aTime = aTime asTimeStamp asTime
]

{ #category : #Private }
TimeTest >> timeClass [

	^ Time
]
