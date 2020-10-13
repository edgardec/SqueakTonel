"
TwoWayScrollPane is now obsolete.  You should be able to use ScrollPane to do both vertical and horizontal scrolling.

As an example, see Morph>>inATwoWayScrollPane and change the first line to create a ScrollPane instead of a TwoWayScrollPane.  It will still work.

(EllipseMorph new extent: 200@150) inATwoWayScrollPane openInWorld

Note that user preferences for ScrollPane may be geared toward text scrolling, so that the horizontal scrollbar may be hidden when not needed, while the vertical scrollbar is always shown.  Use ScrollPane>>alwaysShowHScrollbar: or its variants to adjust this if you want the vertical & horizontal scrollbars to be shown consistently.

"
Class {
	#name : #TwoWayScrollPane,
	#superclass : #MorphicModel,
	#instVars : [
		'getMenuSelector',
		'getMenuTitleSelector',
		'xScrollBar',
		'yScrollBar',
		'scroller'
	],
	#category : #'MorphicExtras-Obsolete'
}

{ #category : #'new-morph participation' }
TwoWayScrollPane class >> includeInNewMorphMenu [
	"OK to instantiate"
	^ true
]

{ #category : #accessing }
TwoWayScrollPane >> colorForInsets [
	"My submorphs use the surrounding color"
	owner notNil and:
		[ owner color isColor ifTrue: [ ^ owner color ] ].
	^ Color white
]

{ #category : #'geometry testing' }
TwoWayScrollPane >> containsPoint: aPoint [
	(super containsPoint: aPoint) ifTrue: [^ true].
	"Also include scrollbar when it is extended..."
	"used to handle retractable scrolbar"
	^ false
]

{ #category : #initialization }
TwoWayScrollPane >> createScrollBarNamed: aString [ 
"creates a scroll bar named as aString"
	| result |
	result := ScrollBar new model: self slotName: aString.
	result borderStyle: (BorderStyle inset width: 2).
	^ result
]

{ #category : #initialization }
TwoWayScrollPane >> createScroller [
"create a scroller"
	| result |
	result := TransformMorph new color: Color transparent.
	result offset: 0 @ 0.
	^ result
]

{ #category : #initialization }
TwoWayScrollPane >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
TwoWayScrollPane >> defaultBorderStyle [
	^ BorderStyle inset
]

{ #category : #layout }
TwoWayScrollPane >> doLayoutIn: layoutBounds [
	"layout has changed. update scroll deltas or whatever else"

	(owner notNil and: [owner hasProperty: #autoFitContents])
		ifTrue: [self fitContents].
	super doLayoutIn: layoutBounds.
]

{ #category : #geometry }
TwoWayScrollPane >> extent: newExtent [
	bounds extent = newExtent ifTrue: [^ self].
	super extent: (newExtent max: 36@32).
	self resizeScrollBar; resizeScroller; setScrollDeltas.

]

{ #category : #layout }
TwoWayScrollPane >> fitContents [
	"Adjust my size to fit my contents reasonably snugly"

	self extent: scroller submorphBounds extent
				+ (yScrollBar width @ xScrollBar height)
				+ (self borderWidth*2)
				 
]

{ #category : #menu }
TwoWayScrollPane >> getMenu: shiftKeyState [ 
	"Answer the menu for this text view, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."

	| menu aMenu aTitle |
	getMenuSelector isNil ifTrue: [^nil].
	menu := MenuMorph new defaultTarget: model.
	aTitle := getMenuTitleSelector 
				ifNotNil: [model perform: getMenuTitleSelector].
	getMenuSelector numArgs = 1 
		ifTrue: 
			[aMenu := model perform: getMenuSelector with: menu.
			aTitle ifNotNil: [aMenu addTitle: aTitle].
			^aMenu].
	getMenuSelector numArgs = 2 
		ifTrue: 
			[aMenu := model 
						perform: getMenuSelector
						with: menu
						with: shiftKeyState.
			aTitle ifNotNil: [aMenu addTitle: aTitle].
			^aMenu].
	^self error: 'The getMenuSelector must be a 1- or 2-keyword symbol'
]

{ #category : #'event handling' }
TwoWayScrollPane >> handlesMouseDown: evt [
	^ true
]

{ #category : #'event handling' }
TwoWayScrollPane >> handlesMouseOver: evt [
	^ true
]

{ #category : #'retractable scroll bar' }
TwoWayScrollPane >> hideOrShowScrollBar [

	^self		"we don't support retractable at the moment"
]

{ #category : #'retractable scroll bar' }
TwoWayScrollPane >> hideOrShowScrollBar: scrollBar forRange: range [

	(self hasProperty: #hideUnneededScrollbars) ifFalse: [^ self].
	(submorphs includes: scrollBar)
		ifTrue: [range <= 0 ifTrue: [scrollBar model: nil; delete]]
		ifFalse: [range > 0 ifTrue: [scrollBar model: self.  self resizeScrollBar; addMorph: scrollBar]]

]

{ #category : #initialization }
TwoWayScrollPane >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self addMorph: (yScrollBar := self createScrollBarNamed: 'yScrollBar');
		 addMorph: (xScrollBar := self createScrollBarNamed: 'xScrollBar');
		 addMorph: (scroller := self createScroller).
	""
	self extent: 150 @ 120
]

{ #category : #'event handling' }
TwoWayScrollPane >> keyStroke: evt [
	"If pane is not full, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"

	scroller submorphs last keyStroke: evt
]

{ #category : #menu }
TwoWayScrollPane >> leftOrRight [  "Change scroll bar location"

	"used to handle left vs right scrollbar"
]

{ #category : #geometry }
TwoWayScrollPane >> leftoverScrollRange [
	"Return the entire scrolling range minus the currently viewed area."
	^ self totalScrollRange - (self innerBounds extent * 3 // 4) max: 0@0

]

{ #category : #menu }
TwoWayScrollPane >> menuSelector: aSelector [
	getMenuSelector := aSelector
]

{ #category : #menu }
TwoWayScrollPane >> menuTitleSelector: aSelector [
	getMenuTitleSelector := aSelector
]

{ #category : #'event handling' }
TwoWayScrollPane >> mouseDown: evt [
	evt yellowButtonPressed  "First check for option (menu) click"
		ifTrue: [^ self yellowButtonActivity: evt shiftPressed].
	"If pane is not full, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseDown: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #'event handling' }
TwoWayScrollPane >> mouseEnter: event [

	"used to handle retractable scrolbar"
]

{ #category : #'event handling' }
TwoWayScrollPane >> mouseLeave: event [

	"used to handle retractable scrolbar"
]

{ #category : #'event handling' }
TwoWayScrollPane >> mouseMove: evt [
	"If pane is not full, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseMove: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #'event handling' }
TwoWayScrollPane >> mouseUp: evt [
	"If pane is not full, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseUp: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #'events-processing' }
TwoWayScrollPane >> rejectsEvent: anEvent [

	scroller submorphs isEmpty ifTrue: [^true].	"something messed up here"
	scroller firstSubmorph isSyntaxMorph ifTrue: [^ super rejectsEvent: anEvent].
	^self visible not		"ignore locked status"
]

{ #category : #geometry }
TwoWayScrollPane >> resizeScrollBar [
	"used to handle left vs right scrollbar"
	yScrollBar bounds: (bounds topLeft extent: 16 @ (bounds height - 16)).
	xScrollBar bounds: ((bounds left + 16) @ (bounds bottom - 16)  extent: (bounds width - 16) @ 16).

]

{ #category : #geometry }
TwoWayScrollPane >> resizeScroller [
	| inner |
	"used to handle left vs right scrollbar"
	inner := self innerBounds.
	scroller bounds: (inner topLeft + (yScrollBar width@0) corner: (inner bottomRight - (0@xScrollBar height)))
]

{ #category : #menu }
TwoWayScrollPane >> retractableOrNot [  "Change scroll bar operation"

	"used to handle retractable scrolbar"
]

{ #category : #geometry }
TwoWayScrollPane >> scrollBarFills: aRectangle [
	"Return true if a flop-out scrollbar fills the rectangle"
	"used to handle retractable scrolbar"
	^ false
]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> scrollBarMenuButtonPressed: event [
	^ self yellowButtonActivity: event shiftPressed
]

{ #category : #menu }
TwoWayScrollPane >> scrollBarOnLeft: aBoolean [

	"used to handle left vs right scrollbar"
]

{ #category : #geometry }
TwoWayScrollPane >> scrollBy: delta [
	"Move the contents in the direction delta."
	"For now, delta is assumed to have a zero x-component. Used by scrollIntoView:"
	| r newOffset |

	newOffset := (scroller offset - delta max: 0@0) min: self leftoverScrollRange.
	scroller offset: newOffset.

	r := self leftoverScrollRange.
	r y = 0
		ifTrue: [yScrollBar value: 0.0]
		ifFalse: [yScrollBar value: newOffset y asFloat / r y].
	r x = 0
		ifTrue: [xScrollBar value: 0.0]
		ifFalse: [xScrollBar value: newOffset x asFloat / r x].

]

{ #category : #geometry }
TwoWayScrollPane >> scrollIntoView: desiredRectangle extra: anumber [
	| shift |

	shift := desiredRectangle deltaToEnsureInOrCentered: (
		scroller offset extent: scroller bounds extent
	)  extra: anumber.
	shift = (0 @ 0) ifFalse: [self scrollBy: (0@0) - shift].

]

{ #category : #access }
TwoWayScrollPane >> scroller [
	^ scroller
]

{ #category : #geometry }
TwoWayScrollPane >> setScrollDeltas [
	| range scrollDelta totalRange innerBounds |
	totalRange := self totalScrollRange ifNil: [^ self].
	range := self leftoverScrollRange.
	innerBounds := self innerBounds.
	scrollDelta := 10 @ 10.

	self hideOrShowScrollBar: xScrollBar
		forRange: totalRange x - (innerBounds width - yScrollBar width).
	range x <= 0
		ifTrue: [xScrollBar scrollDelta: 0.02 pageDelta: 0.2.
				xScrollBar interval: 1.0]
		ifFalse: [xScrollBar scrollDelta: (scrollDelta x / range x) asFloat
						pageDelta: (innerBounds width - scrollDelta x / range x) asFloat.
				xScrollBar interval: (innerBounds width - scrollDelta x / totalRange x) asFloat].

	self hideOrShowScrollBar: yScrollBar
		forRange: totalRange y - (innerBounds height - xScrollBar height).
	range y <= 0
		ifTrue: [yScrollBar scrollDelta: 0.02 pageDelta: 0.2.
				yScrollBar interval: 1.0]
		ifFalse: [yScrollBar scrollDelta: (scrollDelta y / range y) asFloat
						pageDelta: (innerBounds height - scrollDelta y / range y) asFloat.
				yScrollBar interval: (innerBounds height - scrollDelta y / totalRange y) asFloat]
]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> shiftedYellowButtonActivity [
	^ self yellowButtonActivity: true
]

{ #category : #geometry }
TwoWayScrollPane >> totalScrollRange [

	"Return the entire scrolling range."
	^ ((scroller localSubmorphBounds ifNil: [^nil]) encompass: 0@0) extent


]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> unshiftedYellowButtonActivity [
	^ self yellowButtonActivity: false
]

{ #category : #access }
TwoWayScrollPane >> wantsSlot [
	"For now do it the old way, until we sort this out"
	^ true
]

{ #category : #menu }
TwoWayScrollPane >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ getMenuSelector notNil
]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> xScrollBarMenuButtonPressed: event [
	^ self yellowButtonActivity: event shiftPressed
]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> xScrollBarValue: scrollValue [ 

	"although there appear to be no senders, see Slider>>setValue:"

	scroller hasSubmorphs ifFalse: [^ self].
	scroller offset: self leftoverScrollRange x * scrollValue @ scroller offset y
]

{ #category : #'retractable scroll bar' }
TwoWayScrollPane >> xScrollerHeight [

	(submorphs includes: xScrollBar)  "Sorry the logic is reversed :( "
		ifFalse: [^ 0 @ 0]					"already included"
		ifTrue: [^ 0 @ xScrollBar height]	"leave space for it"

]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> yScrollBarMenuButtonPressed: event [
	^ self yellowButtonActivity: event shiftPressed
]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> yScrollBarValue: scrollValue [

	"although there appear to be no senders, see Slider>>setValue:"

	scroller hasSubmorphs ifFalse: [^ self].
	scroller offset: scroller offset x @ (self leftoverScrollRange y * scrollValue)
]

{ #category : #'scroll bar events' }
TwoWayScrollPane >> yellowButtonActivity: shiftKeyState [
	| menu |
	(menu := self getMenu: shiftKeyState) ifNotNil:
		[menu setInvokingView: self.
		menu popUpEvent: self activeHand lastEvent in: self world]
]
