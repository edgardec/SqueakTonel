"
An object representing an undoable command to be done in the environment.

Structure:
	phase			indicates whether the cmd is current in undone or redone mode
 	cmdWording		The wording of the command (used in arming the ""undo""/""redo"" menu items
 	parameters		an IdentityDictionary /NOT USED/
	undoTarget		Receiver, selector and arguments to accomplish undo
	undoSelector
	undoArguments
	redoTarget		Receiver, selector and arguments to accomplish redo
	redoSelector
	redoArguments

To use this, for any command you wish to use, you
	*	Create an instance of Command, as follows...
			cmd := Command new cmdWording: 'resizing'.
	*	Give the the command undo state and redo state, as follows...
			cmd undoTarget: target selector: #extent: argument: oldExtent.
			cmd redoTarget: target selector: #extent: argument: newExtent.
	*	Send a message of the form
			Command rememberCommand: cmd

LastCommand is the last command that was actually done or undone.

CommandHistory, applicable only when infiniteUndo is set, holds a 'tape' of the complete history of commands, as far back as it's possible to go.

CommandExcursions, also applicable only in the infiniteUndo case, and rather at the fringe even then, holds segments of former CommandHistory that have been lopped off because of variant paths taken.
"
Class {
	#name : #Command,
	#superclass : #Object,
	#instVars : [
		'phase',
		'cmdWording',
		'undoTarget',
		'undoSelector',
		'undoArguments',
		'redoTarget',
		'redoSelector',
		'redoArguments',
		'parameters'
	],
	#category : #'MorphicExtras-Undo'
}

