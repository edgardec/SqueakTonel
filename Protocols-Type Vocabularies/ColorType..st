"
A data type representing a Color value.
"
Class {
	#name : #ColorType,
	#superclass : #DataType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #'initial value' }
ColorType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ Color random
]

{ #category : #initialization }
ColorType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #Color.
]
