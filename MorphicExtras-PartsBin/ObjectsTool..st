"
I am a Master Parts Bin that allows the user to drag out a new Morph from a voluminous iconic list.

Choose ""objects"" from the world menu, or type Alt-o (Cmd-o on the Mac).

To add a new kinds of Morphs:
In the class of the Morph, implement the message:

descriptionForPartsBin
	^ self partName:	'Rectangle'
		categories:		#('Graphics' ' Basic 1 ')
		documentation:	'A rectangular shape, with border and fill style'

The partName is the title that will show in the lower pane of the Object Tool.
When is categories mode, an object can be seen in more than one category.  The list above tells which ones.
Documentation is what will show in the balloon help for each object thumbnail.
The message #initializeToStandAlone creates the actual instance.

To make a second variant object prototype coming from the same class, implement #supplementaryPartsDescriptions.  In it, you get to specify the nativitySelector.  It is sent to the class to get the variant objects.  Often it is #authoringPrototype.  (A class may supply supplementaryPartsDescriptions without implementing descriptionForPartsBin.  This gives you better control.)


"
Class {
	#name : #ObjectsTool,
	#superclass : #AlignmentMorph,
	#instVars : [
		'searchString',
		'modeSymbol'
	],
	#category : #'MorphicExtras-PartsBin'
}

{ #category : #'parts bin' }
ObjectsTool class >> descriptionForPartsBin [
	^ self partName:	'Objects' translatedNoop
		categories:		#()
		documentation:	'A place to obtain many kinds of objects' translatedNoop
]

{ #category : #'class initialization' }
ObjectsTool class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
ObjectsTool class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#ObjectsTool.	 #newStandAlone. 'Object Catalog' translatedNoop. 'A tool that lets you browse the catalog of objects' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#ObjectsTool	. #newStandAlone. 'Object Catalog' translatedNoop.'A tool that lets you browse the catalog of objects' translatedNoop}
						forFlapNamed: 'Widgets'.]
]

