"
A Vocabulary representing typed data.
"
Class {
	#name : #DataType,
	#superclass : #Vocabulary,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #'initial value' }
DataType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ 'no value'
]

{ #category : #queries }
DataType >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	"^ (self class == DataType) not"  "i.e. subclasses yes, myself no"
	"Assuming this is an abstract class"
	^true
]
