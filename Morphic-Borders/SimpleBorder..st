"
see BorderedMorph
"
Class {
	#name : #SimpleBorder,
	#superclass : #BorderStyle,
	#instVars : [
		'baseColor',
		'color',
		'width'
	],
	#category : #'Morphic-Borders'
}

{ #category : #accessing }
SimpleBorder >> baseColor [

	^baseColor
]

{ #category : #accessing }
SimpleBorder >> baseColor: aColor [

	baseColor = aColor ifTrue:[^self].
	baseColor := aColor ifNil: [Color transparent].
	self color: baseColor "#color: will do  #releaseCachedState"
]

{ #category : #accessing }
SimpleBorder >> bottomRightColor [
	^color
]

{ #category : #accessing }
SimpleBorder >> color [

	^color
]

{ #category : #accessing }
SimpleBorder >> color: aColor [
	color = aColor ifTrue:[^self].
	color := aColor.
	self releaseCachedState.
]

{ #category : #drawing }
SimpleBorder >> drawLineFrom: startPoint to: stopPoint on: aCanvas [ 
	| lineColor |
	lineColor := (stopPoint truncated quadrantOf: startPoint truncated) > 2 
				ifTrue: [self topLeftColor]
				ifFalse: [self bottomRightColor].
	aCanvas 
		line: startPoint
		to: stopPoint 
		width: self width
		color: lineColor
]

{ #category : #drawing }
SimpleBorder >> frameRectangle: aRectangle on: aCanvas [
	aCanvas frameAndFillRectangle: aRectangle
		fillColor: Color transparent
		borderWidth: self width
		topLeftColor: self topLeftColor
		bottomRightColor: self bottomRightColor.
]

{ #category : #'initialize-release' }
SimpleBorder >> initialize [
	
	super initialize.

	width := 0.
	baseColor := color := Color transparent
]

{ #category : #accessing }
SimpleBorder >> style [
	^#simple
]

{ #category : #accessing }
SimpleBorder >> topLeftColor [
	^color
]

{ #category : #accessing }
SimpleBorder >> width [

	^width
]

{ #category : #accessing }
SimpleBorder >> width: aNumber [
	width = aNumber ifTrue:[^self].
	width := aNumber truncated max: (width isPoint ifTrue:[0@0] ifFalse:[0]).
	self releaseCachedState.
]
