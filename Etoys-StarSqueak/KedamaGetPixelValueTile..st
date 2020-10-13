"
I provide the patchValueIn getter tile.

"
Class {
	#name : #KedamaGetPixelValueTile,
	#superclass : #TileMorph,
	#instVars : [
		'patchTile'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #'initialization support' }
KedamaGetPixelValueTile >> addPatchTile [

	| m1 desiredW m2 label |
	self removeAllMorphs.
	m1 := TilePadMorph new.
	label := 	StringMorph contents: 'getValueIn' translated font: ScriptingSystem fontForTiles.

	m2 := TileMorph new.
	m2 extent: 20@22.
	m2 minWidth: 20.
	m1 extent: (m2 extent + (2@2)).
	m1 setType: #Patch.
	m1 addMorph: m2.
	desiredW := m1 width.
	self extent: (desiredW max: self basicWidth) @ self class defaultH.
	m1 position: (bounds center x - (m1 width // 2)) @ (bounds top + 1).
	self addMorphBack: m1.
	self addMorphFront: label.
	patchTile := m1.

]

{ #category : #initialization }
KedamaGetPixelValueTile >> initialize [

	super initialize.
	type := #Patch.
	operatorOrExpression := #getPatchValueIn:.
	self addPatchTile.
	self line1: 'getPatchValueIn:'.

]

{ #category : #'initialization support' }
KedamaGetPixelValueTile >> line1: line1 [

	| label |
	self removeAllMorphs.

	label := 	StringMorph contents: 'patchValueIn' translated font: ScriptingSystem fontForTiles.

	self addMorphBack: label.
	self addMorphBack: patchTile.

]

{ #category : #'tile protocol' }
KedamaGetPixelValueTile >> setPatchDefaultTo: aPlayer [

	patchTile submorphs first setToReferTo: aPlayer.

]

{ #category : #'tile protocol' }
KedamaGetPixelValueTile >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

	| parts |
	parts := operatorOrExpression keywords.	"getPatchValueIn:"
	aStream nextPutAll: parts first.
	aStream space.
	patchTile storeCodeOn: aStream indent: tabCount.

]
