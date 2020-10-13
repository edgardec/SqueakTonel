"
I implement the 32-bit version of the Mersenne Twister PRNG, using 30-bit arithmetic, based on http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/ARTICLES/mt.pdf . The parameters of the generator are stored in class variables prefixed with MT.

Instance Variables
	states:	<Array>
	index: <Integer>

index
	- the index of the state, which should be used to generate the next random integer value

states
	- an Array holding the internal state of the generator

---

If you just want a quick random integer, use:
		10 atRandom
Every integer interval can give a random number:
		(6 to: 12) atRandom
SequenceableCollections can give randomly selected elements:
		'pick one of these letters randomly' atRandom
SequenceableCollections also respond to shuffled, as in:
		($A to: $Z) shuffled

The correct way to use class Random is to store one in an instance or class variable:
		myGenerator := Random new.
Then use it every time you need another number between 0.0 and 1.0 (excluding)
		myGenerator next
You can also generate a positive integer
		myGenerator nextInt: 10
"
Class {
	#name : #Random,
	#superclass : #Object,
	#instVars : [
		'states',
		'index'
	],
	#classVars : [
		'MTa',
		'MTbShifted',
		'MTcShifted',
		'MTl',
		'MTlowerMask',
		'MTm',
		'MTn',
		'MTs',
		'MTt',
		'MTu',
		'MTupperMask',
		'MTw',
		'MTwFloatMultiplier',
		'MTwordMask'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #testing }
Random class >> bucketTest: randy [
	"Execute this:   Random bucketTest: Random new"
	" A quick-and-dirty bucket test. Prints nbuckets values on the
Transcript.
	  Each should be 'near' the value of ntries. Any run with any value
'far' from ntries
	  indicates something is very wrong. Each run generates different
values.
	  For a slightly better test, try values of nbuckets of 200-1000 or
more; go get coffee.
	  This is a poor test; see Knuth.   Some 'OK' runs:
		1000 1023 998 969 997 1018 1030 1019 1054 985 1003
		1011 987 982 980 982 974 968 1044 976
		1029 1011 1025 1016 997 1019 991 954 968 999 991
		978 1035 995 988 1038 1009 988 993 976
"
	| nbuckets buckets ntrys |
	nbuckets := 200.
	buckets := Array new: nbuckets.
	buckets atAllPut: 0.
	ntrys :=  10000.
	ntrys*nbuckets timesRepeat: [ | slot |
		slot := randy nextInt: nbuckets.
		buckets at: slot put: (buckets at: slot) + 1 ].
	Transcript cr.
	1 to: nbuckets do: [ :nb |
		Transcript print: (buckets at: nb); space ].
	Transcript flush
]

