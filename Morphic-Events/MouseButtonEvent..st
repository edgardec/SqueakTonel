Class {
	#name : #MouseButtonEvent,
	#superclass : #MouseEvent,
	#instVars : [
		'whichButton',
		'nClicks'
	],
	#category : #'Morphic-Events'
}

{ #category : #accessing }
MouseButtonEvent >> blueButtonChanged [
	"Answer true if the blue mouse button has changed. This is the third mouse button or cmd+click on the Mac."

	^ whichButton anyMask: 1
]

{ #category : #accessing }
MouseButtonEvent >> nClicks [
	^nClicks ifNil: [0]
]

{ #category : #accessing }
MouseButtonEvent >> nClicks: n [
	nClicks := n
]

{ #category : #printing }
MouseButtonEvent >> printOn: aStream [

	aStream nextPut: $[.
	aStream nextPutAll: self cursorPoint printString; space.
	aStream nextPutAll: type; space.
	aStream nextPutAll: self modifierString.
	aStream nextPutAll: self buttonString.
	aStream nextPutAll: self whichButtonString; space.
	aStream nextPutAll: timeStamp printString.
	aStream nextPut: $].
]

{ #category : #accessing }
MouseButtonEvent >> redButtonChanged [
	"Answer true if the red mouse button has changed. This is the first mouse button."

	^ whichButton anyMask: 4
]

{ #category : #dispatching }
MouseButtonEvent >> sentTo: anObject [
	"Dispatch the receiver into anObject"
	type == #mouseDown ifTrue:[^anObject handleMouseDown: self].
	type == #mouseUp ifTrue:[^anObject handleMouseUp: self].
	^super sentTo: anObject
]

{ #category : #private }
MouseButtonEvent >> setType: evtType position: evtPos which: button buttons: evtButtons hand: evtHand stamp: stamp [
	type := evtType.
	position := evtPos.
	buttons := evtButtons.
	source := evtHand.
	wasHandled := false.
	whichButton := button.
	timeStamp := stamp.
]

{ #category : #private }
MouseButtonEvent >> setType: evtType position: evtPos which: button buttons: evtButtons nClicks: numClicks  hand: evtHand stamp: stamp [
	type := evtType.
	position := evtPos.
	buttons := evtButtons.
	nClicks := numClicks.
	source := evtHand.
	wasHandled := false.
	whichButton := button.
	timeStamp := stamp
]

{ #category : #printing }
MouseButtonEvent >> storeOn: aStream [
	super storeOn: aStream.
	aStream space.
	whichButton storeOn: aStream.
]

{ #category : #initialize }
MouseButtonEvent >> type: eventType readFrom: aStream [
	super type: eventType readFrom: aStream.
	aStream skip: 1.
	whichButton := Integer readFrom: aStream.
]

{ #category : #accessing }
MouseButtonEvent >> whichButton [
	^whichButton
]

{ #category : #printing }
MouseButtonEvent >> whichButtonString [
	"Return a string identifying the changed buttons"
	
	^ String streamContents: [:stream |
		stream nextPutAll: '( '.
		self redButtonChanged ifTrue: [stream nextPutAll: 'red '].
		self yellowButtonChanged ifTrue: [stream nextPutAll: 'yellow '].
		self blueButtonChanged ifTrue: [stream nextPutAll: 'blue '].
		stream nextPutAll: ')']
]

{ #category : #accessing }
MouseButtonEvent >> yellowButtonChanged [
	"Answer true if the yellow mouse button has changed. This is the second mouse button or option+click on the Mac."

	^ whichButton anyMask: 2
]
