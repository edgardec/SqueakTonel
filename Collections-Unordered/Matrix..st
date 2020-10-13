"
I represent a two-dimensional array, rather like Array2D.
There are three main differences between me and Array2D:
(1) Array2D inherits from ArrayedCollection, but isn't one.  A lot of things that should work
    do not work in consequence of this.
(2) Array2D uses ""at: column at: row"" index order, which means that nothing you write using
    it is likely to work either.  I use the almost universal ""at: row at: column"" order, so it is
    much easier to adapt code from other languages without going doolally.
(3) Array2D lets you specify the class of the underlying collection, I don't.

Structure:
  nrows : a non-negative integer saying how many rows there are.
  ncols : a non-negative integer saying how many columns there are.
  contents : an Array holding the elements in row-major order.  That is, for a 2x3 array
    the contents are (11 12 13 21 22 23).  Array2D uses column major order.

    You can specify the class of 'contents' when you create a new Array2D,
    but Matrix always gives you an Array.

    There is a reason for this.  In strongly typed languages like Haskell and Clean,
    'unboxed arrays' save you both space AND time.  But in Squeak, while
    WordArray and FloatArray and so on do save space, it costs time to use them.
    A LOT of time.  I've measured aFloatArray sum running nearly twice as slow as
    anArray sum.  The reason is that whenever you fetch an element from an Array,
    that's all that happens, but when you fetch an element from aFloatArray, a whole
    new Float gets allocated to hold the value.  This takes time and churns memory.
    So the paradox is that if you want fast numerical stuff, DON'T use unboxed arrays!

    Another reason for always insisting on an Array is that letting it be something
    else would make things like #, and #,, rather more complicated.  Always using Array
    is the simplest thing that could possibly work, and it works rather well.

I was trying to patch Array2D to make more things work, but just couldn't get my head
around the subscript order.  That's why I made Matrix.

Element-wise matrix arithmetic works; you can freely mix matrices and numbers but
don't try to mix matrices and arrays (yet).
Matrix multiplication, using the symbol +* (derived from APL's +.x), works between
(Matrix or Array) +* (Matrix or Array).  Don't try to use a number as an argument of +*.
Matrix * Number and Number * Matrix work fine, so you don't need +* with numbers.

Still to come: oodles of stuff.  Gaussian elimination maybe, other stuff probably not.

"
Class {
	#name : #Matrix,
	#superclass : #Collection,
	#instVars : [
		'nrows',
		'ncols',
		'contents'
	],
	#category : #'Collections-Unordered'
}

