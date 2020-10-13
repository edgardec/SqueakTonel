"
DoubleWordArrayTest are SUnit tests for DoubleWordArray.

"
Class {
	#name : #DoubleWordArrayTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #tests }
DoubleWordArrayTest >> testAtOutOfBounds [
	"self debug: #testAtOutOfBounds"
	"Do the test more than once to make sure the jitted code is tested."
	1 to: 5 do:
		[:iteration|
		 self 
			should: [(DoubleWordArray with: 0) at: 2]
			raise: Error.
		 self 
			should: [(DoubleWordArray with: 0) at: -1]
			raise: Error]
]

{ #category : #tests }
DoubleWordArrayTest >> testAtPutOutOfBounds [
	"self debug: #testAtPutOutOfBounds"
	"Do the test more than once to make sure the jitted code is tested."
	1 to: 5 do:
		[:iteration|
		 self 
			should: [(DoubleWordArray with: 0) at: 2 put: 1]
			raise: Error.
		 self 
			should: [(DoubleWordArray with: 0) at: -1 put: 1]
			raise: Error]
]

{ #category : #tests }
DoubleWordArrayTest >> testByteSize [
	self assert: (DoubleWordArray new: 1) byteSize = 8 "8 bytes are 64 bits"
]

{ #category : #tests }
DoubleWordArrayTest >> testCannotPutNegativeValue [
	self should: [DoubleWordArray with: -1] raise: Error
]

{ #category : #tests }
DoubleWordArrayTest >> testCannotPutTooLargeValue [
	| maxValue |
	maxValue := 1 << 64 - 1.
	self assert: (DoubleWordArray with: maxValue) first = maxValue.
	self should: [DoubleWordArray with: maxValue + 1] raise: Error
]

{ #category : #tests }
DoubleWordArrayTest >> testElementSize [
	self assert: DoubleWordArray new bytesPerElement = 8 "8 bytes are 64 bits"
]

{ #category : #tests }
DoubleWordArrayTest >> testSomeValues [
	| dwArray int next |
	next := [:x | x - 3 * x sqrtFloor + 5].
	int := 0.
	dwArray := DoubleWordArray new: 1.
	[int highBit < 64]
		whileTrue:
			[dwArray at: 1 put: int.
			self assert: (dwArray at: 1) = int.
			int := next value: int].
	self should: [dwArray at: 1 put: int] raise: Error
]
