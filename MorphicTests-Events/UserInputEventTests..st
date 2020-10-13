Class {
	#name : #UserInputEventTests,
	#superclass : #TestCase,
	#instVars : [
		'hand',
		'world'
	],
	#category : #'MorphicTests-Events'
}

{ #category : #testing }
UserInputEventTests class >> isAbstract [

	^ self == UserInputEventTests
]

{ #category : #support }
UserInputEventTests >> blueMouseDownAt: point [

	^ MouseButtonEvent new
		setType: #mouseDown
		position: point
		which: 2r000 "no change"
		buttons: 2r001 "blue pressed"
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : #support }
UserInputEventTests >> checkEventOrder: someEventTypes forEvents: someEvents ignoreMouseOver: ignoreMouseOver [
	"Use this to verify the order of events"
	
	((someEvents
		select: [:ea | ea isMouseOver not or: [ignoreMouseOver not]])
		collect: [:ea | ea type])
			with: someEventTypes
			do: [:t1 :t2 | self assert: t2 equals: t1].
		
]

{ #category : #support }
UserInputEventTests >> keystroke: char at: point [

	^ KeyboardEvent new
		setType: #keystroke
		buttons: 0 "no modifiers"
		position: point
		keyValue: char asciiValue
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : #support }
UserInputEventTests >> redMouseDownAt: point [

	^ MouseButtonEvent new
		setType: #mouseDown
		position: point
		which: 2r000 "no change"
		buttons: 2r100 "red/left pressed"
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : #support }
UserInputEventTests >> redMouseUpAt: point [

	^ MouseButtonEvent new
		setType: #mouseUp
		position: point
		which: 2r100 "red/left changed"
		buttons: 2r000 "nothing pressed"
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : #running }
UserInputEventTests >> setUp [

	super setUp.

	world := (PasteUpMorph newWorldForProject: nil)
		extent: 300@200;
		yourself.
		
	hand := HandMorphForEventTests new.
	
	world
		removeHand: world firstHand; "the default hand"
		addHand: hand.
]

{ #category : #running }
UserInputEventTests >> tearDown [

	hand showHardwareCursor: true. "Nasty side-effect"
	super tearDown.
]

{ #category : #support }
UserInputEventTests >> yellowMouseDownAt: point [

	^ MouseButtonEvent new
		setType: #mouseDown
		position: point
		which: 2r000 "no change"
		buttons: 2r010 "yellow pressed"
		hand: hand
		stamp: Time millisecondClockValue
]
