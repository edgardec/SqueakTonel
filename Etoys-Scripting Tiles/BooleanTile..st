"
A tile whose result type is boolean.
"
Class {
	#name : #BooleanTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #accessing }
BooleanTile >> resultType [
	"Answer the result type of the receiver"

	^ #Boolean
]
