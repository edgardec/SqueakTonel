Class {
	#name : #HtmlBlockQuote,
	#superclass : #HtmlBlockEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlBlockQuote >> addToFormatter: formatter [
	formatter ensureNewlines: 2.
	formatter increaseIndent.
	super addToFormatter: formatter.
	formatter decreaseIndent.
	formatter ensureNewlines: 2.
]

{ #category : #testing }
HtmlBlockQuote >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlBlockQuote >> tagName [
	^'blockquote'
]
