"
A morph whose submorphs comprise a paste-up of rectangular subparts which ""show through"".  Anything called a 'Playfield' is a PasteUpMorph.

Facilities commonly needed on pages of graphical presentations and on simulation playfields, such as the painting of new objects, turtle trails, gradient fills, background paintings, parts-bin behavior, collision-detection, etc., are (or will be) provided.

A World, the entire Smalltalk screen, is a PasteUpMorph.  A World responds true to isWorld.  Morph subclasses that have specialized menus (BookMorph) build them in the message addBookMenuItemsTo:hand:.  A PasteUpMorph that is a world, builds its menu in HandMorph buildWorldMenu.

presenter	A Presenter in charge of stopButton stepButton and goButton, 
			mouseOverHalosEnabled soundsEnabled fenceEnabled coloredTilesEnabled.
model		<not used>
cursor		??
padding		??
backgroundMorph		A Form that covers the background.
turtleTrailsForm			Moving submorphs may leave trails on this form.
turtlePen				Draws the trails.
lastTurtlePositions		A Dictionary of (aPlayer -> aPoint) so turtle trails can be drawn 
						only once each step cycle.  The point is the start of the current stroke.
isPartsBin		If true, every object dragged out is copied.
autoLineLayout		??
indicateCursor		??
resizeToFit		??
wantsMouseOverHalos		If true, simply moving the cursor over a submorph brings up its halo.
worldState		If I am also a World, keeps the hands, damageRecorder, stepList etc.
griddingOn		If true, submorphs are on a grid


"
Class {
	#name : #PasteUpMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'presenter',
		'model',
		'cursor',
		'padding',
		'backgroundMorph',
		'turtleTrailsForm',
		'turtlePen',
		'lastTurtlePositions',
		'isPartsBin',
		'indicateCursor',
		'wantsMouseOverHalos',
		'worldState',
		'griddingOn'
	],
	#classVars : [
		'DisableDeferredUpdates',
		'GlobalCommandKeysEnabled',
		'MinCycleLapse',
		'StillAlive',
		'WindowEventHandler'
	],
	#category : #'Morphic-Worlds'
}

