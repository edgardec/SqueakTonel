Class {
	#name : #WeakKeyDictionaryTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Weak'
}

{ #category : #tests }
WeakKeyDictionaryTest >> testIsEmpty [

	| wkd o1 o2 |
	o1 := Object new.
	o2 := Object new.

	wkd := self targetClass new.
	self assert: wkd isEmpty.

	wkd at: o1 put: #o1.
	wkd at: o2 put: #o2.
	self deny: wkd isEmpty.
	       
	Smalltalk garbageCollect.
	wkd finalizeValues.
	self deny: wkd isEmpty.

	o1 := nil.
	o2 := nil.
	Smalltalk garbageCollect.
	wkd finalizeValues.
	self assert: wkd isEmpty.
]

{ #category : #tests }
WeakKeyDictionaryTest >> testNilDoesNotInheritValueOfGarbageCollectedObject [
	"When the keys are garbage collected, they become nil in the associations.
	This must not mislead the dictionary to answer that nil had one of the values of these
	associations!"
	| dictionary hashTable |
	dictionary := self targetClass new.
	"Craft a hash table where all keys were freed."
	hashTable := dictionary array.
	self assert: hashTable size > 0.
	hashTable replace: [:each | WeakKeyAssociation key: nil value: 1].
	self assert: (dictionary at: nil ifAbsent: []) isNil. "and not 1"
]
