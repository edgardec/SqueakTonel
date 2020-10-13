"
I am a simple holder of a prototype object and hand out copies when requested.
"
Class {
	#name : #PrototypeTester,
	#superclass : #Object,
	#instVars : [
		'prototype'
	],
	#category : #'Tests-Utilities'
}

{ #category : #'as yet unclassified' }
PrototypeTester class >> defaultRuns [
"the default number of times to test"
	^ 50
]

{ #category : #'as yet unclassified' }
PrototypeTester class >> with: aPrototype [
	^self new prototype:aPrototype
]

{ #category : #accessing }
PrototypeTester >> prototype [
	"Get a prototype"
	^ prototype copy 
]

{ #category : #accessing }
PrototypeTester >> prototype: aPrototype [ 
	"Set my prototype"
	prototype := aPrototype copy 
]

{ #category : #running }
PrototypeTester >> result [
	"Perform the test the default number of times"
	^ self resultFor: self class defaultRuns 
]
