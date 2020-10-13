"
This represents a particular point in time during any given day.  For example, '5:19:45 pm'.

If you need a point in time on a particular day, use DateAndTime.  If you need a duration of time, use Duration.

"
Class {
	#name : #Time,
	#superclass : #Magnitude,
	#instVars : [
		'seconds',
		'nanos'
	],
	#classVars : [
		'ClockPolicy',
		'HighResClockTicksPerMillisecond',
		'LastClockTick',
		'UpdateVMTimeZoneCacheAt',
		'UseHighResClockForTiming'
	],
	#pools : [
		'ChronologyConstants'
	],
	#category : #'Chronology-Core'
}

{ #category : #benchmarks }
Time class >> benchmarkMillisecondClock [		"Time benchmarkMillisecondClock"

	"Benchmark the time spent in a call to Time>>millisecondClockValue.

	On the VM level this tests the efficiency of calls to ioMSecs()."

	"PII/400 Windows 98: 0.725 microseconds per call"

	| temp1 temp2 temp3 delayTime nLoops time |

	delayTime := 5000. "Time to run benchmark is approx. 2*delayTime"



	"Don't run the benchmark if we have an active delay since

	we will measure the additional penalty in the primitive dispatch

	mechanism (see #benchmarkPrimitiveResponseDelay)."

	Delay anyActive ifTrue:[

		^self notify:'Some delay is currently active.

Running this benchmark will not give any useful result.'].



	"Flush the cache for this benchmark so we will have

	a clear cache hit for each send to #millisecondClockValue below"

	Object flushCache.

	temp1 := 0.

	temp2 := self. "e.g., temp1 == Time"

	temp3 := self millisecondClockValue + delayTime.



	"Now check how often we can run the following loop in the given time"

	[temp2 millisecondClockValue < temp3]

		whileTrue:[temp1 := temp1 + 1].



	nLoops := temp1. "Remember the loops we have run during delayTime"



	"Setup the second loop"

	temp1 := 0.

	temp3 := nLoops.



	"Now measure how much time we spend without sending #millisecondClockValue"

	time := Time millisecondClockValue.

	[temp1 < temp3]

		whileTrue:[temp1 := temp1 + 1].

	time := Time millisecondClockValue - time.



	"And compute the number of microseconds spent per call to #millisecondClockValue"

	^((delayTime - time * 1000.0 / nLoops) truncateTo: 0.001) printString,

		' microseconds per call to Time>>millisecondClockValue'

]

{ #category : #benchmarks }
Time class >> benchmarkPrimitiveResponseDelay [	"Time benchmarkPrimitiveResponseDelay"

	"Benchmark the overhead for primitive dispatches with an active Delay.

	On the VM level, this tests the efficiency of ioLowResMSecs."



	"PII/400 Windows98: 0.128 microseconds per prim"



	"ar 9/6/1999: This value is *extremely* important for stuff like sockets etc.

	I had a bad surprise when Michael pointed this particular problem out:

	Using the hardcoded clock() call for ioLowResMSecs on Win32 resulted in an overhead

	of 157.4 microseconds per primitive call - meaning you can't get no more than

	approx. 6000 primitives per second on my 400Mhz PII system with an active delay!

	BTW, it finally explains why Squeak seemed soooo slow when running PWS or 

	other socket stuff. The new version (not using clock() but some Windows function) 

	looks a lot better (see above; approx. 8,000,000 prims per sec with an active delay)."



	| nLoops bb index baseTime actualTime delayTime |

	delayTime := 5000. "Time to run this test is approx. 3*delayTime"



	Delay anyActive ifTrue:[

		^self notify:'Some delay is currently active.

Running this benchmark will not give any useful result.'].



	bb := Array new: 1. "The object we send the prim message to"



	"Compute the # of loops we'll run in a decent amount of time"

	[(Delay forMilliseconds: delayTime) wait] 

		forkAt: Processor userInterruptPriority.



	nLoops := 0.

	[Delay anyActive] whileTrue:[

		bb basicSize; basicSize; basicSize; basicSize; basicSize; 

			basicSize; basicSize; basicSize; basicSize; basicSize.

		nLoops := nLoops + 1.

	].



	"Flush the cache and make sure #basicSize is in there"

	Object flushCache.

	bb basicSize.



	"Now run the loop without any active delay

	for getting an idea about its actual speed."

	baseTime := self millisecondClockValue.

	index := nLoops.

	[index > 0] whileTrue:[

		bb basicSize; basicSize; basicSize; basicSize; basicSize; 

			basicSize; basicSize; basicSize; basicSize; basicSize.

		index := index - 1.

	].

	baseTime := self millisecondClockValue - baseTime.



	"Setup the active delay but try to never make it active"

	[(Delay forMilliseconds: delayTime + delayTime) wait] 

		forkAt: Processor userInterruptPriority.



	"And run the loop"

	actualTime := self millisecondClockValue.

	index := nLoops.

	[index > 0] whileTrue:[

		bb basicSize; basicSize; basicSize; basicSize; basicSize; 

			basicSize; basicSize; basicSize; basicSize; basicSize.

		index := index - 1.

	].

	actualTime := self millisecondClockValue - actualTime.



	"And get us some result"

	^((actualTime - baseTime) * 1000 asFloat / (nLoops * 10) truncateTo: 0.001) printString,

		' microseconds overhead per primitive call'

]

{ #category : #'class initialization' }
Time class >> clockPolicy [

	^ClockPolicy
]

{ #category : #'class initialization' }
Time class >> clockPolicy: aSymbol [
	"When sequencial calls are made to DateAndTime now, it may be desirable to
	force the system clock to be monotonic, and it may be desirable for the clock
	to appear to be strictly increasing with no repeat values. The ClockPolicy
	identifies which of several possible strategies to use.

	Allowable values are
		#acceptPlatformTime
		#monotonicAllowDuplicates
		#monotonicForceMicrosecondIncrement
		#monotonicForceNanosecondIncrement "

	self assert: (
		#(
			acceptPlatformTime
			monotonicAllowDuplicates
			monotonicForceMicrosecondIncrement
			monotonicForceNanosecondIncrement) includes: aSymbol).
	ClockPolicy := aSymbol
]

{ #category : #'general inquiries' }
Time class >> condenseBunches: aCollectionOfSeconds [
	| secArray now out pause prev bunchEnd |
	"Identify the major intervals in a bunch of numbers.  
	Each number is a seconds since 1901 that represents a date and time.
	We want the last event in a bunch.  Return array of seconds for:
	
	Every event in the last half hour.
		Every bunch separated by 30 min in the last 24 hours.
	
	Every bunch separated by two hours before that."

	"Time condenseBunches: 
		(#(20 400 401  20000 20200 20300 40000 45000  200000 201000 202000) 
			collect: [ :tt | self totalSeconds - tt])
"

	secArray := aCollectionOfSeconds asSortedCollection.
	pause := 1.
	now := self totalSeconds.
	out := OrderedCollection new.
	prev := 0.
	bunchEnd := nil.
	secArray reverseDo: [:secs | | ago | "descending"
		ago := now - secs.
		ago > (60*30) ifTrue: [pause := "60*30" 1800].
		ago > (60*60*24) ifTrue: [pause := "60*120" 7200].
		ago - prev >= pause ifTrue: [out add: bunchEnd.  bunchEnd := secs].
		prev := ago].
	out add: bunchEnd.
	out removeFirst.
	^ out

]

{ #category : #'squeak protocol' }
Time class >> current [ 

	^ self now
]

{ #category : #'smalltalk-80' }
Time class >> dateAndTimeFromSeconds: secondCount [

	^ Array
		with: (Date fromSeconds: secondCount)
		with: (Time fromSeconds: secondCount \\ 86400)
]

{ #category : #'smalltalk-80' }
Time class >> dateAndTimeNow [
	"Answer a two-element Array of (Date today, Time now)."

	^ self dateAndTimeFromSeconds: self totalSeconds

]

{ #category : #'general inquiries' }
Time class >> durationToRun: timedBlock [
	"Answer a duration timedBlock takes to return its value"

	^(self nanosecondsToRun: timedBlock) nanoSeconds
]

{ #category : #clock }
Time class >> estimateHighResClockTicksPerMillisecond [

	| t0 t1 t2 t3 |
	
	"Count the ticks ellapsed during a 10ms busy loop"
	t0 := Time utcMicrosecondClock + 200.
	[Time utcMicrosecondClock >= t0] whileFalse.
	t1 := self highResClock.
	[Time utcMicrosecondClock >= (t0 + 10000)] whileFalse.
	t1 := self highResClock - t1 * 1000 // (Time utcMicrosecondClock - t0).
	
	"Count the ticks ellapsed during a 20ms busy loop"
	t0 := Time utcMicrosecondClock + 200.
	[Time utcMicrosecondClock >= t0] whileFalse.
	t2 := self highResClock.
	[Time utcMicrosecondClock >= (t0 + 20000)] whileFalse.
	t2 := self highResClock - t2 * 1000 // (Time utcMicrosecondClock - t0).
	
	"Count the ticks ellapsed during a 30ms busy loop"
	t0 := Time utcMicrosecondClock + 200.
	[Time utcMicrosecondClock >= t0] whileFalse.
	t3 := self highResClock.
	[Time utcMicrosecondClock >= (t0 + 30000)] whileFalse.
	t3 := self highResClock - t3 * 1000 // (Time utcMicrosecondClock - t0).
	
	"Take the median of the 3 estimates as the best"
	^ t1 <= t2
		ifTrue: [t2 <= t3
				ifTrue: [t2]
				ifFalse: [t1 <= t3
						ifTrue: [t3]
						ifFalse: [t1]]]
		ifFalse: [t1 <= t3
				ifTrue: [t1]
				ifFalse: [t2 <= t3
						ifTrue: [t3]
						ifFalse: [t2]]]
]

{ #category : #clock }
Time class >> eventMillisecondClock [
	"In order to make certain event handling code work (cf MouseEvent>asMouseMove) we need access
	to the tick kept by ioMSecs() "
	"Time eventMillisecondClock"
	<primitive: 135>
	^0
]

{ #category : #'smalltalk-80' }
Time class >> fromSeconds: secondCount [ 
	"Answer an instance of me that is secondCount number of seconds since midnight."

	| integerSeconds nanos |
	integerSeconds := secondCount truncated.
	integerSeconds = secondCount
		ifTrue: [nanos := 0]
		ifFalse: [nanos := (secondCount - integerSeconds * NanosInSecond) asInteger].
	^ self seconds: integerSeconds nanoSeconds: nanos

]

{ #category : #clock }
Time class >> highResClock [
	"Time highResClock"
	"Primitive. Answer the value of the high resolution clock if this computer has one.
	Usually, this should be the highest resolution value available, for example on Intel
	it will be the value of the time stamp counter register."
	<primitive: 'primitiveHighResClock'>
	^0
]

{ #category : #clock }
Time class >> highResClockTicksPerMillisecond [
	HighResClockTicksPerMillisecond = 0
		ifTrue:
			[HighResClockTicksPerMillisecond := self estimateHighResClockTicksPerMillisecond].
	^HighResClockTicksPerMillisecond
]

{ #category : #'squeak protocol' }
Time class >> hour: hour minute: minute second: second [
	"Answer a Time"

	^ self hour: hour minute: minute second: second nanoSecond: 0

]

{ #category : #'squeak protocol' }
Time class >> hour: hour minute: minute second: second  nanoSecond: nanoCount [
	"Answer a Time - only second precision for now"

	^ self 
		seconds: (hour * SecondsInHour) + (minute * SecondsInMinute) + second 
		nanoSeconds: nanoCount

]

{ #category : #'general inquiries' }
Time class >> humanWordsForSecondsAgo: secs [
	| date today |
	"Return natural language for this date and time in the past."

	secs <= 1 ifTrue: [^ 'a second ago'].
	secs < 45 ifTrue: [^ secs printString, ' seconds ago'].
	secs < 90 ifTrue: [^ 'a minute ago'].
	secs < "45*60" 2700 ifTrue: [^ (secs//60) printString, ' minutes ago'].
	secs < "90*60" 5400 ifTrue: [^ 'an hour ago'].
	secs < "18*60*60" 64800 ifTrue: [^ (secs//3600) printString, ' hours ago'].
	date := Date fromSeconds: self totalSeconds - secs.		"now work with dates"
	today := Date today.
	date > (today subtractDays: 2) ifTrue: [^ 'yesterday'].
	date > (today subtractDays: 8) ifTrue: [^ 'last ', date dayOfWeekName].
	date > (today subtractDays: 13) ifTrue: [^ 'a week ago'].
	date > (today subtractDays: 28) ifTrue: [
		^ ((today subtractDate: date)//7) printString, ' weeks ago'].
	date > (today subtractDays: 45) ifTrue: [^ 'a month ago'].
	date > (today subtractDays: 300) ifTrue: [^ 'last ', date monthName].
	^ date monthName, ', ', date year printString

"Example
#(0.5 30 62 130 4000 10000 60000 90000 345600 864000 1728000 3456000 17280000 34560000 345600000) 
		collect: [:ss | Time humanWordsForSecondsAgo: ss].
"

]

{ #category : #'class initialization' }
Time class >> initialize [
	" self initialize "

	LastClockTick ifNil: [ LastClockTick := 0 ].
	
	HighResClockTicksPerMillisecond ifNil: [ HighResClockTicksPerMillisecond := 0 ].

	ClockPolicy ifNil: [
		"self clockPolicy: #acceptPlatformTime."
		self clockPolicy: #monotonicAllowDuplicates.
		"self clockPolicy: #monotonicForceMicrosecondIncrement."
		"self clockPolicy: #monotonicForceNanosecondIncrement." ]
]

{ #category : #clock }
Time class >> localMicrosecondClock [
	"Answer the local microseconds since the Smalltalk epoch (January 1st 1901, the start of the 20th century).
	 The value is derived from the current UTC wallclock time and the image's current notion of time zone."
	^self utcMicrosecondClock + (DateAndTime localOffset asSeconds * 1000000)
]

{ #category : #clock }
Time class >> localMicrosecondClockPrimitive [
	"Answer the local microseconds since the Smalltalk epoch (January 1st 1901, the start of the 20th century).
	 The value is derived from the Posix epoch with a constant offset corresponding to elapsed microseconds
	 between the two epochs according to RFC 868, and with an offset duration corresponding to the current
	 offset of local time from UTC."
	<primitive: 241>
	^0
]

{ #category : #clock }
Time class >> localMicrosecondClockWithOffset [
	"Answer an array with local microseconds since the Smalltalk epoch and the
	current seconds offset from GMT in the local time zone."

	| result |
	result := self posixMicrosecondClockWithOffset.
	"DateAndTime unixEpoch asSeconds"
	result at: 1 put: result first + ((2177452800 + result second) * 1000000).
	^result
]

{ #category : #'general inquiries' }
Time class >> microsecondsToRun: timedBlock [ 
	"Answer the number of microseconds timedBlock takes to return its value."

	| startUsecs |
	(self useHighResClockForTiming and: [self highResClock ~= 0])
		ifTrue: [	^(self nanosecondsToRunHighRes: timedBlock) + 500 // 1000].
	startUsecs := self utcMicrosecondClock.
	timedBlock value.
	^self utcMicrosecondClock - startUsecs
]

{ #category : #'squeak protocol' }
Time class >> midnight [

	^ self seconds: 0

]

{ #category : #'ansi protocol' }
Time class >> milliSecondsSinceMidnight [
	^self localMicrosecondClock // 1000 \\ 86400000 "24 * 60 * 60 * 1000"
]

{ #category : #'general inquiries' }
Time class >> millisecondClock [
	"Answer the value of the millisecond clock. Unlike older implementatins, this is a clock; it will never roll-over."

	^self utcMicrosecondClock // 1000
]

{ #category : #'general inquiries' }
Time class >> millisecondClockValue [
	"Answer the value of the millisecond clock."

	^self utcMicrosecondClock // 1000
]

{ #category : #'squeak protocol' }
Time class >> milliseconds: currentTime since: lastTime [
	"Answer the elapsed time since last recorded in milliseconds (i.e. of millisecondClockValue).
	 Since the time basis is now a 61-bit or greater UTC microsecond clock, rollover is no longer an issue."

	^currentTime - lastTime
]

{ #category : #'squeak protocol' }
Time class >> millisecondsSince: lastTime [
	"Answer the elapsed time since last recorded in milliseconds.
	Compensate for rollover."

	^self milliseconds: self millisecondClockValue since: lastTime

]

{ #category : #'general inquiries' }
Time class >> millisecondsToRun: timedBlock [ 
	"Answer the number of milliseconds timedBlock takes to return its value."

	^(self microsecondsToRun: timedBlock) + 500 // 1000
]

{ #category : #'general inquiries' }
Time class >> namesForTimes: arrayOfSeconds [
	| simpleEnglish final prev |
	"Return English descriptions of the times in the array.  They are each seconds since 1901.  If two names are the same, append the date and time to distinguish them."

	simpleEnglish := arrayOfSeconds collect: [:secsAgo |
		self humanWordsForSecondsAgo: self totalSeconds - secsAgo].
	prev := ''.
	final := simpleEnglish copy.
	simpleEnglish withIndexDo: [:eng :ind | | prevPair myPair | 
		eng = prev ifFalse: [eng]
			ifTrue: ["both say 'a month ago'"
				prevPair := self dateAndTimeFromSeconds: 
						(arrayOfSeconds at: ind-1).
				myPair := self dateAndTimeFromSeconds: 
						(arrayOfSeconds at: ind).
				(final at: ind-1) = prev ifTrue: ["only has 'a month ago'"
					final at: ind-1 put: 
							(final at: ind-1), ', ', prevPair first mmddyyyy].
				final at: ind put: 
							(final at: ind), ', ', myPair first mmddyyyy.
				prevPair first = myPair first 
					ifTrue: [
						(final at: ind-1) last == $m ifFalse: ["date but no time"
							final at: ind-1 put: 
								(final at: ind-1), ', ', prevPair second printMinutes].
						final at: ind put: 
							(final at: ind), ', ', myPair second printMinutes]].
		prev := eng].
	^ final

]

{ #category : #'general inquiries' }
Time class >> nanosecondsToRun: timedBlock [
	"Answer the number of nanoseconds timedBlock takes to return its value.
	Use high resolution clock if available and preferred."

	| startUsecs |
	(self useHighResClockForTiming and: [self highResClock ~= 0])
		ifTrue: [	^(self nanosecondsToRunHighRes: timedBlock)].
	"Fallback to microseconds clock"
	startUsecs := self utcMicrosecondClock.
	timedBlock value.
	^self utcMicrosecondClock - startUsecs * 1000
]

{ #category : #'general inquiries' }
Time class >> nanosecondsToRunHighRes: timedBlock [
	"Answer the number of nanoseconds timedBlock takes to return its value using high resolution clock.
	This assumes that high resolution clock is available, has a constant rate, and is synchronized between multi-core CPU"

	| ticks |
	ticks := self highResClock.
	timedBlock value.
	^(self highResClock - ticks
		+ (self highResClock - self highResClock ) "subtract the ticks taken by the call to highResClock itself"
		* 1e6 // self highResClockTicksPerMillisecond) "and convert ticks to nanoSeconds"
]

{ #category : #'smalltalk-80' }
Time class >> new [
	"Answer a Time representing midnight"

	^ self midnight
]

{ #category : #'squeak protocol' }
Time class >> noon [

	^ self seconds: (SecondsInDay / 2)

]

{ #category : #'ansi protocol' }
Time class >> now [
	"Answer a Time representing the time right now - this is a 24 hour clock."
	| localUsecs localUsecsToday |
	localUsecs := self localMicrosecondClock.
	localUsecsToday := localUsecs \\ MicrosecondsInDay.
	^ self
		seconds: localUsecsToday // 1000000
		nanoSeconds: localUsecsToday \\ 1000000 * 1000
]

{ #category : #clock }
Time class >> posixMicrosecondClockWithOffset [
	"Answer an array with local microseconds since the Posix epoch and the
	current seconds offset from GMT in the local time zone."

	| array posixUtcValue |
	array := self primPosixMicrosecondClockWithOffset.
	posixUtcValue := array at: 1.
	(self updateTimeZoneCacheAt: posixUtcValue) ifTrue: [ "Time zone may have changed: fetch again."
		self primPosixMicrosecondClockWithOffset: array.
		posixUtcValue := array at: 1 ].
	ClockPolicy caseOf: {
		[#acceptPlatformTime] -> [^ array] .
		[#monotonicAllowDuplicates] -> [
			posixUtcValue > LastClockTick
				ifTrue: [LastClockTick := posixUtcValue]
				ifFalse: [array at: 1 put: LastClockTick]] .
		[#monotonicForceMicrosecondIncrement] -> [
			posixUtcValue > LastClockTick
				ifTrue: [LastClockTick := posixUtcValue]
				ifFalse: [LastClockTick := LastClockTick + 1. "add one microsecond"
					array at: 1 put: LastClockTick]] .
		[#monotonicForceNanosecondIncrement] -> [
			posixUtcValue > LastClockTick
				ifTrue: [LastClockTick := posixUtcValue]
				ifFalse: [LastClockTick := LastClockTick + (1 / 1000). "add one nanosecond"
					array at: 1 put: LastClockTick]]
	} otherwise: [].
	^array
]

{ #category : #clock }
Time class >> posixMicrosecondClockWithOffset: aDateAndTime [
	"Initialize aDateAndTime initialized with local microseconds since the Posix
	epoch and the current seconds offset from GMT in the local time zone."

	| posixUtcValue |
	self primPosixMicrosecondClockWithOffset: aDateAndTime.
	posixUtcValue := aDateAndTime utcMicroseconds.
	(self updateTimeZoneCacheAt: posixUtcValue) ifTrue: [ "Time zone may have changed: fetch again."
		self primPosixMicrosecondClockWithOffset: aDateAndTime .
		posixUtcValue := aDateAndTime utcMicroseconds ].
	ClockPolicy caseOf: {
		[#acceptPlatformTime] -> [^ aDateAndTime] .
		[#monotonicAllowDuplicates] -> [
			posixUtcValue > LastClockTick
				ifTrue: [LastClockTick := posixUtcValue]
				ifFalse: [aDateAndTime utcMicroseconds: LastClockTick]] .
		[#monotonicForceMicrosecondIncrement] -> [
			posixUtcValue > LastClockTick
				ifTrue: [LastClockTick := posixUtcValue]
				ifFalse: [LastClockTick := LastClockTick + 1. "add one microsecond"
					aDateAndTime utcMicroseconds: LastClockTick]] .
		[#monotonicForceNanosecondIncrement] -> [
			posixUtcValue > LastClockTick
				ifTrue: [LastClockTick := posixUtcValue]
				ifFalse: [LastClockTick := LastClockTick + (1 / 1000). "add one nanosecond"
					aDateAndTime utcMicroseconds: LastClockTick]]
	} otherwise: [].
	^aDateAndTime
]

{ #category : #private }
Time class >> primPosixMicrosecondClockWithOffset [
	"Answer an array with UTC microseconds since the Posix epoch and the
	current seconds offset from GMT in the local time zone. If the primitive is
	not available, then answer the time and offset of Posix epoch GMT. This enables
	the image to continue running in the absence of #primitiveUtcWithOffset, thus
	avoiding the need to fallback code based on the earlier local microsecond clock
	mechanism."

	<primitive: 'primitiveUtcWithOffset'>
	^{0. 0}
]

{ #category : #private }
Time class >> primPosixMicrosecondClockWithOffset: arrayOrObjectWithTwoSlots [
	"Answer an array with UTC microseconds since the Posix epoch and the
	current seconds offset from GMT in the local time zone. If the primitive is
	not available, then answer the time and offset of Posix epoch GMT. This enables
	the image to continue running in the absence of #primitiveUtcWithOffset, thus
	avoiding the need to fallback code based on the earlier local microsecond clock
	mechanism.

	The parameter may be a two element array, or an object whose first two instance
	variables are expected to be UTC microseconds and seconds offset from GMT."

	<primitive: 'primitiveUtcWithOffset'>

	(arrayOrObjectWithTwoSlots instVarAt: 1)
		ifNil: [arrayOrObjectWithTwoSlots instVarAt: 1 put: 0].
	(arrayOrObjectWithTwoSlots instVarAt: 2)
		ifNil: [arrayOrObjectWithTwoSlots instVarAt: 2 put: 0]
]

{ #category : #clock }
Time class >> primitiveUpdateTimeZone [
	"Update the VMs notion of the current time zone.  The VM sets its notion
	 of the time zone once at start-up.  If one wants the VM to keep its notion
	 up-to-date arrange to invoke this primitive periodically."
	
	<primitive: 243>
	^nil "Return nil instead of self to indicate that the primitive failed."
]

{ #category : #'smalltalk-80' }
Time class >> readFrom: aStream [
	"Read a Time from the stream in the form:
		<hour>:<minute>:<second> <am/pm>

	<minute>, <second> or <am/pm> may be omitted.  e.g. 1:59:30 pm; 8AM; 15:30"

	| hourMinuteSecondNano |
	hourMinuteSecondNano := self readHourMinuteSecondNanoFrom: aStream.
	^ self 
		hour: hourMinuteSecondNano first 
		minute: hourMinuteSecondNano second 
		second: hourMinuteSecondNano third 
		nanoSecond: hourMinuteSecondNano fourth

	"Time readFrom: (ReadStream on: '2:23:09 pm')"
]

{ #category : #'smalltalk-80' }
Time class >> readHourMinuteSecondNanoFrom: aStream [
	"Read a Time from the stream in the form:
		<hour>:<minute>:<second> <am/pm>

	<minute>, <second> or <am/pm> may be omitted.  e.g. 1:59:30 pm; 8AM; 15:30"

	| hour minute second ampm nanos nanosBuffer |
	hour := Integer readFrom: aStream.
	minute := 0.
	second := 0.
	nanosBuffer := '000000000' copy.
	nanos := WriteStream on: nanosBuffer.
	(aStream peekFor: $:) 
		ifTrue: [
			minute := Integer readFrom: aStream.
			(aStream peekFor: $:) 
				ifTrue: [
					second := Integer readFrom: aStream.
					(aStream peekFor: $.)
						ifTrue: [
							[aStream atEnd not and: [aStream peek isDigit]]
								whileTrue: [nanos nextPut: aStream next]]]].
	aStream skipSeparators.
	(aStream atEnd not and: ['PApa' includes: aStream peek]) ifTrue: 
		[ampm := aStream next asLowercase.
		(ampm = $p and: [hour < 12]) ifTrue: [hour := hour + 12].
		(ampm = $a and: [hour = 12]) ifTrue: [hour := 0].
		(aStream peekFor: $m) ifFalse: [aStream peekFor: $M ]].
	^ { hour . minute . second . nanosBuffer asInteger }

	"Time readFrom: (ReadStream on: '2:23:09 pm')"
]

{ #category : #'squeak protocol' }
Time class >> seconds: seconds [
	"Answer a Time from midnight."

	^ self basicNew ticks: (Duration seconds: seconds) ticks
]

{ #category : #'squeak protocol' }
Time class >> seconds: seconds nanoSeconds: nanoCount [
	"Answer a Time from midnight."

	^ self basicNew
		ticks: (Duration seconds: seconds nanoSeconds: nanoCount) ticks

]

{ #category : #'system startup' }
Time class >> startUp: resuming [

	resuming ifTrue: [
		LastClockTick := 0 ]
]

{ #category : #'smalltalk-80' }
Time class >> totalSeconds [
	"Answer the total seconds since the Squeak epoch: 1 January 1901, in local time."

	^self localMicrosecondClock // 1000000
]

{ #category : #clock }
Time class >> updateTimeZoneCacheAt: posixUtcMicrosecondClock [
	"Tell the VM to update its cached time zone value if the POSIX UTC time reached the valute stored in UpdateVMTimeZoneCacheAt has been reached. Assume that posixUtcMicrosecondClock is an integer with the current POSIX UTC microsecond clock value. Return true when the cache was updated to indicate that the time zone may have changed."

	| updateInterval |
	UpdateVMTimeZoneCacheAt ifNil: [
		"Automatic update is disabled."
		^false ].
	posixUtcMicrosecondClock < UpdateVMTimeZoneCacheAt ifTrue: [ ^false ].
	self primitiveUpdateTimeZone ifNil: [ 
		"The primitive failed."
		^false ].
	updateInterval := 1800000000. "This could be a preference but 30 minutes matches all upcoming DST change times."
	UpdateVMTimeZoneCacheAt := posixUtcMicrosecondClock // updateInterval + 1 * updateInterval "Round up posixUtcMicrosecondClock to the next multiple of updateInterval.".
	^true
]

{ #category : #preferences }
Time class >> useHighResClockForTiming [
	<preference: 'Use high resolution clock for timing'
	category: 'performance'
	description: 'This is used for measuring time ellapsed for running a block. High resolution clocks (known as TSC) are counter embedded on CPU and incremented at each cycle. They enable timing close to the nanosecond for GHz CPU. However, on older models, they might have a non constant rate depending on power saving: converting ticks to seconds is not reliable in this case, but knowing the number of cycles taken to perform the task is still a valuable information. TSC might also be un-synchronized between the multi-cores: if Squeak process is switched from 1 core to another during the timing, timing results could be random. If you have a recent CPU, you might prefer this option'
	type: #Boolean>
	^UseHighResClockForTiming ifNil: [ false ]
]

{ #category : #clock }
Time class >> utcMicrosecondClock [
	"Answer the UTC microseconds since the Smalltalk epoch (January 1st 1901, the start of the 20th century).
	 The value is derived from the Posix epoch with a constant offset corresponding to elapsed microseconds
	 between the two epochs according to RFC 868."
	<primitive: 240>
	^0
]

{ #category : #'ansi protocol' }
Time >> < aTime [

	^ self asDuration < aTime asDuration
]

{ #category : #'ansi protocol' }
Time >> = aTime [

	^ [ self ticks = aTime ticks ]
		on: MessageNotUnderstood do: [false]
]

{ #category : #'smalltalk-80' }
Time >> addSeconds: nSeconds [ 
	"Answer a Time that is nSeconds after the receiver."

	| secondsToAdd newNanos |
	(secondsToAdd := nSeconds truncated) = nSeconds
		ifTrue: [newNanos := nanos]
		ifFalse: [(newNanos := nanos + (nSeconds - secondsToAdd * NanosInSecond)) > NanosInSecond
				ifTrue: [secondsToAdd := secondsToAdd + 1.
					newNanos := newNanos - NanosInSecond]].
	^ self class seconds: seconds + secondsToAdd nanoSeconds: newNanos
]

{ #category : #'smalltalk-80' }
Time >> addTime: timeAmount [
	"Answer a Time that is timeInterval after the receiver. timeInterval is an 
	instance of Date or Time."

	^ self class seconds: self asSeconds + timeAmount asSeconds

]

{ #category : #'squeak protocol' }
Time >> asDate [

	^ Date today
]

{ #category : #'squeak protocol' }
Time >> asDateAndTime [

	^ DateAndTime today + self
]

{ #category : #'squeak protocol' }
Time >> asDuration [

	"Answer the duration since midnight"

	^ Duration seconds: seconds nanoSeconds: nanos
]

{ #category : #'squeak protocol' }
Time >> asMonth [

	^ self asDateAndTime asMonth
]

{ #category : #'squeak protocol' }
Time >> asNanoSeconds [
	"Answer the number of nanoseconds since midnight"

	^ self asDuration asNanoSeconds
]

{ #category : #'smalltalk-80' }
Time >> asSeconds [
	"Answer the number of seconds since midnight of the receiver."

	^ seconds

]

{ #category : #'squeak protocol' }
Time >> asTime [

	^ self
]

{ #category : #'squeak protocol' }
Time >> asTimeStamp [

	^ self asDateAndTime asTimeStamp
]

{ #category : #'squeak protocol' }
Time >> asWeek [

	^ self asDateAndTime asWeek
]

{ #category : #'squeak protocol' }
Time >> asYear [

	^ self asDateAndTime asYear
]

{ #category : #'ansi protocol' }
Time >> duration [

	^ Duration zero
]

{ #category : #'ansi protocol' }
Time >> hash [

	^ self ticks hash
]

{ #category : #printing }
Time >> hhmm24 [
	"Return a string of the form 1123 (for 11:23 am), 2154 (for 9:54 pm), of exactly 4 digits"

	^(String streamContents: 
		[ :aStream | self print24: true showSeconds: false on: aStream ])
			copyWithout: $:

]

{ #category : #'ansi protocol' }
Time >> hour [

	^ self hour24
]

{ #category : #'ansi protocol' }
Time >> hour12 [
	"Answer an <integer> between 1 and 12, inclusive, representing the hour 
	of the day in the 12-hour clock of the local time of the receiver."
	^ self hour24 - 1 \\ 12 + 1

]

{ #category : #'ansi protocol' }
Time >> hour24 [


	^ self asDuration hours
]

{ #category : #'smalltalk-80' }
Time >> hours [

	^ self hour
]

{ #category : #'smalltalk-80' }
Time >> intervalString [
	"Treat the time as a difference.  Give it in hours and minutes with two digits of accuracy."

	| d |
	d := self asDuration.
	^ String streamContents: [ :s |
		d hours > 0 ifTrue: [s print: d hours; nextPutAll: ' hours'].
		d minutes > 0 ifTrue: [s space; print: d minutes; nextPutAll: ' minutes'].
		d seconds > 0 ifTrue: [s space; print: d seconds; nextPutAll: ' seconds'] ]

]

{ #category : #'ansi protocol' }
Time >> meridianAbbreviation [

	^ self hour < 12 ifTrue: ['AM'] ifFalse: ['PM']

]

{ #category : #'ansi protocol' }
Time >> minute [

	^ self asDuration minutes
]

{ #category : #'smalltalk-80' }
Time >> minutes [

	^ self asDuration minutes
]

{ #category : #'squeak protocol' }
Time >> nanoSecond [


	^ nanos
]

{ #category : #printing }
Time >> print24 [
	"Return as 8-digit string 'hh:mm:ss', with leading zeros if needed"

	^String streamContents:
		[ :aStream | self print24: true on: aStream ]

]

{ #category : #printing }
Time >> print24: hr24 on: aStream [ 
	"Format is 'hh:mm:ss' or 'h:mm:ss am' "

	self print24: hr24 showSeconds: true on: aStream
]

{ #category : #printing }
Time >> print24: hr24 showSeconds: showSeconds on: aStream [ 
	"Format is 'hh:mm:ss' or 'h:mm:ss am'  or, if showSeconds is false, 'hh:mm' or 'h:mm am'"

	^self print24: hr24 showSeconds: showSeconds showSubseconds: false on: aStream 
]

{ #category : #printing }
Time >> print24: hr24 showSeconds: showSeconds showSubseconds: showSubseconds on: aStream [ 
	"Format is 'hh:mm:ss' or 'h:mm:ss am'  or, if showSeconds is false, 'hh:mm' or 'h:mm am'.
	If showSubseconds is true and our nanoSeconds are not zero, a decimal point and subseconds are added"

	| h m s |
	h := self hour. m := self minute. s := self second.
	hr24
		ifTrue: 
			[ h < 10 ifTrue: [ aStream nextPutAll: '0' ].
			h printOn: aStream ]
		ifFalse:
			[ h > 12
				ifTrue: [h - 12 printOn: aStream]
				ifFalse: 
					[h < 1
						ifTrue: [ 12 printOn: aStream ]
						ifFalse: [ h printOn: aStream ]]].

	aStream nextPutAll: (m < 10 ifTrue: [':0'] ifFalse: [':']).
	m printOn: aStream.

	showSeconds ifTrue:
		[ aStream nextPutAll: (s < 10 ifTrue: [':0'] ifFalse: [':']).
		(showSubseconds not or: [self nanoSecond = 0])
			ifTrue: [s asInteger printOn: aStream]
			ifFalse: [s asInteger * NanosInSecond + self nanoSecond asInteger 
				printOn: aStream asFixedPoint: NanosInSecond]].

	hr24 ifFalse:
		[ aStream nextPutAll: (h < 12 ifTrue: [' am'] ifFalse: [' pm']) ].

]

{ #category : #printing }
Time >> printMinutes [
	"Return as string 'hh:mm pm'  "

	^String streamContents:
		[ :aStream | self print24: false showSeconds: false on: aStream ]
]

{ #category : #printing }
Time >> printOn: aStream [ 

	self print24: false
		showSeconds: (self seconds ~= 0
				or: [self nanoSecond ~= 0])
		showSubseconds: self nanoSecond ~= 0
		on: aStream
]

{ #category : #'ansi protocol' }
Time >> second [


	^ self asDuration seconds

]

{ #category : #'smalltalk-80' }
Time >> seconds [

	^ self second
]

{ #category : #private }
Time >> seconds: secondCount [
	"Private - only used by Time class."

	seconds := secondCount.
	nanos := 0

]

{ #category : #private }
Time >> seconds: secondCount nanoSeconds: nanoCount [ 
	"Private - only used by Time class."

	seconds := secondCount.
	nanos := nanoCount

]

{ #category : #printing }
Time >> storeOn: aStream [

	aStream print: self printString; nextPutAll: ' asTime'

]

{ #category : #'smalltalk-80' }
Time >> subtractTime: timeAmount [ 
	"Answer a Time that is timeInterval before the receiver. timeInterval is  
	an instance of Date or Time."

	^ self class seconds: self asSeconds - timeAmount asSeconds
]

{ #category : #private }
Time >> ticks [
	"Answer an Array: { seconds. nanoSeconds }"

	^ Array with: 0 with: seconds with: nanos.
]

{ #category : #private }
Time >> ticks: anArray [
	"ticks is an Array: { days. seconds. nanoSeconds }"

	seconds := anArray at: 2.
	nanos := anArray at: 3

]

{ #category : #'squeak protocol' }
Time >> to: anEnd [
	"Answer a Timespan. anEnd must respond to #asDateAndTime"

	^ self asDateAndTime to: anEnd
]
