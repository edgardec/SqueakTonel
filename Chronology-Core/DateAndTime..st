"
I represent a point in UTC time as defined by ISO 8601. I have zero duration.

My implementation uses variables utcMicroseconds and localOffsetSeconds. This represents time magnitude as elapsed microseconds since the Posix epoch, with localOffsetSeconds representing local offset from UTC. The magnitude is used for comparison and duration calculations, and the local offset is used for displaying this magnitude in the context of a local time zone.

The implementation ignores leap seconds, which are adjustments made to maintain earth rotational clock time in synchronization with elapsed seconds.

DateAndTime class>>now will use #primitiveUtcWithOffset to obtain current time in UTC microseconds with current local offset in seconds. The primitive provides an atomic query for UTC time and local offset as measured by the OS platform.  If primitiveUtcWithOffset is not available, the traditional implementation is used, which relies on a primitive for microseconds in the local time zone and derives UTC based on the TimeZone setting.

"
Class {
	#name : #DateAndTime,
	#superclass : #Magnitude,
	#instVars : [
		'utcMicroseconds',
		'localOffsetSeconds'
	],
	#classVars : [
		'AutomaticTimezone',
		'ClockProvider',
		'InitializeFromPrimitive',
		'LocalTimeZone',
		'PosixEpochJulianDays'
	],
	#pools : [
		'ChronologyConstants'
	],
	#category : #'Chronology-Core'
}

