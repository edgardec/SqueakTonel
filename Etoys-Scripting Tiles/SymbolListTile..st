"
Instances of SymbolListTile are literal tiles whose literals are choosable from a finite list.
"
Class {
	#name : #SymbolListTile,
	#superclass : #TileMorph,
	#instVars : [
		'choices',
		'dataType'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'customevents-updating' }
SymbolListTile class >> updateAllTilesForVocabularyNamed: aVocabularyName [
	"The choices in the Vocabulary named aVocabularyName may have changed.
	Update my subinstances if necessary to reflect the changes."

	 (self allSubInstances select: [ :ea | ea dataType = aVocabularyName ])
		do: [ :ea | ea updateChoices ] 
]

{ #category : #'user interface' }
SymbolListTile >> acceptNewLiteral: aLiteral [
	"Accept the new literal"

	self labelMorph useSymbolFormat.
	self literal: aLiteral.
	self adjustHelpMessage.
	self acceptNewLiteral.  "so tile scriptor can recompile if necessary"
	self labelMorph informTarget

]

{ #category : #'user interface' }
SymbolListTile >> adjustHelpMessage [
	"Adjust the help message to reflect the new literal"

	(ScriptingSystem helpStringOrNilForOperator: literal) ifNotNil:
		[:aString |
			self labelMorph setBalloonText: aString]
]

{ #category : #'user interface' }
SymbolListTile >> choices [
	"Answer the list of current choices for the receiver's symbol"

	dataType == #ScriptName ifTrue: "Backward compatibility with old tiles"
		[^ Project current world presenter allKnownUnaryScriptSelectors].
	^ choices
]

{ #category : #initialization }
SymbolListTile >> choices: choiceList dataType: aDataType [
	"Initialize the receiver with the given choice-list and data type"

	choices := choiceList.
	dataType := aDataType.
	literal := choiceList first
]

{ #category : #'customevents-accessing' }
SymbolListTile >> dataType [
	^dataType
]

{ #category : #'event handling' }
SymbolListTile >> handlesMouseDown: evt [
	"Answer whether the receiver handles mouse-down"

	^ true
]

{ #category : #initialization }
SymbolListTile >> initialize [
	super initialize.
	literal := #nothing
]

{ #category : #private }
SymbolListTile >> line1: line1 [
	"Emblazon the receiver with the requested label.  If the receiver already has a label, make the new label be of the same class"

	super line1: line1.
	self labelMorph useSymbolFormat
]

{ #category : #accessing }
SymbolListTile >> literal: anObject [
	"Set the receiver's literal as indicated"
	self flag: #yo.

	literal := anObject asSymbol.
	self updateLiteralLabel.
"
	key := Vocabulary eToyVocabulary translationKeyFor: literal.
	key isNil ifFalse: [literal := key].
"
	self flag: #deferred.  "The below formerly was necessary but now is problematical, leading to low-space condition etc.  May need to revisit, since as I comment this out now I am uncertain what if anything this may break"
	"self labelMorph informTarget"


]

{ #category : #'events-processing' }
SymbolListTile >> mouseDownPriority [
	"Higher-priority than parts donor, so that the tile can offer a popup even when it is in a larger structure, such as a PhraseTileMorph, that itself behaves as a parts donor"

	^ 75
]

{ #category : #'user interface' }
SymbolListTile >> offerAllChoicesInAPopUp [
	"Retained in deference to pre-existing content that may have event handlers that send this message."

	
]

{ #category : #accessing }
SymbolListTile >> options [
	^ {self choices. self choices
		collect: [:each | ScriptingSystem helpStringForOperator: literal]}
]

{ #category : #misc }
SymbolListTile >> setLiteralInitially: anObject [
	"Establish the initial literal.  Get the label correct, but do *not* send the value back to the target via the setter (unlike #literal:)"

	literal := anObject ifNotNil: [anObject asSymbol].
	self updateLiteralLabel
]

{ #category : #'customevents-initialization' }
SymbolListTile >> updateChoices [
	choices := (Vocabulary vocabularyNamed: dataType) choices.
	(choices includes: literal) ifFalse: [ literal := choices first. self changed ]
]

{ #category : #'player viewer' }
SymbolListTile >> updateLiteralLabel [
	"Update the wording emblazoned on the tile, if needed.  Copied down, for jimmying, unfortunately"

	| myLabel |
	(myLabel := self labelMorph) ifNil: [^ self].
	myLabel useSymbolFormat.
	myLabel acceptValue: literal asString.
	self changed.
]

{ #category : #accessing }
SymbolListTile >> value: anObject [ 
	self acceptNewLiteral: anObject
]

{ #category : #'event handling' }
SymbolListTile >> wantsKeyboardFocusFor: aSubmorph [
	"Answer whether a plain mouse click on aSubmorph, a text-edit-capable thing, should result in a text selection there"

	^ false
]
