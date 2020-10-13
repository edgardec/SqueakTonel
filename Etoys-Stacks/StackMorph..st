"
A book that is very much like a HyperCard stack.  

Each book page represents a different background.  The page stays while different cards are projected onto it.  
	The data for a single card is stored in a CardPlayer.  There is a list of objects that only appear on this card (privateMorphs) and the card-specific text to be inserted into the background fields.

Item					How it is stored
a background			a page of the StackMorph
a card					data is in an instance of a subclass of CardPlayer.
						A list of CardPlayers is in the 'cards' inst var of the StackMorph.
a background field		a TextMorph on a page of the StackMorph
a background picture	a morph of any kind on a page of the StackMorph
script for bkgnd button		method in Player.  Button is its costume.
text in a background field		value of inst var 'field1' in a CardPlayer.
								(The CardPlayer is also pointed at by the #cardInstance 
								property of the bkgnd field (TextMorph))
text in a card field		in the TextMorph in privateMorphs in the CardPlayer.
picture on a card		a morph of any kind in privateMorphs in the CardPlayer.
script for card button	method in the CardPlayer.  Button is its costume.

See VariableDock.
"
Class {
	#name : #StackMorph,
	#superclass : #BookMorph,
	#instVars : [
		'cards'
	],
	#category : #'Etoys-Stacks'
}

{ #category : #scripting }
StackMorph class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."

	^ # ((#'stack navigation'
			((command goToNextCardInStack 'Go to the next card')
			(command goToPreviousCardInStack  'Go to the previous card')
			(command goToFirstCardInBackground 'Go to the first card of the current background')
			(command goToFirstCardOfStack 'Go to the first card of the entire stack')
			(command goToLastCardInBackground 'Go to the last card of the current background')
			(command goToLastCardOfStack 'Go to the last card of the entire stack')
			(command deleteCard 'Delete the current card')
			(command insertCard 'Create a new card')
			(slot cardNumber 'The ordinal number of the current card' Number readWrite Player getCardNumber Player setCardNumber:))))
]

