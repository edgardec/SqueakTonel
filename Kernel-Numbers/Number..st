"
Class Number holds the most general methods for dealing with numbers. Subclasses Float, Fraction, and Integer, and their subclasses, provide concrete representations of a numeric quantity.

All of Number's subclasses participate in a simple type coercion mechanism that supports mixed-mode arithmetic and comparisons.  It works as follows:  If
	self<typeA> op: arg<typeB>
fails because of incompatible types, then it is retried in the following guise:
	(arg adaptTypeA: self) op: arg adaptToTypeA.
This gives the arg of typeB an opportunity to resolve the incompatibility, knowing exactly what two types are involved.  If self is more general, then arg will be converted, and viceVersa.  This mechanism is extensible to any new number classes that one might wish to add to Squeak.  The only requirement is that every subclass of Number must support a pair of conversion methods specific to each of the other subclasses of Number.
"
Class {
	#name : #Number,
	#superclass : #Magnitude,
	#category : #'Kernel-Numbers'
}

{ #category : #constants }
Number class >> one [

	^1
]

{ #category : #'instance creation' }
Number class >> readFrom: stringOrStream [ 
	"Answer a number as described on aStream.  The number may
	be any accepted Smalltalk literal Number format.
	It can include a leading radix specification, as in 16rFADE.
	It can as well be NaN, Infinity or -Infinity for conveniency.
	If stringOrStream does not start with a valid number description, fail."
	
	^(ExtendedNumberParser on: stringOrStream) nextNumber
]

{ #category : #'instance creation' }
Number class >> readFrom: stringOrStream base: base [
	"Answer a number as described on aStream in the given number base."

	^(SqNumberParser on: stringOrStream) nextNumberBase: base
]

{ #category : #'instance creation' }
Number class >> readFrom: stringOrStream ifFail: aBlock [
	"Answer a number as described on aStream.  The number may
	be any accepted Smalltalk literal Number format.
	It can include a leading radix specification, as in 16rFADE.
	It can as well be NaN, Infinity or -Infinity for conveniency.
	If input does not represent a valid number, then execute fail block
	and leave the stream positioned before offending character"
	
	^(ExtendedNumberParser on: stringOrStream) failBlock: aBlock; nextNumber
]

{ #category : #'instance creation' }
Number class >> readSmalltalkSyntaxFrom: stringOrStream [ 
	"Answer a number as described on aStream.  The number may
	be any accepted Smalltalk literal Number format.
	It can include a leading radix specification, as in 16rFADE.
	It can as well be NaN, Infinity or -Infinity for conveniency.
	If stringOrStream does not start with a valid number description, fail."
	
	^(SqNumberParser on: stringOrStream) nextNumber
]

{ #category : #constants }
Number class >> zero [
	^ 0.
]

{ #category : #arithmetic }
Number >> * aNumber [ 
	"Answer the result of multiplying the receiver by aNumber."

	self subclassResponsibility
]

{ #category : #'mathematical functions' }
Number >> ** aNumber [

	^ self raisedTo: aNumber
]

{ #category : #arithmetic }
Number >> + aNumber [ 
	"Answer the sum of the receiver and aNumber."

	self subclassResponsibility
]

{ #category : #arithmetic }
Number >> - aNumber [ 
	"Answer the difference between the receiver and aNumber."

	self subclassResponsibility
]

{ #category : #arithmetic }
Number >> / aNumber [ 
	"Answer the result of dividing the receiver by aNumber."

	self subclassResponsibility
]

{ #category : #arithmetic }
Number >> // aNumber [ 
	"Integer quotient defined by division with truncation toward negative 
	infinity. 9//4 = 2, -9//4 = -3. -0.9//0.4 = -3. \\ answers the remainder 
	from this division."

	^(self / aNumber) floor
]

{ #category : #arithmetic }
Number >> \\ aNumber [ 
	"modulo. Remainder defined in terms of //. Answer a Number with the 
	same sign as aNumber. e.g. 9\\4 = 1, -9\\4 = 3, 9\\-4 = -3, 0.9\\0.4 = 0.1."

	^self - (self // aNumber * aNumber)
]

{ #category : #arithmetic }
Number >> abs [
	"Answer a Number that is the absolute value (positive magnitude) of the 
	receiver."

	self < 0
		ifTrue: [^self negated]
		ifFalse: [^self]
]

{ #category : #converting }
Number >> adaptToCollection: rcvr andSend: selector [
	"If I am involved in arithmetic with a Collection, return a Collection of
	the results of each element combined with me in that expression."

	^ rcvr collect: [:element | element perform: selector with: self]
]

{ #category : #converting }
Number >> adaptToComplex: rcvr andSend: selector [
	"If I am involved in arithmetic with a Complex number, convert me to a Complex number."
	^ rcvr perform: selector with: self asComplex
]

{ #category : #converting }
Number >> adaptToFloat: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Float, convert rcvr to a
	Fraction. This way, no bit is lost and comparison is exact."
	
	rcvr isFinite
		ifFalse: [
			selector == #= ifTrue: [^false].
			selector == #~= ifTrue: [^true].
			rcvr isNaN ifTrue: [^ false].
			(selector = #< or: [selector = #'<='])
				ifTrue: [^ rcvr < 0.0].
			(selector = #> or: [selector = #'>='])
				ifTrue: [^ rcvr > 0.0].
			^self error: 'unknow comparison selector'].

	"Try to avoid asTrueFraction because it can cost"
	self isAnExactFloat ifTrue: [^rcvr perform: selector with: self asExactFloat].
	selector == #= ifTrue: [^false].
	selector == #~= ifTrue: [^true].
	^ rcvr asTrueFraction perform: selector with: self
]

{ #category : #converting }
Number >> adaptToFloat: rcvr andSend: selector [ 
	"If I am involved in arithmetic with a Float, convert me to a Float."
	^ rcvr perform: selector with: self asFloat
]

{ #category : #converting }
Number >> adaptToFraction: rcvr andSend: selector [
	"If I am involved in arithmetic with a Fraction, convert us and evaluate exprBlock."
	^ self subclassResponsibility
]

{ #category : #converting }
Number >> adaptToInteger: rcvr andSend: selector [
	"If I am involved in arithmetic with a Integer, convert us and evaluate exprBlock."
	^ self subclassResponsibility
]

{ #category : #converting }
Number >> adaptToPoint: rcvr andSend: selector [
	"If I am involved in arithmetic with a Point, convert me to a Point."
	^ rcvr perform: selector with: self@self
]

{ #category : #converting }
Number >> adaptToScaledDecimal: receiverScaledDecimal andSend: arithmeticOpSelector [ 
	"Do any required conversion and then the arithmetic. 
	receiverScaledDecimal arithmeticOpSelector self."
	#Numeric.
	"add 200/01/19 For ScaledDecimal support."
	^ self subclassResponsibility
]

{ #category : #converting }
Number >> adaptToString: rcvr andSend: selector [
	"If I am involved in arithmetic with a String, convert it to a Number."
	^ rcvr asNumber perform: selector with: self
]

{ #category : #'mathematical functions' }
Number >> arCosh [
	"Answer receiver's area hyperbolic cosine.
	That is the inverse function of cosh."

	^self asFloat arCosh
]

{ #category : #'mathematical functions' }
Number >> arSinh [
	"Answer receiver's area hyperbolic sine.
	That is the inverse function of sinh."

	^self asFloat arSinh
]

{ #category : #'mathematical functions' }
Number >> arTanh [
	"Answer receiver's area hyperbolic tangent.
	That is the inverse function of tanh."

	^self asFloat arTanh
]

{ #category : #'mathematical functions' }
Number >> arcCos [ 
	"The receiver is the cosine of an angle. Answer the angle measured in 
	radians."

	^self asFloat arcCos
]

{ #category : #'mathematical functions' }
Number >> arcSin [
	"The receiver is the sine of an angle. Answer the angle measured in 
	radians."

	^self asFloat arcSin
]

{ #category : #'mathematical functions' }
Number >> arcTan [
	"The receiver is the tangent of an angle. Answer the angle measured in 
	radians."

	^self asFloat arcTan
]

{ #category : #'mathematical functions' }
Number >> arcTan: denominator [
	"The receiver is the tangent of an angle. Answer the angle measured in 
	radians."

	^(self asFloat) arcTan: denominator.
]

{ #category : #arithmetic }
Number >> arg [
	"Answer the argument of the receiver (see Complex | arg)."
	
	self isZero ifTrue: [self error: 'Zero (0 + 0 i) does not have an argument.'].
	0 < self
		ifTrue: [^ 0]
		ifFalse: [^ Float pi]
]

{ #category : #converting }
Number >> asB3DVector3 [
	^self@self@self
]

{ #category : #converting }
Number >> asComplex [
	"Answer a Complex number that represents value of the the receiver."

	^ Complex real: self imaginary: 0
]

{ #category : #converting }
Number >> asExactFloat [
	"Convert this number asFloat with a priori knowledge that it is an exact Float.
	Some subclass might exploit this knowledge for a faster implementation.
	Only send this if self isAnExactFloat."
	^self asFloat
]

{ #category : #converting }
Number >> asFloatD [
	"Answer a d precision floating-point number approximating the receiver."
	#Numeric.
	"add 200/01/19 For ANSI <number> protocol."
	^ self asFloat
]

{ #category : #converting }
Number >> asFloatE [
	"Answer a floating-point number approximating the receiver."
	#Numeric.
	"add 200/01/19 For ANSI <number> protocol."
	^ self asFloat
]

{ #category : #converting }
Number >> asFloatQ [
	"Answer a floating-point number approximating the receiver."
	#Numeric.
	"add 200/01/19 For ANSI <number> protocol."
	^ self asFloat
]

{ #category : #converting }
Number >> asInteger [
	"Answer an Integer nearest the receiver toward zero."

	^self truncated
]

{ #category : #converting }
Number >> asNonFraction [	
	"Answer a number equivalent to the receiver that is not a fraction. See Fraction for active method."

	^self 
]

{ #category : #converting }
Number >> asNumber [
	^ self
]

{ #category : #converting }
Number >> asPoint [
	"Answer a Point with the receiver as both coordinates; often used to 
	supply the same value in two dimensions, as with symmetrical gridding 
	or scaling."

	^self @ self
]

{ #category : #converting }
Number >> asScaledDecimal [
	"Answer a scaled decimal number approximating the receiver."
	#Numeric.

	^ self asScaledDecimal: 8

]

{ #category : #converting }
Number >> asScaledDecimal: scale [ 
	"Answer a scaled decimal number, with a fractional precision of scale, 
	approximating the receiver."
	#Numeric.
	"add 200/01/19 For number protocol."
	^ ScaledDecimal newFromNumber: self scale: scale
]

{ #category : #converting }
Number >> asSmallAngleDegrees [
	"Return the receiver normalized to lie within the range (-180, 180)"

	| pos |
	pos := self \\ 360.
	pos > 180 ifTrue: [pos := pos - 360].
	^ pos

"#(-500 -300 -150 -5 0 5 150 300 500 1200) collect: [:n | n asSmallAngleDegrees]"
]

{ #category : #converting }
Number >> asSmallPositiveDegrees [
	"Return the receiver normalized to lie within the range (0, 360)"

	^self \\ 360
]

{ #category : #'filter streaming' }
Number >> byteEncode:aStream [
	^aStream writeNumber:self.

]

{ #category : #'truncation and round off' }
Number >> ceiling [
	"Answer the integer nearest the receiver toward  infinity."

	| truncation |
	truncation := self truncated.
	self <= 0 ifTrue: [^truncation].
	self = truncation
		ifTrue: [^truncation]
		ifFalse: [^truncation + 1]
]

{ #category : #comparing }
Number >> closeTo: num [
	"are these two numbers close?"

	num isFloat ifTrue: [^ num closeTo: self asFloat].
	^[self = num] ifError: [false]
]

{ #category : #'mathematical functions' }
Number >> copySignTo: aNumber [
	"Return a number with same magnitude as aNumber and same sign as self."

	^ self signBit = 0
		ifTrue: [aNumber abs]
		ifFalse: [aNumber abs negated].
]

{ #category : #'mathematical functions' }
Number >> cos [
	"The receiver represents an angle measured in radians. Answer its cosine."

	^self asFloat cos
]

{ #category : #'mathematical functions' }
Number >> cosh [
	"Answer receivers hyperbolic cosine."
	
	^self asFloat cosh
]

{ #category : #printing }
Number >> defaultLabelForInspector [
	"Answer the default label to be used for an Inspector window on the receiver."

	^ super defaultLabelForInspector, ': ', ([self printStringLimitedTo: 100]
		ifError: ['<error cannot print this number>'])
]

{ #category : #'mathematical functions' }
Number >> degreeCos [
	"Answer the cosine of the receiver taken as an angle in degrees."
	
	^ (90 - (180 + self \\ 360 - 180) abs) degreesToRadians sin
]

{ #category : #'mathematical functions' }
Number >> degreeSin [
	"Answer the sine of the receiver taken as an angle in degrees."
	
	^(90 - self) degreeCos
]

{ #category : #converting }
Number >> degreesToRadians [
	"The receiver is assumed to represent degrees. Answer the conversion to 
	radians."

	^self asFloat degreesToRadians
]

{ #category : #'truncation and round off' }
Number >> detentBy: detent atMultiplesOf: grid snap: snap [
	"Map all values that are within detent/2 of any multiple of grid to that multiple.  Otherwise, if snap is true, return self, meaning that the values in the dead zone will never be returned.  If snap is false, then expand the range between dead zones so that it covers the range between multiples of the grid, and scale the value by that factor."
	| r1 r2 |
	r1 := self roundTo: grid.  "Nearest multiple of grid"
	(self roundTo: detent) = r1 ifTrue: [^ r1].  "Snap to that multiple..."
	snap ifTrue: [^ self].  "...or return self"

	r2 := self < r1  "Nearest end of dead zone"
		ifTrue: [r1 - (detent asFloat/2)]
		ifFalse: [r1 + (detent asFloat/2)].
	"Scale values between dead zones to fill range between multiples"
	^ r1 + ((self - r2) * grid asFloat / (grid - detent))
"
	(170 to: 190 by: 2) collect: [:a | a detentBy: 10 atMultiplesOf: 90 snap: true] 	(170 to: 190 by: 2) collect: [:a | a detentBy: 10 atMultiplesOf: 90 snap: false]
	(3.9 to: 4.1 by: 0.02) collect: [:a | a detentBy: 0.1 atMultiplesOf: 1.0 snap: true] 	(-3.9 to: -4.1 by: -0.02) collect: [:a | a detentBy: 0.1 atMultiplesOf: 1.0 snap: false]
"
]

{ #category : #testing }
Number >> even [
	"Answer whether the receiver is an even number."

	^self \\ 2 = 0
]

{ #category : #'mathematical functions' }
Number >> exp [
	"Answer the exponential of the receiver as a floating point number."

	^self asFloat exp
]

{ #category : #'truncation and round off' }
Number >> floor [
	"Answer the integer nearest the receiver toward negative infinity."

	| truncation |
	truncation := self truncated.
	self >= 0 ifTrue: [^truncation].
	self = truncation
		ifTrue: [^truncation]
		ifFalse: [^truncation - 1]
]

{ #category : #'mathematical functions' }
Number >> floorLog: radix [
	"Answer the floor of the log base radix of the receiver."

	^(self log: radix) floor
]

{ #category : #'truncation and round off' }
Number >> fractionPart [
	
	"Added for ANSI compatibility"
	
	^self - self integerPart
]

{ #category : #converting }
Number >> i [
	^ Complex real: 0 imaginary: self
]

{ #category : #'truncation and round off' }
Number >> integerPart [
	"Added for ANSI compatibility"
	^self truncated
]

{ #category : #'mathematical functions' }
Number >> interpolateTo: aNumber at: param [
	^self + (aNumber - self * param)
]

{ #category : #testing }
Number >> isAnExactFloat [
	"Answer true if this Number can be converted exactly to a Float"
	^self subclassResponsibility
]

{ #category : #testing }
Number >> isDivisibleBy: aNumber [
	aNumber = 0 ifTrue: [^ false].
	aNumber isInteger ifFalse: [^ false].
	^ (self \\ aNumber) = 0
]

{ #category : #testing }
Number >> isInfinite [

	^ false
]

{ #category : #testing }
Number >> isNaN [
	^ false
]

{ #category : #testing }
Number >> isNumber [
	^ true
]

{ #category : #printing }
Number >> isOrAreStringWith: aNoun [
	| result |
	result := self = 1
		ifTrue:
			[' is one ']
		ifFalse:
			[self = 0
				ifTrue:
					[' are no ']
				ifFalse:
					[' are ', self printString, ' ']].
	result := result, aNoun.
	self = 1 ifFalse: [result := result, 's'].
	^ result

"#(0 1 2 98.6) do:
	[:num | Transcript cr; show: 'There', (num isOrAreStringWith: 'way'), ' to skin a cat']"
]

{ #category : #testing }
Number >> isZero [
	^self = 0
]

{ #category : #'mathematical functions' }
Number >> ln [
	"Answer the natural log of the receiver."

	^self asFloat ln
]

{ #category : #'mathematical functions' }
Number >> log [
	"Answer the base-10 log of the receiver."

	^self asFloat log
]

{ #category : #'mathematical functions' }
Number >> log2 [
	"Answer the base-2 log of the receiver."

	^self asFloat log2
]

{ #category : #'mathematical functions' }
Number >> log: aNumber [ 
	"Answer the log base aNumber of the receiver."

	aNumber = 2 ifTrue: [^self log2].
	aNumber isPowerOfTwo ifTrue: [^self log2 / aNumber log2].
	^self ln / aNumber ln
]

{ #category : #arithmetic }
Number >> negated [
	"Answer a Number that is the negation of the receiver."

	^0 - self
]

{ #category : #testing }
Number >> negative [
	"Answer whether the receiver is mathematically negative."

	^ self < 0
]

{ #category : #'mathematical functions' }
Number >> nthRoot: aPositiveInteger [
	"Answer the nth root of the receiver."

	self subclassResponsibility
]

{ #category : #testing }
Number >> odd [
	"Answer whether the receiver is an odd number."

	^self even == false
]

{ #category : #testing }
Number >> positive [
	"Answer whether the receiver is positive or equal to 0. (ST-80 protocol).
	See also strictlyPositive"

	^ self >= 0
]

{ #category : #printing }
Number >> printOn: aStream [
	self printOn: aStream base: 10
]

{ #category : #printing }
Number >> printOn: aStream base: base [
	"This method should print a representation of the number for the given base,
	excluding the base prefix (and the letter r for radix)"
	
	^self subclassResponsibility
]

{ #category : #printing }
Number >> printOn: aStream maxDecimalPlaces: placesDesired [
	"Print a representation of the receiver on aStream in decimal notation with at most prescribed number of places after decimal separator."

	| rounder rounded roundedFractionPart placesRequired shorten |
	placesDesired <= 0 ifTrue: [^ self rounded printOn: aStream].
	rounder := 10 raisedToInteger: placesDesired.
	rounded := self roundTo: rounder reciprocal.
	rounded negative ifTrue: [aStream nextPut: $-].
	rounded := rounded abs.
	rounded integerPart truncated printOn: aStream.
	roundedFractionPart := (rounded fractionPart * rounder) truncated.
	placesRequired := placesDesired.
	[roundedFractionPart = 0 ifTrue: [^self].
	(shorten := roundedFractionPart // 10) * 10 = roundedFractionPart]
		whileTrue:
			[placesRequired := placesRequired - 1.
			roundedFractionPart := shorten].
	placesRequired > 0
		ifTrue:
			[aStream nextPut: $..
			roundedFractionPart printOn: aStream base: 10 length: placesRequired padded: true]
]

{ #category : #printing }
Number >> printOn: aStream showingDecimalPlaces: placesDesired [
	"Print a representation of the receiver on aStream in decimal notation with prescribed number of places after decimal separator."

	| rounder rounded roundedFractionPart |
	placesDesired <= 0 ifTrue: [^ self rounded printOn: aStream].
	rounder := 10 raisedToInteger: placesDesired.
	rounded := self roundTo: rounder reciprocal.
	rounded negative ifTrue: [aStream nextPut: $-].
	rounded := rounded abs.
	rounded integerPart truncated printOn: aStream.
	aStream nextPut: $..
	roundedFractionPart := (rounded fractionPart * rounder) truncated.
	roundedFractionPart printOn: aStream base: 10 length: placesDesired padded: true
]

{ #category : #printing }
Number >> printShowingDecimalPlaces: placesDesired [
	"Print the receiver showing precisely the given number of places desired.  If placesDesired is positive, a decimal point and that many digits after the decimal point will always be shown.  If placesDesired is zero, a whole number will be shown, without a decimal point."

	^String new: placesDesired + 10 streamContents: [:aStream |
		self printOn: aStream showingDecimalPlaces: placesDesired]
"
23 printShowingDecimalPlaces: 2
23.5698 printShowingDecimalPlaces: 2
-234.567 printShowingDecimalPlaces: 5
23.4567 printShowingDecimalPlaces: 0
23.5567 printShowingDecimalPlaces: 0
-23.4567 printShowingDecimalPlaces: 0
-23.5567 printShowingDecimalPlaces: 0
100000000 printShowingDecimalPlaces: 1
0.98 printShowingDecimalPlaces: 5
-0.98 printShowingDecimalPlaces: 2
2.567 printShowingDecimalPlaces: 2
-2.567 printShowingDecimalPlaces: 2
0 printShowingDecimalPlaces: 2
"
]

{ #category : #printing }
Number >> printShowingMaxDecimalPlaces: placesDesired [
	"Print the receiver showing at most the given number of places desired after the decimal point.
	Trailing zeros of decimal part are discarded, so the number of digits after the decimal point may vary.
	When placesDesired is zero or negative, or when fraction part vanish, no decimal point is shown."

	^String new: placesDesired + 10 streamContents: [:aStream |
		self printOn: aStream maxDecimalPlaces: placesDesired]
]

{ #category : #printing }
Number >> printString [
	^self printStringBase: 10
]

{ #category : #printing }
Number >> printStringBase: base [
	^ String streamContents:
		[:strm | self printOn: strm base: base]
]

{ #category : #arithmetic }
Number >> quo: aNumber [ 
	"Integer quotient defined by division with truncation toward zero. -9 quo: 
	4 = -2, -0.9 quo: 0.4 = -2. rem: answers the remainder from this division."

	^(self / aNumber) truncated
]

{ #category : #converting }
Number >> radiansToDegrees [
	"The receiver is assumed to represent radians. Answer the conversion to 
	degrees."

	^self asFloat radiansToDegrees
]

{ #category : #'mathematical functions' }
Number >> raisedTo: aNumber [ 
	"Answer the receiver raised to aNumber."

	aNumber isInteger ifTrue: [
		"Do the special case of integer power"
		^ self raisedToInteger: aNumber].
	aNumber isFraction ifTrue: [
		"Special case for fraction power"
		^ self raisedToFraction: aNumber].
	self negative ifTrue: [
		^ ArithmeticError signal: 'Negative numbers can''t be raised to float powers.' ].
	aNumber isZero ifTrue: [^ self class one].	"Special case of exponent=0"
	1 = aNumber ifTrue: [^ self].	"Special case of exponent=1"
	self isZero ifTrue: [				"Special case of self = 0"
		aNumber negative
			ifTrue: [^ (ZeroDivide dividend: 1) signal]
			ifFalse: [^ self]].
	^ (aNumber * self ln) exp		"Otherwise use logarithms"
]

{ #category : #'mathematical functions' }
Number >> raisedToFraction: aFraction [
	self isZero
		ifTrue:
			[aFraction negative ifTrue: [^ (ZeroDivide dividend: 1) signal].
			^self].
	self negative ifFalse: [^(self ln * aFraction) exp].
	aFraction denominator even
		ifTrue: [^ ArithmeticError signal: 'nth root only defined for positive Integer n.'].
	^(self negated ln * aFraction) exp negated
]

{ #category : #'mathematical functions' }
Number >> raisedToInteger: anInteger [
	"The 0 raisedToInteger: 0 is an special case. In some contexts must be 1 and in others must
	be handled as an indeterminate form.
	I take the first context because that's the way that was previously handled.
	Maybe further discussion is required on this topic."
	
	| bitProbe result |
	anInteger negative ifTrue: [^(self raisedToInteger: anInteger negated) reciprocal].
	bitProbe := 1 bitShift: anInteger highBit - 1.
	result := self class one.
	[
		(anInteger bitAnd: bitProbe) > 0 ifTrue: [ result := result * self ].
		(bitProbe := bitProbe bitShift: -1) > 0 ]
		whileTrue: [ result := result squared ].
	^result
]

{ #category : #arithmetic }
Number >> reciprocal [
	"Returns the reciprocal of self.
	In case self is 0 the / signals ZeroDivide"
	
	^1 / self
]

{ #category : #'truncation and round off' }
Number >> reduce [
    "If self is close to an integer, return that integer"
    ^ self
]

{ #category : #arithmetic }
Number >> rem: aNumber [ 
	"Remainder defined in terms of quo:. Answer a Number with the same 
	sign as self. e.g. 9 rem: 4 = 1, -9 rem: 4 = -1. 0.9 rem: 0.4 = 0.1."

	^self - ((self quo: aNumber) * aNumber)
]

{ #category : #'truncation and round off' }
Number >> roundDownTo: aNumber [ 
	"Answer the next multiple of aNumber toward negative infinity that is nearest the 
	receiver."
 	"Examples:
		3.1479 roundDownTo: 0.01 -> 3.14
		3.1479 roundDownTo: 0.1 -> 3.1
		1923 roundDownTo: 10 -> 1920
		3.1479 roundDownTo: 0.005 -> 3.145
		-3.1479 roundDownTo: 0.01 -> -3.15"
		
	^(self/aNumber) floor * aNumber
]

{ #category : #'truncation and round off' }
Number >> roundTo: quantum [ 
	"Answer the nearest number that is a multiple of quantum."

	^(self / quantum) rounded * quantum
]

{ #category : #'truncation and round off' }
Number >> roundUpTo: aNumber [ 
	"Answer the next multiple of aNumber toward infinity that is nearest the 
	receiver."
 	"Examples:
		3.1479 roundUpTo: 0.01 -> 3.15
		3.1479 roundUpTo: 0.1 -> 3.2
		1923 roundUpTo: 10 -> 1930
		3.1479 roundUpTo: 0.005 -> 3.15
		-3.1479 roundUpTo: 0.01 -> -3.14"

	^(self/aNumber) ceiling * aNumber
]

{ #category : #'truncation and round off' }
Number >> rounded [
	"Answer the integer nearest the receiver."

	^(self + (self sign / 2)) truncated
]

{ #category : #'mathematical functions' }
Number >> sign [
	"Answer 1 if the receiver is greater than 0, -1 if less than 0, else 0."

	self > 0 ifTrue: [^1].
	self < 0 ifTrue: [^-1].
	^0
]

{ #category : #'mathematical functions' }
Number >> sign: aNumber [
	"Return a Number with the same sign as aNumber and same magnitude as self."

	^ aNumber copySignTo: self
]

{ #category : #'mathematical functions' }
Number >> signBit [
	"Answer 1 if the receiver is negative, zero otherwise."

	self < 0 ifTrue: [^1].
	^0
]

{ #category : #'mathematical functions' }
Number >> sin [
	"The receiver represents an angle measured in radians. Answer its sine."

	^self asFloat sin
]

{ #category : #'mathematical functions' }
Number >> sinh [
	"Answer receivers hyperbolic sine"
	
	^self asFloat sinh
]

{ #category : #'mathematical functions' }
Number >> sqrt [
	"Answer the square root of the receiver."

	self subclassResponsibility
]

{ #category : #'mathematical functions' }
Number >> squared [
	"Answer the receiver multipled by itself."

	^self * self
]

{ #category : #printing }
Number >> storeOn: aStream [ 
	self printOn: aStream
]

{ #category : #printing }
Number >> storeOn: aStream base: base [
	"This method should print a representation of the number for the given base,
	including the base prefix (with letter r for radix)"
	
	^self subclassResponsibility
]

{ #category : #printing }
Number >> storeStringBase: base [
	^ String streamContents: [:strm | self storeOn: strm base: base]
]

{ #category : #testing }
Number >> strictlyPositive [
	"Answer whether the receiver is mathematically positive."

	^ self > 0
]

{ #category : #printing }
Number >> stringForReadout [
	^ self rounded printString
]

{ #category : #'mathematical functions' }
Number >> tan [
	"The receiver represents an angle measured in radians. Answer its 
	tangent."

	^self asFloat tan
]

{ #category : #'mathematical functions' }
Number >> tanh [
	"Answer receivers hyperbolic tangent"
	
	^self asFloat tanh
]

{ #category : #intervals }
Number >> to: stop [
	"Answer an Interval from the receiver up to the argument, stop, 
	incrementing by 1."

	^Interval from: self to: stop by: 1
]

{ #category : #intervals }
Number >> to: stop by: step [
	"Answer an Interval from the receiver up to the argument, stop, 
	incrementing by step."

	^Interval from: self to: stop by: step
]

{ #category : #intervals }
Number >> to: stop by: step do: aBlock [ 
	"Normally compiled in-line, and therefore not overridable.
	Evaluate aBlock for each element of the interval (self to: stop by: 
step)."
	| nextValue |
	nextValue := self.
	step = 0 ifTrue: [self error: 'step must be non-zero'].
	step < 0
		ifTrue: [[stop <= nextValue]
				whileTrue: 
					[aBlock value: nextValue.
					nextValue := nextValue + step]]
		ifFalse: [[stop >= nextValue]
				whileTrue: 
					[aBlock value: nextValue.
					nextValue := nextValue + step]]
]

{ #category : #intervals }
Number >> to: stop do: aBlock [ 
	"Normally compiled in-line, and therefore not overridable.
	Evaluate aBlock for each element of the interval (self to: stop by: 1)."
	| nextValue |
	nextValue := self.
	[nextValue <= stop]
		whileTrue: 
			[aBlock value: nextValue.
			nextValue := nextValue + 1]
]

{ #category : #'truncation and round off' }
Number >> truncateTo: aNumber [ 
	"Answer the next multiple of aNumber toward zero that is nearest the 
	receiver."
	"Examples:
		3.1479 truncateTo: 0.01 -> 3.14
		3.1479 truncateTo: 0.1 -> 3.1
		1923 truncateTo: 10 -> 1920
		3.1479 truncateTo: 0.005 -> 3.145
		-3.1479 truncateTo: 0.01 -> -3.14"

	^(self quo: aNumber)
		* aNumber
]

{ #category : #'truncation and round off' }
Number >> truncated [
	"Answer an integer nearest the receiver toward zero."

	^self quo: 1
]

{ #category : #private }
Number >> veryDeepCopy [
	"Overridden for performance."
	^ self
]
