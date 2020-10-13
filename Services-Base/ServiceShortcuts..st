"
A data structures implementing a simple form of keyboard shortucts is defined on the class side.

Available keyboard shortcuts are: 

command-0 to command-9 (command is also called alt on some systems).
control-0 to control-0
command-control-0 to command-control-9 (command is also alt)
control-command-left arrow
control-command-up arrow
control-command-right arrow
control-command-down arrow

Using the Services Browser (see class ServicePreferences), these shortcuts can be bound to service identifiers.
"
Class {
	#name : #ServiceShortcuts,
	#superclass : #Object,
	#classInstVars : [
		'map'
	],
	#category : #'Services-Base'
}

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> arrowShortcut: str event: event [ 
	| key s |
	key := event keyCharacter caseOf: {
				[Character arrowDown] -> ['down'].
				[Character arrowUp] -> ['up'].
				[Character arrowLeft] -> ['left'].
				[Character arrowRight] -> ['right']}.
	s := self map
				at: str , key
				ifAbsent: [^ self].
	s serviceOrNil
		ifNotNil: [:sv | sv execute.
	event wasHandled: true]
]

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> changeShortcut: shortcut to: aString [
	aString isBlock ifTrue: [^self map at: shortcut put: aString].
	(aString beginsWith: '[') ifTrue: [^self map at: shortcut put: aString].
	aString isEmpty ifTrue: [self map removeKey: shortcut ifAbsent: []]
				ifFalse: [self map at: shortcut put: aString]
]

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> handleKeystroke: event [ 
	[event isKeystroke
		ifTrue: [self process: event]]
		on: Error
		do: [:e | (self confirm: 'shortcut error. debug?') ifTrue: [e signal]]
]

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> insertPrefShortcut: short [
					ServicePreferences
						addPreference: short
						categories: #('-- keyboard shortcuts --' )
						default: ''
						balloonHelp: 'enter a service id to bind it to this shortcut'
						projectLocal: false
						changeInformee: [self
								changeShortcut: short
								to: (ServicePreferences valueOfPreference: short)]
						changeSelector: #value
						type: #String
]

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> map [
	^ map ifNil: [map := Dictionary new]
]

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> process: event [ 
	event keyCharacter isDigit
		ifTrue: [event commandKeyPressed & event controlKeyPressed
				ifTrue: [^ self shortcut: 'ctrl-cmd-' event: event].
			event commandKeyPressed
				ifTrue: [^ self shortcut: 'cmd-' event: event].
			event controlKeyPressed
				ifTrue: [^ self shortcut: 'ctrl-' event: event]].
	({Character arrowUp. Character arrowDown. Character arrowLeft. Character arrowRight} includes: event keyCharacter)
		ifTrue: [event commandKeyPressed & event controlKeyPressed
				ifTrue: [^ self arrowShortcut: 'ctrl-cmd-' event: event].
			]
]

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> setPreferences [
	| mm |
	mm := self map copy.
	(0 to: 9)
		do: [:i | #('ctrl-' 'cmd-' 'ctrl-cmd-' )
				do: [:str | 
					| short | 
					short := (str , i asString) asSymbol.
					self insertPrefShortcut: short]].
	#(#up #down #left #right )
		do: [:s | 
			self insertPrefShortcut: ('ctrl-cmd-' , s) asSymbol.].
	mm
		keysAndValuesDo: [:k :v | ServicePreferences setPreference: k toValue: v].
	((Array new: 3) at: 1 put: ((Array new: 3) at: 1 put: #inlineServicesInMenu;
			 at: 2 put: true;
			 at: 3 put: 'Inline services within squeak menus';
			 yourself);
		 at: 2 put: ((Array new: 3) at: 1 put: #useOnlyServicesInMenu;
			 at: 2 put: false;
			 at: 3 put: 'Use only services and not regular menu items';
			 yourself);
		 at: 3 put: ((Array new: 3) at: 1 put: #useServicesInBrowserButtonBar;
			 at: 2 put: true;
			 at: 3 put: 'Use a service-based button bar';
			 yourself);
		 yourself)
		do: [:tr | ServicePreferences
				addPreference: tr first
				categories: #('-- settings --' )
				default: tr second
				balloonHelp: tr third]
]

{ #category : #'as yet unclassified' }
ServiceShortcuts class >> shortcut: str event: event [ 
	| s |
	Transcript cr.
	s := self map
				at: str , event keyCharacter asString
				ifAbsent: [^ self].
	(s beginsWith: '[') ifTrue: [^ (Compiler evaluateUnloggedForSelf:  s) value].
	s serviceOrNil
		ifNotNil: [:sv | sv execute.
	event wasHandled: true]
]
