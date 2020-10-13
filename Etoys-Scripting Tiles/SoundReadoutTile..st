"
A tile comprising a readout for a sound-valued instance variable in a Viewer.  It sports up/down  arrows, and a click on the sound name results in a pop-up menu, offering the user the opportunity to choose a new one.
"
Class {
	#name : #SoundReadoutTile,
	#superclass : #StringReadoutTile,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #arrows }
SoundReadoutTile >> arrowAction: delta [
	"Do what is appropriate when an arrow on the tile is pressed; delta will be +1 or -1"

	| soundChoices index |
	soundChoices := self soundChoices.
	index := soundChoices indexOf: literal.
	self literal: (soundChoices atWrap: (index + delta)).
	self playSoundNamed: literal
]

{ #category : #arrows }
SoundReadoutTile >> handlerForMouseDown: anEvent [
	"Return the (prospective) handler for a mouse down event. The handler is temporarily installed and can be used for morphs further down the hierarchy to negotiate whether the inner or the outer morph should finally handle the event"

	^ ((self findA: UpdatingStringMorph) bounds containsPoint: anEvent cursorPoint)
		ifTrue:
			[self]
		ifFalse:
			[super handlerForMouseDown: anEvent]
]

{ #category : #arrows }
SoundReadoutTile >> mouseDown: evt [
	"Handle a mouse down event"

	| aPoint index isUp soundChoices adjustment |
	upArrow ifNotNil: [((isUp := upArrow containsPoint: (aPoint := evt cursorPoint)) or:  [downArrow containsPoint: aPoint])
		ifTrue:
			[soundChoices := self soundChoices.
			index := soundChoices indexOf: literal ifAbsent: [1].
			index > 0 ifTrue:
				[adjustment := isUp ifTrue: [1] ifFalse: [-1].
				self literal: (soundChoices atWrap: (index + adjustment))].
			self playSoundNamed: literal.
			^ self]].
	self soundNameFromUser ifNotNil:
		[:aSoundName |
			self literal: aSoundName.
			self playSoundNamed: literal]
]

{ #category : #arrows }
SoundReadoutTile >> setLiteral: aLiteral [
	super  setLiteral: aLiteral.
	(self findA: UpdatingStringMorph) useSymbolFormat; lock
]

{ #category : #literal }
SoundReadoutTile >> setLiteralTo: anObject width: w [
	"Set the literal and width of the tile as indicated"

	| soundChoices index |
	soundChoices := self soundChoices.
	index := soundChoices indexOf: anObject.
	self setLiteral: (soundChoices atWrap: index)
]

{ #category : #arrows }
SoundReadoutTile >> soundNameFromUser [
	"Obtain a sound from the user.  Exclude the items designated as being discouraged, except that if the current selection is one of those, show it anyway"

	| choices |
	choices := self soundChoices.
	^ UIManager default 
		chooseFrom: (choices collect: [:t | t translated]) 
		values: self soundChoices
		title: 'Sounds' translated
]

{ #category : #private }
SoundReadoutTile >> updateLiteralLabel [
	"Update the wording emblazoned on the tile, if needed"

	super updateLiteralLabel.
	(self findA: UpdatingStringMorph) useSymbolFormat; lock
]
