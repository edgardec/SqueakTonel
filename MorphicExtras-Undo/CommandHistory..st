Class {
	#name : #CommandHistory,
	#superclass : #Object,
	#instVars : [
		'lastCommand',
		'history',
		'excursions'
	],
	#category : #'MorphicExtras-Undo'
}

{ #category : #'class initialization' }
CommandHistory class >> cleanUp [
	"Dump command histories"

	self resetAllHistory

]

{ #category : #'class initialization' }
CommandHistory class >> initialize [
	"CommandHistory initialize"

	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self.
]

{ #category : #'system startup' }
CommandHistory class >> resetAllHistory [
	"Reset all command histories, and make all morphs that might be holding on to undo-grab-commands forget them"

	self allInstancesDo: [:c | c resetCommandHistory].
	MorphExtension withAllSubclassesDo:
		[:morphExtensionClass|
		 morphExtensionClass allInstancesDo:
			[:object| object removeProperty: #undoGrabCommand]]

	"CommandHistory resetAllHistory"

]

{ #category : #'system startup' }
CommandHistory class >> shutDown: aboutToQuit [ 
	Preferences purgeUndoOnQuit ifTrue: [
		aboutToQuit ifTrue: [self resetAllHistory].
	].

]

{ #category : #'system startup' }
CommandHistory class >> startUp: aboutToQuit [ 
	Preferences purgeUndoOnQuit
		ifTrue: [
			aboutToQuit ifTrue: [self resetAllHistory].
		].
 
	
]

{ #category : #'called by programmer' }
CommandHistory >> assureLastCommandStillValid [
	"If the lastCommand is not valid, set it to nil; answer the lastCommand."

	lastCommand ifNotNil:
		[lastCommand stillValid ifFalse:
			[self cantUndo]].
	^ lastCommand
]

{ #category : #'called by programmer' }
CommandHistory >> cantUndo [
	"Called by client to indicate that the prior undoable command is no longer undoable"

	lastCommand := nil.
	history := OrderedCollection new.
]

{ #category : #'called from the ui' }
CommandHistory >> commandToUndo [
	"Undo the last command, i.e. move backward in the recent-commands tape, if possible."

	| anIndex |
	lastCommand ifNil: [^ nil].
	lastCommand phase == #done ifTrue: [^ lastCommand].
	(lastCommand phase == #undone and:
		[(anIndex := history indexOf: lastCommand) > 1])
		ifTrue: [^ history at: anIndex - 1]
		ifFalse: [^ nil]

]

{ #category : #'command history' }
CommandHistory >> historyIndexOfLastCommand [
	"Answer which position of the CommandHistory list is occupied by the LastCommand"

	^ history indexOf: lastCommand
]

{ #category : #initialize }
CommandHistory >> initialize [
	lastCommand := nil.
	history := OrderedCollection new.
	excursions := OrderedCollection new.
]

{ #category : #'command history' }
CommandHistory >> lastCommand [
	"Answer the last command done or undone"

	^ lastCommand
]

{ #category : #'command history' }
CommandHistory >> nextCommand [
	"Answer the command object that would be sent the #redoCommand message if the user were to request Redo, or nil if none"

	| anIndex |
	lastCommand ifNil: [^ nil].
	lastCommand phase == #undone ifTrue: [^ lastCommand].
	anIndex := history indexOf: lastCommand ifAbsent: [^ nil].
	^ anIndex = history size ifTrue: [nil] ifFalse: [history at: (anIndex + 1)]
]

{ #category : #menu }
CommandHistory >> nextCommandToUndo [
	| anIndex |
	lastCommand ifNil: [^ nil].
	lastCommand phase == #done ifTrue: [^ lastCommand].
	(lastCommand phase == #undone and:
		[(anIndex := history indexOf: lastCommand) > 1])
		ifTrue: [^ history at: anIndex - 1]
		ifFalse: [^ nil]
]

{ #category : #'called by programmer' }
CommandHistory >> promoteToCurrent: aCommand [
	"Very unusual and speculative and unfinished!.  Not currently reachable.  For the real thing, we presumably march forward or backward from the current command pointer to the target command in an orderly fashion, doing or undoing each command in turn."

	| itsIndex |
	Preferences useUndo ifFalse: [^ self].
	itsIndex := history indexOf: aCommand ifAbsent: [nil].
	itsIndex ifNotNil:
		[history remove: aCommand ifAbsent: []].
	history add: (lastCommand := aCommand).
	itsIndex < history size ifTrue:
		[excursions add: (history copyFrom: (itsIndex to: history size))].
	history := (history copyFrom: 1 to: itsIndex) copyWith: aCommand.

	lastCommand := aCommand.
	aCommand doCommand.
	lastCommand phase: #done.
]

{ #category : #'called by programmer' }
CommandHistory >> purgeAllCommandsSuchThat: cmdBlock [ 
	"Remove a bunch of commands, as in [:cmd | cmd undoTarget == zort]"

	Preferences useUndo ifFalse: [^self].
	history := history reject: cmdBlock.
	lastCommand := history isEmpty ifTrue: [nil] ifFalse: [history last] 
]

{ #category : #menu }
CommandHistory >> redoEnabled [
	"Answer whether the redo command is currently available"

	^ self nextCommand notNil
]

{ #category : #menu }
CommandHistory >> redoMenuWording [
	"Answer the wording to be used in a menu offering the current 
	Redo command"
	| nextCommand |

	((nextCommand := self nextCommand) isNil
			or: [Preferences useUndo not])
		ifTrue: [^ 'can''t redo' translated].

	^ String
		streamContents: [:aStream | 
			aStream nextPutAll: 'redo' translated.
			aStream nextPutAll: ' "'.
			aStream nextPutAll: (nextCommand cmdWording truncateWithElipsisTo: 20).
			aStream nextPut: $".
			lastCommand phase == #done
				ifFalse: [aStream nextPutAll: ' (z)']]
]

{ #category : #'called from the ui' }
CommandHistory >> redoNextCommand [
	"If there is a way to 'redo' (move FORWARD) in the undo/redo history tape, do it."

	| anIndex |
	lastCommand ifNil: [^ Beeper beep].
	lastCommand phase == #undone
		ifFalse:
			[anIndex := history indexOf: lastCommand.
			(anIndex < history size)
				ifTrue:
					[lastCommand := history at: anIndex + 1]
				ifFalse:
					[^ Beeper beep]].

	lastCommand redoCommand.
	lastCommand phase: #done

]

{ #category : #undo }
CommandHistory >> rememberCommand: aCommand [
	"Make the supplied command be the 'LastCommand', and mark it 'done'"

	| currentCommandIndex |
	Preferences useUndo ifFalse: [^ self].  "Command initialize"

	Preferences infiniteUndo ifTrue:
		[currentCommandIndex := history indexOf: lastCommand.
		((currentCommandIndex < history size) and: [Preferences preserveCommandExcursions]) ifTrue:
			[excursions add: (history copyFrom: (currentCommandIndex to: history size)).
			history := history copyFrom: 1 to: currentCommandIndex].
		history addLast: aCommand].

	lastCommand := aCommand.
	lastCommand phase: #done.
]

{ #category : #'command history' }
CommandHistory >> resetCommandHistory [    "CommandHistory allInstancesDo: [:ch | ch resetCommandHistory]"
	"Clear out the command history so that no commands are held"

	lastCommand := nil.
	history := OrderedCollection new.
]

{ #category : #menu }
CommandHistory >> undoEnabled [
	"Answer whether there is an undoable command at the ready"

	^ lastCommand notNil
]

{ #category : #'called from the ui' }
CommandHistory >> undoLastCommand [
	"Undo the last command, i.e. move backward in the recent-commands tape, if possible."

	| aPhase anIndex |
	lastCommand ifNil: [^ Beeper beep].

	(aPhase := lastCommand phase) == #done
		ifFalse:
			[aPhase == #undone
				ifTrue:
					[anIndex := history indexOf: lastCommand.
					anIndex > 1 ifTrue:
						[lastCommand := history at: anIndex - 1]]].

	lastCommand undoCommand.
	lastCommand phase: #undone

	"Command undoLastCommand"

]

{ #category : #menu }
CommandHistory >> undoMenuWording [
	"Answer the wording to be used in an 'undo' menu item"

	(lastCommand isNil
			or: [Preferences useUndo not
			or: [(Preferences infiniteUndo not and: [lastCommand phase == #undone])
			or: [self nextCommandToUndo isNil]]])
		ifTrue: [^ 'can''t undo' translated].

	^ String
		streamContents: [:aStream | 
			aStream nextPutAll: 'undo' translated.
			aStream nextPutAll: ' "'.
			aStream nextPutAll: (self nextCommandToUndo cmdWording truncateWithElipsisTo: 20).
			aStream nextPut: $".
			lastCommand phase == #done
				ifTrue: [aStream nextPutAll: ' (z)']].
]

{ #category : #'called from the ui' }
CommandHistory >> undoOrRedoCommand [
	"This gives a feature comparable to standard Mac undo/redo.  If the undo/redo action taken was a simple do or a redo, then undo it.  But if the last undo/redo action taken was an undo, then redo it."

	"Command undoOrRedoCommand"
	| aPhase |
	lastCommand ifNil: [^ Beeper beep].

	(aPhase := lastCommand phase) == #done
		ifTrue:
			[lastCommand undoCommand.
			lastCommand phase: #undone]
		ifFalse:
			[aPhase == #undone
				ifTrue:
					[lastCommand redoCommand.
					lastCommand phase: #done]]
]

{ #category : #menu }
CommandHistory >> undoOrRedoMenuWording [
	"Answer the wording to be used in a menu item offering undo/redo (i.e., the form used when the #infiniteUndo preference is false)"

	| pre |
	self assureLastCommandStillValid. 
	lastCommand ifNil: [^ 'can''t undo' translated].
	pre := lastCommand phase == #done
		ifTrue: ['undo' translated]
		ifFalse: ['redo' translated].
	^ pre, ' "', (lastCommand cmdWording truncateWithElipsisTo: 20), '" (z)'
]

{ #category : #'called from the ui' }
CommandHistory >> undoTo [
	"Not yet functional, and not yet sent.  Allow the user to choose a point somewhere in the undo/redo tape, and undo his way to there.   Applicable only if infiniteUndo is set. "

	| anIndex commandList reply |
	(anIndex := self historyIndexOfLastCommand) = 0 ifTrue: [^ Beeper beep].
	commandList := history
		copyFrom:	((anIndex - 10) max: 1)
		to:			((anIndex + 10) min: history size).
	reply := UIManager default chooseFrom: (commandList collect: [:cmd | cmd cmdWording truncateWithElipsisTo: 20]) values: commandList title: 'undo or redo to...'.
	reply ifNotNil: [self inform: #deferred]

	"ActiveWorld commandHistory undoTo"

]
