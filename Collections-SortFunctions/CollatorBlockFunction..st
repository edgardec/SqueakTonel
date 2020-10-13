"
A CollatorBlockFunction is a special SortFunction using a dyadic block to collate objects.

Instance Variables

	collator	<Block>	a dyadic block that must return a -1, 0, or 1.
"
Class {
	#name : #CollatorBlockFunction,
	#superclass : #SortFunction,
	#instVars : [
		'collatorBlock'
	],
	#category : #'Collections-SortFunctions'
}

{ #category : #'instance creation' }
CollatorBlockFunction class >> usingBlock: twoArgsBlock [
	^self new
		collatorBlock: twoArgsBlock
]

{ #category : #comparing }
CollatorBlockFunction >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].
	^collatorBlock = anObject collatorBlock
]

{ #category : #evaluating }
CollatorBlockFunction >> collate: anObject1 with: anObject2 [

	^collatorBlock value: anObject1 value: anObject2 
]

{ #category : #accessing }
CollatorBlockFunction >> collatorBlock [
	^collatorBlock
]

{ #category : #accessing }
CollatorBlockFunction >> collatorBlock: aBlock [
	collatorBlock := aBlock
]

{ #category : #comparing }
CollatorBlockFunction >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ collatorBlock hash
]
