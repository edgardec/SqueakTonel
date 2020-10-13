"
I represent a collection of objects ordered by the collector.
"
Class {
	#name : #OrderedCollection,
	#superclass : #SequenceableCollection,
	#instVars : [
		'array',
		'firstIndex',
		'lastIndex'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #'instance creation' }
OrderedCollection class >> new [
	^ self new: 10
]

{ #category : #'instance creation' }
OrderedCollection class >> new: anInteger [ 
	| instance |
	^(instance := self basicNew) setCollection: (instance arrayType new: anInteger)
]

{ #category : #'instance creation' }
OrderedCollection class >> new: anInteger withAll: anObject [
	| instance |
	^(instance := self basicNew) setContents: (instance arrayType new: anInteger withAll: anObject)
]

{ #category : #'instance creation' }
OrderedCollection class >> newFrom: aCollection [ 
	"Answer an instance of me containing the same elements as aCollection."

	^(self new: aCollection size)
		addAll: aCollection;
		yourself

"	OrderedCollection newFrom: {1. 2. 3}
	{1. 2. 3} as: OrderedCollection
	{4. 2. 7} as: SortedCollection
"
]

{ #category : #'instance creation' }
OrderedCollection class >> ofSize: n [
	"Create a new collection of size n with nil as its elements.
	This method exists because OrderedCollection new: n creates an
	empty collection,  not one of size n."
	| collection |
	collection := self new: n.
	collection setContents: (collection collector).
	^ collection

]

{ #category : #adding }
OrderedCollection >> add: newObject [

	^self addLast: newObject
]

{ #category : #adding }
OrderedCollection >> add: newObject after: oldObject [ 
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just succeeding oldObject. Answer newObject."
	
	| index |
	index := self find: oldObject.
	self insert: newObject before: index + 1.
	^newObject
]

{ #category : #adding }
OrderedCollection >> add: newObject afterIndex: index [ 
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just after index. Answer newObject."
	(index between: 0 and: self size) ifFalse:[^self errorSubscriptBounds: index].
	self insert: newObject before: firstIndex + index.
	^ newObject
]

{ #category : #adding }
OrderedCollection >> add: newObject before: oldObject [ 
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just preceding oldObject. Answer newObject."
	
	| index |
	index := self find: oldObject.
	self insert: newObject before: index.
	^newObject
]

{ #category : #adding }
OrderedCollection >> add: newObject beforeIndex: index [ 
	"Add the argument, newObject, as an element of the receiver. Put it in 
	the sequence just before index. Answer newObject."
	(index between: 1 and: self size+1) ifFalse:[^self errorSubscriptBounds: index].
	self insert: newObject before: firstIndex + index - 1.
	^ newObject
]

{ #category : #adding }
OrderedCollection >> addAll: aCollection [ 
	"Add each element of aCollection at my end. Answer	aCollection."

	^ self addAllLast: aCollection
]

{ #category : #adding }
OrderedCollection >> addAllFirst: aCollection [ 
	"Add all elements of aCollection to the beginning of the me. Answer aCollection. Use double dispatch to add elements in reverse order if aCollection implements #reverseDo:."

	^aCollection addAllFirstTo: self
]

{ #category : #adding }
OrderedCollection >> addAllFirstUnlessAlreadyPresent: anOrderedCollection [ 
	"Add each element of anOrderedCollection at the beginning of the receiver, preserving the order, but do not add any items that are already in the receiver.  Answer anOrderedCollection."

	anOrderedCollection reverseDo:
		[:each | (self includes: each) ifFalse: [self addFirst: each]].
	^ anOrderedCollection
]

{ #category : #adding }
OrderedCollection >> addAllLast: aCollection [ 
	"Add each element of aCollection at the end of me. Answer aCollection."

	^aCollection do: [ :each | self addLast: each ]
]

{ #category : #adding }
OrderedCollection >> addFirst: newObject [ 
	"Add newObject to the beginning of the receiver. Answer newObject."

	firstIndex = 1 ifTrue: [ self makeRoomAtFirst ].
	^array at: (firstIndex := firstIndex - 1) put: newObject
]

{ #category : #adding }
OrderedCollection >> addLast: newObject [ 
	"Add newObject to the end of the receiver. Answer newObject."

	array size = lastIndex ifTrue: [ self makeRoomAtLast ].
	^array at: (lastIndex := lastIndex + 1) put: newObject
]

{ #category : #enumerating }
OrderedCollection >> allButFirstDo: aBlock [ 
	"Override the superclass for performance reasons."

	firstIndex + 1 to: lastIndex do: [ :index |
		aBlock value: (array at: index) ]
]

{ #category : #enumerating }
OrderedCollection >> allButLastDo: aBlock [ 
	"Override the superclass for performance reasons."

	firstIndex to: lastIndex - 1 do: [ :index |
		aBlock value: (array at: index) ]
]

{ #category : #private }
OrderedCollection >> arrayType [
	^ Array
]

{ #category : #converting }
OrderedCollection >> asArray [
	"Overriden for speed"

	| result size |
	result := Array new: (size := self size).
	result
		replaceFrom: 1
		to: size
		with: array
		startingAt: firstIndex.
	^result
]

{ #category : #accessing }
OrderedCollection >> at: anInteger [ 
	"Answer my element at index anInteger. at: is used by a knowledgeable
	client to access an existing element"

	| index |
	1 <= anInteger ifFalse: [ self errorNoSuchElement ].
	(index := anInteger + firstIndex - 1) <= lastIndex ifFalse: [ self errorNoSuchElement ].
	^array at: index
]

{ #category : #accessing }
OrderedCollection >> at: index ifAbsentPut: block [
	"Return value at index, however, if value does not exist (nil or out of bounds) then add block's value at index (growing self if necessary)"

	[ index <= self size ] whileFalse: [ self add: nil ].
	^(self at: index) ifNil: [ self at: index put: block value ]
]

{ #category : #accessing }
OrderedCollection >> at: anInteger put: anObject [ 
	"Put anObject at element index anInteger. at:put: cannot be used to
	append, front or back, to an ordered collection; it is used by a
	knowledgeable client to replace an element."

	| index |
	1 <= anInteger ifFalse: [ self errorNoSuchElement ].
	(index := anInteger + firstIndex - 1) <= lastIndex ifFalse: [ self errorNoSuchElement ].
	^array at: index put: anObject
]

{ #category : #accessing }
OrderedCollection >> capacity [
	"Answer the current capacity of the receiver."

	^ array size
]

{ #category : #enumerating }
OrderedCollection >> collect: aBlock [ 
	"Evaluate aBlock with each of my elements as the argument.
	Collect the resulting values into an OrderedCollection."

	| newCollection |
	newCollection := OrderedCollection new: self size.
	firstIndex to: lastIndex do:
		[:index |
		newCollection addLast: (aBlock value: (array at: index))].
	^ newCollection
]

{ #category : #enumerating }
OrderedCollection >> collect: aBlock from: fromIndex to: toIndex [
	"Evaluate aBlock with each of my elements as the argument between fromIndex and toIndex.
	Collect the resulting values into an OrderedCollection."

	| result offset |
	offset := firstIndex - 1.
	(fromIndex < 1 or:[toIndex + offset > lastIndex])
		ifTrue: [^self errorNoSuchElement].
	result := OrderedCollection new: toIndex - fromIndex + 1.
	fromIndex + offset to: toIndex + offset do:
		[:index | result addLast: (aBlock value: (array at: index))].
	^ result

]

{ #category : #private }
OrderedCollection >> collector [  "Private"
	^ array
]

{ #category : #copying }
OrderedCollection >> copyEmpty [
	"Answer a copy of the receiver that contains no elements."

	^self species new
]

{ #category : #copying }
OrderedCollection >> copyFrom: startIndex to: endIndex [ 
	"Answer a copy of the receiver that contains elements from position
	startIndex to endIndex."

	^self shallowCopy postCopyFrom: startIndex to: endIndex
]

{ #category : #copying }
OrderedCollection >> copyReplaceFrom: start to: stop with: replacementCollection [ 
	"Answer a copy of the receiver with replacementCollection's elements in
	place of the receiver's start'th to stop'th elements. This does not expect
	a 1-1 map from replacementCollection to the start to stop elements, so it
	will do an insert or append."

	| newOrderedCollection delta startIndex stopIndex |
	"if start is less than 1, ignore stop and assume this is inserting at the front. 
	if start greater than self size, ignore stop and assume this is appending. 
	otherwise, it is replacing part of me and start and stop have to be within my 
	bounds. "
	delta := 0.
	startIndex := start.
	stopIndex := stop.
	start < 1
		ifTrue: [startIndex := stopIndex := 0]
		ifFalse: [startIndex > self size
				ifTrue: [startIndex := stopIndex := self size + 1]
				ifFalse: 
					[(stopIndex < (startIndex - 1) or: [stopIndex > self size])
						ifTrue: [self errorOutOfBounds].
					delta := stopIndex - startIndex + 1]].
	newOrderedCollection := 
		self species new: self size + replacementCollection size - delta.
	1 to: startIndex - 1 do: [:index | newOrderedCollection add: (self at: index)].
	1 to: replacementCollection size do: 
		[:index | newOrderedCollection add: (replacementCollection at: index)].
	stopIndex + 1 to: self size do: [:index | newOrderedCollection add: (self at: index)].
	^newOrderedCollection
]

{ #category : #copying }
OrderedCollection >> copyWith: newElement [ 
	"Answer a copy of the receiver that is 1 bigger than the receiver and 
	includes the argument, newElement, at the end."

	| newCollection |
	newCollection := self copy.
	newCollection add: newElement.
	^newCollection
]

{ #category : #enumerating }
OrderedCollection >> do: aBlock [ 
	"Override the superclass for performance reasons."
	
	firstIndex to: lastIndex do: [ :index | 
		aBlock value: (array at: index) ]
]

{ #category : #private }
OrderedCollection >> errorNoSuchElement [

	self error: (String streamContents: [ :stream | 
		stream nextPutAll: 'attempt to index a non-existent element in '.
		self printNameOn: stream ])
]

{ #category : #private }
OrderedCollection >> errorNotEnoughElements [

	self error: (String streamContents: [ :stream | 
		stream nextPutAll: 'attempt to remove more elements than possible from '.
		self printNameOn: stream ])
]

{ #category : #private }
OrderedCollection >> find: oldObject [
  "  This method answers an index in the range firstIndex .. lastIndex, which is meant for internal use only.
     Never use this method in your code, the methods for public use are:
        #indexOf:
        #indexOf:ifAbsent: "

	firstIndex to: lastIndex do: [ :index |
		(array at: index) = oldObject ifTrue: [ ^index ] ].
	self errorNotFound: oldObject
]

{ #category : #accessing }
OrderedCollection >> first [

	firstIndex > lastIndex ifTrue: [ self errorNoSuchElement ].
	^array at: firstIndex
]

{ #category : #private }
OrderedCollection >> growAtFirst [
	"Add new empty slots to the front of array, while keeping the empty slots at the end."

	| newArray newFirstIndex newLastIndex |
	newArray := self arrayType new: (array size * 2 max: 1).
	newFirstIndex := newArray size - array size + firstIndex.
	newLastIndex := newFirstIndex + lastIndex - firstIndex.
	newArray 
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array := newArray.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : #private }
OrderedCollection >> growAtLast [
	"Add new empty slots to the end of array, while keeping the empty slots at the front."

	| newArray |
	newArray := self arrayType new: (array size * 2 max: 1).
	newArray 
		replaceFrom: firstIndex
		to: lastIndex
		with: array
		startingAt: firstIndex.
	array := newArray
]

{ #category : #accessing }
OrderedCollection >> indexOf: anElement startingAt: start [
	"Optimized version."

	firstIndex + start - 1 to: lastIndex do: [ :index |
		(array at: index) = anElement ifTrue: [ ^index - firstIndex + 1 ] ].
	^0
]

{ #category : #private }
OrderedCollection >> insert: anObject before: spot [

  "  spot is an index in the range firstIndex .. lastIndex, such an index is not known from outside the collection. 
     Never use this method in your code, it is meant for private use by OrderedCollection only.
     The methods for use are:
        #add:before:   to insert an object before another object
        #add:beforeIndex:   to insert an object before a given position. "
	| "index" delta spotIndex|
	spotIndex := spot.
	delta := spotIndex - firstIndex.
	firstIndex = 1
		ifTrue: 
			[self makeRoomAtFirst.
			spotIndex := firstIndex + delta].
	firstIndex := firstIndex - 1.
	array
		replaceFrom: firstIndex
		to: spotIndex - 2
		with: array
		startingAt: firstIndex + 1.
	array at: spotIndex - 1 put: anObject.
"	index := firstIndex := firstIndex - 1.
	[index < (spotIndex - 1)]
		whileTrue: 
			[array at: index put: (array at: index + 1).
			index := index + 1].
	array at: index put: anObject."
	^ anObject
]

{ #category : #testing }
OrderedCollection >> isEmpty [
	^firstIndex > lastIndex
]

{ #category : #sorting }
OrderedCollection >> isSorted [
	"Return true if the receiver is sorted by #<=."
	
	^array
		isSortedBetween: firstIndex
		and: lastIndex
]

{ #category : #sorting }
OrderedCollection >> isSortedBetween: startIndex and: endIndex [
	"Return true if the receiver is sorted by #<= between startIndex and endIndex."
	
	^array isSortedBetween: startIndex + firstIndex - 1 and: endIndex + firstIndex - 1
]

{ #category : #sorting }
OrderedCollection >> isSortedBy: aSortBlockOrNil [
	"Return true if the receiver is sorted by aSortBlockOrNil. Use #<= for comparison if aSortBlockOrNil is nil."
	
	^array
		isSortedBy: aSortBlockOrNil
		between: firstIndex
		and: lastIndex
]

{ #category : #sorting }
OrderedCollection >> isSortedBy: aSortBlockOrNil between: startIndex and: endIndex [
	"Return true if the receiver is sorted by aSortBlockOrNil between startIndex and endIndex. Use #<= for comparison if aSortBlockOrNil is nil."
	
	^array
		isSortedBy: aSortBlockOrNil
		between: startIndex + firstIndex - 1
		and: endIndex + firstIndex - 1
]

{ #category : #accessing }
OrderedCollection >> last [

	firstIndex > lastIndex ifTrue: [ self errorNoSuchElement ].
	^array at: lastIndex
]

{ #category : #private }
OrderedCollection >> makeRoomAtFirst [
	"Make some empty slots at the front of the array. If we have more than 50% free space, then just move the elements, so that the first 50% of the slots are free, otherwise add new free slots to the front by growing. Precondition: firstIndex = 1"
	
	| tally newFirstIndex newLastIndex capacity |
	tally := self size.
	capacity := array size.
	tally * 2 >= capacity ifTrue: [ ^self growAtFirst ].
	tally = 0 ifTrue: [ ^self resetTo: capacity + 1 ].
	newFirstIndex := capacity // 2 + 1.
	newLastIndex := newFirstIndex - firstIndex + lastIndex.
	0 to: tally - 1 do: [ :offset |
		array at: newLastIndex - offset put: (array at: lastIndex - offset) ].
	array from: firstIndex to: newFirstIndex - 1 put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : #private }
OrderedCollection >> makeRoomAtLast [
	"Make some empty slots at the end of the array. If we have more than 50% free space, then just move the elements, so that the last 50% of the slots are free, otherwise add new free slots to the end by growing. Precondition: lastIndex = array size"
	
	| tally newFirstIndex newLastIndex |
	tally := self size.
	tally * 2 >= lastIndex ifTrue: [ ^self growAtLast ].
	tally = 0 ifTrue: [ ^self resetTo: 1 ].
	newLastIndex := lastIndex // 2.
	newFirstIndex := newLastIndex - lastIndex + firstIndex.
	array 
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array from: newLastIndex + 1 to: lastIndex put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : #enumerating }
OrderedCollection >> occurrencesOf: anObject [ 
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	| tally |
	tally := 0.
	firstIndex to: lastIndex do: [ :index |
		(array at: index) = anObject ifTrue: [ tally := tally + 1 ] ].
	^tally
]

{ #category : #copying }
OrderedCollection >> postCopy [
	array := array copy
]

{ #category : #copying }
OrderedCollection >> postCopyFrom: startIndex to: endIndex [ 
	"finish copying the array in a certain range."

	endIndex < startIndex ifFalse: [
		"Because actual size of the array may be greater than used size,
		postCopyFrom:to: may fail to fail and answer an incorrect result
		if this sanity check were not applied"
		(startIndex between: 1 and: self size) ifFalse: [^self error: 'startIndex is out of bounds'].
		(endIndex between: 1 and: self size) ifFalse: [^self error: 'endIndex is out of bounds']].
	
	"Add a protection that lacks in Array>>postcopy"
	array := array copyFrom: startIndex + firstIndex - 1 to: (endIndex max: startIndex - 1) + firstIndex - 1.
	firstIndex := 1.
	lastIndex := array size
]

{ #category : #removing }
OrderedCollection >> remove: oldObject ifAbsent: absentBlock [

	firstIndex to: lastIndex do: [ :index |
		(array at: index) = oldObject ifTrue: [
			self removeIndex: index.
			^oldObject ] ].
	^absentBlock value
]

{ #category : #removing }
OrderedCollection >> removeAll [
	"remove all the elements from this collection.
	Keep same amount of storage"
	
	self setCollection: (self arrayType new: array size)
]

{ #category : #removing }
OrderedCollection >> removeAllSuchThat: aBlock [ 
	"Remove each element of the receiver for which aBlock evaluates to true.
	The method in Collection is O(N^2), this is O(N)."

	| n |
	n := firstIndex.
	firstIndex to: lastIndex do: [ :index |
		| element |
		(aBlock value: (element := array at: index)) ifFalse: [
			array at: n put: element.
			n := n + 1 ] ].
	array from: n to: lastIndex put: nil.
	lastIndex := n - 1
]

{ #category : #removing }
OrderedCollection >> removeAt: index [
	| removed |
	removed := self at: index.
	self removeIndex: index + firstIndex - 1.
	^removed
]

{ #category : #removing }
OrderedCollection >> removeFirst [
	"Remove the first element of the receiver and answer it. If the receiver is 
	empty, create an error notification."
	
	| firstObject |
	firstIndex > lastIndex ifTrue: [ self errorEmptyCollection ].
	firstObject := array at: firstIndex.
	array at: firstIndex put: nil.
	firstIndex := firstIndex + 1.
	^firstObject
]

{ #category : #removing }
OrderedCollection >> removeFirst: n [ 
	"Remove the first n objects into an array."

	| lastIndexToRemove result |
	n < 1 ifTrue: [ self errorNoSuchElement ].
	lastIndex < (lastIndexToRemove := firstIndex + n - 1) ifTrue: [ self errorNotEnoughElements ].
	result := array copyFrom: firstIndex to: lastIndexToRemove.
	array from: firstIndex to: lastIndexToRemove put: nil.
	firstIndex := lastIndexToRemove + 1.
	^result
]

{ #category : #private }
OrderedCollection >> removeIndex: removedIndex [
  "  removedIndex is an index in the range firstIndex .. lastIndex, such an index is not known from outside the collection.
    Never use this method in your code, it is meant for private use by OrderedCollection only.
     The method for public use is:
        #removeAt: "

	array 
		replaceFrom: removedIndex 
		to: lastIndex - 1 
		with: array 
		startingAt: removedIndex+1.
	array at: lastIndex put: nil.
	lastIndex := lastIndex - 1.
]

{ #category : #removing }
OrderedCollection >> removeLast [
	"Remove the last element of the receiver and answer it. If the receiver is 
	empty, create an error notification."
	
	| lastObject |
	firstIndex > lastIndex ifTrue: [ self errorEmptyCollection ].
	lastObject := array at: lastIndex.
	array at: lastIndex put: nil.
	lastIndex := lastIndex - 1.
	^ lastObject
]

{ #category : #removing }
OrderedCollection >> removeLast: n [ 
	"Remove the last n objects into an array with last in last position."

	| firstIndexToRemove result |
	n < 1 ifTrue: [ self errorNoSuchElement ].
	(firstIndexToRemove := lastIndex - n + 1) < firstIndex ifTrue: [ self errorNotEnoughElements ].
	result := array copyFrom: firstIndexToRemove to: lastIndex.
	array from: firstIndexToRemove to: lastIndex put: nil.
	lastIndex := firstIndexToRemove - 1.
	^result
]

{ #category : #enumerating }
OrderedCollection >> replace: aBlock [ 
	"Evaluate aBlock with each of my elements as the argument. Collect the resulting values into myself.
	Override superclass in order to work on the internal array directly."

	firstIndex to: lastIndex do: [ :index |
		array at: index put: (aBlock value: (array at: index)) ]
]

{ #category : #removing }
OrderedCollection >> reset [
	"Quickly remove all elements. The objects will be still referenced, but will not be 	accessible."
	
	self resetTo: 1
]

{ #category : #removing }
OrderedCollection >> resetTo: index [
	"Quickly remove all elements. The objects will be still referenced, but will not be 	accessible. Also make sure that the first object will be inserted at index. Choosing the 	right value has had great impact on performance, but it's neglible with the current 	implementation, so it's better to use #reset instead in most cases."
	
	firstIndex := index.
	lastIndex := firstIndex - 1
]

{ #category : #enumerating }
OrderedCollection >> reverseDo: aBlock [ 
	"Override the superclass for performance reasons."
	
	lastIndex to: firstIndex by: -1 do: [ :index |
		aBlock value: (array at: index) ]
]

{ #category : #enumerating }
OrderedCollection >> select: aBlock [ 
	"Evaluate aBlock with each of my elements as the argument. Collect into
	a new collection like the receiver, only those elements for which aBlock
	evaluates to true."

	| newCollection element |
	newCollection := self copyEmpty.
	firstIndex to: lastIndex do:
		[:index |
		(aBlock value: (element := array at: index))
			ifTrue: [newCollection addLast: element]].
	^ newCollection
]

{ #category : #private }
OrderedCollection >> setCollection: anArray [
	array := anArray.
	self reset
]

{ #category : #private }
OrderedCollection >> setContents: anArray [
	array := anArray.
	firstIndex := 1.
	lastIndex := array size.
]

{ #category : #accessing }
OrderedCollection >> size [
	"Answer how many elements the receiver contains."

	^ lastIndex - firstIndex + 1
]

{ #category : #sorting }
OrderedCollection >> sort [
	"Sort this array into ascending order using the '<=' operator."

	self sort: nil
]

{ #category : #sorting }
OrderedCollection >> sort: aSortBlock [ 
	"Sort this collection using aSortBlock. The block should take two arguments and return true if the first element should preceed the second one. If aSortBlock is nil then <= is used for comparison."

	self size <= 1 ifTrue: [ ^self ].
	array
		mergeSortFrom: firstIndex
		to: lastIndex
		by: aSortBlock
]

{ #category : #sorting }
OrderedCollection >> sorted: aSortBlockOrNil [
	"Return a new sequenceable collection which contains the same elements as self but its elements are sorted by aSortBlockOrNil. The block should take two arguments and return true if the first element should preceed the second one. If aSortBlock is nil then <= is used for comparison."
	
	^self copy sort: aSortBlockOrNil
]

{ #category : #enumerating }
OrderedCollection >> with: otherCollection collect: twoArgBlock [ 
	"Collect and return the result of evaluating twoArgBlock with 
	corresponding elements from this collection and otherCollection."

	| result offset size |
	(size := self size) = otherCollection size ifFalse: [ self error: 'otherCollection must be the same size' ].
	result := OrderedCollection new: size.
	offset := 1 - firstIndex.
	firstIndex to: lastIndex do: [ :index |
		result addLast: (
			twoArgBlock 
				value: (array at: index)
				value: (otherCollection at: index + offset)) ].
	^result
]

{ #category : #enumerating }
OrderedCollection >> withIndexCollect: elementAndIndexBlock [ 
	"Just like with:collect: except that the iteration index supplies the second argument to the block. Override superclass in order to use addLast:, not at:put:."

	| newCollection offset |
	newCollection := OrderedCollection new: self size.
	offset := 1 - firstIndex.
	firstIndex to: lastIndex do:
		[:index |
		newCollection addLast: (elementAndIndexBlock
			value: (array at: index)
			value: index + offset) ].
	^ newCollection
]
