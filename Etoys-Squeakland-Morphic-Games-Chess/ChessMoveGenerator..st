"
This class generates moves for any given board. It's speed is critical - for each new position all moves need to be generated in that position. It may be worthwhile to make give this class a little plugin support at some time.
"
Class {
	#name : #ChessMoveGenerator,
	#superclass : #Object,
	#instVars : [
		'myPlayer',
		'myPieces',
		'itsPieces',
		'castlingStatus',
		'enpassantSquare',
		'forceCaptures',
		'moveList',
		'firstMoveIndex',
		'lastMoveIndex',
		'streamList',
		'streamListIndex',
		'attackSquares',
		'kingAttack'
	],
	#classVars : [
		'EmptyPieceMap'
	],
	#pools : [
		'ChessConstants'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #public }
ChessMoveGenerator >> attackSquares [
	^attackSquares
]

{ #category : #'moves-pawns' }
ChessMoveGenerator >> blackPawnCaptureAt: square direction: dir [
	| destSquare move piece |
	destSquare := square-8-dir.
	piece := itsPieces at: destSquare.
	piece = 0 ifFalse:[
		(move := moveList at: (lastMoveIndex := lastMoveIndex + 1))
			move: Pawn from: square to: destSquare capture: piece.
		piece = King ifTrue:[kingAttack := move].
		destSquare <= 8 "a promotion"
			ifTrue:[self promotePawn: move].
	].
	"attempt an en-passant capture"
	enpassantSquare = destSquare ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			captureEnPassant: Pawn from: square to: destSquare.
	].
]

