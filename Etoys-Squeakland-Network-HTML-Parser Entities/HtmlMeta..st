"
some result of a meta tag; unimplemented so far
"
Class {
	#name : #HtmlMeta,
	#superclass : #HtmlHeadEntity,
	#instVars : [
		'theTag'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlMeta >> addToFormatter: formatter [
	| httpEquiv |
	httpEquiv := self getAttribute: 'http-equiv'.
	httpEquiv ifNil: [ ^self ].
	httpEquiv asLowercase = 'refresh' ifTrue: [
		formatter addString: '{refresh: ', (self getAttribute:  'content' default: ''), '}' ].
]

{ #category : #initialization }
HtmlMeta >> initialize: aTag [
	super initialize: aTag.
	theTag := aTag.
]

{ #category : #testing }
HtmlMeta >> mayContain: anEntity [
	^false
]

{ #category : #printing }
HtmlMeta >> printOn: aStream indent: indent [
	indent timesRepeat: [ aStream space ].
	aStream nextPutAll: 'meta: '.
	theTag printOn: aStream.
	aStream cr.
]

{ #category : #testing }
HtmlMeta >> tagName [
	^'meta'
]
