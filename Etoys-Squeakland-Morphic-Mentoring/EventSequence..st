"
A kind of pseudo-morphic-event, created by aggregating all the events contributing to a  mouse-down/mouse-move/mouse-up sequence, or to a  sequence of all mouse-moves with no button down.    The startTime is the time stamp of the first actual event in the sequence; the stopTime is the time stamp of the last actual event in the sequence; and the #events inst var holds the actual events as obtained from the event tape.
"
Class {
	#name : #EventSequence,
	#superclass : #MorphicEvent,
	#instVars : [
		'startTime',
		'stopTime',
		'events'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #processing }
EventSequence >> addEvent: evt [
	"Add an event to my event-list."

	events add: evt
]

{ #category : #accessing }
EventSequence >> duration [
	"Answer how long the event lasts, in milliseconds.  If no stopTime has yet been established, answer zero."

	^ (stopTime ifNil: [startTime]) - startTime
]

{ #category : #accessing }
EventSequence >> durationInMilliseconds [
	"Answer the duration of the activity represented by the receiver, in milliseconds."

	^ self duration
]

{ #category : #accessing }
EventSequence >> events [
	"Answer my events."

	^ events
]

{ #category : #processing }
EventSequence >> expandOnto: aStream [
	"Place all the receiver's events onto a Stream"

	aStream nextPutAll: events
]

{ #category : #initialization }
EventSequence >> initialize [
	"Initialize the receiver."

	super initialize.
	events := OrderedCollection new
]

{ #category : #accessing }
EventSequence >> position [
	"Answer the position of the receiver."

	^ events first position
]

{ #category : #debugging }
EventSequence >> printOn: aStream [
	"Print the receiver on a stream."

	aStream nextPutAll: self class name, ': duration: ', (self duration printString), 'ms  ', events first type, ' -> ', events last type, ' total events ', (events size printString)
]

{ #category : #processing }
EventSequence >> sequenceComplete [
	"The sequence is now complete; note the stop time."

	stopTime := events last timeStamp
]

{ #category : #accessing }
EventSequence >> startTime [
	"Answer the value of startTime."

	^ startTime
]

{ #category : #accessing }
EventSequence >> startTime: anObject [
	"Set the value of startTime."

	startTime := anObject
]

{ #category : #accessing }
EventSequence >> stopTime: anObject [
	"Set the value of stopTime."

	stopTime := anObject
]

{ #category : #accessing }
EventSequence >> timeStamp [
	"Answer the timeStamp of the receiver."

	^ startTime
]
