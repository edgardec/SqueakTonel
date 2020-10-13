"
New text editors.
TextEditor provides most of the functionality that used to be in TextMorphEditor.
SmalltalkEditor is has Smalltalk code specific features.

"
Class {
	#name : #Editor,
	#superclass : #Object,
	#instVars : [
		'morph'
	],
	#classVars : [
		'BlinkingCursor',
		'DestructiveBackWord',
		'DumbbellCursor',
		'KeystrokeActions',
		'SelectionsMayShrink'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #preferences }
Editor class >> blinkingCursor [
	<preference: 'Blinking Text Cursor'
		category: 'Morphic'
		description: 'When true, the text cursor will blink.'
		type: #Boolean>
	^ BlinkingCursor ifNil: [ true ]
]

{ #category : #preferences }
Editor class >> blinkingCursor: aBoolean [
	BlinkingCursor := aBoolean
]

{ #category : #'class initialization' }
Editor class >> cleanUp: aggressive [

	aggressive ifTrue: [self initialize].
]

{ #category : #preferences }
Editor class >> destructiveBackWord [
	<preference: 'Destructive Back-Word'
		category: 'Morphic'
		description: 'Indicates whether the back-word command deletes, or merely selects, the prior word.'
		type: #Boolean>
	^ DestructiveBackWord ifNil: [ true ]
]

{ #category : #preferences }
Editor class >> destructiveBackWord: aBoolean [
	DestructiveBackWord := aBoolean
]

{ #category : #preferences }
Editor class >> dumbbellCursor [
	<preference: 'Dumbbell Text Cursor'
		category: 'Morphic'
		description: 'When enabled, the text cursor assumes the shape of a dumbbell, otherwise a vertical bar.'
		type: #Boolean>
	^ DumbbellCursor ifNil: [ false ]
]

{ #category : #preferences }
Editor class >> dumbbellCursor: aBoolean [
	DumbbellCursor := aBoolean
]

{ #category : #'class initialization' }
Editor class >> initialize [
	"
	Editor initialize
	"
	self initializeKeystrokeActions.
	self allSubclassesDo: [ :c | c initialize ]
]

{ #category : #'class initialization' }
Editor class >> initializeKeystrokeActions [
	"Initialize the table for regular (i.e. non-command) keystroke dispatch"
	"
	self initializeKeystrokeActions
	"
	| actions |
	actions := Array new: 256 withAll: #normalCharacter:.
	0 to: 31 do: [ :i | actions at: i+1 put: #noop: ].
	actions at: 1 + 1 put: #cursorHome:.				"home key"
	actions at: 3 + 1 put: #enter:.						"enter / return key"
	actions at: 4 + 1 put: #cursorEnd:.				"end key"
	actions at: 5 + 1 put: #noop:.						"insert key"
	actions at: 8 + 1 put: #backspace:.				"macDelete winBackspace key"
	actions at: 9 + 1 put: #normalCharacter:.		"tab"
	actions at: 11 + 1 put: #cursorPageUp:.			"page up key"
	actions at: 12 + 1 put: #cursorPageDown:.		"page down key"
	actions at: 13 + 1 put: #enter:.					"enter / return key"
	actions at: 27 + 1 put: #offerMenuFromEsc:.	"escape key"
	actions at: 28 + 1 put: #cursorLeft:.				"left arrow key"
	actions at: 29 + 1 put: #cursorRight:.				"right arrow key"
	actions at: 30 + 1 put: #cursorUp:.				"up arrow key"
	actions at: 31 + 1 put: #cursorDown:.			"down arrow key"
	actions at: 127 + 1 put: #forwardDelete:.		"winDelete key"
	KeystrokeActions := actions
]

{ #category : #preferences }
Editor class >> selectionsMayShrink [
	<preference: 'Selections may shrink'
		category: 'Morphic'
		description: 'When true, allows selection to shrink when using shift+cursor keys'
		type: #Boolean>
	^SelectionsMayShrink ifNil:[true]
]

{ #category : #preferences }
Editor class >> selectionsMayShrink: aBoolean [
	SelectionsMayShrink := aBoolean
]

{ #category : #'keyboard shortcut tables' }
Editor class >> specialShiftCmdKeys [

"Private - return array of key codes that represent single keys acting
as if shift-command were also being pressed"

^#(
	1	"home"
	3	"enter"
	4	"end"
	5	"insert"
	8	"backspace"
	11	"page up"
	12	"page down"
	27	"escape"
	28	"left arrow"
	29	"right arrow"
	30	"up arrow"
	31	"down arrow"
	127	"delete"
	)
]

{ #category : #'typing\/selecting keys' }
Editor >> backWord: aKeyboardEvent [ 
	^ self class destructiveBackWord 
		ifTrue: [ self destructiveBackWord: aKeyboardEvent ]
		ifFalse: [ self nonDestructiveBackWord: aKeyboardEvent ]
]

{ #category : #'typing\/selecting keys' }
Editor >> backspace: aKeyboardEvent [ 
	"Backspace over the last character."

	| startIndex |
	aKeyboardEvent shiftPressed ifTrue: [^ self backWord: aKeyboardEvent].
	startIndex := self markIndex +
				(self hasCaret ifTrue: [0] ifFalse: [1]).
	startIndex := 1 max: startIndex - 1.

	^ self backTo: startIndex
]

{ #category : #private }
Editor >> beginningOfLine: position [
	"Redefined in subclasses using Paragraph support"
	^ self beginningOfParagraph: position
]

{ #category : #private }
Editor >> beginningOfNextParagraph: position [
	| s |
	s := self string.
	^ (s
		indexOf: Character cr
		startingAt: position
		ifAbsent: [ s size ]) + 1
]

{ #category : #private }
Editor >> beginningOfParagraph: position [
	^ (self string
		lastIndexOf: Character cr
		startingAt: position) + 1.
]

{ #category : #private }
Editor >> beginningOfText [
	^1
]

{ #category : #'typing\/selecting keys' }
Editor >> clearSelection [

	self selectFrom: 1 to: 0
]

{ #category : #'menu messages' }
Editor >> clipboardText [

	^ Clipboard clipboardText
]

{ #category : #'menu messages' }
Editor >> clipboardTextPut: text [

	^ Clipboard clipboardText: text
]

{ #category : #'editing keys' }
Editor >> copySelection: aKeyboardEvent [
	"Copy the current text selection."

	self copySelection.
	^true
]

{ #category : #'typing\/selecting keys' }
Editor >> cr: aKeyboardEvent [
	"Append a carriage return character to the stream of characters."

	self addString: Character cr asString.
	^false
]

{ #category : #'typing\/selecting keys' }
Editor >> crWithIndent: aKeyboardEvent [

	"Only for SmalltalkEditor. Regular editors don't indent"
	^ self cr: aKeyboardEvent
]

{ #category : #'typing\/selecting keys' }
Editor >> crlf: aKeyboardEvent [
	"Append a line feed character to the stream of characters."

	self addString: String crlf.
	^false
]

{ #category : #'nonediting\/nontyping keys' }
Editor >> cursorDown: aKeyboardEvent [
	"Private - Move cursor from position in current line to same position in
	next line. If next line too short, put at end. If shift key down,
	select."
	self insertAndCloseTypeIn.
	self 
		moveCursor: [:position | self
				sameColumn: position
				newLine: [:line | line + 1]
				forward: true]
		forward: true
		event: aKeyboardEvent
		specialBlock: [:dummy | dummy].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
Editor >> cursorLeft: aKeyboardEvent [
	"Private - Move cursor left one character if nothing selected, otherwise 
	move cursor to beginning of selection. If the shift key is down, start 
	selecting or extending current selection. Don't allow cursor past 
	beginning of text"

	self insertAndCloseTypeIn.
	self
		moveCursor:[:position | position - 1 max: 1]
		forward: false
		event: aKeyboardEvent
		specialBlock:[:position | self previousWord: position].
	^ true
]

{ #category : #'nonediting\/nontyping keys' }
Editor >> cursorPageDown: aKeyboardEvent [

	self insertAndCloseTypeIn.
	self 
		moveCursor: [:position |
			self
				sameColumn: position
				newLine: [:lineNo | lineNo + self pageHeight]
				forward: true]
		forward: true
		event: aKeyboardEvent
		specialBlock:[:dummy | dummy].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
Editor >> cursorPageUp: aKeyboardEvent [ 

	self insertAndCloseTypeIn.
	self 
		moveCursor: [:position |
			self
				sameColumn: position
				newLine: [:lineNo | lineNo - self pageHeight]
				forward: false]
		forward: false
		event: aKeyboardEvent
		specialBlock:[:dummy | dummy].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
Editor >> cursorRight: aKeyboardEvent [ 
	"Private - Move cursor right one character if nothing selected, 
	otherwise move cursor to end of selection. If the shift key is down, 
	start selecting characters or extending already selected characters. 
	Don't allow cursor past end of text"

	self insertAndCloseTypeIn.
	self
		moveCursor: [:position | position + 1]
		forward: true
		event: aKeyboardEvent
		specialBlock:[:position | self nextWord: position].
	^ true
]

{ #category : #'typing\/selecting keys' }
Editor >> cursorTopHome: aKeyboardEvent [
	"Put cursor at beginning of text -- invoked from cmd-H shortcut, useful for keyboards that have no home key."

	self selectAt: 1.
	^ true
]

{ #category : #'nonediting\/nontyping keys' }
Editor >> cursorUp: aKeyboardEvent [ 
	"Private - Move cursor from position in current line to same position in
	prior line. If prior line too short, put at end"

	self insertAndCloseTypeIn.
	self
		moveCursor: [:position | self
				sameColumn: position
				newLine:[:line | line - 1]
				forward: false]
		forward: false
		event: aKeyboardEvent
		specialBlock:[:dummy | dummy].
	^true
]

{ #category : #'editing keys' }
Editor >> cut: aKeyboardEvent [ 
	"Cut out the current text selection."

	self cut.
	^true
]

{ #category : #'typing\/selecting keys' }
Editor >> destructiveBackWord [
	"If the selection is not a caret, delete it and leave it in the backspace buffer.
	 Else if there is typeahead, delete it.
	 Else, delete the word before the caret."

	| startIndex |
	self hasCaret
		ifTrue: "a caret, delete at least one character"
			[startIndex := 1 max: self markIndex - 1.
			[startIndex > 1 and:
				[(self string at: startIndex - 1) tokenish]]
				whileTrue:
					[startIndex := startIndex - 1]]
		ifFalse: "a non-caret, just delete it"
			[startIndex := self markIndex].
	self backTo: startIndex.
	^ false
]

{ #category : #'typing\/selecting keys' }
Editor >> destructiveBackWord: aKeyboardEvent [ 
	
	^ self destructiveBackWord
]

{ #category : #private }
Editor >> endOfLine: position [
	"Redefined in subclasses using Paragraph support"
	^self endOfParagraph: position
]

{ #category : #private }
Editor >> endOfParagraph: position [
	| s |
	s := self string.
	^ s
		indexOf: Character cr
		startingAt: position
		ifAbsent: [ s size + 1 ].
]

{ #category : #private }
Editor >> endOfText [
	^self string size + 1
]

{ #category : #'typing\/selecting keys' }
Editor >> enter: aKeyboardEvent [
	"Enter / return key was pressed"
	"Process the various Enter / Return keystrokes"
	
	morph acceptOnCR ifTrue: [
		self closeTypeIn.
		^ true].

	aKeyboardEvent controlKeyPressed ifTrue: [
		^ self cr: aKeyboardEvent ].
	aKeyboardEvent shiftPressed ifTrue: [
		^ self lf: aKeyboardEvent ].
	aKeyboardEvent commandAltKeyPressed ifTrue: [
		^ self crlf: aKeyboardEvent ].
	^ self crWithIndent: aKeyboardEvent
]

{ #category : #private }
Editor >> firstWordBoundaryAfter: position [
	"If the character at position is whitespace, answer the position of the first character after position which is not whitespace.
	If the character at position is not whitespace, answer the position of the first character after position which is whitespace."
	| string index atWhitespace |
	string := self string.
	index := position.
	(atWhitespace := (string at: index) isSeparator)
		ifTrue:
			[ "find next non-separator"
			[ (index <= string size) and: [ (string at: index) isSeparator ] ] whileTrue: [ index := index + 1 ] ]
		ifFalse:
			[ "find next separator"
			[ (index <= string size) and: [ (string at: index) isSeparator not ] ] whileTrue: [ index := index + 1 ] ].
	^ index
]

{ #category : #'accessing-selection' }
Editor >> hasSelection [
	^self hasCaret not
]

{ #category : #'typing\/selecting keys' }
Editor >> lf: aKeyboardEvent [ 
	"Append a line feed character to the stream of characters."

	self addString: Character lf asString.
	^false
]

{ #category : #'menu messages' }
Editor >> lineSelectAndEmptyCheck: returnBlock [
	"If the current selection is an insertion point, expand it to be the entire current line; if after that's done the selection is still empty, then evaluate the returnBlock, which will typically consist of '[^ self]' in the caller -- check senders of this method to understand this."

	self hasSelection ifFalse: [
		self selectLine.
		self hasSelection ifFalse: [
			morph flash. 
			^ returnBlock value]].
]

{ #category : #private }
Editor >> lines [
	"Compute lines based on logical line breaks, not optical (which may change due to line wrapping of the editor).
	Subclasses using kinds of Paragraphs can instead use the service provided by it."
	| lines string lineIndex |
	string := self string.
	"Empty strings have no lines at all. Think of something."
	string isEmpty ifTrue:[^{#(1 0 0)}].
	lines := OrderedCollection new: (string size // 15).
	lineIndex := 0.
	string lineIndicesDo: [:start :endWithoutDelimiters :end |
		lines addLast: {start. (lineIndex := lineIndex + 1). end}].
	"Special workaround for last line empty."
	(string last == Character cr or: [string last == Character lf])
		ifTrue: [lines addLast: {string size + 1. lineIndex + 1. string size}].
	^lines
]

{ #category : #accessing }
Editor >> morph [
	^ morph
]

{ #category : #accessing }
Editor >> morph: aMorph [
	"Install a link back to the morph being edited (esp for text links)"
	morph := aMorph 
]

{ #category : #private }
Editor >> moveCursor: directionBlock forward: forward event: aKeyboardEvent specialBlock: specialBlock [ 
	"Private - Move cursor.
	directionBlock is a one argument Block that computes the new Position from a given one.
	specialBlock is a one argumentBlock that computes the new position from a given one under the alternate semantics.
	Note that directionBlock always is evaluated first."
	| indices newPosition shouldSelect |
	shouldSelect := aKeyboardEvent shiftPressed.
	indices := self setIndices: shouldSelect forward: forward.
	newPosition := directionBlock value: (indices at: #moving).
	(aKeyboardEvent commandKeyPressed or: [aKeyboardEvent controlKeyPressed])
		ifTrue: [newPosition := specialBlock value: newPosition].
	shouldSelect
		ifTrue: [self selectMark: (indices at: #fixed) point: newPosition - 1]
		ifFalse: [self selectAt: newPosition]
]

{ #category : #private }
Editor >> moveCursor: directionBlock forward: forward select: shouldSelect [
	"Private - Move cursor.
	directionBlock is a one argument Block that computes the new Position from a given one.
	specialBlock is a one argumentBlock that computes the new position from a given one under the alternate semantics.
	Note that directionBlock always is evaluated first."
	| indices newPosition |
	indices := self setIndices: shouldSelect forward: forward.
	newPosition := directionBlock value: (indices at: #moving).
	shouldSelect
		ifTrue: [self selectMark: (indices at: #fixed) point: newPosition - 1]
		ifFalse: [self selectAt: newPosition]
]

{ #category : #private }
Editor >> nextWord: position [
	| string index |
	string := self string.
	index := position.
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric]]
		whileTrue: [index := index + 1].
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric not]]
		whileTrue: [index := index + 1].
	^ index
]

{ #category : #'typing\/selecting keys' }
Editor >> nonDestructiveBackWord: aKeyboardEvent [ 
	"Select the prior word."
	| indices newPosition |
	self closeTypeIn.
	indices := self 
		setIndices: true
		forward: false.
	newPosition := 1 max: (indices at: #moving) - 1.
	newPosition :=  self previousWord: newPosition.
	self selectMark: (indices at: #fixed) point: newPosition - 1.
	^ true
]

{ #category : #'editing keys' }
Editor >> noop: aKeyboardEvent [ 
	"Unimplemented keyboard command; just ignore it."

	^ true
]

{ #category : #'typing\/selecting keys' }
Editor >> normalCharacter: aKeyboardEvent [ 
	"A nonspecial character is to be added to the stream of characters."

	self addString: aKeyboardEvent keyCharacter asString.
	^false
]

{ #category : #'menu messages' }
Editor >> paste [
	"Paste the text from the shared buffer over the current selection and 
	redisplay if necessary.  Undoer & Redoer: undoAndReselect."

	self replace: self selectionInterval with: self clipboardText and:
		[self selectAt: self pointIndex]
]

{ #category : #'editing keys' }
Editor >> paste: aKeyboardEvent [ 
	"Replace the current text selection by the text in the shared buffer."

	self insertAndCloseTypeIn.
	self paste.
	^true
]

{ #category : #private }
Editor >> previousWord: position [
	| string index |
	string := self string.
	index := position.
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric not]]
		whileTrue: [index := index - 1].
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric]]
		whileTrue: [index := index - 1].
	^ index + 1
]

{ #category : #'typing\/selecting keys' }
Editor >> selectAll [

	self selectFrom: 1 to: self string size
]

{ #category : #'typing\/selecting keys' }
Editor >> selectAll: aKeyboardEvent [ 
	"select everything, invoked by cmd-a.  1/17/96 sw"

	self insertAndCloseTypeIn.
	self selectFrom: 1 to: self string size.
	^ true
]

{ #category : #'new selection' }
Editor >> selectAt: characterIndex [ 
	"Deselect, then place the caret before the character at characterIndex.
	 Be sure it is in view."

	self selectFrom: characterIndex to: characterIndex - 1
]

{ #category : #'new selection' }
Editor >> selectInterval: anInterval [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	self selectFrom: anInterval first to: anInterval last
]

{ #category : #'new selection' }
Editor >> selectIntervalInvisibly: anInterval [
	"Deselect, then select the specified characters inclusive.
	 Do not yet make the new selection visible."

	self selectInvisiblyFrom: anInterval first to: anInterval last
]

{ #category : #'new selection' }
Editor >> selectInvisiblyFrom: start to: stop [
	"Select the designated characters, inclusive.  Make no visual changes."

	self markIndex: start pointIndex: stop + 1
]

{ #category : #'new selection' }
Editor >> selectInvisiblyMark: mark point: point [
	"Select the designated characters, inclusive.  Make no visual changes."

	self markIndex: mark pointIndex: point + 1
]

{ #category : #'new selection' }
Editor >> selectMark: mark point: point [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	(mark =  self markIndex and: [point + 1 = self pointIndex]) ifFalse: [
		self selectInvisiblyMark: mark point: point ]
]

{ #category : #'new selection' }
Editor >> selectWord [
	"Select a word or expression, the result of pressing Command+[Space Bar] or by double-clicking."
	^self
		selectWordLeftDelimiters: '
"''|([{<'   "<--- punctuation symbols should precede the bracket symbols"
		rightDelimiters: '
"''|)]}>'
]

{ #category : #'nonediting\/nontyping keys' }
Editor >> selectWord: aKeyboardEvent [

	self insertAndCloseTypeIn.
	self selectWord.
	^ true
]

{ #category : #'new selection' }
Editor >> selectWordLeftDelimiters: leftDelimiters rightDelimiters: rightDelimiters [
	"Select delimited text or word--the result of double-clicking."

	| openDelimiter closeDelimiter direction match level
	string here hereChar start stop |
	string := self string.
	string size < 2 ifTrue: [^self].
	here := self pointIndex.
	"Select the whole text when clicking before first or after last character"
	(here > string size or: [here < 2]) ifTrue: [^self selectFrom: 1 to: string size].
	openDelimiter := string at: here - 1.
	closeDelimiter := string at: here.
	(match := leftDelimiters indexOf: openDelimiter) > (rightDelimiters indexOf: closeDelimiter)
		ifTrue: [
			"a more-distinct delimiter is on the left -- match to the right"
			start := here.
			direction := 1.
			here := here - 1.
			closeDelimiter := rightDelimiters at: match]
		ifFalse: [
			openDelimiter := string at: here.
			match := rightDelimiters indexOf: openDelimiter.
			match > 0
				ifTrue: [
					"delimiter is on right -- match to the left"
					stop := here - 1.
					direction := -1.
					closeDelimiter := leftDelimiters at: match]
				ifFalse: [
					"no delimiters -- select a token"
					direction := -1]].
	level := 1.
	[level > 0 and: [direction > 0
			ifTrue: [here < string size]
			ifFalse: [here > 1]]]
		whileTrue: [
			hereChar := string at: (here := here + direction).
			match = 0
				ifTrue: ["token scan goes left, then right"
					hereChar tokenish
						ifTrue: [here = 1
								ifTrue: [
									start := 1.
									"go right if hit string start"
									direction := 1]]
						ifFalse: [
							direction < 0
								ifTrue: [
									start := here + 1.
									"go right if hit non-token"
									direction := 1]
								ifFalse: [level := 0]]]
				ifFalse: ["bracket match just counts nesting level"
					hereChar = closeDelimiter
						ifTrue: [level := level - 1"leaving nest"]
						ifFalse: [hereChar = openDelimiter 
									ifTrue: [level := level + 1"entering deeper nest"]]]].

	level > 0 ifTrue: ["in case ran off string end"	here := here + direction].
	^direction > 0
		ifTrue: [self selectFrom: start to: here - 1]
		ifFalse: [self selectFrom: here + 1 to: stop]
]

{ #category : #'accessing-selection' }
Editor >> selectionInterval [
	"Answer the interval that is currently selected."

	^self startIndex to: self stopIndex - 1 
]

{ #category : #private }
Editor >> setIndices: shiftPressed forward: forward [
	"Little helper method that sets the moving and fixed indices according to some flags."
	| indices |
	indices := Dictionary new.
	(shiftPressed and:[self class selectionsMayShrink])
		ifTrue: [
			indices at: #moving put: self pointIndex.
			indices at: #fixed put: self markIndex
		] ifFalse: [
			forward
				ifTrue:[
					indices at: #moving put: self stopIndex.
					indices at: #fixed put: self startIndex.
				] ifFalse: [
					indices at: #moving put: self startIndex.
					indices at: #fixed put: self stopIndex.
				]
		].
	^indices
]

{ #category : #accessing }
Editor >> userHasEdited [
	"Note that my text is free of user edits."

	morph hasUnacceptedEdits: true
]

{ #category : #'menu messages' }
Editor >> wordSelectAndEmptyCheck: returnBlock [
	"Ensure selecting the entire current word; if after that's done the selection is still empty, then evaluate the returnBlock, which will typically consist of '[^ self]' in the caller -- check senders of this method to understand this."

	self hasSelection ifFalse: [
		self selectWord.
		self hasSelection ifFalse: [
			morph flash. 
			^ returnBlock value]].
]
