"
A Paragraph represents text that has been laid out, or composed, in some container.
	text 		A Text with encoded per-character emphasis.
	textStyle	A TextStyle with font set, line height and horizontal alignment.
	firstCharacterIndex    The starting index in text for this paragraph, allowing
				composition of a long text into a number of containers.
	container	A Rectangle or TextContainer that determines where text can go.
	lines		An Array of TextLines comprising the final layout of the text
				after it has been composed within its container.
	positionWhenComposed   As its name implies.  Allows display at new locations
				without the need to recompose the text.
Lines are ordered vertically.  However, for a given y, there may be several lines in left to right order.  Lines must never be empty, even if text is empty.

Notes on yet another hack - 5 Feb 2001

We really need to clean up #composeLinesFrom:to:delta:into:priorLines:atY:!!!

I added one more habdful of code to correct:

This is an annoying bug that's been around for a couple of years, but I finally figured out how to duplicate the problem, so I figured I'd just report it now.  (It doesn't necessarily have to be fixed for 3.0 if it looks messy, but if it's a simple fix, it would be worth it.)

In Morphic, if you have the following text in a workspace:

This is line 1
This is line 2

**and** you have a return character after line 2, you will normally be able to click the mouse two times below line 2 in order to select all the text.  If you edit line 2 (e.g. so that it reads ""line number 2""), you can still select all the text by clicking below the second line.  However, if you edit line 1, you will not be able to select all the text from the bottom in the same way.  Things get messed up such that the last return character seems to be gone.  In this state, if you position the cursor immediately after the 2, and press the right arrow, the cursor jumps to the beginning of line 2... oof. (report by Doug Way)

While I don't have a very deep understanding of the above mentioned method, I was able to determine that text ending in a CR worked better in the editor when the last entry in <lines> had a start of text size + 1 and a stop of text size. I have accordingly added code near the end to ensure this. It seems to have fixed the problem, but we do need to clean this baby up some day. - Bob

