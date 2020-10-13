Class {
	#name : #HtmlOrderedList,
	#superclass : #HtmlList,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlOrderedList >> addToFormatter: formatter [
	formatter startOrderedList.
	super addToFormatter: formatter.
	formatter endOrderedList.
]

{ #category : #testing }
HtmlOrderedList >> tagName [
	^'ol'
]
