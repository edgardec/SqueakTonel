"
I am used to build menus on-the-fly. I maintain lists of menu items, actions (usually symbols to be sent as messages), and menu section dividing lines to which my clients may append new entries and lines by sending me the messages:

	add: aString action: anAction
	addLine

After the menu is constructed, it may be invoked with one of the following messages:

	startUp: initialSelection
	startUp

I am a subclass of ActionMenu, so I inherit a number of instance variables. The ones I am particularly concerned with are:

	items := an OrderedCollection of strings to appear in the menu
	selectors := an OrderedCollection of Symbols to be used as message selectors
	lineArray := an OrderedCollection of line positions
	lastLine := used to keep track of the last line to avoid making duplicate entries in lineArray
"
Class {
	#name : #CustomMenu,
	#superclass : #SelectionMenu,
	#instVars : [
		'labels',
		'dividers',
		'lastDivider',
		'title',
		'targets',
		'arguments'
	],
	#category : #'Tools-Menus'
}

{ #category : #example }
CustomMenu class >> example [
	"CustomMenu example"

	| menu |
	menu := CustomMenu new.
	menu add: 'apples' action: #apples.
	menu add: 'oranges' action: #oranges.
	menu addLine.
	menu addLine.  "extra lines ignored"
	menu add: 'peaches' action: #peaches.
	menu addLine.
	menu add: 'pears' action: #pears.
	menu addLine.
	^ menu startUp: #apples


"NB:  The following is equivalent to the above, but uses the compact #fromArray: consruct:
	(CustomMenu fromArray:
		#(	('apples'		apples)
			('oranges'		oranges)
			-
			-
			('peaches'		peaches)
			-
			('pears'			pears)
			-))
				startUp: #apples"
]

