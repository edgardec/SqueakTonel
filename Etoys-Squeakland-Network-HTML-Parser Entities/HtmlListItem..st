Class {
	#name : #HtmlListItem,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlListItem >> addToFormatter: formatter [
	formatter startListItem.
	super addToFormatter: formatter.
	formatter endListItem.
]

{ #category : #testing }
HtmlListItem >> isListItem [
	^true
]

{ #category : #testing }
HtmlListItem >> mayContain: anEntity [
	^anEntity isBlockEntity or: [ anEntity isTextualEntity ]
]

{ #category : #testing }
HtmlListItem >> tagName [
	^'li'
]
