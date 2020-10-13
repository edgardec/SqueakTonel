Class {
	#name : #HtmlTitle,
	#superclass : #HtmlHeadEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlTitle >> isHeadElement [
	^true
]

{ #category : #testing }
HtmlTitle >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlTitle >> tagName [
	^'title'
]
