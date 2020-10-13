"
I represent a duration starting on a specific DateAndTime.

If my start has an offset identical to my #defaultOffset then comparisons ignore timezone offset.
"
Class {
	#name : #Timespan,
	#superclass : #Magnitude,
	#instVars : [
		'start',
		'duration'
	],
	#category : #'Chronology-Core'
}

{ #category : #'squeak protocol' }
Timespan class >> current [
	^ self starting: (DateAndTime now offset: self defaultOffset)
]

{ #category : #configuring }
Timespan class >> defaultOffset [
	"Timespans created in the context of an offset will start in that offset.  When no context is available, the defaultOffset for Timespans must be zero.  For example, two ways to make a Date for today:
	Date today.  'start is midnight at offset zero.  Will compare successfully to other Date today results.'
	DateAndTime now asDate.  'In this case, the start is midnight of the local time-zone.  It can only compare equally to Dates of its time-zone.'"
	^ Duration zero
]

{ #category : #'squeak protocol' }
Timespan class >> new [
	"Answer a Timespan starting on the Squeak epoch: 1 January 1901"
	^ self starting: (DateAndTime new offset: self defaultOffset)
]

{ #category : #'squeak protocol' }
Timespan class >> starting: aDateAndTime [


	^ self starting: aDateAndTime duration: Duration zero
]

{ #category : #'squeak protocol' }
Timespan class >> starting: aDateAndTime duration: aDuration [

	^ self basicNew
 		start: aDateAndTime asDateAndTime;
		duration: aDuration;
		yourself
]

{ #category : #'squeak protocol' }
Timespan class >> starting: startDateAndTime ending: endDateAndTime [

	^ self 
		starting: startDateAndTime 
		duration: (endDateAndTime asDateAndTime - startDateAndTime)

]

{ #category : #'ansi protocol' }
Timespan >> + operand [
	"operand conforms to protocol Duration"
	

	^ self class starting: (self start + operand) duration: self duration
]

{ #category : #'ansi protocol' }
Timespan >> - operand [
	"operand conforms to protocol DateAndTime or protocol Duration"

	^ (operand respondsTo: #asDateAndTime)

	 	ifTrue: [ self start - operand ]
	
	ifFalse: [ self + (operand negated) ]

]

{ #category : #'ansi protocol' }
Timespan >> < comparand [

	^ self start < comparand
]

{ #category : #'ansi protocol' }
Timespan >> = comparand [
	^ self class = comparand class 
		and: [ self start = comparand start
		and: [ self duration = comparand duration ] ]
.
]

{ #category : #'squeak protocol' }
Timespan >> asDate [


	^ start asDate
]

{ #category : #'squeak protocol' }
Timespan >> asDateAndTime [

	^ start
]

{ #category : #'squeak protocol' }
Timespan >> asDuration [

	^ self duration
]

{ #category : #'squeak protocol' }
Timespan >> asMonth [


	^ start asMonth
]

{ #category : #'squeak protocol' }
Timespan >> asTime [

	^ start asTime
]

{ #category : #'squeak protocol' }
Timespan >> asTimeStamp [

	^ start asTimeStamp
]

{ #category : #'squeak protocol' }
Timespan >> asWeek [

	^ start asWeek
]

{ #category : #'squeak protocol' }
Timespan >> asYear [


	^ start asYear

]

{ #category : #'squeak protocol' }
Timespan >> beCanonical [
	"Chronology preserves Timespans that are extracted from DateAndTime's, making Dates, Months and Years in Squeak able to represent a true Timespan of those durations starting at a specific local DateAndTime.  In case a canonical version is needed, make the receiver independent of any Timezone by removing it."
	start makeUTC
]

{ #category : #enumerating }
Timespan >> dates [


	| dates |

	dates := OrderedCollection new.
	self datesDo: [ :m | dates add: m ].
	^ dates asArray
]

{ #category : #enumerating }
Timespan >> datesDo: aBlock [


	self do: aBlock with: start asDate

]

{ #category : #'smalltalk-80' }
Timespan >> day [
	"Answer the day of the year represented by the receiver."
	^ self dayOfYear
]

{ #category : #'ansi protocol' }
Timespan >> dayOfLocalWeek [
	"Answer the day of the week represented by the receiver."

	^ start dayOfLocalWeek
]

{ #category : #'ansi protocol' }
Timespan >> dayOfMonth [
	"Answer the day of the month represented by the receiver."

	^ start dayOfMonth
]

{ #category : #'ansi protocol' }
Timespan >> dayOfWeek [
	"Answer the day of the week represented by the receiver."

	^ start dayOfWeek
]

{ #category : #'ansi protocol' }
Timespan >> dayOfWeekName [
	"Answer the day of the week represented by the receiver."

	^ start dayOfWeekName
]

{ #category : #'ansi protocol' }
Timespan >> dayOfYear [
	"Answer the day of the year represented by the receiver."

	^ start dayOfYear
]

{ #category : #'smalltalk-80' }
Timespan >> daysInMonth [


	^ start daysInMonth
]

{ #category : #'smalltalk-80' }
Timespan >> daysInYear [
	"Answer the number of days in the month represented by the receiver."

	^ start daysInYear
]

{ #category : #'smalltalk-80' }
Timespan >> daysLeftInYear [
	^ start daysLeftInYear
]

{ #category : #private }
Timespan >> do: aBlock with: aFirstElement [

	self do: aBlock with: aFirstElement when: [ :t | true ]

]

{ #category : #private }
Timespan >> do: aBlock with: aFirstElement when: aConditionBlock [

	| element end |
	element := aFirstElement.
	end := self end.
	[ element start <= end ] whileTrue:
	
	[(aConditionBlock value: element)
			ifTrue: [ aBlock value: element ].
		element := element next. ]

]

{ #category : #'squeak protocol' }
Timespan >> duration [
	"Answer the Duration of this timespan"

	^ duration
]

{ #category : #private }
Timespan >> duration: aDuration [
	"Set the Duration of this timespan"

	duration := aDuration
]

{ #category : #'squeak protocol' }
Timespan >> end [


	^ self duration asNanoSeconds = 0
		ifTrue: [ self start ]
		ifFalse: [ self next start - DateAndTime clockPrecision ]

]

{ #category : #enumerating }
Timespan >> every: aDuration do: aBlock [

	| element end |
	element := self start.
	end := self end.
	[ element <= end ] whileTrue:
	
	[ aBlock value: element.
		element := element + aDuration. ]
]

{ #category : #'smalltalk-80' }
Timespan >> firstDayOfMonth [

	^ start firstDayOfMonth
]

{ #category : #'ansi protocol' }
Timespan >> hash [

	^ start hash + duration hash
]

{ #category : #'squeak protocol' }
Timespan >> includes: aDateAndTime [


	^ (aDateAndTime isKindOf: Timespan)
			ifTrue: [ (self includes: aDateAndTime start)
						and: [ self includes: aDateAndTime end ] ]
			ifFalse: [ aDateAndTime asDateAndTime between: start and: self end ]
]

{ #category : #'squeak protocol' }
Timespan >> includesAllOf: aCollection [ 
	"Answer whether all the elements of aCollection are in the receiver."

	aCollection do: [:elem | (self includes: elem) ifFalse: [^ false]].
	^ true

]

{ #category : #'squeak protocol' }
Timespan >> includesAnyOf: aCollection [ 
	"Answer whether any element of aCollection is included in the receiver"

	aCollection do: [ :elem | (self includes: elem) ifTrue: [^ true]].
	^false

]

{ #category : #'squeak protocol' }
Timespan >> intersection: aTimespan [

	 "Return the Timespan both have in common, or nil"

	 | aBegin anEnd |
	 aBegin := self start max: aTimespan start.
	 anEnd := self end min: aTimespan end.
	 anEnd < aBegin ifTrue: [^nil].

	 ^ self class starting: aBegin ending: anEnd

]

{ #category : #'ansi protocol' }
Timespan >> isLeapYear [

	^ start isLeapYear
]

{ #category : #'squeak protocol' }
Timespan >> julianDayNumber [


	^ start julianDayNumber
]

{ #category : #'squeak protocol' }
Timespan >> makeUTC [
	"Change the receiver's timezone to UTC, which affords substantially better hashing performance."
	start makeUTC
]

{ #category : #'ansi protocol' }
Timespan >> month [

	^ start month
]

{ #category : #'ansi protocol' }
Timespan >> monthAbbreviation [


	^ start monthAbbreviation
]

{ #category : #'smalltalk-80' }
Timespan >> monthIndex [

	^ self month
]

{ #category : #'ansi protocol' }
Timespan >> monthName [


	^ start monthName
]

{ #category : #enumerating }
Timespan >> months [

	| months |
	months := OrderedCollection new: 12.
	self monthsDo: [ :m | months add: m ].
	^ months asArray.

]

{ #category : #enumerating }
Timespan >> monthsDo: aBlock [

	self do: aBlock with: start asMonth
]

{ #category : #'smalltalk-80' }
Timespan >> next [

	^ self class starting: (start + duration) duration: duration
]

{ #category : #'smalltalk-80' }
Timespan >> previous [


	^ self class starting: (start - duration) duration: duration
]

{ #category : #'squeak protocol' }
Timespan >> printOn: aStream [


	super printOn: aStream.
	aStream 
		nextPut: $(;
		print: start;
		nextPut: $D;
		print: duration;
		nextPut: $)

]

{ #category : #'squeak protocol' }
Timespan >> start [
	"Answer the start DateAndTime of this timespan"

	^ start
]

{ #category : #'squeak protocol' }
Timespan >> start: aDateAndTime [
	"Store the start DateAndTime of this timespan"

	start := aDateAndTime asDateAndTime
]

{ #category : #'squeak protocol' }
Timespan >> to: anEnd [
	"Answer an Timespan. anEnd must be aDateAndTime or a Timespan"


	^ Timespan starting: (self start) ending: (anEnd asDateAndTime)

]

{ #category : #'squeak protocol' }
Timespan >> union: aTimespan [
	 "Return the Timespan spanned by both"

	| aBegin anEnd |

	aBegin := self start min: aTimespan start.
	anEnd := self end max: aTimespan end.
	^ Timespan starting: aBegin ending: (anEnd + DateAndTime clockPrecision)

]

{ #category : #enumerating }
Timespan >> weeks [


	| weeks |
	weeks := OrderedCollection new.
	self weeksDo: [ :m | weeks add: m ].
	^ weeks asArray
]

{ #category : #enumerating }
Timespan >> weeksDo: aBlock [

	self do: aBlock with: self asWeek.
]

{ #category : #enumerating }
Timespan >> workDatesDo: aBlock [
	"Exclude Saturday and Sunday"

	self do: aBlock with: start asDate when: [ :d | d dayOfWeek < 6 ]

]

{ #category : #'ansi protocol' }
Timespan >> year [


	^ start year
]

{ #category : #enumerating }
Timespan >> years [


	| years |
	years := OrderedCollection new.
	self yearsDo: [ :m | years add: m ].
	^ years asArray
]

{ #category : #enumerating }
Timespan >> yearsDo: aBlock [

	self do: aBlock with: start asYear.
]