"
Class {
	#name : #NewParagraph,
	#superclass : #Object,
	#instVars : [
		'text',
		'textStyle',
		'firstCharacterIndex',
		'container',
		'lines',
		'positionWhenComposed',
		'offsetToEnd',
		'maxRightX',
		'selectionStart',
		'selectionStop',
		'wantsColumnBreaks',
		'focused',
		'caretRect',
		'showCaret',
		'caretColor',
		'selectionColor',
		'unfocusedSelectionColor'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #private }
NewParagraph >> adjustLineIndicesBy: delta [
	firstCharacterIndex := firstCharacterIndex + delta.
	lines do: [:line | line slide: delta].

]

{ #category : #private }
NewParagraph >> adjustRightX [
	| shrink |
	shrink := container right - maxRightX.
	lines do: [:line | line paddingWidth: (line paddingWidth - shrink)].
	container := container withRight: maxRightX + self caretWidth.
]

{ #category : #access }
NewParagraph >> adjustedFirstCharacterIndex [
	"Return the index in the text where this paragraph WOULD begin if nothing had changed, except the size of the text -- ie if there have only been an insertion of deletion in the preceding morphs"
	offsetToEnd ifNil: [^ -1].
	^ text size - offsetToEnd
]

{ #category : #display }
NewParagraph >> asParagraphForPostscript [

	^ self
]

{ #category : #editing }
NewParagraph >> attributesAt: aPoint [
	"Answer the attributes at the given point"
	^text attributesAt: (self characterBlockAtPoint: aPoint) stringIndex forStyle: textStyle
]

{ #category : #access }
NewParagraph >> caretColor [
	^ caretColor ifNil: [Color red]
]

{ #category : #access }
NewParagraph >> caretColor: aColor [
	caretColor := aColor.
]

{ #category : #access }
NewParagraph >> caretRect [
	"The rectangle in which the caret was last drawn,
	 or nil if the last drawing drew a range-selection rather than insertion point."
	^ caretRect
]

{ #category : #access }
NewParagraph >> caretWidth [
	^ Editor dumbbellCursor
		ifTrue: [ 3 ]
		ifFalse: [ 2 ]
]

{ #category : #alignment }
NewParagraph >> centered [ 
	textStyle centered
]

{ #category : #selection }
NewParagraph >> characterBlockAtPoint: aPoint [ 
	"Answer a CharacterBlock for the character in the text at aPoint."
	| line |
	line := lines at: (self lineIndexForPoint: aPoint).
	^(CharacterBlockScanner new text: text textStyle: textStyle)
		characterBlockAtPoint: aPoint index: nil
		in: line
]

{ #category : #selection }
NewParagraph >> characterBlockForIndex: index [ 
	"Answer a CharacterBlock for the character in text at index."
	| line |
	line := lines at: (self lineIndexOfCharacterIndex: index).
	^ (CharacterBlockScanner new text: text textStyle: textStyle)
		characterBlockAtPoint: nil index: ((index max: line first) min: text size+1)
		in: line
]

{ #category : #editing }
NewParagraph >> clickAt: clickPoint for: model controller: editor [
	"Give sensitive text a chance to fire.  Display flash: (100@100 extent: 100@100)."
	| startBlock action |
	action := false.
	startBlock := self characterBlockAtPoint: clickPoint.
	(text attributesAt: startBlock stringIndex forStyle: textStyle) 
		do: [:att | | range target box boxes |
			att mayActOnClick ifTrue:
				[(target := model) ifNil: [target := editor morph].
				range := text rangeOf: att startingAt: startBlock stringIndex.
				boxes := self selectionRectsFrom: (self characterBlockForIndex: range first) 
							to: (self characterBlockForIndex: range last+1).
				box := boxes detect: [:each | each containsPoint: clickPoint] ifNone: [nil].
				box ifNotNil:
					[ box := (editor transformFrom: nil) invertBoundsRect: box.
					editor morph allOwnersDo: [ :m | box := box intersect: (m boundsInWorld) ].
					self flag: #fix. "mt: Make it stateful and with real events."
					Utilities awaitMouseUpIn: box
						repeating: []
						ifSucceed: [(att actOnClickFor: target in: self at: clickPoint editor: editor) ifTrue: [action := true]].
					Cursor currentCursor == Cursor webLink ifTrue:[Cursor normal show].
				]]].
	^ action
]

{ #category : #composition }
NewParagraph >> compose: t style: ts from: startingIndex in: textContainer [
	text := t.
	textStyle := ts.
	firstCharacterIndex := startingIndex.
	offsetToEnd := text size - firstCharacterIndex.
	container := textContainer.
	self composeAll
]

{ #category : #composition }
NewParagraph >> composeAll [
	self composeLinesFrom: firstCharacterIndex to: text size delta: 0
			into: OrderedCollection new priorLines: Array new atY: container top
]

{ #category : #composition }
NewParagraph >> composeAllStartingAt: characterIndex [
	firstCharacterIndex := characterIndex.
	offsetToEnd := text size - firstCharacterIndex.
	self composeAll
]

{ #category : #composition }
NewParagraph >> composeLinesFrom: start to: stop delta: delta into: lineColl priorLines: priorLines
	atY: startingY [
	"While the section from start to stop has changed, composition may ripple all the way to the end of the text.  However in a rectangular container, if we ever find a line beginning with the same character as before (ie corresponding to delta in the old lines), then we can just copy the old lines from there to the end of the container, with adjusted indices and y-values"

	| newResult |

	newResult := TextComposer new
		composeLinesFrom: start 
		to: stop 
		delta: delta 
		into: lineColl 
		priorLines: priorLines
		atY: startingY
		textStyle: textStyle 
		text: text 
		container: container
		wantsColumnBreaks: wantsColumnBreaks == true.
	lines := newResult first asArray.
	maxRightX := newResult second.
	^maxRightX

]

{ #category : #composition }
NewParagraph >> compositionRectangle [
	^ container
]

{ #category : #selection }
NewParagraph >> containsPoint: aPoint [
	^ (lines at: (self lineIndexForPoint: aPoint)) rectangle
		containsPoint: aPoint
]

{ #category : #copying }
NewParagraph >> deepCopy [
	"Don't want to copy the container (etc) or fonts in the TextStyle."
	| new |
	new := self copy.
	new textStyle: textStyle copy
		lines: lines copy
		text: text deepCopy.
	^ new
]

{ #category : #selection }
NewParagraph >> defaultCharacterBlock [
	^ (CharacterBlock new stringIndex: firstCharacterIndex text: text
			topLeft: lines first topLeft extent: 0 @ 0)
		textLine: lines first
]

{ #category : #display }
NewParagraph >> displayDumbbellCursorOn: aCanvas at: leftX in: line [

	| w |
	w := 2.
	self focused ifFalse: [^ w].
	
	1 to: w
		do: 
			[:i | 
			"Draw caret triangles at top and bottom"

			aCanvas fillRectangle: ((leftX - w + i - 1) @ (line top + i - 1) 
						extent: ((w - i) * 2 + 3) @ 1)
				color: self caretColor.
			aCanvas fillRectangle: ((leftX - w + i - 1) @ (line bottom - i) 
						extent: ((w - i) * 2 + 3) @ 1)
				color: self caretColor].
	
	aCanvas
		line: leftX @ line top
		to: leftX @ (line bottom-1)
		color: self caretColor.
	
	^ w
]

{ #category : #'fonts-display' }
NewParagraph >> displayOn: aCanvas using: displayScanner at: somePosition [
	"Send all visible lines to the displayScanner for display"
	| visibleRectangle offset leftInRun line |
	visibleRectangle := aCanvas clipRect.
	offset := (somePosition - positionWhenComposed) truncated.
	leftInRun := 0.
	(self lineIndexForPoint: visibleRectangle topLeft)
		to: (self lineIndexForPoint: visibleRectangle bottomRight)
		do: [:i | line := lines at: i.
			self displaySelectionInLine: line on: aCanvas.
			line first <= line last ifTrue:
				[leftInRun := displayScanner displayLine: line
								offset: offset leftInRun: leftInRun]].

]

{ #category : #display }
NewParagraph >> displaySelectionInLine: line on: aCanvas [ 
	| leftX rightX w |
	selectionStart ifNil: [^self].	"No selection"
	aCanvas isShadowDrawing ifTrue: [ ^self ].	"don't draw selection with shadow"
	selectionStart = selectionStop 
		ifTrue: 
			["Only show caret on line where clicked"

			selectionStart textLine ~= line ifTrue: [^self]]
		ifFalse:
			["Test entire selection before or after here"

			(selectionStop stringIndex < line first 
				or: [selectionStart stringIndex > (line last + 1)]) ifTrue: [^self].	"No selection on this line"
			(selectionStop stringIndex = line first 
				and: [selectionStop textLine ~= line]) ifTrue: [^self].	"Selection ends on line above"
			(selectionStart stringIndex = (line last + 1) 
				and: [selectionStop textLine ~= line]) ifTrue: [^self]].	"Selection begins on line below"
	leftX := (selectionStart stringIndex <= line first 
				ifTrue: [line ]
				ifFalse: [selectionStart ])left.
	rightX := (selectionStop stringIndex > (line last + 1) or: 
					[selectionStop stringIndex = (line last + 1) 
						and: [selectionStop textLine ~= line]]) 
				ifTrue: [line right]
				ifFalse: [selectionStop left].
	selectionStart = selectionStop 
		ifTrue: [
			rightX := rightX + 1.
			caretRect := (leftX-2) @ line top corner: (rightX+2)@ line bottom. "sigh..."
			self showCaret ifFalse: [^self].
			w := (Editor dumbbellCursor
				ifTrue: [self displayDumbbellCursorOn: aCanvas at: leftX in: line]
				ifFalse: [self displaySimpleCursorOn: aCanvas at: leftX in: line]).
			caretRect := (leftX-w) @ line top corner: (rightX+w)@ line bottom]
		ifFalse: [
			caretRect := nil.
			aCanvas fillRectangle: (leftX @ line top corner: rightX @ line bottom)
				color: (self focused ifTrue: [self selectionColor] ifFalse: [self unfocusedSelectionColor])]
]

{ #category : #display }
NewParagraph >> displaySimpleCursorOn: aCanvas at: leftX in: line [

	self focused ifFalse: [^ 1].
	
	aCanvas
		line: leftX @ (line top+1)
		to: leftX @ (line bottom-1)
		color: self caretColor.

	aCanvas
		line: leftX+1 @ (line top+1)
		to: leftX+1 @ (line bottom-1)
		color: (self caretColor alpha: 0.3).
	
	^ 1
]

{ #category : #access }
NewParagraph >> extent [
	^ container width @ (lines last bottom - lines first top)
]

{ #category : #private }
NewParagraph >> fastFindFirstLineSuchThat: lineBlock [
	"Perform a binary search of the lines array and return the index
	of the first element for which lineBlock evaluates as true.
	This assumes the condition is one that goes from false to true for
	increasing line numbers (as, eg, yval > somey or start char > somex).
	If lineBlock is not true for any element, return size+1."
	
	^lines
		findBinaryIndex: [ :each | 
			(lineBlock value: each)
				ifTrue: [ -1 ]
				ifFalse: [ 1 ] ]
		ifNone: [ :lower :upper | upper ]
]

{ #category : #access }
NewParagraph >> firstCharacterIndex [
	^ firstCharacterIndex
]

{ #category : #composition }
NewParagraph >> fixLastWithHeight: lineHeightGuess [
"This awful bit is to ensure that if we have scanned all the text and the last character is a CR that there is a null line at the end of lines. Sometimes this was not happening which caused anomalous selections when selecting all the text. This is implemented as a post-composition fixup because I coul;dn't figure out where to put it in the main logic."

	| oldLastLine newRectangle line |

	(text size > 1 and: [text last = Character cr]) ifFalse: [^self].

	oldLastLine := lines last.
	oldLastLine last - oldLastLine first >= 0 ifFalse: [^self].
	oldLastLine last = text size ifFalse: [^self].

	newRectangle := oldLastLine left @ oldLastLine bottom 
				extent: 0@(oldLastLine bottom - oldLastLine top).
	"Even though we may be below the bottom of the container,
	it is still necessary to compose the last line for consistency..."

	line := TextLine start: text size+1 stop: text size internalSpaces: 0 paddingWidth: 0.
	line rectangle: newRectangle.
	line lineHeight: lineHeightGuess baseline: textStyle baseline.
	lines := lines, (Array with: line).

]

{ #category : #access }
NewParagraph >> focused [
	focused ifNil: [focused := false].
	^ focused
]

{ #category : #access }
NewParagraph >> focused: aBoolean [
	focused := aBoolean
]

{ #category : #private }
NewParagraph >> indentationOfLineIndex: lineIndex ifBlank: aBlock [
	"Answer the number of leading tabs in the line at lineIndex.  If there are
	 no visible characters, pass the number of tabs to aBlock and return its value.
	 If the line is word-wrap overflow, back up a line and recur."

	| arrayIndex first last crlf |
	crlf := CharacterSet crlf.
	arrayIndex := lineIndex.
	[first := (lines at: arrayIndex) first.
	 first > 1 and: [crlf includes: (text string at: first - 1)]] whileTrue: "word wrap"
		[arrayIndex := arrayIndex - 1].
	last := (lines at: arrayIndex) last.
	
	^(text string copyFrom: first to: last) indentationIfBlank: aBlock.

]

{ #category : #'initialize-release' }
NewParagraph >> initialize [
	self positionWhenComposed: 0 @ 0
]

{ #category : #alignment }
NewParagraph >> justified [ 
	textStyle justified
]

{ #category : #access }
NewParagraph >> lastCharacterIndex [
	^ lines last last
]

{ #category : #private }
NewParagraph >> lastLine [

	^lines last
]

{ #category : #alignment }
NewParagraph >> leftFlush [ 
	textStyle leftFlush
]

{ #category : #private }
NewParagraph >> lineIndexForCharacter: characterIndex [
	"Deprecated"
	
	^self lineIndexOfCharacterIndex: characterIndex 
]

{ #category : #private }
NewParagraph >> lineIndexForPoint: aPoint [
	"Answer the index of the line in which to select the character nearest to aPoint."
	| i py |
	py := aPoint y truncated.

	"Find the first line at this y-value"
	i := (self fastFindFirstLineSuchThat: [:line | line bottom > py]) min: lines size.

	"Now find the first line at this x-value"
	[i < lines size and: [(lines at: i+1) top = (lines at: i) top
				and: [aPoint x >= (lines at: i+1) left]]]
		whileTrue: [i := i + 1].
	^ i
]

{ #category : #private }
NewParagraph >> lineIndexOfCharacterIndex: index [
	"Answer the index of the line in which to select the character at index."
	^ (self fastFindFirstLineSuchThat: [:line | line first > index]) - 1 max: 1
]

{ #category : #private }
NewParagraph >> lines [
	^ lines
]

{ #category : #private }
NewParagraph >> moveBy: delta [
	lines do: [:line | line moveBy: delta].
	positionWhenComposed ifNotNil:[
	positionWhenComposed := positionWhenComposed + delta].
	container := container translateBy: delta
]

{ #category : #access }
NewParagraph >> numberOfLines [

	^lines size
]

{ #category : #private }
NewParagraph >> positionWhenComposed: pos [
	positionWhenComposed := pos
]

{ #category : #composition }
NewParagraph >> recomposeFrom: start to: stop delta: delta [
	"Recompose this paragraph.  The altered portion is between start and stop.
	Recomposition may continue to the end of the text, due to a ripple effect.
	Delta is the amount by which the current text is longer than it was
	when its current lines were composed."
	| startLine newLines |
	"Have to recompose line above in case a word-break was affected."
	startLine := (self lineIndexOfCharacterIndex: start) - 1 max: 1.
	[startLine > 1 and: [(lines at: startLine-1) top = (lines at: startLine) top]]
		whileTrue: [startLine := startLine - 1].  "Find leftmost of line pieces"
	newLines := OrderedCollection new: lines size + 1.
	1 to: startLine-1 do: [:i | newLines addLast: (lines at: i)].
	self composeLinesFrom: (lines at: startLine) first to: stop delta: delta
			into: newLines priorLines: lines
			atY: (lines at: startLine) top
]

{ #category : #editing }
NewParagraph >> replaceFrom: start to: stop with: aText [
	"Edit the text, and then recompose the lines." 
	text replaceFrom: start to: stop with: aText.
	self recomposeFrom: start to: start + aText size - 1 delta: aText size - (stop-start+1)
]

{ #category : #editing }
NewParagraph >> replaceFrom: start to: stop with: aText displaying: displayBoolean [ 
	"Edit the text, and then recompose the lines." 
	text replaceFrom: start to: stop with: aText.
	self recomposeFrom: start to: start + aText size - 1 delta: aText size - (stop-start+1)
]

{ #category : #alignment }
NewParagraph >> rightFlush [ 
	textStyle rightFlush
]

{ #category : #access }
NewParagraph >> selectionColor [
	^ selectionColor ifNil: [Color blue muchLighter]
]

{ #category : #access }
NewParagraph >> selectionColor: aColor [
	selectionColor := aColor.
]

{ #category : #selection }
NewParagraph >> selectionRects [
	"Return an array of rectangles representing the selection region."
	selectionStart ifNil: [^ Array new].
	^ self selectionRectsFrom: selectionStart to: selectionStop
]

{ #category : #selection }
NewParagraph >> selectionRectsFrom: characterBlock1 to: characterBlock2 [ 
	"Return an array of rectangles representing the area between the two character blocks given as arguments."
	| line1 line2 rects cb1 cb2 w |
	characterBlock1 <= characterBlock2
		ifTrue: [cb1 := characterBlock1.  cb2 := characterBlock2]
		ifFalse: [cb2 := characterBlock1.  cb1 := characterBlock2].
	cb1 = cb2 ifTrue:
		[w := self caretWidth.
		^ Array with: (cb1 topLeft - (w@0) corner: cb1 bottomLeft + ((w+1)@0))].
	line1 := self lineIndexOfCharacterIndex: cb1 stringIndex.
	line2 := self lineIndexOfCharacterIndex: cb2 stringIndex.
	cb1 top = (lines at: line1) top
		ifFalse:
			["a word did not fit on prev line - start selection on prev line"
			line1 := line1 - 1 max: 1].
	line1 = line2 ifTrue:
		[^ Array with: (cb1 topLeft corner: cb2 bottomRight)].
	rects := OrderedCollection new.
	rects addLast: (cb1 topLeft corner: (lines at: line1) bottomRight).
	line1+1 to: line2-1 do: [ :i |
		| line |
		line := lines at: i.
		(line left = rects last left and: [ line right = rects last right ])
			ifTrue: [ "new line has same margins as old one -- merge them, so that the caller gets as few rectangles as possible"
					| lastRect |
					lastRect := rects removeLast.
					rects add: (lastRect bottom: line bottom) ]
			ifFalse: [ "differing margins; cannot merge"
					rects add: line rectangle ] ].

	rects addLast: ((lines at: line2) topLeft corner: cb2 bottomLeft).
	^ rects
]

{ #category : #selection }
NewParagraph >> selectionStart: startBlock selectionStop: stopBlock [
	selectionStart := startBlock.
	selectionStop := stopBlock.
]

{ #category : #access }
NewParagraph >> showCaret [
	^showCaret ifNil:[true]

]

{ #category : #access }
NewParagraph >> showCaret: aBool [
	showCaret := aBool

]

{ #category : #access }
NewParagraph >> string [
	^ text string
]

{ #category : #access }
NewParagraph >> text [
	^ text
]

{ #category : #access }
NewParagraph >> textOwner: ignored [  "See TextOnCurve"
]

{ #category : #access }
NewParagraph >> textStyle [
	^ textStyle
]

{ #category : #access }
NewParagraph >> textStyle: aTextStyle [ 
	"Set the style by which the receiver should display its text."
	textStyle := aTextStyle
]

{ #category : #private }
NewParagraph >> textStyle: ts lines: l text: t [
	"Private -- just a service for deepCopy"
	textStyle := ts.
	lines := l.
	text := t.
]

{ #category : #access }
NewParagraph >> unfocusedSelectionColor [
	^ unfocusedSelectionColor ifNil: [Color gray: 0.9]
]

{ #category : #access }
NewParagraph >> unfocusedSelectionColor: aColor [
	unfocusedSelectionColor := aColor.
]

{ #category : #access }
NewParagraph >> wantsColumnBreaks [

	^wantsColumnBreaks
]

{ #category : #access }
NewParagraph >> wantsColumnBreaks: aBoolean [

	wantsColumnBreaks := aBoolean
]
