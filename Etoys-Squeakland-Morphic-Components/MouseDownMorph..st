Class {
	#name : #MouseDownMorph,
	#superclass : #MouseSensorMorph,
	#instVars : [
		'mouseDownSelector',
		'mouseMoveSelector',
		'mouseUpSelector'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #menu }
MouseDownMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
"template..."
	aCustomMenu addLine.
	aCustomMenu add: 'set variable name...' translated action: #renameMe.
	aCustomMenu addLine.
	aCustomMenu add: 'plug mouseDown to model slot' translated action: #plugMouseDownToSlot.
	aCustomMenu add: 'plug mouseMove to model slot' translated action: #plugMouseMoveToSlot.
	aCustomMenu add: 'plug all to model slots' translated action: #plugAllToSlots.
	aCustomMenu addLine.
	aCustomMenu add: 'plug mouseDown to model' translated action: #plugMouseDownToModel.
	aCustomMenu add: 'plug mouseMove to model' translated action: #plugMouseMoveToModel.
	aCustomMenu add: 'plug all to model' translated action: #plugAllToModel.
	aCustomMenu addLine.
	aCustomMenu add: 'set target...' translated action: #setTarget.
	aCustomMenu add: 'set mouseDown selector...' translated action: #setMouseDownSelector.
	aCustomMenu add: 'set mouseMove selector...' translated action: #setMouseMoveSelector.
	aCustomMenu add: 'set mouseUp selector...' translated action: #setMouseUpSelector.

]

{ #category : #'event handling' }
MouseDownMorph >> handlesMouseDown: evt [ 
	^model notNil
]

{ #category : #'event handling' }
MouseDownMorph >> mouseDown: event [
	"Relay a mouseDown event to my model."

	mouseDownSelector ifNotNil:
		[mouseDownSelector numArgs = 0
			ifTrue: [^ model perform: mouseDownSelector].
		mouseDownSelector numArgs = 1
			ifTrue: [^ model perform: mouseDownSelector with: event].
		mouseDownSelector numArgs = 2
			ifTrue: [^ model perform: mouseDownSelector with: true with: event].
		^ self error: 'mouseDownselector must take 0, 1, or 2 arguments']
]

{ #category : #'event handling' }
MouseDownMorph >> mouseMove: event [
	"Relay a mouseMove event to my model."

	mouseMoveSelector ifNotNil:
		[mouseMoveSelector numArgs = 0
			ifTrue: [^ model perform: mouseMoveSelector].
		mouseMoveSelector numArgs = 1
			ifTrue: [^ model perform: mouseMoveSelector with: event cursorPoint].
		mouseMoveSelector numArgs = 2
			ifTrue: [^ model perform: mouseMoveSelector with: event cursorPoint with: event].
		^ self error: 'mouseMoveSelector must take 0, 1, or 2 arguments']
]

{ #category : #'event handling' }
MouseDownMorph >> mouseUp: event [
	"Relay a mouseUp event to my model."

	mouseUpSelector ifNotNil:
		[mouseUpSelector numArgs = 0
			ifTrue: [^ model perform: mouseUpSelector].
		mouseUpSelector numArgs = 1
			ifTrue: [^ model perform: mouseUpSelector with: event].
		^ self error: 'mouseUpselector must take 0, or 1 argument'].
	mouseDownSelector ifNotNil:
		["Or send mouseDown: false..."
		mouseDownSelector numArgs = 2
			ifTrue: [^ model perform: mouseDownSelector with: false with: event].
		^ self error: 'mouseDownselector must take 2 arguments']
]

{ #category : #menu }
MouseDownMorph >> plugAllToModel [
	self plugMouseDownToModel; plugMouseMoveToSlot
]

{ #category : #menu }
MouseDownMorph >> plugAllToSlots [
	self plugMouseDownToSlot; plugMouseMoveToSlot.

]

{ #category : #menu }
MouseDownMorph >> plugMouseDownToModel [
	mouseDownSelector := (self knownName , 'MouseDown:event:') asSymbol.
	model class compile: (

'&nameMouseDown: trueOrFalse event: event
	"A mouseDown event has occurred.
	Add code to handle it here below..."'

			copyReplaceAll: '&name' with: self knownName)
		classified: 'input events' notifying: nil
]

{ #category : #menu }
MouseDownMorph >> plugMouseDownToSlot [
	| varName |
	mouseDownSelector := (self knownName , 'MouseDown:event:') asSymbol.
	varName := self knownName , 'MouseDown'.
	model class addSlotNamed: varName.
	model class compile: (

'&name: trueOrFalse event: event
	"A mouseDown event has occurred.
	Add code to handle it here below..."
	&name := trueOrFalse.'

			copyReplaceAll: '&name' with: varName)
		classified: 'input events' notifying: nil
]

{ #category : #menu }
MouseDownMorph >> plugMouseMoveToModel [
	mouseMoveSelector := (self knownName , 'MouseMove:event:') asSymbol.
	model class compile: (

'&nameMouseMove: location event: event
	"A mouseMove event has occurred.
	Add code to handle it here below..."'

			copyReplaceAll: '&name' with: self knownName)
		classified: 'input events' notifying: nil
]

{ #category : #menu }
MouseDownMorph >> plugMouseMoveToSlot [
	| varName |
	mouseMoveSelector := (self knownName , 'MouseMove:event:') asSymbol.
	varName := self knownName , 'MouseMove'.
	model class addSlotNamed: varName.
	model class compile: (

'&name: location event: event
	"A mouseMove event has occurred.
	Add code to handle it here below..."
	&name := location.'

			copyReplaceAll: '&name' with: varName)
		classified: 'input events' notifying: nil
]
