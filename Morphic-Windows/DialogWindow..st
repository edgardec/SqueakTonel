"
A DialogBoxMorph is Morph used in simple yes/no/confirm dialogs. Strongly modal.
"
Class {
	#name : #DialogWindow,
	#superclass : #Morph,
	#instVars : [
		'titleMorph',
		'messageMorph',
		'paneMorph',
		'buttonRow',
		'result',
		'selectedButton',
		'cancelButton',
		'timeout',
		'preferredPosition',
		'keyMap',
		'exclusive',
		'filter',
		'filterEnabled',
		'filterMorph',
		'autoCancel'
	],
	#classVars : [
		'GradientDialog',
		'IncludeCloseButton',
		'IncludeControlMenu',
		'RoundedDialogCorners',
		'UseWiggleAnimation'
	],
	#category : #'Morphic-Windows'
}

{ #category : #preferences }
DialogWindow class >> gradientDialog [

	<preference: 'gradientDialog'
		category: 'dialogs'
		description: 'If true, dialogs will have a gradient look.'
		type: #Boolean>
	^ GradientDialog ifNil: [true]

]

{ #category : #preferences }
DialogWindow class >> gradientDialog: aBoolean [

	aBoolean = GradientDialog ifTrue: [^ self].
	GradientDialog := aBoolean.
	self refreshAllDialogs.
]

{ #category : #preferences }
DialogWindow class >> includeCloseButton [

	<preference: 'include dialog close button'
		category: #dialogs
		description: 'If true, user dialogs include a close button.'
		type: #Boolean>
	^IncludeCloseButton ifNil: [true]
]

{ #category : #preferences }
DialogWindow class >> includeCloseButton: aBoolean [

	IncludeCloseButton := aBoolean
]

{ #category : #preferences }
DialogWindow class >> includeControlMenu [

	<preference: 'include dialog control menu'
		category: #dialogs
		description: 'If true, user dialogs include a control menu.'
		type: #Boolean>
	^IncludeControlMenu ifNil: [true]
]

{ #category : #preferences }
DialogWindow class >> includeControlMenu: aBoolean [
	IncludeControlMenu := aBoolean
]

{ #category : #preferences }
DialogWindow class >> refreshAllDialogs [
	
	self allSubInstances do: [:instance | instance setDefaultParameters; setTitleParameters].
]

{ #category : #preferences }
DialogWindow class >> roundedDialogCorners [
	<preference: 'Rounded Dialog Corners'
		categoryList: #(windows dialogs)
		description: 'If true, dialog windows will have rounded corners'
		type: #Boolean>
	^ RoundedDialogCorners ifNil: [ true ]
]

{ #category : #preferences }
DialogWindow class >> roundedDialogCorners: aBoolean [
	
	RoundedDialogCorners = aBoolean ifTrue: [^ self].
	RoundedDialogCorners := aBoolean.
	self refreshAllDialogs.
]

{ #category : #preferences }
DialogWindow class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the dialogs''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the dialogs''s border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the dialog.' }.
		{ #font. 'Fonts'. 'Font for dialog messages.' }.
		{ #textColor. 'Colors'. 'Color for dialog messages.' }.
		
		{ #titleBorderColor. 'Colors'. 'Color of the dialogs title border.' }.
		{ #titleBorderWidth. 'Geometry'. 'Width of the dialog title border.' }.
		{ #titleBorderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset for the title.' }.
		{ #titleColor. 'Colors'. 'Background color of the dialogs'' title.' }.
		{ #titleFont. 'Fonts'. 'Font for dialog title.' }.
		{ #titleTextColor. 'Colors'. 'Color for the dialog title label.' }.
		
		{ #okColor. 'Colors'. 'Color for the OK button.' }.
		{ #cancelColor. 'Colors'. 'Color for the Cancel button.' }.
		{ #buttonColor. 'Colors'. 'Color for a normal button.' }.
		{ #selectionModifier. 'Colors'. 'How to convert the color of a selected button?' }.
	}
]

{ #category : #preferences }
DialogWindow class >> useWiggleAnimation [
	
	<preference: 'Use Wiggle Animation in Modal Dialogs'
		categoryList: #(Morphic windows dialogs)
		description: 'In order to indicate that a modal dialog is waiting for a user''s input, wiggle instead of flash.'
		type: #Boolean>
	^ UseWiggleAnimation ifNil: [true]
]

{ #category : #preferences }
DialogWindow class >> useWiggleAnimation: aBoolean [
	
	UseWiggleAnimation := aBoolean.
]

{ #category : #constructing }
DialogWindow >> addPaneMorph: aMorph [

	self paneMorph addMorphBack: aMorph.
]

{ #category : #updating }
DialogWindow >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self
		setDefaultParameters;
		setTitleParameters;
		setMessageParameters.
		
	"Update all buttons."
	selectedButton in: [:sb |
		self buttons do: [:ea |
			ea setProperty: #normalColor toValue: self defaultButtonColor.
			self deselectButton: ea].
		sb ifNotNil: [self selectButton: sb]].
]

{ #category : #accessing }
DialogWindow >> autoCancel [
	"Whether to automatically cancel and close this dialog if the user clicks outside it. Like dismissing a pop-up menu."
	
	^ autoCancel
]

{ #category : #accessing }
DialogWindow >> autoCancel: aBoolean [

	autoCancel := aBoolean.
]

{ #category : #'accessing - ui' }
DialogWindow >> buttonRowMorph [
	^ buttonRow
]

{ #category : #'accessing - ui' }
DialogWindow >> buttons [

	^buttonRow submorphs
]

{ #category : #'accessing - ui' }
DialogWindow >> cancelButton [
	^ cancelButton
]

{ #category : #running }
DialogWindow >> cancelDialog [

	self cancelButton
		ifNil: [self closeDialog: nil]
		ifNotNil: [:btn | btn performAction].	
]

{ #category : #running }
DialogWindow >> closeDialog [

	self selectedButton
		ifNil: [self closeDialog: nil]
		ifNotNil: [:btn | btn performAction].	
]

{ #category : #running }
DialogWindow >> closeDialog: returnValue [
	result := returnValue.
	self delete.
]

{ #category : #constructing }
DialogWindow >> createAcceptButton [

	^ self
		createButton: 'Accept' translated
		value: true
		color: (self userInterfaceTheme okColor ifNil: [Color r: 0.49 g: 0.749 b: 0.49])
]

{ #category : #initialization }
DialogWindow >> createBody [

	| body |
	body := Morph new
		name: 'Body';
		changeTableLayout;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		rubberBandCells: true;
		listDirection: #topToBottom;
		layoutInset: (10@5 corner: 10@10);
		cellGap: 5;
		color: Color transparent;
		yourself.
	body addAllMorphs: {self createMessage: ''. self createPane. self createButtonRow. self createFilter}.
	self addMorphBack: body.
]

{ #category : #constructing }
DialogWindow >> createButton: buttonLabel [

	^ self
		createButton: buttonLabel
		value: self buttonRow submorphs size + 1
		color: self defaultButtonColor
]

{ #category : #constructing }
DialogWindow >> createButton: buttonLabel value: buttonValue [

	^ self
		createButton: buttonLabel
		value: buttonValue
		color: self defaultButtonColor
]

{ #category : #constructing }
DialogWindow >> createButton: buttonLabel value: buttonValue color: buttonColor [

	| button |
	button := PluggableButtonMorphPlus new
		label: buttonLabel ;
		action: [ self closeDialog: buttonValue ] ;
		setProperty: #normalColor toValue: buttonColor ;
		setProperty: #normalLabel toValue: buttonLabel ;
		hResizing: #rigid;
		vResizing: #rigid;
		yourself.
	
	self deselectButton: button.
	buttonRow addMorphBack: button.
	self updateButtonExtent.
	
	^ button
]

{ #category : #initialization }
DialogWindow >> createButtonRow [

	^ buttonRow := Morph new
		name: 'Buttons';
		color: Color transparent;
		changeTableLayout;
		vResizing: #shrinkWrap;
		hResizing: #spaceFill;
		listDirection: #leftToRight;
		listCentering: #center;
		cellGap: 5;
		yourself
]

{ #category : #constructing }
DialogWindow >> createCancelButton [

	^ cancelButton := self
		createButton: 'Cancel' translated
		value: false
		color: (self userInterfaceTheme cancelColor ifNil: [Color r: 1 g: 0.6 b: 0.588])
]

{ #category : #constructing }
DialogWindow >> createCancelButton: label value: result [

	^ cancelButton := self
		createButton: label
		value: result
]

{ #category : #initialization }
DialogWindow >> createFilter [
	"This is an invisible morph that catches keystrokes to filter content in multiple widgets at once. Needs #filterEnabled to be true."
	
	filterMorph := '' asText asMorph lock.
	filterMorph
		name: 'Filter';
		visible: false;
		disableTableLayout: true.
	^ filterMorph
]

{ #category : #initialization }
DialogWindow >> createMessage: aString [ 
	
	messageMorph := aString asText asMorph.
	messageMorph
		name: 'Message';
		readOnly: true;
		setProperty: #indicateKeyboardFocus toValue: #never;
		handlesKeyboardOnlyOnFocus: true. "If user presses enter while only hovering the text, we want to process the stroke to close the dialog."
	self setMessageParameters.	
	^ messageMorph
]

{ #category : #initialization }
DialogWindow >> createPane [

	^ paneMorph := BorderedMorph new
		name: 'Content';
		changeProportionalLayout;
		hResizing: #rigid;
		vResizing: #rigid;
		layoutInset: 0;
		color: Color transparent;
		borderWidth: 0;
		yourself.
]

{ #category : #initialization }
DialogWindow >> createTitle: aString [ 
	"Mimick behavior of MenuMorph title creation."
	
	| box closeButton menuButton |
	box := Morph new
		name: #title;
		changeTableLayout;
		listDirection: #leftToRight;
		yourself.
	
	titleMorph := aString asText asMorph lock.

	closeButton := SystemWindowButton new
		color: Color transparent;
		target: self;
		extent: 12@12;
		actionSelector: #cancelDialog;
		balloonText: 'Cancel this dialog' translated;
		borderWidth: 0;
		visible: self class includeCloseButton;
		yourself.
	SystemWindow closeBoxImage scaleIconToDisplay in: [:icon |
		closeButton labelGraphic: icon; extent: icon extent].

	menuButton := SystemWindowButton new
		color: Color transparent;
		target: self;
		actionSelector: #offerDialogMenu;
		balloonText: 'Dialog menu' translated;
		borderWidth: 0;
		visible: self class includeControlMenu;
		yourself.
	SystemWindow menuBoxImage scaleIconToDisplay in: [:icon |
		menuButton labelGraphic: icon; extent: icon extent].
	
	box addAllMorphs: {closeButton. titleMorph. menuButton}.
	
	self addMorphBack: box.
	self setTitleParameters.
]

{ #category : #running }
DialogWindow >> debugInvocation [

	Processor activeProcess
		debug: self findInvocationContext
		title: 'Dialog invocation'
]

{ #category : #accessing }
DialogWindow >> defaultButtonColor [

	^  self userInterfaceTheme buttonColor ifNil: [(Color r: 0.658 g: 0.678 b: 0.78) twiceLighter]
]

{ #category : #selection }
DialogWindow >> deselectButton: aButton [

	aButton ifNil: [^ self].
	aButton offColor: (aButton valueOfProperty: #normalColor).
	aButton == selectedButton ifTrue: [selectedButton := nil].
]

{ #category : #drawing }
DialogWindow >> drawOverlayOn: aCanvas [

	| title inset |
	super drawOverlayOn: aCanvas.

	title := self submorphs first.

	self wantsRoundedCorners ifTrue: [
		inset := (self class roundedDialogCorners and: [self class gradientDialog])
			"This check compensates a bug in balloon."
			ifTrue: [0@0 corner: 0@ -1] ifFalse: [self borderWidth @ 0].

		"Overdraw lower part of title bar to hide bottom corners."		
		aCanvas
			fillRectangle:( (title bottomLeft - (0 @ self submorphs first cornerRadius) corner: title bottomRight) insetBy: inset)
			color: self color].
		
	"Draw a line between the title and the contents."
	self borderWidth > 0 ifTrue: [			
		"Redraw the border all around. Needed because rounded borders do not align very well."
		self wantsRoundedCorners
			ifTrue: [	aCanvas frameRoundRect: self bounds radius: self cornerRadius width: self borderStyle width color: self borderStyle color]
			ifFalse: [aCanvas frameRectangle: self bounds width: self borderStyle width color: self borderStyle color]].
]

{ #category : #selection }
DialogWindow >> ensureSelectedButton [

	self buttons ifEmpty: [^ self].
	self selectedButton ifNil: [self selectButton: self buttons first].
	self selectedButton enabled ifFalse: [self selectNextButton].
]

{ #category : #accessing }
DialogWindow >> exclusive [

	^ exclusive
]

{ #category : #accessing }
DialogWindow >> exclusive: aBoolean [

	exclusive := aBoolean.
	
	exclusive
		ifTrue: [self activeHand newMouseFocus: self]
		ifFalse: [self activeHand releaseMouseFocus: self].
]

{ #category : #running }
DialogWindow >> exploreInvocation [

	self exclusive: false.
	(self findInvocationContext stack collect: #method)
		explore
]

{ #category : #accessing }
DialogWindow >> filter [
	^ filter ifNil: ['']
]

{ #category : #accessing }
DialogWindow >> filter: aString [
	filter := aString.
	self updateFilter.
]

{ #category : #accessing }
DialogWindow >> filterEnabled [
	^ filterEnabled ifNil: [false]
]

{ #category : #accessing }
DialogWindow >> filterEnabled: aBoolean [

	filterEnabled := aBoolean.
	self updateFilter.
]

{ #category : #running }
DialogWindow >> findInvocationContext [

	| context |
	context := thisContext.
	[context method selector = #getUserResponse and: [context isMethodContext]]
		whileFalse: [context := context sender].
	^ context
]

{ #category : #running }
DialogWindow >> flash [
	"Flash me"
	Beeper beepPrimitive.

	self class useWiggleAnimation ifTrue: [
		#(-2 4 -6 8 -4) do: [:i |
			self left: self left + i.
			self refreshWorld.
		] separatedBy: [(Delay forMilliseconds: 50) wait]
	] ifFalse: [
		1 to: 2 do:[:i|
			self color: Color black.
			self world doOneCycleNow.
			(Delay forMilliseconds: 50) wait.
			self color: Color white.
			self world doOneCycleNow.
			(Delay forMilliseconds: 50) wait] ]
]

{ #category : #running }
DialogWindow >> getUserResponse [

	| hand world |
	self message ifEmpty: [messageMorph delete]. "Do not waste space."
	self paneMorph submorphs
		ifEmpty: ["Do not waste space and avoid strange button-row wraps."
			self paneMorph delete.
			self buttonRowMorph wrapDirection: #none]. 
	
	hand := self currentHand.
	world := self currentWorld.

	self fullBounds.
	self moveToPreferredPosition.
	self openInWorld: world.
	
	hand showTemporaryCursor: nil. "Since we are out of context, reset the cursor."
	
	hand keyboardFocus in: [:priorKeyboardFocus |
		hand mouseFocus in: [:priorMouseFocus |
			self exclusive ifTrue: [hand newMouseFocus: self].
			hand newKeyboardFocus: self.

			[[self isInWorld] whileTrue: [world doOneSubCycle]]
				ifCurtailed: [self cancelDialog].

			hand newKeyboardFocus: priorKeyboardFocus.
			
			self flag: #discuss. "Since 2016 we are having this *ping pong* between (a) restoring the prior mouse focus and (b) just clearing it globally. The former solution makes more sense while the latter fixes issues with some modal dialogs. We have to investigate this further."
			hand releaseMouseFocus.
			"hand newMouseFocus: priorMouseFocus."]].

	^ result
]

{ #category : #running }
DialogWindow >> getUserResponseAfter: seconds [

	timeout := seconds + 1.
	
	self ensureSelectedButton.	
	self step.
	self updateButtonExtent.
	
	^ self getUserResponse
]

{ #category : #running }
DialogWindow >> getUserResponseAtHand [
	"Remove unnecessary widgets."
	self message ifEmpty: [ messageMorph delete ].
	self paneMorph submorphs ifEmpty: [ self paneMorph delete ].
	"Modal dialogs must be as convenient as possible, put default button directly under hand."
	self
		 ensureSelectedButton ;
		 preferredPosition: self selectedButton.
	^ self getUserResponse
]

{ #category : #events }
DialogWindow >> handleMouseDown: event [
	"Always bring me to the front since I am modal"
	
	self comeToFront.
	^ super handleMouseDown: event
]

{ #category : #events }
DialogWindow >> handleMouseUp: event [

	super handleMouseUp: event.
	self exclusive ifTrue: [event hand newMouseFocus: self].
]

{ #category : #events }
DialogWindow >> handlesKeyboard: evt [

	^true
]

{ #category : #events }
DialogWindow >> handlesMouseDown: evt [ 

	^ true
]

{ #category : #initialization }
DialogWindow >> initialExtent [

	^ 200@150
]

{ #category : #initialization }
DialogWindow >> initialize [

	super initialize.
	
	self
		changeTableLayout;
		listDirection: #topToBottom;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		rubberBandCells: true;
		setProperty: #indicateKeyboardFocus toValue: #never.
	
	self createTitle: 'Dialog'.
	self createBody.
	
	self setDefaultParameters.
	
	keyMap := Dictionary new.
	exclusive := true.
	autoCancel := false.
	preferredPosition := self currentWorld center.
]

{ #category : #'dropping\/grabbing' }
DialogWindow >> justDroppedInto: aMorph event: event [

	"Restore drop shadow if necessary."
	self hasDropShadow: Preferences menuAppearance3d.

	self exclusive ifTrue: [
		"aggressively preserve focus"
		event hand newMouseFocus: self].
]

{ #category : #events }
DialogWindow >> keyStroke: evt [
	| char |
	self stopAutoTrigger.
	char := evt keyCharacter.

	char = Character escape ifTrue: [ ^ self cancelDialog ].
	(char = Character cr or: [char = Character enter]) ifTrue: [ ^ self closeDialog ].

	((char = Character arrowLeft or: [char = Character arrowUp])
		or: [ evt shiftPressed and: [ char = Character tab ] ])
			ifTrue: [ ^ self selectPreviousButton ].
	((char = Character arrowRight or: [char = Character arrowDown])
		or: [ char = Character tab ])
			ifTrue: [ ^ self selectNextButton ].
	
	self filterEnabled ifTrue: [
		char = Character backspace ifTrue: [self filter: (self filter ifEmpty: [''] ifNotEmpty: [:f | f allButLast])].
		(char isAlphaNumeric or: [char = Character space])
			ifTrue: [self filter: self filter, char asString]].
	
	keyMap
		at: char asLowercase
		ifPresent: [ : foundButton | foundButton performAction ]
		ifAbsent: [ "do nothing" ].
]

{ #category : #accessing }
DialogWindow >> message [
	^messageMorph contents
]

{ #category : #accessing }
DialogWindow >> message: aStringOrText [

	messageMorph contents: aStringOrText.
	self setMessageParameters.
]

{ #category : #'accessing - ui' }
DialogWindow >> messageMorph [
	^ messageMorph
]

{ #category : #events }
DialogWindow >> mouseDown: event [

	self stopAutoTrigger.
	
	(self containsPoint: event position) ifFalse: [
		^ self autoCancel
			ifTrue: [self cancelDialog]
			ifFalse: [self flash]].
	
	event hand 
		waitForClicksOrDrag: self 
		event: event 
		selectors: { nil. nil. nil. #startDrag: }
		threshold: HandMorph dragThreshold.
]

{ #category : #events }
DialogWindow >> mouseUp: event [
	self stopAutoTrigger.

]

{ #category : #position }
DialogWindow >> moveToHand [

	self moveToHand: self activeHand.
]

{ #category : #position }
DialogWindow >> moveToHand: aHand [ 
	self preferredPosition: aHand position
]

{ #category : #initialization }
DialogWindow >> moveToPreferredPosition [
	self center:
		(preferredPosition isPoint
			ifTrue: [ preferredPosition ]
			ifFalse: [ self center + self currentHand position - preferredPosition center ]).
	self bounds: (self bounds translatedToBeWithin: self currentWorld bounds)
]

{ #category : #running }
DialogWindow >> offerDialogMenu [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu
		add: (exclusive == true ifTrue: ['<yes>'] ifFalse: ['<no>']), 'be modally exclusive' translated
			action: #toggleExclusive;
		addLine;
		add: 'explore dialog invocation' translated
			action: #exploreInvocation;
		add: 'debug dialog invocation' translated
			action: #debugInvocation.
		
	menu popUpEvent: self currentEvent in: self world.
	
	[menu isInWorld] whileTrue: [self world doOneSubCycle].
	self exclusive ifTrue: [self activeHand newMouseFocus: self].
]

{ #category : #'accessing - ui' }
DialogWindow >> paneMorph [
	^ paneMorph
]

{ #category : #initialization }
DialogWindow >> positionOverWidgetNamed: nameSymbol [ 
	self allMorphsDo:
		[ : each | each knownName = nameSymbol ifTrue: [ self preferredPosition: each ] ]
]

{ #category : #position }
DialogWindow >> preferredPosition: aPointOrMorph [
	"Specify that the dialog should be positioned at an absolute Point on the screen, or the particular Morph widget which should be positioned under the hand."
	preferredPosition := aPointOrMorph
]

{ #category : #events }
DialogWindow >> processFocusEvent: evt using: dispatcher [

	^ dispatcher dispatchFocusEventFully: evt with: self
]

{ #category : #constructing }
DialogWindow >> registerKeyboardShortcutFor: button [ 
	"Take the first alpha-numeric character that is not already used as a shortcut, and use it as a shortcut."
	
	(button valueOfProperty: #normalLabel) asString in: [:normalLabel | normalLabel do: [:char |
		char isAlphaNumeric ifTrue: [ keyMap
				at: char asLowercase
				ifPresent: [:ea | "Ignore"]
				ifAbsent: [
					button setProperty: #normalLabel toValue: ('{1} ({2})' format: {normalLabel. char asLowercase}).
					button label: (button valueOfProperty: #normalLabel).
					^ keyMap at: char asLowercase put: button ] ] ] ]
]

{ #category : #constructing }
DialogWindow >> registerKeyboardShortcuts [
	
	self buttons do: [:ea | self registerKeyboardShortcutFor: ea].
]

{ #category : #selection }
DialogWindow >> selectButton: aButton [

	| buttonColor |
	buttonColor :=  ((self userInterfaceTheme selectionModifier ifNil: [ [:c | c muchLighter] ]) value: (aButton valueOfProperty: #normalColor)).
	self deselectButton: selectedButton.
	aButton offColor: buttonColor.
	selectedButton := aButton.
]

{ #category : #selection }
DialogWindow >> selectNextButton [

	self selectedButton ifNil: [^ self].
	(self buttons anySatisfy: [:ea | ea enabled]) ifFalse: [^ self].
	
	self selectedButtonIndex: self selectedButtonIndex \\ self buttons size + 1.
	self selectedButton enabled ifFalse: [self selectNextButton].
]

{ #category : #selection }
DialogWindow >> selectPreviousButton [

	self selectedButton ifNil: [^ self].
	(self buttons anySatisfy: [:ea | ea enabled]) ifFalse: [^ self].
	
	self selectedButtonIndex: self selectedButtonIndex - 2 \\ self buttons size + 1.
	self selectedButton enabled ifFalse: [self selectPreviousButton].
]

{ #category : #accessing }
DialogWindow >> selectedButton [
	^ selectedButton
]

{ #category : #accessing }
DialogWindow >> selectedButton: aButton [

	aButton
		ifNil: [self deselectButton: self selectedButton]
		ifNotNil: [self selectButton: aButton].
]

{ #category : #accessing }
DialogWindow >> selectedButtonIndex [
	
	^ self selectedButton
		ifNil: [0]
		ifNotNil: [:btn | self buttons indexOf: btn]
]

{ #category : #accessing }
DialogWindow >> selectedButtonIndex: anInteger [

	anInteger = 0 ifTrue: [^ self selectedButton: nil].
	self selectedButton: (self buttons at: anInteger).
]

{ #category : #initialization }
DialogWindow >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: (self userInterfaceTheme color ifNil: [Color white]);
		borderStyle: (self userInterfaceTheme borderStyle ifNil: [BorderStyle simple]) copy;
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color gray]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]);
		layoutInset: ((self class roundedDialogCorners and: [self class gradientDialog])
			"This check compensates a bug in balloon."
			ifTrue: [0] ifFalse: [self borderWidth negated asPoint]).

	Preferences menuAppearance3d ifTrue: [self addDropShadow].
]

{ #category : #initialization }
DialogWindow >> setMessageParameters [
	
	messageMorph ifNotNil: [
		| fontToUse colorToUse |
		fontToUse := self userInterfaceTheme font ifNil: [TextStyle defaultFont].
		colorToUse := self userInterfaceTheme textColor ifNil: [Color black].
		
		messageMorph
			hResizing: #shrinkWrap;
			vResizing: #shrinkWrap.
		
		messageMorph contents
			addAttribute: (TextFontReference toFont: fontToUse);
			addAttribute: (TextColor color: colorToUse).
		messageMorph textColor: colorToUse].
]

{ #category : #initialization }
DialogWindow >> setTitleParameters [

	(self submorphNamed: #title) ifNotNil: [:title |
		title
			fillStyle: (self class gradientDialog
				ifFalse: [SolidFillStyle color: (self userInterfaceTheme titleColor ifNil: [Color r: 0.658 g: 0.678 b: 0.78])]
				ifTrue: [self titleGradientFor: title from: (self userInterfaceTheme titleColor ifNil: [Color r: 0.658 g: 0.678 b: 0.78])]);
			borderStyle: (self userInterfaceTheme titleBorderStyle ifNil: [BorderStyle simple]) copy;
			borderColor: (self userInterfaceTheme titleBorderColor ifNil: [Color r: 0.6 g: 0.7 b: 1]);
			borderWidth: (self userInterfaceTheme titleBorderWidth ifNil: [0]);
			cornerStyle: (self wantsRoundedCorners ifTrue: [#rounded] ifFalse: [#square]);
			vResizing: #shrinkWrap;
			hResizing: #spaceFill;
			cellGap: 5;
			layoutInset: (5@3 corner: 5@ (2+(self wantsRoundedCorners ifFalse: [0] ifTrue: [self cornerRadius])))].
	
	titleMorph ifNotNil: [
		| fontToUse colorToUse |
		fontToUse := self userInterfaceTheme titleFont ifNil: [TextStyle defaultFont].
		colorToUse := self userInterfaceTheme titleTextColor ifNil: [Color black].
	
		"Temporary HACK for 64-bit CI build. Can be removed in the future."
		titleMorph contents isText ifFalse: [^ self].
		
		titleMorph
			hResizing: #spaceFill;
			vResizing: #shrinkWrap.
	
		titleMorph contents
			addAttribute: (TextFontReference toFont: fontToUse);
			addAttribute: (TextColor color: colorToUse);
			addAttribute: TextAlignment centered].
]

{ #category : #'dropping\/grabbing' }
DialogWindow >> startDrag: event [

	self hasDropShadow: false.
	event hand grabMorph: self.
]

{ #category : #'stepping and presenter' }
DialogWindow >> step [
	timeout ifNil: [^self].
	timeout = 0
		ifTrue: [
			self stopStepping.
			selectedButton performAction]
		ifFalse: [
			selectedButton label: ('{1} [{2}]' format: {
				selectedButton valueOfProperty: #normalLabel.
				timeout}).
			timeout := timeout - 1]
]

{ #category : #'stepping and presenter' }
DialogWindow >> stepTime [
	^1000
]

{ #category : #'stepping and presenter' }
DialogWindow >> stopAutoTrigger [
	timeout ifNil: [^self].
	timeout := nil.
	self stopStepping.
	selectedButton label: (selectedButton valueOfProperty: #normalLabel). 
]

{ #category : #accessing }
DialogWindow >> title [
	^titleMorph contents
]

{ #category : #accessing }
DialogWindow >> title: aString [

	titleMorph contents: aString asText.
	self setTitleParameters.
]

{ #category : #initialization }
DialogWindow >> titleGradientFor: morph from: aColor [

	| cc gradient |
	cc := aColor.
	gradient := GradientFillStyle ramp: {
		0.0 -> Color white. 
		0.15 ->(cc mixed: 0.5 with: Color white). 
		0.7 -> cc.
	}.
	gradient origin: morph topLeft.
	gradient direction: 0 @ (TextStyle defaultFont height + 10).
	^ gradient
]

{ #category : #running }
DialogWindow >> toggleExclusive [

	self exclusive: self exclusive not.
]

{ #category : #updating }
DialogWindow >> update: aspect [

	aspect == #buttons
		ifTrue: [self updateButtonExtent].
		
	aspect == #flash
		ifTrue: [self flash].
		
	^ super update: aspect
]

{ #category : #updating }
DialogWindow >> updateButtonExtent [
	
	self updateButtonExtent: 20@10.
]

{ #category : #updating }
DialogWindow >> updateButtonExtent: margin [

	"Update all button extents."
	(buttonRow submorphs collect: [:ea | ea minimumExtent]) max + margin in: [:preferredExtent |
		buttonRow submorphsDo: [:ea | ea extent: preferredExtent]].
	
	"See if horizontal button layout would be more appropriate."
	self flag: #magicNumber. "mt: Remove number with computation, maybe choose button font and 20 characters"
	(buttonRow submorphs collect: [:ea | ea fullBounds width]) sum > 400
		ifTrue: [buttonRow
					hResizing: #shrinkWrap;
					listDirection: #topToBottom;
					wrapDirection: #none;
					layoutInset: (buttonRow owner fullBounds width - (buttonRow owner layoutInset left*2) - buttonRow submorphs first fullBounds width // 2@0)]
		ifFalse: [buttonRow
					hResizing: #spaceFill;
					listDirection: #leftToRight;
					wrapDirection: #topToBottom;
					layoutInset: 0].
]

{ #category : #updating }
DialogWindow >> updateFilter [

	self buttons do: [:ea |
		ea enabled: (self filter isEmpty or: [ea label asString includesSubstring: self filter caseSensitive: false])].
	
	filterMorph
		visible: self filter notEmpty;
		disableTableLayout: self filter isEmpty;
		contents: '<', self filter, '>';
		textColor: self messageMorph textColor.
		
	self ensureSelectedButton.
]

{ #category : #rounding }
DialogWindow >> wantsRoundedCorners [

	^ self class roundedDialogCorners or: [super wantsRoundedCorners]
]

{ #category : #'dropping\/grabbing' }
DialogWindow >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph"
	^aMorph isWorldMorph "only into worlds"
]
