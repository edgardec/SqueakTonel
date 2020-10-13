"
I represent a controller that never wants control. I am the controller for views that are non-interactive.
"
Class {
	#name : #NoController,
	#superclass : #Controller,
	#category : #'ST80-Framework'
}

{ #category : #'control defaults' }
NoController >> isControlActive [ 
	"Refer to the comment in Controller|isControlActive."

	^false
]

{ #category : #'control defaults' }
NoController >> isControlWanted [ 
	"Refer to the comment in Controller|isControlWanted."

	^false
]

{ #category : #'basic control sequence' }
NoController >> startUp [
	"I do nothing."

	^self
]
