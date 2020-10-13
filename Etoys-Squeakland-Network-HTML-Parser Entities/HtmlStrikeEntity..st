"
the contents should be displayed struck-through
"
Class {
	#name : #HtmlStrikeEntity,
	#superclass : #HtmlFontChangeEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlStrikeEntity >> addToFormatter: formatter [
	formatter increaseStrike.
	super addToFormatter: formatter.
	formatter decreaseStrike.
]
