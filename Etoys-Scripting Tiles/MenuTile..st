"
A tile representing a menu item
"
Class {
	#name : #MenuTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #arrows }
MenuTile >> arrowAction: delta [
	| phrase aPlayer newItem |
	(phrase := self ownerThatIsA: PhraseTileMorph) ifNil: [^ self].
	aPlayer := phrase associatedPlayer.
	newItem := delta > 0
		ifTrue:
			[aPlayer menuItemAfter: literal]
		ifFalse:
			[aPlayer menuItemBefore: literal].
	self literal: newItem.
	self layoutChanged
]

{ #category : #'events-processing' }
MenuTile >> handlerForMouseDown: anEvent [
	"Don't give anybody over me a chance"
	^self
]

{ #category : #'event handling' }
MenuTile >> handlesMouseDown: evt [
	^ true
]

{ #category : #initialization }
MenuTile >> initialize [
	"Initialize the menu tile"

	super initialize.
	self addArrows; setLiteral: 'send to back' translated.
	self labelMorph useStringFormat; putSelector: nil
]

{ #category : #'events-processing' }
MenuTile >> mouseDownPriority [
	^100
]

{ #category : #'event handling' }
MenuTile >> mouseUp: evt [
	| aPoint reply choices |
	aPoint := evt cursorPoint.
	nArrowTicks := 0.
	((upArrow bounds containsPoint: aPoint) or: [downArrow bounds containsPoint: aPoint]) ifTrue: [^ self mouseStillDown: evt].
	choices := ((self ownerThatIsA: PhraseTileMorph) associatedPlayer costume allMenuWordings) copyWithout: ''.
	reply := UIManager default chooseFrom: choices values: choices.
	reply ifNotNil: [self literal: reply; layoutChanged]
]

{ #category : #accessing }
MenuTile >> resultType [
	"Answer the result type of the receiver"

	^ #Menu
]
