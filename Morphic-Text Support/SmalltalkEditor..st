"
The editor built specifically for Smalltalk code
"
Class {
	#name : #SmalltalkEditor,
	#superclass : #TextEditor,
	#category : #'Morphic-Text Support'
}

{ #category : #'keyboard shortcut tables' }
SmalltalkEditor class >> initialize [
	"SmalltalkEditor initialize"
	self initializeCmdKeyShortcuts.
	self initializeShiftCmdKeyShortcuts.
	self initializeYellowButtonMenu.
	self initializeShiftedYellowButtonMenu.

]

{ #category : #'keyboard shortcut tables' }
SmalltalkEditor class >> initializeCmdKeyShortcuts [
	"Initialize the (unshifted) command-key (or alt-key) shortcut table."
	"NOTE: if you don't know what your keyboard generates, use Sensor kbdTest"
	"SmalltalkEditor initialize"
	| cmds |
	super initializeCmdKeyShortcuts.
	cmds := #($b #browseIt: $d #doIt: $i #inspectIt: $l #cancel: $m #implementorsOfIt: $n #sendersOfIt: $o #spawnIt: $p #printIt: $q #querySymbol: $s #save: ).
	1 to: cmds size
		by: 2
		do: [ : i | cmdActions at: (cmds at: i) asciiValue + 1 put: (cmds at: i + 1)].
	"Set up type-method argument hot keys, 1-4.."
	'1234' do:
		[ : eachKeyboardChar |
		cmdActions 
			at: eachKeyboardChar asciiValue + 1
			put: #typeMethodArgument: ]
]

{ #category : #'keyboard shortcut tables' }
SmalltalkEditor class >> initializeShiftCmdKeyShortcuts [ 
	"Initialize the shift-command-key (or control-key) shortcut table."
	"NOTE: if you don't know what your keyboard generates, use Sensor kbdTest"
	| cmds |
	super initializeShiftCmdKeyShortcuts.
	cmds := #(
		$a	argAdvance:
		$b	browseItHere:
		$d	debugIt:
		$e	methodStringsContainingIt:
		$f	displayIfFalse:
		$g	fileItIn:
		$i	exploreIt:
		$n	referencesToIt:
		$s	invokePrettyPrint:
		$t	displayIfTrue:
		$v	pasteInitials:
		$w	methodNamesContainingIt:
	).
	1 to: cmds size by: 2 do: [ :i |
		shiftCmdActions at: ((cmds at: i) asciiValue + 1) put: (cmds at: i + 1).			"plain keys"
		shiftCmdActions at: ((cmds at: i) asciiValue - 32 + 1) put: (cmds at: i + 1).		"shifted keys"
		shiftCmdActions at: ((cmds at: i) asciiValue - 96 + 1) put: (cmds at: i + 1).		"ctrl keys"
	].
	"shift+cmd _ (underscore)"
	shiftCmdActions at: $_ asciiValue+1 put: #flattenSelection:
]

{ #category : #'keyboard shortcut tables' }
SmalltalkEditor class >> initializeShiftedYellowButtonMenu [
	"Initialize the yellow button pop-up menu and corresponding messages."

	"SmalltalkEditor initialize"

	shiftedYellowButtonMenu := MenuMorph fromArray: StringHolder yellowButtonMenuItems.
]

{ #category : #'keyboard shortcut tables' }
SmalltalkEditor class >> initializeYellowButtonMenu [
	"Initialize the yellow button pop-up menu and corresponding messages."

	"SmalltalkEditor initialize"

	yellowButtonMenu := MenuMorph fromArray: StringHolder yellowButtonMenuItems
]

{ #category : #parenblinking }
SmalltalkEditor >> blinkPrevParen: aCharacter [
	"Same as super, but tries to follow the Smalltalk syntax."

	| openDelimiter closeDelimiter level string here inside |
	string := paragraph text string.
	here := pointBlock stringIndex.
	openDelimiter := aCharacter.
	closeDelimiter := '([{' at: (')]}' indexOf: openDelimiter).
	level := 1.
	inside := nil. "Tricky."
	(here > 1 and: [ (string at: here - 1) = $$ ]) ifTrue: [ ^self ]. "Just a character literal."
	[ level > 0 and: [ here > 1 ] ] whileTrue: [
		| hereChar |
		hereChar := string at: (here := here - 1).
		inside "Are we inside a comment or string literal?"
			ifNotNil: [ "Yes."
				hereChar = inside ifTrue: [
					(here > 1 and: [ (string at: here - 1) ~= inside ])
						ifTrue: [ inside := nil ]
						ifFalse: [ here := here - 1 ] ] ]
			ifNil: [
				(here > 1 and: [ (string at: here - 1) = $$ ]) "Just a character literal."
					ifTrue: [ here := here - 1 ]
					ifFalse: [
						hereChar
							caseOf: {
								[ closeDelimiter ] -> [
									(level := level - 1) = 0 ifTrue: [
										^self blinkParenAt: here ] ].
								[ openDelimiter ] -> [  level := level + 1 ].
								[ $" ] -> [ inside := $" ].
								[ $' ] -> [ inside := $' ] }
							otherwise: [] ] ] ]
]

{ #category : #'do-its' }
SmalltalkEditor >> buttonForIt [

	^ self doItButtonFromSelection ifNotNil: [:e | e openInHand]
]

{ #category : #'editing keys' }
SmalltalkEditor >> changeEmphasis: characterStream [
	"Change emphasis without styling if necessary"
	self styler ifNil: [^super changeEmphasis: characterStream].
	^ self styler evaluateWithoutStyling: [super changeEmphasis: characterStream].
]

{ #category : #'do-its' }
SmalltalkEditor >> doItButtonFromSelection [

	| button string cm |
	self lineSelectAndEmptyCheck: [^ nil].
	button := SimpleButtonMorph new.
	string := self selection.
	(model respondsTo: #doItReceiver) 
		ifTrue: [
			button setProperty: #rcvr toValue: model doItReceiver.
			button setProperty: #ctxt toValue: model doItContext].

	cm := (button valueOfProperty: #rcvr) class compilerClass new 
			compiledMethodFor: string readStream
			in: (button valueOfProperty: #ctxt)
			to: (button valueOfProperty: #rcvr)
			notifying: nil
			ifFail: [^ nil].
	button setProperty: #cm toValue: cm.
	button target: [:b |
		[(b valueOfProperty: #cm) valueWithReceiver: (b valueOfProperty: #rcvr) arguments: 
			((b valueOfProperty: #ctxt) ifNotNil: [{(b valueOfProperty: #ctxt) }] ifNil: [#()])]
		on: OutOfScopeNotification 
		do: [ :ex | ex resume: true]];
		actionSelector: #value:;
		arguments: {button}.
	button label: string.
	^ button.

]

{ #category : #'editing keys' }
SmalltalkEditor >> emphasisExtras [
	^#(
		'Do it' 
		'Print it'
		'Style it'
		'Link to comment of class' 
		'Link to definition of class' 
		'Link to hierarchy of class' 
		'Link to method'
		'URL Link'
	).
]

{ #category : #'editing keys' }
SmalltalkEditor >> flattenSelection: dummy [
	"Replace all lines and consecutive whitespace characters of the current selection with one line separated by single spaces."
	self replaceSelectionWith: self selection string condensedIntoOneLine.
	^ true
]

{ #category : #'editing keys' }
SmalltalkEditor >> handleEmphasisExtra: index with: aKeyboardEvent [
	"Handle an extra emphasis menu item"
	| action attribute thisSel |
	action := {
		[attribute := TextDoIt new.
		thisSel := attribute analyze: self selection].
		[attribute := TextPrintIt new.
		thisSel := attribute analyze: self selection].
		[thisSel := self styleSelection].
		[attribute := TextLink new.
		thisSel := attribute analyze: self selection asString with: 'Comment'].
		[attribute := TextLink new.
		thisSel := attribute analyze: self selection asString with: 'Definition'].
		[attribute := TextLink new.
		thisSel := attribute analyze: self selection asString with: 'Hierarchy'].
		[attribute := TextLink new.
		thisSel := attribute analyze: self selection asString].
		[attribute := TextURL new.
		thisSel := attribute analyze: self selection asString].
		["Edit hidden info"
		thisSel := self hiddenInfo.	"includes selection"
		attribute := TextEmphasis normal].
		["Copy hidden info"
		self copyHiddenInfo.
		^true].	"no other action"
	} at: index.
	action value.

	thisSel ifNil: [^ true].	"Could not figure out what to link to"

	(thisSel isEmpty and: [attribute notNil])
		ifTrue: [
			| oldAttributes |
			"only change emphasisHere while typing"
			oldAttributes := paragraph text attributesAt: self pointIndex.
			emphasisHere := Text addAttribute: attribute toArray: oldAttributes]
		ifFalse: [
			self replaceSelectionWith: (attribute ifNil: [thisSel] ifNotNil: [thisSel asText addAttribute: attribute]) ].
	^ true
]

{ #category : #'editing keys' }
SmalltalkEditor >> invokePrettyPrint: dummy [
	self prettyPrint: false.
	^ true
]

{ #category : #private }
SmalltalkEditor >> methodArgument: anInteger [ 
	^ (ReadStream on: self text asString) nextLine
		ifNil: [ String empty ]
		ifNotNilDo:
			[ : line | 
			line substrings
				at: 2 * anInteger
				ifAbsent: [ String empty ] ]
]

{ #category : #private }
SmalltalkEditor >> nextWord: position [ 
	| string index boundaryCharacters |
	string := self string.
	index := position - 1.
	[ (index
		between: 1
		and: string size) and: [ (string at: index) isSeparator ] ] whileTrue: [ index := index + 1 ].
	boundaryCharacters := ')]}''"|^. 	'.
	((index
		between: 1
		and: string size) and: [ boundaryCharacters includes: (string at: index) ])
		ifTrue:
			[  index := index + 1  ]
		ifFalse:
			[ [ (index
				between: 1
				and: string size) and: [ (boundaryCharacters includes: (string at: index)) not ] ] whileTrue: [ index := index + 1 ] ].
	^ index
]

{ #category : #private }
SmalltalkEditor >> previousWord: position [ 
	| string index boundaryCharacters |
	string := self string.
	index := position.
	"First, get out of whitespace."
	[ (index
		between: 2
		and: string size) and: [ (string at: index) isSeparator ] ] whileTrue: [ index := index - 1 ].
	boundaryCharacters := '([{''"|^. 	'.
	"Are we at a boundary character?"
	((index
		between: 2
		and: string size) and: [ boundaryCharacters includes: (string at: index) ])
		ifTrue:
			[ "yes, select it and any following whitespace of this line."
			index := index - 1 ]
		ifFalse:
			[ "no, select to the next boundary character"
			[ (index
				between: 1
				and: string size) and: [ (boundaryCharacters includes: (string at: index)) not ] ] whileTrue: [ index := index - 1 ] ].
	^ index + 1
]

{ #category : #'do-its' }
SmalltalkEditor >> spyOnIt [

	^ MessageTally spyOn: [self evaluateSelection]
]

{ #category : #'do-its' }
SmalltalkEditor >> styleIt [

	^ self styleSelection
]

{ #category : #'do-its' }
SmalltalkEditor >> styleSelection [

	| styler |
	self lineSelectAndEmptyCheck: [^ ''].
	styler := self styler ifNil: [(Smalltalk classNamed: #SHTextStylerST80) new].
	^ styler styledTextFor: self selection
]

{ #category : #accessing }
SmalltalkEditor >> styler [
	"Answers the styler for this editor. Only code editors support syntax highlighting"
	^ self morph editView styler

]

{ #category : #'do-its' }
SmalltalkEditor >> tallyIt [

	^ self tallySelection
]

{ #category : #'do-its' }
SmalltalkEditor >> tallySelection [
	"Treat the current selection as an expression; evaluate it and return the time took for this evaluation"
	| code result rcvr ctxt v |
	self lineSelectAndEmptyCheck: [^ self].

	(model respondsTo: #doItReceiver) 
		ifTrue: [ rcvr := model doItReceiver.
				ctxt := model doItContext]
		ifFalse: [rcvr := ctxt := nil].
	result := [ | cm |
		code := self selectionAsStream.
		cm := rcvr class evaluatorClass new 
			compiledMethodFor: code
			in: ctxt
			to: rcvr
			notifying: self
			ifFail: [morph flash. ^ self].
		Time millisecondsToRun: 
			[v := cm valueWithReceiver: rcvr arguments: (ctxt ifNil: [#()] ifNotNil: [{ctxt}]) ].
	] 
		on: OutOfScopeNotification 
		do: [ :ex | ex resume: true].
	
	UIManager default
		inform: ('<b>Expression</b>{1}<br>{2}<br><br><b>Time</b> (compile and execute)<br>{3} ms<br><br><b>Result</b><br>{4}' format: {
			rcvr ifNil: [''] ifNotNil: [' (', (rcvr printString truncateWithElipsisTo: 20), ')'].
			(code contents truncateWithElipsisTo: 200) copyReplaceAll: String cr with: '<br>'.
			result printString. 
			v printString truncateWithElipsisTo: 100}) asTextFromHtml.
]

{ #category : #private }
SmalltalkEditor >> typeMethodArgument: aKeyboardEvent [ 
	"Replace the current text selection with the name of the method argument represented by the keyCode."
	| keyCode |
	keyCode := ('1234' 
		indexOf: aKeyboardEvent keyCharacter
		ifAbsent: [1]).
	self  addString: (self methodArgument: keyCode).
	^ false
]
