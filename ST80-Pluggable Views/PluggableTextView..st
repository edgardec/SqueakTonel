"
A PluggableTextView gets its content from the model. This allows the same kind of view to be used in different situations, thus avoiding a proliferation of gratuitous view and controller classes. See the class comment for PluggableListView.

Selectors are:

		getTextSel		fetch the original text from the model
		setTextSel		submit new text to the model when user ""accepts""
		getSelectionSel	get the current text selection range
		getMenuSel		get the pane-specific, 'yellow-button' menu

	Any of the above selectors can be nil, meaning that the model does not supply behavior for the given action, and the default behavior should be used. For example, if setTextSel is nil then this view is consider read-only.

	The model informs a pluggable view of changes by sending #changed: to itself with getTextSel as a parameter. The view informs the model of selection changes by sending setTextSel to it with the newly selected item as a parameter, and invokes menu actions on the model via getMenuSel.

"
Class {
	#name : #PluggableTextView,
	#superclass : #StringHolderView,
	#instVars : [
		'getTextSelector',
		'setTextSelector',
		'getSelectionSelector',
		'getMenuSelector',
		'hasEditingConflicts'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #'instance creation' }
PluggableTextView class >> on: anObject text: getTextSel accept: setTextSel [

	^ self on: anObject
		text: getTextSel
		accept: setTextSel
		readSelection: nil
		menu: nil

]

{ #category : #'instance creation' }
PluggableTextView class >> on: anObject text: getTextSel accept: setTextSel readSelection: getSelectionSel menu: getMenuSel [

	^ self new on: anObject
		text: getTextSel
		accept: setTextSel
		readSelection: getSelectionSel
		menu: getMenuSel

]

{ #category : #'object fileIn' }
PluggableTextView >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	hasEditingConflicts ifNil: [hasEditingConflicts := false].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #initialization }
PluggableTextView >> defaultControllerClass [ 

	^ PluggableTextController

]

{ #category : #'model access' }
PluggableTextView >> getMenu: shiftKeyDown [
	"Answer the menu for this text view, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."

	| menu |
	getMenuSelector == nil ifTrue: [^ nil].
	menu := CustomMenu new.
	getMenuSelector numArgs = 1
		ifTrue: [^ model perform: getMenuSelector with: menu].
	getMenuSelector numArgs = 2
		ifTrue: [^ model perform: getMenuSelector with: menu with: shiftKeyDown].
	^ self error: 'The getMenuSelector must be a 1- or 2-keyword symbol'
]

{ #category : #'model access' }
PluggableTextView >> getSelection [
	"Answer the model's selection interval."

	getSelectionSelector == nil ifTrue: [^ 1 to: 0].  "null selection"
	^ getSelectionSelector ifNotNil: [model perform: getSelectionSelector]

]

{ #category : #'model access' }
PluggableTextView >> getText [ 
	"Answer the list to be displayed."
	| txt |
	getTextSelector == nil ifTrue: [^ Text new].
	txt := model perform: getTextSelector.
	txt == nil ifTrue: [^ Text new].
	self hasUnacceptedEdits: false.	"clean now"
	^ txt
]

{ #category : #'model access' }
PluggableTextView >> getTextSelector [
	"This is sent to the model to find out what text to display"

	^ getTextSelector
]

{ #category : #updating }
PluggableTextView >> hasEditingConflicts [
	"Return true if a conflicting edit to the same code (typically) is known to have occurred after the current contents started getting edited"

	^ hasEditingConflicts == true
]

{ #category : #updating }
PluggableTextView >> hasEditingConflicts: aBoolean [
	hasEditingConflicts := aBoolean
]

{ #category : #updating }
PluggableTextView >> hasUnacceptedEdits: aBoolean [
	super hasUnacceptedEdits: aBoolean.
	aBoolean ifFalse: [hasEditingConflicts := false]
]

{ #category : #initialization }
PluggableTextView >> initialize [ 
	super initialize.
	hasEditingConflicts := false
]

{ #category : #'model access' }
PluggableTextView >> isReadOnlyView [

	^ setTextSelector == nil

]

{ #category : #testing }
PluggableTextView >> isTextView [
	"True if the reciever is a view on a text model, such as a view on a TranscriptStream"
	^true
]

{ #category : #'model access' }
PluggableTextView >> model: aLockedModel [ 
	"Refer to the comment in View|model:."
 
	self model: aLockedModel controller: controller.
	self editString: self getText.

]

{ #category : #initialization }
PluggableTextView >> on: anObject text: getTextSel accept: setTextSel readSelection: getSelectionSel menu: getMenuSel [

	self model: anObject.
	getTextSelector := getTextSel.
	setTextSelector := setTextSel.
	getSelectionSelector := getSelectionSel.
	getMenuSelector := getMenuSel.
	self borderWidth: 1.
	self editString: self getText.
	self setSelection: self getSelection.


]

{ #category : #'controller access' }
PluggableTextView >> selectionInterval [

  ^self controller selectionInterval
]

{ #category : #initialization }
PluggableTextView >> setSelection: sel [

	controller selectFrom: sel first to: sel last.

]

{ #category : #'model access' }
PluggableTextView >> setText: textToAccept from: ctlr [
	"Inform the model of text to be accepted, and return true if OK.
	Any errors should be reported to the controller, ctlr."
	setTextSelector == nil ifTrue: [^ true].
	setTextSelector numArgs = 2
		ifTrue: [^ model perform: setTextSelector with: textToAccept with: ctlr]
		ifFalse: [^ model perform: setTextSelector with: textToAccept]
]

{ #category : #updating }
PluggableTextView >> update: aSymbol [
	"Refer to the comment in View|update:. Do nothing if the given symbol does not match any action. "

	aSymbol == #wantToChange ifTrue:
			[self canDiscardEdits ifFalse: [self promptForCancel].  ^ self].
	aSymbol == #flash ifTrue: [^ controller flash].
	aSymbol == getTextSelector ifTrue: [^ self updateDisplayContents].
	aSymbol == getSelectionSelector ifTrue: [^ self setSelection: self getSelection].
	aSymbol == #clearUserEdits ifTrue: [^ self hasUnacceptedEdits: false].
	(aSymbol == #autoSelect and: [getSelectionSelector ~~ nil]) ifTrue:
			[ParagraphEditor abandonChangeText.	"no replacement!"
			^ controller setSearch: model autoSelectString;
					againOrSame: true].
	aSymbol == #appendEntry ifTrue:
			[^ controller doOccluded: [controller appendEntry]].
	aSymbol == #clearText ifTrue:
			[^ controller doOccluded:
				[controller changeText: Text new]].
	aSymbol == #bs ifTrue:
			[^ controller doOccluded:
				[controller bsText]].
	aSymbol == #codeChangedElsewhere ifTrue:
			[^ self hasEditingConflicts: true].
	aSymbol == #saveContents ifTrue:
			[^self controller saveContentsInFile].
	aSymbol == #close ifTrue:
			[^self topView controller closeAndUnscheduleNoTerminate].
	aSymbol == #acceptChanges ifTrue:
			[^ self controller accept].
	aSymbol == #revertChanges ifTrue:
			[^ self controller cancel].
]

{ #category : #updating }
PluggableTextView >> update: aSymbol with: arg1 [
	aSymbol == #editString ifTrue:[
		self editString: arg1.
		^self hasUnacceptedEdits: true.
	].
	^super update: aSymbol with: arg1
]

{ #category : #'model access' }
PluggableTextView >> updateDisplayContents [

	self editString: self getText.
	self displayView.
	self setSelection: self getSelection.

]
