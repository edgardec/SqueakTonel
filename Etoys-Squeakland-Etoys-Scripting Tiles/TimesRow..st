"
A custom alignment morph that holds the ""times' portion of a Times/Repeat complex
"
Class {
	#name : #TimesRow,
	#superclass : #AlignmentMorph,
	#instVars : [
		'timesPad'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #initialization }
TimesRow >> initialize [
	"object initialization"

	| repeatLabel |
	super initialize.
	self minCellSize: (2@16).
	self setNameTo: 'Times'.
	repeatLabel := StringMorph  contents: 'Repeat' translated font:  Preferences standardEToysFont.
	self addMorphBack: repeatLabel.
	self vResizing: #shrinkWrap.
	self addTransparentSpacerOfSize: (6@5).

	timesPad := TilePadMorph new setType: #Number.
	timesPad hResizing: #shrinkWrap; color: Color transparent.
	timesPad addMorphBack: (TileMorph new addArrows; setLiteral: 2; addSuffixArrow; yourself).
	timesPad borderWidth: 0; layoutInset: (1@0).

	self addMorphBack: timesPad.
	self addMorphBack: (StringMorph  contents: (' ', ('times' translated), ' ') font: Preferences standardEToysFont).
	self addMorphBack: AlignmentMorph newVariableTransparentSpacer
]

{ #category : #'retract-arrow processing' }
TimesRow >> replaceSubmorph: existingMorph by: newMorph [
	"Replace a submorph by a different morph. Fix up my  inst vars as appropriate."

	super replaceSubmorph: existingMorph by: newMorph.
	(newMorph isKindOf: TilePadMorph)
		ifTrue:
			[timesPad := newMorph]

]

{ #category : #accessing }
TimesRow >> timesPad [
	"Answer the TilePadMorph at the top of the tile
	tree for the times part. Guard against repeating
	less than 0 times"
	| number |
	timesPad submorphs isEmpty ifTrue: [
		timesPad addMorphBack: (TileMorph new addArrows; setLiteral: 0; addSuffixArrow; yourself)
	].
	((number := timesPad submorphs first) isKindOf: TileMorph)
		ifTrue: [number literal < 0
				ifTrue: [number literal: 0]].
	^ timesPad
]
