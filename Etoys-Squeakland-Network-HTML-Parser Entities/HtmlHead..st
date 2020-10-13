Class {
	#name : #HtmlHead,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlHead >> mayContain: anEntity [
	^anEntity isHeadElement or: [ anEntity isComment ]
]

{ #category : #testing }
HtmlHead >> tagName [
	^'head'
]

{ #category : #metainformation }
HtmlHead >> title [
	"return the title, or nil if there isn't one"
	| te |
	te := self titleEntity.
	te ifNil: [ ^nil ].
	^te textualContents
]

{ #category : #metainformation }
HtmlHead >> titleEntity [
	"return the title entity, or nil if there isn't one"
	contents do: [ :e | e tagName = 'title' ifTrue: [ ^e ] ].
	^nil
]
