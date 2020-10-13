Class {
	#name : #PreferenceBrowserMorph,
	#superclass : #SystemWindow,
	#instVars : [
		'mainPanel',
		'defaultButton',
		'saveButton',
		'loadButton',
		'saveToDiskButton',
		'loadFromDiskButton',
		'themeButton',
		'helpButton',
		'preferenceList',
		'lastKeystrokeTime',
		'lastKeystrokes',
		'highlightedPreferenceButton'
	],
	#category : #PreferenceBrowser
}

{ #category : #'instance creation' }
PreferenceBrowserMorph class >> withModel: aPreferenceBrowser [
	^self new initializeWithModel: aPreferenceBrowser;
		yourself.
]

{ #category : #updating }
PreferenceBrowserMorph >> adjustPreferenceListItemsWidth [
	| panel |
	self preferenceList scroller submorphs 
		ifEmpty: [^self].
	panel := self preferenceListInnerPanel. 
	panel width: self preferenceList width - (self preferenceList scrollBarThickness*2).
	panel submorphsDo: [:ea | ea hResizing: #rigid; width: panel width].
	self preferenceList setScrollDeltas.
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> basicButton [

	^ PluggableButtonMorph new
		model: self model;
		offColor: self paneColor;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutInset: 4;
		yourself
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> basicKeyPressed: anEvent [
	| aChar oldSelection nextSelection max milliSeconds nextSelectionList nextSelectionPref |
	aChar := anEvent keyCharacter.
	nextSelection := oldSelection := self selectedPreferenceIndex.
	max := self selectedCategoryPreferences size.
	milliSeconds := Time millisecondClockValue.
	milliSeconds - lastKeystrokeTime > 300 ifTrue: ["just use the one current character for selecting"
		lastKeystrokes := ''].
	lastKeystrokes := lastKeystrokes , aChar asLowercase asString.
	lastKeystrokeTime := milliSeconds.
	nextSelectionList := OrderedCollection newFrom: (self selectedCategoryPreferences copyFrom: oldSelection + 1 to: max).
	nextSelectionList addAll: (self selectedCategoryPreferences copyFrom: 1 to: oldSelection).
	"Get rid of blanks and style used in some lists"
	nextSelectionPref := nextSelectionList detect: [:a | a name withBlanksTrimmed asLowercase beginsWith: lastKeystrokes]
				ifNone: [^ self preferenceList flash"match not found"].
	nextSelection := self selectedCategoryPreferences findFirst: [:a | a  = nextSelectionPref].
	"No change if model is locked"
	oldSelection == nextSelection ifTrue: [^ self preferenceList flash].
	^ self selectedPreferenceIndex: nextSelection
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> buttonRowLayoutFrame [ 
	^LayoutFrame fractions: (0@0 corner: 1@0) offsets: (0@0 corner: 0@ (Preferences standardButtonFont height * 2))
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> defaultButton [
	^defaultButton ifNil: 
		[defaultButton := self basicButton 
						label: 'default' translated; 
						action: #defaultSelected;						
						setBalloonText: 
							'Click here to reset all the preferences to their standard ',
							'default values.' translated]
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> downKeyPressed: anEvent [
	self selectedPreferenceIndex:
		(self selectedPreferenceIndex + 1 
				min: self selectedCategoryPreferences size)
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> endKeyPressed: anEvent [
	self selectedPreferenceIndex: self selectedCategoryPreferences size.

]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> helpButton [
	^helpButton ifNil: 
		[helpButton := self basicButton 
						label: 'help' translated; 
						setBalloonText: 
							'Click here to get some hints on use of this Preferences ',
							'Panel' translated;
						action: #helpSelected]
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> homeKeyPressed: anEvent [
	self selectedPreferenceIndex: 1.

]

{ #category : #initialization }
PreferenceBrowserMorph >> initializeWithModel: aPreferenceBrowser [
	lastKeystrokeTime := 0.
	lastKeystrokes := ''.
	self 
		model: aPreferenceBrowser;
		setLabel: self model windowTitle;
		name: 'PreferenceBrowser';
		addMorph: self rootPanel fullFrame: self rootPanelLayoutFrame;
		addMorph: self newButtonRow fullFrame: self buttonRowLayoutFrame.
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> keyPressed: anEvent [
	self selectedCategory 
		ifNil: [^self].
	anEvent keyValue = 30
		ifTrue: [^self upKeyPressed: anEvent].
	anEvent keyValue = 31
		ifTrue: [^self downKeyPressed: anEvent].
	anEvent keyValue = 1 
		ifTrue: [^self homeKeyPressed: anEvent].
	anEvent keyValue = 4
		ifTrue: [^self endKeyPressed: anEvent].
	anEvent keyValue = 11
		ifTrue: [^self pageUpKeyPressed: anEvent].
	anEvent keyValue = 12
		ifTrue: [^self pageDownKeyPressed: anEvent].
	self basicKeyPressed: anEvent.
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> loadButton [
	^loadButton ifNil: 
		[loadButton := self basicButton 
						label: 'load' translated; 
						action: #loadSelected;						
						setBalloonText: 
							'Click here to reset all the preferences to their values ',
							'in your Personal Preferences.' translated]
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> loadFromDiskButton [
	^loadFromDiskButton ifNil: 
		[loadFromDiskButton := self basicButton 
						label: 'load from disk' translated; 
						action: #loadFromDiskSelected;						
						setBalloonText: 
							'Click here to load all the preferences from ',
							'their saved values on disk.' translated]
]

{ #category : #'submorphs - main panel' }
PreferenceBrowserMorph >> mainPanel [
	^mainPanel ifNil: 
		[mainPanel := BorderedMorph new
			color: Color transparent;
			borderWidth: 0;
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			cellGap: 5;
			changeProportionalLayout;
			on: #mouseEnter send: #paneTransition: to: self;
			addMorphBack: self newCategoryList;
			addMorphBack: self preferenceList;
			layoutFrame: (LayoutFrame fractions: (0@0 corner: 1@1) offsets: (0@ self searchTextFieldLayoutFrame bottomOffset corner: 0@0));
			addPaneSplitters;
			yourself].
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> mouseDownOn: aPreferenceView event: anEvent [
	anEvent hand newKeyboardFocus: self preferenceList scroller.
	anEvent yellowButtonPressed
		ifTrue: [aPreferenceView offerPreferenceNameMenu: self model]
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> newButtonRow [
	^BorderedMorph new
		color: Color transparent;
		borderWidth: 0;
		cellGap: 2;
		layoutPolicy: TableLayout new;
		listDirection: #leftToRight;
		listCentering: #topLeft;
		cellPositioning: #topLeft;
		on: #mouseEnter send: #paneTransition: to: self;
		on: #mouseLeave send: #paneTransition: to: self;
		addMorphBack: self defaultButton;
		addMorphBack: self newSeparator;
		addMorphBack: self saveButton;
		addMorphBack: self loadButton;
		addMorphBack: self newSeparator;
		addMorphBack: self saveToDiskButton;
		addMorphBack: self loadFromDiskButton;
		addMorphBack: self newSeparator;
		addMorphBack: self themeButton;
		addMorphBack: self newTransparentFiller;
		addMorphBack: self helpButton;
		yourself.
]

{ #category : #'submorphs - category list' }
PreferenceBrowserMorph >> newCategoryList [ 
	^(PluggableListMorph
		on: self model
		list: #categoryList
		selected: #selectedCategoryIndex
		changeSelected: #selectedCategoryIndex:)
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			layoutFrame: (LayoutFrame fractions: (0@0 corner: 0.25@1));
			yourself.
]

{ #category : #'submorphs - category list' }
PreferenceBrowserMorph >> newCategoryListPanel [
	^Morph new
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		color: Color transparent;
		layoutPolicy: TableLayout new;
		cellGap: 3;
		listCentering: #topLeft;
		listDirection: #topToBottom;
		cellPositioning: #topLeft;
		clipSubmorphs: true;
		addMorphBack: self newCategoryListPanelLabel;
		addMorphBack: self newCategoryList
]

{ #category : #'submorphs - category list' }
PreferenceBrowserMorph >> newCategoryListPanelLabel [ 
	^StringMorph contents: 'Categories' translated.
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> newPreferenceButtonFor: aPreference [ 
	| button |
	button := PBPreferenceButtonMorph preference: aPreference model: self model.
	button 
		on: #mouseDown
		send: #value:
		to: 
			[:anEvent | 
			self
				selectedPreference: aPreference;
				mouseDownOn: button preferenceView event: anEvent].
	^button
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> newPreferenceListInnerPanel [
	| panel |
	panel := (Morph new)
				color: Color transparent;
				layoutPolicy: TableLayout new;
				listDirection: #topToBottom;
				cellPositioning: #topLeft;
				hResizing: #spaceFill;
				vResizing: #shrinkWrap;
				yourself.
	self selectedCategoryPreferences 
		do: [:aPref | panel addMorphBack: (self newPreferenceButtonFor: aPref)].
	^panel
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> newPreferenceListPanel [
	| panel |
	panel := Morph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		color: Color transparent;
		layoutPolicy: TableLayout new;
		cellGap: 3;
		listCentering: #topLeft;
		listDirection: #topToBottom;
		cellPositioning: #topLeft;
		clipSubmorphs: true;
		addMorphBack: self newPreferenceListPanelLabel;
		addMorphBack: self preferenceList.
	^panel.
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> newPreferenceListPanelLabel [ 
	^StringMorph contents: 'Preferences' translated.
]

{ #category : #'submorphs - search panel' }
PreferenceBrowserMorph >> newSearchTextField [
	
	| ptm  |
	ptm := PluggableTextMorphPlus
		on: self model
		text: #searchPatternNeverTriggered
		accept: #searchPattern:.
	
	ptm
		minimumHeight: 0;
		balloonText: 'Search preferences ...';
		hideScrollBarsIndefinitely;
		layoutFrame: self searchTextFieldLayoutFrame;
		borderInset;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		acceptOnCR: true;
		onKeyStrokeSend: #value to: [ ptm hasUnacceptedEdits ifTrue: [ ptm accept ] ].
	^ptm.
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> newSeparator [
	^BorderedMorph new
		borderWidth: 2;
		borderColor: Color transparent;
		color: self paneColor;
		hResizing: #rigid;
		width: 5;
		vResizing: #spaceFill;
		yourself
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> newTransparentFiller [
	^Morph new
		color: Color transparent;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		yourself.
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> pageDownKeyPressed: anEvent [
	self selectedPreferenceIndex: (self selectedPreferenceIndex + self preferencesShowing size min: self selectedCategoryPreferences size).

]

{ #category : #'event handling' }
PreferenceBrowserMorph >> pageUpKeyPressed: anEvent [
	self selectedPreferenceIndex: (self selectedPreferenceIndex - self preferencesShowing size max: 1).

]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> preferenceList [ 
	^preferenceList ifNil:
		[preferenceList := ScrollPane new
			vResizing: #spaceFill;
			hResizing: #spaceFill;
			layoutFrame: (LayoutFrame fractions: (0.25@0 corner: 1@1) offsets: (4@0 corner: 0@0)).
		preferenceList scroller
			on: #keyStroke send: #keyPressed: to: self;
			changeTableLayout.
		preferenceList.]
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> preferenceListInnerPanel [
	^self preferenceList scroller submorphs first
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> preferencesShowing [
	| prefs |
	prefs := self preferenceListInnerPanel submorphs
					copyFrom: (self selectedPreferenceIndex max: 1)
					to: self selectedCategoryPreferences size.
	^prefs reject: [:ea | (ea top - prefs first top) > self preferenceList scroller height].
]

{ #category : #'submorphs - root panel' }
PreferenceBrowserMorph >> rootPanel [
	^BorderedMorph new
		color: Color transparent;
		borderWidth: 0;
		changeProportionalLayout;
		addMorphBack: self newSearchTextField;
		addMorphBack: self mainPanel;
		yourself.
]

{ #category : #'submorphs - root panel' }
PreferenceBrowserMorph >> rootPanelLayoutFrame [ 
	| frame |
	frame := self buttonRowLayoutFrame.
	^LayoutFrame fractions: (0@0 corner: 1@1) offsets: (0@(frame bottomOffset) corner: 0@0)
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> saveButton [
	^saveButton ifNil: 
		[saveButton := self basicButton 
						label: 'save' translated; 
						action: #saveSelected;						
						setBalloonText: 
							'Click here to save the current constellation of Preferences ',
							'settings as your personal defaults; you can get them all ',
							'reinstalled with a single gesture by clicking the "Restore ',
							'my Personal Preferences".' translated]
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> saveToDiskButton [
	^saveToDiskButton ifNil: 
		[saveToDiskButton := self basicButton 
						label: 'save to disk' translated; 
						action: #saveToDiskSelected;						
						setBalloonText: 
							'Click here to save the current constellation of Preferences ',
							'settings to a file; you can get them all reinstalled with a ', 
							'single gesture by clicking "Restore Settings From Disk".'
								 translated]
]

{ #category : #'submorphs - search panel' }
PreferenceBrowserMorph >> searchTextFieldLayoutFrame [
	
	^ LayoutFrame
		fractions: (0@0 corner: 1@0)
		offsets: (0@0 corner: 0@ (Preferences standardDefaultTextFont height * 3/2) rounded)
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedCategory [
	^self model selectedCategory
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedCategoryIndex [
	^self model selectedCategoryIndex
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedCategoryIndex: anIndex [
	^self model selectedCategoryIndex: anIndex
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedCategoryPreferences [
	^self model selectedCategoryPreferences
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedPreference [
	^self model selectedPreference
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedPreference: aPreference [
	^self model selectedPreference: aPreference
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> selectedPreferenceButton [
	^(self preferenceListInnerPanel submorphs at: self selectedPreferenceIndex)
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedPreferenceIndex [
	^self model selectedPreferenceIndex
]

{ #category : #'model access' }
PreferenceBrowserMorph >> selectedPreferenceIndex: anIndex [
	^self model selectedPreferenceIndex: anIndex
]

{ #category : #'submorphs - buttons' }
PreferenceBrowserMorph >> themeButton [
	^themeButton ifNil: 
		[themeButton := self basicButton 
						label: 'more ...' translated; 
						action: #themeSelected;
						setBalloonText: 'Presents you with a menu of sets or preferences; each item''s balloon-help will tell you about the particular set.  If you choose one, many different preferences that come along are set at the same time; you can subsequently change any settings by using a Preferences Panel' translated].
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> turnOffSelectedPreference [
	highlightedPreferenceButton 
		ifNil: [^self].
	highlightedPreferenceButton highlightOff.
	highlightedPreferenceButton := nil.
]

{ #category : #'submorphs - preference list' }
PreferenceBrowserMorph >> turnOnSelectedPreference [
	
	highlightedPreferenceButton = self selectedPreferenceButton
		ifTrue: [ highlightedPreferenceButton highlightOff. ^self turnOffSelectedPreference].
	highlightedPreferenceButton 
		ifNotNil: [:m | m highlightOff].
	highlightedPreferenceButton := self selectedPreferenceButton
		highlightOn;
		yourself.
	self preferenceList scrollToShow: highlightedPreferenceButton bounds.
]

{ #category : #'event handling' }
PreferenceBrowserMorph >> upKeyPressed: anEvent [
	self selectedPreferenceIndex: 
			(self selectedPreferenceIndex - 1 max: 1).

]

{ #category : #updating }
PreferenceBrowserMorph >> update: aSymbol [
	super update: aSymbol.
	aSymbol == #selectedPreference
		ifTrue: [self updateSelectedPreference].
	aSymbol == #selectedCategoryIndex
		ifTrue: [self updateSelectedCategoryPreferences].
]

{ #category : #updating }
PreferenceBrowserMorph >> updateSelectedCategoryPreferences [
	Cursor wait showWhile: 
		[self preferenceList 
				hScrollBarValue: 0;
				vScrollBarValue: 0.
		self preferenceList scroller removeAllMorphs.
		self preferenceList scroller addMorphBack: self newPreferenceListInnerPanel.
		self adoptPaneColor: self paneColor]
]

{ #category : #updating }
PreferenceBrowserMorph >> updateSelectedPreference [
	| index |
	index := self selectedPreferenceIndex.
	index = 0
		ifTrue: [^self].
	self turnOnSelectedPreference.
]
