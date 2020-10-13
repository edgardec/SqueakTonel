"
A pluggable text morph with support for color.
"
Class {
	#name : #PluggableTextMorphPlus,
	#superclass : #PluggableTextMorph,
	#instVars : [
		'getColorSelector',
		'acceptAction',
		'unstyledAcceptText',
		'styler',
		'getTextColorSelector'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #preferences }
PluggableTextMorphPlus class >> themeProperties [

	^  super themeProperties, {
		{ #stylerClass. 'Editing'. 'The styler class you want to use for syntax highlighting' }.
		{ #balloonTextColor. 'Colors'. 'Color to use when drawing the balloon text on an empty text field.' }.
		{ #balloonTextFont. 'Fonts'. 'Font to use when drawing the balloon text on an empty text field.' }.
	}
]

{ #category : #updating }
PluggableTextMorphPlus >> accept [
	super accept.
	acceptAction ifNotNil:[acceptAction value: textMorph asText].
]

{ #category : #accessing }
PluggableTextMorphPlus >> acceptAction [
	^acceptAction
]

{ #category : #accessing }
PluggableTextMorphPlus >> acceptAction: anAction [
	acceptAction := anAction
]

{ #category : #styling }
PluggableTextMorphPlus >> acceptTextInModel [ 
	
	self okToStyle ifFalse:[^super acceptTextInModel].			
	"#correctFrom:to:with: is sent when the method source is
	manipulated during compilation (removing unused temps,
	changing selectors etc). But 	#correctFrom:to:with: operates 
	on the textMorph's text, and we may be saving an unstyled 
	copy of the text. This means that these corrections will be lost
	unless we also apply the corrections to the unstyled copy that we are saving.
		So remember the unstyled copy in unstyledAcceptText, so
	that when #correctFrom:to:with: is received we can also apply
	the correction to it"
	unstyledAcceptText := styler unstyledTextFrom: textMorph asText.
	[^setTextSelector isNil or:
		[setTextSelector numArgs = 2
			ifTrue: [model perform: setTextSelector with: unstyledAcceptText with: self]
			ifFalse: [model perform: setTextSelector with: unstyledAcceptText]]
	] ensure:[unstyledAcceptText := nil]
]

{ #category : #updating }
PluggableTextMorphPlus >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.

	self styler ifNotNil: [:s | 
		s reset.
		self updateStyle].
]

{ #category : #accessing }
PluggableTextMorphPlus >> balloonText [
	"Overridden to send selector to model and not self. Do not use #perform:orSendTo: because super does more than just the send.."
	
	self balloonTextSelector ifNotNil: [:selector |
		(self model respondsTo: selector) ifTrue: [
			^ self model perform: selector]].
	
	^ super balloonText
]

{ #category : #styling }
PluggableTextMorphPlus >> correctFrom: start to: stop with: aString [
	"see the comment in #acceptTextInModel "
	unstyledAcceptText ifNotNil:[unstyledAcceptText replaceFrom: start to: stop with: aString ].
	^ super correctFrom: start to: stop with: aString
]

{ #category : #drawing }
PluggableTextMorphPlus >> drawBalloonTextOn: aCanvas [ 
	"Show balloon text in the text morph if it has no contents."
	textMorph contents ifNotEmpty: [ ^ self ].
	([ self balloonText ]
		on: Error
		do: [ : err | 'error in balloonText' ]) ifNotNil:
		[ : text | aCanvas
			drawString: text
			in: (self innerBounds insetBy: (5 @ 2 corner: 0 @ 0))
			font: (self userInterfaceTheme balloonTextFont ifNil: [TextStyle defaultFont])
			color: (self userInterfaceTheme balloonTextColor ifNil: [Color gray: 0.7]) ]
]

{ #category : #drawing }
PluggableTextMorphPlus >> drawOn: aCanvas [

	super drawOn: aCanvas.
	self drawBalloonTextOn: aCanvas.
]

{ #category : #accessing }
PluggableTextMorphPlus >> getColorSelector [
	^getColorSelector
]

{ #category : #accessing }
PluggableTextMorphPlus >> getColorSelector: aSymbol [
	getColorSelector := aSymbol.
	self update: getColorSelector.
]

{ #category : #menu }
PluggableTextMorphPlus >> getMenu: shiftKeyState [
	"Answer the menu for this text view. We override the superclass implementation to
	so we can give the selection interval to the model."
	
	| menu aMenu |
	getMenuSelector == nil ifTrue: [^ nil].
	getMenuSelector numArgs < 3 ifTrue: [^ super getMenu: shiftKeyState].
	menu := MenuMorph new defaultTarget: model.
	getMenuSelector numArgs = 3 ifTrue:
		[aMenu := model 
			perform: getMenuSelector 
			with: menu 
			with: shiftKeyState 
			with: self selectionInterval.
		getMenuTitleSelector ifNotNil: 
			[aMenu addTitle: (model perform: getMenuTitleSelector)].
		^ aMenu].
	^ self error: 'The getMenuSelector must be a 1- or 2 or 3-keyword symbol'
]

{ #category : #accessing }
PluggableTextMorphPlus >> getTextColorSelector [
	^getTextColorSelector
]

{ #category : #accessing }
PluggableTextMorphPlus >> getTextColorSelector: aSymbol [
	getTextColorSelector := aSymbol.
	self update: getTextColorSelector.
]

{ #category : #styling }
PluggableTextMorphPlus >> hasUnacceptedEdits: aBoolean [
	"re-implemented to re-style the text iff aBoolean is true"
	 
	super hasUnacceptedEdits: aBoolean.
	aBoolean ifTrue: [ self updateStyle ].
]

{ #category : #testing }
PluggableTextMorphPlus >> okToStyle [

	^ styler
		ifNil: [false]
		ifNotNil: [:s | model aboutToStyle: s requestor: self]
]

{ #category : #styling }
PluggableTextMorphPlus >> setText: aText [
	
	self okToStyle ifFalse:[^super setText: aText].
	super setText: (styler format: aText asText).
	aText size < 4096
		ifTrue:[self updateStyleNow]
		ifFalse:[self updateStyle]
]

{ #category : #accessing }
PluggableTextMorphPlus >> styler [
	"The styler responsible for highlighting text in the receiver"
	^styler
]

{ #category : #accessing }
PluggableTextMorphPlus >> styler: anObject [
	"The styler responsible for highlighting text in the receiver"
	styler := anObject
]

{ #category : #styling }
PluggableTextMorphPlus >> stylerStyled: styledCopyOfText [
	"Sent after the styler completed styling the underlying text. The behavior is similar to #handleInteraction:event: but we do not have to copy text ore make those other checks."
	
	textMorph contents runs: styledCopyOfText runs .

	textMorph paragraph composeAll.
	textMorph editor recomputeSelection.
	textMorph updateFromParagraph.

	textMorph editor blinkParen.
	self scrollSelectionIntoView.
]

{ #category : #styling }
PluggableTextMorphPlus >> stylerStyledInBackground: styledCopyOfText [ 
	"Sent after the styler completed styling of the text"

	"It is possible that the text string	has changed since the styling began. Disregard the styles if styledCopyOfText's string differs with the current textMorph contents string"
	textMorph contents string = styledCopyOfText string
		ifTrue: [self stylerStyled: styledCopyOfText]
]

{ #category : #updating }
PluggableTextMorphPlus >> update: what [
	what ifNil:[^self].
	what == getColorSelector ifTrue: [self color: (model perform: getColorSelector)].
	what == getTextColorSelector ifTrue: [self setTextColor: (model perform: getTextColorSelector)].
	what == #style ifTrue: [self updateStyle].
	
	
	^super update: what
]

{ #category : #styling }
PluggableTextMorphPlus >> updateStyle [

	self okToStyle
		ifTrue: [styler styleInBackgroundProcess: textMorph contents].
]

{ #category : #styling }
PluggableTextMorphPlus >> updateStyleNow [

	self okToStyle
		ifTrue: [styler style: textMorph contents].
]

{ #category : #initialize }
PluggableTextMorphPlus >> useDefaultStyler [
	"This should be changed to a proper registry but as long as there is only shout this will do"
	
	(self userInterfaceTheme stylerClass ifNil: [Smalltalk at: #SHTextStylerST80])
		ifNotNil: [:stylerClass | self styler: (stylerClass new view: self)].
]
