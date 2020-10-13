Class {
	#name : #WeakIdentityKeyDictionaryTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Weak'
}

{ #category : #coverage }
WeakIdentityKeyDictionaryTest >> classToBeTested [ 

	^WeakIdentityKeyDictionary
]

{ #category : #tests }
WeakIdentityKeyDictionaryTest >> testFinalizeValuesWhenLastChainContinuesAtFront [

	| objectWithHashModulo dictionary arraySize a b c |
	objectWithHashModulo := [ :requestedHash :modulo |
		| object |
		[ 
			object := Object new.
			object hash \\ modulo = requestedHash ] whileFalse.
		object ].
	dictionary := self classToBeTested new.
	arraySize := dictionary array size.
	a := objectWithHashModulo value: arraySize - 2 value: arraySize.
	dictionary at: a put: 1.
	b := objectWithHashModulo value: arraySize - 1 value: arraySize.
	dictionary at: b put: 2.
	c := objectWithHashModulo value: arraySize - 2 value: arraySize.
	dictionary at: c put: 3.
	self assert: dictionary array size = arraySize.
	self assert: (dictionary array at: arraySize - 1) key == a.
	self assert: (dictionary array at: arraySize) key == b.
	self assert: (dictionary array at: 1) key == c.
	a := nil.
	Smalltalk garbageCollect.
	dictionary finalizeValues.
	self assert: (dictionary includesKey: b).
	self assert: (dictionary includesKey: c).
	self assert: dictionary slowSize = 2
]

{ #category : #tests }
WeakIdentityKeyDictionaryTest >> testNoNils [
	| d |
	d := WeakIdentityKeyDictionary new
	at: 'hello' copy put: 'world';
		yourself.
	Smalltalk garbageCollect.
	self deny: (d keys includes: nil)
]
