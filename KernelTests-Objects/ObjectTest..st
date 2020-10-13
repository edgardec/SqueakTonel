Class {
	#name : #ObjectTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #private }
ObjectTest >> a [
	self b.
]

{ #category : #private }
ObjectTest >> a1 [
	self b1.
]

{ #category : #private }
ObjectTest >> b [
	self haltIf: #testHaltIf.
]

{ #category : #private }
ObjectTest >> b1 [
	self haltIf: #testasdasdfHaltIf.
]

{ #category : #'tests - debugging' }
ObjectTest >> testAssert [
	Object assert: [true].
	Object assert: true.
	self should: [Object assert: [false]] raise: AssertionFailure.
	self should: [Object assert: false] raise: AssertionFailure.
]

{ #category : #tests }
ObjectTest >> testBecome [
	"self debug: #testBecome"
	"this test should that all the variables pointing to an object are pointing now to another one, and all
      object pointing to the other are pointing to the object"

	| pt1 pt2 pt3 |
	pt1 := 0@0.
	pt2 := pt1.
	pt3 := 100@100.

	pt1 become: pt3.
	self assert: pt2 = (100@100).
	self assert: pt3 = (0@0).
	self assert: pt1 = (100@100).
]

{ #category : #tests }
ObjectTest >> testBecomeForward [
	"self debug: #testBecomeForward"
	"this test should that all the variables pointing to an object are pointing now to another one.
	Not that this inverse is not true. This kind of become is called oneWayBecome in VW"

	| pt1 pt2 pt3 |
	pt1 := 0@0.
	pt2 := pt1.
	pt3 := 100@100.
	pt1 becomeForward: pt3.
	self assert: pt2 = (100@100).
	self assert: pt3 == pt2.
	self assert: pt1 = (100@100)
]

{ #category : #tests }
ObjectTest >> testCopyDependents [

	| bar foo |
	foo := Object new.
	foo addDependent: 42.
	self assert: {42} equals: foo dependents asArray.
	
	bar := foo copy.
	self assert: bar dependents isEmpty.
]

{ #category : #'tests - testing' }
ObjectTest >> testHaltIf [

	self should: [self haltIf: true] raise: Halt.
	self haltIf: false.

	self should: [self haltIf: [true]] raise: Halt.
	self haltIf: [false].

	self should: [self haltIf: #testHaltIf.] raise: Halt.
	self haltIf: #teadfasdfltIf.

	self should: [self a] raise: Halt.
	self a1.

	self should: [self haltIf: [:o | o class = self class]] raise: Halt.
	self haltIf: [:o | o class ~= self class].

]

{ #category : #'tests - testing' }
ObjectTest >> testNotNil [

	self assert: Object new notNil
]

{ #category : #tests }
ObjectTest >> testPerform [

	| object |
	object := Object new.
	self assert: object equals: (object perform: #yourself).
	self deny: 1 equals: (object perform: #yourself).
	self assert: 4 equals: (2 perform: #squared).
	self deny: 3 equals: (2 perform: #squared)
]

{ #category : #tests }
ObjectTest >> testPerformWith [

	self assert: 7 equals: (3 perform: #+ with: 4)
]

{ #category : #tests }
ObjectTest >> testPerformWithWith [

	| receiver |
	receiver := [ :a :b | { a. b } ].
	self assert: #(1 2) equals: (receiver perform: #value:value: with: 1 with: 2)
]

{ #category : #tests }
ObjectTest >> testPerformWithWithWith [

	| receiver |
	receiver := [ :a :b :c | { a. b. c } ].
	self assert: #(1 2 3) equals: (receiver perform: #value:value:value: with: 1 with: 2 with: 3)
]

{ #category : #tests }
ObjectTest >> testPerformWithWithWithWith [

	| receiver |
	receiver := [ :a :b :c :d | { a. b. c. d } ].
	self assert: #(1 2 3 4) equals: (receiver perform: #value:value:value:value: with: 1 with: 2 with: 3 with: 4)
]

{ #category : #tests }
ObjectTest >> testPerformWithWithWithWithWith [

	| receiver |
	receiver := [ :a :b :c :d :e | { a. b. c. d. e } ].
	self assert: #(1 2 3 4 5) equals: (receiver perform: #value:value:value:value:value: with: 1 with: 2 with: 3 with: 4 with: 5)
]

{ #category : #tests }
ObjectTest >> testPinning [
	"Test pinning state changes for two objects. Iterate over all possible state transitions."

	| objects |
	objects := { Object new. Object new }.
	#((false false) (false true) (true false) (true true))
		combinations: 2
		atATimeDo: [ :transition |
			 | fromState toState |
			fromState := transition first.
			toState := transition second.
			fromState with: objects do: [ :pinned :object |
				pinned 
					ifTrue: [ object pin ]
					ifFalse: [ object unpin ].
				self assert: pinned equals: object isPinned ].
			objects withIndexDo: [ :object :index |
				| from to |
				from := fromState at: index.
				to := toState at: index.
				self assert: from equals: (to
					ifTrue: [ object pin ]
					ifFalse: [ object unpin ]).
				self assert: to equals: object isPinned ] ]
]

{ #category : #tests }
ObjectTest >> testShouldBeImplemented [
	| testClass |
	testClass := NotImplementedTestData.
	self should: [testClass new shouldBeImplementedMsg] raise: NotImplemented.
	[testClass new shouldBeImplementedMsg] ifError: [:errDesc |
		self assert: (errDesc includesSubstring: testClass name) description: 'Error should include class name'.
		self assert: (errDesc includesSubstring: #shouldBeImplementedMsg asString) description: 'Error should include selector name'].
]

{ #category : #tests }
ObjectTest >> testShouldNotImplement [
	| testClass |
	testClass := NotImplementedTestData.
	self should: [testClass new shouldNotImplementMsg] raise: NotImplemented.
	[testClass new shouldNotImplementMsg] ifError: [:errDesc |
		self assert: (errDesc includesSubstring: testClass name) description: 'Error should include class name'.
		self assert: (errDesc includesSubstring: #shouldNotImplementMsg asString) description: 'Error should include selector name'].
]
