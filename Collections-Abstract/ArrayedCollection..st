"
I am an abstract collection of elements with a fixed range of integers (from 1 to n>=0) as external keys.
"
Class {
	#name : #ArrayedCollection,
	#superclass : #SequenceableCollection,
	#category : #'Collections-Abstract'
}

{ #category : #testing }
ArrayedCollection class >> isAbstract [
	^self = ArrayedCollection
]

{ #category : #'instance creation' }
ArrayedCollection class >> new [
	"Answer a new instance of me, with size = 0."

	^self new: 0
]

{ #category : #'instance creation' }
ArrayedCollection class >> new: size withAll: value [ 
	"Answer an instance of me, with number of elements equal to size, each 
	of which refers to the argument, value."

	^(self new: size) atAllPut: value
]

{ #category : #'instance creation' }
ArrayedCollection class >> newFrom: aCollection [ 
	"Answer an instance of me containing the same elements as aCollection."
	| newArray |
	newArray := self new: aCollection size.
	1 to: aCollection size do: [:i | newArray at: i put: (aCollection at: i)].
	^ newArray

"	Array newFrom: {1. 2. 3}
	{1. 2. 3} as: Array
	{1. 2. 3} as: ByteArray
	{$c. $h. $r} as: String
	{$c. $h. $r} as: Text
"
]

{ #category : #'instance creation' }
ArrayedCollection class >> newFromStream: s [
	"Only meant for my subclasses that are raw bits and word-like.  For quick unpack form the disk."
	
	| len |
	(self isPointers or: [ self isWords not ]) ifTrue: [ ^self ].
	s next = 16r80 ifTrue: [
		"A compressed format.  Could copy what BitMap does, or use a 
		special sound compression format.  Callers normally compress their own way."
		^self error: 'not implemented' ].
	s skip: -1.
	len := s nextInt32.
	^s nextWordsInto: (self basicNew: len)
]

{ #category : #'instance creation' }
ArrayedCollection class >> with: anObject [ 
	"Answer a new instance of me, containing only anObject."

	| newCollection |
	newCollection := self new: 1.
	newCollection at: 1 put: anObject.
	^newCollection
]

{ #category : #'instance creation' }
ArrayedCollection class >> with: firstObject with: secondObject [ 
	"Answer a new instance of me, containing firstObject and secondObject."

	| newCollection |
	newCollection := self new: 2.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	^newCollection
]

{ #category : #'instance creation' }
ArrayedCollection class >> with: firstObject with: secondObject with: thirdObject [ 
	"Answer a new instance of me, containing only the three arguments as
	elements."

	| newCollection |
	newCollection := self new: 3.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	^newCollection
]

{ #category : #'instance creation' }
ArrayedCollection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject [ 
	"Answer a new instance of me, containing only the four arguments as
	elements."

	| newCollection |
	newCollection := self new: 4.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	^newCollection
]

{ #category : #'instance creation' }
ArrayedCollection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject [
	"Answer a new instance of me, containing only the five arguments as
	elements."

	| newCollection |
	newCollection := self new: 5.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	newCollection at: 5 put: fifthObject.
	^newCollection
]

{ #category : #'instance creation' }
ArrayedCollection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject with: sixthObject [
	"Answer a new instance of me, containing only the 6 arguments as elements."

	| newCollection |
	newCollection := self new: 6.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	newCollection at: 5 put: fifthObject.
	newCollection at: 6 put: sixthObject.
	^ newCollection
]

{ #category : #'instance creation' }
ArrayedCollection class >> withAll: aCollection [
	"Create a new collection containing all the elements from aCollection."

	^ (self new: aCollection size) replaceFrom: 1 to: aCollection size with: aCollection
]

{ #category : #adding }
ArrayedCollection >> add: newObject [
	self shouldNotImplement
]

{ #category : #converting }
ArrayedCollection >> asSortedArray [
	self isSorted ifTrue: [^ self asArray].
	^ super asSortedArray
]

{ #category : #'objects from disk' }
ArrayedCollection >> byteSize [
	^self basicSize * self bytesPerBasicElement

]

{ #category : #'objects from disk' }
ArrayedCollection >> bytesPerBasicElement [
	"Answer the number of bytes that each of my basic elements requires.
	In other words:
		self basicSize * self bytesPerBasicElement
	should equal the space required on disk by my variable sized representation."
	| bytesPerElementOrZero |
	bytesPerElementOrZero := #[0 0 0 0 0 0 0 0 8 4 4 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1] at: self class instSpec.
	^bytesPerElementOrZero = 0
		ifTrue: [Smalltalk wordSize]
		ifFalse: [bytesPerElementOrZero]
]

{ #category : #'objects from disk' }
ArrayedCollection >> bytesPerElement [
	| bytesPerElementOrZero |
	bytesPerElementOrZero := #[0 0 0 0 0 0 0 0 8 4 4 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1] at: self class instSpec.
	^bytesPerElementOrZero = 0
		ifTrue: [Smalltalk wordSize]
		ifFalse: [bytesPerElementOrZero]
]

{ #category : #private }
ArrayedCollection >> defaultElement [

	^nil
]

{ #category : #private }
ArrayedCollection >> fillFrom: aCollection with: aBlock [
	"Evaluate aBlock with each of aCollections's elements as the argument.  
	Collect the resulting values into self. Answer self."

	| index |
	index := 0.
	aCollection do: [ :each |
		self at: (index := index + 1) put: (aBlock value: each) ]
]

{ #category : #'filter streaming' }
ArrayedCollection >> flattenOnStream: aStream [ 
	aStream writeArrayedCollection: self
]

{ #category : #enumerating }
ArrayedCollection >> inject: anObject into: aBlock [
	"Optimized for speed. See super."
	
	| result |
	result := anObject.
	1 to: self size do: [:i | result := aBlock value: result value: (self at: i)].
	^result
]

{ #category : #testing }
ArrayedCollection >> isEmpty [
	^self size = 0
]

{ #category : #sorting }
ArrayedCollection >> isSorted [
	"Return true if the receiver is sorted by #<=."

	^self isSortedBetween: 1 and: self size
]

{ #category : #sorting }
ArrayedCollection >> isSortedBetween: startIndex and: endIndex [
	"Return true if the receiver is sorted by #<= between startIndex and endIndex."

	| previousElement |
	endIndex < startIndex ifTrue: [ ^true ].
	previousElement := self at: startIndex.
	startIndex + 1 to: endIndex do: [ :index |
		| element |
		element := self at: index.
		previousElement <= element ifFalse: [ ^false ].
		previousElement := element ].
	^true
]

{ #category : #sorting }
ArrayedCollection >> isSortedBy: aSortBlockOrNil [
	"Return true if the receiver is sorted by aSortBlockOrNil. Use #<= for comparison if aSortBlockOrNil is nil."

	^self isSortedBy: aSortBlockOrNil between: 1 and: self size
]

{ #category : #sorting }
ArrayedCollection >> isSortedBy: aSortBlockOrNil between: startIndex and: endIndex [
	"Return true if the receiver is sorted by aSortBlockOrNil between startIndex and endIndex. Use #<= for comparison if aSortBlockOrNil is nil."

	| previousElement |
	aSortBlockOrNil ifNil: [ ^self isSortedBetween: startIndex and: endIndex ].
	endIndex < startIndex ifTrue: [ ^true ].
	previousElement := self at: startIndex.
	startIndex + 1 to: endIndex do: [ :index |
		| element |
		element := self at: index.
		(aSortBlockOrNil value: previousElement value: element) ifFalse: [ ^false ].
		previousElement := element ].
	^true
]

{ #category : #sorting }
ArrayedCollection >> mergeFirst: first middle: middle last: last into: dst by: aBlock [
	"Private. Merge the sorted ranges [first..middle] and [middle+1..last] 
	of the receiver into the range [first..last] of dst."

	| i1 i2 val1 val2 out |
	i1 := first.
	i2 := middle + 1.
	val1 := self at: i1.
	val2 := self at: i2.
	out := first - 1.  "will be pre-incremented"

	"select 'lower' half of the elements based on comparator"
	[ (i1 <= middle) and: [ i2 <= last ] ] whileTrue: [
		(aBlock 
			ifNil: [ val1 <= val2 ]
			ifNotNil: [ aBlock value: val1 value: val2 ])
				ifTrue: [
					dst at: (out := out + 1) put: val1.
					val1 := self at: (i1 := i1 + 1)]
				ifFalse: [
					dst at: (out := out + 1) put: val2.
					val2 := self atWrap: (i2 := i2 + 1) ] ].

	"copy the remaining elements"
	i1 <= middle
		ifTrue: [dst replaceFrom: out + 1 to: last with: self startingAt: i1]
		ifFalse: [dst replaceFrom: out + 1 to: last with: self startingAt: i2]
]

{ #category : #sorting }
ArrayedCollection >> mergeSortFrom: startIndex to: stopIndex by: aBlock [
	"Sort the given range of indices using the mergesort algorithm.
	Mergesort is a worst-case O(N log N) sorting algorithm that usually
	does only half as many comparisons as heapsort or quicksort."

	"Details: recursively split the range to be sorted into two halves,
	mergesort each half, then merge the two halves together. An extra 
	copy of the data is used as temporary storage and successive merge 
	phases copy data back and forth between the receiver and this copy.
	The recursion is set up so that the final merge is performed into the
	receiver, resulting in the receiver being completely sorted."

	| size |
	(size := self size) <= 1 ifTrue: [^ self].  "nothing to do"
	startIndex = stopIndex ifTrue: [^ self].
	1 <= startIndex ifFalse: [ self errorSubscriptBounds: startIndex ].
	stopIndex <= size ifFalse: [ self errorSubscriptBounds: stopIndex ].
	startIndex < stopIndex ifFalse: [ self errorSubscriptBounds: startIndex ].
	self shallowCopy
		mergeSortFrom: startIndex
		to: stopIndex 
		into: self 
		by: aBlock
]

{ #category : #sorting }
ArrayedCollection >> mergeSortFrom: firstIndex to: lastIndex into: destination by: aBlock [
	"Private. Split the range to be sorted in half, sort each half, and 
	merge the two half-ranges into destination."

	| n firstObject lastObject |
	"Precondition: firstIndex <= lastIndex, self and destination contain the same elements between firstIndex and lastIndex inclusively but not necessarily in the same order"
	(n := lastIndex - firstIndex) <= 1 ifTrue: [ "Handle 1 and 2 sized ranges directly."
		n = 0 ifTrue: [ ^self ].
		firstObject := self at: firstIndex.
		lastObject := self at: lastIndex.
		(aBlock
			ifNil: [ firstObject <= lastObject ]
			ifNotNil: [ aBlock value: firstObject value: lastObject ])
			ifFalse: [
				destination
					at: lastIndex put: firstObject;
					at: firstIndex put: lastObject ]
			ifTrue: [
				destination
					at: lastIndex put: lastObject;
					at: firstIndex put: firstObject ].
		^self ].
	n := firstIndex + lastIndex // 2.
	destination mergeSortFrom: firstIndex to: n into: self by: aBlock.
	destination mergeSortFrom: n + 1 to: lastIndex into: self by: aBlock.
	self mergeFirst: firstIndex middle: n last: lastIndex into: destination by: aBlock
]

{ #category : #enumerating }
ArrayedCollection >> occurrencesOf: anObject [ 
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	| tally |
	tally := 0.
	1 to: self size do: [ :index |
		(self at: index) = anObject ifTrue: [ tally := tally + 1 ] ].
	^tally
]

{ #category : #sorting }
ArrayedCollection >> quickSort [
	"Sort elements of self to be nondescending according to #<= using an in-place quicksort with simple median-of-three partitioning with guaranteed O(log(n)) space usage."

	self quickSortFrom: 1 to: self size by: nil
]

{ #category : #sorting }
ArrayedCollection >> quickSort: sortBlock [
	"Sort elements of self to be nondescending according to sortBlock using an in-place quicksort with simple median-of-three partitioning with guaranteed O(log(n)) space usage."

	self quickSortFrom: 1 to: self size by: sortBlock
]

{ #category : #sorting }
ArrayedCollection >> quickSortFrom: from to: to by: sortBlock [
	"Sort elements i through j of self to be nondescending according to sortBlock using an in-place quicksort with simple median-of-three partitioning with guaranteed O(log(n)) space usage."

	| dij k l temp i j di dj n ij |
	i := from.
	j := to.
	[
		
		"The prefix d means the data at that index."
		"Sort di,dj."
		di := self at: i.
		dj := self at: j.
		(sortBlock ifNil: [ di <= dj ] ifNotNil: [ sortBlock value: di value: dj ]) ifFalse: [
			self at: i put: dj; at: j put: di. temp := dj. dj := di. di := temp "swap di with dj" ].
		(n := j + 1 - i) <= 2 ifTrue: [ ^self ].
		"More than two elements."
		dij := self at: (ij := i + j // 2). "ij is the midpoint of i and j. Sort di,dij,dj. Make dij be their median."
		(sortBlock ifNil: [ di <= dij ] ifNotNil: [ sortBlock value: di value: dij ])
			ifTrue: [
				(sortBlock ifNil: [ dij <= dj ] ifNotNil: [ sortBlock value: dij value: dj ]) ifFalse: [
					 "swap dij with dj, we don't need the value of the variable dj anymore"
					self at: j put: dij; at: ij put: dj. dij := dj ] ]
			ifFalse: [
				 "swap di with dij, we don't need the value of the variable di anymore"
				self at: i put: dij; at: ij put: di. dij := di ].
		n = 3 ifTrue: [ ^self ].
		"More than three elements."
		"Find k and l such that i<k<l<j and dk,dij,dl are in reverse order. Swap k and l. Repeat this procedure until k and l pass each other."
		k := i.
		l := j.
		[
			[ k <= (l := l - 1) and: [ 
				sortBlock ifNil: [ dij <= (self at: l) ] ifNotNil: [ sortBlock value: dij value: (self at: l) ] ] ] whileTrue.  "i.e. while dl succeeds dij"
			[ (k := k + 1) <= l and: [
				sortBlock ifNil: [ (self at: k) <= dij ] ifNotNil: [ sortBlock value: (self at: k) value: dij ] ] ] whileTrue.  "i.e. while dij succeeds dk"
			k <= l ] whileTrue: [ temp := self at: k. self at: k put: (self at: l); at: l put: temp. ].
		"Now l<k (either 1 or 2 less), and di through dl are all less than or equal to dk through dj. Sort the larger segment in this method and call another quicksort for the smaller segment. This ensures O(log(n)) space usage."
		i < l 
			ifFalse: [
				k < j
					ifFalse: [ ^self ]
					ifTrue: [ i := k ] ]
			ifTrue: [
				k < j
					ifFalse: [ j := l ]
					ifTrue: [
						l - i <  (j - k)
							ifTrue: [ 
								self quickSortFrom: i to: l by: sortBlock.
								i := k ]
							ifFalse: [
								self quickSortFrom: k to: j by: sortBlock.
								j := l ] ] ] ] repeat
]

{ #category : #removing }
ArrayedCollection >> removeAll [

	self shouldNotImplement
]

{ #category : #'objects from disk' }
ArrayedCollection >> restoreEndianness [
	"This word object was just read in from a stream.  It was stored in Big Endian (Mac) format.  Reverse the byte order if the current machine is Little Endian.
	We only intend this for non-pointer arrays.  Do nothing if I contain pointers."

	self class isPointers | self class isWords not ifTrue: [^self].
	Smalltalk  isLittleEndian 
		ifTrue: 
			[Bitmap 
				swapBytesIn: self
				from: 1
				to: self basicSize]
]

{ #category : #accessing }
ArrayedCollection >> size [
	"Answer how many elements the receiver contains."

	<primitive: 62>
	^ self basicSize
]

{ #category : #sorting }
ArrayedCollection >> sort [
	"Sort this array into ascending order using the '<=' operator."

	self sort: nil
]

{ #category : #sorting }
ArrayedCollection >> sort: aSortBlock [ 
	"Sort this array using aSortBlock. The block should take two arguments
	and return true if the first element should preceed the second one.
	If aSortBlock is nil then <= is used for comparison."

	self
		mergeSortFrom: 1
		to: self size
		by: aSortBlock
]

{ #category : #private }
ArrayedCollection >> storeElementsFrom: firstIndex to: lastIndex on: aStream [

	| noneYet defaultElement arrayElement |
	noneYet := true.
	defaultElement := self defaultElement.
	firstIndex to: lastIndex do: 
		[:index | 
		arrayElement := self at: index.
		arrayElement = defaultElement
			ifFalse: 
				[noneYet
					ifTrue: [noneYet := false]
					ifFalse: [aStream nextPut: $;].
				aStream nextPutAll: ' at: '.
				aStream store: index.
				aStream nextPutAll: ' put: '.
				aStream store: arrayElement]].
	^noneYet
]

{ #category : #printing }
ArrayedCollection >> storeOn: aStream [

	aStream nextPutAll: '(('.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' new: '.
	aStream store: self size.
	aStream nextPut: $).
	(self storeElementsFrom: 1 to: self size on: aStream)
		ifFalse: [aStream nextPutAll: '; yourself'].
	aStream nextPut: $)
]

{ #category : #'objects from disk' }
ArrayedCollection >> swapHalves [
		"A normal switch in endianness (byte order in words) reverses the order of 4 bytes.  That is not correct for SoundBuffers, which use 2-bytes units.  If a normal switch has be done, this method corrects it further by swapping the two halves of the long word.
	This method is only used for 16-bit quanities in SoundBuffer, ShortIntegerArray, etc."

	| hack blt |
	"The implementation is a hack, but fast for large ranges"
	hack := Form new hackBits: self.
	blt := (BitBlt toForm: hack) sourceForm: hack.
	blt combinationRule: Form reverse.  "XOR"
	blt sourceY: 0; destY: 0; height: self size; width: 2.
	blt sourceX: 0; destX: 2; copyBits.  "Exchange bytes 0&1 with 2&3"
	blt sourceX: 2; destX: 0; copyBits.
	blt sourceX: 0; destX: 2; copyBits.
]

{ #category : #'objects from disk' }
ArrayedCollection >> writeOn: aStream [ 
	"Store the array of bits onto the argument, aStream.  (leading byte ~= 16r80) identifies this as raw bits (uncompressed).  Always store in Big Endian (Mac) byte order.  Do the writing at BitBlt speeds. We only intend this for non-pointer arrays.  Do nothing if I contain pointers."

	(self class isPointers or: [ self class isWords not ]) ifTrue: [ ^self ].
	aStream nextInt32Put: self basicSize.
	aStream nextWordsPutAll: self.
]

{ #category : #'objects from disk' }
ArrayedCollection >> writeOnGZIPByteStream: aStream [ 
	"We only intend this for non-pointer arrays.  Do nothing if I contain pointers."

	(self class isPointers or: [ self class isWords not ]) ifTrue: [ ^self ].
	aStream nextPutAllWordArray: self
]
