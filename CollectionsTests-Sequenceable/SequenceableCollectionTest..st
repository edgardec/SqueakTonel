Class {
	#name : #SequenceableCollectionTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #'tests - testing' }
SequenceableCollectionTest >> testAfterIfAbsent [

	| col |
	col := #(2 3 4).
	self assert: ((col after: 4 ifAbsent: ['block']) = 'block').
	self assert: ((col after: 5 ifAbsent: ['block']) = 'block').
	self assert: ((col after: 2 ifAbsent: ['block']) = 3).
]

{ #category : #'tests - accessing' }
SequenceableCollectionTest >> testAtAllPut [
	|table|.
	table := Array new: 5.
	table atAllPut: $a.
	self assert: (table allSatisfy: [:elem | elem = $a])
]

{ #category : #'tests - testing' }
SequenceableCollectionTest >> testBeforeIfAbsent [

	| col |
	col := #(2 3 4).	
	self assert: ((col before: 2 ifAbsent: ['block']) = 'block').
	self assert: ((col before: 5 ifAbsent: ['block']) = 'block').
	self assert: ((col before: 3 ifAbsent: ['block']) = 2).
]

{ #category : #'tests - testing' }
SequenceableCollectionTest >> testBeginsWith [
	"We can't test SequenceableCollection directly. However, we can test a sampling of its descendants."

	| la prefix oc |
	la := #(1 2 3 4 5 6).
	oc := OrderedCollection new.
	oc add: 1; add: 2; add: 3.

	self assert: (la beginsWith: #(1)).
	self assert: (la beginsWith: #(1 2)).
	self assert: (la beginsWith: #(1 2 3)).
	self assert: (la beginsWith: oc).
	self deny: (la beginsWith: #()).
	self deny: (la beginsWith: '').
	self deny: (la beginsWith: OrderedCollection new).
	
	self assert: (oc beginsWith: #(1 2)).
	
	prefix := OrderedCollection new.
	self deny: (oc beginsWith: prefix).
	prefix add: 1.
	self assert: (oc beginsWith: prefix).
	prefix add: 2.
	self assert: (oc beginsWith: prefix).
	prefix add: 3.
	self assert: (oc beginsWith: prefix).
	prefix add: 4.
	self deny: (oc beginsWith: prefix).
]

{ #category : #'tests - testing' }
SequenceableCollectionTest >> testBeginsWithAnyOf [
	"We can't test SequenceableCollection directly. However, we can test a sampling of its descendants."

	| la oc |
	la := #(1 2 3 4 5 6).
	oc := OrderedCollection new.
	oc add: 1; add: 2; add: 3.

	self assert: (la beginsWithAnyOf: #((17) (1) (42))).
	self assert: (la beginsWithAnyOf: #((17) (1 2) (42))).
	self assert: (la beginsWithAnyOf: #((17) (1 2 3) (42))).
	self deny: (la beginsWithAnyOf: #()).
	self deny: (la beginsWithAnyOf: #(())).
	self deny: (la beginsWithAnyOf: #((42))).

]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testConcatenation [

	self assert: #( (1 2) (3 4) ) concatenation = #(1 2 3 4).
	self assert: #( (1 2) ( (3 4) ) ) concatenation = #(1 2 (3 4)).
	self should: [#(1 2 3 4) concatenation] raise: Error.

	self assert: #() concatenation = #().
	self assert: #( (1 2) () (3) ()) concatenation = #(1 2 3).
]

{ #category : #'tests - copying' }
SequenceableCollectionTest >> testCopyWith [
	| table |
	table := Array new: 4 withAll: 3.
	self assert: table = #(3 3 3 3).
	table := table copyWith: 4.
	self assert: table = #(3 3 3 3 4).
]

{ #category : #'tests - testing' }
SequenceableCollectionTest >> testEndsWith [
	"We can't test SequenceableCollection directly. However, we can test a sampling of its descendants."

	| la oc suffix |
	la := #(1 2 3 4 5 6).
	oc := OrderedCollection new.
	oc add: 4; add: 5; add: 6.
	
	self assert: (la endsWith: #(6)).
	self assert: (la endsWith: #(5 6)).
	self assert: (la endsWith: #(4 5 6)).
	self assert: (la endsWith: oc).
	self deny: (la endsWith: #()).
	self deny: (la endsWith: '').
	
	suffix := OrderedCollection new.
	suffix add: 6.
	self assert: (oc endsWith: suffix).
	suffix addFirst: 5.
	self assert: (oc endsWith: suffix).
	suffix addFirst: 4.
	self assert: (oc endsWith: suffix).
	suffix addFirst: 3.
	self deny: (oc endsWith: suffix).
]

{ #category : #'tests - testing' }
SequenceableCollectionTest >> testEndsWithAnyOf [
	"We can't test SequenceableCollection directly. However, we can test a sampling of its descendants."

	| la oc |
	la := #(6 5 4 3 2 1).
	oc := OrderedCollection new.
	oc add: 3; add: 2; add: 1.

	self assert: (la endsWithAnyOf: #((17) (1) (42))).
	self assert: (la endsWithAnyOf: #((17) (2 1) (42))).
	self assert: (la endsWithAnyOf: #((17) (3 2 1) (42))).
	self deny: (la endsWithAnyOf: #()).
	self deny: (la endsWithAnyOf: #(())).
	self deny: (la endsWithAnyOf: #((42))).

]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testEvalStrings [
	| table |
	table := #('String new' 'Array with: 3 with: $a' '15+4').
	table := table evalStrings.

	self assert: table first isString.
	self assert: table first isEmpty.
	
	self assert: table second isArray.
	self assert: table second first = 3.
	self assert: table second second = $a.
	
	self assert: table third = 19.
]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testFlatten [

	self
		assert: {3 .4 .2 .4 .'hi' .'ho'}
		equals: {3 .4 .{2 .4 .{'hi'} .'ho'}} flatten
		description: '#flatten should deeply inline all collection-like elements'.
	self
		assert: #( (1 2) (3 4) ) concatenation
		equals: #( (1 2) (3 4) ) flatten
		description: '#flatten of one-level collection-nesting should be the same as its concatenation'.

]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testFlatten2 [

	self
		assert: {3 .4 .2 .4 .'hi' .'ho'}
		equals: {3 .4 .{2 .4 .{'hi'} .'ho'} readStream } flatten
		description: '#flatten should deeply inline all collection-like elements and work with streams'.
]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testFlattened [

	| randomCollection |
	self
		assert: {3 .4 .2 .4 .'hi' .'ho'}
		equals: {3 .4 .{2 .4 .{'hi'} .'ho'}} flattened
		description: '#flattened should deeply inline all collection-like elements'.
	self
		assert: #( (1 2) (3 4) ) concatenation
		equals: #( (1 2) (3 4) ) flattened
		description: '#flattened of one-level collection-nesting should be the same as its concatenation'.
	
	" ensure that #flatten and #flattened are compatible "
	randomCollection := OrderedCollection new: 10.
	10 timesRepeat: [randomCollection add: 50 atRandom].
	
	self
		assert: randomCollection flatten
		equals: randomCollection flattened
		description: '#flatten and #flattened should be exchangeable'
	
]

{ #category : #'tests - copying' }
SequenceableCollectionTest >> testGroupsDo [

	| array |
	array := (1 to: 12) asArray.
	self should: [ array groupsDo: [ ] ] raise: Error.
	self assert: array equals: (Array streamContents: [ :stream |
		array groupsDo: [ :each | stream nextPut: each ] ]).
	self assert: #((1 2) (3 4) (5 6) (7 8) (9 10) (11 12)) equals: (Array streamContents: [ :stream |
		array groupsDo: [ :a :b | 
			stream nextPut: { a. b } ] ]).
	self assert: #((1 2 3) (4 5 6) (7 8 9) (10 11 12)) equals: (Array streamContents: [ :stream |
		array groupsDo: [ :a :b :c | 
			stream nextPut: { a. b. c } ] ]).
	self assert: #((1 2 3 4) (5 6 7 8) (9 10 11 12)) equals: (Array streamContents: [ :stream |
		array groupsDo: [ :a :b :c :d | 
			stream nextPut: { a. b. c. d } ] ]).
	self assert: #((1 2 3 4 5) (6 7 8 9 10)) equals: (Array streamContents: [ :stream |
		array groupsDo: [ :a :b :c :d :e | 
			stream nextPut: { a. b. c. d. e } ] ]).
	self assert: #((1 2 3 4 5 6) (7 8 9 10 11 12)) equals: (Array streamContents: [ :stream |
		array groupsDo: [ :a :b :c :d :e :f | 
			stream nextPut: { a. b. c. d. e. f } ] ]).
	self assert: #((1 2 3 4 5 6 7)) equals: (Array streamContents: [ :stream |
		array groupsDo: [ :a :b :c :d :e :f :g | 
			stream nextPut: { a. b. c. d. e. f. g } ] ]).
	self assert: #() equals: (Array streamContents: [ :stream |
		#(1 2 3) groupsDo: [ :a :b :c :d | stream nextPut: { a. b. c. d } ] ])


]

{ #category : #'tests - accessing' }
SequenceableCollectionTest >> testIndexOfSubCollectionStartingAt [
	| c |
	c := 'abcdefg' asArray. "NB. As of Collections-topa.733, String already permitted out-of-bounds start indexes, so we are careful here to select the SequenceableCollection implementation by using asArray."
	self assert: (c indexOfSubCollection: 'cde' startingAt: 400) = 0.
	self assert: (c indexOfSubCollection: 'cde' startingAt: 4) = 0.
	self assert: (c indexOfSubCollection: 'cde' startingAt: 1) = 3.
	self assert: (c indexOfSubCollection: 'cde' startingAt: 0) = 3.
	self assert: (c indexOfSubCollection: 'cde' startingAt: -1) = 3.

	self assert: (c indexOfSubCollection: 'abcdefg' startingAt: 400) = 0.
	self assert: (c indexOfSubCollection: 'abcdefg' startingAt: 4) = 0.
	self assert: (c indexOfSubCollection: 'abcdefg' startingAt: 1) = 1.
	self assert: (c indexOfSubCollection: 'abcdefg' startingAt: 0) = 1.
	self assert: (c indexOfSubCollection: 'abcdefg' startingAt: -1) = 1.

	self assert: (c indexOfSubCollection: 'abcdefghij' startingAt: 400) = 0.
	self assert: (c indexOfSubCollection: 'abcdefghij' startingAt: 4) = 0.
	self assert: (c indexOfSubCollection: 'abcdefghij' startingAt: 1) = 0.
	self assert: (c indexOfSubCollection: 'abcdefghij' startingAt: 0) = 0.
	self assert: (c indexOfSubCollection: 'abcdefghij' startingAt: -1) = 0.

]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testJoin [

	self assert: #(a b c d e) join = 'abcde'.
	self assert: (#(a b c) joinSeparatedBy: '|') = 'a|b|c'.
]

{ #category : #'tests - arithmetic' }
SequenceableCollectionTest >> testPreMultiplyByArray [
	| array|.

	array := #(3).
	self assert:(array preMultiplyByArray: 2)=6.
	
	array := Array new: 4.
	self should:[array preMultiplyByArray: 2] raise:Error.
]

{ #category : #'tests - arithmetic' }
SequenceableCollectionTest >> testPreMultiplyByMatrix [
	| array matrix result|.
	array := #(1 2 3 4 5).
	
	"( 1  2  3  4  5
	  10 20 30 40 50)"
	matrix := Matrix
				rows:2 columns:5 tabulate: [:row :column | row = 1 
											ifTrue: column
											ifFalse: column * 10].
	result := array preMultiplyByMatrix: matrix.
	self assert: result isArray.
	self assert: result size = 2.
	self assert: result first = 55.
	self assert: result second = 550.
]

{ #category : #'tests - arithmetic' }
SequenceableCollectionTest >> testPreMultiplyByMatrix2 [
	| array matrix|.
	
	array := #(1 2 3 4 5).
	matrix := Matrix rows:1 columns:4 tabulate: [:row :column | column].
	
	"Not compatible size"
	self should:[array preMultiplyByMatrix: matrix] raise: Error.
]

{ #category : #'tests - accessing' }
SequenceableCollectionTest >> testReplaceFromToWithStartingAt [
	| string |

	string := 'abcd' copy.
	string replaceFrom: 1 to: 3 with: 'lmnop' startingAt: 1.
	self assert: string = 'lmnd'.
	
	string := 'abcd' copy.
	string replaceFrom: 1 to: 3 with: 'lmnop' startingAt: 2.
	self assert: string = 'mnod'.
	
	string := 'abcd' copy.
	string replaceFrom: 2 to: 3 with: 'lmnop' startingAt: 1.
	self assert: string = 'almd'.
]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testSplitAndJoin [

	self assert: (('a|b|c' splitBy: '|') joinSeparatedBy: '|') = 'a|b|c'.
]

{ #category : #'tests - converting' }
SequenceableCollectionTest >> testSplitBy [
	"Tests for  splitBy: and splitBy:do:"

	self assert: ('a/b' splitBy: '/') = #('a' 'b').
	self assert: ('a/b/' splitBy: '/') = #('a' 'b' '').
	self assert: ('/a/b/' splitBy: '/') = #('' 'a' 'b' '').
	self assert: ('///' splitBy: '/') = #('' '' '' '').
	self assert: ('/' splitBy: '/') = #('' '').
	self assert: ('a' splitBy: '/') = #('a').
	self assert: ('' splitBy: '/') = #('').

	self assert: ('a//b' splitBy: '//') = #('a' 'b').
	self assert: ('///' splitBy: '//') = #('' '/').

	self assert: ('Hello<p>World<p>' splitBy: '<p>') = #('Hello' 'World' '').

]

{ #category : #'tests - enumerating' }
SequenceableCollectionTest >> testWithCollect [

	| c1 c2 |
	c1 := #(1 2 3).
	c2 := #(4 5 6).

	self assert: #(4 10 18) equals: (c1 with: c2 collect: [:a :b | a * b]).
]

{ #category : #'tests - enumerating' }
SequenceableCollectionTest >> testWithDo [

	| c1 c2 i |
	c1 := #(1 2 3).
	c2 := #(a b).

	self
		should: [c1 with: c2 do: [:ea1 :ea2 | ] ]
		raise: Error.

	c2 := #(a b c).
	i := 0.
	c1 with: c2 do: [:number :letter |
		i := i + 1.
		self assert: (c1 at: i) equals: number.
		self assert: (c2 at: i) equals: letter].
]

{ #category : #'tests - copying' }
SequenceableCollectionTest >> testWithoutDuplicates [

	self assert: #(1 3 5 7 9 2 4 6 8 10)
		equals: ((1 to: 10 by: 2), (1 to: 10 by: 2), (2 to: 11 by: 2), (2 to: 11 by: 2)) withoutDuplicates
]