{ #category : #scripting }
StackMorph class >> authoringPrototype [
	"Answer an instance of the receiver suitable for placing in a parts bin for authors"
	
	| book |
	book := self new markAsPartsDonor.
	book pageSize: (480 @ 320); color: (Color gray: 0.7).
	book borderWidth: 1; borderColor: Color black.
	book currentPage extent: book pageSize.
	book showPageControls: book fullControlSpecs.
	^ book

"self currentHand attachMorph: StackMorph authoringPrototype"
]

{ #category : #'parts bin' }
StackMorph class >> descriptionForPartsBin [
	^ self partName:	'Stack'
		categories:		#('Presentation')
		documentation:	'A database of any sort -- slide show, rolodex, and any point in between'
]

{ #category : #'authoring prototype' }
StackMorph class >> designationsExplainer [
	"Answer a morph that contains designation explanation"

	| aMorph |
	aMorph := AlignmentMorph newColumn color: Color black; layoutInset: 1.
	#((green		
'Shared items on
Background.
Exact same item
shared by every card')
	(orange
'Data items on
Background
Each card has its
own data')
	(red
'Instance-specific
items
unique
to this card')) do:

	[:aPair |
		| aSwatch aTextMorph |
		aSwatch := AlignmentMorph new extent: 132 @80; color: (Color perform: aPair first); lock.
		aSwatch hResizing: #rigid; vResizing: #rigid; layoutInset: 0.
		aSwatch borderColor: Color black.
		aTextMorph := TextMorph new string: aPair second fontName: Preferences standardEToysFont familyName size: 18.
		aTextMorph width: 130.
		aTextMorph centered.
		aSwatch addMorphBack: aTextMorph.
		aMorph addMorphBack: aSwatch].
	aMorph hResizing: #shrinkWrap; vResizing: #shrinkWrap.

	^ aMorph

	"StackMorph designationsExplainer openInHand"

]

{ #category : #misc }
StackMorph class >> discoverSlots: aMorph [
	"Examine the parts of the morph for ones that couldHoldSeparateData.  Return a pair of lists: Named morphs, and unnamed morphs (which may be labels, and non-data).  Examine all submorphs."

	| named unnamed |
	named := OrderedCollection new.
	unnamed := OrderedCollection new.
	aMorph submorphsDo: [:direct | | got | 
		got := false.
		direct allMorphsDo: [:sub | | generic sn |
			sub couldHoldSeparateDataForEachInstance ifTrue: [
				(sn := sub knownName) ifNotNil: [
					generic := (#('Number (fancy)' 'Number (mid)' 'Number (bare)')
									includes: sn).
					(sn beginsWith: 'shared' "label") | generic ifFalse: [
						named add: sub.
						got := true]]]].
		got ifFalse: [unnamed add: direct]].
	^ Array with: named with: unnamed
		
]

{ #category : #'class initialization' }
StackMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'navigation buttons' }
StackMorph class >> nextCardButton [
	"Answer a button that advances the user to the next card in the stack"

	| aButton |
	aButton := SimpleButtonMorph new.
	aButton target: aButton; actionSelector: #goToNextCardInStack; label: '>'; color: Color yellow; borderWidth: 0.
	aButton setNameTo: 'next'.
	^ aButton
]

{ #category : #'navigation buttons' }
StackMorph class >> previousCardButton [
	"Answer a button that will take the user to the preceding card in the stack"

	| aButton |
	aButton := SimpleButtonMorph new.
	aButton target: aButton; actionSelector: #goToPreviousCardInStack; label: '<'; color: Color yellow ; borderWidth: 0.
	aButton setNameTo: 'previous'.
	^ aButton
]

{ #category : #'class initialization' }
StackMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#StackMorph. #authoringPrototype. 'Stack' translatedNoop. 'A multi-card data base' translatedNoop}	
						forFlapNamed: 'Scripting'.
						cl registerQuad: {#StackMorph. #authoringPrototype. 'Stack' translatedNoop. 'A multi-card data base' translatedNoop}
						forFlapNamed: 'Stack Tools'.
						cl registerQuad: {#StackMorph. #stackHelpWindow. 'Stack Help' translatedNoop. 'Some hints about how to use Stacks' translatedNoop}
						forFlapNamed: 'Stack Tools'.
						cl registerQuad: {#StackMorph. #previousCardButton. 'Previous Card' translatedNoop. 'A button that takes the user to the previous card in the stack' translatedNoop}
						forFlapNamed: 'Stack Tools'.
						cl registerQuad: {#StackMorph. #nextCardButton. 'Next Card' translatedNoop. 'A button that takes the user to the next card in the stack' translatedNoop}
						forFlapNamed: 'Stack Tools']
]

{ #category : #'parts bin' }
StackMorph class >> stackHelpWindow [
	^ (Workspace new contents: 'A "stack" is a place where you can create, store, view and retrieve data "fields" from a set of "cards".  Data that you want to occur on every card (such as a name and an address in an Address Stack) are represented by objects such as "Simple Text", "Fancy Text", and "Scrolling Text" that you obtain from the Stack Tools flap.

When you look at a card in a Stack, you may be seeing three different kinds of material.  Press the § button in the stack''s controls to see the current designations, and use the "explain designations" to get a reminder of what the three different colors mean.
·  Things that are designated to be seen on every card, and have the same contents whichever card is being shown. (green)
·  Things that are designated to be seen on every card, with each card having its own value for them. (orange)
·  Things that are designated to occur only on the particular card at hand. (red)

Use the "stack/cards" menu (in an object''s halo menu) to change the designation of any object.  For example, if you have an object that is private to just one card, and you want to make it visible on all cards, use "place onto background".  If you further want it to hold a separate value for each separate card, use "start holding separate data for each instance".

The normal sequence to define a Stack''s structure is to obtain a blank Stack, then create your fields by grabbing what you want from the Stack Tools flap and dropping it where you want it in the stack.  For easiest use, give a name to each field (by editing the name in its halo) *before* you put it onto the background..  Those fields that you want to represent the basic data of the stack need to be given names, placed on the background, and then told to hold separate data.

When you hit the + button in a stack''s controls, a new card is created with default values in all the fields.  You can arrange for a particular default value to be used in a field -- do this either for one field at a time with "be default value on new card", or you can request that the all the values seen on a particular card serve as default by choosing "be defaults for new cards" from the stack''s · menu.

It is also possible to have multiple "backgrounds" in the same stack -- each different background defines a different data structure, and cards from multiple backgrounds can be freely mixed in the same stack.

Besides text fields, it is also possible to have picture-valued fields -- and potentially fields with data values of any other type as well.' translated)

	embeddedInMorphicWindowLabeled: 'Stack Help'

	"StackMorph stackHelpWindow"
]

{ #category : #'class initialization' }
StackMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menu }
StackMorph >> addBookMenuItemsTo: aMenu hand: aHandMorph [
	"Add book-related items to the given menu"

	| controlsShowing subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	subMenu add: 'previous card' translated action: #goToPreviousCardInStack.
	subMenu add: 'next card' translated action: #goToNextCardInStack.
	subMenu add: 'go to card...' translated action: #goToCard.
	subMenu add: 'insert a card' translated action: #insertCard.
	subMenu add: 'delete this card' translated action: #deleteCard.

	controlsShowing := self hasSubmorphWithProperty: #pageControl.
	controlsShowing
		ifTrue:
			[subMenu add: 'hide card controls' translated action: #hidePageControls.
			subMenu add: 'fewer card controls' translated action: #fewerPageControls]
		ifFalse:
			[subMenu add: 'show card controls' translated action: #showPageControls].

	subMenu addLine.
	subMenu add: 'sound effect for all backgrounds' translated action: #menuPageSoundForAll:.
	subMenu add: 'sound effect this background only' translated action: #menuPageSoundForThisPage:.
	subMenu add: 'visual effect for all backgrounds' translated action: #menuPageVisualForAll:.
	subMenu add: 'visual effect this background only' translated action: #menuPageVisualForThisPage:.

	subMenu addLine.
	subMenu add: 'sort pages' translated action: #sortPages:.
	subMenu add: 'uncache page sorter' translated action: #uncachePageSorter.
	(self hasProperty: #dontWrapAtEnd)
		ifTrue: [subMenu add: 'wrap after last page' translated selector: #setWrapPages: argument: true]
		ifFalse: [subMenu add: 'stop at last page' translated selector: #setWrapPages: argument: false].

	subMenu  addUpdating: #showingFullScreenString action: #toggleFullScreen.
	subMenu addLine.
	subMenu add: 'search for text' translated action: #textSearch.
	(self primaryHand pasteBuffer class isKindOf: PasteUpMorph class) ifTrue:
		[subMenu add: 'paste book page' translated action: #pasteBookPage].

	subMenu add: 'send all pages to server' translated action: #savePagesOnURL.
	subMenu add: 'send this page to server' translated action: #saveOneOnURL.
	subMenu add: 'reload all from server' translated action: #reload.
	subMenu add: 'copy page url to clipboard' translated action: #copyUrl.
	subMenu add: 'keep in one file' translated action: #keepTogether.
	subMenu add: 'save as new-page prototype' translated action: #setNewPagePrototype.
	newPagePrototype ifNotNil:
		[subMenu add: 'clear new-page prototype' translated action: #clearNewPagePrototype].

	aMenu add: 'book...' translated subMenu: subMenu

]

{ #category : #background }
StackMorph >> addCardsFromAFile [
	"Using the current background, create new cards by reading in data from a fileThe data are in each record are expected to be tab-delimited, and to occur in the same order as the instance variables of the current-background's cards "

	| fileName |
	fileName := FileChooserDialog openOn: FileDirectory default.
	fileName ifNil:[^Beeper beep].
	FileStream oldFileNamed: fileName do:[:fs|
		self addCardsFromFile: fs].
]

{ #category : #background }
StackMorph >> addCardsFromClipboardData [
	"Using the current background, paste data from the (textual) clipboard to create new records.  The data are in each record are expected to be tab-delimited, and to occur in the same order as the instance variables of the current-background's cards "

	| clip |
	(clip := Clipboard clipboardText) isEmptyOrNil ifTrue: [^ Beeper beep].
	self addCardsFromString: clip
]

{ #category : #background }
StackMorph >> addCardsFromClipboardDataForInstanceVariables: slotNames [
	"Using the current background, paste data from the (textual) clipboard to create new records.  No senders, but can be usefully called manually for selectively bringing in data in oddball format."

	| clip |
	(clip := Clipboard clipboardText) isEmptyOrNil ifTrue: [^ Beeper beep].
	self addCardsFromString: clip slotNames: slotNames
]

{ #category : #background }
StackMorph >> addCardsFromFile: fileStream [
	"Using the current background, take tab delimited data from the file to create new records."

	| aString |
	(aString := fileStream contentsOfEntireFile) isEmptyOrNil ifTrue: [^ Beeper beep].
	self addCardsFromString: aString
]

{ #category : #background }
StackMorph >> addCardsFromString: aString [
	"Using the current background, add cards from a string, which is expected be tab- and return-delimited.  The data are in each record are expected to be tab-delimited, and to occur in the same order as the instance variables of the current-background's cards "

	self addCardsFromString: aString slotNames: self currentCard slotNames
 

]

{ #category : #background }
StackMorph >> addCardsFromString: aString slotNames: slotNames [ 
	"Using the current background, add cards from a string, which is expected be tab- and return-delimited"

	| count |
	count := 0.
	aString asString linesDo: 
			[:aLine | 
			aLine notEmpty 
				ifTrue: 
					[count := count + 1.
					self 
						insertCardOfBackground: self currentPage
						withDataFrom: aLine
						forInstanceVariables: slotNames]].
	self inform: count asString , ' card(s) added' translated
]

{ #category : #'page controls' }
StackMorph >> addPageControlMorph: aMorph [
	"Add the given morph as a page-control, at the appropriate place"

	aMorph setProperty: #pageControl toValue: true.
	self addPane: aMorph paneType: #pageControl
]

{ #category : #initialization }
StackMorph >> addPane: aPane paneType: aType [
	| anIndex |
	anIndex := self insertionIndexForPaneOfType: aType.
	self privateAddMorph: aPane atIndex: anIndex
]

{ #category : #'submorphs-accessing' }
StackMorph >> allNonSubmorphMorphs [
	"Return a collection containing all morphs in this morph which are not currently in the submorph containment hierarchy.  Especially the non-showing pages in BookMorphs."

	| coll |
	coll := OrderedCollection new.
	self privateCards do: [:cd | 
		cd privateMorphs ifNotNil: [coll addAll: cd privateMorphs]].
	^ coll
]

{ #category : #background }
StackMorph >> backgroundWithCard: aCard [
	"Answer the background which contains aCard."

	^ self backgrounds detect:
		[:aBackground | aBackground containsCard: aCard] ifNone: [nil]
]

{ #category : #background }
StackMorph >> backgrounds [
	"Answer the list of backgrounds available in the receiver"

	^ self pages
]

{ #category : #background }
StackMorph >> beDefaultsForNewCards [
	"Make the values that I see here all be accepted as defaults for new cards"

	self currentPage submorphs do:
		[:aMorph | aMorph holdsSeparateDataForEachInstance ifTrue:
			[aMorph setAsDefaultValueForNewCard]]
]

{ #category : #'card access' }
StackMorph >> browseCardClass [
	"Browse the class of the current card"

	| suffix |
	suffix := self currentCard class name numericSuffix.
	ToolSet browseHierarchy: self currentCard class selector: nil.

]

{ #category : #'card access' }
StackMorph >> cardIndexOf: aCard [
	"Answer the ordinal position of aCard in the receiver's list"

	^ self privateCards indexOf: aCard ifAbsent: [nil]
]

{ #category : #accessing }
StackMorph >> cardNumberOf: aPlayer [
	"Answer the card-number of the given player, in the which-card-of-the-stack sense."

	^ self cards identityIndexOf: aPlayer
]

{ #category : #'card access' }
StackMorph >> cards [
	"Answer a list of the cards of the receiver, in order"

	^ self privateCards copy
]

{ #category : #accessing }
StackMorph >> cardsOrPages [
	"The turnable and printable entities"

	^ self cards
]

{ #category : #background }
StackMorph >> changeInstVarOrder [
	"Change the order of the receiver's instance variables"

	| reply |
	reply := UIManager default request: 'rearrange, then accept; or cancel' initialAnswer:
		((self currentPage player class instVarNames asArray collect: [:v | v asSymbol]) storeString copyWithoutAll: #($# $( $))) asString.
	reply isEmptyOrNil ifTrue: [^ self].
	self flag: #deferred.  "Error checking and graceful escape wanted"
	self currentPage player class resortInstanceVariables: (Compiler evaluate:
		('#(', reply, ')'))
]

{ #category : #'as yet unclassified' }
StackMorph >> commitCardData [
	"Make certain that the player data are written back to the player instance"

	^ self currentCard commitCardPlayerData 

]

{ #category : #'card access' }
StackMorph >> currentCard [
	"Answer the current card of the current background of the receiver"

	^ currentPage currentDataInstance
]

{ #category : #'insert and delete' }
StackMorph >> defaultNameStemForNewPages [
	"Answer the stem to use as the default for names of cards in the stack"

	^ 'card'

]

{ #category : #'card access' }
StackMorph >> deleteAllCardsExceptThisOne [
	"Delete all cards except the current one"

	self privateCards size <= 1 ifTrue: [^ Beeper beep].
	(self confirm: 'Really delete ' translated, self privateCards size asString, ' card(s) and all of their data?' translated) ifTrue:
		[self privateCards: (OrderedCollection with: self currentCard)].
]

{ #category : #'card access' }
StackMorph >> deleteCard [
	"Delete the current card from the stack"

	| aCard |
	aCard := self currentCard.
	self privateCards size = 1 ifTrue: [^ Beeper beep].
	(self confirm: 'Really delete this card and all of its data?' translated) ifTrue:
		[self goToNextCardInStack.
		self privateCards remove: aCard].
]

{ #category : #'card access' }
StackMorph >> deleteCard: aCard [
	"Delete the current card from the stack."

	self privateCards size = 1 ifTrue: [^ Beeper beep].
	(aCard == self currentCard) ifTrue: [^ self deleteCard].

	self privateCards remove: aCard ifAbsent: []
]

{ #category : #'card in a stack' }
StackMorph >> explainDesignations [
	"Give the user an explanation of what the designations mean"

	self currentPage explainDesignations

]

{ #category : #menu }
StackMorph >> findText: wants [
	"Turn to the next card that has all of the strings mentioned on it.  Highlight where it is found.  allText and allTextUrls have been set.  Case insensitive search.
	Resuming a search.  If container's text is still in the list and secondary keys are still in the page, (1) search rest of that container.  (2) search rest of containers on that page (3) pages till end of book, (4) from page 1 to this page again."

	"Later sort wants so longest key is first"
	| allText here fromHereOn startToHere oldContainer oldIndex otherKeys strings good |
	allText := self valueOfProperty: #allText ifAbsent: [#()].
	here := self privateCards identityIndexOf: self currentCard ifAbsent: [1].
	fromHereOn := here+1 to: self privateCards size.
	startToHere := 1 to: here.		"repeat this page"
	(self valueOfProperty: #searchKey ifAbsent: [#()]) = wants ifTrue: [
		"does page have all the other keys?  No highlight if found!"
		otherKeys := wants allButFirst.
		strings := allText at: here.
		good := true.
		otherKeys do: [:searchString | | thisWord | "each key"
			good ifTrue: [thisWord := false.
				strings do: [:longString |
					(longString findWordStart: searchString startingAt: 1) > 0 ifTrue: [
							thisWord := true]].
				good := thisWord]].
		good ifTrue: ["all are on this page.  Look in rest for string again."
			oldContainer := self valueOfProperty: #searchContainer.
			oldIndex := self valueOfProperty: #searchOffset.
			(self findText: (OrderedCollection with: wants first) inStrings: strings	
				startAt: oldIndex+1 container: oldContainer 
				cardNum: here) ifTrue: [
					self setProperty: #searchKey toValue: wants.
					^ true]]]
		ifFalse: [fromHereOn := here to: self privateCards size].	"do search this page"
	"other pages"
	fromHereOn do: [:cardNum |
		(self findText: wants inStrings: (allText at: cardNum) startAt: 1 container: nil 
				cardNum: cardNum) 
					ifTrue: [^ true]].
	startToHere do: [:cardNum |
		(self findText: wants inStrings: (allText at: cardNum) startAt: 1 container: nil 
				cardNum: cardNum) 
					ifTrue: [^ true]].
	"if fail"
	self setProperty: #searchContainer toValue: nil.
	self setProperty: #searchOffset toValue: nil.
	self setProperty: #searchKey toValue: nil.
	^ false
]

{ #category : #menu }
StackMorph >> findText: keys inStrings: rawStrings startAt: startIndex container: oldContainer cardNum: cardNum [ 
	"Call once to search a card of the stack.  Return true if found and highlight the text.  oldContainer should be NIL.  
	(oldContainer is only non-nil when (1) doing a 'search again' and (2) the page is in memory and (3) keys has just one element.  oldContainer is a TextMorph.)"

	| container strings old good insideOf place start |
	good := true.
	start := startIndex.
	strings := oldContainer ifNil: 
					["normal case"

					rawStrings]
				ifNotNil: [self currentPage allStringsAfter: oldContainer text].
	keys do: 
			[:searchString | | thisWord | 
			"each key"

			good 
				ifTrue: 
					[thisWord := false.
					strings do: 
							[:longString | | index | 
							(index := longString findWordStart: searchString startingAt: start) > 0 
								ifTrue: 
									[thisWord not & (searchString == keys first) 
										ifTrue: 
											[insideOf := longString.
											place := index].
									thisWord := true].
							start := 1].	"only first key on first container"
					good := thisWord]].
	good 
		ifTrue: 
			["all are on this page"

			"wasIn := (pages at: pageNum) isInMemory."

			self goToCardNumber: cardNum
			"wasIn ifFalse: ['search again, on the real current text.  Know page is in.'.
			^ self findText: keys 
				inStrings: ((pages at: pageNum) allStringsAfter: nil)         recompute it	
				startAt: startIndex container: oldContainer 
				pageNum: pageNum]"].
	(old := self valueOfProperty: #searchContainer) ifNotNil: 
			[(old respondsTo: #editor) 
				ifTrue: 
					[old editor selectFrom: 1 to: 0.	"trying to remove the previous selection!"
					old changed]].
	good 
		ifTrue: 
			["have the exact string object"

			(container := oldContainer) ifNil: 
					[container := self 
								highlightText: keys first
								at: place
								in: insideOf]
				ifNotNil: 
					[container userString == insideOf 
						ifFalse: 
							[container := self 
										highlightText: keys first
										at: place
										in: insideOf]
						ifTrue: 
							[(container isTextMorph) 
								ifTrue: 
									[container editor selectFrom: place to: keys first size - 1 + place.
									container changed]]].
			self setProperty: #searchContainer toValue: container.
			self setProperty: #searchOffset toValue: place.
			self setProperty: #searchKey toValue: keys.	"override later"
			self currentHand newKeyboardFocus: container.
			^true].
	^false
]

{ #category : #menu }
StackMorph >> findViaTemplate [
	| list pl cardInst |
	"Current card is the template.  Only search cards in this background. Look at cards directly (not allText). Key must be found in the same field as in the template.  HyperCard style (multiple starts of words).  
	Put results in a list, outside the stack."

	list := self templateMatches.
	list isEmpty ifTrue: [^ self inform: 'No matches were found.
Be sure the current card is mostly blank
and only has text you want to match.' translated]. 
	"put up a PluggableListMorph"
	cardInst := self currentCard.
	cardInst matchIndex: 0.	"establish entries"
	cardInst results at: 1 put: list.
	self currentPage setProperty: #myStack toValue: self.	"way to get back"

	pl := PluggableListMorph new
			on: cardInst list: #matchNames
			selected: #matchIndex changeSelected: #matchIndex:
			menu: nil "#matchMenu:shifted:" keystroke: nil.
	self currentHand attachMorph: (self formatList: pl).

]

{ #category : #menu }
StackMorph >> formatList: pl [
	| rr ff |
	"Turn this plugglable list into a good looking morph."

	pl color: Color transparent; borderWidth: 0.
	pl font: ((TextStyle named: #Palatino) fontOfSize: 14).
	pl toggleCornerRounding; width: 252; retractableOrNot; hResizing: #spaceFill.
	rr := (RectangleMorph new) toggleCornerRounding; extent: pl extent + (30@30).
	rr color: self currentPage color; fillStyle: (ff := self currentPage fillStyle copy).
	ff isGradientFill ifTrue: [
		rr fillStyle direction: (ff direction * self currentPage extent / rr extent) rounded.
		rr fillStyle origin: rr bounds origin].
	rr addMorph: pl.
	rr layoutPolicy: TableLayout new.
	rr layoutInset: 10@15; cellInset: 10@15; wrapDirection: #leftToRight.
	rr listCentering: #center; borderStyle: (BorderStyle raised width: 5).
	"Up and down buttons on left with arrows in a holder."
	"lb := (RectangleMorph new) color: transparent; borderWidth: 0."
	^ rr
]

{ #category : #'page controls' }
StackMorph >> fullControlSpecs [
	"Answer specifications for the long form of iconic stack/book controls"

	^ {
		#spacer.
		#variableSpacer.
		{'-'.			#deleteCard.			'Delete this card' translated}.
		#spacer.
		{ '¬´'	.		#goToFirstCardOfStack.	'First card' translated}.
		#spacer.
		{ '<'. 		#goToPreviousCardInStack.		'Previous card' translated}.
		#spacer.
		{'¬'.			#invokeBookMenu. 	'Click here to get a menu of options for this stack.' translated}.
		"#spacer.	{'¬'.			#reshapeBackground.  'Reshape' translated}.	"

		#spacer.
		{'¬ß'.			#showDesignationsOfObjects. 	'Show designations' translated}.
		#spacer.
		{'>'	.		#goToNextCardInStack.	'Next card' translated}.
		#spacer.
		{ '¬ª'.		#goToLastCardOfStack.	'Final card' translated}.
		#spacer.
		{'+'.		#insertCard.			'Add a new card after this one' translated}.
		#variableSpacer.
		{'¬'.			#fewerPageControls.			'Fewer controls
(if shift key pressed,
deletes controls)' translated}
}
]

{ #category : #menu }
StackMorph >> getAllText [
	"Collect the text for each card.  Just point at strings so don't have to recopy them.  (Parallel array of urls for ID of cards.  Remote cards not working yet.)
	allText = Array (cards size) of arrays (fields in it) of strings of text.
	allTextUrls = Array (cards size) of urls or card numbers."

	| oldUrls oldStringLists allText allTextUrls |
	self writeSingletonData.
	oldUrls := self valueOfProperty: #allTextUrls ifAbsent: [#()].
	oldStringLists := self valueOfProperty: #allText ifAbsent: [#()].
	allText := self privateCards collect: [:pg | OrderedCollection new].
	allTextUrls := Array new: self privateCards size.
	self privateCards doWithIndex: [:aCard :ind | | aUrl which |
		aUrl := aCard url.  aCard isInMemory 
			ifTrue: [(allText at: ind) addAll: (aCard allStringsAfter: nil).
				aUrl ifNil: [aUrl := ind].
				allTextUrls at: ind put: aUrl]
			ifFalse: ["Order of cards on server may be different.  (later keep up to date?)"
				"*** bug in this algorithm if delete a page?"
				which := oldUrls indexOf: aUrl.
				allTextUrls at: ind put: aUrl.
				which = 0 ifFalse: [allText at: ind put: (oldStringLists at: which)]]].
	self setProperty: #allText toValue: allText.
	self setProperty: #allTextUrls toValue: allTextUrls.
	^ allText
]

{ #category : #'card access' }
StackMorph >> goToCard [
	"prompt the user for an ordinal number, and use that as a basis for choosing a new card to install in the receiver"

	| reply index |
	reply := FillInTheBlank request: 'Which card number? ' translated initialAnswer: '1'.
	reply isEmptyOrNil ifTrue: [^ self].
	((index := reply asNumber) > 0 and: [index <= self privateCards size])
		ifFalse: [^ self inform: 'no such card' translated].
	self goToCard: (self privateCards at: index)
]

{ #category : #'card access' }
StackMorph >> goToCard: destinationCard [
	"Install the indicated destinationCard as the current card in the receiver.  Any viewer currently open on the current card will get retargeted to look at the new one."

	| aBackground existingCard oldViewers |
	destinationCard == self currentCard ifTrue: [^ self].
	self currentPlayerDo:
		[:aPlayer | aPlayer runAllClosingScripts].   "Like HyperCard 'on closeCard'"

	aBackground := self backgroundWithCard: destinationCard.
	existingCard := aBackground currentDataInstance.
	oldViewers := existingCard ifNil: [#()] ifNotNil: [existingCard allOpenViewers].

	aBackground installAsCurrent: destinationCard.
	aBackground setProperty: #myStack toValue: self.	"pointer cardMorph -> stack"

	aBackground ~~ currentPage ifTrue:
		[self goToPageMorph: aBackground runTransitionScripts: false].
	self currentPlayerDo:
		[:aPlayer | aPlayer runAllOpeningScripts] .  "Like HyperCard 'on opencard'"

	oldViewers do: [:aViewer | aViewer retargetFrom: existingCard to: destinationCard]
]

{ #category : #'card access' }
StackMorph >> goToCardNumber: aCardNumber [
	"Install the card whose ordinal number is provided as the current card in the stack"

	self goToCard: (self privateCards atWrap: aCardNumber)
]

{ #category : #'card access' }
StackMorph >> goToFirstCardInBackground [
	"Install the initial card in the current background as the current card in the stack"

	| kind |
	kind := currentPage player class baseUniclass.
	self goToCard: (self privateCards detect: [:aCard | aCard isKindOf: kind] ifNone: [^ Beeper beep])
]

{ #category : #'card access' }
StackMorph >> goToFirstCardOfStack [
	"Install the initial card in the stack as the current card"

	self goToCard: self privateCards first
]

{ #category : #'card access' }
StackMorph >> goToLastCardInBackground [
	"Install the final card in the current background as the current card"

	| kind |
	kind := currentPage player class baseUniclass.
	self goToCard: (self privateCards reversed detect: [:aCard | aCard isKindOf: kind] ifNone: [^ Beeper beep])
]

{ #category : #'card access' }
StackMorph >> goToLastCardOfStack [
	"Install the final card in the stack as the current card"

	self goToCard: self privateCards last
]

{ #category : #'card in a stack' }
StackMorph >> goToNextCardInStack [
	"Make the card *after* the current card become the current card"

	| anIndex newCard |
	anIndex := self privateCards indexOf: currentPage currentDataInstance.
	newCard := self privateCards atWrap: anIndex + 1.
	self goToCard: newCard
]

{ #category : #'card in a stack' }
StackMorph >> goToPreviousCardInStack [
	"Install the previous card as my current one"

	| anIndex newCard |
	anIndex := self privateCards indexOf: currentPage currentDataInstance.
	newCard := self privateCards atWrap: anIndex - 1.
	self goToCard: newCard
]

{ #category : #initialization }
StackMorph >> initialize [
	"Initialize the stack"

	| initialBackground |
	super initialize.
	initialBackground := pages first.
	initialBackground extent: (640@480); beSticky.
	initialBackground beAStackBackground.
	self beUnsticky.
	self setProperty: #controlsAtBottom toValue: true.
	self privateCards: (OrderedCollection with: initialBackground currentDataInstance).

"self currentHand attachMorph: StackMorph authoringPrototype"
]

{ #category : #'parts bin' }
StackMorph >> initializeToStandAlone [
	
	self initialize.
	self pageSize: (480 @ 320); color: (Color gray: 0.7).
	self borderWidth: 1; borderColor: Color black.
	self currentPage extent: self pageSize.
	self showPageControls: self fullControlSpecs.
	^ self

"StackMorph initializedInstance openInHand"
]

{ #category : #initialization }
StackMorph >> initializeWith: aCardMorph [
	"Install the card inside a new stack.  Make no border or controls, so I the card's look is unchanged.  Card already has a CardPlayer."
	
	| wld |
	wld := aCardMorph world.
	self initialize.
	self pageSize: aCardMorph extent.
	self borderWidth: 0; layoutInset: 0; color: Color transparent.
	pages := Array with: aCardMorph.
	self currentPage: aCardMorph.
	self privateCards: (OrderedCollection with: currentPage currentDataInstance).
	currentPage beAStackBackground.
	self position: aCardMorph position.
	submorphs last delete.
	self addMorph: currentPage.	
	self showPageControls: self fullControlSpecs.
	wld addMorph: self.

]

{ #category : #background }
StackMorph >> insertAsBackground: newPage resize: doResize [
	"Make a new background for the stack.  Obtain a name for it from the user.  It starts out life empty"

	| aName |
	aName := FillInTheBlank request: 'What should we call this new background?' translated initialAnswer: 'alternateBackground' translated.
	aName isEmptyOrNil ifTrue: [^ self].
	newPage beSticky.
	doResize ifTrue: [newPage extent: currentPage extent].
	newPage beAStackBackground.
	newPage setNameTo: aName.
	newPage vResizeToFit: false.
	pages isEmpty
		ifTrue: [pages add: newPage]
		ifFalse: [pages add: newPage after: currentPage].
	self privateCards add: newPage currentDataInstance after: currentPage currentDataInstance.
	self nextPage.

]

{ #category : #'card in a stack' }
StackMorph >> insertCard [
	"Create a new card of the current background and make it become the current card"

	self insertCardOfBackground: currentPage
]

{ #category : #'as yet unclassified' }
StackMorph >> insertCardOfBackground [
	"Prompt the user for choice of a background, and insert a new card of that background"

	| bgs aBackground |
	(bgs := self backgrounds) size = 1 ifTrue:
		[self inform: 
'At this time, there IS only one kind of
background in this stack, so that''s
what you''ll get' translated.
		^ self insertCard].
	aBackground := UIManager default
		chooseFrom: (bgs collect: [:bg | bg externalName])
		values: bgs.
	aBackground ifNotNil:
		[self insertCardOfBackground: aBackground]
]

{ #category : #'as yet unclassified' }
StackMorph >> insertCardOfBackground: aBackground [
	"Insert a new card of the given background and have it become the current card"

	| newCard |
	newCard :=  aBackground newCard.
	self privateCards add: newCard after: self currentCard.
	self goToCard: newCard
]

{ #category : #'card access' }
StackMorph >> insertCardOfBackground: aBackground withDataFrom: aLine forInstanceVariables: slotNames [
	"Insert a new card of the given background and have it become the current card. "

	| newCard |
	newCard :=  aBackground newCard.
	self privateCards add: newCard after: self currentCard.
	newCard absorbBackgroundDataFrom: aLine forInstanceVariables: slotNames.
	self goToCard: newCard
]

{ #category : #'submorphs-accessing' }
StackMorph >> insertionIndexForPaneOfType: aType [
	| naturalIndex insertionIndex |
	naturalIndex := self naturalPaneOrder indexOf: aType.
	insertionIndex := 1.
	(self naturalPaneOrder copyFrom: 1 to: (naturalIndex - 1)) do: "guys that would precede"
		[:sym | (self hasSubmorphWithProperty: sym)
			ifTrue:
				[insertionIndex := insertionIndex + 1]].
	^ insertionIndex
]

{ #category : #debugging }
StackMorph >> inspectCurrentBackground [
	"Open an inspector on the corrent background.  Ideally should put include the background name in the inspector's title."

	^ self currentPage inspectWithLabel: 'A Background'

]

{ #category : #debugging }
StackMorph >> inspectCurrentCard [
	"For debugging: open an Inspector on the receiver's current card"

	^ self currentCard inspectWithLabel: 'A Card'

]

{ #category : #debugging }
StackMorph >> inspectCurrentStack [
	"Triggered from the stack-debug menu, open an Inspector on the receiver"

	^ self inspectWithLabel: 'A Stack'

]

{ #category : #menu }
StackMorph >> invokeBookMenu [
	"Invoke the book's control panel menu."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Stack' translated.
	Preferences noviceMode
		ifFalse: [aMenu addStayUpItem].
	aMenu addList: {
		{'find...' translated.					#textSearch}.
		{'find via this template' translated.			#findViaTemplate}.
		{'show designations' translated. 			#showDesignationsOfObjects}.
		{'explain designations' translated.			#explainDesignations}.
		#-.
		{'previous card' translated. 				#goToPreviousCardInStack}.
		{'next card' translated. 				#goToNextCardInStack}.
		{'first card' translated. 				#goToFirstCardOfStack}.
		{'last card' translated. 				#goToLastCardOfStack}.
		{'go to card...' translated. 				#goToCard}.
		#-.
		{'add a card of this background' translated. 		#insertCard}.
		{'add a card of background...' translated.		#insertCardOfBackground}.
		{'make a new background...' translated. 		#makeNewBackground}.
		#-.
		{'insert cards from clipboard data' translated.		#addCardsFromClipboardData.	'Create new cards from a formatted string on the clipboard' translated}.
		{'insert cards from a file...' translated.		#addCardsFromAFile.		'Create new cards from data in a file' translated}.
		#-.
		{'instance variable order...' translated.		#changeInstVarOrder.		'Caution -- DANGER. Change the order of the variables on the cards' translated}.
		{'be defaults for new cards' translated. 		#beDefaultsForNewCards.		'Make these current field values be the defaults for their respective fields on new cards' translated}.
		    {'sort cards by...' translated.			#sortCards.			'Sort all the cards of the current background using some field as the sort key' translated}.
		#-.
		{'delete this card' translated. 			#deleteCard}.
		{'delete all cards *except* this one' translated.	#deleteAllCardsExceptThisOne}.
		#-.
		{'move card to front of stack' translated.		#makeCurrentCardFirstInStack}.
		{'move card to back of stack' translated.		#makeCurrentCardLastInStack}.
		{'move card one position earlier' translated.		#moveCardOnePositionEarlier}.
		{'move card one position later' translated.		#moveCardOnePositionLater}.
		#-.
		{'scripts for this background' translated.		#browseCardClass}.
		#-.
		{'debug...' translated.					#offerStackDebugMenu}.
		{'bookish items...' translated. 			#offerBookishMenu}}.

	aMenu addUpdating: #showingPageControlsString action: #toggleShowingOfPageControls.
	aMenu addUpdating: #showingFullScreenString action: #toggleFullScreen.

	aMenu popUpEvent: self world activeHand lastEvent in: self world

]

{ #category : #'card access' }
StackMorph >> makeCurrentCardFirstInStack [
	"Move the current card such that it becomes the first card in the stack"

	| aCard |
	aCard := self currentCard.
	self privateCards remove: aCard ifAbsent: [];
		addFirst: aCard.
	self currentPage flash
]

{ #category : #'card access' }
StackMorph >> makeCurrentCardLastInStack [
	"Move the current card such that it becomes the last card in the stack"

	| aCard |
	aCard := self currentCard.
	self privateCards remove: aCard ifAbsent: [];
		addLast: aCard.
	self currentPage flash
]

{ #category : #background }
StackMorph >> makeNewBackground [
	"Make a new background for the stack.  Obtain a name for it from the user.  It starts out life empty"

	| newPage |
	(newPage := PasteUpMorph newSticky) color: self color muchLighter.
	newPage borderWidth: currentPage borderWidth; borderColor: currentPage borderColor.
	self insertAsBackground: newPage resize: true. 

]

{ #category : #'card access' }
StackMorph >> moveCardOnePositionEarlier [
	"Move the current card such that its ordinal position is one fewer than it formerly was.  If the current card is already the first one one in the stack, then do nothing"

	| aCard aPosition |
	aCard := self currentCard.
	aCard == self privateCards first ifTrue: [^ self].
	aPosition := self privateCards indexOf: aCard.
	self privateCards remove: aCard;
		add: aCard afterIndex: (aPosition - 2).
	self currentPage flash
]

{ #category : #'card access' }
StackMorph >> moveCardOnePositionLater [
	"Move the current card such that its ordinal position is one greater than it formerly was.  If the current card is already the last one one in the stack, then do nothing"

	| aCard aPosition privateCards |
	aCard := self currentCard.
	privateCards := self privateCards.
	aCard == privateCards last ifTrue: [^ self].
	aPosition := privateCards indexOf: aCard.
	privateCards remove: aCard.
	privateCards add: aCard afterIndex: aPosition.
	self currentPage flash
]

{ #category : #'submorphs-accessing' }
StackMorph >> naturalPaneOrder [
	^ #(header pageControl retrieve search index content)
]

{ #category : #menu }
StackMorph >> offerBookishMenu [
	"Offer a menu with book-related items in it"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Stack / Book' translated.
	aMenu addStayUpItem.
	aMenu addList:
		#(('sort pages' sortPages)
		('uncache page sorter' uncachePageSorter)).
	(self hasProperty: #dontWrapAtEnd)
		ifTrue: [aMenu add: 'wrap after last page' translated selector: #setWrapPages: argument: true]
		ifFalse: [aMenu add: 'stop at last page' translated selector: #setWrapPages: argument: false].
	aMenu addList:
		#(('make bookmark'	 bookmarkForThisPage)
		('make thumbnail' thumbnailForThisPage)).

	aMenu addLine.
	aMenu add: 'sound effect for all pages' translated action: #menuPageSoundForAll:.
	aMenu add: 'sound effect this page only' translated action: #menuPageSoundForThisPage:.
	aMenu add: 'visual effect for all pages' translated action: #menuPageVisualForAll:.
	aMenu add: 'visual effect this page only' translated action: #menuPageVisualForThisPage:.

	aMenu addLine.
	(self primaryHand pasteBuffer class isKindOf: PasteUpMorph class) ifTrue:
		[aMenu add: 'paste book page'   translated action: #pasteBookPage].

	aMenu add: 'save as new-page prototype' translated action: #setNewPagePrototype.
	newPagePrototype ifNotNil: [
		aMenu add: 'clear new-page prototype' translated action: #clearNewPagePrototype].

	aMenu add: (self dragNDropEnabled ifTrue: ['close' translated ] ifFalse: ['open' translated]) , ' dragNdrop' translated
			action: #changeDragAndDrop.
	aMenu addLine.
	aMenu add: 'make all pages this size' translated action: #makeUniformPageSize.
	aMenu addUpdating: #keepingUniformPageSizeString target: self action: #toggleMaintainUniformPageSize.
	aMenu addLine.
	aMenu add: 'send all pages to server' translated action: #savePagesOnURL.
	aMenu add: 'send this page to server' translated action: #saveOneOnURL.
	aMenu add: 'reload all from server' translated action: #reload.
	aMenu add: 'copy page url to clipboard' translated action: #copyUrl.
	aMenu add: 'keep in one file' translated action: #keepTogether.

	aMenu addLine.
	aMenu add: 'load PPT images from slide #1' translated action: #loadImagesIntoBook.
	aMenu add: 'background color for all pages...' translated action: #setPageColor.

	aMenu popUpEvent: self world activeHand lastEvent in: self world



]

{ #category : #menu }
StackMorph >> offerStackDebugMenu [
	"Put up a menu offering debugging items for the stack"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Stack debugging'.
	Preferences noviceMode
		ifFalse: [aMenu addStayUpItem].
	aMenu addList: #(
		('reassess'								reassessBackgroundShape)
		('relax grip on variable names'			relaxGripOnVariableNames)
		('commit card data'						commitCardData)
		-
		('browse card uniclass'					browseCardClass)
		('inspect card'							inspectCurrentCard)
		('inspect background'					inspectCurrentBackground)
		('inspect stack'							inspectCurrentStack)).
	aMenu popUpInWorld: (self world ifNil: [self currentWorld])

]

{ #category : #'as yet unclassified' }
StackMorph >> openInsideLook [
	"Open an inside-look at the current page.  This is a previously-demoed feature not presently incorporated in released code,"

	true ifTrue: [self notYetImplemented] ifFalse: [self currentPage openInsideLook]

]

{ #category : #controls }
StackMorph >> pageControlsMorphFrom: controlSpecs [
	"Answer a controls morph derived from the spec supplied"

	| controls |
	controls := super pageControlsMorphFrom: controlSpecs.
	controls eventHandler: nil.  "not grabbable"
	^ controls
]

{ #category : #'card access' }
StackMorph >> privateCards [
	"Private - answer the collection object that sits in my cards instance variable"

	^ cards
]

{ #category : #'card access' }
StackMorph >> privateCards: aCollection [
	"Private - Make my cards be te given colllection"

	cards := aCollection
]

{ #category : #'card in a stack' }
StackMorph >> reassessBackgroundShape [
	"Have the current page reconsider its cards' instance structure"

	currentPage setProperty: #myStack toValue: self. 	"pointer cardMorph -> stack"
	^ self currentPage reassessBackgroundShape 

]

{ #category : #'card in a stack' }
StackMorph >> relaxGripOnVariableNames [
	"Have the current background relax its grip on existing variable name"

	^ self currentPage relaxGripOnVariableNames 

]

{ #category : #'card in a stack' }
StackMorph >> reshapeBackground [
	"Abandon any memory of variable-name preferences for the current background, and reassess its instance structure"

	^ self currentPage reshapeBackground 

]

{ #category : #'page controls' }
StackMorph >> shortControlSpecs [
	"Answer specficiations for the shorter form of stack controls"

	^ {
		#spacer.
		#variableSpacer.
		{ '<'.	#goToPreviousCardInStack.		'Previous card' translated}.
		#spacer.
		{'¬'.		#invokeBookMenu. 			'Click here to get a menu for this stack.' translated}.
		#spacer.
		{'>'.	#goToNextCardInStack.		'Next card' translated}.
		#variableSpacer.
		{'¬'.		#showMoreControls.			'More controls
(if shift key pressed,
deletes controls)' translated}
}
]

{ #category : #'card in a stack' }
StackMorph >> showDesignationsOfObjects [
	"Momentarily show which objects on the current card belong to which designation category"

	self currentPage showDesignationsOfObjects

]

{ #category : #background }
StackMorph >> sortByField: varName [
	"Perform a simple reordering of my cards, sorting by the given field name.  If there are multiple backgrounds, then sort the current one, placing all its cards first, followed by all others in unchanged order"

	| holdCards thisClassesInstances |
	holdCards := self privateCards copy.

	thisClassesInstances := self privateCards select: [:c | c isKindOf: self currentCard class].
	thisClassesInstances sort:
		[:a :b | (a instVarNamed: varName) asString <= (b instVarNamed: varName) asString].
	holdCards removeAllFoundIn: thisClassesInstances.
	self privateCards:  (thisClassesInstances asOrderedCollection
		addAllLast: holdCards;
		yourself).
	self goToFirstCardOfStack

]

{ #category : #background }
StackMorph >> sortCards [
	"Let the user provide an inst var on which to sort the cards of a background."

	| names aMenu |
	names := self currentPage player class instVarNames.
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Choose field by which to sort:'.
	names do: [:n | aMenu add: n selector: #sortByField: argument: n].
	aMenu popUpInWorld
]

{ #category : #'card in a stack' }
StackMorph >> stackDo: aBlock [
	"Evaluate aBlock on behalf of the receiver stack"

	^ aBlock value: self
]

{ #category : #menu }
StackMorph >> templateMatches [
	| template docks keys bkg |
	"Current card is the template.  Only search cards in this background. Look at cards directly (not allText). Key must be found in the same field as in the template.  HyperCard style (multiple starts of words).  
	Put results in a list, outside the stack."

	template := self currentCard.
	template commitCardPlayerData.
	docks := template class variableDocks.
	(keys := template asKeys) ifNil: [^ #()]. "nothing to match against"
	bkg := self currentPage.
	^ self privateCards select: [:cardPlayer | 
		(((cardPlayer == template) not) and: [cardPlayer costume == bkg]) 
			and: [cardPlayer match: keys fields: docks]].

]

{ #category : #menu }
StackMorph >> writeSingletonData [
	"Backgrounds that have just one card, may never get their data written into a CardPlayer. Make sure we do it."

	| sieve |
	sieve := IdentityDictionary new.
	pages do: [:pp | sieve at: pp put: 0].
	self privateCards do: [:cc | sieve at: cc costume put: (sieve at: cc costume) + 1].
	sieve associationsDo: [:ass | 
		ass value = 1 ifTrue:
			[ass key player commitCardPlayerDataFrom: ass key]].
			"If currently showing card, may be some trouble... <- tk note 5/01"
]
