"
An instance of Lexicon shows the list of all the method categories known to an object or any of its superclasses, as a ""flattened"" list, and, within any selected category, shows all methods understood by the class's instances which are associated with that category, again as a ""flattened"" list.  A variant with a search pane rather than a category list is also implemented.

categoryList				the list of categories
categoryListIndex		index of currently-selected category
targetObject				optional -- an instance being viewed
targetClass				the class being viewed
lastSearchString			the last string searched for
lastSendersSearchSelector	the last senders search selector
limitClass				optional -- the limit class to search for
selectorsVisited			list of selectors visited
selectorsActive			not presently in use, subsumed by selectorsVisited
currentVocabulary		the vocabulary currently installed
currentQuery			what the query category relates to:
							#senders #selectorName #currentChangeSet
compileTargetClass		transient -- behavior in which the current contents is 
							accepted/compiled
"
Class {
	#name : #Lexicon,
	#superclass : #ProtocolBrowser,
	#instVars : [
		'currentVocabulary',
		'categoryList',
		'categoryListIndex',
		'targetClass',
		'limitClass',
		'currentQuery',
		'currentQueryParameter',
		'selectorsVisited',
		'compileTargetClass'
	],
	#category : #'Protocols-Tools'
}

{ #category : #'visible category names' }
Lexicon class >> activeCategoryName [
	"Answer the name to be used for the active-methods category"

	true ifTrue: [^ #'-- current working set --'].

	'-- current working set --' asSymbol "Placed here so a message-strings-containing-it query will find this method"

]

{ #category : #'visible category names' }
Lexicon class >> allCategoryName [
	"Answer the name to be used for the all category"

	true ifTrue: [^ #'-- all --'].

	'-- all --' asSymbol  "Placed here so a message-strings-containing-it query will find this method"

]

{ #category : #'visible category names' }
Lexicon class >> queryCategoryName [
	"Answer the name to be used for the query-results category"

	true ifTrue: [^ #'-- query results --'].

	^ '-- query results --' asSymbol   "Placed here so a message-strings-containing-it query will find this method"
]

{ #category : #'visible category names' }
Lexicon class >> sendersCategoryName [
	"Answer the name to be used for the senders-results category"

	true ifTrue: [^ #'-- "senders" results --'].

	^ '-- "senders" results --'.  "so methods-strings-containing will find this"
]

{ #category : #'visible category names' }
Lexicon class >> viewedCategoryName [
	"Answer the name to be used for the previously-viewed-methods category"

	true ifTrue: [^ #'-- active --'].

	^ '-- active --' asSymbol	 "For benefit of method-strings-containing-it search"

]

{ #category : #'window title' }
Lexicon >> addModelItemsToWindowMenu: aMenu [
	"Add model-related item to the window menu"

	super addModelItemsToWindowMenu: aMenu. 
	aMenu add: 'choose vocabulary...' target: self action: #chooseVocabulary
]

{ #category : #toolbuilder }
Lexicon >> addSpecialButtonsTo: buttonPanelSpec with: builder [

	| homeCatBtnSpec menuBtnSpec mostGenericBtnSpec |
	homeCatBtnSpec := builder pluggableButtonSpec new
		model: self;
		action: #showHomeCategory;
		label: (ScriptingSystem formAtKey: #Cat) asMorph;
		help: 'show this method''s home category';
		yourself.
	menuBtnSpec := builder pluggableButtonSpec new
		model: self;
		action: #offerMenu;
		label: (ScriptingSystem formAtKey: #TinyMenu) asMorph;
		help: 'click here to get a menu with further options';
		yourself.
	mostGenericBtnSpec :=builder pluggableButtonSpec new
		model: self;
		action: #chooseLimitClass;
		label: #limitClassString;
		help: 'Governs which classes'' methods should be shown.  If this is the same as the viewed class, then only methods implemented in that class will be shown.  If it is ProtoObject, then methods of all classes in the vocabulary will be shown.'.
	buttonPanelSpec children
		add: homeCatBtnSpec;
		addFirst: mostGenericBtnSpec;
		addFirst: menuBtnSpec.
]

{ #category : #'window title' }
Lexicon >> adjustWindowTitle [
	"Set the title of the receiver's window, if any, to reflect the current choices"

	| aWindow aLabel catName |
	(catName := self selectedCategoryName) ifNil: [^ self].
	(aWindow := self containingWindow) ifNil: [^ self].
	aLabel := nil.
	#(	(viewedCategoryName		'Messages already viewed - ')
		(allCategoryName			'All messages - ')) do:
			[:aPair | catName = (self categoryWithNameSpecifiedBy: aPair first) ifTrue: [aLabel := aPair second]].

	aLabel ifNil:
		[aLabel := catName = self class queryCategoryName
			ifTrue:
				[self queryCharacterization, ' - ']
			ifFalse:
				['Vocabulary of ']].
	aWindow setLabel: aLabel, (self targetObject ifNil: [targetClass]) nameForViewer
]

{ #category : #'basic operation' }
Lexicon >> annotation [
	"Provide a line of annotation material for a middle pane."

	| aCategoryName |
	self selectedMessageName ifNotNil: [^ super annotation].
	(aCategoryName := self selectedCategoryName) ifNil:
		[^ self hasSearchPane
			ifTrue:
				['type a message name or fragment in the top pane and hit RETURN or ENTER']
			ifFalse:
				[''  "currentVocabulary documentation"]].


	(aCategoryName = self class queryCategoryName) ifTrue:
		[^ self queryCharacterization].
		
	#(
	(allCategoryName			'Shows all methods, whatever other category they belong to')
	(viewedCategoryName		'Methods visited recently.  Use  "-" button to remove a method from this category.')
	(queryCategoryName		'Query results'))

		do:
			[:pair | (self categoryWithNameSpecifiedBy: pair first) = aCategoryName ifTrue: [^ pair second]].

	^ currentVocabulary categoryCommentFor: aCategoryName
]

{ #category : #'new-window queries' }
Lexicon >> browseVariableAssignments [
	"Let the search pertain to the target class regardless of selection."
	self systemNavigation browseVariableAssignments: targetClass
]

{ #category : #'new-window queries' }
Lexicon >> browseVariableReferences [
	"Let the search pertain to the target class regardless of selection"
	self systemNavigation  browseVariableReferences: targetClass
]

{ #category : #toolbuilder }
Lexicon >> buildCategoryListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #categoryList; 
		getIndex: #categoryListIndex; 
		setIndex: #categoryListIndex:; 
		menu: #categoryListMenu:shifted:; 
		keyPress: #categoryListKey:from:.
	^listSpec
]

{ #category : #toolbuilder }
Lexicon >> buildCustomButtonsWith: builder [

	"This method if very similar to StringHolder>>buildOptionalButtonsWith:.
	Refactor and pass in button specs?"
	| panelSpec |
	panelSpec := builder pluggablePanelSpec new.
	panelSpec children: OrderedCollection new.
	self customButtonSpecs do: [:spec | | buttonSpec |
		buttonSpec := builder pluggableActionButtonSpec new.
		buttonSpec model: self.
		buttonSpec label: spec first.
		buttonSpec action: spec second.
		spec size > 2 ifTrue: [buttonSpec help: spec third].
		panelSpec children add: buttonSpec.
	].
	panelSpec layout: #horizontal. "buttons"
	self addSpecialButtonsTo: panelSpec with: builder.
	^panelSpec
]

{ #category : #toolbuilder }
Lexicon >> buildWith: builder [
	"Create the ui for the browser"
	| windowSpec max |
	max := self wantsOptionalButtons ifTrue:[0.32] ifFalse:[0.4].
	windowSpec := self buildWindowWith: builder specs: {
		(self listFrame: max fromLeft: 0 width: 0.5) -> [self buildCategoryListWith: builder].
		(self listFrame: max fromLeft: 0.5 width: 0.5) -> [self buildMessageListWith: builder].
		(self customButtonsFrame: max) -> [self buildCustomButtonsWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	^builder build: windowSpec
]

{ #category : #'message category functions' }
Lexicon >> canShowMultipleMessageCategories [
	"Answer whether the receiver is capable of showing multiple message categories"

	^ true
]

{ #category : #'category list' }
Lexicon >> categoriesPane [
	"If there is a pane defined by #categoryList in my containing window, answer it, else answer nil"

	^ self listPaneWithSelector: #categoryList
]

{ #category : #'category list' }
Lexicon >> categoryDefiningSelector: aSelector [
	"Answer a category in which aSelector occurs"

	| categoryNames |
	categoryNames := categoryList copyWithoutAll: #('-- all --').
	^ currentVocabulary categoryWithNameIn: categoryNames thatIncludesSelector: aSelector forInstance: self targetObject ofClass: targetClass
]

{ #category : #'category list' }
Lexicon >> categoryList [
	"Answer the category list for the protcol, creating it if necessary, and prepending the -- all -- category, and appending the other special categories for search results, etc."

	| specialCategoryNames |
	categoryList ifNil:
		[specialCategoryNames := #(queryCategoryName  viewedCategoryName "searchCategoryName sendersCategoryName  changedCategoryName activeCategoryName")  collect:
			[:sym | self class perform: sym].
		categoryList :=
			(currentVocabulary categoryListForInstance: self targetObject ofClass: targetClass limitClass: limitClass),
			specialCategoryNames,
			(Array with: self class allCategoryName)].
	^ categoryList
]

{ #category : #'category list' }
Lexicon >> categoryListIndex [
	"Answer the index of the currently-selected item in in the category list"

	^ categoryListIndex ifNil: [categoryListIndex := 1]
]

{ #category : #'category list' }
Lexicon >> categoryListIndex: anIndex [
	"Set the category list index as indicated"

	| categoryName aList found existingSelector |
	existingSelector := self selectedMessageName.

	categoryListIndex := anIndex.
	anIndex > 0
		ifTrue:
			[categoryName := categoryList at: anIndex]
		ifFalse:
			[contents := nil].
	self changed: #categoryListIndex.

	found := false.
	#(	(viewedCategoryName		selectorsVisited)
		(queryCategoryName		selectorsRetrieved)) do:
			[:pair |
				categoryName = (self class perform: pair first)
					ifTrue:
						[aList := self perform: pair second.
						found := true]].
	found ifFalse:
		[aList := currentVocabulary allMethodsInCategory: categoryName forInstance: self targetObject ofClass: targetClass].
	categoryName = self class queryCategoryName ifFalse: [autoSelectString := nil].

	self initListFrom: aList highlighting: targetClass.

	messageListIndex := 0.
	self changed: #messageList.
	contents := nil.
	self contentsChanged.
	self selectWithinCurrentCategoryIfPossible: existingSelector.
	self adjustWindowTitle
]

{ #category : #'category list' }
Lexicon >> categoryListKey: aChar from: aView [
	"The user hit a command-key while in the category-list.  Do something"

	(aChar == $f and: [self hasSearchPane not]) ifTrue:
		[^ self obtainNewSearchString].
]

{ #category : #'category list' }
Lexicon >> categoryListMenu: aMenu shifted: aBoolean [
	"Answer the menu for the category list"
	^ self menu: aMenu for: #(categoryListMenu categoryListMenuShifted:) shifted: aBoolean

]

{ #category : #'category list' }
Lexicon >> categoryListMenuTitle [
	"Answer the menu title for the category list menu"

	^ 'categories'
]

{ #category : #selection }
Lexicon >> categoryOfSelector: aSelector [ 
	"Answer the name of the defining category for aSelector, or nil if none"
	| classDefiningSelector |
	classDefiningSelector := targetClass whichClassIncludesSelector: aSelector.
	classDefiningSelector
		ifNil: [^ nil].
	"can happen for example if one issues this from a change-sorter for a 
	message that is recorded as having been removed"
	^ classDefiningSelector whichCategoryIncludesSelector: aSelector
]

{ #category : #'category list' }
Lexicon >> categoryWithNameSpecifiedBy: aSelector [
	"Answer the category name obtained by sending aSelector to my class.  This provides a way to avoid hard-coding the wording of conventions such as '-- all --'"

	^ self class perform: aSelector
]

{ #category : #'category list' }
Lexicon >> chooseCategory: aCategory [
	"Choose the category of the given name, if there is one"

	self categoryListIndex: (categoryList indexOf: aCategory ifAbsent: [^ Beeper beep])
]

{ #category : #'limit class' }
Lexicon >> chooseLimitClass [
	"Put up a menu allowing the user to choose the most generic class to show"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	targetClass withAllSuperclasses do:
		[:aClass | 
			aClass == ProtoObject
				ifTrue:
					[aMenu addLine].
			aMenu add: aClass name selector: #setLimitClass: argument: aClass.
			aClass == limitClass ifTrue:
				[aMenu lastItem color: Color red].
			aClass == targetClass ifTrue: [aMenu addLine]].
	aMenu addTitle: 'Show only methods
implemented at or above...'.  "heh heh -- somebody please find nice wording here!"
	aMenu popUpInWorld: self currentWorld
]

{ #category : #vocabulary }
Lexicon >> chooseVocabulary [
	"Put up a dialog affording the user a chance to choose a different vocabulary to be installed in the receiver"
	
	Smalltalk at: #Vocabulary ifPresent:[:aClass|
		| aMenu |
		aMenu := MenuMorph new defaultTarget: self.
		aMenu addTitle: 'Choose a vocabulary
blue = current
red = imperfect' translated.
		aMenu addStayUpItem.
		aClass allStandardVocabularies do:[:aVocabulary |
			(targetClass implementsVocabulary: aVocabulary)
				ifTrue:
					[aMenu add: aVocabulary vocabularyName selector: #switchToVocabulary: argument: aVocabulary.
					(targetClass fullyImplementsVocabulary: aVocabulary) ifFalse:
						[aMenu lastItem color: Color red].
					aVocabulary == currentVocabulary ifTrue:
						[aMenu lastItem color: Color blue]. 
					aMenu balloonTextForLastItem: aVocabulary documentation]].
		aMenu popUpInWorld: self currentWorld
	].
]

{ #category : #contents }
Lexicon >> contents [
	"We have a class, allow new messages to be defined"

	editSelection == #newMessage ifTrue: [^ targetClass sourceCodeTemplate].
	^ super contents
]

{ #category : #private }
Lexicon >> contents: aString notifying: aController [ 
	"Make sure a possible choice of the compileTargetClass is not remembered."
	[^ super contents: aString notifying: aController]
		ensure: [compileTargetClass := nil]
]

{ #category : #private }
Lexicon >> contents: aString oldSelector: oldSelector in: aClass classified: category notifying: aController [
	"Update messageList if a method is compiled because the selector might be in a
	different class now."
	^ (super contents: aString oldSelector: oldSelector in: aClass classified: category notifying: aController)
		ifTrue: [	self reformulateList. ^ true]
		ifFalse: [false]
]

{ #category : #'within-tool queries' }
Lexicon >> currentQueryParameter [
	"Answer the current query parameter"

	^ currentQueryParameter ifNil: [currentQueryParameter := 'contents']
]

{ #category : #'control buttons' }
Lexicon >> customButtonSpecs [
	"Answer a triplet defining buttons, in the format:

			button label
			selector to send
			help message"
	| aa |
	aa := contentsSymbol == #tiles ifTrue: [{   "Consult Ted Kaehler regarding this bit"
	{'tiles'.				#tilesMenu.					'tiles for assignment and constants'. 	true}.
	{'vars'.				#varTilesMenu.	'tiles for instance variables and a new temporary'. 	true}
		}] ifFalse: [#()].	"true in 4th place means act on mouseDown"

	^ aa, #(
	('follow'			seeAlso							'view a method I implement that is called by this method')
	('find'				obtainNewSearchString			'find methods by name search')
	('sent...'			setSendersSearch				'view the methods I implement that send a given message')

	('<'					navigateToPreviousMethod 		'view the previous active method')
	('>'					navigateToNextMethod 			'view the next active method')
	('-'					removeFromSelectorsVisited		'remove this method from my active list'))
]

{ #category : #initialization }
Lexicon >> customButtonsFrame: bottomFraction [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: bottomFraction offset: self buttonHeight negated - 4;
		rightFraction: 1 offset: 0;
		bottomFraction: bottomFraction offset: 0
]

{ #category : #'user interface' }
Lexicon >> defaultWindowColor [
	^ (Color r: 0.79 g: 0.9 b: 0.79)
]

{ #category : #'basic operation' }
Lexicon >> displaySelector: aSelector [
	"Set aSelector to be the one whose source shows in the browser.  If there is a category list, make it highlight a suitable category"

	| detectedItem messageIndex |
	self chooseCategory: (self categoryDefiningSelector: aSelector).
	detectedItem := messageList detect:
		[:anItem | (anItem asString copyUpTo: Character space) asSymbol == aSelector] ifNone: [^ Beeper beep].
	messageIndex := messageList indexOf: detectedItem.
	self messageListIndex: messageIndex
]

{ #category : #'model glue' }
Lexicon >> doItReceiver [
	"This class's classPool has been jimmied to be the classPool of the class being browsed. A doIt in the code pane will let the user see the value of the class variables.  Here, if the receiver is affiliated with a specific instance, we give give that primacy"

	^ self targetObject ifNil: [self targetClass]
]

{ #category : #'message list' }
Lexicon >> formattedLabel: aString forSelector: aSymbol inClass: aClass [
	"Highlight messages implemented in the targetClass in bold print."
	
	| formattedLabel |
	formattedLabel := super formattedLabel: aString forSelector: aSymbol inClass: aClass.
	aClass = targetClass ifTrue:
		[formattedLabel := formattedLabel asText.
		(self userInterfaceTheme ownMessageAttributes ifNil: [{TextEmphasis bold}]) do: [:textAttribute |
			formattedLabel addAttribute: textAttribute]].

	^ formattedLabel.
]

{ #category : #search }
Lexicon >> hasSearchPane [
	"Answer whether receiver has a search pane"

	^ self searchPane notNil
]

{ #category : #initialization }
Lexicon >> initListFrom: selectorCollection highlighting: aClass [ 
	"Make up the messageList with items from aClass in boldface.  Provide a final filtering in that only selectors whose implementations fall within my limitClass will be shown."

	
	messageList := OrderedCollection new.
	selectorCollection do: 
		[:selector | | item defClass |  defClass := aClass whichClassIncludesSelector: selector.
		(defClass notNil and: [defClass includesBehavior: self limitClass]) ifTrue:
			[item := selector, '     (' , defClass name , ')'.
			item := item asText.
			defClass == aClass ifTrue: [item allBold].
			"(self isThereAnOverrideOf: selector) ifTrue: [item addAttribute: TextEmphasis struckOut]."
			"The above has a germ of a good idea but could be very slow"
			messageList add: item]]
]

{ #category : #'limit class' }
Lexicon >> initialLimitClass [
	"Choose a plausible initial vlaue for the limit class, and answer it"

	| oneTooFar |
	limitClass := targetClass.
	(#('ProtoObject' 'Object' 'Behavior' 'ClassDescription' 'Class' 'ProtoObject class' 'Object class') includes: targetClass name asString) ifTrue: [^ targetClass].

	oneTooFar := (targetClass isKindOf: Metaclass)
		ifTrue:
			["use the fifth back from the superclass chain for Metaclasses, which is the immediate subclass of ProtoObject class.  Print <ProtoObject class allSuperclasses> to count them yourself."
			targetClass allSuperclasses at: (targetClass allSuperclasses size - 5)]
		ifFalse:
			[targetClass allSuperclasses at: targetClass allSuperclasses size].
	[limitClass superclass ~~ oneTooFar]
		whileTrue: [limitClass := limitClass superclass].
	^ limitClass
]

{ #category : #search }
Lexicon >> lastSearchString [
	"Answer the last search string, initializing it to an empty string if it has not been initialized yet"

	^ currentQueryParameter ifNil: [currentQueryParameter := 'contents']
]

{ #category : #search }
Lexicon >> lastSearchString: aString [
	"Make a note of the last string searched for in the receiver"

	currentQueryParameter := aString asString.
	currentQuery := #selectorName.
	autoSelectString := aString.
	self setMethodListFromSearchString.
	^ true
]

{ #category : #search }
Lexicon >> lastSendersSearchSelector [
	"Answer the last senders search selector, initializing it to a default value if it does not already have a value"

	^ currentQueryParameter ifNil: [currentQueryParameter := #flag:]
]

{ #category : #'limit class' }
Lexicon >> limitClass [
	"Answer the most generic class to show in the browser.  By default, we go all the way up to ProtoObject"

	^ limitClass ifNil: [self initialLimitClass]
]

{ #category : #'limit class' }
Lexicon >> limitClass: aClass [
	"Set the most generic class to show as indicated"

	limitClass := aClass
]

{ #category : #'limit class' }
Lexicon >> limitClassString [
	"Answer a string representing the current choice of most-generic-class-to-show"

	| most |
	(most := self limitClass) == ProtoObject
		ifTrue:	[^ 'All'].
	most == targetClass
		ifTrue:	[^ most name].
	^ 'Only through ', most name
]

{ #category : #initialization }
Lexicon >> listFrame: bottomFraction fromLeft: leftFraction width: rightFraction [
	^LayoutFrame new
		leftFraction: leftFraction offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: (leftFraction + rightFraction) offset: 0;
		bottomFraction: bottomFraction offset: self buttonHeight negated - 3
]

{ #category : #'category list' }
Lexicon >> mainCategoryListMenu: aMenu [
	"Answer the menu for the category list"
	<categoryListMenu>
	^ aMenu addList: #(('find...(f)' obtainNewSearchString)); yourself
]

{ #category : #transition }
Lexicon >> maybeReselectClass: aClass selector: aSelector [
	"The protocol or limitClass may have changed, so that there is a different categoryList.  Formerly, the given class and selector were selected; if it is possible to do so, reselect them now"

	aClass ifNil: [^ self].
	(currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: targetClass limitClass: limitClass)
		ifTrue:
			[self selectSelectorItsNaturalCategory: aSelector]
]

{ #category : #'message list' }
Lexicon >> messageHelpAt: anIndex [
	"Show the first n lines of the source code of the selected message."
	Preferences balloonHelpInMessageLists ifFalse: [^ nil].
	self messageList size < anIndex ifTrue: [^ nil].
	
	self class parse: (self messageList at: anIndex) toClassAndSelector:
		[:class :selector |
		^ self messageHelpForMethod: (class compiledMethodAt: selector ifAbsent: [^ nil])].
	
	^ nil
]

{ #category : #'message list' }
Lexicon >> messageIconAt: anIndex [
	Browser showMessageIcons
		ifFalse: [^ nil].
	self class parse: (self messageList at: anIndex) toClassAndSelector:
		[:class :selector |
		^ ToolIcons iconNamed: (ToolIcons
			iconForClass: targetClass
			selector: selector)].
	
	^ nil
]

{ #category : #'basic operation' }
Lexicon >> messageListIndex: anIndex [
	"Set the message list index as indicated, and update the history list if appropriate"

	| newSelector current |
	current := self selectedMessageName.
	super messageListIndex: anIndex.
	anIndex = 0 ifTrue: [
		self editSelection: #newMessage.
		self contentsChanged].
	(newSelector := self selectedMessageName) ifNotNil: 
		[self updateSelectorsVisitedfrom: current to: newSelector]
]

{ #category : #'message list menu' }
Lexicon >> messageListKey: aChar from: view [
	"Respond to a Command key"

	aChar == $f ifTrue: [^ self obtainNewSearchString].
	^ super messageListKey: aChar from: view
]

{ #category : #search }
Lexicon >> methodListFromSearchString: fragment [
	"Answer a method list of methods whose selectors match the given fragment"

	|  aList searchFor |
	currentQueryParameter := fragment.
	currentQuery := #selectorName.
	autoSelectString := fragment.
	searchFor := fragment asString asLowercase withBlanksTrimmed.

	aList := targetClass allSelectors select:
		[:aSelector | currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: targetClass limitClass: limitClass].
	searchFor size > 0 ifTrue:
		[aList := aList select:
			[:aSelector | aSelector includesSubstring: searchFor caseSensitive: false]].
	^ aList sorted

]

{ #category : #'within-tool queries' }
Lexicon >> methodsWithInitials [
	"Answer the list of method selectors within the scope of this tool whose time stamps begin with the initials designated by my currentQueryParameter"

	^ self methodsWithInitials: currentQueryParameter
]

{ #category : #'within-tool queries' }
Lexicon >> methodsWithInitials: initials [
	"Return a list of selectors representing methods whose timestamps have the given initials and which are in the protocol of this object and within the range dictated by my limitClass."

	| classToUse |
	classToUse := self targetObject ifNotNil: [self targetObject class] ifNil: [targetClass].  "In support of lightweight uniclasses"
	^ targetClass allSelectors select:
		[:aSelector | (currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: classToUse limitClass: limitClass) and:
			[Utilities doesMethod: aSelector forClass: classToUse bearInitials: initials]].


]

{ #category : #senders }
Lexicon >> navigateToASender [
	"Present the user with a list of senders of the currently-selected 
	message, and navigate to the chosen one"
	| selectorSet chosen aSelector |
	aSelector := self selectedMessageName.
	selectorSet := Set new.
	(self systemNavigation allCallsOn: aSelector)
		do: [:anItem | selectorSet add: anItem methodSymbol].
	selectorSet := selectorSet
				select: [:sel | currentVocabulary
						includesSelector: sel
						forInstance: self targetObject
						ofClass: targetClass
						limitClass: limitClass].
	selectorSet size = 0
		ifTrue: [^ Beeper beep].
	self okToChange
		ifFalse: [^ self].
	selectorSet := selectorSet sorted.
	chosen := UIManager default chooseFrom: selectorSet values: selectorSet.
	chosen isEmptyOrNil
		ifFalse: [self displaySelector: chosen]
]

{ #category : #history }
Lexicon >> navigateToNextMethod [
	"Navigate to the 'next' method in the current viewing sequence"

	| anIndex aSelector |
	self selectorsVisited size = 0 ifTrue: [^ self].
	anIndex := (aSelector := self selectedMessageName) notNil ifTrue: [selectorsVisited indexOf: aSelector ifAbsent: [selectorsVisited size]] ifFalse: [1].
	self selectedCategoryName == self class viewedCategoryName 
		ifTrue:
			[self selectWithinCurrentCategory: (selectorsVisited atWrap: (anIndex + 1))]
		ifFalse:
			[self displaySelector: (selectorsVisited atWrap: (anIndex + 1))]
]

{ #category : #history }
Lexicon >> navigateToPreviousMethod [
	"Navigate to the 'previous' method in the current viewing sequence"

	| anIndex aSelector |
	self selectorsVisited size = 0 ifTrue: [^ self].
	anIndex := (aSelector := self selectedMessageName) notNil
		ifTrue: [selectorsVisited indexOf: aSelector ifAbsent: [selectorsVisited size]]
		ifFalse: [selectorsVisited size].
	self selectedCategoryName == self class viewedCategoryName 
		ifTrue:
			[self selectWithinCurrentCategory: (selectorsVisited atWrap: (anIndex - 1))]
		ifFalse:
			[self displaySelector: (selectorsVisited atWrap: (anIndex - 1))]
]

{ #category : #history }
Lexicon >> navigateToRecentMethod [
	"Put up a menu of recent selectors visited and navigate to the one chosen"

	| visited aSelector |
	(visited := self selectorsVisited) size > 1 ifTrue:
		[visited := visited copyFrom: 1 to: (visited size min: 20).
		aSelector := UIManager default chooseFrom: visited values: visited 
			title: 'Recent methods visited in this browser'.
		aSelector isEmptyOrNil ifFalse: [self displaySelector: aSelector]]
]

{ #category : #'category list' }
Lexicon >> newCategoryPane [
	"Formulate a category pane for insertion into the receiver's pane list"

	| aListMorph |
	aListMorph := PluggableListMorph on: self list: #categoryList
			selected: #categoryListIndex changeSelected: #categoryListIndex:
			menu: #categoryListMenu:shifted:
			keystroke: #categoryListKey:from:.
	aListMorph setNameTo: 'categoryList'.
	aListMorph menuTitleSelector: #categoryListMenuTitle.
	^ aListMorph
]

{ #category : #transition }
Lexicon >> noteAcceptanceOfCodeFor: newSelector [
	"The user has submitted new code for the given selector; take a note of it.  NB that the selectors-changed list gets added to here, but is not currently used in the system."

	(self selectorsVisited includes: newSelector) ifFalse: [selectorsVisited add: newSelector].
]

{ #category : #search }
Lexicon >> obtainNewSearchString [
	"Put up a box allowing the user to enter a fresh search string"

	| fragment |
	
	fragment := UIManager default request: 'type method name or fragment: ' initialAnswer: self currentQueryParameter.
	fragment ifNil: [^ self].
	(fragment := fragment copyWithout: $ ) size = 0  ifTrue: [^ self].
	currentQueryParameter := fragment.
	fragment := fragment asLowercase.
	currentQuery := #selectorName.
	self showQueryResultsCategory.
	self messageListIndex: 0
]

{ #category : #'menu commands' }
Lexicon >> offerMenu [
	"Offer a menu to the user, in response to the hitting of the menu button on the tool pane"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Lexicon' translated.
	aMenu addStayUpItem.
	aMenu addTranslatedList: #(
		('vocabulary...' 			chooseVocabulary)
		('what to show...'			offerWhatToShowMenu)
		-
		('inst var refs (here)'		setLocalInstVarRefs)
		('inst var assignments (here)'		setLocalInstVarDefs)
		('class var refs (here)'		setLocalClassVarRefs)
		-
		('navigate to a sender...' 	navigateToASender)
		('recent...' 					navigateToRecentMethod)
		('show methods in current change set'	showMethodsInCurrentChangeSet)
		('show methods with initials...'	showMethodsWithInitials)
		-
		"('toggle search pane' 		toggleSearch)"
		-
		('browse full (b)' 			browseMethodFull)
		('browse hierarchy (h)'		browseClassHierarchy)
		('browse protocol (p)'		browseFullProtocol)
		-
		('fileOut'					fileOutMessage)
		('printOut'					printOutMessage)
		-
		('senders of... (n)'			browseSendersOfMessages)
		('implementors of... (m)'		browseMessages)
		('versions (v)' 				browseVersions)
		('inheritance (i)'			methodHierarchy)
		-
		('references... (r)' 				browseVariableReferences)
		('assignments... (a)' 				browseVariableAssignments)
		-
		('more...'					shiftedYellowButtonActivity)).
	
	^ aMenu popUpInWorld: self currentWorld
]

{ #category : #'model glue' }
Lexicon >> okayToAccept [
	"Answer whether it is okay to accept the receiver's input"

	| ok reply |
	(ok := super okayToAccept) ifTrue:
		[((compileTargetClass := self selectedClassOrMetaClass) ~~ targetClass) ifTrue:
			[reply := UIManager default chooseFrom: 
				{'okay, no problem'. 
				'cancel - let me reconsider'. 
				'compile into ', targetClass name, ' instead'.
				'compile into a new uniclass'} title:
'Caution!  This would be
accepted into class ', compileTargetClass name, '.
Is that okay?'.
			reply caseOf:
				{[1] -> [^ true].
				[2] -> [^ false].
				[3] -> [compileTargetClass := targetClass. ^ true]}
				otherwise: [self notYetImplemented]]].
	^ ok
]

{ #category : #toolbuilder }
Lexicon >> openOnClass: aTargetClass inWorld: ignored showingSelector: aSelector [

	^self openOnClass: aTargetClass showingSelector: aSelector
]

{ #category : #toolbuilder }
Lexicon >> openOnClass: aTargetClass showingSelector: aSelector [

	currentVocabulary ifNil: [currentVocabulary := Vocabulary fullVocabulary].
	targetClass := aTargetClass.
	self initialLimitClass.
	
	self reformulateCategoryList.
	ToolBuilder open: self.
	self adjustWindowTitle.
]

{ #category : #transition }
Lexicon >> preserveSelectorIfPossibleSurrounding: aBlock [
	"Make a note of the currently-selected method; perform aBlock and then attempt to reestablish that same method as the selected one in the new circumstances"

	| aClass aSelector |
	aClass := self selectedClassOrMetaClass.
	aSelector := self selectedMessageName.
	aBlock value.
	
	self hasSearchPane
		ifTrue:
			[self setMethodListFromSearchString]
		ifFalse:
			[self maybeReselectClass: aClass selector: aSelector]
]

{ #category : #'within-tool queries' }
Lexicon >> queryCharacterization [
	"Answer a characterization of the most recent query"

	currentQuery == #selectorName
		ifTrue: [^ 'My methods whose names include "', self lastSearchString, '"'].
	currentQuery == #methodsWithInitials
		ifTrue: [^ 'My methods stamped with initials ', currentQueryParameter].
	currentQuery == #senders
		ifTrue: [^ 'My methods that send #', self lastSendersSearchSelector].
	currentQuery == #currentChangeSet
		ifTrue: [^ 'My methods in the current change set'].
	currentQuery == #instVarRefs
		ifTrue:	[^ 'My methods that refer to instance variable "', currentQueryParameter, '"'].
	currentQuery == #instVarDefs
		ifTrue:	[^ 'My methods that store into instance variable "', currentQueryParameter, '"'].
	currentQuery == #classVarRefs
		ifTrue:	[^ 'My methods that refer to class variable "', currentQueryParameter, '"'].
	^ 'Results of queries will show up here'
]

{ #category : #'category list' }
Lexicon >> reformulateCategoryList [
	"Reformulate the category list"

	categoryList := nil.
	self categoryListIndex: 0.
	self changed: #categoryList.
	self contentsChanged
]

{ #category : #transition }
Lexicon >> reformulateList [
	"Make the category list afresh, and reselect the current selector if appropriate"

	self preserveSelectorIfPossibleSurrounding:
		[super reformulateList.
		self categoryListIndex: categoryListIndex]
]

{ #category : #transition }
Lexicon >> reformulateListNoting: newSelector [
	"A method has possibly been submitted for the receiver with newSelector as its selector; If the receiver has a way of reformulating its message list, here is a chance for it to do so"

	super reformulateListNoting: newSelector.
	newSelector ifNotNil:
		[self displaySelector: newSelector]
]

{ #category : #history }
Lexicon >> removeFromSelectorsVisited [
	"Remove the currently-selected method from the active set"

	| aSelector |
	(aSelector := self selectedMessageName) ifNil: [^ self].
	self removeFromSelectorsVisited: aSelector.
	self chooseCategory: self class viewedCategoryName
]

{ #category : #history }
Lexicon >> removeFromSelectorsVisited: aSelector [
	"remove aSelector from my history list"

	self selectorsVisited remove: aSelector ifAbsent: []
]

{ #category : #'menu commands' }
Lexicon >> removeMessage [
	"Remove the selected message from the system."

	messageListIndex = 0 ifTrue: [^ self].
	self okToChange ifFalse: [^ self].

	super removeMessage.
	"my #reformulateList method, called from the super #removeMethod method, will however try to preserve the selection, so we take pains to clobber it by the below..."
	messageListIndex := 0.
	self changed: #messageList.
	self changed: #messageListIndex.
	contents := nil.
	self contentsChanged
]

{ #category : #morphic }
Lexicon >> representsSameBrowseeAs: anotherModel [
	^self hasUnacceptedEdits not
		and: [ anotherModel targetClass = self targetClass ]
]

{ #category : #transition }
Lexicon >> retainMethodSelectionWhileSwitchingToCategory: aCategoryName [
	"retain method selection while switching the category-pane selection to show the category of the given name"

	| aSelectedName |
	aSelectedName := self selectedMessageName.
	self categoryListIndex: (categoryList indexOf: aCategoryName ifAbsent: [^ self]).
	aSelectedName ifNotNil: [self selectWithinCurrentCategory: aSelectedName]

]

{ #category : #'within-tool queries' }
Lexicon >> seeAlso [
	"Present a menu offering the selector of the currently selected message, as well as of all messages sent by it.  If the chosen selector is showable in the current browser, show it here, minding unsubmitted edits however"

	self selectImplementedMessageAndEvaluate:
		[:aSelector |
			((currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: targetClass limitClass: limitClass)  			 "i.e., is this aSelector available in this browser"
					and: [self okToChange])
				ifTrue:
					[self displaySelector: aSelector]
				ifFalse:
					[Beeper beep.  "SysttemNavigation new browseAllImplementorsOf: aSelector"]].
					"Initially I tried making this open an external implementors browser in this case, but later decided that the user model for this was unstable"
]

{ #category : #'within-tool queries' }
Lexicon >> seeAlso: aSelector [
	"If the requested selector is showable in the current browser, show it here, minding unsubmitted edits however"

	((currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: targetClass limitClass: limitClass)   "i.e., is aSelector available in this browser"
					and: [self okToChange])
		ifTrue:
			[self displaySelector: aSelector]
		ifFalse:
			[Beeper beep]
]

{ #category : #'category list' }
Lexicon >> selectCategoryAll [
	self categoryListIndex: (categoryList indexOf: self class allCategoryName)
]

{ #category : #selection }
Lexicon >> selectImplementedMessageAndEvaluate: aBlock [
	"Allow the user to choose one selector, chosen from the currently selected message's selector, as well as those of all messages sent by it, and evaluate aBlock on behalf of chosen selector.  If there is only one possible choice, simply make it; if there are multiple choices, put up a menu, and evaluate aBlock on behalf of the the chosen selector, doing nothing if the user declines to choose any.  In this variant, only selectors "

	| selector method messages |
	(selector := self selectedMessageName) ifNil: [^ self].
	method := (self selectedClassOrMetaClass ifNil: [^ self])
		lookupSelector: selector.
	(method isNil or: [(messages := method messages) size = 0])
		 ifTrue: [^ aBlock value: selector].
	(messages size = 1 and: [messages includes: selector])
		ifTrue:
			[^ aBlock value: selector].  "If only one item, there is no choice"

	messages := messages select: [:aSelector | currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: targetClass limitClass: limitClass].
	self systemNavigation 
		showMenuOf: messages
		withFirstItem: selector
		ifChosenDo: aBlock
]

{ #category : #selection }
Lexicon >> selectSelectorItsNaturalCategory: aSelector [
	"Make aSelector be the current selection of the receiver, with the category being its home category."

	| cat catIndex detectedItem |
	cat := self categoryOfSelector: aSelector.
	catIndex := categoryList indexOf: cat ifAbsent:
		["The method's own category is not seen in this browser; the method probably occurs in some other category not known directly to the class, but for now, we'll just use the all category"
		1].
	self categoryListIndex: catIndex.
	detectedItem := messageList detect:
		[:anItem | (anItem asString copyUpTo: Character space) asSymbol == aSelector] ifNone: [^ self].
	self messageListIndex:  (messageList indexOf: detectedItem ifAbsent: [^ self])
]

{ #category : #selection }
Lexicon >> selectWithinCurrentCategory: aSelector [
	"If aSelector is one of the selectors seen in the current category, select it"

	| detectedItem |
	detectedItem := self messageList detect:
		[:anItem | (anItem asString copyUpTo: Character space) asSymbol == aSelector] ifNone: [^ self].
	self messageListIndex:  (messageList indexOf: detectedItem ifAbsent: [^ self])
]

{ #category : #'category list' }
Lexicon >> selectWithinCurrentCategoryIfPossible: aSelector [
	"If the receiver's message list contains aSelector, navigate right to it without changing categories"
 
	| detectedItem messageIndex |
	aSelector ifNil: [^ self].
	detectedItem := messageList detect:
		[:anItem | (anItem asString copyUpTo: $ ) asSymbol == aSelector] ifNone: [^ self].
	messageIndex := messageList indexOf: detectedItem.
	self messageListIndex: messageIndex

]

{ #category : #'category list' }
Lexicon >> selectedCategoryName [
	"Answer the selected category name"

	^ categoryList ifNotNil:
		[categoryList at: categoryListIndex ifAbsent: [nil]]
]

{ #category : #selection }
Lexicon >> selectedClassOrMetaClass [
	"Answer the currently selected class (or metaclass)."

	self setClassAndSelectorIn: [:c :s | ^c]
]

{ #category : #selection }
Lexicon >> selectedMessage [
	"Answer the source method for the currently selected message."

	(categoryList notNil and: [(categoryListIndex isNil or: [categoryListIndex = 0])])
		ifTrue:
			[^ '---'].

	self setClassAndSelectorIn: [:class :selector | 
		class ifNil: [^ 'here would go the documentation for the protocol category, if any.'].

		self showingDecompile ifTrue: [^ self decompiledSourceIntoContents].
		self showingDocumentation ifTrue: [^ self commentContents].

		currentCompiledMethod := class compiledMethodAt: selector ifAbsent: [nil].
		^ self sourceStringPrettifiedAndDiffed asText makeSelectorBoldIn: class]
]

{ #category : #'within-tool queries' }
Lexicon >> selectorsChanged [
	"Return a list of methods in the current change set (or satisfying some 
	other such criterion) that are in the protocol of this object"
	| aList targetedClass |
	targetedClass := self targetObject
				ifNil: [targetClass]
				ifNotNil: [self targetObject class].
	aList := OrderedCollection new.
	ChangeSet current methodChanges
		associationsDo: [:classChgAssoc | classChgAssoc value
				associationsDo: [:methodChgAssoc | | aClass | (methodChgAssoc value == #change
							or: [methodChgAssoc value == #add])
						ifTrue: [(aClass := targetedClass whichClassIncludesSelector: methodChgAssoc key)
								ifNotNil: [aClass name = classChgAssoc key
										ifTrue: [aList add: methodChgAssoc key]]]]].
	^ aList
]

{ #category : #'within-tool queries' }
Lexicon >> selectorsDefiningInstVar [
	"Return a list of methods that define a given inst var that are in the protocol of this object"

	| aList  |
	aList := OrderedCollection new.
	targetClass withAllSuperclassesDo:
		[:aClass | 
			aList addAll: (aClass whichMethodsStoreInto: currentQueryParameter asString)
		].
	^ aList
]

{ #category : #search }
Lexicon >> selectorsMatching [
	"Anwer a list of selectors in the receiver that match the current search string"

	| fragment aList |
	fragment := self lastSearchString asLowercase.
	aList := targetClass allSelectors select:
		[:aSelector | (aSelector includesSubstring: fragment caseSensitive: false) and:
			[currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: targetClass limitClass: limitClass]].

	^ aList sorted
]

{ #category : #'category list' }
Lexicon >> selectorsReferringToClassVar [
	"Return a list of methods that refer to given class var that are in the 
	protocol of this object"
	| aList aClass nonMeta poolAssoc |
	nonMeta := targetClass theNonMetaClass.
	aClass := nonMeta classThatDefinesClassVariable: currentQueryParameter.
	aList := OrderedCollection new.
	poolAssoc := aClass classPool associationAt: currentQueryParameter asSymbol.
	(self systemNavigation allCallsOn: poolAssoc)
		do: [:elem | (nonMeta inheritsFrom: elem actualClass)
				ifTrue: [aList add: elem methodSymbol]].
	^ aList
]

{ #category : #'within-tool queries' }
Lexicon >> selectorsReferringToInstVar [
	"Return a list of methods that refer to a given inst var that are in the protocol of this object"

	| aList  |
	aList := OrderedCollection new.
	targetClass withAllSuperclassesDo: [:aClass | 
		aList addAll: (aClass whichSelectorsAccess: currentQueryParameter asString)
	].
	^ aList
]

{ #category : #'within-tool queries' }
Lexicon >> selectorsRetrieved [
	"Anwer a list of selectors in the receiver that have been retrieved for the query category.  This protocol is used when reformulating a list after, say, a limitClass change"

	currentQuery == #classVarRefs ifTrue: [^ self selectorsReferringToClassVar].
	currentQuery == #currentChangeSet ifTrue: [^ self selectorsChanged].
	currentQuery == #instVarDefs ifTrue: [^ self selectorsDefiningInstVar].
	currentQuery == #instVarRefs ifTrue: [^ self selectorsReferringToInstVar].
	currentQuery == #methodsWithInitials ifTrue: [^ self methodsWithInitials].
	currentQuery == #selectorName ifTrue: [^ self selectorsMatching].
	currentQuery == #senders ifTrue: [^ self selectorsSendingSelectedSelector].

	^ #()
]

{ #category : #senders }
Lexicon >> selectorsSendingSelectedSelector [
	"Assumes lastSendersSearchSelector is already set"
	| selectorSet |
	autoSelectString := (self lastSendersSearchSelector copyUpTo: $:) asString.
	selectorSet := Set new.
	(self systemNavigation allCallsOn: self lastSendersSearchSelector)
		do: [:anItem | | sel cl | 
			sel := anItem methodSymbol.
			cl := anItem actualClass.
			((currentVocabulary
						includesSelector: sel
						forInstance: self targetObject
						ofClass: targetClass
						limitClass: limitClass)
					and: [targetClass includesBehavior: cl])
				ifTrue: [selectorSet add: sel]].
	^ selectorSet sorted
]

{ #category : #history }
Lexicon >> selectorsVisited [
	"Answer the list of selectors visited in this tool"

	^ selectorsVisited ifNil: [selectorsVisited := OrderedCollection new]
]

{ #category : #'limit class' }
Lexicon >> setLimitClass: aClass [
	"Set aClass as the limit class for this browser"

	| currentClass currentSelector |
	currentClass := self selectedClassOrMetaClass.
	currentSelector := self selectedMessageName.

	self limitClass: aClass.
	categoryList := nil.
	self categoryListIndex: 0.
	self changed: #categoryList.
	self changed: #methodList.
	self changed: #contents.
	self changed: #limitClassString.
	self adjustWindowTitle.
	self hasSearchPane
		ifTrue:
			[self setMethodListFromSearchString].

	self maybeReselectClass: currentClass selector: currentSelector

	
]

{ #category : #'within-tool queries' }
Lexicon >> setLocalClassVarRefs [
	"Put up a list of the class variables in the viewed object, and when the user selects one, let the query results category show all the references to that class variable."

	| aName |

	(aName := targetClass theNonMetaClass chooseClassVarName) ifNil: [^ self].
	currentQuery := #classVarRefs.
	currentQueryParameter := aName.
	self showQueryResultsCategory
]

{ #category : #'within-tool queries' }
Lexicon >> setLocalInstVarDefs [
	"Put up a list of the instance variables in the viewed object, and when the user seletcts one, let the query results category show all the references to that instance variable."

	| instVarToProbe |

	targetClass chooseVarThenDo:
		[:aName | instVarToProbe := aName].
	instVarToProbe isEmptyOrNil ifTrue: [^ self].
	currentQuery := #instVarDefs.
	currentQueryParameter := instVarToProbe.
	self showQueryResultsCategory
]

{ #category : #'within-tool queries' }
Lexicon >> setLocalInstVarRefs [
	"Put up a list of the instance variables in the viewed object, and when the user seletcts one, let the query results category show all the references to that instance variable."

	| instVarToProbe |

	targetClass chooseVarThenDo:
		[:aName | instVarToProbe := aName].
	instVarToProbe isEmptyOrNil ifTrue: [^ self].
	currentQuery := #instVarRefs.
	currentQueryParameter := instVarToProbe.
	self showQueryResultsCategory
]

{ #category : #search }
Lexicon >> setMethodListFromSearchString [
	"Set the method list of the receiver based on matches from the search string"

	| fragment aList |
	self okToChange ifFalse: [^ self].
	fragment := currentQueryParameter.
	fragment := fragment asString asLowercase withBlanksTrimmed.

	aList := targetClass allSelectors select:
		[:aSelector | currentVocabulary includesSelector: aSelector forInstance: self targetObject ofClass: targetClass limitClass: limitClass].
	fragment size > 0 ifTrue:
		[aList := aList select:
			[:aSelector | aSelector includesSubstring: fragment caseSensitive: false]].
	aList size = 0 ifTrue:
		[^ Beeper beep].
	self initListFrom: aList sorted highlighting: targetClass.
	messageListIndex :=  messageListIndex min: messageList size.
	self changed: #messageList

]

{ #category : #senders }
Lexicon >> setSendersSearch [
	"Put up a list of messages sent in the current message, find all methods 
	of the browsee which send the one the user chooses, and show that list 
	in the message-list pane, with the 'query results' item selected in the 
	category-list pane"
	| selectorSet aSelector aString |
	self selectedMessageName
		ifNil: [aString := UIManager default request: 'Type selector to search for' initialAnswer: 'flag:'.
			aString isEmptyOrNil
				ifTrue: [^ self].
			Symbol
				hasInterned: aString
				ifTrue: [:sel | aSelector := sel]]
		ifNotNil: [self
				selectMessageAndEvaluate: [:sel | aSelector := sel]].
	aSelector
		ifNil: [^ self].
	selectorSet := Set new.
	(self systemNavigation allCallsOn: aSelector)
		do: [:anItem | selectorSet add: anItem methodSymbol].
	selectorSet := selectorSet
				select: [:sel | currentVocabulary
						includesSelector: sel
						forInstance: self targetObject
						ofClass: targetClass
						limitClass: limitClass].
	selectorSet size > 0
		ifTrue: [currentQuery := #senders.
			currentQueryParameter := aSelector.
			self
				categoryListIndex: (categoryList indexOf: self class queryCategoryName).
			self messageListIndex: 0]
]

{ #category : #selection }
Lexicon >> setToShowSelector: selectorString selectCategory: aBoolean [ 
	"Set up the receiver so that it will show the given selector"
	| catName catIndex messageIndex aList |
	catName := aBoolean
		ifTrue:
			[ (aList := currentVocabulary
				categoriesContaining: selectorString
				forClass: targetClass)
				at: 1
				ifAbsent: [ self class allCategoryName ] ]
		ifFalse: [ self class allCategoryName ].
	catIndex := categoryList
		indexOf: catName
		ifAbsent: [ 1 ].
	self categoryListIndex: catIndex.
	messageList
		detect:
			[ : anItem | (anItem copyUpTo: Character space) asString asSymbol == selectorString ]
		ifFound:
			[ : detectedItem | messageIndex := messageList indexOf: detectedItem.
			self messageListIndex: messageIndex ]
		ifNone: [ ^ self ]
]

{ #category : #'category list' }
Lexicon >> showCategoriesPane [
	"Show the categories pane instead of the search pane"

	| aPane |
	(aPane := self searchPane) ifNil: [^ Beeper beep].
	self containingWindow replacePane: aPane with: self newCategoryPane.
	categoryList := nil.
	self changed: #categoryList.
	self changed: #messageList
]

{ #category : #'menu commands' }
Lexicon >> showCategory [
	"A revectoring blamable on history.  Not sent in the image, but grandfathered buttons may still send this."

	^ self showHomeCategory
]

{ #category : #'menu commands' }
Lexicon >> showHomeCategory [
	"Toggle the selection of the category of the currently-selected method or category."
	self selectedMessageName
		ifNil: [ self selectCategoryAll ]
		ifNotNil:
			[ : selector | self selectedCategoryName = self class allCategoryName
				ifTrue:
					[ self preserveSelectorIfPossibleSurrounding:
						[ self
							setToShowSelector: selector
							selectCategory: true ] ]
				ifFalse:
					[ self
						setToShowSelector: selector
						selectCategory: false ] ]
]

{ #category : #'menu commands' }
Lexicon >> showMainCategory [
	"Continue to show the current selector, but show it within the context of its primary category.  Preserved for backward compatibility with pre-existing buttons."

	^ self showHomeCategory
]

{ #category : #'within-tool queries' }
Lexicon >> showMethodsInCurrentChangeSet [
	"Set the current query to be for methods in the current change set"

	currentQuery := #currentChangeSet.
	autoSelectString := nil.
	self categoryListIndex: (categoryList indexOf: self class queryCategoryName).
]

{ #category : #'within-tool queries' }
Lexicon >> showMethodsWithInitials [
	"Prompt the user for initials to scan for; then show, in the query-results category, all methods with those initials in their time stamps"

	| initials |
	initials := UIManager default request: 'whose initials? ' initialAnswer: Utilities authorInitials.
	initials isEmptyOrNil ifTrue: [^ self].
	self showMethodsWithInitials: initials



]

{ #category : #'within-tool queries' }
Lexicon >> showMethodsWithInitials: initials [
	"Make the current query be for methods stamped with the given initials"

	currentQuery := #methodsWithInitials.
	currentQueryParameter := initials.
	self showQueryResultsCategory.
	autoSelectString := nil.
	self changed: #messageList.
	self adjustWindowTitle

]

{ #category : #'within-tool queries' }
Lexicon >> showQueryResultsCategory [
	"Point the receiver at the query-results category and set the search string accordingly"

	autoSelectString := self currentQueryParameter.
	self categoryListIndex: (categoryList indexOf: self class queryCategoryName).
	self messageListIndex: 0
]

{ #category : #search }
Lexicon >> showSearchPane [
	"Given that the receiver is showing the categories pane, replace that with a search pane.  Though there is a residual UI for obtaining this variant, it is obscure and the integrity of the protocol-category-browser when there is no categories pane is not necessarily assured at the moment."

	| aPane |
	(aPane := self categoriesPane) ifNil: [^ Beeper beep].
	self containingWindow replacePane: aPane with: self newSearchPane.
	categoryList := nil.
	self changed: #categoryList.
	self changed: #messageList
]

{ #category : #'window title' }
Lexicon >> startingWindowTitle [
	"Answer the initial window title to apply"

	^ 'Vocabulary of ', targetClass nameForViewer
]

{ #category : #vocabulary }
Lexicon >> switchToVocabulary: aVocabulary [
	"Make aVocabulary be the current one in the receiver"

	self preserveSelectorIfPossibleSurrounding:
		[self useVocabulary: aVocabulary.
		self reformulateCategoryList.
		self adjustWindowTitle]

]

{ #category : #morphic }
Lexicon >> targetClass [

	^targetClass

]

{ #category : #private }
Lexicon >> targetForContents: aString [
	^ compileTargetClass
]

{ #category : #'model glue' }
Lexicon >> targetObject [
	"Answer the object to which this tool is bound."

	^ nil
]

{ #category : #search }
Lexicon >> toggleSearch [
	"Toggle the determination of whether a categories pane or a search pane shows"

	self hasSearchPane
		ifTrue:	[self showCategoriesPane]
		ifFalse:	[self showSearchPane]
]

{ #category : #history }
Lexicon >> updateSelectorsVisitedfrom: oldSelector to: newSelector [
	"Update the list of selectors visited."

	newSelector == oldSelector ifTrue: [^ self].
	self selectorsVisited remove: newSelector ifAbsent: [].
		
	(selectorsVisited includes:  oldSelector)
		ifTrue:
			[selectorsVisited add: newSelector after: oldSelector]
		ifFalse:
			[selectorsVisited add: newSelector]

]

{ #category : #vocabulary }
Lexicon >> useVocabulary: aVocabulary [
	"Set up the receiver to use the given vocabulary"

	currentVocabulary := aVocabulary
]

{ #category : #toolbuilder }
Lexicon >> wantsAnnotationPane [
	"This kind of browser always wants annotation panes, so answer true"

	^ true
]
