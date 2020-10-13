Class {
	#name : #ButtonPhaseType,
	#superclass : #SymbolListType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #initialization }
ButtonPhaseType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #ButtonPhase.
	symbols := #(buttonDown whilePressed buttonUp)
]

{ #category : #queries }
ButtonPhaseType >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^true
]
