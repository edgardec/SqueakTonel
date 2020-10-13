"
HalfWordArrayTest are SUnit tests for HalfWordArray.

"
Class {
	#name : #DoubleByteArrayTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #tests }
DoubleByteArrayTest >> testAllPossibleValues [
	| doubleByteArray |
	doubleByteArray := (1 to: 65535) as: DoubleByteArray.
	1 to: doubleByteArray size do: [:i |
		self assert: (doubleByteArray at: i) = i]
]

{ #category : #tests }
DoubleByteArrayTest >> testAtOutOfBounds [
	"self debug: #testAtOutOfBounds"
	"Do the test more than once to make sure the jitted code is tested."
	1 to: 5 do:
		[:iteration|
		 self 
			should: [(DoubleByteArray with: 0) at: 2]
			raise: Error.
		 self 
			should: [(DoubleByteArray with: 0) at: -1]
			raise: Error]
]

{ #category : #tests }
DoubleByteArrayTest >> testAtPutOutOfBounds [
	"self debug: #testAtPutOutOfBounds"
	"Do the test more than once to make sure the jitted code is tested."
	1 to: 5 do:
		[:iteration|
		 self 
			should: [(DoubleByteArray with: 0) at: 2 put: 1]
			raise: Error.
		 self 
			should: [(DoubleByteArray with: 0) at: -1 put: 1]
			raise: Error]
]

{ #category : #tests }
DoubleByteArrayTest >> testByteSize [
	self assert: (DoubleByteArray new: 1) byteSize = 2 "2 bytes are 16 bits"
]

{ #category : #tests }
DoubleByteArrayTest >> testCannotPutNegativeValue [
	self should: [DoubleByteArray with: -1] raise: Error
]

{ #category : #tests }
DoubleByteArrayTest >> testCannotPutTooLargeValue [
	| maxValue |
	maxValue := 1 << 16 - 1.
	self assert: (DoubleByteArray with: maxValue) first = maxValue.
	self should: [DoubleByteArray with: maxValue + 1] raise: Error
]

{ #category : #tests }
DoubleByteArrayTest >> testElementSize [
	self assert: DoubleByteArray new bytesPerElement = 2 "2 bytes are 16 bits"
]
