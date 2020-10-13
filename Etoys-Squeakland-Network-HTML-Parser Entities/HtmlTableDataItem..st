Class {
	#name : #HtmlTableDataItem,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlTableDataItem >> addToFormatter: formatter [
	super addToFormatter: formatter.
	formatter ensureSpaces: 1.
]

{ #category : #testing }
HtmlTableDataItem >> isTableDataItem [
	^true
]

{ #category : #testing }
HtmlTableDataItem >> mayContain: anEntity [
	^anEntity isTextualEntity or: [ anEntity isBlockEntity or: [ anEntity isHeader ] ]
]

{ #category : #testing }
HtmlTableDataItem >> tagName [
	^'td'
]
