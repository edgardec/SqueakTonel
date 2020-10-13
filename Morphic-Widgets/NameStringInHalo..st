"
Shows the name of the morph in the halo. 
"
Class {
	#name : #NameStringInHalo,
	#superclass : #UpdatingStringMorph,
	#category : #'Morphic-Widgets'
}

{ #category : #editing }
NameStringInHalo >> cancelEdits [
	self interimContents: target externalName.
	super cancelEdits
]

{ #category : #drawing }
NameStringInHalo >> drawOn: aCanvas [
	aCanvas fillRectangle: self bounds color: Color white.
	super drawOn: aCanvas.
]

{ #category : #accessing }
NameStringInHalo >> interimContents: aString [
	self contents: aString.
	self placeContents
]

{ #category : #private }
NameStringInHalo >> placeContents [
	| namePosition |
	(owner notNil and: [owner isInWorld]) ifTrue:
		[namePosition := owner basicBox bottomCenter -
			((self width // 2) @ (owner handleSize negated // 2 - 1)).
		namePosition := namePosition min: self world viewBox bottomRight - self extent y + 2.
		self bounds: (namePosition extent: self extent)]
]
