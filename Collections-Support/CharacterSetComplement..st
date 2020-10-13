"
CharacterSetComplement is a space efficient implementation of (CharacterSet complement) taking care of WideCharacter (code > 255)

However, it will maintain a byteArrayMap for character <= 255 in a cache keeping 

instance variables:
	absent <CharacterSet> contains character that are not in the set (i.e. my complement)
	byteArrayMapCache <ByteArray | nil> cache this information because it has to be used in tight loops where efficiency matters
"
Class {
	#name : #CharacterSetComplement,
	#superclass : #CharacterSet,
	#instVars : [
		'absent'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
CharacterSetComplement class >> of: aCharacterSet [
	"answer the complement of aCharacterSet"
	
	^ self new complement: aCharacterSet
]

{ #category : #comparing }
CharacterSetComplement >> = anObject [
	"Implementation note: we do not test if equal to a WideCharacterSet,
	because it is unlikely that WideCharacterSet is as complete as self"
	
	^self class == anObject class and: [
		absent = anObject complement ]
]

{ #category : #adding }
CharacterSetComplement >> add: aCharacter [ 
	"a character is present if not absent, so adding a character is removing it from the absent"
	
	(absent includes: aCharacter)
		ifTrue:
			[byteArrayMap := nil.
			absent remove: aCharacter].
	^ aCharacter
]

{ #category : #testing }
CharacterSetComplement >> canBeEnumerated [
	^false
]

{ #category : #converting }
CharacterSetComplement >> complement [
	"return a character set containing precisely the characters the receiver does not"
	
	^absent copy
]

{ #category : #'initialize-release' }
CharacterSetComplement >> complement: aCharacterSet [
	"initialize with the complement"
	
	byteArrayMap := nil.
	absent := aCharacterSet.
	
]

{ #category : #enumerating }
CharacterSetComplement >> do: aBlock [
	"evaluate aBlock with each character in the set.
	don't do it, there are too many..."

	self shouldNotImplement
]

{ #category : #private }
CharacterSetComplement >> enumerationCost [
	"The maximum cost. I can't even do: loops, it's too expensive."
	
	^100
]

{ #category : #testing }
CharacterSetComplement >> hasWideCharacters [
	"This is a guess that absent is not holding each and every possible wideCharacter..."
	
	^true
]

{ #category : #comparing }
CharacterSetComplement >> hash [
	^ absent hash bitXor: self class hash
]

{ #category : #testing }
CharacterSetComplement >> includesCode: anInteger [
	(absent includesCode: anInteger) ifTrue: [ ^false ].
	^true
]

{ #category : #enumerating }
CharacterSetComplement >> intersection: aCollection [
	aCollection class = self class ifTrue: [^(self complement union: aCollection complement) complement].
	^(aCollection intersection: self) as: CharacterSet
]

{ #category : #copying }
CharacterSetComplement >> postCopy [
	super postCopy.
	absent := absent copy
]

{ #category : #printing }
CharacterSetComplement >> printOn: aStream [
	"Print a description of the complement rather than self.
	Rationale: self would be too long to print."
	
	aStream nextPut: $(.
	absent printOn: aStream.
	aStream nextPut: $); space; nextPutAll: #complement.
]

{ #category : #enumerating }
CharacterSetComplement >> reject: aBlock [
	^LazyCharacterSet including: [:c | (absent includes: c) not and: [(aBlock value: c) not]]
]

{ #category : #removing }
CharacterSetComplement >> remove: aCharacter [
	"This means aCharacter is now absent from myself.
	It must be added to my absent."
	
	byteArrayMap := nil.
	^absent add: aCharacter
]

{ #category : #removing }
CharacterSetComplement >> remove: aCharacter ifAbsent: aBlock [
	(self includes: aCharacter) ifFalse: [^aBlock value].
	^self remove: aCharacter
]

{ #category : #enumerating }
CharacterSetComplement >> select: aBlock [
	^LazyCharacterSet including: [:c | (absent includes: c) not and: [aBlock value: c]]
]

{ #category : #printing }
CharacterSetComplement >> storeOn: aStream [
	"Store a description of the elements of the complement rather than self."
	
	aStream nextPut: $(.
	absent storeOn: aStream.
	aStream nextPut: $); space; nextPutAll: #complement.
]

{ #category : #enumerating }
CharacterSetComplement >> union: aCollection [
	aCollection class = self class ifTrue: [^(self complement intersection: aCollection complement) complement].
	(self isCharacters: aCollection) ifFalse: [^super union: aCollection].
	^(absent reject: [:e | aCollection includes: e]) complement
]
