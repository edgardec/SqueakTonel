Class {
	#name : #TextPlusJumpEnd,
	#superclass : #TextAction,
	#instVars : [
		'jumpLabel'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #accessing }
TextPlusJumpEnd >> emphasizeScanner: scanner [

	"none for me, thanks"
]

{ #category : #accessing }
TextPlusJumpEnd >> jumpLabel [

	^jumpLabel
]

{ #category : #accessing }
TextPlusJumpEnd >> jumpLabel: aString [

	jumpLabel := aString
]
