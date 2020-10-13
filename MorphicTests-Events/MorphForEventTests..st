Class {
	#name : #MorphForEventTests,
	#superclass : #Morph,
	#instVars : [
		'eventsDuringCapture',
		'eventsDuringBubble',
		'eventsRejected',
		'eventsFiltered',
		'handlesMouseDown',
		'keyStrokesReceived',
		'fullFocusDispatch',
		'eventDispatcher'
	],
	#category : #'MorphicTests-Events'
}

{ #category : #'events-processing' }
MorphForEventTests >> defaultEventDispatcher [

	^ self eventDispatcher ifNil: [super defaultEventDispatcher]
]

{ #category : #accessing }
MorphForEventTests >> eventDispatcher [

	^ eventDispatcher
]

{ #category : #accessing }
MorphForEventTests >> eventDispatcher: anEventDispatcher [

	eventDispatcher := anEventDispatcher.
]

{ #category : #accessing }
MorphForEventTests >> eventsDuringBubble [
	^ eventsDuringBubble ifNil: [eventsDuringBubble := OrderedCollection new]
]

{ #category : #accessing }
MorphForEventTests >> eventsDuringCapture [
	^ eventsDuringCapture ifNil: [eventsDuringCapture := OrderedCollection new]
]

{ #category : #accessing }
MorphForEventTests >> eventsFiltered [
	^ eventsFiltered ifNil: [eventsFiltered := OrderedCollection new]
]

{ #category : #accessing }
MorphForEventTests >> eventsRejected [
	^ eventsRejected ifNil: [eventsRejected := OrderedCollection new]
]

{ #category : #'event filtering' }
MorphForEventTests >> filterEvent: anEvent for: aMorphOrNil [

	self eventsFiltered add: anEvent copy -> aMorphOrNil.
	^ anEvent
]

{ #category : #accessing }
MorphForEventTests >> fullFocusDispatch [
	^ fullFocusDispatch ifNil: [false]
]

{ #category : #accessing }
MorphForEventTests >> fullFocusDispatch: aBoolean [
	fullFocusDispatch := aBoolean.
]

{ #category : #'events-processing' }
MorphForEventTests >> handleEvent: anEvent [

	self eventsDuringBubble add: anEvent copy.
	^ super handleEvent: anEvent
]

{ #category : #'event handling' }
MorphForEventTests >> handlesKeyboard: evt [
	^ true
]

{ #category : #'event handling' }
MorphForEventTests >> handlesMouseDown: evt [
	^ handlesMouseDown ifNil: [true]
]

{ #category : #'event handling' }
MorphForEventTests >> handlesMouseMove: evt [
	^ true
]

{ #category : #'event handling' }
MorphForEventTests >> handlesMouseOver: evt [
	^ true
]

{ #category : #'event handling' }
MorphForEventTests >> handlesMouseOverDragging: evt [
	^ true
]

{ #category : #'event handling' }
MorphForEventTests >> handlesMouseStillDown: evt [
	^ true
]

{ #category : #'event handling' }
MorphForEventTests >> keyStroke: evt [

	self keyStrokesReceived add: evt.
]

{ #category : #accessing }
MorphForEventTests >> keyStrokesReceived [
	^ keyStrokesReceived ifNil: [keyStrokesReceived := OrderedCollection new]
]

{ #category : #accessing }
MorphForEventTests >> noMouseDown [

	handlesMouseDown := false.
]

{ #category : #'events-processing' }
MorphForEventTests >> processEvent: anEvent using: dispatcher [

	self eventsDuringCapture add: anEvent copy.
	^ super processEvent: anEvent using: dispatcher
]

{ #category : #'events-processing' }
MorphForEventTests >> processFocusEvent: anEvent using: defaultDispatcher [

	^ self fullFocusDispatch
		ifTrue: [defaultDispatcher dispatchFocusEventFully: anEvent with: self]
		ifFalse: [defaultDispatcher dispatchFocusEvent: anEvent with: self]
	
	
	
]

{ #category : #'events-processing' }
MorphForEventTests >> rejectsEvent: anEvent [

	^ (super rejectsEvent: anEvent)
		ifTrue: [self eventsRejected add: anEvent copy. true]
		ifFalse: [false]
]
