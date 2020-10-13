Class {
	#name : #TextMorphForEditView,
	#superclass : #TextMorph,
	#instVars : [
		'editView',
		'acceptOnCR'
	],
	#classVars : [
		'DraggableTextSelection'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #preferences }
TextMorphForEditView class >> draggableTextSelection [

	<preference: 'Draggable Text Selections'
		categoryList: #(editing mouse Morphic)
		description: 'Whether you can drag-and-drop selections in text morphs.'
		type: #Boolean>
		
	^ DraggableTextSelection ifNil: [false]
]

{ #category : #preferences }
TextMorphForEditView class >> draggableTextSelection: aBoolean [

	DraggableTextSelection := aBoolean.
	
	TextMorphForEditView allInstancesDo: [:tm |
		tm dragEnabled: aBoolean; dropEnabled: aBoolean].
]

{ #category : #'new-morph participation' }
TextMorphForEditView class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #editing }
TextMorphForEditView >> acceptContents [
	"The message is sent when the user hits enter or Cmd-S.
	Accept the current contents and end editing."
	self updateFromParagraph.
	editView accept.
]

{ #category : #'dropping\/grabbing' }
TextMorphForEditView >> acceptDroppingMorph: aTransferMorph event: evt [
	"Accept a text to be inserted at the event/cursor position. Either remove or keep the source text depending on the transfer morph's copy state."
	
	| sourceEditor |
	sourceEditor := (aTransferMorph source respondsTo: #editor)
		ifTrue: [aTransferMorph source editor]
		ifFalse: [nil].

	self
		handleInteraction: [
			
			"1) Delete selection if it is a move operation."
			(aTransferMorph shouldCopy or: [sourceEditor isNil]) ifFalse: [
				sourceEditor destructiveBackWord.
				sourceEditor history previous isCompositeRedo: sourceEditor == self editor].
			
			"2) Insert selection at new place."
			self editor addText: aTransferMorph passenger asText event: evt.
			self editor history previous
				isCompositeUndo: (sourceEditor == self editor and: [aTransferMorph shouldCopy not])]

		fromEvent: evt.
	
	evt hand newKeyboardFocus: self.
]

{ #category : #editing }
TextMorphForEditView >> acceptOnCR [
	"Answer whether the receiver wants to accept when the Return key is hit"

	^ acceptOnCR == true
]

{ #category : #'accept\/cancel' }
TextMorphForEditView >> acceptOnCR: trueOrFalse [
	acceptOnCR := trueOrFalse
]

{ #category : #'event handling' }
TextMorphForEditView >> autoScrollView: evt [
	"This is kind of a hack because the PluggableTextMorph expects me to first expand the selection before auto scrolling will work."
	| localEvt |
	localEvt := evt transformedBy: (self transformedFrom: editView).
	super mouseMove: localEvt.
	editView scrollSelectionIntoView: localEvt.
]

{ #category : #editing }
TextMorphForEditView >> cancelEdits [
	"The message is sent when the user hits enter or Cmd-L.
	Cancel the current contents and end editing."
	self releaseParagraph.
	editView cancel
]

{ #category : #accessing }
TextMorphForEditView >> caretColor [
	^ self valueOfProperty: #caretColor ifAbsent: [Color red]
]

{ #category : #accessing }
TextMorphForEditView >> caretColor: aColor [
	self
		setProperty: #caretColor
		toValue: aColor.
]

{ #category : #'objects from disk' }
TextMorphForEditView >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	acceptOnCR ifNil: [acceptOnCR := false].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #private }
TextMorphForEditView >> createParagraph [

	super createParagraph.
	
	paragraph
		caretColor: self caretColor;
		selectionColor: self selectionColor;
		unfocusedSelectionColor: self unfocusedSelectionColor.
		
	^ paragraph
]

{ #category : #layout }
TextMorphForEditView >> doLayoutIn: layoutBounds [

	| shouldRestoreSelection |
	self flag: #workaround. "mt: The combination of 'releaseParagraph; paragraph' resets the selection. We should find a better way for this in the future. Sigh...."
	
	shouldRestoreSelection := paragraph isNil.
	
	super doLayoutIn: layoutBounds.
	
	shouldRestoreSelection ifTrue: [
		self editView ifNotNil: [:view |
			view restoreSelectionInterval]].
]

{ #category : #drawing }
TextMorphForEditView >> drawNullTextOn: aCanvas [
	"Just run the normal code to show selection in a window"
	aCanvas paragraph: self paragraph bounds: bounds color: color

]

{ #category : #'edit view' }
TextMorphForEditView >> editView [
	^ editView
]

{ #category : #macpal }
TextMorphForEditView >> flash [
	^ editView flash
]

{ #category : #editing }
TextMorphForEditView >> handleInteraction: interActionBlock fromEvent: evt [
	"Overridden to pass along a model to the editor for, eg, link resolution, doits, etc"

	self editor model: editView model.  "For evaluateSelection, etc"
	^ super handleInteraction: interActionBlock fromEvent: evt
]

{ #category : #editing }
TextMorphForEditView >> hasUnacceptedEdits: aBoolean [
	"Set the hasUnacceptedEdits flag in my view."

	editView hasUnacceptedEdits: aBoolean
]

{ #category : #initialization }
TextMorphForEditView >> initialize [
	
	super initialize.
	
	self acceptOnCR: false.
	self dragEnabled: self class draggableTextSelection.
	self dropEnabled: self class draggableTextSelection.
]

{ #category : #'event handling' }
TextMorphForEditView >> keyStroke: evt [
	| view |
	
	editView deleteBalloon.
	self editor model: editView model.  "For evaluateSelection"
	view := editView.  "Copy into temp for case of a self-mutating doit"
	(acceptOnCR and: [evt keyCharacter = Character cr])
		ifTrue: [^ self editor accept].

	view hasUserEdited: false.
	super keyStroke: evt.
	view scrollSelectionIntoView.
	
	view hasUserEdited
		ifTrue: [	view textEdited: self contents].
]

{ #category : #'event handling' }
TextMorphForEditView >> keyboardFocusChange: weHaveFocus [ 
	"Overwritten because we do not want to release the editor if we do not have the focus. Editors and their paragraphs store the text selection, which we want to reuse after getting keyboard focus again. This supports keyboard navigation."

	paragraph ifNotNil: [:para | para focused: weHaveFocus].
	
	weHaveFocus
		ifFalse: [self stopBlinking]
		ifTrue: [
			self hasFocus
				ifFalse: [self editor "forces install"].
			Editor blinkingCursor
				ifTrue: [self startBlinking]
				ifFalse: [self resetBlinkCursor "ensure caret visible"]].
			
	self changed.

	"Tell my edit-view about this because I am his delegate."
	self editView keyboardFocusChange: weHaveFocus.

]

{ #category : #'event handling' }
TextMorphForEditView >> mouseDown: event [

	event yellowButtonPressed ifTrue: [
		(self editor yellowButtonDown: event) ifTrue:[^self].
		^ editView yellowButtonActivity: event shiftPressed].
	^ super mouseDown: event

]

{ #category : #'event handling' }
TextMorphForEditView >> mouseMove: evt [
	| editEvt |
	super mouseMove: evt.
	evt redButtonPressed ifFalse: [^ self].
	editEvt := evt transformedBy: (self transformedFrom: editView) inverseTransformation.
	(editEvt position y between: editView top and: editView bottom) ifFalse:[
		"Start auto-scrolling"
		self startStepping: #autoScrollView:
			at: Time millisecondClockValue
			arguments: (Array with: editEvt)
			stepTime: 100. "fast enough"
	] ifTrue:[
		self stopSteppingSelector: #autoScrollView:.
	].
]

{ #category : #'event handling' }
TextMorphForEditView >> mouseUp: evt [
	super mouseUp: evt.
	self stopSteppingSelector: #autoScrollView:.
	editView scrollSelectionIntoView: evt.

	self flag: #ImmPlugin.
	"self setCompositionWindow."

]

{ #category : #'Multilingual-ImmPlugin' }
TextMorphForEditView >> preferredKeyboardPosition [

	| pos |
	self flag: #ImmPlugin.
	pos := super preferredKeyboardPosition.
	^ pos + (self boundsInWorld) topLeft.

]

{ #category : #accessing }
TextMorphForEditView >> selectionColor [
	^ self valueOfProperty: #selectionColor ifAbsent: [Color blue muchLighter]
]

{ #category : #accessing }
TextMorphForEditView >> selectionColor: aColor [

	self
		setProperty: #selectionColor
		toValue: aColor.
]

{ #category : #'edit view' }
TextMorphForEditView >> setEditView: editPane [
	editView := editPane
]

{ #category : #'debug and other' }
TextMorphForEditView >> tempCommand [
	"Smalltalk browseAllImplementorsOf: #tempCommand"
	"Place your definition for tempCommand for this class here"
]

{ #category : #accessing }
TextMorphForEditView >> unfocusedSelectionColor [
	^ self valueOfProperty: #unfocusedSelectionColor ifAbsent: [Color blue muchLighter]
]

{ #category : #accessing }
TextMorphForEditView >> unfocusedSelectionColor: aColor [

	self
		setProperty: #unfocusedSelectionColor
		toValue: aColor.
]

{ #category : #'dropping\/grabbing' }
TextMorphForEditView >> wantsDroppedMorph: aMorph event: evt [

	^ ((super wantsDroppedMorph: aMorph event: evt)
		and: [aMorph isKindOf: TransferMorph])
		and: [aMorph passenger isString or: [aMorph passenger isText]]
]

{ #category : #'event handling' }
TextMorphForEditView >> wouldAcceptKeyboardFocusUponTab [
	"Answer whether the receiver would be a happy inheritor of keyboard focus if tab were hit in an enclosing playfield under propitious circumstances.  Does not make sense for this kind of morph, which is encased in a window"

	^ false
]
