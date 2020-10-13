"
I am a Switch that turns off automatically after being turned on, that is, I act like a push-button switch.
"
Class {
	#name : #Button,
	#superclass : #Switch,
	#category : #'ST80-Menus'
}

{ #category : #'instance creation' }
Button class >> newOn [ 
	"Refer to the comment in Switch|newOn."

	self error: 'Buttons cannot be created in the on state'.
	^nil
]

{ #category : #state }
Button >> turnOff [
	"Sets the state of the receiver to 'off'. The off action of the receiver is not  
	executed."

	on := false
]

{ #category : #state }
Button >> turnOn [
	"The receiver remains in the 'off' state'."

	self doAction: onAction.
	self doAction: offAction
]
