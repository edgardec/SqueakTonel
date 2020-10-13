"
abstract superclass for entities that may appear in the HEAD section
"
Class {
	#name : #HtmlHeadEntity,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlHeadEntity >> addToFormatter: formatter [
	"head elements are normally just meta-information, and thus don't add anything to the formatter"
]

{ #category : #testing }
HtmlHeadEntity >> isHeadElement [
	^true
]
