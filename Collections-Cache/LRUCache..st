"
I'm a cache of values, given a key I return a Value from the cache or from the factory.

I use a Dictionary to find the corresponding value for the given key. I also store the key-value pairs in a circular doubly-linked list with a head element. The list is implemented by an LRUCacheHeadNode - stored in the head instance variable - and an LRUCacheNode for each key-value pair. The nodes in the list are ordered by access time. The first node (next of head) is the most recently accessed, the last one (previous of head) is the least recently accessed.
If the number of stored key-value pairs is equal to size, and a new pair needs to be stored, then I remove the least recently used pair before adding the new pair.
"
Class {
	#name : #LRUCache,
	#superclass : #Object,
	#instVars : [
		'map',
		'head',
		'calls',
		'hits',
		'size',
		'factory'
	],
	#category : #'Collections-Cache'
}

{ #category : #'instance creation' }
LRUCache class >> size: aNumber factory: aBlock [ 
	"answer an instance of the receiver"
	^ self new initializeSize: aNumber factory: aBlock
]

{ #category : #testing }
LRUCache class >> test [
	" 
	LRUCache test 
	"
	| c |
	c := LRUCache
				size: 5
				factory: [:key | key * 2].
	c at: 1.
	c at: 2.
	c at: 3.
	c at: 4.
	c at: 1.
	c at: 5.
	c at: 6.
	c at: 7.
	c at: 8.
	c at: 1.
	^ c
]

{ #category : #testing }
LRUCache class >> test2 [
	" 
	LRUCache test2.  
	Time millisecondsToRun:[LRUCache test2]. 
	MessageTally spyOn:[LRUCache test2].  
	"
	| c |
	c := LRUCache
				size: 600
				factory: [:key | key * 2].
	1
		to: 6000
		do: [:each | c at: each].
	^ c
]

{ #category : #accessing }
LRUCache >> at: aKey [ 
	"answer the object for aKey, if not present in the cache creates it"

	calls := calls + 1.
	^map
		at: aKey
		ifPresent: [ :node |
			hits := hits + 1.
			head next == node ifFalse: [
				node
					unlink;
					linkAfter: head ].
			node value ]
		ifAbsent: [
			| node |
			map size = size
				ifTrue: [ 
					node := head previous.
					node unlink.
					map removeKey: node key. ]
				ifFalse: [ node := LRUCacheNode new ].
			node linkAfter: head.
			map at: aKey put: node.
			node 
				key: aKey;
				value: (factory value: aKey);
				value ]
]

{ #category : #initialization }
LRUCache >> initializeSize: anInteger factory: aBlock [ 
	"initialize the receiver's size and factory"
	
	anInteger strictlyPositive ifFalse: [ self error: 'Size must be at least 1' ].
	size := anInteger.
	head := LRUCacheHeadNode new.
	map := PluggableDictionary integerDictionary.
	factory := aBlock.
	calls := 0.
	hits := 0
]

{ #category : #printing }
LRUCache >> printOn: aStream [ 
	"Append to the argument, aStream, a sequence of characters 
	that identifies the receiver."
	aStream nextPutAll: self class name;
		 nextPutAll: ' size:';
		 nextPutAll: size asString;
		 nextPutAll: ', calls:';
		 nextPutAll: calls asString;
		 nextPutAll: ', hits:';
		 nextPutAll: hits asString;
		 nextPutAll: ', ratio:';
		 nextPutAll: ((hits isNumber and: [calls isNumber and: [calls ~= 0]])
			ifTrue: [hits / calls]
			ifFalse: [0]) asFloat asString
]

{ #category : #initialization }
LRUCache >> reset [

	self initializeSize: size factory: factory
]
