"
I represent a pair of associated objects--a key and a value. My instances can serve as entries in a dictionary.
"
Class {
	#name : #Association,
	#superclass : #LookupKey,
	#instVars : [
		'value'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
Association class >> key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of 
	the association."

	^self basicNew key: newKey value: newValue
]

{ #category : #comparing }
Association >> = anAssociation [

	^ super = anAssociation and: [value = anAssociation value]
]

{ #category : #comparing }
Association >> analogousCodeTo: anObject [
	"For MethodProperties comparison."
	^anObject isVariableBinding
	  and: [key = anObject key
	  and: [value = anObject value]]
]

{ #category : #'filter streaming' }
Association >> byteEncode: aStream [
	aStream writeAssocation:self.
]

{ #category : #comparing }
Association >> hash [
	"Hash is reimplemented because = is implemented.
	The super implementation is used to avoid hashing the value
	which can be extremely expensive."
	^super hash
]

{ #category : #testing }
Association >> isSpecialWriteBinding [
	"Return true if this variable binding is write protected, e.g., should not be accessed primitively but rather by sending #value: messages"
	^false
]

{ #category : #accessing }
Association >> key: aKey value: anObject [ 
	"Store the arguments as the variables of the receiver."

	key := aKey.
	value := anObject
]

{ #category : #printing }
Association >> printOn: aStream [
	| arrow |
	super printOn: aStream.
	"If the key is a binary selector and we don't use whitespace, we will stream (key, '->') asSymbol."
	arrow := (key isSymbol and: [key isBinary]) ifTrue: [' -> '] ifFalse: ['->'].
	aStream nextPutAll: arrow.
	value printOn: aStream
]

{ #category : #printing }
Association >> storeOn: aStream [
	| arrow |
	"Store in the format (key->value)"
	aStream nextPut: $(.
	key storeOn: aStream.
	"If the key is a binary selector and we don't use whitespace, we will stream (key, '->') asSymbol."
	arrow := (key isSymbol and: [key isBinary]) ifTrue: [' -> '] ifFalse: ['->'].
	aStream nextPutAll: arrow.
	value storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #accessing }
Association >> value [
	"Answer the value of the receiver."

	^value
]

{ #category : #accessing }
Association >> value: anObject [ 
	"Store the argument, anObject, as the value of the receiver."

	value := anObject
]
