"
StringMorph is a ""lightweight"" Morph to display a String. It supports only a single font, color, and emphasis combination. For multiple text styles, use TextMorph.

Structure:
instance var    	Type              Description 
font 			StrikeFont 		(normally nil; then the accessor #font gives back TextStyle 
				or nil			defaultFont) 
emphasis 		SmallInteger	bitmask determining character attributes (underline, bold, 								italics, narrow, struckout) 
contents 		String 			The text that will be displayed. 
hasFocus 		Boolean 		Do I have the keyboard focus or not? 

If you shift-click on a StringMorph you can edit its string. This is accomplished the following way: StringMorph can launch a StringMorphEditor if it receives a #mouseDown event.

A StringMorph may also be used like a SimpleButtonMorph to do an action when clicked. Use the menu 'extras' / 'add mouseUpAction'.

The following propery will be defined:
aStringMorph valueOfProperty: #mouseUpCodeToRun
"
Class {
	#name : #StringMorph,
	#superclass : #Morph,
	#instVars : [
		'font',
		'emphasis',
		'contents',
		'hasFocus'
	],
	#category : #'Morphic-Basic'
}

{ #category : #scripting }
StringMorph class >> authoringPrototype [
	^ super authoringPrototype contents: 'String'
]

{ #category : #'instance creation' }
StringMorph class >> contents: aString [
	" 'StringMorph contents: str' is faster than 'StringMorph new contents: str' "
	^ self contents: aString font: nil
]

{ #category : #'instance creation' }
StringMorph class >> contents: aString font: aFont [
	^ self basicNew initWithContents: aString font: aFont emphasis: 0
]

{ #category : #'instance creation' }
StringMorph class >> contents: aString font: aFont emphasis: emphasisCode [
	^ self basicNew initWithContents: aString font: aFont emphasis: emphasisCode
]

{ #category : #testing }
StringMorph class >> test [
	"Return a morph with lots of strings for testing display speed."
	| c |
	c := AlignmentMorph newColumn.
	SystemOrganization categories do:
		[:cat | c addMorph: (StringMorph new contents: cat)].
	^ c
]

{ #category : #testing }
StringMorph class >> test2 [
	"Return a morph with lots of strings for testing display speed."
	| c r |
	c := AlignmentMorph newColumn.
	SystemOrganization categories reverseDo:
		[:cat | c addMorph: (StringMorph new contents: cat)].
	r := RectangleMorph new extent: c fullBounds extent.
	c submorphsDo: [:m | r addMorph: m].
	^ r

]

{ #category : #editing }
StringMorph >> acceptContents [
	"The message is sent when the user hits enter or Cmd-S. Accept the current contents and end editing. This default implementation does nothing."

]

{ #category : #editing }
StringMorph >> acceptValue: aValue [
	| val |
	self contents: (val := aValue asString).
	^ val
]

{ #category : #menu }
StringMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'change font' translated action: #changeFont.
	aCustomMenu add: 'change emphasis' translated action: #changeEmphasis.

]

{ #category : #'halos and balloon help' }
StringMorph >> addOptionalHandlesTo: aHalo box: box [
	"eventually, add more handles for font..."

	self flag: #deferred.
	^ super addOptionalHandlesTo: aHalo box: box

	"Eventually...
	self addFontHandlesTo: aHalo box: box"
]

{ #category : #'halos and balloon help' }
StringMorph >> boundsForBalloon [
	"Some morphs have bounds that are way too big.  This is a contorted way of making things work okay in PluggableListMorphs, whose list elements historically have huge widths"

	| ownerOwner |
	^ ((owner notNil and: [(ownerOwner := owner owner) notNil]) and:
			[ownerOwner isKindOf: PluggableListMorph])
		ifTrue:
			[self boundsInWorld intersect: ownerOwner boundsInWorld]
		ifFalse:
			[super boundsForBalloon]
]

{ #category : #editing }
StringMorph >> cancelEdits [

	self doneWithEdits
]

{ #category : #menu }
StringMorph >> changeEmphasis [

	| reply aList |
	aList := #(normal bold italic narrow underlined struckOut).
	reply := UIManager default 
		chooseFrom: (aList collect: [:t | t translated]) 
		values: aList..
	reply ifNotNil:[
		self emphasis: (TextEmphasis perform: reply) emphasisCode.
	].

]

{ #category : #menu }
StringMorph >> changeFont [
	
	| chooser originalFont |
	originalFont := self fontToUse.
	self openModal: (
		Cursor wait showWhile: [
			| window |
			window := UIManager default 
				chooseFont: 'Choose a Font' 
				for: self 
				setSelector: #font: 
				getSelector: originalFont.
			"We have to save the model here, because it will be gone when the window is closed."
			chooser := window model. 
			window ]).
	originalFont = self fontToUse ifFalse: [
		"Ensure that we restore the original font in case it was changed, but Cancel was clicked."
		self font: (chooser result ifNil: [ originalFont ]) ]
]

{ #category : #accessing }
StringMorph >> contents [

	^ contents	ifNil: [ self contents: 'String Morph'. contents ]

]

{ #category : #accessing }
StringMorph >> contents: newContents [ 

	self flag: #todo. "mt: hasFocus == true means that the mini editor was launched. We should now ignore any external calls to this method to avoid visual glitches. However, #interimContents: does also use this callback. Figure something out."

	newContents isText
		ifTrue: [^ self initializeFromText: newContents].

	contents = newContents
		ifTrue: [^ self "No substantive change."].

	contents := newContents.
	self changed. "New contents need to be drawn."
		
	self fitContents. "Resize if necessary."
]

{ #category : #'accessing - convenience' }
StringMorph >> contentsClipped: aString [
	"Change my text, but do not change my size as a result"
	contents = aString ifTrue: [^ self].  "No substantive change"
	contents := aString.
	self changed
]

{ #category : #'accessing - convenience' }
StringMorph >> contentsFitted: aString [
	"I fit my contents by default."
	
	self contents: aString.
]

{ #category : #initialization }
StringMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #editing }
StringMorph >> doneWithEdits [

	hasFocus := false
]

{ #category : #drawing }
StringMorph >> drawOn: aCanvas [

	aCanvas
		drawString: self contents
		in: self bounds
		font: self fontToUse
		color: self color.
]

{ #category : #accessing }
StringMorph >> emphasis [
	"self assert: emphasis = self font emphasis"
	
	^ emphasis
]

{ #category : #accessing }
StringMorph >> emphasis: aNumber [
	"Set the receiver's emphasis as indicated. aNumber is a bitmask with the following format:

	bit	attribute
	1	bold
	2	italic
	4	underlined
	8	narrow
	16	struckOut"

	"examples: 0 -> plain.  
	1 -> bold.  2 -> italic.  3 -> bold italic.  4 -> underlined  
	5 -> bold underlined.  6 -> italic underlined.   7 -> bold italic underlined   
	etc..."

	self
		setFont: (self font emphasized: aNumber)
		emphasis: aNumber
]

{ #category : #layout }
StringMorph >> fitContents [

	self extent: self measureContents.
]

{ #category : #'objects from disk' }
StringMorph >> fixUponLoad: aProject seg: anImageSegment [
	"We are in an old project that is being loaded from disk.
Fix up conventions that have changed."

	| substituteFont |
	substituteFont := aProject projectParameters at:
#substitutedFont ifAbsent: [#none].
	(substituteFont ~~ #none and: [self font == substituteFont])
			ifTrue: [ self fitContents ].

	^ super fixUponLoad: aProject seg: anImageSegment
]

{ #category : #accessing }
StringMorph >> font [
	"who came up with #fontToUse rather than font?!"
	^self fontToUse
]

{ #category : #accessing }
StringMorph >> font: aFont [ 
	"Set the font my text will use. The emphasis remains unchanged."

	self
		setFont: (aFont emphasized: self emphasis)
		emphasis: self emphasis.
]

{ #category : #'accessing - convenience' }
StringMorph >> font: aFontOrNil emphasis: emphasisCodeOrNil [
	"For convenience only. Try to use #font: and #emphasis: instead.
	
	Changes font and/or emphasis. If both are given, the font's current emphasis will be discarded. If only the emphasis is given, the system's default font will be used. If only the font is given, the font's emphasis will be cached so that future calls to #font: will keep the emphasis."

	self
		assert: aFontOrNil notNil | emphasisCodeOrNil notNil
		description: 'Either font or emphasis must be non-nil.'.
		
	self
		setFont: ((aFontOrNil isNil or: [aFontOrNil emphasis = emphasisCodeOrNil] or: [emphasisCodeOrNil isNil])
			ifTrue: [aFontOrNil]
			ifFalse: [aFontOrNil emphasized: emphasisCodeOrNil])
		emphasis: (emphasisCodeOrNil ifNil: [aFontOrNil emphasis]).
		
	"self assert: self font emphasis = self emphasis. --- mt: Does not always work because of how StrikeFont treats emphasis 0 in #emphasized:."
]

{ #category : #fonts }
StringMorph >> fontName: fontName [

	self
		fontName: fontName
		size: TextStyle defaultFont pixelSize
		emphasis: 0.
]

{ #category : #fonts }
StringMorph >> fontName: fontName pointSize: fontSize [

	self
		fontName: fontName
		pointSize: fontSize
		emphasis: 0.
]

{ #category : #fonts }
StringMorph >> fontName: fontName pointSize: fontSize emphasis: emphasisCode [

	self
		setFont: (StrikeFont familyName: fontName pointSize: fontSize emphasized: emphasisCode)
		emphasis: emphasisCode.
]

{ #category : #fonts }
StringMorph >> fontName: fontName size: fontSize [

	self
		fontName: fontName
		size: fontSize
		emphasis: 0.
]

{ #category : #fonts }
StringMorph >> fontName: fontName size: fontSize emphasis: emphasisCode [

	self
		setFont: (StrikeFont familyName: fontName size: fontSize emphasized: emphasisCode)
		emphasis: emphasisCode.
]

{ #category : #drawing }
StringMorph >> fontToUse [
	"Support un-initialized font or emphasis variable."
	
	^ font ifNil: [TextStyle defaultFont emphasized: (self emphasis ifNil: [0])]
]

{ #category : #printing }
StringMorph >> fullPrintOn: aStream [

	aStream nextPutAll: '('.
	super fullPrintOn: aStream.
	aStream nextPutAll: ') contents: '; print: contents
]

{ #category : #'event handling' }
StringMorph >> handlesMouseDown: evt [
	^ (evt shiftPressed and: [self wantsKeyboardFocusOnShiftClick])
		ifTrue: [true]
		ifFalse: [super handlesMouseDown: evt].

]

{ #category : #'event handling' }
StringMorph >> hasFocus [
	^ hasFocus
]

{ #category : #testing }
StringMorph >> hasTranslucentColor [

	^true
]

{ #category : #drawing }
StringMorph >> imageForm: depth forRectangle: rect [
	| canvas |
	canvas := Display defaultCanvasClass extent: rect extent depth: depth.
	canvas form fillColor: self color negated. 
	canvas translateBy: rect topLeft negated
		during:[:tempCanvas| tempCanvas fullDrawMorph: self].
	^ canvas form offset: rect topLeft
]

{ #category : #initialization }
StringMorph >> initWithContents: aStringOrText font: aFont emphasis: emphasisCode [ 

	self initialize.
	
	aStringOrText isText
		ifTrue: [self initializeFromText: aStringOrText]
		ifFalse: [
			self initializeFromString: aStringOrText.
			self font: aFont emphasis: emphasisCode].
]

{ #category : #initialization }
StringMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	font := nil.
	emphasis := 0.
	hasFocus := false
]

{ #category : #initialization }
StringMorph >> initializeFromString: aString [

	contents := aString.
]

{ #category : #initialization }
StringMorph >> initializeFromText: aText [

	| scanner |
	scanner := StringMorphAttributeScanner new initializeFromStringMorph: self.

	(aText attributesAt: 1 forStyle: self font textStyle)
		do: [:attr | attr emphasizeScanner: scanner].

	font := scanner font emphasized: scanner emphasis.
	emphasis := scanner emphasis.
	
	color := scanner textColor.

	self contents: aText string.
]

{ #category : #'parts bin' }
StringMorph >> initializeToStandAlone [
	super initializeToStandAlone.
	
	font := nil.
	emphasis := 0.
	hasFocus := false.
	self contents: 'String: Shift-click on me to edit'
]

{ #category : #'accessing - support' }
StringMorph >> interimContents: aString [
	"The receiver is under edit and aString represents the string the user sees as she edits, which typically will not have been accepted and indeed may be abandoned"

	self contents: aString
]

{ #category : #'accessing - convenience' }
StringMorph >> label: aString font: aFont [
	"compatible protocol used in ScriptEditorMorph>>bringUpToDate"
	self contents: aString.
	self font: aFont
]

{ #category : #editing }
StringMorph >> launchMiniEditor: evt [

	| textMorph |
	hasFocus := true.  "Really only means edit in progress for this morph"
	textMorph := StringMorphEditor new contentsAsIs: contents.
	textMorph beAllFont: self fontToUse.
	textMorph bounds: (self bounds expandBy: 0@2).
	self addMorphFront: textMorph.
	evt hand newKeyboardFocus: textMorph.
	textMorph editor selectFrom: 1 to: textMorph paragraph text string size
]

{ #category : #drawing }
StringMorph >> lookTranslucent [

	"keep the text the same color (black)"
]

{ #category : #editing }
StringMorph >> lostFocusWithoutAccepting [
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus -- typically by clicking on some editable text somewhere else -- without having accepted the current edits."

	self acceptContents
]

{ #category : #'accessing - support' }
StringMorph >> measureContents [
	| f |
	f := self fontToUse.
	^(((f widthOfString: contents) max: self minimumWidth)  @ f height).
]

{ #category : #layout }
StringMorph >> minHeight [
	"Layout specific."
	
	^ super minHeight max: self fontToUse height
]

{ #category : #layout }
StringMorph >> minWidth [
	"Layout specific."
	
	^ self hResizing = #spaceFill
		ifTrue: [0] ifFalse: [super minWidth max: (self fontToUse widthOfString: self contents)]
]

{ #category : #'event handling' }
StringMorph >> mouseDown: evt [
	"If the shift key is pressed, make this string the keyboard input focus."

	(evt shiftPressed and: [self wantsKeyboardFocusOnShiftClick])
		ifTrue: [self launchMiniEditor: evt]
		ifFalse: [super mouseDown: evt].

]

{ #category : #printing }
StringMorph >> printOn: aStream [

	super printOn: aStream.
	aStream print: contents.

]

{ #category : #initialization }
StringMorph >> setFont: aFont emphasis: emphasisCode [
	"self assert: emphasisCode = aFont emphasis."

	font := aFont.
	emphasis := emphasisCode.
	
	self fitContents.

"
in inspector say,
	 self font: (TextStyle default fontAt: 2) emphasis: 1
"
]

{ #category : #'accessing - support' }
StringMorph >> setWidth: width [

	self extent: width @ (font ifNil: [TextStyle defaultFont]) height
]

{ #category : #'accessing - support' }
StringMorph >> userString [
	"Do I have a text string to be searched on?"

	^ contents
]

{ #category : #'accessing - support' }
StringMorph >> valueFromContents [
	"Return a new value from the current contents string."
	^ contents
]

{ #category : #editing }
StringMorph >> wantsKeyboardFocusOnShiftClick [
	^ owner topRendererOrSelf wantsKeyboardFocusFor: self

]

{ #category : #'event handling' }
StringMorph >> wouldAcceptKeyboardFocus [
	^ self isLocked not
]
