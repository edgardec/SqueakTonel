"
Chess960Player represents a Chess960 player (doh)
"
Class {
	#name : #Chess960Player,
	#superclass : #ChessPlayer,
	#instVars : [
		'configuration'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess960'
}

{ #category : #'adding\/removing' }
Chess960Player >> addBlackPieces: aChess960Configuration [

	self configuration: aChess960Configuration.

	configuration positions doWithIndex: [:p :n | self addPiece: p at: 56+n].
	49 to: 56 do:[:i| self addPiece: Pawn at: i].
]

{ #category : #'adding\/removing' }
Chess960Player >> addWhitePieces: aChess960Configuration [

	self configuration: aChess960Configuration.

	configuration positions doWithIndex: [:p :n | self addPiece: p at: n].
	9 to: 16 do:[:i| self addPiece: Pawn at: i].

]

{ #category : #moving }
Chess960Player >> applyCastleKingSideMove: move [

	(pieces at: move destinationSquare) isZero "rook" ifFalse: [
		castlingRookSquare := self isWhitePlayer ifTrue: [F1] ifFalse: [F8].
		move sourceSquare = castlingRookSquare 
			ifTrue: [
				self swapPiecesIn: move sourceSquare and: move destinationSquare]
			ifFalse: [
				self movePiece: Rook from: self initialRightRookSquare to: castlingRookSquare.
				self movePiece: King from: move sourceSquare to: move destinationSquare].
		castlingStatus := castlingStatus bitOr: CastlingDone.
		^ self].

	self movePiece: move movingPiece from: move sourceSquare to: move destinationSquare.
	self movePiece: Rook 
		from: self initialRightRookSquare 
		to: ((castlingRookSquare := self isWhitePlayer ifTrue: [F1] ifFalse: [F8])).
	pieces at: castlingRookSquare put: King.
	castlingStatus := castlingStatus bitOr: CastlingDone.
]

{ #category : #moving }
Chess960Player >> applyCastleQueenSideMove: move [

	(pieces at: move destinationSquare) isZero "rook or king" ifFalse: [
		castlingRookSquare := self isWhitePlayer ifTrue: [D1] ifFalse: [D8].
		move sourceSquare = castlingRookSquare 
			ifTrue: [
				self swapPiecesIn: move sourceSquare and: move destinationSquare]
			ifFalse: [
				self movePiece: Rook 
					from: self initialLeftRookSquare to: castlingRookSquare.
				self movePiece: King from: move sourceSquare to: move destinationSquare].
		castlingStatus := castlingStatus bitOr: CastlingDone.
		^ self].

	self movePiece: move movingPiece from: move sourceSquare to: move destinationSquare.
	self movePiece: Rook 
		from: self initialLeftRookSquare 
		to: (castlingRookSquare := self isWhitePlayer ifTrue: [D1] ifFalse: [D8]).
	pieces at: castlingRookSquare put: King.
	castlingStatus := castlingStatus bitOr: CastlingDone.
]

{ #category : #configuration }
Chess960Player >> configuration [

	^ configuration
]

{ #category : #configuration }
Chess960Player >> configuration: aChess960Configuration [

	configuration := aChess960Configuration
]

{ #category : #copying }
Chess960Player >> copyPlayer: aPlayer [

	super copyPlayer: aPlayer.
	configuration := aPlayer configuration
]

{ #category : #configuration }
Chess960Player >> initialKingSquare [

	^ self isWhitePlayer ifTrue: [self configuration initialKingPosition] 
		ifFalse: [self configuration initialKingPosition + 56]
]

{ #category : #configuration }
Chess960Player >> initialLeftRookSquare [

	^ self isWhitePlayer ifTrue: [self configuration initialLeftRookPosition] 
		ifFalse: [self configuration initialLeftRookPosition + 56]
]

{ #category : #configuration }
Chess960Player >> initialRightRookSquare [

	^ self isWhitePlayer ifTrue: [self configuration initialRightRookPosition] 
		ifFalse: [self configuration initialRightRookPosition + 56]
]

{ #category : #configuration }
Chess960Player >> leftCastlingField [

	"The squares walked by both the king and the left rook when castling to the left - they must  be clear of other pieces"

	^ self isWhitePlayer 
		ifTrue: [(C1 to: self initialKingSquare) union: (self initialLeftRookSquare to: D1)] 
		ifFalse: [(C8 to: self initialKingSquare) union: (self initialLeftRookSquare to: D8)]

]

{ #category : #configuration }
Chess960Player >> leftCastlingWalk [

	"The squares walked by the king when castling to the left - they must not be under check"

	| ks |

	ks := self initialKingSquare.
	
	^ self isWhitePlayer 
		ifTrue: [ks > C1 ifTrue: [C1 to: ks] ifFalse: [ks to: C1]] 
		ifFalse: [ks > C8 ifTrue: [C8 to: ks] ifFalse: [ks to: C8]] 
]

{ #category : #'adding\/removing' }
Chess960Player >> movePiece: piece from: sourceSquare to: destSquare [

	sourceSquare = destSquare ifTrue: [^ self].
	super movePiece: piece from: sourceSquare to: destSquare
]

{ #category : #configuration }
Chess960Player >> rightCastlingField [

	"The squares walked by both the king and the right rook when castling to the left - they must  be clear of other pieces"

	^ self isWhitePlayer 
		ifTrue: [(self initialKingSquare to: G1) union: (F1 to: self initialRightRookSquare)] 
		ifFalse: [(self initialKingSquare to: G8) union: (F8 to: self initialRightRookSquare)]
]

{ #category : #configuration }
Chess960Player >> rightCastlingWalk [

	"The squares walked by the king when castling to the right - they must not be under check"

	| ks |

	ks := self initialKingSquare.
	
	^ self isWhitePlayer 
		ifTrue: [ks > G1 ifTrue: [G1 to: ks] ifFalse: [ks to: G1]] 
		ifFalse: [ks > G8 ifTrue: [G8 to: ks] ifFalse: [ks to: G8]] 
]

{ #category : #'adding\/removing' }
Chess960Player >> swapPiecesIn: aSquare and: bSquare [

	"Only applies to specific castling moves"

	| score pa pb |

	pa := pieces at: aSquare.
	pb := pieces at: bSquare.
	
	score := PieceCenterScores at: pa.
	positionalValue := positionalValue - (score at: aSquare).
	positionalValue := positionalValue + (score at: bSquare).

	score := PieceCenterScores at: pb.
	positionalValue := positionalValue - (score at: bSquare).
	positionalValue := positionalValue + (score at: aSquare).

	pieces at: aSquare put: pb.
	pieces at: bSquare put: pa.
	board updateHash: pa at: aSquare from: self.
	board updateHash: pa at: bSquare from: self.
	board updateHash: pb at: bSquare from: self.
	board updateHash: pb at: aSquare from: self.

	self userAgent ifNotNil:[self userAgent swappedPieceOn: aSquare withPieceOn: bSquare].
]

{ #category : #undo }
Chess960Player >> undoCastleKingSideMove: move [
	self prepareNextMove. "in other words, remove extra kings"
	self movePiece: move movingPiece from: move destinationSquare to: move sourceSquare.

	self isWhitePlayer ifTrue: [
			self movePiece: Rook from: F1 to: self initialRightRookPosition.
		] ifFalse: [
			self movePiece: Rook from: F8 to: self initialRightRookPosition + 56.
		]


]

{ #category : #undo }
Chess960Player >> undoCastleQueenSideMove: move [
	self prepareNextMove. "in other words, remove extra kings"
	self movePiece: move movingPiece from: move destinationSquare to: move sourceSquare.

	self isWhitePlayer ifTrue: [
			self movePiece: Rook from: D1 to: self initialLeftRookPosition.
		] ifFalse: [
			self movePiece: Rook from: D8 to: self initialLeftRookPosition + 56.
		]


]

{ #category : #moving }
Chess960Player >> updateCastlingStatus: move [

	"Cannot castle when king has moved"
	(move movingPiece = King) 
		ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableAll].

	"See if a rook has moved"
	(move movingPiece = Rook) ifFalse:[^self].

	(move sourceSquare = self initialLeftRookSquare) 
			ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableQueenSide].

	(move sourceSquare = self initialRightRookSquare) 
			ifTrue:[^castlingStatus := castlingStatus bitOr: CastlingDisableKingSide].
]
