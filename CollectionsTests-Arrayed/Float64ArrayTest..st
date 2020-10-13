"
These tests are used to assert that Float64ArrayPlugin has same results as Float asIEEE32BitWord
"
Class {
	#name : #Float64ArrayTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #tests }
Float64ArrayTest >> testArithmeticCoercion [
	
	self should: [3.5 / (Float64Array with: 2.0) = (Float64Array with: 1.75)].
	self should: [3.5 * (Float64Array with: 2.0) = (Float64Array with: 7.0)].
	self should: [3.5 + (Float64Array with: 2.0) = (Float64Array with: 5.5)].
	self should: [3.5 - (Float64Array with: 2.0) = (Float64Array with: 1.5)].
]

{ #category : #tests }
Float64ArrayTest >> testFloat64ArrayPluginPrimitiveAt [
	"Trivial test"
	
	#(zero one epsilon fmax fminDenormalized fminNormalized negativeZero negativeInfinity infinity) do: [:e |
			| aFloat |
			aFloat := Float perform: e.
			self assert: ((Float64Array with: aFloat) at: 1) = aFloat].

	"Cannot compare NaN"
	self assert: ((Float64Array with: Float nan) at: 1) isNaN.
]

{ #category : #tests }
Float64ArrayTest >> testThatDivideAvoidsUnecessaryOverflow [
	| f1 f2 expectedResult |
	f1 := Float fminNormalized.
	f2 := Float fminDenormalized.
	expectedResult := Float64Array with: f1 / f2.
	
	"If any of these primitives inverse the dividend, then it will overflow"
	self assert: expectedResult equals: f1 / (Float64Array with: f2).
	self assert: expectedResult equals: (Float64Array with: f1) / f2.
	self assert: expectedResult equals: (Float64Array with: f1) / (Float64Array with: f2).
]

{ #category : #tests }
Float64ArrayTest >> testVectorOperations [
	
	"Test primtive cases 'receiver size = argument size'."
	self assert: (Float64Array withAll: {2.0. 2.0}) equals: (Float64Array withAll: {4.0. 6.0}) / (Float64Array withAll: {2.0. 3.0}).
	self assert: (Float64Array withAll: {8.0. 9.0}) equals: (Float64Array withAll: {4.0. 4.5}) * (Float64Array withAll: {2.0. 2.0}).
	self assert: (Float64Array withAll: {6.0. 9.0}) equals: (Float64Array withAll: {4.0. 6.0}) + (Float64Array withAll: {2.0. 3.0}).
	self assert: (Float64Array withAll: {2.0. 3.0}) equals: (Float64Array withAll: {4.0. 6.0}) - (Float64Array withAll: {2.0. 3.0}).
	self assert: 26 equals: ((Float64Array withAll: {4.0. 6.0}) dot: (Float64Array withAll: {2.0. 3.0})).
	
	"Test corner cases where 'receiver size < argument size'."
	self should: [(Float64Array withAll: {4.0. 6.0}) / (Float64Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0}) * (Float64Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0}) + (Float64Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0}) - (Float64Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0}) dot: (Float64Array withAll: {2.0. 3.0. 42.0})] raise: Error.
	
	"Test corner cases where 'receiver size > argument size'."
	self should: [(Float64Array withAll: {4.0. 6.0. 42.0}) / (Float64Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0. 42.0}) * (Float64Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0. 42.0}) + (Float64Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0. 42.0}) - (Float64Array withAll: {2.0. 3.0})] raise: Error.
	self should: [(Float64Array withAll: {4.0. 6.0. 42.0}) dot: (Float64Array withAll: {2.0. 3.0})] raise: Error.




]
