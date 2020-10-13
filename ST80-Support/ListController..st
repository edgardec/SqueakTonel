"
I am a kind of ScrollController that assumes that the view is a kind of ListView. Therefore, scrolling means moving the items in a textual list (menu) up or down. In addition, I provide the red button activity of determining when the red button is selecting an item in the list.
"
Class {
	#name : #ListController,
	#superclass : #ScrollController,
	#category : #'ST80-Support'
}

{ #category : #private }
ListController >> changeModelSelection: anInteger [
	model toggleListIndex: anInteger
]

{ #category : #'marker adjustment' }
ListController >> computeMarkerRegion [ 
	"Refer to the comment in ScrollController|computeMarkerRegion."

	| viewList |
	viewList := view list.
	viewList compositionRectangle height = 0
		ifTrue: [^ 0@0 extent: Preferences scrollBarWidth@scrollBar inside height].
	^ 0@0 extent: Preferences scrollBarWidth@
			((viewList clippingRectangle height asFloat /
						viewList compositionRectangle height *
							scrollBar inside height)
					rounded min: scrollBar inside height)
]

{ #category : #'control defaults' }
ListController >> controlActivity [
	self scrollByMouseWheel ifTrue: [^self].
	self scrollByKeyboard ifTrue: [^self].
	self processKeyboard.
	super controlActivity.

]

{ #category : #'marker adjustment' }
ListController >> markerDelta [

	| viewList |
	viewList := view list.
	viewList compositionRectangle height = 0 ifTrue: [
		^ (marker top - scrollBar inside top) - scrollBar inside height
	].
	^ (marker top - scrollBar inside top) -
		((viewList clippingRectangle top -
				viewList compositionRectangle top) asFloat /
			viewList compositionRectangle height asFloat *
			scrollBar inside height asFloat) rounded

]

{ #category : #'menu messages' }
ListController >> processKeyboard [
	"Derived from a Martin Pammer submission, 02/98"

     | keyEvent oldSelection nextSelection max min howMany |
	sensor keyboardPressed ifFalse: [^ self].

     keyEvent := sensor keyboard asciiValue.
     oldSelection := view selection.
     nextSelection := oldSelection.
     max := view maximumSelection.
     min := view minimumSelection.
     howMany := view clippingBox height // view list lineGrid.

     keyEvent = 31 ifTrue:
		["down-arrow; move down one, wrapping to top if needed"
		nextSelection := oldSelection + 1.
		nextSelection > max ifTrue: [nextSelection := 1]].

     keyEvent = 30 ifTrue:
		["up arrow; move up one, wrapping to bottom if needed"
		nextSelection := oldSelection - 1.
		nextSelection < 1 ifTrue: [nextSelection := max]].

     keyEvent = 1  ifTrue: [nextSelection := 1].  "home"
     keyEvent = 4  ifTrue: [nextSelection := max].   "end"
     keyEvent = 11 ifTrue: [nextSelection := min max: (oldSelection -
howMany)].  "page up"
     keyEvent = 12  ifTrue: [nextSelection := (oldSelection + howMany)
min: max].  "page down"
     nextSelection = oldSelection  ifFalse:
		[model okToChange
			ifTrue:
				[self changeModelSelection: nextSelection.
				self moveMarker]]
			
]

{ #category : #selecting }
ListController >> redButtonActivity [
	| noSelectionMovement oldSelection selection nextSelection pt scrollFlag firstTime |
	noSelectionMovement := true.
	scrollFlag := false.
	oldSelection := view selection.
	firstTime := true.
	[sensor redButtonPressed | firstTime]
		whileTrue: 
			[selection := view findSelection: (pt := sensor cursorPoint).
			firstTime := false.
			selection == nil ifTrue:  "Maybe out of box - check for auto-scroll"
					[pt y < view insetDisplayBox top ifTrue:
						[self scrollView: view list lineGrid.
						scrollFlag := true.
						selection := view firstShown].
					pt y > view insetDisplayBox bottom ifTrue:
						[self scrollView: view list lineGrid negated.
						scrollFlag := true.
						selection := view lastShown]].
			selection == nil ifFalse:
					[view moveSelectionBox: (nextSelection := selection).
					nextSelection ~= oldSelection
						ifTrue: [noSelectionMovement := false]]].
	nextSelection ~~ nil & (nextSelection = oldSelection
			ifTrue: [noSelectionMovement]
			ifFalse: [true]) ifTrue: [self changeModelSelection: nextSelection].
	scrollFlag ifTrue: [self moveMarker]
]

{ #category : #scrolling }
ListController >> scrollAmount [ 
	"Refer to the comment in ScrollController|scrollAmount."

	^sensor cursorPoint y - scrollBar inside top
]

{ #category : #scrolling }
ListController >> scrollView: anInteger [ 
	"Scroll the view and highlight the selection if it just came into view"
	| wasClipped |
	wasClipped := view isSelectionBoxClipped.
	(view scrollBy: anInteger)
		ifTrue: [view isSelectionBoxClipped ifFalse:
					[wasClipped ifTrue:  "Selection came into view"
						[view displaySelectionBox]].
				^ true]
		ifFalse: [^ false]
]

{ #category : #scrolling }
ListController >> viewDelta [ 
	"Refer to the comment in ScrollController|viewDelta."

	| viewList |
	viewList := view list.
	^(viewList clippingRectangle top -
			viewList compositionRectangle top -
			((marker top - scrollBar inside top) asFloat /
				scrollBar inside height asFloat *
				viewList compositionRectangle height asFloat))
		roundTo: viewList lineGrid
]
