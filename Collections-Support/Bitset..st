"
I implement Bitsets, which are dictionary-like data structures mapping 0-1 values to integers between 0 and capacity-1, or in another way they are set-like data structures which can include values between 0 and capacity-1.
I implement three different kind of APIs, each corresponding to a way of thinking about this data structure:
- A Set-like API with #add:, #remove: and #includes:
- A Dictionary-like API with #at:, #at:put:
- And a bit-manipulation API with #bitAt:, #clearBitAt: and #setBitAt:.

Instance Variables
	bytes:		<ByteArray>
	tally:		<Integer>

bytes
	- a ByteArray which holds the values for each integer key. Each byte holds 8 values.

tally
	- the number of objects in this set, or the number or 1 values in this dictionary.

"
Class {
	#name : #Bitset,
	#superclass : #Collection,
	#instVars : [
		'bytes',
		'tally'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
Bitset class >> initializedInstance [

	^ self new: 0
]

{ #category : #'instance creation' }
Bitset class >> new [

	self error: 'Use #new: instead.'
]

{ #category : #'instance creation' }
Bitset class >> new: capacity [

	^self basicNew initialize: capacity
]

{ #category : #comparing }
Bitset >> = anObject [

	self species == anObject species ifFalse: [ ^false ].
	anObject size = tally ifFalse: [ ^false ].
	^anObject bytes = bytes
]

{ #category : #adding }
Bitset >> add: anInteger [
	"Add anInteger to this set. Return anInteger."

	self setBitAt: anInteger.
	^anInteger
]

{ #category : #accessing }
Bitset >> at: anInteger [

	^self bitAt: anInteger
		
]

{ #category : #accessing }
Bitset >> at: anInteger put: aBit [

	^self bitAt: anInteger put: aBit
		
]

{ #category : #'bit manipulation' }
Bitset >> bitAt: anInteger [
	"Return the bit corresponding to anInteger."

	^((bytes at: (anInteger bitShift: -3) + 1) bitShift: 0 - (anInteger bitAnd: 7)) bitAnd: 1
		
]

{ #category : #'bit manipulation' }
Bitset >> bitAt: anInteger put: aBit [
	"Set the value corresponding to anInteger to aBit. Return the new value."

	aBit caseOf: {
		[ 0 ] -> [ self clearBitAt: anInteger ].
		[ 1 ] -> [ self setBitAt: anInteger ] }.
	^aBit
		
		
]

{ #category : #private }
Bitset >> bytes [

	^bytes
]

{ #category : #accessing }
Bitset >> capacity [
	"Return the highest integer this collection can store plus one."

	^bytes size * 8
]

{ #category : #'bit manipulation' }
Bitset >> clearBitAt: anInteger [
	"Set the value corresponding to anInteger to 0. Return true if the value wasn't 0."

	| index value mask newValue |
	index := (anInteger bitShift: -3) + 1.
	value := bytes at: index.
	mask := 1 bitShift: (anInteger bitAnd: 7).
	(newValue := (value bitOr: mask) - mask) = value ifTrue: [ ^false ].
	bytes at: index put: newValue.
	tally := tally - 1.
	^true

]

{ #category : #enumerating }
Bitset >> do: aBlock [
	"Evaluate aBlock with each integer which has its bit set to 1."

	| byte byteOffset lowBits remainingBits |
	remainingBits := tally.
	lowBits := Integer lowBitPerByteTable.
	1 to: bytes size do: [ :index |
		1 <= remainingBits ifFalse: [ ^self ].
		(byte := bytes at: index) = 0 ifFalse: [
			byteOffset := (index bitShift: 3) - 9. "- 8 - 1 to make it -1 based."
			[
				aBlock value: (lowBits at: byte) + byteOffset. "byteOffset is -1 based, lowBits is 1-based."
				remainingBits := remainingBits - 1.
				"Eliminate the low bit and loop if there're any remaning bits set."
				(byte := byte bitAnd: byte - 1) = 0 ] whileFalse ] ]
]

{ #category : #comparing }
Bitset >> hash [
	"#hash is implemented, because #= is implemented."

	^(self species hash bitXor: tally hashMultiply) bitXor: bytes hash
]

{ #category : #testing }
Bitset >> includes: anInteger [

	anInteger isInteger ifFalse: [ ^false ].
	-1 < anInteger ifFalse: [ ^false ].
	anInteger < self capacity ifFalse: [ ^false ].
	^(self bitAt: anInteger) = 1
]

{ #category : #private }
Bitset >> initialize: capacity [
	"Capacity is expected to be a non-negative, multiple-of-eight integer."

	bytes := ByteArray new: capacity // 8.
	tally := 0
]

{ #category : #testing }
Bitset >> isEmpty [
	^tally = 0
]

{ #category : #enumerating }
Bitset >> occurrencesOf: anObject [
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	(self includes: anObject) ifTrue: [ ^1 ].
	^0
]

{ #category : #copying }
Bitset >> postCopy [
	"Copy bytes as well."

	bytes := bytes copy
]

{ #category : #printing }
Bitset >> printElementsOn: aStream separatedBy: delimiter [
	"Overridden to always inform about the entire set of bits."

	(0 to: self capacity-1)
		do: [:index | aStream print: (self bitAt: index)]
		separatedBy: [aStream nextPutAll: delimiter asString].
]

{ #category : #removing }
Bitset >> remove: anInteger ifAbsent: absentBlock [

	(self clearBitAt: anInteger) ifTrue: [ ^anInteger ].
	^absentBlock value
]

{ #category : #removing }
Bitset >> removeAll [

	tally = 0 ifTrue: [ ^self ].
	bytes atAllPut: 0. "Unlike most #removeAll implementations, we don't allocate a new ByteArray here, because this is a bit more efficient. The VM would have to fill the new array with zeroes anyway."
	tally := 0
]

{ #category : #'bit manipulation' }
Bitset >> setBitAt: anInteger [
	"Set the value corresponding to anInteger to 1. Return true if the value wasn't 1."

	| index value newValue |
	index := (anInteger bitShift: -3) + 1.
	value := bytes at: index.
	(newValue := (1 bitShift: (anInteger bitAnd: 7)) bitOr: value) = value ifTrue: [ ^false ].
	bytes at: index put: newValue.
	tally := tally + 1.
	^true
]

{ #category : #accessing }
Bitset >> size [
	"Return the number of 1 values in this collection."

	^tally
]
