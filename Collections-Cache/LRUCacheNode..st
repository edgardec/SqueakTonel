Class {
	#name : #LRUCacheNode,
	#superclass : #LRUCacheHeadNode,
	#instVars : [
		'key',
		'value'
	],
	#category : #'Collections-Cache'
}

{ #category : #accessing }
LRUCacheNode >> key [

	^key
]

{ #category : #accessing }
LRUCacheNode >> key: anObject [

	key := anObject
]

{ #category : #'list operations' }
LRUCacheNode >> linkAfter: anLRUCacheHeadNode [

	next := anLRUCacheHeadNode next.
	previous := anLRUCacheHeadNode.
	next previous: self.
	previous next: self
]

{ #category : #accessing }
LRUCacheNode >> printOn: stream [

	super printOn: stream.
	stream
		nextPut: $(;
		print: key;
		nextPutAll: ', ';
		print: value;
		nextPut: $)
]

{ #category : #'list operations' }
LRUCacheNode >> unlink [

	next previous: previous.
	previous next: next.
	next := previous := nil
]

{ #category : #accessing }
LRUCacheNode >> value [

	^value
]

{ #category : #accessing }
LRUCacheNode >> value: anObject [

	value := anObject
]