{ #category : #construction }
CustomMenu >> add: aString action: actionItem [
	"Add the given string as the next menu item. If it is selected, the given action (usually but not necessarily a symbol) will be returned to the client."

	| s |
	aString ifNil: [^ self addLine].
	s := String new: aString size + 2.
	s at: 1 put: Character space.
	s replaceFrom: 2 to: s size - 1 with: aString.
	s at: s size put: Character space.
	labels addLast: s.
	selections addLast: actionItem.
]

{ #category : #compatibility }
CustomMenu >> add: aString subMenu: aMenu target: target selector: aSymbol argumentList: argList [
	"Create a sub-menu with the given label. This isn't really a sub-menu the way Morphic does it; it'll just pop up another menu."

	self
		add: aString
		target: aMenu
		selector: #invokeOn:
		argumentList: argList asArray.
]

{ #category : #compatibility }
CustomMenu >> add: aString target: target selector: aSymbol [ 

	self add: aString
		target: target
		selector: aSymbol
		argumentList: #()
]

{ #category : #compatibility }
CustomMenu >> add: aString target: target selector: aSymbol argument: arg [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given argument."

	self add: aString
		target: target
		selector: aSymbol
		argumentList: (Array with: arg)
]

{ #category : #compatibility }
CustomMenu >> add: aString target: target selector: aSymbol argumentList: argList [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	self add: aString action: aSymbol.
	targets addLast: target.
	arguments addLast: argList asArray

]

{ #category : #construction }
CustomMenu >> addLine [
	"Append a line to the menu after the last entry. Suppress duplicate lines."

	(lastDivider ~= selections size) ifTrue: [
		lastDivider := selections size.
		dividers addLast: lastDivider].
]

{ #category : #construction }
CustomMenu >> addList: listOfTuplesAndDashes [
	"Add a menu item to the receiver for each tuple in the given list of the form (<what to show> <selector>). Add a line for each dash (-) in the list.  The tuples may have an optional third element, providing balloon help for the item, but such an element is ignored in mvc."

	listOfTuplesAndDashes do: [:aTuple |
		aTuple == #-
			ifTrue: [self addLine]
			ifFalse: [self add: aTuple first action: aTuple second]]

	"CustomMenu new addList: #(
		('apples' buyApples)
		('oranges' buyOranges)
		-
		('milk' buyMilk)); startUp"


]

{ #category : #compatibility }
CustomMenu >> addService: aService for: serviceUser [
	"Append a menu item with the given service. If the item is selected, it will perform the given service."

	aService addServiceFor: serviceUser toMenu: self.
]

{ #category : #compatibility }
CustomMenu >> addServices2: services for: served extraLines: linesArray [

	services withIndexDo: [:service :i |
		service addServiceFor: served toMenu: self.
		(linesArray includes: i)  ifTrue: [self addLine] ]
]

{ #category : #compatibility }
CustomMenu >> addServices: services for: served extraLines: linesArray [

	services withIndexDo: [:service :i |
		self addService: service for: served.
		(linesArray includes: i) | service useLineAfter 
			ifTrue: [self addLine]]
]

{ #category : #construction }
CustomMenu >> addStayUpItem [
	"For compatibility with MenuMorph.  Here it is a no-op"
]

{ #category : #construction }
CustomMenu >> addStayUpItemSpecial [
	"For compatibility with MenuMorph.  Here it is a no-op"
]

{ #category : #construction }
CustomMenu >> addTitle: aString [
	"For compatibility with MenuMorph.  Here it is a no-op"
]

{ #category : #construction }
CustomMenu >> addTranslatedList: listOfTuplesAndDashes [
	"Add a menu item to the receiver for each tuple in the given list of the form (<what to show> <selector>). Add a line for each dash (-) in the list.  The tuples may have an optional third element, providing balloon help for the item, but such an element is ignored in mvc.
	The first element will be translated."

	listOfTuplesAndDashes do: [:aTuple |
		aTuple == #-
			ifTrue: [self addLine]
			ifFalse: [self add: aTuple first translated action: aTuple second]]

	"CustomMenu new addTranslatedList: #(
		('apples' buyApples)
		('oranges' buyOranges)
		-
		('milk' buyMilk)); startUp"


]

{ #category : #compatibility }
CustomMenu >> arguments [
	"Answer my arguments, initializing them to an empty collection if they're found to be nil."

	^ arguments ifNil: [arguments := OrderedCollection new]
]

{ #category : #construction }
CustomMenu >> balloonTextForLastItem: aString [
	"Vacuous backstop provided for compatibility with MorphicMenu"
]

{ #category : #private }
CustomMenu >> build [
	"Turn myself into an invokable ActionMenu."

	| stream |
	stream := WriteStream on: (String new).
	labels do: [:label | stream nextPutAll: label; cr].
	(labels isEmpty) ifFalse: [stream skip: -1].  "remove final cr"
	super labels: stream contents
		font: Preferences standardMenuFont
		lines: dividers
]

{ #category : #'initialize-release' }
CustomMenu >> initialize [

	labels := OrderedCollection new.
	selections := OrderedCollection new.
	dividers := OrderedCollection new.
	lastDivider := 0.
	targets := OrderedCollection new.
	arguments := OrderedCollection new	
]

{ #category : #invocation }
CustomMenu >> invokeOn: targetObject [
	"Pop up this menu and return the result of sending to the target object the selector corresponding to the menu item selected by the user. Return nil if no item is selected.  If the chosen selector has arguments, obtain them from my arguments"

	^ self invokeOn: targetObject orSendTo: nil
]

{ #category : #invocation }
CustomMenu >> invokeOn: targetObject defaultSelection: defaultSelection [
	"Invoke the menu with the given default selection (i.e. one of my 'action' symbols). Answer the 'action' selector associated with the menu item chosen by the user or nil if none is chosen."

	| sel |
	sel := self startUp: defaultSelection.
	sel = nil ifFalse: [
		sel numArgs = 0
			ifTrue: [^ targetObject perform: sel]
			ifFalse: [^ targetObject perform: sel with: nil]].
	^ nil

]

{ #category : #invocation }
CustomMenu >> invokeOn: targetObject orSendTo: anObject [
	"Pop up this menu and return the result of sending to the target object the selector corresponding to the menu item selected by the user. Return  nil if no item is selected.  If the chosen selector has arguments, obtain appropriately.  If the recipient does not respond to the resulting message, send it to the alternate object provided"

	| aSelector anIndex recipient |
	^ (aSelector := self startUp) ifNotNil:
		[anIndex := self selection.
		recipient := ((targets := self targets) isEmptyOrNil or: [anIndex > targets size])
			ifTrue:
				[targetObject]
			ifFalse:
				[targets at: anIndex].
		aSelector numArgs = 0
			ifTrue:
				[recipient perform: aSelector orSendTo: anObject]
			ifFalse:
				[recipient perform: aSelector withArguments: (self arguments at: anIndex)]]
]

{ #category : #construction }
CustomMenu >> labels: aString font: aFont lines: anArrayOrNil [
	"This method allows the receiver to accept old-style SelectionMenu creation messages. It should be used only for backward compatibility during the MVC-to-Morphic transition. New code should be written using the other menu construction protocol such as addList:."

	| labelList linesArray |
	labelList := aString lines asArray.
	anArrayOrNil
		ifNil: [linesArray := #()]
		ifNotNil: [linesArray := anArrayOrNil].
	1 to: labelList size do: [:i |
		self add: (labelList at: i) action: (labelList at: i).
		(linesArray includes: i) ifTrue: [self addLine]].
	font ifNotNil: [font := aFont].

]

{ #category : #construction }
CustomMenu >> labels: labelList lines: linesArray selections: selectionsArray [
	"This method allows the receiver to accept old-style SelectionMenu creation messages. It should be used only for backward compatibility during the MVC-to-Morphic transition. New code should be written using the other menu construction protocol such as addList:."
	"Labels can be either a sting with embedded crs, or a collection of strings."

	| labelArray |
	labelList isString
		ifTrue: [labelArray := labelList lines]
		ifFalse: [labelArray := labelList].
	1 to: labelArray size do: [:i |
		self add: (labelArray at: i) action: (selectionsArray at: i).
		(linesArray includes: i) ifTrue: [self addLine]].

]

{ #category : #private }
CustomMenu >> preSelect: action [
	"Pre-select and highlight the menu item associated with the given action."

	| i |
	i := selections indexOf: action ifAbsent: [^ self].
	marker ifNil: [self computeForm].
	marker := marker
		align: marker topLeft
		with: (marker left)@(frame inside top + (marker height * (i - 1))).
	selection := i.
]

{ #category : #invocation }
CustomMenu >> startUp [
	"Build and invoke this menu with no initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	^ self startUp: nil
]

{ #category : #invocation }
CustomMenu >> startUp: initialSelection [
	"Build and invoke this menu with the given initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	^ self startUp: initialSelection withCaption: title
]

{ #category : #invocation }
CustomMenu >> startUp: initialSelection withCaption: caption [
	"Build and invoke this menu with the given initial selection and caption. Answer the selection associated with the menu item chosen by the user or nil if none is chosen."

	self build.
	(initialSelection notNil) ifTrue: [self preSelect: initialSelection].
	^ super startUpWithCaption: caption
]

{ #category : #invocation }
CustomMenu >> startUpWithCaption: caption [
	"Build and invoke this menu with no initial selection. Answer the selection associated with the menu item chosen by the user or nil if none is chosen; use the provided caption"

	^ self startUp: nil withCaption: caption
]

{ #category : #compatibility }
CustomMenu >> targets [
	"Answer my targets, initializing them to an empty collection if found to be nil"

	^ targets ifNil: [targets := OrderedCollection new]
]

{ #category : #'initialize-release' }
CustomMenu >> title: aTitle [
	title := aTitle
]
