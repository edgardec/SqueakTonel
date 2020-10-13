"
MorphicAlarmQueue is a specialized Heap.  The main change is to stamp each added MorphicAlarm with a sequence number to ensure that alarms scheduled for the same time are executed in the order that they were added.
"
Class {
	#name : #MorphicAlarmQueue,
	#superclass : #Object,
	#instVars : [
		'mutex',
		'sequenceNumber',
		'heap'
	],
	#category : #'Morphic-Events'
}

{ #category : #'class initialization' }
MorphicAlarmQueue class >> convertAllAlarms [
	"Alarms should be kept in a MorphicAlarmQueue, not a Heap."
	WorldState allSubInstancesDo: [:ws | ws convertAlarms]
]

{ #category : #'class initialization' }
MorphicAlarmQueue class >> initialize [
	self convertAllAlarms.
]

{ #category : #adding }
MorphicAlarmQueue >> add: aMorphicAlarm [

	aMorphicAlarm sequenceNumber: self nextSequenceNumber.
	^heap add: aMorphicAlarm
]

{ #category : #enumeration }
MorphicAlarmQueue >> alarmsDoSafely: aBlock [

	heap asArray do: aBlock
]

{ #category : #accessing }
MorphicAlarmQueue >> incrementScheduledTimesBy: anInteger [

	heap do: [ :each | each scheduledTime: each scheduledTime + anInteger ]
]

{ #category : #initialize }
MorphicAlarmQueue >> initialize [

	super initialize.
	mutex := Mutex new.
	sequenceNumber := 0.
	heap := Heap sortBlock: [ :alarmA :alarmB |
		alarmA scheduledTime = alarmB scheduledTime 
			ifFalse: [ alarmA scheduledTime < alarmB scheduledTime ]
			ifTrue: [
				alarmA sequenceNumber = alarmB sequenceNumber
					ifFalse: [ alarmA sequenceNumber < alarmB sequenceNumber ]
					ifTrue: [ self error: 'These alarms run at the same time' ] ] ]
]

{ #category : #accessing }
MorphicAlarmQueue >> mutex [
	
	^mutex
]

{ #category : #private }
MorphicAlarmQueue >> nextSequenceNumber [

	(sequenceNumber := sequenceNumber + 1) = 16r3FFFFFFF ifTrue: [
		"Sequence number overflow... reassign sequence numbers starting at 1."
		heap sort.
		1 to: heap size do: [ :index |
			(heap at: index) sequenceNumber: index ].
		sequenceNumber := heap size + 1 ].
	^sequenceNumber
]

{ #category : #copying }
MorphicAlarmQueue >> postCopy [

	super postCopy.
	mutex := Mutex new.
	heap := heap copy
]

{ #category : #removing }
MorphicAlarmQueue >> removeAlarmWithReceiver: receiver selector: selector [

	^heap
		detect: [ :each | each receiver == receiver and: [ each selector == selector ] ]
		ifFound: [ :found | heap remove: found ]
		ifNone: [ ]
]

{ #category : #removing }
MorphicAlarmQueue >> removeAllAlarmsBefore: nowTime [

	^Array new: 10 streamContents: [ :stream |
		[ heap notEmpty and: [ heap first scheduledTime < nowTime ] ]
			whileTrue: [ stream nextPut: heap removeFirst ] ]
]