{ #category : #preferences }
ObjectsTool class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the tools'' border.' }.
		{ #borderWidth. 'Borders'. 'Width of the tools'' border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the tool.' }.
		{ #textColor. 'Colors'. 'Color for the category button labels.' }.
		{ #selectionTextColor. 'Colors'. 'Color used for the button of the selected category.' }.
	}
]

{ #category : #'class initialization' }
ObjectsTool class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menu }
ObjectsTool >> addCustomMenuItems: aMenu hand: aHand [
	"Add items to the given halo-menu, given a hand"

	super addCustomMenuItems: aMenu hand: aHand.
	aMenu addLine.
	aMenu add: 'alphabetic' translated target: self selector: #showAlphabeticTabs.
	aMenu add: 'find' translated target: self selector: #showSearchPane.
	aMenu add: 'categories' translated target: self selector: #showCategories.
	aMenu addLine.
	aMenu add: 'reset thumbnails' translated target: self selector: #resetThumbnails.
]

{ #category : #alphabetic }
ObjectsTool >> alphabeticTabs [
	"Answer a list of buttons which, when hit, will trigger the choice of a morphic category"

	| buttonList tabLabels |

	self flag: #todo. "includes non-english characters"
	tabLabels := (($a to: $z) asOrderedCollection collect: [:ch | ch asString]) .

	buttonList := tabLabels collect:
		[:catName |
			| aButton |
			aButton := SimpleButtonMorph new label: catName.
			aButton actWhen: #buttonDown.
			aButton target: self; actionSelector: #showAlphabeticCategory:fromButton:; arguments: {catName. aButton}].
	^ buttonList

"ObjectsTool new tabsForMorphicCategories"
]

{ #category : #updating }
ObjectsTool >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setDefaultParameters.
]

{ #category : #constants }
ObjectsTool >> baseBackgroundColor [

	^ self userInterfaceTheme borderColor ifNil: [Color veryLightGray] 
]

{ #category : #constants }
ObjectsTool >> baseBorderColor [

	^ self userInterfaceTheme borderColor ifNil: [Color veryLightGray] 
]

{ #category : #constants }
ObjectsTool >> buttonActiveColor [

	^ self userInterfaceTheme selectionTextColor ifNil: [Color white]
]

{ #category : #constants }
ObjectsTool >> buttonColor [

	^ self userInterfaceTheme textColor ifNil: [Color black]
]

{ #category : #'submorph access' }
ObjectsTool >> buttonPane [
	"Answer the receiver's button pane, nil if none"

	^ self submorphNamed: 'ButtonPane' ifNone: [].
]

{ #category : #layout }
ObjectsTool >> extent: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed"
	super extent: anExtent.
	self submorphsDo: [:m |
		m width: anExtent x]
]

{ #category : #layout }
ObjectsTool >> fixLayoutFrames [
	"Adjust the boundary between the tabs or search pane and the parts bin, giving preference to the tabs."

	| oldY newY aTabsPane aTabsPaneHeight |
	oldY := ((aTabsPane := self tabsPane
						ifNil: [self searchPane])
				ifNil: [^ self]) layoutFrame bottomOffset.
	aTabsPaneHeight := aTabsPane hasSubmorphs
				ifTrue: [(aTabsPane submorphBounds outsetBy: aTabsPane layoutInset) height]
				ifFalse: [aTabsPane height].
	newY := (self buttonPane ifNil: [^ self]) height + aTabsPaneHeight.
	oldY = newY ifTrue: [^ self].
	aTabsPane layoutFrame bottomOffset: newY.
	(self partsBin ifNil: [^ self]) layoutFrame topOffset: newY.
	submorphs	do: [:m | m layoutChanged]
]

{ #category : #tabs }
ObjectsTool >> highlightOnlySubmorph: aMorph in: anotherMorph [
	"Distinguish only aMorph with border highlighting (2-pixel wide red); make all my other submorphs have one-pixel-black highlighting.  This is a rather special-purpose and hard-coded highlighting regime, of course.  Later, if someone cared to do it, we could parameterize the widths and colors via properties, or some such."

	anotherMorph submorphs do: [:m | | color |
	 	color := m == aMorph ifTrue: [self buttonActiveColor] ifFalse: [self buttonColor].
		m 
			borderWidth: 1;
			borderColor: color. 
		m firstSubmorph color: color]

]

{ #category : #thumbnail }
ObjectsTool >> icon [
	"Answer a form with an icon to represent the receiver"
	^ MenuIcons objectCatalogIcon
]

{ #category : #initialization }
ObjectsTool >> initializeForFlap [
	"Initialize the receiver to operate in a flap at the top of the screen."

	"
	Flaps newObjectsFlap openInWorld
	"

	| buttonPane aBin aColor heights tabsPane |
	self basicInitialize.

	self layoutInset: 0;
		layoutPolicy: ProportionalLayout new;
		hResizing: #shrinkWrap;
		vResizing: #rigid;
		borderWidth: 2; borderColor: Color darkGray;
		extent: (self minimumWidth @ self minimumHeight).

	"mode buttons"
	buttonPane := self paneForTabs: self modeTabs.
	buttonPane
		vResizing: #shrinkWrap;
		setNameTo: 'ButtonPane';
		color: (aColor := buttonPane color) darker;
		layoutInset: 6;
		wrapDirection: nil;
		width: self width;
		layoutChanged; fullBounds.

	"Place holder for a tabs or text pane"
	tabsPane := Morph new
		setNameTo: 'TabPane';
		hResizing: #spaceFill;
		yourself.

	heights := { buttonPane height. 40 }.

	buttonPane vResizing: #spaceFill.
	self
		addMorph: buttonPane
		fullFrame: (LayoutFrame
				fractions: (0 @ 0 corner: 1 @ 0)
				offsets: (0 @ 0 corner: 0 @ heights first)).

	self
		addMorph: tabsPane
		fullFrame: (LayoutFrame
				fractions: (0 @ 0 corner: 1 @ 0)
				offsets: (0 @ heights first corner: 0 @ (heights first + heights second))).

	aBin := (PartsBin newPartsBinWithOrientation: #leftToRight from: #())
		listDirection: #leftToRight;
		wrapDirection: #topToBottom;
		color: aColor lighter lighter;
		setNameTo: 'Parts';
		dropEnabled: false;
		vResizing: #spaceFill;
		yourself.

	self
		addMorph: aBin
		fullFrame: (LayoutFrame
				fractions: (0 @ 0 corner: 1 @ 1)
				offsets: (0 @ (heights first + heights second) corner: 0 @ 0)).

	aBin color: (Color orange muchLighter);
		setNameTo: 'Objects' translated.

	self color: (Color orange muchLighter);
		setNameTo: 'Objects' translated.

]

{ #category : #initialization }
ObjectsTool >> initializeToStandAlone [
	"Initialize the receiver so that it can live as a stand-alone morph"

	| buttonPane aBin aColor tabsPane |
	self basicInitialize.
	
	self
		layoutInset: 0;
		useRoundedCorners;
		hResizing: #rigid;
		vResizing: #shrinkWrap;
		extent: RealEstateAgent standardSize;
		listDirection: #topToBottom;
		wrapDirection: #none.

	"mode buttons"
	buttonPane := self paneForTabs: self modeTabs.
	buttonPane color: self baseBackgroundColor.
	buttonPane
		vResizing: #shrinkWrap;
		setNameTo: 'ButtonPane';
		addMorphFront: self dismissButton;
		addMorphBack: self helpButton;
		color: (aColor := buttonPane color) darker;
		layoutInset: 5;
		width: self width;
		layoutChanged; fullBounds.

	"Place holder for a tabs or text pane"
	tabsPane := Morph new.
	tabsPane
		color: self baseBackgroundColor;
		setNameTo: 'TabPane';
		hResizing: #spaceFill;
		vResizing: #shrinkWrap.

	aBin := (PartsBin newPartsBinWithOrientation: #leftToRight from: #())
		changeTableLayout;
		listDirection: #leftToRight;
		wrapDirection: #topToBottom;
		vResizing: #shrinkWrap;
		color: aColor lighter lighter;
		borderColor: aColor lighter lighter;
		setNameTo: 'Parts';
		dropEnabled: false;
		yourself.
		
	self addMorphBack: buttonPane.
	self addMorphBack: tabsPane.
	self addMorphBack: aBin.
	
	self
		borderWidth: 1;
		borderColor: self baseBorderColor;
		color: self baseBackgroundColor;
		setNameTo: 'Objects' translated;
		showCategories.
]

{ #category : #tabs }
ObjectsTool >> initializeWithTabs: tabList [
	"Initialize the receiver to have the given tabs"

	| oldPane newPane |
	oldPane := self tabsPane ifNil: [ self searchPane ].
	newPane := (self paneForTabs: tabList)
		setNameTo: 'TabPane';
		yourself.
	self replaceSubmorph: oldPane by: newPane.


]

{ #category : #alphabetic }
ObjectsTool >> installQuads: quads fromButton: aButton [
	"Install items in the bottom pane that correspond to the given set of quads, as triggered from the given button"

	| aPartsBin sortedQuads oldResizing |
	aPartsBin := self partsBin.
	oldResizing := aPartsBin vResizing.
	aPartsBin removeAllMorphs.
	sortedQuads := ((PartsBin translatedQuads: quads)
		select: [ :each | Smalltalk hasClassNamed: each first ])
		sort: [ :a :b | a third < b third ].
	aPartsBin listDirection: #leftToRight quadList: sortedQuads.
	aButton ifNotNil: [self highlightOnlySubmorph: aButton in: self tabsPane].
	aPartsBin vResizing: oldResizing.
	aPartsBin layoutChanged; fullBounds.
]

{ #category : #layout }
ObjectsTool >> minimizePartsBinSize [
	self layoutChanged; fullBounds.
	self fixLayoutFrames.
	self setExtentFromHalo: (self minimumWidth @ self minimumHeight) 
]

{ #category : #layout }
ObjectsTool >> minimumBottom [
	| iconsBottom partsBin |
	partsBin := self partsBin ifNil: [ ^self bottom ].
	iconsBottom := partsBin submorphs isEmpty
		ifTrue: [ partsBin top + 60 ]
		ifFalse: [ partsBin submorphBounds bottom + partsBin layoutInset ].

	^iconsBottom + self layoutInset + self borderWidth
]

{ #category : #layout }
ObjectsTool >> minimumHeight [
	^(self minimumBottom - self top) max: 280
]

{ #category : #layout }
ObjectsTool >> minimumWidth [
	"Answer a width that assures that the alphabet fits in two rows.  For olpc, this is increased in order to make the Connectors category not too absurdly tall."

	^ 400
]

{ #category : #'major modes' }
ObjectsTool >> modeSymbol [
	"Answer the modeSymbol"

	^ modeSymbol
]

{ #category : #'major modes' }
ObjectsTool >> modeSymbol: aSymbol [
	"Set the receiver's modeSymbol as indicated"

	modeSymbol := aSymbol.
	self tweakAppearanceAfterModeShift.

]

{ #category : #'major modes' }
ObjectsTool >> modeTabs [
	"Answer a list of buttons which, when hit, will trigger the choice of mode of the receiver"

	| buttonList tupleList |
	tupleList :=  #(
		('alphabetic'		alphabetic	showAlphabeticTabs	'A separate tab for each letter of the alphabet')
		('find'				search			showSearchPane			'Provides a type-in pane allowing you to match')
		('categories'		categories	showCategories			'Grouped by category')

		"('standard'		standard		showStandardPane		'Standard Squeak tools supplies for building')"
	).
				
	buttonList := tupleList collect:
		[:tuple |
			| aButton |
			aButton := SimpleButtonMorph new label: tuple first translated.
			aButton actWhen: #buttonUp.
			aButton setProperty: #modeSymbol toValue: tuple second.
			aButton target: self; actionSelector: tuple third.
			aButton setBalloonText: tuple fourth translated.
			aButton borderWidth: 0.
			aButton].
	^ buttonList

"ObjectsTool new modeTabs"
]

{ #category : #search }
ObjectsTool >> newSearchPane [
	"Answer a type-in pane for searches"

	| aTextMorph |
	aTextMorph := TextMorph new
		setProperty: #defaultContents toValue: ('' asText allBold addAttribute: (TextFontChange font3));
		setTextStyle: (TextStyle fontArray: { Preferences standardEToysFont });
		setDefaultContentsIfNil;
		on: #keyStroke send: #searchPaneCharacter: to: self;
		setNameTo: 'SearchPane';
		setBalloonText: 'Type here and all entries that match will be shown.' translated;
		vResizing: #shrinkWrap;
		hResizing: #spaceFill;
		margins: 4@6;
		backgroundColor: Color white.
	^ aTextMorph
]

{ #category : #tabs }
ObjectsTool >> paneForTabs: tabList [ 
	"Answer a pane bearing tabs for the given list"
	| aPane |
	tabList do: [:t |
			t color: Color transparent.
			t borderWidth: 1;
				borderColor: Color black].

	aPane := Morph new
				changeTableLayout;
				color: self baseBackgroundColor;
				listDirection: #leftToRight;
				wrapDirection: #topToBottom;
				vResizing: #spaceFill;
				hResizing: #spaceFill;
				cellGap: 6;
				layoutInset: 4;
				listCentering: #center;
				addAllMorphs: tabList;
				yourself.

	aPane width: self layoutBounds width.

	^ aPane
]

{ #category : #'submorph access' }
ObjectsTool >> partsBin [
	^self findDeeplyA: PartsBin.
]

{ #category : #tabs }
ObjectsTool >> presentHelp [
	"Sent when a Help button is hit; provide the user with some form of help for the tool at hand"

	StringHolder new contents: 'The Objects tool allows you to browse through, and obtain copies of, many kinds of objects.  

You can obtain an Objects tool by choosing "Objects" from the world menu, or by the shortcut of typing alt-o (cmd-o) any time the cursor is over the desktop.

There are three ways to use Objects, corresponding to the three tabs seen at the top:

alphabetic - gives you separate tabs for a, b, c, etc.  Click any tab, and you will see the icons of all the objects whose names begin with that letter

search - gives you a type-in pane for a search string.  Type any letters there, and icons of all the objects whose names match what you have typed will appear in the bottom pane.

categories - provides tabs representing categories of related items.  Click on any tab to see the icons of all the objects in the category.

When the cursor lingers over the icon of any object, you will get balloon help for the item.

When you drag an icon from Objects, it will result in a new copy of it in your hand; the new object will be deposited wherever you next click.' translated; 
	openLabel: 'About Objects' translated
]

{ #category : #menu }
ObjectsTool >> resetThumbnails [
	"Reset the thumbnail cache"

	PartsBin clearThumbnailCache.
	modeSymbol == #categories ifTrue: [self showCategories] ifFalse: [self showAlphabeticTabs]
]

{ #category : #'submorph access' }
ObjectsTool >> searchPane [
	"Answer the receiver's search pane, nil if none"

	^ self submorphNamed: 'SearchPane' ifNone: [].
]

{ #category : #search }
ObjectsTool >> searchPaneCharacter: evt [
	"A character represented by the event handed in was typed in the search pane by the user"

	^ self showMorphsMatchingSearchString

"	| char |  *** The variant below only does a new search if RETURN or ENTER is hit ***
	char := evt keyCharacter.
	(char == Character enter or: [char == Character cr]) ifTrue:
		[self showMorphsMatchingSearchString]"
]

{ #category : #initialization }
ObjectsTool >> setDefaultParameters [
	
	self
		borderColor: self baseBorderColor;
		color: self baseBackgroundColor
]

{ #category : #layout }
ObjectsTool >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed"
	super setExtentFromHalo: ((anExtent x max: self minimumWidth) @ (anExtent y max: self minimumHeight)).

]

{ #category : #search }
ObjectsTool >> setSearchStringFromSearchPane [
	"Set the search string by obtaining its contents from the search pane, and doing a certain amount of munging"

	searchString := self searchPane text string asLowercase withBlanksTrimmed.
	searchString := searchString copyWithoutAll: {Character enter. Character cr}
]

{ #category : #search }
ObjectsTool >> showAll [
	"Put items matching the search string into my lower pane.
	showAll is for testing that all bin parts can be displayed.
	Currently it has no callers of use other than the test."
	| quads |
	self partsBin removeAllMorphs.
	self modeSymbol: nil .
	Cursor wait
		showWhile: [quads := OrderedCollection new.
			Morph withAllSubclasses
				do: [:aClass | aClass
						addPartsDescriptorQuadsTo: quads
						if: [:info | true ]].
			self installQuads: quads fromButton: nil]
]

{ #category : #'submorph access' }
ObjectsTool >> showAlphabeticCategory: aString fromButton: aButton [ 
	"Blast items beginning with a given letter into my lower pane"
	self partsBin removeAllMorphs.
	Cursor wait
		showWhile: [
			| eligibleClasses quads uc |
			uc := aString asUppercase asCharacter.
			eligibleClasses := Morph withAllSubclasses.
			quads := OrderedCollection new.
			eligibleClasses
				do: [:aClass | aClass theNonMetaClass
						addPartsDescriptorQuadsTo: quads
						if: [:info | info formalName translated asUppercase first = uc]].
			self installQuads: quads fromButton: aButton]
]

{ #category : #alphabetic }
ObjectsTool >> showAlphabeticTabs [
	"Switch to the mode of showing alphabetic tabs"

	modeSymbol == #alphabetic ifTrue: [ ^self ].
	self partsBin removeAllMorphs.
	self initializeWithTabs: self alphabeticTabs.
	self modeSymbol: #alphabetic.
	self tabsPane submorphs first doButtonAction
]

{ #category : #categories }
ObjectsTool >> showCategories [
	"Set the receiver up so that it shows tabs for each of the standard categories"

	modeSymbol == #categories ifTrue: [ ^self ].

	self partsBin removeAllMorphs.
	self initializeWithTabs: self tabsForCategories.
	self modeSymbol: #categories.
	self tabsPane submorphs first doButtonAction.

]

{ #category : #categories }
ObjectsTool >> showCategory: aCategoryName fromButton: aButton [ 
	"Project items from the given category into my lower pane"

	"self partsBin removeAllMorphs. IMHO is redundant, "
	Cursor wait
		showWhile: [
			| quads |
			quads := OrderedCollection new.
			Morph withAllSubclasses
				do: [:aClass | aClass theNonMetaClass
						addPartsDescriptorQuadsTo: quads
						if: [:aDescription | aDescription translatedCategories includes: aCategoryName]].
			quads sort: [:q1 :q2 | q1 third <= q2 third].
			self installQuads: quads fromButton: aButton]
]

{ #category : #search }
ObjectsTool >> showMorphsMatchingSearchString [
	"Put items matching the search string into my lower pane"
	self setSearchStringFromSearchPane.
	self partsBin removeAllMorphs.
	Cursor wait
		showWhile: [
			| quads |
			quads := OrderedCollection new.
			Morph withAllSubclasses
				do: [:aClass | aClass
						addPartsDescriptorQuadsTo: quads
						if: [:info | info formalName translated includesSubstring: searchString caseSensitive: false]].
			self installQuads: quads fromButton: nil]
]

{ #category : #search }
ObjectsTool >> showSearchPane [
	"Set the receiver up so that it shows the search pane"

	| tabsPane aPane |
	modeSymbol == #search ifTrue: [ ^self ].

	self partsBin removeAllMorphs.

	tabsPane := self tabsPane.
	aPane := self newSearchPane.
	self replaceSubmorph: tabsPane by: aPane.

	self modeSymbol: #search.
	self showMorphsMatchingSearchString.
	self currentHand newKeyboardFocus: aPane
]

{ #category : #categories }
ObjectsTool >> tabsForCategories [
	"Answer a list of buttons which, when hit, will trigger the choice of a category"

	| buttonList classes categoryList basic |
	classes := Morph withAllSubclasses.
	categoryList := Set new.
	classes do: [:aClass |
		(aClass class includesSelector: #descriptionForPartsBin) ifTrue:
			[categoryList addAll: aClass descriptionForPartsBin translatedCategories].
		(aClass class includesSelector: #supplementaryPartsDescriptions) ifTrue:
			[aClass supplementaryPartsDescriptions do:
				[:aDescription | categoryList addAll: aDescription translatedCategories]]].

	categoryList := categoryList asOrderedCollection sort.
	
	basic := categoryList remove: ' Basic' translated ifAbsent: [ ].
	basic ifNotNil: [ categoryList addFirst: basic ].

	basic := categoryList remove: 'Basic' translated ifAbsent: [ ].
	basic ifNotNil: [ categoryList addFirst: basic ].

	buttonList := categoryList collect:
		[:catName |
			| aButton |
			aButton := SimpleButtonMorph new label: catName.
			aButton actWhen: #buttonDown.
			aButton target: self; actionSelector: #showCategory:fromButton:; arguments: {catName. aButton}].
	^ buttonList

"ObjectsTool new tabsForCategories"
]

{ #category : #'submorph access' }
ObjectsTool >> tabsPane [
	"Answer the receiver's tabs pane, nil if none"

	^ self submorphNamed: 'TabPane' ifNone: [].
]

{ #category : #initialization }
ObjectsTool >> tweakAppearanceAfterModeShift [
	"After the receiver has been put into a given mode, make an initial selection of category, if appropriate, and highlight the mode button."
	
	self buttonPane submorphs do:
		[:aButton | 
			| aColor |
			"aButton borderWidth: 1."
			aColor := (aButton valueOfProperty: #modeSymbol) = modeSymbol
				ifTrue: [self buttonActiveColor]
				ifFalse: [self buttonColor].

			aButton firstSubmorph color: aColor.
			aButton borderColor: aColor].
]
