"
A thumbnail that serves as the value readout for a player-valued slot in a Viewer.  Clicking on it allows the user to select a new object for the slot to point to. 
"
Class {
	#name : #PlayerReferenceReadout,
	#superclass : #ThumbnailMorph,
	#instVars : [
		'putSelector'
	],
	#category : #'Etoys-Scripting Support'
}

{ #category : #'event handling' }
PlayerReferenceReadout >> handlesMouseDown: evt [
	"Allow the user to respecify this by direct clicking"
	^ true
]

{ #category : #accessing }
PlayerReferenceReadout >> isEtoyReadout [
	"Answer whether the receiver can serve as an etoy readout"

	^ true
]

{ #category : #'event handling' }
PlayerReferenceReadout >> mouseDown: evt [ 
	"Allow the user to respecify this by direct clicking"

	| aMorph |
	(putSelector == #unused or: [putSelector isNil]) ifTrue: [^self].
	Sensor waitNoButton.
	aMorph := self world chooseClickTarget.
	aMorph ifNil: [^self].
	objectToView perform: putSelector with: aMorph assuredPlayer.
	self changed
]

{ #category : #initialization }
PlayerReferenceReadout >> objectToView: objectOrNil viewSelector: aSelector putSelector: aPutSelector [
	self objectToView: objectOrNil viewSelector: aSelector.
	putSelector := aPutSelector
]

{ #category : #initialization }
PlayerReferenceReadout >> putSelector [
	"Answer the putSelector"

	^ putSelector
]

{ #category : #initialization }
PlayerReferenceReadout >> putSelector: aSel [
	"Reset the putSelector"

	self objectToView: objectToView viewSelector: viewSelector putSelector: aSel
]

{ #category : #accessing }
PlayerReferenceReadout >> target [
	"Answer the object on which I act"

	^ objectToView
]
