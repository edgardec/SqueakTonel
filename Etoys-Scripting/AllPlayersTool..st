"
A tool that lets you see find, view, and obtain tiles for all the active players in the project.
"
Class {
	#name : #AllPlayersTool,
	#superclass : #AlignmentMorph,
	#category : #'Etoys-Scripting'
}

{ #category : #'instance-creation defaults' }
AllPlayersTool class >> defaultNameStemForInstances [
	"Answer the default name stem for new instances of this class"

	^ 'Players' translatedNoop
]

{ #category : #'parts bin' }
AllPlayersTool class >> descriptionForPartsBin [
	"Answer a description for use in parts bins"

	^ self partName: 	'Players' translatedNoop
		categories:		{'Scripting' translatedNoop}
		documentation:	'A tool showing all the players in your project' translatedNoop
]

{ #category : #menus }
AllPlayersTool >> addCustomMenuItems: aMenu hand: aHand [
	"Add further items to the menu"

	aMenu add: 'reinvigorate' translated target: self action: #reinvigorate.
	Preferences eToyFriendly ifFalse: [aMenu add: 'inspect' translated target: self action: #inspect]
]

{ #category : #initialization }
AllPlayersTool >> addHeaderRow [
	"Add the header morph at the top of the tool"

	| aRow aButton |
	aRow := AlignmentMorph newRow.
	aRow listCentering: #justified; color: Color transparent.
	aButton := self tanOButton.
	aRow addMorphFront: aButton.
	aRow addMorphBack: (StringMorph contents: 'Players in this Project' translated font: ScriptingSystem fontForTiles).

	aRow addMorphBack: self helpButton.
	self addMorphFront: aRow.

]

{ #category : #initialization }
AllPlayersTool >> initializeFor: aPresenter [
	"Initialize the receiver as a tool which shows, and allows the user to change the status of, all the instantiations of all the user-written scripts in the scope of the containing pasteup's presenter"

	| placeHolder |
	self color: Color brown muchLighter muchLighter; wrapCentering: #center; cellPositioning: #topCenter; vResizing: #shrinkWrap; hResizing: #shrinkWrap.
	self useRoundedCorners.
	self layoutInset: 0.
	self borderStyle: BorderStyle complexAltInset; borderWidth: 4; borderColor: (Color r: 0.452 g: 0.839 b: 1.0).  "Color fromUser"
	self addHeaderRow.
	placeHolder := Morph new beTransparent.
	placeHolder extent: 200@0.
	self addMorphBack: placeHolder.
	self setProperty: #ExplicitStepTime toValue: 5000.  "5 seconds"
	WorldState addDeferredUIMessage:
		[self updateScrollbar.
		self reinvigorate]


]

{ #category : #initialization }
AllPlayersTool >> initializeToStandAlone [
	"Initialize the receiver"

	super initializeToStandAlone.
	self layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		hResizing: #spaceFill;
		extent: 1@1;
		vResizing: #spaceFill;
		rubberBandCells: true.

	self initializeFor: self currentWorld presenter
]

{ #category : #reinvigoration }
AllPlayersTool >> invigorateButton [
	"Answer a button that triggers reinvigoration"

	| aButton |
	aButton := IconicButton new target: self;
		borderWidth: 0;
		labelGraphic: (ScriptingSystem formAtKey: #Refresh);
		color: Color transparent; 
		actWhen: #buttonUp;
		actionSelector: #reinvigorate;
		yourself.
	aButton setBalloonText: 'Click here to refresh the list of players'.
	^ aButton

]

{ #category : #reinvigoration }
AllPlayersTool >> menuButton [
	"Answer a button that brings up a menu.  Useful when adding new features, but at present is between uses"

	| aButton |
	aButton := IconicButton new target: self;
		borderWidth: 0;
		labelGraphic: (ScriptingSystem formAtKey: #TinyMenu);
		color: Color transparent; 
		actWhen: #buttonDown;
		actionSelector: #offerMenu;
		yourself.
	aButton setBalloonText: 'click here to get a menu with further options'.
	^ aButton

]

{ #category : #menus }
AllPlayersTool >> presentHelp [
	"Sent when a Help button is hit; provide the user with some form of help for the tool at hand"

	| aFlapTab aString |
	aString := '
Each row represents an object, or "player" in the project.
Click on the menu icon to get a menu of options concerning the player.
Click on a player''s picture to reveal its location.
Click on the turquoise eye to open the player''s viewer.
Click on a player''s name to obtain a tile representing it.'
 translated.

	aFlapTab := ScriptingSystem assureFlapOfLabel: 'Players' translated withContents: aString.
	aFlapTab showFlap
]

{ #category : #reinvigoration }
AllPlayersTool >> reinvigorate [
	"Referesh the contents of the receiver"

	(submorphs copyFrom: 3 to: submorphs size) do: [:m | m delete].
	self currentWorld doOneCycleNow.
	self playSoundNamed: 'scritch'.
	(Delay forMilliseconds: 700) wait.
	self currentWorld presenter reinvigoratePlayersTool: self.
	self playSoundNamed: 'scratch'.
]
