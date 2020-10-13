"
I represent one of several Sunit test Cases intentended to provide complete coverage for the Chronology set of classes as part of the external testing. tlk.
My fixtures are:
aDateAndTime = February 29, 2004 1:33 PM with offset: 2 hours
aDuration = 15 days, 14 hours, 13 minutes, 12 seconds and 11 nano seconds.
aTimeZone =  Grenwhich Meridian (local offset = 0 hours) 
"
Class {
	#name : #DateAndTimeLeapTest,
	#superclass : #TestCase,
	#instVars : [
		'aDateAndTime',
		'aDuration',
		'aTimeZone',
		'localTimeZoneToRestore',
		'localTimeZonePreferenceToRestore'
	],
	#category : #'Chronology-Tests'
}

{ #category : #running }
DateAndTimeLeapTest >> setUp [
	localTimeZoneToRestore := DateAndTime localTimeZone.
	localTimeZonePreferenceToRestore := DateAndTime automaticTimezone.
	DateAndTime localTimeZone: TimeZone default.
	aDateAndTime := (DateAndTime year: 2004 month: 2 day: 29 hour: 13 minute: 33 second: 0 offset: 2 hours).
	aTimeZone := TimeZone default.
	aDuration := Duration days: 0 hours: 13 minutes: 33 seconds: 0 nanoSeconds: 0

]

{ #category : #running }
DateAndTimeLeapTest >> tearDown [
     DateAndTime localTimeZone: localTimeZoneToRestore.
	DateAndTime automaticTimezone: localTimeZonePreferenceToRestore.
     "wish I could remove the time zones I added earlier, tut there is no method for that"

]

{ #category : #testing }
DateAndTimeLeapTest >> testAsDate [
	self assert: (aDateAndTime offset: DateAndTime localTimeZone offset) asDate = 'February 29, 2004' asDate
]

{ #category : #testing }
DateAndTimeLeapTest >> testAsDuration [
	self assert: aDateAndTime asDuration =  aDuration
	

]

{ #category : #testing }
DateAndTimeLeapTest >> testAsLocal [
	self assert: aDateAndTime asLocal =  aDateAndTime.
	self assert: aDateAndTime asLocal = (aDateAndTime utcOffset: aDateAndTime class localOffset)

	

]

{ #category : #testing }
DateAndTimeLeapTest >> testAsMonth [
	self assert:
		(aDateAndTime offset: Month defaultOffset) asMonth =
			(Month
				month: 'February'
				year: 2004)
]

{ #category : #testing }
DateAndTimeLeapTest >> testAsNanoSeconds [
	self assert: aDateAndTime asNanoSeconds =  aDuration asNanoSeconds.
	self assert: aDateAndTime asNanoSeconds = 48780000000000
	

]

{ #category : #testing }
DateAndTimeLeapTest >> testAsSeconds [
	self assert: aDuration asSeconds =  48780.
	self assert: aDateAndTime asSeconds =  3255507180
	

]

{ #category : #testing }
DateAndTimeLeapTest >> testAsTime [
	self assert: aDateAndTime asTime = (Time hour: 13 minute: 33 second: 0)

]

{ #category : #testing }
DateAndTimeLeapTest >> testAsTimeStamp [
	self assert: aDateAndTime asTimeStamp =  ((TimeStamp readFrom: '2-29-2004 1:33 pm' readStream) offset: 2 hours).


]

{ #category : #testing }
DateAndTimeLeapTest >> testAsUTC [
	self assert: aDateAndTime asUTC =  aDateAndTime

          
]

{ #category : #testing }
DateAndTimeLeapTest >> testAsWeek [
	self assert: (aDateAndTime offset: DateAndTime localTimeZone offset) asWeek = (Week starting: '02-29-2004' asDate)
]

{ #category : #testing }
DateAndTimeLeapTest >> testAsYear [
	| year |
	year := (aDateAndTime offset: DateAndTime localTimeZone offset) asYear.
	self assert: year = (Year starting: '02-29-2004' asDate).
	self deny: year = (Year starting: '01-01-2004' asDate)
]

{ #category : #testing }
DateAndTimeLeapTest >> testDay [
	self assert: aDateAndTime day =   60. 
	self deny: aDateAndTime day =   29 
]

{ #category : #testing }
DateAndTimeLeapTest >> testDayMonthYearDo [
	self assert: (aDateAndTime dayMonthYearDo: [:eachDay :eachMonth :eachYear |  eachYear])  = 2004.
	self assert: (aDateAndTime dayMonthYearDo: [:eachDay :eachMonth :eachYear |  eachMonth]) = 2.
	self assert: (aDateAndTime dayMonthYearDo: [:eachDay :eachMonth :eachYear |  eachDay]) = 29.

]

{ #category : #testing }
DateAndTimeLeapTest >> testDayOfMonth [
	self assert: aDateAndTime dayOfMonth  = 29.

]

{ #category : #testing }
DateAndTimeLeapTest >> testDayOfWeek [
	self assert: aDateAndTime dayOfWeek  = 1.
	self assert: aDateAndTime dayOfWeekAbbreviation = 'Sun'.
	self assert: aDateAndTime dayOfWeekName = 'Sunday'.

]

{ #category : #testing }
DateAndTimeLeapTest >> testDayOfYear [
	self assert: aDateAndTime dayOfYear  = 60.


]

{ #category : #testing }
DateAndTimeLeapTest >> testDaysInMonth [
	self assert: aDateAndTime daysInMonth  = 29.


]

{ #category : #testing }
DateAndTimeLeapTest >> testDaysInYear [
	self assert: aDateAndTime daysInYear  = 366.


]

{ #category : #testing }
DateAndTimeLeapTest >> testDaysLeftInYear [
	self assert: aDateAndTime daysLeftInYear  = 306.


]

{ #category : #testing }
DateAndTimeLeapTest >> testFirstDayOfMonth [
	self deny: aDateAndTime firstDayOfMonth =  1.
	self assert: aDateAndTime firstDayOfMonth = 32

]

{ #category : #testing }
DateAndTimeLeapTest >> testFromString [
	self assert: aDateAndTime =  (DateAndTime fromString: ' 2004-02-29T13:33:00+02:00').


]

{ #category : #testing }
DateAndTimeLeapTest >> testHash [
	self assert: aDateAndTime hash =      1078054380000000

]

{ #category : #testing }
DateAndTimeLeapTest >> testHour [
	self assert: aDateAndTime hour =    aDateAndTime hour24.
	self assert: aDateAndTime hour =    13.
	self assert: aDateAndTime hour =    aDateAndTime hours

]

{ #category : #testing }
DateAndTimeLeapTest >> testHour12 [
	self assert: aDateAndTime hour12  =   1.

]

{ #category : #testing }
DateAndTimeLeapTest >> testIsLeapYear [
	self assert: aDateAndTime isLeapYear

]

{ #category : #testing }
DateAndTimeLeapTest >> testLessThan [
	self assert: aDateAndTime  < (aDateAndTime + '1:00:00:00').
	self assert: aDateAndTime + -1 < aDateAndTime.
	
]

{ #category : #testing }
DateAndTimeLeapTest >> testMeridianAbbreviation [
	self assert: aDateAndTime meridianAbbreviation = 'PM'.

	
]

{ #category : #testing }
DateAndTimeLeapTest >> testMiddleOf [
	self assert: (aDateAndTime middleOf: aDuration)  = 
	 (Timespan starting: (DateAndTime year: 2004 month: 2 day: 29 hour: 6 minute: 46 second: 30 offset: 2 hours)
	duration: (Duration days: 0 hours: 13 minutes: 33 seconds: 0 nanoSeconds: 0 ))
	
]

{ #category : #testing }
DateAndTimeLeapTest >> testMidnight [
	| midnight |
	midnight := (aDateAndTime offset: DateAndTime localTimeZone offset) midnight.
	self assert: midnight = '2004-02-29T00:00:00+00:00' asDateAndTime.
	self deny: midnight = '2004-02-29T00:00:00+02:00' asDateAndTime
]

{ #category : #testing }
DateAndTimeLeapTest >> testMinute [
	self assert: aDateAndTime minute =  33


]

{ #category : #testing }
DateAndTimeLeapTest >> testMinutes [
	self assert: aDateAndTime minutes = 33

]

{ #category : #testing }
DateAndTimeLeapTest >> testMonth [
	self assert: aDateAndTime month  = 2.
	self assert: aDateAndTime monthAbbreviation = 'Feb'.
	self assert: aDateAndTime monthName = 'February'.
	self assert: aDateAndTime monthIndex = 2.
]

{ #category : #testing }
DateAndTimeLeapTest >> testMonthParsing [
	self assert:
		(Month readFrom: 'Feb 2011' readStream) =
			(Month
				month: 2
				year: 2011)
]

{ #category : #testing }
DateAndTimeLeapTest >> testNanoSecond [
	self assert: aDateAndTime nanoSecond =  0


]

{ #category : #testing }
DateAndTimeLeapTest >> testNoon [
	self assert: aDateAndTime noon =  '2004-02-29T12:00:00+00:00' asDateAndTime
]

{ #category : #testing }
DateAndTimeLeapTest >> testOffset [
	self assert: aDateAndTime offset =  '0:02:00:00' asDuration.
     self assert: (aDateAndTime offset: '0:12:00:00') =  '2004-02-29T13:33:00+12:00' asDateAndTime
]

{ #category : #testing }
DateAndTimeLeapTest >> testPrintOn [
	| ref ws |
	ref := '2004-02-29T13:33:00+02:00'.
	ws := '' writeStream.
	aDateAndTime printOn: ws.
	self assert: ws contents = ref.
	ref  := 'a TimeZone(UTC)'.
	ws := '' writeStream.
	aTimeZone printOn:  ws.
	self assert: ws contents = ref	
]

{ #category : #testing }
DateAndTimeLeapTest >> testSecond [
	self assert: aDateAndTime second =  0


]

{ #category : #testing }
DateAndTimeLeapTest >> testSeconds [
	self assert: aDateAndTime seconds =  0


]

{ #category : #testing }
DateAndTimeLeapTest >> testTicks [
	self assert: aDateAndTime ticks =  ((DateAndTime julianDayNumber: 2453065) + 48780 seconds) ticks.
	self assert: aDateAndTime ticks =  #(2453065 48780 0)
]

{ #category : #testing }
DateAndTimeLeapTest >> testTicksOffset [
	self assert: aDateAndTime =  (aDateAndTime ticks:  #(2453065 48780 0) offset: DateAndTime localOffset).


]

{ #category : #testing }
DateAndTimeLeapTest >> testUtcOffset [
     self assert: (aDateAndTime utcOffset: '0:02:00:00') =  '2004-02-29T13:33:00+02:00' asDateAndTime
]

{ #category : #testing }
DateAndTimeLeapTest >> testYear [
	self assert: aDateAndTime year = 2004.

	
]

{ #category : #testing }
DateAndTimeLeapTest >> testYearDayHourMinuteSecond [
	self assert: aDateAndTime =  ((DateAndTime year: 2004 day: 60 hour: 13 minute: 33 second: 0) offset: 2 hours).

]

{ #category : #testing }
DateAndTimeLeapTest >> testYearMonthDayHourMinuteSecond [
	self assert: aDateAndTime =  ((DateAndTime year: 2004 month: 2 day: 29 hour: 13 minute: 33 second: 0) offset: 2 hours).

]

{ #category : #testing }
DateAndTimeLeapTest >> testtimeZone [
	self assert: aDateAndTime timeZoneName	= 'Universal Time'.
	self assert: aDateAndTime timeZoneAbbreviation	=  'UTC'


]
