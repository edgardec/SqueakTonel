"
My instances are at least 31-bit numbers, stored in twos complement form. The allowable range in 32-bits is approximately +- 10^9 (+- 1billion).  In 64-bits my instances are 61-bit numbers, stored in twos complement form. The allowable range is approximately +- 10^18 (+- 1 quintillion).   The actual values are computed at start-up.  See SmallInteger class startUp:, minVal, maxVal.
"
Class {
	#name : #SmallInteger,
	#superclass : #Integer,
	#type : #immediate,
	#classInstVars : [
		'minVal',
		'maxVal'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
SmallInteger class >> basicNew [

	self error: 'SmallIntegers can only be created by performing arithmetic'
]

{ #category : #'instance creation' }
SmallInteger class >> basicNew: sizeRequested [

	self error: 'SmallIntegers can only be created by performing arithmetic'
]

{ #category : #documentation }
SmallInteger class >> guideToDivision [
	"Handy guide to the kinds of Integer division: 
	/  exact division, returns a fraction if result is not a whole integer. 
	//  returns an Integer, rounded towards negative infinity. 
	\\ is modulo rounded towards negative infinity. 
	quo:  truncated division, rounded towards zero."
]

{ #category : #'class initialization' }
SmallInteger class >> initialize [
	SmalltalkImage current addToStartUpList: self before: Delay.
	self startUp: true
]

{ #category : #constants }
SmallInteger class >> maxVal [
	"Answer the maximum value for a SmallInteger."
	^maxVal
]

{ #category : #constants }
SmallInteger class >> minVal [
	"Answer the minimum value for a SmallInteger."
	^minVal
]

{ #category : #'instance creation' }
SmallInteger class >> new [

	self basicNew	"generates an error"
]

{ #category : #'class initialization' }
SmallInteger class >> startUp: resuming [
	"The image is either being newly started (resuming is true), or it's just been snapshotted.
	 If this has just been a snapshot, skip all the startup stuff."
	| next val |
	resuming ifFalse: [^self].
	val := -32768. "Assume at least 16 bits"
	[next := val + val.
	 next class == self] whileTrue:
		[val := next].
	minVal := val.
	maxVal := -1 - val
]

{ #category : #arithmetic }
SmallInteger >> * aNumber [ 
	"Primitive. Multiply the receiver by the argument and answer with the
	result if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger. Essential. No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 9>
	^ super * aNumber
]

{ #category : #arithmetic }
SmallInteger >> + aNumber [ 
	"Primitive. Add the receiver to the argument and answer with the result
	if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger  Essential  No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 1>
	^ super + aNumber
]

{ #category : #arithmetic }
SmallInteger >> - aNumber [ 
	"Primitive. Subtract the argument from the receiver and answer with the
	result if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger. Essential. No Lookup. See Object documentation
	whatIsAPrimitive."

	<primitive: 2>
	^super - aNumber
]

{ #category : #arithmetic }
SmallInteger >> / aNumber [ 
	"Primitive. This primitive (for /) divides the receiver by the argument
	and returns the result if the division is exact. Fail if the result is not a
	whole integer. Fail if the argument is 0 or is not a SmallInteger. Optional.
	No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 10>
	aNumber isZero ifTrue: [^(ZeroDivide dividend: self) signal].
	^(aNumber isMemberOf: SmallInteger)
		ifTrue: [(Fraction numerator: self denominator: aNumber) reduced]
		ifFalse: [super / aNumber]
]

{ #category : #arithmetic }
SmallInteger >> // aNumber [ 
	"Primitive. Divide the receiver by the argument and answer with the
	result. Round the result down towards negative infinity to make it a
	whole integer. Fail if the argument is 0 or is not a SmallInteger.
	Essential. No Lookup. See Object documentation whatIsAPrimitive. "

	<primitive: 12>
	^ super // aNumber 	"Do with quo: if primitive fails"
]

{ #category : #comparing }
SmallInteger >> < aNumber [ 
	"Primitive. Compare the receiver with the argument and answer with
	true if the receiver is less than the argument. Otherwise answer false.
	Fail if the argument is not a SmallInteger. Essential. No Lookup. See
	Object documentation whatIsAPrimitive."

	<primitive: 3>
	^super < aNumber
]

{ #category : #comparing }
SmallInteger >> <= aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is less than or equal to the argument. Otherwise answer
	false. Fail if the argument is not a SmallInteger. Optional. No Lookup.
	See Object documentation whatIsAPrimitive. "

	<primitive: 5>
	^super <= aNumber
]

{ #category : #comparing }
SmallInteger >> = aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is equal to the argument. Otherwise answer false. Fail if the
	argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive. "

	<primitive: 7>
	^super = aNumber
]

{ #category : #comparing }
SmallInteger >> > aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is greater than the argument. Otherwise answer false. Fail if
	the argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive."

	<primitive: 4>
	^super > aNumber
]

{ #category : #comparing }
SmallInteger >> >= aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is greater than or equal to the argument. Otherwise answer
	false. Fail if the argument is not a SmallInteger. Optional. No Lookup.
	See Object documentation whatIsAPrimitive."

	<primitive: 6>
	^super >= aNumber
]

{ #category : #arithmetic }
SmallInteger >> \\ aNumber [ 
	"Primitive. Take the receiver modulo the argument. The result is the
	remainder rounded towards negative infinity, of the receiver divided by
	the argument Fail if the argument is 0 or is not a SmallInteger. Optional.
	No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 11>
	^ super \\ aNumber 	"will use // to compute it if primitive fails"
]

{ #category : #converting }
SmallInteger >> as31BitSmallInt [
	"Polymorphic with LargePositiveInteger (see comment there).
	 Return self since all SmallIntegers are 31 bits"

	^ self
]

{ #category : #converting }
SmallInteger >> asCharacter [
	<primitive: 170>
	^self primitiveFailed
]

{ #category : #converting }
SmallInteger >> asFloat [
	"Primitive. Answer a Float that represents the value of the receiver.
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 40>
	self primitiveFailed
]

{ #category : #'bit manipulation' }
SmallInteger >> bitAnd: arg [ 
	"Primitive. Answer an Integer whose bits are the logical AND of the
	 receiver's bits and those of the argument, arg.
	 Numbers are interpreted as having 2's-complement representation.
	 Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 14>
	self >= 0 ifTrue: [^arg bitAnd: self].
	^arg < 0
		ifTrue: [(arg bitInvert bitOr: self bitInvert) bitInvert]
		ifFalse: [arg bitClear: self bitInvert]
]

{ #category : #'bit manipulation' }
SmallInteger >> bitCount [
	"Count the number of bits set to 1 in self. Overridden for performance"

	| n bitCount |
	self < 0 ifTrue: [self error: 'Cannot count bits of negative integers'].
	bitCount := 0.
	n := self.
	[ n = 0 ] whileFalse: [
		bitCount := bitCount + (BitCountPerByteTable at: (n bitAnd: 16rFF) + 1).
		n := n bitShift: -8 ].
	^bitCount
]

{ #category : #'bit manipulation' }
SmallInteger >> bitCountOfByte [
	"Count the number of bits set to 1 in a byte."

	^BitCountPerByteTable at: self + 1
]

{ #category : #'bit manipulation' }
SmallInteger >> bitOr: arg [ 
	"Primitive. Answer an Integer whose bits are the logical OR of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 15>
	self >= 0 ifTrue: [^ arg bitOr: self].
	^ arg < 0
		ifTrue: [(self bitInvert bitAnd: arg bitInvert) bitInvert]
		ifFalse: [(self bitInvert bitClear: arg) bitInvert]
]

{ #category : #'bit manipulation' }
SmallInteger >> bitShift: arg [ 
	"Primitive. Answer an Integer whose value is the receiver's value shifted
	left by the number of bits indicated by the argument. Negative arguments
	shift right. The receiver is interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 17>
	self = 0 ifTrue: [^self].
	self > 0 ifTrue: [^ super bitShift: arg].
	^ arg >= 0
		ifTrue: [(self negated bitShift: arg) negated]
		ifFalse: [(self bitInvert bitShift: arg) bitInvert]
]

{ #category : #'bit manipulation' }
SmallInteger >> bitXor: arg [ 
	"Primitive. Answer an Integer whose bits are the logical XOR of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 16>
	self >= 0 ifTrue: [^ arg bitXor: self].
	^ arg < 0
		ifTrue: [self bitInvert bitXor: arg bitInvert]
		ifFalse: [(self bitInvert bitXor: arg) bitInvert]
]

{ #category : #'bit manipulation' }
SmallInteger >> byteReversed [
	"Answer the receiver with bits reversed in a byte.
	The receiver must be between 0 and 255.
	The constant has been obtained by this snippet:
	(0 to: 255) collect: [:e |
		| r |
		r := ((e bitAnd: 2r11110000) bitShift: -4) + ((e bitAnd: 2r00001111) bitShift: 4).
		r := ((r bitAnd: 2r11001100) bitShift: -2) + ((r bitAnd: 2r00110011) bitShift: 2).
		((r bitAnd: 2r10101010) bitShift: -1) + ((r bitAnd: 2r01010101) bitShift: 1).] as: ByteArray"
	
	^#[0 128 64 192 32 160 96 224 16 144 80 208 48 176 112 240 8 136 72 200 40 168 104 232 24 152 88 216 56 184 120 248 4 132 68 196 36 164 100 228 20 148 84 212 52 180 116 244 12 140 76 204 44 172 108 236 28 156 92 220 60 188 124 252 2 130 66 194 34 162 98 226 18 146 82 210 50 178 114 242 10 138 74 202 42 170 106 234 26 154 90 218 58 186 122 250 6 134 70 198 38 166 102 230 22 150 86 214 54 182 118 246 14 142 78 206 46 174 110 238 30 158 94 222 62 190 126 254 1 129 65 193 33 161 97 225 17 145 81 209 49 177 113 241 9 137 73 201 41 169 105 233 25 153 89 217 57 185 121 249 5 133 69 197 37 165 101 229 21 149 85 213 53 181 117 245 13 141 77 205 45 173 109 237 29 157 93 221 61 189 125 253 3 131 67 195 35 163 99 227 19 147 83 211 51 179 115 243 11 139 75 203 43 171 107 235 27 155 91 219 59 187 123 251 7 135 71 199 39 167 103 231 23 151 87 215 55 183 119 247 15 143 79 207 47 175 111 239 31 159 95 223 63 191 127 255] at: 1 + self
]

{ #category : #printing }
SmallInteger >> decimalDigitLength [
	"Answer the number of digits printed out in base 10.
	 Note that this only works for positive SmallIntegers up to 63-bits."
	
	self <= 99999999 "8" ifTrue: [
		self <= 9999 "4" ifTrue: [
			self <= 99 "2" ifTrue: [
				self <= 9 "1" ifTrue: [ ^1].
				^2 ].
			self <= 999 "3" ifTrue: [ ^3].
			^4 ].
		self <= 999999 "6" ifTrue: [
			self <= 99999 "5" ifTrue: [ ^5 ].
			^6 ].
		self <= 9999999 "7" ifTrue: [ ^7 ].
		^8 ].
	self <= 1073741823 "10" ifTrue: [ "This is here only to avoid LargeInteger comparisons in 32-bit VMs"
		self <= 999999999 "9" ifTrue: [ ^9 ].
		^10 ].
	self <= 999999999999999 "15" ifTrue: [
		self <= 9999999999999 "13" ifTrue: [
			self <= 99999999999 "11" ifTrue: [
				self <= 9999999999 "10" ifTrue: [ ^10 ].
				^11 ].
			self <= 999999999999 "12" ifTrue: [ ^12 ].
			^13 ].
		self <= 99999999999999 "14" ifTrue: [ ^14 ].
		^15 ].
	self <= 99999999999999999 "17" ifTrue: [
		self <= 9999999999999999 "16" ifTrue: [ ^16 ].
		^17 ].
	self <= 999999999999999999 "18" ifTrue: [ ^18 ].
	^19 "(1 << 60 - 1) asString size"
]

{ #category : #copying }
SmallInteger >> deepCopy [
	"Answer the receiver, because SmallIntegers are unique."
	^self
]

{ #category : #'system primitives' }
SmallInteger >> digitAt: n [ 
	"Answer the value of an apparent byte-indexable field in the receiver,
	 analogous. to the large integers, which are organized as bytes."

	n = 1 ifTrue: "Negate carefully in case the receiver is SmallInteger minVal"
		[self < 0 ifTrue:
			[^-256 - self bitAnd: 255].
		 ^self bitAnd: 255].
	self < 0 ifTrue:
		[^(-256 - self bitShift: -8) + 1 digitAt: n - 1].
	^(self bitShift: 8 - (n bitShift: 3)) bitAnd: 255
]

{ #category : #'system primitives' }
SmallInteger >> digitAt: n put: value [ 
	"Fails. The digits of a small integer can not be modified."

	self error: 'You can''t store in a SmallInteger'
]

{ #category : #'system primitives' }
SmallInteger >> digitLength [
	"Answer the number of indexable fields in the receiver. This value is the 
	 same as the largest legal subscript. Included so that a SmallInteger can 
	 behave like a LargePositiveInteger or LargeNegativeInteger."

	| value length |
	length := 1.
	(value := self) < -255
		ifTrue:
			[length := 2.
			value := (-256 - self bitShift: -8) + 1 "carefully negate SmallInteger minVal"].
	[value > 255] whileTrue:
		[value := value bitShift: -8.
		 length := length + 1].
	^length
]

{ #category : #private }
SmallInteger >> digitsAsFloat [
	"private - let the primitive take care to answer the nearest float"
	<primitive: 40>
	^super digitsAsFloat * self sign
]

{ #category : #testing }
SmallInteger >> even [

	^(self bitAnd: 1) = 0
]

{ #category : #private }
SmallInteger >> fromString: str radix: radix [

	| maxdigit c val |
	maxdigit := 
		radix + (radix > 10
					ifTrue: [55 - 1]
					ifFalse: [48 - 1]).
	val := 0.
	1 to: str size do: 
		[:i | 
		c := str at: i.
		(c < 48 ifFalse: [c > maxdigit])
			ifTrue: [^false].
		val := val * radix + (c <= 57
							ifTrue: [c - 48]
							ifFalse: 
								[c < 65 ifTrue: [^false].
								c - 55])].
	^val
]

{ #category : #arithmetic }
SmallInteger >> gcd: anInteger [ 
	"See SmallInteger (Integer) | gcd:"
	| n m |
	anInteger denominator = 1 ifFalse: [^anInteger gcd: self].
	n := self.
	m := anInteger.
	[n = 0]
		whileFalse: 
			[n := m \\ (m := n)].
	^ m abs
]

{ #category : #comparing }
SmallInteger >> hash [
	"Answer an integer value that is related to the value of the receiver.
	 Since the integers are by definition perfectly distributed answer self
	 (it is impossible to derive a hash function that is better distributed
	 than the SmallIntegers themselves). c.f. LargePositiveInteger hash."

	^self
]

{ #category : #'bit manipulation' }
SmallInteger >> hashMultiply [
	"This is a multiplication by by 1664525 mod 2^28 written to avoid overflowing into large integers.
	 The primitive is able to perform the operation with modulo arihmetic."
	<primitive: 159>
	| low |
	low := self bitAnd: 16383.
	^(16r260D * low + ((16r260D * (self bitShift: -14) + (16r0065 * low) bitAnd: 16383) * 16384))
			bitAnd: 16r0FFFFFFF
]

{ #category : #'bit manipulation' }
SmallInteger >> highBit [
	"Answer the index of the high order bit of the receiver, or zero if the  
	receiver is zero. Raise an error if the receiver is negative, since  
	negative integers are defined to have an infinite number of leading 1's 
	in 2's-complement arithmetic. Use >>highBitOfMagnitude if you want to 
	get the highest bit of the magnitude."
	<primitive: 575>
	self < 0 ifTrue: [^ self error: 'highBit is not defined for negative integers'].
	^ self highBitOfPositiveReceiver
]

{ #category : #private }
SmallInteger >> highBitOfByte [
	"The high bits table can be obtained with:
	(1 to: 8) inject: #[0] into: [:highBits :rank | highBits , (highBits collect: [:e | rank])]."
	^ #[0 1 2 2 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8] at: self + 1
]

{ #category : #'bit manipulation' }
SmallInteger >> highBitOfMagnitude [
	"Answer the index of the high order bit of the receiver, or zero if the  
	receiver is zero. This method is used for negative SmallIntegers as well,  
	since Squeak's LargeIntegers are sign/magnitude."
	
	<primitive: 575>
	self < 0 ifTrue: [^self negated highBit].
	^self highBitOfPositiveReceiver
]

{ #category : #private }
SmallInteger >> highBitOfPositiveReceiver [
	| shifted bitNo |
	"Answer the index of the high order bit of the receiver, or zero if the 
	receiver is zero. Receiver has to be positive!"
	shifted := self.
	bitNo := 0.
	[shifted < 65536]
		whileFalse: 
			[shifted := shifted bitShift: -16.
			bitNo := bitNo + 16].
	shifted < 256
		ifFalse: 
			[shifted := shifted bitShift: -8.
			bitNo := bitNo + 8].
	^bitNo + shifted highBitOfByte
]

{ #category : #comparing }
SmallInteger >> identityHash [

	^self
]

{ #category : #'system primitives' }
SmallInteger >> instVarAt: i [ 
	"Small integer has to be specially handled."

	i = 1 ifTrue: [^self].
	self error: 'argument too big for small integer instVarAt:'
]

{ #category : #testing }
SmallInteger >> isAnExactFloat [
	"See super.
	When you're small, the fastest way is to try"
	
	^self asFloat truncated = self
]

{ #category : #testing }
SmallInteger >> isLarge [
	^false
]

{ #category : #testing }
SmallInteger >> isPowerOfTwo [
	"Return true if the receiver is an integral power of two. Optimized version."
	
	^self > 0 and: [ (self bitAnd: self - 1) = 0 ]
]

{ #category : #'bit manipulation' }
SmallInteger >> lowBit [
	" Answer the index of the low order one bit.
		2r00101000 lowBit       (Answers: 4)
		2r-00101000 lowBit      (Answers: 4)
	  First we skip bits in groups of 8, then do a lookup in a table.
	  While not optimal, this is a good tradeoff; long
	  integer #lowBit always invokes us with bytes."

	| n result lastByte |
	n := self.
	n = 0 ifTrue: [ ^ 0 ].
	result := 0.
	[(lastByte := n bitAnd: 16rFF) = 0]
		whileTrue: [
			result := result + 8.
			n := n bitShift: -8 ].
	^result + (LowBitPerByteTable at: lastByte)
]

{ #category : #'system primitives' }
SmallInteger >> nextInstance [
	"SmallIntegers can't be enumerated this way.  There are a finite number of them from from (SmallInteger minVal) to (SmallInteger maxVal), but you'll have to enumerate them yourself with:
	(SmallInteger minVal) to: (SmallInteger maxVal) do: [:integer | <your code here>].
	"

	self shouldNotImplement 
]

{ #category : #'system primitives' }
SmallInteger >> nextObject [
	"SmallIntegers are immediate objects, and, as such, do not have successors in object memory."

	self shouldNotImplement 
]

{ #category : #printing }
SmallInteger >> numberOfDigitsInBase: b [ 
	"Return how many digits are necessary to print this number in base b.
	Mostly same as super but an optimized version for base 10 case"
	
	b = 10 ifFalse: [^super numberOfDigitsInBase: b].
	self < 0 ifTrue: [^self negated numberOfDigitsInBase: b]. "We can't use #decimalDigitLength here, because the receiver might be SmallInteger minVal."
	^self decimalDigitLength
]

{ #category : #'objects from disk' }
SmallInteger >> objectForDataStream: refStrm [
	"In a 64-bit Spur VM, we may have to fake 32-bit SmallIntegers for compatibility."

	| large |
	self > 16r3FFFFFFF ifTrue: [
		large := LargePositiveInteger new: self digitLength neg: false.
		1 to: self digitLength do: [:i | large digitAt: i put: (self digitAt: i)].
		^large].
	self < -16r40000000 ifTrue: [
		large := LargeNegativeInteger new: self digitLength neg: true.
		1 to: self digitLength do: [:i | large digitAt: i put: (self digitAt: i)].
		^large].
	^ self
]

{ #category : #testing }
SmallInteger >> odd [

	^(self bitAnd: 1) = 1
]

{ #category : #printing }
SmallInteger >> printOn: stream base: base [ 
	"Append a representation of this number in base b on aStream."

	self printOn: stream base: base length: 0 padded: false
]

{ #category : #printing }
SmallInteger >> printOn: stream base: base length: minimumLength padded: padWithZeroes [

	| n numberOfDigits totalLength divisor |
	self < 0
		ifTrue: [
			n := self negated.
			totalLength := 1 ]
		ifFalse: [
			n := self.
			totalLength := 0 ].
	numberOfDigits := n numberOfDigitsInBase: base.
	totalLength := totalLength + numberOfDigits.
	padWithZeroes ifFalse: [
		[ totalLength < minimumLength ] whileTrue: [
			stream space.
			totalLength := totalLength + 1 ] ].
	self < 0 ifTrue: [ stream nextPut: $- ].
	padWithZeroes ifTrue: [
		[ totalLength < minimumLength ] whileTrue: [
			stream nextPut: $0.
			totalLength := totalLength + 1 ] ].
	numberOfDigits > 1 ifTrue: [
		divisor := base = 10
			ifTrue: [ #(1 10 100 1000 10000 100000 1000000 10000000 100000000 1000000000 10000000000 100000000000 1000000000000 10000000000000 100000000000000 1000000000000000 10000000000000000 100000000000000000 1000000000000000000) at: numberOfDigits ]
			ifFalse: [ base raisedToInteger: numberOfDigits - 1 ].
		[ divisor > 1 ] whileTrue: [
			| digit |
			digit := n // divisor.
			stream nextPut: ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' at: digit + 1).
			n := n - (digit * divisor).
			divisor := divisor // base ] ].
	^stream nextPut: ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' at: n + 1)
]

{ #category : #printing }
SmallInteger >> printOn: aStream base: b nDigits: n [ 
	"Append a representation of this number in base b on aStream using nDigits.
	self must be positive."

	self printOn: aStream base: b length: n padded: true
]

{ #category : #printing }
SmallInteger >> printString [
	"Highly optimized version for base 10
	and that we know it is a SmallInteger."
	
	| integer next result len |
	self = 0 ifTrue: [^'0'].
	self < 0 ifTrue: [^'-', self negated printString].
	len := self decimalDigitLength.
	result := String new: len.
	integer := self.
	len to: 1 by: -1 do: [:i |
		next := integer // 10.
		result byteAt: i put: 48 + (integer - (next * 10)).
		integer := next].
	^result
]

{ #category : #printing }
SmallInteger >> printStringBase: b [ 
	"Return a String representation of this number in base b.
	For SmallIntegers, it is more efficient to print directly in a String,
	rather than using a Stream like super."

	self < 0
		ifTrue: [^ '-'
				, (self negated printStringBase: b)].
	self < b
		ifTrue: [^ String
				with: (Character digitValue: self)].
	^ self printStringBase: b nDigits: (self numberOfDigitsInBase: b)
]

{ #category : #printing }
SmallInteger >> printStringBase: b nDigits: n [
	"Return a string representation of this number in base b with n digits (left padded with 0).
	Should be invoked with: 0 <= self < (b raisedToInteger: n)."
	
	| integer next result |
	result := String new: n.
	integer := self.
	n to: 1 by: -1 do: [:i |
		next := integer // b.
		result byteAt: i put: (Character digitValue: (integer - (next * b))).
		integer := next].
	^result
]

{ #category : #arithmetic }
SmallInteger >> quo: aNumber [ 
	"Primitive. Divide the receiver by the argument and answer with the 
	result. Round the result down towards zero to make it a whole integer. 
	Fail if the argument is 0 or is not a SmallInteger. Optional. See Object 
	documentation whatIsAPrimitive."
	<primitive: 13>
	aNumber = 0 ifTrue: [^ (ZeroDivide dividend: self) signal].
	(aNumber isMemberOf: SmallInteger)
		ifFalse: [^ super quo: aNumber].
	(aNumber = -1 and: [self = self class minVal])
		ifTrue: ["result is aLargeInteger" ^ self negated].
	self primitiveFailed
]

{ #category : #comparing }
SmallInteger >> scaledIdentityHash [
	"For identityHash values returned by primitive 75, answer
	such values times 2^8.  Otherwise, match the existing
	identityHash implementation"
	
	^self
]

{ #category : #copying }
SmallInteger >> shallowCopy [
	"Answer the receiver, because SmallIntegers are unique."
	^self
]

{ #category : #'mathematical functions' }
SmallInteger >> sqrt [
	"Answer the square root of the receiver.
	If the square root is exact, answer an Integer, else answer a Float approximation"
	| floatResult integerResult |
	self negative ifTrue: [
		^ DomainError signal: 'sqrt undefined for number less than zero.' ].
	floatResult := self asFloat sqrt.
	integerResult := floatResult truncated.
	"Note: truncated works for 60-bit SmallInteger
	If self is a square s^2, but asFloat rounds down,
	f = s^2*(1-e), f^0.5 = s*(1-e)^0.5 = s*(1-0.5*e+O(e^2))
	since s asFloat is exact, and e <= 0.5*ulp(1),
	s*(1-0.5*e+O(e^2)) always rounds to s"
	integerResult * integerResult = self ifTrue: [^integerResult].
	^floatResult
]

{ #category : #'mathematical functions' }
SmallInteger >> sqrtFloor [
	"See super. Use asFloat sqrt which is known to be exactly rounded.
	Adjust the result in case self asFloat is inexact.
	An example why it is necessary with 60 bits SmallInteger is:
		| i |
		i := (1<<28-1) squared - 1.
		i asFloat sqrt truncated squared <= i.
	What happens is that i and and next perfect square above i, s^2
	are rounded to the same Float f >= s^2.
	In other words, asFloat did cross the next perfect square boundary.
	The guess is at most off by 1, because the next next perfect square is:
		(s + 1) squared = (2*s + s squared + 1)
	s squared has at most 60 bits, and 2*s has 31 bits in this case,
	s squared highBit - (2*s) highBit < Float precision,
	so we are sure that next next perfect square is a different Float."

	| guess |
	guess := self asFloat sqrt truncated.
	guess * guess > self ifTrue: [^guess - 1].
	^guess
]

{ #category : #'mathematical functions' }
SmallInteger >> sqrtRem [
	"See super"

	| s |
	s := self sqrtFloor.
	^{s. self - (s*s)}
]

{ #category : #printing }
SmallInteger >> threeDigitName [

	| units answer |

	self = 0 ifTrue: [^''].
	units := #('one' 'two' 'three' 'four' 'five' 'six' 'seven' 'eight' 'nine' 'ten' 
		'eleven' 'twelve' 'thirteen' 'fourteen' 'fifteen' 'sixteen' 'seventeen' 
		'eighteen' 'nineteen').
	self > 99 ifTrue: [
		answer := (units at: self // 100),' hundred'.
		(self \\ 100) = 0 ifFalse: [
			answer := answer,' ',(self \\ 100) threeDigitName
		].
		^answer
	].
	self < 20 ifTrue: [
		^units at: self
	].
	answer := #('twenty' 'thirty' 'forty' 'fifty' 'sixty' 'seventy' 'eighty' 'ninety')
			at: self // 10 - 1.
	(self \\ 10) = 0 ifFalse: [
		answer := answer,'-',(units at: self \\ 10)
	].
	^answer
]

{ #category : #copying }
SmallInteger >> veryDeepCopyWith: deepCopier [
	"Answer the receiver, because SmallIntegers are unique."
	^self
]

{ #category : #comparing }
SmallInteger >> ~= aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is not equal to the argument. Otherwise answer false. Fail if
	the argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive."

	<primitive: 8>
	^super ~= aNumber
]
