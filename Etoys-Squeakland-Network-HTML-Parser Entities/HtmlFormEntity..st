"
Abstract superclass for elements that only appear in forms
"
Class {
	#name : #HtmlFormEntity,
	#superclass : #HtmlEntity,
	#instVars : [
		'form'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #access }
HtmlFormEntity >> form [
	"return which form we are in"
	^form
]

{ #category : #access }
HtmlFormEntity >> form: aForm [
	"set which form we are part of"
	form := aForm
]

{ #category : #testing }
HtmlFormEntity >> isFormEntity [
	^true
]

{ #category : #testing }
HtmlFormEntity >> lint: aStream [
	form ifNil: [ aStream nextPutAll: '<', self tagName, '> not within a form'.
		aStream cr. ].
	super lint: aStream.
]
