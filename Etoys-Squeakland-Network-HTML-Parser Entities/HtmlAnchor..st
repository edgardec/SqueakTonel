Class {
	#name : #HtmlAnchor,
	#superclass : #HtmlSpecialEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlAnchor >> addToFormatter: formatter [
	| href name |

	name := self getAttribute: 'name'.
	name ifNotNil: [
		formatter noteAnchorStart: name ].

	href := self getAttribute: 'href'.

	href isNil
		ifTrue: [ super addToFormatter: formatter ]
		ifFalse: [ 	
			formatter startLink: href.
			super addToFormatter: formatter.
			formatter endLink: href. ].

]

{ #category : #testing }
HtmlAnchor >> mayContain: anEntity [ 
	(self attributes includesKey: 'href') ifFalse: [
		"if we have no href, then we can contain nothing"
		^false ].

	^ anEntity isTextualEntity
]

{ #category : #testing }
HtmlAnchor >> tagName [
	^'a'
]
