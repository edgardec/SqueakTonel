"
WideCharacterSet is used to store a Set of WideCharacter with fast access and inclusion test.

Implementation should be efficient in memory if sets are sufficently sparse.

Wide Characters are at most 32bits.
We split them into 16 highBits and 16 lowBits.

map is a dictionary key: 16 highBits value: map of 16 lowBits.

Maps of lowBits  are stored as arrays of bits in a ByteArray.
If a bit is set to 1, this indicate that corresponding character is present.
8192 bytes are necessary in each lowmap.
Empty lowmap are removed from the map Dictionary.

A byteArrayMap is maintained in parallel with map for fast handling of ByteString.
(byteArrayMap at: i+1) = 0 means that character of asciiValue i is absent, = 1 means present.
"
Class {
	#name : #WideCharacterSet,
	#superclass : #CharacterSet,
	#instVars : [
		'map',
		'bitsetCapacity',
		'highBitsShift',
		'lowBitsMask'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
WideCharacterSet class >> newFrom: aCollection [
	| newCollection |
	newCollection := self new.
	newCollection addAll: aCollection.
	^newCollection
]

{ #category : #comparing }
WideCharacterSet >> = anObject [
	^self species == anObject species
		and: [ anObject canBeEnumerated
			and: [ self wideCharacterMap = anObject wideCharacterMap ] ]
]

{ #category : #adding }
WideCharacterSet >> add: aCharacter [

	| value highBits lowBits |
	(value := aCharacter asInteger) < 256 ifTrue: [
		byteArrayMap at: value + 1 put: 1 ].
	highBits := value bitShift: highBitsShift.
	lowBits := value bitAnd: lowBitsMask.
	(map at: highBits ifAbsentPut: [ Bitset new: bitsetCapacity ])
		setBitAt: lowBits.
	^aCharacter
]

{ #category : #comparing }
WideCharacterSet >> byteArrayMap [
	"return a ByteArray mapping each ascii value to a 1 if that ascii value is in the set, and a 0 if it isn't.
	Intended for use by primitives only. (and comparison)
	This version will answer a subset with only byte characters"
	
	^byteArrayMap
]

{ #category : #enumerating }
WideCharacterSet >> do: aBlock [
 
	map keysAndValuesDo: [ :index :bitset |
		| highBits |
		highBits := index * bitsetCapacity.
		bitset do: [ :lowBits |
			aBlock value: (Character value: highBits + lowBits) ] ]
]

{ #category : #private }
WideCharacterSet >> enumerationCost [
	"Medium cost. I can hold many characters eventually."
	
	^50
]

{ #category : #testing }
WideCharacterSet >> hasWideCharacters [
	"Answer true if i contain any wide character"
	
	self do: [:e | e asciiValue >= 256 ifTrue: [^true]].
	^false
]

{ #category : #comparing }
WideCharacterSet >> hash [
	"Answer a hash code aimed at storing and retrieving the receiver in a Set or Dictionary.
	Two equal objects should have equal hash.
	Note: as the receiver can be equal to an ordinary CharacterSet,
	the hash code must reflect this"
	
	self hasWideCharacters ifTrue: [ ^map hash ].
	^byteArrayMap hash
]

{ #category : #testing }
WideCharacterSet >> includesCode: anInteger [
	anInteger < 256 ifTrue: [ ^(byteArrayMap at: anInteger + 1) ~= 0 ].
	^((map at: (anInteger bitShift: highBitsShift) ifAbsent: nil) ifNil: [ ^false ])
		includes: (anInteger bitAnd: lowBitsMask)
]

{ #category : #'initialize-release' }
WideCharacterSet >> initialize [

	map := PluggableDictionary integerDictionary.
	byteArrayMap := ByteArray new: 256.
	self initializeWithLowBits: 8
]

{ #category : #'initialize-release' }
WideCharacterSet >> initializeWithLowBits: lowBits [

	bitsetCapacity := 1 bitShift: lowBits.
	highBitsShift := 0 - lowBits.
	lowBitsMask := bitsetCapacity - 1.
	
]

{ #category : #copying }
WideCharacterSet >> postCopy [
	super postCopy.
	map := map collect: [:each | each copy]
]

{ #category : #removing }
WideCharacterSet >> remove: aCharacter [
	"Don't signal an error when aCharacter is not present."

	^self remove: aCharacter ifAbsent: aCharacter
]

{ #category : #removing }
WideCharacterSet >> remove: aCharacter ifAbsent: aBlock [

	| value highBits lowBits bitset |
	(value := aCharacter asInteger) < 256 ifTrue: [
		(byteArrayMap at: value + 1) = 0 ifTrue: [ ^aBlock value ].
		byteArrayMap at: value + 1 put: 0 ].
	highBits := value bitShift: highBitsShift.
	lowBits := value bitAnd: lowBitsMask.
	bitset := (map at: highBits ifAbsent: nil) ifNil: [ ^aBlock value ].
	((bitset clearBitAt: lowBits) and: [ bitset size = 0 ]) ifTrue: [
		map removeKey: highBits ].
	^aCharacter
]

{ #category : #removing }
WideCharacterSet >> removeAll [

	map isEmpty ifTrue: [ ^self ].
	map removeAll.
	byteArrayMap atAllPut: 0
]

{ #category : #accessing }
WideCharacterSet >> size [

	^map detectSum: [ :each | each size ]
]

{ #category : #comparing }
WideCharacterSet >> wideCharacterMap [
	^map
]
