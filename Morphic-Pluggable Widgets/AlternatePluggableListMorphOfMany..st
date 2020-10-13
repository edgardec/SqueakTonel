"
This is a multi-select list that is more conventional in its behavior than PluggableListMorphOfMany.  It utilizes a shift+click mechanism for selecting ranges, and control+click for toggling individual selections.  This list also allows fast mouse swipes without missing any message selections.
"
Class {
	#name : #AlternatePluggableListMorphOfMany,
	#superclass : #PluggableListMorph,
	#instVars : [
		'getSelectionListSelector',
		'setSelectionListSelector'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #'instance creation' }
AlternatePluggableListMorphOfMany class >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel [
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
AlternatePluggableListMorphOfMany class >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel keystroke: keyActionSel [ 
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
AlternatePluggableListMorphOfMany >> changeModelSelection: anInteger [
	"Change the model's selected item index to be anInteger."

	^self
		changeModelSelection: anInteger
		shifted: Sensor shiftPressed
		controlled: Sensor controlKeyPressed

]

{ #category : #'model access' }
AlternatePluggableListMorphOfMany >> changeModelSelection: anInteger shifted: shiftedBoolean controlled: controlledBoolean [
	"Change the model's selected item index to be anInteger."

	setIndexSelector ifNotNil:
		[ model 
			perform: setIndexSelector 
			with: anInteger
			with: shiftedBoolean
			with: controlledBoolean ]

]

{ #category : #testing }
AlternatePluggableListMorphOfMany >> hasMultiSelection [

	^ true
]

{ #category : #'model access' }
AlternatePluggableListMorphOfMany >> itemSelectedAmongMultiple: viewIndex [
	^self listSelectionAt: (self modelIndexFor: viewIndex)
]

{ #category : #'model access' }
AlternatePluggableListMorphOfMany >> listSelectionAt: index [
	getSelectionListSelector ifNil:[^false].
	^model perform: getSelectionListSelector with: index
]

{ #category : #'model access' }
AlternatePluggableListMorphOfMany >> listSelectionAt: index put: value [
	setSelectionListSelector ifNil:[^false].
	^model perform: setSelectionListSelector with: index with: value
]

{ #category : #'event handling' }
AlternatePluggableListMorphOfMany >> mouseDown: event [
	| row |

	event yellowButtonPressed ifTrue: [^ self yellowButtonActivity: event shiftPressed].

	row := self rowAtLocation: event position.
	
	row = 0 ifTrue: [^super mouseDown: event].

	model okToChange ifFalse: [^ self].  "No change if model is locked"

	"Inform model of selected item and let it toggle."
	self
		changeModelSelection: (self modelIndexFor: row)
		shifted: event shiftPressed
		controlled: event controlKeyPressed.


"
	event hand releaseMouseFocus: aMorph.
	submorphs do: [ :each | each changed ]
"
]

{ #category : #'event handling' }
AlternatePluggableListMorphOfMany >> mouseLeaveDragging: anEvent [
	"Dragging means changing the list's multi-selection state. Thus, there is no support for drag-and-drop of elements within a selection."
	
	self hoverRow: nil.
	self resetPotentialDropRow.
]

{ #category : #'event handling' }
AlternatePluggableListMorphOfMany >> mouseMove: event [ 
	"The mouse has moved, as characterized by the event provided.  Adjust the scrollbar, and alter the selection as appropriate"

	| oldIndex oldVal row |
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

	model okToChange ifFalse: [^self].	"No change if model is locked"

	"Set meaning for subsequent dragging of selection"
	oldIndex := self getCurrentSelectionIndex.
	oldIndex ~= 0 ifTrue: [oldVal := self listSelectionAt: oldIndex].
	"Need to restore the old one, due to how model works, and set new one."
	oldIndex ~= 0 ifTrue: [self listSelectionAt: oldIndex put: oldVal].

	"Inform model of selected item and let it toggle."
	self 
		changeModelSelection: (self modelIndexFor: row)
		shifted: true
		controlled: true.
	submorphs do: [:each | each changed]
]

{ #category : #'event handling' }
AlternatePluggableListMorphOfMany >> mouseUp: event [
	
	event hand newKeyboardFocus: self. 
	hasFocus := true.
	Cursor normal show.
]

{ #category : #initialization }
AlternatePluggableListMorphOfMany >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel keystroke: keyActionSel [ 
	"setup a whole load of pluggability options"

	getSelectionListSelector := getListSel.
	setSelectionListSelector := setListSel.
	self 
		on: anObject
		list: listSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: keyActionSel
]

{ #category : #updating }
AlternatePluggableListMorphOfMany >> update: aSymbol [ 

	aSymbol == #allSelections ifTrue: [
		"Convenient - yet hard-coded - way to refresh all selections."
		super update: getIndexSelector.
		^ self changed].
	aSymbol == getSelectionListSelector ifTrue: [
		^ self changed].
	
	super update: aSymbol.
]
