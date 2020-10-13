"
I am just a refactor of all the common method of the PreferenceBrowser preference views
"
Class {
	#name : #PBPreferenceView,
	#superclass : #PreferenceView,
	#instVars : [
		'actions'
	],
	#category : #PreferenceBrowser
}

{ #category : #'view registry' }
PBPreferenceView class >> handlesPanel: aPreferencePanel [
	^aPreferencePanel isKindOf: PreferenceBrowser
]

{ #category : #actions }
PBPreferenceView >> actions [
	^actions ifNil: [actions := OrderedCollection new.]
]

{ #category : #actions }
PBPreferenceView >> addActionTitled: aTitle target: aTarget selector: aSelector arguments: aCollection balloonText: aText [
	self actions add: { aTitle. aTarget. aSelector. aCollection. aText }
]

{ #category : #'user interface' }
PBPreferenceView >> basicPanel [
	^BorderedMorph new
		beTransparent;
		extent: 0@0;
		borderWidth: 0;
		layoutInset: 0;
		cellGap: 5;
		layoutPolicy: TableLayout new;
		listCentering: #topLeft;
		cellPositioning: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		yourself
]

{ #category : #'user interface' }
PBPreferenceView >> blankSpaceOf: aPoint [
	^Morph new 
		beTransparent;
		extent: aPoint; 
		yourself
]

{ #category : #'user interface' }
PBPreferenceView >> horizontalFiller [
	^self horizontalPanel
		hResizing: #spaceFill;
		yourself.
]

{ #category : #'user interface' }
PBPreferenceView >> horizontalPanel [
	^self basicPanel
		cellPositioning: #center;
		listDirection: #leftToRight;
		yourself.
]

{ #category : #'user interface' }
PBPreferenceView >> offerPreferenceNameMenu: aPreferenceBrowser [
	"the user clicked on a preference name -- put up a menu"

	| aMenu readableName |
	readableName := self preference readableName.
	aMenu := MenuMorph new 
		defaultTarget: self preference;
		addTitle: readableName.

	(Preferences okayToChangeProjectLocalnessOf: self preference name) ifTrue:
		[aMenu
			addUpdating: #isProjectLocalString target: self preference action: #toggleProjectLocalness;
			balloonTextForLastItem: 'Some preferences are best applied uniformly to all projects, and others are best set by each individual project.  If this item is checked, then this preference will be printed in bold and will have a separate value for each project'].

	aMenu
		addLine;
		add: 'browse senders' translated
			target: self systemNavigation
			selector: #browseAllSelect:name:autoSelect:
			argumentList: {
				[:m | self preference selectors anySatisfy: [:sel | m hasLiteral: sel]].
				'Preference senders: {1}' translated format: {self preference name}.
				self preference selectors first };
		balloonTextForLastItem: 'This will open a method-list browser on all methods that the send the preference "'
			, readableName , '".'.
	self preference provider ifNotNil: [
		aMenu
			add: 'browse implementation' translated
				target: ToolSet
				selector: #browse:selector:
				argumentList: {
					self preference provider class.
					self preference selectors first };
			balloonTextForLastItem: 'This will open a browser on the method that stores the preference "' , readableName , '".'].
	aMenu
		add: 'inspect preference' translated
			target: self preference
			selector: #inspect;
		balloonTextForLastItem: 'This will open an Inspector on the preference "' , readableName , '".'.
	aMenu
		addLine;
		add: 'show category'
			target: aPreferenceBrowser
			selector: #findCategoryFromPreference:
			argument: self preference;
		balloonTextForLastItem: 'Allows you to find out which category, or categories, this preference belongs to.'.

	Smalltalk isMorphic ifTrue:
		[aMenu
			add: 'hand me a button for this preference'
				target: self
				selector: #tearOffButton;
			balloonTextForLastItem: 'Will give you a button that governs this preference, which you may deposit wherever you wish'].

	aMenu
		add: 'copy name to clipboard'
			target: self preference
			selector: #copyName;
		balloonTextForLastItem: 'Copy the name of the preference to the text clipboard, so that you can paste into code somewhere'.
	aMenu
		add: 'copy code to clipboard'
			target: self preference
			selector: #copyCode;
		balloonTextForLastItem: 'Copy the code to access the current preference value to the clipboard, so that you can paste into code somewhere'.

	aMenu popUpInWorld
]

{ #category : #'user interface' }
PBPreferenceView >> verticalPanel [
	^self basicPanel
		cellPositioning: #topLeft;
		listDirection: #topToBottom;
		yourself.
]
