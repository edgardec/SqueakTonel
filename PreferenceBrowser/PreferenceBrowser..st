Class {
	#name : #PreferenceBrowser,
	#superclass : #Model,
	#instVars : [
		'selectedCategoryIndex',
		'selectedPreference',
		'searchPattern',
		'searchResults',
		'lastExecutedSearch',
		'preferences',
		'title'
	],
	#category : #PreferenceBrowser
}

{ #category : #'class initialization' }
PreferenceBrowser class >> initialize [
	self
		registerInOpenMenu;
		registerInFlaps
]

{ #category : #'instance creation' }
PreferenceBrowser class >> open [
	| browser |
	browser := self new.
	(PreferenceBrowserMorph withModel: browser)
		openInWorld.
	^browser.	
]

{ #category : #'instance creation' }
PreferenceBrowser class >> prototypicalToolWindow [
	| window |
	window := PreferenceBrowserMorph withModel: self new.
	window applyModelExtent.
	^window
]

{ #category : #'class initialization' }
PreferenceBrowser class >> registerInFlaps [
	Flaps 
		registerQuad: 
			{ #PreferenceBrowser. 
			#prototypicalToolWindow.
			'Preference Browser' translated.
			'A tool for expressing personal preferences for numerous options' translated }
	 	forFlapNamed: 'Tools' translated.
	Flaps replaceToolsFlap
]

{ #category : #'class initialization' }
PreferenceBrowser class >> registerInOpenMenu [
	(TheWorldMenu respondsTo: #registerOpenCommand:) ifTrue: [
		TheWorldMenu unregisterOpenCommand: 'Preference Browser'.
		TheWorldMenu registerOpenCommand: {'Preference Browser'. {self. #open}}].
		
]

{ #category : #'class initialization' }
PreferenceBrowser class >> unload [
	self 
		unregisterFromOpenMenu;
		unregisterFromFlaps.
]

{ #category : #'class initialization' }
PreferenceBrowser class >> unregisterFromFlaps [
	Flaps 
		unregisterQuadsWithReceiver: self;
		replaceToolsFlap
]

{ #category : #'class initialization' }
PreferenceBrowser class >> unregisterFromOpenMenu [
	 (TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [TheWorldMenu unregisterOpenCommand: 'Preference Browser'].

]

{ #category : #'user interface' }
PreferenceBrowser >> allCategoryLabel [
	^'-- all --' translated
]

{ #category : #accessing }
PreferenceBrowser >> allCategorySelected [
	^self selectedCategory = self allCategoryLabel
]

{ #category : #accessing }
PreferenceBrowser >> allPreferences [
	^ preferences allPreferences sort:
			[:pref1 :pref2 | 
			pref1 viewRegistry viewOrder  <pref2 viewRegistry viewOrder  or:
					[pref1 viewRegistry viewOrder  =pref2 viewRegistry viewOrder 
						 &(pref1 name  <pref2 name)]]
]

{ #category : #accessing }
PreferenceBrowser >> categoryList [
	^OrderedCollection new
		add:  self allCategoryLabel;
		addAll: preferences categoryList sorted;
		add: self searchResultsCategoryLabel;
		yourself.
	
	
]

{ #category : #'preferences search' }
PreferenceBrowser >> defaultSelected [

	(Project uiManager 
		confirm: 'Do you really want to restore the default\preferences?\\If you want to keep the current state,\you have to save it first.' translated withCRs
		title: 'Restore Preferences')
			ifFalse: [^ self].

	Preferences chooseInitialSettings.
]

{ #category : #'user interface' }
PreferenceBrowser >> defaultWindowColor [
	^ (Color r: 0.671 g: 0.9 b: 0.9)
]

{ #category : #find }
PreferenceBrowser >> findCategoryFromPreference: aPreference [
	"Find all categories in which the preference occurs"

	| aMenu| 
	aMenu := MenuMorph new defaultTarget: self.
	aPreference categoryList do:
		[:aCategory | aMenu add: aCategory target: self selector: #selectedCategory: argument: aCategory].
	aMenu popUpInWorld
]

{ #category : #'preferences search' }
PreferenceBrowser >> helpSelected [ 
	"Open up a workspace with explanatory info in it about the Preference Browser"
	Workspace new
		contents: self helpText;
		openLabel: self windowTitle.
]

{ #category : #'preferences search' }
PreferenceBrowser >> helpText [
	^(String streamContents: [:str |
		str nextPutAll:
'Many aspects of the system are governed by the settings of various ''Preferences''.

Click on any of the categories shown in the list on the left to see all the preferences in that category. Alternatively type into the search box at the top of the window and all Preferences matching whatever you typed will appear in the ''search results'' category. A preference is considered to match your search if either its name matches the text *or* if anything in the preference''s help text does.

To find out more about any particular Preference just select it and its help text will appear. The ''more'' button at the end of the hlpe text pops up a menu with some more expert-oriented options.

Some preferences can be ''local'' instead of global. When a preference is set as global its value will apply to whatever project you are in. A local preference will only be valid in the project that you set it in.

The ''Save'' button allow you to quickly save your current settings so it can later be restored with the ''Load'' button.

To carry your settings to another Squeak you might want to use the ''Save to disk'' and ''Load from disk'' buttons. The save to disk option will store all your settings in a ''my.prefs'' file in your Squeak''s current directory.
.']) translated
]

{ #category : #'user interface' }
PreferenceBrowser >> initialExtent [
	^ 660@440
]

{ #category : #'initialize-release' }
PreferenceBrowser >> initialize [
	preferences := Preferences.
	title := 'Preference Browser'.
]

{ #category : #accessing }
PreferenceBrowser >> lastExecutedSearch [
	^lastExecutedSearch
]

{ #category : #accessing }
PreferenceBrowser >> lastExecutedSearch: aTextOrString [
	^lastExecutedSearch:= aTextOrString
]

{ #category : #'preferences search' }
PreferenceBrowser >> loadFromDiskSelected [ 

	(Project uiManager
		confirm: 'Do you really want to restore your\personal preferences from disk?\\The file ''my.prefs'' will be loaded.' translated withCRs
		title: 'Restore Preferences from Disk') ifFalse: [^ self].

	preferences restorePreferencesFromDisk
]

{ #category : #'preferences search' }
PreferenceBrowser >> loadSelected [

	(Project uiManager
		confirm: 'Do you really want to restore\your personal preferences?' translated withCRs
		title: 'Restore Preferences') ifFalse: [^ self].
		
	preferences restorePersonalPreferences.
]

{ #category : #accessing }
PreferenceBrowser >> nonSpecialCategorySelected [
	^self allCategorySelected not & self searchResultsCategorySelected not
]

{ #category : #accessing }
PreferenceBrowser >> preferences [
	^ preferences
]

{ #category : #accessing }
PreferenceBrowser >> preferencesInCategory: aCategory [
	^(preferences preferencesInCategory: aCategory) sort:
		[:pref1 :pref2 | 
				pref1 viewRegistry viewOrder  <pref2 viewRegistry viewOrder  or:
						[pref1 viewRegistry viewOrder  =pref2 viewRegistry viewOrder 
							 &(pref1 name  <pref2 name)]]
]

{ #category : #'user interface' }
PreferenceBrowser >> representsSameBrowseeAs: anotherModel [
	"If an existing Preference browser is on-screen, use it. Compare preferences with #== because those are typically persistent (or long living) database objects in the image."
	
	^ self class = anotherModel class
		and: [self preferences == anotherModel preferences]
]

{ #category : #'preferences search' }
PreferenceBrowser >> saveSelected [

	(Project uiManager
		confirm: 'Do you really want to overwrite\your personal preferences?' translated withCRs
		title: 'Save Preferences') ifFalse: [^ self].

	preferences savePersonalPreferences.
]

{ #category : #'preferences search' }
PreferenceBrowser >> saveToDiskSelected [ 

	(Project uiManager
		confirm: 'Do you really want to overwrite your\personal preferences on disk?\\The file ''my.prefs'' will be updated.' translated withCRs
		title: 'Save Preferences to Disk') ifFalse: [^ self].
		
	preferences storePreferencesToDisk
]

{ #category : #accessing }
PreferenceBrowser >> searchFieldLegend [
	^''.
]

{ #category : #accessing }
PreferenceBrowser >> searchPattern [
	^searchPattern ifNil: [searchPattern := self searchFieldLegend]
]

{ #category : #accessing }
PreferenceBrowser >> searchPattern: aStringOrText [
	aStringOrText 
		ifEmpty: [searchPattern := self searchFieldLegend]
		ifNotEmpty: [searchPattern := aStringOrText asString].
	self changed: #searchPattern.
	^true
]

{ #category : #accessing }
PreferenceBrowser >> searchPatternNeverTriggered [

	^self searchPattern
]

{ #category : #'preferences search' }
PreferenceBrowser >> searchPreferencesFor: pattern [
	| result |
	result := pattern asString asLowercase withBlanksTrimmed.
	result ifEmpty: [^self].
	searchResults := self allPreferences select: [:aPreference |
		((aPreference name includesSubstring: result caseSensitive: false)
			or: [aPreference helpString includesSubstring: result caseSensitive: false])
			or: [aPreference codeString includesSubstring: result caseSensitive: false] ].		
	self selectSearchResultsCategory.
	self lastExecutedSearch: pattern.

]

{ #category : #accessing }
PreferenceBrowser >> searchResults [
	^searchResults ifNil: [searchResults := #()]
]

{ #category : #'user interface' }
PreferenceBrowser >> searchResultsCategoryLabel [
	^'-- search results --' translated
]

{ #category : #accessing }
PreferenceBrowser >> searchResultsCategorySelected [
	^self selectedCategory = self searchResultsCategoryLabel
]

{ #category : #'buttons callbacks' }
PreferenceBrowser >> searchSelected [
	self searchPreferencesFor: self searchPattern.
]

{ #category : #accessing }
PreferenceBrowser >> selectFirstPreferenceOrNil [
	| prefs |
	self selectedCategory
		ifNil: [^self selectedPreference: nil].
	prefs := self preferencesInCategory: self selectedCategory.
	prefs isEmpty
		ifTrue: [^self selectedPreference: nil].
	self selectedPreference: prefs first.
]

{ #category : #accessing }
PreferenceBrowser >> selectSearchResultsCategory [
	self selectedCategoryIndex: (self categoryList indexOf: self searchResultsCategoryLabel)
]

{ #category : #accessing }
PreferenceBrowser >> selectedCategory [
	^self categoryList at: selectedCategoryIndex ifAbsent: []
]

{ #category : #accessing }
PreferenceBrowser >> selectedCategory: aCategorySymbol [
	self selectedCategoryIndex: (self categoryList indexOf: aCategorySymbol).
]

{ #category : #accessing }
PreferenceBrowser >> selectedCategoryIndex [
	^selectedCategoryIndex ifNil: [selectedCategoryIndex := 0].
]

{ #category : #accessing }
PreferenceBrowser >> selectedCategoryIndex: anIndex [
	anIndex = 0
		ifTrue: [^self].
	self selectedPreference: nil.
	selectedCategoryIndex := anIndex.
	self changed: #selectedCategoryIndex.
]

{ #category : #accessing }
PreferenceBrowser >> selectedCategoryPreferences [
	self allCategorySelected
		ifTrue: [^self allPreferences].
	self searchResultsCategorySelected 
		ifTrue: [^self searchResults].
	^self preferencesInCategory: self selectedCategory.
	
]

{ #category : #accessing }
PreferenceBrowser >> selectedPreference [
	^selectedPreference
]

{ #category : #accessing }
PreferenceBrowser >> selectedPreference: aPreference [
	selectedPreference := aPreference.
	self changed: #selectedPreference.
	self changed: #selectedPreferenceIndex.
	self changed: #selectedPreferenceHelpText.
]

{ #category : #accessing }
PreferenceBrowser >> selectedPreferenceHelpText [
	self selectedPreference
		ifNil: [^''].
	^self selectedPreference helpString withBlanksTrimmed.
]

{ #category : #accessing }
PreferenceBrowser >> selectedPreferenceIndex [
	^self selectedCategoryPreferences indexOf: self selectedPreference
]

{ #category : #accessing }
PreferenceBrowser >> selectedPreferenceIndex: anIndex [
	anIndex = 0
		ifTrue: [^self].
	self selectedPreference: (self selectedCategoryPreferences at: anIndex).
]

{ #category : #stepping }
PreferenceBrowser >> stepAt: millisecondClockValue in: aWindow [
	super stepAt: millisecondClockValue in: aWindow.
	self searchPattern ~= self lastExecutedSearch
		ifTrue: [self searchPreferencesFor: self searchPattern].
]

{ #category : #'preferences search' }
PreferenceBrowser >> themeSelected [ 
	preferences offerThemesMenu
]

{ #category : #stepping }
PreferenceBrowser >> wantsStepsIn: aWindow [
	^true.
]

{ #category : #'user interface' }
PreferenceBrowser >> windowTitle [
	^ title translated
]
