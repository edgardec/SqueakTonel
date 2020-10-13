Class {
	#name : #PreferenceWizardMorph,
	#superclass : #Morph,
	#instVars : [
		'previewWorld',
		'titleMorph',
		'buttonRowMorph',
		'controlMorph',
		'startButton',
		'previousButton',
		'nextButton',
		'pages',
		'currentPageIndex',
		'pagesLabel',
		'skipButton',
		'isFullScreen',
		'lowPerformanceMorph',
		'checkmark'
	],
	#category : #PreferenceBrowser
}

{ #category : #'class initialization' }
PreferenceWizardMorph class >> initialize [

	TheWorldMenu registerOpenCommand: {'Preference Wizard'. {self. #open}}. 
]

{ #category : #'instance creation' }
PreferenceWizardMorph class >> open [

	^ PreferenceWizardMorph new openInWorld
]

{ #category : #actions }
PreferenceWizardMorph >> accept [

	self showInstallPage.
]

{ #category : #support }
PreferenceWizardMorph >> adjustSettingsForLowPerformance [

	self updateLowPerformanceLabel: 'Please wait, optimizing performance...' translated.
	self refreshWorld.
	
	self stateGradients "flat look" ifFalse: [self toggleGradients].
	self stateBlinkingCursor ifTrue: [self toggleBlinkingCursor].
	self stateFastDrag ifFalse: [self toggleFastDrag].
	
	self stateSoftShadows ifTrue: [self toggleSoftShadows].
	self stateHardShadows ifTrue: [self toggleHardShadows].
	
	self stateRoundedWindowLook ifTrue: [self toggleRoundedWindowLook].
	self stateRoundedButtonLook ifTrue: [self toggleRoundedButtonLook].
	
	self stateAttachToolsToMouse ifTrue: [self toggleAttachToolsToMouse].
	self stateToolAndMenuIcons ifTrue: [self toggleToolAndMenuIcons].
	
	self stateSmartHorizontalSplitters ifTrue: [self toggleSmartHorizontalSplitters].
	self stateSmartVerticalSplitters ifTrue: [self toggleSmartVerticalSplitters].
	
	PluggableListMorph
		highlightHoveredRow: false;
		filterableLists: false;
		highlightPreSelection: true; "Feedback is important!"
		flashOnErrors: false.
	TheWorldMainDockingBar showSecondsInClock: false.
	Preferences disable: #balloonHelpInMessageLists.
	
	
	"Set simple background."
	Project current world setAsBackground: MorphicProject defaultFill.
	previewWorld fillStyle: Project current world fillStyle.
	
	"Done."
	self updateLowPerformanceLabel: 'Settings were adjusted for optimal performance.' translated.
]

{ #category : #updating }
PreferenceWizardMorph >> changed: aspect [

	super changed: aspect.

	(aspect beginsWith: #state)
		ifTrue: [super changed: ('label', (aspect allButFirst: 5)) asSymbol].
]

{ #category : #updating }
PreferenceWizardMorph >> checkInternetOn: button [

	self isInWorld ifFalse: [^ self].
	(self hasProperty: #checkInternet) ifFalse: [^ self].
	
	self hasInternetConnection
		ifTrue: [button enabled: true; label: 'Yes, install selected packages.' translated]
		ifFalse: [button enabled: false; label: 'Please check your internet connection...' translated].
	
	(self future: 1000) checkInternetOn: button.
]

{ #category : #initialization }
PreferenceWizardMorph >> checkmark [

	^ checkmark ifNil: [checkmark := (((ToolIcons iconNamed: #checkmark) dyed: Color white) scaledToSize: 20@20) asMorph]
]

{ #category : #support }
PreferenceWizardMorph >> chooseTheme: aTheme [

	aTheme apply.

	"The theme does not theme this fake world."
	previewWorld fillStyle: self world fillStyle.
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createButton [

	^ PluggableButtonMorphPlus new
		setProperty: #noUserInterfaceTheme toValue: true;
		offColor: (self defaultColor adjustBrightness: 0.2);
		feedbackColor: (self defaultColor adjustBrightness: 0.4);
		model: self;
		font: (StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 12);
		textColor: self defaultTextColor;
		borderColor: self defaultTextColor;
		instVarNamed: #borderColor put: self defaultTextColor; "HACK!"
		borderWidth: 2;
		cornerStyle: (self hasLowPerformance ifTrue: [#square] ifFalse: [#rounded]);
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		layoutInset: (20@10 corner: 20@10);
		yourself
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createCheckbox: label for: selector [

	^ self
		createCheckbox: label
		for: selector
		help: #()
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createCheckbox: label for: selector help: terms [

	| box lbl btn |
	
	btn := self createButton
		layoutInset: 0;
		label: ' ';
		onColor: (self defaultColor adjustBrightness: 0.3) offColor: (self defaultColor adjustBrightness: 0.3);
		vResizing: #rigid;
		hResizing: #rigid;
		action: ('toggle', selector) asSymbol;
		getStateSelector: ('state', selector) asSymbol;
		getLabelSelector: ('label', selector) asSymbol;
		extent: 25@25.

	lbl := self createLabel: label color: self defaultTextColor.
	lbl hResizing: #spaceFill.
	
	box := Morph new
		color: Color transparent;
		changeTableLayout;
		listDirection: #leftToRight;
		cellPositioning: #topLeft;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		rubberBandCells: true;
		cellGap: 10;
		yourself.
		
	box addAllMorphs: {btn. lbl}.
	self
		setBalloonText: (terms isString ifTrue: [terms] ifFalse: [self findHelpStringFor: terms])
		for: box.
	^ box
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createHorizontalSpacer [

	^ Morph new
		color: Color transparent;
		hResizing: #spaceFill;
		extent: 5@5;
		yourself
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createLabel: aString [

	^ self createLabel: aString color: (self defaultTextColor adjustBrightness: -0.1)
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createLabel: aString color: aColor [

	^ self createLabel: aString color: aColor pointSize: 12
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createLabel: aString color: aColor pointSize: size [

	| lbl |
	lbl := TextMorph new hResizing: #spaceFill; vResizing: #shrinkWrap.
	lbl newContents:aString.
	lbl text
		addAttribute: (TextColor color: aColor);
		addAttribute: (TextFontReference toFont: ((StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: size))).
	lbl lock.
	^ lbl
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createPage [

	^ Morph new
		color: Color transparent;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		changeTableLayout;
		listDirection: #topToBottom;
		cellPositioning: #topLeft;
		layoutInset: (20@20 corner: 10@0);
		cellGap: 10;
		yourself
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createScrollPane [

	| pane |
	pane := ScrollPane new
		setProperty: #noUserInterfaceTheme toValue: true;
		hScrollBarPolicy: #never;
		vScrollBarPolicy: #whenNeeded;
		borderWidth: 0;
		color: Color transparent;
		scrollBarThickness: 20;
		yourself.
		
	pane
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	
	pane scroller changeTableLayout.
	pane scroller addMorph: (Morph new
		changeTableLayout;
		color: Color transparent;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		cellGap: 10;
		layoutInset: (0@0 corner: 10@0);
		yourself).
	
	pane vScrollBar
		setProperty: #noUserInterfaceTheme toValue: true;
		sliderColor: Color white.
	(pane vScrollBar instVarNamed: #slider) 
		cornerStyle: (self hasLowPerformance ifTrue: [#square] ifFalse: [#rounded]);
		borderWidth: 2.
	(pane vScrollBar instVarNamed: #pagingArea) 
		cornerStyle: (self hasLowPerformance ifTrue: [#square] ifFalse: [#rounded]).	
			
	^ pane
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createVerticalSpace [

	^ Morph new
		color: Color transparent;
		vResizing: #rigid;
		extent: 5@5;
		yourself
]

{ #category : #'initialization - building' }
PreferenceWizardMorph >> createVerticalSpacer [

	^ Morph new
		color: Color transparent;
		vResizing: #spaceFill;
		extent: 5@5;
		yourself
]

{ #category : #initialization }
PreferenceWizardMorph >> defaultColor [

	^ Color black
]

{ #category : #initialization }
PreferenceWizardMorph >> defaultTextColor [

	^ Color white
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> doesNotUnderstand: msg [

	(msg selector numArgs = 0 and: [msg selector beginsWith: 'label'])
		ifTrue: [^ (self perform: ('state', (msg selector allButFirst: 5)) asSymbol)
			ifTrue: [self checkmark]
			ifFalse: [' '] ].
		
	^ super doesNotUnderstand: msg
]

{ #category : #'event handling' }
PreferenceWizardMorph >> filterEvent: aKeyboardEvent for: aMorph [

	aKeyboardEvent isKeystroke ifTrue: [
		aKeyboardEvent keyCharacter = Character escape
			ifTrue: [self showSqueak. ^ aKeyboardEvent ignore].
		(aKeyboardEvent keyCharacter = Character cr and: [self isInWelcome])
			ifTrue: [self showPlayfield. ^ aKeyboardEvent ignore].
		].

	^ aKeyboardEvent
]

{ #category : #support }
PreferenceWizardMorph >> findHelpStringFor: someTerms [

	someTerms ifEmpty: [^ ''].
	
	^ Preferences allPreferences
		detect:[:pref | someTerms allSatisfy: [:term| pref name includesSubstring: term caseSensitive: false]]
		ifFound: [:pref | (pref helpString lines joinSeparatedBy: ' ') withBlanksTrimmed]
		ifNone: ['']
]

{ #category : #'event handling' }
PreferenceWizardMorph >> handlesMouseDown: evt [
	^ true
]

{ #category : #testing }
PreferenceWizardMorph >> hasInternetConnection [

	^ [TestCase new ensureSecureInternetConnection. true]
		on: Error do: [false]
]

{ #category : #testing }
PreferenceWizardMorph >> hasLowPerformance [
	"If the wizard is started on a machine with low performance, the wizard will change some settings automatically on startup."
	
	^ Smalltalk isLowerPerformance
]

{ #category : #initialization }
PreferenceWizardMorph >> initialize [

	super initialize.
	
	isFullScreen := false.

	self hasLowPerformance
		ifTrue: [self color: self defaultColor]
		ifFalse: [self color: (self defaultColor alpha: 0.75)].
		
	self setProperty: #indicateKeyboardFocus toValue: #never.
	
	Preferences enable: #systemWindowEmbedOK.
	
	titleMorph := ('Welcome to Squeak' translated asText
		addAttribute: (TextColor color: self defaultTextColor);
		addAttribute: (TextFontReference toFont: (StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 20));
		yourself) asMorph lock.
	titleMorph margins: (10@0 corner: 10@10).
	titleMorph layoutFrame: (LayoutFrame fractions: (0 @ 0 corner: 1 @ 0) offsets: (0@ 0 corner: 0 @ titleMorph height)).
	
	self
		initializePages;
		initializeButtons;
		initializeControlMorph;
		initializePreviewWorld;
		initializeForLowPerformance.

	self
		changeProportionalLayout;
		layoutInset: 20;
		cellGap: 10;
		cellPositioning: #center;
		addAllMorphs: {titleMorph. buttonRowMorph. controlMorph. previewWorld. startButton. skipButton. lowPerformanceMorph}.
		
	self addKeyboardCaptureFilter: self.
]

{ #category : #initialization }
PreferenceWizardMorph >> initializeButtons [

	buttonRowMorph := Morph new
		color: Color transparent;
		changeTableLayout;
		listDirection: #leftToRight;
		cellGap: 10;
		layoutInset: (0@20 corner: 0@0);
		vResizing: #shrinkWrap;
		hResizing: #spaceFill;
		yourself.
		
	buttonRowMorph addAllMorphs: {
		previousButton := self createButton action: #previous; label: 'Previous' translated.
		pagesLabel := (self createLabel: '0 / 0') hResizing: #shrinkWrap; margins: (20@0 corner: 20@0); fullBounds; yourself.
		nextButton := self createButton action: #next; label: 'Next' translated.
		self createHorizontalSpacer.
		self createButton action: #accept; label: 'Done' translated}.
	
	
	buttonRowMorph fullBounds.
	buttonRowMorph layoutFrame: (LayoutFrame fractions: (0 @ 1 corner: 1 @ 1) offsets: (0@ buttonRowMorph height negated corner: 0 @ 0)).
	
	
	
	startButton := (self createButton action: #showPlayfield; label: 'Configure' translated).
	skipButton := (self createButton action: #showSqueak; label: 'Skip' translated).
	
	(startButton width max: skipButton width) in: [:w |
		startButton hResizing: #rigid; width: w.
		skipButton hResizing: #rigid; width: w.
		
		startButton layoutFrame: (LayoutFrame fractions: (0.5 @ 0.6 corner: 0.5 @ 0.6) offsets: (2*w negated @ 0 corner: 0 @ 0)).
		skipButton layoutFrame: (LayoutFrame fractions: (0.5 @ 0.6 corner: 0.5 @ 0.6) offsets: (0@ 0 corner: 2*w @ 0))].
]

{ #category : #initialization }
PreferenceWizardMorph >> initializeControlMorph [

	controlMorph := Morph new
		color: Color transparent;
		changeTableLayout;
		listDirection: #topToBottom;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutInset: (0@0 corner: 10@0);
		layoutFrame: (LayoutFrame fractions: (0.0 @ 0 corner: 0.3 @ 1.0) offsets: (0@ titleMorph height corner: 0 @ buttonRowMorph height negated));
		yourself.
	
	controlMorph addMorph: (self createLabel: 'Please take a few minutes and configure the look-and-feel of the environment. You can always adjust these settings later. You can see the effects of these settings in the live and editable windows to the right.' translated).
]

{ #category : #initialization }
PreferenceWizardMorph >> initializeForLowPerformance [
	
	lowPerformanceMorph := TextMorph new lock.
]

{ #category : #'initialization - pages' }
PreferenceWizardMorph >> initializePage01Themes [

	| currentPage pane |
	currentPage := pages add: self createPage.
	pane := self createScrollPane.
	
	currentPage addMorphBack: (self createLabel: 'Choose a theme:' color: Color white).
	currentPage addMorphBack: pane.
	
	((UserInterfaceTheme allThemes
		reject: [:uit | uit name beginsWith: 'Demo'])
		sorted: [:a :b | a name <= b name])
			do: [:ea |
			pane scroller firstSubmorph addMorphBack: (self createButton
				label: ea name;
				hResizing: #spaceFill;
				action: #chooseTheme:;
				arguments: {ea})].


]

{ #category : #'initialization - pages' }
PreferenceWizardMorph >> initializePage02Visuals [

	| currentPage pane |
	currentPage := pages add: self createPage.
	pane := self createScrollPane.
	
	currentPage addMorphBack: (self createLabel: 'Choose visual settings' color: Color white).
	currentPage addMorphBack: pane.
	
	pane scroller firstSubmorph addAllMorphsBack: {
		self createCheckbox: 'Colorful windows' translated for: #UseColorfulWindows help: #(color window).
		self createCheckbox: 'Flat widget look' translated for: #Gradients help: 'Whether to use gradients or not.' translated.
		self createVerticalSpace.
		self createCheckbox: 'Rounded windows' translated for: #RoundedWindowLook help: #(round window).
		self createCheckbox: 'Rounded buttons' translated for: #RoundedButtonLook help: #(round button).
		self createVerticalSpace.
		self createCheckbox: 'Soft shadows' translated for: #SoftShadows help: #(soft shadow).
		self createCheckbox: 'Hard shadows' translated for: #HardShadows help: 'Whether to use a hard shadow for windows, menus, and dialogs.' translated.
		self createVerticalSpace.
		self createCheckbox: 'Fast drag and resize' translated for: #FastDrag help: #(fast drag).
		self createCheckbox: 'Blinking text cursor' translated for: #BlinkingCursor help: #(blinking cursor).
		self createCheckbox: 'Show keyboard focus' translated for: #ShowKeyboardFocus help: #(keyboard indicate).		
		self createCheckbox: 'Simple edit indication' translated for: #SimpleFrameAdornments help: #(adornment simple).		
		}.
]

{ #category : #'initialization - pages' }
PreferenceWizardMorph >> initializePage02bVisualsMore [

	| currentPage pane |
	currentPage := pages add: self createPage.
	pane := self createScrollPane.
	
	currentPage addMorphBack: (self createLabel: 'Choose more visual settings' color: Color white).
	currentPage addMorphBack: pane.
	
	pane scroller firstSubmorph addAllMorphsBack: {
		self createCheckbox: 'Bigger Fonts' translated for: #UseBiggerFonts help: 'For high-DPI displays, bigger fonts can improve readability.'.
		self createCheckbox: 'Bigger Cursors' translated for: #UseBiggerCursors help: #(bigger cursor).
		}.
]

{ #category : #'initialization - pages' }
PreferenceWizardMorph >> initializePage03Interaction [

	| currentPage pane |
	currentPage := pages add: self createPage.
	pane := self createScrollPane.
	
	currentPage addMorphBack: (self createLabel: 'Choose interaction settings' color: Color white).
	currentPage addMorphBack: pane.
	
	pane scroller firstSubmorph addAllMorphsBack: {
		self createCheckbox: 'Swap mouse buttons' translated for: #SwapMouseButtons help: #(swap mouse).
		self createCheckbox: 'Focus follows mouse' translated for: #FocusFollowsMouse help: #(mouse over keyboard).
		self createCheckbox: 'Mouse wheel to focus' translated for: #SendMouseWheelToKeyboardFocus help: #(wheel keyboard).
		self createVerticalSpace.
		self createCheckbox: 'Auto enclose brackets' translated for: #AutoEnclose help: #(auto enclose).
		self createCheckbox: 'Auto indent lines' translated for: #AutoIndent help: #(auto indent).
		self createCheckbox: 'Enclose text selections' translated for: #EncloseSelection help: #(enclose selection).
		self createVerticalSpace.
		self createCheckbox: 'Arrows in scrollbar' translated for: #ScrollBarsWithoutArrowButtons help: 'Whether to show arrows for scrolling or not.' translated.
		self createCheckbox: 'Menu in scrollbar' translated for: #ScrollBarsWithoutMenuButton help: 'Whether to show a menu button or not.' translated.
		self createCheckbox: 'Scrollbars on the right' translated for: #ScrollBarsOnRight help: #(right scroll).
		self createCheckbox: 'Retractable scrollbars' translated for: #UseRetractableScrollBars help: #(retractable).
		self createCheckbox: 'Narrow scrollbars' translated for: #ScrollBarsNarrow help: #(narrow scroll).
		
		}.
]

{ #category : #'initialization - pages' }
PreferenceWizardMorph >> initializePage04InteractionMore [

	| currentPage pane |
	currentPage := pages add: self createPage.
	pane := self createScrollPane.
	
	currentPage addMorphBack: (self createLabel: 'Choose more interaction settings' color: Color white).
	currentPage addMorphBack: pane.
	
	pane scroller firstSubmorph addAllMorphsBack: {
		self createCheckbox: 'Windows raise on click' translated for: #WindowsRaiseOnClick help: #(window raise).
		self createCheckbox: 'Windows always active' for: #WindowsAlwaysActive help: #(window content active).
		self createCheckbox: 'Window buttons always active' translated for: #WindowButtonsAlwaysActive help: #(window control active).
		self createVerticalSpace.
		self createCheckbox: 'Smart horizontal splitters' translated for: #SmartHorizontalSplitters help: #(horizontal splitter).
		self createCheckbox: 'Smart vertical splitters' translated for: #SmartVerticalSplitters help: #(vertical splitter).
		self createVerticalSpace.
		self createCheckbox: 'Filterable lists and trees' translated for: #FilterableLists help: 'Type something to filter lists. Press [return] to clear the filter. Press [backspace] to clear and restore prior selection.' translated.
		self createCheckbox: 'Filters clear if unfocused' translated for: #ClearFilterAutomatically help: #(filter clear).
		self createVerticalSpace.
		self createCheckbox: 'Attach tools to mouse' translated for: #AttachToolsToMouse help: #(tools attach).		
		}.
]

{ #category : #'initialization - pages' }
PreferenceWizardMorph >> initializePage05Tools [

	| currentPage pane |
	currentPage := pages add: self createPage.
	pane := self createScrollPane.
	
	currentPage addMorphBack: (self createLabel: 'Choose other settings' color: Color white).
	currentPage addMorphBack: pane.
	
	pane scroller firstSubmorph addAllMorphsBack: {
		self createCheckbox: 'Trace messages browser' translated for: #TraceMessages help: #(trace message).
		self createCheckbox: 'Reuse tool windows' translated for: #ReuseWindows help: #(window reuse).
		self createCheckbox: 'Tool and menu icons' translated for: #ToolAndMenuIcons help: 'Whether to show icons in tools and menus.' translated.
		self createCheckbox: 'Browse class hierarchy' translated for: #AlternativeBrowseIt help: 'Whether to spawn a hierarchy browser or full system browser on browse-it commands.' translated.
		}.

]

{ #category : #'initialization - pages' }
PreferenceWizardMorph >> initializePage99ExtraPackages [
	"Let the user install extra packages."

	| currentPage packagesList installButton |
	currentPage := self createPage.
	currentPage
		cellPositioning: #topCenter;
		layoutInset: (150@40 corner: 150@20);
		addMorphBack: self createHorizontalSpacer;
		addMorphBack: ((self createLabel: 'Do you want to install extra packages?' color: Color white)
			hResizing: #shrinkWrap;
			yourself);
		addMorphBack: ((self createLabel: 'Note that the installation process requires an internet connection and may take several minutes.' color: (Color gray: 0.9))
			hResizing: #rigid;
			vResizing: #shrinkWrap;
			width: 450;
			yourself).
	
	currentPage submorphs last text addAttribute: TextAlignment centered.
	currentPage submorphs last layoutChanged.
	
	currentPage addMorphBack: (self createVerticalSpace height: 20).
	
	packagesList := self createScrollPane.
	packagesList
		width: 350;
		hResizing: #rigid;
		vResizing: #spaceFill.

	packagesList scroller firstSubmorph addAllMorphsBack: {
		self createCheckbox: 'Latest system updates' translated for: #InstallLatestUpdates help: 'Install the latest patches for ' translated, SystemVersion current version.
		self createCheckbox: 'Refactoring support in code browsers' translated for: #InstallRefactoringTools help: 'Refactoring is a process of re-writing or re-organizing text or code. The purpose of a refactor is to make the code or text more understandable and readable while exactly preserving its meaning and behavior.' translated.
		self createCheckbox: 'Autocomplete in code editors' translated for: #InstallAutoComplete help: 'Package that provides interactive, context-sensitive auto-completion for Squeak.' translated.
		self createCheckbox: 'Git support and browser' translated for: #InstallGitInfrastructure help: 'From the Git Browser, you can create new commits, synchronize with remote repositories (fetch, pull, push), manage and merge branches, switch between them, and compare different versions.' translated.
		self createCheckbox: 'Foreign function interface (FFI)' translated for: #InstallFFI help: 'FFI, the Squeak Foreign Function Interface, is used to call functions located in shared libraries that are not part of the Squeak VM nor its plugins' translated.
		self createCheckbox: 'Access OS functions' translated for: #InstallOSProcess help: 'OSProcess provides access to operating system functions, including pipes and child process creation.' translated.
	}.
		
	currentPage addMorphBack: packagesList.

	currentPage addMorphBack: ((self createLabel: 'Find more on www.squeak.org/projects' color: (Color gray: 0.9))
		hResizing: #shrinkWrap; yourself).
	
	installButton := (self createButton action: #installExtraPackages).
	currentPage addMorphBack: installButton.
	currentPage addMorphBack: (self createButton action: #showSqueak; label: 'No, maybe later.' translated).
	
	self setProperty: #checkInternet toValue: true.
	self checkInternetOn: installButton.
	
	^ currentPage
]

{ #category : #initialization }
PreferenceWizardMorph >> initializePages [

	pages := OrderedCollection new.
	currentPageIndex := 0.

	self
		initializePage01Themes;
		initializePage02Visuals;
		initializePage02bVisualsMore;
		initializePage03Interaction;
		initializePage04InteractionMore;
		initializePage05Tools.
]

{ #category : #initialization }
PreferenceWizardMorph >> initializePreviewWorld [

	| w1 w2 w3 |

	previewWorld := PasteUpMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		viewBox: (0@0 corner: 500@500);
		layoutFrame: (LayoutFrame fractions: (0.3 @ 0 corner: 1.0 @ 1.0) offsets: (0@ titleMorph height corner: 0 @ buttonRowMorph height negated));
		fillStyle: Project current world fillStyle;
		borderWidth: 2;
		borderColor: Color white;
		cornerStyle: (self hasLowPerformance ifTrue: [#square] ifFalse: [#rounded]);
		yourself.
	
	w1 := (ToolSet browse: Morph selector: #drawOn:) dependents detect: [:ea | ea isSystemWindow].
	w2 := ToolSet browseMessageSet: (SystemNavigation default allCallsOn: #negated) name: 'Senders' translated autoSelect: 'negated'.
	w3 := (Workspace new contents: '3+4 "Select and hit [CMD]+[P]."') openLabel: 'Workspace'.
	
	{w1. w2. w3} do: [:ea | 
		ea makeUnclosable.
		previewWorld addMorph: ea].
	
	self updateWindowBounds.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> installAutoComplete [

	Metacello new
		configuration: 'OCompletion';
		load.
]

{ #category : #actions }
PreferenceWizardMorph >> installExtraPackages [
	"Removes the buttons and adds the progress bar during installation."
	
	| steps page |
	self removeProperty: #checkInternet. "No frequent checks for connectivity from here."
	
	steps := #(
		InstallLatestUpdates
		InstallMetacello
		InstallRefactoringTools
		InstallAutoComplete
		InstallGitInfrastructure
		InstallFFI
		InstallOSProcess )
			select: [:ea | self perform: ('state', ea) asSymbol].
	
	page := controlMorph firstSubmorph.

	page submorphs second hide. "question"
	page submorphs last delete. "url"
	page submorphs last delete. "no button"
	page submorphs last delete. "yes button"
	page submorphs last delete. "package list"
	
	self refreshWorld.
	
	[
		PreferenceWizardProgressMorph install.
		page
			addMorphBack: PreferenceWizardProgressMorph uniqueInstance;
			addMorphBack: self createVerticalSpacer.
			
		steps
			do: [:step | self perform: step withFirstCharacterDownshifted asSymbol]
			displayingProgress: [:step | String streamContents: [:s |
				step findFeatureIndicesDo: [:start :end |
					s nextPutAll: (step copyFrom: start to: end); space].
				s nextPutAll: '...']].
	] ensure: [
		PreferenceWizardProgressMorph reset.
		self showSqueak].
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> installFFI [

	Metacello new
		configuration: 'FFI';
		load.
"
	(Installer squeak)
		project: 'FFI';
		install: 'FFI-Pools';
		install: 'FFI-Kernel';
		install: 'FFI-Tools';
		install: 'FFI-Tests';
		install: 'FFI-PoolsTests'.
"
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> installGitInfrastructure [

	Installer installGitInfrastructure.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> installLatestUpdates [

	MCConfiguration ensureOpenTranscript: false.
	[MCMcmUpdater default doUpdate: false]
		ensure: [MCConfiguration ensureOpenTranscript: true].
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> installMetacello [

	Installer ensureRecentMetacello.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> installOSProcess [

	Installer ss project: 'OSProcess'; install: 'OSProcess'.
	Installer ss project: 'CommandShell'; install: 'CommandShell'.

]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> installRefactoringTools [

	Metacello new
		configuration: 'RefactoringTools';
		version: '2.0';
		load.
]

{ #category : #testing }
PreferenceWizardMorph >> isInPlayfield [

	^ previewWorld visible
]

{ #category : #testing }
PreferenceWizardMorph >> isInWelcome [

	^ startButton visible
]

{ #category : #layout }
PreferenceWizardMorph >> morphicLayerNumber [

	^ 1
]

{ #category : #'event handling' }
PreferenceWizardMorph >> mouseDown: evt [

	(self containsPoint: evt position)
		ifFalse: [^ self delete].
]

{ #category : #'event handling' }
PreferenceWizardMorph >> mouseUp: evt [

	evt hand newMouseFocus: self.
]

{ #category : #actions }
PreferenceWizardMorph >> next [

	currentPageIndex := currentPageIndex + 1 min: pages size.

	nextButton enabled: currentPageIndex < pages size.
	previousButton enabled: currentPageIndex > 1.
	
	self updatePageLabel.
	
	"Remove current page."
	controlMorph submorphs size > 1 ifTrue: [controlMorph submorphs last delete].
	
	"Add new page."
	controlMorph addMorphBack: (pages at: currentPageIndex).
	self fullBounds.
	(pages at: currentPageIndex) layoutChanged.
]

{ #category : #initialization }
PreferenceWizardMorph >> openInWorld [

	super openInWorld.
	
	self step.
	
	self world activeHand
		newKeyboardFocus: self;
		newMouseFocus: self.
		
	self showWelcome.
]

{ #category : #actions }
PreferenceWizardMorph >> previous [

	currentPageIndex := currentPageIndex - 1 max: 1.
	nextButton enabled: currentPageIndex < pages size.
	previousButton enabled: currentPageIndex > 1.

	self updatePageLabel.
	
	"Remove current page."
	controlMorph submorphs last delete.
	
	"Add new page."
	controlMorph addMorphBack: (pages at: currentPageIndex).
]

{ #category : #'event handling' }
PreferenceWizardMorph >> processFocusEvent: evt using: dispatcher [

	^ dispatcher dispatchFocusEventFully: evt with: self
]

{ #category : #updating }
PreferenceWizardMorph >> refreshWorld [

	self world layoutChanged. "To be really sure to update docking bars..."
	self world fullBounds. "Avoid flickering..."
	self world doOneCycle.
]

{ #category : #support }
PreferenceWizardMorph >> setBalloonText: string for: morph [

	morph
		balloonColor: ((self defaultColor alpha: self color alpha) adjustBrightness: 0.2);
		balloonText: (string asText
			addAttribute: (TextFontReference toFont: (StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9));
			addAttribute: (TextColor color: Color banana)).
]

{ #category : #actions }
PreferenceWizardMorph >> showInstallPage [

	buttonRowMorph delete.
	previewWorld delete.

	"self refreshWorld."

	controlMorph
		removeAllMorphs;
		layoutInset: 0;
		layoutFrame: (LayoutFrame fractions: (0.0 @ 0 corner: 1.0 @ 1.0) offsets: (0@ titleMorph height corner: 0 @ 0));
		addMorphBack: self initializePage99ExtraPackages.

	"self refreshWorld."
]

{ #category : #actions }
PreferenceWizardMorph >> showPlayfield [

	startButton hide.
	skipButton hide.
	lowPerformanceMorph hide.
	isFullScreen := true.
	self step.
	
	titleMorph layoutFrame: (LayoutFrame fractions: (0 @ 0 corner: 1 @ 0) offsets: (0@ 0 corner: 0 @ titleMorph height)).
	
	self refreshWorld.
	500 milliSeconds wait.

	controlMorph show.
	previewWorld show.
	buttonRowMorph show.

	self next.
	self refreshWorld.
	
	
]

{ #category : #actions }
PreferenceWizardMorph >> showSqueak [

	self removeProperty: #checkInternet.
	self isInWelcome ifTrue: [^ self delete].
	
	buttonRowMorph hide.
	controlMorph hide.
	previewWorld hide.

	self refreshWorld.
	500 milliSeconds wait.

	titleMorph layoutFrame: (LayoutFrame fractions: (0 @ 0 corner: 1 @ 1)).
	
	self refreshWorld.
	500 milliSeconds wait.
	
	self delete.
]

{ #category : #actions }
PreferenceWizardMorph >> showWelcome [

	titleMorph layoutFrame: (LayoutFrame fractions: (0 @ 0 corner: 1 @ 0.65) offsets: (0 @0 corner: 0@0)).
	isFullScreen := false.
	self height: titleMorph fullBounds height * 4.
		
	controlMorph hide.
	previewWorld hide.
	buttonRowMorph hide.
	
	titleMorph show.
	startButton show.
	skipButton show.
	self hasLowPerformance
		ifFalse: [lowPerformanceMorph hide]
		ifTrue: [lowPerformanceMorph show].

	self hasLowPerformance
		ifTrue: [Cursor wait showWhile: [self adjustSettingsForLowPerformance]].

	self refreshWorld.
	
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateAlternativeBrowseIt [

	^ Preferences valueOfFlag: #alternativeBrowseIt ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateAttachToolsToMouse [

	^ Project uiManager openToolsAttachedToMouseCursor
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateAutoEnclose [

	^ TextEditor autoEnclose
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateAutoIndent [

	^ TextEditor autoIndent
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateBlinkingCursor [

	^ TextEditor blinkingCursor
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateClearFilterAutomatically [

	^ PluggableListMorph clearFilterAutomatically
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateEncloseSelection [

	^ TextEditor encloseSelection
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateFastDrag [

	^ Preferences valueOfFlag: #fastDragWindowForMorphic ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateFilterableLists [

	^ PluggableListMorph filterableLists
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateFocusFollowsMouse [

	^ Preferences valueOfFlag: #mouseOverForKeyboardFocus ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateGradients [

	^ SystemWindow gradientWindow not
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateHardShadows [

	^ (Preferences valueOfFlag: #menuAppearance3d ifAbsent: [false]) and: [Morph useSoftDropShadow not]
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> stateInstallAutoComplete [

	^ self
		valueOfProperty: #InstallAutoComplete
		ifAbsent: [false]

]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> stateInstallFFI [

	^ self
		valueOfProperty: #InstallFFI
		ifAbsent: [false]
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> stateInstallGitInfrastructure [

	^ self
		valueOfProperty: #InstallGitInfrastructure
		ifAbsent: [false]
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> stateInstallLatestUpdates [

	^ self
		valueOfProperty: #InstallLatestUpdates
		ifAbsent: [true]

]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> stateInstallMetacello [

	^ #(
		InstallRefactoringTools
		InstallAutoComplete
		InstallGitInfrastructure
		InstallFFI
		InstallOSProcess )
			anySatisfy: [:ea | self perform: ('state', ea) asSymbol]
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> stateInstallOSProcess [

	^ self
		valueOfProperty: #InstallOSProcess
		ifAbsent: [false]
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> stateInstallRefactoringTools [

	^ self
		valueOfProperty: #InstallRefactoringTools
		ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateReuseWindows [

	^ SystemWindow reuseWindows
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateRoundedButtonLook [

	^ PluggableButtonMorph roundedButtonCorners
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateRoundedWindowLook [

	^ SystemWindow roundedWindowCorners
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateScrollBarsNarrow [

	^ Preferences valueOfPreference: #scrollBarsNarrow ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateScrollBarsOnRight [

	^ Preferences valueOfFlag: #scrollBarsOnRight ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateScrollBarsWithoutArrowButtons [

	^ ScrollBar scrollBarsWithoutArrowButtons not
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateScrollBarsWithoutMenuButton [

	^ ScrollBar scrollBarsWithoutMenuButton not
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateSendMouseWheelToKeyboardFocus [

	^ HandMorph sendMouseWheelToKeyboardFocus
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateShowKeyboardFocus [

	^ Morph indicateKeyboardFocus
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateSimpleFrameAdornments [

	^ PluggableTextMorph simpleFrameAdornments
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateSmartHorizontalSplitters [

	^ ProportionalSplitterMorph smartHorizontalSplitters
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateSmartVerticalSplitters [

	^ ProportionalSplitterMorph smartVerticalSplitters
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateSoftShadows [

	^ (Preferences valueOfFlag: #menuAppearance3d ifAbsent: [false]) and: [Morph useSoftDropShadow]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateSwapMouseButtons [

	^ Preferences valueOfFlag: #swapMouseButtons ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateToolAndMenuIcons [

	^ Browser showClassIcons
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateTraceMessages [

	^ Preferences valueOfFlag: #traceMessages ifAbsent: [false]
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateUseBiggerCursors [

	^ Cursor useBiggerCursors
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateUseBiggerFonts [

	^ UserInterfaceTheme current name beginsWith: 'Demo'
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateUseColorfulWindows [

	^ Model useColorfulWindows
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateUseRetractableScrollBars [

	^ ScrollPane useRetractableScrollBars
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateWindowButtonsAlwaysActive [

	^ SystemWindow windowTitleActiveOnFirstClick
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateWindowsAlwaysActive [

	^ Model windowActiveOnFirstClick
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> stateWindowsRaiseOnClick [

	^ SystemWindow windowsRaiseOnClick
]

{ #category : #stepping }
PreferenceWizardMorph >> step [

	| oldWidth oldBounds |
	"self comeToFront."

	isFullScreen == true
		ifTrue: [
			oldBounds := self bounds.
			self bounds: self world bounds.
			self bounds = oldBounds ifFalse: [
				self updateWindowBounds]]
		ifFalse: [
			oldWidth := self width.
			self width: self world width.
			self center: self world center.
			self width = oldWidth ifFalse: [
				self updateWindowBounds]].
]

{ #category : #stepping }
PreferenceWizardMorph >> stepTime [
	^ 1000
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleAlternativeBrowseIt [

	Preferences toggle: #alternativeBrowseIt.
	self changed: #stateAlternativeBrowseIt.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleAttachToolsToMouse [

	Project uiManager openToolsAttachedToMouseCursor: Project uiManager openToolsAttachedToMouseCursor not.
	self changed: #stateAttachToolsToMouse.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleAutoEnclose [

	TextEditor autoEnclose: TextEditor autoEnclose not.	
	self changed: #stateAutoEnclose.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleAutoIndent [

	TextEditor autoIndent: TextEditor autoIndent not.	
	self changed: #stateAutoIndent.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleBlinkingCursor [

	TextEditor blinkingCursor: TextEditor blinkingCursor not.
	
	TextMorph allSubInstancesDo: [:ea |
		ea stopBlinking.
		ea hasFocus ifTrue: [
			Editor blinkingCursor
				ifTrue: [ea startBlinking]
				ifFalse: [ea resetBlinkCursor "ensure caret visible"]]].
	
	self changed: #stateBlinkingCursor.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleClearFilterAutomatically [

	PluggableListMorph clearFilterAutomatically: PluggableListMorph clearFilterAutomatically not.
	self changed: #stateClearFilterAutomatically.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleEncloseSelection [

	TextEditor encloseSelection: TextEditor encloseSelection not.	
	self changed: #stateEncloseSelection.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleFastDrag [

	Preferences toggle: #fastDragWindowForMorphic.
	self changed: #stateFastDrag.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleFilterableLists [

	PluggableListMorph filterableLists: PluggableListMorph filterableLists not.
	self changed: #stateFilterableLists.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleFocusFollowsMouse [

	Preferences toggle: #mouseOverForKeyboardFocus.
	self changed: #stateFocusFollowsMouse.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleGradients [

	| switch |
	switch := SystemWindow gradientWindow not.
	
	SystemWindow gradientWindow: switch.
	DialogWindow gradientDialog: switch.
	MenuMorph gradientMenu: switch.
	ScrollBar gradientScrollBar: switch.
	PluggableButtonMorph gradientButton: switch.
	
	self changed: #stateGradients.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleHardShadows [

	self stateSoftShadows
		ifFalse: [Preferences toggle: #menuAppearance3d].
		
	Morph useSoftDropShadow: false.
	
	SystemWindow refreshAllWindows; reconfigureWindowsForFocus.
	SystemProgressMorph reset.
	TheWorldMainDockingBar updateInstances.
	
	self changed: #stateSoftShadows.
	self changed: #stateHardShadows.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> toggleInstallAutoComplete [

	self
		setProperty: #InstallAutoComplete
		toValue: self stateInstallAutoComplete not.
	self changed: #stateInstallAutoComplete.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> toggleInstallFFI [

	self
		setProperty: #InstallFFI
		toValue: self stateInstallFFI not.
	self changed: #stateInstallFFI.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> toggleInstallGitInfrastructure [

	self
		setProperty: #InstallGitInfrastructure
		toValue: self stateInstallGitInfrastructure not.
	self changed: #stateInstallGitInfrastructure.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> toggleInstallLatestUpdates [

	self
		setProperty: #InstallLatestUpdates
		toValue: self stateInstallLatestUpdates not.
	self changed: #stateInstallLatestUpdates.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> toggleInstallOSProcess [

	self
		setProperty: #InstallOSProcess
		toValue: self stateInstallOSProcess not.
	self changed: #stateInstallOSProcess.
]

{ #category : #'actions - packages' }
PreferenceWizardMorph >> toggleInstallRefactoringTools [

	self
		setProperty: #InstallRefactoringTools
		toValue: self stateInstallRefactoringTools not.
	self changed: #stateInstallRefactoringTools.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleReuseWindows [

	SystemWindow reuseWindows: SystemWindow reuseWindows not.
	self changed: #stateReuseWindows.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleRoundedButtonLook [

	| switch |
	switch := PluggableButtonMorph roundedButtonCorners not.
	
	PluggableButtonMorph roundedButtonCorners: switch.
	ScrollBar roundedScrollBarLook: switch.
	
	self changed: #stateRoundedButtonLook.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleRoundedWindowLook [

	| switch |
	switch := SystemWindow roundedWindowCorners not.
	
	SystemWindow roundedWindowCorners: switch.
	DialogWindow roundedDialogCorners: switch.
	MenuMorph roundedMenuCorners: switch.
	
	self changed: #stateRoundedWindowLook.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleScrollBarsNarrow [

	Preferences toggle: #scrollBarsNarrow.
	ScrollPane allSubInstancesDo: [:ea | ea scrollBarThickness: ScrollPane scrollBarThickness].
	self changed: #stateScrollBarsNarrow.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleScrollBarsOnRight [

	Preferences toggle: #scrollBarsOnRight.
	ScrollPane allSubInstancesDo: [:ea | ea scrollBarOnLeft: self stateScrollBarsOnRight not].
	self changed: #stateScrollBarsOnRight.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleScrollBarsWithoutArrowButtons [

	ScrollBar scrollBarsWithoutArrowButtons: ScrollBar scrollBarsWithoutArrowButtons not.
	self changed: #stateScrollBarsWithoutArrowButtons.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleScrollBarsWithoutMenuButton [

	ScrollBar scrollBarsWithoutMenuButton: ScrollBar scrollBarsWithoutMenuButton not.
	self changed: #stateScrollBarsWithoutMenuButton.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleSendMouseWheelToKeyboardFocus [

	HandMorph sendMouseWheelToKeyboardFocus: HandMorph sendMouseWheelToKeyboardFocus not.
	self changed: #stateSendMouseWheelToKeyboardFocus.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleShowKeyboardFocus [

	Morph indicateKeyboardFocus: Morph indicateKeyboardFocus not.
	self changed: #stateShowKeyboardFocus.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleSimpleFrameAdornments [

	PluggableTextMorph simpleFrameAdornments: PluggableTextMorph simpleFrameAdornments not.
	self changed: #stateSimpleFrameAdornments.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleSmartHorizontalSplitters [

	ProportionalSplitterMorph smartHorizontalSplitters: ProportionalSplitterMorph smartHorizontalSplitters not.
	self changed: #stateSmartHorizontalSplitters.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleSmartVerticalSplitters [

	ProportionalSplitterMorph smartVerticalSplitters: ProportionalSplitterMorph smartVerticalSplitters not.
	self changed: #stateSmartVerticalSplitters.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleSoftShadows [

	self stateHardShadows
		ifFalse: [Preferences toggle: #menuAppearance3d].
		
	Morph useSoftDropShadow: true.
	
	SystemWindow refreshAllWindows; reconfigureWindowsForFocus.
	SystemProgressMorph reset.
	TheWorldMainDockingBar updateInstances.
	
	self changed: #stateSoftShadows.
	self changed: #stateHardShadows.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleSwapMouseButtons [

	Preferences toggle: #swapMouseButtons.
	self changed: #stateSwapMouseButtons.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleToolAndMenuIcons [

	| switch |
	switch := Browser showClassIcons not.
	
	Browser showClassIcons: switch.
	Browser showMessageIcons: switch.
	Preferences setFlag: #menuWithIcons toValue: switch.
	Preferences setFlag: #visualExplorer toValue: switch.
	
	self changed: #stateToolAndMenuIcons.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleTraceMessages [

	Preferences toggle: #traceMessages.
	self changed: #stateTraceMessages.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleUseBiggerCursors [

	Cursor useBiggerCursors: self stateUseBiggerCursors not.
	Cursor currentCursor: Cursor currentCursor.
	
	self changed: #stateUseBiggerCursors.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleUseBiggerFonts [

	[
		self stateUseBiggerFonts
			ifFalse: [Preferences setDemoFonts]
			ifTrue: [Preferences restoreDefaultFonts].
	] valueSupplyingAnswer: true.
		
	self changed: #stateUseBiggerFonts.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleUseColorfulWindows [

	Model useColorfulWindows: Model useColorfulWindows not.
	self changed: #stateUseColorfulWindows.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleUseRetractableScrollBars [

	ScrollPane useRetractableScrollBars: ScrollPane useRetractableScrollBars not.
	self changed: #stateUseRetractableScrollBars.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleWindowButtonsAlwaysActive [

	SystemWindow windowTitleActiveOnFirstClick: SystemWindow windowTitleActiveOnFirstClick not.
	self changed: #stateWindowButtonsAlwaysActive.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleWindowsAlwaysActive [

	Model windowActiveOnFirstClick: Model windowActiveOnFirstClick not.
	self changed: #stateWindowsAlwaysActive.
]

{ #category : #'actions - buttons' }
PreferenceWizardMorph >> toggleWindowsRaiseOnClick [

	SystemWindow windowsRaiseOnClick: SystemWindow windowsRaiseOnClick not.
	self changed: #stateWindowsRaiseOnClick.
]

{ #category : #layout }
PreferenceWizardMorph >> updateLowPerformanceLabel: string [

	lowPerformanceMorph contentsAsIs: (string asText
		addAttribute: (TextColor color: (Color gray: 0.7));
		addAttribute: (TextFontReference toFont: (StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9))).
		
	lowPerformanceMorph layoutFrame: (LayoutFrame fractions: (1 @ 1 corner: 1 @ 1) offsets: (lowPerformanceMorph fullBounds width negated @ lowPerformanceMorph fullBounds height negated corner: 20 @ 20 "Into margins")).
	
	self layoutChanged.
]

{ #category : #layout }
PreferenceWizardMorph >> updatePageLabel [

	pagesLabel contentsAsIs: (('{1} / {2}' format: {currentPageIndex. pages size}) asText
		addAttribute: (TextColor color: (Color gray: 0.8));
		addAttribute: (TextFontReference toFont: (StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 12))).
]

{ #category : #layout }
PreferenceWizardMorph >> updateWindowBounds [

	| windows offset margin extentToUse pointsToUse |
	isFullScreen == false ifTrue: [^ self].
	
	self fullBounds.

	margin := 20@20.
	extentToUse := (previewWorld extent - (margin * 2)) // 3 * (1.8 @ 1.5).
	pointsToUse := {
		previewWorld center - (previewWorld extent // (5.5 @ 4.5)).
		previewWorld center + (previewWorld width // 5.5 @ 0).
		previewWorld center + (0 @ (previewWorld width // 5))}.

	windows := previewWorld submorphs.
	offset := 50@50.
	
	windows reversed withIndexDo: [:ea :i |
		ea
			extent: extentToUse;
			center: (pointsToUse atWrap: i).
		offset := offset + (50@50)].
]
