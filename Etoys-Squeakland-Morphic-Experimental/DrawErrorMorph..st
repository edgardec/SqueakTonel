"
This morph simply invokes errors during drawing and stepping.
"
Class {
	#name : #DrawErrorMorph,
	#superclass : #Morph,
	#category : #'Etoys-Squeakland-Morphic-Experimental'
}

{ #category : #drawing }
DrawErrorMorph >> drawOn: aCanvas [
	aCanvas error:'DrawErrorMorph drawOn: invoked'
]

{ #category : #printing }
DrawErrorMorph >> printOn: aStream [
	"Indirectly invokes an error during stepping in an Inspector"
	aStream error:'DrawErrorMorph>>printOn: invoked'
]
