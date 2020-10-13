"
A pluggable list view gets its content from the model. This allows the same kind of view to be used in different situations, thus avoiding a proliferation of gratuitous view and controller classes. Selector usage is:

		getListSel		fetch the list of items (strings) to be displayed
		getSelectionSel	get the currently selected item
		setSelectionSel	set the currently selected item (takes an argument)
		getMenuSel		get the pane-specific, 'yellow-button' menu
		keyActionSel	process a keystroke typed in this pane (takes an argument)

	Any of the above selectors can be nil, meaning that the model does not supply behavior for the given action, and the default behavior should be used. However, if getListSel is nil, the default behavior just provides an empty list, which makes for a rather dull list view!

	The model informs a pluggable view of changes by sending #changed: to itself with getListSel or getSelectionSel as a parameter. The view informs the model of selection changes by sending setSelectionSel to it with the newly selected item as a parameter, and invokes menu and keyboard actions on the model via getMenuSel and keyActionSel.

	Pluggability allows a single model object to have pluggable list views on multiple aspects of itself. For example, an object representing one personal music library might be organized as a three-level hierarchy: the types of music, the titles within a given type, and the songs on a given title. Pluggability allows one to easily build a multipane browser for this object with separate list views for the music type, title, and song.

	AutoDeselect is a feature, normally set to true, that will tell the model that there is no selection if you click on an item that is currently selected.  If autoDeselect is false, then the model will simply be told to select the same item again.
"
Class {
	#name : #PluggableListView,
	#superclass : #ListView,
	#instVars : [
		'getListSelector',
		'getSelectionSelector',
		'setSelectionSelector',
		'getMenuSelector',
		'getMenuTitleSelector',
		'keystrokeActionSelector',
		'autoDeselect',
		'items'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #'instance creation' }
PluggableListView class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self new
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: nil
		keystroke: #arrowKey:from:		"default"

]

{ #category : #'instance creation' }
PluggableListView class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self new
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: #arrowKey:from:		"default"


]

{ #category : #'instance creation' }
PluggableListView class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self new
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: keyActionSel

]

