Class {
	#name : #HtmlNoEmbed,
	#superclass : #HtmlSpecialEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlNoEmbed >> addToFormatter: aFormatter [
	"Check if the last incomplete morph has the property #embedded set.
	If so, assume that the last <EMBED> tag has been handled."
	| morphs |
	morphs := aFormatter incompleteMorphs.
	(morphs isEmpty not and:[(morphs last valueOfProperty: #embedded) == true])
		ifTrue:[^self].
	"If not handled do the usual stuff"
	^super addToFormatter: aFormatter
]

{ #category : #testing }
HtmlNoEmbed >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlNoEmbed >> tagName [
	^'noembed'
]
