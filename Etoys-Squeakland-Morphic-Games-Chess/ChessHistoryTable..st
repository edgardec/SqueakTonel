"
This class is a history table for our 'killer heuristic'. It remembers moves that have proven effective in the past and is later used to prioritize newly generated moves according to the effectiveness of the particular move in the past.
"
Class {
	#name : #ChessHistoryTable,
	#superclass : #Object,
	#type : #words,
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #'instance creation' }
ChessHistoryTable class >> new [
	^self new: 4096+64
]

{ #category : #accessing }
ChessHistoryTable >> addMove: aMove [
	| index |
	index := (aMove sourceSquare bitShift: 6) + aMove destinationSquare.
	self at: index put: (self at: index + 1)
]

{ #category : #initialize }
ChessHistoryTable >> atAllPut: aPositiveInteger [
	"Fill the receiver, an indexable bytes or words object, with the given positive integer. The range of possible fill values is [0..255] for byte arrays and [0..(2^32 - 1)] for word arrays."

	<primitive: 145>
	self errorImproperStore.
]

{ #category : #initialize }
ChessHistoryTable >> clear [
	self atAllPut: 0.
]

{ #category : #sorting }
ChessHistoryTable >> sorts: move1 before: move2 [
	^(self at: (move1 sourceSquare bitShift: 6) + move1 destinationSquare) >
		(self at: (move2 sourceSquare bitShift: 6) + move2 destinationSquare)
]
