"
I am an OrderedCollection with an internal array holding non-pointers objects. This has the advantage that the array is never subject of garbage collection. But I can only hold objects of a given type defined by my class-side #arrayType method, which is the only method they have to implement.
"
Class {
	#name : #NonPointersOrderedCollection,
	#superclass : #OrderedCollection,
	#category : #'Collections-Sequenceable'
}

{ #category : #testing }
NonPointersOrderedCollection class >> isAbstract [
	^self = NonPointersOrderedCollection
]

{ #category : #private }
NonPointersOrderedCollection >> arrayType [
	"This method must return a non-pointers array class."

	self subclassResponsibility
]

{ #category : #private }
NonPointersOrderedCollection >> makeRoomAtFirst [
	"Same as super without trying to store nil in the emptied slots of array."
	
	| tally newFirstIndex newLastIndex capacity |
	tally := self size.
	capacity := array size.
	tally * 2 >= capacity ifTrue: [ ^self growAtFirst ].
	tally = 0 ifTrue: [ ^self resetTo: capacity + 1 ].
	newFirstIndex := capacity // 2 + 1.
	newLastIndex := newFirstIndex - firstIndex + lastIndex.
	0 to: tally - 1 do: [ :offset |
		array at: newLastIndex - offset put: (array at: lastIndex - offset) ].
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : #private }
NonPointersOrderedCollection >> makeRoomAtLast [
	"Same as super without trying to store nil in the emptied slots of array."
	
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
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : #removing }
NonPointersOrderedCollection >> removeAllSuchThat: aBlock [ 
	"Same as super without trying to store nil in the emptied slots of array."

	| n |
	n := firstIndex.
	firstIndex to: lastIndex do: [ :index |
		| element |
		(aBlock value: (element := array at: index)) ifFalse: [
			array at: n put: element.
			n := n + 1 ] ].
	lastIndex := n - 1
]

{ #category : #removing }
NonPointersOrderedCollection >> removeFirst [
	"Same as super without trying to store nil in the emptied slot of array."

	| firstObject |
	firstIndex > lastIndex ifTrue: [ self errorEmptyCollection ].
	firstObject := array at: firstIndex.
	firstIndex := firstIndex + 1.
	^firstObject
]

{ #category : #removing }
NonPointersOrderedCollection >> removeFirst: n [ 
	"Same as super without trying to store nil in the emptied slots of array."

	| lastIndexToRemove result |
	n < 1 ifTrue: [ self errorNoSuchElement ].
	lastIndex < (lastIndexToRemove := firstIndex + n - 1) ifTrue: [ self errorNotEnoughElements ].
	result := array copyFrom: firstIndex to: lastIndexToRemove.
	firstIndex := lastIndexToRemove + 1.
	^result
]

{ #category : #private }
NonPointersOrderedCollection >> removeIndex: removedIndex [
 	"Same as super without trying to store nil in the emptied slot of array."

	array 
		replaceFrom: removedIndex 
		to: lastIndex - 1 
		with: array 
		startingAt: removedIndex + 1.
	lastIndex := lastIndex - 1.
]

{ #category : #removing }
NonPointersOrderedCollection >> removeLast [
	"Same as super without trying to store nil in the emptied slot of array."
	
	| lastObject |
	firstIndex > lastIndex ifTrue: [ self errorEmptyCollection ].
	lastObject := array at: lastIndex.
	lastIndex := lastIndex - 1.
	^ lastObject
]

{ #category : #removing }
NonPointersOrderedCollection >> removeLast: n [
	"Same as super without trying to store nil in the emptied slots of array."

	| firstIndexToRemove result |
	n < 1 ifTrue: [ self errorNoSuchElement ].
	(firstIndexToRemove := lastIndex - n + 1) < firstIndex ifTrue: [ self errorNotEnoughElements ].
	result := array copyFrom: firstIndexToRemove to: lastIndex.
	lastIndex := firstIndexToRemove - 1.
	^result
]
