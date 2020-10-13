Class {
	#name : #KedamaBounceOnTile,
	#superclass : #TileMorph,
	#instVars : [
		'playerTile'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #'initialization support' }
KedamaBounceOnTile >> addPlayerTile [

	| m1 desiredW m2 label |
	self removeAllMorphs.
	m1 := TilePadMorph new.
	label := 	StringMorph contents: 'bounce on' translated font: ScriptingSystem fontForTiles.

	m2 := TileMorph new.
	m2 extent: 20@22.
	m2 minWidth: 20.
	m1 extent: (m2 extent + (2@2)).
	m1 setType: #Player.
	m1 addMorph: m2.
	desiredW := m1 width + 6.
	self extent: (desiredW max: self basicWidth) @ self class defaultH.
	m1 position: (bounds center x - (m1 width // 2)) @ (bounds top + 1).
	self addMorphBack: m1.
	self addMorphFront: label.
	playerTile := m1.

]

{ #category : #initialization }
KedamaBounceOnTile >> initialize [

	super initialize.
	type := #Player.
	operatorOrExpression := #bounceOn:.
	self addPlayerTile.

]

{ #category : #'tile protocol' }
KedamaBounceOnTile >> line1: line1 [

	| label |
	self removeAllMorphs.

	label := 	StringMorph contents: 'bounce on' translated font: ScriptingSystem fontForTiles.

	self addMorphBack: label.
	self addMorphBack: playerTile.

]

{ #category : #'tile protocol' }
KedamaBounceOnTile >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

	| parts |
	parts := operatorOrExpression keywords.	"bounceOn:"
	aStream nextPutAll: parts first.
	aStream space.
	playerTile storeCodeOn: aStream indent: tabCount.

]

{ #category : #'tile protocol' }
KedamaBounceOnTile >> updateLiteralLabel [

]
