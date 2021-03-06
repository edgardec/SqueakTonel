Class {
	#name : #BagTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Unordered'
}

{ #category : #'tests - basic' }
BagTest >> testAdd [
	"self run: #testAdd"
	"self debug: #testAdd"

	| aBag |
	aBag := Bag new.
	aBag add: 'a'.
	aBag add: 'b'.
	
	self assert: aBag size = 2.
	aBag add: 'a'.
	self assert: aBag size = 3.
	self assert: (aBag occurrencesOf: 'a') = 2
	

]

{ #category : #'tests - basic' }
BagTest >> testAddWithOccurrences [
	"self debug:#testAddWithOccurrences"
	
	| aBag |
 	aBag := Bag new.	
	aBag add: 'a' withOccurrences: 3.
	self assert: (aBag size = 3).
	
	
	
	
		

]

{ #category : #'tests - basic' }
BagTest >> testAsBag [

	| aBag |
 
	aBag := Bag new.	
	
	self assert: aBag asBag = aBag.
]

{ #category : #'tests - basic' }
BagTest >> testAsSet [

	| aBag aSet |
	aBag := Bag new.	
	aBag add:'a' withOccurrences: 4.
	aBag add:'b' withOccurrences: 2.
	aSet := aBag asSet.
	self assert: aSet size = 2.
	self assert: (aSet occurrencesOf: 'a') = 1 
	
]

{ #category : #'tests - basic' }
BagTest >> testCopy [
	"self run: #testCopy"
	
	| aBag newBag |
	aBag := Bag new.
	aBag add:'a' withOccurrences: 4.
	aBag add:'b' withOccurrences: 2.
	newBag := aBag copy.
	self assert: newBag = aBag.
	self assert: newBag asSet size = 2.
]

{ #category : #tests }
BagTest >> testCreation [
	"self run: #testCreation"
	"self debug: #testCreation"
		
	| bag |
	bag := Bag new.
	self assert: (bag size) = 0.
	self assert: (bag isEmpty).
	

]

{ #category : #tests }
BagTest >> testCumulativeCounts [
	"self run: #testCumulativeCounts"
	"self debug: #testCumulativeCounts"
		
	| bag cumulativeCounts |
	bag := Bag new.
	bag add: '1' withOccurrences: 50.
	bag add: '2' withOccurrences: 40.
	bag add: '3' withOccurrences: 10.
	
	cumulativeCounts := bag cumulativeCounts.
	
	self assert: cumulativeCounts size = 3.
	self assert: cumulativeCounts first = (50 -> '1').
	self assert: cumulativeCounts second = (90 -> '2').
	self assert: cumulativeCounts third = (100 -> '3').

]

{ #category : #tests }
BagTest >> testEqual [
	"(self run: #testEqual)"
	"(self debug: #testEqual)"
	| bag1 bag2 |
	bag1 := Bag new.
	bag2 := Bag new.
	self assert: bag1 = bag2.
	bag1 add: #a;
		 add: #b.
	bag2 add: #a;
		 add: #a.
	self deny: bag1 = bag2.
	self assert: bag1 = bag1.
	bag1 add: #a.
	bag2 add: #b.
	self assert: bag1 = bag2.
	bag1 add: #c.
	self deny: bag1 = bag2.
	bag2 add: #c.
	self assert: bag1 = bag2
]

{ #category : #'tests - basic' }
BagTest >> testOccurrencesOf [
	"self debug: #testOccurrencesOf"

	| aBag |
 	aBag := Bag new.	
	aBag add: 'a' withOccurrences: 3.
	aBag add: 'b'.
	aBag add: 'b'.
	aBag add: 'b'.
	aBag add: 'b'.	
	self assert: (aBag occurrencesOf:'a') = 3.
	self assert: (aBag occurrencesOf:'b') = 4.
	self assert: (aBag occurrencesOf:'c') = 0.
	self assert: (aBag occurrencesOf: nil) =0.
	aBag add: nil.
	self assert: (aBag occurrencesOf: nil) =1.
	
]

{ #category : #tests }
BagTest >> testRemove [
	"self run: #testRemove"
	"self debug: #testRemove"
	
	| bag item |
	item := 'test item'.
	bag := Bag new.
	
	bag add: item.
	self assert: (bag size) = 1.
	bag remove: item.
	self assert: bag isEmpty.
	
	bag add: item withOccurrences: 2.
	bag remove: item.
	bag remove: item.
	self assert: (bag size) = 0.
	
	self should: [bag remove: item.] raise: Error.
]

{ #category : #tests }
BagTest >> testRemoveAll [
	"Allows one to remove all elements of a collection" 
	
	| c1 c2 s2 |
	c1 := #(10 9 8 7 5 4 4 2) asBag.
	c2 := c1 copy.
	s2 := c2 size.
	
	c1 removeAll.
	
	self assert: c1 size = 0.
	self assert: c2 size = s2 description: 'the copy has not been modified'.
]

{ #category : #tests }
BagTest >> testSortedCounts [
	"self run: #testSortedCounts"
	"self debug: #testSortedCounts"
	
	| bag sortedCounts|
	bag := Bag new.
	bag add: '1' withOccurrences: 10.
	bag add: '2' withOccurrences: 1.
	bag add: '3' withOccurrences: 5.
	
	sortedCounts := bag sortedCounts.
	self assert: sortedCounts size = 3.
	
	self assert: sortedCounts first = (10->'1').
	self assert: sortedCounts second =  (5->'3').
	self assert: sortedCounts third =  (1->'2').	
]

{ #category : #tests }
BagTest >> testSortedElements [
	"self run: #testSortedElements"
	"self debug: #testSortedElements"
	
	| bag sortedElements|
	bag := Bag new.
	bag add: '2' withOccurrences: 1.
	bag add: '1' withOccurrences: 10.
	bag add: '3' withOccurrences: 5.
	
	sortedElements := bag sortedElements.
	
	self assert: sortedElements size = 3.
	
	self assert: sortedElements first = ('1'->10).
	self assert: sortedElements second =  ('2'->1).
	self assert: sortedElements third =  ('3'->5).
	
]
