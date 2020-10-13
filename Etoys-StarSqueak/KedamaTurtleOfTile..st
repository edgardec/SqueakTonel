Class {
	#name : #KedamaTurtleOfTile,
	#superclass : #TileMorph,
	#instVars : [
		'turtleTile'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #'initalization support' }
KedamaTurtleOfTile >> addTile [

	| m1 desiredW m2 label |
	self removeAllMorphs.
	m1 := TilePadMorph new.
	label := 	StringMorph contents: 'turtle of' font: ScriptingSystem fontForTiles.

	m2 := TileMorph new.
	m2 extent: 20@22.
	m2 minWidth: 20.
	m1 extent: (m2 extent + (2@2)).
	m1 setType: #Player.
	m1 addMorph: m2.
	desiredW := m1 width.
	self extent: (desiredW max: self basicWidth) @ self class defaultH.
	m1 position: (bounds center x - (m1 width // 2)) @ (bounds top + 1).
	self addMorphBack: m1.
	self addMorphFront: label.
	turtleTile := m1.

]

{ #category : #initialization }
KedamaTurtleOfTile >> initialize [

	super initialize.
	type := #Player.
	operatorOrExpression := #getTurtleOf:.
	self addTile.

]

{ #category : #'tile protocol' }
KedamaTurtleOfTile >> line1: line1 [

	| label |
	self removeAllMorphs.

	label := 	StringMorph contents: 'turtleOf' font: ScriptingSystem fontForTiles.

	self addMorphBack: label.
	self addMorphBack: turtleTile.

]

{ #category : #'initalization support' }
KedamaTurtleOfTile >> setTurtleDefaultTo: aPlayer [

	turtleTile submorphs first setToReferTo: aPlayer.

]

{ #category : #'tile protocol' }
KedamaTurtleOfTile >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

	| parts |
	parts := operatorOrExpression keywords.	"getTurtleOf:"
	aStream nextPutAll: parts first.
	aStream space.
	turtleTile storeCodeOn: aStream indent: tabCount.

]
