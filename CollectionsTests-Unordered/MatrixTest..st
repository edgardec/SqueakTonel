Class {
	#name : #MatrixTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'matrix1',
		'matrix2',
		'matrix3'
	],
	#category : #'CollectionsTests-Unordered'
}

{ #category : #running }
MatrixTest >> setUp [
	matrix1 := Matrix new: 2.
	matrix1 at:1 at:1 put: 1.
	matrix1 at:1 at:2 put: 3.
	matrix1 at:2 at:1 put: 2.
	matrix1 at:2 at:2 put: 4.
	
	matrix2 := Matrix new: 2.
	matrix2 at:1 at:1 put: 3.
	matrix2 at:1 at:2 put: 7.
	matrix2 at:2 at:1 put: 4.
	matrix2 at:2 at:2 put: 8.
]

{ #category : #'tests - accessing' }
MatrixTest >> testAtAt [
	self should:[matrix1 at: 2 at: 3] raise: Error.
	self should:[matrix1 at: 3 at: 2] raise: Error.
	self should:[matrix1 at: 3 at: 3] raise: Error.
	self should:[matrix1 at: 0 at: 1] raise: Error.
	self should:[matrix1 at: 1 at: 0] raise: Error.
	self should:[matrix1 at: 0 at: 0] raise: Error.
	
	self assert: (matrix1 at: 1 at: 1) = 1
]

{ #category : #'tests - copying' }
MatrixTest >> testCopy [

	| copyMatrix |
	
	copyMatrix := matrix1 copy.
	self assert: matrix1 = copyMatrix 
]

{ #category : #'tests - testing' }
MatrixTest >> testIncludes [
	self assert:
			((1 to: 4)
				allSatisfy: [:i | matrix1 includes: i])

]

{ #category : #'tests - arithmetic' }
MatrixTest >> testMultiply [
	
	| result |
	self	should: [matrix1	preMultiplyByMatrix: (Matrix new: 3)]raise: Error.

	result := matrix2 preMultiplyByMatrix: matrix1.
	self assert: (result at: 1 at: 1) = 15.
	self assert: (result at: 1 at: 2) = 31.
	self assert: (result at: 2 at: 1) = 22.
	self assert: (result at: 2 at: 2) = 46
]

{ #category : #'tests - accessing' }
MatrixTest >> testReplaceAll [

	matrix1 replaceAll: 1 with: 10.
	self assert: (matrix1 at:1 at:1) = 10.
	self assert: (matrix1 at:2 at:1) = 2.
	self assert: (matrix1 at:1 at:2) = 3.
	self assert: (matrix1 at:2 at:2) = 4.
]

{ #category : #'tests - accessing' }
MatrixTest >> testSwap [
	matrix1 swap: 1 at: 2 with: 1 at: 1.
	self assert: (matrix1 at: 1 at: 1) = 3.
	self assert: (matrix1 at: 1 at: 2) = 1.
]

{ #category : #'tests - accessing' }
MatrixTest >> testTransposed [
	| transposedMatrix |
	
	transposedMatrix := matrix1 transposed.
	self assert: [(transposedMatrix at:1 at:1) = 1].
	self assert: [(transposedMatrix at:1 at:2) = 2].
	self assert: [(transposedMatrix at:2 at:1) = 3].
	self assert: [(transposedMatrix at:2 at:2) = 4].
]