{ #category : #'moves-pawns' }
ChessMoveGenerator >> blackPawnPushAt: square [
	| destSquare move |
	"Try to push this pawn"
	destSquare := square-8.
	(myPieces at: destSquare) = 0 ifFalse:[^self].
	(itsPieces at: destSquare) = 0 ifFalse:[^self].
	(move := moveList at: (lastMoveIndex := lastMoveIndex + 1))
		move: Pawn from: square to: destSquare.
	destSquare <= 8 "a promotion (can't be double-push so get out)"
		ifTrue:[^self promotePawn: move].

	"Try to double-push if possible"
	square > 48 ifFalse:[^self].
	destSquare := square-16.
	(myPieces at: destSquare) = 0 ifFalse:[^self].
	(itsPieces at: destSquare) = 0 ifFalse:[^self].
	(moveList at: (lastMoveIndex := lastMoveIndex + 1))
		doublePush: Pawn from: square to: destSquare.
]

{ #category : #support }
ChessMoveGenerator >> canCastleBlackKingSide [
	(castlingStatus bitAnd: CastlingEnableKingSide) = 0 ifFalse:[^false].
	"Quickly check if all the squares are zero"
	((myPieces at: G8) + (myPieces at: F8) + (itsPieces at: G8) + (itsPieces at: F8) = 0) ifFalse:[^false].
	"Check for castling squares under attack..  See canCastleBlackQueenSide for details"
	(self checkAttack:{G7. G6. G5. G4. G3. G2. G1} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{F7. F6. F5. F4. F3. F2. F1} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{E7. E6. E5. E4. E3. E2. E1.} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{D8. C8. B8. A8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{F7. E6. D5. C4. B3. A2} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{E7. D6. C5. B4. A3} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{D7. C6. B5. A4} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{F7. G6. H5} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{G7. H6} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{H7} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkUnprotectedAttack:{H7. G7. E7. D7. C7. H6. G6. F6. E6. D6} fromPiece:Knight) ifTrue:[^false].
	(self checkUnprotectedAttack:{H7. G7. F7. E7. D7} fromPiece:Pawn) ifTrue:[^false].
	(self checkUnprotectedAttack:{G7} fromPiece:King) ifTrue:[^false].

	^true.
	
	
	
	
	
]

{ #category : #support }
ChessMoveGenerator >> canCastleBlackQueenSide [
	(castlingStatus bitAnd: CastlingEnableQueenSide) = 0 ifFalse:[^false].
	"Quickly check if all the squares are zero"
	((myPieces at: B8) +  (myPieces at: C8) +  (myPieces at: D8) +
		(itsPieces at: B8) + (itsPieces at: C8) + (itsPieces at: D8) 
			= 0) ifFalse:[^false].
	"Check to see if any of the squares involved in castling are under attack.  First
	check for vertical (rook-like) attacks"
	(self checkAttack:{B7. B6. B5. B4. B3. B2. B1} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{C7. C6. C5. C4. C3. C2. C1} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{D7. D6. D5. D4. D3. D2. D1} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{E7. E6. E5. E4. E3. E2. E1} fromPieces:RookMovers) ifTrue:[^false].
	"Check for a rook attack from the baseline"
	(self checkAttack:{F8. G8. H8} fromPieces:RookMovers) ifTrue:[^false].
	"Check for bishop attacks from the diagonals"
	(self checkAttack:{C7. D6. E5. F4. G3. H2} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{D7. E6. F5. G4. H3} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{E7. F6. G5. H4} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{F7. G6. H5} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{A7} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{B7. A6} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{C7. B6. A5} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{D7. C6. B5. A4} fromPieces:BishopMovers) ifTrue:[^false].
	"Check for a knight attack"
	(self checkUnprotectedAttack:{A7. B7. C7. D7. E7. F7. G7. A6. B6. C6. D6. E6. F6} fromPiece:Knight) ifTrue:[^false].
	"check for a pawn attack"
	(self checkUnprotectedAttack:{A7. B7. C7. D7. E7. F7} fromPiece:Pawn) ifTrue:[^false].
	"check for a king attack"
	(self checkUnprotectedAttack:{B7. C7. } fromPiece:King) ifTrue:[^false].
	^true.

]

{ #category : #support }
ChessMoveGenerator >> canCastleWhiteKingSide [
	(castlingStatus bitAnd: CastlingEnableKingSide) = 0 ifFalse: [^false].
	"Quickly check if all the squares are zero"
	((myPieces at:G1) + (myPieces at:F1) + (itsPieces at:G1) + (itsPieces at:F1) = 0) ifFalse:[^false].
	"Check for castling squares under attack..  See canCastleBlackQueenSide for details"
	(self checkAttack:{G2. G3. G4. G5. G6. G7. G8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{F2. F3. F4. F5. F6. F7. F8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{E2. E3. E4. E5. E6. E7. E8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{A1. A2. A3. A4} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{F2. E3. D4. C5. B6. A7} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{E2. D3. C4. B5. A6} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{D2. C3. B4. A5} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{F2. G3. H4} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{G2. H3} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{H2} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkUnprotectedAttack:{H2. G2. E2. D2. C2. H3. G3. F3. E3. D3} fromPiece:Knight) ifTrue:[^false].
	(self checkUnprotectedAttack:{H2. G2. F2. E2. D2} fromPiece:Pawn) ifTrue:[^false].
	(self checkUnprotectedAttack:{G2} fromPiece:King) ifTrue:[^false].
	^true.
]

{ #category : #support }
ChessMoveGenerator >> canCastleWhiteQueenSide [
	(castlingStatus bitAnd: CastlingEnableQueenSide) = 0 ifFalse: [^false].
	"Quickly check if all the squares are zero"
	((myPieces at:B1) + (myPieces at:C1) + (myPieces at:D1) +
	 (itsPieces at:B1) + (itsPieces at:C1) + (itsPieces at:D1) = 0) ifFalse:[^false].
	"Check for castling squares under attack..  See canCastleBlackQueenSide for details"
	(self checkAttack:{B2. B3. B4. B5. B6. B7. B8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{C2. C3. C4. C5. C6. C7. C8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{D2. D3. D4. D5. D6. D7. D8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{E2. E3. E4. E5. E6. E7. E8} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{F1. G1. H1} fromPieces:RookMovers) ifTrue:[^false].
	(self checkAttack:{C2. D3. E4. F5. G6. H7} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{D2. E3. F4. G5. H6} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{E2. F3. G4. H5} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{F2. G3. H4} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{A2} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{B2. A3} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{C2. B3. A4} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkAttack:{D2. C3. B4. A5} fromPieces:BishopMovers) ifTrue:[^false].
	(self checkUnprotectedAttack:{A2. B2. C2. D2. E2. F2. G2. A3. B3. C3. D3. E3. F3} fromPiece:Knight) ifTrue:[^false].
	(self checkUnprotectedAttack:{A2. B2. C2. D2. E2. F2} fromPiece:Pawn) ifTrue:[^false].
	(self checkUnprotectedAttack:{B2. C2} fromPiece:King) ifTrue:[^false].
	^true.
]

{ #category : #support }
ChessMoveGenerator >> checkAttack:squares fromPieces:pieces [
	"check for an unprotected attack along squares by one of pieces.  Squares is a list of 
	squares such that any piece in pieces can attack unless blocked by another piece.
	E.g., a Bishop of Queen on the file  B7 C6 D5 E4 F3 G2 H1 can attack A8 unless blocked by
	another piece.  To find out if A8 is under attack along B7 C6 D5 E4 F3 G2 H1, use
	checkAttack:{B7. C6.D5. E4. F3. G2. H1} fromPieces:BishopMovers.  Note the order is important;
	squares must be listed in increasing distance from the square of interest"

	squares do:[:sqr|
		"invariant: no piece has been seen on this file at all"
		"one of my pieces blocks any attack"
		(myPieces at:sqr) = 0 ifFalse:[^false].
		"One of its pieces blocks an attack unless it is the kind of piece that can move along this
		file: a Bishop or Queen for a diagonal and a Rook or Queen for a Horizontal or
		Verrtical File"
		(itsPieces at:sqr) = 0 ifFalse:[
			^pieces includes:(itsPieces at:sqr).
		].
		
	].
	"no pieces along file, no attack"
	^false.
	
	

]

{ #category : #support }
ChessMoveGenerator >> checkUnprotectedAttack:squares fromPiece:piece [
	"check to see if my opponent has a piece of type piece on any of squares.  In general, this
	is used because that piece could launch an attack on me from those squares".
	squares do:[:sqr|
		(itsPieces at:sqr) = piece ifTrue:[^true].
	].
	^false.
	
	

]

{ #category : #public }
ChessMoveGenerator >> findAllPossibleMovesFor: player [ 
	"Find all possible moves. This method does not check if the move is legal, e.g., if the king of the player is under attack after the move. If the opponent is check mate (e.g., the king could be taken in the next move) the method returns nil. If the game is stale mate (e.g., the receiver has no move left) this method returns an empty array."

	| piece actions square |
	myPlayer := player.
	myPieces := player pieces.
	itsPieces := player opponent pieces.
	castlingStatus := player castlingStatus.
	enpassantSquare := player opponent enpassantSquare.
	firstMoveIndex = lastMoveIndex ifFalse: [self error: 'I am confused'].
	kingAttack := nil.
	myPlayer isWhitePlayer ifTrue:[
		actions := #(moveWhitePawnAt: moveKnightAt: moveBishopAt: 
					moveRookAt: moveQueenAt: moveWhiteKingAt:)
	] ifFalse:[ 
		actions := #(moveBlackPawnAt: moveKnightAt: moveBishopAt: 
					moveRookAt: moveQueenAt: moveBlackKingAt:)
	].
	square := 0.
	[square < 64] whileTrue:[
		"Note: The following is only to skip empty fields efficiently.
		It could well be replaced by going through each field and test it
		for zero but this is *much* faster."
		square := self skipEmptySquaresIn: myPieces
							using: EmptyPieceMap
							startingAt: square + 1.
		square = 0 ifTrue: [^self moveList].
		piece := myPieces at: square.
		self perform: (actions at: piece) with: square.
		kingAttack ifNotNil: [^self moveList].
	].
	^self moveList
]

{ #category : #public }
ChessMoveGenerator >> findAttackSquaresFor: player [ 
	"Mark all the fields of a board that are attacked by the given player.
	The pieces attacking a field are encoded as (1 << Piece) so that we can
	record all types of pieces that attack the square."

	| move square piece attack list |
	forceCaptures := false.
	attackSquares ifNil: [attackSquares := ByteArray new: 64].
	attackSquares atAllPut: 0.
	list := self findAllPossibleMovesFor: player.
	
	[move := list next.
	move isNil] whileFalse: 
				[square := move destinationSquare.
				piece := move movingPiece.
				attack := attackSquares at: square.
				attack := attack bitOr: (1 bitShift: piece).
				attackSquares at: square put: attack].
	self recycleMoveList: list.
	^attackSquares
]

{ #category : #public }
ChessMoveGenerator >> findPossibleMovesFor: player [
	"Find all possible moves. This method does not check if the move is legal, e.g., if the king of the player is under attack after the move. If the opponent is check mate (e.g., the king could be taken in the next move) the method returns nil. If the game is stale mate (e.g., the receiver has no move left) this method returns an empty array."
	forceCaptures := false.
	^self findAllPossibleMovesFor: player.
]

{ #category : #public }
ChessMoveGenerator >> findPossibleMovesFor: player at: square [
	"Find all possible moves at the given square. This method does not check if the move is legal, e.g., if the king of the player is under attack after the move. If the opponent is check mate (e.g., the king could be taken in the next move) the method returns nil. If the game is stale mate (e.g., the receiver has no move left) this method returns an empty array."
	| piece action |
	forceCaptures := false.
	myPlayer := player.
	myPieces := player pieces.
	itsPieces := player opponent pieces.
	castlingStatus := player castlingStatus.
	enpassantSquare := player opponent enpassantSquare.
	firstMoveIndex = lastMoveIndex ifFalse:[self error:'I am confused'].
	kingAttack := nil.
	piece := myPieces at: square.
	piece = 0 ifFalse:[
		action := #(movePawnAt:
					moveKnightAt:
					moveBishopAt:
					moveRookAt:
					moveQueenAt:
					moveKingAt:) at: piece.
		self perform: action with: square.
	].
	^self moveList
]

{ #category : #public }
ChessMoveGenerator >> findQuiescenceMovesFor: player [
	"Find all the quiescence moves (that is moves capturing pieces)"
	forceCaptures := true.
	^self findAllPossibleMovesFor: player.
]

{ #category : #initialize }
ChessMoveGenerator >> initialize [
	EmptyPieceMap ifNil:[
		EmptyPieceMap := ByteArray new: 256.
		2 to: 7 do:[:i| EmptyPieceMap at: i put: 1]].

	streamList := Array new: 100. "e.g., 100 plies"
	1 to: streamList size do:[:i| streamList at: i put: (ChessMoveList on: #())].
	moveList := Array new: streamList size * 30. "avg. 30 moves per ply"
	1 to: moveList size do:[:i| moveList at: i put: (ChessMove new init)].
	firstMoveIndex := lastMoveIndex := streamListIndex := 0.
]

{ #category : #public }
ChessMoveGenerator >> kingAttack [
	^kingAttack
]

{ #category : #'moves-general' }
ChessMoveGenerator >> moveBishopAt: square [
	| moves |
	moves := BishopMoves at: square.
	1 to: moves size do:[:i|
		self movePiece: Bishop along: (moves at: i) at: square.
	].

]

{ #category : #'moves-general' }
ChessMoveGenerator >> moveBlackKingAt: square [
	| capture |
	(KingMoves at: square) do:[:destSquare|
		(myPieces at: destSquare) = 0 ifTrue:[
			capture := itsPieces at: destSquare.
			(forceCaptures and:[capture = 0]) ifFalse:[
				(moveList at: (lastMoveIndex := lastMoveIndex + 1))
					move: King from: square to: destSquare capture: capture.
				capture = King ifTrue:[kingAttack := moveList at: lastMoveIndex].
			].
		].
	].
	forceCaptures ifTrue:[^self].
	"now consider castling"
	self canCastleBlackKingSide ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			moveCastlingKingSide: King from: square to: square+2.
	].
	self canCastleBlackQueenSide ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			moveCastlingQueenSide: King from: square to: square-2.
	].
]

{ #category : #'moves-pawns' }
ChessMoveGenerator >> moveBlackPawnAt: square [
	"Pawns only move in one direction so check for which direction to use"
	forceCaptures ifFalse:[self blackPawnPushAt: square].
	(square bitAnd: 7) = 1
		ifFalse:[self blackPawnCaptureAt: square direction: 1].
	(square bitAnd: 7) = 0 
		ifFalse:[self blackPawnCaptureAt: square direction: -1].

]

{ #category : #'moves-general' }
ChessMoveGenerator >> moveKingAt: square [
	myPlayer isWhitePlayer
		ifTrue:[^self moveWhiteKingAt: square]
		ifFalse:[^self moveBlackKingAt: square]
]

{ #category : #'moves-general' }
ChessMoveGenerator >> moveKnightAt: square [
	| capture moves destSquare |
	moves := KnightMoves at: square.
	1 to: moves size do:[:i|
		destSquare := moves at: i.
		(myPieces at: destSquare) = 0 ifTrue:[
			capture := itsPieces at: destSquare.
			(forceCaptures and:[capture = 0]) ifFalse:[
				(moveList at: (lastMoveIndex := lastMoveIndex + 1))
					move: Knight from: square to: destSquare capture: capture.
				capture = King ifTrue:[kingAttack := (moveList at: lastMoveIndex)].
			].
		].
	].
]

{ #category : #public }
ChessMoveGenerator >> moveList [
	| list |
	kingAttack ifNotNil:[
		lastMoveIndex := firstMoveIndex.
		^nil].
	list := streamList at: (streamListIndex := streamListIndex + 1).
	list on: moveList from: firstMoveIndex+1 to: lastMoveIndex.
	firstMoveIndex := lastMoveIndex.
	^list
]

{ #category : #'moves-general' }
ChessMoveGenerator >> movePawnAt: square [
	"Pawns only move in one direction so check for which direction to use"
	myPlayer isWhitePlayer
		ifTrue:[^self moveWhitePawnAt: square]
		ifFalse:[^self moveBlackPawnAt: square]
]

{ #category : #'moves-general' }
ChessMoveGenerator >> movePiece: piece along: rayList at: square [
	| destSquare capture |
	1 to: rayList size do:[:i|
		destSquare := rayList at: i.
		(myPieces at: destSquare) = 0 ifFalse:[^self].
		capture := itsPieces at: destSquare.
		(forceCaptures and:[capture = 0]) ifFalse:[
			(moveList at: (lastMoveIndex := lastMoveIndex + 1))
				move: piece from: square to: destSquare capture: capture.
			capture = King ifTrue:[kingAttack := moveList at: lastMoveIndex].
		].
		capture = 0 ifFalse:[^self].
	].
]

{ #category : #'moves-general' }
ChessMoveGenerator >> moveQueenAt: square [
	| moves |
	moves := RookMoves at: square.
	1 to: moves size do:[:i|
		self movePiece: Queen along: (moves at: i) at: square.
	].
	moves := BishopMoves at: square.
	1 to: moves size do:[:i|
		self movePiece: Queen along: (moves at: i) at: square.
	].
]

{ #category : #'moves-general' }
ChessMoveGenerator >> moveRookAt: square [
	| moves |
	moves := RookMoves at: square.
	1 to: moves size do:[:i|
		self movePiece: Rook along: (moves at: i) at: square.
	].

]

{ #category : #'moves-general' }
ChessMoveGenerator >> moveWhiteKingAt: square [
	| capture |
	(KingMoves at: square) do:[:destSquare|
		(myPieces at: destSquare) = 0 ifTrue:[
			capture := itsPieces at: destSquare.
			(forceCaptures and:[capture = 0]) ifFalse:[
				(moveList at: (lastMoveIndex := lastMoveIndex + 1))
					move: King from: square to: destSquare capture: capture.
				capture = King ifTrue:[kingAttack := moveList at: lastMoveIndex].
			].
		].
	].
	forceCaptures ifTrue:[^self].
	"now consider castling"
	self canCastleWhiteKingSide ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			moveCastlingKingSide: King from: square to: square+2.
	].
	self canCastleWhiteQueenSide ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			moveCastlingQueenSide: King from: square to: square-2.
	].
]

{ #category : #'moves-pawns' }
ChessMoveGenerator >> moveWhitePawnAt: square [
	"Pawns only move in one direction so check for which direction to use"
	forceCaptures ifFalse:[self whitePawnPushAt: square].
	(square bitAnd: 7) = 0 
		ifFalse:[self whitePawnCaptureAt: square direction: 1].
	(square bitAnd: 7) = 1 
		ifFalse:[self whitePawnCaptureAt: square direction: -1].

]

{ #category : #public }
ChessMoveGenerator >> profileGenerationFor: player [
	| list |
	Smalltalk garbageCollect.
	MessageTally spyOn:[
		1 to: 100000 do:[:i|
			list := self findPossibleMovesFor: player.
			self recycleMoveList: list].
	].

]

{ #category : #'moves-pawns' }
ChessMoveGenerator >> promotePawn: move [
	"Duplicate the given move and embed all promotion types"
	(moveList at: (lastMoveIndex := lastMoveIndex + 1)) promote: move to: Knight.
	(moveList at: (lastMoveIndex := lastMoveIndex + 1)) promote: move to: Bishop.
	(moveList at: (lastMoveIndex := lastMoveIndex + 1)) promote: move to: Rook.
	move promote: move to: Queen.
]

{ #category : #public }
ChessMoveGenerator >> recycleMoveList: aChessMoveList [
	(streamList at: streamListIndex) == aChessMoveList ifFalse:[^self error:'I am confused'].
	streamListIndex := streamListIndex - 1.
	firstMoveIndex := lastMoveIndex := aChessMoveList startIndex - 1.

]

{ #category : #private }
ChessMoveGenerator >> skipEmptySquaresIn: pieces using: aMap startingAt: startIndex [
	"Find the first empty (zero) square in pieces. The method is layed out so we can (re)use the a particularly effective String primitive (which requires the map argument) but the failure code will do the more natural search for zero instead of the actual primitive equivalent."
	<primitive: 'primitiveFindFirstInString' module: 'MiscPrimitivePlugin'>
	startIndex to: pieces size do:[:index|
		(pieces at: index) = 0 ifFalse:[^index].
	].
	^0
]

{ #category : #'moves-pawns' }
ChessMoveGenerator >> whitePawnCaptureAt: square direction: dir [
	| destSquare move piece |
	destSquare := square+8+dir.
	piece := itsPieces at: destSquare.
	piece = 0 ifFalse:[
		(move := moveList at: (lastMoveIndex := lastMoveIndex + 1))
			move: Pawn from: square to: destSquare capture: piece.
		piece = King ifTrue:[kingAttack := move].
		destSquare > 56 "a promotion"
			ifTrue:[self promotePawn: move].
	].
	"attempt an en-passant capture"
	enpassantSquare = destSquare ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			captureEnPassant: Pawn from: square to: destSquare.
	].
]

{ #category : #'moves-pawns' }
ChessMoveGenerator >> whitePawnPushAt: square [
	"Pawns only move in one direction so check for which direction to use"
	| destSquare move |
	"Try to push this pawn"
	destSquare := square+8.

	(myPieces at: destSquare) = 0 ifFalse:[^self].
	(itsPieces at: destSquare) = 0 ifFalse:[^self].
	(move := moveList at: (lastMoveIndex := lastMoveIndex + 1))
		move: Pawn from: square to: destSquare.
	destSquare > 56 "a promotion (can't be double-push so get out)"
		ifTrue:[^self promotePawn: move].

	"Try to double-push if possible"
	square <= 16 ifFalse:[^self].
	destSquare := square+16.
	(myPieces at: destSquare) = 0 ifFalse:[^self].
	(itsPieces at: destSquare) = 0 ifFalse:[^self].
	(moveList at: (lastMoveIndex := lastMoveIndex + 1))
		doublePush: Pawn from: square to: destSquare.
]