{ #category : #'entropy source' }
Random class >> gatherEntropyInto: aByteArray [
	"Gather good random entropy from a system source and fill up aByteArray with it. Return true upon success, else false."
	
	<primitive: 'primitiveGatherEntropy' module: 'CroquetPlugin'>
	^false
]

{ #category : #'class initialization' }
Random class >> initialize [
	"30-bit MT521 parameters. generated with a modified version of dcmt with ID=1. http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/DC/dc.html"

	"Base parameters"
	"MTp := 521. Not used directly."
	MTw := 30.
	MTm := 9.
	MTa := 16r3235DEE2.
	"MTb := 16r39BB2B00. Not used directly."
	"MTc := 16r3EFD0000. Not used directly."
	MTl := -18.
	MTu := -12.
	MTs := 7.
	MTt := 15.
	"Calculated parameters"
	MTn := 18.
	"MTr := 19. Not used directly."
	MTupperMask := 16r3FF80000.
	MTlowerMask := 16r7FFFF.
	MTwordMask := 16r3FFFFFFF.
	MTbShifted := 7566934.
	MTcShifted := 32250.
	MTwFloatMultiplier := 8388608
]

{ #category : #'instance creation' }
Random class >> seed: anInteger [

	^self basicNew seed: anInteger
]

{ #category : #'die rolling' }
Random >> check: nDice [
	"Roll some dice, WoD-style."

	^ self check: nDice difficulty: 6
]

{ #category : #'die rolling' }
Random >> check: nAttack against: nDefend [
	"Roll some dice, WoD-style."

	^ self check: nAttack against: nDefend difficulty: 6
]

{ #category : #'die rolling' }
Random >> check: nAttack against: nDefend difficulty: diff [
	"Roll some dice, WoD-style."

	| attacks defends |
	attacks := self check: nAttack difficulty: diff.
	attacks < 0 ifTrue: [^ attacks].
	defends := self check: nDefend difficulty: diff.
	^ attacks - defends min: 0
]

{ #category : #'die rolling' }
Random >> check: nDice difficulty: diff [
	"Roll some dice, WoD-style."

	| result |
	result := 0.
	nDice timesRepeat: 
		[ | die |
		(die := self nextInt: 10) = 1
			ifTrue: [result := result - 1]
			ifFalse: [die >= diff ifTrue: [result := result + 1]]].
	^ result
]

{ #category : #'die rolling' }
Random >> diceToken: stream [
	"Private. Mini scanner, see #roll:"

	stream atEnd ifTrue: [^ nil].
	stream peek isDigit ifTrue: [^ Integer readFrom: stream].
	^ stream next asLowercase
]

{ #category : #private }
Random >> generateStates [
	"Generate untempered numbers into the states variable. Split up the operation into three parts to avoid the use of #atWrap: for accessing the states array. Optimized for SmallInteger operations."

	| i limit y offset |
	"Part 1"
	i := 0.
	offset := MTm.
	limit := MTn - offset.
	[ (i := i + 1) <= limit ] whileTrue: [
		y := (MTupperMask bitAnd: (states at: i)) bitOr: (MTlowerMask bitAnd: (states at: i + 1)).
		states
			at: i
			put: ((y bitAnd: 1) * MTa bitXor: ((states at: i + offset) bitXor: (y bitShift: -1))) ].
	"Part 2"
	limit := MTn - 1.
	offset := MTm - MTn.
	i := i - 1.
	[ (i := i + 1) <= limit ] whileTrue: [
		y := (MTupperMask bitAnd: (states at: i)) bitOr: (MTlowerMask bitAnd: (states at: i + 1)).
		states
			at: i
			put: ((y bitAnd: 1) * MTa bitXor: ((states at: i + offset) bitXor: (y bitShift: -1))) ].
	"Part 3"
	y := (MTupperMask bitAnd: (states at: MTn)) bitOr: (MTlowerMask bitAnd: (states at: 1)).
	states
		at: MTn
		put: ((y bitAnd: 1) * MTa bitXor: ((states at: MTm) bitXor: (y bitShift: -1))).
	index := 1
	
]

{ #category : #private }
Random >> hashSeed: anInteger [
	"Use the 32-bit version of the FNV-1a algorithm to hash the seed, and return a 32-bit unsigned integer."

	| fnvPrime hash |
	fnvPrime := 16777619 " 32-bit FVN prime ".
	hash := anInteger negative
		ifTrue: [  3490449840 "  mix in the sign as (2166136261 bitXor: 2r1010101) * 16777619 bitAnd: 16rFFFFFFFF "]
		ifFalse: [ 2166136261 " 32-bit FVN offset basis "].
	1 to: anInteger digitLength do: [ :index |
		hash := 16rFFFFFFFF bitAnd: (hash bitXor: (anInteger digitAt: index)) * fnvPrime ].
	^hash
]

{ #category : #initialization }
Random >> initialize [
	
	self seed: nil
]

{ #category : #private }
Random >> initializeStatesWith: anInteger [
	"Initialize the states array with the seed."

	| seed |
	states := Array new: MTn.
	seed := anInteger.
	1 to: MTn do: [ :i | 
		states at: i put: (MTwordMask bitAnd: seed).
		seed := 16rFFFFFFFF bitAnd: (16r6C078965 * (seed bitXor: seed //  16r40000000 "bitShift: -30") + i) ]
]

{ #category : #accessing }
Random >> next [
	"Answer a random 53-bit Float from the [0, 1) interval. The implementation assumes that the MTw parameter is between 27 and 53."
	
	^self nextValue asFloat * MTwFloatMultiplier + (self nextValue bitAnd: MTwFloatMultiplier - 1) / 9.007199254740992e15 "(1 << 53) asFloat"
]

{ #category : #accessing }
Random >> next: anInteger [
	^ self next: anInteger into: (Array new: anInteger)
]

{ #category : #accessing }
Random >> next: anInteger into: anArray [
	1 to: anInteger do: [:index | anArray at: index put: self next].
	^ anArray
]

{ #category : #accessing }
Random >> nextBytes: anInteger into: aBytesObject startingAt: startIndex [
	"Fill aBytesObject, an object with indexable byte fields, with anInteger number of random bytes starting from startIndex. Assume that MTw is at least 8."

	| randomValue remainingBits index endIndex |
	randomValue := remainingBits := 0.
	index := startIndex.
	endIndex := startIndex + anInteger - 1.
	[ index <= endIndex ] whileTrue: [
		remainingBits >= 8
			ifTrue: [
				aBytesObject basicAt: index put: (randomValue bitAnd: 16rFF).
				randomValue := randomValue bitShift: -8.
				remainingBits := remainingBits - 8.
				index := index + 1 ]
			ifFalse: [
				remainingBits = 0
					ifTrue: [ randomValue := self nextValue ]
					ifFalse: [
						| newRandomValue |
						newRandomValue := self nextValue.
						aBytesObject basicAt: index put: (randomValue bitShift: 8 - remainingBits) + 
							(newRandomValue bitAnd: (1 bitShift: 8 - remainingBits) - 1).
						randomValue := newRandomValue bitShift: 0 - remainingBits.
						index := index + 1 ].
				remainingBits := MTw - remainingBits ] ]
]

{ #category : #accessing }
Random >> nextInt: anInteger [
	"Answer a random integer value from the interval [1, anInteger]"

	| bucketSize retriesLeft |
	anInteger strictlyPositive ifFalse: [ self error: 'Range must be positive' ].
	(anInteger isLarge 
		or: [ anInteger > MTwordMask "In case SmallIntegers have more than MTw-bits, but the generator hasn't been updated accordingly." ]) 
		ifTrue: [ ^self nextLargeInt: anInteger ].
	"Split the MTw-bit(currently 30-bit) integer range up to the equal sized buckets. Generate an MTw-bit random number, and see which bucket it's in. If it doesn't fit in any bucket, then try again."
	bucketSize := MTwordMask // anInteger. "The optimal bucket size would be MTwordMask + 1 // anInteger, but calculating it would involve LargeInteger arithmetic. The MTwordMask // anInteger expression is suboptimal only when anInteger is a power of two. These cases are rare, and the effect is negligible for small values. We could handle these cases separately, but testing if anInteger is a power of two costs more in general."
	retriesLeft := 10. "Based on measurements with various seeds, 10 retries is about optimal for the worst case, when anInteger = MTwordMask // 2 + 1."
	[ (retriesLeft := retriesLeft - 1) >= 0 ] whileTrue: [
		| bucket |
		bucket := self nextValue // bucketSize.
		bucket < anInteger ifTrue: [ ^bucket + 1 ] ].
	"Fall back to the floating point method, which is slower, but when we get here, then we've already spent enough resources on trying to generate the number. Using this fallback also ensures that the method doesn't run for indefinitely long."
	^(self next * anInteger) truncated + 1
]

{ #category : #accessing }
Random >> nextLargeInt: anInteger [
	"Answer a random integer value from the interval [1, anInteger]. This method works for arbitrarily large integers."

	| byteCount bigRandom result firstDigit |
	byteCount := anInteger digitLength + 4. "Extend the space with at least 32 bits for a fairer distribution."
	bigRandom := LargePositiveInteger new: byteCount.
	self nextBytes: byteCount into: bigRandom startingAt: 1.
	bigRandom := bigRandom normalize. "Make sure that there are no leading zero bytes."
	result := anInteger * bigRandom bitShift: -8 * byteCount.
	"Avoid using LargeInteger arithmetic for +1 in most cases."
	result isLarge ifFalse: [ ^result + 1 ].
	(firstDigit := result digitAt: 1) = 255 ifTrue: [ ^result + 1 ].
	result digitAt: 1 put: firstDigit + 1.
	^result
	
]

{ #category : #private }
Random >> nextValue [
	"Answer an MTw-bit random integer between 0 and wordMask, and increment the index."

	| y |
	y := states at: index.
	(index := index + 1) > MTn ifTrue: [ self generateStates ].
	y := y bitXor: (y bitShift: MTu).
	y := ((y bitAnd: MTbShifted) bitShift: MTs) bitXor: y.
	y := ((y bitAnd: MTcShifted) bitShift: MTt) bitXor: y.
	y := (y bitShift: MTl) bitXor: y.
	^y
]

{ #category : #'die rolling' }
Random >> roll: diceString [
	"Roll some dice, DnD-style, according to this mini-grammar:
		dice := epxr {pm dice}
		pm := '+' | '-'
		expr := num | num dD | dD numP | num dD numP
		dD := 'd' | 'D'
		num := digit+
		numP := num | '%'"

	| stream op result |
	stream := diceString readStream.
	result := 0.
	op := #+.
	[ | res range dice token |
	token := self diceToken: stream.
	token isNumber
		ifTrue: [dice := token.
				res := token.
				token := self diceToken: stream]
		ifFalse: [token == $d
			ifTrue: [dice := 1]
			ifFalse: [self error: 'unknown token' , token]].
	token == $d
		ifTrue: [token := self diceToken: stream.
				token isNumber
					ifTrue: [range := token.
							token := self diceToken: stream]
					ifFalse: [token == $%
						ifTrue: [range := 100.
								token := self diceToken: stream]
						ifFalse: [range := 6]].
				res := 0.
				dice timesRepeat: [res := res + (self nextInt: range)]].
	result := result perform: op with: res.
	token ifNil: [^ result].
	(token == $+ or: [token == $-])
		ifFalse: [self error: 'unknown token ' , token].
	op := token asSymbol] repeat
]

{ #category : #initialization }
Random >> seed: anIntegerOrNil [
	"Use the given integer as the seed, or generate one if it's nil."

	(anIntegerOrNil isNil and: [ self seedWithRandomBytes ]) ifFalse: [
		| newSeed |
		newSeed := anIntegerOrNil ifNil: [
			(Time utcMicrosecondClock bitShift: 28) bitXor: self hash hashMultiply ].
		(newSeed between: 0 and: 16rFFFFFFFF) ifFalse: [
			newSeed := self hashSeed: newSeed ].
		self initializeStatesWith: newSeed ].
	self generateStates
]

{ #category : #private }
Random >> seedWithRandomBytes [
	"Initialize the states array with random bytes from the VM. Return true on success, false on failure."

	| randomBytes |
	randomBytes := ByteArray new: MTn * 4.
	(self class gatherEntropyInto: randomBytes) ifFalse: [
		"Primitive not available"
		^false ].
	states := Array new: MTn.
	1 to: MTn do: [ :i | 
		states at: i put: (
			"The below code assumes that MTwordMask is 1 << 30 - 1. It avoids LargeInteger operations on 32-bit platforms. It's equivalent to:
			(randomBytes unsignedLongAt: 1 bigEndian: true) bitAnd: MTwordMask"
			((randomBytes at: i * 4 - 3) bitAnd: 16r3F) * 256 +
				(randomBytes at: i * 4 - 2) * 256 +
				(randomBytes at: i * 4 - 1) * 256 +
				(randomBytes at: i * 4)) ].
	^true
]
