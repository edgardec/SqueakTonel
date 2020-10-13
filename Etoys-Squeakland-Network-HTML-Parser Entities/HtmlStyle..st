Class {
	#name : #HtmlStyle,
	#superclass : #HtmlHeadEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlStyle >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlStyle >> tagName [
	^'style'
]
