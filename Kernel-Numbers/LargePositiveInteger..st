"
I represent positive integers of more than 30 bits (ie, >= 1073741824).  These values are beyond the range of SmallInteger, and are encoded here as an array of 8-bit digits.  Care must be taken, when new values are computed, that any result that COULD BE a SmallInteger IS a SmallInteger (see normalize).

Note that the bit manipulation primitives, bitAnd:, bitShift:, etc., = and ~= run without failure (and therefore fast) if the value fits in 32 bits.  This is a great help to the simulator.
"
Class {
	#name : #LargePositiveInteger,
	#superclass : #Integer,
	#type : #bytes,
	#classVars : [
		'ThresholdForDiv21',
		'ThresholdForMul22',
		'ThresholdForMul33',
		'ThresholdForSqrt',
		'ThresholdForSquaredByFourth',
		'ThresholdForSquaredByHalf'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #testing }
LargePositiveInteger class >> initializedInstance [
	^ 12345678901234567 copy
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForDiv21 [
	<preference: 'Threshold for division by Burnikel-Ziegler recursive split'
		category: 'Arithmetic'
		description: 'The number of byte-digit above which recursive division is more efficient than schoolbook division'
		type: #Number>
	^ThresholdForDiv21 ifNil: [256]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForDiv21: anIntegerOrNil [
	"the number of byte-digit above which schoolbook division is more efficient than recursive division"
	ThresholdForDiv21 := anIntegerOrNil ifNotNil: [:t | t max: Smalltalk wordSize]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForMul22 [
	<preference: 'Threshold for multiplication by 2-way Karatsuba'
		category: 'Arithmetic'
		description: 'The number of byte-digit above which Karatsuba is more efficient than schoolbook'
		type: #Number>
	^ThresholdForMul22 ifNil: [600]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForMul22: anIntegerOrNil [
	"the number of byte-digit above which Karatsuba is more efficient than schoolbook"
	ThresholdForMul22 := anIntegerOrNil ifNotNil: [:t | t max: Smalltalk wordSize + 1]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForMul33 [
	<preference: 'Threshold for multiplication by 3-way Toom-Cook'
		category: 'Arithmetic'
		description: 'The number of byte-digit above which 3-way Toom-Cook is more efficient than Karatsuba'
		type: #Number>
	^ThresholdForMul33 ifNil: [2000]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForMul33: anIntegerOrNil [
	"the number of byte-digit above which 3-way Toom-Cook is more efficient than Karatsuba"
	ThresholdForMul33 := anIntegerOrNil ifNotNil: [:t | t max: Smalltalk wordSize + 1]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForSquaredByFourth [
	<preference: 'Threshold for squaring by 4-way Toom-Cook'
		category: 'Arithmetic'
		description: 'The number of byte-digit above which 4-way Toom-Cook squaring is more efficient than Karatsuba'
		type: #Number>
	^ThresholdForSquaredByFourth ifNil: [800]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForSquaredByFourth: anIntegerOrNil [
	"the number of byte-digit above which 4-way Toom-Cook squaring is more efficient than Karatsuba"
	^ThresholdForSquaredByFourth := anIntegerOrNil ifNotNil: [:t | t max: Smalltalk wordSize]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForSquaredByHalf [
	<preference: 'Threshold for squaring by 2-way Karatsuba'
		category: 'Arithmetic'
		description: 'The number of byte-digit above which Karatsuba squaring is more efficient than schoolbook multiplication'
		type: #Number>
	^ThresholdForSquaredByHalf ifNil: [400]
]

{ #category : #accessing }
LargePositiveInteger class >> thresholdForSquaredByHalf: anIntegerOrNil [
	"the number of byte-digit above which Karatsuba squaring is more efficient than schoolbook multiplication"
	^ThresholdForSquaredByHalf := anIntegerOrNil ifNotNil: [:t | t max: Smalltalk wordSize]
]

{ #category : #arithmetic }
LargePositiveInteger >> * anInteger [ 
	"Primitive. Multiply the receiver by the argument and answer with an
	 Integer result. Fail if either the argument or the result is not in 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 29>
	^super * anInteger
]

{ #category : #arithmetic }
LargePositiveInteger >> + anInteger [ 
	"Primitive. Add the receiver to the argument and answer with an
	 Integer result. Fail if either the argument or the result is not in 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 21>
	^super + anInteger
]

{ #category : #arithmetic }
LargePositiveInteger >> - anInteger [ 
	"Primitive. Subtract the argument from the receiver and answer with an
	 Integer result. Fail if either the argument or the result is not in 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 22>
	^super - anInteger
]

{ #category : #arithmetic }
LargePositiveInteger >> / anInteger [ 
	"Primitive. Divide the receiver by the argument and answer with the
	 result if the division is exact. Fail if the result is not a whole integer.
	 Fail if the argument is 0. Fail if either the argument or the result is not in 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 30>
	^super / anInteger
]

{ #category : #arithmetic }
LargePositiveInteger >> // anInteger [ 
	"Primitive. Divide the receiver by the argument and return the result.
	 Round the result down towards negative infinity to make it a whole
	 integer. Fail if the argument is 0. Fail if either the argument or the
	 result is not in 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 32>
	^super // anInteger
]

{ #category : #comparing }
LargePositiveInteger >> < anInteger [ 
	"Primitive. Compare the receiver with the argument and answer if the
	 receiver is less than the argument. Fail if either the argument or the
	 result is not in 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 23>
	^super < anInteger
]

{ #category : #comparing }
LargePositiveInteger >> <= anInteger [ 
	"Primitive. Compare the receiver with the argument and answer if the
	 receiver is less than or equal to the argument. Fail if the argument is
	 not a SmallInteger or a LargePositiveInteger in the 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 25>
	^super <= anInteger
]

{ #category : #comparing }
LargePositiveInteger >> > anInteger [ 
	"Primitive. Compare the receiver with the argument and answer if the
	 receiver is greater than the argument. Fail if the argument is
	 not a SmallInteger or a LargePositiveInteger in the 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 24>
	^super > anInteger
]

{ #category : #comparing }
LargePositiveInteger >> >= anInteger [ 
	"Primitive. Compare the receiver with the argument and answer if the
	 receiver is greater than or equal to the argument.  Fail if the argument
	 is not a SmallInteger or a LargePositiveInteger in the 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 26>
	^super >= anInteger
]

{ #category : #arithmetic }
LargePositiveInteger >> \\ aNumber [ 
	"Primitive. Take the receiver modulo the argument. The result is the
	 remainder rounded towards negative infinity, of the receiver divided
	 by the argument. Fail if the argument is 0. Fail if either the argument
	 or the result is not a SmallInteger or a LargePositiveInteger in the 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 31>
	aNumber isInteger
		ifTrue:
			[| qr q r |
			qr := self divideByInteger: aNumber.
			q := qr first normalize.
			r := qr last normalize.
			^(q negative
				ifTrue: [r isZero not]
				ifFalse: [q isZero and: [self negative ~~ aNumber negative]])
					ifTrue: [r + aNumber]
					ifFalse: [r]].
	^super \\ aNumber
	
]

{ #category : #arithmetic }
LargePositiveInteger >> \\\ anInteger [ 
	"A modulo method former used in DSA.
	This method is not much faster than \\ and rem: and it breaks some invariants (see super).
	Usage is now deprecated and should be reserved to backward compatibility."

	^(self digitDiv: anInteger neg: false) second
]

{ #category : #arithmetic }
LargePositiveInteger >> abs [
]

{ #category : #converting }
LargePositiveInteger >> as31BitSmallInt [
	"This is only for 31 bit numbers.  Keep my 31 bits the same, but put them in a small int.  The small int will be negative since my 31st bit is 1.  We know my 31st bit is 1 because otherwise I would already be a positive small int."

	self highBit = 31 ifFalse: [self error: 'more than 31 bits can not fit in a SmallInteger'].

	^ self - 16r80000000
]

{ #category : #converting }
LargePositiveInteger >> asFloat [
	"Answer a Float that best approximates the value of the receiver.
	This algorithm is optimized to process only the significant digits of a LargeInteger.
	And it does honour IEEE 754 round to nearest even mode in case of excess precision (see details below)."
	
	"How numbers are rounded in IEEE 754 default rounding mode:
	A shift is applied so that the highest 53 bits are placed before the floating point to form a significand.
	The trailing bits form the fraction part placed after the floating point.
	This fractional number must be rounded to the nearest integer.
	If fraction part is 2r0.1, exactly between two consecutive integers, there is a tie.
	The nearest even integer is chosen in this case.
	Examples (First 52bits of significand are omitted for brevity):
	2r0.00001 is rounded downward to 2r0
	2r1.00001 is rounded downward to 2r1
	2r0.1 is a tie and rounded to 2r0 (nearest even)
	2r1.1 is a tie and rounded to 2r10 (nearest even)
	2r0.10001 is rounded upward to 2r1
	2r1.10001 is rounded upward to 2r10
	Thus, if the next bit after floating point is 0, the significand is left unchanged.
	If next bit after floating point is 1, an odd significand is always rounded upper.
	An even significand is rounded upper only if the fraction part is not a tie."
	
	"Algorihm details:
	The floating point hardware can perform the rounding correctly with several excess bits as long as there is a single inexact operation.
	Note 1: the inexact flag in floating point hardware must not be trusted because in some cases the operations would be exact but would not take into account some bits that were truncated before the Floating point operations.
	Note 2: the floating point hardware is presumed configured in default rounding mode."
	
	| significand shift excess |

	"Check how many bits excess the maximum precision of a Float significand."
	excess := self highBitOfMagnitude - Float precision.
	excess > 7
		ifFalse:
			["We can use naive digit by digit conversion because there will be a single inexact round off at last iteration.
			But the nice thing is that Float precision + 7 excess bits = 60 which fit in a SmallInteger in Spur64.
			So the best to do is to delegate this final operation"
			^self digitsAsFloat ].

	"Remove the excess bits but seven."
	significand := self bitShiftMagnitude: 7 - excess.
	shift := excess - 7.
	"An even significand with a single excess bit immediately following would be truncated.
	But this would not be correct if above shift has truncated some extra bits.
	Check this case, and move an extra bit to the last significand digit."
	((significand digitAt: 1) = 2r01000000 and: [self anyBitOfMagnitudeFrom: 1 to: shift])
		ifTrue: [significand := significand + self sign].

	^significand digitsAsFloat timesTwoPower: shift.
]

{ #category : #'truncation and round off' }
LargePositiveInteger >> atRandom: aRandom [
	"Answer a random integer from 1 to self picked from aRandom."

	^aRandom nextLargeInt: self
]

{ #category : #'bit manipulation' }
LargePositiveInteger >> bitAt: anInteger [
	"Optimize super algorithm to avoid long bit operations.
	Instead work on digits which are known to be SmallInteger and fast.
	Note that this algorithm does not work for negative integers."
	
	| digitIndex bitIndex |
	digitIndex := anInteger - 1 // 8 + 1.
	digitIndex > self digitLength ifTrue: [^0].
	bitIndex := (anInteger - 1 bitAnd: 2r111) + 1.
	^(self digitAt: digitIndex) bitAt: bitIndex
]

{ #category : #'bit manipulation' }
LargePositiveInteger >> bitReverse: highBit [ 
	"This implementation is faster than super"
	
	| digitSize reversed |
	highBit < self highBit ifTrue: [ self error: 'Not enough bits.' ].
	digitSize := highBit + 7 // 8.
	reversed := self class new: digitSize.
	1 to: self digitLength do: [:i |
		reversed digitAt: digitSize + 1 - i put: (self digitAt: i) byteReversed].
	^reversed normalize bitShift: highBit - (digitSize * 8)
]

{ #category : #private }
LargePositiveInteger >> butLowestNDigits: n [
	"make a new integer removing N least significant digits of self."
	
	^self bitShiftMagnitude: -8 * n
]

{ #category : #private }
LargePositiveInteger >> copyDigitsFrom: start to: stop [
	"Make a new integer keeping only some digits of self."
	
	| len slice |
	start > 0 ifFalse: [^self error: 'start index should be at least 1'].
	len := self digitLength.
	(start > len or: [start > stop]) ifTrue: [^0].
	stop >= len
		ifTrue: [start = 1 ifTrue: [^self].
				len := len - start + 1]
		ifFalse: [len := stop - start + 1].
	slice := self class new: len.
	slice replaceFrom: 1 to: len with: self startingAt: start.
	^slice normalize
]

{ #category : #'system primitives' }
LargePositiveInteger >> digitAt: index [ 
	"Primitive. Answer the value of an indexable field in the receiver.   LargePositiveInteger uses bytes of base two number, and each is a 'digit' base 256.  Fail if the argument (the index) is not an Integer or is out of bounds. Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 60>
	self digitLength < index
		ifTrue: [^0]
		ifFalse: [^super at: index]
]

{ #category : #'system primitives' }
LargePositiveInteger >> digitAt: index put: value [ 
	"Primitive. Store the second argument (value) in the indexable field of 
	the receiver indicated by index. Fail if the value is negative or is larger 
	than 255. Fail if the index is not an Integer or is out of bounds. Answer 
	the value that was stored. Essential. See Object documentation 
	whatIsAPrimitive."

	<primitive: 61>
	^super at: index put: value
]

{ #category : #private }
LargePositiveInteger >> digitDiv21: anInteger [
	"This is part of the recursive division algorithm from Burnikel - Ziegler
	Divide a two limbs receiver by 1 limb dividend
	Each limb is decomposed in two halves of p bytes (8*p bits)
	so as to continue the recursion"
	
	| p qr1 qr2 |
	"split in two parts, rounded to upper multiple of 4"
	p := (anInteger digitLength + 7 bitShift: -3) bitShift: 2.
	p < self class thresholdForDiv21 ifTrue: [^(self digitDiv: anInteger neg: false) collect: #normalize].
	qr1 := (self butLowestNDigits: p) digitDiv32: anInteger.
	qr2 := (self lowestNDigits: p) + (qr1 last bitShift: 8*p) digitDiv32: anInteger.
	qr2 at: 1 put: (qr2 at: 1) + ((qr1 at: 1) bitShift: 8*p).
	^qr2
]

{ #category : #private }
LargePositiveInteger >> digitDiv32: anInteger [
	"This is part of the recursive division algorithm from Burnikel - Ziegler
	Divide 3 limb (a2,a1,a0) by 2 limb (b1,b0).
	Each limb is made of p bytes (8*p bits).
	This step transforms the division problem into multiplication
	It must use a fast multiplyByInteger: to be worth the overhead costs."
	
	| a2 b1 d p q qr r |
	"split in two parts, rounded to upper multiple of 4"
	p :=(anInteger digitLength + 7 bitShift: -3) bitShift: 2.
	(a2 := self butLowestNDigits: 2*p) 
		< (b1 := anInteger butLowestNDigits: p)
		ifTrue:
			[qr := (self butLowestNDigits: p) digitDiv21: b1.
			q := qr first.
			r := qr last]
		ifFalse:
			[q := (1 bitShift: 8*p) - 1.
			r := (self butLowestNDigits: p) - (b1 bitShift: 8*p) + b1].
	d := q * (anInteger lowestNDigits: p).
	r := (self lowestNDigits: p) + (r bitShift: 8*p) - d.
	[r < 0]
		whileTrue:
			[q := q - 1.
			r := r + anInteger].
	^Array with: q with: r
	
]

{ #category : #private }
LargePositiveInteger >> digitDivSplit: anInteger [
	"This is the recursive division algorithm from Burnikel - Ziegler
	See Fast Recursive Division - Christoph Burnikel, Joachim Ziegler
	Research Report MPI-I-98-1-022, MPI Saarbrucken, Oct 1998
	https://pure.mpg.de/rest/items/item_1819444_4/component/file_2599480/content"
	
	| s m t a b z qr qDigits q i high low |
	"round digits up to next power of 2"
	s := anInteger digitLength.
	m := 1 bitShift: (s - 1) highBit.
	"shift so that leading bit of leading byte be 1, and digitLength power of two"
	s := m * 8 - anInteger highBit.
	a := self bitShift: s.
	b := anInteger bitShift: s.
	
	"Decompose a into t limbs - each limb have m bytes
	choose t such that leading bit of leading limb of a be 0"
	t := (a highBit + 1 / (m * 8)) ceiling.
	z := a butLowestNDigits: t - 2 * m.
	i := t - 2.
	qDigits := Array new: t - 1.
	"and do a division of two limb by 1 limb b for each pair of limb of a"
	[qr := z digitDiv21: b.
	qDigits at: t - 1 - i put: qr first.
	(i := i - 1) >= 0] whileTrue:
		[z := (qr last bitShift: 8*m) + (a copyDigitsFrom: i * m + 1 to: i + 1 * m)].
	"recompose the quotient from digits"
	t < 3
		ifTrue:
			[q := 0.
			qDigits do: [:qi | q := (q bitShift: 8 * m) + qi]]
		ifFalse:
			["Use a O(n) reconstruction - note the interlace to avoid overlapping digits"
			high  := LargePositiveInteger new: t - 2 * m + qDigits first digitLength.
			low := LargePositiveInteger new: t - 2 * m.
			1 to: t - 1 by: 2 do: [:k | high inplaceAddNonOverlapping: (qDigits at: k) digitShiftBy: t - 1 - k * m].
			2 to: t - 1 by: 2 do: [:k | low inplaceAddNonOverlapping: (qDigits at: k) digitShiftBy: t - 1 - k * m].
			q := high + low].
	^Array with: q with: (qr last bitShift: s negated)
]

{ #category : #'system primitives' }
LargePositiveInteger >> digitLength [
	"Primitive. Answer the number of indexable fields in the receiver. This 
	value is the same as the largest legal subscript. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 62>
	self primitiveFailed
]

{ #category : #private }
LargePositiveInteger >> digitMul22: anInteger [
	"Multiply after decomposing each operand in two parts, using Karatsuba algorithm.
	Karatsuba perform only 3 multiplications, leading to a cost O(n^3 log2)
	asymptotically better than super O(n^2) for large number of digits n.
	See https://en.wikipedia.org/wiki/Karatsuba_algorithm"
	
	| half xLow xHigh yLow yHigh low mid high |
	"split each in two parts, rounded to upper multiple of 4"
	half := (anInteger digitLength + 7 bitShift: -3) bitShift: 2.
	xLow := self lowestNDigits: half.
	xHigh := self butLowestNDigits: half.
	yLow := anInteger lowestNDigits: half.
	yHigh := anInteger butLowestNDigits: half.
	
	"Karatsuba trick: perform with 3 multiplications instead of 4"
	low := xLow multiplyByInteger: yLow.
	high := xHigh multiplyByInteger: yHigh.
	mid := high + low + (xHigh - xLow multiplyByInteger: yLow - yHigh).
	
	"Sum the parts of decomposition"
	^(high isZero
		ifTrue: [low]
		ifFalse: [(high bitShift: 16*half)
			inplaceAddNonOverlapping: low digitShiftBy: 0])
		+ (mid bitShift: 8*half)
]

{ #category : #private }
LargePositiveInteger >> digitMul23: anInteger [
	"Multiply after decomposing the receiver in 2 parts, and multiplicand in 3 parts.
	Only invoke when anInteger digitLength between: 3/2 and 5/2 self digitLength.
	This is a variant of Toom-Cook algorithm (see digitMul33:)"
   
	| half x1 x0 y2 y1 y0 y20 z3 z2 z1 z0 |
	"divide self in 2 and operand in 3 parts, rounded to upper multiple of 4"
	half := ( self digitLength + 7 bitShift: -3) bitShift: 2.
	x1 := self butLowestNDigits: half.
	x0 := self lowestNDigits: half.
	y2 := anInteger butLowestNDigits: half * 2.
	y1 := anInteger copyDigitsFrom: half + 1 to: half * 2.
	y0 := anInteger lowestNDigits: half.
   
	"Toom trick: 4 multiplications instead of 6"
	y20 := y2 + y0.
	z3 := x1 multiplyByInteger: y2.
	z2 := x0 - x1 multiplyByInteger: y20 - y1.
	z1 := x0 + x1 multiplyByInteger: y20 + y1.
	z0 := x0 multiplyByInteger: y0.
   
	"Sum the parts of decomposition"
	^z0 + ((z1 - z2 bitShift: -1) - z3 bitShift: 8*half)
		+ (((z1 + z2 bitShift: -1) - z0) + (z3 bitShift: 8*half) bitShift: 16 * half)
]

{ #category : #private }
LargePositiveInteger >> digitMul33: anInteger [
	"Multiply after decomposing each operand in 3 parts, using a Toom-Cooke algorithm.
	Toom-Cooke is a generalization of Karatsuba divide and conquer algorithm.
	See https://en.wikipedia.org/wiki/Toom%E2%80%93Cook_multiplication
	Use a Bodrato-Zanoni variant for the choice of interpolation points and matrix inversion
	See What about Toom-Cook matrices optimality? - Marco Bodrato, Alberto Zanoni - Oct. 2006
	http://www.bodrato.it/papers/WhatAboutToomCookMatricesOptimality.pdf"
	
	| third x2 x1 x0 y2 y1 y0 y20 z4 z3 z2 z1 z0 x20 |
	"divide both operands in 3 parts, rounded to upper multiple of 4"
	third := anInteger digitLength + 11 // 12 bitShift: 2.
	x2 := self butLowestNDigits: third * 2.
	x1 := self copyDigitsFrom: third + 1 to: third * 2.
	x0 := self lowestNDigits: third.
	y2 := anInteger butLowestNDigits: third * 2.
	y1 := anInteger copyDigitsFrom: third + 1 to: third * 2.
	y0 := anInteger lowestNDigits: third.
	
	"Toom-3 trick: 5 multiplications instead of 9"
	z0 := x0 multiplyByInteger: y0.
	z4 := x2 multiplyByInteger: y2.
	x20 := x2 + x0.
	y20 := y2 + y0.
	z1 := x20 + x1 multiplyByInteger: y20 + y1.
	x20 := x20 - x1.
	y20 := y20 - y1.
	z2 := x20 multiplyByInteger: y20.
	z3 := (x20 + x2 bitShift: 1) - x0 multiplyByInteger: (y20 + y2 bitShift: 1) - y0.
	
	"Sum the parts of decomposition"
	z3 := z3 - z1 quo: 3.
	z1 := z1 - z2 bitShift: -1.
	z2 := z2 - z0.
	
	z3 := (z2 - z3 bitShift: -1) + (z4 bitShift: 1).
	z2 := z2 + z1 - z4.
	z1 := z1 - z3.
	^z0 + (z1 bitShift: 8*third) + (z2 bitShift: 16*third) + (z3 + (z4 bitShift: 8*third) bitShift: 24*third)
]

{ #category : #private }
LargePositiveInteger >> digitMulSplit: anInteger [
	"multiply digits when self and anInteger have not well balanced digitlength.
	in this case, it is better to split the largest (anInteger) in several parts and recompose"

	| xLen yLen split q r high mid low sizes |
	yLen := anInteger digitLength.
	xLen := self digitLength.
	"divide in about 1.5 xLen, rounded to upper multiple of 4"
	split := (xLen * 3 + 7 bitShift: -3) bitShift: 2.
	
	"Arrange to sum non overlapping parts"
	q := yLen // split.
	q < 3 ifTrue: [^(0 to: yLen - 1 by: split) detectSum: [:yShift | (self multiplyByInteger: (anInteger copyDigitsFrom: yShift + 1 to: yShift + split)) bitShift: 8 * yShift]].
	r := yLen \\ split.
	"allocate enough bytes, but not too much, in order to minimise normalize cost;
	we could allocate xLen + yLen for each one as well"
	sizes := {q-1*split. q*split. q*split+r}.
	low  := Integer new: (sizes atWrap: 0 - (q\\3)) + xLen neg: self negative ~~ anInteger negative.
	mid := Integer new:  (sizes atWrap: 1 - (q\\3)) + xLen neg: self negative ~~ anInteger negative.
	high := Integer new: (sizes atWrap: 2 - (q\\3)) + xLen neg: self negative ~~ anInteger negative.
	0 to: yLen - 1 by: 3 * split do: [:yShift |
		low
			inplaceAddNonOverlapping: (self multiplyByInteger: (anInteger copyDigitsFrom: yShift + 1 to: yShift + split))
			digitShiftBy: yShift].
	split to: yLen - 1 by: 3 * split do: [:yShift |
		mid
			inplaceAddNonOverlapping: (self multiplyByInteger: (anInteger copyDigitsFrom: yShift + 1 to: yShift + split))
			digitShiftBy: yShift].
	split * 2 to: yLen - 1 by: 3 * split do: [:yShift |
		high
			inplaceAddNonOverlapping: (self multiplyByInteger: (anInteger copyDigitsFrom: yShift + 1 to: yShift + split))
			digitShiftBy: yShift].
	^high normalize + mid normalize + low normalize
]

{ #category : #private }
LargePositiveInteger >> divideByInteger: anInteger [
	"If length is worth, engage a recursive divide and conquer strategy,
	more efficient than super"
	| qr |
	(anInteger digitLength < (self class thresholdForDiv21 * 2)
			or: [self digitLength <= anInteger digitLength])
		ifTrue: [^ self digitDiv: anInteger neg: self negative ~~ anInteger negative].
	qr := self abs digitDivSplit: anInteger abs.
	self negative ifTrue: [qr at: 2 put: qr second negated].
	self negative = anInteger negative ifFalse: [qr at: 1 put: qr first negated].
	^qr
]

{ #category : #comparing }
LargePositiveInteger >> hash [
	"Answer an integer value that is related to the value of the receiver.
	 Take care that the hash value is the same in both 32-bit and 64-bit versions.
	 Since the integers are by definition perfectly distributed a SmallInteger's hash is itself
	 (it is impossible to derive a hash function that is better distributed than the SmallIntegers
	 themselves).  Therefore, for integers that could possibly fit in the SmallInteger range, answer
	 self.  For values well outside of the SmallInteger range on 64-bits answer a hash that avoids
	 large integer arithmetic."
	^self digitLength <= 8
		ifTrue: [self]
		ifFalse:
			[ByteArray
				hashBytes: self
				startingWith: self species hash]
]

{ #category : #'bit manipulation' }
LargePositiveInteger >> hashMultiply [
	"This is a multiplication by by 1664525 mod 2^28 written to avoid overflowing into large integers.
	 The primitive is able to perform the operation with modulo arihmetic."
	<primitive: 159>
	"Truncate to 28 bits and try again"
	^(self bitAnd: 16rFFFFFFF) hashMultiply
]

{ #category : #'bit manipulation' }
LargePositiveInteger >> highBit [
	"Answer the index of the high order bit of the receiver, or zero if the  
	receiver is zero. Raise an error if the receiver is negative, since  
	negative integers are defined to have an infinite number of leading 1's 
	in 2's-complement arithmetic. Use >>highBitOfMagnitude if you want to  
	get the highest bit of the magnitude."
	^ self highBitOfMagnitude
]

{ #category : #'bit manipulation' }
LargePositiveInteger >> highBitOfMagnitude [
	"Answer the index of the high order bit of the magnitude of the  
	receiver, or zero if the receiver is zero.  
	This method is used for LargeNegativeIntegers as well,  
	since Squeak's LargeIntegers are sign/magnitude."
	| realLength lastDigit |
	realLength := self digitLength.
	[(lastDigit := self digitAt: realLength) = 0]
		whileTrue: [(realLength := realLength - 1) = 0 ifTrue: [^ 0]].
	^ lastDigit highBitOfByte + (8 * (realLength - 1))
]

{ #category : #private }
LargePositiveInteger >> initialGuessForNthRoot: n [
	"Try a divide and conquer approach for the initial guess of nth-root of receiver"
	
	| p high mid q s sn1 |
	"Split self in high*b^n+mid*b+low"
	p := ((self highBit bitShift: -1) // n) bitShift: -3.
	p >= 4 ifFalse: [^super initialGuessForNthRoot: n].
	high := self butLowestNDigits: p * n.
	mid := self copyDigitsFrom: p + 1 to: p * n.
	
	s := high nthRootTruncated: n.
	sn1 := s raisedToInteger: n - 1.
	q := (sn1 * s bitShift: n - 1 * 8 * p) + mid quo: (sn1 * n bitShift: n - 2 * 8 * p).
	^(s bitShift: 8 * p) + q
	
]

{ #category : #private }
LargePositiveInteger >> inplaceAddNonOverlapping: anInteger digitShiftBy: p [
	"Beware: this will destructively replace some digits with that of anInteger.
	- if self and anInteger are of same sign
		(self negative = anInteger negative).
	- if self and anInteger have no overlapping digits
		(self anyBitOfMagnitudeFrom: 8 * p + 1 to: anInteger digitLength + p * 8) not.
	- if anInteger does not overflow self digitLength
		anInteger digitLength + p <= self digitLength.
	then, and only then, this method can be used instead of more costly
		self + (anInteger bitShift: 8 * p).
	This operation is useful in divide and conquer reconstruction phase"
	
	self replaceFrom: p + 1 to: p + anInteger digitLength with: anInteger startingAt: 1
]

{ #category : #testing }
LargePositiveInteger >> isLarge [
	^true
]

{ #category : #testing }
LargePositiveInteger >> isPowerOfTwo [
	"Return true if the receiver is an integral power of two. Optimized version."
	
	| size |
	1 to: (size := self digitLength) do: [ :index |
		| digit |
		(digit := self digitAt: index) = 0 ifFalse: [ 
			^size = index and: [ digit isPowerOfTwo ] ] ].
	^false
]

{ #category : #testing }
LargePositiveInteger >> isPrime [
	"Answer true if the receiver is a prime number. Use a probabilistic implementation	 that
	is much faster for large integers, and that is correct to an extremely high statistical
	level of confidence (effectively deterministic)."

	^ self isProbablyPrime
]

{ #category : #testing }
LargePositiveInteger >> isZero [
	"Optimization. Answer false since receiver is greater than 0."

	^false

]

{ #category : #'mathematical functions' }
LargePositiveInteger >> ln [
	"This function is defined because super ln might overflow."
	| res h |
	res := super ln.
	res isFinite ifTrue: [^res].
	h := self highBit.
	^2 ln * h + (self / (1 << h)) asFloat ln
]

{ #category : #'mathematical functions' }
LargePositiveInteger >> log [
	"This function is defined because super log might overflow."
	| res h |
	res := super log.
	res isFinite ifTrue: [^res].
	h := self highBit.
	^2 log * h + (self / (1 << h)) asFloat log
]

{ #category : #'mathematical functions' }
LargePositiveInteger >> log2 [
	"This function is defined because super log2 might overflow."
	| res h |
	res := super log2.
	res isFinite ifTrue: [^res].
	h := self highBit.
	^h + (self / (1 << h)) asFloat log2
]

{ #category : #private }
LargePositiveInteger >> lowestNDigits: n [
	"Make a new integer keeping only n least significant digits of self"
	
	| low |
	n >= self digitLength ifTrue: [^self].
	low := self class new: n.
	low replaceFrom: 1 to: n with: self startingAt: 1.
	^low normalize
]

{ #category : #'mathematical functions' }
LargePositiveInteger >> mightBeASquare [
	"In base 16, a square number can end only with 0,1,4 or 9 and
	- in case 0, only 0,1,4,9 can precede it,
	- in case 4, only even numbers can precede it.
	See http://en.wikipedia.org/wiki/Square_number
	So, in hex, the last byte must be one of:
		00
		10
		40
		90
		x1
		e4
		x9
	where x is any hex digit and e is any even digit
	Also, the receiver must be an aven power of two."
	| lsb |
	lsb := self digitAt: 1.
	^(lsb = 0 and: [ self lowBit odd ])	"00 (and even power of 2)"
		or: [ lsb = 16r40				"40"
		or: [ (lsb bitAnd: 16r7) = 1		"any|1 or any|9"
		or: [ (lsb bitAnd: 16r1F) = 4		"even|4"
		or: [ (lsb bitAnd: 16r7F) = 16 ]]]]	"10 or 90"
]

{ #category : #private }
LargePositiveInteger >> multiplyByInteger: anInteger [
	"Return the result of multiplying the receiver by the Integer argument.
	This method dispatch to the fastest algorithm based on operands length."
	
	| xLen yLen |
	"Revert to schoolbook multiplication if short"
	(xLen := self digitLength) < self class thresholdForMul22
		ifTrue: [^ self digitMultiply: anInteger 
					neg: self negative ~~ anInteger negative].
	
	"Arrange to have the receiver be the shorter and retry"
	xLen > (yLen := anInteger digitLength)
		ifTrue: [^ anInteger multiplyByInteger: self ].

	"Seek for integers of about the same length, else split the long one"
	yLen > (2 * xLen) ifTrue: [^self digitMulSplit: anInteger].
	
	"Choose the fastest divide and conquer algorithm based on another heuristic"
	xLen >= self class thresholdForMul33 ifTrue: [^self digitMul33: anInteger].
	yLen * 2 >= (3 * xLen) ifTrue: [^self digitMul23: anInteger].
	^self digitMul22: anInteger
]

{ #category : #arithmetic }
LargePositiveInteger >> negated [ 
	^ (self copyto: (LargeNegativeInteger new: self digitLength))
		normalize  "Need to normalize to catch SmallInteger minVal"
]

{ #category : #testing }
LargePositiveInteger >> negative [
	"Answer whether the receiver is mathematically negative."

	^ false
]

{ #category : #converting }
LargePositiveInteger >> normalize [
	"Check for leading zeroes and return shortened copy if so"
	| sLen val len oldLen |
	<primitive: 'primNormalizePositive' module:'LargeIntegers'>
	"First establish len = significant length"
	len := oldLen := self digitLength.
	[len = 0 ifTrue: [^0].
	(self digitAt: len) = 0]
		whileTrue: [len := len - 1].

	"Now check if in SmallInteger range.  Fast compute SmallInteger maxVal digitLength"
	sLen := SmallInteger maxVal > 16r7FFFFFFF "we're definitely on 64bit if we are larger than (2 raisedTo: 31) - 1"
				ifTrue: [8]
				ifFalse: [4].
	(len <= sLen
	 and: [(self digitAt: sLen) <= (SmallInteger maxVal digitAt: sLen)])
		ifTrue: ["If so, return its SmallInt value"
				val := 0.
				len to: 1 by: -1 do:
					[:i | val := (val *256) + (self digitAt: i)].
				^ val].

	"Return self, or a shortened copy"
	len < oldLen
		ifTrue: [^ self growto: len]
		ifFalse: [^ self]
]

{ #category : #testing }
LargePositiveInteger >> positive [
	"Answer whether the receiver is positive or equal to 0. (ST-80 protocol).
	See also strictlyPositive"

	^ true
]

{ #category : #printing }
LargePositiveInteger >> printOn: aStream base: b [
	"Append a representation of this number in base b on aStream.
	In order to reduce cost of LargePositiveInteger ops, split the number in approximately two equal parts in number of digits."
	
	| halfDigits halfPower head tail nDigitsUnderestimate qr |
	"Don't engage any arithmetic if not normalized"
	(self digitLength = 0 or: [(self digitAt: self digitLength) = 0]) ifTrue: [^self normalize printOn: aStream base: b].
	
	nDigitsUnderestimate := b = 10
		ifTrue: [((self highBit - 1) * 1233 >> 12) + 1. "This is because (2 log)/(10 log)*4096 is slightly greater than 1233"]
		ifFalse: [self highBit quo: b highBit].
		
	"splitting digits with a whole power of two is more efficient"
	halfDigits := 1 bitShift: nDigitsUnderestimate highBit - 2.
	
	halfDigits <= 1
		ifTrue: ["Hmmm, this could happen only in case of a huge base b... Let lower level fail"
			^self printOn: aStream base: b nDigits: (self numberOfDigitsInBase: b)].
	
	"Separate in two halves, head and tail"
	halfPower := b raisedToInteger: halfDigits.
	qr := self divideByInteger: halfPower.
	head := qr first normalize.
	tail := qr last normalize.
	
	"print head"
	head printOn: aStream base: b.
	
	"print tail without the overhead to count the digits"
	tail printOn: aStream base: b nDigits: halfDigits
]

{ #category : #printing }
LargePositiveInteger >> printOn: aStream base: b nDigits: n [
	"Append a representation of this number in base b on aStream using n digits.
	In order to reduce cost of LargePositiveInteger ops, split the number of digts approximatily in two
	Should be invoked with: 0 <= self < (b raisedToInteger: n)"
	
	| halfPower half head tail qr |
	n <= 1 ifTrue: [
		n <= 0 ifTrue: [self error: 'Number of digits n should be > 0'].
		
		"Note: this is to stop an infinite loop if one ever attempts to print with a huge base
		This can happen because choice was to not hardcode any limit for base b
		We let Character>>#digitValue: fail"
		^aStream nextPut: (Character digitValue: self) ].
	halfPower := n bitShift: -1.
	half := b raisedToInteger: halfPower.
	qr := self divideByInteger: half.
	head := qr first normalize.
	tail := qr last normalize.
	head printOn: aStream base: b nDigits: n - halfPower.
	tail printOn: aStream base: b nDigits: halfPower
]

{ #category : #printing }
LargePositiveInteger >> printStringBase: base [
	"For LargeIntegers, it's faster to use the stream version.
	This reproduces Number implementation to avoid speed down if one defines Integer>>#printStringBase:
	This method should be removed if  Integer>>#printStringBase: is removed.
	Note: tests preallocating stream space with exact numberOfDigitsInBase: did not gain speed"
	
	^String streamContents: [:str | self printOn: str base: base]
]

{ #category : #arithmetic }
LargePositiveInteger >> quo: anInteger [ 
	"Primitive. Divide the receiver by the argument and answer the result.
	 Round the result down towards zero to make it a whole integer. Fail if
	 the argument is 0. Fail if either the argument or the result is not a
	 SmallInteger or a LargePositiveInteger in the 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 33>
	^super quo: anInteger
]

{ #category : #'objects from disk' }
LargePositiveInteger >> readDataFrom: aDataStream size: varsOnDisk [
	^(super readDataFrom: aDataStream size: varsOnDisk) normalize
	
]

{ #category : #arithmetic }
LargePositiveInteger >> rem: aNumber [ 
	"Remainder defined in terms of quo:. See super rem:. Fail if
	 the argument is 0. Fail if either the argument or the result is not a
	 SmallInteger or a LargePositiveInteger in the 64 bit range.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 20>
	 aNumber isInteger
		ifTrue:
			[| rem |
			rem := (self divideByInteger: aNumber) at: 2.
			^ rem normalize].
	^super rem: aNumber
]

{ #category : #'system primitives' }
LargePositiveInteger >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	| index replacementIndex |
	<primitive: 105>
	replacementIndex := repStart.
	index := start.
	replacement isInteger ifTrue: [
		"This branch is only here to accept SmallInteger replacements not handled by the primitive."
		[ index <= stop ] whileTrue: [
			self digitAt: index put: (replacement digitAt: replacementIndex).
			index := index + 1.
			replacementIndex := replacementIndex + 1 ].
		^self ].
	"Primitive compatible variant which doesn't support SmallInteger replacements."
	[ index <= stop ] whileTrue: [
		self basicAt: index put: (replacement basicAt: replacementIndex).
		index := index + 1.
		replacementIndex := replacementIndex + 1 ]
]

{ #category : #testing }
LargePositiveInteger >> sign [
	"Optimization. Answer 1 since receiver is greater than 0."

	^ 1

]

{ #category : #testing }
LargePositiveInteger >> signBit [
	"Optimization."

	^0
]

{ #category : #'mathematical functions' }
LargePositiveInteger >> sqrt [
	"Answer the square root of the receiver.
	If the square root is exact, answer an Integer, else answer a Float approximation.
	Make sure the result is correctly rounded (i.e. the nearest Float to the exact square root)"
	
	| floatResult integerResult guardBit highBit sr |
	(highBit := self highBit) < (Float precision * 2)
		ifTrue:
			["the sqrt of self asFloat is correctly rounded, so use it"
			floatResult := self asFloat sqrt.
			self mightBeASquare ifFalse: [^floatResult].
			"Answer integerResult in case of perfect square"
			integerResult := floatResult truncated.
			integerResult squared = self ifTrue: [^integerResult].
			^floatResult].

	"Eventually use a guard bit for handling correct rounding direction"
	guardBit := highBit <= (Float precision + 1 * 2)
		ifTrue:
			["Add one guard bit for rounding correctly"
			1]
		ifFalse:
			[self mightBeASquare
				ifTrue:
					["Keep all the bits in case we are a perfect square"
					0]
				ifFalse:
					["Remove superfluous bit that won't change the Float approximation"
					Float precision + 1 - (highBit // 2)]].
	
	"Get truncated sqrt and remainder for the same price"
	sr := (self bitShift: guardBit * 2) sqrtRem.
	
	"Handle case of perfect square"
	integerResult := sr first.
	sr last isZero ifTrue: [^integerResult bitShift: guardBit negated].
	
	"Answer the best we have which is the sqrt correctly rounded at Float precision."
	^((integerResult bitShift: Float precision - integerResult highBit)
		+ (integerResult bitAt: integerResult highBit - Float precision)) asFloat
			timesTwoPower: integerResult highBit - Float precision - guardBit
]

{ #category : #'mathematical functions' }
LargePositiveInteger >> sqrtFloor [
	"See super. Use a fast divide and conquer strategy."

	^self sqrtRem first
]

{ #category : #'mathematical functions' }
LargePositiveInteger >> sqrtRem [
	"See super. Use a divide and conquer method to perform this operation.
	See Paul Zimmermann. Karatsuba Square Root. [Research Report] RR-3805, INRIA. 1999, pp.8. <inria-00072854>
	https://hal.inria.fr/inria-00072854/PDF/RR-3805.pdf"
	
	| n qr q s r sr a3a2 a1 a0 |
	"Split self in 4 digits a3,a2,a1,a0 in base b,
	such that most significant digit a3 >= b/4
	It is not a problem to have a3 >= b,
	so we can round b down to a whole number of bytes n"
	n := (self highBit bitShift: -5) max: 1. "bitShift: -2 divide in 4 parts, bitShift: -3 round down in bytes"
	a3a2 := self butLowestNDigits: n * 2.
	a1 := self copyDigitsFrom: n + 1 to: n * 2.
	a0 := self lowestNDigits: n.
	
	sr := a3a2 sqrtRem.
	qr := (sr last bitShift: 8 * n) + a1 divideByInteger: (sr first bitShift: 1).
	q := qr first normalize.
	s := (sr first bitShift: 8 * n) + q.
	r := (qr last normalize bitShift: 8 * n) + a0 - q squared.
	r negative
		ifTrue:
			[r := (s bitShift: 1) + r - 1.
			s := s - 1].
	sr at: 1 put: s; at: 2 put: r.
	^sr
	
]

{ #category : #'mathematical functions' }
LargePositiveInteger >> squared [
	"Eventually use a divide and conquer algorithm to perform the multiplication"

	(self digitLength >= self class thresholdForSquaredByHalf) ifFalse: [^self * self].
	(self digitLength >= self class thresholdForSquaredByFourth) ifFalse: [^self squaredByHalf].
	^self squaredByFourth
]

{ #category : #private }
LargePositiveInteger >> squaredByFourth [
	"Use a 4-way Toom-Cook divide and conquer algorithm to perform the multiplication.
	See Asymmetric Squaring Formulae Jaewook Chung and M. Anwar Hasan
	https://www.lirmm.fr/arith18/papers/Chung-Squaring.pdf"
	
	| p a0 a1 a2 a3 a02 a13 s0 s1 s2 s3 s4 s5 s6 t2 t3 |
	"divide in 4 parts, rounded to upper multiple of 4"
	p := (self digitLength + 15 bitShift: -4) bitShift: 2.
	a3 := self butLowestNDigits: p * 3.
	a2 := self copyDigitsFrom: p * 2 + 1 to: p * 3.
	a1 := self copyDigitsFrom: p + 1 to: p * 2.
	a0 := self lowestNDigits: p.
	
	"Toom-4 trick: 7 multiplications instead of 16"
	a02 := a0 - a2.
	a13 := a1 - a3.
	s0 := a0 squared.
	s1 := (a0 * a1) bitShift: 1.
	s2 := (a02 + a13) * (a02 - a13).
	s3 := ((a0 + a1) + (a2 + a3)) squared.
	s4 := (a02 * a13) bitShift: 1.
	s5 := (a3 * a2) bitShift: 1.
	s6 := a3 squared.
	
	"Interpolation"
	t2 := s1 + s5.
	t3 := (s2 + s3 + s4 bitShift: -1) - t2.
	s3 := t2 - s4.
	s4 := t3 - s0.
	s2 := t3 - s2 - s6.
	
	"Sum the parts of decomposition"
	^s0 + (s1 bitShift: 8*p) + (s2 + (s3 bitShift: 8*p) bitShift: 16*p)
	+(s4 + (s5 bitShift: 8*p) + (s6 bitShift: 16*p) bitShift: 32*p)
]

{ #category : #private }
LargePositiveInteger >> squaredByHalf [
	"Use a divide and conquer algorithm to perform the multiplication.
	Split in two parts like Karatsuba, but economize 2 additions by using asymetrical product."
	
	| half xHigh xLow low high mid |
	
	"Divide digits in two halves rounded tp upper multiple of 4"
	half := (self digitLength + 1 bitShift: -3) bitShift: 2.
	xLow := self lowestNDigits: half.
	xHigh := self butLowestNDigits: half.
	
	"eventually use karatsuba"
	low := xLow squared.
	high := xHigh squared.
	mid := xLow multiplyByInteger: xHigh.
	
	"Sum the parts of decomposition"
	^(high bitShift: 16*half)
		inplaceAddNonOverlapping: low digitShiftBy: 0;
		+ (mid bitShift: 8*half+1)
]

{ #category : #private }
LargePositiveInteger >> squaredByThird [
	"Use a 3-way Toom-Cook divide and conquer algorithm to perform the multiplication"
	
	| third x0 x1 x2 x20 z0 z1 z2 z3 z4 |
	"divide in 3 parts, rounded to upper multiple of 4"
	third := self digitLength + 11 // 3 bitShift: 2.
	x2 := self butLowestNDigits: third * 2.
	x1 := self copyDigitsFrom: third + 1 to: third * 2.
	x0 := self lowestNDigits: third.
	
	"Toom-3 trick: 5 multiplications instead of 9"
	z0 := x0 squared.
	z4 := x2 squared.
	x20 := x2 + x0.
	z1 := (x20 + x1) squared.
	x20 := x20 - x1.
	z2 := x20 squared.
	z3 := ((x20 + x2 bitShift: 1) - x0) squared.
	
	"Sum the parts of decomposition"
	z3 := z3 - z1 quo: 3.
	z1 := z1 - z2 bitShift: -1.
	z2 := z2 - z0.
	
	z3 := (z2 - z3 bitShift: -1) + (z4 bitShift: 1).
	z2 := z2 + z1 - z4.
	z1 := z1 - z3.
	^z0 + (z1 bitShift: 8*third) + (z2 bitShift: 16*third) + (z3 + (z4 bitShift: 8*third) bitShift: 24*third)
]

{ #category : #testing }
LargePositiveInteger >> strictlyPositive [
	"Answer whether the receiver is mathematically positive."

	^ true
]

{ #category : #converting }
LargePositiveInteger >> withAtLeastNDigits: desiredLength [

	| new |

	self size >= desiredLength ifTrue: [^self].
	new := self class new: desiredLength.
	new
		replaceFrom: 1 
		to: self size 
		with: self 
		startingAt: 1.
	^new
]

{ #category : #comparing }
LargePositiveInteger >> ~= anInteger [ 
	"Primitive. Compare the receiver with the argument and answer if the
	 receiver is equal to the argument. Fail if the receiver or argument is not
	 an integer in the 64 bit range.
	Optional. See Object documentation whatIsAPrimitive."

	<primitive: 28>
	^super ~= anInteger
]