{ #category : #'instance creation' }
Matrix class >> column: aCollection [
	"Should this be called #fromColumn:?"

	^self rows: aCollection size columns: 1 contents: aCollection asArray shallowCopy
]

{ #category : #'instance creation' }
Matrix class >> diagonal: aCollection [
	|r i|
	r := self zeros: aCollection size.
	i := 0.
	aCollection do: [:each | i := i+1. r at: i at: i put: each].
	^r
]

{ #category : #'instance creation' }
Matrix class >> identity: n [
	|r|

	r := self zeros: n.
	1 to: n do: [:i | r at: i at: i put: 1].
	^r
]

{ #category : #'instance creation' }
Matrix class >> new [
	^self rows: 0 columns: 0
]

{ #category : #'instance creation' }
Matrix class >> new: dim [
	"Answer a dim*dim matrix.  Is this an abuse of #new:?  The argument is NOT a size."
	^self rows: dim columns: dim
]

{ #category : #'instance creation' }
Matrix class >> new: dim element: element [
	"Answer a dim*dim matrix with all elements set to element.
	 Is this an abuse of #new:?  The argument is NOT a size."

	^self rows: dim columns: dim element: element
]

{ #category : #'instance creation' }
Matrix class >> new: dim tabulate: aBlock [
	"Answer a dim*dim matrix where it at: i at: j is aBlock value: i value: j."
	^self rows: dim columns: dim tabulate: aBlock
]

{ #category : #'instance creation' }
Matrix class >> ones: n [
	^self new: n element: 1

]

{ #category : #'instance creation' }
Matrix class >> row: aCollection [
	"Should this be called #fromRow:?"

	^self rows: 1 columns: aCollection size contents: aCollection asArray shallowCopy
]

{ #category : #'instance creation' }
Matrix class >> rows: rows columns: columns [
	^self rows: rows columns: columns contents: (Array new: rows*columns)
]

{ #category : #private }
Matrix class >> rows: rows columns: columns contents: contents [
	^super new rows: rows columns: columns contents: contents
]

{ #category : #'instance creation' }
Matrix class >> rows: rows columns: columns element: element [
	^self rows: rows columns: columns
		contents: ((Array new: rows*columns) atAllPut: element; yourself)
]

{ #category : #'instance creation' }
Matrix class >> rows: rows columns: columns tabulate: aBlock [
	"Answer a new Matrix of the given dimensions where
	 result at: i at: j     is   aBlock value: i value: j"
	|a i|

	a := Array new: rows*columns.
	i := 0.
	1 to: rows do: [:row |
		1 to: columns do: [:column |
			a at: (i := i+1) put: (aBlock value: row value: column)]].
	^self rows: rows columns: columns contents: a

]

{ #category : #'instance creation' }
Matrix class >> zeros: n [
	^self new: n element: 0
]

{ #category : #arithmetic }
Matrix >> +* aCollection [
	"Premultiply aCollection by self.  aCollection should be an Array or Matrix.
	 The name of this method is APL's +.x squished into Smalltalk syntax."

	^aCollection preMultiplyByMatrix: self

]

{ #category : #copying }
Matrix >> , aMatrix [
	"Answer a new matrix having the same number of rows as the receiver and aMatrix,
	 its columns being the columns of the receiver followed by the columns of aMatrix."
	|newCont newCols anArray oldCols a b c|

	self assert: [nrows = aMatrix rowCount].
	newCont := Array new: self size + aMatrix size.
	anArray := aMatrix privateContents.
	oldCols := aMatrix columnCount.
	newCols := ncols + oldCols.
	a := b := c := 1.
	1 to: nrows do: [:r |
		newCont replaceFrom: a to: a+ncols-1 with: contents startingAt: b.
		newCont replaceFrom: a+ncols to: a+newCols-1 with: anArray startingAt: c.
		a := a + newCols.
		b := b + ncols.
		c := c + oldCols].
	^self class rows: nrows columns: newCols contents: newCont
		

]

{ #category : #copying }
Matrix >> ,, aMatrix [
	"Answer a new matrix having the same number of columns as the receiver and aMatrix,
	 its rows being the rows of the receiver followed by the rows of aMatrix."

	self assert: [ncols = aMatrix columnCount].
	^self class rows: nrows + aMatrix rowCount columns: ncols
		contents: contents , aMatrix privateContents

]

{ #category : #comparing }
Matrix >> = aMatrix [
	^aMatrix class == self class and: [
	 aMatrix rowCount = nrows and: [
	 aMatrix columnCount = ncols and: [
	 aMatrix privateContents = contents]]]
]

{ #category : #adding }
Matrix >> add: newObject [
	self shouldNotImplement
]

{ #category : #accessing }
Matrix >> anyOne [
	^contents anyOne
]

{ #category : #converting }
Matrix >> asArray [
	^contents shallowCopy
]

{ #category : #converting }
Matrix >> asBag [
	^contents asBag
]

{ #category : #converting }
Matrix >> asByteArray [
	^contents asByteArray
]

{ #category : #converting }
Matrix >> asCharacterSet [
	^contents asCharacterSet
]

{ #category : #converting }
Matrix >> asFloat32Array [
	^contents asFloat32Array
]

{ #category : #converting }
Matrix >> asFloat64Array [
	^contents asFloat64Array
]

{ #category : #converting }
Matrix >> asIdentitySet [
	^contents asIdentitySet
]

{ #category : #converting }
Matrix >> asIntegerArray [
	^contents asIntegerArray
]

{ #category : #converting }
Matrix >> asOrderedCollection [
	^contents asOrderedCollection
]

{ #category : #converting }
Matrix >> asSet [
	^contents asSet
]

{ #category : #converting }
Matrix >> asSortedArray [
	^contents asSortedArray
]

{ #category : #converting }
Matrix >> asSortedCollection [
	^contents asSortedCollection
]

{ #category : #converting }
Matrix >> asSortedCollection: aBlock [
	^contents asSortedCollection: aBlock
]

{ #category : #converting }
Matrix >> asWordArray [
	^contents asWordArray
]

{ #category : #accessing }
Matrix >> at: row at: column [
	^contents at: (self indexForRow: row andColumn: column)
]

{ #category : #accessing }
Matrix >> at: r at: c ifInvalid: v [
	"If r,c is a valid index for this matrix, answer the corresponding element.
	 Otherwise, answer v."

	(r between: 1 and: nrows) ifFalse: [^v].
	(c between: 1 and: ncols) ifFalse: [^v].
	^contents at: (r-1)*ncols + c

]

{ #category : #accessing }
Matrix >> at: row at: column incrementBy: value [
	"Array2D>>at:at:add: was the origin of this method, but in Smalltalk add:
	 generally suggests adding an element to a collection, not doing a sum.
	 This method, and SequenceableCollection>>at:incrementBy: that supports
	 it, have been renamed to reveal their intention more clearly."

	^contents at: (self indexForRow: row andColumn: column) incrementBy: value
]

{ #category : #accessing }
Matrix >> at: row at: column put: value [
	^contents at: (self indexForRow: row andColumn: column) put: value
]

{ #category : #accessing }
Matrix >> atAllPut: value [
	contents atAllPut: value
]

{ #category : #'accessing rows\/columns' }
Matrix >> atColumn: column [
	|p|

	p := (self indexForRow: 1 andColumn: column)-ncols.
	^(1 to: nrows) collect: [:row | contents at: (p := p+ncols)]

]

{ #category : #'accessing rows\/columns' }
Matrix >> atColumn: column put: aCollection [
	|p|

	aCollection size = nrows ifFalse: [self error: 'wrong column size'].
	p := (self indexForRow: 1 andColumn: column)-ncols.
	aCollection do: [:each | contents at: (p := p+ncols) put: each].
	^aCollection

]

{ #category : #accessing }
Matrix >> atRandom [
	^contents atRandom

]

{ #category : #accessing }
Matrix >> atRandom: aGenerator [
	^contents atRandom: aGenerator
]

{ #category : #'accessing rows\/columns' }
Matrix >> atRow: row [
	(row between: 1 and: nrows)
		ifFalse: [self error: '1st subscript out of range'].
	^contents copyFrom: (row-1)*ncols+1 to: row*ncols
]

{ #category : #'accessing rows\/columns' }
Matrix >> atRow: row put: aCollection [
	|p|

	aCollection size = ncols ifFalse: [self error: 'wrong row size'].
	p := (self indexForRow: row andColumn: 1)-1.
	aCollection do: [:each | contents at: (p := p+1) put: each].
	^aCollection
]

{ #category : #'accessing submatrices' }
Matrix >> atRows: rs columns: cs [
	"Answer a Matrix obtained by slicing the receiver.
	 rs and cs should be sequenceable collections of positive integers."

	^self class rows: rs size columns: cs size tabulate: [:r :c |
		self at: (rs at: r) at: (cs at: c)]
]

{ #category : #'accessing submatrices' }
Matrix >> atRows: r1 to: r2 columns: c1 to: c2 [
	"Answer a submatrix [r1..r2][c1..c2] of the receiver."
	|rd cd|

	rd := r1 - 1.
	cd := c1 - 1.
	^self class rows: r2-rd columns: c2-cd tabulate: [:r :c| self at: r+rd at: c+cd]

]

{ #category : #'accessing submatrices' }
Matrix >> atRows: r1 to: r2 columns: c1 to: c2 ifInvalid: element [
	"Answer a submatrix [r1..r2][c1..c2] of the receiver.
	 Portions of the result outside the bounds of the original matrix
	 are filled in with element."
	|rd cd|

	rd := r1 - 1.
	cd := c1 - 1.
	^self class rows: r2-rd columns: c2-cd tabulate: [:r :c| self at: r+rd at: c+cd ifInvalid: element]

]

{ #category : #'accessing submatrices' }
Matrix >> atRows: r1 to: r2 columns: c1 to: c2 put: aMatrix [
	"Set the [r1..r2][c1..c2] submatrix of the receiver
	 from the [1..r2-r1+1][1..c2-c1+1] submatrix of aMatrix.
	 As long as aMatrix responds to at:at: and accepts arguments in the range shown,
	 we don't care if it is bigger or even if it is a Matrix at all."
	|rd cd|

	rd := r1 - 1.
	cd := c1 - 1.
	r1 to: r2 do: [:r |
		c1 to: c2 do: [:c |
			self at: r at: c put: (aMatrix at: r-rd at: c-cd)]].
	^aMatrix

]

{ #category : #enumerating }
Matrix >> collect: aBlock [
	"Answer a new matrix with transformed elements; transformations should be independent."

	^self class rows: nrows columns: ncols contents: (contents collect: aBlock)
]

{ #category : #accessing }
Matrix >> columnCount [
	^ncols
]

{ #category : #'accessing rows\/columns' }
Matrix >> diagonal [
	"Answer (1 to: (nrows min: ncols)) collect: [:i | self at: i at: i]"
	|i|

	i := ncols negated.
	^(1 to: (nrows min: ncols)) collect: [:j | contents at: (i := i + ncols + 1)]
]

{ #category : #enumerating }
Matrix >> difference: aCollection [
	"Union is in because the result is always a Set.
	 Difference and intersection are out because the result is like the receiver,
	 and with irregular seleection that cannot be."
	self shouldNotImplement
]

{ #category : #enumerating }
Matrix >> do: aBlock [
	"Pass elements to aBlock one at a time in row-major order."
	contents do: aBlock
]

{ #category : #comparing }
Matrix >> hash [
	"I'm really not sure what would be a good hash function here.
	 The essential thing is that it must be compatible with #=, and
	 this satisfies that requirement."

	^contents hash
]

{ #category : #testing }
Matrix >> identityIncludes: anObject [
	^contents identityIncludes: anObject
]

{ #category : #accessing }
Matrix >> identityIndexOf: anElement [
	^self identityIndexOf: anElement ifAbsent: [0@0]

]

{ #category : #accessing }
Matrix >> identityIndexOf: anElement ifAbsent: anExceptionBlock [
	^self rowAndColumnForIndex:
		 (contents identityIndexOf: anElement ifAbsent: [^anExceptionBlock value])

]

{ #category : #testing }
Matrix >> includes: anObject [
	^contents includes: anObject
]

{ #category : #testing }
Matrix >> includesAllOf: aCollection [
	^contents includesAllOf: aCollection
]

{ #category : #testing }
Matrix >> includesAnyOf: aCollection [
	^contents includesAnyOf: aCollection
]

{ #category : #private }
Matrix >> indexForRow: row andColumn: column [
	(row between: 1 and: nrows)
		ifFalse: [self error: '1st subscript out of range'].
	(column between: 1 and: ncols)
		ifFalse: [self error: '2nd subscript out of range'].
	^(row-1) * ncols + column
]

{ #category : #accessing }
Matrix >> indexOf: anElement [
	"If there are integers r, c such that (self at: r at: c) = anElement,
	 answer some such r@c, otherwise answer 0@0.  This kind of perverse
	 result is provided by analogy with SequenceableCollection>>indexOf:.
	 The order in which the receiver are searched is UNSPECIFIED except
	 that it is the same as the order used by #indexOf:ifAbsent: and #readStream."

	^self indexOf: anElement ifAbsent: [0@0]

]

{ #category : #accessing }
Matrix >> indexOf: anElement ifAbsent: anExceptionBlock [
	"If there are integers r, c such that (self at: r at: c) = anElement,
	 answer some such r@c, otherwise answer the result of anExceptionBlock."

	^self rowAndColumnForIndex:
		 (contents indexOf: anElement ifAbsent: [^anExceptionBlock value])

]

{ #category : #enumerating }
Matrix >> indicesCollect: aBlock [
	|r i|

	r := Array new: nrows * ncols.
	i := 0.
	1 to: nrows do: [:row |
		1 to: ncols do: [:column |
			r at: (i := i+1) put: (aBlock value: row value: column)]].
	^self class rows: nrows columns: ncols contents: r
]

{ #category : #enumerating }
Matrix >> indicesDo: aBlock [
	1 to: nrows do: [:row |
		1 to: ncols do: [:column |
			aBlock value: row value: column]].
]

{ #category : #enumerating }
Matrix >> indicesInject: start into: aBlock [
	|current|

	current := start.
	1 to: nrows do: [:row |
		1 to: ncols do: [:column |
			current := aBlock value: current value: row value: column]].
	^current
]

{ #category : #enumerating }
Matrix >> intersection: aCollection [
	"Union is in because the result is always a Set.
	 Difference and intersection are out because the result is like the receiver,
	 and with irregular seleection that cannot be."
	self shouldNotImplement
]

{ #category : #testing }
Matrix >> isSequenceable [
	"LIE so that arithmetic on matrices will work.
	 What matters for arithmetic is not that there should be random indexing
	 but that the structure should be stable and independent of the values of
	 the elements.  #isSequenceable is simply the wrong question to ask."
	^true
]

{ #category : #enumerating }
Matrix >> occurrencesOf: anObject [
	^contents occurrencesOf: anObject
]

{ #category : #copying }
Matrix >> postCopy [
	super postCopy.
	contents := contents copy
]

{ #category : #arithmetic }
Matrix >> preMultiplyByArray: a [
	"Answer a +* self where a is an Array."

	nrows = 1 ifFalse: [self error: 'dimensions do not conform'].
	^Matrix rows: a size columns: ncols tabulate: [:row :col |
		(a at: row) * (contents at: col)]

]

{ #category : #arithmetic }
Matrix >> preMultiplyByMatrix: m [
	"Answer m +* self where m is a Matrix."
	

	nrows = m columnCount ifFalse: [self error: 'dimensions do not conform'].
	^Matrix rows: m rowCount columns: ncols tabulate: [:row :col | | s |
		s := 0.
		1 to: nrows do: [:k | s := (m at: row at: k) * (self at: k at: col) + s].
		s]
]

{ #category : #private }
Matrix >> privateContents [
	"Only used in #, #,, and #= so far.
	 It used to be called #contents, but that clashes with Collection>>contents."

	^contents
]

{ #category : #converting }
Matrix >> readStream [
	"Answer a ReadStream that returns all the elements of the receiver
	 in some UNSPECIFIED order."

	^ReadStream on: contents
]

{ #category : #enumerating }
Matrix >> reject: aBlock [
	self shouldNotImplement
]

{ #category : #removing }
Matrix >> remove: anObject ifAbsent: anExceptionBlock [
	self shouldNotImplement
]

{ #category : #removing }
Matrix >> removeAll [

	self shouldNotImplement
]

{ #category : #accessing }
Matrix >> replaceAll: oldObject with: newObject [
	contents replaceAll: oldObject with: newObject
]

{ #category : #private }
Matrix >> rowAndColumnForIndex: index [
	|t|

	t := index - 1.
	^(t // ncols + 1)@(t \\ ncols + 1)
]

{ #category : #accessing }
Matrix >> rowCount [
	^nrows
]

{ #category : #private }
Matrix >> rows: rows columns: columns contents: anArray [
	self assert: [rows isInteger and: [rows >= 0]].
	self assert: [columns isInteger and: [columns >= 0]].
	self assert: [rows * columns = anArray size].
	nrows := rows.
	ncols := columns.
	contents := anArray.
	^self
]

{ #category : #enumerating }
Matrix >> select: aBlock [
	self shouldNotImplement
]

{ #category : #copying }
Matrix >> shuffled [
	^self class rows: nrows columns: ncols contents: (contents shuffled)
]

{ #category : #copying }
Matrix >> shuffledBy: aRandom [
	^self class rows: nrows columns: ncols contents: (contents shuffledBy: aRandom)
]

{ #category : #accessing }
Matrix >> size [
	^contents size
]

{ #category : #printing }
Matrix >> storeOn: aStream [
	aStream nextPut: $(; nextPutAll: self class name;
		nextPutAll: ' rows: '; store: nrows;
		nextPutAll: ' columns: '; store: ncols;
		nextPutAll: ' contents: '; store: contents;
		nextPut: $)
]

{ #category : #printing }
Matrix >> stringForReadout [
	"Answer a String whose characters are a description of the receiver layed out in rows and columns"

	^ String streamContents: [:aStream | 
	1
		to: self rowCount
		do: [:iRow | 
			1
				to: self columnCount
				do: [:iCols | 
					aStream
						print: (self at: iRow at: iCols).
					aStream tab: 2].
			aStream cr]]
]

{ #category : #accessing }
Matrix >> swap: r1 at: c1 with: r2 at: c2 [
	contents swap: (self indexForRow: r1 andColumn: c1)
			 with: (self indexForRow: r2 andColumn: c2)
]

{ #category : #'accessing rows\/columns' }
Matrix >> swapColumn: anIndex withColumn: anotherIndex [
	|a b|

	a := self indexForRow: 1 andColumn: anIndex.
	b := self indexForRow: 1 andColumn: anotherIndex.
	nrows timesRepeat: [
		contents swap: a with: b.
		a := a + ncols.
		b := b + ncols].

]

{ #category : #'accessing rows\/columns' }
Matrix >> swapRow: anIndex withRow: anotherIndex [
	|a b|

	a := self indexForRow: anIndex andColumn: 1.
	b := self indexForRow: anotherIndex andColumn: 1.
	ncols timesRepeat: [
		contents swap: a with: b.
		a := a + 1.
		b := b + 1].

]

{ #category : #'accessing rows\/columns' }
Matrix >> transposed [
	self assert: [nrows = ncols].
	^self indicesCollect: [:row :column | self at: column at: row]
]

{ #category : #enumerating }
Matrix >> with: aCollection collect: aBlock [
	"aCollection must support #at:at: and be at least as large as the receiver."

	^self withIndicesCollect: [:each :row :column |
		aBlock value: each value: (aCollection at: row at: column)]

]

{ #category : #enumerating }
Matrix >> with: aCollection do: aBlock [
	"aCollection must support #at:at: and be at least as large as the receiver."

	self withIndicesDo: [:each :row :column |
		aBlock value: each value: (aCollection at: row at: column)].

]

{ #category : #enumerating }
Matrix >> with: aCollection inject: startingValue into: aBlock [
	"aCollection must support #at:at: and be at least as large as the receiver."

	^self withIndicesInject: startingValue into: [:value :each :row :column |
		aBlock value: value value: each value: (aCollection at: row at: column)]
]

{ #category : #enumerating }
Matrix >> withIndicesCollect: aBlock [
	|i r|

	i := 0.
	r := contents shallowCopy.
	1 to: nrows do: [:row |
		1 to: ncols do: [:column |
			i := i+1.
			r at: i put: (aBlock value: (r at: i) value: row value: column)]].
	^self class rows: nrows columns: ncols contents: r

]

{ #category : #enumerating }
Matrix >> withIndicesDo: aBlock [
	|i|

	i := 0.
	1 to: nrows do: [:row |
		1 to: ncols do: [:column |
			aBlock value: (contents at: (i := i+1)) value: row value: column]].

]

{ #category : #enumerating }
Matrix >> withIndicesInject: start into: aBlock [
	|i current|

	i := 0.
	current := start.
	1 to: nrows do: [:row |
		1 to: ncols do: [:column |
			current := aBlock value: current value: (contents at: (i := i+1)) 
							  value: row value: column]].
	^current
]
