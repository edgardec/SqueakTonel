Class {
	#name : #MouseOverMorph,
	#superclass : #MouseSensorMorph,
	#instVars : [
		'mouseEnterSelector',
		'mouseMoveSelector',
		'mouseLeaveSelector'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #'event handling' }
MouseOverMorph >> handlesMouseOver: evt [ 
	^model notNil
]

{ #category : #'event handling' }
MouseOverMorph >> mouseEnter: event [
	"Relay a mouseEnter event to my model."

	mouseEnterSelector ifNotNil:
		[mouseEnterSelector numArgs = 0
			ifTrue: [^ model perform: mouseEnterSelector].
		mouseEnterSelector numArgs = 1
			ifTrue: [^ model perform: mouseEnterSelector with: event].
		mouseEnterSelector numArgs = 2
			ifTrue: [^ model perform: mouseEnterSelector with: true with: event].
		^ self error: 'mouseEnterselector must take 0, 1, or 2 arguments']
]

{ #category : #'event handling' }
MouseOverMorph >> mouseLeave: event [
	"Relay a mouseLeave event to my model."

	mouseLeaveSelector ifNotNil:
		[mouseLeaveSelector numArgs = 0
			ifTrue: [^ model perform: mouseLeaveSelector].
		mouseLeaveSelector numArgs = 1
			ifTrue: [^ model perform: mouseLeaveSelector with: event].
		^ self error: 'mouseLeaveSelector must take 0, or 1 argument'].

	mouseEnterSelector ifNotNil:
		["Or send mouseEnter: false..."
		mouseEnterSelector numArgs = 2
			ifTrue: [^ model perform: mouseEnterSelector with: false with: event].
		^ self error: 'mouseEnterSelector must take 2 arguments']
]

{ #category : #'event handling' }
MouseOverMorph >> mouseMove: event [
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
