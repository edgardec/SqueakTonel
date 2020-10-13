"
Represents a tile script of uniclass.  Holds the ScriptEditorMorph structures for the current version of a user-defined tile script, as well as previous versions thereof.

In addition to the instance variables of my superclass, my instance variables are:

currentScriptEditor		The current version of the ScriptEditorMorph for the script
formerScriptingTiles		A collection of pairs, (<timeStamp>  (list of morphs)) 
							each pair characterizing a prior tile version
isTextuallyCoded			A boolean.  If true, then a hand-crafted user coding supersedes
							the tale of the tiles.  This architecture is in transition, perhaps.
"
Class {
	#name : #UniclassScript,
	#superclass : #MethodWithInterface,
	#instVars : [
		'currentScriptEditor',
		'formerScriptingTiles',
		'isTextuallyCoded',
		'lastSourceString'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'textually coded' }
UniclassScript >> becomeTextuallyCoded [
	"Transform the receiver into one which is textually coded"

	isTextuallyCoded := true.
	lastSourceString := (playerClass sourceCodeAt: selector)  		"Save this to compare when going back to tiles"
]

{ #category : #updating }
UniclassScript >> bringUpToDate [
	"Bring all versions of the receiver's tile-script source up to date"

	currentScriptEditor ifNotNil:
		[currentScriptEditor bringTileScriptingElementsUpToDate].
	formerScriptingTiles isEmptyOrNil ifFalse:
		[formerScriptingTiles do:
			[:aPair | aPair second do:
				[:aMorph | aMorph bringTileScriptingElementsUpToDate]]]
]

{ #category : #initialization }
UniclassScript >> convertFromUserScript: aUserScript [
	"The argument represents an old UserScript object.  convert it over"

	defaultStatus := aUserScript status.
	isTextuallyCoded := aUserScript isTextuallyCoded.
	currentScriptEditor := aUserScript currentScriptEditor.
	formerScriptingTiles :=  aUserScript formerScriptEditors ifNotNil:
		[aUserScript formerScriptEditors collect:
			[:aScriptEditor |
				Array with: aScriptEditor timeStamp with: aScriptEditor submorphs allButFirst]]
]

{ #category : #'script editor' }
UniclassScript >> currentScriptEditor [
	"Answer the currentScriptEditor"

	^ currentScriptEditor
]

{ #category : #'script editor' }
UniclassScript >> currentScriptEditor: anEditor [
	"Set the receiver's currentScriptEditor as indicated"

	currentScriptEditor := anEditor
]

{ #category : #'script editor' }
UniclassScript >> currentScriptEditorDo: aBlock [
	"Evaluate a block on behalf of my current script editor, if any"

	currentScriptEditor ifNotNil:
		[aBlock value: currentScriptEditor]
]

{ #category : #initialization }
UniclassScript >> initialize [
	"Initialize the receiver by setting its inst vars to default values"

	super initialize.
	isTextuallyCoded := false


]

{ #category : #'script editor' }
UniclassScript >> instantiatedScriptEditorForPlayer: aPlayer [
	"Return the current script editor, creating it if necessary"

	currentScriptEditor ifNil:
		[currentScriptEditor := (self playerClass includesSelector: selector) 
			ifTrue:
				[Preferences universalTiles
					ifFalse:
						[self error: 'duplicate selector'].
				ScriptEditorMorph new fromExistingMethod: selector forPlayer: aPlayer]
			ifFalse:
				[ScriptEditorMorph new setMorph: aPlayer costume scriptName: selector].

		(defaultStatus == #ticking and: [selector numArgs == 0]) ifTrue:
			[aPlayer costume arrangeToStartStepping]]
	ifNotNil: [
		(currentScriptEditor = #textuallyCoded and: [self playerClass includesSelector: selector]) ifTrue: [
			currentScriptEditor := ScriptEditorMorph new setMorph: aPlayer costume scriptName: selector.
			self becomeTextuallyCoded.
			(currentScriptEditor submorphs copyFrom: 2 to: currentScriptEditor submorphs size) do: [:m | m delete].
			currentScriptEditor showSourceInScriptor.
		]
	].
	
	^ currentScriptEditor
]

{ #category : #initialization }
UniclassScript >> isTextuallyCoded [
	"Answer whether the receiver is textually coded"

	^ isTextuallyCoded
]

{ #category : #'textually coded' }
UniclassScript >> lastSourceString [
	"Answer the most recent source string"

	^ lastSourceString
]

{ #category : #access }
UniclassScript >> playerClass [
	"Answer the playerClass associated with the receiver"

	^ playerClass ifNil:
		[playerClass := currentScriptEditor playerScripted ifNotNil: [currentScriptEditor playerScripted class]]
]

{ #category : #initialization }
UniclassScript >> playerClass: aPlayerClass selector: aSelector [
	"Set the playerClass and selector of the receiver"

	super playerClass: aPlayerClass selector: aSelector.
	aSelector numArgs = 1 ifTrue:
		[argumentVariables := {Variable new name: 'parameter' type: #Number}]
]

{ #category : #access }
UniclassScript >> playerClassPerSe [
	"Answer the current value of the playerClass inst var."

	^ playerClass
]

{ #category : #initialization }
UniclassScript >> printOn: aStream [
	aStream nextPutAll: 'A UniclassScript - selector: ', selector printString, ' scriptEditor: ', currentScriptEditor printString
]

{ #category : #'script editor' }
UniclassScript >> recompileScriptFromTilesUnlessTextuallyCoded [
	"recompile Script From Tiles Unless Textually Coded"

	self isTextuallyCoded ifFalse:
		[currentScriptEditor ifNotNil: [currentScriptEditor recompileScript]]
]

{ #category : #versions }
UniclassScript >> recreateScriptFrom: anEditor [
	"Used to revert to old tiles"

	formerScriptingTiles isEmptyOrNil ifTrue: [^ self].
	anEditor reinsertSavedTiles: formerScriptingTiles last second.
	isTextuallyCoded := false
]

{ #category : #'initialize-release' }
UniclassScript >> releaseCachedState [
	"release all non-showing scriptors.  What do we do about versions????"
	"18 May 2001 - get more aggressive in dropping stuff"

	formerScriptingTiles := OrderedCollection new.

	currentScriptEditor ifNil: [^ self].

	true ifTrue: [^ self].	"<<< to test the reconstruction of scripts, change to false"
	currentScriptEditor world ifNil: ["not showing"
		currentScriptEditor := nil]
]

{ #category : #versions }
UniclassScript >> revertScriptVersionFrom: anEditor [ 
	"Let user choose which prior tile version to revert to, and revert to it"

	| chosenStampAndTileList |
	formerScriptingTiles isEmptyOrNil ifTrue: [^Beeper beep].
	chosenStampAndTileList := formerScriptingTiles size = 1 
		ifTrue: [ formerScriptingTiles first]
		ifFalse: 
			[UIManager default 
						chooseFrom: (formerScriptingTiles collect: [:e | e first])
						values: formerScriptingTiles].
	chosenStampAndTileList ifNotNil: 
			[anEditor reinsertSavedTiles: chosenStampAndTileList second.
			isTextuallyCoded := false]
]

{ #category : #updating }
UniclassScript >> revertToLastSavedTileVersionFor: anEditor [
	"revert to the last saved tile version"

	Preferences universalTiles
		ifFalse:
			[formerScriptingTiles isEmptyOrNil ifFalse:
				[anEditor reinsertSavedTiles: formerScriptingTiles last second]]
		ifTrue:
			[anEditor removeAllButFirstSubmorph.
			anEditor insertUniversalTiles].
	anEditor showingMethodPane: false.
	isTextuallyCoded := false
]

{ #category : #updating }
UniclassScript >> saveScriptVersion: timeStamp [
	"Save the tile script version by appending a pair of the form

		<time stamp>     <morph list>

to my list of former scripting tiles.  The morph-list will get copied back into the Scriptor following restoration.  Only applies to classic tiles."

	Preferences universalTiles ifFalse:  "the following only applies to Classic tiles"
		[(currentScriptEditor notNil and: [currentScriptEditor showingMethodPane not]) ifTrue:
				[formerScriptingTiles ifNil: [formerScriptingTiles := OrderedCollection new].
				formerScriptingTiles add:
					(Array with: timeStamp
						with: (currentScriptEditor submorphs allButFirst collect: [:m | m veryDeepCopy])).
				formerScriptingTiles size > 100 ifTrue: [^ self halt: 'apparent runaway versions, proceed at your own risk.']]]
]

{ #category : #versions }
UniclassScript >> savedTileVersionsCount [
	"Answer the number of saved tile versions of the script"

	^ formerScriptingTiles ifNil: [0] ifNotNil: [formerScriptingTiles size]
]

{ #category : #copying }
UniclassScript >> veryDeepFixupWith: deepCopier [

	super veryDeepFixupWith: deepCopier.
	self flag: #todo. "Textually coded scripts may also have to be adapted"
	Project current addDeferredUIMessage: [
		"We do this in a deferred way, because the deep copying may non-deterministically
		 be in a state where not all referenced players already have copies, so then we recompile the
		 script, but we still reference the wrong players! - tfel,jl"
		self recompileScriptFromTilesUnlessTextuallyCoded].
]
