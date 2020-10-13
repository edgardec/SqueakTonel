"
An morph representing an E-Toy ""Player"" in an AllPlayersTool.
"
Class {
	#name : #PlayerSurrogate,
	#superclass : #AlignmentMorph,
	#instVars : [
		'playerRepresented'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #menu }
PlayerSurrogate >> addCustomMenuItems: aMenu hand:  aHand [
	"Add cu stom items to the menu"

	aMenu addList: #(
		('grab this object'	grabThisObject	'wherever it may be rip this object out of its container and hand it to me.')
		('reveal this object'	revealThisObject		'make this object visible and put up its halo')
		('hand me a tile'	handMeATile	'hand me a tile for this object')
		('open viewer'		viewerForThisObject	'open this object''s Viewer'))
]

{ #category : #updating }
PlayerSurrogate >> bringUpToDate [
	"To react to changes  in the corrreponding player, rebuild the display with fresh information from its surrogate"

	self rebuildRow
]

{ #category : #menu }
PlayerSurrogate >> grabThisObject [
	"Hand the user the object represented by the receiver.  Invoked from menu, formerly at least."

	playerRepresented grabPlayerInActiveWorld
]

{ #category : #menu }
PlayerSurrogate >> handMeATile [
	"Hand the user a tile representing the player for which the receiver is a surrogate"

	playerRepresented tearOffTileForSelf
]

{ #category : #updating }
PlayerSurrogate >> isTileScriptingElement [
	"Answer (for the purpose of updating) whether the receiver is a tile-scripting element"

	^ true
]

{ #category : #accessing }
PlayerSurrogate >> playerRepresented [
	"Answer the value of playerRepresented"

	^ playerRepresented
]

{ #category : #accessing }
PlayerSurrogate >> playerRepresented: anObject [
	"Set the value of playerRepresented"

	playerRepresented := anObject.
	self rebuildRow.
	self setNameTo: anObject costume topRendererOrSelf externalName
]

{ #category : #accessing }
PlayerSurrogate >> rebuildRow [
	"Rebuild the row"

	| aThumbnail aTileButton aViewerButton aMenuButton |
	self removeAllMorphs.
	self layoutInset: 2; cellInset: 3.
	self beTransparent.
	aThumbnail := ThumbnailForAllPlayersTool new objectToView: playerRepresented viewSelector: #graphicForViewerTab.

	aMenuButton := IconicButton new labelGraphic: (ScriptingSystem formAtKey: #MenuIcon).
	aMenuButton target: self;
		actionSelector: #playerButtonHit;

		color: Color transparent;
		borderWidth: 0;
		shedSelvedge;
		actWhen: #buttonDown.
	aMenuButton setBalloonText: 'Press here to get a menu' translated.
	self addMorphBack: aMenuButton.

	aThumbnail setBalloonText: 'Click here to reveal this object' translated.
	self addMorphBack: aThumbnail.
	aThumbnail on: #mouseUp send: #beRevealedInActiveWorld to: playerRepresented.

	aViewerButton := IconicButton new labelGraphic: (ScriptingSystem formAtKey: #'LargeHalo-View').
	aViewerButton color: Color transparent; 
			actWhen: #buttonUp;
			actionSelector: #beViewed; target: playerRepresented;
			setBalloonText: 'click here to obtain this object''s Viewer' translated;
			color: Color transparent;
			borderWidth: 0;
			shedSelvedge.

	self addMorphBack: aViewerButton.

	aTileButton := IconicButton  new borderWidth: 0.
	aTileButton labelGraphic: (TileMorph new setToReferTo: playerRepresented) imageForm.
	aTileButton color: Color transparent; 
			actWhen: #buttonDown;
			actionSelector: #tearOffTileForSelf; target: playerRepresented;
			setBalloonText: 'click here to obtain a tile that refers to this player.' translated.
	self addMorphBack: aTileButton.

"	aNameMorph := UpdatingStringMorph new
		useStringFormat;
		target:  playerRepresented;
		getSelector: #nameForViewer;
		setNameTo: 'name';
		font: ScriptingSystem fontForNameEditingInScriptor.
	aNameMorph putSelector: #setName:.
		aNameMorph setProperty: #okToTextEdit toValue: true.
	aNameMorph step.
	self addMorphBack: aNameMorph.
	aNameMorph setBalloonText: 'Click here to edit the player''s name.'.	"
	
]

{ #category : #menu }
PlayerSurrogate >> revealThisObject [
	"Reveal the object I represent"

	playerRepresented revealPlayerIn: Project current world
]

{ #category : #menu }
PlayerSurrogate >> viewerForThisObject [
	"Open a viewer for the object represented by the receiver"

	playerRepresented beViewed
]
