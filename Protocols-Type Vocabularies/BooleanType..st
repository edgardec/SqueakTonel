"
A data type representing Boolean values, i.e., true or false.
"
Class {
	#name : #BooleanType,
	#superclass : #DataType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #'initial value' }
BooleanType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"
	^ true
]

{ #category : #initialization }
BooleanType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #Boolean
]

{ #category : #tiles }
BooleanType >> setFormatForDisplayer: aDisplayer [
	"Set up the displayer to have the right format characteristics"

	aDisplayer useSymbolFormat.
	aDisplayer growable: true

]
