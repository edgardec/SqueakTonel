Class {
	#name : #TileCommandWithArgumentMorph,
	#superclass : #TileMorph,
	#instVars : [
		'playerTile',
		'stringName'
	],
	#category : #'Etoys-Squeakland-EToys-Kedama'
}

{ #category : #'as yet unclassified' }
TileCommandWithArgumentMorph class >> newKedamaAngleToTile [

	^ (self new)
		operatorOrExpression: #getAngleTo:; 
		stringName: 'angleTo';
		type: #Player
		yourself.


]

{ #category : #'as yet unclassified' }
TileCommandWithArgumentMorph class >> newKedamaBounceOnTile [

	^ (self new)
		operatorOrExpression: #bounceOn:; 
		stringName: 'bounceOn';
		type: #Player
		yourself.


]

{ #category : #'as yet unclassified' }
TileCommandWithArgumentMorph class >> newKedamaDistanceToTile [

	^ (self new)
		operatorOrExpression: #getDistanceTo:; 
		stringName: 'distanceTo';
		type: #Player
		yourself.


]

{ #category : #'as yet unclassified' }
TileCommandWithArgumentMorph class >> newKedamaGetPatchValueTile [

	^ (self new)
		operatorOrExpression: #getPatchValueIn:; 
		stringName: 'patchValueIn';
		type: #Patch;
		yourself.


]

{ #category : #'as yet unclassified' }
TileCommandWithArgumentMorph class >> newKedamaGetTurtleOfTile [

	^ (self new)
		operatorOrExpression: #getTurtleOf:; 
		stringName: 'turtleOf';
		type: #Player
		yourself.

]

{ #category : #'as yet unclassified' }
TileCommandWithArgumentMorph class >> newKedamaGetUpHillTile [

	^ (self new)
		operatorOrExpression: #getUphillIn:; 
		stringName: 'upHillIn';
		type: #Patch
		yourself.

]

{ #category : #all }
TileCommandWithArgumentMorph >> addTile [

	| m1 desiredW m2 label |
	self removeAllMorphs.
	m1 := TilePadMorph new.
	label := 	StringMorph contents: stringName translated font: ScriptingSystem fontForTiles.

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
	playerTile := m1.

]

{ #category : #all }
TileCommandWithArgumentMorph >> initialize [

	super initialize.
	type := #Player.
	operatorOrExpression := #getDistanceTo:.
	stringName := 'distance to'.
	self addTile.

]

{ #category : #all }
TileCommandWithArgumentMorph >> line1: line1 [

	| label |
	self removeAllMorphs.

	label := 	StringMorph contents: stringName translated font: ScriptingSystem fontForTiles.

	self addMorphBack: label.
	self addMorphBack: playerTile.

]

{ #category : #all }
TileCommandWithArgumentMorph >> operatorOrExpression: aSymbol [

	operatorOrExpression := aSymbol.

]

{ #category : #all }
TileCommandWithArgumentMorph >> parseNodeWith: encoder [
	"We have a hidden arg. Output two keywords with interspersed arguments."
	^ playerTile parseNodeWith: encoder
]

{ #category : #all }
TileCommandWithArgumentMorph >> setArgumentDefaultTo: aPlayer [

	playerTile submorphs first setToReferTo: aPlayer.
	(aPlayer costume renderedMorph isMemberOf: KedamaPatchMorph)
		ifTrue: [playerTile setType: #Patch]
]

{ #category : #all }
TileCommandWithArgumentMorph >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

	| parts |
	parts := operatorOrExpression keywords.
	aStream nextPutAll: parts first.
	aStream space.
	playerTile storeCodeOn: aStream indent: tabCount.

]

{ #category : #all }
TileCommandWithArgumentMorph >> stringName: aString [

	stringName := aString.

]

{ #category : #all }
TileCommandWithArgumentMorph >> type: aSymbol [

	type := aSymbol.

]
