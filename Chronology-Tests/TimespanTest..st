Class {
	#name : #TimespanTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'timespan',
		'aTimespan',
		'anOverlappingTimespan',
		'anIncludedTimespan',
		'aDisjointTimespan',
		'aDay',
		'aWeek',
		'dec31',
		'jan01',
		'jan08',
		'localTimeZoneToRestore',
		'anEqualTimeSpan',
		'localTimeZonePreferenceToRestore'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
TimespanTest >> classToBeTested [

	^ Timespan

]

{ #category : #Running }
TimespanTest >> setUp [

	| jan01HereSomeWhereElseOnEarth |
	localTimeZoneToRestore := DateAndTime localTimeZone.
	localTimeZonePreferenceToRestore := DateAndTime automaticTimezone.
	DateAndTime localTimeZone: TimeZone default.

	"100 hours starting noon 22 March 2003"
	timespan := Timespan starting:
					(DateAndTime year: 2003 month: 03 day: 22 hour: 12 minute: 0 second: 0)
						duration: (Duration hours: 100).

	dec31 := (DateAndTime year: 2004 month: 12 day: 31 hour: 0 minute: 0 second: 0).
	jan01 := (DateAndTime year: 2005 month: 1 day: 1 hour: 0 minute: 0 second: 0).
	jan08 := (DateAndTime year: 2005 month: 1 day: 8 hour: 0 minute: 0 second:0).
	aDay := Duration days: 1 hours: 0 minutes: 0 seconds: 0 nanoSeconds: 0.
	aWeek := Duration days: 7 hours: 0 minutes: 0 seconds: 0 nanoSeconds: 0.
	aTimespan := Timespan starting: jan01 duration: aWeek.
	jan01HereSomeWhereElseOnEarth := DateAndTime new ticks: (jan01 + 3 hours) ticks offset: jan01 offset + 3 hours.
	anEqualTimeSpan := Timespan starting: jan01HereSomeWhereElseOnEarth asUTC duration: aWeek.
	anOverlappingTimespan := Timespan starting: dec31 duration: aWeek.
	anIncludedTimespan := Timespan starting: jan01 duration: aDay.
	aDisjointTimespan := Timespan starting: jan08 duration: aWeek.




]

{ #category : #Running }
TimespanTest >> tearDown [
	DateAndTime localTimeZone: localTimeZoneToRestore.
	DateAndTime automaticTimezone: localTimeZonePreferenceToRestore.
 	timespan := nil

]

{ #category : #Tests }
TimespanTest >> testAccessing [

	self 
		assert: (timespan start =
				 (DateAndTime year: 2003 month: 03 day: 22 hour: 12 minute: 0 second: 0));
		assert: timespan duration = (Duration hours: 100);
		assert: timespan month = 3;
		assert: timespan monthName = 'March';
		assert: timespan monthAbbreviation = 'Mar'
		


]

{ #category : #Tests }
TimespanTest >> testArithmetic [

	| ts1 ts2 d |
	ts1 := timespan + 2 days.
	ts2 := ts1 - 2 days.
	d := ts1 - (DateAndTime year: 2003 month: 03 day: 20).

	self 
		assert: (ts1 start = 
				 (DateAndTime year: 2003 month: 03 day: 24 hour: 12 minute: 0 second: 0));
		assert: (ts1 duration = timespan duration);
		assert: (ts2 start = timespan start);
		assert: (ts2 duration = timespan duration).

	self
		assert: d = (Duration days: 4 hours: 12 minutes: 0 seconds: 0)


]

{ #category : #testing }
TimespanTest >> testAsDate [
	self assert: aTimespan asDate =   jan01 asDate.
	"MessageNotUnderstood: Date class>>starting:"

]

{ #category : #testing }
TimespanTest >> testAsDateAndTime [
	self assert: aTimespan asDateAndTime =   jan01.
	"MessageNotUnderstood: Date class>>starting:"
	

]

{ #category : #testing }
TimespanTest >> testAsDuration [
	self assert: aTimespan asDuration =  aWeek.

	
	

]

{ #category : #testing }
TimespanTest >> testAsMonth [
	self assert: aTimespan asMonth =   jan01 asMonth.

]

{ #category : #testing }
TimespanTest >> testAsTime [
	self assert: aTimespan asTime =  jan01 asTime
	"MessageNotUnderstood: Time class>>seconds:nanoSeconds:"
 
]

{ #category : #testing }
TimespanTest >> testAsTimeStamp [
	self assert: aTimespan asTimeStamp =  ((TimeStamp readFrom: '1-01-2005 0:00 am' readStream) offset: 0 hours).

]

{ #category : #testing }
TimespanTest >> testAsWeek [
	self assert: aTimespan asWeek =   jan01 asWeek.
	"DateAndTime new asWeek
	 MessageNotUnderstood: Week class>>starting:"

]

{ #category : #testing }
TimespanTest >> testAsYear [
	self assert: aTimespan asYear =   jan01 asYear.


]

{ #category : #Tests }
TimespanTest >> testBeCanonical [

	| start ts1 ts2 ts3 |
	start := '2019-01-27T17:11:40.061188-05:00' asDateAndTime.
	ts1 := Timespan starting: start duration: 123456 seconds.
	ts2 := ts1 deepCopy.
	ts3 := ts2 beCanonical.
	self assert: ts2
		identical: ts3
		description: 'beCanonical modifies the receiver, not a copy thereof'.
	self deny: ts3 = ts1.
	self assert: '2019-01-27T17:11:40.061188-05:00' asDateAndTime
		equals: ts1 start
		description: 'original timespan start is not modified'.
	self assert: ts1 duration
		equals: ts3 duration
		description: 'duration does not change'.
	self assert: '2019-01-27T17:11:40.061188+00:00' asDateAndTime
		equals: ts3 start.
	self deny: ts1 start = ts3 start
		description: 'magnitude of start time is changed'.
	self assert: 5 hours
		equals: start - ts3 start
		description: 'magnitude of start time is changed'.
	self assert: 0 seconds
		equals: ts3 start offset
		description: 'time zone offset is zero'.
	self assert: 5 hours negated
		equals: ts1 start offset
		description: 'original timezone was -18000'.

]

{ #category : #testing }
TimespanTest >> testClockPrecisionDuration [
	| ts |
	ts := Timespan starting: Date today duration: DateAndTime clockPrecision.
	self
		assert: ts start = ts end
]

{ #category : #testing }
TimespanTest >> testCurrent [
	self assert: (Timespan starting: DateAndTime current)
			<= Timespan current.
	self assert:  Timespan current
			<= (Timespan starting: DateAndTime current)
]

{ #category : #testing }
TimespanTest >> testDateToday [
	self assert: Date today start offset isZero
]

{ #category : #testing }
TimespanTest >> testDay [
	self assert: aTimespan day =   jan01 day

]

{ #category : #testing }
TimespanTest >> testDayOfMonth [
	self assert: aTimespan dayOfMonth  = 1.

]

{ #category : #testing }
TimespanTest >> testDayOfWeek [
	self assert: aTimespan  dayOfWeek  = 7.
	self assert: aTimespan  dayOfWeekName = 'Saturday'.

]

{ #category : #testing }
TimespanTest >> testDayOfYear [
	self assert: aTimespan  dayOfYear  = 1.
	"MessageNotUnderstood: UndefinedObject>>year:, Undefined object is Year class"

]

{ #category : #testing }
TimespanTest >> testDaysInMonth [
	self assert: aTimespan  daysInMonth  = 31.
	"MessageNotUnderstood: Month class>>starting:"

]

{ #category : #testing }
TimespanTest >> testDaysInYear [
	self assert: aTimespan  daysInYear  = 365.
	"MessageNotUnderstood: UndefinedObject>>starting:  UndefinedObject is Year class"

]

{ #category : #testing }
TimespanTest >> testDaysLeftInYear [
	self assert: aTimespan  daysLeftInYear  = 364.
	"MessageNotUnderstood: UndefinedObject>>starting:  UndefinedObject is Year class"

]

{ #category : #testing }
TimespanTest >> testDoWith [
	| count |
	count := 0.
	aTimespan
		do: [:each | count := count + 1]
		with: (Timespan starting: jan01 duration: aDay).
	self assert: count = 7
]

{ #category : #testing }
TimespanTest >> testDoWithWhen [
	| count |
	count := 0.
	aTimespan
		do: [:each | count := count + 1]
		with: (Timespan starting: jan01 duration: aDay)
		when: [:each | count < 5].
	self assert: count = 5
]

{ #category : #testing }
TimespanTest >> testDuration [
	self assert: aTimespan duration  = aWeek.
	aTimespan duration: aDay.
	self assert: aTimespan duration =  aDay.


]

{ #category : #testing }
TimespanTest >> testEnd [
	self assert: aTimespan end + (Duration  nanoSeconds:1)  =  aDisjointTimespan start.
	self assert: aTimespan end = (DateAndTime year: 2005 month: 1 day: 7 hour: 23 minute: 59 second: 59 nanoSecond: 999999999 offset: 0 hours)

]

{ #category : #testing }
TimespanTest >> testEveryDo [
	| count duration |
	count := 0.
	duration := 7 days.
	aTimespan
		every: duration
		do: [:each | count := count + 1].
	self assert: count = 1
]

{ #category : #testing }
TimespanTest >> testFirstDayOfMonth [
	self assert: aTimespan firstDayOfMonth =   1. 
	self assert: aDisjointTimespan firstDayOfMonth =   1

]

{ #category : #testing }
TimespanTest >> testHash [
	self assert: (aTimespan = anEqualTimeSpan) ==> [aTimespan hash = anEqualTimeSpan hash]
]

{ #category : #testing }
TimespanTest >> testIncludes [
	self assert: (aTimespan includes: jan01).
	self deny: (aTimespan includes: jan08)

]

{ #category : #testing }
TimespanTest >> testIncludesAllOf [
	self assert: (aTimespan includesAllOf: (Bag with: jan01)).
	self deny: (aTimespan includesAllOf: (Bag with: jan01 with: jan08))

]

{ #category : #testing }
TimespanTest >> testIncludesAnyOf [
	self deny: (aTimespan includesAnyOf: (Bag with: dec31)).
	self assert: (aTimespan includesAnyOf: (Bag with: jan01 with: jan08))
	"Error is due to bug in Timespan 
includesAnyOf: aCollection "
	"Answer whether any element of aCollection is included in the receiver"
	"aCollection do: [ :elem | (self includes: elem) ifTrue: [^ true]].
Shouldn't this return false if none are included?
"

]

{ #category : #Tests }
TimespanTest >> testInclusion [

	| t1 t2 t3 t4 |
	t1 := timespan start.
	t2 := timespan start + (timespan duration / 2).
	t3 := timespan end.
	t4 := timespan start + (timespan duration).

	self 
		assert: (timespan includes: t1);
		assert: (timespan includes: t2);
		assert: (timespan includes: t3)";
		deny: (timespan includes: t4).
	self
		assert: (timespan includes: (t1 to: t2));
		assert: (timespan includes: (t1 to: t4));
		deny: (timespan includes: (Timespan starting: t2 duration: (timespan duration * 2))).
	self 
		assert: (timespan includesAllOf: { t1. t2. t3 } );
		deny: (timespan includesAllOf: { t1. t2. t3. t4} ).
	self 
		assert: (timespan includesAnyOf: { t1. t2. t3 } );
		deny: (timespan includesAnyOf: { t4 } ).
"
]

{ #category : #testing }
TimespanTest >> testIntersectionWithDisjoint [
	self assert: (aTimespan intersection: aDisjointTimespan) isNil.

]

{ #category : #testing }
TimespanTest >> testIntersectionWithIncluded [
	self assert: (aTimespan intersection: anIncludedTimespan)  = 
	(Timespan starting: jan01 duration: (Duration days: 0 hours: 23 minutes: 59 seconds: 59 nanoSeconds: 999999999)).		
	self deny: (aTimespan intersection: anIncludedTimespan)	= anIncludedTimespan

]

{ #category : #testing }
TimespanTest >> testIntersectionWithOverlapping [
	self assert: (aTimespan intersection: anOverlappingTimespan)  = 
	(Timespan starting: jan01 duration: (Duration days: 5 hours: 23 minutes: 59 seconds: 59 nanoSeconds: 999999999)).		


]

{ #category : #testing }
TimespanTest >> testIntersectionWithSelf [
	self assert: (aTimespan intersection: aTimespan)  = 
	(Timespan starting: jan01 duration: (Duration days: 6 hours: 23 minutes: 59 seconds: 59 nanoSeconds: 999999999)).		
	self deny: (aTimespan intersection: anIncludedTimespan)	= aTimespan

]

{ #category : #testing }
TimespanTest >> testIntersectionWithSeparate [
	self assert: (aTimespan intersection: aDisjointTimespan) isNil.
	self deny: (aTimespan intersection: anOverlappingTimespan) isNil.
	self assert: (aTimespan intersection: anIncludedTimespan)  = 
	(Timespan starting: jan01 duration: (Duration days: 0 hours: 23 minutes: 59 seconds: 59 nanoSeconds: 999999999)).		
	self deny: (aTimespan intersection: anIncludedTimespan)	= anIncludedTimespan

]

{ #category : #testing }
TimespanTest >> testIsLeapYear [
	"self assert: anOverlappingTimespan isLeapYear."
	"not sure why this fails"
	self deny: aTimespan isLeapYear

]

{ #category : #testing }
TimespanTest >> testJulianDayNumber [
	self assert: aTimespan julianDayNumber =  (jan01 julianDayNumber).

]

{ #category : #testing }
TimespanTest >> testLessThan [
	self assert: aTimespan  < aDisjointTimespan.
	self deny: anIncludedTimespan < aTimespan
	
]

{ #category : #testing }
TimespanTest >> testMinusADateAndTime [
	"It appears that subtracting a date from a Timespan gives you a duration = to the difference between the start of the timespan and the date "
	self assert: aTimespan - dec31 =  aDay.
	self assert: aDisjointTimespan - jan01 =  aWeek.



]

{ #category : #testing }
TimespanTest >> testMinusADuration [
	"It appears that subtracting a duration from a Timespan gives you a Timespan shifted by the duration"
	self assert: aTimespan - aDay =  anOverlappingTimespan.
	self assert: aDisjointTimespan - aWeek =  aTimespan.	



]

{ #category : #testing }
TimespanTest >> testMonth [
	self assert: aTimespan month  = 1.
	self assert: aTimespan monthName = 'January'.
	self assert: aTimespan monthIndex = 1.
]

{ #category : #testing }
TimespanTest >> testNew [
	self assert: Timespan new = (Timespan starting: '01-01-1901' asDate)
]

{ #category : #testing }
TimespanTest >> testNext [
	self assert: aTimespan next = aDisjointTimespan

]

{ #category : #testing }
TimespanTest >> testPlus [
	self assert: aTimespan + aWeek = aDisjointTimespan.
	self assert: anOverlappingTimespan + aDay = aTimespan.

]

{ #category : #testing }
TimespanTest >> testPrevious [
	self assert: aTimespan  = aDisjointTimespan previous.
	self assert: aTimespan next previous = aTimespan 

]

{ #category : #testing }
TimespanTest >> testPrintOn [
	| ref ws |
	ref := 'a Timespan(2005-01-01T00:00:00+00:00D7:00:00:00)'.
	ws := '' writeStream.
	aTimespan printOn: ws.
	self assert: ws contents = ref

]

{ #category : #testing }
TimespanTest >> testRematerializedDateComparison [
	"Tests whether comparison semantics are affected by serialization / rematerialization."
	| isItTrue date refStream rwstream | date := Date today.
	isItTrue := DateAndTime now asDate = date.
	self assert: (date = DateAndTime now asDate) = isItTrue.
	self assert: (DateAndTime now asDate = date) = isItTrue.
	rwstream := RWBinaryOrTextStream on: ByteArray new.
	refStream := ReferenceStream on: rwstream..
	refStream nextPut: date; close.
	rwstream position: 0.
	refStream := ReferenceStream on: rwstream.
	date := refStream next.
	refStream close.
	self assert: (date = DateAndTime now asDate) = isItTrue.
	self assert: (DateAndTime now asDate = date) = isItTrue.

]

{ #category : #testing }
TimespanTest >> testStart [
	self assert: aTimespan start =   jan01.
	aTimespan start: jan08.
	self assert: aTimespan start =   jan08.
]

{ #category : #testing }
TimespanTest >> testStartingEnding [
	self assert: aTimespan  = (Timespan starting: jan01 ending: jan08)

]

{ #category : #testing }
TimespanTest >> testTo [
	self assert: (anIncludedTimespan to: jan08) = aTimespan 

]

{ #category : #Tests }
TimespanTest >> testUnion [

	| union |
	union := timespan union: timespan.
	
	self 
		assert: (union start = timespan start);
		assert: (union duration = timespan duration)

]

{ #category : #testing }
TimespanTest >> testUnionWithDisjoint [

	self assert: (aTimespan union: aDisjointTimespan)  = 
		(Timespan starting: jan01 duration: (14 days)).	
			

]

{ #category : #testing }
TimespanTest >> testUnionWithIncluded [

	self 
		assert: (aTimespan union: anIncludedTimespan) = aTimespan 	
]

{ #category : #testing }
TimespanTest >> testUnionWithOverlapping [

	self 
		assert: (aTimespan union: anOverlappingTimespan)  = 
				(Timespan starting: dec31 duration: (8 days))
]

{ #category : #testing }
TimespanTest >> testUnionWithSelf [
	self assert: (aTimespan union: aTimespan) = aTimespan
	
]

{ #category : #testing }
TimespanTest >> testUnionWithSeparate [

	self 
		assert: (anOverlappingTimespan union: aDisjointTimespan) = 
			(Timespan 
				starting: anOverlappingTimespan start
				ending:  (aDisjointTimespan end + DateAndTime clockPrecision))
			

]

{ #category : #testing }
TimespanTest >> testWorkDatesDo [
	| count |
	count := 0.
	aTimespan
		workDatesDo: [:each | count := count + 1].
	self assert: count = 5
]

{ #category : #testing }
TimespanTest >> testYear [
	self assert: aTimespan year = 2005.

	
]

{ #category : #testing }
TimespanTest >> testZeroDuration [
	| ts |
	ts := Timespan starting: Date today duration: Duration zero.
	self
		assert: ts start = ts end
]
