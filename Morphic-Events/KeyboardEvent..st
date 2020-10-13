Class {
	#name : #KeyboardEvent,
	#superclass : #UserInputEvent,
	#instVars : [
		'keyValue'
	],
	#category : #'Morphic-Events'
}

{ #category : #comparing }
KeyboardEvent >> = aMorphicEvent [
	super = aMorphicEvent ifFalse:[^false].
	buttons = aMorphicEvent buttons ifFalse: [^ false].
	keyValue = aMorphicEvent keyValue ifFalse: [^ false].
	^ true

]

{ #category : #comparing }
KeyboardEvent >> hash [
	^buttons hash + keyValue hash

]

{ #category : #testing }
KeyboardEvent >> isKeyDown [
	^self type == #keyDown
]

{ #category : #testing }
KeyboardEvent >> isKeyUp [
	^self type == #keyUp
]

{ #category : #testing }
KeyboardEvent >> isKeyboard [
	^true
]

{ #category : #testing }
KeyboardEvent >> isKeystroke [
	^self type == #keystroke
]

{ #category : #testing }
KeyboardEvent >> isMouseMove [
	^false
]

{ #category : #keyboard }
KeyboardEvent >> keyCharacter [
	"Answer the character corresponding this keystroke. This is defined only for keystroke events."

	^ keyValue asCharacter
]

{ #category : #keyboard }
KeyboardEvent >> keyString [
	"Answer the string value for this keystroke. This is defined only for keystroke events."

	^ String streamContents: [ :s | self printKeyStringOn: s ]
]

{ #category : #keyboard }
KeyboardEvent >> keyValue [
	"Answer the ascii value for this keystroke. This is defined only for keystroke events."

	^ keyValue
]

{ #category : #printing }
KeyboardEvent >> printKeyStringOn: aStream [
	"Print a readable string representing the receiver on a given stream"

	| kc inBrackets firstBracket keyString |
	kc := self keyCharacter.
	inBrackets := false.
	firstBracket := [ inBrackets ifFalse: [ aStream nextPut: $<. inBrackets := true ]].
	self controlKeyPressed ifTrue: [ 	firstBracket value. aStream nextPutAll: 'Ctrl-' ].
	self commandKeyPressed ifTrue: [ firstBracket value. aStream nextPutAll: 'Cmd-' ].
	(buttons anyMask: 32) ifTrue: [ firstBracket value. aStream nextPutAll: 'Opt-' ].
	(self shiftPressed and: [ (keyValue between: 1 and: 31) or: [self keyCharacter = Character delete ]])
		ifTrue: [ firstBracket value. aStream nextPutAll: 'Shift-' ].

	keyString := (kc caseOf: {
		[ Character space ] -> [ 'space' ].
		[ Character tab ] -> [ 'tab' ].
		[ Character cr ] -> [ 'cr' ].
		[ Character lf ] -> [ 'lf' ].
		[ Character enter ] -> [ 'enter' ].

		[ Character backspace ] -> [ 'backspace' ].
		[ Character delete ] -> [ 'delete' ].

		[ Character escape ] -> [ 'escape' ].

		[ Character arrowDown ] -> [ 'down' ].
		[ Character arrowUp ] -> [ 'up' ].
		[ Character arrowLeft ] -> [ 'left' ].
		[ Character arrowRight ] -> [ 'right' ].

		[ Character end ] -> [ 'end' ].
		[ Character home ] -> [ 'home' ].
		[ Character pageDown ] -> [ 'pageDown' ].
		[ Character pageUp ] -> [ 'pageUp' ].

		[ Character euro ] -> [ 'euro' ].
		[ Character insert ] -> [ 'insert' ].

		} otherwise: [ String with: kc ]).
		
	keyString size > 1 ifTrue: [ firstBracket value ].
	aStream nextPutAll: keyString.

	inBrackets ifTrue: [aStream nextPut: $> ]
]

{ #category : #printing }
KeyboardEvent >> printOn: aStream [
	"Print the receiver on a stream"

	aStream nextPut: $[.
	aStream nextPutAll: self cursorPoint printString; space.
	aStream nextPutAll: type; space. 
	
	self isKeystroke ifTrue: [
		aStream nextPutAll: ''''.		
		self printKeyStringOn: aStream.
		aStream nextPut: $'; space].
	
	aStream nextPut: $(.
	aStream nextPutAll: keyValue printString.
	aStream nextPut: $); space.
	
	aStream nextPutAll: timeStamp printString.
	aStream nextPut: $]
]

{ #category : #private }
KeyboardEvent >> scanCode: ignore [
	" OB-Tests expects this "
]

{ #category : #dispatching }
KeyboardEvent >> sentTo: anObject [
	"Dispatch the receiver into anObject"
	type == #keystroke ifTrue:[^anObject handleKeystroke: self].
	type == #keyDown ifTrue:[^anObject handleKeyDown: self].
	type == #keyUp ifTrue:[^anObject handleKeyUp: self].
	^super sentTo: anObject.
]

{ #category : #private }
KeyboardEvent >> setType: aSymbol buttons: anInteger position: pos keyValue: aValue hand: aHand stamp: stamp [
	type := aSymbol.
	buttons := anInteger.
	position := pos.
	keyValue := aValue.
	source := aHand.
	wasHandled := false.
	timeStamp := stamp.
]

{ #category : #printing }
KeyboardEvent >> storeOn: aStream [

	aStream nextPutAll: type.
	aStream space.
	self timeStamp storeOn: aStream.
	aStream space.
	buttons storeOn: aStream.
	aStream space.
	keyValue storeOn: aStream.

]

{ #category : #initialize }
KeyboardEvent >> type: eventType readFrom: aStream [
	type := eventType.
	timeStamp := Integer readFrom: aStream.
	aStream skip: 1.
	buttons := Integer readFrom: aStream.
	aStream skip: 1.
	keyValue := Integer readFrom: aStream.
]
