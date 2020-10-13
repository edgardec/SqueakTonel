"
I represent a quad-edge within a subdivision.
"
Class {
	#name : #SubdivisionQuadEdge,
	#superclass : #Object,
	#instVars : [
		'edges',
		'flags',
		'timeStamp'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Triangulation'
}

{ #category : #'instance creation' }
SubdivisionQuadEdge class >> new [
	^self basicNew initialize
]

{ #category : #accessing }
SubdivisionQuadEdge >> classificationColor [
	"Return the classification index of the receiver"
	| r g b |
	r := self isInteriorEdge ifTrue:[1] ifFalse:[0].
	g := self isExteriorEdge ifTrue:[1] ifFalse:[0].
	b := self isBorderEdge ifTrue:[1] ifFalse:[0].
	^Color r: r g: g b: b.
]

{ #category : #accessing }
SubdivisionQuadEdge >> classificationIndex [
	"Return the classification index of the receiver"
	^flags bitAnd: 7
]

{ #category : #private }
SubdivisionQuadEdge >> edgeClass [
	^SubdivisionHalfEdge
]

{ #category : #accessing }
SubdivisionQuadEdge >> edges [
	^edges
]

{ #category : #accessing }
SubdivisionQuadEdge >> first [
	^edges first
]

{ #category : #accessing }
SubdivisionQuadEdge >> flags [
	^flags
]

{ #category : #accessing }
SubdivisionQuadEdge >> flags: newFlags [
	flags := newFlags
]

{ #category : #'initialize-release' }
SubdivisionQuadEdge >> initialize [
	edges := Array new: 4.
	1 to: 4 do:[:i| edges at: i put: (self edgeClass new id: i owner: self)].
	(edges at: 1) next: (edges at: 1).
	(edges at: 2) next: (edges at: 4).
	(edges at: 3) next: (edges at: 3).
	(edges at: 4) next: (edges at: 2).
	timeStamp := 0.
	flags := 0.
]

{ #category : #accessing }
SubdivisionQuadEdge >> isBorderEdge [
	^flags anyMask: 1
]

{ #category : #accessing }
SubdivisionQuadEdge >> isBorderEdge: aBool [
	flags := aBool ifTrue:[flags bitOr: 1] ifFalse:[flags bitClear: 1].
]

{ #category : #accessing }
SubdivisionQuadEdge >> isExteriorEdge [
	^flags anyMask: 4
]

{ #category : #accessing }
SubdivisionQuadEdge >> isExteriorEdge: aBool [
	flags := aBool ifTrue:[flags bitOr: 4] ifFalse:[flags bitClear: 4].
]

{ #category : #accessing }
SubdivisionQuadEdge >> isInteriorEdge [
	^flags anyMask: 2
]

{ #category : #accessing }
SubdivisionQuadEdge >> isInteriorEdge: aBool [
	flags := aBool ifTrue:[flags bitOr: 2] ifFalse:[flags bitClear: 2].
]

{ #category : #accessing }
SubdivisionQuadEdge >> timeStamp [
	^timeStamp
]

{ #category : #accessing }
SubdivisionQuadEdge >> timeStamp: aNumber [
	timeStamp := aNumber
]
