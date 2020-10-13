Class {
	#name : #TextPropertiesMorph,
	#superclass : #GenericPropertiesMorph,
	#instVars : [
		'activeTextMorph',
		'applyToWholeText',
		'lastGlobalColor',
		'selectionInterval'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> activeEditor [

	^self activeTextMorph editor
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> activeTextMorph [

	^activeTextMorph
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> adjustTargetMargin: aFractionalPoint [

	| n |

	n := (aFractionalPoint * 4) rounded.
	myTarget margins: n.
	self showSliderFeedback: n.

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> alignCenter [
	self alignText: #centered.
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> alignJustified [
	self alignText:  #justified.
	
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> alignLeft [
	self alignText: #leftFlush.
	
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> alignRight [
	self alignText: #rightFlush.
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> alignText: aSymbol [
	self applyToWholeText ifTrue: [self activeEditor selectAll].
	self activeEditor setAlignment: aSymbol.
	self activeEditor paragraph composeAll.
	self activeEditor  recomputeSelection.
	self activeTextMorph updateFromParagraph.

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> applyToWholeText [

	^applyToWholeText
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> changeKernBy: delta [

	self changeSelectionAttributeTo: (TextKern kern: delta)
]

{ #category : #'button actions' }
TextPropertiesMorph >> changeSelectionAttributeTo: newAttribute [
	"Install an attribute into the canonical selection."

	| activeEditor |
	self establishSelectionInterval.

	activeEditor := self activeTextMorph editor.
	activeEditor replaceSelectionWith:
		(activeEditor selection asText addAttribute: newAttribute).
	self activeTextMorph updateFromParagraph.
	self activeTextMorph releaseEditor
]

{ #category : #'button actions' }
TextPropertiesMorph >> changeStyle [
	"Put up a menu allowing the user to choose a new style for the TextMorph."

	| anEditor |
	anEditor := self establishSelectionInterval.
	anEditor changeTextFont.
	
]

{ #category : #'button actions' }
TextPropertiesMorph >> changeTargetColorTo: aColor [
	"Change the selection's target to be of the given color."

	self establishSelectionInterval.
	self activeTextMorph selectionColor:  aColor.
	self activeTextMorph releaseEditor
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> changeToNormalText [

	self changeSelectionAttributeTo: (TextEmphasis normal)
]

{ #category : #initialization }
TextPropertiesMorph >> defaultBorderColor [
"answer the default border color/fill style for the receiver"
	^ self defaultColor darker
]

{ #category : #initialization }
TextPropertiesMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color
		r: 0.355
		g: 0.742
		b: 0.839
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> doAccept [

	myTarget 
		text: self activeTextMorph contents textStyle: self activeTextMorph textStyle;
		releaseCachedState;
		changed.
	lastGlobalColor ifNotNil: [myTarget textColor: lastGlobalColor].
	super doAccept.
]

{ #category : #initialization }
TextPropertiesMorph >> initialize [
	"initialize the state of the receiver"

	super initialize.

	applyToWholeText := false. 
	myTarget
		ifNil:
			[myTarget := TextMorph new openInWorld.
			myTarget contents: ''].
      selectionInterval := myTarget editor selectionInterval.
	activeTextMorph := myTarget copy. 
      thingsToRevert
		add: (#wrapFlag: ->  myTarget isWrapped);
		add: (#autoFit: ->  myTarget isAutoFit);
		add: (#setTextStyle: -> myTarget textStyle);
		add: (#margins: ->  myTarget margins);
		add: (#extent: ->  myTarget extent);
		add: (#textColor: ->  myTarget textColor);
		add: (#restoreText: ->  myTarget text deepCopy).
	self rebuild
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> kernMinus [

	self changeKernBy: -1
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> kernPlus [

	self changeKernBy: 1
]

{ #category : #'button actions' }
TextPropertiesMorph >> offerFontMenu [
	"Present a menu of available fonts, and if one is chosen, apply it to the current selection.  
	Use only names of Fonts of this paragraph  "

	| aList reply |
	self establishSelectionInterval.
	aList := self activeTextMorph textStyle fontNamesWithPointSizes.
	reply := (SelectionMenu labelList: aList selections: aList) startUp.
	reply ifNil: [^self].
	self establishSelectionInterval.  "This really does need to be called again!"
	self activeEditor replaceSelectionWith:
		(Text string: self activeEditor selection asString 
			attribute: (TextFontChange fontNumber: (aList indexOf: reply))).
	self activeTextMorph updateFromParagraph.
	self activeTextMorph releaseEditor
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> paneForApplyToWholeText [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #applyToWholeText
			setter: #toggleApplyToWholeText
			help: 'Whether to apply style changes to entire text or just selection' translated.
		self lockedString: ' Apply changes to entire text ' translated.
	}

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> paneForAutoFitToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetHasAutoFit
			setter: #toggleTargetAutoFit
			help: 'Turn auto-fit on or off' translated.
		self lockedString: ' Auto-Fit' translated.
	}

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> paneForMargins [

	^(self inARow: {
		self
			buildFakeSlider: 'Margins' translated 
			selector: #adjustTargetMargin:
			help: 'Drag in here to change the margins of the text' translated
	}) hResizing: #shrinkWrap


]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> paneForTextColorPicker [

	^self 
		inAColumn: {
			self 
				colorPickerFor: self
				getter: #targetTextColor
				setter: #changeTargetColorTo:.
			self lockedString: 'Text Color' translated.
		} 
		named: #pickerForTextColor.


]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> paneForWrappingToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetHasWrapping
			setter: #toggleTargetWrapping
			help: 'Turn line wrapping on or off' translated.
		self lockedString: ' Wrapping' translated.
	}

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> rebuild [

	| buttonColor c |

	self removeAllMorphs.
	self addAColumn: {
		self lockedString: ('Text Properties for {1}' translated format:{myTarget name}).
	}.
	self addAColumn: {
		self paneForApplyToWholeText.
	}.


	c := self addAColumn: {
		self activeTextMorph.
	}.
	c 
		wrapCentering: #topLeft;
		color: Color white;
		borderWidth: 2;
		borderColor: color darker.
	self addAColumn: {
		self paneForTextColorPicker.
	}.

	self addARow: {
		self paneForAutoFitToggle.
	}.
	self addARow: {
		self paneForWrappingToggle.
	}.
	self addARow: {
		self paneForMargins.
	}.

	buttonColor := color lighter.
	self addARow: {
		self inAColumn: {
			self addARow: {
				self 
					buttonNamed: 'Size' translated action: #offerFontMenu color: buttonColor
					help: 'font changing' translated.
				self 
					buttonNamed: 'Style' translated action: #changeStyle color: buttonColor
					help: 'font changing' translated.
				self 
					buttonNamed: 'N' translated action: #changeToNormalText color: buttonColor
					help: 'normal text' translated.
				self 
					buttonNamed: 'B' translated action: #toggleBold color: buttonColor
					help: 'bold text' translated.
				self 
					buttonNamed: 'I' translated action: #toggleItalic color: buttonColor
					help: 'italic text' translated.
				self 
					buttonNamed: 'n' translated action: #toggleNarrow color: buttonColor
					help: 'narrow text' translated.
				self 
					buttonNamed: 'U' translated action: #toggleUnderlined color: buttonColor
					help: 'underlined text' translated.
				self 
					buttonNamed: 'S' translated action: #toggleStruckOut color: buttonColor
					help: 'struck out text' translated.
				self 
					buttonNamed: 'Kern-' translated action: #kernMinus color: buttonColor
					help: 'decrease kern' translated.
				self 
					buttonNamed: 'Kern+' translated action: #kernPlus color: buttonColor
					help: 'increase kern' translated.
			}.
		}.
	}.
	self addARow: {
		self inAColumn: {
			self addARow: {
				self 
					buttonNamed: 'Left flush' translated action: #alignLeft color: buttonColor
					help: 'align text to left side' translated.
					
				self 
					buttonNamed: 'Center' translated action: #alignCenter color: buttonColor
					help: 'align text to center' translated.
				self 
					buttonNamed: 'Right Flush' translated action: #alignRight color: buttonColor
					help: 'align text to right side' translated.
				self 
					buttonNamed: 'Justified' translated action: #alignJustified color: buttonColor
					help: 'justify text alignmet' translated.
			}.
		}.
	}.
	self addARow: {
		self inAColumn: {
			self addARow: {
				self 
					buttonNamed: 'Accept' translated action: #doAccept color: buttonColor
					help: 'keep changes made and close panel' translated.
				self 
					buttonNamed: 'Cancel' translated action: #doCancel color: buttonColor
					help: 'cancel changes made and close panel' translated.
			}.
		}.
	}.

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> targetHasAutoFit [

	^myTarget isAutoFit

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> targetHasWrapping [

	^myTarget isWrapped

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> targetTextColor [
      
	 | attrs c ind |
      ind := selectionInterval start.
	
	(ind isNil or: [ind < 1 or: [ind >activeTextMorph text size]]) ifTrue: [ind := 1].
	attrs :=activeTextMorph text attributesAt: ind.
	c := attrs detect: [:attr | attr class = TextColor] ifNone: [].
	^ c ifNil: [Color black] ifNotNil: [c color].
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleApplyToWholeText [

	applyToWholeText := applyToWholeText not.

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleBold [

	self toggleSelectionAttribute: TextEmphasis bold
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleItalic [

	self toggleSelectionAttribute: TextEmphasis italic
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleNarrow [

	self toggleSelectionAttribute: TextEmphasis narrow
]

{ #category : #'button actions' }
TextPropertiesMorph >> toggleSelectionAttribute: newAttribute [
	"Toggle the given text-attribute  for the current text selection."

	| selText oldAttributes |
	self establishSelectionInterval.
	self activeEditor selectFrom:  selectionInterval start to: selectionInterval stop.

	selText := self activeEditor selection asText.
	oldAttributes := selText attributesAt: 1 forStyle: self activeTextMorph textStyle.
	oldAttributes do: [:att |
		(att dominates: newAttribute) ifTrue: [newAttribute turnOff]
	].
	self activeEditor replaceSelectionWith: (selText addAttribute: newAttribute).
	self activeTextMorph updateFromParagraph.
	self activeTextMorph releaseEditor
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleStruckOut [

	self toggleSelectionAttribute: TextEmphasis struckOut
]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleTargetAutoFit [

	^myTarget autoFitOnOff

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleTargetWrapping [

	^myTarget wrapOnOff

]

{ #category : #'as yet unclassified' }
TextPropertiesMorph >> toggleUnderlined [

	self toggleSelectionAttribute: TextEmphasis underlined
]
