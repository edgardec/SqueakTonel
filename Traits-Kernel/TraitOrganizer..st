"
A class organizer containing state for traits.
"
Class {
	#name : #TraitOrganizer,
	#superclass : #ClassOrganizer,
	#instVars : [
		'traitComposition'
	],
	#category : #'Traits-Kernel'
}

{ #category : #testing }
TraitOrganizer >> isTraitOrganizer [
	"Answer true if this is a TraitOrganizer"
	^true
]

{ #category : #accessing }
TraitOrganizer >> traitComposition [
	"Answer the receiver's trait composition"
	^traitComposition ifNil:[traitComposition := TraitComposition new]
]

{ #category : #accessing }
TraitOrganizer >> traitComposition: aTraitComposition [
	"Install the receiver's trait composition"
	traitComposition := aTraitComposition.
]
