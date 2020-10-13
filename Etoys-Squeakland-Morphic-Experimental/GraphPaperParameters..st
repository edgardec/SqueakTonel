"
parameters that define ""graph paper"".  
	backgroundColor	the color of the ""paper""
	gridColor 				the color of the finest grid lines
	gridEvery				pixels per fine grid
	darkerGridColor		the color of the coarser grid lines
	darkerLineEvery		fine grid lines per coarser grid line
	offset					offset point for the infinite form
"
Class {
	#name : #GraphPaperParameters,
	#superclass : #Object,
	#instVars : [
		'backgroundColor',
		'gridColor',
		'gridEvery',
		'showDarkerGridAlso',
		'darkerGridColor',
		'darkerGridEvery',
		'offset'
	],
	#category : #'Etoys-Squeakland-Morphic-Experimental'
}

{ #category : #'instance creation' }
GraphPaperParameters class >> backgroundColor: bgColor gridColor: gridColor gridEvery: pixelsPerGrid showDarkerGridAlso: aBoolean darkerGridColor: darkerGridColor darkerGridEvery: gridsPerDarkerGrid offset: offsetPoint [
	"Answer a new GraphPaperParameters instance holding the values provided."

	| parms |
	parms := self new.
	parms backgroundColor: bgColor.
	parms gridColor: gridColor.
	parms gridEvery: pixelsPerGrid.
	parms showDarkerGridAlso: aBoolean.
	parms darkerGridColor: darkerGridColor.
	parms darkerGridEvery: gridsPerDarkerGrid.
	parms offset: offsetPoint asPoint.
	^ parms
]

{ #category : #'form creation' }
GraphPaperParameters class >> oneTierGridFormOrigin: origin grid: smallGrid  background: backColor line: lineColor [
	"Answer an infinite form that repeats as a simple grid."

	^ Morph basicNew gridFormOrigin: origin grid: smallGrid asPoint background: backColor line: lineColor

"
	| aPlayfield |
	aPlayfield := PasteUpMorph authoringPrototype extent: 640 @ 480.
	aPlayfield color: (GraphPaperParameters oneTierGridFormOrigin: (0@0) grid: 16 background: Color green muchLighter line: Color blue muchLighter).
	aPlayfield openInHand
"

]

{ #category : #'form creation' }
GraphPaperParameters class >> twoTierGridFormOrigin: origin grid: smallGrid  background: backColor line: lineColor darkerGridEvery: darkerGridEvery darkerGridColor: darkerGridColor [
	"Answer an infinite form that repeats a pattern involving grid lines with darker ones at regular intervals, such as 'engineering paper'."

	| smallGridAsPoint gridForm gridOrigin fullGrid aColor darkGridOrigin countX countY |
	smallGridAsPoint := smallGrid rounded asPoint.
	fullGrid := smallGridAsPoint * darkerGridEvery.
	gridForm := Form extent: fullGrid depth: Display depth.
	gridOrigin := origin \\ smallGridAsPoint.
	darkGridOrigin := origin \\ fullGrid.
	backColor ifNotNil: [gridForm fillWithColor: backColor].
	darkGridOrigin ifNotNil:[countX:=  darkGridOrigin x. countY:=  darkGridOrigin y] 
	ifNil:[countX:= countY := -1].

	gridOrigin x to: gridForm width by: smallGridAsPoint x do:
		[:x |
			aColor := (countX \\ darkerGridEvery) = 0 ifTrue: [darkerGridColor] ifFalse: [lineColor].
			gridForm fill: (x@0 extent: 1@gridForm height) fillColor: aColor. 
			countX:= countX+ 1.].
	gridOrigin y to: gridForm height by: smallGridAsPoint y do:
		[:y |
			aColor := (countY\\ darkerGridEvery) = 0 ifTrue: [darkerGridColor] ifFalse: [lineColor].
			gridForm fill: (0@y extent: gridForm width@1) fillColor: aColor. 
			countY:= countY+ 1.].
	^ InfiniteForm with: gridForm

"
	| aPlayfield |
	aPlayfield := PasteUpMorph authoringPrototype extent: 640 @ 480.
	aPlayfield color: (GraphPaperParameters twoTierGridFormOrigin: (0@0) grid: 16 background: Color green muchLighter line: Color blue muchLighter darkerGridEvery: 10 darkerGridColor: Color blue muchDarker).
	aPlayfield openInHand
"

]

{ #category : #'form creation' }
GraphPaperParameters >> asInfiniteForm [
	"Answer an InfiniteForm embodying the parameters of the receiver."

	^ self showDarkerGridAlso
		ifTrue:
			[self class twoTierGridFormOrigin: offset grid: gridEvery  background: backgroundColor line: gridColor darkerGridEvery: darkerGridEvery darkerGridColor: darkerGridColor]
		ifFalse:
			[self class oneTierGridFormOrigin: offset grid: gridEvery  background: backgroundColor line: gridColor]
]

{ #category : #accessing }
GraphPaperParameters >> backgroundColor [
	"Answer the value of backgroundColor"

	^ backgroundColor
]

{ #category : #accessing }
GraphPaperParameters >> backgroundColor: anObject [
	"Set the value of backgroundColor."

	backgroundColor := anObject
]

{ #category : #accessing }
GraphPaperParameters >> darkerGridColor [
	"Answer the value of darkerGridColor"

	^ darkerGridColor
]

{ #category : #accessing }
GraphPaperParameters >> darkerGridColor: anObject [
	"Set the value of darkerGridColor."

	darkerGridColor := anObject
]

{ #category : #accessing }
GraphPaperParameters >> darkerGridEvery [
	"Answer the value of darkerGridEvery"

	^ darkerGridEvery
]

{ #category : #accessing }
GraphPaperParameters >> darkerGridEvery: aNumber [
	"Set the value of darkerGridEvery"

	darkerGridEvery := aNumber rounded
]

{ #category : #initialization }
GraphPaperParameters >> fillFrom: aGraphPaperMorph [
	"Fill the receiver's instance variables from a GraphPaperMorph panel."

	backgroundColor := aGraphPaperMorph backgroundColor. 
	gridColor := aGraphPaperMorph gridColor.
	gridEvery:= aGraphPaperMorph gridEvery.
	showDarkerGridAlso := aGraphPaperMorph showDarkerGridAlso ifNil: [false].
	darkerGridColor := aGraphPaperMorph darkerGridColor.
	darkerGridEvery := aGraphPaperMorph darkerGridEvery.
	offset := aGraphPaperMorph offset
]

{ #category : #accessing }
GraphPaperParameters >> gridColor [
	"Answer the value of gridColor"

	^ gridColor
]

{ #category : #accessing }
GraphPaperParameters >> gridColor: anObject [
	"Set the value of gridColor."

	gridColor := anObject
]

{ #category : #accessing }
GraphPaperParameters >> gridEvery [
	"Answer the value of gridEvery"

	^ gridEvery
]

{ #category : #accessing }
GraphPaperParameters >> gridEvery: aNumber [
	"Set the value of gridEvery"

	gridEvery := aNumber rounded
]

{ #category : #initialization }
GraphPaperParameters >> initialize [
	"Initialize the receiver and give default values to all the parameters."

	super initialize.
	backgroundColor := Color green lighter.
	gridColor := Color green darker.
	gridEvery := 16.
	showDarkerGridAlso := true.
	darkerGridColor := Color black.
	darkerGridEvery := 5.
	offset := 0 @ 0
]

{ #category : #accessing }
GraphPaperParameters >> offset [
	"Answer the value of offset"

	^ offset
]

{ #category : #accessing }
GraphPaperParameters >> offset: anObject [
	"Set the value of offset."

	offset := anObject
]

{ #category : #accessing }
GraphPaperParameters >> printOn: aStream [
	"Print the receiver on a stream."

	aStream nextPutAll: ('GraphPaperParameters, offset = ', offset printString, ' gridEvery =', gridEvery printString, ' alsoShowDarkerGrid: ',  showDarkerGridAlso printString).
	showDarkerGridAlso ifTrue:
		[aStream nextPutAll: ' darkerGridEvery: ',  darkerGridEvery printString]
]

{ #category : #accessing }
GraphPaperParameters >> showDarkerGridAlso [
	"Answer the value of showDarkerGridAlso"

	^ showDarkerGridAlso
]

{ #category : #accessing }
GraphPaperParameters >> showDarkerGridAlso: anObject [
	"Set the value of showDarkerGridAlso"

	showDarkerGridAlso := anObject
]
