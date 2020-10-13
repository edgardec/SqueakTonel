"
Chess960MoveGenerator implements the specific castling checks and moves for Chess960
"
Class {
	#name : #Chess960MoveGenerator,
	#superclass : #ChessMoveGenerator,
	#category : #'Etoys-Squeakland-Morphic-Games-Chess960'
}

{ #category : #support }
Chess960MoveGenerator >> canCastleBlackKingSide [

	(castlingStatus bitAnd: CastlingEnableKingSide) = 0 ifFalse:[^false].

	(myPlayer rightCastlingField inject: 0 into: [:sum :s| 
			sum + (myPieces at: s) + (itsPieces at: s)]) = (King + Rook)
		ifFalse:[^false].

	myPlayer rightCastlingWalk in: [:w |
		(self checkRookMoversAttacksAlong: w) ifTrue: [^false].
		(self checkBishopMoversAttacksAlong: w) ifTrue: [^ false].
		(self checkKnightAttacksAlong: w) ifTrue: [^ false].
		(self checkPawnsAttacksAlong: w) ifTrue: [^ false].
		(self checkKingAttacksAlong: w) ifTrue: [^ false]].

	(self checkAttack: (myPlayer initialKingSquare - 1 to: A8 by: -1) fromPieces: RookMovers)
		ifTrue: [^false].
	(self checkAttack: {H8} fromPieces: RookMovers) ifTrue: [^false].

	^true.
	
	
	
	
	
]

{ #category : #support }
Chess960MoveGenerator >> canCastleBlackQueenSide [

	(castlingStatus bitAnd: CastlingEnableQueenSide) = 0 ifFalse:[^false].

	(myPlayer leftCastlingField inject: 0 into: [:sum :s| 
			sum + (myPieces at: s) + (itsPieces at: s)]) = (King + Rook)
		ifFalse:[^false].

	myPlayer leftCastlingWalk in: [:w |
		(self checkRookMoversAttacksAlong: w) ifTrue: [^false].
		(self checkBishopMoversAttacksAlong: w) ifTrue: [^ false].
		(self checkKnightAttacksAlong: w) ifTrue: [^ false].
		(self checkPawnsAttacksAlong: w) ifTrue: [^ false].
		(self checkKingAttacksAlong: w) ifTrue: [^ false]].

	(self checkAttack: (myPlayer initialKingSquare +1 to: H8) fromPieces: RookMovers)
		ifTrue: [^false].
	(self checkAttack: {B8 . A8} fromPieces: RookMovers) ifTrue: [^false].


	^true.
	
	
	
	
	
]

{ #category : #support }
Chess960MoveGenerator >> canCastleWhiteKingSide [

	(castlingStatus bitAnd: CastlingEnableKingSide) = 0 ifFalse:[^false].

	(myPlayer rightCastlingField inject: 0 into: [:sum :s| 
			sum + (myPieces at: s) + (itsPieces at: s)]) = (King + Rook)
		ifFalse:[^false].

	myPlayer rightCastlingWalk in: [:w |
		(self checkRookMoversAttacksAlong: w) ifTrue: [^false].
		(self checkBishopMoversAttacksAlong: w) ifTrue: [^ false].
		(self checkKnightAttacksAlong: w) ifTrue: [^ false].
		(self checkPawnsAttacksAlong: w) ifTrue: [^ false].
		(self checkKingAttacksAlong: w) ifTrue: [^ false]].

	(self checkAttack: (myPlayer initialKingSquare - 1 to: A1 by: -1) fromPieces: RookMovers)
		ifTrue: [^false].
	(self checkAttack: {H1} fromPieces: RookMovers) ifTrue: [^false].

	^true.
	
	
	
	
	
]

{ #category : #support }
Chess960MoveGenerator >> canCastleWhiteQueenSide [

	(castlingStatus bitAnd: CastlingEnableQueenSide) = 0 ifFalse:[^false].

	(myPlayer leftCastlingField inject: 0 into: [:sum :s| 
			sum + (myPieces at: s) + (itsPieces at: s)]) = (King + Rook)
		ifFalse:[^false].

	myPlayer leftCastlingWalk in: [:w |
		(self checkRookMoversAttacksAlong: w) ifTrue: [^false].
		(self checkBishopMoversAttacksAlong: w) ifTrue: [^ false].
		(self checkKnightAttacksAlong: w) ifTrue: [^ false].
		(self checkPawnsAttacksAlong: w) ifTrue: [^ false].
		(self checkKingAttacksAlong: w) ifTrue: [^ false]].

	(self checkAttack: (myPlayer initialKingSquare + 1 to: H1) fromPieces: RookMovers)
		ifTrue: [^false].
	(self checkAttack: {B1 . A1} fromPieces: RookMovers) ifTrue: [^false].

	^true.
	
	
	
	
	
]

{ #category : #support }
Chess960MoveGenerator >> checkBishopMoversAttacksAlong: anArray [

	"anArray contains consecutive, ordered squares that are all either in rank 8 or in rank 1"
	
	anArray do: [:s |
		(self checkBishopMoversAttacksOn: s) ifTrue: [^ true]].

	^ false
]

{ #category : #support }
Chess960MoveGenerator >> checkBishopMoversAttacksOn: aSquare [

	"aSquare is either in rank 8 or in rank 1"
	
	| leftDiagonal rightDiagonal |

	myPlayer isWhitePlayer ifFalse: [
		leftDiagonal := (1 to: aSquare - A8) collect: [:n | aSquare - (n * 7)].
		rightDiagonal := (1 to: H8 - aSquare) collect: [:n | aSquare - (n * 9)]
	]
	ifTrue: [
		leftDiagonal := (1 to: aSquare - A1) collect: [:n | aSquare + (n * 7)].
		rightDiagonal := (1 to: H1 - aSquare) collect: [:n | aSquare + (n * 9)]
	].

	^ (self checkAttack: leftDiagonal fromPieces: BishopMovers)
		or: [self checkAttack: rightDiagonal fromPieces: BishopMovers]
]

{ #category : #support }
Chess960MoveGenerator >> checkKingAttacksAlong: anArray [

	"anArray contains consecutive, ordered squares that are all either in rank 8 or in rank 1"
	
	| kpos |

	"somewhat overkill because some positions can never be reached by opponent king"
	kpos := Array streamContents: [:str |
		str nextPut: anArray first - 1.
		str nextPutAll: anArray.
		str nextPut: anArray last + 1].

	^ self checkUnprotectedAttack:
			(kpos + (myPlayer isWhitePlayer ifTrue: [8] ifFalse: [-8]))
		fromPiece: King
]

{ #category : #support }
Chess960MoveGenerator >> checkKnightAttacksAlong: anArray [

	"anArray contains consecutive, ordered squares that are all either in rank 8 or in rank 1"
	
	| kpos1 kpos2 |

	"rank at distance 1"
	kpos1 := (anArray - 2) union: (anArray + 2).

	myPlayer isWhitePlayer ifTrue: [
		kpos1 min = 0 ifTrue: [kpos1 := kpos1 copyWithout: 0].
		kpos1 max = 9 ifTrue: [kpos1 := kpos1 copyWithout: 9]].

	(self checkUnprotectedAttack:
			(kpos1 + (myPlayer isWhitePlayer ifTrue: [8] ifFalse: [-8]))
		fromPiece: Knight) ifTrue: [^ true].

	"rank at distance 2 - same logic as for pawns at distance 1"
	kpos2 := Array streamContents: [:str |
		str nextPut: anArray min - 1.
		anArray size > 1 ifTrue: [str nextPutAll: anArray].
		str nextPut: anArray max + 1].

	^ self checkUnprotectedAttack:
			(kpos2 + (myPlayer isWhitePlayer ifTrue: [16] ifFalse: [-16]))
		fromPiece: Knight
]

{ #category : #support }
Chess960MoveGenerator >> checkPawnsAttacksAlong: anArray [

	"anArray contains consecutive, ordered squares that are all either in rank 8 or in rank 1"
	
	| ppos |

	ppos := Array streamContents: [:str |
		str nextPut: anArray first - 1.
		"If the king does not move, castling is not prevented by a pawn in same file"
		anArray size > 1 ifTrue: [str nextPutAll: anArray].
		str nextPut: anArray last + 1].

	^ self checkUnprotectedAttack:
			(ppos + (myPlayer isWhitePlayer ifTrue: [8] ifFalse: [-8]))
		fromPiece: Pawn
]

{ #category : #support }
Chess960MoveGenerator >> checkRookMoversAttacksAlong: anArray [

	"anArray contains consecutive, ordered squares that are all either in rank 8 or in rank 1"
	
	anArray first > 8 ifTrue: [ "black"
		anArray do: [:s |
			(self checkAttack: {s-8. s-16. s-24. s-32. s-40. s-48. s-56} fromPieces: RookMovers)
				ifTrue: [^ true]].
		^ false].

	"white"
	anArray do: [:s |
		(self checkAttack: {s+8. s+16. s+24. s+32. s+40. s+48. s+56} fromPieces: RookMovers)
			ifTrue: [^ true]].
	^ false
	
]

{ #category : #'moves-general' }
Chess960MoveGenerator >> moveBlackKingAt: square [
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
			moveCastlingKingSide: King from: square to: G8
	].
	self canCastleBlackQueenSide ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			moveCastlingQueenSide: King from: square to: C8
	].
]

{ #category : #'moves-general' }
Chess960MoveGenerator >> moveWhiteKingAt: square [
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
			moveCastlingKingSide: King from: square to: G1.
	].
	self canCastleWhiteQueenSide ifTrue:[
		(moveList at: (lastMoveIndex := lastMoveIndex + 1))
			moveCastlingQueenSide: King from: square to: C1.
	].
]
