Class {
	#name : #ChessConstants,
	#superclass : #SharedPool,
	#classVars : [
		'A1',
		'A2',
		'A3',
		'A4',
		'A5',
		'A6',
		'A7',
		'A8',
		'B1',
		'B2',
		'B3',
		'B4',
		'B5',
		'B6',
		'B7',
		'B8',
		'Bishop',
		'BishopMovers',
		'BishopMoves',
		'C1',
		'C2',
		'C3',
		'C4',
		'C5',
		'C6',
		'C7',
		'C8',
		'CastlingDisableAll',
		'CastlingDisableKingSide',
		'CastlingDisableQueenSide',
		'CastlingDone',
		'CastlingEnableKingSide',
		'CastlingEnableQueenSide',
		'D1',
		'D2',
		'D3',
		'D4',
		'D5',
		'D6',
		'D7',
		'D8',
		'E1',
		'E2',
		'E3',
		'E4',
		'E5',
		'E6',
		'E7',
		'E8',
		'EmptySquare',
		'F1',
		'F2',
		'F3',
		'F4',
		'F5',
		'F6',
		'F7',
		'F8',
		'G1',
		'G2',
		'G3',
		'G4',
		'G5',
		'G6',
		'G7',
		'G8',
		'H1',
		'H2',
		'H3',
		'H4',
		'H5',
		'H6',
		'H7',
		'H8',
		'King',
		'KingMoves',
		'Knight',
		'KnightMoves',
		'Pawn',
		'PieceCenterScores',
		'PieceValues',
		'Queen',
		'Rook',
		'RookMovers',
		'RookMoves'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #'pool initialization' }
ChessConstants class >> initialize [
	"ChessConstants initialize"
	self initializePieceConstants.
	self initializeCastlingConstants.
	self initializePieceValues.
	self initializeMoves.
	self initializeCenterScores.
	self initializeBishopMovers.
	self initializeRookMovers.
	self initializeSquareConstants.
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeBishopMovers. [
	BishopMovers := Set new.
	BishopMovers add:Bishop.
	BishopMovers add:Queen.
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeBishopMoves [
	"ChessPlayer initialize"
	| index moveList1 moveList2 moveList3 moveList4 px py |
	BishopMoves := Array new: 64 withAll: #().
	0 to: 7 do:[:j|
		0 to: 7 do:[:i|
			index := (j * 8) + i + 1.
			moveList1 := moveList2 := moveList3 := moveList4 := #().
			1 to: 7 do:[:k|
				px := i + k. py := j - k.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList1 := moveList1 copyWith: (py * 8) + px + 1].
				px := i - k. py := j - k.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList2 := moveList2 copyWith: (py * 8) + px + 1].
				px := i + k. py := j + k.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList3 := moveList3 copyWith: (py * 8) + px + 1].
				px := i - k. py := j + k.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList4 := moveList4 copyWith: (py * 8) + px + 1].
			].
			BishopMoves at: index put: {moveList1. moveList2. moveList3. moveList4}.
		].
	].
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeCastlingConstants [
	CastlingDone := 1.

	CastlingDisableKingSide := 2.
	CastlingDisableQueenSide := 4.
	CastlingDisableAll := CastlingDisableQueenSide bitOr: CastlingDisableKingSide.

	CastlingEnableKingSide := CastlingDone bitOr: CastlingDisableKingSide.
	CastlingEnableQueenSide := CastlingDone bitOr: CastlingDisableQueenSide.

]

