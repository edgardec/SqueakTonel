"
This class represents the symbols containing 8bit characters.
"
Class {
	#name : #ByteSymbol,
	#superclass : #Symbol,
	#type : #bytes,
	#category : #'Collections-Strings'
}

{ #category : #primitives }
ByteSymbol class >> findFirstInString: aString inSet: inclusionMap startingAt: start [
	^ByteString findFirstInString: aString  inSet: inclusionMap startingAt: start
]

{ #category : #primitives }
ByteSymbol class >> indexOfAscii: anInteger inString: aString startingAt: start [
	^ByteString indexOfAscii: anInteger inString: aString startingAt: start
]

{ #category : #primitives }
ByteSymbol class >> stringHash: aString initialHash: speciesHash [
	"Answer the hash of a byte-indexed string, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply."
	<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>

	^super stringHash: aString initialHash: speciesHash
]

{ #category : #primitives }
ByteSymbol class >> translate: aString from: start  to: stop  table: table [
	^ByteString translate: aString from: start  to: stop  table: table
]

{ #category : #converting }
ByteSymbol >> asByteArray [
	| ba sz |
	sz := self byteSize.
	ba := ByteArray new: sz.
	ba replaceFrom: 1 to: sz with: self startingAt: 1.
	^ba
]

{ #category : #converting }
ByteSymbol >> asOctetString [
	^ self
]

{ #category : #accessing }
ByteSymbol >> at: index [ 
	"Primitive. Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 63>
	^ Character value: (super at: index)
]

{ #category : #accessing }
ByteSymbol >> at: anInteger put: anObject [ 
	"You cannot modify the receiver."
	self errorNoModification
]

{ #category : #accessing }
ByteSymbol >> byteAt: index [
	<primitive: 60>
	^(self at: index) asciiValue
]

{ #category : #accessing }
ByteSymbol >> byteAt: anInteger put: anObject [ 
	"You cannot modify the receiver."
	self errorNoModification
]

{ #category : #accessing }
ByteSymbol >> byteSize [
	^self size
]

{ #category : #testing }
ByteSymbol >> canBeToken [
	"Optimized version for the common case."
	
	| index |
	index := 0.
	[ (index := self findSubstring: '~' in: self startingAt: index + 1 matchTable: Tokenish) = 0 ]
		whileFalse: [
			(self at: index) == $_ ifFalse: [ ^false ] ].
	^true
		
]

{ #category : #comparing }
ByteSymbol >> findSubstring: key in: body startingAt: start matchTable: matchTable [
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned."
	<primitive: 'primitiveFindSubstring' module: 'MiscPrimitivePlugin'>
	^super findSubstring: key in: body startingAt: start matchTable: matchTable
]

{ #category : #private }
ByteSymbol >> hashWithInitialHash: speciesHash [
	"Answer the hash of a byte-indexed string, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply."
	<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>

	^super hashWithInitialHash: speciesHash
]

{ #category : #accessing }
ByteSymbol >> indexOfAnyOf: aCollection startingAt: start [
	"Use double dispatching for speed"
	^aCollection findFirstInByteString: self startingAt: start
]

{ #category : #testing }
ByteSymbol >> isByteString [
	"Answer whether the receiver is a ByteString"
	^true
]

{ #category : #testing }
ByteSymbol >> isOctetString [
	"Answer whether the receiver can be represented as a byte string. 
	This is different from asking whether the receiver *is* a ByteString 
	(i.e., #isByteString)"
	^ true.

]

{ #category : #enumerating }
ByteSymbol >> occurrencesOf: anObject [ 
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	| tally |
	anObject isCharacter ifFalse: [ ^0 ].
	anObject asInteger > 255 ifTrue: [ ^0 ].
	tally := 0.
	1 to: self size do: [ :index |
		(self at: index) == anObject ifTrue: [ tally := tally + 1 ] ].
	^tally
]

{ #category : #private }
ByteSymbol >> pvtAt: index put: aCharacter [
	"Primitive. Store the Character in the field of the receiver indicated by the index.
	 Fail if the index is not an Integer or is out of bounds, or if the argument is not a
	 Character, or the Character's code is outside the 0-255 range, or if the receiver
	 is read-only. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 64 error: ec>
	aCharacter isCharacter ifFalse:
		[^self errorImproperStore].
	index isInteger
		ifTrue:
			[ec == #'no modification' ifTrue:
				[^thisContext modificationForbiddenFor: self at: index putCharacter: aCharacter].
			self errorSubscriptBounds: index]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
ByteSymbol >> species [
	"Answer the preferred class for reconstructing the receiver."
	^ByteString

]

{ #category : #private }
ByteSymbol >> string: aString [
	1 to: aString size do: [:j | self pvtAt: j put: (aString at: j)].
	^self
]
