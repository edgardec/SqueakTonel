"
A SetElement is a special wrapper used to handle addition of some special elements into Set.
This is necessary mainly for storing an UndefinedObject in a Set, since nil is used in Set algorithm to designate free slots in internal storage.

Instance Variables
	enclosedElement:		<Object>

enclosedElement
	- the real element we wish to put into the set

"
Class {
	#name : #SetElement,
	#superclass : #Object,
	#instVars : [
		'enclosedElement'
	],
	#classVars : [
		'NilElement'
	],
	#category : #'Collections-Support'
}

{ #category : #'class initialization' }
SetElement class >> initialize [
	NilElement := self with: nil.

]

{ #category : #'instance creation' }
SetElement class >> with: anObject [
	^ self new enclosedSetElement: anObject
]

{ #category : #accessing }
SetElement class >> withNil [
	^ NilElement

]

{ #category : #comparing }
SetElement >> = anObject [
	^ anObject class = self class and: [ enclosedElement = anObject enclosedSetElement ]

]

{ #category : #converting }
SetElement >> asSetElement [
	"A receiver has to be included into a set, as a distinct object.
	We need to wrap receiver in own turn, otherwise #enclosedSetElement will return wrong object for that set"
	^ SetElement with: self
]

{ #category : #accessing }
SetElement >> enclosedSetElement [
	^ enclosedElement
]

{ #category : #accessing }
SetElement >> enclosedSetElement: anObject [
	enclosedElement := anObject
]

{ #category : #comparing }
SetElement >> hash [
	^ enclosedElement hash

]
