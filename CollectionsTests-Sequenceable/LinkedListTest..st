"
A set of test cases which thoroughly test functionality of the LinkedList class.
"
Class {
	#name : #LinkedListTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'nextLink',
		'n',
		'list',
		'link1',
		'link2',
		'link3',
		'link4',
		'nonEmpty',
		'otherList',
		'link',
		'collectionWithNil',
		'collectionWithoutNil',
		'nonEmpty1Element',
		'collectionWithoutEqualElements',
		'elementNotIn',
		'elementIn',
		'sameAtendAndBegining',
		'collection5Elements',
		'collectResult'
	],
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #requirements }
LinkedListTest >> accessCollection [
	^collectionWithoutEqualElements 
]

{ #category : #requirements }
LinkedListTest >> anotherElementNotIn [
" return an element included  in 'collection' "
	^ elementNotIn 
]

{ #category : #requirements }
LinkedListTest >> anotherElementOrAssociationIn [
	" return an element (or an association for Dictionary ) present  in 'collection' "
	^ self collection anyOne
]

{ #category : #requirements }
LinkedListTest >> anotherElementOrAssociationNotIn [
	" return an element (or an association for Dictionary )not present  in 'collection' "
	^ elementNotIn 
]

{ #category : #'tests - converting' }
LinkedListTest >> assertNoDuplicates: aCollection whenConvertedTo: aClass [ 
	| result |
	result := self collectionWithEqualElements asIdentitySet.
	self assert: (result class includesBehavior: IdentitySet).
	self collectionWithEqualElements do: [ :initial | self assert: (result occurrencesOf: initial) = 1 ]
]

{ #category : #'tests - converting' }
LinkedListTest >> assertNonDuplicatedContents: aCollection whenConvertedTo: aClass [ 
	| result |
	result := aCollection perform: ('as' , aClass name) asSymbol.
	self assert: (result class includesBehavior: aClass).
	result do: 
		[ :each | 
		self assert: (aCollection occurrencesOf: each) = (result occurrencesOf: each) ].
	^ result
]

{ #category : #'tests - converting' }
LinkedListTest >> assertSameContents: aCollection whenConvertedTo: aClass [ 
	| result |
	result := self assertNonDuplicatedContents: aCollection whenConvertedTo: aClass.
	self assert: result size = aCollection size
]

{ #category : #requirements }
LinkedListTest >> collection [
	^ self nonEmpty
]

{ #category : #requirements }
LinkedListTest >> collectionClass [
" return the class to be used to create instances of the class tested"
	^ LinkedList
]

{ #category : #requirements }
LinkedListTest >> collectionMoreThan1NoDuplicates [
	" return a collection of size 5 without equal elements"
	^ collectionWithoutEqualElements
]

{ #category : #requirements }
LinkedListTest >> collectionNotIncluded [
" return a collection for wich each element is not included in 'nonEmpty' "
	^ collectionWithoutNil 
]

{ #category : #requirements }
LinkedListTest >> collectionWith1TimeSubcollection [
" return a collection including 'oldSubCollection'  only one time "
	^ self oldSubCollection 
]

{ #category : #requirements }
LinkedListTest >> collectionWithCopyNonIdentical [
	" return a collection that include elements for which 'copy' return a different object (this is not the case of SmallInteger)"
	^ collectionWithoutEqualElements
]

{ #category : #requirements }
LinkedListTest >> collectionWithElement [
	"Returns a collection that already includes what is returned by #element."
	^ self collection
]

{ #category : #requirements }
LinkedListTest >> collectionWithElementsToRemove [
" return a collection of elements included in 'nonEmpty'  "
	^ self nonEmpty 
]

{ #category : #requirements }
LinkedListTest >> collectionWithSortableElements [
	" return a collection only including elements that can be sorted (understanding '<' )"
	^ collection5Elements 
]

{ #category : #requirements }
LinkedListTest >> collectionWithoutEqualElements [

" return a collection not including equal elements "
	^collectionWithoutEqualElements 
]

{ #category : #requirements }
LinkedListTest >> collectionWithoutNilElements [
" return a collection that doesn't includes a nil element "
	^collectionWithoutNil 
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> containsAll: union of: one andOf: another [
			
	self assert: (one allSatisfy: [:each | union includes: each]).
	self assert: (another allSatisfy: [:each | union includes: each])
]

{ #category : #requirements }
LinkedListTest >> element [
	^ link ifNil: [link := ValueLink value: 42. "so that we can recognize this link"]
]

{ #category : #requirements }
LinkedListTest >> elementInForElementAccessing [
" return an element inculded in 'accessCollection '"
	^ elementIn 
]

{ #category : #requirements }
LinkedListTest >> elementInForIndexAccessing [
" return an element included in 'accessCollection' "
	^ elementIn 
]

{ #category : #requirements }
LinkedListTest >> elementNotIn [
	^ Link new
]

{ #category : #requirements }
LinkedListTest >> elementNotInForElementAccessing [
" return an element not included in 'accessCollection' "
	^ elementNotIn 
]

{ #category : #requirements }
LinkedListTest >> elementNotInForIndexAccessing [
" return an element not included in 'accessCollection' "
	^ elementNotIn 
]

{ #category : #requirements }
LinkedListTest >> elementNotInForOccurrences [
" return an element notIncluded in #collectionWithoutEqualElements"
	^ elementNotIn 
]

{ #category : #requirements }
LinkedListTest >> elementToAdd [
" return an element of type 'nonEmpy' elements'type'"
	^ ValueLink value: 77
]

{ #category : #accessing }
LinkedListTest >> empty [
	^ list
]

{ #category : #'tests - copying with replacement' }
LinkedListTest >> firstIndexesOf: aSubCollection in: collection [
" return an OrderedCollection with the first indexes of the occurrences of subCollection in  collection "
	| tmp result currentIndex |
	tmp:= collection.
	result:= OrderedCollection new.
	currentIndex := 1.
	
	[tmp isEmpty ]whileFalse:
		[
		(tmp beginsWith: aSubCollection)
			ifTrue: [ 	
				result add: currentIndex.
				1 to: aSubCollection size do: 
					[:i | 
					tmp := tmp copyWithoutFirst.
					currentIndex := currentIndex + 1]
				]
			ifFalse: [
				tmp := tmp copyWithoutFirst.
				currentIndex := currentIndex +1.
				]
		 ].
	
	^ result.
	
]

{ #category : #'tests - fixture' }
LinkedListTest >> howMany: aSubCollection in: collection [
" return an integer representing how many time 'subCollection'  appears in 'collection'  "
	| tmp nTime |
	tmp := collection.
	nTime:= 0.
	
	[tmp isEmpty ]whileFalse:
		[
		(tmp beginsWith: aSubCollection)
			ifTrue: [ 	
				nTime := nTime + 1.
				1 to: aSubCollection size do: [:i | tmp := tmp copyWithoutFirst.]
				]
			ifFalse: [tmp := tmp copyWithoutFirst.]
		 ].
	
	^ nTime.
	
]

{ #category : #requirements }
LinkedListTest >> indexInForCollectionWithoutDuplicates [
" return an index between 'collectionWithoutEqualsElements'  bounds"
	^ 2
]

{ #category : #requirements }
LinkedListTest >> indexInNonEmpty [
" return an index between bounds of 'nonEmpty' "

	^ self nonEmpty size
]

{ #category : #requirements }
LinkedListTest >> moreThan3Elements [
	" return a collection including atLeast 3 elements"
	^ collectionWithoutEqualElements 
]

{ #category : #requirements }
LinkedListTest >> moreThan4Elements [

" return a collection including at leat 4 elements"
	^ collectionWithoutEqualElements 
]

{ #category : #accessing }
LinkedListTest >> n [
	^n
]

{ #category : #accessing }
LinkedListTest >> n: number [
	n := number.
	
]

{ #category : #accessing }
LinkedListTest >> nextLink [
	^nextLink
]

{ #category : #accessing }
LinkedListTest >> nextLink: aLink [
	nextLink := aLink
]

{ #category : #requirements }
LinkedListTest >> nonEmpty [
	^ nonEmpty ifNil: [nonEmpty := LinkedList with: 5 with: 4 with: 3 with: 2 with: 1 with: self element]
]

{ #category : #requirements }
LinkedListTest >> nonEmpty1Element [
" return a collection of size 1 including one element"
	^ nonEmpty1Element 
]

{ #category : #requirements }
LinkedListTest >> nonEmptyMoreThan1Element [
" return a collection that don't includes equl elements'" 
	^collectionWithoutNil 
]

{ #category : #requirements }
LinkedListTest >> nonEmptyWithoutEqualElements [
" return a collection without equal elements "
	^ collectionWithoutEqualElements 
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> numberOfSimilarElementsInIntersection [
	^ self collection occurrencesOf: self anotherElementOrAssociationIn
]

{ #category : #requirements }
LinkedListTest >> oldSubCollection [
" return a subCollection included in collectionWith1TimeSubcollection .
ex :   subCollection := #( 2 3 4) and collectionWith1TimeSubcollection := #(1 2 3 4 5)"
	^ self nonEmpty 
]

{ #category : #requirements }
LinkedListTest >> otherCollection [
	^ otherList ifNil: [otherList := LinkedList with: Link new with: Link new]
]

{ #category : #requirements }
LinkedListTest >> replacementCollection [
" return a collection that will be used to replace 'oldSubcollection' in ' collectionWith1TimeSubcollection'  " 
	^ collectionWithoutNil 
]

{ #category : #requirements }
LinkedListTest >> result [
	"Returns a collection of the classes of elements in #collection"
	 ^ collectResult
]

{ #category : #running }
LinkedListTest >> setUp [
	
	super setUp.
	list := LinkedList new.
	link1 := 133.
	link2 := 'test'.
	link3 := $h.
	link4 := Set new.
	elementNotIn := Link new.
	collectionWithoutNil := LinkedList new add: link1; add: link2 ; add: link3; yourself.
	elementIn := 'thisElementIsIncluded'.
	collectionWithoutEqualElements := LinkedList new add: elementIn ; add: 'pewpew' ; add: 'normal links'; add: 'are no fun!' ;add: $x ;yourself.
	collection5Elements := collectionWithoutEqualElements .
	
	"sameAtendAndBegining := LinkedList new add: Link new; add: Link new ; add: Link new; yourself."
	link := ValueLink value: 42.
	nonEmpty1Element :=  LinkedList new add: Link new; yourself.
	 "so that we can recognize this link"
	"nonEmpty := LinkedList with: link with: Link new."
	"otherList := LinkedList with: Link new with: Link new."

]

{ #category : #requirements }
LinkedListTest >> speciesClass [
	
	^LinkedList
]

{ #category : #requirements }
LinkedListTest >> subCollectionNotIn [
" return a collection for which at least one element is not included in 'accessCollection' "
	^ collectionWithoutNil 
]

{ #category : #running }
LinkedListTest >> tearDown [
	list := nil.
	link1 := nil.
	link2 := nil.
	link3 := nil.
	link4 := nil.
	
	link := nil.
	nonEmpty := nil.
	otherList := nil.
	
	^ super tearDown
]

{ #category : #tests }
LinkedListTest >> test01add [
	self assert: list isEmpty.
	list add: link1.
	self assert: list size = 1.
	self assert: list first = link1.
	
	list add: link2.
	self assert: list size = 2.
	self assert: list first = link1.
	self assert: list second = link2.
	
	list add: link3.
	self assert: list size = 3.
	self assert: list first = link1.
	self assert: list second = link2.
	self assert: list third = link3.
	
	list add: link4.
	self assert: list size = 4.
	self assert: list first = link1.
	self assert: list second = link2.
	self assert: list third = link3.
	self assert: list fourth = link4
]

{ #category : #tests }
LinkedListTest >> test02addLast [
	self assert: list isEmpty.
	
	list addLast: link1.
	self assert: list size = 1.
	self assert: list first = link1.
	
	list addLast: link2.
	self assert: list size = 2.
	self assert: list first = link1.
	self assert: list second = link2.
	
	list addLast: link3.
	self assert: list size = 3.
	self assert: list first = link1.
	self assert: list second = link2.
	self assert: list third = link3.
	
	list addLast: link4.
	self assert: list size = 4.
	self assert: list first = link1.
	self assert: list second = link2.
	self assert: list third = link3.
	self assert: list fourth = link4
]

{ #category : #tests }
LinkedListTest >> test03addFirst [
	self assert: list isEmpty.
	
	list addFirst: link1.
	self assert: list size = 1.
	self assert: list first = link1.
	
	list addFirst: link2.
	self assert: list size = 2.
	self assert: list first = link2.
	self assert: list second = link1.
	
	list addFirst: link3.
	self assert: list size = 3.
	self assert: list first = link3.
	self assert: list second = link2.
	self assert: list third = link1.
	
	list addFirst: link4.
	self assert: list size = 4.
	self assert: list first = link4.
	self assert: list second = link3.
	self assert: list third = link2.
	self assert: list fourth = link1
]

{ #category : #tests }
LinkedListTest >> test04addBefore [
	self assert: list isEmpty.
	
	list add: link1.
	self assert: list size = 1.
	self assert: list first == link1.
	
	list add: link2 before: link1.
	self assert: list size = 2.
	self assert: list first == link2.
	self assert: list second == link1.
	
	list add: link3 before: link1.
	self assert: list size = 3.
	self assert: list first == link2.
	self assert: list second == link3.
	self assert: list third == link1.
	
	list add: link4 before: link1.
	self assert: list size = 4.
	self assert: list first == link2.
	self assert: list second == link3.
	self assert: list third == link4.
	self assert: list fourth == link1
]

{ #category : #tests }
LinkedListTest >> test05addBefore [
	self assert: list isEmpty.
	
	list add: link1.
	self assert: list size = 1.
	self assert: list first == link1.
	
	list add: link2 before: link1.
	self assert: list size = 2.
	self assert: list first == link2.
	self assert: list second == link1.
	
	list add: link3 before: link2.
	self assert: list size = 3.
	self assert: list first == link3.
	self assert: list second == link2.
	self assert: list third == link1.
	
	list add: link4 before: link3.
	self assert: list size = 4.
	self assert: list first == link4.
	self assert: list second == link3.
	self assert: list third == link2.
	self assert: list fourth == link1
]

{ #category : #tests }
LinkedListTest >> test06addAfter [
	self assert: list isEmpty.
	
	list add: link1.
	self assert: list size = 1.
	self assert: list first == link1.
	
	list add: link2 after: link1.
	self assert: list size = 2.
	self assert: list first == link1.
	self assert: list second == link2.
	
	list add: link3 after: link2.
	self assert: list size = 3.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link3.
	
	list add: link4 after: link3.
	self assert: list size = 4.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link3.
	self assert: list fourth == link4
]

{ #category : #tests }
LinkedListTest >> test07addAfter [
	self assert: list isEmpty.
	
	list add: link1.
	self assert: list size = 1.
	self assert: list first == link1.
	
	list add: link2 after: link1.
	self assert: list size = 2.
	self assert: list first == link1.
	self assert: list second == link2.
	
	list add: link3 after: link1.
	self assert: list size = 3.
	self assert: list first == link1.
	self assert: list second == link3.
	self assert: list third == link2.
	
	list add: link4 after: link1.
	self assert: list size = 4.
	self assert: list first == link1.
	self assert: list second == link4.
	self assert: list third == link3.
	self assert: list fourth == link2
]

{ #category : #tests }
LinkedListTest >> test08addAfter [
	| l first |
	l := LinkedList new.
	first := self class new n: 1.
	
	l add: first.
	l add: (self class new n: 3).

	self assert: (l collect:[:e | e n]) asArray  = #(1 3).
	
	l add: (self class new n: 2) after: first.

	self assert: (l collect:[:e | e n]) asArray  = #(1 2 3).
]

{ #category : #tests }
LinkedListTest >> test09addAfter [
	| l last |
	l := LinkedList new.
	last := self class new n: 2.
	l add: (self class new n: 1).
	l add: last.
	
	self assert: (l collect:[:e | e n]) asArray  = #(1 2).
	 
	l add: (self class new n: 3) after: last.

	self assert: (l collect:[:e | e n]) asArray  = #(1 2 3).
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0CopyTest [
	self empty.
	self assert: self empty size = 0.
	self nonEmpty.
	self assert: (self nonEmpty size = 0) not.
	self collectionWithElementsToRemove.
	self assert: (self collectionWithElementsToRemove size = 0) not.
	self collectionWithElementsToRemove do: [ :each | self assert: (self nonEmpty includes: each) ].
	self elementToAdd.
	self deny: (self nonEmpty includes: self elementToAdd).
	self collectionNotIncluded.
	self collectionNotIncluded do: [ :each | self deny: (self nonEmpty includes: each) ]
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureAsStringCommaAndDelimiterTest [
	self nonEmpty.
	self deny: self nonEmpty isEmpty.
	self empty.
	self assert: self empty isEmpty.
	self nonEmpty1Element.
	self assert: self nonEmpty1Element size = 1
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureBeginsEndsWithTest [
	self nonEmpty.
	self deny: self nonEmpty isEmpty.
	self assert: self nonEmpty size > 1.
	self empty.
	self assert: self empty isEmpty
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureCopyPartOfSequenceableTest [
	self collectionWithoutEqualElements.
	self collectionWithoutEqualElements
		do: [ :each | self assert: (self collectionWithoutEqualElements occurrencesOf: each) = 1 ].
	self indexInForCollectionWithoutDuplicates.
	self
		assert:
			(self indexInForCollectionWithoutDuplicates > 0 and: [ self indexInForCollectionWithoutDuplicates
				< self collectionWithoutEqualElements size ]).
	self empty.
	self assert: self empty isEmpty
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureCopySameContentsTest [
	self nonEmpty.
	self deny: self nonEmpty isEmpty.
	self empty.
	self assert: self empty isEmpty
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureCopyWithOrWithoutSpecificElementsTest [
	self nonEmpty.
	self deny: self nonEmpty isEmpty.
	self indexInNonEmpty.
	self assert: self indexInNonEmpty > 0.
	self assert: self indexInNonEmpty <= self nonEmpty size
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureCopyWithReplacementTest [
	self replacementCollection.
	self oldSubCollection.
	self collectionWith1TimeSubcollection.
	self assert: (self howMany: self oldSubCollection in: self collectionWith1TimeSubcollection) = 1
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureEmptyTest [
	self nonEmpty.
	self deny: self nonEmpty isEmpty.
	self empty.
	self assert: self empty isEmpty
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureIncludeTest [
	| anElementIn |
	self nonEmpty.
	self deny: self nonEmpty isEmpty.
	self elementNotIn.
	anElementIn := true.
	self nonEmpty detect: [ :each | each = self elementNotIn ] ifNone: [ anElementIn := false ].
	self assert: anElementIn = false.
	self anotherElementNotIn.
	anElementIn := true.
	self nonEmpty detect: [ :each | each = self anotherElementNotIn ] ifNone: [ anElementIn := false ].
	self assert: anElementIn = false.
	self empty.
	self assert: self empty isEmpty
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureIncludeWithIdentityTest [
	| anElement |
	self collectionWithCopyNonIdentical.
	anElement := self collectionWithCopyNonIdentical anyOne.
	self deny: anElement == anElement copy
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureIndexAccessTest [
	| res |
	self collectionMoreThan1NoDuplicates.
	self assert: self collectionMoreThan1NoDuplicates size = 5.
	res := true.
	self collectionMoreThan1NoDuplicates
		detect: [ :each | (self collectionMoreThan1NoDuplicates occurrencesOf: each) > 1 ]
		ifNone: [ res := false ].
	self assert: res = false.
	self elementInForIndexAccessing.
	self assert: (self collectionMoreThan1NoDuplicates includes: self elementInForIndexAccessing).
	self elementNotInForIndexAccessing.
	self deny: (self collectionMoreThan1NoDuplicates includes: self elementNotInForIndexAccessing)
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureIterateSequencedReadableTest [

	| res |
	
	self nonEmptyMoreThan1Element.
	self assert: self nonEmptyMoreThan1Element  size > 1.
	
	
	self empty.
	self assert: self empty isEmpty .
	
	res := true.
	self nonEmptyMoreThan1Element    
	detect: [ :each | (self nonEmptyMoreThan1Element    occurrencesOf: each) > 1 ]
	ifNone: [ res := false ].
	self assert: res = false.
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureIterateTest [
	| res |
	self collectionWithoutNilElements.
	self assert: (self collectionWithoutNilElements occurrencesOf: nil) = 0.
	res := true.
	self collectionWithoutNilElements
		detect: [ :each | (self collectionWithoutNilElements occurrencesOf: each) > 1 ]
		ifNone: [ res := false ].
	self assert: res = false
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureOccurrencesTest [
	| tmp |
	self empty.
	self assert: self empty isEmpty.
	self collectionWithoutEqualElements.
	self deny: self collectionWithoutEqualElements isEmpty.
	tmp := OrderedCollection new.
	self collectionWithoutEqualElements
		do: [ :each | 
			self deny: (tmp includes: each).
			tmp add: each ].
	self elementNotInForOccurrences.
	self deny: (self collectionWithoutEqualElements includes: self elementNotInForOccurrences)
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixturePrintTest [
	self nonEmpty.
	self deny: self nonEmpty isEmpty
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureRequirementsOfTAddTest [
	self collectionWithElement.
	self otherCollection.
	self element.
	self assert: (self collectionWithElement includes: self element).
	self deny: (self otherCollection includes: self element)
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureSequencedElementAccessTest [
	self moreThan4Elements.
	self assert: self moreThan4Elements size >= 4.
	self subCollectionNotIn.
	self subCollectionNotIn detect: [ :each | (self moreThan4Elements includes: each) not ] ifNone: [ self assert: false ].
	self elementNotInForElementAccessing.
	self deny: (self moreThan4Elements includes: self elementNotInForElementAccessing).
	self elementInForElementAccessing.
	self assert: (self moreThan4Elements includes: self elementInForElementAccessing)
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureSetAritmeticTest [
	self collection.
	self deny: self collection isEmpty.
	self nonEmpty.
	self deny: self nonEmpty isEmpty.
	self anotherElementOrAssociationNotIn.
	self collection isDictionary
		ifTrue: [ self deny: (self collection associations includes: self anotherElementOrAssociationNotIn key) ]
		ifFalse: [ self deny: (self collection includes: self anotherElementOrAssociationNotIn) ].
	self collectionClass
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureSubcollectionAccessTest [
	self moreThan3Elements.
	self assert: self moreThan3Elements size > 2
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureTConvertTest [
	"a collection of number without equal elements:"

	| res |
	self collectionWithoutEqualElements.
	res := true.
	self collectionWithoutEqualElements
		detect: [ :each | (self collectionWithoutEqualElements occurrencesOf: each) > 1 ]
		ifNone: [ res := false ].
	self assert: res = false
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0FixtureTRemoveTest [
	| duplicate |
	self empty.
	self nonEmptyWithoutEqualElements.
	self deny: self nonEmptyWithoutEqualElements isEmpty.
	duplicate := true.
	self nonEmptyWithoutEqualElements
		detect: [ :each | (self nonEmptyWithoutEqualElements occurrencesOf: each) > 1 ]
		ifNone: [ duplicate := false ].
	self assert: duplicate = false.
	self elementNotIn.
	self assert: self empty isEmpty.
	self deny: self nonEmptyWithoutEqualElements isEmpty.
	self deny: (self nonEmptyWithoutEqualElements includes: self elementNotIn)
]

{ #category : #'tests - fixture' }
LinkedListTest >> test0TStructuralEqualityTest [
	self empty.
	self nonEmpty.
	self assert: self empty isEmpty.
	self deny: self nonEmpty isEmpty
]

{ #category : #tests }
LinkedListTest >> test10removeFirst [
	list add: link1.
	list add: link2.
	list add: link3.
	list add: link4.
	
	self assert: list size = 4.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link3.
	self assert: list fourth == link4.
	
	list removeFirst.
	self assert: list size = 3.
	self assert: list first == link2.
	self assert: list second == link3.
	self assert: list third == link4.
	
	list removeFirst.
	self assert: list size = 2.
	self assert: list first == link3.
	self assert: list second == link4.
	
	list removeFirst.
	self assert: list size = 1.
	self assert: list first == link4.
	
	list removeFirst.
	self assert: list isEmpty
]

{ #category : #tests }
LinkedListTest >> test11removeLast [
	list add: link1.
	list add: link2.
	list add: link3.
	list add: link4.
	
	self assert: list size = 4.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link3.
	self assert: list fourth == link4.
	
	list removeLast.
	self assert: list size = 3.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link3.
	
	list removeLast.
	self assert: list size = 2.
	self assert: list first == link1.
	self assert: list second == link2.
	
	list removeLast.
	self assert: list size = 1.
	self assert: list first == link1.
	
	list removeFirst.
	self assert: list isEmpty
]

{ #category : #tests }
LinkedListTest >> test12remove [
	list add: link1.
	list add: link2.
	list add: link3.
	list add: link4.
	
	self assert: list size = 4.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link3.
	self assert: list fourth == link4.
	
	list remove: link3.
	self assert: list size = 3.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link4.
	
	list remove: link2.
	self assert: list size = 2.
	self assert: list first == link1.
	self assert: list second == link4.
	
	list remove: link1.
	self assert: list size = 1.
	self assert: list first == link4.
	
	list remove: link4.
	self assert: list isEmpty
]

{ #category : #tests }
LinkedListTest >> test13remove [
	list add: link1.
	list add: link2.
	list add: link3.
	list add: link4.
	
	self assert: list size = 4.
	self assert: list first == link1.
	self assert: list second == link2.
	self assert: list third == link3.
	self assert: list fourth == link4.
	
	list remove: link1.
	self assert: list size = 3.
	self assert: list first == link2.
	self assert: list second == link3.
	self assert: list third == link4.
	
	list remove: link4.
	self assert: list size = 2.
	self assert: list first == link2.
	self assert: list second == link3.
	
	list remove: link2.
	self assert: list size = 1.
	self assert: list first == link3.
	
	list remove: link3.
	self assert: list isEmpty
]

{ #category : #tests }
LinkedListTest >> test14removeIfAbsent [
	list add: link1.
	
	self assert: list size = 1.
	self assert: list first == link1.
	
	list remove: link1.
	self assert: list isEmpty.
	
	[list remove: link1]
		on: Error
		do: [^ self].
		
	"The execution should not get here. If yes, something went wrong."
	self assert: false
]

{ #category : #tests }
LinkedListTest >> test22addAll [
	| link5 link6 link7 link8 listToBeAdded |
	link5 := Link new.
	link6 := Link new.
	link7 := Link new.
	link8 := Link new.
	
	list
		add: link1;
		add: link2;
		add: link3;
		add: link4.
		
	listToBeAdded := LinkedList new.
	listToBeAdded
		add: link5;
		add: link6;
		add: link7;
		add: link8.
		
	list addAll: listToBeAdded.
	
	self should: [(list at: 1) == link1].
	self should: [(list at: 2) == link2].
	self should: [(list at: 3) == link3].
	self should: [(list at: 4) == link4].
	self should: [(list at: 5) == link5].
	self should: [(list at: 6) == link6].
	self should: [(list at: 7) == link7].
	self should: [(list at: 8) == link8].
]

{ #category : #tests }
LinkedListTest >> testAddAfter [

	| l first |
	l := LinkedList new.
	first := self class new n: 1.
	
	l add: first.
	l add: (self class new n: 3).
	self assert: (l collect:[:e | e n]) asArray  = #(1 3).
	l add: (self class new n: 2) after: first.
	self assert: (l collect:[:e | e n]) asArray  = #(1 2 3).
]

{ #category : #tests }
LinkedListTest >> testAddAfterLast [

	| l last |
	l := LinkedList new.
	last := self class new n: 2.
	l add: (self class new n: 1).
	l add: last.
	self assert: (l collect:[:e | e n]) asArray  = #(1 2). 
	l add: (self class new n: 3) after: last.
	self assert: (l collect:[:e | e n]) asArray  = #(1 2 3).
]

{ #category : #tests }
LinkedListTest >> testAddAfterLast2 [
	"LinkedListTest new testAddAfterLast2"

	| l first second third fourth |
	l := LinkedList new.
	first := self class new n: 1.
	second := self class new n: 2.
	third := self class new n: 3.
	fourth :=self class new n: 4.
	l addLast: first.
	l addLast: second.
	self assert: (l collect:[:e | e n]) asArray  = #(1 2). 
	l add: third after: second.
	self assert: (l collect:[:e | e n]) asArray  = #(1 2 3).
	l addLast: fourth.
	self assert: (l collect:[:e | e n]) asArray  = #(1 2 3 4).
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAfter [
	"self debug: #testAfter"
	self assert: (self moreThan4Elements after: (self moreThan4Elements at: 1)) = (self moreThan4Elements at: 2).
	self 
		should: 
			[ self moreThan4Elements after: (self moreThan4Elements at: self moreThan4Elements size) ]
		raise: Error.
	self 
		should: [ self moreThan4Elements after: self elementNotInForElementAccessing ]
		raise: Error
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAfterIfAbsent [
	"self debug: #testAfterIfAbsent"
	self assert: (self moreThan4Elements 
			after: (self moreThan4Elements at: 1)
			ifAbsent: [ 33 ]) = (self moreThan4Elements at: 2).
	self assert: (self moreThan4Elements 
			after: (self moreThan4Elements at: self moreThan4Elements size)
			ifAbsent: [ 33 ]) = 33.
	self assert: (self moreThan4Elements 
			after: self elementNotInForElementAccessing
			ifAbsent: [ 33 ]) = 33
]

{ #category : #'tests - subcollections access' }
LinkedListTest >> testAllButFirst [
	"self debug: #testAllButFirst"
	| abf col |
	col := self moreThan3Elements.
	abf := col allButFirst.
	self deny: abf first = col first.
	self assert: abf size + 1 = col size
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testAllButFirstDo [
	
	| result |
	result:= OrderedCollection  new.
	
	self nonEmptyMoreThan1Element  allButFirstDo: [:each | result add: each].
	
	1 to: (result size) do:
		[:i|
		self assert: (self nonEmptyMoreThan1Element  at:(i +1))=(result at:i)].
	
	self assert: result size=(self nonEmptyMoreThan1Element  size-1).
]

{ #category : #'tests - subcollections access' }
LinkedListTest >> testAllButFirstNElements [
	"self debug: #testAllButFirst"
	| abf col |
	col := self moreThan3Elements.
	abf := col allButFirst: 2.
	1 
		to: abf size
		do: [ :i | self assert: (abf at: i) = (col at: i + 2) ].
	self assert: abf size + 2 = col size
]

{ #category : #'tests - subcollections access' }
LinkedListTest >> testAllButLast [
	"self debug: #testAllButLast"
	| abf col |
	col := self moreThan3Elements.
	abf := col allButLast.
	self deny: abf last = col last.
	self assert: abf size + 1 = col size
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testAllButLastDo [
	
	| result |
	result:= OrderedCollection  new.
	
	self nonEmptyMoreThan1Element  allButLastDo: [:each | result add: each].
	
	1 to: (result size) do:
		[:i|
		self assert: (self nonEmptyMoreThan1Element  at:(i ))=(result at:i)].
	
	self assert: result size=(self nonEmptyMoreThan1Element  size-1).
]

{ #category : #'tests - subcollections access' }
LinkedListTest >> testAllButLastNElements [
	"self debug: #testAllButFirst"
	| abf col |
	col := self moreThan3Elements.
	abf := col allButLast: 2.
	1 
		to: abf size
		do: [ :i | self assert: (abf at: i) = (col at: i) ].
	self assert: abf size + 2 = col size
]

{ #category : #'tests - iterating' }
LinkedListTest >> testAllSatisfy [

	| element |
	" when all element  satisfy the condition, should return true : "
	self assert: ( self collectionWithoutNilElements  allSatisfy: [:each | (each notNil) ] ).
	
	" when all element don't satisfy the condition, should return false : "
	self deny: ( self collectionWithoutNilElements  allSatisfy: [:each | (each notNil) not ] ).
	
	" when only one element doesn't satisfy the condition' should return false'"
	element := self collectionWithoutNilElements anyOne.
	self deny: ( self collectionWithoutNilElements  allSatisfy: [:each | (each = element) not] ).
]

{ #category : #'tests - iterating' }
LinkedListTest >> testAllSatisfyEmpty [

	self assert: ( self empty allSatisfy: [:each | false]).
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testAnySastify [

	| element |
	" when all elements satisty the condition, should return true :"
	self assert: ( self collectionWithoutNilElements anySatisfy: [:each | each notNil ]).
	
	" when only one element satisfy the condition, should return true :"
	element := self collectionWithoutNilElements anyOne.
	self assert: ( self collectionWithoutNilElements  anySatisfy: [:each | (each = element)  ]   ).
	
	" when all elements don't satisty the condition, should return false :"
	self deny: ( self collectionWithoutNilElements anySatisfy: [:each | (each notNil) not ]).

]

{ #category : #'tests - converting' }
LinkedListTest >> testAsArray [
	"self debug: #testAsArray3"
	self 
		assertSameContents: self collectionWithoutEqualElements
		whenConvertedTo: Array
]

{ #category : #'tests - converting' }
LinkedListTest >> testAsBag [

	self assertSameContents: self collectionWithoutEqualElements whenConvertedTo: Bag
]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsCommaStringEmpty [

	self assert: self empty asCommaString = ''.
	self assert: self empty asCommaStringAnd = ''.
	

]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsCommaStringMore [

	"self assert: self oneTwoThreeItemCol asCommaString = '1, 2, 3'.
	self assert: self oneTwoThreeItemCol asCommaStringAnd = '1, 2 and 3'
"

	| result resultAnd index allElementsAsString |
	result:= self nonEmpty asCommaString .
	resultAnd:= self nonEmpty asCommaStringAnd .
 
	index := 1.
	(result findBetweenSubStrs: ',' )do:
		[:each |
		index = 1
			ifTrue: [self assert: each= ((self nonEmpty at:index)asString)]
			ifFalse: [self assert: each= (' ',(self nonEmpty at:index) asString)].
		index:=index+1
		].
	
	"verifying esultAnd :"
	allElementsAsString:=(resultAnd findBetweenSubStrs: ',' ).
	1 to: allElementsAsString size do:
		[:i | 
		i<(allElementsAsString size )
			ifTrue: [
			i = 1
				ifTrue:[self assert: (allElementsAsString at:i)=((self nonEmpty at:i) asString)]
				ifFalse:[self assert: (allElementsAsString at:i)=(' ',(self nonEmpty at:i) asString)]
				].
		i=(allElementsAsString size)
			ifTrue:[ 
			i = 1
				ifTrue:[self assert: (allElementsAsString at:i)=( (self nonEmpty at:i ) asString ,' and ', (self nonEmpty at: ( i + 1) ) asString )]
				ifFalse:[self assert: (allElementsAsString at:i)=( ' ' , (self nonEmpty at:i ) asString ,' and ', (self nonEmpty at: ( i + 1) ) asString )]
				].
		
		
			].
]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsCommaStringOne [
	
	"self assert: self oneItemCol asCommaString = '1'.
	self assert: self oneItemCol asCommaStringAnd = '1'."

	self assert: self nonEmpty1Element  asCommaString = (self nonEmpty1Element first asString).
	self assert: self nonEmpty1Element  asCommaStringAnd = (self nonEmpty1Element first asString).
	
]

{ #category : #'tests - converting' }
LinkedListTest >> testAsIdentitySet [
	"test with a collection without equal elements :"
	self 
		assertSameContents: self collectionWithoutEqualElements
		whenConvertedTo: IdentitySet.

]

{ #category : #'tests - converting' }
LinkedListTest >> testAsOrderedCollection [
	
	self assertSameContents: self collectionWithoutEqualElements whenConvertedTo: OrderedCollection
]

{ #category : #'tests - converting' }
LinkedListTest >> testAsSet [
	| |
	"test with a collection without equal elements :"
	self assertSameContents: self collectionWithoutEqualElements whenConvertedTo: Set.
	
]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsStringOnDelimiterEmpty [

	| delim emptyStream |
	delim := ', '.
	emptyStream := ReadWriteStream on: ''.
	self empty asStringOn: emptyStream delimiter: delim.
	self assert: emptyStream contents = ''.

]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsStringOnDelimiterLastEmpty [

	| delim emptyStream |
	delim := ', '.
	emptyStream := ReadWriteStream on: ''.
	self empty asStringOn: emptyStream delimiter: delim last:'and'.
	self assert: emptyStream contents = ''.

]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsStringOnDelimiterLastMore [

	| delim multiItemStream result last allElementsAsString |
	
	delim := ', '.
	last := 'and'.
	result:=''.
	multiItemStream := ReadWriteStream on:result.
	self nonEmpty  asStringOn: multiItemStream delimiter: ', ' last: last.
	
	allElementsAsString:=(result findBetweenSubStrs: ', ' ).
	1 to: allElementsAsString size do:
		[:i | 
		i<(allElementsAsString size-1 )
			ifTrue: [self assert: (allElementsAsString at:i)=((self nonEmpty at:i)asString)].
		i=(allElementsAsString size-1)
			ifTrue:[ self deny: (allElementsAsString at:i)=(last)asString].
		i=(allElementsAsString size)
			ifTrue: [self assert: (allElementsAsString at:i)=((self nonEmpty at:(i-1))asString)].
			].
	

]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsStringOnDelimiterLastOne [

	| delim oneItemStream result |
	
	delim := ', '.
	result:=''.
	oneItemStream := ReadWriteStream on: result.
	self nonEmpty1Element  asStringOn: oneItemStream delimiter: delim last: 'and'.
	oneItemStream do:[:each | self assert: each = (self nonEmpty1Element first asString)].
	

	
]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsStringOnDelimiterMore [

	| delim multiItemStream result index |
	"delim := ', '.
	multiItemStream := '' readWrite.
	self oneTwoThreeItemCol asStringOn: multiItemStream delimiter: ', '.
	self assert: multiItemStream contents = '1, 2, 3'."
	
	delim := ', '.
	result:=''.
	multiItemStream := ReadWriteStream on:result.
	self nonEmpty  asStringOn: multiItemStream delimiter: ', '.
	
	index:=1.
	(result findBetweenSubStrs: ', ' )do:
		[:each |
		self assert: each= ((self nonEmpty at:index)asString).
		index:=index+1
		].
]

{ #category : #'tests - comma and delimiter' }
LinkedListTest >> testAsStringOnDelimiterOne [

	| delim oneItemStream result |
	"delim := ', '.
	oneItemStream := '' readWrite.
	self oneItemCol asStringOn: oneItemStream delimiter: delim.
	self assert: oneItemStream contents = '1'."
	
	delim := ', '.
	result:=''.
	oneItemStream := ReadWriteStream on: result.
	self nonEmpty1Element  asStringOn: oneItemStream delimiter: delim.
	oneItemStream do:[:each | self assert: each = (self nonEmpty1Element first asString)].
	

	
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAt [
	"self debug: #testAt"
	"
	self assert: (self accessCollection at: 1) = 1.
	self assert: (self accessCollection at: 2) = 2.
	"
	| index |
	index := self moreThan4Elements indexOf: self elementInForElementAccessing.
	self assert: (self moreThan4Elements at: index) = self elementInForElementAccessing
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtAll [
	"self debug: #testAtAll"
	"	self flag: #theCollectionshouldbe102030intheFixture.
	
	self assert: (self accessCollection atAll: #(2 1)) first = self accessCollection second.
	self assert: (self accessCollection atAll: #(2)) first = self accessCollection second."
	| result |
	result := self moreThan4Elements atAll: #(2 1 2 ).
	self assert: (result at: 1) = (self moreThan4Elements at: 2).
	self assert: (result at: 2) = (self moreThan4Elements at: 1).
	self assert: (result at: 3) = (self moreThan4Elements at: 2).
	self assert: (self moreThan4Elements atAll: #()) = self moreThan4Elements species new
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtIfAbsent [
	"self debug: #testAt"
	| absent |
	absent := false.
	self moreThan4Elements 
		at: self moreThan4Elements size + 1
		ifAbsent: [ absent := true ].
	self assert: absent = true.
	absent := false.
	self moreThan4Elements 
		at: self moreThan4Elements size
		ifAbsent: [ absent := true ].
	self assert: absent = false
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtLast [
	"self debug: #testAtLast"
	| index |
	self assert: (self moreThan4Elements atLast: 1) = self moreThan4Elements last.
	"tmp:=1.
	self do:
		[:each | 
		each =self elementInForIndexAccessing 
			ifTrue:[index:=tmp].
		tmp:=tmp+1]."
	index := self moreThan4Elements indexOf: self elementInForElementAccessing.
	self assert: (self moreThan4Elements atLast: index) = (self moreThan4Elements at: self moreThan4Elements size - index + 1)
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtLastError [
	"self debug: #testAtLast"
	self 
		should: [ self moreThan4Elements atLast: self moreThan4Elements size + 1 ]
		raise: Error
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtLastIfAbsent [
	"self debug: #testAtLastIfAbsent"
	self assert: (self moreThan4Elements 
			atLast: 1
			ifAbsent: [ nil ]) = self moreThan4Elements last.
	self assert: (self moreThan4Elements 
			atLast: self moreThan4Elements size + 1
			ifAbsent: [ 222 ]) = 222
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtOutOfBounds [
	"self debug: #testAtOutOfBounds"
	self 
		should: [ self moreThan4Elements at: self moreThan4Elements size + 1 ]
		raise: Error.
	self 
		should: [ self moreThan4Elements at: -1 ]
		raise: Error
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtPin [
	"self debug: #testAtPin"
	self assert: (self moreThan4Elements atPin: 2) = self moreThan4Elements second.
	self assert: (self moreThan4Elements atPin: 99) = self moreThan4Elements last.
	self assert: (self moreThan4Elements atPin: -99) = self moreThan4Elements first
]

{ #category : #'tests - sequenceable' }
LinkedListTest >> testAtPut [
	| ll |
	ll := LinkedList new.
	ll add: 1.
	ll at: 1 put: 2.
	self assert: (ll at: 1) equals: 2
]

{ #category : #'tests - sequenceable' }
LinkedListTest >> testAtPutOutsideBounds [
	| ll |
	ll := LinkedList new.
	self should: [ ll at: 1 put: 1 ] raise: Error
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtRandom [
	| result |
	result := self nonEmpty atRandom .
	self assert: (self nonEmpty includes: result).
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testAtWrap [
	"self debug: #testAt"
	"
	self assert: (self accessCollection at: 1) = 1.
	self assert: (self accessCollection at: 2) = 2.
	"
	| index |
	index := self moreThan4Elements indexOf: self elementInForElementAccessing.
	self assert: (self moreThan4Elements atWrap: index) = self elementInForElementAccessing.
	self assert: (self moreThan4Elements atWrap: index + self moreThan4Elements size) = self elementInForElementAccessing.
	self assert: (self moreThan4Elements atWrap: index - self moreThan4Elements size) = self elementInForElementAccessing.
	self assert: (self moreThan4Elements atWrap: 1 + self moreThan4Elements size) = (self moreThan4Elements at: 1)
]

{ #category : #'tests - iterating' }
LinkedListTest >> testBasicCollect [

	| res index |
	index := 0.
	res := self collectionWithoutNilElements collect: [ :each | 
		index := index + 1.
		each ].
	
	res do: [ :each | 
		self assert: (self collectionWithoutNilElements occurrencesOf: each) = (res occurrencesOf: each)].
	self assert: index equals: self collectionWithoutNilElements size.
	 
]

{ #category : #'tests - iterating' }
LinkedListTest >> testBasicCollectEmpty [

	| res |
	res := self empty collect: [:each | each class].
	self assert: res isEmpty
	
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testBefore [
	"self debug: #testBefore"
	self assert: (self moreThan4Elements before: (self moreThan4Elements at: 2)) = (self moreThan4Elements at: 1).
	self 
		should: [ self moreThan4Elements before: (self moreThan4Elements at: 1) ]
		raise: Error.
	self 
		should: [ self moreThan4Elements before: 66 ]
		raise: Error
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testBeforeIfAbsent [
	"self debug: #testBefore"
	self assert: (self moreThan4Elements 
			before: (self moreThan4Elements at: 1)
			ifAbsent: [ 99 ]) = 99.
	self assert: (self moreThan4Elements 
			before: (self moreThan4Elements at: 2)
			ifAbsent: [ 99 ]) = (self moreThan4Elements at: 1)
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testCollectFromTo [
	
	| result |
	result:=self nonEmptyMoreThan1Element 
		collect: [ :each | each ]
		from: 1
		to: (self nonEmptyMoreThan1Element size - 1).
		
	1 to: result size
		do: [ :i | self assert: (self nonEmptyMoreThan1Element at: i) = (result at: i) ].
	self assert: result size = (self nonEmptyMoreThan1Element size - 1)
]

{ #category : #'tests - iterating' }
LinkedListTest >> testCollectOnEmpty [
	self assert: (self empty collect: [:e | self fail]) isEmpty
]

{ #category : #'tests - iterating' }
LinkedListTest >> testCollectThenDoOnEmpty [

	self assert: (self empty collect: [:e | self fail] thenDo: [ self fail ]) isEmpty
]

{ #category : #'tests - iterating' }
LinkedListTest >> testCollectThenSelectOnEmpty [

	self assert: (self empty collect: [:e | self fail] thenSelect: [:e | self fail ]) isEmpty
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyAfter [
	| result index collection |
	collection := self collectionWithoutEqualElements .
	index:= self indexInForCollectionWithoutDuplicates .
	result := collection   copyAfter: (collection  at:index ).
	
	"verifying content: "
	(1) to: result size do: 
		[:i |
		self assert: (collection   at:(i + index ))=(result at: (i))].

	"verify size: "
	self assert: result size = (collection   size - index).
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyAfterEmpty [
	| result |
	result := self empty copyAfter: self collectionWithoutEqualElements first.
	self assert: result isEmpty.
	
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyAfterLast [
	| result index collection |
	collection := self collectionWithoutEqualElements .
	index:= self indexInForCollectionWithoutDuplicates .
	result := collection   copyAfterLast: (collection  at:index ).
	
	"verifying content: "
	(1) to: result size do: 
		[:i |
		self assert: (collection   at:(i + index ))=(result at: (i))].

	"verify size: "
	self assert: result size = (collection   size - index).
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyAfterLastEmpty [
	| result |
	result := self empty copyAfterLast: self collectionWithoutEqualElements first.
	self assert: result isEmpty.
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyEmptyWith [
	"self debug: #testCopyWith"
	| res anElement |
	anElement := self elementToAdd.
	res := self empty copyWith: anElement.
	self assert: res size = (self empty size + 1).
	self assert: (res includes: (anElement value))
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyEmptyWithout [
	"self debug: #testCopyEmptyWithout"
	| res |
	res := self empty copyWithout: self elementToAdd.
	self assert: res size = self empty size.
	self deny: (res includes: self elementToAdd)
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyEmptyWithoutAll [
	"self debug: #testCopyEmptyWithoutAll"
	| res |
	res := self empty copyWithoutAll: self collectionWithElementsToRemove.
	self assert: res size = self empty size.
	self collectionWithElementsToRemove do: [ :each | self deny: (res includes: each) ]
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyEquals [
	"self debug: #testCopySameClass"
	"A copy should be equivalent to the things it's a copy of"
	
	| copy | 
	copy := self nonEmpty copy.
	self assert: copy  = self nonEmpty.
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyFromTo [
	| result  index collection |
	collection := self collectionWithoutEqualElements .
	index :=self indexInForCollectionWithoutDuplicates .
	result := collection   copyFrom: index  to: collection  size .
	
	"verify content of 'result' : "
	1 to: result size do:
		[:i | 
		self assert: (result at:i)=(collection  at: (i + index - 1))].
	
	"verify size of 'result' : "
	self assert: result size = (collection  size - index + 1).
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyNonEmptyWith [
	"self debug: #testCopyNonEmptyWith"
	| res anElement |
	anElement := self elementToAdd .
	res := self nonEmpty copyWith: anElement.
	"here we do not test the size since for a non empty set we would get a problem.
	Then in addition copy is not about duplicate management. The element should 
	be in at the end."
	self assert: (res includes: (anElement value)).
	self nonEmpty do: [ :each | res includes: each ]
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyNonEmptyWithout [
	"self debug: #testCopyNonEmptyWithout"
	
	| res anElementOfTheCollection |
	anElementOfTheCollection :=  self nonEmpty anyOne.
	res := (self nonEmpty copyWithout: anElementOfTheCollection).
	"here we do not test the size since for a non empty set we would get a problem.
	Then in addition copy is not about duplicate management. The element should 
	be in at the end."
	self deny: (res includes: anElementOfTheCollection).
	self nonEmpty do:
		[:each | (each = anElementOfTheCollection) 
					ifFalse: [self assert: (res includes: each)]].
	

]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyNonEmptyWithoutAll [
	"self debug: #testCopyNonEmptyWithoutAll"
	| res |
	res := self nonEmpty copyWithoutAll: self collectionWithElementsToRemove.
	"here we do not test the size since for a non empty set we would get a problem.
	Then in addition copy is not about duplicate management. The element should 
	be in at the end."
	self collectionWithElementsToRemove do: [ :each | self deny: (res includes: (each)) ].
	self nonEmpty do: 
		[ :each | 
		(self collectionWithElementsToRemove includes: each) ifFalse: [ self assert: (res includes: each) ] ]
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyNonEmptyWithoutAllNotIncluded [
	"self debug: #testCopyNonEmptyWithoutAllNotIncluded"
	| res |
	res := self nonEmpty copyWithoutAll: self collectionNotIncluded.
	"here we do not test the size since for a non empty set we would get a problem.
	Then in addition copy is not about duplicate management. The element should 
	be in at the end."
	self nonEmpty do: [ :each | self assert: (res includes: each) ]
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyNonEmptyWithoutNotIncluded [
	"self debug: #testCopyNonEmptyWithoutNotIncluded"
	| res |
	res := self nonEmpty copyWithout: self elementToAdd.
	"here we do not test the size since for a non empty set we would get a problem.
	Then in addition copy is not about duplicate management. The element should 
	be in at the end."
	self nonEmpty do: [ :each | self assert: (res includes: each) ]
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopyNotSame [
	"self debug: #testCopySameClass"
	"A copy of a collection should always be of the same class as the instance it copies"
	
	| copy | 
	copy := self nonEmpty copy.
	self deny: copy  == self nonEmpty.
]

{ #category : #'tests - copying with replacement' }
LinkedListTest >> testCopyReplaceAllWith1Occurence [
	| result  firstIndexesOfOccurrence index endPartIndexResult endPartIndexCollection |
	
	result := self collectionWith1TimeSubcollection  copyReplaceAll: self oldSubCollection with: self replacementCollection .
	
	"detecting indexes of olSubCollection"
	firstIndexesOfOccurrence  := self firstIndexesOf: self oldSubCollection in: self collectionWith1TimeSubcollection .
	index:= firstIndexesOfOccurrence at: 1.
	
	"verify content of 'result' : "
	"first part of 'result'' : '"

	1 to: (index -1) do: 
		[
		:i |  
		self assert: (self collectionWith1TimeSubcollection  at:i)=(result at: i)
		].

	" middle part containing replacementCollection : "
	
	index to: (index + self replacementCollection size-1) do: 
		[
		:i |
		self assert: ( result at: i )=(self replacementCollection at: ( i - index + 1 ))
		].
	
	" end part :"
	
	endPartIndexResult :=  index + self replacementCollection  size .
	endPartIndexCollection :=   index + self oldSubCollection size  .
	
	1 to: (result size - endPartIndexResult - 1 ) do:
		[ 
		:i |
		self assert: (result at: ( endPartIndexResult + i - 1 ) ) = (self collectionWith1TimeSubcollection  at: ( endPartIndexCollection + i - 1 ) ).
		].
	
	
	
]

{ #category : #'tests - copying with replacement' }
LinkedListTest >> testCopyReplaceFromToWith [
	| result  indexOfSubcollection lastIndexOfOldSubcollection lastIndexOfReplacementCollection |
	
	indexOfSubcollection := (self firstIndexesOf: self oldSubCollection  in:  self collectionWith1TimeSubcollection) at: 1. 
	lastIndexOfOldSubcollection := indexOfSubcollection + self oldSubCollection size -1.
	lastIndexOfReplacementCollection := indexOfSubcollection + self replacementCollection  size -1.
	
	result := self collectionWith1TimeSubcollection  copyReplaceFrom: indexOfSubcollection  to: lastIndexOfOldSubcollection   with: self replacementCollection .
	
	"verify content of 'result' : "
	"first part of 'result'  "
	
	1 to: (indexOfSubcollection  - 1) do: 
		[ 
		:i | 
		self assert: (self collectionWith1TimeSubcollection  at:i) = (result at: i)
		].
	
	" middle part containing replacementCollection : "
	
	(indexOfSubcollection ) to: ( lastIndexOfReplacementCollection  ) do: 
		[
		:i |
		self assert: (result at: i)=(self replacementCollection at: (i - indexOfSubcollection +1))
		].
	
	" end part :"
	1 to: (result size - lastIndexOfReplacementCollection   ) do:
		[ 
		:i |
		self assert: (result at: ( lastIndexOfReplacementCollection  + i  ) ) = (self collectionWith1TimeSubcollection  at: ( lastIndexOfOldSubcollection  + i  ) ).
		].
	
	
	

	
	
]

{ #category : #'tests - copying with replacement' }
LinkedListTest >> testCopyReplaceFromToWithInsertion [
	| result  indexOfSubcollection |
	
	indexOfSubcollection := (self firstIndexesOf: self oldSubCollection  in:  self collectionWith1TimeSubcollection) at: 1. 
	
	result := self collectionWith1TimeSubcollection  copyReplaceFrom: indexOfSubcollection  to: ( indexOfSubcollection - 1 ) with: self replacementCollection .
	
	"verify content of 'result' : "
	"first part of 'result'' : '"
	
	1 to: (indexOfSubcollection -1) do: 
		[
		:i | 
		self assert: (self collectionWith1TimeSubcollection  at:i)=(result at: i)
		].
	
	" middle part containing replacementCollection : "
	indexOfSubcollection  to: (indexOfSubcollection  + self replacementCollection size-1) do: 
		[
		:i |
		self assert: ( result at: i )=(self replacementCollection at: ( i - indexOfSubcollection +1 ))
		].
	
	" end part :"
	(indexOfSubcollection  + self replacementCollection size) to: (result size) do:
		[:i|
		self assert: (result at: i)=(self collectionWith1TimeSubcollection  at: (i-self replacementCollection size))].
	
	" verify size: "	
	self assert: result size=(self collectionWith1TimeSubcollection  size + self replacementCollection size).
	

	

	
	
]

{ #category : #'tests - copy' }
LinkedListTest >> testCopySameClass [
	"self debug: #testCopySameClass"
	"A copy of a collection should always be of the same class as the instance it copies"
	
	| copy | 
	copy := self empty copy.
	self assert: copy class == self empty class.
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyUpTo [
	| result index collection |
	collection := self collectionWithoutEqualElements .
	index:= self indexInForCollectionWithoutDuplicates .
	result := collection   copyUpTo: (collection  at:index).
	
	"verify content of 'result' :"
	1 to: result size do: [:i| self assert: (collection   at:i)=(result at:i)].
	
	"verify size of 'result' :"
	self assert: result size = (index-1).
	
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyUpToEmpty [
	| result |
	result := self empty copyUpTo: self collectionWithoutEqualElements first.
	self assert: result isEmpty.
	
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyUpToLast [
	| result index collection |
	collection := self collectionWithoutEqualElements .
	index:= self indexInForCollectionWithoutDuplicates .
	result := collection   copyUpToLast: (collection  at:index).
	
	"verify content of 'result' :"
	1 to: result size do: [:i| self assert: (collection   at:i)=(result at:i)].
	
	"verify size of 'result' :"
	self assert: result size = (index-1).
]

{ #category : #'tests - copying part of sequenceable' }
LinkedListTest >> testCopyUpToLastEmpty [
	| result |
	result := self empty copyUpToLast: self collectionWithoutEqualElements first.
	self assert: result isEmpty.
]

{ #category : #'tests - copying with or without' }
LinkedListTest >> testCopyWithFirst [

	| index element result |
	index:= self indexInNonEmpty .
	element:= self nonEmpty at: index.
	
	result := self nonEmpty copyWithFirst: element.	
	
	self assert: result size = (self nonEmpty size + 1).
	self assert: result first = element .
	
	2 to: result size do:
	[ :i |
	self assert: (result at: i) = ( self nonEmpty at: ( i - 1 ))].
]

{ #category : #'tests - copying with or without' }
LinkedListTest >> testCopyWithSequenceable [

	| result index element |
	index := self indexInNonEmpty .
	element := self nonEmpty at: index.
	result := self nonEmpty copyWith: (element ).
	
	self assert: result size = (self nonEmpty size + 1).
	self assert: result last = element .
	
	1 to: (result size - 1) do:
	[ :i |
	self assert: (result at: i) = ( self nonEmpty at: ( i  ))].
]

{ #category : #'tests - copying with or without' }
LinkedListTest >> testCopyWithoutFirst [

	| result |
	result := self nonEmpty copyWithoutFirst.
	
	self assert: result size = (self nonEmpty size - 1).
	
	1 to: result size do:
		[:i |
		self assert: (result at: i)= (self nonEmpty at: (i + 1))].
]

{ #category : #'tests - copying with or without' }
LinkedListTest >> testCopyWithoutIndex [
	| result index |
	index := self indexInNonEmpty .
	result := self nonEmpty copyWithoutIndex: index .
	
	"verify content of 'result:'"
	1 to: result size do:
		[:i | 
		i<( index ) ifTrue: [self assert: ((result at:i )= (self nonEmpty at:i))].
		i>=( index ) ifTrue: [self assert: (result at:i )= (self nonEmpty at:(i+1))]].
	
	"verify size of result : "
	self assert: result size=(self nonEmpty size -1).
]

{ #category : #'tests - creating' }
LinkedListTest >> testCreateAs [
	"Test that a LinkedList can be created by sending message #as: to another collection.
	Implementation note: this method is generic for sequenceable collection and should be traitified."
	| anotherCollection aLinkedList |
	anotherCollection := 1 to: 10.
	aLinkedList := anotherCollection as: LinkedList.
	self assert: (aLinkedList isMemberOf: LinkedList).
	self assert: aLinkedList size equals: anotherCollection size.
	aLinkedList with: anotherCollection do: [:nextElementOfLinkedList :nextElementOfAnotherCollection |
		self assert: nextElementOfLinkedList equals: nextElementOfAnotherCollection]
]

{ #category : #'tests - iterating' }
LinkedListTest >> testDetect [

	| res element |
	element := self collectionWithoutNilElements anyOne .
	 
	res := self collectionWithoutNilElements  detect: [:each | each = element].
	self assert: (res  = element).

	
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testDetectIfNone [

	| res element |
	res := self collectionWithoutNilElements  detect: [:each | each notNil not] ifNone: [100].
	self assert: res  = 100.
	
	element := self collectionWithoutNilElements anyOne.
	res := self collectionWithoutNilElements  detect: [:each | each = element] ifNone: [100].
	self assert: res  = element.

	
	
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testDetectSequenced [
" testing that detect keep the first element returning true for sequenceable collections "

	| element result |
	element := self nonEmptyMoreThan1Element   at:1.
	result:=self nonEmptyMoreThan1Element  detect: [:each | each notNil ].
	self assert: result = element. 
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testDifference [
	"Answer the set theoretic difference of two collections."
	"self debug: #testDifference"
	
	| difference |
	self assert: (self collectionWithoutEqualElements difference: self collectionWithoutEqualElements) isEmpty.
	self assert: (self empty difference: self collectionWithoutEqualElements) isEmpty.
	difference := (self collectionWithoutEqualElements difference: self empty).
	self assert: difference size = self collectionWithoutEqualElements	 size.
	self collectionWithoutEqualElements do: [ :each |
		self assert: (difference includes: each)].

]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testDifferenceWithNonNullIntersection [
	"Answer the set theoretic difference of two collections."
	"self debug: #testDifferenceWithNonNullIntersection"
	"	#(1 2 3) difference: #(2 4) 
	->  #(1 3)"
	| res overlapping |
	overlapping := self collectionClass 
		with: self anotherElementOrAssociationNotIn
		with: self anotherElementOrAssociationIn.
	res := self collection difference: overlapping.
	self deny: (res includes: self anotherElementOrAssociationIn).
	overlapping do: [ :each | self deny: (res includes: each) ]
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testDifferenceWithSeparateCollection [
	"Answer the set theoretic difference of two collections."
	"self debug: #testDifferenceWithSeparateCollection"
	| res separateCol |
	
	separateCol := self collectionClass with: self anotherElementOrAssociationNotIn.
	res := self collectionWithoutEqualElements difference: separateCol.
	
	self deny: (res includes: self anotherElementOrAssociationNotIn).
	self assert: res size equals: self collectionWithoutEqualElements size.
	
	self collectionWithoutEqualElements do: [ :each|
		self assert: (res includes: each)].
	
	res := separateCol difference: self collection.
	self deny: (res includes: self collection anyOne).
	self assert: res equals: separateCol
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testDo [
]

{ #category : #'tests - iterating' }
LinkedListTest >> testDo2 [
	"dc: Bad test, it assumes that a new instance of #speciesClass allows addition with #add:. This is not the case of Interval for which species is Array."
	"res := self speciesClass new.  
	self collection do: [:each | res add: each class].
	self assert: res = self result. "
	| collection cptElementsViewed cptElementsIn |
	collection := self collectionWithoutNilElements.
	cptElementsViewed := 0.
	cptElementsIn := OrderedCollection new.
	collection do: 
		[ :each | 
		cptElementsViewed := cptElementsViewed + 1.
		" #do doesn't iterate with the same objects than those in the collection for FloatArray( I don' t know why ) . That's why I use #includes: and not #identityIncludes:  '"
		(collection includes: each) ifTrue: [
			" the collection used doesn't include equal elements. Therefore each element viewed should not have been viewed before "
			( cptElementsIn includes: each ) ifFalse: [ cptElementsIn add: each ] .
			]. 
		].
	self assert: cptElementsViewed = collection size.
	self assert: cptElementsIn size  = collection size.
	
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testDoSeparatedBy [
	| string expectedString beforeFirst |
	
	string := ''.
	self collectionWithoutNilElements  
		do: [ :each | string := string , each asString ]
		separatedBy: [ string := string , '|' ].
		
	expectedString := ''.
	beforeFirst := true.
	self collectionWithoutNilElements  do: 
		[ :each | 
		beforeFirst = true 
			ifTrue: [ beforeFirst := false ]
			ifFalse: [ expectedString := expectedString , '|' ].
		expectedString := expectedString , each asString ].
	self assert: expectedString = string
]

{ #category : #'tests - iterating' }
LinkedListTest >> testDoWithout [
	"self debug: #testDoWithout"
	
	| res element collection |
	collection := self collectionWithoutNilElements .	
	res := OrderedCollection new.  
	element := self collectionWithoutNilElements anyOne .
	collection  do: [:each | res add: each] without: element  .
	" verifying result :"
	self assert: res size = (collection  size - (collection  occurrencesOf: element)).
	res do: [:each | self assert: (collection occurrencesOf: each) = ( res occurrencesOf: each ) ].
	
]

{ #category : #'tests - equality' }
LinkedListTest >> testEqualSign [
	"self debug: #testEqualSign"

	self deny: (self empty = self nonEmpty).
]

{ #category : #'tests - equality' }
LinkedListTest >> testEqualSignIsTrueForNonIdenticalButEqualCollections [
	"self debug: #testEqualSignIsTrueForNonIdenticalButEqualCollections"
		
	self assert: (self empty = self empty copy). 
	self assert: (self empty copy = self empty).
	self assert: (self empty copy = self empty copy).
		
	self assert: (self nonEmpty = self nonEmpty copy). 
	self assert: (self nonEmpty copy = self nonEmpty).
	self assert: (self nonEmpty copy = self nonEmpty copy).
]

{ #category : #'tests - equality' }
LinkedListTest >> testEqualSignOfIdenticalCollectionObjects [
	"self debug: #testEqualSignOfIdenticalCollectionObjects"
	
	self assert: (self empty = self empty). 
	self assert: (self nonEmpty = self nonEmpty). 
	
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testFindFirst [

	| element result |
	element := self nonEmptyMoreThan1Element   at:1.
	 result:=self nonEmptyMoreThan1Element  findFirst: [:each | each =element].
	
	self assert: result=1. 
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testFindFirstNotIn [

	| result |
	
	 result:=self empty findFirst: [:each | true].
	
	self assert: result=0. 
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testFindLast [

	| element result |
	element := self nonEmptyMoreThan1Element  at:self nonEmptyMoreThan1Element  size.
	 result:=self nonEmptyMoreThan1Element  findLast: [:each | each =element].
	
	self assert: result=self nonEmptyMoreThan1Element  size. 
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testFindLastNotIn [

	| result |
	
	 result:=self empty findFirst: [:each | true].
	
	self assert: result=0. 
]

{ #category : #'tests - subcollections access' }
LinkedListTest >> testFirstNElements [
	"self debug: #testFirstNElements"
	| result |
	result := self moreThan3Elements first: self moreThan3Elements size - 1.
	1 
		to: result size
		do: [ :i | self assert: (result at: i) = (self moreThan3Elements at: i) ].
	self assert: result size = (self moreThan3Elements size - 1).
	self 
		should: [ self moreThan3Elements first: self moreThan3Elements size + 1 ]
		raise: Error
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testFirstSecondThird [
	"self debug: #testFirstSecondThird"
	self assert: self moreThan4Elements first = (self moreThan4Elements at: 1).
	self assert: self moreThan4Elements second = (self moreThan4Elements at: 2).
	self assert: self moreThan4Elements third = (self moreThan4Elements at: 3).
	self assert: self moreThan4Elements fourth = (self moreThan4Elements at: 4)
]

{ #category : #'tests - copying with or without' }
LinkedListTest >> testForceToPaddingStartWith [

	| result element |
	element := self nonEmpty at: self indexInNonEmpty .
	result := self nonEmpty forceTo: (self nonEmpty size+2) paddingStartWith: ( element ).
	
	"verify content of 'result' : "
	1 to: 2   do:
		[:i | self assert: ( element ) = ( result at:(i) ) ].
	
	3 to: result size do:
		[:i | self assert: ( result at:i ) = ( self nonEmpty at:(i-2) ) ].

	"verify size of 'result' :"
	self assert: result size = (self nonEmpty size + 2).
]

{ #category : #'tests - copying with or without' }
LinkedListTest >> testForceToPaddingWith [

	| result element |
	element := self nonEmpty at: self indexInNonEmpty .
	result := self nonEmpty forceTo: (self nonEmpty size+2) paddingWith: ( element ).
	
	"verify content of 'result' : "
	1 to: self nonEmpty  size do:
		[:i | self assert: ( self nonEmpty at: i ) = ( result at:(i) ). ].
	
	(result size - 1) to: result size do:
		[:i | self assert: ( result at:i ) = ( element ) ].

	"verify size of 'result' :"
	self assert: result size = (self nonEmpty size + 2).
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testFromToDo [
	
	| result |
	result:= OrderedCollection  new.
	
	self nonEmptyMoreThan1Element  from: 1 to: (self nonEmptyMoreThan1Element  size -1) do: [:each | result add: each].
	
	1 to: (self nonEmptyMoreThan1Element  size -1) do:
		[:i|
		self assert: (self nonEmptyMoreThan1Element  at:i )=(result at:i)].
	self assert: result size=(self nonEmptyMoreThan1Element  size-1).
]

{ #category : #'tests - includes' }
LinkedListTest >> testIdentityIncludes [
	" test the comportement in presence of elements 'includes' but not 'identityIncludes' "

	" can not be used by collections that can't include elements for wich copy doesn't return another instance "

	| collection element |
	self collectionWithCopyNonIdentical.
	collection := self collectionWithCopyNonIdentical.
	element := collection anyOne copy.	"self assert: (collection includes: element)."
	self deny: (collection identityIncludes: element)
]

{ #category : #'tests - includes' }
LinkedListTest >> testIdentityIncludesNonSpecificComportement [
	" test the same comportement than 'includes: '  "
	| collection |	
	collection := self nonEmpty  .
	
	self deny: (collection identityIncludes: self elementNotIn ).
	self assert:(collection identityIncludes: collection anyOne)

]

{ #category : #'tests - index access' }
LinkedListTest >> testIdentityIndexOf [
	"self debug: #testIdentityIndexOf"
	| collection element |
	collection := self collectionMoreThan1NoDuplicates.
	element := collection first.
	self assert: (collection identityIndexOf: element) = (collection indexOf: element)
]

{ #category : #'tests - index access' }
LinkedListTest >> testIdentityIndexOfIAbsent [
	| collection element |
	collection := self collectionMoreThan1NoDuplicates.
	element := collection first.
	self assert: (collection 
			identityIndexOf: element
			ifAbsent: [ 0 ]) = 1.
	self assert: (collection 
			identityIndexOf: self elementNotInForIndexAccessing
			ifAbsent: [ 55 ]) = 55
]

{ #category : #'tests - empty' }
LinkedListTest >> testIfEmpty [

	self nonEmpty ifEmpty: [ self assert: false] .
	self empty ifEmpty: [ self assert: true] .
	

	
]

{ #category : #'tests - empty' }
LinkedListTest >> testIfEmptyifNotEmpty [

	self assert: (self empty ifEmpty: [true] ifNotEmpty: [false]).
	self assert: (self nonEmpty ifEmpty: [false] ifNotEmpty: [true]).
	
]

{ #category : #'tests - empty' }
LinkedListTest >> testIfNotEmpty [

	self empty ifNotEmpty: [self assert: false].
	self nonEmpty ifNotEmpty: [self assert: true].
	self assert: (self nonEmpty ifNotEmpty: [:s | s ]) = self nonEmpty
	
]

{ #category : #'tests - empty' }
LinkedListTest >> testIfNotEmptyifEmpty [

	self assert: (self empty ifNotEmpty: [false] ifEmpty: [true]).
	self assert: (self nonEmpty ifNotEmpty: [true] ifEmpty: [false]).
	
]

{ #category : #'tests - includes' }
LinkedListTest >> testIncludesAllNoneThere [
	"self debug: #testIncludesAllOfNoneThere'"
	self deny: (self empty includesAllOf: self nonEmpty ).
	self deny: (self nonEmpty includesAllOf: { self elementNotIn. self anotherElementNotIn })
]

{ #category : #'tests - includes' }
LinkedListTest >> testIncludesAnyAllThere [
	"self debug: #testIncludesAnyOfAllThere'"
	self deny: (self nonEmpty includesAnyOf: self empty).
	self assert: (self nonEmpty includesAnyOf: { self nonEmpty anyOne }).
	self assert: (self nonEmpty includesAnyOf: self nonEmpty).
]

{ #category : #'tests - includes' }
LinkedListTest >> testIncludesAnyNoneThere [
	"self debug: #testIncludesAnyOfNoneThere'"
	
	self deny: (self nonEmpty includesAnyOf: self empty).
	self deny: (self nonEmpty includesAnyOf: { self elementNotIn. self anotherElementNotIn })
]

{ #category : #'tests - includes' }
LinkedListTest >> testIncludesElementIsNotThere [
	"self debug: #testIncludesElementIsNotThere"
	
	self deny: (self nonEmpty includes: self elementNotIn).
	self assert: (self nonEmpty includes: self nonEmpty anyOne).
	self deny: (self empty includes: self elementNotIn)
]

{ #category : #'tests - includes' }
LinkedListTest >> testIncludesElementIsThere [
	"self debug: #testIncludesElementIsThere"
	
	self assert: (self nonEmpty includes: self nonEmpty anyOne).
]

{ #category : #'tests - index access' }
LinkedListTest >> testIndexOf [
	"self debug: #testIndexOf"
	| tmp index collection |
	collection := self collectionMoreThan1NoDuplicates.
	tmp := collection size.
	collection reverseDo: 
		[ :each | 
		each = self elementInForIndexAccessing ifTrue: [ index := tmp ].
		tmp := tmp - 1 ].
	self assert: (collection indexOf: self elementInForIndexAccessing) = index
]

{ #category : #'tests - index access' }
LinkedListTest >> testIndexOfIfAbsent [
	"self debug: #testIndexOfIfAbsent"
	| collection |
	collection := self collectionMoreThan1NoDuplicates.
	self assert: (collection 
			indexOf: collection first
			ifAbsent: [ 33 ]) = 1.
	self assert: (collection 
			indexOf: self elementNotInForIndexAccessing
			ifAbsent: [ 33 ]) = 33
]

{ #category : #'tests - index access' }
LinkedListTest >> testIndexOfStartingAt [
	"self debug: #testLastIndexOf"
	| element collection |
	collection := self collectionMoreThan1NoDuplicates.
	element := collection first.
	self assert: (collection 
			indexOf: element
			startingAt: 2
			ifAbsent: [ 99 ]) = 99.
	self assert: (collection 
			indexOf: element
			startingAt: 1
			ifAbsent: [ 99 ]) = 1.
	self assert: (collection 
			indexOf: self elementNotInForIndexAccessing
			startingAt: 1
			ifAbsent: [ 99 ]) = 99
]

{ #category : #'tests - index access' }
LinkedListTest >> testIndexOfStartingAtIfAbsent [
	"self debug: #testLastIndexOf"
	| element collection |
	collection := self collectionMoreThan1NoDuplicates.
	element := collection first.
	self assert: (collection 
			indexOf: element
			startingAt: 2
			ifAbsent: [ 99 ]) = 99.
	self assert: (collection 
			indexOf: element
			startingAt: 1
			ifAbsent: [ 99 ]) = 1.
	self assert: (collection 
			indexOf: self elementNotInForIndexAccessing
			startingAt: 1
			ifAbsent: [ 99 ]) = 99
]

{ #category : #'tests - index access' }
LinkedListTest >> testIndexOfSubCollectionStartingAt [
	"self debug: #testIndexOfIfAbsent"
	| subcollection index collection |
	collection := self collectionMoreThan1NoDuplicates.
	subcollection := self collectionMoreThan1NoDuplicates.
	index := collection 
		indexOfSubCollection: subcollection
		startingAt: 1.
	self assert: index = 1.
	index := collection 
		indexOfSubCollection: subcollection
		startingAt: 2.
	self assert: index = 0
]

{ #category : #'tests - index access' }
LinkedListTest >> testIndexOfSubCollectionStartingAtIfAbsent [
	"self debug: #testIndexOfIfAbsent"
	| index absent subcollection collection |
	collection := self collectionMoreThan1NoDuplicates.
	subcollection := self collectionMoreThan1NoDuplicates.
	absent := false.
	index := collection 
		indexOfSubCollection: subcollection
		startingAt: 1
		ifAbsent: [ absent := true ].
	self assert: absent = false.
	absent := false.
	index := collection 
		indexOfSubCollection: subcollection
		startingAt: 2
		ifAbsent: [ absent := true ].
	self assert: absent = true
]

{ #category : #'tests - iterating' }
LinkedListTest >> testInjectInto [
	|result|
	result:= self collectionWithoutNilElements 
		inject: 0
		into: [:inj :ele | ele notNil ifTrue: [ inj + 1 ]].
	
	self assert: self collectionWithoutNilElements size = result .
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testIntersectionBasic [
	"self debug: #testIntersectionBasic"
	| inter |
	inter := self collection intersection: (self collectionClass with: self anotherElementOrAssociationIn).
	self deny: inter isEmpty.
	self assert: (inter includes: self anotherElementOrAssociationIn value)
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testIntersectionEmpty [
	"self debug: #testIntersectionEmpty"
	
	| inter |
	inter := self empty intersection: self empty.
	self assert: inter isEmpty. 
	inter := self empty intersection: self collection .
	self assert: inter =  self empty.
	
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testIntersectionItself [
	"self debug: #testIntersectionItself"
	
	| result |
	result :=  (self collectionWithoutEqualElements intersection: self collectionWithoutEqualElements).
	self assert: result size  = self collectionWithoutEqualElements size.
	self collectionWithoutEqualElements do: [ :each|
		self assert: (result includes: each) ].
	
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testIntersectionTwoSimilarElementsInIntersection [
	"self debug: #testIntersectionBasic"
	| inter |
	inter := self collection intersection: (self collectionClass with: self anotherElementOrAssociationIn).
	self assert: (self collection occurrencesOf: self anotherElementOrAssociationIn) = self numberOfSimilarElementsInIntersection.
	self assert: (inter includes: self anotherElementOrAssociationIn value)
]

{ #category : #'tests - empty' }
LinkedListTest >> testIsEmpty [

	self assert: (self empty isEmpty).
	self deny: (self nonEmpty isEmpty).
]

{ #category : #'tests - empty' }
LinkedListTest >> testIsEmptyOrNil [

	self assert: (self empty isEmptyOrNil).
	self deny: (self nonEmpty isEmptyOrNil).
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testKeysAndValuesDo [
	"| result |
	result:= OrderedCollection new.
	
	self nonEmptyMoreThan1Element  keysAndValuesDo: 
		[:i :value|
		result add: (value+i)].
	
	1 to: result size do:
		[:i|
		self assert: (result at:i)=((self nonEmptyMoreThan1Element at:i)+i)]"
	|  indexes elements |
	indexes:= OrderedCollection new.
	elements := OrderedCollection new.
	
	self nonEmptyMoreThan1Element  keysAndValuesDo: 
		[:i :value|
		indexes  add: (i).
		elements add: value].
	
	(1 to: self nonEmptyMoreThan1Element size )do:
		[ :i |
		self assert: (indexes at: i) = i.
		self assert: (elements at: i) = (self nonEmptyMoreThan1Element at: i).	
		].
	
	self assert: indexes size = elements size. 
	self assert: indexes size = self nonEmptyMoreThan1Element size . 
	
	
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testKeysAndValuesDoEmpty [
	| result |
	result:= OrderedCollection new.
	
	self empty  keysAndValuesDo: 
		[:i :value|
		result add: (value+i)].
	
	self assert: result isEmpty .
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testLast [
	"self debug: #testLast"
	self assert: self moreThan4Elements last = (self moreThan4Elements at: self moreThan4Elements size)
]

{ #category : #'tests - index access' }
LinkedListTest >> testLastIndexOf [
	"self debug: #testLastIndexOf"
	| element collection |
	collection := self collectionMoreThan1NoDuplicates.
	element := collection first.
	self assert: (collection lastIndexOf: element) = 1.
	self assert: (collection lastIndexOf: self elementNotInForIndexAccessing) = 0
]

{ #category : #'tests - index access' }
LinkedListTest >> testLastIndexOfIfAbsent [
	"self debug: #testIndexOfIfAbsent"
	| element collection |
	collection := self collectionMoreThan1NoDuplicates.
	element := collection first.
	self assert: (collection 
			lastIndexOf: element
			ifAbsent: [ 99 ]) = 1.
	self assert: (collection 
			lastIndexOf: self elementNotInForIndexAccessing
			ifAbsent: [ 99 ]) = 99
]

{ #category : #'tests - index access' }
LinkedListTest >> testLastIndexOfStartingAt [
	"self debug: #testLastIndexOf"
	| element collection |
	collection := self collectionMoreThan1NoDuplicates.
	element := collection last.
	self assert: (collection 
			lastIndexOf: element
			startingAt: collection size
			ifAbsent: [ 99 ]) = collection size.
	self assert: (collection 
			lastIndexOf: element
			startingAt: collection size - 1
			ifAbsent: [ 99 ]) = 99.
	self assert: (collection 
			lastIndexOf: self elementNotInForIndexAccessing
			startingAt: collection size
			ifAbsent: [ 99 ]) = 99
]

{ #category : #'tests - subcollections access' }
LinkedListTest >> testLastNElements [
	"self debug: #testLastNElements"
	| result |
	result := self moreThan3Elements last: self moreThan3Elements size - 1.
	1 
		to: result size
		do: [ :i | self assert: (result at: i) = (self moreThan3Elements at: i + 1) ].
	self assert: result size = (self moreThan3Elements size - 1).
	self 
		should: [ self moreThan3Elements last: self moreThan3Elements size + 1 ]
		raise: Error
]

{ #category : #'tests - element accessing' }
LinkedListTest >> testMiddle [
	"self debug: #testMiddle"
	self assert: self moreThan4Elements middle = (self moreThan4Elements at: self moreThan4Elements size // 2 + 1)
]

{ #category : #'tests - iterating' }
LinkedListTest >> testNoneSatisfy [

	| element |
	self assert: ( self collectionWithoutNilElements  noneSatisfy: [:each | each notNil not ] ).
	element := self collectionWithoutNilElements anyOne.
	self deny: ( self collectionWithoutNilElements  noneSatisfy: [:each | (each = element)not ] ).
]

{ #category : #'tests - iterating' }
LinkedListTest >> testNoneSatisfyEmpty [

	self assert: ( self empty noneSatisfy: [:each | false]).
	
]

{ #category : #'tests - empty' }
LinkedListTest >> testNotEmpty [

	self assert: (self nonEmpty  notEmpty).
	self deny: (self empty notEmpty).
]

{ #category : #'tests - occurrencesOf' }
LinkedListTest >> testOccurrencesOf [
	| collection |
	collection := self collectionWithoutEqualElements .
	
	collection do: [ :each | self assert: (collection occurrencesOf: each) = 1 ].
]

{ #category : #'tests - occurrencesOf' }
LinkedListTest >> testOccurrencesOfEmpty [
	| result |
	result := self empty occurrencesOf: (self collectionWithoutEqualElements anyOne).
	self assert: result = 0
]

{ #category : #'tests - occurrencesOf' }
LinkedListTest >> testOccurrencesOfNotIn [
	| result |
	result := self collectionWithoutEqualElements occurrencesOf: self elementNotInForOccurrences.
	self assert: result = 0
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testPairsCollect [
	
	| index result |
	index:=0.
	
	result:=self nonEmptyMoreThan1Element  pairsCollect: 
		[:each1 :each2 | 
		self assert: ( self nonEmptyMoreThan1Element indexOf: each2 ) = (index := index + 2).
		(self nonEmptyMoreThan1Element indexOf: each2) = ((self nonEmptyMoreThan1Element indexOf: each1) + 1).
		].
	
	result do: 
		[:each | self assert: each = true].
	

]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testPairsDo [
	| index |
	index:=1.
	
	self nonEmptyMoreThan1Element  pairsDo: 
		[:each1 :each2 | 
		self assert:(self nonEmptyMoreThan1Element at:index)=each1.
		self assert:(self nonEmptyMoreThan1Element at:(index+1))=each2.
		index:=index+2].
	
	self nonEmptyMoreThan1Element size odd
		ifTrue:[self assert: index=self nonEmptyMoreThan1Element size]
		ifFalse:[self assert: index=(self nonEmptyMoreThan1Element size+1)].
]

{ #category : #'tests - printing' }
LinkedListTest >> testPrintElementsOn [

	| aStream result allElementsAsString tmp |
	result:=''.
	aStream:= ReadWriteStream on: result.
	tmp:= OrderedCollection new.
	self nonEmpty do: [:each | tmp add: each asString].
	
	self nonEmpty printElementsOn: aStream .
	allElementsAsString:=(result findBetweenSubStrs: ' ' ).
	1 to: allElementsAsString size do:
		[:i | 
		self assert: (tmp occurrencesOf:(allElementsAsString at:i))=(allElementsAsString  occurrencesOf:(allElementsAsString at:i)).
			].
]

{ #category : #'tests - printing' }
LinkedListTest >> testPrintNameOn [

	| aStream result |
	result:=''.
	aStream:= ReadWriteStream on: result.
	self nonEmpty printNameOn: aStream.
	self nonEmpty class name first isVowel
		ifTrue:[ self assert: aStream contents =('an ',self nonEmpty class name ) ]
		ifFalse:[self assert: aStream contents =('a ',self nonEmpty class name)].
]

{ #category : #'tests - printing' }
LinkedListTest >> testPrintOn [
	| aStream result allElementsAsString tmp |
	result:=''.
	aStream:= ReadWriteStream on: result.
	tmp:= OrderedCollection new.
	self nonEmpty do: [:each | tmp add: each asString].
	
	self nonEmpty printOn: aStream .
	allElementsAsString:=(result findBetweenSubStrs: ' ' ).
	1 to: allElementsAsString size do:
		[:i | 
		i=1
			ifTrue:[
			self accessCollection class name first isVowel 
				ifTrue:[self assert: (allElementsAsString at:i)='an' ]
				ifFalse:[self assert: (allElementsAsString at:i)='a'].].
		i=2
			ifTrue:[self assert: (allElementsAsString at:i)=self accessCollection class name].
		i>2
			ifTrue:[self assert: (tmp occurrencesOf:(allElementsAsString at:i))=(allElementsAsString  occurrencesOf:(allElementsAsString at:i)).].	
			].
]

{ #category : #'tests - printing' }
LinkedListTest >> testPrintOnDelimiter [
	| aStream result allElementsAsString tmp |
	result:=''.
	aStream:= ReadWriteStream on: result.
	tmp:= OrderedCollection new.
	self nonEmpty do: [:each | tmp add: each asString].
	
	
	
	self nonEmpty printOn: aStream delimiter: ', ' .
	
	allElementsAsString:=(result findBetweenSubStrs: ', ' ).
	1 to: allElementsAsString size do:
		[:i | 
		self assert: (tmp occurrencesOf:(allElementsAsString at:i))=(allElementsAsString  occurrencesOf:(allElementsAsString at:i))
			].
]

{ #category : #'tests - printing' }
LinkedListTest >> testPrintOnDelimiterLast [

	| aStream result allElementsAsString tmp |
	result:=''.
	aStream:= ReadWriteStream on: result.
	tmp:= OrderedCollection new.
	self nonEmpty do: [:each | tmp add: each asString].
	
	self nonEmpty printOn: aStream delimiter: ', ' last: 'and'.
	
	allElementsAsString:=(result findBetweenSubStrs: ', ' ).
	1 to: allElementsAsString size do:
		[:i | 
		i<(allElementsAsString size-1 )
			ifTrue: [self assert: (tmp occurrencesOf: (allElementsAsString at:i))=(allElementsAsString  occurrencesOf: (allElementsAsString at:i))].
		i=(allElementsAsString size-1)
			ifTrue:[ self deny: (allElementsAsString at:i)=('and')asString].
		i=(allElementsAsString size)
			ifTrue: [self assert: (tmp occurrencesOf: (allElementsAsString at:i))=(allElementsAsString  occurrencesOf: (allElementsAsString at:i))].
			].
]

{ #category : #'tests - iterating' }
LinkedListTest >> testReject [

	| res element |
	res := self collectionWithoutNilElements reject: [:each | each notNil not].
	self assert: res size = self collectionWithoutNilElements size.
	
	element := self collectionWithoutNilElements anyOne.
	res := self collectionWithoutNilElements  reject: [:each | each = element].
	self assert: res size = (self collectionWithoutNilElements size - 1).
	
	
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testRejectAllThenCollect [
	| result |
	
	result := (self collectionWithoutNilElements 
		reject: [ :each | each notNil ] )
		collect: [ :each| self fail ].
	
	self assert: result isEmpty
]

{ #category : #'tests - iterating' }
LinkedListTest >> testRejectEmpty [

	| res |
	res := self empty reject: [:each | each odd].
	self assert: res size = self empty size
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testRejectNoReject [

	| res |
	res := self collectionWithoutNilElements  reject: [:each | each notNil not].
	self assert: res size = self collectionWithoutNilElements size.
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testRejectThenCollect [

	| result index selectIndex pivot |
	
	index := 0.
	selectIndex := 0.
	pivot := self collectionWithoutNilElements anyOne.
	
	result := (self collectionWithoutNilElements 
		reject: [ :each | 
			selectIndex := selectIndex + 1.
			"reject the first element"
			selectIndex = 1 ])
		collect: [ :each | 
			self assert: each notNil.
			index := index + 1.
			pivot ].
			
	self assert: result ~= self collectionWithoutNilElements.
	self assert: selectIndex equals: self collectionWithoutNilElements size.
	self assert: index equals: self collectionWithoutNilElements size - 1.
	
	self assert: (self collectionWithoutNilElements occurrencesOf: pivot) equals: 1.
	"should be > 1 for standard collection and = 1 for those that do not allow exact duplicates"
	self assert: (result occurrencesOf: pivot) >= 1.
	 
]

{ #category : #'tests - iterating' }
LinkedListTest >> testRejectThenCollectEmpty [

	self assert: ((self empty reject: [:e | self fail ]) collect: [ :each| self fail ]) isEmpty
]

{ #category : #'tests - iterating' }
LinkedListTest >> testRejectThenDoOnEmpty [

	self assert: (self empty reject: [:e | self fail ] thenDo: [ self fail ]) isEmpty
]

{ #category : #tests }
LinkedListTest >> testRemoveAll [
	| list2 |
	list add: link1.
	list add: link2.
	list add: link3.
	list add: link4.
	list2 := list copy.
	list removeAll.
	
	self assert: list size = 0.
	self assert: list2 size = 4 description: 'the copy has not been modified'
]

{ #category : #'tests - remove' }
LinkedListTest >> testRemoveAllError [
	"self debug: #testRemoveElementThatExists"
	| el aSubCollection |
	el := self elementNotIn.
	aSubCollection := self nonEmptyWithoutEqualElements copyWith: el.
	self 
		should: [ | res | res := self nonEmptyWithoutEqualElements removeAll: aSubCollection ]
		raise: Error
]

{ #category : #'tests - remove' }
LinkedListTest >> testRemoveAllFoundIn [
	"self debug: #testRemoveElementThatExists"
	| el aSubCollection res |
	el := self nonEmptyWithoutEqualElements anyOne.
	aSubCollection := (self nonEmptyWithoutEqualElements copyWithout: el) copyWith: self elementNotIn.
	res := self nonEmptyWithoutEqualElements removeAllFoundIn: aSubCollection.
	self assert: self nonEmptyWithoutEqualElements size = 1.
	self nonEmptyWithoutEqualElements do: [ :each | self assert: each = el ]
]

{ #category : #'tests - remove' }
LinkedListTest >> testRemoveAllSuchThat [
	"self debug: #testRemoveElementThatExists"
	| el aSubCollection |
	el := self nonEmptyWithoutEqualElements anyOne.
	aSubCollection := self nonEmptyWithoutEqualElements copyWithout: el.
	self nonEmptyWithoutEqualElements removeAllSuchThat: [ :each | aSubCollection includes: each ].
	self assert: self nonEmptyWithoutEqualElements size = 1.
	self nonEmptyWithoutEqualElements do: [ :each | self assert: each = el ]
]

{ #category : #'tests - remove' }
LinkedListTest >> testRemoveElementFromEmpty [
	"self debug: #testRemoveElementFromEmpty"
	self 
		should: [ self empty remove: self nonEmptyWithoutEqualElements anyOne ]
		raise: Error
]

{ #category : #'tests - remove' }
LinkedListTest >> testRemoveElementReallyRemovesElement [
	"self debug: #testRemoveElementReallyRemovesElement"
	| size |
	size := self nonEmptyWithoutEqualElements size.
	self nonEmptyWithoutEqualElements remove: self nonEmptyWithoutEqualElements anyOne.
	self assert: size - 1 = self nonEmptyWithoutEqualElements size
]

{ #category : #'tests - remove' }
LinkedListTest >> testRemoveElementThatExists [
	"self debug: #testRemoveElementThatExists"

	| el res |
	el := self nonEmptyWithoutEqualElements anyOne.
	res := self nonEmptyWithoutEqualElements remove: el.
	self assert: res == el
]

{ #category : #'tests - remove' }
LinkedListTest >> testRemoveIfAbsent [
	"self debug: #testRemoveElementThatExists"

	| el res |
	el := self elementNotIn.
	res := self nonEmptyWithoutEqualElements remove: el ifAbsent: [ 33 ].
	self assert: res = 33
]

{ #category : #'tests - copying same contents' }
LinkedListTest >> testReverse [

	| result |
	result := self nonEmpty reversed.	
	"verify content of 'result: '"
	1 to: result size do:
		[:i | self assert: ((result at: i) 
			= (self nonEmpty at: (self nonEmpty size - i + 1)))].
	"verify size of 'result' :"
	self assert: result size=self nonEmpty size.
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testReverseDo [
	| result |
	result:= OrderedCollection new.
	self nonEmpty reverseDo: [: each | result add: each].
	
	1 to: result size do:
		[:i|
		self assert: (result at: i)=(self nonEmpty at:(self nonEmpty size-i+1))].
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testReverseDoEmpty [
	| result |
	result:= OrderedCollection new.
	self empty reverseDo: [: each | result add: each].
	
	self assert: result isEmpty .
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testReverseWithDo [
	
	| firstCollection secondCollection index |

	firstCollection := self nonEmptyMoreThan1Element.
	secondCollection := firstCollection copy.
	index := firstCollection size.
	
	firstCollection  reverseWith: secondCollection do:
		[:a :b |
	
		self assert: (firstCollection at: index) equals:  a. 
		self assert: (secondCollection at: index) equals:  b.
			( index := index - 1).]
	
	
	
]

{ #category : #'tests - copying same contents' }
LinkedListTest >> testReversed [
	| result |
	result := self nonEmpty reversed .
	
	"verify content of 'result: '"
	1 to:  result size do:
		[:i | self assert: ((result at:i)=(self nonEmpty at:(self nonEmpty size-i+1)))].
	"verify size of 'result' :"
	self assert: result size=self nonEmpty size.
]

{ #category : #'tests - iterating' }
LinkedListTest >> testSelect [

	| result element |
	result := self collectionWithoutNilElements select: [ :each | each notNil].
	self assert: result size equals: self collectionWithoutNilElements size.
	
	element := self collectionWithoutNilElements anyOne.
	result := self collectionWithoutNilElements select: [ :each | (each = element) not].
	self assert: result size equals: (self collectionWithoutNilElements size - 1).
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testSelectNoneThenCollect [
	| result |
	
	result := self collectionWithoutNilElements 
		select: [ :each | each isNil ] 
		thenCollect: [ :each| self fail ].
	
	self assert: result isEmpty
]

{ #category : #'tests - iterating' }
LinkedListTest >> testSelectOnEmpty [

	self assert: (self empty select: [:e | self fail]) isEmpty
	
]

{ #category : #'tests - iterating' }
LinkedListTest >> testSelectThenCollect [

	| result index selectIndex pivot |
	
	index := 0.
	selectIndex := 0.
	pivot := self collectionWithoutNilElements anyOne.
	
	result := self collectionWithoutNilElements 
		select: [ :each | 
			selectIndex := selectIndex + 1.
			"reject the first element"
			selectIndex > 1 ]
		thenCollect: [ :each | 
			self assert: each notNil.
			index := index + 1.
			pivot ].
			
	self assert: result ~= self collectionWithoutNilElements.
	self assert: selectIndex equals: self collectionWithoutNilElements size.
	self assert: index equals: self collectionWithoutNilElements size - 1.
	
	self assert: (self collectionWithoutNilElements occurrencesOf: pivot) equals: 1.
	"should be > 1 for standard collection and = 1 for those that do not allow exact duplicates"
	self assert: (result occurrencesOf: pivot) >= 1.
	 
]

{ #category : #'tests - iterating' }
LinkedListTest >> testSelectThenCollectOnEmpty [

	self assert: (self empty select: [:e | self fail ] thenCollect: [ self fail ]) isEmpty
]

{ #category : #'tests - iterating' }
LinkedListTest >> testSelectThenDoOnEmpty [

	self assert: (self empty select: [:e | self fail ] thenDo: [ self fail ]) isEmpty
]

{ #category : #'tests - copying same contents' }
LinkedListTest >> testShallowCopy [
	| result |
	result := self nonEmpty shallowCopy .
	
	"verify content of 'result: '"
	1 to: self nonEmpty size do:
		[:i | self assert: ((result at:i)=(self nonEmpty at:i))].
	"verify size of 'result' :"
	self assert: result size=self nonEmpty size.
]

{ #category : #'tests - copying same contents' }
LinkedListTest >> testShallowCopyEmpty [
	| result |
	result := self empty shallowCopy .
	self assert: result isEmpty .
]

{ #category : #'tests - copying same contents' }
LinkedListTest >> testShuffled [
	| result |
	result := self nonEmpty shuffled .
	
	"verify content of 'result: '"
	result do: [:each | self assert: (self nonEmpty occurrencesOf: each)=(result occurrencesOf: each)].
	"verify size of 'result' :"
	self assert: result size=self nonEmpty size.
]

{ #category : #'tests - printing' }
LinkedListTest >> testStoreOn [
" for the moment work only for collection that include simple elements such that Integer"

"| string str result cuttedResult index elementsAsStringExpected elementsAsStringObtained tmp |
string := ''.
str := ReadWriteStream  on: string.
elementsAsStringExpected := OrderedCollection new.
elementsAsStringObtained := OrderedCollection new.
self nonEmpty do: [ :each | elementsAsStringExpected  add: each asString].

self nonEmpty storeOn: str.
result := str contents .
cuttedResult := ( result findBetweenSubStrs: ';' ).

index := 1.

cuttedResult do:
	[ :each |
	index = 1 
		ifTrue: [ self assert: (each beginsWith: ( tmp := '((' , self nonEmpty class asString , ' new) add: '           )).
				tmp := each copyFrom: ( tmp size + 1) to: ( each size ).
				elementsAsStringObtained add: tmp.
				index := index + 1. ]
		ifFalse:  [ 
		 index < cuttedResult size
			ifTrue:[self assert: (each beginsWith: ( tmp:=  ' add: '   )).
				tmp := each copyFrom: ( tmp size + 1) to: ( each size ).
				elementsAsStringObtained add: tmp.
					index := index + 1.]
			ifFalse: [self assert: ( each = ' yourself)' ) ].
			]
	
	].


	elementsAsStringExpected do: [ :each | self assert: (elementsAsStringExpected occurrencesOf: each ) = ( elementsAsStringObtained occurrencesOf: each) ]"


]

{ #category : #'tests - iterating' }
LinkedListTest >> testSumNumbers [
	|result|
	result:= self collectionWithoutNilElements 
		detectSum: [ :ele | ele notNil ifTrue: [ 1 ] ifFalse: [ 0 ]].
	
	self assert: self collectionWithoutNilElements size = result
]

{ #category : #'tests - swap' }
LinkedListTest >> testSwapAdjacent [
	|aList|
	aList := LinkedList with: 5 with: 4 with: 3 with: 2 with: 1.
	
	aList swap: 3 with: 4.
	self assert: (aList at: 3) equals: 2.
	self assert: (aList at: 4) equals: 3.
]

{ #category : #'tests - swap' }
LinkedListTest >> testSwapAdjacentEnd [
	|aList|
	aList := LinkedList with: 5 with: 4 with: 3 with: 2 with: 1.
	
	aList swap: 4 with: 5.
	self assert: (aList at: 4) equals: 1.
	self assert: (aList at: 5) equals: 2.
	self assert: aList last equals: 2.
]

{ #category : #'tests - swap' }
LinkedListTest >> testSwapAdjacentStart [
	|aList|
	aList := LinkedList with: 5 with: 4 with: 3 with: 2 with: 1.
	
	aList swap: 1 with: 2.
	self assert: (aList at: 1) equals: 4.
	self assert: (aList at: 2) equals: 5.
	self assert: aList first equals: 4.
]

{ #category : #'tests - swap' }
LinkedListTest >> testSwapBasic [
	|aList|
	aList := LinkedList with: 5 with: 4 with: 3 with: 2 with: 1.
	
	aList swap: 2 with: 4.
	self assert: (aList at: 2) equals: 2.
	self assert: (aList at: 4) equals: 4.

]

{ #category : #'tests - swap' }
LinkedListTest >> testSwapStartAndEnd [
	|aList|
	aList := LinkedList with: 5 with: 4 with: 3 with: 2 with: 1.
	
	aList swap: 1 with: 5.
	self assert: (aList at: 1) equals: 1.
	self assert: (aList at: 5) equals: 5.
	self assert: aList first equals: 1.
	self assert: aList last equals: 5.
]

{ #category : #'tests - adding' }
LinkedListTest >> testTAdd [

	| added |
	added := self otherCollection add: self element.
	self assert: added = self element. "equality or identity ?"
	self assert: (self otherCollection includes: self element).

	
]

{ #category : #'tests - adding' }
LinkedListTest >> testTAddAll [
	| added collection toBeAdded |
	collection := self collectionWithElement .
	toBeAdded := self otherCollection .
	added := collection addAll: toBeAdded .
	self assert: added == toBeAdded .	"test for identiy because #addAll: has not reason to copy its parameter."
	self assert: (collection includesAllOf: toBeAdded )
]

{ #category : #'tests - adding' }
LinkedListTest >> testTAddIfNotPresentWithElementAlreadyIn [

	| added oldSize collection anElement |
	collection := self collectionWithElement .
	oldSize := collection size.
	anElement := self element .
	self assert: (collection  includes: anElement ).
	
	added := collection  addIfNotPresent: anElement .
	
	self assert: added == anElement .	"test for identiy because #add: has not reason to copy its parameter."
	self assert: collection  size = oldSize
]

{ #category : #'tests - adding' }
LinkedListTest >> testTAddIfNotPresentWithNewElement [

	| added oldSize collection elem |
	collection := self otherCollection .
	oldSize := collection  size.
	elem := self element .
	self deny: (collection  includes: elem ).
	
	added := collection  addIfNotPresent: elem .
	self assert: added == elem . "test for identiy because #add: has not reason to copy its parameter."
	self assert: (collection  size = (oldSize + 1)).

	
]

{ #category : #'tests - adding' }
LinkedListTest >> testTWrite [
	| added collection elem |
	collection := self otherCollection  .
	elem := self element .
	added := collection  write: elem .
	
	self assert: added == elem .	"test for identiy because #add: has not reason to copy its parameter."
	self assert: (collection  includes: elem )	.
	self assert: (collection  includes: elem ).
	
	
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testUnion [
	"self debug: #testUnionOfEmpties"
	
	| union |
	union := self empty union: self nonEmpty.
	self containsAll: union of: self empty andOf: self nonEmpty.
	union := self nonEmpty union: self empty.
	self containsAll: union of: self empty andOf: self nonEmpty.
	union := self collection union: self nonEmpty.
	self containsAll: union of: self collection andOf: self nonEmpty.
]

{ #category : #'tests - set arithmetic' }
LinkedListTest >> testUnionOfEmpties [
	"self debug: #testUnionOfEmpties"
	
	self assert:  (self empty union: self empty) isEmpty.
	
	
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testWithCollect [
	
	| result firstCollection secondCollection index  |

	firstCollection := self nonEmptyMoreThan1Element.
	secondCollection := firstCollection copy.
	index := 0.
	
	result := firstCollection  with: secondCollection collect:
		[:a :b |
		( index := index + 1).
		self assert: (firstCollection at: index) equals:  a. 
		self assert: (secondCollection at: index) equals:  b.
		b].
	
	1 to: result size do:[: i | self assert: (result at:i)= (secondCollection  at: i)].
	self assert: result size = secondCollection  size.
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testWithCollectError [
	self should: [self nonEmptyMoreThan1Element with: self empty collect:[:a :b | ]] raise: Error.
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testWithDo [
	
	| firstCollection secondCollection index |

	firstCollection := self nonEmptyMoreThan1Element.
	secondCollection := firstCollection copy.
	index := 0.
	
	firstCollection  with: secondCollection do:
		[:a :b |
		( index := index + 1).
		self assert: (firstCollection at: index) equals:  a. 
		self assert: (secondCollection at: index) equals:  b.]
	
	
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testWithDoError [
	
	self should: [self nonEmptyMoreThan1Element with: self empty do:[:a :b | ]] raise: Error.
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testWithIndexCollect [
	
	| result index collection |
	index := 0.
	collection := self nonEmptyMoreThan1Element .
	result := collection  withIndexCollect: [:each :i | 
		self assert: i = (index := index + 1).	
		self assert: i = (collection  indexOf: each) .
		each] . 
	
	1 to: result size do:[: i | self assert: (result at:i)= (collection at: i)].
	self assert: result size = collection size.
]

{ #category : #'tests - iterate on sequenced reable collections' }
LinkedListTest >> testWithIndexDo [
	
	"| result |
	result:=Array new: self nonEmptyMoreThan1Element size.
	self nonEmptyMoreThan1Element  withIndexDo: [:each :i | result at:i put:(each+i)].
	
	1 to: result size do:[: i | self assert: (result at:i)= ((self nonEmptyMoreThan1Element at: i) + i)]"
	|  indexes elements |
	indexes:= OrderedCollection new.
	elements := OrderedCollection new.
	
	self nonEmptyMoreThan1Element  withIndexDo: 
		[:value :i  |
		indexes  add: (i).
		elements add: value].
	
	(1 to: self nonEmptyMoreThan1Element size )do:
		[ :i |
		self assert: (indexes at: i) = i.
		self assert: (elements at: i) = (self nonEmptyMoreThan1Element at: i).	
		].
	
	self assert: indexes size = elements size. 
	self assert: indexes size = self nonEmptyMoreThan1Element size . 
	
]

{ #category : #'tests - begins ends with' }
LinkedListTest >> testsBeginsWith [
	
	self assert: (self nonEmpty beginsWith:(self nonEmpty copyUpTo: self nonEmpty last)).
	self assert: (self nonEmpty beginsWith:(self nonEmpty )).
	self deny: (self nonEmpty beginsWith:(self nonEmpty copyWith:self nonEmpty first)).
]

{ #category : #'tests - begins ends with' }
LinkedListTest >> testsBeginsWithEmpty [
	
	self deny: (self nonEmpty beginsWith:(self empty)).
	self deny: (self empty beginsWith:(self nonEmpty )).

]

{ #category : #'tests - begins ends with' }
LinkedListTest >> testsEndsWith [
	
	self assert: (self nonEmpty endsWith: self nonEmpty copyWithoutFirst).
	self assert: (self nonEmpty endsWith: self nonEmpty).
	self deny: (self nonEmpty endsWith: (self nonEmpty copyWith: self nonEmpty first)).
]

{ #category : #'tests - begins ends with' }
LinkedListTest >> testsEndsWithEmpty [
	
	self deny: (self nonEmpty endsWith: self empty).
	self deny: (self empty endsWith: self nonEmpty).
	
]
