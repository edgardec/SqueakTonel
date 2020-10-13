Class {
	#name : #MessageNames,
	#superclass : #MessageSet,
	#instVars : [
		'searchString',
		'selectorList',
		'selectorListIndex'
	],
	#category : #'Tools-Browser'
}

{ #category : #'instance creation' }
MessageNames class >> methodBrowserSearchingFor: searchString [
	"Answer an method-browser window whose search-string is initially as indicated"

	| aWindow |
	aWindow := self new searchString: searchString.
	^ToolBuilder default build: aWindow
]

{ #category : #'instance creation' }
MessageNames class >> openMessageNames [
	"Open a new instance of the receiver in the active world"
	^(ToolBuilder open: self new label: 'Message Names') model

	"MessageNames openMessageNames"

]

{ #category : #'instance creation' }
MessageNames class >> prototypicalToolWindow [
	"Answer an example of myself seen in a tool window, for the benefit of parts-launching tools"

	^ self methodBrowserSearchingFor: ''
]

{ #category : #toolbuilder }
MessageNames >> buildSearchPaneWith: builder [
	
	| panelSpec textSpec buttonSpec |
	panelSpec := builder pluggablePanelSpec new
		layout: #horizontal;
		children: OrderedCollection new;
		yourself.

	textSpec := builder pluggableInputFieldSpec new.
	textSpec 
		model: searchString;
		help: 'Type here, then hit Search.' translated;
		getText: #contents; 
		setText: #contents:;
		softLineWrap: true.
	panelSpec children add: textSpec.
		
	buttonSpec := builder pluggableActionButtonSpec new.
	buttonSpec 
		model: self;
		label: 'Search';
		action: #doSearch;
		horizontalResizing: #shrinkWrap.
	panelSpec children add: buttonSpec.
			
	^ panelSpec
]

{ #category : #toolbuilder }
MessageNames >> buildSelectorListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #selectorList; 
		getIndex: #selectorListIndex; 
		setIndex: #selectorListIndex:; 
		menu: #selectorListMenu:; 
		keyPress: #selectorListKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
MessageNames >> buildWith: builder [
	"ToolBuilder open: MessageNames new"

	| windowSpec max searchHeight |
	max := self wantsOptionalButtons ifTrue:[0.42] ifFalse:[0.5].
	searchHeight := Preferences standardDefaultTextFont height * 2.
	
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.5@0.1) -> [self buildSearchPaneWith: builder].
		(0@0.1 corner: 0.5 @ max) -> [self buildSelectorListWith: builder].
		(0.5@0.0 corner: 1.0@max) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.

	^ builder build: windowSpec
]

{ #category : #search }
MessageNames >> computeMessageList [

	^ selectorListIndex = 0
		ifTrue: [#()]
		ifFalse: [self systemNavigation
			allImplementorsOf: (selectorList at: selectorListIndex)]
]

{ #category : #search }
MessageNames >> computeSelectorListFrom: searchString [
	"Compute selector list from search string. The searchString is a list of expressions separated by ;. Each expression is matched individually. An expression can be a simple string (same as *expression*), a string with double quotes (exact match) or a match expression (see String >> #match:)."
	
	^ (Array streamContents: [ :stream |
			(searchString findBetweenSubStrs: ';') do: [ :selPat |
				(selPat first = $" and: [ selPat last = $" and: [ selPat size > 2 ] ])
					ifTrue: [
						Symbol 
							hasInterned: (selPat copyFrom: 2 to: selPat size - 1)
							ifTrue: [ :sym | stream nextPut: sym ] ]
					ifFalse: [
						| raw n m |
						n := selPat occurrencesOf: $*.
						m := selPat occurrencesOf:  $#.
						raw := ((n > 0 or: [ m > 0 ]) 	and: [ selPat size > (n + m) ])
							ifTrue: [ Symbol selectorsMatching: selPat ]
							ifFalse: [ Symbol selectorsContaining: selPat ].
						stream nextPutAll: raw ] ] ]) 
			sort: [ :x :y | x caseInsensitiveLessOrEqual: y ]
]

{ #category : #'message list menu' }
MessageNames >> copyName [
	"Copy the current selector to the clipboard"

	| selector |
	(selector := self selectorList at: selectorListIndex ifAbsent: [nil]) ifNotNil:
		[Clipboard clipboardText: selector asString asText]
]

{ #category : #'user interface' }
MessageNames >> defaultWindowColor [
	^ (Color r: 0.639 g: 0.9 b: 0.497)
]

{ #category : #search }
MessageNames >> doSearch [
	"The user hit the Search button -- treat it as a synonym for the user having hit the Return or Enter (or cmd-s) in the type-in pane"

	searchString changed: #acceptChanges.
]

{ #category : #search }
MessageNames >> doSearch: aSearchString [
	
	| normalizedSearchString |
	normalizedSearchString := aSearchString asString copyWithout: Character space.
		
	Cursor wait showWhile: [
		self selectorList: (self computeSelectorListFrom: normalizedSearchString)].
	
	^ true
]

{ #category : #toolbuilder }
MessageNames >> frameOffsetFromTop: height fromLeft: leftFraction width: rightFraction bottomFraction: bottomFraction [
	^LayoutFrame new
		topFraction: 0 offset: height;
		leftFraction: leftFraction offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: bottomFraction offset: 0;
		yourself.
]

{ #category : #initialization }
MessageNames >> initialize [

	super initialize.
	
	searchString := ValueHolder new contents: ''.
	searchString addDependent: self.
	
	selectorList := #().
	selectorListIndex := 0.
	
	self messageListIndex: 0.
]

{ #category : #initialization }
MessageNames >> labelString [

	^ self searchString
		ifEmpty: ['Message Names']
		ifNotEmpty: [:s | 'Message names containing "', s asString asLowercase, '"']
]

{ #category : #'selector list' }
MessageNames >> mainSelectorListMenu: aMenu [
	"Answer the menu associated with the selectorList"
	<selectorListMenu>
	aMenu addList: #(
		('senders (n)'				browseSenders		'browse senders of the chosen selector')
		('copy selector to clipboard'	copyName			'copy the chosen selector to the clipboard, for subsequent pasting elsewhere')
		-
		('show only implemented selectors'	showOnlyImplementedSelectors		'remove from the selector-list all symbols that do not represent implemented methods')).

	^ aMenu
]

{ #category : #'message list' }
MessageNames >> messageList: someObjects [

	messageList := someObjects.
	self changed: #messageList.
	
	self messageListIndex: (messageList size > 0
			ifTrue: [1]
			ifFalse: [0]).
]

{ #category : #'morphic ui' }
MessageNames >> postAcceptBrowseFor: anotherModel [

	self searchString: anotherModel searchString.
]

{ #category : #search }
MessageNames >> searchString [

	^ searchString contents
]

{ #category : #search }
MessageNames >> searchString: aString [
	
	searchString contents: aString.
]

{ #category : #'class list' }
MessageNames >> selectedClassOrMetaClass [
	"Answer the currently selected class (or metaclass)."
	self hasMessageSelected ifTrue:
		[ ^ self setClassAndSelectorIn: [:c :s | ^c] ].
	
	(selectorListIndex isNil not and: [selectorListIndex > 0]) ifTrue: [^Smalltalk classNamed: (self selectorList at: selectorListIndex)].
	
	^ nil.
	
]

{ #category : #'message list' }
MessageNames >> selectedMessageName [
	selectorList basicSize = 0 ifTrue: [^ nil]. "Deals with selectorList nil or empty"
	^selectorList at: (selectorListIndex max: 1) ifAbsent: [nil] "If no selection we can still find a selector"
]

{ #category : #'selector list' }
MessageNames >> selectorList [

	^ selectorList
]

{ #category : #'selector list' }
MessageNames >> selectorList: someObjects [
	"Answer the selectorList"

	selectorList := someObjects.
	self changed: #selectorList.
	
	"Select first result if any."
	self selectorListIndex: (selectorList size > 0
			ifTrue: [1]
			ifFalse: [0]).
]

{ #category : #toolbuilder }
MessageNames >> selectorListFrame: max fromTop: topOffset [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: topOffset;
		rightFraction: 0.5 offset: 0;
		bottomFraction: max offset: 0.
]

{ #category : #'selector list' }
MessageNames >> selectorListIndex [
	"Answer the selectorListIndex"

	^ selectorListIndex
]

{ #category : #'selector list' }
MessageNames >> selectorListIndex: anInteger [ 
	"Set the selectorListIndex as specified, and propagate consequences"
	| methodClass index |
	methodClass := currentCompiledMethod ifNotNil: [currentCompiledMethod methodClass].
	selectorListIndex := anInteger.
	self changed: #selectorListIndex.

	messageList := self computeMessageList.
	self changed: #messageList.
	messageList size > 1 ifTrue:
		[methodClass ifNotNil: [index := messageList findFirst: [:methodRef| methodRef actualClass = methodClass]]].

	"If a method of the same class exists, select that, otherwise select the first message if any."
	self messageListIndex: (index ifNil: [1 min: messageList size])
]

{ #category : #'selector list' }
MessageNames >> selectorListKey: aChar from: view [
	"Respond to a Command key in the message-list pane."

	aChar == $n ifTrue: [^ self browseSenders].
	aChar == $c ifTrue: [^ self copyName].
	aChar == $b ifTrue: [^ self browseMethodFull].

]

{ #category : #'selector list' }
MessageNames >> selectorListMenu: aMenu [
	"Answer the menu associated with the selectorList"
	^ self menu: aMenu for: #(selectorListMenu selectorListMenuShifted:)

]

{ #category : #'selector list' }
MessageNames >> selectorListMenuTitle [
	"Answer the title to supply for the menu belonging to the selector-list pane"

	^ 'Click on any item in the list
to see all implementors of it'
]

{ #category : #search }
MessageNames >> showOnlyImplementedSelectors [
	"Caution -- can be slow! Filter my selector list down such that it only  
	shows selectors that are actually implemented somewhere in the system."
	self okToChange ifFalse: [^ self].
	
	Cursor wait showWhile: [
		self selectorList: (self systemNavigation allSelectorsWithAnyImplementorsIn: selectorList)].
]

{ #category : #toolbuilder }
MessageNames >> topConstantHeightFrame: height fromLeft: leftFraction width: rightFraction [
	^LayoutFrame new
		topFraction: 0 offset: 0;
		leftFraction: leftFraction offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: 0 offset: height;
		yourself.
]

{ #category : #updating }
MessageNames >> update: aspect [

	aspect == #contents
		ifTrue: [
			self changed: #labelString.
			self doSearch: self searchString].
		
	super update: aspect.
]
