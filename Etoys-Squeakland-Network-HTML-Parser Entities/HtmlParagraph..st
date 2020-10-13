Class {
	#name : #HtmlParagraph,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlParagraph >> addToFormatter: formatter [
	formatter ensureNewlines: 2.
	super addToFormatter: formatter.
]

{ #category : #testing }
HtmlParagraph >> isBlockEntity [
	^true
]

{ #category : #testing }
HtmlParagraph >> isParagraph [
	^true
]

{ #category : #testing }
HtmlParagraph >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlParagraph >> tagName [
	^'p'
]
