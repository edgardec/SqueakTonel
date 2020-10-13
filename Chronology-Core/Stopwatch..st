"
A Stopwatch maintains a collection of timespans.
"
Class {
	#name : #Stopwatch,
	#superclass : #Object,
	#instVars : [
		'timespans',
		'state'
	],
	#category : #'Chronology-Core'
}

{ #category : #'squeak protocol' }
Stopwatch >> activate [

	self isSuspended ifTrue:
		[self timespans add: 
			(Timespan starting: DateAndTime now duration: Duration zero).
		self state: #active]

]

{ #category : #'squeak protocol' }
Stopwatch >> duration [

	| ts last |
	self isSuspended 
		ifTrue:
			[ (ts := self timespans) isEmpty ifTrue: 
				[ ts := { Timespan starting: DateAndTime now duration: Duration zero } ] ]
		ifFalse:
			[ last := self timespans last.
			ts := self timespans allButLast
				add: (last duration: (DateAndTime now - last start); yourself);
				yourself ].
		
	^ (ts collect: [ :t | t duration ]) sum
]

{ #category : #'squeak protocol' }
Stopwatch >> end [

	^ self timespans last next


]

{ #category : #'squeak protocol' }
Stopwatch >> isActive [

	^ self state = #active

]

{ #category : #'squeak protocol' }
Stopwatch >> isSuspended [

	^ self state = #suspended


]

{ #category : #copying }
Stopwatch >> postCopy [
	super postCopy.
	timespans := timespans copy
]

{ #category : #'squeak protocol' }
Stopwatch >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self state;
		nextPut: $:;
		print: self duration;
		nextPut: $).


]

{ #category : #'squeak protocol' }
Stopwatch >> reActivate [

	self 
		suspend;
		activate.

]

{ #category : #'squeak protocol' }
Stopwatch >> reset [

	self suspend.
	timespans := nil

]

{ #category : #'squeak protocol' }
Stopwatch >> start [

	^ self timespans first start


]

{ #category : #'squeak protocol' }
Stopwatch >> state [

	^ state ifNil: [ state := #suspended ]
]

{ #category : #'squeak protocol' }
Stopwatch >> state: aSymbol [

	state := aSymbol
]

{ #category : #'squeak protocol' }
Stopwatch >> suspend [

	| ts |
	self isActive ifTrue:
		[ ts := self timespans last.
		ts duration: (DateAndTime now - ts start).
		self state: #suspended]
]

{ #category : #'squeak protocol' }
Stopwatch >> timespans [

	^ timespans ifNil: [ timespans := OrderedCollection new ]
]
