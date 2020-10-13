Class {
	#name : #Mines,
	#superclass : #AlignmentMorph,
	#instVars : [
		'board',
		'minesDisplay',
		'timeDisplay',
		'helpText'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'parts bin' }
Mines class >> descriptionForPartsBin [
	^ self partName: 	'Mines' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'Find those mines' translatedNoop
]

{ #category : #access }
Mines >> board [

	board ifNil:
		[board := MinesBoard new
			target: self;
			actionSelector: #selection].
	^ board
]

{ #category : #initialize }
Mines >> buildButton: aButton target: aTarget label: aLabel selector: aSelector [
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
Mines >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
Mines >> defaultBorderStyle [
	^ BorderStyle raised
]

{ #category : #initialization }
Mines >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
Mines >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #actions }
Mines >> help: helpState [

	helpState
		ifTrue: [self addMorphBack: self helpText]
		ifFalse: [helpText delete]
]

{ #category : #access }
Mines >> helpString [
	^ 'Mines is a quick and dirty knock-off of the Minesweeper game found on Windows. I used this to teach myself Squeak. I liberally borrowed from the <SameGame> example, so the code should look pretty familiar, though like any project it has rapidly ...morphed... to reflect my own idiosyncracies. Note especially the lack of any idiomatic structure to the code - I simply haven''t learned them yet.

Mines is a very simple, yet extremely frustrating, game to play. The rules are just this: there are 99 mines laid down on the board. Find them without ""finding"" them. Your first tile is free - click anywhere. The tiles will tell you how many mines are right next to it, including the diagonals. If you uncover the number ''2'', you know that there are two mines hidden in the adjacent tiles. If you think you have found a mine, you can flag it by either ''shift'' clicking, or click with the ''yellow'' mouse button. Once you have flagged all of the mines adjacent to a numbered tile, you can click on the tile again to uncover the rest. Of course, you could be wrong about those too... 

You win once you have uncovered all of the tiles that do not contain mines. Good luck...

David A. Smith
dastrs@bellsouth.net' translated
]

{ #category : #access }
Mines >> helpText [

	helpText ifNil:
		[helpText := PluggableTextMorph new
			width: self width; "board width;"
			editString: self helpString].
	^ helpText
]

{ #category : #initialization }
Mines >> initialize [
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

{ #category : #initialize }
Mines >> makeControls [
	| row |
	row := AlignmentMorph newRow color: color;
				 borderWidth: 2;
				 layoutInset: 3.
	row borderStyle: BorderStyle inset.
	row hResizing: #spaceFill;
		 vResizing: #shrinkWrap;
		 wrapCentering: #center;
		 cellPositioning: #leftCenter;
		 extent: 5 @ 5.
	row
		addMorph: (self
				buildButton: SimpleSwitchMorph new
				target: self
				label: '  Help  ' translated
				selector: #help:).
	row
		addMorph: (self
				buildButton: SimpleButtonMorph new
				target: self
				label: '  Quit  ' translated
				selector: #delete).
	"row 
	addMorph: (self 
	buildButton: SimpleButtonMorph new 
	target: self 
	label: ' Hint '  translated
	selector: #hint)."
	row
		addMorph: (self
				buildButton: SimpleButtonMorph new
				target: self
				label: '  New game  ' translated
				selector: #newGame).
	minesDisplay := LedMorph new digits: 2;
				 extent: 2 * 10 @ 15.
	row
		addMorph: (self wrapPanel: minesDisplay label: 'Mines:' translated).
	timeDisplay := LedTimerMorph new digits: 3;
				 extent: 3 * 10 @ 15.
	row
		addMorph: (self wrapPanel: timeDisplay label: 'Time:' translated).
	^ row
]

{ #category : #access }
Mines >> minesDisplay [

	^ minesDisplay
]

{ #category : #actions }
Mines >> newGame [

	timeDisplay value: 0; flash: false.
	timeDisplay stop.
	timeDisplay reset.
	minesDisplay value: 99.
	self board resetBoard.
]

{ #category : #access }
Mines >> timeDisplay [

	^ timeDisplay
]

{ #category : #initialize }
Mines >> wrapPanel: anLedPanel label: aLabel [
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
