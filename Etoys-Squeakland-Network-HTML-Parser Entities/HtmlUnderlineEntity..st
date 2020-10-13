Class {
	#name : #HtmlUnderlineEntity,
	#superclass : #HtmlFontChangeEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlUnderlineEntity >> addToFormatter: formatter [
	formatter increaseUnderline.
	super addToFormatter: formatter.	
	formatter decreaseUnderline.
]
