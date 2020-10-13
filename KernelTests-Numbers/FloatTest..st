"
I provide a test suite for Float values. Examine my tests to see how Floats should behave, and see how to use them.
"
Class {
	#name : #FloatTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'exactInteger',
		'float',
		'greaterInexactInt',
		'smallerInexactInt',
		'greaterFloat',
		'smallerFloat',
		'boxedFloat',
		'greaterBoxedFloat',
		'smallerBoxedFloat'
	],
	#category : #'KernelTests-Numbers'
}

{ #category : #asserting }
FloatTest >> assertIsNegativeZero: aFloat [
	"Assert that aFloat is Float negativeZero"
	self assert: aFloat = 0.0.
	self assert: aFloat signBit = 1
]

{ #category : #asserting }
FloatTest >> assertIsPositiveZero: aFloat [
	"Assert that aFloat is Float zero (the positive one)"
	self assert: aFloat = 0.0.
	self assert: aFloat signBit = 0
]

{ #category : #running }
FloatTest >> setUp [
	exactInteger := 1 << (Float precision + 2).
	float := exactInteger asFloat.
	greaterInexactInt := exactInteger + 1.
	smallerInexactInt := exactInteger - 1.
	greaterFloat := float successor.
	smallerFloat := float predecessor.
	
	boxedFloat := Float new: 2.
	boxedFloat basicAt: 1 put: (float basicAt: 1).
	boxedFloat basicAt: 2 put: (float basicAt: 2).
	greaterBoxedFloat := Float new: 2.
	greaterBoxedFloat basicAt: 1 put: (greaterFloat basicAt: 1).
	greaterBoxedFloat basicAt: 2 put: (greaterFloat basicAt: 2).
	smallerBoxedFloat := Float new: 2.
	smallerBoxedFloat basicAt: 1 put: (smallerFloat basicAt: 1).
	smallerBoxedFloat basicAt: 2 put: (smallerFloat basicAt: 2).
]

{ #category : #'tests - IEEE 754' }
FloatTest >> test32bitConversion [
	"Except for NaN, we can convert a 32bits float to a 64bits float exactly.
	Thus we can convert the 64bits float to the original 32bits float pattern."
	
	#(16r0 "zero"
	 16r80000000 "negative zero"
	 16r1 "min unormalized"
	 16r12345 "a unnormalized"
	 16r801FEDCB "a negative unnormalized"
	 16r7FFFFF "largest unnormalized"
	 16r800000 "smallest normalized"
	 16r468ACDEF "a normalized float"
	 16rCABD1234 "a negative normalized float"
	 16r7F7FFFFF "largest finite float"
	 16r7F800000 "positive infinity"
	 16rFF800000 "negative infinity"
	)
	  do: [:originalWord | self assert: (Float fromIEEE32Bit: originalWord) asIEEE32BitWord = originalWord]
]

{ #category : #'tests - IEEE 754' }
FloatTest >> test32bitGradualUnderflow [
	"method asIEEE32BitWord did not respect IEEE gradual underflow"
	
	| conv expected exponentPart |
	
	"IEEE 32 bits Float have 1 bit sign/8 bit exponent/23 bits of mantissa after leading 1
	2r1.mmmmmmmmmmmmmmmmmmmmmmm * (2 raisedTo: 2reeeeeeee-127) * sign
	except when 2reeeeeeee isZero, which is a gradual underflow:
	2r0.mmmmmmmmmmmmmmmmmmmmmmm * (2 raisedTo: 2r00000000-126) * sign
	and when 2reeeeeeee = 255, which is infinity if mantissa all zero or nan otherwise"
	
	"case 1: This example is the first gradual underflow case"
	conv := 2r0.11111111111111111111111e-126 asIEEE32BitWord.
	
	"expected float encoded as sign/exponent/mantissa (whithout leading 1 or 0)"
	exponentPart := 0.
	expected := exponentPart bitOr: 2r11111111111111111111111.
	self assert: expected = conv.
	
	"case 2: smallest number"
	conv := 2r0.00000000000000000000001e-126 asIEEE32BitWord.
	expected := exponentPart bitOr: 2r1.
	self assert: expected = conv.
	
	"case 3: round to nearest even also in underflow cases... here round to upper"
	conv := 2r0.000000000000000000000011e-126 asIEEE32BitWord.
	expected := exponentPart bitOr: 2r10.
	self assert: expected = conv.
	
	"case 4: round to nearest even also in underflow cases... here round to lower"
	conv := 2r0.000000000000000000000101e-126 asIEEE32BitWord.
	expected := exponentPart bitOr: 2r10.
	self assert: expected = conv.
	
	"case 5: round to nearest even also in underflow cases... here round to upper"
	conv := 2r0.0000000000000000000001011e-126 asIEEE32BitWord.
	expected := exponentPart bitOr: 2r11.
	self assert: expected = conv.
	
]

{ #category : #'tests - IEEE 754' }
FloatTest >> test32bitRoundingMode [
	"method asIEEE32BitWord did not respect IEEE default rounding mode"
	
	| conv expected exponentPart |
	
	"IEEE 32 bits Float have 1 bit sign/8 bit exponent/23 bits of mantissa after leading 1
	2r1.mmmmmmmmmmmmmmmmmmmmmmm * (2 raisedTo: 2reeeeeeee-127) * sign
	except when 2reeeeeeee isZero, which is a gradual underflow:
	2r0.mmmmmmmmmmmmmmmmmmmmmmm * (2 raisedTo: 2r00000000-127) * sign
	and when 2reeeeeeee = 255, which is infinity if mantissa all zero or nan otherwise"
	
	"This example has two extra bits in mantissa for testing rounding mode
	case 1: should obviously round to upper"
	conv := 2r1.0000000000000000000000111e25 asIEEE32BitWord.
	
	"expected float encoded as sign/exponent/mantissa (whithout leading 1)"
	exponentPart := 25+127 bitShift: 23. "127 is 2r01111111 or 16r7F"
	expected := exponentPart bitOr: 2r10.
	self assert: expected = conv.
	
	"case 2: exactly in the mid point of two 32 bit float: round toward nearest even (to upper)"
	conv := 2r1.0000000000000000000000110e25 asIEEE32BitWord.
	expected := exponentPart bitOr: 2r10.
	self assert: expected = conv.
	
	"case 3: exactly in the mid point of two 32 bit float: round toward nearest even (to lower)"
	conv := 2r1.0000000000000000000000010e25 asIEEE32BitWord.
	expected := exponentPart bitOr: 2r0.
	self assert: expected = conv.
	
	"case 4: obviously round to upper"
	conv := 2r1.0000000000000000000000011e25 asIEEE32BitWord.
	expected := exponentPart bitOr: 2r1.
	self assert: expected = conv.

]

{ #category : #'tests - mathematical functions' }
FloatTest >> testArCosh [
	self assert: 1.0 arCosh = 0.0.
	self deny: Float infinity arCosh isFinite.
	self assert: (2.5 arCosh cosh closeTo: 2.5).
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testArSinh [
	self assertIsPositiveZero: 0.0 arSinh.
	self assertIsNegativeZero: Float negativeZero arSinh.
	self deny: Float infinity arSinh isFinite.
	self assert: (0.5 arSinh negated closeTo: 0.5 negated arSinh).
	self assert: (0.5 arSinh sinh closeTo: 0.5).
	self assert: (-2.5 arSinh sinh closeTo: -2.5).
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testArTanh [
	self assertIsPositiveZero: 0.0 arTanh.
	self assertIsNegativeZero: Float negativeZero arTanh.
	self deny: 1 arTanh isFinite.
	self assert: (0.5 arTanh negated closeTo: 0.5 negated arTanh).
	self assert: (0.5 arTanh tanh closeTo: 0.5).
	self assert: (-0.5 arTanh tanh closeTo: -0.5).
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testArcTan [

	self assert: ((100 arcTan: 100) closeTo: Float pi / 4).
	self assert: ((-100 arcTan: 100) closeTo: Float pi / -4).
	self assert: ((100 arcTan: -100) closeTo: Float pi * 3 / 4).
	self assert: ((-100 arcTan: -100) closeTo: Float pi * -3 / 4).
	self assert: ((0 arcTan: 100) closeTo: 0).
	self assert: ((0 arcTan: -100) closeTo: Float pi).
	self assert: ((100 arcTan: 0) closeTo: Float pi / 2).
	self assert: ((-100 arcTan: 0) closeTo: Float pi / -2).
	
	self assert: ((Float negativeZero arcTan: 100) closeTo: 0).
	self assert: ((Float negativeZero arcTan: -100) closeTo: Float pi * -1).
	
	self assert: (0 arcTan: 0) = 0.
	self assert: (Float negativeZero arcTan: 0) = 0.
	self assert: ((0 arcTan: Float negativeZero) closeTo: Float pi).
	self assert: ((Float negativeZero arcTan: Float negativeZero) closeTo: Float pi negated). 
]

{ #category : #'tests - conversion' }
FloatTest >> testCeiling [
	self assert: 1.0 ceiling = 1.
	self assert: 1.1 ceiling = 2.
	self assert: -2.0 ceiling = -2.
	self assert: -2.1 ceiling = -2.
]

{ #category : #'tests - characterization' }
FloatTest >> testCharacterization [

	"Test the largest finite representable floating point value"
	self assert: Float fmax successor = Float infinity.
	self assert: Float infinity predecessor = Float fmax.
	self assert: Float fmax negated predecessor = Float negativeInfinity.
	self assert: Float negativeInfinity successor = Float fmax negated.
	
	"Test the smallest positive representable floating point value"
	self assert: Float fmin predecessor = 0.0.
	self assert: 0.0 successor = Float fmin.
	self assert: Float fmin negated successor = 0.0.
	self assert: 0.0 predecessor = Float fmin negated.
	
	"Test the relative precision"
	self assert: Float one + Float epsilon > Float one.
	self assert: Float one + Float epsilon = Float one successor.
	self assert: Float one + (Float epsilon / Float radix) = Float one.
	
	"Test maximum and minimum exponent"
	self assert: Float fmax exponent = Float emax.
	self assert: Float fminNormalized exponent = Float emin.
	Float denormalized ifTrue: [
		self assert: Float fminDenormalized exponent = (Float emin + 1 - Float precision)].
	
	"Alternative tests for maximum and minimum"
	self assert: (Float radix - Float epsilon) * (Float radix raisedTo: Float emax) = Float fmax.
	self assert: Float epsilon * (Float radix raisedTo: Float emin) = Float fmin.
	
	"Test sucessors and predecessors"
	self assert: Float one predecessor successor = Float one.
	self assert: Float one successor predecessor = Float one.
	self assert: Float one negated predecessor successor = Float one negated.
	self assert: Float one negated successor predecessor = Float one negated.
	self assert: Float infinity successor = Float infinity.
	self assert: Float negativeInfinity predecessor = Float negativeInfinity.
	self assertIsNegativeZero: Float fmin negated successor.
	self assert: Float nan predecessor isNaN.
	self assert: Float nan successor isNaN.
	
	"SPECIFIC FOR IEEE 754 double precision - 64 bits"
	self assert: Float fmax hex = '7FEFFFFFFFFFFFFF'.
	self assert: Float fminDenormalized hex = '0000000000000001'.
	self assert: Float fminNormalized hex = '0010000000000000'.
	self assert: 0.0 hex = '0000000000000000'.
	self assert: Float negativeZero hex = '8000000000000000'.
	self assert: Float one hex = '3FF0000000000000'.
	self assert: Float infinity hex = '7FF0000000000000'.
	self assert: Float negativeInfinity hex = 'FFF0000000000000'.
]

{ #category : #'tests - compare' }
FloatTest >> testCloseTo [
	self deny: (Float nan closeTo: Float nan) description: 'NaN isn''t close to anything'.
	self deny: (Float nan closeTo: 1.0) description: 'NaN isn''t close to anything'.
	self deny: (1.0 closeTo: Float nan) description: 'NaN isn''t close to anything'.
	
	self deny: (-1.0 closeTo: 1.0).
	self deny: (1.0 closeTo: Float infinity).
	self assert: (Float infinity closeTo: Float infinity) description: 'since they are =, they also are closeTo:'.
	
	self assert: (1.0/3.0 closeTo: 1/3).
	self assert: (1.0e-8 closeTo: 0).
	self assert: (0 closeTo: 1.0e-8).
	self assert: (1+1.0e-8 closeTo: 1.0).
	
	self assert: (1000000001.0 closeTo: 1000000000.0).
	self deny: (1000000001 closeTo: 1000000000) description: 'exact representation are considered closeTo: only if equal'.
]

{ #category : #'tests - compare' }
FloatTest >> testCloseToFurthestCloseToNeasrest [
	| x nearest furthest |
	x := 1.0e-6.
	nearest := 1.0e-7.
	furthest := 0.0.
	self assert: (x - nearest) abs < (x - furthest) abs.
	self assert: (x closeTo: furthest) ==> (x closeTo: nearest)
]

{ #category : #'tests - compare' }
FloatTest >> testCloseToIsSymmetric [
	self assert: ((1<<2000) reciprocal closeTo: 1.0e-6) equals: (1.0e-6 closeTo: (1<<2000) reciprocal)
]

{ #category : #'tests - compare' }
FloatTest >> testComparison [
	
	"test equality when Float conversion loose bits"
	| a b c |
	a := 16r1FFFFFFFFFFFFF1.
	b := 16r1FFFFFFFFFFFFF3.
	c := a asFloat.
	self assert: ((a = c) & (b = c)) ==> (a = b).
	
	"Test equality when Float conversion exact"
	self assert: 16r1FFFFFFFFFFFFF = 16r1FFFFFFFFFFFFF asFloat.
	self assert: 16r1FFFFFFFFFFFFF = 16r1FFFFFFFFFFFFF asFloat asInteger.
	
	"Test inequality when Float conversion loose bits"
	self assert: (((1 bitShift: 54)+1)/(1 bitShift: 54)) > 1.
	self assert: (((1 bitShift: 54)+1)/(1 bitShift: 54)) > 1.0.
	
	self assert: (((1 bitShift: 54)-1)/(1 bitShift: 54)) < 1.
	self assert: (((1 bitShift: 54)-1)/(1 bitShift: 54)) < 1.0.
	
	"Test exact vs inexact arithmetic"
	(1 to: 100) do: [:i |
		i isPowerOfTwo
			ifTrue: [self assert: (1/i) = (1/i) asFloat]
			ifFalse: [self deny: (1/i) = (1/i) asFloat]].
	
	"Test overflow (compare to infinity)"
	a := (11 raisedTo: 400) / 2.
	b := (13 raisedTo: 400) / 2.
	c := a asFloat.
	self assert: ((a = c) & (b = c)) ==> (a = b).
	
	"every integer is smaller than infinity"
	self assert: a < Float infinity.
	self assert: a > Float negativeInfinity.
	
	"Test underflow"
	self deny: 1 / (11 raisedTo: 400) = 0.
	self deny: 1 / (11 raisedTo: 400) = 0.0.
	
	"Test hash code"
	self assert:
		((Set new: 3) add: 3; add: 3.0; size) =
		((Set new: 4) add: 3; add: 3.0; size).
]

{ #category : #'tests - compare' }
FloatTest >> testComparisonSmallFromBoxed [
	"Comparison should work the same, boxed or not"
	
	self assert: boxedFloat = float.
	self deny: boxedFloat ~= float.
	self deny: boxedFloat = smallerFloat.
	self assert: boxedFloat ~= greaterFloat.
	
	self assert: boxedFloat < greaterFloat.
	self assert: boxedFloat <= greaterFloat.
	self deny: boxedFloat > greaterFloat.
	self deny: boxedFloat >= greaterFloat.
	
	self deny: boxedFloat < smallerFloat.
	self deny: boxedFloat <= smallerFloat.
	self assert: boxedFloat > smallerFloat.
	self assert: boxedFloat >= smallerFloat.
]

{ #category : #'tests - compare' }
FloatTest >> testComparisonSmallWithBoxed [
	"Comparison should work the same, boxed or not"
	
	self assert: float = boxedFloat.
	self deny: float ~= boxedFloat.
	self deny: float = smallerBoxedFloat.
	self assert: float ~= greaterBoxedFloat.
	
	self assert: float < greaterBoxedFloat.
	self assert: float <= greaterBoxedFloat.
	self deny: float > greaterBoxedFloat.
	self deny: float >= greaterBoxedFloat.
	
	self deny: float < smallerBoxedFloat.
	self deny: float <= smallerBoxedFloat.
	self assert: float > smallerBoxedFloat.
	self assert: float >= smallerBoxedFloat.
]

{ #category : #'tests - compare' }
FloatTest >> testComparisonWhenPrimitiveFails [
	"This is related to http://bugs.squeak.org/view.php?id=7361"

	self deny: 0.5 < (1/4).
	self deny: 0.5 < (1/2).
	self assert: 0.5 < (3/4).
	
	self deny: 0.5 <= (1/4).
	self assert: 0.5 <= (1/2).
	self assert: 0.5 <= (3/4).
	
	self assert: 0.5 > (1/4).
	self deny: 0.5 > (1/2).
	self deny: 0.5 > (3/4).
	
	self assert: 0.5 >= (1/4).
	self assert: 0.5 >= (1/2).
	self deny: 0.5 >= (3/4).
	
	self deny: 0.5 = (1/4).
	self assert: 0.5 = (1/2).
	self deny: 0.5 = (3/4).
	
	self assert: 0.5 ~= (1/4).
	self deny: 0.5 ~= (1/2).
	self assert: 0.5 ~= (3/4).
]

{ #category : #'tests - arithmetic' }
FloatTest >> testContinuedFractions [
	self assert: (Float pi asApproximateFractionAtOrder: 1) = (22/7).
	self assert: (Float pi asApproximateFractionAtOrder: 3) = (355/113)
]

{ #category : #tests }
FloatTest >> testCopy [
	"Elementary tests"
	self assert: 2.0 copy = 2.0.
	self assert: -0.5 copy = -0.5.
	
	"Are exceptional Floats preserved by the copy ?"
	self assert: Float nan copy isNaN.
	self assert: Float infinity copy = Float infinity.
	self assert: Float negativeInfinity copy = Float negativeInfinity.
	
	"Is the sign of zero preserved by the copy ?"
	self assert: 0.0 copy hex = 0.0 hex.
	self assert: Float negativeZero copy hex = Float negativeZero hex.
]

{ #category : #'tests - zero behavior' }
FloatTest >> testCopySign [
	self assert: (0.0 copySignTo: 1) = 1.
	self assert: (Float negativeZero copySignTo: 1) = -1.
	self assertIsNegativeZero: (-1 copySignTo: 0.0).
	self assertIsPositiveZero: (1 copySignTo: Float negativeZero).
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testCosh [
	self assert: (0.0 cosh closeTo: 1).
	self deny: Float infinity cosh isFinite.
	self assert: (2.0 cosh squared - 2.0 sinh squared closeTo: 1).
	self assert: (2.0 cosh closeTo: 2.0 negated cosh).
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testDegreeCos [	
	"Following tests use approximate equality, because cosine are generally evaluated using inexact Floating point arithmetic"
	self assert: (45.0 degreeCos squared - 0.5) abs <= Float epsilon.
	self assert: (60.0 degreeCos - 0.5) abs <= Float epsilon.
	self assert: (120.0 degreeCos + 0.5) abs <= Float epsilon.
	-360.0 to: 360.0 do: [:i |
		self assert: (i degreeCos closeTo: i degreesToRadians cos)].
	
	"Following tests use strict equality which is a requested property of degreeCos"
	-10.0 to: 10.0 do: [:k |
		self assert: (k*360 + 90) degreeCos = 0.
		self assert: (k*360 - 90) degreeCos = 0.
		self assert: (k*360 + 180) degreeCos + 1 = 0.
		self assert: (k*360) degreeCos - 1 = 0.].
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testDegreeCosForExceptionalValues [
	self assert: Float nan degreeCos isNaN.
	self assert: Float infinity degreeCos isNaN.
	self assert: Float negativeInfinity degreeCos isNaN.
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testDegreeSin [	
	"Following tests use approximate equality, because sine are generally evaluated using inexact Floating point arithmetic"
	self assert: (45.0 degreeSin squared - 0.5) abs <= Float epsilon.
	self assert: (30.0 degreeSin - 0.5) abs <= Float epsilon.
	self assert: (-30.0 degreeSin + 0.5) abs <= Float epsilon.
	-360.0 to: 360.0 do: [:i |
		self assert: (i degreeSin closeTo: i degreesToRadians sin)].
	
	"Following tests use strict equality which is a requested property of degreeSin"
	-10.0 to: 10.0 do: [:k |
		self assert: (k*360 + 90) degreeSin - 1 = 0.
		self assert: (k*360 - 90) degreeSin + 1= 0.
		self assert: (k*360 + 180) degreeSin = 0.
		self assert: (k*360) degreeSin = 0.].
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testDegreeSinForExceptionalValues [
	self assert: Float nan degreeSin isNaN.
	self assert: Float infinity degreeSin isNaN.
	self assert: Float negativeInfinity degreeSin isNaN.
]

{ #category : #'tests - arithmetic' }
FloatTest >> testDivide [

	self assert: 1.5 / 2.0 = 0.75.
	
	self assert: 2.0 / 1 = 2.0.
	
	self should: [ 2.0 / 0 ] raise: ZeroDivide.
	self should: [ 2.0 / 0.0 ] raise: ZeroDivide.
	self should: [ 1.2 / Float negativeZero ] raise: ZeroDivide.
	self should: [ 1.2 / (1.3 - 1.3) ] raise: ZeroDivide
	
]

{ #category : #'tests - compare' }
FloatTest >> testExactComparisonFromSmallInt [
	"Those tests works when using naive (integer asFloat = float) comparison.
	This is because the conversion asFloat are exact."
	
	{float. boxedFloat} do: [:f |
		self assert: exactInteger = f.
		self deny: exactInteger ~= f.
		self assert: exactInteger <= f.
		self deny: exactInteger < f.
		self assert: exactInteger >= f.
		self deny: exactInteger > f].
	
	{greaterFloat. greaterBoxedFloat} do: [:f |
		self deny: exactInteger = f.
		self assert: exactInteger ~= f.
		self assert: exactInteger <= f.
		self assert: exactInteger < f.
		self deny: exactInteger >= f.
		self deny: exactInteger > f].
		
	{smallerFloat. smallerBoxedFloat} do: [:f |
		self deny: exactInteger = f.
		self assert: exactInteger ~= f.
		self deny: exactInteger <= f.
		self deny: exactInteger < f.
		self assert: exactInteger >= f.
		self assert: exactInteger > f].
]

{ #category : #'tests - compare' }
FloatTest >> testExactComparisonWithSmallInt [
	"Those tests works when using naive (integer asFloat = float) comparison.
	This is because the conversion asFloat are exact."
	
	{float. boxedFloat} do: [:f |
		self assert: f = exactInteger.
		self deny: f ~= exactInteger.
		self assert: f <= exactInteger.
		self deny: f < exactInteger.
		self assert: f >= exactInteger.
		self deny: f > exactInteger].
	
	{greaterFloat. greaterBoxedFloat} do: [:f |
		self deny: f = exactInteger.
		self assert: f ~= exactInteger.
		self deny: f <= exactInteger.
		self deny: f < exactInteger.
		self assert: f >= exactInteger.
		self assert: f > exactInteger].
		
	{smallerFloat. smallerBoxedFloat} do: [:f |
		self deny: f = exactInteger.
		self assert: f ~= exactInteger.
		self assert: f <= exactInteger.
		self assert: f < exactInteger.
		self deny: f >= exactInteger.
		self deny: f > exactInteger].
]

{ #category : #'tests - conversion' }
FloatTest >> testFloatRounded [
	"5000000000000001 asFloat has an exact representation (no round off error).
	It should round to nearest integer without loosing bits.
	This is a no regression test on http://bugs.squeak.org/view.php?id=7134"
	
	| x y int r |
	
	"This is a preamble asserting exactness of representation
	and quality of various conversions"
	int := 5000000000000001.
	x := int asFloat.
	y := (5 asFloat squared squared squared squared timesTwoPower: 15) + 1.
	self assert: x = y.
	self assert: x asTrueFraction = int.
	
	"this one should be true for any float
	in order to conform to ISO/IEC 10967-2"
	self assert: x rounded = x asTrueFraction rounded.
	self assert: x negated rounded = x negated asTrueFraction rounded.

	"a random test"
	r := Random new.
	10000 timesRepeat: [
		x := r next * 1.9999e16 + 1.0e12 .
		self assert: x rounded = x asTrueFraction rounded.
		self assert: x negated rounded = x negated asTrueFraction rounded]
]

{ #category : #'tests - conversion' }
FloatTest >> testFloatTruncated [
	"(10 raisedTo: 16) asFloat has an exact representation (no round off error).
	It should convert back to integer without loosing bits.
	This is a no regression test on http://bugs.impara.de/view.php?id=3504"
	
	| x y int r |
	int := 10 raisedTo: 16.
	x := int asFloat.
	y := (5 raisedTo: 16) asFloat timesTwoPower: 16.
	self assert: x = y.
	
	self assert: x asInteger = int.
	
	"this one should be true for any float"
	self assert: x asInteger = x asTrueFraction asInteger.

	"a random test"
	r := Random new.
	10000 timesRepeat: [
		x := r next * 1.9999e16 + 1.0e12 .
		self assert: x truncated = x asTrueFraction truncated].
	
	"test an edge case (see https://github.com/OpenSmalltalk/opensmalltalk-vm/issues/376)"
	self assert: SmallInteger maxVal + 1 equals: (SmallInteger maxVal + 1) asFloat asInteger
]

{ #category : #'tests - conversion' }
FloatTest >> testFloor [
	self assert: 1.0 floor = 1.
	self assert: 1.1 floor = 1.
	self assert: -2.0 floor = -2.
	self assert: -2.1 floor = -3.
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testFloorLog2 [
	"Float internal representation of Float being in base 2, we expect (aFloat floorLog: 2) to be exact."
	
	| aBitLess aBitMore |
	aBitMore := 1 + Float epsilon.
	aBitLess := 1 - Float epsilon.
	Float emin + 1 to: Float emax - 1 do: [:exp |
		| exactPowerOfTwo |
		exactPowerOfTwo := 1.0 timesTwoPower: exp.
		self assert: (exactPowerOfTwo floorLog: 2) equals: exp.
		self assert: (exactPowerOfTwo * aBitMore floorLog: 2) equals: exp.
		self assert: (exactPowerOfTwo * aBitLess floorLog: 2) equals: exp - 1].
]

{ #category : #'tests - conversion' }
FloatTest >> testFractionAsExactFloat [
	{
		1/2.
		1<<Float precision - 1 / (1 << 8).
		Float fminNormalized asFraction.
		Float fmin asFraction * 3.
		Float fmin asFraction.
	}
		do: [:f | self assert: f asExactFloat equals: f asFloat]
]

{ #category : #'tests - conversion' }
FloatTest >> testFractionAsFloat [
	"use a random test"
	
	| r m frac err collec |
	r := Random new seed: 1234567.
	m := (2 raisedTo: 54) - 1.
	200 timesRepeat: [
		frac := ((r nextInt: m) * (r nextInt: m) + 1) / ((r nextInt: m) * (r nextInt: m) + 1).
		err := (frac - frac asFloat asTrueFraction) * frac reciprocal * (1 bitShift: 52).
		self assert: err < (1/2)].
	
	collec := #(16r10000000000000 16r1FFFFFFFFFFFFF 1 2 16r20000000000000 16r20000000000001 16r3FFFFFFFFFFFFF 16r3FFFFFFFFFFFFE 16r3FFFFFFFFFFFFD).
	collec do: [:num |
		collec do: [:den |
			frac := Fraction numerator: num denominator: den.
			err := (frac - frac asFloat asTrueFraction) * frac reciprocal * (1 bitShift: 52).
			self assert: err <= (1/2)]].
]

{ #category : #'tests - conversion' }
FloatTest >> testFractionAsFloat2 [
	"test rounding to nearest even"
		
	self assert: ((1<<52)+0+(1/4)) asFloat asTrueFraction = ((1<<52)+0).
	self assert: ((1<<52)+0+(1/2)) asFloat asTrueFraction = ((1<<52)+0).
	self assert: ((1<<52)+0+(3/4)) asFloat asTrueFraction = ((1<<52)+1).
	self assert: ((1<<52)+1+(1/4)) asFloat asTrueFraction = ((1<<52)+1).
	self assert: ((1<<52)+1+(1/2)) asFloat asTrueFraction = ((1<<52)+2).
	self assert: ((1<<52)+1+(3/4)) asFloat asTrueFraction = ((1<<52)+2).
]

{ #category : #'tests - conversion' }
FloatTest >> testFractionAsFloatWithUnderflow [
	"test rounding to nearest even"

	| underflowPower |
	underflowPower := Float emin - Float precision.
	self assert: (2 raisedTo: underflowPower) asFloat = 0.0.	
	self assert: (2 raisedTo: underflowPower) negated asFloat = 0.0.
	self assert: (2 raisedTo: underflowPower) negated asFloat signBit = 1 description: 'a negative underflow should return a negative zero'.
]

{ #category : #'tests - conversion' }
FloatTest >> testFractionIsAnExactFloat [
	self assert: (1/2) isAnExactFloat.
	self assert: (1<<Float precision - 1 / (1 << 8)) isAnExactFloat.
	self assert: (Float fmin asFraction * 3) isAnExactFloat.
	self assert: Float fmin asFraction isAnExactFloat.
	self deny: (Float fmin asFraction / 2) isAnExactFloat.
	self deny: (Float fmin asFraction * 3 / 2) isAnExactFloat.
	self deny: (1 / 3) isAnExactFloat.
	self deny: (1<<Float precision + 1 / 2) isAnExactFloat.
]

{ #category : #'tests - infinity behavior' }
FloatTest >> testHugeIntegerCloseTo [
	"This is a test for bug http://bugs.squeak.org/view.php?id=7368"
	
 	"FloatTest new testHugeIntegerCloseTo"

	self deny: (1.0 closeTo: 200 factorial).
	self deny: (200 factorial closeTo: 1.0).
	self assert: (Float infinity closeTo: 200 factorial) = (200 factorial closeTo: Float infinity).
]

{ #category : #'tests - compare' }
FloatTest >> testInexactComparisonFromSmallInt [
	"Those tests would fail if using naive (integer asFloat = float) comparison.
	This is because the conversion asFloat are inexact and loose bits."
	
	{float. boxedFloat} do: [:f |
		self deny: smallerInexactInt = f.
		self assert: greaterInexactInt ~= f.
	
		self assert: greaterInexactInt > f.
		self deny: greaterInexactInt <= f.
		self assert: smallerInexactInt < f.
		self deny: smallerInexactInt >= f].
]

{ #category : #'tests - compare' }
FloatTest >> testInexactComparisonOKFromSmallInt [
	"asFloat conversion is monotonic:
	intA < intB ==> (intA asFloat <= intB asFloat).
	Thus those tests would work if using naive (integer asFloat op: float) comparison,
	even if asFloat conversion is inexact."
	
	{greaterFloat . greaterBoxedFloat} do: [:f |
		self deny: smallerInexactInt = f.
		self assert: smallerInexactInt ~= f.
	
		self assert: smallerInexactInt < f.
		self assert: smallerInexactInt <= f.
		self deny: smallerInexactInt > f.
		self deny: smallerInexactInt >= f].
]

{ #category : #'tests - compare' }
FloatTest >> testInexactComparisonOKWithSmallInt [
	"asFloat conversion is monotonic:
	intA < intB ==> (intA asFloat <= intB asFloat).
	Thus those tests would work if using naive (integer asFloat op: float) comparison,
	even if asFloat conversion is inexact."
	
	{smallerFloat . smallerBoxedFloat} do: [:f |
		self deny: f = greaterInexactInt.
		self assert: f ~= greaterInexactInt.
	
		self assert: f < greaterInexactInt.
		self assert: f <= greaterInexactInt.
		self deny: f > greaterInexactInt.
		self deny: f >= greaterInexactInt].
]

{ #category : #'tests - compare' }
FloatTest >> testInexactComparisonWithSmallInt [
	"Those tests would fail if using naive (integer asFloat = float) comparison.
	This is because the conversion asFloat are inexact and loose bits."
	
	{float. boxedFloat} do: [:f |
		self deny: f = greaterInexactInt.
		self assert: f ~= smallerInexactInt.
	
		self assert: f < greaterInexactInt.
		self deny: f >= greaterInexactInt.
		self assert: f > smallerInexactInt.
		self deny: f <= smallerInexactInt].
]

{ #category : #'tests - infinity behavior' }
FloatTest >> testInfinity1 [
   "FloatTest new testInfinity1"

	| i1  i2 |

	i1 := 10000 exp.
	i2 := 1000000000 exp.
	self assert: i1 isInfinite & i2 isInfinite & (i1 = i2).
	"All infinities are equal. (This is a very substantial difference to NaN's, which are never equal."

]

{ #category : #'tests - infinity behavior' }
FloatTest >> testInfinity2 [
   "FloatTest new testInfinity2"

	| i1  i2 |
	i1 := 10000 exp.
	i2 := 1000000000 exp.
	i2 := 0 - i2. " this is entirely ok. You can compute with infinite values."

	self assert: i1 isInfinite & i2 isInfinite & i1 positive & i2 negative.
	self deny: i1 = i2.
  	"All infinities are signed. Negative infinity is not equal to Infinity"

]

{ #category : #'tests - IEEE 754' }
FloatTest >> testInfinity3 [
	self assert: (Float negativeInfinity asIEEE32BitWord printPaddedWith: $0 to: 32 base: 2) =
		'11111111100000000000000000000000'.
	self assert: (Float fromIEEE32Bit:
		(Integer readFrom: '11111111100000000000000000000000' readStream base: 2))
			= Float negativeInfinity
]

{ #category : #'tests - infinity behavior' }
FloatTest >> testInfinityCloseTo [
	"This is a test for bug http://bugs.squeak.org/view.php?id=6729:"
	
 	"FloatTest new testInfinityCloseTo"

	self deny: (Float infinity closeTo: Float negativeInfinity).
	self deny: (Float negativeInfinity closeTo: Float infinity).
]

{ #category : #'tests - conversion' }
FloatTest >> testIntegerAsFloat [
	"assert IEEE 754 round to nearest even mode is honoured"
	
	self deny: 16r1FFFFFFFFFFFF0801 asFloat = 16r1FFFFFFFFFFFF0800 asFloat. "this test is on 65 bits"
	self deny: 16r1FFFFFFFFFFFF0802 asFloat = 16r1FFFFFFFFFFFF0800 asFloat. "this test is on 64 bits"
	self assert: 16r1FFFFFFFFFFF1F800 asFloat = 16r1FFFFFFFFFFF20000 asFloat. "nearest even is upper"
	self assert: 16r1FFFFFFFFFFFF0800 asFloat = 16r1FFFFFFFFFFFF0000 asFloat. "nearest even is lower"

]

{ #category : #'tests - zero behavior' }
FloatTest >> testIsZero [
	self assert: 0.0 isZero.
	self assert: Float negativeZero isZero.
	self deny:  0.1 isZero.
]

{ #category : #'tests - conversion' }
FloatTest >> testLargeIntegerIsAnExactFloat [
	self assert: Float fmax asInteger isAnExactFloat.
	self deny: (Float fmax asInteger + (Float fmax ulp / 2) asInteger) isAnExactFloat.
	self deny: (Float fmax asInteger * 2) isAnExactFloat
]

{ #category : #'tests - conversion' }
FloatTest >> testLargeNegativeIntegerAsFloat [
	"assert IEEE 754 round to nearest even mode is honoured"
	
	self assert: SmallInteger minVal asFloat negative.
	self assert: SmallInteger minVal isAnExactFloat description: 'this test requires this condition. If not met, change the test'.
	self assert: SmallInteger minVal equals: SmallInteger minVal asFloat. "this test requires integrity of negative SmallInteger asFloat"
	self assert: SmallInteger minVal asFloat - 1.0 equals: (SmallInteger minVal - 1) asFloat "same for LargeNegativeInteger"
	
]

{ #category : #'tests - compare' }
FloatTest >> testLiteralEqualityOfNan [
	| nan |
	nan := Float nan.
	self assert: (nan literalEqual: nan)
		description: 'Float nan is not equal to itself, though it is literally equal'.
]

{ #category : #'tests - compare' }
FloatTest >> testLiteralEqualityOfZeroAndNegativeZero [
	self assert: 1
		equals: (Compiler evaluate: '1>2 ifTrue: [0.0] ifFalse: [-0.0]') signBit
		description: 'Float zero and negativeZero are not literally substituable'.
]

{ #category : #tests }
FloatTest >> testMaxExactInteger [
	"
	FloatTest new testMaxExactInteger
	"

	self assert: Float maxExactInteger asFloat truncated = Float maxExactInteger.
	0 to: 10000 do: [ :j |
		self assert: (Float maxExactInteger-j) asFloat truncated = (Float maxExactInteger-j) ].
	self deny: (Float maxExactInteger+1) asFloat truncated = (Float maxExactInteger+1)
	
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN1 [
   	"FloatTest new testNaN1"

	self assert: Float nan == Float nan.
	self deny: Float nan = Float nan.
	"a NaN is not equal to itself."

]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN2 [
	"Two NaN values are always considered to be different.
	On an little-endian machine (32 bit Intel), Float nan is 16rFFF80000 16r00000000.
	On a big-endian machine (PowerPC), Float nan is 16r7FF80000 16r00000000. Changing
	the bit pattern of the first word of a NaN produces another value that is still
	considered equal to NaN. This test should work on both little endian and big
	endian machines. However, it is not guaranteed to work on future 64 bit versions
	of Squeak, for which Float may have different internal representations."

	"FloatTest new testNaN2"

	| nan1 nan2 |
	nan1 := Float nan copy.
	nan2 := Float nan copy.

	"test two instances of NaN with the same bit pattern"
	self deny: nan1 = nan2.
	self deny: nan1 == nan2.
	self deny: nan1 = nan1.
	self assert: nan1 == nan1.

	"change the bit pattern of nan1"
	self assert: nan1 size = 2.
	self assert: (nan1 at: 2) = 0.
	nan1 at: 1 put: (nan1 at: 1) + 999.
	self assert: nan1 isNaN.
	self assert: nan2 isNaN.
	self deny: (nan1 at: 1) = (nan2 at: 1).

	"test two instances of NaN with different bit patterns"
	self deny: nan1 = nan2.
	self deny: nan1 == nan2.
	self deny: nan1 = nan1.
	self assert: nan1 == nan1

]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN3 [
   "FloatTest new testNaN3"

   	| set item identitySet |
	set := Set new.
	set add: (item := Float nan).
	self deny: (set includes: item).
	identitySet := IdentitySet new.
	identitySet add: (item := Float nan).
	self assert: (identitySet includes: item).
	"as a NaN is not equal to itself, it can not be retrieved from a set"

]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN4 [
   	"FloatTest new testNaN4"

	| dict |
	dict := Dictionary new.
	dict at: Float nan put: #NaN.
	self deny: (dict includes: Float nan).
	"as a NaN is not equal to itself, it can not be retrieved when it is used as a dictionary key"

]

{ #category : #'tests - IEEE 754' }
FloatTest >> testNaN5 [
	| nanstr |
	
	"check the NaN string representation conforms to IEEE 754"
	nanstr := Float nan asIEEE32BitWord printPaddedWith: $0 to: 32 base: 2.
	self
		assert: (#($0 $1) includes: (nanstr at: 1));
		assert: (nanstr copyFrom: 2 to: 9) = '11111111';
		assert: (#($0 $1) includes: (nanstr at: 10)); "accept both quiet and signalled NaNs"
		assert: ((nanstr copyFrom: 11 to: 32) reject: [ :c | #($0 $1) includes: c ]) isEmpty.
	
	"check a correct quiet NaN is created from a string"
	self assert: (Float fromIEEE32Bit:
		(Integer readFrom: '01111111110000000000000000000000' readStream base: 2)) isNaN
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaNCompare [
	"IEEE 754 states that NaN cannot be ordered.
	As a consequence, every arithmetic comparison involving a NaN SHOULD return false.
	Except the is different test (~=).
	This test does verify this rule"
	
	| compareSelectors theNaN anotherNaN comparand brokenMethods warningMessage |
	compareSelectors := #(#< #<= #> #>= #=).
	theNaN := Float nan.
	anotherNaN := Float infinity - Float infinity.
	comparand := {1. 2.3. Float infinity. 2/3. 1.25s2. 2 raisedTo: 50}.
	comparand := comparand , (comparand collect: [:e | e negated]).
	comparand := comparand , {theNaN. anotherNaN}.

"do a first pass to collect all broken methods"
	brokenMethods := Set new.
	comparand do: [:comp |
		compareSelectors do: [:op |
			(theNaN perform: op with: comp) ifTrue: [brokenMethods add: (theNaN class lookupSelector: op)].
			(comp perform: op with: theNaN) ifTrue: [brokenMethods add: (comp class lookupSelector: op)]].
		(theNaN ~= comp) ifFalse: [brokenMethods add: (theNaN class lookupSelector: #~=)].
		(comp ~= theNaN) ifFalse: [brokenMethods add: (comp class lookupSelector: #~=)]].
	
"build a warning message to tell about all broken methods at once"
	warningMessage := String streamContents: [:s |
			s nextPutAll: 'According to IEEE 754 comparing with a NaN should always return false, except ~= that should return true.'; cr.
			s nextPutAll: 'All these methods failed to do so. They are either broken or call a broken one'.
			brokenMethods do: [:e | s cr; print: e methodClass; nextPutAll: '>>'; print: e selector]].
		
"Redo the tests so as to eventually open a debugger on one of the failures"
	brokenMethods := Set new.
	comparand do: [:comp2 |
		compareSelectors do: [:op2 |
			self deny: (theNaN perform: op2 with: comp2) description: warningMessage.
			self deny: (comp2 perform: op2 with: theNaN) description: warningMessage].
		self assert: (theNaN ~= comp2) description: warningMessage.
		self assert: (comp2 ~= theNaN) description: warningMessage].
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaNisLiteral [
	self deny: Float nan isLiteral description: 'there is no literal representation of NaN'
]

{ #category : #'tests - zero behavior' }
FloatTest >> testNegativeZeroAbs [
	self assert: Float negativeZero abs signBit = 0 description: 'the absolute value of a negative zero is zero'
]

{ #category : #'tests - zero behavior' }
FloatTest >> testNegativeZeroSign [
	self assert: Float negativeZero sign = 0.
	self assert: Float negativeZero signBit = 1 "That's how we can distinguish from positive zero"
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testNthRoot [
	"
	FloatTest new testNthRoot
	"
	self should: [ -1.23 nthRoot: 4 ] raise: ArithmeticError
]

{ #category : #'tests - printing' }
FloatTest >> testPrintPaddedWithTo [
	"This bug was reported in http://lists.gforge.inria.fr/pipermail/pharo-users/2011-February/001569.html.
	The problem was caused by treating the format specifier as a number rather than
	as a string, such the the number may be a Float subject to floating point rounding
	errors. The solution to treat the format specifier as a string, and extract the integer
	fields before and after the decimal point in the string."

	self assert: [(1.0 printPaddedWith: $0 to: 2.2) = '01.00'].
	self assert: [(1.0 printPaddedWith: $X to: 2.2) = 'X1.0X'].
	self assert: [(1.0 printPaddedWith: $0 to: 2) = '01.0'].
	self assert: [(12345.6789 printPaddedWith: $0 to: 2) = '12345.6789'].
	self assert: [(12345.6789 printPaddedWith: $0 to: 2.2) = '12345.6789'].
	self assert: [(12.34 printPaddedWith: $0 to: 2.2) = '12.34'].
	self assert: [(12345.6789 printPaddedWith: $0 to: 2.2) = '12345.6789'].
	self assert: [(123.456 printPaddedWith: $X to: 4.4) = 'X123.456X'].
	self assert: [(1.0 printPaddedWith: $0 to: 2.1) = '01.0'].
	self assert: [(1.0 printPaddedWith: $0 to: 2.2) = '01.00'].
	self assert: [(1.0 printPaddedWith: $0 to: 2.3) = '01.000']. "previously failed due to float usage"
	self assert: [(1.0 printPaddedWith: $0 to: 2.4) = '01.0000']. "previously failed due to float usage"
	self assert: [(1.0 printPaddedWith: $0 to: 2.5) = '01.00000']


]

{ #category : #'tests - mathematical functions' }
FloatTest >> testRaisedTo [
	"
	FloatTest new testRaisedTo
	"
	self should: [ -1.23 raisedTo: 1/4 ] raise: ArithmeticError
]

{ #category : #'tests - conversion' }
FloatTest >> testReadFromManyDigits [
	"A naive algorithm may interpret these representations as Infinity or NaN.
	This is http://bugs.squeak.org/view.php?id=6982"
	
	| s1 s2 |
	s1 := '1' , (String new: 321 withAll: $0) , '.0e-321'.
	s2 := '0.' , (String new: 320 withAll: $0) , '1e321'.
	self assert: (Number readFrom: s1) = 1.
	self assert: (Number readFrom: s2) = 1.
]

{ #category : #'tests - arithmetic' }
FloatTest >> testReciprocal [

	self 
		assert: 1.0 reciprocal = 1.0;
		assert: 2.0 reciprocal = 0.5;
		assert: -1.0 reciprocal = -1.0;
		assert: -2.0 reciprocal = -0.5.
		
	self should: [ 0.0 reciprocal ] raise: ZeroDivide
]

{ #category : #'tests - conversion' }
FloatTest >> testRounded [
	self assert: 0.9 rounded = 1.
	self assert: 1.0 rounded = 1.
	self assert: 1.1 rounded = 1.
	self assert: -1.9 rounded = -2.
	self assert: -2.0 rounded = -2.
	self assert: -2.1 rounded = -2.
	
	"In case of tie, round to upper magnitude"
	self assert: 1.5 rounded = 2.
	self assert: -1.5 rounded = -2.
]

{ #category : #tests }
FloatTest >> testSetOfFloat [
	"Classical disagreement between hash and = did lead to a bug.
	This is a non regression test from http://bugs.squeak.org/view.php?id=3360"

	| size3 size4 |
	size3 := (Set new: 3) add: 3; add: 3.0; size.
	size4 := (Set new: 4) add: 3; add: 3.0; size.
	self assert: size3 = size4 description: 'The size of a Set should not depend on its capacity.'
]

{ #category : #tests }
FloatTest >> testSign [

	"Set up"
	| negatives negz positives strictNegatives strictPositives zero |
	strictPositives := {2. 2.5. Float infinity}.
	strictNegatives := {-3. -3.25. Float negativeInfinity}.
	zero := 0.0.
	negz := Float negativeZero.
	positives := strictPositives copyWith: zero.
	negatives := strictNegatives copyWith: negz.
	
	"The sign of non zeros"
	strictPositives do: [:aPositive | self assert: aPositive sign = 1].
	strictNegatives do: [:aNegative | self assert: aNegative sign = -1].
	
	"The sign of zeros"
	self assert: zero sign = 0.
	self assert: negz sign = 0. "remark that negz can't be distinguished from zero and is thus considered positive..."
	self assert: negz signBit = 1. "but we can differentiate"
	
	"Test the copy sign functions"
	positives do: [:aPositiveSign |
		positives do: [:aPositive | 
			self assert: (aPositive sign: aPositiveSign) = aPositive].
		negatives do: [:aNegative | 
			self assert: (aNegative sign: aPositiveSign) = aNegative negated].
		(zero sign: aPositiveSign) signBit = 0.
		(negz sign: aPositiveSign) signBit = 0].
	
	negatives do: [:aNegativeSign |
		positives do: [:aPositive | 
			self assert: (aPositive sign: aNegativeSign) = aPositive negated].
		negatives do: [:aNegative | 
			self assert: (aNegative sign: aNegativeSign) = aNegative].
		(zero sign: aNegativeSign) signBit = 1.
		(negz sign: aNegativeSign) signBit = 1].
]

{ #category : #'tests - characterization' }
FloatTest >> testSignificandAndExponent [
	| denormals exceptionals normals |
	
	normals := {Float pi. Float pi * 100.0. Float pi/ -100.0. Float fmax. Float fminNormalized}.
	denormals := {0.0. Float negativeZero. Float fminNormalized predecessor. Float fmin negated}.
	exceptionals := {Float nan. Float infinity. Float negativeInfinity.}.
	
	normals , denormals , exceptionals do: [:aFloat |
		"Any Float can be decomposed into its significand and exponent, and the significand holds the sign"
		aFloat isNaN
			ifTrue: [self assert: (aFloat significand timesTwoPower: aFloat exponent) isNaN]
			ifFalse: [self
				assert: (aFloat significand timesTwoPower: aFloat exponent)
				equals: aFloat]].
	
	normals , denormals do: [:aFloat |
		"The significand magnitude is in interval [1.0,2.0( "
		aFloat = 0.0
			ifTrue: [self assert: aFloat significand equals: 0]
			ifFalse: [self
				assert: aFloat significand abs >= 1.0;
				assert: aFloat significand abs < 2.0]]
]

{ #category : #'tests - characterization' }
FloatTest >> testSignificandAsInteger [
	| mantissaBits denormalPowersOfTwo denormals exceptionals normalPowersOfTwo normals |
	"There are 52 bits used for representing the mantissa (plus an eventual leading 1, see below)"
	mantissaBits := Float precision - 1.
	
	normals := {Float pi. Float pi * 100.0. Float pi/ -100.0. Float fmax. Float fminNormalized}.
	denormals := {0.0. Float negativeZero. Float fminNormalized predecessor. Float fmin negated}.
	exceptionals := {Float nan. Float infinity. Float negativeInfinity.}.
	normalPowersOfTwo := (-10 to: 10) collect: [:i | 1.0 timesTwoPower: i].
	denormalPowersOfTwo := (Float emin - mantissaBits to: Float emin - 1) collect: [:i | 1.0 timesTwoPower: i].
	
	normals do: [:aNormalFloat |
		"Assume the mantissa is written in least 52 bits of hex format, with an implied 1 on position 53"
		self
			assert: (((Integer readFrom: aNormalFloat hex base: 16) bitAnd: 1<<mantissaBits-1) bitOr: 1<<mantissaBits)
			equals: aNormalFloat significandAsInteger].
	
	denormals , exceptionals do: [:aDenormalOrExceptionalFloat |
		"For every other Float, zero, denormal or exceptional, no implied leading one"
		self
			assert: ((Integer readFrom: aDenormalOrExceptionalFloat hex base: 16) bitAnd: 1<<mantissaBits-1)
			equals: aDenormalOrExceptionalFloat significandAsInteger].

	normalPowersOfTwo do: [:aNormalPowerOfTwoFloat |
		"The significand of a power of two is a power of two, with high bit of expected precision"
		self assert: aNormalPowerOfTwoFloat significandAsInteger isPowerOfTwo.
		self assert: aNormalPowerOfTwoFloat significandAsInteger highBit equals: Float precision.
		self assert: aNormalPowerOfTwoFloat successor significandAsInteger equals: aNormalPowerOfTwoFloat significandAsInteger + 1.
		"The last one is not true for fminNormalized"
		aNormalPowerOfTwoFloat = Float fminNormalized or: [
			self assert: aNormalPowerOfTwoFloat predecessor significandAsInteger equals: aNormalPowerOfTwoFloat significandAsInteger * 2 - 1]].
	
	denormalPowersOfTwo do: [:aDenormalPowerOfTwoFloat |
		"The significand of a denormal power of two is a power of two, just with less bits"
		self assert: aDenormalPowerOfTwoFloat significandAsInteger isPowerOfTwo.
		self assert: aDenormalPowerOfTwoFloat significandAsInteger highBit equals: Float precision + aDenormalPowerOfTwoFloat exponent - Float emin.
		aDenormalPowerOfTwoFloat successor = Float fminNormalized or: [
			self assert: aDenormalPowerOfTwoFloat successor significandAsInteger equals: aDenormalPowerOfTwoFloat significandAsInteger + 1].
		self assert: aDenormalPowerOfTwoFloat predecessor significandAsInteger equals: aDenormalPowerOfTwoFloat significandAsInteger - 1.].
	
	"Well known value for a few extremal cases"
	self assert: Float fmax significandAsInteger equals: 1 << Float precision - 1.
	self assert: Float fmin significandAsInteger equals: 1.
	self assert: 0.0 significandAsInteger equals: 0.
	self assert: Float infinity significandAsInteger equals: 0.
	self assert: Float nan significandAsInteger > 0
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testSinh [
	self assertIsPositiveZero: 0.0 sinh.
	self assertIsNegativeZero: Float negativeZero sinh.
	self deny: Float infinity sinh isFinite.
	self assert: (2.0 cosh squared - 2.0 sinh squared closeTo: 1).
	self assert: (2.0 sinh negated closeTo: 2.0 negated sinh).
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testSqrtFallback [
	| fallBackMethod |
	fallBackMethod := Float>>#sqrt.
	{Float fmin. Float fmin * 2.0. Float fmin * 63.0. Float fmax. Float fmax predecessor predecessor.
	1.0. 2.0. 3.0. 4.0. 5.0}
		do: [:f |
			| s sm sp |
			"check against the primitives - if they are absent, it does not test anything..."
			s := fallBackMethod valueWithReceiver: f arguments: Array new.
			self assert: s equals: f sqrt.
			
			"in case we don't have the primitive, use exact arithmetic and a bit of logic"
			sm := s asTrueFraction - (s ulp asTrueFraction / 2).
			sp := s asTrueFraction + (s ulp asTrueFraction / 2).
			
			self assert: s asTrueFraction squared < f ==> [sp squared > f]
				description: '(s)^2 < (s+ulp/2)^2 <= f => s is more than ulp/2 away from the true square root of f'.
			self assert: s asTrueFraction squared > f ==> [sm squared < f]
				description: 'f <= (s-ulp/2)^2 < (s)^2  ==> s is more than ulp/2 away from the true square root of f'].
	self assertIsNegativeZero: (fallBackMethod valueWithReceiver: Float negativeZero arguments: Array new).
	self assertIsPositiveZero: (fallBackMethod valueWithReceiver: 0.0 arguments: Array new).
	self assert: (fallBackMethod valueWithReceiver: Float nan arguments: Array new) isNaN.
	self assert: (fallBackMethod valueWithReceiver: Float infinity arguments: Array new) equals: Float infinity.
	self should: [fallBackMethod valueWithReceiver: -2.0 arguments: Array new] raise: DomainError
]

{ #category : #'tests - printing' }
FloatTest >> testStoreBase16 [
	"This bug was reported in mantis http://bugs.squeak.org/view.php?id=6695"

	self
		assert: (20.0 storeStringBase: 16) = '16r14.0'
		description: 'the radix prefix should not be omitted, except in base 10'
]

{ #category : #tests }
FloatTest >> testStoreOn [
	"If storeOn: prints exactly and the parser avoid cumulating round off Errors,
	then Float should be read back exactly.
	Note: there is no guarantee to restore the bit pattern of NaN though"
	
	self assert: (Compiler evaluate: Float halfPi storeString) = Float halfPi.
	self assert: (Compiler evaluate: Float halfPi negated storeString) = Float halfPi negated.
	self assert: (Compiler evaluate: Float infinity storeString) = Float infinity.
	self assert: (Compiler evaluate: Float negativeInfinity storeString) = Float negativeInfinity.
	self assert: (Compiler evaluate: Float nan storeString) isNaN.
]

{ #category : #'tests - conversion' }
FloatTest >> testStringAsNumber [
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
	self
		should: [ 'invalid number' asNumber ]
		raise: NumberParserError
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testTanh [
	self assertIsPositiveZero: 0.0 tanh.
	self assertIsNegativeZero: Float negativeZero tanh.
	self assert: (Float infinity tanh closeTo: 1).
	self assert: (2.0 cosh squared - 2.0 sinh squared closeTo: 1).
	self assert: (2.0 tanh negated closeTo: 2.0 negated tanh).
]

{ #category : #'tests - arithmetic' }
FloatTest >> testTimesTwoPowerGradualUnderflow [
	"Here is a vicious case where timesTwoPower is inexact because it underflows.
	And two consecutive inexact operations lead to a different result than a single one.
	Typically expressed as multiple of Float fmin in base 2,
	2r1011*Float fmin shifted by -3 with round to nearest, tie to even mode:
	-> round(1.011) -> 1.0 = fmin
	But if first shifted by -2 then by -1:
	-> round(10.11) -> 11.0 = 3*fmin
	-> round(1.1) -> 10.0 = 2*fmin
	Or first shifted by -1 then by -2:
	-> round(101.1) -> 110.0 = 6*fmin
	-> round(1.1) -> 10.0 = 2*fmin
	A naive implementation that split the shift uncarefully might fail to handle such case correctly."
	| f |
	f := 2r1011 asFloat.
	"scan the whole range of possible exponents for this significand"
	Float fmin exponent + f exponent to: Float fmax exponent - f exponent
		do:
			[:exp |
			| g |
			g := f timesTwoPower: exp.
			self assert: (g timesTwoPower: Float fmin exponent - g exponent) = Float fmin].
]

{ #category : #'tests - arithmetic' }
FloatTest >> testTimesTwoPowerOverflow [
	self assert: (Float fminNormalized timesTwoPower: Float emax - Float emin) equals: (2.0 raisedTo: Float emax).
	self assert: (Float zero timesTwoPower: SmallInteger maxVal squared) equals: Float zero.

]

{ #category : #'tests - arithmetic' }
FloatTest >> testTimesTwoPowerUnderflow [
	self assert: ((2.0 raisedTo: Float emax) timesTwoPower: Float emin - Float emax) equals: Float fminNormalized.
	self assert: (Float infinity timesTwoPower: SmallInteger minVal * SmallInteger maxVal) equals: Float infinity.

]

{ #category : #'tests - conversion' }
FloatTest >> testTruncated [
	self assert: 1.0 truncated = 1.
	self assert: 1.1 truncated = 1.
	self assert: -2.0 truncated = -2.
	self assert: -2.1 truncated = -2.
]

{ #category : #'tests - characterization' }
FloatTest >> testUlp [

	{Float pi predecessor. Float pi. Float pi successor} do:
		[:f |
		self assert: (f * 2) ulp = (f ulp * 2).
		self assert: (f / 2) ulp = (f ulp / 2).
		self deny: f + f ulp = f.
		self deny: f - f ulp = f.
		"Tests below are valid as long as default rounding mode (to nearest even) is used"
		self assert: f significandAsInteger odd ==> (f ulp / 2.0 + f = f successor).
		self assert: f significandAsInteger even ==> (f ulp / 2.0 + f = f)].
	
	self assert: 0.0 ulp = Float fmin.
	self assert: 1.0 ulp = Float epsilon.
	self assert: Float nan ulp isNaN.
	self assert: Float infinity ulp = Float infinity.
	self assert: Float negativeInfinity ulp = Float infinity.

	self assert: ((0 to: Float precision - 1) allSatisfy: [:each | (Float fmin timesTwoPower: each) ulp = Float fmin]).	
]

{ #category : #'tests - zero behavior' }
FloatTest >> testZero1 [
	"FloatTest new testZero1"

	self assert: Float negativeZero = 0 asFloat.
	self assert: (Float negativeZero at: 1) ~= (0 asFloat at: 1).

	"The negative zero has a bit representation that is different from the bit representation of the positive zero. Nevertheless, both values are defined to be equal."

]

{ #category : #'tests - IEEE 754' }
FloatTest >> testZero2 [
	self assert: (Float negativeZero asIEEE32BitWord printPaddedWith: $0 to: 32 base: 2) =
		'10000000000000000000000000000000'.
	self assert: (Float fromIEEE32Bit:
		(Integer readFrom: '10000000000000000000000000000000' readStream base: 2))
			= Float negativeZero
]

{ #category : #'tests - arithmetic' }
FloatTest >> testZeroRaisedToNegativePower [
	"this is a test related to http://bugs.squeak.org/view.php?id=6781"
	
	self should: [0.0 raisedTo: -1] raise: ZeroDivide.
	self should: [0.0 raisedTo: -1.0] raise: ZeroDivide.
]
