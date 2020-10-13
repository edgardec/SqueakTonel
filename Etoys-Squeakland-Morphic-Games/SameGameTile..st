"
I am a single tile for the SameGame.  I act much like a switch.
"
Class {
	#name : #SameGameTile,
	#superclass : #SimpleSwitchMorph,
	#instVars : [
		'switchState',
		'disabled',
		'oldSwitchState'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
SameGameTile class >> includeInNewMorphMenu [

	^false
]

{ #category : #accessing }
SameGameTile >> color: aColor [ 
	super color: aColor.
	self borderColor: aColor.
	onColor := aColor.
	offColor := aColor.
	self changed
]

{ #category : #accessing }
SameGameTile >> disabled [

	^ disabled
]

{ #category : #accessing }
SameGameTile >> disabled: aBoolean [

	disabled := aBoolean.
	disabled
		ifTrue:
			[self color: owner color.
			self borderColor: owner color]
		ifFalse:
			[self setSwitchState: self switchState]
]

{ #category : #button }
SameGameTile >> doButtonAction [
	"Perform the action of this button. The last argument of the message sent to the target is the new state of this switch."

	(target notNil and: [actionSelector notNil]) 
		ifTrue: 
			[target perform: actionSelector
				withArguments: (arguments copyWith: switchState)]
]

{ #category : #initialization }
SameGameTile >> initialize [

	super initialize.
	self label: ''.
	self borderWidth: 2.
	bounds := 0@0 corner: 16@16.
	offColor := Color gray.
	onColor := Color gray.
	switchState := false.
	oldSwitchState := false.
	disabled := false.
	self useSquareCorners
	
]

{ #category : #accessing }
SameGameTile >> insetColor [
	"Use my own color for insets"
	^color
]

{ #category : #'event handling' }
SameGameTile >> mouseDown: evt [

	disabled ifFalse:
		[oldSwitchState := switchState.
		self setSwitchState: (oldSwitchState = false).
		self doButtonAction].

]

{ #category : #'event handling' }
SameGameTile >> mouseMove: evt [

	"don't do anything, here"
]

{ #category : #'event handling' }
SameGameTile >> mouseUp: evt [

	"don't do anything, here"
]

{ #category : #accessing }
SameGameTile >> setSwitchState: aBoolean [

	switchState := aBoolean.
	disabled ifFalse:
		[switchState
			ifTrue:
				[self borderInset.
				self color: onColor]
			ifFalse:
				[self borderRaised.
				self color: offColor]]
]

{ #category : #accessing }
SameGameTile >> switchState [

	^ switchState
]
