Class {
	#name : #NullEncoder,
	#superclass : #Object,
	#instVars : [
		'target',
		'filterSelector'
	],
	#category : #'Morphic-Support'
}

{ #category : #configuring }
NullEncoder class >> defaultTarget [
	^OrderedCollection new.

]

{ #category : #configuring }
NullEncoder class >> filterSelector [
	^#writeOnFilterStream:

]

{ #category : #processing }
NullEncoder class >> process:anObject [
	^self stream process:anObject.


]

{ #category : #creation }
NullEncoder class >> stream [
	^self streamOn:self defaultTarget. 

]

{ #category : #creation }
NullEncoder class >> stream:newTarget [
	^self new initWithTarget:newTarget.

]

{ #category : #creation }
NullEncoder class >> streamOn:newTargetCollection [
	^self new initWithTarget:newTargetCollection.

]

{ #category : #creation }
NullEncoder class >> streamOnFile:fileName [
	^self new initWithTarget:(FileStream newFileNamed: fileName).

]

{ #category : #accessing }
NullEncoder >> close [

	^target close.

]

{ #category : #accessing }
NullEncoder >> contents [
	^target contents.

]

{ #category : #writing }
NullEncoder >> forward:anObject [
	anObject ~= nil ifTrue:[target write:anObject].

]

{ #category : #initialization }
NullEncoder >> initWithTarget:aTarget [
	target := aTarget.
	filterSelector := self class filterSelector.
	^self.

]

{ #category : #processing }
NullEncoder >> process:anObject [
	self write:anObject.
	^self contents.
]

{ #category : #accessing }
NullEncoder >> target [
	^target.
]

{ #category : #writing }
NullEncoder >> write:anObject [
	filterSelector  ifNil:[filterSelector:=self class filterSelector].
	anObject ifNotNil: [anObject perform:filterSelector with:self].

]

{ #category : #writing }
NullEncoder >> writeObject:anObject [
	^self forward:anObject.

]
