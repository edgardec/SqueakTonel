"
SqNumberParser is a NumberParser specialized in reading Number with Squeak syntax.

Squeak syntax follows general Smalltalk-80 conventions for integer and floats, extended with scaled decimals.
Noticeable differences with st-80 and other Smalltalks are:
- allow both 2r-10 and -2r10 and even -2r-10
- allow floating point with radix 2r10.011
- do not allow single s without following digits as ScaledDecimal
- handle special case of Float (NaN Infinity and -0.0 as negative zero)
"
Class {
	#name : #SqNumberParser,
	#superclass : #NumberParser,
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
SqNumberParser class >> on: aStringOrStream [
	^self new on: aStringOrStream
]

{ #category : #'instance creation' }
SqNumberParser class >> parse: aStringOrStream [ 
	^(self new)
		on: aStringOrStream;
		nextNumber
]

{ #category : #'instance creation' }
SqNumberParser class >> parse: aStringOrStream onError: failBlock [ 
	^(self new)
		on: aStringOrStream;
		failBlock: failBlock;
		nextNumber
]

{ #category : #accessing }
SqNumberParser >> allowPlusSign [
	"return a boolean indicating if plus sign is allowed or not"

	^false
]

{ #category : #accessing }
SqNumberParser >> exponentLetters [
	"answer the list of possible exponents for Numbers.
	Note: this parser will not honour precision attached to the exponent.
	different exponent do not lead to different precisions.
	only IEEE 754 floating point numbers will be created"
	
	^'edq'
]

{ #category : #'parsing-private' }
SqNumberParser >> makeIntegerOrScaledInteger [
	"At this point, there is no digit, nor fractionPart.
	 Maybe it can be a scaled decimal with fraction omitted...
	 Maybe it can be a Float with a negative exponent"
	
	neg ifTrue:
		[integerPart := integerPart negated].
	self readExponent ifTrue:
		["Check that the result is an integer, otherwise answer a Float.  Fractions are /not/ valid literals."
		 (exponent >= 0 or: [(integerPart * (base raisedToInteger: exponent)) isInteger]) ifFalse:
			[base := base asFloat].
		^integerPart * (base raisedToInteger: exponent)].
	(self readScaleWithDefaultNumberOfDigits: 0) ifTrue:
		[^integerPart asScaledDecimal: scale].
	^ integerPart
]

{ #category : #'parsing-private' }
SqNumberParser >> makeScaledDecimalWithNumberOfNonZeroFractionDigits: numberOfNonZeroFractionDigits andNumberOfTrailingZeroInFractionPart: numberOfTrailingZeroInFractionPart [
	"at this point integerPart fractionPart and scale have been read out (in inst var).
	Form a ScaledDecimal.
	Care of eliminating trailing zeroes from the fractionPart"
	
	| decimalMultiplier decimalFraction |
	decimalMultiplier := base raisedToInteger: numberOfNonZeroFractionDigits.
	decimalFraction := integerPart * decimalMultiplier + (fractionPart // (base raisedTo: numberOfTrailingZeroInFractionPart)) / decimalMultiplier.
	neg
		ifTrue: [decimalFraction := decimalFraction negated].
	^decimalFraction asScaledDecimal: scale
]

{ #category : #'parsing-public' }
SqNumberParser >> nextFraction [
	| numerator denominator numberOfTrailingZeroInIntegerPart |
	base := 10.
	neg := self peekSignIsMinus.
	(integerPart := self nextUnsignedIntegerOrNilBase: base)
		ifNil: ["No integerPart, raise an error"
			^ self expected: 'a digit'].
	numberOfTrailingZeroInIntegerPart := nDigits - lastNonZero.
	(sourceStream peekFor: $r)
		ifTrue: ["<base>r<integer>"
			(base := integerPart) < 2
				ifTrue: [
					sourceStream skip: -1.
					^ self expected: 'an integer greater than 1 as valid radix'].
			self peekSignIsMinus
				ifTrue: [neg := neg not].
			integerPart := self nextUnsignedIntegerBase: base.
			numberOfTrailingZeroInIntegerPart := nDigits - lastNonZero].
	(sourceStream peekFor: $.)
		ifTrue:
			[^self readFractionPartNumberOfTrailingZeroInIntegerPart: numberOfTrailingZeroInIntegerPart].
	numerator := neg
		ifTrue: [integerPart negated]
		ifFalse: [integerPart].
	self readExponent ifTrue: [numerator := numerator * (base raisedToInteger: exponent)].
	(sourceStream peekFor: $/) ifFalse: [^numerator].
	base := 10.
	(denominator := self nextUnsignedIntegerOrNilBase: base)
		ifNil:
			[sourceStream skip: -1. "Not a valid denominator, ungobble / and return numerator"
			^numerator].
	(sourceStream peekFor: $r)
		ifTrue: ["<base>r<integer>"
			(base := denominator) < 2
				ifTrue: [
					sourceStream skip: -1.
					^ self expected: 'an integer greater than 1 as valid radix'].
			denominator := self nextUnsignedIntegerBase: base].
	self readExponent ifTrue: [denominator := denominator * (base raisedToInteger: exponent)].
	^numerator / denominator
]

{ #category : #'parsing-public' }
SqNumberParser >> nextFractionBase: aRadix [
	| numerator denominator |
	base := aRadix.
	neg := self peekSignIsMinus.
	(integerPart := self nextUnsignedIntegerOrNilBase: base)
		ifNil: [^self expected: 'a digit between 0 and ' , (Character digitValue: aRadix)].
	numerator := neg
		ifTrue: [integerPart negated]
		ifFalse: [integerPart].
	self readExponent ifTrue: [numerator := numerator * (base raisedToInteger: exponent)].
	(sourceStream peekFor: $/) ifFalse: [^numerator].
	(denominator := self nextUnsignedIntegerOrNilBase: base)
		ifNil:
			[sourceStream skip: -1. "Not a valid denominator, ungobble / and return numerator"
			^numerator].
	self readExponent ifTrue: [denominator := denominator * (base raisedToInteger: exponent)].
	^numerator / denominator
]

{ #category : #'parsing-public' }
SqNumberParser >> nextInteger [
	"Read an Integer from sourceStream, asnwser that Integer.
	In Smalltalk syntax, a radix can be specified, and an exponent too."
	
	| numberOfTrailingZeroInIntegerPart |
	base := 10.
	neg := self peekSignIsMinus.
	integerPart := self nextUnsignedIntegerOrNilBase: base.
	numberOfTrailingZeroInIntegerPart := nDigits - lastNonZero.
	(sourceStream peekFor: $r)
		ifTrue: ["<base>r<integer>"
			(base := integerPart) < 2
				ifTrue: [
					sourceStream skip: -1.
					^ self expected: 'an integer greater than 1 as valid radix'].
			self peekSignIsMinus
				ifTrue: [neg := neg not].
			integerPart := self nextUnsignedIntegerBase: base.
			numberOfTrailingZeroInIntegerPart := nDigits - lastNonZero].
	^ self makeIntegerOrScaledInteger
]

{ #category : #'parsing-public' }
SqNumberParser >> nextNumber [
	"main method for reading a number.
	This one can read Float Integer and ScaledDecimal"
	
	| numberOfTrailingZeroInIntegerPart |
	base := 10.
	neg := self peekSignIsMinus.
	integerPart := self nextUnsignedIntegerOrNilBase: base.
	integerPart ifNil: [
		"This is not a regular number beginning with a digit
		It is time to check for exceptional condition NaN and Infinity"
		^self readNamedFloatOrFail].
	numberOfTrailingZeroInIntegerPart := nDigits - lastNonZero.
	(sourceStream peekFor: $r)
		ifTrue: ["<base>r<integer>"
			(base := integerPart) < 2
				ifTrue: [
					sourceStream skip: -1.
					^ self expected: 'an integer greater than 1 as valid radix'].
			self peekSignIsMinus
				ifTrue: [neg := neg not].
			integerPart := self nextUnsignedIntegerBase: base.
			numberOfTrailingZeroInIntegerPart := nDigits - lastNonZero].
	^ (sourceStream peekFor: $.)
		ifTrue: [self readNumberWithFractionPartNumberOfTrailingZeroInIntegerPart: numberOfTrailingZeroInIntegerPart]
		ifFalse: [self makeIntegerOrScaledInteger]
]

{ #category : #'parsing-public' }
SqNumberParser >> nextNumberBase: b [
	"Method for reading a number without radix prefix.
	This one can read Float Integer and ScaledDecimal"
	
	| numberOfTrailingZeroInIntegerPart |
	base := b.
	neg := sourceStream peekFor: $-.
	integerPart := self nextUnsignedIntegerOrNilBase: base.
	integerPart ifNil: [
		"This is not a regular number beginning with a digit
		It is time to check for exceptional condition NaN and Infinity"
		^self readNamedFloatOrFail].
	numberOfTrailingZeroInIntegerPart := nDigits - lastNonZero.
	^ (sourceStream peekFor: $.)
		ifTrue: [self readNumberWithFractionPartNumberOfTrailingZeroInIntegerPart: numberOfTrailingZeroInIntegerPart]
		ifFalse: [self makeIntegerOrScaledInteger]
]

{ #category : #'parsing-public' }
SqNumberParser >> nextScaledDecimal [
	"Main method for reading a (scaled) decimal number.
	Good Gracious, do not accept a decimal in another base than 10!
	In other words, do not accept radix notation like 2r1.1, even not 10r5.3
	Do not accept exponent notation neither, like 1.0e-3"
	
	| numberOfNonZeroFractionDigits numberOfTrailingZeroInFractionPart |
	base := 10.
	neg := sourceStream peekFor: $-.
	integerPart := self nextUnsignedIntegerBase: base.
	(sourceStream peekFor: $.)
		ifTrue: [fractionPart := self nextUnsignedIntegerOrNilBase: base.
			fractionPart ifNil: ["Oops, the decimal point seems not part of this number"
							sourceStream skip: -1.
							^ neg
								ifTrue: [integerPart negated asScaledDecimal: 0]
								ifFalse: [integerPart asScaledDecimal: 0]].
			numberOfNonZeroFractionDigits := lastNonZero.
			numberOfTrailingZeroInFractionPart := nDigits - lastNonZero.
			(self readScaleWithDefaultNumberOfDigits: nDigits)
				ifFalse: ["No scale were provided. use number of digits after decimal point as scale"
					scale := nDigits].
			^self makeScaledDecimalWithNumberOfNonZeroFractionDigits: numberOfNonZeroFractionDigits andNumberOfTrailingZeroInFractionPart: numberOfTrailingZeroInFractionPart].
	self readScaleWithDefaultNumberOfDigits: 0.
	neg	ifTrue: [integerPart := integerPart negated].
	^integerPart asScaledDecimal: scale
]

{ #category : #'parsing-public' }
SqNumberParser >> nextUnsignedInteger [
	"Read an unsigned Integer from sourceStream, asnwser that Integer.
	In Smalltalk syntax, a radix can be specified, and an exponent too."
	
	base := 10.
	neg := false.
	integerPart := self nextUnsignedIntegerOrNilBase: base.
	(sourceStream peekFor: $r)
		ifTrue: ["<base>r<integer>"
			(base := integerPart) < 2
				ifTrue: [
					sourceStream skip: -1.
					^ self expected: 'an integer greater than 1 as valid radix'].
			integerPart := self nextUnsignedIntegerBase: base].
	^ self makeIntegerOrScaledInteger
]

{ #category : #'parsing-private' }
SqNumberParser >> readFractionPartNumberOfTrailingZeroInIntegerPart: numberOfTrailingZeroInIntegerPart [
	"at this stage, sign integerPart and a decimal point have been read.
	try and form a number with a fractionPart"
	
	| numberOfNonZeroFractionDigits numberOfTrailingZeroInFractionPart mantissa value |
	fractionPart := self nextUnsignedIntegerOrNilBase: base.
	fractionPart ifNil: ["No fractionPart found, ungobble the decimal point and return the integerPart"
					sourceStream skip: -1.
					^ neg
						ifTrue: [integerPart negated]
						ifFalse: [integerPart]].
	numberOfNonZeroFractionDigits := lastNonZero.
	numberOfTrailingZeroInFractionPart := nDigits - lastNonZero.
	self readExponent.
	fractionPart isZero
		ifTrue: [mantissa := integerPart
						// (base raisedToInteger: numberOfTrailingZeroInIntegerPart).
			exponent := exponent + numberOfTrailingZeroInIntegerPart]
		ifFalse: [mantissa := integerPart
						* (base raisedToInteger: numberOfNonZeroFractionDigits) + (fractionPart // (base raisedToInteger: numberOfTrailingZeroInFractionPart)).
			exponent := exponent - numberOfNonZeroFractionDigits].

	value := exponent positive
		ifTrue: [mantissa * (base raisedToInteger: exponent)]
		ifFalse: [mantissa / (base raisedToInteger: exponent negated)].
	^ neg
		ifTrue: [value negated]
		ifFalse: [value]
]

{ #category : #'parsing-private' }
SqNumberParser >> readNamedFloatOrFail [
	"This method is used when there is no digit encountered:
	It try and read a named Float NaN or Infinity.
	Negative sign for -Infinity has been read before sending this method, and is indicated in the neg inst.var.
	Fail if no named Float is found"
		
	neg ifFalse: [(sourceStream nextMatchAll: 'NaN')
			ifTrue: [^ Float nan]].
	(sourceStream nextMatchAll: 'Infinity')
		ifTrue: [^ neg
			ifTrue: [Float negativeInfinity]
			ifFalse: [Float infinity]].
	^self expected: 'a digit between 0 and ' , (String with: (Character digitValue: base - 1))
]

{ #category : #'parsing-private' }
SqNumberParser >> readNumberWithFractionPartNumberOfTrailingZeroInIntegerPart: numberOfTrailingZeroInIntegerPart [
	"at this stage, sign integerPart and a decimal point have been read.
	try and form a number with a fractionPart"
	
	| numberOfNonZeroFractionDigits numberOfTrailingZeroInFractionPart mantissa value |
	fractionPart := self nextUnsignedIntegerOrNilBase: base.
	fractionPart ifNil: ["No fractionPart found,ungobble the decimal point and return the integerPart"
					sourceStream skip: -1.
					^ neg
						ifTrue: [integerPart negated]
						ifFalse: [integerPart]].
	numberOfNonZeroFractionDigits := lastNonZero.
	numberOfTrailingZeroInFractionPart := nDigits - lastNonZero.
	self readExponent
		ifFalse: [(self readScaleWithDefaultNumberOfDigits: nDigits)
				ifTrue: [^self makeScaledDecimalWithNumberOfNonZeroFractionDigits: numberOfNonZeroFractionDigits
					andNumberOfTrailingZeroInFractionPart: numberOfTrailingZeroInFractionPart]].

	fractionPart isZero
		ifTrue: [mantissa := integerPart
						// (base raisedToInteger: numberOfTrailingZeroInIntegerPart).
			exponent := exponent + numberOfTrailingZeroInIntegerPart]
		ifFalse: [mantissa := integerPart
						* (base raisedToInteger: numberOfNonZeroFractionDigits) + (fractionPart // (base raisedToInteger: numberOfTrailingZeroInFractionPart)).
			exponent := exponent - numberOfNonZeroFractionDigits].

	value := self makeFloatFromMantissa: mantissa exponent: exponent base: base.
	^ neg
		ifTrue: [value isZero
				ifTrue: [Float negativeZero]
				ifFalse: [value negated]]
		ifFalse: [value]
]

{ #category : #'parsing-private' }
SqNumberParser >> readScaleWithDefaultNumberOfDigits: anInteger [
	"Read the scale if any and store it into scale instance Variable.
	Answer true if found, answer false if none.
	The scale is specified by letter s, optionnally followed by a positive integer in base 10.
	If no integer is specified, that means using as many digits as provided after the fraction separator, as provided by parameter anInteger.
	A letter s followed by another letter is not considered as a scale specification, because it could be part of a message."

	scale := 0.
	sourceStream atEnd
		ifTrue: [ ^ false ].
	(sourceStream peekFor: $s)
		ifFalse: [ ^ false ].
	scale := self nextUnsignedIntegerOrNilBase: 10.
	scale
		ifNil: [ 
			scale := anInteger.
			(sourceStream peek ifNil: [ false ] ifNotNil: [ :nextChar | nextChar isLetter ])
				ifTrue: [ 
					sourceStream skip: -1.	"ungobble the s"
					^ false ]
				ifFalse: [ ^ true ] ].
	^ true
]
