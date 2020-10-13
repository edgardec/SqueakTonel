"
I am a list widget that uses the change/update mechanism to display model data as a vertical arrangement of (maybe formatted) strings and icons in a scroll pane.

When I am in keyboard focus, type in a letter (or several letters quickly) to go to the next item that begins with that letter. If you enabled the ""filterable lists"" preference, I will hide all items that do not match the filter.

Special keys (arrow up/down, page up/down, home, end) are also supported.
"
Class {
	#name : #PluggableListMorph,
	#superclass : #ScrollPane,
	#instVars : [
		'list',
		'fullList',
		'modelToView',
		'viewToModel',
		'getListSelector',
		'getListSizeSelector',
		'getListElementSelector',
		'getIndexSelector',
		'setIndexSelector',
		'keystrokeActionSelector',
		'autoDeselect',
		'lastKeystrokeTime',
		'lastKeystrokes',
		'lastClickTime',
		'doubleClickSelector',
		'handlesBasicKeys',
		'potentialDropRow',
		'hoverRow',
		'listMorph',
		'keystrokePreviewSelector',
		'priorSelection',
		'getIconSelector',
		'getHelpSelector'
	],
	#classVars : [
		'ClearFilterAutomatically',
		'ClearFilterDelay',
		'FilterableLists',
		'FlashOnErrors',
		'HighlightHoveredRow',
		'HighlightPreSelection',
		'MenuRequestUpdatesSelection'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #preferences }
PluggableListMorph class >> clearFilterAutomatically [
	<preference: 'Filterable Lists Clear Automatically'
		category: 'scrolling'
		description: 'When using the Filterable Lists option, if this option is also selected, then the filter will be cleared as soon as the list loses keyboard focus.'
		type: #Boolean>
	^ ClearFilterAutomatically ifNil: [ true ]
]

