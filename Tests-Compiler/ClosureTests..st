Class {
	#name : #ClosureTests,
	#superclass : #TestCase,
	#instVars : [
		'collection'
	],
	#category : #'Tests-Compiler'
}

{ #category : #utilities }
ClosureTests >> assertValues: anArray [
	| values |
	values := collection collect: [ :each | each value ].
	self 
		assert: anArray asArray = values asArray
		description: 'Expected: ' , anArray asArray printString , 
			', but got ' , values asArray printString
]

{ #category : #utilities }
ClosureTests >> evaluateCopyOf: aBlock [
	aBlock copy value
]

{ #category : #tests }
ClosureTests >> methodArgument: anObject [
	^ [ anObject ]
	
]

{ #category : #utilities }
ClosureTests >> methodWithNonLocalReturn [
	self evaluateCopyOf: [^ self].
	self signalFailure: 'Should never reach here'
]

{ #category : #running }
ClosureTests >> setUp [
	super setUp.
	collection := OrderedCollection new
]

{ #category : #tests }
ClosureTests >> testBlockArgument [
	| block block1 block2 |
	block := [ :arg | | temp | temp := arg. [ temp ] ].
	block1 := block value: 1.
	block2 := block value: 2.
	self assert: block1 value = 1.
	self assert: block2 value = 2
]

{ #category : #tests }
ClosureTests >> testBlockTemp [
	| block block1 block2 |
	block := [ :arg | [ arg ] ].
	block1 := block value: 1.
	block2 := block value: 2.
	self assert: block1 value = 1.
	self assert: block2 value = 2
]

{ #category : #tests }
ClosureTests >> testCopyNonLocalReturn [
	"This should not fail."
	self methodWithNonLocalReturn
]

{ #category : #tests }
ClosureTests >> testIsClean [
	| local |
	local := #testIsClean.

	self assert: [] isClean. "closes over nothing at all"
	self assert: [:a :b| a < b] isClean. "accesses only arguments"
	self assert: [:a :b| | s | s := a + b. s even] isClean. "accesses only local variables"

	self deny: [^nil] isClean. "closes over home (^-return)"
	self deny: [self] isClean. "closes over the receiver"
	self deny: [collection] isClean. "closes over the receiver (to access the inst var collection)"
	self deny: [local] isClean. "closes over local variable of outer context"
]

{ #category : #tests }
ClosureTests >> testMethodArgument [
	| temp block |
	temp := 0.
	block := [ [ temp ] ].
	temp := 1.
	block := block value.
	temp := 2.
	self assert: block value = 2
]

{ #category : #tests }
ClosureTests >> testMethodTemp [
	| block1 block2 |
	block1 := self methodArgument: 1.
	block2 := self methodArgument: 2.
	self assert: block1 value = 1.
	self assert: block2 value = 2
]

{ #category : #'tests - todo' }
ClosureTests >> testToDoArgument [
	1 to: 5 do: [ :index |
		collection add: [ index ] ].
	self assertValues: #(1 2 3 4 5)
]

{ #category : #'tests - todo' }
ClosureTests >> testToDoArgumentNotInlined [
	| block |
	block := [ :index |
		collection add: [ index ] ].
	1 to: 5 do: block.
	self assertValues: #(1 2 3 4 5)
]

{ #category : #'tests - todo' }
ClosureTests >> testToDoInsideTemp [
	1 to: 5 do: [ :index | 
		| temp | 
		temp := index. 
		collection add: [ temp ] ].
	self assertValues: #(1 2 3 4 5)
]

{ #category : #'tests - todo' }
ClosureTests >> testToDoInsideTempNotInlined [
	| block |
	block := [ :index | 
		| temp | 
		temp := index. 
		collection add: [ temp ] ].
	1 to: 5 do: block.
	self assertValues: #(1 2 3 4 5)
]

{ #category : #'tests - todo' }
ClosureTests >> testToDoOutsideTemp [
	| temp |
	1 to: 5 do: [ :index | 
		temp := index. 
		collection add: [ temp ] ].
	self assertValues: #(5 5 5 5 5)
]

{ #category : #'tests - todo' }
ClosureTests >> testToDoOutsideTempNotInlined [
	| block temp |
	block := [ :index | 
		temp := index. 
		collection add: [ temp ] ].
	1 to: 5 do: block.
	self assertValues: #(5 5 5 5 5)
]

{ #category : #'tests - while' }
ClosureTests >> testWhileModificationAfter [
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		collection add: [ index ].
		index := index + 1 ].
	self assertValues: #(5 5 5 5 5)
]

{ #category : #'tests - while' }
ClosureTests >> testWhileModificationAfterNotInlined [
	| index block |
	index := 0.
	block := [ 
		collection add: [ index ].
		index := index + 1 ].
	[ index < 5 ] whileTrue: block.
	self assertValues: #(5 5 5 5 5)
]

{ #category : #'tests - while' }
ClosureTests >> testWhileModificationBefore [
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [ 
		index := index + 1.
		collection add: [ index ] ].
	self assertValues: #(5 5 5 5 5)
]

{ #category : #'tests - while' }
ClosureTests >> testWhileModificationBeforeNotInlined [
	| index block |
	index := 0.
	block := [ 
		index := index + 1.
		collection add: [ index ] ].
	[ index < 5 ] whileTrue: block.
	self assertValues: #(5 5 5 5 5)
]

{ #category : #'tests - while' }
ClosureTests >> testWhileWithTemp [
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		temp := index := index + 1.
		collection add: [ temp ] ].
	self assertValues: #(1 2 3 4 5)
]

{ #category : #'tests - while' }
ClosureTests >> testWhileWithTempIsNil [
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		collection add: temp.
		temp := index := index + 1. 
		collection add: temp].
	self assertValues: #(nil 1 nil 2 nil 3 nil 4 nil 5)
]

{ #category : #'tests - while' }
ClosureTests >> testWhileWithTempNotInlined [
	| index block |
	index := 0.
	block := [
		| temp |
		temp := index := index + 1.
		collection add: [ temp ] ].
	[ index < 5 ] whileTrue: block.
	self assertValues: #(1 2 3 4 5)
]
