Class {
	#name : #FormStub,
	#superclass : #Form,
	#instVars : [
		'locator'
	],
	#category : #'Graphics-Display Objects'
}

{ #category : #accessing }
FormStub >> locator [
	^locator
]

{ #category : #accessing }
FormStub >> locator: aString [
	locator := aString
]

{ #category : #'fileIn\/Out' }
FormStub >> objectForDataStream: refStream [
	"Force me into outPointers so that I get notified about startup"
	refStream replace: self with: self.
	^self
]
