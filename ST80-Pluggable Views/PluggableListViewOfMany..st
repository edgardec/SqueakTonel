Class {
	#name : #PluggableListViewOfMany,
	#superclass : #PluggableListView,
	#instVars : [
		'getSelectionListSelector',
		'setSelectionListSelector'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #'instance creation' }
PluggableListViewOfMany class >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel [
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
PluggableListViewOfMany class >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel keystroke: keyActionSel [ 
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

{ #category : #displaying }
PluggableListViewOfMany >> deEmphasizeView [ 
	"Refer to the comment in View|deEmphasizeView."
	selection := 0.
	1 to: self maximumSelection do:
		[:i | selection := i.
		(self listSelectionAt: i) ifTrue: [self deEmphasizeSelectionBox]].
	selection := 0
]

{ #category : #'controller access' }
PluggableListViewOfMany >> defaultControllerClass [ 

	^ PluggableListControllerOfMany

]

{ #category : #displaying }
PluggableListViewOfMany >> highlightFrom: start to: stop [
	(start == nil or: [stop == nil]) ifTrue: [^ self displayView].
	start to: stop do:
		[:i | selection := i.
		(self listSelectionAt: selection) ifTrue: [self displaySelectionBox]].
	selection := 0
]

{ #category : #selecting }
PluggableListViewOfMany >> listSelectionAt: index [
	getSelectionListSelector ifNil:[^false].
	^model perform: getSelectionListSelector with: index
]

{ #category : #selecting }
PluggableListViewOfMany >> listSelectionAt: index put: value [
	setSelectionListSelector ifNil:[^false].
	^model perform: setSelectionListSelector with: index with: value
]

{ #category : #selecting }
PluggableListViewOfMany >> moveSelectionBox: anInteger [ 
	"Presumably the selection has changed to be anInteger. Deselect the 
	previous selection and display the new one, highlighted."
	selection ~= anInteger
		ifTrue: 
			[selection := anInteger.
			self displaySelectionBox]
]

{ #category : #initialization }
PluggableListViewOfMany >> on: anObject list: listSel primarySelection: getSelectionSel changePrimarySelection: setSelectionSel listSelection: getListSel changeListSelection: setListSel menu: getMenuSel keystroke: keyActionSel [
	"setup a whole load of pluggability options"
	getSelectionListSelector := getListSel.
	setSelectionListSelector := setListSel.
	super on: anObject list: listSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel

]

{ #category : #displaying }
PluggableListViewOfMany >> scrollBy: anInteger [
	"This is a possible way to intercept what ListOfManyController did to get multiple selections to show.  Feel to replace this."

	| ans |
	ans := super scrollBy: anInteger.
"	self displaySelectionBox."
	^ ans
]

{ #category : #selecting }
PluggableListViewOfMany >> selection [
	"Have to override normal controller smarts about deselection"
	^ 0
]

{ #category : #updating }
PluggableListViewOfMany >> update: aSymbol [ 
	aSymbol == getListSelector
		ifTrue: [self list: self getList.
			^ self displayView; emphasizeView].
	aSymbol == getSelectionSelector
		ifTrue: [^ self displayView; emphasizeView].
	aSymbol == #allSelections
		ifTrue: [^ self displayView; emphasizeView].
	^ super update: aSymbol
]
