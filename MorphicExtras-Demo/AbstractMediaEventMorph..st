"
An abstract representation of media events to be placed in a PianoRollScoreMorph (or others as they are developed)
"
Class {
	#name : #AbstractMediaEventMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'startTimeInScore',
		'endTimeInScore'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #initialization }
AbstractMediaEventMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
AbstractMediaEventMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color paleYellow
]

{ #category : #accessing }
AbstractMediaEventMorph >> endTime [

	^endTimeInScore ifNil: [startTimeInScore + 100]
]

{ #category : #initialization }
AbstractMediaEventMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self layoutPolicy: TableLayout new;
	  listDirection: #leftToRight;
	  wrapCentering: #topLeft;
	  hResizing: #shrinkWrap;
	  vResizing: #shrinkWrap;
	  layoutInset: 2;
	  rubberBandCells: true
]

{ #category : #'piano rolls' }
AbstractMediaEventMorph >> justDroppedIntoPianoRoll: pianoRoll event: evt [
	
	| ambientEvent |
	startTimeInScore := pianoRoll timeForX: self left.

	ambientEvent := AmbientEvent new 
		morph: self;
		time: startTimeInScore.

	pianoRoll score addAmbientEvent: ambientEvent.

	"self endTime > pianoRoll scorePlayer durationInTicks ifTrue:
		[pianoRoll scorePlayer updateDuration]"

]
