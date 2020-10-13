"
A DoubleWordArrays store 64-bit unsigned Integer values.
"
Class {
	#name : #DoubleWordArray,
	#superclass : #UnsignedIntegerArray,
	#type : #longs,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
DoubleWordArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 8
]
