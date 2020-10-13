"
ObjectViewers offers the same kind of interception of messages (via doesnotUnderstand:) as ObjectTracers, but instead of just being wrappers, they actually replace the object being viewed.  This makes them a lot more dangerous to use, but one can do amazing things.  For instance, the example below actually intercepts the EventSensor object, and prints the mouse coordinates asynchronously, every time they change:
	Sensor evaluate: [Sensor cursorPoint printString displayAt: 0@0]
		wheneverChangeIn: [Sensor cursorPoint].
To exit from this example, execute:
	Sensor xxxUnTrace

"
Class {
	#name : #ObjectViewer,
	#superclass : #ObjectTracer,
	#instVars : [
		'valueBlock',
		'lastValue',
		'changeBlock'
	],
	#category : #'Kernel-Objects'
}

{ #category : #'very few messages' }
ObjectViewer >> doesNotUnderstand: aMessage [ 
	"Check for change after sending aMessage"
	| returnValue newValue |
	recursionFlag ifTrue: [^ aMessage sendTo: tracedObject].
	recursionFlag := true.
	returnValue := aMessage sendTo: tracedObject.
	newValue := valueBlock cull: aMessage.
	newValue = lastValue ifFalse:
		[changeBlock cull: aMessage.
		lastValue := newValue].
	recursionFlag := false.
	^ returnValue
]

{ #category : #'very few messages' }
ObjectViewer >> xxxViewedObject: viewedObject evaluate: block1 wheneverChangeIn: block2 [
	"This message name must not clash with any other (natch)."
	tracedObject := viewedObject.
	valueBlock := block2.
	changeBlock := block1.
	recursionFlag := false
]
