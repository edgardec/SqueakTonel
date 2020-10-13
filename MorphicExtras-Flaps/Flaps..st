"
ClassVariables

FlapsQuads               quads defining predefined flaps
			default flaps are: 'PlugIn Supplies', 'Stack Tools', 'Supplies', 'Tools', 'Widgets' and 'Scripting'

SharedFlapTabs          an  array of flaps shared between squeak projects
SharedFlapsAllowed     boolean


"
Class {
	#name : #Flaps,
	#superclass : #Object,
	#classVars : [
		'FlapsQuads',
		'SharedFlapTabs',
		'SharedFlapsAllowed'
	],
	#category : #'MorphicExtras-Flaps'
}

{ #category : #'predefined flaps' }
Flaps class >> addAndEnableEToyFlaps [
	"Initialize the standard default out-of-box set of global flaps.  This method creates them and places them in my class variable #SharedFlapTabs, but does not itself get them displayed."

	| aSuppliesFlap |
	SharedFlapTabs
		ifNotNil: [^ self].
	SharedFlapTabs := OrderedCollection new.

	aSuppliesFlap := self newSuppliesFlapFromQuads: self quadsDefiningPlugInSuppliesFlap positioning: #right.
	aSuppliesFlap referent setNameTo: 'Supplies Flap' translated.  "Per request from Kim Rose, 7/19/02"
	SharedFlapTabs add: aSuppliesFlap.  "The #center designation doesn't quite work at the moment"

	(Smalltalk globals at: #SugarNavigatorBar ifPresent: [:c | c showSugarNavigator] ifAbsent: [false])
		ifTrue: [SharedFlapTabs add: self newSugarNavigatorFlap]
		ifFalse: [Preferences showProjectNavigator
			ifTrue:[ SharedFlapTabs add: self newNavigatorFlap]].

	self enableGlobalFlapWithID: 'Supplies' translated.

	(Smalltalk globals at: #SugarNavigatorBar ifPresent: [:c | c showSugarNavigator] ifAbsent: [false])
		ifTrue:
			[self enableGlobalFlapWithID: 'Sugar Navigator Flap' translated.
			(self globalFlapTabWithID: 'Sugar Navigator Flap' translated) ifNotNil:
				[:navTab | aSuppliesFlap sugarNavTab: navTab]]
		ifFalse: [
			Preferences showProjectNavigator
				ifTrue:[ self enableGlobalFlapWithID: 'Navigator' translated]].

	SharedFlapsAllowed := true.
	Project current flapsSuppressed: false.
	^ SharedFlapTabs

"Flaps addAndEnableEToyFlaps"
]

{ #category : #'shared flaps' }
Flaps class >> addGlobalFlap: aFlapTab [
	"Add the given flap tab to the list of shared flaps"

	SharedFlapTabs ifNil: [SharedFlapTabs := OrderedCollection new].
	SharedFlapTabs add: aFlapTab
]

{ #category : #'menu support' }
Flaps class >> addIndividualGlobalFlapItemsTo: aMenu [
	"Add items governing the enablement of specific global flaps to aMenu"

	self globalFlapTabsIfAny do:
		[:aFlapTab |
			|  anItem |
			anItem := aMenu addUpdating: #globalFlapWithIDEnabledString: enablementSelector: #showSharedFlaps target: self selector: #enableDisableGlobalFlapWithID: argumentList: {aFlapTab flapID}.
			anItem wordingArgument: aFlapTab flapID.
			anItem setBalloonText: aFlapTab balloonTextForFlapsMenu].
]

{ #category : #'new flap' }
Flaps class >> addLocalFlap [

	^ self addLocalFlap: self currentEvent
]

{ #category : #'new flap' }
Flaps class >> addLocalFlap: anEvent [
	"Menu command -- let the user add a new project-local flap.  Once the new flap is born, the user can tell it to become a shared flap.  Obtain an initial name and edge for the flap, launch the flap, and also launch a menu governing the flap, so that the user can get started right away with customizing it."

	| title edge |
	edge := self askForEdgeOfNewFlap.
	edge ifNil: [^ self].
	
	title := UIManager default request: 'Wording for this flap:' translated initialAnswer: 'Flap' translated.
	title isEmptyOrNil ifTrue: [^ self].
	
	^ self addLocalFlap: anEvent titled: title onEdge: edge
]

{ #category : #'new flap' }
Flaps class >> addLocalFlap: anEvent titled: title onEdge: edge [

	| flapTab menu world |
	flapTab := self newFlapTitled: title onEdge: edge.
	(world := anEvent hand world) addMorphFront: flapTab.
	flapTab adaptToWorld: world.
	menu := flapTab buildHandleMenu: anEvent hand.
	flapTab addTitleForHaloMenu: menu.
	flapTab computeEdgeFraction.
	menu popUpEvent: anEvent in: world.
]

{ #category : #'construction support' }
Flaps class >> addMorph: aMorph asElementNumber: aNumber inGlobalFlapSatisfying: flapBlock [
	"If any global flap satisfies flapBlock, add aMorph to it at the given position.  Applies to flaps that are parts bins and that like thumbnailing"

	| aFlapTab flapPasteUp |
	aFlapTab := self globalFlapTabsIfAny detect: flapBlock ifNone: [^ self].
	flapPasteUp := aFlapTab referent.
	flapPasteUp addMorph: aMorph asElementNumber: aNumber.
	flapPasteUp replaceTallSubmorphsByThumbnails; setPartsBinStatusTo: true
]

{ #category : #'construction support' }
Flaps class >> addMorph: aMorph asElementNumber: aNumber inGlobalFlapWithID: anID [
	"If any global flap satisfies flapBlock, add aMorph to it at the given position.  No senders in the image -- intended to be invoked by doits in code updates only, and applies to flaps that are parts bins and that like thumbnailing"

	^ self addMorph: aMorph asElementNumber: aNumber inGlobalFlapSatisfying: [:aFlap | aFlap flapID = anID]
]

{ #category : #'predefined flaps' }
Flaps class >> addNewDefaultSharedFlaps [
	"Add the stack tools flap and the navigator flap to the global list, but do not have them showing initially.  Transitional, called by the postscript of the FlapsOnBottom update; probably dispensable afterwards."

	SharedFlapTabs ifNotNil:
		[(self globalFlapTabWithID: 'Stack Tools' translated) ifNil:
			[SharedFlapTabs add: self newStackToolsFlap delete].
		self enableGlobalFlapWithID: 'Stack Tools' translated.
		(self globalFlapTabWithID: 'Navigator' translated) ifNil:
			[SharedFlapTabs add: self newNavigatorFlap delete].
		self enableGlobalFlapWithID: 'Navigator' translated.
		self currentWorld addGlobalFlaps]
]

{ #category : #'predefined flaps' }
Flaps class >> addStandardFlaps [
	"Initialize the standard default out-of-box set of global flaps. 
	This method creates them and places them in my class 
	variable #SharedFlapTabs, but does not itself get them 
	displayed. "
	SharedFlapTabs
		ifNil: [SharedFlapTabs := OrderedCollection new].
	SharedFlapTabs add: self newSqueakFlap.
	SharedFlapTabs add: self newSuppliesFlap.
	SharedFlapTabs add: self newToolsFlap.
	SharedFlapTabs add: self newWidgetsFlap.
	SharedFlapTabs add: self newStackToolsFlap.

	Preferences showProjectNavigator
		ifTrue:[SharedFlapTabs add: self newNavigatorFlap].

	SharedFlapTabs add: self newPaintingFlap.
	SharedFlapTabs add: self newObjectsFlap.
	self disableGlobalFlapWithID: 'Stack Tools' translated.
	self disableGlobalFlapWithID: 'Painting' translated.

	Preferences showProjectNavigator
		ifTrue:[self disableGlobalFlapWithID: 'Navigator' translated].

	^ SharedFlapTabs
]

{ #category : #'construction support' }
Flaps class >> addToSuppliesFlap: aMorph asElementNumber: aNumber [
	"Add the given morph to the supplies flap.  To be called by doits in updates, so don't be alarmed by its lack of senders."

	self addMorph: aMorph asElementNumber: aNumber inGlobalFlapWithID: 'Supplies'
]

{ #category : #testing }
Flaps class >> anyFlapsVisibleIn: aWorld [

	aWorld submorphsDo: [:m |
		(m isKindOf: FlapTab) ifTrue: [^ true]].
	
	^ false
]

{ #category : #'new flap' }
Flaps class >> askForEdgeOfNewFlap [

	
	^MenuMorph 
		chooseFrom: (#('left' 'right' 'top' 'bottom') collect: [ :each | each translated ])
		values: #(left right top bottom)
		lines: #()
		title: 'Where should the new flap cling?' translated.

]

{ #category : #miscellaneous }
Flaps class >> automaticFlapLayoutChanged [
	"Sent when the automaticFlapLayout preference changes.  No senders in easily traceable in the image, but this is really sent by a Preference object!"

	Preferences automaticFlapLayout ifTrue:
		[self positionNavigatorAndOtherFlapsAccordingToPreference]
]

{ #category : #'flap mechanics' }
Flaps class >> clobberFlapTabList [
	"Flaps clobberFlapTabList"

	SharedFlapTabs := nil
]

{ #category : #'new flap' }
Flaps class >> defaultColorForFlapBackgrounds [
	"Answer the color to use, by default, in new flap backgrounds"

	^ (Color blue mixed: 0.8 with: Color white) alpha: 0.6
]

{ #category : #'predefined flaps' }
Flaps class >> defaultsQuadsDefiningPlugInSuppliesFlap [
	"Answer a list of quads which define the objects to appear in the default Supplies flap used in the Plug-in image"

	"PartsBin reconstructAllPartsIcons"

	^  #(
	(ObjectsTool				newStandAlone				'Object Catalog'		'A tool that lets you browse the catalog of available objects')
	(AllScriptsTool			allScriptsToolForActiveWorld	'All Scripts' 		'Stop, Step, and Go buttons for controlling all your scripts at once.  The tool can also be "opened up" to control each script in your project individually.')
	(TrashCanMorph			new						'Trash'				'A tool for discarding objects')
	(GrabPatchMorph		new						'Grab Patch'		'Allows you to create a new Sketch by grabbing a rectangular patch from the screen')
	(LassoPatchMorph		new						'Lasso'		'Allows you to create a new Sketch by lassoing an area from the screen')

	(StickyPadMorph		newStandAlone			'Sticky Pad'			'Each time you obtain one of these pastel, translucent, borderless rectangles, it will be a different color from the previous time.')
	"(PaintInvokingMorph	new						'Paint'				'Drop this into an area to start making a fresh painting there')"
	(TextMorph				boldAuthoringPrototype			'Text'				'Text that you can edit into anything you desire.')
	(RecordingControlsMorph	authoringPrototype		'Sound'				'A device for making sound recordings.')
	(RectangleMorph 		authoringPrototype		'Rectangle' 		'A rectangle')
	(RectangleMorph		roundRectPrototype		'RoundRect'		'A rectangle with rounded corners')
	(EllipseMorph			authoringPrototype		'Ellipse'			'An ellipse or circle')
	(StarMorph				authoringPrototype		'Star'			'A star')
	(CurveMorph			authoringPrototype		'Curve'			'A curve')
	(PolygonMorph			authoringPrototype		'Polygon'		'A straight-sided figure with any number of sides')
	(ScriptableButton		authoringPrototype		'Button'			'A Scriptable button')
	"(BookMorph				nextPageButton			'NextPage'		'A button that takes you to the next page')
	(BookMorph				previousPageButton 		'PreviousPage'	'A button that takes you to the previous page')"
	"(ScriptingSystem		prototypicalHolder 		'Holder'			'A place for storing alternative pictures in an animation, etc.')"
	(PasteUpMorph			authoringPrototype		'Playfield'		'A place for assembling parts or for staging animations')
	(SimpleSliderMorph		authoringPrototype		'Slider'			'A slider for showing and setting numeric values.')
	(JoystickMorph			authoringPrototype		'Joystick'		'A joystick-like control')
	(BookMorph				authoringPrototype		'Book'			'A multi-paged structure')
	"(ClockMorph				authoringPrototype		'Clock'			'A simple digital clock')"
	(KedamaMorph			 newSet 		'Particles'	'A Kedama World with pre-made components')
	"(RandomNumberTile		new					'Random'		'A random-number tile for use with tile scripting')") asOrderedCollection
]

{ #category : #'flaps registry' }
Flaps class >> defaultsQuadsDefiningScriptingFlap [
	"Answer a structure defining the default items in the Scripting flap.
	previously in quadsDeiningScriptingFlap"

	^ {
	{#TrashCanMorph.		#new.							'Trash' translatedNoop. 	'A tool for discarding objects' translatedNoop}.	
	{#ScriptingSystem.		#scriptControlButtons.			'Status' translatedNoop.	'Buttons to run, stop, or single-step scripts' translatedNoop}.
	{#AllScriptsTool.			#allScriptsToolForActiveWorld.	'All Scripts' translatedNoop.	'A tool that lets you control all the running scripts in your world' translatedNoop}.
	{#ScriptingSystem.		#newScriptingSpace.		'Scripting' translatedNoop. 	'A confined place for drawing and scripting, with its own private stop/step/go buttons.' translatedNoop}.

	{#PaintInvokingMorph.	#new.		'Paint' translatedNoop.	'Drop this into an area to start making a fresh painting there' translatedNoop}.
	{#ScriptableButton.		#authoringPrototype.	'Button' translatedNoop.		'A Scriptable button' translatedNoop}.
	{#ScriptingSystem.		#prototypicalHolder.		'Holder' translatedNoop.		'A place for storing alternative pictures in an animation, etc.' translatedNoop}.
	{#FunctionTile.			#randomNumberTile.	'Random' translatedNoop.	'A tile that will produce a random number in a given range' translatedNoop}.
	{#ScriptingSystem.		#anyButtonPressedTiles.	'ButtonDown?' translatedNoop.	'Tiles for querying whether the mouse button is down' translatedNoop}.
	{#ScriptingSystem.		#noButtonPressedTiles.	'ButtonUp?' translatedNoop.		'Tiles for querying whether the mouse button is up' translatedNoop}.

	{#SimpleSliderMorph.	#authoringPrototype.	'Slider' translatedNoop.		'A slider for showing and setting numeric values.' translatedNoop}.
	{#JoystickMorph	.		#authoringPrototype.	'Joystick' translatedNoop.	'A joystick-like control' translatedNoop}.
	{#TextFieldMorph.		#exampleBackgroundField.	'Scrolling Field'	translatedNoop. 'A scrolling data field which will have a different value on every card of the background' translatedNoop}.

	{#PasteUpMorph.	#authoringPrototype.		'Playfield' translatedNoop.	'A place for assembling parts or for staging animations' translatedNoop}.


	{#StackMorph. 		#authoringPrototype.		'Stack' translatedNoop. 		'A multi-card data base'	translatedNoop}.
	{#TextMorph.		#exampleBackgroundLabel.	'Background Label' translatedNoop. 'A piece of text that will occur on every card of the background' translatedNoop}.
	{#TextMorph	.		#exampleBackgroundField.	'Background Field' translatedNoop. 'A data field which will have a different value on every card of the background' translatedNoop}
} asOrderedCollection
]

{ #category : #'flaps registry' }
Flaps class >> defaultsQuadsDefiningStackToolsFlap [
	"Answer a structure defining the items on the default system Stack Tools flap.
	previously in quadsDefiningStackToolsFlap"

	^ {
	{#StackMorph. 		#authoringPrototype.	'Stack' translatedNoop. 				'A multi-card data base'	translatedNoop}.
	{#StackMorph.		#stackHelpWindow.		'Stack Help'	translatedNoop.		'Some hints about how to use Stacks' translatedNoop}.
	{#TextMorph	.		#authoringPrototype.	'Simple Text' translatedNoop.		'Text that you can edit into anything you wish' translatedNoop}.
	{#TextMorph	.		#fancyPrototype.		'Fancy Text' translatedNoop. 		'A text field with a rounded shadowed border, with a fancy font.' translatedNoop}.
	{#ScrollableField.	#newStandAlone.		'Scrolling Text' translatedNoop.		'Holds any amount of text; has a scroll bar' translatedNoop}.
	{#ScriptableButton.	#authoringPrototype.	'Scriptable Button' translatedNoop.	'A button whose script will be a method of the background Player' translatedNoop}.
	{#StackMorph.		#previousCardButton. 	'Previous Card' translatedNoop. 		'A button that takes the user to the previous card in the stack' translatedNoop}.
	{#StackMorph.		#nextCardButton.		'Next Card' translatedNoop.			'A button that takes the user to the next card in the stack' translatedNoop} } asOrderedCollection

]

{ #category : #'flaps registry' }
Flaps class >> defaultsQuadsDefiningSuppliesFlap [
	"Answer a list of quads which define the objects to appear in the default Supplies flap.
	previously in quadsDefiningSuppliesFlap"

	^ {
	{#RectangleMorph. 	#authoringPrototype.		'Rectangle' 	translatedNoop.	'A rectangle' translatedNoop}.
	{#RectangleMorph.	#roundRectPrototype.		'RoundRect' translatedNoop.		'A rectangle with rounded corners' translatedNoop}.
	{#EllipseMorph.		#authoringPrototype.		'Ellipse' translatedNoop.			'An ellipse or circle' translatedNoop}.
	{#StarMorph.		#authoringPrototype.		'Star' translatedNoop.			'A star' translatedNoop}.
	{#PolygonMorph.		#curvePrototype.		'Curve' translatedNoop.			'A curve' translatedNoop}.
	{#PolygonMorph.	#authoringPrototype.		'Polygon' translatedNoop.		'A straight-sided figure with any number of sides' translatedNoop}.
	{#TextMorph	.		#authoringPrototype.	'Text' translatedNoop.			'Text that you can edit into anything you desire.' translatedNoop}.
	{#ScriptingSystem.	#prototypicalHolder. 		'Holder' translatedNoop.			'A place for storing alternative pictures in an animation, etc.' translatedNoop}.
	{#ImageMorph.		#authoringPrototype.		'Picture' translatedNoop.		'A non-editable picture of something' translatedNoop}.
	{#ScriptableButton.	#authoringPrototype.		'Button' translatedNoop.			'A Scriptable button' translatedNoop}.
	{#SimpleSliderMorph.	#authoringPrototype.	'Slider' translatedNoop.			'A slider for showing and setting numeric values.' translatedNoop}.
	{#PasteUpMorph.	#authoringPrototype.		'Playfield' translatedNoop.		'A place for assembling parts or for staging animations' translatedNoop}.
	{#BookMorph.		#authoringPrototype.		'Book' translatedNoop.			'A multi-paged structure' translatedNoop}.
	{#TabbedPalette.		#authoringPrototype.		'TabbedPalette' translatedNoop.	'A structure with tabs' translatedNoop}.
	{#JoystickMorph	.	#authoringPrototype.		'Joystick' translatedNoop.		'A joystick-like control' translatedNoop}.
	{#ClockMorph.		#authoringPrototype.		'Clock' translatedNoop.			'A simple digital clock' translatedNoop}.
	{#BookMorph.		#previousPageButton. 		'PreviousPage' translatedNoop.	'A button that takes you to the previous page' translatedNoop}.
	{#BookMorph.		#nextPageButton.			'NextPage' translatedNoop.		'A button that takes you to the next page' translatedNoop}
} asOrderedCollection
]

{ #category : #'flaps registry' }
Flaps class >> defaultsQuadsDefiningToolsFlap [
	"Answer a structure defining the default Tools flap.
	previously in quadsDefiningToolsFlap"

	^ OrderedCollection new
	addAll: #(
	(Browser 				prototypicalToolWindow		'Browser'			'A Browser is a tool that allows you to view all the code of all the classes in the system')
	(TranscriptStream		openMorphicTranscript				'Transcript'			'A Transcript is a window usable for logging and debugging; browse references to #Transcript for examples of how to write to it.')
	(Workspace			prototypicalToolWindow		'Workspace'			'A Workspace is a simple window for editing text.  You can later save the contents to a file if you desire.'));
		add: {   FileList2 .
				#prototypicalToolWindow.
				'File List'.
				'A File List is a tool for browsing folders and files on disks and FTP servers.' };
	addAll: #(
	(DualChangeSorter		prototypicalToolWindow		'Change Sorter'		'Shows two change sets side by side')
	(SelectorBrowser		prototypicalToolWindow		'Method Finder'		'A tool for discovering methods by providing sample values for arguments and results')
	(MessageNames		prototypicalToolWindow		'Message Names'		'A tool for finding, viewing, and editing all methods whose names contain a given character sequence.')
	(PreferencesBrowser	prototypicalToolWindow	'Preferences'			'Allows you to control numerous options')
	(Utilities				recentSubmissionsWindow	'Recent'				'A message browser that tracks the most recently-submitted methods')
	(ProcessBrowser		prototypicalToolWindow		'Processes'			'A Process Browser shows you all the running processes')
	(Preferences			annotationEditingWindow	'Annotations'		'Allows you to specify the annotations to be shown in the annotation panes of browsers, etc.')
		(PackagePaneBrowser	prototypicalToolWindow		'Packages'			'Package Browser:  like a System Browser, except that if has extra level of categorization in the top-left pane, such that class-categories are further organized into groups called "packages"')
	(ChangeSorter			prototypicalToolWindow		'Change Set'			'A tool that allows you to view and manipulate all the code changes in a single change set'));
		yourself
]

{ #category : #'flaps registry' }
Flaps class >> defaultsQuadsDefiningWidgetsFlap [
	"Answer a structure defining the default Widgets flap.
     previously in quadsDefiningWidgetsFlap"

	^ #(
	(TrashCanMorph			new						'Trash'		
		'A tool for discarding objects')
	"(AllScriptsTool			allScriptsToolForActiveWorld	'All
Scripts' 		'A tool that lets you see and control all the running
scripts in your project')"
	(PaintInvokingMorph	new						'Paint'		
		'Drop this into an area to start making a fresh painting there')
	(GeeMailMorph			new						'Gee-Mail'	
		'A place to present annotated content')
	(RecordingControlsMorph	authoringPrototype		'Sound'		
		'A device for making sound recordings.')
	"(MPEGMoviePlayerMorph	authoringPrototype		'Movie
Player'		'A Player for MPEG movies')"
	(FrameRateMorph		authoringPrototype			'Frame
Rate'		'An indicator of how fast your system is running')
	(MagnifierMorph		newRound					'Magnifier'	
		'A magnifying glass')
	"(ScriptingSystem		newScriptingSpace			'Scripting'	
		'A confined place for drawing and scripting, with its own
private stop/step/go buttons.')
	(ScriptingSystem		holderWithAlphabet			'Alphabet'	
		'A source for single-letter objects')
	(BouncingAtomsMorph	new						'Bouncing
Atoms'	'Atoms, mate')"
	(ObjectsTool				newStandAlone				'Object
Catalog'		'A tool that lets you browse the catalog of objects')
	) asOrderedCollection
]

{ #category : #'construction support' }
Flaps class >> deleteMorphsSatisfying: deleteBlock fromGlobalFlapSatisfying: flapBlock [
	"If any global flap satisfies flapBlock, then delete objects satisfying from deleteBlock from it.  Occasionally called from do-its in updates or other fileouts."

	| aFlapTab flapPasteUp |
	aFlapTab := self globalFlapTabsIfAny detect: flapBlock ifNone: [^ self].
	flapPasteUp := aFlapTab referent.
	flapPasteUp submorphs do:
		[:aMorph | (deleteBlock value: aMorph) ifTrue: [aMorph delete]]
]

{ #category : #'menu commands' }
Flaps class >> disableGlobalFlapWithID: aFlapID [
	"Mark this project as having the given flapID disabled"

	| disabledFlapIDs  aFlapTab currentProject |
	(currentProject := Project current) assureFlapIntegrity.
	Smalltalk isMorphic ifFalse: [^ self].
	disabledFlapIDs := currentProject parameterAt: #disabledGlobalFlapIDs.
	(aFlapTab := self globalFlapTabWithID: aFlapID) ifNotNil:
		[aFlapTab hideFlap].
	(disabledFlapIDs includes: aFlapID)
		ifFalse:
			[disabledFlapIDs add: aFlapID].
	aFlapTab ifNotNil: [aFlapTab delete]

	
]

{ #category : #'menu commands' }
Flaps class >> disableGlobalFlaps [
	"Clobber all the shared flaps structures.  First read the user her Miranda rights."

	self disableGlobalFlaps: true
]

{ #category : #'menu commands' }
Flaps class >> disableGlobalFlaps: interactive [
	"Clobber all the shared flaps structures.  First read the user her Miranda rights."

	interactive
		ifTrue: [(self confirm: 
'CAUTION! This will destroy all the shared
flaps, so that they will not be present in 
*any* project.  If, later, you want them
back, you will have to reenable them, from
this same menu, whereupon the standard
default set of shared flaps will be created.
Do you really want to go ahead and clobber
all shared flaps at this time?' translated) ifFalse: [^ self]].

	self globalFlapTabsIfAny do:
		[:aFlapTab | self removeFlapTab: aFlapTab keepInList: false.
		aFlapTab isInWorld ifTrue: [self error: 'Flap problem' translated]].
	self clobberFlapTabList.
	self initializeFlapsQuads.
	SharedFlapsAllowed := false.
	Smalltalk isMorphic ifTrue: [
		Project current world
			restoreMorphicDisplay;
			reformulateUpdatingMenus].
	
	"The following reduces the risk that flaps will be created with variant IDs
		such as 'Stack Tools2', potentially causing some shared flap logic to fail."
		"Smalltalk garbageCollect."  "-- see if we are OK without this"
]

{ #category : #miscellaneous }
Flaps class >> doAutomaticLayoutOfFlapsIfAppropriate [
	"Do automatic layout of flaps if appropriate"

	Preferences automaticFlapLayout ifTrue:
		[self positionNavigatorAndOtherFlapsAccordingToPreference]
]

{ #category : #miscellaneous }
Flaps class >> enableClassicNavigatorChanged [
	"The #classicNavigatorEnabled preference has changed.   No senders in easily traceable in the image, but this is really sent by a Preference object!"

	Preferences classicNavigatorEnabled
		ifTrue:
			[Flaps disableGlobalFlapWithID: 'Navigator' translated.
			Preferences enable: #showProjectNavigator.
			self disableGlobalFlapWithID: 'Navigator' translated.]
		ifFalse:
			[self enableGlobalFlapWithID: 'Navigator' translated.
			Project current world addGlobalFlaps].

	self doAutomaticLayoutOfFlapsIfAppropriate.
	Project current assureNavigatorPresenceMatchesPreference.
	Project current world reformulateUpdatingMenus.
]

{ #category : #'menu commands' }
Flaps class >> enableDisableGlobalFlapWithID: aFlapID [
	"Toggle the enable/disable status of the given global flap"

	| disabledFlapIDs  aFlapTab currentProject |
	(currentProject := Project current) assureFlapIntegrity.
	Smalltalk isMorphic ifFalse: [^ self].
	disabledFlapIDs := currentProject parameterAt: #disabledGlobalFlapIDs.
	(aFlapTab := self globalFlapTabWithID: aFlapID) ifNotNil:
		[aFlapTab hideFlap].
	(disabledFlapIDs includes: aFlapID)
		ifTrue:
			[disabledFlapIDs remove: aFlapID.
			self currentWorld addGlobalFlaps]
		ifFalse:
			[disabledFlapIDs add: aFlapID.
			aFlapTab ifNotNil: [aFlapTab delete]].
	self doAutomaticLayoutOfFlapsIfAppropriate
]

{ #category : #'menu support' }
Flaps class >> enableEToyFlaps [
	"Start using global flaps, plug-in version, given that they were not present."

	Cursor wait showWhile:
		[self addAndEnableEToyFlaps.
		self enableGlobalFlaps]
]

{ #category : #'menu commands' }
Flaps class >> enableGlobalFlapWithID: aFlapID [
	"Remove any memory of this flap being disabled in this project"

	| disabledFlapIDs  currentProject |
	(currentProject := Project current) assureFlapIntegrity.
	Smalltalk isMorphic ifFalse: [^ self].
	disabledFlapIDs := currentProject parameterAt: #disabledGlobalFlapIDs ifAbsent: [^ self].
	disabledFlapIDs remove: aFlapID ifAbsent: []
	
]

{ #category : #'menu support' }
Flaps class >> enableGlobalFlaps [
	"Start using global flaps, given that they were not present."

	Cursor wait showWhile: [
		SharedFlapsAllowed := true.
		self globalFlapTabs. "This will create them"
		Smalltalk isMorphic ifTrue: [
			Project current world addGlobalFlaps.
			self doAutomaticLayoutOfFlapsIfAppropriate.
			FlapTab allInstancesDo: [:tab | tab computeEdgeFraction].
			Project current world reformulateUpdatingMenus]]
]

{ #category : #'shared flaps' }
Flaps class >> enableOnlyGlobalFlapsWithIDs: survivorList [
	"In the current project, suppress all global flaps other than those with ids in the survivorList"

	self globalFlapTabsIfAny do: [:flapTab |
		(survivorList includes: flapTab flapID)
			ifTrue: [self enableGlobalFlapWithID: flapTab flapID]
			ifFalse: [self disableGlobalFlapWithID: flapTab flapID]].
	Project current world addGlobalFlaps 

	"Flaps enableOnlyGlobalFlapsWithIDs: #('Supplies')"
]

{ #category : #'menu commands' }
Flaps class >> explainFlaps [
	"Open a window giving flap help."

	(StringHolder new contents: self explainFlapsText translated)
		openLabel: 'Flaps' translated

"Flaps explainFlaps"




	
]

{ #category : #'menu commands' }
Flaps class >> explainFlapsText [
	"Answer the text, in English, to show in a help-window about Flaps."

	^'Flaps are like drawers on the edge of the screen, which can be opened so that you can use what is inside them, and closed when you do not need them.  They have many possible uses, a few of which are illustrated by the default set of flaps you can get as described below.

 ''Shared flaps'' are available in every morphic project.  As you move from project to project, you will see these same shared flaps in each, though there are also options, on a project-by-project basis, to choose which of the shared flaps should be shown, and also momentarily to suppress the showing of all shared flaps.   

 To get started using flaps, bring up the desktop menu and choose ''flaps...'', and make the menu stay up by choosing ''keep this menu up''.  If you see, in this flaps menu,  a list of flap names such as ''Squeak'', ''Tools'', etc., it means that shared flaps are already set up in your image.  If you do not see the list, you will instead see a menu item that invites you to ''install default shared flaps''; choose that, and new flaps will be created, and the flaps menu will change to reflect their presence.

 ''Project flaps'' are flaps that belong to a single morphic project.  You will see them when you are in that project, but not when you are in any other morphic project.

 If a flap is set up as a parts bin (such as the default Tools and Supplies flaps), you can use it to create new objects -- just open the flap, then find the object you want, and drag it out; when the cursor leaves the flap, the flap itself will snap closed, and you''ll be left holding the new object -- just click to place it exactly where you want it.

 If a flap is *not* set up as a parts bin (such as the default ''Squeak'' flap at the left edge of the screen) you can park objects there (this is an easy way to move objects from project to project) and you can place your own private controls there, etc.  Everything in the default ''Squeak'' flap (and all the other default flaps, for that matter) is there only for illustrative purposes -- every user will want to fine-tune the flaps to suit his/her own style and needs.

 Each flap may be set up to appear on mouseover, dragover, both, or neither.  See the menu items described below for more about these and other options.

 You can open a closed flap by clicking on its tab, or by dragging the tab toward the center of the screen

 You can close an open flap by clicking on its tab or by dragging the tab back off the edge of the screen.

 Drag the tab of a flap to reposition the tab and to resize the flap itself.  Repositioning starts when you drag the cursor out of the original tab area.

 If flaps or their tabs seem wrongly positioned or lost, try issuing a restoreDisplay from the screen menu.

 The red-halo menu on a flap allows you to change the flap''s properties.   For greatest ease of use, request ''keep this menu up'' here -- that way, you can easily explore all the options in the menu.

 tab color...				Lets you change the color of the flap''s tab.
 flap color...				Lets you change the color of the flap itself.

 use textual tab...		If the tab is not textual, makes it become textual.
 change tab wording...	If the tab is already textual, allows you to edit
							its wording.

 use graphical tab...		If the tab is not graphical, makes it become
							graphical.
 choose tab graphic...	If the tab is already graphical, allows you
							to change the picture.

 use solid tab...			If the tab is not solid, makes it become solid, i.e.
							appear as a solid band of color along the
							entire length or width of the screen.

 parts-bin behavior		If set, then dragging an object from the flap
							tears off a new copy of the object.

 dragover				If set, the flap opens on dragover and closes
							again on drag-leave.


 mouseover				If set, the flap opens on mouseover and closes
							again on mouse-leave. 

 cling to edge...			Governs which edge (left, right, top, bottom)
							the flap adheres to.

 shared					If set, the same flap will be available in all projects; if not, the
							flap will will occur only in one project.

 destroy this flap		Deletes the flap.

 To define a new flap, use ''make a new flap'', found in the ''flaps'' menu.

 To reinstate the default system flaps, you can use ''destroy all shared flaps'' from the ''flaps'' menu, and once they are destroyed, choose ''install default shared flaps''.

 To add, delete, or edit things on a given flap, it is often wise first to suspend the flap''s mouse-over and drag-over sensitivity, so it won''t keep disappearing on you while you''re trying to work with it.

 Besides the three standard flaps delivered with the default system, there are two other flaps readily available on demand from the ''flaps'' menu -- one is called ''Stack Tools'', which provides some tools useful for building stack-like content, the other is called ''Painting'', which provides a quick way to make a new painting.  Simply clicking on the appropriate checkbox in the ''flaps'' menu will toggle the corresponding flap between being visible and not being visible in the project.' translated
]

{ #category : #miscellaneous }
Flaps class >> fileOutChanges [
	"Bug workaround for squeak-flap 'fileOutChanges' buttons which for a while were mistakenly sending their requests here..."

	^ ChangeSet current verboseFileOut. 
]

{ #category : #'flap mechanics' }
Flaps class >> freshFlapsStart [
	"To be called manually only, as a drastic measure.  Delete all flap artifacts and establish fresh default global flaps
	Flaps freshFlapsStart
	"
	self currentWorld deleteAllFlapArtifacts.
	self clobberFlapTabList.
	self addStandardFlaps

]

{ #category : #'shared flaps' }
Flaps class >> globalFlapTab: aName [
	"Answer the global flap tab in the current system whose flapID is the same as aName, or nil if none found."

	| idToMatch |
	idToMatch := (aName beginsWith: 'flap: ')
		ifTrue:  "Ted's old scheme; this convention may still be found
				in pre-existing content that has been externalized"
			[aName copyFrom: 7 to: aName size]
		ifFalse:
			[aName].

	^ self globalFlapTabsIfAny detect: [:ft | ft flapID = idToMatch] ifNone: [nil]
]

{ #category : #'shared flaps' }
Flaps class >> globalFlapTabOrDummy: aName [
	"Answer a global flap tab in the current image with the given name.  If none is found, answer a dummy StringMorph for some reason (check with tk about the use of this)"

	| gg |
	(gg := self globalFlapTab: aName) ifNil:
		[^ StringMorph contents: aName, ' can''t be found'].
	^ gg
]

{ #category : #'shared flaps' }
Flaps class >> globalFlapTabWithID: aFlapID [
	"answer the global flap tab with the given id, or nil if none"

	^ self globalFlapTabsIfAny detect: [:aFlapTab | aFlapTab flapID = aFlapID]
		ifNone:
		["Second try allows sequence numbers"
		self globalFlapTabsIfAny detect: [:aFlapTab | FlapTab givenID: aFlapTab flapID matches: aFlapID]
			ifNone: [nil]]
]

{ #category : #'shared flaps' }
Flaps class >> globalFlapTabs [
	"Answer the list of shared flap tabs, creating it if necessary.  Much less aggressive is #globalFlapTabsIfAny"

	SharedFlapTabs ifNil: [self initializeStandardFlaps].
	^ SharedFlapTabs copy
]

{ #category : #'shared flaps' }
Flaps class >> globalFlapTabsIfAny [
	"Answer a list of the global flap tabs, but it they don't exist, just answer an empty list"

	^ SharedFlapTabs copy ifNil: [Array new]
]

{ #category : #'shared flaps' }
Flaps class >> globalFlapTabsWithID: aFlapID [
	"Answer all flap tabs whose ids start with the given id"

	^ self globalFlapTabsIfAny select:
		[:aFlapTab |
			(aFlapTab flapID = aFlapID) or: [FlapTab givenID: aFlapTab flapID matches: aFlapID]]

"Flaps globalFlapTabsWithID: 'Stack Tools'"
]

{ #category : #'menu support' }
Flaps class >> globalFlapWithIDEnabledString: aFlapID [
	"Answer the string to be shown in a menu to represent the status of the givne flap regarding whether it it should be shown in this project."

	| aFlapTab wording |
	aFlapTab := self globalFlapTabWithID: aFlapID.
	wording := aFlapTab ifNotNil: [aFlapTab wording] ifNil: ['(',  aFlapID, ')'].
	^ (Project current isFlapIDEnabled: aFlapID)
		ifTrue:
			['<on>', wording]
		ifFalse:
			['<off>', wording]
]

{ #category : #'class initialization' }
Flaps class >> initialize [
	self initializeFlapsQuads
]

{ #category : #'flaps registry' }
Flaps class >> initializeFlapsQuads [
	"initialize the list of dynamic flaps quads.
	self initializeFlapsQuads"
	FlapsQuads := nil. 
	self registeredFlapsQuads at: 'PlugIn Supplies' put: self defaultsQuadsDefiningPlugInSuppliesFlap;
		 at: 'Stack Tools' put: self defaultsQuadsDefiningStackToolsFlap;
		 at: 'Supplies' put: self defaultsQuadsDefiningSuppliesFlap;
		 at: 'Tools' put: self defaultsQuadsDefiningToolsFlap;
		 at: 'Widgets' put: self defaultsQuadsDefiningWidgetsFlap..
	^ self registeredFlapsQuads
]

{ #category : #'predefined flaps' }
Flaps class >> initializeStandardFlaps [
	"Initialize the standard default out-of-box set of global flaps. This method creates them and places them in my class variable #SharedFlapTabs, but does not itself get them displayed."

	SharedFlapTabs := nil.
	self addStandardFlaps
]

{ #category : #miscellaneous }
Flaps class >> makeNavigatorFlapResembleGoldenBar [
	"At explicit request, make the flap-based navigator resemble the golden bar.  No senders in the image, but sendable from a doit"

	"Flaps makeNavigatorFlapResembleGoldenBar"

	Preferences setPreference: #classicNavigatorEnabled toValue: false.
	Preferences setPreference: #showProjectNavigator toValue: false.
	(self globalFlapTabWithID: 'Navigator' translated) ifNil:
		[SharedFlapTabs add: self newNavigatorFlap delete].
	self enableGlobalFlapWithID: 'Navigator' translated.
	Preferences setPreference: #navigatorOnLeftEdge toValue: true.
	(self globalFlapTabWithID: 'Navigator' translated) arrangeToPopOutOnMouseOver: true.
	Project current world addGlobalFlaps.
	self doAutomaticLayoutOfFlapsIfAppropriate.
	Project current assureNavigatorPresenceMatchesPreference.	
]

{ #category : #'new flap' }
Flaps class >> newFlapTitled: aString onEdge: anEdge [
	"Create a new flap with the given title and place it on the given edge"

	^ self newFlapTitled: aString onEdge: anEdge inPasteUp: self currentWorld

]

{ #category : #'new flap' }
Flaps class >> newFlapTitled: aString onEdge: anEdge inPasteUp: aPasteUpMorph [
	"Add a flap with the given title, placing it on the given edge, in the given pasteup"

	| aFlapBody aFlapTab  |
	aFlapBody := PasteUpMorph newSticky.
	aFlapTab := FlapTab new referent: aFlapBody.
	aFlapTab setName: aString edge: anEdge color: (Color r: 0.516 g: 0.452 b: 1.0).

	anEdge == #left ifTrue:
		[aFlapTab position: (aPasteUpMorph left @ aPasteUpMorph top).
		aFlapBody extent: (200 @ aPasteUpMorph height)].
	anEdge == #right ifTrue:
		[aFlapTab position: ((aPasteUpMorph right - aFlapTab width) @ aPasteUpMorph top).
		aFlapBody extent: (200 @ aPasteUpMorph height)].
	anEdge == #top ifTrue:
		[aFlapTab position: ((aPasteUpMorph left + 50) @ aPasteUpMorph top).
		aFlapBody extent: (aPasteUpMorph width @ 200)].
	anEdge == #bottom ifTrue:
		[aFlapTab position: ((aPasteUpMorph left + 50) @ (aPasteUpMorph bottom - aFlapTab height)).
		aFlapBody extent: (aPasteUpMorph width @ 200)].

	aFlapBody
		beFlap: true;
		color: self defaultColorForFlapBackgrounds;
		changeTableLayout.
	^ aFlapTab
]

{ #category : #'predefined flaps' }
Flaps class >> newLoneSuppliesFlap [
	"Answer a fully-instantiated flap named 'Supplies' to be placed at the bottom of the screen, for use when it is the only flap shown upon web launch.  We're still evidently nurturing this method along, but it is a disused branch, whose lone sender has no senders..."

	|  aFlapTab aStrip leftEdge |  "Flaps setUpSuppliesFlapOnly"
	aStrip := PartsBin newPartsBinWithOrientation: #leftToRight andColor: Color red muchLighter from:	 {

	{#TrashCanMorph. #new	. 'Trash' translatedNoop. 'A tool for discarding objects' translatedNoop}.	
	{#ScriptingSystem. #scriptControlButtons. 'Status'	translatedNoop. 'Buttons to run, stop, or single-step scripts' translatedNoop}.
	{#AllScriptsTool.    #allScriptsToolForActiveWorld. 'All Scripts' translatedNoop. 'A tool that lets you control all the running scripts in your world' translatedNoop}.

	{#PaintInvokingMorph. #new. 'Paint' translatedNoop.	'Drop this into an area to start making a fresh painting there' translatedNoop}.
	{#RectangleMorph. #authoringPrototype. 'Rectangle' translatedNoop. 'A rectangle' translatedNoop}.
	{#RectangleMorph. #roundRectPrototype. 'RoundRect'	 translatedNoop. 'A rectangle with rounded corners' translatedNoop}.
	{#EllipseMorph.	#authoringPrototype.	'Ellipse' translatedNoop. 'An ellipse or circle' translatedNoop}.
	{#StarMorph. 	#authoringPrototype.	'Star' translatedNoop. 	'A star' translatedNoop}.
	{#PolygonMorph.	#curvePrototype.	'Curve'	translatedNoop. 'A curve' translatedNoop}.
	{#PolygonMorph	. #authoringPrototype.	'Polygon' translatedNoop. 'A straight-sided figure with any number of sides' translatedNoop}.
	{#TextMorph	.	#authoringPrototype. 	'Text' translatedNoop.	'Text that you can edit into anything you desire.' translatedNoop}.
	{#SimpleSliderMorph	.	#authoringPrototype.	'Slider' translatedNoop.	'A slider for showing and setting numeric values.' translatedNoop}.
	{#JoystickMorph	.	#authoringPrototype.	'Joystick' translatedNoop. 	'A joystick-like control' translatedNoop}.
	{#ScriptingSystem.	#prototypicalHolder.		'Holder'	translatedNoop.		'A place for storing alternative pictures in an animation, etc.' translatedNoop}.
"	{#ScriptableButton.	#authoringPrototype.	'Button'	 translatedNoop.		'A Scriptable button' translatedNoop}."
	{#PasteUpMorph.	#authoringPrototype.	'Playfield' translatedNoop.	'A place for assembling parts or for staging animations' translatedNoop}.
	{#BookMorph.		#authoringPrototype.	'Book' translatedNoop.		'A multi-paged structure' translatedNoop}.
	{#TabbedPalette.		#authoringPrototype.	'Tabs' translatedNoop.		'A structure with tabs' translatedNoop}.

	{#RecordingControls.	#authoringPrototype.	'Sound Recorder' translatedNoop. 'A device for making sound recordings.' translatedNoop}.
	{#MagnifierMorph.	#newRound	.			'Magnifier' translatedNoop.		'A magnifying glass' translatedNoop}.

	{#ImageMorph.		#authoringPrototype.	'Picture' translatedNoop. 	'A non-editable picture of something' translatedNoop}.
	{#ClockMorph.		#authoringPrototype,	'Clock' translatedNoop, 	'A simple digital clock' translatedNoop}.
	{#BookMorph,		#previousPageButton,	'Previous' translatedNoop, 'A button that takes you to the previous page' translatedNoop}.
	{#BookMorph,		#nextPageButton,		'Next' translatedNoop,	'A button that takes you to the next page' translatedNoop}.
}.

	aFlapTab := FlapTab new referent: aStrip beSticky.
	aFlapTab setName: 'Supplies' translated edge: #bottom color: Color red lighter.

	aStrip extent: self currentWorld width @ 78.
	leftEdge := ((Display width - (16  + aFlapTab width)) + 556) // 2.

	aFlapTab position: (leftEdge @ (self currentWorld height - aFlapTab height)).

	aStrip beFlap: true.
	aStrip autoLineLayout: true.
	
	^ aFlapTab
]

{ #category : #'predefined flaps' }
Flaps class >> newNavigatorFlap [
	"Answer a newly-created flap which adheres to the bottom edge of the screen and which holds the project navigator controls. "

	|  aFlapTab navBar aFlap |
	navBar := ProjectNavigationMorph preferredNavigator new addButtons.
	aFlap := PasteUpMorph newSticky borderWidth: 0;
			extent: navBar extent + (0@20);
			color: (Color orange alpha: 0.8);
			beFlap: true;
			addMorph: navBar beSticky.
	aFlap hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	aFlap useRoundedCorners.
	aFlap setNameTo: 'Navigator Flap' translated.
	navBar fullBounds.  "to establish width"
	
	aFlapTab := FlapTab new referent: aFlap.
	aFlapTab setName: 'Navigator' translated edge: #bottom color: Color orange.
	aFlapTab position: ((navBar width // 2) - (aFlapTab width // 2))
					@ (self currentWorld height - aFlapTab height).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.
	^ aFlapTab

"Flaps replaceGlobalFlapwithID: 'Navigator' translated "

]

{ #category : #'predefined flaps' }
Flaps class >> newObjectsFlap [
	"Answer a fully-instantiated flap named 'Objects' to be placed at the top of the screen."

	|  aFlapTab anObjectsTool |
	anObjectsTool := ObjectsTool new.
	anObjectsTool initializeForFlap.

	aFlapTab := FlapTab new referent: anObjectsTool beSticky.
	aFlapTab setName: 'Objects' translated edge: #top color: Color red lighter.
	aFlapTab position: ((Display width - (aFlapTab width + 22)) @ 0).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.

	anObjectsTool extent: self currentWorld width @ 200.
	anObjectsTool beFlap: true.
	anObjectsTool color: Color red muchLighter.
	anObjectsTool clipSubmorphs: true.

	anObjectsTool showCategories.

	^ aFlapTab
]

{ #category : #'predefined flaps' }
Flaps class >> newPaintingFlap [
	"Add a flap with the paint palette in it"

	| aFlap aFlapTab  |
	"Flaps reinstateDefaultFlaps. Flaps addPaintingFlap"

	aFlap := PasteUpMorph new borderWidth: 0.
	aFlap color: Color transparent.
	aFlap layoutPolicy: TableLayout new.
	aFlap hResizing: #shrinkWrap.
	aFlap vResizing: #shrinkWrap.
	aFlap cellPositioning: #topLeft.
	aFlap clipSubmorphs: false.

	aFlap beSticky. "really?!"
	aFlap addMorphFront: PaintBoxMorph new.
	aFlap setProperty: #flap toValue: true.
	aFlap fullBounds. "force layout"

	aFlapTab := FlapTab new referent: aFlap.
	aFlapTab setNameTo: 'Painting' translated.
	aFlapTab setProperty: #priorWording toValue: 'Paint' translated.
	aFlapTab useGraphicalTab.
	aFlapTab removeAllMorphs.
	aFlapTab setProperty: #paintingFlap toValue: true.
	aFlapTab addMorphFront: 
		"(SketchMorph withForm: (ScriptingSystem formAtKey: #PaintingFlapPic))"
		self paintFlapButton.
	aFlapTab cornerStyle: #rounded.
	aFlapTab edgeToAdhereTo: #right.
	aFlapTab setToPopOutOnDragOver: false.
	aFlapTab setToPopOutOnMouseOver: false.
	aFlapTab on: #mouseUp send: #startOrFinishDrawing: to: aFlapTab.
	aFlapTab setBalloonText:'Click here to start or finish painting.' translated.

	aFlapTab fullBounds. "force layout"
	aFlapTab position: (0@6).
	self currentWorld addMorphFront: aFlapTab.  
	^ aFlapTab
]

{ #category : #'predefined flaps' }
Flaps class >> newSqueakFlap [
	"Answer a new default 'Squeak' flap for the left edge of the screen"

	| aFlap aFlapTab aButton aClock buttonColor anOffset bb aFont |
	aFlap := PasteUpMorph newSticky borderWidth: 0.
	aFlapTab := FlapTab new referent: aFlap.
	aFlapTab setName: 'Squeak' translated edge: #left color: Color brown lighter lighter.
	aFlapTab position: (0 @ ((Display height - aFlapTab height) // 2)).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.

	aFlap cellInset: 14@14.
	aFlap beFlap: true.
	aFlap color: (Color brown muchLighter lighter "alpha: 0.3").
	aFlap extent: 150 @ self currentWorld height.
	aFlap layoutPolicy: TableLayout new.
	aFlap wrapCentering: #topLeft.
	aFlap layoutInset: 2.
	aFlap listDirection: #topToBottom.
	aFlap wrapDirection: #leftToRight.

	"self addProjectNavigationButtonsTo: aFlap."
	anOffset := 16.

	aClock := ClockMorph newSticky.
	aClock color: Color red.
	aClock showSeconds: false.
	aClock font: (TextStyle default fontAt: 3).
	aClock step.
	aClock setBalloonText: 'The time of day.  If you prefer to see seconds, check out my menu.' translated.
	aFlap addCenteredAtBottom: aClock offset: anOffset.

	buttonColor :=  Color cyan muchLighter.
	bb := SimpleButtonMorph new target: Smalltalk.
	bb color: buttonColor.
	aButton := bb copy.
	aButton actionSelector: #saveSession.
	aButton setBalloonText: 'Make a complete snapshot of the current state of the image onto disk.' translated.
	aButton label: 'save' translated font: (aFont := ScriptingSystem fontForTiles).
	aFlap addCenteredAtBottom: aButton offset: anOffset.

	aButton := bb copy target: MCMcmUpdater.
	aButton actionSelector: #updateFromServer.
	aButton label: 'load code updates' translated font: aFont.
	aButton color: buttonColor.
	aButton setBalloonText: 'Check the Squeak server for any new code updates, and load any that are found.' translated.
	aFlap addCenteredAtBottom: aButton offset: anOffset.

	aButton := SimpleButtonMorph new target: Smalltalk; actionSelector: #aboutThisSystem;
		label: 'about this system' translated font: aFont.
	aButton color: buttonColor.
	aButton setBalloonText: 'click here to find out version information' translated.
	aFlap addCenteredAtBottom: aButton offset: anOffset.

	aFlap addCenteredAtBottom: (Preferences themeChoiceButtonOfColor: buttonColor font: aFont) offset: anOffset.

	aButton := TrashCanMorph newSticky.
	aFlap addCenteredAtBottom: aButton offset: anOffset.
	aButton startStepping.

	^ aFlapTab

"Flaps replaceGlobalFlapwithID: 'Squeak' translated "
]

{ #category : #'predefined flaps' }
Flaps class >> newStackToolsFlap [
	"Add a flap with stack tools in it"

	| aFlapTab aStrip |
	aStrip := PartsBin newPartsBinWithOrientation: #leftToRight
		andColor: (Color red muchLighter "alpha: 0.2") from: self quadsDefiningStackToolsFlap.

	aFlapTab := FlapTab new referent: aStrip beSticky.
	aFlapTab setName: 'Stack Tools' translated edge: #bottom color: Color brown lighter lighter.
	aFlapTab position: ((Display width - (aFlapTab width + 226)) @ (self currentWorld height - aFlapTab height)).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.

	aStrip extent: self currentWorld width @ 78.
	aStrip beFlap: true.
	aStrip autoLineLayout: true.
	aStrip extent: self currentWorld width @ 70.

	^ aFlapTab

"Flaps replaceGlobalFlapwithID: 'Stack Tools' translated"
]

{ #category : #'predefined flaps' }
Flaps class >> newSuppliesFlap [
	"Answer a fully-instantiated flap named 'Supplies' to be placed at the bottom of the screen; this is for the non-plug-in-version"

	^ self newSuppliesFlapFromQuads: self quadsDefiningSuppliesFlap positioning: #right
]

{ #category : #'predefined flaps' }
Flaps class >> newSuppliesFlapFromQuads: quads positioning: positionSymbol [
	"Answer a fully-instantiated flap named 'Supplies' to be placed at the bottom of the screen.  Use #center as the positionSymbol to have it centered at the bottom of the screen, or #right to have it placed off near the right edge."

	|  aFlapTab aStrip hPosition |
	(Smalltalk classNamed: 'SugarNavigatorBar') ifNotNil: [:c |
		c showSugarNavigator ifTrue: [
			^ self newSuppliesFlapFromQuads: quads positioning: positionSymbol withPreviousEntries: nil]].
	aStrip := PartsBin newPartsBinWithOrientation: #leftToRight andColor: Color red muchLighter from:	 quads.
	"self twiddleSuppliesButtonsIn: aStrip."
	aFlapTab := FlapTab new referent: aStrip beSticky.
	aFlapTab setName: 'Supplies' translated edge: #bottom color: Color red lighter.
	hPosition := positionSymbol == #center
		ifTrue:
			[(Display width // 2) - (aFlapTab width // 2)]
		ifFalse:
			[Display width - (aFlapTab width + 22)].
	aFlapTab position: (hPosition @ (self currentWorld height - aFlapTab height)).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.

	aStrip extent: self currentWorld width @ 136.
	aStrip beFlap: true.
	aStrip autoLineLayout: true.
	
	^ aFlapTab

"Flaps replaceGlobalFlapwithID: 'Supplies' translated"
]

{ #category : #'predefined flaps' }
Flaps class >> newToolsFlap [
	"Answer a newly-created flap which adheres to the right edge of the screen and which holds prototypes of standard tools."

	|  aFlapTab aStrip |
	aStrip := PartsBin newPartsBinWithOrientation: #topToBottom andColor: (Color orange muchLighter alpha: 0.8) from: self quadsDefiningToolsFlap.
 
	aFlapTab := FlapTab new referent: aStrip beSticky.
	aFlapTab setName: 'Tools' translated edge: #right color: Color orange lighter.
	aFlapTab position: (self currentWorld width - aFlapTab width) @ ((Display height - aFlapTab height) // 2).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.

	aStrip extent: (90 @ self currentWorld height).
	aStrip beFlap: true.
	
	^ aFlapTab

"Flaps replaceGlobalFlapwithID: 'Tools' translated "

]

{ #category : #'predefined flaps' }
Flaps class >> newWidgetsFlap [
	"Answer a newly-created flap which adheres to the bottom edge of the screen and which holds prototypes of standard widgets. "

	|  aFlapTab aStrip |
	aStrip := PartsBin newPartsBinWithOrientation: #leftToRight andColor: (Color blue muchLighter alpha: 0.8)
		from:	 self quadsDefiningWidgetsFlap.

	aFlapTab := FlapTab new referent: aStrip beSticky.
	aFlapTab setName: 'Widgets' translated edge: #bottom color: Color blue lighter lighter.
	aFlapTab position: ((Display width - (aFlapTab width + 122)) @ (self currentWorld height - aFlapTab height)).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.

	aStrip extent: self currentWorld width @ 78.
	aStrip beFlap: true.
	aStrip autoLineLayout: true.
	
	^ aFlapTab

"Flaps replaceGlobalFlapwithID: 'Widgets' translated "

]

{ #category : #miscellaneous }
Flaps class >> orientationForEdge: anEdge [
	"Answer the orientation -- #horizontal or #vertical -- that corresponds to the edge symbol"

	^ (#(left right) includes: anEdge)
		ifTrue:	[#vertical]
		ifFalse:	[#horizontal]
]

{ #category : #miscellaneous }
Flaps class >> paintFlapButton [
	"Answer a button to serve as the paint flap"

	| pb oldArgs brush myButton m |
	pb := PaintBoxMorph new submorphNamed: #paint:.
	pb
		ifNil:
			[(brush := Form extent: 16@16 depth: 16) fillColor: Color red]
		ifNotNil:
			[oldArgs := pb arguments.
			brush := oldArgs third.
			brush := brush copy: (2@0 extent: 42@38).
			brush := brush scaledToSize: brush extent // 2].
	myButton := BorderedMorph new.
	myButton color: (Color r: 0.833 g: 0.5 b: 0.0); borderStyle: (BorderStyle raised width: 2).
	myButton addMorph: (m := brush asMorph lock).
	myButton extent: m extent + (myButton borderWidth + 6).
	m position: myButton center - (m extent // 2).
	^ myButton


]

{ #category : #'shared flaps' }
Flaps class >> positionNavigatorAndOtherFlapsAccordingToPreference [
	"Lay out flaps along the designated edge right-to-left, possibly positioning the navigator flap, exceptionally, on the left."

	| ids |
	ids := Preferences navigatorOnLeftEdge ifTrue: [{'Navigator' translated}] ifFalse: [#()].

	Flaps positionVisibleFlapsRightToLeftOnEdge: #bottom butPlaceAtLeftFlapsWithIDs: ids

"Flaps positionNavigatorAndOtherFlapsAccordingToPreference"
]

{ #category : #'shared flaps' }
Flaps class >> positionVisibleFlapsRightToLeftOnEdge: edgeSymbol butPlaceAtLeftFlapsWithIDs: idList [
	"Lay out flaps along the designated edge right-to-left, while laying left-to-right any flaps found in the exception list

	Flaps positionVisibleFlapsRightToLeftOnEdge: #bottom butPlaceAtLeftFlapWithIDs: {'Navigator' translated. 'Supplies' translated}
	Flaps sharedFlapsAlongBottom"

	| leftX flapList flapsOnRight flapsOnLeft |
	flapList := self globalFlapTabsIfAny select:
		[:aFlapTab | aFlapTab isInWorld and: [aFlapTab edgeToAdhereTo == edgeSymbol]].
	flapsOnLeft := OrderedCollection new.
	flapsOnRight := OrderedCollection new.
	
	flapList do: [:fl | 
		(idList includes: fl flapID)
			ifTrue: [ flapsOnLeft addLast: fl ]
			ifFalse: [ flapsOnRight addLast: fl ] ].

	leftX := Project current world width - 15.

	flapsOnRight 
		sort: [:f1 :f2 | f1 left > f2 left];
		do: [:aFlapTab |
			aFlapTab right: leftX - 3.
			leftX := aFlapTab left].

	leftX := Project current world left.

	flapsOnLeft
		sort: [:f1 :f2 | f1 left > f2 left];
		do: [:aFlapTab |
			aFlapTab left: leftX + 3.
			leftX := aFlapTab right].

	flapList do:
		[:ft | ft computeEdgeFraction.
		ft flapID = 'Navigator' translated ifTrue:
			[ft referent left: (ft center x - (ft referent width//2) max: 0)]]
]

{ #category : #'construction support' }
Flaps class >> possiblyReplaceEToyFlaps [
	"If in eToyFriendly mode, and if it's ok to reinitialize flaps, replace the existing flaps with up-too-date etoy flaps.  Caution:  this is destructive of existing flaps.  If preserving the contents of existing flaps is important, set the preference 'okToReinitializeFlaps' to true"

	PartsBin thumbnailForPartsDescription: StickyPadMorph descriptionForPartsBin.  "Puts StickyPadMorph's custom icon back in the cache which typically will have been called"
	(Preferences eToyFriendly and: [Preferences okToReinitializeFlaps]) ifTrue:
		[Flaps disableGlobalFlaps: false.
		Flaps addAndEnableEToyFlaps.
		Smalltalk isMorphic ifTrue: [Project current world enableGlobalFlaps]].
	"PartsBin clearThumbnailCache"

"Flaps possiblyReplaceEToyFlaps"
]

{ #category : #'predefined flaps' }
Flaps class >> quadsDefiningPlugInSuppliesFlap [
	"Answer a list of quads which define the objects to appear in the default Supplies flap used in the Plug-in image"

	^ self registeredFlapsQuadsAt: 'PlugIn Supplies'
]

{ #category : #'predefined flaps' }
Flaps class >> quadsDefiningStackToolsFlap [
	"Answer a structure defining the items on the default system Stack Tools flap"

	^ self registeredFlapsQuadsAt: 'Stack Tools'

	"Flaps replaceGlobalFlapwithID: 'Stack Tools'"
]

{ #category : #'predefined flaps' }
Flaps class >> quadsDefiningSuppliesFlap [
	"Answer a list of quads which define the objects to appear in the default Supplies flap"

	^ self registeredFlapsQuadsAt: 'Supplies'
]

{ #category : #'predefined flaps' }
Flaps class >> quadsDefiningToolsFlap [
	"Answer a structure defining the default Tools flap"

	^ self registeredFlapsQuadsAt: 'Tools'
]

{ #category : #'predefined flaps' }
Flaps class >> quadsDefiningWidgetsFlap [
	"Answer a structure defining the default Widgets flap"

	^ self registeredFlapsQuadsAt: 'Widgets'
]

{ #category : #'predefined flaps' }
Flaps class >> quadsDeiningScriptingFlap [
	"Answer a structure defining the default items in the Scripting flap"

	^ self registeredFlapsQuadsAt: 'Scripting'
]

{ #category : #'flaps registry' }
Flaps class >> registerQuad: aQuad forFlapNamed: aLabel [
	"If any previous registration of the same label string is already known, delete the old one."

	"aQuad received must be an array of the form {TargetObject. #command label  'A Help String'} 

Flaps registerQuad: #(FileList2 openMorphicViewInWorld	'Enhanced File List'	'A nicer File List.')
	forFlapNamed: 'Tools' "

	self unregisterQuad: aQuad forFlapNamed: aLabel.
	(self registeredFlapsQuads at: aLabel ifAbsent:[^self]) add: aQuad
]

{ #category : #'flaps registry' }
Flaps class >> registeredFlapsQuads [
	"Answer the list of dynamic flaps quads"
	
	FlapsQuads ifNil: [FlapsQuads := Dictionary new].
	^ FlapsQuads

" FlapsQuads := nil. "
]

{ #category : #'flaps registry' }
Flaps class >> registeredFlapsQuadsAt: aLabel [
	"Answer the list of dynamic flaps quads at aLabel"

	^ (self registeredFlapsQuads at: aLabel ifAbsent:[^#()])
		removeAllSuchThat: [:q | (self environment includesKey: q first) not or: [(self environment at: q first) isNil]]

]

{ #category : #'flap mechanics' }
Flaps class >> reinstateDefaultFlaps [
	"Remove all existing 'standard' global flaps clear the global list, and and add fresh ones.  To be called by doits in updates etc.  This is a radical step, but it does *not* clobber non-standard global flaps or local flaps.  To get the effect of the *former* version of this method, call Flaps freshFlapsStart"

	"Flaps reinstateDefaultFlaps"
	self globalFlapTabsIfAny do:
		[:aFlapTab |
			({
				
				'Squeak' translated.
				'Menu' translated.
				'Widgets' translated.
				'Tools' translated.
				'Supplies' translated.
				
				'Objects' translated.
				'Navigator' translated
			  } includes: aFlapTab flapID) ifTrue:
				[self removeFlapTab: aFlapTab keepInList: false]].

	"The following reduces the risk that flaps will be created with variant IDs
		such as 'Stack Tools2', potentially causing some shared flap logic to fail."
		"Smalltalk garbageCollect."  "-- see if we are OK without this"

	self addStandardFlaps.
	"self disableGlobalFlapWithID: 'Scripting'.
	self disableGlobalFlapWithID: 'Objects'."
	self currentWorld addGlobalFlaps.
	self currentWorld reformulateUpdatingMenus.

]

{ #category : #'shared flaps' }
Flaps class >> removeDuplicateFlapTabs [
	"Remove flaps that were accidentally added multiple times"
	"Flaps removeDuplicateFlapTabs"
	| tabs duplicates |
	SharedFlapTabs copy ifNil: [^self].
	tabs := SharedFlapTabs copy.
	duplicates := Set new.
	tabs do: [:tab | | same |
		same := tabs select: [:each | each wording = tab wording].
		same isEmpty not
			ifTrue: [
				same removeFirst.
				duplicates addAll: same]].
	SharedFlapTabs removeAll: duplicates
]

{ #category : #'flap mechanics' }
Flaps class >> removeFlapTab: aFlapTab keepInList: aBoolean [
	"Remove the given flap tab from the screen, and, if aBoolean is true, also from the global list"

	(SharedFlapTabs ~~ nil and: [SharedFlapTabs includes: aFlapTab])
		ifTrue:
			[aBoolean ifFalse: [self removeFromGlobalFlapTabList: aFlapTab]].
	aFlapTab ifNotNil:
		[aFlapTab referent delete.
		aFlapTab delete]
]

{ #category : #miscellaneous }
Flaps class >> removeFromGlobalFlapTabList: aFlapTab [
	"If the flap tab is in the global list, remove it"

	SharedFlapTabs remove: aFlapTab ifAbsent: []
]

{ #category : #replacement }
Flaps class >> replaceGlobalFlapwithID: flapID [
	"If there is a global flap with flapID, replace it with an updated one."

	| replacement tabs |
	(tabs := self globalFlapTabsWithID: flapID) size = 0 ifTrue: [^ self].
	tabs do: [:tab |
		self removeFlapTab: tab keepInList: false].
	flapID = 'Stack Tools' translated ifTrue: [replacement := self newStackToolsFlap].
	flapID = 'Supplies' translated ifTrue: [replacement := self newSuppliesFlapFromQuads: 
		(Preferences eToyFriendly
			ifFalse: [self quadsDefiningSuppliesFlap]
			ifTrue: [self quadsDefiningPlugInSuppliesFlap]) positioning: #right].
	flapID = 'Tools' translated ifTrue: [replacement := self newToolsFlap].
	flapID = 'Widgets' translated ifTrue: [replacement := self newWidgetsFlap].
	flapID = 'Navigator' translated ifTrue: [replacement := self newNavigatorFlap].
	flapID = 'Squeak' translated ifTrue: [replacement := self newSqueakFlap].
	replacement ifNil: [^ self].
	self addGlobalFlap: replacement.
	self currentWorld ifNotNil: [self currentWorld addGlobalFlaps]

"Flaps replaceFlapwithID: 'Widgets' translated "
]

{ #category : #replacement }
Flaps class >> replacePartSatisfying: elementBlock inGlobalFlapSatisfying: flapBlock with: replacement [
	"If any global flap satisfies flapBlock, look in it for a part satisfying elementBlock; if such a part is found, replace it with the replacement morph, make sure the flap's layout is made right, etc."

	| aFlapTab flapPasteUp anElement |
	aFlapTab := self globalFlapTabsIfAny detect: flapBlock ifNone: [^ self].
	flapPasteUp := aFlapTab referent.
	anElement := flapPasteUp submorphs detect: elementBlock ifNone: [^ self].
	flapPasteUp replaceSubmorph: anElement by: replacement.
	flapPasteUp replaceTallSubmorphsByThumbnails; setPartsBinStatusTo: true.

"Flaps replacePartSatisfying: [:el |  (el isKindOf: MorphThumbnail) and: [(el morphRepresented isKindOf: SystemWindow) and: [el morphRepresented label = 'scripting area']]]
inGlobalFlapSatisfying: [:fl | (fl submorphs size > 0) and:  [(fl submorphs first isKindOf: TextMorph) and: [(fl submorphs first contents string copyWithout: Character cr) = 'Tools']]] with: ScriptingSystem newScriptingSpace"
]

{ #category : #replacement }
Flaps class >> replacePartSatisfying: elementBlock inGlobalFlapWithID: aFlapID with: replacement [
	"If a global flapl exists with the given flapID, look in it for a part satisfying elementBlock; if such a part is found, replace it with the replacement morph, make sure the flap's layout is made right, etc."

	^ self replacePartSatisfying: elementBlock inGlobalFlapSatisfying: [:fl | fl flapID = aFlapID] with: replacement
]

{ #category : #replacement }
Flaps class >> replaceToolsFlap [
	"if there is a global tools flap, replace it with an updated one."

	self replaceGlobalFlapwithID: 'Tools' translated

"Flaps replaceToolsFlap"
]

{ #category : #'menu support' }
Flaps class >> setUpSuppliesFlapOnly [
	"Set up the Supplies flap as the only shared flap.  A special version formulated for this stand-alone use is used, defined in #newLoneSuppliesFlap"

	| supplies |
	SharedFlapTabs isEmptyOrNil ifFalse:  "get rid of pre-existing guys if any"
		[SharedFlapTabs do:
			[:t | t referent delete.  t delete]].

	SharedFlapsAllowed := true.
	SharedFlapTabs := OrderedCollection new.
	SharedFlapTabs add: (supplies := self newLoneSuppliesFlap).
	self enableGlobalFlapWithID: 'Supplies' translated.
	supplies setToPopOutOnMouseOver: false.

	Smalltalk isMorphic ifTrue: [
		Project current world
			addGlobalFlaps;
			reformulateUpdatingMenus].
]

{ #category : #'shared flaps' }
Flaps class >> sharedFlapsAllowed [
	"Answer whether the shared flaps feature is allowed in this system"

	^ SharedFlapsAllowed ifNil: [SharedFlapsAllowed := SharedFlapTabs isEmptyOrNil not]
]

{ #category : #'shared flaps' }
Flaps class >> sharedFlapsAlongBottom [
	"Put all shared flaps (except Painting which can't be moved) along the bottom"
	"Flaps sharedFlapsAlongBottom"

	| leftX unordered ordered |
	unordered := self globalFlapTabsIfAny asIdentitySet.
	ordered := Array streamContents:
		[:s | {
				'Squeak' translated.
				'Navigator' translated.
				'Supplies' translated.
				'Widgets' translated.
				'Stack Tools' translated.
				'Tools' translated.
				'Painting' translated.
			} do:
			[:id | (self globalFlapTabWithID: id) ifNotNil:
				[:ft | unordered remove: ft.
				id = 'Painting' translated ifFalse: [s nextPut: ft]]]].

	"Pace off in order from right to left, setting positions"
	leftX := Display width-15.
	ordered , unordered asArray reverseDo:
		[:ft | ft setEdge: #bottom.
		ft right: leftX - 3.  leftX := ft left].

	"Put Nav Bar centered under tab if possible"
	(self globalFlapTabWithID: 'Navigator' translated) ifNotNil:
		[:ft | ft referent left: (ft center x - (ft referent width//2) max: 0)].
	self positionNavigatorAndOtherFlapsAccordingToPreference.

]

{ #category : #'menu support' }
Flaps class >> showSharedFlaps [
	"Answer whether shared flaps are currently showing.  Presumably it is in service of Alan's wishes to have flaps show sometimes on interior subprojects and sometomes on outer projects that Bob's CurrentProjectRefactoring is threaded into the logic here."

	^ Project current showSharedFlaps
]

{ #category : #'menu support' }
Flaps class >> suppressFlapsString [
	"Answer the string to be shown in a menu to represent the suppress-flaps-in-this-project status"

	^ Project current suppressFlapsString
]

{ #category : #'predefined flaps' }
Flaps class >> twiddleSuppliesButtonsIn: aStrip [
	"Munge item(s) in the strip whose names as seen in the parts bin should be different from the names to be given to resulting torn-off instances"

	(aStrip submorphs detect: [:m | m target == StickyPadMorph] ifNone: [nil])
		ifNotNil:
			[:aButton | aButton arguments: {#newStandAlone.  'tear off'}]
]

{ #category : #'flaps registry' }
Flaps class >> unregisterQuad: aQuad forFlapNamed: aLabel [ 
	"If any previous registration at the same label string has the same receiver-command,
	delete the old one."
	(self registeredFlapsQuadsAt: aLabel)
		removeAllSuchThat: [:q | q first = aQuad first
				and: [q second = aQuad second]]
]

{ #category : #'flaps registry' }
Flaps class >> unregisterQuadsWithReceiver: aReceiver [ 
	"delete all quads with receiver aReceiver."
	self registeredFlapsQuads
		do: [:assoc | assoc value
				removeAllSuchThat: [:q | (self environment at: (q first) ifAbsent:[nil]) = aReceiver ]]
]

{ #category : #'flaps registry' }
Flaps class >> unregisterQuadsWithReceiver: aReceiver fromFlapNamed: aLabel [
	"delete all quads with receiver aReceiver."
	(self registeredFlapsQuads at: aLabel) removeAllSuchThat: [:q | q first = aReceiver name]
]
