"
This is the unit test for the class Ascii85Converter.
"
Class {
	#name : #Ascii85ConverterTest,
	#superclass : #TestCase,
	#instVars : [
		'decoded',
		'encoded'
	],
	#category : #'CollectionsTests-Streams'
}

{ #category : #accessing }
Ascii85ConverterTest >> decoded [

	^ decoded
]

{ #category : #accessing }
Ascii85ConverterTest >> decoded: anObject [

	decoded := anObject
]

{ #category : #accessing }
Ascii85ConverterTest >> encoded [

	^ encoded
]

{ #category : #accessing }
Ascii85ConverterTest >> encoded: anObject [

	encoded := anObject
]

{ #category : #accessing }
Ascii85ConverterTest >> hackedEncoded [

	^ String streamContents: 
		[:out | | in |
		in := self encoded readStream.
		out
			nextPutAll: (in next: 5);
			cr;
			nextPutAll: (in next: 4);
			space;
			nextPutAll: in upToEnd]

]

{ #category : #running }
Ascii85ConverterTest >> setUp [
	self decoded: 'Hi There!'.
	self encoded: '<~8802GBOu3q+T~>'.
]

{ #category : #tests }
Ascii85ConverterTest >> testAscii85Encoded [
	
	self
		assert: (Ascii85Converter encode: self decoded) contents 
		equals: self decoded ascii85Encoded
		description: 'The convenience method should match the converters output'
	
]

{ #category : #tests }
Ascii85ConverterTest >> testDecode1Zero [
	| bits chars |
	bits := #[0].
	chars := '<~!!~>'.
	self
		assert: bits
		equals: (Ascii85Converter decodeToBytes: chars) contents		
		description: 'Decoding should decode three zeros without squashing'.

]

{ #category : #tests }
Ascii85ConverterTest >> testDecode3Zeros [
	| bits chars |
	bits := #[0 0 0].
	chars := '<~!!!!~>'.
	self
		assert: bits
		equals: (Ascii85Converter decodeToBytes: chars) contents		
		description: 'Decoding should decode three zeros without squashing'.

]

{ #category : #tests }
Ascii85ConverterTest >> testDecode4Zeros [
	| bits chars |
	bits := #[0 0 0 0].
	chars := '<~z~>'.
	self
		assert: bits
		equals: (Ascii85Converter decodeToBytes: chars) contents		
		description: 'Decoding should decode four zeros with squashing'.

]

{ #category : #tests }
Ascii85ConverterTest >> testDecode5Zeros [
	| bits chars |
	bits := #[0 0 0 0 0].
	chars := '<~z!!~>'.
	self
		assert: bits
		equals: (Ascii85Converter decodeToBytes: chars) contents		
		description: 'Decoding should decode five zeros with squashing and a bang'.

]

{ #category : #tests }
Ascii85ConverterTest >> testDecodeEndTooShort [
	| chars |
	chars := '<~z!~>'.
	self
		should: [Ascii85Converter decodeToBytes: chars]
		raise: Error
		description: 'Decoding too short end tuple should raise an error'.
]

{ #category : #tests }
Ascii85ConverterTest >> testDecodeIgnoreFiller [

	self
		assert: self decoded
		equals: self hackedEncoded ascii85Decoded
		description: 'Decoding should ignore linebreaks and spaces'.

]

{ #category : #tests }
Ascii85ConverterTest >> testEncodeDecode [

	| encoded |
	encoded := (Ascii85Converter encode: self decoded) contents.
	self 
		assert: self encoded
		equals: encoded
		description: 'A simple text should be encodable.'.
	self
		assert: self decoded
		equals: (Ascii85Converter decodeToChars: encoded) contents
		description: 'The encoded text decoded should match the original'.

]

{ #category : #tests }
Ascii85ConverterTest >> testEncodeDecodeMultiLine [
	" PLRM page 131:
	It inserts a newline in the encoded output at least once every 80 characters,
	thereby limiting the lengths of lines.
	"
	| aHundred encodedLines |
	aHundred := String new: 100 withAll: $a.
	encodedLines := (Ascii85Converter encode: aHundred) contents lines.
	self
		assert: (encodedLines collect: [:ea | ea size]) max <= 80
		description: 'Encoded long lines should break at max 80 characters'.

]

{ #category : #tests }
Ascii85ConverterTest >> testEncodeDecodeWithZ [
	" PLRM page 131:
	As a special case, if all five digits are 0, they are represented by a single character z
	instead of by !!!!!.
	"
	| bits chars |
	bits := #[40 50 60 0 0 0 0 0 0 0 0 0 0 0 40 50 60].
	chars := '<~-o*mbzz!!"E&49~>'.
	self
		assert: chars
		equals: (Ascii85Converter encode: bits) contents		
		description: 'Encoding should squash five-tuples of 0 to z'.
	self
		assert: chars
		equals: (Ascii85Converter encode: bits asString) contents		
		description: 'Encoding should squash five-tuples of 0 to z'.
	self
		assert: bits
		equals: (Ascii85Converter decodeToBytes: chars) contents		
		description: 'Decoding should unsquash z to five-tuples of 0'.
	self
		assert: bits asString
		equals: (Ascii85Converter decodeToChars: chars) contents		
		description: 'Decoding should unsquash z to five-tuples of 0'.

]

{ #category : #tests }
Ascii85ConverterTest >> testOnByteArray [

	self assert: self encoded equals: self decoded asByteArray ascii85Encoded.
]