{ #category : #'initialize-release' }
Command class >> cleanUp [

	MorphExtension allInstancesDo: [ :each | each removeUndoCommands ]
]

{ #category : #'dog simple ui' }
Command class >> redoEnabled [
	| w |
	^(w := self currentWorld) == nil ifTrue:[false] ifFalse:[w commandHistory redoEnabled]
]

{ #category : #'dog simple ui' }
Command class >> redoNextCommand [
	| w |
	^(w := self currentWorld) == nil ifFalse:[w commandHistory redoNextCommand]
]

{ #category : #'dog simple ui' }
Command class >> undoEnabled [
	| w |
	^(w := self currentWorld) == nil ifTrue:[false] ifFalse:[w commandHistory undoEnabled]
]

{ #category : #'dog simple ui' }
Command class >> undoLastCommand [
	| w |
	^(w := self currentWorld) == nil ifFalse:[w commandHistory undoLastCommand]
]

{ #category : #'dog simple ui' }
Command class >> undoRedoButtons [
	"Answer a morph that offers undo and redo buttons"

	| wrapper |
	"self currentHand attachMorph: Command undoRedoButtons"
	wrapper := AlignmentMorph newColumn.
	wrapper color: Color veryVeryLightGray lighter;
		borderWidth: 0;
		layoutInset: 0;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.
	#((CrudeUndo undoLastCommand 'undo last command done' undoEnabled CrudeUndoDisabled CrudeUndoDisabled) 
	(CrudeRedo redoNextCommand 'redo last undone command' redoEnabled CrudeRedoDisabled CrudeRedoDisabled)) do:
		[:tuple |
			| aButton |
			wrapper addTransparentSpacerOfSize: (8@0).
			aButton := UpdatingThreePhaseButtonMorph new.
			aButton
				onImage: (ScriptingSystem formAtKey: tuple first);
				offImage: (ScriptingSystem formAtKey: tuple fifth);
				pressedImage: (ScriptingSystem formAtKey: tuple sixth);
				getSelector: tuple fourth;
				color: Color transparent; 
				target: self;
				actionSelector: tuple second;
				setNameTo: tuple second;
				setBalloonText: tuple third;
				extent: aButton onImage extent.
			wrapper addMorphBack: aButton.
			wrapper addTransparentSpacerOfSize: (8@0)].
	^ wrapper
]

{ #category : #'class initialization' }
Command class >> zapObsolete [
"Command zapObsolete"
	"kill some obsolete stuff still retained by the CompiledMethods in change records"

	| before after histories lastCmd histCount lastCount |
	Smalltalk garbageCollect.
	before := Command allInstances size.
	histories := Association allInstances select: [ :each | 
		each key == #CommandHistory and: [
			(each value isKindOf: OrderedCollection) and: [
				each value isEmpty not and: [
					each value first isKindOf: Command]]]
	].
	histCount := histories size.
	lastCmd := Association allInstances select: [ :each | 
		each key == #LastCommand and: [each value isKindOf: Command]
	].
	lastCount := lastCmd size.
	histories do: [ :each | each value: OrderedCollection new].
	lastCmd do: [ :each | each value: Command new].
	Smalltalk garbageCollect.
	Smalltalk garbageCollect.
	after := Command allInstances size.
	Transcript show: {before. after. histCount. histories. lastCount. lastCmd} printString; cr; cr.
	
]

{ #category : #private }
Command >> assuredParameterDictionary [
	"Private!  Answer the parameters dictionary, creating it if necessary"

	^ parameters ifNil: [parameters := IdentityDictionary new]
]

{ #category : #private }
Command >> cmdWording [
	"Answer the wording to be used to refer to the command in a menu"

	^ cmdWording ifNil: ['last command' translated]
]

{ #category : #initialization }
Command >> cmdWording: wrd [
	"Set the wording to be used in a menu item referring to the receiver"

	cmdWording := wrd
]

{ #category : #'command execution' }
Command >> doCommand [
	"Do the command represented by the receiver.  Not actually called by active current code, but reachable by the not-yet-unsealed promoteToCurrent: action."

	redoTarget ifNotNil: [redoTarget perform: redoSelector withArguments: redoArguments]
]

{ #category : #parameters }
Command >> parameterAt: aSymbol [
	"Answer the parameter stored at the given symbol, or nil if none"

	^ self parameterAt: aSymbol ifAbsent: [nil]
]

{ #category : #parameters }
Command >> parameterAt: aSymbol ifAbsent: aBlock [
	"Answer the parameter stored at the aSymbol, but if none, return the result of evaluating aBlock"

	^ self assuredParameterDictionary at: aSymbol ifAbsent: aBlock
]

{ #category : #parameters }
Command >> parameterAt: aSymbol put: aValue [
	"Place aValue in the parameters dictionary using aSymbol as key"

	^ self assuredParameterDictionary at: aSymbol put: aValue
]

{ #category : #private }
Command >> phase [
	"Answer the phase of the command"

	^ phase
]

{ #category : #initialization }
Command >> phase: aPhase [
	"Set the phase of the command to the supplied symbol"

	phase := aPhase
]

{ #category : #printing }
Command >> printOn: aStream [
	"Provide more detailed info about the receiver, put in for debugging, maybe should be removed"

	super printOn: aStream.
	aStream nextPutAll: ' phase: ', phase printString.
	cmdWording ifNotNil: [aStream nextPutAll: '; ', cmdWording asString].
	parameters ifNotNil:
		[parameters associationsDo:
			[:assoc | aStream nextPutAll: ': ', assoc printString]]
]

{ #category : #'command execution' }
Command >> redoCommand [
	"Perform the 'redo' operation"

	redoTarget ifNotNil: [redoTarget perform: redoSelector withArguments: redoArguments]
]

{ #category : #initialization }
Command >> redoTarget: target selector: aSymbol argument: argument [

	^ self redoTarget: target selector: aSymbol arguments: {argument}
]

{ #category : #initialization }
Command >> redoTarget: target selector: selector arguments: arguments [
	"Give target morph a chance to refine its undo operation"

	target refineRedoTarget: target selector: selector arguments: arguments in:
		[:rTarget :rSelector :rArguments |
		redoTarget := rTarget.
		redoSelector := rSelector.
		redoArguments := rArguments]
]

{ #category : #'command execution' }
Command >> stillValid [
	"Answer whether the receiver is still valid."

	^ (undoTarget isMorph and: [undoTarget isInWorld]) or: [redoTarget isMorph and:  [redoTarget isInWorld]]
]

{ #category : #'command execution' }
Command >> undoCommand [
	"Perform the 'undo' operation"

	undoTarget ifNotNil: [undoTarget perform: undoSelector withArguments: undoArguments]
]

{ #category : #private }
Command >> undoTarget [
	^ undoTarget
]

{ #category : #initialization }
Command >> undoTarget: target selector: aSymbol argument: argument [

	^ self undoTarget: target selector: aSymbol arguments: {argument}
]

{ #category : #initialization }
Command >> undoTarget: target selector: selector arguments: arguments [
	"Give target morph a chance to refine its undo operation"

	target refineUndoTarget: target selector: selector arguments: arguments in:
		[:rTarget :rSelector :rArguments |
		undoTarget := rTarget.
		undoSelector := rSelector.
		undoArguments := rArguments]
]

{ #category : #copying }
Command >> veryDeepFixupWith: deepCopier [
	"ALL inst vars were weakly copied.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"
	super veryDeepFixupWith: deepCopier.
	1 to: self class instSize do:
		[:ii |
		| old  |
		old := self instVarAt: ii.
		self instVarAt: ii put: (deepCopier references at: old ifAbsent: [old])].
]

{ #category : #copying }
Command >> veryDeepInner: deepCopier [
	"ALL fields are weakly copied!  Can't duplicate an object by duplicating a Command that involves it.  See DeepCopier."

	super veryDeepInner: deepCopier.
	"just keep old pointers to all fields"
	parameters := parameters.
]
