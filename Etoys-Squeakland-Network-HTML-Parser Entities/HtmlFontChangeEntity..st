"
an entity whose effect is to change the font its constituents are displayed in in some way.  Multiple tags might generate almost any of the subclasses, so the tag name is stored explicitly.
"
Class {
	#name : #HtmlFontChangeEntity,
	#superclass : #HtmlTextualEntity,
	#instVars : [
		'tagName'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #'private-initialization' }
HtmlFontChangeEntity >> initialize: aTag [
	super initialize: aTag.
	tagName := aTag name
]

{ #category : #testing }
HtmlFontChangeEntity >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlFontChangeEntity >> tagName [
	"must be stored in an i-var, because these classes work for different tags"
	^tagName
]
