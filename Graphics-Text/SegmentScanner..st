"
A SegmentScanner is a CompositionScanner specialized for composing TextOnCurve.

"
Class {
	#name : #SegmentScanner,
	#superclass : #CompositionScanner,
	#pools : [
		'TextConstants'
	],
	#category : #'Graphics-Text'
}

{ #category : #private }
SegmentScanner >> setStopConditions [
	"Set the font and the stop conditions for the current run."
	
	self setFont.
	stopConditions := DefaultStopConditions
]
