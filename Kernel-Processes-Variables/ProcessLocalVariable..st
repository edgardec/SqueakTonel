"
My subclasses have values specific to the active process. They can be read with #value and set with #value:
"
Class {
	#name : #ProcessLocalVariable,
	#superclass : #ProcessSpecificVariable,
	#category : #'Kernel-Processes-Variables'
}

{ #category : #accessing }
ProcessLocalVariable class >> value: anObject [
	
	^Processor activeProcess environmentAt: self put: anObject
]
