Class {
	#name : #Global,
	#superclass : #Binding,
	#instVars : [
		'value'
	],
	#category : #'Environments-Core'
}

{ #category : #'instance creation' }
Global class >> key: aSymbol value: anObject [
	^ self basicNew initializeWithKey: aSymbol value: anObject
]

{ #category : #converting }
Global >> asBinding: aSymbol [
	^ aSymbol == key
		ifTrue: [self]
		ifFalse: [Alias key: aSymbol source: self]
]

{ #category : #'initialize-release' }
Global >> initializeWithKey: aSymbol value: anObject [
	self initialize.
	key := aSymbol.
	value := anObject
]

{ #category : #evaluating }
Global >> value [
	^ value
]

{ #category : #accessing }
Global >> value: anObject [
	value := anObject
]
