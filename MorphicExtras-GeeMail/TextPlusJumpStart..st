Class {
	#name : #TextPlusJumpStart,
	#superclass : #TextAction,
	#instVars : [
		'jumpLabel'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'mouse events' }
TextPlusJumpStart >> actOnClickFor: model [
	"Subclasses may override to provide, eg, hot-spot actions"

	model doJumpTo: jumpLabel.
	^ true
]

{ #category : #accessing }
TextPlusJumpStart >> emphasizeScanner: scanner [
	"Set the emphasist for text scanning"
	scanner addEmphasis: 4
]

{ #category : #accessing }
TextPlusJumpStart >> jumpLabel [

	^jumpLabel
]

{ #category : #accessing }
TextPlusJumpStart >> jumpLabel: aString [

	jumpLabel := aString
]
