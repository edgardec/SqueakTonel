"
an entity which displays its contents in boldface
"
Class {
	#name : #HtmlBoldEntity,
	#superclass : #HtmlFontChangeEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlBoldEntity >> addToFormatter: formatter [
	formatter increaseBold.
	super addToFormatter: formatter.
	formatter decreaseBold.
]
