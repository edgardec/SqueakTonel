"
A morph representing a related sequence of mouse events.
"
Class {
	#name : #MouseEventSequenceMorph,
	#superclass : #EventMorph,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #menu }
MouseEventSequenceMorph >> addCustomMenuItems: aMenu hand: aHand [
	"Add morph-specific items to the given menu which was invoked by the given hand."

	super addCustomMenuItems: aMenu hand: aHand.
	aMenu addLine.
	aMenu addTranslatedList: #(
		( 'graphical view'	openExpandedView 'Lets you visualize all the individual events that constitute this sequence in an onionskin overlay to the event theatre.')
		('textual view' openTextualView 'Presents the constituent events of this sequence in a scrolling list for your inspection.')) translatedNoop
]

{ #category : #accessing }
MouseEventSequenceMorph >> durationInMilliseconds [
	"Answer the duration in milliseconds"

	^ event durationInMilliseconds
]

{ #category : #accessing }
MouseEventSequenceMorph >> events [
	"Answer the actual events comprising the receiver.  My direct 'event' is a contrived MouseEventSequenceEvent; this method reaches into that sequence event and retrieves its constituent native events."

	^ event events
]

{ #category : #processing }
MouseEventSequenceMorph >> growConcluded [
	"After the user has manually resized the receiver, via its halo, this is called."

	| leftTime rightTime newSpan oldSpan ratio  baseline |
	self eventRoll ifNotNil: [:roll |
		leftTime :=roll timeStampForCurrentPositionOf: self.
		rightTime :=  roll timeStampForRightEdgeOf: self.
		oldSpan := event duration.
		newSpan := rightTime  - leftTime.
		ratio := newSpan asFloat / oldSpan.
		newSpan ~= oldSpan
			ifTrue:
				[baseline := event events first timeStamp.
				event events do:
					[:evt | evt timeStamp:
						(baseline + (((evt timeStamp - baseline) * ratio)))].
				event  startTime: event events first timeStamp.
				event stopTime: event events last timeStamp.
				roll pushChangesBackToEventTheatre]
			ifFalse:
				[^ self]]
]

{ #category : #menu }
MouseEventSequenceMorph >> openExpandedView [
	"Open an editor allowing the actual events constituting the receiver to be visualized and edited."

	| anEditor roll |
	anEditor := MouseEventEditor new.
	(roll := self eventRoll) ifNil: [Beeper beep.  ^ self flash].

	anEditor initializeFor: self forEventRoll: roll.
	anEditor bounds: roll eventTheatre contentArea bounds.
	anEditor openInWorld
]

{ #category : #menu }
MouseEventSequenceMorph >> openExpandedView: evt [
	"The user double-clicked on me; open a derivative editor for my interior,  However, for the double-click is disabled and we require the user to pop up the halo menu for me to get at the expanded-view commands.  Thus, for the moment, this method has no senders."

	| aMorph anEditor roll |

	 (roll := self eventRoll) ifNil: [^ Beeper beep].

	evt shiftPressed ifFalse: 
		[anEditor := MouseEventEditor new.
		anEditor initializeFor: self forEventRoll: roll.
		anEditor bounds: roll eventTheatre contentArea bounds.
		^ anEditor openInWorld].

	aMorph := TextualEventSequenceDisplayer new.
	aMorph mouseEventSequenceMorph: self.
	aMorph openInHand
]

{ #category : #menu }
MouseEventSequenceMorph >> openTextualView [
	"Open a textual view of the events in the receiver."

	| aMorph |
	aMorph := TextualEventSequenceDisplayer new.
	aMorph mouseEventSequenceMorph: self.
	aMorph openInHand
]

{ #category : #processing }
MouseEventSequenceMorph >> putEventsOnto: aStream [
	"Write all of the events represented by the receiver in its current state onto the given stream."

	| newEvent aTimeStamp itsStartTime |
	itsStartTime := event events first timeStamp.
	event events do:
		[:evt |
			newEvent := evt veryDeepCopy.
			aTimeStamp := self eventRoll timeStampForCurrentPositionOf: self.
			newEvent timeStamp: (aTimeStamp + (evt timeStamp - itsStartTime)).
			aStream nextPut: newEvent]
]
