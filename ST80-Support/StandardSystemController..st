"
I am a controller for StandardSystemViews, that is, those views that are at the top level of a project in the system user interface. I am a kind of MouseMenuController that creates a blue button menu for moving, framing, collapsing, and closing ScheduledViews, and for selecting views under the view of my instance.
"
Class {
	#name : #StandardSystemController,
	#superclass : #MouseMenuController,
	#instVars : [
		'status'
	],
	#classVars : [
		'HBorderCursor',
		'ScheduledBlueButtonMenu',
		'ScheduledBlueButtonMessages',
		'VBorderCursor'
	],
	#category : #'ST80-Support'
}

{ #category : #'class initialization' }
StandardSystemController class >> initialize [
	"StandardSystemController initialize"

	ScheduledBlueButtonMenu := SelectionMenu
		labels:
'edit label
choose color...
two-tone/full color
move
frame
full screen
collapse
close'
	lines: #(3 7)
	selections: #(label chooseColor toggleTwoTone move reframe fullScreen collapse close).

	VBorderCursor := Cursor extent: 16@16 fromArray: #(
		2r1010000000000000
		2r1010000000000000
		2r1010000000000000
		2r1010000000000000
		2r1010000000000000
		2r1010010000100000
		2r1010110000110000
		2r1011111111111000
		2r1010110000110000
		2r1010010000100000
		2r1010000000000000
		2r1010000000000000
		2r1010000000000000
		2r1010000000000000
		2r1010000000000000
		2r1010000000000000)
			offset: 0@0.
	HBorderCursor := Cursor extent: 16@16 fromArray: #(
		2r1111111111111111
		2r0000000000000000
		2r1111111111111111
		2r0000000100000000
		2r0000001110000000
		2r0000011111000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000011111000000
		2r0000001110000000
		2r0000000100000000
		2r0000000000000000
		2r0000000000000000
		2r0000000000000000)
			offset: 0@0.
]

