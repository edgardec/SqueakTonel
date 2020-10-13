"
includes raw text, font-changing entities like <b> and <em>, and special entities like <a> and <img>.  All of these are relatively low level regarding formatting; they are superceded by higher level things like <li> and <p>.  When formatted, they flow around like characters.
"
Class {
	#name : #HtmlTextualEntity,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlTextualEntity >> isTextualEntity [
	^true
]
