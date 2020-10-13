"
This class defines the user interface for a fine game of chess.
"
Class {
	#name : #ChessMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'board',
		'history',
		'redoList',
		'animateMove',
		'autoPlay'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #accessing }
ChessMorph class >> blackBishopImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 0 0 0 21053440 0 0 21053440 0 0 4538368 0 0 88489984 0 0 357978112 0 0 357994496 0 0 1431675904 0 1 1452647424 0 1 1452631040 0 5 1789487360 0 5 1789483264 0 5 1452628224 0 21 1452627200 0 21 1452626944 0 21 1431655424 0 21 1431655424 0 21 1431655424 0 21 1431654400 0 21 1431654400 0 5 1431654400 0 5 1431650304 0 1 1431650304 0 1 2863284224 0 1 2863284224 0 0 1431633920 0 0 445644800 0 1 1431650304 0 1 1789476864 0 1 1789476864 0 1 1431650304 0 0 20971520 0 0 89128960 0 0 357826560 0 21840 1414858069 0 349525 1410684245 1342177280 344085 1074091009 1342177280 262144 0 268435456 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> blackKingImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 4194304 0 0 22020096 0 0 4194304 0 0 89391104 0 0 111411200 0 1398016 107216981 1426063360 22369600 107218261 1430257664 22456660 107222362 2772434944 89740885 111416741 1498415104 90527125 1162892885 1448083456 93672805 1095850325 1448083456 362108249 1431656790 2522087424 362190169 1435854230 2522087424 362190422 1452643686 2522087424 362112598 1431672169 1448345600 362112597 2505463146 2522087424 93760085 2505463145 1448083456 93678165 2526434665 1448083456 93673045 1704351141 1498415104 90527317 1700353429 1498415104 23418261 1700353429 1497366528 22631829 1499027029 1497366528 22631829 1503221333 1698693120 5657957 1503222101 1694498816 1463653 1499026773 2483027968 1414485 1499026774 1409286144 354986 2841291433 1342177280 87381 1431655765 1073741824 21845 1431655765 0 5802 2863311508 0 6485 1431655780 0 6485 1521046884 0 6485 1431655780 0 6826 2863311524 0 5461 1431655764 0 0 0 0 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> blackKnightImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 0 0 0 268435456 0 1 335544320 0 1 335544320 0 1 1430257664 0 0 1431568384 0 1 1431650304 0 21 1432704000 0 342 2774160704 0 1370 1767216464 0 5461 2505402708 0 21845 1431656021 0 87381 1431655829 0 349525 1431655781 1073741824 1398101 1431672149 1342177280 1398101 1431672153 1342177280 5592405 1431983446 1409286144 5592405 1343576406 1409286144 22369600 1402197 2483027968 26543360 5920085 2768240640 22287360 5593685 1694498816 22040576 23766357 1694498816 81920 89478485 1698693120 0 89478485 1698693120 0 357913941 1765801984 0 1431655765 1765801984 0 1431655765 1766850560 1 1431655765 1498415104 5 1431655765 1498415104 21 1431655765 1498415104 21 1431655765 1498415104 21 1431655765 1498415104 85 1431655765 1498415104 341 1431655765 1498415104 341 1431655765 1498415104 1365 1431655765 1498415104 1365 1431655765 1431306240 1365 1431655765 1431306240 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> blackPawnImage [
	^((ColorForm
	extent: 40@40
	depth: 1
	fromArray: #( 0 0 15360 0 32256 0 32256 0 32256 0 32256 0 32256 0 15360 0 65280 0 262080 0 65280 0 32256 0 32256 0 65280 0 65280 0 65280 0 130944 0 262080 0 262080 0 524256 0 524256 0 524256 0 524256 0 524256 0 524256 0 524256 0 262080 0 262080 0 262080 0 130944 0 65280 0 65280 0 524256 0 4194300 0 8388606 0 16777215 0 33554431 2147483648 33554431 2147483648 33554431 2147483648 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032)  ))
]

{ #category : #accessing }
ChessMorph class >> blackQueenImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 5242880 0 0 5242880 0 0 1048576 0 320 4194324 0 320 5242900 0 64 5242896 0 64 5242896 0 64 5242896 0 80 5242960 0 83886160 5242960 0 83886160 5242960 1310720 16777300 5243216 1310720 4194388 22282576 1048576 4194388 22282576 4194304 5242964 22282576 4194304 5505109 22283600 20971520 1310805 22283600 88080384 1376341 22283600 88080384 1392725 1096029520 356515840 1392725 1096029520 356515840 1396821 1096029520 1430257664 1397845 1431655761 1426063360 349269 1431655761 1426063360 349525 1431655765 1426063360 349525 1431655765 1426063360 349525 1431655765 1426063360 349525 1521112405 1426063360 88746 2773854890 1409286144 91477 1453938005 2483027968 27285 1436898666 2415919104 23125 1521112410 1342177280 6826 2773854890 1073741824 5461 1431655765 1073741824 21845 1431655765 1342177280 21845 1431655765 1342177280 0 0 0 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> blackRookImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 357826560 0 349184 357826645 1073741824 349184 357826645 1073741824 349184 357826645 1073741824 349525 1431655765 1073741824 436906 2863311530 1073741824 349526 1431721301 1073741824 1366 1431721296 0 1366 1431721296 0 1366 1431721296 0 1366 1431721296 0 1366 1431721296 0 1706 2863311504 0 1365 1448432976 0 1365 1448432976 0 1365 1448432976 0 1365 1448432976 0 1365 1448432976 0 1706 2863311504 0 1366 1431721296 0 1366 1431721296 0 1366 1431721296 0 1366 1431721296 0 1366 1431721296 0 1706 2863311504 0 1365 1448432976 0 1365 1448432976 0 1365 1448432976 0 1365 1448432976 0 1365 1448432976 0 1365 1448432976 0 1706 2863311504 0 23210 2863311525 0 27306 2863311529 0 87381 1431655765 1073741824 436906 2863311530 2415919104 436906 2863311530 2415919104 349525 1431655765 1342177280 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #'parts bin' }
ChessMorph class >> descriptionForPartsBin [
	^ self partName: 	'Chess' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'A fine game of chess' translatedNoop
]

{ #category : #accessing }
ChessMorph class >> whiteBishopImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 0 0 0 16842752 0 0 88424448 0 0 88424448 0 0 89473024 0 0 378966016 0 0 1520865280 0 1 1789240320 0 1 2842256384 0 5 2842321920 0 6 2505462784 0 22 2505479168 0 26 2842338304 0 26 2842338304 0 26 2842338304 0 26 2863309824 0 26 2863309824 0 26 2863309824 0 26 2863309824 0 26 2863305728 0 22 2863304704 0 6 2863288320 0 5 2863284224 0 1 1431650304 0 1 1431650304 0 1 1768505344 0 1 1768505344 0 1 1768505344 0 1 1431650304 0 5 2863284224 0 5 1431654400 0 0 104857600 0 0 374341632 0 0 1498677248 0 87381 1701139797 1073741824 1419946 2488969898 1409286144 349525 1343575381 1342177280 1310720 0 335544320 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> whiteKingImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 0 0 0 22020096 0 0 93585408 0 0 111411200 0 0 93585408 0 0 362020864 0 1397760 447021077 1409286144 5940480 425263450 2768240640 23767376 429458858 2839543808 94721684 425268885 1448083456 110536037 426072410 2794455040 379234921 1499818410 2777939968 442149466 1431676586 2846097408 443198102 2526451305 1772355584 443116133 2842319449 1772355584 443111785 2841270937 2846097408 443193769 1785293465 2577661952 442866090 1789504149 1503920128 443110826 1785309845 2846097408 376083882 1499048598 2845048832 106603946 2573838938 2777677824 110799274 2594548330 2794455040 110799210 2594613610 2794455040 93760106 2523310506 2521825280 27699802 2774968746 2587885568 23440026 2795939242 1497366528 6908570 2795939497 1694498816 5925546 2795940521 2751463424 1463637 1453675861 2483027968 371301 2506447274 1342177280 87641 2590415189 1073741824 26261 1431655845 0 21850 2774182229 0 21930 2505484885 0 21866 2842339669 0 22165 1431655829 0 21850 2863311189 0 21845 1431655765 0 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> whiteKnightImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 1073741824 0 16 1342177280 0 20 1342177280 0 5 1430257664 0 6 2857713664 0 6 2862956544 0 22 2863223808 0 346 2863306048 0 1445 1789569360 0 22166 1521134164 0 91813 1789569685 0 367274 2863245989 1073741824 1469098 2862983845 1342177280 1682090 2863049385 1342177280 5679786 2863048362 1409286144 22718890 2861996714 1409286144 27961706 2775210410 2499805184 95070809 1432708522 2499805184 111503701 22455978 2503999488 378889472 27957930 2773483520 374969344 94988970 2773483520 88428544 106343082 2773483520 84295680 359312042 2840592384 344064 1521134250 2840592384 1 1789569706 2840592384 1 2863311530 2840854528 5 2863311530 2857631744 22 2863311530 2857631744 26 2863311530 2857631744 90 2863311530 2857631744 106 2863311530 2857631744 362 2863311530 2857631744 1450 2863311530 2857631744 1706 2863311530 2857631744 5802 2863311530 2857631744 6826 2863311530 2857631744 23210 2863311530 2857631744 21845 1431655765 1431568384 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> whitePawnImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 357826560 0 0 446955520 0 0 1520762880 0 0 1789460480 0 0 1520762880 0 0 378798080 0 0 1431633920 0 1 1789476864 0 21 2863289344 0 85 1431655680 0 0 446955520 0 0 1520762880 0 0 1789460480 0 0 1789460480 0 1 1789476864 0 5 2863288320 0 6 2863304704 0 22 2863305728 0 26 2863309824 0 90 2863310080 0 106 2863311104 0 106 2863311104 0 106 2863311104 0 90 2863310080 0 26 2863309824 0 26 2863309824 0 22 2863305728 0 6 2863304704 0 5 2863288320 0 1 1789476864 0 0 1789460480 0 341 1520784704 0 1450 2505484880 0 22186 2863311509 0 92842 2863311529 1073741824 109226 2863311530 1073741824 109226 2863311530 1073741824 87381 1431655765 1073741824 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> whiteQueenImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 0 0 0 5242880 0 0 22282240 0 0 5242880 0 64 5242896 0 336 5242964 0 336 5242964 0 64 5242896 0 64 5242896 0 80 5242960 0 80 22282320 0 83886160 27525200 1310720 352321620 27525456 1376256 88080484 27525520 1376256 20971620 27525520 5242880 5242981 27526544 5242880 5505129 27526800 22020096 6553705 27526800 93323264 6619241 1101272720 105906176 6881386 1168448144 373293056 5849194 1185487504 440401920 1724522 1453939344 1514143744 1740906 2527685265 1782579200 1741930 2527685265 2856321024 1746282 2863311509 2856321024 1747306 2863311510 2856321024 1485482 2863311530 2839543808 436906 2863311530 2835349504 436906 2505403050 2835349504 365909 1515869525 1694498816 87466 2773854885 1409286144 21850 2841029205 1342177280 21866 2505403029 1342177280 21845 1521112405 1342177280 27306 2863311530 2415919104 27306 2863311530 2415919104 92842 2863311530 2483027968 87381 1431655765 1409286144 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #accessing }
ChessMorph class >> whiteRookImage [
	^((ColorForm
	extent: 40@40
	depth: 2
	fromArray: #( 0 0 0 0 357892096 0 87360 447283221 1409286144 109120 447283226 2751463424 109120 447283226 2751463424 109141 1521046874 2751463424 109226 2863311530 2751463424 87381 1431655765 1409286144 426 1789553316 0 426 1789553316 0 426 1789553316 0 426 1789553316 0 426 1789553316 0 341 1431655764 0 426 2859117220 0 426 2859117220 0 426 2859117220 0 426 2859117220 0 426 2859117220 0 341 1431655764 0 426 1789553316 0 426 1789553316 0 426 1789553316 0 426 1789553316 0 426 1789553316 0 341 1431655764 0 426 2859117220 0 426 2859117220 0 426 2859117220 0 426 2859117220 0 426 2859117220 0 426 2859117220 0 5461 1431655765 0 23210 2863311529 1073741824 27306 2863311530 1073741824 87381 1431655765 1342177280 371370 2863311530 2483027968 436906 2863311530 2751463424 349525 1431655765 1409286144 0 0 0)
	offset: 0@0)
	colorsFromArray: #(#( ) #(0.0 0.0 0.032) #(1.0 1.0 1.0) #( )  ))
]

{ #category : #layout }
ChessMorph >> acceptDroppingMorph: aMorph event: anEvent [
	| destSquare sourceSquare |
	sourceSquare := aMorph valueOfProperty: #chessBoardSourceSquare.
	aMorph removeProperty: #chessBoardSourceSquare.
	destSquare := self asSquare: aMorph center.
	"!!! ACTUAL MOVE HAPPENS INDIRECTLY !!!"
	(self atSquare: sourceSquare) addMorphCentered: aMorph.
	destSquare ifNil:[^self].
	self movePieceFrom: sourceSquare to: destSquare.
	self showMovesAt: destSquare.
]

{ #category : #initialize }
ChessMorph >> addButtonRow [

	| r m |
	r := AlignmentMorph newRow hResizing: #shrinkWrap; vResizing: #shrinkWrap; color: Color transparent.
	r cellInset: 2.
	r addMorphBack: (self buttonName: '  New  ' translated action: #newGame).
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
	m align: m bounds topLeft with: r fullBounds bottomLeft.
	self addMorphFront: m.
]

{ #category : #initialize }
ChessMorph >> addSquares [
	| white black square index |
	white := Color white.
	black := Color lightGray.
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
			square borderColor: Color red.
			square setProperty: #squarePosition toValue: (index := index + 1).
			square setNameTo: 
				(String with: ($a asInteger + (index - 1 bitAnd: 7)) asCharacter with: ($1 asInteger + (index -1 bitShift: -3)) asCharacter).
			square on: #mouseEnter send: #showMoves:from: to: self.
			square on: #mouseEnterDragging send: #dragSquareEnter:from: to: self.
			square on: #mouseLeaveDragging send: #dragSquareLeave:from: to: self.
		] ifFalse:["decoration"
			square color: Color transparent.
			sq = ' ' ifFalse:[
				square addMorphCentered: (StringMorph contents: sq asUppercase font: Preferences windowTitleFont emphasis: 1).
			].
		].
		square extent: 40@40.
		self addMorphBack: square.
	]].

]

{ #category : #'game callbacks' }
ChessMorph >> addedPiece: piece at: square white: isWhite [
	| m |
	m := self newPiece: piece white: isWhite.
	m on: #mouseDown send: #dragPiece:from: to: self.
	m setProperty: #chessBoard toValue: self.
	(self atSquare: square) removeAllMorphs; addMorphCentered: m.
]

{ #category : #drawing }
ChessMorph >> areasRemainingToFill: x [
	^x areasOutside: self bounds
]

{ #category : #geometry }
ChessMorph >> asSquare: aPoint [
	self squaresDo:[:sq| (sq bounds containsPoint: aPoint) ifTrue:[^sq valueOfProperty: #squarePosition]].
	^nil
]

{ #category : #geometry }
ChessMorph >> atSquare: square [
	^submorphs detect:[:any| (any valueOfProperty: #squarePosition) = square] ifNone:[nil]
]

{ #category : #playing }
ChessMorph >> autoPlay [
	autoPlay := autoPlay not.
	autoPlay ifTrue:[self thinkAndMove].
]

{ #category : #initialize }
ChessMorph >> buttonFillStyle [

	| fill |
	fill := GradientFillStyle ramp: {
		0.0 -> (Color r: 0.05 g: 0.5 b: 1.0). 
		1.0 -> (Color r: 0.85 g: 0.95 b: 1.0)}.
	fill origin: (0@0).
	fill direction: 40@10.
	fill radial: false.
	^ fill

]

{ #category : #initialize }
ChessMorph >> buttonName: aString action: aSymbol [

	^ SimpleButtonMorph new
		target: self;
		label: aString;
		actionSelector: aSymbol;
		color: (Color gray: 0.8);  "old color"
		fillStyle: self buttonFillStyle;
		borderWidth: 1;
		borderRaised.

]

{ #category : #'game callbacks' }
ChessMorph >> completedMove: aMove white: aBool [
	board ifNil:[^self].
	history addLast: aMove.
	self validateGamePosition.
]

{ #category : #initialization }
ChessMorph >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
ChessMorph >> defaultBorderStyle [
	^ BorderStyle raised
]

{ #category : #initialization }
ChessMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 5
]

{ #category : #initialization }
ChessMorph >> defaultBounds [
	"answer the default bounds for the receiver"
	^ 0 @ 0 corner: 410 @ 410
]

{ #category : #initialization }
ChessMorph >> defaultColor [
	"answer the receiver's default color"
	| result |
	result := GradientFillStyle ramp: {0.0
					-> (Color
							r: 0.05
							g: 0.5
							b: 1.0). 1.0
					-> (Color
							r: 0.85
							g: 0.95
							b: 1.0)}.
	result origin: self bounds origin;
		 direction: self extent.
	result radial: false.
	^ result
]

{ #category : #'drag and drop' }
ChessMorph >> dragPiece: evt from: aMorph [
	board searchAgent isThinking ifTrue:[^self].
	self submorphsDo:[:m| m borderWidth: 0].
	aMorph setProperty: #chessBoardSourceSquare toValue: (aMorph owner valueOfProperty: #squarePosition).
	evt hand grabMorph: aMorph.
]

{ #category : #'drag and drop' }
ChessMorph >> dragSquareEnter: evt from: aMorph [
	"Note: #wantsDroppedMorph: will validate move"
	board ifNil:[^self].
	evt hand hasSubmorphs ifFalse:[^self].
	(self wantsDroppedMorph: evt hand firstSubmorph event: evt) ifFalse:[^self].
	aMorph borderWidth: 1.
]

{ #category : #'drag and drop' }
ChessMorph >> dragSquareLeave: evt from: aMorph [
	board ifNil:[^self].
	evt hand hasSubmorphs ifFalse:[^self].
	aMorph borderWidth: 0.
]

{ #category : #playing }
ChessMorph >> findBestMove [
	| move |
	board searchAgent isThinking ifTrue:[^self].
	Cursor wait showWhile:[move := board searchAgent think].
	self inform: 'I suggest: ' translated, move printString.
	^move
]

{ #category : #'game callbacks' }
ChessMorph >> finishedGame: result [
	"
		0 - white lost
		0.5 - draw
		1 - white won
	"
	board := nil.
]

{ #category : #'game callbacks' }
ChessMorph >> gameReset [
	self squaresDo:[:m| m removeAllMorphs; borderWidth: 0]
]

{ #category : #initialization }
ChessMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	animateMove := false.
	autoPlay := false.

	self cornerStyle: #square.
	self layoutPolicy: TableLayout new.
	self listDirection: #leftToRight;
		 wrapDirection: #bottomToTop.
	self addSquares.
	self addButtonRow.
	self newGame
]

{ #category : #playing }
ChessMorph >> movePieceFrom: sourceSquare to: destSquare [
	board ifNil:[^self].
	board searchAgent isThinking ifTrue:[^self].
	board movePieceFrom: sourceSquare to: destSquare.
	board searchAgent startThinking.
]

{ #category : #'game callbacks' }
ChessMorph >> movedPiece: piece from: sourceSquare to: destSquare [
	| sourceMorph destMorph sourcePos destPos w startTime nowTime deltaTime |
	sourceMorph := (self atSquare: sourceSquare) firstSubmorph.
	destMorph := self atSquare: destSquare.
	animateMove ifTrue:[
		sourcePos := sourceMorph boundsInWorld center.
		destPos := destMorph boundsInWorld center.
		(w := self world) ifNotNil:[
			w addMorphFront: sourceMorph.
			sourceMorph addDropShadow.
			sourceMorph shadowColor: (Color black alpha: 0.5).
			deltaTime := (sourcePos dist: destPos) * 10 asInteger.
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
]

{ #category : #playing }
ChessMorph >> newGame [
	board ifNil:[board := ChessBoard new].
	board initialize.
	board userAgent: self.
	board initializeNewBoard.
	history := OrderedCollection new.
	redoList := OrderedCollection new.

]

{ #category : #initialize }
ChessMorph >> newPiece: piece white: isWhite [
	| index selector m |
	index := piece.
	isWhite ifFalse:[index := index + 6].
	selector := #(	
		whitePawnImage
		whiteKnightImage
		whiteBishopImage
		whiteRookImage
		whiteQueenImage
		whiteKingImage

		blackPawnImage
		blackKnightImage
		blackBishopImage
		blackRookImage
		blackQueenImage
		blackKingImage) at: index.
	m := ChessPieceMorph new image: (self class perform: selector).
	m setProperty: #isWhite toValue: isWhite.
	m setProperty: #piece toValue: piece.
	^m
]

{ #category : #initialize }
ChessMorph >> newSquare [
	^BorderedMorph new "or anyone alike"
]

{ #category : #playing }
ChessMorph >> redoMove [
	"Redo the last undone move"
	redoList isEmpty ifTrue:[^self].
	board nextMove: redoList removeLast.

]

{ #category : #'game callbacks' }
ChessMorph >> removedPiece: piece at: square [
	animateMove ifFalse:[
		(self atSquare: square) removeAllMorphs.
	].
]

{ #category : #'game callbacks' }
ChessMorph >> replacedPiece: oldPiece with: newPiece at: square white: isWhite [
	self removedPiece: oldPiece at: square.
	self addedPiece: newPiece at: square white: isWhite
]

{ #category : #'other stuff' }
ChessMorph >> rotateBoard [
	self listDirection = #leftToRight
		ifTrue:[^self listDirection: #topToBottom; wrapDirection: #leftToRight].
	self listDirection = #topToBottom
		ifTrue:[^self listDirection: #rightToLeft; wrapDirection: #topToBottom].
	self listDirection = #rightToLeft
		ifTrue:[^self listDirection: #bottomToTop; wrapDirection: #rightToLeft].
	self listDirection = #bottomToTop
		ifTrue:[^self listDirection: #leftToRight; wrapDirection: #bottomToTop].

]

{ #category : #events }
ChessMorph >> showMoves: evt from: aMorph [
	| square |
	square := aMorph valueOfProperty: #squarePosition.
	square ifNotNil:[^self showMovesAt: square].
]

{ #category : #events }
ChessMorph >> showMovesAt: square [
	| list |
	board ifNil:[^self].
	board searchAgent isThinking ifTrue:[^self].
	self squaresDo:[:m| m borderWidth: 0].
	list := board activePlayer findValidMovesAt: square.
	list isEmpty ifTrue:[^self].
	(self atSquare: square) borderWidth: 1.
	list do:[:move|
		(self atSquare: (move triggerSquareIn: board)) borderWidth: 1.
	].
]

{ #category : #geometry }
ChessMorph >> squaresDo: aBlock [
	^submorphs do:[:m| (m hasProperty: #squarePosition) ifTrue:[aBlock value: m]].
]

{ #category : #'other stuff' }
ChessMorph >> statusString [
	board ifNil:[^''].
	^board statusString
]

{ #category : #'stepping and presenter' }
ChessMorph >> step [
	| move |
	board searchAgent isThinking ifTrue:[
		move := board searchAgent thinkStep.
		move ifNotNil:[
			animateMove := true.
			board movePieceFrom: move sourceSquare 
					to: move destinationSquare].
	] ifFalse:[
		autoPlay ifTrue:[board searchAgent startThinking].
	].
]

{ #category : #testing }
ChessMorph >> stepTime [
	^0
]

{ #category : #playing }
ChessMorph >> thinkAndMove [
	board searchAgent isThinking ifTrue:[^self].
	board searchAgent startThinking.
]

{ #category : #playing }
ChessMorph >> undoMove [
	"Undo the last move"
	board ifNil:[^self].
	history isEmpty ifTrue:[^self].
	board undoMove: history removeLast.

]

{ #category : #'game callbacks' }
ChessMorph >> undoMove: aMove white: aBool [
	board ifNil:[^self].
	redoList addLast: aMove.
	self validateGamePosition.
]

{ #category : #'game callbacks' }
ChessMorph >> validateGamePosition [
	"This method does nothing but validating what you see (on screen) is what you get (from the board)."
	| square piece isWhite p |
	1 to: 64 do:[:idx|
		square := self atSquare: idx.
		square hasSubmorphs 
			ifTrue:[piece := square firstSubmorph valueOfProperty: #piece.
					isWhite := square firstSubmorph valueOfProperty: #isWhite]
			ifFalse:[piece := 0. isWhite := nil].
		p := board whitePlayer pieceAt: idx.
		idx = board whitePlayer castlingRookSquare ifTrue:[p := ChessPlayer rook].
		isWhite == true ifTrue:[
			p = piece ifFalse:[self error:'White broken'].
		] ifFalse:[p = 0 ifFalse:[self error:'White broken']].
		p := board blackPlayer pieceAt: idx.
		idx = board blackPlayer castlingRookSquare ifTrue:[p := ChessPlayer rook].
		isWhite == false ifTrue:[
			p = piece ifFalse:[self error:'White broken'].
		] ifFalse:[p = 0 ifFalse:[self error:'White broken']].
	].
]

{ #category : #'dropping\/grabbing' }
ChessMorph >> wantsDroppedMorph: aMorph event: anEvent [
	| sourceSquare destSquare |
	(aMorph valueOfProperty: #chessBoard) == self ifFalse:[^false].
	board ifNil:[^true].
	sourceSquare := aMorph valueOfProperty: #chessBoardSourceSquare.
	destSquare := self asSquare: aMorph bounds center.
	destSquare ifNil:[^false].
	^board activePlayer isValidMoveFrom: sourceSquare to: destSquare
]
