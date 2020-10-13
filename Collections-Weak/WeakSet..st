"
I'm like Set but my instances only hold weakly to their elements.

Instance Variables:
	flag:		an Object which marks the empty slot in this instance. This object shouldn't be used anywhere else in the system. Every WeakSet has a different flag.

Differences from Set:
array is a WeakArray filled with flag initially. flag marks the empty slots, because elements which become garbage will be replaced with nil by the garbage collector. Besides nil, flag cannot be added to my instances.
"
Class {
	#name : #WeakSet,
	#superclass : #Set,
	#instVars : [
		'flag'
	],
	#category : #'Collections-Weak'
}

{ #category : #adding }
WeakSet >> add: newObject [
	"Include newObject as one of the receiver's elements, but only if
	not already present. Answer newObject"

	| index element |
	index := self scanFor: newObject.
	((element := array at: index) == flag or: [ element == nil ])
		ifTrue: [self atNewIndex: index put: newObject asSetElement].
	^newObject
]

{ #category : #private }
WeakSet >> arrayType [

	^WeakArray
]

{ #category : #enumerating }
WeakSet >> collect: aBlock [

	| newSet |
	newSet := self species new: self size.
	tally = 0 ifTrue: [ ^newSet ].
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :object |
			object == flag ifFalse: [
				newSet add: (aBlock value: object enclosedSetElement) ] ] ].
	^newSet
]

{ #category : #enumerating }
WeakSet >> do: aBlock [

	tally = 0 ifTrue: [ ^self ].
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :object |
			object == flag ifFalse: [
				aBlock value: object enclosedSetElement] ] ]
]

{ #category : #public }
WeakSet >> do: aBlock after: anElement [

	| index endIndex |
	tally = 0 ifTrue: [ ^self ].
	anElement
		ifNil: [ index := 0 ]
		ifNotNil: [ 
			index := self scanFor: anElement.
			(array at: index) == flag ifTrue: [
				index := 0 ] ].
	endIndex := array size.
	[ (index := index + 1) <= endIndex ] whileTrue: [
		(array at: index) ifNotNil: [ :object |
			object == flag ifFalse: [
				aBlock value: object enclosedSetElement] ] ]
]

{ #category : #private }
WeakSet >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by flag.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one."

	| element index |
	index := start.
	[ (element := array at: (index := index \\ array size + 1)) == flag ] whileFalse: [
		element 
			ifNil: [ "This object is gone"
				array at: index put: flag.
				tally := tally - 1 ]
			ifNotNil: [
				| newIndex |
				(newIndex := self scanFor: element enclosedSetElement) = index ifFalse: [
					array 
						at: newIndex put: element;
						at: index put: flag ] ] ]

]

{ #category : #private }
WeakSet >> growTo: anInteger [
	"Grow the elements array and reinsert the old elements"

	| oldElements |
	oldElements := array.
	array := self arrayType new: anInteger withAll: flag.
	self noCheckNoGrowFillFrom: oldElements
]

{ #category : #testing }
WeakSet >> includes: anObject [ 
	
	(array at: (self scanFor: anObject))
		ifNil: [ ^false ]
		ifNotNil: [ :object |
			object == flag
				ifTrue: [ ^false ]
				ifFalse: [ ^true ] ]
]

{ #category : #private }
WeakSet >> initialize: n [
	"Initialize array to an array size of n"

	super initialize: n.
	flag := Object new.
	array atAllPut: flag
]

{ #category : #accessing }
WeakSet >> like: anObject [
	"Answer an object in the receiver that is equal to anObject,
	nil if no such object is found. Relies heavily on hash properties"

	| element |
	^(element  := array at: (self scanFor: anObject)) == flag
		ifFalse: [ element enclosedSetElement]
]

{ #category : #accessing }
WeakSet >> like: anObject ifAbsent: aBlock [
	"Answer an object in the receiver that is equal to anObject,
	or evaluate the block if not found. Relies heavily on hash properties"

	| element |
	((element  := array at: (self scanFor: anObject)) == flag or: [ element == nil ])
		ifTrue: [ ^aBlock value ]
		ifFalse: [ ^element enclosedSetElement ]
]

{ #category : #private }
WeakSet >> noCheckNoGrowFillFrom: anArray [
	"Add the elements of anArray except nils and flag to me assuming that I don't contain any of them, they are unique and I have more free space than they require."

	tally := 0.
	1 to: anArray size do: [ :index |
		(anArray at: index) ifNotNil: [ :object |
			object == flag ifFalse: [ 
				array
					at: (self scanForEmptySlotFor: object enclosedSetElement)
					put: object.
				tally := tally + 1 ] ] ]
]

{ #category : #copying }
WeakSet >> postCopy [
	| oldFlag |
	super postCopy.
	oldFlag := flag.
	flag := Object new.
	array replaceAll: oldFlag with: flag.
]

{ #category : #removing }
WeakSet >> remove: oldObject ifAbsent: aBlock [

	| index |
	index := self scanFor: oldObject.
	(array at: index) == flag ifTrue: [ ^ aBlock value ].
	array at: index put: flag.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^oldObject
]

{ #category : #private }
WeakSet >> scanFor: anObject [
	"Scan the key array for the first slot containing either flag (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| index start size |
	index := start := anObject hash \\ (size := array size) + 1.
	[ 
		| element |
		((element := array at: index) == flag or: [ element enclosedSetElement = anObject ])
			ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
WeakSet >> scanForEmptySlotFor: anObject [
	"Scan the key array for the first slot containing an empty slot (indicated by flag or a nil). Answer the index of that slot. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := anObject hash \\ (size := array size) + 1.
	[ 
		| element |
		((element := array at: index) == flag or: [ element == nil ]) ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
WeakSet >> scanForLoadedSymbol: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or zero if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements"

	| element start finish |

	start := (anObject hash \\ array size) + 1.
	finish := array size.

	"Search from (hash mod size) to the end."
	start to: finish do:
		[:index | ((element := array at: index) == flag or: [element enclosedSetElement asString = anObject asString])
			ifTrue: [^ index ]].

	"Search from 1 to where we started."
	1 to: start-1 do:
		[:index | ((element := array at: index) == flag or: [element enclosedSetElement asString = anObject asString])
			ifTrue: [^ index ]].

	^ 0  "No match AND no empty slot"
]

{ #category : #accessing }
WeakSet >> size [
	"Careful! Answer the maximum amount
	of elements in the receiver, not the
	exact amount"

	^tally
]

{ #category : #public }
WeakSet >> slowSize [
	"Careful! Answer the maximum amount
	of elements in the receiver, not the
	exact amount"

	| count |
	count := 0.
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :object |
			object == flag ifFalse: [
				count := count + 1 ] ] ].
	^count
]
