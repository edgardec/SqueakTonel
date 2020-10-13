"
These tests are used to assert that FloatArrayPlugin has same results as Float asIEEE32BitWord
"
Class {
	#name : #FloatArrayTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #tests }
FloatArrayTest >> testArithmeticCoercion [
	"This test is related to http://bugs.squeak.org/view.php?id=6782"
	
	self should: [3.0 / (Float32Array with: 2.0) = (Float32Array with: 1.5)].
	self should: [3.0 * (Float32Array with: 2.0) = (Float32Array with: 6.0)].
	self should: [3.0 + (Float32Array with: 2.0) = (Float32Array with: 5.0)].
	self should: [3.0 - (Float32Array with: 2.0) = (Float32Array with: 1.0)].
]

{ #category : #tests }
FloatArrayTest >> testFloatArrayPluginPrimitiveAt [
	"if FloatArrayPlugin primitive are not here, this test is dumb.
	Otherwise, it will compare primitive and #fromIEEE32Bit:"
	
	#(
		"regular numbers no truncation or rounding"
		2r0.0 2r1.0 2r1.1 2r1.00000000000000000000001
		2r1.0e-10 2r1.1e-10 2r1.00000000000000000000001e-10
		2r1.0e10 2r1.1e10 2r1.00000000000000000000001e10
		
		"smallest float32 before gradual underflow"
		2r1.0e-126
		
		"biggest float32"
		2r1.11111111111111111111111e127
		
		"overflow"
		2r1.11111111111111111111111e128
		
		"gradual underflow"
		2r0.11111111111111111111111e-126
		2r0.00000000000000000000001e-126
		
		"with rounding mode : tests on 25 bits"
		
		2r1.0000000000000000000000001
		2r1.0000000000000000000000010
		2r1.0000000000000000000000011
		2r1.0000000000000000000000100
		2r1.0000000000000000000000101
		2r1.0000000000000000000000110
		2r1.0000000000000000000000111
		2r1.1111111111111111111111001
		2r1.1111111111111111111111010
		2r1.1111111111111111111111011
		2r1.1111111111111111111111101
		2r1.1111111111111111111111110
		2r1.1111111111111111111111111
		
		"overflow"
		2r1.1111111111111111111111110e127
		
		"gradual underflow"
		2r0.1111111111111111111111111e-126
		2r0.1111111111111111111111110e-126
		2r0.1111111111111111111111101e-126
		2r0.1111111111111111111111011e-126
		2r0.1111111111111111111111010e-126
		2r0.1111111111111111111111001e-126
		2r0.0000000000000000000000111e-126
		2r0.0000000000000000000000110e-126
		2r0.0000000000000000000000101e-126
		2r0.0000000000000000000000011e-126
		2r0.0000000000000000000000010e-126
		2r0.0000000000000000000000001e-126
		2r0.0000000000000000000000010000000000000000000000000001e-126
		) do: [:e |
			self assert: ((Float32Array with: e) at: 1) = (Float fromIEEE32Bit: ((Float32Array with: e) basicAt: 1)).
			self assert: ((Float32Array with: e negated) at: 1) = (Float fromIEEE32Bit: ((Float32Array with: e negated) basicAt: 1))].
		
	"special cases"
	(Array with: Float infinity with: Float negativeInfinity with: Float negativeZero)
		do: [:e | self assert: ((Float32Array with: e) at: 1) = (Float fromIEEE32Bit: ((Float32Array with: e) basicAt: 1))].
		
	"Cannot compare NaN"
	(Array with: Float nan)
		do: [:e | self assert: (Float fromIEEE32Bit: ((Float32Array with: e) basicAt: 1)) isNaN].
]

{ #category : #tests }
FloatArrayTest >> testFloatArrayPluginPrimitiveAtPut [
	"if FloatArrayPlugin primitive are not here, this test is dumb.
	Otherwise, it will compare primitive and #asIEEE32BitWord"
	
	#(
		"regular numbers no truncation or rounding"
		2r0.0 2r1.0 2r1.1 2r1.00000000000000000000001
		2r1.0e-10 2r1.1e-10 2r1.00000000000000000000001e-10
		2r1.0e10 2r1.1e10 2r1.00000000000000000000001e10
		
		"smallest float32 before gradual underflow"
		2r1.0e-126
		
		"biggest float32"
		2r1.11111111111111111111111e127
		
		"overflow"
		2r1.11111111111111111111111e128
		
		"gradual underflow"
		2r0.11111111111111111111111e-126
		2r0.00000000000000000000001e-126
		
		"with rounding mode : tests on 25 bits"
		
		2r1.0000000000000000000000001
		2r1.0000000000000000000000010
		2r1.0000000000000000000000011
		2r1.0000000000000000000000100
		2r1.0000000000000000000000101
		2r1.0000000000000000000000110
		2r1.0000000000000000000000111
		2r1.1111111111111111111111001
		2r1.1111111111111111111111010
		2r1.1111111111111111111111011
		2r1.1111111111111111111111101
		2r1.1111111111111111111111110
		2r1.1111111111111111111111111
		
		"overflow"
		2r1.1111111111111111111111110e127
		
		"gradual underflow"
		2r0.1111111111111111111111111e-126
		2r0.1111111111111111111111110e-126
		2r0.1111111111111111111111101e-126
		2r0.1111111111111111111111011e-126
		2r0.1111111111111111111111010e-126
		2r0.1111111111111111111111001e-126
		2r0.0000000000000000000000111e-126
		2r0.0000000000000000000000110e-126
		2r0.0000000000000000000000101e-126
		2r0.0000000000000000000000011e-126
		2r0.0000000000000000000000010e-126
		2r0.0000000000000000000000001e-126
		2r0.0000000000000000000000010000000000000000000000000001e-126
		) do: [:e |
			self assert: ((Float32Array with: e) basicAt: 1) = e asIEEE32BitWord.
			self assert: ((Float32Array with: e negated) basicAt: 1) = e negated asIEEE32BitWord].
		
	"special cases"
	(Array with: Float infinity with: Float negativeInfinity with: Float negativeZero with: Float nan)
		do: [:e | self assert: ((Float32Array with: e) basicAt: 1) = e asIEEE32BitWord].
		
]

{ #category : #tests }
FloatArrayTest >> testThatDivideAvoidsUnecessaryOverflow [
	| f1 expectedResult |
	f1 := 1.0e-39.
	expectedResult := Float64Array with: 1.0.
	
	"If any of these primitives inverse the dividend into a float, then it will overflow.
	It will work though if using intermediate double."
	self assert: expectedResult equals: f1 / (Float64Array with: f1).
	self assert: expectedResult equals: (Float64Array with: f1) / f1.
	self assert: expectedResult equals: (Float64Array with: f1) / (Float64Array with: f1).
]

{ #category : #tests }
FloatArrayTest >> testVectorOperations [
	
	"Test primtive cases 'receiver size = argument size'."
	self assert: (Float32Array withAll: {2.0. 2.0}) equals: (Float32Array withAll: {4.0. 6.0}) / (Float32Array withAll: {2.0. 3.0}).
	self assert: (Float32Array withAll: {8.0. 9.0}) equals: (Float32Array withAll: {4.0. 4.5}) * (Float32Array withAll: {2.0. 2.0}).
	self assert: (Float32Array withAll: {6.0. 9.0}) equals: (Float32Array withAll: {4.0. 6.0}) + (Float32Array withAll: {2.0. 3.0}).
	self assert: (Float32Array withAll: {2.0. 3.0}) equals: (Float32Array withAll: {4.0. 6.0}) - (Float32Array withAll: {2.0. 3.0}).
	self assert: 26 equals: ((Float32Array withAll: {4.0. 6.0}) dot: (Float32Array withAll: {2.0. 3.0})).
	
	"Test corner cases where 'receiver size < argument size'."
	self should: [(Float32Array withAll: {4.0. 6.0}) / (Float32Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0}) * (Float32Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0}) + (Float32Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0}) - (Float32Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0}) dot: (Float32Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	
	"Test corner cases where 'receiver size > argument size'."
	self should: [(Float32Array withAll: {4.0. 6.0. 42.0}) / (Float32Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0. 42.0}) * (Float32Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0. 42.0}) + (Float32Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0. 42.0}) - (Float32Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float32Array withAll: {4.0. 6.0. 42.0}) dot: (Float32Array withAll: {2.0. 3.0})] raise: Error.




]
