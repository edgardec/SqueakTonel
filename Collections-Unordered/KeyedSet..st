"
Like Set except a key of every element is used for hashing and searching instead of the element itself.  keyBlock gets the key of an element.
"
Class {
	#name : #KeyedSet,
	#superclass : #Set,
	#instVars : [
		'keyBlock'
	],
	#category : #'Collections-Unordered'
}

{ #category : #'instance creation' }
KeyedSet class >> keyBlock: oneArgBlock [
	"Create a new KeySet whose way to access an element's key is by executing oneArgBlock on the element"

	^ self new keyBlock: oneArgBlock
]

{ #category : #adding }
KeyedSet >> add: newObject [
	"Include newObject as one of the receiver's elements, but only if
	not already present. Answer newObject."

	| index |
	index := self scanFor: (keyBlock value: newObject).
	(array at: index) ifNil: [self atNewIndex: index put: newObject asSetElement].
	^ newObject
]

{ #category : #adding }
KeyedSet >> addAll: aCollection [ 
	"Include all the elements of aCollection as the receiver's elements"

	(aCollection respondsTo: #associationsDo:)
		ifTrue: [aCollection associationsDo: [:ass | self add: ass]]
		ifFalse: [aCollection do: [:each | self add: each]].
	^ aCollection
]

{ #category : #accessing }
KeyedSet >> at: key [ 
	"Answer the value associated with the key."

	^ self at: key ifAbsent: [self errorKeyNotFound: key]
]

{ #category : #accessing }
KeyedSet >> at: key ifAbsent: aBlock [ 
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^(array at: (self scanFor: key)) ifNil: [ aBlock value ] ifNotNil:[:obj| obj enclosedSetElement]
]

{ #category : #accessing }
KeyedSet >> at: key ifAbsentPut: aBlock [ 
	"Answer the value associated with the key or, if key isn't found,
	add the result of evaluating aBlock to self"

	^ self at: key ifAbsent: [self add: aBlock value]
]

{ #category : #accessing }
KeyedSet >> at: key ifPresent: aBlock [
	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

	| v |
	v := self at: key ifAbsent: [^ nil].
	^ aBlock value: v

]

{ #category : #copying }
KeyedSet >> copyEmpty [

	^super copyEmpty
		keyBlock: keyBlock;
		yourself
]

{ #category : #private }
KeyedSet >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by nil.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one."

	| element index |
	index := start.
	[ (element := array at: (index := index \\ array size + 1)) == nil ] whileFalse: [
		| newIndex |
		(newIndex := self scanFor: (keyBlock value: element enclosedSetElement)) = index ifFalse: [
			array 
				at: newIndex put: element;
				at: index put: nil ] ]
]

{ #category : #testing }
KeyedSet >> includes: anObject [ 
	
	(array at: (self scanFor: (keyBlock value: anObject))) ifNil: [ ^false ] ifNotNil: [ ^true ]
]

{ #category : #testing }
KeyedSet >> includesKey: key [

	(array at: (self scanFor: key)) ifNil: [ ^false ] ifNotNil: [ ^true ]
]

{ #category : #private }
KeyedSet >> initialize: n [

	super initialize: n.
	keyBlock := #key

]

{ #category : #initialize }
KeyedSet >> keyBlock: oneArgBlock [
	"When evaluated return the key of the argument which will be an element of the set"

	keyBlock := oneArgBlock
]

{ #category : #accessing }
KeyedSet >> keys [
	"Answer an Array containing the receiver's keys."
	
	^Array new: self size streamContents: [:s| self keysDo: [:key| s nextPut: key]]
]

{ #category : #accessing }
KeyedSet >> keysDo: block [

	self do: [:item | block value: (keyBlock value: item)]
]

{ #category : #accessing }
KeyedSet >> keysSorted [

	^self keys sort
]

{ #category : #accessing }
KeyedSet >> like: anObject [
	"Answer an object in the receiver that is equal to anObject,
	nil if no such object is found. Relies heavily on hash properties"

	^(array at: (self scanFor: (keyBlock value: anObject)))
		ifNotNil: [ :element | element enclosedSetElement]
]

{ #category : #accessing }
KeyedSet >> like: anObject ifAbsent: aBlock [
	"Answer an object in the receiver that is equal to anObject,
	or evaluate the block if not found. Relies heavily on hash properties"

	^(array at: (self scanFor: (keyBlock value: anObject)))
		ifNil: [ aBlock value ]
		ifNotNil: [ :element | element enclosedSetElement ]
]

{ #category : #adding }
KeyedSet >> member: newObject [
	"Include newObject as one of the receiver's elements, if already exists just return it"

	| index |
	index := self scanFor: (keyBlock value: newObject).
	(array at: index) ifNotNil: [ :element | ^element enclosedSetElement].
	self atNewIndex: index put: newObject asSetElement.
	^ newObject
]

{ #category : #private }
KeyedSet >> noCheckNoGrowFillFrom: anArray [
	"Add the elements of anArray except nils to me assuming that I don't contain any of them, they are unique and I have more free space than they require."

	1 to: anArray size do: [ :index |
		(anArray at: index) ifNotNil: [ :object |
			array
				at: (self scanForEmptySlotFor: (keyBlock value: object enclosedSetElement))
				put: object ] ]
]

{ #category : #accessing }
KeyedSet >> put: newObject [
	"Include newObject as one of the receiver's elements even if there is already an element with the same key. Answer the replaced SetElement object or nil if no element existed with newObject's key. This method's behavior is similar to Dictionary >> #at:put:'s, hence the name."

	| index |
	index := self scanFor: (keyBlock value: newObject).
	(array at: index)
		ifNil: [
			self atNewIndex: index put: newObject asSetElement.
			^nil ]
		ifNotNil: [ :oldObject |
			array at: index put: newObject asSetElement.
			^oldObject ]
]

{ #category : #removing }
KeyedSet >> remove: oldObject ifAbsent: aBlock [

	| index |
	index := self scanFor: (keyBlock value: oldObject).
	(array at: index) ifNil: [ ^ aBlock value ].
	array at: index put: nil.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^ oldObject
]

{ #category : #removing }
KeyedSet >> removeAll [
	"See super."
	
	| tmp |
	tmp := keyBlock.
	super removeAll.
	keyBlock := tmp
]

{ #category : #removing }
KeyedSet >> removeKey: key [ 

	^ self removeKey: key ifAbsent: [self errorKeyNotFound: key]
]

{ #category : #removing }
KeyedSet >> removeKey: key ifAbsent: aBlock [

	| index obj |
	index := self scanFor: key.
	obj := (array at: index) ifNil: [ ^ aBlock value ].
	array at: index put: nil.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^ obj enclosedSetElement
]

{ #category : #private }
KeyedSet >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| index start size |
	index := start := anObject hash \\ (size := array size) + 1.
	[ 
		| element |
		((element := array at: index) == nil or: [ (keyBlock value: element enclosedSetElement) = anObject ])
			ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]
