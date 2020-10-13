"
a comment from the page
"
Class {
	#name : #HtmlCommentEntity,
	#superclass : #HtmlTextualEntity,
	#instVars : [
		'commentText'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlCommentEntity >> addToFormatter: formatter [
	"do nothing"
]

{ #category : #access }
HtmlCommentEntity >> commentText [
	^commentText
]

{ #category : #'private-iniitialization' }
HtmlCommentEntity >> initializeWithText: aString [
	super initialize.
	commentText := aString.
]

{ #category : #testing }
HtmlCommentEntity >> isComment [
	^true
]

{ #category : #testing }
HtmlCommentEntity >> mayContain: anEntity [
	^false
]

{ #category : #printing }
HtmlCommentEntity >> printHtmlOn: aStream indent: indent [ 
	indent timesRepeat: [aStream space].
	aStream nextPutAll: '<!-- '.
	aStream nextPutAll: self commentText.
	aStream nextPutAll: ' -->'.
	aStream cr
]

{ #category : #printing }
HtmlCommentEntity >> printOn: aStream indent: indent [ 
	self printHtmlOn: aStream indent: indent
]

{ #category : #testing }
HtmlCommentEntity >> tagName [	
	"return a bogus tag name"
	^'x-comment'
]
