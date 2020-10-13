"
I am a common abstract superclass for all Integer implementations. My implementation subclasses are SmallInteger, LargePositiveInteger, and LargeNegativeInteger.
	
Integer division consists of:
	/	exact division, answers a fraction if result is not a whole integer
	//	answers an Integer, rounded towards negative infinity
	\\	is modulo rounded towards negative infinity
	quo: truncated division, rounded towards zero
"
Class {
	#name : #Integer,
	#superclass : #Number,
	#classVars : [
		'BitCountPerByteTable',
		'LowBitPerByteTable'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
Integer class >> basicNew [

	self == Integer ifTrue: [
		^ self error: 'Integer is an abstract class.  Make a concrete subclass.'].
	^ super basicNew
]

{ #category : #'instance creation' }
Integer class >> byte1: byte1 byte2: byte2 byte3: byte3 byte4: byte4 [
	"Depending on the size of SmallInteger maxVal and the high-order byte,
	 either copy directly into a LargeInteger, or build up a SmallInteger by shifting"
	| value |
	((SmallInteger maxVal > 1073741823)
	or: [byte4 < 16r40]) ifTrue:
		[^ (byte4 bitShift: 24)
		 + (byte3 bitShift: 16)
		 + (byte2 bitShift: 8)
		 + byte1].
	value := LargePositiveInteger new: 4.
	value digitAt: 4 put: byte4.
	value digitAt: 3 put: byte3.
	value digitAt: 2 put: byte2.
	value digitAt: 1 put: byte1.
	^value
]

{ #category : #'instance creation' }
Integer class >> byte1: byte1 byte2: byte2 byte3: byte3 byte4: byte4 byte5: byte5 byte6: byte6 byte7: byte7 byte8: byte8 [
	"Depending on the size of SmallInteger maxVal and the high-order byte,
	 either copy directly into a LargeInteger, or build up a SmallInteger by shifting"
	| value |
	(SmallInteger maxVal > 1073741823
		ifTrue: [byte8 <= (SmallInteger maxVal digitAt: 8)]
		ifFalse: [byte5 + byte6 + byte7 = 0 and: [byte4 < 16r40]]) ifTrue:
			[^ (byte8 bitShift: 56)
			 + (byte7 bitShift: 48)
			 + (byte6 bitShift: 40)
			 + (byte5 bitShift: 32)
			 + (byte4 bitShift: 24)
			 + (byte3 bitShift: 16)
			 + (byte2 bitShift: 8)
			 + byte1].
	value := LargePositiveInteger new: 8.
	value digitAt: 8 put: byte8.
	value digitAt: 7 put: byte7.
	value digitAt: 6 put: byte6.
	value digitAt: 5 put: byte5.
	value digitAt: 4 put: byte4.
	value digitAt: 3 put: byte3.
	value digitAt: 2 put: byte2.
	value digitAt: 1 put: byte1.
	^value
]

{ #category : #'class initialization' }
Integer class >> initialize [
	"Integer initialize"
	
	self 
		initializeLowBitPerByteTable;
		initializeBitCountPerByteTable
]

{ #category : #'class initialization' }
Integer class >> initializeBitCountPerByteTable [
	"Initialize BitCountPerByteTable which is a ByteArray that contains the number of set bits (1) of the integers between 0 and 255. It's defined as a class variable so that it can be used from the instance side and subclasses too."
	"Evaluate this expression to form the byte array:
	((0 to: 255)
		collect: [:i | 
			| bitCount n |
			n := i.
			bitCount := 0.
			[n = 0]
				whileFalse:
					[bitCount := bitCount + 1.
					n := n bitAnd: n - 1].
			bitCount]
		as: ByteArray)"
	
	BitCountPerByteTable := #[0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 4 5 5 6 5 6 6 7 5 6 6 7 6 7 7 8]
]

{ #category : #'class initialization' }
Integer class >> initializeLowBitPerByteTable [
	"Initialize LowBitPerByteTable which is a ByteArray that contains the index of the lowest set bit of the integers between 1 and 255. It's defined as a class variable because it's used from the instance side and subclasses."
	"The low bits table can be obtained with:
	((1 to: 8) inject: #[1] into: [:lowBits :rank | (lowBits copy at: 1 put: lowBits first + 1; yourself) , lowBits]) allButFirst
	or with it's symmetric pair:
	((1 to: 8) inject: #[1] into: [:lowBits :rank | lowBits, (lowBits copy atLast: 1 put: lowBits last + 1; yourself)]) allButLast."
	
	LowBitPerByteTable := #[1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 7 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 8 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 7 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1]
]

{ #category : #'instance creation' }
Integer class >> initializedInstance [
	^ 2468
]

{ #category : #'prime numbers' }
Integer class >> largePrimesUpTo: maxValue [
	"Compute and return all the prime numbers up to maxValue"
	^Array streamContents:[:s| self largePrimesUpTo: maxValue do:[:prime| s nextPut: prime]]
]

{ #category : #'prime numbers' }
Integer class >> largePrimesUpTo: max do: aBlock [
	"Evaluate aBlock with all primes up to maxValue.
	The Algorithm is adapted from http://www.rsok.com/~jrm/printprimes.html
	It encodes prime numbers much more compactly than #primesUpTo: 
	38.5 integer per byte (2310 numbers per 60 byte) allow for some fun large primes.
	(all primes up to SmallInteger maxVal can be computed within ~27MB of memory;
	the regular #primesUpTo: would require one *GIGA*byte).
	Note: The algorithm could be re-written to produce the first primes (which require
	the longest time to sieve) faster but only at the cost of clarity."

	| n limit flags maskBitIndex bitIndex maskBit byteIndex index primesUpTo2310 indexLimit increments incrementIndex |
	limit := max asInteger - 1.
	indexLimit := max asInteger sqrtFloor + 1.
	"Create the array of flags."
	flags := ByteArray new: (limit + 2309) // 2310 * 60 + 60.
	flags atAllPut: 16rFF. "set all to true"

	"Compute the primes up to 2310"
	primesUpTo2310 := self primesUpTo: 2310.

	"Create a mapping from 2310 integers to 480 bits (60 byte)"
	maskBitIndex := Array new: 2310.
	bitIndex := -1. "for pre-increment"
	maskBitIndex at: 1 put: (bitIndex := bitIndex + 1).
	maskBitIndex at: 2 put: (bitIndex := bitIndex + 1).

	index := 1.
	[ index <= 5 ] whileTrue: [
		aBlock value: (primesUpTo2310 at: index).
		index := index + 1 ].
	
	n := 2.
	[ n <= 2309 ] whileTrue: [
		[(primesUpTo2310 at: index) < n] 
			whileTrue:[index := index + 1].
		n = (primesUpTo2310 at: index) ifTrue:[
			maskBitIndex at: n+1 put: (bitIndex := bitIndex + 1).
		] ifFalse:[
			"if modulo any of the prime factors of 2310, then could not be prime"
			(n \\ 2 = 0 or:[n \\ 3 = 0 or:[n \\ 5 = 0 or:[n \\ 7 = 0 or:[n \\ 11 = 0]]]]) 
				ifTrue:[maskBitIndex at: n+1 put: 0]
				ifFalse:[maskBitIndex at: n+1 put: (bitIndex := bitIndex + 1)].
		].
		n := n + 1 ].

	"Now the real work begins...
	Start with 13 since multiples of 2,3,5,7,11 are handled by the storage method;
	increment by iterating through increments, which enables us to only check about 20.77% of all numbers."
	n := 13.
	increments := #[4 2 4 6 2 6 4 2 4 6 6 2 6 4 2 6 4 6 8 4 2 4 2 4 14 4 6 2 10 2 6 6 4 2 4 6 2 10 2 4 2 12 10 2 4 2 4 6 2 6 4 6 6 6 2 6 4 2 6 4 6 8 4 2 4 6 8 6 10 2 4 6 2 6 6 4 2 4 6 2 6 4 2 6 10 2 10 2 4 2 4 6 8 4 2 4 12 2 6 4 2 6 4 6 12 2 4 2 4 8 6 4 6 2 4 6 2 6 10 2 4 6 2 6 4 2 4 2 10 2 10 2 4 6 6 2 6 6 4 6 6 2 6 4 2 6 4 6 8 4 2 6 4 8 6 4 6 2 4 6 8 6 4 2 10 2 6 4 2 4 2 10 2 10 2 4 2 4 8 6 4 2 4 6 6 2 6 4 8 4 6 8 4 2 4 2 4 8 6 4 6 6 6 2 6 6 4 2 4 6 2 6 4 2 4 2 10 2 10 2 6 4 6 2 6 4 2 4 6 6 8 4 2 6 10 8 4 2 4 2 4 8 10 6 2 4 8 6 6 4 2 4 6 2 6 4 6 2 10 2 10 2 4 2 4 6 2 6 4 2 4 6 6 2 6 6 6 4 6 8 4 2 4 2 4 8 6 4 8 4 6 2 6 6 4 2 4 6 8 4 2 4 2 10 2 10 2 4 2 4 6 2 10 2 4 6 8 6 4 2 6 4 6 8 4 6 2 4 8 6 4 6 2 4 6 2 6 6 4 6 6 2 6 6 4 2 10 2 10 2 4 2 4 6 2 6 4 2 10 6 2 6 4 2 6 4 6 8 4 2 4 2 12 6 4 6 2 4 6 2 12 4 2 4 8 6 4 2 4 2 10 2 10 6 2 4 6 2 6 4 2 4 6 6 2 6 4 2 10 6 8 6 4 2 4 8 6 4 6 2 4 6 2 6 6 6 4 6 2 6 4 2 4 2 10 12 2 4 2 10 2 6 4 2 4 6 6 2 10 2 6 4 14 4 2 4 2 4 8 6 4 6 2 4 6 2 6 6 4 2 4 6 2 6 4 2 4 12 2 12].
	incrementIndex := 1.
	[ n <= limit ] whileTrue: [
		(maskBit := maskBitIndex at: (n \\ 2310 + 1)) = 0 ifFalse:["not a multiple of 2,3,5,7,11"
			byteIndex := n // 2310 * 60 + (maskBit-1 bitShift: -3) + 1.
			bitIndex := 1 bitShift: (maskBit bitAnd: 7).
			((flags at: byteIndex) bitAnd: bitIndex) = 0 ifFalse:["not marked -- n is prime"
				aBlock value: n.
				"Start with n*n since any integer < n has already been sieved 
				(e.g., any multiple of n with a number k < n has been cleared 
				when k was sieved); add 2 * n to avoid even numbers and
				mark all multiples of this prime. Note: n < indexLimit below
				limits running into LargeInts -- nothing more."
				n < indexLimit ifTrue:[
					index := n * n.
					[index <= limit] whileTrue:[
						(maskBit := maskBitIndex at: (index \\ 2310 + 1)) = 0 ifFalse:[
							byteIndex := (index // 2310 * 60) + (maskBit-1 bitShift: -3) + 1.
							maskBit := 255 - (1 bitShift: (maskBit bitAnd: 7)).
							flags at: byteIndex put: ((flags at: byteIndex) bitAnd: maskBit).
						].
						index := index + n + n ].
				].
			].
		].
		n := n + (increments at: incrementIndex).
		incrementIndex := incrementIndex + 1.
		incrementIndex > increments size ifTrue: [ incrementIndex := 1 ] ]
]

{ #category : #'class initialization' }
Integer class >> lowBitPerByteTable [
	
	^LowBitPerByteTable
]

{ #category : #'instance creation' }
Integer class >> new [

	self == Integer ifTrue: [
		^ self error: 'Integer is an abstract class.  Make a concrete subclass.'].
	^ super new
]

{ #category : #'instance creation' }
Integer class >> new: length neg: neg [
	"Answer an instance of a large integer whose size is length. neg is a flag 
	determining whether the integer is negative or not."

	neg 
		ifTrue: [^LargeNegativeInteger new: length]
		ifFalse: [^LargePositiveInteger new: length]
]

{ #category : #'prime numbers' }
Integer class >> primesUpTo: max [
	"Return a list of prime integers up to the given integer."
	"Integer primesUpTo: 100"
	^Array streamContents:[:s| self primesUpTo: max do:[:prime| s nextPut: prime]]
]

{ #category : #'prime numbers' }
Integer class >> primesUpTo: max do: aBlock [
	"Compute aBlock with all prime integers up to the given integer."
	"Integer primesUpTo: 100"

	| index sieve increment limit limitSqrtFloor |
	limit := max asInteger.
	"Fall back into #largePrimesUpTo:do: if we'd require more than 100k of memory; 
	the alternative will only requre 2/77th of the amount we need here and is almost as fast."
	limit <= 100000 ifFalse: [ ^self largePrimesUpTo: limit do: aBlock ].
	limit := limit - 1. "upTo:"
	limit <= 1 ifTrue: [ ^self ].
	aBlock value: 2.
	limit <= 2 ifTrue: [ ^self ].
	aBlock value: 3.
	sieve := ByteArray new: limit withAll: 1. "1 = prime, 0 = not prime"
	sieve at: 1 put: 0.
	"Filter multiples of 2."
	index := 4.
	[ index <= limit ] whileTrue: [
		sieve at: index put: 0.
		index := index + 2 ].
	"Filter multiples of 3."
	index := 9.
	[ index <= limit ] whileTrue: [
		sieve at: index put: 0.
		index := index + 3 ].
	"Filter the rest of the primes."
	limitSqrtFloor := limit sqrtFloor.
	index := 5.
	increment := 2.
	[ index <= limitSqrtFloor ] whileTrue: [
		(sieve at: index) = 1 ifTrue: [
			| originalIndex originalIncrement |
			aBlock value: index.
			originalIndex := index.
			originalIncrement := increment.
			increment := index + index.
			index := index * index.
			[ index <= limit ] whileTrue: [
				sieve at: index put: 0.
				index := index + increment ].
			index := originalIndex.
			increment := originalIncrement ].
		index := index + increment.
		increment := 6 - increment ].
	"No more new primes here."
	[ index <= limit ] whileTrue: [
		(sieve at: index) = 1 ifTrue: [
			aBlock value: index ].
		index := index + increment.
		increment := 6 - increment ]
]

{ #category : #'instance creation' }
Integer class >> readFrom: aStringOrStream [ 
	"Answer a new Integer as described on the stream, aStream.
	Embedded radix specifiers not allowed - use Number readFrom: for that."
	^self readFrom: aStringOrStream base: 10
]

{ #category : #'instance creation' }
Integer class >> readFrom: aStringOrStream base: base [ 
	"Answer an instance of one of the concrete subclasses if Integer. 
	Initial plus or minus sign accepted, and bases > 10 use letters A-Z.
	Imbedded radix specifiers not allowed;  use Number class readFrom: for that.
	Raise an Error if there are no digits."

	^(ExtendedNumberParser on: aStringOrStream) nextIntegerBase: base
]

{ #category : #'instance creation' }
Integer class >> readFrom: aStringOrStream ifFail: aBlock [
	"Answer an instance of one of the concrete subclasses if Integer. 
	Initial plus or minus sign accepted.
	Imbedded radix specifiers not allowed;  use Number class readFrom: for that.
	Execute aBlock if there are no digits."

	^(ExtendedNumberParser on: aStringOrStream) nextIntegerBase: 10 ifFail: aBlock
]

{ #category : #compatibility }
Integer class >> readFrom: aStream radix: radix [
	^self readFrom: aStream base: radix
]

{ #category : #'prime numbers' }
Integer class >> verbosePrimesUpTo: max [
	"Integer verbosePrimesUpTo: SmallInteger maxVal" "<- heh, heh"
	"Compute primes up to max, but be verbose about it"
	^Array streamContents:[:s| self verbosePrimesUpTo: max do:[:prime| s nextPut: prime]].
]

{ #category : #'prime numbers' }
Integer class >> verbosePrimesUpTo: max do: aBlock [
	"Integer verbosePrimesUpTo: SmallInteger maxVal" "<- heh, heh"
	"Compute primes up to max, but be verbose about it"
	| lastTime |
	lastTime := Time millisecondClockValue.
	UIManager default informUserDuring:[:bar|
		bar value:'Computing primes...'.
		self primesUpTo: max do:[:prime| | nowTime |
			aBlock value: prime.
			nowTime := Time millisecondClockValue.
			(nowTime - lastTime > 1000) ifTrue:[
				lastTime := nowTime.
				bar value:'Last prime found: ', prime printString]]].
]

{ #category : #arithmetic }
Integer >> * aNumber [
	"Refer to the comment in Number * " 
	aNumber isInteger ifTrue:
		[^ self multiplyByInteger: aNumber].
	^ aNumber adaptToInteger: self andSend: #*
]

{ #category : #arithmetic }
Integer >> + aNumber [
	"Refer to the comment in Number + "
	aNumber isInteger ifTrue:
		[self negative == aNumber negative
			ifTrue: [^ (self digitAdd: aNumber) normalize]
			ifFalse: [^ self digitSubtract: aNumber]].
	aNumber isFraction ifTrue:
		[^Fraction numerator: self * aNumber denominator + aNumber numerator denominator: aNumber denominator].
	^ aNumber adaptToInteger: self andSend: #+
]

{ #category : #arithmetic }
Integer >> - aNumber [
	"Refer to the comment in Number - "
	aNumber isInteger ifTrue:
		[self negative == aNumber negative
			ifTrue: [^ self digitSubtract: aNumber]
			ifFalse: [^ (self digitAdd: aNumber) normalize]].
	aNumber isFraction ifTrue:
		[^Fraction numerator: self * aNumber denominator - aNumber numerator denominator: aNumber denominator].
	^ aNumber adaptToInteger: self andSend: #-
]

{ #category : #arithmetic }
Integer >> / aNumber [
	"Refer to the comment in Number / "
	| quoRem |
	aNumber isInteger ifTrue:
		[quoRem := self divideByInteger: aNumber.
		(quoRem at: 2) = 0
			ifTrue: [^ (quoRem at: 1) normalize]
			ifFalse: [^ (Fraction numerator: self denominator: aNumber) reduced]].
	^ aNumber adaptToInteger: self andSend: #/
]

{ #category : #arithmetic }
Integer >> // aNumber [ 
	| q |
	#Numeric.
	"Changed 200/01/19 For ANSI support."
	aNumber = 0 ifTrue: [^ (ZeroDivide dividend: self) signal"<- Chg"].
	self = 0 ifTrue: [^ 0].
	q := self quo: aNumber.
	"Refer to the comment in Number|//."
	(q negative
		ifTrue: [q * aNumber ~= self]
		ifFalse: [q = 0 and: [self negative ~= aNumber negative]])
		ifTrue: [^ q - 1"Truncate towards minus infinity."]
		ifFalse: [^ q]
]

{ #category : #comparing }
Integer >> < aNumber [
	aNumber isInteger ifTrue:
		[self negative == aNumber negative
			ifTrue: [self negative
						ifTrue: [^ (self digitCompare: aNumber) > 0]
						ifFalse: [^ (self digitCompare: aNumber) < 0]]
			ifFalse: [^ self negative]].
	^ aNumber adaptToInteger: self andCompare: #<
]

{ #category : #'bit manipulation' }
Integer >> << shiftAmount [  "left shift"
	shiftAmount < 0 ifTrue: [self error: 'negative arg'].
	^ self bitShift: shiftAmount
]

{ #category : #comparing }
Integer >> <= aNumber [
	aNumber isInteger ifTrue:
		[self negative == aNumber negative
			ifTrue: [self negative
						ifTrue: [^ (self digitCompare: aNumber) >= 0]
						ifFalse: [^ (self digitCompare: aNumber) <= 0]]
			ifFalse: [^ self negative]].
	^ aNumber adaptToInteger: self andCompare: #<=
]

{ #category : #comparing }
Integer >> = aNumber [

	aNumber class == self class ifTrue: [ ^(self digitCompare: aNumber) = 0 ].
	aNumber isInteger ifTrue: [ ^false ].
	aNumber isNumber ifFalse: [ ^false ].
	^aNumber adaptToInteger: self andCompare: #=
]

{ #category : #comparing }
Integer >> > aNumber [
	aNumber isInteger ifTrue:
		[self negative == aNumber negative
			ifTrue: [self negative
						ifTrue: [^(self digitCompare: aNumber) < 0]
						ifFalse: [^(self digitCompare: aNumber) > 0]]
			ifFalse: [^ aNumber negative]].
	^ aNumber adaptToInteger: self andCompare: #>
]

{ #category : #comparing }
Integer >> >= aNumber [
	aNumber isInteger ifTrue:
		[self negative == aNumber negative
			ifTrue: [self negative
						ifTrue: [^(self digitCompare: aNumber) <= 0]
						ifFalse: [^(self digitCompare: aNumber) >= 0]]
			ifFalse: [^ aNumber negative]].
	^ aNumber adaptToInteger: self andCompare: #>=
]

{ #category : #'bit manipulation' }
Integer >> >> shiftAmount [  "right shift"
	shiftAmount < 0 ifTrue: [self error: 'negative arg'].
	^ self bitShift: 0 - shiftAmount
]

{ #category : #arithmetic }
Integer >> \\\ anInteger [ 
	"A modulo method former used in DSA."
	
	"Notes: this method used to be a faster than \\ for LargeIntegers, but this advantage is fainting:
	- it always was slower for SmallInteger because of the indirection below
	- a new LargeInteger primitive makes \\ faster up to 64 bits operands
	- even above 64 bits, its advantage has become marginal thanks to revised \\ primitive fallback code
	Moreover, \\\ behaviour is questionable for these reasons:
	- for a negative receiver xor argument, it behaves like rem: for LargeInteger and \\ for SmallInteger
	- it may answer a not normalized LargeInteger (with leading null digits) which breaks some invariants
	For example, check (SmallInteger maxVal + 1 \\\ 8) isZero.
	So beware if you ever think using this method."

	^self \\ anInteger
]

{ #category : #converting }
Integer >> adaptToScaledDecimal: receiverScaledDecimal andSend: arithmeticOpSelector [ 
	"Convert me to a ScaledDecimal and do the arithmetic. 
	receiverScaledDecimal arithmeticOpSelector self."
	#Numeric.
	"add 200/01/19 For ScaledDecimal support."
	^ receiverScaledDecimal perform: arithmeticOpSelector with: (self asScaledDecimal: 0)
]

{ #category : #arithmetic }
Integer >> alignedTo: anInteger [
	"Answer the smallest number not less than receiver that is a multiple of anInteger."

	^(self+anInteger-1//anInteger)*anInteger

"5 alignedTo: 2"
"12 alignedTo: 3"
]

{ #category : #'bit manipulation' }
Integer >> allMask: mask [ 
	"Treat the argument as a bit mask. Answer whether all of the bits that 
	are 1 in the argument are 1 in the receiver."

	^mask = (self bitAnd: mask)
]

{ #category : #'bit manipulation' }
Integer >> anyBitOfMagnitudeFrom: start to: stopArg [ 
	"Tests for any magnitude bits in the interval from start to stopArg."
	"Primitive fixed in LargeIntegers v1.2. If you have an earlier version 
	comment out the primitive call (using this ST method then)."
	| magnitude firstDigitIx lastDigitIx rightShift leftShift stop |
	<primitive: 'primAnyBitFromTo' module:'LargeIntegers'>
	start < 1 | (stopArg < 1)
		ifTrue: [^ self error: 'out of range'].
	magnitude := self abs.
	stop := stopArg min: magnitude highBit.
	start > stop
		ifTrue: [^ false].
	firstDigitIx := start - 1 // 8 + 1.
	lastDigitIx := stop - 1 // 8 + 1.
	rightShift := (start - 1 \\ 8) negated.
	leftShift := 7 - (stop - 1 \\ 8).
	firstDigitIx = lastDigitIx
		ifTrue: [| digit mask | 
			mask := (255 bitShift: rightShift negated)
						bitAnd: (255 bitShift: leftShift negated).
			digit := magnitude digitAt: firstDigitIx.
			^ (digit bitAnd: mask)
				~= 0].
	((magnitude digitAt: firstDigitIx)
			bitShift: rightShift)
			~= 0
		ifTrue: [^ true].
	firstDigitIx + 1
		to: lastDigitIx - 1
		do: [:ix | (magnitude digitAt: ix)
					~= 0
				ifTrue: [^ true]].
	(((magnitude digitAt: lastDigitIx)
			bitShift: leftShift)
			bitAnd: 255)
			~= 0
		ifTrue: [^ true].
	^ false
]

{ #category : #'bit manipulation' }
Integer >> anyMask: mask [ 
	"Treat the argument as a bit mask. Answer whether any of the bits that 
	are 1 in the argument are 1 in the receiver."

	^0 ~= (self bitAnd: mask)
]

{ #category : #converting }
Integer >> asCharacter [
	"Answer the Character whose value is the receiver."
	^Character value: self
]

{ #category : #converting }
Integer >> asFloat [
	"Answer a Float that best approximates the value of the receiver."
	
	self subclassResponsibility
]

{ #category : #converting }
Integer >> asFraction [
	"Answer a Fraction that represents the value of the receiver.
	Since an Integer already behaves as a special kind of Fraction, no conversion is required, see #isFraction."

	^self
]

{ #category : #converting }
Integer >> asHexDigit [
	^'0123456789ABCDEF' at: self+1
]

{ #category : #converting }
Integer >> asInteger [
	"Answer with the receiver itself."

	^self


]

{ #category : #'truncation and round off' }
Integer >> asLargerPowerOfTwo [
	"Convert the receiver into a power of two which is not less than the receiver"
	self isPowerOfTwo
		ifTrue:[^self]
		ifFalse:[^1 bitShift: (self highBit)]
]

{ #category : #'truncation and round off' }
Integer >> asPowerOfTwo [
	"Convert the receiver into a power of two"
	^self asSmallerPowerOfTwo
]

{ #category : #tiles }
Integer >> asPrecedenceName [

	^#('unary' 'binary' 'keyword') at: self

]

{ #category : #converting }
Integer >> asScaledDecimal [
	"The number of significant digits of the answer is the same as the number of decimal digits in the receiver."
	^ ScaledDecimal newFromNumber: self scale: 0
]

{ #category : #'truncation and round off' }
Integer >> asSmallerPowerOfTwo [
	"Convert the receiver into a power of two which is not larger than the receiver"
	self isPowerOfTwo
		ifTrue:[^self]
		ifFalse:[^1 bitShift: (self highBit - 1)]
]

{ #category : #printing }
Integer >> asStringWithCommas [
	"123456789 asStringWithCommas"
	"-123456789 asStringWithCommas"
	^ self asStringWithCommasSigned: false
]

{ #category : #printing }
Integer >> asStringWithCommasSigned: aBoolean [
	"123456789 asStringWithCommasSigned: true"
	"-123456789 asStringWithCommasSigned: false"
	| digits |
	digits := self abs printString.
	^ String streamContents:
		[:strm | 
		self sign = -1 ifTrue: [strm nextPut: $-] ifFalse: [aBoolean ifTrue: [strm nextPut: $+]].
		1 to: digits size do: 
			[:i | strm nextPut: (digits at: i).
			(i < digits size and: [(i - digits size) \\ 3 = 0])
				ifTrue: [strm nextPut: $,]]]
]

{ #category : #printing }
Integer >> asTwoCharacterString [
	"Answer a two-character string representing the receiver, with leading zero if required.  Intended for use with integers in the range 0 to 99, but plausible replies given for other values too"

	^ (self >= 0 and: [self < 10])
		ifTrue:	['0', self printString]
		ifFalse:	[self printString copyFrom: 1 to: 2]


"
2 asTwoCharacterString
11 asTwoCharacterString
1943 asTwoCharacterString
0 asTwoCharacterString
-2 asTwoCharacterString
-234 asTwoCharacterString
"
]

{ #category : #printing }
Integer >> asWords [
	"SmallInteger maxVal asWords"
	| mils minus three num answer milCount |
	self = 0 ifTrue: [^'zero'].
	mils := #('' ' thousand' ' million' ' billion' ' trillion' ' quadrillion' ' quintillion' ' sextillion' ' septillion' ' octillion' ' nonillion' ' decillion' ' undecillion' ' duodecillion' ' tredecillion' ' quattuordecillion' ' quindecillion' ' sexdecillion' ' septendecillion' ' octodecillion' ' novemdecillion' ' vigintillion').
	num := self.
	minus := ''.
	self < 0 ifTrue: [
		minus := 'negative '.
		num := num negated.
	].
	answer := String new.
	milCount := 1.
	[num > 0] whileTrue: [
		three := (num \\ 1000) threeDigitName.
		num := num // 1000.
		three isEmpty ifFalse: [
			answer isEmpty ifFalse: [
				answer := ', ',answer
			].
			answer := three,(mils at: milCount),answer.
		].
		milCount := milCount + 1.
	].
	^minus,answer
]

{ #category : #'truncation and round off' }
Integer >> atRandom [
	"Answer a random integer from 1 to self.  This implementation uses the process-local random number generator."

	self isZero ifTrue: [ ^0 ].
	self negative ifTrue: [ ^self negated atRandom negated ].
	^self atRandom: ThreadSafeRandom value
]

{ #category : #'truncation and round off' }
Integer >> atRandom: aGenerator [
	"Answer a random integer from 1 to self picked from aGenerator."

	^ aGenerator nextInt: self
]

{ #category : #benchmarks }
Integer >> benchFib [  "Handy send-heavy benchmark"
	"(result // seconds to run) = approx calls per second"
	" | r t |
	  t := Time millisecondsToRun: [r := 26 benchFib].
	  (r * 1000) // t"
	"138000 on a Mac 8100/100"
	^ self < 2
		ifTrue: [1] 
		ifFalse: [(self-1) benchFib + (self-2) benchFib + 1]

]

{ #category : #benchmarks }
Integer >> benchmark [  "Handy bytecode-heavy benchmark"
	"(500000 // time to run) = approx bytecodes per second"
	"5000000 // (Time millisecondsToRun: [10 benchmark]) * 1000"
	"3059000 on a Mac 8100/100"
    | size flags prime k count |
    size := 8190.
    1 to: self do:
        [:iter |
        count := 0.
        flags := (Array new: size) atAllPut: true.
        1 to: size do:
            [:i | (flags at: i) ifTrue:
                [prime := i+1.
                k := i + prime.
                [k <= size] whileTrue:
                    [flags at: k put: false.
                    k := k + prime].
                count := count + 1]]].
    ^ count
]

{ #category : #'bit manipulation' }
Integer >> bitAnd: n [ 
	"Answer an Integer whose bits are the logical AND of the receiver's bits  
	and those of the argument, n."
	| norm |
	<primitive: 'primDigitBitAnd' module:'LargeIntegers'>
	norm := n normalize.
	^ self
		digitLogic: norm
		op: #bitAnd:
		length: (self digitLength max: norm digitLength)
]

{ #category : #'bit manipulation' }
Integer >> bitAt: anInteger [
	"Answer 1 if the bit at position anInteger is set to 1, 0 otherwise.
	self is considered an infinite sequence of bits, so anInteger can be any strictly positive integer.
	Bit at position 1 is the least significant bit.
	Negative numbers are in two-complements.
	
	This is a naive implementation that can be refined in subclass for speed"
	
	^(self bitShift: 1 - anInteger) bitAnd: 1
]

{ #category : #'bit manipulation' }
Integer >> bitAt: anInteger put: value [
	"Answer a new Integer that has the bit of rank anInteger set to value.
	The bit value should be 0 or 1, otherwise raise an Error.
	The bits are indexed starting at 1 for the least significant bit.
	For negative integers, operate on 2-complement representation."
	
	| b |
	b := self bitAt: anInteger.
	b = value ifTrue: [^self].
	0 = value ifTrue: [^self bitAnd: (1 bitShift: anInteger - 1) bitInvert].
	1 = value ifTrue: [^self bitOr: (1 bitShift: anInteger - 1)].
	self error: 'bit value should be 0 or 1'
]

{ #category : #'bit manipulation' }
Integer >> bitClear: aMask [ 
	"Answer an Integer equal to the receiver, except with all bits cleared that are set in aMask."

	^ (self bitOr: aMask) - aMask
]

{ #category : #'bit manipulation' }
Integer >> bitCount [
	"Count the number of bits set to 1 in self"

	| bitCount |
	self < 0 ifTrue: [self error: 'Cannot count bits of negative integers'].
	bitCount := 0.
	1 to: self digitLength do: [:i |
		bitCount := bitCount + (BitCountPerByteTable at: (self digitAt: i) + 1) ].
	^bitCount
]

{ #category : #'bit manipulation' }
Integer >> bitInvert [
	"Answer an Integer whose bits are the logical negation of the receiver's bits.
	Numbers are interpreted as having 2's-complement representation."

	^ -1 - self
]

{ #category : #'bit manipulation' }
Integer >> bitInvert32 [
	"Answer the 32-bit complement of the receiver."

	^ self bitXor: 16rFFFFFFFF
]

{ #category : #'bit manipulation' }
Integer >> bitOr: n [ 
	"Answer an Integer whose bits are the logical OR of the receiver's bits  
	and those of the argument, n."
	| norm |
	<primitive: 'primDigitBitOr' module:'LargeIntegers'>
	norm := n normalize.
	^ self
		digitLogic: norm
		op: #bitOr:
		length: (self digitLength max: norm digitLength)
]

{ #category : #'bit manipulation' }
Integer >> bitReverse: highBit [ 
	"Reverse the bits of the receiver so that the lsb is the highBit'th bit of the answer.  Translated from C code at:  http://graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious."
	| v r s |
	highBit < self highBit ifTrue: [ self error: 'Not enough bits.' ].
	v := self.
	r := v bitAnd: 1.
	s := highBit - 1.
	[ v := v bitShift: -1.
	v = 0 ] whileFalse:
		[ r := r bitShift: 1.
		r := r bitOr: (v bitAnd: 1).
		s := s - 1 ].
	^ r bitShift: s
]

{ #category : #'bit manipulation' }
Integer >> bitShift: shiftCount [ 
	"Answer an Integer whose value (in twos-complement representation) is  
	the receiver's value (in twos-complement representation) shifted left by 
	the number of bits indicated by the argument. Negative arguments  
	shift right. Zeros are shifted in from the right in left shifts."
	| magnitudeShift |
	magnitudeShift := self bitShiftMagnitude: shiftCount.
	^ ((self negative and: [shiftCount negative])
		and: [self anyBitOfMagnitudeFrom: 1 to: shiftCount negated])
		ifTrue: [magnitudeShift - 1]
		ifFalse: [magnitudeShift]
]

{ #category : #'bit manipulation' }
Integer >> bitShiftMagnitude: shiftCount [ 
	"Answer an Integer whose value (in magnitude representation) is  
	the receiver's value (in magnitude representation) shifted left by  
	the number of bits indicated by the argument. Negative arguments
	shift right. Zeros are shifted in from the right in left shifts."
	| rShift |
	<primitive: 'primDigitBitShiftMagnitude' module:'LargeIntegers'>
	shiftCount >= 0 ifTrue: [^ self digitLshift: shiftCount].
	rShift := 0 - shiftCount.
	^ (self
		digitRshift: (rShift bitAnd: 7)
		bytes: (rShift bitShift: -3)
		lookfirst: self digitLength) normalize
]

{ #category : #'bit manipulation' }
Integer >> bitXor: n [ 
	"Answer an Integer whose bits are the logical XOR of the receiver's bits  
	and those of the argument, n."
	| norm |
	<primitive: 'primDigitBitXor' module:'LargeIntegers'>
	norm := n normalize.
	^ self
		digitLogic: norm
		op: #bitXor:
		length: (self digitLength max: norm digitLength)
]

{ #category : #'printing-numerative' }
Integer >> byteEncode: aStream base: base [
	^self printOn: aStream base: base	
]

{ #category : #'truncation and round off' }
Integer >> ceiling [ 
	"Refer to the comment in Number|ceiling."
]

{ #category : #private }
Integer >> copyto: x [
	| stop |
	stop := self digitLength min: x digitLength.
	^ x replaceFrom: 1 to: stop with: self startingAt: 1
]

{ #category : #arithmetic }
Integer >> crossSumBase: aBase [
	|aResult|
	"Precondition"
	self assert:[aBase isInteger and: [aBase >=2]].

	self < 0 ifTrue: [^self negated crossSumBase: aBase].
	self < aBase ifTrue: [^ self].
	aResult := self \\ aBase + (self // aBase crossSumBase: aBase).

	"Postcondition
	E.g. 18 crossSumBase: 10 -> 9 => 18\\(10-1) = 0"
	self assert: [((aResult \\ (aBase - 1) = 0)) = ((self \\ (aBase - 1)) =0)].
	^aResult
]

{ #category : #accessing }
Integer >> denominator [
	"Let an Integer be polymorphic to a Fraction. See #isFraction."
	^1
]

{ #category : #private }
Integer >> digitAdd: arg [ 
	| len arglen accum sum |
	<primitive: 'primDigitAdd' module:'LargeIntegers'>
	accum := 0.
	(len := self digitLength) < (arglen := arg digitLength) ifTrue: [len := arglen].
	"Open code max: for speed"
	sum := Integer new: len neg: self negative.
	1 to: len do: 
		[:i | 
		accum := (accum bitShift: -8)
					+ (self digitAt: i) + (arg digitAt: i).
		sum digitAt: i put: (accum bitAnd: 255)].
	accum > 255
		ifTrue: 
			[sum := sum growby: 1.
			sum at: sum digitLength put: (accum bitShift: -8)].
	^ sum
]

{ #category : #printing }
Integer >> digitBuffer:digitLength [
  ^Array new:digitLength*8.
]

{ #category : #private }
Integer >> digitCompare: arg [ 
	"Compare the magnitude of self with that of arg.   
	Return a code of 1, 0, -1 for self >, = , < arg"
	| len arglen argDigit selfDigit |
	<primitive: 'primDigitCompare' module:'LargeIntegers'>
	len := self digitLength.
	(arglen := arg digitLength) ~= len
		ifTrue: [arglen > len
				ifTrue: [^ -1]
				ifFalse: [^ 1]].
	[len > 0]
		whileTrue: 
			[(argDigit := arg digitAt: len) ~= (selfDigit := self digitAt: len)
				ifTrue: [argDigit < selfDigit
						ifTrue: [^ 1]
						ifFalse: [^ -1]].
			len := len - 1].
	^ 0
]

{ #category : #private }
Integer >> digitDiv21: anInteger [
	
	^(self digitDiv: anInteger neg: false) collect: #normalize
]

{ #category : #private }
Integer >> digitDiv32: anInteger [
	
	^(self digitDiv: anInteger neg: false) collect: #normalize
]

{ #category : #private }
Integer >> digitDiv: arg neg: ng [ 
	"Answer with an array of (quotient, remainder)."
	| quo rem ql d div dh dnh dl qhi qlo j l hi lo r3 a t divDigitLength remDigitLength |
	<primitive: 'primDigitDivNegative' module:'LargeIntegers'>
	arg = 0 ifTrue: [^ (ZeroDivide dividend: self) signal].
	"TFEI added this line"
	l := self digitLength - arg digitLength + 1.
	l <= 0 ifTrue: [^ Array with: 0 with: self].
	"shortcut against #highBit"
	d := 8 - arg lastDigit highBitOfByte.
	div := arg digitLshift: d.
	divDigitLength := div digitLength + 1.
	div := div growto: divDigitLength.
	"shifts so high order word is >=128"
	rem := self digitLshift: d.
	rem digitLength = self digitLength ifTrue: [rem := rem growto: self digitLength + 1].
	remDigitLength := rem digitLength.
	"makes a copy and shifts"
	quo := Integer new: l neg: ng.
	dl := divDigitLength - 1.
	"Last actual byte of data"
	ql := l.
	dh := div digitAt: dl.
	dnh := dl = 1
				ifTrue: [0]
				ifFalse: [div digitAt: dl - 1].
	1 to: ql do: 
		[:k | 
		"maintain quo*arg+rem=self"
		"Estimate rem/div by dividing the leading to bytes of rem by dh."
		"The estimate is q = qhi*16+qlo, where qhi and qlo are nibbles."
		j := remDigitLength + 1 - k.
		"r1 := rem digitAt: j."
		(rem digitAt: j)
			= dh
			ifTrue: [qhi := qlo := 15
				"i.e. q=255"]
			ifFalse: 
				["Compute q = (r1,r2)//dh, t = (r1,r2)\\dh.  
				Note that r1,r2 are bytes, not nibbles.  
				Be careful not to generate intermediate results exceeding 13  
				bits."
				"r2 := (rem digitAt: j - 1)."
				t := ((rem digitAt: j)
							bitShift: 4)
							+ ((rem digitAt: j - 1)
									bitShift: -4).
				qhi := t // dh.
				t := (t \\ dh bitShift: 4)
							+ ((rem digitAt: j - 1)
									bitAnd: 15).
				qlo := t // dh.
				t := t \\ dh.
				"Next compute (hi,lo) := q*dnh"
				hi := qhi * dnh.
				lo := qlo * dnh + ((hi bitAnd: 15)
								bitShift: 4).
				hi := (hi bitShift: -4)
							+ (lo bitShift: -8).
				lo := lo bitAnd: 255.
				"Correct overestimate of q.  
				Max of 2 iterations through loop -- see Knuth vol. 2"
				r3 := j < 3
							ifTrue: [0]
							ifFalse: [rem digitAt: j - 2].
				[(t < hi
					or: [t = hi and: [r3 < lo]])
					and: 
						["i.e. (t,r3) < (hi,lo)"
						qlo := qlo - 1.
						lo := lo - dnh.
						lo < 0
							ifTrue: 
								[hi := hi - 1.
								lo := lo + 256].
						hi >= dh]]
					whileTrue: [hi := hi - dh].
				qlo < 0
					ifTrue: 
						[qhi := qhi - 1.
						qlo := qlo + 16]].
		"Subtract q*div from rem"
		l := j - dl.
		a := 0.
		1 to: divDigitLength do: 
			[:i | 
			hi := (div digitAt: i)
						* qhi.
			lo := a + (rem digitAt: l) - ((hi bitAnd: 15)
							bitShift: 4) - ((div digitAt: i)
							* qlo).
			rem digitAt: l put: lo - (lo // 256 * 256).
			"sign-tolerant form of (lo bitAnd: 255)"
			a := lo // 256 - (hi bitShift: -4).
			l := l + 1].
		a < 0
			ifTrue: 
				["Add div back into rem, decrease q by 1"
				qlo := qlo - 1.
				l := j - dl.
				a := 0.
				1 to: divDigitLength do: 
					[:i | 
					a := (a bitShift: -8)
								+ (rem digitAt: l) + (div digitAt: i).
					rem digitAt: l put: (a bitAnd: 255).
					l := l + 1]].
		quo digitAt: ql + 1 - k put: (qhi bitShift: 4)
				+ qlo].
	rem := rem
				digitRshift: d
				bytes: 0
				lookfirst: dl.
	^ Array with: quo with: rem
]

{ #category : #private }
Integer >> digitLogic: arg op: op length: len [ 
	| i result neg1 neg2 rneg z1 z2 rz b1 b2 b |
	neg1 := self negative.
	neg2 := arg negative.
	rneg := ((neg1
				ifTrue: [-1]
				ifFalse: [0])
				perform: op
				with: (neg2
						ifTrue: [-1]
						ifFalse: [0]))
				< 0.
	result := Integer new: len neg: rneg.
	rz := z1 := z2 := true.
	i := 0.
	[(i := i + 1) <= len
		or: ["mind a carry on result that might go past len digits"
			rneg and: [rz
				and: [result := result growby: 1.
					true]]]]
		whileTrue: [b1 := self digitAt: i.
			neg1
				ifTrue: [b1 := z1
								ifTrue: [b1 = 0
										ifTrue: [0]
										ifFalse: [z1 := false.
											256 - b1]]
								ifFalse: [255 - b1]].
			b2 := arg digitAt: i.
			neg2
				ifTrue: [b2 := z2
								ifTrue: [b2 = 0
										ifTrue: [0]
										ifFalse: [z2 := false.
											256 - b2]]
								ifFalse: [255 - b2]].
			b := b1 perform: op with: b2.
			result
				digitAt: i
				put: (rneg
						ifTrue: [rz
								ifTrue: [b = 0
										ifTrue: [0]
										ifFalse: [rz := false.
											256 - b]]
								ifFalse: [255 - b]]
						ifFalse: [b])].
	^ result normalize
]

{ #category : #private }
Integer >> digitLshift: shiftCount [ 
	| carry rShift mask len result digit byteShift bitShift highBit |
	(highBit := self highBitOfMagnitude) = 0 ifTrue: [^ 0].
	len := highBit + shiftCount + 7 // 8.
	result := Integer new: len neg: self negative.
	byteShift := shiftCount // 8.
	bitShift := shiftCount \\ 8.
	bitShift = 0 ifTrue: ["Fast version for byte-aligned shifts"
		^ result
			replaceFrom: byteShift + 1
			to: len
			with: self
			startingAt: 1].
	carry := 0.
	rShift := bitShift - 8.
	mask := 255 bitShift: 0 - bitShift.
	1 to: byteShift do: [:i | result digitAt: i put: 0].
	1 to: len - byteShift do: 
		[:i | 
		digit := self digitAt: i.
		result digitAt: i + byteShift put: (((digit bitAnd: mask)
				bitShift: bitShift)
				bitOr: carry).
		carry := digit bitShift: rShift].
	^ result
]

{ #category : #private }
Integer >> digitMultiply: arg neg: ng [ 
	| selfLen argLen prod prodLen carry digit k ab |
	<primitive: 'primDigitMultiplyNegative' module:'LargeIntegers'>
	argLen := arg digitLength.
	(argLen = 1 and: [(arg digitAt: 1)
			= 0])
		ifTrue: [^ 0].
	selfLen := self digitLength.
	(selfLen = 1 and: [(self digitAt: 1)
			= 0])
		ifTrue: [^ 0].
	prodLen := selfLen + argLen.
	prod := Integer new: prodLen neg: ng.
	"prod starts out all zero"
	1 to: selfLen do: [:i | (digit := self digitAt: i) ~= 0
			ifTrue: 
				[k := i.
				carry := 0.
				"Loop invariant: 0<=carry<=0377, k=i+j-1"
				1 to: argLen do: 
					[:j | 
					ab := (arg digitAt: j)
								* digit + carry + (prod digitAt: k).
					carry := ab bitShift: -8.
					prod digitAt: k put: (ab bitAnd: 255).
					k := k + 1].
				prod digitAt: k put: carry]].
	^ prod normalize
]

{ #category : #private }
Integer >> digitRshift: anInteger bytes: b lookfirst: a [ 
	 "Shift right 8*b+anInteger bits, 0<=n<8.
	Discard all digits beyond a, and all zeroes at or below a."
	| n x r f m digit count i |
	n := 0 - anInteger.
	x := 0.
	f := n + 8.
	i := a.
	m := 255 bitShift: 0 - f.
	digit := self digitAt: i.
	[((digit bitShift: n) bitOr: x) = 0 and: [i ~= 1]] whileTrue:
		[x := digit bitShift: f "Can't exceed 8 bits".
		i := i - 1.
		digit := self digitAt: i].
	i <= b ifTrue: [^Integer new: 0 neg: self negative].  "All bits lost"
	r := Integer new: i - b neg: self negative.
	count := i.
	x := (self digitAt: b + 1) bitShift: n.
	b + 1 to: count do:
		[:j | digit := self digitAt: j + 1.
		r digitAt: j - b put: (((digit bitAnd: m) bitShift: f) bitOr: x) 
			"Avoid values > 8 bits".
		x := digit bitShift: n].
	^r
]

{ #category : #private }
Integer >> digitSubtract: arg [ 
	| smaller larger z sum sl al ng |
	<primitive: 'primDigitSubtract' module:'LargeIntegers'>
	sl := self digitLength.
	al := arg digitLength.
	(sl = al
		ifTrue: 
			[[(self digitAt: sl)
				= (arg digitAt: sl) and: [sl > 1]]
				whileTrue: [sl := sl - 1].
			al := sl.
			(self digitAt: sl)
				< (arg digitAt: sl)]
		ifFalse: [sl < al])
		ifTrue: 
			[larger := arg.
			smaller := self.
			ng := self negative == false.
			sl := al]
		ifFalse: 
			[larger := self.
			smaller := arg.
			ng := self negative].
	sum := Integer new: sl neg: ng.
	z := 0.
	"Loop invariant is -1<=z<=1"
	1 to: sl do: 
		[:i | 
		z := z + (larger digitAt: i) - (smaller digitAt: i).
		sum digitAt: i put: z - (z // 256 * 256).
		"sign-tolerant form of (z bitAnd: 255)"
		z := z // 256].
	^ sum normalize
]

{ #category : #private }
Integer >> digitsAsFloat [
	"private - naive conversion method.
	This method should be used if and only if
	Float precision + 8 >= self highBit.
	This way, all floating point operations will be exact, but eventually the
	last one, giving a guaranty that result will be the nearest Float."
	| result n |
	result := (self digitAt: (n := self digitLength)) asFloat.
	[(n := n - 1) > 0]
		whileTrue: [result := 256.0 * result + (self digitAt: n) asFloat].
	^ result
]

{ #category : #private }
Integer >> divideByInteger: anInteger [
	"Answer an Array with quotient and remainder of division by anInteger.
	the quotient is always truncated toward zero, and remainder has same sign as receiver.
	Beware, the result might be un-normailzed (LargeInteger with leading zero digits)"
	^self digitDiv: anInteger 
			neg: self negative ~~ anInteger negative
]

{ #category : #testing }
Integer >> even [ 
	"Refer to the comment in Number|even."

	^((self digitAt: 1) bitAnd: 1) = 0
]

{ #category : #'mathematical functions' }
Integer >> factorial [
	"Answer the factorial of the receiver."

	self = 0 ifTrue: [^ 1].
	self > 0 ifTrue: [^ self * (self - 1) factorial].
	self error: 'Not valid for negative integers'
]

{ #category : #'truncation and round off' }
Integer >> floor [ 
	"Refer to the comment in Number|floor."
]

{ #category : #'mathematical functions' }
Integer >> floorLog: radix [
	"Unlike super, this version is exact when radix is integer"
	
	radix isInteger ifFalse: [^super floorLog: radix].
	self <= 0 ifTrue: [^DomainError signal: 'floorLog: is only defined for x > 0.0'].
	^(self numberOfDigitsInBase: radix) - 1
]

{ #category : #'truncation and round off' }
Integer >> fractionPart [
	"Added for ANSI compatibility"
	^0
]

{ #category : #'mathematical functions' }
Integer >> gcd: anInteger [
	"See Knuth, Vol 2, 4.5.2, Algorithm L"
	"Initialize"
	| higher u v k uHat vHat a b c d vPrime vPrimePrime q t |
	anInteger denominator = 1 ifFalse: [^anInteger gcd: self].
	higher := SmallInteger maxVal highBit.
	u := self abs max: (v := anInteger abs).
	v := self abs min: v.
	[v class == SmallInteger]
		whileFalse: 
			[(uHat := u bitShift: (k := higher - u highBit)) class == SmallInteger
				ifFalse: 
					[k := k - 1.
					uHat := uHat bitShift: -1].
			vHat := v bitShift: k.
			a := 1.
			b := 0.
			c := 0.
			d := 1.
			"Test quotient"
			[(vPrime := vHat + d) ~= 0
				and: [(vPrimePrime := vHat + c) ~= 0 and: [(q := uHat + a // vPrimePrime) = (uHat + b // vPrime)]]]
				whileTrue: 
					["Emulate Euclid"
					c := a - (q * (a := c)).
					d := b - (q * (b := d)).
					vHat := uHat - (q * (uHat := vHat))].
			"Multiprecision step"
			b = 0
				ifTrue: 
					[v := u rem: (u := v)]
				ifFalse: 
					[t := u * a + (v * b).
					v := u * c + (v * d).
					u := t]].
	^ v gcd: u
]

{ #category : #private }
Integer >> growby: n [

	^self growto: self digitLength + n
]

{ #category : #private }
Integer >> growto: n [

	^self copyto: (self species new: n)
]

{ #category : #printing }
Integer >> hex [
	"Print the receiver as hex, prefixed with 16r.  DO NOT CHANGE THIS!  The Cog VMMaker depends on this.
	 Consider using any of
		printStringHex
		printStringBase: 16
		printStringBase: 16 length: 8 padded: true
		storeStringHex
		storeStringBase: 16
		storeStringBase: 16 length: 11 padded: true"
	^self storeStringBase: 16
]

{ #category : #'bit manipulation' }
Integer >> highBit [
	"Answer the index of the high order bit of the receiver, or zero if the  
	receiver is zero. Raise an error if the receiver is negative, since  
	negative integers are defined to have an infinite number of leading 1's 
	in 2's-complement arithmetic. Use >>highBitOfMagnitude if you want to  
	get the highest bit of the magnitude."

	^ self subclassResponsibility
]

{ #category : #'bit manipulation' }
Integer >> highBitOfMagnitude [
	"Answer the index of the high order bit of the magnitude of the  
	receiver, or zero if the receiver is zero."
	^ self subclassResponsibility
]

{ #category : #private }
Integer >> initialGuessForNthRoot: aPositiveInteger [
	"Use a simplistic scheme based solely on most significant bit"
	^1 bitShift: self highBitOfMagnitude + aPositiveInteger - 1 // aPositiveInteger
]

{ #category : #'truncation and round off' }
Integer >> integerPart [
	"Added for ANSI compatibility"
	^self
]

{ #category : #testing }
Integer >> isAnExactFloat [
	"Answer true if this Integer can be converted exactly to a Float"
	| h |
	(h := self highBitOfMagnitude) <= Float precision
		ifTrue: [^ true].
	^ h - 1 <= Float emax
		and: [(self anyBitOfMagnitudeFrom: 1 to: h - Float precision) not]
]

{ #category : #testing }
Integer >> isFraction [
	"Each Integer is considered as a special kind of Fraction with self as numerator and a unit denominator.
	Rationale: A Fraction with a unit denominator will be automatically reduced to an Integer.
	Hence Integer has to be polymorphic to Fraction."
	^true
]

{ #category : #testing }
Integer >> isInteger [
	"True for all subclasses of Integer."

	^ true
]

{ #category : #printing }
Integer >> isLiteral [

	^true
]

{ #category : #testing }
Integer >> isPowerOfTwo [
	"Return true if the receiver is an integral power of two."
	
	^self strictlyPositive and: [ (self bitAnd: self - 1) = 0 ]
]

{ #category : #testing }
Integer >> isPrime [
	"Answer true if the receiver is a prime number. See isProbablyPrime for a probabilistic
	implementation that is much faster for large integers, and that is correct to an extremely
	high statistical level of confidence (effectively deterministic)."
	
	| probe step limit |
	self <= 3 ifTrue: [ ^self >= 2 ].
	self \\ 2 = 0 ifTrue: [ ^false ].
	self \\ 3 = 0 ifTrue: [ ^false ].
	self <= 1073741823 ifFalse: [ "1 << 30 - 1. For numbers larger than this (on 64-bit platforms) #isProbablyPrime is usually quicker."
		^self isProbablyPrime ].
	probe := 5.
	step := 2. "Step will oscillate between 2 and 4 because at this point self \\ 6 is either 1 or 5."
	limit := self sqrtFloor. "On 64-bit platforms this could be written as self asFloat sqrt truncated (+ 1), which is faster because it creates no intermediate objects. Knowing that self has at most 30 bits because of the check above, this value will never be larger than 32767."
	[ probe <= limit ] whileTrue: [
		self \\ probe = 0 ifTrue: [ ^false ].
		probe := probe + step.
		step := 6 - step ].
	^true
]

{ #category : #testing }
Integer >> isProbablyPrime [
	"See isProbablyPrimeWithK:andQ: for the algoritm description."
	
	| k q |
	self <= 1 ifTrue: [ ^false ].
	self even ifTrue: [ ^self = 2 ].
	"Factor self into (2 raisedTo: k) * q + 1, where q odd"
	q := self bitShift: -1.
	k := q lowBit.
	q := q bitShift: 1 - k.
	"Repeat the probabilistic until false (the probability of false negative is null) or until probability is very low."
	25 timesRepeat: [ (self isProbablyPrimeWithK: k andQ: q) ifFalse: [ ^false ] ].
	"The probability of false positive after 25 iterations is less than (1/4 raisedTo: 25) < 1.0e-15"
	^true
]

{ #category : #private }
Integer >> isProbablyPrimeWithK: k andQ: q [ 
	"Algorithm P, probabilistic primality test, from
	Knuth, Donald E. 'The Art of Computer Programming', Vol 2,
	Third Edition, section 4.5.4, page 395, P1-P5 refer to Knuth description..
	Note that this is a Miller Rabin test which may answer false positives (known as pseudoprimes) for at most 1/4 of the possible bases x."

	| x j y minusOne |
	"P1"
	x := (self - 2) atRandom + 1.
	"P2"
	j := 0.
	y := x raisedTo: q modulo: self.
	minusOne := self - 1.
	
	["P3"
	y = 1 ifTrue: [^j = 0].
	y = minusOne ifTrue: [^true].
	"P4"
	(j := j + 1) < k]
		whileTrue:
			[y := y squared \\ self].
	"P5"
	^false
]

{ #category : #'system primitives' }
Integer >> lastDigit [
	"Answer the last digit of the integer base 256.  LargePositiveInteger uses bytes of base two number, and each is a 'digit'."

	^self digitAt: self digitLength
]

{ #category : #'mathematical functions' }
Integer >> lcm: n [ 
	"Answer the least common multiple of the receiver and n."

	^self // (self gcd: n) * n
]

{ #category : #'mathematical functions' }
Integer >> ln [
	self > 0 ifTrue: [^super ln].
	^DomainError signal: 'ln is only defined for x > 0'
]

{ #category : #'mathematical functions' }
Integer >> log [
	self > 0 ifTrue: [^super log].
	^DomainError signal: 'log is only defined for x > 0'
]

{ #category : #'mathematical functions' }
Integer >> log2 [
	self > 0 ifTrue: [^super log2].
	^DomainError signal: 'log2 is only defined for x > 0'
]

{ #category : #'bit manipulation' }
Integer >> lowBit [
	"Answer the index of the low order bit of this number."
	
	| index digit |
	index := 0.
	[ (digit := self digitAt: (index := index + 1)) = 0 ] whileTrue.
	^(LowBitPerByteTable at: digit) + (index - 1 * 8)
]

{ #category : #private }
Integer >> montgomeryDigitBase [
	"Answer the base used by Montgomery algorithm."
	^1 << self montgomeryDigitLength
]

{ #category : #private }
Integer >> montgomeryDigitLength [
	"Answer the number of bits composing a digit in Montgomery algorithm.
	Primitive use either 8 or 32 bits digits"
	<primitive: 'primMontgomeryDigitLength' module:'LargeIntegers'>
	^8 "Legacy plugin which did not have this primitive did use 8 bits digits"
]

{ #category : #private }
Integer >> montgomeryDigitMax [
	"Answer the maximum value of a digit used in Montgomery algorithm."
	
	^1 << self montgomeryDigitLength - 1
]

{ #category : #private }
Integer >> montgomeryNumberOfDigits [
	"Answer the number of montgomery digits required to represent the receiver."
	^self digitLength * 8 + (self montgomeryDigitLength - 1) // self montgomeryDigitLength
]

{ #category : #private }
Integer >> montgomeryRaisedTo: n times: y modulo: m mInvModB: mInv [
	"Private - do a Montgomery exponentiation of self modulo m.
	The operation is equivalent to (self/y raisedTo: n)*y \\ m,
	with y is (b raisedTo: m montgomeryNumberOfDigits),
	with (m bitAnd: b-1) * mInv \\ b = (b-1)
	with b = self montgomeryDigitBase (either 1<<8 or 1<<32)"
	
	| pow j k w index oddPowersOfSelf square |
	
	"Precompute powers of self for odd bit patterns xxxx1 up to length w + 1.
	The width w is chosen with respect to the total bit length of n,
	such that each bit pattern will on average be encoutered P times in the whole bit sequence of n.
	This costs (2 raisedTo: w) multiplications, but more will be saved later (see below)."
	k := n highBit.
	w := (k highBit - 1 >> 1 min: 16) max: 1.
	oddPowersOfSelf := Array new: 1 << w.
	oddPowersOfSelf at: 1 put: (pow := self).
	square := self montgomeryTimes: self modulo: m mInvModB: mInv.
	2 to: oddPowersOfSelf size do: [:i | pow := oddPowersOfSelf at: i put: (pow montgomeryTimes: square modulo: m mInvModB: mInv)].
	
	"Now exponentiate by searching precomputed bit patterns with a sliding window"
	pow := y.
	[k > 0]
		whileTrue:
			[pow := pow montgomeryTimes: pow modulo: m mInvModB: mInv.
			"Skip bits set to zero (the sliding window)"
			(n bitAt: k) = 0
				ifFalse:
					["Find longest odd bit pattern up to window length (w + 1)"
					j := k - w max: 1.
					[j < k and: [(n bitAt: j) = 0]] whileTrue: [j := j + 1].
					"We found a bit pattern of length k-j+1;
					perform the square powers for each bit
					(same cost as bitwise algorithm);
					compute the index of this bit pattern in the precomputed powers."
					index := 0.
					[k > j] whileTrue:
						[pow := pow montgomeryTimes: pow modulo: m mInvModB: mInv.
						index := index << 1 + (n bitAt: k).
						k := k - 1].
					"Perform a single multiplication for the whole bit pattern.
					This saves up to (k-j) multiplications versus a naive algorithm operating bit by bit"
					pow := pow montgomeryTimes: (oddPowersOfSelf at: index + 1) modulo: m mInvModB: mInv].
			k := k - 1].
	^pow
]

{ #category : #private }
Integer >> montgomeryTimes: a modulo: m mInvModB: mInv [
	"Answer the result of a Montgomery multiplication
	self * a * (b raisedTo: m montgomeryNumberOfDigits) inv \\ m
	NOTE: it is assumed that:
	self montgomeryNumberOfDigits <= m montgomeryNumberOfDigits
	a montgomeryNumberOfDigits <= m montgomeryNumberOfDigits
	mInv * m \\ b = (-1 \\ b) = (b-1) (this implies m odd)
	where b = self montgomeryDigitBase
	
	Answer nil in case of absent plugin or other failure."
	
	<primitive: 'primMontgomeryTimesModulo' module:'LargeIntegers'>
	^nil
]

{ #category : #private }
Integer >> multiplyByInteger: anInteger [
	^self digitMultiply: anInteger 
			neg: self negative ~~ anInteger negative
]

{ #category : #'bit manipulation' }
Integer >> noMask: mask [ 
	"Treat the argument as a bit mask. Answer whether none of the bits that 
	are 1 in the argument are 1 in the receiver."

	^0 = (self bitAnd: mask)
]

{ #category : #'truncation and round off' }
Integer >> normalize [ 
	"SmallInts OK; LgInts override"
	^ self
]

{ #category : #'mathematical functions' }
Integer >> nthRoot: aPositiveInteger [
	"Answer the nth root of the receiver.
	Answer an Integer if root is exactly this Integer, else answer the Float nearest the exact root."

	| guess excess scaled nBits |
	guess := self nthRootRounded: aPositiveInteger.
	excess := (guess raisedTo: aPositiveInteger) - self.
	excess = 0 ifTrue: [ ^ guess ].

	nBits := Float precision - guess highBitOfMagnitude.
	nBits <= 0 ifTrue: [ ^(Fraction numerator: guess * 4 - excess sign denominator: 4) asFloat].

	scaled := self << (nBits * aPositiveInteger).
	guess := scaled nthRootRounded: aPositiveInteger.
	excess := (guess raisedTo: aPositiveInteger) - scaled.
	^(Fraction numerator: guess * 4 - excess sign denominator: 1 << (nBits + 2)) asFloat
]

{ #category : #'mathematical functions' }
Integer >> nthRootRounded: aPositiveInteger [
	"Answer the integer nearest the nth root of the receiver."
	| guess |
	self = 0 ifTrue: [^0].
	self negative
		ifTrue:
			[aPositiveInteger even ifTrue: [ ArithmeticError signal: 'Negative numbers don''t have even roots.' ].
			^(self negated nthRootRounded: aPositiveInteger) negated].
	guess := self nthRootTruncated: aPositiveInteger.
	^(2 * guess + 1 raisedToInteger: aPositiveInteger) < (self bitShift: aPositiveInteger)
		ifTrue: [guess + 1]
		ifFalse: [guess]
]

{ #category : #'mathematical functions' }
Integer >> nthRootTruncated: n [
	"Answer the integer part of the nth root of the receiver."
	| guess guessToTheNthMinusOne nextGuess |
	self = 0 ifTrue: [^0].
	(n isInteger and: [n > 0]) ifFalse: [ ArithmeticError signal: 'nthRootTruncated: operand must be a strictly positive Integer' ].
	self negative
		ifTrue:
			[n even ifTrue: [ ArithmeticError signal: 'Negative numbers don''t have even roots.' ].
			^(self negated nthRootTruncated: n) negated].
	guess := self initialGuessForNthRoot: n.
	[
		guessToTheNthMinusOne := guess raisedToInteger: n - 1.
		nextGuess := (n - 1 * guess * guessToTheNthMinusOne + self) // (guessToTheNthMinusOne * n).
		nextGuess >= guess ] whileFalse:
			[ guess := nextGuess ].
	( guess raisedToInteger: n) > self  ifTrue:
			[ guess := guess - 1 ].
	^guess
]

{ #category : #printing }
Integer >> numberOfDigitsInBase: b [ 
	"Return how many digits are necessary to print this number in base b.
	This does not count any place for minus sign, radix prefix or whatever.
	Note that this algorithm may cost a few operations on LargeInteger."

	| nDigits q total |
	self negative ifTrue: [^self negated numberOfDigitsInBase: b].
	self < b ifTrue: [^1].
	b isPowerOfTwo ifTrue: [^self highBit + b highBit - 2 quo: b highBit - 1].
	
	"A conversion from base 2 to base b has to be performed.
	This algorithm avoids Float computations like (self log: b) floor + 1,
	1) because they are inexact
	2) because LargeInteger might overflow
	3) because this algorithm might be cheaper than conversion"

	q := self.
	total := 0.
	["Make an initial nDigits guess that is lower than or equal to required number of digits"
	nDigits := b = 10
		ifTrue: [((q highBit - 1) * 1233 >> 12) + 1. "This is because (2 log)/(10 log)*4096 is slightly greater than 1233"]
		ifFalse: [q highBit quo: b highBit].
	total := total + nDigits.
	
	"See how many digits remains above these first nDigits guess"
	(q := q quo: (b raisedToInteger: nDigits)) < b] whileFalse.
	^q = 0
		ifTrue: [total]
		ifFalse: [total + 1]
]

{ #category : #accessing }
Integer >> numerator [
	"Let an Integer be polymorphic to a Fraction. See #isFraction."
	^self
]

{ #category : #private }
Integer >> print: positiveNumberString on: aStream prefix: prefix length: minimum padded: zeroFlag [
	| padLength |
	padLength := minimum - positiveNumberString size - prefix size.
	padLength > 0
		ifTrue: [zeroFlag
				ifTrue: [aStream nextPutAll: prefix; nextPutAll: (String new: padLength withAll: $0)]
				ifFalse: [aStream nextPutAll: (String new: padLength withAll: Character space); nextPutAll: prefix]]
		ifFalse: [aStream nextPutAll: prefix].
	aStream nextPutAll: positiveNumberString
	
]

{ #category : #printing }
Integer >> printAsLiteralOn: aStream [
	^self printOn: aStream base: 10
]

{ #category : #printing }
Integer >> printOn: aStream [
	^self printOn: aStream base: 10
]

{ #category : #printing }
Integer >> printOn: aStream asFixedPoint: base [
	"assume I am a fixedpoint decimal scaled by base"
	"String streamContents: [:s | 1234 printOn: s asFixedPoint: 1000]"

	| b n |
	self < 0 ifTrue: [aStream nextPut: $-. 
		^self negated printOn: aStream asFixedPoint: base].
	b := base.
	n := self.
	[aStream print: n // b.
	(n := n \\ b) = 0] whileFalse: [
		b = base ifTrue: [aStream nextPut: $.].
		b := b // 10].

]

{ #category : #'printing-numerative' }
Integer >> printOn: aStream base: base [
	^self subclassResponsibility
]

{ #category : #'printing-numerative' }
Integer >> printOn: aStream base: base length: minimum padded: zeroFlag [
	| prefix |
	prefix := self negative ifTrue: ['-'] ifFalse: [String new].
	self print: (self abs printStringBase: base) on: aStream prefix: prefix length: minimum padded: zeroFlag

]

{ #category : #'printing-numerative' }
Integer >> printOn: aStream base: b nDigits: n [ 
	"Append a representation of this number in base b on aStream using nDigits.
	self must be positive."

	self subclassResponsibility
]

{ #category : #printing }
Integer >> printOn: outputStream base: baseInteger showRadix: flagBoolean [ 
	"Write a sequence of characters that describes the receiver in radix 
	baseInteger with optional radix specifier. 
	The result is undefined if baseInteger less than 2 or greater than 36."
	| tempString startPos |
	#Numeric.
	"2000/03/04  Harmon R. Added ANSI <integer> protocol"

	tempString := self printStringRadix: baseInteger.
	flagBoolean ifTrue: [^ outputStream nextPutAll: tempString].
	startPos := (tempString indexOf: $r ifAbsent: [self error: 'radix indicator not found.'])
				+ 1.
	self negative ifTrue: [outputStream nextPut: $-].
	outputStream nextPutAll: (tempString copyFrom: startPos to: tempString size)
]

{ #category : #printing }
Integer >> printOn: aStream maxDecimalPlaces: placesDesired [
	^self printOn: aStream
]

{ #category : #printing }
Integer >> printOn: aStream showingDecimalPlaces: placesDesired [
	"Same as super, but provides a faster implementation because fraction part and rounding are trivial."
	
	self printOn: aStream base: 10.
	placesDesired <= 0
		ifFalse:
			[aStream nextPut: $..
			0 printOn: aStream base: 10 length: placesDesired padded: true].
]

{ #category : #printing }
Integer >> printPaddedWith: aCharacter to: anInteger [ 
	"Answer the string containing the ASCII representation of the receiver 
	padded on the left with aCharacter to be at least anInteger characters."
	#Numeric.
	"2000/03/04  Harmon R. Added Date and Time support"
	^ self
		printPaddedWith: aCharacter
		to: anInteger
		base: 10
]

{ #category : #printing }
Integer >> printPaddedWith: aCharacter to: anInteger base: aRadix [ 
	"Answer the string containing the ASCII representation of the receiver 
	padded on the left with aCharacter to be at least anInteger characters."
	| aStream padding digits |
	#Numeric.
	"2000/03/04  Harmon R. Added Date and Time support"
	aStream := WriteStream on: (String new: 10).
	self
		printOn: aStream
		base: aRadix
		showRadix: false.
	digits := aStream contents.
	padding := anInteger - digits size.
	padding > 0 ifFalse: [^ digits].
	^ ((String new: padding) atAllPut: aCharacter;
	 yourself) , digits
]

{ #category : #printing }
Integer >> printString [
	"For Integer, prefer the stream version to the string version for efficiency"
	
	^String streamContents: [:str | self printOn: str base: 10]
]

{ #category : #'printing-numerative' }
Integer >> printStringBase: base length: minimum padded: zeroFlag [
	^String streamContents: [:s| self printOn: s base: base length: minimum padded: zeroFlag]
]

{ #category : #'printing-numerative' }
Integer >> printStringHex [
	^self printStringBase: 16
]

{ #category : #'printing-numerative' }
Integer >> printStringLength: minimal [
	^self printStringLength: minimal padded: false

]

{ #category : #'printing-numerative' }
Integer >> printStringLength: minimal padded: zeroFlag [
	^self printStringBase: 10 length: minimal padded: zeroFlag
]

{ #category : #'printing-numerative' }
Integer >> printStringPadded: minimal [
	^self printStringLength: minimal padded: true

]

{ #category : #printing }
Integer >> printStringRadix: baseInteger [ 
	"Return a string containing a sequence of characters that represents the 
	numeric value of the receiver in the radix specified by the argument.  
	If the receiver is negative, a minus sign ('-') is prepended to the 
	sequence of characters. 
	The result is undefined if baseInteger less than 2 or greater than 36."
	| tempString |
	#Numeric.
	"2000/03/04  Harmon R. Added ANSI <integer> protocol"
	baseInteger = 10
		ifTrue: 
			[tempString := self storeStringBase: baseInteger.
			self negative
				ifTrue: [^ '-10r' , (tempString copyFrom: 2 to: tempString size)]
				ifFalse: [^ '10r' , tempString]].
	^ self storeStringBase: baseInteger
]

{ #category : #'printing-numerative' }
Integer >> printStringRoman [
	^String streamContents: [:stream | | integer |
		integer := self negative ifTrue: [stream nextPut: $-. self negated] ifFalse: [self].
		integer // 1000 timesRepeat: [stream nextPut: $M].
		integer
			romanDigits: 'MDC' for: 100 on: stream;
			romanDigits: 'CLX' for: 10 on: stream;
			romanDigits: 'XVI' for: 1 on: stream]
]

{ #category : #printing }
Integer >> printTruncatedOn: aStream showingDecimalPlaces: placesDesired [
	"Print a representation of the receiver on aStream in decimal notation with prescribed number of places after decimal separator.
	Print as if the receiver was truncated to requested precision."

	self printOn: aStream.
	placesDesired > 0
		ifTrue:
			[aStream nextPut: $..
			aStream next: placesDesired put: $0]
]

{ #category : #arithmetic }
Integer >> quo: aNumber [ 
	"Refer to the comment in Number quo: "
	| quo |
	aNumber isInteger ifTrue: 
		[quo := (self divideByInteger: aNumber) at: 1.
		^ quo normalize].
	^ aNumber adaptToInteger: self andSend: #quo:
]

{ #category : #'printing-numerative' }
Integer >> radix: base [ 
	^ self printStringBase: base
]

{ #category : #'mathematical functions' }
Integer >> raisedTo: n modulo: m [
	"Answer the modular exponential.
	Note: this implementation is optimized for case of large integers raised to large powers."
	| a s mInv |
	n = 0 ifTrue: [^1].
	(self >= m or: [self < 0]) ifTrue: [^self \\ m raisedTo: n modulo: m].
	n < 0 ifTrue: [^(self reciprocalModulo: m) raisedTo: n negated modulo: m].
	(n < 4096 or: [m even])
		ifTrue:
			["Overhead of Montgomery method might cost more than naive divisions, use naive"
			^self slidingLeftRightRaisedTo: n modulo: m].
	
	mInv := self montgomeryDigitBase - ((m bitAnd: self montgomeryDigitMax) reciprocalModulo: self montgomeryDigitBase).
 
	"Initialize the result to R=self montgomeryDigitModulo raisedTo: m montgomeryNumberOfDigits"
	a := (1 bitShift: m montgomeryNumberOfDigits * m montgomeryDigitLength) \\ m.
	
	"Montgomerize self (multiply by R)"
	(s := self montgomeryTimes: (a*a \\ m) modulo: m mInvModB: mInv)
		ifNil:
			["No Montgomery primitive available ? fallback to naive divisions"
			^self slidingLeftRightRaisedTo: n modulo: m].

	"Exponentiate self*R"
	a := s montgomeryRaisedTo: n times: a modulo: m mInvModB: mInv.

	"Demontgomerize the result (divide by R)"
	^a montgomeryTimes: 1 modulo: m mInvModB: mInv
]

{ #category : #'mathematical functions' }
Integer >> raisedToFraction: aFraction [
	| root |
	root := self nthRootTruncated: aFraction denominator.
	(root raisedToInteger: aFraction denominator) = self ifTrue: [^root raisedToInteger: aFraction numerator].
	^super raisedToFraction: aFraction
]

{ #category : #arithmetic }
Integer >> reciprocalModulo: n [
	"Answer an integer x such that (self * x) \\ n = 1, x > 0, x < n.
	Raise an error if there is no such integer.
	The algorithm is a non extended euclidean modular inversion called NINV.
	It is described in this article:
		'Using an RSA Accelerator for Modular Inversion'
	by Martin Seysen. See http://www.iacr.org/archive/ches2005/017.pdf"

	| u v f fPlusN b result result2 |
	((self <= 0) or: [n <= 0]) ifTrue: [self error: 'self and n must be greater than zero'].
	self >= n ifTrue: [self error: 'self must be < n'].

	b := n highBit + 1.
	f := 1 bitShift: b.
	v := (self bitShift: b) + 1.
	u := n bitShift: b.
	fPlusN := f + n.
	[v >= fPlusN] whileTrue:
		[v := u \\ (u := v)].
	result := v - f.
	(result2 := result + n) > 0
		ifFalse: [self error: 'no inverse'].
	^result positive
		ifTrue: [result]
		ifFalse: [result2]
]

{ #category : #'system primitives' }
Integer >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	| j |  "Catches failure if LgInt replace primitive fails"
	j := repStart.
	start to: stop do:
		[:i |
		self digitAt: i put: (replacement digitAt: j).
		j := j+1]
]

{ #category : #private }
Integer >> romanDigits: digits for: base on: aStream [
	| n |
	n := self \\ (base * 10) // base.
	n = 9 ifTrue: [^ aStream nextPut: digits last; nextPut: digits first].
	n = 4 ifTrue: [^ aStream nextPut: digits last; nextPut: digits second].
	n > 4 ifTrue: [aStream nextPut: digits second].
	n \\ 5 timesRepeat: [aStream nextPut: digits last]
]

{ #category : #'truncation and round off' }
Integer >> rounded [ 
	"Refer to the comment in Number|rounded."
]

{ #category : #'truncation and round off' }
Integer >> significantDigits: aNumber [
	"Round to preserve aNumber significant digits:
	987654321 significantDigits: 1 ==> 1000000000
	987654321 significantDigits: 2 ==> 990000000"
	| digits |
	digits := self numberOfDigitsInBase: 10.
	^self roundTo: (10 raisedTo: digits - aNumber)
]

{ #category : #private }
Integer >> slidingLeftRightRaisedTo: n modulo: m [
	"Private - compute (self raisedTo: n) \\ m,
	Note: this method has to be fast because it is generally used with large integers in cryptography.
	It thus operate on exponent bits from left to right by packets with a sliding window rather than bit by bit (see below)."
	
	| pow j k w index oddPowersOfSelf square |
	
	"Precompute powers of self for odd bit patterns xxxx1 up to length w + 1.
	The width w is chosen with respect to the total bit length of n,
	such that each bit pattern will on average be encoutered P times in the whole bit sequence of n.
	This costs (2 raisedTo: w) multiplications, but more will be saved later (see below)."
	k := n highBit.
	w := (k highBit - 1 >> 1 min: 16) max: 1.
	oddPowersOfSelf := Array new: 1 << w.
	oddPowersOfSelf at: 1 put: (pow := self).
	square := self * self \\ m.
	2 to: oddPowersOfSelf size do: [:i | pow := oddPowersOfSelf at: i put: pow * square \\ m].
	
	"Now exponentiate by searching precomputed bit patterns with a sliding window"
	pow := 1.
	[k > 0]
		whileTrue:
			[pow := pow * pow \\ m.
			"Skip bits set to zero (the sliding window)"
			(n bitAt: k) = 0
				ifFalse:
					["Find longest odd bit pattern up to window length (w + 1)"
					j := k - w max: 1.
					[j < k and: [(n bitAt: j) = 0]] whileTrue: [j := j + 1].
					"We found an odd bit pattern of length k-j+1;
					perform the square powers for each bit
					(same cost as bitwise algorithm);
					compute the index of this bit pattern in the precomputed powers."
					index := 0.
					[k > j] whileTrue:
						[pow := pow * pow \\ m.
						index := index * 2 + (n bitAt: k).
						k := k - 1].
					"Perform a single multiplication for the whole bit pattern.
					This saves up to (k-j) multiplications versus a naive algorithm operating bit by bit"
					pow := pow * (oddPowersOfSelf at: index + 1) \\ m].
			k := k - 1].
	^pow
]

{ #category : #'mathematical functions' }
Integer >> sqrtFloor [
	"Return the integer part of the square root of self
	Assume self >= 0
	The following post-conditions apply:
	1) self sqrtFloor squared <= self
	2) (self sqrtFloor + 1) squared > self"

	self subclassResponsibility
]

{ #category : #'mathematical functions' }
Integer >> sqrtRem [
	"Return an array with floor sqrt and sqrt remainder.
	Assume self >= 0.
	The following invariants apply:
	1) self  sqrtRem first squared <= self
	2) (self sqrtRem first + 1) squared > self
	3) self sqrtRem first squared + self sqrtRem last = self"

	self subclassResponsibility
]

{ #category : #'printing-numerative' }
Integer >> storeOn: aStream base: base [
	"Print a representation of the receiver on the stream
	<aStream> in base <base> where
	2 <= <baseInteger> <= 16. If <base> is other than 10
	it is written first separated by $r followed by the number
	like for example: 16rFCE2"

	| integer |
	integer := self negative
		ifTrue: [aStream nextPut: $-. self negated]
		ifFalse: [self].
	base = 10 ifFalse: [aStream nextPutAll: base printString; nextPut: $r].
	aStream nextPutAll: (integer printStringBase: base).

]

{ #category : #'printing-numerative' }
Integer >> storeOn: aStream base: base length: minimum padded: zeroFlag [
	| prefix |
	prefix := self negative ifTrue: ['-'] ifFalse: [String new].
	base = 10 ifFalse: [prefix := prefix, base printString, 'r'].
	self print: (self abs printStringBase: base) on: aStream prefix: prefix length: minimum padded: zeroFlag

]

{ #category : #'printing-numerative' }
Integer >> storeStringBase: base length: minimum padded: zeroFlag [
	^String streamContents: [:s| self storeOn: s base: base length: minimum padded: zeroFlag]
]

{ #category : #'printing-numerative' }
Integer >> storeStringHex [
	^self storeStringBase: 16
]

{ #category : #'mathematical functions' }
Integer >> take: kk [
	"Return the number of combinations of (self) elements taken kk at a time.  For 6 take 3, this is 6*5*4 / (1*2*3).  Zero outside of Pascal's triangle.  Use a trick to go faster."
	" 6 take: 3  "

	| num denom |
	kk < 0 ifTrue: [^ 0].
	kk > self ifTrue: [^ 0].
	num := 1.
	self to: (kk max: self-kk) + 1 by: -1 do: [:factor | num := num * factor].
	denom := 1.
	1 to: (kk min: self-kk) do: [:factor | denom := denom * factor].
	^ num // denom
]

{ #category : #enumerating }
Integer >> timesRepeat: aBlock [ 
	"Evaluate the argument, aBlock, the number of times represented by the 
	receiver."

	| remaining |
	remaining := self.
	[ (remaining := remaining - 1) >= 0 ] whileTrue: [
		aBlock value ]
]

{ #category : #benchmarks }
Integer >> tinyBenchmarks [
	"Report the results of running the two tiny Squeak benchmarks.
	ar 9/10/1999: Adjusted to run at least 1 sec to get more stable results"
	"0 tinyBenchmarks"
	"On a 292 MHz G3 Mac: 23,000,000 bytecodes/sec; 980,000 sends/sec"
	"On a 400 MHz PII/Win98:  18,000,000 bytecodes/sec; 1,100,000 sends/sec"
	"On a 2800 MHz i7:  1,200,000,000 bytecodes/sec; 25,000,000 sends/sec"
	"On a 2800 MHz i7 (CogVM):  1,700,000,000 bytecodes/sec; 260,000,000 sends/sec"	
	| t1 t2 r n1 n2 |
	n1 := 1.
	[t1 := Time millisecondsToRun: [n1 benchmark].
	t1 < 1000] whileTrue:[n1 := n1 * 2]. "Note: #benchmark's runtime is about O(n)"

	n2 := 28.
	[t2 := Time millisecondsToRun: [r := n2 benchFib].
	t2 < 1000] whileTrue:[n2 := n2 + 1]. 
	"Note: #benchFib's runtime is about O(k^n),
		where k is the golden number = (1 + 5 sqrt) / 2 = 1.618...."

	^ ((n1 * 500000 * 1000) // t1 significantDigits: 2) asStringWithCommas, ' bytecodes/sec; ',
	  ((r * 1000) // t2 significantDigits: 2) asStringWithCommas, ' sends/sec'

]

{ #category : #'truncation and round off' }
Integer >> truncated [ 
	"Refer to the comment in Number|truncated."
]
