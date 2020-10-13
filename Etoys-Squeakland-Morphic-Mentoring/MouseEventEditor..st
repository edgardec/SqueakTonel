"
A nascent graphical editor for the mouse events constituting a mouse-event sequence.  This is just a beginning -- there is no UI yet for propagating the results of edits back to the originating mouse-event sequence.
"
Class {
	#name : #MouseEventEditor,
	#superclass : #PasteUpMorph,
	#instVars : [
		'mouseEventSequenceMorph'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #initialization }
MouseEventEditor >> discRepresentingEvent: evt index: anIndex [
	"Answer a disk to represent the given event."

	| aMorph |
	aMorph := MouseEventToken new.
	aMorph index: anIndex event: evt.
	^ aMorph
]

{ #category : #initialization }
MouseEventEditor >> initializeFor: aMouseEventSequenceMorph forEventRoll: aRoll [
	"Initialize the receiver as an editor for the given mouse-event-sequence and event-roll."

	| aTheatre aMorph |
	self color: (Color green muchLighter alpha: 0.7).
	aTheatre := aRoll eventTheatre.
	mouseEventSequenceMorph := aMouseEventSequenceMorph.
	self extent: aTheatre initialContentArea extent.
	self setNameTo: 'mouse event editor'.
	mouseEventSequenceMorph events doWithIndex:
		[:evt :index |
			aMorph := self discRepresentingEvent: evt index: index.
			aMorph center: evt position - aTheatre initialContentArea topLeft.
			self addMorphFront: aMorph]
]

{ #category : #'drag and drop' }
MouseEventEditor >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph."

	^ aMorph isWorldMorph "only into worlds"
]
