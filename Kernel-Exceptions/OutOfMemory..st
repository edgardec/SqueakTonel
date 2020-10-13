"
OutOfMemory is signaled when an allocation fails due to not having enough memory. Its default action signals the low-space semaphore.
"
Class {
	#name : #OutOfMemory,
	#superclass : #Error,
	#category : #'Kernel-Exceptions'
}

{ #category : #private }
OutOfMemory >> isResumable [
	^true
]
