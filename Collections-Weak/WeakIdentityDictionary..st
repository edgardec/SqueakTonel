"
I am a WeakIdentityDictionary, that is a dictionary pointing weakly to its associations of key->value pairs.
I am especially usefull for handling undeclared bindings that will be naturally garbage collected without having to scan all the CompiledMethods.

Instance variables:
    vacuum    <Object> a unique object used for marking empty slots

Due to usage of WeakArray for my own storage, reclaimed slots will be nilled out.
I cannot consider a nil slot as empty because of garbage collection does not fix collisions.
Thus I need to differentiate empty slots (vacuum) from garbaged collected slots (nil).

If I did not reclaim the nil slots and make them vacuum again, then my capacity would grow indefinitely.
My strategy to avoid such growth is to randomly cleanup the garbage collected slot encountered when scanning for a key.
It should mitigate the growth since this method is used when adding a new entry.

Due to those not yet cleaned-up nil slots I might over-estimate my size. Don't take it too literally.
"
Class {
	#name : #WeakIdentityDictionary,
	#superclass : #IdentityDictionary,
	#instVars : [
		'vacuum'
	],
	#category : #'Collections-Weak'
}

{ #category : #accessing }
WeakIdentityDictionary >> add: anAssociation [

	| index |
	index := self scanFor: anAssociation key.
	(array at: index)
		ifNil: [ self atNewIndex: index put: anAssociation ]
		ifNotNil: [ :element |
				element == vacuum
					ifTrue: [ self atNewIndex: index put: anAssociation ]
					ifFalse: [ element value: anAssociation value ] ].
	^anAssociation
]

{ #category : #private }
WeakIdentityDictionary >> arrayType [
	^ WeakArray
]

{ #category : #accessing }
WeakIdentityDictionary >> associationAt: key ifAbsent: aBlock [ 
	"Answer the association with the given key.
	If key is not found, return the result of evaluating aBlock."

	^((array at: (self scanFor: key))
		ifNil: [ aBlock value ]
		ifNotNil: [:association |
			association == vacuum
				ifTrue: [ aBlock value ]
				ifFalse: [ association ] ])
]

{ #category : #enumerating }
WeakIdentityDictionary >> associationsDo: aBlock [ 
	"Evaluate aBlock for each of the receiver's elements (key/value 
	associations)."

	tally = 0 ifTrue: [ ^self].
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :element |
			element == vacuum ifFalse: [ aBlock value: element ] ] ]
]

{ #category : #accessing }
WeakIdentityDictionary >> at: key ifAbsent: aBlock [ 
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^((array at: (self scanFor: key))
		ifNil: [ aBlock ]
		ifNotNil: [:association |
			association == vacuum
				ifTrue: [ aBlock ]
				ifFalse: [ association ] ]) value "Blocks and Associations expect #value"
]

{ #category : #accessing }
WeakIdentityDictionary >> at: key ifPresent: oneArgBlock ifAbsent: absentBlock [
	"Lookup the given key in the receiver. If it is present, answer the
	 value of evaluating the oneArgBlock with the value associated
	 with the key, otherwise answer the value of absentBlock."
	^(array at: (self scanFor: key))
		ifNil: [absentBlock value]
		ifNotNil:
			[:association|
			 association == vacuum
				ifTrue: [absentBlock value]
				ifFalse: [oneArgBlock value: association value]]
]

{ #category : #accessing }
WeakIdentityDictionary >> at: key ifPresent: oneArgBlock ifAbsentPut: absentBlock [
	"Lookup the given key in the receiver. If it is present, answer the value of
	 evaluating oneArgBlock with the value associated with the key. Otherwise
	 add the value of absentBlock under the key, and answer that value."

	| index value |
	index := self scanFor: key.
	(array at: index) ifNotNil:
		[:element|
		 element == vacuum ifFalse: [^oneArgBlock value: element value] ].
	value := absentBlock value.
	self atNewIndex: index put: (self associationClass key: key value: value).
	^value
]

{ #category : #accessing }
WeakIdentityDictionary >> at: key put: anObject [ 
	"Set the value at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject."

	| index |
	index := self scanFor: key.
	(array at: index)
		ifNil:
			["it's possible to get here if the association just died"
			self atNewIndex: index put: (self associationClass key: key value: anObject) ]
		ifNotNil: [ :association | 
			association == vacuum
				ifTrue: [ self atNewIndex: index put: (self associationClass key: key value: anObject) ]
				ifFalse: [association value: anObject ] ].
	^anObject
]

{ #category : #private }
WeakIdentityDictionary >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by vacuum.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one."

	| element index |
	index := start.
	[ (element := array at: (index := index \\ array size + 1)) == vacuum ] whileFalse: [
		element
			ifNil:
				[ "The binding at this slot was reclaimed - finish the cleanup"
				array at: index put: vacuum.
				tally := tally - 1 ]
			ifNotNil:
				[| newIndex |
				(newIndex := self scanFor: element key) = index ifFalse: [
					array 
						at: newIndex put: element;
						at: index put: vacuum ] ] ]
]

{ #category : #private }
WeakIdentityDictionary >> growTo: anInteger [
	"Grow the elements array and reinsert the old elements"
	
	| oldElements |
	oldElements := array.
	array := self arrayType new: anInteger withAll: vacuum.
	self noCheckNoGrowFillFrom: oldElements
]

{ #category : #testing }
WeakIdentityDictionary >> includesKey: key [ 
	"Answer whether the receiver has a key equal to the argument, key."
	
	(array at: (self scanFor: key))
		ifNil: [
			"it just has been reclaimed"
			^false]
		ifNotNil: [ :element |
			element == vacuum
				ifTrue: [ ^false ]
				ifFalse: [ ^true ] ]
]

{ #category : #private }
WeakIdentityDictionary >> initialize: n [
	vacuum := Object new.
	array := self arrayType new: n withAll: vacuum.
	tally := 0
]

{ #category : #private }
WeakIdentityDictionary >> noCheckNoGrowFillFrom: anArray [
	"Add the elements of anArray except nils to me assuming that I don't contain any of them, they are unique and I have more free space than they require."

	tally := 0.
	1 to: anArray size do: [ :index |
		(anArray at: index) ifNotNil: [ :association |
			association == vacuum ifFalse: [
				array
					at: (self scanForEmptySlotFor: association key)
					put: association.
				tally := tally + 1 ] ] ]
]

{ #category : #copying }
WeakIdentityDictionary >> postCopy [
	"Beware: do share the bindings, so changing a binding value in the copy will also change it in the original.
	Copying the bindings would not make sense: we hold weakly on them, so they would die at first garbage collection."

	| oldVacuum |
	super postCopy.
	oldVacuum := vacuum.
	vacuum := Object new.
	array := array collect: [ :association |
		association ifNotNil: [
			association == oldVacuum
				ifTrue: [ vacuum ]
				ifFalse: [ association ] ] ]
]

{ #category : #removing }
WeakIdentityDictionary >> removeKey: key ifAbsent: aBlock [ 
	"Remove key (and its associated value) from the receiver. If key is not in 
	the receiver, answer the result of evaluating aBlock. Otherwise, answer 
	the value externally named by key."

	| index association |
	index := self scanFor: key.
	(association := (array at: index)) == vacuum ifTrue: [ ^aBlock value ].
	array at: index put: vacuum.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^association value
]

{ #category : #removing }
WeakIdentityDictionary >> removeUnreferencedKeys [
	"Make sure tally is set to the right size by #compact."

	super removeUnreferencedKeys.
	self compact
]

{ #category : #private }
WeakIdentityDictionary >> scanFor: anObject [
	"Scan the array for the first slot containing either
	- a vacuum object indicating an empty slot
	- or a binding whose key matches anObject.
	Answer the index of that slot or raise an error if no slot is found which should never happen."

	| index start size |
	index := start := anObject scaledIdentityHash \\ (size := array size) + 1.
	[ 
		(array at: index) ifNotNil: [ :element |
			(element == vacuum or: [ element key == anObject ])
				ifTrue: [ ^index ] ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
WeakIdentityDictionary >> scanForEmptySlotFor: anObject [
	"Scan the array for the first empty slot marked by vacuum object or nil.
	Answer the index of that slot or raise an error if no slot is found, which should never happen."

	| index start |	
	index := start := anObject scaledIdentityHash \\ array size + 1.
	[ 
		| element |
		((element := array at: index) == vacuum or: [ element == nil ]) ifTrue: [ ^index ].
		(index := index \\ array size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #accessing }
WeakIdentityDictionary >> slowSize [
	"Careful! Answer the maximum amount
	of elements in the receiver, not the
	exact amount"

	| count |
	count := 0.
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :object |
			object == vacuum ifFalse: [
				count := count + 1 ] ] ].
	^count
]
