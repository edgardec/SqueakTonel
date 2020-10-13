"
Illustrates the double-click capabilities of Morphic.

If you have a kind of morph you wish to have respond specially to a double-click, it should:

(1)  Respond ""true"" to #handlesMouseDown:

(2)  In its mouseDown: method, send #waitForClicksOrDrag:event: to the hand.

(3)  Reimplement #click: to react to single-clicked mouse-down.

(4)  Reimplement #doubleClick: to make the appropriate response to a double-click.

(5)  Reimplement #drag: to react to non-clicks.  This message is sent continuously until the button is released.  You can check the event argument to react differently on the first, intermediate, and last calls.
"
Class {
	#name : #DoubleClickExample,
	#superclass : #RectangleMorph,
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #'parts bin' }
DoubleClickExample class >> descriptionForPartsBin [
	^ self partName:	'DoubleClick' translatedNoop
		categories:		#()
		documentation:	'An example of how to use double-click in moprhic' translatedNoop
]

{ #category : #accessing }
DoubleClickExample >> balloonText [
	^ 'Double-click on me to change my color; 
single-click on me to change border color;
hold mouse down within me and then move it to grow 
(if I''m red) or shrink (if I''m blue).' translated

]

{ #category : #'event handling' }
DoubleClickExample >> click: evt [
	self showBalloon: 'click' hand: evt hand.
	self borderColor: (self borderColor = Color black ifTrue: [Color yellow] ifFalse: [Color black])

]

{ #category : #initialization }
DoubleClickExample >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color red
]

{ #category : #'event handling' }
DoubleClickExample >> doubleClick: evt [
	self showBalloon: 'doubleClick' hand: evt hand.
	self color: ((color = Color blue) ifTrue: [Color red] ifFalse: [Color blue])

]

{ #category : #'event handling' }
DoubleClickExample >> handlesMouseDown: evt [
	^ true
]

{ #category : #'event handling' }
DoubleClickExample >> mouseDown: evt [
	"Do nothing upon mouse-down except inform the hand to watch for a double-click; wait until an ensuing click:, doubleClick:, or drag: message gets dispatched"

	evt hand waitForClicksOrDrag: self event: evt
]

{ #category : #'event handling' }
DoubleClickExample >> startDrag: evt [
	"We'll get a mouseDown first, some mouseMoves, and a mouseUp event last"
	| oldCenter |
	evt isMouseDown ifTrue:
		[self showBalloon: 'drag (mouse down)' hand: evt hand.
		self world displayWorld.
		(Delay forMilliseconds: 750) wait].
	evt isMouseUp ifTrue:
		[self showBalloon: 'drag (mouse up)' hand: evt hand].
	(evt isMouseUp or: [evt isMouseDown]) ifFalse:
		[self showBalloon: 'drag (mouse still down)' hand: evt hand].
	(self containsPoint: evt cursorPoint)
		ifFalse: [^ self].

	oldCenter := self center.
	color = Color red
		ifTrue:
			[self extent: self extent + (1@1)]
		ifFalse:
			[self extent: ((self extent - (1@1)) max: (16@16))].
	self center: oldCenter
]
