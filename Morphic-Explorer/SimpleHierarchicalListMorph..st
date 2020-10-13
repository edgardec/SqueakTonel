"
Display a hierarchical list of items.  Each item should be wrapped with a ListItemWrapper.

For a simple example, look at submorphsExample.  For beefier examples, look at ObjectExplorer or FileList2.
"
Class {
	#name : #SimpleHierarchicalListMorph,
	#superclass : #ScrollPane,
	#instVars : [
		'selectedMorph',
		'hoveredMorph',
		'getListSelector',
		'keystrokeActionSelector',
		'autoDeselect',
		'columns',
		'columnsCache',
		'sortingSelector',
		'getSelectionSelector',
		'setSelectionSelector',
		'potentialDropMorph',
		'lineColor',
		'font',
		'textColor'
	],
	#classVars : [
		'WrappedNavigation'
	],
	#classInstVars : [
		'expandedForm',
		'notExpandedForm'
	],
	#category : #'Morphic-Explorer'
}

{ #category : #preferences }
SimpleHierarchicalListMorph class >> applyUserInterfaceTheme [

	expandedForm := nil.
	notExpandedForm := nil.
]

{ #category : #'instance creation' }
SimpleHierarchicalListMorph class >> expandedForm [
	expandedForm
		ifNotNil: [expandedForm depth ~= Display depth
				ifTrue: [expandedForm := nil]].
	^ expandedForm
		ifNil: [expandedForm := ((Form
						extent: 10 @ 9
						depth: 8
						fromArray: #(4294967295 4294967295 4294901760 4294967295 4294967295 4294901760 4278255873 16843009 16842752 4294902089 1229539657 33488896 4294967041 1229539585 4294901760 4294967295 21561855 4294901760 4294967295 4278321151 4294901760 4294967295 4294967295 4294901760 4294967295 4294967295 4294901760 )
						offset: 0 @ 0)
						asFormOfDepth: Display depth)
							replaceColor: Color white withColor: Color transparent;
							scaleIconToDisplay]
]

{ #category : #'instance creation' }
SimpleHierarchicalListMorph class >> notExpandedForm [
	notExpandedForm
		ifNotNil: [notExpandedForm depth ~= Display depth
				ifTrue: [notExpandedForm := nil]].
	^ notExpandedForm
		ifNil: [notExpandedForm := ((Form
						extent: 10 @ 9
						depth: 8
						fromArray: #(4294967041 4294967295 4294901760 4294967041 33554431 4294901760 4294967041 1224867839 4294901760 4294967041 1229521407 4294901760 4294967041 1229539585 4294901760 4294967041 1229521407 4294901760 4294967041 1224867839 4294901760 4294967041 33554431 4294901760 4294967041 4294967295 4294901760 )
						offset: 0 @ 0)
							asFormOfDepth: Display depth)
								replaceColor: Color white withColor: Color transparent;
								scaleIconToDisplay]
]

{ #category : #'instance creation' }
SimpleHierarchicalListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel [
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
SimpleHierarchicalListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel [
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
SimpleHierarchicalListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self new
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: keyActionSel

]

{ #category : #examples }
SimpleHierarchicalListMorph class >> submorphsExample [
	"display a hierarchical list of the current world plus its submorphs plus its submorphs' submorphs etc."
	"SimpleHierarchicalListMorph submorphsExample"
	| morph |
	morph :=
		SimpleHierarchicalListMorph
			on: [ Array with:  (MorphWithSubmorphsWrapper with: Project current world)  ]
			list: #value
			selected: nil
			changeSelected: nil
			menu: nil
			keystroke: nil.

	morph openInWindow
]

{ #category : #preferences }
SimpleHierarchicalListMorph class >> themeProperties [

	^ super themeProperties, {
		{ #font. 'Fonts'. 'Font of the list items.' }.
		{ #textColor. 'Colors'. 'Color of the list items.' }.
		{ #selectionColor. 'Colors'. 'Color used for items when hovering or selecting them.' }.
		{ #selectionTextColor. 'Colors'. 'Color used for label when hovering or selecting them.' }.
		
		{ #filterColor. 'Colors'. 'Color used for items to indicate the matching filter.' }.
		{ #filterTextColor. 'Colors'. 'Color used for items to indicate the matching filter.' }.
		{ #highlightTextColor. 'Colors'. 'Color used for highlighted items.' }.
		
		{ #hoverSelectionModifier. 'Colors'. 'How to derive the hover color from the selection color.'}.

		{ #lineColor. 'Colors'. 'How the lines are drawn.' }.
	}
]

{ #category : #preferences }
SimpleHierarchicalListMorph class >> wrappedNavigation [
	<preference: 'Wrapped Tree Navigation'
		category: 'Morphic'
		description: 'When enabled, use of the arrow keys at the top or bottom of a hierarchical list will wrap to the opposite side of the list.'
		type: #Boolean>
	^ WrappedNavigation ifNil: [ false ]
]

{ #category : #preferences }
SimpleHierarchicalListMorph class >> wrappedNavigation: aBoolean [ 
	WrappedNavigation := aBoolean
]

{ #category : #'drag and drop' }
SimpleHierarchicalListMorph >> acceptDroppingMorph: aMorph event: evt [

	self model
		acceptDroppingMorph: aMorph
		event: evt
		inMorph: self.
	self resetPotentialDropMorph.
	evt hand releaseMouseFocus: self.
	Cursor normal show.

]

{ #category : #private }
SimpleHierarchicalListMorph >> addMorphsTo: morphList from: aCollection allowSorting: sortBoolean withExpandedItems: expandedItems atLevel: newIndent [

	| priorMorph newCollection firstAddition |
	priorMorph := nil.
	newCollection := (sortBoolean and: [sortingSelector notNil]) ifTrue: [
		aCollection sorted: [ :a :b | 
			(a perform: sortingSelector) <= (b perform: sortingSelector)]
	] ifFalse: [
		aCollection
	].
	firstAddition := nil.
	newCollection do: [:item | 
		priorMorph := self indentingItemClass basicNew 
			initWithContents: item 
			prior: priorMorph 
			forList: self
			indentLevel: newIndent.
		priorMorph
			initWithColor: self textColor
			andFont: self font.
		priorMorph
			selectionColor: self selectionColor;
			selectionTextColor: self selectionTextColor;
			hoverColor: self hoverColor;
			highlightTextColor: self highlightTextColor;
			filterColor: self filterColor;
			filterTextColor: self filterTextColor.
		firstAddition ifNil: [firstAddition := priorMorph].
		morphList add: priorMorph.
		((item hasEquivalentIn: expandedItems) or: [priorMorph isExpanded]) ifTrue: [
			self flag: #bug. "mt: Endless recursion can happen for similar items in the tree."
			priorMorph isExpanded: true.
			priorMorph 
				addChildrenForList: self 
				addingTo: morphList
				withExpandedItems: expandedItems.
		].
	].
	^firstAddition
	

]

{ #category : #private }
SimpleHierarchicalListMorph >> addSubmorphsAfter: parentMorph fromCollection: aCollection allowSorting: sortBoolean [

	| priorMorph morphList newCollection |
	priorMorph := nil.
	newCollection := (sortBoolean and: [sortingSelector notNil]) ifTrue: [
		aCollection sorted: [ :a :b | 
			(a perform: sortingSelector) <= (b perform: sortingSelector)]
	] ifFalse: [
		aCollection
	].
	morphList := OrderedCollection new.
	newCollection do: [:item | 
		priorMorph := self indentingItemClass basicNew 
			initWithContents: item 
			prior: priorMorph 
			forList: self
			indentLevel: parentMorph indentLevel + 1.
		priorMorph
			color: self textColor;
			font: self font;
			selectionColor: self selectionColor;
			selectionTextColor: self selectionTextColor;
			hoverColor: self hoverColor;
			highlightTextColor: self highlightTextColor;
			filterColor: self filterColor;
			filterTextColor: self filterTextColor.
		morphList add: priorMorph.
	].
	scroller addAllMorphs: morphList after: parentMorph.
	^morphList
	

]

{ #category : #private }
SimpleHierarchicalListMorph >> adjustSubmorphPositions [

	| p |
	p := 0@0.
	scroller submorphsDo: [ :each | | h |
		each visible ifTrue: [
			h := each height.
			each privateBounds: (p extent: self preferredSubmorphWidth@h).
			p := p + (0@h) ]].
	self 
		clearColumnsCache;
		changed;
		layoutChanged;
		setScrollDeltas.

]

{ #category : #updating }
SimpleHierarchicalListMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self adjustSubmorphPositions.
]

{ #category : #'keyboard navigation' }
SimpleHierarchicalListMorph >> arrowKey: asciiValue [
	"Handle a keyboard navigation character. Answer true if handled, false if not."
	| keyEvent max oldSelection nextSelection howManyItemsShowing keyHandled |
	keyHandled := false.
	keyEvent := asciiValue.
	max := self maximumSelection.
	nextSelection := oldSelection := self getSelectionIndex.
     keyEvent = 31 ifTrue:["down"
		keyHandled := true.
		nextSelection :=oldSelection + 1.
		nextSelection > max ifTrue: [nextSelection := (self class wrappedNavigation ifTrue: [1] ifFalse: [max])]].
     keyEvent = 30 ifTrue:["up"
		keyHandled := true.
		nextSelection := oldSelection - 1.
		nextSelection < 1 ifTrue: [nextSelection := self class wrappedNavigation ifTrue: [max] ifFalse: [1]]].
     keyEvent = 1  ifTrue: ["home"
		keyHandled := true.
		nextSelection := 1].
     keyEvent = 4  ifTrue: ["end"
		keyHandled := true.
		nextSelection := max].
	howManyItemsShowing := self numSelectionsInView.
      keyEvent = 11 ifTrue: ["page up"
		keyHandled := true.
		nextSelection := 1 max: oldSelection - howManyItemsShowing].
     keyEvent = 12  ifTrue: ["page down"
		keyHandled := true.
		nextSelection := oldSelection + howManyItemsShowing min: max].

	(nextSelection ~= oldSelection or: [ keyHandled and: [ self class wrappedNavigation not ]]) ifTrue: [
		self setSelectionIndex: nextSelection.
		^ true].
	
	keyEvent = 29 ifTrue:["right"
		selectedMorph ifNotNil:[
			(selectedMorph canExpand and:[selectedMorph isExpanded not])
				ifTrue:[self toggleExpandedState: selectedMorph]
				ifFalse:[self setSelectionIndex: self getSelectionIndex+1].
		].
		^true].
	keyEvent = 28 ifTrue:["left"
		selectedMorph ifNotNil:[
			(selectedMorph isExpanded)
				ifTrue:[self toggleExpandedState: selectedMorph]
				ifFalse:[self setSelectionIndex: (self getSelectionIndex-1 max: 1)].
		].
		^true].
	^false
]

{ #category : #initialization }
SimpleHierarchicalListMorph >> autoDeselect: trueOrFalse [
	"When selecting a selected item, it will be deselected. See #mouseUp:."
	
	autoDeselect := trueOrFalse.
]

{ #category : #'private - caching' }
SimpleHierarchicalListMorph >> clearColumnsCache [

	columnsCache := self columns
		ifNil: [Array empty]
		ifNotNil: [:c | Array new: c size].
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> columns [

	^columns
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> columns: anArray [
	"You can specify columns or specs for columns. This depends on the actual morph that is used as item. ObjectExplorers produce items that support exact numbers, blocks, and nil for max width."
	
	columns := anArray.
	self clearColumnsCache.
]

{ #category : #'private - caching' }
SimpleHierarchicalListMorph >> columnsCache [
	columnsCache ifNil: [self clearColumnsCache].
	^ columnsCache
]

{ #category : #initialization }
SimpleHierarchicalListMorph >> currentlyExpanded [

	^(scroller submorphs select: [ :each | each isExpanded]) collect: [ :each |
		each complexContents
	].
	
]

{ #category : #drawing }
SimpleHierarchicalListMorph >> drawHoverOn: aCanvas [ 

	self hoveredMorph ifNil: [^ self].
	PluggableListMorph highlightHoveredRow ifFalse: [^ self].
	
	aCanvas
		transformBy: scroller transform
		clippingTo: scroller innerBounds
		during: [:c | self hoveredMorph drawHoverOn: c].
]

{ #category : #drawing }
SimpleHierarchicalListMorph >> drawLinesOn: aCanvas [

	| lColor |
	lColor := self lineColor.
	aCanvas 
		transformBy: scroller transform
		clippingTo: scroller innerBounds
		during:[:clippedCanvas |
			scroller submorphsDo: [ :submorph |
				(submorph visible and: [(submorph isExpanded
					or: [clippedCanvas isVisible: submorph fullBounds] )
					or: [	submorph nextSibling notNil and: [clippedCanvas isVisible: submorph nextSibling fullBounds]]]) 
						 ifTrue: [submorph drawLinesOn: clippedCanvas lineColor: lColor indentThreshold: 0] ] ]
		smoothing: scroller smoothing.

]

{ #category : #drawing }
SimpleHierarchicalListMorph >> drawOn: aCanvas [ 
	
	super drawOn: aCanvas.
	
	self drawHoverOn: aCanvas.
	self drawSelectionOn: aCanvas.
	self drawLinesOn: aCanvas.
]

{ #category : #drawing }
SimpleHierarchicalListMorph >> drawSelectionOn: aCanvas [ 

	self selectedMorph ifNotNil: [:m |
		aCanvas
			transformBy: scroller transform
			clippingTo: scroller innerBounds
			during: [:c | m drawSelectionOn: c] ].
]

{ #category : #events }
SimpleHierarchicalListMorph >> expand: aMorph to: level [
	| allChildren |
	aMorph toggleExpandedState.
	allChildren := OrderedCollection new: 10.
	aMorph recursiveAddTo: allChildren.
	allChildren do: [:each | 
		((each canExpand
			and: [each isExpanded not])
			and: [level > 0])
			ifTrue: [self expand: each to: level-1]].
]

{ #category : #events }
SimpleHierarchicalListMorph >> expandAll [
	(selectedMorph isNil
		or: [selectedMorph isExpanded])
		ifTrue: [^self].
	self expandAll: selectedMorph.
	self adjustSubmorphPositions
]

{ #category : #events }
SimpleHierarchicalListMorph >> expandAll: aMorph [
	| allChildren |
	aMorph toggleExpandedState.
	allChildren := OrderedCollection new: 10.
	aMorph recursiveAddTo: allChildren.
	allChildren do: [:each | 
		(each canExpand and: [each isExpanded not])
			ifTrue: [self expandAll: each]].

]

{ #category : #events }
SimpleHierarchicalListMorph >> expandAll: aMorph except: aBlock [
	| allChildren |
	(aBlock value: aMorph complexContents)
		ifFalse: [^self].
	aMorph toggleExpandedState.
	allChildren := OrderedCollection new: 10.
	aMorph recursiveAddTo: allChildren.
	allChildren do: [:each | 
		(each canExpand
			and: [each isExpanded not])
			ifTrue: [self expandAll: each except: aBlock]].
]

{ #category : #events }
SimpleHierarchicalListMorph >> expandRoots [
	"Expand all the receiver's roots"
	self roots
		do: [:each |
			(each canExpand and: [each isExpanded not])
				ifTrue: [each toggleExpandedState]].
	self adjustSubmorphPositions
]

{ #category : #drawing }
SimpleHierarchicalListMorph >> expandedForm [

	^self class expandedForm
]

{ #category : #geometry }
SimpleHierarchicalListMorph >> extent: newExtent [
	bounds extent = newExtent ifTrue: [^ self].
	super extent: newExtent.
	self setScrollDeltas 
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> filterColor [

	^ self valueOfProperty: #filterColor ifAbsent: [Color yellow]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> filterColor: aColor [

	self setProperty: #filterColor toValue: aColor.
	scroller submorphsDo: [:ea | ea filterColor: aColor].
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> filterTextColor [

	^ self valueOfProperty: #filterTextColor ifAbsent: [Color black]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> filterTextColor: aColor [

	self setProperty: #filterTextColor toValue: aColor.
	scroller submorphsDo: [:ea | ea filterTextColor: aColor].
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> font [
	^ font ifNil: [TextStyle defaultFont]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> font: aFont [
	font := aFont.
	scroller submorphsDo: [:ea | ea font: font].
]

{ #category : #selection }
SimpleHierarchicalListMorph >> getCurrentSelectionItem [

	^model perform: (getSelectionSelector ifNil: [^nil])
	
]

{ #category : #'model access' }
SimpleHierarchicalListMorph >> getList [ 
	"Answer the list to be displayed."

	^(model perform: (getListSelector ifNil: [^#()])) ifNil: [#()]


]

{ #category : #'keyboard navigation' }
SimpleHierarchicalListMorph >> getSelectionIndex [
	^scroller submorphs indexOf: selectedMorph
]

{ #category : #scrolling }
SimpleHierarchicalListMorph >> hUnadjustedScrollRange [
"Return the width of the widest item in the list"

	| max count |
	self flag: #tofix. "mt: What about icons and columns? Do we ever show horizontal scroll bars for such tree views anyway? Maybe just return 0?"
	
	max := 0.
	count := 0.
	scroller submorphsDo: [ :each | | stringW right |
		stringW := each font widthOfStringOrText: each contents.
		right := (each toggleRectangle right + stringW + 10).
		max := max max: right.
		
"NOTE: need to optimize this method by caching list item morph widths (can init that cache most efficiently in the #list: method before the item widths are reset to 9999).  For now, just punt on really long lists"
		((count := count + 1) > 200) ifTrue:[ ^max * 3].
	].

	^max 

]

{ #category : #'events-processing' }
SimpleHierarchicalListMorph >> handleMouseMove: anEvent [
	"Reimplemented because we really want #mouseMove when a morph is dragged around"
	anEvent wasHandled ifTrue:[^self]. "not interested"
	self hoveredMorph: (self itemFromPoint: anEvent position).
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

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> handlesMouseOverDragging: evt [
	^self dropEnabled
]

{ #category : #drawing }
SimpleHierarchicalListMorph >> highlightSelection [

	selectedMorph ifNotNil: [selectedMorph highlight]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> highlightTextColor [

	^ self valueOfProperty: #highlightTextColor ifAbsent: [Color red]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> highlightTextColor: aColor [

	self setProperty: #highlightTextColor toValue: aColor.
	scroller submorphsDo: [:ea | ea highlightTextColor: aColor].
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> hoverColor [

	^ self valueOfProperty: #hoverColor ifAbsent: [Color veryLightGray]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> hoverColor: aColor [

	self setProperty: #hoverColor toValue: aColor.
	scroller submorphsDo: [:ea | ea setProperty: #hoverColor toValue: aColor].
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> hoveredMorph [

	^ hoveredMorph
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> hoveredMorph: aMorph [

	hoveredMorph == aMorph ifTrue: [^ self].
	
	hoveredMorph ifNotNil: [:m | m changed].
	hoveredMorph := aMorph.
	hoveredMorph ifNotNil: [:m | m changed].	
]

{ #category : #initialization }
SimpleHierarchicalListMorph >> indentingItemClass [
	
	^IndentingListItemMorph
]

{ #category : #initialization }
SimpleHierarchicalListMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self setProperty: #autoExpand toValue: false.
	self
		on: #mouseMove
		send: #mouseStillDown:onItem:
		to: self
]

{ #category : #private }
SimpleHierarchicalListMorph >> insertNewMorphs: morphList [

	scroller addAllMorphs: morphList.
	self adjustSubmorphPositions.
	self selection: self getCurrentSelectionItem.
	self setScrollDeltas.

]

{ #category : #'debug and other' }
SimpleHierarchicalListMorph >> installModelIn: aWorld [
	"No special inits for new components"
	^ self
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> itemFromPoint: aPoint [
	"Return the list element (morph) at the given point or nil if outside"
	| ptY visibleRows |
	scroller hasSubmorphs ifFalse:[^nil].
	(scroller fullBounds containsPoint: aPoint) ifFalse:[^nil].
	
	visibleRows := scroller submorphs select: [:m | m visible].
	
	ptY := (visibleRows first point: aPoint from: self) y.
	"note: following assumes that submorphs are vertical, non-overlapping, and ordered"
	visibleRows first top > ptY ifTrue:[^nil].
	visibleRows last bottom < ptY ifTrue:[^nil].
	"now use binary search"
	^visibleRows
		findBinary:[:item|
			(item top <= ptY and:[item bottom >= ptY])
				ifTrue:[0] "found"
				ifFalse:[ (item top + item bottom // 2) > ptY ifTrue:[-1] ifFalse:[1]]]
		ifNone: [nil]
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> keyStroke: event [ 
	"Process potential command keys"
	
	event keyCharacter asciiValue < 32 ifTrue: [
		^ self specialKeyPressed: event keyCharacter asciiValue].
	
	" A lot of actions do not return a Boolean here (#messageListKey:from:, 
	#classListKey:from:, ...); even most #arrowKey:from: implementors do not.
	Hence, we explicitely check for false and else assume truthieness"
	^ (self keyStrokeAction: event) ~~ false

]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> keyStrokeAction: event [ 

	| numArgs |
	keystrokeActionSelector ifNil: [^false].
	
	numArgs := keystrokeActionSelector numArgs.
	
	numArgs = 1 ifTrue: [
		^ model
			perform: keystrokeActionSelector
			with: event keyCharacter].
	numArgs = 2 ifTrue: [
		^ model 
			perform: keystrokeActionSelector
			with: event keyCharacter
			with: self].
	numArgs = 3 ifTrue: [
		^ model 
			perform: keystrokeActionSelector
			with: event keyCharacter
			with: self
			with: event].
	^self error: 'The keystrokeActionSelector must be a 1-, 2-, or 3-keyword symbol'
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> lineColor [
	"Answer a good color to use for drawing the lines that connect members of the hierarchy view.
	Used the cached color, or derive it if necessary by finding the first owner (up to my root) that is not transparent, then picking a contrasting color.
	Fall back to veryLightGray if all my owners are transparent."

	| coloredOwner targetLuminance ownerColor darken |
	lineColor ifNotNil: [ ^lineColor ].
	coloredOwner := self firstOwnerSuchThat: [ :o | o isWorldOrHandMorph not and: [ o color isTransparent not ]].
	coloredOwner ifNil: [ ^Color veryLightGray ].
	ownerColor := coloredOwner color.
	darken := ownerColor luminance > 0.5.
	targetLuminance := ownerColor luminance + (darken ifTrue: [ -0.2 ] ifFalse: [ 0.2 ]).
	^darken
		ifTrue: [ ownerColor atMostAsLuminentAs: targetLuminance ]
		ifFalse: [ ownerColor atLeastAsLuminentAs: targetLuminance ]
	

]

{ #category : #accessing }
SimpleHierarchicalListMorph >> lineColor: aColor [
	^lineColor := aColor

]

{ #category : #initialization }
SimpleHierarchicalListMorph >> list: aCollection [

	| wereExpanded morphList |
	wereExpanded := self currentlyExpanded.
	scroller removeAllMorphs.
	(aCollection isNil or: [aCollection isEmpty]) ifTrue: [^ self selectedMorph: nil].
	morphList := OrderedCollection new.
	self 
		addMorphsTo: morphList
		from: aCollection 
		allowSorting: false
		withExpandedItems: wereExpanded
		atLevel: 0.
	self insertNewMorphs: morphList.
]

{ #category : #initialization }
SimpleHierarchicalListMorph >> listItemHeight [
	"This should be cleaned up.  The list should get spaced by this parameter."
	^ 12
]

{ #category : #selection }
SimpleHierarchicalListMorph >> maximumSelection [

	^ scroller submorphs size

]

{ #category : #selection }
SimpleHierarchicalListMorph >> minimumSelection [
	^ 1
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> mouseDown: evt [
	| aMorph selectors |
	aMorph := self itemFromPoint: evt position.
	evt yellowButtonPressed  "First check for option (menu) click"
		ifTrue: [
			(PluggableListMorph menuRequestUpdatesSelection and: [model okToChange]) ifTrue: [
				aMorph == selectedMorph 
					ifFalse: [self setSelectedMorph: aMorph]].
			^ self yellowButtonActivity: evt shiftPressed].
	(aMorph notNil and:[aMorph inToggleArea: (aMorph point: evt position from: self)])
		ifTrue:[^self toggleExpandedState: aMorph event: evt]. 
	aMorph ifNil:[^super mouseDown: evt].
	
	aMorph highlightForMouseDown.
	self setProperty: #highlightedMorph toValue: aMorph.
	
	selectors := Array 
		with: #click:
		with: nil
		with: nil
		with: (self dragEnabled ifTrue:[#startDrag:] ifFalse:[nil]).
	evt hand waitForClicksOrDrag: self event: evt selectors: selectors threshold: HandMorph dragThreshold "pixels".
]

{ #category : #obsolete }
SimpleHierarchicalListMorph >> mouseDown: event onItem: aMorph [
	self removeObsoleteEventHandlers.

]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> mouseEnter: event [

	super mouseEnter: event.
	
	Preferences mouseOverForKeyboardFocus
		ifTrue: [event hand newKeyboardFocus: self].
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> mouseEnterDragging: evt [
	| aMorph |
	(evt hand hasSubmorphs and:[self dropEnabled]) ifFalse: ["no d&d"
		^super mouseEnterDragging: evt].
	(self wantsDroppedMorph: evt hand firstSubmorph event: evt )
		ifTrue:[
			aMorph := self itemFromPoint: evt position.
			aMorph ifNotNil:[self potentialDropMorph: aMorph].
			evt hand newMouseFocus: self.
			"above is ugly but necessary for now"
		].
]

{ #category : #obsolete }
SimpleHierarchicalListMorph >> mouseEnterDragging: anEvent onItem: aMorph [ 
	self removeObsoleteEventHandlers.
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> mouseLeave: aMouseEvent [ 

	super mouseLeave: aMouseEvent.
	self hoveredMorph: nil.
	
	Preferences mouseOverForKeyboardFocus
		ifTrue: [aMouseEvent hand releaseKeyboardFocus: self].
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> mouseLeaveDragging: anEvent [

	self hoveredMorph: nil.
	(self dropEnabled and:[anEvent hand hasSubmorphs]) ifFalse: ["no d&d"
		^ super mouseLeaveDragging: anEvent].
	self resetPotentialDropMorph.
	anEvent hand releaseMouseFocus: self.
	"above is ugly but necessary for now"

]

{ #category : #obsolete }
SimpleHierarchicalListMorph >> mouseLeaveDragging: anEvent onItem: aMorph [ 
	self removeObsoleteEventHandlers.
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> mouseMove: evt [

	(self dropEnabled and:[evt hand hasSubmorphs]) 
		ifFalse:[^super mouseMove: evt].
	potentialDropMorph ifNotNil:[
		(potentialDropMorph containsPoint: (potentialDropMorph point: evt position from: self))
			ifTrue:[^self].
	].
	self mouseLeaveDragging: evt.
	(self containsPoint: evt position) 
		ifTrue:[self mouseEnterDragging: evt].
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> mouseUp: event [
 
	| clickedMorph highlightedMorph |
	clickedMorph := self itemFromPoint: event position.
	highlightedMorph := self valueOfProperty: #highlightedMorph ifAbsent: [].
	self removeProperty: #highlightedMorph.

	((model okToChange not
		or: [clickedMorph isNil])
		or: [clickedMorph ~~ highlightedMorph]) ifTrue: [
			highlightedMorph ifNotNil: [:m | m highlightForMouseDown: false].
			^ self].
	
	((autoDeselect isNil or: [autoDeselect]) and: [clickedMorph == selectedMorph]) 
		ifTrue: [self setSelectedMorph: nil]
		ifFalse: [self setSelectedMorph: clickedMorph].

	highlightedMorph highlightForMouseDown: false.	
	event hand newKeyboardFocus: self.
	Cursor normal show.
]

{ #category : #drawing }
SimpleHierarchicalListMorph >> notExpandedForm [

	^self class notExpandedForm
]

{ #category : #private }
SimpleHierarchicalListMorph >> noteRemovalOfAll: aCollection [

	scroller removeAllMorphsIn: aCollection.
	(aCollection includes: selectedMorph) ifTrue: [self setSelectedMorph: nil].
]

{ #category : #scrolling }
SimpleHierarchicalListMorph >> offsetToShow: aRectangle [
	"Focus rectangles are too wide and the view hence jumps to the right. Snap it back to 0 on the horizontal axis."
	
	^ 0 @ (super offsetToShow: aRectangle) y
]

{ #category : #initialization }
SimpleHierarchicalListMorph >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [

	self model: anObject.
	getListSelector := getListSel.
	getSelectionSelector := getSelectionSel.
	setSelectionSelector := setSelectionSel.
	getMenuSelector := getMenuSel.
	keystrokeActionSelector := keyActionSel.
	autoDeselect := true.
	self borderWidth: 1.
	self list: self getList.
]

{ #category : #'drag and drop' }
SimpleHierarchicalListMorph >> potentialDropMorph [
	^potentialDropMorph
]

{ #category : #'drag and drop' }
SimpleHierarchicalListMorph >> potentialDropMorph: aMorph [
	potentialDropMorph := aMorph.
	aMorph highlightForDrop
]

{ #category : #private }
SimpleHierarchicalListMorph >> preferredSubmorphWidth [

	^ 9999
]

{ #category : #obsolete }
SimpleHierarchicalListMorph >> removeObsoleteEventHandlers [
	scroller submorphs do:[:m|
		m eventHandler: nil; highlightForMouseDown: false; resetExtension].
]

{ #category : #'drag and drop' }
SimpleHierarchicalListMorph >> resetPotentialDropMorph [
	potentialDropMorph ifNotNil: [
		potentialDropMorph resetHighlightForDrop.
		potentialDropMorph := nil]

]

{ #category : #accessing }
SimpleHierarchicalListMorph >> roots [
	"Answer the receiver's roots"
	^ scroller submorphs
		select: [:each | each indentLevel isZero]
]

{ #category : #geometry }
SimpleHierarchicalListMorph >> scrollDeltaHeight [
	^ scroller hasSubmorphs
		ifTrue: [scroller firstSubmorph height]
		ifFalse: [super scrollDeltaHeight]
]

{ #category : #geometry }
SimpleHierarchicalListMorph >> scrollDeltaWidth [
"A guess -- assume that the width of a char is approx 1/2 the height of the font"
	^ self scrollDeltaHeight // 2



]

{ #category : #selection }
SimpleHierarchicalListMorph >> selectedMorph [
	^selectedMorph
]

{ #category : #selection }
SimpleHierarchicalListMorph >> selectedMorph: aMorph [

	self unhighlightSelection.
	selectedMorph := aMorph.
	self highlightSelection
]

{ #category : #selection }
SimpleHierarchicalListMorph >> selection: item [
	"Called from outside to request setting a new selection.
	Assumes scroller submorphs is exactly our list.
	Note: MAY NOT work right if list includes repeated items"

	| i |
	item ifNil: [^self selectionIndex: 0].
	i := scroller submorphs findFirst: [:m | m complexContents == item].
	i > 0 ifTrue: [^self selectionIndex: i].
	i := scroller submorphs findFirst: [:m | m withoutListWrapper = item withoutListWrapper].
	self selectionIndex: i
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> selectionColor [

	^ self valueOfProperty: #selectionColor ifAbsent: [Color blue]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> selectionColor: aColor [

	self setProperty: #selectionColor toValue: aColor.
	scroller submorphsDo: [:ea | ea selectionColor: aColor].
]

{ #category : #selection }
SimpleHierarchicalListMorph >> selectionIndex: idx [
	"Called internally to select the index-th item."
	| theMorph index |
	idx ifNil: [^ self].
	index := idx min: scroller submorphs size max: 0.
	(theMorph := index = 0 ifTrue: [nil] ifFalse: [scroller submorphs at: index])
		ifNotNil: [self scrollToShow: theMorph bounds].
	self selectedMorph: theMorph
]

{ #category : #selection }
SimpleHierarchicalListMorph >> selectionOneOf: aListOfItems [
	"Set the selection to the first item in the list which is represented by one of my submorphs"

	
	aListOfItems do: [ :item | | index |
		index := scroller submorphs findFirst: [:m | 
			m withoutListWrapper = item withoutListWrapper
		].
		index > 0 ifTrue: [^self selectionIndex: index].
	].
	self selectionIndex: 0.
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> selectionTextColor [

	^ self valueOfProperty: #selectionTextColor ifAbsent: [Color white]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> selectionTextColor: aColor [

	self setProperty: #selectionTextColor toValue: aColor.
	scroller submorphsDo: [:ea | ea selectionTextColor: aColor].
]

{ #category : #initialization }
SimpleHierarchicalListMorph >> setDefaultParameters [

	super setDefaultParameters.
	
	self
		font: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]);
		textColor: (self userInterfaceTheme textColor ifNil: [Color black]).
		
	self
		selectionColor: (self userInterfaceTheme selectionColor ifNil: [Color r: 0.72 g: 0.72 b: 0.9]);
		selectionTextColor: (self userInterfaceTheme selectionTextColor ifNil: [Color black]);
		filterColor: (self userInterfaceTheme filterColor ifNil: [Color yellow paler]);
		filterTextColor: (self userInterfaceTheme filterTextColor ifNil: [Color black]);
		lineColor: (self userInterfaceTheme lineColor ifNil: [Color veryLightGray]);
		hoverColor: ((self userInterfaceTheme hoverSelectionModifier ifNil: [ [:c | c darker alpha: 0.3] ]) value: self selectionColor);
		highlightTextColor: (self userInterfaceTheme highlightTextColor ifNil: [Color red]).
]

{ #category : #selection }
SimpleHierarchicalListMorph >> setSelectedMorph: aMorph [

	"Avoid unnecessary model callbacks."
	self selectedMorph == aMorph ifTrue: [^ self].

	model 
		perform: (setSelectionSelector ifNil: [^self]) 
		with: aMorph complexContents	"leave last wrapper in place"

 
]

{ #category : #'keyboard navigation' }
SimpleHierarchicalListMorph >> setSelectionIndex: idx [
	"Called internally to select the index-th item."
	| theMorph index max currentIndex |
	idx ifNil: [^ self].
	max := scroller submorphs size.
	currentIndex := self getSelectionIndex.
	
	index := idx min: max max: 0.
	theMorph := index = 0 ifTrue: [nil] ifFalse: [scroller submorphs at: index].

	"Skip invisible rows."
	[theMorph notNil and: [theMorph visible not]] whileTrue: [
		currentIndex < index
			ifTrue: [index := index + 1]
			ifFalse: [index := index - 1].		
		(index < 1 or: [index > max]) ifTrue: [^ self].
		theMorph := scroller submorphs at: index.
	].
	self setSelectedMorph: theMorph.
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> sortingSelector: s [

	sortingSelector := s
]

{ #category : #'event handling' }
SimpleHierarchicalListMorph >> specialKeyPressed: asciiValue [

	(self arrowKey: asciiValue)
		ifTrue: [^ true].
		
	asciiValue = 27 "escape"
		ifTrue: [
			self currentEvent shiftPressed
				ifTrue: [self currentWorld putUpWorldMenuFromEscapeKey]
				ifFalse: [self yellowButtonActivity: false].
			^ true].
	
	^ false
]

{ #category : #'drag and drop' }
SimpleHierarchicalListMorph >> startDrag: evt [ 
	
	| itemMorph |
	evt hand hasSubmorphs ifTrue: [^ self].
	self model okToChange ifFalse: [^ self].
	
	itemMorph := scroller submorphs
		detect: [:any | any highlightedForMouseDown]
		ifNone: [^ self].

	"Prepare visuals."
	itemMorph highlightForMouseDown: false.
	self setSelectedMorph: itemMorph.

	[ "Initiate drag."
		(self model dragPassengerFor: itemMorph inMorph: self) ifNotNil: [:passenger | | ddm |
			ddm := (self valueOfProperty: #dragTransferClass ifAbsent: [TransferMorph]) withPassenger: passenger from: self.
			ddm dragTransferType: (self model dragTransferTypeForMorph: self).
			ddm updateFromUserInputEvent: evt.
			self model dragStartedFor: itemMorph transferMorph: ddm.
			evt hand grabMorph: ddm].
	] ensure: [
		Cursor normal show.
		evt hand releaseMouseFocus: self].
]

{ #category : #obsolete }
SimpleHierarchicalListMorph >> startDrag: evt onItem: itemMorph [ 
	self removeObsoleteEventHandlers.
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> textColor [
	^ textColor ifNil: [Color black]
]

{ #category : #accessing }
SimpleHierarchicalListMorph >> textColor: aColor [
	textColor := aColor.
	scroller submorphsDo: [:ea | ea color: textColor].
]

{ #category : #'keyboard navigation' }
SimpleHierarchicalListMorph >> toggleExpandedState: aMorph [
	aMorph toggleExpandedState.
	self adjustSubmorphPositions.

]

{ #category : #events }
SimpleHierarchicalListMorph >> toggleExpandedState: aMorph event: event [
	| oldState |
	"self setSelectedMorph: aMorph."
	event yellowButtonPressed ifTrue: [
		oldState := aMorph isExpanded.
		scroller submorphs copy do: [ :each |
			(each canExpand and: [each isExpanded = oldState]) ifTrue: [
				each toggleExpandedState.
			].
		].
	] ifFalse: [
		aMorph toggleExpandedState.
	].
	self adjustSubmorphPositions.
	
]

{ #category : #drawing }
SimpleHierarchicalListMorph >> unhighlightSelection [
	selectedMorph ifNotNil: [selectedMorph unhighlight]
]

{ #category : #updating }
SimpleHierarchicalListMorph >> update: aSymbol [ 
	aSymbol == getSelectionSelector 
		ifTrue: 
			[self selection: self getCurrentSelectionItem.
			^self].
	aSymbol == getListSelector 
		ifTrue: 
			[self list: self getList.
			^self].
	((aSymbol isKindOf: Array) 
		and: [aSymbol notEmpty and: [aSymbol first == #openPath]]) 
			ifTrue: 
				[^(scroller submorphs at: 1 ifAbsent: [^self]) 
					openPath: aSymbol allButFirst]
]

{ #category : #'drag and drop' }
SimpleHierarchicalListMorph >> wantsDroppedMorph: aMorph event: anEvent [ 
	^ self model wantsDroppedMorph: aMorph event: anEvent inMorph: self
]

{ #category : #'private - caching' }
SimpleHierarchicalListMorph >> widthOfColumn: index [ 

	self columns ifNil: [^ nil].
	
	"Try columns cache."
	(self columnsCache at: index)
		ifNotNil: [:cachedWidth | ^ cachedWidth].
		
	^ (self columns at: index)
		ifNil: [nil]
		ifNotNil: [:widthOrSpec |
			"Fill columns cache."
			self columnsCache
				at: index
				put: (widthOrSpec isNumber
					ifTrue: [widthOrSpec]
					ifFalse: [widthOrSpec isBlock
						ifTrue: [widthOrSpec cull: self]
						ifFalse: [50 "fall back for bad spec"]])]
]
