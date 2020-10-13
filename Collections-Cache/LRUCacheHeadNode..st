Class {
	#name : #LRUCacheHeadNode,
	#superclass : #Object,
	#instVars : [
		'next',
		'previous'
	],
	#category : #'Collections-Cache'
}

{ #category : #'initialize-release' }
LRUCacheHeadNode >> initialize [

	previous := next := self
]

{ #category : #accessing }
LRUCacheHeadNode >> next [

	^next
]

{ #category : #accessing }
LRUCacheHeadNode >> next: anObject [

	next := anObject
]

{ #category : #accessing }
LRUCacheHeadNode >> previous [

	^previous
]

{ #category : #accessing }
LRUCacheHeadNode >> previous: anObject [

	previous := anObject
]
