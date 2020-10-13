Class {
	#name : #IntervalTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #failures }
IntervalTest >> expectedFailures [

	^ #(testIntervalOfFloatLast testIntervalOfFloatReversed testSurprisingFuzzyInclusionBehavior)
]

{ #category : #tests }
IntervalTest >> testAdd [
	self assert: (1 to: 10)
			+ 5
			= (6 to: 15)
]

{ #category : #tests }
IntervalTest >> testAnyOne [
	self assert: ((2 to: 5) includes: (2 to: 5) anyOne).
	self should: [(2 to: 1) anyOne] raise: Error description: 'This interval is empty'
]

{ #category : #tests }
IntervalTest >> testAsInterval [
	"This is the same as newFrom:"

	self assert: (1 to: 3) equals: (#(1 2 3) as: Interval).
	self assert: (33 to: -23 by: -28) equals: (#(33 5 -23) as: Interval).
	self assert: (2 to: 6 by: 2) equals: (#[2 4 6] as: Interval).

	self should: [#(33 5 -22) as: Interval]
		raise: Error
		description: 'This is not an arithmetic progression'

]

{ #category : #tests }
IntervalTest >> testAsIntervalWithFractionalProgression [
	self assert: (1 to: 2 by: 1/2) equals: ({1. 3/2. 2} as: Interval).
	self assert: (1 to: 2 by: 0.2s) equals: ({1. 1.2s. 1.4s. 1.6s. 1.8s. 2} as: Interval).
	
	self should: [#(0.1 0.2 0.3 0.4) as: Interval]
		raise: Error
		description: 'There is no guaranty that Interval of Float can be constructed from individual Float'.
	"Even though, by chance there might be a Float Interval with same elements"
	#(0.1 0.2 0.3 0.4) hasEqualElements: (0.1 to: 0.4 by: 0.1 predecessor)
]

{ #category : #tests }
IntervalTest >> testAt [
	self assert: ((1 to: 10)
			at: 1)
			= 1.
	self assert: ((1 to: 10)
			at: 3)
			= 3.
	self assert: ((1 to: 10 by: 2)
			at: 1)
			= 1.
	self assert: ((1 to: 10 by: 2)
			at: 3)
			= 5
]

{ #category : #tests }
IntervalTest >> testDo [
	| s i |
	s := OrderedCollection new.
	i := (10 to: 20).
	i do: [ :each | s addLast: each].
	self assert: (s hasEqualElements: i)
]

{ #category : #tests }
IntervalTest >> testEquals [

	self assert: (3 to: 5) = (3.0 to: 5.0).
	self deny: (3 to: 5) = (3 to: 5 by: 2) description: 'Sharing bounds is not enough to make Interval equals'.
]

{ #category : #tests }
IntervalTest >> testEquals3 [

	self assert: (3 to: 5 by: 2) first = (3 to: 6 by: 2) first.
	self assert: (3 to: 5 by: 2) last = (3 to: 6 by: 2) last.
	self assert: (3 to: 5 by: 2) = (3 to: 6 by: 2).
]

{ #category : #tests }
IntervalTest >> testEqualsWhenEmpty [
	self assert: (3 to: 2) = (3 to: 2) copy.
	self deny: (3 to: 2) = (2 to: 1)
		description: 'Empty intervals are considered different if their bound differs. Text selection rely on this feature'.
]

{ #category : #tests }
IntervalTest >> testEqualsWithArray [
	"Intervals are not considered equal to Array, even if they share the same sequence of elements."
	self deny: (3 to: 5) = #(3 4 5).
	self deny: #(3 4 5) = (3 to: 5).
]

{ #category : #tests }
IntervalTest >> testExtent [
	self assert: (1 to: 10) extent = 9.
	self assert: (1 to: 10 by: 2) extent = 9.
	self assert: (1 to:-1) extent = -2
]

{ #category : #tests }
IntervalTest >> testHashEqualIfIntervalEqual [
	| interval1 interval2 |
	interval1 := 0 to: 1.
	interval2 := 0 to: 5/3. "Taken from an actual issue in an image"
	self assert: interval1 equals: interval2.
	self assert: interval1 hash equals: interval2 hash.
]

{ #category : #tests }
IntervalTest >> testInclusion [
	"Non regression test for another bug of fuzzy inclusion"
	
	self deny: ((1.0 to: 3.0 by: 1.0 successor) includes: 3.0) description: 'The last element of this Interval is closed to 2'
]

{ #category : #tests }
IntervalTest >> testInclusionBug1603 [
	"This test is by german morales.
	It is about mantis bug 1603"
	
	self shouldnt: ((1 to: 5 by: 1) includes: 2.5). "obvious"
	self shouldnt: ((100000000000000 to: 500000000000000 by: 100000000000000)
 		  includes: 250000000000000). "same as above with 14 zeros appended"
]

{ #category : #tests }
IntervalTest >> testInclusionBug6455 [
	"This test is about mantis bug http://bugs.squeak.org/view.php?id=6455
	It should work as long as Fuzzy inclusion test feature for Interval of Float is maintained.
	This is a case when tested element is near ones of actual value, but by default.
	Code used to work only in the case of close numbers by excess..."
	
	self assert: ((0 to: Float pi by: Float pi / 100) includes: Float pi * (3/100))
]

{ #category : #tests }
IntervalTest >> testIndexOfBug1602 [
	"This test is by german morales.
	It is about mantis bug 1602"
	
	self should: ((1 to: 5 by: 1) indexOf: 2.5) = 0. "obvious"
	self should: ((100000000000000 to: 500000000000000 by: 100000000000000)
 		  indexOf: 250000000000000) = 0. "same as above with 14 zeros appended"
]

{ #category : #tests }
IntervalTest >> testIndexOfBug6455 [
	"This test is about mantis bug http://bugs.squeak.org/view.php?id=6455
	It should work as long as Fuzzy inclusion test feature for Interval of Float is maintained.
	This is a case when tested element is near ones of actual value, but by default.
	Code used to work only in the case of close numbers by excess..."
	
	self assert: ((0 to: Float pi by: Float pi / 100) indexOf: Float pi * (3/100)) = 4
]

{ #category : #tests }
IntervalTest >> testInfiniteLoopBug6456 [
	"This is a non regression test against mantis bug #6456.
	Some Float interval size was not consistent with do: loop.
	Some Float Interval used to do: infinite loops"
	
	| x interval counter size |
	x := (1.0 timesTwoPower: Float precision). "Note: x+1 = x due to inexact arithmetic"
	interval := x to: x+4.
	size := interval size.
	counter := 0.
	interval do: [:each | self assert: (counter := counter + 1) <= size].
]

{ #category : #tests }
IntervalTest >> testIntervalOfFloatEqual [
	"Interval with Float are weirdos"

	| interval1 interval2 interval3 interval4 |
	interval1 := (0 to: 1 by: 1/10).
	interval2 := (0.0 to: 1 by: 1/10).
	self deny: (interval1 = interval2) ==> (interval1 hasEqualElements: interval2)
		description: 'Interval of Float may have different elements from another Interval, even if they pretend to be equal.'.

	interval3 := (0.3 to: 0.6 by: 1/10).
	interval4 := (0.3 to: 0.6 by: 0.1).
	self deny: (interval3 hasEqualElements: interval4) ==> (interval3 = interval4)
		description: 'Interval of Float may pretend they differ from another Interval even if they have same elements.'.
]

{ #category : #tests }
IntervalTest >> testIntervalOfFloatLast [
	"Some definition of last were problematic for Interval of Float"
	
	| increment upperBound interval |
	self assert: (0.2 to: 0.9 by: 0.1) last = (0.2 to: 0.9 by: 0.1) asArray last
		description: 'the last element cannot reasonably change when converting asArray'.
	
	upperBound := 1.7.
	increment := 0.1.
	self deny: (0 to: upperBound by: increment) last > upperBound
		description: 'the last element cannot reasonably exceed upper bound'.
	
	interval := -0.9999999999999994 to: 1 by: 2.
	self assert: interval last < interval first
		==> (interval isEmpty or: [interval increment < 0])
		description: 'the last element cannot reasonably deceed(*) lower bound (* be inferior to)'
]

{ #category : #tests }
IntervalTest >> testIntervalOfFloatReversed [
	self assert: (-16.3 to: 20.1 by: 1.3) reversed size
		equals: (-16.3 to: 20.1 by: 1.3) size
		description: 'reversed should preserve the size of a collection'.
	self assert: (0.1 to: 0.9 by: 0.1) reversed asArray
		equals: (0.1 to: 0.9 by: 0.1) asArray reversed
		description: 'reversed should preserve the elements of a collection'.
]

{ #category : #tests }
IntervalTest >> testIntervalStoreOn [
	"this is a test for http://bugs.squeak.org/view.php?id=4378"
	
	| interval1 interval2 |
	interval1 := 0 to: 1 by: 0.5s1 squared.
	interval2 := Compiler evaluate: interval1 storeString.
	self assert: interval1 size = interval2 size
]

{ #category : #tests }
IntervalTest >> testInvalid [
	"empty, impossible ranges"
	self assert: (1 to: 0) isEmpty.
	self assert: (1 to: -1) isEmpty.
	self assert: (-1 to: -2) isEmpty.
	self assert: (1 to: 5 by: -1) isEmpty.
	
	"always contains only start value."
	self assert: (1 to: 1) asArray = #(1).
	self assert: (1 to: 5 by: 10) asArray = #(1).
	self assert: (1 to: 0 by: -2) asArray = #(1).

]

{ #category : #tests }
IntervalTest >> testIsInterval [
	self assert: (1 to: 10) isInterval.
	self assert: (1 to: 10 by: 2) isInterval
]

{ #category : #tests }
IntervalTest >> testLast [

self assert: (1 to:10) last = 10.
self assert: (1 to:10 by:2) last = 9 
]

{ #category : #tests }
IntervalTest >> testMinus [
	self assert: (1 to: 10)
			- 5
			= (-4 to: 5)
]

{ #category : #tests }
IntervalTest >> testNewFrom [

	 self assert: (1 to: 1) equals: (Interval newFrom: (1 to: 1)).
	 self assert: (1 to: 1) equals:  (Interval newFrom: #(1)).
	 self assert: ( 1 to: 0) equals: (Interval newFrom: #()).

]

{ #category : #tests }
IntervalTest >> testOtherNewFrom [

	self assert: (Interval newFrom: #(1 2 3 )) = (1 to: 3).
	self assert: (Interval newFrom: #(33  5 -23 )) = (33 to: -23 by: -28).
	self should: [(Interval newFrom: #(33  5 -22 ))] raise: Error.
	self assert: (#(33  5 -23) as: Interval) = (33 to: -23 by: -28).
	self should: [( #(33  5 -22 ) as: Interval)] raise: Error.
	
	self assert: ( (-4 to: -12 by: -1) as: Interval) = (-4 to: -12 by: -1).
	self assert: ( Interval newFrom: (1 to: 1)) = (1 to: 1).
	self assert: ( Interval newFrom: (1 to: 0)) = (1 to: 0).
	self assert: (#(1) as: Interval) = (1 to: 1).
	self assert: (#() as: Interval) = (1 to: 0).
]

{ #category : #tests }
IntervalTest >> testPermutationsDo [

	| i oc |
	i := (1.234 to: 4.234).
	oc := OrderedCollection new.
	i permutationsDo: [:e | oc add: e].
	self assert: (oc size = i size factorial).
	^ oc
]

{ #category : #tests }
IntervalTest >> testRangeIncludes [
	self
		assert: ((1 to: 10)
				rangeIncludes: 3).
	self
		assert: ((1 to: 10 by: 2)
				rangeIncludes: 3).
	self
		deny: ((1 to: 10)
				rangeIncludes: 0).
	self
		deny: ((1 to: 10)
				rangeIncludes: 11).
	self
		deny: ((1 to: 10 by: 2)
				rangeIncludes: 0).
	self
		deny: ((1 to: 10 by: 2)
				rangeIncludes: 11)
]

{ #category : #tests }
IntervalTest >> testReverseDo [
	| s i |
	s := OrderedCollection new.
	i := 10 to: 20.
	i
		reverseDo: [:each | s addFirst: each].
	self
		assert: (s hasEqualElements: i)
]

{ #category : #tests }
IntervalTest >> testReverseUnevenDo [
	| s i |
	s := OrderedCollection new.
	i := 10 to: 20 by: 3.
	i
		reverseDo: [:each | s addFirst: each].
	self
		assert: (s hasEqualElements: i)
]

{ #category : #tests }
IntervalTest >> testReversed [
	self assert: (3 to: 10) reversed = (10 to: 3 by: -1).
	self assert: (3 to: 11 by: 4) reversed = (11 to: 3 by: -4).
	self assert: (3 to: 12 by: 4) reversed = (11 to: 3 by: -4).
]

{ #category : #tests }
IntervalTest >> testReversedEmpty [
	self assert: (4 to: 3) reversed = (3 to: 4 by: -1).
	self assert: (4 to: 3 by: 5) reversed = (3 to: 4 by: -5).
]

{ #category : #tests }
IntervalTest >> testSum [
	1 to: 10 do: [:i |
		| int |
		int := -3 to: i-1*5-3 by: 5.
		self assert: int asArray sum = int sum.
		self assert: int reversed sum = int sum]
]

{ #category : #tests }
IntervalTest >> testSurprisingFuzzyInclusionBehavior [
	"If ever Interval implement fuzzy inclusion, then we can expect weird logic..."
	self assert: ((0.1 to: 0.9 by: 0.1) includes: 0.3)
			==> (((0.1 to: 0.9 by: 0.1) occurrencesOf: 0.3) > 0)
		description: 'A Collection that includes something has at least one occurrence of something'.
	self assert: ((0.1 to: 0.9 by: 0.1) lastIndexOf: 0.3)
			>= ((0.1 to: 0.9 by: 0.1) indexOf: 0.3)
		description: 'The last index of an object in a SequenceableCollection should be greater than or equal to the first index'.
	self assert: ((0.1 to: 0.9 by: 0.1) includes: 0.3)
			==> (((0.1 to: 0.9 by: 0.1) copyWithout: 0.3) size < (0.1 to: 0.9 by: 0.1) size)
		description: 'A Collection should be able to shrink by stripping own elements'.
]

{ #category : #tests }
IntervalTest >> testUnevenDo [
	| s i |
	s := OrderedCollection new.
	i := 10 to: 20 by: 3.
	i
		do: [:each | s addLast: each].
	self
		assert: (s hasEqualElements: i)
]
