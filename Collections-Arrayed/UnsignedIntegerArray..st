"
UnsignedIntegerArray is an abstract class for all arrays of unsigned integer of fixed bit-width.


"
Class {
	#name : #UnsignedIntegerArray,
	#superclass : #RawBitsArray,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
UnsignedIntegerArray >> atAllPut: value [
	"Fill the receiver with the given value"

	<primitive: 145>
	super atAllPut: value
]

{ #category : #accessing }
UnsignedIntegerArray >> defaultElement [
	"Return the default element of the receiver"
	^0
]

{ #category : #private }
UnsignedIntegerArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	<primitive: 105>
	^super replaceFrom: start to: stop with: replacement startingAt: repStart 
]
