"
A morph representing a keyboard event.
"
Class {
	#name : #KeyboardEventMorph,
	#superclass : #EventMorph,
	#instVars : [
		'character'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #'menu commands' }
KeyboardEventMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand.  This method provides is invoked both from the halo-menu and from the control-menu regimes."

	aCustomMenu add: 'Change character' translated target: self action: #changeCharacter
]

{ #category : #'menu commands' }
KeyboardEventMorph >> changeCharacter [
	"Allow the user to select a new character for the receiver."

	| result |
	result := FillInTheBlank request: 'New character? ' translated initialAnswer: character asString.
	result isEmptyOrNil ifTrue: [^ self].
	result = character asString ifTrue: [^ self].
	event keyValue: result first asciiValue.
	self eventRoll ifNotNil: [:r | r pushChangesBackToEventTheatre]
]

{ #category : #accessing }
KeyboardEventMorph >> character [
	"Answer the value of character"

	^ character
]

{ #category : #accessing }
KeyboardEventMorph >> character: c [
	"Set the character"

	| aColor |
	character := c.
	aColor := c = Character space
		ifTrue:
			[Color yellow lighter]
		ifFalse:
			[c = Character backspace
				ifTrue:
					[Color blue lighter]
				ifFalse: 
					[(c tokenish or: [c isSpecial])
						ifTrue:
							[self colorFromEvent]
						ifFalse:
							[Color red lighter]]].
	self color: aColor
]

{ #category : #initialization }
KeyboardEventMorph >> colorFromEvent [
	"Answer a color corresponding to my event"

	| aColor |
	aColor := Color white.
	event shiftPressed ifTrue:
		[aColor := aColor mixed: 0.3 with: Color red].
	event commandKeyPressed ifTrue:
		[aColor := aColor mixed: 0.3 with: Color green].
	event controlKeyPressed ifTrue:
		[aColor := aColor mixed: 0.3 with: Color yellow].
	^ aColor
]

{ #category : #initialization }
KeyboardEventMorph >> event: anObject [
	"Set the value of event"

	event := anObject.
	self setColorFromEvent
]

{ #category : #initialization }
KeyboardEventMorph >> initialize [
	"Initialze the receiver."

	super initialize.
	self color: (Color r: 0.0 g: 0.968 b: 0.903)
]

{ #category : #initialization }
KeyboardEventMorph >> setColorFromEvent [
	"Set the receiver's color from the info in the event."

	self color: self colorFromEvent
]