{ #category : #preferences }
PluggableListMorph class >> clearFilterAutomatically: aBoolean [
	ClearFilterAutomatically := aBoolean
]

{ #category : #preferences }
PluggableListMorph class >> clearFilterDelay [
	<preference: 'Filterable Lists Clear Delay'
		category: 'scrolling'
		description: 'Defines the maximum delay (in milliseconds) between keystrokes before the filter expression is cleared again.'
		type: #Number>
		
	^ ClearFilterDelay ifNil: [500]
]

{ #category : #preferences }
PluggableListMorph class >> clearFilterDelay: aNumber [
		
	ClearFilterDelay := aNumber.
]

{ #category : #preferences }
PluggableListMorph class >> filterableLists [
	<preference: 'Filterable Lists'
		category: 'scrolling'
		description: 'When true, using the keyboard on a list will filter it rather than scroll.  Pressing enter clears the filter and keeps the filtered selection.  Backspace clears the filter and returns to the prior selection.'
		type: #Boolean>
	^ FilterableLists ifNil: [ true ]
]

{ #category : #preferences }
PluggableListMorph class >> filterableLists: aBoolean [
	"When true, using the keyboard on a list will filter it rather than scroll.  Pressing enter clears the filter and keeps the filtered selection.  Backspace clears the filter and returns to the prior selection."
	FilterableLists := aBoolean
]

{ #category : #preferences }
PluggableListMorph class >> flashOnErrors [

	<preference: 'Flash on Errors in Lists'
		category: #Morphic
		description: 'If a user request cannot be fulfilled as expected, flash briefly to inform the user about it. While this can improve user feedback, it adds a small delay because of an explicit world refresh.'
		type: #Boolean>
		
	^ FlashOnErrors ifNil: [false]
]

{ #category : #preferences }
PluggableListMorph class >> flashOnErrors: aBoolean [

	FlashOnErrors := aBoolean.
]

{ #category : #preferences }
PluggableListMorph class >> highlightHoveredRow [

	<preference: 'Highlight Hovered Row in Lists'
		category: #Morphic
		description: 'Indicate which row will be affected before any further interaction takes place.'
		type: #Boolean>
	^ HighlightHoveredRow ifNil: [true]
]

{ #category : #preferences }
PluggableListMorph class >> highlightHoveredRow: aBoolean [

	HighlightHoveredRow := aBoolean.
]

{ #category : #preferences }
PluggableListMorph class >> highlightPreSelection [

	<preference: 'Highlight Pre-Selection in Lists'
		category: #Morphic
		description: 'Indicate the attempt to change the selection in models like after a click or key press. If model updates can take long, such indication can improve user feedback. However, this adds a small delay because of an explicit world refresh.'
		type: #Boolean>
		
	^ HighlightPreSelection ifNil: [false]
]

{ #category : #preferences }
PluggableListMorph class >> highlightPreSelection: aBoolean [

	HighlightPreSelection := aBoolean.
]

{ #category : #preferences }
PluggableListMorph class >> menuRequestUpdatesSelection [

	<preference: 'Menu request updates list/tree selection'
		category: #Morphic
		description: 'When invoking a menu, the action is applied to the current selection in the list. If the mouse cursor it at a different location, however, this preference will update the selection before showing the menu if enabled.'
		type: #Boolean>
	^ MenuRequestUpdatesSelection ifNil: [ false ]
]

{ #category : #preferences }
PluggableListMorph class >> menuRequestUpdatesSelection: aBoolean [

	MenuRequestUpdatesSelection := aBoolean.
]

{ #category : #'instance creation' }
PluggableListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self new
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: nil
		keystroke: #arrowKey:from:		"default"
]

{ #category : #'instance creation' }
PluggableListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self new
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: #arrowKey:from:		"default"

]

{ #category : #'instance creation' }
PluggableListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self new
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: keyActionSel

]

{ #category : #preferences }
PluggableListMorph class >> themeProperties [

	^ super themeProperties, {
		{ #font. 'Fonts'. 'Font of the list items.' }.
		{ #textColor. 'Colors'. 'Color of the list items.' }.
		{ #selectionColor. 'Colors'. 'Color used for items when hovering or selecting them.' }.
		{ #multiSelectionColor. 'Colors'. 'Colors used for items that are selected among others.'}.
		{ #selectionTextColor. 'Colors'. 'Color used for label when hovering or selecting them.' }.
		{ #filterColor. 'Colors'. 'Color used for items to indicate the matching filter.' }.
		{ #filterTextColor. 'Colors'. 'Color used for items to indicate the matching filter.' }.
		
		{ #preSelectionModifier. 'Colors'. 'How to derive the pre-selection color from the selection color.'}.
		{ #hoverSelectionModifier. 'Colors'. 'How to derive the hover color from the selection color.'}.
	}
]

{ #category : #'drag and drop' }
PluggableListMorph >> acceptDroppingMorph: aMorph event: evt [ 
	"This message is sent when a morph is dropped onto a morph that has     
	agreed to accept the dropped morph by responding 'true' to the     
	wantsDroppedMorph:Event: message. The default implementation just     
	adds the given morph to the receiver."
	"Here we let the model do its work."

	self model
		acceptDroppingMorph: aMorph
		event: evt
		inMorph: self.
	self resetPotentialDropRow.
	evt hand releaseMouseFocus: self.
	Cursor normal show.

]

{ #category : #menus }
PluggableListMorph >> addCustomMenuItems:  aMenu hand: aHandMorph [
	"Add halo menu items to be handled by the invoking hand. The halo menu is invoked by clicking on the menu-handle of the receiver's halo."

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu addLine.
	aMenu add: 'list font...' translated target: self action: #setListFont.
	aMenu add: 'copy list to clipboard' translated target: self action: #copyListToClipboard.
	aMenu add: 'copy selection to clipboard' translated target: self action: #copySelectionToClipboard
]

{ #category : #'submorphs-accessing' }
PluggableListMorph >> allSubmorphNamesDo: nameBlock [
	"Assume list morphs do not have named parts -- saves MUCH time"

	^ self
]

{ #category : #filtering }
PluggableListMorph >> allowEmptyFilterResult [
	^ self valueOfProperty: #allowEmptyFilterResult ifAbsent: [false]
]

{ #category : #filtering }
PluggableListMorph >> allowEmptyFilterResult: aBoolean [
	
	self
		setProperty: #allowEmptyFilterResult
		toValue: aBoolean.
]

{ #category : #updating }
PluggableListMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self listMorph listChanged.
]

{ #category : #initialization }
PluggableListMorph >> autoDeselect: trueOrFalse [
	"Enable/disable autoDeselect (see class comment)"
	autoDeselect := trueOrFalse.
]

{ #category : #accessing }
PluggableListMorph >> balloonText [
	"Overridden to send selector to model and not self. Do not use #perform:orSendTo: because super does more than just the send.."
	
	self getHelpSelector ifNotNil: [:selector |
		(self model respondsTo: selector) ifTrue: [
			| modelIndex |
			(modelIndex := self modelIndexFor: self hoverRow) > 0 ifTrue: [
				^ self model perform: selector with: modelIndex]]].
	
	^ super balloonText
]

{ #category : #'model access - keystroke' }
PluggableListMorph >> basicKeyPressed: aChar [
	
	self listFilterAppend: aChar.
]

{ #category : #'accessing - items' }
PluggableListMorph >> bottomVisibleRowIndex [
	^ self rowAtLocation: self scroller bottomLeft - (0@1)
]

{ #category : #'debug and other' }
PluggableListMorph >> browseImplementationOfGetListSelector [

	| method |
	method := model class lookupSelector: getListSelector.
	ToolSet browse: method methodClass selector: method selector.
]

{ #category : #'debug and other' }
PluggableListMorph >> buildDebugMenu: aHandMorph [

	| aMenu |
	aMenu := super buildDebugMenu: aHandMorph.
	aMenu addLine.
	aMenu add: 'browse get-list code' translated target: self action: #browseImplementationOfGetListSelector.
	aMenu add: 'debug get-list invocation' translated target: self action: #debugGetList.
	^ aMenu
]

{ #category : #testing }
PluggableListMorph >> canBeEncroached [
	"Answer whether my bottom edge can be encroached by horizontal smart-splitter.  If my list is larger than my outermost containing window, go ahead and report true since moving a splitter will never allow my entire list to be displayed.  In that case go ahead and be encroachable to allow lower truncated text-panes to be exposed, but leave a reasonable height (70) to ensure at least few items are displayed."
	^ self height > 24 and:
		[ | outermostContainer |
		outermostContainer := self outermostMorphThat:
			[ : e | e owner = self world ].
		listMorph height + 8 < self height or:
			[ outermostContainer notNil and: [ listMorph height > (outermostContainer height / 1.2) and: [ self height > 70 ] ] ] ]
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> canHaveIcons [

	^ getIconSelector notNil
]

{ #category : #'model access' }
PluggableListMorph >> changeModelSelection: aModelIndex [
	" Change the model's selected item index to be aModelIndex. Optionally, do a pre-selection highlight, which requires an immediate re-draw of this widget."

	self class highlightPreSelection ifTrue: [
		self rowAboutToBecomeSelected: (self viewIndexFor: aModelIndex).
		self refreshWorld].
	setIndexSelector ifNotNil: [
		model perform: setIndexSelector with: aModelIndex ].
]

{ #category : #geometry }
PluggableListMorph >> charactersOccluded [
	"Answer the number of characters occluded in my #visibleList by my right edge."
	| listIndex | listIndex:=0.
	^ self visibleList
		inject: 0
		into:
			[ : sum : each | | eachString totalWidth indexOfLastVisible iconWidth |
			totalWidth:=0.
			eachString := each asString "withBlanksTrimmed".
			iconWidth := (self iconAt: (listIndex := listIndex+1)) ifNil:[0] ifNotNil: [ : icon | icon width+2 ].
			indexOfLastVisible := ((1 to: eachString size)
				detect:
					[ : stringIndex | (totalWidth:=totalWidth+(self font widthOf: (eachString at: stringIndex))) >
						(self width -
							(scrollBar
								ifNil: [ 0 ]
								ifNotNil: [ scrollBar width ]) - iconWidth) ]
				ifNone: [ eachString size + 1 ]) - 1.
			sum + ((eachString size - indexOfLastVisible) min: 10) ]
]

{ #category : #accessing }
PluggableListMorph >> clearFilterAutomatically [

	^ (self valueOfProperty: #clearFilterAutomatically ifAbsent: [true]) and: [self class clearFilterAutomatically]
]

{ #category : #accessing }
PluggableListMorph >> clearFilterAutomatically: aBoolean [
	self setProperty: #clearFilterAutomatically toValue: aBoolean.
]

{ #category : #'model access' }
PluggableListMorph >> commandKeyTypedIntoMenu: evt [
	"The user typed a command-key into a menu which has me as its command-key handler"

	^ self modifierKeyPressed: evt keyCharacter
]

{ #category : #menus }
PluggableListMorph >> copyListToClipboard [
	"Copy my items to the clipboard as a multi-line string"

	Clipboard clipboardText: (
		String streamContents: [:stream |
			1 to: self listSize do: [:viewIndex |
				stream nextPutAll: (self itemAt: viewIndex) asString; cr]]).
]

{ #category : #menus }
PluggableListMorph >> copySelectionToClipboard [
	"Copy my selected item to the clipboard as a string"

	self selection
		ifNotNil:
			[Clipboard clipboardText: self selection asString]
		ifNil:
			[self flash]
]

{ #category : #initialization }
PluggableListMorph >> createListMorph [

	^ self listMorphClass new
		listSource: self;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		cellPositioning: #leftCenter;
		setProperty: #indicateKeyboardFocus toValue: #never;
		yourself.
]

{ #category : #'debug and other' }
PluggableListMorph >> debugGetList [

	(Process
		forBlock: [model perform: getListSelector]
		runUntil: [:context | context selector = getListSelector])
			debugWithTitle: ('Debug get-list invocation in model "{1}"' format: {model printString}).
]

{ #category : #'event handling' }
PluggableListMorph >> doubleClick: event [
	| index |
	doubleClickSelector ifNil: [^super doubleClick: event].
	index := self rowAtLocation: event position.
	index = 0 ifTrue: [^super doubleClick: event].
	"selectedMorph ifNil: [self setSelectedMorph: aMorph]."
	^ self model perform: doubleClickSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> doubleClickSelector [
	^ doubleClickSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> doubleClickSelector: aSymbol [
	doubleClickSelector := aSymbol
]

{ #category : #filtering }
PluggableListMorph >> filterList: someItems matching: aPattern [
	"Filter someStrings according to aPattern. Prepend best matches in the result. Update the model-to-view map."
	
	| frontMatching substringMatching tmp |
	aPattern ifEmpty: [ ^ someItems ].
	someItems ifEmpty: [ ^ someItems ].
	
	frontMatching := OrderedCollection new.
	substringMatching := OrderedCollection new.
	
	self assert: modelToView isEmpty.
	self assert: viewToModel isEmpty.
	tmp := OrderedCollection new.
	
	someItems doWithIndex:
		[ :each :n | | foundPos |
		foundPos := self filterListItem: each matching: aPattern.
		foundPos = 1
			ifTrue:
				[ frontMatching add: each.
				modelToView at: n put: frontMatching size.
				viewToModel at: frontMatching size put: n ]
			ifFalse:
				[ foundPos > 1 ifTrue:
					[ substringMatching add: each.
					tmp add: n; add:  substringMatching size ] ] ].

	tmp pairsDo: [:modelIndex :viewIndex |
		modelToView at: modelIndex put: viewIndex + frontMatching size.
		viewToModel at: viewIndex + frontMatching size put: modelIndex].
	
	^ frontMatching, substringMatching
]

{ #category : #filtering }
PluggableListMorph >> filterListItem: anObject matching: aPattern [
	
	^ anObject asString
		findString: aPattern
		startingAt: 1
		caseSensitive: false
]

{ #category : #filtering }
PluggableListMorph >> filterTerm [
	^ lastKeystrokes ifNil: ['']
]

{ #category : #filtering }
PluggableListMorph >> filterTerm: aString [

	lastKeystrokes = aString ifTrue: [^ self].
	lastKeystrokes := aString.
	self updateListFilter.
]

{ #category : #accessing }
PluggableListMorph >> filterableList [
	^ (self valueOfProperty: #filterableList ifAbsent: [false]) or: [self class filterableLists]
]

{ #category : #accessing }
PluggableListMorph >> filterableList: aBoolean [
	self setProperty: #filterableList toValue: aBoolean.
]

{ #category : #drawing }
PluggableListMorph >> flash [

	self class flashOnErrors ifTrue: [super flash].
]

{ #category : #initialization }
PluggableListMorph >> font [

	^ self listMorph font

]

{ #category : #initialization }
PluggableListMorph >> font: aFontOrNil [

	self listMorph font: aFontOrNil.
	
	self minimumWidth: (self font widthOf: $m) * 5.

]

{ #category : #'list morph callbacks' }
PluggableListMorph >> fullListSize [
	"Number of items in the unfiltered list."
	
	^ self getFullList size
]

{ #category : #'model access' }
PluggableListMorph >> getCurrentSelectionIndex [
	"Answer the index of the current selection."

	getIndexSelector ifNil: [^0].
	^model perform: getIndexSelector
]

{ #category : #'model access - cached' }
PluggableListMorph >> getFilteredList [
	"Apply the current filter to the list. Maybe shorten the filter term if there are no matches."
	
	| fullList filteredList |
	fullList := self getFullList.
		
	self hasFilter ifFalse: [^ fullList].
	fullList ifEmpty: [^ fullList].
	
	filteredList := self filterList: fullList matching: lastKeystrokes.
	
	(filteredList isEmpty not or: [ self allowEmptyFilterResult ])
		ifFalse: 
			[ "Remove the last character and try filtering again."
			lastKeystrokes := lastKeystrokes allButLast: 1.
			^ self
				 flash;
				 getFilteredList ].
			
	^ filteredList
]

{ #category : #'model access - cached' }
PluggableListMorph >> getFullList [
	"The full, unfiltered list. Cached result, see #updateList. Prefer getListSelector over getListElementSelector if both a set."
	
	^ fullList ifNil: [
		fullList := getListSelector
			ifNotNil: [:sel | model perform: sel]
			ifNil: [(getListSizeSelector notNil and: [getListElementSelector notNil])
				ifTrue: [	(1 to: self getListSize) collect: [:index | self getListItem: index]]
				ifFalse: [#() "We cannot get the full list."]].
		fullList ifNil: [Error signal: 'The model must never provide ''nil'' as a list but only a collection.'].
		fullList]
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getHelpSelector [
	
	^ getHelpSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getHelpSelector: aSelector [
	"Get help for list entries."
	
	getHelpSelector := aSelector.
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getIconSelector [
	^ getIconSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getIconSelector: aSymbol [
	getIconSelector := aSymbol
]

{ #category : #'model access - cached' }
PluggableListMorph >> getList [
	"Answer the (maybe filtered) list to be displayed. Cached result, see #updateList."
	
	^ list ifNil: [
		list := #(). "To make this call safe when re-entering it while fetching the list. This can happen, for example, when the model fetches data that opens the system progress bar which then will redraw periodically."
		list := self filterableList
			ifTrue: [self getFilteredList]
			ifFalse: [self getFullList].
		self updateListMorph.
		list]
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getListElementSelector [
	"specify a selector that can be used to obtain a single element in the underlying list"
	^ getListElementSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getListElementSelector: aSymbol [
	"specify a selector that can be used to obtain a single element in the underlying list"

	getListElementSelector = aSymbol ifTrue: [^self].
	getListElementSelector := aSymbol.
	self updateList.
]

{ #category : #'model access' }
PluggableListMorph >> getListItem: modelIndex [
	
	^ getListElementSelector
		ifNotNil: [:sel | model perform: sel with: modelIndex ]
		ifNil: [self getFullList at: modelIndex]
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getListSelector [
	^ getListSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getListSelector: aSymbol [ 
	"Set the receiver's getListSelector as indicated, and trigger a recomputation of the list"
	
	getListSelector = aSymbol ifTrue: [^ self].
	getListSelector := aSymbol.
	self updateList.
]

{ #category : #'model access' }
PluggableListMorph >> getListSize [
	"return the current number of items in the displayed list"
	
	^ getListSizeSelector
		ifNotNil: [:sel | model perform: sel]
		ifNil: [self fullListSize]
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getListSizeSelector [
	^ getListSizeSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> getListSizeSelector: aSymbol [
	"specify a selector that can be used to specify the list's size"

	getListSizeSelector = aSymbol ifTrue: [^ self].
	getListSizeSelector := aSymbol.
	self updateList.
]

{ #category : #menu }
PluggableListMorph >> getMenu: shiftKeyState [
	"Answer the menu for this text view, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."

	| aMenu |
	aMenu := super getMenu: shiftKeyState.
	aMenu ifNotNil: [aMenu commandKeyHandler: self].
	^ aMenu
]

{ #category : #accessing }
PluggableListMorph >> hScrollBarPolicy: aSymbol [
	"The lazy list morph will never wrap its rows if they do not fit. Instead, they are just clipped. So, #spaceFill is fine if the horizontal scroll bar should never be visible."
	
	self checkScrollBarPolicy: aSymbol.
	
	aSymbol ~= #never
		ifTrue: [self listMorph hResizing: #shrinkWrap]
		ifFalse: [self listMorph hResizing: #spaceFill].
				
	^ super hScrollBarPolicy: aSymbol
]

{ #category : #'events-processing' }
PluggableListMorph >> handleMouseMove: anEvent [
	"Reimplemented because we really want #mouseMove when a morph is dragged around"
	anEvent wasHandled ifTrue:[^self]. "not interested"
	self hoverRow: (self rowAtLocation: anEvent position).
	(anEvent anyButtonPressed and:[anEvent hand mouseFocus == self]) ifFalse:[^self].
	anEvent wasHandled: true.
	self mouseMove: anEvent.
	(self handlesMouseStillDown: anEvent) ifTrue:[
		"Step at the new location"
		self startStepping: #handleMouseStillDown: 
			at: Time millisecondClockValue
			arguments: {anEvent copy resetHandlerFields}
			stepTime: 1].

]

{ #category : #accessing }
PluggableListMorph >> handlesBasicKeys [
	" if ya don't want the list to automatically handle non-modifier key 
	(excluding shift key) input, return false"
	^ handlesBasicKeys ifNil: [ true ]
]

{ #category : #accessing }
PluggableListMorph >> handlesBasicKeys: aBoolean [
	"set whether the list morph should handle basic keys like arrow keys, or whether everything should be passed to the model"
	handlesBasicKeys := aBoolean
]

{ #category : #'event handling' }
PluggableListMorph >> handlesMouseOverDragging: evt [
	^self dropEnabled
]

{ #category : #filtering }
PluggableListMorph >> hasFilter [
	^ self filterTerm notEmpty
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> hasMultiSelection [

	^ false
]

{ #category : #drawing }
PluggableListMorph >> highlightSelection [
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> highlightSelector [
	^self valueOfProperty: #highlightSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> highlightSelector: aSelector [

	self highlightSelector = aSelector ifTrue: [^ self].
	self setProperty: #highlightSelector toValue: aSelector.
]

{ #category : #'accessing - items' }
PluggableListMorph >> hoverItem [

	^ self hoverRow = 0
		ifTrue: [nil]
		ifFalse: [self itemAt: self hoverRow]
]

{ #category : #accessing }
PluggableListMorph >> hoverRow [

	^ hoverRow ifNil: [0]
]

{ #category : #accessing }
PluggableListMorph >> hoverRow: viewIndex [

	hoverRow = viewIndex ifTrue: [^ self].
	
	self listMorph rowChanged: hoverRow with: viewIndex.
	hoverRow := viewIndex.
	
	self wantsBalloon ifTrue: [
		self activeHand
			removePendingBalloonFor: self;
			triggerBalloonFor: self after: self balloonHelpDelayTime].
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> iconAt: viewIndex [

	^ getIconSelector ifNotNil: [model perform: getIconSelector with: (self modelIndexFor: viewIndex)]
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> iconAt: viewIndex column: columnIndex [

	^ self iconAt: viewIndex
]

{ #category : #filtering }
PluggableListMorph >> indicateFiltered [
	"Don't need this pink background anymore, since now the current filter is highlighted in every matching substring entry in the list."
	"self color: Color red muchLighter muchLighter"
]

{ #category : #filtering }
PluggableListMorph >> indicateUnfiltered [
	
]

{ #category : #initialization }
PluggableListMorph >> initForKeystrokes [
	lastKeystrokeTime := 0.
	lastKeystrokes := ''
]

{ #category : #initialization }
PluggableListMorph >> initialize [
	listMorph := self createListMorph.
	super initialize.
	self scroller
		layoutPolicy: TableLayout new;
		addMorph: listMorph.	
	self
		minimumWidth: (self font widthOf: $m) * 5 ;
		minimumHeight: self font height
	
	
]

{ #category : #'debug and other' }
PluggableListMorph >> installModelIn: aWorld [
	"No special inits for new components"
	^ self
]

{ #category : #drawing }
PluggableListMorph >> isPluggableListMorph [
	^ true
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> itemAt: viewIndex [
	"Callback from list morph."
	
	^ self getList at: viewIndex
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> itemAt: viewIndex column: columnIndex [
	
	^ self itemAt: viewIndex
]

{ #category : #'accessing - items' }
PluggableListMorph >> itemFromPoint: aPoint [
	"Return the list element (morph) at the given point or nil if outside"
	| ptY |
	scroller hasSubmorphs ifFalse:[^nil].
	(scroller fullBounds containsPoint: aPoint) ifFalse:[^nil].
	ptY := (scroller firstSubmorph point: aPoint from: self) y.
	"note: following assumes that submorphs are vertical, non-overlapping, and ordered"
	scroller firstSubmorph top > ptY ifTrue:[^nil].
	scroller lastSubmorph bottom < ptY ifTrue:[^nil].
	"now use binary search"
	^scroller 
		findSubmorphBinary:[:item|
			(item top <= ptY and:[item bottom >= ptY])
				ifTrue:[0] "found"
				ifFalse:[ (item top + item bottom // 2) > ptY ifTrue:[-1] ifFalse:[1]]]
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> itemSelectedAmongMultiple: viewIndex [
	"return whether the index-th row is selected.  Always false in PluggableListMorph, but sometimes true in PluggableListMorphOfMany"
	^false
]

{ #category : #'event handling' }
PluggableListMorph >> keyStroke: event [ 
	"Process keys 
	The model is allowed to preview all keystrokes. If it's not interested:
	specialKeys are things like up, down, etc. ALWAYS HANDLED 
	modifierKeys are regular characters either 1) accompanied with ctrl, 
	cmd or 2) any character if the list doesn't want to handle basic 
	keys (handlesBasicKeys returns false) 
	basicKeys are any characters"
	
	| aChar aSpecialKey |
	(self previewKeystroke: event)
		ifTrue: [^ self].
	
	aChar := event keyCharacter.
	
	(aSpecialKey := aChar asciiValue) < 32
		ifTrue: [^ self specialKeyPressed: aSpecialKey].
	
	(event anyModifierKeyPressed or: [self handlesBasicKeys not])
		ifTrue: [^ self modifierKeyPressed: aChar].
		
	^ self basicKeyPressed: aChar
]

{ #category : #'event handling' }
PluggableListMorph >> keyboardFocusChange: aBoolean [ 
	"Clear the hover effect and maybe the current list filter if we lose keyboard focus."
	
	aBoolean ifFalse:
		[self hoverRow: nil.
		self clearFilterAutomatically ifTrue:
			[self removeFilter]].
		
	super keyboardFocusChange: aBoolean.
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> keystrokeActionSelector [
	^ keystrokeActionSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> keystrokeActionSelector: keyActionSel [
	"Set the keystroke action selector as specified"

	keystrokeActionSelector := keyActionSel
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> keystrokePreviewSelector [
	^ keystrokePreviewSelector
]

{ #category : #'accessing - selectors' }
PluggableListMorph >> keystrokePreviewSelector: sel [
	"The method on the model that will be given first view of any keystroke events.  For access via scripting"

	keystrokePreviewSelector := sel
]

{ #category : #filtering }
PluggableListMorph >> listFilterAppend: aChar [
	"Update the list filter or change selection to match the current filter expression. The given character will be appended to the current filter term."

	| milliseconds slowKeyStroke newModelIndex oldModelIndex |
	model okToChange ifFalse: [ ^ self ].

	newModelIndex := oldModelIndex := self getCurrentSelectionIndex.
	milliseconds := Time millisecondClockValue.
	slowKeyStroke := (Time
		milliseconds: milliseconds
		since: lastKeystrokeTime) > self class clearFilterDelay.
	slowKeyStroke := slowKeyStroke or:
		"For unfiltered lists, ff the users hits the same key repeatedly, support navigation regardless of the configured delay, as quickly as they want."
		[ self filterableList not and: [ lastKeystrokes size = 1 and: [ lastKeystrokes first = aChar ] ] ] .
	lastKeystrokeTime := milliseconds.

	"1) Record the key press."
	slowKeyStroke
		ifTrue:
			[ "Fresh filter expression *and* filterable lists? Keep track of that for escaping the filter."
			(self filterableList and: [self hasFilter not]) ifTrue:
				[ priorSelection := self modelIndexFor: self selectionIndex ].
			"Forget previous keystrokes and search in following elements."
			lastKeystrokes := aChar asLowercase asString.
			self filterableList ifFalse: 
				[ newModelIndex := self modelIndexFor: ((self nextSelectionIndexFrom: self selectionIndex) max: 1) ] ]
		ifFalse:
			[ "Append quick keystrokes but don't move selection if it still matches."
			lastKeystrokes := lastKeystrokes , aChar asLowercase asString.
			self filterableList ifFalse:
				[ newModelIndex := self modelIndexFor: ((self nextSelectionIndexFrom: self selectionIndex-1) max: 1) ] ].

	self filterableList ifTrue:
		[ self updateListFilter.
		newModelIndex := self modelIndexFor: 1 ].
	
	(self hasFilter and: [(self getCurrentSelectionIndex = newModelIndex) not]) ifTrue:
		[ self changeModelSelection: newModelIndex ].
]

{ #category : #filtering }
PluggableListMorph >> listFilterSet: aString [
	"Set the filter term and select the first match."

	self filterTerm: aString.
	self changeModelSelection: (self listSize = 0 ifTrue: [0] ifFalse: [self modelIndexFor: 1]).
]

{ #category : #accessing }
PluggableListMorph >> listMorph [

	^ listMorph
]

{ #category : #private }
PluggableListMorph >> listMorphClass [
	^LazyListMorph
]

{ #category : #'list morph callbacks' }
PluggableListMorph >> listSize [
	"Number of items in the (filtered) list."
	
	^ self getList size
]

{ #category : #selection }
PluggableListMorph >> maximumSelection [
	"Return the highest ui index that can be selected."
	
	^ self listSize
]

{ #category : #selection }
PluggableListMorph >> minimumSelection [
	^ 1
]

{ #category : #filtering }
PluggableListMorph >> modelIndexFor: selectionIndex [ 
	"The model does not know anything about the receiver's filtering. So if I am filtered, we must determine the correct index by scanning the full list in the model -- or use the lookup cache."
	
	self hasFilter ifFalse: [^ selectionIndex]. "No lookup needed."
	self filterableList ifFalse: [^ selectionIndex]. "No lookup needed."
	selectionIndex = 0 ifTrue: [^ 0]. "Nothing selected."
	
	^ viewToModel at: selectionIndex ifAbsent: [0]
]

{ #category : #'model access - keystroke' }
PluggableListMorph >> modifierKeyPressed: aChar [ 
	
	keystrokeActionSelector ifNil: [^ self].

	model
		perform: keystrokeActionSelector
		withEnoughArguments: {
			aChar.
			self}.
]

{ #category : #'event handling' }
PluggableListMorph >> mouseDown: evt [
	| selectors row |
	row := self rowAtLocation: evt position.

	evt yellowButtonPressed  "First check for option (menu) click"
		ifTrue: [
			((self selectionIndex ~= row
				and: [self class menuRequestUpdatesSelection])
				and: [model okToChange]) ifTrue: [
					"Models depend on the correct selection:"
					self changeModelSelection: (self modelIndexFor: row)].
			
			^ self yellowButtonActivity: evt shiftPressed].
	row = 0  ifTrue: [^super mouseDown: evt].
	"self dragEnabled ifTrue: [aMorph highlightForMouseDown]."
	selectors := Array 
		with: #click:
		with: (doubleClickSelector ifNotNil:[#doubleClick:])
		with: nil
		with: (self dragEnabled ifTrue:[#startDrag:] ifFalse:[nil]).
	evt hand waitForClicksOrDrag: self event: evt selectors: selectors threshold: HandMorph dragThreshold "pixels".
]

{ #category : #'event handling' }
PluggableListMorph >> mouseEnter: event [

	super mouseEnter: event.
	Preferences mouseOverForKeyboardFocus
		ifTrue: [event hand newKeyboardFocus: self].
]

{ #category : #'event handling' }
PluggableListMorph >> mouseEnterDragging: evt [

	(evt hand hasSubmorphs and:[self dropEnabled]) ifFalse: ["no d&d"
		^super mouseEnterDragging: evt].

	(self wantsDroppedMorph: evt hand firstSubmorph event: evt )
		ifTrue:[
			potentialDropRow := self rowAtLocation: evt position.
			evt hand newMouseFocus: self.
			self changed.
			"above is ugly but necessary for now"
		].

]

{ #category : #'event handling' }
PluggableListMorph >> mouseLeave: event [ 

	super mouseLeave: event.
	self hoverRow: nil.
	self resetPotentialDropRow.

	Preferences mouseOverForKeyboardFocus
		ifTrue: [event hand releaseKeyboardFocus: self].
]

{ #category : #events }
PluggableListMorph >> mouseLeaveDragging: anEvent [

	self hoverRow: nil.
	anEvent hand releaseMouseFocus: self.
	(self dropEnabled and:[anEvent hand hasSubmorphs]) ifFalse: ["no d&d"
		^ super mouseLeaveDragging: anEvent].
	self resetPotentialDropRow.
	"above is ugly but necessary for now"

]

{ #category : #'event handling' }
PluggableListMorph >> mouseMove: evt [

	(self dropEnabled and:[evt hand hasSubmorphs]) 
		ifFalse:[^super mouseMove: evt].
	potentialDropRow ifNotNil:[
		potentialDropRow = (self rowAtLocation: evt position)
			ifTrue:[^self].
	].
	self mouseLeaveDragging: evt.
	(self containsPoint: evt position) 
		ifTrue:[self mouseEnterDragging: evt].
]

{ #category : #'event handling' }
PluggableListMorph >> mouseUp: event [ 

	| row |
	model okToChange ifFalse: [^ self].
	(self containsPoint: event position) ifFalse: [^ self].

	row := self rowAtLocation: event position.
	row = self selectionIndex
		ifTrue: [(autoDeselect ifNil: [true]) ifTrue: [row = 0 ifFalse: [self changeModelSelection: 0] ]]
		ifFalse: [self changeModelSelection: (self modelIndexFor: row)].
		
	event hand newKeyboardFocus: self. 
	hasFocus := true.
	Cursor normal show.
]

{ #category : #filtering }
PluggableListMorph >> nextSelectionIndexFrom: start [
	"Return the next selection index that matches the current filter term."
	
	| newViewIndex oldViewIndex startIndex |	
	oldViewIndex := newViewIndex := start \\ (self listSize max: 1) + 1.
	startIndex := newViewIndex.
	
	[ (self itemAt: newViewIndex) asString withBlanksTrimmed asLowercase
		beginsWith: lastKeystrokes ] whileFalse:
			[ (newViewIndex := newViewIndex \\ (self listSize max: 1) + 1) = startIndex ifTrue:
				[ self flash. ^ 0 "Not in list." ] ].
	
	oldViewIndex = newViewIndex ifTrue: [ self flash ].
	
	^ newViewIndex
]

{ #category : #scrolling }
PluggableListMorph >> numSelectionsInView [
	"Overwritten to map submorphCount to the (filtered) list size. There is only one submorph: the lazy list morph."
	
	^ scroller numberOfItemsPotentiallyInViewWith: self listSize
]

{ #category : #scrolling }
PluggableListMorph >> offsetToShow: aRectangle [
	"Due to the approximation of the horizontal scroll range and the primary interaction along the vertical axis, we snap back to 0 on the horizontal axis."
	
	^ 0 @ (super offsetToShow: aRectangle) y
]

{ #category : #initialization }
PluggableListMorph >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [ 

	self model: anObject.

	getListSelector := getListSel.
	getIndexSelector := getSelectionSel.
	setIndexSelector := setSelectionSel.
	getMenuSelector := getMenuSel.
	keystrokeActionSelector := keyActionSel.

	autoDeselect := true.

	self updateList.
	self updateListSelection.
	
	self initForKeystrokes.
]

{ #category : #'drag and drop' }
PluggableListMorph >> potentialDropItem [
	"return the item that the most recent drop hovered over, or nil if there is no potential drop target"
	self potentialDropRow = 0 ifTrue: [ ^self ].
	^self itemAt: self potentialDropRow
]

{ #category : #'drag and drop' }
PluggableListMorph >> potentialDropRow [
	"return the row of the item that the most recent drop hovered over, or 0 if there is no potential drop target"
	^potentialDropRow ifNil: [ 0 ].

]

{ #category : #'model access - keystroke' }
PluggableListMorph >> previewKeystroke: keystrokeEvent [
	"Let the model decide if it's going to handle the event for us"

	keystrokePreviewSelector ifNil: [^ false].
	
	^ model
		perform: keystrokePreviewSelector
		withEnoughArguments: {
			keystrokeEvent.
			self}
]

{ #category : #filtering }
PluggableListMorph >> removeFilter [

	self filterTerm: String empty.
]

{ #category : #'drag and drop' }
PluggableListMorph >> resetPotentialDropRow [
	potentialDropRow ifNotNil: [
	potentialDropRow ~= 0 ifTrue: [
		potentialDropRow := 0.
		self changed. ] ]
]

{ #category : #selection }
PluggableListMorph >> rowAboutToBecomeSelected: anInteger [

	self listMorph preSelectedRow: anInteger
]

{ #category : #'accessing - items' }
PluggableListMorph >> rowAtLocation: aPoint [
	"Return the row at the given point or 0 if outside"
	| pointInListMorphCoords |
	pointInListMorphCoords := (self scroller transformFrom: self) transform: aPoint.
	^self listMorph rowAtLocation: pointInListMorphCoords.
]

{ #category : #geometry }
PluggableListMorph >> scrollDeltaHeight [
	"Return the increment in pixels which this pane should be scrolled."
	^ self font height
]

{ #category : #geometry }
PluggableListMorph >> scrollDeltaWidth [
"A guess -- assume that the width of a char is approx 1/2 the height of the font"
	^ self scrollDeltaHeight // 2


]

{ #category : #selection }
PluggableListMorph >> scrollSelectionIntoView [
	"make sure that the current selection is visible"

	| row |
	(row := self selectionIndex) = 0
		ifFalse: [self scrollToShow: (self listMorph drawBoundsForRow: row)]
]

{ #category : #selection }
PluggableListMorph >> selectedMorph [
	"this doesn't work with the LargeLists patch!  Use #selectionIndex and #selection instead."
	^self scroller submorphs at: self selectionIndex
]

{ #category : #selection }
PluggableListMorph >> selectedMorph: aMorph [ 
	"this shouldn't be used any longer. Only sent by implemetations of #list: such as PluggableListMorph, SimpleHierarchicalListMorph etc"

	self isThisEverCalled .
	true ifTrue: [^self]
]

{ #category : #selection }
PluggableListMorph >> selection [ 
	
	^ self getList
		at: self selectionIndex
		ifAbsent: [nil]
]

{ #category : #selection }
PluggableListMorph >> selection: item [
	"Called from outside to request setting a new selection."

	self selectionIndex: (self getList indexOf: item)
]

{ #category : #selection }
PluggableListMorph >> selectionIndex [
	"return the index we have currently selected, or 0 if none"
	^self listMorph selectedRow ifNil: [ 0 ]
]

{ #category : #selection }
PluggableListMorph >> selectionIndex: viewIndex [
	"Called internally to select the index-th item."

	self selectionIndex = viewIndex ifTrue: [^ self].

	self unhighlightSelection.
	self listMorph selectedRow: (viewIndex min: self listSize).
	self highlightSelection.
	
	self scrollSelectionIntoView.
]

{ #category : #initialization }
PluggableListMorph >> setDefaultParameters [

	super setDefaultParameters.
	
	self
		font: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]);
		textColor: (self userInterfaceTheme textColor ifNil: [Color black]).
		
	self setListParameters.
]

{ #category : #menus }
PluggableListMorph >> setListFont [
	"set the font for the list"

	Preferences 
		chooseFontWithPrompt: 'Choose the font for this list' translated 
		andSendTo: self 
		withSelector: #font: 
		highlightSelector: #font
]

{ #category : #initialization }
PluggableListMorph >> setListParameters [

	self listMorph
		selectionColor: (self userInterfaceTheme selectionColor ifNil: [Color r: 0.72 g: 0.72 b: 0.9]);
		multiSelectionColor: (self userInterfaceTheme multiSelectionColor ifNil: [(Color r: 0.72 g: 0.72 b: 0.9) lighter]);
		setProperty: #selectionTextColor
			toValue: (self userInterfaceTheme selectionTextColor ifNil: [Color black]);
		filterColor: (self userInterfaceTheme filterColor ifNil: [Color yellow paler]);
		setProperty: #filterTextColor
			toValue: (self userInterfaceTheme filterTextColor ifNil: [Color black]);
		
		setProperty: #preSelectionColor
			toValue: ((self userInterfaceTheme preSelectionModifier ifNil: [ [:c | Color gray: 0.9] ]) value: self listMorph selectionColor asColor);
		setProperty: #hoverColor
			toValue: ((self userInterfaceTheme hoverSelectionModifier ifNil: [ [:c | c darker alpha: 0.3] ]) value: self listMorph selectionColor asColor)
]

{ #category : #selection }
PluggableListMorph >> setSelectedMorph: aMorph [ 
	self changeModelSelection: (self modelIndexFor: (scroller submorphs indexOf: aMorph))
]

{ #category : #'model access - keystroke' }
PluggableListMorph >> specialKeyPressed: asciiValue [
	"A special key with the given ascii-value was pressed; dispatch it"
	| oldSelection nextSelection max howManyItemsShowing |
	(#(8 13) includes: asciiValue) ifTrue:
		[ "backspace key - clear the filter, restore the list with the selection" 
		model okToChange ifFalse: [^ self].
		self removeFilter.
		priorSelection ifNotNil:
			[ | prior |
			prior := priorSelection.
			priorSelection := self getCurrentSelectionIndex.
			asciiValue = 8 ifTrue: [ self changeModelSelection: prior ] ].
		^ self ].
	asciiValue = 27 ifTrue: 
		[" escape key"
		^ self currentEvent shiftPressed
			ifTrue:
				[self currentWorld putUpWorldMenuFromEscapeKey]
			ifFalse:
				[self yellowButtonActivity: false]].

	max := self maximumSelection.
	max > 0 ifFalse: [^ self].
	nextSelection := oldSelection := self selectionIndex.
	asciiValue = 31 ifTrue: 
		[" down arrow"
		nextSelection := oldSelection + 1.
		nextSelection > max ifTrue: [nextSelection := 1]].
	asciiValue = 30 ifTrue: 
		[" up arrow"
		nextSelection := oldSelection - 1.
		nextSelection < 1 ifTrue: [nextSelection := max]].
	asciiValue = 1 ifTrue:
		[" home"
		nextSelection := 1].
	asciiValue = 4 ifTrue:
		[" end"
		nextSelection := max].
	howManyItemsShowing := self numSelectionsInView.
	asciiValue = 11 ifTrue:
		[" page up"
		nextSelection := 1 max: oldSelection - howManyItemsShowing].
	asciiValue = 12 ifTrue:
		[" page down"
		nextSelection := oldSelection + howManyItemsShowing min: max].
	model okToChange ifFalse: [^ self].
	"No change if model is locked"
	oldSelection = nextSelection ifTrue: [^ self flash].
	^ self changeModelSelection: (self modelIndexFor: nextSelection)
]

{ #category : #'drag and drop' }
PluggableListMorph >> startDrag: evt [ 

	| item itemMorph |
	evt hand hasSubmorphs ifTrue: [^ self].
	self model okToChange ifFalse: [^ self].

	"Ensure selection to save additional click."
	(self rowAtLocation: evt position) in: [:clickedRow |
		self selectionIndex = clickedRow
			ifFalse: [self changeModelSelection: (self modelIndexFor: clickedRow)]].

	item := self selection ifNil: [^ self].
	itemMorph := StringMorph contents: item asStringOrText.
	
	[ "Initiate drag."
		(self model dragPassengerFor: itemMorph inMorph: self) ifNotNil: [:passenger | | ddm |
			ddm := (self valueOfProperty: #dragTransferClass ifAbsent: [TransferMorph]) withPassenger: passenger from: self.
			ddm dragTransferType: (self model dragTransferTypeForMorph: self).
			ddm updateFromUserInputEvent: evt.
			self model dragStartedFor: itemMorph transferMorph: ddm.
			evt hand grabMorph: ddm.
			self mouseEnterDragging: evt "Enable internal move"]
	] ensure: [Cursor normal show].
]

{ #category : #initialization }
PluggableListMorph >> textColor [
	"Answer my default text color."
	^self valueOfProperty: #textColor ifAbsent: [ Color black ]

]

{ #category : #initialization }
PluggableListMorph >> textColor: aColor [
	"Set my default text color."
	self setProperty: #textColor toValue: aColor.
	self listMorph color: aColor.
]

{ #category : #'accessing - items' }
PluggableListMorph >> topVisibleRowIndex [
	^ self rowAtLocation: self scroller topLeft
]

{ #category : #drawing }
PluggableListMorph >> unhighlightSelection [

]

{ #category : #updating }
PluggableListMorph >> update: aSymbol [ 

	aSymbol == getListSelector ifTrue: [^ self updateList].
	aSymbol == getIndexSelector ifTrue: [^ self updateListSelection].
	
	"The following selectors are rarely used."
	aSymbol == getListSizeSelector ifTrue: [^ self updateList].
	aSymbol == getListElementSelector ifTrue: [^ self updateList].
]

{ #category : #updating }
PluggableListMorph >> update: aSymbol with: arg1 [

	(aSymbol == #inputRequested and: [getIndexSelector == arg1 or: [setIndexSelector == arg1]])
		ifTrue: [self activeHand newKeyboardFocus: self].
		
	super update: aSymbol with: arg1.
]

{ #category : #updating }
PluggableListMorph >> updateList [

	self updateList: nil.
]

{ #category : #updating }
PluggableListMorph >> updateList: modelList [
	"Keeps the current filter as it is."
	
	fullList := modelList.
	self updateListFilter.
]

{ #category : #updating }
PluggableListMorph >> updateListFilter [

	| selection |
	selection := self selectionIndex = 0 "Avoid fetching #getList here."
		ifTrue: [nil]
		ifFalse: [self selection].

	list := nil.
	modelToView := Dictionary new.
	viewToModel := Dictionary new.
	
	self getList.
	
	"Try to restore the last selection."
	selection ifNotNil: [self selection: selection].
]

{ #category : #updating }
PluggableListMorph >> updateListMorph [
	"Tell my list morph that the data has changed. This is an extra hook for subclasses."
	
	self listMorph listChanged.
]

{ #category : #updating }
PluggableListMorph >> updateListSelection [

	self updateListSelection: self getCurrentSelectionIndex.
]

{ #category : #updating }
PluggableListMorph >> updateListSelection: modelIndex [
	"Model changed the selection. Invalidate the filtered list if the selection index cannot be found."

	| viewIndex |
	modelIndex = 0 ifTrue: [
		^ self selectionIndex: 0].

	"The the model is inconsistent. Cannot fix here."
	modelIndex > self fullListSize ifTrue: [
		^ self selectionIndex: 0].
		
	"Lookup the view index."
	viewIndex := self viewIndexFor: modelIndex.

	"The filter is preventing us from selecting the item we want - remove it."
	viewIndex = 0 ifTrue: [
		self removeFilter.
		viewIndex := modelIndex].

	self selectionIndex: viewIndex.
]

{ #category : #'debug and other' }
PluggableListMorph >> userString [
	"Do I have a text string to be searched on?"

	^ String streamContents: [:strm |
		self getFullList do: [:item |
			"must use asStringOrText because that's what the drawing uses, too"
			strm nextPutAll: item asStringOrText; cr]]
]

{ #category : #updating }
PluggableListMorph >> verifyContents [
	"Verify the contents of the receiver, reconstituting if necessary.  Called whenever window is reactivated, to react to possible structural changes.  Also called periodically in morphic if the smartUpdating preference is true"

	| currentList modelList modelIndex |
	self flag: #performance. "mt: We do have changed/update. Why can't the tools communicate through an appropriate notifier such as the SystemChangeNotifier?"

	"1) Is the list still up to date?"
	currentList := fullList. fullList := nil.
	modelList := self getFullList.
	modelList = currentList
		ifFalse: [self updateList: modelList].
	
	"2) Is the selection still up to date?"
	modelIndex := self getCurrentSelectionIndex.
	(self modelIndexFor: self selectionIndex) = modelIndex
		ifFalse: [self updateListSelection: modelIndex].
]

{ #category : #filtering }
PluggableListMorph >> viewIndexFor: modelIndex [ 
	"The model does not know anything about the receiver's filtering. So if I am filtered, we must determine the correct index by scanning the filtered list in the view -- or use the lookup cache."

	self hasFilter ifFalse: [^ modelIndex]. "No lookup needed."
	self filterableList ifFalse: [^ modelIndex]. "No lookup needed."
	modelIndex = 0 ifTrue: [^ 0]. "Nothing selected."
	
	^ modelToView at: modelIndex ifAbsent: [0]
]

{ #category : #accessing }
PluggableListMorph >> visibleList [
	"For convenience. Avoid accessing #getList directly. Just use the same protocol that my #listMorph uses."
	
	^ self listSize = 0
		ifTrue: [ Array empty ]
		ifFalse:
			[ (self topVisibleRowIndex to: self bottomVisibleRowIndex) collect:
				[ :viewIndex |
					self itemAt: viewIndex ] ].
]

{ #category : #'drag and drop' }
PluggableListMorph >> wantsDroppedMorph: aMorph event: anEvent [ 
	^ self model wantsDroppedMorph: aMorph event: anEvent inMorph: self
]
