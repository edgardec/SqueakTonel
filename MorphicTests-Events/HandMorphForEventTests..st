Class {
	#name : #HandMorphForEventTests,
	#superclass : #HandMorph,
	#instVars : [
		'eventsDuringCapture',
		'eventsDuringBubble',
		'eventsRejected',
		'eventsFiltered',
		'isHandling'
	],
	#category : #'MorphicTests-Events'
}

{ #category : #accessing }
HandMorphForEventTests >> eventsDuringBubble [
	^ eventsDuringBubble ifNil: [eventsDuringBubble := OrderedCollection new]
]

{ #category : #accessing }
HandMorphForEventTests >> eventsDuringCapture [
	^ eventsDuringCapture ifNil: [eventsDuringCapture := OrderedCollection new]
]

{ #category : #accessing }
HandMorphForEventTests >> eventsFiltered [
	^ eventsFiltered ifNil: [eventsFiltered := OrderedCollection new]
]

{ #category : #accessing }
HandMorphForEventTests >> eventsRejected [
	^ eventsRejected ifNil: [eventsRejected := OrderedCollection new]
]

{ #category : #'event filtering' }
HandMorphForEventTests >> filterEvent: anEvent for: aMorphOrNil [

	self eventsFiltered add: anEvent copy -> aMorphOrNil.
	^ anEvent
]

{ #category : #'events-processing' }
HandMorphForEventTests >> handleEvent: anEvent [

	(isHandling == true and: [(#(mouseOver mouseMove) includes: anEvent type) not]) ifTrue: [Error signal: 'Recursive handling detected!'].
	isHandling := true.
	self eventsDuringBubble add: anEvent copy.
	[^ super handleEvent: anEvent]
		ensure: [isHandling := false].
]

{ #category : #'events-processing' }
HandMorphForEventTests >> handleEventSilently: anEvent [

	^ super handleEvent: anEvent
]

{ #category : #'events-processing' }
HandMorphForEventTests >> processEvent: anEvent using: dispatcher [

	self eventsDuringCapture add: anEvent copy.
	^ super processEvent: anEvent using: dispatcher
]

{ #category : #'events-processing' }
HandMorphForEventTests >> rejectsEvent: anEvent [

	^ (super rejectsEvent: anEvent)
		ifTrue: [self eventsRejected add: anEvent copy. true]
		ifFalse: [false]
]
