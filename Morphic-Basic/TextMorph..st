"
TextMorphs support display of text with emphasis.  They also support reasonable text-editing capabilities, as well as embedded hot links, and the ability to embed submorphs in the text.

Late in life, TextMorph was made a subclass of BorderedMorph to provide border and background color if desired.  In order to keep things compatible, protocols have been redirected so that color (preferably textColor) relates to the text, and backgroundColor relates to the inner fill color.

Text display is clipped to the innerBounds of the rectangle, and text composition is normally performed within a rectangle which is innerBounds inset by the margins parameter.

If text has been embedded in another object, one can elect to fill the owner's shape, in which case the text will be laid out in the shape of the owner's shadow image (including any submorphs other than the text).  One can also elect to have the text avoid occlusions, in which case it will avoid the bounds of any sibling morphs that appear in front of it.  It may be necessary to update bounds in order for the text runaround to notice the presence of a new occluding shape.

The optional autoFitContents property enables the following feature:  if the text contents changes, then the bounds of the morph will be adjusted to fit the minimum rectangle that encloses the text (plus any margins specified).  Similarly, any attempt to change the size of the morph will be resisted if this parameter is set.  Except...

If the wrapFlag parameter is true, then text will be wrapped at word boundaries based on the composition width (innerBounds insetBy: margins) width.  Thus an attempt to resize the morph in autofit mode, if it changes the width, will cause the text to be recomposed with the new width, and then the bounds will be reset to the minimum enclosing rectangle.  Similarly, if the text contents are changed with the wrapFlag set to true, word wrap will be performed based on the current compostion width, after which the bounds will be set (or not), based on the autoFitcontents property.

Note that fonts can only be applied to the TextMorph as a whole.  While you can change the size, color, and emphasis of a subsection of the text and have it apply to only that subsection, changing the font changes the font for the entire contents of the TextMorph. 

Still a TextMorph can be composed of several texts of different fonts
| font1 font2 t1 t2 tMorph|
tMorph := TextMorph new.
font1 := (TextFontReference toFont: (StrikeFont familyName: 'Atlanta' size: 22)).
font2 := (TextFontReference toFont: (StrikeFont familyName: 'Atlanta' size: 11)).
t1 := 'this is font1' asText addAttribute: font1.
t2 := ' and this is font2' asText addAttribute: font2.
tMorph contents: (t1,t2).
tMorph openInHand.


Yet to do:
Make a comprehensive control for the eyedropper, with border width and color, inner color and text color, and margin widths.
"
Class {
	#name : #TextMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'textStyle',
		'text',
		'wrapFlag',
		'paragraph',
		'editor',
		'container',
		'predecessor',
		'successor',
		'backgroundColor',
		'margins',
		'readOnly',
		'autoFit'
	],
	#classVars : [
		'CaretForm',
		'DefaultEditorClass'
	],
	#category : #'Morphic-Basic'
}

