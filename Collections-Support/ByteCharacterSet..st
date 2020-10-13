"
A set of characters.  Lookups for inclusion are very fast.
"
Class {
	#name : #ByteCharacterSet,
	#superclass : #CharacterSet,
	#instVars : [
		'tally'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
ByteCharacterSet class >> allCharacters [
	"return a set containing all byte characters"

	^ self fromMap: (ByteArray new: 256 withAll: 1)
]

{ #category : #'instance creation' }
ByteCharacterSet class >> fromMap: aByteArray [
	
	^self basicNew fromMap: aByteArray
]

{ #category : #comparing }
ByteCharacterSet >> = anObject [
	
	self species == anObject species ifFalse: [ ^false ].
	anObject size = tally ifFalse: [ ^false ].
	^self byteArrayMap = anObject byteArrayMap
]

{ #category : #adding }
ByteCharacterSet >> add: aCharacter [
	"I automatically become a WideByteCharacterSet if you add a wide character to myself"
	
	| index |
	(index := aCharacter asInteger + 1) <= 256 ifFalse: [
		| wide |
		wide := WideCharacterSet new.
		wide addAll: self.
		wide add: aCharacter.
		self becomeForward: wide.
		^aCharacter ].
	(byteArrayMap at: index) = 1 ifFalse: [
		byteArrayMap at: index put: 1.
		tally := tally + 1 ].
	^aCharacter
]

{ #category : #conversion }
ByteCharacterSet >> asString [
	"Convert the receiver into a String"

	^String new: self size streamContents:[:s|
		self do:[:ch| s nextPut: ch].
	].
]

{ #category : #private }
ByteCharacterSet >> byteArrayMap [
	"return a ByteArray mapping each ascii value to a 1 if that ascii value is in the set, and a 0 if it isn't.  Intended for use by primitives only"
	^byteArrayMap
]

{ #category : #enumerating }
ByteCharacterSet >> do: aBlock [
	"evaluate aBlock with each character in the set"

	| index |
	tally >= 128 ifTrue: [ "dense"
		index := 0.
		[ (index := index + 1) <= 256 ] whileTrue: [
			(byteArrayMap at: index) = 1 ifTrue: [
				aBlock value: (Character value: index - 1) ] ].
		^self ].
	"sparse"
	index := 0.
	[ (index := byteArrayMap indexOf: 1 startingAt: index + 1) = 0 ] whileFalse: [
		aBlock value: (Character value: index - 1) ].
	
]

{ #category : #private }
ByteCharacterSet >> enumerationCost [
	"Low cost. I do not hold more than 256 characters."
	
	^10
]

{ #category : #'initialize-release' }
ByteCharacterSet >> fromMap: aByteArray [
	byteArrayMap := aByteArray.
	tally := aByteArray count: [:e | e = 1]
]

{ #category : #testing }
ByteCharacterSet >> hasWideCharacters [
	^false
]

{ #category : #comparing }
ByteCharacterSet >> hash [
	^self byteArrayMap hash
]

{ #category : #testing }
ByteCharacterSet >> includesCode: anInteger [
	anInteger > 255 ifTrue: [ ^false ].
	^(byteArrayMap at: anInteger + 1) > 0
]

{ #category : #'initialize-release' }
ByteCharacterSet >> initialize [
	byteArrayMap := ByteArray new: 256.
	tally := 0
]

{ #category : #testing }
ByteCharacterSet >> isEmpty [
	^tally = 0
]

{ #category : #copying }
ByteCharacterSet >> postCopy [
	super postCopy.
	byteArrayMap := byteArrayMap copy
]

{ #category : #removing }
ByteCharacterSet >> remove: aCharacter [

	^self remove: aCharacter ifAbsent: aCharacter
]

{ #category : #removing }
ByteCharacterSet >> remove: aCharacter ifAbsent: aBlock [

	| index |
	(index := aCharacter asciiValue + 1) <= 256 ifFalse: [ ^aBlock value ].
	(byteArrayMap at: index) = 0 ifTrue: [ ^aBlock value ].
	byteArrayMap at: index put: 0.
	tally := tally - 1.
	^aCharacter
]

{ #category : #removing }
ByteCharacterSet >> removeAll [

	byteArrayMap atAllPut: 0.
	tally := 0
]

{ #category : #accessing }
ByteCharacterSet >> size [

	^tally
]

{ #category : #private }
ByteCharacterSet >> wideCharacterMap [
	"used for comparing with WideByteCharacterSet"
	
	| wide |
	wide := WideCharacterSet new.
	wide addAll: self.
	^wide wideCharacterMap
]
