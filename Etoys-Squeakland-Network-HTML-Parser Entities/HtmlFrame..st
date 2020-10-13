Class {
	#name : #HtmlFrame,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlFrame >> addToFormatter: formatter [
	| src |
	src := self getAttribute: 'src' default: nil.
	formatter ensureNewlines: 1.
	src ifNotNil: [ formatter startLink: src ].
	formatter addString: 'frame '.
	formatter addString: (self name ifNil: ['(unnamed)']).
	src ifNotNil:  [ formatter endLink: src ].
	formatter ensureNewlines: 1.
]

{ #category : #categorization }
HtmlFrame >> isFrame [
	^true
]

{ #category : #testing }
HtmlFrame >> mayContain: anEntity [
	^false
]

{ #category : #testing }
HtmlFrame >> tagName [
	^'frame'
]
