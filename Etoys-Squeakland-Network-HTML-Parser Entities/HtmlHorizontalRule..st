Class {
	#name : #HtmlHorizontalRule,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlHorizontalRule >> addToFormatter: formatter [
	formatter hr
]

{ #category : #testing }
HtmlHorizontalRule >> mayContain: anEntity [
	^false
]

{ #category : #testing }
HtmlHorizontalRule >> tagName [
	^'hr'
]
