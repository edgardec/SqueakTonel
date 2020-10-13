"
My instances represent IEEE-754 floating-point double-precision numbers.  They have about 16 digits of accuracy and their range is between plus and minus 10^307. Some valid examples are:
	
	8.0 13.3 0.3 2.5e6 1.27e-30 1.27e-31 -12.987654e12

Mainly: no embedded blanks, little e for tens power, and a digit on both sides of the decimal point.  It is actually possible to specify a radix for Squeak Float constants.  This is great for teaching about numbers, but may be confusing to the average reader:

	3r20.2 --> 6.66666666666667
	8r20.2 --> 16.25

If you don't have access to the definition of IEEE-754, you can figure out what is going on by printing various simple values in Float hex.  It may help you to know that the basic format is...
	sign		1 bit
	exponent	11 bits with bias of 1023 (16r3FF) to produce an exponent
						in the range -1023 .. +1024
				- 16r000:
					significand = 0: Float zero
					significand ~= 0: Denormalized number (exp = -1024, no hidden '1' bit)
				- 16r7FF:
					significand = 0: Infinity
					significand ~= 0: Not A Number (NaN) representation
	mantissa	53 bits, but only 52 are stored (20 in the first word, 32 in the second).  This is because a normalized mantissa, by definition, has a 1 to the right of its floating point, and IEEE-754 omits this redundant bit to gain an extra bit of precision instead.  People talk about the mantissa without its leading one as the FRACTION, and with its leading 1 as the SIGNFICAND.

The single-precision format is...
	sign		1 bit
	exponent	8 bits, with bias of 127, to represent -126 to +127
                    - 0x0 and 0xFF reserved for Float zero (mantissa is ignored)
                    - 16r7F reserved for Float underflow/overflow (mantissa is ignored)
	mantissa	24 bits, but only 23 are stored
This format is used in FloatArray (qv), and much can be learned from the conversion routines, Float asIEEE32BitWord, and Float class fromIEEE32Bit:.

