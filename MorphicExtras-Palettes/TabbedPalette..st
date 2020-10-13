"
A structure of tabs and associated books.  Pressing a tab brings into focus the associated book.  Some tabs can have simple actions rather than books as their focus -- in this case, the palette is cleared and the action taken. 
"
Class {
	#name : #TabbedPalette,
	#superclass : #BookMorph,
	#instVars : [
		'tabsMorph'
	],
	#category : #'MorphicExtras-Palettes'
}

{ #category : #scripting }
TabbedPalette class >> authoringPrototype [
	| aTabbedPalette aBook aTab |
	aTabbedPalette := self new markAsPartsDonor.
	aTabbedPalette pageSize: 200 @ 300.
	aTabbedPalette tabsMorph highlightColor: Color red regularColor: Color blue.
	aTabbedPalette addMenuTab.

	aBook := BookMorph new setNameTo: 'one'; pageSize: aTabbedPalette pageSize.
	aBook color: Color blue muchLighter.
	aBook removeEverything; insertPage; showPageControls.
	aBook currentPage addMorphBack: (Project current world drawingClass withForm: ScriptingSystem squeakyMouseForm).
	aTab := aTabbedPalette addTabForBook: aBook.

	aBook := BookMorph new setNameTo: 'two'; pageSize: aTabbedPalette pageSize.
	aBook color: Color red muchLighter.
	aBook removeEverything; insertPage; showPageControls.
	aBook currentPage addMorphBack: CurveMorph authoringPrototype.
	aTabbedPalette addTabForBook: aBook.

	aTabbedPalette selectTab: aTab.

	aTabbedPalette beSticky.
	aTabbedPalette tabsMorph hResizing: #spaceFill.
	^ aTabbedPalette
]

{ #category : #printing }
TabbedPalette class >> defaultNameStemForInstances [
	^ 'tabbedPalette' translatedNoop
]

{ #category : #'parts bin' }
TabbedPalette class >> descriptionForPartsBin [
	^ DescriptionForPartsBin
		formalName: 'TabbedPalette'
		categoryList: #('Presentation')
		documentation: 'A tabbed palette of books'
		globalReceiverSymbol: #TabbedPalette
		nativitySelector: #authoringPrototype
]

{ #category : #'class initialization' }
TabbedPalette class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
TabbedPalette class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: #(TabbedPalette	authoringPrototype	'TabbedPalette'	'A structure with tabs')
						forFlapNamed: 'Supplies'.]
]

{ #category : #'class initialization' }
TabbedPalette class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'palette menu' }
TabbedPalette >> addBookMenuItemsTo: aCustomMenu hand: aHandMorph [ 
	aCustomMenu add: 'add palette menu' translated action: #addMenuTab.
	aCustomMenu add: 'become the Standard palette' translated action: #becomeStandardPalette
]

{ #category : #'palette menu' }
TabbedPalette >> addMenuTab [
	"Add the menu tab.  This is ancient code, not much in the spirit of anything current"

	| aMenu aTab aGraphic sk |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu stayUp: true.
	"aMenu add:  'clear' translated action: #showNoPalette."
	aMenu add:  'sort tabs' translated action: #sortTabs:.
	aMenu add:  'choose new colors for tabs' translated action: #recolorTabs.
	aMenu setProperty: #paletteMenu toValue: true.
	"aMenu add:  'make me the Standard palette' translated action: #becomeStandardPalette."
	aTab := self addTabForBook: aMenu  withBalloonText: 'a menu of palette-related controls' translated.
	aTab highlightColor: tabsMorph highlightColor; regularColor: tabsMorph regularColor.
	tabsMorph laySubpartsOutInOneRow; layoutChanged.

	aGraphic := ScriptingSystem formAtKey: 'TinyMenu'.
	aGraphic ifNotNil:
		[aTab removeAllMorphs.
		aTab addMorph: (sk := Project current world drawingClass withForm: aGraphic).
		sk position: aTab position.
		sk lock.
		aTab fitContents].
	self layoutChanged
]

{ #category : #initialization }
TabbedPalette >> addTabFor: aReferent font: aFont [
	| aTab |
	aTab := tabsMorph addTabFor: aReferent font: aFont.
	pages add: aReferent.
	currentPage ifNil: [currentPage := aReferent].
	^ aTab
]

{ #category : #initialization }
TabbedPalette >> addTabForBook: aBook [
	| aTab |
	aTab := tabsMorph addTabForBook: aBook.
	pages add: aBook.
	currentPage ifNil: [currentPage := aBook].
	^ aTab
]

{ #category : #initialization }
TabbedPalette >> addTabForBook: aBook withBalloonText: text [
	| aTab |
	aTab := tabsMorph addTabForBook: aBook.
	pages add: aBook.
	currentPage ifNil: [currentPage := aBook].
	text ifNotNil: [aTab setBalloonText: text].
	^ aTab
]

{ #category : #'misc menu items' }
TabbedPalette >> becomeStandardPalette [
	self presenter standardPalette: self
]

{ #category : #miscellaneous }
TabbedPalette >> currentPalette [
	"A stylistic convenience to reduce confusion caused by the fact that a palette is a book of books"
	^ currentPage
]

{ #category : #initialization }
TabbedPalette >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color transparent
]

{ #category : #initialization }
TabbedPalette >> defaultPageSize [
	^ 156 @ 232
]

{ #category : #'halos and balloon help' }
TabbedPalette >> defersHaloOnClickTo: aSubMorph [
	"If a cmd-click on aSubMorph would make it a preferred recipient of the halo, answer true"

	^ currentPage notNil and:
		[(aSubMorph hasOwner: currentPage)
			and: [currentPage defersHaloOnClickTo: aSubMorph]]
	
]

{ #category : #'scraps tab' }
TabbedPalette >> hasScrapsTab [
	pages detect: [:p | (p hasProperty: #scraps)] ifNone: [^ false].
	^ true
]

{ #category : #initialization }
TabbedPalette >> initialize [
	"Initialize the receiver, which was just created via a call to the  
	class's #basicNew"
	super initialize.
	""
	pageSize := self defaultPageSize.
	self removeEverything.
	
	tabsMorph := IndexTabs new.
	self addMorph: tabsMorph
]

{ #category : #initialization }
TabbedPalette >> newTabs: tabsList [
	"Reconstitute the palette based on info in the tabs list"

	| color1 color2 color3 |
	pages := pages species new.
	tabsMorph ifNotNil:
		[color1 := tabsMorph  highlightColor.
		color2 := tabsMorph regularColor.
		color3 := tabsMorph color.
		tabsMorph delete].
	tabsMorph := IndexTabs new.
	self addMorphFront: tabsMorph.
	color1 ifNotNil:
		[tabsMorph highlightColor: color1 regularColor: color2; color: color3].
	currentPage ifNotNil:
		[currentPage delete.
		currentPage := nil].
	tabsList do:
		[:aTab | | itsBook |
			tabsMorph addTab: aTab.
			aTab unHighlight.
			(itsBook := aTab morphToInstall) ifNotNil:
					[pages add: itsBook.
					currentPage ifNil: [currentPage := itsBook]]].
	tabsMorph position: self position + self borderWidth
]

{ #category : #'misc menu items' }
TabbedPalette >> recolorTabs [
	"Prompt the user for new on and off colors for tabs"

	| onColor offColor |
	self inform: 'Choose the ''on'' color'.
	onColor := Color fromUser.

	self inform: 
'Okay, now please choose
the ''off'' color'.
	offColor := Color fromUser.

	tabsMorph highlightColor: onColor regularColor: offColor.
	currentPage ifNotNil:
		[tabsMorph highlightTabFor: currentPage]
]

{ #category : #'submorphs-add\/remove' }
TabbedPalette >> replaceSubmorph: oldMorph by: newMorph [
	super replaceSubmorph: oldMorph by: newMorph.
	oldMorph == currentPage ifTrue:
		[currentPage := newMorph]
]

{ #category : #'scraps tab' }
TabbedPalette >> scrapsBook [
	^ pages detect: [:p | p hasProperty: #scraps] ifNone: [nil]
]

{ #category : #'user-interface' }
TabbedPalette >> selectTab: aTab [
	| currentPalette morphToInstall oldTab aSketchEditor |
	currentPage ifNotNil:
		[self currentPalette currentPlayerDo:
			[:aPlayer | aPlayer runAllClosingScripts]].
	oldTab := tabsMorph highlightedTab.
	(oldTab notNil and: [(morphToInstall := oldTab morphToInstall) isKindOf: PaintBoxMorph])
		ifTrue:
			[(aSketchEditor := self world submorphOfClass: SketchEditorMorph) ifNotNil:
				[aSketchEditor cancelOutOfPainting].
			morphToInstall delete].

	tabsMorph selectTab: aTab.
	morphToInstall := aTab morphToInstall.

	(morphToInstall isKindOf: PaintBoxMorph) "special case, maybe generalize this need?"
		ifFalse:
			[self goToPageMorph: morphToInstall]
		ifTrue:
			[self showNoPaletteAndHighlightTab: aTab.
			self world addMorphFront: morphToInstall.
			morphToInstall position: ((self left max: 90) "room for the pop-out-to-left panel"
				@ (tabsMorph bottom))].
	
	(currentPalette := self currentPalette) ifNotNil:
		[currentPalette layoutChanged.
		currentPalette currentPlayerDo: [:aPlayer | aPlayer runAllOpeningScripts]].
	self snapToEdgeIfAppropriate
]

{ #category : #'user-interface' }
TabbedPalette >> selectTabNamed: aName [
	"If the receiver has a tab with the given name, select it"

	| aTab |
	aTab := self tabNamed: aName.
	aTab ifNotNil: [self selectTab: aTab]
]

{ #category : #'user-interface' }
TabbedPalette >> selectTabOfBook: aBook [
	self tabMorphs do:
		[:aTab | aTab morphToInstall == aBook ifTrue: [^ self selectTab: aTab]]
]

{ #category : #other }
TabbedPalette >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed.  For a BookMorph, we assume any resizing attempt is a request that the book-page currently being viewed be resized accoringly; this will typically not affect unseen book pages, though there is a command that can be issued to harmonize all book-page sizes, and also an option to set that will maintain all pages at the same size no matter what."

	currentPage isInWorld
		ifFalse: "doubtful case mostly"
			[super setExtentFromHalo: anExtent]
		ifTrue:
			[currentPage setExtentFromHalo: ((anExtent x @ (anExtent y - (self innerBounds height - currentPage height))) - (2 * (self borderWidth @ self borderWidth))).
			self maintainsUniformPageSize ifTrue:
				[self setProperty: #uniformPageSize toValue: currentPage extent]]
]

{ #category : #initialization }
TabbedPalette >> setInitialState [
	super setInitialState.
""
	self layoutInset: 0.
	pageSize := 156 @ 232
]

{ #category : #'misc menu items' }
TabbedPalette >> showNoPalette [
	self showNoPaletteAndHighlightTab: nil
]

{ #category : #'misc menu items' }
TabbedPalette >> showNoPaletteAndHighlightTab: aTab [

	| oldTab morphToInstall aSketchEditor |
	oldTab := tabsMorph highlightedTab.
	(oldTab notNil and: [(morphToInstall := oldTab morphToInstall) isKindOf: PaintBoxMorph])
		ifTrue:
			[(aSketchEditor := self world submorphOfClass: SketchEditorMorph) ifNotNil:
				[aSketchEditor cancelOutOfPainting].
			morphToInstall delete].

	currentPage ifNotNil: [currentPage delete].
	currentPage := nil.
	submorphs size > 1 ifTrue: "spurious submorphs, yecch"
		[(submorphs copyFrom: 2 to: submorphs size) do: [:m | m delete]].
	tabsMorph highlightTab: aTab
]

{ #category : #'scraps tab' }
TabbedPalette >> showScrapsTab [
	self selectTabOfBook: self scrapsBook
]

{ #category : #'misc menu items' }
TabbedPalette >> sortTabs: evt [
	TabSorterMorph new sortTabsFor: self.  "it directly replaces me"
	self delete

]

{ #category : #'user-interface' }
TabbedPalette >> tabMorphs [
	^ tabsMorph tabMorphs
]

{ #category : #'user-interface' }
TabbedPalette >> tabNamed: aName [
	"Answer the tab of the given name, or nil if none"

	^ self tabMorphs detect: [:m | ((m isKindOf: StringMorph) and: [m contents = aName])
		or: [(m isKindOf: ReferenceMorph) and: [(m firstSubmorph isKindOf: StringMorph) and:
				[m firstSubmorph contents = aName]]]] ifNone: [nil]
]

{ #category : #miscellaneous }
TabbedPalette >> tabsMorph [
	^ tabsMorph
]

{ #category : #navigation }
TabbedPalette >> transitionSpecFor: aMorph [
	^ aMorph valueOfProperty: #transitionSpec  " check for special propety"
		ifAbsent: [Array with: 'silence'  " ... otherwise this is the default"
						with: #none
						with: #none]
]

{ #category : #'dropping\/grabbing' }
TabbedPalette >> wantsDroppedMorph: aMorph event: evt [ 
	(tabsMorph bounds containsPoint: (self pointFromWorld: evt cursorPoint)) 
		ifTrue: [^false	"unless it's a book, perhaps, someday"].
	^currentPage isNil or: [currentPage wantsDroppedMorph: aMorph event: evt]
]
