"
PluggableSets allow the redefinition of hashing and equality by clients. This is in particular useful if the clients know about specific properties of the objects stored in the set which in turn can heavily improve the performance of sets and dictionaries.

Instance variables:
	hashBlock	<BlockClosure>	A one argument block used for hashing the elements.
	equalBlock	<BlockClosure>	A two argument block used for comparing the elements.

Example: Adding 1000000 integer points in the range (0@0) to: (100@100) to a set.

(	| n rnd set max points |
	set := Set new: (n := 1000000).
	rnd := Random new.
	max := 100.
	points := (1 to: n) collect: [:ign| (rnd next @ rnd next * max) truncated].
	Smalltalk garbageCollectMost. ""to reduce variability in the run-to-run times""
	[1 to: 1000000 do: [:i| set add: (points at: i)]]
		timeToRun
)

The above is way slow since the default hashing function of points leads to an awful lot of collisions in the set. And now the same, with a somewhat different hash function:

(	| n rnd set max points |
	set := PluggableSet new: (n := 1000000).
	set hashBlock: [:item| (item x bitShift: 10) + item y].
	rnd := Random new.
	max := 100.
	points := (1 to: n) collect: [:ign| (rnd next @ rnd next * max) truncated].
	Smalltalk garbageCollectMost. ""to reduce variability in the run-to-run times""
	[1 to: 1000000 do: [:i| set add: (points at: i)]]
		timeToRun
)
"
Class {
	#name : #PluggableSet,
	#superclass : #Set,
	#instVars : [
		'hashBlock',
		'equalBlock'
	],
	#category : #'Collections-Unordered'
}

{ #category : #'instance creation' }
PluggableSet class >> integerSet [
	^self new hashBlock: [:integer | integer hash \\ 1064164 * 1009]
]

{ #category : #comparing }
PluggableSet >> = anObject [
	"Two sets are equal if
	 (a) they are the same 'kind' of thing.
	 (b) they have the same set of keys.
	 (c) for each (common) key, they have the same value"

	self == anObject ifTrue: [ ^true ].
	self species == anObject species ifFalse: [ ^false ].
	hashBlock = anObject hashBlock ifFalse: [ ^false ].
	equalBlock = anObject equalBlock ifFalse: [ ^false ].
	self size = anObject size ifFalse: [ ^false ].
	^self allSatisfy: [ :each | anObject includes: each ]
]

{ #category : #copying }
PluggableSet >> copyEmpty [

	^super copyEmpty
		hashBlock: hashBlock;
		equalBlock: equalBlock;
		yourself
]

{ #category : #accessing }
PluggableSet >> equalBlock [
	"Return the block used for comparing the elements in the receiver."
	^equalBlock
]

{ #category : #accessing }
PluggableSet >> equalBlock: aBlock [
	"Set a new equality block. The block must accept two arguments and return true if the argumets are considered equal, false otherwise"
	equalBlock := aBlock.
]

{ #category : #accessing }
PluggableSet >> hashBlock [
	"Return the block used for hashing the elements in the receiver."
	^hashBlock
]

{ #category : #accessing }
PluggableSet >> hashBlock: aBlock [
	"Set a new hash block. The block must accept one argument and return the hash value of the given argument."
	hashBlock := aBlock.
]

{ #category : #private }
PluggableSet >> scanFor: anObject [ 
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := (hashBlock
		ifNil: [ anObject hash ]
		ifNotNil: [ hashBlock value: anObject ]) \\ (size := array size) + 1.
	[ 
		| element |
		((element := array at: index) == nil or: [
			equalBlock
				ifNil: [ element enclosedSetElement = anObject ]
				ifNotNil: [ equalBlock value: element enclosedSetElement value: anObject ] ])
			ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
PluggableSet >> scanForEmptySlotFor: anObject [
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
