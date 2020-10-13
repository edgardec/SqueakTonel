Class {
	#name : #PhraseTileForTest,
	#superclass : #PhraseTileMorph,
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #'as yet unclassified' }
PhraseTileForTest >> addCommandFeedback: evt [
	"Add screen feedback showing what would be torn off in a drag"

	| aMorph |
	(self owner owner isMemberOf: PhraseTileMorph) ifTrue: [self owner owner addCommandFeedback: evt. ^ self].
	aMorph := RectangleMorph new bounds: ((self topLeft - (2@1)) corner: (self bottomRight) + (2@1)).
	aMorph beTransparent; borderWidth: 2; borderColor: ScriptingSystem commandFeedback; lock.
	Project current world addHighlightMorph: aMorph for: self outmostScriptEditor
]

{ #category : #'as yet unclassified' }
PhraseTileForTest >> initialize [

	super initialize.
	self color: Color orange muchLighter.
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		borderWidth: 1;
		borderColor: ScriptingSystem standardTileBorderColor.
	self setupCostume.

]

{ #category : #mouse }
PhraseTileForTest >> mouseDown: evt [ 
	"Handle a mouse-down on the receiver"

	| guyToTake catViewer |
	guyToTake := CompoundTileMorph new.
	guyToTake setNamePropertyTo: 'TestTile' translated.
	guyToTake position: evt position + (-25@8).

	guyToTake formerPosition: evt hand position.
	"self startSteppingSelector: #trackDropZones."
	(catViewer := self ownerThatIsA: CategoryViewer) ifNotNil:
		[guyToTake setProperty: #newPermanentPlayer toValue: catViewer scriptedPlayer.
		guyToTake setProperty: #newPermanentScript toValue: true].
	guyToTake justGrabbedFromViewer: true.

	^ evt hand grabMorph: guyToTake
]

{ #category : #'as yet unclassified' }
PhraseTileForTest >> setupCostume [

	| stringMorph |
	stringMorph := StringMorph new contents: 'Test' translated.
	stringMorph name: 'Test' translated.
	stringMorph font: Preferences standardEToysFont.
	self addMorphBack: stringMorph.
	self addMorphBack: (Morph new color: color;
			 extent: 15 @ 5).

	stringMorph := StringMorph new contents: 'Yes' translated.
	stringMorph name: 'Yes' translated.
	stringMorph font: Preferences standardEToysFont.
	self addMorphBack: stringMorph.
	self addMorphBack: (Morph new color: color;
			 extent: 15 @ 5).

	stringMorph := StringMorph new contents: 'No' translated.
	stringMorph name: 'No' translated.
	stringMorph font: Preferences standardEToysFont.
	self addMorphBack: stringMorph.
	self addMorphBack: (Morph new color: color;
			 extent: 15 @ 5).

]
