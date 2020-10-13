"
A ValueLink is a Link containing a Value.
Adding an object to a LinkedList which is not a Link will create a ValueLink containing that object.


value - The object this link points to.
"
Class {
	#name : #ValueLink,
	#superclass : #Link,
	#instVars : [
		'value'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
ValueLink class >> value: aValue [

	^self new value: aValue
]

{ #category : #comparing }
ValueLink >> = anotherObject [

	^self species == anotherObject species 
	and: [self value = anotherObject value 
	and: [self nextLink == anotherObject nextLink]]
]

{ #category : #comparing }
ValueLink >> hash [

	^self value hash bitXor: self nextLink identityHash 

]

{ #category : #printing }
ValueLink >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	value printOn: aStream.
	aStream nextPut: $)

]

{ #category : #accessing }
ValueLink >> value [

	^ value
]

{ #category : #accessing }
ValueLink >> value: anObject [

	value := anObject.
]
