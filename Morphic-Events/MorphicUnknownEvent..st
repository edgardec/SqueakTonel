Class {
	#name : #MorphicUnknownEvent,
	#superclass : #MorphicEvent,
	#instVars : [
		'type',
		'argument'
	],
	#pools : [
		'EventSensorConstants'
	],
	#category : #'Morphic-Events'
}

{ #category : #accessing }
MorphicUnknownEvent >> argument [
	^argument
]

{ #category : #accessing }
MorphicUnknownEvent >> argument: arg [
	argument := arg
]

{ #category : #'objects from disk' }
MorphicUnknownEvent >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	type ifNil: [type := #startSound].
	source ifNil: [source := varDict at: 'sourceHand'].
	argument ifNil: [argument := varDict at: 'sound' ifAbsent: [nil]].	"???"
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #accessing }
MorphicUnknownEvent >> position [
	^0@0
]

{ #category : #private }
MorphicUnknownEvent >> setType: evtType argument: arg [
	type := evtType.
	argument := arg.
]

{ #category : #private }
MorphicUnknownEvent >> setType: evtType argument: arg hand: evtHand stamp: stamp [
	type := evtType.
	argument := arg.
	source := evtHand.
	timeStamp := stamp.
]

{ #category : #printing }
MorphicUnknownEvent >> storeOn: aStream [
	aStream nextPutAll: 'unknown'.
	aStream space.
	self timeStamp storeOn: aStream.
	aStream space.
	{type. argument} storeOn: aStream.
]

{ #category : #accessing }
MorphicUnknownEvent >> type [
	^type
]

{ #category : #initialize }
MorphicUnknownEvent >> type: eventType readFrom: aStream [
	| typeAndArg |
	timeStamp := Integer readFrom: aStream.
	aStream skip: 1.
	typeAndArg := Object readFrom: aStream.
	type := typeAndArg first.
	argument := typeAndArg last.
]
