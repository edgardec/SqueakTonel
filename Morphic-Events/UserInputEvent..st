Class {
	#name : #UserInputEvent,
	#superclass : #MorphicEvent,
	#instVars : [
		'type',
		'buttons',
		'position',
		'handler',
		'wasHandled',
		'wasIgnored'
	],
	#pools : [
		'EventSensorConstants'
	],
	#category : #'Morphic-Events'
}

{ #category : #'modifier state' }
UserInputEvent >> anyModifierKeyPressed [
	"ignore, however, the shift keys 'cause that's not REALLY a command key "

	^ self buttons anyMask: 16r70	"cmd | opt | ctrl"
]

{ #category : #printing }
UserInputEvent >> buttonString [
	"Return a string identifying the currently pressed buttons"
	| string |
	string := ''.
	self redButtonPressed ifTrue:[string := string,'red '].
	self yellowButtonPressed ifTrue:[string := string,'yellow '].
	self blueButtonPressed ifTrue:[string := string,'blue '].
	^string
]

{ #category : #accessing }
UserInputEvent >> buttons [
	"Return the a word encoding the mouse and modifier buttons for this event."

	^ buttons
]

{ #category : #'modifier state' }
UserInputEvent >> commandKeyPressed [
	"Answer true if the command key on the keyboard was being held down when this event occurred."

	^ buttons anyMask: 64
]

{ #category : #'modifier state' }
UserInputEvent >> controlKeyPressed [
	"Answer true if the control key on the keyboard was being held down when this event occurred."

	^ buttons anyMask: 16
]

{ #category : #initialize }
UserInputEvent >> copyHandlerState: anEvent [
	"Copy the handler state from anEvent. Used for quickly transferring handler information between transformed events."
	handler := anEvent handler.
	wasHandled := anEvent wasHandled.
]

{ #category : #accessing }
UserInputEvent >> handler [
	^handler
]

{ #category : #accessing }
UserInputEvent >> handler: anObject [
	handler := anObject
]

{ #category : #initialize }
UserInputEvent >> initialize [

	super initialize.
	wasIgnored := false.
]

{ #category : #printing }
UserInputEvent >> modifierString [
	"Return a string identifying the currently pressed modifiers"
	| string |
	string := ''.
	self commandKeyPressed ifTrue:[string := string,'CMD '].
	self shiftPressed ifTrue:[string := string,'SHIFT '].
	self controlKeyPressed ifTrue:[string := string,'CTRL '].
	^string
]

{ #category : #accessing }
UserInputEvent >> position [
	^position
]

{ #category : #initialize }
UserInputEvent >> resetHandlerFields [
	"Reset anything that is used to cross-communicate between two eventual handlers during event dispatch"
	handler := nil.
	wasHandled := false.
]

{ #category : #private }
UserInputEvent >> setPosition: aPoint [
	position := aPoint
]

{ #category : #'modifier state' }
UserInputEvent >> shiftPressed [
	"Answer true if the shift key on the keyboard was being held down when this event occurred."

	^ buttons anyMask: 8

]

{ #category : #transforming }
UserInputEvent >> transformBy: aMorphicTransform [
	"Transform the receiver into a local coordinate system."
	position :=  aMorphicTransform globalPointToLocal: position.
]

{ #category : #transforming }
UserInputEvent >> transformedBy: aMorphicTransform [
	"Return the receiver transformed by the given transform into a local coordinate system."
	^self shallowCopy transformBy: aMorphicTransform
]

{ #category : #transforming }
UserInputEvent >> translateBy: delta [
	"add delta to cursorPoint, and return the new event"
	position := position + delta.
]

{ #category : #transforming }
UserInputEvent >> translateTo: point [

	position := point.
]

{ #category : #transforming }
UserInputEvent >> translatedBy: delta [
	"add delta to cursorPoint, and return the new event"
	^self shallowCopy translateBy: delta
]

{ #category : #accessing }
UserInputEvent >> type [
	"Return a symbol indicating the type this event."

	^ type
]

{ #category : #accessing }
UserInputEvent >> wasHandled [
	^wasHandled
]

{ #category : #accessing }
UserInputEvent >> wasHandled: aBool [
	wasHandled := aBool.
]

{ #category : #accessing }
UserInputEvent >> wasIgnored [
	^ wasIgnored == true
]

{ #category : #accessing }
UserInputEvent >> wasIgnored: aBoolean [
	wasIgnored := aBoolean.
]
