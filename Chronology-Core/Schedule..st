"
I represent a powerful class for implementing recurring schedules.
"
Class {
	#name : #Schedule,
	#superclass : #Timespan,
	#instVars : [
		'schedule'
	],
	#category : #'Chronology-Core'
}

{ #category : #enumerating }
Schedule >> between: aStart and: anEnd do: aBlock [

	| element end i |
	end := self end min: anEnd.
	element := self start.
	
	i := 1.
	[ element < aStart ] whileTrue:
	
	[ element := element + (schedule at: i).
		i := i + 1. (i > schedule size) ifTrue: [i := 1]].
	i := 1.
	[ element <= end ] whileTrue:
	
	[ aBlock value: element.
		element := element + (schedule at: i).
		i := i + 1.
		(i > schedule size) ifTrue: [i := 1]]

]

{ #category : #enumerating }
Schedule >> dateAndTimes [

	| dateAndTimes |
	dateAndTimes := OrderedCollection new.
	self scheduleDo: [ :e | dateAndTimes add: e ].
	^ dateAndTimes asArray
]

{ #category : #'squeak protocol' }
Schedule >> includes: aDateAndTime [

	| dt |
	dt := aDateAndTime asDateAndTime.
	self scheduleDo: [ :e | e = dt ifTrue: [^true] ].
	^ false

]

{ #category : #enumerating }
Schedule >> schedule [
	^ schedule
]

{ #category : #enumerating }
Schedule >> schedule: anArrayOfDurations [

	schedule := anArrayOfDurations
]

{ #category : #enumerating }
Schedule >> scheduleDo: aBlock [

	self between: (self start) and: (self end) do: aBlock

]
