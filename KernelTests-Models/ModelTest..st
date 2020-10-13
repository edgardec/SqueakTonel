Class {
	#name : #ModelTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Models'
}

{ #category : #tests }
ModelTest >> testCopyDependents [

	| bar foo |
	foo := Model new.
	foo addDependent: 42.
	self assert: {42} equals: foo dependents asArray.
	
	bar := foo copy.
	self assert: bar dependents isEmpty.
]
