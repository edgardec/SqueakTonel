Class {
	#name : #AbstractSharedQueueTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #testing }
AbstractSharedQueueTest class >> isAbstract [
	^self class == thisContext methodClass
]

{ #category : #private }
AbstractSharedQueueTest >> queueClass [
	^self subclassResponsibility
]

{ #category : #tests }
AbstractSharedQueueTest >> testBasics [
	| q |
	q := self queueClass new.

	self assert: nil equals: q nextOrNil.

	q nextPut: 5.
	self assert: 5 equals: q nextOrNil.
	self assert: nil equals: q nextOrNil
]

{ #category : #tests }
AbstractSharedQueueTest >> testContention1 [
	"here is a test case that breaks the standard SharedQueue from Squeak 3.8"

	| q r1 r2 |
	q := self queueClass new.
	q nextPut: 5.
	q nextPut: 10.

	self assert: 5 equals: q nextOrNil.

	[ r1 := q next ] fork.
	[ r2 := q next ] fork.
	Processor  yield.   "let the above two threads block"
	
	q nextPut: 10.
	Processor yield.

	self assert: 10 equals: r1.
	self assert: 10 equals: r2.
	self assert: nil equals: q nextOrNil
]

{ #category : #tests }
AbstractSharedQueueTest >> testNextOrNilSuchThat [
	| q item |
	q := self queueClass new.
	q nextPut: 5.
	q nextPut: 6.

	item := q nextOrNilSuchThat: [ :x | x even ].
	self assert: 6 equals: item.

	self assert: 5 equals: q nextOrNil.
	self assert: nil equals: q nextOrNil
]

{ #category : #tests }
AbstractSharedQueueTest >> testPeeks [
	| q |
	q := self queueClass new.

	self assert: nil equals: q peek.
	self assert: nil equals: q peekLast.

	q nextPut: #first; nextPut: #last.

	self assert: #first equals: q peek.
	self assert: #last equals: q peekLast.

	self assert: #first equals: q next.

	self assert: #last equals: q peek.
	self assert: #last equals: q peekLast
]
