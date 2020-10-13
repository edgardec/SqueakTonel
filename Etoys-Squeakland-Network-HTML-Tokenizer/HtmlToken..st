Class {
	#name : #HtmlToken,
	#superclass : #Object,
	#instVars : [
		'source'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Tokenizer'
}

{ #category : #'instance creation' }
HtmlToken class >> forSource: source [  
	^super new initialize: source

]

{ #category : #formatting }
HtmlToken >> addToFormatter: aFormatter [
	"add ourself to a formatter"
]

{ #category : #'parser support' }
HtmlToken >> entityFor [
	^self subclassResponsibility
]

{ #category : #'private-initialization' }
HtmlToken >> initialize: s [
	"default initialization doesn't do much.  subclasses are free to override"
	source := s

]

{ #category : #properties }
HtmlToken >> isComment [
	"whether this token is an HTML comment"
	^false

]

{ #category : #properties }
HtmlToken >> isTag [
	"is this an HTML tag"
	^false
]

{ #category : #properties }
HtmlToken >> isText [
	"return whether it is a string of text"
	^false

]

{ #category : #printing }
HtmlToken >> printOn: aStream [
	aStream nextPutAll: '{';
		nextPutAll: self class name;
		nextPut: $:;
		nextPutAll: self source;
		nextPut: $}.
]

{ #category : #access }
HtmlToken >> source [
	"the raw source text that composes this token"
	^source
]
