"
A tile which refers to a script name.  The choices available to the user, via the arrows and via the pop-up she gets when she clicks on the current script-name, are the names of all the user scripts in any Players in the active World.
"
Class {
	#name : #ScriptNameTile,
	#superclass : #SymbolListTile,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'user interface' }
ScriptNameTile >> adjustHelpMessage [
	"Adjust the help message to reflect the new literal"

	self labelMorph setBalloonText: 'The name of the script to which this operation applies' translated
]

{ #category : #initialization }
ScriptNameTile >> choices [
	"Answer the current list of choices"

	^ Project current world presenter allKnownUnaryScriptSelectors
]

{ #category : #initialization }
ScriptNameTile >> dataType: aDataType [
	"Initialize the receiver with the given data type"

	dataType := aDataType.
	literal := #emptyScript
]
