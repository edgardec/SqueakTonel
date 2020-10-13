"
An entire Smalltalk statement in tiles.  A line of code.
"
Class {
	#name : #CommandTilesMorph,
	#superclass : #TileLikeMorph,
	#instVars : [
		'morph',
		'playerScripted'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #initialization }
CommandTilesMorph >> initialize [

	super initialize.
	self wrapCentering: #center; cellPositioning: #leftCenter.
	self hResizing: #shrinkWrap.
	self borderWidth: 0.
	self layoutInset: 0.
	self extent: 5@5.  "will grow to fit"

]

{ #category : #initialization }
CommandTilesMorph >> setMorph: aMorph [
	playerScripted := aMorph playerScripted

]

{ #category : #miscellaneous }
CommandTilesMorph >> tileRows [

	^ Array with: self submorphs
]
