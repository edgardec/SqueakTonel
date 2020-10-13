Class {
	#name : #Alias,
	#superclass : #Binding,
	#instVars : [
		'source'
	],
	#category : #'Environments-Core'
}

{ #category : #'instance creation' }
Alias class >> key: aSymbol source: anAssociation [
	^ self basicNew initializeWithKey: aSymbol source: anAssociation
]

{ #category : #converting }
Alias >> asBinding: aSymbol [
	^ aSymbol = source key
		ifTrue: [source]
		ifFalse: [Alias key: aSymbol source: source]
]

{ #category : #initialization }
Alias >> initializeWithKey: aSymbol source: anAssociation [
	self initialize.
	key := aSymbol.
	source := anAssociation
]

{ #category : #testing }
Alias >> isSpecialReadBinding [
	^ true
]

{ #category : #testing }
Alias >> isSpecialWriteBinding [
	^ true
]

{ #category : #literals }
Alias >> literalEqual: other [ 
	"Two aliases are equal if they have the same source"

	^ self species = other species and: [self source == other source]
]

{ #category : #accessing }
Alias >> source [
	^ source
]

{ #category : #evaluating }
Alias >> value [
	^ source value
]

{ #category : #accessing }
Alias >> value: anObject [
	source value: anObject
]
