"
I am a textMorph used as a pop-up editor for StringMorphs.  I present a yellow background and I go away when a CR is typed or when the user clicks elsewhere.
"
Class {
	#name : #StringMorphEditor,
	#superclass : #TextMorph,
	#category : #'Morphic-Text Support'
}

{ #category : #'new-morph participation' }
StringMorphEditor class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #drawing }
StringMorphEditor >> drawOn: aCanvas [

	aCanvas fillRectangle: self bounds color: Color yellow muchLighter.
	^ super drawOn: aCanvas
]

{ #category : #display }
StringMorphEditor >> initialize [
	"Initialize the receiver.  Give it a white background"

	super initialize.
	self backgroundColor: Color white.
	self textColor: Color red.
]

{ #category : #'event handling' }
StringMorphEditor >> keyStroke: evt [
	"This is hugely inefficient, but it seems to work, and it's unlikely it will ever need
	to be any more efficient -- it's only intended to edit single-line strings."

	| char priorEditor newSel |
	(((char := evt keyCharacter) = Character enter) or: [(char = Character cr)
			or: [char = $s and: [evt commandKeyPressed]]])
				ifTrue: [owner doneWithEdits; acceptContents.
	self flag: #arNote. "Probably unnecessary"
						evt hand releaseKeyboardFocus.
						^ self delete].
	
	((char := evt keyCharacter) = Character escape
		or: [char = $l and: [evt commandKeyPressed]]) ifTrue:   "cancel"
		[owner cancelEdits.
		evt hand releaseKeyboardFocus.
		^ self delete].

	super keyStroke: evt.
	
	owner ifNil: [^self].
	owner interimContents: self contents asString.
	newSel := self editor selectionInterval.

	priorEditor := self editor.  "Save editor state"
	self releaseParagraph.  "Release paragraph so it will grow with selection."
	self paragraph.      "Re-instantiate to set new bounds"
	self installEditorToReplace: priorEditor.  "restore editor state"
	self editor selectFrom: newSel first to: newSel last.

]

{ #category : #'event handling' }
StringMorphEditor >> keyboardFocusChange: aBoolean [
	| hadFocus |
	owner ifNil: [ ^self ].
	hadFocus := owner hasFocus.
	super keyboardFocusChange: aBoolean.
	aBoolean ifFalse:
		[hadFocus ifTrue:
			[owner lostFocusWithoutAccepting; doneWithEdits].
		^ self delete]
]
