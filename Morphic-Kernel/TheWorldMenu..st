"
Instances of TheWorldMenu serve to present the primary Squeak menu obtained by clicking on open desktop, which is variously spoken of as the ""screen menu"", the ""desktop menu"", or the ""world menu"".

myProject is the Project I pertain to.
myWorld is the world, a PasteUpMorph, that I pertain to.
myHand is the hand that invoked the menu.
"
Class {
	#name : #TheWorldMenu,
	#superclass : #Object,
	#instVars : [
		'myProject',
		'myWorld',
		'myHand'
	],
	#classVars : [
		'OpenMenuRegistry'
	],
	#category : #'Morphic-Kernel'
}

{ #category : #'class initialization' }
TheWorldMenu class >> cleanUp [
	"Flush out obsolete entries"

	self removeObsolete
]

{ #category : #'open-menu registry' }
TheWorldMenu class >> loadSqueakMap [
	"Load the externally-maintained SqueakMap package if it is not already loaded.  Based on code by Göran Hultgren"

	| server |
	Socket initializeNetwork.
	server := #('map1.squeakfoundation.org' 'map2.squeakfoundation.org' 'map.squeak.org' 'map.bluefish.se' 'marvin.bluefish.se:8000')
		detect: [:srv | | addr answer |
			addr := NetNameResolver addressForName: (srv upTo: $:) timeout: 5.
			addr notNil and: [
				answer := HTTPSocket httpGet: ('http://', srv, '/sm/ping').
				answer isString not and: [answer contents = 'pong']]]
		ifNone: [^ self inform: 'Sorry, no SqueakMap master server responding.'].
	server ifNotNil: ["Ok, found an SqueakMap server"
		ChangeSet newChangesFromStream:
			((('http://', server, '/sm/packagebyname/squeakmap/downloadurl')
			asUrl retrieveContents content) asUrl retrieveContents content unzipped
			readStream)
		named: 'SqueakMap']
]

{ #category : #'open-menu registry' }
TheWorldMenu class >> openPackageLoader [
	"If this method is reached, it means that SMLoader has not yet been loaded; after SqueakMap has come into the image, a different receiver/selector will have been installed under 'Package Loader'; if this method is reached when theoretically SqueakMap is already loaded, presumably this is a grandfathered menu item in a still-up menu, so get the message on to its appropriate recipient."

	| loaderClass |
	((loaderClass := Smalltalk at: #SMLoader ifAbsent: [nil]) isKindOf: Class)
		ifTrue:
			[^ loaderClass open].

	(self confirm: 
'This requires that you first install "SqueakMap" into your image.
SqueakMap is a new architecture for finding, installing, and
publishing packages in Squeak.
Would you like to install SqueakMap now?' )
		ifTrue:
			[self loadSqueakMap]
]

{ #category : #'open-menu registry' }
TheWorldMenu class >> registerOpenCommand: anArray [
	"The array received should be of form {'A Label String'. {TargetObject. #command}  'A Help String'} ; the final element is optional but if present will be used to supply balloon help for the menu item in the Open menu.
	If any previous registration of the same label string is already known, delete the old one."

	self unregisterOpenCommand: anArray first.
	OpenMenuRegistry addLast: anArray
]

{ #category : #'open-menu registry' }
TheWorldMenu class >> registeredOpenCommands [
	"Answer the list of dynamic open commands, sorted by description"
	
	^self registry asArray sort: [ :a :b | a first asLowercase < b first asLowercase ]
]

{ #category : #'open-menu registry' }
TheWorldMenu class >> registry [
	"Answer the registry of dynamic open commands"
	
	^OpenMenuRegistry ifNil: [OpenMenuRegistry := OrderedCollection new].

]

{ #category : #'open-menu registry' }
TheWorldMenu class >> removeObsolete [
	"Remove all obsolete commands"	
	self registry removeAllSuchThat: [:e | e second first class isObsolete].
]

{ #category : #'open-menu registry' }
TheWorldMenu class >> unregisterOpenCommand: label [
	"Remove the open command with the given label from the registry"
	
	self registry removeAllSuchThat: [:e | e first = label]
]

{ #category : #'open-menu registry' }
TheWorldMenu class >> unregisterOpenCommandWithReceiver: aReceiver [
	"Remove the open command with the given object as receiver from the registry"
	
	self registry removeAllSuchThat: [:e | e second first == aReceiver]
]

{ #category : #menu }
TheWorldMenu >> addGestureHelpItemsTo: aMenuMorph [ 

]

{ #category : #construction }
TheWorldMenu >> addObjectsAndTools: menu [
	self
		fillIn: menu
		from: {
			nil.
			{ 'objects (o)'. { #myWorld. #activateObjectsTool }. 'A tool for finding and obtaining many kinds of objects' }.
			{ 'new morph...'. { self. #newMorph }. 'Offers a variety of ways to create new objects' }.
			nil.
			{ 'authoring tools...'. { self. #scriptingDo }. 'A menu of choices useful for authoring' }.
			{ 'playfield options...'. { self. #playfieldDo }. 'A menu of options pertaining to this object as viewed as a playfield' }.
			{ 'flaps...'. { self. #flapsDo }. 'A menu relating to use of flaps.  For best results, use "keep this menu up"' }.
			{ 'projects...'. { self. #projectDo }. 'A menu of commands relating to use of projects' }.
			{ 'telemorphic...' . {self. #remoteDo}.  'commands for doing multi-machine "telemorphic" experiments'}.
			nil
		}
]

{ #category : #construction }
TheWorldMenu >> addPrintAndDebug: menu [
	Preferences simpleMenus ifFalse: [
		self
			fillIn: menu
			from: {
				{ 'make screenshot'. {self. #saveScreenshot}. 'makes a screenshot and saves it to disk'}.
				"{ 'print PS to file...'. { self. #printWorldOnFile }. 'write the world into a postscript file' }."
				{ 'debug...'. { self. #debugDo }. 'a menu of debugging items' }
			} ]
]

{ #category : #construction }
TheWorldMenu >> addProjectEntries: menu [
	self
		fillIn: menu
		from: {
			nil.
			{ 'previous project'. { #myWorld. #goBack }. 'return to the most-recently-visited project' }.
			{ 'jump to project...'. { #myWorld. #jumpToProject }. 'put up a list of all projects, letting me choose one to go to' }.
			{ 'save project on file...'. { #myWorld. #saveOnFile }. 'save this project on a file' }.
			{'load project from file...'. {self. #loadProject}. 'load a project from a file' }.
			nil
		}
]

{ #category : #construction }
TheWorldMenu >> addRestoreDisplay: menu [
	self
		fillIn: menu
		from: {
			{'restore display (r)'. { Project current. #restoreDisplay }. 'repaint the screen -- useful for removing unwanted display artifacts, lingering cursors, etc.' }.
			nil
		}
]

{ #category : #construction }
TheWorldMenu >> addSaveAndQuit: menu [
	self
		fillIn: menu
		from: {
			nil.
			{ 'save'. { Smalltalk. #saveSession }. 'save the current version of the image on disk' }.
			{ 'save as...'. { Smalltalk. #saveAs }. 'save the current version of the image on disk under a new name.' }.
			{ 'save as new version'. { Smalltalk. #saveAsNewVersion }. 'give the current image a new version-stamped name and save it under that name on disk.' }.
			{ 'save and quit'. { self. #saveAndQuit }. 'save the current image on disk, and quit out of Squeak.' }.
			{ 'quit'. { self. #quitSession }. 'quit out of Squeak.' }
		}
]

{ #category : #construction }
TheWorldMenu >> addUtilities: menu [
	Preferences simpleMenus ifFalse: [
		self
			fillIn: menu
			from: {
				{ 'open...'. { self. #openWindow } }.
				{ 'windows...'. { self. #windowsDo } }.
				{ 'changes...'. { self. #changesDo } }
			} ].
	self
		fillIn: menu
		from: {
			{ 'help...'. { self. #helpDo }. 'puts up a menu of useful items for updating the system, determining what version you are running, and much else' }.
			{ 'appearance...'. { self. #appearanceDo }. 'put up a menu offering many controls over appearance.' }
		}.
	Preferences simpleMenus ifFalse: [
		self
			fillIn: menu
			from: {
				{ 'do...'. { Utilities. #offerCommonRequests }. 'put up an editible list of convenient expressions, and evaluate the one selected.' }
			} ]
]

{ #category : #construction }
TheWorldMenu >> alphabeticalMorphMenu [
	| list splitLists menu firstChar lastChar subMenu |
	list := Morph withAllSubclasses select: [:m | m includeInNewMorphMenu].
	list := list sorted: [:c1 :c2 | c1 name < c2 name].
	splitLists := self splitNewMorphList: list depth: 3.
	menu := MenuMorph new defaultTarget: self.
	1 to: splitLists size
		do: 
			[:i | 
			firstChar := i = 1 
				ifTrue: [$A]
				ifFalse: 
					[((splitLists at: i - 1) last name first asInteger + 1) 
								asCharacter].
			lastChar := i = splitLists size 
						ifTrue: [$Z]
						ifFalse: [(splitLists at: i) last name first].
			subMenu := MenuMorph new.
			(splitLists at: i) do: 
					[:cl | 
					subMenu 
						add: cl name
						target: self
						selector: #newMorphOfClass:event:
						argument: cl].
			menu add: firstChar asString , ' - ' , lastChar asString subMenu: subMenu].
	^menu
]

{ #category : #popups }
TheWorldMenu >> appearanceDo [
	"Build and show the appearance menu for the world."

	self doPopUp: self appearanceMenu
]

{ #category : #construction }
TheWorldMenu >> appearanceMenu [
	"Build the appearance menu for the world."

	^self fillIn: (self menu: 'appearance...') from: {

		{'preferences...' . { self . #openPreferencesBrowser} . 'Opens a "Preferences Browser" which allows you to alter many settings' } .
		{'choose set of preferences...' . { Preferences . #offerThemesMenu} . 'Presents you with a menu of sets or preferences; each item''s balloon-help will tell you about the particular set.  If you choose one, many different preferences that come along are set at the same time; you can subsequently change any settings by using a Preferences Panel'} .
		nil .
		{'system fonts...' . { self . #standardFontDo} . 'Choose the standard fonts to use for code, lists, menus, window titles, etc.'}.
		nil.
		{#menuColorString . { self . #toggleMenuColorPolicy} . 'Governs whether menu colors should be derived from the desktop color.'}.
		{#roundedCornersString . { self . #toggleRoundedCorners} . 'Governs whether morphic windows and menus should have rounded corners.'}.
		nil.
		{'full screen on' . { DisplayScreen . #fullScreenOn} . 'puts you in full-screen mode, if not already there.'}.
		{'full screen off' . { DisplayScreen . #fullScreenOff} . 'if in full-screen mode, takes you out of it.'}.
		nil.
		{'set display depth...' . {self. #setDisplayDepth} . 'choose how many bits per pixel.'}.
		{'set desktop color...' . {self. #changeBackgroundColor} . 'choose a uniform color to use as desktop background.'}.
		{'set gradient color...' . {self. #setGradientColor} . 'choose second color to use as gradient for desktop background.'}.
		{'use texture background' . { #myWorld . #setStandardTexture} . 'apply a graph-paper-like texture background to the desktop.'}.
		nil.
		{'clear turtle trails from desktop' . { #myWorld . #clearTurtleTrails} . 'remove any pigment laid down on the desktop by objects moving with their pens down.'}.
		{'pen-trail arrowhead size...' . { Preferences. #setArrowheads} . 'choose the shape to be used in arrowheads on pen trails.'}.

	}
]

{ #category : #construction }
TheWorldMenu >> buildWorldMenu [
	"Build the menu that is put up when the screen-desktop is clicked on"
	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu commandKeyHandler: self.
	self colorForDebugging: menu.
	menu addStayUpItem.
	self makeConvenient: menu.
	Smalltalk at: #ServiceGUI ifPresent:[:sgui|
		sgui worldMenu: menu.
		sgui onlyServices ifTrue: [^ menu].
	].
	self addProjectEntries: menu.
	myWorld addUndoItemsTo: menu.
	self addRestoreDisplay: menu.
	self addUtilities: menu.
	self addObjectsAndTools: menu.
	self addPrintAndDebug: menu.
	self addSaveAndQuit: menu.
	^ menu
]

{ #category : #commands }
TheWorldMenu >> changeBackgroundColor [
	"Let the user select a new background color for the world"
	myWorld
		changeColorTarget: myWorld
		selector: #setAsBackground:
		originalColor: myWorld fillStyle asColor
		hand: myWorld activeHand
]

{ #category : #popups }
TheWorldMenu >> changesDo [
	"Build the changes menu for the world."

	self doPopUp: self changesMenu
]

{ #category : #construction }
TheWorldMenu >> changesMenu [
        "Build the changes menu for the world."

        | menu |
        menu := self menu: 'changes...'.
        self fillIn: menu from: {
                { 'file out current change set' . { ChangeSet current . #verboseFileOut}.
                                'Write the current change set out to a file whose name reflects the change set name and the current date & time.'}.
                { 'create new change set...' . { ChangeSet . #newChangeSet}. 'Create a new change set and make it the current one.'}.
                { 'browse changed methods' . { ChangeSet  . #browseChangedMessages}.  'Open a message-list browser showing all methods in the current change set'}.
                { 'check change set for slips' . { self  . #lookForSlips}.
                                'Check the current change set for halts, references to the Transcript, etc., and if any such thing is found, open up a message-list browser detailing all possible slips.'}.

                nil.
                { 'simple change sorter' . {self. #openChangeSorter1}.  'Open a 3-paned changed-set viewing tool'}.
                { 'dual change sorter' . {self. #openChangeSorter2}.
                                'Open a change sorter that shows you two change sets at a time, making it easy to copy and move methods and classes between them.'}.
               { 'find a change sorter (C)' . { #myWorld . #findAChangeSorter: }. 'Brings an open change sorter to the front, creating one if necessary, and makes it the active window'}.
                nil.
                { 'browse recent submissions (R)' . { Utilities . #browseRecentSubmissions}.
                                'Open a new recent-submissions browser.  A recent-submissions browser is a message-list browser that shows the most recent methods that have been submitted.  If you submit changes within that browser, it will keep up-to-date, always showing the most recent submissions.'}.
			{ 'browse my changes' . { SystemNavigation new . #browseMyChanges }.
					'Browse all of my changes since the last time #condenseSources was run.'}.
			nil.
                { 'recently logged changes...' . { self . #browseRecentLog}.'Open a change-list browser on the latter part of the changes log.  You can use this browser to recover logged changes which were not saved in your image, in the event of a crash or other interruption.'}.

                { 'recent log file...' . { Smalltalk . #writeRecentToFile}.
                                'Create a file holding the logged changes (going as far back as you wish), and open a window on that file.'}.

                nil.
                { 'save world as morph file' . {self. #saveWorldInFile}. 'Save a file that, when reloaded, reconstitutes the current World.'}.
                nil.
        }.
        ^ menu
]

{ #category : #commands }
TheWorldMenu >> cleanUpWorld [
	(UIManager default confirm:
'This will remove all windows except those
containing unsubmitted text edits, and will
also remove all non-window morphs (other
than flaps) found on the desktop.  Are you
sure you want to do this?' translated)
		ifFalse: [^ self].

	myWorld allNonFlapRelatedSubmorphs do:
		[:m | m delete].
	(SystemWindow windowsIn: myWorld satisfying: [:w | w model canDiscardEdits])
		do: [:w | w delete]
]

{ #category : #construction }
TheWorldMenu >> colorForDebugging: aMenu [

        "aMenu color: self myMenuColor"

        "aMenu color: Color lightRed"


]

{ #category : #action }
TheWorldMenu >> commandKeyTypedIntoMenu: evt [
	"The user typed a command-key into the given menu; dispatch it"

	myWorld keystrokeInWorld: evt 
]

{ #category : #popups }
TheWorldMenu >> debugDo [

	self doPopUp: self debugMenu
]

{ #category : #construction }
TheWorldMenu >> debugMenu [

        | menu |

        menu := self menu: 'debug...'.
        self fillIn: menu from: { 
                { 'inspect world' . { #myWorld . #inspect } }.
                { 'explore world' . { #myWorld . #explore } }.
                { 'inspect model' . { myWorld model . #inspect } }.
                        " { 'talk to world...' . { self . #typeInMessageToWorld } }."
                { 'start MessageTally' . { self . #startMessageTally } }.
                { 'start/browse MessageTally' . { self . #startThenBrowseMessageTally } }.
                { 'open process browser' . { self . #openProcessBrowser } }.
                nil.
                        "(self hasProperty: #errorOnDraw) ifTrue:  Later make this come up only when needed."
                { 'start drawing again' . { #myWorld . #resumeAfterDrawError } }.
                { 'start stepping again' . { #myWorld . #resumeAfterStepError } }.
                nil.
                { 'call #tempCommand' . { #myWorld . #tempCommand } }.
                { 'define #tempCommand' . { #myWorld . #defineTempCommand } }.
        }.
	self haltOnceEnabled
		ifTrue: [menu
				add: 'disable halt/inspect once' translated
				target: menu
				action: #clearHaltOnce]
		ifFalse: [menu
				add: 'enable halt/inspect once' translated
				target: menu
				action: #setHaltOnce].
	^menu
	
]

{ #category : #action }
TheWorldMenu >> doMenuItem: aCollection with: event [
	| realTarget selector nArgs |
	selector := aCollection second.
	nArgs := selector numArgs.
	realTarget := aCollection first.
	realTarget == #myWorld ifTrue: [realTarget := myWorld].
	realTarget == #myHand ifTrue: [realTarget := myHand].
	realTarget == #myProject ifTrue: [realTarget := self projectForMyWorld].
	^nArgs = 0 
		ifTrue:[realTarget perform: selector]
		ifFalse:[realTarget perform: selector with: event].

]

{ #category : #popups }
TheWorldMenu >> doPopUp: aMenu [

	aMenu popUpForHand: myHand in: myWorld.

]

{ #category : #construction }
TheWorldMenu >> fillIn: aMenu from: dataForMenu [
	"A menu constructor utility by RAA.  dataForMenu is a list of items which mean:
			nil							Indicates to add a line

			first element is symbol		Add updating item with the symbol as the wording selector
			second element is a list		second element has the receiver and selector

			first element is a string		Add menu item with the string as its wording
			second element is a list		second element has the receiver and selector

			a third element exists		Use it as the balloon text
			a fourth element exists		Use it as the enablement selector (updating case only)"
	

	dataForMenu do: [ :itemData | | item |
		itemData ifNil: [aMenu addLine] ifNotNil:
			[item := (itemData first isKindOf: Symbol)
				ifTrue: 
					[aMenu 
						addUpdating: itemData first 
						target: self 
						selector: #doMenuItem:with: 
						argumentList: {itemData second}]
				 ifFalse:
					[aMenu 
						add: itemData first translated
						target: self 
						selector: #doMenuItem:with: 
						argumentList: {itemData second}].
			itemData size >= 3 ifTrue:
				[aMenu balloonTextForLastItem: itemData third translated.
			itemData size >= 4 ifTrue:
				[item enablementSelector: itemData fourth]]]].

	^ aMenu
]

{ #category : #commands }
TheWorldMenu >> garbageCollect [
	"Do a garbage collection, and report results to the user."

	Utilities garbageCollectAndReport
]

{ #category : #popups }
TheWorldMenu >> helpDo [
	"Build and show the help menu for the world."

	self doPopUp: self helpMenu
]

{ #category : #construction }
TheWorldMenu >> helpMenu [
        "Build the help menu for the world."
        |  menu |

  	menu := self menu: 'help...'.

        self fillIn: menu from:
        {
                {'about this system...'. {Smalltalk. #aboutThisSystem}. 'current version information.'}.
                {'update code from server'. {MCMcmUpdater. #updateFromServer}. 'load latest code updates via the internet'}.
                {'preferences...'. {self. #openPreferencesBrowser}. 'view and change various options.'}.
			 {'set language...' . {Project. #chooseNaturalLanguage}. 'choose the language in which tiles should be displayed.'} .
                nil.
               {'command-key help'. { TheWorldMainDockingBar instance . #commandKeyHelp}. 'summary of keyboard shortcuts.'}
	}.

	self addGestureHelpItemsTo: menu.

	self fillIn: menu from:
	{
                {'world menu help'. { self . #worldMenuHelp}. 'helps find menu items buried in submenus.'}.
                        "{'info about flaps' . { Utilities . #explainFlaps}. 'describes how to enable and use flaps.'}."
                {'font size summary' . { TextStyle . #fontSizeSummary}.  'summary of names and sizes of available fonts.'}.
                {'useful expressions' . { Utilities . #openStandardWorkspace}. 'a window full of useful expressions.'}.
			 {'annotation setup...' . { Preferences . #editAnnotations}. 'Click here to get a little window that will allow you to specify which types of annotations, in which order, you wish to see in the annotation panes of browsers and other tools'}.
			nil.
                {'graphical imports' . { Imports default . #viewImages}.  'view the global repository called ImageImports; you can easily import external graphics into ImageImports via the FileList'}.
                {'standard graphics library' . { ScriptingSystem . #inspectFormDictionary}.  'lets you view and change the system''s standard library of graphics.'}.
                nil.
                {'telemorphic...' . {self. #remoteDo}.  'commands for doing multi-machine "telemorphic" experiments'}.
                {#soundEnablingString . { SoundService . #toggleSoundEnabled}. 'turning sound off will completely disable Squeak''s use of sound.'}.
                nil.

                {'set author initials...' . { Utilities . #setAuthorInitials }. 'supply initials to be used to identify the author of code and other content.'}.
                {'vm statistics' . { self . #vmStatistics}.  'obtain some intriguing data about the vm.'}.
			  nil.
			  {'purge undo records' . { CommandHistory . #resetAllHistory }. 'save space by removing all the undo information remembered in all projects.'}.
                {'space left' . { self . #garbageCollect}. 'perform a full garbage-collection and report how many bytes of space remain in the image.'}.
        }.

	^menu


]

{ #category : #commands }
TheWorldMenu >> loadProject [

	| fName |
	"Put up a Menu and let the user choose a '.project' file to load.  Create a thumbnail and jump into the project."

	Project canWeLoadAProjectNow ifFalse: [^ self].
	fName := UIManager default chooseFileMatchingSuffixes: #('pr' 'project').
	fName ifNil:[^nil].

	FileDirectory splitName: fName to:[:dir :file|
			ProjectLoading 
				openFromDirectory: dir
				andFileName: file]

]

{ #category : #commands }
TheWorldMenu >> lookForSlips [

	ChangeSet current lookForSlips
]

{ #category : #construction }
TheWorldMenu >> makeConvenient: menu [
	self
		fillIn: menu
		from: {
			{ 'Browser'. { StandardToolSet. #openClassBrowser }. 'open a browser' }.
			{ 'Workspace'. { Workspace. #open }. 'open a workspace' }.
			{ 'Transcript'. { Transcript. #open }. 'open a transcript' }.
			Smalltalk at: #TestRunner ifPresent:[:aClass|
				{ 'Test Runner'. { aClass. #open }. 'open a test runner' }.
			].
			nil
		}
]

{ #category : #mechanics }
TheWorldMenu >> menu: titleString [
	"Create a menu with the given title, ready for filling"

	| menu |
	(menu := MenuMorph entitled: titleString translated) 
		defaultTarget: self; 
		addStayUpItem;
		commandKeyHandler: self.
	self colorForDebugging: menu.
	^ menu

]

{ #category : #action }
TheWorldMenu >> menuColorString [

	^ Preferences menuColorString
]

{ #category : #commands }
TheWorldMenu >> mvcProjectsAllowed [

	^Preferences mvcProjectsAllowed and: [Smalltalk includesKey: #StandardSystemView]
]

{ #category : #construction }
TheWorldMenu >> newMorph [
	"The user requested 'new morph' from the world menu.  Put up a menu that allows many ways of obtaining new morphs."

	| menu |

	menu := self menu: 'Add a new morph'.
	menu 
		add: 'from paste buffer' translated target: myHand action: #pasteMorph;
		add: 'from alphabetical list' translated subMenu: self alphabeticalMorphMenu;
		add: 'from a file...' translated target: self action: #readMorphFromAFile.
	menu addLine.
	menu add: 'grab rectangle from screen' translated target: myWorld action: #grabDrawingFromScreen:;
		add: 'grab with lasso from screen' translated target: myWorld action: #grabLassoFromScreen:;
		add: 'grab rubber band from screen' translated target: myWorld action: #grabRubberBandFromScreen:;
		add: 'grab flood area from screen' translated target: myWorld action: #grabFloodFromScreen:.
	menu addLine.
	menu add: 'make new drawing' translated target: myWorld action: #newDrawingFromMenu:;
		add: 'make link to project...' translated target: self action: #projectThumbnail.

	self doPopUp: menu.

]

{ #category : #commands }
TheWorldMenu >> newMorphOfClass: morphClass event: evt [
	"Attach a new morph of the given class to the invoking hand."

	| m |
	m := morphClass new.
	m installModelIn: myWorld.  "a chance to install model pointers"
	m wantsToBeOpenedInWorld
		ifTrue:[myWorld addMorph: m]
		ifFalse:[evt hand attachMorph: m].
	myWorld startSteppingSubmorphsOf: m.

]

{ #category : #commands }
TheWorldMenu >> openBrowser [ 
	"Create and schedule a Browser view for browsing code."
	ToolSet browse: nil selector: nil
]

{ #category : #commands }
TheWorldMenu >> openFileDirectly [

	FileList openFileDirectly
]

{ #category : #commands }
TheWorldMenu >> openFileList [
	FileList open.
]

{ #category : #commands }
TheWorldMenu >> openMVCProject [
	"Open a new MVC project (only if MVC is present)"
	Smalltalk at: #MVCProject ifPresent:[:projClass|
		ProjectViewMorph openOn: projClass new.
	].
]

{ #category : #construction }
TheWorldMenu >> openMenu [
	"Build the open window menu for the world."

	| menu |
	menu := self menu: 'open...'.
	menu defaultTarget: ToolSet default.
	menu addList: ToolSet menuItems.
	menu defaultTarget: self.
	self fillIn: menu from: {
		nil.
		{'file...' . { self . #openFileDirectly} . 'Lets you open a window on a single file'}.
		{'transcript (t)' . {self . #openTranscript}. 'A window used to report messages sent to Transcript' }.
		"{'inner world' . { WorldWindow . #test1} }."
		nil.
	}.
	self fillIn: menu from: self class registeredOpenCommands.
	menu addLine.

	self mvcProjectsAllowed ifTrue:
		[self fillIn: menu from: { {'mvc project' . {self. #openMVCProject} . 'Creates a new project of the classic "mvc" style'} }].

	self fillIn: menu from: { 
		{'morphic project' . {self. #openMorphicProject} . 'Creates a new morphic project'}.
	}.
	Smalltalk at: #SMxMorphicProject ifPresent: [:p |
		self fillIn: menu from: { 
			{ 'simple morphic project' . { self . #openSMxMorphicProject } . 'Creates a new simple morphic project' }.
		}
	].
	^menu

]

{ #category : #commands }
TheWorldMenu >> openMorphicProject [
	"Open a morphic project from within a morphic project"
	MorphicProject openViewOn: nil

]

{ #category : #commands }
TheWorldMenu >> openPreferencesBrowser [
	"Open a preferences browser"
	^Smalltalk at: #PreferenceBrowser ifPresent:[:pb| pb open].

]

{ #category : #commands }
TheWorldMenu >> openTranscript [

	Transcript openLabel: 'Transcript'
]

{ #category : #popups }
TheWorldMenu >> openWindow [

	self doPopUp: self openMenu
]

{ #category : #commands }
TheWorldMenu >> openWorkspace [

	UIManager default edit: '' label: 'Workspace'
]

{ #category : #popups }
TheWorldMenu >> projectDo [
	"Build and show the project menu for the world."

	self doPopUp: self projectMenu
]

{ #category : #commands }
TheWorldMenu >> projectForMyWorld [

        ^myProject ifNil: [myProject := myWorld project]
]

{ #category : #construction }
TheWorldMenu >> projectMenu [
	"Build the project menu for the world."
	| menu |

	self flag: #bob0302.

	menu := self menu: 'projects...'.
	self fillIn: menu from: { 
		{ 'save on server (also makes a local copy)' . { #myProject . #storeOnServer } }.
		{ 'save to a different server' . { #myProject . #saveAs } }.
		{ 'save project on local file only' . { #myWorld . #saveOnFile } }.
		{ 'see if server version is more recent...' . { #myProject . #loadFromServer } }.
		{ 'load project from file...' . { self . #loadProject } }.
		nil.
	}.

	self mvcProjectsAllowed ifTrue: [
		self fillIn: menu from: {
			{ 'create new mvc project'. { self . #openMVCProject } }.
		}
	].
	self fillIn: menu from: { 
		{ 'create new morphic project' . { self . #openMorphicProject } }.
	}.
	Smalltalk at: #SMxMorphicProject ifPresent: [:p |
		self fillIn: menu from: { 
			{ 'create new simple morphic project' . { self . #openSMxMorphicProject } }.
		}
	].
	self fillIn: menu from: { 
		nil.
		{ 'go to previous project' . { Project . #returnToPreviousProject } }.
		{ 'go to next project' . { Project . #advanceToNextProject } }.
		{ 'jump to project...' . { #myWorld . #jumpToProject } }.
	}.
	Preferences simpleMenus ifFalse: [
		self fillIn: menu from: { 
			nil.
			{ 'save for future revert' . { #myProject . #saveForRevert } }.
			{ 'revert to saved copy' . { #myProject . #revert } }.
		}.
	].

	^ menu
]

{ #category : #action }
TheWorldMenu >> projectThumbnail [
	"Offer the user a menu of project names. Attach to the hand a thumbnail of the project the user selects."

	| projName pr names values |
	names := OrderedCollection with: Project current name, ' (current)'.
	values := OrderedCollection with: Project current name.
	Project allNames do: [:n | names add: n. values add: n].
	projName := UIManager default 
		chooseFrom: names values: values lines: #(1) title: 'Select a project'.
	projName ifNotNil:
		[(pr := Project named: projName) 
			ifNotNil: [myHand attachMorph: (ProjectViewMorph on: pr)]
			ifNil: [self inform: 'can''t seem to find that project']].
]

{ #category : #commands }
TheWorldMenu >> quitSession [

	Smalltalk
		snapshot: (UserDialogBoxMorph 
			confirm: 'Save changes before quitting?' translated 
			orCancel: [^ self]
			at: Project current world center)
		andQuit: true
]

{ #category : #commands }
TheWorldMenu >> readMorphFromAFile [
	"Produce a morph from a file -- either a saved .morph file or a graphics file"

	| morphOrList ff aName f m |
	aName := UIManager default chooseFileMatchingSuffixes: (Form allTypicalFileExtensions add: 'morph'; yourself) label: 'Choose a file to load' translated.
	aName ifNil: [^ self].  "User made no choice"

	(aName asLowercase endsWith: '.morph')
		ifTrue:
			[ff := FileStream readOnlyFileNamed: aName.
			morphOrList := ff fileInObjectAndCode.		"code filed in is the Model class"
			"the file may contain either a single morph or an array of morphs"
			myWorld addMorphsAndModel: morphOrList]
		ifFalse:
			[f := Form fromFileNamed: aName.
			f ifNil: [^ self error: 'unrecognized image file format' translated].
			m := myWorld drawingClass new form: f.
			myHand attachMorph: m]

]

{ #category : #popups }
TheWorldMenu >> remoteDo [

	self doPopUp: self remoteMenu
]

{ #category : #construction }
TheWorldMenu >> remoteMenu [
        "Build the Telemorphic menu for the world."

        ^self fillIn: (self menu: 'Telemorphic' translatedNoop) from: {
                { 'local host address' translatedNoop. { #myWorld . #reportLocalAddress } }.
                { 'connect remote user' translatedNoop. { #myWorld . #connectRemoteUser } }.
                { 'disconnect remote user' translatedNoop. { #myWorld . #disconnectRemoteUser } }.
                { 'disconnect all remote users' translatedNoop. { #myWorld . #disconnectAllRemoteUsers } }.
        }
]

{ #category : #action }
TheWorldMenu >> roundedCornersString [

	^ (((SystemWindow roundedWindowCorners)
		ifTrue: ['stop']
		ifFalse: ['start']) , ' rounding window corners') translated
]

{ #category : #commands }
TheWorldMenu >> saveAndQuit [

	Smalltalk snapshot: true andQuit: true
]

{ #category : #action }
TheWorldMenu >> saveScreenshot [
	"Make a screenshot of the world and save it to a file"

	SampledSound playSoundNamed: 'camera'.
	PNGReadWriter putForm: myWorld imageForm onFileNamed:
		(FileDirectory default nextNameFor: 'SqueakScreen' extension:'png').

]

{ #category : #commands }
TheWorldMenu >> saveWorldInFile [
	"Save the world's submorphs, model, and stepList in a file.  "

	| fileName fileStream aClass |
	fileName := UIManager default request: 'File name for this morph?'.
	fileName isEmpty ifTrue: [^ self].  "abort"

	"Save only model, stepList, submorphs in this world"
	myWorld submorphsDo: [:m |
		m allMorphsDo: [:subM | subM prepareToBeSaved]].	"Amen"

	fileStream := FileStream newFileNamed: fileName, '.morph'.
	aClass := myWorld model ifNil: [nil] ifNotNil: [myWorld model class].
	fileStream fileOutClass: aClass andObject: myWorld.

]

{ #category : #commands }
TheWorldMenu >> setDisplayDepth [
	"Let the user choose a new depth for the display. "

	| result oldDepth allDepths allLabels hasBoth |
	oldDepth := Display nativeDepth.
	allDepths := #(1 -1 2 -2 4 -4 8 -8 16 -16 32 -32) select: [:d | Display supportsDisplayDepth: d].
	hasBoth := (allDepths anySatisfy:[:d| d > 0]) and:[allDepths anySatisfy:[:d| d < 0]].
	allLabels := allDepths collect:[:d|
		String streamContents:[:s|
			s nextPutAll: (d = oldDepth ifTrue:['<on>'] ifFalse:['<off>']).
			s print: d abs.
			hasBoth ifTrue:[s nextPutAll: (d > 0 ifTrue:['  (big endian)'] ifFalse:['  (little endian)'])].
		]].
	result := UIManager default
		chooseFrom: allLabels 
		values: allDepths 
		title: 'Choose a display depth' translated.
	result ifNotNil: [Display newDepth: result].
	oldDepth := oldDepth abs.
	(Smalltalk isMorphic and: [(Display depth < 4) ~= (oldDepth < 4)])
		ifTrue:
			["Repaint windows since they look better all white in depth < 4"
			(SystemWindow windowsIn: myWorld satisfying: [:w | true]) do:
				[:w |
				oldDepth < 4
					ifTrue: [w restoreDefaultPaneColor]
					ifFalse: [w updatePaneColors]]]
]

{ #category : #action }
TheWorldMenu >> setGradientColor [

	myWorld setGradientColor: myHand lastEvent
]

{ #category : #action }
TheWorldMenu >> soundEnablingString [

	^ SoundService soundEnablingString
]

{ #category : #commands }
TheWorldMenu >> splitNewMorphList: list depth: d [ 
	| middle c prev next out |
	d <= 0 ifTrue: [^Array with: list].
	middle := list size // 2 + 1.
	c := (list at: middle) name first.
	prev := middle - 1.
	[prev > 0 and: [(list at: prev) name first = c]] 
		whileTrue: [prev := prev - 1].
	next := middle + 1.
	[next <= list size and: [(list at: next) name first = c]] 
		whileTrue: [next := next + 1].
	"Choose the better cluster"
	middle := middle - prev < (next - middle) 
				ifTrue: [prev + 1]
				ifFalse: [next]. 
	middle = 1 ifTrue: [middle := next].
	middle >= list size ifTrue: [middle := prev + 1].
	(middle = 1 or: [middle >= list size]) ifTrue: [^Array with: list].
	out := WriteStream on: Array new.
	out nextPutAll: (self splitNewMorphList: (list copyFrom: 1 to: middle - 1)
				depth: d - 1).
	out 
		nextPutAll: (self splitNewMorphList: (list copyFrom: middle to: list size)
				depth: d - 1).
	^out contents
]

{ #category : #action }
TheWorldMenu >> staggerPolicyString [

	^ Preferences staggerPolicyString
]

{ #category : #popups }
TheWorldMenu >> standardFontDo [
	"Build and show the standard font menu"

	self doPopUp: Preferences fontConfigurationMenu
]

{ #category : #commands }
TheWorldMenu >> startMessageTally [
	| world |
	world := Project current world.
	(self confirm: 'MessageTally will start now,
and stop when the cursor goes
to the top of the screen') ifTrue:
		[MessageTally spyOn:
			[[Sensor peekPosition y > 0] whileTrue: [world doOneCycle]]]
]

{ #category : #'windows & flaps menu' }
TheWorldMenu >> suppressFlapsString [
	"Answer the wording of the suppress-flaps item"

	^ Project current suppressFlapsString
]

{ #category : #action }
TheWorldMenu >> toggleMenuColorPolicy [

	Preferences toggle: #menuColorFromWorld.
]

{ #category : #action }
TheWorldMenu >> toggleRoundedCorners [

	SystemWindow roundedWindowCorners: SystemWindow roundedWindowCorners not.
]

{ #category : #action }
TheWorldMenu >> toggleWindowPolicy [

	Preferences toggle: #reverseWindowStagger.
]

{ #category : #commands }
TheWorldMenu >> vmStatistics [
	"Open a string view on a report of vm statistics"

	(StringHolder new contents: Smalltalk vmStatisticsReportString)
		openLabel: 'VM Statistics'
]

{ #category : #'windows & flaps menu' }
TheWorldMenu >> windowsDo [
	"Build the windows menu for the world."

	self doPopUp: self windowsMenu
]

{ #category : #'windows & flaps menu' }
TheWorldMenu >> windowsMenu [
        "Build the windows menu for the world."

        ^ self fillIn: (self menu: 'windows' translatedNoop) from: {  
                { 'find window' translatedNoop. { #myWorld . #findWindow: }. 'Presents a list of all windows; if you choose one from the list, it becomes the active window.' translatedNoop}.

                { 'find changed browsers...' translatedNoop. { #myWorld . #findDirtyBrowsers: }. 'Presents a list of browsers that have unsubmitted changes; if you choose one from the list, it becomes the active window.' translatedNoop}.

                { 'find changed windows...' translatedNoop. { #myWorld . #findDirtyWindows: }. 'Presents a list of all windows that have unsubmitted changes; if you choose one from the list, it becomes the active window.' translatedNoop}.
			nil.

                { 'find a transcript (t)' translatedNoop. { #myWorld . #findATranscript: }. 'Brings an open Transcript to the front, creating one if necessary, and makes it the active window' translatedNoop}.

               { 'find a fileList (L)' translatedNoop. { #myWorld . #findAFileList: }. 'Brings an open fileList to the front, creating one if necessary, and makes it the active window' translatedNoop}.

               { 'find a change sorter (C)' translatedNoop. { #myWorld . #findAChangeSorter: }. 'Brings an open change sorter to the front, creating one if necessary, and makes it the active window' translatedNoop}.

			{ 'find message names (W)' translatedNoop. { #myWorld . #findAMessageNamesWindow: }. 'Brings an open MessageNames window to the front, creating one if necessary, and makes it the active window' translatedNoop}.

			 nil.
                { #staggerPolicyString . { self . #toggleWindowPolicy }. 'stagger: new windows positioned so you can see a portion of each one.
                tile: new windows positioned so that they do not overlap others, if possible.' translatedNoop}.

                nil.
                { 'collapse all windows' translatedNoop. { #myWorld . #collapseAll }. 'Reduce all open windows to collapsed forms that only show titles.' translatedNoop}.
                { 'expand all' translatedNoop. { #myWorld . #expandAll }. 'Expand all collapsed windows and other collapsed objects back to their expanded forms.' translatedNoop}.
		
                { 'close top window (w)' translatedNoop. { SystemWindow . #closeTopWindow }. 'Close the topmost window if possible.' translatedNoop}.
                { 'send top window to back (\)' translatedNoop. { SystemWindow . #sendTopWindowToBack  }. 'Make the topmost window become the backmost one, and activate the window just beneath it.' translatedNoop}.
			 { 'move windows onscreen' translatedNoop. { #myWorld . #bringWindowsFullOnscreen }. 'Make all windows fully visible on the screen' translatedNoop}.

                nil.
                { 'delete unchanged windows' translatedNoop. { #myWorld . #closeUnchangedWindows }. 'Deletes all windows that do not have unsaved text edits.' translatedNoop}.
                { 'delete non-windows' translatedNoop. { #myWorld . #deleteNonWindows }. 'Deletes all non-window morphs lying on the world.' translatedNoop}.
                { 'delete both of the above' translatedNoop. { self . #cleanUpWorld }. 'deletes all unchanged windows and also all non-window morphs lying on the world, other than flaps.' translatedNoop}.

        }
]

{ #category : #mechanics }
TheWorldMenu >> world: aWorld project: aProject hand: aHand [

	myWorld := aWorld.
	myProject := aProject.
	myHand := aHand.
]

{ #category : #commands }
TheWorldMenu >> worldMenuHelp [
	| explanation aList |
	"self currentWorld primaryHand worldMenuHelp"

	aList := OrderedCollection new.
	#(helpMenu changesMenu openMenu debugMenu projectMenu scriptingMenu windowsMenu playfieldMenu appearanceMenu flapsMenu) 
		with:
	#('help' 'changes' 'open' 'debug' 'projects' 'authoring tools' 'windows' 'playfield options' 'appearance' 'flaps') do:
		[:sel :title | | aMenu |
		aMenu := self perform: sel.
			aMenu items do:
				[:it | | cnts |
				(((cnts := it contents) = 'keep this menu up') or: [cnts isEmpty])
					ifFalse: [aList add: (cnts, ' - ', title translated)]]].
	aList sort: [:a :b | a caseInsensitiveLessOrEqual: b ].

	explanation := String streamContents: [:aStream | aList do:
		[:anItem | aStream nextPutAll: anItem; cr]].

	(StringHolder new contents: explanation)
		openLabel: 'Where in the world menu is...' translated
]
