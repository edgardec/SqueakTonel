"
Chess960Morph is a nicer, scalable, skin for ChessMorph.
It also can play Fischer random chess (use the '960' button) 

	Chess960Morph new openInWorld

	(Chess960Morph new squareSize: 100) openInWorld

"
Class {
	#name : #Chess960Morph,
	#superclass : #ChessMorph,
	#instVars : [
		'images',
		'message',
		'squareSize'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess960'
}

{ #category : #'parts bin' }
Chess960Morph class >> descriptionForPartsBin [
	^ self partName: 	'Chess 960' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'A fine game of chess. Revised by Stéphane Rollandin (spfa).' translatedNoop
]

{ #category : #initialize }
Chess960Morph >> addButtonRow [

	| r m |
	r := AlignmentMorph newRow hResizing: #shrinkWrap; vResizing: #shrinkWrap; color: Color transparent.
	r cellInset: 2.
	r addMorphBack: (self buttonName: '  New  ' translated action: #newGame).
	r addMorphBack: (self buttonName: '  960  ' translated action: #new960Game).
	r addMorphBack: (self buttonName: '  Help  ' translated action: #findBestMove).
	r addMorphBack: (self buttonName: '  Play  ' translated action: #thinkAndMove).
	r addMorphBack: (self buttonName: '  Auto  ' translated action: #autoPlay).
	r addMorphBack: (self buttonName: '  Undo  ' translated action: #undoMove).
	r addMorphBack: (self buttonName: '  Redo  ' translated action: #redoMove).
	r addMorphBack: (self buttonName: '  Quit  ' translated action: #delete).
	r disableTableLayout: true.
	r align: r bounds topLeft with: self layoutBounds topLeft.
	self addMorphFront: r.
	m := UpdatingStringMorph on: self selector: #statusString.
	m useStringFormat.
	m disableTableLayout: true.
	m stepTime: 50.
	m align: m bounds topLeft with: r fullBounds bottomLeft.
	self addMorphFront: m.
	m
		font: self textFont; 
		color: self statusColor; 
		maximumWidth: self width - self squareSize; 
		position:  self position + (self squareSize @ self squareSize * 0.6)
]

{ #category : #initialize }
Chess960Morph >> addSquares [
	| white black border square index |
	white := self whiteColor.
	black := self blackColor.
	border := self highColor.
	index := 0.
	#(
		(	' '	'a'	'b'	'c'	'd'	'e'	'f'	'g'	'h'	' ')
		(	'1'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	' ')
		(	'2'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	' ')
		(	'3'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	' ')
		(	'4'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	' ')
		(	'5'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	' ')
		(	'6'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	' ')
		(	'7'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	' ')
		(	'8'	'W'	'B'	'W'	'B'	'W'	'B'	'W'	'B'	' ')
		(	' '	' '	' '	' '	' '	' '	' '	' '	' '	' ')
	) do:[:file|
		file do:[:sq|
		square := self newSquare.
		square borderWidth: 0.
		(sq = 'W' or:[sq = 'B']) ifTrue:[
			square color: (sq = 'W' ifTrue:[white] ifFalse:[black]).
			square borderColor: border.
			square setProperty: #squarePosition toValue: (index := index + 1).
			square setNameTo: 
				(String with: ($a asInteger + (index - 1 bitAnd: 7)) asCharacter with: ($1 asInteger + (index -1 bitShift: -3)) asCharacter).
			square on: #mouseEnter send: #showMoves:from: to: self.
			square on: #mouseEnterDragging send: #dragSquareEnter:from: to: self.
			square on: #mouseLeaveDragging send: #dragSquareLeave:from: to: self.
		] ifFalse:["decoration"
			square color: Color transparent.
			sq = ' ' ifFalse:[
				square addMorph: ((StringMorph contents: sq font: self textFont)
										color: self labelsColor).
			].
		].
		square extent: self squareSize @ self squareSize.
		self addMorphBack: square.
		square submorphs ifNotEmpty: [square submorphs first center: square center]
	]].

]

{ #category : #theme }
Chess960Morph >> blackColor [
	
	" Color earth paler duller."	
	"^ Color grass duller"
	^ Color r: 0.343 g: 0.576 b: 0.207
]

{ #category : #theme }
Chess960Morph >> buttonColor [

"	^ Color lightBlue3 whiter 	"
	^ Color r: 0.667 g: 0.792 b: 0.833
]

{ #category : #initialize }
Chess960Morph >> buttonName: aString action: aSymbol [

	^ SimpleButtonMorph new
		target: self;
		label: aString;
		actionSelector: aSymbol;
		color: self buttonColor; 
		borderWidth: 1;
		borderRaised.

]

{ #category : #initialization }
Chess960Morph >> defaultBounds [
	"answer the default bounds for the receiver"
	^ 0 @ 0 corner: (self squareSize * 10 + 10) @ (self squareSize * 10 + 10)
]

{ #category : #theme }
Chess960Morph >> defaultColor [

	"^ Color paleTeal duller duller"
	^ Color r: 0.467 g: 0.631 b: 0.71
]

{ #category : #playing }
Chess960Morph >> findBestMove [
	| move |
	board ifNil: [^ self].
	board searchAgent isThinking ifTrue:[^self].

"tmp - board should be nil when the game is over"
	((1 to: 64) allSatisfy: [:n |
		(board activePlayer pieces at: n) isZero
			or: [(board activePlayer findValidMovesAt: n) isEmpty]])
				ifTrue: [message := (board activePlayer isWhitePlayer 
											ifTrue: ['white'] ifFalse: ['black']), ' lost'. 
						^ self].

	Cursor wait showWhile:[move := board searchAgent think].
	message :=  'I suggest ' translated, move moveString.
	^move

]

{ #category : #'as yet unclassified' }
Chess960Morph >> finishedGame: result [

	super finishedGame: result.
	message := #('black won' 'draw' 'white won') at: result * 2 + 1
]

{ #category : #theme }
Chess960Morph >> highColor [
	
"	^ Color lightGold"
	^ Color r: 0.992 g: 0.863 b: 0.361
]

{ #category : #theme }
Chess960Morph >> images [

	^ images ifNil: [images := ChessPieceMorphWC piecesWithHeight: self squareSize - 5]
]

{ #category : #initialization }
Chess960Morph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self bounds: self defaultBounds.
	self beSticky
]

{ #category : #theme }
Chess960Morph >> labelsColor [
	
"	^ Color armyGreen"
	^ Color r: 0.294 g: 0.365 b: 0.086
]

{ #category : #'game callbacks' }
Chess960Morph >> movedPiece: piece from: sourceSquare to: destSquare [
	| sourceMorph destMorph sourcePos destPos w startTime nowTime deltaTime |
	sourceMorph := (self atSquare: sourceSquare) firstSubmorph.
	destMorph := self atSquare: destSquare.
	animateMove ifTrue:[
		sourcePos := sourceMorph boundsInWorld center.
		destPos := destMorph boundsInWorld center.
		(w := self world) ifNotNil:[
			w addMorphFront: sourceMorph.
			deltaTime := (sourcePos dist: destPos) * 3 asInteger.
			startTime := Time millisecondClockValue.
			[nowTime := Time millisecondClockValue.
			nowTime - startTime < deltaTime] whileTrue:[
				sourceMorph center: sourcePos + (destPos - sourcePos * (nowTime - startTime) // deltaTime) asIntegerPoint.
				w displayWorldSafely].
			sourceMorph removeDropShadow.
		].
	].
	destMorph removeAllMorphs.
	destMorph addMorphCentered: sourceMorph.
	animateMove := false.
	message := nil.
]

{ #category : #initialize }
Chess960Morph >> new960Game [
	board := Chess960Board new.
	board initialize.
	board userAgent: self.
	board initializeNewBoard.
	history := OrderedCollection new.
	redoList := OrderedCollection new.
	message := nil

]

{ #category : #initialize }
Chess960Morph >> newPiece: piece white: isWhite [

	| index selector m |
	index := piece.
	isWhite ifFalse:[index := index + 6].
	selector := #(	
		whitePawn
		whiteKnight
		whiteBishop
		whiteRook
		whiteQueen
		whiteKing

		blackPawn
		blackKnight
		blackBishop
		blackRook
		blackQueen
		blackKing) at: index.
	m := ChessPieceMorph new image: (self images at: selector).
	m setProperty: #isWhite toValue: isWhite.
	m setProperty: #piece toValue: piece.
	^m
]

{ #category : #resizing }
Chess960Morph >> reinstallPieces [

	board whitePlayer pieces doWithIndex: [:pc :n |
		pc isZero ifFalse: [
			self addedPiece: pc at: n white: true]].

	board blackPlayer pieces doWithIndex: [:pc :n |
		pc isZero ifFalse: [
			self addedPiece: pc at: n white: false]].
]

{ #category : #miscellaneous }
Chess960Morph >> setExtentFromHalo: anExtent [

	self squareSize: (anExtent x - 10) //10.
]

{ #category : #events }
Chess960Morph >> showMovesAt: square [
	| list |
	board ifNil:[^self].
	board searchAgent isThinking ifTrue:[^self].
	self squaresDo:[:m| m borderWidth: 0].
	list := board activePlayer findValidMovesAt: square.
	list isEmpty ifTrue:[^self].
	(self atSquare: square) borderWidth: 2.
	list do:[:move|
		(self atSquare: (move triggerSquareIn: board)) borderWidth: 5.
	].
]

{ #category : #resizing }
Chess960Morph >> squareSize [
	
	^ squareSize ifNil: [70]
]

{ #category : #resizing }
Chess960Morph >> squareSize: anInteger [
	
	| ss |

	ss := anInteger max: 48.

	squareSize := ss.
	images := nil.
	submorphs do: #delete.
	self extent: (ss * 10 + 10) @ (ss * 10 + 10) .
	self addSquares.
	self addButtonRow.	
	self reinstallPieces
]

{ #category : #theme }
Chess960Morph >> statusColor [

"	^ Color reallyLightBlue 	"
	^ Color r: 0.831 g: 1 b: 1
]

{ #category : #'other stuff' }
Chess960Morph >> statusString [

	^ message ifNil: [super statusString]
]

{ #category : #'game callbacks' }
Chess960Morph >> swappedPieceOn: aSquare withPieceOn: bSquare [
	| aMorph bMorph |

	aMorph := (self atSquare: aSquare) firstSubmorph.
	bMorph := (self atSquare: bSquare) firstSubmorph.

	(self atSquare: aSquare) removeAllMorphs.
	(self atSquare: aSquare) addMorphCentered: bMorph.

	(self atSquare: bSquare)  removeAllMorphs.
	(self atSquare: bSquare)  addMorphCentered: aMorph.

	message := nil.
]

{ #category : #theme }
Chess960Morph >> textFont [ 

	| ps |

	ps := self squareSize < 80 ifTrue: [12] ifFalse: [15].

	^ TTCFont familyName: 'BitstreamVeraSans' pointSize: ps emphasis: 1

]

{ #category : #theme }
Chess960Morph >> whiteColor [
	
"	^ Color ivory"
	^ Color r: 1 g: 1 b: 0.94
]
