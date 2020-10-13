"
I represent a collection of objects ordered by some property of the objects themselves. The ordering is specified in a two argument BlockClosure. The default sorting function is a <= comparison on elements.
"
Class {
	#name : #SortedCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'sortBlock'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #'instance creation' }
SortedCollection class >> sortBlock: aBlock [ 
	"Answer an instance of me such that its elements are sorted according to 
	the criterion specified in aBlock."

	^(super new: 10) sortBlock: aBlock
]

{ #category : #comparing }
SortedCollection >> = aSortedCollection [
	"Answer true if my and aSortedCollection's species are the same,
	and if our blocks are the same, and if our elements are the same."

	self species = aSortedCollection species ifFalse: [^ false].
	sortBlock = aSortedCollection sortBlock
		ifTrue: [^ super = aSortedCollection]
		ifFalse: [^ false]
]

{ #category : #adding }
SortedCollection >> add: newObject [
	^ super insert: newObject before: (self indexForInserting: newObject)
]

{ #category : #adding }
SortedCollection >> addAll: aCollection [
	aCollection size > (self size // 3)
		ifTrue:
			[aCollection do: [:each | self addLast: each].
			self reSort]
		ifFalse: [aCollection do: [:each | self add: each]].
	^ aCollection
]

{ #category : #adding }
SortedCollection >> addFirst: newObject [
	self shouldNotImplement
]

{ #category : #accessing }
SortedCollection >> at: anInteger put: anObject [
	self shouldNotImplement
]

{ #category : #adding }
SortedCollection >> copyEmpty [
	"Answer a copy of the receiver without any of the receiver's elements."

	^self species sortBlock: sortBlock
]

{ #category : #private }
SortedCollection >> indexForInserting: newObject [

	| index low high |
	low := firstIndex.
	high := lastIndex.
	sortBlock
		ifNil: [ 
			[ low > high ] whileFalse: [ 
				index := (high + low) // 2.
				(array at: index) <= newObject
					ifTrue: [ low := index + 1 ]
					ifFalse: [ high := index - 1 ] ] ]
		ifNotNil: [ 
			[ low > high ] whileFalse: [ 
				index := (high + low) // 2.
				(sortBlock value: (array at: index) value: newObject)
					ifTrue: [ low := index + 1 ]
					ifFalse: [ high := index - 1 ] ] ].
	^low
]

{ #category : #private }
SortedCollection >> insert: anObject before: spot [
	self shouldNotImplement
]

{ #category : #accessing }
SortedCollection >> median [
	"Return the middle element, or as close as we can get."

	^ self at: self size + 1 // 2
]

{ #category : #private }
SortedCollection >> reSort [

	firstIndex < lastIndex ifTrue: [ 
		array quickSortFrom: firstIndex to: lastIndex by: sortBlock ]
]

{ #category : #converting }
SortedCollection >> reverseInPlace [
	"Change this colleciton into its reversed.
	Do not make a copy like reversed do, but change self in place."
	
	| newFirstIndex |
	newFirstIndex := 1 + array size - lastIndex.
	lastIndex := 1 + array size - firstIndex.
	firstIndex := newFirstIndex.
	array := array reversed.
	sortBlock := sortBlock
		ifNil: [ [ :a :b | b <= a ] ]
		ifNotNil: [ [ :a :b | sortBlock value: b value: a ] ]
]

{ #category : #converting }
SortedCollection >> reversed [
	"Answer a collection that Sort elements in reverse order"
	
	^self shallowCopy reverseInPlace
]

{ #category : #private }
SortedCollection >> should: a precede: b [

	^sortBlock ifNil: [a <= b] ifNotNil: [sortBlock value: a value: b]

]

{ #category : #sorting }
SortedCollection >> sort: aSortBlock [ 
	"Sort this collection using aSortBlock. The block should take two arguments
	and return true if the first element should preceed the second one.
	If aSortBlock is nil then <= is used for comparison."

	super sort: aSortBlock.
	sortBlock := aSortBlock
]

{ #category : #accessing }
SortedCollection >> sortBlock [
	"Answer the blockContext which is the criterion for sorting elements of 
	the receiver."

	^sortBlock
]

{ #category : #accessing }
SortedCollection >> sortBlock: aBlock [ 
	"Make the argument, aBlock, be the criterion for ordering elements of the 
	receiver."

	sortBlock := aBlock.
	"sortBlocks with side effects may not work right"
	self size > 1 ifTrue: [self reSort]
]

{ #category : #'topological sort' }
SortedCollection >> sortTopologically [
	"Plenty of room for increased efficiency in this one."

	| remaining result pick |
	remaining := self asOrderedCollection.
	result := OrderedCollection new.
	[remaining isEmpty] whileFalse: [
		pick := remaining select: [:item |
			remaining allSatisfy: [:anotherItem |
				item == anotherItem or: [self should: item precede: anotherItem]]].
		pick isEmpty ifTrue: [self error: 'bad topological ordering'].
		result addAll: pick.
		remaining removeAll: pick].
	^self copySameFrom: result
]
