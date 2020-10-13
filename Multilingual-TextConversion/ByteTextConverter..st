"
A ByteTextConverter is a converter for byte-encoded character sets.


"
Class {
	#name : #ByteTextConverter,
	#superclass : #TextConverter,
	#classInstVars : [
		'encodeTable',
		'decodeTable'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #'class initialization' }
ByteTextConverter class >> createTableFrom: anArray [
	
	^ anArray asIntegerArray
]

{ #category : #accessing }
ByteTextConverter class >> decodeTable [
	^decodeTable
]

{ #category : #accessing }
ByteTextConverter class >> encodeTable [
	^encodeTable
]

{ #category : #'class initialization' }
ByteTextConverter class >> initializeDecodeTable [
	"Initialize a table with self Character code + 1 as key (index) and Squeak Character code as value"
	
	^self subclassResponsibility
]

{ #category : #'class initialization' }
ByteTextConverter class >> initializeEncodeTable [
	"Initialize a table with Squeak Character code as key (without leadingChar) and self Character code as value.
	Character code < 128 don't have to be mapped because they have the same encoding (ASCII)."
	
	decodeTable ifNil: [self initializeDecodeTable].
	self assert: decodeTable size = 256.
	encodeTable := Dictionary new.
	decodeTable keysAndValuesDo: [:key :value |
		(value = -1 or: [value = 16rFFFD]) ifFalse: [
			encodeTable at: value put: key - 1]]
]

{ #category : #'class initialization' }
ByteTextConverter class >> initializeLatin1MapAndEncodings [
	"Initialize the latin1Map and latin1Encodings.
	These variables ensure that conversions from latin1 ByteString is reasonably fast.
	This implementation assumes that encodeTable is initialized."
	
	latin1Map := ByteArray new: 256.
	latin1Encodings := Array new: 256.
	0 to: 255 do:[:i |
		| latin1 encoded |
		latin1 := String with: (Character value: i).
		[encoded := String with: (Character value: (self new encode: latin1 first charCode))] 
			ifError: [].
		latin1 = encoded ifTrue:[
			latin1Map at: i+1 put: 0. "no translation needed"
		] ifFalse: [
			latin1Map at: i+1 put: 1. "translation needed"
			latin1Encodings at: i+1 put: encoded.
		]].
]

{ #category : #'class initialization' }
ByteTextConverter class >> initializeTables [

      self == ByteTextConverter ifTrue: [ ^self ].
	self 
		initializeDecodeTable; 
		initializeEncodeTable; 
		initializeLatin1MapAndEncodings

]

{ #category : #conversion }
ByteTextConverter >> backFromStream: aStream [

	aStream position = 0 ifTrue: [ ^nil ].
	aStream isBinary ifTrue: [ ^aStream basicBack ].
	^self toSqueak: aStream basicBack
]

{ #category : #friend }
ByteTextConverter >> currentCharSize [
	^ 1
]

{ #category : #private }
ByteTextConverter >> decode: aByte [
	"Answer a decoded squeak character corresponding to aByte code.
	Note that aByte does necessary span in the range 0...255, since this receiver is a ByteTextEncoder."
	| code |
	((code := self class decodeTable at: 1 + aByte) = -1 or: [code = 16rFFFD]) ifTrue: [^nil].
	^Character value: code
]

{ #category : #private }
ByteTextConverter >> encode: squeakEncodedCharCode [
	"Answer the encoded byte code corresponding to squeakEncodedCharCode.
	Note that the squeakEncodedCharCode does not necessary span in the range 0...255."
	^ self class encodeTable at: squeakEncodedCharCode 
		ifAbsent: [UndefinedConversion signalFor: squeakEncodedCharCode toEncoding: self ]
]

{ #category : #private }
ByteTextConverter >> fromSqueak: char [
	^ Character value: (self encode: char charCode)
]

{ #category : #conversion }
ByteTextConverter >> nextFromStream: aStream [
	| character1 |
	aStream isBinary ifTrue: [^ aStream basicNext].
	character1 := aStream basicNext ifNil: [^ nil].
	^ self toSqueak: character1
]

{ #category : #conversion }
ByteTextConverter >> nextPut: aCharacter toStream: aStream [
	
	| charCode |
	aStream isBinary ifTrue: [ ^aCharacter storeBinaryOn: aStream ].
	(charCode := aCharacter charCode) < 256 
		ifFalse: [ aStream basicNextPut: (Character value: (self encode: charCode)) ]
		ifTrue: [
			(latin1Map at: charCode + 1) = 1 
				ifFalse: [aStream basicNextPut: aCharacter]
				ifTrue: [(latin1Encodings at: charCode + 1)
							ifNil: [ UndefinedConversion signalFor: charCode toEncoding: self]
							ifNotNil: [ :encodedString | aStream basicNextPutAll: encodedString ] ] ].
	^aCharacter
]

{ #category : #private }
ByteTextConverter >> toSqueak: char [
	^self decode: char charCode
]
