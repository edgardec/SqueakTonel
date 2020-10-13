"
Text converter for UTF-8.  Since the BOM is used to distinguish the MacRoman code and UTF-8 code, BOM is written for UTF-8 by #writeBOMOn: which is called by client.
"
Class {
	#name : #UTF8TextConverter,
	#superclass : #TextConverter,
	#classVars : [
		'StrictUtf8Conversions'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #conversion }
UTF8TextConverter class >> decodeByteString: aByteString [
	"Convert the given string from UTF-8 using the fast path if converting to Latin-1"

	| outStream lastIndex nextIndex limit byte1 byte2 byte3 byte4 unicode |
	lastIndex := 1.
	(nextIndex := ByteString findFirstInString: aByteString inSet: latin1Map startingAt: lastIndex) = 0
		ifTrue: [ ^aByteString ].
	limit := aByteString size.
	outStream := (String new: limit) writeStream.
	[
		outStream next: nextIndex - lastIndex putAll: aByteString startingAt: lastIndex.
		byte1 := aByteString byteAt: nextIndex.
		(byte1 bitAnd: 16rE0) = 192 ifTrue: [ "two bytes"
			nextIndex < limit ifFalse: [ ^ self errorMalformedInput: aByteString ].
			byte2 := aByteString byteAt: (nextIndex := nextIndex + 1).
			(byte2 bitAnd: 16rC0) = 16r80 ifFalse:[	^self errorMalformedInput: aByteString ].
			unicode := ((byte1 bitAnd: 31) bitShift: 6) + (byte2 bitAnd: 63)].
		(byte1 bitAnd: 16rF0) = 224 ifTrue: [ "three bytes"
			(nextIndex + 2) <= limit ifFalse: [ ^ self errorMalformedInput: aByteString ].
			byte2 := aByteString byteAt: (nextIndex := nextIndex + 1).
			(byte2 bitAnd: 16rC0) = 16r80 ifFalse:[ ^self errorMalformedInput: aByteString ].
			byte3 := aByteString byteAt: (nextIndex := nextIndex + 1).
			(byte3 bitAnd: 16rC0) = 16r80 ifFalse:[ ^self errorMalformedInput: aByteString ].
			unicode := ((byte1 bitAnd: 15) bitShift: 12) + ((byte2 bitAnd: 63) bitShift: 6)
				+ (byte3 bitAnd: 63)].
		(byte1 bitAnd: 16rF8) = 240 ifTrue: [ "four bytes"
			(nextIndex + 3) <= limit ifFalse: [ ^ self errorMalformedInput: aByteString ].
			byte2 := aByteString byteAt: (nextIndex := nextIndex + 1).
			(byte2 bitAnd: 16rC0) = 16r80 ifFalse:[ ^self errorMalformedInput: aByteString ].
			byte3 := aByteString byteAt: (nextIndex := nextIndex + 1).
			(byte3 bitAnd: 16rC0) = 16r80 ifFalse:[ ^self errorMalformedInput: aByteString ].
			byte4 := aByteString byteAt: (nextIndex := nextIndex + 1).
			(byte4 bitAnd: 16rC0) = 16r80 ifFalse:[ ^self errorMalformedInput: aByteString ].
			unicode := ((byte1 bitAnd: 16r7) bitShift: 18) +
							((byte2 bitAnd: 63) bitShift: 12) + 
							((byte3 bitAnd: 63) bitShift: 6) +
							(byte4 bitAnd: 63)].
		unicode ifNil: [ ^self errorMalformedInput: aByteString ].
		unicode = 16rFEFF ifFalse: [ "Skip byte order mark"
			outStream nextPut: (Unicode value: unicode) ].
		lastIndex := nextIndex + 1.
		(nextIndex := ByteString findFirstInString: aByteString inSet: latin1Map startingAt: lastIndex) = 0 ] whileFalse.
	^outStream 
		next: aByteString size - lastIndex + 1 putAll: aByteString startingAt: lastIndex;
		contents

]

{ #category : #conversion }
UTF8TextConverter class >> encodeByteString: aByteString [
	"Convert the given string from UTF-8 using the fast path if converting to Latin-1"

	| outStream lastIndex nextIndex |
	lastIndex := 1.
	(nextIndex := ByteString findFirstInString: aByteString inSet: latin1Map startingAt: lastIndex) = 0
		ifTrue: [ ^aByteString ].
	outStream := (String new: aByteString size + 1) writeStream.
	[
		outStream 
			next: nextIndex - lastIndex putAll: aByteString startingAt: lastIndex;
			nextPutAll: (latin1Encodings at: (aByteString byteAt: nextIndex) + 1).
		lastIndex := nextIndex + 1.
		(nextIndex := ByteString findFirstInString: aByteString inSet: latin1Map startingAt: lastIndex) = 0 ] whileFalse.
	^outStream 
		next: aByteString size - lastIndex + 1 putAll: aByteString startingAt: lastIndex;
		contents
]

{ #category : #utilities }
UTF8TextConverter class >> encodingNames [

	^ #('utf-8' 'utf8') copy.

]

{ #category : #utilities }
UTF8TextConverter class >> errorMalformedInput: aString [
	"Invalid UTF-8 input has been detected in the given string.
	Raise an error if strict conversions are enabled, otherwise allow
	the original string to be returned."

	self strictUtf8Conversions ifTrue:[
		(InvalidUTF8 new string: aString) signal.
	].

	^aString
]

{ #category : #'class initialization' }
UTF8TextConverter class >> initializeLatin1MapAndEncodings [
	"Initialize the latin1Map and latin1Encodings. These variables ensure that conversions from latin1 ByteString is reasonably fast."
	
	latin1Map := (0 to: 255) collect: [ :each | each bitShift: -7 ] as: ByteArray.
	latin1Encodings := (0 to: 255) collect: [ :each |
		each <= 127
			ifTrue: [ nil ]
			ifFalse: [
				{ 192 bitOr: (each bitShift: -6). (each bitAnd: 63) bitOr: 128 } asByteArray asString ] ]
]

{ #category : #utilities }
UTF8TextConverter class >> strictUtf8Conversions [
	"Preference setter for strict utf-8 conversions"

	<preference: 'Strict utf8 conversions'
		category: 'general' "should this be localization?"
		description: 'If true, invalid utf-8 input will raise errors. If false, invalid utf-8 input will be allowed to pass through the conversion unchanged'
		type: #Boolean>
	
	^StrictUtf8Conversions ifNil:[true]

]

{ #category : #utilities }
UTF8TextConverter class >> strictUtf8Conversions: aBool [
	"Preference setter for strict utf-8 conversions"

	StrictUtf8Conversions := aBool.


]

{ #category : #accessing }
UTF8TextConverter class >> writeBOMOn: aStream [
	"Write Byte Order Mark"
	aStream nextPut: 16rEF.
	aStream nextPut: 16rBB.
	aStream nextPut: 16rBF.

]

{ #category : #conversion }
UTF8TextConverter >> backFromStream: aStream [

	aStream position = 0 ifTrue: [ ^nil ].
	aStream isBinary ifTrue: [ ^aStream basicBack ].
	[ aStream position = 0 or: [ 
		(aStream basicBack asciiValue bitXor: 128) >= 64 ] ] whileFalse.
	^aStream peek
]

{ #category : #conversion }
UTF8TextConverter >> decodeString: aString [

	| result |
	aString isByteString ifFalse: [ ^super decodeString: aString ].
	result := self class decodeByteString: aString.
	self class latin1Encodings == latin1Encodings ifTrue: [ ^result ].
	^result withSqueakLineEndings
]

{ #category : #conversion }
UTF8TextConverter >> encodeString: aString [

	| result |
	aString isByteString ifFalse: [ ^super encodeString: aString ].
	result := self class encodeByteString: aString.
	self class latin1Encodings == latin1Encodings ifTrue: [ ^result ].
	^result withLineEndings: (latin1Encodings at: 14)
	
]

{ #category : #conversion }
UTF8TextConverter >> errorMalformedInput: aString [
	"Invalid UTF-8 input has been detected in the given string.
	Raise an error if strict conversions are enabled, otherwise allow
	the original string to be returned."
	
	^self class errorMalformedInput: aString
]

{ #category : #friend }
UTF8TextConverter >> leadingChar [

	^ self shouldNotImplement

]

{ #category : #'fileIn\/Out' }
UTF8TextConverter >> nextChunkFromStream: input [
	"Answer the contents of input, up to the next terminator character. Doubled terminators indicate an embedded terminator character."
	
	self skipSeparatorsFrom: input.
	^self 
		parseLangTagFor: (
			self decodeString: (
				String new: 1000 streamContents: [ :stream |
					[
						stream nextPutAll: (input basicUpTo: $!).
						input basicNext == $! ]
							whileTrue: [ 
								stream nextPut: $! ].
					input atEnd ifFalse: [ input skip: -1 ] ]))
		fromStream: input
]

{ #category : #'fileIn\/Out' }
UTF8TextConverter >> nextChunkTextFromStream: input [
	"Deliver the next chunk as a Text.  Decode the following ]style[ chunk if present.  Position at start of next real chunk."
	
	| chunk position runs |
	chunk := self nextChunkFromStream: input.
	position := input position.
	((self skipSeparatorsAndPeekNextFrom: input) == $] and: [
		(input basicNext: 7) = ']style[' ])
			ifTrue: [
				runs := RunArray scanFrom: (self nextChunkFromStream: input) readStream ]
			ifFalse: [
				input position: position.
				runs := RunArray new: chunk size withAll: #() ].
	^Text string: chunk runs: runs
]

{ #category : #conversion }
UTF8TextConverter >> nextFromStream: aStream [

	| char1 value1 char2 value2 unicode char3 value3 char4 value4 |
	aStream isBinary ifTrue: [^ aStream basicNext].
	char1 := aStream basicNext.
	char1 ifNil:[^ nil].
	value1 := char1 asInteger.
	value1 <= 127 ifTrue: [
		"1-byte char"
		^ char1 asCharacter
	].

	"at least 2-byte char"
	char2 := aStream basicNext.
	char2 ifNil:[^self errorMalformedInput: (String with: char1 asCharacter)].
	value2 := char2 asInteger.

	(value1 bitAnd: 16rE0) = 192 ifTrue: [
		^ Unicode value: ((value1 bitAnd: 31) bitShift: 6) + (value2 bitAnd: 63).
	].

	"at least 3-byte char"
	char3 := aStream basicNext.
	char3 ifNil:[^self errorMalformedInput: (String with: char1 asCharacter with: char2 asCharacter)].
	value3 := char3 asInteger.
	(value1 bitAnd: 16rF0) = 224 ifTrue: [
		unicode := ((value1 bitAnd: 15) bitShift: 12) + ((value2 bitAnd: 63) bitShift: 6)
				+ (value3 bitAnd: 63).
	].

	(value1 bitAnd: 16rF8) = 240 ifTrue: [
		"4-byte char"
		char4 := aStream basicNext.
		char4 ifNil:[^self errorMalformedInput: (String with: char1 asCharacter with: char2 asCharacter with: char3 asCharacter)].
		value4 := char4 asInteger.
		unicode := ((value1 bitAnd: 16r7) bitShift: 18) +
					((value2 bitAnd: 63) bitShift: 12) + 
					((value3 bitAnd: 63) bitShift: 6) +
					(value4 bitAnd: 63).
	].

	unicode ifNil:[^self errorMalformedInput: (String with: char1 asCharacter with: char2 asCharacter with: char3 asCharacter)].
	unicode > 16r10FFFD ifTrue: [
		^self errorMalformedInput: (String with: char1 asCharacter with: char2 asCharacter with: char3 asCharacter).
	].
	
	unicode = 16rFEFF ifTrue: [^ self nextFromStream: aStream].
	^ Unicode value: unicode.

]

{ #category : #conversion }
UTF8TextConverter >> nextPut: aCharacter toStream: aStream [ 
	
	| nBytes mask shift ucs2code |
	aStream isBinary ifTrue: [ ^aCharacter storeBinaryOn: aStream ].
	ucs2code := aCharacter asUnicode ifNil: [ ^aCharacter ].
	ucs2code < 256 ifTrue: [
		(latin1Encodings at: ucs2code + 1)
			ifNil: [ aStream basicNextPut: aCharacter ]
			ifNotNil: [ :encodedString | aStream basicNextPutAll: encodedString ].
		^aCharacter ].
	nBytes := ucs2code highBit + 3 // 5.
	mask := #[128 192 224 240 248 252 254 255] at: nBytes.
	shift := nBytes - 1 * -6.
	aStream basicNextPut: (Character value: (ucs2code bitShift: shift) + mask).
	2 to: nBytes do: [ :i | 
		shift := shift + 6.
		aStream basicNextPut: (
			Character value: ((ucs2code bitShift: shift) bitAnd: 63) + 128) ].
	^aCharacter.

]

{ #category : #'fileIn\/Out' }
UTF8TextConverter >> parseLangTagFor: aString fromStream: stream [

	| position |
	position := stream position.
	"Test for ]lang[ tag"
	((self skipSeparatorsAndPeekNextFrom: stream) == $] and: [
		(stream basicNext: 6) = ']lang[' ]) ifTrue: [
			^stream
				decodeString: aString
				andRuns: (self nextChunkFromStream: stream) ].
	"no tag"
	stream position: position.
	^aString
]

{ #category : #'fileIn\/Out' }
UTF8TextConverter >> skipSeparatorsAndPeekNextFrom: aStream [
	"Same as #skipSeparators, but returns the next character after the separators if such exists."

	| character |
	[ 
		((character := aStream basicNext) 
			ifNil: [ ^aStream "backwards compatibility, should be nil" ])
				isSeparator ] whileTrue.
	aStream skip: -1.
	^character
	
]

{ #category : #'fileIn\/Out' }
UTF8TextConverter >> skipSeparatorsFrom: aStream [

	[ (aStream basicNext ifNil: [ ^self ]) isSeparator ] whileTrue.
	aStream skip: -1
]
