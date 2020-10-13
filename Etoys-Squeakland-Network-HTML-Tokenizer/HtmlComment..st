"
A comment, eg <!-- this is a comment -->
Normally this is ignored, but it's included so that every byte in the
input gets put into one tag or another.
"
Class {
	#name : #HtmlComment,
	#superclass : #HtmlToken,
	#category : #'Etoys-Squeakland-Network-HTML-Tokenizer'
}

{ #category : #'parser support' }
HtmlComment >> entityFor [
	^self shouldNotImplement
]

{ #category : #properties }
HtmlComment >> isComment [
	^true
]

{ #category : #access }
HtmlComment >> text [
	"return the text of the comment, the part inside the <!-- and -->"
	^self notYetImplemented
]