{ #category : #borders }
StandardSystemController >> adjustPaneBorders [ 
	| side sub newRect outerFrame |
	outerFrame := view displayBox.
	side := #none.
	VBorderCursor showWhile:
		[ [sub := view subviewWithLongestSide: [:s | side := s]
						near: sensor cursorPoint.
		  self cursorOnBorder and: [(side = #left) | (side = #right)]]
			whileTrue: [
				self interActivityPause.
				sensor redButtonPressed ifTrue:
				[side = #left ifTrue:
					[newRect := sub stretchFrame:
						[:f | (f withLeft: sensor cursorPoint x)
								intersect: outerFrame]
						startingWith: sub displayBox].
				side = #right ifTrue:
					[newRect := sub stretchFrame:
						[:f | (f withRight: sensor cursorPoint x)
								intersect: outerFrame]
						startingWith: sub displayBox].
				view reframePanesAdjoining: sub along: side to: newRect]]].
	HBorderCursor showWhile:
		[ [sub := view subviewWithLongestSide: [:s | side := s]
						near: sensor cursorPoint.
		  self cursorOnBorder and: [(side = #top) | (side = #bottom)]]
			whileTrue: [
				self interActivityPause.
				sensor redButtonPressed ifTrue:
				[side = #top ifTrue:
					[newRect := sub stretchFrame:
						[:f | (f withTop: sensor cursorPoint y)
								intersect: outerFrame]
						startingWith: sub displayBox].
				side = #bottom ifTrue:
					[newRect := sub stretchFrame:
						[:f | (f withBottom: sensor cursorPoint y)
								intersect: outerFrame]
						startingWith: sub displayBox].
				view reframePanesAdjoining: sub along: side to: newRect]]]
]

{ #category : #borders }
StandardSystemController >> adjustWindowBorders [ 
	| side noClickYet |
	noClickYet := true.
	VBorderCursor showWhile:
		[ [side := view displayBox sideNearestTo: sensor cursorPoint.
		  self cursorOnBorder
			and: [(side = #left) | (side = #right)
			and: [noClickYet or: [sensor redButtonPressed]]]]
			whileTrue:
			[sensor redButtonPressed ifTrue:
				[noClickYet := false.
				side = #left ifTrue:
					[view newFrame: [:f | f withLeft: sensor cursorPoint x]].
				side = #right ifTrue:
					[view newFrame: [:f | f withRight: sensor cursorPoint x]]].
			self interActivityPause]].
	HBorderCursor showWhile:
		[ [side := view displayBox sideNearestTo: sensor cursorPoint.
		  self cursorOnBorder
			and: [(side = #top) | (side = #bottom)
			and: [noClickYet or: [sensor redButtonPressed]]]]
			whileTrue:
			[sensor redButtonPressed ifTrue:
				[noClickYet := false.
				side = #top ifTrue:
					[view newFrame: [:f | f withTop: sensor cursorPoint y]].
				side = #bottom ifTrue:
					[view newFrame: [:f | f withBottom: sensor cursorPoint y]]].
		  self interActivityPause]]
]

{ #category : #borders }
StandardSystemController >> adjustWindowCorners [ 
	| box clicked |
	box := view windowBox.
	clicked := false.
	#(topLeft topRight bottomRight bottomLeft)
		do: [:readCorner |
			| cornerBox |
			cornerBox := ((box insetBy: 2) perform: readCorner) - (10@10) extent: 20@20.
			(cornerBox containsPoint: sensor cursorPoint)
				ifTrue: 
				["Display reverse: cornerBox."
				(Cursor perform: readCorner) showWhile:
					[[(cornerBox containsPoint: (sensor cursorPoint))
						and: [(clicked := sensor anyButtonPressed) not]]
						whileTrue: [ self interActivityPause ].
				"Display reverse: cornerBox."
				clicked ifTrue:
					[view newFrame:
						[:f | | p f2 |
						p := sensor cursorPoint.
						readCorner = #topLeft ifTrue:
							[f2 := p corner: f bottomRight].
						readCorner = #bottomLeft ifTrue:
							[f2 := (f withBottom: p y) withLeft: p x].
						readCorner = #bottomRight ifTrue:
							[f2 := f topLeft corner: p].
						readCorner = #topRight ifTrue:
							[f2 := (f withTop: p y) withRight: p x].
						f2]]]]].
	^ clicked
]

{ #category : #'control defaults' }
StandardSystemController >> blueButtonActivity [
	ScheduledBlueButtonMenu ifNil: [^ super controlActivity].
	ScheduledBlueButtonMenu invokeOn: self
]

{ #category : #borders }
StandardSystemController >> checkForReframe [
	| cp |
	view isCollapsed ifTrue: [^ self].
	cp := sensor cursorPoint.
	((view closeBoxFrame expandBy: 2) containsPoint: cp)
		| ((view growBoxFrame expandBy: 2) containsPoint: cp)
		ifTrue: [^ self].  "Dont let reframe interfere with close/grow"
	self adjustWindowCorners.
	self cursorOnBorder ifFalse: [^ self].
	((view insetDisplayBox insetBy: 2@2) containsPoint: cp)
		ifFalse: [^ self adjustWindowBorders].
	view subViews size <= 1 ifTrue: [^ self].
	(view subviewWithLongestSide: [:s | ] near: cp) == nil
		ifFalse: [^ self adjustPaneBorders].
]

{ #category : #'menu messages' }
StandardSystemController >> chooseColor [
	"Allow the user to specify a new background color for the receiver's window.  5/6/96 sw.
	 7/31/96 sw: use Color fromUser"

	view backgroundColor: Color fromUser; uncacheBits; display
]

{ #category : #'menu messages' }
StandardSystemController >> close [
	"The receiver's view should be removed from the screen and from the 
	collection of scheduled views."

	model okToChange ifFalse: [^self].
	status := #closed.
	view erase
]

{ #category : #scheduling }
StandardSystemController >> closeAndUnschedule [
	"Erase the receiver's view and remove it from the collection of scheduled 
	views."

	status := #closed.
	ScheduledControllers unschedule: self.
	view erase.
	view release.
	ScheduledControllers searchForActiveController.
]

{ #category : #scheduling }
StandardSystemController >> closeAndUnscheduleNoErase [
	"Remove the scheduled view from the collection of scheduled views. Set 
	its status to closed but do not erase and do not terminate. For debuggers."

	status := #closed.
	ScheduledControllers unschedule: self.
	view release.
]

{ #category : #scheduling }
StandardSystemController >> closeAndUnscheduleNoTerminate [
	"Erase the receiver's view and remove it from the collection of scheduled views, but do not terminate the current process. Useful for clean-up scripts."

	status := #closed.
	ScheduledControllers unschedule: self.	
	view erase.
	view release.

]

{ #category : #'menu messages' }
StandardSystemController >> collapse [
	"Get the receiver's view to change to a collapsed view on the screen."
	view collapseToPoint: view chooseCollapsePoint
]

{ #category : #'control defaults' }
StandardSystemController >> controlActivity [
	self checkForReframe.
	^ super controlActivity
]

{ #category : #'basic control sequence' }
StandardSystemController >> controlInitialize [
	view displayEmphasized.
	view uncacheBits.  "Release cached bitmap while active"
	model windowActiveOnFirstClick ifFalse: [sensor waitNoButton].
	status := #active.
	view isCollapsed ifFalse: [model modelWakeUpIn: view]
]

{ #category : #'basic control sequence' }
StandardSystemController >> controlTerminate [
	status == #closed
		ifTrue: [
			ScheduledControllers unschedule: self.
			view ~~ nil ifTrue: [view release].
			^self].
	view deEmphasize; cacheBits.
	view isCollapsed ifFalse: [model modelSleep].
]

{ #category : #borders }
StandardSystemController >> cursorOnBorder [ 
	| cp i box |
	view isCollapsed ifTrue: [^ false].
	cp := sensor cursorPoint.
	((view labelDisplayBox insetBy: (0 @ 2 corner: 0 @ -2)) containsPoint: cp)
		ifTrue: [^ false].
	(i := view subViews findFirst: [:v | v displayBox containsPoint: cp]) = 0
		ifTrue: [box := view windowBox]
		ifFalse: [box := (view subViews at: i) insetDisplayBox].
	^ ((box insetBy: 3) containsPoint: cp) not
		and: [(box expandBy: 4) containsPoint: cp]
]

{ #category : #'menu messages' }
StandardSystemController >> expand [
	"The receiver's view was collapsed; open it again and ask the user to 
	designate its rectangular area."
	view expand; emphasize
]

{ #category : #borders }
StandardSystemController >> fullScreen [
	"Make the receiver's window occupy jes' about the full screen.  6/10/96 sw"

	view fullScreen
]

{ #category : #'pluggable menus' }
StandardSystemController >> getPluggableYellowButtonMenu: shiftKeyState [
	^ nil
]

{ #category : #'initialize-release' }
StandardSystemController >> initialize [
	super initialize.
	status := #inactive
]

{ #category : #'control defaults' }
StandardSystemController >> isControlActive [
	status == #active ifFalse: [^ false].
	sensor anyButtonPressed ifFalse: [^ true].
	self viewHasCursor
		ifTrue: [^ true]
		ifFalse: [ScheduledControllers noteNewTop.
				^ false]
]

{ #category : #'menu messages' }
StandardSystemController >> label [

	| newLabel |
	newLabel := UIManager default
		request: 'Edit the label, then type RETURN'
		initialAnswer: view label.
	newLabel isEmpty ifFalse: [view relabel: newLabel].

]

{ #category : #cursor }
StandardSystemController >> labelHasCursor [
	"Answer true if the cursor is within the window's label"
	^view labelContainsPoint: sensor cursorPoint
]

{ #category : #'menu messages' }
StandardSystemController >> move [
	"Ask the user to designate a new origin position for the receiver's view.
	6/10/96 sw: tell the view that it has moved"

	| oldBox | 
	oldBox := view windowBox.
	view uncacheBits.
	view align: view windowBox topLeft
		with: view chooseMoveRectangle topLeft.
	view displayEmphasized.
	view moved.  "In case its model wishes to take note."
	(oldBox areasOutside: view windowBox) do:
		[:rect | ScheduledControllers restore: rect]
]

{ #category : #scheduling }
StandardSystemController >> open [
	"Create an area on the screen in which the receiver's scheduled view can 
	be displayed. Make it the active view."

	view resizeInitially.
	status := #open.
	ScheduledControllers scheduleActive: self
]

{ #category : #scheduling }
StandardSystemController >> openDisplayAt: aPoint [ 
	"Create an area with origin aPoint in which the receiver's scheduled 
	view can be displayed. Make it the active view."

	view align: view viewport center with: aPoint.
	view translateBy:
		(view displayBox amountToTranslateWithin: Display boundingBox).
	status := #open.
	ScheduledControllers scheduleActive: self
]

{ #category : #scheduling }
StandardSystemController >> openNoTerminate [
	"Create an area in which the receiver's scheduled view can be displayed. 
	Make it the active view. Do not terminate the currently active process."

	view resizeInitially.
	status := #open.
	ScheduledControllers scheduleActiveNoTerminate: self
]

{ #category : #scheduling }
StandardSystemController >> openNoTerminateDisplayAt: aPoint [ 
	"Create an area with origin aPoint in which the receiver's scheduled 
	view can be displayed. Make it the active view. Do not terminate the 
	currently active process."

	view resizeMinimumCenteredAt: aPoint.
	status := #open.
	ScheduledControllers scheduleActiveNoTerminate: self
]

{ #category : #'control defaults' }
StandardSystemController >> redButtonActivity [
	"If cursor is in label of a window when red button is pushed,
	check for closeBox or growBox, else drag the window frame
	or edit the label."

	| box p |
	p := sensor cursorPoint.
	self labelHasCursor ifFalse: [super redButtonActivity. ^ self].
	((box := view closeBoxFrame) containsPoint: p)
		ifTrue:
			[Utilities
				awaitMouseUpIn: box
				repeating: []
				ifSucceed: [self close. ^ self].
			^ self].
	((box := view growBoxFrame) containsPoint: p)
		ifTrue:
			[Utilities
				awaitMouseUpIn: box
				repeating: []
				ifSucceed:
					[Sensor controlKeyPressed ifTrue: [^ self expand; fullScreen].
					^ view isCollapsed
						ifTrue: [self expand]
						ifFalse: [self collapse]].
			^ self].
	(((box := view labelTextRegion expandBy: 1) containsPoint: p)
			and: [Preferences clickOnLabelToEdit or: [sensor leftShiftDown]])
		ifTrue:
			[Utilities
				awaitMouseUpIn: box
				repeating: []
				ifSucceed: [^ self label].
			^ self].
	self move
]

{ #category : #'menu messages' }
StandardSystemController >> reframe [
	^ view reframeTo: view getFrame
]

{ #category : #scheduling }
StandardSystemController >> status: aSymbol [
	status := aSymbol
]

{ #category : #'menu messages' }
StandardSystemController >> toggleTwoTone [
	(view isMemberOf: StandardSystemView) ifTrue:
		[^ view becomeForward: (view as: ColorSystemView)].
	(view isMemberOf: ColorSystemView) ifTrue:
		[^ view becomeForward: (view as: StandardSystemView)].

]

{ #category : #'menu messages' }
StandardSystemController >> under [
	"Deactive the receiver's scheduled view and pass control to any view that 
	might be positioned directly underneath it and the cursor."

	status := #inactive
]
