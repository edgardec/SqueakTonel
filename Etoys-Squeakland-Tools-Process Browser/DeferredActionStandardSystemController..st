"
This is a StandardSystemController that can queue up objects to be evaluated before its control loop.
"
Class {
	#name : #DeferredActionStandardSystemController,
	#superclass : #StandardSystemController,
	#instVars : [
		'queue'
	],
	#category : #'Etoys-Squeakland-Tools-Process Browser'
}

{ #category : #'as yet unclassified' }
DeferredActionStandardSystemController >> addDeferredUIMessage: valuableObject [ 
	queue nextPut: valuableObject
]

{ #category : #'as yet unclassified' }
DeferredActionStandardSystemController >> controlActivity [
	[queue isEmpty]
		whileFalse: [queue next value].
	^super controlActivity
]

{ #category : #'as yet unclassified' }
DeferredActionStandardSystemController >> initialize [
	super initialize.
	queue := SharedQueue new.
]
