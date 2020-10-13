"
TestLocalVariable is a test class using in ProcessSpecificTest.
"
Class {
	#name : #TestLocalVariable,
	#superclass : #ProcessLocalVariable,
	#category : #'KernelTests-Processes'
}

{ #category : #'as yet unclassified' }
TestLocalVariable class >> default [
	"My default value for a new process is 0."
	
	^0
]
