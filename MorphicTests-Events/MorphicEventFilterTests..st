Class {
	#name : #MorphicEventFilterTests,
	#superclass : #UserInputEventTests,
	#category : #'MorphicTests-Events'
}

{ #category : #tests }
MorphicEventFilterTests >> test01EventBubbleFilter [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := MorphForEventTests new.

	m1 addEventBubbleFilter: filter.
	m2 addEventBubbleFilter: filter.
	m3 addEventBubbleFilter: filter.
	
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: {m3.m2.m1} equals: (filter eventsFiltered select: [:ea | ea key isMouseDown] thenCollect: [:ea | ea value]) asArray.
]

{ #category : #tests }
MorphicEventFilterTests >> test02EventCaptureFilter [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := MorphForEventTests new.

	m1 addEventCaptureFilter: filter.
	m2 addEventCaptureFilter: filter.
	m3 addEventCaptureFilter: filter.
	
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: {m1.m2.m3} equals: (filter eventsFiltered select: [:ea | ea key isMouseDown] thenCollect: [:ea | ea value]) asArray.
]

{ #category : #tests }
MorphicEventFilterTests >> test03FocusEventBubbleFilter [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := MorphForEventTests new.

	m1 addEventBubbleFilter: filter.
	m2 addEventBubbleFilter: filter.
	m3 addEventBubbleFilter: filter.

	hand newMouseFocus: m2.	
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: {m2.m1} equals: (filter eventsFiltered select: [:ea | ea key isMouseDown] thenCollect: [:ea | ea value]) asArray.
]

{ #category : #tests }
MorphicEventFilterTests >> test04FocusEventCaptureFilter [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := MorphForEventTests new.

	m1 addEventCaptureFilter: filter.
	m2 addEventCaptureFilter: filter.
	m3 addEventCaptureFilter: filter.

	hand newMouseFocus: m2.	
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: {m1.m2} equals: (filter eventsFiltered select: [:ea | ea key isMouseDown] thenCollect: [:ea | ea value]) asArray.
]

{ #category : #tests }
MorphicEventFilterTests >> test05IgnoreEvent [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := PluggableEventFilter on: [:event | event ignore].

	m1 addEventCaptureFilter: filter.

	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: m1 eventsDuringBubble isEmpty.
	self assert: m2 eventsDuringBubble isEmpty.
	self assert: m3 eventsDuringBubble isEmpty.

	self assert: m1 eventsDuringCapture notEmpty.
	self assert: m2 eventsDuringCapture isEmpty.
	self assert: m3 eventsDuringCapture isEmpty.
]

{ #category : #tests }
MorphicEventFilterTests >> test06IgnoreFocusEvent [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := PluggableEventFilter on: [:event | event ignore].

	m1 addEventCaptureFilter: filter.

	hand newMouseFocus: m3.
	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: m1 eventsDuringBubble isEmpty.
	self assert: m2 eventsDuringBubble isEmpty.
	self assert: m3 eventsDuringBubble isEmpty.

	self assert: m1 eventsDuringCapture isEmpty.
	self assert: m2 eventsDuringCapture isEmpty.
	self assert: m3 eventsDuringCapture isEmpty.
]

{ #category : #tests }
MorphicEventFilterTests >> test07TransformEvent [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := PluggableEventFilter on: [:event | self keystroke: $x at: m3 center].
	m2 addEventCaptureFilter: filter.

	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: (m1 eventsDuringCapture anySatisfy: [:evt | evt isMouseDown]).
	self assert: (m2 eventsDuringCapture anySatisfy: [:evt | evt isMouseDown]).
	self assert: (m3 eventsDuringCapture anySatisfy: [:evt | evt isKeystroke]).
	
	self assert: (m3 eventsDuringBubble anySatisfy: [:evt | evt isKeystroke]).
	self assert: (m2 eventsDuringBubble anySatisfy: [:evt | evt isKeystroke]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:evt | evt isKeystroke]).

]

{ #category : #tests }
MorphicEventFilterTests >> test08TransformEventAgain [

	| m1 m2 m3 filter |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := PluggableEventFilter on: [:event | self keystroke: $x at: m3 center].
	m2 addEventBubbleFilter: filter.

	hand handleEvent: (self redMouseDownAt: m3 center).

	self assert: (m1 eventsDuringCapture anySatisfy: [:evt | evt isMouseDown]).
	self assert: (m2 eventsDuringCapture anySatisfy: [:evt | evt isMouseDown]).
	self assert: (m3 eventsDuringCapture anySatisfy: [:evt | evt isMouseDown]).
	
	self assert: (m3 eventsDuringBubble anySatisfy: [:evt | evt isMouseDown]).
	self assert: (m2 eventsDuringBubble anySatisfy: [:evt | evt isMouseDown]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:evt | evt isKeystroke]).

]

{ #category : #tests }
MorphicEventFilterTests >> test09KeyboardShortcut [

	| m1 m2 m3 filter hit |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	m3 := MorphForEventTests new.
	
	m1 addMorph: m2.
	m2 addMorph: m3.
	
	m1 openInWorld: world.

	filter := PluggableEventFilter on: [:event | 
		hit := false.
		(event isKeystroke and: [event keyCharacter = $x]) ifTrue: [
			hit := true.
			event ignore].
		event].
	
	m1 addKeyboardCaptureFilter: filter.

	hand handleEvent: (self keystroke: $x at: m3 center).

	self assert: hit.

	self assert: (m1 eventsDuringCapture anySatisfy: [:evt | evt isKeystroke]).
	self assert: (m2 eventsDuringCapture noneSatisfy: [:evt | evt isKeystroke]).
	self assert: (m3 eventsDuringCapture noneSatisfy: [:evt | evt isKeystroke]).
	
	self assert: (m3 eventsDuringBubble noneSatisfy: [:evt | evt isKeystroke]).
	self assert: (m2 eventsDuringBubble noneSatisfy: [:evt | evt isKeystroke]).
	self assert: (m1 eventsDuringBubble noneSatisfy: [:evt | evt isKeystroke]).

	m1 eventsDuringCapture removeAll.
	hand handleEvent: (self keystroke: $o at: m3 center).

	self deny: hit.

	self assert: (m1 eventsDuringCapture anySatisfy: [:evt | evt isKeystroke]).
	self assert: (m2 eventsDuringCapture anySatisfy: [:evt | evt isKeystroke]).
	self assert: (m3 eventsDuringCapture anySatisfy: [:evt | evt isKeystroke]).
	
	self assert: (m3 eventsDuringBubble anySatisfy: [:evt | evt isKeystroke]).
	self assert: (m2 eventsDuringBubble anySatisfy: [:evt | evt isKeystroke]).
	self assert: (m1 eventsDuringBubble anySatisfy: [:evt | evt isKeystroke]).




]
