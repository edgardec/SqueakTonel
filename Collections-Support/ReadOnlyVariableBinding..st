Class {
	#name : #ReadOnlyVariableBinding,
	#superclass : #LookupKey,
	#instVars : [
		'value'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
ReadOnlyVariableBinding class >> key: key value: aValue [
	^self new privateSetKey: key value: aValue
]

{ #category : #accessing }
ReadOnlyVariableBinding >> canAssign [

	^ false
]

{ #category : #testing }
ReadOnlyVariableBinding >> isSpecialWriteBinding [
	"Return true if this variable binding is write protected, e.g., should not be accessed primitively but rather by sending #value: messages"
	^true
]

{ #category : #private }
ReadOnlyVariableBinding >> privateSetKey: aKey value: aValue [
	key := aKey.
	value := aValue
]

{ #category : #accessing }
ReadOnlyVariableBinding >> value [
	^value
]

{ #category : #accessing }
ReadOnlyVariableBinding >> value: aValue [
	(AttemptToWriteReadOnlyGlobal signal: 'Cannot store into read-only bindings') == true ifTrue:[
		value := aValue.
	].
]
