"
An implementation of a shared queue based on class Monitor.  Clients may may place items on the queue using nextPut: or remove them using methods like next or nextOrNil.  Items are removed in first-in first-out (FIFO) order.  It is safe for multiple threads to access the same shared queue, which is why this is a ""shared"" queue.

[monitor] is used to synchronize access from multiple threads.

[items] is an ordered collection holding the items that are in the queue.  New items are added  at the end, and old items are removed from the beginning.

All methods must hold the monitor while they run.

"
Class {
	#name : #SharedQueue2,
	#superclass : #Stream,
	#instVars : [
		'monitor',
		'items'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #'instance creation' }
SharedQueue2 class >> new [
	^self basicNew initialize
]

{ #category : #accessing }
SharedQueue2 >> flush [
	self deprecated: 'use removeAll'.
	^self removeAll
]

{ #category : #accessing }
SharedQueue2 >> flushAllSuchThat: aBlock [
	self deprecated: 'use removeAllSuchThat:'.

	^self removeAllSuchThat: aBlock
]

{ #category : #initializing }
SharedQueue2 >> initialize [
	monitor := Monitor new.
	items := OrderedCollection new.

]

{ #category : #size }
SharedQueue2 >> isEmpty [
	^monitor critical: [ items isEmpty ]
]

{ #category : #accessing }
SharedQueue2 >> next [

	^monitor critical: [
		monitor waitWhile: [ items isEmpty ].
		items removeFirst ]

]

{ #category : #accessing }
SharedQueue2 >> nextOrNil [
	^monitor critical: [
		items isEmpty ifTrue: [ nil ] ifFalse: [ items removeFirst ] ]
]

{ #category : #accessing }
SharedQueue2 >> nextOrNilSuchThat: aBlock [
	"Answer the next object that satisfies aBlock, skipping any intermediate objects.
	If no such object has been queued, answer <nil> and leave me intact."

	^monitor critical: [
		| index |
		index := items findFirst: aBlock.
		index = 0 ifTrue: [
			nil ]
		ifFalse: [
			items removeAt: index ] ].

]

{ #category : #accessing }
SharedQueue2 >> nextPut: item [

	monitor critical: [
		items addLast: item.
		monitor signal.  ].
	^item
]

{ #category : #accessing }
SharedQueue2 >> peek [
	"Answer the object that was sent through the receiver first and has not 
	yet been received by anyone but do not remove it from the receiver. If 
	no object has been sent, return nil"
	^monitor critical: [
		items isEmpty ifTrue: [ nil ] ifFalse: [ items first ] ]

]

{ #category : #accessing }
SharedQueue2 >> peekLast [
	"Answer the object that was sent through the receiver last and has not 
	 yet been received by anyone. If  no object has been sent, answer nil"

	"SharedQueue2 new nextPut: 1; nextPut: 2; peekLast"
	^monitor critical:
		[items isEmpty ifFalse:
			[items last]]
]

{ #category : #copying }
SharedQueue2 >> postCopy [
	super postCopy.
	monitor critical:
		[items := items copy.
		monitor := Monitor new]
]

{ #category : #printing }
SharedQueue2 >> printOn: aStream [
	monitor critical: [
		aStream 
			nextPutAll: self class name;
			nextPutAll: ' with ';
			print: items size;
		 	nextPutAll: ' items' ].
]

{ #category : #accessing }
SharedQueue2 >> removeAll [
	monitor critical: [
		items removeAll ].
]

{ #category : #accessing }
SharedQueue2 >> removeAllSuchThat: aBlock [
	"Remove from the queue all objects that satisfy aBlock."
	monitor critical: [
		items removeAllSuchThat: aBlock ]
]

{ #category : #size }
SharedQueue2 >> size [
	^monitor critical: [ items size ]
]
