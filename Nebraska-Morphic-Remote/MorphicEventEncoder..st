"
A filter which translates MorphEvent's into StringArray's.
"
Class {
	#name : #MorphicEventEncoder,
	#superclass : #Object,
	#instVars : [
		'connection',
		'lastEventSent'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
MorphicEventEncoder class >> on: aStringArray [
	^self basicNew connection: aStringArray
]

{ #category : #initialization }
MorphicEventEncoder >> connection: aConnection [
	connection := aConnection
]

{ #category : #'network I\/O' }
MorphicEventEncoder >> flush [
	connection flush
]

{ #category : #'network I\/O' }
MorphicEventEncoder >> processIO [
	connection processIO
]

{ #category : #'network I\/O' }
MorphicEventEncoder >> requestBufferedConnection [
	"request the opposite side to send complete screen updates rather than discrete drawing commands"
	
	connection nextPut: { 'beginBuffering' }

]

{ #category : #'network I\/O' }
MorphicEventEncoder >> sendEvent: anEvent [
	(anEvent isMouseMove and: [ anEvent = lastEventSent ]) ifTrue: [
		"save on network traffic--don't send duplicate mouse moves"
		^self ].
	lastEventSent := anEvent.
	connection nextPut: #('event'), anEvent encodedAsStringArray
]

{ #category : #'network I\/O' }
MorphicEventEncoder >> sendViewExtent: newExtent [
	"inform the opposite side that our view extent has changed"
	
	connection nextPut: { 'viewExtent'. CanvasEncoder encodePoint: newExtent }

]
