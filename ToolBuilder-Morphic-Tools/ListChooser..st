"
I am a simple dialog to allow the user to pick from a list of strings or symbols.
I support keyboard and mouse navigation, and interactive filtering of the displayed items.

You can specify whether you want the index, or the value of the selected item. If you're interested in the value, you can also allow users to Add a new value not in the list.

cmd-s or <enter> or double-click answers the currently selected item's value/index;
cmd-l or <escape> or closing the window answers nil/zero.

Now using ToolBuilder, so needs Morphic-MAD.381.

Released under the MIT Licence.
"
Class {
	#name : #ListChooser,
	#superclass : #Model,
	#instVars : [
		'selectedIndex',
		'items',
		'searchText',
		'addAllowed',
		'result',
		'title',
		'listMorph',
		'dialogMorph'
	],
	#category : #'ToolBuilder-Morphic-Tools'
}

{ #category : #'ChooserTool compatibility' }
ListChooser class >> chooseFrom: aList [
	^ self 
		chooseFrom: aList 
		title: self defaultTitle
]

{ #category : #'ChooserTool compatibility' }
ListChooser class >> chooseFrom: aList title: aString [
	^ self
		chooseIndexFrom: aList 
		title: aString
		addAllowed: false
]

{ #category : #'instance creation' }
ListChooser class >> chooseIndexFrom: aList [
	^ self 
		chooseIndexFrom: aList 
		title: self defaultTitle
]

{ #category : #'instance creation' }
ListChooser class >> chooseIndexFrom: aList title: aString [
	^ self
		chooseIndexFrom: aList 
		title: (aString isEmptyOrNil ifTrue: [ self defaultTitle ] ifFalse: [ aString ])
		addAllowed: false
]

{ #category : #'instance creation' }
ListChooser class >> chooseIndexFrom: aList title: aString addAllowed: aBoolean [
	^ self new
		chooseIndexFrom: aList 
		title: (aString isEmptyOrNil ifTrue: [ self defaultTitle ] ifFalse: [ aString ])
		addAllowed: aBoolean
]

{ #category : #'instance creation' }
ListChooser class >> chooseItemFrom: aList [
	^ self 
		chooseItemFrom: aList 
		title: self defaultTitle
]

{ #category : #'instance creation' }
ListChooser class >> chooseItemFrom: aList title: aString [
	^ self
		chooseItemFrom: aList 
		title: aString
		addAllowed: false
]

{ #category : #'instance creation' }
ListChooser class >> chooseItemFrom: aList title: aString addAllowed: aBoolean [
	^ self new
		chooseItemFrom: aList 
		title: (aString isEmptyOrNil ifTrue: [ self defaultTitle ] ifFalse: [ aString ])
		addAllowed: aBoolean
]

{ #category : #'instance creation' }
ListChooser class >> defaultTitle [
	^ 'Please choose:'
]

{ #category : #examples }
ListChooser class >> testDictionary [
	^ self 
		chooseItemFrom: (Dictionary newFrom: {#a->1. 2->#b.})
		title: 'Pick from Dictionary' "gives values, not keys"
]

{ #category : #examples }
ListChooser class >> testIndex [
	^ self 
		chooseIndexFrom: (Smalltalk classNames , Smalltalk traitNames) asOrderedCollection
		title: 'Pick a class'
]

{ #category : #examples }
ListChooser class >> testItem [
	^ self 
		chooseItemFrom: (Smalltalk classNames , Smalltalk traitNames) asOrderedCollection
		title: 'Pick a class'
]

{ #category : #examples }
ListChooser class >> testItemAdd [
	^ self 
		chooseItemFrom: (Smalltalk classNames , Smalltalk traitNames) asOrderedCollection
		title: 'Pick or Add:'
		addAllowed: true
]

{ #category : #examples }
ListChooser class >> testLongTitle [
	^ self 
		chooseItemFrom: #(this is a list of values that aren/t the point here)
		title: 'Pick from some values from this list'
]

{ #category : #examples }
ListChooser class >> testSet [
	^ self 
		chooseItemFrom: #(a list of values as a Set) asSet
		title: 'Pick from Set'
]

{ #category : #preferences }
ListChooser class >> themeProperties [

	^ super themeProperties,  {
		{ #okColor. 'Colors'. 'Color for the OK button.' }.
		{ #cancelColor. 'Colors'. 'Color for the Cancel button.' }.
		{ #addColor. 'Colors'. 'Color for a normal button.' }.
		{ #disabledColor. 'Colors'. 'Color for a disabled button.' }.
	}
]

{ #category : #actions }
ListChooser >> accept [
	"if the user submits with no valid entry, make them start over"
	
	| choice |
	self canAccept ifFalse: [
		self canAdd ifTrue: [^ self add].
		^ self changed: #textSelection].
	
	choice := self selectedItem.
	
	self canAdd ifTrue: [
		"Ask the user whether to add the new item or choose the list selection."
		(UserDialogBoxMorph
			confirm: 'You can either choose an existing item or add a new one.\What do you want?' translated withCRs
			title: 'Choose or Add' translated
			trueChoice: choice asString
			falseChoice: self searchText asString at: self currentHand position)
				ifNil: ["Cancelled" self result: nil. ^ self]
				ifNotNil: [:answer |
					answer ifTrue: [self result: choice] ifFalse: [self result: self searchText asString]]
		] ifFalse: [self result: choice].
	
	self changed: #close.
]

{ #category : #colors }
ListChooser >> acceptColor [
	
	self canAdd ifTrue: [^ self addColor].
	
	^ self canAccept 
		ifTrue: [ self userInterfaceTheme okColor ifNil: [(Color r: 0.49 g: 0.749 b: 0.49)] ]
		ifFalse: [ self userInterfaceTheme disabledColor ifNil: [Color lightGray] ]
]

{ #category : #colors }
ListChooser >> acceptLabel [

	^ self canAdd
		ifFalse: ['Choose' translated]
		ifTrue: [self canAccept
			ifTrue: ['Choose or Add' translated]
			ifFalse: ['Add' translated]]
]

{ #category : #actions }
ListChooser >> acceptText: someText [
	"the text morph wants to tell us about its contents but I don't care, I'm only interested in the list"
	self accept
]

{ #category : #actions }
ListChooser >> add [
	"if the user submits with no valid entry, make them start over"
	self canAdd ifFalse: [^ self changed: #textSelection].
	self result: self searchText asString.
	self changed: #close.
]

{ #category : #accessing }
ListChooser >> addAllowed [

	^ addAllowed ifNil: [false]
]

{ #category : #accessing }
ListChooser >> addAllowed: anObject [

	addAllowed := anObject
]

{ #category : #colors }
ListChooser >> addColor [
	
	^ self canAdd 
		ifTrue: [ self userInterfaceTheme addColor ifNil: [Color blue muchLighter] ]
		ifFalse: [ self userInterfaceTheme disabledColor ifNil: [Color lightGray] ]
]

{ #category : #updating }
ListChooser >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self
		changed: #okColor;
		changed: #cancelColor;
		changed: #addColor.
]

{ #category : #building }
ListChooser >> buildWith: builder [

	| dialogSpec searchBarHeight listSpec fieldSpec |
	
	searchBarHeight := Preferences standardDefaultTextFont height * 1.75.
	
	dialogSpec := builder pluggableDialogSpec new
		model: self;
		title: #title;
		closeAction: #closed;
		extent: self initialExtent;
		autoCancel: true; "Behave like a pop-up menu. Historical reasons."
		children: OrderedCollection new;
		buttons: OrderedCollection new;
		yourself.
	
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #items; 
		getIndex: #selectedIndex; 
		setIndex: #selectedIndex:; 
		doubleClick: #accept;
		"keystrokePreview: #keyStrokeFromList:;"
		autoDeselect: false;
		filterableList: true;
		clearFilterAutomatically: false;
		name: #list;
		frame: (LayoutFrame fractions: (0@0 corner: 1@1) offsets: (0@searchBarHeight corner: 0@0)).
	dialogSpec children add: listSpec.
	
	fieldSpec := builder pluggableInputFieldSpec new.
	fieldSpec 
		model: self;
		name: #searchText ;
		getText: #searchText;
		editText: #searchText:;
		setText: #acceptText:;
		selection: #textSelection;
		menu: nil;
		indicateUnacceptedChanges: false;
		askBeforeDiscardingEdits: false;
		help: (self addAllowed ifTrue: ['Type new or filter existing...' translated] ifFalse: ['Type to filter existing...' translated]);
		frame: (LayoutFrame fractions: (0@0 corner: 1@0) offsets: (0@0 corner: 0@searchBarHeight)).
	dialogSpec children add: fieldSpec.
	
	"Buttons"
	dialogSpec buttons add: (
		builder pluggableButtonSpec new
			model: self; 
			label: #acceptLabel;
			action: #accept;
			enabled: #canAcceptOrAdd;
			color: #acceptColor).

	dialogSpec buttons add: (
		builder pluggableButtonSpec new
			model: self; 
			label: 'Cancel';
			action: #cancel;
			color: #cancelColor).
		
	dialogMorph := builder build: dialogSpec.
	dialogMorph addKeyboardCaptureFilter: self ; positionOverWidgetNamed: #searchText.
	listMorph := builder widgetAt: #list.
	listMorph allowEmptyFilterResult: true.
	
	^ dialogMorph
]

{ #category : #testing }
ListChooser >> canAccept [
	^ self selectedIndex > 0
]

{ #category : #testing }
ListChooser >> canAcceptOrAdd [
	^ self canAccept or: [self canAdd]
]

{ #category : #testing }
ListChooser >> canAdd [
	^ self addAllowed
		and: [self searchText asString withBlanksTrimmed notEmpty]
		and: [self selectedItem asString ~= self searchText asString]
]

{ #category : #actions }
ListChooser >> cancel [

	self result: nil.
	self changed: #close.
]

{ #category : #colors }
ListChooser >> cancelColor [
	
	^ self userInterfaceTheme cancelColor ifNil: [Color r: 1 g: 0.6 b: 0.588]
]

{ #category : #'initialize-release' }
ListChooser >> chooseIndexFrom: labelList title: aString [
	| choice |
	choice := self chooseItemFrom: labelList title: aString addAllowed: false.
	^ self items indexOf: choice
]

{ #category : #'initialize-release' }
ListChooser >> chooseIndexFrom: labelList title: aString addAllowed: aBoolean [
	| choice |
	choice := self chooseItemFrom: labelList title: aString addAllowed: false.
	self addAllowed: aBoolean.
	^ self items indexOf: choice
]

{ #category : #'initialize-release' }
ListChooser >> chooseItemFrom: labelList title: aString addAllowed: aBoolean [

	self items: labelList asOrderedCollection.
	self title: aString.
	self addAllowed: aBoolean.

	ToolBuilder open: self.
	^ self result
]

{ #category : #actions }
ListChooser >> closed [
	
	self selectedIndex: 0.
]

{ #category : #'event handling' }
ListChooser >> filterEvent: aKeyboardEvent for: aMorph [

	| char |
	aKeyboardEvent isKeystroke ifFalse: [^ aKeyboardEvent].
	aKeyboardEvent anyModifierKeyPressed ifTrue: [^ aKeyboardEvent].
	
	char := aKeyboardEvent keyCharacter.
	
	char = Character backspace
		ifTrue: [self searchText: (self searchText asString ifNotEmpty: [:s | s allButLast]). ^ aKeyboardEvent ignore].
	char = Character delete
		ifTrue: [self searchText: (self searchText asString ifNotEmpty: [:s | s allButFirst]). ^ aKeyboardEvent ignore].
	(char = Character cr or: [char = Character enter])
		ifTrue: [self accept. aKeyboardEvent ignore].
	char = Character escape 
		ifTrue: [self cancel. aKeyboardEvent ignore].
	(char asInteger between: 32 and: 126)
		ifTrue: [self searchText: self searchText asString, char asString. aKeyboardEvent ignore].
	(char = Character arrowUp or: [char = Character arrowDown
		or: [char = Character pageUp or: [char = Character pageDown
		or: [char = Character home or: [char = Character end]]]]])
		ifTrue: [listMorph keyStroke: aKeyboardEvent. ^aKeyboardEvent ignore].
	
	^ aKeyboardEvent
]

{ #category : #building }
ListChooser >> initialExtent [

	| listFont |
	listFont := Preferences standardListFont.
	^ (20 * (listFont widthOf: $m))@(15 * listFont height)
]

{ #category : #accessing }
ListChooser >> items [

	^ items
]

{ #category : #accessing }
ListChooser >> items: anObject [

	items := anObject
]

{ #category : #accessing }
ListChooser >> result [

	^ result
]

{ #category : #accessing }
ListChooser >> result: anObject [

	result := anObject
]

{ #category : #accessing }
ListChooser >> searchText [
	^ searchText ifNil: [ searchText := '' ]
]

{ #category : #accessing }
ListChooser >> searchText: aString [
	searchText := aString.
	listMorph listFilterSet: aString asString.
	
	self changed: #searchText.
	self changed: #canAcceptOrAdd.
	self changed: #acceptLabel.
	self changed: #buttons.
]

{ #category : #accessing }
ListChooser >> selectedIndex [
	^ selectedIndex ifNil: [ self items size min: 1 ]
]

{ #category : #accessing }
ListChooser >> selectedIndex: anInt [
	selectedIndex := anInt.
	self changed: #selectedIndex.
]

{ #category : #accessing }
ListChooser >> selectedItem [

	^  self items at: self selectedIndex ifAbsent: []
]

{ #category : #accessing }
ListChooser >> textSelection [
	^ self searchText size +1 to: self searchText size 
]

{ #category : #accessing }
ListChooser >> title [
	^ title ifNil: [ title := 'Please choose' ]
]

{ #category : #accessing }
ListChooser >> title: aString [
	title := aString.
]