Thanks to Rich Harmon for asking many questions and to Tim Olson, Bruce Cohen, Rick Zaccone and others for the answers that I have collected here.
"
Class {
	#name : #Float,
	#superclass : #Number,
	#classVars : [
		'E',
		'Epsilon',
		'Halfpi',
		'Infinity',
		'Ln10',
		'Ln2',
		'MaxVal',
		'MaxValLn',
		'MinValLogBase2',
		'NaN',
		'NegativeInfinity',
		'NegativeZero',
		'Pi',
		'RadiansPerDegree',
		'Sqrt2',
		'ThreePi',
		'Twopi'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
Float class >> basicNew [
	^BoxedFloat64 basicNew: 2
]

{ #category : #'instance creation' }
Float class >> basicNew: anInteger [
	^BoxedFloat64 basicNew: 2
]

{ #category : #constants }
Float class >> denormalized [
	"Answer whether implementation supports denormalized numbers (also known as gradual underflow)."
	
	^true
]

{ #category : #constants }
Float class >> e [
	"Answer the constant, E."

	^E
]

{ #category : #constants }
Float class >> emax [
	"Answer exponent of maximal representable value"
	
	^1023
]

{ #category : #constants }
Float class >> emin [
	"Answer exponent of minimal normalized representable value"
	
	^-1022
]

{ #category : #constants }
Float class >> epsilon [
	"Answer difference between 1.0 and previous representable value"
	
	^1.0 timesTwoPower: 1 - self precision
]

{ #category : #constants }
Float class >> fmax [
	"Answer the maximum finite floating point value representable."
	
	^MaxVal
]

{ #category : #constants }
Float class >> fmin [
	"Answer minimum positive representable value."
	
	^self denormalized
		ifTrue: [self fminDenormalized]
		ifFalse: [self fminNormalized]
]

{ #category : #constants }
Float class >> fminDenormalized [
	"Answer the minimum denormalized value representable."
	
	^1.0 timesTwoPower: MinValLogBase2
]

{ #category : #constants }
Float class >> fminNormalized [
	"Answer the minimum normalized value representable."
	
	^1.0 timesTwoPower: -1022
]

{ #category : #'instance creation' }
Float class >> fromIEEE32Bit: word [
	"Convert the given 32 bit word (which is supposed to be a positive 32-bit value) from
	 a 32 bit IEEE floating point representation into an actual Squeak float object (being
	 64 bits wide). Should only be used for conversion in FloatArrays or likewise objects."
	
	| sign mantissa exponent delta |
	word <= 0 ifTrue:
		[^word negative
			ifTrue: [self error: 'Cannot deal with negative numbers']
			ifFalse: [self zero]].
	sign := word bitAnd: 16r80000000.
	word = sign ifTrue:
		[^self negativeZero].
	
	exponent := ((word bitShift: -23) bitAnd: 16rFF) - 127.
	mantissa := word bitAnd:  16r7FFFFF.

	exponent = 128 ifTrue: "Either NAN or INF"
		[^mantissa = 0
			ifTrue:
				[sign = 0 
					ifTrue: [self infinity]
					ifFalse: [self negativeInfinity]]
			ifFalse: [self nan]].

	exponent = -127 ifTrue:
		"gradual underflow (denormalized number)
		 Remove first bit of mantissa and adjust exponent"
		[delta := mantissa highBit.
		 mantissa := (mantissa bitAnd: (1 bitShift: delta - 1) - 1) bitShift: 24 - delta.
		 exponent := exponent + delta - 23].
	
	"Create new float"
	^(self basicNew: 2)
		basicAt: 1 put: ((sign bitOr: (1023 + exponent bitShift: 20)) bitOr: (mantissa bitShift: -3));
		basicAt: 2 put: ((mantissa bitAnd: 7) bitShift: 29);
		* 1.0 "reduce to SmallFloat64 if possible"
]

{ #category : #'instance creation' }
Float class >> fromIEEE64Bit: anInteger [
	"Convert the given 64 bit word (which is supposed to be a positive 64-bit value) from
	  a 64 bit IEEE floating point representation into an actual Squeak float object (being
	  64 bits wide). Should only be used for conversion in FloatArrays or likewise objects."
	| value |
	value := self basicNew: 2.
	value
		basicAt: 1 put: (anInteger bitShift: -32);
		basicAt: 2 put: (anInteger bitAnd: 16rFFFFFFFF).
	^value isFinite
		ifTrue: [value * 1.0] "reduce to SmallFloat64 if possible"
		ifFalse: [value]
]

{ #category : #constants }
Float class >> halfPi [
	^ Halfpi
]

{ #category : #constants }
Float class >> infinity [
	"Answer the value used to represent an infinite magnitude"

	^ Infinity
]

{ #category : #'class initialization' }
Float class >> initialize [
	"Float initialize"
	"Constants from Computer Approximations, pp. 182-183:
		Pi = 3.14159265358979323846264338327950288
		Pi/2 = 1.57079632679489661923132169163975144
		Pi*2 = 6.28318530717958647692528676655900576
		Pi/180 = 0.01745329251994329576923690768488612
		2.0 ln = 0.69314718055994530941723212145817657
		2.0 sqrt = 1.41421356237309504880168872420969808"

	Pi := 3.14159265358979323846264338327950288.
	Halfpi := Pi / 2.0.
	Twopi := Pi * 2.0.
	ThreePi := Pi * 3.0.
	RadiansPerDegree := Pi / 180.0.

	Ln2 := 0.69314718055994530941723212145817657.
	Ln10 := 10.0 ln.
	Sqrt2 := 1.41421356237309504880168872420969808.
	E := 2.718281828459045235360287471353.

	Epsilon := 0.000000000001.  "Defines precision of mathematical functions"

	MaxVal := 1.7976931348623157e308.
	MaxValLn := 709.782712893384.
	MinValLogBase2 := -1074.

	Infinity := MaxVal * MaxVal.
	NegativeInfinity := 0.0 - Infinity.
	NaN := Infinity - Infinity.
	NegativeZero := 1.0 / Infinity negated.

	{Infinity. NegativeInfinity. NaN} do: [:each| each beReadOnlyObject]

]

{ #category : #constants }
Float class >> ln10 [
	^ Ln10
]

{ #category : #constants }
Float class >> ln2 [
	^ Ln2
]

{ #category : #constants }
Float class >> maxExactInteger [
	"Answer the biggest integer such that it is exactly represented in a float, and all smaller integers also are"
	^1 bitShift: self precision
]

{ #category : #constants }
Float class >> nan [
	"Answer the canonical value used to represent Not-A-Number"

	^ NaN
]

{ #category : #constants }
Float class >> negativeInfinity [
	"Answer the value used to represent a negative infinity."
	^ NegativeInfinity
]

{ #category : #constants }
Float class >> negativeZero [

	^ NegativeZero
]

{ #category : #constants }
Float class >> one [
	
	^1.0
]

{ #category : #constants }
Float class >> pi [
	"Answer the constant, Pi."

	^Pi
]

{ #category : #constants }
Float class >> precision [
	"Answer the apparent precision of the floating point representation.
	That is the maximum number of radix-based digits (bits if radix=2) representable in floating point without round off error.
	Technically, 52 bits are stored in the representation, and normalized numbers have an implied leading 1 that does not need to be stored.
	Note that denormalized floating point numbers don't have the implied leading 1, and thus gradually loose precision.
	This format conforms IEEE 754 double precision standard."
	
	^53
]

{ #category : #constants }
Float class >> radix [
	"Answer the radix used for internal floating point representation."
	
	^2
]

{ #category : #'instance creation' }
Float class >> readFrom: aStream [ 
	"Answer a new Float as described on the stream, aStream."

	^(super readFrom: aStream) asFloat
]

{ #category : #'instance creation' }
Float class >> readFrom: aStream ifFail: aBlock [
	"Answer a new Float as described on the stream, aStream."

	^(super readFrom: aStream ifFail: [^aBlock value]) asFloat
]

{ #category : #constants }
Float class >> sqrt2 [

	^ Sqrt2
]

{ #category : #constants }
Float class >> threePi [

	^ ThreePi

]

{ #category : #constants }
Float class >> twoPi [

	^ Twopi

]

{ #category : #constants }
Float class >> zero [
	^ 0.0.
]

{ #category : #arithmetic }
Float >> abs [
	"This is faster than using Number abs and works for negativeZero."
	self <= 0.0
		ifTrue: [^ 0.0 - self]
		ifFalse: [^ self]
]

{ #category : #printing }
Float >> absByteEncode: aStream base: base [
	"Print my value on a stream in the given base.  Assumes that my value is strictly
	positive; negative numbers, zero, and NaNs have already been handled elsewhere.
	Based upon the algorithm outlined in:
	Robert G. Burger and R. Kent Dybvig
	Printing Floating Point Numbers Quickly and Accurately
	ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
	June 1996.
	This version performs all calculations with Floats instead of LargeIntegers, and loses
	about 3 lsbs of accuracy compared to an exact conversion."

	| significantBits fBase exp baseExpEstimate r s mPlus mMinus scale d tc1 tc2 fixedFormat decPointCount |
	self isInfinite ifTrue: [aStream print: 'Infinity'. ^ self].
	significantBits := 50.  "approximately 3 lsb's of accuracy loss during conversion"
	fBase := base asFloat.
	exp := self exponent.
	baseExpEstimate := (exp * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue:
			[r := self.
			s := 1.0.
			mPlus := 1.0 timesTwoPower: exp - significantBits.
			mMinus := self significand ~= 1.0 ifTrue: [mPlus] ifFalse: [mPlus / 2.0]]
		ifFalse:
			[r := self timesTwoPower: significantBits.
			s := 1.0 timesTwoPower:  significantBits.
			mMinus := 1.0 timesTwoPower: (exp max: -1024).
			mPlus :=
				(exp = MinValLogBase2) | (self significand ~= 1.0)
					ifTrue: [mMinus]
					ifFalse: [mMinus * 2.0]].
	baseExpEstimate >= 0
		ifTrue:
			[s := s * (fBase raisedToInteger: baseExpEstimate).
			exp = 1023
				ifTrue:   "scale down to prevent overflow to Infinity during conversion"
					[r := r / fBase.
					s := s / fBase.
					mPlus := mPlus / fBase.
					mMinus := mMinus / fBase]]
		ifFalse:
			[exp < -1023
				ifTrue:   "scale up to prevent denorm reciprocals overflowing to Infinity"
					[d := (53 * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
					scale := fBase raisedToInteger: d.
					r := r * scale.
					mPlus := mPlus * scale.
					mMinus := mMinus * scale.
					scale := fBase raisedToInteger: (baseExpEstimate + d) negated]
				ifFalse:
				[scale := fBase raisedToInteger: baseExpEstimate negated].
			s := s / scale].
	(r + mPlus >= s)
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[s := s / fBase].
	(fixedFormat := baseExpEstimate between: -3 and: 6)
		ifTrue:
			[decPointCount := baseExpEstimate.
			baseExpEstimate <= 0
				ifTrue: [aStream print: ('0.000000' truncateTo: 2 - baseExpEstimate)]]
		ifFalse:
			[decPointCount := 1].
	[d := (r / s) truncated.
	r := r - (d * s).
	(tc1 := r <= mMinus) | (tc2 := r + mPlus >= s)] whileFalse:
		[aStream print: (Character digitValue: d).
		r := r * fBase.
		mPlus := mPlus * fBase.
		mMinus := mMinus * fBase.
		decPointCount := decPointCount - 1.
		decPointCount = 0 ifTrue: [aStream print: $.]].
	tc2 ifTrue:
		[tc1 not | (tc1 & (r*2.0 >= s)) ifTrue: [d := d + 1]].
	aStream print: (Character digitValue: d).
	decPointCount > 0
		ifTrue:
		[decPointCount - 1 to: 1 by: -1 do: [:i | aStream print: $0].
		aStream print: '.0'].
	fixedFormat ifFalse:
		[aStream print: $e.
		aStream print: (baseExpEstimate - 1) printString]
]

{ #category : #printing }
Float >> absPrintExactlyOn: aStream base: base [
	"Print my value on a stream in the given base.  Assumes that my value is strictly
	positive; negative numbers, zero, and NaNs have already been handled elsewhere.
	Based upon the algorithm outlined in:
	Robert G. Burger and R. Kent Dybvig
	Printing Floating Point Numbers Quickly and Accurately
	ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
	June 1996.
	This version guarantees that the printed representation exactly represents my value
	by using exact integer arithmetic."

	| significand exp baseExpEstimate r s mPlus mMinus scale roundingIncludesLimits d tc1 tc2 fixedFormat decPointCount slowbit shead |
	self isInfinite ifTrue: [aStream nextPutAll: 'Infinity'. ^ self].
	significand := self significandAsInteger.
	roundingIncludesLimits := significand even.
	exp := (self exponent - 52) max: MinValLogBase2.
	baseExpEstimate := (self exponent * base asFloat reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue:
			[significand ~= 16r10000000000000
				ifTrue:
					[r := significand bitShift: 1 + exp.
					s := 2.
					mPlus := mMinus := 1 bitShift: exp]
				ifFalse:
					[r := significand bitShift: 2 + exp.
					s := 4.
					mPlus := 2 * (mMinus := 1 bitShift: exp)]]
		ifFalse:
			[(exp = MinValLogBase2 or: [significand ~= 16r10000000000000])
				ifTrue:
					[r := significand bitShift: 1.
					s := 1 bitShift: 1 - exp.
					mPlus := mMinus := 1]
				ifFalse:
					[r := significand bitShift: 2.
					s := 1 bitShift: 2 - exp.
					mPlus := 2.
					mMinus := 1]].
	baseExpEstimate >= 0
		ifTrue: [s := s * (base raisedToInteger: baseExpEstimate)]
		ifFalse:
			[scale := base raisedToInteger: baseExpEstimate negated.
			r := r * scale.
			mPlus := mPlus * scale.
			mMinus := mMinus * scale].
	((r + mPlus >= s) and: [roundingIncludesLimits or: [r + mPlus > s]])
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[r := r * base.
			mPlus := mPlus * base.
			mMinus := mMinus * base].
	(fixedFormat := baseExpEstimate between: -3 and: 6)
		ifTrue:
			[decPointCount := baseExpEstimate.
			baseExpEstimate <= 0
				ifTrue: [aStream nextPutAll: ('0.000000' truncateTo: 2 - baseExpEstimate)]]
		ifFalse:
			[decPointCount := 1].
	slowbit := 1 - s lowBit .
	shead := s bitShift: slowbit.
	[d := (r bitShift: slowbit) // shead.
	r := r - (d * s).
	(tc1 := (r <= mMinus) and: [roundingIncludesLimits or: [r < mMinus]]) |
	(tc2 := (r + mPlus >= s) and: [roundingIncludesLimits or: [r + mPlus > s]])] whileFalse:
		[aStream nextPut: (Character digitValue: d).
		r := r * base.
		mPlus := mPlus * base.
		mMinus := mMinus * base.
		(decPointCount := decPointCount - 1) = 0 ifTrue: [aStream nextPut: $.]].
	tc2 ifTrue:
		[(tc1 not or: [r * 2 >= s]) ifTrue: [d := d + 1]].
	aStream nextPut: (Character digitValue: d).
	decPointCount > 0
		ifTrue:
			[decPointCount - 1 to: 1 by: -1 do: [:i | aStream nextPut: $0].
			aStream nextPutAll: '.0'].
	fixedFormat
		ifFalse:
			[aStream nextPut: $e.
			aStream nextPutAll: (baseExpEstimate - 1) printString]
]

{ #category : #printing }
Float >> absPrintExactlyOn: aStream base: base decimalPlaces: placesDesired showTrailingFractionalZeros: showtrailingZeros [
	"Print my value on a stream in the given base with fixed number of digits after floating point.
	When placesDesired are beyond Float precision, zeroes are appended.
	When showtrailingZeros is false, the trailing zeroes after decimal point will be omitted.
	If all fractional digits are zeros, the decimal point is omitted too.
	Assumes that my value is strictly positive; negative numbers, zero, and NaNs have already been handled elsewhere.
	Based upon the algorithm outlined in:
	Robert G. Burger and R. Kent Dybvig
	Printing Floating Point Numbers Quickly and Accurately
	ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
	June 1996.."

	| significand exp baseExpEstimate r s mPlus mMinus scale roundingLowIncludesLimits roundingHighIncludesLimits d tc1 tc2 decPointCount slowbit shead delta |
	self isInfinite ifTrue: [aStream nextPutAll: 'Infinity'. ^ self].
	significand := self significandAsInteger.
	exp := (self exponent - 52) max: MinValLogBase2.
	exp >= 0
		ifTrue:
			[significand ~= 16r10000000000000
				ifTrue:
					[r := significand bitShift: 1 + exp.
					s := 2.
					mPlus := mMinus := 1 bitShift: exp]
				ifFalse:
					[r := significand bitShift: 2 + exp.
					s := 4.
					mPlus := 2 * (mMinus := 1 bitShift: exp)]]
		ifFalse:
			[(exp = MinValLogBase2 or: [significand ~= 16r10000000000000])
				ifTrue:
					[r := significand bitShift: 1.
					s := 1 bitShift: 1 - exp.
					mPlus := mMinus := 1]
				ifFalse:
					[r := significand bitShift: 2.
					s := 1 bitShift: 2 - exp.
					mPlus := 2.
					mMinus := 1]].
	delta := s / 2 / (base raisedTo: placesDesired).
	roundingLowIncludesLimits :=  (mMinus < delta and: [mMinus := delta. true]) or: [significand even].
	roundingHighIncludesLimits := (mPlus < delta and: [mPlus := delta. true]) or: [significand even].
	baseExpEstimate := (self exponent * base asFloat reciprocalLogBase2 - 1.0e-10) ceiling.
	baseExpEstimate >= 0
		ifTrue: [s := s * (base raisedToInteger: baseExpEstimate)]
		ifFalse:
			[scale := base raisedToInteger: baseExpEstimate negated.
			r := r * scale.
			mPlus := mPlus * scale.
			mMinus := mMinus * scale].
	((r + mPlus >= s) and: [roundingHighIncludesLimits or: [r + mPlus > s]])
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[r := r * base.
			mPlus := mPlus * base.
			mMinus := mMinus * base].
	decPointCount := baseExpEstimate.
	baseExpEstimate <= 0
		ifTrue:
			[placesDesired + baseExpEstimate <= 0
				ifTrue:
					[aStream nextPut: $0.
					(showtrailingZeros and: [placesDesired > 0]) ifTrue: [aStream nextPut: $.; nextPutAll: (String new: placesDesired withAll: $0)].
					^self].
			aStream nextPutAll: '0.'; nextPutAll: (String new: 0 - baseExpEstimate withAll: $0)].
	slowbit := 1 - s lowBit .
	shead := s bitShift: slowbit.
	[d := (r bitShift: slowbit) // shead.
	r := r - (d * s).
	(tc1 := (r <= mMinus) and: [roundingLowIncludesLimits or: [r < mMinus]]) |
	(tc2 := (r + mPlus >= s) and: [roundingHighIncludesLimits or: [r + mPlus > s]])] whileFalse:
		[aStream nextPut: (Character digitValue: d).
		r := r * base.
		mPlus := mPlus * base.
		mMinus := mMinus * base.
		(decPointCount := decPointCount - 1) = 0 ifTrue: [aStream nextPut: $.]].
	tc2 ifTrue:
		[(tc1 not or: [r * 2 >= s]) ifTrue: [d := d + 1]].
	aStream nextPut: (Character digitValue: d).
	decPointCount > 0
		ifTrue:
			[decPointCount - 1 to: 1 by: -1 do: [:i | aStream nextPut: $0].
			(showtrailingZeros and: [placesDesired > 0]) ifTrue: [aStream nextPut: $.; nextPutAll: (String new: placesDesired withAll: $0)]]
		ifFalse:
			[(showtrailingZeros and: [placesDesired + decPointCount > 1]) ifTrue: [aStream nextPutAll: (String new: placesDesired + decPointCount - 1 withAll: $0)]].
]

{ #category : #printing }
Float >> absPrintOn: aStream base: base [
	"Print my value on a stream in the given base.  Assumes that my value is strictly
	positive; negative numbers, zero, and NaNs have already been handled elsewhere.
	Based upon the algorithm outlined in:
	Robert G. Burger and R. Kent Dybvig
	Printing Floating Point Numbers Quickly and Accurately
	ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
	June 1996.
	This version performs all calculations with Floats instead of LargeIntegers, and loses
	about 3 lsbs of accuracy compared to an exact conversion."

	| significantBits fBase exp baseExpEstimate r s mPlus mMinus scale d tc1 tc2 fixedFormat decPointCount |
	self isInfinite ifTrue: [aStream nextPutAll: 'Infinity'. ^ self].
	significantBits := 50.  "approximately 3 lsb's of accuracy loss during conversion"
	fBase := base asFloat.
	exp := self exponent.
	baseExpEstimate := (exp * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue:
			[r := self.
			s := 1.0.
			mPlus := 1.0 timesTwoPower: exp - significantBits.
			mMinus := self significand ~= 1.0 ifTrue: [mPlus] ifFalse: [mPlus / 2.0]]
		ifFalse:
			[r := self timesTwoPower: significantBits.
			s := 1.0 timesTwoPower:  significantBits.
			mMinus := 1.0 timesTwoPower: (exp max: -1024).
			mPlus :=
				(exp = MinValLogBase2) | (self significand ~= 1.0)
					ifTrue: [mMinus]
					ifFalse: [mMinus * 2.0]].
	baseExpEstimate >= 0
		ifTrue:
			[exp = 1023
				ifTrue:   "scale down to prevent overflow to Infinity during conversion"
					[r := r / fBase.
					s := s * (fBase raisedToInteger: baseExpEstimate - 1).
					mPlus := mPlus / fBase.
					mMinus := mMinus / fBase]
				ifFalse:
					[s := s * (fBase raisedToInteger: baseExpEstimate)]]
		ifFalse:
			[exp < -1023
				ifTrue:   "scale up to prevent denorm reciprocals overflowing to Infinity"
					[d := (53 * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
					scale := fBase raisedToInteger: d.
					r := r * scale.
					mPlus := mPlus * scale.
					mMinus := mMinus * scale.
					scale := fBase raisedToInteger: (baseExpEstimate + d) negated]
				ifFalse:
				[scale := fBase raisedToInteger: baseExpEstimate negated].
			s := s / scale].
	(r + mPlus >= s)
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[s := s / fBase].
	(fixedFormat := baseExpEstimate between: -3 and: 6)
		ifTrue:
			[decPointCount := baseExpEstimate.
			baseExpEstimate <= 0
				ifTrue: [aStream nextPutAll: ('0.000000' truncateTo: 2 - baseExpEstimate)]]
		ifFalse:
			[decPointCount := 1].
	[d := (r / s) truncated.
	r := r - (d * s).
	(tc1 := r <= mMinus) | (tc2 := r + mPlus >= s)] whileFalse:
		[aStream nextPut: (Character digitValue: d).
		r := r * fBase.
		mPlus := mPlus * fBase.
		mMinus := mMinus * fBase.
		decPointCount := decPointCount - 1.
		decPointCount = 0 ifTrue: [aStream nextPut: $.]].
	tc2 ifTrue:
		[tc1 not | (tc1 & (r*2.0 >= s)) ifTrue: [d := d + 1]].
	aStream nextPut: (Character digitValue: d).
	decPointCount > 0
		ifTrue:
		[decPointCount - 1 to: 1 by: -1 do: [:i | aStream nextPut: $0].
		aStream nextPutAll: '.0'].
	fixedFormat ifFalse:
		[aStream nextPut: $e.
		aStream nextPutAll: (baseExpEstimate - 1) printString]
]

{ #category : #printing }
Float >> absPrintOn: aStream base: base digitCount: digitCount [ 
	"Print me in the given base, using digitCount significant figures."

	| fuzz x exp q fBase scale logScale xi |
	self isInfinite ifTrue: [^ aStream nextPutAll: 'Inf'].
	fBase := base asFloat.
	"x is myself normalized to [1.0, fBase), exp is my exponent"
	exp := self floorLog: fBase.
	scale := 1.0.
	logScale := 0.
	[(x := fBase raisedTo: (exp + logScale)) = 0]
		whileTrue:
			[scale := scale * fBase.
			logScale := logScale + 1].
	x := self * scale / x.
	fuzz := fBase raisedTo: 1 - digitCount.
	"round the last digit to be printed"
	x := 0.5 * fuzz + x.
	x >= fBase
		ifTrue: 
			["check if rounding has unnormalized x"
			x := x / fBase.
			exp := exp + 1].
	(exp < 6 and: [exp > -4])
		ifTrue: 
			["decimal notation"
			q := 0.
			exp < 0 ifTrue: [1 to: 1 - exp do: [:i | aStream nextPut: ('0.0000'
at: i)]]]
		ifFalse: 
			["scientific notation"
			q := exp.
			exp := 0].
	[x >= fuzz]
		whileTrue: 
			["use fuzz to track significance"
			xi := x asInteger.
			aStream nextPut: (Character digitValue: xi).
			x := x - xi asFloat * fBase.
			fuzz := fuzz * fBase.
			exp := exp - 1.
			exp = -1 ifTrue: [aStream nextPut: $.]].
	[exp >= -1]
		whileTrue: 
			[aStream nextPut: $0.
			exp := exp - 1.
			exp = -1 ifTrue: [aStream nextPut: $.]].
	q ~= 0
		ifTrue: 
			[aStream nextPut: $e.
			q printOn: aStream]
]

{ #category : #converting }
Float >> adaptToFraction: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Fraction, convert myself to a
	Fraction. This way, no bit is lost and comparison is exact."
	
	self isFinite ifFalse: [
		selector == #= ifTrue: [ ^false ].
		selector == #~= ifTrue: [ ^true ].
		(selector == #< or: [ selector == #'<=' ])
			ifTrue: [ ^self >= 0.0].
		(selector == #> or: [ selector == #'>=' ])
			ifTrue: [ ^0.0 >= self ].
		^self error: 'unknow comparison selector' ].
		
	"Try to avoid asTrueFraction because it can cost"
	rcvr isAnExactFloat ifTrue: [^rcvr asExactFloat perform: selector with: self].
	selector == #= ifTrue: [^false].
	selector == #~= ifTrue: [^true].
	^ rcvr perform: selector with: self asTrueFraction
]

{ #category : #converting }
Float >> adaptToFraction: rcvr andSend: selector [
	"If I am involved in arithmetic with a Fraction, convert it to a Float."
	^ rcvr asFloat perform: selector with: self
]

{ #category : #converting }
Float >> adaptToInteger: rcvr andCompare: selector [ 
	"If I am involved in comparison with an Integer, convert myself to a
	Fraction. This way, no bit is lost and comparison is exact."
	
	self isFinite ifFalse: [
		selector == #= ifTrue: [ ^false ].
		selector == #~= ifTrue: [ ^true ].
		(selector == #< or: [ selector == #'<=' ])
			ifTrue: [ ^self >= 0.0 ].
		(selector == #> or: [ selector == #'>=' ])
			ifTrue: [ ^0.0 >= self ].
		^self error: 'unknow comparison selector'].
		
	"Try to avoid asTrueFraction because it can cost"
	selector == #= ifTrue: [
		self fractionPart = 0.0 ifFalse: [^false]].
	selector == #~= ifTrue: [
		self fractionPart = 0.0 ifFalse: [^true]].
	
	rcvr isAnExactFloat ifTrue: [^rcvr asExactFloat perform: selector with: self].
	selector == #= ifTrue: [^false].
	selector == #~= ifTrue: [^true].
	^ rcvr perform: selector with: self asTrueFraction
]

{ #category : #converting }
Float >> adaptToInteger: rcvr andSend: selector [
	"If I am involved in arithmetic with an Integer, convert it to a Float."
	^ rcvr asFloat perform: selector with: self
]

{ #category : #converting }
Float >> adaptToScaledDecimal: rcvr andCompare: selector [ 
	"If I am involved in comparison with a scaled Decimal, convert myself to a
	Fraction. This way, no bit is lost and comparison is exact."
	
	self isFinite ifFalse: [
		selector == #= ifTrue: [^false].
		selector == #~= ifTrue: [^true].
		(selector == #< or: [ selector == #'<=' ])
			ifTrue: [ ^self >= 0.0 ].
		(selector == #> or: [ selector == #'>=' ])
			ifTrue: [ ^0.0 >= self ].
		^self error: 'unknow comparison selector' ].

	"Try to avoid asTrueFraction because it can cost"
	rcvr isAnExactFloat ifTrue: [^rcvr asExactFloat perform: selector with: self].
	selector == #= ifTrue: [^false].
	selector == #~= ifTrue: [^true].
	^ rcvr perform: selector with: self asTrueFraction
]

{ #category : #converting }
Float >> adaptToScaledDecimal: receiverScaledDecimal andSend: arithmeticOpSelector [ 
	"Convert receiverScaledDecimal to a Float and do the arithmetic. 
	receiverScaledDecimal arithmeticOpSelector self."
	#Numeric.
	"add 200/01/19 For ScaledDecimal support."
	^ receiverScaledDecimal asFloat perform: arithmeticOpSelector with: self
]

{ #category : #'mathematical functions' }
Float >> arCosh [
	"Answer receiver's area hyperbolic cosine.
	That is the inverse function of cosh."

	self < 1 
		ifTrue: 
			[^DomainError signal: 'Receiver must be greater or equal to 1'].
	^self + 1 = self 
		ifTrue: [self abs ln + 2 ln]
		ifFalse: [((self squared - 1) sqrt + self) ln]
]

{ #category : #'mathematical functions' }
Float >> arSinh [
	"Answer receiver's area hyperbolic sine.
	That is the inverse function of sinh."

	self = 0.0 ifTrue: [^self].	"Handle negativeZero"  
	^self + 1 = self 
		ifTrue: [(self abs ln + 2 ln) * self sign]
		ifFalse: [((self squared + 1) sqrt + self) ln]
]

{ #category : #'mathematical functions' }
Float >> arTanh [
	"Answer receiver's area hyperbolic tangent.
	That is the inverse function of tanh."

	self = 0.0 ifTrue: [^self].	"Handle negativeZero"
	self abs = 1 ifTrue: [^self copySignTo: Float infinity].
	self abs > 1 
		ifTrue: 
			[^DomainError signal: 'Receiver must be between -1.0 and 1.0'].
	^((1 + self) / (1 - self)) ln / 2
]

{ #category : #'mathematical functions' }
Float >> arcCos [
	"Answer the angle in radians."

	^ Halfpi - self arcSin
]

{ #category : #'mathematical functions' }
Float >> arcSin [
	"Answer the angle in radians."

	((self < -1.0) or: [self > 1.0]) ifTrue: [DomainError signal: 'arcSin only takes values between -1 and 1'].
	((self = -1.0) or: [self = 1.0])
		ifTrue: [^ Halfpi * self]
		ifFalse: [^ (self / (1.0 - (self * self)) sqrt) arcTan]
]

{ #category : #'mathematical functions' }
Float >> arcTan: denominator [
	"Answer the angle in radians, taking care of 4 quadrants.
	Implementation note: use signBit and sign: in order to catch cases of negativeZero"

	self = 0.0
		ifTrue:
			[denominator signBit = 0 ifTrue: [ ^0.0 ].
			^Pi sign: self ].
	denominator = 0.0 ifTrue: [ ^Halfpi sign: self ].
	denominator > 0.0 	ifTrue: [ ^(self / denominator) arcTan ].
	^(self / denominator) arcTan + (Pi sign: self)
]

{ #category : #converting }
Float >> asApproximateFraction [
	"Answer a Fraction approximating the receiver. This conversion uses the 
	continued fraction method to approximate a floating point number."

	^ self asApproximateFractionRelativeDecimalPlaces: 10
]

{ #category : #converting }
Float >> asApproximateFractionAtOrder: maxOrder [
	"Answer a Fraction approximating the receiver. This conversion uses the 
	continued fraction method to approximate a floating point number. If maxOrder
	is zero, use maximum order"

	^self 
		asApproximateFractionAtOrder: maxOrder
		precision: self ulp / 2
]

{ #category : #converting }
Float >> asApproximateFractionAtOrder: maxOrder precision: limit [ 
	"Answer a Rational number--Integer or Fraction--representing the receiver.
	This conversion uses the continued fraction method to	approximate a floating point number.
	The iteration stops when precision has reached the prescribed limit,
	or when the maximum number of iterations has been reached.
	If maxOrder is zero, then the number of iterations is not limited."
	
	| num1 denom1 num2 denom2 int frac newD order |
	newD := self asFraction. "use exact arithmetic to avoid both overflow and accumulation of rounding errors"
	num1 := denom2 := 1. "Initialize alternating numerators"
	num2 := denom1 := 0. "and denominators"	
	order := maxOrder = 0 ifTrue: [-1] ifFalse: [maxOrder].
	[int := newD integerPart. "get the integer part of this"
	frac := newD fractionPart. "and save the fractional part for next time"
	num1 := num2 + ((num2 := num1) * int). "Update numerators"
	denom1 := denom2 + ((denom2 := denom1) * int). "and denominators"
	frac = 0
		or: [order = 0
		or: [((Fraction numerator: num1 denominator: denom1) - self) abs <= limit]]]
		whileFalse:
			[newD := frac reciprocal "Take reciprocal of the fractional part".
			order := order - 1].
	^denom1 = 1
		ifTrue: ["Am i really an Integer?"
			num1"Yes, return Integer result"]
		ifFalse: ["Otherwise return Fraction result"
			Fraction numerator: num1 denominator: denom1]
]

{ #category : #converting }
Float >> asApproximateFractionRelativeDecimalPlaces: decimalPlaces [
	"Answer a Fraction approximating the receiver. This conversion uses the 
	continued fraction method to approximate a floating point number.
	Stop the recursion when precision has reached prescribed number of relative decimalPlaces."

	^ self
		asApproximateFractionAtOrder: 0
		precision: (1.0 timesTwoPower: self exponent - (decimalPlaces * Ln10 / Ln2) rounded)
]

{ #category : #printing }
Float >> asBytesDescription [
	^ self asInteger asBytesDescription
]

{ #category : #converting }
Float >> asFloat [
	"Answer the receiver itself."

	^self
]

{ #category : #converting }
Float >> asFraction [
	^ self asTrueFraction 
]

{ #category : #converting }
Float >> asIEEE32BitWord [
	"Convert the receiver into a 32 bit Integer value representing the same number in IEEE 32 bit format.
	 Used for conversion in FloatArrays."
	
	| word1 word2 sign mantissa exponent truncatedBits mask roundToUpper |
	
	"skip fast positive and nnegative zero"
	self = 0.0 ifTrue: [^self basicAt: 1].
	
	"retrieve 64 bits of IEEE 754 double"
	word1 := self basicAt: 1.
	word2 := self basicAt: 2.
	
	"prepare sign exponent and mantissa of 32 bits float"
	sign := word1 bitAnd: 16r80000000.
	exponent := ((word1 bitShift: -20) bitAnd: 16r7FF) - 1023 + 127.
	mantissa := (word2 bitShift: -29) + ((word1 bitAnd:  16rFFFFF) bitShift: 3).
	truncatedBits := (word2 bitAnd: 16r1FFFFFFF).

	"We must now honour default IEEE rounding mode (round to nearest even)"
	
	"we are below gradual underflow, even if rounded to upper mantissa"
	exponent < -24 ifTrue: [^sign]. "this can be negative zero"
	
	"BEWARE: rounding occurs on less than 23bits when gradual underflow"
	exponent <= 0
		ifTrue:
			[mask := 1 bitShift: exponent negated.
			mantissa := mantissa bitOr: 16r800000.
			roundToUpper := (mantissa bitAnd: mask) isZero not
				and: [truncatedBits isZero not
					or: [(mantissa bitAnd: mask - 1) isZero not
						or: [(mantissa bitAnd: mask*2) isZero not]]].
			mantissa := mantissa bitShift: exponent - 1.
			"exponent := exponent + 1"]
		ifFalse:
			[roundToUpper := (truncatedBits bitAnd: 16r10000000) isZero not
				and: [(mantissa bitAnd: 16r1) isZero not
					or: [(truncatedBits bitAnd: 16r0FFFFFFF) isZero not]]].
		
	"adjust mantissa and exponent due to IEEE rounding mode"
	roundToUpper ifTrue:
		[mantissa := mantissa + 1.
		mantissa > 16r7FFFFF ifTrue:
			[mantissa := 0.
			exponent := exponent+1]].

	exponent > 254 ifTrue: "Overflow"
		[exponent := 255.
		self isNaN
			ifTrue: [mantissa isZero
				ifTrue: ["BEWARE: do not convert a NaN to infinity due to truncatedBits"
					mantissa := 1]]
			ifFalse: [mantissa := 0]].
		
	"Encode the word"
	^(sign bitOr: ((exponent max: 0) bitShift: 23)) bitOr: mantissa
]

{ #category : #converting }
Float >> asIEEE64BitWord [
	"Convert the receiver into a 64 bit Integer value representing the same number in IEEE 64 bit format.
	 Used for conversion in FloatArrays."
	
	^((self basicAt: 1) bitShift: 32) + (self basicAt: 2)
]

{ #category : #converting }
Float >> asTrueFraction [
	" Answer a fraction that EXACTLY represents self,
	  a double precision IEEE floating point number.
	  Floats are stored in the same form on all platforms.
	  (Does handle gradual underflow but not NANs.)
	  By David N. Smith with significant performance
	  improvements by Luciano Esteban Notarfrancesco.
	  (Version of 11April97)"
	| signexp positive expPart exp fraction fractionPart signedFraction result zeroBitsCount |
	self isInfinite ifTrue: [self error: 'Cannot represent infinity as a fraction'].
	self isNaN ifTrue: [self error: 'Cannot represent Not-a-Number as a fraction'].


	" Extract the sign and the biased exponent "
	signexp := (self basicAt: 1) bitShift: -20.
	positive := (signexp bitAnd: 16r800) = 0.
	expPart := signexp bitAnd: 16r7FF.

	" Extract fractional part; answer 0 if this is a true 0.0 value "
	fractionPart := (((self basicAt: 1) bitAnd: 16rFFFFF) bitShift: 32)+ (self basicAt: 2).
	( expPart=0 and: [ fractionPart=0 ] ) ifTrue: [ ^ 0  ].

	" Replace omitted leading 1 in fraction unless gradual underflow"
	fraction := expPart = 0
		ifTrue: [fractionPart bitShift: 1]
		ifFalse: [fractionPart bitOr: 16r0010000000000000].
	signedFraction := positive ifTrue: [fraction] ifFalse: [fraction negated].
	
	"Unbias exponent: 16r3FF is bias; 52 is fraction width"
	exp := 16r3FF + 52 - expPart.

	" Form the result. When exp>52, the exponent is adjusted by
	  the number of trailing zero bits in the fraction to minimize
	  the (huge) time otherwise spent in #gcd:. "
	exp negative
		ifTrue: [
			result := signedFraction bitShift: exp negated ]
		ifFalse:	[
			zeroBitsCount := fraction lowBit - 1.
			exp := exp - zeroBitsCount.
			exp <= 0
				ifTrue: [
					zeroBitsCount := zeroBitsCount + exp.
					"exp := 0."   " Not needed; exp not
refernced again "
					result := signedFraction bitShift:
zeroBitsCount negated ]
				ifFalse: [
					result := Fraction
						numerator: (signedFraction
bitShift: zeroBitsCount negated)
						denominator: (1 bitShift:
exp) ] ].

	"Low cost validation omitted after extensive testing"
	"(result asFloat = self) ifFalse: [self error: 'asTrueFraction validation failed']."
	^ result 
]

{ #category : #accessing }
Float >> at: index [ 
	"Avoid primitive in Object>>at:"

	^self basicAt: index
]

{ #category : #accessing }
Float >> at: index put: value [ 
	"Avoid primitive in Object>>at:put:"

	^self basicAt: index put: value
]

{ #category : #accessing }
Float >> basicAt: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an 
	indexable element in the receiver. Fail if the argument index is not an 
	Integer or is out of bounds. Essential. Do not override in a subclass. See 
	Object documentation whatIsAPrimitive.

	This version of basicAt: is specifically for floats, answering the most significant
	word for index 1 and the least significant word for index 2.  This allows the VM
	to store floats in whatever order it chooses while it appears to the image that
	they are always in big-endian/PowerPC order."

	<primitive: 38 error: ec>
	ec ifNil: "primitive not implemented; floats are in big-endian/PowerPC order."
		[^super basicAt: index].
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self basicAt: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Float >> basicAt: index put: value [
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive.

	This version of basicAt: is specifically for floats, answering the most significant
	word for index 1 and the least significant word for index 2.  This allows the VM
	to store floats in whatever order it chooses while it appears to the image that
	they are always in big-endian/PowerPC order."

	<primitive: 39 error: ec>
	ec ifNil: "primitive not implemented; floats are in big-endian/PowerPC order."
		[^super basicAt: index put: value].
	index isInteger
		ifTrue: [(index >= 1 and: [index <= self size])
					ifTrue: [self errorImproperStore]
					ifFalse: [self errorSubscriptBounds: index]].
	index isNumber
		ifTrue: [^self basicAt: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #printing }
Float >> byteEncode: aStream base: base [
	"Handle sign, zero, and NaNs; all other values passed to absPrintOn:base:" 

	self isNaN ifTrue: [aStream print: 'NaN'. ^ self]. "check for NaN before sign"
	self > 0.0
		ifTrue: [self absByteEncode: aStream base: base]
		ifFalse:
			[self signBit = 1
				ifTrue: [aStream print: '-'].
			self = 0.0
				ifTrue: [aStream print: '0.0'. ^ self]
				ifFalse: [aStream writeNumber:self negated base: base]]
]

{ #category : #comparing }
Float >> closeTo: num [
 	"are these two numbers close?"
	num isNumber ifFalse: [^[self = num] ifError: [false]].
	self = 0.0 ifTrue: [^num abs < 0.0001].
	num = 0 ifTrue: [^self abs < 0.0001].
	^self = num asFloat or: [
		| abs |
		(abs := self abs) < 0.0001 ifTrue: [^num abs < 0.0001].
		(self - num) abs / (abs max: num abs) < 0.0001]
]

{ #category : #'mathematical functions' }
Float >> cos [
	"Answer the cosine of the receiver taken as an angle in radians."

	^ (self + Halfpi) sin
]

{ #category : #'mathematical functions' }
Float >> cosh [
	"Answer receivers hyperbolic cosine."
	
	| ex |
	ex := self abs exp.
	^(ex + ex reciprocal) / 2
]

{ #category : #copying }
Float >> deepCopy [

	^self copy
]

{ #category : #'mathematical functions' }
Float >> degreeCos [
	"Take care of exceptional values"
	
	self isFinite ifTrue: [^super degreeCos].
	^self degreesToRadians cos
]

{ #category : #'mathematical functions' }
Float >> degreeSin [
	"Take care of exceptional values"
	
	self isFinite ifTrue: [^super degreeSin].
	^self degreesToRadians sin
]

{ #category : #converting }
Float >> degreesToRadians [
	"Answer the receiver in radians. Assumes the receiver is in degrees."

	^self * RadiansPerDegree
]

{ #category : #'truncation and round off' }
Float >> exponentFromBitPattern [
	"Extract the exponent from the bit pattern.
	This is used only when primitive fails"
	
	| exponent word1 |
	self isFinite ifFalse: [^self error: 'cannot take the exponent of non finite Float'].
	self = 0.0 ifTrue: [^-1].
	word1 := self basicAt: 1.
	exponent := (word1 bitShift: -20) bitAnd: 16r7FF.
	^exponent = 0
		ifTrue:
			[| high |
			high := (word1 bitAnd: 16rFFFFF) highBit.
			high := high = 0
				ifTrue: [(self basicAt: 2) highBit]
				ifFalse: [high + 32].
			self class emin - self class precision + high]
		ifFalse:
			[exponent + self class emin - 1]
]

{ #category : #'mathematical functions' }
Float >> floorLog: radix [
	"Answer the floor of the log base radix of the receiver.
	The result may be off by one due to rounding errors, except in base 2."

	(radix = 2 and: [self > 0.0 and: [self isFinite]]) ifTrue: [^self exponent].
	^ (self log: radix) floor

]

{ #category : #comparing }
Float >> hash [
	"Hash is reimplemented because = is implemented. Both words of the float are used. (The bitShift:'s ensure that the intermediate results do not become a large integer.) Care is taken to answer same hash as an equal Integer."

	(self isFinite and: [self fractionPart = 0.0]) ifTrue: [^self truncated hash].
	^ ((self basicAt: 1) bitShift: -4) +
	   ((self basicAt: 2) bitShift: -4)

]

{ #category : #printing }
Float >> hex [  "If ya really want to know..."
	^ String streamContents:
		[:strm |
		| word nibble |
		1 to: 2 do:
			[:i | word := self at: i.
			1 to: 8 do: 
				[:s | nibble := (word bitShift: -8+s*4) bitAnd: 16rF.
				strm nextPut: ('0123456789ABCDEF' at: nibble+1)]]]
"
(-2.0 to: 2.0) collect: [:f | f hex]
"
]

{ #category : #'truncation and round off' }
Float >> integerPart [
	"Answer a Float whose value is the receiver's truncated value."

	^self - self fractionPart
]

{ #category : #testing }
Float >> isAnExactFloat [
	^true
]

{ #category : #testing }
Float >> isFinite [
	"simple, byte-order independent test for rejecting Not-a-Number and (Negative)Infinity"

	^(self - self) = 0.0
]

{ #category : #testing }
Float >> isFloat [
	^ true
]

{ #category : #testing }
Float >> isInfinite [
	"Return true if the receiver is positive or negative infinity."

	^ self = Infinity or: [self = NegativeInfinity]

]

{ #category : #testing }
Float >> isLiteral [
	"There is no literal representation of NaN.
	However, there are literal representations of Infinity, like 1.0e1000.
	But since they are not able to print properly, only case of finite Float is considered."
	
	^self isFinite
]

{ #category : #testing }
Float >> isNaN [
	"simple, byte-order independent test for Not-a-Number"

	^ self ~= self
]

{ #category : #testing }
Float >> isPowerOfTwo [
	"Return true if the receiver is an integral power of two.
	Floats never return true here."
	^false
]

{ #category : #testing }
Float >> isZero [
	^self = 0.0
]

{ #category : #comparing }
Float >> literalEqual: aFloat [
	"Two float literals can be replaced by a single one only if their representation have the same bits.
	For example, zero and negativeZero are equal, but not literally equal."

	^self class == aFloat class and: [(self at: 1) = (aFloat at: 1) and: [(self at: 2) = (aFloat at: 2)]]
]

{ #category : #'mathematical functions' }
Float >> log [
	"Answer the base 10 logarithm of the receiver."

	^ self ln / Ln10
]

{ #category : #'mathematical functions' }
Float >> log2 [
	"Answer the base 2 logarithm of the receiver.
	Arrange to answer exact result in case of exact power of 2."

	^ self significand ln / Ln2 + self exponent
]

{ #category : #arithmetic }
Float >> negated [
	"Answer a Number that is the negation of the receiver.
	Implementation note: this version cares of negativeZero."

	^-1.0 * self
]

{ #category : #'mathematical functions' }
Float >> nthRoot: aPositiveInteger [
	"Answer the nth root of the receiver."
	aPositiveInteger = 2 ifTrue: [
		^self sqrt ].

	(aPositiveInteger isInteger not or: [ aPositiveInteger negative ])
		ifTrue: [^ ArithmeticError signal: 'nth root only defined for positive Integer n.'].
	
	^self negative
		ifTrue: [
			aPositiveInteger odd
				ifTrue: [ (self negated raisedTo: 1.0 / aPositiveInteger) negated ]
				ifFalse: [ ArithmeticError signal: 'Negative numbers don''t have even roots.' ]]
		ifFalse: [ self raisedTo: 1.0 / aPositiveInteger ]
]

{ #category : #'truncation and round off' }
Float >> predecessor [
	| ulp |
	self isFinite ifFalse: [
		(self isNaN or: [self negative]) ifTrue: [^self].
		^Float fmax].
	ulp := self ulp.
	^self - (0.5 * ulp) = self
		ifTrue: [self - ulp]
		ifFalse: [self - (0.5 * ulp)]
]

{ #category : #printing }
Float >> printAsLiteralOn: aStream [
	^self storeOn: aStream base: 10
]

{ #category : #printing }
Float >> printOn: aStream base: base [
	"Print the receiver with the minimal number of digits that describes it unambiguously.
	This way, every two different Float will have a different printed representation.
	More over, every Float can be reconstructed from its printed representation with #readFrom:." 

	self isNaN ifTrue: [aStream nextPutAll: 'NaN'. ^ self]. "check for NaN before sign"
	self > 0.0
		ifTrue: [self absPrintExactlyOn: aStream base: base]
		ifFalse:
			[self signBit = 1
				ifTrue: [aStream nextPutAll: '-'].
			self = 0.0
				ifTrue: [aStream nextPutAll: '0.0']
				ifFalse: [self negated absPrintExactlyOn: aStream base: base]]
]

{ #category : #printing }
Float >> printOn: aStream maxDecimalPlaces: placesDesired [
	"Refine super implementation in order to avoid any rounding error caused by rounded or roundTo:"
	
	self isFinite ifFalse: [^self printOn: aStream].
	self > 0.0
		ifTrue: [self absPrintExactlyOn: aStream base: 10 decimalPlaces: placesDesired showTrailingFractionalZeros: false]
		ifFalse:
			[self signBit = 1
				ifTrue: [aStream nextPutAll: '-'].
			self = 0.0
				ifTrue: [aStream nextPutAll: '0.0']
				ifFalse: [self absPrintExactlyOn: aStream base: 10 decimalPlaces: placesDesired showTrailingFractionalZeros: false]]
]

{ #category : #printing }
Float >> printOn: aStream showingDecimalPlaces: placesDesired [
	"Refine super implementation in order to avoid any rounding error caused by rounded or roundTo:"
	
	self isFinite ifFalse: [^self printOn: aStream].
	self > 0.0
		ifTrue: [self absPrintExactlyOn: aStream base: 10 decimalPlaces: placesDesired showTrailingFractionalZeros: true]
		ifFalse:
			[self signBit = 1
				ifTrue: [aStream nextPutAll: '-'].
			self = 0.0
				ifTrue:
					[aStream nextPut: $0.
					placesDesired > 0 ifTrue: [aStream nextPut: $.; next: placesDesired put: $0]]
				ifFalse: [self absPrintExactlyOn: aStream base: 10 decimalPlaces: placesDesired showTrailingFractionalZeros: true]]
]

{ #category : #printing }
Float >> printPaddedWith: aCharacter to: aNumber [ 
	"Answer the string containing the ASCII representation of the receiver 
	padded on the left with aCharacter to be at least on aNumber 
	integerPart characters and padded the right with aCharacter to be at 
	least anInteger fractionPart characters."
	| aStream digits fPadding fLen iPadding iLen curLen periodIndex |
	#Numeric.
	"2000/03/04  Harmon R. Added Date and Time support"
	aStream := WriteStream on: (String new: 10).
	self printOn: aStream.
	digits := aStream contents.
	periodIndex := digits indexOf: $..
	curLen := periodIndex - 1.
	iLen := aNumber integerPart.
	curLen < iLen
		ifTrue: [iPadding := (String new: (iLen - curLen) asInteger) atAllPut: aCharacter;
					 yourself]
		ifFalse: [iPadding := ''].
	curLen := digits size - periodIndex.
	"n.b. Treat aNumber as a string format specifier rather than as a number, because
	floating point truncation can produce incorrect results for the fraction part."
	fLen := (aNumber asString copyAfterLast: $. )
		ifNotEmpty: [:s | s asInteger]
		ifEmpty: [ 0 ].
	curLen < fLen
		ifTrue: [fPadding := (String new: fLen - curLen) atAllPut: aCharacter;
					 yourself]
		ifFalse: [fPadding := ''].
	^ iPadding , digits , fPadding
]

{ #category : #converting }
Float >> radiansToDegrees [
	"Answer the receiver in degrees. Assumes the receiver is in radians."

	^self / RadiansPerDegree
]

{ #category : #arithmetic }
Float >> reciprocal [

	"Returns the reciprocal.
	If self is 0.0 the / signals a ZeroDivide"
	
	^1.0 / self
]

{ #category : #'mathematical functions' }
Float >> reciprocalFloorLog: radix [ 
	"Quick computation of (self log: radix) floor, when self < 1.0.
	Avoids infinite recursion problems with denormalized numbers"

	| adjust scale n |
	adjust := 0.
	scale := 1.0.
	[(n := radix / (self * scale)) isInfinite]
		whileTrue:
			[scale := scale * radix.
			adjust := adjust + 1].
	^ ((n floorLog: radix) + adjust) negated
]

{ #category : #'mathematical functions' }
Float >> reciprocalLogBase2 [
	"optimized for self = 10, for use in conversion for printing"

	^ self = 10.0
		ifTrue: [Ln2 / Ln10]
		ifFalse: [Ln2 / self ln]
]

{ #category : #'truncation and round off' }
Float >> reduce [
    "If self is close to an integer, return that integer"

    (self closeTo: self rounded) ifTrue: [^ self rounded]
]

{ #category : #'truncation and round off' }
Float >> rounded [
	"Answer the integer nearest the receiver.
	Implementation note: super would not handle tricky inexact arithmetic"
	
	"self assert: 5000000000000001.0 rounded = 5000000000000001"

	self fractionPart abs < 0.5
		ifTrue: [^self truncated]
		ifFalse: [^self truncated + self sign rounded]
]

{ #category : #'mathematical functions' }
Float >> safeArcCos [
	"Answer the angle in radians."
	(self between: -1.0 and: 1.0)
		ifTrue: [^ self arcCos]
		ifFalse: [^ self sign arcCos]
]

{ #category : #'mathematical functions' }
Float >> signBit [
	"Answer 1 if the receiver has sign bit set (including case of IEEE-754 negative-zero).
	Answer 0 otherwise"

	^((self at: 1) bitShift: -31)
]

{ #category : #'truncation and round off' }
Float >> significand [

	^ self timesTwoPower: (self exponent negated)
]

{ #category : #'truncation and round off' }
Float >> significandAsInteger [
	"Answer the mantissa of a Float shifted so as to have the ulp equal to 1.
	For exceptional values, infinity and nan, just answer the bit pattern."

	self isFinite ifTrue:
		[^(self timesTwoPower: self class precision - 1 - (self exponent max: self class emin)) truncated abs].
	^(((self basicAt: 1) bitAnd: 16r000FFFFF) bitShift: 32) bitOr: (self basicAt: 2)
]

{ #category : #'mathematical functions' }
Float >> sinh [
	"Answer receivers hyperbolic sine"
	
	| ex |
	ex := self abs exp.
	^self copySignTo: (ex - ex reciprocal) / 2
]

{ #category : #'mathematical functions' }
Float >> sqrt [
	"Fallback code for absent primitives.
	Care to answer a correctly rounded result as mandated by IEEE-754."
	
	| guess selfScaled nextGuess exp secator hi lo remainder maxError |
	self <= 0.0
		ifTrue: [self = 0.0
				ifTrue: [^ self]
				ifFalse: [^ DomainError signal: 'sqrt undefined for number less than zero.']].
	self isFinite ifFalse: [^self].
	
	"scale to avoid loss of precision in case of gradual underflow
	(selfScaled between: 1.0 and: 2.0), so it is a good guess by itself"
	exp := self exponent // 2.
	guess := selfScaled := self timesTwoPower: exp * -2.
	
	"Use Newton-Raphson iteration - it converges quadratically
	(twice many correct bits at each loop)"
	[nextGuess := selfScaled - (guess * guess) / (2.0 * guess) + guess.
	"test if both guess are within 1 ulp"
	(nextGuess + guess) / 2.0  = guess]
		whileFalse: 
			["always round odd upper - this avoids infinite loop with alternate flip of last bit"
			guess := nextGuess + (nextGuess ulp/2.0)].
	
	"adjust the rounding - the guess can be 2 ulp up or 1 ulp down
	Let u = guess ulp.
	if (guess+u/2)^2<self, then guess is under-estimated
	if (guess-u/2)^2>self, then guess is over-estimated
	Note that they can't be equal (because left term has 55 bits).
	(guess+u/2)^2=guess^2 + guess*u + u^2/4 < self
	==> self - guess^2 > guess*u
	(guess-u/2)^2=guess^2 - guess*u + u^2/4 > self
	==> guess^2 - self >= guess*u
	(guess^2 - self) is evaluated with an emulated fused-multiply-add"
	
	["Decompose guess in two 26 bits parts hi,lo
	the trick is that they do not necessarily have the same sign
	If 53 bits are hi,0,lo => (hi,lo) else hi,1,lo=> (hi+1,-lo)"
	secator := "1<<27+1" 134217729.0.
	hi := guess * secator.
	hi :=hi + (guess - hi).
	lo := guess - hi.
	
	"The operations below are all exact"
	remainder := selfScaled - hi squared - (hi * lo * 2.0) - lo squared.
	maxError := guess timesTwoPower: 1 - Float precision.
	remainder > maxError or: [remainder negated >= maxError]]
			whileTrue: [guess :=remainder > 0.0
				ifTrue: [guess successor]
				ifFalse: [guess predecessor]].
	
	"undo the scaling"
	^ guess timesTwoPower: exp
]

{ #category : #printing }
Float >> storeOn: aStream [ 
	"Print the Number exactly so it can be interpreted back unchanged"
	
	self storeOn: aStream base: 10
]

{ #category : #printing }
Float >> storeOn: aStream base: base [ 
	"Print the Number exactly so it can be interpreted back unchanged"
	self isFinite
		ifTrue: [self signBit = 1 ifTrue: [aStream nextPutAll: '-'].
			base = 10 ifFalse: [aStream print: base; nextPut: $r].
			self = 0.0
				ifTrue: [aStream nextPutAll: '0.0']
				ifFalse: [self abs absPrintExactlyOn: aStream base: base]]
		ifFalse: [self isNaN
				ifTrue: [aStream nextPutAll: 'Float nan']
				ifFalse: [self > 0.0
						ifTrue: [aStream nextPutAll: 'Float infinity']
						ifFalse: [aStream nextPutAll: 'Float infinity negated']]]
]

{ #category : #'truncation and round off' }
Float >> successor [
	| ulp |
	self isFinite ifFalse: [
		(self isNaN or: [self positive]) ifTrue: [^self].
		^Float fmax negated].
	ulp := self ulp.
	^self + (0.5 * ulp) = self
		ifTrue: [self * -1.0 - ulp * -1.0 "This trick is for obtaining a negativeZero"]
		ifFalse: [self + (0.5 * ulp)]
]

{ #category : #'mathematical functions' }
Float >> tan [
	"Answer the tangent of the receiver taken as an angle in radians."

	^ self sin / self cos
]

{ #category : #'mathematical functions' }
Float >> tanh [
	"Answer hyperbolic tangent of receiver.
	Trivial implementation is:
		^self sinh/self cosh
	This implementation takes care not to overflow."

	| ex emx |
	self = 0.0 ifTrue: [^self].	"Handle negativeZero"
	self > 20.0 ifTrue: [^1.0].
	self < -20.0 ifTrue: [^-1.0].
	ex := self exp.
	emx := ex reciprocal.
	^(ex - emx) / (ex + emx)
]

{ #category : #'mathematical functions' }
Float >> timesTwoPower: anInteger [ 
	"Answer with the receiver multiplied by 2.0 raised
	to the power of the argument"

	self isFinite ifFalse: [^self].
	self isZero ifTrue: [^self].
	
	"Make sure that (2.0 raisedTo: Integer) can be safely used without overflow
	For example:
		Float fminNormalized * (2.0 raisedTo: 2000) = Float infinity.
	while:
		(Float fminNormalized timesTwoPower: 2000) = (2.0 raisedTo: 2000+Float emin)."	
	anInteger > Float emax ifTrue: [^(self timesTwoPower: Float emax) timesTwoPower: anInteger - Float emax].
	
	"In case of gradual underflow, timesTwoPower: is not exact, so greatest care must be taken
	because two consecutive timesTwoPower: might differ from a single one"
	anInteger < (Float emin - Float precision + 1)
		ifTrue:
			[| deltaToUnderflow |
			deltaToUnderflow := Float emin - self exponent max: Float emin - Float precision + 1.
			deltaToUnderflow >= 0 ifTrue:
				["self is already near or past underflow, so don't care, result will be zero"
				deltaToUnderflow := Float emin].
			^(self timesTwoPower: deltaToUnderflow) timesTwoPower: anInteger - deltaToUnderflow].
	
	"If (2.0 raisedToInteger: anInteger) fit in a positive SmallInteger, then use faster SmallInteger conversion.
	Note that SmallInteger maxVal highBit = 30 in a 32 bits image, so 1 can be shifted 29 times."
	anInteger > -30 ifTrue: [
		anInteger < 0 ifTrue: [^ self / (1 bitShift: 0 - anInteger) asFloat].
		anInteger < 30 ifTrue: [^ self * (1 bitShift: anInteger) asFloat]].
	
	^ self * (2.0 raisedToInteger: anInteger)
]

{ #category : #'truncation and round off' }
Float >> ulp [
	"Answer the unit of least precision of self (the power of two corresponding to last bit of mantissa)"
	
	| exponent |
	self isFinite ifFalse: [^self abs].
	self = 0.0 ifTrue: [^Float fmin].
	exponent := self exponent.
	^exponent < self class emin
		ifTrue: [Float fminDenormalized]
 		ifFalse: [Float epsilon timesTwoPower: exponent]
]

{ #category : #copying }
Float >> veryDeepCopyWith: deepCopier [
	"Return self.  Do not record me."

	^self shallowCopy
]
