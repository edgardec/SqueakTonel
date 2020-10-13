"
Holds the ScriptEditorMorph structures for the current version of a user-defined tile script, as well as previous versions thereof.
	currentScriptEditor	The current version of the ScriptEditorMorph for the script
	formerScriptEditors 	Earlier versions of the script, for recapturing via the Versions feature
							(a dictionary, <timeStamp> -> ScriptEditorMorph
"
Class {
	#name : #UserScript,
	#superclass : #ScriptInstantiation,
	#instVars : [
		'currentScriptEditor',
		'formerScriptEditors'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'script editor' }
UserScript >> allScriptVersionsDo: aBlock [

	self isTextuallyCoded ifFalse: [aBlock value: currentScriptEditor].
	formerScriptEditors ifNotNil: [ formerScriptEditors do: aBlock ]
]

{ #category : #'textually coded' }
UserScript >> becomeTextuallyCoded [
	currentScriptEditor := #textuallyCoded
]

{ #category : #'script editor' }
UserScript >> bringUpToDate [
	self allScriptVersionsDo: [:v | v bringUpToDate]
]

{ #category : #'script editor' }
UserScript >> currentScriptEditor [
	"Answer the currentScriptEditor value"

	^ currentScriptEditor
]

{ #category : #'script editor' }
UserScript >> currentScriptEditor: anEditor [
	currentScriptEditor := anEditor
]

{ #category : #'script editor' }
UserScript >> formerScriptEditors [
	"Answer the formerScriptEditors value"

	^ formerScriptEditors
]

{ #category : #'script editor' }
UserScript >> instantiatedScriptEditor [
	"Return the current script editor, creating it if necessary"

	self isTextuallyCoded ifTrue:
			[^ (player costume pasteUpMorph ifNil: [player costume "the world, backstop"]) scriptorForTextualScript: selector ofPlayer: player].

	currentScriptEditor ifNil:
		[currentScriptEditor := (player class includesSelector: selector) 
			ifTrue: [ScriptEditorMorph new 
				fromExistingMethod: selector 
				forPlayer: player]
			ifFalse: [ScriptEditorMorph new
				setMorph: player costume
				scriptName: selector].
		status == #ticking ifTrue: [player costume arrangeToStartStepping]].
	
	^ currentScriptEditor
]

{ #category : #'textually coded' }
UserScript >> isTextuallyCoded [
	^ currentScriptEditor == #textuallyCoded
]

{ #category : #versions }
UserScript >> recreateScriptFrom: anEditor [
	"Used to revert to old tiles"

	formerScriptEditors isEmptyOrNil ifTrue: [^ self].
	self revertScriptVersionFrom: anEditor installing: formerScriptEditors last
]

{ #category : #'script editor' }
UserScript >> releaseCachedState [
	"release all non-showing scriptors.  What do we do about versions????"

	self isTextuallyCoded ifTrue: [formerScriptEditors := OrderedCollection new].
		"to test new tiles.  We 'commit' to current script."
	currentScriptEditor ifNil: [^ self].
	true ifTrue: [^ self].	"<<< to test the reconstruction of scripts, change to false"
	currentScriptEditor world ifNil: ["not showing"
		currentScriptEditor := nil].


]

{ #category : #versions }
UserScript >> revertScriptVersionFrom: anEditor [ 
	"Let user choose which prior tile version to revert to, and revert to it"

	| result |
	formerScriptEditors isEmptyOrNil ifTrue: [^Beeper beep].
	result := formerScriptEditors size = 1 
		ifTrue: [formerScriptEditors first]
		ifFalse: 
			[UIManager default 
						chooseFrom: (formerScriptEditors collect: [:e | e timeStamp])
						values: formerScriptEditors].
	result 
		ifNotNil: [self revertScriptVersionFrom: anEditor installing: result]
]

{ #category : #versions }
UserScript >> revertScriptVersionFrom: anEditor installing: aSavedEditor [
	"Replace anEditor with a brought-up-to-date version of aSavedEditor"

	| aPosition oldOwner |
	aPosition := anEditor position.
	oldOwner := anEditor topRendererOrSelf owner.
	anEditor delete.
	currentScriptEditor := aSavedEditor bringUpToDate install.
	player costume viewAfreshIn: oldOwner showingScript: selector at: aPosition
]

{ #category : #versions }
UserScript >> revertToLastSavedTileVersionFor: anEditor [
	"revert to the last saved tile version"

	formerScriptEditors isEmptyOrNil ifFalse:
		[self revertScriptVersionFrom: anEditor installing: formerScriptEditors last]
]

{ #category : #versions }
UserScript >> saveScriptVersion: timeStampCurrentlyIgnored [ 
	self isTextuallyCoded 
		ifFalse: 
			[formerScriptEditors isNil 
				ifTrue: [formerScriptEditors := OrderedCollection new].
			currentScriptEditor 
				ifNotNil: [formerScriptEditors add: currentScriptEditor veryDeepCopy].
			formerScriptEditors size > 100 
				ifTrue: [^self error: 'apparent runaway versions']]
]

{ #category : #versions }
UserScript >> savedTileVersionsCount [
	"Answer the number of saved tile versions of the script"

	^ formerScriptEditors ifNil: [0] ifNotNil: [formerScriptEditors size]
]

{ #category : #updating }
UserScript >> updateToPlayer: aPlayer [
	"Set aPlayer as the current player referenced by the receiver and its script editor"

	(currentScriptEditor notNil and: [currentScriptEditor ~~ #textuallyCoded]) ifTrue:
		[currentScriptEditor updateToPlayer: aPlayer].
	player := aPlayer
]
