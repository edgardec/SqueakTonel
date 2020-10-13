Class {
	#name : #DropEvent,
	#superclass : #MorphicEvent,
	#instVars : [
		'position',
		'contents',
		'wasHandled'
	],
	#category : #'Morphic-Events'
}

{ #category : #accessing }
DropEvent >> contents [
	^contents
]

{ #category : #initialize }
DropEvent >> copyHandlerState: anEvent [
	"Copy the handler state from anEvent. Used for quickly transferring handler information between transformed events."
	wasHandled := anEvent wasHandled.
]

{ #category : #accessing }
DropEvent >> cursorPoint [
	"For compatibility with mouse events"
	^position
]

{ #category : #testing }
DropEvent >> isDropEvent [
	^true
]

{ #category : #accessing }
DropEvent >> position [
	^position
]

{ #category : #printing }
DropEvent >> printOn: aStream [

	aStream nextPut: $[.
	aStream nextPutAll: self position printString; space.
	aStream nextPutAll: self type.
	aStream nextPut: $].
]

{ #category : #initialize }
DropEvent >> resetHandlerFields [
	"Reset anything that is used to cross-communicate between two eventual handlers during event dispatch"
	wasHandled := false.
]

{ #category : #dispatching }
DropEvent >> sentTo: anObject [
	"Dispatch the receiver into anObject"
	self type == #dropEvent ifTrue:[^anObject handleDropMorph: self].
]

{ #category : #private }
DropEvent >> setPosition: pos contents: aMorph hand: aHand [
	position := pos.
	contents := aMorph.
	source := aHand.
	wasHandled := false.
]

{ #category : #transforming }
DropEvent >> transformBy: aMorphicTransform [
	"Transform the receiver into a local coordinate system."
	position :=  aMorphicTransform globalPointToLocal: position.
]

{ #category : #transforming }
DropEvent >> transformedBy: aMorphicTransform [
	"Return the receiver transformed by the given transform into a local coordinate system."
	^self shallowCopy transformBy: aMorphicTransform
]

{ #category : #transforming }
DropEvent >> translateTo: point [

	position := point.
]

{ #category : #accessing }
DropEvent >> type [
	^#dropEvent
]

{ #category : #accessing }
DropEvent >> wasHandled [
	^wasHandled
]

{ #category : #accessing }
DropEvent >> wasHandled: aBool [
	wasHandled := aBool.
]
