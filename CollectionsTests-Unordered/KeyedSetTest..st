"
KeyedSetTest hold sunit tests for class KeyedSet
"
Class {
	#name : #KeyedSetTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Unordered'
}

{ #category : #tests }
KeyedSetTest >> testLike [
	
	| k |
	k := KeyedSet keyBlock: [ :each | each * 2 ].
	self assert: (k like: 1) isNil.
	k add: 1.
	self assert: (k like: 1) = 1.
	k add: 2.
	self assert: (k like: 2) = 2.
	self assert: (k like: 3) isNil.
]

{ #category : #tests }
KeyedSetTest >> testLikeIfAbsent [
	
	| k missing |
	k := KeyedSet keyBlock: [ :each | each * 2 ].
	missing := false.
	self assert: (k like: 1 ifAbsent: [ missing := true. nil ]) isNil.
	self assert: missing.
	k add: 1.
	missing := false.
	self assert: (k like: 1 ifAbsent: [ missing := true. nil ]) = 1.
	self deny: missing.
	k add: 2.
	self assert: (k like: 2 ifAbsent: nil) = 2.
	self assert: (k like: 3 ifAbsent: nil) isNil
]

{ #category : #tests }
KeyedSetTest >> testPut [
	
	| set result |
	set := KeyedSet keyBlock: [ :each | each ifNil: [ 1 ] ifNotNil: [ each first ] ].
	1 to: 10 do: [ :each | set add: { each. each asString } ].
	self assert: 10 equals: set size.
	
	1 to: 10 do: [ :each |
		| original |
		original := set at: each.
		result := set put: { each. each asString }.
		self assert: 10 equals: set size.
		self assert: { each. each asString } equals: result enclosedSetElement.
		self assert: original == result.
		self deny: original == (set at: each).
		self assert: original equals: (set at: each).
		self assert:  { each. each asString } equals: (set at: each) ].
	
	result := set put: { 11. '11' }.
	self assert: nil equals: result.
	self assert: 11 equals: set size.
	self assert: { 11. '11' } equals: (set at: 11).
	
	result := set put: { 11. '12' }.
	self assert: { 11. '11' } equals: result enclosedSetElement.
	self assert: 11 equals: set size.
	self assert: { 11. '12' } equals: (set at: 11).
	
	result := set put: nil.
	self assert: { 1. '1' } equals: result enclosedSetElement.
	self assert: 11 equals: set size.
	self assert: nil equals: (set at: 1)
]

{ #category : #tests }
KeyedSetTest >> testSelect [
	"this is a non regression test for http://bugs.squeak.org/view.php?id=6535"
	
	| ks ks2 |
	
	"Creare a KeyedSet"
	ks := KeyedSet keyBlock: [:e | e asInteger \\ 4].
	ks addAll: #(1.2 1.5 3.8 7.7 9.1 12.4 13.25 14.0 19.2 11.4).
	
	"There is non more than 4 possible keys (0 1 2 3)"
	self assert: ks size <= 4.
	
	"Select some elements"
	ks2 := ks select: [:e | e fractionPart > 0.5].

	"If keyBlock was preserved, then still no more than 4 keys..."
	ks2 addAll: #(1.2 1.5 3.8 7.7 9.1 12.4 13.25 14.0 19.2 11.4).
	self assert: ks2 size <= 4.
]
