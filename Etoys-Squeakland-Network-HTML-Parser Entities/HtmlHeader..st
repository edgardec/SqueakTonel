Class {
	#name : #HtmlHeader,
	#superclass : #HtmlEntity,
	#instVars : [
		'level'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlHeader >> addToFormatter: formatter [
	formatter startHeader: level.
	super addToFormatter: formatter.
	formatter endHeader: level
]

{ #category : #'private-initialization' }
HtmlHeader >> initialize: aTag [
	super initialize: aTag.
	level := aTag name last digitValue.
]

{ #category : #testing }
HtmlHeader >> isHeader [
	^true
]

{ #category : #testing }
HtmlHeader >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlHeader >> tagName [
	^'h', level printString
]
