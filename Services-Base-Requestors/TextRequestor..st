"
A requestor for text areas, able for example to fetch the current selected text.
"
Class {
	#name : #TextRequestor,
	#superclass : #Requestor,
	#instVars : [
		'model'
	],
	#category : #'Services-Base-Requestors'
}

{ #category : #request }
TextRequestor >> getCurrentText [
	"returns the unnacepted text in the text morph" 
	^ self getModel codeTextMorph text
]

{ #category : #request }
TextRequestor >> getModel [
	^ model first
]

{ #category : #accessing }
TextRequestor >> model: aModel [
	model := WeakArray with: aModel
]