{ #category : #scripting }
TextMorph class >> authoringPrototype [
	| t |
	t := super authoringPrototype.
	t contents: 'abc' translated asText.
	t wrapFlag: true. 

"Strangeness here in order to avoid two offset copies of the default contents when operating in an mvc project before cursor enters the morphic window"
	t paragraph.
	^ t
]

{ #category : #'connectorstext-parts bin' }
TextMorph class >> boldAuthoringPrototype [
	"TextMorph boldAuthoringPrototype openInHand"
	| text |
	text := Text string: 'Text' translated attributes: { TextEmphasis bold. }.
	^self new
		contentsWrapped: text;
		fontName: 'BitstreamVeraSans' pointSize: 24;
		paragraph;
		extent: 79@36;
		margins: 4@0;
		fit;
		yourself

]

{ #category : #'parts bin' }
TextMorph class >> borderedPrototype [

	| t |
	t := self authoringPrototype.
	t fontName: 'BitstreamVeraSans' pointSize: 24.
	t autoFit: false; extent: 250@100.
	t borderWidth: 1; margins: 4@0; backgroundColor: Color white.

"Strangeness here in order to avoid two offset copies of the default contents when operating in an mvc project before cursor enters the morphic window"
	t paragraph.
	^ t
]

{ #category : #'class initialization' }
TextMorph class >> cleanUp [

	TextMorph allSubInstancesDo: [:m | m releaseEditor].
]

{ #category : #'class initialization' }
TextMorph class >> defaultEditorClass [
	"Answers the default editor class for TextMorph"
	^DefaultEditorClass
]

{ #category : #'class initialization' }
TextMorph class >> defaultEditorClass: aTextEditorClass [
	"Sets the default editor class for TextMorph"
	"
		TextMorph defaultEditorClass: TextMorphEditor.
		TextMorph defaultEditorClass: TextEditor.
	"
	DefaultEditorClass := aTextEditorClass
]

{ #category : #scripting }
TextMorph class >> defaultNameStemForInstances [
	^ 'Text' translatedNoop
]

{ #category : #'parts bin' }
TextMorph class >> exampleBackgroundLabel [
	"Answer a background label for a parts bin"

	| aTextMorph |
	aTextMorph := self authoringPrototype.
	aTextMorph contents: 'background
label' asText.  
	aTextMorph beAllFont: (StrikeFont familyName: #NewYork size: 18).
	aTextMorph color: Color brown.
	aTextMorph setProperty: #shared toValue: true.
	^ aTextMorph

]

{ #category : #'parts bin' }
TextMorph class >> fancyPrototype [

	| t |
	t := self authoringPrototype.
	t autoFit: false; extent: 150@75.
	t borderWidth: 2; margins: 4@0; useRoundedCorners.	"Why not rounded?"
	"fancy font, shadow, rounded"
	t fontName: Preferences standardEToysFont familyName size: 18; textColor: Color blue; fillStyle: Color lightBrown.
	t addDropShadow.

"Strangeness here in order to avoid two offset copies of the default contents when operating in an mvc project before cursor enters the morphic window"
	t paragraph.
	^ t
]

{ #category : #'new-morph participation' }
TextMorph class >> includeInNewMorphMenu [
	^ true
]

{ #category : #'class initialization' }
TextMorph class >> initialize [	"TextMorph initialize"

	"Initialize the default text editor class to use"
	DefaultEditorClass := SmalltalkEditor.

	"Initialize constants shared by classes associated with text display."

	CaretForm := (ColorForm extent: 16@5
					fromArray: #(2r001100e26 2r001100e26 2r011110e26 2r111111e26 2r110011e26)
					offset: -2@0)
					colors: (Array with: Color transparent with: (TranslucentColor r: 0.0 g: 0.0 b: 0.8 alpha: 0.2)).

	self registerInFlapsRegistry.

]

{ #category : #'class initialization' }
TextMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#TextMorph. #authoringPrototype. 'Text' translatedNoop. 'Text that you can edit into anything you desire.' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#TextMorph	. #exampleBackgroundLabel. 'Background Label' translatedNoop. 'A piece of text that will occur on every card of the background' translatedNoop}
						forFlapNamed: 'Scripting'.
						cl registerQuad: {#TextMorph	. #exampleBackgroundField. 'Background Field' translatedNoop. 'A data field which will have a different value on every card of the background' translatedNoop}
						forFlapNamed: 'Scripting'.
						cl registerQuad: {#TextMorph	. #authoringPrototype. 'Simple Text'	translatedNoop. 'Text that you can edit into anything you wish' translatedNoop}
						forFlapNamed: 'Stack Tools'.
						cl registerQuad: {#TextMorph	. #fancyPrototype. 'Fancy Text' 	translatedNoop. 'A text field with a rounded shadowed border, with a fancy font.' translatedNoop}
						forFlapNamed: 'Stack Tools'.
						cl registerQuad: {#TextMorph	. #authoringPrototype. 'Text' translatedNoop. 'Text that you can edit into anything you desire.' translatedNoop}
						forFlapNamed: 'Supplies'.]
]

{ #category : #'instance creation' }
TextMorph class >> string: aString fontName: aName [

	^ self
		string: aString
		fontName: aName
		size: TextStyle defaultFont pixelSize
]

{ #category : #'instance creation' }
TextMorph class >> string: aString fontName: aName size: aSize [

	^ self
		string: aString
		fontName: aName
		size: aSize
		wrap: false "...because we don't know the initial width to wrap..."

]

{ #category : #'instance creation' }
TextMorph class >> string: aString fontName: aName size: aSize wrap: shouldWrap [

	^ self new
		string: aString fontName: aName size: aSize wrap: shouldWrap;
		yourself
]

{ #category : #'instance creation' }
TextMorph class >> string: aString size: pixelSize [

	^ self
		string: aString
		fontName: TextStyle defaultFont familyName
		size: pixelSize
]

{ #category : #'class initialization' }
TextMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #editing }
TextMorph >> acceptContents [
	"The message is sent when the user hits enter or Cmd-S.
	Accept the current contents and end editing.
	This default implementation does nothing."
	self updateFromParagraph
]

{ #category : #layout }
TextMorph >> acceptDroppingMorph: aMorph event: evt [
	"This message is sent when a morph is dropped onto me."

	self addMorphFront: aMorph fromWorldPosition: aMorph position.
		"Make a TextAnchor and install it in a run."
]

{ #category : #editing }
TextMorph >> acceptOnCR [
	"Answer whether the receiver wants to accept when the Return key is hit.  Generic TextMorph has no such feature, but subclasses may."

	^ false
]

{ #category : #menu }
TextMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	| outer |
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'text properties...' translated action: #changeTextColor.
	aCustomMenu addUpdating: #autoFitString target: self action: #autoFitOnOff.
	aCustomMenu addUpdating: #wrapString target: self action: #wrapOnOff.
	aCustomMenu add: 'text margins...' translated action: #changeMargins:.
	aCustomMenu add: 'add predecessor' translated action: #addPredecessor:.
	aCustomMenu add: 'add successor' translated action: #addSuccessor:.
	
	outer := self owner.
	outer ifNotNil: [
	outer isLineMorph ifTrue:
		[container isNil
			ifTrue: [Smalltalk at: #TextOnCurveContainer ifPresent: [:ignored | aCustomMenu add: 'follow owner''s curve' translated action: #followCurve]]
			ifFalse: [aCustomMenu add: 'reverse direction' translated action: #reverseCurveDirection.
					aCustomMenu add: 'set baseline' translated action: #setCurveBaseline:]]
		ifFalse:
		[self fillsOwner
			ifFalse: [aCustomMenu add: 'fill owner''s shape' translated action: #fillingOnOff]
			ifTrue: [aCustomMenu add: 'rectangular bounds' translated action: #fillingOnOff].
		self avoidsOcclusions
			ifFalse: [aCustomMenu add: 'avoid occlusions' translated action: #occlusionsOnOff]
			ifTrue: [aCustomMenu add: 'ignore occlusions' translated action: #occlusionsOnOff]]].
	aCustomMenu addLine.
	aCustomMenu add: 'holder for characters' translated action: #holderForCharacters

]

{ #category : #'submorphs-add\/remove' }
TextMorph >> addMorphFront: aMorph fromWorldPosition: wp [ 
	"Overridden for more specific re-layout and positioning"
	aMorph textAnchorProperties anchorLayout == #document 
		ifFalse:[^ self 
					anchorMorph: aMorph 
					at: wp 
					type: aMorph textAnchorProperties anchorLayout].
	self addMorphFront: aMorph.

]

{ #category : #'linked frames' }
TextMorph >> addPredecessor: evt [
	| newMorph |
	newMorph := self copy predecessor: predecessor successor: self.
	newMorph extent: self width @ 100.
	predecessor ifNotNil: [predecessor setSuccessor: newMorph].
	self setPredecessor: newMorph.
	predecessor recomposeChain.
	evt hand attachMorph: newMorph
]

{ #category : #'linked frames' }
TextMorph >> addSuccessor: evt [
	| newMorph |
	newMorph := self copy predecessor: self successor: successor.
	newMorph extent: self width @ 100.
	successor ifNotNil: [successor setPredecessor: newMorph].
	self setSuccessor: newMorph.
	successor recomposeChain.
	evt hand attachMorph: newMorph
]

{ #category : #private }
TextMorph >> adjustLineIndicesBy: delta [
	paragraph ifNotNil: [paragraph adjustLineIndicesBy: delta]
]

{ #category : #anchors }
TextMorph >> adjustTextAnchor: aMorph [
	"Later compute the new relative position of aMorph if it is #paragraph anchored."
]

{ #category : #anchors }
TextMorph >> anchorMorph: aMorph at: aPoint type: anchorType [
	
	| relPt index newText block |
	aMorph owner == self ifTrue:[self removeMorph: aMorph].
	self addMorphFront: aMorph.
	
	relPt := self transformFromWorld globalPointToLocal: aPoint.
	index := (self paragraph characterBlockAtPoint: relPt) stringIndex.
	newText := Text string: Character startOfHeader asString attribute: (TextAnchor new anchoredMorph: aMorph).
	anchorType == #inline ifTrue:[
			self paragraph replaceFrom: index to: index-1 with: newText displaying: false].
	anchorType == #document ifTrue: [
			index := index min: paragraph text size.
			index := paragraph text string lastIndexOf: Character cr startingAt: index.
			block := paragraph characterBlockForIndex: index+1.
			aMorph textAnchorProperties positionInDocument: (relPt x - bounds left) @ (relPt y - block top).
			self paragraph replaceFrom: index+1 to: index with: newText displaying: false].
	
	self fit.
]

{ #category : #drawing }
TextMorph >> areasRemainingToFill: aRectangle [
	"Overridden from BorderedMorph to test backgroundColor instead of (text) color."
	(self backgroundColor isNil or: [self backgroundColor asColor isTranslucent])
		ifTrue: [^ Array with: aRectangle].
	self wantsRoundedCorners
	ifTrue: [(self borderWidth > 0 and: [self borderColor isColor and: [self borderColor isTranslucent]])
				ifTrue: [^ aRectangle areasOutside: (self innerBounds intersect: self boundsWithinCorners)]
				ifFalse: [^ aRectangle areasOutside: self boundsWithinCorners]]
	ifFalse: [(self borderWidth > 0 and: [self borderColor isColor and: [self borderColor isTranslucent]])
				ifTrue: [^ aRectangle areasOutside: self innerBounds]
				ifFalse: [^ aRectangle areasOutside: self bounds]]
]

{ #category : #accessing }
TextMorph >> asText [
	^ text
]

{ #category : #accessing }
TextMorph >> autoFit: trueOrFalse [
	"Private! Please use #hResizing: and #vResizing:."
	
	"Whether I automatically adjust my size to fit text as it changes"
	
	self isAutoFit = trueOrFalse ifTrue: [^ self].
	self autoFitOnOff.
]

{ #category : #menu }
TextMorph >> autoFitOnOff [
	autoFit := self isAutoFit not.
	self isAutoFit ifTrue: [self fit]
]

{ #category : #menu }
TextMorph >> autoFitString [
	"Answer the string to put in a menu that will invite the user to 
	switch autoFit mode"
	^ (self isAutoFit
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'text auto fit' translated
]

{ #category : #containment }
TextMorph >> avoidsOcclusions [
	^container notNil and: [ container avoidsOcclusions ]

]

{ #category : #accessing }
TextMorph >> backgroundColor [
	^ self fillStyle.

]

{ #category : #accessing }
TextMorph >> backgroundColor: newColor [
	self fillStyle: newColor.

]

{ #category : #initialization }
TextMorph >> beAllFont: aFont [

	textStyle := TextStyle fontArray: (Array with: aFont).
	text ifNotNil: [text addAttribute: (TextFontReference toFont: aFont)].
	self releaseCachedState; changed
]

{ #category : #blinking }
TextMorph >> blinkStart [
	"Reset time for blink cursor after which blinking should actually start"
	^self valueOfProperty: #blinkStart ifAbsent:[Time millisecondClockValue]

]

{ #category : #blinking }
TextMorph >> blinkStart: msecs [
	"Reset time for blink cursor after which blinking should actually start"
	^self setProperty: #blinkStart toValue: msecs

]

{ #category : #accessing }
TextMorph >> borderWidth: newWidth [
	super borderWidth: newWidth.
	paragraph ifNotNil: [self composeToBounds].
]

{ #category : #geometry }
TextMorph >> bounds [
	container ifNil: [^ bounds].
	^ container bounds ifNil: [bounds]
]

{ #category : #editing }
TextMorph >> cancelEdits [
	"The message is sent when the user hits enter or Cmd-L.
	Cancel the current contents and end editing.
	This default implementation does nothing."
	self releaseParagraph
]

{ #category : #alignment }
TextMorph >> centered [ 
	self paragraph centered.
	self updateFromParagraph 
]

{ #category : #menu }
TextMorph >> changeMargins: evt [
	| handle origin aHand oldMargin newMargin |
	aHand := evt ifNil: [self primaryHand] ifNotNil: [evt hand].
	origin := aHand position.
	oldMargin := margins.
	(handle := HandleMorph new)
		forEachPointDo:
			[:newPoint | handle removeAllMorphs.
			handle addMorph:
				(LineMorph from: origin to: newPoint color: Color black width: 1).
			newMargin := (newPoint - origin max: 0@0) // 5.
			self margins: newMargin]
		lastPointDo:
			[:newPoint | handle deleteBalloon.
			self halo ifNotNil: [ :halo | halo addHandles].
			self rememberCommand:
				(Command new cmdWording: ('margin change for ' translated,self nameForUndoWording);
					undoTarget: self selector: #margins: argument: oldMargin;
					redoTarget: self selector: #margins: argument: newMargin;
					yourself)].
	aHand attachMorph: handle.
	handle setProperty: #helpAtCenter toValue: true.
	handle showBalloon:
'Move cursor down and to the right
to increase margin inset.
Click when done.' hand: evt hand.
	handle startStepping
]

{ #category : #menu }
TextMorph >> changeTextColor [
	"Change the color of the receiver -- triggered, e.g. from a menu"

	self openATextPropertySheet.
">>>>>
	ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self activeHand;
		target: self;
		selector: #textColor:;
		originalColor: self textColor;
		putUpFor: self near: self fullBoundsInWorld
<<<<"
]

{ #category : #editing }
TextMorph >> chooseAlignment [
	self editor changeAlignment.
	self updateFromParagraph
]

{ #category : #editing }
TextMorph >> chooseEmphasis [
	self editor changeEmphasisOrAlignment.
	self updateFromParagraph
]

{ #category : #editing }
TextMorph >> chooseEmphasisOrAlignment [
	self editor changeEmphasisOrAlignment.
	self updateFromParagraph
]

{ #category : #editing }
TextMorph >> chooseFont [
	self editor changeTextFont.
	self updateFromParagraph.
]

{ #category : #editing }
TextMorph >> chooseStyle [
	self editor changeStyle.
	self updateFromParagraph.
]

{ #category : #'event handling' }
TextMorph >> click: evt [

	self
		handleInteraction: [self editor click: evt]
		fromEvent: evt.
]

{ #category : #private }
TextMorph >> clippingRectangle [
	^ self innerBounds
]

{ #category : #private }
TextMorph >> composeToBounds [
	"Compose my text to fit my bounds.
	If any text lies outside my bounds, it will be clipped, or
	if I have successors, it will be shown in the successors."
	| |
	self releaseParagraph; paragraph.
	container ifNotNil:
		[self privateBounds: container bounds truncated].
	self paragraph positionWhenComposed: self position.
	successor ifNotNil:
		[successor predecessorChanged].


]

{ #category : #private }
TextMorph >> compositionRectangle [
	| compRect |
	compRect := self innerBounds.
	margins ifNotNil: [compRect := compRect insetBy: margins].
	compRect width < 9 ifTrue: [compRect := compRect withWidth: 9].
	compRect height < 16 ifTrue: [compRect := compRect withHeight: 16].
	^ compRect
]

{ #category : #geometry }
TextMorph >> container [
	"Return the container for composing this text.  There are four cases:
	1.  container is specified as, eg, an arbitrary shape,
	2.  container is specified as the bound rectangle, because
		this morph is linked to others,
	3.  container is nil, and wrap is true -- grow downward as necessary,
	4.  container is nil, and wrap is false -- grow in 2D as necessary."

	container ifNil:
		[successor ifNotNil: [^ self compositionRectangle].
		wrapFlag ifTrue: [^ self compositionRectangle withHeight: self maximumContainerExtent y].
		^ self compositionRectangle topLeft extent: self maximumContainerExtent].
	^ container
]

{ #category : #'geometry testing' }
TextMorph >> containsPoint: aPoint [
	(super containsPoint: aPoint) ifFalse: [^ false].  "Not in my bounds"
	container ifNil: [^ true].  "In bounds of simple text"
	self startingIndex > text size ifTrue:
		["make null text frame visible"
		^ super containsPoint: aPoint].
	"In complex text (non-rect container), test by line bounds"
	^ self paragraph containsPoint: aPoint

]

{ #category : #accessing }
TextMorph >> contents [

	^ text
]

{ #category : #accessing }
TextMorph >> contents: stringOrText [
	^ self newContents: stringOrText
]

{ #category : #accessing }
TextMorph >> contents: stringOrText wrappedTo: width [
	"Accept new text contents.  Lay it out, wrapping to width.
	Then fit my height to the result."
	self newContents: ''.
	wrapFlag := true.
	super extent: width truncated@self height.
	self newContents: stringOrText
]

{ #category : #accessing }
TextMorph >> contentsAsIs: stringOrText [
	"Accept new text contents with line breaks only as in the text.
	Fit my width and height to the result."
	wrapFlag := false.
	container ifNotNil: [container fillsOwner ifTrue: [wrapFlag := true]].
	self newContents: stringOrText
]

{ #category : #accessing }
TextMorph >> contentsWrapped: stringOrText [
	"Accept new text contents.  Lay it out, wrapping within my current width.
	Then fit my height to the result."
	wrapFlag := true.
	self newContents: stringOrText
]

{ #category : #'objects from disk' }
TextMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	self borderWidth ifNil: [
		self borderWidth: 0.
		self removeProperty: #fillStyle].
	^ super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #copying }
TextMorph >> copy [
	^ super copy text: text copy textStyle: textStyle copy 
		wrap: wrapFlag color: color
		predecessor: nil successor: nil
]

{ #category : #accessing }
TextMorph >> crAction [
	"Return the action to perform when encountering a CR in the input"
	^self valueOfProperty: #crAction
]

{ #category : #accessing }
TextMorph >> crAction: aMessageSend [
	"Return the action to perform when encountering a CR in the input"
	^self setProperty: #crAction toValue: aMessageSend
]

{ #category : #private }
TextMorph >> createParagraph [

	self setProperty: #CreatingParagraph toValue: true.

	[
		self setDefaultContentsIfNil.

		"...Code here to recreate the paragraph..."
		paragraph := (self paragraphClass new textOwner: self owner).
		paragraph wantsColumnBreaks: successor notNil.
		paragraph
			compose: text
			style: textStyle copy
			from: self startingIndex
			in: self container.
		wrapFlag ifFalse:
			["Was given huge container at first... now adjust"
			paragraph adjustRightX].
		paragraph focused: (self currentHand keyboardFocus == self).
	
		self fit.
	] ensure: [self removeProperty: #CreatingParagraph].

	^ paragraph
]

{ #category : #accessing }
TextMorph >> cursor [
	"Answer the receiver's logical cursor position"

	| loc |
	loc := self valueOfProperty: #textCursorLocation  ifAbsentPut: [1].
	loc := loc min: text string size.
	^ loc rounded
	
]

{ #category : #accessing }
TextMorph >> cursorWrapped: aNumber [
	"Set the cursor as indicated"

	self setProperty: #textCursorLocation toValue: (((aNumber rounded - 1) \\  text string size) + 1)

	
]

{ #category : #drawing }
TextMorph >> debugDrawLineRectsOn: aCanvas [
	"Shows where text line rectangles are"
	self paragraph lines do:
		[:line | aCanvas frameRectangle: line rectangle color: Color brown]

]

{ #category : #initialization }
TextMorph >> defaultBorderWidth [
	^ 0
]

{ #category : #initialization }
TextMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #geometry }
TextMorph >> defaultLineHeight [
	^ textStyle lineGrid
]

{ #category : #'submorphs-add\/remove' }
TextMorph >> delete [
	predecessor ifNotNil: [predecessor setSuccessor: successor].
	successor ifNotNil: [successor setPredecessor: predecessor.
						successor recomposeChain].
	super delete
]

{ #category : #layout }
TextMorph >> doLayoutIn: layoutBounds [
	"Compute paragraph here to reduce visual flickering. Also update the layout of any submorphs, which can be added via text anchors.
	
	autoFit + wrapFlag -> hResizing: #rigid + vResizing: #shrinkWrap
	autoFIt + no wrapFlag -> hResizing: #shrinkWrap + vResizing: #shrinkWrap
	no autoFit + wrapFlag -> hResizing: #rigid + vRresizing: #rigid
	no autoFit + no wrapFlag -> hResizing: #rigid + vRresizing: #rigid"
	
	self submorphsDo: [:m | m fullBounds].	
	self paragraph.
	fullBounds := self privateFullBounds.
]

{ #category : #drawing }
TextMorph >> drawNullTextOn: aCanvas [
	"make null text frame visible"

	aCanvas isPostscriptCanvas ifFalse: [
	aCanvas fillRectangle: bounds color: 
		((Color black) alpha: 0.1).
		]
]

{ #category : #drawing }
TextMorph >> drawOn: aCanvas [
	"Draw the receiver on a canvas"

	| fauxBounds |
	self setDefaultContentsIfNil.
	super drawOn: aCanvas.  "Border and background if any"
	false ifTrue: [self debugDrawLineRectsOn: aCanvas].  "show line rects for debugging"
	(self startingIndex > text size)
		ifTrue: [self drawNullTextOn: aCanvas].
	"Hack here:  The canvas expects bounds to carry the location of the text, but we also need to communicate clipping."
	fauxBounds := self bounds topLeft corner: self innerBounds bottomRight.
	aCanvas paragraph: self paragraph bounds: fauxBounds color: color
]

{ #category : #'multi level undo' }
TextMorph >> editHistory [
	^ self editor history
]

{ #category : #accessing }
TextMorph >> editor [
	"Return my current editor, or install a new one."
	editor ifNotNil: [^ editor].
	^ self installEditorToReplace: nil
]

{ #category : #private }
TextMorph >> editorClass [
	"Answer the class used to create the receiver's editor"
	^DefaultEditorClass
]

{ #category : #accessing }
TextMorph >> elementCount [
	"Answer how many sub-objects are within me"

	^ self text string size 
]

{ #category : #editing }
TextMorph >> enterClickableRegion: evt [
	| index isLink |
	evt hand hasSubmorphs ifTrue:[^false].
	paragraph ifNotNil:[
		index := (paragraph characterBlockAtPoint: evt position) stringIndex.
		isLink := (paragraph text attributesAt: index forStyle: paragraph textStyle) 
					anySatisfy:[:attr| attr mayActOnClick].
		isLink ifTrue: [
			evt hand showTemporaryCursor: Cursor webLink.
			^ true]].
	^ false

]

{ #category : #geometry }
TextMorph >> extent: aPoint [ 
	| newExtent priorEditor |
	bounds extent = aPoint ifTrue: [^ self].
	priorEditor := editor.
	self isAutoFit
		ifTrue: [wrapFlag ifFalse: [^ self].  "full autofit can't change"
				newExtent := aPoint truncated.
				newExtent x = self extent x ifTrue: [^ self].  "No change of wrap width"
				self releaseParagraph.  "invalidate the paragraph cache"
				super extent: newExtent.
				priorEditor
					ifNil: [self fit]  "since the width has changed..."
					ifNotNil: [self installEditorToReplace: priorEditor]]
		ifFalse: [super extent: aPoint truncated.
				wrapFlag ifFalse: [^ self].  "no effect on composition"
				self composeToBounds]

]

{ #category : #'visual properties' }
TextMorph >> fillStyle [
	"Return the current fillStyle of the receiver."
	^ self
		valueOfProperty: #fillStyle
		ifAbsent: [backgroundColor
				ifNil: [Color transparent]]
]

{ #category : #'visual properties' }
TextMorph >> fillStyle: aFillStyle [
	"Set the current fillStyle of the receiver."
	self setProperty: #fillStyle toValue: aFillStyle.
	"Workaround for Morphs not yet converted"
	backgroundColor := aFillStyle asColor.
	self changed.
]

{ #category : #containment }
TextMorph >> fillingOnOff [
	"Establish a container for this text, with opposite filling status"
	self fillsOwner: (self fillsOwner not)
]

{ #category : #containment }
TextMorph >> fillsOwner [
	"Answer true if I fill my owner's shape."
	^container notNil and: [container fillsOwner]
]

{ #category : #containment }
TextMorph >> fillsOwner: aBoolean [ 
	self fillsOwner == aBoolean
		ifTrue: [^ self].
	self
		setContainer: (aBoolean
				ifTrue: [wrapFlag := true.
					container
						ifNil: [TextContainer new for: self minWidth: textStyle lineGrid * 2]
						ifNotNil: [container fillsOwner: true]]
				ifFalse: [self avoidsOcclusions
						ifFalse: [ nil ]
						ifTrue: [container fillsOwner: false]])
]

{ #category : #'linked frames' }
TextMorph >> firstCharacterIndex [
	^ self paragraph firstCharacterIndex
]

{ #category : #'linked frames' }
TextMorph >> firstInChain [
	"Return the first morph in a chain of textMorphs"

	| first |
	first := self.
	[first predecessor isNil] whileFalse: [first := first predecessor].
	^first
]

{ #category : #private }
TextMorph >> fit [
	"Adjust my bounds to fit the text.  Should be a no-op if autoFit is not specified.
	Required after the text changes,
	or if wrapFlag is true and the user attempts to change the extent."

	| newExtent para cBounds lastOfLines heightOfLast |
	self isAutoFit 
		ifTrue: 
			[
			newExtent := self paragraph extent max: 1 @ self defaultLineHeight.
			newExtent := newExtent + (2 * self borderWidth).
			margins 
				ifNotNil: [newExtent := ((0 @ 0 extent: newExtent) expandBy: margins) extent].
			newExtent ~= bounds extent 
				ifTrue: 
					[(container isNil and: [successor isNil]) 
						ifTrue: 
							[para := paragraph.	"Save para (layoutChanged smashes it)"
							super extent: newExtent.
							paragraph := para]].
			container notNil & successor isNil 
				ifTrue: 
					[cBounds := container bounds truncated.
					"23 sept 2000 - try to allow vertical growth"
					lastOfLines := self paragraph lines last.
					heightOfLast := lastOfLines bottom - lastOfLines top.
					(lastOfLines last < text size 
						and: [lastOfLines bottom + heightOfLast >= self bottom]) 
							ifTrue: 
								[container releaseCachedState.
								cBounds := cBounds origin corner: cBounds corner + (0 @ heightOfLast)].
					self privateBounds: cBounds]].

	"These statements should be pushed back into senders"
	self paragraph positionWhenComposed: self position.
	successor ifNotNil: [successor predecessorChanged].
	self changed	"Too conservative: only paragraph composition
					should cause invalidation."
]

{ #category : #'objects from disk' }
TextMorph >> fixUponLoad: aProject seg: anImageSegment [
	"We are in an old project that is being loaded from disk. Fix up conventions that have changed."

	| substituteFont |
	wrapFlag ifNil:[wrapFlag := true].
	substituteFont := aProject projectParameters at: #substitutedFont ifAbsent: [#none].
	(substituteFont ~~ #none and: [self textStyle fontArray includes: substituteFont])
			ifTrue: [ self fit ].

	^ super fixUponLoad: aProject seg: anImageSegment
]

{ #category : #menu }
TextMorph >> followCurve [
	self setContainer: (TextOnCurveContainer new baseline: 0; textDirection: 1).
	self changed
]

{ #category : #accessing }
TextMorph >> font: aFont [
	| newTextStyle |
	newTextStyle := aFont textStyle copy ifNil: [ TextStyle fontArray: { aFont } ].
	textStyle := newTextStyle.
	text addAttribute: (TextFontChange fontNumber: (newTextStyle fontIndexOf: aFont)).
	paragraph ifNotNil: [paragraph textStyle: newTextStyle]
]

{ #category : #initialization }
TextMorph >> fontName: fontName pointSize: fontSize [
	| newTextStyle |
	newTextStyle := ((TextStyle named: fontName asSymbol) ifNil: [ TextStyle default ]) copy.
	newTextStyle ifNil: [self error: 'font ', fontName, ' not found.'].

	textStyle := newTextStyle.
	text addAttribute: (TextFontChange fontNumber: (newTextStyle fontIndexOfPointSize: fontSize)).
	self releaseParagraph.
]

{ #category : #initialization }
TextMorph >> fontName: fontName size: fontSize [
	| newTextStyle |
	newTextStyle := ((TextStyle named: fontName asSymbol) ifNil: [ TextStyle default ]) copy.
	textStyle := newTextStyle.
	text addAttribute: (TextFontChange fontNumber: (newTextStyle fontIndexOfSize: fontSize)).
	self releaseParagraph.
]

{ #category : #printing }
TextMorph >> fullPrintOn: aStream [

	aStream nextPutAll: '('.
	super fullPrintOn: aStream.
	aStream nextPutAll: ') contents: '; print: text
]

{ #category : #'scripting access' }
TextMorph >> getAllButFirstCharacter [
	"Obtain all but the first character from the receiver; if that would be empty, return a black dot"

	| aString |
	^ (aString := text string) size > 1 
		ifTrue: [aString copyFrom: 2 to: aString size] 
		ifFalse: ['·']
]

{ #category : #accessing }
TextMorph >> getFirstCharacter [
	"obtain the first character from the receiver if it is empty, return a  
	black dot"
	| aString |
	^ (aString := text string) isEmpty
		ifTrue: ['·']
		ifFalse: [aString first asString] 
]

{ #category : #accessing }
TextMorph >> getLastCharacter [
	"obtain the last character from the receiver if it is empty, return a black dot"

	| aString |
	^ (aString := text string) size > 0 
		ifTrue: [aString last asString] 
		ifFalse: ['·']
]

{ #category : #'event handling' }
TextMorph >> getMenu: shiftKeyState [ 
	^ (shiftKeyState not or: [Preferences noviceMode])
		ifTrue: [TextEditor yellowButtonMenu]
		ifFalse: [TextEditor shiftedYellowButtonMenu]
]

{ #category : #'submorphs-add\/remove' }
TextMorph >> goBehind [
	"We need to save the container, as it knows about fill and run-around"
	| cont |
	container ifNil: [^ super goBehind].
	self releaseParagraph.  "Cause recomposition"
	cont := container.  "Save the container"
	super goBehind.  "This will change owner, nilling the container"
	container := cont.  "Restore the container"
	self changed
]

{ #category : #'layout-properties' }
TextMorph >> hResizing [

	self layoutProperties ifNotNil: [:props |
		^ props hResizing].
	
	(self isAutoFit and: [self isWrapped])
		ifTrue: [^ #rigid]. "or #spaceFill"
	(self isAutoFit and: [self isWrapped not])
		ifTrue: [^ #shrinkWrap].
	(self isAutoFit not and: [self isWrapped])
		ifTrue: [^ #rigid]. "or #spaceFill"
	(self isAutoFit not and: [self isWrapped not])
		ifTrue: [^ #rigid]. "or #spaceFill"
]

{ #category : #'layout-properties' }
TextMorph >> hResizing: aSymbol [

	super hResizing: aSymbol.
	
	aSymbol == #shrinkWrap
		ifTrue: [self autoFit: true; wrapFlag: false];
		ifFalse: ["#rigid or #spaceFill -- Prefer to not cut out text."
			self autoFit: self vResizing == #shrinkWrap; wrapFlag: true].

	self releaseParagraph.
]

{ #category : #editing }
TextMorph >> handleEdit: editBlock [
	"Ensure that changed areas get suitably redrawn"
	| result |
	self selectionChanged.  "Note old selection"
	result := editBlock value.
	self selectionChanged.  "Note new selection"
	self updateFromParagraph.  "Propagate changes as necessary"
	^result
]

{ #category : #editing }
TextMorph >> handleInteraction: interactionBlock fromEvent: evt [
	"Perform the changes in interactionBlock, noting any change in selection
	and possibly a change in the size of the paragraph (ar 9/22/2001 - added for TextPrintIts)"

	| oldEditor oldParagraph oldText oldSelection |
	oldEditor := editor.
	oldParagraph := paragraph.
	oldText := oldParagraph text copy.
	oldSelection := oldParagraph selectionRects. "already copy"

	"Note old selection."
	self selectionChanged: oldSelection.
	
	interactionBlock value.

	(oldParagraph == paragraph) ifTrue:[
		"this will not work if the paragraph changed"
		editor := oldEditor.     "since it may have been changed while in block"
	].
	
	"Note new selection."
	paragraph selectionRects in: [:newSelection |
		newSelection ~= oldSelection ifTrue: [
			self selectionChanged: newSelection]].
		
	(oldText = paragraph text and: [ oldText runs = paragraph text runs ])
		ifFalse:[ 
			self paragraph composeAll.
			self updateFromParagraph ].
	
	self flag: #ImmPlugin.
	"self setCompositionWindow."
]

{ #category : #'events-processing' }
TextMorph >> handleKeystroke: anEvent [
	"Overwritten to support tab-among-fields preference."

	| pasteUp |
	anEvent wasHandled ifTrue:[^self].
	(self handlesKeyboard: anEvent) ifFalse: [^ self].
	(anEvent hand keyboardFocus ~~ self
		and: [self handlesKeyboardOnlyOnFocus])
			ifTrue: [^ self].

	anEvent keyCharacter = Character tab ifTrue: [
		"Allow passing through text morph inside pasteups"
		(self wouldAcceptKeyboardFocusUponTab
			and: [(pasteUp := self pasteUpMorphHandlingTabAmongFields) notNil])
				ifTrue: [
					anEvent wasHandled: true.
					^ pasteUp tabHitWithEvent: anEvent]].
	
	^ super handleKeystroke: anEvent
]

{ #category : #'events-processing' }
TextMorph >> handleMouseMove: anEvent [
	"Re-implemented to allow for mouse-up move events"
	anEvent wasHandled ifTrue:[^self]. "not interested"
	(anEvent hand hasSubmorphs) ifTrue:[^self].
	anEvent wasHandled: true.
	self mouseMove: anEvent.
	(anEvent anyButtonPressed and:[anEvent hand mouseFocus == self]) ifFalse:[^self].
	(self handlesMouseStillDown: anEvent) ifTrue:[
		"Step at the new location"
		self startStepping: #handleMouseStillDown: 
			at: Time millisecondClockValue
			arguments: {anEvent copy resetHandlerFields}
			stepTime: 1].

]

{ #category : #'event handling' }
TextMorph >> handlesKeyboard: evt [
	^true
]

{ #category : #'event handling' }
TextMorph >> handlesMouseDown: evt [
	self isPartsDonor ifTrue: [^ false].
	^ self innerBounds containsPoint: evt cursorPoint
]

{ #category : #'event handling' }
TextMorph >> handlesMouseOver: evt [
	^ self isPartsDonor not
]

{ #category : #'event handling' }
TextMorph >> hasFocus [
	^editor notNil
]

{ #category : #accessing }
TextMorph >> hasTranslucentColor [
	"Overridden from BorderedMorph to test backgroundColor instead of (text) color."

	^ self backgroundColor isNil
		or: [self backgroundColor isColor and: [self backgroundColor isTranslucentColor]]
		or: [self borderColor isColor and: [self borderColor isTranslucentColor]]
]

{ #category : #editing }
TextMorph >> hasUnacceptedEdits: aBoolean [
	"Ignored here, but noted in TextMorphForEditView"

]

{ #category : #menu }
TextMorph >> holderForCharacters [
	"Hand the user a Holder that is populated with individual text morphs representing my characters"

	| aHolder |
	aHolder := ScriptingSystem prototypicalHolder.
	aHolder setNameTo: 'H', self externalName.
	text string do:
		[:aChar |
			aHolder addMorphBack: (TextMorph new contents: aChar asText)].
	aHolder setProperty: #donorTextMorph toValue: self.
	aHolder fullBounds.
	aHolder openInHand
]

{ #category : #initialization }
TextMorph >> initialize [

	super initialize.

	textStyle := TextStyle default copy.
	
	wrapFlag := false.
	autoFit := true.
]

{ #category : #'scripting access' }
TextMorph >> insertCharacters: aString [
	"Insert the characters from the given source at my current cursor position"

	| aLoc aText attributes |
	aLoc := self cursor max: 1.
	aText := aLoc > text size
		ifTrue: [aString asText]
		ifFalse: [
			attributes := (text attributesAt: aLoc)
				select: [:attr | attr mayBeExtended].
			Text string: aString attributes: attributes].
	paragraph replaceFrom: aLoc to: (aLoc - 1) with: aText displaying: true.
	self updateFromParagraph  
]

{ #category : #'scripting access' }
TextMorph >> insertContentsOf: aPlayer [
	"Insert the characters from the given player at my current cursor position"

	| aLoc |
	aLoc := self cursor.
	paragraph replaceFrom: aLoc to: (aLoc - 1) with: aPlayer getStringContents displaying: true.
	self updateFromParagraph  
]

{ #category : #private }
TextMorph >> installEditorToReplace: priorEditor [
	"Install an editor for my paragraph.  This constitutes 'hasFocus'.
	If priorEditor is not nil, then initialize the new editor from its state.
	We may want to rework this so it actually uses the prior editor."

	| stateArray |
	priorEditor ifNotNil: [stateArray := priorEditor stateArray].
	editor := self editorClass new morph: self.
	editor changeParagraph: self paragraph.
	priorEditor
		ifNil: [editor history: TextEditorCommandHistory new]
		ifNotNil: [editor stateArrayPut: stateArray].
	self selectionChanged.
	^ editor
]

{ #category : #accessing }
TextMorph >> isAutoFit [
	"For migrating old instances only. See #initialize."
	
	^ autoFit ifNil: [autoFit := true]
]

{ #category : #'linked frames' }
TextMorph >> isLinkedTo: aMorph [
	self firstInChain withSuccessorsDo:
		[:m | m == aMorph ifTrue: [^ true]].
	^ false
]

{ #category : #classification }
TextMorph >> isTextMorph [
	^true
]

{ #category : #accessing }
TextMorph >> isWrapped [
	
	^wrapFlag
]

{ #category : #alignment }
TextMorph >> justified [ 
	self paragraph justified.
	self updateFromParagraph
]

{ #category : #'event handling' }
TextMorph >> keyStroke: evt [
	"Handle a keystroke event."
	
	self resetBlinkCursor. "don't blink during type-in"
	ToolSet 
		codeCompletionAround: [
			evt keyValue = 13 ifTrue: [ "CR - check for special action"
				self crAction ifNotNil: [ :action |
					"Note: Code below assumes that this was some
					input field reacting on CR. Break the keyboard
					focus so that the receiver can be safely deleted."
					evt hand newKeyboardFocus: nil.
					^action valueWithEnoughArguments: { evt } ] ].
			self handleInteraction: [ self editor keyStroke: evt ] fromEvent: evt.
			"self updateFromParagraph."
			super keyStroke: evt  "sends to keyStroke event handler, if any" ]
		textMorph: self
		keyStroke: evt
]

{ #category : #'event handling' }
TextMorph >> keyboardFocusChange: weHaveFocus [ 

	paragraph ifNotNil: [:para | para focused: weHaveFocus].

	weHaveFocus
		ifTrue: [ "A hand is wanting to send us characters..."
			self hasFocus ifFalse: [self editor	"Forces install"].
			Editor blinkingCursor
				ifTrue: [self startBlinking]
				ifFalse: [self resetBlinkCursor "ensure caret visible"]]
		ifFalse: [ "A hand has clicked elsewhere..."
			self world ifNotNil: [:w |
				self flag: #suspicious. "mt: Why should this be called with 'false' if a hand holds on the focus? Do hands not talk to each other before sending this call? They should..."
				w handsDo: [:h | h keyboardFocus == self ifTrue: [^self]].
				"Release control unless some hand is still holding on"
				self releaseEditor].
			self stopBlinking].

]

{ #category : #'linked frames' }
TextMorph >> lastCharacterIndex [
	^ self paragraph lastCharacterIndex
]

{ #category : #layout }
TextMorph >> layoutChanged [
	"For embedded morphs, we have to invalidate our paragraph if those morphs invalidate their layout. Since paragraph creation will also change this morph's bounds, ignore that case."

	"2019-10-16 mt Does not work. Breaks up scroll ranges after saving a method. Breaks highlight of opening parenthesis in Shout."
	"(self hasProperty: #CreatingParagraph) ifFalse: [self releaseParagraph]."

	^ super layoutChanged
]

{ #category : #alignment }
TextMorph >> leftFlush [ 
	self paragraph leftFlush.
	self updateFromParagraph
]

{ #category : #caching }
TextMorph >> loadCachedState [
	"Prepare for fast response -- next page of a book?"
	self paragraph
]

{ #category : #accessing }
TextMorph >> margins [

	^margins
]

{ #category : #accessing }
TextMorph >> margins: newMargins [
	"newMargins can be a number, point or rectangle, as allowed by, eg, insetBy:."

	margins := newMargins.
	self composeToBounds
]

{ #category : #geometry }
TextMorph >> maximumContainerExtent [
	"For text composition. Returns the maximum area for text to be composed."
	
	^ 9999999@9999999
]

{ #category : #layout }
TextMorph >> minHeight [

	| result |
	textStyle ifNil: [^ 16].

	result := (textStyle lineGrid + 2) + (self borderWidth*2).
	margins ifNil: [^ result].
	
	^ margins isRectangle
		ifTrue: [result + margins top + margins bottom]
		ifFalse: [margins isPoint
			ifTrue: [result + margins y + margins y]
			ifFalse: [result + (2*margins)]]
]

{ #category : #layout }
TextMorph >> minWidth [

	| result |
	textStyle ifNil: [^ 9].

	result := 9 + (self borderWidth*2).
	margins ifNil: [^ result].
	
	^ margins isRectangle
		ifTrue: [result + margins left + margins right]
		ifFalse: [margins isPoint
			ifTrue: [result + margins x + margins x]
			ifFalse: [result + (2*margins)]]
]

{ #category : #'event handling' }
TextMorph >> mouseDown: evt [ 
	"Make this TextMorph be the keyboard input focus, if it isn't  
	already, and repond to the text selection gesture."
	
	evt yellowButtonPressed ifTrue: [
		"First check for option (menu) click"
		^ self yellowButtonActivity: evt shiftPressed].

	"Show the caret immediately on mouse down to give user feedback."
	self resetBlinkCursor.

	"If focus does not follow the mouse cursor and we click below everything, just grab the focus to not destroy the selection."
	((self hasKeyboardFocus: evt hand) not and: [(self bounds containsPoint: evt position) not])
		ifTrue: [evt hand newKeyboardFocus: self]
		ifFalse: [
			evt hand newKeyboardFocus: self.
			self
				handleInteraction: [self mouseEnter: evt. editor mouseDown: evt]
				fromEvent: evt].
]

{ #category : #'event handling' }
TextMorph >> mouseEnter: evt [ 

	self editor updateCursorForEvent: evt.
]

{ #category : #'event handling' }
TextMorph >> mouseLeave: evt [ 

	evt hand showTemporaryCursor: nil.
]

{ #category : #'event handling' }
TextMorph >> mouseMove: evt [

	evt redButtonPressed ifFalse: [
		(self enterClickableRegion: evt)
			ifFalse: [self editor updateCursorForEvent: evt].
		^ self].

	self
		handleInteraction: [self editor mouseMove: evt]
		fromEvent: evt.
]

{ #category : #'event handling' }
TextMorph >> mouseUp: evt [
	self handleInteraction: [editor mouseUp: evt] fromEvent: evt
]

{ #category : #accessing }
TextMorph >> newContents: stringOrText [ 
	"Accept new text contents."
	| newText embeddedMorphs oldSelection |
	newText := stringOrText isString 
		ifTrue: [Text fromString: stringOrText copy ]
		ifFalse: [ stringOrText copy asText.	"should be veryDeepCopy?" ].

	(text = newText and: [text runs = newText runs]) ifTrue: [^ self].	"No substantive change"
	text ifNotNil: [(embeddedMorphs := text embeddedMorphs)
			ifNotNil: 
				[self removeAllMorphsIn: embeddedMorphs.
				embeddedMorphs do: [:m | m delete]]].

	oldSelection := editor ifNotNil: [:ed | ed selectionInterval].
	text := newText.

	"add all morphs off the visible region; they'll be moved into the right 
	place when they become visible. (this can make the scrollable area too 
	large, though)"
	newText embeddedMorphs do: 
		[:m | 
		self addMorph: m.
		m position: -1000 @ 0].
	self releaseParagraph.
	"update the paragraph cache"
	self paragraph.
	oldSelection ifNotNil: [:sel | self selectFrom: sel first to: sel last].
	"re-instantiate to set bounds"
	self world ifNotNil: [self world startSteppingSubmorphsOf: self]
]

{ #category : #containment }
TextMorph >> occlusionsOnOff [
	"Establish a container for this text, with opposite occlusion avoidance status"
	self setContainer:
	(container
	ifNil: [(TextContainer new for: self minWidth: textStyle lineGrid*2)
							fillsOwner: false; avoidsOcclusions: true]
	ifNotNil: [(container avoidsOcclusions and: [container fillsOwner not])
			ifTrue: [nil  "Return to simple rectangular bounds"]
			ifFalse: [container avoidsOcclusions: container avoidsOcclusions not]])
]

{ #category : #blinking }
TextMorph >> onBlinkCursor [

	| para |
	para := paragraph ifNil: [^nil].
	Time millisecondClockValue < self blinkStart 
		ifTrue: [para showCaret: para focused]
		ifFalse: [para showCaret: para showCaret not].
	para caretRect ifNotNil: [ :r | self invalidRect: r].
]

{ #category : #'change reporting' }
TextMorph >> ownerChanged [
	| priorEditor |
	super ownerChanged.
	container ifNotNil: 
			[editor isNil 
				ifTrue:
					[self releaseParagraph.
					(container isKindOf: TextContainer) ifTrue:
						["May need to recompose due to changes in owner"
						self installEditorToReplace: nil.
						self releaseParagraph]]
				ifFalse: 
					[priorEditor := editor.
					self releaseParagraph.
					self installEditorToReplace: priorEditor]]
]

{ #category : #private }
TextMorph >> paragraph [
	"Paragraph instantiation is lazy -- create it only when needed"

	^ paragraph ifNil: [self createParagraph]
]

{ #category : #private }
TextMorph >> paragraphClass [
	container ifNil: [^ NewParagraph].
	^ container paragraphClass
]

{ #category : #editing }
TextMorph >> passKeyboardFocusTo: otherMorph [ 
	| w |
	self flag: #arNote.	"Do we need this?!"
	(w := self world) isNil 
		ifFalse: 
			[w 
				handsDo: [:h | h keyboardFocus == self ifTrue: [h newKeyboardFocus: otherMorph]]]
]

{ #category : #'linked frames' }
TextMorph >> predecessor [
	^ predecessor
]

{ #category : #private }
TextMorph >> predecessor: pred successor: succ [
	"Private -- for use only in morphic duplication"
	predecessor := pred.
	successor := succ.

]

{ #category : #private }
TextMorph >> predecessorChanged [
	| newStart oldStart |
	(self hasProperty: #CreatingParagraph) ifTrue: [^self].
	newStart := predecessor isNil 
				ifTrue: [1]
				ifFalse: [predecessor lastCharacterIndex + 1].
	(self paragraph adjustedFirstCharacterIndex ~= newStart 
		or: [newStart >= text size]) 
			ifTrue: 
				[paragraph composeAllStartingAt: newStart.
				self fit]
			ifFalse: 
				["If the offset to end of text has not changed, just slide"
				oldStart := self firstCharacterIndex.
				self withSuccessorsDo: [:m | m adjustLineIndicesBy: newStart - oldStart]]
]

{ #category : #'Multilingual-ImmPlugin' }
TextMorph >> preferredKeyboardPosition [
	| default rects |
	self flag: #ImmPlugin.
	default := (self bounds: self bounds in: self world) topLeft.
	paragraph
		ifNil: [^ default].
	rects := paragraph selectionRects.
	rects size = 0
		ifTrue: [^ default].
	^ rects first bottomLeft
]

{ #category : #geometry }
TextMorph >> privateMoveBy: delta [ 
	super privateMoveBy: delta.
	editor 
		ifNil: [ paragraph ifNotNil: [paragraph moveBy: delta]]
		ifNotNil: [ 
			"When moving text with an active editor, save and restore all state."
			paragraph moveBy: delta.
			self installEditorToReplace: editor]
]

{ #category : #private }
TextMorph >> privateOwner: newOwner [
	"Nil the container when text gets extracted"
	super privateOwner: newOwner.
	container ifNotNil: [
		newOwner ifNotNil: [
			newOwner isWorldOrHandMorph ifTrue: [self setContainer: nil]]]
]

{ #category : #accessing }
TextMorph >> readOnly [

	^ readOnly ifNil: [false]
]

{ #category : #accessing }
TextMorph >> readOnly: aBoolean [

	readOnly := aBoolean.
]

{ #category : #containment }
TextMorph >> recognizerArena [
	"Answer the rectangular area, in world coordinates, that the character recognizer should regard as its tablet"

	| outer |
	^ (outer := self ownerThatIsA: PluggableTextMorph)
		ifNotNil: [outer boundsInWorld]
		ifNil: [self boundsInWorld]
]

{ #category : #'linked frames' }
TextMorph >> recomposeChain [
	"Recompose this textMorph and all that follow it."
	self withSuccessorsDo:
		[:m |  m text: text textStyle: textStyle;  "Propagate new style if any"
				releaseParagraph;  "Force recomposition"
				fit  "and propagate the change"]
]

{ #category : #caching }
TextMorph >> releaseCachedState [

	super releaseCachedState.
	self releaseParagraph; paragraph.

]

{ #category : #private }
TextMorph >> releaseEditor [ 
	"Release the editor for my paragraph.  This morph no longer 'hasFocus'."
	editor ifNotNil:
		[self selectionChanged.
		self paragraph selectionStart: nil selectionStop: nil.
		editor := nil].
]

{ #category : #private }
TextMorph >> releaseParagraph [

	"a slight kludge so subclasses can have a bit more control over whether the paragraph really 
	gets released. important for GeeMail since the selection needs to be accessible even if the 
	hand is outside me"

	self releaseParagraphReally.

]

{ #category : #private }
TextMorph >> releaseParagraphReally [

	"a slight kludge so subclasses can have a bit more control over whether the paragraph really 
	gets released. important for GeeMail since the selection needs to be accessible even if the 
	hand is outside me"

	"Paragraph instantiation is lazy -- it will be created only when needed"
	self releaseEditor.
	paragraph ifNotNil:
		[paragraph := nil].
	container ifNotNil:
		[container releaseCachedState]
]

{ #category : #private }
TextMorph >> removedMorph: aMorph [
	| range |
	range := text find: (TextAnchor new anchoredMorph: aMorph).
	range ifNotNil: [
		self paragraph 
			replaceFrom: range first 
			to: range last
			with: Text new 
			displaying: false.
		self fit].
	super removedMorph: aMorph.
]

{ #category : #blinking }
TextMorph >> resetBlinkCursor [
	"Reset the blinking cursor"
	| para |
	self blinkStart: Time millisecondClockValue + 500.
	para := paragraph ifNil: [^self].
	para showCaret = para focused ifFalse:[
		para caretRect ifNotNil: [ :r | self invalidRect: r].
		para showCaret: para focused.].

]

{ #category : #menu }
TextMorph >> reverseCurveDirection [
	container textDirection: container textDirection negated.
	self paragraph composeAll
]

{ #category : #alignment }
TextMorph >> rightFlush [ 
	self paragraph rightFlush.
	self updateFromParagraph
]

{ #category : #accessing }
TextMorph >> selectAll [

	self selectionChanged.
	self editor selectAll.
	self selectionChanged.
]

{ #category : #accessing }
TextMorph >> selectFrom: start to: stop [

	self selectionChanged.
	self editor selectFrom: start to: stop.
	self selectionChanged.

]

{ #category : #accessing }
TextMorph >> selectInterval: anInterval [

	self selectionChanged.
	self editor selectInterval: anInterval.
	self selectionChanged.

]

{ #category : #accessing }
TextMorph >> selection [
	^editor ifNotNil: [ editor selection ]
]

{ #category : #private }
TextMorph >> selectionChanged [
	
	self selectionChanged: self paragraph selectionRects.
]

{ #category : #private }
TextMorph >> selectionChanged: rects [
	"Invalidate all the selection rectangles. By using either fullBounds or outerBounds, we make sure that any drop shadow is accounted for too."
	
	| myBounds |
	rects ifEmpty: [^ self].
	myBounds := fullBounds ifNil: [self outerBounds].
	rects do: [:r | self invalidRect: (r intersect: myBounds)].
]

{ #category : #accessing }
TextMorph >> selectionInterval [

	^ self editor selectionInterval
]

{ #category : #accessing }
TextMorph >> selectionInterval: anInterval [

	self selectInterval: anInterval.
]

{ #category : #'scripting access' }
TextMorph >> setAllButFirstCharacter: source [ 
	"Set all but the first char of the receiver to the source"
	| chars |
	(chars := self getCharacters) isEmpty
		ifTrue: [self newContents: '·' , source asString]
		ifFalse: [self newContents: (String
								streamContents: [:aStream | 
									aStream nextPut: chars first.
									aStream nextPutAll: source])]
]

{ #category : #accessing }
TextMorph >> setCharacters: chars [
	"obtain a string value from the receiver"

	(self getCharacters = chars) ifFalse:
		[self newContents: chars]
]

{ #category : #editing }
TextMorph >> setCompositionWindow [

	| hand |
	self flag: #ImmPlugin.
	hand := self primaryHand.
	hand ifNotNil: [hand compositionWindowManager keyboardFocusForAMorph: self].

]

{ #category : #containment }
TextMorph >> setContainer: newContainer [
	"Adopt (or abandon) container shape"
	self changed.
	container := newContainer.
	self releaseParagraph
]

{ #category : #menu }
TextMorph >> setCurveBaseline: evt [
	| handle origin |
	origin := evt cursorPoint.
	handle := HandleMorph new forEachPointDo:
		[:newPoint | handle removeAllMorphs.
		handle addMorph:
			(PolygonMorph vertices: (Array with: origin with: newPoint)
				color: Color black borderWidth: 1 borderColor: Color black).
		container baseline: (newPoint - origin) y negated asInteger // 5.
		self paragraph composeAll].
	evt hand attachMorph: handle.
	handle startStepping	
]

{ #category : #private }
TextMorph >> setDefaultContentsIfNil [
	"Set the default contents"

	| toUse |
	text ifNil:
		[toUse := self valueOfProperty: #defaultContents.
		toUse ifNil: [toUse :='abc' asText "allBold"].	"try it plain for a while"
		text := toUse]
]

{ #category : #accessing }
TextMorph >> setFirstCharacter: source [ 
	"Set the first character of the receiver as indicated"
	| aChar chars |
	aChar := source asCharacter.
	(chars := self getCharacters) isEmpty
		ifTrue: [self
				newContents: (String with: aChar)]
		ifFalse: [chars first = aChar
				ifFalse: [self
						newContents: (String
								streamContents: [:aStream | 
									aStream nextPut: aChar.
									aStream
										nextPutAll: (chars copyFrom: 2 to: chars size)])]] 
]

{ #category : #accessing }
TextMorph >> setLastCharacter: source [
	"Set the last character of the receiver as indicated"

	| aChar chars |
	aChar := source asCharacter.
	(chars := self getCharacters) size > 0 
		ifFalse:
			[self newContents: (String with: aChar)]
		ifTrue:
			[(chars last = aChar) ifFalse:
				[self newContents: (String streamContents:
					[:aStream |
						aStream nextPutAll: (chars copyFrom: 1 to: (chars size - 1)).
						aStream nextPut: aChar])]]
]

{ #category : #private }
TextMorph >> setPredecessor: newPredecessor [
	predecessor := newPredecessor
]

{ #category : #private }
TextMorph >> setSuccessor: newSuccessor [

	successor := newSuccessor.
	paragraph ifNotNil: [paragraph wantsColumnBreaks: successor notNil].

]

{ #category : #initialization }
TextMorph >> setTextStyle: aTextStyle [

	textStyle := aTextStyle.
	self releaseCachedState; changed
]

{ #category : #blinking }
TextMorph >> startBlinking [
	self startStepping: #onBlinkCursor 
		at: Time millisecondClockValue 
		arguments: nil stepTime: 500.
	self resetBlinkCursor.

]

{ #category : #'event handling' }
TextMorph >> startDrag: evt [

	self removeProperty: #waitingForTextDrag.

	[evt hand grabMorph: (TransferMorph withPassenger: self selection from: self)]
		ensure: [evt hand releaseMouseFocus: self].
]

{ #category : #'linked frames' }
TextMorph >> startingIndex [
	predecessor isNil
		ifTrue: [^ 1].
	^ predecessor lastCharacterIndex + 1 
]

{ #category : #blinking }
TextMorph >> stopBlinking [
	self stopSteppingSelector: #onBlinkCursor.
	self resetBlinkCursor. "Ensure caret visible."
]

{ #category : #initialization }
TextMorph >> string: aString fontName: aName size: aSize [

	self string: aString fontName: aName size: aSize wrap: true
]

{ #category : #initialization }
TextMorph >> string: aString fontName: aName size: aSize wrap: shouldWrap [

	shouldWrap
		ifTrue: [self contentsWrapped: aString]
		ifFalse: [self contentsAsIs: aString].

	self fontName: aName size: aSize
]

{ #category : #'linked frames' }
TextMorph >> successor [
	^ successor
]

{ #category : #accessing }
TextMorph >> text [
	^ text
]

{ #category : #private }
TextMorph >> text: t textStyle: s [
	"Private -- for use only in morphic duplication"
	text := t.
	textStyle := s.
	paragraph ifNotNil: [paragraph textStyle: s]
]

{ #category : #private }
TextMorph >> text: t textStyle: s wrap: wrap color: c
	predecessor: pred successor: succ [
	"Private -- for use only in morphic duplication"
	text := t.
	textStyle := s.
	wrapFlag := wrap.
	color := c.
	paragraph := editor := container := nil.
	self predecessor: pred successor: succ
]

{ #category : #accessing }
TextMorph >> textAlignment [
	"Answer 1..4, representing #leftFlush, #rightFlush, #centered, or #justified"
	^self editor textAlignment
]

{ #category : #accessing }
TextMorph >> textAlignmentSymbol [
	"Answer one of #leftFlush, #rightFlush, #centered, or #justified"
	^self editor textAlignmentSymbol
]

{ #category : #geometry }
TextMorph >> textBounds [
	^ bounds
]

{ #category : #accessing }
TextMorph >> textColor [

	^ color
]

{ #category : #accessing }
TextMorph >> textColor: aColor [

	color = aColor ifTrue: [^ self].
	color := aColor.
	self changed.

]

{ #category : #accessing }
TextMorph >> textStyle [
	^textStyle
]

{ #category : #private }
TextMorph >> updateFromParagraph [
	"A change has taken place in my paragraph, as a result of editing and I must be updated.  If a line break causes recomposition of the current paragraph, or it the selection has entered a different paragraph, then the current editor will be released, and must be reinstalled with the resulting new paragraph, while retaining any editor state, such as selection, undo state, and current typing emphasis."

	| newStyle sel oldLast oldEditor back |
	paragraph ifNil: [^self].
	wrapFlag ifNil: [wrapFlag := true].
	editor ifNotNil: 
			[oldEditor := editor.
			sel := editor selectionInterval.
			editor storeSelectionInParagraph].
	text := paragraph text.
	paragraph textStyle = textStyle 
		ifTrue: [self fit]
		ifFalse: 
			["Broadcast style changes to all morphs"

			newStyle := paragraph textStyle.
			(self firstInChain text: text textStyle: newStyle) recomposeChain.
			editor ifNotNil: [self installEditorToReplace: editor]].
	
	(self isAutoFit and: [self isWrapped not])
		ifTrue: [self extent: self paragraph extent; composeToBounds]
		ifFalse: [self layoutChanged].
	sel ifNil: [^self].

	"If selection is in top line, then recompose predecessor for possible ripple-back"
	predecessor ifNotNil: 
			[sel first <= (self paragraph lines first last + 1) 
				ifTrue: 
					[oldLast := predecessor lastCharacterIndex.
					predecessor paragraph 
						recomposeFrom: oldLast
						to: text size
						delta: 0.
					oldLast = predecessor lastCharacterIndex 
						ifFalse: 
							[predecessor changed.	"really only last line"
							self predecessorChanged]]].
	((back := predecessor notNil 
				and: [sel first <= self paragraph firstCharacterIndex]) or: 
				[successor notNil 
					and: [sel first > (self paragraph lastCharacterIndex + 1)]]) 
		ifTrue: 
			["The selection is no longer inside this paragraph.
		Pass focus to the paragraph that should be in control."

			back ifTrue: [predecessor recomposeChain] ifFalse: [self recomposeChain].
			self firstInChain withSuccessorsDo: 
					[:m | 
					(sel first between: m firstCharacterIndex and: m lastCharacterIndex + 1) 
						ifTrue: 
							[m installEditorToReplace: oldEditor.
							^self passKeyboardFocusTo: m]].
			self error: 'Inconsistency in text editor'	"Must be somewhere in the successor chain"].
	editor ifNil: 
			["Reinstate selection after, eg, style change"

			self installEditorToReplace: oldEditor].
		
	self flag: #ImmPlugin.
	"self setCompositionWindow."

]

{ #category : #accessing }
TextMorph >> userString [
	"Do I have a text string to be searched on?"

	^text ifNotNil: [:txt| txt string]
]

{ #category : #'layout-properties' }
TextMorph >> vResizing [

	self layoutProperties ifNotNil: [:props |
		^ props vResizing].
	
	(self isAutoFit and: [self isWrapped])
		ifTrue: [^ #shrinkWrap]. 
	(self isAutoFit and: [self isWrapped not])
		ifTrue: [^ #shrinkWrap].
	(self isAutoFit not and: [self isWrapped])
		ifTrue: [^ #rigid]. "or #spaceFill"
	(self isAutoFit not and: [self isWrapped not])
		ifTrue: [^ #rigid]. "or #spaceFill"
]

{ #category : #'layout-properties' }
TextMorph >> vResizing: aSymbol [

	super vResizing: aSymbol.
	
	self autoFit: aSymbol == #shrinkWrap.

	 self wrapDirection: (aSymbol == #shrinkWrap
		ifTrue: [#topToBottom]
		ifFalse: [#none]).
		
	self releaseParagraph.
]

{ #category : #copying }
TextMorph >> veryDeepFixupWith: deepCopier [ 
	"If target and arguments fields were weakly copied, fix them here.  If 
	they were in the tree being copied, fix them up, otherwise point to the 
	originals!"

	super veryDeepFixupWith: deepCopier.
	"It makes no sense to share pointers to an existing predecessor and successor"
	predecessor := deepCopier references at: predecessor ifAbsent: [nil].
	successor := deepCopier references at: successor ifAbsent: [nil]
]

{ #category : #copying }
TextMorph >> veryDeepInner: deepCopier [ 
	"Copy all of my instance variables. Some need to be not copied at all, but shared.
	Warning!! Every instance variable defined in this class must be handled.
	We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	textStyle := textStyle veryDeepCopyWith: deepCopier.
	text := text veryDeepCopyWith: deepCopier.
	wrapFlag := wrapFlag veryDeepCopyWith: deepCopier.
	paragraph := paragraph veryDeepCopyWith: deepCopier.
	editor := editor veryDeepCopyWith: deepCopier.
	container := container veryDeepCopyWith: deepCopier.
	predecessor := predecessor.
	successor := successor.
	backgroundColor := backgroundColor veryDeepCopyWith: deepCopier.
	margins := margins veryDeepCopyWith: deepCopier.
]

{ #category : #'event handling' }
TextMorph >> wantsKeyboardFocus [

	^ true
]

{ #category : #'linked frames' }
TextMorph >> withSuccessorsDo: aBlock [ 
	"Evaluate aBlock for each morph in my successor chain"

	| each |
	each := self.
	[each isNil] whileFalse: 
			[aBlock value: each.
			each := each successor]
]

{ #category : #'event handling' }
TextMorph >> wouldAcceptKeyboardFocusUponTab [
	"Answer whether the receiver might accept keyboard focus if 
	tab were hit in some container playfield"
	^ self inPartsBin not
]

{ #category : #'layout-properties' }
TextMorph >> wrapDirection [

	self layoutProperties ifNotNil: [:props |
		^ props wrapDirection].
	
	^ self vResizing == #shrinkWrap
		ifTrue: [#topToBottom]
		ifFalse: [#none]
]

{ #category : #accessing }
TextMorph >> wrapFlag: aBoolean [
	"Private! Please use #hResizing: and #vResizing:."

	"Whether contained text will adjust its bounds as I change shape:
		|	wrapFlag 	|		TextMorph grows			|		TextMorph shrinks 	|
		|		true 		| wrapped lines fill new space	|	long lines wrap to fit 		|
		|		false 		|   wrapped lines stay same 		|	long lines are cut off 		|"

	aBoolean == wrapFlag ifTrue: [^ self].
	wrapFlag := aBoolean.
	self composeToBounds
]

{ #category : #menu }
TextMorph >> wrapOnOff [
	self wrapFlag: wrapFlag not
]

{ #category : #menu }
TextMorph >> wrapString [
	"Answer the string to put in a menu that will invite the user to 
	switch autoFit mode"
	^ (wrapFlag
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'text wrap to bounds' translated
]

{ #category : #editing }
TextMorph >> xeqLinkText: sourceString withParameter: param [
	self confirm: 'xeqLinkText:
' asText allBold , sourceString asText
]

{ #category : #'event handling' }
TextMorph >> yellowButtonActivity: shiftKeyState [ 
	"Invoke the text-editing menu"
	| menu |
	(menu := self getMenu: shiftKeyState)
		ifNotNil: [""
			menu setInvokingView: self editor.
			self flag: #refactor. "mt: This should work non-modally..."
			menu invokeModal. self changed]
]
