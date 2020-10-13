"
My instances are used to save information needed to construct the switch in a menu for a FormEditor. A collection of my instances is stored as a class variable of FormMenuView.
"
Class {
	#name : #FormButtonCache,
	#superclass : #Object,
	#instVars : [
		'offset',
		'form',
		'value',
		'initialState'
	],
	#category : #'ST80-Editors'
}

{ #category : #accessing }
FormButtonCache >> form [
	"Answer the receiver's form, the image of the button on the screen."

	^form
]

{ #category : #accessing }
FormButtonCache >> form: aForm [
	"Set the receiver's form to be the argument."

	form := aForm
]

{ #category : #accessing }
FormButtonCache >> initialState [
	"Answer the receiver's initial state, on or off."

	^initialState
]

{ #category : #accessing }
FormButtonCache >> initialState: aBoolean [
	"Set the receiver's initial state, on or off, to be the argument."

	initialState := aBoolean
]

{ #category : #accessing }
FormButtonCache >> offset [
	"Answer the receiver's offset, its relative position for displaying the 
	button."

	^offset
]

{ #category : #accessing }
FormButtonCache >> offset: anInteger [
	"Set the receiver's offset."

	offset := anInteger
]

{ #category : #accessing }
FormButtonCache >> value [
	"Answer the receiver's value, the keyboard key that selects the button."

	^value
]

{ #category : #accessing }
FormButtonCache >> value: aCharacter [
	"Set the receiver's key character."

	value := aCharacter
]
