"
Presents an EToy script to the user on the screen.  Has in it:

a Morph with the controls for the script.
a Morph with the tiles.  Either PhraseMorphs and TileMorphs, 
	or a TwoWayScroller with SyntaxMorphs in it.

WritingUniversalTiles -- only vlaid while a project is being written out.  
		True if using UniversalTiles in that project.
"
Class {
	#name : #ScriptEditorMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'scriptName',
		'firstTileRow',
		'timeStamp',
		'playerScripted',
		'handWithTile',
		'showingMethodPane',
		'threadPolygon',
		'previousDropHandPosition',
		'dropSpaces'
	],
	#classVars : [
		'Evaluator',
		'GenerateParseNodeDirectly',
		'Rewrite',
		'TrackedEditor',
		'WritingUniversalTiles'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'new-morph participation' }
ScriptEditorMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #'class initialization' }
ScriptEditorMorph class >> initialize [

	Rewrite := true.
	GenerateParseNodeDirectly := true.
]

{ #category : #'instance creation' }
ScriptEditorMorph class >> writingUniversalTiles [
	"Only valid during the write of a Project."

	^ WritingUniversalTiles
]

{ #category : #'instance creation' }
ScriptEditorMorph class >> writingUniversalTiles: boolean [

	WritingUniversalTiles := boolean
]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> acceptDroppingMorph: aMorph event: evt [
	"Allow the user to add tiles and program fragments just by dropping them on this morph."

	| i slideMorph p1 p2 |

	self prepareToUndoDropOf: aMorph.
	"Find where it will go, and prepare to animate the move..."
	i := self rowInsertionIndexFor: aMorph fullBounds center.
	slideMorph := aMorph imageForm offset: 0@0.
	p1 := aMorph screenRectangle topLeft.
	aMorph delete.
	self stopTracking.
	self world displayWorld.  "Clear old image prior to animation"

	(aMorph isKindOf: PhraseTileMorph orOf: CompoundTileMorph) ifTrue:
		[aMorph aboutToBeAcceptedInScriptor].
	aMorph tileRows do: [:tileList |
		self insertTileRow: (Array with:
				(tileList first rowOfRightTypeFor: owner forActor: aMorph associatedPlayer))
			after: i.
		i := i + 1].
	self removeSpaces.
	self enforceTileColorPolicy.
	self layoutChanged.
	self fullBounds. "force layout"

	"Now animate the move, before next Morphic update.
		NOTE: This probably should use ZoomMorph instead"
	p2 := (self submorphs atPin: (i-1 max: firstTileRow)) screenRectangle topLeft.
	slideMorph slideFrom: p1 to: p2 nSteps: 5 delay: 50 andStay: true.
	self playSoundNamed: 'scritch'.
	self topEditor scriptEdited  "Keep me for editing, a copy goes into lastAcceptedScript"
]

{ #category : #'customevents-buttons' }
ScriptEditorMorph >> actuallyDestroyScript [
	"Carry out the actual destruction of the associated script."

	| aHandler itsCostume |
	self delete.
	playerScripted removeScriptNamed: scriptName.
	playerScripted actorState instantiatedUserScriptsDictionary removeKey: scriptName ifAbsent: [].
		"not quite enough yet in the multiple-instance case..."
	itsCostume := playerScripted costume.
	(aHandler := itsCostume renderedMorph eventHandler) ifNotNil:
		[aHandler forgetDispatchesTo: scriptName].
	itsCostume removeActionsSatisfying: [ :act | act receiver == playerScripted and: [ act selector == scriptName ]].
	itsCostume currentWorld removeActionsSatisfying: [ :act | act receiver == playerScripted and: [ act selector == scriptName ]].
	playerScripted updateAllViewersAndForceToShow: ScriptingSystem nameForScriptsCategory
]

{ #category : #'e-toy support' }
ScriptEditorMorph >> adaptToWorld: aWorld [

	self unhibernate	"for universal tiles"
]

{ #category : #menus }
ScriptEditorMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add custom menu items to a menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addUpdating: #autoFitString target: self action: #autoFitOnOff.
	aCustomMenu addLine.
	aCustomMenu add: 'fix layout' target: self action: #fixLayout.

]

{ #category : #buttons }
ScriptEditorMorph >> addDestroyButtonTo: aRowMorph [ 
	"Add the destroiy button at the end of the header provided"

	| aButton |
	aButton := self pinkXButton.
	aRowMorph addMorphBack: aButton.
	aButton actionSelector: #destroyScript;
			 setBalloonText: 'Destroy this script
(CAUTION!!)' translated.
	^ aRowMorph
]

{ #category : #buttons }
ScriptEditorMorph >> addDismissButtonTo: aRowMorph [
	"Add the brown dismiss button to the header"

	| aButton |
	aButton := self tanOButton.
	aRowMorph addMorphBack: aButton.
	aButton actionSelector: #dismiss;
			setBalloonText: 
'Remove this script
from the screen
(you can open it
again from a Viewer)' translated.
	^ aRowMorph
]

{ #category : #private }
ScriptEditorMorph >> addNewRow [

	| row |
	row := AlignmentMorph newRow
		vResizing: #spaceFill;
		layoutInset: 0;
		borderWidth: 0;
		extent: (bounds width)@(TileMorph defaultH);
		color: Color transparent.
	self addMorphBack: row.
	^ row

]

{ #category : #other }
ScriptEditorMorph >> addParameter [
	"Transform the receiver so that it bears a parameter.  This will require a selector change, e.g. from #script3 to #script3:"

	playerScripted startHavingParameterFor: scriptName asSymbol
]

{ #category : #buttons }
ScriptEditorMorph >> addYesNoToHand [
	"Place a test/yes/no complex in the hand of the beloved user"

	| ms messageNodeMorph aMorph |
	Preferences universalTiles
		ifTrue:
			[ms := MessageSend receiver: true selector: #ifTrue:ifFalse:
						arguments: {['do nothing']. ['do nothing']}.
			messageNodeMorph := ms asTilesIn: playerScripted class globalNames: true.
			self primaryHand attachMorph: messageNodeMorph]
		ifFalse:
			[aMorph := CompoundTileMorph new.
			self currentHand attachMorph: aMorph.
			aMorph setNamePropertyTo: 'TestTile' translated.
			aMorph position: self currentHand position.
			aMorph formerPosition: self currentHand position.
			self startSteppingSelector: #trackDropZones].
]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> assureParameterTilesValid [
	"Make certain that parameter tiles in my interior are still type valid; replace any that now intimate type errors"

	self isTextuallyCoded ifFalse:
		[(self allMorphs select: [:m | m isKindOf: ParameterTile]) do:
			[:aTile | aTile assureTypeStillValid].
		self install]
]

{ #category : #menu }
ScriptEditorMorph >> autoFitOnOff [
	"Toggle between auto fit to size of code and manual resize with scrolling"
	| tw |
	(tw := self findA: ScrollPane) ifNil: [^ self].
	(self hasProperty: #autoFitContents)
		ifTrue: [self removeProperty: #autoFitContents.
			self hResizing: #rigid; vResizing: #rigid]
		ifFalse: [self setProperty: #autoFitContents toValue: true.
			self hResizing: #shrinkWrap; vResizing: #shrinkWrap].
	tw layoutChanged
]

{ #category : #menu }
ScriptEditorMorph >> autoFitString [
	"Answer the string to put in a menu that will invite the user to 
	switch autoFit mode"
	^ ((self hasProperty: #autoFitContents)
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'auto fit' translated
]

{ #category : #other }
ScriptEditorMorph >> becomeTextuallyCoded [
	"If the receiver is not currently textually coded, make it become so now, and show its source in place in the Scriptor"

	self isTextuallyCoded ifTrue: [^ self].
	self saveScriptVersion.
	Preferences universalTiles ifFalse: [self userScriptObject becomeTextuallyCoded].
	(submorphs copyFrom: 2 to: submorphs size) do: [:m | m delete]
]

{ #category : #scripting }
ScriptEditorMorph >> bringUpToDate [
	"Make certain that the player name in my header is up to date.  Names emblazoned on submorphs of mine are handled separately by direct calls to their #bringUpToDate methods -- the responsibility here is strictly for the name in the header."

	| currentName |
	playerScripted ifNil: 
			["likely a naked test/yes/no fragment!"

			^self].
	currentName := playerScripted externalName.
	submorphs isEmpty ifTrue: [^self].
	(self firstSubmorph findDeepSubmorphThat: [:m | m knownName = 'title']
		ifAbsent: [^self]) label: currentName font: ScriptingSystem fontForTiles
]

{ #category : #buttons }
ScriptEditorMorph >> buttonRowForEditor [
	"Answer a row of buttons that comprise the header at the top of the Scriptor"

	| aRow aString aStatusMorph aButton aTile aMorph goldBoxButton aBox |
	aRow := AlignmentMorph newRow color: ScriptingSystem baseColor; layoutInset: 1.
	aRow hResizing: #spaceFill.
	aRow vResizing: #shrinkWrap.
	self addDismissButtonTo: aRow.
	aRow addTransparentSpacerOfSize: 9.

	"Player's name"
	aString := playerScripted externalName.
	aMorph := StringMorph contents: aString font: ScriptingSystem fontForTiles.
	aMorph setNameTo: 'title'.
	aRow addMorphBack: aMorph.
	aRow addTransparentSpacerOfSize: 6.

	"Script's name"
	aBox := AlignmentMorph newRow.
	aBox hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	aBox color: (Color r: 0.839 g: 1.0 b: 0.806).
	aBox borderWidth: 1.
	aBox  borderColor: (Color r: 0.645 g: 0.774 b: 0.613).
	aButton := UpdatingStringMorph new.
	aButton useStringFormat;
		target:  self;
		getSelector: #scriptTitle;
		setNameTo: 'script name';
		font: ScriptingSystem fontForNameEditingInScriptor;
		putSelector: #setScriptNameTo:;
		setProperty: #okToTextEdit toValue: true;
		step;
		yourself.
	aBox addMorph: aButton.
	aRow addMorphBack: aBox.
	aBox setBalloonText: 'Click here to edit the name of the script.' translated.
	"aRow addTransparentSpacerOfSize: 9."
	aRow addVariableTransparentSpacer.

	"Try It button"
	self hasParameter ifFalse:
		[aRow addMorphBack:
			((ThreePhaseButtonMorph
				labelSymbol: #TryIt
				target: self
				actionSelector: #tryMe
				arguments: #())
				actWhen: #whilePressed;
				balloonTextSelector: #tryMe).
		aRow addTransparentSpacerOfSize: 3].

	"Step button, only for non-Kedama"
	(self playerScripted isPrototypeTurtlePlayer or: [self hasParameter]) ifFalse:
		[aRow addMorphBack: (aButton := ThreePhaseButtonMorph
				labelSymbol: #StepMe
				target: self
				actionSelector: #stepMe
				arguments: #()).
		aButton balloonTextSelector: #stepMe.
		aRow addTransparentSpacerOfSize: 3].

	"Status controller"
	self hasParameter
		ifTrue:
			[aTile := TypeListTile new choices: Vocabulary typeChoicesForUserVariables dataType: nil.
			aTile addArrows.
			aTile setLiteral: self typeForParameter.
			aRow addMorphBack: aTile.
			aTile borderColor: Color red.
			aTile color: ScriptingSystem uniformTileInteriorColor.
			aTile setBalloonText: 'Drag from here to get a parameter tile' translated.
			aTile addCaretsAsAppropriate: true]
		ifFalse:
			[aRow addMorphBack: (aStatusMorph := self scriptInstantiation statusControlMorph)].

	"aRow addTransparentSpacerOfSize: 3."
	aRow addVariableTransparentSpacer.

	"Gold-box"
	aRow addMorphBack: (goldBoxButton := IconicButton new).
	goldBoxButton borderWidth: 0;
			labelGraphic: (ScriptingSystem formAtKey: 'RoundGoldBox'); color: Color transparent; 
			actWhen: #buttonDown;
			target: self;
			actionSelector: #offerGoldBoxMenu;
			shedSelvedge;
			setBalloonText: 'click here to get a palette of useful tiles to use in your script.' translated.
	aRow addTransparentSpacerOfSize: 6@1.

	"Menu Button"
	aButton := self menuButton.
	aButton actionSelector: #offerScriptorMenu.
	aRow addMorphBack: aButton.

	(playerScripted existingScriptInstantiationForSelector: scriptName)
		ifNotNil:
			[:inst | inst updateStatusMorph: aStatusMorph].
	^ aRow
]

{ #category : #other }
ScriptEditorMorph >> ceaseHavingAParameter [
	"Cease having a parameter"

	playerScripted ceaseHavingAParameterFor: scriptName
]

{ #category : #buttons }
ScriptEditorMorph >> chooseFrequency [
	| currentFrequency aMenu |
	currentFrequency := self scriptInstantiation frequency.
	currentFrequency = 0 ifTrue: [currentFrequency := 1].
	aMenu := MenuMorph new defaultTarget: self.
	#(1 2 5 10 25 50 100 1000 5000 10000) do:
		[:i | aMenu add: i printString selector: #setFrequencyTo: argument: i].
	
	aMenu add: 'other...' translated action: #typeInFrequency.
	aMenu addTitle: ('Choose frequency (current: {1})' translated format: {currentFrequency}).
	aMenu  popUpEvent: self currentEvent in: self world
]

{ #category : #buttons }
ScriptEditorMorph >> chooseTrigger [
	"NB; the keyStroke branch commented out temporarily until keystrokes can actually be passed along to the user's scripting code"
	
	self presentScriptStatusPopUp
]

{ #category : #other }
ScriptEditorMorph >> codeString [
	^ String streamContents: [:aStream | self storeCodeOn: aStream indent: 1]

]

{ #category : #'menu commands' }
ScriptEditorMorph >> createThreadShowing [

	| vertices |
	self deleteThreadShowing.
	vertices := OrderedCollection new.
	self tileRows do: [:row | | b |
		row first isTurtleRow ifTrue: [
			b := row first bounds.
			vertices add: ((b topLeft + (4 @ 0)) + ((0 * 0.1 * b width) @ 0)).
			0 to: 9 do: [:i |
				vertices add: ((b topLeft + (4 @ 4))+ ((i * 0.1 * b width ) @ 0)).
				vertices add: ((b bottomLeft + (4 @ -4)) + ((i * 0.1 * b width) @ 0)).
			].	
			vertices add: ((b bottomLeft + (4 @ 0)) + ((9 * 0.1 * b width) @ 0)).
		] ifFalse: [
			b := row first bounds.
			vertices add: ((b origin x + b corner x) // 2) @ (b origin y).
			vertices add: ((b origin x + b corner x) // 2) @ (b origin y + 4).
			vertices add: ((b origin x + b corner x) // 2) @ (b corner y - 4).
			vertices add: ((b origin x + b corner x) // 2) @ (b corner y).
		].
	].
	threadPolygon := PolygonMorph vertices: vertices color: Color black borderWidth: 2 borderColor: Color black.
	threadPolygon makeOpen.
	threadPolygon openInWorld.

]

{ #category : #initialization }
ScriptEditorMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
ScriptEditorMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ ScriptingSystem colorBehindTiles
]

{ #category : #'menu commands' }
ScriptEditorMorph >> deleteThreadShowing [

	threadPolygon ifNotNil: [threadPolygon delete. threadPolygon := nil].

]

{ #category : #buttons }
ScriptEditorMorph >> destroyScript [
	"At user request, and only after confirmation, destroy the script, thus removing it from the uniclass's method dictionary and removing its instantiations from all instances of uniclass, etc."

	(self confirm: 'Caution -- this destroys this script
permanently; are you sure you want to do this?' translated) ifFalse: [^ self].
	true ifTrue: [^ playerScripted removeScript: scriptName fromWorld: self world].

	self flag: #deferred.  "revisit"
	(playerScripted okayToDestroyScriptNamed: scriptName)
		ifFalse:
			[^ self inform: 'Sorry, this script is being called
from another script.' translated].

	Cursor wait showWhile: [
		self actuallyDestroyScript].
]

{ #category : #buttons }
ScriptEditorMorph >> dismiss [
	"Dismiss the scriptor, usually nondestructively.  Possibly animate the dismissal."

	| endPoint aForm startPoint topRend |
	owner ifNil: [^ self].
	scriptName ifNil: [^ self delete].  "ad hoc fixup for bkwrd compat"

	endPoint := self viewerTile ifNotNilDo: [:tile | tile topLeft] ifNil: [owner topRight].
	aForm := (topRend := self topRendererOrSelf) imageForm  offset: (0@0).
	handWithTile := nil.
	startPoint := topRend topLeft.
	topRend topRendererOrSelf delete.
	(playerScripted isExpendableScript: scriptName) ifTrue: [
		^ playerScripted removeScript: scriptName fromWorld: Project current world].
	
	Project current world displayWorld.
	aForm slideFrom: startPoint to: endPoint nSteps: 4 delay: 30.
	"The OLPC Virtual Screen wouldn't notice the last update here."
	Display forceToScreen: (endPoint extent: aForm extent).
]

{ #category : #'submorphs-add\/remove' }
ScriptEditorMorph >> dismissViaHalo [
	"The user has clicked in the delete halo-handle.  This provides a hook in case some concomitant action should be taken, or if the particular morph is not one which should be put in the trash can, for example."

	self resistsRemoval ifTrue: [^ self].
	self destroyScript
]

{ #category : #drawing }
ScriptEditorMorph >> drawOn: aCanvas [
	"may need to unhibernate the script lazily here."

	(Preferences universalTiles and: [self submorphs size < 2])
		ifTrue:
			[WorldState addDeferredUIMessage: [self unhibernate]].

	^ super drawOn: aCanvas
]

{ #category : #buttons }
ScriptEditorMorph >> editMethodDescription [
	"Edit the balloon help associated with the script"

	self userScriptObject editDescription.
	playerScripted updateAllViewers
]

{ #category : #'customevents-other' }
ScriptEditorMorph >> explainStatusAlternatives [
	"Explain the scripting-status alternatives."

		ScriptingSystem putUpInfoPanelFor:(ScriptingSystem statusHelpStringFor: playerScripted) title: 'Script Status' translated extent: 800@500
]

{ #category : #other }
ScriptEditorMorph >> extent: x [

	| newExtent tw menu |
	newExtent := x max: self minWidth @ self minHeight.
	(tw := self findA: ScrollPane) ifNil:
		["This was the old behavior"
		^ super extent: newExtent].

	(self hasProperty: #autoFitContents) ifTrue: [
		menu := MenuMorph new defaultTarget: self.
		menu addUpdating: #autoFitString target: self action: #autoFitOnOff.
		menu addTitle: 'To resize the script, uncheck the box below' translated.
		menu popUpEvent: nil in: self world	.
		^ self].

	"Allow the user to resize to any size"
	tw extent: ((newExtent x max: self firstSubmorph width)
				@ (newExtent y - self firstSubmorph height)) - (self borderWidth * 2) + (-4 @ -4).  "inset?"
	^ super extent: newExtent
]

{ #category : #menu }
ScriptEditorMorph >> fixLayout [
	self fixLayoutOfSubmorphsNotIn: IdentitySet new
]

{ #category : #menu }
ScriptEditorMorph >> fixLayoutOfSubmorphsNotIn: aCollection [ 
	self
		allMorphsDo: [:m | (aCollection includes: m)
				ifFalse: [m ~~ self
						ifTrue: [(m respondsTo: #fixLayoutOfSubmorphsNotIn:)
								ifTrue: [m fixLayoutOfSubmorphsNotIn: aCollection]].
					m layoutChanged.
					aCollection add: m]]
]

{ #category : #'objects from disk' }
ScriptEditorMorph >> fixUponLoad: aProject seg: anImageSegment [
	"We are in an old project that is being loaded from disk.
Fix up conventions that have changed."

	(aProject projectParameters at: #substitutedFont ifAbsent: [#none])
		 ~~ #none ifTrue: [ self setProperty:
#needsLayoutFixed toValue: true ].

	^ super fixUponLoad: aProject seg: anImageSegment
]

{ #category : #'tiles from method' }
ScriptEditorMorph >> fromExistingMethod: aSelector forPlayer: aPlayer [ 
	"Create tiles for this method.  "

	self initialize.
	playerScripted := aPlayer.
	self setMorph: aPlayer costume scriptName: aSelector.
	self insertUniversalTiles
]

{ #category : #other }
ScriptEditorMorph >> handUserButtonDownTile [
	"Hand the user a button-down tile, presumably to drop in the script"
	
	
	self currentHand attachMorph:
		(self presenter systemQueryPhraseWithActionString: '(Sensor anyButtonPressed)' labelled: 'button down?' translated)
	
]

{ #category : #other }
ScriptEditorMorph >> handUserButtonUpTile [
	"Hand the user a button-up tile, presumably to drop in the script"
	
	
	self currentHand attachMorph:
		(self presenter systemQueryPhraseWithActionString: '(Sensor noButtonPressed)' labelled: 'button up?' translated)
	
]

{ #category : #other }
ScriptEditorMorph >> handUserParameterTile [
	"Hand the user a parameter, presumably to drop in the script"
	
	| aTileMorph |
	aTileMorph := ParameterTile new forScriptEditor: self.
	self currentHand attachMorph: aTileMorph
]

{ #category : #other }
ScriptEditorMorph >> handUserRandomTile [
	"Hand the user a random-number tile, presumably to drop in the script"

	| functionPhrase argTile aPad |
	functionPhrase := FunctionTile new.
	argTile := (Vocabulary vocabularyNamed: 'Number') defaultArgumentTile.
	aPad := TilePadMorph new setType: #Number.
	aPad addMorphBack: argTile.
	functionPhrase operator: #random pad: aPad.
	functionPhrase openInHand
]

{ #category : #other }
ScriptEditorMorph >> handUserTileForSelf [
	"Hand the user a tile representing the player who is current the 'self' of this script"

	playerScripted tileToRefer openInHand
]

{ #category : #'event handling' }
ScriptEditorMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #'event handling' }
ScriptEditorMorph >> handlesMouseOverDragging: evt [

	^ true

]

{ #category : #buttons }
ScriptEditorMorph >> hasParameter [
	"Answer whether the receiver has a parameter"

	^ scriptName numArgs > 0
]

{ #category : #other }
ScriptEditorMorph >> hasScriptInvoking: aScriptName ofPlayer: aPlayer [
	"Answer whether the receiver has any tiles in it which invoke the given script of the given player.  Place-holder for now, needs to be implemented"
	^ false
]

{ #category : #other }
ScriptEditorMorph >> hasScriptReferencing: aSlotName ofPlayer: aPlayer [
	"Answer whether the receiver has any tiles in it which reference the given slot of the given player.  By doing a text search on the decompiled method, this is able to work both with text and with tiles.  The approach is still not perfect, because we can't really know until run-time whom the getters and setters are sent to.  But practically speaking, this is all presumably a positive."

	| stringToSearch |
	"(aPlayer isKindOf: playerScripted class) ifFalse: [^ false]."

	stringToSearch := (playerScripted class compiledMethodAt: scriptName) decompileString.
	{aSlotName asGetterSelector. aSlotName asSetterSelector} do:
		[:searchee |
			(stringToSearch findString: searchee startingAt: 1) = 0
				ifFalse:
					[^ true]]. 

	^ false
]

{ #category : #other }
ScriptEditorMorph >> hibernate [
	"Possibly delete the tiles, but only if using universal tiles."

	| tw |
	Preferences universalTiles ifFalse: [^self].
	(tw := self findA: ScrollPane) isNil 
		ifFalse: 
			[self setProperty: #sizeAtHibernate toValue: self extent.	"+ tw xScrollerHeight"
			submorphs size > 1 ifTrue: [tw delete]]
]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> indexOfMorphAbove: aPoint [
	"Return index of lowest morph whose bottom is above aPoint.
	Will return 0 if the first morph is not above aPoint"
	submorphs doWithIndex:
		[:m :i | m fullBounds bottom >= aPoint y ifTrue:
					[^ (i max: firstTileRow) - 1]].
	^ submorphs size
]

{ #category : #initialization }
ScriptEditorMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self listDirection: #topToBottom;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 cellPositioning: #topLeft;
		 setProperty: #autoFitContents toValue: true;
		minHeight: TileMorph defaultH;
		layoutInset: 2.
	self useRoundedCornersInEtoys.
	self borderColor: ScriptingSystem borderColor.
	self setNameTo: 'Script Editor' translated.
	firstTileRow := 1.
	"index of first tile-carrying submorph"
	self addNewRow.
	showingMethodPane := false.

]

{ #category : #private }
ScriptEditorMorph >> insertTileRow: tileList after: index [
	"Return a row to be used to insert an entire row of tiles."

	| row |
	row := AlignmentMorph newRow
		vResizing: #spaceFill;
		layoutInset: 0;
		extent: (bounds width)@(TileMorph defaultH);
		color: Color transparent.
	row position: self position.
	row addAllMorphs: tileList.
	tileList do: [:t | t justAddedAsTileRow].
	self privateAddMorph: row atIndex: index + 1.

]

{ #category : #other }
ScriptEditorMorph >> insertUniversalTiles [
	"Insert universal tiles for the method at hand"

	self removeAllButFirstSubmorph.
	"fix a broken header in weasel"
	submorphs isEmpty ifFalse: [
		self firstSubmorph vResizing: #shrinkWrap.
	].
	self insertUniversalTilesForClass: playerScripted class selector: scriptName
]

{ #category : #other }
ScriptEditorMorph >> insertUniversalTilesForClass: aClass selector: aSelector [
	"Add a submorph which holds the universal-tiles script for the given class and selector"

	| source tree syn widget header |
	source := aClass sourceCodeAt: aSelector ifAbsent: [
		Transcript cr; show: aClass name, 'could not find selector ', aSelector.
		^ self delete].    
	tree := Compiler new 
		parse: source 
		in: aClass 
		notifying: nil.
	(syn := tree asMorphicSyntaxUsing: SyntaxMorph)
		parsedInClass: aClass.
	aSelector numArgs = 0 ifTrue: [
		"remove method header line"
		(header := syn findA: SelectorNode) ifNotNil: [header delete]].
	syn removeReturnNode.		"if ^ self at end, remove it"
	widget := syn inAScrollPane.
	widget hResizing: #spaceFill;
		vResizing: #spaceFill;
		color: Color transparent;
		setProperty: #hideUnneededScrollbars toValue: true.
	self addMorphBack: widget.
	(self hasProperty: #autoFitContents) ifFalse:
		[self valueOfProperty: #sizeAtHibernate ifPresentDo:
			[:oldExtent | self extent: oldExtent]].
	syn finalAppearanceTweaks.
]

{ #category : #buttons }
ScriptEditorMorph >> install [
	"Accept the current classic tiles as the new source code for the script.  In the case of universalTiles, initialize the method and its methodInterface if not already done."

	Preferences universalTiles ifFalse:
		[self removeSpaces].
	scriptName ifNotNil:
		[playerScripted acceptScript: self topEditor for:  scriptName asSymbol].

	self enforceImplicitSelf
]

{ #category : #buttons }
ScriptEditorMorph >> installWithNewLiteral [

	self removeSpaces.
	scriptName ifNotNil:
		[playerScripted ifNotNil: [playerScripted acceptScript: self topEditor for:  scriptName]]
]

{ #category : #'e-toy support' }
ScriptEditorMorph >> isCandidateForAutomaticViewing [
	^ false
]

{ #category : #other }
ScriptEditorMorph >> isEmpty [
	^ submorphs size < firstTileRow
]

{ #category : #testing }
ScriptEditorMorph >> isScriptEditorMorph [
	^true
]

{ #category : #other }
ScriptEditorMorph >> isTextuallyCoded [
	(self topEditor isKindOf: ScriptEditorMorph) ifFalse: [^ false].  "workaround for the case where the receiver is embedded in a free-standing CompoundTileMorph.  Yecch!"
	^ self userScriptObject notNil and: [self userScriptObject isTextuallyCoded]
]

{ #category : #'e-toy support' }
ScriptEditorMorph >> isTileEditor [
	"Yes I am"
	^true
]

{ #category : #scripting }
ScriptEditorMorph >> isTileScriptingElement [
	^ true
]

{ #category : #'e-toy support' }
ScriptEditorMorph >> localeChanged [
	"Update myself to reflect the change in locale"

	self fixLayout.
	self == self topEditor ifTrue:  "nested script-editors handled by the topmost."
		[self fixUpCarets]
]

{ #category : #buttons }
ScriptEditorMorph >> makeIsolatedCodePane [
	MethodHolder makeIsolatedCodePaneForClass: playerScripted class selector: scriptName
]

{ #category : #other }
ScriptEditorMorph >> methodNodeMorph [
	"Answer the morph that constitutes the receiver's method node"

	submorphs size < 2  ifTrue: [^ nil].
	^ self findDeepSubmorphThat:
		[:aMorph | (aMorph isSyntaxMorph) and:
				[aMorph parseNode isKindOf: MethodNode]]
			ifAbsent: [nil]
]

{ #category : #other }
ScriptEditorMorph >> methodString [
	"Answer the source-code string for the receiver.  This is for use by classic tiles, but is also used in universal tiles to formulate an initial method declaration for a nascent user-defined script; in universalTiles mode, the codeString (at present anyway) is empty -- the actual code derives from the SyntaxMorph in that case"

	| string evaluator rewriter |
	(submorphs size = 2 and: [(submorphs second isMemberOf: MethodMorph)]) ifTrue: [
		^ submorphs second model contents
	].
	string := String streamContents:
		[:aStream |
			aStream nextPutAll: scriptName.
			scriptName endsWithAColon ifTrue:
				[aStream nextPutAll: ' parameter'].
			aStream cr; cr; tab.
			aStream nextPutAll: self codeString.
	].
	self hasKedamaTurtlePlayer ifFalse: [^ string].
	Evaluator ifNil: [
		self class setDefaultEvaluator.
	].
	evaluator := Evaluator.
	playerScripted class compileSilently: string classified: 'temporary'.
	evaluator makeAttributedTreeWith: ((playerScripted class compiledMethodAt: scriptName) decompileClass: playerScripted class selector: scriptName) forReceiver: playerScripted.
	evaluator addGraphEdgesRoot.
	evaluator evaluateAllOccurence.

	Rewrite ifTrue: [
		rewriter := KedamaVectorParseTreeRewriter new.
		rewriter attributedTree: evaluator attributedTree.
		rewriter parseTree: evaluator attributedTree tree.
		rewriter setEncoderFor: playerScripted in: self referenceWorld.
		rewriter visit: evaluator attributedTree tree andParent: nil.
		^ rewriter parseTree printString.
	] ifFalse: [
		evaluator attributedTree inspect.
		^ string
	].

]

{ #category : #other }
ScriptEditorMorph >> modernize [
	"If the receiver appears to date from the past, try to fix it up"
	
	Preferences universalTiles ifFalse:
		[(self isTextuallyCoded and: [self showingMethodPane not]) ifTrue:
			["Fix up old guys that  are not showing the code in place"
			self showSourceInScriptor]]
]

{ #category : #access }
ScriptEditorMorph >> morph [
	^ self playerScripted costume
]

{ #category : #'event handling' }
ScriptEditorMorph >> mouseEnter: evt [
	| hand tile |

	hand := evt hand.
	hand submorphs size = 1 ifFalse: [^self].
	tile := hand firstSubmorph renderedMorph.
	"self class = BooleanScriptEditor ifTrue: [self halt]."
	(self wantsDroppedMorph: tile event: evt) ifFalse: [^self].
	handWithTile := hand.
	self startTracking.

]

{ #category : #'event handling' }
ScriptEditorMorph >> mouseEnterDragging: evt [
	"Test button state elsewhere if at all"
	^ self mouseEnter: evt
]

{ #category : #'event handling' }
ScriptEditorMorph >> mouseLeave: evt [
	owner ifNil: [^ self].	"left by being removed, not by mouse movement"
	(self hasProperty: #justPickedUpPhrase) ifTrue:[
		self removeProperty: #justPickedUpPhrase.
		^self].
	self stopTracking.
	self removeSpaces.
]

{ #category : #'event handling' }
ScriptEditorMorph >> mouseLeaveDragging: evt [
	"Test button state elsewhere if at all"
	^ self mouseLeave: evt
]

{ #category : #access }
ScriptEditorMorph >> myMorph [
	"Answer the morph that serves as the costume of my associated player.  If for some reason I have no associated player, answer nil"

	| aPlayer |
	^ (aPlayer := self playerScripted) ifNotNil: [aPlayer costume]
]

{ #category : #'e-toy support' }
ScriptEditorMorph >> objectViewed [
	^ self playerScripted costume
]

{ #category : #other }
ScriptEditorMorph >> offerScriptorMenu [
	"Put up a menu in response to the user's clicking in the menu-request area of the scriptor's heaer"

	| aMenu count |

	self modernize.
	self currentHand showTemporaryCursor: nil.

	Preferences eToyFriendly ifTrue: [^ self offerSimplerScriptorMenu].

	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: scriptName asString.
	aMenu addStayUpItem.  "NB:  the kids version in #offerSimplerScriptorMenu does not deploy the stay-up item"

	aMenu addList: (self hasParameter
		ifTrue: [{
			{'remove parameter' translated.					#ceaseHavingAParameter}}]
		ifFalse: [{
			{'add parameter' translated.						#addParameter}}]).

	self hasParameter ifFalse:
		[aMenu addTranslatedList: {
			{'button to fire this script' translatedNoop. #tearOfButtonToFireScript}.
			{'fires per tick...' translatedNoop. #chooseFrequency}.
			#-
		}].

	aMenu addUpdating: #showingCaretsString  target: self action: #toggleShowingCarets.
	aMenu addLine.
	aMenu addList: {
		{'edit balloon help for this script' translated.		#editMethodDescription}.
		{'explain status alternatives' translated. 			#explainStatusAlternatives}.
		{'button to show/hide this script' translated.			#buttonToOpenOrCloseThisScript}.
		#-
	}.


	Preferences universalTiles ifFalse:
		[count := self savedTileVersionsCount.
		self showingMethodPane
			ifFalse:				"currently showing tiles"
				[aMenu add: 'show code textually' translated action: #toggleWhetherShowingTiles.
				count > 0 ifTrue: 
					[aMenu add: 'revert to tile version...' translated action:	 #revertScriptVersion].
				aMenu add: 'save this version' translated	action: #saveScriptVersion]

			ifTrue:				"current showing textual source"
				[count >= 1 ifTrue:
					[aMenu add: 'revert to tile version' translated action: #toggleWhetherShowingTiles]]].

	"aMenu addLine.
	self addGoldBoxItemsTo: aMenu."

	aMenu addLine.
	
	aMenu add: 'grab this object' translated target: playerScripted selector: #grabPlayerIn: argument: self currentWorld.
	aMenu balloonTextForLastItem: 'This will actually pick up the object bearing this script and hand it to you.  Click the (left) button to drop it' translated.

	aMenu add: 'reveal this object' translated target: playerScripted selector: #revealPlayerIn: argument: self currentWorld.
	aMenu balloonTextForLastItem: 'If you have misplaced the object bearing this script, use this item to (try to) make it visible' translated.

	aMenu add: 'tile representing this object' translated target: playerScripted action: #tearOffTileForSelf.
	aMenu balloonTextForLastItem: 'choose this to obtain a tile which represents the object associated with this script' translated.

	aMenu addTranslatedList: {
		#-.
		{'open viewer' translatedNoop. #openObjectsViewer.  'open the viewer of the object to which this script belongs' translatedNoop}.
		{'detached method pane' translatedNoop. #makeIsolatedCodePane. 'open a little window that shows the Smalltalk code underlying this script.' translatedNoop}.
		#-.
		{'destroy this script' translatedNoop. #destroyScript}
	}.


	^ aMenu popUpInWorld: self currentWorld
]

{ #category : #initialization }
ScriptEditorMorph >> phrase: aPhraseTileMorph [
	"Make the receiver be a Scriptor for a new script whose initial contents is the given phrase."

	| aHolder |
	firstTileRow := 2.
	aHolder := AlignmentMorph newRow.
	aHolder beTransparent; layoutInset: 0.
	aHolder addMorphBack: aPhraseTileMorph.
	self addMorphBack: aHolder.
	self scriptEdited
]

{ #category : #buttons }
ScriptEditorMorph >> playerScripted [
	^ playerScripted
]

{ #category : #initialization }
ScriptEditorMorph >> playerScripted: aPlayer [
	playerScripted := aPlayer 
]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> prepareToUndoDropOf: aMorph [
	"No longer functional"
]

{ #category : #access }
ScriptEditorMorph >> printOn: aStream [
	^ aStream nextPutAll: 'ScriptEditor for #', scriptName asString, ' player: ', playerScripted externalName
]

{ #category : #other }
ScriptEditorMorph >> recompileScript [
	"A hook called in several places in the UI when something has been dragged & dropped into or out of the script."

	self install.
	"self stopScript"
]

{ #category : #other }
ScriptEditorMorph >> recreateScript [
	| aUserScript |
	aUserScript := playerScripted class userScriptForPlayer: playerScripted selector: scriptName.
	aUserScript recreateScriptFrom: self
]

{ #category : #other }
ScriptEditorMorph >> reinsertSavedTiles: savedTiles [
	"Revert the scriptor to show the saved tiles"

	self submorphs doWithIndex: [:m :i | i > 1 ifTrue: [m delete]].
	self addAllMorphs: savedTiles.
	self allMorphsDo: [:m | m isTileScriptingElement ifTrue: [m bringUpToDate]].
	self install.
	self showingMethodPane: false
]

{ #category : #caching }
ScriptEditorMorph >> releaseCachedState [
	"Release any state that could be recomputed"

	super releaseCachedState.
	handWithTile := nil.
	self hibernate
]

{ #category : #private }
ScriptEditorMorph >> removeEmptyRows [
	submorphs copy do: [:m |
		(m isAlignmentMorph and: [m submorphCount = 0])
			ifTrue: [m delete]].
self flag: #arNote. "code below lead to large and unnecessary recomputations of layouts; without it things just fly"
"	self fullBounds.
	self layoutChanged."

	self flag: #noteToJohn.  "Screws up when we have nested IFs.  got broken in 11/97 when you made some emergency fixes for some other reason, and has never worked since...  Would be nice to have a more robust reaction to this!"
"
	self removeEmptyLayoutMorphs.

	spacer := LayoutMorph new extent: 10@12.
	spacer vResizing: #rigid.
	self privateAddMorph: spacer atIndex: self indexForLeadingSpacer.

	spacer := LayoutMorph new  extent: 10@12.
	spacer vResizing: #rigid.
	self privateAddMorph: spacer atIndex: (submorphs size + 1).

	self fullBounds; layoutChanged."

]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> removeSpaces [
	"Remove vertical space"
	dropSpaces ifNotNil: [dropSpaces do: [:m | m delete]].
	dropSpaces := nil.
	self removeEmptyRows.
	submorphs isEmpty ifTrue: [self height: self minHeight].

]

{ #category : #other }
ScriptEditorMorph >> renameScript [
	"Rename the current script.  Invoked at user menu request"

	playerScripted renameScript: self scriptName
]

{ #category : #other }
ScriptEditorMorph >> renameScriptTo: newSelector [
	"Rename the receiver's script so that it bears a new selector"

	| aMethodNodeMorph methodMorph methodSource pos newMethodSource |

	scriptName := newSelector.
	self updateHeader.
	Preferences universalTiles
		ifFalse:  "classic tiles"
			[self showingMethodPane
				ifTrue:
					["textually coded -- need to change selector"
					methodMorph := self findA: MethodMorph.
					methodSource := methodMorph text string.
					pos := methodSource indexOf: Character cr ifAbsent: [self error: 'no cr'].
					newMethodSource := newSelector.
					newSelector numArgs > 0 ifTrue: [newMethodSource := newMethodSource, ' t1'].  "for the parameter"
					newMethodSource := newMethodSource, (methodSource copyFrom: pos to: methodSource size).
					methodMorph editString: newMethodSource.
					methodMorph model changeMethodSelectorTo: newSelector.
					playerScripted class compileSilently: newMethodSource classified: 'scripts'.
					methodMorph accept]
				ifFalse:
					[self install]]
		ifTrue:  "universal tiles..."
			[(aMethodNodeMorph := self methodNodeMorph) ifNotNil:
				[aMethodNodeMorph acceptInCategory: 'scripts']]
]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> repelsMorph: aMorph event: ev [
	"Answer whether the receiver shoul repel the given morph"

	^ Preferences universalTiles
		ifTrue:
			[(aMorph respondsTo: #parseNode) not]
		ifFalse:
			[aMorph isTileLike not]
]

{ #category : #'e-toy support' }
ScriptEditorMorph >> replaceReferencesToSlot: oldSlotName inPlayer: aPlayer with: newSlotName [
	"An instance variable has been renamed in a player; replace all references to the old instance variable of that player such that they become references to the new slot"

	self tileRows do: [:row |
		row do: [:c | c traverseRowTranslateSlotOld: oldSlotName of: aPlayer to: newSlotName]].
	self install.
	self fixLayout
]

{ #category : #buttons }
ScriptEditorMorph >> replaceRow1 [

	submorphs first delete.  "the button row"
	self addMorphFront: self buttonRowForEditor.  "up to date"

]

{ #category : #caching }
ScriptEditorMorph >> resetHandWithTile [
	"Set the handWithTile back to nil, in case it somehow got to be nonnil"

	handWithTile := nil
]

{ #category : #buttons }
ScriptEditorMorph >> restoreScriptName: aScriptName [
	"For fixup only..."

	scriptName := aScriptName
]

{ #category : #other }
ScriptEditorMorph >> revertScriptVersion [
	| aUserScript |
	aUserScript := playerScripted class userScriptForPlayer: playerScripted selector: scriptName.
	aUserScript revertScriptVersionFrom: self
]

{ #category : #'save & revert' }
ScriptEditorMorph >> revertToTileVersion [
	"The receiver, currently showing textual code,  is asked to revert to the last-saved tile version"

	| aUserScript |

	self 
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	aUserScript := playerScripted class userScriptForPlayer: playerScripted selector: scriptName.
	aUserScript revertToLastSavedTileVersionFor: self.
	self currentWorld startSteppingSubmorphsOf: self
]

{ #category : #private }
ScriptEditorMorph >> rowInsertionIndexFor: aPoint [
	"Return the row into which the given morph should be inserted."

	| m |
	firstTileRow to: submorphs size do: [:i |
		m := submorphs at: i.
		((m top <= aPoint y) and: [m bottom >= aPoint y]) ifTrue:
			[(aPoint y > m center y)
				ifTrue: [^ i]
				ifFalse: [^ (i - 1) max: firstTileRow]]].
	^ firstTileRow > submorphs size
		ifTrue:
			[submorphs size]
		ifFalse:
			[(submorphs at: firstTileRow) top > aPoint y 
				ifTrue: [firstTileRow - 1 max: 1 ]
				ifFalse: [submorphs size]]

]

{ #category : #'save & revert' }
ScriptEditorMorph >> saveScriptVersion [
	self userScriptObject saveScriptVersion: self setTimeStamp
]

{ #category : #'save & revert' }
ScriptEditorMorph >> savedTileVersionsCount [
	"Answer the number of saved tile versions that currently exist for this script"

	^ self userScriptObject savedTileVersionsCount
]

{ #category : #private }
ScriptEditorMorph >> scriptEdited [
	"The script was edited in some way.  Recompile the script and be sure appropriate carets are showing."

	| anEditor |
	(anEditor := self topEditor) ifNotNil:
		[anEditor recompileScript.
		anEditor fixUpCarets]
]

{ #category : #access }
ScriptEditorMorph >> scriptInstantiation [
	^ playerScripted scriptInstantiationForSelector: scriptName
]

{ #category : #buttons }
ScriptEditorMorph >> scriptName [
	^ scriptName
]

{ #category : #buttons }
ScriptEditorMorph >> scriptTitle [

	^ Preferences universalTiles 
		ifTrue: [SyntaxMorph new substituteKeywordFor: scriptName] 
				"spaces instead of capitals, no colons"
				"Don't use property #syntacticallyCorrectContents.  
				  scriptName here holds the truth"
		ifFalse: [scriptName].

]

{ #category : #buttons }
ScriptEditorMorph >> scriptee [
	| editor |
	playerScripted ifNotNil: [^ playerScripted].
	(editor := self topEditor) == self ifTrue: [self error: 'unattached script editor'. ^ nil].
	^ editor scriptee
]

{ #category : #frequency }
ScriptEditorMorph >> setFrequencyTo: aNumber [
	self scriptInstantiation frequency: aNumber
]

{ #category : #initialization }
ScriptEditorMorph >> setMorph: anActorMorph [
	"Not really the way to do this any more"
	playerScripted := anActorMorph player

]

{ #category : #initialization }
ScriptEditorMorph >> setMorph: anActorMorph scriptName: aString [
	"Create a script editor for editing a named script."

	self setMorph: anActorMorph.
	scriptName := aString.
	self addMorphFront: self buttonRowForEditor.
	self updateStatus.
	firstTileRow := 2

]

{ #category : #testing }
ScriptEditorMorph >> setParameterType: typeChosen [
	"Set the parameter type as indicated"

	playerScripted setParameterFor: scriptName toType: typeChosen
]

{ #category : #other }
ScriptEditorMorph >> setScriptNameTo: aNewName [
	"The user has typed into the script-name pane.  Accept the changed contents as the new script name, and take action accordingly"

	playerScripted renameScript: self scriptName newSelector:
		(playerScripted acceptableScriptNameFrom: aNewName forScriptCurrentlyNamed:  self scriptName)
]

{ #category : #other }
ScriptEditorMorph >> setTimeStamp [
	timeStamp := Date today mmddyyyy, ' ', (Time now print24 copyFrom: 1 to: 8).
	^ timeStamp
]

{ #category : #buttons }
ScriptEditorMorph >> showSourceInScriptor [
	"Remove tile panes, if any, and show textual source instead"

	self isTextuallyCoded ifFalse: [self becomeTextuallyCoded].
		"Mostly to fix up grandfathered ScriptEditors"

	self removeAllButFirstSubmorph.

	self setupMethodMorph.

]

{ #category : #'textually-coded scripts' }
ScriptEditorMorph >> showingMethodPane [
	"Answer whether the receiver is currently showing the textual method pane"

	^ showingMethodPane ifNil: [showingMethodPane := false]
]

{ #category : #'textually-coded scripts' }
ScriptEditorMorph >> showingMethodPane: val [
	"Whether the receiver will show the textual method pane"

	showingMethodPane := val
]

{ #category : #testing }
ScriptEditorMorph >> stepTime [

	^ 0
]

{ #category : #other }
ScriptEditorMorph >> storeCodeOn: aStream indent: tabCount [ 
	| lastOwner |
	lastOwner := nil.
	self tileRows do: 
			[:r | 
			r do: 
					[:m | 
					((m isTileMorph) 
						or: [(m isCompoundTileMorph) or: [m isPhraseTileMorph]]) 
							ifTrue: 
								[tabCount timesRepeat: [aStream tab].
								(m owner ~= lastOwner and: [lastOwner ~= nil]) 
									ifTrue: 
										[aStream
											nextPut: $.;
											cr;
											tab.
										]
									ifFalse: 
										[lastOwner ~= nil ifTrue: [aStream space].
										].
								m storeCodeOn: aStream indent: tabCount.
								lastOwner := m owner]]]
]

{ #category : #other }
ScriptEditorMorph >> tearOfButtonToFireScript [
	"Tear off a button to fire this script"

	playerScripted tearOffButtonToFireScriptForSelector: scriptName
]

{ #category : #other }
ScriptEditorMorph >> tileRows [
	"If using classic tiles, return a collection of arrays of Tiles in which each array is one line of tiles.  (John Maloney's original design and code)."

	| rows r |
	rows := OrderedCollection new.
	Preferences universalTiles ifTrue: [^ rows].
	firstTileRow to: submorphs size do: [:i |
		r := submorphs at: i.
		r submorphCount > 0 ifTrue: [rows addLast: r submorphs]].
	^ rows

]

{ #category : #other }
ScriptEditorMorph >> timeStamp [
	^ timeStamp
]

{ #category : #other }
ScriptEditorMorph >> toggleWhetherShowingTiles [
	"Toggle between showing the method pane and showing the tiles pane"

	self showingMethodPane
		ifFalse:				"currently showing tiles"
			[self showSourceInScriptor]

		ifTrue:				"current showing textual source"
			[Preferences universalTiles
				ifTrue: [^ self revertToTileVersion].
			self savedTileVersionsCount >= 1
				ifTrue:
					[(self userScriptObject lastSourceString = (playerScripted class sourceCodeAt: scriptName))
						ifFalse:
							[(self confirm: 
'Caution -- this script was changed
textually; if you revert to tiles at this
point you will lose all the changes you
may have made textually.  Do you
really want to do this?' translated) ifFalse: [^ self]].
					self revertToTileVersion]
				ifFalse:
					[Beeper beep]]
]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> trackDropZones [
	"The fundamental heart of script-editor layout, by Dan Ingalls in fall 1997, though many hands have touched it since."

	| hand insertion i space1 d space2 insHt nxtHt prevBot ht2 c1 c2 ii where |
	hand := handWithTile ifNil: [self primaryHand].
	previousDropHandPosition = hand position ifTrue: [^ self].
	previousDropHandPosition := hand position.
	((self hasOwner: hand) not and: [hand submorphCount > 0])
		ifTrue:
			[insertion := hand firstSubmorph renderedMorph.
			insHt := insertion fullBounds height.
			self removeDropSpaces.
			where := self globalPointToLocal: hand position"insertion fullBounds topLeft".
			i := (ii := self indexOfMorphAbove: where) min: submorphs size-1.
			prevBot := i <= 0 ifTrue: [(self innerBounds) top]
							ifFalse: [(self submorphs at: i) bottom].
			nxtHt := (submorphs isEmpty
				ifTrue: [(self owner isMemberOf: AlignmentMorph) ifTrue: [Morph new extent: 0@10] ifFalse: [insertion]]
				ifFalse: [self submorphs at: i+1]) height max: 1.
			"nxtHt printString displayAt: 0@0."
			d := ii > i ifTrue: [nxtHt "for consistent behavior at bottom"]
					ifFalse: [0 max: (where y - prevBot min: nxtHt)].

			"Top and bottom spacer heights cause continuous motion..."
			c1 := Color green.  c2 := Color transparent.
			ht2 := d*insHt//nxtHt.
			"'d, insHt, nxtHt', d printString, '  ', insHt printString, '  ', nxtHt printString, '  ', ht2 printString, '                   ' displayAt: 0@50."
			dropSpaces ifNil: [
				dropSpaces := Array new: 2.
				dropSpaces at: 1 put: Morph new.
				dropSpaces at: 2 put: Morph new.
			].
			space1 := dropSpaces at: 1.
			space2 := dropSpaces at: 2.
			space1 privateBounds: (0@0 extent: (self width - (self borderWidth*2) - 10)@(insHt-ht2));
                                        color: ((insHt-ht2) > (insHt//2+1) ifTrue: [c1] ifFalse: [c2]).
			space2 privateBounds: (0@0 extent: (self width - (self borderWidth*2) - 10)@ht2);
                                        color: (ht2 > (insHt//2+1) ifTrue: [c1] ifFalse: [c2]).
			self privateAddMorph: (space1 position: where) atIndex: (i+1 max: 1).
			self privateAddMorph: (space2 position: where) atIndex: (i+3 min: submorphs size+1).

			]
		ifFalse:
			[self stopTracking. self removeSpaces]
]

{ #category : #buttons }
ScriptEditorMorph >> tryMe [
	"Evaluate the given script on behalf of the scripted object"

	scriptName numArgs = 0
		ifTrue:
			[self deleteEtoysDebugger.
			self playerScripted performScriptIfCan: scriptName ]


]

{ #category : #testing }
ScriptEditorMorph >> typeForParameter [
	"Answer a symbol representing the type of my parameter"

	scriptName numArgs > 0 ifTrue:
		[(playerScripted class scripts at: scriptName ifAbsent: [nil]) ifNotNil:
			[:aScript | ^ aScript argumentVariables first variableType]].

	^ #Error
]

{ #category : #frequency }
ScriptEditorMorph >> typeInFrequency [
	| reply aNumber |
	reply := FillInTheBlank request: 'Number of firings per tick: ' translated initialAnswer: self scriptInstantiation frequency printString.

	reply ifNotNil:
		[aNumber := reply asNumber.
		aNumber > 0 ifTrue:
			[self setFrequencyTo: aNumber]]
]

{ #category : #other }
ScriptEditorMorph >> unhibernate [
	"I have been loaded as part of an ImageSegment.
	Make sure that I am fixed up properly."
	self topEditor == self ifFalse: [^ self]. "Part of a compound test"
	self updateHeader.
	self fixUpCarets.
	self fixLayout.
	"Recreate my tiles from my method if i have new universal tiles."
	self world
		ifNil: [(playerScripted isNil or: [playerScripted isUniversalTiles not]) ifTrue: [^ self]]
		ifNotNil:
			[Preferences universalTiles ifFalse: [^ self]].

	self insertUniversalTiles.
	self showingMethodPane: false
]

{ #category : #initialization }
ScriptEditorMorph >> updateHeader [
	"Replace my header morph with another one assured of being structurally au courant"
	
	(firstTileRow notNil and: [firstTileRow > 1]) ifTrue:
		[self replaceRow1]
]

{ #category : #buttons }
ScriptEditorMorph >> updateStatus [
	"Update that status in the receiver's header.  "

	(self topEditor == self and: [firstTileRow ~~ 1]) ifTrue:
		[(submorphs size == 0 or: [(self firstSubmorph findA: ScriptStatusControl) isNil])
			ifTrue:
				[self replaceRow1].
		self updateStatusMorph: (self firstSubmorph findA: ScriptStatusControl)]
]

{ #category : #buttons }
ScriptEditorMorph >> updateStatusMorph: statusMorph [
	"My status button may need to reflect an externally-induced change in status"

	(playerScripted existingScriptInstantiationForSelector: scriptName) ifNotNil:
		[:scriptInstantiation |
			scriptInstantiation updateStatusMorph: statusMorph]
]

{ #category : #initialization }
ScriptEditorMorph >> updateToPlayer: newPlayer [ 
	"Make certain that the script name and the names of actors within are up to date"

	playerScripted ifNil: 
		["likely a naked test/yes/no fragment!"
		^ self].
	newPlayer == playerScripted ifTrue: [^ self].	"Already points to him"
	self allMorphs do:  [:m | 
		(m isKindOf: TileMorph)  ifTrue: 
			[m retargetFrom: playerScripted to: newPlayer.
			m bringUpToDate]].
	playerScripted := newPlayer.
	self replaceRow1
]

{ #category : #other }
ScriptEditorMorph >> userScriptObject [
	"Answer the user-script object associated with the receiver.  This is expected to be called only for objects that actually reside within 'Scriptors', but will return nil, rather than fail, of there is no userScriptObject found."

	| aPlayerScripted topEd |
	aPlayerScripted := (topEd := self topEditor) playerScripted.
	^ aPlayerScripted ifNotNil: [ aPlayerScripted class userScriptForPlayer: aPlayerScripted selector: topEd scriptName]
]

{ #category : #copying }
ScriptEditorMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
playerScripted := deepCopier references at: playerScripted ifAbsent: [playerScripted].

]

{ #category : #copying }
ScriptEditorMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	scriptName := scriptName veryDeepCopyWith: deepCopier.
	firstTileRow := firstTileRow veryDeepCopyWith: deepCopier.
	timeStamp := timeStamp veryDeepCopyWith: deepCopier.
	playerScripted := playerScripted.		"Weakly copied"
	handWithTile := nil.  "Just a cache"
	showingMethodPane := showingMethodPane.	"boolean"
	threadPolygon := nil. "Just a cache".
	previousDropHandPosition := nil.
	dropSpaces := nil.

]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> wantsDroppedMorph: aMorph event: evt [
	"Answer whether the receiver would be interested in accepting the morph"

	^ (aMorph isTileLike and: [self isTextuallyCoded not]) and:
		[(#(Command Unknown) includes: aMorph resultType capitalized)]
]

{ #category : #menus }
ScriptEditorMorph >> wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph [
	"Answer whether the receiver would like to offer the halo handle with the given selector (e.g. #addCollapseHandle:)"

	(#(addDupHandle: addMakeSiblingHandle:) includes: aSelector) ifTrue:
		[^ false].

	^ super wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph
]

{ #category : #'dropping\/grabbing' }
ScriptEditorMorph >> willingToBeDiscarded [
	"Resist the drag-into-trash gesture"

	^ false
]
