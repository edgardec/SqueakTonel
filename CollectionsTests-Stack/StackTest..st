Class {
	#name : #StackTest,
	#superclass : #TestCase,
	#classInstVars : [
		'testSize'
	],
	#category : #'CollectionsTests-Stack'
}

{ #category : #tests }
StackTest >> testEmptyError [

	| aStack |
	aStack := Stack new.
	self should: [ aStack top ] raise: Error.
	self should: [ aStack pop] raise: Error.
	
	aStack push: 'element'.
	
	self assert: 'element' equals: aStack top.
	self assert: 'element' equals:  aStack pop.
	
	
	"The stack is empty again due to previous pop"
	self should: [ aStack top ] raise: Error.
	self should: [ aStack pop] raise: Error.
]

{ #category : #tests }
StackTest >> testPop [

	| aStack res elem |
	elem := 'anElement'.	
	aStack := Stack new.
	self assert: aStack isEmpty.
	
	aStack push: 'a'.
	aStack push: elem.
	res := aStack pop.	
	self assert: res = elem.
	self assert: res == elem.
	
	self assert: aStack size = 1.
	aStack pop.
	self assert: aStack isEmpty.


]

{ #category : #tests }
StackTest >> testPush [
	
	| aStack |
	aStack := Stack new.
	aStack push: 'a'.
	self assert: aStack size = 1.	
	aStack push: 'b'.
	self assert: aStack size = 2.
	
]

{ #category : #tests }
StackTest >> testSize [
	
	| aStack |
	aStack := Stack new.
	self assert: aStack size = 0.
	aStack push: 'a'.
	self assert: aStack size = 1.
	aStack push: 'b'.
	self assert: aStack size = 2.
	aStack pop.
	self assert: aStack size = 1.
	aStack pop.
	self assert: aStack size = 0.

 
	



]

{ #category : #tests }
StackTest >> testTop [

	| aStack |
	aStack := Stack new.
	self assert: aStack isEmpty.
	aStack push: 'a'.
	aStack push: 'b'.
	self assert: aStack top = 'b'.
	self assert: aStack top = 'b'.
	self assert: aStack size = 2.
]
