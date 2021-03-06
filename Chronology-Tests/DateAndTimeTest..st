Class {
	#name : #DateAndTimeTest,
	#superclass : #ClassTestCase,
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
DateAndTimeTest >> classToBeTested [

	^ DateAndTime


]

{ #category : #Coverage }
DateAndTimeTest >> selectorsToBeIgnored [

	| private | 
	private := #( #printOn: ).

	^ super selectorsToBeIgnored, private

]

{ #category : #Tests }
DateAndTimeTest >> testArithmeticAcrossDateBoundary [

	| t1 t2 |
	t1 := '2004-01-07T11:55:00+00:00' asDateAndTime. 
	t2 := t1 - ( (42900+1) seconds).  

	self 
		assert: t2 = ('2004-01-06T23:59:59+00:00' asDateAndTime)
		

]

{ #category : #Tests }
DateAndTimeTest >> testAsSecondsIsTheSameInAnyTimezone [
	"Using the Posix epoch as a convenient reference, verify that this point
	in time is represented with the same magnitude in any local time zone."

	| posixEpochInVariousLocations |
	posixEpochInVariousLocations := {
		'1970-01-01T00:00:00+00:00' asDateAndTime .
		'1970-01-01T01:00:00+01:00' asDateAndTime .
		'1970-01-01T02:00:00+02:00' asDateAndTime .
		'1970-01-01T12:00:00+12:00' asDateAndTime .
		'1969-12-31T23:00:00-01:00' asDateAndTime .
		'1969-12-31T22:00:00-02:00' asDateAndTime .
		'1969-12-31T12:00:00-12:00' asDateAndTime
	}.
	posixEpochInVariousLocations do: [ :e |
		self assert: 2177452800 equals: e asSeconds ].

]

{ #category : #Tests }
DateAndTimeTest >> testAsSecondsMatchesFromSecondsUsingAnyOffset [
	"Verify that #asSeconds is symmetric with #fromSeconds: for an instance with
	offset that does not match the current local time zone offset."

	| aDateAndTime seconds newDateAndTime |
	aDateAndTime := DateAndTime year: 2004 month: 2 day: 29 hour: 13 minute: 33 second: 0 offset: 2 hours.
	seconds := aDateAndTime asSeconds.
	newDateAndTime := DateAndTime fromSeconds: seconds.
	self assert: seconds equals: newDateAndTime asSeconds.

	"Repeat with another offset to ensure coverage"
	aDateAndTime := DateAndTime year: 2004 month: 2 day: 29 hour: 13 minute: 33 second: 0 offset: -11 hours.
	seconds := aDateAndTime asSeconds.
	newDateAndTime := DateAndTime fromSeconds: seconds.
	self assert: seconds equals: newDateAndTime asSeconds.

]

{ #category : #Tests }
DateAndTimeTest >> testAsSecondsMatchesFromSecondsUsingCurrentLocalOffset [
	"Verify that #asSeconds is symmetric with #fromSeconds: for an instance with
	offset that matches the current local time zone offset."

	| seconds newDateAndTime now |
	now := DateAndTime now.
	seconds := now asSeconds.
	newDateAndTime := DateAndTime fromSeconds: seconds.
	self assert: seconds equals: newDateAndTime asSeconds.

]

{ #category : #Tests }
DateAndTimeTest >> testAsSecondsMatchesFromSecondsUsingZeroOffset [
	"Verify that #asSeconds is symmetric with #fromSeconds: for an instance with
	zero offset as in UTC time."

	| aDateAndTime seconds newDateAndTime |
	aDateAndTime := DateAndTime year: 2004 month: 2 day: 29 hour: 13 minute: 33 second: 0 offset: 0 hours.
	seconds := aDateAndTime asSeconds.
	newDateAndTime := DateAndTime fromSeconds: seconds.
	self assert: seconds equals: newDateAndTime asSeconds.

]

{ #category : #Tests }
DateAndTimeTest >> testAsStringFromString [
	"Convert to string then back, verify same date and time. Skip years in the
	range 0 to 99 because they are interpreted relative to 2000."

	| day hour dt min mo nano offset sec dtNew s |
	mo := 12.
	day := 2.
	hour := 2.
	min := 3.
	sec := 4.
	nano := 5.
	offset := 6 hours.
	(-2000 to: -1) , (100 to: 5000) do: [:yr |
		dt := DateAndTime 
			year: yr month: mo day: day 
			hour: hour minute: min second: sec nanoSecond: nano 
			offset: offset.
		s := dt asString.
		dtNew := DateAndTime fromString: s.
		self assert: dt equals: dtNew].

]

{ #category : #Tests }
DateAndTimeTest >> testDateTimeDenotation1 [
  "DateAndTimeTest new testDateTimeDenotation1"
	
	 " Detroit is 5 hours behind UTC, this offset to UTC is therefore written with a minus sign. This example tests the correct interpretation of the DateAndTime denotation. "

	| twoPmInLondon twoPmUTCInLocalTimeOfDetroit nineAmInDetroit |
	twoPmInLondon := DateAndTime
				year: 2004
				month: 11
				day: 2
				hour: 14
				minute: 0
				second: 0
				offset: 0 hours.
	twoPmUTCInLocalTimeOfDetroit := twoPmInLondon utcOffset: -5 hours.
	nineAmInDetroit  := '2004-11-02T09:00:00-05:00' asDateAndTime.
	self assert:  twoPmUTCInLocalTimeOfDetroit = nineAmInDetroit.
	

]

{ #category : #Tests }
DateAndTimeTest >> testDateTimeDenotation2 [
  "DateAndTimeTest new testDateTimeDenotation2"
	
	 " Moscow is 3 hours ahead UTC, this offset to UTC is therefore positive. This example tests the correct interpretation of the DateAndTime denotation. "

	| lateEveningInLondon lateEveningInLocalTimeOfMoscow
	 localMoscowTimeFromDenotation |
	lateEveningInLondon := DateAndTime
				year: 2004
				month: 11
				day: 30
				hour: 23
				minute: 30
				second: 0
				offset: 0 hours.
	lateEveningInLocalTimeOfMoscow := lateEveningInLondon utcOffset: 3 hours.
	localMoscowTimeFromDenotation  := '2004-12-01T02:30:00+03:00' asDateAndTime.
	self assert:  lateEveningInLocalTimeOfMoscow = localMoscowTimeFromDenotation.
	

]

{ #category : #Tests }
DateAndTimeTest >> testErrorWhenDayIsAfterMonthEnd [

	self
		should:
			[DateAndTime
				year: 2004
				month: 2
				day: 30]
		raise: Error.
]

{ #category : #Tests }
DateAndTimeTest >> testErrorWhenDayIsBeforeMonthStart [

	self
		should:
			[DateAndTime
				year: 2004
				month: 2
				day: -1]
		raise: Error.

	self
		should:
			[DateAndTime
				year: 2004
				month: 2
				day: 0]
		raise: Error.
]

{ #category : #Tests }
DateAndTimeTest >> testFromString [

	| fromString fromStringNoOffset fromStringUTC |
	fromString := DateAndTime fromString: '-1199-01-05T20:33:14.321-05:00'.
	self assert: (fromString printString = '-1199-01-05T20:33:14.321-05:00').
	
	"if no offset is provided, the local offset should be used"
	fromStringNoOffset := DateAndTime fromString: '-1199-01-05T20:33:14.321'.
	self assert: (fromStringNoOffset offset = DateAndTime localOffset).
	
	"if a string contains the UTC designator Z, the local offset should not be used"
	fromStringUTC := DateAndTime fromString: '2011-08-26T18:00:03Z'.
	self assert: (fromStringUTC printString = '2011-08-26T18:00:03+00:00').
]

{ #category : #Tests }
DateAndTimeTest >> testGetSeconds [
	"Verify that getSeconds represents whole seconds in the local time zone. For
	a given instance of DateAndTime, changing the time zone offset changes the
	local representation, but does not affect magnitude (time since a defiined
	epoch). Therefore, if time zone offset changes, the asSeconds value should
	not change, and the getSeconds value should change to reflect local timezone." 

	| dt s1 id stSeconds seconds1 seconds2 |
	s1 :=  '2019-01-12T10:07:05.18743-05:00'.
	dt := s1 asDateAndTime.
	self assert: 18000 seconds negated equals: dt offset.
	seconds1 := dt getSeconds.
	self assert: 36425 equals: seconds1.
	id := dt identityHash.
	stSeconds := dt asSeconds.
	dt localOffsetSeconds: 0. "make the receiver's timezone GMT, do not change magnitude"
	self assert: id equals: dt identityHash. "same object, not a copy"
	self assert: '2019-01-12T15:07:05.18743+00:00' equals: dt asString.
	self assert: stSeconds equals: dt asSeconds. "magnitude unchanged"
	self assert: '2019-01-12T10:07:05.18743-05:00' asDateAndTime equals: dt. "still equal"
	seconds2 := dt getSeconds.
	self deny: seconds1 equals: seconds2.
	self assert: 54425 equals: seconds2.


]

{ #category : #Tests }
DateAndTimeTest >> testHash [
	| date0 date1 date2 |
	date0 := DateAndTime unixEpoch.
	date1 := DateAndTime new ticks: (date0 + 1 hours) ticks offset: 0 hours.
	date2 := DateAndTime new ticks: (date0 - 2 hours) ticks offset: -3 hours.
	self assert: (date1 = date2) ==> [date1 hash = date2 hash]
]

{ #category : #Tests }
DateAndTimeTest >> testInstanceCreation [

	| t |
	t := DateAndTime 
			year: 1 month: 1 day: 2 
			hour: 2 minute: 3 second: 4 nanoSecond: 5 
			offset: 6 hours.
	self 
		assert: (t julianDayNumber = 1721427);
		assert: (t offset = 6 hours);
		assert: (t hour = 2);
		assert: (t minute = 3);
		assert: (t second = 4);
		assert: (t nanoSecond = 5).
		

]

{ #category : #Tests }
DateAndTimeTest >> testMonotonicity [

	| t1 t2 t3 t4 |
	t1 := DateAndTime now.
	t2 := DateAndTime now.
	(Delay forMilliseconds: 1000) wait.
	t3 := DateAndTime now.
	t4 := DateAndTime now.

	self
		assert: (	t1 <= t2);
		assert: (	t2 < t3);
		assert: (	t3 <= t4).

]

{ #category : #Tests }
DateAndTimeTest >> testPrecision [
	"Verify that the clock is returning a value with accuracy of better than 1 second.  For now it seems sufficient to get two values and verify they are not the same."

	| originalClockPolicy |
	originalClockPolicy := Time clockPolicy.
	[
		#(
			"#acceptPlatformTime is not listed here, because it doesn't guarantee monotoncity."
			monotonicAllowDuplicates <=
			monotonicForceMicrosecondIncrement <
			monotonicForceNanosecondIncrement <
		) pairsDo: [ :clockPolicy :comparator |
			| first second |
			Time clockPolicy: clockPolicy.
			first := DateAndTime now.
			second := DateAndTime now.
			self
				assert: (first perform: comparator with: second)
				description: ('Clock policy {1} didn''t compare with {2}' format: { clockPolicy. comparator }) ] ]
		ensure: [ Time clockPolicy: originalClockPolicy ]

]

{ #category : #Tests }
DateAndTimeTest >> testPrintString [

	"(self new setTestSelector: #testPrintString) debug"

	| dt dtNoOffset |
	dt :=DateAndTime
		year: 2004
		month: 11
		day: 2
		hour: 14
		minute: 3
		second: 5
		nanoSecond: 12345
		offset: (Duration seconds: (5 * 3600)).
	self assert: dt printString = '2004-11-02T14:03:05.000012345+05:00'.
	
	self assert: ('2002-05-16T17:20:45.1+01:01' asDateAndTime printString = '2002-05-16T17:20:45.1+01:01').
	self assert:	(' 2002-05-16T17:20:45.02+01:01' asDateAndTime printString = '2002-05-16T17:20:45.02+01:01').  
	self assert:	('2002-05-16T17:20:45.000000009+01:01' asDateAndTime printString =  '2002-05-16T17:20:45.000000009+01:01').
	self assert: ('2002-05-16T17:20:45+00:00' asDateAndTime printString = '2002-05-16T17:20:45+00:00' ).
	self assert: (' 2002-05-16T17:20:45+01:57' asDateAndTime printString = '2002-05-16T17:20:45+01:57').
	self assert: (' 2002-05-16T17:20:45-02:34' asDateAndTime printString = '2002-05-16T17:20:45-02:34').
	self assert: ('2002-05-16T17:20:45+00:00' asDateAndTime printString = '2002-05-16T17:20:45+00:00').
	self assert: ('1997-04-26T01:02:03+01:02:3' asDateAndTime printString = '1997-04-26T01:02:03+01:02:3').

	"When no offset is provided, the local one is used"
	dtNoOffset := '2002-05-16T17:20' asDateAndTime.
	self assert: (('2002-05-16T17:20:00*' match: dtNoOffset printString) and: [dtNoOffset offset = DateAndTime localOffset]).


]

{ #category : #Tests }
DateAndTimeTest >> testReadFrom [

	self assert: '-1199-01-05T20:33:14.321-05:00' equals: (DateAndTime readFrom: '-1199-01-05T20:33:14.321-05:00' readStream) printString.
	self assert: '-1199-01-05T20:33:14.321-05:00' equals: '-1199-01-05T20:33:14.321-05:00' asDateAndTime printString.
	self assert: '2002-05-16T17:20:45.1+01:01' equals: '2002-05-16T17:20:45.1+01:01' asDateAndTime printString.
	self assert: '2002-05-16T17:20:45.02+01:01' equals: ' 2002-05-16T17:20:45.02+01:01' asDateAndTime printString.  
	self assert: '2002-05-16T17:20:45.000000009+01:01' equals: '2002-05-16T17:20:45.000000009+01:01' asDateAndTime printString.
	self assert: '2002-05-16T17:20:45+01:57' equals: ' 2002-05-16T17:20:45+01:57' asDateAndTime printString.
	self assert: '2002-05-16T17:20:45-02:34' equals: ' 2002-05-16T17:20:45-02:34' asDateAndTime printString.
	self assert: '2002-05-16T17:20:45+00:00' equals: '2002-05-16T17:20:45+00:00' asDateAndTime printString.
	self assert: '1997-04-26T01:02:03+01:02:3' equals: '1997-04-26T01:02:03+01:02:3' asDateAndTime printString
]

{ #category : #Tests }
DateAndTimeTest >> testRestoreFromChronologyTicksAndOffset [
	"Legacy serialized instances are made up of 3 SmallIntegers knowns as 'ticks' plus an 'offset' Duration.  Ensure a serialized DateAndTime can be correctly restored from these values."
	| dt newDt |
	dt := '2018-11-17T14:19:42.887676-06:00' asDateAndTime.
	newDt := DateAndTime basicNew ticks: dt ticks offset: dt offset.
	self assert: dt = newDt
]

{ #category : #Tests }
DateAndTimeTest >> testSmalltalk80Accessors [

	| t |
	t := DateAndTime 
			year: 1 month: 1 day: 2 
			hour: 2 minute: 3 second: 4 nanoSecond: 5 
			offset: 6 hours.
	self 
		assert: (t hours = t hours);
		assert: (t minutes = t minute);
		assert: (t seconds = t second).

]

{ #category : #Tests }
DateAndTimeTest >> testTimeZoneEquivalence [
  "DateAndTimeTest new testTimeZoneEquivalence"
	"When the clock on the wall in Detroit says 9:00am, the clock on the wall
	in London says 2:00pm. The Duration difference between the corresponding
	DateAndTime values should be zero."
	
	 " Detroit is 5 hours behind UTC, this offset to UTC is therefore written with a minus sign. This example tests both the correct interpretation of the DateAndTime denotation and correct DateAndTime arithmetics. "

	| twoPmInLondon nineAmInDetroit durationDifference |
	twoPmInLondon := '2004-11-02T14:00:00+00:00' asDateAndTime.
	nineAmInDetroit  := '2004-11-02T09:00:00-05:00' asDateAndTime.
	durationDifference := twoPmInLondon - nineAmInDetroit.
	self assert: durationDifference asSeconds = 0.
	self assert: twoPmInLondon = nineAmInDetroit

]

{ #category : #Tests }
DateAndTimeTest >> testTimeZoneEquivalence2 [
  "DateAndTimeTest new testTimeZoneEquivalence2"
	"This example demonstates the fact that
        2004-05-24T22:40:00  UTC  is
        2004-05-25T01:40:00  in Moscow
     (Moscow is 3 hours ahead of UTC)  "

	| thisMoment thisMomentInMoscow |
    thisMoment := DateAndTime year: 2004 month: 5 day: 24 hour: 22 minute: 40.
    thisMomentInMoscow := thisMoment utcOffset: 3 hours.
	self assert: (thisMoment - thisMomentInMoscow) asSeconds = 0.
	self assert: thisMoment = thisMomentInMoscow

]
