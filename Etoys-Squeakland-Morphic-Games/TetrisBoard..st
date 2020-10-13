Class {
	#name : #TetrisBoard,
	#superclass : #PasteUpMorph,
	#instVars : [
		'paused',
		'gameOver',
		'delay',
		'score',
		'currentBlock',
		'game'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
TetrisBoard class >> includeInNewMorphMenu [

	^false
]

{ #category : #'as yet unclassified' }
TetrisBoard >> cellSize [

	^12@12
]

{ #category : #other }
TetrisBoard >> checkForFullRows [

	| targetY morphsInRow bonus |
	self numRows to: 2 by: -1 do: [ :row |
		targetY := (self originForCell: 1@row) y.
		[
			morphsInRow := self submorphsSatisfying: [ :each | each top = targetY].
			morphsInRow size = self numColumns
		] whileTrue: [
			bonus := (morphsInRow collect: [:each | each color]) asSet size = 1 
				ifTrue: [1000] 
				ifFalse: [100].
			self score: score + bonus.
			submorphs copy do: [ :each |
				each top = targetY ifTrue: [
					each delete
				].
				each top < targetY ifTrue: [
					each position: each position + (0@self cellSize y)
				].
			].
		].
	].


]

{ #category : #initialization }
TetrisBoard >> defaultBounds [
"answer the default bounds for the receiver"
	^ 0 @ 0 extent: self numColumns @ self numRows * self cellSize + (1 @ 1)
]

{ #category : #initialization }
TetrisBoard >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		  lightBlue
]

{ #category : #'button actions' }
TetrisBoard >> dropAllTheWay [

	self running ifFalse: [^ self].
	[currentBlock dropByOne] whileTrue: [
		self score: score + 1
	].

]

{ #category : #data }
TetrisBoard >> emptyAt: aPoint [

	| cellOrigin |
	(aPoint x between: 1 and: self numColumns) ifFalse: [^ false].
	(aPoint y < 1) ifTrue: [^ true].	"handle early phases"
	(aPoint y <= self numRows) ifFalse: [^ false].
	cellOrigin := self originForCell: aPoint.
	^(self submorphsSatisfying: [ :each | each topLeft = cellOrigin]) isEmpty


]

{ #category : #accessing }
TetrisBoard >> game: aTetris [

	game := aTetris
]

{ #category : #'button actions' }
TetrisBoard >> moveLeft [

	self running ifFalse: [^ self].
	currentBlock moveDeltaX: -1 deltaY: 0 deltaAngle: 0.

]

{ #category : #'button actions' }
TetrisBoard >> moveRight [

	self running ifFalse: [^ self].
	currentBlock moveDeltaX: 1 deltaY: 0 deltaAngle: 0.

]

{ #category : #'button actions' }
TetrisBoard >> newGame [

	self removeAllMorphs.
	gameOver := paused := false.
	delay := 500.
	currentBlock := nil.
	self score: 0.

]

{ #category : #data }
TetrisBoard >> numColumns [

	^10
	
]

{ #category : #data }
TetrisBoard >> numRows [

	^27
	
]

{ #category : #'as yet unclassified' }
TetrisBoard >> originForCell: aPoint [

	^aPoint - (1@1) * self cellSize + self position


]

{ #category : #'button actions' }
TetrisBoard >> pause [

	gameOver ifTrue: [^ self].
	paused := paused not.

]

{ #category : #'button actions' }
TetrisBoard >> rotateAntiClockWise [

	self running ifFalse: [^ self].
	currentBlock moveDeltaX: 0 deltaY: 0 deltaAngle: -1.

]

{ #category : #'button actions' }
TetrisBoard >> rotateClockWise [

	self running ifFalse: [^ self].
	currentBlock moveDeltaX: 0 deltaY: 0 deltaAngle: 1.

]

{ #category : #'button actions' }
TetrisBoard >> running [

	^currentBlock notNil and: [paused not]
]

{ #category : #accessing }
TetrisBoard >> score: aNumber [

	score := aNumber.
	game score: score.
]

{ #category : #'stepping and presenter' }
TetrisBoard >> step [

	(self ownerThatIsA: HandMorph) ifNotNil: [^self].
	paused ifTrue: [^ self]. 
	currentBlock ifNil: [
		currentBlock := TetrisBlock new.
		self addMorphFront: currentBlock.
		currentBlock board: self.
	] ifNotNil: [
		currentBlock dropByOne ifFalse: [self storePieceOnBoard]
	].

]

{ #category : #testing }
TetrisBoard >> stepTime [
	^ delay
]

{ #category : #other }
TetrisBoard >> storePieceOnBoard [

	currentBlock submorphs do: [ :each |
		self addMorph: each.
		((each top - self top) // self cellSize y) < 3 ifTrue: [
			paused := gameOver := true.
		].
	].
	currentBlock delete.
	currentBlock := nil.
	self checkForFullRows.
	self score: score + 10.
	delay := delay - 2 max: 80.


]
