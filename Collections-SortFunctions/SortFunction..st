"
I am intended to be used in place of two arg sort blocks.

Usage

In the following example, an ascending SortFunction is created based on the result of the #first message send to each object.
#(#(1 2) #(2 3) #(0 0)) sorted: #first ascending.

To sort by the #last element, but descending, the following would be used:
#(#(1 2) #(2 3) #(0 0)) sorted: #last descending.

One can use blocks as well. The following sorts in descending order, the sub elements based on the sum of their values.
| sumBlock |
sumBlock := [:sequence | sequence inject: 0 into: [:sum :each | sum + each]].
#(#(1 2) #(2 3) #(0 0)) sorted: sumBlock descending.

One can even use 2 arg blocks, for those cases where the function isn't expressible with objects that respond to < and =. The only catch, is that such a function has to return not true and false, but instead a collation order, values of -1 (for before), 0 (the same) or 1 (to follow). For example:

| oddBlock |
oddBlock :=
		[:a :b |
		a odd = b odd ifTrue: [0] ifFalse: [a odd ifTrue: [-1] ifFalse: [1]]].
#(1 5 1 3 2 7 9 4 6) asSortedCollection: oddBlock descending

Instance Variables
	collator	<SortFunction>	This is the object responsible for collating objetcs, generally a SortFunction.


"
Class {
	#name : #SortFunction,
	#superclass : #Object,
	#classVars : [
		'Default'
	],
	#category : #'Collections-SortFunctions'
}

{ #category : #accessing }
SortFunction class >> default [
	^Default
]

{ #category : #converting }
SortFunction >> , aSortFunction [
	"Return a new SortFunction which is the concatenation of aSortFunction to me, I will be the primary sort, but if I compare equal, I will defer to the argument."

	^ChainedSortFunction startWith: self then: aSortFunction asSortFunction
]

{ #category : #converting }
SortFunction >> asSortFunction [

	^self
]

{ #category : #evaluating }
SortFunction >> collate: value1 with: value2 [
	"answer the collation order for the two values -1,0 or 1"
	
	^self subclassResponsibility
]

{ #category : #converting }
SortFunction >> reversed [
	"Return new sort function with reverse sort order."

	^ReverseSortFunction on: self
]

{ #category : #converting }
SortFunction >> undefinedFirst [
	"Return a new SortFunction that sort all the nil first, an non nil with myself."
	^(UndefinedSortFunction on: self) undefinedFirst
]

{ #category : #converting }
SortFunction >> undefinedLast [
	"Return a new SortFunction that sort all the nil last, an non nil with myself."
	^(UndefinedSortFunction on: self) undefinedLast
]

{ #category : #evaluating }
SortFunction >> value: anObject value: bObject [
	"Masquerade as a two argument block, used by many of the sorting APIs, by returning whether anObject should be placed before bObject or not."

	| result |
	result := (self collate: anObject with: bObject).
	^result <= 0
]
