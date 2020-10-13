Class {
	#name : #MCOperationsList,
	#superclass : #Object,
	#instVars : [
		'operations'
	],
	#category : #'Monticello-Patching'
}

{ #category : #'instance creation' }
MCOperationsList class >> operations: aCollection [
	^ self basicNew initializeWithOperations: aCollection
]

{ #category : #ui }
MCOperationsList >> browse [
	(self browserClass items: operations) show
]

{ #category : #ui }
MCOperationsList >> browserClass [
	^ MCOperationsBrowser
]

{ #category : #intializing }
MCOperationsList >> initializeWithOperations: aCollection [
	operations := aCollection
]

{ #category : #querying }
MCOperationsList >> isEmpty [
	^ operations isEmpty
]

{ #category : #accessing }
MCOperationsList >> operations [
	^ operations
]