{ #category : #preferences }
DateAndTime class >> automaticTimezone [
	"Accessor for the system-wide preference"
	
	<preference: 'Automatically set local timezone'
		category: 'general'
		description: 'If enabled, the timezone will automatically be kept in sync with the system''s time (daylight savings changes etc.)'
		type: #Boolean>
	^AutomaticTimezone ifNil: [ true ]
]

{ #category : #preferences }
DateAndTime class >> automaticTimezone: aBoolean [
	"Accessor for the system-wide preference.
	Note this gets disabled in localTimeZone: to make that override stick"
	
	AutomaticTimezone := aBoolean.
	aBoolean ifTrue: [self now].		"fetch timezone immediately"
]

{ #category : #'system startup' }
DateAndTime class >> canInitializeFromPrimitive [
	"Some implementations of primitiveUtcWithOffset do not support passing the
	DateAndTime instance as a parameter to the primitive."

	^self  basicNew initializeFromPrimitive utcMicroseconds notNil
]

{ #category : #'clock provider' }
DateAndTime class >> clock [ 
	 "the provider of real time seconds/milliseconds."

	^ ClockProvider 
]

{ #category : #'ansi protocol' }
DateAndTime class >> clockPrecision [
	"One nanosecond precision"

	^ Duration seconds: 0 nanoSeconds: 1

]

{ #category : #'squeak protocol' }
DateAndTime class >> current [


	^ self now
]

{ #category : #'squeak protocol' }
DateAndTime class >> date: aDate time: aTime [

	^ self 
		year: aDate year
		month: aDate monthIndex
		day: aDate dayOfMonth 
		hour: aTime hour 
		minute: aTime minute
		second: aTime second
		nanoSecond: aTime nanoSecond
		offset: aDate start offset
]

{ #category : #private }
DateAndTime class >> daysFromSmalltalkEpochToPosixEpoch [

	^52 * 365 + (17 * 366)
]

{ #category : #'squeak protocol' }
DateAndTime class >> epoch [
	"Answer a DateAndTime representing the Squeak epoch: 1 January 1901"

	^ self utcMicroseconds: self epochOffsetMicros negated offset: 0

]

{ #category : #private }
DateAndTime class >> epochOffset [
	"Elaspsed seconds from the Smalltalk epoch to the Posix epoch"
	^self daysFromSmalltalkEpochToPosixEpoch * SecondsInDay
]

{ #category : #private }
DateAndTime class >> epochOffsetMicros [
	"Elaspsed microseconds from the Smalltalk epoch to the Posix epoch"
	^self epochOffset * 1000000
]

{ #category : #'smalltalk-80' }
DateAndTime class >> fromSeconds: seconds [ 
	"Answer a DateAndTime since the Squeak epoch: 1 January 1901

	Squeak traditionally used seconds since the Smalltalk epoch in local time,
	which is undefinable. The error was probably caused by some early VM design
	choices that have since been corrected. Assume now that the Smalltalk epoch
	is defined relative to GMT, and that it may be treated similarly to the Posix
	epoch except for a constant offset value.

	This implementation differs from earlier Squeak in that it uses seconds relative
	to the Smalltalk epoch (not local time), and represents seconds as an arbitrary
	precision number rather than an integer."

	| s uSec offset |
	offset := self localOffsetSeconds.
	s := seconds - self epochOffset.
	uSec := s * 1000000.
	^ self utcMicroseconds: uSec offset: offset

]

{ #category : #'squeak protocol' }
DateAndTime class >> fromString: aString [


	^ self readFrom: (ReadStream on: aString)
]

{ #category : #'squeak protocol' }
DateAndTime class >> fromUnixTime: utcSeconds [

	^self utcSeconds: utcSeconds offset: 0

]

{ #category : #'initialize-release' }
DateAndTime class >> initialize [

	ClockProvider := Time.
	PosixEpochJulianDays := 2440588.
	InitializeFromPrimitive := self canInitializeFromPrimitive.
	Smalltalk addToStartUpList: self.
	self startUp: true

]

{ #category : #'squeak protocol' }
DateAndTime class >> julianDayNumber: anInteger [ 
	^ self
		julianDayNumber: anInteger
		offset: self localOffset
]

{ #category : #'squeak protocol' }
DateAndTime class >> julianDayNumber: anInteger offset: aDuration [ 

	^self basicNew
		setJdn: anInteger
		seconds: 0
		nano: 0
		offset: aDuration
]

{ #category : #'squeak protocol' }
DateAndTime class >> localOffset [
	"Answer the duration we are offset from UTC"

	^ Duration seconds: self localOffsetSeconds

]

{ #category : #'squeak protocol' }
DateAndTime class >> localOffset: aDuration [
	"Override the local time zone (for testing). This disables the #automaticTimezone: preference"
	self localTimeZone: (TimeZone offset: aDuration name: 'Local Time (override)' abbreviation: 'LTO').

]

{ #category : #private }
DateAndTime class >> localOffsetSeconds [

	self automaticTimezone
		ifTrue: [ ^Time posixMicrosecondClockWithOffset second ]
		ifFalse: [ ^self localTimeZone offset asSeconds ]
]

{ #category : #accessing }
DateAndTime class >> localTimeZone [
	"Answer the local time zone"

	^ LocalTimeZone ifNil: [ LocalTimeZone := TimeZone default ]


]

{ #category : #accessing }
DateAndTime class >> localTimeZone: aTimeZone [
	"Set the local time zone"
	"
	DateAndTime localTimeZone: (TimeZone offset:  0 hours name: 'Universal Time' abbreviation: 'UTC').
	DateAndTime localTimeZone: (TimeZone offset: -8 hours name: 'Pacific Standard Time' abbreviation: 'PST').
	"
	LocalTimeZone := aTimeZone.
	self automaticTimezone: (aTimeZone abbreviation = 'LT')
]

{ #category : #'squeak protocol' }
DateAndTime class >> midnight [

	^ self now midnight
]

{ #category : #'squeak protocol' }
DateAndTime class >> milliSecondsSinceMidnight [
	^Time milliSecondsSinceMidnight
]

{ #category : #'smalltalk-80' }
DateAndTime class >> millisecondClock [

	^self clock millisecondClock
]

{ #category : #'smalltalk-80' }
DateAndTime class >> millisecondClockValue [

	^ self clock millisecondClockValue
]

{ #category : #'squeak protocol' }
DateAndTime class >> new [
	"Answer a DateAndTime representing the Squeak epoch: 1 January 1901"

	^ self utcMicroseconds: self epochOffsetMicros negated offset: 0


]

{ #category : #'squeak protocol' }
DateAndTime class >> noon [

	^ self now noon

]

{ #category : #'ansi protocol' }
DateAndTime class >> now [
	"Answer time now as reported by #primitiveUtcWithOffset. If the primitive is not
	available, answer the Posix epoch GMT."

	self automaticTimezone
		ifTrue: [ InitializeFromPrimitive
			ifTrue: [ ^ self basicNew initializeFromPrimitive ]
			ifFalse: [ | timeArray |
				timeArray := Time posixMicrosecondClockWithOffset.
				^ self utcMicroseconds: timeArray first offset: timeArray second ] ]
		ifFalse: [ | timeArray |
			timeArray := Time posixMicrosecondClockWithOffset.
			^ self utcMicroseconds: timeArray first offset: self localOffsetSeconds ]

]

{ #category : #'squeak protocol' }
DateAndTime class >> nowAtOffset: offsetDuration [
	"Answers the local time at places with the specified offsetDuration timezone."
	"local time Chicago (CST)"
	"DateAndTime nowAtOffset: -6 hours"

	^ self utcMicroseconds: Time posixMicrosecondClockWithOffset first offset: offsetDuration asSeconds

]

{ #category : #'squeak protocol' }
DateAndTime class >> readFrom: aStream [

	| offsetSeconds ch yearMonthDay hourMinuteSecondNano offset |

	yearMonthDay := Date readYearMonthDayFrom: aStream.
	[aStream peek isDigit]
		whileFalse: [aStream next].
	hourMinuteSecondNano := Time readHourMinuteSecondNanoFrom: aStream.
	(aStream atEnd or: [('+-Z' includes: aStream peek) not])
		ifTrue: [ self flag: #FIXME.
				"Different unit tests have conflicting opinions as to whether the
				current local offset should be used as a default. However, the current
				local offset cannot be correct due to DST (offset is itself a function
				of the point in time). Nevertheless, this is a reasonable default considering
				that the offset would have been explicitly part of the date string if it
				was a matter of concern. Unit tests will require updates to match this
				assumption."
				"offsetSeconds := 0"
				offsetSeconds := self localOffsetSeconds]
		ifFalse: [(aStream peekFor: $Z)
			ifTrue: [offsetSeconds := 0]
			ifFalse: [
				ch := aStream next.
				ch = $+ ifTrue: [ch := Character space].
				offset := Duration fromString: ch asString, '0:', aStream upToEnd, ':0'.
				offsetSeconds := offset asSeconds]].
	^ self
		year: yearMonthDay first
		month: yearMonthDay second
		day: yearMonthDay third
		hour: hourMinuteSecondNano first
		minute: hourMinuteSecondNano second
		second: hourMinuteSecondNano third
		nanoSecond: hourMinuteSecondNano fourth
		offsetSeconds: offsetSeconds


	"	'-1199-01-05T20:33:14.321-05:00' asDateAndTime
		' 2002-05-16T17:20:45.1+01:01' asDateAndTime

		' 2002-05-16T17:20:45.02+01:01' asDateAndTime

		' 2002-05-16T17:20:45.003+01:01' asDateAndTime

		' 2002-05-16T17:20:45.0004+01:01' asDateAndTime
  		' 2002-05-16T17:20:45.00005' asDateAndTime
		' 2002-05-16T17:20:45.000006+01:01' asDateAndTime

		' 2002-05-16T17:20:45.0000007+01:01' asDateAndTime
		' 2002-05-16T17:20:45.00000008-01:01' asDateAndTime   
		' 2002-05-16T17:20:45.000000009+01:01' asDateAndTime  
		' 2002-05-16T17:20:45.0000000001+01:01' asDateAndTime  

 		' 2002-05-16T17:20' asDateAndTime
		' 2002-05-16T17:20:45' asDateAndTime
		' 2002-05-16T17:20:45+01:57' asDateAndTime
 		' 2002-05-16T17:20:45-02:34' asDateAndTime
 		' 2002-05-16T17:20:45+00:00' asDateAndTime
		' 1997-04-26T01:02:03+01:02:3' asDateAndTime 
 	"
]

{ #category : #'system startup' }
DateAndTime class >> startUp: startingAfresh [
	"Set local timezone"
	startingAfresh
		ifTrue: [InitializeFromPrimitive := self canInitializeFromPrimitive.
			Time initialize. "set LastClockTick to 0".
			self now]
]

{ #category : #'squeak protocol' }
DateAndTime class >> today [

	^ self midnight
]

{ #category : #'squeak protocol' }
DateAndTime class >> tomorrow [

	^ self today asDate next asDateAndTime

]

{ #category : #'smalltalk-80' }
DateAndTime class >> totalSeconds [

	^ self clock totalSeconds
]

{ #category : #'squeak protocol' }
DateAndTime class >> unixEpoch [
	"Answer a DateAndTime representing the Unix epoch (1 January 1970, midnight UTC)"

	^self utcMicroseconds: 0 offset: 0
]

{ #category : #'instance creation' }
DateAndTime class >> utcMicroseconds: microsecondsSincePosixEpoch offset: secondsFromGMT [

	^super new
		utcMicroseconds: microsecondsSincePosixEpoch
		offset: secondsFromGMT
]

{ #category : #private }
DateAndTime class >> utcMicrosecondsForYear: year month: month day: day hour: hour minute: minute second: second nanoSecond: nanoCount  offsetSeconds: offsetSeconds [

	| monthIndex daysInMonth p q r s julianDayNumber posixDays seconds utcSeconds |

	monthIndex := month isInteger ifTrue: [month] ifFalse: [Month indexOfMonth: month].
	daysInMonth := Month
		daysInMonth: monthIndex
		forYear: year.
	day < 1 ifTrue: [self error: 'day may not be zero or negative'].
	day > daysInMonth ifTrue: [self error: 'day is after month ends']. 	
	
	p := (monthIndex - 14) quo: 12.
	q := year + 4800 + p.
	r := monthIndex - 2 - (12 * p).
	s := (year + 4900 + p) quo: 100.

	julianDayNumber :=
 		( (1461 * q) quo: 4 ) +
			( (367 * r) quo: 12 ) -
 				( (3 * s) quo: 4 ) +
 					( day - 32075 ).

	posixDays := julianDayNumber - PosixEpochJulianDays.
	seconds := hour * 60 + minute * 60 + second - offsetSeconds.
	utcSeconds := seconds + (posixDays * 24 * 3600).
	^ utcSeconds * 1000000 + (nanoCount / 1000)

]

{ #category : #'instance creation' }
DateAndTime class >> utcSeconds: secondsSincePosixEpoch offset: secondsFromGMT [

	^self
		utcMicroseconds: secondsSincePosixEpoch * 1000000
		offset: secondsFromGMT
]

{ #category : #'squeak protocol' }
DateAndTime class >> year: year day: dayOfYear [
	"Return a DateAndTime"

	^ self
		year: year
		day: dayOfYear
		hour: 0
		minute: 0
		second: 0

]

{ #category : #'ansi protocol' }
DateAndTime class >> year: year day: dayOfYear hour: hour minute: minute second: second [

	^ self
		year: year
		day: dayOfYear
		hour: hour
		minute: minute
		second: second
		offset: self localOffset

]

{ #category : #'ansi protocol' }
DateAndTime class >> year: year day: dayOfYear hour: hour minute: minute second: second offset: offset [ 
	"Return a DataAndTime"

	| y d |
	y := self
		year: year
		month: 1
		day: 1
		hour: hour
		minute: minute
		second: second
		nanoSecond: 0
		offset: offset.

	d := Duration days: (dayOfYear - 1).

	^ y + d

]

{ #category : #'squeak protocol' }
DateAndTime class >> year: year month: month day: day [
	"Return a DateAndTime, midnight local time"
	
	^self
 		year: year
 		month: month
 		day: day
 		hour: 0
		minute: 0

]

{ #category : #'squeak protocol' }
DateAndTime class >> year: year month: month day: day hour: hour minute: minute [
	"Return a DateAndTime"

	^self
 		year: year
 		month: month
 		day: day
 		hour: hour
		minute: minute
		second: 0

]

{ #category : #'ansi protocol' }
DateAndTime class >> year: year month: month day: day hour: hour minute: minute second: second [
	"Return a DateAndTime"

	^ self
		year: year
		month: month
		day: day
		hour: hour
		minute: minute
		second: second
		offset: self localOffset
]

{ #category : #'squeak protocol' }
DateAndTime class >> year: year month: month day: day hour: hour minute: minute second: second nanoSecond: nanoCount offset: offset [
	"Return a DateAndTime"

	| offsetSeconds utcMicros |
	offsetSeconds := offset asSeconds.
	utcMicros := self
				utcMicrosecondsForYear: year
				month: month
				day: day
				hour: hour
				minute: minute
				second: second
				nanoSecond: nanoCount
				offsetSeconds: offsetSeconds.
	^ self utcMicroseconds: utcMicros offset: offsetSeconds
]

{ #category : #'squeak protocol' }
DateAndTime class >> year: year month: month day: day hour: hour minute: minute second: second nanoSecond: nanoCount offsetSeconds: offsetSeconds [
	"Return a DateAndTime"

	| utcMicros |
	utcMicros := self
				utcMicrosecondsForYear: year
				month: month
				day: day
				hour: hour
				minute: minute
				second: second
				nanoSecond: nanoCount
				offsetSeconds: offsetSeconds.
	^ self utcMicroseconds: utcMicros offset: offsetSeconds
]

{ #category : #'ansi protocol' }
DateAndTime class >> year: year month: month day: day hour: hour minute: minute second: second offset: offset [

	^ self
		year: year
		month: month
		day: day
		hour: hour
		minute: minute
		second: second
		nanoSecond: 0
		offset: offset
]

{ #category : #'squeak protocol' }
DateAndTime class >> yesterday [

	^ self today asDate previous asDateAndTime
]

{ #category : #'ansi protocol' }
DateAndTime >> + operand [
	"operand conforms to protocol Duration"

	^ self class
		utcMicroseconds: operand asDuration asNanoSeconds / 1000 + utcMicroseconds
		offset: localOffsetSeconds

]

{ #category : #'ansi protocol' }
DateAndTime >> - operand [
	"operand conforms to protocol DateAndTime or protocol Duration"

	^ (operand respondsTo: #asDateAndTime)
		ifTrue: 
			[ | micros |
			micros := utcMicroseconds - operand asDateAndTime utcMicroseconds.
			Duration seconds: micros // 1000000 nanoSeconds: micros \\ 1000000 * 1000]
		ifFalse:
			[ self + (operand negated) ]

]

{ #category : #'ansi protocol' }
DateAndTime >> < comparand [
	"comparand conforms to protocol DateAndTime,
	or can be converted into something that conforms."

	^utcMicroseconds < comparand asDateAndTime utcMicroseconds

]

{ #category : #'ansi protocol' }
DateAndTime >> = aDateAndTimeOrTimeStamp [
	"Equal if the absolute time values match, regardless of local time transform"
	self == aDateAndTimeOrTimeStamp ifTrue: [ ^ true ].
	^aDateAndTimeOrTimeStamp species == DateAndTime
		and: [ utcMicroseconds = aDateAndTimeOrTimeStamp utcMicroseconds ]
]

{ #category : #converting }
DateAndTime >> asChronologySeconds [
	"What #asSeconds answers in prior Chronology-format images."
	^ self asSeconds + self offset asSeconds
]

{ #category : #'squeak protocol' }
DateAndTime >> asDate [


	^ Date starting: self asDateAndTime
]

{ #category : #'squeak protocol' }
DateAndTime >> asDateAndTime [

	^ self
]

{ #category : #'squeak protocol' }
DateAndTime >> asDuration [
	"Answer the duration since midnight."

	^ Duration seconds: self getSeconds nanoSeconds: self nanoSecond

]

{ #category : #'smalltalk-80' }
DateAndTime >> asExactSeconds [
	"Return the duration in seconds since the Squeak epoch"

	"Squeak traditionally used seconds since the Smalltalk epoch in local time,
	which is undefinable. The error was probably caused by some early VM design
	choices that have since been corrected. Assume now that the Smalltalk epoch
	is defined relative to GMT, and that it may be treated similarly to the Posix
	epoch except for a constant offset value.

	This implementation differs from earlier Squeak in that it uses seconds relative
	to the Smalltalk epoch (not local time), and represents seconds as an arbitrary
	precision number rather than an integer."

	^ utcMicroseconds / 1000000 + self class epochOffset

]

{ #category : #'ansi protocol' }
DateAndTime >> asLocal [
	

	^ (self offset = self class localOffset)

		ifTrue: [self]
		ifFalse: [self utcOffset: self class localOffset]
]

{ #category : #'squeak protocol' }
DateAndTime >> asMonth [

	^ Month starting: self
]

{ #category : #'squeak protocol' }
DateAndTime >> asNanoSeconds [
	"Answer the number of nanoseconds since midnight"

	^ self asDuration asNanoSeconds
]

{ #category : #converting }
DateAndTime >> asPosixSeconds [

	^utcMicroseconds / 1000000

]

{ #category : #'smalltalk-80' }
DateAndTime >> asSeconds [
	"Return the number of seconds since the Squeak epoch. See asExactSeconds
	to retain full precision of the duration in seconds."

	"Squeak traditionally used seconds since the Smalltalk epoch in local time,
	which is undefinable. The error was probably caused by some early VM design
	choices that have since been corrected. Assume now that the Smalltalk epoch
	is defined relative to GMT, and that it may be treated similarly to the Posix
	epoch except for a constant offset value.

	This implementation differs from earlier Squeak in that it uses seconds relative
	to the Smalltalk epoch (not local time), and represents seconds as an arbitrary
	precision number rather than an integer."

	^ utcMicroseconds // 1000000 + self class epochOffset

]

{ #category : #'squeak protocol' }
DateAndTime >> asTime [


	^ Time seconds: self getSeconds nanoSeconds: self nanoSecond

]

{ #category : #'squeak protocol' }
DateAndTime >> asTimeStamp [

	^ self as: TimeStamp
]

{ #category : #'ansi protocol' }
DateAndTime >> asUTC [

	localOffsetSeconds = 0 ifTrue: [ ^self ].
	^self copy localOffsetSeconds: 0.
]

{ #category : #'squeak protocol' }
DateAndTime >> asUnixTime [
	"answer number of seconds since unix epoch (midnight Jan 1, 1970, UTC)"

	^utcMicroseconds // 1000000
]

{ #category : #'squeak protocol' }
DateAndTime >> asWeek [

	^ Week starting: self
]

{ #category : #'squeak protocol' }
DateAndTime >> asYear [

	^ Year starting: self
]

{ #category : #'smalltalk-80' }
DateAndTime >> day [

	^ self dayOfYear

]

{ #category : #'squeak protocol' }
DateAndTime >> dayMonthYearDo: aBlock [
	"Evaluation the block with three arguments: day month, year."

	| l n i j dd |
	l := self julianDayNumber + 68569.
	n := 4 * l // 146097.
	l := l - (146097 * n + 3 // 4).
	i := l + 1 * 4000 // 1461001.
	l := l - (1461 * i // 4) + 31.
	j := 80 * l // 2447.
	dd := l - (2447 * j // 80).
	l := j // 11.

	^ aBlock
		value: dd
		value: -12 * l + 2 + j "month"
		value: n - 49 * 100 + i + l "year"
]

{ #category : #'ansi protocol' }
DateAndTime >> dayOfLocalWeek [

	"Sunday=1, ... , Saturday=7"

	^ (self julianDayNumber + 2 - Week weekdayStartIndex rem: 7) + 1

]

{ #category : #'ansi protocol' }
DateAndTime >> dayOfMonth [
	"Answer which day of the month is represented by the receiver."

	^ self
		dayMonthYearDo: [ :d :m :y | d ]

]

{ #category : #'ansi protocol' }
DateAndTime >> dayOfWeek [

	"Sunday=1, ... , Saturday=7"

	^ (self julianDayNumber + 1 rem: 7) + 1

]

{ #category : #'ansi protocol' }
DateAndTime >> dayOfWeekAbbreviation [

	^ self dayOfWeekName copyFrom: 1 to: 3

]

{ #category : #'ansi protocol' }
DateAndTime >> dayOfWeekName [

	^ Week nameOfDay: self dayOfWeek
]

{ #category : #'ansi protocol' }
DateAndTime >> dayOfYear [
	"This code was contributed by Dan Ingalls. It is equivalent to the terser
		^ jdn - (Year year: self year) start julianDayNumber + 1 but much quicker."

	^ self dayMonthYearDo:
		[ :d :m :y |
			| monthStart |
			monthStart := #(1 32 60 91 121 152 182 213 244 274 305 335) at: m.
			(m > 2 and: [ Year isLeapYear: y ])
				ifTrue: [ monthStart + d ]
				ifFalse: [ monthStart + d - 1 ]]
]

{ #category : #'smalltalk-80' }
DateAndTime >> daysInMonth [
	"Answer the number of days in the month represented by the receiver."


	^ self asMonth daysInMonth
]

{ #category : #'smalltalk-80' }
DateAndTime >> daysInYear [

	"Answer the number of days in the year represented by the receiver."

	^ self asYear daysInYear
]

{ #category : #'smalltalk-80' }
DateAndTime >> daysLeftInYear [
	"Answer the number of days in the year after the date of the receiver."

	^ self daysInYear - self dayOfYear
]

{ #category : #'squeak protocol' }
DateAndTime >> duration [

	^ Duration zero
]

{ #category : #'smalltalk-80' }
DateAndTime >> firstDayOfMonth [

	^ self asMonth start day

]

{ #category : #'squeak protocol' }
DateAndTime >> floor [
	"Answer a copy with magnitude rounded down to the nearest whole second"
	^self class
		utcMicroseconds: utcMicroseconds // 1000000 * 1000000
		offset: localOffsetSeconds
]

{ #category : #accessing }
DateAndTime >> getSeconds [
	
	^utcMicroseconds // 1000000 + localOffsetSeconds \\ 86400
]

{ #category : #'ansi protocol' }
DateAndTime >> hash [
	^utcMicroseconds hash
]

{ #category : #'ansi protocol' }
DateAndTime >> hour [

	^ self hour24
]

{ #category : #'ansi protocol' }
DateAndTime >> hour12 [
	"Answer an <integer> between 1 and 12, inclusive, representing the hour 
	of the day in the 12-hour clock of the local time of the receiver."
	^ self hour24 - 1 \\ 12 + 1

]

{ #category : #'ansi protocol' }
DateAndTime >> hour24 [

	^self getSeconds // 3600
]

{ #category : #'smalltalk-80' }
DateAndTime >> hours [

	^ self hour

]

{ #category : #'initialize-release' }
DateAndTime >> initializeFromPrimitive [

	Time posixMicrosecondClockWithOffset: self
]

{ #category : #'ansi protocol' }
DateAndTime >> isLeapYear [


	^ Year isLeapYear: self year

]

{ #category : #'squeak protocol' }
DateAndTime >> julianDayNumber [

	^utcMicroseconds // 1000000 + localOffsetSeconds // 86400 + PosixEpochJulianDays
]

{ #category : #'initialize-release' }
DateAndTime >> localOffsetSeconds: seconds [
	"Private. Allow value to be modified during initialization in order to support local
	timezone preference."

	localOffsetSeconds := seconds

]

{ #category : #'squeak protocol' }
DateAndTime >> makeUTC [
	"Make the receiver's timezone UTC. This adjusts both the magnitude and
	local offset of the receiver such that self asString remains unchanged
	except for a zero timezone offset."

	^ self
		utcMicroseconds: localOffsetSeconds * 1000000 + utcMicroseconds
		offset: 0

]

{ #category : #'ansi protocol' }
DateAndTime >> meridianAbbreviation [

	^ self asTime meridianAbbreviation

]

{ #category : #private }
DateAndTime >> microsecondsFromDay: jdn seconds: s nanos: n offset: localOffsetSeconds [

	^jdn - PosixEpochJulianDays "days" * 86400
		+ s - localOffsetSeconds "seconds" * 1000000
		+ (n / 1000) "nanos"
]

{ #category : #'squeak protocol' }
DateAndTime >> middleOf: aDuration [
	"Return a Timespan where the receiver is the middle of the Duration"

	| duration |
	duration := aDuration asDuration.

	^ Timespan starting: (self - (duration / 2)) duration: duration

]

{ #category : #'squeak protocol' }
DateAndTime >> midnight [
	"Answer a DateAndTime starting at midnight of the same timezone offset as the receiver."
	^ self class basicNew
		setJdn: self julianDayNumber
		seconds: 0
		nano: 0
		localOffsetSeconds: localOffsetSeconds.
]

{ #category : #'ansi protocol' }
DateAndTime >> minute [

	^self getSeconds // 60 \\ 60
]

{ #category : #'smalltalk-80' }
DateAndTime >> minutes [

	^ self minute

]

{ #category : #'ansi protocol' }
DateAndTime >> month [

	^ self 
		dayMonthYearDo: [ :d :m :y | m ]

]

{ #category : #'ansi protocol' }
DateAndTime >> monthAbbreviation [


	^ self monthName copyFrom: 1 to: 3
]

{ #category : #'smalltalk-80' }
DateAndTime >> monthIndex [


	^ self month
]

{ #category : #'ansi protocol' }
DateAndTime >> monthName [


	^ Month nameOfMonth: self month
]

{ #category : #'squeak protocol' }
DateAndTime >> nanoSecond [

	^utcMicroseconds \\ 1000000 * 1000

]

{ #category : #'squeak protocol' }
DateAndTime >> noon [
	"Answer a DateAndTime starting at noon"

	^ self dayMonthYearDo: 
		[ :d :m :y | self class year: y month: m day: d hour: 12 minute: 0 second: 0 ]

]

{ #category : #private }
DateAndTime >> normalize: i ticks: ticks base: base [

	| tick div quo rem |
	tick := ticks at: i.
	div := tick asInteger digitDiv: base neg: tick negative.
	quo := (div at: 1) normalize.
	rem := (div at: 2) normalize.
	rem < 0 ifTrue: [ quo := quo - 1. rem := base + rem ].
	ticks at: (i-1) put: ((ticks at: i-1) + quo).
	ticks at: i put: rem

]

{ #category : #'ansi protocol' }
DateAndTime >> offset [

	^ Duration seconds: localOffsetSeconds
]

{ #category : #'ansi protocol' }
DateAndTime >> offset: anOffset [

	"Answer a <DateAndTime> equivalent to the receiver but with its local time 
	being offset from UTC by offset."

	| newOffset newMicros |
	self flag: #FIXME. "check the definition of this and of #utcOffset:"
	newOffset := anOffset asDuration asSeconds.
	newMicros := localOffsetSeconds - newOffset * 1000000 + utcMicroseconds.
	^ self class utcMicroseconds: newMicros offset: newOffset

]

{ #category : #accessing }
DateAndTime >> offsetSeconds [

	^localOffsetSeconds
]

{ #category : #'initialize-release' }
DateAndTime >> posixEpochJulianDays [

	^self class daysFromSmalltalkEpochToPosixEpoch + SqueakEpoch
]

{ #category : #'squeak protocol' }
DateAndTime >> printHMSOn: aStream [
	"Print just hh:mm:ss"
	
	| seconds |
	seconds := self getSeconds.
	seconds // 3600 printOn: aStream base: 10 length: 2 padded: true.
	aStream nextPut: $:.
	seconds \\ 3600 // 60 printOn: aStream base: 10 length: 2 padded: true.
	aStream nextPut: $:.
	seconds \\ 60 printOn: aStream base: 10 length: 2 padded: true
]

{ #category : #'squeak protocol' }
DateAndTime >> printOn: aStream [
	"Print as per ISO 8601 sections 5.3.3 and 5.4.1.
	Prints either:
		'YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for positive years) or '-YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for negative years)"

	^self printOn: aStream withLeadingSpace: false

]

{ #category : #'squeak protocol' }
DateAndTime >> printOn: aStream withLeadingSpace: printLeadingSpaceToo [
	"Print as per ISO 8601 sections 5.3.3 and 5.4.1.
	If printLeadingSpaceToo is false, prints either:
		'YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for positive years) or '-YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for negative years)
	If printLeadingSpaceToo is true, prints either:
		' YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for positive years) or '-YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for negative years)
	"

	| nanos offsetSeconds |
	self printYMDOn: aStream withLeadingSpace: printLeadingSpaceToo.
	aStream nextPut: $T.
	self printHMSOn: aStream.
	(nanos := utcMicroseconds \\ 1000000 * 1000) = 0 ifFalse: [
		| length |
		aStream nextPut: $..
		length := 9.
		[ nanos \\ 10 = 0 ] whileTrue: [
			nanos := nanos // 10.
			length := length - 1 ].
		nanos printOn: aStream base: 10 length: length padded: true ].
	"Print offset"
	aStream nextPut: (localOffsetSeconds >= 0 ifTrue: [ $+ ] ifFalse: [ $- ]).
	offsetSeconds := localOffsetSeconds abs.
	offsetSeconds // 3600 printOn: aStream base: 10 length: 2 padded: true.
	aStream nextPut: $:.
	offsetSeconds \\ 3600 // 60 printOn: aStream base: 10 length: 2 padded: true.
	(offsetSeconds := offsetSeconds \\ 60) = 0 ifFalse: [
		aStream
			nextPut: $:;
			print: offsetSeconds ]
]

{ #category : #'squeak protocol' }
DateAndTime >> printYMDOn: aStream [
	"Print just YYYY-MM-DD part.
	If the year is negative, prints out '-YYYY-MM-DD'."

	^self printYMDOn: aStream withLeadingSpace: false.

]

{ #category : #'squeak protocol' }
DateAndTime >> printYMDOn: aStream withLeadingSpace: printLeadingSpaceToo [
	"Print just the year, month, and day on aStream.

	If printLeadingSpaceToo is true, then print as:
		' YYYY-MM-DD' (if the year is positive) or '-YYYY-MM-DD' (if the year is negative)
	otherwise print as:
		'YYYY-MM-DD' or '-YYYY-MM-DD' "

	self dayMonthYearDo: [ :day :month :year |
		year negative
			ifTrue: [ aStream nextPut: $- ]
			ifFalse: [ printLeadingSpaceToo ifTrue: [ aStream space ] ].
		year abs printOn: aStream base: 10 length: 4 padded: true.
		aStream nextPut: $-.
		month printOn: aStream base: 10 length: 2 padded: true.
		aStream nextPut: $-.
		day printOn: aStream base: 10 length: 2 padded: true ]
]

{ #category : #'objects from disk' }
DateAndTime >> readDataFrom: aDataStream size: varsOnDisk [
	"Fill in the fields of self based on the contents of aDataStream. The serialized
	data will have four instance variables, because all instances are serialized in a
	cononical format as if having originating from an instance with the traditional
	seconds/offset/jdn/nanos instance variables."
 
	| seconds offset jdn nanos |
	seconds := aDataStream next.
	offset := aDataStream next.
	jdn := aDataStream next.
	nanos := aDataStream next.
	localOffsetSeconds := offset ifNil: [ 0 ] ifNotNil: [ :off | off asSeconds ].
	utcMicroseconds := self
				microsecondsFromDay: jdn
				seconds: seconds
				nanos: nanos
				offset: localOffsetSeconds.
]

{ #category : #'ansi protocol' }
DateAndTime >> second [

	^self getSeconds \\ 60
]

{ #category : #'smalltalk-80' }
DateAndTime >> seconds [

	^ self second

]

{ #category : #private }
DateAndTime >> secondsSinceMidnight [

	^ self getSeconds
]

{ #category : #private }
DateAndTime >> setJdn: jdn seconds: s nano: n localOffsetSeconds: offset [

	localOffsetSeconds := offset.
	utcMicroseconds := self
				microsecondsFromDay: jdn
				seconds: s
				nanos: n
				offset: offset
]

{ #category : #'squeak protocol' }
DateAndTime >> setJdn: jdn seconds: s nano: n offset: o [

	self setJdn: jdn seconds: s nano: n localOffsetSeconds: o asSeconds.

]

{ #category : #accessing }
DateAndTime >> species [
	^DateAndTime
]

{ #category : #'objects from disk' }
DateAndTime >> storeDataOn: aDataStream [
	"Store myself on a DataStream.  Answer self. 
	Store 4 variables worth of data, corresponding to the 4 instance variables of the old
	DateAndTime implementation, which is to be used as common format for externally
	stored instances."

	" | dt dt2 |
	dt := DateAndTime now.
	dt2 := DataStream testWith: dt.
	{ dt . dt2 }."

	| cntInstVars cntIndexedVars ticks jdn offset seconds nanos |
	"Set the instance variable count to 4 to match that of a cononical instance." 
	cntInstVars := 4.
	cntIndexedVars := self basicSize.
	aDataStream
		beginInstance: self xxxClass
		size: cntInstVars + cntIndexedVars.

	"Create the 4 values of the old format DateAndTime"
	ticks := self ticks. 	"{days. seconds. nanoSeconds}."
	offset := self offset.
	jdn := ticks at: 1.
	seconds := ticks at: 2.
	nanos := ticks at: 3.
	aDataStream
		nextPut: seconds;
		nextPut: offset;
		nextPut: jdn;
		nextPut: nanos.

]

{ #category : #private }
DateAndTime >> ticks [
	"Private - answer an array with our instance variables. Assumed to be UTC "

	^ Array with: self julianDayNumber with: self getSeconds with: self nanoSecond

]

{ #category : #private }
DateAndTime >> ticks: ticks offset: utcOffset [
	"ticks is {julianDayNumber. secondCount. nanoSeconds}"

	| jdn s nanos normalizedTicks |
	normalizedTicks := ticks copy.
	self normalize: 3 ticks: normalizedTicks base: NanosInSecond.
	self normalize: 2 ticks: normalizedTicks base: SecondsInDay.

	jdn	:= normalizedTicks at: 1.
	s := normalizedTicks at: 2.
	nanos := normalizedTicks at: 3.
	localOffsetSeconds := utcOffset ifNil: [0] ifNotNil: [utcOffset asSeconds].
	utcMicroseconds := self microsecondsFromDay: jdn seconds: s nanos: nanos offset: localOffsetSeconds.

]

{ #category : #'ansi protocol' }
DateAndTime >> timeZoneAbbreviation [

	^ self class localTimeZone abbreviation
]

{ #category : #'ansi protocol' }
DateAndTime >> timeZoneName [

	^ self class localTimeZone name
]

{ #category : #'squeak protocol' }
DateAndTime >> to: anEnd [
	"Answer a Timespan. anEnd conforms to protocol DateAndTime or protocol Timespan"

	^ Timespan starting: self ending: (anEnd asDateAndTime)

]

{ #category : #'squeak protocol' }
DateAndTime >> to: anEnd by: aDuration [
	"Answer a Timespan. anEnd conforms to protocol DateAndTime or protocol Timespan"

	^ (Schedule starting: self ending: (anEnd asDateAndTime))
		schedule: (Array with: aDuration asDuration);
		yourself

]

{ #category : #'squeak protocol' }
DateAndTime >> to: anEnd by: aDuration do: aBlock [
	"Answer a Timespan. anEnd conforms to protocol DateAndTime or protocol Timespan"

	^ (self to: anEnd by: aDuration) scheduleDo: aBlock
]

{ #category : #accessing }
DateAndTime >> utcMicroseconds [
	^utcMicroseconds
]

{ #category : #'initialize-release' }
DateAndTime >> utcMicroseconds: utcValue [
	"Allow value to be modified during initialization from a primitive in order to support
	monotonically increasing clock behavior."
	utcMicroseconds := utcValue
]

{ #category : #'initialize-release' }
DateAndTime >> utcMicroseconds: microsecondsSincePosixEpoch offset: tzOffset [

	utcMicroseconds := microsecondsSincePosixEpoch.
	localOffsetSeconds := tzOffset.

]

{ #category : #'squeak protocol' }
DateAndTime >> utcOffset: anOffset [ 
	"Answer a DateAndTime equivalent to the receiver but offset from UTC by anOffset"
	^ self class
		utcMicroseconds: utcMicroseconds
		offset: anOffset asDuration asSeconds
]

{ #category : #'ansi protocol' }
DateAndTime >> year [
	^ self
		dayMonthYearDo: [ :d :m :y | y ]

]
