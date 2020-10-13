"
I am an abstract collection of objects that implement hash and equality in a consitent way. This means that whenever two objects are equal, their hashes have to be equal too. If two objects are equal then I can only store one of them. Hashes are expected to be integers (preferably SmallIntegers). I also expect that the objects contained by me do not change their hashes. If that happens, hash invariants have to be re-established, which can be done by #rehash.

Since I'm abstract, no instances of me should exist. My subclasses should implement #scanFor:, #fixCollisionsFrom: and #noCheckNoGrowFillFrom:.

Instance Variables
	array:		<ArrayedCollection> (typically Array or WeakArray)
	tally:		<Integer> (non-negative)

array
	- An array whose size is a prime number, it's non-nil elements are the elements of the collection, and whose nil elements are empty slots. There is always at least one nil. In fact I try to keep my ""load"" at 75% or less so that hashing will work well.

tally
	- The number of elements in the collection. The array size is always greater than this.

Implementation details:
I implement a hash table which uses open addressing with linear probing as the method of collision resolution. Searching for an element or a free slot for an element is done by #scanFor: which should return the index of the slot in array corresponding to it's argument. When an element is removed #fixCollisionsFrom: should rehash all elements in array between the original index of the removed element, wrapping around after the last slot until reaching an empty slot. My maximum load factor (75%) is hardcoded in #atNewIndex:put:, so it can only be changed by overriding that method. When my load factor reaches this limit I replace my array with a larger one (see #grow) ensuring that my load factor will be less than or equal to 50%. The new array is filled by #noCheckNoGrowFillFrom: which should use #scanForEmptySlotFor: instead of #scanFor: for better performance. I do not shrink.

"
Class {
	#name : #HashedCollection,
	#superclass : #Collection,
	#instVars : [
		'tally',
		'array'
	],
	#classVars : [
		'GoodPrimes'
	],
	#category : #'Collections-Abstract'
}

