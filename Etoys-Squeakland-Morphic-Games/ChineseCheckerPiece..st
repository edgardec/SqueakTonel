"
I represent a player piece for Chinese Checkers.  Mostly I act as an ellipse, but my special methods ensure that I cannot be picked up or dropped except in the proper circumstances.

Structure:
 myBoard		a ChineseCheckers morph
 boardLoc		my current logical position on the board.

"
Class {
	#name : #ChineseCheckerPiece,
	#superclass : #EllipseMorph,
	#instVars : [
		'boardLoc',
		'myBoard'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
ChineseCheckerPiece class >> includeInNewMorphMenu [

	^ false
]

{ #category : #accessing }
ChineseCheckerPiece >> boardLoc [

	^ boardLoc
]

{ #category : #'event handling' }
ChineseCheckerPiece >> handlesMouseDown: evt [

	^ true
]

{ #category : #'dropping\/grabbing' }
ChineseCheckerPiece >> justDroppedInto: newOwner event: evt [

	newOwner == myBoard ifFalse:
		["Only allow dropping into my board."
		^self rejectDropMorphEvent: evt].
	^super justDroppedInto: newOwner event: evt
]

{ #category : #'event handling' }
ChineseCheckerPiece >> mouseDown: evt [

	((owner isKindOf: ChineseCheckers)
		and: [owner okToPickUpPieceAt: boardLoc])
		ifTrue: [evt hand grabMorph: self]
]

{ #category : #accessing }
ChineseCheckerPiece >> setBoard: aBoard loc: aBoardLoc [

	myBoard := aBoard.
	boardLoc := aBoardLoc
]
