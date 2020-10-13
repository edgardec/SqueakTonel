Class {
	#name : #PluggableEventFilter,
	#superclass : #Object,
	#instVars : [
		'filterBlock'
	],
	#category : #'Morphic-Events'
}

{ #category : #'instance creation' }
PluggableEventFilter class >> on: filterBlock [

	^ self new filterBlock: filterBlock
]

{ #category : #accessing }
PluggableEventFilter >> filterBlock [

	^ filterBlock
]

{ #category : #accessing }
PluggableEventFilter >> filterBlock: anObject [

	filterBlock := anObject
]

{ #category : #'events-filtering' }
PluggableEventFilter >> filterEvent: event for: target [

	^ self filterBlock
		ifNil: [event]
		ifNotNil: [:b | b cull: event cull: target]
]
