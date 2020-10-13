"
Represents a color and possibly a style attribute to be applied to a syntactic element for pretty-printing.  The attributeList inst var is a cache.
"
Class {
	#name : #SyntaxAttribute,
	#superclass : #Object,
	#instVars : [
		'color',
		'emphasis',
		'attributeList'
	],
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #'as yet unclassified' }
SyntaxAttribute class >> color: aColor emphasis: anEmphasis [
	^ self new color: aColor; emphasis: anEmphasis; yourself
]

{ #category : #accessing }
SyntaxAttribute >> attributeList [
	"Answer a list of text attributes that characterize the receiver"
	attributeList ifNil:
		[attributeList := OrderedCollection new: 2.
		color ifNotNil: [attributeList add: (TextColor color: color)].
		emphasis ifNotNil: [attributeList add: (TextEmphasis perform: emphasis)]].
	^ attributeList
]

{ #category : #accessing }
SyntaxAttribute >> color [

	^ color
]

{ #category : #accessing }
SyntaxAttribute >> color: aTextColor [
	color := aTextColor.
	attributeList := nil
]

{ #category : #accessing }
SyntaxAttribute >> emphasis [

	^ emphasis
]

{ #category : #accessing }
SyntaxAttribute >> emphasis: aTextEmphasis [
	emphasis := aTextEmphasis.
	attributeList := nil
]
