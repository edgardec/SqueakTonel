Class {
	#name : #StopwatchTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'aStopwatch',
		'aDelay'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
StopwatchTest >> classToBeTested [

	^ Stopwatch


]

{ #category : #Coverage }
StopwatchTest >> selectorsToBeIgnored [

	| private | 
	private := #( #printOn: #state: ).

	^ super selectorsToBeIgnored, private

]

{ #category : #running }
StopwatchTest >> setUp [
	aStopwatch := Stopwatch new.
	aDelay := Delay forMilliseconds: 1.
]

{ #category : #Tests }
StopwatchTest >> testActive [

	| sw |
	sw := Stopwatch new.
	sw activate.
	
	1 seconds asDelay wait.
	self 
		assert: (sw duration >= 1 seconds).

	2 seconds asDelay wait.
	self 
		assert: (sw duration >= 3 seconds).

	sw suspend.
]

{ #category : #testing }
StopwatchTest >> testChangingStatus [
	aStopwatch activate.
	self assert: aStopwatch isActive.
	self assert: aStopwatch timespans size = 1.
	aStopwatch suspend.
	self assert: aStopwatch isSuspended.
	self assert: aStopwatch timespans size = 1.
	aStopwatch activate.
	aStopwatch reActivate.
	self assert: aStopwatch isActive.
	self assert: aStopwatch timespans size = 3.
	aStopwatch reset.
	self assert: aStopwatch isSuspended.
	self assert: aStopwatch timespans size = 0.
]

{ #category : #testing }
StopwatchTest >> testInitialStatus [
	self assert: aStopwatch isSuspended.
	self deny: aStopwatch isActive.
	self assert: aStopwatch duration = 0 seconds
]

{ #category : #testing }
StopwatchTest >> testMultipleTimings [
	aStopwatch activate.
	aDelay wait.
	aStopwatch suspend.
	aStopwatch activate.
	aDelay wait.
	aStopwatch suspend.
	self assert: aStopwatch timespans size = 2. 
	self assert: aStopwatch timespans first asDateAndTime <= 
					aStopwatch timespans last asDateAndTime.

]

{ #category : #Tests }
StopwatchTest >> testNew [

	| sw |
	sw := Stopwatch new.
	
	self 
		assert: (sw isSuspended);
		assert: (sw state = #suspended);
		deny: (sw isActive);
		assert: (sw timespans isEmpty)


]

{ #category : #testing }
StopwatchTest >> testPrintOn [
	| ref ws |
	ref := 'a Stopwatch(suspended:0:00:00:00)'.
	ws := '' writeStream.
	aStopwatch printOn: ws.
	self assert: ws contents = ref
]

{ #category : #Tests }
StopwatchTest >> testReActivate [

	| sw |
	sw := Stopwatch new.
	sw 
		activate;
		suspend;
		reActivate.
	
	self 
		assert: (sw isActive).

]

{ #category : #Tests }
StopwatchTest >> testReset [

	| sw |
	sw := Stopwatch new.
	sw activate.
	
	sw reset.
	self 
		assert: (sw isSuspended);
		assert: (sw timespans isEmpty)

]

{ #category : #testing }
StopwatchTest >> testSingleTiming [
	| timeBefore |
	timeBefore := DateAndTime now.
	aStopwatch activate.
	aDelay wait.
	aStopwatch suspend.
	self assert: aStopwatch timespans size = 1. 
	self assert: aStopwatch timespans first asDateAndTime >= timeBefore. 
	self assert: aStopwatch timespans first asDateAndTime <= aStopwatch end.

]

{ #category : #Tests }
StopwatchTest >> testStartStop [

	| sw t1 t2 t3 t4 |
	sw := Stopwatch new.
	t1 := DateAndTime now.
	(Delay forMilliseconds: 10) wait.
	sw activate; activate.
	(Delay forMilliseconds: 10) wait.
	t2 := DateAndTime now.
	
	self 
		deny: (sw isSuspended);
		assert: (sw isActive);
		assert: (sw timespans size = 1);
		assert: (t1 <= sw start);
		assert: (sw start <= t2).

	(Delay forMilliseconds: 10) wait.
	t3 := DateAndTime now.
	(Delay forMilliseconds: 10) wait.
	sw suspend; suspend.
	(Delay forMilliseconds: 10) wait.
	t4 := DateAndTime now.

	self 
		assert: (sw isSuspended);
		deny: (sw isActive);
		assert: (sw timespans size = 1);
		assert: (sw end between: t3 and: t4);
		assert: (t3 <= sw end);
		assert: (sw end <= t4).

]
