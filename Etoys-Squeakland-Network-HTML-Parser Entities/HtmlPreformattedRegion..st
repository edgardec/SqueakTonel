Class {
	#name : #HtmlPreformattedRegion,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlPreformattedRegion >> addToFormatter: formatter [
	formatter ensureNewlines: 1.
	formatter increasePreformatted.
	super addToFormatter: formatter.
	formatter decreasePreformatted.
	formatter ensureNewlines: 1.
]

{ #category : #testing }
HtmlPreformattedRegion >> mayContain: anEntity [
	^true
]

{ #category : #lint }
HtmlPreformattedRegion >> shouldContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlPreformattedRegion >> tagName [
	^'pre'
]
