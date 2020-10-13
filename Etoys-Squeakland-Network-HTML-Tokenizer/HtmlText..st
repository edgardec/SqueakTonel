"
A sequence of text without any tags in it.  &sp; style characters have been replaced by their actual values. 
"
Class {
	#name : #HtmlText,
	#superclass : #HtmlToken,
	#instVars : [
		'text'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Tokenizer'
}

{ #category : #formatter }
HtmlText >> addToFormatter: aFormatter [
	"add ourself to a formatter"
	aFormatter addText: source
]

{ #category : #'private-initialization' }
HtmlText >> initialize: source0 [
	super initialize: source0.
	self text: source0 replaceHtmlCharRefs.
]

{ #category : #properties }
HtmlText >> isText [
	^true
]

{ #category : #access }
HtmlText >> text [
	^text

]

{ #category : #'private-initialization' }
HtmlText >> text: text0 [
	text := text0.
]
