Class {
	#name : #SoundType,
	#superclass : #DataType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #'initial value' }
SoundType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ 'croak'
]

{ #category : #initialization }
SoundType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #Sound
]
