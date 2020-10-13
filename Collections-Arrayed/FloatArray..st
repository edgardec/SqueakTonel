"
FloatArray is an abstract class for representing arrays of floating point values of some given precision.
Subclasses notably provide support for IEEE 754 single precision (32bits) and double precision (64) floats.

"
Class {
	#name : #FloatArray,
	#superclass : #RawBitsArray,
	#category : #'Collections-Arrayed'
}

{ #category : #'instance creation' }
FloatArray class >> basicNew: anInteger [
	"For backward compatibility, create a 32bits FloatArray"
	
	self == FloatArray
		ifTrue: [^Float32Array basicNew: anInteger].
	^super basicNew: anInteger
]

{ #category : #arithmetic }
FloatArray >> * anObject [

	^self shallowCopy *= anObject
]

{ #category : #arithmetic }
FloatArray >> *= anObject [
	^anObject isNumber
		ifTrue:[self primMulScalar: anObject asFloat]
		ifFalse:[self primMulArray: anObject]
]

{ #category : #arithmetic }
FloatArray >> + anObject [

	^self shallowCopy += anObject
]

{ #category : #arithmetic }
FloatArray >> += anObject [
	^anObject isNumber
		ifTrue:[self primAddScalar: anObject asFloat]
		ifFalse:[self primAddArray: anObject]
]

{ #category : #arithmetic }
FloatArray >> - anObject [

	^self shallowCopy -= anObject
]

{ #category : #arithmetic }
FloatArray >> -= anObject [
	^anObject isNumber
		ifTrue:[self primSubScalar: anObject asFloat]
		ifFalse:[self primSubArray: anObject]
]

{ #category : #arithmetic }
FloatArray >> / anObject [

	^self shallowCopy /= anObject
]

{ #category : #arithmetic }
FloatArray >> /= anObject [
	^anObject isNumber
		ifTrue:[self primDivScalar: anObject asFloat]
		ifFalse:[self primDivArray: anObject]
]

{ #category : #arithmetic }
FloatArray >> \\= other [

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
FloatArray >> adaptToNumber: rcvr andSend: selector [
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
FloatArray >> asFloatArray [
	^self
]

{ #category : #accessing }
FloatArray >> at: index [
	"Answer the Float at index in the receiver.  This method converts from either a 32-bit IEEE representation,
	 or a 64-bit IEEE representation to a Squeak Float object.  Primitive. Optional."
	<primitive: 238 error: ec>
	^self bytesPerElement = 4
		ifTrue: [Float fromIEEE32Bit: (self basicAt: index)]
		ifFalse: [Float fromIEEE64Bit: (self basicAt: index)]
]

{ #category : #accessing }
FloatArray >> at: index put: value [
	"Store the Float value at index in the receiver.  This method converts from a Squeak Float object,
	 or an Integer, into either a 32-bit IEEE representation, or a 64-bit IEEE representation. Primitive. Optional."
	<primitive: 239 error: ec>
	value isFloat 
		ifTrue:[self basicAt: index put: (self bytesPerElement = 4
				ifTrue: [value asIEEE32BitWord]
				ifFalse: [value asIEEE64BitWord])]
		ifFalse: [self at: index put: value asFloat].
	^value
]

{ #category : #accessing }
FloatArray >> defaultElement [
	"Return the default element of the receiver"
	^0.0
]

{ #category : #accessing }
FloatArray >> length [
	"Return the length of the receiver"
	^self squaredLength sqrt
]

{ #category : #arithmetic }
FloatArray >> negated [

	^self shallowCopy *= -1
]

{ #category : #private }
FloatArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart
]

{ #category : #accessing }
FloatArray >> squaredLength [
	"Return the squared length of the receiver"
	^self dot: self
]
