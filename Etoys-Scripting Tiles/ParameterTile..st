"
Represents a parameter in a user-defined script in ""classic"" tile-scripting.  The type of a script's parameter is declared in the ScriptEditor for the script, and a parameter tile gets its type from the script.  But because the user can change the parameter type *after* having created parameter tiles, we can later have type mismatches.  Which however we at least deal with reasonably cleverly.
"
Class {
	#name : #ParameterTile,
	#superclass : #TileMorph,
	#instVars : [
		'scriptEditor'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #miscellaneous }
ParameterTile >> associatedPlayer [
	"Answer the player with which the receiver is associated"

	^ self scriptEditor playerScripted
]

{ #category : #type }
ParameterTile >> assureTypeStillValid [
	"Consider the possibility that the parameter type of my surrounding method has changed and that hence I no longer represent a possible value for the parameter of the script.  If this condition obtains, then banish me in favor of a default literal tile of the correct type"

	(self ownerThatIsA: TilePadMorph) ifNotNil:
		[:aPad | aPad type = self scriptEditor typeForParameter ifFalse:
			[aPad setToBearDefaultLiteral]]
]

{ #category : #miscellaneous }
ParameterTile >> booleanComparatorPhrase [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase rel retrieverType |
	retrieverType := self resultType.

	rel := (Vocabulary vocabularyForType: retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	outerPhrase firstSubmorph addMorph: self.
	outerPhrase submorphs last addMorph: (ScriptingSystem tileForArgType: retrieverType).

	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #initialization }
ParameterTile >> forScriptEditor: aScriptEditor [
	"Make the receiver be associated with the given script editor"

	scriptEditor := aScriptEditor.
	self line1: aScriptEditor typeForParameter translated.
]

{ #category : #initialization }
ParameterTile >> initialize [
	"Initialize the receiver"

	super initialize.
	type := #parameter.

	self typeColor: Color red
]

{ #category : #access }
ParameterTile >> isBooleanType [ 
	"Answer whether the receiver's type is inherently boolean"

	^ self scriptEditor typeForParameter == #Boolean
]

{ #category : #accessing }
ParameterTile >> resultType [
	"Answer the result type of the receiver"

	^ self scriptEditor typeForParameter
]

{ #category : #access }
ParameterTile >> rowOfRightTypeFor: aLayoutMorph forActor: aPlayer [
	"Answer a phrase of the right type for the putative container"

	| aTemporaryViewer aPhrase |
	aLayoutMorph demandsBoolean ifTrue:
		[aTemporaryViewer := CategoryViewer new invisiblySetPlayer: aPlayer.
		aPhrase := aTemporaryViewer booleanPhraseFromPhrase: self.
		aPhrase justGrabbedFromViewer: false.
		^ aPhrase].
	^ self
]

{ #category : #access }
ParameterTile >> scriptEditor [
	"Answer the receiver's script editor.  The slightly strange code here is in order to contend with the unusual situation where a parameter tile obtained from one script editor is later dropped into a different script editor.  As long as the parameter tile is *in* a script editor, that containing scriptEditor is the one; if it is *not*, then we use the last known one"

	| aScriptEditor |
	^ (aScriptEditor := self outermostMorphThat: [:m | m isKindOf: ScriptEditorMorph])
		ifNotNil:
			[scriptEditor := aScriptEditor]
		ifNil:
			[scriptEditor]
]

{ #category : #'code generation' }
ParameterTile >> storeCodeOn: aStream indent: tabCount [
	"Store code on the stream"
 
	| myTypeString |
	myTypeString := self resultType.
	(self scriptEditor hasParameter and: [self scriptEditor typeForParameter = myTypeString])
		ifTrue:
			[aStream nextPutAll: 'parameter']
		ifFalse:
			["This script no longer bears a parameter, yet there's an orphaned Parameter tile in it"
			aStream nextPutAll: '(self defaultValueOfType: #', myTypeString, ')']
]

{ #category : #miscellaneous }
ParameterTile >> tileRows [
	"Answer a list of tile rows -- in this case exactly one row -- representing the receiver."

	^ Array with: (Array with: self)
]
