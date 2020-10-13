"
This class represents the chess board itself.
"
Class {
	#name : #ChessBoard,
	#superclass : #Object,
	#instVars : [
		'whitePlayer',
		'blackPlayer',
		'activePlayer',
		'userAgent',
		'searchAgent',
		'generator',
		'hashKey',
		'hashLock'
	],
	#classVars : [
		'HashKeys',
		'HashLocks'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #'class initialization' }
ChessBoard class >> initialize [
	"ChessGame initialize"
	self initializeHashKeys.

]

{ #category : #'class initialization' }
ChessBoard class >> initializeHashKeys [
	"ChessGame initialize"
	| random |
	HashKeys := Array new: 12.
	1 to: HashKeys size do:[:i| HashKeys at: i put: (WordArray new: 64)].
	HashLocks := Array new: 12.
	1 to: HashLocks size do:[:i| HashLocks at: i put: (WordArray new: 64)].
	random := Random seed: 23648646.
	1 to: 12 do:[:i|
		1 to: 64 do:[:j|
			(HashKeys at: i) at: j put: (random nextInt: 16r3FFFFFFF "SmallInteger maxVal on 32bits VM")- 1. 
			(HashLocks at: i) at: j put: (random nextInt: 16r3FFFFFFF "SmallInteger maxVal on 32bits VM") - 1.
		].
	].


]

{ #category : #accessing }
ChessBoard >> activePlayer [
	^activePlayer
]

{ #category : #accessing }
ChessBoard >> blackPlayer [
	^blackPlayer
]

{ #category : #copying }
ChessBoard >> copyBoard: aBoard [ 
	"Copy all volatile state from the given board"

	whitePlayer copyPlayer: aBoard whitePlayer.
	blackPlayer copyPlayer: aBoard blackPlayer.
	activePlayer := aBoard activePlayer isWhitePlayer 
				ifTrue: [whitePlayer]
				ifFalse: [blackPlayer]. 
	hashKey := aBoard hashKey.
	hashLock := aBoard hashLock.
	userAgent := nil
]

{ #category : #accessing }
ChessBoard >> generator [
	^generator
]

{ #category : #hashing }
ChessBoard >> hashKey [
	^hashKey
]

{ #category : #hashing }
ChessBoard >> hashLock [
	^hashLock
]

{ #category : #initialize }
ChessBoard >> initialize [
	generator ifNil:[generator := ChessMoveGenerator new initialize].
	searchAgent ifNil:[searchAgent := ChessPlayerAI new initialize].
	self resetGame.

]

{ #category : #initialize }
ChessBoard >> initializeNewBoard [
	self resetGame.
	whitePlayer addWhitePieces.
	blackPlayer addBlackPieces.

]

{ #category : #moving }
ChessBoard >> movePieceFrom: sourceSquare to: destSquare [
	| move |
	searchAgent isThinking ifTrue:[^self].
	move := (activePlayer findPossibleMovesAt: sourceSquare) contents
		detect:[:any| any destinationSquare = destSquare
						or: [(any triggerSquareIn: self) = destSquare]].
	self nextMove: move.
	searchAgent activePlayer: activePlayer.
]

{ #category : #moving }
ChessBoard >> nextMove: aMove [ 
	activePlayer applyMove: aMove.
	userAgent 
		ifNotNil: [userAgent completedMove: aMove white: activePlayer isWhitePlayer].
	activePlayer := activePlayer == whitePlayer 
				ifTrue: [blackPlayer]
				ifFalse: [whitePlayer].
	activePlayer prepareNextMove 
]

{ #category : #moving }
ChessBoard >> nullMove [
	activePlayer := activePlayer == whitePlayer 
				ifTrue: [blackPlayer]
				ifFalse: [whitePlayer]. 
	activePlayer prepareNextMove
]

{ #category : #copying }
ChessBoard >> postCopy [
	whitePlayer == activePlayer ifTrue:[
		whitePlayer := whitePlayer copy.
		blackPlayer := blackPlayer copy.
		activePlayer := whitePlayer.
	] ifFalse:[
		whitePlayer := whitePlayer copy.
		blackPlayer := blackPlayer copy.
		activePlayer := blackPlayer.
	].
	whitePlayer opponent: blackPlayer.
	blackPlayer opponent: whitePlayer.
	whitePlayer board: self.
	blackPlayer board: self.
	self userAgent: nil.
]

{ #category : #printing }
ChessBoard >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPut: $(;
		print: hashKey; space; print: hashLock;
		nextPut: $).
]

{ #category : #initialize }
ChessBoard >> resetGame [
	hashKey := hashLock := 0.
	whitePlayer := ChessPlayer new initialize.
	blackPlayer := ChessPlayer new initialize.
	whitePlayer opponent: blackPlayer.
	whitePlayer board: self.
	blackPlayer opponent: whitePlayer.
	blackPlayer board: self.
	activePlayer := whitePlayer.
	searchAgent reset: self.
	userAgent ifNotNil:[userAgent gameReset].
]

{ #category : #accessing }
ChessBoard >> searchAgent [
	^searchAgent
]

{ #category : #accessing }
ChessBoard >> searchAgent: anAgent [
	searchAgent := anAgent.
]

{ #category : #accessing }
ChessBoard >> statusString [
	^searchAgent statusString
]

{ #category : #moving }
ChessBoard >> undoMove: aMove [ 
	activePlayer := activePlayer == whitePlayer 
				ifTrue: [blackPlayer]
				ifFalse: [whitePlayer]. 
	activePlayer undoMove: aMove.
	userAgent 
		ifNotNil: [userAgent undoMove: aMove white: activePlayer isWhitePlayer]
]

{ #category : #hashing }
ChessBoard >> updateHash: piece at: square from: player [ 
	| index |
	index := player == whitePlayer ifTrue: [piece] ifFalse: [piece + 6].
	hashKey := hashKey bitXor: ((HashKeys at: index) at: square). 
	hashLock := hashLock bitXor: ((HashLocks at: index) at: square)
]

{ #category : #accessing }
ChessBoard >> userAgent [
	^userAgent
]

{ #category : #accessing }
ChessBoard >> userAgent: anObject [
	userAgent := anObject.
]

{ #category : #accessing }
ChessBoard >> whitePlayer [
	^whitePlayer
]
