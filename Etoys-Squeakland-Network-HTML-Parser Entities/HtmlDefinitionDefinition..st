Class {
	#name : #HtmlDefinitionDefinition,
	#superclass : #HtmlDefinitionListElement,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlDefinitionDefinition >> addToFormatter: formatter [
	formatter ensureNewlines: 1.
	formatter increaseIndent.
	super addToFormatter: formatter.
	formatter decreaseIndent.
]

{ #category : #testing }
HtmlDefinitionDefinition >> mayContain: anEntity [
	^anEntity isBlockEntity or: [ anEntity isTextualEntity ] 
]

{ #category : #testing }
HtmlDefinitionDefinition >> tagName [
	^'dd'
]
