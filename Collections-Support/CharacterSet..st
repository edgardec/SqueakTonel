"
A set of characters.  Lookups for inclusion are very fast.
CharacterSet is the abstract class that is visible to the outside world.
Subclasses should be considered as implementation details.
"
Class {
	#name : #CharacterSet,
	#superclass : #Collection,
	#instVars : [
		'byteArrayMap'
	],
	#classVars : [
		'Ascii',
		'CrLf',
		'NonAscii',
		'NonSeparators',
		'Separators'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
CharacterSet class >> allCharacters [
	"return a set containing all characters"

	^ self empty complement
]

{ #category : #accessing }
CharacterSet class >> ascii [
	"return a set containing all the ASCII characters"

	^Ascii ifNil: [ Ascii := self newFrom: ((1 to: 127) collect: [:code | code asCharacter]) ]
]

{ #category : #'initialize-release' }
CharacterSet class >> cleanUp: aggressive [

	CrLf := NonSeparators := Separators := nil
]

{ #category : #accessing }
CharacterSet class >> crlf [

	^CrLf ifNil: [ CrLf := self with: Character cr with: Character lf ]
]

{ #category : #'instance creation' }
CharacterSet class >> empty [
 	"return an empty set of characters"
	^self new
]

{ #category : #testing }
CharacterSet class >> isAbstract [
	^self = CharacterSet
]

{ #category : #'instance creation' }
CharacterSet class >> new [
	self = CharacterSet ifTrue: [^ByteCharacterSet new].
	^super new
]

{ #category : #'instance creation' }
CharacterSet class >> newFrom: aCollection [
	| newCollection |
	newCollection := self new.
	newCollection addAll: aCollection.
	^newCollection
]

{ #category : #accessing }
CharacterSet class >> nonAscii [
	"return a set containing all the non ASCII characters"

	^NonAscii ifNil: [ NonAscii := self ascii complement ]
]

{ #category : #accessing }
CharacterSet class >> nonSeparators [
	"return a set containing everything but the whitespace characters"

	^NonSeparators ifNil: [
		NonSeparators := self separators complement ]
]

{ #category : #accessing }
CharacterSet class >> separators [
	"return a set containing just the whitespace characters"

	^Separators ifNil: [ Separators := self newFrom: Character separators ]
]

{ #category : #'instance creation' }
CharacterSet class >> withAll: aCollection [
	"Create a new CharacterSet containing all the characters from aCollection."

	^self newFrom: aCollection
]

{ #category : #accessing }
CharacterSet >> any: numberOfElements [

	^ self any: numberOfElements as: Array
]

{ #category : #accessing }
CharacterSet >> any: numberOfElements as: aClass [

	self canBeEnumerated
		ifTrue: [^ super any: numberOfElements as: aClass]
		ifFalse: [self shouldNotImplement]
]

{ #category : #converting }
CharacterSet >> as: otherClass [
	otherClass = CharacterSet ifTrue: [^self].
	^super as: otherClass
]

{ #category : #accessing }
CharacterSet >> byteArrayMap [
	"return a ByteArray mapping each ascii value to a 1 if that ascii value is in the set, and a 0 if it isn't.  Intended for use by primitives only"
	^byteArrayMap ifNil: [byteArrayMap := self createByteArrayMap]
]

{ #category : #converting }
CharacterSet >> byteComplement [
	"return a character set containing precisely the single byte characters the receiver does not"
	
	^ ByteCharacterSet fromMap: (self byteArrayMap collect: [:i | 1 - i])
]

{ #category : #testing }
CharacterSet >> canBeEnumerated [
	^true
]

{ #category : #converting }
CharacterSet >> complement [
	"return a character set containing precisely the characters the receiver does not"
	
	^CharacterSetComplement of: self copy
]

{ #category : #private }
CharacterSet >> createByteArrayMap [
	^ (0 to: 255)
		collect: [:i | (self includesCode: i) ifTrue: [1] ifFalse: [0]]
		as: ByteArray
]

{ #category : #private }
CharacterSet >> enumerationCost [
	"Answer an integer giving a scale of cost, especially for do: loops."
	
	^self subclassResponsibility
]

{ #category : #enumerating }
CharacterSet >> findFirstInByteString: aByteString startingAt: startIndex [
	"Double dispatching: since we know this is a ByteString, we can use a superfast primitive using a ByteArray map with 0 slots for byte characters not included and 1 for byte characters included in the receiver."
	^ByteString
		findFirstInString: aByteString
		inSet: self byteArrayMap
		startingAt: startIndex
]

{ #category : #testing }
CharacterSet >> includes: anObject [ 
	anObject isCharacter ifFalse: [ ^false ].
	^self includesCode: anObject asInteger
]

{ #category : #testing }
CharacterSet >> includesCode: anInteger [
	^self subclassResponsibility
]

{ #category : #enumerating }
CharacterSet >> intersection: aCollection [
	(self species = aCollection species and: [aCollection enumerationCost < self enumerationCost]) ifTrue: [^aCollection intersection: self].
	^ self select: [:each | aCollection includes: each]
]

{ #category : #testing }
CharacterSet >> isCharacters: aCollection [
	"Answer whether this collection contains characters"
	^self species = aCollection species or: [aCollection isString or: [aCollection allSatisfy: [:e | e isCharacter]]]
]

{ #category : #enumerating }
CharacterSet >> occurrencesOf: anObject [
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	(self includes: anObject) ifTrue: [ ^1 ].
	^0
]

{ #category : #copying }
CharacterSet >> postCopy [
	super postCopy.
	byteArrayMap := byteArrayMap copy
]

{ #category : #removing }
CharacterSet >> removeAll [
	self becomeForward: ByteCharacterSet new
]

{ #category : #private }
CharacterSet >> species [
	^CharacterSet
]

{ #category : #enumerating }
CharacterSet >> union: aCollection [
	(self isCharacters: aCollection) ifFalse: [^super union: aCollection].
	(self species = aCollection species and: [aCollection enumerationCost > self enumerationCost]) ifTrue: [^aCollection union: self].
	^self copy addAll: aCollection; yourself
]
