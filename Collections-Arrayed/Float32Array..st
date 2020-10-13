"
A Float32Array store single precision IEEE 754 (32 bits) floating point numbers.
"
Class {
	#name : #Float32Array,
	#superclass : #FloatArray,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #'instance creation' }
Float32Array class >> fromFloat64Array: aFloat64Array [
	^(self new: aFloat64Array) copyFromFloat64Array: aFloat64Array
]

{ #category : #arithmetic }
Float32Array >> * anObject [

	^self shallowCopy *= anObject
]

{ #category : #arithmetic }
Float32Array >> *= anObject [
	^anObject isNumber
		ifTrue:[self primMulScalar: anObject asFloat]
		ifFalse:[self primMulArray: anObject]
]

{ #category : #arithmetic }
Float32Array >> + anObject [

	^self shallowCopy += anObject
]

{ #category : #arithmetic }
Float32Array >> += anObject [
	^anObject isNumber
		ifTrue:[self primAddScalar: anObject asFloat]
		ifFalse:[self primAddArray: anObject]
]

{ #category : #arithmetic }
Float32Array >> - anObject [

	^self shallowCopy -= anObject
]

{ #category : #arithmetic }
Float32Array >> -= anObject [
	^anObject isNumber
		ifTrue:[self primSubScalar: anObject asFloat]
		ifFalse:[self primSubArray: anObject]
]

{ #category : #arithmetic }
Float32Array >> / anObject [

	^self shallowCopy /= anObject
]

{ #category : #arithmetic }
Float32Array >> /= anObject [
	^anObject isNumber
		ifTrue:[self primDivScalar: anObject asFloat]
		ifFalse:[self primDivArray: anObject]
]

{ #category : #comparing }
Float32Array >> = aFloatArray [ 
	<primitive: 'primitiveEqual' module: 'FloatArrayPlugin'>
	^super = aFloatArray
]

{ #category : #arithmetic }
Float32Array >> \\= other [

	other isNumber ifTrue: [
		1 to: self size do: [:i |
			self at: i put: (self at: i) \\ other
		].
		^ self.
	].
	1 to: (self size min: other size) do: [:i |
		self at: i put: (self at: i) \\ (other at: i).
	].


]

{ #category : #arithmetic }
Float32Array >> adaptToNumber: rcvr andSend: selector [
	"If I am involved in arithmetic with a Number. If possible,
	convert it to a float and perform the (more efficient) primitive operation."
	selector == #+ ifTrue:[^self + rcvr].
	selector == #* ifTrue:[^self * rcvr].
	selector == #- ifTrue:[^self negated += rcvr].
	selector == #/ ifTrue:[
		"DO NOT USE TRIVIAL CODE
			^self reciprocal * rcvr
		BECAUSE OF GRADUAL UNDERFLOW
		self should: (1.0e-39 / (FloatArray with: 1.0e-39)) first < 2."
			^(self class new: self size withAll: rcvr) / self
		].
	^super adaptToNumber: rcvr andSend: selector
]

{ #category : #converting }
Float32Array >> asFloat32Array [
	^self
]

{ #category : #converting }
Float32Array >> asFloat64Array [
	^Float64Array fromFloatArray: self
]

{ #category : #converting }
Float32Array >> asFloatArray [
	^self
]

{ #category : #accessing }
Float32Array >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 4
]

{ #category : #'initialize-release' }
Float32Array >> copyFromFloat64Array: aFloat64Array [
	"Destructively replace the elements of self with those of aFloat64Array"
	<primitive: 'primitiveFromFloat64Array' module: 'Float64ArrayPlugin'>
	self isOfSameSizeCheck: aFloat64Array.
	1 to: self size do:[:i| self at: i put: (aFloat64Array at: i)].
]

{ #category : #arithmetic }
Float32Array >> dot: aFloatVector [
	"Primitive. Return the dot product of the receiver and the argument.
	Fail if the argument is not of the same size as the receiver."

	| result |
	<primitive: 'primitiveDotProduct' module: 'FloatArrayPlugin'>
	self size = aFloatVector size ifFalse:[^self error:'Must be equal size'].
	result := 0.0.
	1 to: self size do:[:i|
		result := result + ((self at: i) * (aFloatVector at: i)).
	].
	^result
]

{ #category : #comparing }
Float32Array >> hash [
	| result |
	<primitive:'primitiveHashArray' module: 'FloatArrayPlugin'>
	result := 0.
	1 to: self size do:[:i| result := result + (self basicAt: i) ].
	^result bitAnd: 16r1FFFFFFF
]

{ #category : #accessing }
Float32Array >> length [
	"Return the length of the receiver"
	^self squaredLength sqrt
]

{ #category : #arithmetic }
Float32Array >> negated [

	^self shallowCopy *= -1
]

{ #category : #arithmetic }
Float32Array >> normalize [
	"Unsafely normalize the receiver in-place (become a unit vector).
 	 Div-by-Zero raised if len 0."
	<primitive: 'primitiveNormalize' module: 'FloatArrayPlugin'>
	self /= self length.
]

{ #category : #'primitives-plugin' }
Float32Array >> primAddArray: floatArray [

	<primitive: 'primitiveAddFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) + (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float32Array >> primAddScalar: scalarValue [

	<primitive: 'primitiveAddScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) + scalarValue].
]

{ #category : #'primitives-plugin' }
Float32Array >> primDivArray: floatArray [

	<primitive: 'primitiveDivFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) / (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float32Array >> primDivScalar: scalarValue [

	<primitive: 'primitiveDivScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) / scalarValue].
]

{ #category : #'primitives-plugin' }
Float32Array >> primMulArray: floatArray [

	<primitive: 'primitiveMulFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) * (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float32Array >> primMulScalar: scalarValue [

	<primitive: 'primitiveMulScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) * scalarValue].
]

{ #category : #'primitives-plugin' }
Float32Array >> primSubArray: floatArray [

	<primitive: 'primitiveSubFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) - (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
Float32Array >> primSubScalar: scalarValue [

	<primitive: 'primitiveSubScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) - scalarValue].
]

{ #category : #private }
Float32Array >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart
]

{ #category : #accessing }
Float32Array >> squaredLength [
	"Return the squared length of the receiver"
	^self dot: self
]

{ #category : #'primitives-plugin' }
Float32Array >> sum [

	<primitive: 'primitiveSum' module: 'FloatArrayPlugin'>
	^ super sum
]
