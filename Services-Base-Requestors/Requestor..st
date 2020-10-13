"
I am an implementation of BasicRequestor with some requests already implemented.
"
Class {
	#name : #Requestor,
	#superclass : #BasicRequestor,
	#category : #'Services-Base-Requestors'
}

{ #category : #'as yet unclassified' }
Requestor class >> default [
	"returns a default requestor"
	^ self new
]

{ #category : #requests }
Requestor >> getClass [
	^Smalltalk at: self getSymbol
]

{ #category : #requests }
Requestor >> getClassCollection [
	^ self getSymbolCollection collect: [:className | Smalltalk at: className]
]

{ #category : #requests }
Requestor >> getMethodBody [
	| m world |
	m := FillInTheBlankMorph new.
	m setQuery: 'Please enter the full body of the method you want to define' 
		initialAnswer:  self class sourceCodeTemplate
		answerExtent: 500@250
		acceptOnCR: false. 
	world := Project current world.
	world addMorph: m centeredNear: world activeHand position.
	^ m getUserResponse.
]

{ #category : #requests }
Requestor >> getSelection [
	"Sorry to feedle with fillInTheBlankMorph innards, but I had to"
	| text m world |
	text := (MethodReference class: self getClass selector: self getSelector) sourceCode.
	m := FillInTheBlankMorph new.
	m setQuery: 'Highlight a part of the source code, and accept' initialAnswer: text
		answerExtent: 500@250
		acceptOnCR: true. 
	world := Project current world.
	world addMorph: m centeredNear: world activeHand position.
	m getUserResponse.
	^ m selection
]

{ #category : #'services requests' }
Requestor >> getSelector [
	^ self caption: 'enter selector'; getSymbol
]
