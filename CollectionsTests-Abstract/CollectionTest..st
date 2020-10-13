"
A TestCase is a Command representing the future running of a test case. Create one with the class method #selector: aSymbol, passing the name of the method to be run when the test case runs.

When you discover a new fixture, subclass TestCase, declare instance variables for the objects in the fixture, override #setUp to initialize the variables, and possibly override# tearDown to deallocate any external resources allocated in #setUp.

When you are writing a test case method, send #assert: aBoolean when you want to check for an expected value. For example, you might say ""self assert: socket isOpen"" to test whether or not a socket is open at a point in a test.
"
Class {
	#name : #CollectionTest,
	#superclass : #TestCase,
	#instVars : [
		'empty',
		'nonEmpty'
	],
	#category : #'CollectionsTests-Abstract'
}

{ #category : #running }
CollectionTest >> setUp [
	empty := Set new.
	nonEmpty := OrderedCollection with: #x
]

{ #category : #tests }
CollectionTest >> testAny [

	{
		"{ numberOfElements. originalCollection }"
		{ 2. Array withAll: #(1 2 3 4) }.
		{ 4. Array withAll: #(1 2 3 4) }.
		{ 0. Array withAll: #(1 2 3 4) }.
		{ 2. OrderedCollection withAll: #(1 2 3 4) }.
		{ 2. Dictionary withAll: { #apple -> #red. #plum -> #purple. #peach -> #orange } }.			
		{ 2. Set withAll: #(1 2 3 4) }.
		{ 2. Bag withAll: #(1 1 2 2) }.
	} do: [:spec | | result |
		result := spec second any: spec first.
		self
			assert: (spec second includesAllOf: result);
			assert: spec first equals: result size;
			assert: spec second class equals: result class].
]

{ #category : #tests }
CollectionTest >> testAnyAs [

	{
		"{ numberOfElements. expectedSize. resultKind. originalCollection }"
		{ 2. 2. OrderedCollection. Array withAll: #(1 2 3 4) }.
		{ 4. 1. Set. Array withAll: #(1 1 1 1) }.
		{ 4. 4. Bag. Array withAll: #(1 1 1 1) }.
		{ 2. 2. Dictionary. Array withAll: { #apple -> #red. #plum -> #purple. #peach -> #orange } }.			
	} do: [:spec | | result |
		result := spec fourth any: spec first as: spec third.
		
		"For Array vs. Dictionary, #includesAllOf: does not work because it would just iterate the values in the dictionary."
		(result associationsDo: [:each | self assert: (spec fourth includes: each)]).
		
		self
			assert: spec second equals: result size;
			assert: spec third equals: result class].
]

{ #category : #tests }
CollectionTest >> testAnyError [

	self
		should: [#(1 2 3 4) any: 5] raise: Error; "Too small."
		should: [#(1 2 3 4) any: -1] raise: Error. "Bad argument."
]

{ #category : #tests }
CollectionTest >> testAnyStreams [

	{
		"{ numberOfElements. expectedSize. originalCollection }"
		{ 2. 2. Array withAll: #(1 2 3 4) }.
		{ 4. 4. Array withAll: #(1 2 3 4) }.
		{ 0. 0. Array withAll: #(1 2 3 4) }.
		{ 10. 4. Array withAll: #(1 2 3 4) }. "No error for streams."
		{ 2. 2. OrderedCollection withAll: #(1 2 3 4) }.
	} do: [:spec | | result |
		result := spec third readStream any: spec first.
		self
			assert: (spec third includesAllOf: result);
			assert: spec second equals: result size;
			assert: spec third class equals: result class].
]

{ #category : #tests }
CollectionTest >> testAsCommaString [
	{OrderedCollection new. Set new.} do:
		[ :coll |
		self assert: coll asCommaString = ''.

		coll add: 1.
		self assert: coll asCommaString = '1'.

		coll add: 2; add: 3.
		self assert: coll asCommaString = '1, 2, 3'].
]

{ #category : #tests }
CollectionTest >> testAsCommaStringAnd [
	{OrderedCollection new. Set new.} do:
		[ :coll |
		self assert: coll asCommaStringAnd = ''.

		coll add: 1.
		self assert: coll asCommaStringAnd = '1'.

		coll add: 2; add: 3.
		self assert: coll asCommaStringAnd = '1, 2 and 3'].
]

{ #category : #tests }
CollectionTest >> testAsStringOnDelimiter [
	| delim |
	delim := ', '.
	{OrderedCollection new. Set new.} do:
		[ :coll | | oneItemStream emptyStream multiItemStream |
		emptyStream := String new writeStream.
		coll asStringOn: emptyStream delimiter: delim.
		self assert: emptyStream contents = ''.

		coll add: 1.
		oneItemStream := String new writeStream.
		coll asStringOn: oneItemStream delimiter: delim.
		self assert: oneItemStream contents = '1'.

		coll add: 2; add: 3.
		multiItemStream := String new writeStream.
		coll asStringOn: multiItemStream delimiter: ', '.
		self assert: multiItemStream contents = '1, 2, 3'.]
]

{ #category : #tests }
CollectionTest >> testAsStringOnDelimiterLast [
	| delim last |
	delim := ', '.
	last := ' & '.
	{OrderedCollection new. Set new.} do:
		[ :coll | | multiItemStream emptyStream oneItemStream |
		emptyStream := String new writeStream.
		coll asStringOn: emptyStream delimiter: delim last: last.
		self assert: emptyStream contents = ''.

		coll add: 1.
		oneItemStream := String new writeStream.
		coll asStringOn: oneItemStream delimiter: delim last: last.
		self assert: oneItemStream contents = '1'.

		coll add: 2; add: 3.
		multiItemStream := String new writeStream.
		coll asStringOn: multiItemStream delimiter: ', ' last: last.
		self assert: multiItemStream contents = '1, 2 & 3'.]
]

{ #category : #tests }
CollectionTest >> testCollectAs [

	| classes collection newCollection |
	classes := {Array . OrderedCollection . Set . Bag}.
	classes do: [:originClass |
		classes do: [:targetClass |
			collection := originClass with: 1 with: 2 with: 3.
			newCollection := collection collect: [:v | v + 1] as: targetClass.
			self 
				assert: collection size equals: newCollection size;
				assert: (newCollection includesAllOf: { 2 . 3. 4})]]
]

{ #category : #tests }
CollectionTest >> testDetect [

	self assert: #x equals: (nonEmpty detect: [:ea | ea isSymbol]).
	self should: [nonEmpty detect: [:ea | ea isNumber]] raise: Error.
]

{ #category : #tests }
CollectionTest >> testDetectIfFound [

	self assert: 42 equals: (nonEmpty detect: [:ea | ea isSymbol] ifFound: [:symbol | 42]).
	self assert: nil equals:  (nonEmpty detect: [:ea | ea isNumber] ifFound: [:number | #x]).
]

{ #category : #tests }
CollectionTest >> testDetectIfFoundIfNone [

	self assert: 42 equals: (nonEmpty
								detect: [:ea | ea isSymbol]
								ifFound: [:symbol | 42]
								ifNone: [#x]).
	self assert: #x equals:  (nonEmpty
								detect: [:ea | ea isNumber]
								ifFound: [:symbol | 42]
								ifNone: [#x]).
]

{ #category : #tests }
CollectionTest >> testDetectIfNone [

	self assert: #x equals: (nonEmpty detect: [:ea | ea isSymbol] ifNone: [42]).
	self assert: 42 equals:  (nonEmpty detect: [:ea | ea isNumber] ifNone: [42]).
]

{ #category : #tests }
CollectionTest >> testEmptyOfLiteralCollections [

	| literalCollections |
	literalCollections := Collection withAllSubclasses select: 
		[:cls | cls initializedInstance ifNil: [false] ifNotNil: [:inst | inst isLiteral]].
	literalCollections do: [:coll |
		self
			assert: 0
			equals: coll empty size
			description: 'Literal collection should have meaningful empty instance';
			
			assert: coll empty species
			identical: coll empty species
			description: 'Empty instance of literal collection should be canonical']
]

{ #category : #tests }
CollectionTest >> testHistogramOf [
	" could be collect:as: Bag, but histogram is what it's used for "
	| baseCollection collection |
	baseCollection := {#x -> 2 . #y -> 3 . #y -> 4. #z -> 2 }.
	{ Array . OrderedCollection . Set } do: 
		[:collectionClass |
		collection := baseCollection as: collectionClass.
		self
			assert: collection asBag
			equals: (collection histogramOf: [:ea | ea])
			description: 'For ', collectionClass, ', #asBag and identity-histograms should match'.
		self
			assert: (Bag withAll: #( x y y z))
			equals: (collection histogramOf: [:ea | ea key])
			description:  'For ', collectionClass, ', histogramming contents should work '.
		self
			assert: (Bag withAll: #( 2 3 4 2 ))
			equals: (collection histogramOf: [:ea | ea value])
			description:  'For ', collectionClass, ', histogramming contents should work'].

	collection := baseCollection as: KeyedSet.
	self
		assert: collection asBag
		equals: (collection histogramOf: [:ea | ea])
		description: 'For KeyedSet, #asBag and identity-histograms should match'.
	self
		assert: (Bag withAll: #( x y z))
		equals: (collection histogramOf: [:ea | ea key])
		description:  'For KeyedSet, histogramming contents should work '.
	self
		assert: (Bag withAll: #( 2 3 2 ))
		equals: (collection histogramOf: [:ea | ea value])
		description:  'For KeyedSet, histogramming contents should work'.
	
	baseCollection := {#x -> 2 . "#y -> 3 ." #y -> 4. #z -> 2 }. "No duplicate keyes"
	collection := baseCollection as: Dictionary.
	self
		assert:  (Bag withAll: #( 2 2 4 ))
		equals: (collection histogramOf: [:ea | ea])
		description: 'For Dictionary, histogramming should work on values.'.
	self
		assert:  (collection values histogramOf: [:ea | ea])
		equals: (collection histogramOf: [:ea | ea])
		description: 'For Dictionary, histogramming should be the same as histogramming the values.'.
	self
		assert: collection asBag
		equals: (collection histogramOf: [:ea | ea])
		description: 'For Dictionary, #asBag should match histogramming.'.
	self
		assert: (Bag withAll: #(x y z))
		equals: (collection keys histogramOf: [:ea |ea])
		description:  'For Dictionary, histogramming keys is ok to be less convenient.'.

]

{ #category : #tests }
CollectionTest >> testIfEmpty [

	nonEmpty ifEmpty: [self assert: false].
	self assert: (empty ifEmpty: [self]) == self.
	self assert: (nonEmpty ifEmpty: [self]) == nonEmpty.

]

{ #category : #tests }
CollectionTest >> testIfEmptyifNotEmpty [

	self assert: (empty ifEmpty: [true] ifNotEmpty: [false]).
	self assert: (nonEmpty ifEmpty: [false] ifNotEmpty: [true]).
	self assert: (nonEmpty ifEmpty: [false] ifNotEmpty: [:s | s first = #x])
]

{ #category : #tests }
CollectionTest >> testIfEmptyifNotEmptyDo [

	self assert: (empty ifEmpty: [true] ifNotEmptyDo: [:s | false]).
	self assert: (nonEmpty ifEmpty: [false] ifNotEmptyDo: [:s | s first = #x])
]

{ #category : #tests }
CollectionTest >> testIfNotEmpty [

	empty ifNotEmpty: [self assert: false].
	self assert: (nonEmpty ifNotEmpty: [self]) == self.
	self assert: (nonEmpty ifNotEmpty: [:s | s first]) = #x.
	self assert: (empty ifNotEmpty: [self]) == empty.

]

{ #category : #tests }
CollectionTest >> testIfNotEmptyDo [

	empty ifNotEmptyDo: [:s | self assert: false].
	self assert: (nonEmpty ifNotEmptyDo: [:s | s first]) = #x

]

{ #category : #tests }
CollectionTest >> testIfNotEmptyDoifNotEmpty [

	self assert: (empty ifNotEmptyDo: [:s | false] ifEmpty: [true]).
	self assert: (nonEmpty ifNotEmptyDo: [:s | s first = #x] ifEmpty: [false])
]

{ #category : #tests }
CollectionTest >> testIfNotEmptyifEmpty [

	self assert: (empty ifEmpty: [true] ifNotEmpty: [false]).
	self assert: (nonEmpty ifEmpty: [false] ifNotEmpty: [true]).
	self assert: (nonEmpty ifEmpty: [false] ifNotEmpty: [:s | s first = #x])
]

{ #category : #tests }
CollectionTest >> testInitializedInstanceIntegrity [

	self
		shouldnt: [Collection withAllSubclassesDo: [:cls | cls initializedInstance]]
		raise: Error
		description: 'No collection should break for #initializedInstance';
		
		assert: [Collection withAllSubclasses allSatisfy: [:cls | |inst|
				inst := cls initializedInstance.
				inst isNil or: [inst isKindOf: cls]]]
		description: 'All collections should have meaningful initialized instances or opted out';
		
		yourself

]

{ #category : #tests }
CollectionTest >> testMinMax [
	self assert: #(5 6 3 -3 2 1 0 4) minMax = #(-3 6).
	self assert: #($f $g $a $g $u $z $s $t) minMax = #($a $z).
	self assert: #(2834.83 -293482.28 99283 23 959323) minMax = #(-293482.28 959323).
]

{ #category : #tests }
CollectionTest >> testPrintElementsOn [
	"Monticello configurations rely on this behavior for serializing a configuration
	to send to a repository. If the implementation of printElementsOn: changes,
	make sure that MCRepository>>storeVersion: is updated accordingly, and
	fix this test to match."

	| ws |
	ws := WriteStream on: ''.
	#( one two three ) printElementsOn: ws.
	self assert: '(#one #two #three)' equals: ws contents.

]

{ #category : #tests }
CollectionTest >> testPrintOnDelimiter [
	| delim |
	delim := ', '.
	{OrderedCollection new. Set new.} do:
		[ :coll | | emptyStream oneItemStream multiItemStream |
		emptyStream := String new writeStream.
		coll printOn: emptyStream delimiter: delim.
		self assert: emptyStream contents = ''.

		coll add: 1.
		oneItemStream := String new writeStream.
		coll printOn: oneItemStream delimiter: delim.
		self assert: oneItemStream contents = '1'.

		coll add: 2; add: 3.
		multiItemStream := String new writeStream.
		coll printOn: multiItemStream delimiter: ', '.
		self assert: multiItemStream contents = '1, 2, 3'.
		
		multiItemStream := String new writeStream.
		coll printOn: multiItemStream delimiter: ', ' printString.
		self assert: multiItemStream contents = '1'', ''2'', ''3'.]
]

{ #category : #tests }
CollectionTest >> testPrintOnDelimiterLast [
	| delim last |
	delim := ', '.
	last := ' & '.
	{OrderedCollection new. Set new.} do:
		[ :coll | | emptyStream oneItemStream multiItemStream |
		emptyStream := String new writeStream.
		coll printOn: emptyStream delimiter: delim last: last.
		self assert: emptyStream contents = ''.

		coll add: 1.
		oneItemStream := String new writeStream.
		coll printOn: oneItemStream delimiter: delim last: last.
		self assert: oneItemStream contents = '1'.

		coll add: 2; add: 3.
		multiItemStream := String new writeStream.
		coll printOn: multiItemStream delimiter: ', ' last: last.
		self assert: multiItemStream contents = '1'', ''2'' & ''3'.]
]

{ #category : #tests }
CollectionTest >> testPrintingArrayWithMetaclass [
	self assert: {Array class} printString = '{Array class}'
]

{ #category : #tests }
CollectionTest >> testReduce [
	"self run: #testReduce"

	| array set bag |
	array := Array with: 1 with: 2 with: 3.
	self assert: (array reduce:[:a :b| a + b]) = 6.
	set := array asSet.
	self assert: (set reduce:[:a :b| a + b]) = 6.

	array := Array with: Color red with: Color green with: Color blue.
	self assert: (array reduce:[:a :b| a + b]) = Color white.
	set := array asSet.
	self assert: (set reduce:[:a :b| a + b]) = Color white.

	array := Array with: 1 with: 1 with: 1.
	self assert: (array reduce:[:a :b| a + b]) = 3.
	bag := array asBag.
	self assert: (bag reduce:[:a :b| a + b]) = 3.

]

{ #category : #tests }
CollectionTest >> testTake [

	self
		assert: 2 equals: (#(1 2) take: 5) size;
		assert: 2 equals: (#(1 2) readStream take: 5) size;
		should: [#(1 2) take: -1] raise: Error.
]

{ #category : #tests }
CollectionTest >> testTryIgnore [

	| someObjects sum |
	someObjects := #(1 3 a b 7 c 2).
	sum := 0.
	
	someObjects
		try: [:each | sum := sum + each]
		ignore: NumberParserError.
	
	self assert: 13 equals: sum.
]

{ #category : #tests }
CollectionTest >> testTryIgnoreIfException [

	| someObjects exceptions |
	someObjects := #(1 3 a b 7 c 2).
	exceptions := OrderedCollection new.

	someObjects
		try: [:each | each + each]
		ignore: Error
		ifException: [:ex | exceptions add: ex].

	self assert: 3 equals: exceptions size.
]
