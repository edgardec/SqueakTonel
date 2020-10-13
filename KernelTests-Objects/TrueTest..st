Class {
	#name : #TrueTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #tests }
TrueTest >> testAND [

	self assert: (true & true) = true.
	self assert: (true & false) = false.
]

{ #category : #tests }
TrueTest >> testAnd [

	self assert: (true and: ['alternativeBlock']) = 'alternativeBlock'.
]

{ #category : #tests }
TrueTest >> testAsBit [

	self assert: (true asBit = 1).
]

{ #category : #tests }
TrueTest >> testIfFalse [

	self assert: (true ifFalse: ['alternativeBlock']) = nil. 
]

{ #category : #tests }
TrueTest >> testIfFalseIfTrue [

	self assert: (true ifFalse: ['falseAlternativeBlock'] 
                      ifTrue: ['trueAlternativeBlock']) = 'trueAlternativeBlock'. 
]

{ #category : #tests }
TrueTest >> testIfTrue [
	
	self assert: (true ifTrue: ['alternativeBlock']) = 'alternativeBlock'. 
]

{ #category : #tests }
TrueTest >> testIfTrueIfFalse [

	self assert: (true ifTrue: ['trueAlternativeBlock'] 
                      ifFalse: ['falseAlternativeBlock']) = 'trueAlternativeBlock'. 
]

{ #category : #tests }
TrueTest >> testInMemory [

	self assert: (true isInMemory = true).
]

{ #category : #tests }
TrueTest >> testNew [

	self should: [True new] raise: Error. 
]

{ #category : #tests }
TrueTest >> testNot [

	self assert: (true not = false).
]

{ #category : #tests }
TrueTest >> testOR [

	self assert: (true | true) = true.
	self assert: (true | false) = true.
]

{ #category : #tests }
TrueTest >> testOr [

	self assert: (true or: ['alternativeBlock']) = true.
]

{ #category : #tests }
TrueTest >> testPrintOn [

	self assert: (String streamContents: [:stream | true printOn: stream]) = 'true'. 
]

{ #category : #tests }
TrueTest >> testXor [
	self assert: (true xor: true) = false.
	self assert: (true xor: false) = true.
	self assert: (true xor: [true]) = false.
	self assert: (true xor: [false]) = true.
	"Verify that boolean with non-boolean raise errors."
	self should: [true xor: [1]] raise: Error.
	self should: [true xor: 1] raise: Error.
]
