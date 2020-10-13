"
I represent a finite arithmetic progression.
"
Class {
	#name : #Interval,
	#superclass : #SequenceableCollection,
	#instVars : [
		'start',
		'stop',
		'step'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #'instance creation' }
Interval class >> from: startInteger to: stopInteger [ 
	"Answer an instance of me, starting at startNumber, ending at 
	stopNumber, and with an interval increment of 1."

	^self basicNew
		setFrom: startInteger
		to: stopInteger
		by: 1
]

{ #category : #'instance creation' }
Interval class >> from: startInteger to: stopInteger by: stepInteger [ 
	"Answer an instance of me, starting at startNumber, ending at 
	stopNumber, and with an interval increment of stepNumber."

	^self basicNew
		setFrom: startInteger
		to: stopInteger
		by: stepInteger
]

{ #category : #'instance creation' }
Interval class >> initializedInstance [
	^self newFrom: #()
]

{ #category : #'instance creation' }
Interval class >> newFrom: aCollection [ 
	"Answer an instance of me containing the same elements as aCollection."

    | newInterval n |
    (n := aCollection size) <= 1 ifTrue: [
		n = 0 ifTrue: [^self from: 1 to: 0].
		^self from: aCollection anyOne to: aCollection anyOne].
    	newInterval := self
		from: aCollection first
		to: aCollection last
		by: (aCollection last - aCollection first) / (n - 1).
	(newInterval hasEqualElements: aCollection)
		ifFalse:
			[self error: 'The argument is not an arithmetic progression'].
	^newInterval

"	Interval newFrom: {1. 2. 3}
	{33. 5. -23} as: Interval
	{33. 5. -22} as: Interval    (an error)
	(-4 to: -12 by: -1) as: Interval
	#(2 4 6) asByteArray as: Interval.
"
]

{ #category : #arithmetic }
Interval >> + number [

	^ start + number to: stop + number by: step
]

{ #category : #adding }
Interval >> , otherCollection [
	"Override to answer an Interval if otherCollection is an adjacent and congruent interval."
	^(otherCollection isInterval
	  and: [otherCollection increment = step
	  and: [otherCollection first = (self last + step)]])
		ifTrue: [self class from: start to: otherCollection last by: step]
		ifFalse: [super, otherCollection]
]

{ #category : #arithmetic }
Interval >> - number [

	^ start - number to: stop - number by: step
]

{ #category : #comparing }
Interval >> = anObject [
	^ self == anObject
		or: [anObject isInterval
			ifFalse: [super = anObject]
			ifTrue: 
				[start = anObject first
				 and: [step = anObject increment
				 and: [self last = anObject last]]]]
]

{ #category : #adding }
Interval >> add: newObject [ 
	"Adding to an Interval is not allowed."

	self shouldNotImplement
]

{ #category : #adding }
Interval >> addAllFirstTo: anOrderedCollection [
	"Add all of my elements to the beginning of anOrderedCollection"

	self reverseDo: [ :each | anOrderedCollection addFirst: each ]
]

{ #category : #accessing }
Interval >> anyOne [
	"This message will fail for an empty Interval, super would not."
	^self at: 1
]

{ #category : #accessing }
Interval >> at: anInteger [ 
	"Answer the anInteger'th element."

	(anInteger >= 1 and: [anInteger <= self size])
		ifTrue: [^start + (step * (anInteger - 1))]
		ifFalse: [self errorSubscriptBounds: anInteger]
]

{ #category : #accessing }
Interval >> at: anInteger put: anObject [ 
	"Storing into an Interval is not allowed."

	self error: 'you can not store into an interval'
]

{ #category : #enumerating }
Interval >> collect: aBlock [
	| nextValue result |
	result := self species new: self size.
	nextValue := start.
	1 to: result size do:
		[:i |
		result at: i put: (aBlock value: nextValue).
		nextValue := nextValue + step].
	^ result
]

{ #category : #copying }
Interval >> copyFrom: startIndex to: stopIndex [
	(startIndex = 1 and: [stopIndex = self size]) ifTrue: [^self].
	stopIndex < startIndex ifTrue: [^self copyEmpty].
	^(self at: startIndex) to: (self at: stopIndex) by: step
]

{ #category : #enumerating }
Interval >> do: aBlock [ 
	"Evaluate aBlock for each value of the interval.
	Implementation note: instead of repeatedly incrementing the value
	    aValue := aValue + step.
	until stop is reached,
	We prefer to recompute value from start
	    aValue := start + (index * step).
	This is better for floating points accuracy, while not degrading Integer and Fraction speed too much.
	Moreover, this is consistent with methods #at: and #size"
	
	| aValue index size |
	index := 0.
	size := self size.
	[index < size]
		whileTrue: [aValue := start + (index * step).
			index := index + 1.
			aBlock value: aValue]
]

{ #category : #accessing }
Interval >> extent [ 
	"Answer the max - min of the receiver interval."
	"(10 to: 50) extent"

	^stop - start
]

{ #category : #accessing }
Interval >> first [ 
	"Refer to the comment in SequenceableCollection|first."

	^start
]

{ #category : #comparing }
Interval >> hash [
	"Hash is reimplemented because = is implemented."
        ^((start hash hashMultiply bitXor: self last hash) hashMultiply
                bitXor: self size)
]

{ #category : #accessing }
Interval >> increment [
	"Answer the receiver's interval increment."

	^step
]

{ #category : #accessing }
Interval >> indexOf: anElement startingAt: startIndex [
	"startIndex is an positive integer, the collection index where the search is started."
	"during the computation of val , floats are only used when the receiver	contains floats"

	| index val |
	(self rangeIncludes: anElement) ifFalse: [ ^0 ].
	val := anElement - self first / self increment.
	val isFloat
		ifTrue: [
			(val - val rounded) abs * 100000000 < 1 ifFalse: [ ^0 ].
			index := val rounded + 1 ]
		ifFalse: [
			val isInteger ifFalse: [ ^0 ].
			index := val + 1 ].
	"finally, the value of startIndex comes into play:"
	(index between: startIndex and: self size) ifFalse: [ ^0 ].
	^index
]

{ #category : #testing }
Interval >> isEmpty [
	^self size = 0
]

{ #category : #testing }
Interval >> isInterval [

	^ true
]

{ #category : #accessing }
Interval >> last [ 
	"Refer to the comment in SequenceableCollection|last."

	^stop - (stop - start \\ step)
]

{ #category : #enumerating }
Interval >> permutationsDo: aBlock [
	"Repeatly value aBlock with a single copy of the receiver. Reorder the copy
	so that aBlock is presented all (self size factorial) possible permutations."
	"(1 to: 4) permutationsDo: [:each | Transcript cr; show: each printString]"

	self asArray permutationsDo: aBlock

]

{ #category : #printing }
Interval >> printOn: aStream [
	aStream nextPut: $(;
	 print: start;
	 nextPutAll: ' to: ';
	 print: stop.
	step ~= 1 ifTrue: [aStream nextPutAll: ' by: '; print: step].
	aStream nextPut: $)
]

{ #category : #accessing }
Interval >> rangeIncludes: aNumber [
	"Return true if the number lies in the interval between start and stop."

	step >= 0
		ifTrue: [^ aNumber between: start and: stop]
		ifFalse: [^ aNumber between: stop and: start]

]

{ #category : #enumerating }
Interval >> reverseDo: aBlock [ 
	"Evaluate aBlock for each element of my interval, in reverse order.
	Implementation notes: see do: for an explanation on loop detail"

	| aValue index |
	index := self size.
	[index > 0]
		whileTrue: [
			index := index - 1.
			aValue := start + (index * step).
			aBlock value: aValue]
]

{ #category : #converting }
Interval >> reversed [
	self isEmpty ifTrue: [^stop to: start by: step negated].
	^self last to: start by: step negated
]

{ #category : #private }
Interval >> setFrom: startInteger to: stopInteger by: stepInteger [

	start := startInteger.
	stop := stopInteger.
	step := stepInteger
]

{ #category : #accessing }
Interval >> size [
	"Answer how many elements the receiver contains."

	step < 0
		ifTrue: [start < stop
				ifTrue: [^ 0]
				ifFalse: [^ stop - start // step + 1]]
		ifFalse: [stop < start
				ifTrue: [^ 0]
				ifFalse: [^ stop - start // step + 1]]
]

{ #category : #sorting }
Interval >> sorted [
	"an Interval is already sorted"
	step < 0 ifTrue: [^self reversed].
	^self
]

{ #category : #private }
Interval >> species [

	^Array
]

{ #category : #printing }
Interval >> storeOn: aStream [ 
	aStream nextPut: $(;
	 store: start;
	 nextPutAll: ' to: ';
	 store: stop.
	step ~= 1 ifTrue: [aStream nextPutAll: ' by: '; store: step].
	aStream nextPut: $)
]

{ #category : #accessing }
Interval >> sum [
	"Optimized version. Use the sum(n * i - k, i=a..b) = -1/2 * (a - b - 1) * (n * (a + b) - 2 * k) equation with a = 1, n = step, b = self size and k = step - start."

	| b |
	b := self size.
	^b * ((b - 1) * step + (start * 2)) / 2
]