{ #category : #'pool initialization' }
ChessConstants class >> initializeCenterScores [
	"ChessPlayer initialize"
	PieceCenterScores := Array new: 6.
	1 to: 6 do:[:i| PieceCenterScores at: i put: (ByteArray new: 64)].
	PieceCenterScores at: Knight put:
		#(
			-4	0	0	0	0	0	0	-4
			-4	0	2	2	2	2	0	-4
			-4	2	3	2	2	3	2	-4
			-4	1	2	5	5	2	2	-4
			-4	1	2	5	5	2	2	-4
			-4	2	3	2	2	3	2	-4
			-4	0	2	2	2	2	0	-4
			-4	0	0	0	0	0	0	-4
		).
	PieceCenterScores at: Bishop put:
		#(
			-2	-2	-2	-2	-2	-2	-2	-2
			-2	0	0	0	0	0	0	-2
			-2	0	1	1	1	1	0	-2
			-2	0	1	2	2	1	0	-2
			-2	0	1	2	2	1	0	-2
			-2	0	1	1	1	1	0	-2
			-2	0	0	0	0	0	0	-2
			-2	-2	-2	-2	-2	-2	-2	-2
		).
	PieceCenterScores at: Queen put:
		#(
			-3	0	0	0	0	0	0	-3
			-2	0	0	0	0	0	0	-2
			-2	0	1	1	1	1	0	-2
			-2	0	1	2	2	1	0	-2
			-2	0	1	2	2	1	0	-2
			-2	0	1	1	1	1	0	-2
			-2	0	0	0	0	0	0	-2
			-3	0	0	0	0	0	0	-3
		).
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeKingMoves [
	"ChessPlayer initialize"
	| index px py moveList |
	KingMoves := Array new: 64 withAll: #().
	0 to: 7 do:[:j|
		0 to: 7 do:[:i|
			index := (j * 8) + i + 1.
			moveList := #().
			#( (-1 -1) (0 -1) (1 -1) (-1 0) (1 0) (-1 1) (0 1) (1 1)) do:[:spec|
				px := i + spec first.
				py := j + spec last.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList := moveList copyWith: (py * 8) + px + 1]].
			KingMoves at: index put: moveList
		].
	].
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeKnightMoves [
	"ChessPlayer initialize"
	| index px py moveList |
	KnightMoves := Array new: 64 withAll: #().
	0 to: 7 do:[:j|
		0 to: 7 do:[:i|
			index := (j * 8) + i + 1.
			moveList := #().
			#( (-2 -1) (-1 -2) (1 -2) (2 -1) (-2 1) (-1 2) (1 2) (2 1)) do:[:spec|
				px := i + spec first.
				py := j + spec last.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList := moveList copyWith: (py * 8) + px + 1]].
			KnightMoves at: index put: moveList
		].
	].
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeMoves [
	"ChessPlayer initialize"
	self initializeKnightMoves.
	self initializeRookMoves.
	self initializeBishopMoves.
	self initializeKingMoves.
]

{ #category : #'pool initialization' }
ChessConstants class >> initializePieceConstants [
	EmptySquare := 0.
	Pawn := 1.
	Knight := 2.
	Bishop := 3.
	Rook := 4.
	Queen := 5.
	King := 6.
]

{ #category : #'pool initialization' }
ChessConstants class >> initializePieceValues [
	PieceValues := Array new: 6.
	PieceValues at: Pawn put: 100.
	PieceValues at: Knight put: 300.
	PieceValues at: Bishop put: 350.
	PieceValues at: Rook put: 500.
	PieceValues at: Queen put: 900.
	PieceValues at: King put: 2000.

]

{ #category : #'pool initialization' }
ChessConstants class >> initializeRookMovers. [
	RookMovers := Set new.
	RookMovers add:Rook.
	RookMovers add:Queen.
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeRookMoves [
	"ChessPlayer initialize"
	| index moveList1 moveList2 moveList3 moveList4 px py |
	RookMoves := Array new: 64 withAll: #().
	0 to: 7 do:[:j|
		0 to: 7 do:[:i|
			index := (j * 8) + i + 1.
			moveList1 := moveList2 := moveList3 := moveList4 := #().
			1 to: 7 do:[:k|
				px := i + k. py := j.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList1 := moveList1 copyWith: (py * 8) + px + 1].
				px := i. py := j + k.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList2 := moveList2 copyWith: (py * 8) + px + 1].
				px := i - k. py := j.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList3 := moveList3 copyWith: (py * 8) + px + 1].
				px := i. py := j - k.
				((px between: 0 and: 7) and:[py between: 0 and: 7]) ifTrue:[
					moveList4 := moveList4 copyWith: (py * 8) + px + 1].
			].
			RookMoves at: index put: {moveList1. moveList2. moveList3. moveList4}.
		].
	].
]

{ #category : #'pool initialization' }
ChessConstants class >> initializeSquareConstants [
	A1:=1. B1:=2. C1:=3. D1:=4. E1:=5. F1:=6. G1:=7. H1:=8.
	A2:=9. B2:=10. C2:=11. D2:=12. E2:=13. F2:=14. G2:=15. H2:=16.
	A3:=17. B3:=18. C3:=19. D3:=20. E3:=21. F3:=22. G3:=23. H3:=24.
	A4:=25. B4:=26. C4:=27. D4:=28. E4:=29. F4:=30. G4:=31. H4:=32.
	A5:=33. B5:=34. C5:=35. D5:=36. E5:=37. F5:=38. G5:=39. H5:=40.
	A6:=41. B6:=42. C6:=43. D6:=44. E6:=45. F6:=46. G6:=47. H6:=48.
	A7:=49. B7:=50. C7:=51. D7:=52. E7:=53. F7:=54. G7:=55. H7:=56.
	A8:=57. B8:=58. C8:=59. D8:=60. E8:=61. F8:=62. G8:=63. H8:=64.
]
