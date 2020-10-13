Class {
	#name : #TextEditorCommandHistory,
	#superclass : #Object,
	#instVars : [
		'commands',
		'currentIndex'
	],
	#classVars : [
		'MaximumTextHistoryDepth'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #preferences }
TextEditorCommandHistory class >> maximumTextHistoryDepth [
	<preference: 'Maximum text edit (undo/redo) history depth'
		categoryList:  #(editing Morphic)
		description: 'Specifies the number of editor commands that will be stored in a text editor'
		type: #Number>
	^ MaximumTextHistoryDepth ifNil: [500]
]

{ #category : #preferences }
TextEditorCommandHistory class >> maximumTextHistoryDepth: number [

	MaximumTextHistoryDepth := number.
]

{ #category : #'undo\/redo' }
TextEditorCommandHistory >> beginRemember: command [

	commands := commands
		copyFrom: (1 max: (currentIndex + 2 - self class maximumTextHistoryDepth))
		to: (currentIndex min: commands size).
	commands := commands, {command}.
	currentIndex := commands size - 1. "Select the new command."
]

{ #category : #accessing }
TextEditorCommandHistory >> current [

	^ self next
]

{ #category : #enumeration }
TextEditorCommandHistory >> detect: block [

	self do: [:command |
		(block value: command) ifTrue: [^ command]].
	^ nil
]

{ #category : #enumeration }
TextEditorCommandHistory >> do: block [
	"Goes backward in history."
	
	((currentIndex min: commands size) to: 1 by: -1)
		do: [:i | block value: (commands at: i)].
]

{ #category : #'undo\/redo' }
TextEditorCommandHistory >> finishRemember [

	currentIndex := commands size.
]

{ #category : #testing }
TextEditorCommandHistory >> hasCursorMoved: cursorIndex [

	^ self hasPrevious and: [self previous intervalAfter first ~= cursorIndex]
]

{ #category : #testing }
TextEditorCommandHistory >> hasInsertedSomething [

	^ self hasPrevious and: [self previous hasInsertedSomething]
]

{ #category : #accessing }
TextEditorCommandHistory >> hasNext [

	^ currentIndex < commands size
]

{ #category : #accessing }
TextEditorCommandHistory >> hasPrevious [

	^ currentIndex > 0
]

{ #category : #testing }
TextEditorCommandHistory >> hasReplacedSomething [

	^ self hasPrevious and: [self previous hasReplacedSomething]
]

{ #category : #initialization }
TextEditorCommandHistory >> initialize [

	super initialize.
	self reset.
]

{ #category : #accessing }
TextEditorCommandHistory >> next [

	^ self hasNext
		ifTrue: [commands at: currentIndex+1]
		ifFalse: [nil]
]

{ #category : #accessing }
TextEditorCommandHistory >> previous [

	^ self hasPrevious
		ifTrue: [commands at: currentIndex]
		ifFalse: [nil]
]

{ #category : #'undo\/redo' }
TextEditorCommandHistory >> redoIn: editor [

	self hasNext ifFalse: [^ self].
	
	[self current redoIn: editor]
		ensure: [currentIndex := currentIndex + 1].

	self previous isCompositeRedo == true ifTrue: [self redoIn: editor].
]

{ #category : #initialization }
TextEditorCommandHistory >> reset [

	commands := #().
	currentIndex := 0.
]

{ #category : #'undo\/redo' }
TextEditorCommandHistory >> undoIn: editor [

	self hasPrevious ifFalse: [^ self].
	
	currentIndex := currentIndex - 1.
	self current undoIn: editor.

	self current isCompositeUndo == true ifTrue: [self undoIn: editor].
]
