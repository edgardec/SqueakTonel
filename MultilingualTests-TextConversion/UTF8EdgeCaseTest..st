"
I am a suite of test cases based on ""UTF-8 decoder capability and stress test"" by Markus Kuhn <http://www.cl.cam.ac.uk/~mgk25/> of 2015-08-28, licensed CC BY 4.0.

The document my tests were extracted from can be found at https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt

"
Class {
	#name : #UTF8EdgeCaseTest,
	#superclass : #TestCase,
	#category : #'MultilingualTests-TextConversion'
}

{ #category : #tests }
UTF8EdgeCaseTest >> expectBytesToFailDecoding: aByteArray [
	self should: [aByteArray utf8Decoded] raise: InvalidUTF8
]

{ #category : #tests }
UTF8EdgeCaseTest >> expectHex: aString toDecodeToCodepoint: anInteger [
	self expectHex: aString toDecodeToCodepoints: { anInteger }

]

{ #category : #tests }
UTF8EdgeCaseTest >> expectHex: aString toDecodeToCodepoints: anArray [ 
	| s |
	s := (ByteArray readHexFrom: aString) utf8Decoded.
	self assert: anArray size equals: s size.
	self assert: anArray asArray equals: (s asArray collect: [:c | c asInteger]).
]

{ #category : #tests }
UTF8EdgeCaseTest >> expectHexToFailDecoding: aString [ 
	self should: [(ByteArray readHexFrom: aString) utf8Decoded] raise: InvalidUTF8.

]

{ #category : #failures }
UTF8EdgeCaseTest >> expectedFailures [

	^ #(testMaximumOverlongSequences testOverlongAsciiSequences 
		testOverlongNUL testOverlongNUL testPairedUTF16Surrogates testSingleUTF16Surrogates)
]

{ #category : #tests }
UTF8EdgeCaseTest >> testConcatenationOfIncompleteSequences [
	"Concatenation of incomplete sequences"
	self expectHexToFailDecoding: 'c0e080'. "Should fail between the c0 and the e0"
	"(similar omitted)"
]

{ #category : #tests }
UTF8EdgeCaseTest >> testFirstPossibleSequenceOfACertainLength [
	"First possible sequence of a certain length"
	self expectHex: '00' toDecodeToCodepoint: 0.
	self expectHex: 'c280' toDecodeToCodepoint: 16r80.
	self expectHex: 'e0a080' toDecodeToCodepoint: 16r800.
	self expectHex: 'f0908080' toDecodeToCodepoint: 16r10000.
	"self expectHex: 'f888808080' toDecodeToCodepoint: 16r200000." "Codepoint is out of range."
	"self expectHex: 'fc8480808080' toDecodeToCodepoint: 16r4000000." "Codepoint is out of range."
]

{ #category : #tests }
UTF8EdgeCaseTest >> testImpossibleBytes [
	"Impossible bytes"
	self expectHexToFailDecoding: 'fe'.
	self expectHexToFailDecoding: 'ff'.
	self expectHexToFailDecoding: 'fefeffff'.
]

{ #category : #tests }
UTF8EdgeCaseTest >> testLastPossibleSequenceOfACertainLength [
	self expectHex: '7f' toDecodeToCodepoint: 16r7f.
	self expectHex: 'dfbf' toDecodeToCodepoint: 16r7ff.
	self expectHex: 'efbfbf' toDecodeToCodepoint: 16rffff.
	self expectHex: 'f7bfbfbf' toDecodeToCodepoint: 16r1fffff.
	"self expectHex: 'fbbfbfbfbf' toDecodeToCodepoint: 16r3ffffff." "Codepoint is out of range."
	"self expectHex: 'fdbfbfbfbfbf' toDecodeToCodepoint: 16r7fffffff." "Codepoint is out of range."

]

{ #category : #tests }
UTF8EdgeCaseTest >> testLonelyStartCharacters [
	"Lonely start characters"
	"
		All 32 first bytes of 2-byte sequences (0xc0-0xdf),
		All 16 first bytes of 3-byte sequences (0xe0-0xef),
		All 8 first bytes of 4-byte sequences (0xf0-0xf7),
		All 4 first bytes of 5-byte sequences (0xf8-0xfb),
		All 2 first bytes of 6-byte sequences (0xfc-0xfd),
		... each followed by a space character
	"
	(16rc0 to: 16rfd) do: [:i | self expectBytesToFailDecoding: (ByteArray with: i with: 32)].

]

{ #category : #tests }
UTF8EdgeCaseTest >> testMaximumOverlongSequences [
	"Maximum overlong sequences"
	self expectHexToFailDecoding: 'c1bf'.
	self expectHexToFailDecoding: 'e09fbf'.
	self expectHexToFailDecoding: 'f08fbfbf'.
	self expectHexToFailDecoding: 'f887bfbfbf'.
	self expectHexToFailDecoding: 'fc83bfbfbfbf'.

]

{ #category : #tests }
UTF8EdgeCaseTest >> testNoncharacterCodePositions [
	"Noncharacter code positions"
	self expectHex: 'efbfbe' toDecodeToCodepoint: 16rfffe.
	self expectHex: 'efbfbf' toDecodeToCodepoint: 16rffff.
	self expectHex: 'efb790efb791efb792efb793efb794efb795efb796efb797efb798efb799efb79aefb79befb79cefb79defb79eefb79fefb7a0efb7a1efb7a2efb7a3efb7a4efb7a5efb7a6efb7a7efb7a8efb7a9efb7aaefb7abefb7acefb7adefb7aeefb7af'
		toDecodeToCodepoints: ((16rFDD0 to: 16rFDEF) asArray).
	self expectHex: 'f09fbfbef09fbfbff0afbfbef0afbfbff0bfbfbef0bfbfbff18fbfbef18fbfbff19fbfbef19fbfbff1afbfbef1afbfbff1bfbfbef1bfbfbff28fbfbef28fbfbff29fbfbef29fbfbff2afbfbef2afbfbff2bfbfbef2bfbfbff38fbfbef38fbfbff39fbfbef39fbfbff3afbfbef3afbfbff3bfbfbef3bfbfbff48fbfbef48fbfbf'
		toDecodeToCodepoints: ([ | a |
			a := OrderedCollection new.
			(1 to: 16r10) do: [:n |
				a add: n * 16r10000 + 16rFFFE.
				a add: n * 16r10000 + 16rFFFF].
			a] value).

]

{ #category : #tests }
UTF8EdgeCaseTest >> testOtherBoundaryConditions [
	"Other boundary conditions"
	self expectHex: 'ed9fbf' toDecodeToCodepoint: 16rd7ff.
	self expectHex: 'ee8080' toDecodeToCodepoint: 16re000.
	self expectHex: 'efbfbd' toDecodeToCodepoint: 16rfffd. "REPLACEMENT CHARACTER"
	self expectHex: 'f48fbfbf' toDecodeToCodepoint: 16r10ffff. "Last valid code point (happens to be a NONCHARACTER)"
	self expectHex: 'f4908080' toDecodeToCodepoint: 16r110000. "First number beyond valid code point space"
]

{ #category : #tests }
UTF8EdgeCaseTest >> testOverlongAsciiSequences [
	"Overlong sequences"
	"ASCII 2F"
	self expectHexToFailDecoding: 'c0af'.
	self expectHexToFailDecoding: 'e080af'.
	self expectHexToFailDecoding: 'f08080af'.
	self expectHexToFailDecoding: 'f8808080af'.
	self expectHexToFailDecoding: 'fc80808080af'.

]

{ #category : #tests }
UTF8EdgeCaseTest >> testOverlongNUL [
	"Overlong representation of the NUL character"
	self expectHexToFailDecoding: 'c080'.
	self expectHexToFailDecoding: 'e08080'.
	self expectHexToFailDecoding: 'f0808080'.
	self expectHexToFailDecoding: 'f880808080'.
	self expectHexToFailDecoding: 'fc8080808080'.

]

{ #category : #tests }
UTF8EdgeCaseTest >> testPairedUTF16Surrogates [
	"Illegal code positions"
	"Paired UTF-16 surrogates"
	self expectHexToFailDecoding: 'eda080edb080'.
	self expectHexToFailDecoding: 'eda080edbfbf'.
	self expectHexToFailDecoding: 'edadbfedb080'.
	self expectHexToFailDecoding: 'edadbfedbfbf'.
	self expectHexToFailDecoding: 'edae80edb080'.
	self expectHexToFailDecoding: 'edae80edbfbf'.
	self expectHexToFailDecoding: 'edafbfedb080'.
	self expectHexToFailDecoding: 'edafbfedbfbf'.

]

{ #category : #tests }
UTF8EdgeCaseTest >> testSequencesWithLastContinuationByteMissing [
	"Sequences with last continuation byte missing"

	self expectHexToFailDecoding: 'c0'. "U+0000"
	self expectHexToFailDecoding: 'e080'. "U+0000"
	self expectHexToFailDecoding: 'f08080'. "U+0000"
	self expectHexToFailDecoding: 'f8808080'. "U+0000"
	self expectHexToFailDecoding: 'fc80808080'. "U+0000"

	self expectHexToFailDecoding: 'df'. "U+07FF"
	self expectHexToFailDecoding: 'efbf'. "U+FFFF"
	self expectHexToFailDecoding: 'f7bfbf'. "U+1FFFFF"
	self expectHexToFailDecoding: 'fbbfbfbf'. "U+3FFFFFF"
	self expectHexToFailDecoding: 'fdbfbfbfbf'. "U+7FFFFFFF"

	"Additional tests not in Kuhn's document, testing for presence of off-by-two errors:"

	self expectHexToFailDecoding: 'e0'. "U+0000"
	self expectHexToFailDecoding: 'f080'. "U+0000"
	self expectHexToFailDecoding: 'f88080'. "U+0000"
	self expectHexToFailDecoding: 'fc808080'. "U+0000"

	self expectHexToFailDecoding: 'ef'. "U+FFFF"
	self expectHexToFailDecoding: 'f7bf'. "U+1FFFFF"
	self expectHexToFailDecoding: 'fbbfbf'. "U+3FFFFFF"
	self expectHexToFailDecoding: 'fdbfbfbf'. "U+7FFFFFFF"

]

{ #category : #tests }
UTF8EdgeCaseTest >> testSingleUTF16Surrogates [
	"Illegal code positions"
	"Single UTF-16 surrogates"
	self expectHexToFailDecoding: 'eda080'.
	self expectHexToFailDecoding: 'edadbf'.
	self expectHexToFailDecoding: 'edae80'.
	self expectHexToFailDecoding: 'edafbf'.
	self expectHexToFailDecoding: 'edb080'.
	self expectHexToFailDecoding: 'edbe80'.
	self expectHexToFailDecoding: 'edbfbf'.

]

{ #category : #tests }
UTF8EdgeCaseTest >> testUnexpectedContinuationBytes [
	"Unexpected continuation bytes"
	self expectHexToFailDecoding: '80'. "First continuation byte"
	self expectHexToFailDecoding: 'bf'. "Last continuation byte"
	self expectHexToFailDecoding: '80bf'. "Two continuation bytes"
	self expectHexToFailDecoding: '80bf80'. "Three continuation bytes"
	self expectHexToFailDecoding: '80bf80bf'. "Four continuation bytes"
	self expectHexToFailDecoding: '80bf80bf80'. "Five continuation bytes"
	self expectHexToFailDecoding: '80bf80bf80bf'. "Six continuation bytes"
	self expectHexToFailDecoding: '80bf80bf80bf80'. "Seven continuation bytes"
	"(Skipping 'sequence of all 64 possible continuation bytes (0x80-0xbf)')"
]
