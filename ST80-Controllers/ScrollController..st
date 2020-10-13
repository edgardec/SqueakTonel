"
I represent control for scrolling using a scrollBar. I am a MouseMenuController that creates a scrollBar, rather than menus. My subclasses add the button menus. I keep control as long as the cursor is inside the view or the scrollBar area.
	
A scrollBar is a rectangular area representing the length of the information being viewed. It contains an inner rectangle whose top y-coordinate represents the relative position of the information visible on the screen with respect to all of the information, and whose size represents the relative amount of that information visible on the screen. The user controls which part of the information is visible by pressing the red button. If the cursor is to the right of the inner rectangle, the window onto the visible information moves upward, if the cursor is to the left, the window moves downward, and if the cursor is inside, the inner rectangle is grabbed and moved to a desired position.
"
Class {
	#name : #ScrollController,
	#superclass : #MouseMenuController,
	#instVars : [
		'scrollBar',
		'marker',
		'savedArea',
		'menuBar',
		'savedMenuBarArea'
	],
	#category : #'ST80-Controllers'
}

{ #category : #scrolling }
ScrollController >> anyButtonActivity [
	"deal with red button down in scrollBar beyond yellowLine"

	self yellowButtonActivity
]

{ #category : #cursor }
ScrollController >> changeCursor: aCursor [ 
	"The current cursor should be set to be aCursor."

	Cursor currentCursor ~~ aCursor ifTrue: [aCursor show]
]

{ #category : #'marker adjustment' }
ScrollController >> computeMarkerRegion [
	"Answer the rectangular area in which the gray area of the scroll bar 
	should be displayed."

	^0@0 extent: Preferences scrollBarWidth @
			((view window height asFloat /
						view boundingBox height *
							scrollBar inside height)
				 rounded min: scrollBar inside height)
]

{ #category : #'control defaults' }
ScrollController >> controlActivity [
	self scrollByMouseWheel ifTrue: [^ self].
	self scrollByKeyboard ifTrue: [^ self].
	self scrollBarContainsCursor
		ifTrue: [self scroll]
		ifFalse: [self normalActivity]
]

{ #category : #'basic control sequence' }
ScrollController >> controlInitialize [
	"Recompute scroll bars.  Save underlying image unless it is already saved."
	| |
	super controlInitialize.
	scrollBar region: (0 @ 0 extent: 24 @ view apparentDisplayBox height).
	scrollBar insideColor: view backgroundColor.
	marker region: self computeMarkerRegion.
	scrollBar := scrollBar align: scrollBar topRight with: view apparentDisplayBox topLeft.
	marker := marker align: marker topCenter with: self upDownLine @ (scrollBar top + 2).
	savedArea isNil ifTrue: [savedArea := Form fromDisplay: scrollBar].
	scrollBar displayOn: Display.

	"Show a border around yellow-button (menu) region"
"
	yellowBar := Rectangle left: self yellowLine right: scrollBar right + 1
		top: scrollBar top bottom: scrollBar bottom.
	Display border: yellowBar width: 1 mask: Form veryLightGray.
"
	self moveMarker

]

{ #category : #'basic control sequence' }
ScrollController >> controlTerminate [

	super controlTerminate.
	savedArea notNil 	
		ifTrue: 
			[savedArea displayOn: Display at: scrollBar topLeft.
			savedArea := nil].
]

{ #category : #scrolling }
ScrollController >> downLine [
	"if cursor before downLine, display down cursor and scroll down on button down"

	^scrollBar left + 6 
]

{ #category : #'initialize-release' }
ScrollController >> initialize [
	super initialize.
	scrollBar := Quadrangle new.
	scrollBar borderWidthLeft: 2 right: 0 top: 2 bottom: 2.
	marker := Quadrangle new.
	marker insideColor: Preferences scrollBarColor.
	menuBar := Quadrangle new.
	menuBar borderWidthLeft:  2 right: 0 top: 2 bottom: 2.
]

{ #category : #'control defaults' }
ScrollController >> isControlActive [ 
	super isControlActive ifTrue: [^ true].
	sensor blueButtonPressed ifTrue: [^ false].
	^ (scrollBar inside merge: view insetDisplayBox) containsPoint: sensor cursorPoint
]

{ #category : #'control defaults' }
ScrollController >> isControlWanted [
	^ self viewHasCursor
]

{ #category : #cursor }
ScrollController >> markerContainsCursor [
	"Answer whether the gray area inside the scroll bar area contains the 
	cursor."

	^marker inside containsPoint: sensor cursorPoint
]

{ #category : #'marker adjustment' }
ScrollController >> markerDelta [
	^ marker top 
		- scrollBar inside top  
		- ((view window top - view boundingBox top) asFloat 
			/ view boundingBox height asFloat *
				scrollBar inside height asFloat) rounded
]

{ #category : #'marker adjustment' }
ScrollController >> markerRegion: aRectangle [ 
	"Set the area defined by aRectangle as the marker. Fill it with gray tone."

	Display fill: marker fillColor: scrollBar insideColor.
	marker region: aRectangle.
	marker := marker align: marker topCenter 
			with: self upDownLine @ (scrollBar top + 2) 
]

{ #category : #cursor }
ScrollController >> menuBarContainsCursor [
	"Answer whether the cursor is anywhere within the menu bar area."

	^ menuBar notNil and:
			[menuBar containsPoint: sensor cursorPoint]
]

{ #category : #'marker adjustment' }
ScrollController >> moveMarker [
	"The view window has changed. Update the marker."

	self moveMarker: self markerDelta negated anchorMarker: nil
]

{ #category : #'marker adjustment' }
ScrollController >> moveMarker: anInteger anchorMarker: anchorMarker [
	"Update the marker so that is is translated by an amount corresponding to 
	a distance of anInteger, constrained within the boundaries of the scroll 
	bar.  If anchorMarker ~= nil, display the border around the area where the
	marker first went down."

	Display fill: marker fillColor: scrollBar insideColor.
	anchorMarker = nil
		ifFalse: [Display border: anchorMarker width: 1 fillColor: Color gray].
	marker := marker translateBy: 0 @
				((anInteger min: scrollBar inside bottom - marker bottom) max:
					scrollBar inside top - marker top).
	marker displayOn: Display
]

{ #category : #'marker adjustment' }
ScrollController >> moveMarkerTo: aRectangle [ 
	"Same as markerRegion: aRectangle; moveMarker, except a no-op if the marker
	 would not move."

	(aRectangle height = marker height and: [self viewDelta = 0]) ifFalse:
		[self markerRegion: aRectangle.
		self moveMarker]
]

{ #category : #'control defaults' }
ScrollController >> normalActivity [
	super controlActivity
]

{ #category : #scrolling }
ScrollController >> scroll [
	"Check to see whether the user wishes to jump, scroll up, or scroll down."
	| savedCursor |
	savedCursor := Cursor currentCursor.
			[self scrollBarContainsCursor]
				whileTrue: 
					[self interActivityPause.
					sensor cursorPoint x <= self downLine
								ifTrue: [self scrollDown]
								ifFalse: [sensor cursorPoint x <= self upLine
										ifTrue: [self scrollAbsolute]
										ifFalse: [sensor cursorPoint x <= self yellowLine
												ifTrue: [self scrollUp]
												ifFalse: [sensor cursorPoint x <= scrollBar right
														ifTrue: "Might not be, with touch pen"
														[self changeCursor: Cursor menu.
														sensor anyButtonPressed 
														ifTrue: [self changeCursor: savedCursor. 
																self anyButtonActivity]]]]]].
	savedCursor show
]

{ #category : #private }
ScrollController >> scrollAbsolute [
	| markerOutline oldY markerForm |
	self changeCursor: Cursor rightArrow.

	oldY := -1.
	sensor anyButtonPressed ifTrue: 
	  [markerOutline := marker deepCopy.
	  markerForm := Form fromDisplay: marker.
	  Display fill: marker fillColor: scrollBar insideColor.
	  Display border: markerOutline width: 1 fillColor: Color gray.
	  markerForm 
		follow: 
			[oldY ~= sensor cursorPoint y
				ifTrue: 
					[oldY := sensor cursorPoint y.
					marker := marker translateBy: 
					  0 @ ((oldY - marker center y 
						min: scrollBar inside bottom - marker bottom) 
						max: scrollBar inside top - marker top).
					self scrollView].
				marker origin] 
		while: [
			self interActivityPause.
			sensor anyButtonPressed].

	  Display fill: markerOutline fillColor: scrollBar insideColor.
	  self moveMarker]
]

{ #category : #scrolling }
ScrollController >> scrollAmount [
	"Answer the number of bits of y-coordinate should be scrolled. This is a 
	default determination based on the view's preset display transformation."

	^((view inverseDisplayTransform: sensor cursorPoint)
		- (view inverseDisplayTransform: scrollBar inside topCenter)) y
]

{ #category : #cursor }
ScrollController >> scrollBarContainsCursor [
	"Answer whether the cursor is anywhere within the scroll bar area."

	^scrollBar containsPoint: sensor cursorPoint
]

{ #category : #scrolling }
ScrollController >> scrollByKeyboard [
	| keyEvent |
	keyEvent := sensor peekKeyboard.
	keyEvent ifNil: [^ false].
	(sensor controlKeyPressed or:[sensor commandKeyPressed]) ifFalse: [^ false].
	keyEvent asciiValue = 30
		ifTrue: 
			[sensor keyboard.
			self scrollViewUp ifTrue: [self moveMarker].
			^ true].
	keyEvent asciiValue = 31
		ifTrue: 
			[sensor keyboard.
			self scrollViewDown ifTrue: [self moveMarker].
			^ true].
	^ false
]

{ #category : #scrolling }
ScrollController >> scrollByMouseWheel [
	| wheelDirection |
	wheelDirection := sensor peekMouseWheelDirection.	
	wheelDirection = #up
		ifTrue: 
			[sensor mouseWheelDirection.
			self scrollViewUp ifTrue: [self moveMarker].
			^ true].
	wheelDirection = #down
		ifTrue: 
			[sensor mouseWheelDirection.
			self scrollViewDown ifTrue: [self moveMarker].
			^ true].
	^ false
]

{ #category : #private }
ScrollController >> scrollDown [
	| markerForm firstTime |
	self changeCursor: Cursor down.
	sensor anyButtonPressed ifTrue:
	  [markerForm := Form fromDisplay: marker.
	  Display fill: marker fillColor: scrollBar insideColor.
	  firstTime := true.
	  markerForm 
		follow: 
			[self scrollViewDown ifTrue:
				[marker := marker translateBy: 0 @
					((self markerDelta negated 
						min: scrollBar inside bottom - marker bottom) 
						max: scrollBar inside top - marker top).
				firstTime
					ifTrue: [
						"pause before scrolling repeatedly"
						(Delay forMilliseconds: 250) wait.
						firstTime := false.
					] ifFalse: [
						(Delay forMilliseconds: 50) wait.
					].
				].
			marker origin] 
		while: [sensor anyButtonPressed].
	  self moveMarker.]
]

{ #category : #private }
ScrollController >> scrollUp [
	| markerForm firstTime |
	self changeCursor: Cursor up.
	sensor anyButtonPressed ifTrue:
	  [markerForm := Form fromDisplay: marker.
	  Display fill: marker fillColor: scrollBar insideColor.
	  firstTime := true.
	  markerForm 
		follow: 
			[self scrollViewUp ifTrue:
				[marker := marker translateBy: 0 @
					((self markerDelta negated 
						min: scrollBar inside bottom - marker bottom) 
						max: scrollBar inside top - marker top).
				firstTime
					ifTrue: [
						"pause before scrolling repeatedly"
						(Delay forMilliseconds: 250) wait.
						firstTime := false.
					] ifFalse: [
						(Delay forMilliseconds: 50) wait.
					].
				].
			marker origin] 
		while: [sensor anyButtonPressed].
	  self moveMarker.]
]

{ #category : #scrolling }
ScrollController >> scrollView [
	"The scroll bar jump method was used so that the view should be 
	updated to correspond to the location of the scroll bar gray area.
	Return true only if scrolling took place."
	^ self scrollView: self viewDelta
]

{ #category : #scrolling }
ScrollController >> scrollView: anInteger [ 
	"Tell the reciever's view to scroll by anInteger amount.
	Return true only if scrolling actually resulted."
	(view scrollBy: 0 @ 
				((anInteger min: view window top - view boundingBox top)
						max: view window top - view boundingBox bottom))
		ifTrue: [view clearInside; display.  ^ true]
		ifFalse: [^ false]
]

{ #category : #scrolling }
ScrollController >> scrollViewDown [
	"Scroll the receiver's view down the default amount.
	Return true only if scrolling actually took place."
	^ self scrollView: self scrollAmount negated
]

{ #category : #scrolling }
ScrollController >> scrollViewUp [
	"Scroll the receiver's view up the default amount.
	Return true only if scrolling actually took place."
	^ self scrollView: self scrollAmount
]

{ #category : #scrolling }
ScrollController >> upDownLine [
	"Check to see whether the user wishes to jump, scroll up, or scroll down."

	^scrollBar left + 12
]

{ #category : #scrolling }
ScrollController >> upLine [
	"if cursor beyond upLine, display up cursor and scroll up on button down"

	^scrollBar left + 12
]

{ #category : #scrolling }
ScrollController >> viewDelta [
	"Answer an integer that indicates how much the view should be scrolled. 
	The scroll bar has been moved and now the view must be so the amount 
	to scroll is computed as a ratio of the current scroll bar position."

	^view window top - view boundingBox top -
		((marker top - scrollBar inside top) asFloat /
			scrollBar inside height asFloat *
				view boundingBox height asFloat) rounded
]

{ #category : #scrolling }
ScrollController >> yellowLine [
	"Check to see whether the user wishes to jump, scroll up, or scroll down."

	^scrollBar left + 16
]
