Class {
	#name : #MorphicEventTests,
	#superclass : #UserInputEventTests,
	#category : #'MorphicTests-Events'
}

{ #category : #tests }
MorphicEventTests >> test01WantsKeyboardFocus [

	| ptm |
	ptm := PluggableTextMorph new.
	ptm setText: 'test01WantsKeyboardFocus'.
	ptm openInWorld: world.
	
	self deny: (ptm hasKeyboardFocus: hand).
	self deny: (ptm textMorph hasKeyboardFocus: hand).
	
	self assert: ptm wantsKeyboardFocus.
	self assert: ptm keyboardFocusDelegate == ptm textMorph.
	
	hand handleEvent: (self redMouseDownAt: ptm center).
	self assert: (ptm hasKeyboardFocus: hand).
	self assert: (ptm textMorph hasKeyboardFocus: hand).

]

{ #category : #tests }
MorphicEventTests >> test02MouseOver [

	| m1 m2 |
	m1 := MorphForEventTests new.
	m2 := MorphForEventTests new.
	
	m1 extent: 20@20; topLeft: 0@0.
	m2 extent: 20@20; topLeft: 40@0.
	
	m1 openInWorld: world.
	m2 openInWorld: world.
	
	hand handleEvent: (self redMouseDownAt: m1 center).
	hand handleEvent: (self redMouseUpAt: m1 center).
	hand handleEvent: (self redMouseDownAt: m2 center).
	hand handleEvent: (self redMouseUpAt: m2 center).
	
	self
		checkEventOrder: #(mouseMove mouseEnter mouseDown mouseUp mouseLeave)
		forEvents: m1 eventsDuringBubble
		ignoreMouseOver: true.	
	
	self
		checkEventOrder: #(mouseMove mouseEnter mouseDown mouseUp)
		forEvents: m2 eventsDuringBubble
		ignoreMouseOver: true.
	
]

{ #category : #tests }
MorphicEventTests >> test03EventHandler [

	| m |
	m := Morph new.
	m extent: 20@20; topLeft: 0@0.

	m wantsHaloFromClick: false.
	m wantsYellowButtonMenu: false.
	m wantsMetaMenu: false.

	m on: #mouseDown send: #value: to:[:evt|
		evt redButtonPressed ifTrue:[m color: Color red].
		evt yellowButtonPressed ifTrue:[m color: Color yellow].
		evt blueButtonPressed ifTrue:[m color: Color blue]]. 

	m openInWorld: world.
	
	hand handleEvent: (self redMouseDownAt: m center).
	self assert: Color red equals: m color.

	hand handleEvent: (self yellowMouseDownAt: m center).
	self assert: Color yellow equals: m color.
	
	hand handleEvent: (self blueMouseDownAt: m center).
	self assert: Color blue equals: m color.
]
