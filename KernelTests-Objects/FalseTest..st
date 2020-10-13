"
This is the unit test for the class False. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category

"
Class {
	#name : #FalseTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #tests }
FalseTest >> testAND [

	self assert: (false & true) = false.
	self assert: (false & false) = false.
]

{ #category : #tests }
FalseTest >> testAnd [

	self assert: (false and: ['alternativeBlock']) = false.
]

{ #category : #tests }
FalseTest >> testAsBit [

	self assert: (false asBit = 0).
]

{ #category : #tests }
FalseTest >> testIfFalse [
	
	self assert: ((false ifFalse: ['alternativeBlock']) = 'alternativeBlock'). 
]

{ #category : #tests }
FalseTest >> testIfFalseIfTrue [

	self assert: (false ifFalse: ['falseAlternativeBlock'] 
                      ifTrue: ['trueAlternativeBlock']) = 'falseAlternativeBlock'. 
]

{ #category : #tests }
FalseTest >> testIfTrue [

	self assert: (false ifTrue: ['alternativeBlock']) = nil. 
]

{ #category : #tests }
FalseTest >> testIfTrueIfFalse [

	self assert: (false ifTrue: ['trueAlternativeBlock'] 
                      ifFalse: ['falseAlternativeBlock']) = 'falseAlternativeBlock'. 
]

{ #category : #tests }
FalseTest >> testInMemory [

	self assert: (false isInMemory = true).
]

{ #category : #tests }
FalseTest >> testNew [

	self should: [False new] raise: TestResult error. 
]

{ #category : #tests }
FalseTest >> testNot [

	self assert: (false not = true).
]

{ #category : #tests }
FalseTest >> testOR [

	self assert: (false | true) =  true.
	self assert: (false | false) = false.
]

{ #category : #tests }
FalseTest >> testOr [

	self assert: (false or: ['alternativeBlock']) = 'alternativeBlock'.
]

{ #category : #tests }
FalseTest >> testPrintOn [

	self assert: (String streamContents: [:stream | false printOn: stream]) = 'false'. 
]

{ #category : #tests }
FalseTest >> testXor [
	self assert: (false xor: true) = true.
	self assert: (false xor: false) = false.
	self assert: (false xor: [true]) = true.
	self assert: (false xor: [false]) = false.
	"Verify that boolean with non-boolean raise errors."
	self should: [false xor: [1]] raise: Error.
	self should: [false xor: 1] raise: Error.
]
