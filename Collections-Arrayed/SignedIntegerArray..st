"
SignedIntegerArray is an abstract class for all arrays of signed integer of fixed bit-width.
"
Class {
	#name : #SignedIntegerArray,
	#superclass : #RawBitsArray,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
SignedIntegerArray >> defaultElement [
	"Return the default element of the receiver"
	^0
]
