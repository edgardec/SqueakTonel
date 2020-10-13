"
Class PluggableDictionary allows the redefinition of hashing and equality by clients. This is in particular useful if the clients know about specific properties of the objects stored in the dictionary. See the class comment of PluggableSet for an example.

Instance variables:
	hashBlock	<BlockClosure>	A one argument block used for hashing the elements.
	equalBlock	<BlockClosure>	A two argument block used for comparing the elements.

"
Class {
	#name : #PluggableDictionary,
	#superclass : #Dictionary,
	#instVars : [
		'hashBlock',
		'equalBlock'
	],
	#category : #'Collections-Unordered'
}

{ #category : #'instance creation' }
PluggableDictionary class >> integerDictionary [
	^ self new hashBlock: [:integer | integer hash \\ 1064164 * 1009]
]

{ #category : #comparing }
PluggableDictionary >> = anObject [
	"Two dictionaries are equal if
	 (a) they are the same 'kind' of thing.
	 (b) they have the same set of keys.
	 (c) for each (common) key, they have the same value"

	self == anObject ifTrue: [ ^true ].
	self species == anObject species ifFalse: [ ^false ].
	hashBlock = anObject hashBlock ifFalse: [ ^false ].
	equalBlock = anObject equalBlock ifFalse: [ ^false ].
	self size = anObject size ifFalse: [ ^false ].
	self associationsDo: [ :association |
		(anObject at: association key ifAbsent: [ ^false ]) = association value
			ifFalse: [ ^false ] ].
	^true
]

{ #category : #enumerating }
PluggableDictionary >> collect: aBlock [ 
	"Evaluate aBlock with each of my values as the argument.  Collect the resulting values into a collection that is like me. Answer with the new collection."
	
	| newCollection |
	newCollection := (self species new: self size)
		hashBlock: hashBlock;
		equalBlock: equalBlock;
		yourself.
	self associationsDo: [ :each |
		newCollection at: each key put: (aBlock value: each value) ].
	^newCollection


]

{ #category : #copying }
PluggableDictionary >> copyEmpty [

	^super copyEmpty
		hashBlock: hashBlock;
		equalBlock: equalBlock;
		yourself
]

{ #category : #accessing }
PluggableDictionary >> equalBlock [
	"Return the block used for comparing the elements in the receiver."
	^equalBlock
]

{ #category : #accessing }
PluggableDictionary >> equalBlock: aBlock [
	"Set a new equality block. The block must accept two arguments and return true if the argumets are considered to be equal, false otherwise"
	equalBlock := aBlock.
]

{ #category : #accessing }
PluggableDictionary >> hashBlock [
	"Return the block used for hashing the elements in the receiver."
	^hashBlock
]

{ #category : #accessing }
PluggableDictionary >> hashBlock: aBlock [
	"Set a new hash block. The block must accept one argument and must return the hash value of the given argument."
	hashBlock := aBlock.
]

{ #category : #private }
PluggableDictionary >> scanFor: anObject [ 
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := (hashBlock
		ifNil: [ anObject hash ]
		ifNotNil: [ hashBlock value: anObject ]) \\ (size := array size) + 1.
	[ 
		| element |
		((element := array at: index) == nil or: [
			equalBlock
				ifNil: [ element key = anObject ]
				ifNotNil: [ equalBlock value: element key value: anObject ] ])
			ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
PluggableDictionary >> scanForEmptySlotFor: anObject [
	"Scan the key array for the first slot containing an empty slot (indicated by a nil). Answer the index of that slot. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := (hashBlock
		ifNil: [ anObject hash ]
		ifNotNil: [ hashBlock value: anObject ]) \\ (size := array size) + 1.
	[ 
		(array at: index) ifNil: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]
