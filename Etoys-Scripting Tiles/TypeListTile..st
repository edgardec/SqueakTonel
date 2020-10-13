"
A tile that offers a list of supported data types.
"
Class {
	#name : #TypeListTile,
	#superclass : #SymbolListTile,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'user interface' }
TypeListTile >> acceptNewLiteral: aLiteral [
	"Accept the new literal"

	| scriptEditor |
	super acceptNewLiteral: aLiteral.
	(scriptEditor := self ownerThatIsA: ScriptEditorMorph) ifNotNil:
			[scriptEditor setParameterType: aLiteral asSymbol]
]

{ #category : #menus }
TypeListTile >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add morph-specific items to the given menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'choose type...' translated action: #showSuffixChoices
]

{ #category : #arrows }
TypeListTile >> addMenuIcon [
	"Add a little menu icon; store it in my suffixArrow slot"

	suffixArrow ifNotNil: [suffixArrow delete].
	suffixArrow := ImageMorph new image: (ScriptingSystem formAtKey: #MenuTriangle).
	suffixArrow setBalloonText: 'click here to choose a new type for this parameter' translated.
	self addMorphBack: suffixArrow
]

{ #category : #'user interface' }
TypeListTile >> adjustHelpMessage [
	"In this case, don't"
]

{ #category : #initialization }
TypeListTile >> initialize [
	"Initialize the receiver. Cheesily, we use the extension arrow 
	graphic for a menu icon temporarily"
	super initialize
"".
	self addMenuIcon
]

{ #category : #'as yet unclassified' }
TypeListTile >> mouseDown: evt [

	evt wasHandled: true.

]

{ #category : #'mouse handling' }
TypeListTile >> showOptions [
	| topScript |
	suffixArrow
		ifNotNil: [(suffixArrow bounds containsPoint: self currentHand cursorPoint)
				ifTrue: [^ super showOptions]].
	topScript := self
				outermostMorphThat: [:m | m isKindOf: ScriptEditorMorph].
	topScript
		ifNotNil: [topScript handUserParameterTile]
]

{ #category : #arrows }
TypeListTile >> showSuffixChoices [
	"When the user clicks on the suffix arrow, put up the type-choices menu"
	"A bit dirty hack, avoided testing whether the down arrow includes mouse point"
	 super showOptions
]

{ #category : #accessing }
TypeListTile >> value: anObject [ 
	| scriptEditor |
	super value: anObject.
	(scriptEditor := self ownerThatIsA: ScriptEditorMorph)
		ifNotNil: [scriptEditor setParameterType: anObject]
]
