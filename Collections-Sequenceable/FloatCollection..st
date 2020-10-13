"
FloatCollctions store 32bit IEEE floating point numbers.
"
Class {
	#name : #FloatCollection,
	#superclass : #NonPointersOrderedCollection,
	#category : #'Collections-Sequenceable'
}

{ #category : #private }
FloatCollection >> arrayType [
	^ Float32Array
]

{ #category : #converting }
FloatCollection >> asFloat32Array [
	"Optimized version"

	^array copyFrom: firstIndex to: lastIndex
]
