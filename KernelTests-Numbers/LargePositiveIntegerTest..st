Class {
	#name : #LargePositiveIntegerTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Numbers'
}

{ #category : #asserting }
LargePositiveIntegerTest >> assertSqrtCorrectlyRoundedForExponent: exp [
	"Requires exp > Float precision, so that f ulp/2 is integer"
	{1.5. 1.25 squared. 2.0 predecessor} do: [:sf |
		| f xe xp xm |
		
		f := sf timesTwoPower: exp.
	
		"make two integers around the pivot"
		xe := f asInteger + (f ulp asInteger / 2).
		xm := xe squared - 1.
		xp := xe squared + 1.
		self assert: xe squared sqrt equals: xe.
		self assert: xe squared sqrt isInteger.
	
		"check rounding when result is near f squared"
		self assert: xm sqrt equals: f.
		self assert: xm sqrt isFloat.
		self assert: xp sqrt equals: f successor.
		self assert: xp sqrt isFloat.
	
		"same in the other direction"
		xe := f asInteger - (f ulp asInteger / 2).
		xm := xe squared - 1.
		xp := xe squared + 1.
		self assert: xe squared sqrt equals: xe.
		self assert: xe squared sqrt isInteger.
	
		"check rounding when result is near f squared"
		self assert: xm sqrt equals: f predecessor.
		self assert: xm sqrt isFloat.
		self assert: xp sqrt equals: f.
		self assert: xp sqrt isFloat].
]

{ #category : #tests }
LargePositiveIntegerTest >> testBitShift [

	"Check bitShift from and back to SmallInts"
	
	1 to: 257 do: [:i | self should: [((i bitShift: i) bitShift: 0-i) == i]].
]

{ #category : #tests }
LargePositiveIntegerTest >> testDenormalizedPrintString [
	"Check that an un-normalized instance behaves reasonably."

	| i i0 |
	i := LargePositiveInteger new: 4.
	i basicAt: 2 put: 255.
	self assert: i size = 4.
	self assert: i printString = '65280'.	"256*255"
	self assert: i normalize = 65280.
	self assert: (i normalize isMemberOf: SmallInteger).
	
	i0 := LargePositiveInteger new: 0.
	self assert: i0 size = 0.
	self assert: i0 printString = '0'.
	self assert: i0 normalize = 0.
	self assert: (i0 normalize isMemberOf: SmallInteger)
]

{ #category : #tests }
LargePositiveIntegerTest >> testDigitAt [

	| lpi |
	lpi := 114605103402541699037609980192546360895434064385.
	1 to: 20 do: [:i | | digit |
		digit := lpi digitAt: i.
		self assert: i equals: digit]

]

{ #category : #tests }
LargePositiveIntegerTest >> testDigitAtPut [

	| lpi |
	lpi := LargePositiveInteger new: 20.
	1 to: 20 do: [:i | lpi digitAt: i put: i].
	self assert: 114605103402541699037609980192546360895434064385equals: lpi

]

{ #category : #tests }
LargePositiveIntegerTest >> testDigitDiv [
	| a b q r qr ap bp |
	ap := self x23kbits.
	bp := self x13kbits.
	self assert: (ap digitDivSplit: bp) = ((ap digitDiv: bp neg: false) collect: #normalize).
	#(#yourself #negated) do: [:opa | 
		#(#yourself #negated) do: [:opb | 
			a := ap perform: opa.
			b := bp perform: opb.
			qr := a digitDiv: b neg: opa ~~ opb.
			q := qr first normalize.
			r := qr last normalize.
			self assert: q * b + r = a.
			self assert: r abs < b abs.
			self assert: a positive ==> r positive.
			self assert: a negative ==> (r negative | r isZero)]]
	
]

{ #category : #tests }
LargePositiveIntegerTest >> testDigitLength [

	| lpi |
	lpi := 114605103402541699037609980192546360895434064385.
	self assert: 20 equals: lpi digitLength

]

{ #category : #tests }
LargePositiveIntegerTest >> testEmptyTemplate [

	"Check that an uninitialized instance behaves reasonably."

	| i |
	i := LargePositiveInteger new: 4.
	self assert: i size = 4.
	self assert: i printString = '0'.
	self assert: i normalize = 0.
	self assert: (i normalize isMemberOf: SmallInteger)
]

{ #category : #tests }
LargePositiveIntegerTest >> testFastMultiply [
	| a b ab ap bp |
	ap := self x92kbits.
	bp := self x106kbits.
	#(#yourself #negated) do: [:opa | 
		#(#yourself #negated) do: [:opb | 
			a := ap perform: opa.
			b := bp perform: opb.
			ab := a * b.
			self assert: (a multiplyByInteger: b) = ab.
			self assert: (a digitMultiply: b neg: a negative ~~ b negative) = ab.
			self assert: (a digitMul22: b) = ab.
			self assert: (a digitMul23: b) = ab.
			self assert: (a digitMul33: b) = ab]]
]

{ #category : #tests }
LargePositiveIntegerTest >> testLargeSqrtFloor [
	"This test fails if a careless implementation naivly factors out the power of two (remove the trailing zeroes up to lowBit).
	This was the case in a previous Squeak 4.x implementation."

	| large root |
	large := (SmallInteger maxVal << 100 + 1) << 100.
	root := large sqrtFloor.
	self assert: root squared <= large.
	self assert: (root+1) squared > large.
]

{ #category : #tests }
LargePositiveIntegerTest >> testMultDicAddSub [
	"self run: #testMultDicAddSub"

	| n f f1 |	
	n := 100.
	f := 100 factorial.
	f1 := f*(n+1).
	n timesRepeat: [f1 := f1 - f].
	self assert: (f1 = f). 

	n timesRepeat: [f1 := f1 + f].
	self assert: (f1 // f = (n+1)). 
	self assert: (f1 negated = (Number readFrom: '-' , f1 printString)).
]

{ #category : #tests }
LargePositiveIntegerTest >> testNormalize [
	"self run: #testNormalize"
	"Check normalization and conversion to/from SmallInts"

	self assert: ((SmallInteger maxVal + 1 - 1) == SmallInteger maxVal).
	self assert: (SmallInteger maxVal + 3 - 6) == (SmallInteger maxVal-3).
	self should: ((SmallInteger minVal - 1 + 1) == SmallInteger minVal).
	self assert: (SmallInteger minVal - 3 + 6) == (SmallInteger minVal+3).
]

{ #category : #tests }
LargePositiveIntegerTest >> testReciprocalModulo [
	| large r |
	large := 1 bitShift: 48.
	r := Random seed: 46912151.
	4691 timesRepeat:
		[| a b c t |
		a := (r nextInt: large) + 1.
		b := (r nextInt: large) + 1.
		a > b ifTrue: [t := a. a:= b. b := t].
		(a gcd: b) = 1
			ifTrue:
				[c := a reciprocalModulo: b.
				self assert: (a * c) \\ b = 1.]
			ifFalse: [self should: [ a reciprocalModulo: b ] raise: Error]].
]

{ #category : #tests }
LargePositiveIntegerTest >> testReplaceFromToWithStartingAt [

	| lpi20 lpi7 |
	lpi20 := LargePositiveInteger new: 20.
	1 to: 20 do: [:i | lpi20 digitAt: i put: i].
	lpi7 := LargePositiveInteger new: 7.
	1 to: 7 do: [:i | lpi7 digitAt: i put: 11 - i].
	lpi20 replaceFrom: 6 to: 10 with: lpi7 startingAt: 2.
	"unmodified digits"
	(1 to: 5) , (11 to: 20) do: [:e | | digit |
		digit := lpi20 digitAt: e.
		self assert: e equals: digit].
	"replaced digits"
	6 to: 10 do: [:e | | digit replacementDigit |
		digit := lpi20 digitAt: e.
		replacementDigit := lpi7 digitAt: e - 4.
		self assert: replacementDigit equals: digit]

]

{ #category : #'tests - mathematical functions' }
LargePositiveIntegerTest >> testSqrt [
	self assert: (SmallInteger maxVal + 1) sqrt equals: (SmallInteger maxVal + 1) asFloat sqrt.
]

{ #category : #'tests - mathematical functions' }
LargePositiveIntegerTest >> testSqrtCorrectlyRounded [
	self assertSqrtCorrectlyRoundedForExponent: Float precision * 2 - 1.
	self assertSqrtCorrectlyRoundedForExponent: Float precision * 2 + 1.
	self assertSqrtCorrectlyRoundedForExponent: Float precision * 2 + 3.
	self assertSqrtCorrectlyRoundedForExponent: Float precision * 3 // 2.
	self assertSqrtCorrectlyRoundedForExponent: Float emax* 2 // 3. "such that asFloat would overflow"
	self assertSqrtCorrectlyRoundedForExponent: Float emax.
]

{ #category : #tests }
LargePositiveIntegerTest >> testSqrtRem [
	| x sr |
	x := self x92kbits.
	sr := x sqrtRem.
	self assert: sr first squared <= x.
	self assert: (sr first+1) squared > x.
	self assert: sr first squared + sr last = x.
]

{ #category : #tests }
LargePositiveIntegerTest >> testSquared [

	| large ref |
	large := self x23kbits.
	ref := large * large.
	self assert: ref = large squared.
	self assert: ref = large squaredByHalf.
	self assert: ref = large squaredByThird.
	self assert: ref = large squaredByFourth.
]

{ #category : #accessing }
LargePositiveIntegerTest >> x106kbits [
	"Return a 106 kilo bits integer"
	^(15 to: 55 by: 4)
				inject: 9876543210
				into: [:big :bits | big * big << bits + bits]
]

{ #category : #accessing }
LargePositiveIntegerTest >> x13kbits [
	"Return a 13 kilo bits integer"
	^(15 to: 44 by: 4)
				inject: 9753102468
				into: [:big :bits | big * big << bits + bits]
]

{ #category : #accessing }
LargePositiveIntegerTest >> x23kbits [
	"Return a 23 kilo bits integer"
	^(11 to: 44 by: 4)
			inject: 1234567890
			into: [:big :bits | big * big << bits + bits]
]

{ #category : #accessing }
LargePositiveIntegerTest >> x92kbits [
	"Return a 92 kilo bits integer"
	^(11 to: 51 by: 4)
			inject: 1357924680
			into: [:big :bits | big * big << bits + bits]
]
