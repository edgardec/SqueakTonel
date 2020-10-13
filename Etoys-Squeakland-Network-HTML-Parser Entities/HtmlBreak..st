Class {
	#name : #HtmlBreak,
	#superclass : #HtmlSpecialEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlBreak >> addToFormatter: formatter [
	formatter addChar: Character cr.
]

{ #category : #testing }
HtmlBreak >> mayContain: anEntity [
	^false
]

{ #category : #testing }
HtmlBreak >> tagName [
	^'br'
]
