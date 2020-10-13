Class {
	#name : #PluggableTextMorph,
	#superclass : #ScrollPane,
	#instVars : [
		'textMorph',
		'getTextSelector',
		'setTextSelector',
		'getSelectionSelector',
		'hasUnacceptedEdits',
		'hasUserEdited',
		'askBeforeDiscardingEdits',
		'selectionInterval',
		'hasEditingConflicts',
		'editTextSelector',
		'wantsWrapBorder'
	],
	#classVars : [
		'AdornmentCache',
		'SimpleFrameAdornments',
		'SoftLineWrap',
		'VisualWrapBorder',
		'VisualWrapBorderLimit'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #'frame adornments' }
PluggableTextMorph class >> adornmentCache [
	"Cache for frame adornments"

	^AdornmentCache ifNil:[AdornmentCache := Dictionary new].
]

{ #category : #'frame adornments' }
PluggableTextMorph class >> adornmentWithColor: aColor [
	"Create and return a frame adornment with the given color"

	| size box form fillStyle |
	^self adornmentCache at: aColor ifAbsentPut:[
		size := 16. 
		box := 0@0 extent: size asPoint.
		form := Form extent: size@size depth: 32.
		fillStyle := MenuMorph gradientMenu ifFalse: [SolidFillStyle color: aColor] ifTrue: [
			(GradientFillStyle ramp: {
				0.0->(aColor alpha: 0.01).
				0.8->aColor.
				1.0->aColor})
				origin: box topRight - (size@0);
				direction: (size @ size negated) // 4;
				radial: false].
		form getCanvas drawPolygon:  {
			box topRight. 
			box topRight + (0@size). 
			box topRight - (size@0)
		} fillStyle: fillStyle.
		form].

]

{ #category : #'initialize-release' }
PluggableTextMorph class >> cleanUp: aggressive [

	aggressive ifTrue: [self flushAdornmentCache].
]

{ #category : #'frame adornments' }
PluggableTextMorph class >> flushAdornmentCache [
	"Cache for frame adornments"

	AdornmentCache := nil
]

{ #category : #'instance creation' }
PluggableTextMorph class >> on: anObject text: getTextSel accept: setTextSel [

	^ self on: anObject
		text: getTextSel
		accept: setTextSel
		readSelection: nil
		menu: nil
]

{ #category : #'instance creation' }
PluggableTextMorph class >> on: anObject text: getTextSel accept: setTextSel readSelection: getSelectionSel menu: getMenuSel [

	^ self new on: anObject
		text: getTextSel
		accept: setTextSel
		readSelection: getSelectionSel
		menu: getMenuSel
]

{ #category : #'frame adornments' }
PluggableTextMorph class >> simpleFrameAdornments [
	<preference: 'Simple Frame Adornments'
		category: 'Morphic'
		description: 'When true, use a simple rectangle border as feedback for indicating unsaved changes in text editors, otherwise use a small triangle in the upper-right corner'
		type: #Boolean>
	^SimpleFrameAdornments ifNil:[false]
]

{ #category : #'frame adornments' }
PluggableTextMorph class >> simpleFrameAdornments: aBool [
	"Sets the simpleFrameAdornment preference
		PluggableTextMorph simpleFrameAdornments: true.
		PluggableTextMorph simpleFrameAdornments: false.
	"
	SimpleFrameAdornments := aBool

]

{ #category : #preferences }
PluggableTextMorph class >> softLineWrap [
	<preference: 'Use soft line wrap'
		categoryList: #(scrolling editing)
		description: 'Wrap text lines to avoid horizontal scrolling.'
		type: #Boolean>
	^ SoftLineWrap ifNil: [true]
]

{ #category : #preferences }
PluggableTextMorph class >> softLineWrap: aBoolean [

	aBoolean == SoftLineWrap ifTrue: [^ self].
	SoftLineWrap := aBoolean.
	PluggableTextMorph allSubInstancesDo: [:m |
		m text lineCount > 1 ifTrue: [m wrapFlag: aBoolean]].
]

{ #category : #preferences }
PluggableTextMorph class >> themeProperties [

	^ super themeProperties, {
		{ #font. 'Fonts'. 'Font for text if not styled.' }.
		{ #textColor. 'Colors'. 'Color for text if not styled.' }.		
		{ #caretColor. 'Colors'. 'The color of the text cursor.' }.
		{ #selectionColor. 'Colors'. 'The color of the text selection.' }.
		{ #unfocusedSelectionModifier. 'Colors'. 'How to derive the text selection color if not focused.' }.
		
		{ #adornmentReadOnly. 'Color'. 'How to indicate read-only contents.' }.
		{ #adornmentRefuse. 'Color'. 'How to indicate that the model refuses to accept.' }.
		{ #adornmentConflict. 'Color'. 'How to indicate that there are editing conflicts.' }.
		{ #adornmentDiff. 'Color'. 'How to indicate that the model wants diff feedback.' }.
		{ #adornmentNormalEdit. 'Color'. 'How to indicate that there are unaccepted edits.' }.
		{ #adornmentDiffEdit. 'Color'. 'How to indicate that there are unaccepted edits in a diff view.' }.
		
		{ #wrapBorderColorModifier. 'Color'. 'How to indicate a specific wrap border.' }.
		{ #frameAdornmentWidth. 'Geometry'. 'Width of simple frame adornments.' }.
	}
]

{ #category : #preferences }
PluggableTextMorph class >> visualWrapBorder [
	<preference: 'Show wrap border in code panes.'
		categoryList: #(editing visuals performance)
		description: 'Show a visual border after a specific amount of characters. Makes sense for monospaced fonts.'
		type: #Boolean>
	^ VisualWrapBorder ifNil: [false]
]

{ #category : #preferences }
PluggableTextMorph class >> visualWrapBorder: aBoolean [

	VisualWrapBorder := aBoolean.
]

{ #category : #preferences }
PluggableTextMorph class >> visualWrapBorderLimit [
	<preference: 'Wrap border limit'
		categoryList: #(editing visuals performance)
		description: 'Amount of characters after the border should be drawn.'
		type: #Number>
	^ VisualWrapBorderLimit ifNil: [80]
]

{ #category : #preferences }
PluggableTextMorph class >> visualWrapBorderLimit: aNumber [

	VisualWrapBorderLimit := aNumber asInteger.
]

{ #category : #'menu commands' }
PluggableTextMorph >> accept [ 
	"Inform the model of text to be accepted, and return true if OK."

	| priorSelection priorScrollerOffset |

	(self canDiscardEdits and: [(self hasProperty: #alwaysAccept) not])
		ifTrue: [^ self flash].

	self hasEditingConflicts ifTrue: [
		(self confirm: 'Caution! This method may have been\changed elsewhere since you started\editing it here.  Accept anyway?' withCRs translated) ifFalse: [^ self flash]].

	priorSelection := self selectionInterval copy.
	priorScrollerOffset := scroller offset copy.
	
	self acceptTextInModel == true
		ifFalse: [^ self "something went wrong"].
		
	self setText: self getText.
	self hasUnacceptedEdits: false.

	(model dependents
		detect: [:dep | (dep isKindOf: PluggableTextMorph) and: [dep getTextSelector == #annotation]]
		ifNone: [nil])
			ifNotNil: [:aPane | model changed: #annotation].

	"Update the model's internal caches. Note that this is specific to CodeHolder and the stepping it uses for updating. We have to trigger this here manually to avoid that the next step message destroys our selection and scrolling offset."
	(model respondsTo: #updateCodePaneIfNeeded)
		ifTrue: [model updateCodePaneIfNeeded].
	
	"Restore prior selection:"
	scroller offset: priorScrollerOffset.
	selectionInterval := priorSelection.
	self selectFrom: priorSelection first to: priorSelection last.
]

{ #category : #layout }
PluggableTextMorph >> acceptDroppingMorph: aMorph event: evt [ 
	"This message is sent when a morph is dropped onto a morph that has     
	agreed to accept the dropped morph by responding 'true' to the     
	wantsDroppedMorph:Event: message. The default implementation just     
	adds the given morph to the receiver."
	"Here we let the model do its work."

	self model
		acceptDroppingMorph: aMorph
		event: evt
		inMorph: self.


]

{ #category : #initialization }
PluggableTextMorph >> acceptOnCR: trueOrFalse [
	textMorph acceptOnCR: trueOrFalse
]

{ #category : #'menu commands' }
PluggableTextMorph >> acceptTextInModel [
	"Inform the model that the receiver's textMorph's text should be accepted.
	Answer true if the model accepted ok, false otherwise"
	| textToAccept |

	textToAccept := textMorph contents copy.
	^setTextSelector isNil or:
		[setTextSelector numArgs = 2
			ifTrue: [model perform: setTextSelector with: textToAccept with: self]
			ifFalse: [model perform: setTextSelector with: textToAccept]]

]

{ #category : #accessing }
PluggableTextMorph >> adoptPaneColor: aColor [

	super adoptPaneColor: aColor.
	
	self wrapBorderColor: ((self userInterfaceTheme wrapBorderColorModifier ifNil: [ [:c | c muchLighter alpha: 0.3] ])
								value: self borderColor).
]

{ #category : #'menu commands' }
PluggableTextMorph >> again [
	self handleEdit: [textMorph editor again]
]

{ #category : #transcript }
PluggableTextMorph >> appendEntry [
	"Append the text in the model's writeStream to the editable text. "
	textMorph asText size > model characterLimit ifTrue:
		["Knock off first half of text"
		self selectInvisiblyFrom: 1 to: textMorph asText size // 2.
		self replaceSelectionWith: Text new].
	self selectInvisiblyFrom: textMorph asText size + 1 to: textMorph asText size.
	self replaceSelectionWith: model contents asText.
	self selectInvisiblyFrom: textMorph asText size + 1 to: textMorph asText size
]

{ #category : #updating }
PluggableTextMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self textMorph releaseParagraph; paragraph.
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> askBeforeDiscardingEdits: aBoolean [
	"Set the flag that determines whether the user should be asked before discarding unaccepted edits."

	askBeforeDiscardingEdits := aBoolean
]

{ #category : #'menu commands' }
PluggableTextMorph >> browseChangeSetsWithSelector [
	"Help the user track down which change sets mention a particular selector"

	self handleEdit: [textMorph editor browseChangeSetsWithSelector]
]

{ #category : #'menu commands' }
PluggableTextMorph >> browseIt [
	self handleEdit: [textMorph editor browseIt]
]

{ #category : #transcript }
PluggableTextMorph >> bsText [
	self changeText: (self text copyFrom: 1 to: (self text size - 1 max: 0))
]

{ #category : #'menu commands' }
PluggableTextMorph >> buttonForIt [
	self handleEdit: [textMorph editor buttonForIt]
]

{ #category : #testing }
PluggableTextMorph >> canBeEncroached [
	"Fixed-height always report true, since they cannot be encroached."
	self layoutFrame ifNotNil: [ : frame | frame topFraction = frame bottomFraction ifTrue: [ ^ true ] ].
	^ (textMorph height+10) < self height
]

{ #category : #'dependents access' }
PluggableTextMorph >> canDiscardEdits [
	"Return true if this view either has no text changes or does not care."

	^ (hasUnacceptedEdits & askBeforeDiscardingEdits) not

]

{ #category : #'menu commands' }
PluggableTextMorph >> cancel [
	self setText: self getText.
	self setSelection: self getSelection.
	getTextSelector == #annotation ifFalse:
		[(model dependents detect: [:dep | (dep isKindOf: PluggableTextMorph) and: [dep getTextSelector == #annotation]] ifNone: [nil]) ifNotNil:
			[:aPane | model changed: #annotation]]
]

{ #category : #'menu commands' }
PluggableTextMorph >> changeStyle [
	self handleEdit: [textMorph editor changeStyle]
]

{ #category : #transcript }
PluggableTextMorph >> changeText: aText [
	"The paragraph to be edited is changed to aText."
	self setText: aText
]

{ #category : #geometry }
PluggableTextMorph >> charactersOccluded [
	"Let the receiver suggest to its neighboring vertical Splitter(s) that they try to optimize their position such that none of the receivers visible lines need to wrap."
	| numberOfPhysicalLines lastPhysicalLine logicalLines physicalLines |
	numberOfPhysicalLines := 0.
	lastPhysicalLine := (physicalLines := textMorph paragraph lines)
		detect:
			[ : each | numberOfPhysicalLines := numberOfPhysicalLines + 1.
			each bottom > self height ]
		ifNone: [ physicalLines last ].
	logicalLines := (self text
		copyFrom: 1
		to: lastPhysicalLine last) lineCount.
	^ numberOfPhysicalLines - logicalLines
]

{ #category : #'menu commands' }
PluggableTextMorph >> chooseAlignment [
	self handleEdit: [textMorph editor changeAlignment]
]

{ #category : #'menu commands' }
PluggableTextMorph >> classCommentsContainingIt [
	self handleEdit: [textMorph editor classCommentsContainingIt]
]

{ #category : #'menu commands' }
PluggableTextMorph >> classNamesContainingIt [
	self handleEdit: [textMorph editor classNamesContainingIt]
]

{ #category : #html }
PluggableTextMorph >> copyHtml [
	"put the html representation of the receiver's text into the clipboard"
	Clipboard clipboardText: self text printHtmlString
]

{ #category : #'menu commands' }
PluggableTextMorph >> copySelection [
	self handleEdit: [textMorph editor copySelection]
]

{ #category : #'interactive error protocol' }
PluggableTextMorph >> correctFrom: start to: stop with: aString [
	^ self handleEdit: [textMorph editor correctFrom: start to: stop with: aString]
]

{ #category : #'interactive error protocol' }
PluggableTextMorph >> correctSelectionWithString: aString [
	| result newPosition |

	"I can't tell if this is a hack or if it's the right thing to do."
	self setSelection: selectionInterval. 

	result := self correctFrom: selectionInterval first to: selectionInterval last with: aString.
	newPosition := selectionInterval first + aString size.
	self setSelection: (newPosition to: newPosition - 1).
	^ result
]

{ #category : #'menu commands' }
PluggableTextMorph >> cut [
	self handleEdit: [textMorph editor cut]
]

{ #category : #'menu commands' }
PluggableTextMorph >> debugIt [
	self handleEdit: [textMorph editor debugIt]
]

{ #category : #'menu commands' }
PluggableTextMorph >> doIt [
	^ self handleEdit: [textMorph editor doIt]
]

{ #category : #drawing }
PluggableTextMorph >> drawFrameAdornment: aColor on: aCanvas [ 
	"Indicate edit status for the text editor"
	self class simpleFrameAdornments
		ifTrue:
			[ aCanvas
				frameRectangle: self innerBounds
				width: (self valueOfProperty: #frameAdornmentWidth ifAbsent: [1])
				color: aColor.
			aCanvas
				frameRectangle: (self innerBounds insetBy: 1)
				width: (self valueOfProperty: #frameAdornmentWidth ifAbsent: [1])
				color: (aColor alpha: aColor alpha / 3.0) ]
		ifFalse:
			[ | form |
			"Class-side adornment cache is currently using pre-multiplied alpha, so we need to use rule 34 which works for < 32bpp, too."
			form := self class adornmentWithColor: aColor.
			aCanvas
				image: form
				at: self innerBounds topRight - (form width @ 0)
				sourceRect: form boundingBox
				rule: 34 ]
]

{ #category : #drawing }
PluggableTextMorph >> drawFrameAdornmentsOn: aCanvas [ 
	"Include a thin red inset border for unaccepted edits, or, if the unaccepted edits are known to conflict with a change made somewhere else to the same method (typically), put a thick red frame"

	self wantsFrameAdornments ifFalse: [^ self].
	
	self readOnly ifTrue: [^ self drawFrameAdornment: (self valueOfProperty: #adornmentReadOnly ifAbsent: [Color black]) on: aCanvas].
	
	(model notNil and: [model refusesToAcceptCode])
		ifTrue: [
			"Put up feedback showing that code cannot be submitted in this state"
			^ self drawFrameAdornment: (self valueOfProperty: #adornmentRefuse ifAbsent: [Color tan]) on: aCanvas].
	
	self hasEditingConflicts
		ifTrue: [^ self drawFrameAdornment: (self valueOfProperty: #adornmentConflict ifAbsent: [Color red]) on: aCanvas].
		 
	self hasUnacceptedEdits ifTrue: [
		model wantsDiffFeedback
			ifTrue: [self drawFrameAdornment: (self valueOfProperty: #adornmentDiffEdit ifAbsent: [Color yellow]) on: aCanvas]
			ifFalse: [self drawFrameAdornment: (self valueOfProperty: #adornmentNormalEdit ifAbsent: [Color orange]) on: aCanvas].
		^ self].

	model wantsDiffFeedback
		ifTrue: [self drawFrameAdornment: (self valueOfProperty: #adornmentDiff ifAbsent: [Color green]) on: aCanvas].
]

{ #category : #drawing }
PluggableTextMorph >> drawOverlayOn: aCanvas [ 
	"Draw frame adornments on top of everything otherwise they will partially overlap with text selection which looks ugly."
	
	self drawWrapBorderOn: aCanvas.
	super drawOverlayOn: aCanvas. 
	self drawFrameAdornmentsOn: aCanvas.

]

{ #category : #drawing }
PluggableTextMorph >> drawWrapBorderOn: aCanvas [

	| offset rect |
	self wantsWrapBorder ifFalse: [^ self].
	textMorph ifNil: [^ self].
	
	offset := textMorph margins isRectangle
		ifTrue: [textMorph margins left]
		ifFalse: [textMorph margins isPoint
			ifTrue: [textMorph margins x]
			ifFalse: [textMorph margins]].
	offset := offset + ((textMorph textStyle defaultFont widthOf: $x) * self class visualWrapBorderLimit).
	offset > self width ifTrue: [^ self].
	
	rect := scroller topLeft + (offset @ 0) corner: scroller bottomRight.

	aCanvas
		fillRectangle: rect
		color: self wrapBorderColor.
	aCanvas
		line: rect topLeft
		to: rect bottomLeft
		width: self borderStyle width
		color: (self wrapBorderColor muchDarker alpha: 0.5).
]

{ #category : #initialization }
PluggableTextMorph >> editString: aString [ 
	"Jam some text in.  This is treated as clean text by default."

	self setText: aString asText
]

{ #category : #accessing }
PluggableTextMorph >> editTextSelector [

	^ editTextSelector
]

{ #category : #accessing }
PluggableTextMorph >> editTextSelector: aSymbol [

	editTextSelector := aSymbol.
]

{ #category : #'menu commands' }
PluggableTextMorph >> explain [
	self handleEdit: [textMorph editor explain]
]

{ #category : #'menu commands' }
PluggableTextMorph >> exploreIt [
	^ self handleEdit: [textMorph editor exploreIt]
]

{ #category : #geometry }
PluggableTextMorph >> extraScrollRange [
	^ self height // 4
]

{ #category : #'menu commands' }
PluggableTextMorph >> fileItIn [
	self handleEdit: [textMorph editor fileItIn]
]

{ #category : #'menu commands' }
PluggableTextMorph >> find [
	self handleEdit: [textMorph editor find]
]

{ #category : #'menu commands' }
PluggableTextMorph >> findAgain [
	self handleEdit: [textMorph editor findAgain]
]

{ #category : #'menu commands' }
PluggableTextMorph >> findReplace [
	self handleEdit: [textMorph editor findReplace]
]

{ #category : #initialization }
PluggableTextMorph >> font: aFont [
	textMorph beAllFont: aFont
]

{ #category : #'model access' }
PluggableTextMorph >> getSelection [
	"Answer the model's selection interval."

	getSelectionSelector ifNil: [^1 to: 0].	"null selection"
	^model perform: getSelectionSelector
]

{ #category : #'model access' }
PluggableTextMorph >> getText [
	"Retrieve the current model text"

	| newText |
	getTextSelector ifNil: [^Text new].
	newText := model perform: getTextSelector.
	newText ifNil: [^Text new].
	^newText shallowCopy
]

{ #category : #accessing }
PluggableTextMorph >> getTextSelector [
	^getTextSelector
]

{ #category : #'editor access' }
PluggableTextMorph >> handleEdit: editBlock [
	| result |
	textMorph editor selectFrom: selectionInterval first to: selectionInterval last;
						model: model.  "For, eg, evaluateSelection"
	result := textMorph handleEdit: editBlock.   "Update selection after edit"
	self scrollSelectionIntoView.
	^ result
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> hasEditingConflicts [
	"Return true if a conflicting edit to the same code (typically) is known to have occurred after the current contents started getting edited"

	^ hasEditingConflicts == true
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> hasEditingConflicts: aBoolean [

	hasEditingConflicts := aBoolean
]

{ #category : #accessing }
PluggableTextMorph >> hasFocus [

	^ super hasFocus or: [textMorph notNil and: [textMorph hasKeyboardFocus]]
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> hasUnacceptedEdits [
	"Return true if this view has unaccepted edits."

	^ hasUnacceptedEdits
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> hasUnacceptedEdits: wasJustEdited [

	wasJustEdited = hasUnacceptedEdits ifFalse: [
		hasUnacceptedEdits := wasJustEdited.
		self changed].

	wasJustEdited
		ifTrue: [self hasUserEdited: true]
		ifFalse: [self hasEditingConflicts: false].
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> hasUserEdited [ 
	
	^ hasUserEdited
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> hasUserEdited: aBoolean [
	
	hasUserEdited := aBoolean.
]

{ #category : #'menu commands' }
PluggableTextMorph >> implementorsOfIt [
	self handleEdit: [textMorph editor implementorsOfIt]
]

{ #category : #initialization }
PluggableTextMorph >> initialize [

	self initializeTextMorph.
	super initialize.

	hasUnacceptedEdits := false.
	hasEditingConflicts := false.
	askBeforeDiscardingEdits := true.

	self minimumWidth: (TextStyle defaultFont widthOf: $m) * 10.
		
	scroller
		layoutPolicy: TableLayout new;
		addMorph: textMorph.
	
	"Reset minExtent because only now we can anser #isAutoFit correctly."
	self minimumExtent: 0@0; updateMinimumExtent.
]

{ #category : #initialization }
PluggableTextMorph >> initializeTextMorph [

	textMorph := self textMorphClass new
		margins: (3@0 corner: 0@0);
		setEditView: self;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		setProperty: #indicateKeyboardFocus toValue: #never;
		yourself.
]

{ #category : #'menu commands' }
PluggableTextMorph >> inspectIt [
	^ self handleEdit: [textMorph editor inspectIt]
]

{ #category : #'debug and other' }
PluggableTextMorph >> installModelIn: aWorld [
	"No special inits for new components"
	^ self
]

{ #category : #accessing }
PluggableTextMorph >> isAutoFit [
	"Whether I adjust the contents of my scroller to save a scroll bar."
	
	^ self wrapFlag
]

{ #category : #testing }
PluggableTextMorph >> isTextView [
	"True if the reciever is a view on a text model, such as a view on a TranscriptStream"
	^true
]

{ #category : #testing }
PluggableTextMorph >> isWrapped [

	^ self wrapFlag
]

{ #category : #'event handling' }
PluggableTextMorph >> keyStroke: evt [
	"A keystroke was hit while the receiver had keyboard focus.  Pass the keystroke on to my textMorph, and and also, if I have an event handler, pass it on to that handler"

	textMorph keyStroke: evt.
	self eventHandler ifNotNil:
		[self eventHandler keyStroke: evt fromMorph: self].

]

{ #category : #'event handling' }
PluggableTextMorph >> keyboardFocusDelegate [

	^ textMorph ifNil: [self]
]

{ #category : #'menu commands' }
PluggableTextMorph >> methodNamesContainingIt [
	self handleEdit: [textMorph editor methodNamesContainingIt]
]

{ #category : #'menu commands' }
PluggableTextMorph >> methodSourceContainingIt [
	self handleEdit: [textMorph editor methodSourceContainingIt]
]

{ #category : #'menu commands' }
PluggableTextMorph >> methodStringsContainingit [
	self handleEdit: [textMorph editor methodStringsContainingit]
]

{ #category : #'event handling' }
PluggableTextMorph >> mouseEnter: event [
	"Restore the selection in the text morph if there was a selection."

	super mouseEnter: event.
	
	selectionInterval ifNotNil: [:interval |
		textMorph editor
			selectInterval: selectionInterval;
			setEmphasisHere].
		
	Preferences mouseOverForKeyboardFocus
		ifTrue: [event hand newKeyboardFocus: self].
]

{ #category : #'event handling' }
PluggableTextMorph >> mouseLeave: event [
	"Save the selection interval for later."

	self rememberSelectionInterval.

	super mouseLeave: event.

	Preferences mouseOverForKeyboardFocus
		ifTrue: [event hand releaseKeyboardFocus: self]
]

{ #category : #'interactive error protocol' }
PluggableTextMorph >> nextTokenFrom: start direction: dir [
	^ textMorph editor nextTokenFrom: start direction: dir
]

{ #category : #'interactive error protocol' }
PluggableTextMorph >> notify: aString at: anInteger in: aStream [
	^ textMorph editor notify: aString at: anInteger in: aStream
]

{ #category : #'menu commands' }
PluggableTextMorph >> offerFontMenu [
	self handleEdit: [textMorph editor changeTextFont]
]

{ #category : #initialization }
PluggableTextMorph >> on: anObject text: getTextSel accept: setTextSel readSelection: getSelectionSel menu: getMenuSel [

	self model: anObject.
	getTextSelector := getTextSel.
	setTextSelector := setTextSel.
	getSelectionSelector := getSelectionSel.
	getMenuSelector := getMenuSel.
	self setText: self getText.
	self setSelection: self getSelection.
]

{ #category : #'event handling' }
PluggableTextMorph >> onKeyStrokeSend: sel to: recipient [
	textMorph on: #keyStroke send: sel to: recipient.
]

{ #category : #'menu commands' }
PluggableTextMorph >> paste [
	self handleEdit: [textMorph editor paste]
]

{ #category : #'menu commands' }
PluggableTextMorph >> pasteRecent [
	"Paste an item chosen from RecentClippings."

	| clipping |
	(clipping := Clipboard chooseRecentClipping) ifNil: [^ self].
	Clipboard clipboardText: clipping.
	^ self handleEdit: [textMorph editor paste]
]

{ #category : #'menu commands' }
PluggableTextMorph >> presentSpecialMenu [
	self handleEdit: [textMorph editor presentSpecialMenu]
]

{ #category : #'menu commands' }
PluggableTextMorph >> prettyPrint [
	self handleEdit: [textMorph editor prettyPrint]
]

{ #category : #'menu commands' }
PluggableTextMorph >> prettyPrintWithColor [
	self handleEdit: [textMorph editor prettyPrintWithColor]
]

{ #category : #'menu commands' }
PluggableTextMorph >> printIt [
	^ self handleEdit: [textMorph editor printIt]
]

{ #category : #'menu commands' }
PluggableTextMorph >> printerSetup [
	self handleEdit: [textMorph editor printerSetup]
]

{ #category : #'unaccepted edits' }
PluggableTextMorph >> promptForCancel [
	"Ask if it is OK to cancel changes to text"
	(self confirm:
'Changes have not been saved.
Is it OK to cancel those changes?' translated)
		ifTrue: [model changed: #clearUserEdits].

]

{ #category : #accessing }
PluggableTextMorph >> readOnly [

	^ textMorph readOnly
]

{ #category : #accessing }
PluggableTextMorph >> readOnly: aBoolean [

	textMorph readOnly: aBoolean.
]

{ #category : #'menu commands' }
PluggableTextMorph >> redo [
	self handleEdit: [textMorph editor redo]
]

{ #category : #'menu commands' }
PluggableTextMorph >> referencesToIt [
	self handleEdit: [textMorph editor referencesToIt]
]

{ #category : #private }
PluggableTextMorph >> rememberSelectionInterval [

	self flag: #fixIntervalCache. "mt: We should find a better design for discarding unused text editors in text morphs and restoring them on demand."
	selectionInterval := textMorph editor markIndex to: textMorph editor pointIndex - 1.
]

{ #category : #transcript }
PluggableTextMorph >> replaceSelectionWith: aText [
	^ textMorph editor replaceSelectionWith: aText
]

{ #category : #'editor access' }
PluggableTextMorph >> restoreSelectionInterval [

	selectionInterval ifNotNil: [
		self selectionInterval: selectionInterval].
]

{ #category : #'menu commands' }
PluggableTextMorph >> saveContentsInFile [
	self handleEdit: [textMorph editor saveContentsInFile]
]

{ #category : #'scroll bar events' }
PluggableTextMorph >> scrollBarMenuButtonPressed: event [
	"The menu button in the scrollbar was pressed; put up the menu"

	| menu |
	(menu := self getMenu: event shiftPressed) ifNotNil:
		["Set up to use perform:orSendTo: for model/view dispatch"
		menu setInvokingView: self.
		menu invokeModal]
]

{ #category : #geometry }
PluggableTextMorph >> scrollDeltaHeight [
	"Return the increment in pixels which this pane should be scrolled."
	^ textMorph ifNil: [super scrollDeltaHeight] ifNotNil: [:tm | tm defaultLineHeight]

]

{ #category : #'editor access' }
PluggableTextMorph >> scrollSelectionIntoView [
	"Scroll my text into view if necessary and return true, else return false"
	^ self scrollSelectionIntoView: nil
]

{ #category : #'editor access' }
PluggableTextMorph >> scrollSelectionIntoView: event [ 
	"Scroll my text into view. Due to line composition mechanism, we must never use the right of a character block because the lines last character block right value always comes from a global container and is *not* line specific."

	self rememberSelectionInterval.
	
	textMorph editor hasSelection
		ifFalse: [self scrollToShow: (textMorph editor startBlock withWidth: 1)]
		ifTrue: [
			self scrollToShow: (textMorph editor startBlock topLeft corner: textMorph editor stopBlock bottomLeft).
			self scrollToShow: (textMorph editor pointBlock withWidth: 1). "Ensure text cursor visibility."].
		
	^ true
]

{ #category : #'editor access' }
PluggableTextMorph >> selectAll [

	textMorph selectAll.
	self rememberSelectionInterval.
]

{ #category : #'interactive error protocol' }
PluggableTextMorph >> selectFrom: start to: stop [

	textMorph selectFrom: start to: stop.
	self rememberSelectionInterval.
]

{ #category : #'editor access' }
PluggableTextMorph >> selectInterval: anInterval [

	textMorph selectInterval: anInterval.
	self rememberSelectionInterval.
]

{ #category : #'interactive error protocol' }
PluggableTextMorph >> selectIntervalInvisibly: aSelectionInterval [
	^ textMorph editor selectIntervalInvisibly: aSelectionInterval
]

{ #category : #'interactive error protocol' }
PluggableTextMorph >> selectInvisiblyFrom: start to: stop [
	^ textMorph editor selectInvisiblyFrom: start to: stop
]

{ #category : #'editor access' }
PluggableTextMorph >> selectionInterval [

	^ textMorph selectionInterval
]

{ #category : #'editor access' }
PluggableTextMorph >> selectionInterval: anInterval [

	textMorph selectionInterval: anInterval.
	self rememberSelectionInterval.
]

{ #category : #'menu commands' }
PluggableTextMorph >> sendContentsToPrinter [
	self handleEdit: [textMorph editor sendContentsToPrinterWithLabel: owner knownName]
]

{ #category : #'menu commands' }
PluggableTextMorph >> sendersOfIt [
	self handleEdit: [textMorph editor sendersOfIt]
]

{ #category : #initialization }
PluggableTextMorph >> setDefaultParameters [

	super setDefaultParameters.
	
	self
		font: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]);
		setTextColor: (self userInterfaceTheme textColor ifNil: [Color black]).
	
	self wrapBorderColor: ((self userInterfaceTheme wrapBorderColorModifier ifNil: [ [:c | c muchLighter alpha: 0.3] ])
								value: self borderColor).
	
	self
		setProperty: #adornmentReadOnly
		toValue: (self userInterfaceTheme adornmentReadOnly ifNil: [Color black]);
		setProperty: #adornmentRefuse
		toValue: (self userInterfaceTheme adornmentRefuse ifNil: [Color tan]);
		setProperty: #adornmentConflict
		toValue: (self userInterfaceTheme adornmentConflict ifNil: [Color red]);
		setProperty: #adornmentDiff
		toValue: (self userInterfaceTheme adornmentDiff ifNil: [Color green]);
		setProperty: #adornmentNormalEdit
		toValue: (self userInterfaceTheme adornmentNormalEdit ifNil: [Color orange]);
		setProperty: #adornmentDiffEdit
		toValue: (self userInterfaceTheme adornmentDiffEdit ifNil: [Color yellow]).
		
	self
		setProperty: #frameAdornmentWidth
		toValue: (self userInterfaceTheme frameAdornmentWidth ifNil: [1]).
	
	textMorph
		caretColor: (self userInterfaceTheme caretColor ifNil: [Color red]);
		selectionColor: (self userInterfaceTheme selectionColor ifNil: [TranslucentColor r: 0.0 g: 0.0 b: 0.8 alpha: 0.2]);
		unfocusedSelectionColor: ((self userInterfaceTheme unfocusedSelectionModifier ifNil: [ [:c | Color gray: 0.9] ])
			value: textMorph selectionColor).
]

{ #category : #'menu commands' }
PluggableTextMorph >> setSearchString [
	self handleEdit: [textMorph editor setSearchString]
]

{ #category : #'model access' }
PluggableTextMorph >> setSelection: anInterval [
	"Sets a new selection of characters. If the argument is nil, give the model a chance to just leave the selection where it currently is."
	
	(anInterval notNil and: [anInterval ~= selectionInterval]) ifTrue: [
		
		"Note old selection."
		textMorph selectionChanged.
		
		"Update selection."
		selectionInterval := anInterval.
		textMorph editor selectFrom: anInterval first to: anInterval last.

		"Note new selection."	
		textMorph selectionChanged].

	"Even if there is no change, ensure that the selection is visible."
	self scrollSelectionIntoView.
]

{ #category : #'model access' }
PluggableTextMorph >> setText: aText [

	textMorph newContents: aText.
	self hasUnacceptedEdits: false.
	self setScrollDeltas.	
	
	self flag: #performance. "mt: Needed only to redraw overlays such as the help text."
	self changed.
]

{ #category : #'model access' }
PluggableTextMorph >> setTextColor: aColor [
	"Set the color of my text to the given color"

	textMorph textColor: aColor
]

{ #category : #'editor access' }
PluggableTextMorph >> setTextMorphToSelectAllOnMouseEnter [
	"Tell my textMorph's editor to select all when the mouse enters"

	textMorph on: #mouseEnter send: #selectAll to: textMorph
]

{ #category : #accessing }
PluggableTextMorph >> setTextSelector [
	^setTextSelector
]

{ #category : #'menu commands' }
PluggableTextMorph >> spawn [
	self handleEdit: [textMorph editor spawn].
	self cancel
]

{ #category : #'menu commands' }
PluggableTextMorph >> spyOnIt [
	self handleEdit: [textMorph editor spyOnIt]
]

{ #category : #accessing }
PluggableTextMorph >> styler [
	"The styler responsible for highlighting text in the receiver.
	 Instances of PluggableTextMorph don;t have one."
	^nil
]

{ #category : #'menu commands' }
PluggableTextMorph >> tallyIt [
	self handleEdit: [textMorph editor tallyIt]
]

{ #category : #'model access' }
PluggableTextMorph >> text [
	^ textMorph contents
]

{ #category : #'editor access' }
PluggableTextMorph >> textEdited: someText [
	"Tell the model about some edits in the text if interested. This is not #accept, which means that it will be send on every keystroke."
	
	self editTextSelector ifNotNil: [:selector |
		model perform: selector with: someText].
	
	self flag: #performance. "mt: Needed only to redraw overlays such as the help text."
	self changed.
]

{ #category : #accessing }
PluggableTextMorph >> textMorph [
	^ textMorph
]

{ #category : #private }
PluggableTextMorph >> textMorphClass [
	"Answer the class used to create the receiver's textMorph"
	
	^TextMorphForEditView
]

{ #category : #'menu commands' }
PluggableTextMorph >> tileForIt [
	"Return a tile referring to the object resulting form evaluating my current selection.  Not currently threaded in, but useful in earlier demos and possibly still of value."

	
	self handleEdit:
		[textMorph editor evaluateSelectionAndDo: [:result | self currentHand attachMorph: result tileToRefer]]
]

{ #category : #'menu commands' }
PluggableTextMorph >> toggleAnnotationPaneSize [

	| handle origin aHand siblings |

	self flag: #bob.		"CRUDE HACK to enable changing the size of the annotations pane"

	owner ifNil: [^self].
	siblings := owner submorphs.
	siblings size > 3 ifTrue: [^self].
	siblings size < 2 ifTrue: [^self].

	aHand := self primaryHand.
	origin := aHand position.
	(handle := HandleMorph new)
		forEachPointDo: [:newPoint | | lf ht prevBottom newHeight m |
			handle removeAllMorphs.
			newHeight := (newPoint - origin) y asInteger min: owner height - 50 max: 16.
			lf := siblings last layoutFrame.
			lf bottomOffset: newHeight.
			prevBottom := newHeight.
			siblings size - 1 to: 1 by: -1 do: [ :index |
				m := siblings at: index.
				lf := m layoutFrame.
				ht := lf bottomOffset - lf topOffset.
				lf topOffset: prevBottom.
				lf bottomOffset = 0 ifFalse: [
					lf bottomOffset: (prevBottom + ht).
				].
				prevBottom := prevBottom + ht.
			].
			owner layoutChanged.

		]
		lastPointDo:
			[:newPoint | handle deleteBalloon.
			self halo ifNotNil: [:halo | halo addHandles].
		].
	aHand attachMorph: handle.
	handle setProperty: #helpAtCenter toValue: true.
	handle showBalloon:
'Move cursor farther from
this point to increase pane.
Click when done.' hand: aHand.
	handle startStepping


]

{ #category : #'menu commands' }
PluggableTextMorph >> undo [
	self handleEdit: [textMorph editor undo]
]

{ #category : #updating }
PluggableTextMorph >> update: aSymbol [ 
	aSymbol ifNil: [^self].
	aSymbol == #flash ifTrue: [^self flash].

	aSymbol == getTextSelector
		ifTrue: [
			self setText: self getText.
			getSelectionSelector
				ifNotNil: [self setSelection: self getSelection].
			^ self].
	aSymbol == getSelectionSelector 
		ifTrue: [^self setSelection: self getSelection].

	aSymbol == #acceptChanges ifTrue: [^ self accept].
	aSymbol == #revertChanges ifTrue: [^ self cancel].

	(aSymbol == #autoSelect and: [getSelectionSelector notNil]) 
		ifTrue: 
			[self handleEdit: 
					[(textMorph editor)
						abandonChangeText; "no replacement!"
						setSearch: model autoSelectString;
						findAgainNow "do not reset search string"]].
	aSymbol == #clearUserEdits ifTrue: [^self hasUnacceptedEdits: false].
	aSymbol == #wantToChange 
		ifTrue: 
			[self canDiscardEdits ifFalse: [^self promptForCancel].
			^self].
	aSymbol == #appendEntry 
		ifTrue: 
			[self handleEdit: [self appendEntry].
			^self refreshWorld].
	aSymbol == #appendEntryLater
		ifTrue: [self handleEdit: [self appendEntry]].
	aSymbol == #clearText 
		ifTrue: 
			[self handleEdit: [self changeText: Text new].
			^self refreshWorld].
	aSymbol == #bs 
		ifTrue: 
			[self handleEdit: [self bsText].
			^self refreshWorld].
	aSymbol == #codeChangedElsewhere 
		ifTrue: 
			[self hasEditingConflicts: true.
			^self changed].
	aSymbol == #saveContents
		ifTrue:
			[^self saveContentsInFile].
	aSymbol == #showContents
		ifTrue:
			[^ self scrollToTop].

]

{ #category : #updating }
PluggableTextMorph >> update: aSymbol with: arg1 [

	aSymbol == #editString ifTrue:[
		self editString: arg1.
		self hasUnacceptedEdits: true.
	].

	(aSymbol == #inputRequested and: [self getTextSelector == arg1 or: [self setTextSelector == arg1]])
		ifTrue: [self activeHand newKeyboardFocus: self].

	^super update: aSymbol with: arg1
]

{ #category : #'halos and balloon help' }
PluggableTextMorph >> wantsBalloon [

	^ self textMorph contents notEmpty and: [super wantsBalloon]
]

{ #category : #'dropping\/grabbing' }
PluggableTextMorph >> wantsDroppedMorph: aMorph event: anEvent [ 
	^ self model wantsDroppedMorph: aMorph event: anEvent inMorph: self
]

{ #category : #drawing }
PluggableTextMorph >> wantsFrameAdornments [
	"Answer whether the receiver wishes to have red borders, etc.,  
	used to show editing state"
	"A 'long-term temporary workaround': a nonmodular,  
	unsavory, but expedient way to get the desired effect, sorry.  
	Clean up someday."
	^ self
		valueOfProperty: #wantsFrameAdornments
		ifAbsent: [(#(#annotation #searchString #infoViewContents ) includes: getTextSelector) not]
]

{ #category : #drawing }
PluggableTextMorph >> wantsFrameAdornments: aBoolean [ 
	self setProperty: #wantsFrameAdornments toValue: aBoolean
]

{ #category : #accessing }
PluggableTextMorph >> wantsWrapBorder [

	^ wantsWrapBorder ifNil: [false]
]

{ #category : #accessing }
PluggableTextMorph >> wantsWrapBorder: aBoolean [

	wantsWrapBorder := aBoolean.
]

{ #category : #accessing }
PluggableTextMorph >> wrapBorderColor [

	^ self valueOfProperty: #wrapBorderColor ifAbsent: [Color gray alpha: 0.3]
]

{ #category : #accessing }
PluggableTextMorph >> wrapBorderColor: aColor [

	self setProperty: #wrapBorderColor toValue: aColor.
	self changed.
]

{ #category : #accessing }
PluggableTextMorph >> wrapFlag [

	^ textMorph ifNil: [false] ifNotNil: [:tm | tm isWrapped]
]

{ #category : #accessing }
PluggableTextMorph >> wrapFlag: aBoolean [

	textMorph ifNil: [self setText: ''].
	
	aBoolean
		ifTrue: [
			textMorph hResizing: #spaceFill.
			self hideHScrollBarIndefinitely]
		ifFalse: [
			textMorph hResizing: #shrinkWrap.
			self showHScrollBarOnlyWhenNeeded].

	self layoutChanged.
]

{ #category : #'menu commands' }
PluggableTextMorph >> yellowButtonActivity [
	"Called when the shifted-menu's 'more' item is chosen"
	self yellowButtonActivity: false
]
