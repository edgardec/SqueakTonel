Class {
	#name : #ClassBinding,
	#superclass : #Binding,
	#instVars : [
		'value'
	],
	#category : #'Environments-Core'
}

{ #category : #'instance creation' }
ClassBinding class >> key: key value: value [
	^ self basicNew initializeWithKey: key value: value
]

{ #category : #converting }
ClassBinding >> asBinding: aSymbol [
	^ aSymbol == key
		ifTrue: [self]
		ifFalse: [Alias key: aSymbol source: self]
]

{ #category : #accessing }
ClassBinding >> canAssign [
	^ false
]

{ #category : #'initialize-release' }
ClassBinding >> initializeWithKey: kObject value: vObject [
	self initialize.
	key := kObject.
	value := vObject.
]

{ #category : #testing }
ClassBinding >> isSpecialWriteBinding [
	^ true
]

{ #category : #literals }
ClassBinding >> literalEqual: other [
	"Class bindings are equal when the bind the same class"
	
	^ self species = other species and: [self value = other value]
]

{ #category : #evaluating }
ClassBinding >> value [
	^ value
]

{ #category : #accessing }
ClassBinding >> value: anObject [
	(AttemptToWriteReadOnlyGlobal signal: 'Cannot store into read-only bindings')
		ifTrue: [value := anObject]
]
