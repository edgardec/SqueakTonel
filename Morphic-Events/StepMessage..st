Class {
	#name : #StepMessage,
	#superclass : #MorphicAlarm,
	#instVars : [
		'stepTime'
	],
	#category : #'Morphic-Events'
}

{ #category : #'instance creation' }
StepMessage class >> scheduledAt: scheduledTime stepTime: stepTime receiver: aTarget selector: aSelector arguments: argArray [
	^(self receiver: aTarget selector: aSelector arguments: argArray)
		scheduledTime: scheduledTime;
		stepTime: stepTime
]

{ #category : #printing }
StepMessage >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPut: $(;
		print: receiver;
		space;
		print: selector;
		space;
		print: scheduledTime;
		nextPut: $).
]

{ #category : #'stepping and presenter' }
StepMessage >> stepTime [
	"Return the step time for this message. If nil, the receiver of the message will be asked for its #stepTime."
	^stepTime
]

{ #category : #accessing }
StepMessage >> stepTime: aNumber [
	"Set the step time for this message. If nil, the receiver of the message will be asked for its #stepTime."
	stepTime := aNumber
]
