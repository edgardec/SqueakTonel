"
A MethodInterface bound to an actual class.

	selector					A symbol - the selector being described
	argumentSpecifications	A list of specifications for the formal arguments of the method
	resultSpecification 		A characterization of the return value of the method
	userLevel				
	attributeKeywords		A list of symbols, comprising keywords that the user wishes to
								associate with this method
	defaultStatus			The status to apply to new instances of the class by default
	defaultFiresPerTick		How many fires per tick, by default, should be allowed if ticking.
	playerClass				The actual class with which this script is associated
"
Class {
	#name : #MethodWithInterface,
	#superclass : #MethodInterface,
	#instVars : [
		'playerClass'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'script editor' }
MethodWithInterface >> allScriptActivationButtons [
	"Answer all the script-activation buttons that exist for this interface"

	^ ScriptActivationButton allInstances select: 
		[:aButton | aButton uniclassScript == self]
]

{ #category : #'script editor' }
MethodWithInterface >> allScriptEditors [
	"Answer all the script editors that exist for the class and selector of this interface"

	^ ScriptEditorMorph allInstances select: 
		[:aScriptEditor | aScriptEditor playerScripted class == self playerClass and:
			[aScriptEditor scriptName == selector]]
]

{ #category : #updating }
MethodWithInterface >> bringUpToDate [
	"Bring all scriptors related to this method up to date.  Note that this will not change the senders of this method if the selector changed -- that's something still ahead."

	(ScriptEditorMorph allInstances select:
		[:m | (m playerScripted isMemberOf: self playerClass) and: [m scriptName == selector]])
			do:
				[:m | m bringUpToDate]
]

{ #category : #initialization }
MethodWithInterface >> convertFromUserScript: aUserScript [
	"The argument represents an old UserScript object.  convert it over"

	defaultStatus := aUserScript status.
]

{ #category : #'script editor' }
MethodWithInterface >> currentScriptEditor: anEditor [
	"Set the receiver's currentScriptEditor as indicated, if I care.  MethodWithInterface does not care, since it does not hold on to a ScriptEditor.  A subclass of mine, however does, or did, care"
]

{ #category : #initialization }
MethodWithInterface >> initialize [
	"Initialize the receiver by setting its inst vars to default values"

	super initialize.
	defaultStatus := #normal
]

{ #category : #'script editor' }
MethodWithInterface >> instantiatedScriptEditorForPlayer: aPlayer [
	"Return a new script editor for the player and selector"

	| aScriptEditor |
	aScriptEditor := (self playerClass includesSelector: selector) 
			ifTrue: [ScriptEditorMorph new 
				fromExistingMethod: selector 
				forPlayer: aPlayer]
			ifFalse: [ScriptEditorMorph new
				setMorph: aPlayer costume
				scriptName: selector].
		defaultStatus == #ticking ifTrue:
			[aPlayer costume arrangeToStartStepping].
	
	^ aScriptEditor
]

{ #category : #initialization }
MethodWithInterface >> isTextuallyCoded [
	"Answer whether the receiver is in a textually-coded state.  A leftover from much earlier times, this is a vacuous backstop"

	^ false
]

{ #category : #rename }
MethodWithInterface >> okayToRename [
	"Answer whether the receiver is in a state to be renamed."

	^ true
]

{ #category : #access }
MethodWithInterface >> playerClass [
	"Answer the playerClass associated with the receiver.  Note: fixes up cases where the playerClass slot was a Playerxxx object because of an earlier bug"

	^ (playerClass isKindOf: Class)
		ifTrue:
			[playerClass]
		ifFalse:
			[playerClass := playerClass class]
]

{ #category : #initialization }
MethodWithInterface >> playerClass: aPlayerClass selector: aSelector [
	"Set the playerClass and selector of the receiver"

	playerClass := aPlayerClass.
	selector := aSelector.
]

{ #category : #'script editor' }
MethodWithInterface >> recompileScriptFromTilesUnlessTextuallyCoded [
	"Recompile Script From Tiles Unless Textually Coded.  For the universal-tiles MethodWithInterface case, this is moot.  Used only in support of a reintegration of Open-school forked projects from Sept 2000 in 7/01"
]

{ #category : #rename }
MethodWithInterface >> renameScript: newSelector fromPlayer: aPlayer [
	"The receiver's selector has changed to the new selector.  Get various things right, including the physical appearance of any Scriptor open on this method"

	self allScriptEditors do:
		[:aScriptEditor | aScriptEditor renameScriptTo: newSelector].

	(selector numArgs = 0 and: [newSelector numArgs = 1])
		ifTrue:
			[self argumentVariables: (OrderedCollection with:
				(Variable new name: #parameter type: #Number))].
	(selector numArgs = 1 and: [newSelector numArgs = 0])
		ifTrue:
			[self argumentVariables: OrderedCollection new].

	selector := newSelector asSymbol.
	self bringUpToDate.
	self playerClass atSelector: selector putScript: self.
	self allScriptGoverningButtons  do:
		[:aButton | aButton bringUpToDate].


]

{ #category : #updating }
MethodWithInterface >> revertToLastSavedTileVersionFor: anEditor [
	"revert to the last saved tile version.  Only for universal tiles."

	anEditor removeAllButFirstSubmorph.
	anEditor insertUniversalTiles.
	anEditor showingMethodPane: false
]

{ #category : #updating }
MethodWithInterface >> saveScriptVersion: timeStamp [
	"Save the tile script version if I do that sort of thing"
]

{ #category : #initialization }
MethodWithInterface >> status [
	^defaultStatus

]
