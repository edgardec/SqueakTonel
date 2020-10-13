Class {
	#name : #HtmlButton,
	#superclass : #HtmlFormEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlButton >> mayContain: anEntity [
	^false
]

{ #category : #testing }
HtmlButton >> tagName [
	^'button'
]
