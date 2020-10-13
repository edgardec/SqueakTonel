"
Used as part of the Nebraska system.  It is controlled by commands sent through a socket.  The encoding is interpreted via a MorphicEventDecoder.
"
Class {
	#name : #RemoteControlledHandMorph,
	#superclass : #HandMorph,
	#instVars : [
		'eventDecoder',
		'viewExtent',
		'nebraskaClient'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
RemoteControlledHandMorph class >> on: aDecoder [ 
	^self new  decoder: aDecoder
]

{ #category : #events }
RemoteControlledHandMorph >> convertRemoteClientToBuffered [

	self world convertRemoteClientToBuffered: nebraskaClient
]

{ #category : #initialization }
RemoteControlledHandMorph >> decoder: aDecoder [
	eventDecoder := aDecoder
]

{ #category : #initialization }
RemoteControlledHandMorph >> initialize [
	super initialize.
	viewExtent := 100@100.
]

{ #category : #initialization }
RemoteControlledHandMorph >> nebraskaClient: aNebraskaClient [

	nebraskaClient := aNebraskaClient
]

{ #category : #drawing }
RemoteControlledHandMorph >> needsToBeDrawn [

	^true
]

{ #category : #'event handling' }
RemoteControlledHandMorph >> processEvents [
	| |
	eventDecoder processIO.
	eventDecoder applyMessagesTo: self.

]

{ #category : #events }
RemoteControlledHandMorph >> queueEvent: anEvent [
	"add an event to be handled"

	anEvent setHand: self.
	self handleEvent: anEvent resetHandlerFields.
]

{ #category : #events }
RemoteControlledHandMorph >> setViewExtent: newExtent [
	"set the extent of this hand's view of the world"
	viewExtent := newExtent
]

{ #category : #geometry }
RemoteControlledHandMorph >> worldBounds [
	^0@0 extent: viewExtent
]
