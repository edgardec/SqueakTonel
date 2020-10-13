"
A text object intended to carry user-created textual content.  The default mode is to be non-wrapping, so that the only wrapping that takes place will be that imposed by explicit carriage-returns in the text. The user can manually (from menu) change the wrap setting, and it is also automatically switched to wrap-mode if the user manually resizes the text-object (with the halo) and also if the user, by typing, makes the text object extend off the right edge of the screen.
"
Class {
	#name : #UserText,
	#superclass : #TextMorph,
	#category : #'Etoys-Squeakland-Morphic-Basic'
}

{ #category : #menus }
UserText >> addYellowButtonMenuItemsTo: aCustomMenu event: evt [ 
	"Add menu items to a yellow-button menu abuiliding."

	super addYellowButtonMenuItemsTo: aCustomMenu event: evt.
	self addBasicMenuItemsTo: aCustomMenu event: evt.
	self addCustomMenuItems: aCustomMenu hand: evt hand.
	self addTextMenuItemsTo: aCustomMenu event: evt
]

{ #category : #initialization }
UserText >> beAllFont: aFont [
	"Set the receiver such that the given font is installed throughout."

	self editor selection isEmptyOrNil ifTrue: [ self editor selectAll ].
	super beAllFont: aFont.
]

{ #category : #drawing }
UserText >> drawOn: aCanvas [
	"Render the receiver on the given canvas."

	super drawOn: aCanvas.
	aCanvas isShadowDrawing
		ifTrue: [^ self].
	self hasFocus
		ifTrue: [aCanvas
				frameRectangle: (self fullBounds insetBy: 0)
				color: self keyboardFocusColor]
]

{ #category : #font }
UserText >> fontName: fontname pointSize: size [
	"Set receiver to accommodate the given font name and size."

	super fontName: fontname pointSize: size.
	self updateFromParagraph
]

{ #category : #font }
UserText >> fontName: fontname size: size [
	"Set the given font-name and size to be used in the receiver's text."

	super fontName: fontname size: size.
	self updateFromParagraph.
]

{ #category : #editing }
UserText >> highlightRectChanged [
	"The highlight rectangle changed... react."

	(self outerBounds areasOutside: (self innerBounds insetBy: 3))
		do: [ :rect | self invalidRect: rect ]
]

{ #category : #initialization }
UserText >> initialize [
	"Initialize the receiver."

	super initialize.
	wrapFlag := false.
	self margins: 6@0.
	self autoFit: true. 

]

{ #category : #private }
UserText >> installEditorToReplace: priorEditor [
	"Install an editor for my paragraph.  This constitutes 'hasFocus'.
	If priorEditor is not nil, then initialize the new editor from its state.
	We may want to rework this so it actually uses the prior editor."

	super installEditorToReplace: priorEditor.
	self highlightRectChanged.
	^ editor
]

{ #category : #'event handling' }
UserText >> keyStroke: evt [ 
	"Handle a keystroke event."

	| newSel |
	super keyStroke: evt.
	evt hand keyboardFocus == self ifFalse: [self releaseEditor. ^ self].
	newSel := self editor selectionInterval.	"restore editor state"
	self refreshParagraph.
	self editor selectFrom: newSel first to: newSel last.
	
	wrapFlag ifFalse:
		[self fullBounds right > owner right ifTrue:
			[self wrapFlag: true.
			self right: owner right.
			self refreshParagraph.
			self editor selectFrom: text string size + 1 to: text string size]].
]

{ #category : #'event handling' }
UserText >> refreshParagraph [
	"Release any existing editor, then release the paragraph and reinistantiate it so that it will grow with its selection; if under edit, restore the editing state."

	| priorEditor |
	priorEditor := editor.	"Save editor state"
	self releaseParagraph.	"Release paragraph so it will grow with selection."
	self paragraph.	"Re-instantiate to set new bounds"
	priorEditor ifNotNil: [ self installEditorToReplace: priorEditor]. "restore editor state"

]

{ #category : #'events-processing' }
UserText >> rejectsEvent: anEvent [
	"Answer whether the receiver rejects a given event."

	self trackFocusFromEvent: anEvent.
	^ (super rejectsEvent: anEvent)
		or: [ anEvent isKeyboard and: [ (self handlesKeyboard: anEvent) not ] ]
]

{ #category : #private }
UserText >> releaseEditor [
	"Release the text editor, and signal that the highlight rectangle needs to be updated."

	super releaseEditor.
	self highlightRectChanged

]

{ #category : #resizing }
UserText >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed."

	self wrapFlag: true.
	^ super setExtentFromHalo: anExtent
]

{ #category : #'event handling' }
UserText >> trackFocusFromEvent: evt [
	"Track focus."

	evt hand keyboardFocus == self ifFalse:
		[self hasFocus ifTrue: [ self highlightRectChanged. self releaseEditor]]
]

{ #category : #private }
UserText >> updateFromParagraph [
	"Update the receiver's contents from its paragraph"

	super updateFromParagraph.
	self hasFocus ifFalse: [^ self].

	(self isAutoFit and: [ wrapFlag not])
		ifTrue: [ self refreshParagraph].
	self editor

]
