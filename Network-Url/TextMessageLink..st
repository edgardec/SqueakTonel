"
A link to a hidden mail message.  Clicking on it allows the message to be viewed or saved to disk.
"
Class {
	#name : #TextMessageLink,
	#superclass : #TextAttribute,
	#instVars : [
		'message'
	],
	#category : #'Network-Url'
}

{ #category : #'instance creation' }
TextMessageLink class >> message: aMessage [
	^super new initialize: aMessage
]

{ #category : #acting }
TextMessageLink >> actOnClickFor: evt [ 
	| choice viewMsg |
	viewMsg := message containsViewableImage
		ifTrue: ['view this image attachment']
		ifFalse: ['view this attachment'].
	choice := UIManager default chooseFrom: (Array with: viewMsg 
													with: 'save this attachment' ).
	choice = 1
		ifTrue: ["open a new viewer"
			message viewBody].
	choice = 2
		ifTrue: ["save the mesasge"
			message save].
	^ true
]

{ #category : #appearance }
TextMessageLink >> emphasizeScanner: scanner [
	scanner textColor: Color brown
]

{ #category : #initialization }
TextMessageLink >> initialize: message0 [
	message := message0
]

{ #category : #acting }
TextMessageLink >> mayActOnClick [
	^true
]
