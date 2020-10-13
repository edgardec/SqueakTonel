"
Used for layout.
Since all morphs now support layoutPolicy the main use of this class is no longer needed.
Kept around for compability. 
Supports a few methods not found elsewhere that can be convenient, eg. newRow

"
Class {
	#name : #AlignmentMorph,
	#superclass : #RectangleMorph,
	#category : #'Morphic-Basic'
}

{ #category : #'instance creation' }
AlignmentMorph class >> columnPrototype [
	"Answer a prototypical column"

	| sampleMorphs aColumn |
	sampleMorphs := #(red yellow green) collect:
		[:aColor | Morph new extent: 130 @ 38; color: (Color perform: aColor); setNameTo: aColor asString; yourself].
	aColumn := self inAColumn: sampleMorphs.
	aColumn setNameTo: 'Column'.
	aColumn color: Color veryVeryLightGray.
	aColumn cellGap: 4; layoutInset: 6.
	aColumn enableDragNDrop.
	aColumn setBalloonText: 'Things dropped into here will automatically be organized into a column. Once you have added your own items here, you will want to remove the sample colored rectangles that this started with, and you will want to change this balloon help message to one of your own!' translated.
	^ aColumn
]

{ #category : #scripting }
AlignmentMorph class >> defaultNameStemForInstances [
	"The code just below, now commented out, resulted in every instance of every sublcass of AlignmentMorph being given a default name of the form 'Alignment1', rather than the desired 'MoviePlayer1', 'ScriptEditor2', etc."

	"^ 'Alignment'"

	^ super defaultNameStemForInstances
]

{ #category : #'instance creation' }
AlignmentMorph class >> inAColumn: aCollectionOfMorphs [
	"Answer a columnar AlignmentMorph holding the given collection"

	| col |
	col := self newColumn
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		layoutInset: 1;
		borderColor: Color black;
		borderWidth: 1;
		wrapCentering: #center;
		cellPositioning: #topCenter.
	aCollectionOfMorphs do: [:each | col addMorphBack: each].
	^ col
]

{ #category : #'instance creation' }
AlignmentMorph class >> inARow: aCollectionOfMorphs [
	"Answer a row-oriented AlignmentMorph holding the given collection"

	| aRow |
	aRow := self newRow
		color: Color transparent;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		layoutInset: 1;
		borderColor: Color black;
		borderWidth: 1;
		wrapCentering: #center;
		cellPositioning: #topCenter.
	aCollectionOfMorphs do: [ :each | aRow addMorphBack: each].
	^ aRow
]

{ #category : #'instance creation' }
AlignmentMorph class >> newColumn [

	^ self new
		listDirection: #topToBottom;
		hResizing: #spaceFill;
		extent: 1@1;
		vResizing: #spaceFill

]

{ #category : #'instance creation' }
AlignmentMorph class >> newRow [

	^ self new
		listDirection: #leftToRight;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		extent: 1@1;
		borderWidth: 0

]

{ #category : #'instance creation' }
AlignmentMorph class >> newSpacer: aColor [
	"Answer a space-filling instance of me of the given color."

	^ self new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutInset: 0;
		borderWidth: 0;
		extent: 1@1;
		color: aColor.

]

{ #category : #'instance creation' }
AlignmentMorph class >> newVariableTransparentSpacer [
	"Answer a space-filling instance of me of the given color."

	^ self new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutInset: 0;
		borderWidth: 0;
		extent: 1@1;
		color: Color transparent

]

{ #category : #'instance creation' }
AlignmentMorph class >> rowPrototype [
	"Answer a prototypical row"

	| sampleMorphs aRow |
	sampleMorphs := (1 to: (2 + 3 atRandom)) collect:
		[:integer | EllipseMorph new extent: ((60 + (20 atRandom)) @ (80 + ((20 atRandom)))); color: Color random; setNameTo: ('egg',  integer asString); yourself].
	aRow := self inARow: sampleMorphs.
	aRow setNameTo: 'Row'.
	aRow enableDragNDrop.
	aRow cellGap: 6.
	aRow layoutInset: 8.
	aRow setBalloonText: 'Things dropped into here will automatically be organized into a row. Once you have added your own items here, you will want to remove the sample colored eggs that this started with, and you will want to change this balloon help message to one of your own!' translated.
	aRow color: Color veryVeryLightGray.
	^ aRow

			"AlignmentMorph rowPrototype openInHand"
]

{ #category : #'visual properties' }
AlignmentMorph >> canHaveFillStyles [
	"Return true if the receiver can have general fill styles; not just colors.
	This method is for gradually converting old morphs."

	^ self class == AlignmentMorph "no subclasses"
]

{ #category : #'object fileIn' }
AlignmentMorph >> convertOldAlignmentsNov2000: varDict using: smartRefStrm [ 
	"major change - much of AlignmentMorph is now implemented more generally in Morph"

	"These are going away 
	#('orientation' 'centering' 'hResizing' 'vResizing' 
	'inset' 'minCellSize' 'layoutNeeded' 'priorFullBounds')"

	| orientation centering hResizing vResizing inset minCellSize inAlignment |
	orientation := varDict at: 'orientation'.
	centering := varDict at: 'centering'.
	hResizing := varDict at: 'hResizing'.
	vResizing := varDict at: 'vResizing'.
	inset := varDict at: 'inset'.
	minCellSize := varDict at: 'minCellSize'.
	(orientation == #horizontal or: [orientation == #vertical]) 
		ifTrue: [self layoutPolicy: TableLayout new].
	self cellPositioning: #topLeft.
	self rubberBandCells: true.
	orientation == #horizontal ifTrue: [self listDirection: #leftToRight].
	orientation == #vertical ifTrue: [self listDirection: #topToBottom].
	centering == #topLeft ifTrue: [self wrapCentering: #topLeft].
	centering == #bottomRight ifTrue: [self wrapCentering: #bottomRight].
	centering == #center 
		ifTrue: 
			[self wrapCentering: #center.
			orientation == #horizontal 
				ifTrue: [self cellPositioning: #leftCenter]
				ifFalse: [self cellPositioning: #topCenter]].
	(inset isNumber or: [inset isPoint]) ifTrue: [self layoutInset: inset].
	(minCellSize isNumber or: [minCellSize isPoint]) 
		ifTrue: [self minCellSize: minCellSize].
	(self hasProperty: #clipToOwnerWidth) ifTrue: [self clipSubmorphs: true].

	"now figure out if our owner was an AlignmentMorph, even if it is reshaped..."
	inAlignment := false.
	owner isMorph 
		ifTrue: [(owner isAlignmentMorph) ifTrue: [inAlignment := true]]
		ifFalse: 
			["e.g., owner may be reshaped"

			(owner class instanceVariablesString 
				findString: 'orientation centering hResizing vResizing') > 0 
				ifTrue: 
					["this was an alignment morph being reshaped"

					inAlignment := true]].
	"And check for containment in system windows"
	owner isSystemWindow ifTrue: [inAlignment := true].
	(hResizing == #spaceFill and: [inAlignment not]) 
		ifTrue: [self hResizing: #shrinkWrap]
		ifFalse: [self hResizing: hResizing].
	(vResizing == #spaceFill and: [inAlignment not]) 
		ifTrue: [self vResizing: #shrinkWrap]
		ifFalse: [self vResizing: vResizing]
]

{ #category : #'objects from disk' }
AlignmentMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [

	| newish |
	newish := super convertToCurrentVersion: varDict refStream:
smartRefStrm.

	"major change - much of AlignmentMorph is now implemented
more generally in Morph"
	varDict at: 'hResizing' ifPresent: [ :x |
		^ newish convertOldAlignmentsNov2000: varDict using:
smartRefStrm].
	^ newish

]

{ #category : #initialization }
AlignmentMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 0
]

{ #category : #initialization }
AlignmentMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.8
		g: 1.0
		b: 0.8
]

{ #category : #initialization }
AlignmentMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self layoutPolicy: TableLayout new;
	 listDirection: #leftToRight;
	 wrapCentering: #topLeft;
	 hResizing: #spaceFill;
	 vResizing: #spaceFill;
	 layoutInset: 2;
	 rubberBandCells: true
]

{ #category : #classification }
AlignmentMorph >> isAlignmentMorph [

	^ true

]

{ #category : #initialization }
AlignmentMorph >> openInWindowLabeled: aString inWorld: aWorld [

	self layoutInset: 0.
	^super openInWindowLabeled: aString inWorld: aWorld.
]

{ #category : #'event handling' }
AlignmentMorph >> wantsKeyboardFocusFor: aSubmorph [
	aSubmorph wouldAcceptKeyboardFocus ifTrue: [^ true].
	^ super wantsKeyboardFocusFor: aSubmorph
]
