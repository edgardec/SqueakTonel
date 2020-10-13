"
An input sensor which scales just like the display.
"
Class {
	#name : #OLPCVirtualSensor,
	#superclass : #EventSensor,
	#category : #'Etoys-OLPC-Display'
}

{ #category : #accessing }
OLPCVirtualSensor >> primGetNextEvent: array [
	| scale offset |
	super primGetNextEvent: array.
	Display isVirtualScreen ifFalse: [^self].
	"scale mouse events"
	(array at: 1) = EventTypeMouse ifTrue:[
		offset := Display displayOffset.
		scale := Display displayScale.
		array at: 3 put: ((array at: 3) - offset x * scale) truncated.
		array at: 4 put: ((array at: 4) - offset y * scale) truncated.
	].
	(array at: 1) = EventTypeDragDropFiles ifTrue:[
		scale := Display displayScale.
		offset := Display displayOffset.
		array at: 4 put: ((array at: 4) - offset x * scale) truncated.
		array at: 5 put: ((array at: 5) - offset y * scale) truncated.
	].
]