{ #category : #project }
PasteUpMorph class >> MinCycleLapse: milliseconds [
	"set the minimum amount of time that may transpire between two calls to doOneCycle"
	MinCycleLapse := milliseconds ifNotNil: [ milliseconds rounded ].
]

{ #category : #scripting }
PasteUpMorph class >> authoringPrototype [
	"Answer an instance of the receiver suitable for placing in a parts bin for authors"
	
	| proto |
	proto := self new markAsPartsDonor.
	proto color: Color green muchLighter;  extent: 100 @ 80; borderColor: (Color r: 0.645 g: 0.935 b: 0.161).
	proto extent: 300 @ 240.
	proto wantsMouseOverHalos: false.
	proto beSticky.
	^ proto
]

{ #category : #printing }
PasteUpMorph class >> defaultNameStemForInstances [
	"Answer a basis for names of default instances of the receiver"
	^ 'playfield' translatedNoop
]

{ #category : #'parts bin' }
PasteUpMorph class >> descriptionForPartsBin [
	^ self partName:	'Playfield'
		categories:		#('Presentation')
		documentation:	'A place for assembling parts or for staging animations'
]

{ #category : #project }
PasteUpMorph class >> disableDeferredUpdates [

	^DisableDeferredUpdates ifNil: [DisableDeferredUpdates := false]

]

{ #category : #project }
PasteUpMorph class >> disableDeferredUpdates: aBoolean [
	"If the argument is true, disable deferred screen updating."
	"Details: When deferred updating is used, Morphic performs double-buffered screen updates by telling the VM to de-couple the Display from the hardware display buffer, drawing directly into the Display, and then forcing the changed regions of the Display to be copied to the screen. This saves both time (an extra BitBlt is avoided) and space (an extra display buffer is avoided). However, on platforms on which the Display points directly to the hardware screen buffer, deferred updating can't be used (you'd see ugly flashing as the layers of the drawing were assembled). In this case, the drawing is composited into an offscreen FormCanvas  and then copied to the hardware display buffer."

	DisableDeferredUpdates := aBoolean.

]

{ #category : #preferences }
PasteUpMorph class >> globalCommandKeysEnabled [
	<preference: 'Enable Global Command Keys'
		category: 'Morphic'
		description: 'When true, the global command keys are enabled.  Command-key help is available from the help menu.'
		type: #Boolean>
	^ GlobalCommandKeysEnabled ifNil: [ true ]
]

{ #category : #preferences }
PasteUpMorph class >> globalCommandKeysEnabled: aBoolean [

	GlobalCommandKeysEnabled = aBoolean ifTrue: [^ self].
	GlobalCommandKeysEnabled := aBoolean.
	
	SystemWindow allSubInstancesDo: [:ea |
		aBoolean
			ifTrue: [ea addKeyboardShortcuts]
			ifFalse: [ea removeKeyboardShortcuts]].

	PasteUpMorph allSubInstancesDo: [:ea |
		aBoolean
			ifTrue: [ea addKeyboardShortcuts]
			ifFalse: [ea removeKeyboardShortcuts]].
]

{ #category : #project }
PasteUpMorph class >> newWorldForProject: projectOrNil [ 
	"Return a new pasteUpMorph configured as a world (ie project notNil).
	projectOrNil is no longer used."

	^ self new initForProject: WorldState new
]

{ #category : #recompilation }
PasteUpMorph class >> postRecompileAction [
	"PasteUpMorph's worldState refers to blocks in its alarms and stepList inst vars.  These should be rebuilt post recompileAll"
	Project allProjects do:
		[:project|
		 project isMorphic ifTrue:
			[project world updateStatePostRecompile]].
	self currentWorld addGlobalFlaps
]

{ #category : #'world state' }
PasteUpMorph >> abandonAllHalos [
	self flag: #arNote. "Remove the method"
	^self deleteAllHalos
]

{ #category : #misc }
PasteUpMorph >> abandonCostumeHistory [
	self allMorphsDo:
		[:m | m player ifNotNil: [m player forgetOtherCostumes]]
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> acceptDroppingMorph: dropped event: evt [
	"The supplied morph, known to be acceptable to the receiver, is now to be assimilated; the precipitating event is supplied"

	| aMorph |
	aMorph := self morphToDropFrom: dropped.
	self isWorldMorph
		ifTrue:["Add the given morph to this world and start stepping it if it wants to be."
				aMorph isInWorld not ifTrue: [aMorph position: evt position].
				self addMorphFront: aMorph.
				(aMorph fullBounds intersects: self viewBox) ifFalse:
					[Beeper beep.  aMorph position: self bounds center]]
		ifFalse:[super acceptDroppingMorph: aMorph event: evt].

	aMorph submorphsDo: [:m | (m isKindOf: HaloMorph) ifTrue: [m delete]].
	aMorph allMorphsDo:  "Establish any penDown morphs in new world"
		[:m | | tfm mm |
		m player ifNotNil:
			[m player getPenDown ifTrue:
				[((mm := m player costume) notNil and: [(tfm := mm owner transformFrom: self) notNil])
					ifTrue: [self noteNewLocation: (tfm localPointToGlobal: mm referencePosition)
									forPlayer: m player]]]].

	self isPartsBin
		ifTrue:
			[aMorph isPartsDonor: true.
			aMorph stopSteppingSelfAndSubmorphs.
			aMorph suspendEventHandler]
		ifFalse:
			[self world startSteppingSubmorphsOf: aMorph].

"	self presenter morph: aMorph droppedIntoPasteUpMorph: self."
	self griddingOn ifTrue: [aMorph position: (self gridPoint: aMorph position)].
	self showingListView ifTrue:
		[self sortSubmorphsBy: (self valueOfProperty: #sortOrder).
		self currentWorld abandonAllHalos].

	self bringTopmostsToFront.

]

{ #category : #flaps }
PasteUpMorph >> accommodateFlap: aFlapTab [
	"Shift submorphs over, if appropriate"
	| offset |
	aFlapTab slidesOtherObjects ifTrue:
		[offset := self offsetForAccommodating: aFlapTab referent extent onEdge: aFlapTab edgeToAdhereTo.
		self shiftSubmorphsBy: offset]
]

{ #category : #'world menu' }
PasteUpMorph >> activateObjectsTool [
	"Offer the user a parts bin of morphs -- if one already exists, bring it to the front and flash its border beckoningly; if none exists yet, create a new one and place it in the center of the screen"

	| anObjectTool |
	submorphs do:
		[:aMorph | (aMorph renderedMorph isKindOf: ObjectsTool)
			ifTrue:
				[aMorph comeToFront.
				aMorph flash.
				^ self]].
	"None found, so create one"

	anObjectTool := ObjectsTool newStandAlone.
	self addMorphFront: anObjectTool.
	anObjectTool fullBounds.
	anObjectTool center: self center

	"ActiveWorld activateObjectsTool"
]

{ #category : #initialization }
PasteUpMorph >> adaptedToWorld: aWorld [
	"If I refer to a world or a hand, return the corresponding items in the new world."
	self isWorldMorph ifTrue:[^aWorld].
]

{ #category : #'alarms-scheduler' }
PasteUpMorph >> addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime [
	"Add a new alarm with the given set of parameters"
	worldState addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime.
]

{ #category : #'submorphs-add\/remove' }
PasteUpMorph >> addAllMorphs: array [

	super addAllMorphs: array.
	self isWorldMorph
		ifTrue: [array do: [:m | self startSteppingSubmorphsOf: m]].

]

{ #category : #layout }
PasteUpMorph >> addCenteredAtBottom: aMorph offset: anOffset [
	"Add aMorph beneath all other morphs currently in the receiver, centered horizontally, with the vertical offset from the bottom of the previous morph given by anOffset"
	| curBot |
	curBot := 0.
	submorphs do: [:m | curBot := curBot max: m bottom].
	self addMorphBack: aMorph.
	aMorph position: ((self center x - (aMorph width // 2)) @ (curBot + anOffset))
]

{ #category : #'menu & halo' }
PasteUpMorph >> addCustomMenuItems: menu hand: aHandMorph [ 
	"Add morph-specific menu itemns to the menu for the hand"
	super addCustomMenuItems: menu hand: aHandMorph.

	menu addLine.
	Preferences noviceMode
		ifFalse: [
			self addStackMenuItems: menu hand: aHandMorph.
			self addPenMenuItems: menu hand: aHandMorph.
			self addPlayfieldMenuItems: menu hand: aHandMorph].

	self isWorldMorph
		ifTrue: [
			menu addLine.
			Preferences noviceMode
				ifFalse: [(owner isKindOf: BOBTransformationMorph)
						ifTrue: [self addScalingMenuItems: menu hand: aHandMorph]].
			menu addUpdating: #showWorldMainDockingBarString action: #toggleShowWorldMainDockingBar.

			Flaps sharedFlapsAllowed ifTrue: [
				menu
					addUpdating: #suppressFlapsString
					target: Project current
					action: #toggleFlapsSuppressed.
			].
			 
			Preferences noviceMode ifFalse: [| twm |
				menu addLine.

				twm := TheWorldMenu new.
				twm world: self project: Project current hand: aHandMorph.

				menu add: 'old desktop menu... (W)' translated subMenu: twm buildWorldMenu.
			].
		].

]

{ #category : #flaps }
PasteUpMorph >> addGlobalFlaps [ 
	"Must make global flaps adapt to world.  Do this even if not shown, so the old world will not be pointed at by the flaps."

	| use thisWorld |
	use := Flaps sharedFlapsAllowed.
	Project current flapsSuppressed ifTrue: [use := false].
	"Smalltalk isMorphic ifFalse: [use := false]."
	thisWorld := use 
		ifTrue: [self]
		ifFalse: [PasteUpMorph new initForProject:  "fake to be flap owner"
						WorldState new;
					bounds: (0@0 extent: 4000@4000);
					viewBox: (0@0 extent: 4000@4000)].
	
	Flaps globalFlapTabsIfAny do: [:aFlapTab |
		(Project current isFlapEnabled: aFlapTab) ifTrue:
			[(aFlapTab world == thisWorld) ifFalse:
				[thisWorld addMorphFront: aFlapTab.
				aFlapTab adaptToWorld: thisWorld].	"always do"
			use ifTrue:
				[aFlapTab spanWorld.
				aFlapTab adjustPositionAfterHidingFlap.
				aFlapTab flapShowing ifTrue: [aFlapTab showFlap]]]]
]

{ #category : #'world state' }
PasteUpMorph >> addHand: aHandMorph [
	"Add the given hand to the list of hands for this world."

	aHandMorph owner ifNotNil:[aHandMorph owner removeHand: aHandMorph].
	worldState addHand: aHandMorph.
	aHandMorph privateOwner: self.

]

{ #category : #initialization }
PasteUpMorph >> addKeyboardShortcuts [
	"Install an event capture filter to add shortcuts for global operations like opening a tool."
	
	self addKeyboardCaptureFilter: self.
]

{ #category : #'world state' }
PasteUpMorph >> addMorph: aMorph centeredNear: aPoint [
	"Add the given morph to this world, attempting to keep its center as close to the given point possible while also keeping the it entirely within the bounds of this world."

	| trialRect delta |
	trialRect := Rectangle center: aPoint extent: aMorph fullBounds extent.
	delta := trialRect amountToTranslateWithin: bounds.
	aMorph position: trialRect origin + delta.
	self addMorph: aMorph.

]

{ #category : #'submorphs-add\/remove' }
PasteUpMorph >> addMorphFront: aMorph [

	^self addMorphInFrontOfLayer: aMorph

]

{ #category : #'WiW support' }
PasteUpMorph >> addMorphInLayer: aMorph [
	super addMorphInLayer: aMorph.
	aMorph wantsToBeTopmost ifFalse:[self bringTopmostsToFront].
]

{ #category : #'world state' }
PasteUpMorph >> addMorphsAndModel: aMorphOrList [ 
	"Dump in submorphs, model, and stepList from aMorphOrList.  Used to bring a world, paste-up, or other morph in from an object file."

	aMorphOrList isMorph 
		ifTrue: 
			[aMorphOrList isWorldMorph 
				ifFalse: 
					["one morph, put on hand"

					"aMorphOrList installModelIn: self.  	a chance to install model pointers"

					aMorphOrList privateOwner: nil.
					self firstHand attachMorph: aMorphOrList.
					self startSteppingSubmorphsOf: aMorphOrList]
				ifTrue: 
					[model isNil 
						ifTrue: [self setModel: aMorphOrList modelOrNil]
						ifFalse: 
							[aMorphOrList modelOrNil ifNotNil: 
									[aMorphOrList modelOrNil privateOwner: nil.
									self addMorph: aMorphOrList modelOrNil]].
					aMorphOrList privateSubmorphs reverseDo: 
							[:m | 
							m privateOwner: nil.
							self addMorph: m.
							m changed].
					(aMorphOrList instVarNamed: 'stepList') 
						do: [:entry | entry first startSteppingIn: self]]]
		ifFalse: 
			["list, add them all"

			aMorphOrList reverseDo: 
					[:m | 
					m privateOwner: nil.
					self addMorph: m.
					self startSteppingSubmorphsOf: m.	"It may not want this!"
					m changed]]
]

{ #category : #initialization }
PasteUpMorph >> addMouseShortcuts [
	
	self addMouseCaptureFilter: self.
]

{ #category : #'menu & halo' }
PasteUpMorph >> addPenMenuItems: menu hand: aHandMorph [
	"Add a pen-trails-within submenu to the given menu"

	menu add: 'pen trails...' translated target: self selector: #putUpPenTrailsSubmenu.
	menu balloonTextForLastItem: 'its governing pen trails drawn within' translated
]

{ #category : #'menu & halo' }
PasteUpMorph >> addPenTrailsMenuItemsTo: aMenu [
	"Add items relating to pen trails to aMenu"

	| oldTarget |
	oldTarget := aMenu defaultTarget.
	aMenu defaultTarget: self.
	aMenu add: 'clear pen trails' translated action: #clearTurtleTrails.
	aMenu addLine.
	aMenu add: 'all pens up' translated action: #liftAllPens.
	aMenu add: 'all pens down' translated action: #lowerAllPens.
	aMenu addLine.
	aMenu add: 'all pens show lines' translated action: #linesForAllPens.
	aMenu add: 'all pens show arrowheads' translated action: #arrowsForAllPens.
	aMenu add: 'all pens show arrows' translated action: #linesAndArrowsForAllPens.
	aMenu add: 'all pens show dots' translated action: #dotsForAllPens.
	aMenu  addLine.
	aMenu addUpdating:  #batchPenTrailsString  action: #toggleBatchPenTrails.
	aMenu balloonTextForLastItem: 'if true, detailed movement of pens between display updates is ignored.  Thus multiple line segments drawn within a script may not be seen individually.' translated.

	aMenu defaultTarget: oldTarget
]

{ #category : #'menu & halo' }
PasteUpMorph >> addPlayfieldMenuItems: menu hand: aHandMorph [
	"Add playfield-related items to the menu"

	menu add: 'playfield options...' translated target: self action: #presentPlayfieldMenu.
	(self hasProperty: #donorTextMorph) ifTrue:
		[menu add: 'send contents back to donor' translated action: #sendTextContentsBackToDonor]
]

{ #category : #Nebraska }
PasteUpMorph >> addRemoteClient: aClient [
	self addHand: aClient hand.
	worldState addRemoteCanvas: aClient canvas.
	aClient canvas fullDrawMorph: self.
	self changed.  "force a redraw"

]

{ #category : #'menu & halo' }
PasteUpMorph >> addScalingMenuItems: menu hand: aHandMorph [

	| subMenu |

	(subMenu := MenuMorph new)
		defaultTarget: self;
		add: 'show application view' translated action: #showApplicationView;
		add: 'show factory view' translated action: #showFactoryView;
		add: 'show whole world view' translated action: #showFullView;
		add: 'expand' translated action: #showExpandedView;
		add: 'reduce' translated action: #showReducedView;
		addLine;
		add: 'define application view' translated action: #defineApplicationView;
		add: 'define factory view' translated action: #defineFactoryView.
	menu
		add: 'world scale and clip...' translated
		subMenu: subMenu
]

{ #category : #'menu & halo' }
PasteUpMorph >> addStackMenuItems: menu hand: aHandMorph [
	"Add appropriate stack-related items to the given menu"

	self isStackBackground
		ifTrue:
			[menu add: 'card & stack...' target: self action: #presentCardAndStackMenu]
]

{ #category : #'world menu' }
PasteUpMorph >> addUndoItemsTo: aWorldMenu [
	"Add undo-related items to the given menu.  Will add zero, one or two items, depending on the settings of the #useUndo and #infiniteUndo preferences"

	Preferences useUndo ifFalse: [^ self].
	Preferences infiniteUndo
		ifFalse:
			[aWorldMenu addUpdating: #undoOrRedoMenuWording target: self commandHistory action: #undoOrRedoCommand]
		ifTrue:
			[aWorldMenu addUpdating: #undoMenuWording target: self commandHistory  action: #undoLastCommand.
			aWorldMenu addUpdating: #redoMenuWording target: self commandHistory action: #redoNextCommand.
			self flag: #deferred.  "The following feature to be unblocked in due course"
			"aWorldMenu add: 'undo to...' target: self commandHistory action: #undoTo"].
	aWorldMenu addLine
]

{ #category : #'menu & halo' }
PasteUpMorph >> addWorldHaloMenuItemsTo: aMenu hand: aHandMorph [
	"Add standard halo items to the menu, given that the receiver is a World"

	| unlockables |
	self addFillStyleMenuItems: aMenu hand: aHandMorph.
	self addLayoutMenuItems: aMenu hand: aHandMorph.

	aMenu addLine.
	self addWorldToggleItemsToHaloMenu: aMenu.
	aMenu addLine.
	self addCopyItemsTo: aMenu.
	self addPlayerItemsTo: aMenu.
	self addExportMenuItems: aMenu hand: aHandMorph.
	self addStackItemsTo: aMenu.
	self addMiscExtrasTo: aMenu.

	Preferences noviceMode ifFalse:
		[self addDebuggingItemsTo: aMenu hand: aHandMorph].

	aMenu addLine.
	aMenu defaultTarget: self.

	aMenu addLine.

	unlockables := self submorphs select:
		[:m | m isLocked].
	unlockables size = 1 ifTrue:
		[aMenu add: ('unlock "{1}"' translated format:{unlockables first externalName})action: #unlockContents].
	unlockables size > 1 ifTrue:
		[aMenu add: 'unlock all contents' translated action: #unlockContents.
		aMenu add: 'unlock...' translated action: #unlockOneSubpart].

	aMenu defaultTarget: aHandMorph.

]

{ #category : #'menu & halo' }
PasteUpMorph >> addWorldToggleItemsToHaloMenu: aMenu [
	"Add toggle items for the world to the halo menu"

	#(
	(hasDragAndDropEnabledString changeDragAndDrop 'whether I am open to having objects dropped into me')
	(roundedCornersString toggleCornerRounding 'whether the world should have rounded corners')) do:

		[:trip | aMenu addUpdating: trip first action: trip second.
			aMenu balloonTextForLastItem: trip third]
]

{ #category : #'submorphs-accessing' }
PasteUpMorph >> allMorphsDo: aBlock [
	"Enumerate all morphs in the world, including those held in hands."

	super allMorphsDo: aBlock.
	self isWorldMorph
		ifTrue: [worldState handsReverseDo: [:h | h allMorphsDo: aBlock]].

]

{ #category : #'world state' }
PasteUpMorph >> allNonFlapRelatedSubmorphs [
	"Answer all non-window submorphs that are not flap-related"

	^submorphs 
		select: [:m | (m isSystemWindow) not and: [m wantsToBeTopmost not]]
]

{ #category : #misc }
PasteUpMorph >> allScriptEditors [
	^ self allMorphs select:
		[:s | s isScriptEditorMorph]
]

{ #category : #misc }
PasteUpMorph >> allScriptors [
	"Answer a list of all active scriptors running on behalf of the receiver.  This is a hook used in past demos and with a future life which however presently is vacuous"

	^ #()
"
	^ self allMorphs select: [:m | m isKindOf: Scriptor]"
]

{ #category : #scripting }
PasteUpMorph >> allTileScriptingElements [
	"Answer a list of all the morphs that pertain to tile-scripting.  A sledge-hammer"

	| all morphs |
	morphs := IdentitySet new: 400.
	self allMorphsAndBookPagesInto: morphs.
	all := morphs select: [:s | s isTileScriptingElement].
"	self closedViewerFlapTabs do:
		[:aTab | all addAll: aTab referent allTileScriptingElements].
"
	^ all asOrderedCollection
]

{ #category : #misc }
PasteUpMorph >> alwaysShowThumbnail [
	^ self hasProperty: #alwaysShowThumbnail
]

{ #category : #flaps }
PasteUpMorph >> assureFlapTabsFitOnScreen [
	self flapTabs do:
		[:m | m fitOnScreen]
]

{ #category : #accessing }
PasteUpMorph >> assureFlapWidth: requestedWidth [
	| tab |
	self width: requestedWidth.
	tab := self flapTab ifNil:[^self].
	tab flapShowing ifTrue:[tab hideFlap; showFlap].
]

{ #category : #'world state' }
PasteUpMorph >> assureNotPaintingElse: aBlock [
	"If painting is already underway in the receiver, put up an informer to that effect and evalute aBlock"
	self sketchEditorOrNil ifNotNil:
		[self inform: 'Sorry, you can only paint
one object at a time' translated.
		Cursor normal show.
		^ aBlock value]

]

{ #category : #'world state' }
PasteUpMorph >> assureNotPaintingEvent: evt [
	"If painting is already underway
	in the receiver, put up an informer to that effect and evalute aBlock"
	| editor |
	(editor := self sketchEditorOrNil) ifNotNil:[
		editor save: evt.
		Cursor normal show.
	].
]

{ #category : #'world state' }
PasteUpMorph >> assuredCanvas [
	
	^worldState assuredCanvas
]

{ #category : #options }
PasteUpMorph >> autoLineLayout [
	| layout |
	layout := self layoutPolicy ifNil:[^false].
	layout isTableLayout ifFalse:[^false].
	self listDirection == #leftToRight ifFalse:[^false].
	self wrapDirection == #topToBottom ifFalse:[^false].
	^true
]

{ #category : #options }
PasteUpMorph >> autoLineLayout: aBoolean [
	"Make the receiver be viewed with auto-line-layout, which means that its submorphs will be laid out left-to-right and then top-to-bottom in the manner of a word processor, or (if aBoolean is false,) cease applying auto-line-layout"

	aBoolean ifTrue:
		[self viewingNormally ifTrue: [self saveBoundsOfSubmorphs]].
	aBoolean ifTrue:[
		self layoutPolicy: TableLayout new.
		self layoutInset: 8; cellGap: 4.
		self listDirection: #leftToRight; wrapDirection: #topToBottom.
	] ifFalse:[
		self layoutPolicy: nil.
		self layoutInset: 0; cellGap: 0.
	].

]

{ #category : #'menu & halo' }
PasteUpMorph >> autoLineLayoutString [
	"Answer the string to be shown in a menu to represent the  
	auto-line-layout status"
	^ (self autoLineLayout
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'auto-line-layout' translated
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> automaticPhraseExpansion [
	^ self hasProperty: #automaticPhraseExpansion
]

{ #category : #'e-toy support' }
PasteUpMorph >> automaticViewing [
	^ self hasProperty: #automaticViewing
]

{ #category : #'world state' }
PasteUpMorph >> beWorldForProject: aProject [

	self privateOwner: nil.
	worldState := WorldState new.
	self addHand: HandMorph new.
	self setProperty: #automaticPhraseExpansion toValue: true.
	self setProperty: #optimumExtentFromAuthor toValue: Display extent.
	self startSteppingSubmorphsOf: self
]

{ #category : #initialization }
PasteUpMorph >> becomeActiveDuring: aBlock [
	"Make the receiver the active world during the evaluation of aBlock."

	^ ActiveWorldVariable value: self during: aBlock
]

{ #category : #options }
PasteUpMorph >> behaveLikeHolder [
 
	self vResizeToFit: true; autoLineLayout: true; indicateCursor: true
]

{ #category : #options }
PasteUpMorph >> behaveLikeHolder: aBoolean [
 	"Change the receiver's viewing properties such that they conform to what we commonly call a Holder, viz: resize-to-fit, do auto-line-layout, and indicate the 'cursor'"

	self vResizeToFit: aBoolean; autoLineLayout: aBoolean; indicateCursor: aBoolean
	
]

{ #category : #options }
PasteUpMorph >> behavingLikeAHolder [
	"Answer whether the receiver is currently behaving like a Holder"

	^ self resizeToFit and: [self indicateCursor and: [self autoLineLayout]]
]

{ #category : #flaps }
PasteUpMorph >> bringTopmostsToFront [
	submorphs
		select:[:m| m wantsToBeTopmost]
		thenDo:[:m| self addMorphInLayer: m].
]

{ #category : #'world menu' }
PasteUpMorph >> bringWindowsFullOnscreen [
	"Make ever SystemWindow on the desktop be totally on-screen, whenever possible."
	
	(SystemWindow windowsIn: self satisfying: [:w | true]) do:
		[:aWindow | 
			aWindow right: (aWindow right min: bounds right).
			aWindow bottom: (aWindow bottom min: bounds bottom).
			aWindow left: (aWindow left max: bounds left).
			aWindow top: (aWindow top max: bounds top)]
]

{ #category : #'world menu' }
PasteUpMorph >> browseAllScriptsTextually [
	"Put up a browser showing all scripts in the project textually"

	self presenter browseAllScriptsTextually

"ActiveWorld browseAllScriptsTextually"
]

{ #category : #'menu & halo' }
PasteUpMorph >> buildDebugMenu: aHandMorph [
	| aMenu |
	aMenu := super buildDebugMenu: aHandMorph.
	aMenu add:  'abandon costume history' translated target: self action: #abandonCostumeHistory.
	^ aMenu
]

{ #category : #'world menu' }
PasteUpMorph >> buildWorldMenu: evt [
	^(TheWorldMenu new
		world: self
		project: (self project ifNil: [Project current])       "mvc??"
		hand: evt hand) buildWorldMenu.
]

{ #category : #misc }
PasteUpMorph >> cachedOrNewThumbnailFrom: newThumbnail [
	"If I have a cached thumbnail, and it is of the desired extent, then ruturn it.
	Otherwise produce one in newThumbnail and return it (after caching).
	This code parallels what happens in page: to match resultant extent."
	| cachedThumbnail scale ext |
	scale := newThumbnail height / self fullBounds height.
	ext := (self fullBounds extent * scale) truncated.
	(cachedThumbnail := self valueOfProperty: #cachedThumbnail) ifNotNil:
		[cachedThumbnail extent = ext ifTrue: [^ cachedThumbnail]].
	self setProperty: #cachedThumbnail toValue: (newThumbnail page: self).
	^ newThumbnail
]

{ #category : #'visual properties' }
PasteUpMorph >> canHaveFillStyles [
	"Return true if the receiver can have general fill styles; not just colors.
	This method is for gradually converting old morphs."
	^ true
]

{ #category : #'project state' }
PasteUpMorph >> canvas [

	^ worldState canvas
]

{ #category : #'project state' }
PasteUpMorph >> canvas: aCanvas [
	"Set this world's canvas"

	worldState canvas: aCanvas.

]

{ #category : #misc }
PasteUpMorph >> cartesianOrigin [
	^ self originAtCenter
		ifFalse:
			[self bottomLeft]
		ifTrue:
			[self center]
]

{ #category : #'world state' }
PasteUpMorph >> checkCurrentHandForObjectToPaste [

	| response |
	self primaryHand pasteBuffer ifNil: [^self].
	response := UIManager default chooseFrom: #('Delete' 'Keep')
		title: 'Hand is holding a Morph in its paste buffer:\' withCRs,
			self primaryHand pasteBuffer printString.
	response = 1 ifTrue: [self primaryHand pasteBuffer: nil].

]

{ #category : #'world state' }
PasteUpMorph >> checkCurrentHandForObjectToPaste2 [

	self primaryHand pasteBuffer ifNil: [^self].
	self inform: 'Hand is holding a Morph in its paste buffer:\' withCRs,
		self primaryHand pasteBuffer printString.


]

{ #category : #'world state' }
PasteUpMorph >> chooseClickTarget [
	Cursor crossHair showWhile:
		[Sensor waitButton].
	Cursor down showWhile:
		[Sensor anyButtonPressed].
	^ (self morphsAt: Sensor cursorPoint) first topRendererOrSelf
]

{ #category : #stepping }
PasteUpMorph >> cleanseStepList [
	"Remove morphs from the step list that are not in this World.  Often were in a flap that has moved on to another world."

	worldState cleanseStepListForWorld: self
]

{ #category : #undo }
PasteUpMorph >> clearCommandHistory [

	worldState ifNotNil: [worldState clearCommandHistory]
]

{ #category : #'world menu' }
PasteUpMorph >> closeUnchangedWindows [
	"Present a menu of window titles for all windows with changes,
	and activate the one that gets chosen."
	(UIManager default confirm:
'Do you really want to close all windows
except those with unaccepted edits?' translated)
		ifFalse: [^ self].

	(SystemWindow windowsIn: self satisfying: [:w | w model canDiscardEdits])
		do: [:w | w delete]
]

{ #category : #misc }
PasteUpMorph >> closedViewerFlapTabs [
	"Answer all the viewer flap tabs in receiver that are closed"

	^ self submorphs select:
		[:m | (m isKindOf: ViewerFlapTab) and: [m flapShowing not]]
]

{ #category : #'world menu' }
PasteUpMorph >> collapseAll [
	"Collapse all windows"
	(SystemWindow windowsIn: self satisfying: [:w | w isCollapsed not])
		reverseDo: [:w | w collapseOrExpand.  self displayWorld].
	self collapseNonWindows
]

{ #category : #'world menu' }
PasteUpMorph >> collapseNonWindows [
	self allNonFlapRelatedSubmorphs do:
		[:m | m collapse]
]

{ #category : #'world state' }
PasteUpMorph >> colorAt: aPoint belowMorph: aMorph [
	"Return the color of the pixel immediately behind the given morph at the given point.
	NOTE: due to some bounds wobble in flexing, we take the middle of 3x3 rect."
	^ (self patchAt: (aPoint-1 extent: 3) without: aMorph andNothingAbove: true)
		colorAt: 1@1

]

{ #category : #undo }
PasteUpMorph >> commandHistory [
	"Return the command history for the receiver"
	^self isWorldMorph
		ifTrue:[worldState commandHistory]
		ifFalse:[super commandHistory]
]

{ #category : #'world menu' }
PasteUpMorph >> commandKeySelectors [
	"Answer my command-key table"

	| aDict |
	aDict := self valueOfProperty: #commandKeySelectors ifAbsentPut: [self initializeDesktopCommandKeySelectors].
	^ aDict
]

{ #category : #'world menu' }
PasteUpMorph >> connectRemoteUser [
	
	^self
		connectRemoteUserWithName: nil 
		picture: nil 
		andIPAddress: nil

]

{ #category : #'world menu' }
PasteUpMorph >> connectRemoteUserWithName: nameStringOrNil picture: aFormOrNil andIPAddress: aStringOrNil [
	"Prompt for the initials to be used to identify the cursor of a remote user, then create a cursor for that user and wait for a connection."

	| initials addr h |
	initials := nameStringOrNil.
	initials isEmptyOrNil ifTrue: [
		initials := UIManager default request: 'Enter initials for remote user''s cursor?'.
	].
	initials isEmpty ifTrue: [^ self].  "abort"
	addr := 0.
	aStringOrNil isEmptyOrNil ifFalse: [
		addr := NetNameResolver addressForName: aStringOrNil timeout: 30
	].
	addr = 0 ifTrue: [
		addr := NetNameResolver promptUserForHostAddress.
	].
	addr = 0 ifTrue: [^ self].  "abort"

	(RemoteHandMorph ensureNetworkConnected) ifFalse: [^ self]. "abort"

	h := RemoteHandMorph new userInitials: initials andPicture: aFormOrNil.
	self addHand: h.
	h changed.
	h startListening.
	h startTransmittingEventsTo: addr.

]

{ #category : #layout }
PasteUpMorph >> convertAlignment [
	self 
		clipSubmorphs: true ;
		layoutPolicy: nil ;
		layoutInset: 0 ;
		cellInset: 0 ;
		vResizing: #rigid
]

{ #category : #Nebraska }
PasteUpMorph >> convertRemoteClientToBuffered: aClient [

	worldState removeRemoteCanvas: aClient canvas.
	aClient convertToBuffered.
	worldState addRemoteCanvas: aClient canvas.
	self changed.  "force a redraw"

]

{ #category : #'objects from disk' }
PasteUpMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	"transition from project to worldState (8/16/1999)"
	worldState ifNil: [varDict at: 'project' ifPresent: [ :x | worldState := x]].

	"elimination of specific gradient stuff (5/6/2000)"
	varDict at: 'fillColor2' ifPresent: [ :color2 |
		(color isColor and: [color2 isColor and: [color ~= color2]]) ifTrue: [
			self useGradientFill.
			self fillStyle
				colorRamp: {0.0 -> color. 1.0 -> color2};
				radial: false;
				origin: self position;
				direction: ((varDict at: 'gradientDirection') == #vertical 
					ifTrue:[0@self height] 
					ifFalse:[self width@0]).
		]
	].

	"support shortcuts with the new event filters (5/24/2018)"
	self
		initializeKeyboardShortcuts;
		initializeMouseShortcuts.

	^super convertToCurrentVersion: varDict refStream: smartRefStrm.

]

{ #category : #flaps }
PasteUpMorph >> correspondingFlapTab [
	"If there is a flap tab whose referent is me, return it, else return nil.  Will also work for flaps on the edge of embedded subareas such as within scripting-areas, but more slowly."

	self currentWorld flapTabs do:
		[:aTab | aTab referent == self ifTrue: [^ aTab]].

	"Catch guys in embedded worldlets"
	self currentWorld allMorphs do:
		[:aTab | ((aTab isKindOf: FlapTab) and: [aTab referent == self]) ifTrue: [^ aTab]].

	^ nil
]

{ #category : #classification }
PasteUpMorph >> couldMakeSibling [
	
	^ self isWorldMorph not
]

{ #category : #model }
PasteUpMorph >> createCustomModel [
	"Create a model object for this world if it does not yet have one. A model object is an initially empty subclass of MorphicModel. As the user names parts and adds behavior, instance variables and methods are added to this class."

	model isNil ifFalse: [^self].
	model := MorphicModel newSubclass new
]

{ #category : #'menu & halo' }
PasteUpMorph >> currentlyUsingVectorVocabulary [
	"Answer whether this world is currently set up to use the vector vocabulary"

	^ (self valueOfProperty: #currentVocabularySymbol) == #Vector
]

{ #category : #'e-toy support' }
PasteUpMorph >> cursor [ 
	^ cursor

]

{ #category : #'e-toy support' }
PasteUpMorph >> cursor: aNumber [
	"for backward compatibility"

	self cursorWrapped: aNumber
]

{ #category : #cursor }
PasteUpMorph >> cursorWrapped: aNumber [ 
	"Set the cursor to the given number, modulo the number of items I
	contain. Fractional cursor values are allowed."
	| oldRect newRect offset |
	cursor = aNumber
		ifTrue: [^ self].
	self hasSubmorphs
		ifFalse: [cursor := 1.
			^ self].
	oldRect := self selectedRect.
	offset := (self asNumber: aNumber) - 1 \\ submorphs size.
	cursor := offset + 1.
	newRect := self selectedRect.
	self indicateCursor
		ifTrue: [self invalidRect: oldRect;
				 invalidRect: newRect]
]

{ #category : #'world state' }
PasteUpMorph >> deEmphasizeViewMVC: asTwoTone [
	self flag: #arNote. "Probably unnecessary"
	worldState handsDo:          "free dependents links if any"
		[:h | h releaseKeyboardFocus].
	worldState canvas: nil.		"free model's canvas to save space"
	self fullReleaseCachedState.
	asTwoTone ifTrue: [
		"draw deEmphasized as a two-tone (monochrome) form"
		self displayWorldAsTwoTone].

]

{ #category : #initialization }
PasteUpMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color
		r: 0.861
		g: 1.0
		b: 0.722
]

{ #category : #initialization }
PasteUpMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
PasteUpMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Preferences defaultWorldColor muchLighter.
]

{ #category : #viewer }
PasteUpMorph >> defaultNameStemForInstances [
	"Answer a basis for names of default instances of the receiver"
	^ self isWorldMorph
		ifFalse:
			[super defaultNameStemForInstances]
		ifTrue:
			['world' translatedNoop]
]

{ #category : #'halos and balloon help' }
PasteUpMorph >> defersHaloOnClickTo: aSubMorph [
	"If a cmd-click on aSubMorph would make it a preferred recipient of the halo, answer true"
	^ true
	
]

{ #category : #'menu & halo' }
PasteUpMorph >> defineApplicationView [

	| r |
	r := Rectangle fromUser.
	self 
		setProperty: #applicationViewBounds 
		toValue: ((self transformFromOutermostWorld) globalBoundsToLocal: r) truncated 
]

{ #category : #'menu & halo' }
PasteUpMorph >> defineFactoryView [

	| r |
	r := Rectangle fromUser.
	self 
		setProperty: #factoryViewBounds 
		toValue: ((self transformFromOutermostWorld) globalBoundsToLocal: r) truncated 
]

{ #category : #'world menu' }
PasteUpMorph >> delayedInvokeWorldMenu: evt [ 
	self
		addAlarm: #invokeWorldMenu:
		with: evt
		after: 200
]

{ #category : #'world state' }
PasteUpMorph >> deleteAllHalos [
	self haloMorphs do:
		[ : m | m target isSelectionMorph ifTrue: [ m target delete ] ].
	self hands do:
		[ : each | each removeHalo ]
]

{ #category : #'menu & halo' }
PasteUpMorph >> deleteBalloonTarget: aMorph [
	"Delete the balloon help targeting the given morph"
	self handsDo:[:h| h deleteBalloonTarget: aMorph].
]

{ #category : #flaps }
PasteUpMorph >> deleteGlobalFlapArtifacts [
	"Delete all flap-related detritus from the world"

	| localFlaps |
	localFlaps := self localFlapTabs collect: [:m | m referent].
	self submorphs do:
		[:m | 
			((m isFlapTab) and: [m isGlobalFlap]) ifTrue: [m delete].
			m isFlap ifTrue:[(localFlaps includes: m) ifFalse: [m delete]]]

"ActiveWorld deleteGlobalFlapArtifacts"


]

{ #category : #'world menu' }
PasteUpMorph >> deleteNonWindows [
	(UIManager default confirm:
'Do you really want to discard all objects
that are not in windows?' translated)
		ifFalse: [^ self].

	self allNonFlapRelatedSubmorphs do:
		[:m | m delete]
]

{ #category : #'world menu' }
PasteUpMorph >> detachableScriptingSpace [
	ScriptingSystem newScriptingSpace openInWorld: self
]

{ #category : #'world menu' }
PasteUpMorph >> disconnectAllRemoteUsers [
	"Disconnect all remote hands and stop transmitting events."
	self world handsDo: [:h |
		(h isKindOf: RemoteHandMorph) 
			ifTrue: [h withdrawFromWorld]].
]

{ #category : #'world menu' }
PasteUpMorph >> disconnectRemoteUser [
	"Prompt for the initials of the remote user, then remove the remote hand with those initials, breaking its connection."

	"select hand to remove"
	| initials handToRemove |
	initials := UIManager default request: 'Enter initials for remote user''s cursor?'.
	initials isEmpty ifTrue: [^ self].  "abort"
	handToRemove := nil.
	self handsDo: [:h |
		h userInitials = initials ifTrue: [handToRemove := h]].
	handToRemove ifNil: [^ self].  "no hand with those initials"
	handToRemove withdrawFromWorld.

]

{ #category : #'world menu' }
PasteUpMorph >> dispatchCommandKeyInWorld: aChar event: evt [
	"Dispatch the desktop command key if possible.  Answer whether handled"

	| aMessageSend |
	aMessageSend := self commandKeySelectors at: aChar ifAbsent: [^ false].
	aMessageSend selector numArgs = 0
		ifTrue:
			[aMessageSend value]
		ifFalse:
			[aMessageSend valueWithArguments: (Array with: evt)].
	^ true

]

{ #category : #'world state' }
PasteUpMorph >> displayWorld [

	self outermostWorldMorph privateOuterDisplayWorld

]

{ #category : #'world state' }
PasteUpMorph >> displayWorldAsTwoTone [
	"Display the world in living black-and-white. (This is typically done to save space.)"

	worldState displayWorldAsTwoTone: self submorphs: submorphs color: color

]

{ #category : #'world state' }
PasteUpMorph >> displayWorldNonIncrementally [
	"Display the morph world non-incrementally. Used for testing."

	(worldState canvas isNil or: 
			[worldState canvas extent ~= self viewBox extent 
				or: [worldState canvas form depth ~= Display depth]]) 
		ifTrue: 
			["allocate a new offscreen canvas the size of the window"

			worldState 
				canvas: (Display defaultCanvasClass extent: self viewBox extent)].
	worldState canvas fillColor: color.
	submorphs reverseDo: [:m | worldState canvas fullDrawMorph: m].
	worldState handsReverseDo: [:h | worldState canvas fullDrawMorph: h].
	worldState canvas form displayOn: Display at: self viewBox origin.
	self fullRepaintNeeded.	"don't collect damage"
	Display forceDisplayUpdate
]

{ #category : #'world state' }
PasteUpMorph >> displayWorldSafely [

	worldState displayWorldSafely: self.

]

{ #category : #'world state' }
PasteUpMorph >> doOneCycle [
	"see the comment in doOneCycleFor:"

	worldState doOneCycleFor: self
]

{ #category : #'world state' }
PasteUpMorph >> doOneCycleInBackground [
	
	worldState doOneCycleInBackground

]

{ #category : #'interaction loop' }
PasteUpMorph >> doOneCycleNow [
	"see the comment in doOneCycleNowFor:"
	worldState doOneCycleNowFor: self.

]

{ #category : #'world state' }
PasteUpMorph >> doOneSubCycle [
	"Like doOneCycle, but preserves activeHand."

	worldState doOneSubCycleFor: self
]

{ #category : #'world state' }
PasteUpMorph >> dragThroughOnDesktop: evt [
	"Draw out a selection rectangle"
	| selection |
	selection := SelectionMorph newBounds: (evt cursorPoint extent: 8@8).
	self addMorph: selection.
	^ selection extendByHand: evt hand

]

{ #category : #drawing }
PasteUpMorph >> drawOn: aCanvas [ 
	"Draw in order:
	- background color
	- grid, if any
	- background sketch, if any
	- Update and draw the turtleTrails form. See the comment in updateTrailsForm.
	- cursor box if any

	Later (in drawSubmorphsOn:) I will skip drawing the background sketch."

	"draw background fill"
	super drawOn: aCanvas.

	"draw grid"
	(self griddingOn and: [self gridVisible]) 
		ifTrue: 
			[aCanvas fillRectangle: self bounds
				fillStyle: (self 
						gridFormOrigin: self gridOrigin
						grid: self gridModulus
						background: nil
						line: Color lightGray)].

	"draw background sketch."
	backgroundMorph ifNotNil: [
		self clipSubmorphs ifTrue: [
			aCanvas clipBy: self clippingBounds
				during: [ :canvas | canvas fullDrawMorph: backgroundMorph ]]
			ifFalse: [ aCanvas fullDrawMorph: backgroundMorph ]].

	"draw turtle trails"
	(lastTurtlePositions isNil or: [lastTurtlePositions isEmpty]) ifFalse:[
		self updateTrailsForm.
	].
	turtleTrailsForm 
		ifNotNil: [aCanvas paintImage: turtleTrailsForm at: self position].

	"draw cursor"
	(submorphs notEmpty and: [self indicateCursor]) 
		ifTrue: 
			[aCanvas 
				frameRectangle: self selectedRect
				width: 2
				color: Color black]
]

{ #category : #painting }
PasteUpMorph >> drawSubmorphsOn: aCanvas [ 
	"Display submorphs back to front, but skip my background sketch."

	| drawBlock |
	submorphs isEmpty ifTrue: [^self].
	drawBlock := [:canvas | submorphs reverseDo: [:m | m ~~ backgroundMorph ifTrue: [ canvas fullDrawMorph: m ]]].
	self clipSubmorphs 
		ifTrue: [aCanvas clipBy: self clippingBounds during: drawBlock]
		ifFalse: [drawBlock value: aCanvas]
]

{ #category : #'world menu' }
PasteUpMorph >> drawingClass [

	^ SketchMorph
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> dropEnabled [
	"Get this morph's ability to add and remove morphs via drag-n-drop."

	^ (self valueOfProperty: #dropEnabled) ~~ false

]

{ #category : #'event handling' }
PasteUpMorph >> dropFiles: anEvent [
	"Handle a number of dropped files from the OS.
	TODO:
		- use a more general mechanism for figuring out what to do with the file (perhaps even offering a choice from a menu)
		- remember the resource location or (when in browser) even the actual file handle
	"
	| numFiles |
	numFiles := anEvent contents.
	1 to: numFiles do: [ :i |
		(FileDirectory requestDropDirectory: i) 
			ifNotNil: [:directory | self handleDroppedItem: directory event: anEvent]
			ifNil: [(FileStream requestDropStream: i) ifNotNil: [:stream |
				[self handleDroppedItem: stream event: anEvent] ensure: [stream close]]]].
				
]

{ #category : #accessing }
PasteUpMorph >> dumpPresenter [
	"Dump my current presenter"
	presenter := nil.
]

{ #category : #'world state' }
PasteUpMorph >> embeddedProjectDisplayMode [

	"#naked - the embedded project/world is just a pasteup in the outer p/w
	#window - the embedded p/w is in a system window in the outer p/w
	#frame - the embedded p/w is in a green frame and clipped
	#scaled - the embedded p/w is in a green frame and scaled to fit"

	^#scaled

]

{ #category : #flaps }
PasteUpMorph >> enableGlobalFlaps [ 
	"Restore saved global flaps, or obtain brand-new system defaults if necessary"

	Flaps globalFlapTabs. 		 "If nil, creates new ones"
	self addGlobalFlaps 			 "put them on screen"
]

{ #category : #'world state' }
PasteUpMorph >> endDrawing: evt [
	"If painting is already underway
	in the receiver, finish and save it."
	| editor |
	(editor := self sketchEditorOrNil) ifNotNil:[
		editor save: evt.
		Cursor normal show.
	].
]

{ #category : #'world state' }
PasteUpMorph >> exit [

	Project current exit

]

{ #category : #'world menu' }
PasteUpMorph >> expandAll [
	"Expand all windows"
	(SystemWindow windowsIn: self satisfying: [:w | w isCollapsed])
		reverseDo: [:w | w collapseOrExpand.  self displayWorld]
]

{ #category : #geometry }
PasteUpMorph >> extent: aPoint [

	super extent: aPoint.
	worldState ifNotNil: [
		worldState viewBox ifNotNil: [
			worldState canvas: nil.
			worldState viewBox: bounds
		].
	].
]

{ #category : #'world menu' }
PasteUpMorph >> extractScreenRegion: poly andPutSketchInHand: hand [
	"The user has specified a polygonal area of the Display.
	Now capture the pixels from that region, and put in the hand as a Sketch."
	| screenForm outline topLeft innerForm exterior |
	outline := poly shadowForm.
	topLeft := outline offset.
	exterior := (outline offset: 0@0) anyShapeFill reverse.
	screenForm := Form fromDisplay: (topLeft extent: outline extent).
	screenForm eraseShape: exterior.
	innerForm := screenForm trimBordersOfColor: Color transparent.
	self currentHand showTemporaryCursor: nil.
	innerForm isAllWhite ifFalse:
		[hand attachMorph: (self drawingClass withForm: innerForm)]
]

{ #category : #'visual properties' }
PasteUpMorph >> fillStyle: aFormOrColorOrFillStyle [

	^ super fillStyle: (aFormOrColorOrFillStyle isForm
		ifTrue: [InfiniteForm with: aFormOrColorOrFillStyle]
		ifFalse: [aFormOrColorOrFillStyle isColor
			ifTrue: [SolidFillStyle color: aFormOrColorOrFillStyle]
			ifFalse: [aFormOrColorOrFillStyle]])
]

{ #category : #'events-processing' }
PasteUpMorph >> filterEvent: mouseOrKeyboardEvent for: anObject [

	"1) Mouse shortcuts"
	mouseOrKeyboardEvent isMouse ifTrue: [
	
		"Only accept mouse down, no up."
		mouseOrKeyboardEvent isMouseDown
			ifFalse: [^ mouseOrKeyboardEvent].
	
		mouseOrKeyboardEvent blueButtonPressed
			ifTrue: [	self tryInvokeHalo: mouseOrKeyboardEvent]
			ifFalse: [mouseOrKeyboardEvent controlKeyPressed
				ifTrue: [self tryInvokeMetaMenu: mouseOrKeyboardEvent]].

		^ mouseOrKeyboardEvent].

	"2) Keyboard shortcuts"
	mouseOrKeyboardEvent isKeyboard ifTrue: [

		"Delegate keyboard shortcuts to my docking bars."
		self submorphsDo: [:ea | ea isDockingBar ifTrue: [
			ea filterEvent: mouseOrKeyboardEvent for: anObject. "No support for converting events here!"
			mouseOrKeyboardEvent wasIgnored ifTrue: [^ mouseOrKeyboardEvent "early out"]]].
	
		"Only accept key strokes as shortcuts, no down/up."
		mouseOrKeyboardEvent isKeystroke
			ifFalse: [^ mouseOrKeyboardEvent].

		self tryInvokeKeyboardShortcut: mouseOrKeyboardEvent.
	
		^ mouseOrKeyboardEvent].
	
	"Should not be necessary if this filter is correctly configured."
	^ mouseOrKeyboardEvent
]

{ #category : #'world menu' }
PasteUpMorph >> findAChangeSorter: evt [
	"Locate a change sorter, open it, and bring it to the front.  Create one if necessary"

	self findAWindowSatisfying:
		[:aWindow | (aWindow model isMemberOf: ChangeSorter) or:
				[aWindow model isKindOf: DualChangeSorter]] orMakeOneUsing: [DualChangeSorter open]
]

{ #category : #'world menu' }
PasteUpMorph >> findAFileList: evt [ 
	"Bring a file list to the foreground, reusing an existing one if possible."
	self
		findAWindowSatisfying: [ : aWindow | (aWindow model class = FileList) and: [ aWindow model hasUnacceptedEdits not ] ]
		orMakeOneUsing: [ FileList prototypicalToolWindow openInWorld ]
]

{ #category : #'world menu' }
PasteUpMorph >> findAMessageNamesWindow: evt [
	"Locate a MessageNames tool, open it, and bring it to the front.  Create one if necessary"

	self findAWindowSatisfying:
		[:aWindow | aWindow model isKindOf: MessageNames] orMakeOneUsing: [MessageNames openMessageNames]
]

{ #category : #'world menu' }
PasteUpMorph >> findAPreferencesPanel: evt [
	"Locate a Preferences Panel, open it, and bring it to the front.  Create one if necessary"
	Smalltalk at: #PreferenceBrowser ifPresent:[:pb|
		self findAWindowSatisfying:[:aWindow | aWindow model isKindOf: pb]
			orMakeOneUsing:[pb open]
	].
]

{ #category : #'world menu' }
PasteUpMorph >> findATranscript: evt [
	"Locate a transcript, open it, and bring it to the front.  Create one if necessary"

	self findAWindowSatisfying:
		[:aWindow | aWindow model == Transcript] orMakeOneUsing: [Transcript openLabel: 'Transcript']
]

{ #category : #'world menu' }
PasteUpMorph >> findAWindowSatisfying: qualifyingBlock orMakeOneUsing: makeBlock [ 
	"Locate a window satisfying a block, open it, and bring it to the front.  Create one if necessary, by using the makeBlock"

	submorphs do:
		[:aMorph | | aWindow | 
		(((aWindow := aMorph renderedMorph) isSystemWindow) 
		and: [qualifyingBlock value: aWindow]) ifTrue:
			[aWindow isCollapsed ifTrue: [aWindow expand].
			self addMorphFront: aWindow.
			aWindow beKeyWindow.
			^self]].
	"None found, so create one"
	makeBlock value
]

{ #category : #'world menu' }
PasteUpMorph >> findDirtyBrowsers: evt [ 
	"Present a menu of window titles for browsers with changes,
	and activate the one that gets chosen."

	| menu |
	menu := MenuMorph new.
	(SystemWindow windowsIn: self
		satisfying: [:w | (w model isKindOf: Browser) and: [w model canDiscardEdits not]]) 
			do: 
				[:w | 
				menu 
					add: w label
					target: w
					action: #beKeyWindow].
	menu submorphs notEmpty ifTrue: [menu popUpEvent: evt in: self]
]

{ #category : #'world menu' }
PasteUpMorph >> findDirtyWindows: evt [ 
	"Present a menu of window titles for all windows with changes,
	and activate the one that gets chosen."

	| menu |
	menu := MenuMorph new.
	(SystemWindow windowsIn: self
		satisfying: [:w | w model canDiscardEdits not]) do: 
				[:w | 
				menu 
					add: w label
					target: w
					action: #beKeyWindow].
	menu submorphs notEmpty ifTrue: [menu popUpEvent: evt in: self]
]

{ #category : #'world menu' }
PasteUpMorph >> findWindow: evt [
	"Present a menu names of windows and naked morphs, and activate the one that gets chosen.  Collapsed windows appear below line, expand if chosen; naked morphs appear below second line; if any of them has been given an explicit name, that is what's shown, else the class-name of the morph shows; if a naked morph is chosen, bring it to front and have it don a halo."
	| menu expanded collapsed nakedMorphs |
	menu := MenuMorph new.
	expanded := SystemWindow windowsIn: self satisfying: [:w | w isCollapsed not].
	collapsed := SystemWindow windowsIn: self satisfying: [:w | w isCollapsed].
	nakedMorphs := self submorphsSatisfying:
		[:m | (m isSystemWindow not and: [(m isStickySketchMorph) not]) and:
			[(m isFlapTab) not]].
	(expanded isEmpty & (collapsed isEmpty & nakedMorphs isEmpty)) ifTrue: [^ Beeper beep].
	(expanded sort: [:w1 :w2 | w1 label caseInsensitiveLessOrEqual: w2 label]) do:
		[:w | menu add: (w label contractTo: 80) target: w action: #beKeyWindow.
			w model canDiscardEdits ifFalse: [menu lastItem color: Color red]].
	(expanded isEmpty | (collapsed isEmpty & nakedMorphs isEmpty)) ifFalse: [menu addLine].
	(collapsed sort: [:w1 :w2 | w1 label caseInsensitiveLessOrEqual: w2 label]) do: 
		[:w | menu add: (w label contractTo: 80) target: w action: #collapseOrExpand.
		w model canDiscardEdits ifFalse: [menu lastItem color: Color red]].
	nakedMorphs isEmpty ifFalse: [menu addLine].
	(nakedMorphs sort: [:w1 :w2 | w1 nameForFindWindowFeature caseInsensitiveLessOrEqual: w2 nameForFindWindowFeature]) do:
		[:w | menu add: (w nameForFindWindowFeature contractTo: 80) target: w action: #comeToFrontAndAddHalo].
	menu addTitle: 'find window' translated.
	
	menu popUpEvent: evt in: self.
]

{ #category : #'project state' }
PasteUpMorph >> firstHand [

	^ worldState hands first
]

{ #category : #'objects from disk' }
PasteUpMorph >> fixUponLoad: aProject seg: anImageSegment [ 
	"We are in an old project that is being loaded from disk.
	Fix up conventions that have changed."
	| weakMessage |
	self isWorldMorph
		ifTrue: [(self valueOfProperty: #soundAdditions)
				ifNotNil: [:additions | SampledSound assimilateSoundsFrom: additions]].
	self actionMap
		ifNotNil: [:aDictionary | 
			weakMessage := aDictionary
						at: #aboutToLeaveWorld
						ifAbsent: [].
			weakMessage
				ifNotNil: [weakMessage selector = #removeModalWindow
						ifTrue: [weakMessage receiver: nil]]].
	^ super fixUponLoad: aProject seg: anImageSegment
]

{ #category : #accessing }
PasteUpMorph >> flapTab [
	"Answer the tab affilitated with the receiver.  Normally every flap tab is expected to have a PasteUpMorph which serves as its 'referent.'"

	| ww |
	self isFlap ifFalse: [^ nil].
	ww := self presenter associatedMorph ifNil: [self].
	^ ww flapTabs
		detect: [:any| any referent == self]
		ifNone: [nil]
]

{ #category : #flaps }
PasteUpMorph >> flapTabs [
	^ self submorphs select:[:m| m isFlapTab]
]

{ #category : #'world state' }
PasteUpMorph >> flashRects: rectangleList color: aColor [
	"For testing. Flashes the given list of rectangles on the Display so you can watch incremental redisplay at work."
	"Details: Uses two reverses so that the display is restored to its original state. This is necessary when in deferred update mode."

	| blt |
	blt := (BitBlt toForm: Display)
		sourceForm: nil;
		sourceOrigin: 0@0;
		clipRect: self viewBox;
		combinationRule: Form reverse.
	rectangleList do: [:r | | screenRect |
		screenRect := r translateBy: self viewBox origin.
		blt destRect: screenRect; copyBits.
		Display forceToScreen: screenRect; forceDisplayUpdate.
		(Delay forMilliseconds: 15) wait.
		blt destRect: screenRect; copyBits.
		Display forceToScreen: screenRect; forceDisplayUpdate].

]

{ #category : #'geometry testing' }
PasteUpMorph >> fullContainsPoint: pt [
	"The world clips its children"

	worldState ifNil: [^super fullContainsPoint: pt].
	^bounds containsPoint: pt


]

{ #category : #'world state' }
PasteUpMorph >> fullRepaintNeeded [

	worldState doFullRepaint.
	SystemWindow windowsIn: self
		satisfying: [:w | w makeMeVisible. false].


]

{ #category : #'world menu' }
PasteUpMorph >> getWorldMenu: aSymbol [
	^(TheWorldMenu new
		world: self
		project: (self project ifNil: [Project current])       "mvc??"
		hand: self primaryHand) perform: aSymbol
]

{ #category : #'world state' }
PasteUpMorph >> goBack [

	Project returnToPreviousProject.

]

{ #category : #'world menu' }
PasteUpMorph >> grabDrawingFromScreen: evt [
	"Allow the user to specify a rectangular area of the Display, capture the pixels from that area, and use them to create a new drawing morph. Attach the result to the hand."
	| m |
	m := self drawingClass new form: Form fromUser.
	evt hand position: Sensor cursorPoint.  "update hand pos after Sensor loop in fromUser"
	evt hand attachMorph: m.
]

{ #category : #'world menu' }
PasteUpMorph >> grabFloodFromScreen: evt [
	"Allow the user to plant a flood seed on the Display, and create a new drawing morph from the resulting region. Attach the result to the hand."
	| screenForm exterior p1 box |
	p1 := Cursor crossHair showWhile: [Sensor waitButton].
	box := Display floodFill: Color transparent at: p1.
	exterior := ((Display copy: box) makeBWForm: Color transparent) reverse.
	self world invalidRect: box; displayWorldSafely.
	(box area > (Display boundingBox area // 2))
		ifTrue: [^ UIManager default notify: 'Sorry, the region was too big'].
	(exterior deepCopy reverse anyShapeFill reverse)  "save interior bits"
		displayOn: exterior at: 0@0 rule: Form and.
	screenForm := Form fromDisplay: box.
	screenForm eraseShape: exterior.
	screenForm isAllWhite ifFalse:
		[evt hand attachMorph: (self drawingClass withForm: screenForm)]
]

{ #category : #'world menu' }
PasteUpMorph >> grabLassoFromScreen: evt [
	"Allow the user to specify a polygonal area of the Display, capture the pixels from that area, and use them to create a new drawing morph. Attach the result to the hand."

	self extractScreenRegion: (PolygonMorph fromHandFreehand: evt hand)
		andPutSketchInHand: evt hand

]

{ #category : #'world menu' }
PasteUpMorph >> grabRubberBandFromScreen: evt [
	"Allow the user to specify a polygonal area of the Display, capture the pixels from that area, and use them to create a new drawing morph. Attach the result to the hand."

	self extractScreenRegion: (PolygonMorph fromHand: evt hand)
		andPutSketchInHand: evt hand
]

{ #category : #display }
PasteUpMorph >> gradientFillColor: aColor [
	"For backwards compatibility with GradientFillMorph"

	self flag: #fixThis.
	self useGradientFill.
	self fillStyle colorRamp: {0.0 -> self fillStyle colorRamp first value. 1.0 -> aColor}.
	self setAsBackground: self fillStyle.
	self changed
]

{ #category : #gridding }
PasteUpMorph >> gridModulus [

	^ self gridSpec extent
]

{ #category : #gridding }
PasteUpMorph >> gridModulus: newModulus [

	self gridSpecPut: (self gridOrigin extent: newModulus).
	self changed
]

{ #category : #gridding }
PasteUpMorph >> gridOrigin [

	^ self gridSpec origin
]

{ #category : #gridding }
PasteUpMorph >> gridOrigin: newOrigin [

	^ self gridSpecPut: (newOrigin extent: self gridModulus)
]

{ #category : #geometry }
PasteUpMorph >> gridPoint: ungriddedPoint [

	self griddingOn ifFalse: [^ ungriddedPoint].
	^ (ungriddedPoint - self position - self gridOrigin grid: self gridModulus)
					+ self position + self gridOrigin
]

{ #category : #gridding }
PasteUpMorph >> gridSpec [
	"Gridding rectangle provides origin and modulus"

	^ self valueOfProperty: #gridSpec ifAbsent: [0@0 extent: 8@8]
]

{ #category : #gridding }
PasteUpMorph >> gridSpecPut: newSpec [
	"Gridding rectangle provides origin and modulus"

	^ self setProperty: #gridSpec toValue: newSpec
]

{ #category : #gridding }
PasteUpMorph >> gridVisible [

	^ self hasProperty: #gridVisible
]

{ #category : #gridding }
PasteUpMorph >> gridVisibleOnOff [

	self setProperty: #gridVisible toValue: self gridVisible not.
	self changed
]

{ #category : #gridding }
PasteUpMorph >> gridVisibleString [
	"Answer a string to be used in a menu offering the opportunity 
	to show or hide the grid"
	^ (self gridVisible
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'grid visible when gridding' translated
]

{ #category : #gridding }
PasteUpMorph >> griddingOn [

	^ griddingOn ifNil: [false]
]

{ #category : #gridding }
PasteUpMorph >> griddingOnOff [

	griddingOn := self griddingOn not.
	self changed
]

{ #category : #gridding }
PasteUpMorph >> griddingString [
	"Answer a string to use in a menu offering the user the 
	opportunity to start or stop using gridding"
	^ (self griddingOn
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'use gridding' translated
]

{ #category : #'world state' }
PasteUpMorph >> haloMorphs [
	^ self hands collect:[:h| h halo] thenSelect:[:halo| halo notNil]
]

{ #category : #'event handling' }
PasteUpMorph >> handleDroppedItem: anItem event: anEvent [
	
	(ExternalDropHandler lookupExternalDropHandler: anItem)
		ifNotNil: [:handler | handler handle: anItem in: self dropEvent: anEvent].
]

{ #category : #'event handling' }
PasteUpMorph >> handlesKeyboard: evt [
	^self isWorldMorph or:[evt keyCharacter == Character tab and:[self tabAmongFields]]
]

{ #category : #'event handling' }
PasteUpMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #'project state' }
PasteUpMorph >> hands [

	^ worldState hands
]

{ #category : #'project state' }
PasteUpMorph >> handsDo: aBlock [

	^ worldState ifNotNil: [ worldState handsDo: aBlock ]
]

{ #category : #'project state' }
PasteUpMorph >> handsReverseDo: aBlock [

	^ worldState ifNotNil: [ worldState handsReverseDo: aBlock ]
]

{ #category : #Nebraska }
PasteUpMorph >> hasRemoteServer [
	^self remoteServer notNil
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> hasTransferMorphConverter [
	^ self transferMorphConverter ~= #yourself
]

{ #category : #misc }
PasteUpMorph >> heightForThumbnails [
	^ self valueOfProperty: #heightForThumbnails ifAbsent: [50]
]

{ #category : #misc }
PasteUpMorph >> hideFlapsOtherThan: aFlapTab ifClingingTo: anEdgeSymbol [
	"Hide flaps on the given edge unless they are the given one"

	self flapTabs do:
		[:aTab | (aTab edgeToAdhereTo == anEdgeSymbol)
			ifTrue:
				[aTab  == aFlapTab
					ifFalse:
						[aTab hideFlap]]]
]

{ #category : #misc }
PasteUpMorph >> hideViewerFlaps [
	self flapTabs do:[:aTab |
		(aTab isKindOf: ViewerFlapTab) ifTrue:[aTab hideFlap]]
]

{ #category : #misc }
PasteUpMorph >> hideViewerFlapsOtherThanFor: aPlayer [
	self flapTabs do:
		[:aTab | (aTab isKindOf: ViewerFlapTab)
			ifTrue:
				[aTab scriptedPlayer == aPlayer
					ifFalse:
						[aTab hideFlap]]]
]

{ #category : #thumbnail }
PasteUpMorph >> icon [
	"Answer a form with an icon to represent the receiver"
	^ self isWorldMorph
		ifTrue: [MenuIcons homeIcon]
		ifFalse: [MenuIcons projectIcon]
]

{ #category : #options }
PasteUpMorph >> indicateCursor [
	^ indicateCursor == true
]

{ #category : #options }
PasteUpMorph >> indicateCursor: aBoolean [
	indicateCursor := aBoolean.
	self changed.
]

{ #category : #'menu & halo' }
PasteUpMorph >> indicateCursorString [
	"Answer the string to be shown in a menu to represent the  
	whether-to-indicate-cursor status"
	^ (self indicateCursor
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'indicate cursor' translated
]

{ #category : #'world state' }
PasteUpMorph >> initForProject: aWorldState [

	worldState := aWorldState.
	self viewBox: Display boundingBox.  
	self color: Preferences defaultWorldColor.
	self addHand: HandMorph new.
	self setProperty: #automaticPhraseExpansion toValue: true.
	self setProperty: #optimumExtentFromAuthor toValue: Display extent.
	self wantsMouseOverHalos: Preferences mouseOverHalos.
	self borderWidth: 0.
	model := nil.

]

{ #category : #initialization }
PasteUpMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	cursor := 1.
	padding := 3.
	self enableDragNDrop.
	self isWorldMorph
		ifTrue: [self setProperty: #automaticPhraseExpansion toValue: true].
	self clipSubmorphs: true.
	self initializeKeyboardShortcuts.
	self initializeMouseShortcuts.
]

{ #category : #'world menu' }
PasteUpMorph >> initializeDesktopCommandKeySelectors [
	"Provide the starting settings for desktop command key selectors.  Answer the dictionary."

	"ActiveWorld initializeDesktopCommandKeySelectors"
	| dict |
	dict := IdentityDictionary new.
	self defaultDesktopCommandKeyTriplets do: [:trip |
		| messageSend |
		messageSend := MessageSend receiver: trip second selector: trip third.
		dict at: trip first put: messageSend].
	self setProperty: #commandKeySelectors toValue: dict.
	^ dict
]

{ #category : #initialization }
PasteUpMorph >> initializeKeyboardShortcuts [
	"Install an event capture filter to add shortcuts for global operations like opening a tool."
	
	PasteUpMorph globalCommandKeysEnabled
		ifTrue: [self addKeyboardShortcuts].
]

{ #category : #initialization }
PasteUpMorph >> initializeMouseShortcuts [
	
	self addMouseShortcuts.
]

{ #category : #'parts bin' }
PasteUpMorph >> initializeToStandAlone [
	"Answer an instance of the receiver suitable for placing in a parts bin for authors"
	
	self initialize.
	self color: Color green muchLighter;  extent: 100 @ 80; borderColor: (Color r: 0.645 g: 0.935 b: 0.161).
	self extent: 300 @ 240.
	self beSticky
]

{ #category : #misc }
PasteUpMorph >> innocuousName [
	^ (self isFlap)
		ifTrue:
			['flap' translated]
		ifFalse:
			[super innocuousName]
]

{ #category : #'world state' }
PasteUpMorph >> install [

	owner := nil.	"since we may have been inside another world previously"
	
	submorphs do: [:ss | ss owner isNil ifTrue: [ss privateOwner: self]].
	"Transcript that was in outPointers and then got deleted."
	self viewBox: Display boundingBox.
	EventSensor default flushEvents.
	worldState handsDo: [:h | h initForEvents].
	self installFlaps.
	self borderWidth: 0.	"default"
	(Preferences showSecurityStatus 
		and: [SecurityManager default isInRestrictedMode]) 
			ifTrue: 
				[self
					borderWidth: 2;
					borderColor: Color red].
	self presenter allExtantPlayers do: [:player | player prepareToBeRunning].
	SystemWindow noteTopWindowIn: self.
]

{ #category : #'WiW support' }
PasteUpMorph >> installAsActiveSubprojectIn: enclosingWorld at: newBounds titled: aString [ 
    | window howToOpen tm boundsForWorld |
    howToOpen := self embeddedProjectDisplayMode.
    "#scaled may be the only one that works at the moment"
    submorphs do: [:ss | ss owner isNil ifTrue: [ss privateOwner: self]].
    "Transcript that was in outPointers and then got deleted."
    boundsForWorld := howToOpen == #naked ifTrue: [newBounds] ifFalse: [bounds].
    worldState canvas: nil.
    worldState viewBox: boundsForWorld.
    self bounds: boundsForWorld.

    "self viewBox: Display boundingBox."
    "worldState handsDo: [:h | h initForEvents]."
    self installFlaps.

    "SystemWindow noteTopWindowIn: self."
    "self displayWorldSafely."
    howToOpen == #naked ifTrue: [enclosingWorld addMorphFront: self].
    howToOpen == #window 
        ifTrue: 
            [window := (SystemWindow labelled: aString) model: self.
            window addMorph: self frame: (0 @ 0 extent: 1.0 @ 1.0).
            window openInWorld: enclosingWorld].
    howToOpen == #frame 
        ifTrue: 
            [window := (AlignmentMorphBob1 new)
                        minWidth: 100;
                        minHeight: 100;
                        borderWidth: 8;
                        borderColor: Color green;
                        bounds: newBounds.
            window addMorph: self.
            window openInWorld: enclosingWorld].
    howToOpen == #scaled 
        ifTrue: 
            [self position: 0 @ 0.
            window := (EmbeddedWorldBorderMorph new)
                        minWidth: 100;
                        minHeight: 100;
                        borderWidth: 8;
                        borderColor: Color green;
                        bounds: newBounds.
            tm := BOBTransformationMorph new.
            window addMorph: tm.
            tm addMorph: self.
            window openInWorld: enclosingWorld.
            tm changeWorldBoundsToShow: bounds.
            self arrangeToStartSteppingIn: enclosingWorld
            "tm scale: (tm width / self width min: tm height / self height) asFloat."]
]

{ #category : #'WiW support' }
PasteUpMorph >> installAsActiveSubprojectIn: enclosingWorld titled: aString [

    | opt newWidth |

    opt := self optimumExtentFromAuthor.
    (opt x > (enclosingWorld width * 0.7) or: 
            [opt y > (enclosingWorld height * 0.7)]) ifTrue: [
        newWidth := enclosingWorld width // 2.
        opt := newWidth @ (opt y * newWidth / opt x) truncated
    ].
    ^self 
        installAsActiveSubprojectIn: enclosingWorld 
        at: (enclosingWorld topLeft + (enclosingWorld extent - opt // 2) extent: opt) 
        titled: aString
]

{ #category : #'world state' }
PasteUpMorph >> installFlaps [
	"Get flaps installed within the bounds of the receiver"

	| localFlapTabs |
	Project current assureFlapIntegrity.
	self addGlobalFlaps.
	localFlapTabs := self localFlapTabs.
	localFlapTabs do: [:each | each visible: false].

	Preferences eToyFriendly ifTrue: [
		ProgressInitiationException display: 'Building Viewers...' translated
			during: [:bar |
				localFlapTabs keysAndValuesDo: [:i :each |
					each adaptToWorld.
					each visible: true.
					each unhibernate.
					self changed.
					bar value: i / self localFlapTabs size]].
	] ifFalse: [
		localFlapTabs keysAndValuesDo: [:i :each |
			each adaptToWorld.
			each visible: true.
			self changed]].

	self assureFlapTabsFitOnScreen.
	self bringTopmostsToFront
]

{ #category : #'change reporting' }
PasteUpMorph >> invalidRect: damageRect from: aMorph [
	"Clip damage reports to my bounds, since drawing is clipped to my bounds."
	self isWorldMorph
		ifTrue: [worldState recordDamagedRect: damageRect].
	^super invalidRect: damageRect from: aMorph
]

{ #category : #'world menu' }
PasteUpMorph >> invokeWorldMenu: evt [
	"Put up the world menu, triggered by the passed-in event.  But don't do it if the eToyFriendly preference is set to true."

	Preferences eToyFriendly ifFalse:
		[self putUpWorldMenu: evt]
]

{ #category : #testing }
PasteUpMorph >> isEasySelecting [
"This is to isolate easySelection predicate. 
Selectors in holders make no sense so we are limiting easy selection to the worldMorph.
It would also make sense in playfield so feel free to adjust this predicate.  Selection can always be forced by using the shift before mouse down."

^ self isWorldMorph and: [  Preferences easySelection ]
]

{ #category : #'parts bin' }
PasteUpMorph >> isPartsBin [
	^ isPartsBin == true
]

{ #category : #options }
PasteUpMorph >> isPartsBin: aBoolean [
	isPartsBin := aBoolean
]

{ #category : #'menu & halo' }
PasteUpMorph >> isPartsBinString [
	"Answer the string to be shown in a menu to represent the 
	parts-bin status"
	^ (self isPartsBin
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'parts bin' translated
]

{ #category : #classification }
PasteUpMorph >> isPlayfieldLike [
	^ true
]

{ #category : #'project state' }
PasteUpMorph >> isStepping: aMorph [
	^ worldState isStepping: aMorph
]

{ #category : #'project state' }
PasteUpMorph >> isStepping: aMorph selector: aSelector [
	^ worldState isStepping: aMorph selector: aSelector
]

{ #category : #classification }
PasteUpMorph >> isWorldMorph [

	^ worldState notNil
]

{ #category : #'world state' }
PasteUpMorph >> jumpToProject [

	Project current jumpToProject.

]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> justDroppedInto: aMorph event: anEvent [
	"This message is sent to a dropped morph after it has been dropped on--and been accepted by--a drop-sensitive morph"

	super justDroppedInto: aMorph event: anEvent.
	self isPartsBin ifTrue: [self setPartsBinStatusTo: true]  "gets some things right about the subtle case of dropping a parts bin"

]

{ #category : #'event handling' }
PasteUpMorph >> keyStroke: anEvent [
	"A keystroke has been made.  Service event handlers and, if it's a keystroke presented to the world, dispatch it to #unfocusedKeystroke:"

	| selected |
	super keyStroke: anEvent.  "Give event handlers a chance"

	selected := self selectedObject.
	selected isNil
		ifFalse:[ selected moveOrResizeFromKeystroke: anEvent ].

	(anEvent keyCharacter == Character tab) ifTrue:
		[self tabAmongFields
			ifTrue:[^ self tabHitWithEvent: anEvent]].
	self isWorldMorph ifTrue:
		[self keystrokeInWorld: anEvent]
]

{ #category : #'world menu' }
PasteUpMorph >> keyboardNavigationHandler [
	"Answer the receiver's existing keyboardNavigationHandler, or nil if none."

	| aHandler |
	aHandler := self valueOfProperty: #keyboardNavigationHandler ifAbsent: [^ nil].
	(aHandler hasProperty: #moribund) ifTrue:  "got clobbered in another project"
		[self removeProperty: #keyboardNavigationHander.
		^ nil].
	^ aHandler
]

{ #category : #'world menu' }
PasteUpMorph >> keyboardNavigationHandler: aHandler [
	"Set the receiver's keyboard navigation handler as indicated.  A nil argument means to remove the handler"

	aHandler
		ifNil:
			[self removeProperty: #keyboardNavigationHandler]
		ifNotNil:
			[self setProperty: #keyboardNavigationHandler toValue: aHandler]
]

{ #category : #'world menu' }
PasteUpMorph >> keystrokeInWorld: evt [
	"A keystroke was hit when no keyboard focus was set, so it is sent here to the world instead."

	|  aChar isCmd ascii |
	aChar := evt keyCharacter.
	(ascii := aChar asciiValue) = Character escape asciiValue ifTrue:
		[evt commandKeyPressed ifFalse: [^ self putUpWorldMenuFromEscapeKey]].
	(evt controlKeyPressed not
		and: [(#(1 4 8 28 29 30 31 32) includes: ascii)  "home, end, backspace, arrow keys, space"
			and: [self keyboardNavigationHandler notNil]])
				ifTrue: [self keyboardNavigationHandler navigateFromKeystroke: aChar].

	isCmd := evt commandKeyPressed and: [Preferences cmdKeysInText].
	(evt commandKeyPressed and: [Preferences eToyFriendly])
			ifTrue:
				[(aChar == $W) ifTrue: [^ self putUpWorldMenu: evt]].
	(isCmd and: [Preferences honorDesktopCmdKeys]) ifTrue:
		[^ self dispatchCommandKeyInWorld: aChar event: evt].

	"It was unhandled. Remember the keystroke."
	self lastKeystroke: evt keyString.
	self triggerEvent: #keyStroke
]

{ #category : #accessing }
PasteUpMorph >> lastKeystroke [
	"Answer the last keystroke fielded by the receiver"

	^ self valueOfProperty: #lastKeystroke ifAbsent: ['']
]

{ #category : #accessing }
PasteUpMorph >> lastKeystroke: aString [
	"Remember the last keystroke fielded by the receiver"

	^ self setProperty: #lastKeystroke toValue: aString
]

{ #category : #layout }
PasteUpMorph >> laySubpartsOutInOneRow [
	| aPosition |
	aPosition := 0 @ padding.
	submorphs do:
	[:aMorph |
		aMorph position: (aPosition + (padding @ 0)).
		aPosition := aMorph topRight]
]

{ #category : #layout }
PasteUpMorph >> layoutChanged [
	"The receiver's layout changed; inform above and below"
	super layoutChanged.
	(self valueOfProperty: #SqueakPage) ifNotNil: [
		self setProperty: #pageDirty toValue: true].
		"I am the morph of a SqueakPage, I have changed and 
		need to be written out again"

]

{ #category : #'project state' }
PasteUpMorph >> listOfSteppingMorphs [
	^ worldState listOfSteppingMorphs

"self currentWorld listOfSteppingMorphs"
]

{ #category : #flaps }
PasteUpMorph >> localFlapTabs [
	"Answer a list of local flap tabs in the current project"

	| globalList aList |
	globalList := Flaps globalFlapTabsIfAny.
	aList := OrderedCollection new.
	submorphs do:
		[:m | | aFlapTab |
		((m isFlapTab) and: [(globalList includes: m) not])
			ifTrue:
				[aList add: m]
			ifFalse:
				[((m isFlap) and:
					[(aFlapTab := m submorphs detect: [:n | n isFlapTab] ifNone: [nil]) notNil])
						ifTrue:
							[aList add: aFlapTab]]].
	^ aList
]

{ #category : #'world menu' }
PasteUpMorph >> makeNewDrawing: evt [
	^self makeNewDrawing: evt at: evt position
]

{ #category : #'world menu' }
PasteUpMorph >> makeNewDrawing: evt at: aPoint [
	"make a new drawing, triggered by the given event, with the painting area centered around the given point"

	| w newSketch newPlayer sketchEditor aPalette rect aPaintBox aPaintTab aWorld |
	w := self world.
	w assureNotPaintingElse: [^ self].
	rect := self paintingBoundsAround: aPoint.
	aPalette := self standardPalette.
	aPalette ifNotNil: [aPalette showNoPalette; layoutChanged].
	w prepareToPaint.

	newSketch := self drawingClass new.
	Smalltalk at: #UnscriptedPlayer ifPresent:[:aClass|
		newSketch player: (newPlayer := aClass newUserInstance).
		newPlayer costume: newSketch.
	].
	newSketch nominalForm: (Form extent: rect extent depth: w assuredCanvas depth).
	newSketch bounds: rect.
	sketchEditor := SketchEditorMorph new.
	w addMorphFront: sketchEditor.
	sketchEditor initializeFor: newSketch inBounds: rect pasteUpMorph: self.
	sketchEditor
		afterNewPicDo: [:aForm :aRect | | tfx whereToPresent |
			whereToPresent := self presenter.
			newSketch form: aForm.
			tfx := self transformFrom: w.
			newSketch position: (tfx globalPointToLocal: aRect origin).
			newSketch rotationStyle: sketchEditor rotationStyle.
			newSketch forwardDirection: sketchEditor forwardDirection.

			newPlayer ifNotNil:[newPlayer setHeading: sketchEditor forwardDirection].
			(aPaintTab := (aWorld := self world) paintingFlapTab)
				ifNotNil:[aPaintTab hideFlap]
				ifNil:[(aPaintBox := aWorld paintBox) ifNotNil:[aPaintBox delete]].

			self addMorphFront: (newPlayer ifNil:[newSketch] ifNotNil:[newPlayer costume]).
			w startSteppingSubmorphsOf: newSketch.
			whereToPresent drawingJustCompleted: newSketch]
		 ifNoBits:[
			(aPaintTab := (aWorld := self world) paintingFlapTab)
				ifNotNil:[aPaintTab hideFlap]
				ifNil:[(aPaintBox := aWorld paintBox) ifNotNil:[aPaintBox delete]].
			aPalette ifNotNil: [aPalette showNoPalette].]
]

{ #category : #painting }
PasteUpMorph >> makeNewDrawingWithin [
	"Start a painting session in my interior which will result in a new SketchMorph being created as one of my submorphs"

	| evt |
	evt := MouseEvent new setType: nil position: self center buttons: 0 hand: self world activeHand.
	self makeNewDrawing: evt
]

{ #category : #misc }
PasteUpMorph >> maxHeightToAvoidThumbnailing [
	^ self valueOfProperty: #maxHeightToAvoidThumbnailing ifAbsent: [80]
]

{ #category : #misc }
PasteUpMorph >> maximumThumbnailWidth [
	^ self valueOfProperty: #maximumThumbnailWidth ifAbsent: [200 min: (self width - 10)]
]

{ #category : #polymorph }
PasteUpMorph >> modalLockTo: aSystemWindow [
	"Don't lock the world! Lock the submorphs.
	The modal window gets opened afterwards so is OK."
	
	|lockStates|
	lockStates := IdentityDictionary new.
	self submorphsDo: [:m |
		lockStates at: m put: m isLocked.
		m lock].
	self
		setProperty: #submorphLockStates
		toValue: lockStates
]

{ #category : #polymorph }
PasteUpMorph >> modalUnlockFrom: aSystemWindow [
	"Don't unlock the world! Unlock the submorphs
	that were not originally locked."
	
	|lockStates|
	lockStates := self
		valueOfProperty: #submorphLockStates
		ifAbsent: [^self].
	self removeProperty: #submorphLockStates.
	lockStates keysAndValuesDo: [:m :locked |
		locked ifFalse: [m unlock]]
]

{ #category : #model }
PasteUpMorph >> model [
	"Return the model object for this world. If the world has no model, then create one."

	self createCustomModel.
	^ model
]

{ #category : #accessing }
PasteUpMorph >> modelOrNil [
	"Return the model object for this world, or nil if it doesn't have one."

	^ model

]

{ #category : #'user interface' }
PasteUpMorph >> modelWakeUp [
	"I am the model of a SystemWindow, that has just been activated"

	| aWindow |
	owner isNil ifTrue: [^self].	"Not in Morphic world"
	(owner isKindOf: TransformMorph) ifTrue: [^self viewBox: self fullBounds].
	(aWindow := self containingWindow) ifNotNil: 
			[self viewBox = aWindow panelRect 
				ifFalse: [self viewBox: aWindow panelRect]]
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> morphToDropForTransferMorph: aTransferMorph [ 
	"aTransferMorph has been dragged directly onto the desktop.  TransferMorphs, by nature, are about transferring a 'logical object' from another source. Answer the Morph that should actually be dropped on to the desktop."
	^ self
		perform: self transferMorphConverter
		with: aTransferMorph
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> morphToDropFrom: aMorph [ 
	"Given a morph being carried by the hand, which the hand is about to drop, answer the actual morph to be deposited.  Normally this would be just the morph itself, but several unusual cases arise, which this method is designed to service."

	| aNail representee handy posBlock |
	handy := self primaryHand.
	posBlock := 
			[:z | | tempPos | 
			tempPos := handy position 
						- ((handy targetOffset - aMorph formerPosition) 
								* (z extent / aMorph extent)) rounded.
			self pointFromWorld: tempPos].
	self alwaysShowThumbnail 
		ifTrue: 
			[aNail := aMorph 
						representativeNoTallerThan: self maxHeightToAvoidThumbnailing
						norWiderThan: self maximumThumbnailWidth
						thumbnailHeight: self heightForThumbnails.
			aNail == aMorph 
				ifFalse: 
					[aMorph formerPosition: aMorph position.
					aNail position: (posBlock value: aNail)].
			^aNail].
	((aMorph isKindOf: MorphThumbnail) 
		and: [(representee := aMorph morphRepresented) owner isNil]) 
			ifTrue: 
				[representee position: (posBlock value: representee).
				^representee].
	self showingListView 
		ifTrue: 
			[^aMorph 
				listViewLineForFieldList: (self valueOfProperty: #fieldListSelectors)].
	(aMorph hasProperty: #newPermanentScript) 
		ifTrue: [^aMorph asEmptyPermanentScriptor].
	((aMorph isPhraseTileMorph) or: [aMorph isSyntaxMorph]) 
		ifFalse: [^aMorph morphToDropInPasteUp: self].
	aMorph userScriptSelector isEmptyOrNil 
		ifTrue: 
			["non-user"

			self automaticPhraseExpansion ifFalse: [^aMorph]].
	^aMorph morphToDropInPasteUp: self
]

{ #category : #'event handling' }
PasteUpMorph >> morphToGrab: event [
	"Return the morph to grab from a mouse down event. If none, return nil."
	self submorphsDo:[:m|
		((m rejectsEvent: event) not and:[m fullContainsPoint: event cursorPoint]) ifTrue:[^m].
	].
	^nil
]

{ #category : #'WiW support' }
PasteUpMorph >> morphicLayerNumber [

	self isFlap ifTrue:[^26]. 	"As navigators"
	^super morphicLayerNumber.
]

{ #category : #'submorphs-accessing' }
PasteUpMorph >> morphsInFrontOf: someMorph overlapping: aRectangle do: aBlock [
	"Include hands if the receiver is the World"
	self handsDo:[:m|
		m == someMorph ifTrue:["Try getting out quickly"
			owner ifNil:[^self].
			^owner morphsInFrontOf: self overlapping: aRectangle do: aBlock].
		"The hand only overlaps if it's not the hardware cursor"
		m needsToBeDrawn ifTrue:[
			(m fullBoundsInWorld intersects: aRectangle)
				ifTrue:[aBlock value: m]]].
	^super morphsInFrontOf: someMorph overlapping: aRectangle do: aBlock
]

{ #category : #'event handling' }
PasteUpMorph >> mouseDown: evt [
	"Handle a mouse down event."
	| grabbedMorph handHadHalos |

	(Preferences generalizedYellowButtonMenu
			and: [evt yellowButtonPressed])
		ifTrue: [^ self yellowButtonActivity: evt shiftPressed].

	grabbedMorph := self morphToGrab: evt.
	grabbedMorph ifNotNil:[
		grabbedMorph isSticky ifTrue:[^self].
		self isPartsBin ifFalse:[^evt hand grabMorph: grabbedMorph].
		grabbedMorph := grabbedMorph partRepresented duplicate.
		grabbedMorph restoreSuspendedEventHandler.
		(grabbedMorph fullBounds containsPoint: evt position) 
			ifFalse:[grabbedMorph position: evt position].
		"Note: grabbedMorph is ownerless after duplicate so use #grabMorph:from: instead"
		^ evt hand grabMorph: grabbedMorph from: self].

	(super handlesMouseDown: evt)
		ifTrue:[^super mouseDown: evt].

	handHadHalos := evt hand halo notNil.

	evt hand removeHalo. "shake off halos"
	evt hand releaseKeyboardFocus. "shake of keyboard foci"

	self submorphs
		select:[:each | each hasProperty: #morphHierarchy]
		thenDo:[:each | each delete].

	Preferences noviceMode
		ifTrue:[
			self submorphs
				select:[:each | (each isKindOf: MenuMorph) and:[each stayUp not]]
				thenDo:[:each | each delete].
		].

	(evt shiftPressed not
			and:[ self isWorldMorph not 
			and:[ self wantsEasySelection not ]])
	ifTrue:[
		"explicitly ignore the event if we're not the world and we'll not select,
		so that we could be picked up if need be"
		evt wasHandled: false.
		^ self.
	].

	( evt shiftPressed or: [ self wantsEasySelection ] ) ifTrue:[
		"We'll select on drag, let's decide what to do on click"
		| clickSelector |

		clickSelector := nil.

		evt shiftPressed ifTrue:[
			clickSelector := #findWindow:.
		]
		ifFalse:[
			self isWorldMorph ifTrue:[
				clickSelector := handHadHalos
										ifTrue: [ #delayedInvokeWorldMenu: ]
										ifFalse: [ #invokeWorldMenu: ]
			]
		].

		evt hand 
				waitForClicksOrDrag: self 
				event: evt 
				selectors: { clickSelector. nil. nil. #dragThroughOnDesktop: }
				threshold: HandMorph dragThreshold.
	]
	ifFalse:[
		"We wont select, just bring world menu if I'm the world"
		self isWorldMorph ifTrue:[
			handHadHalos
				ifTrue: [ self delayedInvokeWorldMenu: evt ]
				ifFalse: [ self invokeWorldMenu: evt ]
		]
	].

]

{ #category : #'menu & halo' }
PasteUpMorph >> mouseOverHalosString [
	"Answer the string to be shown in a menu to represent the  
	mouse-over-halos status"
	^ (self wantsMouseOverHalos
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'mouse-over halos' translated
]

{ #category : #'event handling' }
PasteUpMorph >> mouseUp: evt [
	self isWorldMorph ifTrue:[self removeAlarm: #invokeWorldMenu:].
	super mouseUp: evt.
]

{ #category : #misc }
PasteUpMorph >> mouseX [
	"Answer the x-coordinate of the mouse, in my coordinate system"

	^ self isInWorld
		ifTrue:
			[((self pointFromWorld: self cursorPoint) x) - self cartesianOrigin x]
		ifFalse:
			[0]
]

{ #category : #misc }
PasteUpMorph >> mouseY [
	"Answer the y-coordinate of the mouse, in my coordinate system"

	^ self isInWorld
		ifTrue:
			[self cartesianOrigin y - ((self pointFromWorld: self cursorPoint) y)]
		ifFalse:
			[0]
]

{ #category : #misc }
PasteUpMorph >> nameForCopyIfAlreadyNamed: aMorph [
	"Answer a name to set for a copy of aMorph if aMorph itself is named, else nil"

	| aName usedNames |
	^ (aName := aMorph knownName) ifNotNil:
		[usedNames := self allKnownNames.
		Utilities keyLike: aName satisfying: [:f | (usedNames includes: f) not]]
]

{ #category : #'world menu' }
PasteUpMorph >> newDrawingFromMenu: evt [
	self assureNotPaintingElse: [^ self].
	evt hand attachMorph: PaintInvokingMorph new markAsPartsDonor
]

{ #category : #initialization }
PasteUpMorph >> newResourceLoaded [
	"Some resource has just been loaded. Notify all morphs in case somebody wants to update accordingly."
	self allMorphsDo:[:m| m resourceJustLoaded ].
	self fullRepaintNeeded.
]

{ #category : #'world state' }
PasteUpMorph >> nextPage [
	"backstop for smart next-page buttons that look up the containment hierarchy until they find somone who is willing to field this command.  If we get here, the 'next' button was not embedded in a book, so we can do nothing useful"

	Beeper beep
]

{ #category : #'world state' }
PasteUpMorph >> noDisplayDuring: block [
	"Some morphs insist on updating the display like the system progress bar does. However, some code might be in an inconsistent state. For this, you can use this method to be safe."

	self
		setProperty: #shouldDisplayWorld
		toValue: false.
		
	block ensure: [self removeProperty: #shouldDisplayWorld].
]

{ #category : #cursor }
PasteUpMorph >> numberAtCursor [
	"Answer the number represented by the object at my current cursor position"

	| chosenMorph |
	submorphs isEmpty ifTrue: [^ 0].
	chosenMorph := submorphs at: ((cursor truncated max: 1) min: submorphs size).
	^ chosenMorph getNumericValue

]

{ #category : #flaps }
PasteUpMorph >> offsetForAccommodating: anExtent onEdge: edgeSymbol [
	"Answer a delta to be applied to my submorphs in order tfor anExtent to be slid inboard on the indicated edge"
	edgeSymbol == #left ifTrue: [^ anExtent x @ 0].
	edgeSymbol == #right ifTrue: [^ anExtent x negated @ 0].
	edgeSymbol == #top ifTrue: [^ 0 @ anExtent y].
	edgeSymbol == #bottom ifTrue: [^ 0 @ anExtent y negated].
]

{ #category : #undo }
PasteUpMorph >> onceAgainDismiss: aMorph [
	"Occasioned by a redo of a dismiss-via-halo"

	aMorph dismissMorph.
	TrashCanMorph preserveTrash ifTrue: 
		[TrashCanMorph slideDismissalsToTrash
			ifTrue:[aMorph slideToTrash: nil]
			ifFalse:[TrashCanMorph moveToTrash: aMorph]]
]

{ #category : #'world menu' }
PasteUpMorph >> openScrapsBook: evt [
	"Open up the Scraps book in the center of the screen"

	evt hand world addMorphCentered: ScrapBook default scrapBook
]

{ #category : #'world state' }
PasteUpMorph >> optimumExtentFromAuthor [

	
	^self 
		valueOfProperty: #optimumExtentFromAuthor 
		ifAbsent: [ | opt |
			opt := bounds extent.
			self setProperty: #optimumExtentFromAuthor toValue: opt.
			^opt
		]


]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> originAtCenter [
	^ self hasProperty: #originAtCenter
]

{ #category : #'menu & halo' }
PasteUpMorph >> originAtCenterString [
	"Answer the string to be shown in a menu to represent the 
	origin-at-center status"
	^ ((self hasProperty: #originAtCenter)
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'origin-at-center' translated
]

{ #category : #misc }
PasteUpMorph >> padding: aNumber [
	padding := aNumber
]

{ #category : #'world state' }
PasteUpMorph >> paintArea [
	"What rectangle should the user be allowed to create a new painting in??
	An area beside the paintBox. Allow playArea to override with its own
	bounds! "
	| playfield paintBoxBounds |
	playfield := self
				submorphNamed: 'playfield'
				ifNone: [].
	playfield
		ifNotNil: [^ playfield bounds].
	paintBoxBounds := self paintBox bounds.
	self firstHand targetPoint x < paintBoxBounds center x
		ifTrue: [^ bounds topLeft corner: paintBoxBounds left @ bounds bottom"paint on left side"]
		ifFalse: [^ paintBoxBounds right @ bounds top corner: bounds bottomRight]
]

{ #category : #'world state' }
PasteUpMorph >> paintAreaFor: aSketchMorph [ 
	"Answer the area to comprise the onion-skinned canvas for painting/repainting aSketchMorph"

	| itsOwner |
	((itsOwner := aSketchMorph owner) notNil and: [itsOwner isPlayfieldLike]) 
		ifTrue: [^itsOwner bounds].	"handles every plausible situation"
	^self paintArea
]

{ #category : #'world state' }
PasteUpMorph >> paintBox [
	"Return the painting controls widget (PaintBoxMorph) to be used for painting in this world. If there is not already a PaintBox morph, or if it has been deleted from this world, create a new one."

	| newPaintBox refPoint aPalette |
	self allMorphsDo: [:m | (m isKindOf: PaintBoxMorph) ifTrue: [^ m]].
	refPoint := (aPalette := self standardPalette)
		ifNotNil:
			[aPalette showNoPalette.
			aPalette topRight + (0 @ 12)]
		ifNil:
			[self topRight].
	newPaintBox := PaintBoxMorph new.
	newPaintBox position: (refPoint - (newPaintBox width @ 0)). 
	self addMorph: newPaintBox.
	^ newPaintBox

]

{ #category : #'world state' }
PasteUpMorph >> paintBoxOrNil [
	"Return the painting controls widget (PaintBoxMorph) to be used for painting in this world. If there is not already a PaintBox morph return nil"

	self allMorphsDo: [:m | (m isKindOf: PaintBoxMorph) ifTrue: [^ m]].
	^ nil

]

{ #category : #painting }
PasteUpMorph >> paintingBoundsAround: aPoint [
	"Return a rectangle for painting centered on the given point. Both the argument point and the result rectangle are in world coordinates."

	| paintExtent maxPaintArea myBnds |
	paintExtent := self reasonablePaintingExtent.
	maxPaintArea := paintExtent x * paintExtent y.
	myBnds := self boundsInWorld.
	(myBnds area <= maxPaintArea) ifTrue: [^ myBnds].
	^ (aPoint - (paintExtent // 2) extent: paintExtent) intersect: myBnds

]

{ #category : #flaps }
PasteUpMorph >> paintingFlapTab [
	"If the receiver has a flap which has a paintbox, return it, else return nil"
	self flapTabs do:
		[:aTab | aTab referent submorphsDo:
			[:aMorph | (aMorph isKindOf: PaintBoxMorph) ifTrue: [^ aTab]]].
	^ nil
]

{ #category : #'world state' }
PasteUpMorph >> patchAt: patchRect without: stopMorph andNothingAbove: stopThere [
	"Return a complete rendering of this patch of the display screen
	without stopMorph, and possibly without anything above it."

	| c |
	c := ColorPatchCanvas
		extent: patchRect extent
		depth: Display depth
		origin: patchRect topLeft negated
		clipRect: (0@0 extent: patchRect extent).
	c stopMorph: stopMorph.
	c doStop: stopThere.

	(self bounds containsRect: patchRect) ifFalse:
		["Need to fill area outside bounds with black."
		c form fillColor: Color black].
	(self bounds intersects: patchRect) ifFalse:
		["Nothing within bounds to show."
		^ c form].
	self fullDrawOn: c.
	stopThere ifFalse: [ self world handsReverseDo: [:h | h drawSubmorphsOn: c]].
	^c form

]

{ #category : #'world state' }
PasteUpMorph >> pauseEventRecorder [
	"Suspend any event recorder, and return it if found"

	
	worldState handsDo: [:h | | er | (er := h pauseEventRecorderIn: self) ifNotNil: [^ er]].
	^ nil
]

{ #category : #geometry }
PasteUpMorph >> position: aPoint [
	"Prevent moving a world (e.g. via HandMorph>>specialGesture:)"

	"for now, let's allow it and see what happens"

	self isWorldMorph ifFalse: [^super position: aPoint].
	super position: aPoint.
	self viewBox ifNotNil: [self viewBox: (aPoint extent: self viewBox extent)].


]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> positionNear: aPoint forExtent: anExtent adjustmentSuggestion: adjustmentPoint [
	"Compute a plausible positioning for adding a subpart of size anExtent, somewhere near aPoint, using adjustmentPoint as the unit of adjustment"

	| adjustedPosition |
	adjustedPosition := aPoint.
	[((self morphsAt: (adjustedPosition + (anExtent // 2))) size > 1) and:  "that 1 is self here"
		[bounds containsPoint: adjustedPosition]]
	whileTrue:
		[adjustedPosition := adjustedPosition + adjustmentPoint].

	^ adjustedPosition
]

{ #category : #misc }
PasteUpMorph >> prepareToBeSaved [
	"Prepare for export via the ReferenceStream mechanism"

	| exportDict soundKeyList players |
	super prepareToBeSaved.
	turtlePen := nil.
	self isWorldMorph
		ifTrue:
			[self removeProperty: #scriptsToResume.
			soundKeyList := Set new.
			(players := self presenter allExtantPlayers)
				do: [:aPlayer | aPlayer slotInfo
						associationsDo: [:assoc | assoc value type == #Sound
								ifTrue: [soundKeyList
										add: (aPlayer instVarNamed: assoc key)]]].
			players
				do: [:p | p allScriptEditors
						do: [:e | (e allMorphs
								select: [:m | m isSoundTile])
								do: [:aTile | soundKeyList add: aTile literal]]].
			(self allMorphs
				select: [:m | m isSoundTile])
				do: [:aTile | soundKeyList add: aTile literal].
			soundKeyList removeAllFoundIn: SampledSound universalSoundKeys.
			soundKeyList
				removeAllSuchThat: [:aKey | (SampledSound soundLibrary includesKey: aKey) not].
			soundKeyList isEmpty
				ifFalse: [exportDict := Dictionary new.
					soundKeyList
						do: [:aKey | exportDict
								add: (SampledSound soundLibrary associationAt: aKey)].
					self setProperty: #soundAdditions toValue: exportDict]]
]

{ #category : #painting }
PasteUpMorph >> prepareToPaint [
	"We're about to start painting. Do a few preparations that make the system more responsive."

	^ self prepareToPaint: Preferences keepTickingWhilePainting not
]

{ #category : #painting }
PasteUpMorph >> prepareToPaint: stopRunningScripts [
	"We're about to start painting. Do a few preparations that make the system more responsive."

	self hideViewerFlaps. "make room"
	stopRunningScripts ifTrue:
		[self setProperty: #scriptsToResume toValue: self presenter allCurrentlyTickingScriptInstantiations.  "We'll restart these when painting is done"
		self stopRunningAll]. "stop scripts"
	self abandonAllHalos. "no more halos"
]

{ #category : #'menu & halo' }
PasteUpMorph >> presentCardAndStackMenu [
	"Put up a menu holding card/stack-related options."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.		
	aMenu addStayUpItem.
	aMenu addTitle: 'card and stack' translated.
	aMenu add: 'add new card' translated action: #insertCard.
	aMenu add: 'delete this card' translated action: #deleteCard.
	aMenu add: 'go to next card' translated action: #goToNextCardInStack.
	aMenu add: 'go to previous card' translated action: #goToPreviousCardInStack.
	aMenu addLine.
	aMenu add: 'show foreground objects' translated action: #showForegroundObjects.
	aMenu add: 'show background objects' translated action: #showBackgroundObjects.
	aMenu add: 'show designations' translated action: #showDesignationsOfObjects.
	aMenu add: 'explain designations'  translated action: #explainDesignations.
	aMenu popUpInWorld: (self world ifNil: [self currentWorld])
]

{ #category : #'menu & halo' }
PasteUpMorph >> presentPlayfieldMenu [

	self playfieldOptionsMenu popUpForHand: self activeHand in: self world
]

{ #category : #accessing }
PasteUpMorph >> presenter [
	"Normally only the world will have a presenter, but the architecture supports individual localized presenters as well"

	^ presenter ifNil:
		[self isWorldMorph
			ifTrue: [presenter := Presenter defaultPresenterClass new associatedMorph: self]
			ifFalse: [super presenter]]
]

{ #category : #'world state' }
PasteUpMorph >> previousPage [
	"backstop for smartprev-page buttons that look up the containment hierarchy until they find somone who is willing to field this command.  If we get here, the button was not embedded in a book, so we can do nothing useful"

	Beeper beep
]

{ #category : #structure }
PasteUpMorph >> primaryHand [

	^ self hands at: 1 ifAbsent: [nil]
]

{ #category : #printing }
PasteUpMorph >> printOn: aStream [
	"Reimplemented to add a tag showing that the receiver is currently functioning as a 'world', if it is"

	super printOn: aStream.
	self isWorldMorph ifTrue: [aStream nextPutAll: ' [world]']
]

{ #category : #'world menu' }
PasteUpMorph >> printScriptSummary [
	"Put up a window with summaries of all scripts in the world"

	self presenter reportPlayersAndScripts

"self currentWorld printScriptSummary"
]

{ #category : #private }
PasteUpMorph >> privateFullMoveBy: delta [
	"Private. Overridden to prevent drawing turtle trails when a playfield is moved"
	self setProperty: #turtleTrailsDelta toValue: delta.
	super privateFullMoveBy: delta.
	self removeProperty: #turtleTrailsDelta.

]

{ #category : #private }
PasteUpMorph >> privateMoveBy: delta [

	super privateMoveBy: delta.
	worldState ifNotNil: [
		worldState viewBox ifNotNil: [
			worldState viewBox: bounds
		].
	].
]

{ #category : #'world state' }
PasteUpMorph >> privateOuterDisplayWorld [

	(self valueOfProperty: #shouldDisplayWorld ifAbsent: [true])
		ifTrue: [worldState displayWorld: self submorphs: submorphs].
]

{ #category : #private }
PasteUpMorph >> privateRemoveMorph: aMorph [
	backgroundMorph == aMorph ifTrue: [ backgroundMorph := nil ].
	^super privateRemoveMorph: aMorph.

]

{ #category : #'events-processing' }
PasteUpMorph >> processEvent: anEvent using: defaultDispatcher [
	"Reimplemented to install the receiver as the new active world if it is one"

	self isWorldMorph ifFalse: [
		^ super processEvent: anEvent using: defaultDispatcher].
	
	^ self becomeActiveDuring: [
		super processEvent: anEvent using: defaultDispatcher]
]

{ #category : #project }
PasteUpMorph >> project [
	"Find the project that owns me.  Not efficient to call this."

	^ Project ofWorld: self
]

{ #category : #'world menu' }
PasteUpMorph >> putUpNewMorphMenu [
	"Put up the New Morph menu in the world"

	TheWorldMenu new adaptToWorld: self; newMorph
]

{ #category : #'menu & halo' }
PasteUpMorph >> putUpPenTrailsSubmenu [
	"Put up the pen trails menu"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu title: 'pen trails' translated.
	aMenu addStayUpItem.
	self addPenTrailsMenuItemsTo: aMenu.
	^ aMenu popUpInWorld: self
]

{ #category : #'world menu' }
PasteUpMorph >> putUpWorldMenu: evt [
	"Put up a menu in response to a click on the desktop, triggered by evt."

	| menu |
	self bringTopmostsToFront.
	evt isMouse ifTrue:
		[evt yellowButtonPressed
			ifTrue: [^ self yellowButtonClickOnDesktopWithEvent: evt].
		evt shiftPressed ifTrue:[^ self findWindow: evt]].
	"put up screen menu"
	menu := self buildWorldMenu: evt.
	menu addTitle: Preferences desktopMenuTitle translated.
	menu popUpEvent: evt in: self.
	^ menu
]

{ #category : #'world menu' }
PasteUpMorph >> putUpWorldMenuFromEscapeKey [
	Preferences noviceMode
		ifFalse: [self putUpWorldMenu: self currentEvent]
]

{ #category : #painting }
PasteUpMorph >> reasonablePaintingExtent [
	^ Preferences unlimitedPaintArea
		ifTrue:
			[3000 @ 3000]
		ifFalse:
			[Preferences defaultPaintingExtent]
]

{ #category : #cursor }
PasteUpMorph >> rectifyCursor [
	cursor := ((cursor truncated max: 1) min: submorphs size)

]

{ #category : #'e-toy support' }
PasteUpMorph >> referencePlayfield [
	"Answer a pasteup morph to be used as the reference for cartesian coordinates.
	Do not get fooled by other morphs (like viewers) that happen to be named 'playfield'."

	^self isWorldMorph
		ifTrue: [ self submorphThat: [ :s | (s knownName = 'playfield') and: [ s isPlayfieldLike] ] ifNone: [self]]
		ifFalse: [ super referencePlayfield ]
]

{ #category : #'objects from disk' }
PasteUpMorph >> referencePool [
	^ self 
		valueOfProperty: #References 
		ifAbsentPut: [WeakValueDictionary new]

]

{ #category : #'menu & halo' }
PasteUpMorph >> reformulateUpdatingMenus [
	"Give any updating menu morphs in the receiver a fresh kiss of life"

	(self submorphs select: [:m | m isKindOf: UpdatingMenuMorph]) do:
		[:m | m updateMenu] 

	"NB: to do the perfect job here one might well want to extend across allMorphs here, but the expense upon project entry is seemingly too high a price to pay at this point"
]

{ #category : #undo }
PasteUpMorph >> reintroduceIntoWorld: aMorph [
	"The given morph is being raised from the dead.  Bring it back to life."

	(aMorph valueOfProperty: #lastPosition) ifNotNil:
		[:pos | aMorph position: pos].
	aMorph openInWorld; goHome

	
]

{ #category : #caching }
PasteUpMorph >> releaseCachedState [
	super releaseCachedState.
	presenter ifNotNil:[presenter flushPlayerListCache].
	self isWorldMorph ifTrue:[self cleanseStepList].
]

{ #category : #Nebraska }
PasteUpMorph >> releaseRemoteServer [
	"My server has been transferred to some other world. Release pending references"
	^worldState releaseRemoteServer.
]

{ #category : #project }
PasteUpMorph >> releaseSqueakPages [
	
	"If this world has a book with SqueakPages, then clear the SqueakPageCache"

	submorphs do: [:sub | | uu |
		(sub isKindOf: BookMorph) ifTrue: [
		uu := sub valueOfProperty: #url ifAbsent: [nil].
		uu ifNotNil: [(SqueakPageCache pageCache includesKey: uu) ifTrue: [
				SqueakPageCache initialize]]]].	"wipe the cache"
]

{ #category : #flaps }
PasteUpMorph >> releaseViewers [
	"In preparation for saving, make the flapTabs release their viewers."

	self flapTabs do: [:ft | 
		(ft respondsTo: #hibernate) ifTrue: [ft hibernate]]
]

{ #category : #Nebraska }
PasteUpMorph >> remoteServer [
	^worldState remoteServer.
]

{ #category : #Nebraska }
PasteUpMorph >> remoteServer: aNebraskaServer [

	| h |

	worldState remoteServer: aNebraskaServer.
	h := self primaryHand.
	aNebraskaServer ifNil:[
		(h hasProperty: #representingTheServer) ifTrue: [
			h removeProperty: #representingTheServer.
			h userInitials: '' andPicture: nil.
		]
	] ifNotNil:[
		(h hasProperty: #representingTheServer) ifFalse: [
			h setProperty: #representingTheServer toValue: true.
			h userInitials: Utilities authorName andPicture: nil.
		]
	].
]

{ #category : #flaps }
PasteUpMorph >> removeAccommodationForFlap: aFlapTab [
	"Shift submorphs over, if appropriate"
	| offset |
	aFlapTab slidesOtherObjects ifTrue:
		[offset := self offsetForAccommodating: aFlapTab referent extent onEdge: aFlapTab edgeToAdhereTo.
		self shiftSubmorphsBy: offset negated]
]

{ #category : #'alarms-scheduler' }
PasteUpMorph >> removeAlarm: aSelector for: aTarget [
	"Remove the alarm with the given selector"
	worldState removeAlarm: aSelector for: aTarget
]

{ #category : #'world menu' }
PasteUpMorph >> removeAllViewers [
	"Delete all the viewers lined up along my right margin."

	(self submorphs select: [:m | m isKindOf: ViewerFlapTab]) do:
		[:m |
			m referent ifNotNil: [m referent delete].
			m delete.]
]

{ #category : #'world state' }
PasteUpMorph >> removeHand: aHandMorph [
	"Remove the given hand from the list of hands for this world."

	(worldState hands includes: aHandMorph) ifFalse: [^self].
	aHandMorph dropMorphs.
	self invalidRect: aHandMorph fullBounds.
	worldState removeHand: aHandMorph.

]

{ #category : #initialization }
PasteUpMorph >> removeKeyboardShortcuts [
	
	self removeKeyboardCaptureFilter: self.
]

{ #category : #Nebraska }
PasteUpMorph >> removeRemoteClient: aClient [
	self removeHand: aClient hand.
	worldState removeRemoteCanvas: aClient canvas.
	self changed.  "force a redraw"

]

{ #category : #'world state' }
PasteUpMorph >> repairEmbeddedWorlds [

	| toDoList |

	toDoList := OrderedCollection new.
	self allMorphsDo: [ :each | | transform eWorld |
		(each isKindOf: EmbeddedWorldBorderMorph) ifTrue: [
			transform := each submorphs at: 1 ifAbsent: [nil].
			transform ifNotNil: [
				eWorld := transform submorphs at: 1 ifAbsent: [nil].
				eWorld ifNotNil: [
					toDoList add: {transform. eWorld}.
				].
			].
			"Smalltalk at: #Q put: {self. each. transform. eWorld}."
		].
	].
	toDoList do: [ :each |
		each first addMorph: each second.
	].
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> repelsMorph: aMorph event: ev [
	(aMorph wantsToBeDroppedInto: self) ifFalse: [^ false].
	self dropEnabled ifFalse: [^ true].
	(self wantsDroppedMorph: aMorph event: ev) ifFalse: [^ true].
	^ super repelsMorph: aMorph event: ev "consults #repelling flag"
]

{ #category : #options }
PasteUpMorph >> replaceTallSubmorphsByThumbnails [
	"Any submorphs that seem to tall get replaced by thumbnails; their balloon text is copied over to the thumbnail"

	| heightForThumbnails maxHeightToAvoidThumbnailing maxWidthForThumbnails |
	heightForThumbnails := self heightForThumbnails.
	maxHeightToAvoidThumbnailing := self maxHeightToAvoidThumbnailing.
	maxWidthForThumbnails := self maximumThumbnailWidth.
	self submorphs do:
		[:aMorph | | existingHelp itsThumbnail |
			itsThumbnail := aMorph representativeNoTallerThan: maxHeightToAvoidThumbnailing norWiderThan: maxWidthForThumbnails thumbnailHeight: heightForThumbnails.
			(aMorph == itsThumbnail)
				ifFalse:
					[existingHelp := aMorph balloonText.
					self replaceSubmorph: aMorph by: itsThumbnail.
					existingHelp ifNotNil:
						[itsThumbnail setBalloonText: existingHelp]]]
]

{ #category : #'world menu' }
PasteUpMorph >> reportLocalAddress [
	"Report the local host address of this computer."

	| addrString m s |
	Socket initializeNetwork.
	addrString := NetNameResolver localAddressString.
	m := RectangleMorph new
		color: (Color r: 0.6 g: 0.8 b: 0.6);
		extent: 118@36;
		borderWidth: 1.
	s := StringMorph contents: 'Local Host Address:'.
	s position: m position + (5@4).
	m addMorph: s.
	s := StringMorph contents: addrString.
	s position: m position + (5@19).
	m addMorph: s.
	self primaryHand attachMorph: m.

]

{ #category : #'world state' }
PasteUpMorph >> repositionFlapsAfterScreenSizeChange [
	"Reposition flaps after screen size change"

	(Flaps globalFlapTabsIfAny, self localFlapTabs) do:
		[:aFlapTab |
			aFlapTab applyEdgeFractionWithin: self bounds].
	Flaps doAutomaticLayoutOfFlapsIfAppropriate
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> resetTransferMorphConverter [
	^ self transferMorphConverter: #yourself
]

{ #category : #'parts bin' }
PasteUpMorph >> residesInPartsBin [
	"Answer true if the receiver is, or has some ancestor owner who is, a parts bin"

	self isWorldMorph
		ifTrue: [^ self isPartsBin]
		ifFalse: [^ self isPartsBin or: [super residesInPartsBin]]
]

{ #category : #options }
PasteUpMorph >> resizeToFit [
	^self vResizing == #shrinkWrap
]

{ #category : #options }
PasteUpMorph >> resizeToFitString [
	"Answer a string, to be used in a self-updating menu, to 
	represent whether the receiver is currently using resize-to-fit 
	or not"
	^ (self resizeToFit
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'resize to fit' translated
]

{ #category : #'world menu' }
PasteUpMorph >> respondToCommand: aCharacter bySending: aSelector to: aReceiver [
	"Respond to the command-key use of the given character by sending the given selector to the given receiver.  If the selector is nil, retract any prior such setting"

	aSelector
		ifNil:
			[self commandKeySelectors removeKey: aCharacter]
		ifNotNil:
			[self commandKeySelectors at: aCharacter put: (MessageSend receiver: aReceiver selector: aSelector)]
]

{ #category : #'WiW support' }
PasteUpMorph >> restartWorldCycleWithEvent: evt [

	"RAA 27 Nov 99 - redispatch that click picked up from our inner world"
	evt ifNotNil: [
		self primaryHand handleEvent: (evt setHand: self primaryHand).
	].
	Project current spawnNewProcessAndTerminateOld: true

]

{ #category : #viewing }
PasteUpMorph >> restoreBoundsOfSubmorphs [
	"restores the saved xy-positions and extents"

	submorphs do:
		[:aSubmorph |
			aSubmorph valueOfProperty: #savedExtent ifPresentDo:
				[:anExtent | aSubmorph extent: anExtent].
			aSubmorph valueOfProperty: #savedPosition ifPresentDo:
				[:aPosition | aSubmorph position: aPosition]]
]

{ #category : #'world state' }
PasteUpMorph >> restoreFlapsDisplay [
	"Restore the display of flaps"

	(Flaps sharedFlapsAllowed and: [Project current flapsSuppressed not]) ifTrue:
		[Flaps globalFlapTabs do:
			[:aFlapTab | aFlapTab adaptToWorld]].
	self localFlapTabs do:
			[:aFlapTab | aFlapTab adaptToWorld].
	self assureFlapTabsFitOnScreen.
	self bringTopmostsToFront.
]

{ #category : #'world state' }
PasteUpMorph >> restoreMainDockingBarDisplay [
	"Restore the display of docking bars"
	self dockingBars
		do: [:each | each updateBounds]
]

{ #category : #'world state' }
PasteUpMorph >> restoreMorphicDisplay [

	self removeProperty: #shouldDisplayWorld.

	ThumbnailMorph recursionReset.
	
	self
		extent: Display extent;
		viewBox: Display boundingBox;
		handsDo: [:h | h visible: true; showTemporaryCursor: nil];
"		restoreFlapsDisplay;
		restoreMainDockingBarDisplay;
"		fullRepaintNeeded.

]

{ #category : #painting }
PasteUpMorph >> resumeScriptsPausedByPainting [
	"If there were any scripts running when painting was initiated, resume them now"

	| aList |
	(aList := self valueOfProperty: #scriptsToResume) isEmptyOrNil ifFalse:
		[aList do:
			[:aScriptInstantiation |
				aScriptInstantiation player costume isInWorld ifTrue:
					[aScriptInstantiation startRunningIfPaused]]].
	self removeProperty: #scriptsToResume
]

{ #category : #stepping }
PasteUpMorph >> runLocalStepMethods [

	worldState runLocalStepMethodsIn: self

]

{ #category : #stepping }
PasteUpMorph >> runStepMethods [

	worldState runStepMethodsIn: self

]

{ #category : #'world state' }
PasteUpMorph >> saveAsWorld [
	| worldName s |
	worldName := UIManager default
		request: 'Please give this world a name'
		initialAnswer: 'test'.
	((self class class includesSelector: worldName asSymbol) and:
		[(UIManager default confirm: 'OK to overwrite ' , worldName , '?') not])
		ifTrue: [^ self].

	s := WriteStream on: (String new: 1000).
	s	nextPutAll: worldName; cr; tab;
		nextPutAll: '"' , self class name , ' ' , worldName, ' open"'; cr; cr; tab;
		nextPutAll: '^ '.
	self printConstructorOn: s indent: 0.
	s cr.

	self class class
		compile: s contents
		classified: 'examples'
		notifying: nil.
]

{ #category : #viewing }
PasteUpMorph >> saveBoundsOfSubmorphs [
	"store the current xy-positions and extents of submorphs for future use"

	submorphs do:
		[:aSubmorph |
			aSubmorph setProperty: #savedExtent toValue: aSubmorph extent.
			aSubmorph setProperty: #savedPosition toValue: aSubmorph position]
]

{ #category : #'objects from disk' }
PasteUpMorph >> saveOnFile [
	"Ask the user for a filename and save myself on a SmartReferenceStream file.  Writes out the version and class structure.  The file is fileIn-able.  UniClasses will be filed out."

	| aFileName fileStream |

	self flag: #bob0302.
	self isWorldMorph ifTrue: [^self project saveAs].

	aFileName := ('my {1}.project' translated format: {self class name}) asFileName.	"do better?"
	aFileName := UIManager default saveFilenameRequest: 'File name?' translated 
			initialAnswer: aFileName.
	aFileName ifNil: [^ Beeper beep].
	self allMorphsDo: [:m | m prepareToBeSaved].

	fileStream := FileStream newFileNamed: aFileName.
	fileStream fileOutClass: nil andObject: self.	"Puts UniClass definitions out anyway"
]

{ #category : #cursor }
PasteUpMorph >> selectedRect [
	"Return a rectangle enclosing the morph at the current cursor. Note that the cursor may be a float and may be out of range, so pick the nearest morph. Assume there is at least one submorph."

	| p |
	p := cursor asInteger.
	p := p min: submorphs size.
	p := p max: 1.
	^(submorphs at: p) fullBounds expandBy: 2
]

{ #category : #'menu & halo' }
PasteUpMorph >> sendTextContentsBackToDonor [
	"Send my string contents back to the Text Morph from whence I came"

	(self valueOfProperty: #donorTextMorph) ifNotNil:
		[:aDonor | aDonor setCharacters: self assuredPlayer getStringContents]
]

{ #category : #'visual properties' }
PasteUpMorph >> setAsBackground: aFormOrColorOrFillStyle [

	| project |
	(self outermostWorldMorph == self and: [(project := self project) isMorphic])
		ifTrue: [project setAsBackground: aFormOrColorOrFillStyle]
		ifFalse: [self fillStyle: aFormOrColorOrFillStyle].
]

{ #category : #display }
PasteUpMorph >> setGradientColor: evt [
	"For backwards compatibility with GradientFillMorph"

	self flag: #fixThis.
	self changeColorTarget: self selector: #gradientFillColor:
		originalColor: (self fillStyle isGradientFill
			ifTrue: [self fillStyle colorRamp last value]
			ifFalse: [color])
		hand: evt hand.
]

{ #category : #gridding }
PasteUpMorph >> setGridSpec [
	"Gridding rectangle provides origin and modulus"
	| response result |
	response := UIManager default
			request: 'New grid origin (usually 0@0):' translated
			initialAnswer: self gridOrigin printString.
	response isEmpty ifTrue: [^ self].
	result := [Compiler evaluate: response] ifError: [^ self].
	(result isPoint and: [(result >= (0@0))])
		ifTrue: [self gridOrigin: result]
		ifFalse: [self inform: ('Must be a Point with coordinates (for example 10@10)' translated )].

	response := UIManager default
			request: 'New grid spacing:' translated
			initialAnswer: self gridModulus printString.
	response isEmpty ifTrue: [^ self].
	result := [Compiler evaluate: response] ifError: [^ self].
	(result isPoint and: [(result > (0@0)) ])
		ifTrue: [self gridModulus: result]
		ifFalse: [self inform: ('Must be a Point with coordinates (for example 10@10)' translated )].


]

{ #category : #model }
PasteUpMorph >> setModel: aModelMorph [
	"Set the model for this world. Methods for sensitized morphs will be compiled into the class for this model."

	model := aModelMorph

]

{ #category : #options }
PasteUpMorph >> setPartsBinStatusTo: aBoolean [
	isPartsBin := aBoolean.
	aBoolean ifFalse: [self enableDragNDrop].
		"but note that we no longer reset openToDragNDrop to false upon making it a parts bin again"
	isPartsBin
		ifTrue:
			[submorphs do:
				[:m | m isPartsDonor: true.
					m stopStepping.
					m suspendEventHandler]]
		ifFalse:
			[submorphs do:
				[:m | m isPartsDonor: false.
					m restoreSuspendedEventHandler].
			self world ifNotNil: [self world startSteppingSubmorphsOf: self]]
]

{ #category : #'WiW support' }
PasteUpMorph >> shouldGetStepsFrom: aWorld [

	(self isWorldMorph and: [owner notNil]) ifTrue: [
		^self outermostWorldMorph == aWorld
	].
	^super shouldGetStepsFrom: aWorld
]

{ #category : #'menu & halo' }
PasteUpMorph >> showApplicationView [

	self transformToShow: (self valueOfProperty: #applicationViewBounds ifAbsent: [bounds])
		
]

{ #category : #'menu & halo' }
PasteUpMorph >> showExpandedView [

	owner	"the transform"
		owner	"the green border"
			bounds: Display boundingBox
]

{ #category : #'menu & halo' }
PasteUpMorph >> showFactoryView [

	self transformToShow: (self valueOfProperty: #factoryViewBounds ifAbsent: [bounds])
		
]

{ #category : #'menu & halo' }
PasteUpMorph >> showFullView [

	self transformToShow: bounds
		
]

{ #category : #'menu & halo' }
PasteUpMorph >> showReducedView [

	| r |
	r := Display extent // 4 extent: Display extent // 2.
	owner	"the transform"
		owner	"the green border"
			bounds: r
]

{ #category : #'world menu' }
PasteUpMorph >> showStatusOfAllScripts [
	"Put up a window that shows, and allows you to change, the status of all scripts"

	self presenter toolToViewScriptInstantiations
]

{ #category : #'menu & halo' }
PasteUpMorph >> showThumbnailString [
	"Answer the string to be shown in a menu to represent the 
	show-thumbnails status"
	^ ((self hasProperty: #alwaysShowThumbnail)
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'show thumbnails' translated
]

{ #category : #'menu & halo' }
PasteUpMorph >> showWorldMainDockingBarString [
	^ self project showWorldMainDockingBarString
]

{ #category : #viewing }
PasteUpMorph >> showingListView [
	"Answer whether the receiver is currently showing a list view"

	^ self hasProperty: #showingListView

]

{ #category : #'world state' }
PasteUpMorph >> sketchEditorOrNil [
	"Return a SketchEditorMorph found in the world, if any, else nil"

	^ self findA: SketchEditorMorph

]

{ #category : #'world state' }
PasteUpMorph >> sleep [

	self flag: #bob.		"Alan wanted this"

	worldState canvas ifNil: [^ self  "already called (clean this up)"].
	Cursor normal show.	"restore the normal cursor"

">>>> Alan wanted this out
	(turtleTrailsForm ~~ nil and: [self confirm: 'May I clear the pen trails
in this worldState to save space?']) ifTrue: [self clearTurtleTrails].
<<<<<"

	worldState canvas: nil.		"free my canvas to save space"
	self fullReleaseCachedState.

]

{ #category : #misc }
PasteUpMorph >> smallThumbnailForPageSorter [

	^ self cachedOrNewThumbnailFrom: BookPageThumbnailMorph new smaller
]

{ #category : #'world state' }
PasteUpMorph >> someHalo [
	"Return some halo that's currently visible in the world"

	| m |
	^(m := self haloMorphs) notEmpty ifTrue: [m first] ifFalse: [nil]
]

{ #category : #viewing }
PasteUpMorph >> sortSubmorphsBy: sortOrderSymbol [
	"Sort the receiver's submorphs by the criterion indicated in the provided symbol"
	self invalidRect: self fullBounds.
	submorphs := submorphs sorted: [:a :b | (a perform: sortOrderSymbol) <= (b perform: sortOrderSymbol)].
	self layoutChanged.
]

{ #category : #'world state' }
PasteUpMorph >> specialNameInModelFor: aMorph [
	^ model ifNotNil: [model nameFor: aMorph] ifNil: [nil]
]

{ #category : #'world state' }
PasteUpMorph >> standardPlayerHit [

	self playSoundNamed: 'peaks'.

]

{ #category : #'update cycle' }
PasteUpMorph >> startBackgroundProcess [
	"Start a process to update this world in the background. Return the process created."

	| p |
	p := [ [
		self doOneCycleInBackground.
		(Delay forMilliseconds: 20) wait] repeat ] newProcess.
	p resume.
	^ p

]

{ #category : #misc }
PasteUpMorph >> startRunningAll [
	"Start running all scripted morphs.  Triggered by user hitting GO button"

	self presenter flushPlayerListCache.  "Inefficient, but makes sure things come right whenever GO hit"
	self presenter allExtantPlayers do: [:aPlayer | aPlayer costume residesInPartsBin ifFalse: [aPlayer startRunning]].

	self world updateStatusForAllScriptEditors
]

{ #category : #stepping }
PasteUpMorph >> startStepping: aMorph [
	"Add the given morph to the step list. Do nothing if it is already being stepped."
	^self startStepping: aMorph at: Time millisecondClockValue selector: #stepAt: arguments: nil stepTime: nil
]

{ #category : #stepping }
PasteUpMorph >> startStepping: aMorph at: scheduledTime selector: aSelector arguments: args stepTime: stepTime [
	worldState startStepping: aMorph at: scheduledTime selector: aSelector arguments: args stepTime: stepTime.
]

{ #category : #'world state' }
PasteUpMorph >> startSteppingSubmorphsOf: aMorph [
	"Ensure that all submorphs of the given morph that want to be stepped are added to the step list.   Typically used after adding a morph to the world."

	self flag: #obsolete. "the intoWorld mechanism in addMorph nowadays takes care of adding submorphs to steplist"

"	aMorph allMorphsDo: [:m |
		aMorph ~~ m & m wantsSteps ifTrue: [
			m arrangeToStartSteppingIn: m world]].
"


]

{ #category : #'stepping and presenter' }
PasteUpMorph >> step [

	(self isWorldMorph and: [owner notNil]) ifTrue: [
		^self runLocalStepMethods
	].
	super step
]

{ #category : #misc }
PasteUpMorph >> stepAll [
	"tick all the paused player scripts in the receiver"

	self presenter allExtantPlayers do:
		[:aPlayer | 
			aPlayer startRunning; step; stopRunning]
]

{ #category : #'project state' }
PasteUpMorph >> stepListSize [
	^ worldState stepListSize

"Transcript cr; show: self currentWorld stepListSize printString, ' items on steplist as of ', Date dateAndTimeNow printString"
]

{ #category : #'project state' }
PasteUpMorph >> stepListSummary [
	^ worldState stepListSummary

"Transcript cr show: self currentWorld stepListSummary"
]

{ #category : #'stepping and presenter' }
PasteUpMorph >> stepTime [

	(self isWorldMorph and: [owner notNil]) ifTrue: [
		^1
	].
	^super stepTime
]

{ #category : #'project state' }
PasteUpMorph >> steppingMorphsNotInWorld [
	| all |
	all := self allMorphs.
	^ self listOfSteppingMorphs select: [:m | (all includes: m) not]

	"self currentWorld steppingMorphsNotInWorld do: [:m | m delete]"
]

{ #category : #misc }
PasteUpMorph >> stopRunningAll [
	"Reset all ticking scripts to be paused.  Triggered by user hitting STOP button"

	self presenter allExtantPlayers do:
		[:aPlayer |
			aPlayer stopRunning].

	self world updateStatusForAllScriptEditors
]

{ #category : #stepping }
PasteUpMorph >> stopStepping: aMorph [
	"Remove the given morph from the step list."

	worldState stopStepping: aMorph

]

{ #category : #stepping }
PasteUpMorph >> stopStepping: aMorph selector: aSelector [
	"Remove the given morph from the step list."

	worldState stopStepping: aMorph selector: aSelector

]

{ #category : #project }
PasteUpMorph >> storeProjectsAsSegments [
	"Force my sub-projects out to disk"

	submorphs do: 
			[:sub | 
			(sub isSystemWindow) 
				ifTrue: [(sub model isKindOf: Project) ifTrue: [sub model storeSegment]]]	"OK if was already out"
]

{ #category : #misc }
PasteUpMorph >> thumbnailForPageSorter [

	^ self cachedOrNewThumbnailFrom: BookPageThumbnailMorph new
]

{ #category : #options }
PasteUpMorph >> toggleAutoLineLayout [
	"Toggle the auto-line-layout setting"

	self autoLineLayout: self autoLineLayout not.
	self autoLineLayout ifFalse: [self restoreBoundsOfSubmorphs].
]

{ #category : #'world menu' }
PasteUpMorph >> toggleClassicNavigatorIfAppropriate [
	"If appropriate, toggle the presence of classic navigator"

	Preferences classicNavigatorEnabled ifTrue: [^ Preferences toggle: #showProjectNavigator]
]

{ #category : #options }
PasteUpMorph >> toggleIsPartsBin [
	"Not entirely happy with the openToDragNDrop not being directly manipulable etc, but still living with it for now."
	self setPartsBinStatusTo: self isPartsBin not
]

{ #category : #options }
PasteUpMorph >> toggleMouseOverHalos [
	wantsMouseOverHalos := self wantsMouseOverHalos not
]

{ #category : #options }
PasteUpMorph >> toggleResizeToFit [
	"Toggle whether the receiver is set to resize-to-fit"

	self vResizeToFit: self resizeToFit not
]

{ #category : #'menu & halo' }
PasteUpMorph >> toggleShowWorldMainDockingBar [
	self project toggleShowWorldMainDockingBar
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> transferMorphConverter [
	^self
		valueOfProperty: #transferMorphConverter
		ifAbsent: [ #yourself ]
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> transferMorphConverter: aMessageSend [ 
	self
		setProperty: #transferMorphConverter
		toValue: aMessageSend
]

{ #category : #Nebraska }
PasteUpMorph >> transferRemoteServerFrom: aWorld [
	"Transfer the remote server which was associated with aWorld (if any) to the receiver"
	| server |
	(aWorld notNil and:[aWorld isMorph and:[aWorld isWorldMorph]]) ifFalse:[^self].
	server := aWorld remoteServer.
	server ifNotNil:[
		self remoteServer: server.
		server clients do:[:each| self addRemoteClient: each].
		self primaryHand
			userInitials: (aWorld primaryHand userInitials)
			andPicture: (aWorld primaryHand userPicture).
		aWorld primaryHand userInitials: '' andPicture: nil].
	aWorld releaseRemoteServer.
]

{ #category : #'menu & halo' }
PasteUpMorph >> transformToShow: aRectangle [

	owner changeWorldBoundsToShow: aRectangle

]

{ #category : #'world state' }
PasteUpMorph >> triggerClosingScripts [
	"If the receiver has any scripts set to run on closing, run them now"
	| aPlayer |
	self allMorphsDo:[ :m|
	(aPlayer := m player) ifNotNil:
		[aPlayer runAllClosingScripts]]
]

{ #category : #'world state' }
PasteUpMorph >> triggerOpeningScripts [
	"If the receiver has any scripts set to run on opening, run them now"
	| aPlayer |
	self allMorphsDo:[ :m|
	(aPlayer := m player) ifNotNil:
		[aPlayer runAllOpeningScripts]]
]

{ #category : #'events-processing' }
PasteUpMorph >> tryInvokeHalo: aUserInputEvent [ 
	"Invoke halos around the top-most world container at aUserInputEvent's #position.  If it was already halo'd, zero-in on its next inward component morph at that position.  Holding Shift during the click reverses this traversal order."
	| stack innermost haloTarget |
	Preferences noviceMode ifTrue: [ ^ self ].
	Morph haloForAll ifFalse: [ ^ self ].
	"the stack is the top-most morph to bottom-most."
	stack := (self morphsAt: aUserInputEvent position unlocked: true) select:
		[ : each | each wantsHaloFromClick or: [ each handlesMouseDown: aUserInputEvent ] ].
	innermost := aUserInputEvent hand halo
		ifNil: [ stack first ]
		ifNotNil:
			[ : existingHalo | (stack copyWithout: existingHalo) "No halos on halos"
				detect: [ : each | each owner == self ]
				ifFound:
					[ : worldContainer | "Is existingHalo's target part of the same worldContainer as the morph clicked?"
					(existingHalo target withAllOwners includes: worldContainer)
						ifTrue: [ "same hierarchy, let #transferHalo: continue to handle it for now."  ^self ]
						ifFalse:
							[ "different hierarchy, remove + add."
							aUserInputEvent hand removeHalo.
							aUserInputEvent shiftPressed
								ifTrue: [ stack second "first is still the just removed halo" ]
								ifFalse: [ worldContainer ] ] ]
				ifNone: [ "existingHalo is on the World, defer to #transferHalo: for now."  ^self ] ].
	"If modifier key is pressed, start at innermost (the target), otherwise the outermost (direct child of the world (self))."
	haloTarget := (innermost == self or: [aUserInputEvent shiftPressed])
		ifTrue: [ innermost ]
		ifFalse:
			 [ "Find the outermost owner that wants it."
			innermost withAllOwners reversed allButFirst
				detect: [ : each | each wantsHaloFromClick ]
				ifNone: [ "haloTarget has its own mouseDown handler, don't halo."  ^ self ] ].
	"Now that we have the haloTarget, show the halo."
	aUserInputEvent hand
		newMouseFocus: haloTarget
		event: aUserInputEvent.
	haloTarget invokeHaloOrMove: aUserInputEvent.
	"aUserInputEvent has been consumed, don't let it cause any further side-effects."
	aUserInputEvent ignore
]

{ #category : #'events-processing' }
PasteUpMorph >> tryInvokeKeyboardShortcut: aKeyboardEvent [

	aKeyboardEvent commandKeyPressed ifFalse: [^ self].
	
	aKeyboardEvent keyCharacter caseOf: {
		[$R] -> [Utilities browseRecentSubmissions].
		[$L] -> [self findAFileList: aKeyboardEvent].
		[$O] -> [self findAMonticelloBrowser].
		[$P] -> [self findAPreferencesPanel: aKeyboardEvent].
		"[$Z] -> [ChangeList browseRecentLog]."
		[$]] -> [Smalltalk snapshot: true andQuit: false].
	} otherwise: [^ self "no hit"].
	
	aKeyboardEvent ignore "hit!".
]

{ #category : #'events-processing' }
PasteUpMorph >> tryInvokeMetaMenu: anEvent [

	| innerMost target |
	Morph metaMenuForAll ifFalse: [^ self].
	Preferences eToyFriendly ifTrue: [^ self].
	
	innerMost := (self morphsAt: anEvent position unlocked: true) first.
	
	"Traverse the owner chain if some morph does not want to show its meta menu."
	target := innerMost.
	[target isNil or: [target wantsMetaMenu]] whileFalse: [target := target owner].
	target ifNil: [^ self].
	
	target invokeMetaMenu: anEvent.
	anEvent ignore.
]

{ #category : #'world menu' }
PasteUpMorph >> undoOrRedoCommand [
	"Undo or redo the last command recorded in the world"

	^ self commandHistory undoOrRedoCommand
]

{ #category : #misc }
PasteUpMorph >> unhideHiddenObjects [
	self allMorphsDo:
		[:m | m show]
]

{ #category : #name }
PasteUpMorph >> unusedMorphNameLike: stem [
	"Answer a suitable name for a morph in this world, based on the stem provided"

	| names |
	names := self allKnownNames.
	^ Utilities keyLike: stem asString satisfying:
		[:aName | (names includes: aName) not]
]

{ #category : #recompilation }
PasteUpMorph >> updateStatePostRecompile [
	"worldState refers to blocks in its alarms and stepList inst vars.  These should be rebuilt post recompileAll"
	worldState convertAlarms; convertStepList
]

{ #category : #misc }
PasteUpMorph >> updateStatusForAllScriptEditors [
	self allScriptEditors do: [:anEditor | anEditor updateStatus]
]

{ #category : #accessing }
PasteUpMorph >> useRoundedCorners [
	"Somewhat special cased because we do have to fill Display for this"
	super useRoundedCorners.
	self == self world ifTrue:[Display bits primFill: 0]. "done so that we *don't* get a flash"
]

{ #category : #'WiW support' }
PasteUpMorph >> validateMouseEvent: evt [

	
]

{ #category : #cursor }
PasteUpMorph >> valueAtCursor [
	"Answer the submorph of mine indexed by the value of my 'cursor' slot"

	submorphs isEmpty ifTrue: [^ self presenter standardPlayer costume].
	^ (submorphs at: ((cursor truncated max: 1) min: submorphs size)) morphRepresented
]

{ #category : #cursor }
PasteUpMorph >> valueAtCursor: aMorph [
	submorphs isEmpty ifTrue: [^ self].
	self rectifyCursor.
	self replaceSubmorph: self valueAtCursor by: aMorph
]

{ #category : #copying }
PasteUpMorph >> veryDeepCopyWith: deepCopier [
	"See storeDataOn:"

	^ self isWorldMorph
		ifTrue: [self]	"never copy the World"
		ifFalse: [super veryDeepCopyWith: deepCopier]
]

{ #category : #'project state' }
PasteUpMorph >> viewBox [
	"This tortured workaround arises from a situation encountered 
	in which a PasteUpMorph was directliy lodged as a submorph 
	of another PasteUpMorph of identical size, with the former 
	bearing flaps but the latter being the world"
	^ worldState
		ifNil: [super viewBox]
		ifNotNil: [worldState viewBox]
]

{ #category : #'project state' }
PasteUpMorph >> viewBox: newViewBox [ 
	"I am now displayed within newViewBox; react."

	self isWorldMorph ifTrue: [
		(self viewBox isNil or: [self viewBox extent ~= newViewBox extent]) 
			ifTrue: [worldState canvas: nil].
		worldState viewBox: newViewBox].
	
	super position: newViewBox topLeft.
	
	fullBounds := bounds := newViewBox.
]

{ #category : #viewing }
PasteUpMorph >> viewingNormally [
	"Answer whether the receiver is being viewed normally, viz not in list-view or auto-line-layout"

	^ (self showingListView or: [self autoLineLayout == true]) not

]

{ #category : #'halos and balloon help' }
PasteUpMorph >> wantsDirectionHandles [

	^ super wantsDirectionHandles and: [self isWorldMorph not]
]

{ #category : #'event handling' }
PasteUpMorph >> wantsDropFiles: anEvent [
	^self isWorldMorph
]

{ #category : #'dropping\/grabbing' }
PasteUpMorph >> wantsDroppedMorph: aMorph event: evt [
	self isWorldMorph ifTrue:[^true]. "always"
	self visible ifFalse: [^ false].  "will be a call to #hidden again very soon"
	self dropEnabled ifFalse: [^ false].
	^ true
]

{ #category : #'event handling' }
PasteUpMorph >> wantsEasySelection [
	"Answer if the receiver want easy selection mode"
	^ Preferences easySelection
]

{ #category : #'halos and balloon help' }
PasteUpMorph >> wantsHaloFor: aSubMorph [
	"Answer whether the receiver wishes for a mouse-over halo to be produced for aSubMorph"

	^ wantsMouseOverHalos == true and:
		 [self visible and:
			[isPartsBin ~~ true and:
				[self dropEnabled and:
					[aSubMorph renderedMorph isLikelyRecipientForMouseOverHalos]]]]
]

{ #category : #'halos and balloon help' }
PasteUpMorph >> wantsHaloFromClick [
	(owner isSystemWindow) ifTrue: [^ false].
	self paintBoxOrNil ifNotNil: [^ false].
	^ true.

]

{ #category : #'event handling' }
PasteUpMorph >> wantsKeyboardFocusFor: aSubmorph [
	aSubmorph inPartsBin ifTrue: [^ false].
	aSubmorph wouldAcceptKeyboardFocus ifTrue: [ ^ true].
	^ super wantsKeyboardFocusFor: aSubmorph
]

{ #category : #options }
PasteUpMorph >> wantsMouseOverHalos [
	^ wantsMouseOverHalos == true
]

{ #category : #options }
PasteUpMorph >> wantsMouseOverHalos: aBoolean [
	wantsMouseOverHalos := aBoolean
]

{ #category : #'event handling' }
PasteUpMorph >> wantsWindowEvent: anEvent [
	^self isWorldMorph or: [self windowEventHandler notNil]
]

{ #category : #'event handling' }
PasteUpMorph >> windowEvent: anEvent [
	self windowEventHandler
		ifNotNil: [^self windowEventHandler windowEvent: anEvent].

	anEvent type == #windowClose
		ifTrue: [
			^Preferences eToyFriendly 
				ifTrue: [ProjectNavigationMorph basicNew quitSqueak]
				ifFalse: [TheWorldMenu basicNew quitSession]].

]

{ #category : #'event handling' }
PasteUpMorph >> windowEventHandler [
	"This is a class variable so it is global to all projects and does not get saved"
	^WindowEventHandler
]

{ #category : #'event handling' }
PasteUpMorph >> windowEventHandler: anObject [
	"This is a class variable so it is global to all projects and does not get saved"
	WindowEventHandler := anObject

]

{ #category : #structure }
PasteUpMorph >> world [
	worldState ifNil: [^super world].
	^self
]

{ #category : #'world menu' }
PasteUpMorph >> yellowButtonClickOnDesktopWithEvent: evt [ 
	"Put up either the personalized menu or the world menu when 
	the user clicks on the morphic desktop with the yellow button. 
	The preference 'personalizedWorldMenu' governs which one 
	is used"
	| aMenu |
	Preferences personalizedWorldMenu
		ifTrue: [aMenu := MenuMorph new defaultTarget: self.
			Preferences personalizeUserMenu: aMenu.
			aMenu addLine.
			aMenu
				add: 'personalize...' translated
				target: Preferences
				action: #letUserPersonalizeMenu]
		ifFalse: [aMenu := self buildWorldMenu: evt.
			aMenu addTitle: 'World' translated].
	aMenu popUpEvent: evt in: self
]
