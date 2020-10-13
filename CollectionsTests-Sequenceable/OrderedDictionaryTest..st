Class {
	#name : #OrderedDictionaryTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'sut'
	],
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #running }
OrderedDictionaryTest >> setUp [

	super setUp.
	sut := OrderedDictionary new: 7.
]

{ #category : #'tests - accessing' }
OrderedDictionaryTest >> testAtIndex [

	1 to: 10 do: [:ea |
		sut at: ea put: nil].

	1 to: 10 do: [:index |
		self assert: index equals: (sut atIndex: index) key].
]

{ #category : #tests }
OrderedDictionaryTest >> testCompact [
	"Eager compacting on removal."

	1 to: 3 do: [:ea | sut at: ea put: nil].
	sut removeKey: 2.
	self assert: 2 equals: ((sut instVarNamed: #order) count: [:ea | ea notNil]).
]

{ #category : #'tests - copying' }
OrderedDictionaryTest >> testCopy [

	sut
		at: 1 put: nil;
		at: 2 put: nil;
		at: 3 put: nil.

	sut copy in: [:copy |
		self assert: sut keys equals: copy keys.
		copy at: 4 put: nil.
		self assert: sut keys size < copy keys size].
]

{ #category : #'tests - accessing' }
OrderedDictionaryTest >> testCopyFirst [

	1 to: 10 do: [:ea |
		sut at: ea put: nil].

	self assert: (1 to: 5) asArray equals: (sut first: 5) keys.
]

{ #category : #'tests - copying' }
OrderedDictionaryTest >> testCopyFromTo [

	| copy |
	1 to: 10 do: [:index |
		sut at: index put: nil].

	copy := sut copyFrom: 3 to: 5.
	self assert: (3 to: 5) asArray equals: copy keys.
	copy at: 3 put: #foo.
	self assert: (sut at: 3) isNil.
	
	copy at: 11 put: #ba.
	self assert: #ba equals: (copy at: 11).
]

{ #category : #'tests - accessing' }
OrderedDictionaryTest >> testCopyLast [

	1 to: 10 do: [:ea |
		sut at: ea put: nil].

	self assert: (6 to: 10) asArray equals: (sut last: 5) keys.
]

{ #category : #'tests - accessing' }
OrderedDictionaryTest >> testFirst [

	1 to: 10 do: [:ea |
		sut at: ea put: nil].

	#(first second third fourth fifth sixth seventh eighth ninth) withIndexDo: [:selector :index |
		self assert: index equals: (sut perform: selector) key].
]

{ #category : #tests }
OrderedDictionaryTest >> testGrow [

	self
		assert: 11 equals: sut array size; "next prime number to 7; see #setUp"
		assert: sut capacity = (sut instVarNamed: #order) size;
		assert: sut array size >(sut instVarNamed: #order) size. "save memory"

	1 to: sut array size do: [:ea |
		sut at: ea put: nil].

	self
		assert: sut array size > 11;
		assert: sut capacity = (sut instVarNamed: #order) size;
		assert: sut array size > (sut instVarNamed: #order) size. "save memory"
]

{ #category : #'tests - sorting' }
OrderedDictionaryTest >> testIsSorted [

	10 to: 1 by: -1 do: [:ea |
		sut at: ea put: nil].

	self assert: sut isSorted not.
	sut sort.
	self assert: sut isSorted.
]

{ #category : #tests }
OrderedDictionaryTest >> testOrder [
	"We use integers as keys to match hash values."

	| dict |
	dict := Dictionary new.

	1 to: 10 do: [:ea |
		dict at: ea put: nil.
		sut at: ea put: nil].

	self assert: dict keys = sut keys.

	dict removeKey: 5.
	sut removeKey: 5.

	self assert: dict keys = sut keys.

	dict at: 5 put: nil.
	sut at: 5 put: nil.

	self
		assert: dict keys ~= sut keys;
		assert: #(1 2 3 4 6 7 8 9 10 5) equals: sut keys;
		assert: #(1 2 3 4 5 6 7 8 9 10) equals: dict keys.
]

{ #category : #tests }
OrderedDictionaryTest >> testOverflow [
	"Check whether repeated additions of the same alternating keys causes an error."

	self
		shouldnt: [20 timesRepeat: [sut at: 1 put: nil; removeKey: 1]]
		raise: Error. 
]

{ #category : #tests }
OrderedDictionaryTest >> testOverwriteValue [
	"First write wins wrt. order in the dictionary."

	1 to: 5 do: [:ea |
		sut at: ea put: nil].

	sut at: 3 put: nil.

	self assert: #(1 2 3 4 5) equals: sut keys.
]

{ #category : #'tests - sorting' }
OrderedDictionaryTest >> testSort [

	10 to: 1 by: -1 do: [:ea |
		sut at: ea put: nil].

	self assert: (10 to: 1 by: -1) asArray equals: sut keys.
	sut sort.
	self assert: (1 to: 10) asArray equals: sut keys.
]

{ #category : #'tests - sorting' }
OrderedDictionaryTest >> testSortCustom [

	| values |
	values := #(The quick brown fox jumps over the lazy dog).
	1 to: 9 do: [:ea |
		sut at: ea put: (values at: ea)].
	sut sort: [:a1 :a2 | a1 value <= a2 value].
	self assert: values sorted equals: sut values.

]

{ #category : #'tests - sorting' }
OrderedDictionaryTest >> testSorted [

	10 to: 1 by: -1 do: [:ea |
		sut at: ea put: nil].

	sut sorted in: [:copy |
		self
			assert: copy ~~ sut;
			assert: copy keys = sut keys reversed].
]
