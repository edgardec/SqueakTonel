Class {
	#name : #HtmlTable,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlTable >> addToFormatter: formatter [
	formatter ensureNewlines: 1.
	super addToFormatter: formatter.
	formatter ensureNewlines: 1.
]

{ #category : #testing }
HtmlTable >> mayContain: anEntity [
	^anEntity isTableRow
]

{ #category : #testing }
HtmlTable >> tagName [
	^'table'
]
