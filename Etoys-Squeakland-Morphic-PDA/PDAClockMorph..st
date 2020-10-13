"
See PDA comment. '
"
Class {
	#name : #PDAClockMorph,
	#superclass : #WatchMorph,
	#instVars : [
		'backgroundColor'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #'new-morph participation' }
PDAClockMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #accessing }
PDAClockMorph >> color [
	^ backgroundColor
]

{ #category : #accessing }
PDAClockMorph >> color: aColor [
	backgroundColor := aColor.
	self changed
]

{ #category : #drawing }
PDAClockMorph >> drawOn: aCanvas [

	aCanvas frameAndFillRectangle: self bounds fillColor: backgroundColor
				borderWidth: self borderWidth borderColor: self borderColor.
	super drawOn: aCanvas.

]

{ #category : #'as yet unclassified' }
PDAClockMorph >> faceColor: aColor [
	super color: aColor
]
