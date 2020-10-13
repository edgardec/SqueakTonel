Class {
	#name : #MorphicAlarm,
	#superclass : #MessageSend,
	#instVars : [
		'scheduledTime',
		'sequenceNumber',
		'numArgs'
	],
	#category : #'Morphic-Events'
}

{ #category : #'instance creation' }
MorphicAlarm class >> scheduledAt: scheduledTime receiver: aTarget selector: aSelector arguments: argArray [
	^(self receiver: aTarget selector: aSelector arguments: argArray)
		scheduledTime: scheduledTime.
]

{ #category : #accessing }
MorphicAlarm >> scheduledTime [
	"Return the time (in milliseconds) that the receiver is scheduled to be executed"
	^scheduledTime
]

{ #category : #accessing }
MorphicAlarm >> scheduledTime: msecs [
	"Set the time (in milliseconds) that the receiver is scheduled to be executed"
	scheduledTime := msecs
]

{ #category : #accessing }
MorphicAlarm >> sequenceNumber [
	"Answer the sequence number of the alarm, which is used to preserve ordering for alarms scheduled for the same time."
	^sequenceNumber ifNil: [0]
]

{ #category : #accessing }
MorphicAlarm >> sequenceNumber: positiveInteger [
	"Set the sequence number of the alarm, which is used to preserve ordering for alarms scheduled for the same time."
	sequenceNumber := positiveInteger
]

{ #category : #evaluating }
MorphicAlarm >> value: anArgument [
	| nArgs |
	numArgs ifNil:[numArgs := selector numArgs].
	nArgs := arguments ifNil:[0] ifNotNil:[arguments size].
	nArgs = numArgs ifTrue:[
		"Ignore extra argument"
		^self value].
	^arguments
		ifNil: [ receiver perform: selector with: anArgument]
		ifNotNil: [ receiver perform: selector withArguments: (arguments copyWith: anArgument)]
]
