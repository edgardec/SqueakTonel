"
an entity which displays its contents in italics
"
Class {
	#name : #HtmlItalicsEntity,
	#superclass : #HtmlFontChangeEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlItalicsEntity >> addToFormatter: formatter [
	formatter increaseItalics.
	super addToFormatter: formatter.	
	formatter decreaseItalics.
]
