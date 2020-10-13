Class {
	#name : #HeapTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Sequenceable'
}

{ #category : #examples }
HeapTest >> heapExample [	"HeapTest new heapExample"
	"Create a sorted collection of numbers, remove the elements
	sequentially and add new objects randomly.
	Note: This is the kind of benchmark a heap is designed for."
	| n rnd array time sorted |
	n := 5000. "# of elements to sort"
	rnd := Random new.
	array := (1 to: n) collect:[:i| rnd next].
	"First, the heap version"
	time := Time millisecondsToRun:[
		sorted := Heap withAll: array.
		1 to: n do:[:i| 
			sorted removeFirst.
			sorted add: rnd next].
	].
	Transcript cr; show:'Time for Heap: ', time printString,' msecs'.
	"The quicksort version"
	time := Time millisecondsToRun:[
		sorted := SortedCollection withAll: array.
		1 to: n do:[:i| 
			sorted removeFirst.
			sorted add: rnd next].
	].
	Transcript cr; show:'Time for SortedCollection: ', time printString,' msecs'.

]

{ #category : #examples }
HeapTest >> heapSortExample [
	"Sort a random collection of Floats and compare the results with #quicksort and #sort (using the merge-sort algorithm)."
	"HeapTest new heapSortExample"
	
	| arrayToSort n rnd array time |
	Smalltalk garbageCollectMost.
	n := 50000. "# of elements to sort"
	rnd := Random new.
	array := Array new: n.
	1 to: n do: [ :index | array at: index put: rnd next ].
	arrayToSort := array copy.
	"First, the heap version"
	self deny: arrayToSort isSorted.
	time := [ (Heap on: arrayToSort) sort ] timeToRun.
	self assert: arrayToSort isSorted.
	Transcript cr; show: 'Time for heap-sort: ', time printString,' msecs'.
	"The quicksort version"
	arrayToSort copyFrom: array.
	self deny: arrayToSort isSorted.
	time := [ arrayToSort quickSort ] timeToRun.
	self assert: arrayToSort isSorted.
	Transcript cr; show: 'Time for quick-sort: ', time printString,' msecs'.
	"The merge-sort version"
	arrayToSort copyFrom: array.
	self deny: arrayToSort isSorted.
	time := [ arrayToSort sort ] timeToRun.
	self assert: arrayToSort isSorted.	
	Transcript cr; show: 'Time for merge-sort: ', time printString,' msecs'
]

{ #category : #tests }
HeapTest >> test1 [
	| data |

	"The first element of each array is the sort value, and the second will be updated by the heap with the index of the element within the heap."
	data :=  (1 to: 8) collect: [:i | {i*2. 0}].

	"Repeat with different data ordering."
	5 timesRepeat: [ | h |
		h := Heap new sortBlock: [:e1 :e2 | e1 first < e2 first].
		h indexUpdateBlock: [:array :index | array at: 2 put: index].

		data shuffled do: [:d | h add: d].
		data do: [:d | self should: (h at: d second) == d].
	]
]

{ #category : #tests }
HeapTest >> testAdd [
	"self run: #testAdd"

	| heap |
	heap := Heap new.
	self assert: heap size = 0.
	heap add: 3.
	self assert: heap size = 1.
	self assert: heap isEmpty not.
	self assert: heap first = 3.
	self assert: (heap at: 1) = 3.
	heap add: 2.
	self assert: heap size = 2.
	self assert: heap first = 2.
	self assert: (heap at: 2) = 3.
	
]

{ #category : #tests }
HeapTest >> testAddAndRemoveFirst [

	| random heap validateHeap |
	random := Random seed: 36rSqueak.
	heap := Heap sortBlock: [ :a :b | a first >= b first ].
	heap indexUpdateBlock: [ :element :newIndex | element at: 2 put: newIndex ].
	validateHeap := [ heap isValidHeap and: [
		heap do: [ :each | self assert: (heap at: each second) == each ] ] ].
	validateHeap value.
	self assert: 0 equals: heap size.
	self assert: heap isEmpty.
	1 to: 100 do: [ :index |
		heap add: { random next. nil }.
		self assert: index equals: heap size.
		validateHeap value ].
	1000 timesRepeat: [
		| first |
		first := heap removeFirst.
		heap do: [ :each | self assert: (heap sortBlock value: first value: each) ].
		heap add: { random next. nil }.
		validateHeap value ]
]

{ #category : #tests }
HeapTest >> testAt [
	"self run: #testAt"

	| heap |
	heap := Heap new.
	heap add: 3.
	self assert: (heap at: 1) = 3.
	self should: [heap at: 2] raise: Error.
	heap add: 4.
	self assert: (heap at: 1) = 3.
	self assert: (heap at: 2) = 4.

	
]

{ #category : #tests }
HeapTest >> testAtRaisesErrorWhenIndexIsInvalid [
	" self run: #testAtRaisesErrorWhenIndexIsInvalid "

	| heap |
	heap := Heap new.
	1 to: 100 do: [ :index |
		1 to: heap size do: [ :each | 
			self assert: ((heap at: each) between: 1 and: heap size) ].
		self 
			should: [ heap at: 0 ] raise: Error;
			should: [ heap at: heap size + 1 ] raise: Error.
		heap add: index ].
]

{ #category : #tests }
HeapTest >> testCompact [
	" self run: #testCompact "
	
	| heap |
	heap := Heap new.
	1 to: 100 do: [ :index |
		| copy |
		copy := heap copy.
		copy compact.
		self 
			assert: copy = heap;
			assert: copy capacity <= heap capacity;
			assert: copy capacity = copy size.
		heap add: index ].
]

{ #category : #tests }
HeapTest >> testCopy [

	| heap |
	heap := Heap new.
	1 to: 100 do: [ :index |
		| copy |
		copy := heap copy.
		self 
			assert: copy = heap;
			assert: heap = copy;
			deny: copy == heap;
			assert: copy sortBlock = heap sortBlock;
			deny: copy array == heap array.
		heap add: index ].
]

{ #category : #tests }
HeapTest >> testCopyEmpty [

	| heap |
	heap := Heap new.
	1 to: 100 do: [ :index |
		| copy |
		copy := heap copyEmpty.
		self 
			assert: copy isHeap;
			assert: copy isEmpty;
			assert: copy sortBlock = heap sortBlock.
		heap add: index ].
]

{ #category : #tests }
HeapTest >> testDo [
	"self run: #testDo"

	| heap coll |
	heap := Heap withAll: #(1 3 5).
	coll := OrderedCollection new.
	
	heap do: [:each | coll add: each].
	
	self assert: coll = #(1 3 5) asOrderedCollection.

]

{ #category : #tests }
HeapTest >> testExamples [
	self heapExample.
	self heapSortExample.
]

{ #category : #tests }
HeapTest >> testFirst [
	"self run: #testFirst"
	| heap |
	heap := Heap new.
	heap add: 5.
	heap add: 12.
	heap add: 1.
	self assert: heap first = 1.
	heap removeFirst.
	self assert: heap first = 5.
]

{ #category : #tests }
HeapTest >> testHeap [
	"self run: #testHeap"

	| heap |
	heap := Heap new.
	self assert: heap isHeap.
	
	self assert: heap isEmpty.
	heap add: 1.
	self assert: heap isEmpty not
	

]

{ #category : #tests }
HeapTest >> testIfEqualIsTransitive [
	"This is http://bugs.squeak.org/view.php?id=6943"

    | anArray heap1 heap2 |
    anArray := #(1 2 3).
    heap1 := Heap withAll: (1 to: 3) sortBlock: [:a :b | a < b].
    heap2 := Heap withAll: (1 to: 3) sortBlock: [:a :b | b > a].
    self
		assert: (heap1 = anArray) & (heap2 = anArray) ==> (heap1 = heap2)
		description: 'Heap equality should be transitive'
]

{ #category : #tests }
HeapTest >> testIndexUpdateBlockWithFirstElementRemoval [

	| random heap validateHeap |
	random := Random seed: 36rSqueak.
	heap := Heap sortBlock: [ :a :b | a first <= b first ].
	heap indexUpdateBlock: [ :element :newIndex | element at: 2 put: newIndex ].
	validateHeap := [ 
		heap isHeap
			and: [ heap isValidHeap
			and: [ heap do: [ :each | self assert: (heap at: each second) == each ] ] ] ].
	validateHeap value.
	1 to: 10 do: [ :i |
		heap add: { i. nil }.
		validateHeap value ].
	10 timesRepeat: [
		heap removeAt: 1.
		validateHeap value ]
]

{ #category : #tests }
HeapTest >> testRemove [
	"self run: #testRemove"
	
	| heap |
	heap := Heap new.
	self should: [heap removeFirst] raise: Error.
	heap add: 5.
	self assert: 5 equals: heap removeFirst.
	self assert: heap size = 0.
	heap add: 5.
	self should: [heap removeAt: 2] raise: Error.
]

{ #category : #tests }
HeapTest >> testSort [

	self testSortUsing: Heap new.
	{
		nil.
		#<=.
		[ :a :b | a <= b ].
		[ :a :b | a >= b ] 
	} do: [ :each | self testSortUsing: (Heap sortBlock: each) ]
]

{ #category : #tests }
HeapTest >> testSortBlock [
	"self run: #testSortBlock"

	| heap |
	heap := Heap withAll: #(1 3 5).
	self assert: heap asArray = #(1 3 5).
	
	heap sortBlock: [ :e1 :e2 | e1 >= e2 ].
	self assert: heap isValidHeap.
	self assert: heap asArray = #(5 3 1)

]

{ #category : #tests }
HeapTest >> testSortUsing: aHeap [

	| random |
	random := Random seed: 36rSqueak.
	self assert: aHeap isValidHeap.
	1000 timesRepeat: [
		aHeap add: random next.
		self assert: aHeap isValidHeap ].
	self deny: (aHeap asArray isSortedBy: aHeap sortBlock).
	aHeap sort.
	self assert: aHeap isValidHeap.
	self assert: (aHeap asArray isSortedBy: aHeap sortBlock)

]

{ #category : #tests }
HeapTest >> testSortWithIndexUpdateBlock [

	| random heap validateHeap |
	random := Random seed: 36rSqueak.
	heap := Heap sortBlock: [ :a :b | a first <= b first ].
	heap indexUpdateBlock: [ :element :newIndex | element at: 2 put: newIndex ].
	validateHeap := [ 
		heap isHeap
			and: [ heap isValidHeap
			and: [ heap do: [ :each | self assert: (heap at: each second) == each ] ] ] ].
	validateHeap value.
	1000 timesRepeat: [
		heap add: { random next. nil }.
		validateHeap value ].
	self deny: (heap asArray isSortedBy: heap sortBlock).
	heap sort.
	validateHeap value.
	self assert: (heap asArray isSortedBy: heap sortBlock)

]
