"
The transposition table is a lookup cache for positions in a game that occur through transpositions in move. As an example, the same position is obtained by the moves:
	1. e2-e4		Nb8-c6
	2. d2-d4
and
	1. d2-d4		Nb8-c6
	2. e2-e4
An extremely large number of search branches can be cut off immediately by recognizing that the current position is just the transposition of another one. The transposition table is one of the techniques that actually make modern chess programs good enough to compete with or even beat humans.

"
Class {
	#name : #ChessTranspositionTable,
	#superclass : #Object,
	#instVars : [
		'array',
		'used',
		'collisions'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #'instance creation' }
ChessTranspositionTable class >> new: bits [
	^self basicNew initialize: bits
]

{ #category : #initialize }
ChessTranspositionTable >> clear [
	"Set the following to true for printing information about the fill rate and number of collisions. The transposition table should have *plenty* of free space (it should rarely exceed 30% fill rate) and *very* few collisions (those require us to evaluate positions repeatedly that we've evaluated before -- bad idea!)"

	| entry |
	false 
		ifTrue: 
			[used position > 0 
				ifTrue: 
					['entries used:	' , used position printString , ' (' 
						, (used position * 100 // array size) printString , '%)	' 
						displayAt: 0 @ 0].
			collisions > 0 
				ifTrue: 
					['collisions:		' , collisions printString , ' (' 
						, (collisions * 100 // array size) printString , '%)	' 
						displayAt: 0 @ 15]].
	used position: 0.
	[(entry := used next) isNil] whileFalse: [entry clear].
	used resetToStart.
	collisions := 0
]

{ #category : #initialize }
ChessTranspositionTable >> initialize: nBits [
	"Initialize the receiver using 1<<nBits entries. See also ChessPlayerAI>>initializeTranspositionTable."
	| entry |
	array := Array new: 1 << nBits.
	used := ReadWriteStream on: (Array new: 50000). "<- will grow if not sufficient!"
	entry := ChessTTEntry new clear.
	1 to: array size do:[:i| array at: i put: entry shallowCopy].
	collisions := 0.
	Smalltalk garbageCollect. "We *really* want them old here"
]

{ #category : #lookup }
ChessTranspositionTable >> lookupBoard: aBoard [
	| key entry |
	key := aBoard hashKey bitAnd: array size - 1.
	entry := array at: key + 1.
	entry ifNil:[^nil].
	entry valueType = -1 ifTrue:[^nil].
	entry hashLock = aBoard hashLock ifFalse:[^nil].
	^entry
]

{ #category : #initialize }
ChessTranspositionTable >> storeBoard: aBoard value: value type: valueType depth: depth stamp: timeStamp [
	| key entry |
	key := aBoard hashKey bitAnd: array size - 1.
	entry := array at: key + 1.
	entry valueType = -1 
		ifTrue:[used nextPut: entry]
		ifFalse:[entry hashLock = aBoard hashLock ifFalse:[collisions := collisions + 1]].
	(entry valueType = -1 
		or:[entry depth <= depth
		or:[entry timeStamp < timeStamp]]) ifFalse:[^self].
	entry hashLock: aBoard hashLock.
	entry value: value.
	entry valueType: valueType.
	entry depth: depth.
	entry timeStamp: timeStamp.

]
