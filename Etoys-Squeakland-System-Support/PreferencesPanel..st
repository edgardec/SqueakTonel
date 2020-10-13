"
I represent a the model of a Preferences window.
"
Class {
	#name : #PreferencesPanel,
	#superclass : #Model,
	#instVars : [
		'searchString'
	],
	#category : #'Etoys-Squeakland-System-Support'
}

{ #category : #cleanup }
PreferencesPanel class >> deleteAllPreferencesPanels [
	"Called manually to clobber all existing preferences panels"
	"PreferencesPanel deleteAllPreferencesPanels"

	| aWindow |
	self allInstancesDo:
		[:aPanel |
			(aWindow := aPanel containingWindow) isMorph
				ifTrue:
					[aWindow delete]].
	self killExistingMVCViews.
	UpdatingThreePhaseButtonMorph allInstancesDo: "clobber old stand-alone prefs buttons"
		[:m | (m actionSelector == #togglePreference:) ifTrue:
			[(m owner isAlignmentMorph) ifTrue:
				[m owner delete]]]
]

{ #category : #cleanup }
PreferencesPanel class >> isAPreferenceViewToKill: aSystemView [
	"Answer whether the given StandardSystemView is one affiliated with a PreferencesPanel"

	| m target subView |
	aSystemView subViews size = 1 ifFalse: [^ false].
	subView := aSystemView subViews first.
	(subView isKindOf: MorphWorldView) ifFalse: [^ false].
	((m := subView model) isKindOf: MVCWiWPasteUpMorph) ifFalse: [^ false].
	m submorphs size = 1 ifFalse: [^ false].
	m firstSubmorph submorphs size = 1 ifFalse: [^ false].
	target := m firstSubmorph firstSubmorph. 
	(target isKindOf: TabbedPalette) ifFalse: [^ false].
	^ #(browsing debug fileout general halos) allSatisfy: [:s |
		(target tabNamed: s) notNil]
]

{ #category : #cleanup }
PreferencesPanel class >> killExistingMVCViews [
	"Kill all existing preferences views in mvc"
"
PreferencesPanel killExistingMVCViews
"
	| byebye |

	ControlManager allInstances do: [ :cm |
		byebye := cm controllersSatisfying: [ :eachC |
			self isAPreferenceViewToKill: eachC view].
		byebye do: [ :each | 
			each status: #closed.
			each view release.
			cm unschedule: each]]
]

{ #category : #find }
PreferencesPanel >> addHelpItemsTo: panelPage [
	"Add the items appropriate the the ? page of the receiver"

	| aButton aTextMorph aMorph firstTextMorph |
	panelPage hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	firstTextMorph :=  TextMorph new contents: 'Search Preferences for:' translated.
	"firstTextMorph beAllFont: ((TextStyle default fontOfSize: 13) emphasized: 1)."
	panelPage addMorphBack: firstTextMorph lock.
	panelPage addTransparentSpacerOfSize: 0@10.

	aMorph := RectangleMorph new clipSubmorphs: true; beTransparent; borderWidth: 2; borderColor: Color black; extent: 250 @ 36.
	aMorph vResizing: #rigid; hResizing: #rigid.
	aTextMorph :=  PluggableTextMorph new
				on: self
				text: #searchString
				accept: #setSearchStringTo:
				readSelection: nil
				menu: nil.
"	aTextMorph hResizing: #rigid."
	aTextMorph borderWidth: 0.
	aTextMorph font: ((TextStyle default fontOfSize: 21) emphasized: 1); setTextColor: Color red.
	aMorph addMorphBack: aTextMorph.
	aTextMorph acceptOnCR: true.
	aTextMorph position: (aTextMorph position + (6@5)).
	aMorph clipLayoutCells: true.
	aTextMorph extent: 240 @ 25.
	panelPage addMorphBack: aMorph.
	aTextMorph setBalloonText: 'Type what you want to search for here, then hit the "Search" button, or else hit RETURN or ENTER' translated.
	aTextMorph setTextMorphToSelectAllOnMouseEnter.
	aTextMorph hideScrollBarsIndefinitely.
	panelPage addTransparentSpacerOfSize: 0@10.

	aButton := SimpleButtonMorph new 
				target: self; 
				color: Color transparent; 
				actionSelector: #initiateSearch:;
				 arguments: {aTextMorph};
				 label: 'Search' translated.
	panelPage addMorphBack: aButton.
	aButton setBalloonText: 'Type what you want to search for in the box above, then click here (or hit RETURN or ENTER) to start the search; results will appear in the "search results" category.' translated.

	panelPage addTransparentSpacerOfSize: 0@30.

	panelPage addMorphBack: (SimpleButtonMorph new 
								color: Color transparent;
								 label: 'Reset preferences on startup' translated;
								 target: Preferences;
								 actionSelector: #deletePersistedPreferences;
								 setBalloonText: 'Click here to delete all the preferences saved on file. On the next start, they will have their original value.' translated ; yourself).

	panelPage addTransparentSpacerOfSize: 0@14.

Preferences eToyFriendly ifFalse: [ 
	panelPage addMorphBack: (SimpleButtonMorph new 
								color: Color transparent;
								 label: 'Restore all Default Preference Settings' translated;
								 target: Preferences;
								 actionSelector: #chooseInitialSettings;
								 setBalloonText: 'Click here to reset all the preferences to their standard default values.' translated ; yourself).

	panelPage addTransparentSpacerOfSize: 0@14.
	panelPage addMorphBack: (SimpleButtonMorph new 
								color: Color transparent; 
								label: 'Save Current Settings as my Personal Preferences' translated; 
								target: Preferences;
								 actionSelector: #savePersonalPreferences;
								 setBalloonText: 'Click here to save the current constellation of Preferences settings as your personal defaults; you can get them all reinstalled with a single gesture by clicking the "Restore my Personal Preferences".' translated; yourself).

	panelPage addTransparentSpacerOfSize: 0@14.
	panelPage addMorphBack: (SimpleButtonMorph new 
								color: Color transparent; 
								label: 'Restore my Personal Preferences' translated;
								 target: Preferences;
								 actionSelector: #restorePersonalPreferences;
								 setBalloonText: 'Click here to reset all the preferences to their values in your Personal Preferences.' translated; yourself).

	panelPage addTransparentSpacerOfSize: 0@30.
	panelPage addMorphBack: (SimpleButtonMorph new 
								color: Color transparent; 
								label: 'Save Current Settings to Disk' translated; 
								target: Preferences; 
								actionSelector: #storePreferencesToDisk;
								setBalloonText: 'Click here to save the current constellation of Preferences settings to a file; you can get them all reinstalled with a single gesture by clicking "Restore Settings From Disk".' translated; yourself).

	panelPage addTransparentSpacerOfSize: 0@14.
	panelPage addMorphBack: (SimpleButtonMorph new 
								color: Color transparent; 
								label: 'Restore Settings from Disk' translated; 
								target: Preferences; 
								actionSelector: #restorePreferencesFromDisk; 
								setBalloonText: 'Click here to load all the preferences from their saved values on disk.' translated; yourself).

	panelPage addTransparentSpacerOfSize: 0@30.

	panelPage addMorphBack: (SimpleButtonMorph new
								color: Color transparent;
								label: 'Inspect Parameters' translated; 
								target: Preferences; 
								actionSelector: #inspectParameters; 
								setBalloonText: 'Click here to view all the values stored in the system Parameters dictionary' translated; yourself).
	panelPage addTransparentSpacerOfSize: 0@10.
	panelPage addMorphBack: (Preferences themeChoiceButtonOfColor: Color transparent font: TextStyle defaultFont).
	panelPage addTransparentSpacerOfSize: 0@10.
].

	panelPage addMorphBack: (SimpleButtonMorph new 
								color: Color transparent; 
								label: 'Help!' translated;
								target: Preferences;
								actionSelector: #giveHelpWithPreferences; 
								setBalloonText: 'Click here to get some hints on use of this Preferences Panel' translated; yourself).
	panelPage wrapCentering: #center.

]

{ #category : #initialization }
PreferencesPanel >> addModelItemsToWindowMenu: aMenu [
	"aMenu is being constructed to be presented to the user in response to the user's pressing on the menu widget in the title bar of a morphic SystemWindow.  Here, the model is given the opportunity to add any model-specific items to the menu, whose default target is the SystemWindow itself."

	true ifTrue: [^ self].  

	"The below are provisionally disenfranchised, because their function is now directly available in the ? category"
	aMenu addLine.
	aMenu add: 'find preference... (f)' translated target: self action: #findPreference:.
	aMenu add: 'inspect parameters' translated target: Preferences action: #inspectParameters
]

{ #category : #initialization }
PreferencesPanel >> adjustProjectLocalEmphasisFor: aSymbol [
	"Somewhere, the preference represented by aSymbol got changed from being one that is truly global to one that varies by project, or vice-versa.  Get my panel right -- this involves changing the emphasis on the item"

	| aWindow toFixUp allMorphs emphasis |
	(aWindow := self containingWindow) ifNil: [^ self].
	emphasis := (Preferences preferenceAt: aSymbol ifAbsent: [^ self]) localToProject
		ifTrue:	[1 "bold for local-to-project"]
		ifFalse:	[0 "plain for global"].
	allMorphs := IdentitySet new.
	aWindow allMorphsAndBookPagesInto: allMorphs.
	toFixUp := allMorphs select:
		[:m | (m isKindOf: StringMorph) and: [m contents = aSymbol]].
	toFixUp do:
		[:aStringMorph | aStringMorph emphasis: emphasis]

	
]

{ #category : #find }
PreferencesPanel >> containingWindow [
	"Answer the window in which the receiver is seen"

	^ super containingWindow ifNil:
		[Smalltalk isMorphic ifFalse: [self currentWorld]]
]

{ #category : #find }
PreferencesPanel >> findCategoryFromPreference: prefSymbol [
	"Find all categories in which the preference occurs"

	| aMenu| 
	aMenu := MenuMorph new defaultTarget: self.
	(Preferences categoriesContainingPreference: prefSymbol) do:
		[:aCategory | aMenu add: aCategory target: self selector: #switchToCategoryNamed:event: argumentList: {aCategory. MorphicEvent new}].
	aMenu popUpInWorld
]

{ #category : #find }
PreferencesPanel >> findPreference: evt [
	"Allow the user to submit a selector fragment; search for that among preference names; put up a list of qualifying preferences; if the user selects one of those, redirect the preferences panel to reveal the chosen preference"

	self findPreferencesMatching: (FillInTheBlank request: 'Search for preferences containing:' translated initialAnswer: 'color')
]

{ #category : #initialization }
PreferencesPanel >> findPreferencesMatching: incomingTextOrString [
	"find all preferences matching incomingTextOrString"

	| result aList aPalette controlPage |
	result := incomingTextOrString asString asLowercase.
	result := result asLowercase withBlanksTrimmed.
	result isEmptyOrNil ifTrue: [^ self].

	aList := Preferences allPreferences select:
		[:aPreference | 
			(aPreference name includesSubstring: result caseSensitive: false) or:
				[aPreference helpString includesSubstring: result caseSensitive: false]].
	aPalette := (self containingWindow ifNil: [^ self]) findDeeplyA: TabbedPalette.
	aPalette ifNil: [^ self].
	aPalette selectTabNamed:  'search results'.
	aPalette currentPage ifNil: [^ self].  "bkwd compat"
	controlPage := aPalette currentPage.
	controlPage removeAllMorphs.
	controlPage addMorph: (StringMorph contents: ('Preferences matching "', self searchString, '"') font: Preferences standardEToysButtonFont).
	aList sort: [:a :b | a name < b name].
	aList do:
		[:aPreference | | button |
			button := aPreference representativeButtonWithColor: Color white inPanel: self.
			button ifNotNil: [controlPage addMorphBack: button]].
	aPalette world startSteppingSubmorphsOf: aPalette
]

{ #category : #find }
PreferencesPanel >> findPreferencesMatchingSearchString [
	"find all preferences matching incomingTextOrString"

	self findPreferencesMatching: self searchString
]

{ #category : #find }
PreferencesPanel >> initiateSearch: morphHoldingSearchString [
	"Carry out the action of the Search button in the Preferences panel"

	searchString := morphHoldingSearchString text.
	self setSearchStringTo: self searchString.
	
	self findPreferencesMatchingSearchString
]

{ #category : #find }
PreferencesPanel >> keyStroke: anEvent [
	"Handle a keystroke event in the panel; we map f (for find) into a switch to the ? category"

	(anEvent keyCharacter == $f) ifTrue:
		[^ self switchToCategoryNamed: #? event: nil]
]

{ #category : #find }
PreferencesPanel >> searchString [
	"Answer the current searchString, initializing it if need be"

	 | win aMorph |
searchString isEmptyOrNil ifTrue: 
		[searchString := 'Type here, hit Search' translated.
		(win := self containingWindow) ifNotNil:
			[aMorph := win findDeepSubmorphThat:
					[:m | m isKindOf: PluggableTextMorph]
				ifAbsent: [^ searchString].
			aMorph setText: searchString.
			aMorph setTextMorphToSelectAllOnMouseEnter.
			aMorph selectAll]].
	^ searchString
]

{ #category : #find }
PreferencesPanel >> setSearchStringTo: aText [
	"The user submitted aText as the search string; now search for it"

	searchString := aText asString.
	self findPreferencesMatching: searchString.
	^ true
]

{ #category : #'category switch' }
PreferencesPanel >> switchToCategoryNamed: aName event: anEvent [
	"Switch the panel so that it looks at the category of the given name"

	| aPalette |
	aPalette := self containingWindow findDeeplyA: TabbedPalette.
	aPalette ifNil: [^ self].
	aPalette selectTabNamed: aName
]
