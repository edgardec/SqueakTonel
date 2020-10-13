"
An optimized representation of a set of moves - mainly there to avoid excessive allocation (and garbage collections) in a few critical places.
"
Class {
	#name : #ChessMoveList,
	#superclass : #ReadStream,
	#instVars : [
		'startIndex'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #accessing }
ChessMoveList >> contents [
	^collection copyFrom: startIndex to: readLimit
]

{ #category : #private }
ChessMoveList >> on: aCollection from: firstIndex to: lastIndex [
	startIndex := firstIndex.
	^super on: aCollection from: firstIndex to: lastIndex.

]

{ #category : #sorting }
ChessMoveList >> sortUsing: historyTable [
	
	^collection 
		quickSortFrom: startIndex
		to: readLimit
		by: [ :a :b | historyTable sorts: a before: b ]
]

{ #category : #accessing }
ChessMoveList >> startIndex [
	^startIndex
]
