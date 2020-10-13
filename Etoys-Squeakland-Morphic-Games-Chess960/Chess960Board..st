"
Chess960Board can handle Fisher-style random starting positions in home ranks
"
Class {
	#name : #Chess960Board,
	#superclass : #ChessBoard,
	#category : #'Etoys-Squeakland-Morphic-Games-Chess960'
}

{ #category : #initialize }
Chess960Board >> initialize [
	generator ifNil:[generator := Chess960MoveGenerator new initialize].
	searchAgent ifNil:[searchAgent := ChessPlayerAI new initialize].
	self resetGame.

]

{ #category : #initialize }
Chess960Board >> initializeNewBoard [
	
	| conf |

	self resetGame.
	conf := Chess960Configuration new.
	whitePlayer addWhitePieces: conf.
	blackPlayer addBlackPieces: conf.

]

{ #category : #initialize }
Chess960Board >> resetGame [
	hashKey := hashLock := 0.
	whitePlayer := Chess960Player new initialize.
	blackPlayer := Chess960Player new initialize.
	whitePlayer opponent: blackPlayer.
	whitePlayer board: self.
	blackPlayer opponent: whitePlayer.
	blackPlayer board: self.
	activePlayer := whitePlayer.
	searchAgent reset: self.
	userAgent ifNotNil:[userAgent gameReset].
]
