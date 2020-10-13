"
This class represents the base for all events.

Instance variables:
	stamp	<Integer>	The millisecond clock time stamp (based on Time millisecondClock)
	source	<Hand | nil>	If non-nil the hand that generated the event.
"
Class {
	#name : #MorphicEvent,
	#superclass : #Object,
	#instVars : [
		'timeStamp',
		'source'
	],
	#category : #'Morphic-Events'
}

{ #category : #'instance creation' }
MorphicEvent class >> convertObsolete: anEvent [
	"ar 10/25/2000: This method is used to convert OLD MorphicEvents into new ones."
	| type cursorPoint buttons keyValue sourceHand |
	type := anEvent type.
	cursorPoint := anEvent cursorPoint.
	buttons := anEvent buttons.
	keyValue := anEvent keyValue.
	sourceHand := anEvent hand.
	type == #mouseMove ifTrue:[
		^MouseMoveEvent new
			setType: #mouseMove 
			startPoint: cursorPoint
			endPoint: cursorPoint
			trail: #() 
			buttons: buttons 
			hand: sourceHand 
			stamp: nil].
	(type == #mouseDown) | (type == #mouseUp) ifTrue:[
			^MouseButtonEvent new
				setType: type
				position: cursorPoint
				which: 0
				buttons: buttons
				hand: sourceHand
				stamp: nil].
	(type == #keystroke) | (type == #keyDown) | (type == #keyUp) ifTrue:[
		^KeyboardEvent new
			setType: type
			buttons: buttons
			position: cursorPoint
			keyValue: keyValue
			hand: sourceHand
			stamp: nil].
	^nil
]

