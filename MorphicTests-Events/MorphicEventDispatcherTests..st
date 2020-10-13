Class {
	#name : #MorphicEventDispatcherTests,
	#superclass : #UserInputEventTests,
	#category : #'MorphicTests-Events'
}

{ #category : #tests }
MorphicEventDispatcherTests >> test01EventBubbling [

	| m1 m2 m3 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	self assert: m3 eventsDuringBubble isEmpty.
	self assert: m2 eventsDuringBubble isEmpty.
	self assert: m1 eventsDuringBubble isEmpty.
	
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: (m3 eventsDuringBubble anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m2 eventsDuringBubble anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:ea | ea isMouseDown]).
]

{ #category : #tests }
MorphicEventDispatcherTests >> test02EventCapturing [

	| m1 m2 m3 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	self assert: m3 eventsDuringCapture isEmpty.
	self assert: m2 eventsDuringCapture isEmpty.
	self assert: m1 eventsDuringCapture isEmpty.
	
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: (m3 eventsDuringCapture anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m2 eventsDuringCapture anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m1 eventsDuringCapture anySatisfy: [:ea | ea isMouseDown]).
]

{ #category : #tests }
MorphicEventDispatcherTests >> test03EventRejecting [

	| m1 m2 m3 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m2 lock. "to reject events"
	m1 openInWorld: world.

	self assert: m2 eventsRejected isEmpty.

	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: (m2 eventsRejected anySatisfy: [:ea | ea isMouseDown]).
	self assert: m2 eventsDuringBubble isEmpty.
	self assert: m2 eventsDuringCapture notEmpty.

	self assert: m1 eventsRejected isEmpty.
	self assert: m1 eventsDuringBubble notEmpty.
	self assert: m1 eventsDuringCapture notEmpty.

	self assert: m3 eventsRejected isEmpty.
	self assert: m3 eventsDuringBubble isEmpty.
	self assert: m3 eventsDuringCapture isEmpty.
]

{ #category : #tests }
MorphicEventDispatcherTests >> test04OverlappingSiblings [
	"Only one of two overlapping siblings gets the event."
	
	| m1 m2 m3 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m1 addMorph: m3.

	m2 bounds: m3 bounds. "full overlap"

	m1 openInWorld: world.

	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: (m3 eventsDuringBubble anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m2 eventsDuringBubble isEmpty).
	
	self assert: (m3 eventsDuringCapture anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m2 eventsDuringCapture isEmpty).
]

{ #category : #tests }
MorphicEventDispatcherTests >> test05FocusEventBubbling [

	| m1 m2 m3 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.

	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	self assert: m3 eventsDuringBubble isEmpty.
	self assert: m2 eventsDuringBubble isEmpty.
	self assert: m1 eventsDuringBubble isEmpty.
	
	hand newMouseFocus: m2. "Not m3! Due to focus, m3 is not considered during capturing/bubbling phase."
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: m3 eventsDuringBubble isEmpty.
	self assert: (m2 eventsDuringBubble anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:ea | ea isMouseDown]).	
	
	hand newKeyboardFocus: m2.
	hand handleEvent: (self keystroke: $x at: m3 center).

	self assert: m3 eventsDuringBubble isEmpty.
	self assert: (m2 eventsDuringBubble anySatisfy: [:ea | ea isKeystroke]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:ea | ea isKeystroke]).
	
]

{ #category : #tests }
MorphicEventDispatcherTests >> test06FocusEventCapturing [
	"There is no capturing phase for focus events."

	| m1 m2 m3 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	self assert: m3 eventsDuringCapture isEmpty.
	self assert: m2 eventsDuringCapture isEmpty.
	self assert: m1 eventsDuringCapture isEmpty.

	hand newMouseFocus: m2. "Not m3! Due to focus, m3 is not considered during capturing/bubbling phase."
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: m3 eventsDuringCapture isEmpty.
	self assert: m2 eventsDuringCapture isEmpty.
	self assert: m1 eventsDuringCapture isEmpty.
	
	hand newKeyboardFocus: m2.
	hand handleEvent: (self keystroke: $x at: m3 center).

	self assert: m3 eventsDuringCapture isEmpty.
	self assert: m2 eventsDuringCapture isEmpty.
	self assert: m1 eventsDuringCapture isEmpty.
]

{ #category : #tests }
MorphicEventDispatcherTests >> test07EventNoBubbling [
	"There is no bubbling if no morph handles the event."
	
	| m1 m2 m3 |
	m1 := MorphForEventTests new noMouseDown.
	m2 := MorphForEventTests new noMouseDown.
	m3 := MorphForEventTests new noMouseDown.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	self assert: m3 eventsDuringBubble isEmpty.
	self assert: m2 eventsDuringBubble isEmpty.
	self assert: m1 eventsDuringBubble isEmpty.
	
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: (m3 eventsDuringBubble noneSatisfy: [:ea | ea isMouseDown]).
	self assert: (m2 eventsDuringBubble noneSatisfy: [:ea | ea isMouseDown]).
	self assert: (m1 eventsDuringBubble noneSatisfy: [:ea | ea isMouseDown]).
]

{ #category : #tests }
MorphicEventDispatcherTests >> test08FocusEventBubblingNoHand [
	"If you drag something, do not bubble up to the hand."
	
	| m1 |
	m1 := MorphForEventTests new noMouseDown.
	hand grabMorph: m1.

	hand newKeyboardFocus: m1.

	self assert: (hand eventsDuringBubble noneSatisfy: [:ea | ea isKeystroke]).
	self assert: (m1 eventsDuringBubble noneSatisfy: [:ea | ea isKeystroke]).
	
	self
		shouldnt: [hand handleEventSilently: (self keystroke: $x at: 0@0)]
		raise: Error.
	
	self assert: (hand eventsDuringBubble noneSatisfy: [:ea | ea isKeystroke]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:ea | ea isKeystroke]).

]

{ #category : #tests }
MorphicEventDispatcherTests >> test09FocusEventCapturingNoHand [
	"Avoid duplication of capture step in hand for focus events."
	
	| m1 |
	m1 := MorphForEventTests new noMouseDown.
	hand grabMorph: m1.

	hand newKeyboardFocus: m1.

	self assert: (hand eventsDuringCapture noneSatisfy: [:ea | ea isKeystroke]).
	self assert: (m1 eventsDuringCapture noneSatisfy: [:ea | ea isKeystroke]).
	
	hand handleEventSilently: (self keystroke: $x at: 0@0).
	
	self assert: (hand eventsDuringCapture noneSatisfy: [:ea | ea isKeystroke]).
	self assert: (m1 eventsDuringCapture noneSatisfy: [:ea | ea isKeystroke]).
]

{ #category : #tests }
MorphicEventDispatcherTests >> test10NoDuplicateKeyStroke [
	"Verifies that the event bubbling mechanism does not send keystroke events twice after the event was handled, as usual, by a morph."
	
	| m1 m2 m3 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	self assert: m3 keyStrokesReceived isEmpty.
	self assert: m2 keyStrokesReceived isEmpty.
	self assert: m1 keyStrokesReceived isEmpty.
	
	hand handleEvent: (self keystroke: $x at: m3 center).

	self assert: (m3 eventsDuringBubble anySatisfy: [:ea | ea isKeystroke]).
	self assert: (m2 eventsDuringBubble anySatisfy: [:ea | ea isKeystroke]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:ea | ea isKeystroke]).
	
	self assert: m3 keyStrokesReceived first keyCharacter = $x.
	self assert: m2 keyStrokesReceived isEmpty.
	self assert: m1 keyStrokesReceived isEmpty.

]

{ #category : #tests }
MorphicEventDispatcherTests >> test11FocusEventReject [
	"If a morph with mouse focus or keyboard focus rejects the event, that focus should be cleared."

	| m1 m2 |
	m1 := MorphForEventTests new.	
	m1 fullFocusDispatch: false.
	m1 on: #mouseDown send: #hide to: m1.
	m1 on: #keyStroke send: #hide to: m1.
	m1 openInWorld: world.

	hand newMouseFocus: m1.
	hand handleEvent: (self redMouseDownAt: m1 center).
	self assert: hand mouseFocus isNil.
	
	hand newKeyboardFocus: m1.
	hand handleEvent: (self keystroke: $x at: m1 center).
	self assert: hand keyboardFocus isNil.
	
	m2 := MorphForEventTests new.
	m2 bounds: m1 bounds.
	m1 addMorph: m2.
	m1 fullFocusDispatch: true.
	
	hand newMouseFocus: m1.
	hand handleEvent: (self redMouseDownAt: m2 center).
	self assert: hand mouseFocus isNil.
	
	hand newKeyboardFocus: m2.
	hand handleEvent: (self keystroke: $x at: m2 center).
	self assert: hand keyboardFocus isNil.

]

{ #category : #tests }
MorphicEventDispatcherTests >> test12CustomEventDispatcher [
	"Each morph can choose to use a custom event dispatcher."

	| m1 m2 |
	m1 := MorphForEventTests new.
	m1 eventDispatcher: MorphicEventDispatcherForEventTests new.

	m2 := MorphForEventTests new.
	m2 eventDispatcher: MorphicEventDispatcherForEventTests new.

	m2 bounds: m1 bounds.
	m1 addMorph: m2. "full overlap"

	m1 openInWorld: world.

	self deny: (m1 eventDispatcher eventsSeen anySatisfy: [:ea | ea isMouseDown]).
	self deny: (m2 eventDispatcher eventsSeen anySatisfy: [:ea | ea isMouseDown]).
	
	hand handleEvent: (self redMouseDownAt: m2 center).

	self assert: (m1 eventDispatcher eventsSeen anySatisfy: [:ea | ea isMouseDown]).
	self assert: (m2 eventDispatcher eventsSeen anySatisfy: [:ea | ea isMouseDown]).
]
