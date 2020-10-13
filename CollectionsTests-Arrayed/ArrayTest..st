"
This is the unit test for the class Array. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #ArrayTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'example1',
		'literalArray',
		'selfEvaluatingArray',
		'otherArray',
		'nonSEArray1',
		'nonSEarray2',
		'example2'
	],
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #'initialize-release' }
ArrayTest >> setUp [

	literalArray := #(1 true 3 #four).
	selfEvaluatingArray := { 1. true. (3/4). Color black. (2 to: 4) . 5 }.
	nonSEArray1 := { 1 . Set with: 1 }.
	nonSEarray2 := { Smalltalk globals associationAt: #Array }.
	example1 := #(1 2 3 4 5).
	example2 := {1. 2. 3/4. 4. 5}. 
]

{ #category : #'tests - accessing' }
ArrayTest >> testAtWrap [
	|tabTest|
	tabTest := #(5 6 8).
	self assert:(tabTest atWrap: 2) = 6.
	self assert:(tabTest atWrap:7) = 5.
	self assert:( tabTest atWrap:5) = 6.
	self assert:(tabTest atWrap:0)= 8.
	self assert:(tabTest atWrap:1)= 5.
	self assert:(tabTest atWrap:-2) = 5.


]

{ #category : #tests }
ArrayTest >> testEmpty [

	self
		assert: 0
		equals: Array empty size
		description: 'The empty Array should be empty indeed';
		
		assert: Array
		equals: Array empty species 
		description: 'The empty Array should be an Array';
		
		assert: Array empty
		identical: Array empty 
		description: 'The empty Array should be canonical';
		
		yourself
		
		

]

{ #category : #tests }
ArrayTest >> testIsArray [
	
	self assert: example1 isArray
]

{ #category : #tests }
ArrayTest >> testIsLiteral [
	"We work with a copy of literalArray, to avoid corrupting the code."
	
	| aLiteralArray |
	aLiteralArray := literalArray copy.
	self assert: aLiteralArray isLiteral.
	aLiteralArray at: 1 put: self class.
	self deny: aLiteralArray isLiteral.
	self deny: (literalArray as: WeakArray) isLiteral description: 'instances of Array subclasses are not literal'.
]

{ #category : #tests }
ArrayTest >> testLiteralEqual [
	self
		deny: (example1 literalEqual: example1 asIntegerArray)
]

{ #category : #tests }
ArrayTest >> testLiteralStoreOn [
	"Test that a literal Array is stored and evaluated back unchanged"
	
	| anArray |
	anArray := {true. false. nil. #a. 'a'. $a. -1. 0. 1. Float pi. Float halfPi. Float halfPi negated.}.
	anArray := anArray copyWith: anArray.
	self assert: anArray isLiteral.
	self assert: (Compiler evaluate: anArray storeString) = anArray.
]

{ #category : #tests }
ArrayTest >> testNewWithSize [
	|array|
	array := Array new: 5.
	self assert: array size = 5.
	1 to: 5 do: [:index | self assert: (array at: index) isNil]
]

{ #category : #tests }
ArrayTest >> testPremultiply [
	self assert: example1 +* #(2 ) = #(2 4 6 8 10 ) 
]

{ #category : #tests }
ArrayTest >> testPrinting [
	self assert: '#(1 true 3 #four)' equals: literalArray printString.
	self
		assert: (literalArray = (Compiler evaluate: literalArray printString))
		description: 'Literal array doesn''t print as a string that when evaluated returns an equivalent Array'.
	self assert: '{1 . true . (3/4) . Color black . (2 to: 4) . 5}' equals: selfEvaluatingArray printString.
	self
		assert: (selfEvaluatingArray = (Compiler evaluate: selfEvaluatingArray printString))
		description: 'Array doesn''t print as a string that when evaluated returns an equivalent Array'.
	self assert: '{1 . a Set(1)}' equals: nonSEArray1 printString.
	self assert: '{#Array=>Array}' equals: nonSEarray2 printString.

]