{ #category : #'instance creation' }
MorphicEvent class >> readFrom: aStream [
	"Read a MorphicEvent from the given stream."
	| typeString |
	typeString := String streamContents:
		[:s | | c |   [(c := aStream next) isLetter] whileTrue: [s nextPut: c]].
	typeString = 'mouseMove' ifTrue:[^MouseMoveEvent type: #mouseMove readFrom: aStream].
	typeString = 'mouseDown' ifTrue:[^MouseButtonEvent type: #mouseDown readFrom: aStream].
	typeString = 'mouseUp' ifTrue:[^MouseButtonEvent type: #mouseUp readFrom: aStream].
	typeString = 'mouseWheel' ifTrue:[^MouseWheelEvent type: #mouseWheel readFrom: aStream].

	typeString = 'keystroke' ifTrue:[^KeyboardEvent type: #keystroke readFrom: aStream].
	typeString = 'keyDown' ifTrue:[^KeyboardEvent type: #keyDown readFrom: aStream].
	typeString = 'keyUp' ifTrue:[^KeyboardEvent type: #keyUp readFrom: aStream].

	typeString = 'mouseOver' ifTrue:[^MouseEvent type: #mouseOver readFrom: aStream].
	typeString = 'mouseEnter' ifTrue:[^MouseEvent type: #mouseEnter readFrom: aStream].
	typeString = 'mouseLeave' ifTrue:[^MouseEvent type: #mouseLeave readFrom: aStream].

	typeString = 'unknown' ifTrue:[^MorphicUnknownEvent type: #unknown readFrom: aStream].

	^nil

]

{ #category : #'instance creation' }
MorphicEvent class >> readFromObsolete: aStream [
	"Read one of those old and now obsolete events from the stream"
	| type x y buttons keyValue typeString |
	typeString := String streamContents:
		[:s | | c |   [(c := aStream next) isLetter] whileTrue: [s nextPut: c]].
	typeString = 'mouseMove'
		ifTrue: [type := #mouseMove  "fast treatment of common case"]
		ifFalse: [type := typeString asSymbol].

	x := Integer readFrom: aStream.
	aStream skip: 1.
	y := Integer readFrom: aStream.
	aStream skip: 1.

	buttons := Integer readFrom: aStream.
	aStream skip: 1.

	keyValue := Integer readFrom: aStream.

	typeString = 'mouseMove' ifTrue:[
		^MouseMoveEvent new
			setType: #mouseMove 
			startPoint: x@y 
			endPoint: x@y 
			trail: #() 
			buttons: buttons 
			hand: nil 
			stamp: nil].
	(typeString = 'mouseDown') | (typeString = 'mouseUp') ifTrue:[
			^MouseButtonEvent new
				setType: type
				position: x@y
				which: 0
				buttons: buttons
				hand: nil
				stamp: nil].
	(typeString = 'keystroke') | (typeString = 'keyDown') | (typeString = 'keyUp') ifTrue:[
		^KeyboardEvent new
			setType: type
			buttons: buttons
			position: x@y
			keyValue: keyValue
			hand: nil
			stamp: nil].

	^nil
]

{ #category : #'instance creation' }
MorphicEvent class >> type: eventType readFrom: aStream [
	^self new type: eventType readFrom: aStream
]

{ #category : #comparing }
MorphicEvent >> = anEvent [
	anEvent isMorphicEvent ifFalse:[^false].
	^self type = anEvent type
]

{ #category : #initialize }
MorphicEvent >> becomeActiveDuring: aBlock [
	"Make the receiver the active event during the evaluation of aBlock."

	^ ActiveEventVariable value: self during: aBlock
]

{ #category : #'object fileIn' }
MorphicEvent >> convertOctober2000: varDict using: smartRefStrm [
	"ar 10/25/2000: This method is used to convert OLD MorphicEvents into new ones."
	"These are going away #('type' 'cursorPoint' 'buttons' 'keyValue' 'sourceHand').  Possibly store their info in another variable?"
	| type cursorPoint buttons keyValue sourceHand |
	type := varDict at: 'type'.
	cursorPoint := varDict at: 'cursorPoint'.
	buttons := varDict at: 'buttons'.
	keyValue := varDict at: 'keyValue'.
	sourceHand := varDict at: 'sourceHand'.
	type == #mouseMove ifTrue:[
		^MouseMoveEvent new
			setType: #mouseMove 
			startPoint: cursorPoint
			endPoint: cursorPoint
			trail: #() 
			buttons: buttons 
			hand: sourceHand 
			stamp: nil].
	(type == #mouseDown) | (type == #mouseUp) ifTrue:[
			^MouseButtonEvent new
				setType: type
				position: cursorPoint
				which: 0
				buttons: buttons
				hand: sourceHand
				stamp: nil].
	(type == #keystroke) | (type == #keyDown) | (type == #keyUp) ifTrue:[
		^KeyboardEvent new
			setType: type
			buttons: buttons
			position: cursorPoint
			keyValue: keyValue
			hand: sourceHand
			stamp: nil].
	"All others will be handled there"
	^MorphicUnknownEvent new
]

{ #category : #'objects from disk' }
MorphicEvent >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	

	"ar 10/25/2000: This method is used to convert OLD MorphicEvents into new ones."
	varDict at: 'cursorPoint' ifPresent: [ :x | | answer | 
		answer := self convertOctober2000: varDict using: smartRefStrm.
		varDict removeKey: 'cursorPoint'.	"avoid doing this again"
		^answer
	].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.



]

{ #category : #initialize }
MorphicEvent >> copyHandlerState: anEvent [
	"Copy the handler state from anEvent. Used for quickly transferring handler information between transformed events."

]

{ #category : #accessing }
MorphicEvent >> cursorPoint [
	"Backward compatibility. Use #position instead"
	^ self position
]

{ #category : #accessing }
MorphicEvent >> hand [
	"Return the source that generated the event"
	^source
]

{ #category : #comparing }
MorphicEvent >> hash [
	^self type hash
]

{ #category : #dispatching }
MorphicEvent >> ignore [

	self wasIgnored: true.
]

{ #category : #testing }
MorphicEvent >> isDraggingEvent [
	^false
]

{ #category : #testing }
MorphicEvent >> isDropEvent [
	^false
]

{ #category : #testing }
MorphicEvent >> isKeyboard [
	^false
]

{ #category : #testing }
MorphicEvent >> isKeystroke [
	^false
]

{ #category : #testing }
MorphicEvent >> isMorphicEvent [
	^true
]

{ #category : #testing }
MorphicEvent >> isMouse [
	^false
]

{ #category : #testing }
MorphicEvent >> isMouseOver [
	^self type == #mouseOver
]

{ #category : #testing }
MorphicEvent >> isWindowEvent [
	^false
]

{ #category : #accessing }
MorphicEvent >> position [
	"Since cursorPoint is defined and refers to position it should be defined
	here as well"
	^ self subclassResponsibility
]

{ #category : #initialize }
MorphicEvent >> resetHandlerFields [
	"Reset anything that is used to cross-communicate between two eventual handlers during event dispatch"
]

{ #category : #dispatching }
MorphicEvent >> sentTo: anObject [
	"Dispatch the receiver into anObject"
	^anObject handleUnknownEvent: self
]

{ #category : #private }
MorphicEvent >> setHand: aHand [
	source := aHand
]

{ #category : #private }
MorphicEvent >> setTimeStamp: stamp [
	timeStamp := stamp.
]

{ #category : #accessing }
MorphicEvent >> timeStamp [
	"Return the millisecond clock value at which the event was generated"
	^timeStamp ifNil:[timeStamp := Sensor eventTimeNow]
]

{ #category : #transforming }
MorphicEvent >> transformedBy: aMorphicTransform [
	"Return the receiver transformed by the given transform into a local coordinate system."

]

{ #category : #transforming }
MorphicEvent >> translateTo: point [

]

{ #category : #accessing }
MorphicEvent >> type [
	"Return a symbol indicating the type this event."
	^self subclassResponsibility
]

{ #category : #initialize }
MorphicEvent >> type: eventType readFrom: aStream [
	"Read a MorphicEvent from the given stream."

]

{ #category : #accessing }
MorphicEvent >> wasHandled [
	"Return true if this event was handled. May be ignored for some types of events."
	^false
]

{ #category : #accessing }
MorphicEvent >> wasHandled: aBool [
	"Determine if this event was handled. May be ignored for some types of events."
]

{ #category : #accessing }
MorphicEvent >> wasIgnored [
	^ false
]

{ #category : #accessing }
MorphicEvent >> wasIgnored: boolean [

]
