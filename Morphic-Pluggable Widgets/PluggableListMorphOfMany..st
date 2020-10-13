"
A variant of its superclass that allows multiple items to be selected simultaneously.  There is still a distinguished element which is selected, but each other element in the list may be flagged on or off.

"
Class {
	#name : #PluggableListMorphOfMany,
	#superclass : #PluggableListMorph,
	#instVars : [
		'dragOnOrOff',
		'getSelectionListSelector',
		'setSelectionListSelector'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #'instance creation' }
PluggableListMorphOfMany class >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel [
	^ self new
		on: anObject
		list: listSel
		primarySelection: getSelectionSel
		changePrimarySelection: setSelectionSel
		listSelection: getListSel
		changeListSelection: setListSel
		menu: getMenuSel
		keystroke: #arrowKey:from:		"default"
]

{ #category : #'instance creation' }
PluggableListMorphOfMany class >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel keystroke: keyActionSel [ 
	^ self new
		on: anObject
		list: listSel
		primarySelection: getSelectionSel
		changePrimarySelection: setSelectionSel
		listSelection: getListSel
		changeListSelection: setListSel
		menu: getMenuSel
		keystroke: keyActionSel
]

{ #category : #'model access' }
PluggableListMorphOfMany >> basicKeyPressed: aCharacter [
	"Maps [space] key to be a special key."
	
	aCharacter = Character space
		ifTrue: [self specialKeyPressed: aCharacter asciiValue]
		ifFalse: [super basicKeyPressed: aCharacter].
]

{ #category : #testing }
PluggableListMorphOfMany >> hasMultiSelection [

	^ true
]

{ #category : #'model access' }
PluggableListMorphOfMany >> itemSelectedAmongMultiple: viewIndex [
	^self listSelectionAt: (self modelIndexFor: viewIndex)
]

{ #category : #'model access' }
PluggableListMorphOfMany >> listSelectionAt: index [
	getSelectionListSelector ifNil:[^false].
	^model perform: getSelectionListSelector with: index
]

{ #category : #'model access' }
PluggableListMorphOfMany >> listSelectionAt: index put: value [
	setSelectionListSelector ifNil:[^false].
	^model perform: setSelectionListSelector with: index with: value
]

{ #category : #'event handling' }
PluggableListMorphOfMany >> mouseDown: event [
	| row index |
	event yellowButtonPressed ifTrue: [^ self yellowButtonActivity: event shiftPressed].
	row := self rowAtLocation: event position.

	row = 0 ifTrue: [^super mouseDown: event].
	index := self modelIndexFor: row.

	model okToChange ifFalse: [^ self].  "No change if model is locked"

	self changeModelSelection: index.

	"Set meaning for subsequent dragging of selection"
	self
		listSelectionAt: index
		put: (dragOnOrOff := (self listSelectionAt: index) not)

]

{ #category : #'event handling' }
PluggableListMorphOfMany >> mouseMove: event [ 
	"The mouse has moved, as characterized by the event provided.  Adjust the scrollbar, and alter the selection as appropriate"

	| row index |
	event position y < self top 
		ifTrue: 
			[scrollBar scrollUp: 1.
			row := self rowAtLocation: scroller topLeft + (1 @ 1)]
		ifFalse: 
			[row := event position y > self bottom 
				ifTrue: 
					[scrollBar scrollDown: 1.
					self rowAtLocation: scroller bottomLeft + (1 @ -1)]
				ifFalse: [ self rowAtLocation: event position]].
	row = 0 ifTrue: [^super mouseDown: event].
	index := self modelIndexFor: row.

	model okToChange ifFalse: [^self].	"No change if model is locked"

	dragOnOrOff ifNil: [
		"Was not set at mouse down, which means the mouse must have gone down in an area where there was no list item"
		dragOnOrOff := (self listSelectionAt: index) not].

	self changeModelSelection: index.
	self listSelectionAt: index put: dragOnOrOff.
]

{ #category : #'event handling' }
PluggableListMorphOfMany >> mouseUp: event [

	dragOnOrOff := nil.  "So improperly started drags will have not effect"

	event hand newKeyboardFocus: self. 
	hasFocus := true.
	Cursor normal show.
]

{ #category : #initialization }
PluggableListMorphOfMany >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel keystroke: keyActionSel [
	"setup a whole load of pluggability options"
	
	getSelectionListSelector := getListSel.
	setSelectionListSelector := setListSel.
	super
		on: anObject
		list: listSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: keyActionSel.
]

{ #category : #'model access' }
PluggableListMorphOfMany >> specialKeyPressed: asciiValue [
	"Toggle the selection on [space]."
	
	asciiValue = Character space asciiValue
		ifTrue: [ | index |
			index :=  self getCurrentSelectionIndex.
			self
				listSelectionAt: index
				put: ((self listSelectionAt: index) not).
			^ self].
		
	super specialKeyPressed: asciiValue.
]

{ #category : #updating }
PluggableListMorphOfMany >> update: aSymbol [ 

	aSymbol == #allSelections ifTrue: [
		"Convenient - yet hard-coded - way to refresh all selections."
		super update: getIndexSelector.
		^ self changed].
	aSymbol == getSelectionListSelector ifTrue: [
		^ self changed].
	
	super update: aSymbol.
]
