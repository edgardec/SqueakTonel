"
Text converter for UTF-16.  It supports the endianness and byte order mark.
"
Class {
	#name : #UTF16TextConverter,
	#superclass : #TextConverter,
	#instVars : [
		'useLittleEndian',
		'useByteOrderMark',
		'byteOrderMarkDone'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #utilities }
UTF16TextConverter class >> encodingNames [

	^ #('utf-16' 'utf16' 'utf-16-le' 'utf-16-be' 'utf-16be' 'utf-16le') copy.

]

{ #category : #accessing }
UTF16TextConverter class >> initializeLatin1MapAndEncodings [
	"Initialize the latin1Map and latin1Encodings.
	These variables ensure that conversions from latin1 ByteString is reasonably fast."
	
	latin1Map := ByteArray new: 256 withAll: 1.
	latin1Encodings := (0 to: 255) collect: [ :i | { 0. i } asByteArray asString ]
]

{ #category : #private }
UTF16TextConverter >> charFromStream: aStream withFirst: firstValue [

	| character1 character2 n secondValue |
	(16rD800 <= firstValue and: [firstValue <= 16rDBFF]) ifFalse: [
		^Unicode value: firstValue ].
	character1 := aStream basicNext ifNil: [ ^nil ].
	character2 := aStream basicNext ifNil: [ ^nil ].
	useLittleEndian ifTrue: [
		| tmp |
		tmp := character1.
		character1 := character2.
		character2 := tmp ].
	secondValue := (character1 charCode bitShift: 8) + character2 charCode.
	n := firstValue - 16rD800 * 16r400 + (secondValue - 16rDC00) + 16r10000.
	^Unicode value: n
]

{ #category : #'initialize-release' }
UTF16TextConverter >> initialize [

	super initialize.
	useLittleEndian := useByteOrderMark := byteOrderMarkDone := false
]

{ #category : #private }
UTF16TextConverter >> next16BitValue: value toStream: aStream [

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

{ #category : #conversion }
UTF16TextConverter >> nextFromStream: aStream [

	| character1 character2 readBOM charValue |
	aStream isBinary ifTrue: [ ^aStream basicNext ].
	character1 := aStream basicNext ifNil: [ ^nil ].
	character2 := aStream basicNext ifNil: [ ^nil ].
	
	readBOM := false.
	(character1 asciiValue = 16rFF and: [character2 asciiValue = 16rFE]) ifTrue: [
		self
			useByteOrderMark: true;
			useLittleEndian: true.
		readBOM := true ].
	(character1 asciiValue = 16rFE and: [character2 asciiValue = 16rFF]) ifTrue: [
		self
			useByteOrderMark: true;
			useLittleEndian: false.
		readBOM := true ].

	readBOM ifTrue: [
		character1 := aStream basicNext ifNil: [ ^nil ].
		character2 := aStream basicNext ifNil: [ ^nil ] ].

	useLittleEndian 
		ifTrue: [ charValue := (character2 charCode bitShift: 8) + character1 charCode ]
		ifFalse: [ charValue := (character1 charCode bitShift: 8) + character2 charCode ].

	^ self charFromStream: aStream withFirst: charValue
]

{ #category : #conversion }
UTF16TextConverter >> nextPut: aCharacter toStream: aStream [

	| charCode |
	aStream isBinary ifTrue: [ ^aCharacter storeBinaryOn: aStream ].
	(useByteOrderMark and: [ byteOrderMarkDone not ]) ifTrue: [
		self next16BitValue: (useLittleEndian ifTrue: [ 16rFFFE ] ifFalse: [ 16rFEFF ]) toStream: aStream.
		byteOrderMarkDone := true ].
	(charCode := aCharacter charCode) < 256
		ifTrue: [
			(latin1Encodings at: charCode + 1)
				ifNil: [ self next16BitValue: charCode toStream: aStream ]
				ifNotNil: [ :encodedString | aStream basicNextPutAll: encodedString ] ]
		ifFalse: [
			charCode <= 16rFFFF
				ifTrue: [ self next16BitValue: charCode toStream: aStream ]
				ifFalse: [
					| low high |
					charCode := charCode - 16r10000.
					low := charCode \\ 16r400 + 16rDC00.
					high := charCode // 16r400 + 16rD800.
					self
						next16BitValue: high toStream: aStream;
						next16BitValue: low toStream: aStream ] ].
	^aCharacter
]

{ #category : #private }
UTF16TextConverter >> swapLatin1EncodingByteOrder [
	latin1Encodings := latin1Encodings collect: [:each | each reverse]
]

{ #category : #accessing }
UTF16TextConverter >> useByteOrderMark [

	^useByteOrderMark

]

{ #category : #accessing }
UTF16TextConverter >> useByteOrderMark: aBoolean [

	useByteOrderMark := aBoolean.

]

{ #category : #accessing }
UTF16TextConverter >> useLittleEndian [

	^useLittleEndian

]

{ #category : #accessing }
UTF16TextConverter >> useLittleEndian: aBoolean [

	aBoolean = useLittleEndian ifFalse: [ self swapLatin1EncodingByteOrder ].
	useLittleEndian := aBoolean.

]
