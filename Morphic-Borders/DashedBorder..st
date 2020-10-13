Class {
	#name : #DashedBorder,
	#superclass : #SimpleBorder,
	#instVars : [
		'dashLength',
		'gapLength',
		'gapColor',
		'offset'
	],
	#category : #'Morphic-Borders'
}

{ #category : #accessing }
DashedBorder >> dashLength [

	^ dashLength
]

{ #category : #accessing }
DashedBorder >> dashLength: anObject [

	dashLength := anObject.
]

{ #category : #drawing }
DashedBorder >> frameRectangle: aRectangle on: aCanvas [

	{
		aRectangle topLeft. aRectangle topRight - (1@0).
		aRectangle topRight - (1@0). aRectangle bottomRight - (1@1).
		aRectangle bottomRight - (1@1). aRectangle bottomLeft - (0@1).
		aRectangle bottomLeft - (0@1). aRectangle topLeft.
	} pairsDo: [:startPoint :endPoint |
		aCanvas
			line: startPoint to: endPoint
			width: self width
			color: self color
			dashLength: self dashLength
			secondColor: self gapColor
			secondDashLength: self gapLength
			startingOffset: self offset]
]

{ #category : #accessing }
DashedBorder >> gapColor [

	^ gapColor
]

{ #category : #accessing }
DashedBorder >> gapColor: anObject [

	gapColor := anObject.
]

{ #category : #accessing }
DashedBorder >> gapLength [

	^ gapLength
]

{ #category : #accessing }
DashedBorder >> gapLength: anObject [

	gapLength := anObject.
]

{ #category : #'initialize-release' }
DashedBorder >> initialize [

	super initialize.
	
	dashLength := 10.
	
	gapLength := 4.
	gapColor := Color transparent.
	
	offset := 0.
]

{ #category : #accessing }
DashedBorder >> offset [

	^ offset
]

{ #category : #accessing }
DashedBorder >> offset: anObject [

	offset := anObject.
]
