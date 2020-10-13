Class {
	#name : #HtmlTextEntity,
	#superclass : #HtmlTextualEntity,
	#instVars : [
		'text'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlTextEntity >> addToFormatter: aFormatter [
	aFormatter addString: text
]

{ #category : #testing }
HtmlTextEntity >> mayContain: anEntity [
	^false
]

{ #category : #printing }
HtmlTextEntity >> printHtmlOn: aStream indent: indent [ 
	indent timesRepeat: [aStream space].
	aStream nextPutAll: text.

]

{ #category : #printing }
HtmlTextEntity >> printOn: aStream indent: indent [
	indent timesRepeat: [ aStream space ].
	aStream nextPutAll: '['.
	aStream nextPutAll: text.
	aStream nextPutAll: ']'.
	aStream cr.
]

{ #category : #testing }
HtmlTextEntity >> tagName [
	"bogus"
	^'x-text'  
]

{ #category : #access }
HtmlTextEntity >> text [
	^text
]

{ #category : #access }
HtmlTextEntity >> text: text0 [
	text := text0
]

{ #category : #contents }
HtmlTextEntity >> textualContents [
	^text
]
