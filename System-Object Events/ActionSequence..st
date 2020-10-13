"
An ActionSequence is an array that lists the object's dependant objects.
"
Class {
	#name : #ActionSequence,
	#superclass : #Array,
	#type : #variable,
	#category : #'System-Object Events'
}

{ #category : #converting }
ActionSequence >> asActionSequence [

	^self
]

{ #category : #converting }
ActionSequence >> asActionSequenceTrappingErrors [

	^WeakActionSequenceTrappingErrors withAll: self
]

{ #category : #converting }
ActionSequence >> asMinimalRepresentation [

	self size = 0
		ifTrue: [^nil].
	self size = 1
		ifTrue: [^self first].
	^self
]

{ #category : #printing }
ActionSequence >> printOn: aStream [

	self size < 2 ifTrue: [^super printOn: aStream].
	aStream nextPutAll: '#('.
	self
		do: [:each | each printOn: aStream]
		separatedBy: [aStream cr].
	aStream nextPut: $)
]

{ #category : #evaluating }
ActionSequence >> value [
	"Evaluate the elements of the receiver and answer the result of last evaluation."

	^self inject: nil into:
		[:previousAnswer :each | each value]
]

{ #category : #evaluating }
ActionSequence >> valueWithArguments: anArray [
	"Evaluate the elements of the receiver with provided arguments and answer the result of last evaluation."

	^self inject: nil into:
		[:previousAnswer :each | each valueWithArguments: anArray]
]
