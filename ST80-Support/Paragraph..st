"
I represent displayable text that has been decoraged with margin alignment, line leading, and tab settings.
"
Class {
	#name : #Paragraph,
	#superclass : #DisplayText,
	#instVars : [
		'clippingRectangle',
		'compositionRectangle',
		'destinationForm',
		'rule',
		'mask',
		'marginTabsLevel',
		'lines',
		'lastLine'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'ST80-Support'
}

{ #category : #examples }
Paragraph class >> example [
	"This simple example illustrates how to display a few lines of text on the screen at the current cursor point.  
	Fixed. "

	| para point |
	point := Sensor waitButton.
	para := 'This is the first line of characters
and this is the second line.' asParagraph.
	para displayOn: Display at: point.

	"Paragraph example"
]

{ #category : #'instance creation' }
Paragraph class >> new [
	"Do not allow an uninitialized view. Create with text that has no
	characters."

	^self withText: '' asText
]

{ #category : #'instance creation' }
Paragraph class >> withText: aText [ 
	"Answer an instance of me with text set to aText and style set to the 
	system's default text style."

	^self withText: aText style: DefaultTextStyle copy
]

{ #category : #'instance creation' }
Paragraph class >> withText: aText style: aTextStyle [ 
	"Answer an instance of me with text set to aText and style set to 
	aTextStyle."

	^super new setWithText: aText style: aTextStyle
]

{ #category : #'instance creation' }
Paragraph class >> withText: aText style: aTextStyle compositionRectangle: compRect clippingRectangle: clipRect foreColor: c1 backColor: c2 [
	"Answer an instance of me with text set to aText and style set to 
	aTextStyle, composition rectangle is compRect and the clipping rectangle 
	is clipRect."
	| para |
	para := super new.
	para setWithText: aText
		style: aTextStyle
		compositionRectangle: compRect
		clippingRectangle: clipRect
		foreColor: c1 backColor: c2.
	^para
]

{ #category : #converting }
Paragraph >> asForm [
	"Answer a Form made up of the bits that represent the receiver's displayable text."

	| theForm |
	theForm := textStyle maxDepth = 1
		ifTrue: [
			(ColorForm extent: compositionRectangle extent)
				offset: offset;
				colors: {
					backColor ifNil: [Color transparent].
					foreColor ifNil: [Color black]}]
		ifFalse: [
			(Form extent: compositionRectangle extent depth: Display depth)
				offset: offset].

	self displayOn: theForm
		at: 0@0
		clippingBox: theForm boundingBox
		rule: Form over
		fillColor: nil.

	^ theForm

"Example:
| p |
p := 'Abc' asParagraph.
p foregroundColor: Color red backgroundColor: Color black.
p asForm displayOn: Display at: 30@30 rule: Form over"

]

{ #category : #converting }
Paragraph >> asString [
	"Answer the string of characters of the receiver's text."

	^text string
]

{ #category : #converting }
Paragraph >> asText [
	"Answer the receiver's text."

	^text
]

{ #category : #accessing }
Paragraph >> backgroundColor [
	backColor == nil ifTrue: [^ Color white].
	^ backColor
]

{ #category : #private }
Paragraph >> bottomAtLineIndex: lineIndex [ 
	"Answer the bottom y of given line."
	| y |
	y := compositionRectangle top.
	lastLine = 0 ifTrue: [^ y + textStyle lineGrid].
	1 to: (lineIndex min: lastLine) do:
		[:i | y := y + (lines at: i) lineHeight].
	^ y

]

{ #category : #'display box access' }
Paragraph >> boundingBox [

	^offset extent: compositionRectangle extent
]

{ #category : #selecting }
Paragraph >> caretFormForDepth: depth [
	"Return a caret form for the given depth."
	"(Paragraph new caretFormForDepth: Display depth) displayOn: Display at: 0@0 rule: Form reverse"

	| box f bb map |
	box := CaretForm boundingBox.
	f := Form extent: box extent depth: depth.
	map := (Color cachedColormapFrom: CaretForm depth to: depth) copy.
	map at: 1 put: (Color transparent pixelValueForDepth: depth).
	map at: 2 put: (Color quickHighLight: depth) first.  "pixel value for reversing"
	bb := BitBlt toForm: f.
	bb
		sourceForm: CaretForm;
		sourceRect: box;
		destOrigin: 0@0;
		colorMap: map;
 		combinationRule: Form over;
		copyBits.
	^ f
]

{ #category : #alignment }
Paragraph >> centered [ 
	"Set the alignment for the style with which the receiver displays its text 
	so that text is centered in the composition rectangle."

	textStyle alignment: Centered
]

{ #category : #'character location' }
Paragraph >> characterBlockAtPoint: aPoint [ 
	"Answer a CharacterBlock for characters in the text at point aPoint. It is 
	assumed that aPoint has been transformed into coordinates appropriate to 
	the receiver's destinationForm rectangle and the compositionRectangle."

	^CharacterBlockScannerForMVC new characterBlockAtPoint: aPoint in: self
]

{ #category : #'character location' }
Paragraph >> characterBlockForIndex: targetIndex [ 
	"Answer a CharacterBlock for character in the text at targetIndex. The 
	coordinates in the CharacterBlock will be appropriate to the intersection 
	of the destinationForm rectangle and the compositionRectangle."

	^CharacterBlockScannerForMVC new characterBlockForIndex: targetIndex in: self
]

{ #category : #utilities }
Paragraph >> clearVisibleRectangle [ 
	"Display the area in which the receiver presents its text so that the area 
	is all one tone--in this case, all white."

	destinationForm
	  fill: clippingRectangle
	  rule: rule
	  fillColor: self backgroundColor
]

{ #category : #selecting }
Paragraph >> clickAt: clickPoint for: model controller: aController [
	"Give sensitive text a chance to fire.  Display flash: (100@100 extent: 100@100)."
	| startBlock action |
	action := false.
	startBlock := self characterBlockAtPoint: clickPoint.
	(text attributesAt: startBlock stringIndex forStyle: textStyle) 
		do: [:att | att mayActOnClick ifTrue:
				[| range boxes box |
				range := text rangeOf: att startingAt: startBlock stringIndex.
				boxes := self selectionRectsFrom: (self characterBlockForIndex: range first) 
							to: (self characterBlockForIndex: range last+1).
				box := boxes detect: [:each | each containsPoint: clickPoint]
							ifNone: [^ action].
				Utilities awaitMouseUpIn: box repeating: []
					ifSucceed: [aController terminateAndInitializeAround:
								[(att actOnClickFor: model in: self at: clickPoint editor: aController) ifTrue: [action := true]]]]].
	^ action
]

{ #category : #accessing }
Paragraph >> clippingRectangle [ 
	"Answer the rectangle, defined in absolute coordinates, whose 
	intersection with the destinationForm is the area in which the characters 
	are constrained to display."

	^clippingRectangle
]

{ #category : #accessing }
Paragraph >> clippingRectangle: clipRect [ 
	clippingRectangle := clipRect
]

{ #category : #composition }
Paragraph >> composeAll [
	"Compose a collection of characters into a collection of lines."

	| startIndex stopIndex lineIndex maximumRightX compositionScanner |
	lines := Array new: 32.
	lastLine := 0.
	maximumRightX := 0.
	text size = 0
		ifTrue:
			[compositionRectangle := compositionRectangle withHeight: 0.
			^maximumRightX].
	startIndex := lineIndex := 1.
	stopIndex := text size.
	compositionScanner := CompositionScanner new forParagraph: self.
	[startIndex > stopIndex] whileFalse: 
		[self lineAt: lineIndex 
				put: (compositionScanner composeLine: lineIndex 
										fromCharacterIndex: startIndex 
										inParagraph: self).
		 maximumRightX := compositionScanner rightX max: maximumRightX.
		 startIndex := (lines at: lineIndex) last + 1.
		 lineIndex := lineIndex + 1].
	self updateCompositionHeight.
	self trimLinesTo: lineIndex - 1.
	^ maximumRightX
]

{ #category : #accessing }
Paragraph >> compositionRectangle [
	"Answer the rectangle whose width is the dimension, modified by 
	indents and tabsLevels, against which line wraparound is measured. The 
	height of the compositionRectangle is reset each time recomposition is 
	required."

	^compositionRectangle
]

{ #category : #accessing }
Paragraph >> compositionRectangle: compRectangle [ 
	"Set the rectangle whose width is the dimension, modified by indents and 
	tabsLevels, against which line wraparound is measured."

	compositionRectangle := compRectangle.
	self composeAll
]

{ #category : #private }
Paragraph >> compositionRectangle: compositionRect text: aText style: aTextStyle offset: aPoint [

	compositionRectangle := compositionRect copy.
	text := aText.
	textStyle := aTextStyle.
	rule := DefaultRule.
	mask := nil.		"was DefaultMask "
	marginTabsLevel := 0.
	destinationForm := Display.
	offset := aPoint.
	^self composeAll
]

{ #category : #private }
Paragraph >> compositionRectangleDelta [
	"A handy number -- mostly for scrolling."

	^compositionRectangle top - clippingRectangle top
]

{ #category : #'display box access' }
Paragraph >> computeBoundingBox [

	^offset extent: compositionRectangle extent
]

{ #category : #utilities }
Paragraph >> deepCopy [
	"Don't want to copy the destForm (Display) or fonts in the TextStyle.  9/13/96 tk"

	| new |
	new := self copy.
	new textStyle: textStyle copy.
	new destinationForm: destinationForm.
	new lines: lines copy.
	new text: text deepCopy.
	^ new
]

{ #category : #'character location' }
Paragraph >> defaultCharacterBlock [
	^ CharacterBlock new stringIndex: 1 text: text
			topLeft: compositionRectangle topLeft extent: 0 @ 0
]

{ #category : #accessing }
Paragraph >> destinationForm [ 
	 "Answer the Form into which the characters are scanned."

	^destinationForm
]

{ #category : #utilities }
Paragraph >> destinationForm: destForm [
	destinationForm := destForm
]

{ #category : #private }
Paragraph >> displayLines: linesInterval [ 
	^ self displayLines: linesInterval
		affectedRectangle: self visibleRectangle
]

{ #category : #private }
Paragraph >> displayLines: linesInterval affectedRectangle: affectedRectangle [
	"This is the first level workhorse in the display portion of the TextForm routines.
	It checks to see which lines in the interval are actually visible, has the
	CharacterScanner display only those, clears out the areas in which display will
	occur, and clears any space remaining in the visibleRectangle following the space
	occupied by lastLine."

	| topY firstLineIndex lastLineIndex lastLineIndexBottom |

	"Save some time by only displaying visible lines"
	firstLineIndex := self lineIndexOfTop: affectedRectangle top.
	firstLineIndex < linesInterval first ifTrue: [firstLineIndex := linesInterval first].
	lastLineIndex := self lineIndexOfTop: affectedRectangle bottom - 1.
	lastLineIndex > linesInterval last ifTrue:
			[linesInterval last > lastLine
		 		ifTrue: [lastLineIndex := lastLine]
		  		ifFalse: [lastLineIndex := linesInterval last]].
	lastLineIndexBottom := (self bottomAtLineIndex: lastLineIndex).
	((Rectangle 
		origin: affectedRectangle left @ (topY := self topAtLineIndex: firstLineIndex) 
		corner: affectedRectangle right @ lastLineIndexBottom)
	  intersects: affectedRectangle)
		ifTrue: [ " . . . (skip to clear-below if no lines displayed)"
				BitBltDisplayScanner new
					displayLines: (firstLineIndex to: lastLineIndex)
					in: self clippedBy: affectedRectangle].
	lastLineIndex = lastLine ifTrue: 
		 [destinationForm  "Clear out white space below last line"
		 	fill: (affectedRectangle left @ (lastLineIndexBottom max: affectedRectangle top)
				corner: affectedRectangle bottomRight)
		 	rule: rule fillColor: self backgroundColor]
]

{ #category : #displaying }
Paragraph >> displayOn: aDisplayMedium [
	"Because Paragraphs cache so much information, computation is avoided
	and displayAt: 0@0 is not appropriate here."

	self displayOn: aDisplayMedium
		at: compositionRectangle topLeft
		clippingBox: clippingRectangle
		rule: rule
		fillColor: mask
]

{ #category : #displaying }
Paragraph >> displayOn: aDisplayMedium at: aPoint [
	"Use internal clippingRect; destination cliping is done during actual display."

	self displayOn: aDisplayMedium at: aPoint
		clippingBox: (clippingRectangle translateBy: aPoint - compositionRectangle topLeft)
		rule: rule fillColor: mask
]

{ #category : #displaying }
Paragraph >> displayOn: aDisplayMedium at: aDisplayPoint clippingBox: clipRectangle rule: ruleInteger fillColor: aForm [
	"Default display message when aDisplayPoint is in absolute screen
	coordinates."

	rule := ruleInteger.
	mask := aForm.
	clippingRectangle := clipRectangle.
	compositionRectangle := aDisplayPoint extent: compositionRectangle extent.
	(lastLine == nil or: [lastLine < 1]) ifTrue: [self composeAll].
	self displayOn: aDisplayMedium lines: (1 to: lastLine)
]

{ #category : #private }
Paragraph >> displayOn: aDisplayMedium lines: lineInterval [

	| saveDestinationForm |
	saveDestinationForm := destinationForm.
	destinationForm := aDisplayMedium.
	self displayLines: lineInterval.
	destinationForm := saveDestinationForm
]

{ #category : #displaying }
Paragraph >> displayOn: aDisplayMedium transformation: displayTransformation clippingBox: clipRectangle align: alignmentPoint with: relativePoint rule: ruleInteger fillColor: aForm [ 

	self				"Assumes offset has been set!!!!!"
	  displayOn: aDisplayMedium
	  at: (offset 
			+ (displayTransformation applyTo: relativePoint) 
			- alignmentPoint) rounded
	  clippingBox: clipRectangle
	  rule: ruleInteger
	  fillColor: aForm.
	
]

{ #category : #selecting }
Paragraph >> extendSelectionAt: beginBlock endBlock: endBlock [ 
	"Answer with an Array of two CharacterBlocks that represent the text 
	selection that the user makes."
	
	(self characterBlockAtPoint: Sensor cursorPoint) <= beginBlock
		ifTrue: [^self mouseMovedFrom: beginBlock 
					pivotBlock: endBlock
					showingCaret: (beginBlock = endBlock)]
		ifFalse: [^self mouseMovedFrom: endBlock 
					pivotBlock: beginBlock
					showingCaret: (beginBlock = endBlock)]

]

{ #category : #selecting }
Paragraph >> extendSelectionMark: markBlock pointBlock: pointBlock [ 
	"Answer with an Array of two CharacterBlocks that represent the text 
	selection that the user makes."
	true 
		ifTrue:[^self mouseMovedFrom: pointBlock
					pivotBlock: markBlock
					showingCaret:(pointBlock = markBlock)]
		ifFalse:
		[	| beginBlock endBlock |
			beginBlock := markBlock min: pointBlock.
			endBlock := markBlock max: endBlock.
	
			(self characterBlockAtPoint: Sensor cursorPoint) <= beginBlock
				ifTrue: [^self mouseMovedFrom: beginBlock 
							pivotBlock: endBlock
							showingCaret: (beginBlock = endBlock)]
				ifFalse: [^self mouseMovedFrom: endBlock 
							pivotBlock: beginBlock
							showingCaret: (beginBlock = endBlock)]
		]

]

{ #category : #accessing }
Paragraph >> fillColor [ 
	"Answer the Form with which each character is combined by the scanner 
	before applying the rule for display."

	^mask
]

{ #category : #accessing }
Paragraph >> fillColor: maskForm [ 
	"Set the argument, maskForm, to be the form with which each character 
	is combined by the scanner before applying the rule for display."

	mask := maskForm
]

{ #category : #utilities }
Paragraph >> fit [
	"Make the bounding rectangle of the receiver contain all the text without 
	changing the width of the receiver's composition rectangle."

	[(self lineIndexOfTop: clippingRectangle top) = 1]
		whileFalse: [self scrollBy: (0-1)*textStyle lineGrid].
	self updateCompositionHeight.
	clippingRectangle := clippingRectangle withBottom: compositionRectangle bottom
]

{ #category : #indicating }
Paragraph >> flash [ 
	"Complement twice the visible area in which the receiver displays."

	Display flash: clippingRectangle
]

{ #category : #accessing }
Paragraph >> height [ 
	"Answer the height of the composition rectangle."

	^compositionRectangle height
]

{ #category : #selecting }
Paragraph >> hiliteRect: rect [

	rect ifNotNil: [
		| highlightColor |
		highlightColor := Color quickHighLight: destinationForm depth.
		destinationForm
			fill: rect
			rule: Form reverse
			fillColor: highlightColor].

]

{ #category : #accessing }
Paragraph >> indentationOfLineIndex: lineIndex ifBlank: aBlock [
	"Answer the number of leading tabs in the line at lineIndex.  If there are
	 no visible characters, pass the number of tabs to aBlock and return its value.
	 If the line is word-wrap overflow, back up a line and recur."

	| arrayIndex first last reader leadingTabs lastSeparator lf tab ch |
	lf := Character lf.
	tab := Character tab.
	arrayIndex := lineIndex.
	[first := (lines at: arrayIndex) first.
	 first > 1 and: [(text string at: first - 1) ~~ CR and: [(text string at: first - 1) ~~ lf]]] whileTrue: "word wrap"
		[arrayIndex := arrayIndex - 1].
	last := (lines at: lastLine) last.
	reader := ReadStream on: text string from: first to: last.
	leadingTabs := 0.
	[reader atEnd not and: [(ch := reader next) == tab]]
		whileTrue: [leadingTabs := leadingTabs + 1].
	lastSeparator := first - 1 + leadingTabs.
	[reader atEnd not and: [ch isSeparator and: [ch ~~ CR and: [ch ~~ lf]]]]
		whileTrue: [lastSeparator := lastSeparator + 1. ch := reader next].
	(lastSeparator = last or: [ch == CR or: [ch == lf]])
		ifTrue: [^aBlock value: leadingTabs].
	^leadingTabs
]

{ #category : #alignment }
Paragraph >> justified [ 
	"Set the alignment for the style with which the receiver displays its text 
	so that the characters in each of text end on an even border in the 
	composition rectangle."

	textStyle alignment: Justified
]

{ #category : #alignment }
Paragraph >> leftFlush [ 
	"Set the alignment for the style with which the receiver displays its text 
	so that the characters in each of text begin on an even border in the 
	composition rectangle. This is also known as ragged-right."

	textStyle alignment: LeftFlush
]

{ #category : #private }
Paragraph >> leftMarginForCompositionForLine: lineIndex [ 
	"Build the left margin for composition of a line. Depends upon
	marginTabsLevel and the indent."

	| indent |
	lineIndex = 1
		ifTrue: [indent := textStyle firstIndent]
		ifFalse: [indent := textStyle restIndent].
	^indent + (textStyle leftMarginTabAt: marginTabsLevel)
]

{ #category : #private }
Paragraph >> leftMarginForDisplayForLine: lineIndex alignment: alignment [
	"Build the left margin for display of a line. Depends upon
	leftMarginForComposition, compositionRectangle left and the alignment."

	| pad |
	(alignment = LeftFlush or: [alignment = Justified])
		ifTrue: 
			[^compositionRectangle left 
				+ (self leftMarginForCompositionForLine: lineIndex)].
	"When called from character location code and entire string has been cut,
	there are no valid lines, hence following nil check."
	(lineIndex <= lines size and: [(lines at: lineIndex) notNil])
		ifTrue: 
			[pad := (lines at: lineIndex) paddingWidth]
		ifFalse: 
			[pad := 
				compositionRectangle width - textStyle firstIndent - textStyle rightIndent].
	alignment = Centered 
		ifTrue: 
			[^compositionRectangle left 
				+ (self leftMarginForCompositionForLine: lineIndex) + (pad // 2)].
	alignment = RightFlush 
		ifTrue:
			[^compositionRectangle left 
				+ (self leftMarginForCompositionForLine: lineIndex) + pad].
	self error: ['no such alignment']
]

{ #category : #private }
Paragraph >> lineAt: indexInteger put: aTextLineInterval [ 
	"Store a line, track last, and grow lines if necessary."
	indexInteger > lastLine ifTrue: [lastLine := indexInteger].
	lastLine > lines size ifTrue: [lines := lines , (Array new: lines size)].
	^lines at: indexInteger put: aTextLineInterval
]

{ #category : #private }
Paragraph >> lineIndexOfCharacterIndex: characterIndex [ 
	"Answer the line index for a given characterIndex."

	1 to: lastLine do: 
		[:lineIndex | 
		(lines at: lineIndex) last >= characterIndex ifTrue: [^lineIndex]].
	^lastLine
]

{ #category : #private }
Paragraph >> lineIndexOfTop: top [ 
	"Answer the line index at a given top y."
	| y line |
	lastLine = 0 ifTrue: [^ 1].
	y := compositionRectangle top.
	1 to: lastLine do:
		[:i | line := lines at: i.
		(y := y + line lineHeight) > top ifTrue: [^ i]].
	^ lastLine

]

{ #category : #private }
Paragraph >> lines [

	^lines
]

{ #category : #utilities }
Paragraph >> lines: lineArray [
	lines := lineArray
]

{ #category : #accessing }
Paragraph >> mask [ 
	"Answer the Form with which each character is combined by the scanner 
	before applying the rule for display."

	^mask
]

{ #category : #selecting }
Paragraph >> mouseMovedFrom: beginBlock pivotBlock: pivotBlock showingCaret: caretOn [ 
	| startBlock stopBlock showingCaret |
	stopBlock := startBlock := beginBlock.
	showingCaret := caretOn.
	[Sensor redButtonPressed]
		whileTrue: 
			[stopBlock := self characterBlockAtPoint: Sensor cursorPoint.
			stopBlock = startBlock
				ifFalse: 
					[showingCaret
						ifTrue: 
							[showingCaret := false.
							self reverseFrom: pivotBlock to: pivotBlock].
			((startBlock >= pivotBlock and: [stopBlock >= pivotBlock])
				or: [startBlock <= pivotBlock and: [stopBlock <= pivotBlock]])
				ifTrue: 
					[self reverseFrom: startBlock to: stopBlock.
					startBlock := stopBlock]
				ifFalse: 
					[self reverseFrom: startBlock to: pivotBlock.
					self reverseFrom: pivotBlock to: stopBlock.
					startBlock := stopBlock].
			(clippingRectangle containsRect: stopBlock) ifFalse:
				[stopBlock top < clippingRectangle top
				ifTrue: [self scrollBy: stopBlock top - clippingRectangle top
						withSelectionFrom: pivotBlock to: stopBlock]
				ifFalse: [self scrollBy: stopBlock bottom + textStyle lineGrid - clippingRectangle bottom
						withSelectionFrom: pivotBlock to: stopBlock]]]].
	pivotBlock = stopBlock ifTrue:
		[showingCaret ifFalse:  "restore caret"
			[self reverseFrom: pivotBlock to: pivotBlock]].
	^ Array with: pivotBlock with: stopBlock
]

{ #category : #selecting }
Paragraph >> mouseSelect [
	"Answer with an Array of two CharacterBlocks that represent the text 
	selection that the user makes.  Return quickly if the button is noticed up
	to make double-click more responsive."

	| pivotBlock startBlock stopBlock origPoint stillDown |
	stillDown := Sensor redButtonPressed.
	pivotBlock := startBlock := stopBlock :=
		self characterBlockAtPoint: (origPoint := Sensor cursorPoint).
	stillDown := stillDown and: [Sensor redButtonPressed].
	self reverseFrom: startBlock to: startBlock.
	[stillDown and: [Sensor cursorPoint = origPoint]] whileTrue:
		[stillDown := Sensor redButtonPressed].
	(stillDown and: [clippingRectangle containsPoint: Sensor cursorPoint])
		ifFalse: [^Array with: pivotBlock with: stopBlock].
	^ self mouseMovedFrom: startBlock 
		pivotBlock: pivotBlock
		showingCaret: true
]

{ #category : #selecting }
Paragraph >> mouseSelect: clickPoint [ 
	"Track text selection and answer with an Array of two CharacterBlocks."
	| startBlock |
	startBlock := self characterBlockAtPoint: clickPoint.
	self reverseFrom: startBlock to: startBlock.
	^ self mouseMovedFrom: startBlock 
		pivotBlock: startBlock
		showingCaret: true
]

{ #category : #private }
Paragraph >> moveBy: delta [
	compositionRectangle := compositionRectangle translateBy: delta.
	clippingRectangle := clippingRectangle translateBy: delta.

]

{ #category : #accessing }
Paragraph >> numberOfLines [ 
	"Answer the number of lines of text in the receiver."

	^lastLine
]

{ #category : #indicating }
Paragraph >> outline [ 
	"Display a border around the visible area in which the receiver presents 
	its text."

	clippingRectangle bottom <= compositionRectangle bottom
	  ifTrue: [Display 
				border: (clippingRectangle intersect: compositionRectangle) 
				width: 2]
	  ifFalse: [Display 
				border: (clippingRectangle intersect: destinationForm boundingBox)
				width: 2].
	
]

{ #category : #accessing }
Paragraph >> replaceFrom: start to: stop with: aText displaying: displayBoolean [
	"Replace the receiver's text starting at position start, stopping at stop, by 
	the characters in aText. It is expected that most requirements for 
	modifications to the receiver will call this code. Certainly all cut's or 
	paste's." 

	| compositionScanner obsoleteLines obsoleteLastLine firstLineIndex lastLineIndex
	startLine stopLine replacementRange visibleRectangle startIndex newLine done
	newStop obsoleteY newY moveRectangle |

	text replaceFrom: start to: stop with: aText.		"Update the text."
	lastLine = 0 ifTrue:
		["if lines have never been set up, measure them and display
		all the lines falling in the visibleRectangle"
		self composeAll.
		displayBoolean ifTrue: [^ self displayLines: (1 to: lastLine)]].

	"save -- things get pretty mashed as we go along"
	obsoleteLines := lines copy.
	obsoleteLastLine := lastLine.

	"find the starting and stopping lines"
	firstLineIndex := startLine := self lineIndexOfCharacterIndex: start.
	stopLine := self lineIndexOfCharacterIndex: stop.

	"how many characters being inserted or deleted
		-- negative if aText size is < characterInterval size."
	replacementRange := aText size - (stop - start + 1).
	"Give ourselves plenty of elbow room."
	compositionRectangle := compositionRectangle withHeight: (textStyle lineGrid * 9999).
	"build a boundingBox of the actual screen space in question -- we'll need it later"
	visibleRectangle := (clippingRectangle intersect: compositionRectangle)
							intersect: destinationForm boundingBox.
	compositionScanner := CompositionScanner new forParagraph: self.		"Initialize a scanner."

	"If the starting line is not also the first line, then measuring must commence from line preceding the one in which characterInterval start appears.  For example, deleting a line with only a carriage return may move characters following the deleted portion of text into the line preceding the deleted line."
	startIndex := (lines at: firstLineIndex) first.
	startLine > 1
		ifTrue: 	[newLine := compositionScanner composeLine: startLine - 1
						fromCharacterIndex: (lines at: startLine - 1) first
						inParagraph: self.
				(lines at: startLine - 1) = newLine
					ifFalse:	["start in line preceding the one with the starting character"
							startLine := startLine - 1.
							self lineAt: startLine put: newLine.
							startIndex := newLine last + 1]].
	startIndex > text size ifTrue:
		["nil lines after a deletion -- remeasure last line below"
		self trimLinesTo: (firstLineIndex - 1 max: 0).
		text size = 0 ifTrue:
			["entire text deleted -- clear visibleRectangle and return."
			displayBoolean ifTrue: [destinationForm fill: visibleRectangle rule: rule fillColor: self backgroundColor].
			self updateCompositionHeight.
			^self]].

	"Now we really get to it."
	done := false.
	lastLineIndex := stopLine.
	[done or: [startIndex > text size]]
		whileFalse: 
		[self lineAt: firstLineIndex put:
			(newLine := compositionScanner composeLine: firstLineIndex
							fromCharacterIndex: startIndex inParagraph: self).
		[(lastLineIndex > obsoleteLastLine
			or: ["no more old lines to compare with?"
				newLine last <
					(newStop := (obsoleteLines at: lastLineIndex) last + replacementRange)])
			  	or: [done]]
			whileFalse: 
			[newStop = newLine last
				ifTrue:	["got the match"
						"get source and dest y's for moving the unchanged lines"
						obsoleteY := self topAtLineIndex: lastLineIndex + 1
									using: obsoleteLines and: obsoleteLastLine.
						newY := self topAtLineIndex: firstLineIndex + 1.
						stopLine := firstLineIndex.
						done := true.
							"Fill in the new line vector with the old unchanged lines.
							Update their starting and stopping indices on the way."
						((lastLineIndex := lastLineIndex + 1) to: obsoleteLastLine) do:
							[:upDatedIndex | 
							self lineAt: (firstLineIndex := firstLineIndex + 1) 
								put: ((obsoleteLines at: upDatedIndex)
							  		slide: replacementRange)].
							"trim off obsolete lines, if any"
						self trimLinesTo: firstLineIndex]
				ifFalse:	[lastLineIndex := lastLineIndex + 1]].
		startIndex := newLine last + 1.
		firstLineIndex := firstLineIndex + 1].

	"Now the lines are up to date -- Whew!.  What remains is to move
	the 'unchanged' lines and display those which have changed."
	displayBoolean   "Not much to do if not displaying"
		ifFalse: [^ self updateCompositionHeight].
	startIndex > text size ifTrue:
		["If at the end of previous lines simply display lines from the line in
		which the first character of the replacement occured through the
		end of the paragraph."
		self updateCompositionHeight.
		self displayLines:
			(startLine to: (stopLine := firstLineIndex min: lastLine)).
		destinationForm  "Clear out area at the bottom"
			fill: ((visibleRectangle left @ (self topAtLineIndex: lastLine + 1)
						extent: visibleRectangle extent)
					intersect: visibleRectangle)
			rule: rule fillColor: self backgroundColor]
		ifFalse:
		[newY ~= obsoleteY ifTrue:
			["Otherwise first move the unchanged lines within
			the visibleRectangle with a good old bitblt."
			moveRectangle :=
				visibleRectangle left @ (obsoleteY max: visibleRectangle top)
					corner: visibleRectangle corner.
			destinationForm copyBits: moveRectangle from: destinationForm
				at: moveRectangle origin + (0 @ (newY-obsoleteY))
				clippingBox: visibleRectangle
				rule: Form over fillColor: nil].

		"Then display the altered lines."
		self displayLines: (startLine to: stopLine).

		newY < obsoleteY
			ifTrue:
			[(self topAtLineIndex: obsoleteLastLine+1 using: obsoleteLines and: obsoleteLastLine) > visibleRectangle bottom
				ifTrue:
				["A deletion may have 'pulled' previously undisplayed lines
				into the visibleRectangle.  If so, display them."
				self displayLines:
					((self lineIndexOfTop: visibleRectangle bottom - (obsoleteY - newY))
						to: (self lineIndexOfTop: visibleRectangle bottom))].
			"Clear out obsolete material at the bottom of the visibleRectangle."
			destinationForm
				fill: ((visibleRectangle left @ ((self bottomAtLineIndex: lastLine) + 1)
						extent: visibleRectangle extent)
					intersect: visibleRectangle)  "How about just corner: ??"
				rule: rule fillColor: self backgroundColor].

		(newY > obsoleteY and: [obsoleteY < visibleRectangle top])
			ifTrue:
				["An insertion may have 'pushed' previously undisplayed lines
				into the visibleRectangle.  If so, display them."
				self displayLines:
					((self lineIndexOfTop: visibleRectangle top)
						to: (self lineIndexOfTop: visibleRectangle top + (newY-obsoleteY)))].

		self updateCompositionHeight]
]

{ #category : #selecting }
Paragraph >> reverseFrom: characterBlock1 to: characterBlock2 [ 
	"Reverse area between the two character blocks given as arguments."
	| visibleRectangle initialRectangle interiorRectangle finalRectangle lineNo baseline caret |
	characterBlock1 = characterBlock2 ifTrue:
		[lineNo := self lineIndexOfCharacterIndex: characterBlock1 stringIndex.
		baseline := lineNo = 0 ifTrue: [textStyle baseline]
							ifFalse: [(lines at: lineNo) baseline].
		caret := self caretFormForDepth: Display depth.
		^ caret  "Use a caret to indicate null selection"
				displayOn: destinationForm
				at: characterBlock1 topLeft + (-3 @ baseline)
				clippingBox: clippingRectangle
				rule: (false "Display depth>8" ifTrue: [9 "not-reverse"]
									ifFalse: [Form reverse])
				fillColor: nil].
	visibleRectangle := 
		(clippingRectangle intersect: compositionRectangle)
			"intersect: destinationForm boundingBox" "not necessary".
	characterBlock1 top = characterBlock2 top
		ifTrue: [characterBlock1 left < characterBlock2 left
					ifTrue: 
						[initialRectangle := 
							(characterBlock1 topLeft corner: characterBlock2 bottomLeft)
								intersect: visibleRectangle]
					ifFalse: 
						[initialRectangle := 
							(characterBlock2 topLeft corner: characterBlock1 bottomLeft)
								intersect: visibleRectangle]]
		ifFalse: [characterBlock1 top < characterBlock2 top
				ifTrue: 
					[initialRectangle := 
						(characterBlock1 topLeft 
							corner: visibleRectangle right @ characterBlock1 bottom)
							intersect: visibleRectangle.
					finalRectangle := 
						(visibleRectangle left @ characterBlock2 top 
							corner: characterBlock2 bottomLeft)
							intersect: visibleRectangle.
					characterBlock1 bottom = characterBlock2 top
						ifFalse: 
							[interiorRectangle := 
								(visibleRectangle left @ characterBlock1 bottom
									corner: visibleRectangle right @ characterBlock2 top)
									intersect: visibleRectangle]]
				ifFalse: 
					[initialRectangle := 
						(visibleRectangle left @ characterBlock1 top 
							corner: characterBlock1 bottomLeft)
							intersect: visibleRectangle.
					finalRectangle := 
						(characterBlock2 topLeft 
							corner: visibleRectangle right @ characterBlock2 bottom)
							intersect: visibleRectangle.
					characterBlock1 top = characterBlock2 bottom
						ifFalse: 
							[interiorRectangle := 
								(visibleRectangle left @ characterBlock2 bottom 
									corner: visibleRectangle right @ characterBlock1 top)
									intersect: visibleRectangle]]].
	self hiliteRect: initialRectangle.
	self hiliteRect: interiorRectangle.
	self hiliteRect: finalRectangle.
]

{ #category : #alignment }
Paragraph >> rightFlush [ 
	"Set the alignment for the style with which the receiver displays its text 
	so that the characters in each of text end on an even border in the 
	composition rectangle but the beginning of each line does not. This is 
	also known as ragged-left."

	textStyle alignment: RightFlush
]

{ #category : #private }
Paragraph >> rightMarginForComposition [
	"Build the right margin for a line. Depends upon compositionRectangle
	width, marginTabsLevel, and right indent."

	^compositionRectangle width 
		- (textStyle rightMarginTabAt: marginTabsLevel) 
		- textStyle rightIndent
]

{ #category : #private }
Paragraph >> rightMarginForDisplay [ 
	"Build the right margin for a line. Depends upon compositionRectangle
	rightSide, marginTabsLevel, and right indent."

	^compositionRectangle right - 
		textStyle rightIndent - (textStyle rightMarginTabAt: marginTabsLevel)
]

{ #category : #accessing }
Paragraph >> rule [ 
	"Answer the rule according to which character display behaves. For 
	example, rule may equal over, under, reverse."

	^rule
]

{ #category : #accessing }
Paragraph >> rule: ruleInteger [ 
	"Set the rule according to which character display behaves."

	rule := ruleInteger
]

{ #category : #scrolling }
Paragraph >> scrollBy: heightToMove [ 
	^ self scrollBy: heightToMove withSelectionFrom: nil to: nil
]

{ #category : #scrolling }
Paragraph >> scrollBy: heightToMove withSelectionFrom: startBlock to: stopBlock [ 
	"Translate the composition rectangle up (dy<0) by heightToMove.
	Repainting text as necessary, and selection if blocks not nil.
	Return true unless scrolling limits have been reached."
	| max min amount |
	max := 0 max: "cant scroll up more than dist to (top of) bottom line"
		compositionRectangle bottom - textStyle lineGrid - clippingRectangle top.
	min := 0 min: "cant scroll down more than top is above clipRect"
		compositionRectangle top - clippingRectangle top.
	amount := ((heightToMove truncateTo: textStyle lineGrid) min: max) max: min.
	amount ~= 0
		ifTrue: [destinationForm deferUpdatesIn: clippingRectangle while: [
					self scrollUncheckedBy: amount
						withSelectionFrom: startBlock to: stopBlock].
				^ true]
		ifFalse: [^ false]
]

{ #category : #scrolling }
Paragraph >> scrollDelta [
	"By comparing this before and after, you know if scrolling happened"
	^ clippingRectangle top - compositionRectangle top
]

{ #category : #scrolling }
Paragraph >> scrollUncheckedBy: heightToMove withSelectionFrom: startBlock to: stopBlock [ 
	"Scroll by the given amount.  Copy bits where possible, display the rest.
	If selection blocks are not nil, then select the newly visible text as well."
	| savedClippingRectangle delta |
	delta := 0 @ (0 - heightToMove).
	compositionRectangle := compositionRectangle translateBy: delta.
	startBlock == nil ifFalse:
		[startBlock moveBy: delta.
		stopBlock moveBy: delta].
	savedClippingRectangle := clippingRectangle.
	clippingRectangle := clippingRectangle intersect: Display boundingBox.
	heightToMove abs >= clippingRectangle height
	  ifTrue: 
		["Entire visible region must be repainted"
		self displayLines: (1 to: lastLine) affectedRectangle: clippingRectangle]
	  ifFalse:
		["Copy bits where possible / display the rest"
		destinationForm
			copyBits: clippingRectangle from: destinationForm
			at: clippingRectangle topLeft + delta
			clippingBox: clippingRectangle
			rule: Form over fillColor: nil.
		"Set clippingRectangle to 'vacated' area for lines 'pulled' into view."
		clippingRectangle := heightToMove < 0
			ifTrue:  "On the top"
				[clippingRectangle topLeft corner: clippingRectangle topRight + delta]
			ifFalse:  "At the bottom"
				[clippingRectangle bottomLeft + delta corner: clippingRectangle bottomRight].
		self displayLines: (1 to: lastLine)   "Refresh vacated region"
			affectedRectangle: clippingRectangle].
	startBlock == nil ifFalse:
		[self reverseFrom: startBlock to: stopBlock].
	"And restore the clippingRectangle to its original value. "
	clippingRectangle := savedClippingRectangle
]

{ #category : #selecting }
Paragraph >> selectionRectsFrom: characterBlock1 to: characterBlock2 [ 
	"Return an array of rectangles representing the area between the two character blocks given as arguments."
	| visibleRectangle initialRectangle interiorRectangle finalRectangle lineNo baseline |
	characterBlock1 = characterBlock2 ifTrue:
		[lineNo := self lineIndexOfCharacterIndex: characterBlock1 stringIndex.
		baseline := lineNo = 0 ifTrue: [textStyle baseline]
							ifFalse: [(lines at: lineNo) baseline].
		^ Array with: (characterBlock1 topLeft extent: 1 @ baseline)].
	visibleRectangle := clippingRectangle intersect: compositionRectangle.
	characterBlock1 top = characterBlock2 top
		ifTrue: [characterBlock1 left < characterBlock2 left
					ifTrue: 
						[initialRectangle := 
							(characterBlock1 topLeft corner: characterBlock2 bottomLeft)
								intersect: visibleRectangle]
					ifFalse: 
						[initialRectangle := 
							(characterBlock2 topLeft corner: characterBlock1 bottomLeft)
								intersect: visibleRectangle]]
		ifFalse: [characterBlock1 top < characterBlock2 top
					ifTrue: 
						[initialRectangle := 
							(characterBlock1 topLeft 
								corner: visibleRectangle right @ characterBlock1 bottom)
								intersect: visibleRectangle.
						characterBlock1 bottom = characterBlock2 top
							ifTrue: 
								[finalRectangle := 
									(visibleRectangle left @ characterBlock2 top 
										corner: characterBlock2 bottomLeft)
										intersect: visibleRectangle]
							ifFalse: 
								[interiorRectangle := 
									(visibleRectangle left @ characterBlock1 bottom
										corner: visibleRectangle right 
														@ characterBlock2 top)
										intersect: visibleRectangle.
								finalRectangle := 
									(visibleRectangle left @ characterBlock2 top 
										corner: characterBlock2 bottomLeft)
										intersect: visibleRectangle]]
				ifFalse: 
					[initialRectangle := 
						(visibleRectangle left @ characterBlock1 top 
							corner: characterBlock1 bottomLeft)
							intersect: visibleRectangle.
					characterBlock1 top = characterBlock2 bottom
						ifTrue: 
							[finalRectangle := 
								(characterBlock2 topLeft 
									corner: visibleRectangle right 
												@ characterBlock2 bottom)
									intersect: visibleRectangle]
						ifFalse: 
							[interiorRectangle := 
								(visibleRectangle left @ characterBlock2 bottom 
									corner: visibleRectangle right @ characterBlock1 top)
									intersect: visibleRectangle.
							finalRectangle := 
								(characterBlock2 topLeft 
									corner: visibleRectangle right 
												@ characterBlock2 bottom)
									intersect: visibleRectangle]]].
	^ (Array with: initialRectangle with: interiorRectangle with: finalRectangle)
			select: [:rect | rect notNil]
]

{ #category : #private }
Paragraph >> setWithText: aText style: aTextStyle [ 
	"Set text and adjust bounding rectangles to fit."

	| shrink compositionWidth unbounded |
	unbounded := Rectangle origin: 0 @ 0 extent: 9999@9999.
	compositionWidth := self
		setWithText: aText style: aTextStyle compositionRectangle: unbounded clippingRectangle: unbounded.
	compositionRectangle := compositionRectangle withWidth: compositionWidth.
	clippingRectangle := compositionRectangle copy.
	shrink := unbounded width - compositionWidth.
	"Shrink padding widths accordingly"
	1 to: lastLine do:
		[:i | (lines at: i) paddingWidth: (lines at: i) paddingWidth - shrink]
]

{ #category : #private }
Paragraph >> setWithText: aText style: aTextStyle compositionRectangle: compRect clippingRectangle: clipRect [ 
	"Set text and using supplied parameters. Answer max composition width."

	clippingRectangle := clipRect copy.
	^self
		compositionRectangle: compRect
		text: aText
		style: aTextStyle
		offset: 0 @ 0
]

{ #category : #private }
Paragraph >> setWithText: aText style: aTextStyle compositionRectangle: compRect clippingRectangle: clipRect foreColor: cf backColor: cb [
	"Set text and using supplied parameters. Answer max composition width."

	clippingRectangle := clipRect copy.
	self foregroundColor: cf backgroundColor: cb.
	^ self
		compositionRectangle: compRect
		text: aText
		style: aTextStyle
		offset: 0 @ 0
]

{ #category : #accessing }
Paragraph >> string [
	^text string
]

{ #category : #accessing }
Paragraph >> stringAtLineNumber: aNumber [
	(aNumber > lastLine or: [aNumber < 1]) ifTrue: [^ nil].
	^ (text string copyFrom: (lines at: aNumber) first to: (lines at: aNumber) last) copyWithoutAll: CharacterSet crlf
]

{ #category : #accessing }
Paragraph >> text: aText [ 
	"Set the argument, aText, to be the text for the receiver."

	text := aText.
	self composeAll
]

{ #category : #alignment }
Paragraph >> toggleAlignment [ 
	"Set the alignment for the style with which the receiver displays its text 
	so that it moves from centered to justified to leftFlush to rightFlush and 
	back to centered again."

	textStyle alignment: textStyle alignment + 1
]

{ #category : #private }
Paragraph >> topAtLineIndex: lineIndex [ 
	"Answer the top y of given line."
	| y |
	y := compositionRectangle top.
	lastLine = 0 ifTrue: [lineIndex > 0 ifTrue: [^ y + textStyle lineGrid]. ^ y].
	1 to: (lineIndex-1 min: lastLine) do:
		[:i | y := y + (lines at: i) lineHeight].
	^ y

]

{ #category : #private }
Paragraph >> topAtLineIndex: lineIndex using: otherLines and: otherLastLine [
	"Answer the top y of given line."
	| y |
	y := compositionRectangle top.
	otherLastLine = 0 ifTrue: [^ y].
	1 to: (lineIndex-1 min: otherLastLine) do:
		[:i | y := y + (otherLines at: i) lineHeight].
	^ y

]

{ #category : #private }
Paragraph >> trimLinesTo: lastLineInteger [

	(lastLineInteger + 1 to: lastLine) do: [:i | lines at: i put: nil].
	(lastLine := lastLineInteger) < (lines size // 2) 
		ifTrue: [lines := lines copyFrom: 1 to: lines size - (lines size // 2)]
]

{ #category : #private }
Paragraph >> updateCompositionHeight [
	"Mainly used to insure that intersections with compositionRectangle work." 

	compositionRectangle := compositionRectangle withHeight:
		(self bottomAtLineIndex: lastLine) - compositionRectangle top.
	(text size ~= 0 and: [(text at: text size) = CR or: [(text at: text size) = Character lf]])
		ifTrue: [compositionRectangle := compositionRectangle withHeight:
					compositionRectangle height + (lines at: lastLine) lineHeight]
]

{ #category : #utilities }
Paragraph >> visibleRectangle [ 
	"May be less than the clippingRectangle if text ends part way down.
	Also some fearful history includes Display intersection;
	it shouldn't be necessary"

	^ (clippingRectangle intersect: compositionRectangle)
		intersect: destinationForm boundingBox
]

{ #category : #private }
Paragraph >> withClippingRectangle: clipRect do: aBlock [
	| saveClip |
	saveClip := clippingRectangle.
	clippingRectangle := clipRect.
		aBlock value.
	clippingRectangle := saveClip
]

{ #category : #composition }
Paragraph >> wrappingBox: compositionRect clippingBox: clippingRect [ 
	"Set the composition rectangle for the receiver so that the lines wrap 
	within the rectangle, compositionRect, and the display of the text is 
	clipped by the rectangle, clippingRect."

	self compositionRectangle: compositionRect copy
				text: text
				style: textStyle
				offset: offset.
	clippingRectangle := clippingRect copy
]
