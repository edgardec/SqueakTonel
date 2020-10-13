Class {
	#name : #TextEditorCommand,
	#superclass : #Object,
	#instVars : [
		'interval',
		'message',
		'paragraph',
		'selection',
		'contentsBefore',
		'contentsAfter',
		'intervalBefore',
		'intervalAfter',
		'valid',
		'messageToUndo',
		'messageToRedo',
		'intervalBetween',
		'type',
		'isCompositeUndo',
		'isCompositeRedo'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #accessing }
TextEditorCommand >> contentsAfter [

	^ contentsAfter
]

{ #category : #accessing }
TextEditorCommand >> contentsAfter: anObject [

	contentsAfter := anObject
]

{ #category : #accessing }
TextEditorCommand >> contentsBefore [

	^ contentsBefore
]

{ #category : #accessing }
TextEditorCommand >> contentsBefore: anObject [

	contentsBefore := anObject
]

{ #category : #testing }
TextEditorCommand >> hasInsertedSomething [

	^ self contentsBefore isEmpty
]

{ #category : #testing }
TextEditorCommand >> hasReplacedSomething [

	^ self contentsBefore size > 0
]

{ #category : #accessing }
TextEditorCommand >> intervalAfter [

	^ intervalAfter
]

{ #category : #accessing }
TextEditorCommand >> intervalAfter: anObject [

	intervalAfter := anObject
]

{ #category : #accessing }
TextEditorCommand >> intervalBefore [

	^ intervalBefore
]

{ #category : #accessing }
TextEditorCommand >> intervalBefore: anObject [

	intervalBefore := anObject
]

{ #category : #accessing }
TextEditorCommand >> intervalBetween [

	^ intervalBetween
]

{ #category : #accessing }
TextEditorCommand >> intervalBetween: anObject [

	intervalBetween := anObject
]

{ #category : #accessing }
TextEditorCommand >> isCompositeRedo [

	^ isCompositeRedo
]

{ #category : #accessing }
TextEditorCommand >> isCompositeRedo: boolean [

	isCompositeRedo := boolean.
]

{ #category : #accessing }
TextEditorCommand >> isCompositeUndo [

	^ isCompositeUndo
]

{ #category : #accessing }
TextEditorCommand >> isCompositeUndo: boolean [

	isCompositeUndo := boolean.
]

{ #category : #accessing }
TextEditorCommand >> messageToRedo [
	^ messageToRedo
]

{ #category : #accessing }
TextEditorCommand >> messageToRedo: msg [
	messageToRedo := msg.
]

{ #category : #accessing }
TextEditorCommand >> messageToUndo [
	^ messageToUndo
]

{ #category : #accessing }
TextEditorCommand >> messageToUndo: msg [
	messageToUndo := msg.
]

{ #category : #copying }
TextEditorCommand >> postCopy [

	super postCopy.
	
	contentsAfter := contentsAfter copy.
	contentsBefore := contentsBefore copy.
	intervalAfter := intervalAfter copy.
	intervalBefore := intervalBefore copy.
	intervalBetween := intervalBetween copy.

	messageToUndo := messageToUndo copy.
	messageToRedo := messageToRedo copy.
]

{ #category : #'undo\/redo' }
TextEditorCommand >> redoIn: editor [

	self messageToRedo sendTo: editor.
]

{ #category : #accessing }
TextEditorCommand >> type [

	^ type
]

{ #category : #accessing }
TextEditorCommand >> type: symbol [

	type := symbol.
]

{ #category : #'undo\/redo' }
TextEditorCommand >> undoIn: editor [

	self messageToUndo sendTo: editor.
]
