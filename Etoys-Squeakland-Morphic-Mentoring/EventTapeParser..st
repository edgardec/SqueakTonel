"
Preliminary, exploratory!  Given a raw eventTape created by the EventRecorder, parse it into a new tape in which coherent mouse sequences are factored into higher-order events.
"
Class {
	#name : #EventTapeParser,
	#superclass : #Object,
	#instVars : [
		'eventTape',
		'newTape',
		'currentMouseSequence',
		'currentKeyboardSequence'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #services }
EventTapeParser class >> executableEventTapeFromCompactTape: aCompactEventTape [
	"Formulate a full fresh event tape from the given compact event tape."

	| allEvents |
	allEvents := Array streamContents:
		[:aStream |
			aCompactEventTape do:
				[:anEvent |
					anEvent expandOnto: aStream]].
	^allEvents sort: [:a :b | a timeStamp < b timeStamp]
]

{ #category : #accessing }
EventTapeParser >> ambientTrack [
	"Answer an array of MouseEpisodeEvents characterizing the mouse track."

	^ newTape reject: [:p | p isKindOf: EventSequence orOf: KeyboardEventMorph]
]

{ #category : #accessing }
EventTapeParser >> concludeCurrentKeyboardSequence [
	"If I have a keyboard sequence abuilding, finish it off.  This path not currently in use; for the moment we are only cherry-picking keystroke events."

	currentKeyboardSequence ifNil: [^ self].
	currentKeyboardSequence sequenceComplete.
	newTape add: currentKeyboardSequence.
	currentKeyboardSequence := nil
]

{ #category : #accessing }
EventTapeParser >> concludeCurrentMouseSequence [
	"If I have a mouse sequence abuilding, finish it off."

	currentMouseSequence ifNil: [^ self].
	currentMouseSequence sequenceComplete.
	newTape add: currentMouseSequence.
	currentMouseSequence := nil
]

{ #category : #accessing }
EventTapeParser >> eventTape: anObject [
	"Set the value of eventTape"

	eventTape := anObject
]

{ #category : #accessing }
EventTapeParser >> keyboardTrack [
	"Answer an array of KeyboardeEventSequences characterizing the keyboard track."

	self parseTape.
	^ Array streamContents: [:aStream |
		newTape do:
			[:anEvent | anEvent addKeystrokeEventsTo: aStream]]
]

{ #category : #accessing }
EventTapeParser >> mouseTrack [
	"Answer an array of MouseEpisodeEvents characterizing the mouse track."

	self parseTape.
	^ newTape select: [:p | p isKindOf: MouseEventSequence]
]

{ #category : #accessing }
EventTapeParser >> newTape [
	"Answer the value of newTape"

	^ newTape
]

{ #category : #accessing }
EventTapeParser >> parseTape [
	"Parse the existing event-tape into a new tape of higher-level events."

	| itsType  |
	newTape := OrderedCollection new.
	currentMouseSequence := nil.
	currentKeyboardSequence := nil.
	eventTape do:
		[:anEvent | anEvent isMouse
			ifTrue:
				[(itsType := anEvent type) = #mouseDown
					ifTrue:
						[self concludeCurrentMouseSequence.
						self startNewMouseSequenceWith: anEvent]
					ifFalse:
						[itsType = #mouseUp
							ifTrue:
								[currentMouseSequence
									ifNil:
										[Transcript cr; show:  'no mouse seq']
									ifNotNil:
										[currentMouseSequence addEvent: anEvent.
										self concludeCurrentMouseSequence]]
							ifFalse:
								[currentMouseSequence
									ifNil:
										[self startNewMouseSequenceWith: anEvent]
									ifNotNil:
										[currentMouseSequence addEvent: anEvent]]]]
			ifFalse:
				[(anEvent isKeyboard not or: [anEvent type = #keystroke])
					ifTrue:
						[newTape add: anEvent]]]

]

{ #category : #accessing }
EventTapeParser >> startNewKeyboardSequenceWith: anEvent [
	"Start a new currentKeyboardeSequence, using the event provided as the first event in it.  Not currently in use... for the moment we only cherry-pick keystroke events.  Thus this method presently has no senders."

	currentKeyboardSequence := KeyboardEventSequence new.
	currentKeyboardSequence startTime: anEvent timeStamp.
	currentKeyboardSequence addEvent: anEvent
]

{ #category : #accessing }
EventTapeParser >> startNewMouseSequenceWith: anEvent [
	"Start a new currentMouseSequence, using the event provided as the first event in it"

	currentMouseSequence := MouseEventSequence new.
	currentMouseSequence startTime: anEvent timeStamp.
	currentMouseSequence addEvent: anEvent
]
