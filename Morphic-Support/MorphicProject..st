"
An MorphicProject is a project with a Morphic user interface. Its world is a PasteUpMorph, and its UI manager is a MorphicUIManager. It uses a MorphicToolBuilder to create the views for various tools. It has a single uiProcess for its world, and Morph updates and user interaction occur in the context of that UI process.

"
Class {
	#name : #MorphicProject,
	#superclass : #Project,
	#instVars : [
		'uiProcess'
	],
	#classVars : [
		'DefaultFill'
	],
	#category : #'Morphic-Support'
}

{ #category : #utilities }
MorphicProject class >> compileNewDefaultBackgroundFrom: aForm [ 
	"Compile a new #defaultBackgroundForm method in this class-side which uses aForm as the background."
	| formStream base64 |
	formStream := ByteArray new writeStream.
	PNGReadWriter
		putForm: aForm
		onStream: formStream.
	base64 := formStream base64Encoded.
	self class
		compile:
			(String streamContents:
				[ : stream | stream
					 nextPutAll: 'defaultBackgroundForm
	^ Form fromBinaryStream: ' ;
					 nextPut: $' ;
					 nextPutAll: base64 ;
					 nextPut: $' ;
					nextPutAll: ' base64Decoded asByteArray readStream' ])
		classified: 'class initialization'
]

{ #category : #'class initialization' }
MorphicProject class >> convertOldProjects [
	"Convert older Morphic projects to be MorphicProjects"
	Project allInstancesDo:[:p|
		p isMorphic ifTrue:[p primitiveChangeClassTo: self basicNew].
	].
]

{ #category : #utilities }
MorphicProject class >> defaultFill [
	"Answer the default fill to use for new Morphic Worlds"
	^DefaultFill ifNil:[Color white].

]

{ #category : #utilities }
MorphicProject class >> defaultFill: aFill [
	"Answer the default fill to use for new Morphic Worlds"
	DefaultFill := aFill.
]

{ #category : #'class initialization' }
MorphicProject class >> initialize [
	"MorphicProject initialize"

	Smalltalk addToShutDownList: self.
]

{ #category : #'instance creation' }
MorphicProject class >> openViewAndEnter: morphOrList [
	"morphOrList has been reconstituted from a file. Open it in an appropriate
	Morphic world."

	| contents |
	contents := morphOrList.
	(morphOrList isKindOf: SqueakPage) ifTrue: [
		contents := morphOrList contentsMorph
	].
	(contents isKindOf: PasteUpMorph) ifFalse:
		[^ self inform: 'This is not a PasteUpMorph or
exported Project.' translated].
	(self openViewOn: contents) enter

]

{ #category : #'instance creation' }
MorphicProject class >> openViewOn: aPasteUpOrNil [
	"Create a new Morphic Project and open a view for the project"
	| newProject |
	newProject := self new.
	aPasteUpOrNil ifNotNil: [newProject installPasteUpAsWorld: aPasteUpOrNil].
	ProjectViewMorph openOn: newProject.
	^newProject

]

{ #category : #utilities }
MorphicProject class >> releaseProjectReferences: outgoingProject [
	"Iterate over all project-view morphs, wherever they may be located. Also consider image segments."
	
	ImageSegment allSubInstancesDo: [:seg |
		seg ifOutPointer: outgoingProject thenAllObjectsDo: [:obj |
			(obj isKindOf: ProjectViewMorph) ifTrue: [
				obj owner isSystemWindow
					ifTrue: [obj owner model: nil; delete].
				obj abandon]]].
	
	ProjectViewMorph allSubInstancesDo: [:p | 
		p owner isSystemWindow ifTrue: [p owner model: nil; delete].
		p project == outgoingProject ifTrue: [p abandon]].
]

{ #category : #'system startup' }
MorphicProject class >> shutDown: quitting [

	Project current isMorphic ifTrue: [
		Project current world submorphsDo: [:ea |
			ea removeProperty: #dropShadow]].
]

{ #category : #preferences }
MorphicProject class >> themeProperties [

	^ super themeProperties, {
		{ #background. 'Colors'. 'Color or fill-style for projects. Use-defined background will not be overwritten.' }.
	}
]

{ #category : #'class initialization' }
MorphicProject class >> unload [

	Smalltalk removeFromShutDownList: self.
]

{ #category : #shrinking }
MorphicProject class >> unloadMorphic [
	"MorphicProject unloadMorphic"

	Project current isMorphic ifTrue: [
		^ Error signal: 'You can only unload Morphic from within another kind of project.'].

	MorphicProject removeProjectsFromSystem.
	
	#(ActiveHand ActiveWorld ActiveEvent World) do: [:ea |
		Smalltalk globals removeKey: ea].

	{ 'ToolBuilder-Morphic' . 'MorphicTests' . 'MorphicExtras' . 'Morphic' }
		do: [ :package | (MCPackage named: package) unload ].


]

{ #category : #'file in\/out' }
MorphicProject >> acceptProjectDetails: details [
	"Store project details back into a property of the world, and if a name is provided, make sure the name is properly installed in the project."

	self world setProperty: #ProjectDetails toValue: details.
	details ifNotNil:
		[details
			at: 'projectname'
			ifPresent: [ :newName | self renameTo: newName]]
]

{ #category : #'scheduling & debugging' }
MorphicProject >> addDeferredUIMessage: valuableObject [ 
	"Arrange for valuableObject to be evaluated at a time when the user interface
	is in a coherent state."

	self flag: #discuss. "mt: Why are deferred UI messages shared among all Morphic projects? That's not the case for MVC projects..."
	WorldState addDeferredUIMessage: valuableObject
]

{ #category : #utilities }
MorphicProject >> addItem: item toMenu: menu selection: action color: aColor thumbnail: aForm [
	"Add menu item representing the sender to a menu"
	"Removed setting the color - it wasn't working well with dark color themes."

	menu
		add: item
		selector: #jumpToSelection:
		argument: action.
	aForm isNil
		ifFalse: [menu lastItem
				icon: (aForm
						scaledIntoFormOfSize: (Preferences tinyDisplay
								ifTrue: [16]
								ifFalse: [28]))]
]

{ #category : #subprojects }
MorphicProject >> addProject: project [

	| view |
	super addProject: project.
	
	view := Preferences projectViewsInWindows
		ifTrue: [ProjectViewMorph newProjectViewInAWindowFor: project]
		ifFalse: [ProjectViewMorph on: project].
	
	"Do not use #openInWorld: because SystemWindow does things with real-estate manager, which depends on too much global state."
	self world
		addMorph: view;
		startSteppingSubmorphsOf: view.
]

{ #category : #updating }
MorphicProject >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setWorldBackground: false.
]

{ #category : #'file in\/out' }
MorphicProject >> armsLengthCommand: aCommand withDescription: aString [
	| tempProject foolingForm tempCanvas bbox crossHatchColor stride |
	"Set things up so that this aCommand is sent to self as a message
after jumping to the parentProject.  For things that can't be executed
while in this project, such as saveAs, loadFromServer, storeOnServer.  See
ProjectViewMorph step."

	world borderWidth: 0.	"get rid of the silly default border"
	tempProject := MorphicProject new.
	foolingForm := world imageForm.		"make them think they never left"
	tempCanvas := foolingForm getCanvas.
	bbox := foolingForm boundingBox.
	crossHatchColor := Color yellow alpha: 0.3.
	stride := 20.
	10 to: bbox width by: stride do: [ :x |
		tempCanvas fillRectangle: (x@0 extent: 1@bbox height) fillStyle: crossHatchColor.
	].
	10 to: bbox height by: stride do: [ :y |
		tempCanvas fillRectangle: (0@y extent: bbox width@1) fillStyle: crossHatchColor.
	].

	tempProject world color: (InfiniteForm with: foolingForm).
	tempProject projectParameters 
		at: #armsLengthCmd 
		put: (
			DoCommandOnceMorph new
				addText: aString;
				actionBlock: [
					self doArmsLengthCommand: aCommand.
				]
		).
	tempProject projectParameters 
		at: #deleteWhenEnteringNewProject 
		put: true.
	tempProject enter

]

{ #category : #'flaps support' }
MorphicProject >> assureFlapIntegrity [
	"Make certain that the items on the disabled-global-flap list are actually global flaps, and if not, get rid of them.  Also, old (and damaging) parameters that held references to actual disabled flaps are cleansed"

	| disabledFlapIDs currentGlobalIDs oldList |
	disabledFlapIDs := self parameterAt: #disabledGlobalFlapIDs ifAbsent: [Set new].
	currentGlobalIDs := Flaps globalFlapTabsIfAny collect: [:f | f flapID].
	oldList := Project current projectParameterAt: #disabledGlobalFlaps ifAbsent: [nil].
	oldList ifNotNil:
		[disabledFlapIDs := oldList collect: [:aFlap | aFlap flapID].
		disabledFlapIDs addAll: {'Scripting' translated. 'Stack Tools' translated. 'Painting' translated}].
	disabledFlapIDs := disabledFlapIDs select: [:anID | currentGlobalIDs includes: anID].
	self projectParameterAt: #disabledGlobalFlapIDs put: disabledFlapIDs asSet.
	self assureNavigatorPresenceMatchesPreference.

	projectParameters ifNotNil:
		[projectParameters removeKey: #disabledGlobalFlaps ifAbsent: []]
]

{ #category : #'docking bars support' }
MorphicProject >> assureMainDockingBarPresenceMatchesPreference [
	"Synchronize the state of the receiver's dockings with the  
	preference"
	(self showWorldMainDockingBar)
		ifTrue: [self createOrUpdateMainDockingBar]
		ifFalse: [self removeMainDockingBar]
]

{ #category : #'menu messages' }
MorphicProject >> assureNavigatorPresenceMatchesPreference [
	"Make sure that the current project conforms to the presence/absence of the navigator"

	| navigator navType wantIt |
	wantIt :=  Preferences classicNavigatorEnabled and: [Preferences showProjectNavigator].
	navType := ProjectNavigationMorph preferredNavigator.
	navigator := world findA: navType.
	wantIt
		ifFalse:
			[navigator ifNotNil: [navigator delete]]
		ifTrue:
			[navigator isNil ifTrue: 
				[(navigator := navType new)
					bottomLeft: world bottomLeft;
					openInWorld: world]]
]

{ #category : #editors }
MorphicProject >> bitEdit: aForm [
	"Create and schedule a view located in an area designated by the user 
	that contains a view of the receiver magnified by 8@8 that can be 
	modified using the Bit Editor. It also contains a view of the original 
	form."

	aForm currentHand attachMorph: (FatBitsPaint new editForm: aForm;
			 magnification: 8;
			 brushColor: Color black;
			 penSize: 1;
			 yourself)

]

{ #category : #editors }
MorphicProject >> bitEdit: aForm at: magnifiedFormLocation scale: scaleFactor [
	"Create and schedule a view whose top left corner is magnifiedLocation 
	and that contains a view of aForm magnified by scaleFactor that  can be
	modified using the Bit Editor. It also contains a view of the original form."

	self inform: 'A Morphic editor has not been implemented. Enter an MVC project to edit this form.'
]

{ #category : #updating }
MorphicProject >> canApplyUserInterfaceTheme [

	^ true
]

{ #category : #language }
MorphicProject >> chooseNaturalLanguage [
	"Put up a menu allowing the user to choose the natural language for the project"

	| aMenu availableLanguages |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'choose language' translated.
	aMenu lastItem setBalloonText: 'This controls the human language in which tiles should be viewed.  It is potentially extensible to be a true localization mechanism, but initially it only works in the classic tile scripting system.  Each project has its own private language choice' translated.
	Preferences noviceMode
		ifFalse:[aMenu addStayUpItem].

	availableLanguages := NaturalLanguageTranslator availableLanguageLocaleIDs
										sorted:[:x :y | x displayName < y displayName].

	availableLanguages do:
		[:localeID |
			aMenu addUpdating: #stringForLanguageNameIs: target: Locale selector:  #switchAndInstallFontToID: argumentList: {localeID}].
	aMenu popUpInWorld

"Project current chooseNaturalLanguage"
]

{ #category : #'flaps support' }
MorphicProject >> cleanseDisabledGlobalFlapIDsList [
	"Make certain that the items on the disabled-global-flap list are actually global flaps, and if not, get rid of them"

	| disabledFlapIDs currentGlobalIDs oldList |
	disabledFlapIDs := self parameterAt: #disabledGlobalFlapIDs ifAbsent: [Set new].
	currentGlobalIDs := Flaps globalFlapTabsIfAny collect: [:f | f flapID].
	oldList := Project current projectParameterAt: #disabledGlobalFlaps ifAbsent: [nil].
	oldList ifNotNil:
		[disabledFlapIDs := oldList select: [:aFlap | aFlap flapID]].
	disabledFlapIDs := disabledFlapIDs select: [:anID | currentGlobalIDs includes: anID].
	self projectParameterAt: #disabledGlobalFlapIDs put: disabledFlapIDs.

	self removeParameter: #disabledGlobalFlaps.

]

{ #category : #enter }
MorphicProject >> clearGlobalState [
	"Clean up global state. This method may be removed if the use of global state variables is eliminated."

	"If global World is defined, clear it now. The value is expected to be set again as a new project is entered."
	Smalltalk globals at: #World ifPresent: [:w |
		Smalltalk globals at: #World put: nil].
]

{ #category : #accessing }
MorphicProject >> color [

	^ self world isInMemory
		ifTrue: [Color black]
		ifFalse: [Color brown]
]

{ #category : #utilities }
MorphicProject >> composeDisplayTextIntoForm: displayText [

	| tmpText canvas |
	tmpText := TextMorph new contentsAsIs: displayText text deepCopy.
	displayText foregroundColor ifNotNil: [:color |
		tmpText text addAttribute: (TextColor color: color)].
	displayText backgroundColor ifNotNil: [:color |
		tmpText backgroundColor: color].
	tmpText setTextStyle: displayText textStyle.
	canvas := FormCanvas on: (Form extent: tmpText extent depth: 32).
	tmpText drawOn: canvas.
	^ canvas form
]

{ #category : #'file in\/out' }
MorphicProject >> compressFilesIn: tempDir to: localName in: localDirectory [
	"Compress all the files in tempDir making up a zip file in localDirectory named localName"

	| archive archiveName entry fileNames |
	archive := ZipArchive new.
	fileNames := tempDir fileNames.
	(fileNames includes: 'manifest')
		ifTrue: [fileNames := #('manifest'), (fileNames copyWithout: 'manifest')].
	fileNames do:[:fn|
		archiveName := fn.
		entry := archive addFile: (tempDir fullNameFor: fn) as: archiveName.
		entry desiredCompressionMethod: (
			fn = 'manifest'
				ifTrue: [ZipArchive compressionLevelNone] 
				ifFalse: [ZipArchive compressionDeflated]).
	].
	archive writeToFileNamed: (localDirectory fullNameFor: localName).
	archive close.
	tempDir fileNames do:[:fn|
		tempDir deleteFileNamed: fn ifAbsent:[]].
	localDirectory deleteDirectory: tempDir localName.
]

{ #category : #'file in\/out' }
MorphicProject >> compressFilesIn: tempDir to: localName in: localDirectory resources: collector [
	"Compress all the files in tempDir making up a zip file in localDirectory named localName"
	| archive urlMap |
	urlMap := Dictionary new.
	collector locatorsDo:[:loc|
		"map local file names to urls"
		urlMap at: (tempDir localNameFor: loc localFileName) put: loc urlString.
		ResourceManager cacheResource: loc urlString inArchive: localName].
	archive := ZipArchive new.
	tempDir fileNames do:[:fn| | archiveName entry |
		archiveName := urlMap at: fn ifAbsent:[fn].
		entry := archive addFile: (tempDir fullNameFor: fn) as: archiveName.
		entry desiredCompressionMethod: ZipArchive compressionStored.
	].
	archive writeToFileNamed: (localDirectory fullNameFor: localName).
	archive close.
	tempDir fileNames do:[:fn|
		tempDir deleteFileNamed: fn ifAbsent:[]].
	localDirectory deleteDirectory: tempDir localName.
]

{ #category : #'docking bars support' }
MorphicProject >> createOrUpdateMainDockingBar [
	"Private - create a new main docking bar or update the current one"
	| w mainDockingBars |
	w := self world.
	mainDockingBars := w mainDockingBars.
	mainDockingBars isEmpty ifTrue:
		[ "no docking bar, just create a new one"
		self dockingBar createDockingBar
			 openInWorld: w .
		^ self ].
	"update if needed"
	mainDockingBars do:
		[ : each | self dockingBar updateIfNeeded: each ]
]

{ #category : #utilities }
MorphicProject >> createViewIfAppropriate [
	"Create a project view for the receiver and place it appropriately on the screen."

	| aMorph requiredWidth existing proposedV proposedH despair |
	ProjectViewOpenNotification signal ifTrue:
		[Preferences projectViewsInWindows
			ifTrue:
				[(ProjectViewMorph newProjectViewInAWindowFor: self) openInWorld]
			ifFalse:
				[aMorph := ProjectViewMorph on: self.
				requiredWidth := aMorph width + 10.
				existing := self currentWorld submorphs
					select: [:m | m isKindOf: ProjectViewMorph]
					thenCollect: [:m | m fullBoundsInWorld].
				proposedV := 85.
				proposedH := 10.
				despair := false.
				[despair not and: [((proposedH @ proposedV) extent: requiredWidth) intersectsAny: existing]] whileTrue:
					[proposedH := proposedH + requiredWidth.
					proposedH + requiredWidth > self currentWorld right ifTrue:
						[proposedH := 10.
						proposedV := proposedV + 90.
						proposedV > (self currentWorld bottom - 90)
							ifTrue:
								[proposedH := self currentWorld center x - 45.
								proposedV := self currentWorld center y - 30.
								despair := true]]].
				aMorph position: (proposedH @ proposedV).
				aMorph openInWorld]]
]

{ #category : #protocols }
MorphicProject >> currentVocabulary [

	^ self world currentVocabulary
]

{ #category : #'scheduling & debugging' }
MorphicProject >> debuggerClass [

	^ Smalltalk classNamed: #MorphicDebugger
]

{ #category : #release }
MorphicProject >> deletingProject: outgoingProject [

	(self world submorphs
		select: [:m | m isSystemWindow and: [m model == outgoingProject]]
		thenCollect: [:window | window paneMorphs first])
		do: [:projectViewMorph |
			projectViewMorph owner "window" model: nil; delete.
			projectViewMorph abandon].

	super deletingProject: outgoingProject.
]

{ #category : #transcripter }
MorphicProject >> displayTranscripter: transcripter [
	"A transcripter is a minimal user interface to support an emergency evaluator.
	A Morphic project uses class NewParagraph."
	transcripter morphicDisplayText
]

{ #category : #utilities }
MorphicProject >> do: aBlock withProgressInfoOn: aMorphOrNil label: aString [
	"Evaluate aBlock with a labeled progress bar"

	ComplexProgressIndicator new 
		targetMorph: aMorphOrNil;
		historyCategory: aString;
		withProgressDo: aBlock

]

{ #category : #'docking bars support' }
MorphicProject >> dockingBar [
	^ self
		projectParameterAt: #dockingBar
		ifAbsent: [ TheWorldMainDockingBar instance ]
]

{ #category : #'docking bars support' }
MorphicProject >> dockingBar: aTheWorldMainDockingBar [ 
	self
		projectParameterAt: #dockingBar
		put: aTheWorldMainDockingBar.
	self isCurrentProject ifTrue: [ TheWorldMainDockingBar instance: aTheWorldMainDockingBar ]
]

{ #category : #editors }
MorphicProject >> editCharacter: character ofFont: strikeFont [
	"Open a bit editor on a character in the given strike font."
	"Note that BitEditor only works in MVC currently."

	"(TextStyle default fontAt: 1) edit: $="

	self inform: 'A Morphic editor has not been implemented. Enter an MVC project to edit this font.'
]

{ #category : #'flaps support' }
MorphicProject >> enableDisableGlobalFlap: aFlapTab [
	"For the benefit of pre-existing which-global-flap buttons from a design now left behind."

	self flag: #toRemove.
	^ self inform: 
'Sorry, this is an obsolete menu; please
dismiss it and get a fresh menu.  Thanks.'.
]

{ #category : #enter }
MorphicProject >> enterAsActiveSubprojectWithin: enclosingWorld [

    "Install my ChangeSet, Transcript, and scheduled views as current globals. 

    If returningFlag is true, we will return to the project from whence the current project was entered; don't change its previousProject link in this case.
    If saveForRevert is true, save the ImageSegment of the project being left.
    If revertFlag is true, make stubs for the world of the project being left.
    If revertWithoutAsking is true in the project being left, then always revert."

    "Experimental mods for initial multi-project work:
        1. assume in morphic (this eliminated need for <showZoom>)
        2. assume <saveForRevert> is false (usual case) - removed <old>
        3. assume <revertFlag> is false
        4. assume <revertWithoutAsking> is false - <forceRevert> now auto false <seg> n.u.
        5. no zooming
        6. assume <projectsSentToDisk> false - could be dangerous here
        7. assume no isolation problems (isolationHead ==)
        8. no closing scripts
    "

    self isCurrentProject ifTrue: [^ self].

    "guards ifNotNil: [
        guards := guards reject: [:obj | obj isNil].
        guards do: [:obj | obj okayToEnterProject ifFalse: [^ self]]
    ]."

        "CurrentProject makeThumbnail."
        "--> Display bestGuessOfCurrentWorld triggerClosingScripts."
    CurrentProject displayDepth: Display depth.

    displayDepth == nil ifTrue: [displayDepth := Display depth].
        "Display newDepthNoRestore: displayDepth."

        "(world hasProperty: #letTheMusicPlay)
            ifTrue: [world removeProperty: #letTheMusicPlay]
            ifFalse: [Smalltalk at: #ScorePlayer ifPresent: [:playerClass | 
                        playerClass allSubInstancesDo: [:player | player pause]]]."

        "returningFlag
            ifTrue: [nextProject := CurrentProject]
            ifFalse: [previousProject := CurrentProject]."

        "CurrentProject saveState."
        "CurrentProject := self."
        "Smalltalk newChanges: changeSet."
        "TranscriptStream newTranscript: transcript."
        "Sensor flushKeyboard."
        "recorderOrNil := Display pauseMorphicEventRecorder."

        "Display changeMorphicWorldTo: world."  "Signifies Morphic"
    world 
        installAsActiveSubprojectIn: enclosingWorld 
        titled: self name.

        "recorderOrNil ifNotNil: [recorderOrNil resumeIn: world]."
    world triggerOpeningScripts.
    self removeParameter: #exportState.
        "self spawnNewProcessAndTerminateOld: true"
]

{ #category : #'squeaklet on server' }
MorphicProject >> enterIfThereOrFind: aProjectName [

	| newProject |
	newProject := Project named: aProjectName.
	newProject ifNotNil: [^newProject enter].

	ComplexProgressIndicator new 
		targetMorph: nil;
		historyCategory: 'project loading';
		withProgressDo: [
			[
				newProject := self fromMyServerLoad: aProjectName
			] 
				on: ProjectViewOpenNotification
				do: [ :ex | ex resume: false]		
					"we probably don't want a project view morph in this case"
		].

	newProject ifNotNil: [^newProject enter].
	Beeper beep.
]

{ #category : #'file in\/out' }
MorphicProject >> exportSegmentInSexpWithChangeSet: aChangeSetOrNil fileName: aFileName directory: aDirectory withoutInteraction: noInteraction [

	| fd sexp actualName |

	world ifNil: [^ false].
	world presenter ifNil: [^ false].
	(world respondsTo: #sissScanObjectsAsEtoysProject) ifFalse: [^ false].

	Command initialize.
	world clearCommandHistory.
	world cleanseStepList.
	world localFlapTabs size = world flapTabs size ifFalse: [
		noInteraction ifTrue: [^ false].
		self error: 'Still holding onto Global flaps'].

	fd := aDirectory directoryNamed: self resourceDirectoryName.
	fd assureExistence.

	"Must activate old world because this is run at #armsLength.
	Otherwise references to ActiveWorld, ActiveHand, or ActiveEvent
	will not be captured correctly if referenced from blocks or user code."
	world becomeActiveDuring:[
		sexp := world sissScanObjectsAsEtoysProject.
	].
	(aFileName endsWith: '.pr') ifTrue: [
		actualName := (aFileName copyFrom: 1 to: aFileName size - 3), '.sexp'.
	] ifFalse: [
		actualName := aFileName
	].

	self
		writeForExportInSexp: sexp withSources: actualName
		inDirectory: fd
		changeSet: aChangeSetOrNil.
	SecurityManager default signFile: actualName directory: fd.
	self storeHtmlPageIn: fd.
	(world valueOfProperty: #ProjectDetails ifAbsent: [Dictionary new])
		at: 'Project-Format' put: 'S-Expression'.
	self storeManifestFileIn: fd.
	self compressFilesIn: fd to: aFileName in: aDirectory.

	^ true

]

{ #category : #'file in\/out' }
MorphicProject >> exportSegmentWithChangeSet: aChangeSetOrNil fileName: aFileName
directory: aDirectory [

	^ self exportSegmentWithChangeSet: aChangeSetOrNil fileName: aFileName directory: aDirectory withoutInteraction: false
]

{ #category : #'file in\/out' }
MorphicProject >> exportSegmentWithChangeSet: aChangeSetOrNil fileName: aFileName
directory: aDirectory withoutInteraction: noInteraction [
	"Store my project out on the disk as an *exported*
ImageSegment.  All outPointers will be in a form that can be resolved
in the target image.  Name it <project name>.extSeg.  Whatdo we do
about subProjects, especially if they are out as local image
segments?  Force them to come in?
	Player classes are included automatically."

	| is str ans revertSeg roots holder collector fd mgr stacks |

	"Files out a changeSet first, so that a project can contain
its own classes"
	world ifNil: [^ false].
	world presenter ifNil: [^ false].

	ScrapBook default emptyScrapBook.
	(world respondsTo: #cleanUpReferences) ifTrue:
		[world cleanUpReferences].
	world currentHand pasteBuffer: nil.	  "don't write the paste buffer."
	world currentHand mouseOverHandler initialize.	  "forget about any
	references here"
		"Display checkCurrentHandForObjectToPaste."
	Command initialize.
	world clearCommandHistory.
	world fullReleaseCachedState; releaseViewers.
	world cleanseStepList.
	world localFlapTabs size = world flapTabs size ifFalse: [
		noInteraction ifTrue: [^ false].
		self error: 'Still holding onto Global flaps'].
	world releaseSqueakPages.
	Smalltalk at: #ScriptEditorMorph ifPresent: [:s |
		s writingUniversalTiles: (self projectParameterAt: #universalTiles ifAbsent: [false])].
	holder := Project allProjects.	"force them in to outPointers, where
	DiskProxys are made"

	"Just export me, not my previous version"
	revertSeg := self parameterAt: #revertToMe.
	self removeParameter: #revertToMe.

	roots := OrderedCollection new.
	roots add: self; add: world; add: transcript; add: aChangeSetOrNil; add: thumbnail; add: world activeHand.

		"; addAll: classList; addAll: (classList collect: [:cls | cls class])"

	roots := roots reject: [ :x | x isNil].	"early saves may not have
	active hand or thumbnail"

	fd := aDirectory directoryNamed: self resourceDirectoryName.
	fd assureExistence.
	"Clean up resource references before writing out"
	mgr := self resourceManager.
	self resourceManager: nil.
	ResourceCollector current: ResourceCollector new.
	ResourceCollector current localDirectory: fd.
	ResourceCollector current baseUrl: self resourceUrl.
	ResourceCollector current initializeFrom: mgr.
	ProgressNotification signal: '2:findingResources' extra:
'(collecting resources...)' translated.
	"Must activate old world because this is run at #armsLength.
	Otherwise references to ActiveWorld, ActiveHand, or ActiveEvent
	will not be captured correctly if referenced from blocks or user code."
	world becomeActiveDuring:[
		is := ImageSegment copySmartRootsExport: roots asArray.
		"old way was (is := ImageSegment new
copyFromRootsForExport: roots asArray)"
	].
	self resourceManager: mgr.
	collector := ResourceCollector current.
	ResourceCollector current: nil.
	ProgressNotification signal: '2:foundResources' extra: ''.
	is state = #tooBig ifTrue: [
		collector replaceAll.
		^ false].

	str := ''.
	"considered legal to save a project that has never been entered"
	(is outPointers includes: world) ifTrue: [
		str := str, '\Project''s own world is not in the segment.' translated withCRs].
	str isEmpty ifFalse: [
		ans := UIManager default chooseFrom: {
			'Do not write file' translated.
			'Write file anyway' translated.
			'Debug' translated.
		} title: str.
		ans = 1 ifTrue: [
			revertSeg ifNotNil: [projectParameters at:
	#revertToMe put: revertSeg].
			collector replaceAll.
			^ false].
		ans = 3 ifTrue: [
			collector replaceAll.
			self halt: 'Segment not written' translated]].
		stacks := is findStacks.

		is
			writeForExportWithSources: aFileName
			inDirectory: fd
			changeSet: aChangeSetOrNil.
		SecurityManager default signFile: aFileName directory: fd.
		"Compress all files and update check sums"
		collector forgetObsolete.
		self storeResourceList: collector in: fd.
		self storeHtmlPageIn: fd.
		self storeManifestFileIn: fd.
		self writeStackText: stacks in: fd registerIn: collector.
		"local proj.005.myStack.t"
		self compressFilesIn: fd to: aFileName in: aDirectory
	resources: collector.
				"also deletes the resource directory"
		"Now update everything that we know about"
		mgr updateResourcesFrom: collector.

	revertSeg ifNotNil: [projectParameters at: #revertToMe put: revertSeg].
	holder.

	collector replaceAll.

	world flapTabs do: [:ft |
			(ft respondsTo: #unhibernate) ifTrue: [ft unhibernate]].
	is arrayOfRoots do: [:obj |
		obj isScriptEditorMorph ifTrue: [obj unhibernate]].
	^ true

]

{ #category : #'scheduling & debugging' }
MorphicProject >> fatalDrawingError: errMsg [
	"Morphic drawing failed and could not be recovered. So we end up here."
	
	self primitiveError: errMsg.

	"Hm... we should jump into a 'safe' worldState here, but how do we find it?!"
]

{ #category : #enter }
MorphicProject >> finalEnterActions: leavingProject [
	"Perform the final actions necessary as the receiver project is entered"

	| navigator armsLengthCmd navType thingsToUnhibernate |
	"If this image has a global World variable, update it now"
	Smalltalk globals at: #World
		ifPresent: [ :w | Smalltalk globals at: #World put: world ].
	world install.
	world transferRemoteServerFrom: leavingProject world.
	"(revertFlag | saveForRevert | forceRevert) ifFalse: [
		(Preferences valueOfFlag: #projectsSentToDisk) ifTrue: [
			self storeSomeSegment]]."
	
	"Transfer event recorder to me."
	leavingProject isMorphic ifTrue: [
		leavingProject world pauseEventRecorder ifNotNil: [:rec |
			rec resumeIn: world]].

	world triggerOpeningScripts.


	self initializeMenus.
	self projectParameters 
		at: #projectsToBeDeleted 
		ifPresent: [ :projectsToBeDeleted |
			self removeParameter: #projectsToBeDeleted.
			projectsToBeDeleted do: [:each | each delete]].

	Locale switchAndInstallFontToID: self localeID.

	thingsToUnhibernate := world valueOfProperty: #thingsToUnhibernate ifAbsent: [#()].
	thingsToUnhibernate do: [:each | each unhibernate].
	world removeProperty: #thingsToUnhibernate.

	navType := ProjectNavigationMorph preferredNavigator.
	armsLengthCmd := self parameterAt: #armsLengthCmd ifAbsent: [nil].
	navigator := world findA: navType.
	(Preferences classicNavigatorEnabled and: [Preferences showProjectNavigator and: [navigator isNil]]) ifTrue:
		[(navigator := navType new)
			bottomLeft: world bottomLeft;
			openInWorld: world].
	navigator notNil & armsLengthCmd notNil ifTrue:
		[navigator color: Color lightBlue].
	armsLengthCmd notNil ifTrue:
		[Preferences showFlapsWhenPublishing
			ifFalse:
				[self flapsSuppressed: true.
				navigator ifNotNil:	[navigator visible: false]].
		armsLengthCmd openInWorld: world].
	world reformulateUpdatingMenus.
	world presenter positionStandardPlayer.
	self assureMainDockingBarPresenceMatchesPreference.

	world repairEmbeddedWorlds.
]

{ #category : #enter }
MorphicProject >> finalExitActions: enteringProject [

	world triggerClosingScripts.

	"Pause sound players, subject to preference settings"
	(world hasProperty: #letTheMusicPlay)
		ifTrue: [world removeProperty: #letTheMusicPlay]
		ifFalse: [SoundService stop].

	world sleep.

	(world findA: ProjectNavigationMorph)
		ifNotNil: [:navigator | navigator retractIfAppropriate].

	self clearGlobalState.
	EventSensor default flushEvents.
	
	self world submorphsDo: [:ea | ea removeProperty: #dropShadow].
]

{ #category : #utilities }
MorphicProject >> findAFolderForProject: aProject label: dialogLabel [
	"Find a folder for saving or loading a project"

	^DirectoryChooserDialog findAFolderForProject: aProject label: dialogLabel

]

{ #category : #utilities }
MorphicProject >> findProjectView: projectDescription [
	"In this world, find the morph that holds onto the project described by projectDescription.
	projectDescription can be a project, or the name of a project.  The project may be
	represented by a DiskProxy. The holder morph may be at any depth in the world.."

	| pName |
	pName := (projectDescription isString) 
		ifTrue: [projectDescription]
		ifFalse: [projectDescription name].
	world allMorphsDo: [:pvm | | dpName |
	pvm class == ProjectViewMorph ifTrue: [
		(pvm project class == Project and: 
			[pvm project name = pName]) ifTrue: [^ pvm].
			pvm project class == DiskProxy ifTrue: [ 
			dpName := pvm project constructorArgs first.
			dpName := (dpName findTokens: '/') last.
			dpName := (Project parseProjectFileName: dpName unescapePercents) first.
			dpName = pName ifTrue: [^ pvm]]]].
	^ nil
]

{ #category : #'flaps support' }
MorphicProject >> flapsSuppressed: aBoolean [
	"Make the setting of the flag that governs whether global flaps are suppressed in the project be as indicated and add or remove the actual flaps"

	super flapsSuppressed: aBoolean.
	self == Project current
		ifFalse:   "Anomalous case where this project is not the current one."
			[aBoolean
				ifTrue:		
					[Flaps globalFlapTabsIfAny do:
						[:aFlapTab | Flaps removeFlapTab: aFlapTab keepInList: true]]

				ifFalse:
					[Smalltalk isMorphic  ifTrue:
						[self currentWorld addGlobalFlaps]]].
	Project current assureNavigatorPresenceMatchesPreference
]

{ #category : #editors }
MorphicProject >> formEdit: aForm [
	"Start up an instance of the form editor on a form."
 
	self inform: 'A Morphic editor has not been implemented. Enter an MVC project to edit this form or use #bitEdit'
]

{ #category : #editors }
MorphicProject >> formViewClass [
	"Answer a class suitable for a view on a form or collection of forms"

	^ GraphicalDictionaryMenu
]

{ #category : #futures }
MorphicProject >> future: receiver do: aSelector at: deltaMSecs args: args [
	"Send a message deltaSeconds into the future.  No response is expected."
	| msg |
	msg := MessageSend receiver: receiver selector: aSelector arguments: args.
	deltaMSecs = 0 
		ifTrue: [self addDeferredUIMessage: msg]
		ifFalse: [
			world 
				addAlarm: #addDeferredUIMessage: 
				withArguments: {msg}
				for: self
				at: (Time millisecondClockValue + deltaMSecs)
		]..
	^nil
]

{ #category : #futures }
MorphicProject >> future: receiver send: aSelector at: deltaMSecs args: args [
	"Send a message deltaSeconds into the future.  Answers a Promise that will be resolved at some time in the future."
	| pr closure |
	pr := Promise new.
	closure := [pr fulfillWith: [receiver perform: aSelector withArguments: args]].
	deltaMSecs = 0
		ifTrue: [self addDeferredUIMessage: closure]
		ifFalse: [
			world 
				addAlarm: #addDeferredUIMessage: 
				withArguments: {closure}
				for: self
				at: (Time millisecondClockValue + deltaMSecs)
		].
	^pr
		
]

{ #category : #'flaps support' }
MorphicProject >> globalFlapEnabledString: aFlapTab [
	"Answer the string to be shown in a menu to represent the status of the given flap regarding whether it it should be shown in this project."

	^ (self isFlapEnabled: aFlapTab)
		ifTrue:
			['<on>', aFlapTab wording]
		ifFalse:
			['<off>', aFlapTab wording]
]

{ #category : #'flaps support' }
MorphicProject >> globalFlapWithIDEnabledString: aFlapID [
	"Answer the string to be shown in a menu to represent the status of the given flap regarding whether it it should be shown in this project."

	| aFlapTab |
	aFlapTab := Flaps globalFlapTabWithID: aFlapID.
	^ (self isFlapEnabled: aFlapTab)
		ifTrue:
			['<on>', aFlapTab wording]
		ifFalse:
			['<off>', aFlapTab wording]
]

{ #category : #initialize }
MorphicProject >> initMorphic [
	"Written so that Morphic can still be removed.  Note that #initialize is never actually called for a morphic project -- see the senders of this method."

	self flag: #toRemove. "check if this method still used by Etoys"
	Smalltalk verifyMorphicAvailability ifFalse: [^ nil].
	changeSet := ChangeSet new.
	transcript := TranscriptStream new.
	displayDepth := Display depth.
	parentProject := CurrentProject.
	world := PasteUpMorph newWorldForProject: self.
	Locale switchToID: CurrentProject localeID.
	self initializeProjectPreferences. "Do this *after* a world is installed so that the project will be recognized as a morphic one."
	Preferences useVectorVocabulary ifTrue: [world installVectorVocabulary]
]

{ #category : #initialize }
MorphicProject >> initialize [
	"Initialize a new Morphic Project"
	super initialize.
	world := PasteUpMorph newWorldForProject: self.
	self setWorldBackground: true.
	Locale switchToID: CurrentProject localeID.
	Preferences useVectorVocabulary ifTrue: [world installVectorVocabulary]
]

{ #category : #enter }
MorphicProject >> initializeMenus [
	"Menu setting for these classes may have been modified by another
	Morphic project, e.g. SimpleMorphic. Ensure that they are restored to the
	expected menus."

	Editor initialize.
]

{ #category : #transcripter }
MorphicProject >> initializeParagraphForTranscripter: transcripter [
	"A transcripter is a minimal user interface to support an emergency evaluator.
	A Morphic project uses class NewParagraph."
	transcripter morphicInitializeParagraph: NewParagraph
]

{ #category : #initialize }
MorphicProject >> installPasteUpAsWorld: pasteUpMorph [
	"(ProjectViewMorph newMorphicProjectOn: aPasteUpMorph) openInWorld."

	world := pasteUpMorph beWorldForProject: self.
	self setWorldBackground: true.
]

{ #category : #'scheduling & debugging' }
MorphicProject >> interruptCleanUpFor: interruptedProcess [
	"Clean up things in case of a process interrupt."

	super interruptCleanUpFor: interruptedProcess.

	self uiProcess == interruptedProcess ifTrue: [
		self currentHand ifNotNil: [:hand | hand interrupted].
		world removeProperty: #shouldDisplayWorld.
		Preferences eToyFriendly ifTrue: [world stopRunningAll]].
]

{ #category : #display }
MorphicProject >> invalidate [
	"Invalidate the entire project so that a redraw will be forced later."
	world restoreMorphicDisplay.
]

{ #category : #'flaps support' }
MorphicProject >> isFlapEnabled:  aFlapTab [
	"Answer whether the given flap tab is enabled in this project"

	^ self isFlapIDEnabled: aFlapTab flapID
]

{ #category : #'flaps support' }
MorphicProject >> isFlapIDEnabled:  aFlapID [
	"Answer whether a flap of the given ID is enabled in this project"

	| disabledFlapIDs  |
	disabledFlapIDs := self parameterAt: #disabledGlobalFlapIDs ifAbsent: [^ true].
	^ (disabledFlapIDs includes: aFlapID) not
]

{ #category : #enter }
MorphicProject >> isIncompletelyLoaded [
	"Answer true if project is incomplete and should be loaded from server "

	(world isKindOf: StringMorph)
		ifTrue: [self inform: 'This project is not all here. I will try to load a complete version.' translated.
			^ true].
	^ false
]

{ #category : #testing }
MorphicProject >> isMorphic [
	"Duh."
	^true
]

{ #category : #utilities }
MorphicProject >> jumpToProject [
	"Present a list of potential projects and enter the one selected."

	"Project current jumpToProject"

	| menu |
menu:=MenuMorph new.
menu defaultTarget: self.
	menu := self buildJumpToMenu: menu.
	menu popUpInWorld
]

{ #category : #'scheduling & debugging' }
MorphicProject >> lastDeferredUIMessage [
	"Answer the most recently scheduled deferredUIMessage."

	^WorldState lastDeferredUIMessage
]

{ #category : #'file in\/out' }
MorphicProject >> loadFromServer: newerAutomatically [
	"If a newer version of me is on the server, load it."
	| pair resp server |
	self assureIntegerVersion.

	self isCurrentProject ifTrue: ["exit, then do the command"
		^ self armsLengthCommand: #loadFromServer withDescription: 'Loading' translated
	].
	server := self tryToFindAServerWithMe ifNil: [^ nil].
	pair := self class mostRecent: self name onServer: server.
	pair first ifNil: [^ self inform: ('can''t find file on server for {1}' translated format: {self name})].
	self currentVersionNumber > pair second ifTrue: [
		^ self inform: ('That server has an older version of the project.' translated)].
	version = (Project parseProjectFileName: pair first) second ifTrue: [
		resp := (UIManager default chooseFrom: 
				(Array with: 'Reload anyway' translated 
						with: 'Cancel' translated withCRs) 
				title:  'The only changes are the ones you made here.' translated).
		resp ~= 1 ifTrue: [^ nil]
	] ifFalse: [
		newerAutomatically ifFalse: [
			resp := (UIManager default 
						chooseFrom: #('Load it' 'Cancel') 
						title:  'A newer version exists on the server.').
			resp ~= 1 ifTrue: [^ nil]
		].
	].

	"let's avoid renaming the loaded change set since it will be replacing ours"
	self projectParameters at: #loadingNewerVersion put: true.

	ComplexProgressIndicator new 
		targetMorph: nil;
		historyCategory: 'project loading';
		withProgressDo: [
			ProjectLoading
				installRemoteNamed: pair first
				from: server
				named: self name
				in: parentProject
		]

]

{ #category : #'menu messages' }
MorphicProject >> makeThumbnail [
	"Make a thumbnail image of this project from the Display."
	world displayWorldSafely. "clean pending damage"
	super makeThumbnail.
	(Smalltalk at: #InternalThreadNavigationMorph) ifNotNil: [:tnMorph |
		tnMorph cacheThumbnailFor: self].
	^ thumbnail
]

{ #category : #release }
MorphicProject >> myPlayerClasses [
	"Answer all my (non-systemDefined) player classes"
	| classes presenter |
	classes := Set new.
	presenter := self world presenter.
	presenter ifNotNil: [
		presenter flushPlayerListCache.		"old and outside guys"
		presenter allExtantPlayers do:
			[:p | p class isSystemDefined ifFalse: [classes add: p class]]].
	^classes
]

{ #category : #display }
MorphicProject >> noDisplayDuring: block [

	self world noDisplayDuring: block.
]

{ #category : #'file in\/out' }
MorphicProject >> noteManifestDetailsIn: manifestInfo [
	"The receiver is a project being loaded.  From the dictionary provided, absorb and remember whether it's an 'old' (pre-olpc) project, and remember the GUID, user, and prev-GUID associated with the project when these data are available in the incoming manifest."

	| manifestDict oldProject |
	manifestInfo isEmptyOrNil ifTrue: [^ self projectParameterAt: #oldProject put: true].

	manifestDict := (manifestInfo isKindOf: Dictionary) ifTrue: [manifestInfo] ifFalse: [manifestInfo first].

	oldProject := ((manifestDict at: 'Squeak-Version' ifAbsent: ['']) beginsWith: 'etoys') not.
	self projectParameterAt: #oldProject put: oldProject.

	manifestDict at: #URI ifPresent: [:aUri | self projectParameterAt: #URI put: aUri].
	manifestDict at: #user ifPresent: [:aUser | self projectParameterAt: #user put: aUser].
	manifestDict at: #'prev-URI' ifPresent: [:aUri | self projectParameterAt: #'prev-URI' put: aUri]
]

{ #category : #utilities }
MorphicProject >> offerMenu: menuSelector from: aModel shifted: aBoolean [
	"Pop up a menu whose target is aModel and whose contents are provided
	by sending the menuSelector to the model. The menuSelector takes two
	arguments: a menu, and a boolean representing the shift state."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: aModel.
	aModel perform: menuSelector with: aMenu with: aBoolean.
	aMenu popUpInWorld

]

{ #category : #'squeaklet on server' }
MorphicProject >> openBlankProjectNamed: projName [

	| proj projViewer |

	proj := MorphicProject openViewOn: nil.
	proj changeSet name: projName.
	proj world addMorph: (
		TextMorph new 
			beAllFont: ((TextStyle default fontOfSize: 26) emphasized: 1);
			color: Color red;
			contents: 'Welcome to a new project - ',projName
	).
	proj setParent: self.
	projViewer := (self findProjectView: projName) ifNil: [^proj].
	(projViewer owner isSystemWindow) ifTrue: [
			projViewer owner model: proj].
	^ projViewer project: proj
]

{ #category : #editors }
MorphicProject >> openImage: aForm name: fullName saveResource: aBoolean [
	"Open a view on an image. If aBoolean is true, save the image as a project resource."

	aBoolean ifTrue:
		[self resourceManager 
			addResource: aForm 
			url: (FileDirectory urlForFileNamed: fullName) asString].
	(world drawingClass withForm: aForm) openInWorld

]

{ #category : #initialize }
MorphicProject >> openProject: aProject [
	"Create a new for a new project in the context of the receiver"
	ProjectViewMorph openOn: aProject.
]

{ #category : #utilities }
MorphicProject >> pointerMoved [
	"Pointer has moved during a drag operation. Perform any necessary updates.
	In Morphic, pay the price for reading the sensor directly."

	world activeHand
			newMouseFocus: nil;
			showTemporaryCursor: nil;
			flushEvents
]

{ #category : #release }
MorphicProject >> prepareForDelete [
	"The window in which the project is housed is about to deleted. Perform
	any necessary actions to prepare for deletion."

	| list |
	Smalltalk at: #WonderlandCameraMorph ifPresent:[:aClass |
		world submorphs do:   "special release for wonderlands"
					[:m | (m isKindOf: aClass)
							and: [m getWonderland release]]].
	"Remove Player classes and metaclasses owned by project"
	self myPlayerClasses do: [:playerCls | playerCls removeFromSystemUnlogged].


]

{ #category : #display }
MorphicProject >> previewImageForm [

	^ self world imageForm
]

{ #category : #'scheduling & debugging' }
MorphicProject >> recursiveError: msg [

	"1a) If the recursion happens in a non-ui process, make sure to escalate it in the ui process."
	Processor activeProcess == self uiProcess ifFalse: [
		self addDeferredUIMessage: [super recursiveError: msg].
		^ Processor activeProcess suspend].
	
	"1b) Normal escalation of error recursion in the ui process." 
	^ super recursiveError: msg
]

{ #category : #'docking bars support' }
MorphicProject >> removeMainDockingBar [
	"Remove the receiver's main docking bars"
	self world mainDockingBars
		do: [:each | each delete]
]

{ #category : #display }
MorphicProject >> restore [

	world displayWorldSafely.
]

{ #category : #'scheduling & debugging' }
MorphicProject >> restoreDisplay [
	"Give all morphs a chance to draw again."
	self world ifNotNil: [:w | w allMorphsDo: [:ea | ea removeProperty: #errorOnDraw ]].

	super restoreDisplay.
]

{ #category : #enter }
MorphicProject >> resumeEventRecorder: recorder [

	recorder ifNotNil: [:rec | rec resumeIn: world].
]

{ #category : #enter }
MorphicProject >> scheduleProcessForEnter [
	"Complete the enter: by launching a new process"

	self spawnNewProcess.
]

{ #category : #utilities }
MorphicProject >> setAsBackground: aFormOrColorOrFillStyle [
	"Set  aForm as a background image."

	| thisWorld newFill oldFill |
	thisWorld := self world.
	
	oldFill := thisWorld fillStyle.
	thisWorld fillStyle: aFormOrColorOrFillStyle.
	newFill := thisWorld fillStyle.
	
	newFill rememberCommand:
		(Command new cmdWording: 'set background to a picture' translated;
			undoTarget: thisWorld selector: #fillStyle: argument: oldFill;
			redoTarget: thisWorld selector: #fillStyle: argument: newFill).
	
	thisWorld setProperty: #hasCustomBackground toValue: true.
]

{ #category : #'flaps support' }
MorphicProject >> setFlaps [

	| flapTabs flapIDs sharedFlapTabs navigationMorph |
	self flag: #toRemove. "check if this method still used by Etoys"

	flapTabs := self world flapTabs.
	flapIDs := flapTabs collect: [:tab | tab knownName].
	flapTabs
		do: [:tab | (tab isMemberOf: ViewerFlapTab)
				ifFalse: [tab isGlobalFlap
						ifTrue: [Flaps removeFlapTab: tab keepInList: false.
							tab currentWorld reformulateUpdatingMenus]
						ifFalse: [| referent | 
							referent := tab referent.
							referent isInWorld
								ifTrue: [referent delete].
							tab delete]]].
	sharedFlapTabs := Flaps classPool at: #SharedFlapTabs.
	flapIDs
		do: [:id | 
			id = 'Navigator' translated
				ifTrue: [sharedFlapTabs add: Flaps newNavigatorFlap].
			id = 'Widgets' translated
				ifTrue: [sharedFlapTabs add: Flaps newWidgetsFlap].
			id = 'Tools' translated
				ifTrue: [sharedFlapTabs add: Flaps newToolsFlap].
			id = 'Squeak' translated
				ifTrue: [sharedFlapTabs add: Flaps newSqueakFlap].
			id = 'Supplies' translated
				ifTrue: [sharedFlapTabs add: Flaps newSuppliesFlap].
			id = 'Stack Tools' translated
				ifTrue: [sharedFlapTabs add: Flaps newStackToolsFlap].
			id = 'Painting' translated
				ifTrue: [sharedFlapTabs add: Flaps newPaintingFlap].
			id = 'Objects' translated
				ifTrue: [sharedFlapTabs add: Flaps newObjectsFlap ]].
	2 timesRepeat: [flapIDs do: [:id | Flaps enableDisableGlobalFlapWithID: id]].
	self world flapTabs
		do: [:flapTab | flapTab isCurrentlyTextual
				ifTrue: [flapTab changeTabText: flapTab knownName]].
	Flaps positionNavigatorAndOtherFlapsAccordingToPreference.
	navigationMorph := self currentWorld findDeeplyA: ProjectNavigationMorph preferredNavigator.
	navigationMorph isNil
		ifTrue: [^ self].
	navigationMorph allMorphs
		do: [:morph | morph class == SimpleButtonDelayedMenuMorph
				ifTrue: [(morph findA: ImageMorph) isNil
						ifTrue: [| label | 
							label := morph label.
							label isNil
								ifFalse: [| name | 
									name := morph knownName.
									name isNil
										ifTrue: [morph name: label.
											name := label].
									morph label: name translated]]]]
]

{ #category : #initialize }
MorphicProject >> setWorldBackground: force [

	((world hasProperty: #hasCustomBackground) and: [force not])
		ifTrue: [^ self].

	"If the user has a custom background, propagate it into the new project."
	((Project current ~~ self and: [Project current isMorphic]) and: [Project current world hasProperty: #hasCustomBackground])
		ifTrue: [
			world fillStyle: Project current world fillStyle copy.
			world setProperty: #hasCustomBackground toValue: true]
		ifFalse: [
			world removeProperty: #hasCustomBackground.
			world fillStyle: (self userInterfaceTheme background ifNil: [self class defaultFill])].
]

{ #category : #utilities }
MorphicProject >> showImage: aForm named: imageName [
	"Show an image, possibly attached to the pointer for positioning"

	HandMorph attach: (world drawingClass withForm: aForm)

]

{ #category : #'docking bars support' }
MorphicProject >> showWorldMainDockingBar [

	^ self projectPreferenceFlagDictionary
		at: #showWorldMainDockingBar
		ifAbsent: [ false ]
]

{ #category : #'docking bars support' }
MorphicProject >> showWorldMainDockingBar: aBoolean [ 
	"Change the receiver to show the main docking bar"
	self projectPreferenceFlagDictionary at: #showWorldMainDockingBar put: aBoolean.
	self assureMainDockingBarPresenceMatchesPreference
]

{ #category : #'docking bars support' }
MorphicProject >> showWorldMainDockingBarString [
	^ (self showWorldMainDockingBar
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'show main docking bar (M)' translated
]

{ #category : #'active process' }
MorphicProject >> spawnNewProcess [

	uiProcess := [
		[world doOneCycle.  Processor yield ] repeat.
	] newProcess priority: Processor userSchedulingPriority.
	uiProcess resume
]

{ #category : #'active process' }
MorphicProject >> spawnNewProcessAndTerminateOld: terminate [

	self spawnNewProcess.
	terminate
		ifTrue: [Processor terminateActive]
		ifFalse: [Processor activeProcess suspend]
]

{ #category : #'active process' }
MorphicProject >> spawnNewProcessIfThisIsUI: suspendedProcess [
	"Initialize a UI process if needed. Answer true if suspendedProcess was interrupted
	from a UI process."
	self uiProcess == suspendedProcess ifTrue: [
		self spawnNewProcess.
		^true
	].

	"Ensure that the UI process is running."
	self uiProcess
		ifNil: [self spawnNewProcess]
		ifNotNil: [:p | p isSuspended ifTrue: [
			self restoreDisplay.
			self uiProcess resume]].

	^false		"no new process was created"

]

{ #category : #enter }
MorphicProject >> startUpActions [
	
	super startUpActions.
	
	self world install.
	self world firstHand position: 100@100.
]

{ #category : #'file in\/out' }
MorphicProject >> storeSegment [
	"Store my project out on the disk as an ImageSegment.  Keep the outPointers in memory.  Name it <project name>.seg.  *** Caller must be holding (Project alInstances) to keep subprojects from going out. ***"

	| currentWorld is sizeHint |
	currentWorld := Project current world.
	(currentWorld == world) ifTrue: [^ false]. 
		"self inform: 'Can''t send the current world out'."
	world isInMemory ifFalse: [^ false].  "already done"
	world ifNil: [^ false].  world presenter ifNil: [^ false].

	ScrapBook default emptyScrapBook.
	currentWorld checkCurrentHandForObjectToPaste.
	world releaseSqueakPages.
	sizeHint := self projectParameters at: #segmentSize ifAbsent: [0].

	is := ImageSegment
			copyFromRootsLocalFileFor: {world presenter. world}	"world, and all Players"
			sizeHint: sizeHint.

	is state = #tooBig ifTrue: [^ false].
	is segment size < 2000 ifTrue: ["debugging" 
		Transcript show: self name, ' only ', is segment size printString, 
			'bytes in Segment.'; cr].
	self projectParameters at: #segmentSize put: is segment size.
	is extract; writeToFile: self name.
	^ true
]

{ #category : #'file in\/out' }
MorphicProject >> storeSegmentNoFile [
	"For testing.  Make an ImageSegment.  Keep the outPointers in memory.  Also useful if you want to enumerate the objects in the segment afterwards (allObjectsDo:)"

	| is currentWorld |
	currentWorld := Project current world.
	(currentWorld == world) ifTrue: [^ self].		" inform: 'Can''t send the current world out'."
	world isInMemory ifFalse: [^ self].  "already done"
	world ifNil: [^ self].  world presenter ifNil: [^ self].

	"Do this on project enter"
	currentWorld flapTabs do: [:ft | ft referent adaptToWorld: currentWorld].
		"Hack to keep the Menu flap from pointing at my project"
	"Preferences setPreference: #useGlobalFlaps toValue: false."
	"Utilities globalFlapTabsIfAny do:
		[:aFlapTab | Utilities removeFlapTab: aFlapTab keepInList: false].
	Utilities clobberFlapTabList.	"
	"project world deleteAllFlapArtifacts."
	"self currentWorld deleteAllFlapArtifacts.	"
	ScrapBook default emptyScrapBook.
	currentWorld checkCurrentHandForObjectToPaste2.

	is := ImageSegment
			copyFromRootsLocalFileFor: {world presenter. world}	"world, and all Players"
			sizeHint: 0.

	is segment size < 800 ifTrue: ["debugging" 
		Transcript show: self name, ' did not get enough objects'; cr.  ^ Beeper beep].

	is extract.
	"is instVarAt: 2 put: is segment clone."		"different memory"
]

{ #category : #subprojects }
MorphicProject >> subProjects [
	"Answer a list of all the subprojects  of the receiver. "
	
	^ (super subProjects, (world submorphs 
		select: [:m | (m isSystemWindow) and: [m model isKindOf: Project]]
		thenCollect: [:m | m model])) asSet asArray.
]

{ #category : #'flaps support' }
MorphicProject >> suppressFlapsString [
	^ (self flapsSuppressed
		ifTrue: ['<no>']
		ifFalse: ['<yes>']), 'show shared tabs (F)' translated
]

{ #category : #enter }
MorphicProject >> suspendProcessForDebug [

	| p |
	self assert: Processor activeProcess == uiProcess.
	
	p := uiProcess.
	uiProcess := nil.
	p suspend.
]

{ #category : #'scheduling & debugging' }
MorphicProject >> syntaxError: aSyntaxErrorNotification [

	| compilerProcess errorWasInUIProcess debugger |
	debugger := (super syntaxError: aSyntaxErrorNotification) model debugger.
	
	compilerProcess := Processor activeProcess.
	errorWasInUIProcess := self spawnNewProcessIfThisIsUI: compilerProcess.
	
	debugger errorWasInUIProcess: errorWasInUIProcess.
	compilerProcess suspend.
]

{ #category : #enter }
MorphicProject >> terminateProcessForLeave [
	"There is only one UI process. Kill it."
	
	self assert: Processor activeProcess == uiProcess.
	uiProcess := nil.
	Processor terminateActive.
]

{ #category : #utilities }
MorphicProject >> textWindows [
	"Answer a dictionary of all system windows for text display keyed by window title.
	Generate new window titles as required to ensure unique keys in the dictionary."

	| aDict windows title |
	aDict := Dictionary new.
	windows := world submorphs select: [:m | m isSystemWindow].
	windows do:
		[:w | | assoc |
		assoc := w titleAndPaneText.
		assoc ifNotNil:
			[w holdsTranscript ifFalse:
				[title := assoc key.
				(aDict includesKey: title) ifTrue: [ | newKey | "Ensure unique keys in aDict"
					(1 to: 100) detect: [:e |
							newKey := title, '-', e asString.
							(aDict includesKey: newKey) not].
					title := newKey.
					assoc := newKey -> assoc value].
				aDict add: assoc]]].
	^ aDict

]

{ #category : #'flaps support' }
MorphicProject >> toggleFlapsSuppressed [
	"Project current toggleFlapsSuppressed"

	^self flapsSuppressed: self flapsSuppressed not.
]

{ #category : #'docking bars support' }
MorphicProject >> toggleShowWorldMainDockingBar [
	self showWorldMainDockingBar: self showWorldMainDockingBar not
]

{ #category : #'active process' }
MorphicProject >> uiProcess [
	^uiProcess
]

{ #category : #'active process' }
MorphicProject >> uiProcess: newUIProcess [
	^uiProcess := newUIProcess
]

{ #category : #language }
MorphicProject >> updateLocaleDependents [
	"Set the project's natural language as indicated"

	(self world respondsTo: #isTileScriptingElement) ifTrue: "Etoys present" [
		self world allTileScriptingElements do: [:viewerOrScriptor |
			viewerOrScriptor localeChanged]].
	
	Flaps disableGlobalFlaps: false.
	(Preferences eToyFriendly or: [
		(Smalltalk classNamed: #SugarNavigatorBar) ifNotNil: [:c | c showSugarNavigator] ifNil: [false]])
		ifTrue: [
			Flaps addAndEnableEToyFlaps.
			self world addGlobalFlaps]
		ifFalse: [Flaps enableGlobalFlaps].

	(self isFlapIDEnabled: 'Navigator' translated)
		ifFalse: [Flaps enableDisableGlobalFlapWithID: 'Navigator' translated].
	
	ScrapBook default emptyScrapBook.
	MenuIcons initializeTranslations.
	
	super updateLocaleDependents.
	
	"self setFlaps.
	self setPaletteFor: aLanguageSymbol."
]

{ #category : #display }
MorphicProject >> viewLocFor: exitedProject [ 
	"Look for a view of the exitedProject, and return its center"

	world submorphsDo: [:v |
			(v isSystemWindow and: [v model == exitedProject])
				ifTrue: [^ v center]].
	^ super viewLocFor: exitedProject
]

{ #category : #enter }
MorphicProject >> wakeUpTopWindow [
	"Image has been restarted, and the startUp list has been processed. Perform
	any additional actions needed to restart the user interface."

	SystemWindow wakeUpTopWindowUponStartup.
	Preferences mouseOverForKeyboardFocus ifTrue: 
		[ "Allow global command keys to work upon re-entry without having to cause a focus change first."
		self currentHand releaseKeyboardFocus ]
]
