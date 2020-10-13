Class {
	#name : #HtmlOptionGroup,
	#superclass : #HtmlFormEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlOptionGroup >> mayContain: anEntity [
	^anEntity isOption
]

{ #category : #testing }
HtmlOptionGroup >> tagName [
	^'optgroup'
]
