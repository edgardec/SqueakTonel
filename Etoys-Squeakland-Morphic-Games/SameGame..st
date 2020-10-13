"
See SameGame>>helpString for an explanation of how to play
"
Class {
	#name : #SameGame,
	#superclass : #AlignmentMorph,
	#instVars : [
		'board',
		'scoreDisplay',
		'selectionDisplay',
		'helpText'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'parts bin' }
SameGame class >> descriptionForPartsBin [
	^ self partName:	'Same' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'A board game implementedby Tim Olson, based on a game originally written for UNIX by Eiji Fukumoto.' translatedNoop
]

{ #category : #access }
SameGame >> board [

	board ifNil:
		[board := SameGameBoard new
			target: self;
			actionSelector: #selection].
	^ board
]

{ #category : #access }
SameGame >> board: aSameGameBoard [

	board := aSameGameBoard
]

{ #category : #initialization }
SameGame >> buildButton: aButton target: aTarget label: aLabel selector: aSelector [
	"wrap a button or switch in an alignmentMorph to allow a row of buttons to fill space"

	| a |
	aButton 
		target: aTarget;
		label: aLabel;
		actionSelector: aSelector;
		borderStyle: (BorderStyle raised width: 2);
		color: color.
	a := AlignmentMorph newColumn
		wrapCentering: #center; cellPositioning: #topCenter;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		color: color.
	a addMorph: aButton.
	^ a


]

{ #category : #initialization }
SameGame >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #actions }
SameGame >> help: helpState [

	helpState
		ifTrue: [helpText := self helpText.
			"Text layout is broken, so add text and apply #spaceFill to make line breaks work"
			self addMorphBack: helpText.
			helpText textMorph hResizing: #spaceFill]
		ifFalse: [helpText delete]
]

{ #category : #access }
SameGame >> helpString [
	^ 'The object of SameGame is to maximize your score by removing tiles from the board.  Tiles are selected and removed by clicking on a tile that has at least one adjacent tile of the same color (where adjacent is defined as up, down, left, or right).

The first click selects a group of adjacent tiles, a second click in that group will remove it from the board, sliding tiles down and right to fill the space of the removed group.  If you wish to select a different group, simply click on it instead.

The score increases by "(selection - 2) squared", so you want to maximize the selection size as much as possible.  However, making small strategic selections may allow you to increase the size of a later selection.

If you are having a hard time finding a group, the "Hint" button will find one and select it for you (although it is likely not the best group to select!).

When there are no more groups available, the score display will flash with your final score.  Your final score is reduced by 1 for each tile remaining on the board.  If you manage to remove all tiles, your final score is increased by a bonus of 5 times the number of tiles on a full board.

Come on, you can beat that last score!  Click "New game"  ;-)

SameGame was originally written by Eiji Fukumoto for UNIX and X; this version is based upon the same game concept, but was rewritten from scratch.' translated
]

{ #category : #access }
SameGame >> helpText [

	helpText ifNil:
		[helpText := PluggableTextMorph new
			width: board width;
			editString: self helpString].
	^ helpText
]

{ #category : #initialization }
SameGame >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self listDirection: #topToBottom;
	  wrapCentering: #center;
		 cellPositioning: #topCenter;
	  vResizing: #shrinkWrap;
	  hResizing: #shrinkWrap;
	  layoutInset: 3;
	  addMorph: self makeControls;
	  addMorph: self board.
	helpText := nil.
	self newGame
]

{ #category : #initialization }
SameGame >> makeControls [

	| row |
	row := AlignmentMorph newRow
		color: color;
		borderWidth: 0;
		layoutInset: 3.
	row hResizing: #spaceFill; vResizing: #shrinkWrap; wrapCentering: #center; cellPositioning: #leftCenter; extent: 5@5.
	row addMorph:
		(self
			buildButton: SimpleSwitchMorph new
			target: self
			label: 'Help' translated
			selector: #help:).
	row addMorph:
		(self
			buildButton: SimpleButtonMorph new
			target: self
			label: 'Quit' translated
			selector: #delete).
	row addMorph:
		(self
			buildButton: SimpleButtonMorph new
			target: self board
			label: 'Hint' translated
			selector: #hint).
	row addMorph:
		(self
			buildButton: SimpleButtonMorph new
			target: self
			label: 'New game' translated
			selector: #newGame).
	selectionDisplay := LedMorph new
		digits: 2;
		extent: (2*10@15).
	row addMorph: (self wrapPanel: selectionDisplay label: 'Selection:' translated).
	scoreDisplay := LedMorph new
		digits: 4;
		extent: (4*10@15).
	row addMorph: (self wrapPanel: scoreDisplay label: 'Score:' translated).
	^ row
]

{ #category : #actions }
SameGame >> newGame [

	scoreDisplay value: 0; flash: false.
	selectionDisplay value: 0.
	self board resetBoard.
]

{ #category : #access }
SameGame >> scoreDisplay [

	^ scoreDisplay
]

{ #category : #actions }
SameGame >> selection [
	"a selection was made on the board; get its count and update the displays"

	| count score |
	count := self board selectionCount.
	count = 0 
		ifTrue: 
			[score := scoreDisplay value + (selectionDisplay value - 2) squared.
			board findSelection ifNil: 
					[count := board tilesRemaining.
					score := count = 0 
						ifTrue: [score + (5 * board rows * board columns)]
						ifFalse: [score - count max:0].
					scoreDisplay flash: true].
			scoreDisplay value: score].
	selectionDisplay value: count
]

{ #category : #initialization }
SameGame >> wrapPanel: anLedPanel label: aLabel [
	"wrap an LED panel in an alignmentMorph with a label to its left"

	| a |
	a := AlignmentMorph newRow
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		borderWidth: 0;
		layoutInset: 3;
		color: color lighter.
	a addMorph: anLedPanel.
	a addMorph: (StringMorph contents: aLabel). 
	^ a


]
