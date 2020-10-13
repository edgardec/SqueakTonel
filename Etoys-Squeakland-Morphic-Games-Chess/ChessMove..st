"
I represent a particular move in the chess game.
"
Class {
	#name : #ChessMove,
	#superclass : #Object,
	#instVars : [
		'movingPiece',
		'capturedPiece',
		'sourceSquare',
		'destinationSquare',
		'type',
		'value',
		'bestMove'
	],
	#classVars : [
		'BasicMoveMask',
		'EvalTypeAccurate',
		'EvalTypeLowerBound',
		'EvalTypeUpperBound',
		'ExtractPromotionShift',
		'MoveCaptureEnPassant',
		'MoveCaptureOrdinary',
		'MoveCastlingKingSide',
		'MoveCastlingQueenSide',
		'MoveDoublePush',
		'MoveNormal',
		'MovePromotionBishop',
		'MovePromotionKnight',
		'MovePromotionQueen',
		'MovePromotionRook',
		'MoveResign',
		'MoveStaleMate',
		'NoPromotionMask',
		'NullMove',
		'PromotionMask',
		'PromotionShift'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #accessing }
ChessMove class >> basicMoveMask [
	^BasicMoveMask
]

{ #category : #accessing }
ChessMove class >> decodeFrom: encodedMove [
	^self new moveEncoded: encodedMove
]

{ #category : #'class initialization' }
ChessMove class >> initialize [
	"ChessMove initialize"
	MoveNormal := 1.
	MoveDoublePush := 2.
	MoveCaptureEnPassant := 3.
	MoveCastlingKingSide := 4.
	MoveCastlingQueenSide := 5.
	MoveResign := 6.
	MoveStaleMate := 7.

	BasicMoveMask := 15.
	PromotionShift := 4.
	ExtractPromotionShift :=  0 - PromotionShift.

	EvalTypeAccurate := 0.
	EvalTypeUpperBound := 1.
	EvalTypeLowerBound := 2.

	NullMove := 0.


]

{ #category : #comparing }
ChessMove >> = aMove [
	movingPiece = aMove movingPiece ifFalse:[^false].
	capturedPiece = aMove capturedPiece ifFalse:[^false].
	type = aMove type ifFalse:[^false].
	sourceSquare = aMove sourceSquare ifFalse:[^false].
	destinationSquare = aMove destinationSquare ifFalse:[^false].
	^true
]

{ #category : #accessing }
ChessMove >> bestMove [
	^nil
]

{ #category : #initialize }
ChessMove >> captureEnPassant: aPiece from: startSquare to: endSquare [
	movingPiece := capturedPiece := aPiece.
	sourceSquare := startSquare.
	destinationSquare := endSquare.
	type := MoveCaptureEnPassant.
]

{ #category : #accessing }
ChessMove >> capturedPiece [
	^capturedPiece
]

{ #category : #accessing }
ChessMove >> capturedPiece: aValue [
	^capturedPiece := aValue
]

{ #category : #initialize }
ChessMove >> checkMate: aPiece [
	movingPiece := aPiece.
	sourceSquare := 0.
	destinationSquare := 0.
	type := MoveResign.
	capturedPiece := 0.
]

{ #category : #accessing }
ChessMove >> destinationSquare [
	^destinationSquare
]

{ #category : #accessing }
ChessMove >> destinationSquare: aValue [
	^destinationSquare := aValue
]

{ #category : #initialize }
ChessMove >> doublePush: aPiece from: startSquare to: endSquare [
	movingPiece := aPiece.
	sourceSquare := startSquare.
	destinationSquare := endSquare.
	type := MoveDoublePush.
	capturedPiece := 0.
]

{ #category : #accessing }
ChessMove >> encodedMove [
	"Return an integer encoding enough of a move for printing"
	^destinationSquare + 
		(sourceSquare bitShift: 8) +
		(movingPiece bitShift: 16) +
		(capturedPiece bitShift: 24)
]

{ #category : #comparing }
ChessMove >> hash [
	^((movingPiece hash bitXor: capturedPiece hash) bitXor:
		(sourceSquare hash bitXor: destinationSquare hash)) bitXor: type hash
]

{ #category : #initialize }
ChessMove >> init [
	movingPiece := sourceSquare := destinationSquare := 1.
	type := MoveNormal.
	capturedPiece := 0.
]

{ #category : #initialize }
ChessMove >> move: aPiece from: startSquare to: endSquare [
	movingPiece := aPiece.
	sourceSquare := startSquare.
	destinationSquare := endSquare.
	type := MoveNormal.
	capturedPiece := 0.
]

{ #category : #initialize }
ChessMove >> move: aPiece from: startSquare to: endSquare capture: capture [
	movingPiece := aPiece.
	sourceSquare := startSquare.
	destinationSquare := endSquare.
	capturedPiece := capture.
	type := MoveNormal.

]

{ #category : #initialize }
ChessMove >> moveCastlingKingSide: aPiece from: startSquare to: endSquare [
	movingPiece := aPiece.
	sourceSquare := startSquare.
	destinationSquare := endSquare.
	type := MoveCastlingKingSide.
	capturedPiece := 0.
]

{ #category : #initialize }
ChessMove >> moveCastlingQueenSide: aPiece from: startSquare to: endSquare [
	movingPiece := aPiece.
	sourceSquare := startSquare.
	destinationSquare := endSquare.
	type := MoveCastlingQueenSide.
	capturedPiece := 0.
]

{ #category : #initialize }
ChessMove >> moveEncoded: encodedMove [
	destinationSquare := encodedMove bitAnd: 255.
	sourceSquare := (encodedMove bitShift: -8) bitAnd: 255.
	movingPiece := (encodedMove bitShift: -16) bitAnd: 255.
	capturedPiece := (encodedMove bitShift: -24) bitAnd: 255.
	type := MoveNormal.

]

{ #category : #printing }
ChessMove >> moveString [
	^String streamContents:[:aStream|
		aStream nextPutAll: (#('' 'N' 'B' 'R' 'Q' 'K') at: movingPiece).
		aStream nextPutAll: (String with: ($a asInteger + (sourceSquare - 1 bitAnd: 7)) asCharacter with: ($1 asInteger + (sourceSquare -1 bitShift: -3)) asCharacter).
		capturedPiece = 0 ifTrue:[
			aStream nextPutAll: '-'.
		] ifFalse:[
			aStream nextPutAll: 'x'.
			aStream nextPutAll: (#('' 'N' 'B' 'R' 'Q' 'K') at: capturedPiece).
		].
		aStream nextPutAll: (String with: ($a asInteger + (destinationSquare - 1 bitAnd: 7)) asCharacter with: ($1 asInteger + (destinationSquare -1 bitShift: -3)) asCharacter).
	].
]

{ #category : #accessing }
ChessMove >> moveType [
	^type
]

{ #category : #accessing }
ChessMove >> moveType: aType [
	^type := aType
]

{ #category : #accessing }
ChessMove >> movingPiece [
	^movingPiece
]

{ #category : #accessing }
ChessMove >> movingPiece: aValue [
	^movingPiece := aValue
]

{ #category : #printing }
ChessMove >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll:'('.
	aStream nextPutAll: (#('' 'N' 'B' 'R' 'Q' 'K') at: movingPiece).
	aStream nextPutAll: (String with: ($a asInteger + (sourceSquare - 1 bitAnd: 7)) asCharacter with: ($1 asInteger + (sourceSquare -1 bitShift: -3)) asCharacter).
	capturedPiece = 0 ifTrue:[
		aStream nextPutAll: '-'.
	] ifFalse:[
		aStream nextPutAll: 'x'.
		aStream nextPutAll: (#('' 'N' 'B' 'R' 'Q' 'K') at: capturedPiece).
	].
	aStream nextPutAll: (String with: ($a asInteger + (destinationSquare - 1 bitAnd: 7)) asCharacter with: ($1 asInteger + (destinationSquare -1 bitShift: -3)) asCharacter).
	aStream nextPutAll:')'.
]

{ #category : #initialize }
ChessMove >> promote: move to: promotion [
	movingPiece := move movingPiece.
	capturedPiece := move capturedPiece.
	sourceSquare := move sourceSquare.
	destinationSquare := move destinationSquare. 
	type := move moveType.
	type := type bitOr: (promotion bitShift: PromotionShift).

]

{ #category : #accessing }
ChessMove >> promotion [
	^type bitShift: ExtractPromotionShift
]

{ #category : #accessing }
ChessMove >> sourceSquare [
	^sourceSquare
]

{ #category : #accessing }
ChessMove >> sourceSquare: aValue [
	^sourceSquare := aValue
]

{ #category : #initialize }
ChessMove >> staleMate: aPiece [
	movingPiece := aPiece.
	sourceSquare := 0.
	destinationSquare := 0.
	type := MoveStaleMate.
	capturedPiece := 0.
]

{ #category : #accessing }
ChessMove >> triggerSquareIn: aChessBoard [

	type = MoveCastlingKingSide ifTrue: [^ aChessBoard activePlayer initialRightRookSquare].
	type = MoveCastlingQueenSide ifTrue: [^ aChessBoard activePlayer initialLeftRookSquare].

	^destinationSquare
]

{ #category : #accessing }
ChessMove >> value [
	^value
]

{ #category : #accessing }
ChessMove >> value: newValue [
	value := newValue
]
