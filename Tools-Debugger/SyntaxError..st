"
I represent syntax error report for syntax errors encountered when filing in class descriptions from a non-interactive source such as an external file. As a StringHolder, the string to be viewed is the method code or expression containing the error.

The user may fix the error and accept the method to continue the fileIn.

"
Class {
	#name : #SyntaxError,
	#superclass : #StringHolder,
	#instVars : [
		'class',
		'selector',
		'debugger',
		'notification'
	],
	#category : #'Tools-Debugger'
}

{ #category : #'instance creation' }
SyntaxError class >> open: aSyntaxErrorNotification [
	
	^ ToolBuilder default openDebugger: (self new setNotification: aSyntaxErrorNotification; yourself)
]

{ #category : #'text menu support' }
SyntaxError >> aboutToStyle: aStyler [

	aStyler
		classOrMetaClass: self selectedClassOrMetaClass;
		parseAMethod: notification doitFlag not.
	^ true
]

{ #category : #toolbuilder }
SyntaxError >> buildWith: builder [

	| windowSpec listSpec textSpec |
	windowSpec := builder pluggableWindowSpec new
		model: self;
		label: 'Syntax Error';
		children: OrderedCollection new.

	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #list; 
		getIndex: #listIndex; 
		setIndex: nil; 
		menu: #listMenu:;
		frame: (0@0 corner: 1@0.15).
	windowSpec children add: listSpec.

	textSpec := builder pluggableCodePaneSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #contents:notifying:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:;
		frame: (0@0.15 corner: 1@1).
	windowSpec children add: textSpec.

	^ builder build: windowSpec
]

{ #category : #other }
SyntaxError >> contents: aString notifying: aController [
	"Accept the code editions if syntax is correct.
	Then let the notification signalerContext proceed and restart compilation with these newSource."

	"In case of failure, return false so as to not accept the edits"
	notification reparse: aString notifying: aController ifFail: [^false].

	"else accept edits and proceed"
	aController hasUnacceptedEdits: false.
	self proceed
]

{ #category : #accessing }
SyntaxError >> contentsSelection [

	^ notification ifNil: [1 to: 0] ifNotNil: [self errorMessageInterval]
]

{ #category : #menu }
SyntaxError >> debug [
	"Show the stack of the process leading to this syntax editor, typically showing the stack of the compiler as called from fileIn."

	debugger openFullNoSuspendLabel: 'Stack of the Syntax Error'.
	Smalltalk isMorphic ifFalse: [Processor terminateActive].

]

{ #category : #accessing }
SyntaxError >> debugger [

	^ debugger
]

{ #category : #'text menu support' }
SyntaxError >> errorMessageInterval [
	"To understand this format, see Parser >> #notify:at:."
	
	^ notification location
		to: notification location
			+ '"' size
			+ notification errorMessage size - 1
			+ ' ->"' size
]

{ #category : #'initialize-release' }
SyntaxError >> initialExtent [

	^ 380@220
]

{ #category : #'message list' }
SyntaxError >> list [
	"Answer an array of one element made up of the class name and message selector in which the syntax error was found. This is the single item in the message list of a view/browser on the receiver."

	^ Array with: (class name, '  ', (selector ifNil: ['<none>']))

]

{ #category : #'message list' }
SyntaxError >> listIndex [
	"There is always exactly one element in my list and it is always selected."

	^ 1

]

{ #category : #menu }
SyntaxError >> listMenu: aMenu [

	^ aMenu labels:
'proceed
debug calling process
browse full'
	lines: #()
	selections: #(proceed debug browseMethodFull)

]

{ #category : #menu }
SyntaxError >> proceed [
	"The user has has edited and presumably fixed the syntax error and the filein can now proceed. The active process usually suspends (or terminates) after this call."

	[debugger proceed]
		ensure: [self changed: #close].
]

{ #category : #'initialize-release' }
SyntaxError >> release [
	debugger ifNotNil:
		[debugger interruptedProcess ifNotNil:
			[:p |	p isTerminated ifFalse:
				[p terminate]]].
]

{ #category : #'text menu support' }
SyntaxError >> selectedClass [
	"Answer the class in which the syntax error occurred."

	^ class

]

{ #category : #'text menu support' }
SyntaxError >> selectedClassOrMetaClass [
	"Answer the class of the method being compiled."

	^ class

]

{ #category : #'text menu support' }
SyntaxError >> selectedMessageName [
	"Answer the selector of the method being compiled."

	^ selector

]

{ #category : #accessing }
SyntaxError >> setNotification: aSyntaxErrorNotification [

	| types printables badChar code |
	notification := aSyntaxErrorNotification.
	class := aSyntaxErrorNotification errorClass.
	
	debugger := Project current debuggerClass new.
	debugger context: aSyntaxErrorNotification signalerContext.
	
	code := aSyntaxErrorNotification errorCode.
	selector := class newParser parseSelector: code.
	types := Scanner classPool at: #TypeTable.	"dictionary"
	printables := '!@#$%&*-_=+<>{}?/\,·£¢§¶ªºÚæÚ¯×¿«»`~`' asSet.
	badChar := code detect: [:aChar | (types at: aChar asciiValue ifAbsent: [#xLetter]) == #xBinary and: [
			(printables includes: aChar) not]] ifNone: [nil].
	contents := badChar 
		ifNil: [code]
		ifNotNil: ['<<<This string contains a character (ascii value ', 
			badChar asciiValue printString,
			') that is not normally used in code>>> ', code].
		
	self changed: #contentsSelection.
]
