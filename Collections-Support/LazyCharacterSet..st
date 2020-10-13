"
A LazyCharacterSet is a kind of CharacterSet which does not know in advance which Character it contains or not.
If will lazily evaluate a block on demand if ever one ask whether it includes: a character.
It is not feasible to enumerate a LazyCharacterSet, because there are way too many characters.

Instance Variables
	block:		<BlockContext | Symbol>
	byteArrayMapCache:		<ByteArray | nil>

block
	- a valuable, answering either true or false when sent the message value: - true means that this set includes the character passed as value: argument.

byteArrayMapCache
	- a cache holding 0 or 1 for the first 256 character codes - 0 meaning not included, 1 included. This is used in some primitives

"
Class {
	#name : #LazyCharacterSet,
	#superclass : #CharacterSet,
	#instVars : [
		'block'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
LazyCharacterSet class >> including: aBlock [
	"Create the set of Character for which aBlock evaluates to true"
	^self new block: aBlock
]

{ #category : #adding }
LazyCharacterSet >> add: aCharacter [
	| oldBlock |
	oldBlock := block.
	block := [:c | c = aCharacter or: [oldBlock value: c]].
	^aCharacter
]

{ #category : #adding }
LazyCharacterSet >> addAll: aCollection [
	| oldBlock |
	oldBlock := block.
	block := [:c | (aCollection includes: c) or: [oldBlock value: c]].
	^aCollection
]

{ #category : #accessing }
LazyCharacterSet >> block [
	^block
]

{ #category : #accessing }
LazyCharacterSet >> block: aValuable [
	"Set the block used to determine if I include a Character or not.
	aValuable is an object that shoud answer true or false when sent value:"
	
	byteArrayMap := nil.
	block := aValuable
]

{ #category : #testing }
LazyCharacterSet >> canBeEnumerated [
	^false
]

{ #category : #enumerating }
LazyCharacterSet >> do: aBlock [
	"evaluate aBlock with each character in the set.
	don't do it, there are too many loop..."

	self shouldNotImplement
]

{ #category : #private }
LazyCharacterSet >> enumerationCost [
	"The maximum cost. I can't even do: loops, it's too expensive."
	
	^100
]

{ #category : #testing }
LazyCharacterSet >> includes: aCharacter [
	^block value: aCharacter
]

{ #category : #testing }
LazyCharacterSet >> includesCode: anInteger [
	^block value: (Character value: anInteger)
]

{ #category : #enumerating }
LazyCharacterSet >> intersection: aCollection [
	^((self isCharacters: aCollection)
		ifTrue: [aCollection select: block]
		ifFalse:
			["protect feeding block with non character"
			aCollection select: [:e |e isCharacter and: [block value: e]]]) as: CharacterSet
		
]

{ #category : #enumerating }
LazyCharacterSet >> reject: aBlock [
	^self class including: [:char | (aBlock value: char) not and: [block value: char]]
]

{ #category : #removing }
LazyCharacterSet >> remove: aCharacter [
	| oldBlock |
	oldBlock := block.
	block := [:c | (c = aCharacter) not and: [oldBlock value: c]].
	^aCharacter
]

{ #category : #removing }
LazyCharacterSet >> remove: aCharacter ifAbsent: aBlock [
	(self includes: aCharacter) ifFalse: [^aBlock value].
	^self remove: aCharacter
]

{ #category : #removing }
LazyCharacterSet >> removeAll: aCollection [
	| oldBlock |
	oldBlock := block.
	block := [:c | (aCollection includes: c) not and: [oldBlock value: c]].
	^aCollection
]

{ #category : #enumerating }
LazyCharacterSet >> select: aBlock [
	^self class including: [:char | (block value: char) and: [aBlock value: char]]
]

{ #category : #enumerating }
LazyCharacterSet >> union: aCollection [
	(self isCharacters: aCollection) ifFalse: [^super union: aCollection].
	^self class including: [:c | (aCollection includes: c) or: [block value: c]]
]
