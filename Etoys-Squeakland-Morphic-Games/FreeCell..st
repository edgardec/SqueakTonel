Class {
	#name : #FreeCell,
	#superclass : #AlignmentMorph,
	#instVars : [
		'board',
		'cardsRemainingDisplay',
		'elapsedTimeDisplay',
		'gameNumberDisplay',
		'lastGameLost',
		'state',
		'autoMoveRecursionCount',
		'myFillStyle'
	],
	#classVars : [
		'Statistics'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'parts bin' }
FreeCell class >> descriptionForPartsBin [
	^ self partName:	'FreeCell' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'A unique solitaire card game' translatedNoop
]

{ #category : #'class initialization' }
FreeCell class >> initialize [

	Statistics := FreeCellStatistics new.
]

{ #category : #actions }
FreeCell >> autoMovingHome [

	elapsedTimeDisplay pause.
	autoMoveRecursionCount := autoMoveRecursionCount + 1.
]

{ #category : #accessing }
FreeCell >> board [

	board ifNil: 
		[board := FreeCellBoard new
			target: self;
			actionSelector: #boardAction:].
	^board
]

{ #category : #actions }
FreeCell >> boardAction: actionSymbol [

	actionSymbol = #cardMovedHome 	ifTrue: [^self cardMovedHome].
	actionSymbol = #autoMovingHome	ifTrue: [^self autoMovingHome].
]

{ #category : #private }
FreeCell >> buildButton: aButton target: aTarget label: aLabel selector: aSelector [
	"wrap a button or switch in an alignmentMorph to provide some space around the button"

	| a |
	aButton 
		target: aTarget;
		label: aLabel;
		actionSelector: aSelector;
		borderStyle: (BorderStyle raised width: 2);
		color: Color gray.
	a := AlignmentMorph newColumn
		wrapCentering: #center; cellPositioning: #topCenter;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent;
		layoutInset: 1.
	a addMorph: aButton.
	^ a


]

{ #category : #actions }
FreeCell >> cardMovedHome [

	cardsRemainingDisplay value: (cardsRemainingDisplay value - 1).
	autoMoveRecursionCount := autoMoveRecursionCount - 1 max: 0.
	cardsRemainingDisplay value = 0 
		ifTrue: [self gameWon]
		ifFalse: [autoMoveRecursionCount = 0 ifTrue: [elapsedTimeDisplay continue]].
]

{ #category : #'visual properties' }
FreeCell >> colorNearBottom [

	^Color r: 0.0 g: 0.455 b: 0.18
]

{ #category : #'visual properties' }
FreeCell >> colorNearTop [

	^ (Color r: 0.304 g: 0.833 b: 0.075)
]

{ #category : #accessing }
FreeCell >> currentGame [

	^self board cardDeck seed
]

{ #category : #'user interface' }
FreeCell >> defaultBackgroundColor [

	^Color r: 0.365 g: 1.0 b: 0.09
]

{ #category : #initialization }
FreeCell >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
FreeCell >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ self colorNearTop
]

{ #category : #'visual properties' }
FreeCell >> fillStyle [

	myFillStyle ifNil: [
		myFillStyle := GradientFillStyle ramp: {
			0.0 -> self colorNearTop. 
			1.0 -> self colorNearBottom
		}.
	].
	^myFillStyle
		origin: self position;
		direction: (self width // 2)@self height

]

{ #category : #actions }
FreeCell >> gameLost [

	state := #lost.
	elapsedTimeDisplay stop.
	cardsRemainingDisplay highlighted: true; flash: true.
	Statistics gameLost: self currentGame
]

{ #category : #actions }
FreeCell >> gameWon [

	state := #won.
	elapsedTimeDisplay stop; highlighted: true; flash: true.
	Statistics gameWon: self currentGame
]

{ #category : #actions }
FreeCell >> help [

	self helpText editWithLabel: 'FreeCell Help'.
]

{ #category : #accessing }
FreeCell >> helpText [
	^ 'The objective of FreeCell is to move all of the cards to the four "home cells" in the upper right corner.  Each home cell will hold one suit and must be filled sequentially starting with the Ace.

There are four "free cells" in the upper left corner that can each hold one card.  Cards can be moved from the bottom of a stack to a free cell or to another stack.  

When moving a card to another stack, it must have a value that is one less than the exposed card and of a different color.' translated
]

{ #category : #actions }
FreeCell >> inAutoMove [
	"Return true if an automove sequence is in progress"

	^ autoMoveRecursionCount > 0
]

{ #category : #initialization }
FreeCell >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	Statistics newSession.
	autoMoveRecursionCount := 0.
	self listDirection: #topToBottom.
	self wrapCentering: #center;
		 cellPositioning: #topCenter.
	self vResizing: #shrinkWrap.
	self hResizing: #shrinkWrap.
	self
		 addMorph: self makeControls;
		 addMorph: self board;
		 newGame
]

{ #category : #initialization }
FreeCell >> makeCardsRemainingDisplay [
	cardsRemainingDisplay := LedMorph new digits: 2;
				 extent: 2 * 10 @ 15.
	^ self wrapPanel: cardsRemainingDisplay label: 'Cards Left: ' translated
]

{ #category : #initialization }
FreeCell >> makeControlBar [

	^AlignmentMorph newRow
		color: self colorNearBottom;
		borderStyle: (BorderStyle inset width: 2);
		layoutInset: 0;
		hResizing: #spaceFill; vResizing: #shrinkWrap; wrapCentering: #center; cellPositioning: #leftCenter;
		yourself.
]

{ #category : #initialization }
FreeCell >> makeControls [

	^self makeControlBar
		addMorph: AlignmentMorph newVariableTransparentSpacer;
		addMorph: self makeHelpButton;
		addMorph: self makeQuitButton;
		addMorph: self makeStatisticsButton;
		addMorph: self makeGameNumberDisplay;
		addMorph: self makePickGameButton;
		addMorph: self makeSameGameButton;
		addMorph: self makeNewGameButton;
		addMorph: self makeElapsedTimeDisplay;
		addMorph: self makeCardsRemainingDisplay;
		yourself.
]

{ #category : #initialization }
FreeCell >> makeElapsedTimeDisplay [
	elapsedTimeDisplay := LedTimerMorph new digits: 3;
				 extent: 3 * 10 @ 15.
	^ self wrapPanel: elapsedTimeDisplay label: 'Elapsed Time: ' translated
]

{ #category : #initialization }
FreeCell >> makeGameNumberDisplay [
	gameNumberDisplay := LedMorph new digits: 5;
				 extent: 5 * 10 @ 15.
	^ self wrapPanel: gameNumberDisplay label: 'Game #: ' translated
]

{ #category : #initialization }
FreeCell >> makeHelpButton [
	^ self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'Help' translated
		selector: #help
]

{ #category : #initialization }
FreeCell >> makeNewGameButton [
	^ self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'New game' translated
		selector: #newGame
]

{ #category : #initialization }
FreeCell >> makePickGameButton [
	^ self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'Pick game' translated
		selector: #pickGame
]

{ #category : #initialization }
FreeCell >> makeQuitButton [
	^ self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'Quit' translated
		selector: #quit
]

{ #category : #initialization }
FreeCell >> makeSameGameButton [
	^ self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'Same game' translated
		selector: #sameGame
]

{ #category : #initialization }
FreeCell >> makeStatisticsButton [
	^ self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'Statistics' translated
		selector: #statistics
]

{ #category : #'user interface' }
FreeCell >> modelSleep [
	"When fixing #contains: calls beware of reinventing #includes:"
	(#(newGame sameGame pickGame won lost ) includes: state)
		ifTrue: [elapsedTimeDisplay pause]
]

{ #category : #'user interface' }
FreeCell >> modelWakeUp [
	"Maybe less performant but more readable"
	(#(won lost) includes: state)
		ifFalse: [elapsedTimeDisplay resume]
]

{ #category : #actions }
FreeCell >> newGame [
	Collection initialize.
	self newGameNumber: nil.
	state := #newGame
]

{ #category : #actions }
FreeCell >> newGameNumber: aSeedOrNil [ 
	cardsRemainingDisplay value ~~ 0 ifTrue: [self gameLost].
	cardsRemainingDisplay flash: false; highlighted: false; value: 52.
	elapsedTimeDisplay flash: false; highlighted: false.
	"board handles nil case"
	self board pickGame: aSeedOrNil.
	elapsedTimeDisplay reset; start.
	gameNumberDisplay value: self currentGame
]

{ #category : #initialization }
FreeCell >> openInWindowLabeled: aString inWorld: aWorld [

	^(super openInWindowLabeled: aString inWorld: aWorld)
		model: self;
		yourself
]

{ #category : #actions }
FreeCell >> pickGame [
	| seed |
	seed := self promptForSeed.
	seed isNil ifTrue: [^ self].
	self newGameNumber: seed.
	state := #pickGame
]

{ #category : #actions }
FreeCell >> promptForSeed [
	| ss ii hh |
	[hh := board hardness
				ifNil: [0].
	ss := FillInTheBlank request: 'Pick a game number between 1 and 32000.
or
set the hardness of the next game by typing ''H 30''.
Above 100 is very hard.  Zero is standard game.
Current hardness is: ' translated , hh printString.
	"Let the user cancel."
	ss isEmpty
		ifTrue: [^ nil].
	ss := ss withoutQuoting.
	ss first asLowercase == $h
		ifTrue: ["Set the hardness"
			[ii := ss numericSuffix]
				on: Error
				do: [ii := 0].
			board hardness: ii.
			^ nil].
	[ii := ss asNumber asInteger]
		on: Error
		do: [ii := 0].
	ii between: 1 and: 32000] whileFalse.
	^ ii
]

{ #category : #actions }
FreeCell >> quit [
	cardsRemainingDisplay value ~~ 0 ifTrue: [self gameLost].

	self owner == self world
		ifTrue: [self delete]
		ifFalse: [self owner delete].
	Statistics close
]

{ #category : #actions }
FreeCell >> sameGame [
	self newGameNumber: self currentGame.
	state := #sameGame.


]

{ #category : #actions }
FreeCell >> statistics [

	Statistics display
]

{ #category : #private }
FreeCell >> wrapPanel: anLedPanel label: aLabel [
	"wrap an LED panel in an alignmentMorph with a label to its left"

	| a |
	a := AlignmentMorph newRow
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		borderWidth: 0;
		layoutInset: 5;
		color: Color transparent.
	a addMorph: anLedPanel.
	a addMorph: (StringMorph contents: aLabel). 
	^ a

]
