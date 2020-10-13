"
I am a ProcessLocalVariable. I hold the an instance of Random for each process. If the process doesn't have such instance yet, then my class-side #default message will create one. The instance should not be shared among processes.

I implement all methods of Random's accessing category on the class side, and proxy them to the instance. If you want to use any other methods, or the object itself, then use #value directly.
"
Class {
	#name : #ThreadSafeRandom,
	#superclass : #ProcessLocalVariable,
	#category : #'Kernel-Numbers'
}

{ #category : #accessing }
ThreadSafeRandom class >> default [

	^self value: Random new
]

{ #category : #accessing }
ThreadSafeRandom class >> next [

	^self value next
]

{ #category : #accessing }
ThreadSafeRandom class >> next: anInteger [

	^self value next: anInteger
]

{ #category : #accessing }
ThreadSafeRandom class >> next: anInteger into: anArray [

	^self value next: anInteger into: anArray
]

{ #category : #accessing }
ThreadSafeRandom class >> nextInt: anInteger [

	^self value nextInt: anInteger
]
