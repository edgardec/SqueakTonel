Class {
	#name : #ChessPieceMorph,
	#superclass : #ImageMorph,
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #'dropping\/grabbing' }
ChessPieceMorph >> wantsToBeDroppedInto: aMorph [
	^aMorph isKindOf: ChessMorph
]
