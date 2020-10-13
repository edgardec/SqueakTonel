"
I represent a query path into the class descriptions, the software of the system.
"
Class {
	#name : #Browser,
	#superclass : #CodeHolder,
	#instVars : [
		'environment',
		'systemOrganizer',
		'classOrganizer',
		'metaClassOrganizer',
		'editSelection',
		'metaClassIndicated',
		'selectedSystemCategory',
		'selectedClassName',
		'selectedMessageName',
		'selectedMessageCategoryName',
		'classDefinition',
		'metaClassDefinition'
	],
	#classVars : [
		'ListClassesHierarchically',
		'RecentClasses',
		'ShowClassIcons',
		'ShowMessageIcons',
		'SortMessageCategoriesAlphabetically'
	],
	#category : #'Tools-Browser'
}

{ #category : #preferences }
Browser class >> canUseMultiWindowBrowsers [
	^true
]

{ #category : #'class initialization' }
Browser class >> cleanUp [
	"Flush caches"

	self initialize.
]

{ #category : #'instance creation' }
Browser class >> fullOnCategory: aCategory [
	"Open a new full browser set to the system category."

	^ self new
		selectSystemCategory: aCategory asSymbol;
		buildAndOpenFullBrowser
]

{ #category : #'instance creation' }
Browser class >> fullOnClass: aClass [ 
	"Open a new full browser set to class."
	"Browser fullOnClass: Browser"

	^ self new
			setClass: aClass;
			buildAndOpenFullBrowser
]

{ #category : #'instance creation' }
Browser class >> fullOnClass: aClass category: category [
	"Open a new full browser set to class and message category."
	"Browser fullOnClass: Browser category: 'controls' "

	^ self new
			setClass: aClass;
			selectMessageCategoryNamed: category;
			buildAndOpenFullBrowser
]

{ #category : #'instance creation' }
Browser class >> fullOnClass: aClass selector: aSelector [
	"Open a new full browser set to the class and selector."
	"Browser fullOnClass: Browser selector: #defaultWindowColor"

	^ self new
			setClass: aClass selector: aSelector;
			buildAndOpenFullBrowser
]

{ #category : #'class initialization' }
Browser class >> initialize [
	"Browser initialize"

	RecentClasses := OrderedCollection new.
	self 
		registerInFlapsRegistry;
		registerInAppRegistry	
]

{ #category : #preferences }
Browser class >> listClassesHierarchically [
	<preference: 'List classes hierarchically'
		category: 'browsing'
		description: 'When enabled, the class list in the browser is arranged and indented with regard to the class hierarchy.'
		type: #Boolean>
	^ListClassesHierarchically ifNil: [false]

]

{ #category : #preferences }
Browser class >> listClassesHierarchically: aBool [

	ListClassesHierarchically := aBool
]

{ #category : #'instance creation' }
Browser class >> new [

	^super new systemOrganizer: SystemOrganization
]

{ #category : #'instance creation' }
Browser class >> newOnCategory: aCategory [
	"Open a new browser on this category"

	"Browser newOnCategory: 'Tools-Browser'"

	^self newOnCategory: aCategory label:  'Classes in category ', aCategory

]

{ #category : #'instance creation' }
Browser class >> newOnCategory: aCategory editString: aString label: aLabel [
	"Open a new browser on this category (testing first for existence) with aString pre-selected in the code pane.
	We have to be a bit sneaky to do the string insertion since it cannot be handled until after the actual browser is built and opened"

	"Browser newOnCategory: 'Tools-Browser' editString: 'test string edit setup' label: 'Testing category browser with set edit string'"

	| newBrowser |
	newBrowser := self newOnCategory: aCategory label: aLabel.
	aString ifNotNil:[newBrowser changed: #editString with: aString].
	^ newBrowser
	

]

{ #category : #'instance creation' }
Browser class >> newOnCategory: aCategory label: aLabel [
	"Open a new browser on this category (testing first for existence)."

	"Browser newOnCategory: 'Tools-Browser' label: 'Testing category browser'"

	| newBrowser newCat |
	newBrowser := self new.
	newCat := aCategory asSymbol.
	(newBrowser systemCategoryList includes: newCat)
		ifTrue: [ newBrowser selectSystemCategory: newCat ]
		ifFalse: [ ^ self inform: 'No such category' ].
	
	newBrowser buildAndOpenCategoryBrowserLabel: aLabel.
	^ newBrowser
	

]

{ #category : #'instance creation' }
Browser class >> newOnClass: aClass [ 
	"Open a new class browser on this class."
	^ self newOnClass: aClass label: 'Class Browser: ', aClass name
]

{ #category : #'instance creation' }
Browser class >> newOnClass: aClass editString: aString label: aLabel [
	"Open a new class browser on this class with aString pre-selected in the code pane.
	We have to be a bit sneaky to do the string insertion since it cannot be handled until after the actual browser is built and opened"
	"Browser newOnClass: Browser editString: 'test string edit setup' label: 'Testing category browser with set edit string'"
	| newBrowser|

	newBrowser := self newOnClass: aClass label: aLabel.
	newBrowser editSelection: #newMessage.
	aString ifNotNil:[newBrowser changed: #editString with: aString].
	^ newBrowser

]

{ #category : #'instance creation' }
Browser class >> newOnClass: aClass label: aLabel [
	"Open a new class browser on this class and set the label."
	"Browser newOnClass: Browser label: 'A specific label that I want'"
	| newBrowser |

	newBrowser := self new.
	newBrowser setClass: aClass.
	^ newBrowser buildAndOpenClassBrowserLabel: aLabel

]

{ #category : #'instance creation' }
Browser class >> newOnClass: aClass messageCategory: aCategory [

	^ self newOnClass: aClass messageCategory: aCategory editString: nil label: 'Message Category Browser (' , aClass name, ')'.
]

{ #category : #'instance creation' }
Browser class >> newOnClass: aClass messageCategory: aCategory editString: aString label: aLabel [
	"Open a new message protocol browser on this class & protocol with aString pre-selected in the code pane.
	We have to be a bit sneaky to do the string insertion since it cannot be handled until after the actual browser is built and opened"

	^self newOnClass: aClass messageCategory: aCategory selector: nil editString: aString label: aLabel
]

{ #category : #'instance creation' }
Browser class >> newOnClass: aClass messageCategory: aCategory selector: aSelector editString: aString label: aLabel [
	"Open a new message protocol browser on this class & protocol with aString pre-selected in the code pane.
	We have to be a bit sneaky to do the string insertion since it cannot be handled until after the actual browser is built and opened"
	"Browser newOnClass: Browser messageCategory: 'controls' selector: #decorateButtons editString: 'test string edit setup' label: 'Testing class browser with set edit string'"
	| newBrowser|

	newBrowser := self new.
	"setting up a new browser for a specific class, category and selector requires this order of messages
	since the #selectMessageCategoryNamed: carefully nils the chosen selector; thus we can't use
	the more obvious seeming #setClass:selector: method"
	newBrowser
		setClass: aClass;
		selectMessageCategoryNamed: aCategory;
		selectMessageNamed: aSelector;
		editSelection: #editMessage.

	newBrowser buildAndOpenMessageCategoryBrowserLabel: 'Message Category Browser (' , aClass name, ')'.
	aString ifNotNil:[newBrowser changed: #editString with: aString].
	^newBrowser
]

{ #category : #'instance creation' }
Browser class >> newOnClass: aClass selector: aSymbol [
	"Open a new class browser on this class."
	"Browser newOnClass: Browser selector: #decorateButtons"
	| newBrowser |

	newBrowser := self new.
	newBrowser setClass: aClass selector: aSymbol.
	^ newBrowser buildAndOpenClassBrowserLabel: 'Class Browser: ', aClass name

]

{ #category : #'instance creation' }
Browser class >> open [
	^self openBrowser


]

{ #category : #'instance creation' }
Browser class >> openBrowser [
	"Open a standard system browser with the generic category/class/protocol/message lists"
	"Browser openBrowser"

	^ self new buildAndOpenFullBrowser


]

{ #category : #'instance creation' }
Browser class >> prototypicalToolWindow [
	"Answer an example of myself seen in a tool window, for the benefit of parts-launching tools"

	^ ToolBuilder default build: self 
]

{ #category : #'class initialization' }
Browser class >> registerInAppRegistry [
	"Register the receiver in the SystemBrowser AppRegistry"
	SystemBrowser register: self.
]

{ #category : #'class initialization' }
Browser class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#Browser. #prototypicalToolWindow. 'Browser' translatedNoop. 'A Browser is a tool that allows you to view all the code of all the classes in the system' translatedNoop}
						forFlapNamed: 'Tools']
]

{ #category : #preferences }
Browser class >> showClassIcons [
	<preference: 'Show class icons'
		category: 'browsing'
		description: 'When enabled, the class list will show icons for some standard types such as Morph and Magnitude.'
		type: #Boolean>
	^ShowClassIcons ifNil: [true]

]

{ #category : #preferences }
Browser class >> showClassIcons: aBoolean [
	ShowClassIcons := aBoolean.
]

{ #category : #preferences }
Browser class >> showMessageIcons [
	<preference: 'Show message icons'
		category: 'browsing'
		description: 'When enabled, the message list will show icons for flags, overrides, etc.'
		type: #Boolean>
	^ShowMessageIcons ifNil: [true]

]

{ #category : #preferences }
Browser class >> showMessageIcons: aBoolean [

	ShowMessageIcons := aBoolean.
]

{ #category : #preferences }
Browser class >> sortMessageCategoriesAlphabetically [

	<preference: 'Sort Message Categories Alphabetically'
		categoryList: #(browsing Tools)
		description: 'When enabled, the message category list in the browser is ordered by alphabet. No need to ''alphabetize'' this list manually via the context menu.'
		type: #Boolean>
		
	^ SortMessageCategoriesAlphabetically ifNil: [false]

]

{ #category : #preferences }
Browser class >> sortMessageCategoriesAlphabetically: aBoolean [

	SortMessageCategoriesAlphabetically := aBoolean.

]

{ #category : #'instance creation' }
Browser class >> systemOrganizer: anOrganizer [

	^(super new)
		systemOrganizer: anOrganizer;
		yourself
]

{ #category : #'class initialization' }
Browser class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self].
	SystemBrowser unregister: self.
]

{ #category : #'code pane' }
Browser >> aboutToStyle: aStyler [
	"This is a notification that aStyler is about to re-style its text.
	Set the classOrMetaClass in aStyler, so that identifiers
	will be resolved correctly.
	Answer true to allow styling to proceed, or false to veto the styling"
	| type |
	
	self isModeStyleable ifFalse: [^false].
	type := self editSelection.
	(#(newMessage editMessage editClass newClass) includes: type) ifFalse:[^false].
	aStyler classOrMetaClass: ((type = #editClass or: [type = #newClass]) ifFalse:[self selectedClassOrMetaClass]).
	^true
]

{ #category : #'class functions' }
Browser >> addAllMethodsToCurrentChangeSet [
	"Add all the methods in the selected class or metaclass to the current change set.  You ought to know what you're doing before you invoke this!"

	| aClass |
	(aClass := self selectedClassOrMetaClass) ifNotNil:
		[aClass selectorsDo:
			[:sel |
				ChangeSet current adoptSelector: sel forClass: aClass].
		self changed: #annotation]

]

{ #category : #'message category functions' }
Browser >> addCategory [
	"Present a choice of categories or prompt for a new category name and add it before the current selection, or at the end if no current selection"
	| labels reject lines newName oldCategory |
	self okToChange ifFalse: [^ self].
	self hasClassSelected ifFalse: [^ self].
	labels := OrderedCollection new.
	reject := Set new.
	reject
		addAll: self selectedClassOrMetaClass organization categories;
		add: ClassOrganizer nullCategory;
		add: ClassOrganizer default.
	lines := OrderedCollection new.
	self selectedClassOrMetaClass allSuperclasses do: [:cls | | cats |
		cls = Object ifFalse: [
			cats := cls organization categories reject:
				 [:cat | reject includes: cat].
			cats isEmpty ifFalse: [
				lines add: labels size.
				labels addAll: cats sort.
				reject addAll: cats]]].
	(newName := UIManager default
		chooseFromOrAddTo: labels
		lines: lines
		title: 'Add Category') ifNil: [^ self].
	newName isEmpty
		ifTrue: [^ self]
		ifFalse: [newName := newName asSymbol].
	oldCategory := self selectedMessageCategoryName.
	self classOrMetaClassOrganizer
		addCategory: newName
		before: (self hasMessageCategorySelected
				ifFalse: [nil]
				ifTrue: [self selectedMessageCategoryName]).
	self changed: #messageCategoryList.
	self selectMessageCategoryNamed: newName.
	self changed: #messageCategoryList.

]

{ #category : #'message list' }
Browser >> addExtraShiftedItemsTo: aMenu [
	"The shifted selector-list menu is being built; some menu items are appropriate only for certain kinds of browsers, and this gives a hook for them to be added as approrpiate.  If any is added here, a line should be added first -- browse reimplementors of this message for examples."

]

{ #category : #'user interface' }
Browser >> addModelItemsToWindowMenu: aMenu [
	"Add model-related items to the window menu"
	super addModelItemsToWindowMenu: aMenu.
	SystemBrowser addRegistryMenuItemsTo: aMenu inAccountOf: self.
]

{ #category : #traits }
Browser >> addSpecialMenu: aMenu [
	aMenu addList: #(
		-
		('new class'				newClass)
		('new trait'				newTrait)
		-).
	self selectedClass notNil ifTrue: [
		aMenu addList: #(
			('add trait' addTrait)
			-) ].
	aMenu addList: #(-).
	^ aMenu
]

{ #category : #'system category functions' }
Browser >> addSystemCategory [
	"Prompt for a new category name and add it before the
	current selection, or at the end if no current selection"
	| oldSelection newName |
	self okToChange ifFalse: [^ self].
	oldSelection := self selectedSystemCategory.
	newName := self
		request: 'Please type new category name'
		initialAnswer: 'Category-Name'.
	newName isEmpty
		ifTrue: [^ self]
		ifFalse: [newName := newName asSymbol].
	systemOrganizer
		addCategory: newName
		before: self selectedSystemCategory.
	self selectSystemCategory:
		(oldSelection isNil
			ifTrue: [ self systemCategoryList last ]
			ifFalse: [ oldSelection ]).
	self changed: #systemCategoryList.
]

{ #category : #traits }
Browser >> addTrait [
	| input trait |
	input := UIManager default request: 'add trait'.
	input isEmptyOrNil ifFalse: [
		trait := Smalltalk classNamed: input.
		(trait isNil or: [trait isTrait not]) ifTrue: [
			^self inform: 'Input invalid. ' , input , ' does not exist or is not a trait'].
		self selectedClass setTraitComposition: self selectedClass traitComposition asTraitComposition +  trait.
		self contentsChanged].

]

{ #category : #'message category functions' }
Browser >> alphabetizeMessageCategories [
	| oldMessageCategory oldMethod |
	oldMessageCategory := selectedMessageCategoryName.
	oldMethod := selectedMessageName.
	self hasClassSelected ifFalse: [^ false].
	self okToChange ifFalse: [^ false].
	self classOrMetaClassOrganizer sortCategories.
	self clearUserEditFlag.
	self editClass.
	self selectClassNamed: selectedClassName.
	self selectMessageCategoryNamed: oldMessageCategory.
	self selectMessageNamed: oldMethod.
	^ true
]

{ #category : #'system category functions' }
Browser >> alphabetizeSystemCategories [

	self okToChange ifFalse: [^ false].
	systemOrganizer sortCategories.
	self selectSystemCategory: nil.
	self changed: #systemCategoryList.

]

{ #category : #annotation }
Browser >> annotation [
	"Provide a line of content for an annotation pane, representing information about the method associated with the selected class and selector in the receiver."

	|  aSelector aClass |
	(aClass := self selectedClassOrMetaClass) == nil ifTrue: [^ ''].
	self editSelection == #editComment ifTrue:
		[^ self annotationForSelector: #Comment ofClass: aClass].

	self editSelection == #editClass ifTrue:
		[^ self annotationForSelector: #Definition ofClass: aClass].
	(aSelector := self selectedMessageName) ifNil: [^ ''].
	^ self annotationForSelector: aSelector ofClass: aClass
]

{ #category : #annotation }
Browser >> annotation: aText [ 
	"The user accepted aText in our annotation pane"
	| theClass |
	(theClass := self selectedClass) ifNil: [^false].
	self editSelection == #editClass
		ifTrue: [
			self stripNaggingAttributeFromComment: aText.
			theClass comment: aText stamp: Utilities changeStamp.
			self changed: #classCommentText.
			^ true].
	^ false

]

{ #category : #'class comment pane' }
Browser >> annotationForClassCommentFor: aClass [
	"Provide a line of content for an annotation pane, given that the receiver is pointing at the class comment of the given class."
	| aStamp |
	aStamp :=  classOrganizer commentStamp.
	^ aStamp
		ifNil:
			[self selectedClassName, ' has no class comment']
		ifNotNil:
			['class comment for ', self selectedClassName,
				(aStamp = '<historical>'
					ifFalse:
						[' - ', aStamp]
					ifTrue:
						[''])]
]

{ #category : #'class comment pane' }
Browser >> annotationForClassDefinitionFor: aClass [
	"Provide a line of content for an annotation pane, given that the receiver is pointing at the class definition of the given class."
	^self classCommentText
]

{ #category : #'multi-window support' }
Browser >> arrowKey: aChar from: view [
	"Intercept Apple-Digit to select panes"
	| index |
	(aChar isDigit
	 and: [self multiWindowState notNil]) ifTrue:
	 	[index := aChar asciiValue - $0 asciiValue.
		index = 0 ifTrue: [index := 10].
		^index <= self multiWindowState models size
			ifTrue: [self multiWindowState selectWindowIndex: index]
			ifFalse: [self changed: #flash]].
	^super arrowKey: aChar from: view

]

{ #category : #'system category functions' }
Browser >> browseAllClasses [
	"Create and schedule a new browser on all classes alphabetically."
	
	^ClassListBrowser newOnAllClasses
]

{ #category : #'message functions' }
Browser >> browseAllCommentsForClass [
	"Opens a HelpBrowser on the class"

	| myClass |
	myClass := self selectedClassOrMetaClass ifNil: [ ^self ].
	myClass isTrait ifTrue: [ ^self ].
	(Smalltalk classNamed: #HelpBrowser)
		ifNil: [ ^self inform: 'HelpBrowser is not available.' ]
		ifNotNil: [ :HelpBrowser |
			HelpBrowser openOn: myClass theNonMetaClass ]

]

{ #category : #'multi-window support' }
Browser >> browseClassHierarchy [
	"Overridden to consider multi-window state and hierarchy browser."

	| behavior newBrowser |
	(behavior := self selectedClassOrMetaClass) isNil ifTrue:
		[^self].

	(self isPackage "PackageBrowser panes can't support a hierarchy browser; not sure why."
	 or: [self multiWindowState isNil]) ifTrue:
		[^super browseClassHierarchy].

	(newBrowser := HierarchyBrowser new initHierarchyForClass: behavior)
		selectMessageCategoryNamed: self selectedMessageCategoryName;
		selectMessageNamed: self selectedMessageName;
		editSelection: editSelection.

	self multiWindowState addWindow: newBrowser
]

{ #category : #toolbuilder }
Browser >> buildAndOpenCategoryBrowser [
	"assemble the spec for a system category browser, build it and open it - use the default label"

	^self buildAndOpenCategoryBrowserLabel: nil

]

{ #category : #toolbuilder }
Browser >> buildAndOpenCategoryBrowserLabel: aLabelString [
	"assemble the spec for a system category browser, build it and open it"

	| builder windowSpec |
	builder := ToolBuilder default.

	windowSpec := self buildCategoryBrowserWith: builder.
	aLabelString ifNotNil:[:str| windowSpec label: str].

	builder open: windowSpec.
	
	^self

]

{ #category : #toolbuilder }
Browser >> buildAndOpenClassBrowserLabel: aLabelString [
	"assemble the spec for a class browser, build it and open it"

	| builder max windowSpec catPaneHeight|
	builder := ToolBuilder default.
	catPaneHeight := Preferences standardListFont height + 5 "top margin/border" + 5 "bottom margin/border".
	max := self wantsOptionalButtons ifTrue:[0.32] ifFalse:[0.4].

	windowSpec :=self buildWindowWith: builder specs: {
		(self topConstantHeightFrame: self buttonHeight fromLeft: 0 width: 0.5) -> [self buildClassListSingletonWith: builder].
		(self frameOffsetFromTop: self buttonHeight fromLeft: 0 width: 0.5 bottomFraction: max) -> [self buildMessageCategoryListWith: builder].
		(self topConstantHeightFrame: self buttonHeight fromLeft: 0.5 width: 0.5) -> [self buildSwitchesWith: builder].
		(self frameOffsetFromTop: self buttonHeight fromLeft: 0.5 width: 0.5 bottomFraction: max) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	self setMultiWindowFor:windowSpec.
	windowSpec label: aLabelString.

	builder open: windowSpec.
	
	^self

]

{ #category : #toolbuilder }
Browser >> buildAndOpenFullBrowser [
	"assemble the spec for a full system browser, build it and open it"

	| builder window |
	builder := ToolBuilder default.

	"the build-but-don't-open phase is factored out to support the prototypicalToolWindow facility"
	window := self buildDefaultBrowserWith: builder.
	builder open: window.
]

{ #category : #toolbuilder }
Browser >> buildAndOpenMessageCategoryBrowserLabel: aLabelString [
	"assemble the spec for a messasge category browser, build it and open it"

	| builder max windowSpec|
	builder := ToolBuilder default.
	max := self wantsOptionalButtons ifTrue:[0.32] ifFalse:[0.4].

	windowSpec :=self buildWindowWith: builder specs: {
		(0@0 corner: 1.0@0.08) -> [self buildMessageListCatSingletonWith: builder].
		(0.0@0.08 corner: 1.0@max) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	self setMultiWindowFor:windowSpec.
	windowSpec label: aLabelString.

	builder open: windowSpec.
	
	^self

]

{ #category : #toolbuilder }
Browser >> buildCategoryBrowserWith: builder [
	"assemble the spec for a system category browser, build it and return it"

	| max windowSpec catPaneHeight|
	catPaneHeight := Preferences standardListFont height + 5 "top margin/border" + 5 "bottom margin/border".
	max := self wantsOptionalButtons ifTrue:[0.32] ifFalse:[0.4].

	windowSpec := self buildWindowWith: builder specs: {
		(LayoutFrame fractions: (0@0 corner: 1.0@0) offsets: (0@0 corner: 0@catPaneHeight)) -> [self buildSystemCatListSingletonWith: builder].
		((self classListFrame: max fromTop: 0 fromLeft: 0 width: 0.333)
			topOffset: catPaneHeight) -> [self buildClassListWith: builder].
		(self switchesFrame: max fromLeft: 0 width: 0.333) -> [self buildSwitchesWith: builder].
		(LayoutFrame fractions: (0.333@0 corner: 0.666@max) offsets: (0@catPaneHeight corner: 0@0)) -> [self buildMessageCategoryListWith: builder].
		(LayoutFrame fractions: (0.666@0 corner: 1@max) offsets: (0@catPaneHeight corner: 0@0)) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	self setMultiWindowFor:windowSpec.

	^builder build: windowSpec

]

{ #category : #toolbuilder }
Browser >> buildClassListSingletonWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #classListSingleton; 
		getIndex: #indexIsOne; 
		setIndex: #indexIsOne:; 
		menu: #classListMenu:shifted:;
		keyPress: #classListKey:from:;
		hScrollBarPolicy: #never;
		vScrollBarPolicy: #never;
		minimumHeight: 0.
	^listSpec

]

{ #category : #toolbuilder }
Browser >> buildClassListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #classList;
		getIndex: #classListIndex; 
		setIndex: #classListIndex:;
		icon: #classIconAt:; 
		menu: #classListMenu:shifted:; 
		keyPress: #classListKey:from:.
	SystemBrowser browseWithDragNDrop 
		ifTrue:[listSpec dragItem: #dragFromClassList:].

	^listSpec

]

{ #category : #toolbuilder }
Browser >> buildDefaultBrowserWith: builder [
	"assemble the spec for a full system browser, build it and return the built but not opened morph"
	"this build-but-don't-open phase is factored out to support the prototypicalToolWindow facility"

	| max windowSpec |
	max := self wantsOptionalButtons ifTrue:[0.42] ifFalse:[0.5].

	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.25@max) -> [self buildSystemCategoryListWith: builder].
		(self classListFrame: max) -> [self buildClassListWith: builder].
		(self switchesFrame: max) -> [self buildSwitchesWith: builder].
		(0.5@0 corner: 0.75@max) -> [self buildMessageCategoryListWith: builder].
		(0.75@0 corner: 1@max) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	self setMultiWindowFor:windowSpec.

	^builder build: windowSpec
]

{ #category : #'message category functions' }
Browser >> buildMessageCategoryBrowser [
	"Create and schedule a message category browser for the currently 
	selected message category."

	self buildMessageCategoryBrowserEditString: nil
]

{ #category : #'message category functions' }
Browser >> buildMessageCategoryBrowserEditString: aString [ 
	"Create and schedule a new class browser for the current selection,
	with initial textual contents set to aString. This is used specifically in
	spawning where a class is established but a method-category is not."
	^  self hasMessageCategorySelected ifTrue: [Browser
		newOnClass: self selectedClassOrMetaClass
		messageCategory:  self selectedMessageCategoryName
		selector: self selectedMessageName
		editString: aString
		label: 'Message category Browser: ' , self selectedClassOrMetaClass name , self categoryOfCurrentMethod]
]

{ #category : #toolbuilder }
Browser >> buildMessageCategoryListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #messageCategoryList; 
		getIndex: #messageCategoryListIndex; 
		setIndex: #messageCategoryListIndex:; 
		menu: #messageCategoryMenu:; 
		keyPress: #messageCategoryListKey:from:.
	SystemBrowser browseWithDragNDrop ifTrue:[
		listSpec
			dropAccept: #wantsMessageCategoriesDrop:;
			dropItem: #dropOnMessageCategories:at:].
	^listSpec

]

{ #category : #toolbuilder }
Browser >> buildMessageListCatSingletonWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #messageCatListSingleton; 
		getIndex: #indexIsOne; 
		setIndex: #indexIsOne:; 
		menu: #messageCategoryMenu:;
		hScrollBarPolicy: #never;
		vScrollBarPolicy: #never;
		minimumHeight: 0.
	^listSpec

]

{ #category : #toolbuilder }
Browser >> buildMessageListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #messageList; 
		getIndex: #messageListIndex; 
		setIndex: #messageListIndex:; 
		icon: #messageIconAt:;
		helpItem: #messageHelpAt:;
		menu: #messageListMenu:shifted:; 
		keyPress: #messageListKey:from:.
	SystemBrowser browseWithDragNDrop 
		ifTrue:[listSpec dragItem: #dragFromMessageList:].
	^listSpec

]

{ #category : #toolbuilder }
Browser >> buildSwitchesWith: builder [
	"Build the instance/comment/class switch"

	| panelSpec i q c |
	panelSpec := builder pluggablePanelSpec new
		layout: #horizontal;
		spacing: -1;
		children: OrderedCollection new;
		yourself.

	i := builder pluggableButtonSpec new.
	i 
			model: self;
			label: 'instance';
			help: 'Show instance-side methods' translated;
			state: #instanceMessagesIndicated; 
			action: #indicateInstanceMessages.

	q := builder pluggableButtonSpec new.
	q 
			model: self;
			horizontalResizing: #shrinkWrap;
			label: '?';
			help: 'Cycle between definition, comment, and hierarchy view' translated; 
			state: #classCommentIndicated; 
			action: #plusButtonHit.

	c := builder pluggableButtonSpec new.
	c 
			model: self;
			label: 'class';
			help: 'Show class-side methods' translated;
			state: #classMessagesIndicated; 
			action: #indicateClassMessages.
			
	panelSpec children addAll: {
		i. c.
		builder pluggableSpacerSpec new.
		q
	}.

	^panelSpec
]

{ #category : #toolbuilder }
Browser >> buildSystemCatListSingletonWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #systemCategorySingleton; 
		getIndex: #indexIsOne; 
		setIndex: #indexIsOne:; 
		menu: #systemCategoryMenu:; 
		keyPress: #systemCatSingletonKey:from:;
		hScrollBarPolicy: #never;
		vScrollBarPolicy: #never;
		minimumHeight: 0.
	^listSpec
]

{ #category : #'system category functions' }
Browser >> buildSystemCategoryBrowser [
	"Open a new system category browser on the selelcted category, if there is one"

	self hasSystemCategorySelected
		ifTrue: 
			[self class newOnCategory: self selectedSystemCategory]
]

{ #category : #'system category functions' }
Browser >> buildSystemCategoryBrowserEditString: aString [ 
	"Open a new system category browser on the selelcted category, if
	there is one"
	self hasSystemCategorySelected
		ifTrue: [self class
				newOnCategory: self selectedSystemCategory
				editString: aString
				label: 'Classes in category ' , self selectedSystemCategory]
]

{ #category : #toolbuilder }
Browser >> buildSystemCategoryListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #systemCategoryList; 
		getIndex: #systemCategoryListIndex; 
		setIndex: #systemCategoryListIndex:; 
		menu: #systemCategoryMenu:; 
		keyPress: #systemCatListKey:from:.
	SystemBrowser browseWithDragNDrop ifTrue:[
		listSpec
			dropAccept: #wantsSystemCategoriesDrop:;
			dropItem: #dropOnSystemCategories:at:].
	^listSpec
]

{ #category : #toolbuilder }
Browser >> buildWith: builder [
	"Create the ui for the browser"
	"Browser is a bit of an oddity in the ToolBuilder>build: world since the class provides several dfferent UIs rather than the one-per-class idiom of ToolBuilder. Here we are building the full browser version"

	^self buildDefaultBrowserWith: builder 
]

{ #category : #'message category functions' }
Browser >> canShowMultipleMessageCategories [
	"Answer whether the receiver is capable of showing multiple message categories"

	^ true
]

{ #category : #'message category list' }
Browser >> categorizeAllUncategorizedMethods [
	"Categorize methods by looking in parent classes for a method category."

	self classOrMetaClassOrganizer classifyAllUnclassified.
	self changed: #messageCategoryList
]

{ #category : #'message category functions' }
Browser >> categoryOfCurrentMethod [
	"Determine the method category associated with the receiver at the current moment, or nil if none"

	| aCategory |
	^ super categoryOfCurrentMethod ifNil:
		[(aCategory := self messageCategoryListSelection) == ClassOrganizer allCategory
					ifTrue:
						[nil]
					ifFalse:
						[aCategory]]
]

{ #category : #'message category functions' }
Browser >> changeMessageCategories: aString [ 
	"The characters in aString represent an edited version of the the message 
	categories for the selected class. Update this information in the system 
	and inform any dependents that the categories have been changed. This 
	message is invoked because the user had issued the categories command 
	and edited the message categories. Then the user issued the accept 
	command."

	self classOrMetaClassOrganizer changeFromString: aString.
	self clearUserEditFlag.
	self editClass.
	self selectClassNamed: selectedClassName.
	^ true
]

{ #category : #'system category functions' }
Browser >> changeSystemCategories: aString [ 
	"Update the class categories by parsing the argument aString."

	systemOrganizer changeFromString: aString.
	self changed: #systemCategoryList.
	^ true
]

{ #category : #metaclass }
Browser >> classCommentIndicated [
	"Answer true iff we're viewing the class comment."

	^ editSelection == #editComment 

]

{ #category : #'class functions' }
Browser >> classCommentText [
	"return the text to display for the comment of the currently selected class"
	| theClass |
	theClass := self selectedClassOrMetaClass.
	theClass ifNil: [ ^''].

	^ theClass hasComment
		ifTrue: [  theClass comment  ]
		ifFalse: [ self noCommentNagString ]
]

{ #category : #metaclass }
Browser >> classDefinitionIndicated [

	^ editSelection == #editClass 

]

{ #category : #'class functions' }
Browser >> classDefinitionText [
	"return the text to display for the definition of the currently selected class"
	| theClass |
	^(theClass := self selectedClassOrMetaClass) ifNil: [''] ifNotNil: [theClass definition]
]

{ #category : #'class list' }
Browser >> classIconAt: anIndex [

	self class showClassIcons
		ifFalse: [^ nil].

	^ ToolIcons iconNamed: (ToolIcons iconForClass: (self classList at: anIndex) withBlanksTrimmed asSymbol)
]

{ #category : #'class list' }
Browser >> classList [

	^ self class listClassesHierarchically
		ifTrue: [self hierarchicalClassList]
		ifFalse: [self defaultClassList].
]

{ #category : #'initialize-release' }
Browser >> classListFrame: bottomFraction [
	^self
		classListFrame: bottomFraction
		fromTop: 0
		fromLeft: 0.25
		width: 0.25.
]

{ #category : #'initialize-release' }
Browser >> classListFrame: bottomFraction fromLeft: leftFraction width: rightFraction [
	^self
		classListFrame: bottomFraction
		fromTop: 0
		fromLeft: leftFraction
		width: rightFraction.
]

{ #category : #'initialize-release' }
Browser >> classListFrame: bottomFraction fromTop: topFraction fromLeft: leftFraction width: rightFraction [
	^LayoutFrame new
		leftFraction: leftFraction offset: 0;
		topFraction: topFraction offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: bottomFraction offset: self buttonHeight negated
]

{ #category : #'class list' }
Browser >> classListIndex [
	"Answer the index of the current class selection."

	^ self classListIndexOf: self selectedClassName.
]

{ #category : #'class list' }
Browser >> classListIndex: anInteger [ 
	| newClassName |
	newClassName := self classList at: anInteger ifAbsent: [ nil ].
	newClassName := newClassName ifNotNil: [newClassName withoutLeadingBlanks asSymbol].
	self selectClassNamed: newClassName.
]

{ #category : #'class list' }
Browser >> classListIndexOf: className [ 

	| classList |
	classList := self classList.
	classList := classList collect: [:ea | ea withoutLeadingBlanks asSymbol].
	^ classList indexOf: className.
]

{ #category : #'class functions' }
Browser >> classListMenu: aMenu [ 
	"Conveniently fit for backward compatibility with old browers stored in image segments"
	<classListMenuShifted: false>
	aMenu addList: #(
		-
		('browse full (b)'			browseMethodFull)
		('browse hierarchy (h)'		spawnHierarchy)
		('browse protocol (p)'		browseFullProtocol)
		-
		('printOut'					printOutClass)
		('fileOut'					fileOutClass)
		-
		('show hierarchy'			hierarchy)
		('show definition'			editClass)
		('show comment'			editComment)
		('show all comments'		browseAllCommentsForClass)
		-
		('references... (r)'			browseVariableReferences)
		('assignments... (a)'			browseVariableAssignments)
		('class refs (N)'				browseClassRefs)
		-
		('rename class ...'			renameClass)
		('copy class'				copyClass)
		('remove class (x)'			removeClass)
		-
		('find method...'				findMethod)).
	^ aMenu

]

{ #category : #'class functions' }
Browser >> classListMenu: aMenu shifted: shifted [
	"Set up the menu to apply to the receiver's class list, honoring the #shifted boolean"
	^ self menu: aMenu for: #(classListMenu classListMenuShifted:) shifted: shifted.

]

{ #category : #'pluggable menus - hooks' }
Browser >> classListMenuHook: aMenu shifted: aBoolean [
	<classListMenu>
	<menuPriority: 400>
	^ self menuHook: aMenu named: #classListMenu shifted: aBoolean.

]

{ #category : #'class functions' }
Browser >> classListMenuMore: aMenu [ 
	" The 'more..' link that toggles between shifted and unshifted menus
	in class lists "
	<classListMenuShifted: false>
	<menuPriority: 1000>
	^ aMenu addList: #(- ('more...'	offerShiftedClassListMenu)); yourself

]

{ #category : #'class list' }
Browser >> classListSingleton [

	| name |
	name := self selectedClassName.
	^ name ifNil: [Array new]
		ifNotNil: [Array with: name]
]

{ #category : #metaclass }
Browser >> classMessagesIndicated [
	"Answer whether the messages to be presented should come from the 
	metaclass."

	^ self metaClassIndicated and: [self classCommentIndicated not]
]

{ #category : #'system category functions' }
Browser >> classNotFound [

	self changed: #flash.
]

{ #category : #metaclass }
Browser >> classOrMetaClassOrganizer [
	"Answer the class organizer for the metaclass or class, depending on 
	which (instance or class) is indicated."

	self metaClassIndicated
		ifTrue: [^metaClassOrganizer]
		ifFalse: [^classOrganizer]
]

{ #category : #'code pane' }
Browser >> compileMessage: aText notifying: aController [
	"Compile the code that was accepted by the user, placing the compiled method into an appropriate message category.  Return true if the compilation succeeded, else false."
	| fallBackCategoryName originalSelectorName result fallBackMethodName |
	self selectedMessageCategoryName = ClassOrganizer allCategory
		ifTrue:
			[ "User tried to save a method while the ALL category was selected"
			fallBackCategoryName := selectedMessageCategoryName.
			fallBackMethodName := selectedMessageName.
			editSelection == #newMessage
				ifTrue:
					[ "Select the 'as yet unclassified' category"
					selectedMessageCategoryName := nil.
					(result := self defineMessageFrom: aText notifying: aController)
						ifNil:
							["Compilation failure:  reselect the original category & method"
							selectedMessageCategoryName := fallBackCategoryName.
							selectedMessageName := fallBackMethodName]
						ifNotNil:
							[self setSelector: result]]
				ifFalse:
					[originalSelectorName := self selectedMessageName.
					self setOriginalCategoryIndexForCurrentMethod.
					selectedMessageName := fallBackMethodName := originalSelectorName.			
					(result := self defineMessageFrom: aText notifying: aController)
						ifNotNil:
							[self setSelector: result]
						ifNil:
							[ "Compilation failure:  reselect the original category & method"
							selectedMessageCategoryName := fallBackCategoryName.
							selectedMessageName := fallBackMethodName.
							^ result notNil]].
			self changed: #messageCategoryList.
			self changed: #messageList.
			^ result notNil]
		ifFalse:
			[ "User tried to save a method while the ALL category was NOT selected"
			^ (self defineMessageFrom: aText notifying: aController) notNil]
]

{ #category : #accessing }
Browser >> contents [
	"Depending on the current selection, different information is retrieved.
	Answer a string description of that information. This information is the
	method of the currently selected class and message."

	| comment theClass latestCompiledMethod |
	latestCompiledMethod := currentCompiledMethod.
	currentCompiledMethod := nil.

	editSelection == #newTrait
		ifTrue: [^ClassDescription newTraitTemplateIn: self selectedSystemCategory].
	editSelection == #none ifTrue: [^ ''].
	editSelection == #editSystemCategories 
		ifTrue: [^ systemOrganizer printString].
	editSelection == #newClass 
		ifTrue: [^ self newClassContents].
	editSelection == #editClass 
		ifTrue: [^self classDefinitionText].
	editSelection == #editComment 
		ifTrue:
			[(theClass := self selectedClass) ifNil: [^ ''].
			comment := theClass comment.
			currentCompiledMethod := classOrganizer commentRemoteStr.
			^ comment size = 0
				ifTrue: ['This class has not yet been commented.']
				ifFalse: [comment]].
	editSelection == #hierarchy 
		ifTrue: [^self selectedClassOrMetaClass printHierarchy].
	editSelection == #editMessageCategories 
		ifTrue: [^ self classOrMetaClassOrganizer printString].
	editSelection == #newMessage
		ifTrue:
			[^ (theClass := self selectedClassOrMetaClass) 
				ifNil: ['']
				ifNotNil: [theClass sourceCodeTemplate]].
	editSelection == #editMessage
		ifTrue:
			[^ self editContentsWithDefault:
				[currentCompiledMethod := latestCompiledMethod.
				self selectedMessage]].

	self error: 'Browser internal error: unknown edit selection.'
]

{ #category : #accessing }
Browser >> contents: input notifying: aController [ 
	"The retrieved information has changed and its source must now be
	 updated. The information can be a variety of things, depending on
	 the list selections (such as templates for class or message definition,
	 methods) or the user menu commands (such as definition, comment,
	 hierarchy).  Answer the result of updating the source."

	| aString aText theClass |
	self changed: #annotation.
	aString := input asString.
	aText := input asText.
	editSelection == #newTrait ifTrue: [^self defineTrait: input asString notifying: aController].
	editSelection == #editSystemCategories ifTrue: [^ self changeSystemCategories: aString].
	editSelection == #editClass | (editSelection == #newClass) ifTrue: [^ self defineClass: aString notifying: aController].
	editSelection == #editComment
		ifTrue: 
			[theClass := self selectedClass.
			theClass
				ifNil: 
					[self inform: 'You must select a class
before giving it a comment.'.
					^ false].
			theClass comment: aText stamp: Utilities changeStamp.
			self changed: #classCommentText.
			^ true].
	editSelection == #hierarchy ifTrue: [^ true].
	editSelection == #editMessageCategories ifTrue: [^ self changeMessageCategories: aString].
	editSelection == #editMessage | (editSelection == #newMessage)
		ifTrue:
			[^ self okayToAccept
				ifFalse:
					[false]
				ifTrue:
					[self compileMessage: aText notifying: aController]].
	editSelection == #none
		ifTrue: 
			[self inform: 'This text cannot be accepted
in this part of the browser.'.
			^ false].
	self error: 'unacceptable accept'
]

{ #category : #accessing }
Browser >> contentsSelection [
	"Return the interval of text in the code pane to select when I set the pane's contents"

	self hasMessageCategorySelected & (self hasMessageSelected not)
		ifTrue: [^ 1 to: 500]	"entire empty method template"
		ifFalse: [^ 1 to: 0]  "null selection"
]

{ #category : #'class functions' }
Browser >> copyClass [
	| originalClass originalName copysName |
	self hasClassSelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	originalClass := self selectedClass.
	originalName := originalClass name.
	copysName := self request: 'Please type new class name' initialAnswer: originalName.
	copysName = '' ifTrue: [^ self].  " Cancel returns '' "
	copysName := copysName asSymbol.
	copysName = originalName ifTrue: [^ self].
	(self environment hasClassNamed: copysName)
		ifTrue: [^ self error: copysName , ' already exists'].
	Cursor wait showWhile: [
		| newDefinition newMetaDefinition newClass |
		newDefinition := originalClass definition
			copyReplaceAll: originalName printString
			with: copysName printString.
		newClass := Compiler evaluate: newDefinition environment: self environment
			logged: true.
		newMetaDefinition := originalClass class definition
			copyReplaceAll: originalClass class name
			with: newClass class name.
		Compiler evaluate: newMetaDefinition environment: self environment
			logged: true.
		newClass copyAllCategoriesFrom: originalClass.
		newClass class copyAllCategoriesFrom: originalClass class.
		originalClass hasComment ifTrue: [
			newClass comment: originalClass comment ] ].
	self classListIndex: 0.
	self changed: #classList
]

{ #category : #accessing }
Browser >> couldBrowseAnyClass [
	"Answer whether the receiver is equipped to browse any class. This is in support of the system-brower feature that allows the browser to be redirected at the selected class name.  This implementation is clearly ugly, but the feature it enables is handsome enough.  3/1/96 sw"

	^self dependents
		anySatisfy: [:d | (d respondsTo: #getListSelector)
				and: [d getListSelector == #systemCategoryList]]
]

{ #category : #'class list' }
Browser >> createHierarchyTreeOf: col [

	"Create a tree from a flat collection of classes"
	| transformed |
	transformed := col collect: [:ea | 
		| childs indexes |
		childs := col select: [:class | class isTrait not and: [class superclass = ea]].
		indexes := childs collect: [:child | col indexOf: child].
		ea -> indexes].
	transformed copy do: [:ea |
		ea value: (ea value collect: [:idx | 
			| val |
			val := transformed at: idx.
			transformed at: idx put: nil.
			val])].
	^ transformed select: [:ea | ea notNil].

]

{ #category : #'class functions' }
Browser >> createInstVarAccessors [

	self selectedClassOrMetaClass
		ifNotNil: [:aClass | aClass createInstVarAccessors].

]

{ #category : #controls }
Browser >> decorateButtons [

	super decorateButtons.
	
	self changed: #classCommentIndicated.
	self changed: #instanceMessagesIndicated.
	self changed: #classMessagesIndicated.
]

{ #category : #'initialize-release' }
Browser >> defaultBrowserTitle [
	| title |
	title := 'System Browser'.
	^ self environment = self class environment
		ifTrue: [title]
		ifFalse: [title, ' on environment ', self environment asString]
]

{ #category : #'class list' }
Browser >> defaultClassList [
	"Answer an array of the class names of the selected category. Answer an 
	empty array if no selection exists."
		
	^ self hasSystemCategorySelected
		ifFalse: [Array new]
		ifTrue: [self selectedSystemCategory = SystemOrganizer allCategory
			ifTrue: [systemOrganizer allElements sort]
			ifFalse: [systemOrganizer listAtCategoryNamed: self selectedSystemCategory]]

]

{ #category : #'user interface' }
Browser >> defaultWindowColor [
	^ (Color r: 0.764 g: 0.9 b: 0.63)
]

{ #category : #'class functions' }
Browser >> defineClass: defString notifying: aController [  
	"The receiver's textual content is a request to define a new class. The
	source code is defString. If any errors occur in compilation, notify
	aController."
	| oldClass class newClassName defTokens keywdIx envt |
	oldClass := self selectedClassOrMetaClass.
	defTokens := defString findTokens: Character separators.
	
	((defTokens first = 'Trait' and: [defTokens second = 'named:'])
		or: [defTokens second = 'classTrait'])
		ifTrue: [^self defineTrait: defString notifying: aController].
		
	keywdIx := defTokens findFirst: [:x | x beginsWith: 'category'].
	envt := self selectedEnvironment.
	keywdIx := defTokens findFirst: [:x | '*subclass*' match: x].
	newClassName := (defTokens at: keywdIx+1) copyWithoutAll: '#()'.
	((oldClass isNil or: [oldClass theNonMetaClass name asString ~= newClassName])
		and: [envt includesKey: newClassName asSymbol]) ifTrue:
			["Attempting to define new class over existing one when
				not looking at the original one in this browser..."
			(self confirm: ((newClassName , ' is an existing class in this system.
Redefining it might cause serious problems.
Is this really what you want to do?') asText makeBoldFrom: 1 to: newClassName size))
				ifFalse: [^ false]].
	"ar 8/29/1999: Use oldClass superclass for defining oldClass
	since oldClass superclass knows the definerClass of oldClass."
	oldClass ifNotNil:[oldClass := oldClass superclass].
	class := envt beCurrentDuring: 
		[oldClass subclassDefinerClass
				evaluate: defString
				in: envt
				notifying: aController
				logged: false].
	(class isKindOf: Behavior)
		ifTrue: [self changed: #systemCategoryList; changed: #classList.
				self clearUserEditFlag; spawnOrNavigateTo: class.
				^ true]
		ifFalse: [^ false]
]

{ #category : #'message functions' }
Browser >> defineMessageFrom: aString notifying: aController [
	"Compile the expressions in aString. Notify aController if a syntax error occurs. Install the compiled method in the selected class classified under  the currently selected message category name. Answer the selector obtained if compilation succeeds, nil otherwise."
	| selectedMessageName selector category oldMessageList selectedClassOrMetaClass |
	selectedMessageName := self selectedMessageName.
	oldMessageList := self messageList.
	selectedClassOrMetaClass := self selectedClassOrMetaClass.
	contents := nil.
	selector := (selectedClassOrMetaClass newParser parseSelector: aString).
	(self metaClassIndicated
		and: [(selectedClassOrMetaClass includesSelector: selector) not
		and: [Metaclass isScarySelector: selector]])
		ifTrue: ["A frist-time definition overlaps the protocol of Metaclasses"
				(self confirm: ((selector , ' is used in the existing class system.
Overriding it could cause serious problems.
Is this really what you want to do?') asText makeBoldFrom: 1 to: selector size))
				ifFalse: [^nil]].
	category := selectedMessageName
		ifNil: [ self selectedMessageCategoryName ]
		ifNotNil: [ (selectedClassOrMetaClass >> selectedMessageName) methodReference ifNotNil: [ : ref | ref category ]].
	selector := selectedClassOrMetaClass
				compile: aString
				classified: category
				notifying: aController.
	selector == nil ifTrue: [^ nil].
	contents := aString copy.
	
	self changed: #messageCategoryList. "Because the 'as yet unclassified' might just appear."
	self changed: #messageList. "Because we have code-dependent list formatting by now such as #isDeprecated."
	
	selector ~~ selectedMessageName
		ifTrue: 
			[category = ClassOrganizer nullCategory
				ifTrue: [self changed: #classSelectionChanged.
						self changed: #classList.
						self messageCategoryListIndex: 1].
			self setClassOrganizer.  "In case organization not cached"
			(oldMessageList includes: selector)
				ifFalse: [self changed: #messageList].
			self messageListIndex: (self messageList indexOf: selector)].
	^ selector
]

{ #category : #traits }
Browser >> defineTrait: defString notifying: aController [  

	| defTokens keywdIx envt oldTrait newTraitName trait |
	oldTrait := self selectedClassOrMetaClass.
	defTokens := defString findTokens: Character separators.
	keywdIx := defTokens findFirst: [:x | x = 'category'].
	envt := self selectedEnvironment.
	keywdIx := defTokens findFirst: [:x | x = 'named:'].
	newTraitName := (defTokens at: keywdIx+1) copyWithoutAll: '#()'.
	((oldTrait isNil or: [oldTrait baseTrait name asString ~= newTraitName])
		and: [envt includesKey: newTraitName asSymbol]) ifTrue:
			["Attempting to define new class/trait over existing one when
				not looking at the original one in this browser..."
			(self confirm: ((newTraitName , ' is an existing class/trait in this system.
Redefining it might cause serious problems.
Is this really what you want to do?') asText makeBoldFrom: 1 to: newTraitName size))
				ifFalse: [^ false]].

	trait := envt beCurrentDuring:
		[Compiler evaluate: defString in: envt notifying: aController logged: true].
	^(trait isTrait)
		ifTrue: [
			self changed: #classList.
			self classListIndex: (self classListIndexOf: trait baseTrait name).
			self clearUserEditFlag; editClass.
			true]
		ifFalse: [ false ]

]

{ #category : #'self-updating' }
Browser >> didCodeChangeElsewhere [

	super didCodeChangeElsewhere ifTrue:
		[^true].
	self classDefinitionIndicated ifFalse:
		[^false].
	^self metaClassIndicated
		ifFalse:
			[classDefinition ~= (self selectedClass ifNotNil: [:selectedClass| selectedClass definition])]
		ifTrue:
			[metaClassDefinition ~= (self selectedClass ifNotNil: [:selectedClass| selectedClass theMetaClass definition])]
]

{ #category : #accessing }
Browser >> doItReceiver [
	"This class's classPool has been jimmied to be the classPool of the class 
	being browsed. A doIt in the code pane will let the user see the value of 
	the class variables."

	^ self selectedClass
]

{ #category : #'drag and drop' }
Browser >> dragFromClassList: index [ 
	"Drag a class from the browser"
	| name envt |
	(name := self classList at: index) ifNil: [ ^ nil ].
	(envt := self selectedEnvironment) ifNil: [ ^ nil ].
	^ envt
		at: name withBlanksTrimmed asSymbol
		ifAbsent: [  ]
]

{ #category : #'drag and drop' }
Browser >> dragFromMessageList: index [
	"Drag a method from the browser"
	
	| selector |
	self flag: #refactor. "mt: Maybe use an approach similar to MessageSet class >> #parse:toClassAndSelector instead of #asString? There could be any fancy representation of a message in the message list."
	selector := Symbol lookup: (self messageList at: index) asString.
	selector ifNil: [^ self].
	
	^self selectedClassOrMetaClass compiledMethodAt: selector ifAbsent:[nil]
]

{ #category : #'drag and drop' }
Browser >> dropOnMessageCategories: method at: index [

	| sourceClass destinationClass category copy |
	copy := Sensor shiftPressed.
	(method isKindOf: CompiledMethod) 
		ifFalse:[^self inform: 'Can only drop methods'].
	sourceClass := method methodClass.
	destinationClass := self selectedClassOrMetaClass.
	sourceClass == destinationClass ifTrue:[
		category := self messageCategoryList at: index.
		category = ClassOrganizer allCategory ifTrue: [^false].
		destinationClass organization classify: method selector  under: category suppressIfDefault: false logged: true.
		self changed: #messageCategoryList.
		self changed: #messageList.
		^true ].
	(copy
		or: [ (destinationClass inheritsFrom: sourceClass)
		or: [ (sourceClass inheritsFrom: destinationClass)
		or: [ sourceClass theNonMetaClass == destinationClass theNonMetaClass ] ] ])
		ifFalse: [
			(self confirm: (
				'Classes "{1}" and "{2}" are unrelated.{3}Are you sure you want to move this method?'
					format: { sourceClass. destinationClass. Character cr })) 
						ifFalse: [ ^false ] ].
	destinationClass
		compile: method getSource
		classified: (self messageCategoryList at: index)
		withStamp: method timeStamp
		notifying: nil.
	copy ifFalse: [
		sourceClass removeSelector: method selector ].
	^true
]

{ #category : #'drag and drop' }
Browser >> dropOnSystemCategories: aClass at: index [
	| category |
	(aClass isBehavior) ifFalse:[^self inform: 'Can only drop classes'].
	category := self systemCategoryList at: index.
	self selectedEnvironment organization classify: aClass instanceSide name  under: category.
	self changed: #systemCategoryList.
	self changed: #classList.
	^true
]

{ #category : #'class functions' }
Browser >> editClass [
	"Retrieve the description of the class definition."

	self hasClassSelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	self messageCategoryListIndex: 0.
	self editSelection: #editClass.
	self changed: #contents.
	self changed: #classCommentText.

]

{ #category : #'class functions' }
Browser >> editComment [
	"Retrieve the description of the class comment."

	self hasClassSelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	self messageCategoryListIndex: 0.
	metaClassIndicated := false.
	self editSelection: #editComment.
	self changed: #classSelectionChanged.
	self changed: #messageCategoryList.
	self changed: #messageList.
	self decorateButtons.
	self contentsChanged

]

{ #category : #'message category functions' }
Browser >> editMessageCategories [
	"Indicate to the receiver and its dependents that the message categories of 
	the selected class have been changed."

	self okToChange ifFalse: [^ self].
	self hasClassSelected
		ifTrue: 
			[self messageCategoryListIndex: 0.
			self editSelection: #editMessageCategories.
			self changed: #editMessageCategories.
			self contentsChanged]
]

{ #category : #accessing }
Browser >> editSelection [
	^editSelection
]

{ #category : #accessing }
Browser >> editSelection: aSelection [
	"Set the editSelection as requested."

	editSelection := aSelection.
	self changed: #editSelection.
]

{ #category : #'system category functions' }
Browser >> editSystemCategories [
	"Retrieve the description of the class categories of the system organizer."

	self okToChange ifFalse: [^ self].
	self selectSystemCategory: nil.
	self editSelection: #editSystemCategories.
	self changed: #editSystemCategories.
	self contentsChanged
]

{ #category : #accessing }
Browser >> environment [
	^ environment 	ifNil: [Environment default]
]

{ #category : #'class functions' }
Browser >> explainSpecial: string [ 
	"Answer a string explaining the code pane selection if it is displaying 
	one of the special edit functions."

	| classes whole lits reply |
	(editSelection == #editClass or: [editSelection == #newClass])
		ifTrue: 
			["Selector parts in class definition"
			string last == $: ifFalse: [^nil].
			lits := Array with:
				#subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:.
			(whole := lits
					detect: [:each | each keywords anySatisfy: [:frag | frag = string] ]
					ifNone: []) ~~ nil
				ifTrue: [reply := '"' , string , ' is one part of the message selector ' , whole , '.']
				ifFalse: [^nil].
			classes := self systemNavigation allClassesImplementing: whole.
			classes := 'these classes ' , classes printString.
			^reply , '  It is defined in ' , classes , '."
Smalltalk browseAllImplementorsOf: #' , whole].

	editSelection == #hierarchy
		ifTrue: 
			["Instance variables in subclasses"
			classes := self selectedClassOrMetaClass allSubclasses.
			classes := classes
					detect: [:each | each instVarNames anySatisfy: [:name | name = string] ]
					ifNone: [^nil].
			classes := classes printString.
			^'"is an instance variable in class ' , classes , '."
' , classes , ' browseAllAccessesTo: ''' , string , '''.'].
	editSelection == #editSystemCategories ifTrue: [^nil].
	editSelection == #editMessageCategories ifTrue: [^nil].
	^nil
]

{ #category : #'class functions' }
Browser >> fileOutClass [
	"Print a description of the selected class onto a file whose name is the 
	category name followed by .st."

	Cursor write showWhile:
		[self hasClassSelected ifTrue: [self selectedClass fileOut]]
]

{ #category : #'message category functions' }
Browser >> fileOutMessageCategories [
	"Print a description of the selected message category of the selected class 
	onto an external file."

Cursor write showWhile:
	[self hasMessageCategorySelected
		ifTrue: 
			[self selectedClassOrMetaClass fileOutCategory: self selectedMessageCategoryName]]
]

{ #category : #'system category functions' }
Browser >> fileOutSystemCategory [
	"Print a description of each class in the selected category onto a file 
	whose name is the category name followed by .st."

	self hasSystemCategorySelected
		ifTrue: [systemOrganizer fileOutCategory: self selectedSystemCategory]
]

{ #category : #'system category functions' }
Browser >> findClass [
	"Search for a class by name."

	| foundClass |
	(self multiWindowState notNil
	 or: [self okToChange]) ifFalse:
		[^self classNotFound].
	foundClass := UIManager default chooseClassOrTraitFrom: self environment.
	foundClass ifNil: [^self classNotFound].
	(self selectedClass notNil
	 and: [self multiWindowState notNil
	 "Can only support multi-window if original window has all the right panes."
	 and: [self multiWindowState prototype isHierarchy not]]) ifTrue:
		[(self classList includes: foundClass name)
			ifTrue: [self multiWindowState copyWindow]
			ifFalse: [self multiWindowState addNewWindow]].
 	self selectCategoryForClass: foundClass.
	self selectClass: foundClass
]

{ #category : #'class functions' }
Browser >> findMethod [
	"Pop up a list of the current class's methods, and select the one chosen by the user"
	| aClass selectors reply cat messageCatIndex messageIndex |
	self classListIndex = 0 ifTrue: [^ self].
	self okToChange ifFalse: [^ self].
	aClass := self selectedClassOrMetaClass.
	selectors := aClass selectors sorted.
	selectors isEmpty ifTrue: [self inform: aClass name, ' has no methods.'. ^ self].
	reply := UIManager default 
		chooseFrom: selectors
		values: selectors
		lines: #(1).
	reply ifNil: [^ self].
	cat := aClass whichCategoryIncludesSelector: reply.
	messageCatIndex := self messageCategoryList indexOf: cat.
	self messageCategoryListIndex: messageCatIndex.
	messageIndex := (self messageList indexOf: reply).
	self messageListIndex: messageIndex
]

{ #category : #'class list' }
Browser >> flattenHierarchyTree: classHierarchy on: col indent: indent [
	^ self
		flattenHierarchyTree: classHierarchy
		on: col
		indent: indent
		by: '  '.
]

{ #category : #'class list' }
Browser >> flattenHierarchyTree: classHierarchy on: col indent: indent by: indentChars [
	^ self
		flattenHierarchyTree: classHierarchy
		on: col
		indent: indent
		by: indentChars
		format: [:class | class name]
]

{ #category : #'class list' }
Browser >> flattenHierarchyTree: classHierarchy on: col indent: indent by: indentChars format: formatBlock [
	"Recursively add to col the names in classHierarchy indenting to show the hierarchical relationship. Use indentChars to do the indenting: spaces, tabs, etc."
	| plusIndent |
	plusIndent := indentChars.
	classHierarchy do: [:assoc |
		| class childs label |
		class := assoc key.
		label := formatBlock value: class.
		label isText
			ifTrue: [col add: (Text string: indent attributes: (label attributesAt: 1)), label]
			ifFalse: [col add: indent, label].
		childs := assoc value.
		self
			flattenHierarchyTree: childs
			on: col
			indent: indent , plusIndent
			by: indentChars
			format: formatBlock].
	^ col
]

{ #category : #'initialize-release' }
Browser >> frameOffsetFromTop: height fromLeft: leftFraction width: rightFraction bottomFraction: bottomFraction [
	^LayoutFrame new
		topFraction: 0 offset: height;
		leftFraction: leftFraction offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: bottomFraction offset: 0;
		yourself.
]

{ #category : #'class list' }
Browser >> hasClassSelected [
	^ selectedClassName notNil and: [(Smalltalk classNamed: selectedClassName) notNil]
]

{ #category : #'message category list' }
Browser >> hasMessageCategorySelected [
	^ self selectedMessageCategoryName notNil.
]

{ #category : #'message list' }
Browser >> hasMessageSelected [
	^ self selectedMessageName notNil.
]

{ #category : #'system category list' }
Browser >> hasSystemCategorySelected [
	^ self selectedSystemCategory notNil.
]

{ #category : #'class list' }
Browser >> hierarchicalClassList [

	"classNames are an arbitrary collection of classNames of the system.
	Reorder those class names so that they are sorted and indended by inheritance"
	| classes |
	"Creating the hierarchy is *really slow* for the full class list. Skip it for now."
	self selectedSystemCategory = SystemOrganizer allCategory
		ifTrue: [^ self defaultClassList].
		
	classes := self defaultClassList collect: [:sym | self environment classNamed: sym].
	^ self
		flattenHierarchyTree: (self createHierarchyTreeOf: classes)
		on: OrderedCollection new
		indent: ''.
]

{ #category : #'class functions' }
Browser >> hierarchy [
	"Display the inheritance hierarchy of the receiver's selected class."

	self hasClassSelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	self messageCategoryListIndex: 0.
	self editSelection: #hierarchy.
	self changed: #editComment.
	self contentsChanged.
	^ self
]

{ #category : #'message category functions' }
Browser >> highlightMessageList: list with: morphList [
	"Changed by emm to add emphasis in case of breakpoint"

	morphList do:[:each | 
		| classOrNil methodOrNil |
		classOrNil := self selectedClassOrMetaClass.
		methodOrNil := classOrNil isNil
			ifTrue:[nil]
			ifFalse:[classOrNil methodDictionary at: each contents ifAbsent:[]].
		(methodOrNil notNil and:[methodOrNil hasBreakpoint])
			ifTrue:[each contents: ((each contents ,' [break]') asText allBold)]]
]

{ #category : #'system category list' }
Browser >> indexIsOne [
	"When used as a singleton list, index is always one"
	^ 1
]

{ #category : #'system category list' }
Browser >> indexIsOne: value [
	"When used as a singleton list, can't change it"

	^ self
]

{ #category : #metaclass }
Browser >> indicateClassMessages [
	"Indicate that the message selection should come from the metaclass 
	messages."

	self okToChange ifTrue: [
		self metaClassIndicated: true]
]

{ #category : #metaclass }
Browser >> indicateInstanceMessages [
	"Indicate that the message selection should come from the class (instance) 
	messages."

	self okToChange ifTrue: [
		self metaClassIndicated: false]
]

{ #category : #'message functions' }
Browser >> inspectInstances [
	"Inspect all instances of the selected class.  1/26/96 sw"

	| myClass |
	((myClass := self selectedClassOrMetaClass) isNil or: [myClass isTrait])
		ifFalse: [myClass theNonMetaClass inspectAllInstances]

]

{ #category : #'message functions' }
Browser >> inspectSubInstances [
	"Inspect all instances of the selected class and all its subclasses  1/26/96 sw"

	| aClass |
	((aClass := self selectedClassOrMetaClass) isNil or: [aClass isTrait])
		ifFalse: [
			aClass := aClass theNonMetaClass.
			aClass inspectSubInstances].

]

{ #category : #metaclass }
Browser >> instanceMessagesIndicated [
	"Answer whether the messages to be presented should come from the 
	class."

	^metaClassIndicated not and: [self classCommentIndicated not]
]

{ #category : #'multi-window support' }
Browser >> isHierarchy [
	^false
]

{ #category : #'multi-window support' }
Browser >> isPackage [
	^false
]

{ #category : #'initialize-release' }
Browser >> labelString [
	| label |
	label := self selectedClassName
				ifNil: [ self defaultBrowserTitle ]
				ifNotNil: [ self defaultBrowserTitle, ': ', self selectedClassName asString ].
	(self multiWindowState notNil
	 and: [self multiWindowState models size > 1]) ifTrue:
		[label := (self multiWindowState models indexOf: self) printString, '. ', label].
	^label
]

{ #category : #'message list' }
Browser >> lastMessageName [
	^ self messageList last.
]

{ #category : #'message category functions' }
Browser >> mainMessageCategoryMenu: aMenu [
	<messageCategoryMenu>
	^ aMenu addList: #(
			('browse'						buildMessageCategoryBrowser)
			('print out'						printOutMessageCategories)
			('file out'						fileOutMessageCategories)
			-
			('reorganize'					editMessageCategories)
			('alphabetize'					alphabetizeMessageCategories)
			('remove empty categories'	removeEmptyCategories)
			('categorize all uncategorized'	categorizeAllUncategorizedMethods)
			('new category...'				addCategory)
			-
			('rename...'						renameCategory)
			('remove (x)'					removeMessageCategory));
		yourself

]

{ #category : #'message functions' }
Browser >> mainMessageListMenu: aMenu [
	<messageListMenuShifted: false>
	^ aMenu addList: #(
			('what to show...'			offerWhatToShowMenu)
			('toggle break on entry'		toggleBreakOnEntry)
			-
			('browse full (b)' 			browseMethodFull)
			('browse hierarchy (h)'		browseClassHierarchy)
			('browse protocol (p)'			browseFullProtocol)
			-
			('fileOut'					fileOutMessage)
			('printOut'					printOutMessage)
			('copy selector (c)'			copySelector)
			('copy reference (C)'		copyReference)
			-
			('senders of... (n)'			browseSendersOfMessages)
			('implementors of... (m)'		browseMessages)
			('inheritance (i)'			methodHierarchy)
			('versions (v)'				browseVersions)
			-
			('references... (r)'			browseVariableReferences)
			('assignments... (a)'			browseVariableAssignments)
			('class refs (N)'			browseClassRefs)
			-
			('remove method (x)'			removeMessage)
			('explore method'			exploreMethod)
			('inspect method'			inspectMethod));
		yourself

]

{ #category : #'system category functions' }
Browser >> mainSystemCategoryMenu: aMenu [
	<systemCategoryMenu>
	^ aMenu addList: #(
			('find class... (f)'			findClass)
			('back... (b)'				recent)
			-
			('browse all'			browseAllClasses)
			('browse'				buildSystemCategoryBrowser)
			-
			('printOut'				printOutSystemCategory)
			('fileOut'				fileOutSystemCategory)
			-
			('reorganize'			editSystemCategories)
			('alphabetize'			alphabetizeSystemCategories)
			-
			('update'				updateSystemCategories)
			('add item...'				addSystemCategory)
			('rename...'				renameSystemCategory)
			('remove (x)'			removeSystemCategory));
		yourself

]

{ #category : #'class functions' }
Browser >> makeNewSubclass [

	self selectedClassOrMetaClass ifNil: [^ self].
	self okToChange ifFalse: [^ self].
	self editSelection: #newClass.
	self contentsChanged.
	"Force the text view to assume there are changes"
	self changed: #editString with: self contents
]

{ #category : #'message category list' }
Browser >> messageCatListSingleton [

	| name |
	name := self selectedMessageCategoryName.
	^ name ifNil: [Array new]
		ifNotNil: [Array with: name]
]

{ #category : #'message category list' }
Browser >> messageCategoryList [
	"Answer the selected category of messages."

	^ self hasClassSelected
		ifFalse: [Array new]
		ifTrue: [ {ClassOrganizer allCategory},
			(self class sortMessageCategoriesAlphabetically
				ifTrue: [self rawMessageCategoryList sorted]
				ifFalse: [self rawMessageCategoryList]) ]
]

{ #category : #'message category list' }
Browser >> messageCategoryListIndex [
	"Answer the index of the selected message category."

	^self messageCategoryList indexOf: selectedMessageCategoryName
]

{ #category : #'message category list' }
Browser >> messageCategoryListIndex: anInteger [
	"Set the selected message category to be the one indexed by anInteger."

	selectedMessageCategoryName := nil.
	self selectMessageCategoryNamed: (self messageCategoryList at: anInteger ifAbsent: [nil]).
]

{ #category : #'message category list' }
Browser >> messageCategoryListKey: aCharacter from: view [

	aCharacter == $x ifTrue: [ ^self removeMessageCategory ].
	^self arrowKey: aCharacter from: view
	
]

{ #category : #'message category list' }
Browser >> messageCategoryListSelection [
	"Return the selected category name or nil."

	^ ((self messageCategoryList size = 0 
		or: [self messageCategoryListIndex = 0]) 
		or: [self messageCategoryList size < self messageCategoryListIndex])
			ifTrue: [nil]
			ifFalse: [self messageCategoryList at: (self messageCategoryListIndex max: 1)]
]

{ #category : #'message category functions' }
Browser >> messageCategoryMenu: aMenu [
	^ self menu: aMenu for: #(messageCategoryMenu messageCategoryMenuShifted:)

]

{ #category : #'pluggable menus - hooks' }
Browser >> messageCategoryMenuHook: aMenu shifted: aBoolean [
	<messageCategoryMenu>
	<menuPriority: 400>
	^ self menuHook: aMenu named: #messageCategoryMenu shifted: aBoolean.

]

{ #category : #'message list' }
Browser >> messageHelpAt: anIndex [
	"Show the first n lines of the sources code of the selected message."
	
	| iconHelp selector method |
	Preferences balloonHelpInMessageLists ifFalse: [^ nil].
	self messageList size < anIndex ifTrue: [^ nil].
	
	"Items in the message list can be formatted texts."
	self flag: #refactor.
	selector := Symbol lookup: (self messageList at: anIndex) asString.
	selector ifNil: [^ nil].
	
	method := self selectedClassOrMetaClass compiledMethodAt: selector ifAbsent: [^ nil].
	iconHelp := (self messageIconHelpFor: method selector) ifNotEmpty: [:t | 
		t , Character cr, Character cr].
	
	^ iconHelp asText
		append: (self messageHelpForMethod: method);
		yourself
]

{ #category : #'message list' }
Browser >> messageIconAt: anIndex [

	| selector |
	self class showMessageIcons ifFalse: [^ nil].
	
	self flag: #refactor.
	selector := Symbol lookup: (self messageList at: anIndex ifAbsent: [^nil]) asString.
	selector ifNil: [^ nil].
	
	^ self messageIconFor: selector
]

{ #category : #'message list' }
Browser >> messageIconFor: aSelector [ 

	self class showMessageIcons ifFalse: [^ nil].

	^ ToolIcons iconNamed: (ToolIcons
		iconForClass: self selectedClassOrMetaClass
		selector: aSelector)
]

{ #category : #'message list' }
Browser >> messageIconHelpFor: aSelector [

	self class showMessageIcons ifFalse: [^ String empty].

	^ ToolIconHelp iconHelpNamed: (ToolIcons
		iconForClass: self selectedClassOrMetaClass
		selector: aSelector)
]

{ #category : #'message list' }
Browser >> messageList [
	"Answer an Array of the message selectors of the currently selected message category. If no category is selected or the '-- all --' category is selected, return all method selectors. Make deprecated messages look gray and struck-out."
	

	^ (self selectedMessageCategoryName isNil or: [self selectedMessageCategoryName = ClassOrganizer allCategory])
		ifTrue: [
			self classOrMetaClassOrganizer
				ifNil: [Array new]
				ifNotNil: [:organizer | organizer allMethodSelectors collect: [:ea |
					self formattedLabel: ea]]]
		ifFalse: [
			(self classOrMetaClassOrganizer listAtCategoryNamed: self selectedMessageCategoryName)
				collect: [:ea | self formattedLabel: ea]]
]

{ #category : #'message list' }
Browser >> messageListIndex [
	"Answer the index of the selected message selector into the currently 
	selected message category."

	^ self messageListIndexOf: self selectedMessageName
]

{ #category : #'message list' }
Browser >> messageListIndex: anInteger [
	"Set the selected message selector to be the one indexed by anInteger."

	self selectMessageNamed: (self messageList at: anInteger ifPresent: [:lbl | lbl asString] ifAbsent: [nil] )
]

{ #category : #'message list' }
Browser >> messageListIndexOf: aString [
	^ self messageList indexOf: aString.
]

{ #category : #'message list' }
Browser >> messageListMenu: aMenu shifted: shifted [ 
	"Answer the message-list menu"
	^ self menu: aMenu for: #(messageListMenu messageListMenuShifted:) shifted: shifted

]

{ #category : #'pluggable menus - hooks' }
Browser >> messageListMenuHook: aMenu shifted: aBoolean [
	<messageListMenu>
	<menuPriority: 400>
	^ self menuHook: aMenu named: #messageListMenu shifted: aBoolean.

]

{ #category : #metaclass }
Browser >> metaClassIndicated [
	"Answer the boolean flag that indicates which of the method dictionaries, 
	class or metaclass."

	^ metaClassIndicated
]

{ #category : #metaclass }
Browser >> metaClassIndicated: trueOrFalse [ 
	"Indicate whether browsing instance or class messages."

	metaClassIndicated := trueOrFalse.
	self setClassOrganizer.
	self hasSystemCategorySelected ifTrue:
		[self editSelection: (self hasClassSelected
			ifFalse: [metaClassIndicated
				ifTrue: [#none]
				ifFalse: [#newClass]]
			ifTrue: [#editClass])].
	selectedMessageCategoryName := nil.
	selectedMessageName := nil.
	contents := nil.
	self changed: #classSelectionChanged.
	self changed: #messageCategoryList.
	self changed: #messageList.
	self changed: #contents.
	self changed: #annotation.
	self decorateButtons

]

{ #category : #'initialize-release' }
Browser >> methodCategoryChanged [
	self changed: #messageCategoryList.
	self changed: #messageList.
	self changed: #annotation.
	self messageListIndex: 0
]

{ #category : #'multi-window support' }
Browser >> multiWindowName [
	"Answer the string to display for the receiver in a multi-window."
	^String streamContents:
		[:s| | str |
		self selectedClass
			ifNil: [s nextPut: $a; space; nextPutAll: self defaultBrowserTitle]
			ifNotNil:
				[s print: self selectedClass.
				 self metaClassIndicated ifTrue:
					[s nextPutAll: ' class'].
				  self isHierarchy ifTrue:
					[s space; nextPutAll: ' Hierarchy']].
		(str := self selectedMessageName) notNil
			ifTrue: [s nextPutAll: '>>'; nextPutAll: str]
			ifFalse:
				[(str := self selectedMessageCategoryName) notNil
					ifTrue: [s space; nextPut: ${; nextPutAll: str; nextPut: $}]]]
]

{ #category : #'multi-window support' }
Browser >> multiWindowNameForState: savedStateMessage [
	"Answer the string to display for the receiver in a multi-window."
	| getarg |
	getarg := [:keyword| savedStateMessage arguments at: (savedStateMessage selector keywords indexOf: keyword)].
	^String streamContents:
		[:s|
		(getarg value: 'className:')
			ifNil: [(getarg value: 'restoreToCategory:')
					ifNil: [s nextPut: $a; space; nextPutAll: self defaultBrowserTitle]
					ifNotNil: [:categoryName| s nextPutAll: categoryName]]
			ifNotNil:
				[:className|
				s nextPutAll: className.
				(getarg value: 'meta:') ifTrue:
					[s nextPutAll: ' class'].
				  self isHierarchy ifTrue:
					[s space; nextPutAll: ' Hierarchy'].
				(getarg value: 'selector:')
					ifNil: [(getarg value: 'protocol:') ifNotNil:
							[:protocol| s space; nextPut: ${; nextPutAll: protocol; nextPut: $}]]
					ifNotNil: [:selector| s nextPutAll: '>>'; nextPutAll: selector]]]
]

{ #category : #traits }
Browser >> newClass [
	(self selectedClassOrMetaClass notNil and: 
		[self selectedClassOrMetaClass isTrait]) ifTrue: [self classListIndex: 0].
	self editClass.
	editSelection := #newClass.
	self contentsChanged
]

{ #category : #accessing }
Browser >> newClassContents [
	| theClassName |
	^ (theClassName := self selectedClassName)
		ifNil:
			[Class template: self selectedSystemCategory]
		ifNotNil:
			[Class templateForSubclassOf: theClassName asString category: self selectedSystemCategory]
]

{ #category : #traits }
Browser >> newTrait [
	self classListIndex: 0.
	self editClass.
	editSelection := #newTrait.
	self contentsChanged
]

{ #category : #'class comment pane' }
Browser >> noCommentNagString [

	^ Text
		string: 'THIS CLASS HAS NO COMMENT!' translated
		attribute: (TextColor color: (self userInterfaceTheme noClassCommentColor ifNil: [Color red]))
]

{ #category : #accessing }
Browser >> noteSelectionIndex: anInteger for: aSymbol [
	aSymbol == #systemCategoryList
		ifTrue:
			[self systemCategoryListIndex: anInteger].
	aSymbol == #classList
		ifTrue:
			[self classListIndex: anInteger].
	aSymbol == #messageCategoryList
		ifTrue:
			[self messageCategoryListIndex: anInteger].
	aSymbol == #messageList
		ifTrue:
			[self messageListIndex: anInteger].
]

{ #category : #'multi-window support' }
Browser >> okToClose [
	^super okToClose
	  and: [self multiWindowState isNil or: [self multiWindowState okToClose]]
]

{ #category : #'class functions' }
Browser >> plusButtonHit [
	"Cycle among definition, comment, and hierachy"

	editSelection == #editComment ifTrue: [
		self hierarchy.
		self decorateButtons.
		^ self].
	
	editSelection == #hierarchy ifTrue: [
		self editSelection: #editClass.
		(self hasClassSelected and: [self okToChange]) ifTrue: [
			self changed: #editComment.
			self contentsChanged].
		self decorateButtons.
		^ self].
	
	self editComment.
	self decorateButtons.
]

{ #category : #'class functions' }
Browser >> printOutClass [
	"Print a description of the selected class onto a file whose name is the 
	category name followed by .html."

Cursor write showWhile:
		[self hasClassSelected ifTrue: [self selectedClass fileOutAsHtml: true]]
]

{ #category : #'message category functions' }
Browser >> printOutMessageCategories [
	"Print a description of the selected message category of the selected class 
	onto an external file in Html format."

Cursor write showWhile:
	[self hasMessageCategorySelected
		ifTrue: 
			[self selectedClassOrMetaClass fileOutCategory: self selectedMessageCategoryName
										asHtml: true]]
]

{ #category : #'system category functions' }
Browser >> printOutSystemCategory [
	"Print a description of each class in the selected category as Html."

Cursor write showWhile:
	[self hasSystemCategorySelected
		ifTrue: [systemOrganizer fileOutCategory: self selectedSystemCategory
								asHtml: true ]]

]

{ #category : #'message category list' }
Browser >> rawMessageCategoryList [
	^ self hasClassSelected
		ifTrue: [self classOrMetaClassOrganizer categories]
		ifFalse: [Array new]
]

{ #category : #'message category list' }
Browser >> recategorizeMethodSelector: sel [ 
	"Categorize method named sel by looking in parent classes for a 
	method category. 
	Answer true if recategorized."
	self selectedClassOrMetaClass allSuperclasses
		do: [:ea | 
			| thisCat |
			thisCat := ea organization categoryOfElement: sel.
			(thisCat ~= ClassOrganizer default
					and: [thisCat notNil])
				ifTrue: [self classOrMetaClassOrganizer classify: sel under: thisCat logged: true.
					self changed: #messageCategoryList.
					^ true]].
	^ false
]

{ #category : #'class list' }
Browser >> recent [
	"Let the user select from a list of recently visited classes.  11/96 stp.
	 12/96 di:  use class name, not classes themselves.
	 : dont fall into debugger in empty case"

	| className class recentList |
	recentList := (RecentClasses reject: [:s | s = self selectedClassName]) select: [:n | Smalltalk hasClassNamed: n].
	recentList size = 0 ifTrue: [^ Beeper beep].
	className := UIManager default chooseFrom: recentList values: recentList.
	className == nil ifTrue: [^ self].
	
	self okToChange ifFalse: [^ self].

	class := Smalltalk at: className.
	self selectCategoryForClass: class.
	self classListIndex: (self classListIndexOf: class name)
]

{ #category : #'message list' }
Browser >> reformulateList [
	"If the receiver has a way of reformulating its message list, here is a chance for it to do so"
	super reformulateList.
	(self messageList includes: self selectedMessageName)
		ifFalse: [ self messageList
					ifEmpty: [ self selectMessageNamed: nil ]
					ifNotEmpty: [ self selectMessageNamed: self lastMessageName ]].
]

{ #category : #'class functions' }
Browser >> removeClass [
	"If the user confirms the wish to delete the class, do so"

	super removeClass ifTrue:
		[self classListIndex: 0]
]

{ #category : #'message category functions' }
Browser >> removeEmptyCategories [
	self okToChange ifFalse: [^ self].
	self selectedClassOrMetaClass organization removeEmptyCategories.
	self changed: #messageCategoryList

]

{ #category : #'message functions' }
Browser >> removeMessage [
	"If a message is selected, create a Confirmer so the user can verify that  
	the currently selected message should be removed from the system. If 
	so,  
	remove it. If the Preference 'confirmMethodRemoves' is set to false, the 
	confirmer is bypassed."
	| messageName confirmation |
	self hasMessageSelected not
		ifTrue: [^ self].
	self okToChange
		ifFalse: [^ self].
	messageName := self selectedMessageName.
	confirmation := self systemNavigation   confirmRemovalOf: messageName on: self selectedClassOrMetaClass.
	confirmation = 3
		ifTrue: [^ self].
	self selectedClassOrMetaClass removeSelector: messageName.
	self selectMessageNamed: nil.
	self changed: #messageList.
	self setClassOrganizer.
	"In case organization not cached"
	confirmation = 2
		ifTrue: [self systemNavigation browseAllCallsOn: messageName]
]

{ #category : #'message category functions' }
Browser >> removeMessageCategory [
	"If a message category is selected, create a Confirmer so the user can 
	verify that the currently selected message category should be removed
 	from the system. If so, remove it."

	| messageCategoryName |
	self hasMessageCategorySelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	messageCategoryName := self selectedMessageCategoryName.
	(self messageList size = 0
		or: [self confirm: 'Are you sure you want to
remove this method category 
and all its methods?'])
		ifTrue: 
			[self selectedClassOrMetaClass removeCategory: messageCategoryName.
			self selectMessageCategoryNamed: nil.
			self changed: #classSelectionChanged].
	self changed: #messageCategoryList.

]

{ #category : #'message functions' }
Browser >> removeMessageFromBrowser [
	"Our list speaks the truth and can't have arbitrary things removed"

	^ self changed: #flash
]

{ #category : #'system category functions' }
Browser >> removeSystemCategory [
	"If a class category is selected, create a Confirmer so the user can 
	verify that the currently selected class category and all of its classes
 	should be removed from the system. If so, remove it."

	self hasSystemCategorySelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	(self classList size = 0
		or: [self confirm: 'Are you sure you want to
remove this system category 
and all its classes?'])
		ifTrue: 
		[| nextSelectedCat |
		nextSelectedCat := self systemCategoryList before: self selectedSystemCategory ifAbsent: [nil].
		systemOrganizer removeSystemCategory: self selectedSystemCategory.
		self selectSystemCategory: nextSelectedCat.
		self changed: #systemCategoryList]
]

{ #category : #'message category functions' }
Browser >> renameCategory [
	"Prompt for a new category name and add it before the
	current selection, or at the end if no current selection"
	| oldName newName |
	self hasClassSelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	self hasMessageCategorySelected ifFalse: [^ self].
		
	oldName := self selectedMessageCategoryName.
	newName := self
		request: 'Please type new category name'
		initialAnswer: oldName.
	newName isEmpty
		ifTrue: [^ self]
		ifFalse: [newName := newName asSymbol].
	newName = oldName ifTrue: [^ self].
	self classOrMetaClassOrganizer
		renameCategory: oldName
		toBe: newName.
	self selectClassNamed: selectedClassName.
	self selectMessageCategoryNamed: newName.
	self changed: #messageCategoryList.

]

{ #category : #'class functions' }
Browser >> renameClass [
	| oldName newName obs oldBinding |
	self hasClassSelected ifFalse: [^ self].
	self okToChange
		ifFalse: [^ self].
	oldName := self selectedClass name.
	newName := self request: 'Please type new class name' initialAnswer: oldName.
	newName = ''
		ifTrue: [^ self].
	"Cancel returns ''"
	newName := newName asSymbol.
	newName = oldName
		ifTrue: [^ self].
	(self selectedClass environment includesKey: newName)
		ifTrue: [^ self error: newName , ' already exists'].
	oldBinding := self selectedClass environment declarationOf: oldName.
	[self selectedClass rename: newName]
		on: RemarkNotification
		do: [:ex | self inform: ex messageText. ex resume].
	selectedClassName := newName.
	self changed: #classList.
	obs := self systemNavigation allCallsOn: oldBinding.
	obs isEmpty
		ifFalse: [self systemNavigation
				browseMessageList: obs
				name: 'Obsolete References to ' , oldName
				autoSelect: oldName].
	self selectClassNamed: newName.
]

{ #category : #'system category functions' }
Browser >> renameSystemCategory [
	"Prompt for a new category name and add it before the
	current selection, or at the end if no current selection"
	| oldSelection newName |
	oldSelection := self selectedSystemCategory.
	oldSelection isNil
		ifTrue: [^ self].  "no selection"
	self okToChange ifFalse: [^ self].
	
	newName := self
		request: 'Please type new category name'
		initialAnswer: oldSelection.
	newName isEmpty
		ifTrue: [^ self]
		ifFalse: [newName := newName asSymbol].
	oldSelection = newName ifTrue: [^ self].
	systemOrganizer
		renameCategory: oldSelection
		toBe: newName.
	self selectSystemCategory: newName.
	self changed: #systemCategoryList.
]

{ #category : #accessing }
Browser >> request: prompt initialAnswer: initialAnswer [

	^ UIManager default
		request: prompt
		initialAnswer: initialAnswer

]

{ #category : #'multi-window support' }
Browser >> restoreMultiWindowState: aMessage [
	"Restore the state after a multi-window switch.."
	aMessage sentTo: self
]

{ #category : #'multi-window support' }
Browser >> restoreToCategory: category className: className protocol: protocol selector: selector mode: editMode meta: metaBool [
	selectedSystemCategory := nil. "forces recomputation in selectSystemCategory:"
	self selectSystemCategory: category.
	self selectClassNamed: className.
	self metaClassIndicated: metaBool.
	self selectMessageCategoryNamed: protocol.
	self selectMessageNamed: selector.
	editSelection := editMode.
	self
		contentsChanged;
		decorateButtons
]

{ #category : #'multi-window support' }
Browser >> saveMultiWindowState [
	^Message
		selector: #restoreToCategory:className:protocol:selector:mode:meta:
		arguments: {	self selectedSystemCategory.
						self selectedClassName.
						self selectedMessageCategoryName.
						self selectedMessageName.
						self editSelection.
						self metaClassIndicated }
]

{ #category : #'system category list' }
Browser >> selectCategoryForClass: theClass [
	self selectSystemCategory: theClass category.
]

{ #category : #'class list' }
Browser >> selectClass: classNotMeta [
	^ self selectClassNamed:
		(classNotMeta
			ifNil: [ nil ]
			ifNotNil: [ classNotMeta name ]).
]

{ #category : #'class list' }
Browser >> selectClassNamed: aSymbolOrString [
	| className currentMessageCategoryName currentMessageName |

	currentMessageCategoryName := [self selectedMessageCategoryName]
										on: Error
										do: [:ex| ex return: nil].
	currentMessageName := [self selectedMessageName]
								on: Error
								do: [:ex| ex return: nil].
								
	selectedClassName := aSymbolOrString ifNotNil: [ aSymbolOrString asSymbol ].
	self setClassOrganizer.
	self setClassDefinition.

	"Try to reselect the category and/or selector if the new class has them."
	selectedMessageCategoryName :=(self messageCategoryList includes: currentMessageCategoryName)
		ifTrue: [currentMessageCategoryName]
		ifFalse: [nil].
	selectedMessageName := (self messageList includes: currentMessageName)
		ifTrue: [currentMessageName]
		ifFalse: [nil].

	self hasMessageSelected ifTrue:
		[self editSelection: #editMessage] ifFalse:
	[self hasMessageCategorySelected ifTrue:
		[self editSelection: #newMessage] ifFalse:
	[self classCommentIndicated
		ifTrue: [self editSelection: #editComment]
		ifFalse: [self editSelection: (self hasClassSelected not
					ifTrue: [(metaClassIndicated or: [ self hasSystemCategorySelected not ])
						ifTrue: [#none]
						ifFalse: [#newClass]]
					ifFalse: [#editClass])]]].
	contents := nil.
	self selectedClass isNil
		ifFalse: [className := self selectedClass name.
					(RecentClasses includes: className)
				ifTrue: [RecentClasses remove: className].
			RecentClasses addFirst: className.
			RecentClasses size > 16
				ifTrue: [RecentClasses removeLast]].
	self changed: #classSelectionChanged.
	self changed: #classCommentText.
	self changed: #classListIndex.	"update my selection"
	self changed: #messageCategoryList.
	self changed: #messageList.
	self changed: #relabel.
	self changed: #selectedSystemCategoryName.
	self contentsChanged
]

{ #category : #accessing }
Browser >> selectEnvironment: anEnvironment [ 
	environment := anEnvironment.
	systemOrganizer := environment organization
]

{ #category : #'message category list' }
Browser >> selectMessageCategoryNamed: aSymbol [ 
	"Given aSymbol, select the category with that name.  Do nothing if 
	aSymbol doesn't exist."
	
	selectedMessageCategoryName := aSymbol.
	selectedMessageName := nil.
	
	self changed: #messageCategorySelectionChanged.
	self changed: #messageCategoryListIndex. "update my selection"
	self changed: #messageList.
	self changed: #messageListIndex.
	
	self editSelection: (aSymbol notNil
		ifTrue: [#newMessage]
		ifFalse: [self hasClassSelected
			ifTrue: [#editClass]
			ifFalse: [#newClass]]).
	contents := nil.
	self contentsChanged.
]

{ #category : #'message list' }
Browser >> selectMessageNamed: aSymbolOrString [
	| name |
	name := aSymbolOrString ifNotNil: [ aSymbolOrString asSymbol ].
	selectedMessageName := name.

	self editSelection: (name notNil
		ifTrue: [#editMessage]
		ifFalse: [self messageCategoryListIndex > 0
			ifTrue: [#newMessage]
			ifFalse: [self hasClassSelected
				ifTrue: [#editClass]
				ifFalse: [#newClass]]]).
	contents := nil.
	self changed: #messageListIndex. "update my selection"
	self contentsChanged.
	self decorateButtons.
]

{ #category : #'system category list' }
Browser >> selectSystemCategory: aSymbol [
	"Set the selected system category. Update all other selections to be deselected."
	aSymbol = selectedSystemCategory ifTrue: [^ self].
	selectedSystemCategory := aSymbol.
	selectedClassName := nil.
	selectedMessageCategoryName := nil.
	selectedMessageName := nil.
	self editSelection: ( aSymbol isNil ifTrue: [#none] ifFalse: [#newClass]).
	self metaClassIndicated: false.
	self setClassOrganizer.
	contents := nil.
	
	self 
		changed: #systemCategorySelectionChanged;
		changed: #systemCategoryListIndex;	"update my selection"
		changed: #classList;
		changed: #messageCategoryList;
		changed: #messageList;
		changed: #relabel.

	self 
		decorateButtons;
		contentsChanged
]

{ #category : #'class list' }
Browser >> selectedClass [
	"Answer the class that is currently selected. Answer nil if no selection 
	exists."

	| name envt |
	(name := self selectedClassName) ifNil: [^ nil].
	(envt := self selectedEnvironment) ifNil: [^ nil].
	^ envt at: name ifAbsent: [envt valueOf: name ifAbsent: [nil]]
]

{ #category : #'class list' }
Browser >> selectedClassName [
	^ selectedClassName.
]

{ #category : #metaclass }
Browser >> selectedClassOrMetaClass [
	"Answer the selected class/trait or metaclass/classTrait."

	| cls |
	^self metaClassIndicated
		ifTrue: [(cls := self selectedClass) ifNil: [nil] ifNotNil: [cls classSide]]
		ifFalse: [self selectedClass]
]

{ #category : #metaclass }
Browser >> selectedClassOrMetaClassName [
	"Answer the selected class name or metaclass name."

	^self selectedClassOrMetaClass name
]

{ #category : #'system category list' }
Browser >> selectedEnvironment [
	"Answer the browsed environment. If this returned a system category dependent
	value and possibly nil (as it did in previous versions), selectedClass would not work in
	a hierarchy browser that has to display classes from different environments
	(because the correct categories might be missing in the browser)"

	^ environment ifNil: [Smalltalk globals]
]

{ #category : #'message list' }
Browser >> selectedMessage [
	"Answer a copy of the source code for the selected message."

	| class selector method |
	contents == nil ifFalse: [^ contents copy].

	self showingDecompile ifTrue:
		[^ self decompiledSourceIntoContents].

	class := self selectedClassOrMetaClass.
	selector := self selectedMessageName.
	method := class compiledMethodAt: selector ifAbsent: [^ ''].	"method deleted while in another project"
	currentCompiledMethod := method.

	^ contents := (self showingDocumentation
		ifFalse: [ self sourceStringPrettifiedAndDiffed ]
		ifTrue: [ self commentContents ])
			copy asText makeSelectorBoldIn: class
]

{ #category : #'message category list' }
Browser >> selectedMessageCategoryName [
	"Answer the name of the selected message category, if any. Answer nil 
	otherwise."

	^ selectedMessageCategoryName
]

{ #category : #'message list' }
Browser >> selectedMessageName [
	"Answer the message selector of the currently selected message, if any. 
	Answer nil otherwise."

	^ selectedMessageName.
]

{ #category : #'message list' }
Browser >> selectedMessageName: aSelector [
	"Make the given selector be the selected message name"

	| anIndex |
	anIndex := self messageList indexOf: aSelector.
	anIndex > 0 ifTrue:
		[self messageListIndex: anIndex].
	self changed: #selectedMessageName. "inform interested parties"
]

{ #category : #'system category list' }
Browser >> selectedSystemCategory [
	^ selectedSystemCategory
]

{ #category : #'system category list' }
Browser >> selectedSystemCategoryName [
	"Answer the name of the selected system category or nil."

	^ self selectedSystemCategory.
]

{ #category : #'initialize-release' }
Browser >> setClass: aBehavior [
	"Set the state of a new, uninitialized Browser."

	| isMeta aClass |
	aBehavior ifNil: [^ self].
	(aBehavior isKindOf: Metaclass)
		ifTrue: [
			isMeta := true.
			aClass := aBehavior soleInstance]
		ifFalse: [
			isMeta := false.
			aClass := aBehavior].
		
	self
		selectEnvironment: aClass environment;
		selectCategoryForClass: aClass;
		classListIndex: (self classListIndexOf: aClass name);
		metaClassIndicated: isMeta.
]

{ #category : #'initialize-release' }
Browser >> setClass: aBehavior selector: aSymbol [
	"Set the state of a new, uninitialized Browser."

	aBehavior ifNil: [^ self].

	self
		setClass: aBehavior;	
		setSelector: aSymbol.
]

{ #category : #metaclass }
Browser >> setClassDefinition [
	"Remember the current class definition."
	
	| theClass |
	classDefinition := nil.
	metaClassDefinition := nil.
	self hasClassSelected ifFalse: [^ self].
	theClass := self selectedClass ifNil: [ ^self ].
	classDefinition := theClass definition.
	metaClassDefinition := theClass theMetaClass definition.
]

{ #category : #metaclass }
Browser >> setClassOrganizer [
	"Install whatever organization is appropriate"
	| theClass |
	classOrganizer := nil.
	metaClassOrganizer := nil.
	self hasClassSelected ifFalse: [^ self].
	theClass := self selectedClass ifNil: [ ^self ].
	classOrganizer := theClass organization.
	metaClassOrganizer := theClass classSide organization.
]

{ #category : #toolbuilder }
Browser >> setMultiWindowFor: windowSpec [
	"set the multi-window style for the windowSpec according to both the users preference and the browser's ability"
	(self class canUseMultiWindowBrowsers and: [self class useMultiWindowBrowsers])
		ifTrue: [windowSpec multiWindowStyle: #labelButton].


]

{ #category : #'message category list' }
Browser >> setOriginalCategoryIndexForCurrentMethod [
	"private - Set the message category index for the currently selected method. 
	 
	 Note:  This should only be called when somebody tries to save  
	 a method that they are modifying while ALL is selected."

	selectedMessageCategoryName := self categoryOfCurrentMethod.
]

{ #category : #'initialize-release' }
Browser >> setSelector: aSymbol [
	"Make the receiver point at the given selector, in the currently chosen class. If the selector is found in the class organization we also set the message category to suit"

	| aClass |
	aSymbol ifNil: [^ self].
	(aClass := self selectedClassOrMetaClass) ifNil: [^ self].
	(aClass organization categoryOfElement: aSymbol)
		ifNil: [^ self]
		ifNotNil: [:category |
			self
				selectMessageCategoryNamed: category;
				selectMessageNamed: aSymbol].
]

{ #category : #'class functions' }
Browser >> shiftedClassListMenu: aMenu [
	<classListMenuShifted: true>
	"Set up the menu to apply to the receiver's class list when the shift key is down"
	^ aMenu
		addList: #(
			-
			('local senders...'			browseLocalSenders	'browse senders local to this class')
			('unsent methods'			browseUnusedMethods	'browse all methods defined by this class that have no senders')
			('unreferenced inst vars'	showUnreferencedInstVars	'show a list of all instance variables that are not referenced in methods')
			('unreferenced class vars'	showUnreferencedClassVars	'show a list of all class variables that are not referenced in methods')
			('subclass template'			makeNewSubclass		'put a template into the code pane for defining of a subclass of this class')
			-
			('sample instance'			makeSampleInstance		'give me a sample instance of this class, if possible')
			('inspect instances'			inspectInstances			'open an inspector on all the extant instances of this class')
			('inspect subinstances'		inspectSubInstances		'open an inspector on all the extant instances of this class and of all of its subclasses')
			-
			('add all meths to current chgs'		addAllMethodsToCurrentChangeSet
																'place all the methods defined by this class into the current change set')
			('create inst var accessors'	createInstVarAccessors	'compile instance-variable access methods for any instance variables that do not yet have them'));
		yourself
]

{ #category : #'class functions' }
Browser >> shiftedClassListMenuMore: aMenu [
	" The 'more..' link that toggles between unshifted and shifted menus
	in class lists "
	<classListMenuShifted: true>
	<menuPriority: 1000>
	^ aMenu addList: #(-
			('more...' offerUnshiftedClassListMenu 'return to the standard class-list menu'));
		yourself
]

{ #category : #'message list' }
Browser >> shiftedMessageListMenu: aMenu [
	<messageListMenuShifted: true>
	"Fill aMenu with the items appropriate when the shift key is held down"

	aMenu addStayUpItem.
	aMenu addList: #(
		('toggle diffing (D)'						toggleDiffing)
		('implementors of sent messages'			browseAllMessages)
		-
		('local senders of...'						browseLocalSendersOfMessages)
		('local implementors of...'				browseLocalImplementors)
		-
		('spawn sub-protocol'					spawnProtocol)
		('spawn full protocol'					spawnFullProtocol)
		-
		('sample instance'						makeSampleInstance)
		('inspect instances'						inspectInstances)
		('inspect subinstances'					inspectSubInstances)).

	self addExtraShiftedItemsTo: aMenu.
	aMenu addList: #(
		-
		('change category...'					changeCategory)).

	self canShowMultipleMessageCategories ifTrue: [aMenu addList:
		 #(('toggle category selection (Y)'						showHomeCategory))].
	aMenu addList: #(
		-
		('change sets with this method'			findMethodInChangeSets)
		('revert to previous version'				revertToPreviousVersion)
		('remove from current change set'		removeFromCurrentChanges)
		('revert & remove from changes'		revertAndForget)
		('add to current change set'				adoptMessageInCurrentChangeset)
		('copy up or copy down...'				copyUpOrCopyDown)).
	^ aMenu

]

{ #category : #'code pane' }
Browser >> showBytecodes [
	"Show or hide the bytecodes of the selected method -- an older protocol now mostly not relevant."

	self toggleShowingByteCodes
]

{ #category : #'message category functions' }
Browser >> showHomeCategory [
	"Select the category of the currently-selected method.  If it is already selected, or if no method is selected, deselect it to unfilter the message list."
	self okToChange ifTrue:
		[ | aSelector | ((aSelector := self selectedMessageName) notNil or: [ selectedMessageCategoryName notNil ]) ifTrue:
			[ aSelector
				ifNil: [ self selectMessageCategoryNamed: nil ]
				ifNotNil: [ self toggleCategorySelectionForCurrentMethod ].
			self selectedMessageName: aSelector ] ]
]

{ #category : #accessing }
Browser >> spawn: aString [ 
	"Create and schedule a fresh browser and place aString in its code pane.  This method is called when the user issues the #spawn command (cmd-o) in any code pane.  Whatever text was in the original code pane comes in to this method as the aString argument; the changes in the original code pane have already been cancelled by the time this method is called, so aString is the only copy of what the user had in his code pane."

	self selectedClassOrMetaClass ifNotNil: [^ super spawn: aString].

	self hasSystemCategorySelected ifTrue:
		["Open a browser with the initial codepane string set"
		^ self buildSystemCategoryBrowserEditString: aString].
		
	^ super spawn: aString  
	"This bail-out at least saves the text being spawned, which would otherwise be lost"
]

{ #category : #private }
Browser >> spawnOrNavigateTo: aClass [
	self setClass: aClass selector: nil
]

{ #category : #'class comment pane' }
Browser >> stripNaggingAttributeFromComment: aText [
	^aText removeAttribute: TextColor red from: 1 to: aText size
]

{ #category : #accessing }
Browser >> suggestCategoryToSpawnedBrowser: aBrowser [
	"aBrowser is a message-category browser being spawned from the receiver.  Tell it what it needs to know to get its category info properly set up."

	(self isMemberOf: Browser) "yecch, but I didn't invent the browser hierarchy"
		ifTrue:
			[aBrowser messageCategoryListIndex: (self messageCategoryList indexOf: self categoryOfCurrentMethod ifAbsent: [2])]
		ifFalse:
			[aBrowser setOriginalCategoryIndexForCurrentMethod]
]

{ #category : #'initialize-release' }
Browser >> switchesFrame: bottomFraction [
	^self switchesFrame: bottomFraction fromLeft: 0.25 width: 0.25.
]

{ #category : #'initialize-release' }
Browser >> switchesFrame: bottomFraction fromLeft: leftFraction width: rightFraction [
	^LayoutFrame new
		leftFraction: leftFraction offset: 0;
		topFraction: bottomFraction offset: self buttonHeight negated;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: bottomFraction offset: 0
]

{ #category : #'system category list' }
Browser >> systemCatListKey: aChar from: view [
	"Respond to a Command key.  I am a model with a code pane, and I also have a listView that has a list of methods.  The view knows how to get the list and selection."

	aChar == $f ifTrue: [^ self findClass].
	aChar == $x ifTrue: [^ self removeSystemCategory].
	aChar == $b ifTrue: [^ self recent].
	^ self classListKey: aChar from: view
]

{ #category : #'initialize-release' }
Browser >> systemCatSingletonKey: aChar from: aView [
	^ self messageListKey: aChar from: aView
]

{ #category : #'system category functions' }
Browser >> systemCatSingletonMenu: aMenu [

	^ aMenu labels:
'browse all
browse
printOut
fileOut
update
rename...
remove' 
	lines: #(2 4)
	selections:
		#(browseAllClasses buildSystemCategoryBrowser
		printOutSystemCategory fileOutSystemCategory updateSystemCategories
		renameSystemCategory removeSystemCategory)

]

{ #category : #'system category list' }
Browser >> systemCategoryList [
	"Answer the class categories modelled by the receiver."

	^ {SystemOrganizer allCategory},  systemOrganizer categories
]

{ #category : #'system category list' }
Browser >> systemCategoryListIndex [
	"Answer the index of the selected class category."

	^ self systemCategoryList indexOf: self selectedSystemCategory.
]

{ #category : #'system category list' }
Browser >> systemCategoryListIndex: anInteger [ 
	"Set the selected system category index to be anInteger. Update all other 
	selections to be deselected."
	
	self selectSystemCategory: (self systemCategoryList at: anInteger ifAbsent: [ nil ])
]

{ #category : #'system category functions' }
Browser >> systemCategoryMenu: aMenu [
	^ self menu: aMenu for: #(systemCategoryMenu systemCategoryMenuShifted:)

]

{ #category : #'pluggable menus - hooks' }
Browser >> systemCategoryMenuHook: aMenu shifted: aBoolean [
	<systemCategoryMenu>
	<menuPriority: 400>
	^ self menuHook: aMenu named: #systemCategoryMenu shifted: aBoolean.

]

{ #category : #'system category list' }
Browser >> systemCategorySingleton [

	| cat |
	cat := self selectedSystemCategory.
	^ cat ifNil: [Array new]
		ifNotNil: [Array with: cat]
]

{ #category : #'initialize-release' }
Browser >> systemOrganizer: aSystemOrganizer [
	"Initialize the receiver as a perspective on the system organizer, 
	aSystemOrganizer. Typically there is only one--the system variable 
	SystemOrganization."
	
	contents := nil.
	systemOrganizer := aSystemOrganizer.
	selectedSystemCategory := nil.
	selectedMessageCategoryName := nil.
	selectedClassName := nil.
	selectedMessageName := nil.
	metaClassIndicated := false.
	self setClassOrganizer.
	self editSelection: #none.
]

{ #category : #'message category list' }
Browser >> toggleCategorySelectionForCurrentMethod [
	| methodCategory selectorName |
	methodCategory := self categoryOfCurrentMethod.
	selectorName := self selectedMessageName.
	(methodCategory notNil and:
		[ methodCategory ~= ClassOrganizer allCategory and: [ methodCategory ~= selectedMessageCategoryName ] ])
		ifTrue:
			[ selectedMessageCategoryName := methodCategory.
			selectedMessageName := selectorName.
			self changed: #messageCategorySelectionChanged.
			self changed: #messageCategoryListIndex.
			"update my selection"
			self changed: #messageList.
			self changed: #messageListIndex ]
		ifFalse:
			[ methodCategory = selectedMessageCategoryName ifTrue:
				[ selectedMessageCategoryName := nil.
				self
					 changed: #messageCategorySelectionChanged ;
					 changed: #messageCategoryListIndex ;
					 changed: #messageList ] ]
]

{ #category : #'initialize-release' }
Browser >> topConstantHeightFrame: height fromLeft: leftFraction width: rightFraction [
	^LayoutFrame new
		topFraction: 0 offset: 0;
		leftFraction: leftFraction offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: 0 offset: height;
		yourself.
]

{ #category : #'system category functions' }
Browser >> updateSystemCategories [
	"The class categories were changed in another browser. The receiver must 
	reorganize its lists based on these changes."

	self okToChange ifFalse: [^ self].
	self changed: #systemCategoryList
]

{ #category : #copying }
Browser >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"systemOrganizer := systemOrganizer. 	clone has the old value. we share it"
"classOrganizer := classOrganizer		clone has the old value. we share it"
"metaClassOrganizer 	:= metaClassOrganizer	clone has the old value. we share it"
selectedSystemCategory := selectedSystemCategory veryDeepCopyWith: deepCopier.
selectedClassName := selectedClassName veryDeepCopyWith: deepCopier.
selectedMessageCategoryName := selectedMessageCategoryName veryDeepCopyWith: deepCopier.
selectedMessageName := selectedMessageName veryDeepCopyWith: deepCopier.
editSelection := editSelection veryDeepCopyWith: deepCopier.
metaClassIndicated := metaClassIndicated veryDeepCopyWith: deepCopier.

]

{ #category : #'drag and drop' }
Browser >> wantsMessageCategoriesDrop: anObject [
	"Only accept drops of compiled methods on system categories"
	^anObject isKindOf: CompiledMethod
]

{ #category : #'drag and drop' }
Browser >> wantsSystemCategoriesDrop: anObject [
	"Only accept drops of behaviors on system categories"
	^anObject isBehavior
]
