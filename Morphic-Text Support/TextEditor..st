"
See comment in Editor.

My instances edit Text, this is, they support multiple lines and TextAttributes.
They have no specific facilities for editing Smalltalk code. Those are found in SmalltalkEditor.
"
Class {
	#name : #TextEditor,
	#superclass : #Editor,
	#instVars : [
		'model',
		'paragraph',
		'markBlock',
		'pointBlock',
		'beginTypeInIndex',
		'emphasisHere',
		'lastParenLocation',
		'otherInterval',
		'oldInterval',
		'typeAhead',
		'history'
	],
	#classVars : [
		'AutoEnclose',
		'AutoIndent',
		'ChangeText',
		'EncloseSelection',
		'FindText'
	],
	#classInstVars : [
		'cmdActions',
		'shiftCmdActions',
		'yellowButtonMenu',
		'shiftedYellowButtonMenu'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #'class initialization' }
TextEditor class >> abandonChangeText [
	"Call this to get out of the maddening situation in which the system keeps aggressively trying to do a replacement that you no longer wish to make, every time you make choose a new method in a list."
	ChangeText := FindText

	"
	TextEditor abandonChangeText
	"
]

{ #category : #preferences }
TextEditor class >> autoEnclose [
	<preference: 'Auto enclose brackets () {} []'
		categoryList: #('Morphic' 'editing')
		description: 'When true, typing an opening parenthesis, bracket or square-bracket will also add its corresponding closing character after the cursor so you can type within the bracket.'
		type: #Boolean>
		
	^ AutoEnclose ifNil: [ false ]
]

{ #category : #preferences }
TextEditor class >> autoEnclose: aBoolean [
	AutoEnclose := aBoolean
]

{ #category : #preferences }
TextEditor class >> autoIndent [
	<preference: 'Auto indent on new line'
		categoryList: #('Morphic' 'editing')
		description: 'When true, tabs will be inserted after pressing Enter | Return such that the new line will be indented equally with the previous line.'
		type: #Boolean>
	^ AutoIndent ifNil: [ true ]
]

{ #category : #preferences }
TextEditor class >> autoIndent: aBoolean [
	AutoIndent := aBoolean
]

{ #category : #'class initialization' }
TextEditor class >> cleanUp [

	TextEditor allSubInstancesDo: [:editor |
		editor history ifNotNil: [:h | 
			h current ifNotNil: [editor closeTypeIn].
			h reset]].
]

{ #category : #accessing }
TextEditor class >> cmdActions [
	^cmdActions
]

{ #category : #preferences }
TextEditor class >> encloseSelection [
	<preference: 'Enclose selection with brackets () {} [] '''' "" || <>'
		categoryList: #('Morphic' 'editing')
		description: 'When true, selecting text and typing an opening parenthesis, bracket, square-bracket, single quote, or double quote will add corresponding character around the selection without requiring a cmd key.'
		type: #Boolean>
		
	^ EncloseSelection ifNil: [ false ]
]

{ #category : #preferences }
TextEditor class >> encloseSelection: boolean [

	EncloseSelection := boolean.
]

{ #category : #'class initialization' }
TextEditor class >> initialize [ 
	"Initialize the keyboard shortcut maps and the shared buffers
	for copying text across views and managing again and undo." 
 
	"TextEditor initialize"

	FindText := ChangeText := Text new.

	self initializeCmdKeyShortcuts.
	self initializeShiftCmdKeyShortcuts.
	self initializeYellowButtonMenu.
	self initializeShiftedYellowButtonMenu
]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeCmdKeyShortcuts [
	"Initialize the (unshifted) command-key (or alt-key) shortcut table."

	"NOTE: if you don't know what your keyboard generates, use Sensor kbdTest"

	"TextEditor initialize"

	| cmdMap cmds |
	cmdMap := Array new: 256 withAll: #noop:.		"use temp in case of a crash"
	cmdMap at: 1 + 1 put: #cursorHome:.				"home key"
	cmdMap at: 4 + 1 put: #cursorEnd:.				"end key"
	cmdMap at: 8 + 1 put: #backspace:.				"ctrl-H or delete key"
	cmdMap at: 11 + 1 put: #cursorPageUp:.			"page up key"
	cmdMap at: 12 + 1 put: #cursorPageDown:.		"page down key"
	cmdMap at: 13 + 1 put: #crWithIndent:.			"cmd-Return"
	cmdMap at: 27 + 1 put: #offerMenuFromEsc:.		"escape key"
	cmdMap at: 28 + 1 put: #cursorLeft:.				"left arrow key"
	cmdMap at: 29 + 1 put: #cursorRight:.				"right arrow key"
	cmdMap at: 30 + 1 put: #cursorUp:.				"up arrow key"
	cmdMap at: 31 + 1 put: #cursorDown:.				"down arrow key"
	cmdMap at: 32 + 1 put: #selectWord:.				"space bar key"
	cmdMap at: 127 + 1 put: #forwardDelete:.		"del key"
			
	'0123456789-=' 
		do: [:char | cmdMap at: char asciiValue + 1 put: #changeEmphasis:].
		
	'([<{|"''' do: [:char | cmdMap at: char asciiValue + 1 put: #enclose:].
	
	cmds := #($a #selectAll: $c #copySelection: $e #exchange: $f #find: $g #findAgain: $j #doAgain: $k #offerFontMenu: $u #align: $v #paste: $w #backWord: $x #cut: $y #swapChars: $z #undo:).
	1 to: cmds size
		by: 2
		do: [:i | cmdMap at: (cmds at: i) asciiValue + 1 put: (cmds at: i + 1)].
		
	cmdActions := cmdMap
]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeShiftCmdKeyShortcuts [ 
	"Initialize the shift-command-key (or control-key) shortcut table."
	"NOTE: if you don't know what your keyboard generates, use Sensor kbdTest"
	"wod 11/3/1998: Fix setting of cmdMap for shifted keys to actually use the 
	capitalized versions of the letters.
	TPR 2/18/99: add the plain ascii values back in for those VMs that don't return the shifted values."

	"TextEditor initialize"
	
	| cmdMap cmds |

	"shift-command and control shortcuts"
	cmdMap := Array new: 256 withAll: #noop:.  		"use temp in case of a crash"
	cmdMap at: ( 1 + 1) put: #cursorHome:.			"home key"
	cmdMap at: ( 4 + 1) put: #cursorEnd:.				"end key"
	cmdMap at: ( 8 + 1) put: #forwardDelete:.			"ctrl-H or delete key"
	cmdMap at: (11 + 1) put: #cursorPageUp:.			"page up key"
	cmdMap at: (12 + 1) put: #cursorPageDown:.		"page down key"
	cmdMap at: (13 + 1) put: #crWithIndent:.			"ctrl-Return"
	cmdMap at: (27 + 1) put: #offerMenuFromEsc:.	"escape key"
	cmdMap at: (28 + 1) put: #cursorLeft:.			"left arrow key"
	cmdMap at: (29 + 1) put: #cursorRight:.			"right arrow key"
	cmdMap at: (30 + 1) put: #cursorUp:.				"up arrow key"
	cmdMap at: (31 + 1) put: #cursorDown:.			"down arrow key"
	cmdMap at: (32 + 1) put: #selectWord:.			"space bar key"
	cmdMap at: (45 + 1) put: #changeEmphasis:.		"cmd-sh-minus"
	cmdMap at: (61 + 1) put: #changeEmphasis:.		"cmd-sh-plus"
	cmdMap at: (127 + 1) put: #forwardDelete:.		"del key"

	"On some keyboards, these characters require a shift"
	'([<{|"''9' do: [:char | cmdMap at: char asciiValue + 1 put: #enclose:].

	"NB: sw 12/9/2001 commented out the idiosyncratic line just below, which was grabbing shift-esc in the text editor and hence which argued with the wish to have shift-esc be a universal gesture for escaping the local context and calling up the desktop menu."  
	"cmdMap at: (27 + 1) put: #shiftEnclose:." 	"ctrl-["

	"'""''(' do: [ :char | cmdMap at: (char asciiValue + 1) put: #enclose:]."

	cmds := #(
		$c	compareToClipboard:
		$h	cursorTopHome:
		$j	doAgainUpToEnd:
		$k	changeStyle:
		$m	selectCurrentTypeIn:
		$s	findAgain:
		$u	changeLfToCr:
		$x	makeLowercase:
		$y	makeUppercase:
		$z	redo: "makeCapitalized:"
	).
	1 to: cmds size by: 2 do: [ :i |
		cmdMap at: ((cmds at: i) asciiValue + 1) put: (cmds at: i + 1).			"plain keys"
		cmdMap at: ((cmds at: i) asciiValue - 32 + 1) put: (cmds at: i + 1).		"shifted keys"
		cmdMap at: ((cmds at: i) asciiValue - 96 + 1) put: (cmds at: i + 1).		"ctrl keys"
	].
	shiftCmdActions := cmdMap
]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeShiftedYellowButtonMenu [
	"Initialize the yellow button pop-up menu and corresponding messages."

	"TextEditor initialize"
	"
	shiftedYellowButtonMenu := {
		{'set font... (k)' translated.					#offerFontMenu}.
		{'set style... (K)' translated.				#changeStyle}.
		{'set alignment...' translated.				#chooseAlignment}.
		#-.
		{'more...' translated.						#yellowButtonActivity}.
	}
	"
	shiftedYellowButtonMenu := yellowButtonMenu
]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeYellowButtonMenu [
	"Initialize the yellow button pop-up menu and corresponding messages."

	"TextEditor initialize"

	yellowButtonMenu := MenuMorph fromArray: {
		{'find...(f)' translated.				#find}.
		{'find again (g)' translated.				#findAgain}.
		{'find and replace ...' translated.			#findReplace}.
		{'do/replace again (j)' translated.			#again}.
		#-.
		{'undo (z)' translated.				#undo}.
		{'redo (Z)' translated.				#redo}.
		#-.
		{'copy (c)' translated.				#copySelection}.
		{'cut (x)' translated.				#cut}.
		{'paste (v)' translated.				#paste}.
		{'paste...' translated.				#pasteRecent}.
		#-.
		{'set font... (k)' translated.			#offerFontMenu}.
		{'set style... (K)' translated.		#changeStyle}.
		{'set alignment...' translated.		#chooseAlignment}.
		"
		#-.
		{'more...' translated.				#shiftedTextPaneMenuRequest}.
		"
	}
]

{ #category : #'class initialization' }
TextEditor class >> resetAllHistory [

	TextEditor allSubInstances do: [:editor |
		editor history reset].

	
]

{ #category : #accessing }
TextEditor class >> shiftCmdActions [
	^shiftCmdActions
]

{ #category : #'class initialization' }
TextEditor class >> shiftedYellowButtonMenu [
	"Answer the menu to be presented when the yellow button is pressed while the shift key is down"

	^ shiftedYellowButtonMenu
]

{ #category : #'class initialization' }
TextEditor class >> yellowButtonMenu [

	^ yellowButtonMenu
]

{ #category : #'editing keys' }
TextEditor >> abandonChangeText [
	^self class abandonChangeText
]

{ #category : #'menu messages' }
TextEditor >> accept [
	"Save the current text of the text being edited as the current acceptable version for purposes of canceling.  Allow my morph to take appropriate action"
	morph acceptContents
]

{ #category : #'typing support' }
TextEditor >> addString: aString [

	morph readOnly ifTrue: [^ self].

	"If we modifying the text like backward or forward delete, we have to finish that operation."
	(self isTypingIn and: [self history current type notNil])
		ifTrue: [self closeTypeIn].

	self typeAhead nextPutAll: aString.
]

{ #category : #'editing dragdrop' }
TextEditor >> addText: aText event: anEvent [
	"Used for dropping/inserting text."
	
	| index |
	index := (paragraph characterBlockAtPoint: anEvent position) stringIndex.
	self closeTypeIn.
	
	self selectInvisiblyFrom: index to: index-1.
	self replaceSelectionWith: aText.
]

{ #category : #'new selection' }
TextEditor >> afterSelectionInsertAndSelect: aString [

	self insertAndSelect: aString at: self stopIndex 
]

{ #category : #'menu messages' }
TextEditor >> again [
	"Do the same find/replace command again. Looks up the editor's own command history and uses the previous command to determine find string and replace string."
	
	self history hasReplacedSomething
		ifFalse: [morph flash. ^ false].
	
	self
		setSearchFromSelectionOrHistory;
		setReplacementFromHistory.
	
	"If we have no selection, give the user one to avoid annoying surprises."
	^ self hasSelection
		ifTrue: [self findReplaceAgainNow]
		ifFalse: [self findAgainNow. false "see #againUpToEnd"]
]

{ #category : #'menu messages' }
TextEditor >> againUpToEnd [
	"Find and replace until the end."
	
	| first |
	self again ifFalse: [^ self].

	first := self history previous.

	[self hasSelection] whileTrue: [
		self history previous
			isCompositeUndo: true;
			isCompositeRedo: true.
		self findReplaceAgainNow].

	first isCompositeUndo: false.
	
	self history previous isCompositeUndo: first ~~ self history previous.
	self history previous isCompositeRedo: false.
]

{ #category : #'menu messages' }
TextEditor >> align [
	"Align text according to the next greater alignment value,
	cycling among leftFlush, rightFlush, center, and justified."
	self changeAlignment.
	self recomputeSelection
]

{ #category : #'editing keys' }
TextEditor >> align: aKeyboardEvent [
	"Triggered by Cmd-u;  cycle through alignment alternatives.  8/11/96 sw"

	self align.
	^ true
]

{ #category : #private }
TextEditor >> applyAttribute: aTextAttribute [
	"The user selected aTextAttribute via shortcut, menu or other means.
	If there is a selection, apply the attribute to the selection.
	In any case use the attribute for the user input (emphasisHere)"
	| interval |

	emphasisHere := Text addAttribute: aTextAttribute toArray: emphasisHere.
	
	interval := self selectionInterval.
	(interval isEmpty and: [ aTextAttribute isParagraphAttribute not ])
		ifTrue: [ ^self ].
	
	self text addAttribute: aTextAttribute from: interval first to: interval last.
	paragraph recomposeFrom: interval first to: interval last delta: 0.
	self recomputeSelection.	"Needed so visible selection is updated to reflect new visual extent of selection"
	morph changed
]

{ #category : #'typing\/selecting keys' }
TextEditor >> argAdvance: aKeyboardEvent [ 
	"Invoked by Ctrl-a or Shift+Command+A.  Useful after Ctrl-q.
	 Search forward from the end of the selection for a colon and place the caret after it.  If no colon is found, do nothing."
	| start |
	self insertAndCloseTypeIn.
	start := paragraph text
		findString: ':'
		startingAt: self stopIndex.
	start isZero ifFalse: [ self selectAt: start + 1 ].
	^ true
]

{ #category : #'typing support' }
TextEditor >> autoEncloseFor: typedChar [ 
	"Answer whether typeChar was handled by auto-enclosure.  Caller should call normalCharacter if not."
	| openers closers |
	openers := '([{'.
	closers := ')]}'.
	(closers includes: typedChar) ifTrue:
		[ | pos |
		self blinkPrevParen: typedChar.
		((pos := self indexOfNextNonwhitespaceCharacter) notNil and: [ (paragraph string at: pos) = typedChar ])
			ifTrue:
				[ self
					moveCursor: [ : position | position + pos - pointBlock stringIndex + 1 ]
					forward: true
					select: false.
				^ true ]
			ifFalse: [ ^ false ] ].
	(openers includes: typedChar) ifTrue:
		[ self
			openTypeIn;
			addString: typedChar asString;
			addString: (closers at: (openers indexOf: typedChar)) asString;
			insertAndCloseTypeIn;
			
			moveCursor: [ : position | position - 1 ]
			forward: false
			select: false.
		^ true ].
	^ false
]

{ #category : #'typing support' }
TextEditor >> backTo: startIndex [
	"During typing, backspace to startIndex. If there already is a selection, just delete that selection. Otherwise, check if we did something else than backward-deletion and start a new command if so."

	morph readOnly ifTrue: [^ false].

	self hasSelection ifTrue: [
		"Add checkpoint in undo history."
		self replaceSelectionWith: self nullText.
		^ true].

	startIndex > self text size ifTrue: [^ false].

	self selectInvisiblyFrom: startIndex to: self stopIndex-1.
	
	self isTypingIn ifTrue: [
		self history current type = #backward
			ifFalse: [self closeTypeIn]
			ifTrue: [
				"Accumulate all deleted characters in current undo command."
				self history current contentsBefore replaceFrom: 1 to: 0 with: self selection.
				self history current intervalBefore in: [:i |
					self history current intervalBefore: (startIndex to: i last)]]].
		
	self openTypeInFor: #backward.
	self zapSelectionWith: self nullText.
	
	^ false
]

{ #category : #private }
TextEditor >> beginningOfLine: position [
	"Redefined in subclasses using Paragraph support"
	^ (paragraph lines at:(paragraph lineIndexOfCharacterIndex: position)) first
]

{ #category : #binding }
TextEditor >> bindingOf: aString [
	^model bindingOf: aString
]

{ #category : #parenblinking }
TextEditor >> blinkParen [
	"Used if Shout"
	lastParenLocation ifNotNil: [
		self text string size >= lastParenLocation ifTrue: [
			self text
				addAttribute: TextEmphasis bold
				from: lastParenLocation
				to: lastParenLocation]]
]

{ #category : #parenblinking }
TextEditor >> blinkParenAt: parenLocation [ 
	self text
		addAttribute: TextEmphasis bold
		from: parenLocation
		to: parenLocation.
	lastParenLocation := parenLocation.
]

{ #category : #parenblinking }
TextEditor >> blinkPrevParen: aCharacter [
	"Used if not Shout"
	| openDelimiter closeDelimiter level string here hereChar |
	string := paragraph string.
	here := pointBlock stringIndex.
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
						ifTrue: [level := level + 1]]]
]

{ #category : #'menu messages' }
TextEditor >> browseChangeSetsWithSelector [
	"Determine which, if any, change sets have at least one change for the selected selector, independent of class"

	| aSelector |
	self lineSelectAndEmptyCheck: [^ self].
	(aSelector := self selectedSelector) == nil ifTrue: [^ morph flash].
	ChangeSorter browseChangeSetsWithSelector: aSelector
]

{ #category : #'menu messages' }
TextEditor >> browseClassFromIt [
	"Launch a hierarchy browser for the class indicated by the current selection.  If multiple classes matching the selection exist, let the user choose among them."
	| aClass |
	self lineSelectAndEmptyCheck: [ ^ self ].
	aClass := UIManager default
		classFromPattern: self selection string withBlanksTrimmed
		withCaption: 'choose a class to browse...'
		in: model environment.
	aClass ifNil: [ ^ morph flash ].
	self systemNavigation
		spawnHierarchyForClass: aClass
		selector: nil
]

{ #category : #'menu messages' }
TextEditor >> browseIt [
	"Launch a browser for the current selection, if appropriate."

	Preferences alternativeBrowseIt ifTrue: [^ self browseClassFromIt].

	self lineSelectAndEmptyCheck: [^ morph flash].

	"First, try to show all accesses to instance or class variables."
	self selectedInstanceVariable ifNotNil:
		[:nameToClass | self systemNavigation
			browseAllAccessesTo: nameToClass key
			from: nameToClass value].
	self selectedClassVariable ifNotNil:
		[:binding | self model browseAllCallsOn: binding].

	"Then, either browse the class (from a binding) or all implementors of a selector."
	self selectedBinding ifNotNil:
		[:binding | ^ self systemNavigation browseClass: binding].
	self selectedSelector ifNotNil:
		[:selector | ^ self model browseAllImplementorsOf: selector].
	
	morph flash
]

{ #category : #'editing keys' }
TextEditor >> browseIt: aKeyboardEvent [
	"Triggered by Cmd-B; browse the thing represented by the current selection, if plausible.  1/18/96 sw"

	self browseIt.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> browseItHere [
	"Retarget the receiver's window to look at the selected class, if appropriate."

	self wordSelectAndEmptyCheck: [^ morph flash].

	((model isKindOf: Browser) and: [model couldBrowseAnyClass])
		ifFalse: [^ morph flash].
	model okToChange
		ifFalse: [^ morph flash].
			
	self selectedSymbol ifNotNil: [:symbol |
		(model environment classNamed: symbol) ifNotNil: [:class |
			^ model setClass: class]].
	
	morph flash
]

{ #category : #'editing keys' }
TextEditor >> browseItHere: aKeyboardEvent [ 
	"Triggered by Cmd-shift-B; browse the thing represented by the current selection, if plausible, in the receiver's own window.  3/1/96 sw"

	self browseItHere.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> cancel [
	"Cancel the changes made so far to this text"
	morph cancelEdits
]

{ #category : #'editing keys' }
TextEditor >> cancel: aKeyboardEvent [
	"Cancel unsubmitted changes."

	self cancel.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> changeAlignment [
	| options reply |
	options := self existingIndentation
		caseOf:
			{[0]-> [ #('leftFlush' 'indented' 'centered' 'justified' 'rightFlush') ].
			[1] -> [ #('leftFlush' 'indented more' 'centered' 'justified' 'rightFlush') ]}
		otherwise: [ #('leftFlush' 'indented less' 'indented more' 'centered' 'justified' 'rightFlush') ].
	reply := UIManager default chooseFrom: options values: options.
	reply ifNil: [ ^ self ].
	self setAlignment: reply.
	paragraph composeAll.
	self recomputeSelection.
	^ true
]

{ #category : #'editing keys' }
TextEditor >> changeEmphasis: aKeyboardEvent [ 
	"Change the emphasis of the current selection or prepare to accept characters with the change in emphasis. Emphasis change amounts to a font change.  Keeps typeahead."

	"control 0..9 -> 0..9"

	| keyCode attribute oldAttributes index thisSel colors extras |
	keyCode := ('0123456789-=' indexOf: aKeyboardEvent keyCharacter ifAbsent: [1]) - 1.
	oldAttributes := paragraph text attributesAt: self pointIndex.
	thisSel := self selection.

	"Decipher keyCodes for Command 0-9..."
	(keyCode between: 1 and: 5) 
		ifTrue: [attribute := TextFontChange fontNumber: keyCode].

	keyCode = 6 
		ifTrue: [
			colors := #(#black #magenta #red #yellow #green #blue #cyan #white).
			extras := self emphasisExtras.
			index := UIManager default chooseFrom:colors , #('choose color...' ), extras
						lines: (Array with: colors size + 1).
			index = 0 ifTrue: [^true].
			index <= colors size 
				ifTrue: [attribute := TextColor color: (Color perform: (colors at: index))]
				ifFalse: [
					index := index - colors size - 1.	"Re-number!!!"
					index = 0 
						ifTrue: [attribute := self chooseColor]
						ifFalse:[^self handleEmphasisExtra: index with: aKeyboardEvent]	"handle an extra"]].
	(keyCode between: 7 and: 11) 
		ifTrue: [
			aKeyboardEvent shiftPressed 
				ifTrue: [
					keyCode = 10 ifTrue: [attribute := TextKern kern: -1].
					keyCode = 11 ifTrue: [attribute := TextKern kern: 1]]
				ifFalse: [
					attribute := TextEmphasis 
								perform: (#(#bold #italic #narrow #underlined #struckOut) at: keyCode - 6).
					oldAttributes 
						do: [:att | (att dominates: attribute) ifTrue: [attribute turnOff]]]].
	keyCode = 0 ifTrue: [attribute := TextEmphasis normal].
	attribute ifNotNil: [
		thisSel size = 0
			ifTrue: [
				"only change emphasisHere while typing"
				self insertTypeAhead.
				emphasisHere := Text addAttribute: attribute toArray: oldAttributes ]
			ifFalse: [
				self replaceSelectionWith: (thisSel asText addAttribute: attribute) ]].
	^true
]

{ #category : #attributes }
TextEditor >> changeEmphasisOrAlignment [
	| aList reply  code align menuList startIndex |
	startIndex := self startIndex.
	aList := #(normal bold italic narrow underlined struckOut leftFlush centered rightFlush justified).	
	align := paragraph text alignmentAt: startIndex 
		ifAbsent: [ paragraph textStyle alignment ].
	code := paragraph text emphasisAt: startIndex.
	menuList := WriteStream on: Array new.
	menuList nextPut: (code isZero ifTrue:['<on>'] ifFalse:['<off>']), 'normal' translated.
	menuList nextPutAll: (#(bold italic underlined struckOut) collect:[:emph|
		(code anyMask: (TextEmphasis perform: emph) emphasisCode)
			ifTrue: [ '<on>', emph asString translated ]
			ifFalse: [ '<off>',emph asString translated ]]).
	((paragraph text attributesAt: startIndex)
		anySatisfy: [ :attr | attr isKern and: [attr kern < 0 ]]) 
			ifTrue: [ menuList nextPut:'<on>', 'narrow' translated ]
			ifFalse: [ menuList nextPut:'<off>', 'narrow' translated ].
	menuList nextPutAll: (#(leftFlush centered rightFlush justified) collectWithIndex: [ :type :i |
		align = (i-1)
			ifTrue: [ '<on>',type asString translated ]
			ifFalse: [ '<off>',type asString translated ]]).
	aList := #(normal bold italic underlined struckOut narrow leftFlush centered rightFlush justified).
	reply := UIManager default chooseFrom: menuList contents values: aList lines: #(1 6).
	reply notNil ifTrue: [
		(#(leftFlush centered rightFlush justified) includes: reply)
			ifTrue: [
				self setAlignment: reply.
				paragraph composeAll.
				self recomputeSelection]
			ifFalse: [
				self setEmphasis: reply.
				paragraph composeAll.
				self recomputeSelection]].
	^ true
]

{ #category : #'editing keys' }
TextEditor >> changeLfToCr: aKeyboardEvent [ 
	"Replace all LFs by CRs.
	Triggered by Cmd-U -- useful when getting code from FTP sites
	jmv- Modified to als change crlf by cr"
	
	| fixed |
	fixed := self selection string withSqueakLineEndings. 
	self replaceSelectionWith: (Text fromString: fixed).
	^ true
]

{ #category : #'initialize-release' }
TextEditor >> changeParagraph: aParagraph [ 
	"Install aParagraph as the one to be edited by the receiver."

	paragraph := aParagraph.
	self resetState
]

{ #category : #attributes }
TextEditor >> changeSelectionFontTo: aFont [ 
	| attr |
	aFont ifNil: [ ^ self ].
	attr := TextFontReference toFont: aFont.
	
	self openTypeIn.
	
	paragraph text
		addAttribute: attr
		from: self startIndex
		to:
			(self hasSelection
				ifTrue: [ self stopIndex - 1 min: paragraph text size ]
				ifFalse: [ paragraph text size ]).
	
	self closeTypeIn.
	
	paragraph composeAll.
	self recomputeSelection.
	morph changed
]

{ #category : #attributes }
TextEditor >> changeStyle [
	"Let user change styles for the current text pane."
	| names reply style current menuList |

	current := paragraph textStyle.
	names := TextStyle knownTextStyles.
	menuList := names collect: [ :styleName |
		styleName = current name
			ifTrue: [ '<on>', styleName ]
			ifFalse: [ '<off>', styleName ]].
	reply := UIManager default chooseFrom: menuList values: names.
	reply ifNotNil: [
		(style := TextStyle named: reply) ifNil: [Beeper beep. ^ true].
		paragraph textStyle: style.
		paragraph composeAll.
		self recomputeSelection].
	^ true
]

{ #category : #'typing\/selecting keys' }
TextEditor >> changeStyle: aKeyboardEvent [ 
	"Put up the style-change menu"

	self insertAndCloseTypeIn.
	self changeStyle.
	^ true
]

{ #category : #attributes }
TextEditor >> changeTextFont [
	"Present a dialog which allows the user to select a font, and if one is chosen, apply it to the current selection.	If there is no selection, or the selection is empty, apply it to the whole morph."
	| curFont startIndex |
	startIndex := self startIndex.
	curFont := (paragraph text fontAt: startIndex withStyle: paragraph textStyle).
	morph openModal: (
		Cursor wait showWhile: [ 
			(FontChooserTool default
				withTitle: 'Change the selected text''s font to...' translated
				for: self 
				setSelector: #changeSelectionFontTo:
				getSelector: curFont)
			"Do not allow changing the emphasis; we don't know how to deal with
			a 'pre-emphasized' font here, so bail."
					offerStyleList: false;
					open])
]

{ #category : #'menu messages' }
TextEditor >> chooseAlignment [
	self changeAlignment
]

{ #category : #'editing keys' }
TextEditor >> chooseColor [
	"Make a new Text Color Attribute, let the user pick a color, and return the attribute"
	| attribute |
	attribute := TextColor color: Color black.
	NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph on: attribute) openNear: morph fullBoundsInWorld ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: morph activeHand ;
				 target: attribute ;
				 selector: #color: ;
				 originalColor: Color black ;
				
				putUpFor: morph
				near: morph fullBoundsInWorld ].
	^ attribute
]

{ #category : #'menu messages' }
TextEditor >> classCommentsContainingIt [
	"Open a browser class comments which contain the current selection somewhere in them."

	self lineSelectAndEmptyCheck: [^ self].
	self systemNavigation browseClassCommentsWithString: self selection string
]

{ #category : #'menu messages' }
TextEditor >> classNamesContainingIt [
	"Open a browser on classes whose names contain the selected string"

	self lineSelectAndEmptyCheck: [^self].
	self systemNavigation
		browseClassesWithNamesContaining: self selection string
		caseSensitive: Sensor leftShiftDown
]

{ #category : #parenblinking }
TextEditor >> clearParens [
	lastParenLocation ifNotNil: [
		self text string size >= lastParenLocation ifTrue: [
			self text
				removeAttribute: TextEmphasis bold
				from: lastParenLocation
				to: lastParenLocation]].
	lastParenLocation := nil
]

{ #category : #events }
TextEditor >> click: evt [
	"This is called if you click in a text selection while drag is enabled, but you did not drag. Also see #startDrag:."
	
	self selectAt: (paragraph characterBlockAtPoint: evt position) stringIndex.
]

{ #category : #'typing support' }
TextEditor >> closeTypeIn [
	"See comment in openTypeIn.  It is important to call closeTypeIn before executing
	 any non-typing key, making a new selection, etc.  It is called automatically for
	 menu commands."

	| begin stop |
	beginTypeInIndex ifNotNil: [
		begin := beginTypeInIndex.
		stop := self stopIndex.
				
		self history current
			contentsAfter: (stop <= begin
				ifTrue: [self nullText]
				ifFalse: [paragraph text copyFrom: begin to: stop-1]);
			intervalAfter: (stop to: stop-1);
			intervalBetween: (stop < begin
				ifTrue: [stop to: stop-1]
				ifFalse: [begin to: stop-1]);
			messageToUndo: (Message selector: #undoAndReselect);
			messageToRedo: (Message selector: #redoAndReselect).
			
		self history finishRemember.

		beginTypeInIndex := nil]
]

{ #category : #'menu messages' }
TextEditor >> compareToClipboard [
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
TextEditor >> compareToClipboard: aKeyboardEvent [
	"Compare the receiver to the text on the clipboard."

	self compareToClipboard.
	^ true
]

{ #category : #'do-its' }
TextEditor >> compileSelectionFor: anObject in: evalContext [

	| methodNode |
	methodNode := [Compiler new
		compileNoPattern: self selectionAsStream
		in: anObject class
		context: evalContext
		environment: model environment
		notifying: self
		ifFail: [^nil]]
			on: OutOfScopeNotification
			do: [:ex | ex resume: true].
	^ methodNode generateWithTempNames
]

{ #category : #'editing keys' }
TextEditor >> copyHiddenInfo [
	"In TextLinks, TextDoits, TextColor, and TextURLs, there is hidden
info.  Copy that to the clipboard.  You can paste it and see what it is.
Usually enclosed in <>."

	^ self clipboardTextPut: self hiddenInfo
]

{ #category : #'menu messages' }
TextEditor >> copySelection [
	"Copy the current selection and store it in the paste buffer, unless a caret."

	self lineSelectAndEmptyCheck: [^ self].
	self clipboardTextPut: self selection.
]

{ #category : #'new selection' }
TextEditor >> correctFrom: start to: stop with: aString [
	"Make a correction in the model that the user has authorised from somewhere else in the system (such as from the compilier).  The user's selection is not changed, only corrected."
	| userSelection delta loc |
	aString = '#insert period' ifTrue: [
		loc := start.
		[(loc := loc-1)>0 and: [(paragraph string at: loc) isSeparator]]
			whileTrue: [loc := loc-1].
		^ self correctFrom: loc+1 to: loc with: '.'].
	userSelection := self selectionInterval.

	self selectInvisiblyFrom: start to: stop.
	self replaceSelectionWith: aString.

	delta := aString size - (stop - start + 1).
	self
		selectInvisiblyFrom: userSelection first + (userSelection first > start ifFalse: [ 0 ] ifTrue: [ delta ])
		to: userSelection last + (userSelection last > start ifFalse: [ 0 ] ifTrue: [ delta ]).
]

{ #category : #'typing\/selecting keys' }
TextEditor >> crWithIndent: aKeyboardEvent [ 
	"Replace the current text selection with CR followed by as many tabs
	as on the current line (+/- bracket count) -- initiated by Shift-Return."
	self addString: (String streamContents: [:characterStream | characterStream crtab: self tabCount]).  "Now inject CR with tabCount tabs"
	^ false
]

{ #category : #'nonediting\/nontyping keys' }
TextEditor >> cursorEnd: aKeyboardEvent [ 

	"Private - Move cursor end of current line."
	| string |
	self insertAndCloseTypeIn.
	string := paragraph text string.
	self
		moveCursor:
			[:position | Preferences wordStyleCursorMovement
				ifTrue:[| targetLine |
					targetLine := paragraph lines at:(paragraph lineIndexOfCharacterIndex: position).
					targetLine = paragraph lastLine
						ifTrue:[targetLine last + 1]
						ifFalse:[targetLine last]]
				ifFalse:[
					string
						indexOfAnyOf: CharacterSet crlf
						startingAt: position
						ifAbsent:[string size + 1]]]
		forward: true
		event: aKeyboardEvent
		specialBlock:[:dummy | string size + 1].
	^true
]

{ #category : #'nonediting\/nontyping keys' }
TextEditor >> cursorHome: aKeyboardEvent [ 

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
		event: aKeyboardEvent
		specialBlock: [:dummy | 1].
	^true
]

{ #category : #'menu messages' }
TextEditor >> cut [
	"Cut out the current selection and redisplay the paragraph if necessary.  Undoer & Redoer: undoCutCopy:"

	self lineSelectAndEmptyCheck: [^ self].

	self clipboardTextPut: self selection.
	self replaceSelectionWith: self nullText.
]

{ #category : #'do-its' }
TextEditor >> debugIt [

	| receiver context helperProcess |
	self lineSelectAndEmptyCheck: [^self].

	(model respondsTo: #debugExpression:)
		ifTrue: [^ model perform: #debugExpression: with: self selection].

	receiver := (model respondsTo: #doItReceiver) 
		ifTrue: [model doItReceiver]
		ifFalse: [nil].
		
	context := (model respondsTo: #doItContext) 
		ifTrue: [model doItContext]
		ifFalse: [nil].

	(self compileSelectionFor: receiver in: context) ifNotNil: [:doItMethod |
		helperProcess := context
			ifNil: [self assert: doItMethod selector = #DoIt.
				Process forMethod: doItMethod receiver: receiver]
			ifNotNil: [self assert: doItMethod selector = #DoItIn:.
				Process forMethod: doItMethod receiver: receiver arguments: {context}].
		helperProcess debugWithTitle: 'Debug it'].
]

{ #category : #'editing keys' }
TextEditor >> debugIt: aKeyboardEvent [

	self debugIt.
	^ true
]

{ #category : #'typing\/selecting keys' }
TextEditor >> destructiveBackWord: aKeyboardEvent [
	typeAhead isEmpty
		ifTrue: [ super destructiveBackWord: aKeyboardEvent ]
		ifFalse: [ typeAhead reset ].
	^ false
]

{ #category : #'typing support' }
TextEditor >> dispatchOnEnterWith: aKeyboardEvent [
	"Enter key hit.  Treat is as an 'accept', viz a synonym for cmd-s.  If cmd key is down, treat is as a synonym for print-it. "

	aKeyboardEvent commandKeyPressed
		ifTrue:
			[self printIt.]
		ifFalse: 
			[self insertAndCloseTypeIn.
			self accept].
	^ true
]

{ #category : #'typing support' }
TextEditor >> dispatchOnKeyboardEvent: aKeyboardEvent [ 
	"Carry out the action associated with this character, if any. Type-ahead is passed so some routines can flush or use it."
	
	| honorCommandKeys typedChar |
	typedChar := aKeyboardEvent keyCharacter.
	
	"Handle one-line input fields."
	(typedChar == Character cr and: [morph acceptOnCR])
		ifTrue: [^ true].
	
	"Clear highlight for last opened parenthesis."
	self clearParens.
	
	"Handle line breaks and auto indent."
	typedChar == Character cr ifTrue: [
		aKeyboardEvent controlKeyPressed
			ifTrue: [^ self normalCharacter: aKeyboardEvent].
		aKeyboardEvent shiftPressed
			ifTrue: [^ self lf: aKeyboardEvent].
		aKeyboardEvent commandKeyPressed
			ifTrue: [^ self crlf: aKeyboardEvent].
		^ self crWithIndent: aKeyboardEvent].

	"Handle indent/outdent with selected text block."
	typedChar == Character tab ifTrue: [
		aKeyboardEvent shiftPressed
			ifTrue: [self outdent: aKeyboardEvent. ^ true]
			ifFalse: [self hasMultipleLinesSelected
				ifTrue: [self indent: aKeyboardEvent. ^ true]]].

	honorCommandKeys := Preferences cmdKeysInText.

	(honorCommandKeys and: [typedChar == Character enter])
		ifTrue: [^ self dispatchOnEnterWith: aKeyboardEvent].
	
	"Special keys overwrite crtl+key combinations - at least on Windows. To resolve this
	conflict, assume that keys other than cursor keys aren't used together with Crtl."
	((self class specialShiftCmdKeys includes: aKeyboardEvent keyValue)
		and: [aKeyboardEvent keyValue < 27])
			ifTrue: [^ aKeyboardEvent controlKeyPressed
				ifTrue: [self
							perform: (self class shiftCmdActions at: aKeyboardEvent keyValue + 1)
							with: aKeyboardEvent]
				ifFalse: [self
							perform: (self class cmdActions at: aKeyboardEvent keyValue + 1)
							with: aKeyboardEvent]].
			
	"backspace, and escape keys (ascii 8 and 27) are command keys"
	((honorCommandKeys and: [aKeyboardEvent commandKeyPressed])
		or: [self class specialShiftCmdKeys includes: aKeyboardEvent keyValue])
			ifTrue: [ ^ aKeyboardEvent shiftPressed
				ifTrue: [self
							perform: (self class shiftCmdActions at: aKeyboardEvent keyValue + 1)
							with: aKeyboardEvent]
				ifFalse: [self
							perform: (self class cmdActions at: aKeyboardEvent keyValue + 1)
							with: aKeyboardEvent]].

	"the control key can be used to invoke shift-cmd shortcuts"
	(honorCommandKeys and: [ aKeyboardEvent controlKeyPressed ])
		ifTrue: [^ self
					perform: (self class shiftCmdActions at: aKeyboardEvent keyValue + 1)
					with: aKeyboardEvent].

	"Enclose selection with brackets etc."
	((self class encloseSelection and: [self hasSelection]) and: [self enclose: aKeyboardEvent])
		ifTrue: [^ true].

	"Automatically enclose paired characters such as brackets."
	(self class autoEnclose and: [self autoEncloseFor: typedChar])
		ifTrue: [^ true].
		
	"Even if no enclosing feature was used, highlight the matching bracket when closing one."
	(')]}' includes: typedChar)
		ifTrue: [self blinkPrevParen: typedChar].
					
	self normalCharacter: aKeyboardEvent.
	^ false
]

{ #category : #'typing\/selecting keys' }
TextEditor >> displayIfFalse: aKeyboardEvent [
	"Replace the current text selection with the text 'ifFalse:'--initiated by 
	ctrl-f."

	self addString: 'ifFalse:'.
	^false
]

{ #category : #'typing\/selecting keys' }
TextEditor >> displayIfTrue: aKeyboardEvent [
	"Replace the current text selection with the text 'ifTrue:'--initiated by 
	ctrl-t."

	self addString: 'ifTrue:'.
	^false
]

{ #category : #'typing\/selecting keys' }
TextEditor >> doAgain: aKeyboardEvent [ 
	"Do the previous thing again once. 1/26/96 sw"

	self insertAndCloseTypeIn.
	self again.
	^ true
]

{ #category : #'typing\/selecting keys' }
TextEditor >> doAgainUpToEnd: aKeyboardEvent [ 
	"Do the previous thing again once. 1/26/96 sw"

	self insertAndCloseTypeIn.
	self againUpToEnd.
	^ true
]

{ #category : #'do-its' }
TextEditor >> doIt [
	"Set the context to include pool vars of the model.  Then evaluate."
	^ self evaluateSelection
]

{ #category : #'editing keys' }
TextEditor >> doIt: aKeyboardEvent [
	"Called when user hits cmd-d.  Select the current line, if relevant, then evaluate and execute.  2/1/96 sw.
	2/29/96 sw: don't call selectLine; it's done by doIt now"

	self doIt.
	^ true
]

{ #category : #'editing keys' }
TextEditor >> emphasisExtras [
	"Answer an array of extra items for the emphasis menu"
	^#()
]

{ #category : #'editing keys' }
TextEditor >> enclose: aKeyboardEvent [
	"Insert or remove bracket characters around the current selection."

	| character left right startIndex stopIndex oldSelection which t |
	character := aKeyboardEvent shiftPressed
					ifTrue: ['{}|"<>' at: ('[]\'',.' indexOf: aKeyboardEvent keyCharacter) ifAbsent: [aKeyboardEvent keyCharacter]]
					ifFalse: [aKeyboardEvent keyCharacter].
	self closeTypeIn.
	startIndex := self startIndex.
	stopIndex := self stopIndex.
	oldSelection := self selection.
	which := '([<{|"''9' indexOf: character ifAbsent: [ ^ false ].
	"Allow Control key in lieu of Alt+Shift for (, {, and double-quote."
	left := ((Preferences cmdKeysInText and: [ aKeyboardEvent controlKeyPressed ])
		ifTrue: [ '({<{|""(' ]
		ifFalse: ['([<{|"''(']) at: which.
	right := ((Preferences cmdKeysInText and: [ aKeyboardEvent controlKeyPressed ])
		ifTrue: [ ')}>}|"")' ] 
		ifFalse: [')]>}|"'')']) at: which.
	t := self text.
	((startIndex > 1 and: [stopIndex <= t size])
			and: [ (t at: startIndex-1) = left and: [(t at: stopIndex) = right]])
		ifTrue:
			["already enclosed; strip off brackets"
			self selectFrom: startIndex-1 to: stopIndex.
			self replaceSelectionWith: oldSelection]
		ifFalse:
			["not enclosed; enclose by matching brackets"
			self replaceSelectionWith:
				(Text string: (String with: left), oldSelection string, (String with: right) attributes: emphasisHere).
			self selectFrom: startIndex+1 to: stopIndex].
	^true
]

{ #category : #'new selection' }
TextEditor >> encompassLine: anInterval [
	"Return an interval that encompasses the entire line"
	| string left right |
	string := paragraph text string.
	left := (string lastIndexOfAnyOf: CharacterSet crlf startingAt: anInterval first - 1) + 1.
	right := (string indexOfAnyOf: CharacterSet crlf startingAt: anInterval last + 1 ifAbsent: [string size + 1]) - 1.
	^left to: right
]

{ #category : #private }
TextEditor >> endOfLine: position [
	"Redefined in subclasses using Paragraph support"
	| targetLine |
	targetLine := paragraph lines at: (paragraph lineIndexFor: position).
	^ targetLine = paragraph lastLine
		ifFalse: [ targetLine last ]
		ifTrue: [ targetLine last + 1 ]
]

{ #category : #'do-its' }
TextEditor >> evaluateSelection [
	"Treat the current selection as an expression; evaluate it and return the result"
	
	^self evaluateSelectionAndDo: [:result | result]
]

{ #category : #'do-its' }
TextEditor >> evaluateSelectionAndDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	| result rcvr ctxt |
	self lineSelectAndEmptyCheck: [^ nil].

	(model respondsTo: #evaluateExpression:) ifTrue: [
		^ aBlock value: (model perform: #evaluateExpression: with: self selection)].

	(model respondsTo: #doItReceiver) 
		ifTrue: [ rcvr := model doItReceiver.
				ctxt := model doItContext]
		ifFalse: [rcvr := ctxt := nil].
	result := [
		rcvr class evaluatorClass new 
			evaluate: self selectionAsStream
			in: ctxt
			to: rcvr
			environment: (model environment ifNil: [Smalltalk globals])
			notifying: self
			ifFail: [morph flash. ^ nil]
			logged: true.
	] 
		on: OutOfScopeNotification 
		do: [ :ex | ex resume: true].
		
	(model respondsTo: #expressionEvaluated:result:) ifTrue: [
		model perform: #expressionEvaluated:result: with: self selection with: result].
		
	^aBlock value: result
]

{ #category : #'menu messages' }
TextEditor >> exchange [
	"See comment in exchangeWith:"

	self exchangeWith: otherInterval.
]

{ #category : #'editing keys' }
TextEditor >> exchange: eKeyboardEvent [
	"Exchange the current and prior selections.  Keeps typeahead."

	self insertAndCloseTypeIn.
	self exchange.
	^true
]

{ #category : #private }
TextEditor >> exchangeWith: prior [
	"If the prior selection is non-overlapping and legal, exchange the text of
	 it with the current selection and leave the currently selected text selected
	 in the location of the prior selection (or leave a caret after a non-caret if it was
	 exchanged with a caret).  If both selections are carets, flash & do nothing.
	 Don't affect the paste buffer."

	| start stop before selection priorSelection delta altInterval |
	start := self startIndex.
	stop := self stopIndex - 1.
	
	(((prior first <= prior last) and: [start <= stop])
		and: [self isDisjointFrom: prior])
			ifFalse: [morph flash. ^ self].
		
	before := prior last < start.
	selection := self selection.
	priorSelection := paragraph text copyFrom: prior first to: prior last.
	delta := before ifTrue: [0] ifFalse: [priorSelection size - selection size].
	
	"Create first undo command."
	self replaceSelectionWith: priorSelection.
	self history previous isCompositeRedo: true.
	
	self selectInvisiblyFrom: prior first + delta to: prior last + delta.
	delta := before ifTrue: [stop - prior last] ifFalse: [start - prior first].

	"Create second undo command."
	self replaceSelectionWith: selection.
	self history previous isCompositeUndo: true.

	altInterval := prior first + delta to: prior last + delta.
				
	"If one was a caret, make it otherInterval & leave the caret after the other"
	prior first > prior last ifTrue: [self selectAt: prior last + 1].
	otherInterval := start > stop
		ifTrue: [self selectAt: altInterval last + 1. prior]
		ifFalse: [altInterval]
]

{ #category : #private }
TextEditor >> existingIndentation [
	^ paragraph text indentationAmountAt: (self encompassLine: self selectionInterval)
]

{ #category : #'menu messages' }
TextEditor >> explain [
	"Try to shed some light on what kind of entity the current selection is. 
	The selection must be a single token or construct. Insert the answer after 
	the selection. Send private messages whose names begin with 'explain' 
	that return a string if they recognize the selection, else nil."

	
Cursor execute showWhile: 
			[ | string numbers delimitors cgVars reply selectors tiVars symbol sorry |
			sorry := '"Sorry, I can''t explain that.  Please select a single
token, construct, or special character.'.
			sorry := sorry , (morph canDiscardEdits
							ifFalse: ['  Also, please cancel or accept."']
							ifTrue: ['"']).
			(string := self selection asString) isEmpty
				ifTrue: [reply := '']
				ifFalse: [string := self explainScan: string.
					"Remove space, tab, cr"
					"Temps and Instance vars need only test strings that are all letters"
					(string allSatisfy: [:char | char isLetter or: [char isDigit]])
						ifTrue: 
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
TextEditor >> explainAnySel: symbol [ 
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
TextEditor >> explainChar: string [
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
	char = $_ ifTrue: [^'"Left arrow means assignment (deprecated, applies if the Preference for allow underscore assignment is set).  The value of the expression after the left arrow is stored into the variable before it."'].
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
TextEditor >> explainClass: symbol [ 
	"Is symbol a class variable or a pool variable?"
	| class reply classes |
	(model respondsTo: #selectedClassOrMetaClass)
		ifFalse: [^ nil].
	(class := model selectedClassOrMetaClass) ifNil: [^ nil].
	"no class is selected"
	(class isKindOf: Metaclass)
		ifTrue: [class := class soleInstance].
	classes := class withAllSuperclasses.
	"class variables"
	reply := classes detect: [:each | each classVarNames anySatisfy: [:name | symbol = name]]
				ifNone: [].
	reply == nil ifFalse: [^ '"is a class variable, defined in class ' , reply printString , '"\' withCRs , 'SystemNavigation new browseAllCallsOn: (' , reply printString , ' classPool associationAt: #' , symbol , ').'].
	"pool variables"
	classes do: [:each | each sharedPools
			anySatisfy: [:pool | (pool includesKey: symbol)
					and: 
						[reply := pool.
						true]]].
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
TextEditor >> explainCtxt: symbol [ 
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

{ #category : #explain }
TextEditor >> explainDelimitor: string [
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
TextEditor >> explainGlobal: symbol [ 
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
TextEditor >> explainInst: string [ 
	"Is string an instance variable of this class?"
	| classes cls |

	(model respondsTo: #selectedClassOrMetaClass) ifTrue: [
		cls := model selectedClassOrMetaClass].
	cls ifNil: [^ nil].	  "no class known"
	classes := (Array with: cls)
				, cls allSuperclasses.
	classes := classes detect: [:each | each instVarNames anySatisfy: [:name | name = string]] ifNone: [^nil].
	classes := classes printString.
	^ '"is an instance variable of the receiver; defined in class ' , classes , 
		'"\' withCRs , classes , ' systemNavigation browseAllAccessesTo: ''' , string , ''' from: ', classes, '.'
]

{ #category : #explain }
TextEditor >> explainMySel: symbol [ 
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
TextEditor >> explainNumber: string [ 
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
TextEditor >> explainPartSel: string [ 
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
			(whole := lits detect: [:each | (each keywords detect: [:frag | frag = string]
							ifNone: []) ~~ nil]
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
TextEditor >> explainScan: string [ 
	"Remove beginning and trailing space, tab, cr.
	 1/15/96 sw: copied intact from BrowserCodeController"

	| c beg end |
	beg := 1.
	end := string size.
	
	[beg = end ifTrue: [^string copyFrom: 1 to: 1].
	"if all blank, tell about the first"
	c := string at: beg.
	c = Character space or: [c = Character tab or: [c = Character cr]]]
		whileTrue: [beg := beg + 1].
	
	[c := string at: end.
	c = Character space or: [c = Character tab or: [c = Character cr]]]
		whileTrue: [end := end - 1].
	^string copyFrom: beg to: end	"Return purely visible characters"
]

{ #category : #explain }
TextEditor >> explainTemp: string [ 
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
TextEditor >> exploreIt [

	 self evaluateSelectionAndDo: [:result |
		(model respondsTo: #exploreIt:result:)
			ifTrue: [model
				perform: #exploreIt:result:
				with: self selection
				with: result]
			ifFalse: [result explore]].
]

{ #category : #'editing keys' }
TextEditor >> exploreIt: aKeyboardEvent [
	"Explore the selection -- invoked via cmd-shift-I.  If there is no current selection, use the current line."

	self exploreIt.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> fileItIn [
	"Make a Stream on the text selection and fileIn it.
	 1/24/96 sw: moved here from FileController; this function can be useful from any text window that shows stuff in chunk format"

	self selectionAsStream fileIn

]

{ #category : #'editing keys' }
TextEditor >> fileItIn: aKeyboardEvent [
	"File in the selection; invoked via a keyboard shortcut, -- for now, cmd-shift-G."

	self fileItIn.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> find [
	"Prompt the user for a string to search for, and search the receiver from the current selection onward for it.  1/26/96 sw"

	self setSearchFromSelectionOrHistory.

	(UIManager default request: 'Find what to select? ' initialAnswer: FindText)
		ifEmpty: [^ self]
		ifNotEmpty: [:reply |
			FindText := reply.
			self findAgainNow].
]

{ #category : #'typing\/selecting keys' }
TextEditor >> find: aKeyboardEvent [
	"Prompt the user for what to find, then find it, searching from the current selection onward."

	self
		insertAndCloseTypeIn;
		find.

	^ true
]

{ #category : #'menu messages' }
TextEditor >> findAgain [

	self setSearchFromSelectionOrHistory.
	
	^ self findAgainNow
]

{ #category : #'typing\/selecting keys' }
TextEditor >> findAgain: aKeyboardEvent [ 
	"Find the desired text again."

	self
		insertAndCloseTypeIn;
		findAgain.
	
	^ true
]

{ #category : #'typing support' }
TextEditor >> findAgainNow [

	| where |	
	where := self text
				findString: FindText
				startingAt: self stopIndex
				caseSensitive: Preferences caseSensitiveFinds.
	
	where = 0
		ifTrue: [self selectFrom: self stopIndex to: self stopIndex - 1]
		ifFalse: [self selectFrom: where to: where + FindText size - 1].

	^ true
]

{ #category : #'menu messages' }
TextEditor >> findReplace [

	self
		setSearchFromSelectionOrHistory;
		setReplacementFromHistory.

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
							self findReplaceAgainNow]]
]

{ #category : #'typing\/selecting keys' }
TextEditor >> findReplace: aKeyboardEvent [

	self
		insertAndCloseTypeIn;
		findReplace.
		
	^ true
]

{ #category : #'menu messages' }
TextEditor >> findReplaceAgain [
		
	^ self again
]

{ #category : #'typing\/selecting keys' }
TextEditor >> findReplaceAgain: aKeyboardEvent [ 

	self
		insertAndCloseTypeIn;
		findReplaceAgain.

	^ true
]

{ #category : #'typing support' }
TextEditor >> findReplaceAgainNow [

	self hasSelection ifTrue: [
		"Search from the beginning of the current selection. Supports a nice combination with regular find feature."
		self selectInvisiblyFrom: self startIndex to: self startIndex - 1].
	
	self findAgainNow.
	self hasSelection ifFalse: [^ false].

	self replaceSelectionWith: ChangeText.
	self findAgainNow. "Select possible next thing to replace."

	^ true
]

{ #category : #displaying }
TextEditor >> flash [
	^ morph flash
]

{ #category : #'typing\/selecting keys' }
TextEditor >> forwardDelete: aKeyboardEvent [
	"Delete forward over the next character.
	  Make Undo work on the whole type-in, not just the one char.
	wod 11/3/1998: If there was a selection use #zapSelectionWith: rather than #backspace: which was 'one off' in deleting the selection. Handling of things like undo or typeIn area were not fully considered."

	| startIndex stopIndex |
	morph readOnly ifTrue: [^ self].
	
	self hasSelection ifTrue: [
		"Create checkpoint in history."
		self replaceSelectionWith: self nullText.
		^ true].

	startIndex := self markIndex.
	startIndex > self text size ifTrue: [^ false].

	stopIndex := startIndex.

	"Forward delete next word"
	self flag: #consistency. "mt: We might want to implemented it like #backspace: and #backWord:."
	aKeyboardEvent shiftPressed
		ifTrue: [stopIndex := (self firstWordBoundaryAfter: stopIndex) - 1].

	self selectInvisiblyFrom: startIndex to: stopIndex.
	
	self isTypingIn ifTrue: [
		self history current type = #forwardDelete
			ifFalse: [self closeTypeIn]
			ifTrue: [
				"Append next characters that will be removed."
				self history current contentsBefore append: self selection.
				self history current intervalBefore in:  [:i |
					self history current intervalBefore: (i first to: i last + (stopIndex - startIndex + 1))]]].
	
	self openTypeInFor: #forwardDelete.
	self zapSelectionWith: self nullText.
	
	^ false
]

{ #category : #'editing keys' }
TextEditor >> handleEmphasisExtra: index with: aKeyboardEvent [
	"Handle an emphasis extra choice"
	^true
]

{ #category : #'accessing-selection' }
TextEditor >> hasCaret [
	^ markBlock = pointBlock
]

{ #category : #'typing support' }
TextEditor >> hasMultipleLinesSelected [
	^ self selection includesAnyOf: CharacterSet crlf
]

{ #category : #'editing keys' }
TextEditor >> hiddenInfo [
	"In TextLinks, TextDoits, TextColor, and TextURLs, there is hidden info.  Return the entire string that was used by Cmd-6 to create this text attribute.  Usually enclosed in < >."

	| attrList |
	attrList := self text attributesAt: (self pointIndex + self markIndex)//2.
	attrList do: [:attr |
		(attr isKindOf: TextAction) ifTrue:
			[^ self selection asString, '<', attr info, '>']].
	"If none of the above"
	attrList do: [:attr |
		attr class == TextColor ifTrue:
			[^ self selection asString, '<', attr color printString, '>']].
	^ self selection asString, '[No hidden info]'
]

{ #category : #accessing }
TextEditor >> history [
	^ history
]

{ #category : #accessing }
TextEditor >> history: commandHistory [
	history := commandHistory.
]

{ #category : #'menu messages' }
TextEditor >> implementorsOfIt [
	"Open an implementors browser on the selected selector"

	self lineSelectAndEmptyCheck: [^ self].
	self selectedSelector ifNotNil:
		[:aSelector| ^self model browseAllImplementorsOf: aSelector].
	self selectedLiteral ifNotNil:
		[:aLiteral| ^self model browseAllImplementorsOf: aLiteral].
	morph flash.
]

{ #category : #'editing keys' }
TextEditor >> implementorsOfIt: aKeyboardEvent [
	"Triggered by Cmd-m; browse implementors of the selector represented by the current selection, if plausible. 2/1/96 sw"

	self implementorsOfIt.
	^ true
]

{ #category : #'editing keys' }
TextEditor >> inOutdent: aKeyboardEvent delta: delta [
	"Add/remove a tab at the front of every line occupied by the selection. Flushes typeahead.  Derived from work by Larry Tesler back in December 1985.  Now triggered by Cmd-L and Cmd-R.  2/29/96 sw"

	| realStart realStop lines startLine stopLine start stop adjustStart "indentation" numLines oldText newText newSize |

	"Operate on entire lines, but remember the real selection for re-highlighting later"
	realStart := self startIndex.
	realStop := self stopIndex - 1.

	"Special case a caret on a line of its own, including weird case at end of paragraph"
	(realStart > realStop and:
				[realStart < 2 or: [(paragraph string at: realStart - 1) == Character cr or: [(paragraph string at: realStart - 1) == Character lf]]])
		ifTrue:
			[delta < 0
				ifTrue:
					[morph flash]
				ifFalse:
					[self replaceSelectionWith: Character tab asText.
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
TextEditor >> indent: aKeyboardEvent [
	"Add a tab at the front of every line occupied by the selection. Invoked from keyboard via cmd-shift-R.  2/29/96 sw"

	^ self inOutdent: aKeyboardEvent delta: 1
]

{ #category : #private }
TextEditor >> indent: delta fromStream: inStream toStream: outStream [
	"Append the contents of inStream to outStream, adding or deleting delta or -delta
	 tabs at the beginning, and after every CR except a final CR.  Do not add tabs
	 to totally empty lines, and be sure nothing but tabs are removed from lines."

	| ch skip cr tab prev atEnd |
	cr := Character cr.
	tab := Character tab.
	delta > 0
		ifTrue: "shift right"
			[prev := cr.
			 [ch := (atEnd := inStream atEnd) ifTrue: [cr] ifFalse: [inStream next].
			  (prev == cr and: [ch ~~ cr]) ifTrue:
				[delta timesRepeat: [outStream nextPut: tab]].
			  atEnd]
				whileFalse:
					[outStream nextPut: ch.
					prev := ch]]
		ifFalse: "shift left"
			[skip := delta. "a negative number"
			 [inStream atEnd] whileFalse:
				[((ch := inStream next) == tab and: [skip < 0]) ifFalse:
					[outStream nextPut: ch].
				skip := ch == cr ifTrue: [delta] ifFalse: [skip + 1]]]
]

{ #category : #private }
TextEditor >> indexOfNextNonwhitespaceCharacter [
	pointBlock stringIndex
		to: paragraph string size
		do:
			[ : n | | char | (char := paragraph string at: n) isSeparator ifFalse: [ ^ n ] ].
	^ nil
]

{ #category : #'typing support' }
TextEditor >> insertAndCloseTypeIn [
	self
		insertTypeAhead ;
		closeTypeIn
]

{ #category : #'new selection' }
TextEditor >> insertAndSelect: aString at: anInteger [

	self closeTypeIn.
	
	self selectInvisiblyFrom: anInteger to: anInteger - 1.
	self openTypeIn.

	self
		replace: self selectionInterval
		with: (Text string: (' ', aString) attributes: emphasisHere)
		and: [].

	self closeTypeIn.
]

{ #category : #'typing support' }
TextEditor >> insertTypeAhead [
	self typeAhead position = 0 ifFalse:
		[self zapSelectionWith: (Text string: self typeAhead contents emphasis: emphasisHere).
		self typeAhead reset.
		self unselect]
]

{ #category : #'do-its' }
TextEditor >> inspectIt [

	 self evaluateSelectionAndDo: [:result |
		(model respondsTo: #inspectIt:result:)
			ifTrue: [model
				perform: #inspectIt:result:
				with: self selection
				with: result]
			ifFalse: [ToolSet inspect: result]].
]

{ #category : #'editing keys' }
TextEditor >> inspectIt: aKeyboardEvent [
	"Inspect the selection -- invoked via cmd-i.  If there is no current selection, use the current line.  1/17/96 sw
	 2/29/96 sw: don't call selectLine; it's done by inspectIt now"

	self inspectIt.
	^ true
]

{ #category : #private }
TextEditor >> isDisjointFrom: anInterval [
	"Answer true if anInterval is a caret not touching or within the current
	 interval, or if anInterval is a non-caret that does not overlap the current
	 selection."

	| fudge |
	fudge := anInterval size = 0 ifTrue: [1] ifFalse: [0].
	^(anInterval last + fudge < self startIndex or:
			[anInterval first - fudge >= self stopIndex])

]

{ #category : #events }
TextEditor >> isEventInSelection: evt [
	"Check whether the event position is within the current selection."

	| pt a b |	
	self hasSelection ifFalse: [^ false].

	pt := evt position.
	a := self startBlock.
	b := self stopBlock.
	
	^ (pt >= a topLeft and: [pt <= b bottomLeft]) "Start and stop in same line"
		or: [
			a top < b top and: [ "Start and stop in different lines."
				((pt y > a bottom and: [pt y < b top]) "Fully selected lines in the middle."
					or: [pt x >= a left and: [pt y between: a top and: a bottom]]) "Top tail."
					or: [pt x <= b left and: [pt y between: b top and: b bottom]]]]. "Bottom tail."
	
	
	

	
]

{ #category : #'typing support' }
TextEditor >> isTypingIn [
	^ beginTypeInIndex notNil
]

{ #category : #events }
TextEditor >> keyStroke: anEvent [
 	self resetTypeAhead.

	(self dispatchOnKeyboardEvent: anEvent) 
		ifTrue: [
			self closeTypeIn.
			self storeSelectionInParagraph.
			^self].

	self openTypeIn.
	self 
		zapSelectionWith: self typeAhead contents; 
		resetTypeAhead;
		unselect;
		storeSelectionInParagraph.
]

{ #category : #'editing keys' }
TextEditor >> makeCapitalized: aKeyboardEvent [
	"Force the current selection to uppercase."

	| prev |
	prev := $-.  "not a letter"
	self replaceSelectionWith: 
		(self selection string collect:
			[:c | prev := prev isLetter ifTrue: [c asLowercase] ifFalse: [c asUppercase]]).
	^ true
]

{ #category : #'editing keys' }
TextEditor >> makeLowercase: aKeyboardEvent [
	"Force the current selection to lowercase.  Triggered by Cmd-X."

	self replaceSelectionWith: (self selection string asLowercase).
	^ true
]

{ #category : #'editing keys' }
TextEditor >> makeUppercase: aKeyboardEvent [
	"Force the current selection to uppercase.  Triggered by Cmd-Y."

	self replaceSelectionWith: (self selection string asUppercase).
	^ true
]

{ #category : #'accessing-selection' }
TextEditor >> markIndex [
	^ markBlock stringIndex
]

{ #category : #'accessing-selection' }
TextEditor >> markIndex: anIndex pointIndex: anotherIndex [
	"Called, for example, when selecting text with shift+arrow keys"
	markBlock := paragraph characterBlockForIndex: anIndex.
	pointBlock := paragraph characterBlockForIndex: anotherIndex
]

{ #category : #'menu messages' }
TextEditor >> methodNamesContainingIt [
	"Open a browser on methods names containing the selected string"

	self lineSelectAndEmptyCheck: [^ self].
	Cursor wait showWhile:
		[self systemNavigation browseMethodsWhoseNamesContain: self selection string withBlanksTrimmed].
	Cursor normal show
]

{ #category : #'editing keys' }
TextEditor >> methodNamesContainingIt: aKeyboardEvent [ 
	"Browse methods whose selectors containing the selection in their names"

	self methodNamesContainingIt.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> methodSourceContainingIt [
	"Open a browser on methods which contain the current selection in their source (case-sensitive full-text search of source). Slow!"

	self lineSelectAndEmptyCheck: [^ self].
	self systemNavigation browseMethodsWithSourceString: self selection string
]

{ #category : #'editing keys' }
TextEditor >> methodStringsContainingIt: aKeyboardEvent [ 
	"Invoked from cmd-E -- open a browser on all methods holding string constants containing it.  Flushes typeahead. "

	self methodStringsContainingit.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> methodStringsContainingit [
	"Open a browser on methods which contain the current selection as part of a string constant."

	self lineSelectAndEmptyCheck: [^ self].
	self systemNavigation browseMethodsWithString: self selection string
]

{ #category : #accessing }
TextEditor >> model [

	^model
]

{ #category : #'model access' }
TextEditor >> model: aModel [
	model := aModel
]

{ #category : #events }
TextEditor >> mouseDown: evt [ 
	"Either 1) handle text actions in the paragraph, 2) begin a text drag operation, or 3) modify the caret/selection."
	
	| clickPoint b |

	oldInterval := self selectionInterval.
	clickPoint := evt cursorPoint.
	b := paragraph characterBlockAtPoint: clickPoint.

	(paragraph clickAt: clickPoint for: model controller: self) ifTrue: [
		markBlock := b.
		pointBlock := b.
		evt hand releaseKeyboardFocus: morph.
		evt hand releaseMouseFocus: morph.
		^ self ].
	
	(morph dragEnabled and: [self isEventInSelection: evt]) ifTrue: [
		evt hand
			waitForClicksOrDrag: morph
			event: evt
			selectors: {#click:. nil. nil. #startDrag:}
			threshold: HandMorph dragThreshold.
		morph setProperty: #waitingForTextDrag toValue: true.
		^ self].
	
	evt shiftPressed
		ifFalse: [
			self closeTypeIn.
			markBlock := b.
			pointBlock := b ]
		 ifTrue: [
			self closeTypeIn.
			self mouseMove: evt ].
       self storeSelectionInParagraph
]

{ #category : #events }
TextEditor >> mouseMove: evt [
	"Change the selection in response to mouse-down drag. Do not change the selection if the user wants to drag the current selection."

	(morph hasProperty: #waitingForTextDrag) ifTrue: [^ self].
	pointBlock := paragraph characterBlockAtPoint: evt position.
	self storeSelectionInParagraph
]

{ #category : #events }
TextEditor >> mouseUp: evt [
	"An attempt to break up the old processRedButton code into threee phases"

	oldInterval ifNil: [^ self].  "Patched during clickAt: repair"
	(self hasCaret 
		and: [oldInterval = self selectionInterval])
		ifTrue: [self selectWord].
	self setEmphasisHere.
	(self isDisjointFrom: oldInterval) ifTrue:
		[otherInterval := oldInterval].
	self storeSelectionInParagraph.

	self updateCursorForEvent: evt.
	morph removeProperty: #waitingForTextDrag.
]

{ #category : #private }
TextEditor >> moveCursor: directionBlock forward: forward event: aKeyboardEvent specialBlock: specialBlock [ 
	super moveCursor: directionBlock forward: forward event: aKeyboardEvent specialBlock: specialBlock.
	self setEmphasisHere
]

{ #category : #'new selection' }
TextEditor >> nextTokenFrom: start direction: dir [
	"simple token-finder for compiler automated corrections"
	| loc str |
	loc := start + dir.
	str := paragraph string.
	[(loc between: 1 and: str size) and: [(str at: loc) isSeparator]]
		whileTrue: [loc := loc + dir].
	^ loc
]

{ #category : #'new selection' }
TextEditor >> notify: aString at: anInteger in: aStream [ 
	"The compilation of text failed. The syntax error is noted as the argument, 
	aString. Insert it in the text at starting character position anInteger."

	self insertAndSelect: aString at: (anInteger max: 1)
]

{ #category : #private }
TextEditor >> nullText [

	^Text string: '' attributes: emphasisHere
]

{ #category : #attributes }
TextEditor >> offerFontMenu [
	"Present a menu of available fonts, and if one is chosen, apply it to the current selection.  
	Use only names of Fonts of this paragraph  "
	
	^self changeTextFont
]

{ #category : #'editing keys' }
TextEditor >> offerFontMenu: aKeyboardEvent [ 
	"The user typed the command key that requests a font change; Offer the font menu.  5/27/96 sw"

	self insertAndCloseTypeIn.
	self offerFontMenu.
	^ true
]

{ #category : #'menu commands' }
TextEditor >> offerMenuFromEsc: aKeyboardEvent [ 
	"The escape key was hit while the receiver has the keyboard focus; take action."

	aKeyboardEvent shiftPressed ifFalse: [
		self raiseContextMenu: aKeyboardEvent].
	^ true
]

{ #category : #'typing support' }
TextEditor >> openTypeIn [

	self openTypeInFor: nil.
]

{ #category : #'typing support' }
TextEditor >> openTypeInFor: editType [
	"Set up UndoSelection to null text (to be added to by readKeyboard and backTo:),
	 beginTypeInBlock to keep track of the leftmost backspace, and UndoParameter to tally
	 how many deleted characters were backspaced over rather than 'cut'.
	 You can't undo typing until after closeTypeIn."

	beginTypeInIndex ifNil: [
		beginTypeInIndex := self startIndex.
		self history beginRemember: (TextEditorCommand new
			type: editType;
			contentsBefore: (self hasSelection ifTrue: [self selection] ifFalse: [self nullText]);
			intervalBefore: (beginTypeInIndex to: self stopIndex-1)
			yourself)].
]

{ #category : #'editing keys' }
TextEditor >> outdent: aKeyboardEvent [
	"Remove a tab from the front of every line occupied by the selection.
	Invoked from keyboard via cmd-shift-L.  2/29/96 sw"

	^ self inOutdent: aKeyboardEvent delta: -1
]

{ #category : #private }
TextEditor >> pageHeight [
	| howManyLines visibleHeight totalHeight ratio |
	howManyLines := paragraph numberOfLines.
	visibleHeight := self visibleHeight.
	totalHeight := self totalTextHeight.
	ratio := visibleHeight / totalHeight.
	^(ratio * howManyLines) rounded - 2
]

{ #category : #accessing }
TextEditor >> paragraph [

	^paragraph
]

{ #category : #'menu messages' }
TextEditor >> paste [
	"Update command history."
	
	self openTypeIn.
	super paste.
	self closeTypeIn.
]

{ #category : #'editing keys' }
TextEditor >> pasteInitials: aKeyboardEvent [ 
	"Replace the current text selection by an authorship name/date stamp; invoked by cmd-shift-v, easy way to put an authorship stamp in the comments of an editor."

	self insertAndCloseTypeIn.
	self openTypeIn.
	self replace: self selectionInterval with: (Text fromString: Utilities changeStamp) and: [self selectAt: self stopIndex].
	self closeTypeIn.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> pasteRecent [
	"Paste an item chose from RecentClippings."

	| clipping |
	(clipping := Clipboard chooseRecentClipping) ifNil: [^ self].
	Clipboard clipboardText: clipping.
	^ self paste
]

{ #category : #'accessing-selection' }
TextEditor >> pointBlock [
	^ pointBlock
]

{ #category : #'accessing-selection' }
TextEditor >> pointIndex [
	^ pointBlock stringIndex
]

{ #category : #'menu messages' }
TextEditor >> prettyPrint [
	self prettyPrint: false
]

{ #category : #'menu messages' }
TextEditor >> prettyPrint: decorated [ 
	"Reformat the contents of the receiver's view (a Browser or Workspace)."

	model selectedClassOrMetaClass
		ifNil: [ "arbitrary text selection in a workspace, not directly associated with a class"
			(Compiler new formatNoPattern: self selection environment: model environment)
				ifNotNilDo: [:newText | self replaceSelectionWith: newText]]
		ifNotNil: [:selectedClass | "source for a method in the selected class"
			(selectedClass newCompiler
					format: self text
					in: selectedClass
					notifying: self
					decorated: decorated)
				ifNotNilDo: [ :newText |
						self selectInvisiblyFrom: 1 to: paragraph text size.
						self replaceSelectionWith: (selectedClass ifNil: [newText] ifNotNil: [newText asText makeSelectorBoldIn: selectedClass]).
						self selectAt: self text size + 1 ]].

]

{ #category : #'menu messages' }
TextEditor >> prettyPrintWithColor [
	self prettyPrint: true
]

{ #category : #'do-its' }
TextEditor >> printIt [

	self evaluateSelectionAndDo: [:result |
		(model respondsTo: #printIt:result:)
			ifTrue: [model
				perform: #printIt:result:
				with: self selection
				with: result]
			ifFalse: [self afterSelectionInsertAndSelect: result printString]]
]

{ #category : #'editing keys' }
TextEditor >> printIt: aKeyboardEvent [
	"Print the results of evaluting the selection -- invoked via cmd-p.  If there is no current selection, use the current line.  1/17/96 sw
	 2/29/96 sw: don't call selectLine now, since it's called by doIt"

	self printIt.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> printerSetup [
	"copied from ParagraphEditor"
	TextPrinter defaultTextPrinter inspect

]

{ #category : #'typing\/selecting keys' }
TextEditor >> querySymbol: aKeyboardEvent [
	"Invoked by Ctrl-q to query the Symbol table and display alternate symbols."

	| hintText lastOffering offering |
	(self isTypingIn not or: [self history current type ~= #query])
		ifTrue: [
			self closeTypeIn.
			self openTypeIn.
			self selectPrecedingIdentifier.
			self closeTypeIn].
	
	self openTypeInFor: #query.
	
	hintText := self history current contentsBefore string.
	hintText := hintText copyFrom: (hintText
		lastIndexOfAnyOf: Character separators, '#'
		startingAt: hintText size) + 1 to: hintText size.
	self selectInvisiblyFrom: self history current intervalBefore first to: self stopIndex-1.
	lastOffering := self selection string.
	lastOffering := (lastOffering copyReplaceAll: ':  ' with: ':') withBlanksTrimmed.

	"Only offer suggestions for not-empty tokens."
	hintText ifEmpty: [morph flash. self closeTypeIn. ^ true].
	offering := Symbol thatStarts: hintText skipping: lastOffering.
	offering ifNil: [offering := Symbol thatStarts: hintText skipping: nil].
	offering ifNil: [morph flash. self closeTypeIn. ^ true].
	
	"Add some nice spacing to the suggestion."
	offering := offering copyReplaceAll: ':' with: ':  '.
	offering last = Character space ifTrue: [offering := offering allButLast].
	
	"Insert the suggestions. (Note that due to previous selection, things will be overwritten and not appended.)"
	self typeAhead nextPutAll: offering.

	^ false
]

{ #category : #'nonediting\/nontyping keys' }
TextEditor >> raiseContextMenu: aKeyboardEvent [ 
	(morph respondsTo: #editView)
		ifTrue: [morph editView yellowButtonActivity: false].
	^ true
]

{ #category : #'current selection' }
TextEditor >> recomputeSelection [
	"The same characters are selected but their coordinates may have changed."

	self markIndex: self markIndex pointIndex: self pointIndex
]

{ #category : #'menu messages' }
TextEditor >> redo [

	self closeTypeIn.
	self history redoIn: self.
]

{ #category : #'editing keys' }
TextEditor >> redo: aKeyboardEvent [ 
	"Redo the last edit."

	self insertAndCloseTypeIn.
	self redo.
	^true
]

{ #category : #undo }
TextEditor >> redoAndReselect [

	self
		replace: self history current intervalBefore
		with: self history current contentsAfter
		and: [self selectInterval: self history current intervalAfter].
]

{ #category : #'menu messages' }
TextEditor >> referencesToIt [
	"Open a MessageSet with the references to the selected global or variable name."

	self wordSelectAndEmptyCheck: [^ self].
	self selectedInstanceVariable ifNotNil:
		[:nameToClass | ^ self systemNavigation
			browseAllAccessesTo: nameToClass key
			from: nameToClass value].
	self selectedBinding ifNotNil:
		[:binding | ^ self systemNavigation browseAllCallsOnClass: binding].
	morph flash.
]

{ #category : #'editing keys' }
TextEditor >> referencesToIt: aKeyboardEvent [
	"Triggered by Cmd-N; browse references to the current selection"

	self referencesToIt.
	^ true
]

{ #category : #'typing support' }
TextEditor >> removePreviousInsertion [
	"If the previous command was an insertion, remove it by not undoing it but replacing it with nothing."

	self history hasInsertedSomething ifFalse: [morph flash. ^ false].

	self
		selectInvisiblyFrom: self history previous intervalBefore first
		to: self history previous intervalAfter last.

	self replaceSelectionWith: self nullText.

	^ true
	
]

{ #category : #undo }
TextEditor >> replace: interval with: newText [

	self
		replace: interval
		with: newText
		and: ["Do nothing."].
]

{ #category : #undo }
TextEditor >> replace: xoldInterval with: newText and: selectingBlock [ 
	"Replace the text in oldInterval with newText and execute selectingBlock to establish the new selection.  Create an undoAndReselect:redoAndReselect: undoer to allow perfect undoing."

	| undoInterval |
	undoInterval := self selectionInterval.
	undoInterval = xoldInterval ifFalse: [self selectInterval: xoldInterval].
	
	self zapSelectionWith: newText.
	selectingBlock value.
	
	otherInterval := self selectionInterval.
]

{ #category : #undo }
TextEditor >> replaceSelectionWith: aText [
	"Remember the selection text in UndoSelection.
	 Deselect, and replace the selection text by aText.
	 Remember the resulting selectionInterval in UndoInterval and PriorInterval.
	 Set up undo to use UndoReplace."

	self openTypeIn.
	self zapSelectionWith: aText.
	self closeTypeIn.
]

{ #category : #'initialize-release' }
TextEditor >> resetState [ 
	"Establish the initial conditions for editing the paragraph: place caret 
	before first character, set the emphasis to that of the first character,
	and save the paragraph for purposes of canceling."

	pointBlock := markBlock := paragraph defaultCharacterBlock.
	beginTypeInIndex := nil.
	otherInterval := 1 to: 0.
	self setEmphasisHere.
]

{ #category : #private }
TextEditor >> resetTypeAhead [
	typeAhead := WriteStream on: (String new: 1)
]

{ #category : #private }
TextEditor >> sameColumn: start newLine: lineBlock forward: isForward [
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
TextEditor >> save: aKeyboardEvent [
	"Submit the current text.  Equivalent to 'accept' 1/18/96 sw"

	self insertAndCloseTypeIn.
	self accept.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> saveContentsInFile [
	"Save the receiver's contents string to a file, prompting the user for a file-name.  Suggest a reasonable file-name."

	| fileName stringToSave parentWindow labelToUse suggestedName |
	stringToSave := paragraph text string.
	stringToSave size = 0 ifTrue: [^self inform: 'nothing to save.'].
	parentWindow := model dependents 
				detect: [:dep | dep isKindOf: SystemWindow]
				ifNone: [nil].
	labelToUse := parentWindow ifNil: ['Untitled']
				ifNotNil: [parentWindow label].
	suggestedName := nil.
	#(#('Decompressed contents of: ' '.gz')) do: 
			[:leaderTrailer | | lastIndex | 
			"can add more here..."

			(labelToUse beginsWith: leaderTrailer first) 
				ifTrue: 
					[suggestedName := labelToUse copyFrom: leaderTrailer first size + 1
								to: labelToUse size.
					(labelToUse endsWith: leaderTrailer last) 
						ifTrue: 
							[suggestedName := suggestedName copyFrom: 1
										to: suggestedName size - leaderTrailer last size]
						ifFalse: 
							[lastIndex := suggestedName lastIndexOf: $..
							lastIndex > 1
								ifTrue: [suggestedName := suggestedName copyFrom: 1 to: lastIndex - 1]]]].
	suggestedName ifNil: [suggestedName := labelToUse , '.text'].
	fileName := UIManager default saveFilenameRequest: 'File name?'
				initialAnswer: suggestedName.
	fileName isEmptyOrNil 
		ifFalse: 
			[(FileStream newFileNamed: fileName)
				nextPutAll: stringToSave;
				close]
]

{ #category : #scrolling }
TextEditor >> scrollBy: ignore [ 
	"Ignore scroll requests."
]

{ #category : #'current selection' }
TextEditor >> selectAndScroll [
	"Ignore scroll requests."
]

{ #category : #'nonediting\/nontyping keys' }
TextEditor >> selectCurrentTypeIn: aKeyboardEvent [ 
	"Select what would be replaced by an undo (e.g., the last typeIn)."

	| prior |

	self flag: #buggy.
	self insertAndCloseTypeIn.
	prior := otherInterval.
	self insertAndCloseTypeIn.
	otherInterval := prior.
	^ true
]

{ #category : #'new selection' }
TextEditor >> selectFrom: start to: stop [
	self closeTypeIn.
	"Select the specified characters inclusive."
	self selectInvisiblyFrom: start to: stop.
	self storeSelectionInParagraph.
	"Preserve current emphasis if selection is empty"
	stop > start ifTrue: [
		self setEmphasisHere ]
]

{ #category : #'new selection' }
TextEditor >> selectLine [
	"Make the receiver's selection, if it currently consists of an insertion point only, encompass the current line."

	self selectInterval: (self encompassLine: self selectionInterval)
]

{ #category : #'new selection' }
TextEditor >> selectPrecedingIdentifier [
	"Invisibly select the identifier that ends at the end of the selection, if any."

	| string sep stop tok |
	tok := false.
	string := paragraph string.
	stop := self stopIndex - 1.
	[stop > 0 and: [(string at: stop) isSeparator]] whileTrue: [stop := stop - 1].
	sep := stop.
	[sep > 0 and: [(string at: sep) tokenish]] whileTrue: [tok := true. sep := sep - 1].
	tok ifTrue: [self selectInvisiblyFrom: sep + 1 to: stop]
]

{ #category : #'menu messages' }
TextEditor >> selectedBinding [
	"Try to make a binding out of the current text selection. That binding can be a global or class."

	^ self selectedSymbol ifNotNil:
		[ :symbol |
			((model respondsTo: #selectedClassOrMetaClass)
				ifTrue: [ model selectedClassOrMetaClass ifNil: [ model environment ] ]
				ifFalse: [ model environment ]) ifNotNil:
					[ :environment | environment bindingOf: symbol ] ]
]

{ #category : #'menu messages' }
TextEditor >> selectedClassVariable [
	"Try to make a class-variable binding out of the current text selection."

	(model respondsTo: #selectedClassOrMetaClass) ifFalse: [ ^ nil ].
		
	^ self selectedSymbol ifNotNil:
		[ :symbol | model selectedClassOrMetaClass ifNotNil:
			[ :classOrMetaClass | (classOrMetaClass theNonMetaClass allClassVarNames includes: symbol)
				ifTrue: [ classOrMetaClass bindingOf: symbol ]
				ifFalse: [ nil ] ] ]
]

{ #category : #'menu messages' }
TextEditor >> selectedInstanceVariable [
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
TextEditor >> selectedLiteral [
	"Try to make a Smalltalk literal out of the current text selection."

	^ self selection string findLiteral
]

{ #category : #'menu messages' }
TextEditor >> selectedSelector [
	"Try to make a selector out of the current text selection."

	^ self selection string findSelector
]

{ #category : #'menu messages' }
TextEditor >> selectedSymbol [
	"Try to make a symbol out of the current text selection."

	^ self selection string findSymbol
]

{ #category : #'accessing-selection' }
TextEditor >> selection [
	"Answer the text in the paragraph that is currently selected."

	^paragraph text copyFrom: self startIndex to: self stopIndex - 1 
]

{ #category : #'accessing-selection' }
TextEditor >> selectionAsStream [
	"Answer a ReadStream on the text in the paragraph that is currently  selected."

	^ReadStream
		on: paragraph string
		from: self startIndex
		to: self stopIndex - 1
]

{ #category : #'menu messages' }
TextEditor >> sendContentsToPrinterWithLabel: label [
	| textToPrint printer |
	textToPrint := paragraph text.
	textToPrint size = 0 ifTrue: [^self inform: 'nothing to print.'].
	printer := TextPrinter defaultTextPrinter.
	printer documentTitle: (label ifNil: ['Untitled']).
	printer printText: textToPrint
]

{ #category : #'menu messages' }
TextEditor >> sendersOfIt [
	"Open a senders browser on the selected selector"

	self lineSelectAndEmptyCheck: [^ self].
	self selectedSelector ifNotNil: [:aSelector |
		^ self model browseAllCallsOn: aSelector].
	self selectedLiteral ifNotNil: [:aLiteral |
		^ self model browseAllCallsOn: aLiteral].
	morph flash.
]

{ #category : #'editing keys' }
TextEditor >> sendersOfIt: aKeyboardEvent [
	"Triggered by Cmd-n; browse implementors of the selector represented by the current selection, if plausible. 2/1/96 sw"

	self sendersOfIt.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> setAlignment: selectionString [
	| attr interval  |
	attr := selectionString
		caseOf: 
			{ [ 'indented' ] -> [ TextIndent amount: 1 ].
			[ 'indented more' ] -> [ TextIndent amount: self existingIndentation+1 ].
			[ 'indented less' ] -> [  TextIndent amount: (self existingIndentation-1 max: 0) ]}
		otherwise:
			[ TextAlignment perform: selectionString asSymbol ].
	interval := self encompassLine: self selectionInterval.
	paragraph
		replaceFrom: interval first 
		to: interval last 
		with: ((paragraph text copyFrom: interval first to: interval last) addAttribute: attr)
]

{ #category : #'editing keys' }
TextEditor >> setEmphasis: emphasisSymbol [
	"Change the emphasis of the current selection."

	| oldAttributes attribute |
	oldAttributes := paragraph text attributesAt: self selectionInterval first.

	attribute := TextEmphasis perform: emphasisSymbol.
	(emphasisSymbol == #normal) 
		ifFalse:	[oldAttributes do:	
			[:att | (att dominates: attribute) ifTrue: [attribute turnOff]]].
	self replaceSelectionWith: (self selection addAttribute: attribute)
]

{ #category : #'typing support' }
TextEditor >> setEmphasisHere [

	emphasisHere := (paragraph text attributesAt: (self pointIndex - 1 max: 1) forStyle: paragraph textStyle)
					select: [:att | att mayBeExtended]
]

{ #category : #'typing support' }
TextEditor >> setEmphasisHereFromText [

	self setEmphasisHereFromTextForward: true
]

{ #category : #'typing support' }
TextEditor >> setEmphasisHereFromTextForward: f [

	| i t forward delta prevIsSeparator nextIsSeparator |
	i := self pointIndex.
	t := self text.
	"Try to set emphasisHere correctly after whitespace.
	Most important after a cr, i.e. at the start of a new line"
	prevIsSeparator :=  i > 1 and: [ (t at: i-1) isSeparator ].
	nextIsSeparator := i <= t size and: [ (t at: i) isSeparator ].
	forward := prevIsSeparator = nextIsSeparator
		ifTrue: [ f ]
		ifFalse: [ nextIsSeparator ].
	delta := forward ifTrue: [ 1 ] ifFalse: [ 0 ].
	emphasisHere := (t attributesAt: (i - delta max: 1))
					select: [:att | att mayBeExtended].
]

{ #category : #accessing }
TextEditor >> setReplacementFromHistory [
	"Use history to get the previous replacement."
	
	self history hasReplacedSomething
		ifTrue: [ChangeText := self history previous contentsAfter].
]

{ #category : #accessing }
TextEditor >> setSearch: aStringOrText [

	FindText := aStringOrText.
]

{ #category : #accessing }
TextEditor >> setSearchFromSelectionOrHistory [
	"Updates the current string to find with the current selection or the last change if it replaced something and thus had a prior selection."

	self hasSelection
		ifTrue: [FindText := self selection]
		ifFalse: [self history hasReplacedSomething
			ifTrue: [FindText := self history previous contentsBefore]
			ifFalse: [(self history hasInsertedSomething and: [(self history hasCursorMoved: self stopIndex) not])
				ifTrue: [
					FindText := self history previous contentsAfter.
					self removePreviousInsertion. "Undoable."]]]
]

{ #category : #'menu messages' }
TextEditor >> setSearchString [
	"Make the current selection, if any, be the current search string."
	self hasCaret ifTrue: [morph flash. ^ self].
	self setSearch:  self selection string
]

{ #category : #'menu messages' }
TextEditor >> spawn [
	"Create and schedule a message browser for the code of the model's 
	selected message. Retain any edits that have not yet been accepted."
	| code |
	code := paragraph text string.
	self cancel.
	model spawn: code.
]

{ #category : #'editing keys' }
TextEditor >> spawnIt: aKeyboardEvent [
	"Triggered by Cmd-o; spawn a new code window, if it makes sense."

	self spawn.
	^ true
]

{ #category : #'accessing-selection' }
TextEditor >> startBlock [
	^ pointBlock min: markBlock
]

{ #category : #'accessing-selection' }
TextEditor >> startIndex [
	^ self startBlock stringIndex
]

{ #category : #'typing support' }
TextEditor >> startOfTyping [
	"Compatibility during change from characterBlock to integer"
	beginTypeInIndex == nil ifTrue: [^ nil].
	beginTypeInIndex isNumber ifTrue: [^ beginTypeInIndex].
	"Last line for compatibility during change from CharacterBlock to Integer."
	^ beginTypeInIndex stringIndex
]

{ #category : #'initialize-release' }
TextEditor >> stateArray [
	^[ {ChangeText.
		FindText.
		history ifNil: [TextEditorCommandHistory new]. "Convert old instances"
		self markIndex to: self pointIndex - 1.
		self startOfTyping.
		emphasisHere.
		lastParenLocation}]
			on: MessageNotUnderstood
			do: [:ex| ex resume: nil]
]

{ #category : #'initialize-release' }
TextEditor >> stateArrayPut: stateArray [
	ChangeText := stateArray at: 1.
	FindText := stateArray at: 2.
	history := stateArray at: 3.
	(stateArray at: 4) ifNotNil: [:sel| self selectFrom: sel first to: sel last].
	beginTypeInIndex := stateArray at: 5.
	emphasisHere := stateArray at: 6.
	lastParenLocation := stateArray at: 7
]

{ #category : #'accessing-selection' }
TextEditor >> stopBlock [
	^ pointBlock max: markBlock
]

{ #category : #'accessing-selection' }
TextEditor >> stopIndex [
	^ self stopBlock stringIndex
]

{ #category : #'mvc compatibility' }
TextEditor >> storeSelectionInParagraph [
	paragraph selectionStart: self startBlock selectionStop: self stopBlock
]

{ #category : #accessing }
TextEditor >> string [

	^self text string
]

{ #category : #accessing }
TextEditor >> styler [
	"Answers the styler for this editor. Only code editors support syntax highlighting"
	^nil
]

{ #category : #accessing }
TextEditor >> styler: aStyler [
	"Sets the styler for this editor. Only code editors support syntax highlighting"
	^nil
]

{ #category : #'editing keys' }
TextEditor >> swapChars: aKeyboardEvent [ 
	"Triggered byCmd-Y;.  Swap two characters, either those straddling the insertion point, or the two that comprise the selection.  Suggested by Ted Kaehler.  "

	| currentSelection aString chars |
	(chars := self selection) size = 0
		ifTrue:
			[currentSelection := self pointIndex.
			self selectMark: currentSelection - 1 point: currentSelection]
		ifFalse:
			[chars size = 2
				ifFalse:
					[morph flash. ^ true]
				ifTrue:
					[currentSelection := self pointIndex - 1]].
	aString := self selection string.
	self replaceSelectionWith: (Text string: aString reversed attributes: emphasisHere).
	self selectAt: currentSelection + 1.
	^ true
]

{ #category : #'as yet unclassified' }
TextEditor >> systemNavigation [
	^ SystemNavigation for: model environment
]

{ #category : #'typing\/selecting keys' }
TextEditor >> tabCount [
	^ self class autoIndent
		ifTrue:
			[ | tabCount s i char |
			s := paragraph string.
			i := self stopIndex.
			tabCount := 0.
			[(i := i-1) > 0 and: [(char := s at: i) ~= Character cr and: [char ~= Character lf]]]
				whileTrue:  "Count tabs and brackets (but not a leading bracket)"
				[(char = Character tab and: [i < s size and: [(s at: i+1) ~= $[ ]]) ifTrue: [tabCount := tabCount + 1].
				char = $[ ifTrue: [tabCount := tabCount + 1].
				char = $] ifTrue: [tabCount := tabCount - 1]].
			tabCount ]
		ifFalse: [ 0 ]
]

{ #category : #accessing }
TextEditor >> text [
	"Answer the text of the paragraph being edited."

	^paragraph text
]

{ #category : #accessing }
TextEditor >> totalTextHeight [

	^paragraph lines last bottom
]

{ #category : #accessing }
TextEditor >> transformFrom: owner [
	^morph transformFrom: owner
]

{ #category : #private }
TextEditor >> typeAhead [
	^ typeAhead ifNil:
		[ self resetTypeAhead.
		typeAhead ]
]

{ #category : #private }
TextEditor >> unapplyAttribute: aTextAttribute [
	"The user selected aTextAttribute to be removed.
	If there is a selection, unapply the attribute to the selection.
	In any case do not use the attribute for the user input (emphasisHere)"

	| interval |

	emphasisHere := emphasisHere copyWithout: aTextAttribute.

	interval := self selectionInterval.
	(interval isEmpty and: [ aTextAttribute isParagraphAttribute not ])
		ifTrue: [ ^self ].
	
	self text removeAttribute: aTextAttribute from: interval first to: interval last.
	paragraph recomposeFrom: interval first to: interval last delta: 0.
	self recomputeSelection.	"Needed so visible selection is updated to reflect new visual extent of selection"
	morph changed
]

{ #category : #'menu messages' }
TextEditor >> undo [

	self closeTypeIn.
	self history undoIn: self.
	self history hasPrevious ifFalse: [morph hasUnacceptedEdits: false].
]

{ #category : #'editing keys' }
TextEditor >> undo: aKeyboardEvent [ 
	"Undo the last edit."

	self insertAndCloseTypeIn.
	self undo.
	^true
]

{ #category : #undo }
TextEditor >> undoAndReselect [

	self
		replace: self history current intervalBetween
		with: self history current contentsBefore
		and: [self selectInterval: self history current intervalBefore].
]

{ #category : #'accessing-selection' }
TextEditor >> unselect [
	markBlock := pointBlock copy
]

{ #category : #events }
TextEditor >> updateCursorForEvent: evt [ 

	(((morph bounds containsPoint: evt position)
		and: [morph dragEnabled not or: [(self isEventInSelection: evt) not]])
		and: [evt hand temporaryCursor ~~ Cursor text])
			ifTrue: [evt hand showTemporaryCursor: Cursor text]
			ifFalse: [evt hand showTemporaryCursor: nil].
]

{ #category : #scrolling }
TextEditor >> updateMarker [
	"Ignore scrollbar redraw requests."

]

{ #category : #accessing }
TextEditor >> visibleHeight [

	^morph owner bounds height
]

{ #category : #events }
TextEditor >> yellowButtonDown: event [
	"Process a yellow button event. Answer true if the event was handled, false otherwise."
	(paragraph attributesAt: event cursorPoint) do:[:attr|
		attr menu ifNotNil:[
			attr menu
				setInvokingView: self morph editView;
				popUpEvent: event in: self morph world.
			^true]].
	^false
]

{ #category : #'mvc compatibility' }
TextEditor >> zapSelectionWith: replacement [

	| start stop rep |
	morph readOnly ifTrue: [^ self].
	start := self startIndex.
	stop := self stopIndex.
	(replacement isEmpty and: [stop > start]) ifTrue: [
		"If deleting, then set emphasisHere from 1st character of the deletion"
		emphasisHere := (self text attributesAt: start) select: [:att | att mayBeExtended]].
	(start = stop and: [ replacement isEmpty ]) ifFalse: [
		replacement isText
			ifTrue: [ rep := replacement]
			ifFalse: [ rep := Text string: replacement attributes: emphasisHere ].
		self text replaceFrom: start to: stop - 1 with: rep.
		paragraph
			recomposeFrom: start
			to:  start + rep size - 1
			delta: rep size - (stop-start).
		self markIndex: start pointIndex: start + rep size.
		otherInterval := self selectionInterval].

	self userHasEdited  " -- note text now dirty"
]
