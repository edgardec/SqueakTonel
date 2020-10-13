"
A slight modification on TextMorph to show empty fields just as one would fields with data: with a cursor and without the pink field
"
Class {
	#name : #ShowEmptyTextMorph,
	#superclass : #TextMorph,
	#category : #'Etoys-Experimental'
}

{ #category : #drawing }
ShowEmptyTextMorph >> drawOn: aCanvas [
	self setDefaultContentsIfNil.
	aCanvas paragraph: self paragraph bounds: bounds color: color.

]
