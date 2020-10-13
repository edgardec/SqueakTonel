"
An event sequence consisting of a related series of keyboard events, from a key-down through a key-up.  This is not in current use, since the reporting of keyboard events seems so erratic that we are only gathering keystroke events for the time being.
"
Class {
	#name : #KeyboardEventSequence,
	#superclass : #EventSequence,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #debugging }
KeyboardEventSequence >> addKeystrokeEventsTo: aStream [
	"Add any keystroke event to a stream"

	events do: [:e | e eventType = #keystroke ifTrue:
		[aStream nextPut: e]]
]

{ #category : #debugging }
KeyboardEventSequence >> printOn: aStream [
	"Print the receiver on a stream"

	aStream nextPutAll: self class name, ': duration: ', (self duration printString), 'ms  ', events first type,'$', events first keyValue asCharacter asString, ' -> ', events last type, ' total events ', (events size printString)
]

{ #category : #debugging }
KeyboardEventSequence >> type [
	"Return a symbol indicating the type this event."

	^ #keystroke
]
