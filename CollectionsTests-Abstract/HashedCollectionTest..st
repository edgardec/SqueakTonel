Class {
	#name : #HashedCollectionTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Abstract'
}

{ #category : #'tests - integrity' }
HashedCollectionTest >> testArraySize [

	| inconsistentCollections |
	inconsistentCollections := HashedCollection allSubInstances reject: [ :each |
		each class == MethodDictionary "MethodDictionary is the only HashedCollection which doesn't have prime array size"
			ifTrue: [ each array size isPowerOfTwo ]
			ifFalse: [ each array size isPrime ] ].
	self assert: inconsistentCollections isEmpty
]

{ #category : #'tests - integrity' }
HashedCollectionTest >> testCapacity [

	self assert: (HashedCollection allSubInstances allSatisfy: [ :each |
		 each array size * 3 // 4 = each capacity ])
]

{ #category : #'tests - class - sizing' }
HashedCollectionTest >> testGoodPrimeAtLeast [

	| primes |
	primes := HashedCollection goodPrimes.
	primes do: [ :each |
		self assert: (HashedCollection goodPrimeAtLeast: each) = each.
		self assert: (HashedCollection goodPrimeAtLeast: each - 1) = each.
		self assert: (HashedCollection goodPrimeAtLeast: each + 1) > each ].
	(0 to: 1000) do: [ :each |
		| goodPrime |
		goodPrime := HashedCollection goodPrimeAtLeast: each.
		self assert: goodPrime isPrime.
		self assert: goodPrime >= each.
		self assert: (primes detect: [ :ea | ea >= each ] ifNone: [ each + 1 ]) = goodPrime ].
	self assert: (HashedCollection goodPrimeAtLeast: primes last + 1) odd
]

{ #category : #'tests - class - sizing' }
HashedCollectionTest >> testGoodPrimes [

	| goodPrimes badPrimes hashMultiplyConstant |
	goodPrimes := HashedCollection goodPrimes.
	"Bad primes are less than the hashMultiply constant (1664525) and 1664525 \\ prime is close to 0 (mod prime)."
	hashMultiplyConstant := 1 hashMultiply.
	badPrimes := (Integer primesUpTo: hashMultiplyConstant) select: [ :each |
		| remainder |
		remainder := hashMultiplyConstant \\ each.
		remainder <= 1 or: [ remainder + 1 = each ] ].
	self assert: goodPrimes isArray.
	goodPrimes do: [ :each | 
		self assert: each isInteger.
		self assert: each odd.
		self assert: each isPrime ].
	self assert: goodPrimes isSorted.
	"HashedCollection class >> #goodPrimesAtLeast: relies on the following three."
	self assert: goodPrimes size > 3.
	self assert: #(3 5 7) equals: (goodPrimes first: 3).
	self assert: goodPrimes last > 100000.
	"The below snippet tests that primes past 2069 do not interact badly with 1664525, the hashMultiply constant."
	goodPrimes
		select: [ :each | each > 2069 ]
		thenDo: [ :each |
			self deny: (badPrimes includes: each).
			1 to: 8 do: [ :k |
				1 to: 32 do: [ :a |
					self assert: 1 equals: (each gcd: (256 raisedTo: k) + a).
					self assert: 1 equals: (each gcd: (256 raisedTo: k) - a) ] ] ]
]

{ #category : #'tests - class - sizing' }
HashedCollectionTest >> testSizeFor [

	| goodPrimes |
	goodPrimes := HashedCollection goodPrimes.
	(0 to: 10000) asArray,
	#(
		10999 61356 68602 73189 79868 86789 239984 239985 501175 661865 841558
		9669391 15207345 19827345 23469817 27858432 65223175 106650047
		157687845 190892299 234947087 264782114 269617510 270995400 
		392236508 456647275 468699153 606865011 606997796 617927086
		837938371 880614337 989233852 1000473294 1060034095 1073741833 1073741834) do: [ :numberOfElements |
			| capacity capacityIndex |
			capacity := HashedCollection sizeFor: numberOfElements.
			self 
				assert: capacity isInteger
					description: '#sizeFor: must return an integer';
				assert: capacity odd
					description: '#sizeFor: must return an odd integer';
				assert: capacity > 0
					description: '#sizeFor: must return a positive integer'.
			capacity <= goodPrimes last ifTrue: [
				self 
					assert: capacity isPrime
					description: '#sizeFor: must return a prime when the returned capacity is smaller than the largest good prime' ].
			self
				assert: numberOfElements asFloat / capacity <= 0.75
				description: '#sizeFor: must return a capacity for which the load factor does not exceed 75%'.
			capacityIndex := goodPrimes indexOf: capacity ifAbsent: [ goodPrimes size + 1 ].
			capacityIndex > 1 ifTrue: [
				| nextSmallerCapacity |
				nextSmallerCapacity := goodPrimes at: capacityIndex - 1.
				self
					assert: numberOfElements asFloat / nextSmallerCapacity > 0.75
					description: '#sizeFor: should return the smallest possible capacity' ] ]
]
