"
WordGamePanelMorph provides some default support for clicking and typing in a panel with letterMorphs.

letterMorphs		a collection of LetterMorphs
					Useful in referring specifically to active letterMorphs
					when submorphs may contain other morphs

haveTypedHere		a Boolean used to determine how backspace should be handled
"
Class {
	#name : #WordGamePanelMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'letterMorphs',
		'haveTypedHere'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
WordGamePanelMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #menus }
WordGamePanelMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Include our modest command set in the ctrl-menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	self addMenuItemsTo: aCustomMenu hand: aHandMorph
]

{ #category : #menu }
WordGamePanelMorph >> addMenuItemsTo: aCustomMenu hand: aHandMorph [
	"override with actual menu items"
]

{ #category : #events }
WordGamePanelMorph >> checkForLostFocus [
	"Determine if the user has clicked outside this panel"

	self activeHand ifNil: [^ self].
	(self containsPoint: self activeHand position) ifFalse: [self lostFocus]
]

{ #category : #defaults }
WordGamePanelMorph >> clearTyping [
	"Clear out all letters entered as a solution."

	letterMorphs do: [:m | (m letter notNil and: [m letter isLetter])
							ifTrue: [m setLetter: Character space]].
	self unhighlight.

]

{ #category : #'event handling' }
WordGamePanelMorph >> handlesMouseDown: event [
	"Absorb mouseDown so stray clicks will not pick up the panel"

	^ true
]

{ #category : #defaults }
WordGamePanelMorph >> highlight: morph [

	self unhighlight.
	morph color: Color green
]

{ #category : #defaults }
WordGamePanelMorph >> isClean [
	"Return true only if all cells are blank."

	letterMorphs do:
		[:m | (m letter notNil and: [m letter ~= $ ]) ifTrue: [^ false]].
	^ true

]

{ #category : #defaults }
WordGamePanelMorph >> keyCharacter: keyCharacter atIndex: indexOfAffectedMorph nextFocus: nextFocus [

	"Override with actual response"

]

{ #category : #events }
WordGamePanelMorph >> keyStrokeEvent: evt letterMorph: morph [ 
	"Handle typing.  Calls keyCharacter:atIndex:nextFocus: for further behavior."

	| affectedMorph keyCharacter nextFocus |
	evt keyCharacter = Character backspace 
		ifTrue: 
			["<delete> zaps the current selection if there has been no typing,
				but it zaps the previous selection if there has been prior typing."

			affectedMorph := haveTypedHere 
						ifTrue: [morph previousTypeableLetter]
						ifFalse: [morph]. 
			keyCharacter := Character space.
			nextFocus := morph previousTypeableLetter]
		ifFalse: 
			[affectedMorph := morph.
			keyCharacter := evt keyCharacter asUppercase.
			(keyCharacter isLetter or: [keyCharacter = Character space]) 
				ifFalse: [^self].
			haveTypedHere := true.
			nextFocus := morph nextTypeableLetter.
			nextFocus == morph 
				ifTrue: 
					["If hit end of a word, change backspace mode"

					haveTypedHere := false]].
	evt hand newKeyboardFocus: nextFocus.
	self unhighlight.
	nextFocus color: Color green.
	self 
		keyCharacter: keyCharacter
		atIndex: affectedMorph indexInQuote
		nextFocus: nextFocus
]

{ #category : #access }
WordGamePanelMorph >> letterMorphs [

	^ letterMorphs
]

{ #category : #defaults }
WordGamePanelMorph >> lostFocus [

	self unhighlight
]

{ #category : #events }
WordGamePanelMorph >> mouseDownEvent: evt letterMorph: morph [

	haveTypedHere := false.
	evt hand newKeyboardFocus: morph.
	self highlight: morph
]

{ #category : #defaults }
WordGamePanelMorph >> unhighlight [

	letterMorphs do: [:m | m ifNotNil: [m unhighlight]]

]
