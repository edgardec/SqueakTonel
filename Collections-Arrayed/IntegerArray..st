"
IntegerArrays store 32bit signed Integer values.
Negative values are stored as 2's complement.
"
Class {
	#name : #IntegerArray,
	#superclass : #SignedWordArray,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #converting }
IntegerArray >> asIntegerArray [
	^self
]
