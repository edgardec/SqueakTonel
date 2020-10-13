"
An abstract superclass for KeyboardEventMorph, MediaEventMorph, and MouseEventSequenceMorph.  These are morphs used on an EventRoll to represent events on an event tape. 
"
Class {
	#name : #EventMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'event'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #'drag and drop' }
EventMorph >> brownDragConcluded [
	"After the user has manually repositioned the receiver via brown-halo-drag, this is invoked."

	self currentWorld abandonAllHalos.
	self eventRoll ifNotNil:
		[:evtRoll | evtRoll pushChangesBackToEventTheatre]
]

{ #category : #accessing }
EventMorph >> event: anObject [
	"Set the value of event."

	event := anObject
]

{ #category : #accessing }
EventMorph >> eventTheatre [
	"Answer the event-theatre associated with the receiver, nil if none.  This is only well-defined if the receiver resides within an EventRoll."

	^ self eventRoll ifNotNil:
		[self eventRoll eventTheatre]
]

{ #category : #initialization }
EventMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self borderWidth: 0
]

{ #category : #'drag and drop' }
EventMorph >> justDroppedInto: aMorph event: anEvent [
	"The receiver was just dropped somewhere..."

	| aFormerOwner |
	aFormerOwner := self formerOwner ifNil: [^ self].
	aMorph == aFormerOwner ifTrue: [^ self].
	(aFormerOwner isKindOf: EventTimeline)
		ifTrue:
			[aFormerOwner eventRoll ifNotNil: [:r | r pushChangesBackToEventTheatre.
			self formerOwner: nil] ].  "NB only do this once!"
]

{ #category : #'event roll' }
EventMorph >> putEventsOnto: aStream [
	"Write all of the events represented by the receiver onto the given stream.  This generic implementation, usable by everything except the EventSequenceMorphs, puts a single event, one-for-one, onto the stream; the event differs from the receiver's own event in that its timeStamp is appropriately transformed."

	| newEvent aTimeStamp |
	newEvent := event veryDeepCopy.
	aTimeStamp := self eventRoll timeStampForCurrentPositionOf: self.
	newEvent timeStamp: aTimeStamp.
	aStream nextPut: newEvent
]

{ #category : #'drag and drop' }
EventMorph >> suitableForDroppingIntoEventRoll [
	"Answer whether the receiver is suitable for dropping into an Event Roll."

	^ true
]
