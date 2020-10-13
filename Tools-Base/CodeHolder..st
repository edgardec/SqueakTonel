"
An ancestor class for all models which can show code.  Eventually, much of the code that currently resides in StringHolder which only applies to code-holding StringHolders might get moved down here.
"
Class {
	#name : #CodeHolder,
	#superclass : #StringHolder,
	#instVars : [
		'currentCompiledMethod',
		'contentsSymbol',
		'multiWindowState'
	],
	#classVars : [
		'ContentsSymbolQuints',
		'EditContentsOptions',
		'MultiWindowBrowsers'
	],
	#category : #'Tools-Base'
}

{ #category : #controls }
CodeHolder class >> addContentsSymbolQuint: quint afterEntry: aSymbol [ 
	"Register a menu selection item in the position after the entry with
	selection symbol aSymbol."

	"CodeHolder
		addContentsSymbolQuint: #(#altSyntax #toggleAltSyntax #showingAltSyntaxString 'altSyntax' 'alternative syntax')
		afterEntry: #colorPrint"

	(ContentsSymbolQuints
		anySatisfy: [:e | (e isKindOf: Collection) and: [e first = quint first]])
		ifFalse: [
			| entry |
			entry := ContentsSymbolQuints
						detect: [:e | (e isKindOf: Collection) and: [e first = aSymbol]].
			ContentsSymbolQuints add: quint after: entry.
			^ self].
	self notify: 'entry already exists for ', quint first
]

{ #category : #controls }
CodeHolder class >> addContentsSymbolQuint: quint afterPosition: index [
	"Register a menu selection item in the position after index."

	"CodeHolder
		addContentsSymbolQuint: #(#altSyntax #toggleAltSyntax #showingAltSyntaxString 'altSyntax' 'alternative syntax')
		afterPosition: 1"

	| entry |
	entry := ContentsSymbolQuints at: index.
	self contentsSymbolQuints add: quint after: entry
]

{ #category : #controls }
CodeHolder class >> addEditContentsOption: anAssociation [

	"CodeHolder addEditContentsOption: #translateToC -> #selectedTranslateToC"

	EditContentsOptions add: anAssociation
]

{ #category : #preferences }
CodeHolder class >> canUseMultiWindowBrowsers [
	"This is a hook to allow browsers to control whether to respond to the muli-window preference.
	 Currenty CodeHolder cannot usefully use multi-windows, but may be able to do so in the future."
	^false
]

{ #category : #controls }
CodeHolder class >> defaultContentsSymbolQuints [
	"Default list of quintuplets representing information on the alternative views available in the code pane
		first element:	the contentsSymbol used
		second element:	the selector to call when this item is chosen.
		third element:	the selector to call to obtain the wording of the menu item.
		fourth element:	the wording to represent this view
		fifth element:	balloon help
	A hypen indicates a need for a seperator line in a menu of such choices"

	^ {
		{#source
			. #togglePlainSource 
			. #showingPlainSourceString 
			. 'source'
			. 'the textual source code as written' translated} .
		{#documentation
			. #toggleShowDocumentation
			. #showingDocumentationString
			. 'documentation'
			. 'the first comment in the method' translated} .

		#- .
		{#prettyPrint
			. #togglePrettyPrint
			. #prettyPrintString
			. 'prettyPrint'
			. 'the method source presented in a standard text format' translated} .

		#- .
		{#showDiffs
			. #toggleRegularDiffing
			. #showingRegularDiffsString
			. 'showDiffs'
			. 'the textual source diffed from its prior version' translated} .

		#- .
		{#decompile
			. #toggleDecompile
			. #showingDecompileString
			. 'decompile'
			. 'source code decompiled from byteCodes' translated} .
		{#byteCodes
			. #toggleShowingByteCodes
			. #showingByteCodesString
			. 'byteCodes'	
			. 'the bytecodes that comprise the compiled method' translated} .
	}
]

{ #category : #controls }
CodeHolder class >> defaultEditContentsOptions [
	"An array of associations of current display mode symbol to selector
	that creates the edit contents for that display mode. The default selector
	is #selectedMessage; this is a list of alternative to the default."

	^ {
		#byteCodes -> #selectedBytecodes
	}
]

{ #category : #'class initialization' }
CodeHolder class >> initialize [

	"CodeHolder initialize"

	ContentsSymbolQuints := self defaultContentsSymbolQuints asOrderedCollection.
	EditContentsOptions := Dictionary new.
	self defaultEditContentsOptions
		do: [:opt | EditContentsOptions at: opt key put: opt value]
]

{ #category : #controls }
CodeHolder class >> removeContentsSymbol: aSymbol [ 
	"Unregister the menu selection item with selection symbol aSymbol."

	"CodeHolder removeContentsSymbol: #altSyntax"

	| entries |
	entries := ContentsSymbolQuints
		select: [:e | (e isKindOf: Collection) and: [e first = aSymbol]].
	ContentsSymbolQuints removeAll: entries.
	^ entries

]

{ #category : #preferences }
CodeHolder class >> useMultiWindowBrowsers [
	<preference: 'Multi-window browsers'
		category: 'browsing'
		description: 'When enabled, the browser uses a multi-window to conserve real-estate.  e.g. enable then click in the window label of a browser to see the items being browsed.'
		type: #Boolean>
	^MultiWindowBrowsers ifNil: [false]
]

{ #category : #preferences }
CodeHolder class >> useMultiWindowBrowsers: aBoolean [
	MultiWindowBrowsers := aBoolean
]

{ #category : #contents }
CodeHolder >> aboutToStyle: aStyler [
	"This is a notification that aStyler is about to re-style its text.
	The default is to answer false to veto the styling"

	^false
]

{ #category : #misc }
CodeHolder >> addModelItemsToWindowMenu: aMenu [
	"Add model-related item to the window menu"

	super addModelItemsToWindowMenu: aMenu. 
	Smalltalk isMorphic ifTrue:
		[aMenu addLine.
		aMenu add: 'what to show...' translated target: self action: #offerWhatToShowMenu]
]

{ #category : #annotation }
CodeHolder >> addPriorVersionsCountForSelector: aSelector ofClass: aClass to: aStream [
	"add an annotation detailing the prior versions count"
	| versionsCount |

	versionsCount := VersionsBrowser versionCountForSelector: aSelector class: aClass.
	aStream nextPutAll: 
				((versionsCount > 1
					ifTrue:
						[versionsCount = 2 ifTrue:
							['1 prior version']
							ifFalse:
								[versionsCount printString, ' prior versions']]
					ifFalse:
						['no prior versions']), self annotationSeparator)
]

{ #category : #commands }
CodeHolder >> adoptMessageInCurrentChangeset [
	"Add the receiver's method to the current change set if not already there"

	self setClassAndSelectorIn: [:cl :sel |
		cl ifNotNil:
			[ChangeSet current adoptSelector: sel forClass: cl.
			self changed: #annotation]]

]

{ #category : #annotation }
CodeHolder >> annotation [
	"Provide a line of content for an annotation pane, representing information about the method associated with the selected class and selector in the receiver."

	|  aSelector aClass |

	((aSelector := self selectedMessageName) == nil or: [(aClass := self selectedClassOrMetaClass) == nil]) ifTrue: [^ ''].
	^ self annotationForSelector: aSelector ofClass: aClass
]

{ #category : #annotation }
CodeHolder >> annotation: aString [ 
	"The user accepted aString in our annotation pane.  Return false because by default we cannot edit annotations"
	^ false

]

{ #category : #annotation }
CodeHolder >> annotationForClassCommentFor: aClass [
	"Provide a line of content for an annotation pane, given that the receiver is pointing at the clas comment of the given class."

	| aStamp nonMeta |
	aStamp :=  (nonMeta := aClass theNonMetaClass) organization commentStamp.
	^ aStamp
		ifNil:
			[nonMeta name, ' has no class comment']
		ifNotNil:
			['class comment for ', nonMeta name,
				(aStamp = '<historical>'
					ifFalse:
						[' - ', aStamp]
					ifTrue:
						[''])]
]

{ #category : #annotation }
CodeHolder >> annotationForClassDefinitionFor: aClass [
	"Provide a line of content for an annotation pane, given that the receiver is pointing at the class definition of the given class."

	^ 'Class definition for ', aClass name
]

{ #category : #annotation }
CodeHolder >> annotationForHierarchyFor: aClass [
	"Provide a line of content for an annotation pane, given that the receiver is pointing at the hierarchy of the given class."

	^ 'Hierarchy for ', aClass name
]

{ #category : #annotation }
CodeHolder >> annotationForSelector: aSelector ofClass: aClass [ 
	"Provide a line of content for an annotation pane, representing  
	information about the given selector and class"
	| separator aStream requestList |
	aSelector == #Comment
		ifTrue: [^ self annotationForClassCommentFor: aClass].
	aSelector == #Definition
		ifTrue: [^ self annotationForClassDefinitionFor: aClass].
	aSelector == #Hierarchy
		ifTrue: [^ self annotationForHierarchyFor: aClass].
	aStream := (String new: 512) writeStream.
	requestList := self annotationRequests.
	separator := requestList size > 1
				ifTrue: [self annotationSeparator]
				ifFalse: [''].
	requestList
		do: [:aRequest | | aString sendersCount aComment aCategory implementorsCount aList stamp | 
			aRequest == #firstComment
				ifTrue: [aComment := aClass firstCommentAt: aSelector.
					aComment isEmptyOrNil
						ifFalse: [aStream nextPutAll: aComment , separator]].
			aRequest == #masterComment
				ifTrue: [aComment := aClass supermostPrecodeCommentFor: aSelector.
					aComment isEmptyOrNil
						ifFalse: [aStream nextPutAll: aComment , separator]].
			aRequest == #documentation
				ifTrue: [aComment := aClass precodeCommentOrInheritedCommentFor: aSelector.
					aComment isEmptyOrNil
						ifFalse: [aStream nextPutAll: aComment , separator]].
			aRequest == #timeStamp
				ifTrue: [stamp := self timeStamp.
					aStream
						nextPutAll: (stamp size > 0
								ifTrue: [stamp , separator]
								ifFalse: ['no timeStamp' , separator])].
			aRequest == #messageCategory
				ifTrue: [aCategory := aClass organization categoryOfElement: aSelector.
					aCategory
						ifNotNil: ["woud be nil for a method no longer present,  
							e.g. in a recent-submissions browser"
							aStream nextPutAll: aCategory , separator]].
			aRequest == #sendersCount
				ifTrue: [sendersCount := (self systemNavigation allCallsOn: aSelector) size.
					sendersCount := sendersCount = 1
								ifTrue: ['1 sender']
								ifFalse: [sendersCount printString , ' senders'].
					aStream nextPutAll: sendersCount , separator].
			aRequest == #implementorsCount
				ifTrue: [implementorsCount := self systemNavigation numberOfImplementorsOf: aSelector.
					implementorsCount := implementorsCount = 1
								ifTrue: ['1 implementor']
								ifFalse: [implementorsCount printString , ' implementors'].
					aStream nextPutAll: implementorsCount , separator].
			aRequest == #priorVersionsCount
				ifTrue: [self
						addPriorVersionsCountForSelector: aSelector
						ofClass: aClass
						to: aStream].
			aRequest == #priorTimeStamp
				ifTrue: [stamp := VersionsBrowser
								timeStampFor: aSelector
								class: aClass
								reverseOrdinal: 2.
					stamp
						ifNotNil: [aStream nextPutAll: 'prior time stamp: ' , stamp , separator]].
			aRequest == #recentChangeSet
				ifTrue: [aString := ChangesOrganizer mostRecentChangeSetWithChangeForClass: aClass selector: aSelector.
					aString size > 0
						ifTrue: [aStream nextPutAll: aString , separator]].
			aRequest == #allChangeSets
				ifTrue: [aList := ChangesOrganizer allChangeSetsWithClass: aClass selector: aSelector.
					aList size > 0
						ifTrue: [aList size = 1
								ifTrue: [aStream nextPutAll: 'only in change set ']
								ifFalse: [aStream nextPutAll: 'in change sets: '].
							aList
								do: [:aChangeSet | aStream nextPutAll: aChangeSet name , ' ']]
						ifFalse: [aStream nextPutAll: 'in no change set'].
					aStream nextPutAll: separator]].
	^ aStream contents
]

{ #category : #toolbuilder }
CodeHolder >> annotationFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 1 offset: self annotationPaneHeight negated;
		rightFraction: 1 offset: 0;
		bottomFraction: 1 offset: 0
]

{ #category : #toolbuilder }
CodeHolder >> annotationPaneHeight [
	^ (Preferences standardCodeFont height * 3/2) rounded
]

{ #category : #annotation }
CodeHolder >> annotationPaneMenu: aMenu shifted: shifted [

	^ aMenu 
		labels: 'change pane size'
		lines: #()
		selections: #(toggleAnnotationPaneSize)
]

{ #category : #annotation }
CodeHolder >> annotationRequests [
	^ Preferences defaultAnnotationRequests
]

{ #category : #annotation }
CodeHolder >> annotationSeparator [
	"Answer the separator to be used between annotations"

	^ ' · '
]

{ #category : #commands }
CodeHolder >> browseImplementors [
	"Create and schedule a message set browser on all implementors of the currently selected message selector. Do nothing if no message is selected."

	| aMessageName |
	(aMessageName := self selectedMessageName) ifNotNil: 
		[self systemNavigation browseAllImplementorsOf: aMessageName]
]

{ #category : #commands }
CodeHolder >> browseSenders [
	"Create and schedule a message set browser on all senders of the currently selected message selector.  Of there is no message currently selected, offer a type-in"

	self sendQuery: #browseAllCallsOn: to: self systemNavigation
]

{ #category : #toolbuilder }
CodeHolder >> buildAnnotationPaneWith: builder [
	
	| annoSpec |
	annoSpec := builder pluggableInputFieldSpec new.
	annoSpec
		model: self;
		getText: #annotation;
		setText: #annotation:. 
	^ annoSpec
]

{ #category : #construction }
CodeHolder >> buildClassBrowserEditString: classDefinition [ 
	"Create and schedule a new class browser for the current selection, with initial textual contents set to aString.  This is used specifically in spawning where a class is established but a method-category is not."

	self flag: #uglyHack. "mt: We should not abuse Browser like this. We should not even know about #Browser in this superclass."
	^(Browser
		newOnClass: self selectedClassOrMetaClass
		editString: classDefinition
		label: 'Class Browser: ', self selectedClassOrMetaClass name)
			editSelection: #editClass; "...because we know it is class def code."
			changed: #editString with: classDefinition; "...trigger re-styling."
			yourself

]

{ #category : #toolbuilder }
CodeHolder >> buildCodePaneWith: builder [
	| textSpec top buttonSpec annoSpec |
	self wantsOptionalButtons ifTrue: [
		top := builder pluggablePanelSpec new.
		top children: OrderedCollection new.
		buttonSpec := self buildOptionalButtonsWith: builder.
		buttonSpec frame: self optionalButtonsFrame.
		top children add: buttonSpec].
	textSpec := builder pluggableCodePaneSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #contents:notifying:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:.
	self wantsAnnotationPane ifTrue: [
		top ifNil: [
			top := builder pluggablePanelSpec new.
			top children: OrderedCollection new].
		annoSpec := self buildAnnotationPaneWith: builder.
		annoSpec frame: self annotationFrame.
		top children add: annoSpec].
	top ifNotNil: [
		textSpec frame: self textFrame.
		top children add: textSpec].
	^top ifNil: [textSpec]
]

{ #category : #toolbuilder }
CodeHolder >> buildCodeProvenanceButtonWith: builder [
	| buttonSpec |
	buttonSpec := builder pluggableActionButtonSpec new.
	buttonSpec
		model: self;
		label: #codePaneProvenanceString;
		changeLabelWhen: #contents;
		style: #menuButton;
		action: #offerWhatToShowMenu;
		help: 'Governs what view is shown in the code pane.  Click here to change the view';
		margin: (5@0 corner: 0@0).
	^buttonSpec
]

{ #category : #construction }
CodeHolder >> buildMessageBrowserEditString: aString [ 
	"Create and schedule a new message browser for the current selection,
	with initial textual contents set to aString."
	^ Browser
		newOnClass: self selectedClassOrMetaClass
		messageCategory: self categoryOfCurrentMethod
		selector: self selectedMessageName
		editString: aString
		label: 'Message Browser: ' , self selectedClassOrMetaClass name , self categoryOfCurrentMethod
]

{ #category : #construction }
CodeHolder >> buildMessageCategoryBrowserForCategory: aCategory class: aClass selector: aSelectorOrNil editString: methodSourceCode [ 
	"Create and schedule a new class browser for the current selection,
	with initial textual contents set to aString. This is used specifically in
	spawning where a class is established but a method-category is not."
	
	self flag: #uglyHack. "mt: We should not abuse Browser like this. We should not even know about #Browser in this superclass."
	^ (Browser
		newOnClass: aClass
		messageCategory: aCategory
		selector: aSelectorOrNil
		editString: methodSourceCode
		label: 'Message category Browser: ' , aClass name , aCategory)
]

{ #category : #construction }
CodeHolder >> buildMorphicCodePaneWith: editString [
	"Construct the pane that shows the code.
	Respect the Preference for standardCodeFont."

	| codePane |
	codePane := PluggableTextMorph
				on: self
				text: #contents
				accept: #contents:notifying:
				readSelection: #contentsSelection
				menu: #codePaneMenu:shifted:.
	codePane font: Preferences standardCodeFont.
	editString
		ifNotNil: [codePane editString: editString.
			codePane hasUnacceptedEdits: true].
	^ codePane
]

{ #category : #toolbuilder }
CodeHolder >> buildOptionalButtonsWith: builder [

	| panelSpec |
	panelSpec := builder pluggablePanelSpec new.
	panelSpec children: OrderedCollection new.
	self optionalButtonPairs do:[:spec|
		| buttonSpec |
		buttonSpec := builder pluggableActionButtonSpec new.
		buttonSpec model: self.
		buttonSpec label: spec first.
		buttonSpec action: spec second.
		spec second == #methodHierarchy
			ifTrue:[buttonSpec
				enabled: #inheritanceButtonEnabled;
				color: #inheritanceButtonColor].
		spec second == #browseVersions
			ifTrue:[buttonSpec enabled: #versionsButtonEnabled].
		spec size > 2 ifTrue:[buttonSpec help: spec third].
		panelSpec children add: buttonSpec].

	"What to show"
	self wantsCodeProvenanceButton ifTrue: [
		panelSpec children
			add: builder pluggableSpacerSpec new;
			add: (self buildCodeProvenanceButtonWith: builder)].

	panelSpec layout: #horizontal. "buttons"
	^panelSpec
]

{ #category : #toolbuilder }
CodeHolder >> buttonHeight [
	^ Preferences standardButtonFont height * 2
]

{ #category : #'message category functions' }
CodeHolder >> canShowMultipleMessageCategories [
	"Answer whether the receiver is capable of showing multiple message categories"

	^ false
]

{ #category : #categories }
CodeHolder >> categoryFromUserWithPrompt: aPrompt for: aClass [
	"self new categoryFromUserWithPrompt: 'testing' for: SystemDictionary"

	|  labels myCategories reject lines newName menuIndex | 
	labels := OrderedCollection with: 'new...'.
	labels addAll: (myCategories := aClass organization categories sorted:
		[:a :b | a asLowercase < b asLowercase]).
	reject := myCategories asSet.
	reject
		add: ClassOrganizer nullCategory;
		add: ClassOrganizer default.
	lines := OrderedCollection with: 1 with: (myCategories size + 1).

	aClass allSuperclasses do:
		[:cls |
			| cats |
			cats := cls organization categories reject:
				 [:cat | reject includes: cat].
			cats isEmpty ifFalse:
				[lines add: labels size.
				labels addAll: (cats sort:
					[:a :b | a asLowercase < b asLowercase]).
				reject addAll: cats]].

	newName := (labels size = 1 or:
		[menuIndex := (UIManager default chooseFrom: labels lines: lines title: aPrompt).
		menuIndex = 0 ifTrue: [^ nil].
		menuIndex = 1])
			ifTrue:
				[UIManager default request: 'Please type new category name'
					initialAnswer: 'category name']
			ifFalse: 
				[labels at: menuIndex].
	^ newName ifNotNil: [newName asSymbol]
]

{ #category : #categories }
CodeHolder >> categoryOfCurrentMethod [
	"Answer the category that owns the current method.  If unable to determine a category, answer nil."

	| aClass aSelector |
	^ (aClass := self selectedClassOrMetaClass) 
		ifNotNil: [(aSelector := self selectedMessageName) 
			            ifNotNil: [aClass whichCategoryIncludesSelector: aSelector]]
]

{ #category : #categories }
CodeHolder >> changeCategory [
	"Present a menu of the categories of messages for the current class, 
	and let the user choose a new category for the current message"

	| aClass aSelector |
	(aClass := self selectedClassOrMetaClass) ifNotNil:
		[(aSelector := self selectedMessageName) ifNotNil:
			[(self letUserReclassify: aSelector in: aClass) ifTrue:
				["ChangeSet current reorganizeClass: aClass."
				"Decided on further review that the above, when present, could cause more
                    unexpected harm than good"
				self methodCategoryChanged]]]
]

{ #category : #controls }
CodeHolder >> codePaneProvenanceString [
	"Answer a string that reports on code-pane-provenance"

	| symsAndWordings |
	(symsAndWordings := self contentsSymbolQuints) do:
		[:aQuad |
			contentsSymbol == aQuad first ifTrue: [^ aQuad fourth]].
	^ symsAndWordings first fourth "default to plain source, for example if nil as initially"
]

{ #category : #contents }
CodeHolder >> commentContents [
	"documentation for the selected method"

	| poss aClass aSelector |
	^ (poss := (aClass := self selectedClassOrMetaClass)
						ifNil:
							['----']
						ifNotNil:
							[(aSelector := self selectedMessageName)
								ifNil:
									['---']
								ifNotNil:
									[(aClass precodeCommentOrInheritedCommentFor: aSelector)", String cr, String cr, self timeStamp"
"which however misses comments that are between the temps  declaration and the body of the method; those are picked up by ·aClass commentOrInheritedCommentFor: aSelector· but that method will get false positives from comments *anywhere* in the method source"]])
		isEmptyOrNil
			ifTrue:
				[aSelector
					ifNotNil:
						[((aClass methodHeaderFor: aSelector), '

Has no comment') asText makeSelectorBoldIn: aClass]
					ifNil:
						['Hamna']]
			ifFalse:	[aSelector
				ifNotNil: [((aClass methodHeaderFor: aSelector), '

', poss) asText makeSelectorBoldIn: aClass]
				ifNil: [poss]]
]

{ #category : #contents }
CodeHolder >> contents [
	"Answer the source code or documentation for the selected method"

	self showingByteCodes ifTrue:
		[^ self selectedBytecodes].

	self showingDocumentation ifTrue:
		[^ self commentContents].

	^ self selectedMessage
]

{ #category : #contents }
CodeHolder >> contentsChanged [

	super contentsChanged.
	self changed: #annotation
]

{ #category : #contents }
CodeHolder >> contentsSymbol [
	"Answer a symbol indicating what kind of content should be shown for the method; for normal showing of source code, this symbol is #source.  A nil value in the contentsSymbol slot will be set to #source by this method"

	^ contentsSymbol ifNil:
		[contentsSymbol := SystemBrowser browseWithPrettyPrint
								ifTrue:
									[#prettyPrint]
								ifFalse:
									[#source]]
]

{ #category : #contents }
CodeHolder >> contentsSymbol: aSymbol [
	"Set the contentsSymbol as indicated.  #source means to show source code, #comment means to show the first comment found in the source code"

	contentsSymbol := aSymbol
]

{ #category : #controls }
CodeHolder >> contentsSymbolQuints [
	"Answer a list of quintuplets representing information on the alternative views available in the code pane
		first element:	the contentsSymbol used
		second element:	the selector to call when this item is chosen.
		third element:	the selector to call to obtain the wording of the menu item.
		fourth element:	the wording to represent this view
		fifth element:	balloon help
	A hypen indicates a need for a seperator line in a menu of such choices"

	^ ContentsSymbolQuints
]

{ #category : #commands }
CodeHolder >> copyUpOrCopyDown [
	"Used to copy down code from a superclass to a subclass or vice-versa in one easy step, if you know what you're doing.  Prompt the user for which class to copy down or copy up to, then spawn a fresh browser for that class, with the existing code planted in it, and with the existing method category also established."

	| aClass aSelector allClasses implementors aMenu |
	Smalltalk isMorphic ifFalse: [^ self inform: 
'Sorry, for the moment you have to be in
Morphic to use this feature.'].

	((aClass := self selectedClassOrMetaClass) isNil or: [(aSelector := self selectedMessageName) == nil]) 
		ifTrue:	[^ Beeper beep].

	allClasses := self systemNavigation hierarchyOfClassesSurrounding: aClass.
	implementors := self systemNavigation hierarchyOfImplementorsOf: aSelector forClass: aClass.
	aMenu := MenuMorph new defaultTarget: self.
	aMenu title: 
aClass name, '.', aSelector, '
Choose where to insert a copy of this method
(blue = current, black = available, red = other implementors'.
	allClasses do:
		[:cl |
			| aColor |
			aColor := cl == aClass
				ifTrue:	[#blue]
				ifFalse:
					[(implementors includes: cl)
						ifTrue:	[#red]
						ifFalse:	[#black]].
			(aColor == #red)
				ifFalse:
					[aMenu add: cl name selector: #spawnToClass: argument: cl]
				ifTrue:
					[aMenu add: cl name selector: #spawnToCollidingClass: argument: cl].
			aMenu lastItem color: (Color colorFrom: aColor)].
	aMenu popUpInWorld
]

{ #category : #'message list' }
CodeHolder >> decompiledSourceIntoContents [
	"For backwards compatibility."

	^self  decompiledSourceIntoContentsWithTempNames: (Sensor leftShiftDown not) 

]

{ #category : #'message list' }
CodeHolder >> decompiledSourceIntoContentsWithTempNames: showTempNames [ 
	"Obtain a source string by decompiling the method's code, and place 
	that source string into my contents.
	Also return the string.
	Get temps from source file if showTempNames is true."

	| class selector method |
	class := self selectedClassOrMetaClass.
	selector := self selectedMessageName.
	"Was method deleted while in another project?"
	method := class compiledMethodAt: selector ifAbsent: [^ ''].

	currentCompiledMethod := method.
	contents := (showTempNames
		ifTrue: [method decompileWithTemps]
		ifFalse: [method decompile]) decompileString.
	contents := contents asText makeSelectorBoldIn: class.
	^ contents copy
]

{ #category : #controls }
CodeHolder >> decorateButtons [
	"Change screen feedback for any buttons in the UI of the receiver that may wish it.  Initially, it is only the Inheritance button that is decorated, but one can imagine others."
	self changed: #inheritanceButtonColor.
	self changed: #inheritanceButtonEnabled.
	self changed: #versionsButtonEnabled.
]

{ #category : #annotation }
CodeHolder >> defaultAnnotationPaneHeight [
	"Answer the receiver's preferred default height for new annotation panes."

	^ Preferences parameterAt: #defaultAnnotationPaneHeight ifAbsentPut: [25]
]

{ #category : #annotation }
CodeHolder >> defaultButtonPaneHeight [
	"Answer the user's preferred default height for new button panes."

	^ Preferences parameterAt: #defaultButtonPaneHeight ifAbsentPut: [25]
]

{ #category : #diffs }
CodeHolder >> defaultDiffsSymbol [
	"Answer the code symbol to use when generically switching to diffing"

	^ Preferences diffsWithPrettyPrint 
		ifTrue:
			[#prettyDiffs]
		ifFalse:
			[#showDiffs]
]

{ #category : #'self-updating' }
CodeHolder >> didCodeChangeElsewhere [
	"Determine whether the code for the currently selected method and class has been changed somewhere else."
	| aClass aSelector aCompiledMethod |
	currentCompiledMethod ifNil: [^ false].

	(aClass := self selectedClassOrMetaClass) ifNil: [^ false].

	(aSelector := self selectedMessageName) ifNil: [^ false].

	self classCommentIndicated
		ifTrue: [^ currentCompiledMethod ~~ aClass organization commentRemoteStr].

	^ (aCompiledMethod := aClass compiledMethodAt: aSelector ifAbsent: [^ false]) ~~ currentCompiledMethod
		and: [aCompiledMethod last ~= 0 "either not yet installed"
				or: [ currentCompiledMethod last = 0 "or these methods don't have source pointers"]]
]

{ #category : #diffs }
CodeHolder >> diffFromPriorSourceFor: sourceCode [ 
	"If there is a prior version of source for the selected method, return a diff, else just return the source code"

	| prior |
	^ (prior := self priorSourceOrNil)
		ifNil: [sourceCode]
		ifNotNil: [TextDiffBuilder buildDisplayPatchFrom: prior to: sourceCode inClass: self selectedClass prettyDiffs: self showingPrettyDiffs]
]

{ #category : #contents }
CodeHolder >> editContents [

	^ self editContentsWithDefault: [self selectedMessage]

]

{ #category : #contents }
CodeHolder >> editContentsWithDefault: aBlock [

	| selector |
	selector := EditContentsOptions
		at: self contentsSymbol
		ifAbsent: [^ aBlock value].
	^ self perform: selector

]

{ #category : #'message functions' }
CodeHolder >> exploreMethod [
	(self selectedClassOrMetaClass
		compiledMethodAt: self selectedMessageName
		ifAbsent: []) ifNotNil:
			[:method| method explore]
]

{ #category : #'message list' }
CodeHolder >> formattedLabel: aString [
	"Usually, the label is the same as the selector. Override this if the external representation of a message is different from its internal one."
	
	^ self
		formattedLabel: aString
		forSelector: aString
		inClass: self selectedClassOrMetaClass
]

{ #category : #'message list' }
CodeHolder >> formattedLabel: aString forSelector: aSymbol inClass: aClass [
	"Show deprecated messages differently so that users recognize them quickly to avoid them. This is a performance critical method in the user interface."
	
	| formattedLabel |
	self flag: #investigate. "mt: aClass must never be nil! Faulty tools should override this call themselves or fix the caller site."
	aClass ifNil: [^ aString].
	
	(aSymbol = #Definition or: [aSymbol = #Comment])
		ifTrue: [aClass isDeprecated
			ifFalse: [^ aString]]
		ifFalse: [(aClass isDeprecated or: [(aClass compiledMethodAt: aSymbol ifAbsent: [^ aString]) isDeprecated])
			ifFalse: [^ aString]].
	
	formattedLabel := aString asText.
	
	(self userInterfaceTheme deprecatedMessageAttributes ifNil: [{TextColor gray. TextEmphasis struckOut}]) do: [:textAttribute |
		formattedLabel addAttribute: textAttribute].

	^ formattedLabel.
]

{ #category : #misc }
CodeHolder >> getSelectorAndSendQuery: querySelector to: queryPerformer [
	"Obtain a selector relevant to the current context, and then send the querySelector to the queryPerformer with the selector obtained as its argument.  If no message is currently selected, then obtain a method name from a user type-in"

	self getSelectorAndSendQuery: querySelector to: queryPerformer with: { }.

]

{ #category : #misc }
CodeHolder >> getSelectorAndSendQuery: querySelector to: queryPerformer with: queryArgs [
	"Obtain a selector relevant to the current context, and then send the querySelector to the queryPerformer with the selector obtained and queryArgs as its arguments.  If no message is currently selected, then obtain a method name from a user type-in"

	| strm array |
	strm := WriteStream on: (array := Array new: queryArgs size + 1).
	strm nextPut: nil.
	strm nextPutAll: queryArgs.

	self selectedMessageName ifNil: [ | selector |
		selector := UIManager default request: 'Type selector:' initialAnswer: 'flag:'.
		selector := selector copyWithout: Character space.
		^ selector isEmptyOrNil ifFalse: [
			(Symbol hasInterned: selector
				ifTrue: [ :aSymbol |
					array at: 1 put: aSymbol.
					queryPerformer perform: querySelector withArguments: array])
				ifFalse: [ self inform: 'no such selector']
		]
	].

	self selectMessageAndEvaluate: [:selector |
		array at: 1 put: selector.
		queryPerformer perform: querySelector withArguments: array
	]
]

{ #category : #misc }
CodeHolder >> informPossiblyCorruptSource [

	| sourcesName |
	sourcesName := FileDirectory localNameFor: Smalltalk sourcesName.
	self inform: 'There may be a problem with your sources file!

The source code for every method should (usually) start with the
method selector but this is not the case with this method! You may
proceed with caution but it is recommended that you get a new source file.

This can happen if you download the "' , sourcesName  , '" file, 
or the ".changes" file you use, as TEXT. It must be transfered 
in BINARY mode, even if it looks like a text file, 
to preserve the CR line ends.

Mac users: This may have been caused by Stuffit Expander. 
To prevent the files above to be converted to Mac line ends 
when they are expanded, do this: Start the program, then 
from Preferences... in the File menu, choose the Cross 
Platform panel, then select "Never" and press OK. 
Then expand the compressed archive again.

(Occasionally, the source code for a method may legitimately
start with a non-alphabetic character -- for example, Behavior
method #formalHeaderPartsFor:.  In such rare cases, you can
happily disregard this warning.)'
]

{ #category : #toolbuilder }
CodeHolder >> inheritanceButtonColor [
	"Check to see if the currently-viewed method has a super send or an override, and if so, change screen feedback, unless the #decorateBrowserButtons says not to."

	| flags aColor cm |
	cm := currentCompiledMethod.
	((cm isKindOf: CompiledMethod) and: [Preferences decorateBrowserButtons])
		ifFalse: [^Color transparent].

	"This table duplicates the old logic, but adds two new colors for the cases where there is a superclass definition, but this method doesn't call it."

	flags := 0.
	self isThisAnOverride ifTrue: [ flags := flags bitOr: 4 ].
	cm sendsToSuper ifTrue: [ flags := flags bitOr: 2 ].
	self isThereAnOverride ifTrue: [ flags := flags bitOr: 1 ].
	aColor := {
		Color transparent.
		Color tan lighter.
		Color green muchLighter.
		Color blue muchLighter.
		Color red muchLighter.	"has super but doesn't call it"
		(Color r: 0.94 g: 0.823 b: 0.673).	"has sub; has super but doesn't call it"
		Color green muchLighter.
		Color blue muchLighter.
	} at: flags + 1.

	^aColor
]

{ #category : #toolbuilder }
CodeHolder >> inheritanceButtonEnabled [
	"The inheritance button is only enabled when a method is selected"

	^  self selectedMessageName notNil

]

{ #category : #'message functions' }
CodeHolder >> inspectMethod [
	(self selectedClassOrMetaClass
		compiledMethodAt: self selectedMessageName
		ifAbsent: []) ifNotNil:
			[:method| method inspect]
]

{ #category : #diffs }
CodeHolder >> installTextualCodingPane [
	"Install text into the code pane"

	| aWindow codePane aPane boundsToUse |
	(aWindow := self containingWindow) ifNil: [self error: 'where''s that window?'].
	codePane := self codeTextMorph ifNil: [self error: 'no code pane'].
	aPane := self buildMorphicCodePaneWith: nil.
	boundsToUse := (codePane bounds origin- (1@1)) corner: (codePane owner bounds corner " (1@1").
	aWindow replacePane: codePane with: aPane.
	aPane vResizing: #spaceFill; hResizing: #spaceFill; borderWidth: 0.
	aPane bounds: boundsToUse.
	aPane owner clipSubmorphs: false.

	self contentsChanged
]

{ #category : #contents }
CodeHolder >> isModeStyleable [
	"determine the current mode can be styled"
	^ self showingSource or: [self showingPrettyPrint]
]

{ #category : #misc }
CodeHolder >> isThereAnOverride [
	"Answer whether any subclass of my selected class implements my selected selector"

	| aName aClass |
	aName := self selectedMessageName ifNil: [^ false].
	aClass := self selectedClassOrMetaClass ifNil: [^ false].
	^aClass isSelectorOverridden: aName
]

{ #category : #misc }
CodeHolder >> isThisAnOverride [
	"Answer whether any superclass of my selected class implements my selected selector"

	| aName aClass |
	aName := self selectedMessageName ifNil: [^ false].
	aClass := self selectedClassOrMetaClass ifNil: [^ false].
	^aClass isSelectorOverride: aName
]

{ #category : #categories }
CodeHolder >> letUserReclassify: anElement in: aClass [
	"Put up a list of categories and solicit one from the user.  
	Answer true if user indeed made a change, else false"
	

	| currentCat newCat |
	currentCat := aClass organization categoryOfElement: anElement.
	newCat := self 
				categoryFromUserWithPrompt: 'choose category (currently "', currentCat, '")' 
				for: aClass.
	(newCat ~~ nil and: [newCat ~= currentCat])
		ifTrue:
			[aClass organization classify: anElement under: newCat suppressIfDefault: false logged: true.
			^ true]
		ifFalse:
			[^ false]
]

{ #category : #'categories & search pane' }
CodeHolder >> listPaneWithSelector: aSelector [
	"If, among my window's paneMorphs, there is a list pane defined with aSelector as its retriever, answer it, else answer nil"

	| aWindow |
	Smalltalk isMorphic ifFalse: [^ nil].
	^ (aWindow := self containingWindow) ifNotNil:
		[aWindow paneMorphSatisfying:
			[:aMorph | (aMorph isKindOf: PluggableListMorph) and:
				[aMorph getListSelector == aSelector]]]
]

{ #category : #traits }
CodeHolder >> makeSampleInstance [
	| aClass nonMetaClass anInstance |
	((aClass := self selectedClassOrMetaClass) isNil or: [aClass isTrait]) ifTrue: [^ self].
	nonMetaClass := aClass theNonMetaClass.
	anInstance := self sampleInstanceOfSelectedClass.
	(anInstance isNil and: [nonMetaClass ~~ UndefinedObject]) ifTrue: 
		[^ self inform: 'Sorry, cannot make an instance of ', nonMetaClass name].

	(Smalltalk isMorphic and: [anInstance isMorph])
		ifTrue:
			[self currentHand attachMorph: anInstance]
		ifFalse:
			[anInstance inspectWithLabel: 'An instance of ', nonMetaClass name]
]

{ #category : #'message list' }
CodeHolder >> messageHelpForMethod: aMethod [
	"Answer the formatted help text for a method."
	"Show the first n lines of the source code of the method."
	| source formatted |
	source := aMethod getSource.
	formatted := (Smalltalk classNamed: #SHTextStylerST80)
		ifNil: [ source asText ]
		ifNotNil: [ :textStylerClass |
			textStylerClass new
				classOrMetaClass: aMethod methodClass;
				styledTextFor: source asText ].
	^ self messageHelpTruncated: formatted
]

{ #category : #'message list' }
CodeHolder >> messageHelpTruncated: aText [
	"Show only the first n lines of the text."
	| formatted lineCount |
	formatted := aText.
	lineCount := 0.
	aText doWithIndex: [:char :index |
		char = Character cr ifTrue: [lineCount := lineCount + 1].
		lineCount > 10 ifTrue: [
			formatted := formatted copyFrom: 1 to: index-1.
			formatted append: ' [...]'.
			^ formatted]].
	^ formatted
]

{ #category : #'message list menu' }
CodeHolder >> messageListKey: aChar from: view [
	"Respond to a Command key.  I am a model with a code pane, and I also
	have a listView that has a list of methods.  The view knows how to get
	the list and selection."
	| sel class |
	aChar == $D ifTrue: [^ self toggleDiffing].
	sel := self selectedMessageName.
	aChar == $m ifTrue:  "These next two put up a type in if no message selected"
		[^ self useSelector: sel orGetSelectorAndSendQuery: #browseAllImplementorsOf: to: self ].
	aChar == $n ifTrue: 
		[^ self useSelector: sel orGetSelectorAndSendQuery: #browseAllCallsOn: to: self ].
	aChar == $d ifTrue: [^ self removeMessageFromBrowser].
	"The following require a class selection"
	(class := self selectedClassOrMetaClass) ifNil: [^ self arrowKey: aChar from: view].
	aChar == $b ifTrue: [^ ToolSet browse: class selector: sel].
	aChar == $N ifTrue: [^ self browseClassRefs].
	aChar == $i ifTrue: [^ self methodHierarchy].
	aChar == $h ifTrue: [^ self browseClassHierarchy].
	aChar == $p ifTrue: [^ self browseFullProtocol].
	aChar == $r ifTrue: [^ self browseVariableReferences].
	aChar == $a ifTrue: [^ self browseVariableAssignments].
	(aChar == $Y and: [self canShowMultipleMessageCategories])
		ifTrue: [^ self showHomeCategory].
	"The following require a method selection"
	sel ifNotNil: 
		[aChar == $o ifTrue: [^ self fileOutMessage].
		aChar == $c ifTrue: [^ self copySelector].
		aChar == $v ifTrue: [^ self browseVersions].
		aChar == $x ifTrue: [^ self removeMessage].
		aChar == $C ifTrue: [ self copyReference ]].
	^ self arrowKey: aChar from: view
]

{ #category : #'message list menu' }
CodeHolder >> messageListMenuMore: aMenu [
	" The 'more..' link that toggles between shifted and unshifted menus
	in message lists and context stacks "
	<messageListMenuShifted: false>
	<contextStackMenuShifted: false>
	<menuPriority: 1000>
	^ aMenu addList: #(
			-
			('more...'				shiftedYellowButtonActivity));
		yourself

]

{ #category : #categories }
CodeHolder >> methodCategoryChanged [
	self changed: #annotation
]

{ #category : #misc }
CodeHolder >> modelWakeUpIn: aWindow [
	"The window has been activated.  Respond to possible changes that may have taken place while it was inactive"

	self updateListsAndCodeIn: aWindow.
	self decorateButtons.
	self refreshAnnotation.

	super modelWakeUpIn: aWindow
]

{ #category : #'multi-window support' }
CodeHolder >> multiWindowState [
	^multiWindowState
]

{ #category : #'multi-window support' }
CodeHolder >> multiWindowState: aSavedMultiWindowState [
	multiWindowState := aSavedMultiWindowState
]

{ #category : #'categories & search pane' }
CodeHolder >> newSearchPane [
	"Answer a new search pane for the receiver"

	| aTextMorph |
	aTextMorph := PluggableTextMorph on: self
					text: #lastSearchString accept: #lastSearchString:
					readSelection: nil menu: nil.
	aTextMorph setProperty: #alwaysAccept toValue: true.
	aTextMorph askBeforeDiscardingEdits: false.
	aTextMorph acceptOnCR: true.
	aTextMorph setBalloonText: 'Type here and hit ENTER, and all methods whose selectors match what you typed will appear in the list pane below.'.
	^ aTextMorph
]

{ #category : #commands }
CodeHolder >> offerMenu [
	"Offer a menu to the user from the bar of tool buttons"

	self offerDurableMenuFrom: #messageListMenu:shifted: shifted: false
]

{ #category : #commands }
CodeHolder >> offerShiftedClassListMenu [
	"Offer the shifted class-list menu."

	^ self offerMenuFrom: #classListMenu:shifted: shifted: true
]

{ #category : #commands }
CodeHolder >> offerUnshiftedClassListMenu [
	"Offer the shifted class-list menu."

	^ self offerMenuFrom: #classListMenu:shifted: shifted: false
]

{ #category : #'what to show' }
CodeHolder >> offerWhatToShowMenu [
	"Offer a menu governing what to show"
	| builder menuSpec |
	builder := ToolBuilder default.
	menuSpec := builder pluggableMenuSpec new.
	self contentsSymbolQuints do: [:aQuint | aQuint == #-
		ifTrue: [menuSpec addSeparator]
		ifFalse: [
			| item |
			item := menuSpec add: (self perform: aQuint third) 
					target: self selector: aQuint second argumentList: #().
			item help: aQuint fifth.
		].
	].
	builder runModal: (builder open: menuSpec).
]

{ #category : #misc }
CodeHolder >> okayToAccept [
	"Answer whether it is okay to accept the receiver's input"

	self showingDocumentation ifTrue:
		[self inform: 
'Sorry, for the moment you can
only submit changes here when
you are showing source.  Later, you
will be able to edit the isolated comment
here and save it back, but only if YOU
implement it!.'.
		^ false].

	self showingEditContentsOption ifTrue:
		[self inform: 'Cannot accept ', self contentsSymbol, ' input'.
		^ false].

	self showingAnyKindOfDiffs ifFalse:
		[^ true]. 
	^ (UIManager default chooseFrom: {
		'accept anyway -- I''ll take my chances'.
		'um, let me reconsider'.
	} title:
'Caution!  You are "showing diffs" here, so 
there is a danger that some of the text in the
code pane is contaminated by the "diff" display') = 1
]

{ #category : #controls }
CodeHolder >> optionalButtonPairs [
	"Answer a tuple (formerly pairs) defining buttons, in the format:
			button label
			selector to send
			help message"

	| aList |

	aList := #(
	('browse'			browseMethodFull			'view this method in a browser')
	('senders' 			browseSendersOfMessages	'browse senders of...')
	('implementors'		browseMessages				'browse implementors of...')
	('versions'			browseVersions				'browse versions')), 

	(Preferences decorateBrowserButtons
		ifTrue:
			[{#('inheritance'		methodHierarchy 'browse method inheritance
green: sends to super
tan: has override(s)
mauve: both of the above
pink: is an override but doesn''t call super
pinkish tan: has override(s), also is an override but doesn''t call super' )}]
		ifFalse:
			[{#('inheritance'		methodHierarchy			'browse method inheritance')}]),

	#(
	('hierarchy'		browseClassHierarchy				'browse class hierarchy')
	('vars'			browseVariableReferences			'references...')).

	^ aList
]

{ #category : #toolbuilder }
CodeHolder >> optionalButtonsFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 0 offset: self buttonHeight
]

{ #category : #'what to show' }
CodeHolder >> prettyPrintString [
	"Answer whether the receiver is showing pretty-print"

	^ ((contentsSymbol == #prettyPrint)
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'prettyPrint'
]

{ #category : #misc }
CodeHolder >> priorSourceOrNil [
	"If the currently-selected method has a previous version, return its source, else return nil"
	| aClass aSelector  changeRecords |
	(aClass := self selectedClassOrMetaClass) ifNil: [^ nil].
	(aSelector := self selectedMessageName) ifNil: [^ nil].
	changeRecords := aClass changeRecordsAt: aSelector.
	(changeRecords == nil or: [changeRecords size <= 1]) ifTrue: [^ nil].
	^ (changeRecords at: 2) string 

]

{ #category : #toolbuilder }
CodeHolder >> receiverClass [
	^ self selectedClassOrMetaClass 
]

{ #category : #misc }
CodeHolder >> refreshAnnotation [
	"If the receiver has an annotation pane that does not bear unaccepted edits, refresh it"

	(self dependents detect: [:m | (m inheritsFromAnyIn: #('PluggableTextView' 'PluggableTextMorph')) and: [m getTextSelector == #annotation]] ifNone: [nil]) ifNotNil:
		[:aPane | aPane hasUnacceptedEdits ifFalse:
			[aPane update: #annotation]]
]

{ #category : #misc }
CodeHolder >> refusesToAcceptCode [
	"Answer whether receiver, given its current contentsSymbol, could accept code happily if asked to"

	^ (#(byteCodes documentation tiles) includes: self contentsSymbol)
]

{ #category : #misc }
CodeHolder >> releaseCachedState [
	"Can always be found again.  Don't write on a file."
	currentCompiledMethod := nil.
]

{ #category : #commands }
CodeHolder >> removeClass [
	"Remove the selected class from the system, at interactive user request.  Make certain the user really wants to do this, since it is not reversible.  Answer true if removal actually happened."

	| message  className classToRemove result |
	self okToChange ifFalse: [^ false].
	classToRemove := self selectedClassOrMetaClass ifNil: [Beeper beep. ^ false].
	classToRemove := classToRemove theNonMetaClass.
	className := classToRemove name.
	message := 'Are you certain that you
want to REMOVE the class ', className, '
from the system?'.
	(result := self confirm: message)
		ifTrue: 
			[classToRemove subclasses size > 0
				ifTrue: [(self confirm: 'class has subclasses: ' , message)
					ifFalse: [^ false]].
			classToRemove removeFromSystem.
			self changed: #classList.
			true].
	^ result
]

{ #category : #diffs }
CodeHolder >> restoreTextualCodingPane [
	"If the receiver is showing tiles, restore the textual coding pane"

	contentsSymbol == #tiles ifTrue:
		[contentsSymbol := #source.
		self installTextualCodingPane]
]

{ #category : #misc }
CodeHolder >> sampleInstanceOfSelectedClass [
	| aClass |
	"Return a sample instance of the class currently being pointed at"
	(aClass := self selectedClassOrMetaClass) ifNil: [^ nil].
	^ aClass theNonMetaClass initializedInstance
]

{ #category : #'categories & search pane' }
CodeHolder >> searchPane [
	"Answer the search pane associated with the receiver in its window, or nil if none.  Morphic only"

	^ self textPaneWithSelector: #lastSearchString
]

{ #category : #'message list' }
CodeHolder >> selectedBytecodes [
	"Answer text to show in a code pane when in showing-byte-codes mode"

	^ (self selectedClassOrMetaClass compiledMethodAt: self selectedMessageName ifAbsent: [^ '' asText]) symbolic asText
]

{ #category : #'message list' }
CodeHolder >> selectedMessage [
	"Answer a copy of the source code for the selected message.  This generic version is probably actually never reached, since every subclass probably reimplements and does not send to super.  In time, ideally, most, or all, reimplementors would vanish and all would defer instead to a universal version right here.  Everything in good time."

	| class selector method |
	contents ifNotNil: [^ contents copy].

	self showingDecompile ifTrue:[^ self decompiledSourceIntoContents].

	class := self selectedClassOrMetaClass.
	(class isNil or: [(selector := self selectedMessageName) isNil]) ifTrue: [^ ''].
	method := class compiledMethodAt: selector ifAbsent: [^ ''].	"method deleted while in another project"
	currentCompiledMethod := method.

	^ contents := (self showingDocumentation
		ifFalse: [self sourceStringPrettifiedAndDiffed]
		ifTrue:	[ self commentContents])
			copy asText makeSelectorBoldIn: class
]

{ #category : #categories }
CodeHolder >> selectedMessageCategoryName [
	"Answer the name of the message category of the message of the currently selected context."

	^ self selectedClass organization categoryOfElement: self selectedMessageName
]

{ #category : #misc }
CodeHolder >> sendQuery: querySelector to: queryPerformer [
	"Apply a query to the primary selector associated with the current context.  If no such selection exists, obtain one by user type-in. Then send querySelector to queryPerformer with the selector as its argument."

	| aSelector aString |
	aSelector := self selectedMessageName ifNil:
		[aString :=UIManager default request: 'Type selector:' initialAnswer: 'flag:'.
		^ aString isEmptyOrNil ifFalse:
			[(Symbol hasInterned: aString ifTrue:
				[:aSymbol | queryPerformer perform: querySelector with: aSymbol])
				ifFalse:
					[self inform: 'no such selector']]].

	queryPerformer perform: querySelector with: aSelector
]

{ #category : #misc }
CodeHolder >> setClassAndSelectorIn: csBlock [
	"Evaluate csBlock with my selected class and and selector as its arguments; provide nil arguments if I don't have a method currently selected"

	| aName |
	(aName := self selectedMessageName)
		ifNil:
			[csBlock value: nil value: nil]
		ifNotNil:
			[csBlock value: self selectedClassOrMetaClass value: aName]

]

{ #category : #'what to show' }
CodeHolder >> setContentsToForceRefetch [
	"Set the receiver's contents such that on the next update the contents will be formulated afresh.  This is a critical and obscure difference between Browsers on the one hand and MessageSets on the other, and has over the years been the source of much confusion and much difficulty.  By centralizing the different handling here, we don't need so many idiosyncratic overrides in MessageSet any more"

	contents := nil
]

{ #category : #'message list menu' }
CodeHolder >> shiftedMessageListMore: aMenu [
	" The 'more..' link that toggles between shifted and unshifted menus
	in message lists and context stacks "
	<messageListMenuShifted: true>
	<contextStackMenuShifted: true>
	<menuPriority: 1000>
	^ aMenu addList: #(
			-
			('more...'				unshiftedYellowButtonActivity));
		yourself

]

{ #category : #commands }
CodeHolder >> shiftedYellowButtonActivity [
	"Offer the shifted selector-list menu"

	^ self offerMenuFrom: #messageListMenu:shifted: shifted: true
]

{ #category : #'what to show' }
CodeHolder >> showByteCodes: aBoolean [
	"Get into or out of bytecode-showoing mode"

	self okToChange ifFalse: [^ self changed: #flash].
	aBoolean
		ifTrue:
			[contentsSymbol := #byteCodes]
		ifFalse:
			[contentsSymbol == #byteCodes ifTrue: [contentsSymbol := #source]].
	self contentsChanged
]

{ #category : #'what to show' }
CodeHolder >> showDecompile: aBoolean [
	"Set the decompile toggle as indicated"

	self contentsSymbol: (aBoolean ifFalse: [#source] ifTrue: [#decompile])
]

{ #category : #diffs }
CodeHolder >> showDiffs [
	"Answer whether the receiver is showing diffs of source code.  The preferred protocol here is #showingRegularDiffs, but this message is still sent by some preexisting buttons so is retained."

	^ contentsSymbol == #showDiffs

]

{ #category : #diffs }
CodeHolder >> showDiffs: aBoolean [
	"Set whether I'm showing diffs as indicated; use the global preference to determine which kind of diffs to institute."

	self showingAnyKindOfDiffs
		ifFalse:
			[aBoolean ifTrue:
				[contentsSymbol := self defaultDiffsSymbol]]
		ifTrue:
			[aBoolean ifFalse:
				[contentsSymbol := #source]].
	self setContentsToForceRefetch.
	self contentsChanged
]

{ #category : #'what to show' }
CodeHolder >> showDocumentation: aBoolean [
	"Set the showDocumentation toggle as indicated"

	self contentsSymbol: (aBoolean ifFalse: [#source] ifTrue: [#documentation])
]

{ #category : #diffs }
CodeHolder >> showPrettyDiffs: aBoolean [
	"Set whether I'm showing pretty diffs as indicated"

	self showingPrettyDiffs
		ifFalse:
			[aBoolean ifTrue:
				[contentsSymbol := #prettyDiffs]]
		ifTrue:
			[aBoolean ifFalse:
				[contentsSymbol := #source]].
	self setContentsToForceRefetch.
	self contentsChanged
]

{ #category : #diffs }
CodeHolder >> showRegularDiffs: aBoolean [
	"Set whether I'm showing regular diffs as indicated"

	self showingRegularDiffs
		ifFalse:
			[aBoolean ifTrue:
				[contentsSymbol := #showDiffs]]
		ifTrue:
			[aBoolean ifFalse:
				[contentsSymbol := #source]].
	self setContentsToForceRefetch.
	self contentsChanged
]

{ #category : #traits }
CodeHolder >> showUnreferencedClassVars [
	"Search for all class variables known to the selected class, and put up a 
	list of those that have no references anywhere in the system. The 
	search includes superclasses, so that you don't need to navigate your 
	way to the class that defines each class variable in order to determine 
	whether it is unreferenced"
	| cls aList aReport |
	((cls := self selectedClass) isNil or: [cls isTrait]) ifTrue: [^ self].
	aList := self systemNavigation allUnreferencedClassVariablesOf: cls.
	aList size = 0
		ifTrue: [^ self inform: 'There are no unreferenced
class variables in
' , cls name].
	aReport := String
				streamContents: [:aStream | 
					aStream nextPutAll: 'Unreferenced class variable(s) in ' , cls name;
						 cr.
					aList
						do: [:el | aStream tab; nextPutAll: el; cr]].
	Transcript cr; show: aReport.
	UIManager default chooseFrom: aList values: aList 
		title: 'Unreferenced
class variables in 
' , cls name
]

{ #category : #traits }
CodeHolder >> showUnreferencedInstVars [
	"Search for all instance variables known to the selected class, and put up a list of those that have no references anywhere in the system.  The search includes superclasses, so that you don't need to navigate your way to the class that defines each inst variable in order to determine whether it is unreferenced"

	| cls aList aReport |
	((cls := self selectedClassOrMetaClass) isNil or: [cls isTrait]) ifTrue: [^ self].
	aList := cls allUnreferencedInstanceVariables.
	aList size = 0 ifTrue: [^ self inform: 'There are no unreferenced
instance variables in
', cls name].
	aReport := String streamContents:
		[:aStream |
			aStream nextPutAll: 'Unreferenced instance variable(s) in ', cls name; cr.
			aList do: [:el | aStream tab; nextPutAll: el; cr]].
	Transcript cr; show: aReport.
	UIManager default chooseFrom: aList values: aList title: 'Unreferenced
instance variables in 
', cls name
]

{ #category : #diffs }
CodeHolder >> showingAnyKindOfDiffs [
	"Answer whether the receiver is currently set to show any kind of diffs"

	^ #(showDiffs prettyDiffs) includes: contentsSymbol
]

{ #category : #'what to show' }
CodeHolder >> showingByteCodes [
	"Answer whether the receiver is showing bytecodes"

	^ contentsSymbol == #byteCodes
]

{ #category : #'what to show' }
CodeHolder >> showingByteCodesString [
	"Answer whether the receiver is showing bytecodes"

	^ (self showingByteCodes
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'byteCodes'
]

{ #category : #'what to show' }
CodeHolder >> showingDecompile [
	"Answer whether the receiver should show decompile rather than, say, source code"

	^ self contentsSymbol == #decompile

]

{ #category : #'what to show' }
CodeHolder >> showingDecompileString [
	"Answer a string characerizing whether decompilation is showing"

	^ (self showingDecompile
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'decompile'
]

{ #category : #'what to show' }
CodeHolder >> showingDocumentation [
	"Answer whether the receiver should show documentation rather than, say, source code"

	^ self contentsSymbol == #documentation

]

{ #category : #'what to show' }
CodeHolder >> showingDocumentationString [
	"Answer a string characerizing whether documentation is showing"

	^ (self showingDocumentation
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'documentation'
]

{ #category : #'what to show' }
CodeHolder >> showingEditContentsOption [
	"True if any of the optional EditContentsOptions modes is in effect. This
	includes bytecode display and possibly other display modes."

	^ EditContentsOptions includesKey: self contentsSymbol

]

{ #category : #'what to show' }
CodeHolder >> showingPlainSource [
	"Answer whether the receiver is showing plain source"

	^ contentsSymbol == #source
]

{ #category : #'what to show' }
CodeHolder >> showingPlainSourceString [
	"Answer a string telling whether the receiver is showing plain source"

	^ (self showingPlainSource
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'source'
]

{ #category : #diffs }
CodeHolder >> showingPrettyDiffs [
	"Answer whether the receiver is showing pretty diffs of source code"

	^ contentsSymbol == #prettyDiffs

]

{ #category : #diffs }
CodeHolder >> showingPrettyDiffsString [
	"Answer a string representing whether I'm showing pretty diffs"

	^ (self showingPrettyDiffs
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'prettyDiffs'
]

{ #category : #'what to show' }
CodeHolder >> showingPrettyPrint [
	"Answer whether the receiver is showing pretty-print"

	^ contentsSymbol == #prettyPrint
]

{ #category : #diffs }
CodeHolder >> showingRegularDiffs [
	"Answer whether the receiver is showing regular diffs of source code"

	^ contentsSymbol == #showDiffs

]

{ #category : #diffs }
CodeHolder >> showingRegularDiffsString [
	"Answer a string representing whether I'm showing regular diffs"

	^ (self showingRegularDiffs
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'showDiffs'
]

{ #category : #'what to show' }
CodeHolder >> showingSource [
	"Answer whether the receiver is currently showing source code"

	^ self contentsSymbol == #source

]

{ #category : #controls }
CodeHolder >> sourceAndDiffsQuintsOnly [
	"Answer a list of quintuplets representing information on the alternative views available in the code pane for the case where the only plausible choices are showing source or either of the two kinds of diffs"

	^ #(
(source			togglePlainSource 		showingPlainSourceString	'source'			'the textual source code as writen')
(showDiffs		toggleRegularDiffing	showingRegularDiffsString	'showDiffs'		'the textual source diffed from its prior version')
(prettyDiffs		togglePrettyDiffing		showingPrettyDiffsString	'prettyDiffs'		'formatted textual source diffed from formatted form of prior version'))
]

{ #category : #'message list' }
CodeHolder >> sourceStringPrettifiedAndDiffed [
	"Answer a copy of the source code for the selected message, transformed by diffing and pretty-printing exigencies"

	| class selector sourceString |
	class := self selectedClassOrMetaClass.
	selector := self selectedMessageName.
	(class isNil or: [selector isNil]) ifTrue: [^'missing'].
	sourceString := class ultimateSourceCodeAt: selector ifAbsent: [^'error'].
	self validateMessageSource: sourceString forSelector: selector inClass: class.
	(#(#prettyPrint #prettyDiffs) 
		includes: contentsSymbol) 
			ifTrue: 
				[sourceString := class prettyPrinterClass 
							format: sourceString
							in: class
							notifying: nil].
	self showingAnyKindOfDiffs 
		ifTrue: [sourceString := self diffFromPriorSourceFor: sourceString].
	^sourceString
]

{ #category : #commands }
CodeHolder >> spawn: aString [ 
	"Create and schedule a spawned message category browser for the currently selected message category.  The initial text view contains the characters in aString.  In the spawned browser, preselect the current selector (if any) as the going-in assumption, though upon acceptance this will often change"

	self selectedClassOrMetaClass
		ifNil: [
			^ aString isEmptyOrNil ifFalse: [(Workspace new contents: aString) openLabel: 'spawned workspace']]
		ifNotNil: [:cls |
			self categoryOfCurrentMethod
				ifNil: [
					self buildClassBrowserEditString: aString]
				ifNotNil: [:category |
					self
						buildMessageCategoryBrowserForCategory: category
						class: cls
						selector: self selectedMessageName
						editString: aString]]
]

{ #category : #traits }
CodeHolder >> spawnHierarchy [
	"Create and schedule a new hierarchy browser on the currently selected class or meta."

	^ ToolSet
		browseHierarchy: self selectedClassOrMetaClass
		selector: self selectedMessageName
]

{ #category : #commands }
CodeHolder >> spawnToClass: aClass [
	"Used to copy down code from a superclass to a subclass in one easy step, if you know what you're doing.  Spawns a new message-category browser for the indicated class, populating it with the source code seen in the current tool."

	self categoryOfCurrentMethod
		ifNil: [
			self buildClassBrowserEditString: self contents]
		ifNotNil: [:category |
			self
				buildMessageCategoryBrowserForCategory: category
				class: aClass
				selector: nil
				editString: self contents]
]

{ #category : #commands }
CodeHolder >> spawnToCollidingClass: aClass [
	"Potentially used to copy down code from a superclass to a subclass in one easy step, in the case where the given class already has its own version of code, which would consequently be clobbered if the spawned code were accepted."

	self inform: 'That would be destructive of
some pre-existing code already in that
class for this selector.  For the moment,
we will not let you do this to yourself.'
]

{ #category : #'self-updating' }
CodeHolder >> stepIn: aSystemWindow [
	self updateListsAndCodeIn: aSystemWindow
]

{ #category : #misc }
CodeHolder >> suggestCategoryToSpawnedBrowser: aBrowser [
	"aBrowser is a message-category browser being spawned from the receiver.  Tell it what it needs to know to get its category info properly set up."

	aBrowser setOriginalCategoryIndexForCurrentMethod
]

{ #category : #toolbuilder }
CodeHolder >> textFrame [
	| topOffset bottomOffset |
	topOffset := self wantsOptionalButtons
		ifTrue: [self buttonHeight]
		ifFalse: [0].
	bottomOffset := self wantsAnnotationPane
		ifTrue: [self annotationPaneHeight negated]
		ifFalse: [0].
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: topOffset;
		rightFraction: 1 offset: 0;
		bottomFraction: 1 offset: bottomOffset
]

{ #category : #breakpoints }
CodeHolder >> toggleBreakOnEntry [
	"Install or uninstall a halt-on-entry breakpoint"

	| selectedMethod |
	self selectedClassOrMetaClass ifNil: [ ^self].
	selectedMethod := self selectedClassOrMetaClass
		compiledMethodAt: self selectedMessageName
		ifAbsent: [^ self].
	selectedMethod hasBreakpoint
		ifTrue:
			[BreakpointManager unInstall: selectedMethod]
		ifFalse:
			[BreakpointManager 
				installInClass: self selectedClassOrMetaClass
				selector: self selectedMessageName].
	self changed: #messageList
]

{ #category : #'what to show' }
CodeHolder >> toggleDecompile [
	"Toggle the setting of the showingDecompile flag, unless there are unsubmitted edits that the user declines to discard"

	| wasShowing |
	self okToChange ifTrue:
		[wasShowing := self showingDecompile.
		self restoreTextualCodingPane.
		self showDecompile: wasShowing not.
		self setContentsToForceRefetch.
		self contentsChanged]


]

{ #category : #diffs }
CodeHolder >> toggleDiffing [
	"Toggle whether diffs should be shown in the code pane.  If any kind of diffs were being shown, stop showing diffs.  If no kind of diffs were being shown, start showing whatever kind of diffs are called for by default."

	| wasShowingDiffs |
	self okToChange ifTrue:
		[wasShowingDiffs := self showingAnyKindOfDiffs.
		self restoreTextualCodingPane.
		self showDiffs: wasShowingDiffs not.
		self setContentsToForceRefetch.
		self contentsChanged]


]

{ #category : #diffs }
CodeHolder >> togglePlainSource [
	"Toggle whether plain source shown in the code pane"
	
	| wasShowingPlainSource |
	self okToChange ifTrue:
		[wasShowingPlainSource := self showingPlainSource.
		self restoreTextualCodingPane.
		wasShowingPlainSource
			ifTrue:
				[self showDocumentation: true]
			ifFalse:
				[contentsSymbol := #source].
		self setContentsToForceRefetch.
		self changed: #contents]


]

{ #category : #diffs }
CodeHolder >> togglePrettyDiffing [
	"Toggle whether pretty-diffing should be shown in the code pane"

	| wasShowingDiffs |
	self okToChange ifTrue:
		[wasShowingDiffs := self showingPrettyDiffs.
		self restoreTextualCodingPane.
		self showPrettyDiffs: wasShowingDiffs not.
		self setContentsToForceRefetch.
		self contentsChanged]


]

{ #category : #diffs }
CodeHolder >> togglePrettyPrint [
	"Toggle whether pretty-print is in effectin the code pane"

	self restoreTextualCodingPane.
	self okToChange ifTrue:
		[self showingPrettyPrint
			ifTrue:
				[contentsSymbol := #source]
			ifFalse:
				[contentsSymbol := #prettyPrint].
		self setContentsToForceRefetch.
		self contentsChanged]


]

{ #category : #diffs }
CodeHolder >> toggleRegularDiffing [
	"Toggle whether regular-diffing should be shown in the code pane"

	| wasShowingDiffs |
	self okToChange ifTrue:
		[wasShowingDiffs := self showingRegularDiffs.
		self restoreTextualCodingPane.
		self showRegularDiffs: wasShowingDiffs not.
		self setContentsToForceRefetch.
		self contentsChanged]


]

{ #category : #'what to show' }
CodeHolder >> toggleShowDocumentation [
	"Toggle the setting of the showingDocumentation flag, unless there are unsubmitted edits that the user declines to discard"

	| wasShowing |
	self okToChange ifTrue:
		[wasShowing := self showingDocumentation.
		self restoreTextualCodingPane.
		self showDocumentation: wasShowing not.
		self setContentsToForceRefetch.
		self contentsChanged]


]

{ #category : #'what to show' }
CodeHolder >> toggleShowingByteCodes [
	"Toggle whether the receiver is showing bytecodes"

	self restoreTextualCodingPane.
	self showByteCodes: self showingByteCodes not.
	self setContentsToForceRefetch.
	self contentsChanged
]

{ #category : #commands }
CodeHolder >> unshiftedYellowButtonActivity [
	"Offer the unshifted shifted selector-list menu"

	^ self offerMenuFrom: #messageListMenu:shifted: shifted: false
]

{ #category : #'self-updating' }
CodeHolder >> updateCodePaneIfNeeded [
	"If the code for the currently selected method has changed underneath me, then update the contents of my code pane unless it holds unaccepted edits"

	self didCodeChangeElsewhere
		ifTrue:
			[self hasUnacceptedEdits
				ifFalse:
					[self setContentsToForceRefetch.
					self contentsChanged]
				ifTrue:
					[self changed: #codeChangedElsewhere]]
]

{ #category : #'self-updating' }
CodeHolder >> updateListsAndCodeIn: aWindow [
	super updateListsAndCodeIn: aWindow.
	self updateCodePaneIfNeeded
]

{ #category : #misc }
CodeHolder >> useSelector: incomingSelector orGetSelectorAndSendQuery: querySelector to: queryPerformer [
	"If incomingSelector is not nil, use it, else obtain a selector from user type-in.   Using the determined selector, send the query to the performer provided."

	| aSelector |
	incomingSelector
		ifNotNil:
			[queryPerformer perform: querySelector with: incomingSelector]
		ifNil:
			[aSelector :=UIManager default request: 'Type selector:' initialAnswer: 'flag:'.
			aSelector isEmptyOrNil ifFalse:
				[(Symbol hasInterned: aSelector ifTrue:
					[:aSymbol | queryPerformer perform: querySelector with: aSymbol])
					ifFalse:
						[self inform: 'no such selector']]]
]

{ #category : #'message list' }
CodeHolder >> validateMessageSource: sourceString forSelector: aSelector inClass: theClass [
	"Check whether there is evidence that method source is invalid"

	(theClass newParser parseSelector: sourceString asString) = aSelector
		ifFalse: [self informPossiblyCorruptSource].
]

{ #category : #toolbuilder }
CodeHolder >> versionsButtonEnabled [
	"The versions button is only enabled when a method is selected or we view the 
	class comment."

	^  self selectedMessageName notNil or: [self classCommentIndicated]
]

{ #category : #'what to show' }
CodeHolder >> wantsCodeProvenanceButton [

	^ true
]

{ #category : #diffs }
CodeHolder >> wantsDiffFeedback [
	"Answer whether the receiver is showing diffs of source code"

	^ self showingAnyKindOfDiffs
]

{ #category : #'self-updating' }
CodeHolder >> wantsStepsIn: aWindow [
	^ Preferences smartUpdating
]
