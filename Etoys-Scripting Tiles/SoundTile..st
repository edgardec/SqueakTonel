"
A scripting tile representing a 'sound' constant.  Sounds are represented by their names, which are strings; the actual sounds live in SampleSound's SoundLibrary.
"
Class {
	#name : #SoundTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'mouse handling' }
SoundTile >> handlerForMouseDown: anEvent [
	"Return the (prospective) handler for a mouse down event. The handler is temporarily installed and can be used for morphs further down the hierarchy to negotiate whether the inner or the outer morph should finally handle the event"

	^ ((self findA: UpdatingStringMorph) bounds containsPoint: anEvent cursorPoint)
		ifTrue:
			[self]
		ifFalse:
			[super handlerForMouseDown: anEvent]
]

{ #category : #initialization }
SoundTile >> initialize [
	"Initialize the state of the receiver. Pick the croak sound
	if available, otherwise any sound."
	
	| soundChoices startingSoundName |
	super initialize.
	soundChoices := self soundChoices.
	startingSoundName := (soundChoices includes: 'croak')
							ifTrue: ['croak']
							ifFalse: [[soundChoices anyOne] ifError: ['silence']].
	self addArrows; setLiteral: startingSoundName.
	self labelMorph useSymbolFormat
]

{ #category : #accessing }
SoundTile >> isSoundTile [
	^true
]

{ #category : #'event handling' }
SoundTile >> options [
	"Answer the options of the tile for an arrow"

	| soundChoices |
	soundChoices := self soundChoices.
	^ {soundChoices. soundChoices}
]

{ #category : #accessing }
SoundTile >> resultType [
	"Answer the result type of the receiver"

	^ #Sound
]

{ #category : #initialization }
SoundTile >> setLiteral: anObject [

	super setLiteral: anObject.
	self labelMorph useSymbolFormat

]

{ #category : #access }
SoundTile >> sound [

	^ SoundService default soundNamed: literal

]

{ #category : #'event handling' }
SoundTile >> value: anObject [ 
	super value: anObject.
	self playSoundNamed: anObject
]

{ #category : #'event handling' }
SoundTile >> wantsKeyboardFocusFor: aSubmorph [
	^ false
]
