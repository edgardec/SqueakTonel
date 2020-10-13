"
A ProjectNavigationMorph is the standard panel of buttons for navigating and managing projects. It appears, usually at bottom left, when the classicNavigatorEnabled and showProjectNavigator preferences are enabled.

"
Class {
	#name : #ProjectNavigationMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'mouseInside',
		'soundSlider'
	],
	#classVars : [
		'LastManualPlacement'
	],
	#category : #'MorphicExtras-Navigators'
}

{ #category : #navigation }
ProjectNavigationMorph class >> preferredNavigator [

	"Preferences eToyFriendly ifTrue: [^KidNavigationMorph]."
	^ProjectNavigationMorph
]

{ #category : #buttons }
ProjectNavigationMorph >> addButtons [

	self orientedVertically ifTrue: [
		self addAColumn: (
			self makeTheButtons collect: [ :x | self inAColumn: {x}]
		)
	] ifFalse: [
		self addARow: (
			self makeTheButtons collect: [ :x | self inAColumn: {x}]
		)
	].

]

{ #category : #menus }
ProjectNavigationMorph >> addCustomMenuItems: aMenu hand: aHandMorph [

	"Add further items to the menu as appropriate"

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu 
		addUpdating: #orientationString 
		action: #toggleOrientation.

]

{ #category : #'private - ui' }
ProjectNavigationMorph >> amountToShowWhenSmall [

	^7	"if no part of the buttons is visible, we chew up fewer cycles"
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonFind [
	"Answer a button for finding/loading projects"

	^ self makeButton: 'FIND' balloonText: 'Click here to find a project.  Hold down this button to reveal additional options.' translated for: #findAProjectSimple

]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonFlaps [

	^self inFlapsSuppressedMode ifTrue: [
		self makeButton: 'Show tabs' translated balloonText: 'Show tabs' translated for: #toggleFlapsSuppressed
	] ifFalse: [
		self makeButton: 'Hide tabs' translated balloonText: 'Hide tabs' translated for: #toggleFlapsSuppressed
	].


]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonFullScreen [

	^self inFullScreenMode ifTrue: [
		self makeButton: 'Browser Reentry' translated balloonText: 'Re-enter the browser' translated for: #fullScreenOff
	] ifFalse: [
		self makeButton: 'Escape Browser' translated balloonText: 'Use the full screen' translated for: #fullScreenOn
	]


]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonGoTo [

	^self makeButton: 'GO TO' translated balloonText: 'Go to another project' translated for: #gotoAnother

]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonLanguage [
	"Answer a button for finding/loading projects"
	^ SimpleButtonDelayedMenuMorph new target: self;
		 borderStyle: BorderStyle raised;
		 color: self colorForButtons;
		 label: Project current naturalLanguage font: self fontForButtons;
		 setBalloonText: 'Click here to choose your language.' translated;
		 actionSelector: #chooseLanguage
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonNewProject [

	^self makeButton: 'NEW' translated balloonText: 'Start a new project' translated for: #newProject

]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonNewer [

	^self makeButton: 'Newer?' translated balloonText: 'Is there a newer version of this project ?' translated for: #getNewerVersionIfAvailable
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonNext [

	^self makeButton: 'NEXT >' translated balloonText: 'Next project' translated for: #nextProject
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonPaint [

	| pb oldArgs brush myButton m |

	myButton := self makeButton: '' balloonText: 'Make a painting' translated for: #doNewPainting.
	pb := PaintBoxMorph new submorphNamed: #paint:.
	pb ifNil: [
		(brush := Form extent: 16@16 depth: 16) fillColor: Color red
	] ifNotNil: [
		oldArgs := pb arguments.
		brush := oldArgs third.
		brush := brush copy: (2@0 extent: 42@38).
		brush := brush scaledToSize: brush extent // 2.
	].
	myButton addMorph: (m := brush asMorph lock).
	myButton extent: m extent + (myButton borderWidth + 6).
	m position: myButton center - (m extent // 2).

	^myButton

"brush := (ScriptingSystem formAtKey: 'Painting')."


]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonPrev [

	^self makeButton: '< PREV' translated balloonText: 'Previous project' translated for: #previousProject
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonPublish [
	"Answer a button for publishing the project"

	^ self makeButton: 'PUBLISH IT!' translated balloonText: 'Click here to save a project.  Hold down this button to reveal additional publishing options' translated for: #publishProject
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonQuit [
	"Make and answer a button whose pressing will result in quitting out of Squeak."

	^self makeButton: 'QUIT' translated balloonText: 'Quit Etoys (without saving)' translated for: #quitSqueak

]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonTell [

	^self makeButton: 'Tell!' translated balloonText: 'Tell a friend about this project' translated for: #tellAFriend

]

{ #category : #'the buttons' }
ProjectNavigationMorph >> buttonUndo [
	"Build and return a fresh Undo button for me."

	^ self makeUpdatingButtonWithBalloonText:  'Undo or redo the last undoable action' actionSelector: #undoOrRedoLastCommand wordingSelector: #undoButtonWording


]

{ #category : #private }
ProjectNavigationMorph >> checkForRebuild [
	| lastScreenMode flapsSuppressed |

	lastScreenMode := DisplayScreen displayIsFullScreen.
	flapsSuppressed := Project current flapsSuppressed.
	((self valueOfProperty: #currentNavigatorVersion) = self currentNavigatorVersion
			and: [lastScreenMode = self inFullScreenMode
			and: [flapsSuppressed = self inFlapsSuppressedMode
			and: [(self valueOfProperty: #includeSoundControlInNavigator) = 
						Preferences includeSoundControlInNavigator]]]) ifFalse: [
		self 
			setProperty: #includeSoundControlInNavigator 
			toValue: Preferences includeSoundControlInNavigator.
		self setProperty: #flapsSuppressedMode toValue: flapsSuppressed.
		self setProperty: #showingFullScreenMode toValue: lastScreenMode.
		self setProperty: #currentNavigatorVersion toValue: self currentNavigatorVersion.
		self removeAllMorphs.
		self addButtons.
	].

]

{ #category : #'the actions' }
ProjectNavigationMorph >> chooseLanguage [

	Project current chooseNaturalLanguage
]

{ #category : #accessing }
ProjectNavigationMorph >> color: newColor [

	| buttonColor |

	super color: newColor.
	buttonColor := color darker.
	self submorphsDo: [:m | m submorphsDo: [:n | n color: buttonColor]]
]

{ #category : #buttons }
ProjectNavigationMorph >> colorForButtons [

	^color darker
]

{ #category : #private }
ProjectNavigationMorph >> currentNavigatorVersion [
	"Answer the current navigator version."

	^ 31		"since these guys get saved, we fix them up if they are older versions"
]

{ #category : #initialization }
ProjectNavigationMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color orange
]

{ #category : #'the actions' }
ProjectNavigationMorph >> doFindButtonMenuEvent: evt [

	| selection |
	selection := UIManager default chooseFrom:{
		'find a project' translated.
		'find a project (more places)' translated.
		'find any file' translated.
		'search the SuperSwiki' translated.
	} values: { 
		[self findAProjectSimple].
		[self findAProject].
		[self findAnything].
		[self findSomethingOnSuperSwiki].
	} title: 'Find options' translated.
	selection ifNil: [^self].
	selection value.


]

{ #category : #'the actions' }
ProjectNavigationMorph >> doNewPainting [
	
	| w f |

	w := self world.
	w assureNotPaintingElse: [^ self].
	(f := self owner flapTab) ifNotNil: [f hideFlap].
	w makeNewDrawing: (self primaryHand lastEvent copy setPosition: w center)

]

{ #category : #'the actions' }
ProjectNavigationMorph >> doPublishButtonMenuEvent: evt [

	| selection |
	selection := UIManager default chooseFrom: {
		'Publish' translated.
		'Publish As...' translated.
		'Publish to Different Server' translated.
		 'edit project info' translated.
	} values: {
		[self publishProject].
		[self publishProjectAs].
		[self publishDifferent].
		[self editProjectInfo].
	} title:  'Publish options' translated.
	selection ifNil: [^self].
	selection value.


]

{ #category : #'the actions' }
ProjectNavigationMorph >> editProjectInfo [

	Smalltalk at: #EToyProjectDetailsMorph ifPresent:[:aClass|
		aClass
			getFullInfoFor: (self world ifNil: [^self]) project
			ifValid: []
			expandedFormat: true
	].
]

{ #category : #'the actions' }
ProjectNavigationMorph >> findAProject [

	FileList2 
		morphicViewProjectLoader2InWorld: self world
		reallyLoad: true
		dirFilterType: #initialDirectoryList
]

{ #category : #'the actions' }
ProjectNavigationMorph >> findAProjectSimple [

	FileList2 
		morphicViewProjectLoader2InWorld: self world 
		reallyLoad: true
		dirFilterType: #limitedSuperSwikiDirectoryList
]

{ #category : #'the actions' }
ProjectNavigationMorph >> findAnything [

	FileList2 morphicViewGeneralLoaderInWorld: self world
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> findSomethingOnSuperSwiki [

	| projectServers server index |
	projectServers := ServerDirectory projectServers.
	projectServers isEmpty
		ifTrue: [^self].
	projectServers size = 1
		ifTrue: [server := projectServers first]
		ifFalse: [index := UIManager default chooseFrom: (projectServers collect: [:each | (ServerDirectory nameForServer: each) translatedIfCorresponds]) 
				title: 'Choose a super swiki:' translated.
			index > 0
				ifTrue: [server := projectServers at: index]
				ifFalse: [^self]].
	Smalltalk at: #EToyProjectQueryMorph ifPresent:[:aClass| aClass onServer: server].
]

{ #category : #buttons }
ProjectNavigationMorph >> fontForButtons [
	^ Preferences standardButtonFont
]

{ #category : #'the actions' }
ProjectNavigationMorph >> fullScreenOff [

	self setProperty: #showingFullScreenMode toValue: false.
	DisplayScreen fullScreenOff.
	self removeProperty: #currentNavigatorVersion.
	mouseInside := false.

]

{ #category : #'the actions' }
ProjectNavigationMorph >> fullScreenOn [

	self setProperty: #showingFullScreenMode toValue: true.
	DisplayScreen fullScreenOn.
	self removeProperty: #currentNavigatorVersion.
	mouseInside := false.

]

{ #category : #'the actions' }
ProjectNavigationMorph >> getNewerVersionIfAvailable [

	(self world ifNil: [^Beeper beep]) project loadFromServer: true.


]

{ #category : #'the actions' }
ProjectNavigationMorph >> gotoAnother [

	Smalltalk at: #EToyProjectHistoryMorph ifPresent:[:aClass| aClass new openInWorld].
]

{ #category : #'event handling' }
ProjectNavigationMorph >> handlesMouseOver: evt [

	^true
]

{ #category : #testing }
ProjectNavigationMorph >> inFlapsSuppressedMode [

	^(self valueOfProperty: #flapsSuppressedMode) == true
]

{ #category : #testing }
ProjectNavigationMorph >> inFullScreenMode [

	^(self valueOfProperty: #showingFullScreenMode) == true
]

{ #category : #initialization }
ProjectNavigationMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self layoutInset: 6;
	  hResizing: #shrinkWrap;
	  vResizing: #shrinkWrap;
	  useRoundedCorners.
	mouseInside := false.

]

{ #category : #'dropping\/grabbing' }
ProjectNavigationMorph >> justDroppedInto: aMorph event: anEvent [

	self setProperty: #stickToTop toValue: nil.
	self positionVertically.
	LastManualPlacement := {self position. self valueOfProperty: #stickToTop}.
	super justDroppedInto: aMorph event: anEvent.
	self step
]

{ #category : #'the buttons' }
ProjectNavigationMorph >> languageIcon [
	^ (ColorForm
	extent: 19@18
	depth: 4
	fromArray: #( 4294967295 4294967295 4293918720 4294967206 2183331839 4293918720 4294946286 3972145919 4293918720 4294631150 3430031919 4293918720 4289588973 3396477476 4293918720 4292799965 3399692836 4293918720 4208913868 724784466 804257792 4141735107 858993445 804257792 4140616899 1127429205 804257792 4174171340 3006481493 804257792 4174171340 3274982741 804257792 4170435788 3409204562 804257792 4280497100 1429493074 4293918720 4280431429 1429558562 4293918720 4294059093 1431654959 4293918720 4294919237 1431446271 4293918720 4294967074 572719103 4293918720 4294967295 4294967295 4293918720)
	offset: 0@0)
	colorsFromArray: #(#(0.0 0.0 0.0) #(1.0 1.0 1.0) #(0.376 0.376 0.784) #(0.357 0.357 0.733) #(0.231 0.231 0.474) #(0.494 0.494 0.964) #(0.498 0.498 0.933) #(0.376 0.376 0.706) #(0.419 0.419 0.78) #(0.415 0.415 0.776) #(0.595 0.595 0.972) #(0.638 0.638 0.968) #(0.654 0.654 0.96) #(0.686 0.686 0.96) #(0.71 0.71 0.964) #( )  )
]

{ #category : #buttons }
ProjectNavigationMorph >> makeButton: aString balloonText: anotherString for: aSymbol [

	^ SimpleButtonDelayedMenuMorph new target: self;
		 borderStyle: BorderStyle raised;
		 color: self colorForButtons;
		 label: aString font: self fontForButtons;
		 setBalloonText: anotherString;
		 actionSelector: aSymbol
]

{ #category : #buttons }
ProjectNavigationMorph >> makeTheAdvancedButtons [

	^{
		self buttonNewProject.
		self buttonShare.
		self buttonPrev.
		self buttonNext.
		self buttonPublish.
		self buttonNewer.
		self buttonTell.
		self buttonFind.
		self buttonFullScreen.
		"self buttonFlaps."
		self buttonPaint.
	},
	(
		Preferences includeSoundControlInNavigator ifTrue: [{self buttonSound}] ifFalse: [#()]
	),
	{
		self buttonLanguage.
		self buttonUndo.
		self buttonQuit.
	}

]

{ #category : #buttons }
ProjectNavigationMorph >> makeTheButtons [
	^ Preferences showAdvancedNavigatorButtons
		ifTrue: [self makeTheAdvancedButtons]
		ifFalse: [self makeTheSimpleButtons]
]

{ #category : #buttons }
ProjectNavigationMorph >> makeTheSimpleButtons [

	^{
		self buttonNewProject.

		self buttonPrev.
		self buttonNext.
		self buttonPublish.
		self buttonFind.
		self buttonFullScreen.

		self buttonPaint.
	},
	(
		Preferences includeSoundControlInNavigator ifTrue: [{self buttonSound}] ifFalse: [#()]
	),
	{
		self buttonLanguage.
		self buttonUndo.
		self buttonQuit.
	}

]

{ #category : #buttons }
ProjectNavigationMorph >> makeUpdatingButtonWithBalloonText: balloonString actionSelector: actionSymbol wordingSelector: wordingSymbol [
	"Answer a button  whose target is the receiver (i.e. a ProjectNavigationMorph), who gets its wording by sending the wordingSelector to me.  The given string"

	| aButton |
	aButton := UpdatingSimpleButtonMorph new.
	aButton
		target: self;
		borderStyle: BorderStyle raised;
		color: self colorForButtons;
		label: '-' font: self fontForButtons;
		setBalloonText: balloonString translated;
		actionSelector: actionSymbol;
		wordingSelector: wordingSymbol.
	aButton step.
	^ aButton
	
	
]

{ #category : #'WiW support' }
ProjectNavigationMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^mouseInside == true ifTrue: [26] ifFalse: [25]

		"Navigators are behind menus and balloons, but in front of most other stuff"
]

{ #category : #'event handling' }
ProjectNavigationMorph >> mouseEnter: evt [

	(self worldBounds containsPoint: evt cursorPoint) ifFalse: [^self].
	mouseInside := true.
	self positionVertically.
	
]

{ #category : #'event handling' }
ProjectNavigationMorph >> mouseLeave: evt [

	self world ifNil: [^self].		"can happen after delete from control menu"
	(self worldBounds containsPoint: evt cursorPoint) ifFalse: [^self].
	mouseInside := false.
	self positionVertically.

]

{ #category : #'the actions' }
ProjectNavigationMorph >> newProject [

	MorphicProject openViewOn: nil

]

{ #category : #'the actions' }
ProjectNavigationMorph >> nextProject [

	Project advanceToNextProject.
	Beeper beep.
]

{ #category : #initialization }
ProjectNavigationMorph >> openInWorld: aWorld [

	LastManualPlacement ifNotNil: [
		self position: LastManualPlacement first.
		self setProperty: #stickToTop toValue: LastManualPlacement second.
	].
	super openInWorld: aWorld.
]

{ #category : #'private - ui' }
ProjectNavigationMorph >> orientationString [
	^ (self orientedVertically
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'vertical orientation' translated
]

{ #category : #'private - ui' }
ProjectNavigationMorph >> orientedVertically [

	^self valueOfProperty: #orientedVertically ifAbsent: [false]

]

{ #category : #'the actions' }
ProjectNavigationMorph >> positionVertically [

	| wb stickToTop |

	owner == self world ifFalse: [^self].
	wb := self worldBounds.
	stickToTop := self valueOfProperty: #stickToTop.
	stickToTop ifNil: [
		stickToTop := (self top - wb top) abs < (self bottom - wb bottom) abs.
		self setProperty: #stickToTop toValue: stickToTop.
	].
	mouseInside == true ifTrue: [
		stickToTop ifTrue: [
			self top: wb top
		] ifFalse: [
			self bottom: wb bottom
		].
	] ifFalse: [
		stickToTop ifTrue: [
			self bottom: wb top + self amountToShowWhenSmall
		] ifFalse: [
			self top: wb bottom - self amountToShowWhenSmall
		].
	].


]

{ #category : #'the actions' }
ProjectNavigationMorph >> previousProject [

	Project returnToPreviousProject.
	Project current exit.	"go to parent if no previous"
	Beeper beep.
]

{ #category : #'the actions' }
ProjectNavigationMorph >> publishDifferent [

	self 
		publishStyle: #initialDirectoryListForProjects 
		forgetURL: true
		withRename: false

]

{ #category : #'the actions' }
ProjectNavigationMorph >> publishProject [

	self world paintBoxOrNil ifNotNil: [
		(self confirm: 'You seem to be painting a sketch.
Do you continue and publish the project with the paint tool?' translated) ifFalse: [^ self].
	].
	self 
		publishStyle: #limitedSuperSwikiPublishDirectoryList 
		forgetURL: false
		withRename: false
]

{ #category : #'the actions' }
ProjectNavigationMorph >> publishProjectAs [

	self 
		publishStyle: #limitedSuperSwikiPublishDirectoryList 
		forgetURL: false
		withRename: true
]

{ #category : #'the actions' }
ProjectNavigationMorph >> publishStyle: aSymbol forgetURL: aBoolean withRename: renameBoolean [

	| w saveOwner primaryServer rename |

	w := self world ifNil: [^Beeper beep].
	w setProperty: #SuperSwikiPublishOptions toValue: aSymbol.

	primaryServer := w project primaryServerIfNil: [nil].
	rename := ((primaryServer notNil
		and: [primaryServer acceptsUploads]) not)
		or: [renameBoolean].
	rename := rename or: [Smalltalk globals at: #DAVMultiUserServerDirectory ifPresent: [:c | primaryServer isKindOf: c] ifAbsent: [false]].
	w setProperty: #SuperSwikiRename toValue: rename.

	saveOwner := owner.
	self delete.
	[w project 
		storeOnServerShowProgressOn: self 
		forgetURL: aBoolean | rename]
		ensure: [saveOwner addMorphFront: self]
]

{ #category : #'the actions' }
ProjectNavigationMorph >> quitSqueak [
	"Obtain a confirmation from the user, and if the answer is true, quite Squeak summarily"

	(self confirm: 'Are you sure you want to Quit Squeak?' translated) ifFalse: [^ self].
	
	Smalltalk snapshot: false andQuit: true

]

{ #category : #ui }
ProjectNavigationMorph >> retractIfAppropriate [

	mouseInside := false.
	self positionVertically.

]

{ #category : #menus }
ProjectNavigationMorph >> showMenuFor: aSymbol event: evt [

	(aSymbol == #publishProject or: [aSymbol == #publishProjectSimple]) ifTrue: [
		self doPublishButtonMenuEvent: evt.
		^true		"we did show the menu"
	].
	(aSymbol == #findAProject or: [aSymbol == #findAProjectSimple]) ifTrue: [
		self doFindButtonMenuEvent: evt.
		^true		"we did show the menu"
	].
	^false

]

{ #category : #'stepping and presenter' }
ProjectNavigationMorph >> step [
	| wb |

	owner ifNil: [^ self].
	(self ownerThatIsA: HandMorph) ifNotNil: [^self].
	self checkForRebuild.
	owner == self world ifTrue: [
		owner addMorphInLayer: self.
		wb := self worldBounds.
		self left < wb left ifTrue: [self left: wb left].
		self right > wb right ifTrue: [self right: wb right].
		self positionVertically.
	].
]

{ #category : #'stepping and presenter' }
ProjectNavigationMorph >> stepTime [

	^1000
]

{ #category : #'the actions' }
ProjectNavigationMorph >> tellAFriend [

	self world project tellAFriend
]

{ #category : #'the actions' }
ProjectNavigationMorph >> toggleFlapsSuppressed [

	Project current toggleFlapsSuppressed
]

{ #category : #'the actions' }
ProjectNavigationMorph >> toggleOrientation [

	self setProperty: #orientedVertically toValue: self orientedVertically not.
	self setProperty: #currentNavigatorVersion toValue: self currentNavigatorVersion - 1.


]

{ #category : #'stepping and presenter' }
ProjectNavigationMorph >> undoButtonWording [
	"Answer the wording for the Undo button."

	| wdng |
	wdng := Project current world commandHistory undoOrRedoMenuWording.
	(wdng endsWith: ' (z)') ifTrue: [
		wdng := wdng copyFrom: 1to: wdng size - 4].
	^ wdng
]

{ #category : #'the actions' }
ProjectNavigationMorph >> undoLastCommand [
	
	self world commandHistory undoLastCommand
]

{ #category : #'the actions' }
ProjectNavigationMorph >> undoOrRedoLastCommand [
	"Undo or redo the last command, as approrpiate."

	^ Project current world commandHistory undoOrRedoCommand
]

{ #category : #'stepping and presenter' }
ProjectNavigationMorph >> wantsSteps [

	^true
]
