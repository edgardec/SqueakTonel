Class {
	#name : #UTF8TextConverterTest,
	#superclass : #TestCase,
	#category : #'MultilingualTests-TextConversion'
}

{ #category : #tests }
UTF8TextConverterTest >> testBasicConversion [
	|converter originalText bytes decodedText |
	originalText := self unicodeString.
	converter := UTF8TextConverter new.
	
	"Default (ie useLittleEndian instvar nil)"
	bytes := (originalText convertToWithConverter: converter).
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
	
]

{ #category : #tests }
UTF8TextConverterTest >> testLazyConversion [
	"Ensure the lazy conversions do what they should"

	| strict result |
	strict := UTF8TextConverter strictUtf8Conversions.
	[UTF8TextConverter strictUtf8Conversions: false.
	result := 'Grüß Gott' utf8ToSqueak.
	] ensure:[UTF8TextConverter strictUtf8Conversions: strict].

	self assert: result = 'Grüß Gott'.

]

{ #category : #tests }
UTF8TextConverterTest >> testSqueakToUtf8 [
	"Ensure proper encoding"

	self assert: '' squeakToUtf8 equals: ''.
	self assert: 'Hello World' squeakToUtf8 equals: 'Hello World'.
	self assert: 'Grüß Gott' squeakToUtf8 asByteArray 
		equals: #[71 114 195 188 195 159 32 71 111 116 116]
]

{ #category : #tests }
UTF8TextConverterTest >> testStrictConversion [
	"Ensure the strict conversions do what they should"

	| strict |
	strict := UTF8TextConverter strictUtf8Conversions.
	[UTF8TextConverter strictUtf8Conversions: true.
	self should:[ 'Grüß Gott' utf8ToSqueak ] raise: Error.
	] ensure:[UTF8TextConverter strictUtf8Conversions: strict].
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8DecodedAscii [
	self assert: 'Hello, world' equals: #[72 101 108 108 111 44 32 119 111 114 108 100] utf8Decoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8DecodedAstralPlane [
	| w |
	w := #[122 230 176 180 240 157 132 158] utf8Decoded.
	"w now contains three codepoints:
		- Unicode Character 'LATIN SMALL LETTER Z' (U+007A)
		- Unicode Han Character 'water, liquid, lotion, juice' (U+6C34)
		- Unicode Character 'MUSICAL SYMBOL G CLEF' (U+1D11E)"
	self assert: 3 equals: w size.
	self assert: 122 equals: (w at: 1) asInteger.
	self assert: 27700 equals: (w at: 2) asInteger.
	self assert: 119070 equals: (w at: 3) asInteger.
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8DecodedEmptyString [
	self assert: '' equals: #[] utf8Decoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8DecodedInvalidSequences [
	"Very simple sanity test. See also class UTF8EdgeCaseTest."
	self should: [#[122 255] utf8Decoded]
		raise: InvalidUTF8
		description: 'Valid UTF-8 never contains byte 255'.

]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8DecodedLatin1 [
	self assert: 'éèç' equals: #[195 169 195 168 195 167] utf8Decoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8DecodedNonLatin1 [
	self assert: 'Ελλάδα' equals: #[206 149 206 187 206 187 206 172 206 180 206 177] utf8Decoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8DecodedNullCharacter [
	self assert: (String with: Character null) equals: #[0] utf8Decoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8EncodedAscii [
	self assert: #[72 101 108 108 111 44 32 119 111 114 108 100]
		equals: 'Hello, world' utf8Encoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8EncodedAstralPlane [
	| w |
	w := WideString from: #(122 27700 119070).
	"w now contains three codepoints:
		- Unicode Character 'LATIN SMALL LETTER Z' (U+007A)
		- Unicode Han Character 'water, liquid, lotion, juice' (U+6C34)
		- Unicode Character 'MUSICAL SYMBOL G CLEF' (U+1D11E)"
	self assert: 3 equals: w size description: 'Expected widestring to contain three codepoints'.
	self assert: 122 equals: (w at: 1) asInteger.
	self assert: 27700 equals: (w at: 2) asInteger.
	self assert: 119070 equals: (w at: 3) asInteger.
	"Now the encoding test:"
	self assert: #[122 230 176 180 240 157 132 158]
		equals: w utf8Encoded
		description: 'Expected correct "astral plane" character encoding'.
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8EncodedEmptyString [
	self assert: #[] equals: '' utf8Encoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8EncodedLatin1 [
	self assert: #[195 169 195 168 195 167] equals: 'éèç' utf8Encoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8EncodedNonLatin1 [
	self assert: #[206 149 206 187 206 187 206 172 206 180 206 177] equals: 'Ελλάδα' utf8Encoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8EncodedNullCharacter [
	self assert: #[0] equals: (String with: Character null) utf8Encoded
]

{ #category : #tests }
UTF8TextConverterTest >> testUtf8ToSqueak [
	"Ensure proper encoding"

	self assert: '' utf8ToSqueak equals: ''.
	self assert: 'Hello World' utf8ToSqueak equals: 'Hello World'.
	self assert: #[71 114 195 188 195 159 32 71 111 116 116] asString utf8ToSqueak
		equals: 'Grüß Gott'


]

{ #category : #fixtures }
UTF8TextConverterTest >> unicodeString [

	^ String newFrom: (#(19335 12403) collect: [:n | Character codePoint: n])
]
