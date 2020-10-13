"
I am an ordered dictionary. I have an additional index (called 'order') to keep track of the insertion order of my associations.

The read access is not affected by the additional index.

The index is updated in O(1) [time] when inserting new keys. For present keys, that insertion involves actions in O(n) to move the respective element to the end of the order.

The growth operation compacts the index and takes O(n) additional time.

NOTE: This is still no instance of SequenceableCollection. Having this, some protocols are missing and may require working on #associations, which is an Array and thus sequenceable.
"
Class {
	#name : #OrderedDictionary,
	#superclass : #Dictionary,
	#instVars : [
		'order'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #enumerating }
OrderedDictionary >> associationsDo: aBlock [
	"Iterate over the order instead of the internal array."

	order from: 1 to: tally do: aBlock
]

{ #category : #accessing }
OrderedDictionary >> atIndex: integer [

	integer > tally ifTrue: [ self error: 'indices are out of bounds' ].
	^order at: integer
]

{ #category : #accessing }
OrderedDictionary >> atIndex: integer ifAbsent: exceptionBlock [
	"As we are sequenceable, provide index-based access."

	integer > tally ifTrue: [ ^exceptionBlock value ].
	^order at: integer ifAbsent: exceptionBlock
]

{ #category : #private }
OrderedDictionary >> atNewIndex: index put: anObject [

	super atNewIndex: index put: anObject.
	order at: tally put: anObject
	
]

{ #category : #copying }
OrderedDictionary >> copyFrom: startIndex to: endIndex [ 
	"Answer a copy of the receiver that contains elements from position
	startIndex to endIndex."

	^ self shallowCopy postCopyFrom: startIndex to: endIndex
]

{ #category : #accessing }
OrderedDictionary >> eighth [
	"Answer the eighth element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 8
]

{ #category : #accessing }
OrderedDictionary >> fifth [
	"Answer the fifth element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 5
]

{ #category : #accessing }
OrderedDictionary >> first [
	"Answer the first element of the receiver"

	^ self atIndex: 1
]

{ #category : #accessing }
OrderedDictionary >> first: n [
	"Answer the first n elements of the receiver.
	Raise an error if there are not enough elements."

	^ self copyFrom: 1 to: n
]

{ #category : #accessing }
OrderedDictionary >> fourth [
	"Answer the fourth element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 4
]

{ #category : #private }
OrderedDictionary >> growTo: anInteger [

	| oldOrder |
	super growTo: anInteger.
	oldOrder := order.
	"Grow only to 75%. See #atNewIndex:put: in HashedCollection."
	order := self class arrayType new: anInteger + 1 * 3 // 4.
	order
		replaceFrom: 1
		to: tally
		with: oldOrder
		startingAt: 1
]

{ #category : #private }
OrderedDictionary >> initialize: n [

	super initialize: n.
	order := self class arrayType new: n + 1 * 3 // 4
]

{ #category : #sorting }
OrderedDictionary >> isSorted [
	"Return true if the receiver is sorted by #<=."
	
	^ order
		isSortedBetween: 1
		and: tally
]

{ #category : #accessing }
OrderedDictionary >> keysInOrder [
	"Overridden.  Preserve the order of the receiver."
	^ self keys
]

{ #category : #accessing }
OrderedDictionary >> last [
	"Answer the last element of the receiver"

	^ self atIndex: self size
]

{ #category : #accessing }
OrderedDictionary >> last: n [
	"Answer the last n elements of the receiver.  
	Raise an error if there are not enough elements."

	| size |
	size := self size.
	^ self copyFrom: size - n + 1 to: size
]

{ #category : #accessing }
OrderedDictionary >> ninth [
	"Answer the ninth element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 9
]

{ #category : #copying }
OrderedDictionary >> postCopy [
	"We must not copy associations again but retrieve them from the array, which is already a copy. See super."

	super postCopy.
	order := order copy.
	1 to: tally do: [ :index |
		order at: index put: (array at: (self scanFor: (order at: index) key)) ]
]

{ #category : #copying }
OrderedDictionary >> postCopyFrom: startIndex to: endIndex [
	"Adapted from SequenceableCollection and OrderedCollection."

	| oldOrder |	
	oldOrder := order.
	array := self class arrayType
		new: (self class goodPrimeAtLeast: endIndex - startIndex + 1 * 4 // 3). "fill 75% to 100%"
	order := self class arrayType
		new: array size + 1 * 3 // 4. "remove 25%"

	startIndex to: endIndex do: [:index | | element |
		element := (oldOrder at: index) copy.
		order at: index - startIndex + 1 put: element.
		array at: (self scanFor: element key) put: element].

	tally := endIndex - startIndex + 1.
]

{ #category : #removing }
OrderedDictionary >> removeKey: key ifAbsent: aBlock [

	| result |
	result := super removeKey: key ifAbsent: [ ^aBlock value ].
	(self scanOrderFor: key) ifNotNil: [ :index |
		order 
			replaceFrom: index
			to: tally
			with: order
			startingAt: index + 1 ].
.	order at: tally + 1 put: nil.
	^result
]

{ #category : #private }
OrderedDictionary >> scanOrderFor: anObject [

	1 to: tally do: [ :index |
		(order at: index) key = anObject ifTrue: [ ^index ] ].
	^nil
]

{ #category : #accessing }
OrderedDictionary >> second [
	"Answer the second element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 2
]

{ #category : #accessing }
OrderedDictionary >> seventh [
	"Answer the seventh element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 7
]

{ #category : #accessing }
OrderedDictionary >> sixth [
	"Answer the sixth element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 6
]

{ #category : #sorting }
OrderedDictionary >> sort [

	self sort: nil
]

{ #category : #sorting }
OrderedDictionary >> sort: aSortBlock [
	"Like in OrderedCollection, sort the associations according to the sort block."

	tally <= 1 ifTrue: [ ^self ].
	order
		mergeSortFrom: 1
		to: tally
		by: aSortBlock
]

{ #category : #sorting }
OrderedDictionary >> sorted: aSortBlockOrNil [

	^ self copy sort: aSortBlockOrNil
]

{ #category : #accessing }
OrderedDictionary >> third [
	"Answer the third element of the receiver.
	Raise an error if there are not enough elements."

	^ self atIndex: 3
]
