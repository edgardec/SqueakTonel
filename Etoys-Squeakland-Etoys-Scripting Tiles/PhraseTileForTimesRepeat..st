"
A place-holder for a Times-Repeat complex of etoy tiles.  Used in a Viewer; when the user drags one of these, he ends up with a fully-instantiated Times/Repeat complex of tiles in his hand; if he drops such a group on the desktop, a new script is created for the object associated with the Viewer in question, with the Times/Repeat as its initial contents.
"
Class {
	#name : #PhraseTileForTimesRepeat,
	#superclass : #PhraseTileMorph,
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #hilighting }
PhraseTileForTimesRepeat >> addCommandFeedback: evt [
	"Add screen feedback showing what would be torn off in a drag"

	| aMorph |
	
	(self owner owner isMemberOf: PhraseTileMorph) ifTrue: [self owner owner addCommandFeedback: evt. ^ self].
	aMorph := RectangleMorph new bounds: ((self topLeft - (2@1)) corner: (self bottomRight) + (2@1)).
	aMorph beTransparent; borderWidth: 2; borderColor: ScriptingSystem commandFeedback; lock.
	Project current world addHighlightMorph: aMorph for: self outmostScriptEditor
]

{ #category : #initialization }
PhraseTileForTimesRepeat >> initialize [
	"Initialize the receiver."

	super initialize.
	self color: Color orange muchLighter.
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		borderWidth: 1;
		borderColor: ScriptingSystem standardTileBorderColor.
	self setupCostume

]

{ #category : #mouse }
PhraseTileForTimesRepeat >> mouseDown: evt [ 
	"Handle a mouse-down on the receiver"

	| guyToTake catViewer |
	guyToTake := TimesRepeatTile new.
	guyToTake setNamePropertyTo: 'Repeat Tile' translated.
	guyToTake position: evt position + (-25@8).
	
	guyToTake formerPosition: evt hand position.
	"self startSteppingSelector: #trackDropZones."
	(catViewer := self ownerThatIsA: CategoryViewer) ifNotNil:
		[guyToTake setProperty: #newPermanentPlayer toValue: catViewer scriptedPlayer.
		guyToTake setProperty: #newPermanentScript toValue: true].
	guyToTake justGrabbedFromViewer: true.
	
	^ evt hand grabMorph: guyToTake
]

{ #category : #initialization }
PhraseTileForTimesRepeat >> setupCostume [
	"Set up the details that make up the receiver's appearance."

	| stringMorph |
	stringMorph := StringMorph new contents: 'Repeat' translated.
	stringMorph name: 'Repeat' translated.
	stringMorph font: Preferences standardEToysFont.
	self addMorphBack: stringMorph.
	self addMorphBack: (Morph new color: color;
			 extent: 15 @ 5).

	stringMorph := StringMorph new contents: 'Times' translated.
	stringMorph name: 'Times' translated.
	stringMorph font: Preferences standardEToysFont.
	self addMorphBack: stringMorph.
	self addMorphBack: (Morph new color: color;
			 extent: 15 @ 5).

]
