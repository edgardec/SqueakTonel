"
Text converter for UTF-32.  It supports the endianness and byte order mark.
"
Class {
	#name : #UTF32TextConverter,
	#superclass : #TextConverter,
	#instVars : [
		'useLittleEndian',
		'useByteOrderMark',
		'byteOrderMarkDone'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #utilities }
UTF32TextConverter class >> encodingNames [

	^ #( 'utf32' 'utf32be' 'utf32le' 'utf-32' 'utf-32be' 'utf-32le' 'ucs4' 'ucs4be' 'ucs4le') copy

]

{ #category : #utilities }
UTF32TextConverter class >> initializeLatin1MapAndEncodings [
	"Initialize the latin1Map and latin1Encodings.
	These variables ensure that conversions from latin1 ByteString is reasonably fast."
	
	latin1Map := ByteArray new: 256 withAll: 1.
	latin1Encodings := (0 to: 255) collect: [ :i | { 0. 0. 0. i } asByteArray asString ]

]

{ #category : #'initialize-release' }
UTF32TextConverter >> initialize [

	super initialize.
	useLittleEndian := useByteOrderMark := byteOrderMarkDone := false
]

{ #category : #private }
UTF32TextConverter >> next16BitValue: value toStream: aStream [

	| v1 v2 |
	v1 := (value bitShift: -8) bitAnd: 16rFF.
	v2 := value bitAnd: 16rFF.
	useLittleEndian
		ifTrue: [
			aStream 
				basicNextPut: (Character value: v2);
				basicNextPut: (Character value: v1) ]
		ifFalse: [
			aStream
				basicNextPut: (Character value: v1);
				basicNextPut: (Character value: v2) ].

]

{ #category : #private }
UTF32TextConverter >> next32BitValue: value toStream: aStream [

	| v1 v2 v3 v4 |
	v1 := (value bitShift: -24) bitAnd: 16rFF.
	v2 := (value bitShift: -16) bitAnd: 16rFF.
	v3 := (value bitShift: -8) bitAnd: 16rFF.
	v4 := (value bitShift: 0) bitAnd: 16rFF.
	useLittleEndian
		ifTrue: [
			aStream 
				basicNextPut: (Character value: v4);
				basicNextPut: (Character value: v3);
				basicNextPut: (Character value: v2);
				basicNextPut: (Character value: v1) ]
		ifFalse: [
			aStream
				basicNextPut: (Character value: v1);
				basicNextPut: (Character value: v2);
				basicNextPut: (Character value: v3);
				basicNextPut: (Character value: v4) ].

]

{ #category : #conversion }
UTF32TextConverter >> nextFromStream: aStream [

	| character1 character2 readBOM charValue character3 character4 |
	aStream isBinary ifTrue: [ ^aStream basicNext ].
	character1 := aStream basicNext ifNil: [ ^nil ].
	character2 := aStream basicNext ifNil: [ ^nil ].
	character3 := aStream basicNext ifNil: [ ^nil ].
	character4 := aStream basicNext ifNil: [ ^nil ].
	
	readBOM := false.
	(character1 asciiValue = 16rFF and: [character2 asciiValue = 16rFE]) ifTrue: [
		self
			useByteOrderMark: true;
			useLittleEndian: true.
		readBOM := true ].
	
	((character1 asciiValue = 0 and: [character2 asciiValue = 0]) 
	and: [character3 asciiValue = 16rFE and: [character4 asciiValue = 16rFF]]) ifTrue: [
		self
			useByteOrderMark: true;
			useLittleEndian: false.
		readBOM := true ].

	readBOM ifTrue: [
		"Re-initialize character variables if they contain BOM"
		character1 := aStream basicNext ifNil: [ ^nil ].
		character2 := aStream basicNext ifNil: [ ^nil ].
		character3 := aStream basicNext ifNil: [ ^nil ].
		character4 := aStream basicNext ifNil: [ ^nil ]. ].

	useLittleEndian 
		ifTrue: [ charValue := (character4 charCode bitShift: 24) + (character3 charCode bitShift: 16) + (character2 charCode bitShift: 8) + character1 charCode ]
		ifFalse: [ charValue := (character1 charCode bitShift: 24) + (character2 charCode bitShift: 16) + (character3 charCode bitShift: 8) + character4 charCode ].

	^ Unicode value: charValue
]

{ #category : #conversion }
UTF32TextConverter >> nextPut: aCharacter toStream: aStream [

	| charCode |
	aStream isBinary ifTrue: [ ^aCharacter storeBinaryOn: aStream ].
	(useByteOrderMark and: [ byteOrderMarkDone not ]) ifTrue: [
		self next32BitValue: 16r0000FEFF toStream: aStream.
		byteOrderMarkDone := true ].
	(charCode := aCharacter charCode) < 256
		ifTrue: [
			(latin1Encodings at: charCode + 1)
				ifNil: [ self next32BitValue: charCode toStream: aStream ]
				ifNotNil: [ :encodedString | aStream basicNextPutAll: encodedString ] ]
		ifFalse: [
			self next32BitValue: charCode toStream: aStream ].
	^aCharacter
]

{ #category : #private }
UTF32TextConverter >> swapLatin1EncodingByteOrder [
	latin1Encodings := latin1Encodings collect: [:each | 
		each ifNotNil: [each reverse]]
]

{ #category : #accessing }
UTF32TextConverter >> useByteOrderMark [

	^useByteOrderMark

]

{ #category : #accessing }
UTF32TextConverter >> useByteOrderMark: aBoolean [

	useByteOrderMark := aBoolean.

]

{ #category : #accessing }
UTF32TextConverter >> useLittleEndian [

	^useLittleEndian

]

{ #category : #accessing }
UTF32TextConverter >> useLittleEndian: aBoolean [

	aBoolean = useLittleEndian ifFalse: [ self swapLatin1EncodingByteOrder ].
	useLittleEndian := aBoolean.

]
