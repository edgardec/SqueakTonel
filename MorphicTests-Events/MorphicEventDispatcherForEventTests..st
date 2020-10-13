Class {
	#name : #MorphicEventDispatcherForEventTests,
	#superclass : #MorphicEventDispatcher,
	#instVars : [
		'eventsSeen',
		'morphsSeen'
	],
	#category : #'MorphicTests-Events'
}

{ #category : #dispatching }
MorphicEventDispatcherForEventTests >> dispatchEvent: anEvent with: aMorph [

	self eventsSeen add: anEvent copy.
	self morphsSeen add: aMorph.
	^ super dispatchEvent: anEvent with: aMorph
]

{ #category : #accessing }
MorphicEventDispatcherForEventTests >> eventsSeen [

	^ eventsSeen ifNil: [eventsSeen := OrderedCollection new]
]

{ #category : #accessing }
MorphicEventDispatcherForEventTests >> morphsSeen [

	^ morphsSeen ifNil: [morphsSeen := OrderedCollection new]
]
