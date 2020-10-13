Class {
	#name : #WeakIdentityDictionaryTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Weak'
}

{ #category : #tests }
WeakIdentityDictionaryTest >> testIsEmpty [

	| wid o1 o2 |
	o1 := #o1 -> Object new.
	o2 := #o2 -> Object new.

	wid := self targetClass new.
	self assert: wid isEmpty.

	wid add: o1.
	wid add: o2.
	self deny: wid isEmpty.
	       
	Smalltalk garbageCollect.
	self deny: wid isEmpty.

	o1 := nil.
	o2 := nil.
	Smalltalk garbageCollect.
	self assert: wid isEmpty.
]
