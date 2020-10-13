"
This class represents a player in the game, including its pieces and the current value of the player's position.
"
Class {
	#name : #ChessPlayer,
	#superclass : #Object,
	#instVars : [
		'board',
		'pieces',
		'opponent',
		'castlingRookSquare',
		'enpassantSquare',
		'castlingStatus',
		'materialValue',
		'numPawns',
		'positionalValue'
	],
	#pools : [
		'ChessConstants'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #accessing }
ChessPlayer class >> king [
	^King
]

{ #category : #accessing }
ChessPlayer class >> rook [
	^Rook
]

{ #category : #'adding\/removing' }
ChessPlayer >> addBlackPieces [
	self initialize.
	49 to: 56 do:[:i| self addPiece: Pawn at: i].
	self addPiece: Rook at: 57.
	self addPiece: Knight at: 58.
	self addPiece: Bishop at: 59.
	self addPiece: Queen at: 60.
	self addPiece: King at: 61.
	self addPiece: Bishop at: 62.
	self addPiece: Knight at: 63.
	self addPiece: Rook at: 64.

]

{ #category : #'adding\/removing' }
ChessPlayer >> addPiece: piece at: square [
	pieces at: square put: piece.
	materialValue := materialValue + (PieceValues at: piece).
	positionalValue := positionalValue + ((PieceCenterScores at: piece) at: square).
	piece = Pawn ifTrue:[numPawns := numPawns + 1].
	board updateHash: piece at: square from: self.
	self userAgent ifNotNil:[self userAgent addedPiece: piece at: square white: self isWhitePlayer].
]

{ #category : #'adding\/removing' }
ChessPlayer >> addWhitePieces [
	self addPiece: Rook at: 1.
	self addPiece: Knight at: 2.
	self addPiece: Bishop at: 3.
	self addPiece: Queen at: 4.
	self addPiece: King at: 5.
	self addPiece: Bishop at: 6.
	self addPiece: Knight at: 7.
	self addPiece: Rook at: 8.
	9 to: 16 do:[:i| self addPiece: Pawn at: i].

]

{ #category : #moving }
ChessPlayer >> applyCastleKingSideMove: move [
	self movePiece: move movingPiece from: move sourceSquare to: move destinationSquare.
	self movePiece: Rook from: move sourceSquare+3 to: (castlingRookSquare := move sourceSquare+1).
	pieces at: castlingRookSquare put: King.
	castlingStatus := castlingStatus bitOr: CastlingDone.
]

{ #category : #moving }
ChessPlayer >> applyCastleQueenSideMove: move [
	self movePiece: move movingPiece from: move sourceSquare to: move destinationSquare.
	self movePiece: Rook from: move sourceSquare-4 to: (castlingRookSquare := move sourceSquare-1).
	pieces at: castlingRookSquare put: King.
	castlingStatus := castlingStatus bitOr: CastlingDone.
]

{ #category : #moving }
ChessPlayer >> applyDoublePushMove: move [
	enpassantSquare := (move sourceSquare + move destinationSquare) bitShift: -1.
	"Above means: the field between start and destination"
	^self movePiece: move movingPiece from: move sourceSquare to: move destinationSquare.
]

{ #category : #moving }
ChessPlayer >> applyEnpassantMove: move [
	| capturedSquare |
	capturedSquare := move destinationSquare - (self isWhitePlayer ifTrue:[8] ifFalse:[-8]).
	opponent removePiece: move capturedPiece at: capturedSquare.
	self userAgent ifNotNil:[(self userAgent atSquare: capturedSquare) removeAllMorphs].
	^self movePiece: move movingPiece from: move sourceSquare to: move destinationSquare
]

{ #category : #moving }
ChessPlayer >> applyMove: move [
	"Apply the given move"
	| action |
	"Apply basic move"
	action := #(
			applyNormalMove:
			applyDoublePushMove:
			applyEnpassantMove:
			applyCastleKingSideMove:
			applyCastleQueenSideMove:
			applyResign:
			applyStaleMate:
		) at: (move moveType bitAnd: ChessMove basicMoveMask).
	self perform: action with: move.

	"Promote if necessary"
	self applyPromotion: move.

	"Maintain castling status"
	self updateCastlingStatus: move.

]

{ #category : #moving }
ChessPlayer >> applyNormalMove: move [
	| piece |
	(piece := move capturedPiece) = EmptySquare 
		ifFalse:[opponent removePiece: piece at: move destinationSquare].
	^self movePiece: move movingPiece from: move sourceSquare to: move destinationSquare.
]

{ #category : #moving }
ChessPlayer >> applyPromotion: move [
	| piece |
	piece := move promotion.
	piece = 0 ifFalse:[self replacePiece: move movingPiece with: piece at: move destinationSquare].
]

{ #category : #moving }
ChessPlayer >> applyResign: move [
	"Give up."
	self userAgent ifNotNil:[
		self isWhitePlayer 
			ifTrue:[self userAgent finishedGame: 0]
			ifFalse:[self userAgent finishedGame: 1].
	].
]

{ #category : #moving }
ChessPlayer >> applyStaleMate: move [
	"Itsa draw."
	self userAgent ifNotNil:[self userAgent finishedGame: 0.5].
]

{ #category : #accessing }
ChessPlayer >> board [
	^board
]

{ #category : #accessing }
ChessPlayer >> board: aBoard [
	board := aBoard
]

{ #category : #testing }
ChessPlayer >> canCastleKingSide [
	(castlingStatus bitAnd: CastlingEnableKingSide) = 0 ifFalse: [^false].
	self isWhitePlayer 
		ifTrue: 
			[(pieces sixth) = 0 ifFalse: [^false].
			pieces seventh = 0 ifFalse: [^false].
			(opponent pieceAt: 6) = 0 ifFalse: [^false].
			(opponent pieceAt: 7) = 0 ifFalse: [^false]]
		ifFalse: 
			[(pieces at: 62) = 0 ifFalse: [^false].
			(pieces at: 63) = 0 ifFalse: [^false].
			(opponent pieceAt: 62) = 0 ifFalse: [^false].
			(opponent pieceAt: 63) = 0 ifFalse: [^false]].
	^true
]

{ #category : #testing }
ChessPlayer >> canCastleQueenSide [
	(castlingStatus bitAnd: CastlingEnableQueenSide) = 0 ifFalse: [^false].
	self isWhitePlayer 
		ifTrue: 
			[pieces second = 0 ifFalse: [^false].
			(pieces third) = 0 ifFalse: [^false].
			pieces fourth = 0 ifFalse: [^false].
			(opponent pieceAt: 2) = 0 ifFalse: [^false].
			(opponent pieceAt: 3) = 0 ifFalse: [^false].
			(opponent pieceAt: 4) = 0 ifFalse: [^false]]
		ifFalse: 
			[(pieces at: 58) = 0 ifFalse: [^false].
			(pieces at: 59) = 0 ifFalse: [^false].
			(pieces at: 60) = 0 ifFalse: [^false].
			(opponent pieceAt: 58) = 0 ifFalse: [^false].
			(opponent pieceAt: 59) = 0 ifFalse: [^false].
			(opponent pieceAt: 60) = 0 ifFalse: [^false]].
	^true
]

{ #category : #accessing }
ChessPlayer >> castlingRookSquare [
	^castlingRookSquare
]

{ #category : #accessing }
ChessPlayer >> castlingStatus [
	^castlingStatus
]

{ #category : #copying }
ChessPlayer >> copyPlayer: aPlayer [
	"Copy all the volatile state from aPlayer"
	castlingRookSquare := aPlayer castlingRookSquare.
	enpassantSquare := aPlayer enpassantSquare.
	castlingStatus := aPlayer castlingStatus.
	materialValue := aPlayer materialValue.
	numPawns := aPlayer numPawns.
	positionalValue := aPlayer positionalValue.
	pieces replaceFrom: 1 to: pieces size with: aPlayer pieces startingAt: 1.
]

{ #category : #accessing }
ChessPlayer >> enpassantSquare [
	^enpassantSquare
]

{ #category : #evaluation }
ChessPlayer >> evaluate [
	^self evaluateMaterial + self evaluatePosition
]

{ #category : #evaluation }
ChessPlayer >> evaluateMaterial [
	"Compute the board's material balance, from the point of view of the side
	player.  This is an exact clone of the eval function in CHESS 4.5"
	| total diff value pawns |
	self materialValue = opponent materialValue ifTrue:[^0]. "both sides are equal"
	total := self materialValue + opponent materialValue.
	diff := self materialValue - opponent materialValue.

	pawns := numPawns.
	pawns < 0 ifTrue: ["happens - a bug somewhere" pawns := 0].

	value := (2400 min: diff) + 
		((diff * (12000 - total) * pawns) // (6400 * (pawns + 1))).
	^value
]

{ #category : #evaluation }
ChessPlayer >> evaluatePosition [
	"Compute the board's positional balance, from the point of view of the side player."
	^positionalValue - opponent positionalValue
]

{ #category : #'moves-general' }
ChessPlayer >> findPossibleMoves [
	"Find all possible moves. This method does not check if the move is legal, e.g., if the king of the player is under attack after the move. If the opponent is check mate (e.g., the king could be taken in the next move) the method returns nil. If the game is stale mate (e.g., the receiver has no move left) this method returns an empty array."
	| moveList moves |
	moveList := board generator findPossibleMovesFor: self.
	moveList ifNil:[^nil].
	moves := moveList contents collect:[:move| move copy].
	board generator recycleMoveList: moveList.
	^moves
]

{ #category : #'moves-general' }
ChessPlayer >> findPossibleMovesAt: square [
	"Find all possible moves at the given square. This method does not check if the move is legal, e.g., if the king of the player is under attack after the move. If the opponent is check mate (e.g., the king could be taken in the next move) the method returns nil. If the game is stale mate (e.g., the receiver has no move left) this method returns an empty array."
	| moveList moves |
	moveList := board generator findPossibleMovesFor: self at: square.
	moveList ifNil:[^nil].
	moves := moveList contents collect:[:move| move copy].
	board generator recycleMoveList: moveList.
	^moves
]

{ #category : #'moves-general' }
ChessPlayer >> findQuiescenceMoves [
	"Find all possible moves. This method does not check if the move is legal, e.g., if the king of the player is under attack after the move. If the opponent is check mate (e.g., the king could be taken in the next move) the method returns nil. If the game is stale mate (e.g., the receiver has no move left) this method returns an empty array."
	| moveList moves |
	moveList := board generator findQuiescenceMovesFor: self.
	moveList ifNil:[^nil].
	moves := moveList contents collect:[:move| move copy].
	board generator recycleMoveList: moveList.
	^moves
]

{ #category : #'moves-general' }
ChessPlayer >> findValidMoves [
	"Find all the valid moves"
	| moveList |
	moveList := self findPossibleMoves ifNil:[^nil].
	^moveList select:[:move| self isValidMove: move].
]

{ #category : #'moves-general' }
ChessPlayer >> findValidMovesAt: square [
	"Find all the valid moves"
	| moveList |
	moveList := (self findPossibleMovesAt: square) ifNil:[^nil].
	^moveList select:[:move| self isValidMove: move].
]

{ #category : #configuration }
ChessPlayer >> initialLeftRookSquare [

	^ self isWhitePlayer ifTrue: [A1] ifFalse: [A8]
]

{ #category : #configuration }
ChessPlayer >> initialRightRookSquare [

	^ self isWhitePlayer ifTrue: [H1] ifFalse: [H8]
]

{ #category : #initialize }
ChessPlayer >> initialize [
	"ChessPlayer initialize"
	pieces := ByteArray new: 64.
	materialValue := 0.
	positionalValue := 0.
	numPawns := 0.
	enpassantSquare := 0.
	castlingRookSquare := 0.
	castlingStatus := 0.
]

{ #category : #testing }
ChessPlayer >> isValidMove: move [
	"Is the given move actually valid for the receiver?
	If the receiver's king can't be taken after applying the move, it is."
	| copy |
	copy := board copy.
	copy nextMove: move.
	^copy activePlayer findPossibleMoves notNil
]

{ #category : #testing }
ChessPlayer >> isValidMoveFrom: sourceSquare to: destSquare [
	| move |
	move := (self findValidMovesAt: sourceSquare)
			detect:[:any| (any triggerSquareIn: board) = destSquare] ifNone:[nil].
	^move notNil
]

{ #category : #testing }
ChessPlayer >> isWhitePlayer [
	^board whitePlayer == self
]

{ #category : #accessing }
ChessPlayer >> materialValue [
	^materialValue
]

{ #category : #'adding\/removing' }
ChessPlayer >> movePiece: piece from: sourceSquare to: destSquare [
	| score |
	score := PieceCenterScores at: piece.
	positionalValue := positionalValue - (score at: sourceSquare).
	positionalValue := positionalValue + (score at: destSquare).
	pieces at: sourceSquare put: 0.
	pieces at: destSquare put: piece.
	board updateHash: piece at: sourceSquare from: self.
	board updateHash: piece at: destSquare from: self.
	self userAgent ifNotNil:[self userAgent movedPiece: piece from: sourceSquare to: destSquare].
]

{ #category : #accessing }
ChessPlayer >> numPawns [
	^numPawns
]

{ #category : #accessing }
ChessPlayer >> opponent [
	^opponent
]

{ #category : #accessing }
ChessPlayer >> opponent: aPlayer [
	opponent := aPlayer
]

{ #category : #accessing }
ChessPlayer >> pieceAt: square [
	"Return the piece at the given square"
	^pieces at: square
]

{ #category : #accessing }
ChessPlayer >> pieces [
	^pieces
]

{ #category : #evaluation }
ChessPlayer >> positionalValue [
	"Evaluate our current position"
	^positionalValue
]

{ #category : #copying }
ChessPlayer >> postCopy [

	pieces := pieces copy
]

{ #category : #initialize }
ChessPlayer >> prepareNextMove [
	"Clear enpassant square and reset any pending extra kings"
	enpassantSquare := 0.
	castlingRookSquare = 0 ifFalse:[pieces at: castlingRookSquare put: Rook].
	castlingRookSquare := 0.

]

{ #category : #'adding\/removing' }
ChessPlayer >> removePiece: piece at: square [

	(pieces at: square) = piece ifFalse: ["fix"
		"Happens at time - some moves have a capturedPiece absent from the board"
		^self].

	pieces at: square put: 0.
	materialValue := materialValue - (PieceValues at: piece).
	positionalValue := positionalValue - ((PieceCenterScores at: piece) at: square).
	piece = Pawn ifTrue:[numPawns := numPawns - 1].
	board updateHash: piece at: square from: self.
	self userAgent ifNotNil:[self userAgent removedPiece: piece at: square].

]

{ #category : #'adding\/removing' }
ChessPlayer >> replacePiece: oldPiece with: newPiece at: square [
	pieces at: square put: newPiece.
	materialValue := materialValue - (PieceValues at: oldPiece) + (PieceValues at: newPiece).
	positionalValue := positionalValue - ((PieceCenterScores at: oldPiece) at: square).
	positionalValue := positionalValue + ((PieceCenterScores at: newPiece) at: square).

	oldPiece = Pawn ifTrue:[numPawns := numPawns - 1].
	newPiece = Pawn ifTrue:[numPawns := numPawns + 1].
	board updateHash: oldPiece at: square from: self.
	board updateHash: newPiece at: square from: self.
	self userAgent ifNotNil:[self userAgent replacedPiece: oldPiece with: newPiece at: square white: self isWhitePlayer].
]

{ #category : #undo }
ChessPlayer >> undoCastleKingSideMove: move [
	self prepareNextMove. "in other words, remove extra kings"
	self movePiece: move movingPiece from: move destinationSquare to: move sourceSquare.
	self movePiece: Rook from: move sourceSquare+1 to: move sourceSquare+3.
]

{ #category : #undo }
ChessPlayer >> undoCastleQueenSideMove: move [
	self prepareNextMove. "in other words, remove extra kings"
	self movePiece: move movingPiece from: move destinationSquare to: move sourceSquare.
	self movePiece: Rook from: move sourceSquare-1 to: move sourceSquare-4.

]

{ #category : #undo }
ChessPlayer >> undoDoublePushMove: move [
	enpassantSquare := 0.
	self movePiece: move movingPiece from: move destinationSquare to: move sourceSquare.
]

{ #category : #undo }
ChessPlayer >> undoEnpassantMove: move [
	self movePiece: move movingPiece from: move destinationSquare to: move sourceSquare.
	opponent addPiece: move capturedPiece at: move destinationSquare - 
		(self isWhitePlayer ifTrue:[8] ifFalse:[-8]).

]

{ #category : #undo }
ChessPlayer >> undoMove: move [
	"Undo the given move"
	| action |
	self undoPromotion: move.
	"Apply basic move"
	action := #(
			undoNormalMove:
			undoDoublePushMove:
			undoEnpassantMove:
			undoCastleKingSideMove:
			undoCastleQueenSideMove:
			undoResign:
			undoStaleMate:
		) at: (move moveType bitAnd: ChessMove basicMoveMask).
	self perform: action with: move.
]

{ #category : #undo }
ChessPlayer >> undoNormalMove: move [
	| piece |
	self movePiece: move movingPiece from: move destinationSquare to: move sourceSquare.
	(piece := move capturedPiece) = EmptySquare 
		ifFalse:[opponent addPiece: piece at: move destinationSquare].

]

{ #category : #undo }
ChessPlayer >> undoPromotion: move [
	| piece |
	piece := move promotion.
	piece = 0 ifFalse:[self replacePiece: piece with: move movingPiece at: move destinationSquare].
]

{ #category : #undo }
ChessPlayer >> undoResign: move [
]

{ #category : #undo }
ChessPlayer >> undoStaleMate: move [
]

{ #category : #moving }
ChessPlayer >> updateCastlingStatus: move [

	"Cannot castle when king has moved"
	(move movingPiece = King) 
		ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableAll].

	"See if a rook has moved"
	(move movingPiece = Rook) ifFalse:[^self].

	self isWhitePlayer ifTrue:[
		(move sourceSquare = 1) 
			ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableQueenSide].
		(move sourceSquare = 8) 
			ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableKingSide].
	] ifFalse:[
		(move sourceSquare = 57) 
			ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableQueenSide].
		(move sourceSquare = 64) 
			ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableKingSide].
	].
]

{ #category : #accessing }
ChessPlayer >> userAgent [
	^board userAgent
]
