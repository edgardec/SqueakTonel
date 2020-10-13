"
See PDA comment. 
"
Class {
	#name : #PDAChoiceMorph,
	#superclass : #PopUpChoiceMorph,
	#instVars : [
		'backgroundColor'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #'new-morph participation' }
PDAChoiceMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #accessing }
PDAChoiceMorph >> color [

	^ backgroundColor
]

{ #category : #accessing }
PDAChoiceMorph >> color: aColor [

	backgroundColor := aColor.
	self changed
]

{ #category : #drawing }
PDAChoiceMorph >> drawOn: aCanvas [

	| offset |
	offset := 4@(bounds height - self fontToUse height // 2).
	aCanvas frameAndFillRectangle: bounds fillColor: backgroundColor
			borderWidth: 1 borderColor: Color black.
	aCanvas drawString: contents
			in: ((bounds translateBy: offset) intersect: bounds)
			font: self fontToUse color: Color black.

]
