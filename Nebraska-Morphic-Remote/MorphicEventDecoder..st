"
decode messages sent via a MorphicEventEncoder.
"
Class {
	#name : #MorphicEventDecoder,
	#superclass : #Object,
	#instVars : [
		'connection'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
MorphicEventDecoder class >> on: aStringArray [
	^self basicNew connection: aStringArray
]

{ #category : #'handling messages' }
MorphicEventDecoder >> apply: aStringArray to: aHand [
	"decode aStringArray, and apply the encoded command to aHand"

	aStringArray first = 'event' ifTrue: [
		^self applyEventMessage: aStringArray to: aHand
	].
	aStringArray first = 'viewExtent' ifTrue: [
		^self applyViewExtentMessage: aStringArray to: aHand
	].
	aStringArray first = 'beginBuffering' ifTrue: [
		^aHand convertRemoteClientToBuffered
	].

	^self error: 'unknown message type: ', aStringArray first
]

{ #category : #'handling messages' }
MorphicEventDecoder >> applyEventMessage: aStringArray to: aHand [
	| event |
	event := MorphicEvent fromStringArray: (aStringArray copyFrom: 2 to: aStringArray size).
	event ifNotNil:[aHand queueEvent: event].
]

{ #category : #'handling messages' }
MorphicEventDecoder >> applyMessagesTo: aHand [
	| msg |
	"apply all queued events to the given hand"
	"currently, there is no way to extract the rawmessages.  This is simply because I didn't feel like implementing individual classes for each message -lex"
	[ msg := connection nextOrNil.  msg notNil ] whileTrue: [
		self apply: msg to: aHand ].

]

{ #category : #'handling messages' }
MorphicEventDecoder >> applyViewExtentMessage: aStringArray to: aHand [
	| newViewExtent |
	newViewExtent := CanvasDecoder decodePoint: aStringArray second.

	aHand setViewExtent: newViewExtent
]

{ #category : #initialization }
MorphicEventDecoder >> connection: aConnection [
	connection := aConnection
]

{ #category : #'handling messages' }
MorphicEventDecoder >> processIO [
	connection processIO
]
