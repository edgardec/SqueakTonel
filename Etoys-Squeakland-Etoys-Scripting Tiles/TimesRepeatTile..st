"
A variant on the CompoundTileMorph that allows a section of code to be executed as many times as a numeric-control-field indicates.  For reasons of sharing and history, the CompoundTileMorph continues to be the one for test/yes/no, and this subclass disregards those three areas and adds two of its own.  An associated class is the TimesRow -- see its class comment.
"
Class {
	#name : #TimesRepeatTile,
	#superclass : #CompoundTileMorph,
	#instVars : [
		'timesRow',
		'whatToRepeatPart'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #initialization }
TimesRepeatTile >> initialize [
	"Fully initialize the receiver."

	| dummyColumn  timesRepeatColumn repeatRow separator placeHolder doLabel ephemerum |
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

	timesRow := TimesRow newRow color: color; layoutInset: 0.
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
	doLabel := StringMorph  contents: 'Do' translated font: Preferences standardEToysFont.
	repeatRow addMorphBack: doLabel.
	repeatRow addMorphBack: (Morph new color: color; extent: 5@5).  "spacer"
	repeatRow addMorphBack: (whatToRepeatPart := ScriptEditorMorph new borderWidth: 0; layoutInset: 0).

	whatToRepeatPart
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		color: (Color transparent);
		height: (Preferences standardEToysFont height);
		minHeight: (Preferences standardEToysFont height);
		setNameTo: ('Script to repeat' translated);
		addMorphBack: ((ephemerum := Morph new height: 14) beTransparent).

	timesRepeatColumn addMorphBack: repeatRow.
	
	self addMorphBack: timesRepeatColumn.
	self bounds: self fullBounds.

	ephemerum delete
]

{ #category : #access }
TimesRepeatTile >> labelMorphs [
	"Answer a list of the StringMorphs that constitute the user-visible labels in the receiver's interior -- in this case, the StringMorphs showing the words Repeat, times, and Do."

	| w |
	w := WriteStream on: (Array new: 3).
	w nextPut: self submorphs second submorphs first submorphs first.
	w nextPut: self submorphs second submorphs first submorphs fourth.
	w nextPut: self submorphs second submorphs third submorphs second.
	^ w contents

"
TimesRepeatTile new labelMorphs collect: [:m | m contents]
"

]

{ #category : #localization }
TimesRepeatTile >> localeChanged [
	"Hack to allow the times repeat to update when locale changes"
	self labelMorphs first contents: 'Repeat' translated.
	self labelMorphs second contents: (' ', ('times' translated), ' ').
	self labelMorphs third contents: 'Do' translated

]

{ #category : #access }
TimesRepeatTile >> numberOfTimesToRepeatPart [
	"Answer the TilePadMorph which holds the tiles defining the number of times to repeat"

	^ timesRow timesPad 
]

{ #category : #'code generation' }
TimesRepeatTile >> parseNodeWith: encoder [
	"Answer a MessageNode representing the receiver."

	| rec selector arg timesPart |
	rec := (timesPart := self numberOfTimesToRepeatPart) submorphs
		ifEmpty:
			[encoder encodeLiteral: 0]
		ifNotEmpty:
			[timesPart parseNodeWith: encoder].
	selector := #timesRepeat:.
	arg := self blockNode: whatToRepeatPart with: encoder.
	^ MessageNode new
				receiver: rec
				selector: selector
				arguments: (Array with: arg)
				precedence: (selector precedence)
				from: encoder
				sourceRange: nil

]

{ #category : #'code generation' }
TimesRepeatTile >> storeCodeOn: aStream indent: tabCount [
	"Store code representing the receiver on the stream, obeying the tab state."

	aStream nextPutAll: '(('.
	self numberOfTimesToRepeatPart submorphs
		ifEmpty:
			[aStream nextPutAll: '0']
		ifNotEmpty:
			[self numberOfTimesToRepeatPart storeCodeOn: aStream indent: tabCount + 2].
	aStream nextPutAll: ' ) asInteger max: 0) timesRepeat:'.
	tabCount + 1 timesRepeat: [aStream tab].
	aStream nextPutAll: '['; cr.
	self storeCodeBlockFor: whatToRepeatPart on: aStream indent: tabCount + 2.
	aStream nextPut: $].

]

{ #category : #initialization }
TimesRepeatTile >> targetPartFor: aMorph [
	"Return the row into which the given morph should be inserted."

	| centerY |
	centerY := aMorph fullBounds center y.
	{self numberOfTimesToRepeatPart, whatToRepeatPart} do: [:m |
		(centerY <= m bounds bottom) ifTrue: [^ m]].
	^ noPart

]
