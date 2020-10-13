"
Tests to verify parsing of numbers from streams and strings.

Note: ScaledDecimalTest contains related tests for parsing ScaledDecimal.
"
Class {
	#name : #NumberParsingTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Numbers'
}

{ #category : #'tests - Float' }
NumberParsingTest >> testFloatFromStreamAsNumber [
	"This covers parsing in Number>>readFrom:"

	| rs aFloat |
	rs := '10r-12.3456' readStream.
	aFloat := Number readFrom: rs.
	self assert: -12.3456 = aFloat.
	self assert: rs atEnd.

	rs := '10r-12.3456e2' readStream.
	aFloat := Number readFrom: rs.
	self assert: -1234.56 = aFloat.
	self assert: rs atEnd.

	rs := '10r-12.3456e2e2' readStream.
	aFloat := Number readFrom: rs.
	self assert: -1234.56 = aFloat.
	self assert: rs upToEnd = 'e2'.

	rs := '10r-12.3456d2' readStream.
	aFloat := Number readFrom: rs.
	self assert: -1234.56 = aFloat.
	self assert: rs atEnd.

	rs := '10r-12.3456q2' readStream.
	aFloat := Number readFrom: rs.
	self assert: -1234.56 = aFloat.
	self assert: rs atEnd.

	rs := '-12.3456q2' readStream.
	aFloat := Number readFrom: rs.
	self assert: -1234.56 = aFloat.
	self assert: rs atEnd.

	rs := '12.3456q2' readStream.
	aFloat := Number readFrom: rs.
	self assert: 1234.56 = aFloat.
	self assert: rs atEnd.

	rs := '12.3456z2' readStream.
	aFloat := Number readFrom: rs.
	self assert: 12.3456 = aFloat.
	self assert: rs upToEnd = 'z2'.

]

{ #category : #'tests - Float' }
NumberParsingTest >> testFloatFromStreamWithExponent [
	"This covers parsing in Number>>readFrom:"

	| rs aFloat |
	rs := '1.0e-14' readStream.
	aFloat := Number readFrom: rs.
	self assert: 1.0e-14 = aFloat.
	self assert: rs atEnd.

	rs := '1.0e-14 1' readStream.
	aFloat := Number readFrom: rs.
	self assert: 1.0e-14 = aFloat.
	self assert: rs upToEnd = ' 1'.

	rs := '1.0e-14eee' readStream.
	aFloat := Number readFrom: rs.
	self assert: 1.0e-14 = aFloat.
	self assert: rs upToEnd = 'eee'.

	rs := '1.0e14e10' readStream.
	aFloat := Number readFrom: rs.
	self assert: 1.0e14 = aFloat.
	self assert: rs upToEnd = 'e10'.

	rs := '1.0e+14e' readStream. "Plus sign is parseable too"
	aFloat := Number readFrom: rs.
	self assert: 1.0e14 = aFloat.
	self assert: rs upToEnd = 'e'.

	rs := '1.0e' readStream.
	aFloat := Number readFrom: rs.
	self assert: 1.0 = aFloat.
	self assert: rs upToEnd = 'e'.
]

{ #category : #'tests - Float' }
NumberParsingTest >> testFloatFromStringAsNumber [
	"This covers parsing in Number>>readFrom:"

	| aFloat |
	aFloat := '10r-12.3456' asNumber.
	self assert: -12.3456 = aFloat.
	aFloat := '10r-12.3456e2' asNumber.
	self assert: -1234.56 = aFloat.
	aFloat := '10r-12.3456d2' asNumber.
	self assert: -1234.56 = aFloat.
	aFloat := '10r-12.3456q2' asNumber.
	self assert: -1234.56 = aFloat.
	aFloat := '-12.3456q2' asNumber.
	self assert: -1234.56 = aFloat.
	aFloat := '12.3456q2' asNumber.
	self assert: 1234.56 = aFloat.

]

{ #category : #'tests - Float' }
NumberParsingTest >> testFloatFromStringWithExponent [
	"This covers parsing in Number>>readFrom:"

	| aFloat |
	aFloat := '1.0e-14' asNumber.
	self assert: 1.0e-14 = aFloat.
	aFloat := '1.0e-14 1' asNumber.
	self assert: 1.0e-14 = aFloat.
	aFloat := '1.0e-14e' asNumber.
	self assert: 1.0e-14 = aFloat.
	aFloat := '1.0e14e' asNumber.
	self assert: 1.0e14 = aFloat.
	aFloat := '1.0e+14e' asNumber. "Plus sign is parseable too"
	self assert: 1.0e14 = aFloat.

]

{ #category : #'tests - Float' }
NumberParsingTest >> testFloatReadWithImplicitLeadingZero [
	"Test support for implicit leading zeroes when reading numbers from Strings."
	self should: [-0.22 = '-.22' asNumber].
	self should: [0.22 = '.22' asNumber].

]

{ #category : #'tests - Float' }
NumberParsingTest >> testFloatReadWithRadix [
	"This covers parsing in Number>>readFrom:
	Note: In most Smalltalk dialects, the radix notation is not used for numbers
	with exponents. In Squeak, a string with radix and exponent can be parsed,
	and the exponent is always treated as base 10 (not the base indicated in the
	radix prefix). I am not sure if this is a feature, a bug, or both, but the
	Squeak behavior is documented in this test. -dtl"

	| aNumber rs |
	aNumber := '2r1.0101e9' asNumber.
	self assert: 672.0 = aNumber.
	self assert: (Number readFrom: '2r1.0101e9') = (1.3125 * (2 raisedTo: 9)).
	rs := ReadStream on: '2r1.0101e9e9'.
	self assert: (Number readFrom: rs) = 672.0.
	self assert: rs upToEnd = 'e9'

]

{ #category : #'tests - Float' }
NumberParsingTest >> testFloatmin [
	"Note that these are originally tests cases for former bugs of libc dtoa from netlib.
	ref http://www.exploringbinary.com/gays-strtod-returns-zero-for-inputs-just-above-2-1075/
	ref http://gcc.gnu.org/viewcvs/gcc/trunk/gcc/testsuite/gcc.dg/float-exact-1.c?view=markup&pathrev=205119
	They are also non regression for a bug of NumberParser related to incorrect position of last non zero digit.
	ref https://pharo.fogbugz.com/f/cases/12642/bug-in-NumberParser-when-reading-a-number-with-fraction-part"
	| halfMin moreThanHalfmin |
	halfMin := SqNumberParser parse: (Float fmin asTrueFraction / 2 printShowingDecimalPlaces: 1 - Float fmin exponent).
	self assert: halfMin equals: 0.0 description: 'nearest even of 0.5*Float fmin is zero'.
	moreThanHalfmin := SqNumberParser parse: (Float fmin asTrueFraction / 2 + (10 raisedTo: Float fmin exponent - 4) printShowingDecimalPlaces: 4 - Float fmin exponent).
	self assert: moreThanHalfmin equals: Float fmin description: 'nearest Float of a Fraction > 0.5*Float fmin is Float fmin'.
]

{ #category : #'tests - Integer' }
NumberParsingTest >> testIntegerFromString [
	"This covers parsing in Number>>readFrom:"

	#(
		('123'  123)
		('-123'  -123)
		('123.'  123.0)
		('-123.'  -123.0)
		('123This is not to be read'  123)
		('123s is a ScaledDecimal'  123s0)
		('123sin is not a ScaledDecimal, s could be part of message sin'  123)
		('123e could be confused with a Float' 123)) do: [ :each |
			[ :string :numericValue |
				| result |
				result := string asNumber.
				self assert: result = numericValue.
				self assert: result class = numericValue class] valueWithArguments: each ]

]

{ #category : #'tests - Integer' }
NumberParsingTest >> testIntegerReadFrom [
	"Ensure remaining characters in a stream are not lost when parsing an integer."

	#(
		('13r96 has a radix specification'  123 ' has a radix specification')
		('123r is not a radix specification here'  123 'r is not a radix specification here')
		('-123e has no exponent'  -123 'e has no exponent')
		('-123.e has no exponent'  -123.0 'e has no exponent')
		('-123e2 has an exponent'  -12300 ' has an exponent')
		('123This is not to be read'  123 'This is not to be read')
		('123s is a ScaledDecimal'  123s0 ' is a ScaledDecimal')
		('-123.s is a ScaledDecimal'  -123s0 ' is a ScaledDecimal')
		('123sin is not a ScaledDecimal, s could be part of message sin'  123 'sin is not a ScaledDecimal, s could be part of message sin')
		('123.sin is not a ScaledDecimal, s could be part of message sin'  123.0 'sin is not a ScaledDecimal, s could be part of message sin')
	) do: [ :each |
			[ :string :numericValue :expectedRest |
				| readStream result rest |
				readStream := string readStream.
				result := Number readFrom: readStream.
				rest := readStream upToEnd.
				self assert: result = numericValue.
				self assert: result class = numericValue class.
				self assert: rest = expectedRest] valueWithArguments: each ]

]

{ #category : #'tests - Integer' }
NumberParsingTest >> testIntegerReadWithRadix [
	"This covers parsing in Number>>readFrom:
	Note: In most Smalltalk dialects, the radix notation is not used for numbers
	with exponents. In Squeak, a string with radix and exponent can be parsed,
	and the exponent is always treated as base 10 (not the base indicated in the
	radix prefix). I am not sure if this is a feature, a bug, or both, but the
	Squeak behavior is documented in this test. -dtl"

	| aNumber rs |
	aNumber := '2r1e26' asNumber.
	self assert: 67108864 = aNumber.
	self assert: (Number readFrom: '2r1e26') = (2 raisedTo: 26).
	rs := '2r1e26eee' readStream.
	self assert: (Number readFrom: rs) = 67108864.
	self assert: rs upToEnd = 'eee'

]

{ #category : #'tests - Integer' }
NumberParsingTest >> testNegativeZero [
	"This test ensure that -0.0 will produce a negativeZero"

	| negativeZero |
	negativeZero := Number readFrom: '-0.0' readStream.
	
	"If it is a negative zero, it must behave like a negative zero... IEEE 754 tells how it should behave"
	self deny: (negativeZero at: 1) = 0 description: 'In IEEE 754, a negative zero has its sign bit set to 1'..
	self assert: negativeZero = 0 description: 'In IEEE 754, a negative zero cannot be distinguished from zero'.
]

{ #category : #'tests - ScaledDecimal' }
NumberParsingTest >> testScaledDecimalWithTrailingZeroes [
	"This is a non regression tests for http://bugs.squeak.org/view.php?id=7169"
	
	self assert: (Number readFrom: '0.50s2') = (1/2).
	self assert: (Number readFrom: '0.500s3') = (1/2).
	self assert: (Number readFrom: '0.050s3') = (1/20).
]
