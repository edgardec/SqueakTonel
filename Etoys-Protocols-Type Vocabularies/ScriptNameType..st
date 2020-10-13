"
ScriptNameType is a data type representing selectors of user-written scripts.  The choices offered as values for data of this type are all the symbols that are implemented as names of user-written scripts in the current project.
"
Class {
	#name : #ScriptNameType,
	#superclass : #SymbolListType,
	#category : #'Etoys-Protocols-Type Vocabularies'
}

{ #category : #queries }
ScriptNameType >> choices [
	"Answer an alphabetized list of known script selectors in the current project"

	^ Project current world presenter allKnownUnaryScriptSelectors

]

{ #category : #tiles }
ScriptNameType >> defaultArgumentTile [
	"Answer a tile to represent the type"

	| aTile  |
	aTile := ScriptNameTile new dataType: self vocabularyName.
	aTile addArrows.
	'empty script' translatedNoop.
	aTile setLiteral: #emptyScript.
	^ aTile
]

{ #category : #initialization }
ScriptNameType >> initialize [
	"Initialize the ScriptNameType vocabulary"

	super initialize.
	self vocabularyName: #ScriptName
]

{ #category : #tile }
ScriptNameType >> newReadoutTile [
	"Answer a tile that can serve as a readout for data of this type"

	^ ScriptNameTile new dataType: self vocabularyName

]

{ #category : #queries }
ScriptNameType >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^true
]
