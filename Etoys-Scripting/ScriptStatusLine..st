Class {
	#name : #ScriptStatusLine,
	#superclass : #AlignmentMorph,
	#category : #'Etoys-Scripting'
}

{ #category : #'event handling' }
ScriptStatusLine >> wantsKeyboardFocusFor: aSubmorph [
	"No thanks"

	^ false
]
