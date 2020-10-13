Class {
	#name : #ColorSeerTile,
	#superclass : #ColorTileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #initialization }
ColorSeerTile >> initialize [
"initialize the state of the receiver"
	| m1 m2 desiredW wording |
	super initialize.
""
	self removeAllMorphs.
	"get rid of the parts of a regular Color tile"
	type := #operator.
	operatorOrExpression := #color:sees:.
	wording := (Vocabulary eToyVocabulary
				methodInterfaceAt: operatorOrExpression
				ifAbsent: []) wording.
	m1 := StringMorph contents: wording font: ScriptingSystem fontForTiles.
	m2 := Morph new extent: 16 @ 14;
				
				color: (Color
						r: 0.8
						g: 0
						b: 0).
	desiredW := m1 width + 6.
	self extent: (desiredW max: self basicWidth)
			@ self class defaultH.
	m1 position: bounds center x - (m1 width // 2) @ (bounds top + 5).
	m2 position: bounds center x - (m2 width // 2) + 3 @ (bounds top + 8).
	self addMorph: m1;
		 addMorphFront: m2.
	colorSwatch := m2
]

{ #category : #'code generation' }
ColorSeerTile >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

	| parts |
	parts := operatorOrExpression keywords.	"color:sees:"
	^aStream
		nextPutAll: (parts first);
		space;
		nextPutAll: colorSwatch color printString;
		space;
		nextPutAll: (parts second)
]

{ #category : #initialization }
ColorSeerTile >> updateWordingToMatchVocabulary [
	"The current vocabulary has changed; change the wording on my face, if appropriate"

	| aMethodInterface |
	aMethodInterface := self currentVocabulary methodInterfaceAt: operatorOrExpression ifAbsent: [Vocabulary eToyVocabulary methodInterfaceAt: operatorOrExpression ifAbsent: [^ self]].
	self labelMorph contents: aMethodInterface wording.
	self setBalloonText: aMethodInterface helpMessage.
]
