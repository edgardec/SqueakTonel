"
I represent a duration of time. I have nanosecond precision
"
Class {
	#name : #Duration,
	#superclass : #Magnitude,
	#instVars : [
		'nanos',
		'seconds'
	],
	#pools : [
		'ChronologyConstants'
	],
	#category : #'Chronology-Core'
}

{ #category : #'squeak protocol' }
Duration class >> days: aNumber [

	^ self seconds: aNumber * SecondsInDay nanoSeconds: 0
]

{ #category : #'ansi protocol' }
Duration class >> days: days hours: hours minutes: minutes seconds: seconds [

	^ self days: days hours: hours minutes: minutes seconds: seconds nanoSeconds: 0
]

{ #category : #'squeak protocol' }
Duration class >> days: days hours: hours minutes: minutes seconds: seconds nanoSeconds: nanos [	

 	^self
		seconds: seconds
			+ (minutes * SecondsInMinute) 
			+ (hours * SecondsInHour)
			+ (days * SecondsInDay)
		nanoSeconds: nanos

]

{ #category : #'ansi protocol' }
Duration class >> days: days seconds: seconds [

	^ self basicNew seconds: days * SecondsInDay + seconds nanoSeconds: 0

]

{ #category : #'squeak protocol' }
Duration class >> fromString: aString [

	^ self readFrom: (ReadStream on: aString)

]

{ #category : #'squeak protocol' }
Duration class >> hours: aNumber [

	^ self seconds: aNumber * SecondsInHour nanoSeconds: 0
]

{ #category : #'initialize-release' }
Duration class >> initialize [
	ChronologyConstants classPool
		at: #Zero
		put:
			(self basicNew
				seconds: 0
				nanoSeconds: 0) ;
		at: #OneDay
		put: 1 day
]

{ #category : #'squeak protocol' }
Duration class >> microSeconds: anInteger [
	^ self
		seconds: (anInteger quo: 1e6)
		nanoSeconds: (anInteger rem: 1e6) * 1000
]

{ #category : #'squeak protocol' }
Duration class >> milliSeconds: milliCount [ 
	
	^self
		seconds: (milliCount quo: 1000)
		nanoSeconds: (milliCount rem: 1000) * NanosInMillisecond
]

{ #category : #'squeak protocol' }
Duration class >> minutes: aNumber [

	^ self seconds: aNumber * SecondsInMinute nanoSeconds: 0
]

{ #category : #'squeak protocol' }
Duration class >> month: aMonth [
	"aMonth is an Integer or a String"
	
	^ (Month month: aMonth year: Year current year) duration

]

{ #category : #'squeak protocol' }
Duration class >> nanoSeconds: nanos [
	"This method is slow. If you have nanos less than 10^6 you should use #seconds:nanoSeconds: instead."

	| quo |
	quo := nanos quo: NanosInSecond.
	^ self basicNew
		seconds: quo
		nanoSeconds: nanos - (quo * NanosInSecond)

]

{ #category : #'squeak protocol' }
Duration class >> oneDay [
	"Answer the canonicalized Duration representing length of 1 day.  Used by Dates."
	^ OneDay
]

{ #category : #'squeak protocol' }
Duration class >> readDayHourMinuteSecondNanaFrom: aStream [
	"Formatted as per ANSI 5.8.2.16: [-]D:HH:MM:SS[.S]"

	| sign days hours minutes seconds nanos nanosBuffer |
	sign := (aStream peekFor: $-) ifTrue: [-1] ifFalse: [1].
	days := (aStream upTo: $:) asInteger sign: sign.
	hours := (aStream upTo: $:) asInteger sign: sign.
	minutes := (aStream upTo: $:) asInteger sign: sign.
	seconds := (aStream upTo: $.) asInteger sign: sign.
	nanosBuffer := '000000000' copy.
	nanos := WriteStream on: nanosBuffer.
	[aStream atEnd not and: [aStream peek isDigit]]
		whileTrue: [nanos nextPut: aStream next].
		
	^ { days . hours . minutes . seconds .nanosBuffer asInteger sign: sign }

	"	'0:00:00:00' asDuration
		'0:00:00:00.000000001' asDuration
		'0:00:00:00.999999999' asDuration
		'0:00:00:00.100000000' asDuration
		'0:00:00:00.001 ' asDuration
		'0:00:00:00.1' asDuration
		'0:00:00:01 ' asDuration
		'0:12:45:45' asDuration
		'1:00:00:00' asDuration
		'365:00:00:00' asDuration
		'-7:09:12:06.10' asDuration
		'+0:01:02:3' asDuration
 	"
]

{ #category : #'squeak protocol' }
Duration class >> readFrom: aStream [
	"Formatted as per ANSI 5.8.2.16: [-]D:HH:MM:SS[.S]"

	| dayHourMinuteSecondNano |
	dayHourMinuteSecondNano := self readDayHourMinuteSecondNanaFrom: aStream.
		
	^ self 
		days: dayHourMinuteSecondNano first 
		hours: dayHourMinuteSecondNano second 
		minutes: dayHourMinuteSecondNano third 
		seconds: dayHourMinuteSecondNano fourth 
		nanoSeconds: dayHourMinuteSecondNano fifth

	"	'0:00:00:00' asDuration
		'0:00:00:00.000000001' asDuration
		'0:00:00:00.999999999' asDuration
		'0:00:00:00.100000000' asDuration
		'0:00:00:00.001 ' asDuration
		'0:00:00:00.1' asDuration
		'0:00:00:01 ' asDuration
		'0:12:45:45' asDuration
		'1:00:00:00' asDuration
		'365:00:00:00' asDuration
		'-7:09:12:06.10' asDuration
		'+0:01:02:3' asDuration
 	"
]

{ #category : #'ansi protocol' }
Duration class >> seconds: seconds [

	seconds isInteger
		ifTrue: [ ^ self basicNew fullSeconds: seconds ]
		ifFalse: [ ^ self seconds: seconds nanoSeconds: 0 ]

]

{ #category : #'squeak protocol' }
Duration class >> seconds: seconds nanoSeconds: nanos [

	^ self basicNew
		seconds: seconds truncated
		nanoSeconds: seconds fractionPart * NanosInSecond + nanos
]

{ #category : #'squeak protocol' }
Duration class >> weeks: aNumber [

	^ self days: (aNumber * 7) seconds: 0

]

{ #category : #'ansi protocol' }
Duration class >> zero [
	"Answer the canonicalized instance of Duration zero."
	^ Zero
]

{ #category : #'ansi protocol' }
Duration >> * operand [
	"operand is a Number" 	^ self class nanoSeconds: ( (self asNanoSeconds * operand) asInteger)

]

{ #category : #'ansi protocol' }
Duration >> + operand [

	"operand is a Duration" 	^ self class nanoSeconds: (self asNanoSeconds + operand asNanoSeconds)
]

{ #category : #'ansi protocol' }
Duration >> - operand [
	"operand is a Duration" 	^ self + operand negated
]

{ #category : #'ansi protocol' }
Duration >> / operand [

	"operand is a Duration or a Number"


	^ operand isNumber
		ifTrue: [ self class nanoSeconds: (self asNanoSeconds / operand) asInteger ]
		ifFalse: [ self asNanoSeconds / operand asDuration asNanoSeconds ]

]

{ #category : #'squeak protocol' }
Duration >> // operand [

	"operand is a Duration or a Number"


	^ operand isNumber
		ifTrue: [ self class nanoSeconds: (self asNanoSeconds // operand) asInteger ]
		ifFalse: [ self asNanoSeconds // operand asDuration asNanoSeconds ]
]

{ #category : #'ansi protocol' }
Duration >> < comparand [

	^ self asNanoSeconds < comparand asNanoSeconds
]

{ #category : #'ansi protocol' }
Duration >> = comparand [ 
	"Answer whether the argument is a <Duration> representing the same 
	period of time as the receiver."

	^ self == comparand
		ifTrue: [true]
		ifFalse: 
			[self species = comparand species 
				ifTrue: [self asNanoSeconds = comparand asNanoSeconds]
				ifFalse: [false] ]

]

{ #category : #'squeak protocol' }
Duration >> \\ operand [

	"modulo. Remainder defined in terms of //. Answer a Duration with the 
	same sign as aDuration. operand is a Duration or a Number."

	^ operand isNumber
		ifTrue: [ self class nanoSeconds: (self asNanoSeconds \\ operand) ]
		ifFalse: [ self - (operand * (self // operand)) ]
]

{ #category : #'ansi protocol' }
Duration >> abs [

	^ self class seconds: seconds abs nanoSeconds: nanos abs
]

{ #category : #'squeak protocol' }
Duration >> ago [
	"Answer the DateAndTime which was the receiver's duration ago.
	e.g., 5 minutes ago.  2 days ago."
	^ DateAndTime now - self
]

{ #category : #'squeak protocol' }
Duration >> asDelay [

	^ Delay forDuration: self

]

{ #category : #'ansi protocol' }
Duration >> asDuration [

	^ self
]

{ #category : #'squeak protocol' }
Duration >> asMicroSeconds [
	nanos = 0 ifTrue: [ ^ seconds * 1e6 ].
	^ (seconds * 1e6) + (nanos // 1000)
]

{ #category : #'squeak protocol' }
Duration >> asMilliSeconds [

	nanos = 0 ifTrue: [ ^seconds * 1000 ].
	^nanos // 1000000 + (seconds * 1000)
]

{ #category : #'squeak protocol' }
Duration >> asNanoSeconds [

	^seconds * NanosInSecond + nanos
]

{ #category : #'ansi protocol' }
Duration >> asSeconds [


	^ seconds
]

{ #category : #'ansi protocol' }
Duration >> days [
	"Answer the number of days the receiver represents."

	^ seconds quo: SecondsInDay

]

{ #category : #'squeak protocol' }
Duration >> fromNow [
	"Answer the DateAndTime which which occurs the receiver's duration from now.
	e.g., 5 minutes fromNow.  2 days fromNow."
	^ DateAndTime now + self
]

{ #category : #private }
Duration >> fullSeconds: secondCount [
	"Private - only used by Duration class"

	seconds := secondCount.
	nanos := 0.

]

{ #category : #'ansi protocol' }
Duration >> hash [

 	^seconds bitXor: nanos
]

{ #category : #'ansi protocol' }
Duration >> hours [
	"Answer the number of hours the receiver represents."


	^ (seconds rem: SecondsInDay) quo: SecondsInHour
]

{ #category : #'initialize-release' }
Duration >> initialize [
	self seconds: 0 nanoSeconds: 0.

]

{ #category : #'squeak protocol' }
Duration >> isZero [

	^ seconds = 0 and: [ nanos = 0 ]

]

{ #category : #'ansi protocol' }
Duration >> minutes [

	"Answer the number of minutes the receiver represents."


	^ (seconds rem: SecondsInHour) quo: SecondsInMinute
]

{ #category : #'squeak protocol' }
Duration >> nanoSeconds [


	^ nanos
]

{ #category : #'ansi protocol' }
Duration >> negated [

	^ self class seconds: seconds negated nanoSeconds: nanos negated
]

{ #category : #'ansi protocol' }
Duration >> negative [


	^ self positive not
]

{ #category : #'ansi protocol' }
Duration >> positive [


	^ seconds = 0 ifTrue: [ nanos positive ] ifFalse: [ seconds positive ]
]

{ #category : #'squeak protocol' }
Duration >> printOn: aStream [
	"Format as per ANSI 5.8.2.16: [-]D:HH:MM:SS[.S]" 	| d h m s n |
	d := self days abs.
	h := self hours abs.
	m := self minutes abs.
 	s := self seconds abs truncated.
	n := self nanoSeconds abs. 	self negative ifTrue: [ aStream nextPut: $- ].
	d printOn: aStream. aStream nextPut: $:.
	h < 10 ifTrue: [ aStream nextPut: $0. ].
	h printOn: aStream. aStream nextPut: $:.
	m < 10 ifTrue: [ aStream nextPut: $0. ].
	m printOn: aStream. aStream nextPut: $:.
	s < 10 ifTrue: [ aStream nextPut: $0. ].
	s printOn: aStream.
	n = 0 ifFalse:
		[ | z ps |
		aStream nextPut: $..
		ps := n printString padded: #left to: 9 with: $0. 
		z := ps findLast: [ :c | c asciiValue > $0 asciiValue ].
		ps from: 1 to: z + 2 // 3 * 3 do: [ :c | aStream nextPut: c ] ]

]

{ #category : #'squeak protocol' }
Duration >> roundTo: aDuration [
	"e.g. if the receiver is 5 minutes, 37 seconds, and aDuration is 2 minutes, answer 6 minutes."

	^ self class nanoSeconds: (self asNanoSeconds roundTo: aDuration asNanoSeconds)

]

{ #category : #'ansi protocol' }
Duration >> seconds [
	"Answer the number of seconds the receiver represents."

	^seconds rem: SecondsInMinute
]

{ #category : #private }
Duration >> seconds: secondCount nanoSeconds: nanoCount [ 
	"Private - only used by Duration class"

	seconds := secondCount.
	nanos := nanoCount rounded.
	"normalize if signs do not match"
	[ nanos < 0 and: [ seconds > 0 ] ]
		whileTrue: [ seconds := seconds - 1.
			nanos := nanos + NanosInSecond ].
	[ seconds < 0 and: [ nanos > 0 ] ]
		whileTrue: [ seconds := seconds + 1.
			nanos := nanos - NanosInSecond ]


]

{ #category : #private }
Duration >> storeOn: aStream [

	aStream
		nextPut: $(;
		nextPutAll: self className;
		nextPutAll: ' seconds: ';
		print: seconds;
		nextPutAll: ' nanoSeconds: ';
		print: nanos;
		nextPut: $)

]

{ #category : #private }
Duration >> ticks [
	"Answer an array {days. seconds. nanoSeconds}. Used by DateAndTime and Time."

	| days |
	days := self days.
	^ Array 
		with: days
		with: seconds - (days * SecondsInDay)
		with: nanos

]

{ #category : #'squeak protocol' }
Duration >> truncateTo: aDuration [
	"e.g. if the receiver is 5 minutes, 37 seconds, and aDuration is 2 minutes, answer 4 minutes."

	^ self class
		nanoSeconds: (self asNanoSeconds truncateTo: aDuration asNanoSeconds)

]

{ #category : #'squeak protocol' }
Duration >> wait [
	"Convert this duration in a delay and wait once. Return the created delay so that the client can wait on it again if needed.
	
	Do-it: 3 minutes wait"
	
	| delay |
	delay := self asDelay.
	delay wait.
	^ delay
]
