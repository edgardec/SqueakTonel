Class {
	#name : #HtmlDefinitionTerm,
	#superclass : #HtmlDefinitionListElement,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlDefinitionTerm >> addToFormatter: formatter [
	formatter ensureNewlines: 1.
	super addToFormatter: formatter.
]

{ #category : #testing }
HtmlDefinitionTerm >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlDefinitionTerm >> tagName [
	^'dt'
]
