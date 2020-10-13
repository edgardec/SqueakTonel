"
A graphical menu that is put up whe the user requests it from the gold-box icon in the header of a Blue scriptor.
"
Class {
	#name : #GoldBoxMenu,
	#superclass : #AlignmentMorph,
	#instVars : [
		'scriptor',
		'lastItemMousedOver'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting'
}

{ #category : #initialization }
GoldBoxMenu >> basicExtentForElements [
	"Answer the nominal thumbnail extent"

	^ Preferences parameterAt: #goldBoxElementExtent ifAbsentPut: (140 @ 40)

"
Preferences setParameter: #goldBoxElementExtent to: (140 @ 40).
"
]

{ #category : #initialization }
GoldBoxMenu >> initializeFor: aScriptor [
	"Answer a graphical menu to be put up in conjunction with the Gold Box"

	| aButton goldBox aReceiver boxBounds example toScale |
	scriptor := aScriptor.
	lastItemMousedOver := nil.
	self removeAllMorphs.
	self setProperty: #goldBox toValue: true.
	self listDirection: #topToBottom;
		hResizing: #spaceFill; extent: 1@1; vResizing: #spaceFill. "standard #newColumn stuff"

	self setNameTo: 'Gold Box' translated.
	self useRoundedCorners.
	self color: Color white.
	self borderColor:  (Color r: 1.0 g: 0.839 b: 0.065).
	self hResizing: #shrinkWrap; vResizing: #shrinkWrap; borderWidth: 4.
	{
	{ScriptingSystem. #yesNoComplexOfTiles.  'test' translated. 'Test/Yes/No panes for testing a condition.'  translated}.
	{ScriptingSystem. #timesRepeatComplexOfTiles. 'repeat'  translated.  'TimesRepeat panes for running a section of code repeatedly.'  translated}.
	{ ScriptingSystem.	#randomNumberTile.	 'random'  translated.		'A tile that will produce a random number in a given range.'  translated}.
	{ ScriptingSystem.	#seminalFunctionTile.	 'function'  translated.		'A tile representing a function call.  Click on the function name or the arrows to change functions.'  translated}.
	{ScriptingSystem.	#buttonUpTile.	 'button up?'  translated.		'Reports whether the mouse button is up'  translated}.
	{ScriptingSystem.	#buttonDownTile.	 'button down?'  translated.		'Reports whether the mouse button is down'  translated}.
	{ScriptingSystem.	#randomColorTile.	 'random color'  translated.		'A tile returning a random color'  translated}.
	{scriptor playerScripted. #tileToRefer.  'tile for me'  translated. 'A tile representing the object being scripted'  translated}.
	{self.  #numericConstantTile.  'number'  translated.   'A tile holding a plain number'  translated}.
} do:
		[:tuple |
			aReceiver := tuple first.
			example := aReceiver perform: tuple second.
			
			aButton := IconicButton new target: aReceiver.
			aButton borderWidth: 0;
				color: Color transparent.
			toScale := tuple size >= 5
				ifTrue:
					[tuple first perform: tuple fifth]  "bail-out for intractable images."
				ifFalse:
					[example imageForm].
			aButton labelGraphic: (toScale copy scaledToHeight: 40).

			aButton actionSelector: #launchPartOffsetVia:label:.
			aButton arguments: {tuple second.  tuple third}.
			(tuple size > 3 and: [tuple fourth isEmptyOrNil not]) ifTrue:
				[aButton setBalloonText: tuple fourth].
			aButton actWhen: #buttonDown.
			aButton on: #mouseEnter send: #mousedOverEvent:button:  to: self.
			aButton on: #click send: #delete to: self.
 			self addMorphBack: aButton].
	goldBox := aScriptor submorphs first submorphThat: [:m | (m isKindOf: SimpleButtonMorph) and: [m actionSelector == #offerGoldBoxMenu]] ifNone: [nil].
	goldBox
		ifNil:
			[self position: self currentHand position]
		ifNotNil:
			[boxBounds := goldBox boundsInWorld.
			self center: boxBounds center.
			self left: (boxBounds center x - (self width // 2)).
			self top: boxBounds bottom].
	lastItemMousedOver := nil.
	self on: #mouseLeave send: #mouseLeftMenuWithEvent: to: self.
	self on: #mouseLeaveDragging send: #delete to: self.
]

{ #category : #initialization }
GoldBoxMenu >> mouseLeftMenuWithEvent: evt [
	"The mouse, having been within the menu, has now left it.  Formerly:  Depending on how the departure takes place, we either do or don't hand the user a prototype object, but in any case we ourselves vanish.  Currently:  we do *not* tear off a new instance, but rather simply delete the open gold-box."
	
	false ifTrue:
		[lastItemMousedOver ifNotNil:
			[((evt position x <= self left) or: [evt position x >= self right])  "off to sides"
				ifTrue:
					[lastItemMousedOver doButtonAction]]].

	self delete
]

{ #category : #initialization }
GoldBoxMenu >> mousedOverEvent: evt button: aButton [
	"The mouse came over a button in my panel; make a note of it, and  instigate its mouseover highlighting"

	lastItemMousedOver := aButton.
	aButton borderThick
]

{ #category : #initialization }
GoldBoxMenu >> numericConstantTile [
	"Answer a bare numeric-constant tile."

	| aTile |
	aTile := (Vocabulary vocabularyNamed: 'Number')  defaultArgumentTile.
	aTile vResizing: #shrinkWrap.
	^ aTile
]