{ #category : #initialization }
PluggableListView >> autoDeselect: trueOrFalse [
	"Enable/disable autoDeselect (see class comment)"
	autoDeselect := trueOrFalse.
]

{ #category : #'model access' }
PluggableListView >> changeModelSelection: anInteger [
	"Change the model's selected item index to be anInteger."
	| newIndex |
	newIndex := anInteger.
	(autoDeselect == nil or: [autoDeselect]) ifTrue:
		[getSelectionSelector ifNotNil:
			[(model perform: getSelectionSelector) = anInteger ifTrue:
				["Click on existing selection deselects"
				newIndex := 0]]].

	setSelectionSelector ifNotNil:
		[model perform: setSelectionSelector with: newIndex].
]

{ #category : #'controller access' }
PluggableListView >> defaultControllerClass [ 

	^ PluggableListController

]

{ #category : #initialization }
PluggableListView >> font: aFontOrNil [

	super font: aFontOrNil.
	self list: self getList.  "update display"

]

{ #category : #'model access' }
PluggableListView >> getCurrentSelectionIndex [
	"Answer the index of the current selection."

	getSelectionSelector == nil ifTrue: [^ 0].
	^ model perform: getSelectionSelector
]

{ #category : #'model access' }
PluggableListView >> getList [ 
	"Answer the list to be displayed."

	| lst |
	getListSelector == nil ifTrue: [^ #()].
	lst := model perform: getListSelector.
	lst == nil ifTrue: [^ #()].
	^ lst
]

{ #category : #'model access' }
PluggableListView >> getListSelector [
	^ getListSelector
]

{ #category : #'model access' }
PluggableListView >> getMenu: shiftKeyDown [
	"Answer the menu for this text view, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."
	| menu aMenu |
	getMenuSelector == nil ifTrue: [^ nil].
	menu := CustomMenu new.
	getMenuSelector numArgs = 1
		ifTrue:
			[aMenu := model perform: getMenuSelector with: menu.
			getMenuTitleSelector ifNotNil: [aMenu title: (model perform: getMenuTitleSelector)].
			^ aMenu].
	getMenuSelector numArgs = 2
		ifTrue: [aMenu := model perform: getMenuSelector with: menu with: shiftKeyDown.
				getMenuTitleSelector ifNotNil: [aMenu title: (model perform: getMenuTitleSelector)].
				^ aMenu].
	^ self error: 'The getMenuSelector must be a 1- or 2-keyword symbol'
]

{ #category : #'model access' }
PluggableListView >> handleKeystroke: aChar [
	"Answer the menu for this list view."

	| args aSpecialKey |

	aSpecialKey := aChar asciiValue.
	aSpecialKey < 32 ifTrue: [ self specialKeyPressed: aSpecialKey. ^nil ].
	keystrokeActionSelector ifNil: [^ nil].

	controller controlTerminate.
	(args := keystrokeActionSelector numArgs) = 1
		ifTrue: [model perform: keystrokeActionSelector with: aChar.
				^ controller controlInitialize].
	args = 2
		ifTrue: [model perform: keystrokeActionSelector with: aChar with: self.
				^ controller controlInitialize].
	^ self error: 'The keystrokeActionSelector must be a 1- or 2-keyword symbol'
]

{ #category : #initialization }
PluggableListView >> list: arrayOfStrings [
	"Set the receivers items to be the given list of strings
	The instance variable 'items' holds the original list. The instance variable 'list' is a paragraph constructed from this list."

	((items == arrayOfStrings) "fastest" or: [items = arrayOfStrings]) ifTrue: [^ self].
	items := arrayOfStrings.
	isEmpty := arrayOfStrings isEmpty.

	"add top and bottom delimiters"
	list := ListParagraph
		withArray:
			(Array streamContents: [:s |
				s nextPut: topDelimiter.
				arrayOfStrings do:
					[:item | item == nil ifFalse:
						[(item isMemberOf: MethodReference)  "A very specific fix for MVC"
							ifTrue: [s nextPut: item asStringOrText]
							ifFalse: [s nextPut: item]]].
				s nextPut: bottomDelimiter])
		 style: self assuredTextStyle.

	selection := self getCurrentSelectionIndex.
	self positionList.
]

{ #category : #initialization }
PluggableListView >> menu: getMenuSel [

	getMenuSelector := getMenuSel
]

{ #category : #initialization }
PluggableListView >> menuTitleSelector: getMenuTitleSel [
	getMenuTitleSelector := getMenuTitleSel
]

{ #category : #initialization }
PluggableListView >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [

	self model: anObject.
	getListSelector := getListSel.
	getSelectionSelector := getSelectionSel.
	setSelectionSelector := setSelectionSel.
	getMenuSelector := getMenuSel.
	keystrokeActionSelector := keyActionSel.
	autoDeselect := true.
	self borderWidth: 1.
	self list: self getList.
]

{ #category : #'model access' }
PluggableListView >> setSelectionSelectorIs: aSelector [
	^ aSelector == setSelectionSelector
]

{ #category : #'model access' }
PluggableListView >> specialKeyPressed: keyEvent [
	"Process the up and down arrows in a list pane."
     | oldSelection nextSelection max min howMany |

	(#(1 4 11 12 30 31) includes: keyEvent) ifFalse: [ ^ false ].

     oldSelection := self getCurrentSelectionIndex.
     nextSelection := oldSelection.
     max := self maximumSelection.
     min := self minimumSelection.
     howMany := self numSelectionsInView.	"get this exactly??"

     keyEvent = 31 ifTrue:
		["down-arrow; move down one, wrapping to top if needed"
		nextSelection := oldSelection + 1.
		nextSelection > max ifTrue: [nextSelection := 1]].

     keyEvent = 30 ifTrue:
		["up arrow; move up one, wrapping to bottom if needed"
		nextSelection := oldSelection - 1.
		nextSelection < 1 ifTrue: [nextSelection := max]].

     keyEvent = 1  ifTrue: [nextSelection := 1].  "home"
     keyEvent = 4  ifTrue: [nextSelection := max].   "end"
     keyEvent = 11 ifTrue: [nextSelection := min max: (oldSelection - howMany)].  "page up"
     keyEvent = 12  ifTrue: [nextSelection := (oldSelection + howMany) min: max].  "page down"
     nextSelection = oldSelection  ifFalse:
		[model okToChange
			ifTrue:
				[self changeModelSelection: nextSelection.
				"self controller moveMarker"]].
	
	^true
			
]

{ #category : #updating }
PluggableListView >> update: aSymbol [ 
	"Refer to the comment in View|update:."
	aSymbol == getListSelector ifTrue:
		[self list: self getList.
		self displayView.
		self displaySelectionBox.
		^self].
	aSymbol == getSelectionSelector ifTrue:
		[^ self moveSelectionBox: self getCurrentSelectionIndex].
	aSymbol == #startNewBrowser ifTrue:
		[(self setSelectionSelectorIs: #classListIndex:) ifTrue: [
			"A SelectorBrowser is about to open a new Browser on a class"
			self controller controlTerminate]]

]

{ #category : #updating }
PluggableListView >> verifyContents [
	| newItems existingSelection anIndex |
	"Called on window reactivation to react to possible structural changes.  Update contents if necessary."

	newItems := self getList.
	((items == newItems) "fastest" or: [items = newItems]) ifTrue: [^ self].
	self flash.  "list has changed beneath us; could get annoying, but hell"
	existingSelection := list stringAtLineNumber: (selection + (topDelimiter ifNil: [0] ifNotNil: [1])).  "account for cursed ------ row"
	self list: newItems.

	(newItems size > 0 and: [newItems first isKindOf: Symbol]) ifTrue:
		[existingSelection := existingSelection asSymbol].
	(anIndex := newItems indexOf: existingSelection ifAbsent: [nil])
		ifNotNil:
			[model noteSelectionIndex: anIndex for: getListSelector.]
		ifNil:
			[self changeModelSelection: 0].
	selection := 0. " to display the list without selection "
	self displayView.
	self update: getSelectionSelector.

]
