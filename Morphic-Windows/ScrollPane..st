"
The scroller (a transform) of a scrollPane is driven by the scrollBar.  The scroll values vary from 0.0, meaning zero offset to 1.0 meaning sufficient offset such that the bottom of the scrollable material appears 3/4 of the way down the pane.  The total distance to achieve this range is called the totalScrollRange.

Basic clue about utilization of the ScrollPane class is given in:
	ScrollPane example1.
	ScrollPane example2.
"
Class {
	#name : #ScrollPane,
	#superclass : #MorphicModel,
	#instVars : [
		'scrollBar',
		'scroller',
		'retractableScrollBar',
		'scrollBarOnLeft',
		'getMenuSelector',
		'getMenuTitleSelector',
		'hasFocus',
		'hScrollBar',
		'hScrollBarPolicy',
		'vScrollBarPolicy',
		'scrollBarThickness'
	],
	#classVars : [
		'HorizontalScrollDeltaPerMouseWheelNotch',
		'UseRetractableScrollBars',
		'VerticalScrollDeltaPerMouseWheelNotch'
	],
	#category : #'Morphic-Windows'
}

{ #category : #examples }
ScrollPane class >> example1 [
	| window scrollPane pasteUpMorph |
	window := SystemWindow new.
	scrollPane := ScrollPane new.
	pasteUpMorph := PasteUpMorph new.
	pasteUpMorph extent: 1000@1000.
	scrollPane scroller addMorph: pasteUpMorph.
	window addMorph: scrollPane frame: (0@0 corner: 1@1).
	window openInWorld.
]

{ #category : #examples }
ScrollPane class >> example2 [
	| window scrollPane pasteUpMorph point textMorph |
	window := SystemWindow new.
	scrollPane := ScrollPane new.
	pasteUpMorph := PasteUpMorph new.
	pasteUpMorph extent: 1000@1000.
	scrollPane scroller addMorph: pasteUpMorph.
	window addMorph: scrollPane frame: (0@0 corner: 1@1).
	0 to: 1000 by: 100 do: 
		[:x | 0 to: 1000 by: 100 do:
			[:y |
				point :=  x@y.
				textMorph := TextMorph new contents: point asString.
				textMorph position: point.
				pasteUpMorph addMorph: textMorph
			]
		].
	window openInWorld.
]

{ #category : #preferences }
ScrollPane class >> horizontalScrollDeltaPerMouseWheelNotch [
	
	<preference: 'horizontal scroll increment per single mouse wheel'
		category: #scrolling
		description: 'How many horizontal scroll increments should be caused in response to a single mouse wheel notch.
Typically, the scroll panes increment are about 1 character width for list and text panes (see #scrollDeltaWidth).
The default setting is 3 so as to match the most widely used convention.'
		type: #Number>
	^ HorizontalScrollDeltaPerMouseWheelNotch ifNil: [3]
]

{ #category : #preferences }
ScrollPane class >> horizontalScrollDeltaPerMouseWheelNotch: anIntegerOrNil [
	
	HorizontalScrollDeltaPerMouseWheelNotch := anIntegerOrNil
]

{ #category : #'new-morph participation' }
ScrollPane class >> includeInNewMorphMenu [
	"OK to instantiate"
	^ true
]

{ #category : #defaults }
ScrollPane class >> scrollBarThickness [

	^ Preferences scrollBarsNarrow
		ifTrue: [10]
		ifFalse: [14]
]

{ #category : #preferences }
ScrollPane class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the pane''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the pane''s border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the pane.' }.
	}
]

{ #category : #preferences }
ScrollPane class >> useRetractableScrollBars [
	
	<preference: 'Use retractable scrollbars'
		category: #scrolling
		description: 'When enabled, scrollbars are hidden when scroll pane is not focused.'
		type: #Boolean>
	^ UseRetractableScrollBars ifNil: [false]
]

{ #category : #preferences }
ScrollPane class >> useRetractableScrollBars: aBoolean [
	
	UseRetractableScrollBars = aBoolean ifTrue: [^ self].
	UseRetractableScrollBars := aBoolean.
	ScrollPane allSubInstances do: [:pane | 
		pane retractable: aBoolean].
]

{ #category : #preferences }
ScrollPane class >> verticalScrollDeltaPerMouseWheelNotch [
	
	<preference: 'vertical scroll increment per single mouse wheel'
		category: #scrolling
		description: 'How many vertical scroll increments should be caused in response to a single mouse wheel notch.
Typically, the scroll panes increment are one line height for list and text panes (see #scrollDeltaHeight).
The default setting is 3 so as to match the most widely used convention.'
		type: #Number>
	^ VerticalScrollDeltaPerMouseWheelNotch ifNil: [3]
]

{ #category : #preferences }
ScrollPane class >> verticalScrollDeltaPerMouseWheelNotch: anIntegerOrNil [
	
	VerticalScrollDeltaPerMouseWheelNotch := anIntegerOrNil
]

{ #category : #menu }
ScrollPane >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	retractableScrollBar
		ifTrue: [aCustomMenu add: 'make scrollbar inboard' translated action: #retractableOrNot]
		ifFalse: [aCustomMenu add: 'make scrollbar retractable' translated action: #retractableOrNot].
	scrollBarOnLeft
		ifTrue: [aCustomMenu add: 'scroll bar on right' translated action: #leftOrRight]
		ifFalse: [aCustomMenu add: 'scroll bar on left' translated action: #leftOrRight]
]

{ #category : #scrolling }
ScrollPane >> adjustOffset [
	"Layout specific. If our scroller is large enough, avoid hiding contents due to bad offset."

	| sbox adjustedOffset |
	sbox := scroller submorphBoundsForShrinkWrap.
	adjustedOffset := (sbox width <= scroller width ifTrue: [0] ifFalse: [scroller offset x]) @
		(sbox height <= scroller height ifTrue: [0] ifFalse: [scroller offset y]).
	scroller offset: adjustedOffset.
]

{ #category : #accessing }
ScrollPane >> adoptPaneColor: paneColor [
	super adoptPaneColor: paneColor.
	
	"May not be in the hierarchy at the moment."
	scrollBar adoptPaneColor: paneColor.
	hScrollBar adoptPaneColor: paneColor.

	paneColor ifNotNil: [:pc | self borderColor: ((self userInterfaceTheme borderColorModifier ifNil: [ [:c | c adjustBrightness: -0.3] ]) value: pc)].
]

{ #category : #'accessing options' }
ScrollPane >> alwaysShowHScrollBar [

	self hScrollBarPolicy: #always.

]

{ #category : #'accessing options' }
ScrollPane >> alwaysShowScrollBars [	
	
	self 
		alwaysShowHScrollBar;
		alwaysShowVScrollBar.

]

{ #category : #'accessing options' }
ScrollPane >> alwaysShowVScrollBar [

	self vScrollBarPolicy: #always.

]

{ #category : #updating }
ScrollPane >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setDefaultParameters.
]

{ #category : #support }
ScrollPane >> canBeEncroached [
	"For support of the smartHorizontalSplitters preference."
	^ scrollBar isInWorld not
]

{ #category : #layout }
ScrollPane >> checkScrollBarPolicy: aSymbol [

	aSymbol == #never ifTrue: [^ self].
	aSymbol == #whenNeeded ifTrue: [^ self].
	aSymbol == #always ifTrue: [^ self].
	
	Error signal: 'Invalid value for scrollbar policy. Use #never, #whenNeeded, or #always.'.
]

{ #category : #'geometry testing' }
ScrollPane >> containsPoint: aPoint [

	(super containsPoint: aPoint) ifTrue: [^ true].
	
	"Also include v scrollbar when it is extended..."
	((retractableScrollBar and: [self vIsScrollbarShowing]) and:
		[scrollBar containsPoint: aPoint])
			ifTrue:[ ^true ].
		
	"Also include hScrollbar when it is extended..."
	((retractableScrollBar and: [self hIsScrollbarShowing]) and:
		[hScrollBar containsPoint: aPoint])
			ifTrue: [ ^true ].
	
	^ false

]

{ #category : #'objects from disk' }
ScrollPane >> convertToCurrentVersion: varDict refStream: smartRefStrm [ 
	scrollBarThickness
		ifNil: [scrollBarThickness := self class scrollBarThickness].
	hScrollBarPolicy
		ifNil: [hScrollBarPolicy := #whenNeeded].
	vScrollBarPolicy
		ifNil: [vScrollBarPolicy := #whenNeeded].
	hScrollBar
		ifNil: [(hScrollBar := ScrollBar on: self getValue: nil setValue: #hScrollBarValue:) 
			       menuSelector: #hScrollBarMenuButtonPressed:;
				 orientation: #horizontal;
				 extent: 1 @ 1].
	^ super convertToCurrentVersion: varDict refStream: smartRefStrm
]

{ #category : #initialization }
ScrollPane >> defaultExtent [
	^150@120

]

{ #category : #layout }
ScrollPane >> doLayoutIn: layoutBounds [
	"Manually layout my submorphs. Maybe we can find a proper layout policy in the future."

	| priorBounds |
	priorBounds := bounds.
	
	self updateLayout.
	super doLayoutIn: layoutBounds.

	"Do one additional run if required."
	(priorBounds ~= bounds or: [self hasProperty: #doLayoutAgainHere]) ifTrue: [
		self updateLayout.
		super doLayoutIn: layoutBounds.
		"self assert: (self hasProperty: #doLayoutAgainHere) not. --- Not working yet."].
]

{ #category : #drawing }
ScrollPane >> drawOn: aCanvas [

	self wantsRoundedCorners
		ifTrue: [aCanvas fillRoundRect: self bounds radius: self cornerRadius fillStyle: self fillStyle]
		ifFalse: [aCanvas fillRectangle: self bounds fillStyle: self fillStyle].
]

{ #category : #drawing }
ScrollPane >> drawOverlayOn: aCanvas [
	"Draw my border OVER my submorphs because the scrollbars overlap."
	
	self wantsRoundedCorners
		ifTrue: [aCanvas frameRoundRect: self bounds radius: self cornerRadius borderStyle: self borderStyle]
		ifFalse: [aCanvas frameRectangle: self bounds borderStyle: self borderStyle].
		
	super drawOverlayOn: aCanvas.
]

{ #category : #geometry }
ScrollPane >> extentToFit [
	"Resize scroll pane to exactly fit its contents."
	
	| offset |
	offset := 0@0.
	(retractableScrollBar not and: [self vScrollBarPolicy == #always])
		ifTrue: [offset := (self scrollBarThickness - self borderWidth) @ offset y].
	(retractableScrollBar not and: [self hScrollBarPolicy == #always])
		ifTrue: [offset := offset x @ (self scrollBarThickness - self borderWidth)].
		
	^ scroller submorphBounds extent + offset + (2* (self borderWidth @ self borderWidth))
]

{ #category : #'event filtering' }
ScrollPane >> filterEvent: aKeyboardEvent for: morphOrNil [
	"See #initialize. This filter should be installed as keyboard event filter during the capture phase."

	aKeyboardEvent isKeystroke
		ifFalse: [^ aKeyboardEvent].

	^ aKeyboardEvent
		wasIgnored: (self scrollByKeyboard: aKeyboardEvent);
		yourself
]

{ #category : #geometry }
ScrollPane >> fit [
	"Resize scroll pane to exactly fit its contents."
	
	self extent: self extentToFit.
]

{ #category : #accessing }
ScrollPane >> flatColoredScrollBarLook [
	"Currently only show the flat (not rounded) + colored-to-match-window scrollbar look when inboard."
	^ retractableScrollBar not or: [ScrollBar alwaysShowFlatScrollbarForAlternativeLook]

]

{ #category : #menu }
ScrollPane >> getMenu: shiftKeyState [
	"Answer the menu for this text view, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."
	| menu aMenu aTitle |
	getMenuSelector == nil ifTrue: [^ nil].
	menu := MenuMorph new defaultTarget: model.
	aTitle := getMenuTitleSelector ifNotNil: [model perform: getMenuTitleSelector].
	getMenuSelector numArgs = 1 ifTrue:
		[aMenu := model perform: getMenuSelector with: menu.
		aTitle ifNotNil:  [aMenu addTitle: aTitle].
		^ aMenu].
	getMenuSelector numArgs = 2 ifTrue:
		[aMenu := model perform: getMenuSelector with: menu with: shiftKeyState.
		aTitle ifNotNil:  [aMenu addTitle: aTitle].
		^ aMenu].
	^ self error: 'The getMenuSelector must be a 1- or 2-keyword symbol'
]

{ #category : #'geometry ranges' }
ScrollPane >> hExtraScrollRange [
	"Return the amount of extra blank space to include below the bottom of the scroll content."
	^ 0

]

{ #category : #'layout - visibility' }
ScrollPane >> hHideOrShowScrollBar [
	"Hide or show the scrollbar depending on if the pane is scrolled/scrollable."

	self hIsScrollbarNeeded
		ifTrue:[ self hShowScrollBar ]
		ifFalse: [ self hHideScrollBar ].

]

{ #category : #'layout - visibility' }
ScrollPane >> hHideScrollBar [

	self hIsScrollbarShowing ifFalse: [^self].
	self removeMorph: hScrollBar.
	retractableScrollBar ifFalse: [self setProperty: #doLayoutAgainHere toValue: true].
]

{ #category : #'geometry testing' }
ScrollPane >> hIsScrollable [
	"If the contents of the pane are too small to scroll, return false."
	
	^ self hLeftoverScrollRange > 0

]

{ #category : #'geometry testing' }
ScrollPane >> hIsScrollbarNeeded [
"Return whether the horz scrollbar is needed"

	"Don't do anything with the retractable scrollbar unless we have focus"
	retractableScrollBar & self hasFocus not ifTrue: [^false].
	
	"Don't show it if we were told not to."
	self hScrollBarPolicy == #never ifTrue: [^false].

	"Always show it if we were told to"
	self hScrollBarPolicy == #always ifTrue: [^true].

	^self hIsScrollable

]

{ #category : #'geometry testing' }
ScrollPane >> hIsScrollbarShowing [
	"Return true if a horz scroll bar is currently showing"

	^ hScrollBar owner notNil
]

{ #category : #'geometry testing' }
ScrollPane >> hIsScrolled [
	"If the scroller is not set to x = 0, then the pane has been h-scrolled."
	^scroller offset x > 0

]

{ #category : #'geometry ranges' }
ScrollPane >> hLeftoverScrollRange [
	"Return the entire scrolling range minus the currently viewed area."

	^ scroller hasSubmorphs
		ifFalse: [0]
		ifTrue: [self hTotalScrollRange - scroller width max: 0]

]

{ #category : #accessing }
ScrollPane >> hMargin [
"pixels of whitespace at to the left of the scroller when the hScrollBar offset is 0"
	^0

]

{ #category : #'layout - resizing' }
ScrollPane >> hResizeScrollBar [

	| topLeft h border offset |
	self hScrollBarPolicy == #never ifTrue: [^self].
	
	h := self scrollBarThickness.
	border := self borderWidth.
	offset := (scrollBarOnLeft and: [self vIsScrollbarShowing and: [retractableScrollBar not]])
		ifTrue: [h]
		ifFalse: [0].
	
	topLeft := retractableScrollBar
				ifTrue: [bounds bottomLeft + (offset @ border negated)]
				ifFalse: [bounds bottomLeft + (offset @ h negated)].

	hScrollBar bounds: (topLeft extent: self hScrollBarWidth@ h)
]

{ #category : #layout }
ScrollPane >> hResizing: aSymbol [
	"Pass #shrinkWrap property to scroller to make this scroll pane's layout work. See #doLayoutIn:."

	super hResizing: aSymbol.
	
	scroller hResizing: (aSymbol == #shrinkWrap
		ifTrue: [#shrinkWrap]
		ifFalse: [#spaceFill]).
]

{ #category : #accessing }
ScrollPane >> hScrollBar [
	^ hScrollBar
]

{ #category : #'scroll bar events' }
ScrollPane >> hScrollBarMenuButtonPressed: event [
	^ self scrollBarMenuButtonPressed: event

]

{ #category : #accessing }
ScrollPane >> hScrollBarPolicy [

	^ hScrollBarPolicy
]

{ #category : #accessing }
ScrollPane >> hScrollBarPolicy: aSymbol [
	"#always, #never, #whenNeeded"

	hScrollBarPolicy = aSymbol ifTrue: [^ self].
	self checkScrollBarPolicy: aSymbol.
	
	hScrollBarPolicy := aSymbol.
	self layoutChanged.
]

{ #category : #scrolling }
ScrollPane >> hScrollBarValue: scrollValue [

	scroller hasSubmorphs ifFalse: [^ self].
	scroller offset: (scrollValue max: 0) @ scroller offset y.
]

{ #category : #geometry }
ScrollPane >> hScrollBarWidth [
"Return the width of the horizontal scrollbar"


	| w |
	
	w := bounds width "- (2 * borderWidth)".
	
	(retractableScrollBar not and: [self vIsScrollbarNeeded])
		ifTrue: [w := w - self scrollBarThickness ].
		
	^w 

]

{ #category : #'layout - scrolling' }
ScrollPane >> hSetScrollDelta [
	"Set the ScrollBar deltas, value and interval, based on the current scroll pane size, offset and range."

	| delta |	
	delta := self scrollDeltaWidth.

	hScrollBar
			truncate: true;
			scrollDelta: delta 
			pageDelta: 10*delta;
			maximumValue: self hLeftoverScrollRange;
			interval: (self hTotalScrollRange = 0
				ifTrue: [1.0]
				ifFalse: [scroller width / self hTotalScrollRange]);
			setValue: scroller offset x.
]

{ #category : #'layout - visibility' }
ScrollPane >> hShowScrollBar [

	self hIsScrollbarShowing ifTrue: [^self].
	self hResizeScrollBar.
	self privateAddMorph: hScrollBar atIndex: 1.
	retractableScrollBar
		ifTrue: [self comeToFront]
		ifFalse: [self setProperty: #doLayoutAgainHere toValue: true].
]

{ #category : #'geometry ranges' }
ScrollPane >> hTotalScrollRange [
	"Return the entire scrolling range."
	^ self hUnadjustedScrollRange + self hExtraScrollRange + self hMargin

]

{ #category : #'geometry ranges' }
ScrollPane >> hUnadjustedScrollRange [
	"Return the width extent of the receiver's submorphs."

	^ scroller localSubmorphBounds width
]

{ #category : #'event handling' }
ScrollPane >> handlesKeyboard: evt [
	^ true
]

{ #category : #'event handling' }
ScrollPane >> handlesMouseDown: evt [
	^ true

]

{ #category : #'event handling' }
ScrollPane >> handlesMouseOver: evt [
	"Could just ^ true, but this ensures that scroll bars won't flop out
	if you mouse-over appendages such as connecting pins."
	self flag: #arNote. "I have no idea how the code below could've ever worked. If the receiver does not handle mouse over events then it should not receive any #mouseLeave if the mouse leaves the receiver for real. This is because 'evt cursorPoint' describes the *end* point of the movement and considering that the code would return false if the move ends outside the receiver the scroll bars should never pop back in again. Which is exactly what happens with the new event logic if you don't just ^true. I'm leaving the code in for reference - perhaps somebody can make sense from it; I sure cannot."
	^true
"
	| cp |
	cp := evt cursorPoint.
	(bounds containsPoint: cp)
		ifTrue: [^ true]			
		ifFalse: [self submorphsDo:
					[:m | (m containsPoint: cp) ifTrue:
							[m == scrollBar
								ifTrue: [^ true]
								ifFalse: [^ false]]].
				^ false]
"
]

{ #category : #'event handling' }
ScrollPane >> handlesMouseWheel: evt [
	^ true
]

{ #category : #accessing }
ScrollPane >> hasFocus [
	"hasFocus is currently set by mouse enter/leave events.
	This inst var should probably be moved up to a higher superclass."

	^ hasFocus ifNil: [false]
]

{ #category : #'accessing options' }
ScrollPane >> hideHScrollBarIndefinitely [
	"Get rid of scroll bar for short panes that don't want it shown."

	self hScrollBarPolicy: #never.
	self hHideOrShowScrollBar.

]

{ #category : #'layout - visibility' }
ScrollPane >> hideOrShowScrollBars [

	self removeProperty: #doLayoutAgainHere. "Detect change."
	
	"There is the one edge case where no scroll bar would be needed if both scroll bars would just disappear."
	(((((self vScrollBarPolicy = #whenNeeded and: [self hScrollBarPolicy = #whenNeeded])
		and: [self retractableScrollBar not])
		and: [self vIsScrollbarShowing and: [self hIsScrollbarShowing]])
		and: [self hLeftoverScrollRange <= self vScrollBar width])
		and: [self vLeftoverScrollRange <= self hScrollBar height])
			ifTrue: [^ self vHideScrollBar; hHideScrollBar].

	self 
		vHideOrShowScrollBar; 
		hHideOrShowScrollBar.
]

{ #category : #'layout - visibility' }
ScrollPane >> hideScrollBars [
	self
		vHideScrollBar;
		hHideScrollBar

]

{ #category : #'accessing options' }
ScrollPane >> hideScrollBarsIndefinitely [

	self
		hideVScrollBarIndefinitely;
		hideHScrollBarIndefinitely.
]

{ #category : #'accessing options' }
ScrollPane >> hideVScrollBarIndefinitely [
	"Get rid of scroll bar for short panes that don't want it shown."

	self vScrollBarPolicy: #never.
	self vHideOrShowScrollBar.

]

{ #category : #initialization }
ScrollPane >> initialize [
	
	"initialize the state of the receiver"
	super initialize.
	""
	self initializePreferences.
	hasFocus := false.
	self initializeScrollBars.
	""
	
	self extent: self defaultExtent.
	self updateMinimumExtent.
	
	self setDefaultParameters.
	self addKeyboardCaptureFilter: self.
]

{ #category : #initialization }
ScrollPane >> initializePreferences [
	"initialize the receiver's Preferences"
	
	retractableScrollBar := self class useRetractableScrollBars.
	scrollBarOnLeft := (Preferences valueOfFlag: #scrollBarsOnRight) not.
	scrollBarThickness := self class scrollBarThickness.
	
	Preferences alwaysShowVScrollbar
		ifTrue: [ self vScrollBarPolicy: #always ]
		ifFalse: [ self vScrollBarPolicy: #whenNeeded ].
		
	Preferences alwaysHideHScrollbar
		ifTrue:[ self hScrollBarPolicy: #never ]
		ifFalse: [ Preferences alwaysShowHScrollbar
			ifTrue: [ self hScrollBarPolicy: #always ]
			ifFalse: [ self hScrollBarPolicy: #whenNeeded ]].
]

{ #category : #initialization }
ScrollPane >> initializeScrollBars [
	"Initialize vertical and horizontal scroll bars."

	(scrollBar := ScrollBar on: self getValue: nil setValue: #vScrollBarValue:)
			menuSelector: #vScrollBarMenuButtonPressed:;
			orientation: #vertical;
			extent: 1@1.
	(hScrollBar := ScrollBar on: self getValue: nil setValue: #hScrollBarValue:)
			menuSelector: #hScrollBarMenuButtonPressed:;
			orientation: #horizontal;
			extent: 1@1.

	""
	scroller := TransformMorph new
		color: Color transparent;
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	scroller offset: 0 @ 0.
	self addMorph: scroller.
	""
	retractableScrollBar ifFalse: 
			[self 
				addMorph: scrollBar;
				addMorph: hScrollBar].
	self updateMinimumExtent.
]

{ #category : #geometry }
ScrollPane >> innerBounds [

	| inner bottomOffset leftOffset rightOffset |
	(retractableScrollBar or: [self vIsScrollbarShowing not])
		ifTrue: [leftOffset := rightOffset := 0]
		ifFalse: [
			scrollBarOnLeft
				ifTrue: [
					leftOffset := self scrollBarThickness - self borderWidth.
					rightOffset := 0.]
				ifFalse: [
					leftOffset := 0.
					rightOffset := self scrollBarThickness - self borderWidth]].
			
	(retractableScrollBar or: [self hIsScrollbarShowing not])
		ifTrue: [bottomOffset := 0]
		ifFalse: [bottomOffset := self scrollBarThickness - self borderWidth].
	
	inner := super innerBounds.
	^ (inner left + leftOffset) @ (inner top "+ topOffset")
		corner: (inner right - rightOffset) @ (inner bottom - bottomOffset)
]

{ #category : #accessing }
ScrollPane >> insetColor [

	^ self containingWindow
		ifNil: [super insetColor]
		ifNotNil: [:window | window colorForInsets]
]

{ #category : #'geometry testing' }
ScrollPane >> isAnyScrollbarShowing [

	^ self hIsScrollbarShowing or: [self vIsScrollbarShowing]

]

{ #category : #accessing }
ScrollPane >> isAutoFit [
	"Does this scroll pane modifies the extent of its scrollable content when it resizes itself to avoid, for example, a horizontal or vertical scrollbar?"

	^ false
]

{ #category : #support }
ScrollPane >> isScrolledFromTop [
	"Have the contents of the pane been scrolled, so that the top of the contents are not visible?"
	^ self vIsScrolled

]

{ #category : #'event handling' }
ScrollPane >> keyStroke: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"

	scroller submorphs last keyStroke: evt
]

{ #category : #menu }
ScrollPane >> leftOrRight [  "Change scroll bar location"
	scrollBarOnLeft := scrollBarOnLeft not.
	self extent: self extent
]

{ #category : #menu }
ScrollPane >> menuTitleSelector: aSelector [
	getMenuTitleSelector := aSelector
]

{ #category : #layout }
ScrollPane >> minScrollbarHeight [
	"Answer the minimum extent occupied by the receiver..
	It is assumed the if the receiver is sized to its minimum both scrollbars will be used (and visible) unless they have been turned off explicitly.
	This makes the behaviour also more predictable."
	
	^ (self vScrollBarPolicy == #never 
		ifTrue: [0]
		ifFalse: [scrollBar minHeight])
			+ (((self hScrollBarPolicy == #never or: [retractableScrollBar]) or: [self isAutoFit])
				ifTrue: [0]
				ifFalse: [self scrollBarThickness])
]

{ #category : #layout }
ScrollPane >> minScrollbarWidth [
	"Answer the minimum extent occupied by the receiver..
	It is assumed the if the receiver is sized to its minimum both scrollbars will be used (and visible) unless they have been turned off explicitly.
	This makes the behaviour also more predictable."
	
	^ ((self hScrollBarPolicy == #never or: [self isAutoFit])
		ifTrue: [0]
		ifFalse: [hScrollBar minWidth])
			+ ((retractableScrollBar or: [self vScrollBarPolicy == #never])
				ifTrue: [0]
				ifFalse: [self scrollBarThickness])
]

{ #category : #'event handling' }
ScrollPane >> mouseDown: evt [
	evt yellowButtonPressed  "First check for option (menu) click"
		ifTrue: [^ self yellowButtonActivity: evt shiftPressed].
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseDown: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #'event handling' }
ScrollPane >> mouseEnter: event [
	hasFocus := true.
	owner isSystemWindow ifTrue: [owner paneTransition: event].
	retractableScrollBar ifTrue: [self hideOrShowScrollBars].
]

{ #category : #'event handling' }
ScrollPane >> mouseLeave: event [
	hasFocus := false.
	retractableScrollBar ifTrue: [self hideScrollBars].
	owner isSystemWindow ifTrue: [owner paneTransition: event].
]

{ #category : #'event handling' }
ScrollPane >> mouseMove: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)."
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseMove: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #'event handling' }
ScrollPane >> mouseUp: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseUp: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #'event handling' }
ScrollPane >> mouseWheel: evt [

	evt isWheelUp ifTrue: [scrollBar scrollUp: (evt verticalScrollDelta: self class verticalScrollDeltaPerMouseWheelNotch)].
	evt isWheelDown ifTrue: [scrollBar scrollDown: (evt verticalScrollDelta: self class verticalScrollDeltaPerMouseWheelNotch)].
	evt isWheelLeft ifTrue: [hScrollBar scrollUp: (evt horizontalScrollDelta: self class verticalScrollDeltaPerMouseWheelNotch)].
	evt isWheelRight ifTrue: [hScrollBar scrollDown: (evt horizontalScrollDelta: self class verticalScrollDeltaPerMouseWheelNotch)].
]

{ #category : #accessing }
ScrollPane >> numSelectionsInView [
	"Answer the scroller's height based on the average number of submorphs."
	
	^scroller numberOfItemsPotentiallyInView
]

{ #category : #scrolling }
ScrollPane >> offsetToShow: aRectangle [
	"Calculate the offset necessary to show the rectangle."
	
	| offset scrollRange target |
	self fullBounds. "We need updated bounds."
	offset := scroller offset.
	scrollRange := self hTotalScrollRange @ self vTotalScrollRange.
	
	"Normalize the incoming rectangle."
	target := 
			(scroller width < aRectangle width
				ifTrue: [offset x < aRectangle left "Coming from left?"
					ifTrue: [aRectangle right - scroller width]
					ifFalse: [aRectangle left]]
				ifFalse: [aRectangle left])
		@
			(scroller height < aRectangle height
				ifTrue: [offset y < aRectangle top "Coming from top?"
					ifTrue: [aRectangle bottom - scroller height]
					ifFalse: [aRectangle top]]
				ifFalse: [aRectangle top])
		corner: 
			(scroller width < aRectangle width
				ifTrue: [offset x + scroller width > aRectangle right "Coming from right?"
					ifTrue: [aRectangle left + scroller width]
					ifFalse: [aRectangle right]]
				ifFalse: [aRectangle right])
		@
			(scroller height < aRectangle height
				ifTrue: [offset y + scroller height > aRectangle bottom "Coming from bottom?"
					ifTrue: [aRectangle top + scroller height]
					ifFalse: [aRectangle bottom]]
				ifFalse: [aRectangle bottom]).

	"Vertical Scrolling"
	target top < offset y
		ifTrue: [offset := offset x @ target top].	
	target bottom > (offset y + scroller height)
		ifTrue: [offset := offset x @ (target bottom - scroller height)].
	
	"Horizontal Scrolling"
	target left < offset x
		ifTrue: [offset := target left @ offset y].
	target right > (offset x + scroller width)
		ifTrue: [offset := (target right - scroller width) @ offset y].

	^ (offset min: scrollRange - scroller extent) max: 0@0
]

{ #category : #accessing }
ScrollPane >> raisedColor [

	^ self containingWindow
		ifNil: [super raisedColor]
		ifNotNil: [:window | window raisedColor]
]

{ #category : #geometry }
ScrollPane >> resetExtent [
	"Reset the extent. (may be overridden by subclasses which need to do more than this)"
	
	self flag: #deprecate. "mt: Remove all uses in Etoys."
	self resizeScroller
]

{ #category : #'layout - resizing' }
ScrollPane >> resizeScrollBars [
	self vResizeScrollBar; hResizeScrollBar

]

{ #category : #'layout - resizing' }
ScrollPane >> resizeScroller [

	scroller
		bounds: self layoutBounds;
		fullBounds. "To make #shrinkWrap work."
]

{ #category : #'accessing retractable' }
ScrollPane >> retractable: aBoolean [
	retractableScrollBar == aBoolean ifFalse: [self retractableOrNot "toggles it"]
]

{ #category : #'accessing retractable' }
ScrollPane >> retractableOrNot [
	"Change scroll bar operation"

	retractableScrollBar := retractableScrollBar not.
	retractableScrollBar
		ifTrue: [
			self removeMorph: scrollBar; removeMorph: hScrollBar]
		ifFalse: [(submorphs includes: scrollBar) 
					ifFalse: 
						[self privateAddMorph: scrollBar atIndex: 1.
						self privateAddMorph: hScrollBar atIndex: 1]].
	self updateMinimumExtent.
]

{ #category : #'accessing retractable' }
ScrollPane >> retractableScrollBar [
	^ retractableScrollBar
]

{ #category : #support }
ScrollPane >> scrollBarFills: aRectangle [
	"Return true if a flop-out scrollbar fills the rectangle"

	retractableScrollBar ifFalse:[^false].
	
	((submorphs includes: scrollBar) and: [scrollBar bounds containsRect: aRectangle])
				ifTrue:[ ^true ].
	^((submorphs includes: hScrollBar) and: [hScrollBar bounds containsRect: aRectangle])

]

{ #category : #'scroll bar events' }
ScrollPane >> scrollBarMenuButtonPressed: event [
	^ self yellowButtonActivity: event shiftPressed
]

{ #category : #accessing }
ScrollPane >> scrollBarOnLeft [
	^ scrollBarOnLeft
]

{ #category : #accessing }
ScrollPane >> scrollBarOnLeft: aBoolean [

	scrollBarOnLeft := aBoolean.
	self layoutChanged.
]

{ #category : #accessing }
ScrollPane >> scrollBarThickness [
	"Includes border"
	
	^ scrollBarThickness
]

{ #category : #accessing }
ScrollPane >> scrollBarThickness: anInteger [
	
	scrollBarThickness := anInteger.
	
	self updateMinimumExtent.
	self layoutChanged.
]

{ #category : #scrolling }
ScrollPane >> scrollBy: delta [
	"Move the contents in the direction delta."

	self flag: #negated. "mt: Who uses this and why is does the expected behavor negate the delta?"
	self vScrollBar scrollBy: delta y negated.
	self hScrollBar scrollBy: delta x negated.
]

{ #category : #'event handling' }
ScrollPane >> scrollByKeyboard: event [ 
	"If event is ctrl+up/down then scroll and answer true. Backwards compatibility."
	
	(event controlKeyPressed or:[event commandKeyPressed "??? key decode table in event sensor does not change CTRL+up/down !!!"]) ifFalse: [^ false].
	event keyCharacter = Character arrowUp
		ifTrue: 
			[scrollBar scrollUp: 3.
			^ true].
	event keyCharacter = Character arrowDown
		ifTrue: 
			[scrollBar scrollDown: 3.
			^ true].
	"event keyCharacter = Character arrowRight
		ifTrue: 
			[hScrollBar scrollDown: 3.
			^ true].
	event keyCharacter = Character arrowLeft
		ifTrue: 
			[hScrollBar scrollUp: 3.
			^ true]."
	^ false
]

{ #category : #geometry }
ScrollPane >> scrollDeltaHeight [
	"Return the increment in pixels which this pane should be scrolled (normally a subclass responsibility)."
	^ 10

]

{ #category : #geometry }
ScrollPane >> scrollDeltaWidth [
	"Return the increment in pixels which this pane should be scrolled (normally a subclass responsibility)."
	
	^10

]

{ #category : #scrolling }
ScrollPane >> scrollToBottom [

	self vScrollBar scrollToMaximum..
]

{ #category : #scrolling }
ScrollPane >> scrollToLeft [

	self hScrollBar scrollToMinimum..
]

{ #category : #scrolling }
ScrollPane >> scrollToRight [

	self hScrollBar scrollToMaximum.
]

{ #category : #scrolling }
ScrollPane >> scrollToShow: aRectangle [

	| newOffset |
	newOffset := self offsetToShow: aRectangle.
	self hScrollBar setValue: newOffset x.
	self vScrollBar setValue: newOffset y.
]

{ #category : #scrolling }
ScrollPane >> scrollToTop [

	self vScrollBar scrollToMinimum.
]

{ #category : #accessing }
ScrollPane >> scroller [
	^ scroller
]

{ #category : #accessing }
ScrollPane >> scroller: aTransformMorph [
	scroller ifNotNil:[scroller delete].
	scroller := aTransformMorph.
	self addMorph: scroller.
]

{ #category : #initialization }
ScrollPane >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: (self userInterfaceTheme color ifNil: [Color white]);
		borderStyle: (self userInterfaceTheme borderStyle ifNil: [BorderStyle simple]) copy;
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color gray: 0.6]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]).
]

{ #category : #'layout - scrolling' }
ScrollPane >> setScrollDeltas [
	"Set the ScrollBar deltas, value and interval, based on the current scroll pane size, offset and range."

	scroller ifNil: [^ self].
	
	self hideOrShowScrollBars.
	self vSetScrollDelta.
	self hSetScrollDelta.
]

{ #category : #'scroll bar events' }
ScrollPane >> shiftedTextPaneMenuRequest [
	"The more... button was hit from the text-pane menu"

	^ self yellowButtonActivity: true
]

{ #category : #'scroll bar events' }
ScrollPane >> shiftedYellowButtonActivity [
	^ self yellowButtonActivity: true
]

{ #category : #'accessing options' }
ScrollPane >> showHScrollBarOnlyWhenNeeded [

	self hScrollBarPolicy: #whenNeeded.
	self hHideOrShowScrollBar.

]

{ #category : #'layout - visibility' }
ScrollPane >> showScrollBars [
	self  vShowScrollBar; hShowScrollBar

]

{ #category : #'accessing options' }
ScrollPane >> showScrollBarsOnlyWhenNeeded [

	self
		showHScrollBarOnlyWhenNeeded;
		showVScrollBarOnlyWhenNeeded.

]

{ #category : #'accessing options' }
ScrollPane >> showVScrollBarOnlyWhenNeeded [
	"Get rid of scroll bar for short panes that don't want it shown."

	self vScrollBarPolicy: #whenNeeded.
	self vHideOrShowScrollBar.

]

{ #category : #layout }
ScrollPane >> submorphBoundsForShrinkWrap [
	"No need to consider scrollbars because those are placed outside the #innerBounds like a border. See #resizeScroller."
	
	^ scroller bounds
]

{ #category : #'scroll bar events' }
ScrollPane >> unshiftedYellowButtonActivity [
	^ self yellowButtonActivity: false
]

{ #category : #layout }
ScrollPane >> updateLayout [
	"Manually layout my submorphs. Maybe we can find a proper layout policy in the future."
	
	self scroller hasSubmorphs ifTrue: [
		self scroller firstSubmorph changesHeightForWidth
			ifTrue: [self vHideScrollBar; resizeScroller; vHideOrShowScrollBar; resizeScroller]
			ifFalse: [self scroller firstSubmorph changesWidthForHeight
				ifTrue: [self hHideScrollBar; resizeScroller; hHideOrShowScrollBar; resizeScroller]
				ifFalse: [self resizeScroller]]].
	
	self
		resizeScrollBars;
		adjustOffset;
		setScrollDeltas.

]

{ #category : #layout }
ScrollPane >> updateMinimumExtent [
	"This grows only. For shrinking scroll bars, this might have to be changed."
	
	self minimumWidth: (self minimumWidth max: self minScrollbarWidth).
	self minimumHeight: (self minimumHeight max: self minScrollbarHeight).
]

{ #category : #'geometry ranges' }
ScrollPane >> vExtraScrollRange [
	"Return the amount of extra blank space to include below the bottom of the scroll content."
	^ 0

]

{ #category : #'layout - visibility' }
ScrollPane >> vHideOrShowScrollBar [

	self vIsScrollbarNeeded
		ifTrue:[ self vShowScrollBar ]
		ifFalse:[ self vHideScrollBar ].

]

{ #category : #'layout - visibility' }
ScrollPane >> vHideScrollBar [

	self vIsScrollbarShowing ifFalse: [^self].
	self removeMorph: scrollBar.
	retractableScrollBar ifFalse: [self setProperty: #doLayoutAgainHere toValue: true].
]

{ #category : #'geometry testing' }
ScrollPane >> vIsScrollable [
	"Return whether the verticle scrollbar is scrollable. If the contents of the pane are too small to scroll, return false."
	
	^ self vLeftoverScrollRange > 0
]

{ #category : #'geometry testing' }
ScrollPane >> vIsScrollbarNeeded [
"Return whether the verticle scrollbar is needed"

	"Don't do anything with the retractable scrollbar unless we have focus"
	retractableScrollBar & self hasFocus not ifTrue: [^false].
	
	"Don't show it if we were told not to."
	self vScrollBarPolicy == #never ifTrue: [^false].

	"Always show it if we were told to"
	self vScrollBarPolicy == #always ifTrue: [^true].
	
	^self vIsScrollable

]

{ #category : #'geometry testing' }
ScrollPane >> vIsScrollbarShowing [
	"Return true if a retractable scroll bar is currently showing"

	^ scrollBar owner notNil

]

{ #category : #'geometry testing' }
ScrollPane >> vIsScrolled [
	"If the scroller is not set to y = 0, then the pane has been scrolled."
	^scroller offset y > 0

]

{ #category : #'geometry ranges' }
ScrollPane >> vLeftoverScrollRange [
	"Return the entire scrolling range minus the currently viewed area."

	^ scroller hasSubmorphs
		ifFalse: [0]
		ifTrue: [self vTotalScrollRange - scroller height max: 0]

]

{ #category : #'layout - resizing' }
ScrollPane >> vResizeScrollBar [

	| w topLeft border |
	self vScrollBarPolicy == #never ifTrue: [^self].
	
	w := self scrollBarThickness.
	border := self borderWidth.
	topLeft := scrollBarOnLeft 
		ifTrue: [retractableScrollBar 
			ifTrue: [bounds topLeft - ((w - border) @ 0)]
			ifFalse: [bounds topLeft]]
		ifFalse: [retractableScrollBar 
			ifTrue: [bounds topRight - (border @ 0)]
			ifFalse: [bounds topRight - (w @ 0)]].
			
	scrollBar bounds: (topLeft extent: w @ self vScrollBarHeight)
	

]

{ #category : #layout }
ScrollPane >> vResizing: aSymbol [
	"Pass #shrinkWrap property to scroller to make this scroll pane's layout work. See #doLayoutIn:."

	super vResizing: aSymbol.
	
	scroller vResizing: (aSymbol == #shrinkWrap
		ifTrue: [#shrinkWrap]
		ifFalse: [#spaceFill]).
]

{ #category : #accessing }
ScrollPane >> vScrollBar [
	^ scrollBar
]

{ #category : #geometry }
ScrollPane >> vScrollBarHeight [
	| h |

	h := bounds height "- (2 * borderWidth)".
	(retractableScrollBar not and: [self hIsScrollbarNeeded]) 
		ifTrue:[ h := h - self scrollBarThickness. ].
	
	^h

]

{ #category : #'scroll bar events' }
ScrollPane >> vScrollBarMenuButtonPressed: event [
	^ self scrollBarMenuButtonPressed: event

]

{ #category : #accessing }
ScrollPane >> vScrollBarPolicy [

	^ vScrollBarPolicy
]

{ #category : #accessing }
ScrollPane >> vScrollBarPolicy: aSymbol [
	"#always, #never, #whenNeeded"

	vScrollBarPolicy = aSymbol ifTrue: [^ self].
	self checkScrollBarPolicy: aSymbol.
	
	vScrollBarPolicy := aSymbol.
	self layoutChanged.
]

{ #category : #scrolling }
ScrollPane >> vScrollBarValue: scrollValue [

	scroller hasSubmorphs ifFalse: [^ self].
	scroller offset: scroller offset x @ (scrollValue max: 0).
]

{ #category : #'layout - scrolling' }
ScrollPane >> vSetScrollDelta [
	"Set the ScrollBar deltas, value and interval, based on the current scroll pane size, offset and range."

	| delta |	
	delta := self scrollDeltaHeight.

	scrollBar
			truncate: true;
			scrollDelta: delta 
			pageDelta: 10*delta;
			maximumValue: self vLeftoverScrollRange;
			interval: (self vTotalScrollRange = 0
				ifTrue: [1.0]
				ifFalse: [scroller height / self vTotalScrollRange]);
			setValue: scroller offset y.
]

{ #category : #'layout - visibility' }
ScrollPane >> vShowScrollBar [

	self vIsScrollbarShowing ifTrue: [^ self].
	self vResizeScrollBar.
	self privateAddMorph: scrollBar atIndex: 1.
	retractableScrollBar
		ifTrue: [self comeToFront]
		ifFalse:[self setProperty: #doLayoutAgainHere toValue: true].
]

{ #category : #'geometry ranges' }
ScrollPane >> vTotalScrollRange [
	"Return the entire scrolling range."
	^ self vUnadjustedScrollRange + self vExtraScrollRange

]

{ #category : #'geometry ranges' }
ScrollPane >> vUnadjustedScrollRange [
	"Return the height extent of the receiver's submorphs."

	^ scroller localSubmorphBounds height
]

{ #category : #'event handling' }
ScrollPane >> wantsKeyboardFocus [

	^ true
]

{ #category : #accessing }
ScrollPane >> wantsSlot [
	"For now do it the old way, until we sort this out"
	^ true
]

{ #category : #menu }
ScrollPane >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ getMenuSelector notNil
]

{ #category : #'scroll bar events' }
ScrollPane >> yellowButtonActivity: shiftKeyState [
	| menu |
	(menu := self getMenu: shiftKeyState) ifNotNil:
		[menu setInvokingView: self.
		menu popUpEvent: self activeHand lastEvent in: self world]
]
