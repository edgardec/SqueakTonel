"
A Float64Array store double precision IEEE 754 (64 bits) floating point numbers.
"
Class {
	#name : #Float64Array,
	#superclass : #FloatArray,
	#type : #longs,
	#category : #'Collections-Arrayed'
}

{ #category : #'instance creation' }
Float64Array class >> fromFloatArray: aFloatArray [
	^(self new: aFloatArray) copyFromFloatArray: aFloatArray
]

{ #category : #comparing }
Float64Array >> = aFloat64Array [ 
	<primitive: 'primitiveEqual' module: 'Float64ArrayPlugin'>
	^super = aFloat64Array
]

{ #category : #converting }
Float64Array >> asFloat32Array [
	^Float32Array fromFloat64Array: self
]

{ #category : #converting }
Float64Array >> asFloat64Array [
	^self
]

{ #category : #accessing }
Float64Array >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 8
]

{ #category : #'initialize-release' }
Float64Array >> copyFromFloatArray: aFloatArray [
	"Destructively replace the elements of self with those of aFloatArray"
	<primitive: 'primitiveFromFloatArray' module: 'Float64ArrayPlugin'>
	self isOfSameSizeCheck: aFloatArray.
	1 to: self size do:[:i| self at: i put: (aFloatArray at: i)].
]

{ #category : #arithmetic }
Float64Array >> dot: aFloatVector [
	"Primitive. Return the dot product of the receiver and the argument.
	Fail if the argument is not of the same size as the receiver."

	| result |
	<primitive: 'primitiveDotProduct' module: 'Float64ArrayPlugin'>
	self size = aFloatVector size ifFalse:[^self error:'Must be equal size'].
	result := 0.0.
	1 to: self size do:[:i|
		result := result + ((self at: i) * (aFloatVector at: i)).
	].
	^result
]

{ #category : #comparing }
Float64Array >> hash [
	| result |
	<primitive:'primitiveHashArray' module: 'Float64ArrayPlugin'>
	result := 0.
	1 to: self size do:[:i| result := result + (self basicAt: i) ].
	^result bitAnd: 16r1FFFFFFF
]

{ #category : #arithmetic }
Float64Array >> normalize [
	"Unsafely normalize the receiver in-place (become a unit vector).
 	 Div-by-Zero raised if len 0."
	<primitive: 'primitiveNormalize' module: 'Float64ArrayPlugin'>
	self /= self length.
]

{ #category : #'primitives-plugin' }
Float64Array >> primAddArray: floatArray [

	<primitive: 'primitiveAddFloat64Array' module: 'Float64ArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) + (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float64Array >> primAddScalar: scalarValue [

	<primitive: 'primitiveAddScalar' module: 'Float64ArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) + scalarValue].
]

{ #category : #'primitives-plugin' }
Float64Array >> primDivArray: floatArray [

	<primitive: 'primitiveDivFloat64Array' module: 'Float64ArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) / (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float64Array >> primDivScalar: scalarValue [

	<primitive: 'primitiveDivScalar' module: 'Float64ArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) / scalarValue].
]

{ #category : #'primitives-plugin' }
Float64Array >> primMulArray: floatArray [

	<primitive: 'primitiveMulFloat64Array' module: 'Float64ArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) * (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float64Array >> primMulScalar: scalarValue [

	<primitive: 'primitiveMulScalar' module: 'Float64ArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) * scalarValue].
]

{ #category : #'primitives-plugin' }
Float64Array >> primSubArray: floatArray [

	<primitive: 'primitiveSubFloat64Array' module: 'Float64ArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) - (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float64Array >> primSubScalar: scalarValue [

	<primitive: 'primitiveSubScalar' module: 'Float64ArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) - scalarValue].
]

{ #category : #'primitives-plugin' }
Float64Array >> sum [

	<primitive: 'primitiveSum' module: 'Float64ArrayPlugin'>
	^ super sum
]
