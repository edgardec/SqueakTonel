"
These test cases demonstrate addition of items into an OrderedCollection as well as item removal.

Some of the assertions are quite complicated and use a lot of collection protocol. Such methods do not test one single method, but protocol in general.
"
Class {
	#name : #OrderedCollectionTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAdd [
	| l |
	l := #(1 2 3 4) asOrderedCollection.
	l add: 88.
	self assert: (l =  #(1 2 3 4 88) asOrderedCollection).
	l add: 99.
	self assert: (l =  #(1 2 3 4 88 99) asOrderedCollection). 


]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddAfter [

	| l |
	l := #(1 2 3 4) asOrderedCollection.
	l add: 88 after: 1.
	self assert: (l =  #(1 88 2 3 4) asOrderedCollection).
	l add: 99 after: 2.
	self assert: (l =  #(1 88 2 99 3 4) asOrderedCollection). 


]

{ #category : #'tests - public methods' }
OrderedCollectionTest >> testAddAfterIndex [
	"self run: #testAddAfterIndex"
	| l |
	l := #(1 2 3 4) asOrderedCollection.
	l add: 77 afterIndex: 0.
	self assert: (l =  #(77 1 2 3 4) asOrderedCollection).
	l add: 88 afterIndex: 2.
	self assert: (l =  #(77 1 88 2 3 4) asOrderedCollection). 
	l add: 99 afterIndex: l size.
	self assert: (l =  #(77 1 88 2 3 4 99) asOrderedCollection). 
	self should:[l add: 666 afterIndex: -1] raise: Error.
	self should:[l add: 666 afterIndex: l size+1] raise: Error.
	
	"Now make room by removing first two and last two elements,
	and see if the illegal bounds test still fails"
	(l first: 2) , (l last: 2) reversed do: [:e | l remove: e].
	self should: [l add: 666 afterIndex: -1] raise: Error.
	self should: [l add: 666 afterIndex: l size+1] raise: Error.
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddAll [
	"Allows one to add each element of an orderedCollection at the end of another
	orderedCollection "
	"self run:#testAddAll" 
	
	| c1 c2 |
	c1 := #(1 2 3 4 ) asOrderedCollection.
	c2 := #(5 6 7 8 9 ) asOrderedCollection.
	c1 addAll: c2.
	self assert: c1 = #(1 2 3 4 5 6 7 8 9) asOrderedCollection
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddAllFirst [
	"Allows one to add each element of an orderedCollection at the beginning of another
	orderedCollection "
	"self run:#testAddAllFirst" 
	
	| c1 c2 |
	c1 := #(1 2 3 4 ) asOrderedCollection.
	c2 := #(5 6 7 8 9 ) asOrderedCollection.
	c2 addAllFirst: c1.
	self assert: c2 = #(1 2 3 4 5 6 7 8 9) asOrderedCollection
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddAllFirstUnlessAlreadyPresent [
	"Allows one to add each element of an orderedCollection at the beginning of
	another orderedCollection preserving the order but no duplicate element"
	"self run:#testAddAllFirstUnlessAlreadyPresent" 
	
	| c1 c2 c3 |
	c1 := #(1 2 3 4 ) asOrderedCollection.
	c2 := #(5 6 7 8 9 ) asOrderedCollection.
	c3 := #(0 1 ) asOrderedCollection.
	c2 addAllFirstUnlessAlreadyPresent: c1.
	self assert: c2 = #(1 2 3 4 5 6 7 8 9 ) asOrderedCollection.
	c1 addAllFirstUnlessAlreadyPresent: c3.
	self deny: c1 = #(0 1 1 2 3 4 ) asOrderedCollection.
	self assert: c1 = #(0 1 2 3 4 ) asOrderedCollection.
	
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddAllLast [
	"Allows one to add each element of an orderedCollection at the beginning of another
	orderedCollection "
	"self run:#testAddAllLast" 
	
	| c1 c2 |
	c1 := #(1 2 3 4 ) asOrderedCollection.
	c2 := #(5 6 7 8 9 ) asOrderedCollection.
	c1 addAllLast: c2.
	self assert: c1 = #(1 2 3 4 5 6 7 8 9) asOrderedCollection
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddBefore [

	| l |
	l := #(1 2 3 4) asOrderedCollection.
	l add: 88 before: 1.
	self assert: (l =  #(88 1 2 3 4) asOrderedCollection).
	l add: 99 before: 2.
	self assert: (l =  #(88 1 99 2 3 4) asOrderedCollection). 


]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddBeforeAndRemove [

	| l initialCollection |
	l := #(1 2 3 4) asOrderedCollection.
	initialCollection := l shallowCopy.
	l add: 88 before: 1.
	self assert: (l =  #(88 1 2 3 4) asOrderedCollection).
	l add: 99 before: 2.
	self assert: (l =  #(88 1 99 2 3 4) asOrderedCollection). 
	l remove: 99.
	l remove: 88.
	self assert: l = initialCollection.


]

{ #category : #'tests - public methods' }
OrderedCollectionTest >> testAddBeforeIndex [
	"self run: #testAddBeforeIndex"
	| l |
	l := #(1 2 3 4) asOrderedCollection.
	l add: 77 beforeIndex: 1.
	self assert: (l =  #(77 1 2 3 4) asOrderedCollection).
	l add: 88 beforeIndex: 3.
	self assert: (l =  #(77 1 88 2 3 4) asOrderedCollection). 
	l add: 99 beforeIndex: l size+1.
	self assert: (l =  #(77 1 88 2 3 4 99) asOrderedCollection). 
	self should:[l add: 666 beforeIndex: 0] raise: Error.
	self should:[l add: 666 beforeIndex: l size+2] raise: Error.
	
	"Now make room by removing first two and last two elements,
	and see if the illegal bounds test still fails"
	(l first: 2) , (l last: 2) reversed do: [:e | l remove: e].
	self should:[l add: 666 beforeIndex: 0] raise: Error.
	self should:[l add: 666 beforeIndex: l size+2] raise: Error.


]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddDuplicateItem1 [
	| collection |
	collection := #('Jim' 'Mary' 'John' 'Andrew' ) asOrderedCollection.
	collection add: 'John' before: 'John'.
	self
		assert: ((collection asBag occurrencesOf: 'John')
					= 2
				and: [(collection at: (collection indexOf: 'John')
							+ 1)
						= (collection
								at: (collection indexOf: 'John'))])
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddFirst [
	| l |
	l := #(1 2 3 4) asOrderedCollection.
	l addFirst: 88.
	self assert: (l =  #(88 1 2 3 4) asOrderedCollection).
	l addFirst: 99.
	self assert: (l =  #(99 88 1 2 3 4) asOrderedCollection). 


]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddItem1 [

   | collection size |
   collection := #('Jim' 'Mary' 'John' 'Andrew' ) asOrderedCollection.
   size := collection size.
   collection add: 'James' before: 'Jim'.
   collection add: 'Margaret' before: 'Andrew'.
   self assert: size + 2 = collection size.

]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddItem2 [
	| collection |
	collection := #('Jim' 'Mary' 'John' 'Andrew' ) asOrderedCollection.
	collection add: 'James' before: 'Jim'.
	collection add: 'Margaret' before: 'Andrew'.
	self assert: (collection indexOf: 'James')
			+ 1
			= (collection indexOf: 'Jim').
	self assert: (collection indexOf: 'Margaret')
			+ 1
			= (collection indexOf: 'Andrew')
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAddLast [
	| l |
	l := #(1 2 3 4) asOrderedCollection.
	l addLast: 88.
	self assert: (l =  #(1 2 3 4 88) asOrderedCollection).
	l addLast: 99.
	self assert: (l =  #(1 2 3 4 88 99) asOrderedCollection). 


]

{ #category : #'tests - accessing' }
OrderedCollectionTest >> testAt [
	| collection |
	collection := #('Jim' 'Mary' 'John' 'Andrew' ) asOrderedCollection.
	self assert: (collection at:1) = 'Jim'.
	self assert: (collection at:2) = 'Mary'
]

{ #category : #'tests - adding' }
OrderedCollectionTest >> testAtIfAbsentPut [
	"Allows one to add an element at an index if no element exist at this index"
	"self run:#testAtIfAbsentPut" 
	
	| c |
	c := #(1 2 3 4 ) asOrderedCollection.
	c at: 2 ifAbsentPut: [5].
	self assert: #(1 2 3 4 ) asOrderedCollection equals: c.
	c at: 5 ifAbsentPut: [5].
	self assert: #(1 2 3 4 5 ) asOrderedCollection equals: c.
	c at: 7 ifAbsentPut: [7].
	self assert: #(1 2 3 4 5 nil 7 ) asOrderedCollection equals: c.
]

{ #category : #'tests - accessing' }
OrderedCollectionTest >> testAtPut [
	"Allows one to replace an element but not at an off range index"
	"self run:#testAtPut"
	| c |
	c := #(1 2 3 4 ) asOrderedCollection.
	c at: 2 put: 5.
	self assert: c = #(1 5 3 4 ) asOrderedCollection.
	self
		should: [c at: 5 put: 8]
		raise: Error.
	self deny: c = #(1 5 3 4 8 ) asOrderedCollection
]

{ #category : #'tests - accessing' }
OrderedCollectionTest >> testCapacity [
	"Allows one to check the current capacity of an Ordered collection"
	"self run:#testCapacity"
	
	| c1 c2 c3 |
	c1 := #(1 2 ) asOrderedCollection.
	self assert: (c1 capacity =  2).
	c2 := OrderedCollection new: 10.
	c2 add: 3.
	self assert: (c2 capacity = 10).	
	c3 := OrderedCollection new.
	self deny: (c3 capacity =  0).
	
]

{ #category : #'tests - enumerating' }
OrderedCollectionTest >> testCollect [
	"Allows one to collect some element of a collection into another collection"
	"self run: #testCollect"
	 
	| c1 c2 res |
	c1 := #(-1 2 -3 4) asOrderedCollection.
	c2 := #(1 2 3 4) asOrderedCollection.
	res := c1 collect: [:each | each abs].
	self assert: (c2 = res).
]

{ #category : #'tests - enumerating' }
OrderedCollectionTest >> testCollectFromTo [
	"Allows one to collect some element of a collection into another collection between a first index and an end index for the collect"
	"self run: #testCollectFromTo"
	
	| c1 res |
	c1 := #(-1 2 -3 4 -5 6 -7 8) asOrderedCollection.
	res := c1 collect: [:each | each abs] from: 1 to: 3.
	self assert: (res = #(1 2 3) asOrderedCollection).
	self should: [c1 collect: [:each | each abs] from: 10 to: 13] raise: Error.
	self should: [c1 collect: [:each | each abs] from: 5 to: 2] raise: Error.
]

{ #category : #'tests - copying' }
OrderedCollectionTest >> testCopyEmpty [
	"Allows one to create a copy of the receiver that contains no elements"
	"self run:#testCopyEmpty"
	
	| c1 c2 |
	c1 := #(1 2 3 4 ) asOrderedCollection.
	c2 := c1 copyEmpty.
	self assert: (c2 size = 0).
]

{ #category : #'tests - copying' }
OrderedCollectionTest >> testCopyFromTo [
	"Allows one to create a copy of the receiver that contains elements from position start to end"
	"self run: #testCopyFromTo"
	
	| c1 c2 c3 | 
	c1 := #(1 2 3 4) asOrderedCollection.
	c2 := (c1 copyFrom: 1 to: 2).
	self assert: c2 = #(1 2) asOrderedCollection.
	self should: [c1 copyFrom: 10 to: 20] raise: Error.
	
	c3 := c1 copyFrom: 4 to: 2.
	self assert: c3 isEmpty.
	
	self should: [c1 copyFrom: 4 to: 5 ] raise: Error.
	
	
	

]

{ #category : #'tests - copying' }
OrderedCollectionTest >> testCopyReplaceFromToWith [
	"Allows one to create a copy from the receiver which elements between start and end of the 	receiver being replace by 	element of the collection after with:"
	"self run:#testCopyReplaceFromToWith"

	| c1 c2 c3 c4 |
	c1 := #(1 2 3 4) asOrderedCollection.
	c2 := #(5 6 7 8 9) asOrderedCollection.
	c3 := (c2 copyReplaceFrom: 1 to: 2 with: c1).
	self assert: c3 = #(1 2 3 4 7 8 9) asOrderedCollection.
	self should: [c2 copyReplaceFrom: 3 to: 1 with: c1] raise: Error.
	
	c4 := (c2 copyReplaceFrom: 10 to: 25 with: c1).
	self assert: c4 = #(5 6 7 8 9 1 2 3 4) asOrderedCollection.
	
	
]

{ #category : #'tests - copying' }
OrderedCollectionTest >> testCopyWith [
	"Allows one to create a copy of the receiver that contains the new element at the end"
	"self run: #testCopyWith"
	
	| c1 | 
	c1 := #(1 2 3 4) asOrderedCollection.
	c1 := c1 copyWith: 6.
	self assert: c1 = #(1 2 3 4 6) asOrderedCollection.
	
	

	
	
	

]

{ #category : #'tests - copying' }
OrderedCollectionTest >> testForceToPadding [
	"This is a non regression bug for http://bugs.squeak.org/view.php?id=7296"
	
	| c1 c2 paddingElement |
	"source collection"
	c1 := #(5 3 7 2 ) asOrderedCollection.
	paddingElement := nil.
	
	"force length to longer"
	c2 := c1 forceTo: 10 paddingWith: paddingElement.
	self assert: (c1 ~~ c2) description: 'forceTo:paddingWith: should modify a copy'.
	self assert: (c2 size = 10).
	self assert: (c2 copyFrom: 1 to: c1 size) = c1.
	self assert: ((c1 size + 1 to: c2 size) allSatisfy: [:i | (c2 at: i) = paddingElement]).
	
	"force length to shorter"
	c2 := c1 forceTo: 3 paddingWith: paddingElement.
	self assert: (c1 ~~ c2) description: 'forceTo:paddingWith: should modify a copy'.
	self assert: (c2 size = 3).
	self assert: (c2 copyFrom: 1 to: 3) = (c1 copyFrom: 1 to: 3).
	
	"SAME TEST BUT PADDING AT START FOLLOWING..."
	
	"force length to longer"
	c2 := c1 forceTo: 10 paddingStartWith: paddingElement.
	self assert: (c1 ~~ c2) description: 'forceTo:paddingStartWith: should modify a copy'.
	self assert: (c2 size = 10).
	self assert: (c2 copyFrom: c2 size - c1 size + 1 to: c2 size) = c1.
	self assert: ((1 to: c2 size - c1 size) allSatisfy: [:i | (c2 at: i) = paddingElement]).
	
	"force length to shorter"
	c2 := c1 forceTo: 3 paddingStartWith: paddingElement.
	self assert: (c1 ~~ c2) description: 'forceTo:paddingStartWith: should modify a copy'.
	self assert: (c2 size = 3).
	self assert: (c2 copyFrom: 1 to: 3) = (c1 copyFrom: 1 to: 3).
]

{ #category : #'tests - enumerating' }
OrderedCollectionTest >> testIndexOf [
	| collection indices |
	collection := #('Jim' 'Mary' 'John' 'Andrew' ) asOrderedCollection.
	indices := collection
				collect: [:item | collection indexOf: item].
	self assert: (1 to: 4) asOrderedCollection = indices
]

{ #category : #'tests - enumerating' }
OrderedCollectionTest >> testIndexOfWithDuplicates [

   | collection indices bagOfIndices |
   collection := #('Jim' 'Mary' 'John' 'Andrew' 'Mary' 'John' 'Jim' 'Micheal') asOrderedCollection.
   indices := collection collect: [:item | collection indexOf: item].
   self assert: indices asSet size = collection asSet size.
   bagOfIndices := indices asBag.
   self assert: (indices asSet 
                    allSatisfy: [:index | (bagOfIndices occurrencesOf: index)
	                                       = (collection occurrencesOf: (collection at: index))]).

  "  indexOf:  returns the index of the first occurrence of an item.
     For an item with n occurrences, the index of its first occurrence
     is found  n  times. "
]

{ #category : #'tests - enumerating' }
OrderedCollectionTest >> testOverlappingPairsCollect [

	| o |
	o := #(5 4 3 2 1) asOrderedCollection.
	self
		assert: #(9 7 5 3) asOrderedCollection
		equals: (o overlappingPairsCollect: [ :a :b | a + b ])
]

{ #category : #'tests - removing' }
OrderedCollectionTest >> testRemoveAll [
	"Allows one to remove all elements of a collection" 
	
	| c1 c2 s2 |
	c1 := #(2 3 4 6) asOrderedCollection.
	c1 addAll: (1 to: 200).
	c2 := c1 copy.
	s2 := c2 size.
	
	c1 removeAll.
	
	self assert: c1 size = 0.
	self assert: c2 size = s2 description: 'the copy has not been modified'
	
]

{ #category : #'tests - removing' }
OrderedCollectionTest >> testRemoveAllSuchThat [
	| collection |
	collection := (1 to: 10) asOrderedCollection.
	collection
		removeAllSuchThat: [:e | e even].
	self assert: collection = (1 to: 10 by: 2) asOrderedCollection
]

{ #category : #'tests - removing' }
OrderedCollectionTest >> testRemoveAt [
	"Allows one to remove an element from a collection at an index"
	"self run:#testRemoveAt" 
	
	| c1 |
	c1 := #(2 3 4 6) asOrderedCollection.
	c1 removeAt: 2.
	self assert: (c1 = #(2 4 6) asOrderedCollection).
	self should: [c1 removeAt: 10] raise: Error.
	self should: [c1 removeAt: -1] raise: Error.
	
]

{ #category : #'tests - removing' }
OrderedCollectionTest >> testRemoveFirst [
	"Allows one to remove n element of a collection at the first"
	"self run:#testRemoveFirst" 
	
	| c1 |
	c1 := #(2 3 4 6) asOrderedCollection.
	c1 removeFirst: 1.
	self assert: (c1 = #(3 4 6) asOrderedCollection).
	c1 removeFirst: 2.
	self assert: (c1 = #(6) asOrderedCollection).
	self should: [c1 removeFirst: 10] raise: Error.
	
	
]

{ #category : #'tests - removing' }
OrderedCollectionTest >> testRemoveIfAbsent [
	"Allows one to remove an element from a collection and to copy it in another collection."
	"If the element isn't in the first collection, the second collection copy the element after ifAbsent"
	"self run:#testRemoveIfAbsent"
	
	| c1 c2 |
	c1 := #(1 2 3 4) asOrderedCollection.
	c2 := OrderedCollection new.
	
	c2 add: (c1 remove: 2 ifAbsent: [6]).
	self assert: (c1 = #(1 3 4) asOrderedCollection).
	self assert: (c2 = #(2) asOrderedCollection).
	
	c2 add: (c1 remove: 18 ifAbsent: [6]).
	self assert: (c1 = #(1 3 4) asOrderedCollection).
	self assert: (c2 = #(2 6) asOrderedCollection).
]

{ #category : #'tests - removing' }
OrderedCollectionTest >> testRemoveLast [
	"Allows one to remove n element of a collection at the end"
	"self run:#testRemoveLast" 
	
	| c1 |
	c1 := #(2 3 4 6) asOrderedCollection.
	c1 removeLast: 1.
	self assert: (c1 = #(2 3 4) asOrderedCollection).
	c1 removeLast: 2.
	self assert: (c1 = #(2) asOrderedCollection).
	self should: [c1 removeLast: 10] raise: Error.
]

{ #category : #'tests - copying' }
OrderedCollectionTest >> testReversed [
	| collection1 collection2 |
	collection1 := #('Jim' 'Mary' 'John' 'Andrew' ) asOrderedCollection.
	collection2 := collection1 reversed.
	self assert: collection2 first = 'Andrew'.
	self assert: collection2 last = 'Jim'
]

{ #category : #'tests - accessing' }
OrderedCollectionTest >> testSize [
	"Allows one to check the size of an Ordered collection"
	"self run:#testSize"
	
	| c1 c2 |
	c1 := #(1 2 ) asOrderedCollection.
	self assert: (c1 size =  2).
	
	c2 := OrderedCollection new.
	self assert: (c2 size = 0)
	
]

{ #category : #'tests - streaming' }
OrderedCollectionTest >> testStreamContents [
	| oc |
	self shouldnt: [oc := OrderedCollection streamContents: [:stream | 1 to: 3 do: [:i | stream nextPut: i]]]
		raise: Error
		description: 'it should be possible to stream over an OrderedCollection'.
	self assert: oc class = OrderedCollection.
	self assert: oc = (1 to: 3) asOrderedCollection.
]

{ #category : #'tests - enumerating' }
OrderedCollectionTest >> testWithCollect [
	"Allows one to collect some element of two collections into another collection with element corresponding to the condition in the blocks"
	"self run: #testWithCollect"
	
	| c1 c2 res |
	c1 := #(-1 2 -3 4 -5 6 -7 8) asOrderedCollection.
	c2 := #(-9 10 -11 12 -13 14 -15 16) asOrderedCollection.
	res := c1 with: c2 collect: [:each1 :each2 | each1 < each2
		ifTrue: [each1]
		ifFalse: [each2]].
	self assert: (res = #(-9 2 -11 4 -13 6 -15 8) asOrderedCollection).
	
]
