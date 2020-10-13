"
I implement an element of a stack. I'm a container for any type of object, saved into the 'element' variable. My superclass Link allows me to be part of a LinkedList.
"
Class {
	#name : #StackLink,
	#superclass : #Link,
	#instVars : [
		'element'
	],
	#category : #'Collections-Stack'
}

{ #category : #'instance creation' }
StackLink class >> with: anObject [ 
	^ self new element: anObject
]

{ #category : #accessing }
StackLink >> element [
	^element
]

{ #category : #accessing }
StackLink >> element: anObject [ 
	"Any kind of Object."
	element := anObject
]

{ #category : #printing }
StackLink >> printOn: aStream [ 
	aStream nextPutAll: self class printString;
		 nextPutAll: ' with: ';
		 nextPutAll: self element printString
]
