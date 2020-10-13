Class {
	#name : #HtmlDefinitionList,
	#superclass : #HtmlBlockEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlDefinitionList >> addToFormatter: formatter [
	super addToFormatter: formatter.
	formatter ensureNewlines: 1.
]

{ #category : #testing }
HtmlDefinitionList >> mayContain: anEntity [
	^anEntity isDefinitionListElement
]

{ #category : #testing }
HtmlDefinitionList >> tagName [
	^'dl'
]
