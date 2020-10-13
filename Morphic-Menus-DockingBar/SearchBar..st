Class {
	#name : #SearchBar,
	#superclass : #Model,
	#instVars : [
		'originatingWidget',
		'searchTerm',
		'selection',
		'resultsWidget',
		'workspace',
		'scratchPad'
	],
	#classVars : [
		'UseScratchPad',
		'UseSmartSearch'
	],
	#category : #'Morphic-Menus-DockingBar'
}

{ #category : #building }
SearchBar class >> build [

	^ ToolBuilder build: self new
]

{ #category : #preferences }
SearchBar class >> useScratchPad [
	<preference: 'Ctrl+0 invokes the scratch pad'
		category: 'docking bars'
		description: 'When enabled, pressing Ctrl+0 will go straight to the Search Bar''s scratch pad instead of the Search Bar, where pressing ESCape will return keyboard focus to the originating window.'
		type: #Boolean>
	^ UseScratchPad ifNil: [ false ]
]

{ #category : #preferences }
SearchBar class >> useScratchPad: aBoolean [
	UseScratchPad := aBoolean
]

{ #category : #preferences }
SearchBar class >> useSmartSearch [
	<preference: 'Smart search'
		category: 'docking bars'
		description: 'When enabled, the docking bar search tries to find globals or full class names first, then tries to browse implementors, then tries to find class names if the search term starts uppercase, and finally invoke the regular message names search. When disabled, do only the last.'
		type: #Boolean>
	^ UseSmartSearch ifNil: [ true ]
]

{ #category : #preferences }
SearchBar class >> useSmartSearch: aBoolean [
	UseSmartSearch := aBoolean.
]

{ #category : #accessing }
SearchBar >> activate: event in: morph [ 
	self class useScratchPad
		ifTrue:
			[ event hand keyboardFocus = self scratchPad ifFalse: [ originatingWidget := event hand keyboardFocus ].
			self scratchPad selectAll; openInWorld.
			self layoutScratchPad.
			event hand newKeyboardFocus: self scratchPad ]
		ifFalse:
			[ self selection: (1 to: self searchTerm size).
			event hand newKeyboardFocus: morph textMorph ]
]

{ #category : #accessing }
SearchBar >> bindingOf: x [

	^ self workspace bindingOf: x
]

{ #category : #toolbuilder }
SearchBar >> buildWith: builder [

	^ (builder build: (builder pluggableInputFieldSpec new
		model: self;
		getText: #searchTerm;
		setText: #smartSearch:in:;
		editText: #searchTermSilently:;
		menu: #menu:shifted:;
		selection: #selection;
		indicateUnacceptedChanges: false;
		help: 'Search or evaluate...' translated))
			name: #searchBar;
			wantsFrameAdornments: false;
			yourself
]

{ #category : #private }
SearchBar >> handleScratchPadKey: aKeyboardEvent [ 
	(aKeyboardEvent keyValue = Character escape asciiValue and: [ originatingWidget notNil ]) ifTrue:
		[ aKeyboardEvent hand newKeyboardFocus: originatingWidget.
		self removeScratchPad ]
]

{ #category : #private }
SearchBar >> layoutScratchPad [
	| world pos width |
	world := Project current world.
	world mainDockingBars do:
		[ : each | each searchBarMorph ifNotNil:
			[ : searchBar | pos := searchBar bottomLeft.
			width := searchBar width ] ].
	width ifNil: [ width := 250.  pos := world topRight - (width @ 5) ].
	scratchPad
		width: width ;
		position: pos ;
		startStepping: #deleteUnlessHasFocus at: Time millisecondClockValue arguments: nil stepTime: 3000
]

{ #category : #accessing }
SearchBar >> menu: aMenu shifted: aBoolean [

	^ StringHolder codePaneMenu: aMenu shifted: aBoolean
]

{ #category : #'do-its' }
SearchBar >> printIt: code result: object [

	| focusedWidget |
	focusedWidget := self currentHand keyboardFocus.

	self removeResultsWidget.
	
	ToolBuilder default in: [:builder |
		resultsWidget := (builder build: (StringHolder new
			contents: object asString;
			buildCodePaneWith: builder)).
		"This might cause the widget disappear to early. Especially if the textMorph is to small but the container needs to maintain a larger size because of its scroll bars."
		resultsWidget textMorph
			on: #mouseLeave send: #delete to: resultsWidget.
		resultsWidget
			extent: 1000@1000; fullBounds; "give text a chance to layout good"
			width: 250; fullBounds;
			height: (resultsWidget extentToFit y min: 300);
			position: (focusedWidget
				ifNotNil: [:w | w owner boundsInWorld bottomLeft]
				ifNil: [self currentHand position]);
			color: (BalloonMorph balloonColor alpha: 1.0).
			
		Preferences menuAppearance3d
			ifTrue: [resultsWidget addDropShadow].
			
		resultsWidget openInWorld].
]

{ #category : #accessing }
SearchBar >> removeResultsWidget [

	resultsWidget ifNotNil: [:w | w delete].
	resultsWidget := nil.
]

{ #category : #accessing }
SearchBar >> removeScratchPad [
	scratchPad ifNotNil: [ scratchPad delete ]
]

{ #category : #accessing }
SearchBar >> scratchPad [
	^ scratchPad ifNil:
		[ scratchPad := TextMorphForEditView new. "we should be able to use TextMorph here; fix later"
		scratchPad
"			on: #keyboardFocusChange send: #removeScratchPad to: self ;"
			on: #mouseLeave send: #removeScratchPad to: self ;
			on: #keyStroke send: #handleScratchPadKey: to: self ;
			margins: (5@0 corner: 5@0);
			backgroundColor: ((UserInterfaceTheme current get: #color for: #NewBalloonMorph) ifNil: [ BalloonMorph balloonColor ]) ;
			setEditView: PluggableTextMorph new ; "dummy"
			autoFit: true ;
			wrapFlag: true ;
			newContents: '--scratch area--' ;
			font: ((UserInterfaceTheme current get: #font for: #PluggableTextMorph) ifNil: [TextStyle defaultFont]);
			textColor: ((UserInterfaceTheme current get: #textColor for: #PluggableTextMorph) ifNil: [Color black]);
			caretColor: ((UserInterfaceTheme current get: #caretColor for: #PluggableTextMorph) ifNil: [Color red]);
			selectionColor: ((UserInterfaceTheme current get: #selectionColor for: #PluggableTextMorph) ifNil: [Color blue muchDarker] ifNotNil: [ : col | col twiceLighter ]); 
			yourself.
		self layoutScratchPad.
		Preferences menuAppearance3d ifTrue: [ scratchPad addDropShadow ].
		scratchPad ]
]

{ #category : #accessing }
SearchBar >> searchTerm [

	^ searchTerm ifNil: ['']
]

{ #category : #accessing }
SearchBar >> searchTerm: aString [

	searchTerm := aString.
	self changed: #searchTerm.
]

{ #category : #accessing }
SearchBar >> searchTermSilently: aString. [
	"Do not signal it to the model."
	
	searchTerm := aString.
]

{ #category : #accessing }
SearchBar >> selection [

	^ selection ifNil: [1 to: 0]
]

{ #category : #accessing }
SearchBar >> selection: anInterval [

	selection := anInterval.
	self changed: #selection.
]

{ #category : #searching }
SearchBar >> smartSearch: text in: morph [
	"Take the user input and perform an appropriate search"
	| input newContents |
	self removeResultsWidget.
	input := text asString ifEmpty:[^self].
	self class useSmartSearch ifFalse: [^ ToolSet default browseMessageNames: input].

	"If it is a global or a full class name, browse that class."
	(Smalltalk bindingOf: input) ifNotNil:[:assoc| | global |
		global := assoc value.
		^ToolSet browse: (global isBehavior ifTrue:[global] ifFalse:[global class]) selector: nil].
	
	"If it is a symbol and there are implementors of it, browse those implementors."
	Symbol hasInterned: input ifTrue: [:selector |
		(SystemNavigation new allImplementorsOf: selector) ifNotEmpty:[:list|
			^SystemNavigation new
				browseMessageList: list
				name: 'Implementors of ' , input]].

	"If it starts uppercase, browse classes if any. Otherwise, just search for messages."
	input first isUppercase
		ifTrue: [
			(UIManager default classFromPattern: input withCaption: '')
				ifNotNil:[:aClass| ^ToolSet browse: aClass selector: nil]
				ifNil: [
					newContents := input, ' -- not found.'.
					self searchTerm: newContents.
					self selection: (input size+1 to: newContents size).
					self currentHand newKeyboardFocus: morph textMorph.
					^ self]]
		ifFalse: [
			ToolSet default browseMessageNames: input].
]

{ #category : #accessing }
SearchBar >> workspace [

	^ workspace ifNil: [workspace := Workspace new]
]
