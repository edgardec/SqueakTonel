"
This class is the root of the Requestor hierarchy.

Requestors are interfaces between services and the system. ServiceActions are given an instance
of a Requestor, and they ask it for the data they need. The requestor is determined by the model of the application. A class used as a model can implement the #requestor message to return the most suited requestor. A requestor knows how to query its model and the user if needed.

Requestor are defined in hierarchies so that the protocol they rely on (methods starting with 'get') can be easily reused.
"
Class {
	#name : #BasicRequestor,
	#superclass : #Object,
	#instVars : [
		'caption',
		'answer'
	],
	#category : #'Services-Base'
}

{ #category : #'generic requests' }
BasicRequestor >> caption: aString [
	caption := aString
]

{ #category : #executing }
BasicRequestor >> get: aString [
	self caption: aString.
	^ self getSymbol
]

{ #category : #'generic requests' }
BasicRequestor >> getString [
	| result |
	result := UIManager default  request:caption  initialAnswer:answer contents.
	self newCaption.
	result isEmpty  |result isNil  ifTrue:[ServiceCancelled signal].
	^ result
]

{ #category : #'generic requests' }
BasicRequestor >> getStringCollection [
	caption := caption, Character cr asString, 'Separate items with space'.
	^ (self getString findTokens: ' ') collect: [:each | each copyWithoutAll: ' ' ]
]

{ #category : #'generic requests' }
BasicRequestor >> getSymbol [
	^ self getString asSymbol
]

{ #category : #'generic requests' }
BasicRequestor >> getSymbolCollection [
	^[self getStringCollection collect: [:each | each asSymbol]] 
		on: ServiceCancelled
		do: [#()]
]

{ #category : #'initialize-release' }
BasicRequestor >> initialize [
	self newCaption
]

{ #category : #'generic requests' }
BasicRequestor >> newCaption [
	caption := 'Enter text'.
	answer := String new writeStream.
]
