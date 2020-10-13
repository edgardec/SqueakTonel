"
I represent a Controller that takes control if a key on the keyboard is depressed or if the cursor is within my rectangular area.
"
Class {
	#name : #FormMenuController,
	#superclass : #Controller,
	#category : #'ST80-Editors'
}

{ #category : #'control defaults' }
FormMenuController >> controlActivity [
	"Pass control to a subView corresponding to a pressed keyboard key or to
	a mouse button pressed, if any."

	sensor keyboardPressed
		ifTrue: [self processMenuKey]
		ifFalse: [self controlToNextLevel]
]

{ #category : #'control defaults' }
FormMenuController >> isControlActive [
	"Answer false if the blue mouse button is pressed and the cursor is
	outside of the inset display box of the Controller's view; answer true,
	otherwise."

	^sensor keyboardPressed |
		(view containsPoint: sensor cursorPoint) & sensor blueButtonPressed not
]

{ #category : #'control defaults' }
FormMenuController >> isControlWanted [
	"Answer true if the cursor is inside the inset display box (see 
	View|insetDisplayBox) of the receiver's view, and answer false, 
	otherwise. It is sent by Controller|controlNextLevel in order to determine 
	whether or not control should be passed to this receiver from the
	Controller of the superView of this receiver's view."

	^sensor keyboardPressed | self viewHasCursor
]

{ #category : #'control defaults' }
FormMenuController >> processMenuKey [
	"The user typed a key on the keyboard. Perform the action of the button whose shortcut is that key, if any."

	| aView |
	aView := view subViewContainingCharacter: sensor keyboard.
	aView ~~ nil ifTrue: [aView performAction].

]
