"
I implement a simple Stack. #push: adds a new object of any kind on top of the stack. #pop returns the first element and remove it from the stack. #top answer the first element of the stack without removing it.
"
Class {
	#name : #Stack,
	#superclass : #Object,
	#instVars : [
		'linkedList'
	],
	#category : #'Collections-Stack'
}

{ #category : #private }
Stack >> errorEmptyStack [
	self error: 'this stack is empty'
]

{ #category : #'initialize-release' }
Stack >> initialize [
	super initialize.
	linkedList := LinkedList new
]

{ #category : #testing }
Stack >> isEmpty [
	^ self linkedList isEmpty
]

{ #category : #private }
Stack >> linkedList [
	"The stack is implemented with a LinkedList. Do NOT call this function, it  
	is for private use !"
	^ linkedList
]

{ #category : #private }
Stack >> notEmptyCheck [
	"Ensure the stack is not empty."
	self isEmpty
		ifTrue: [self errorEmptyStack]
]

{ #category : #removing }
Stack >> pop [
	"Returns the first element and remove it from the stack."

	self notEmptyCheck.
	^self linkedList removeFirst element
]

{ #category : #copying }
Stack >> postCopy [
	super postCopy.
	linkedList := linkedList copy
]

{ #category : #adding }
Stack >> push: anObject [ 
	"Adds a new object of any kind on top of the stack."
	self linkedList
		addFirst: (StackLink with: anObject).
	^ anObject.
]

{ #category : #accessing }
Stack >> size [
	"How many objects in me ?"
	^ self linkedList size
]

{ #category : #accessing }
Stack >> top [
	"Answer the first element of the stack without removing it."
	self notEmptyCheck.
	^ self linkedList first element
]
