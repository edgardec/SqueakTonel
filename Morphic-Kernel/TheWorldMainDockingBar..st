Class {
	#name : #TheWorldMainDockingBar,
	#superclass : #Object,
	#classVars : [
		'Instance',
		'ShowSecondsInClock',
		'TS',
		'TwentyFourHourClock'
	],
	#category : #'Morphic-Kernel'
}

{ #category : #preferences }
TheWorldMainDockingBar class >> applyUserInterfaceTheme [

	self updateInstances.
]

{ #category : #'initialize-release' }
TheWorldMainDockingBar class >> cleanUp [
	self updateInstances.
]

{ #category : #preferences }
TheWorldMainDockingBar class >> disableMenuPreference: aPreferenceSymbol [

	self setMenuPreference: aPreferenceSymbol to: false.
]

{ #category : #preferences }
TheWorldMainDockingBar class >> enableMenuPreference: aPreferenceSymbol [

	self setMenuPreference: aPreferenceSymbol to: true.
]

{ #category : #preferences }
TheWorldMainDockingBar class >> getMenuPreference: aPreferenceSymbol [

	^ self getMenuPreference: aPreferenceSymbol ifAbsent: [true]
]

{ #category : #preferences }
TheWorldMainDockingBar class >> getMenuPreference: aPreferenceSymbol ifAbsent: aBlock [

	| project |
	^ (project := Project current) isMorphic
		ifTrue: [project projectPreferenceFlagDictionary at: aPreferenceSymbol ifAbsent: aBlock]
		ifFalse: aBlock

]

{ #category : #'class initialization' }
TheWorldMainDockingBar class >> initialize [
	"self initialize"
	
	Locale addLocalChangedListener: self.
	self updateInstances.
]

{ #category : #access }
TheWorldMainDockingBar class >> instance [
	"Answer the receiver's instance"
	^ Instance ifNil: [ Instance := self new ]
]

{ #category : #access }
TheWorldMainDockingBar class >> instance: aTheWorldMainDockingBar [
	Instance := aTheWorldMainDockingBar.
	self updateInstances
]

{ #category : #events }
TheWorldMainDockingBar class >> localeChanged [
	self updateInstances
]

{ #category : #preferences }
TheWorldMainDockingBar class >> setMenuPreference: aPreferenceSymbol to: aBoolean [
	| project |
	(project := Project current) isMorphic ifTrue: [
		project projectPreferenceFlagDictionary at: aPreferenceSymbol  put: aBoolean.
		(aBoolean ~= (Preferences preferenceAt: aPreferenceSymbol))
			ifTrue: [Preferences setPreference: aPreferenceSymbol toValue: aBoolean]].
	self updateInstances.
]

{ #category : #timestamping }
TheWorldMainDockingBar class >> setTimeStamp [
	"Change the receiver's timeStamp"
	TS := UUID new
]

{ #category : #preferences }
TheWorldMainDockingBar class >> showAppsMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Apps'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Apps'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showAppsMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showAppsMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showAppsMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showDoMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Do'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Do'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showDoMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showDoMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showDoMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showExtrasMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Extras'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Extras'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showExtrasMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showExtrasMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showExtrasMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showHelpMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Help'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Help'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showHelpMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showHelpMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showHelpMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showMainMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Main'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Main'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showMainMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showMainMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showMainMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showProjectsMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Projects'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Projects'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showProjectsMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showProjectsMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showProjectsMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showSecondsInClock [
	<preference: 'Show seconds in clock'
		category: 'docking bars'
		description: 'Whether the clock in the world''s main docking bar should display seconds.'
		type: #Boolean>
	^ ShowSecondsInClock ifNil: [ true ]
]

{ #category : #preferences }
TheWorldMainDockingBar class >> showSecondsInClock: boolean [

	ShowSecondsInClock := boolean.
	self updateInstances.
]

{ #category : #preferences }
TheWorldMainDockingBar class >> showToolsMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Tools'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Tools'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showToolsMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showToolsMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showToolsMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showWindowsMenuInWorldMainDockingBar [
	
	<preference: 'Show ''Windows'' menu in world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should show the ''Windows'' menu.'
		type: #Boolean>
	^ self getMenuPreference: #showWindowsMenuInWorldMainDockingBar ifAbsent: [true]

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showWindowsMenuInWorldMainDockingBar: aBoolean [
	
	self
		setMenuPreference: #showWindowsMenuInWorldMainDockingBar
		to: aBoolean.

]

{ #category : #preferences }
TheWorldMainDockingBar class >> showWorldMainDockingBar [
	
	<preference: 'Show world main docking bar'
		category: 'docking bars'
		description: 'Whether world''s main docking bar should be shown or not.'
		type: #Boolean>
	^Project current showWorldMainDockingBar
]

{ #category : #preferences }
TheWorldMainDockingBar class >> showWorldMainDockingBar: aBoolean [
	
	Project current showWorldMainDockingBar: aBoolean
]

{ #category : #preferences }
TheWorldMainDockingBar class >> themeProperties [

	^ {
		{ #textColor. 'Colors'. 'The color for the clock and other labels.' }.
		{ #font. 'Fonts'. 'The font for the clock and other labels.' }.
		{ #logoColor. 'Colors'. 'The color of the Squeak logo.' }.
		{ #selectionLogoColor. 'Colors'. 'The color of the Squeak logo when it is selected.' }.
	}
]

{ #category : #timestamping }
TheWorldMainDockingBar class >> timeStamp [
	"Answer the receiver's timeStamp"
	^ TS
]

{ #category : #preferences }
TheWorldMainDockingBar class >> twentyFourHourClock [
	<preference: '24-hour Time Clock'
		category: 'docking bars'
		description: 'Whether the clock in the world''s main docking bar should present the time in 24-hour format.'
		type: #Boolean>
	^ TwentyFourHourClock ifNil: [ true ]
]

{ #category : #preferences }
TheWorldMainDockingBar class >> twentyFourHourClock: aBoolean [
	TwentyFourHourClock := aBoolean.
	self updateInstances
]

{ #category : #events }
TheWorldMainDockingBar class >> updateInstances [
	"The class has changed, time to update the instances"

	self setTimeStamp.
	Project current in: [:project |
		project isMorphic ifTrue: [
			project assureMainDockingBarPresenceMatchesPreference]].
]

{ #category : #events }
TheWorldMainDockingBar class >> updateInstances: anEvent [ 
	"The class has changed, time to update the instances"
	(anEvent itemClass == self
			or: [anEvent itemClass == self class])
		ifFalse: [^ self].
	""
	self updateInstances
]

{ #category : #'submenu - squeak' }
TheWorldMainDockingBar >> aboutMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'About Squeak...' translated;
			target: self;
			selector: #aboutSqueak ]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> aboutSqueak [
	
	| m |
	 m := SystemReporter open.
	 m label: 'About Squeak' translated.
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> allOtherWindowsLike: window [
	^ self allVisibleWindows reject: [:each |
		each model name ~= window model name or: [each = window]]
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> allVisibleWindows [
	^SystemWindow windowsIn: Project current world satisfying: [ :w | w visible ]
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> allWindowsLike: window [
	^ self allVisibleWindows reject: [:each | each model ~= window model or: [each = window]]
]

{ #category : #updating }
TheWorldMainDockingBar >> applyUserInterfaceTheme [
	"Do it on the class-side."
]

{ #category : #'submenu - apps' }
TheWorldMainDockingBar >> appsMenuOn: aDockingBar [
	"Create a menu with the registered apps"

	aDockingBar addItem: [ :item |
		item
			contents: 'Apps' translated;
			subMenuUpdater: self
			selector: #listAppsOn: ]

]

{ #category : #'right side' }
TheWorldMainDockingBar >> browseChanges [

	ChangeSorter open.
]

{ #category : #'right side' }
TheWorldMainDockingBar >> browseChangesLabel [
	"The project name is the same as the current change set."
	
	^ Project current name
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> browserMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Browser' translated;
			help: 'Open a browser' translated;
			icon: (self colorIcon: Browser basicNew windowColorToUse);
			target: StandardToolSet;
			selector: #openClassBrowser ]
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> canCloseProject [

	^ self canEnterParentProject
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> canEnterParentProject [
	
	^ Project current isTopProject not
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> canEnterPreviousProject [

	^ Project current previousProject notNil
]

{ #category : #'right side' }
TheWorldMainDockingBar >> clockOn: aDockingBar [ 
	aDockingBar 
		addMorphBack: (ClockMorph new
			font: self fontToUse;
			color: self colorToUse;
			show24hr: self class twentyFourHourClock;
			showSeconds: self class showSecondsInClock;
			yourself);
		addDefaultSpace
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> closeAllWindows [
	self allVisibleWindows do: [:each |
		each model canDiscardEdits ifTrue: [each delete]]
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> closeAllWindowsBut: window [
	(self allOtherWindowsLike: window) do: [:each |
		each model canDiscardEdits ifTrue: [each delete]]
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> closeAllWindowsButWorkspaces [

	(UserDialogBoxMorph
		confirm: 'There might be unsaved changes.\Do you really want to close all windows\that are no workspaces?' withCRs
		title: 'Only keep workspaces') ifTrue: [
			self allVisibleWindows
				reject: [:each | each model isKindOf: Workspace]
				thenDo: [:each | [each delete] valueSupplyingAnswer: true]].
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> closeAllWindowsLike: window [
	self closeAllWindowsBut: window.
	window model canDiscardEdits ifTrue: [window delete]
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> closeAllWindowsUnsafe [

	(UserDialogBoxMorph
		confirm: 'There might be unsaved changes.\Do you really want to close all windows?' withCRs
		title: 'Close All Windows') ifTrue: [
			self allVisibleWindows do: [:each | [each delete] valueSupplyingAnswer: true]].
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> closeProject [

	Project current close.
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> closeProjectMenuItemOn: menu [

	menu addUpdatingItem: [ :item |
		item
			contents: 'Close This Project' translated;
			help: 'Close this project and return to parent one' translated;
			target: self;
			selector: #closeProject;
			enablementSelector: #canCloseProject ]
]

{ #category : #private }
TheWorldMainDockingBar >> colorIcon: aColor [

	"Guess if 'uniform window colors' are used and avoid all icons to be just gray"
	(aColor = (UserInterfaceTheme current get: #uniformWindowColor for: Model) or: [Preferences tinyDisplay]) ifTrue: [ ^nil ].
	^(aColor iconOrThumbnailOfSize: (14 * RealEstateAgent scaleFactor) truncated)
		borderWidth: 3 color: ((UserInterfaceTheme current get: #color for: #MenuMorph) ifNil: [(Color r: 0.9 g: 0.9 b: 0.9)]) muchDarker;
		borderWidth: 2 color: Color transparent
]

{ #category : #private }
TheWorldMainDockingBar >> colorToUse [

	^ self userInterfaceTheme textColor ifNil: [Color black]
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> commandKeyHelp [
	"Open a window giving command key help."

	self
		openHelp: #SqueakTutorialsCommandKey
		topic: nil
]

{ #category : #construction }
TheWorldMainDockingBar >> createDockingBar [
	"Create a docking bar from the receiver's representation"
	
	| dockingBar |
	dockingBar := DockingBarMorph new
		adhereToTop;
		borderWidth: 0.
	self fillDockingBar: dockingBar.
	"self labelIfNeeded: dockingBar."
	^ dockingBar
]

{ #category : #construction }
TheWorldMainDockingBar >> doMenuOn: aDockingBar [ 

	aDockingBar addItem: [ :item |
		item
			contents: 'Do' translated;
			subMenuUpdater: self
			selector: #listCommonRequestsOn: ]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> dualChangeSorterMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Dual Change Sorter' translated;
			help: 'Open a Dual Change Sorter' translated;
			icon: (self colorIcon: ChangeSorter basicNew windowColorToUse);
			target: DualChangeSorter;
			selector: #open ]
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> editCurrentTheme [

	UserInterfaceTheme current explore.
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> enterParentProject [
	
	^ Project returnToParentProject
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> enterPreviousProject [

	^ Project returnToPreviousProject
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> extendingTheSystem [
	
	self
		openHelp: #SqueakProjectHelp
		topic: #extendingTheSystem
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> extrasMenuOn: aDockingBar [ 

	aDockingBar addItem: [ :it|
		it 	contents: 'Extras' translated;
			addSubMenu: [:menu|
				menu addItem:[:item|
					item
						contents: 'Recover Changes' translated;
						help: 'Recover changes after a crash' translated;
						icon: MenuIcons smallDocumentClockIcon;
						target: ChangeList;
						selector: #browseRecentLog].
				menu addItem:[:item|
					item
						contents: 'Recover Method Versions' translated;
						help: 'Recover versions of deleted methods' translated;
						target: ChangeList;
						selector: #browseMethodVersions].				
				menu addLine.
				menu addItem:[:item|
					item
						contents: 'Themes & Colors' translated;
						subMenuUpdater: self
						selector: #themesAndWindowColorsOn: ].
				menu addItem:[:item|
					item
						contents: 'Language' translated;
						subMenuUpdater: self
						selector: #languageTranslatorsOn: ].
				menu addItem:[:item|
					item
						contents: 'Set Author Initials' translated;
						help: 'Sets the author initials' translated;
						icon: MenuIcons smallUserQuestionIcon;
						target: Utilities;
						selector: #setAuthorInitials].
				menu addItem:[:item|
					item
						contents: 'Restore Display (r)' translated;
						help: 'Redraws the entire display' translated;
						target: Project current;
						selector: #restoreDisplay].
				menu addItem:[:item|
					item
						contents: 'Rebuild Menus' translated;
						help: 'Rebuilds the menu bar' translated;
						target: TheWorldMainDockingBar;
						selector: #updateInstances].
				menu addLine.
				menu addItem:[:item|
					item
						contents: 'Start Profiler' translated;
						help: 'Starts the profiler' translated;
						icon: MenuIcons smallTimerIcon;
						target: self;
						selector: #startMessageTally].
				menu addItem:[:item|
					item
						contents: 'Collect Garbage' translated;
						help: 'Run the garbage collector and report space usage' translated;
						target: Utilities;
						selector: #garbageCollectAndReport].
				menu addItem:[:item|
					item
						contents: 'Purge Undo Records' translated;
						help: 'Save space by removing all the undo information remembered in all projects' translated;
						target: CommandHistory;
						selector: #resetAllHistory].
				menu addItem:[:item|
					item
						contents: 'VM statistics' translated;
						help: 'Virtual Machine information' translated;
						target: self;
						selector: #vmStatistics].
				menu addLine.
				menu addItem:[:item|
					item
						contents: 'Graphical Imports' translated;
						help: 'View the global repository called ImageImports; you can easily import external graphics into ImageImports via the FileList' translated;
						target: (Imports default);
						selector: #viewImages].
				menu addItem:[:item|
					item
						contents: 'Standard Graphics Library' translated;
						help: 'Lets you view and change the system''s standard library of graphics' translated;
						target: ScriptingSystem;
						selector: #inspectFormDictionary].
				menu addItem:[:item|
					item
						contents: 'Annotation Setup' translated;
						help: 'Click here to get a little window that will allow you to specify which types of annotations, in which order, you wish to see in the annotation panes of browsers and other tools' translated;
						target: Preferences;
						selector: #editAnnotations].
				menu addItem:[:item|
					item
						contents: 'Browse My Changes' translated;
						help: 'Browse all of my changes since the last time #condenseSources was run.' translated;
						target: SystemNavigation new;
						selector: #browseMyChanges].
			] ]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> fileListMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'File List' translated;
			help: 'Open a file list' translated;
			icon: (self colorIcon: FileList basicNew windowColorToUse);
			target: StandardToolSet;
			selector: #openFileList ]
]

{ #category : #construction }
TheWorldMainDockingBar >> fillDockingBar: aDockingBar [ 
	"Private - fill the given docking bar"
	
	self menusOn: aDockingBar.
	aDockingBar addSpacer.
	self projectNameOn: aDockingBar.
	aDockingBar addSpacer.
	self rightSideOn: aDockingBar.
	aDockingBar
		setProperty: #mainDockingBarTimeStamp 
		toValue: self class timeStamp.
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> fontSizeSummary [
	
	self
		openHelp: #SqueakToolsHelp
		topic: #fontSizeSummary
]

{ #category : #private }
TheWorldMainDockingBar >> fontToUse [

	^ self userInterfaceTheme font ifNil: [TextStyle defaultFont]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> gitInfrastructureMenuItemOn: menu [

	menu addItem: [:item |
			item
				contents: ((Smalltalk hasClassNamed: #SquitBrowser)
					ifTrue: ['Git Browser' translated]
					ifFalse: ['Git Browser (click to install)' translated]);
				help: 'Browse repositories on github.com' translated;
				icon: (self colorIcon: ((Smalltalk classNamed: #SquitBrowser) ifNil: Model)
										basicNew windowColorToUse);			
				target: self;
				selector: #installAndOpenGitBrowser]
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> helpMenuOn: aDockingBar [

	aDockingBar addItem: [ :it |
		it	contents: 'Help' translated;
			addSubMenu: [ :menu | 
				menu addItem: [:item |
						item
							contents: 'Squeak Help' translated;
							help: 'Integrated Help System' translated;
							target: self;
							selector: #squeakHelp].
				
				menu addLine.
				
				menu addItem:[:item|
					item
						contents: 'Online Resources' translated;
						help: 'Online resources for Squeak' translated;
						target: self;
						icon: MenuIcons smallHelpIcon;
						selector: #squeakOnlineResources].
				menu addItem:[:item|
					item
						contents: 'Squeak Swiki' translated;
						help: 'A very simple way to access Squeak Swiki resources in the image' translated;
						target: self;
						selector: #swiki].
				menu addItem:[:item|
					item
						contents: 'Keyboard Shortcuts' translated;
						help: 'Keyboard bindings used in Squeak' translated;
						target: self;
						selector: #commandKeyHelp ].
				menu addItem:[:item|
					item
						contents: 'Font Size Summary' translated;
						help: 'Font size summary.' translated;
						target: self;
						selector: #fontSizeSummary ].
				menu addItem:[:item|
					item
						contents: 'Useful Expressions' translated;
						help: 'Useful expressions' translated;
						target: self;
						selector: #usefulExpressions ].
				menu addLine.
				menu addItem:[:item|
					item
						contents: 'Terse Guide to Squeak' translated;
						help: 'Concise information about language and environment' translated;
						target: self;
						selector: #terseGuideToSqueak].
				menu addItem:[:item|
					item
						contents: 'Extending the system' translated;
						help: 'Includes code snippets to evaluate for extending the system' translated;
						target: self;
						icon: MenuIcons smallHelpIcon;
						selector: #extendingTheSystem].
				menu addLine.
				
			menu addItem:[:item|
				item
					contents: 'Release Notes' translated;
					help: 'Changes in this release' translated ;
					target: self;
					selector: #releaseNotes].
			menu addItem:[:item|
				item
					contents: 'Working With Squeak' translated;
					help: 'Information for new users' ;
					target: self;
					selector: #workingWithSqueak].
			menu addItem:[:item|
				item
					contents: 'The Squeak User Interface' translated;
					help: 'Descriptions of some of the more-unusual UI elements in Squeak' ;
					target: self;
					selector: #squeakUserInterface].
			menu addItem:[:item|
				item
					contents: 'License Information' translated;
					help: String empty ;
					target: self;
					selector: #licenseInformation].				
				
		
			menu addLine.
			menu addItem: [:item |
				item
					contents: 'About Squeak' translated;
					help: 'SystemReporter status of the image and runtime environment' translated;
					target: self;
					selector: #aboutSqueak].
		]]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> installAndOpenGitBrowser [ 
	
	(Smalltalk hasClassNamed: #SquitBrowser)
		ifFalse: [ (UIManager default
					confirm: 'The Git infrastructure and browser is not yet installed.\\Do you want to install the Git Browser?\\(Note that this step requires an internet connection and\may take several minutes.)' withCRs translated
					title: 'Confirm Installation Request' )
			ifTrue: [ Installer
						ensureRecentMetacello;
						installGitInfrastructure.
					TheWorldMainDockingBar updateInstances ]
			ifFalse: [ ^self ] ].
	(Smalltalk classNamed: #SquitBrowser) open.

]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> jumpToProjectMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Enter Project' translated;
			icon: MenuIcons smallProjectJumpIcon;
			subMenuUpdater: self
			selector: #updateJumpToProjectSubMenu: ]
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> languageTranslatorsOn: menu [

	| availableLanguages |
	availableLanguages := NaturalLanguageTranslator availableLanguageLocaleIDs
		sorted:[:x :y | x displayName < y displayName].
	
	availableLanguages do: [:localeID |
		menu addUpdating: #stringForLanguageNameIs: target: Locale selector:  #switchAndInstallFontToID: argumentList: {localeID}].

]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> licenseInformation [
	
	self
		openHelp: #SqueakLicenseHelp
		topic: #officialLicense
]

{ #category : #'submenu - apps' }
TheWorldMainDockingBar >> listAppsOn: menu [
	"Update the apps list in the menu"

	| args |
	TheWorldMenu registeredOpenCommands do:[:spec|
		args := spec second.
		menu addItem: [ :item |
			item
				contents: spec first translated;
				target: args first;
				selector: args second].
	].

]

{ #category : #'submenu - do' }
TheWorldMainDockingBar >> listCommonRequestsOn: aMenu [

	| strings |
	strings := Utilities commonRequestStrings contents.

	strings asString linesDo: [:aString |
		aString = '-'
			ifTrue: [aMenu addLine]
			ifFalse: [aMenu add: (aString ifEmpty: [' ']) target: Utilities selector: #eval: argument: aString]].

	aMenu addLine.
	aMenu add: 'edit this list' translated target: Utilities action: #editCommonRequestStrings.
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> listWindowsOn: menu [

	| windows |
	windows := self allVisibleWindows sorted: [:winA :winB |
		((winA model isNil or: [winB model isNil]) or: [winA model name = winB model name])
			ifTrue: [winA label < winB label]
			ifFalse: [winA model name < winB model name]].
	windows ifEmpty: [ 
		menu addItem: [ :item | 
			item
				contents: 'No Windows' translated;
				isEnabled: false ] ].
	windows do: [ :each |
		| windowColor |
		windowColor := (each model respondsTo: #windowColorToUse)
			ifTrue: [each model windowColorToUse]
			ifFalse: [UserInterfaceTheme current get: #uniformWindowColor for: Model]. 
		menu addItem: [ :item |
			item 
				contents: (self windowMenuItemLabelFor: each);
				icon: (self colorIcon: windowColor);
				target: each;
				selector: #comeToFront;
				subMenuUpdater: self
				selector: #windowMenuFor:on:
				arguments: { each };
				action: [ each beKeyWindow; expand ] ] ].
	menu
		addLine;
		add: 'Collapse all windows' target: (Project current world) selector: #collapseAllWindows;
		add: 'Close all windows' target: self selector: #closeAllWindowsUnsafe;
		addItem: [:item | item
			contents: 'Close all windows without changes';
			target: self;
			icon: MenuIcons smallBroomIcon;
			selector: #closeAllWindows];
		add: 'Close all windows but workspaces' target: self selector: #closeAllWindowsButWorkspaces.
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> loadProject [

	Project current world worldMenu loadProject
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> loadProjectMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Load Project' translated;
			help: 'Load a project from a file and enter it on success' translated;
			target: self;
			selector: #loadProject ]
]

{ #category : #construction }
TheWorldMainDockingBar >> menusOn: aDockingBar [

	self class showMainMenuInWorldMainDockingBar ifTrue: [
		self squeakMenuOn: aDockingBar].

	self class showProjectsMenuInWorldMainDockingBar ifTrue: [
		self projectsMenuOn: aDockingBar].

	self class showToolsMenuInWorldMainDockingBar ifTrue: [
		self toolsMenuOn: aDockingBar].

	self class showAppsMenuInWorldMainDockingBar ifTrue: [
		self appsMenuOn: aDockingBar].

	self class showDoMenuInWorldMainDockingBar ifTrue: [
		self doMenuOn: aDockingBar].

	self class showExtrasMenuInWorldMainDockingBar ifTrue: [
		self extrasMenuOn: aDockingBar].

	self class showWindowsMenuInWorldMainDockingBar ifTrue: [
		self windowsMenuOn: aDockingBar].

	self class showHelpMenuInWorldMainDockingBar ifTrue: [
		self helpMenuOn: aDockingBar].
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> messageNamesMenuItemOn: menu [ 

	menu addItem: [:item | 
		item 
			contents: 'Message Names' translated;
			help: 'Open the Message Names tool' translated;
			icon: (self colorIcon: MessageNames basicNew windowColorToUse);
			target: StandardToolSet;
			selector: #openMessageNames]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> methodFinderMenuItemOn: menu [ 

	menu addItem: [:item | 
		item 
			contents: 'Method Finder' translated;
			help: 'Open the Method Finder' translated;
			icon: (self colorIcon: SelectorBrowser basicNew windowColorToUse);
			target: StandardToolSet;
			selector: #openSelectorBrowser]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> monticelloBrowserMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Monticello Browser' translated;
			help: 'Open a Monticello Browser' translated;
			icon: (self colorIcon: MCTool basicNew windowColorToUse);
			target: MCWorkingCopyBrowser;
			selector: #open ]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> monticelloConfigurationsMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Monticello Configurations' translated;
			help: 'Open a Monticello Configurations Editor' translated;
			icon: (self colorIcon: MCConfigurationBrowser basicNew windowColorToUse);
			target: MCConfigurationBrowser;
			selector: #open ]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> newProject: projectClass [
	"Create a new project of the given type"
	| newProject |
	"Allow the project to return nil from #new to indicate that it was canceled."
	newProject := projectClass new ifNil:[^self].
	ProjectViewMorph openOn: newProject.
	
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> newProjectMenuItemOn: menu [

	Project allSubclasses do: [ :each |
		menu addItem: [ :item | 
			item
				contents: ('Create ', each name) translated;
				help: ('Create a new ', each name, ' and open a viewer for it.') translated;
				target: self;
				selector: #newProject:;
				arguments: { each } ] ] 
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> openHelp: bookSymbol topic: topicSymbol [
	"If a suitable seeming class named bookSymbol exists in the image we open it on the given topic, or on the first page should topic be nil"
	(Smalltalk classNamed: 'HelpBrowser')
		ifNil: [self inform: 'Sorry, there is no help system installed.' translated]
		ifNotNil: [:helpClass |
			(Smalltalk classNamed: bookSymbol)
				ifNil: [self inform: 'Sorry, the help book you requested does not exist.']
				ifNotNil: [:book |
					topicSymbol
						ifNil: [(helpClass openOn: book) model showFirstTopic]
						ifNotNil: [(helpClass openOn: book) model showTopicNamed: topicSymbol]]]
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> parentProjectMenuItemOn: menu [

	menu addUpdatingItem: [ :item |
		item
			contents: 'Enter Parent Project' translated;
			help: 'Return to the parent project' translated;
			target: self;
			selector: #enterParentProject;
			enablementSelector: #canEnterParentProject ]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> preferenceBrowserMenuItemOn: menu [
	Smalltalk at: #PreferenceBrowser ifPresent:[:pb|
		menu addItem: [ :item |
			item
				contents: 'Preferences' translated;
				help: 'Open a Preferences Browser' translated;
				icon: (self colorIcon: pb basicNew windowColorToUse);
				target: pb;
				selector: #open ]
	].
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> previousProjectMenuItemOn: menu [

	menu addUpdatingItem: [ :item |
		item
			contents: 'Enter Previous Project' translated;
			help: 'Return to the most-recently-visited project' translated;
			target: self;
			selector: #enterPreviousProject;
			enablementSelector: #canEnterPreviousProject ]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> processBrowserMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Process Browser' translated;
			help: 'Open a Process Browser' translated;
			icon: (self colorIcon: ProcessBrowser basicNew windowColorToUse);
			target: ProcessBrowser;
			selector: #open ]
]

{ #category : #'right side' }
TheWorldMainDockingBar >> projectNameOn: aDockingBar [
	
	aDockingBar addUpdatingItem: [:item |
		item
			help: 'Browse this project''s changes';
			target: self;
			selector: #browseChanges;
			wordingProvider: self
			wordingSelector: #browseChangesLabel].
]

{ #category : #construction }
TheWorldMainDockingBar >> projectsMenuOn: aDockingBar [

	aDockingBar addItem: [ :item |
		item
			contents: 'Projects' translated;
			addSubMenu: [ :menu | 
				self newProjectMenuItemOn: menu.
				menu addLine.
				self
					saveProjectMenuItemOn: menu;
					loadProjectMenuItemOn: menu.
				menu addLine.
				self
					parentProjectMenuItemOn: menu;
					previousProjectMenuItemOn: menu;
					jumpToProjectMenuItemOn: menu.
				menu addLine.
				self closeProjectMenuItemOn: menu ] ]

]

{ #category : #'submenu - squeak' }
TheWorldMainDockingBar >> quitMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Quit' translated;
			help: 'Quit out of Squeak' translated;
			icon: MenuIcons smallQuitNoSaveIcon;
			target: self;
			selector: #quitSqueak ]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> quitSqueak [

	^Smalltalk
		snapshot: (
			UserDialogBoxMorph 
				confirm: 'Save changes before quitting?' translated 
				orCancel: [ ^self ]
				at: Project current world center)
		andQuit: true

	
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> releaseNotes [
	
	self
		openHelp: #SqueakReleaseNotes
		topic: nil
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> restoreThemeBackground [

	Project current world removeProperty: #hasCustomBackground.
	UserInterfaceTheme current applyTo: {Project current}.
]

{ #category : #construction }
TheWorldMainDockingBar >> rightSideOn: aDockingBar [

	self
		searchBarOn: aDockingBar;
		clockOn: aDockingBar;
		toggleFullScreenOn: aDockingBar.
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> save [

	Smalltalk snapshot: true andQuit: false
]

{ #category : #'submenu - squeak' }
TheWorldMainDockingBar >> saveAndQuitMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Save And Quit' translated;
			help: 'Save the current state of Squeak on disk, and quit out of Squeak' translated;
			target: self;
			selector: #saveAndQuitSqueak ]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> saveAndQuitSqueak [

	Smalltalk snapshot: true andQuit: true
]

{ #category : #'submenu - squeak' }
TheWorldMainDockingBar >> saveAsMenuItemOn: menu [

	menu addItem: [ :item |	
		item
			contents: 'Save As...' translated;
			help: 'Save the current state of Squeak on disk under a new name' translated;
			target: self;
			selector: #saveImageAs ]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> saveAsNewVersion [

	Smalltalk saveAsNewVersion
]

{ #category : #'submenu - squeak' }
TheWorldMainDockingBar >> saveAsNewVersionMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Save As New Version' translated;
			help: 'Save the current state of Squeak on disk under a version-stamped name' translated;
			target: self;
			selector: #saveAsNewVersion ]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> saveImage [

	Smalltalk saveSession
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> saveImageAs [

	Smalltalk saveAs
]

{ #category : #'submenu - squeak' }
TheWorldMainDockingBar >> saveMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Save' translated;
			help: 'Save the current state of Squeak on disk' translated;
			icon: MenuIcons smallSaveIcon;
			target: self;
			selector: #saveImage ]
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> saveProjectMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Save Project' translated;
			help: 'Save this project on a file' translated;
			target: Project current world;
			selector: #saveOnFile ]
]

{ #category : #'right side' }
TheWorldMainDockingBar >> searchBarOn: aDockingBar [

	aDockingBar 
		addMorphBack: (SearchBar build vResizing: #spaceFill; width: 200);
		addDefaultSpace
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> simpleChangeSorterMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Simple Change Sorter' translated;
			help: 'Open a Change Sorter' translated;
			icon: (self colorIcon: ChangeSorter basicNew windowColorToUse);
			target: ChangeSorter;
			selector: #open ]
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> squeakHelp [

	(Smalltalk classNamed: 'HelpBrowser')
		ifNil: [self inform: 'Sorry, there is no help system installed.' translated]
		ifNotNil: [:helpClass | helpClass open].
]

{ #category : #construction }
TheWorldMainDockingBar >> squeakMenuOn: aDockingBar [ 
	"Private - fill the given docking bar"
	
	aDockingBar addItem: [ :item |
		item
			contents: '';
			icon: (MenuIcons squeakLogoIcon dyed:
				(self userInterfaceTheme logoColor ifNil: [Color black]));
			selectedIcon: (MenuIcons squeakLogoIcon dyed:
				(self userInterfaceTheme selectionLogoColor ifNil: [Color white]));
			addSubMenu: [ :menu | 
				self
					aboutMenuItemOn: menu;
					updateMenuItemOn: menu.
				menu addLine.
				self 
					saveMenuItemOn: menu;
					saveAsMenuItemOn: menu;
					saveAsNewVersionMenuItemOn: menu.
				menu addLine.
				self
					saveAndQuitMenuItemOn: menu;
					quitMenuItemOn: menu ] ]
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> squeakOnlineResources [
	
	self
		openHelp: #SqueakProjectHelp
		topic: #squeakResourcesOnline
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> squeakUserInterface [
	
	self
		openHelp: #SqueakProjectHelp
		topic: #squeakUserInterface
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> startMessageTally [
	| world |
	world := Project current world.
	(self confirm: 'MessageTally will start now,
and stop when the cursor goes
to the top of the screen') ifTrue:
		[MessageTally spyOn:
			[[Sensor peekPosition y > 0] whileTrue: [world doOneCycle]]]
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> swiki [
	
	self
		openHelp: #SWikiHelp
		topic: nil
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> terseGuideToSqueak [

	self
		openHelp: #TerseGuideHelp
		topic: nil
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> testRunnerMenuItemOn: menu [
	Smalltalk at: #TestRunner ifPresent:[:aClass|
		menu addItem: [ :item |
			item
				contents: 'Test Runner' translated;
				help: 'Open the Test Runner' translated;
				icon: (self colorIcon: aClass basicNew windowColorToUse);
				target: aClass;
				selector: #open ]
	].
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> themesAndWindowColorsOn: menu [
	| themes |
	menu addItem:[:item|
		item
			contents: (Model useColorfulWindows ifTrue: ['<yes>'] ifFalse: ['<no>']), 'Colorful Windows' translated;
			target: self;
			selector: #toggleColorfulWindows].
	menu addItem:[:item|
		item
			contents: (SystemWindow gradientWindow not ifTrue: ['<yes>'] ifFalse: ['<no>']), 'Flat Widget Look' translated;
			target: self;
			selector: #toggleGradients].
	menu addLine.
	menu addItem:[:item |
		item
			contents: (((Preferences valueOfFlag: #menuAppearance3d ifAbsent: [false]) and: [Morph useSoftDropShadow]) ifTrue: ['<yes>'] ifFalse: ['<no>']), 'Soft Shadows' translated;
			target: self;
			selector: #toggleSoftShadows].
	menu addItem:[:item |
		item
			contents: (((Preferences valueOfFlag: #menuAppearance3d ifAbsent: [false]) and: [Morph useSoftDropShadow not]) ifTrue: ['<yes>'] ifFalse: ['<no>']), 'Hard Shadows' translated;
			target: self;
			selector: #toggleHardShadows].
	menu addLine.
	menu addItem:[:item |
		item
			contents: (SystemWindow roundedWindowCorners ifTrue: ['<yes>'] ifFalse: ['<no>']), 'Rounded Window/Dialog/Menu Look' translated;
			target: self;
			selector: #toggleRoundedWindowLook].
	menu addItem:[:item |
		item
			contents: (PluggableButtonMorph roundedButtonCorners ifTrue: ['<yes>'] ifFalse: ['<no>']), 'Rounded Button/Scrollbar Look' translated;
			target: self;
			selector: #toggleRoundedButtonLook].
	menu addLine.
	themes := UserInterfaceTheme allThemes asArray sort: #name ascending.
	themes ifEmpty: [ 
		menu addItem: [ :item | 
			item
				contents: '(No UI themes found.)' translated;
				isEnabled: false ] ].
	themes do: [ :each |
		menu addItem: [ :item |
			item 
				contents: (UserInterfaceTheme current == each ifTrue: ['<yes>'] ifFalse: ['<no>']), each name;
				target: each;
				selector: #apply ] ].
	menu
		addLine;
		add: 'Increase Font Size' translated target: Preferences selector: #increaseFontSize;
		add: 'Decrease Font Size' translated target: Preferences selector: #decreaseFontSize.
	menu	
		addLine;
		add: 'Set High-DPI Mode' translated target: Preferences selector: #setDemoFonts;
		add: 'Set Etoys Mode' translated target: ReleaseBuilderSqueakland selector: #setEtoysMode.
	menu
		addLine;
		add: 'Restore UI Theme Background' translated target: self selector: #restoreThemeBackground;
		add: 'Edit Current UI Theme...' translated target: self selector: #editCurrentTheme.
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> toggleColorfulWindows [

	Model useColorfulWindows: Model useColorfulWindows not.
]

{ #category : #'right side' }
TheWorldMainDockingBar >> toggleFullScreenOn: aDockingBar [ 
	
	| toggleMorph onIcon offIcon box bgColor |
	offIcon := (MenuIcons fullscreenWireframeIcon dyed:
					(self userInterfaceTheme logoColor ifNil: [Color black])) scaleIconToDisplay.
	onIcon := (MenuIcons fullscreenWireframeIcon dyed:
					(self userInterfaceTheme selectionLogoColor ifNil: [Color white])) scaleIconToDisplay.
	bgColor := (UserInterfaceTheme current get: #selectionColor for: #DockingBarItemMorph) ifNil: [Color blue].
	
	toggleMorph := offIcon asMorph.
	
	box := Morph new
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		listCentering: #center;
		width: toggleMorph width;
		changeTableLayout;
		
		borderWidth: 1;
		borderColor: Color transparent;
		balloonText: 'toggle full screen mode' translated;
		addMorph: toggleMorph.
		
	toggleMorph setToAdhereToEdge: #rightCenter. 
		
	box
		on: #mouseUp
		send: #value
		to:
			[ DisplayScreen toggleFullScreen. 
			"toggleMorph image: MenuIcons smallFullscreenOffIcon" ] ;

		on: #mouseEnter
		send: #value
		to: [
			toggleMorph image: onIcon.
			box color: bgColor; borderColor: bgColor];
		
		on: #mouseLeave
		send: #value
		to: [
			toggleMorph image: offIcon.
			box color: Color transparent; borderColor: Color transparent].
				
	aDockingBar addMorphBack: box
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> toggleGradients [

	| switch |
	switch := SystemWindow gradientWindow not.
	
	SystemWindow gradientWindow: switch.
	DialogWindow gradientDialog: switch.
	MenuMorph gradientMenu: switch.
	ScrollBar gradientScrollBar: switch.
	PluggableButtonMorph gradientButton: switch.
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> toggleHardShadows [

	((Preferences valueOfFlag: #menuAppearance3d ifAbsent: [false]) and: [Morph useSoftDropShadow])
		ifFalse: [Preferences toggle: #menuAppearance3d].
	Morph useSoftDropShadow: false.
	
	SystemWindow refreshAllWindows; reconfigureWindowsForFocus.
	self class updateInstances.
	SystemProgressMorph reset.
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> toggleRoundedButtonLook [

	| switch |
	switch := PluggableButtonMorph roundedButtonCorners not.
	
	PluggableButtonMorph roundedButtonCorners: switch.
	ScrollBar roundedScrollBarLook: switch.
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> toggleRoundedWindowLook [

	| switch |
	switch := SystemWindow roundedWindowCorners not.
	
	SystemWindow roundedWindowCorners: switch.
	DialogWindow roundedDialogCorners: switch.
	MenuMorph roundedMenuCorners: switch.
]

{ #category : #'submenu - extras' }
TheWorldMainDockingBar >> toggleSoftShadows [

	((Preferences valueOfFlag: #menuAppearance3d ifAbsent: [false]) and: [Morph useSoftDropShadow not])
		ifFalse: [Preferences toggle: #menuAppearance3d].
	Morph useSoftDropShadow: true.
	
	SystemWindow refreshAllWindows; reconfigureWindowsForFocus.
	self class updateInstances.
	SystemProgressMorph reset.
]

{ #category : #construction }
TheWorldMainDockingBar >> toolsMenuOn: aDockingBar [ 

	aDockingBar addItem: [ :item |
		item
			contents: 'Tools' translated;
			addSubMenu: [ :menu | 
				self
					browserMenuItemOn: menu;
					workspaceMenuItemOn: menu;
					transcriptMenuItemOn: menu;
					testRunnerMenuItemOn: menu;
					methodFinderMenuItemOn: menu;
					messageNamesMenuItemOn: menu.
				menu addLine.
				self 
					simpleChangeSorterMenuItemOn: menu;
					dualChangeSorterMenuItemOn: menu;
					monticelloBrowserMenuItemOn: menu;
					monticelloConfigurationsMenuItemOn: menu ;
					gitInfrastructureMenuItemOn: menu.
				menu addLine.
				self
					processBrowserMenuItemOn: menu;
					preferenceBrowserMenuItemOn: menu;
					fileListMenuItemOn: menu.
			] ]
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> transcriptMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Transcript' translated;
			help: 'Open the Transcript' translated;
			icon: (self colorIcon: Transcript windowColorToUse);
			target: Transcript;
			selector: #open ]
]

{ #category : #private }
TheWorldMainDockingBar >> updateIfNeeded: aDockingBar [ 
	"Update the given docking bar if needed"
	| timeStamp |
	timeStamp := aDockingBar
					valueOfProperty: #mainDockingBarTimeStamp
					ifAbsent: [].
	timeStamp ~= self class timeStamp
		ifTrue:
			[aDockingBar
				 release;
				 removeAllMorphs.
			 self fillDockingBar: aDockingBar]
]

{ #category : #'submenu - projects' }
TheWorldMainDockingBar >> updateJumpToProjectSubMenu: subMenu [

	subMenu defaultTarget: Project.
	Project current buildJumpToMenu: subMenu
]

{ #category : #'submenu - squeak' }
TheWorldMainDockingBar >> updateMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Update Squeak' translated;
			help: 'Load latest code updates via the internet' translated;
			icon: MenuIcons smallChangesIcon;
			target: self;
			selector: #updateSqueak ]
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> updateSqueak [
	MCMcmUpdater updateFromServer.
]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> usefulExpressions [
	
	self
		openHelp: #SqueakTutorials
		topic: #usefulExpressions
]

{ #category : #'menu actions' }
TheWorldMainDockingBar >> vmStatistics [
	"Open a string view on a report of vm statistics"

	(StringHolder new contents: Smalltalk vmStatisticsReportString)
		openLabel: 'VM Statistics'
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> windowMenuFor: window on: menu [
	menu 
		addItem: [ :item |
			item
				contents: 'Close' translated ;
				target: window;
				selector: #delete ];
		addItem: [ :item |
			item
				contents: 'Close all like this' translated ;
				target: self;
				selector: #closeAllWindowsLike:;
				arguments: { window } ];
		addItem: [ :item |
			item
				contents: 'Close all but this' translated ;
				target: self;
				selector: #closeAllWindowsBut:;
				arguments: { window } ];
		addItem: [ :item |
			item 
				contents: 'Expand or Contract' translated ;
				target: window;
				selector: #expandBoxHit ]
]

{ #category : #'submenu - windows' }
TheWorldMainDockingBar >> windowMenuItemLabelFor: window [
	| s |
	s := WriteStream on: String new.
	window model canDiscardEdits ifFalse: [ s nextPut: $* ].
	window isCollapsed ifTrue: [ s nextPut: $( ].
	s nextPutAll: window label.
	window isCollapsed ifTrue: [ s nextPut: $) ].
	^s contents contractTo: 50
]

{ #category : #construction }
TheWorldMainDockingBar >> windowsMenuOn: aDockingBar [

	aDockingBar addItem: [ :item |
		item
			contents: 'Windows' translated;
			subMenuUpdater: self
			selector: #listWindowsOn: ]

]

{ #category : #'submenu - help' }
TheWorldMainDockingBar >> workingWithSqueak [
	
	self
		openHelp: #SqueakProjectHelp
		topic: #workingWithSqueak
]

{ #category : #'submenu - tools' }
TheWorldMainDockingBar >> workspaceMenuItemOn: menu [

	menu addItem: [ :item |
		item
			contents: 'Workspace' translated;
			help: 'Open a Workspace' translated;
			icon: (self colorIcon: Workspace basicNew windowColorToUse);
			target: StandardToolSet;
			selector: #openWorkspace ]
]
