Class {
	#name : #KeyboardBuffer,
	#superclass : #Object,
	#instVars : [
		'event',
		'eventUsed'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #testing }
KeyboardBuffer >> commandKeyPressed [
	^ event commandKeyPressed
]

{ #category : #testing }
KeyboardBuffer >> controlKeyPressed [
	^ event controlKeyPressed
]

{ #category : #'as yet unclassified' }
KeyboardBuffer >> flushKeyboard [
	eventUsed ifFalse: [^ eventUsed := true].
]

{ #category : #'as yet unclassified' }
KeyboardBuffer >> keyboard [
	eventUsed ifFalse: [eventUsed := true.  ^ event keyCharacter].
	^ nil
]

{ #category : #'as yet unclassified' }
KeyboardBuffer >> keyboardPeek [
	eventUsed ifFalse: [^ event keyCharacter].
	^ nil
]

{ #category : #testing }
KeyboardBuffer >> keyboardPressed [
	^eventUsed not
]

{ #category : #testing }
KeyboardBuffer >> leftShiftDown [
	^ event shiftPressed
]

{ #category : #'as yet unclassified' }
KeyboardBuffer >> startingEvent: evt [
	event := evt.
	eventUsed := false
]
