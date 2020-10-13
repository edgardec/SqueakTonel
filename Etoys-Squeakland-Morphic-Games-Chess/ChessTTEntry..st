"
This class represents an entry in the transposition table, storing the value (plus some maintenance information) of some position.
"
Class {
	#name : #ChessTTEntry,
	#superclass : #Object,
	#instVars : [
		'value',
		'valueType',
		'depth',
		'hashLock',
		'timeStamp'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #accessing }
ChessTTEntry >> clear [
	value := valueType := timeStamp := depth := -1.
]

{ #category : #accessing }
ChessTTEntry >> depth [
	^depth
]

{ #category : #accessing }
ChessTTEntry >> depth: aNumber [
	depth := aNumber
]

{ #category : #accessing }
ChessTTEntry >> hashLock [
	^hashLock
]

{ #category : #accessing }
ChessTTEntry >> hashLock: aNumber [
	hashLock := aNumber
]

{ #category : #accessing }
ChessTTEntry >> timeStamp [
	^timeStamp
]

{ #category : #accessing }
ChessTTEntry >> timeStamp: aNumber [
	timeStamp := aNumber
]

{ #category : #accessing }
ChessTTEntry >> value [
	^value
]

{ #category : #accessing }
ChessTTEntry >> value: newValue [
	value := newValue
]

{ #category : #accessing }
ChessTTEntry >> valueType [
	^valueType
]

{ #category : #accessing }
ChessTTEntry >> valueType: newType [
	valueType := newType
]
