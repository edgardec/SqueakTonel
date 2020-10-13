"
This class is not used anymore. We keep it to let old projects work.
If we added code to auto-convert old instances of this classs to TimesRepeatTile instances, we could delete it for good.
"
Class {
	#name : #TimesRepeatMorph,
	#superclass : #CompoundTileMorph,
	#instVars : [
		'numberOfTimesToRepeatPart',
		'whatToRepeatPart'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #initialization }
TimesRepeatMorph >> initialize [
	"Fully initialize the receiver."

	| dummyColumn timesRow  timesRepeatColumn repeatRow separator repeatLabel placeHolder doLabel ephemerum |
	submorphs := #().
	bounds := 0@0 corner: 50@40.
	self color: Color orange muchLighter.

	self layoutPolicy: TableLayout new.
	self "border, and layout properties in alphabetical order..."
		borderColor: self color darker;
		borderWidth: 2; 
		cellPositioning: #topLeft;
		hResizing: #spaceFill;
		layoutInset: 0;
		listDirection: #leftToRight;
		rubberBandCells: true;
		vResizing: #shrinkWrap;
		wrapCentering: #none.

	self setNameTo: 'Repeat Complex'.

	dummyColumn := AlignmentMorph newColumn.
	dummyColumn cellInset: 0; layoutInset: 0.
	dummyColumn width: 0.
	dummyColumn cellPositioning: #leftCenter.
	dummyColumn hResizing: #shrinkWrap; vResizing: #spaceFill.
	self addMorph: dummyColumn.

	timesRepeatColumn := AlignmentMorph newColumn.
	timesRepeatColumn setNameTo: 'Times Repeat'.

	timesRepeatColumn cellPositioning: #topLeft.
	timesRepeatColumn hResizing: #spaceFill.
 	timesRepeatColumn vResizing: #shrinkWrap.
	timesRepeatColumn layoutInset: 0.
	timesRepeatColumn borderWidth: 0.
	timesRepeatColumn color:  Color orange muchLighter.

	timesRow := AlignmentMorph newRow color: color; layoutInset: 0.
	timesRow minCellSize: (2@16).
	timesRow setNameTo: 'Times'.
	repeatLabel := StringMorph  contents: 'Repeat' translated font:  Preferences standardEToysFont.
	timesRow addMorphBack: repeatLabel.
	timesRow vResizing: #shrinkWrap.
	timesRow addMorphBack: (Morph new color: color; extent: 6@5).  "spacer"

	numberOfTimesToRepeatPart := TilePadMorph new setType: #Number.
	numberOfTimesToRepeatPart hResizing: #shrinkWrap; color: Color transparent.
	numberOfTimesToRepeatPart addMorphBack: (TileMorph new addArrows; setLiteral: 2).
	numberOfTimesToRepeatPart borderWidth: 0; layoutInset: (1@0).

	timesRow addMorphBack: numberOfTimesToRepeatPart.
	timesRow addMorphBack: (StringMorph  contents: ' times ' font: Preferences standardEToysFont).
	timesRow addMorphBack: AlignmentMorph newVariableTransparentSpacer.
	timesRepeatColumn addMorphBack: timesRow.

	separator := AlignmentMorph newRow color:  Color transparent.
	separator vResizing: #rigid; hResizing: #spaceFill; height: 2.
	separator borderWidth: 0.
	timesRepeatColumn addMorphBack: separator.

	repeatRow := AlignmentMorph newRow color: color; layoutInset: 0.
	repeatRow minCellSize: (2@16).
	repeatRow setNameTo: 'Repeat '.
	placeHolder := Morph new.
	placeHolder beTransparent; extent: (8@0).
	repeatRow addMorphBack: placeHolder.
	repeatRow vResizing: #shrinkWrap.
	doLabel := StringMorph  contents: 'Do' font: Preferences standardEToysFont.
	repeatRow addMorphBack: doLabel.
	repeatRow addMorphBack: (Morph new color: color; extent: 5@5).  "spacer"
	repeatRow addMorphBack: (whatToRepeatPart := ScriptEditorMorph new borderWidth: 0; layoutInset: 0).

	whatToRepeatPart hResizing: #spaceFill.
	whatToRepeatPart vResizing: #shrinkWrap.
	whatToRepeatPart color: Color transparent.
	whatToRepeatPart setNameTo: 'Script to repeat'.
	whatToRepeatPart addMorphBack: (ephemerum := Morph new height: 14) beTransparent.

	timesRepeatColumn addMorphBack: repeatRow.
	
	self addMorphBack: timesRepeatColumn.
	self bounds: self fullBounds.

	ephemerum delete
]

{ #category : #access }
TimesRepeatMorph >> labelMorphs [

	| w |
	w := WriteStream on: (Array new: 3).
	w nextPut: self submorphs second submorphs first submorphs first.
	w nextPut: self submorphs second submorphs first submorphs fourth.
	w nextPut: self submorphs second submorphs third submorphs second.
	^ w contents.

]

{ #category : #'code generation' }
TimesRepeatMorph >> parseNodeWith: encoder [

	| rec selector arg |
	rec := numberOfTimesToRepeatPart submorphs
		ifEmpty:
			[encoder encodeLiteral: 0]
		ifNotEmpty:
			[numberOfTimesToRepeatPart parseNodeWith: encoder].
	selector := #timesRepeat:.
	arg := self blockNode: whatToRepeatPart with: encoder.
	^ MessageNode new
				receiver: rec
				selector: selector
				arguments: (Array with: arg)
				precedence: (selector precedence)
				from: encoder
				sourceRange: nil.

]

{ #category : #'code generation' }
TimesRepeatMorph >> storeCodeOn: aStream indent: tabCount [
	"Store code representing the receiver on the stream, obeying the tab state."

	aStream nextPutAll: '(('.
	numberOfTimesToRepeatPart submorphs
		ifEmpty:
			[aStream nextPutAll: '0']
		ifNotEmpty:
			[numberOfTimesToRepeatPart storeCodeOn: aStream indent: tabCount + 2].
	aStream nextPutAll: ' ) asInteger max: 0) timesRepeat:'.
	tabCount + 1 timesRepeat: [aStream tab].
	aStream nextPutAll: '['; cr.
	self storeCodeBlockFor: whatToRepeatPart on: aStream indent: tabCount + 2.
	aStream nextPut: $].

]

{ #category : #initialization }
TimesRepeatMorph >> targetPartFor: aMorph [
	"Return the row into which the given morph should be inserted."

	| centerY |
	centerY := aMorph fullBounds center y.
	{numberOfTimesToRepeatPart, whatToRepeatPart} do: [:m |
		(centerY <= m bounds bottom) ifTrue: [^ m]].
	^ noPart

]
