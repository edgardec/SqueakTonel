Class {
	#name : #UnknownType,
	#superclass : #DataType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #initialization }
UnknownType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	vocabularyName := #unknown
]

{ #category : #queries }
UnknownType >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^ false
]
