Class {
	#name : #WordArrayTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #tests }
WordArrayTest >> testAtOutOfBounds [
	"self debug: #testAtOutOfBounds"
	"Do the test more than once to make sure the jitted code is tested."
	1 to: 5 do:
		[:iteration|
		 self 
			should: [(WordArray with: 0) at: 2]
			raise: Error.
		 self 
			should: [(WordArray with: 0) at: -1]
			raise: Error]
]

{ #category : #tests }
WordArrayTest >> testAtPutOutOfBounds [
	"self debug: #testAtPutOutOfBounds"
	"Do the test more than once to make sure the jitted code is tested."
	1 to: 5 do:
		[:iteration|
		 self 
			should: [(WordArray with: 0) at: 2 put: 1]
			raise: Error.
		 self 
			should: [(WordArray with: 0) at: -1 put: 1]
			raise: Error]
]

{ #category : #tests }
WordArrayTest >> testByteSize [
	self assert: (WordArray new: 1) byteSize = 4 "4 bytes are 32 bits"
]

{ #category : #tests }
WordArrayTest >> testCannotPutNegativeValue [
	self should: [WordArray with: -1] raise: Error
]

{ #category : #tests }
WordArrayTest >> testCannotPutTooLargeValue [
	| maxValue |
	maxValue := 1 << 32 - 1.
	self assert: (WordArray with: maxValue) first = maxValue.
	self should: [WordArray with: maxValue + 1] raise: Error
]

{ #category : #tests }
WordArrayTest >> testElementSize [
	self assert: WordArray new bytesPerElement = 4 "4 bytes are 32 bits"
]

{ #category : #tests }
WordArrayTest >> testSomeValues [
	| wArray int next |
	next := [:x | x - 3 * x sqrtFloor + 5].
	int := 0.
	wArray := WordArray new: 1.
	[int highBit < 32]
		whileTrue:
			[wArray at: 1 put: int.
			self assert: (wArray at: 1) = int.
			int := next value: int].
	self should: [wArray at: 1 put: int] raise: Error
]
