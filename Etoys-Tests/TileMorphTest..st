Class {
	#name : #TileMorphTest,
	#superclass : #TestCase,
	#instVars : [
		'soundSystemBackup'
	],
	#category : #'Etoys-Tests'
}

{ #category : #testing }
TileMorphTest >> expectedFailures [

	^ super expectedFailures, 
		(self class environment
			at: #BaseSoundSystem
			ifPresent: [:e| #()]
			ifAbsent: [#(testSoundTile) "Only this test depends on Sound"])
]

{ #category : #running }
TileMorphTest >> setUp [
	soundSystemBackup := SoundService default: (self class environment at: #BaseSoundSystem ifAbsent: [nil]).
]

{ #category : #running }
TileMorphTest >> tearDown [

	SoundService default: soundSystemBackup.
]

{ #category : #testing }
TileMorphTest >> testArrowAction [
	"self debug: #testArrowAction"
	| dummy tile |
	dummy := Morph new.
	tile := TileMorph new setOperator: '+'.
	dummy addMorph: tile.
	tile arrowAction: 1.
	self assert: tile codeString = '-'.

	tile := TileMorph new setOperator: '<'.
	dummy addMorph: tile.
	tile arrowAction: 1.
	"Because receiver is not tile"
	self assert: tile codeString = 'eToysEQ:'.

	tile := true newTileMorphRepresentative.
	dummy addMorph: tile.
	tile arrowAction: 1.
	self assert: tile codeString = '(false)'.

]

{ #category : #testing }
TileMorphTest >> testAssignmentTile [
	"self debug: #testAssignmentTile"

	| player viewer tile phrase |
	player := Morph new assuredPlayer.
	viewer := CategoryViewer new invisiblySetPlayer: player.
	viewer  makeSetter: #(#getX #Number) event: nil from: player costume.
	phrase := self currentHand firstSubmorph.
	self currentHand removeAllMorphs.
	tile := phrase submorphs second.

	self assert: tile codeString = 'setX: '.
	tile arrowAction: 1.
	self assert: tile codeString = 'setX: self getX + '.
]

{ #category : #testing }
TileMorphTest >> testNewTileMorphRepresentative [
	
	self assert: (nil newTileMorphRepresentative class =  UndescribedTile).
	self assert: (false newTileMorphRepresentative isKindOf: TileMorph).
	self assert: (false newTileMorphRepresentative literal = false).
	self assert: (true newTileMorphRepresentative literal = true).
]

{ #category : #testing }
TileMorphTest >> testSoundTile [
	"self debug: #testSoundTile"
	| tile dummy |
	dummy := Morph new.
	tile := SoundTile new literal: 'croak'.
	dummy addMorph: tile.
	tile arrowAction: 1.
	self assert: tile codeString = '(''horn'')'.

	
]
