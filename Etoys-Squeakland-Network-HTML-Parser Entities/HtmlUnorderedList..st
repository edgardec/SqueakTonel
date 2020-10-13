Class {
	#name : #HtmlUnorderedList,
	#superclass : #HtmlList,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlUnorderedList >> addToFormatter: formatter [
	formatter startUnorderedList.
	super addToFormatter: formatter.
	formatter endUnorderedList.
]

{ #category : #testing }
HtmlUnorderedList >> tagName [
	^'ul'
]
