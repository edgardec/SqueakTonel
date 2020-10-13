"
I am an object that doesn't always hash correctly.  I am used for testing the HashTester.
"
Class {
	#name : #BadHasher,
	#superclass : #Object,
	#category : #'Tests-Utilities'
}

{ #category : #comparing }
BadHasher >> hash [
	"answer with a different hash some of the time"
	100 atRandom < 30
		ifTrue: [^ 1]. 
	^ 2
]
