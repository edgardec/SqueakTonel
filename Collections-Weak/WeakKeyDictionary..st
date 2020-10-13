"
I am a dictionary holding only weakly on my keys. This is a bit dangerous since at any time my keys can go away. Clients are responsible to register my instances by WeakArray such that the appropriate actions can be taken upon loss of any keys.

See WeakRegistry for an example of use.

"
Class {
	#name : #WeakKeyDictionary,
	#superclass : #Dictionary,
	#instVars : [
		'finalizer'
	],
	#category : #'Collections-Weak'
}

{ #category : #adding }
WeakKeyDictionary >> add: anAssociation [
	self at: anAssociation key put: anAssociation value.
	^ anAssociation
]

{ #category : #accessing }
WeakKeyDictionary >> associationClass [

	^WeakKeyAssociation
]

{ #category : #enumerating }
WeakKeyDictionary >> associationsDo: aBlock [ 
	"Evaluate aBlock for each of the receiver's elements (key/value 
	associations)."

	tally = 0 ifTrue: [ ^self].
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :association |
			association key ifNotNil: [ :key | "Don't let the key go away."
				aBlock value: association ] ] ]
]

{ #category : #accessing }
WeakKeyDictionary >> at: key ifAbsent: aBlock [ 
	"While no nil key can be added, keys become nil when they are garbage collected.
	This must not let nil accidentally 'inherit' the value of such a stale association."
	key ifNil: [^ aBlock value].
	^ super at: key ifAbsent: aBlock
]

{ #category : #accessing }
WeakKeyDictionary >> at: key put: anObject [ 
	"Set the value at key to be anObject.  If key is not found, create a new
	entry for key and set is value to anObject. Answer anObject."
	
	key ifNil: [ ^anObject ].
	^super at: key put: anObject
]

{ #category : #finalization }
WeakKeyDictionary >> finalizeValues [
	"Remove and finalize all elements which have nil key"
	
	|  cleanUpAfterRemove |
	tally = 0 ifTrue: [ ^self ].
	cleanUpAfterRemove := false.
	1 to: array size do: [ :index |
		(array at: index) 
			ifNil: [ cleanUpAfterRemove := false ]
			ifNotNil: [ :element |
				element key
					ifNil: [
						finalizer ifNotNil: [ finalizer value: element value ].
						array at: index put: nil.
						tally := tally - 1.
						cleanUpAfterRemove := true ]
					ifNotNil: [ :key |
						cleanUpAfterRemove ifTrue: [
							| newIndex |
							(newIndex := self scanFor: key) = index ifFalse: [
								array 
									at: newIndex put: element;
									at: index put: nil ] ] ] ] ].
	cleanUpAfterRemove ifTrue: [ "Continue rehashing at the front of array"
		self fixCollisionsFrom: array size ]
					
]

{ #category : #accessing }
WeakKeyDictionary >> finalizer: aValueable [

	finalizer := aValueable
]

{ #category : #private }
WeakKeyDictionary >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by nil.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one."

	| element index |
	index := start.
	[ (element := array at: (index := index \\ array size + 1)) == nil ] whileFalse: [
		element key
			ifNil: [ 
				finalizer ifNotNil: [ finalizer value: element value ].
				array at: index put: nil.
				tally := tally - 1 ]
			ifNotNil: [ :key | "Don't let the key go away"
				| newIndex |
				(newIndex := self scanFor: key) = index ifFalse: [
					array 
						at: newIndex put: element;
						at: index put: nil ] ] ]
]

{ #category : #private }
WeakKeyDictionary >> noCheckNoGrowFillFrom: anArray [
	"Add the elements of anArray except nils and flag to me assuming that I don't contain any of them, they are unique and I have more free space than they require."

	tally := 0.
	1 to: anArray size do: [ :index |
		(anArray at: index) ifNotNil: [ :association |
			association key 
				ifNil: [ finalizer ifNotNil: [ finalizer value: association value ] ]
				ifNotNil: [ :key | "Don't let the key go away"
					array
						at: (self scanForEmptySlotFor: key)
						put: association.
					tally := tally + 1 ] ] ]
]

{ #category : #public }
WeakKeyDictionary >> slowSize [
	"Careful! Answer the maximum amount
	of elements in the receiver, not the
	exact amount"

	| count |
	count := 0.
	1 to: array size do: [ :index |
		(array at: index) ifNotNil: [ :object |
			object key ifNotNil: [
				count := count + 1 ] ] ].
	^count
]
