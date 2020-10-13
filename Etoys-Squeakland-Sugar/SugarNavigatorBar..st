Class {
	#name : #SugarNavigatorBar,
	#superclass : #ProjectNavigationMorph,
	#instVars : [
		'sugarLib',
		'highLightColor',
		'paintButton',
		'undoButton',
		'shareButton',
		'stopButton',
		'supplies',
		'listener',
		'suppliesFlap',
		'projectNameField',
		'isSugar'
	],
	#classVars : [
		'ShowHideButton',
		'ShowSugarNavigator'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #utilitity }
SugarNavigatorBar class >> configureCurrentForSqueakland [

	SugarNavigatorBar current ifNotNil: [:bar | bar configureForSqueakland].

]

{ #category : #'instance creation' }
SugarNavigatorBar class >> current [

	| flap |
	flap := Flaps globalFlapTabWithID: 'Sugar Navigator Flap' translated.
	flap ifNil: [^ nil].
	(flap referent isMemberOf: SugarNavigatorBar) ifFalse: [^ nil].
	^ flap referent.

]

{ #category : #utilitity }
SugarNavigatorBar class >> findAnythingMorph [

	^ FileList2 morphicViewProjectLoader2InWorld: Project current world
		title: 'Find...' translated
		reallyLoad: true
		dirFilterType: #initialDirectoryList
		isGeneral: true.
]

{ #category : #'class initialization' }
SugarNavigatorBar class >> initialize [
	"self initialize"
	Preferences addPreference: #showAdvancedNavigatorButtons 
		categories: #(morphic)
		default: false
		balloonHelp: 'If true, an advanced version of the navigator is shown, otherwise a simplified version.'
		projectLocal: false
		changeInformee: self
		changeSelector: #rebuildButtons.

]

{ #category : #'instance creation' }
SugarNavigatorBar class >> newWith: aSugarLibObject [

	^ self new sugarLib: aSugarLibObject.

]

{ #category : #utilitity }
SugarNavigatorBar class >> putUpInitialBalloonHelp [

	| flap |
	flap := Flaps globalFlapTabWithID: 'Sugar Navigator Flap' translated.
	flap ifNil: [^ self].
	(flap referent isMemberOf: SugarNavigatorBar) ifFalse: [^ self].
	flap referent putUpInitialBalloonHelp

]

{ #category : #utilitity }
SugarNavigatorBar class >> rebuildButtons [
	self current ifNotNil: [:bar | bar rebuildButtons]
]

{ #category : #'instance creation' }
SugarNavigatorBar class >> refreshButRetainOldContents [
"
	SugarNavigatorBar refreshButRetainOldContents
"
	| supplies objects nav nonStandard color highlight height |
	nav := Flaps globalFlapTabWithID: 'Sugar Navigator Flap' translated.
	nav ifNotNil: [
		nonStandard := nav nonStandardMorphs.
		color := nav referent color.
		highlight := nav referent highlightColor.
		height := nav referent height.
	] ifNil: [
		nonStandard := #().
		color := nil.
		highlight := nil.
		height := nil].
	supplies := Flaps globalFlapTabWithID: 'Supplies' translated.
	supplies ifNotNil: [supplies := supplies referent].
	(supplies isMemberOf: PartsBin) ifTrue: [objects := supplies savedUserDefinedObjects] ifFalse: [objects := nil].

	Flaps disableGlobalFlaps: false.
	Flaps enableEToyFlaps.
	nav := Flaps globalFlapTabWithID: 'Sugar Navigator Flap' translated.
	nonStandard ifNotNil: [
		nonStandard do: [:p |
			nav addMorphFront: p first.
			p first position: (nav position + p second)
		]
	].
	(color notNil and: [highlight notNil and: [height notNil]]) ifTrue: [nav referent color: color highLightColor: highlight. nav naviHeight: height].
	objects ifNotNil: [
		supplies := Flaps globalFlapTabWithID: 'Supplies' translated.
		supplies ifNotNil: [supplies := supplies referent].
		(supplies isMemberOf: PartsBin) ifTrue: [supplies restoreUserDefinedObjectsFrom: objects].
	]
]

{ #category : #preferences }
SugarNavigatorBar class >> showHideButton [
	
	<preference: 'Show a button to hide the Sugar navigator bar inside the bar'
		category: 'docking bars'
		description: 'Whether the hide bar button is shown in the Sugar navigator bar'
		type: #Boolean>
	^ ShowHideButton ifNil: [ShowHideButton := false]
]

{ #category : #preferences }
SugarNavigatorBar class >> showHideButton: aBoolean [
	
	ShowHideButton := aBoolean.
	self showSugarNavigator: self showSugarNavigator. "re-init"
]

{ #category : #preferences }
SugarNavigatorBar class >> showSugarNavigator [
	
	<preference: 'Show Sugar navigator bar'
		category: 'docking bars'
		description: 'Whether the EToys Sugar navigator bar is shown. Disables the world main docking bar.'
		type: #Boolean>
	^ ShowSugarNavigator ifNil: [ShowSugarNavigator := false]
]

{ #category : #preferences }
SugarNavigatorBar class >> showSugarNavigator: aBoolean [
	
	ShowSugarNavigator := aBoolean.
	Smalltalk at: #TheWorldMainDockingBar ifPresent: [:class | class showWorldMainDockingBar: aBoolean not].
	Project current updateLocaleDependents.
]

{ #category : #utilitity }
SugarNavigatorBar class >> supplementaryPartsDescriptions [
	^ {DescriptionForPartsBin
		formalName: 'File Dialog' translatedNoop
		categoryList: #('Scripting')
		documentation: 'The list of files and directories' translatedNoop
		globalReceiverSymbol: #SugarNavigatorBar
		nativitySelector: #findAnythingMorph
	}
]

{ #category : #preferences }
SugarNavigatorBar class >> themeProperties [

	^ {}
]

{ #category : #initialization }
SugarNavigatorBar >> addButtons [

	super addButtons.
	self wantsHaloForSubmorphs: Preferences eToyFriendly not.

]

{ #category : #updating }
SugarNavigatorBar >> applyUserInterfaceTheme [

	self class showSugarNavigator: self class showSugarNavigator.
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> availableDisplayModes [
	"Answer an array of available screen modes.  The full-screen item is not included now."

	| ret actual desired |
	ret := OrderedCollection new: 3.
	ret add: #physical.
	actual := DisplayScreen actualScreenSize.
	desired := OLPCVirtualScreen virtualScreenExtent.
	actual = desired ifTrue: [^ ret].
	ret add: #scaledVirtual.
	(actual x > desired x and: [actual y > desired y]) ifTrue:
		[ret add: #centeredVirtual].

	^ ret asArray
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> balloonTextForMode: aMode [
	"Answer the (English) balloon text associated with a display-mode choice."

	aMode = #physical ifTrue:
		[^ 'Use the normal Squeak display, without applying any special scaling.' translated].
	aMode = #scaledVirtual ifTrue:
		[^ 'Scale the Squeak display so that it appears to have the same resolution as an OLPC display.  If you resize the Squeak window to approximate the physical dimensions of the real OLPC display, this will result in an appearance that closely resembles the appearance on an OLPC screen.' translated].
	aMode = #centeredVirtual ifTrue:
		[^ 'Present a virtual display that approximates the actual OLPC display in resolution, centered within the actual Squeak display window.' translated].
	^ nil
]

{ #category : #'help flap' }
SugarNavigatorBar >> buildAndOpenHelpFlap [
	"Called only when flaps are being created afresh."

	| aFlapTab outer leftStrip rightStrip aGuide |
	aFlapTab := FlapTab new.
	aFlapTab assureExtension visible: false.
	aFlapTab setProperty: #rigidThickness toValue: true.

	outer := AlignmentMorph newRow.
	outer assureExtension visible: false.
	outer clipSubmorphs: true.
	outer beTransparent.
	outer vResizing: #spaceFill; hResizing: #spaceFill.
	outer layoutInset: 0; cellInset: 0; borderWidth: 0.
	outer setProperty: #wantsHaloFromClick toValue: false.

	leftStrip := Morph new beTransparent.  "This provides space for tabs to be seen."
	leftStrip layoutInset: 0; cellInset: 0; borderWidth: 0.
	leftStrip width:  20.
	leftStrip hResizing: #rigid; vResizing: #spaceFill.
	outer addMorphBack: leftStrip.   

	rightStrip := AlignmentMorph newColumn.
	rightStrip color: (Color green veryMuchLighter alpha:  0.2).
	rightStrip layoutInset: 0; cellInset: 0; borderWidth: 0.
	rightStrip setProperty: #wantsHaloFromClick toValue: false.
	outer addMorphBack: rightStrip.
	outer clipSubmorphs: true.
	
	aGuide := QuickGuideMorph new.
	aGuide initializeIndexPage.
"	aGuide order: QuickGuideMorph defaultOrder.	"
	QuickGuideMorph loadIndexAndPeekOnDisk.
	aGuide loadPages.
	rightStrip addMorphBack: aGuide.
	aGuide beSticky.

	aFlapTab referent ifNotNil: [aFlapTab referent delete].
	aFlapTab referent: outer.
	aFlapTab setName: 'Help' translated edge: #left color: (Color r: 0.677 g: 0.935 b: 0.484).
	Project current world addMorphFront: aFlapTab.
	aFlapTab adaptToWorld: Project current world.
	aFlapTab computeEdgeFraction.

	aFlapTab position: outer left @ outer top.
	outer extent: 462 @ Project current world height.

	outer beFlap: true.
	outer beTransparent.

	aFlapTab referent hide.
	aFlapTab referentMargin: 0@self height.
	aFlapTab openFully.

	outer beSticky.
	leftStrip beSticky.
	rightStrip beSticky.

	aFlapTab applyThickness: 462.
	aFlapTab fitOnScreen.
	aFlapTab referent show.
	aFlapTab show.
	aFlapTab makeFlapCompact: true.
	aFlapTab setToPopOutOnDragOver:  false.
	Flaps addGlobalFlap: aFlapTab.
	Project current world addGlobalFlaps.
	ScriptingSystem cleanUpFlapTabsOnLeft
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonChoose [
	"Answer a button for choosing objects from the Journal"

	^ self makeButton: 'FIND' translated balloonText: 'Find an entry in the Journal.  Hold mouse button down for further options.' translated for: #chooseObject

]

{ #category : #accessing }
SugarNavigatorBar >> buttonHeight [

	^ paintButton ifNotNil: [paintButton height] ifNil: [75].

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonHideNavBar [
	"Build and return a fresh HideNavBarButton"

	^ self makeButton: 'hideNavBar' balloonText: 'hide the tool bar' translated for: #hideNavBar

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonKeep [
	"Answer a button for saving the project in the Journal"
	^ self makeButton: 'PUBLISH IT!' translated balloonText:  'Keep a copy of the current project in the Journal. Hold mouse button down for further options.' translated for: #keepProject
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonLanguage [
	"Build and return a fresh Undo button for me."

	^ self makeButton: 'language' balloonText: 'Click here to choose your language.' translated for: #chooseLanguage

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonLoadSexp [
	"Answer a button for finding/loading groups of morphs"

	^ self makeButton: 'open' balloonText: 'Click here to load a few morphs from another project.' translated for: #loadASexp

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonPaint [
	"Build and return a fresh Undo button for me."

	^paintButton := self makeButton: 'paint' balloonText: 'Make a painting' translated for: #doNewPainting

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonSaveSexp [
	"Answer a button for finding/loading groups of morphs"

	^ self makeButton: 'save' balloonText: 'Click here to save the Etoys in this project into a file.' translated for: #publishSexp

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonShare [
	"Answer an new instance of a 'Share' button."

	^ shareButton := self makeButton: 'Share' 
		balloonText: 'Enable sharing. When another user joins, you can exchange objects.' translated 
		for: #shareMenu
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonShowNavBar [
	"Build and return a fresh button for showing the nav-bar."

	^ self makeButton: 'showNavBar' balloonText: 'show the tool bar' translated for: #showNavBar

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonStop [

	^self makeButton: 'stop' balloonText: 'Quit Etoys (with saving)' translated for: #stopSqueak

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonUndo [
	"Build and return a fresh Undo button for me."

	undoButton := self makeButton: 'undo' balloonText: 'Undo the last change' translated for: #undoOrRedoLastCommand.
	^ undoButton.

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> buttonZoom [
	"Build and return a fresh Zoom button for me."

	^self makeButton: 'zoom' balloonText: 'Click here to toggle using the full screen.' translated for: #zoom

]

{ #category : #'visual properties' }
SugarNavigatorBar >> canApplyUserInterfaceTheme [

	^ true
]

{ #category : #'button actions' }
SugarNavigatorBar >> changeDisplayModeTo: aSymbol [
	"If the user's display mode is not already the one indicated by the input parameter, switch to that mode."

	aSymbol == #physical ifTrue: [
		OLPCVirtualScreen virtualScreenExtent: nil.
		^ OLPCVirtualScreen unInstall.
	].
	aSymbol == #scaledVirtual ifTrue: [
		^ OLPCVirtualScreen install.
	].
	aSymbol == #centeredVirtual ifTrue: [
		OLPCVirtualScreen install.
		^ Display zoomOut: true.
	].
]

{ #category : #'button actions' }
SugarNavigatorBar >> changeVirtualScreenMode [

	Display isVirtualScreen ifTrue: [
		(Display canZoomOut) ifTrue: [
			Display zoomOut not ifTrue: [Display zoomOut: true. ^ self].
		].
		Display unInstall.
		^ self.
	].
	OLPCVirtualScreen install.

]

{ #category : #'morphic interaction' }
SugarNavigatorBar >> checkForResize [
	"Check to see if the receiver needs to be reconfigured because of a world resize."

	| shouldResize h worldBounds inset |
	(owner isKindOf: SugarNavTab) ifFalse: [^ self].  "e.g. being held by hand."
	owner edgeToAdhereTo = #topRight ifTrue: [^ owner occupyTopRightCorner]. 

	shouldResize := false.
	worldBounds := self world bounds.
	(self layoutInset ~= (inset := SugarLauncher isRunningInSugar ifTrue: [75@0] ifFalse: [0@0]))
		ifTrue: [self layoutInset: inset].
	worldBounds width ~= self width ifTrue: [shouldResize := true].
	Preferences useArtificialSweetenerBar ifTrue: [
		h := submorphs first submorphs first height.
		(worldBounds extent x >= 1024 and: [worldBounds extent y >= 768]) ifTrue: [
			h = 40 ifTrue: [self naviHeight: 75. shouldResize := true]]
		ifFalse: [h = 75 ifTrue: [self naviHeight: 40. shouldResize := true]]].
	(h := self submorphBounds height) ~= self height ifTrue: [shouldResize := true].
	(owner notNil and: [owner isFlapTab]) ifTrue: [
		owner edgeToAdhereTo == #top ifTrue: [
			self topLeft ~= worldBounds topLeft ifTrue: [shouldResize := true].
		]. 
		owner edgeToAdhereTo == #bottom ifTrue: [
			self bottomLeft ~= worldBounds bottomLeft ifTrue: [shouldResize := true].
		]. 
		shouldResize ifTrue: [
			owner edgeToAdhereTo == #top ifTrue: [
				self bounds: (0@0 corner: (worldBounds width@h)).
			].
			owner edgeToAdhereTo == #bottom ifTrue: [
				self bounds: (0@(worldBounds height - h) corner: (worldBounds bottomRight)).
			].
			self resizeProjectNameField.
			owner layoutChanged.
		].
	].
]

{ #category : #initialization }
SugarNavigatorBar >> checkSugarButtons [
	| wasSugar |
	(owner hasProperty: #collapsedMode) ifTrue: [^self].
	wasSugar := paintButton owner submorphs anySatisfy:
		[:e | e isButton and: [e actionSelector = #chooseObject]].
	isSugar := SugarLauncher current isRunningInSugar.
	wasSugar = isSugar ifFalse: [self rebuildButtons].

]

{ #category : #'button actions' }
SugarNavigatorBar >> chooseObject [
	SugarLauncher current chooseObject
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> chooseScreenSetting [
	"Put up a menu allowing the user to choose between virtual-olpc-display mode and normal-display mode."

	| aMenu availableModes |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'display mode' translated.
	Preferences noviceMode
		ifFalse: [aMenu addStayUpItem].

	availableModes := self availableDisplayModes.

	availableModes do:
		[:mode |
			aMenu addUpdating: #stringForDisplayModeIs: target: self selector: #toggleScreenSetting: argumentList: {mode}.
			(self balloonTextForMode: mode) ifNotNil:
				[:help |
					aMenu balloonTextForLastItem: help translated]].
	aMenu addLine.
	aMenu addUpdating: #stringForFullScreenToggle  target: self action: #toggleFullScreen.
	aMenu popUpInWorld

"(Flaps globalFlapTabWithID: 'Sugar Navigator Flap' translated) referent chooseScreenSetting"
]

{ #category : #accessing }
SugarNavigatorBar >> color: aColor [

	| oldHeight |
	color = aColor ifTrue: [^ self].
	oldHeight := self buttonHeight.
	super color: aColor.
	submorphs ifNotEmpty: [self rebuildButtons].
	self buttonHeight ~= oldHeight ifTrue: [
		self naviHeight: oldHeight.
	].

]

{ #category : #accessing }
SugarNavigatorBar >> color: baseColor highLightColor: hColor [

	| oldHeight |
	oldHeight := self buttonHeight.
	(color = baseColor and: [highLightColor = hColor]) ifTrue: [^ self].
	super color: baseColor.
	highLightColor := hColor.
	submorphs ifNotEmpty: [self rebuildButtons].
	self buttonHeight ~= oldHeight ifTrue: [
		self naviHeight: oldHeight.
	].

]

{ #category : #initialization }
SugarNavigatorBar >> configureForSqueakland [
	"Formerly -- have a narrow, green bar.  Now:  just use the standard."

	"self naviHeight: 40.
	self color: Color green muchDarker highLightColor: Color green darker."
]

{ #category : #'button actions' }
SugarNavigatorBar >> currentDisplayMode [

	Display isVirtualScreen ifTrue: [
		(Display canZoomOut) ifTrue: [
			Display zoomOut ifTrue: [^ #centeredVirtual]].
		^ #scaledVirtual
	].
	^ #physical

]

{ #category : #'the actions' }
SugarNavigatorBar >> doFindButtonMenuEvent: evt [

	| selection |
	selection := UIManager default chooseFrom:{
		'find a project' translated.
		'find a project (more places)' translated.
		'find any file' translated.
		'find a file with some players and scripts only' translated.
		'search the SuperSwiki' translated.
	} values: { 
		[self findAProjectSimple].
		[self findAProject].
		[self findAnything].
		[self loadASexp].
		[self findSomethingOnSuperSwiki].
	} title: 'Find options' translated.
	selection ifNil: [^self].
	selection value.
]

{ #category : #'button actions' }
SugarNavigatorBar >> doNewPainting [
	
	| w |

	w := self world.
	w assureNotPaintingElse: [^ self].
	w makeNewDrawing: (self primaryHand lastEvent copy setPosition: w center)

]

{ #category : #'the actions' }
SugarNavigatorBar >> doPublishButtonMenuEvent: evt [

	| selection |
	selection := UIManager default chooseFrom: {
		'Publish' translated.
		'Publish As...' translated.
		'Publish to Different Server' translated.
		'Publish only the Players and their Scripts' translated.
		 'edit project info' translated.
	} values: {
		[self publishProject].
		[self publishProjectAs].
		[self publishDifferent].
		[self publishSexp].
		[self editProjectInfo].
	} title:  'Publish options' translated.
	selection ifNil: [^self].
	selection value.
]

{ #category : #'button actions' }
SugarNavigatorBar >> doZoomButtonMenuEvent: evt [

	self chooseScreenSetting


]

{ #category : #sharing }
SugarNavigatorBar >> getBadge [

	SugarBuddy fromMesh
]

{ #category : #'the actions' }
SugarNavigatorBar >> gotoAnother [

	EToyProjectHistoryMorph new
		position: self currentHand position;
		openInWorld

]

{ #category : #'event handling' }
SugarNavigatorBar >> handlesMouseOver: evt [

	^ false.

]

{ #category : #'button actions' }
SugarNavigatorBar >> hideNavBar [
	"Reconfigure the nav-bar such that it only shows the 'show nav bar' icon at right edge"

	owner hideNavBar
]

{ #category : #accessing }
SugarNavigatorBar >> highLightColor [

	^ highLightColor.


]

{ #category : #accessing }
SugarNavigatorBar >> highLightColor: aColor [

	| oldHeight |
	highLightColor = aColor ifTrue: [^ self].
	highLightColor := aColor.
	oldHeight := self buttonHeight.
	submorphs ifNotEmpty: [self rebuildButtons].
	self buttonHeight ~= oldHeight ifTrue: [
		self naviHeight: oldHeight.
	].

]

{ #category : #initialization }
SugarNavigatorBar >> inAColumn: aCollectionOfMorphs [

	^ aCollectionOfMorphs at: 1.

]

{ #category : #initialization }
SugarNavigatorBar >> inARow: aCollectionOfMorphs [
	"Answer a row morph with the given collection as its submorphs.  Interpret the symbol #spacer in the incoming list as a request for a variable transparent spacer."

	^ (Morph inARow: aCollectionOfMorphs) setProperty: #wantsHaloFromClick toValue: false.

]

{ #category : #initialization }
SugarNavigatorBar >> initialize [

	super initialize.
	self layoutInset: 0@0;
	  hResizing: #rigid;
	  vResizing: #rigid;
	  cellPositioning: #topLeft.
	self cornerStyle: #square.
	self resistsRemoval: true.
	self beSticky.
	self makeGray.

]

{ #category : #accessing }
SugarNavigatorBar >> isSugar [
	^isSugar == true
]

{ #category : #sharing }
SugarNavigatorBar >> joinSharedActivity [
	self startP2P.
	self sharingChanged.
]

{ #category : #'the actions' }
SugarNavigatorBar >> keepProject [
	Preferences sugarAutoSave
		ifTrue: [SugarLauncher current save]
		ifFalse: [self publishProject]

]

{ #category : #'button actions' }
SugarNavigatorBar >> loadASexp [
	| fileName siss sexp |
	fileName := FileChooserDialog openOnSuffixList: {'sexp'} label: nil.
	fileName ifNil: [^ self].

	FileStream
		oldFileNamed: fileName
		do: [:file | 
			file binary.
			siss := file contents.
			sexp := [(DataStream on: (file reset; yourself)) next]
						on: Error
						do: [:e | (Smalltalk at: #MSExpParser)
								parse: siss
								with: #ksexp]].
	sexp sissReadObjectsAsEtoysProject submorphs do: #openInWorld
]

{ #category : #'the actions' }
SugarNavigatorBar >> makeBadgeLabelIn: aPoint [

	| aMorph icon string |
	aMorph := Morph new.
	aMorph extent: aPoint.
	aMorph color: Color transparent.
	
	icon := SketchMorph new form: (SugarLibrary default imageFor: 'miniShare' color: self color).
	string := StringMorph new label: 'Make a Badge' translated font: Preferences standardEToysFont.
	string color: Color white.

	icon center: (icon width // 2)@(aPoint y // 2).
	string center: (icon width // 2)@(aPoint y // 2).
	string left: icon right + 1.
	aMorph addMorph: icon.
	aMorph addMorph: string.
	^ aMorph.

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> makeButton: aString balloonText: anotherString for: aSymbol [
	"Make a button indexed by the string, with the given balloon text; the third parameter indicates the action selector to be associated with the button."

	^ self sugarLib makeButton: aString balloonText: anotherString for: aSymbol target: self baseColor: color highLightColor: highLightColor

]

{ #category : #accessing }
SugarNavigatorBar >> makeGray [

	self color: (Color r: 0.258 g: 0.258 b: 0.258) highLightColor: Color black.

]

{ #category : #accessing }
SugarNavigatorBar >> makeGreen [

	self color: (Color r: 0.258 g: 0.613 b: 0.161) highLightColor: (Color r: 0.157 g: 0.372 b: 0.098).

]

{ #category : #'the actions' }
SugarNavigatorBar >> makeMyNeighborhoodLabelIn: aPoint [

	| aMorph icon string |
	aMorph := Morph new.
	aMorph extent: aPoint.
	aMorph color: Color transparent.
	
	icon := SketchMorph new form: (SugarLibrary default imageFor: 'miniShare' color: self color).
	string := StringMorph new label: 'My Neighborhood' translated font: Preferences standardEToysFont.
	string color: Color white.

	icon center: (icon width // 2)@(aPoint y // 2).
	string center: (icon width // 2)@(aPoint y // 2).
	string left: icon right + 1.
	aMorph addMorph: icon.
	aMorph addMorph: string.
	^ aMorph.

]

{ #category : #'the actions' }
SugarNavigatorBar >> makePrivateLabelIn: aPoint [

	| aMorph icon string |
	aMorph := Morph new.
	aMorph extent: aPoint.
	aMorph color: Color transparent.
	
	icon := SketchMorph new form: (SugarLibrary default imageFor: 'miniPrivate' color: self color).
	string := StringMorph new label: 'Private' translated font: Preferences standardEToysFont.
	string color: Color white.

	icon center: (icon width // 2)@(aPoint y // 2).
	string center: (icon width // 2)@(aPoint y // 2).
	string left: icon right + 1.
	aMorph addMorph: icon.
	aMorph addMorph: string.
	^ aMorph.

]

{ #category : #'the actions' }
SugarNavigatorBar >> makeProjectNameLabel [

	| t |
	projectNameField := SugarRoundedField new.
	t := UpdatingStringMorph new.
	t setProperty: #okToTextEdit toValue: true.
	t putSelector: #projectNameChanged:.
	t getSelector: #projectName.
	projectNameField backgroundColor: self color.
	t target: self.
	t useStringFormat.
	t beSticky.
	t label: Project current name font: (StrikeFont familyName: 'BitstreamVeraSans' size: 24).
	t color: Color black.
	t width: projectNameField width - 10.
	projectNameField label: t.
	projectNameField setBalloonText: self projectNameFieldBalloonHelp.
	projectNameField on: #mouseDown send: #mouseDown: to: t.
	projectNameField on: #mouseUp send: #mouseUp: to: t.
	self resizeProjectNameField.
	^projectNameField.
]

{ #category : #initialization }
SugarNavigatorBar >> makeTheButtons [

	^ (Smalltalk globals at: #SExpElement
		ifPresent: [:c | {self buttonHelp}]
		ifAbsent: [{}]),
	
	{
		self buttonUndo.
		self makeProjectNameLabel.
	},
	(
		Preferences showAdvancedNavigatorButtons
			ifTrue: [{self buttonNewProject. self buttonGoTo}]
			ifFalse: [#()]
	),
	{
		self buttonPrev.
		self buttonNext.
		#spacer.
		self buttonPaint.
		self buttonSupplies.
		self buttonLanguage.
	}, 
	(SugarLauncher isRunningInSugar
		ifTrue: [{
			self buttonShare.
			#spacer.
			self buttonChoose.
			self buttonKeep.
			stopButton := SugarLauncher current willSaveOnQuit
				ifTrue: [self buttonStop]
				ifFalse: [self buttonQuit]	}]
		ifFalse: [
			{
				self buttonFind.
				self buttonPublish.
				#spacer.
				self buttonZoom.
				"self buttonStop."
				self buttonQuit.
			}
	]),
	(SugarNavigatorBar showHideButton
		ifTrue: [{self buttonHideNavBar}]
		ifFalse: [#()])
]

{ #category : #'event handling' }
SugarNavigatorBar >> morphicLayerNumber [

	^ 100.

]

{ #category : #'morphic interaction' }
SugarNavigatorBar >> naviHeight: anInteger [

	anInteger > self height ifTrue: [^ self naviHeightWithFullUpdate: anInteger].
	anInteger < 2 ifTrue: [^ self].
	submorphs isEmpty ifTrue: [^ super extent: self width@anInteger].
	self resizeButtonsAndTabTo: anInteger.

]

{ #category : #'morphic interaction' }
SugarNavigatorBar >> naviHeightWithFullUpdate: anInteger [

	submorphs isEmpty ifTrue: [^ super extent: self width@anInteger].
	self rebuildButtons.
	self resizeButtonsAndTabTo: anInteger.

]

{ #category : #'the actions' }
SugarNavigatorBar >> newProject [
	"Not creating a view. mt's refactoring of projects breaks the assumption that we can always delete a project and all it's children through a view anyway"
	MorphicProject new enter
]

{ #category : #accessing }
SugarNavigatorBar >> oldHeight [

	^ paintButton ifNotNil: [paintButton height] ifNil: [75].

]

{ #category : #initialization }
SugarNavigatorBar >> paintButtonInitialExplanation [

	^ 'To start,
click here
to create
a new
painting.' translated

]

{ #category : #'the actions' }
SugarNavigatorBar >> previousProject [
	Preferences eToyFriendly ifTrue: [
		| prev |
		prev := Project current previousProject.
		(prev isNil or: [prev isTopProject]) ifTrue: [
			Project home ifNotNil: [:p | Project current setParent: p]]].
	super previousProject
]

{ #category : #'the actions' }
SugarNavigatorBar >> projectName [

	^ Project current name

]

{ #category : #'the actions' }
SugarNavigatorBar >> projectNameChanged: aString [

	Project current renameTo: aString.

]

{ #category : #'the actions' }
SugarNavigatorBar >> projectNameFieldBalloonHelp [

	^ 'This is the name of current project.
You can edit it as well.' translated.

]

{ #category : #'button actions' }
SugarNavigatorBar >> publishSexp [

	| morphs siss tempPasteUp directory fileModel window prevSubmorphs |
	self world paintBoxOrNil ifNotNil: [
		self inform: 'You seem to be painting a sketch. You should finish or cancel your painting first' translated.
		^ self].
	tempPasteUp := PasteUpMorph new
						bounds: (self world bounds);
						openInWorld;
						yourself.
	morphs := self world submorphs
			select: [:m |
				(m player notNil and: [m player externalName ~= 'dot'])
					or: [m isKindOf: ScriptEditorMorph]].
	prevSubmorphs := self world submorphs.
	tempPasteUp addAllMorphs: morphs.
	siss := tempPasteUp sissScanObjectsAsEtoysProject.
	tempPasteUp delete.
	self world addAllMorphs: prevSubmorphs.

	window := FileList2 morphicViewProjectSaverFor: Project current.
	(window findDeepSubmorphThat: [:m |
		m eventHandler notNil and: [m eventHandler mouseUpSelector = #saveLocalOnlyHit]] ifAbsent: [])
			ifNotNil: [:m | m delete].
	fileModel := window valueOfProperty: #FileList.
	self world addMorphInLayer: window.
	self world startSteppingSubmorphsOf: window.
	FileList2 modalLoopOn: window.
	directory := fileModel getSelectedDirectory withoutListWrapper.
	directory ifNil: [^ self].
	directory forceNewFileNamed: (Project current name, '.sexp') do: [:f |
		f binary;
		  nextPutAll: ((DataStream on: (WriteStream on: (ByteArray new: siss elements size * 50)))
							nextPut: siss;
							contents)].

]

{ #category : #initialization }
SugarNavigatorBar >> putUpInitialBalloonHelp [
"
	SugarNavigatorBar putUpInitialBalloonHelp
"

	| suppliesButton b1 b2 p b |
	suppliesButton := paintButton owner submorphs detect: [:e | e isButton and: [e actionSelector = #toggleSupplies]].

	b1 := BalloonMorph string: self paintButtonInitialExplanation for: paintButton corner: #topRight force: false.
	b2 := BalloonMorph string: self suppliesButtonInitialExplanation for: suppliesButton corner: #topLeft force: true.

	p := PasteUpMorph new.
	p clipSubmorphs: false.
	p color: Color transparent.
	p borderWidth: 0.
	p addMorph: b1.
	p addMorph: b2.
	b := BalloonMorph string: p for: self world corner: #bottomLeft.
	b color: Color transparent.
	b borderWidth: 0.
	[(Delay forSeconds: 1) wait. b popUp] fork.
]

{ #category : #initialization }
SugarNavigatorBar >> putUpInitialBalloonHelpFor: quads [
	"Given a list of quads of the form <selector> <help-msg> <corner> <force-boolean> (see senders for examples), put up initial balloon help for them."
"
	SugarNavigatorBar someInstance putUpInitialBalloonHelpFor: #((doNewPainting 'make a new painting' topRight false) (toggleSupplies 'open the supplies bin' topLeft true))
	SugarNavigatorBar someInstance putUpInitialBalloonHelpFor: #((showNavBar 'show the tool bar' bottomLeft false) (hideNavBar 'hide the tool bar' bottomLeft false))

"
	|  b1 p b |

	p := PasteUpMorph new.
	p clipSubmorphs: false.
	p color: Color transparent.
	p borderWidth: 0.

	quads do: [:aQuad |
		(submorphs first submorphs detect: [:e | e isButton and: [e actionSelector = aQuad first]] ifNone: [nil]) ifNotNil:
			[:aButton |
				b1 := BalloonMorph string: aQuad second for: aButton corner: aQuad third force: aQuad fourth.
				p addMorph: b1]].

	b := BalloonMorph string: p for: self world corner: #bottomLeft.
	b color: Color transparent.
	b borderWidth: 0.
	[(Delay forSeconds: 1) wait. b popUp] fork.
]

{ #category : #'button actions' }
SugarNavigatorBar >> quitSqueak [
	^SugarLauncher isRunningInSugar
		ifTrue: [SugarLauncher current quit]
		ifFalse: [
			Preferences eToyFriendly
				ifTrue: [super quitSqueak]
				ifFalse: [Smalltalk
								snapshot: (
									UserDialogBoxMorph 
										confirm: 'Save changes before quitting?' translated 
										orCancel: [ ^self ]
										at: self world center)
							andQuit: true]].
]

{ #category : #initialization }
SugarNavigatorBar >> rebuildButtons [
	(owner notNil and: [owner hasProperty: #collapsedMode]) 
		ifTrue:[^self].
	submorphs do: [:e | e delete].
			self addButtons 
]

{ #category : #'morphic interaction' }
SugarNavigatorBar >> resizeButtonsAndTabTo: newDim [
	"Resize the receiver's buttons and containing tab to conform to the given dimension."

	| frame |
	submorphs ifNotEmpty:
		[frame := submorphs first.
		frame submorphs do: [:e |
			e naviHeight: newDim].
		frame height: newDim.
		supplies ifNotNil:
			[supplies naviHeight: newDim]]
]

{ #category : #'the actions' }
SugarNavigatorBar >> resizeProjectNameField [

	"The height should be 45 according to the Sugar guilde line, but an odd number makes the circle distorted.  To be general, it uses 60% of the height of bar."
	| h |
	h := (self height * 0.6) roundTo: 2.
	projectNameField ifNotNil: [
		projectNameField extent: (Display width >= 1200 ifTrue: [220] ifFalse: [130])@h.
		projectNameField resizeLabel].
]

{ #category : #'event handling' }
SugarNavigatorBar >> setEdge: aSymbol [
	"Establish the given edge to which to cling."

	(Flaps globalFlapTab: 'Supplies' translated) ifNotNil:
		[:s | s setEdge: aSymbol]
]

{ #category : #initialization }
SugarNavigatorBar >> setSuppliesBehind [

	supplies ifNotNil: [supplies referent setProperty: #wantsToBeTopmost toValue: false].

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> setupSuppliesFlap [

	| i f |
	sugarLib ifNil: [^ self].
	supplies := Flaps globalFlapTabWithID: 'Supplies' translated.
	supplies ifNotNil: [
		i := sugarLib imageFor: 'supplies' color: color.
		f := Form extent: 75@75 depth: 16.
		f fillColor: color.
		i displayOn: f at: (f extent - i extent)//2 rule: Form over.
		supplies sugarNavTab: self icon: f.
	].

]

{ #category : #'the actions' }
SugarNavigatorBar >> shareMenu [

	| menu item ext |
	menu := MenuMorph new.
	ext := 200@50.
	#((stopSharing makePrivateLabelIn:) (startSharing makeMyNeighborhoodLabelIn:) "(shareThisWorld makeBadgeLabelIn:)") do: [:pair |
		
		item := MenuItemMorph new
			contents: '';
			target: self;
			selector: pair first;
			arguments: #().
		item color: Color black.
		item addMorph: (self perform: pair second with: ext).
		item setProperty: #minHeight toValue: ext y.
		item fitContents.
		item extent: ext.
		item setProperty: #selectionFillStyle toValue: (Color gray alpha: 0.5).
		menu addMorphBack: item.
	].
	menu color: Color black.
	menu borderColor: Color white.
	^ menu invokeModalAt: shareButton position + (10@20) in: Project current world allowKeyboard: false.
]

{ #category : #'button actions' }
SugarNavigatorBar >> shareThisWorld [

	SugarLauncher current isShared ifFalse: [self startSharing].
	self getBadge.

]

{ #category : #sharing }
SugarNavigatorBar >> sharingChanged [
	| state |
	state := SugarLauncher current isShared
		ifTrue: ['share']
		ifFalse: ['private'].
	SugarLibrary default recolorButton: shareButton for: state  baseColor: self color highLightColor: self highlightColor.

]

{ #category : #'event handling' }
SugarNavigatorBar >> showNavBar [
	"Show the full sugar nav bar."

	owner showNavBar
]

{ #category : #'morphic interaction' }
SugarNavigatorBar >> showOnlyShowNavBarButton [
	"Reconfigure the receiver such that it only shows the show-nav-bar button"

	self removeAllMorphs.
	self addMorph: (self inARow:  {self buttonShowNavBar}).
	self hResizing: #shrinkWrap.
	Preferences useArtificialSweetenerBar ifTrue: [self configureForSqueakland].
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> spacer: w [

	^ Morph new extent: w@0; setProperty: #wantsHaloFromClick toValue: false; yourself


]

{ #category : #sharing }
SugarNavigatorBar >> startNebraska [

	| nebraska |
	Project current world remoteServer: nil.
	Project current world submorphs do: [:e | (e isMemberOf: NebraskaServerMorph) ifTrue: [e delete]].
	nebraska := NebraskaServerMorph serveWorld.
	SugarLauncher current
		offerStreamTube: 'sqk-nebraska'
		inBackgroundOnPort: [nebraska listeningPort].

]

{ #category : #sharing }
SugarNavigatorBar >> startP2P [
	listener ifNotNil: [listener stopListening].
	listener ifNil: [listener := SugarListenerMorph new].
	listener position: -200@ -200.
	Project current world addMorphBack: listener.
	listener startListening.
	SugarLauncher current
		offerStreamTube: 'sqk-etoy-p2p'
		inBackgroundOnPort: [listener listeningPort].
]

{ #category : #sharing }
SugarNavigatorBar >> startSharing [
	SugarLauncher current sharePublicly: true.
	self joinSharedActivity.
]

{ #category : #initialization }
SugarNavigatorBar >> startUp [
	self checkSugarButtons

]

{ #category : #'morphic interaction' }
SugarNavigatorBar >> step [
	self checkSugarButtons.
	self checkForResize.
	self undoButtonAppearance.
	self stopButtonAppearance.
]

{ #category : #'event handling' }
SugarNavigatorBar >> stopButtonAppearance [
	"Indicated whether stopping in Sugar will keep or not"
	| wasStop isStop oldButton |
	(self isSugar and: [stopButton notNil])  ifTrue: [
		wasStop := stopButton actionSelector = #stopSqueak.
		isStop := SugarLauncher current willSaveOnQuit.
		wasStop = isStop ifFalse: [
			oldButton := stopButton.
			stopButton := isStop ifTrue: [self buttonStop] ifFalse: [self buttonQuit].
			oldButton owner replaceSubmorph: oldButton by: stopButton]].


]

{ #category : #sharing }
SugarNavigatorBar >> stopSharing [
	SugarLauncher current leaveSharedActivity.
	listener ifNotNil: [listener stopListening. listener := nil].
	Project current world remoteServer: nil.
	Project current world submorphs do: [:ea |
		(ea isMemberOf: NebraskaServerMorph) ifTrue: [ea delete]].
	self sharingChanged.
]

{ #category : #'button actions' }
SugarNavigatorBar >> stopSqueak [

	^ self quitSqueak.

]

{ #category : #'buttons creation' }
SugarNavigatorBar >> stringForDisplayModeIs: aSymbol [
	"Answer the description of the scaling mode represented by the given symbol."

	| currentMode |
	currentMode := self currentDisplayMode.

	#(	(physical			'No Scaling')
		(scaledVirtual		'Scaled Virtual Extent')
		(centeredVirtual	'Centered Virtual Extent'))  translatedNoop do:
			[:pair |
				aSymbol = pair first ifTrue:
					[^  (currentMode = aSymbol ifTrue: ['<yes>'] ifFalse: ['<no>']), pair second translated]].


	^ 'error'
]

{ #category : #'buttons creation' }
SugarNavigatorBar >> stringForFullScreenToggle [
	"Answer the wording forf the full-screen toggle."

	^ (self inFullScreenMode ifTrue: ['<yes>'] ifFalse: ['<no>']), 'Full Screen' translated
]

{ #category : #accessing }
SugarNavigatorBar >> sugarLib [
	"Answer the instance of the SugarLibrary with which the receiver is affiliated, creating it at this time if necessary."

	^ sugarLib ifNil: [sugarLib := SugarLibrary default]
]

{ #category : #initialization }
SugarNavigatorBar >> sugarLib: anObject [

	sugarLib := anObject.

]

{ #category : #initialization }
SugarNavigatorBar >> suppliesButtonInitialExplanation [

	^ 'Or, click to see Supplies.  
Choose an object or 
choose the Object Catalog for more choices.' translated

]

{ #category : #'help flap' }
SugarNavigatorBar >> toggleHelp [
	"Open the help-cards flap, or close it if open."

	| ref f guide |
	f := Flaps globalFlapTab: 'Help' translated.
	f ifNotNil:
		[
		f isInWorld
			ifTrue:
				[ref := f referent.
				ref ifNotNil: [guide := ref findDeeplyA: QuickGuideMorph].
				guide ifNotNil: [guide unloadPages].
				Flaps removeFlapTab: f keepInList: false]
			ifFalse:
				[f openInWorld.
				f showFlap.
				ref := f referent.
				ref ifNotNil: [
					guide := ref findDeeplyA: QuickGuideMorph].
					guide ifNotNil: [Cursor wait showWhile: [guide initializeIndexPage]]]]
		ifNil:
			[QuickGuideMorph guidePath
				ifNil: [^self inform: 'There are no QuickGuides installed' translated].
			Cursor wait showWhile: [self buildAndOpenHelpFlap]]
]

{ #category : #'button actions' }
SugarNavigatorBar >> toggleScreenSetting: aSymbol [
	"The user requested toggling of the display-mode item representing the given symbol"

	| currentMode |
	currentMode := self currentDisplayMode.

	aSymbol = currentMode 
		ifTrue:
			[#(	(physical			scaledVirtual)
				(scaledVirtual		physical)
				(centeredVirtual	scaledVirtual)) do:
					[:pair |
						currentMode = pair first ifTrue: [^ self changeDisplayModeTo: pair second]]].

	self changeDisplayModeTo: aSymbol
]

{ #category : #'button actions' }
SugarNavigatorBar >> toggleSupplies [

	| ref f |
	f := (Flaps globalFlapTab: 'Supplies' translated).
	ref := f referent.
	ref isInWorld ifTrue: [f hideFlap] ifFalse: [
		f showFlap.
		(owner notNil and: [owner isFlapTab]) ifTrue: [
			owner edgeToAdhereTo == #top ifTrue: [
				ref position: self bottomLeft.
			].
			owner edgeToAdhereTo == #bottom ifTrue: [
				ref bottomLeft: self topLeft.
			].
		].
		f position: 0@(f height negated)
	].


]

{ #category : #'event handling' }
SugarNavigatorBar >> undoButtonAppearance [

	| wording |
	undoButton ifNotNil: [
		Project current world commandHistory undoEnabled
			ifTrue: [undoButton enabled]
			ifFalse: [undoButton disabled].
		wording := self undoButtonWording.
		undoButton setBalloonText: wording.
	].


]

{ #category : #'event handling' }
SugarNavigatorBar >> wantsDroppedMorph: aMorph event: evt [

	^ false.

]

{ #category : #initialization }
SugarNavigatorBar >> wantsHaloForSubmorphs: aBoolean [

	self allMorphsDo: [:m | m setProperty: #wantsHaloFromClick toValue: aBoolean].

]

{ #category : #'button actions' }
SugarNavigatorBar >> zoom [
	self inFullScreenMode
		ifTrue: [self fullScreenOff]
		ifFalse: [self fullScreenOn]
]
