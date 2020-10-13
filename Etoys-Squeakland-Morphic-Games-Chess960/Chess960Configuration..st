"
A Chess960Configuration is a Fisher-style random starting arrangement of pieces in the home ranks
"
Class {
	#name : #Chess960Configuration,
	#superclass : #Object,
	#instVars : [
		'positions',
		'king',
		'leftRook',
		'rightRook'
	],
	#pools : [
		'ChessConstants'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess960'
}

{ #category : #'as yet unclassified' }
Chess960Configuration class >> new [

	| rand positions k |

	rand := Random new.
	positions := Array new: 8.
	positions at: (rand nextInt: 4) * 2 - 1 put: Bishop.
	positions at: (rand nextInt: 4) * 2 put: Bishop.
	positions at: (k := (((1 to: 8) select: [:n | (positions at: n) isNil]) copyFrom: 2 to: 5) atRandom: rand) put: King.
	positions at: (((1 to: k-1) select: [:n | (positions at: n) isNil]) atRandom: rand) put: Rook.
	positions at: (((k+1 to: 8) select: [:n | (positions at: n) isNil]) atRandom: rand) put: Rook.
	positions at: (((1 to: 8) select: [:n | (positions at: n) isNil]) atRandom: rand) put: Queen.
	positions at: ((1 to: 8) detect: [:n | (positions at: n) isNil]) put: Knight.
	positions at: ((1 to: 8) detect: [:n | (positions at: n) isNil]) put: Knight.

	^ self basicNew positions: positions

]

{ #category : #positions }
Chess960Configuration >> initialKingPosition [

	^ king ifNil: [king := positions indexOf: King]
]

{ #category : #positions }
Chess960Configuration >> initialLeftRookPosition [

	^ leftRook ifNil: [leftRook := positions indexOf: Rook]
]

{ #category : #positions }
Chess960Configuration >> initialRightRookPosition [

	^ rightRook ifNil: [rightRook := positions indexOf: Rook startingAt: self initialKingPosition]
]

{ #category : #positions }
Chess960Configuration >> positions [

	^ positions
]

{ #category : #positions }
Chess960Configuration >> positions: anArray [

	positions := anArray.
	king := leftRook := rightRook := nil
]