{ #category : #private }
HashedCollection class >> arrayType [
	^ Array
]

{ #category : #'initialize-release' }
HashedCollection class >> cleanUp: aggressive [
	"Rehash all instances when cleaning aggressively"

	aggressive ifTrue: [ self compactAll ]

]

{ #category : #'initialize-release' }
HashedCollection class >> compactAll [
	"HashedCollection compactAll"	
		
	self allSubclassesDo: [ :each | each compactAllInstances ]
]

{ #category : #'initialize-release' }
HashedCollection class >> compactAllInstances [
	"Do not use #allInstancesDo: because #compact may create new instances."

	self allInstances do: [ :each | each compact ]
]

{ #category : #sizing }
HashedCollection class >> goodPrimeAtLeast: lowerLimit [
	"Answer the smallest good prime >= lowerlimit.
	If lowerLimit is larger than the largest known good prime, just make it odd.
	Use linear search, and exponential search to speed up cases when lowerLimit is small (<2500 and <100000, respectively).
	Assume that there are goodPrimes greater than 100000."
	
	| highIndex midIndex lowIndex prime |
	lowerLimit < 2500 ifTrue: [
		"Use linear search when the limit is small. The boundary is based on measurements."
		highIndex := 1.
		[ (GoodPrimes at: highIndex) < lowerLimit ] whileTrue: [
			highIndex := highIndex + 1 ].
		^GoodPrimes at: highIndex ].
	lowerLimit < 100000 
		ifTrue: [
			"Use exponential search when the limit is not too large. The boundary is based on measurements."
			highIndex := 1.
			[ (GoodPrimes at: highIndex) < lowerLimit ] whileTrue: [
				highIndex := highIndex * 2 ].
			lowIndex := highIndex // 2 + 1. "highIndex // 2 was smaller than lowerLimit" ]
		ifFalse: [
			"Regular binary search."
			lowIndex := 1.
			highIndex := GoodPrimes size.
			"Check whether the largest prime would fit"
			(GoodPrimes at: highIndex) < lowerLimit ifTrue: [
				^lowerLimit bitOr: 1 ]. ].
	[ highIndex - lowIndex <= 1 ] whileFalse: [
		midIndex := highIndex + lowIndex // 2.
		prime := GoodPrimes at: midIndex.
		lowerLimit < prime
			ifTrue: [ highIndex := midIndex ]
			ifFalse: [
				lowerLimit > prime
					ifTrue: [ lowIndex := midIndex ]
					ifFalse: [ ^prime ] ] ].
	(GoodPrimes at: lowIndex) >= lowerLimit ifTrue: [ ^GoodPrimes at: lowIndex ].
	^GoodPrimes at: highIndex
]

{ #category : #sizing }
HashedCollection class >> goodPrimes [
	"Answer a sorted array of prime numbers less than one billion that make good hash table sizes. See #initializeGoodPrimes."
	
	^GoodPrimes ifNil: [
		self initializeGoodPrimes.
		GoodPrimes ]
]

{ #category : #sizing }
HashedCollection class >> initialize [

	self initializeGoodPrimes
]

{ #category : #sizing }
HashedCollection class >> initializeGoodPrimes [
	"GoodPrimes is a sorted array of prime numbers less than one billion that make good hash table sizes. Should be expanded as needed. See comments below code."
	
	GoodPrimes := #(3 5 7 11 13 17 23 31 43 59 79 107 149 199 269 359 479 641 857 1151 1549 2069
		2237 2423 2617 2797 2999 3167 3359 3539 3727 3911
		4441 4787 5119 5471 5801 6143 6521 6827 7177 7517 7853
		8783 9601 10243 10867 11549 12239 12919 13679 14293 15013 15731
		17569 19051 20443 21767 23159 24611 25847 27397 28571 30047 31397
		35771 38201 40841 43973 46633 48989 51631 54371 57349 60139 62969
		70589 76091 80347 85843 90697 95791 101051 106261 111143 115777 120691 126311
		140863 150523 160969 170557 181243 190717 201653 211891 221251 232591 242873 251443
		282089 300869 321949 341227 362353 383681 401411 422927 443231 464951 482033 504011
		562621 605779 647659 681607 723623 763307 808261 844709 886163 926623 967229 1014617
		1121987 1201469 1268789 1345651 1429531 1492177 1577839 1651547 1722601 1800377 1878623 1942141 2028401
		2242727 2399581 2559173 2686813 2836357 3005579 3144971 3283993 3460133 3582923 3757093 3903769 4061261
		4455361 4783837 5068529 5418079 5680243 6000023 6292981 6611497 6884641 7211599 7514189 7798313 8077189
		9031853 9612721 10226107 10745291 11338417 11939203 12567671 13212697 13816333 14337529 14938571 15595673 16147291
		17851577 18993941 20180239 21228533 22375079 23450491 24635579 25683871 26850101 27921689 29090911 30153841 31292507 32467307
		35817611 37983761 40234253 42457253 44750177 46957969 49175831 51442639 53726417 55954637 58126987 60365939 62666977 64826669
		71582779 76039231 80534381 84995153 89500331 93956777 98470819 102879613 107400389 111856841 116365721 120819287 125246581 129732203
		143163379 152076289 161031319 169981667 179000669 187913573 196826447 205826729 214748357 223713691 232679021 241591901 250504801 259470131
		285162679 301939921 318717121 335494331 352271573 369148753 385926017 402603193 419480419 436157621 453034849 469712051 486589307 503366497 520043707 
		570475349 603929813 637584271 671138659 704693081 738247541 771801929 805356457 838910803 872365267 905919671 939574117 973128521 1006682977 1040137411 
		1073741833)

"The above primes past 2069 were chosen carefully so that they do not interact badly with 1664525 (used by hashMultiply), and so that gcd(p, (256^k) +/- a) = 1, for 0<a<=32 and 0<k<=8.  See Knuth's TAOCP for details."

"The above primes also try to map the values of ((0 to: 4095) collect: [ :each | each << 18 \\ prime ]) sort to an equidistant sequence of numbers. This helps to avoid the collision of chains in identity-based hashed collections. To do that  they were chosen to return a low value when the following block is evaluated with them as argument:
 [ :prime |
	| n slots cost optimalDistance |
	n := 1 bitShift: 22.
	slots := Array new: n + 1.
	0 to: n - 1 do: [ :ea | slots at: ea + 1 put: (ea bitShift: 8) \\ prime ].
	slots at: n + 1 put: prime.
	slots sort.
	cost := 0.
	optimalDistance := prime // n.
	2 to: n + 1 do: [ :index |
		| newCost |
		newCost := optimalDistance - ((slots at: index) - (slots at: index - 1)).
		newCost > cost ifTrue: [ cost := newCost ] ].
	result add: prime -> cost ]

The shifts in the block relate to the numer of bits the #identityHash consists of (22) and the number of bits #scaledIdentityHash shifts it (8)"
]

{ #category : #testing }
HashedCollection class >> isAbstract [
	^self = HashedCollection
]

{ #category : #'instance creation' }
HashedCollection class >> new [
	"Create a HashedCollection large enough to hold 3 different objects without growing."

	^self basicNew initialize: 5 "For performance, inline the value 5 which would normally be returned by #sizeFor:."
]

{ #category : #'instance creation' }
HashedCollection class >> new: numberOfElements [
	"Create a HashedCollection large enough to hold numberOfElements different objects without growing."
	
	^self basicNew initialize: (numberOfElements <= 3
		ifFalse: [ self sizeFor: numberOfElements ]
		ifTrue: [ "Inline values returned by #sizeFor: to ensure that #new: is not significantly slower than #new for small values."
			numberOfElements < 3
				ifTrue: [ 3 ]
				ifFalse: [ 5 ] ])
]

{ #category : #'initialize-release' }
HashedCollection class >> rehashAll [
	"HashedCollection rehashAll"	
		
	self allSubclassesDo: [ :each | each rehashAllInstances ]
]

{ #category : #'initialize-release' }
HashedCollection class >> rehashAllInstances [
	"Do not use #allInstancesDo: because #rehash may create new instances."

	self allInstances do: [ :each | each rehash ]
]

{ #category : #sizing }
HashedCollection class >> sizeFor: numberOfElements [
	"Return a large enough prime (or odd if too large), the size of the internal array to hold numberOfElements with at most 75% load factor."
	
	^self goodPrimeAtLeast: numberOfElements * 4 + 2 // 3 "Optimized version of (numberOfElements * 4 / 3) ceiling."
]

{ #category : #adding }
HashedCollection >> add: newObject withOccurrences: anInteger [
	"Add newObject anInteger times to the receiver. Do nothing if anInteger is less than one. Answer newObject."
	
	anInteger < 1 ifTrue: [ ^newObject ].
	^self add: newObject "I can only store an object once."
	
]

{ #category : #private }
HashedCollection >> array [
	^ array
]

{ #category : #private }
HashedCollection >> arrayType [
	^ Array
]

{ #category : #private }
HashedCollection >> atNewIndex: index put: anObject [

	array at: index put: anObject.
	tally := tally + 1.
	"Keep array at least 1/4 free for decent hash behavior"
	array size * 3 < (tally * 4) ifTrue: [ self grow ]
]

{ #category : #accessing }
HashedCollection >> capacity [
	"Answer the current capacity of the receiver - aka the number of elements the receiver can hold without growing."

	^ array size * 3 // 4
]

{ #category : #'objects from disk' }
HashedCollection >> comeFullyUpOnReload: smartRefStream [
	"Symbols have new hashes in this image."

	self compact
]

{ #category : #private }
HashedCollection >> compact [
	"Reduce the size of array so that the load factor will be ~75%."
	
	| newCapacity |
	newCapacity := self class sizeFor: self slowSize.
	self growTo: newCapacity
]

{ #category : #copying }
HashedCollection >> copyEmpty [
	"Answer an empty copy of this collection"
	
	"Note: this code could be moved to super"
	
	^self species new
]

{ #category : #enumerating }
HashedCollection >> doWithIndex: aBlock2 [
	"Support Set enumeration with a counter, even though not ordered"
	| index |
	index := 0.
	self do: [:item | aBlock2 value: item value: (index := index+1)]
]

{ #category : #private }
HashedCollection >> errorNoFreeSpace [

	self error: 'There is no free space in this collection!'
]

{ #category : #private }
HashedCollection >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by nil.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one."
	
	self subclassResponsibility
]

{ #category : #private }
HashedCollection >> grow [
	"Grow the elements array and reinsert the old elements"
	
	self growTo: self growSize
]

{ #category : #private }
HashedCollection >> growSize [
	"Answer what my next higher table size should be"
	
	^self class sizeFor: self slowSize * 2
]

{ #category : #private }
HashedCollection >> growTo: anInteger [
	"Grow the elements array and reinsert the old elements"
	
	| oldElements |
	oldElements := array.
	array := self arrayType new: anInteger.
	self noCheckNoGrowFillFrom: oldElements
]

{ #category : #private }
HashedCollection >> initialize: n [
	"Initialize array to an array size of n"
	array := self arrayType new: n.
	tally := 0
]

{ #category : #testing }
HashedCollection >> isEmpty [
	"For non-weak collections, we can use the tally to speed up the empty check. For weak collections, we must use the traditional way because the tally is unreliable. Also see #size vs. #slowSize."

	tally = 0 ifTrue: [ ^true ].
	^array class isWeak and: [ super isEmpty ]
]

{ #category : #private }
HashedCollection >> noCheckNoGrowFillFrom: anArray [
	"Add the elements of anArray except nils to me assuming that I don't contain any of them, they are unique and I have more free space than they require."
	
	self subclassResponsibility
]

{ #category : #private }
HashedCollection >> rehash [
	
	self growTo: array size
]

{ #category : #removing }
HashedCollection >> removeAll [
	"remove all elements from this collection.
	Preserve the capacity"
	
	self initialize: array size
]

{ #category : #private }
HashedCollection >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	self subclassResponsibility
]

{ #category : #private }
HashedCollection >> scanForEmptySlotFor: anObject [
	"Scan the key array for the first slot containing an empty slot (indicated by a nil). Answer the index of that slot. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := anObject hash \\ (size := array size) + 1.
	[ 
		(array at: index) ifNil: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #accessing }
HashedCollection >> size [
	^ tally
]

{ #category : #accessing }
HashedCollection >> slowSize [
	"Answer an upper bound of the number of elements in this collection. For regular collections, this can simply be the value of tally, but for collections that cannot maintain an exact value, like current weak collections, this has to be calculated on the fly."
	
	^tally
]

{ #category : #accessing }
HashedCollection >> someElement [

	self deprecated: 'Use #anyOne'.
	^self anyOne
]

{ #category : #enumerating }
HashedCollection >> union: aCollection [
	"Answer the set theoretic union of the receiver and aCollection, using the receiver's notion of equality and not side effecting the receiver at all."

	^ self copy addAll: aCollection; yourself


]
