"
A tool for controlling and viewing all scripts in a project.  The tool has an open and a closed form.  In the closed form, stop-step-go buttons are available, plus a control for opening the tool up.  In the open form, it has a second row of controls that govern which scripts should be shown, followed by the individual script items.
"
Class {
	#name : #AllScriptsTool,
	#superclass : #AlignmentMorph,
	#instVars : [
		'showingOnlyActiveScripts',
		'showingAllInstances',
		'showingOnlyTopControls'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'instance creation' }
AllScriptsTool class >> allScriptsToolForActiveWorld [
	"Launch an AllScriptsTool to view scripts of the active world"

	| aTool |
	aTool := self newColumn.
	aTool initializeFor: self currentWorld presenter.
	^ aTool
]

{ #category : #printing }
AllScriptsTool class >> defaultNameStemForInstances [
	"Answer the default name stem for new instances of this class"

	^ 'All Scripts' translatedNoop
]

{ #category : #'parts bin' }
AllScriptsTool class >> descriptionForPartsBin [
	"Answer a description for use in parts bins"

	^ self partName: 	'All Scripts' translatedNoop
		categories:		{'Scripting' translatedNoop}
		documentation:	'A tool allowing you to monitor and change the status of all scripts in your project' translatedNoop
]

{ #category : #'class initialization' }
AllScriptsTool class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'instance creation' }
AllScriptsTool class >> launchAllScriptsToolFor: aPresenter [
	"Launch an AllScriptsTool to view scripts of the given presenter"

	| aTool |
	aTool := self newColumn.
	aTool initializeFor: aPresenter.
	self currentHand attachMorph: aTool.
	aPresenter associatedMorph world startSteppingSubmorphsOf: aTool

]

{ #category : #'class initialization' }
AllScriptsTool class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#AllScriptsTool. #allScriptsToolForActiveWorld.	'All Scripts' translatedNoop. 'A tool that lets you see and control all the running scripts in your project' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#AllScriptsTool. #allScriptsToolForActiveWorld. 'All Scripts' translatedNoop. 'A tool that lets you control all the running scripts in your world' translatedNoop}
						forFlapNamed: 'Scripting'.
						cl registerQuad: {#AllScriptsTool. #allScriptsToolForActiveWorld. 'All Scripts' translatedNoop. 'A tool that lets you see and control all the running scripts in your project' translatedNoop}
						forFlapNamed: 'Widgets']
]

{ #category : #'class initialization' }
AllScriptsTool class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #initialization }
AllScriptsTool >> addSecondLineOfControls [
	"Add the second line of controls"

	| aRow outerButton aButton worldToUse |
	aRow := AlignmentMorph newRow listCentering: #center; color: Color transparent.
	outerButton := AlignmentMorph newRow.
	outerButton wrapCentering: #center; cellPositioning: #leftCenter.
	outerButton color:  Color transparent.
	outerButton hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	outerButton addMorph: (aButton := UpdatingThreePhaseButtonMorph checkBox).
	aButton
		target: self;
		actionSelector: #toggleWhetherShowingOnlyActiveScripts;
		getSelector: #showingOnlyActiveScripts.
	outerButton addTransparentSpacerOfSize: (4@0).
	outerButton addMorphBack: (StringMorph contents: 'tickers only' translated font: ScriptingSystem fontForEToyButtons) lock.
	outerButton setBalloonText: 'If checked, then only scripts that are paused or ticking will be shown' translated.
	aRow addMorphBack: outerButton.

	aRow addTransparentSpacerOfSize: 20@0.
	aRow addMorphBack: self helpButton.

	aRow addTransparentSpacerOfSize: 20@0.

	outerButton := AlignmentMorph newRow.
	outerButton wrapCentering: #center; cellPositioning: #leftCenter.
	outerButton color:  Color transparent.
	outerButton hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	outerButton addMorph: (aButton := UpdatingThreePhaseButtonMorph checkBox).
	aButton
		target: self;
		actionSelector: #toggleWhetherShowingAllInstances;
		getSelector: #showingAllInstances.
	outerButton addTransparentSpacerOfSize: (4@0).
	outerButton addMorphBack: (StringMorph contents: 'all instances' translated font: ScriptingSystem fontForEToyButtons) lock.
	outerButton setBalloonText: 'If checked, then entries for all instances will be shown, but if not checked, scripts for only one representative of each different kind of object will be shown.  Consult the help available by clicking on the purple ? for more information.' translated.
	aRow addMorphBack: outerButton.

	self addMorphBack: aRow.
	worldToUse := self isInWorld ifTrue: [self world] ifFalse: [self currentWorld].
	worldToUse presenter reinvigorateAllScriptsTool: self.
	self layoutChanged.
]

{ #category : #initialization }
AllScriptsTool >> dismissButton [
	"Answer a button whose action would be to dismiss the 
	receiver "
	| aButton |
	aButton := super dismissButton.
	aButton setBalloonText: 'Click here to remove this tool from the screen; you can get another one any time you want from the Widgets flap' translated.
	^ aButton
]

{ #category : #initialization }
AllScriptsTool >> initializeFor: ignored [
	"Initialize the receiver as a tool which shows, and allows the user to change the status of, all the instantiations of all the user-written scripts in the scope of the containing pasteup's presenter"

	| aRow aButton |
	showingOnlyActiveScripts := true.
	showingAllInstances := true.
	showingOnlyTopControls := true.
	self color: Color brown muchLighter muchLighter; wrapCentering: #center; cellPositioning: #topCenter; vResizing: #shrinkWrap; hResizing: #shrinkWrap.
	self useRoundedCorners.
	self borderWidth: 4; borderColor: Color brown darker.
	aRow := AlignmentMorph newRow.
	aRow listCentering: #justified; color: Color transparent.
	aButton := self tanOButton.
	aRow addMorphFront: aButton.
	aRow addTransparentSpacerOfSize: 10.
	aRow addMorphBack: ScriptingSystem scriptControlButtons.
	aRow addTransparentSpacerOfSize: 10.
	aRow addMorphBack: self openUpButton.
	self addMorphFront: aRow.


]

{ #category : #'parts bin' }
AllScriptsTool >> initializeToStandAlone [
	super initializeToStandAlone.
	self
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		hResizing: #spaceFill;
		extent: 1 @ 1;
		vResizing: #spaceFill;
		rubberBandCells: true.
	self initializeFor: self currentWorld presenter
]

{ #category : #toggles }
AllScriptsTool >> openUpButton [
	"Answer a button whose action would be to open up the receiver or snap it back closed"

	| aButton |
	aButton := UpdatingThreePhaseButtonMorph blackTriangularOpener.
	aButton getSelector: #showingOnlyTopControls.
	aButton
		target: self;
		actionSelector: #toggleWhetherShowingOnlyTopControls;
		setBalloonText: 'open or close the lower portion that shows individual scripts' translated.
	^ aButton
]

{ #category : #initialization }
AllScriptsTool >> presentHelp [
	"Sent when a Help button is hit; provide the user with some form of help for the tool at hand"

	| aFlapTab |
	aFlapTab := ScriptingSystem assureFlapOfLabel: 'All Scripts' translated withContents: self helpString.
	aFlapTab showFlap
]

{ #category : #toggles }
AllScriptsTool >> showingAllInstances [
	"Answer whether the receiver is currently showing controls for all instances of each uniclass."
 
	^ showingAllInstances 
]

{ #category : #toggles }
AllScriptsTool >> showingOnlyActiveScripts [
	"Answer whether the receiver is currently showing only active scripts"
 
	^ showingOnlyActiveScripts 
]

{ #category : #toggles }
AllScriptsTool >> showingOnlyTopControls [
	"Answer whether the receiver is currently showing only the top controls"
 
	^ showingOnlyTopControls ifNil: [showingOnlyTopControls := true]
]

{ #category : #'stepping and presenter' }
AllScriptsTool >> step [
	"If the list of scripts to show has changed, refresh my contents"

	self showingOnlyTopControls ifFalse:
		[self presenter reinvigorateAllScriptsTool: self].
]

{ #category : #testing }
AllScriptsTool >> stepTime [
	"Answer the interval between steps -- in this case a leisurely 4 seconds"

	^ 4000
]

{ #category : #toggles }
AllScriptsTool >> toggleWhetherShowingAllInstances [
	"Toggle whether the receiver is showing all instances or only one exemplar per uniclass"

	showingAllInstances := showingAllInstances not.
	self presenter reinvigorateAllScriptsTool: self
]

{ #category : #toggles }
AllScriptsTool >> toggleWhetherShowingOnlyActiveScripts [
	"Toggle whether the receiver is showing only active scripts"

	showingOnlyActiveScripts := showingOnlyActiveScripts not.
	self presenter reinvigorateAllScriptsTool: self
]

{ #category : #toggles }
AllScriptsTool >> toggleWhetherShowingOnlyTopControls [
	"Toggle whether the receiver is showing only the stop/step/go line or the full whammy"

	| aCenter |
	showingOnlyTopControls := self showingOnlyTopControls not.
	aCenter := self center x.
	self showingOnlyTopControls
		ifTrue:
			[self removeAllButFirstSubmorph]
		ifFalse:
			[self addSecondLineOfControls.
			self presenter reinvigorateAllScriptsTool: self].
	WorldState addDeferredUIMessage:
		[self center: (aCenter @ self center y)]
	
]

{ #category : #testing }
AllScriptsTool >> wantsSteps [
	"Answer whether the receiver wishes to receive the #step message"

	 ^ true
]
