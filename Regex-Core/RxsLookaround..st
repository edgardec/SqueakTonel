"
Lookaround is used for lookaheads and lookbehinds. They are used to check if the input matches a certain subexpression without consuming any characters (e.g. not advancing the match position).

Lookarounds can be positive or negative. If they are positive the condition fails if the subexpression fails, if they are negative it is inverse.
"
Class {
	#name : #RxsLookaround,
	#superclass : #RxsNode,
	#instVars : [
		'piece',
		'forward',
		'positive'
	],
	#category : #'Regex-Core'
}

{ #category : #'instance creation' }
RxsLookaround class >> with: aRxsRegex forward: forwardBoolean positive: positiveBoolean [
	^ self new
		initializePiece: aRxsRegex
		forward: forwardBoolean
		positive: positiveBoolean
]

{ #category : #'initialize-release' }
RxsLookaround >> beLookahead [
	forward := true
]

{ #category : #'initialize-release' }
RxsLookaround >> beLookbehind [
	forward := false
]

{ #category : #'initialize-release' }
RxsLookaround >> beNegative [
	positive := false
]

{ #category : #'initialize-release' }
RxsLookaround >> bePositive [
	positive := true
]

{ #category : #accessing }
RxsLookaround >> dispatchTo: aBuilder [
	"Inform the matcher of the kind of the node, and it will do whatever it has to."
	^aBuilder syntaxLookaround: self forward: self forward positive: self positive
]

{ #category : #accessing }
RxsLookaround >> forward [

	^ forward
]

{ #category : #'initialize-release' }
RxsLookaround >> initialize [

	super initialize.
	self bePositive.
]

{ #category : #'initialize-release' }
RxsLookaround >> initializePiece: anRsxPiece forward: forwardBoolean positive: positiveBoolean [

	piece := anRsxPiece.
	forward := forwardBoolean.
	positive := positiveBoolean.
]

{ #category : #accessing }
RxsLookaround >> piece [
	^ piece
]

{ #category : #accessing }
RxsLookaround >> positive [

	^ positive
]
