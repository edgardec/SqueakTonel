"
A DoubleByteArrays store 16-bit unsigned Integer values in the range 0 to 65535.
"
Class {
	#name : #DoubleByteArray,
	#superclass : #UnsignedIntegerArray,
	#type : #shorts,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
DoubleByteArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 2
]
