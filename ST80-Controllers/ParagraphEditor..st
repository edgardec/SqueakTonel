"
I am a Controller for editing a Paragraph. I am a kind of ScrollController, so that more text can be created for the Paragraph than can be viewed on the screen. Editing messages are sent by issuing commands from a yellow button menu or from keys on the keyboard. My instances keep control as long as the cursor is within the view when the red or yellow mouse button is pressed; they give up control if the blue button is pressed.
"
Class {
	#name : #ParagraphEditor,
	#superclass : #ScrollController,
	#instVars : [
		'paragraph',
		'startBlock',
		'stopBlock',
		'beginTypeInBlock',
		'emphasisHere',
		'initialText',
		'selectionShowing',
		'otherInterval',
		'lastParentLocation',
		'wasComposition'
	],
	#classVars : [
		'ChangeText',
		'CmdActions',
		'FindText',
		'Keyboard',
		'ShiftCmdActions',
		'UndoInterval',
		'UndoMessage',
		'UndoParagraph',
		'UndoSelection',
		'Undone'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'ST80-Controllers'
}

{ #category : #'class initialization' }
ParagraphEditor class >> abandonChangeText [
	"Call this to get out of the maddening situation in which the system keeps aggressively trying to do a replacement that you no longer wish to make, every time you make choose a new method in a list."
	ChangeText := FindText

	"ParagraphEditor abandonChangeText"

]

{ #category : #'class initialization' }
ParagraphEditor class >> initialize [
	"Initialize the keyboard shortcut maps and the shared buffers 
	for copying text across views and managing again and undo. 
	Marked this method changed to trigger reinit"
	"ParagraphEditor initialize"
	UndoSelection := FindText := ChangeText := Text new.
	UndoMessage := Message selector: #halt.
	self initializeCmdKeyShortcuts.
	self initializeShiftCmdKeyShortcuts.
]

{ #category : #'keyboard shortcut tables' }
ParagraphEditor class >> initializeCmdKeyShortcuts [
	"Initialize the (unshifted) command-key (or alt-key) shortcut table."

	"NOTE: if you don't know what your keyboard generates, use Sensor kbdTest"

	"ParagraphEditor initialize"

	| cmdMap |

	cmdMap := Array new: 256 withAll: #noop:.	"use temp in case of a crash"

	cmdMap at: 1 + 1 put: #cursorHome:.			"home key"
	cmdMap at: 4 + 1 put: #cursorEnd:.				"end key"
	cmdMap at: 8 + 1 put: #backspace:.				"ctrl-H or delete key"
	cmdMap at: 11 + 1 put: #cursorPageUp:.		"page up key"
	cmdMap at: 12 + 1 put: #cursorPageDown:.	"page down key"
	cmdMap at: 13 + 1 put: #crWithIndent:.			"cmd-Return"
	cmdMap at: 27 + 1 put: #offerMenuFromEsc:.	"escape key"
	cmdMap at: 28 + 1 put: #cursorLeft:.			"left arrow key"
	cmdMap at: 29 + 1 put: #cursorRight:.			"right arrow key"
	cmdMap at: 30 + 1 put: #cursorUp:.				"up arrow key"
	cmdMap at: 31 + 1 put: #cursorDown:.			"down arrow key"
	cmdMap at: 32 + 1 put: #selectWord:.			"space bar key"
	cmdMap at: 127 + 1 put: #forwardDelete:.		"del key"

	'0123456789-=' 
		do: [:char | cmdMap at: char asciiValue + 1 put: #changeEmphasis:].

	'([<{|"''' do: [:char | cmdMap at: char asciiValue + 1 put: #enclose:].

	"triplet = {character. comment selector. novice appropiated}"
	#(
		($a		#selectAll:				true)
		($b		#browseIt:				false)
		($c		#copySelection:			true)
		($d		#doIt:						false)
		($e		#exchange:				true)
		($f		#find:						true)
		($g		#findAgain:				true)
		($h		#setSearchString:		true)
		($i		#inspectIt:				false)
		($j		#doAgainOnce:			true)
		($k		#offerFontMenu:		true)
		($l		#cancel:					true)
		($m	#implementorsOfIt:		false)
		($n		#sendersOfIt:			false)
		($o		#spawnIt:				false)
		($p		#printIt:					false)
		($q		#querySymbol:			false)
		($s		#save:					true)
		($t		#tempCommand:		false)
		($u		#align:					true)
		($v		#paste:					true)
		($w	#backWord:				true)
		($x		#cut:						true)
		($y		#swapChars:				true)
		($z		#undo:					true)
	)
		select:[:triplet | Preferences noviceMode not or:[triplet third]]
		thenDo:[:triplet | cmdMap at: triplet first asciiValue + 1 put: triplet second].

	CmdActions := cmdMap.

]

{ #category : #'keyboard shortcut tables' }
ParagraphEditor class >> initializeShiftCmdKeyShortcuts [ 
	"Initialize the shift-command-key (or control-key) shortcut table."
	"NOTE: if you don't know what your keyboard generates, use Sensor kbdTest"
	"wod 11/3/1998: Fix setting of cmdMap for shifted keys to actually use the 
	capitalized versions of the letters.
	TPR 2/18/99: add the plain ascii values back in for those VMs that don't return the shifted values."

	| cmdMap |

	"shift-command and control shortcuts"
	cmdMap := Array new: 256 withAll: #noop:.  "use temp in case of a crash"

	cmdMap at: ( 1 + 1) put: #cursorHome:.				"home key"
	cmdMap at: ( 4 + 1) put: #cursorEnd:.				"end key"
	cmdMap at: ( 8 + 1) put: #forwardDelete:.			"ctrl-H or delete key"
	cmdMap at: (11 + 1) put: #cursorPageUp:.			"page up key"
	cmdMap at: (12 + 1) put: #cursorPageDown:.		"page down key"
	cmdMap at: (13 + 1) put: #crWithIndent:.			"ctrl-Return"
	cmdMap at: (27 + 1) put: #offerMenuFromEsc:.	"escape key"
	cmdMap at: (28 + 1) put: #cursorLeft:.				"left arrow key"
	cmdMap at: (29 + 1) put: #cursorRight:.				"right arrow key"
	cmdMap at: (30 + 1) put: #cursorUp:.				"up arrow key"
	cmdMap at: (31 + 1) put: #cursorDown:.			"down arrow key"
	cmdMap at: (32 + 1) put: #selectWord:.				"space bar key"
	cmdMap at: (45 + 1) put: #changeEmphasis:.		"cmd-sh-minus"
	cmdMap at: (61 + 1) put: #changeEmphasis:.		"cmd-sh-plus"
	cmdMap at: (127 + 1) put: #forwardDelete:.		"del key"

	"On some keyboards, these characters require a shift"
	'([<{|"''' do: [:char | cmdMap at: char asciiValue + 1 put: #enclose:].
		
	"NB: sw 12/9/2001 commented out the idiosyncratic line just below, which was grabbing shift-esc in the text editor and hence which argued with the wish to have shift-esc be a universal gesture for escaping the local context and calling up the desktop menu."  
	"cmdMap at: (27 + 1) put: #shiftEnclose:." 	"ctrl-["

	"'""''(' do: [ :char | cmdMap at: (char asciiValue + 1) put: #enclose:]."

	"triplet = {character. comment selector. novice appropiated}"
	#(
		($a		argAdvance:						false)
		($b		browseItHere:					false)
		($c		compareToClipboard:			false)
		($e		methodStringsContainingIt:	false)
		($f		displayIfFalse:					false)
		($g		fileItIn:							false)
		($h		cursorTopHome:					true)
		($i		exploreIt:							false)
		($j		doAgainMany:					true)
		($k		changeStyle:						true)
		($m		selectCurrentTypeIn:			true)
		($n		referencesToIt:					false)
		($p		makeProjectLink:				true)
		($s		search:							true)
		($t		displayIfTrue:					false)
		($u		changeLfToCr:					false)
		($v		pasteInitials:						false)
		($w	methodNamesContainingIt:	false)
		($x		makeLowercase:					true)
		($y		makeUppercase:					true)
		($z		makeCapitalized:				true)
	)
		select:[:triplet | Preferences noviceMode not or:[triplet third]]
		thenDo:[:triplet |
			cmdMap at: (triplet first asciiValue         + 1) put: triplet second.		"plain keys"
			cmdMap at: (triplet first asciiValue - 32 + 1) put: triplet second.		"shifted keys"
			cmdMap at: (triplet first asciiValue - 96 + 1) put: triplet second.		"ctrl keys"
		].

	ShiftCmdActions := cmdMap
]

{ #category : #'keyboard shortcut tables' }
ParagraphEditor class >> multiRedoOverride [
"Call this to set meta-r to perform the multilevel redo (or tweak the code below to have it bound to some other key sequence)."

"
ParagraphEditor multiRedoOverride.
"
	CmdActions at: $r asciiValue + 1 put: #multiRedo: 

]

{ #category : #'instance creation' }
ParagraphEditor class >> new [
	"Answer a new instance of me with a null Paragraph to be edited."

	| aParagraphEditor |
	aParagraphEditor := super new.
	aParagraphEditor changeParagraph: '' asParagraph.
	^aParagraphEditor
]

{ #category : #'instance creation' }
ParagraphEditor class >> newParagraph: aParagraph [ 
	"Answer an instance of me with aParagraph as the text to be edited."

	| aParagraphEditor |
	aParagraphEditor := super new.
	aParagraphEditor initialize.
	aParagraphEditor changeParagraph: aParagraph.
	^aParagraphEditor
]

{ #category : #'class initialization' }
ParagraphEditor class >> shiftedYellowButtonMenu [
	"Answer the menu to be presented when the yellow button is pressed while the shift key is down"

	^ SelectionMenu fromArray: StringHolder shiftedYellowButtonMenuItems

]

{ #category : #'keyboard shortcut tables' }
ParagraphEditor class >> specialShiftCmdKeys [

"Private - return array of key codes that represent single keys acting
as if shift-command were also being pressed"

^#(
	1	"home"
	3	"enter"
	4	"end"
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

{ #category : #'class initialization' }
ParagraphEditor class >> yellowButtonExpertMenu [

	^ SelectionMenu fromArray: StringHolder yellowButtonMenuItems.

]

{ #category : #'class initialization' }
ParagraphEditor class >> yellowButtonMenu [

	^ Preferences noviceMode
			ifTrue: [self yellowButtonNoviceMenu]
			ifFalse: [self yellowButtonExpertMenu]

]

{ #category : #'class initialization' }
ParagraphEditor class >> yellowButtonNoviceMenu [

	^ MenuMorph fromArray: {
			{'set font... (k)' translated.				#offerFontMenu}.
			{'set style... (K)' translated.				#changeStyle}.
			{'set alignment... (u)' translated.		#chooseAlignment}.
			#-.
			{'make project link (P)' translated.	#makeProjectLink}.
			#-.
			{'find...(f)' translated.					#find}.
			{'find again (g)' translated.				#findAgain}.
			{'set search string (h)' translated.		#setSearchString}.
			#-.
			{'do again (j)' translated.				#again}.
			{'undo (z)' translated.					#undo}.
			#-.
			{'copy (c)' translated.					#copySelection}.
			{'cut (x)' translated.						#cut}.
			{'paste (v)' translated.					#paste}.
			{'paste...' translated.					#pasteRecent}.
			#-.
			{'accept (s)' translated.					#accept}.
			{'cancel (l)' translated.					#cancel}.
		}.

]

{ #category : #'editing keys' }
ParagraphEditor >> abandonChangeText [
	^self class abandonChangeText
]

{ #category : #'menu messages' }
ParagraphEditor >> accept [
	"Save the current text of the text being edited as the current acceptable version for purposes of canceling."

	initialText := paragraph text copy.

]

{ #category : #'as yet unclassified' }
ParagraphEditor >> activateTextActions [
	(paragraph text attributesAt: startBlock stringIndex) 
		do: [:att | att actOnClickFor: model in: paragraph]
]

{ #category : #'new selection' }
ParagraphEditor >> adjustSelection: directionBlock [
	"Helper function for Cursor movement. Always moves point thus allowing selections to shrink. "
	"See also expandSelection:"
	"Accepts a one argument Block that computes the new postion given an old one."
	| newPosition |
	newPosition := directionBlock value: self pointIndex.
	self selectMark: self markIndex point: newPosition.
	^true.
]

{ #category : #'new selection' }
ParagraphEditor >> afterSelectionInsertAndSelect: aString [

	self insertAndSelect: aString at: self stopIndex 
]

{ #category : #'menu messages' }
ParagraphEditor >> again [
	"Text substitution. If the left shift key is down, the substitution is made 
	throughout the entire Paragraph. Otherwise, only the next possible 
	substitution is made.
	Undoer & Redoer: #undoAgain:andReselect:typedKey:."

	"If last command was also 'again', use same keys as before"
	self againOrSame: (UndoMessage sends: #undoAgain:andReselect:typedKey:)
]

{ #category : #private }
ParagraphEditor >> againOnce: indices [
	"Find the next occurrence of FindText.  If none, answer false.
	Append the start index of the occurrence to the stream indices, and, if
	ChangeText is not the same object as FindText, replace the occurrence by it.
	Note that the search is case-sensitive for replacements, otherwise not."

	| where |
	where := paragraph text findString: FindText startingAt: self stopIndex
				caseSensitive: ((ChangeText ~~ FindText) or: [Preferences caseSensitiveFinds]).
	where = 0 ifTrue: [^ false].
	self deselect; selectInvisiblyFrom: where to: where + FindText size - 1.
	ChangeText ~~ FindText ifTrue: [self zapSelectionWith: ChangeText].
	indices nextPut: where.
	self selectAndScroll.
	^ true
]

{ #category : #private }
ParagraphEditor >> againOrSame: useOldKeys [
	"Subroutine of search: and again.  If useOldKeys, use same FindText and ChangeText as before.
	 1/26/96 sw: real worked moved to againOrSame:many:"

	^ self againOrSame: useOldKeys many: sensor leftShiftDown
]

{ #category : #private }
ParagraphEditor >> againOrSame: useOldKeys many: many [
	"Subroutine of search: and again.  If useOldKeys, use same FindText and ChangeText as before.  If many is true, do it repeatedly.  Created 1/26/96 sw by adding the many argument to #againOrSame."

	|  home indices wasTypedKey |

	home := self selectionInterval.  "what was selected when 'again' was invoked"

	"If new keys are to be picked..."
	useOldKeys ifFalse: "Choose as FindText..."
		[FindText := UndoSelection.  "... the last thing replaced."
		"If the last command was in another paragraph, ChangeText is set..."
		paragraph == UndoParagraph ifTrue: "... else set it now as follows."
			[UndoInterval ~= home ifTrue: [self selectInterval: UndoInterval]. "blink"
			ChangeText := ((UndoMessage sends: #undoCutCopy:) and: [self hasSelection])
				ifTrue: [FindText] "== objects signal no model-locking by 'undo copy'"
				ifFalse: [self selection]]]. "otherwise, change text is last-replaced text"

	(wasTypedKey := FindText size = 0)
		ifTrue: "just inserted at a caret"
			[home := self selectionInterval.
			self replaceSelectionWith: self nullText.  "delete search key..."
			FindText := ChangeText] "... and search for it, without replacing"
		ifFalse: "Show where the search will start"
			[home last = self selectionInterval last ifFalse:
				[self selectInterval: home]].

	"Find and Change, recording start indices in the array"
	indices := WriteStream on: (Array new: 20). "an array to store change locs"
	[(self againOnce: indices) & many] whileTrue. "<-- this does the work"
	indices isEmpty ifTrue:  "none found"
		[self flash.
		wasTypedKey ifFalse: [^self]].

	(many | wasTypedKey) ifFalse: "after undo, select this replacement"
		[home := self startIndex to:
			self startIndex + UndoSelection size - 1].

	self undoer: #undoAgain:andReselect:typedKey: with: indices contents with: home with: wasTypedKey
]

{ #category : #'menu messages' }
ParagraphEditor >> align [
	"Align text according to the next greater alignment value--cycling among 
	left flush, right flush, center, justified.  No effect on the undoability of the pre
	preceding command."

	paragraph toggleAlignment.
	paragraph displayOn: Display.
	self recomputeInterval
]

{ #category : #'editing keys' }
ParagraphEditor >> align: characterStream [ 
	"Triggered by Cmd-u;  cycle through alignment alternatives.  8/11/96 sw"

	sensor keyboard.		"flush character"
	self align.
	^ true
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> argAdvance: characterStream [ 
	"Invoked by Ctrl-a. Useful after Ctrl-q or pasting a selector.
	Search forward from the end of the selection for a colon and place
	the caret after it. If no colon is found, do nothing.."
	| start |
	"flush character"
	sensor keyboard.
	self closeTypeIn: characterStream.
	start := paragraph text findString: ':' startingAt: self stopIndex.
	start = 0
		ifFalse: [self selectAt: start + 1].
	^ true
]

{ #category : #'typing support' }
ParagraphEditor >> backTo: startIndex [
	"During typing, backspace to startIndex.  Deleted characters fall into three
	 clusters, from left to right in the text: (1) preexisting characters that were
	 backed over; (2) newly typed characters that were backed over (excluding
	 typeahead, which never even appears); (3) preexisting characters that
	 were highlighted before typing began.  If typing has not yet been opened,
	 open it and watch for the first and third cluster.  If typing has been opened,
	 watch for the first and second cluster.  Save characters from the first and third
	 cluster in UndoSelection.  Tally characters from the first cluster in UndoMessage's parameter.
	 Delete all the clusters.  Do not alter Undoer or UndoInterval (except via
	 openTypeIn).  The code is shorter than the comment."

	| saveLimit newBackovers |
	saveLimit := beginTypeInBlock == nil
		ifTrue: [self openTypeIn. UndoSelection := self nullText. self stopIndex]
		ifFalse: [self startOfTyping].
	self setMark: startIndex.
	startIndex < saveLimit ifTrue:
		[newBackovers := self startOfTyping - startIndex.
		beginTypeInBlock := self startIndex.
		UndoSelection replaceFrom: 1 to: 0 with:
			(paragraph text copyFrom: startIndex to: saveLimit - 1).
		UndoMessage argument: (UndoMessage argument ifNil: [1]) + newBackovers].
	self zapSelectionWith: self nullText.
	self unselect
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> backWord: characterStream [ 
	"If the selection is not a caret, delete it and leave it in the backspace buffer.
	 Else if there is typeahead, delete it.
	 Else, delete the word before the caret."

	| startIndex |
	sensor keyboard.
	characterStream isEmpty
		ifTrue:
			[self hasCaret
				ifTrue: "a caret, delete at least one character"
					[startIndex := 1 max: self markIndex - 1.
					[startIndex > 1 and:
						[(paragraph text at: startIndex - 1) asCharacter tokenish]]
						whileTrue:
							[startIndex := startIndex - 1]]
				ifFalse: "a non-caret, just delete it"
					[startIndex := self markIndex].
			self backTo: startIndex]
		ifFalse:
			[characterStream reset].
	^false
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> backspace: characterStream [ 
	"Backspace over the last character."

	| startIndex |
	sensor leftShiftDown ifTrue: [^ self backWord: characterStream].

	startIndex := self markIndex + (self hasCaret ifTrue: [0] ifFalse: [1]).
	[sensor keyboardPressed and:
			 [sensor peekKeyboard asciiValue = 8]] whileTrue: [
				"process multiple backspaces"
				sensor keyboard.
				startIndex := 1 max: startIndex - 1.
			].
	self backTo: startIndex.
		
	^false
]

{ #category : #parenblinking }
ParagraphEditor >> blinkParen [
	"Highlight the last parenthesis in the text"
	lastParentLocation ifNotNil:
		[self text string size >= lastParentLocation ifTrue: [
			self text
				addAttribute: TextEmphasis bold
				from: lastParentLocation
				to: lastParentLocation]]

]

{ #category : #parenblinking }
ParagraphEditor >> blinkParenAt: parenLocation [ 
	self text
		addAttribute: TextEmphasis bold
		from: parenLocation
		to: parenLocation.
	lastParentLocation := parenLocation.
]

{ #category : #parenblinking }
ParagraphEditor >> blinkPrevParen [

	self deprecated: 'Use #blinkPrevParen:'.
	self blinkPrevParen: sensor peekKeyboard
]

{ #category : #parenblinking }
ParagraphEditor >> blinkPrevParen: aCharacter [
	| openDelimiter closeDelimiter level string here hereChar |
	string := paragraph text string.
	here := startBlock stringIndex.
	openDelimiter := aCharacter.
	closeDelimiter := '([{' at: (')]}' indexOf: openDelimiter).
	level := 1.
	[level > 0 and: [here > 1]]
		whileTrue:
			[hereChar := string at: (here := here - 1).
			hereChar = closeDelimiter
				ifTrue:
					[level := level - 1.
					level = 0
						ifTrue: [^ self blinkParenAt: here]]
				ifFalse:
					[hereChar = openDelimiter
						ifTrue: [level := level + 1]]].
]

{ #category : #'menu messages' }
ParagraphEditor >> browseClassFromIt [
	"Launch a browser for the class indicated by the current selection. 
	If multiple classes matching the selection exist, let the user choose among them."
	| aClass |

	self lineSelectAndEmptyCheck: [^ self].
	aClass := UIManager default
				classFromPattern: self selection string
				withCaption: 'choose a class to browse...'.
	aClass ifNil: [^ view flash].
	self terminateAndInitializeAround: 
			[self systemNavigation browseClass: aClass].
]

{ #category : #'menu messages' }
ParagraphEditor >> browseIt [
	"Launch a browser for the current selection, if appropriate."

	Preferences alternativeBrowseIt ifTrue: [^ self browseClassFromIt].

	self lineSelectAndEmptyCheck: [^ view flash].

	self terminateAndInitializeAround: [

	self flag: #todo. "mt: Active controller process will terminate if any new tool is opened. Find a way to open two tools in this method."

	"First, try to show all accesses to instance or class variables."
	self selectedInstanceVariable ifNotNil:
		[:nameToClass | self systemNavigation
				browseAllAccessesTo: nameToClass key
				from: nameToClass value].
	self selectedClassVariable ifNotNil:
		[:binding | self systemNavigation browseAllCallsOn: binding].

	"Then, either browse the class (from a binding) or all implementors of a selector."
	self selectedBinding ifNotNil:
		[:binding | self systemNavigation browseClass: binding].
	self selectedSelector ifNotNil:
		[:selector | self systemNavigation browseAllImplementorsOf: selector].
	
	]
]

{ #category : #'editing keys' }
ParagraphEditor >> browseIt: characterStream [ 
	"Triggered by Cmd-B; browse the thing represented by the current selection, if plausible.  1/18/96 sw"

	sensor keyboard.		"flush character"
	self browseIt.
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> browseItHere: characterStream [ 
	"Triggered by Cmd-shift-B; browse the thing represented by the current selection, if plausible, in the receiver's own window.  3/1/96 sw"

	sensor keyboard.		"flush character"
	self browseItHere.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> cancel [ 
	"Restore the text of the paragraph to be the text saved since initialization 
	or the last accept.  Undoer & Redoer: undoAndReselect:redoAndReselect:.
	This used to call controlTerminate and controlInitialize but this seemed illogical.
	Sure enough, nobody overrode them who had cancel in the menu, and if
	anybody really cared they could override cancel."

	UndoSelection := paragraph text.
	self undoer: #undoAndReselect:redoAndReselect: with: self selectionInterval with: (1 to: 0).
	view ifNotNil: [view clearInside].
	self changeParagraph: (paragraph text: initialText).
	UndoParagraph := paragraph.
	otherInterval := UndoInterval := 1 to: initialText size. "so undo will replace all"
	paragraph displayOn: Display.
	self selectAt: 1.
	self scrollToTop

]

{ #category : #'editing keys' }
ParagraphEditor >> cancel: characterStream [ 
	"Cancel unsubmitted changes.  Flushes typeahead.  1/12/96 sw
	 1/22/96 sw: put in control terminate/init"

	sensor keyboard.
	self terminateAndInitializeAround: [self cancel].
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> changeAlignment [
	| aList reply  |
	aList := #(leftFlush centered justified rightFlush).
	reply := (SelectionMenu labelList: (aList collect: [:t | t translated]) selections: aList) startUp.
	reply ifNil:[^self].
	self setAlignment: reply.
	paragraph composeAll.
	self recomputeSelection.
	self mvcRedisplay.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> changeEmphasis [
	| aList reply  |
	aList := #(normal bold italic narrow underlined struckOut).
	reply := (SelectionMenu labelList: (aList collect: [:t | t translated]) selections: aList) startUp.
	reply ~~ nil ifTrue:
		[self setEmphasis: reply.
		paragraph composeAll.
		self recomputeSelection.
		self mvcRedisplay].
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> changeEmphasis: characterStream [ 
	"Change the emphasis of the current selection or prepare to
	accept characters with the change in emphasis. Emphasis
	change amounts to a font change. Keeps typeahead."
	
	| keyCode attribute oldAttributes index thisSel colors extras |

	"control 0..9 -> 0..9"
	keyCode := ('0123456789-=' indexOf: sensor keyboard ifAbsent: [1]) - 1.

	oldAttributes := paragraph text attributesAt: self pointIndex forStyle: paragraph textStyle.
	thisSel := self selection.

	"Decipher keyCodes for Command 0-9..."
	(keyCode between: 1 and: 5) ifTrue: [
		attribute := TextFontChange fontNumber: keyCode
	].

	keyCode = 6 ifTrue: [
		| labels lines | 
		colors := #(#black #magenta #red #yellow #green #blue #cyan #white ).
		extras := #('Link to comment of class' 'Link to definition of class' 'Link to hierarchy of class' 'Link to method' ).

		Preferences noviceMode ifTrue: [
			labels := colors , #('choose color...' ).
			lines := #()
		]
		ifFalse: [
			labels := colors , #('choose color...' 'Do it' 'Print it' ) , extras , #('be a web URL link' 'Edit hidden info' 'Copy hidden info' ).
			lines := Array with: colors size + 1
		].

		"index := (PopUpMenu labelArray: labels lines: lines) startUp. "
		index := UIManager default chooseFrom: labels lines: lines.
		index = 0
			ifTrue: [ ^ true].
			
		index <= colors size ifTrue: [
			attribute := TextColor color: (Color perform: (colors at: index))
		]
		ifFalse: [
			index := index - colors size - 1. "Re-number!!!"

			index = 0 ifTrue: [
				attribute := self chooseColor
			].

			index = 1 ifTrue: [
				attribute := TextDoIt new.
				thisSel := attribute analyze: self selection asString
			].

			index = 2 ifTrue: [
				attribute := TextPrintIt new.
				thisSel := attribute analyze: self selection asString
			].

			extras size = 0 & (index > 2) ifTrue: [
				index := index + 4 "skip those"
			].

			index = 3 ifTrue: [
				attribute := TextLink new.
				thisSel := attribute analyze: self selection asString with: 'Comment'
			].

			index = 4 ifTrue: [
				attribute := TextLink new.
				thisSel := attribute analyze: self selection asString with: 'Definition'
			].

			index = 5 ifTrue: [
				attribute := TextLink new.
				thisSel := attribute analyze: self selection asString with: 'Hierarchy'
			].

			index = 6 ifTrue: [
				attribute := TextLink new.
				thisSel := attribute analyze: self selection asString
			].
		
			index = 7 ifTrue: [
				attribute := TextURL new.
				thisSel := attribute analyze: self selection asString
			].
		
			index = 8 ifTrue: [
				"Edit hidden info"
				thisSel := self hiddenInfo. "includes selection"
				attribute := TextEmphasis normal
			].

			index = 9 ifTrue: [
				"Copy hidden info"
				self copyHiddenInfo.
				^ true
			].
		
			"no other action"
			thisSel
				ifNil: [ ^ true ]
		]
	].

	(keyCode between: 7 and: 11) ifTrue: [
		sensor leftShiftDown ifTrue: [
			keyCode = 10 ifTrue: [
				attribute := TextKern kern: -1
			].
			keyCode = 11 ifTrue: [
				attribute := TextKern kern: 1
			]
		]
		ifFalse: [
			attribute := TextEmphasis perform: (#(#bold #italic #narrow #underlined #struckOut ) at: keyCode - 6).
			oldAttributes
						do: [:att | (att dominates: attribute) ifTrue: [attribute turnOff]]
		]
	].

	keyCode = 0
		ifTrue: [attribute := TextEmphasis normal].

	beginTypeInBlock ~~ nil ifTrue: [
		"only change emphasisHere while typing"
		self insertTypeAhead: characterStream.
		emphasisHere := Text addAttribute: attribute toArray: oldAttributes.
		^ true
	].

	self
		replaceSelectionWith: (thisSel asText addAttribute: attribute).
		
	^ true

]

{ #category : #'menu messages' }
ParagraphEditor >> changeEmphasisOrAlignment [
	| aList reply  |
	aList := #(normal bold italic narrow underlined struckOut leftFlush centered rightFlush justified).
	reply := (SelectionMenu labelList: aList lines: #(6) selections: aList) startUp.
	reply ~~ nil ifTrue:
		[(#(leftFlush centered rightFlush justified) includes: reply)
			ifTrue:
				[paragraph perform: reply.
				self recomputeInterval]
			ifFalse:
				[self setEmphasis: reply.
				paragraph composeAll.
				self recomputeSelection.
				self mvcRedisplay]].
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> changeLfToCr: characterStream [ 
	"Replace all LFs by CRs, and CR-LF pairs by single CRs.
	Triggered by Cmd-U -- useful when getting code from FTP sites"

	sensor keyboard.		"flush the triggering cmd-key character"
	self replaceSelectionWith: (Text fromString:
			(self selection string withSqueakLineEndings)).
	^ true
]

{ #category : #'initialize-release' }
ParagraphEditor >> changeParagraph: aParagraph [ 
	"Install aParagraph as the one to be edited by the receiver."

	UndoParagraph == paragraph ifTrue: [UndoParagraph := nil].
	paragraph := aParagraph.
	self resetState
]

{ #category : #'menu messages' }
ParagraphEditor >> changeStyle [
	"Let user change styles for the current text pane  
	 Moved from experimentalCommand to its own method  "

	| aList reply style |
	aList := StrikeFont actualFamilyNames.
	aList addFirst: 'DefaultTextStyle'.
	reply := (SelectionMenu labelList: aList lines: #(1) selections: aList) startUp.
	reply ifNotNil:
		[(style := TextStyle named: reply) ifNil: [Beeper beep. ^ true].
		paragraph textStyle: style copy.
		paragraph composeAll.
		self recomputeSelection.
		self mvcRedisplay].
	^ true
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> changeStyle: characterStream [ 
	"Put up the style-change menu"

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self changeStyle.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> changeStyleTo: aNewStyle [

	paragraph textStyle: aNewStyle.
	paragraph composeAll.
	self recomputeSelection.

]

{ #category : #'accessing-selection' }
ParagraphEditor >> charBefore [

	| start |
	(start := self startIndex) > 1 ifTrue: [^ paragraph text at: start - 1].
	^ nil.

]

{ #category : #'menu messages' }
ParagraphEditor >> chooseAlignment [
	self changeAlignment
]

{ #category : #'editing keys' }
ParagraphEditor >> chooseColor [
	"Make a new Text Color Attribute, let the user pick a color, and return the attribute.  This is the non-Morphic version."

	^ TextColor color: (Color fromUser)
]

{ #category : #'menu messages' }
ParagraphEditor >> classCommentsContainingIt [
	"Open a browser class comments which contain the current selection somewhere in them."

	self lineSelectAndEmptyCheck: [^ self].
	self terminateAndInitializeAround: [
		self systemNavigation browseClassCommentsWithString: self selection string]
]

{ #category : #'menu messages' }
ParagraphEditor >> classNamesContainingIt [
	"Open a browser on classes whose names contain the selected string"

	self lineSelectAndEmptyCheck: [^self].
	self systemNavigation 
		browseClassesWithNamesContaining: self selection string
		caseSensitive: Sensor leftShiftDown
]

{ #category : #parenblinking }
ParagraphEditor >> clearParens [
	lastParentLocation ifNotNil:
		[self text string size >= lastParentLocation ifTrue: [
			self text
				removeAttribute: TextEmphasis bold
				from: lastParentLocation
				to: lastParentLocation]].
	lastParentLocation := nil.
]

{ #category : #'menu messages' }
ParagraphEditor >> clipboardText [

	^ Clipboard clipboardText
]

{ #category : #'menu messages' }
ParagraphEditor >> clipboardText: text [

	^ Clipboard clipboardText: text
]

{ #category : #'menu messages' }
ParagraphEditor >> clipboardTextPut: text [

	^ Clipboard clipboardText: text
]

{ #category : #'typing support' }
ParagraphEditor >> closeTypeIn [
	"See comment in openTypeIn.  It is important to call closeTypeIn before executing
	 any non-typing key, making a new selection, etc.  It is called automatically for
	 menu commands.
	 Typing commands can call 'closeTypeIn: aCharacterStream' instead of this to
	 save typeahead.  Undoer & Redoer: undoAndReselect:redoAndReselect:."

	| begin stop |
	beginTypeInBlock == nil ifFalse:
		[(UndoMessage sends: #noUndoer) ifTrue: "should always be true, but just in case..."
			[begin := self startOfTyping.
			stop := self stopIndex.
			self undoer: #undoAndReselect:redoAndReselect:
				with: (begin + UndoMessage argument to: begin + UndoSelection size - 1)
				with: (stop to: stop - 1).
			UndoInterval := begin to: stop - 1].
		beginTypeInBlock := nil]
]

{ #category : #'typing support' }
ParagraphEditor >> closeTypeIn: characterStream [
	"Call instead of closeTypeIn when you want typeahead to be inserted before the
	 control character is executed, e.g., from Ctrl-V."

	self insertTypeAhead: characterStream.
	self closeTypeIn
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> comment [
	"All key actions that are neither editing nor typing actions have to
	send closeTypeIn at first. See comment in openTypeIn closeTypeIn"
]

{ #category : #'menu messages' }
ParagraphEditor >> compareToClipboard [
	"If any text is selected, present the modifications that would be made to it if the clipboard contents were pasted over it.  If no text is selected, present the differences betwen the entire pane's contents and the clipboard text."
	| subjectText proposedText |
	subjectText := self selection string ifEmpty: [ paragraph text string ].
	proposedText := self clipboardText string.
	subjectText = proposedText ifTrue: [^ self inform: 'Exact match'].
	(StringHolder new 
		textContents:
			(TextDiffBuilder
				buildDisplayPatchFrom: subjectText 
				to: proposedText)) openLabel: 'Differences with Clipboard Text'
]

{ #category : #'editing keys' }
ParagraphEditor >> compareToClipboard: characterStream [ 
	"Compare the receiver to the text on the clipboard.  Flushes typeahead.  5/1/96 sw"

	sensor keyboard.	
	self terminateAndInitializeAround: [self compareToClipboard].
	^ true
]

{ #category : #'do-its' }
ParagraphEditor >> compileSelectionFor: anObject in: evalContext [

	| methodNode |
	methodNode := [Compiler new
		compileNoPattern: self selectionAsStream
		in: anObject class
		context: evalContext
		notifying: self
		ifFail: [^nil]]
			on: OutOfScopeNotification
			do: [:ex | ex resume: true].

	^ methodNode generateWithTempNames.

]

{ #category : #private }
ParagraphEditor >> completeSymbol: hintText lastOffering: selectorOrNil [
	"Invoked by Ctrl-q when there is only a caret.
		Do selector-completion, i.e., try to replace the preceding identifier by a
		selector that begins with those characters & has as many keywords as possible.
	 	Leave two spaces after each colon (only one after the last) as space for
		arguments.  Put the caret after the space after the first keyword.  If the
		user types Ctrl-q again immediately, choose a different selector.
	 Undoer: #undoQuery:lastOffering:; Redoer: itself.
	If redoing, just redisplay the last offering, selector[OrNil]."

	| firstTime input prior caret newStart sym kwds outStream |
	firstTime := self isRedoing
		ifTrue: [prior := sym := selectorOrNil. true]
		ifFalse: [hintText isNil].
	firstTime
		ifTrue: "Initial Ctrl-q (or redo)"					
			[caret := self startIndex.
			self selectPrecedingIdentifier.
			input := self selection]
		ifFalse: "Repeated Ctrl-q"
			[caret := UndoInterval first + hintText size.
			self selectInvisiblyFrom: UndoInterval first to: UndoInterval last.
			input := hintText.
			prior := selectorOrNil].
	(input size ~= 0 and: [sym ~~ nil or:
			[(sym := Symbol thatStarts: input string skipping: prior) ~~ nil]])
		ifTrue: "found something to offer"
			[newStart := self startIndex.
			outStream := WriteStream on: (String new: 2 * sym size).
			1 to: (kwds := sym keywords) size do:
				[:i |
				outStream nextPutAll: (kwds at: i).
				i = 1 ifTrue: [caret := newStart + outStream contents size + 1].
				outStream nextPutAll:
					(i < kwds size ifTrue: ['  '] ifFalse: [' '])].
			UndoSelection := input.
			self deselect; zapSelectionWith: outStream contents asText.
			self undoer: #undoQuery:lastOffering: with: input with: sym]
		ifFalse: "no more matches"
			[firstTime ifFalse: "restore original text & set up for a redo"
				[UndoSelection := self selection.
				self deselect; zapSelectionWith: input.
				self undoer: #completeSymbol:lastOffering: with: input with: prior.
				Undone := true].
			view flash].
	self selectAt: caret
]

{ #category : #'new selection' }
ParagraphEditor >> computeIntervalFrom: start to: stop [
	"Select the designated characters, inclusive.  Make no visual changes."

	self setMark: start.
	self setPoint: stop + 1.
]

{ #category : #scrolling }
ParagraphEditor >> computeMarkerRegion [ 
	"Refer to the comment in ScrollController|computeMarkerRegion."

	paragraph compositionRectangle height = 0
		ifTrue:	[^0@0 extent: Preferences scrollBarWidth @ scrollBar inside height]
		ifFalse:	[^0@0 extent:
					Preferences scrollBarWidth 
						@ ((paragraph clippingRectangle height asFloat /
							self scrollRectangleHeight * scrollBar inside height) rounded
							min: scrollBar inside height)]
]

{ #category : #controlling }
ParagraphEditor >> controlInitialize [

	super controlInitialize.
	self recomputeInterval.
	self initializeSelection.
	beginTypeInBlock := nil
]

{ #category : #controlling }
ParagraphEditor >> controlTerminate [

	self closeTypeIn.  "Must call to establish UndoInterval"
	super controlTerminate.
	self deselect
]

{ #category : #'editing keys' }
ParagraphEditor >> copyHiddenInfo [
	"In TextLinks, TextDoits, TextColor, and TextURLs, there is hidden
info.  Copy that to the clipboard.  You can paste it and see what it is.
Usually enclosed in <>."

	^ self clipboardTextPut: self hiddenInfo asText
]

{ #category : #'menu messages' }
ParagraphEditor >> copySelection [
	"Copy the current selection and store it in the paste buffer, unless a caret.  Undoer & Redoer: undoCutCopy"

	self lineSelectAndEmptyCheck: [^ self].

	"Simulate 'substitute: self selection' without locking the controller"
	UndoSelection := self selection.
	self undoer: #undoCutCopy: with: self clipboardText.
	UndoInterval := self selectionInterval.
	self clipboardTextPut: UndoSelection
]

{ #category : #'editing keys' }
ParagraphEditor >> copySelection: characterStream [ 
	"Copy the current text selection.  Flushes typeahead."

	sensor keyboard.		"flush character"
	self copySelection.
	^true
]

{ #category : #'new selection' }
ParagraphEditor >> correctFrom: start to: stop with: aString [
	"Make a correction in the model that the user has authorised from somewhere else in the system (such as from the compilier).  The user's selection is not changed, only corrected."
	| wasShowing userSelection delta loc |
	aString = '#insert period' ifTrue:
		[loc := start.
		[(loc := loc-1)>0 and: [(paragraph text string at: loc) isSeparator]]
			whileTrue: [loc := loc-1].
		^ self correctFrom: loc+1 to: loc with: '.'].
	(wasShowing := selectionShowing) ifTrue: [ self reverseSelection ].
	userSelection := self selectionInterval.

	self selectInvisiblyFrom: start to: stop.
	self replaceSelectionWith: aString asText.

	delta := aString size - (stop - start + 1).
	self selectInvisiblyFrom:
		userSelection first + (userSelection first > start ifFalse: [ 0 ] ifTrue: [ delta ])
		to: userSelection last + (userSelection last > start ifFalse: [ 0 ] ifTrue: [ delta ]).
	wasShowing ifTrue: [ self reverseSelection ].

]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> crWithIndent: characterStream [ 
	"Replace the current text selection with CR followed by as many tabs
	as on the current line (+/- bracket count) -- initiated by Shift-Return."
	| char s i tabCount |
	sensor keyboard.		"flush character"
	s := paragraph string.
	i := self stopIndex.
	tabCount := 0.
	[(i := i-1) > 0 and: [(char := s at: i) ~= Character cr and: [char ~= Character lf]]]
		whileTrue:  "Count tabs and brackets (but not a leading bracket)"
		[(char = Character tab and: [i < s size and: [(s at: i+1) ~= $[ ]]) ifTrue: [tabCount := tabCount + 1].
		char = $[ ifTrue: [tabCount := tabCount + 1].
		char = $] ifTrue: [tabCount := tabCount - 1]].
	characterStream crtab: tabCount.  "Now inject CR with tabCount tabs"
	^ false
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorDown: characterStream [ 

	"Private - Move cursor from position in current line to same position in
	next line. If next line too short, put at end. If shift key down,
	select."
	self closeTypeIn: characterStream.
	self 
		moveCursor:[:position | self
				sameColumn: position
				newLine:[:line | line + 1]
				forward: true]
		forward: true
		specialBlock:[:dummy | dummy].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorEnd: characterStream [ 

	"Private - Move cursor end of current line."
	| string |
	self closeTypeIn: characterStream.
	string := paragraph text string.
	self
		moveCursor:
			[:position | Preferences wordStyleCursorMovement
				ifTrue:[| targetLine |
					targetLine := paragraph lines at:(paragraph lineIndexOfCharacterIndex: position).
					targetLine = paragraph lines last
						ifTrue:[targetLine last + 1]
						ifFalse:[targetLine last]]
				ifFalse:[
					string
						indexOfAnyOf: CharacterSet crlf
						startingAt: position
						ifAbsent:[string size + 1]]]
		forward: true
		specialBlock:[:dummy | string size + 1].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorHome: characterStream [ 

	"Private - Move cursor from position in current line to beginning of
	current line. If control key is pressed put cursor at beginning of text"

	| string |

	string := paragraph text string.
	self
		moveCursor: [ :position | Preferences wordStyleCursorMovement
				ifTrue:[
					(paragraph lines at:(paragraph lineIndexOfCharacterIndex: position)) first]
				ifFalse:[
					(string
						lastIndexOfAnyOf: CharacterSet crlf
						startingAt: position - 1) + 1]]
		forward: false
		specialBlock: [:dummy | 1].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorLeft: characterStream [ 
	"Private - Move cursor left one character if nothing selected, otherwise 
	move cursor to beginning of selection. If the shift key is down, start 
	selecting or extending current selection. Don't allow cursor past 
	beginning of text"

	self closeTypeIn: characterStream.
	self
		moveCursor:[:position | position - 1 max: 1]
		forward: false
		specialBlock:[:position | self previousWord: position].
	^ true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorPageDown: characterStream [ 

	self closeTypeIn: characterStream.
	self 
		moveCursor: [:position |
			self
				sameColumn: position
				newLine:[:lineNo | lineNo + self pageHeight]
				forward: true]
		forward: true
		specialBlock:[:dummy | dummy].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorPageUp: characterStream [ 

	self closeTypeIn: characterStream.
	self 
		moveCursor: [:position |
			self
				sameColumn: position
				newLine:[:lineNo | lineNo - self pageHeight]
				forward: false]
		forward: false
		specialBlock:[:dummy | dummy].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorRight: characterStream [ 
	"Private - Move cursor right one character if nothing selected, 
	otherwise move cursor to end of selection. If the shift key is down, 
	start selecting characters or extending already selected characters. 
	Don't allow cursor past end of text"

	self closeTypeIn: characterStream.
	self
		moveCursor: [:position | position + 1]
		forward: true
		specialBlock:[:position | self nextWord: position].
	^ true
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> cursorTopHome: characterStream [ 
	"Put cursor at beginning of text -- invoked from cmd-H shortcut, useful for keyboards that have no home key."
	
	sensor keyboard.
	self selectAt: 1.
	^ true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> cursorUp: characterStream [ 

"Private - Move cursor from position in current line to same position in
prior line. If prior line too short, put at end"

	self closeTypeIn: characterStream.
	self
		moveCursor: [:position | self
				sameColumn: position
				newLine:[:line | line - 1]
				forward: false]
		forward: false
		specialBlock:[:dummy | dummy].
	^true
]

{ #category : #'menu messages' }
ParagraphEditor >> cut [
	"Cut out the current selection and redisplay the paragraph if necessary.  Undoer & Redoer: undoCutCopy:"

	self lineSelectAndEmptyCheck: [^ self].

	self replaceSelectionWith: self nullText. 
	self undoer: #undoCutCopy: with: self clipboardText.
	self clipboardTextPut: UndoSelection
]

{ #category : #'editing keys' }
ParagraphEditor >> cut: characterStream [ 
	"Cut out the current text selection.  Flushes typeahead."

	sensor keyboard.		"flush character"
	self cut.
	^true
]

{ #category : #'editing keys' }
ParagraphEditor >> debugIt: characterStream [ 
	sensor keyboard.	
	self terminateAndInitializeAround: [self debugIt].
	^ true
]

{ #category : #'current selection' }
ParagraphEditor >> deselect [
	"If the text selection is visible on the screen, reverse its highlight."

	selectionShowing ifTrue: [self reverseSelection]
]

{ #category : #parenblinking }
ParagraphEditor >> dispatchOnCharacter: char with: typeAheadStream [
	"Carry out the action associated with this character, if any.
	Type-ahead is passed so some routines can flush or use it."

	| honorCommandKeys result |
	self clearParens.
  
	"mikki 1/3/2005 21:31 Preference for auto-indent on return added."
	char asciiValue = 13 ifTrue: [
		^Preferences autoIndent 
			ifTrue: [
				sensor controlKeyPressed
					ifTrue: [self normalCharacter: typeAheadStream]
					ifFalse: [self crWithIndent: typeAheadStream]]
			ifFalse: [
				sensor controlKeyPressed
					ifTrue: [self crWithIndent: typeAheadStream]
					ifFalse: [self normalCharacter: typeAheadStream]]].

	((honorCommandKeys := Preferences cmdKeysInText) and: [char = Character enter])
		ifTrue: [^ self dispatchOnEnterWith: typeAheadStream].

	(char = Character tab and: [ self selection notEmpty ]) ifTrue: [ self tabOrIndent: typeAheadStream ].

	"Special keys overwrite crtl+key combinations - at least on Windows. To resolve this
	conflict, assume that keys other than cursor keys aren't used together with Crtl." 
	((self class specialShiftCmdKeys includes: char asciiValue) and: [char asciiValue < 27])
		ifTrue: [^ sensor controlKeyPressed
			ifTrue: [self perform: (ShiftCmdActions at: char asciiValue + 1) with: typeAheadStream]
			ifFalse: [self perform: (CmdActions at: char asciiValue + 1) with: typeAheadStream]].

	"backspace, and escape keys (ascii 8 and 27) are command keys"
	((honorCommandKeys and: [sensor commandKeyPressed]) or: [self class specialShiftCmdKeys includes: char asciiValue]) ifTrue:
		[^ sensor leftShiftDown
			ifTrue:
				[self perform: (ShiftCmdActions at: char asciiValue + 1 ifAbsent: [#noop:]) with: typeAheadStream]
			ifFalse:
				[self perform: (CmdActions at: char asciiValue + 1 ifAbsent: [#noop:]) with: typeAheadStream]].

	"the control key can be used to invoke shift-cmd shortcuts"
	(honorCommandKeys and: [sensor controlKeyPressed])
		ifTrue:
			[^ self perform: (ShiftCmdActions at: char asciiValue + 1 ifAbsent: [#noop:]) with: typeAheadStream].

	result := self normalCharacter: typeAheadStream.
	
	(')]}' includes: char)
		ifTrue: [self blinkPrevParen: char ].
	^result
]

{ #category : #'typing support' }
ParagraphEditor >> dispatchOnEnterWith: typeAheadStream [
	"Enter key hit.  Treat is as an 'accept', viz a synonym for cmd-s.  If cmd key is down, treat is as a synonym for print-it. "

	sensor keyboard.  "consume enter key"
	self terminateAndInitializeAround: [
	sensor commandKeyPressed
		ifTrue:
			[self printIt.]
		ifFalse: 
			[self closeTypeIn: typeAheadStream.
			self accept].
	].
	^ true
]

{ #category : #displaying }
ParagraphEditor >> display [
	"Redisplay the paragraph."

	| selectionState |
	selectionState := selectionShowing.
	self deselect.
	paragraph foregroundColor: view foregroundColor
			backgroundColor: view backgroundColor;
			displayOn: Display.
	selectionState ifTrue: [self select]
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> displayIfFalse: characterStream [ 
	"Replace the current text selection with the text 'ifFalse:'--initiated by 
	ctrl-f."

	sensor keyboard.		"flush character"
	characterStream nextPutAll: 'ifFalse:'.
	^false
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> displayIfTrue: characterStream [ 
	"Replace the current text selection with the text 'ifTrue:'--initiated by 
	ctrl-t."

	sensor keyboard.		"flush character"
	characterStream nextPutAll: 'ifTrue:'.
	^false
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> doAgainMany: characterStream [ 
	"Do the previous thing again repeatedly. 1/26/96 sw"

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self againOrSame: (UndoMessage sends: #undoAgain:andReselect:typedKey:) many: true.
	^ true
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> doAgainOnce: characterStream [ 
	"Do the previous thing again once. 1/26/96 sw"

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self again.
	^ true
]

{ #category : #'do-its' }
ParagraphEditor >> doIt [
	"Set the context to include pool vars of the model.  Then evaluate."
	^ self evaluateSelection.

]

{ #category : #'editing keys' }
ParagraphEditor >> doIt: characterStream [ 
	"Called when user hits cmd-d.  Select the current line, if relevant, then evaluate and execute.  2/1/96 sw.
	2/29/96 sw: don't call selectLine; it's done by doIt now"

	sensor keyboard.	
	self terminateAndInitializeAround: [self doIt].
	^ true
]

{ #category : #'typing support' }
ParagraphEditor >> doneTyping [
	beginTypeInBlock := nil
]

{ #category : #'editing keys' }
ParagraphEditor >> enclose: characterStream [
	"Insert or remove bracket characters around the current selection.
	 Flushes typeahead."

	| char left right startIndex stopIndex oldSelection which text |
	char := sensor keyboard.
	self closeTypeIn.
	startIndex := self startIndex.
	stopIndex := self stopIndex.
	oldSelection := self selection.
	which := '([<{|"''' indexOf: char ifAbsent: [ ^true ].
	left := '([<{|"''' at: which.
	right := ')]>}|"''' at: which.
	text := paragraph text.
	((startIndex > 1 and: [stopIndex <= text size])
		and:
		[(text at: startIndex-1) = left and: [(text at: stopIndex) = right]])
		ifTrue:
			["already enclosed; strip off brackets"
			self selectFrom: startIndex-1 to: stopIndex.
			self replaceSelectionWith: oldSelection]
		ifFalse:
			["not enclosed; enclose by matching brackets"
			self replaceSelectionWith:
				(Text string: (String with: left), oldSelection string ,(String with: right)
					emphasis: emphasisHere).
			self selectFrom: startIndex+1 to: stopIndex].
	^true
]

{ #category : #'new selection' }
ParagraphEditor >> encompassLine: anInterval [
	"Return an interval that encompasses the entire line"
	| string left right |
	string := paragraph text string.
	left := (string lastIndexOfAnyOf: CharacterSet crlf startingAt: anInterval first - 1) + 1.
	right := (string indexOfAnyOf: CharacterSet crlf startingAt: anInterval last + 1 ifAbsent: [string size + 1]) - 1.
	^left to: right
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> escapeToDesktop: characterStream [ 
	"Pop up a morph to field keyboard input in the context of the desktop"

	Smalltalk isMorphic ifTrue: [
		Project current world putUpWorldMenuFromEscapeKey].
	^ true
]

{ #category : #'do-its' }
ParagraphEditor >> evaluateSelection [
	"Treat the current selection as an expression; evaluate it and return the result"
	
	^self evaluateSelectionAndDo: [:result | result]
]

{ #category : #'do-its' }
ParagraphEditor >> evaluateSelectionAndDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	| result rcvr ctxt |
	self lineSelectAndEmptyCheck: [^ nil].

	(model respondsTo: #doItReceiver) 
		ifTrue: [ rcvr := model doItReceiver.
				ctxt := model doItContext]
		ifFalse: [rcvr := ctxt := nil].
	result := [
		rcvr class evaluatorClass new 
			evaluate: self selectionAsStream
			in: ctxt
			to: rcvr
			notifying: self
			ifFail: [self flash. ^nil]
			logged: true.
	] 
		on: OutOfScopeNotification 
		do: [ :ex | ex resume: true].
	^aBlock value: result
]

{ #category : #'menu messages' }
ParagraphEditor >> exchange [
	"See comment in exchangeWith:"

	self exchangeWith: otherInterval
]

{ #category : #'editing keys' }
ParagraphEditor >> exchange: characterStream [
	"Exchange the current and prior selections.  Keeps typeahead."

	sensor keyboard.	 "Flush character"
	self closeTypeIn: characterStream.
	self exchange.
	^true
]

{ #category : #private }
ParagraphEditor >> exchangeWith: prior [
	"If the prior selection is non-overlapping and legal, exchange the text of
	 it with the current selection and leave the currently selected text selected
	 in the location of the prior selection (or leave a caret after a non-caret if it was
	 exchanged with a caret).  If both selections are carets, flash & do nothing.
	 Don't affect the paste buffer.  Undoer: itself; Redoer: Undoer."

	| start stop before selection priorSelection delta altInterval |
	start := self startIndex.
	stop := self stopIndex - 1.
	((prior first <= prior last) | (start <= stop) "Something to exchange" and:
			[self isDisjointFrom: prior])
		ifTrue:
			[before := prior last < start.
			selection := self selection.
			priorSelection := paragraph text copyFrom: prior first to: prior last.

			delta := before ifTrue: [0] ifFalse: [priorSelection size - selection size].
			self zapSelectionWith: priorSelection.
			self selectFrom: prior first + delta to: prior last + delta.

			delta := before ifTrue: [stop - prior last] ifFalse: [start - prior first].
			self zapSelectionWith: selection.
			altInterval := prior first + delta to: prior last + delta.
			self undoer: #exchangeWith: with: altInterval.
			"If one was a caret, make it otherInterval & leave the caret after the other"
			prior first > prior last ifTrue: [self selectAt: UndoInterval last + 1].
			otherInterval := start > stop
				ifTrue: [self selectAt: altInterval last + 1. UndoInterval]
				ifFalse: [altInterval]]
		ifFalse:
			[view flash]
]

{ #category : #'menu messages' }
ParagraphEditor >> experimentalCommand [
	"Use for experimental command-key implementation.  Using this, 
	you can try things out without forever needing to reinitialize the 
	ParagraphEditor."

	self prettyPrint.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> explain [
	"Try to shed some light on what kind of entity the current selection
is. 
	The selection must be a single token or construct. Insert the answer
after 
	the selection. Send private messages whose names begin with 'explain' 
	that return a string if they recognize the selection, else nil."

	
Cursor execute showWhile: 
			[ | symbol string delimitors reply numbers tiVars selectors sorry cgVars |
			sorry := '"Sorry, I can''t explain that.  Please select a single
token, construct, or special character.'.
			sorry := sorry , (view canDiscardEdits
							ifFalse: ['  Also, please cancel or accept."']
							ifTrue: ['"']).
			(string := self selection asString) isEmpty
				ifTrue: [reply := '']
				ifFalse: [string := self explainScan: string.
					"Remove space, tab, cr"
					"Temps and Instance vars need only test strings that are all
letters"
					(string detect: [:char | (char isLetter or: [char isDigit]) not]
						ifNone: []) ifNil: 
							[tiVars := self explainTemp: string.
							tiVars == nil ifTrue: [tiVars := self explainInst: string]].
					(tiVars == nil and: [model respondsTo: #explainSpecial:])
						ifTrue: [tiVars := model explainSpecial: string].
					tiVars == nil
						ifTrue: [tiVars := '']
						ifFalse: [tiVars := tiVars , '\' withCRs].
					"Context, Class, Pool, and Global vars, and Selectors need 
					only test symbols"
					(Symbol hasInterned: string ifTrue: [:s | symbol := s])
						ifTrue: [cgVars := self explainCtxt: symbol.
							cgVars == nil
								ifTrue: [cgVars := self explainClass: symbol.
									cgVars == nil ifTrue: [cgVars := self explainGlobal: symbol]].
							"See if it is a Selector (sent here or not)"
							selectors := self explainMySel: symbol.
							selectors == nil
								ifTrue: 
									[selectors := self explainPartSel: string.
									selectors == nil ifTrue: [
										selectors := self explainAnySel: symbol]]]
						ifFalse: [selectors := self explainPartSel: string].
					cgVars == nil
						ifTrue: [cgVars := '']
						ifFalse: [cgVars := cgVars , '\' withCRs].
					selectors == nil
						ifTrue: [selectors := '']
						ifFalse: [selectors := selectors , '\' withCRs].
					string size = 1
						ifTrue: ["single special characters"
							delimitors := self explainChar: string]
						ifFalse: ["matched delimitors"
							delimitors := self explainDelimitor: string].
					numbers := self explainNumber: string.
					numbers == nil ifTrue: [numbers := ''].
					delimitors == nil ifTrue: [delimitors := ''].
					reply := tiVars , cgVars , selectors , delimitors , numbers].
			reply size = 0 ifTrue: [reply := sorry].
			self afterSelectionInsertAndSelect: reply]
]

{ #category : #explain }
ParagraphEditor >> explainAnySel: symbol [ 
	"Is this any message selector?"

	| list reply |
	list := self systemNavigation allClassesImplementing: symbol.
	list size = 0 ifTrue: [^nil].
	list size < 12
		ifTrue: [reply := ' is a message selector which is defined in these classes: ' , list asArray printString]
		ifFalse: [reply := ' is a message selector which is defined in many classes'].
	^'"' , symbol , reply , '."' , '\' withCRs, 'SystemNavigation new browseAllImplementorsOf: #' , symbol
]

{ #category : #explain }
ParagraphEditor >> explainChar: string [
	"Does string start with a special character?"

	| char |
	char := string at: 1.
	char = $. ifTrue: [^'"Period marks the end of a Smalltalk statement.  A period in the middle of a number means a decimal point.  (The number is an instance of class Float)."'].
	char = $' ifTrue: [^'"The characters between two single quotes are made into an instance of class String"'].
	char = $" ifTrue: [^'"Double quotes enclose a comment.  Smalltalk ignores everything between double quotes."'].
	char = $# ifTrue: [^'"The characters following a hash mark are made into an instance of class Symbol.  If parenthesis follow a hash mark, an instance of class Array is made.  It contains literal constants."'].
	(char = $( or: [char = $)]) ifTrue: [^'"Expressions enclosed in parenthesis are evaluated first"'].
	(char = $[ or: [char = $]]) ifTrue: [^'"The code inside square brackets is an unevaluated block of code.  It becomes an instance of BlockClosure and is usually passed as an argument."'].
	(char = ${ or: [char = $}]) ifTrue: [^ '"A sequence of expressions separated by periods, when enclosed in curly braces, are evaluated to yield the elements of a new Array"'].
	(char = $< or: [char = $>]) ifTrue: [^'"<primitive: xx> means that this method is usually preformed directly by the virtual machine.  If this method is primitive, its Smalltalk code is executed only when the primitive fails."'].
	char = $^ ifTrue: [^'"Uparrow means return from this method.  The value returned is the expression following the ^"'].
	char = $| ifTrue: [^'"Vertical bars enclose the names of the temporary variables used in this method.  In a block, the vertical bar separates the argument names from the rest of the code."'].
	char = $_ ifTrue: [^'"Left arrow means assignment.  The value of the expression after the left arrow is stored into the variable before it."'].
	char = $; ifTrue: [^'"Semicolon means cascading.  The message after the semicolon is sent to the same object which received the message before the semicolon."'].
	char = $: ifTrue: [^'"A colon at the end of a keyword means that an argument is expected to follow.  Methods which take more than one argument have selectors with more than one keyword.  (One keyword, ending with a colon, appears before each argument).', '\\' withCRs, 'A colon before a variable name just inside a block means that the block takes an agrument.  (When the block is evaluated, the argument will be assigned to the variable whose name appears after the colon)."'].
	char = $$ ifTrue: [^'"The single character following a dollar sign is made into an instance of class Character"'].
	char = $- ifTrue: [^'"A minus sign in front of a number means a negative number."'].
	char = $e ifTrue: [^'"An e in the middle of a number means that the exponent follows."'].
	char = $r ifTrue: [^'"An r in the middle of a bunch of digits is an instance of Integer expressed in a certain radix.  The digits before the r denote the base and the digits after it express a number in that base."'].
	char = Character space ifTrue: [^'"the space Character"'].
	char = Character tab ifTrue: [^'"the tab Character"'].
	char = Character cr ifTrue: [^'"the carriage return Character"'].
	char = Character lf ifTrue: [^'"the line feed Character"'].
	^nil
]

{ #category : #explain }
ParagraphEditor >> explainClass: symbol [ 
	"Is symbol a class variable or a pool variable?"
	| class reply classes |
	self flag: #environments.
	(model respondsTo: #selectedClassOrMetaClass)
		ifFalse: [^ nil].
	(class := model selectedClassOrMetaClass) ifNil: [^ nil].
	"no class is selected"
	(class isKindOf: Metaclass)
		ifTrue: [class := class soleInstance].
	classes := (Array with: class)
				, class allSuperclasses.
	"class variables"
	reply := classes detect: [:each | (each classVarNames detect: [:name | symbol = name]
					ifNone: [])
					~~ nil]
				ifNone: [].
	reply == nil ifFalse: [^ '"is a class variable, defined in class ' , reply printString , '"\' withCRs , 'SystemNavigation new browseAllCallsOn: (' , reply printString , ' classPool associationAt: #' , symbol , ').'].
	"pool variables"
	classes do: [:each | (each sharedPools
			detect: [:pool | (pool includesKey: symbol)
					and: 
						[reply := pool.
						true]]
			ifNone: [])
			~~ nil].
	reply
		ifNil: [(class environment isUndeclared: symbol)
				ifTrue: [^ '"is an undeclared variable.' , '"\' withCRs , 'SystemNavigation new browseAllCallsOn: (Undeclared associationAt: #' , symbol , ').']]
		ifNotNil: 
			[classes := WriteStream on: Array new.
			self systemNavigation
				allBehaviorsDo: [:each | (each sharedPools
						detect: 
							[:pool | 
							pool == reply]
						ifNone: [])
						~~ nil ifTrue: [classes nextPut: each]].
			"Perhaps not print whole list of classes if too long. (unlikely)"
			^ '"is a pool variable from the pool ' , (Smalltalk globals keyAtIdentityValue: reply) asString , ', which is used by the following classes ' , classes contents printString , '"\' withCRs , 'SystemNavigation new browseAllCallsOn: (' , (Smalltalk globals keyAtIdentityValue: reply) asString , ' bindingOf: #' , symbol , ').'].
	^ nil
]

{ #category : #explain }
ParagraphEditor >> explainCtxt: symbol [ 
	"Is symbol a context variable?"

	| reply classes text cls |
	symbol = #nil ifTrue: [reply := '"is a constant.  It is the only instance of class UndefinedObject.  nil is the initial value of all variables."'].
	symbol = #true ifTrue: [reply := '"is a constant.  It is the only instance of class True and is the receiver of many control messages."'].
	symbol = #false ifTrue: [reply := '"is a constant.  It is the only instance of class False and is the receiver of many control messages."'].
	symbol = #thisContext ifTrue: [reply := '"is a context variable.  Its value is always the Context which is executing this method."'].
	(model respondsTo: #selectedClassOrMetaClass) ifTrue: [
		cls := model selectedClassOrMetaClass].
	cls ifNil: [^ reply].	  "no class known"
	symbol = #self ifTrue: 
			[classes := cls withAllSubclasses.
			classes size > 12
				ifTrue: [text := cls printString , ' or a subclass']
				ifFalse: 
					[classes := classes printString.
					text := 'one of these classes' , (classes copyFrom: 4 to: classes size)].
			reply := '"is the receiver of this message; an instance of ' , text , '"'].
	symbol = #super ifTrue: [reply := '"is just like self.  Messages to super are looked up in the superclass (' , cls superclass printString , ')"'].
	^reply
]

{ #category : #private }
ParagraphEditor >> explainDelimitor: string [
	"Is string enclosed in delimitors?"

	| str |
	(string at: 1) isLetter ifTrue: [^nil].  "only special chars"
	(string first = string last) ifTrue:
			[^ self explainChar: (String with: string first)]
		ifFalse:
			[(string first = $( and: [string last = $)]) ifTrue:
				[^ self explainChar: (String with: string first)].
			(string first = $[ and: [string last = $]]) ifTrue:
				[^ self explainChar: (String with: string first)].
			(string first = ${ and: [string last = $}]) ifTrue:
				[^ self explainChar: (String with: string first)].
			(string first = $< and: [string last = $>]) ifTrue:
				[^ self explainChar: (String with: string first)].
			(string first = $# and: [string last = $)]) ifTrue:
				[^'"An instance of class Array.  The Numbers, Characters, Symbols or Arrays between the parenthesis are the elements of the Array."'].
			string first = $# ifTrue:
				[^'"An instance of class Symbol."'].
			(string first = $$ and: [string size = 2]) ifTrue:
				[^'"An instance of class Character.  This one is the character ', (String with: string last), '."'].
			(string first = $:) ifTrue:
				[string = ':=' ifTrue:
					[^'"Colon equals means assignment.  The value of the expression after the := is stored into the variable before it."'].
				str := string allButFirst.
				(self explainTemp: str) ifNotNil:
					[^'"An argument to this block will be bound to the temporary variable ', str, '."']]].
	^ nil
]

{ #category : #explain }
ParagraphEditor >> explainGlobal: symbol [ 
	"Is symbol a global variable?"
	| reply classes |
	reply := Smalltalk at: symbol ifAbsent: [^nil].
	(reply class == Dictionary or:[reply isKindOf: SharedPool class])
		ifTrue: 
			[classes := Set new.
			self systemNavigation allBehaviorsDo: [:each | (each sharedPools anySatisfy: [:pool | pool == reply])
					ifTrue: [classes add: each]].
			classes := classes printString.
			^'"is a global variable.  It is a pool which is used by the following classes ' , (classes allButFirst: 5) , '"'].
	(reply isKindOf: Behavior)
		ifTrue: [^'"is a global variable.  ' , symbol , ' is a class in category ', reply category,
			'."', '\' withCRs, 'Browser newOnClass: ' , symbol , '.'].
	symbol == #Smalltalk ifTrue: [^'"is a global.  Smalltalk is the only instance of SystemDictionary and holds all global variables."'].
	^'"is a global variable.  ' , symbol , ' is ' , reply printString , '"'
]

{ #category : #explain }
ParagraphEditor >> explainInst: string [ 
	"Is string an instance variable of this class?"
	| classes cls |

	(model respondsTo: #selectedClassOrMetaClass) ifTrue: [
		cls := model selectedClassOrMetaClass].
	cls ifNil: [^ nil].	  "no class known"
	classes := (Array with: cls)
				, cls allSuperclasses.
	classes := classes detect: [:each | each instVarNames
			anySatisfy: [:name | name = string] ] ifNone: [^nil].
	classes := classes printString.
	^ '"is an instance variable of the receiver; defined in class ' , classes , 
		'"\' withCRs , classes , ' systemNavigation browseAllAccessesTo: ''' , string , ''' from: ', classes, '.'
]

{ #category : #explain }
ParagraphEditor >> explainMySel: symbol [ 
	"Is symbol the selector of this method?  Is it sent by this method?  If 
	not, then expalin will call (explainPartSel:) to see if it is a fragment of a 
	selector sent here.  If not, explain will call (explainAnySel:) to catch any 
	selector. "

	| lits classes msg |
	(model respondsTo: #selectedMessageName) ifFalse: [^ nil].
	(msg := model selectedMessageName) ifNil: [^nil].	"not in a message"
	classes := self systemNavigation allClassesImplementing: symbol.
	classes size > 12
		ifTrue: [classes := 'many classes']
		ifFalse: [classes := 'these classes ' , classes printString].
	msg = symbol
		ifTrue: [^ '"' , symbol , ' is the selector of this very method!  It is defined in ',
			classes , '.  To see the other definitions, go to the message list pane, get the menu from the top of the scroll bar, and select ''implementors of...''."']
		ifFalse: 
			[lits := (model selectedClassOrMetaClass compiledMethodAt:
				msg) messages.
			(lits anySatisfy: [:each | each == symbol])
				ifFalse: [^nil].
			^ '"' , symbol , ' is a message selector which is defined in ', classes , '.  To see the definitions, go to the message list pane, get the menu from the top of the scroll bar, and select ''implementors of...''."'].
]

{ #category : #explain }
ParagraphEditor >> explainNumber: string [ 
	"Is string a Number?"

	| strm c |
	(c := string at: 1) isDigit ifFalse: [(c = $- and: [string size > 1 and: [(string at: 2) isDigit]])
			ifFalse: [^nil]].
	strm := ReadStream on: string.
	c := Number readFrom: strm.
	strm atEnd ifFalse: [^nil].
	c printString = string
		ifTrue: [^'"' , string , ' is a ' , c class name , '"']
		ifFalse: [^'"' , string , ' (= ' , c printString , ') is a ' , c class name , '"']
]

{ #category : #explain }
ParagraphEditor >> explainPartSel: string [ 
	"Is this a fragment of a multiple-argument selector sent in this method?"
	| lits whole reply classes s msg |

	(model respondsTo: #selectedMessageName) ifFalse: [^ nil].
	(msg := model selectedMessageName) ifNil: [^ nil].  "not in a message"
	string last == $: ifFalse: [^ nil].
	"Name of this method"
	lits := Array with: msg.
	(whole := lits detect: [:each | each keywords anySatisfy: [:frag | frag = string] ]
				ifNone: []) ~~ nil
		ifTrue: [reply := ', which is the selector of this very method!'.
			s := '.  To see the other definitions, go to the message list pane, get the menu from the top of the scroll bar, and select ''implementors of...''."']
		ifFalse: 
			["Selectors called from this method"
			lits := (model selectedClassOrMetaClass compiledMethodAt:
				msg) messages.
			(whole := lits detect: [:each | each keywords anySatisfy: [:frag | frag = string] ]
						ifNone: []) ~~ nil
				ifFalse: [string = 'primitive:'
					ifTrue: [^self explainChar: '<']
					ifFalse: [^nil]].
			reply := '.'.
			s := '.  To see the definitions, go to the message list pane, get the menu from the top of the scroll bar, and select ''implementors of...''."'].
	classes := self systemNavigation allClassesImplementing: whole.
	classes size > 12
		ifTrue: [classes := 'many classes']
		ifFalse: [classes := 'these classes ' , classes printString].
	^ '"' , string , ' is one part of the message selector ' , whole, reply , '  It is defined in ' , classes , s
]

{ #category : #explain }
ParagraphEditor >> explainScan: string [ 
	"Remove beginning and trailing separators (space, tab, cr,...)"

	^string withBlanksTrimmed
]

{ #category : #explain }
ParagraphEditor >> explainTemp: string [ 
	"Is string the name of a temporary variable (method or block argument or temporary)?"

	| selectedClass methodNode tempNode |
	(model respondsTo: #selectedMessageName) ifFalse: [^ nil].
	model selectedMessageName ifNil: [^nil].	"not in a method"
	selectedClass := model selectedClassOrMetaClass.
	methodNode := selectedClass newParser parse: model selectedMessage class: selectedClass.
	tempNode := methodNode encoder tempNodes detect: [:n| n name = string] ifNone: [^nil].
	^(tempNode isArg
		ifTrue: ['"is an argument to this ']
		ifFalse: ['"is a temporary variable in this ']),
	   (tempNode isDeclaredAtMethodLevel
		ifTrue: ['method"']
		ifFalse: ['block"'])
]

{ #category : #'do-its' }
ParagraphEditor >> exploreIt [
	self evaluateSelectionAndDo: [:result | result explore]

]

{ #category : #'editing keys' }
ParagraphEditor >> exploreIt: characterStream [ 
	"Explore the selection -- invoked via cmd-shift-I.  If there is no current selection, use the current line."

	sensor keyboard.		"flush character"
	self terminateAndInitializeAround: [self exploreIt].
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> fileItIn [
	"Make a Stream on the text selection and fileIn it.
	 1/24/96 sw: moved here from FileController; this function can be useful from any text window that shows stuff in chunk format"

	| selection |
	selection := self selection.
	self terminateAndInitializeAround:
		[(ReadStream on: selection string from: 1 to: selection size) fileIn].

]

{ #category : #'editing keys' }
ParagraphEditor >> fileItIn: characterStream [ 
	"File in the selection; invoked via a keyboard shortcut, -- for now, cmd-shift-G."

	sensor keyboard.		"flush character"
	self terminateAndInitializeAround: [self fileItIn].
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> find [
	"Prompt the user for a string to search for, and search the receiver from the current selection onward for it.  1/26/96 sw"

	| reply |
	reply := UIManager default request: 'Find what? ' translated initialAnswer: ''.
	reply size = 0 ifTrue: [^ self].
	self setSearch: reply.
	ChangeText := FindText.  "Implies no replacement to againOnce: method"
	self againOrSame: true
	

]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> find: characterStream [
	"Prompt the user for what to find, then find it, searching from the current selection onward.  1/24/96 sw"

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self find.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> findAgain [
	"Find the text-to-find again.  1/24/96 sw"

	self againOrSame: true
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> findAgain: characterStream [ 
	"Find the desired text again.  1/24/96 sw"

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self findAgain.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> findReplace [

	(Project uiManager
		request: 'Find what to replace?'
		initialAnswer: FindText)
			ifNotEmpty: [:find |

				(Project uiManager
					request: ('Replace ''{1}'' with?' format: {find})
					initialAnswer: (ChangeText ifEmpty: [find])
					onCancelReturn: nil)
						ifNotNil: [:replace |

							FindText := find.
							ChangeText := replace.
							self againOrSame: true ]]
]

{ #category : #'menu messages' }
ParagraphEditor >> fit [
	"Make the bounding rectangle of the paragraph contain all the text while 
	 not changing the width of the view of the paragraph.  No effect on undoability
	 of the preceding command."

	paragraph clearVisibleRectangle.
	paragraph fit.
	paragraph displayOn: Display; outline.
	self recomputeInterval
]

{ #category : #displaying }
ParagraphEditor >> flash [
	"Causes the view of the paragraph to complement twice in succession."

	paragraph flash
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> forwardDelete: characterStream [
	"Delete forward over the next character.
	  Make Undo work on the whole type-in, not just the one char.
	wod 11/3/1998: If there was a selection use #zapSelectionWith: rather than #backspace: which was 'one off' in deleting the selection. Handling of things like undo or typeIn area were not fully considered."
	| startIndex usel upara uinterval ind stopIndex |
	startIndex := self mark.
	startIndex > paragraph text size ifTrue:
		[sensor keyboard.
		^ false].
	self hasSelection ifTrue:
		["there was a selection"
		sensor keyboard.
		self zapSelectionWith: self nullText.
		^ false].
	"Null selection - do the delete forward"
	beginTypeInBlock == nil	"no previous typing.  openTypeIn"
		ifTrue: [self openTypeIn. UndoSelection := self nullText].
	uinterval := UndoInterval deepCopy.
	upara := UndoParagraph deepCopy.
	stopIndex := startIndex.
	(sensor keyboard asciiValue = 127 and: [sensor leftShiftDown])
		ifTrue: [stopIndex := (self firstWordBoundaryAfter: stopIndex) - 1].
	self selectFrom: startIndex to: stopIndex.
	self replaceSelectionWith: self nullText.
	self selectFrom: startIndex to: startIndex-1.
	UndoParagraph := upara.  UndoInterval := uinterval.
	UndoMessage selector == #noUndoer ifTrue: [
		(UndoSelection isText) ifTrue: [
			usel := UndoSelection.
			ind := startIndex. "UndoInterval startIndex"
			usel replaceFrom: usel size + 1 to: usel size with:
				(UndoParagraph text copyFrom: ind to: ind).
			UndoParagraph text replaceFrom: ind to: ind with:
self nullText]].
	^false
]

{ #category : #private }
ParagraphEditor >> getPluggableYellowButtonMenu: shiftKeyState [
	| customMenu |
	^ ((view ~~ nil) and: [(customMenu := view getMenu: shiftKeyState) notNil])
		ifTrue: [customMenu]
		ifFalse:
			[shiftKeyState
				ifTrue: [self class shiftedYellowButtonMenu]
				ifFalse: [self class yellowButtonMenu]]
]

{ #category : #'accessing-selection' }
ParagraphEditor >> hasCaret [
	^self markBlock = self pointBlock
]

{ #category : #'accessing-selection' }
ParagraphEditor >> hasSelection [
	^self hasCaret not
]

{ #category : #'editing keys' }
ParagraphEditor >> hiddenInfo [
	"In TextLinks, TextDoits, TextColor, and TextURLs, there is hidden info.  Return the entire string that was used by Cmd-6 to create this text attribute.  Usually enclosed in < >."

	| attrList |
	attrList := paragraph text attributesAt: (self pointIndex +
self markIndex)//2 forStyle: paragraph textStyle.
	attrList do: [:attr |
		(attr isKindOf: TextAction) ifTrue:
			[^ self selection asString, '<', attr info, '>']].
	"If none of the above"
	attrList do: [:attr |
		attr class == TextColor ifTrue:
			[^ self selection asString, '<', attr color printString, '>']].
	^ self selection asString, '[No hidden info]'
]

{ #category : #'menu messages' }
ParagraphEditor >> implementorsOfIt [
	"Open an implementors browser on the selected selector"

	| aSelector |
	self lineSelectAndEmptyCheck: [^ self].
	(aSelector := self selectedSelector) == nil ifTrue: [^ view flash].
	self terminateAndInitializeAround: [ self systemNavigation browseAllImplementorsOf: aSelector]
]

{ #category : #'editing keys' }
ParagraphEditor >> implementorsOfIt: characterStream [ 
	"Triggered by Cmd-m; browse implementors of the selector represented by the current selection, if plausible. 2/1/96 sw"

	sensor keyboard.		"flush character"
	self implementorsOfIt.
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> inOutdent: characterStream delta: delta [
	"Add/remove a tab at the front of every line occupied by the selection. Flushes typeahead.  Derived from work by Larry Tesler back in December 1985.  Now triggered by Cmd-L and Cmd-R.  2/29/96 sw"

	| realStart realStop lines startLine stopLine start stop adjustStart "indentation" numLines oldText newText newSize |
	sensor keyboard.  "Flush typeahead"

	"Operate on entire lines, but remember the real selection for re-highlighting later"
	realStart := self startIndex.
	realStop := self stopIndex - 1.

	"Special case a caret on a line of its own, including weird case at end of paragraph"
	(realStart > realStop and:
				[realStart < 2 or: [(paragraph string at: realStart - 1) == Character cr or: [(paragraph string at: realStart - 1) == Character lf]]])
		ifTrue:
			[delta < 0
				ifTrue:
					[view flash]
				ifFalse:
					[self replaceSelectionWith: Character tab asSymbol asText.
					self selectAt: realStart + 1].
			^true].

	lines := paragraph lines.
	startLine := paragraph lineIndexOfCharacterIndex: realStart.
	"start on a real line, not a wrapped line"
	[startLine = 1 or: [CharacterSet crlf includes: (paragraph string at: (lines at: startLine-1) last)]] whileFalse: [startLine := startLine - 1].
	stopLine := paragraph lineIndexOfCharacterIndex: (realStart max: realStop).
	start := (lines at: startLine) first.
	stop := (lines at: stopLine) last.
	
	"Pin the start of highlighting unless the selection starts a line"
	adjustStart := realStart > start.

	"Find the indentation of the least-indented non-blank line; never outdent more"
	"indentation := (startLine to: stopLine) inject: 1000 into:
		[:m :l |
		m min: (paragraph indentationOfLineIndex: l ifBlank: [:tabs | 1000])].
	indentation + delta <= 0 ifTrue: [^false]."

	numLines := stopLine + 1 - startLine.
	oldText := paragraph text copyFrom: start to: stop.
	newText := oldText species new: oldText size + ((numLines * delta) max: 0).

	"Do the actual work"
	newSize := 0.
	delta > 0
		ifTrue: [| tabs |
			tabs := oldText species new: delta withAll: Character tab.
			oldText string lineIndicesDo: [:startL :endWithoutDelimiters :endL |
				startL < endWithoutDelimiters ifTrue: [newText replaceFrom: 1 + newSize to: (newSize := newSize + delta) with: tabs startingAt: 1].
				newText replaceFrom: 1 + newSize to: (newSize := 1 + newSize + endL - startL) with: oldText startingAt: startL]]
		ifFalse: [| tab |
			tab := Character tab.
			oldText string lineIndicesDo: [:startL :endWithoutDelimiters :endL |
				| i |
				i := 0.
				[i + delta < 0 and: [ i + startL <= endWithoutDelimiters and: [(oldText at: i + startL) == tab]]] whileTrue: [i := i + 1].
				newText replaceFrom: 1 + newSize to: (newSize := 1 + newSize + endL - (i + startL)) with: oldText startingAt: i + startL]].
	newSize < newText size ifTrue: [newText := newText copyFrom: 1 to: newSize].
	
	"Adjust the range that will be highlighted later"
	adjustStart ifTrue: [realStart := (realStart + delta) max: start].
	realStop := realStop + newSize - oldText size.

	"Replace selection"
	self selectInvisiblyFrom: start to: stop.
	self replaceSelectionWith: newText.
	self selectFrom: realStart to: realStop. 	"highlight only the original range"
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> indent: characterStream [
	"Add a tab at the front of every line occupied by the selection. Flushes typeahead.  Invoked from keyboard via cmd-shift-R.  2/29/96 sw"

	^ self inOutdent: characterStream delta: 1
]

{ #category : #accessing }
ParagraphEditor >> initialText [
	^ initialText
]

{ #category : #'current selection' }
ParagraphEditor >> initializeSelection [
	"Do the initial activity when starting up the receiver. For example, in the 
	ParagraphEditor highlight the current selection."

	self select
]

{ #category : #'new selection' }
ParagraphEditor >> insertAndSelect: aString at: anInteger [

	self replace: (anInteger to: anInteger - 1)
		with: (Text string: (' ' , aString)
					attributes: emphasisHere)
		and: [self selectAndScroll]
]

{ #category : #'typing support' }
ParagraphEditor >> insertTypeAhead: typeAhead [
	typeAhead position = 0 ifFalse:
		[self zapSelectionWith: (Text string: typeAhead contents emphasis: emphasisHere).
		typeAhead reset.
		self unselect]
]

{ #category : #'do-its' }
ParagraphEditor >> inspectIt [
	self evaluateSelectionAndDo: [:result | ToolSet inspect: result].

]

{ #category : #'editing keys' }
ParagraphEditor >> inspectIt: characterStream [ 
	"Inspect the selection -- invoked via cmd-i.  If there is no current selection, use the current line.  1/17/96 sw
	 2/29/96 sw: don't call selectLine; it's done by inspectIt now"

	sensor keyboard.		"flush character"
	self terminateAndInitializeAround: [self inspectIt].
	^ true
]

{ #category : #private }
ParagraphEditor >> isDisjointFrom: anInterval [
	"Answer true if anInterval is a caret not touching or within the current
	 interval, or if anInterval is a non-caret that does not overlap the current
	 selection."

	| fudge |
	fudge := anInterval size = 0 ifTrue: [1] ifFalse: [0].
	^(anInterval last + fudge < self startIndex or:
			[anInterval first - fudge >= self stopIndex])

]

{ #category : #'undo support' }
ParagraphEditor >> isDoing [
	"Call from a doer/undoer/redoer any time to see which it is."

	^(self isUndoing | self isRedoing) not
]

{ #category : #'undo support' }
ParagraphEditor >> isRedoing [
	"Call from a doer/undoer/redoer any time to see which it is."

	^UndoParagraph == #redoing
]

{ #category : #'undo support' }
ParagraphEditor >> isUndoing [
	"Call from a doer/undoer/redoer any time to see which it is."

	^UndoParagraph == #undoing
]

{ #category : #'menu messages' }
ParagraphEditor >> lineSelectAndEmptyCheck: returnBlock [
	"If the current selection is an insertion point, expand it to be the entire current line; if after that's done the selection is still empty, then evaluate the returnBlock, which will typically consist of '[^ self]' in the caller -- check senders of this method to understand this."

	self hasSelection ifFalse: [
		self selectLine.
		self hasSelection ifFalse: [
			self flash. 
			^ returnBlock value]].
]

{ #category : #private }
ParagraphEditor >> lines [
	"Other than my member paragraph i compute lines based on logical
	line breaks, not optical (which may change due to line wrapping of the editor)"
	| lines string lineIndex |
	string := paragraph text string.
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

{ #category : #'editing keys' }
ParagraphEditor >> makeCapitalized: characterStream [ 
	"Force the current selection to be capitalized. Triggered by Cmd-Z."
	| prev |
	sensor keyboard.		"Flush the triggering cmd-key character"
	prev := $-.  "not a letter"
	self replaceSelectionWith: (Text fromString:
			(self selection string collect:
				[:c | prev := prev isLetter ifTrue: [c asLowercase] ifFalse: [c asUppercase]])).
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> makeLowercase: characterStream [ 
	"Force the current selection to lowercase.  Triggered by Cmd-X."

	sensor keyboard.		"flush the triggering cmd-key character"
	self replaceSelectionWith: (Text fromString: (self selection string asLowercase)).
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> makeProjectLink [
	
	| attribute thisSel |
	
	thisSel := self selection.

	attribute := TextSqkProjectLink new. 
	thisSel := attribute analyze: self selection asString.

	thisSel ifNil: [^ true].
	self replaceSelectionWith: (thisSel asText addAttribute: attribute).
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> makeProjectLink: characterStream [ 
	""

	| attribute oldAttributes thisSel |
	
	sensor keyboard.
	oldAttributes := paragraph text attributesAt: self pointIndex forStyle: paragraph textStyle.
	thisSel := self selection.

	attribute := TextSqkProjectLink new. 
	thisSel := attribute analyze: self selection asString.

	thisSel ifNil: [^ true].
	beginTypeInBlock ~~ nil
		ifTrue:  "only change emphasisHere while typing"
			[self insertTypeAhead: characterStream.
			emphasisHere := Text addAttribute: attribute toArray: oldAttributes.
			^ true].
	self replaceSelectionWith: (thisSel asText addAttribute: attribute).
	^ true
]

{ #category : #'editing keys' }
ParagraphEditor >> makeUppercase: characterStream [ 
	"Force the current selection to uppercase.  Triggered by Cmd-Y."

	sensor keyboard.		"flush the triggering cmd-key character"
	self replaceSelectionWith: (Text fromString: (self selection string asUppercase)).
	^ true
]

{ #category : #'accessing-selection' }
ParagraphEditor >> mark [
	^ self markBlock stringIndex
]

{ #category : #'accessing-selection' }
ParagraphEditor >> markBlock [
	^ stopBlock
]

{ #category : #'accessing-selection' }
ParagraphEditor >> markBlock: aCharacterBlock [
	stopBlock := aCharacterBlock.

]

{ #category : #'accessing-selection' }
ParagraphEditor >> markIndex [
	^ self markBlock stringIndex
]

{ #category : #scrolling }
ParagraphEditor >> markerDelta [

	^marker top - scrollBar top - ((paragraph clippingRectangle top -
		paragraph compositionRectangle top) asFloat /
			(self scrollRectangleHeight max: 1) asFloat *
				scrollBar height asFloat) rounded
]

{ #category : #'menu messages' }
ParagraphEditor >> methodNamesContainingIt [
	"Open a browser on methods names containing the selected string"

	self lineSelectAndEmptyCheck: [^ self].
	Cursor wait showWhile:
		[self terminateAndInitializeAround: [self systemNavigation browseMethodsWhoseNamesContain: self selection string withBlanksTrimmed]].
	Cursor normal show
]

{ #category : #'editing keys' }
ParagraphEditor >> methodNamesContainingIt: characterStream [ 
	"Browse methods whose selectors containing the selection in their names"

	sensor keyboard.		"flush character"
	self methodNamesContainingIt.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> methodSourceContainingIt [
	"Open a browser on methods which contain the current selection in their source (case-sensitive full-text search of source). Slow!"

	self lineSelectAndEmptyCheck: [^ self].
	self systemNavigation browseMethodsWithSourceString: self selection string
]

{ #category : #'editing keys' }
ParagraphEditor >> methodStringsContainingIt: characterStream [ 
	"Invoked from cmd-E -- open a browser on all methods holding string constants containing it.  Flushes typeahead. "

	sensor keyboard.	
	self methodStringsContainingit.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> methodStringsContainingit [
	"Open a browser on methods which contain the current selection as part of a string constant."

	self lineSelectAndEmptyCheck: [^ self].
	self terminateAndInitializeAround: [self systemNavigation browseMethodsWithString: self selection string]
]

{ #category : #private }
ParagraphEditor >> moveCursor: directionBlock forward: forward specialBlock: specialBlock [
	"Private - Move cursor.
	directionBlock is a one argument Block that computes the new Position from a given one.
	specialBlock is a one argumentBlock that computes the new position from a given one under the alternate semantics.
	Note that directionBlock always is evaluated first."
	| shift indices newPosition |
	shift := sensor leftShiftDown.
	indices := self setIndices: shift forward: forward.
	newPosition := directionBlock value: (indices at: #moving).
	(sensor commandKeyPressed or:[sensor controlKeyPressed])
		ifTrue: [newPosition := specialBlock value: newPosition].
	sensor keyboard.
	shift
		ifTrue: [self selectMark: (indices at: #fixed) point: newPosition - 1]
		ifFalse: [self selectAt: newPosition]
]

{ #category : #'menu messages' }
ParagraphEditor >> mvcRedisplay [
	"Overridable by subclasses that do their own display"
	Display fill: paragraph clippingRectangle 
			fillColor: view backgroundColor.	"very brute force"
	self display
]

{ #category : #'new selection' }
ParagraphEditor >> nextTokenFrom: start direction: dir [
	"simple token-finder for compiler automated corrections"
	| loc str |
	loc := start + dir.
	str := paragraph text string.
	[(loc between: 1 and: str size) and: [(str at: loc) isSeparator]]
		whileTrue: [loc := loc + dir].
	^ loc
]

{ #category : #private }
ParagraphEditor >> nextWord: position [
	| string index |
	string := paragraph text string.
	index := position.
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric]]
		whileTrue: [index := index + 1].
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric not]]
		whileTrue: [index := index + 1].
	^ index
]

{ #category : #'undo support' }
ParagraphEditor >> noUndoer [
	"The Undoer to use when the command can not be undone.  Checked for
	 specially by readKeyboard."

	UndoMessage := Message selector: #noUndoer
]

{ #category : #'editing keys' }
ParagraphEditor >> noop: characterStream [ 
	"Unimplemented keyboard command; just ignore it."

	sensor keyboard.	  "flush character"
	^ true

]

{ #category : #controlling }
ParagraphEditor >> normalActivity [
	self processKeyboard.
	self processMouseButtons.
	super normalActivity.
	
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> normalCharacter: characterStream [ 
	"A nonspecial character is to be added to the stream of characters."

	characterStream nextPut: sensor keyboard.
	^false
]

{ #category : #'new selection' }
ParagraphEditor >> notify: aString at: anInteger in: aStream [ 
	"The compilation of text failed. The syntax error is noted as the argument, 
	aString. Insert it in the text at starting character position anInteger."

	self insertAndSelect: aString at: (anInteger max: 1)
]

{ #category : #private }
ParagraphEditor >> nullText [

	^Text string: '' emphasis: emphasisHere
]

{ #category : #'do-its' }
ParagraphEditor >> objectsReferencingIt [
	"Open a list inspector on all objects that reference the object that results when the current selection is evaluated.  "
	
	self terminateAndInitializeAround:
		[self evaluateSelectionAndDo: [:result |
			self systemNavigation
					browseAllObjectReferencesTo: result
					except: #()
					ifNone: [:obj | view topView flash]]]
]

{ #category : #'editing keys' }
ParagraphEditor >> offerFontMenu [
	"Present a menu of available fonts, and if one is chosen, apply it to the current selection.  
	Use only names of Fonts of this paragraph  "

	| aList reply |
	aList := paragraph textStyle fontNamesWithPointSizes.
	reply := (SelectionMenu labelList: aList selections: aList) startUp.
	reply ~~ nil ifTrue:
		[self replaceSelectionWith:
			(Text string: self selection asString 
				attribute: (TextFontChange fontNumber: (aList indexOf: reply)))] 
]

{ #category : #'editing keys' }
ParagraphEditor >> offerFontMenu: characterStream [ 
	"The user typed the command key that requests a font change; Offer the font menu.  5/27/96 sw
	 Keeps typeahead.  (?? should flush?)"

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self offerFontMenu.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> offerMenuFromEsc: aStream [
   sensor keyboard. " consume the character "
   self yellowButtonActivity.
  ^true "tell the caller that the character was processed "
]

{ #category : #'typing support' }
ParagraphEditor >> openTypeIn [
	"Set up UndoSelection to null text (to be added to by readKeyboard and backTo:),
	 beginTypeInBlock to keep track of the leftmost backspace, and UndoParameter to tally
	 how many deleted characters were backspaced over rather than 'cut'.
	 You can't undo typing until after closeTypeIn."

	beginTypeInBlock == nil ifTrue:
		[UndoSelection := self nullText.
		self undoer: #noUndoer with: 0.
		beginTypeInBlock := self startIndex]
]

{ #category : #'editing keys' }
ParagraphEditor >> outdent: characterStream [
	"Remove a tab from the front of every line occupied by the selection. Flushes typeahead.  Invoked from keyboard via cmd-shift-L.  2/29/96 sw"

	^ self inOutdent: characterStream delta: -1
]

{ #category : #private }
ParagraphEditor >> pageHeight [
	| howManyLines visibleHeight totalHeight ratio |
	howManyLines := paragraph numberOfLines.
	visibleHeight := self visibleHeight.
	totalHeight := self totalTextHeight.
	ratio := visibleHeight / totalHeight.
	^(ratio * howManyLines) rounded - 2
]

{ #category : #'menu messages' }
ParagraphEditor >> paste [
	"Paste the text from the shared buffer over the current selection and 
	redisplay if necessary.  Undoer & Redoer: undoAndReselect."

	self replace: self selectionInterval with: self clipboardText and:
		[self selectAt: self pointIndex]
]

{ #category : #'editing keys' }
ParagraphEditor >> paste: characterStream [ 
	"Replace the current text selection by the text in the shared buffer.
	 Keeps typeahead."

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self paste.
	^true
]

{ #category : #'editing keys' }
ParagraphEditor >> pasteInitials: characterStream [ 
	"Replace the current text selection by an authorship name/date stamp; invoked by cmd-shift-v, easy way to put an authorship stamp in the comments of an editor.
	 Keeps typeahead."

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self replace: self selectionInterval with: (Text fromString: Utilities changeStamp) and: [self selectAt: self stopIndex].
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> pasteRecent [
	"Paste an item chose from RecentClippings."

	| clipping |
	(clipping := Clipboard chooseRecentClipping) ifNil: [^ self].
	Clipboard clipboardText: clipping.
	^ self paste
]

{ #category : #'menu messages' }
ParagraphEditor >> performMenuMessage: aSelector [
	"If a menu command is invoked, typeIn must be closed first, the selection
	 must be unhighlighted before and rehighlighted after, and the marker
	 must be updated."

	self closeTypeIn.
	self deselect.
	super performMenuMessage: aSelector.
	self selectAndScroll.
	self updateMarker
]

{ #category : #'accessing-selection' }
ParagraphEditor >> pointBlock [
	^ startBlock
]

{ #category : #'accessing-selection' }
ParagraphEditor >> pointBlock: aCharacterBlock [
	startBlock := aCharacterBlock.

]

{ #category : #'accessing-selection' }
ParagraphEditor >> pointIndex [
	^ self pointBlock stringIndex
]

{ #category : #'menu messages' }
ParagraphEditor >> presentSpecialMenu [
	"Present a list of expressions, and if the user chooses one, evaluate it in the context of the receiver, a ParagraphEditor.  Primarily for debugging, this provides a convenient way to talk to the various views, controllers, and models associated with any text pane"

	self terminateAndInitializeAround:
		[| reply items |
		reply := (UIManager default chooseFrom: (items := self specialMenuItems) lines: #()).
		reply = 0 ifTrue: [^ self].
		Compiler new evaluate: (items at: reply) in: [] to: self]
	
]

{ #category : #'menu messages' }
ParagraphEditor >> prettyPrint [
	self prettyPrint: false
]

{ #category : #'menu messages' }
ParagraphEditor >> prettyPrint: decorated [
	"Reformat the contents of the receiver's view (a Browser)."

	| selectedClass newText |
	model selectedMessageCategoryName ifNil: [^ view flash].
	selectedClass := model selectedClassOrMetaClass.
	newText := selectedClass prettyPrinterClass
		format: self text
		in: selectedClass
		notifying: self
		decorated: decorated.
	newText ifNotNil:
		[self deselect; selectInvisiblyFrom: 1 to: paragraph text size.
		self replaceSelectionWith: (newText asText makeSelectorBoldIn: selectedClass).
		self selectAt: 1]
]

{ #category : #'menu messages' }
ParagraphEditor >> prettyPrintWithColor [
	self prettyPrint: true
]

{ #category : #private }
ParagraphEditor >> previousWord: position [
	| string index |
	string := paragraph text string.
	index := position.
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric not]]
		whileTrue: [index := index - 1].
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric]]
		whileTrue: [index := index - 1].
	^ index + 1
]

{ #category : #'do-its' }
ParagraphEditor >> printIt [
	"Treat the current text selection as an expression; evaluate it. Insert the 
	description of the result of evaluation after the selection and then make 
	this description the new text selection."
	self evaluateSelectionAndDo: [:result |
		self afterSelectionInsertAndSelect: result printString]
]

{ #category : #'editing keys' }
ParagraphEditor >> printIt: characterStream [ 
	"Print the results of evaluting the selection -- invoked via cmd-p.  If there is no current selection, use the current line.  1/17/96 sw
	 2/29/96 sw: don't call selectLine now, since it's called by doIt"

	sensor keyboard.		"flush character"
	self terminateAndInitializeAround: [self printIt].
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> printerSetup [
	
	TextPrinter defaultTextPrinter inspect

]

{ #category : #'sensor access' }
ParagraphEditor >> processBlueButton [
	"The user pressed the blue button on the mouse. Determine what action 
	to take."

	^self
]

{ #category : #'sensor access' }
ParagraphEditor >> processKeyboard [
	"Determine whether the user pressed the keyboard. If so, read the keys."

	sensor keyboardPressed ifTrue: [self readKeyboard]
]

{ #category : #'sensor access' }
ParagraphEditor >> processMouseButtons [
	"Determine whether the user pressed any mouse button. For each possible 
	button, determine what actions to take."

	sensor redButtonPressed ifTrue: [self processRedButton].
	sensor yellowButtonPressed ifTrue: [self processYellowButton].
	sensor blueButtonPressed ifTrue: [self processBlueButton]
]

{ #category : #'sensor access' }
ParagraphEditor >> processRedButton [
	"The user pressed a red mouse button, meaning create a new text 
	selection. Highlighting the selection is carried out by the paragraph 
	itself. Double clicking causes a selection of the area between the nearest 
	enclosing delimitors."

	|  selectionBlocks clickPoint oldDelta oldInterval previousMarkBlock previousPointBlock |

	clickPoint := sensor cursorPoint.
	(view containsPoint: clickPoint) ifFalse: [^ self].
	(paragraph clickAt: clickPoint for: model controller: self) ifTrue: [^ self].
	oldInterval := self selectionInterval.
	previousMarkBlock := self markBlock.
	previousPointBlock := self pointBlock.
	oldDelta := paragraph scrollDelta.
	sensor leftShiftDown
		ifFalse:
			[self deselect.
			self closeTypeIn.
			selectionBlocks := paragraph mouseSelect: clickPoint]
		ifTrue:
			[selectionBlocks := paragraph extendSelectionMark: self markBlock pointBlock: self pointBlock.
			self closeTypeIn].
	selectionShowing := true.
	self markBlock: (selectionBlocks at: 1).
	self pointBlock: (selectionBlocks at: 2).
	(self hasCaret
		and: [previousMarkBlock = self markBlock and: [previousPointBlock = self pointBlock]])
		ifTrue: [self selectWord].
	oldDelta ~= paragraph scrollDelta "case of autoscroll"
			ifTrue: [self updateMarker].
	self setEmphasisHere.
	(self isDisjointFrom: oldInterval) ifTrue:
		[otherInterval := oldInterval]
]

{ #category : #'sensor access' }
ParagraphEditor >> processYellowButton [
	"User pressed the yellow button on the mouse. Determine what actions to 
	take."

	self yellowButtonActivity
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> querySymbol: characterStream [
	"Invoked by Ctrl-q to query the Symbol table and display alternate symbols.
	 See comment in completeSymbol:lastOffering: for details."

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.	"keep typeahead"
	self hasCaret
		ifTrue: "Ctrl-q typed when a caret"
			[self perform: #completeSymbol:lastOffering: withArguments:
				((UndoParagraph == paragraph and: [UndoMessage sends: #undoQuery:lastOffering:])
					ifTrue: [UndoMessage arguments] "repeated Ctrl-q"
					ifFalse: [Array with: nil with: nil])] "initial Ctrl-q"
		ifFalse: "Ctrl-q typed when statements were highlighted"
			[view flash].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> raiseContextMenu: characterStream [ 
	"AFAIK, this is never called in morphic, because a subclass overrides it. Which is good, because a ParagraphEditor doesn't know about Morphic and thus duplicates the text-editing actions that really belong in the specific application, not the controller. So the context menu this would raise is likely to be out of date."
	self yellowButtonActivity.
	^true
]

{ #category : #'typing support' }
ParagraphEditor >> readKeyboard [
	"Key struck on the keyboard. Find out which one and, if special, carry 
	out the associated special action. Otherwise, add the character to the 
	stream of characters.  Undoer & Redoer: see closeTypeIn."

	| typeAhead char |
	typeAhead := WriteStream on: (String new: 128).
	[sensor keyboardPressed] whileTrue: 
		[self deselect.
		 sensor keyboardPressed ifTrue: 
			[char := sensor peekKeyboard.
			(self dispatchOnCharacter: char with: typeAhead) ifTrue:
				[self doneTyping.
				self setEmphasisHere.
				^self selectAndScroll; updateMarker].
			self openTypeIn].
		self hasSelection ifTrue: "save highlighted characters"
			[UndoSelection := self selection]. 
		self zapSelectionWithCompositionWith: typeAhead contents.
		typeAhead reset.
		self unselect.
		sensor keyboardPressed ifFalse: 
			[self selectAndScroll.
			sensor keyboardPressed
				ifFalse: [self updateMarker]]]
]

{ #category : #'current selection' }
ParagraphEditor >> recomputeInterval [
	"The same characters are selected but their coordinates may have changed."

	self computeIntervalFrom: self mark to: self pointIndex - 1
]

{ #category : #'current selection' }
ParagraphEditor >> recomputeSelection [
	"Redetermine the selection according to the start and stop block indices; 
	do not highlight."

	self deselect; recomputeInterval
]

{ #category : #'menu messages' }
ParagraphEditor >> referencesToIt [
	"Open a MessageSet with the references to the selected global or variable name."

	self wordSelectAndEmptyCheck: [^ self].
	self selectedInstanceVariable ifNotNil:
		[:nameToClass | ^ self terminateAndInitializeAround:
			[self systemNavigation
				browseAllAccessesTo: nameToClass key
				from: nameToClass value]].
	self selectedBinding ifNotNil:
		[:binding | ^ self terminateAndInitializeAround:
			[self systemNavigation browseAllCallsOnClass: binding]].
	view flash.
]

{ #category : #'editing keys' }
ParagraphEditor >> referencesToIt: characterStream [ 
	"Triggered by Cmd-N; browse references to the current selection"

	sensor keyboard.		"flush character"
	self referencesToIt.
	^ true
]

{ #category : #accessing }
ParagraphEditor >> replace: oldInterval with: newText and: selectingBlock [ 
	"Replace the text in oldInterval with newText and execute selectingBlock to establish the new selection.  Create an undoAndReselect:redoAndReselect: undoer to allow perfect undoing."

	| undoInterval |
	undoInterval := self selectionInterval.
	undoInterval = oldInterval ifFalse: [self selectInterval: oldInterval].
	UndoSelection := self selection.
	self zapSelectionWith: newText.
	selectingBlock value.
	otherInterval := self selectionInterval.
	self undoer: #undoAndReselect:redoAndReselect: with: undoInterval with: otherInterval
]

{ #category : #accessing }
ParagraphEditor >> replaceSelectionWith: aText [
	"Remember the selection text in UndoSelection.
	 Deselect, and replace the selection text by aText.
	 Remember the resulting selectionInterval in UndoInterval and PriorInterval.
	 Set up undo to use UndoReplace."

	beginTypeInBlock ~~ nil ifTrue: [^self zapSelectionWith: aText]. "called from old code"
	UndoSelection := self selection.
	self zapSelectionWith: aText.
	self undoer: #undoReplace
]

{ #category : #'initialize-release' }
ParagraphEditor >> resetState [ 
	"Establish the initial conditions for editing the paragraph: place caret 
	before first character, set the emphasis to that of the first character,
	and save the paragraph for purposes of canceling."

	stopBlock := paragraph defaultCharacterBlock.
	self pointBlock: stopBlock copy.
	beginTypeInBlock := nil.
	UndoInterval := otherInterval := 1 to: 0.
	self setEmphasisHere.
	selectionShowing := false.
	initialText := paragraph text copy
]

{ #category : #'current selection' }
ParagraphEditor >> reverseSelection [
	"Reverse the valence of the current selection highlighting."
	selectionShowing := selectionShowing not.
	paragraph reverseFrom: self pointBlock to: self markBlock
]

{ #category : #private }
ParagraphEditor >> sameColumn: start newLine: lineBlock forward: isForward [
	"Private - Compute the index in my text
	with the line number derived from lineBlock,"
	" a one argument block accepting the old line number.
	The position inside the line will be preserved as good as possible"
	"The boolean isForward is used in the border case to determine if
	we should move to the beginning or the end of the line."
	| wordStyle column currentLine offsetAtTargetLine targetEOL lines numberOfLines currentLineNumber targetLineNumber |
	wordStyle := Preferences wordStyleCursorMovement.
	wordStyle
		ifTrue: [
			lines := paragraph lines.
			numberOfLines := paragraph numberOfLines.
			currentLineNumber  := paragraph lineIndexOfCharacterIndex: start.
			currentLine := lines at: currentLineNumber]
		ifFalse: [
			lines := self lines.
			numberOfLines := lines size.
			currentLine := lines
				detect:[:lineInterval | lineInterval last >= start]
				ifNone:[lines last].
			currentLineNumber := currentLine second].
	column := start - currentLine first.
	targetLineNumber := ((lineBlock value: currentLineNumber) max: 1) min: numberOfLines.
	offsetAtTargetLine := (lines at: targetLineNumber) first.
	targetEOL := (lines at: targetLineNumber) last + (targetLineNumber = numberOfLines ifTrue:[1]ifFalse:[0]).
	targetLineNumber = currentLineNumber
	"No movement or movement failed. Move to beginning or end of line."
		ifTrue:[^isForward
			ifTrue:[targetEOL]
			ifFalse:[offsetAtTargetLine]].
	^offsetAtTargetLine + column min: targetEOL.
]

{ #category : #'editing keys' }
ParagraphEditor >> save: characterStream [
	"Submit the current text.  Equivalent to 'accept' 1/18/96 sw
	 Keeps typeahead."

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self terminateAndInitializeAround: [self accept].
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> saveContentsInFile [
	"Save the receiver's contents string to a file, prompting the user for a file-name.  Suggest a reasonable file-name."

	| fileName stringToSave parentWindow labelToUse suggestedName |
	stringToSave := paragraph text string.
	stringToSave size = 0 ifTrue: [^ self inform: 'nothing to save.'].
	parentWindow := self model dependents
						detect: [:dep | dep isKindOf: SystemWindow orOf: StandardSystemView]
						ifNone: [nil].
	labelToUse := parentWindow
		ifNil: 		['Untitled']
		ifNotNil: 	[parentWindow label].
	suggestedName := nil.
	#(('Decompressed contents of: '		'.gz')) do:  "can add more here..."
		[:leaderTrailer | | lastIndex |
			(labelToUse beginsWith: leaderTrailer first) ifTrue:
				[suggestedName := labelToUse copyFrom: leaderTrailer first size + 1 to: labelToUse size.
				(labelToUse endsWith: leaderTrailer last)
					ifTrue:
						[suggestedName := suggestedName copyFrom: 1 to: suggestedName size - leaderTrailer last size]
					ifFalse:
						[lastIndex := suggestedName lastIndexOf: $..
						(lastIndex > 1) ifTrue:
							[suggestedName := suggestedName copyFrom: 1 to: lastIndex - 1]]]].

	suggestedName ifNil:
		[suggestedName := labelToUse, '.text'].
			
	fileName := UIManager default saveFilenameRequest: 'File name?' translated
			initialAnswer: suggestedName.
	fileName isEmptyOrNil ifFalse:
		[(FileStream newFileNamed: fileName) nextPutAll: stringToSave; close]
]

{ #category : #scrolling }
ParagraphEditor >> scrollAmount [ 
	"Refer to the comment in ScrollController|scrollAmount."

	^sensor cursorPoint y - scrollBar top
]

{ #category : #scrolling }
ParagraphEditor >> scrollBar [
	^ scrollBar
]

{ #category : #scrolling }
ParagraphEditor >> scrollBy: heightToMove [
	"Move the paragraph by heightToMove, and reset the text selection."
	^ paragraph scrollBy: heightToMove withSelectionFrom: self pointBlock to: self markBlock
]

{ #category : #scrolling }
ParagraphEditor >> scrollRectangleHeight [

	^paragraph compositionRectangle height 
		+ paragraph lineGrid
]

{ #category : #scrolling }
ParagraphEditor >> scrollToBottom [
	"Scroll so that the tail end of the text is visible in the view.  5/6/96 sw"

	self scrollView: (paragraph clippingRectangle bottom 
		- paragraph compositionRectangle bottom)
]

{ #category : #scrolling }
ParagraphEditor >> scrollToTop [
	"Scroll so that the paragraph is at the top of the view."

	self scrollView: (paragraph clippingRectangle top 
		- paragraph compositionRectangle top)
]

{ #category : #scrolling }
ParagraphEditor >> scrollView: anInteger [ 
	"Paragraph scrolling uses opposite polarity"
	^ self scrollBy: anInteger negated
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> search: characterStream [
	"Invoked by Ctrl-S.  Same as 'again', but always uses the existing FindText
	 and ChangeText regardless of the last edit."

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self againOrSame: true. "true means use same keys"
	^true
]

{ #category : #'current selection' }
ParagraphEditor >> select [
	"If the text selection is visible on the screen, highlight it."

	selectionShowing ifFalse: [self reverseSelection]
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> selectAll [
	"Make the selection be all the characters of the receiver"

	self selectFrom: 1 to: paragraph text string size
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> selectAll: characterStream [ 
	"select everything, invoked by cmd-a.  1/17/96 sw"

	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self selectFrom: 1 to: paragraph text string size.
	^ true
]

{ #category : #'current selection' }
ParagraphEditor >> selectAndScroll [
	"Scroll until the selection is in the view and then highlight it."
	| lineHeight deltaY clippingRectangle endBlock |
	self select.
	endBlock := self stopBlock.
	lineHeight := paragraph textStyle lineGrid.
	clippingRectangle := paragraph clippingRectangle.
	deltaY := endBlock top - clippingRectangle top.
	deltaY >= 0 
		ifTrue: [deltaY := endBlock bottom - clippingRectangle bottom max: 0].
						"check if stopIndex below bottom of clippingRectangle"
	deltaY ~= 0 
		ifTrue: [self scrollBy: (deltaY abs + lineHeight - 1 truncateTo: lineHeight)
									* deltaY sign]
]

{ #category : #'current selection' }
ParagraphEditor >> selectAndScrollToTop [
	"Scroll until the selection is in the view and then highlight it."
	| lineHeight deltaY clippingRectangle |
	self select.
	lineHeight := paragraph textStyle lineGrid.
	clippingRectangle := paragraph clippingRectangle.
	deltaY := self stopBlock top - clippingRectangle top.
	deltaY ~= 0 
		ifTrue: [self scrollBy: (deltaY abs + lineHeight - 1 truncateTo: lineHeight)
									* deltaY sign]
]

{ #category : #'new selection' }
ParagraphEditor >> selectAt: characterIndex [ 
	"Deselect, then place the caret before the character at characterIndex.
	 Be sure it is in view."

	self selectFrom: characterIndex to: characterIndex - 1
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> selectCurrentTypeIn: characterStream [ 
	"Select what would be replaced by an undo (e.g., the last typeIn)."

	| prior |

	self closeTypeIn: characterStream.
	prior := otherInterval.
	sensor keyboard.		"flush character"
	self closeTypeIn: characterStream.
	self selectInterval: UndoInterval.
	otherInterval := prior.
	^ true
]

{ #category : #'new selection' }
ParagraphEditor >> selectFrom: start to: stop [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	(start = self startIndex and: [stop + 1 = self stopIndex]) ifFalse:
		[self deselect.
		self selectInvisiblyFrom: start to: stop].
	self selectAndScroll
]

{ #category : #'new selection' }
ParagraphEditor >> selectInterval: anInterval [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	self selectFrom: anInterval first to: anInterval last
]

{ #category : #'new selection' }
ParagraphEditor >> selectIntervalInvisibly: anInterval [
	"Deselect, then select the specified characters inclusive.
	 Do not yet make the new selection visible."

	self deselect.
	self selectInvisiblyFrom: anInterval first to: anInterval last
]

{ #category : #'new selection' }
ParagraphEditor >> selectInvisiblyFrom: start to: stop [
	"Select the designated characters, inclusive.  Make no visual changes."

	^ self computeIntervalFrom: start to: stop
]

{ #category : #'new selection' }
ParagraphEditor >> selectInvisiblyMark: mark point: point [
	"Select the designated characters, inclusive.  Make no visual changes."

	^ self computeIntervalFrom: mark to: point
]

{ #category : #'new selection' }
ParagraphEditor >> selectLine [
	"Make the receiver's selection, if it currently consists of an insertion point only, encompass the current line."

	self selectInterval: (self encompassLine: self selectionInterval)
]

{ #category : #'new selection' }
ParagraphEditor >> selectMark: mark point: point [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	(mark =  self markIndex and: [point + 1 = self pointIndex]) ifFalse:
		[self deselect.
		self selectInvisiblyMark: mark point: point].
	self selectAndScroll
]

{ #category : #'new selection' }
ParagraphEditor >> selectPrecedingIdentifier [
	"Invisibly select the identifier that ends at the end of the selection, if any."

	| string sep stop tok |
	tok := false.
	string := paragraph text string.
	stop := self stopIndex - 1.
	[stop > 0 and: [(string at: stop) isSeparator]] whileTrue: [stop := stop - 1].
	sep := stop.
	[sep > 0 and: [(string at: sep) tokenish]] whileTrue: [tok := true. sep := sep - 1].
	tok ifTrue: [self selectInvisiblyFrom: sep + 1 to: stop]
]

{ #category : #'new selection' }
ParagraphEditor >> selectWord [
	"Select delimited text or word--the result of double-clicking."

	| openDelimiter closeDelimiter direction match level leftDelimiters rightDelimiters
	string here hereChar start stop |
	string := paragraph text string.
	here := self pointIndex.
	(here between: 2 and: string size)
		ifFalse: ["if at beginning or end, select entire string"
			^self selectFrom: 1 to: string size].
	leftDelimiters := '([{<|''"
'.
	rightDelimiters := ')]}>|''"
'.
	openDelimiter := string at: here - 1.
	match := leftDelimiters indexOf: openDelimiter.
	match > 0
		ifTrue: 
			["delimiter is on left -- match to the right"
			start := here.
			direction := 1.
			here := here - 1.
			closeDelimiter := rightDelimiters at: match]
		ifFalse: 
			[openDelimiter := string at: here.
			match := rightDelimiters indexOf: openDelimiter.
			match > 0
				ifTrue: 
					["delimiter is on right -- match to the left"
					stop := here - 1.
					direction := -1.
					closeDelimiter := leftDelimiters at: match]
				ifFalse: ["no delimiters -- select a token"
					direction := -1]].
	level := 1.
	[level > 0 and: [direction > 0
			ifTrue: [here < string size]
			ifFalse: [here > 1]]]
		whileTrue: 
			[hereChar := string at: (here := here + direction).
			match = 0
				ifTrue: ["token scan goes left, then right"
					hereChar tokenish
						ifTrue: [here = 1
								ifTrue: 
									[start := 1.
									"go right if hit string start"
									direction := 1]]
						ifFalse: [direction < 0
								ifTrue: 
									[start := here + 1.
									"go right if hit non-token"
									direction := 1]
								ifFalse: [level := 0]]]
				ifFalse: ["bracket match just counts nesting level"
					hereChar = closeDelimiter
						ifTrue: [level := level - 1"leaving nest"]
						ifFalse: [hereChar = openDelimiter 
									ifTrue: [level := level + 1"entering deeper nest"]]]].

	level > 0 ifTrue: ["in case ran off string end"	here := here + direction].
	direction > 0
		ifTrue: [self selectFrom: start to: here - 1]
		ifFalse: [self selectFrom: here + 1 to: stop]
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> selectWord: characterStream [
	sensor keyboard.
	self closeTypeIn: characterStream.
	self selectWord.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> selectedBinding [
	"Try to make a binding out of the current text selection. That binding can be a global or class."

	^ self selectedSymbol ifNotNil:
		[ :symbol |
			((model respondsTo: #selectedClassOrMetaClass)
				ifTrue: [ model selectedClassOrMetaClass ifNil: [ model environment ] ]
				ifFalse: [ model environment ]) ifNotNil:
					[ :environment | environment bindingOf: symbol ] ]
]

{ #category : #'menu messages' }
ParagraphEditor >> selectedClassVariable [
	"Try to make a class-variable binding out of the current text selection."

	(model respondsTo: #selectedClassOrMetaClass) ifFalse: [ ^ nil ].
		
	^ self selectedSymbol ifNotNil:
		[ :symbol | model selectedClassOrMetaClass ifNotNil:
			[ :classOrMetaClass | (classOrMetaClass theNonMetaClass allClassVarNames includes: symbol)
				ifTrue: [ classOrMetaClass bindingOf: symbol ]
				ifFalse: [ nil ] ] ]
]

{ #category : #'menu messages' }
ParagraphEditor >> selectedInstanceVariable [
	"Try to make an association from an instance-variable name to the class where this variable is defined. Make the implementation robust for models that do not know about classes.
	
	Note that inst-var names might not have symbol a representation, only via their accessors."

	(model respondsTo: #selectedClassOrMetaClass) ifFalse: [ ^ nil ].
		
	^ self selection string ifNotNil: 
		[ :token | model selectedClassOrMetaClass ifNotNil:
			[ :behavior |
				(behavior instVarIndexFor: token ifAbsent: [ 0 ]) ~= 0
					ifTrue: [ token -> behavior ]
					ifFalse: [ nil ] ] ]
]

{ #category : #'menu messages' }
ParagraphEditor >> selectedLiteral [
	"Try to make a Smalltalk literal out of the current text selection."

	^ self selection string findLiteral
]

{ #category : #'menu messages' }
ParagraphEditor >> selectedSelector [
	"Try to make a selector out of the current text selection"
	^self selection string findSelector
]

{ #category : #'menu messages' }
ParagraphEditor >> selectedSymbol [
	"Try to make a symbol out of the current text selection."

	^ self selection string findSymbol
]

{ #category : #'accessing-selection' }
ParagraphEditor >> selection [
	"Answer the text in the paragraph that is currently selected."

	| t |
	t := paragraph text copyFrom: self startIndex to: self stopIndex - 1.
	t string isOctetString ifTrue: [t asOctetStringText].
	^ t.

]

{ #category : #'accessing-selection' }
ParagraphEditor >> selectionAsStream [
	"Answer a ReadStream on the text in the paragraph that is currently 
	selected."

	^ReadStream
		on: paragraph string
		from: self startIndex
		to: self stopIndex - 1
]

{ #category : #'accessing-selection' }
ParagraphEditor >> selectionInterval [
	"Answer the interval that is currently selected."

	^self startIndex to: self stopIndex - 1 
]

{ #category : #'menu messages' }
ParagraphEditor >> sendContentsToPrinter [
	| textToPrint printer parentWindow |
	textToPrint := paragraph text.
	textToPrint size == 0 ifTrue: [^self inform: 'nothing to print.' translated].
	printer := TextPrinter defaultTextPrinter.
	parentWindow := self model dependents 
				detect: [:dep | dep isSystemWindow]
				ifNone: [nil].
	parentWindow isNil 
		ifTrue: [printer documentTitle: 'Untitled']
		ifFalse: [printer documentTitle: parentWindow label].
	printer printText: textToPrint
]

{ #category : #'menu messages' }
ParagraphEditor >> sendersOfIt [
	"Open a senders browser on the selected selector"

	self lineSelectAndEmptyCheck: [^ self].
	self selectedSelector ifNotNil:
		[:aSelector| ^ self terminateAndInitializeAround:
			[self systemNavigation browseAllCallsOn: aSelector]].
	self selectedLiteral ifNotNil:
		[:aLiteral| ^ self terminateAndInitializeAround:
			[self systemNavigation browseAllCallsOn: aLiteral]].
	view flash
]

{ #category : #'editing keys' }
ParagraphEditor >> sendersOfIt: characterStream [ 
	"Triggered by Cmd-n; browse implementors of the selector represented by the current selection, if plausible. 2/1/96 sw"

	sensor keyboard.		"flush character"
	self sendersOfIt.
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> setAlignment: aSymbol [
	| attr interval |
	attr := TextAlignment perform: aSymbol.
	interval := self encompassLine: self selectionInterval.
	paragraph replaceFrom: interval first to: interval last with:
		((paragraph text copyFrom: interval first to: interval last) addAttribute: attr) displaying: true.

]

{ #category : #'editing keys' }
ParagraphEditor >> setEmphasis: emphasisSymbol [
	"Change the emphasis of the current selection."

	| oldAttributes attribute |
	oldAttributes := paragraph text attributesAt: self selectionInterval first forStyle: paragraph textStyle.

	attribute := TextEmphasis perform: emphasisSymbol.
	(emphasisSymbol == #normal) 
		ifFalse:	[oldAttributes do:	
			[:att | (att dominates: attribute) ifTrue: [attribute turnOff]]].
	self replaceSelectionWith: (self selection addAttribute: attribute)
]

{ #category : #'typing support' }
ParagraphEditor >> setEmphasisHere [

	emphasisHere := (paragraph text attributesAt: (self pointIndex - 1 max: 1) forStyle: paragraph textStyle)
					select: [:att | att mayBeExtended]
]

{ #category : #private }
ParagraphEditor >> setIndices: shiftPressed forward: forward [
	"Little helper method that sets the moving and fixed indices according to some flags."
	| indices |
	indices := Dictionary new.
	shiftPressed ifTrue: [
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

{ #category : #'accessing-selection' }
ParagraphEditor >> setMark: anIndex [
	self markBlock: (paragraph characterBlockForIndex: anIndex)

]

{ #category : #'accessing-selection' }
ParagraphEditor >> setPoint: anIndex [
	self pointBlock: (paragraph characterBlockForIndex: anIndex)

]

{ #category : #accessing }
ParagraphEditor >> setSearch: aString [
	"Set the FindText and ChangeText to seek aString; except if already seeking aString, leave ChangeText alone so again will repeat last replacement."

	FindText string = aString
		ifFalse: [FindText := ChangeText := aString asText]
]

{ #category : #'menu messages' }
ParagraphEditor >> setSearchString [
	"Make the current selection, if any, be the current search string."
	self hasCaret ifTrue: [view flash. ^ self].
	self setSearch:  self selection string
]

{ #category : #'nonediting\/nontyping keys' }
ParagraphEditor >> setSearchString: characterStream [
	"Establish the current selection as the current search string."

	| aString |
	self closeTypeIn: characterStream.
	sensor keyboard.
	self lineSelectAndEmptyCheck: [^ true].
	aString :=  self selection string.
	aString size = 0
		ifTrue:
			[self flash]
		ifFalse:
			[self setSearch: aString].
	^ true
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> simulatedBackspace [
	"Backspace over the last character, derived from hand-char recognition.  2/5/96 sw"

	| startIndex |
	startIndex := self markIndex + (self hasSelection ifTrue: [1] ifFalse: [0]).

	startIndex := 1 max: startIndex - 1.
	self backTo: startIndex.
	^ false
]

{ #category : #'typing support' }
ParagraphEditor >> simulatedKeystroke: char [
	"Accept char as if it were struck on the keyboard.  This version does not yet deal with command keys, and achieves update in the receiver's typically inactive window via the sledge-hammer of uncache-bits."

	self deselect.
	self openTypeIn.
	self markBlock = self pointBlock ifFalse: [UndoSelection := self selection].
	self zapSelectionWith:
		(Text string: char asString emphasis: emphasisHere).
	self userHasEdited.
	self unselect.
	self selectAndScroll.
	self updateMarker.
	view ifNotNil:
		[view topView uncacheBits
		"in mvc, this makes sure the recognized character shows up in the pane right now; in morphic, a different mechanism is used for the same effect -- see TextMorphEditor method #recognizeCharactersWhileMouseIn:"]

]

{ #category : #'menu messages' }
ParagraphEditor >> spawn [
	"Create and schedule a message browser for the code of the model's 
	selected message. Retain any edits that have not yet been accepted."
	| code |
	code := paragraph text string.
	self cancel.
	model notNil ifTrue:[model spawn: code].

]

{ #category : #'editing keys' }
ParagraphEditor >> spawnIt: characterStream [
	"Triggered by Cmd-o; spawn a new code window, if it makes sense."

	sensor keyboard.
	self terminateAndInitializeAround: [self spawn].
	^ true
]

{ #category : #'menu messages' }
ParagraphEditor >> spawnWorkspace [
	| toUse |
	self selectLine.
	toUse := self selection asString.
	toUse size > 0 ifFalse:
		[toUse := paragraph text string.
		toUse size > 0 ifFalse: [^ self flash]].
	"NB: BrowserCodeController's version does a cancel here"
	self terminateAndInitializeAround:
		[Utilities openScratchWorkspaceLabeled: 'Untitled' contents: toUse]
]

{ #category : #'menu messages' }
ParagraphEditor >> specialMenuItems [
	"Refer to comment under #presentSpecialMenu.  .
	 : added objectsReferencingIt,"

	^ #(	'Transcript cr; show: ''testing'''
			'view superView model inspect'
			'view superView model browseObjClass'
			'view display'
			'self inspect'
			'view backgroundColor: Color fromUser'
			'view topView inspect'
			'self compareToClipboard'
			'view insideColor: Form white'
			'self objectsReferencingIt'
		) 
]

{ #category : #'accessing-selection' }
ParagraphEditor >> startBlock [
	^ self pointBlock min: self markBlock
]

{ #category : #'accessing-selection' }
ParagraphEditor >> startBlock: aCharacterBlock [
	self markBlock: aCharacterBlock
]

{ #category : #'accessing-selection' }
ParagraphEditor >> startIndex [
	^ self startBlock stringIndex
]

{ #category : #'typing support' }
ParagraphEditor >> startOfTyping [
	"Compatibility during change from characterBlock to integer"
	beginTypeInBlock == nil ifTrue: [^ nil].
	beginTypeInBlock isNumber ifTrue: [^ beginTypeInBlock].
	"Last line for compatibility during change from CharacterBlock to Integer."
	^ beginTypeInBlock stringIndex
	
]

{ #category : #'initialize-release' }
ParagraphEditor >> stateArray [
	^ {ChangeText.
		FindText.
		UndoInterval.
		UndoMessage.
		UndoParagraph.
		UndoSelection.
		Undone.
		self selectionInterval.
		self startOfTyping.
		emphasisHere}
]

{ #category : #'initialize-release' }
ParagraphEditor >> stateArrayPut: stateArray [
	| sel |
	ChangeText := stateArray at: 1.
	FindText := stateArray at: 2.
	UndoInterval := stateArray at: 3.
	UndoMessage := stateArray at: 4.
	UndoParagraph := stateArray at: 5.
	UndoSelection := stateArray at: 6.
	Undone := stateArray at: 7.
	sel := stateArray at: 8.
	self selectFrom: sel first to: sel last.
	beginTypeInBlock := stateArray at: 9.
	emphasisHere := stateArray at: 10.
]

{ #category : #'accessing-selection' }
ParagraphEditor >> stopBlock [
	^ self pointBlock max: self markBlock
]

{ #category : #'accessing-selection' }
ParagraphEditor >> stopBlock: aCharacterBlock [
	self pointBlock: aCharacterBlock
]

{ #category : #'accessing-selection' }
ParagraphEditor >> stopIndex [
	^ self stopBlock stringIndex
]

{ #category : #'editing keys' }
ParagraphEditor >> swapChars: characterStream [ 
	"Triggered byCmd-Y;.  Swap two characters, either those straddling the insertion point, or the two that comprise the selection.  Suggested by Ted Kaehler.  "

	| currentSelection aString chars |
	sensor keyboard.		"flush the triggering cmd-key character"
	(chars := self selection) size = 0
		ifTrue:
			[currentSelection := self pointIndex.
			self selectMark: currentSelection - 1 point: currentSelection]
		ifFalse:
			[chars size = 2
				ifFalse:
					[view flash.  ^ true]
				ifTrue:
					[currentSelection := self pointIndex - 1]].
	aString := self selection string.
	self replaceSelectionWith: (Text string: aString reversed emphasis: emphasisHere).
	self selectAt: currentSelection + 1.
	^ true
]

{ #category : #'typing\/selecting keys' }
ParagraphEditor >> tabOrIndent: characterStream [ 
	self selection
		ifEmpty: [ self normalCharacter: characterStream ]
		ifNotEmpty:
			[ Sensor shiftPressed
				ifTrue: [ self outdent: characterStream ]
				ifFalse: [ self indent: characterStream ] ].
	^ false
]

{ #category : #'do-its' }
ParagraphEditor >> tallyIt [

	^ self tallySelection
]

{ #category : #'do-its' }
ParagraphEditor >> tallySelection [
	"Treat the current selection as an expression; evaluate it and return the time took for this evaluation"
	| result rcvr ctxt valueAsString v |
	self lineSelectAndEmptyCheck: [^self].

	(model respondsTo: #doItReceiver) 
		ifTrue: [ rcvr := model doItReceiver.
				ctxt := model doItContext]
		ifFalse: [rcvr := ctxt := nil].
	result := [ | cm |
		cm := rcvr class evaluatorClass new 
			compiledMethodFor: self selectionAsStream
			in: ctxt
			to: rcvr
			notifying: self
			ifFail: [self flash. ^self].
		Time millisecondsToRun: 
			[v := cm valueWithReceiver: rcvr arguments: (ctxt ifNil: [#()] ifNotNil: [{ctxt}]) ].
	] 
		on: OutOfScopeNotification 
		do: [ :ex | ex resume: true].

	"We do not want to have large result displayed"
	valueAsString := v printString.
	(valueAsString size > 30) ifTrue: [valueAsString := (valueAsString copyFrom: 1 to: 30), '...'].
	PopUpMenu 
		inform: 'Time to compile and execute: ', result printString, 'ms res: ', valueAsString.

]

{ #category : #'editing keys' }
ParagraphEditor >> tempCommand: characterStream [ 
	"Experimental.  Triggered by Cmd-t; put trial cmd-key commands here to see how they work, before hanging them on their own cmd accelerators."
	Sensor keyboard.
	self experimentalCommand.
	^ true

	"sensor keyboard.
	self spawnWorkspace.
	^ true"
]

{ #category : #accessing }
ParagraphEditor >> text [
	"Answer the text of the paragraph being edited."

	^paragraph text
]

{ #category : #accessing }
ParagraphEditor >> totalTextHeight [

	^paragraph boundingBox height
]

{ #category : #'menu messages' }
ParagraphEditor >> undo [
	"Reset the state of the paragraph prior to the previous edit.
	 If another ParagraphEditor instance did that edit, UndoInterval is invalid;
	 just recover the contents of the undo-buffer at the start of the paragraph."

	sensor flushEvents. "a way to flush stuck keys"
	self closeTypeIn.

	UndoParagraph == paragraph ifFalse: "Can't undo another paragraph's edit"
		[UndoMessage := Message selector: #undoReplace.
		UndoInterval := 1 to: 0.
		Undone := true].
	UndoInterval ~= self selectionInterval ifTrue: "blink the actual target"
		[self selectInterval: UndoInterval; deselect].

	"Leave a signal of which phase is in progress"
	UndoParagraph := Undone ifTrue: [#redoing] ifFalse: [#undoing].
	UndoMessage sentTo: self.
	UndoParagraph := paragraph
]

{ #category : #'editing keys' }
ParagraphEditor >> undo: characterStream [ 
	"Undo the last edit.  Keeps typeahead, so undo twice is a full redo."

	sensor keyboard. 	"flush character"
	self closeTypeIn: characterStream.
	self undo.
	^true
]

{ #category : #undoers }
ParagraphEditor >> undoAgain: indices andReselect: home typedKey: wasTypedKey [
	"The last command was again.  Undo it. Redoer: itself."

	| findSize substText |
	(self isRedoing & wasTypedKey) ifTrue: "redelete search key"
		[self selectInterval: home.
		self zapSelectionWith: self nullText].

	findSize := (self isRedoing ifTrue: [FindText] ifFalse: [ChangeText]) size.
	substText := self isUndoing ifTrue: [FindText] ifFalse: [ChangeText].
	(self isUndoing ifTrue: [indices size to: 1 by: -1] ifFalse: [1 to: indices size]) do:
		[:i | | index subject |
		index := indices at: i.
		(subject := index to: index + findSize - 1) = self selectionInterval ifFalse:
			[self selectInterval: subject].
		FindText == ChangeText ifFalse: [self zapSelectionWith: substText]].

	self isUndoing
		ifTrue:  "restore selection to where it was when 'again' was invoked"
			[wasTypedKey
				ifTrue: "search started by typing key at a caret; restore it"
					[self selectAt: home first.
					self zapSelectionWith: FindText.
					self selectAt: home last + 1]
				ifFalse: [self selectInterval: home]].

	self undoMessage: UndoMessage forRedo: self isUndoing
]

{ #category : #undoers }
ParagraphEditor >> undoAndReselect: undoHighlight redoAndReselect: redoHighlight [
	"Undo typing, cancel, paste, and other operations that are like replaces
	 but the selection is not the whole restored text after undo, redo, or both.
	 undoHighlight is selected after this phase and redoHighlight after the next phase.
	Redoer: itself."

	self replace: self selectionInterval with: UndoSelection and:
		[self selectInterval: undoHighlight].
	self undoMessage: (UndoMessage argument: redoHighlight) forRedo: self isUndoing

]

{ #category : #undoers }
ParagraphEditor >> undoCutCopy: oldPasteBuffer [
	"Undo of a cut, copy, or any edit that changed CurrentSelection.  Be sure
	 undo-copy does not lock the model.  Redoer: itself, so never isRedoing."

	| recentCut |
	recentCut := self clipboardText.	
	UndoSelection size = UndoInterval size
		ifFalse: [self replaceSelectionWith: UndoSelection].
	self clipboardTextPut: oldPasteBuffer.
	self undoer: #undoCutCopy: with: recentCut
]

{ #category : #'undo support' }
ParagraphEditor >> undoMessage: aMessage forRedo: aBoolean [
	"Call this from an undoer/redoer to set up UndoMessage as the
	 corresponding redoer/undoer.  Also set up UndoParagraph, as well
	 as the state variable Undone.  It is assumed that UndoInterval has been
	 established (generally by zapSelectionWith:) and that UndoSelection has been
	 saved (generally by replaceSelectionWith: or replace:With:and:)."

	self isDoing ifTrue: [UndoParagraph := paragraph].
	UndoMessage := aMessage.
	Undone := aBoolean
]

{ #category : #undoers }
ParagraphEditor >> undoQuery: hintText lastOffering: selectorOrNil [
	"Undo ctrl-q.  selectorOrNil (if not nil) is the previously offered selector.
	 hintText is the original hint.  Redoer: completeSymbol."

	self zapSelectionWith: UndoSelection.
	self undoMessage: (Message selector: #completeSymbol:lastOffering: arguments: UndoMessage arguments) forRedo: true.
	self selectAt: self stopIndex
]

{ #category : #undoers }
ParagraphEditor >> undoReplace [
	"Undo of any command that replaced a selection by other text that it left
	 highlighted, and that is undone and redone by simple reversal of the
	 operation.  This is the most common Undoer; call replaceSelectionWith:
	 to get this setup.  Redoer: itself, so never isRedoing."

	self replaceSelectionWith: UndoSelection
]

{ #category : #'undo support' }
ParagraphEditor >> undoer: aSelector [
	"See comment in undoMessage:.  Use this version when aSelector has no arguments, and you are doing or redoing and want to prepare for undoing."

	self undoMessage: (Message selector: aSelector) forRedo: false
]

{ #category : #'undo support' }
ParagraphEditor >> undoer: aSelector with: arg1 [
	"See comment in undoMessage:.  Use this version when aSelector has one argument, and you are doing or redoing and want to prepare for undoing."

	self undoMessage: (Message selector: aSelector argument: arg1) forRedo: false
]

{ #category : #'undo support' }
ParagraphEditor >> undoer: aSelector with: arg1 with: arg2 [
	"See comment in undoMessage:.  Use this version when aSelector has two arguments, and you are doing or redoing and want to prepare for undoing."

	self undoMessage: (Message selector: aSelector arguments: (Array with: arg1 with: arg2)) forRedo: false
]

{ #category : #'undo support' }
ParagraphEditor >> undoer: aSelector with: arg1 with: arg2 with: arg3 [
	"See comment in undoMessage:.  Use this version when aSelector has three arguments, and you are doing or redoing and want to prepare for undoing."

	self undoMessage: (Message selector: aSelector arguments: (Array with: arg1 with: arg2 with: arg3)) forRedo: false
]

{ #category : #'accessing-selection' }
ParagraphEditor >> unselect [
	self markBlock: self pointBlock copy.
]

{ #category : #scrolling }
ParagraphEditor >> updateMarker [
	"A variation of computeMarkerRegion--only redisplay the marker in the scrollbar if an actual change has occurred in the positioning of the paragraph."
	self moveMarkerTo: self computeMarkerRegion
]

{ #category : #accessing }
ParagraphEditor >> userHasEdited [
	"Note that the user has edited my text. Here it is just a noop so that the Character Recognizer won't fail when used with a vanilla ParagrahEditor."

]

{ #category : #scrolling }
ParagraphEditor >> viewDelta [ 
	"Refer to the comment in ScrollController|viewDelta."

	^paragraph clippingRectangle top 
		- paragraph compositionRectangle top 
		- ((marker top - scrollBar inside top) asFloat 
				/ scrollBar inside height asFloat * self scrollRectangleHeight asFloat)
			roundTo: paragraph lineGrid
]

{ #category : #accessing }
ParagraphEditor >> visibleHeight [

	^paragraph clippingRectangle height
]

{ #category : #'accessing-selection' }
ParagraphEditor >> wasComposition [

	^ wasComposition ifNil: [^ false].

]

{ #category : #'menu messages' }
ParagraphEditor >> wordSelectAndEmptyCheck: returnBlock [
	"If the current selection is an insertion point, expand it to be the entire current word; if after that's done the selection is still empty, then evaluate the returnBlock, which will typically consist of '[^ self]' in the caller -- check senders of this method to understand this."

	self hasSelection ifFalse: [
		self selectWord.
		self hasSelection ifFalse: [
			self flash. 
			^ returnBlock value]].
]

{ #category : #'accessing-selection' }
ParagraphEditor >> zapSelectionWith: aText [
	"Deselect, and replace the selection text by aText.
	 Remember the resulting selectionInterval in UndoInterval and otherInterval.
	 Do not set up for undo."

	| start stop |
	self deselect.
	start := self startIndex.
	stop := self stopIndex.
	(aText isEmpty and: [stop > start]) ifTrue:
		["If deleting, then set emphasisHere from 1st character of the deletion"
		emphasisHere := (paragraph text attributesAt: start forStyle: paragraph textStyle)
					select: [:att | att mayBeExtended]].
	(start = stop and: [aText size = 0]) ifFalse:
		[paragraph
			replaceFrom: start
			to: stop - 1
			with: aText
			displaying: true.
		self computeIntervalFrom: start to: start + aText size - 1.
		self wasComposition ifTrue: [wasComposition := false. self setPoint: start + 1].
		UndoInterval := otherInterval := self selectionInterval]
]

{ #category : #'accessing-selection' }
ParagraphEditor >> zapSelectionWithCompositionWith: aString [
	"Deselect, and replace the selection text by aString.
	 Remember the resulting selectionInterval in UndoInterval and otherInterval.
	 Do not set up for undo."

	| stream newString aText beforeChar |
	wasComposition := false.
	((aString isEmpty or: [(beforeChar := self charBefore) isNil]) or: [
		aString size = 1 and: [(Unicode isComposition: aString first) not]]) ifTrue: [
			^ self zapSelectionWith: (Text string: aString emphasis: emphasisHere)].

	stream := UnicodeCompositionStream on: (String new: 16).
	stream nextPut: beforeChar.
	stream nextPutAll: aString.
	newString := stream contents.
	aText := Text string: newString emphasis: emphasisHere.
	self markBlock < self pointBlock
		ifTrue: [self setMark: self markBlock stringIndex - 1]
		ifFalse: [self setPoint: self  pointBlock stringIndex - 1].

	wasComposition := true. 
	self zapSelectionWith: aText.

]
