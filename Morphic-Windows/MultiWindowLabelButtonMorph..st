"
A MultiWindowLabelButtonMorph is  a means of implementing tabbed windows.  It cooperates with PluggableSystemWindowWithButton to provide a drop-down menu of windows when clicking in the window label.  It requires the model to create a suitable sub-instance of SavedMultiWindowState for inactive windows.  To specify multi-windows use the multiWindowStyle: setter to customize a PluggableWindowSpec.

Instance Variables
	savedMultiWindowState:		<SavedMultiWindowState>

savedMultiWindowState
	- the sequence of models in a multi-window.
"
Class {
	#name : #MultiWindowLabelButtonMorph,
	#superclass : #PluggableButtonMorph,
	#instVars : [
		'savedMultiWindowState'
	],
	#category : #'Morphic-Windows'
}

{ #category : #drawing }
MultiWindowLabelButtonMorph >> drawOn: aCanvas [ 
	"Be invisible."
]

{ #category : #accessing }
MultiWindowLabelButtonMorph >> performAction [
	"Override to interpret the actionSelector as a menu accessor and to activate that menu."

	actionSelector ifNil: [^ self]-
	(model perform: actionSelector) ifNotNil: [:menu |
		menu
			invokeModalAt: self position - (0@5)
			in: self currentWorld
			allowKeyboard: Preferences menuKeyboardControl].
]

{ #category : #accessing }
MultiWindowLabelButtonMorph >> savedMultiWindowState [
	"Answer the value of savedMultiWindowState"

	^ savedMultiWindowState
]

{ #category : #accessing }
MultiWindowLabelButtonMorph >> savedMultiWindowState: anObject [
	"Set the value of savedMultiWindowState"

	savedMultiWindowState := anObject
]
