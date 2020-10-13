"
My instances are intended to be components in a structured picture. Each View in the structured picture can contain other Views as sub-components. These sub-components are called subViews. A View can be a subView of only one View. This View is called its superView. The set of Views in a structured picture forms a hierarchy. The one View in the hierarchy that has no superView is called the topView of the structured picture. A View in a structured picture with no subViews is called a bottom View. A View and all of its subViews, and all of their subViews and so on, are treated as a unit in many operations on the View. For example, if a View is displayed, all of its subViews are displayed as well. There are several categories of operations that can be performed on a View. Among these are the following:
	
	1.	Adding subViews to a View.
	2.	Positioning subViews within a View.
	3.	Deleting subViews from a View.
	4.	Transforming a View.
	5.	Displaying a View.
	
Each View has its own coordinate system. In order to change from one coordinate system to another, each View has two transformations associated with it. The local transformation is a WindowingTransformation that maps objects in the coordinate system of the View to objects in the coordinate system of the superView of the View. The displayTransformation is a WindowingTransformation that maps objects in the coordinate system of the View to objects in the display screen coordinate system.
	
The part of the space that is to be made visible is represented by the window of the View. The window of a View is a Rectangle expressed in the coordinate system of the View. The area occupied by a View in the coordinate system of its superView is called its viewport. The viewport of a View is its window transformed by its local transformation. The region of the display screen occupied by a View is called its displayBox. The display box of a View can include a border. The width of the border expressed in display screen coordinates is called the border width of the View. The color of the border is called the border color. The region of the display box of a View excluding the border is called the inset display box. The color of the inset display box is called the inside color of the View.
"
Class {
	#name : #View,
	#superclass : #Object,
	#instVars : [
		'model',
		'controller',
		'superView',
		'subViews',
		'transformation',
		'viewport',
		'window',
		'displayTransformation',
		'insetDisplayBox',
		'borderWidth',
		'borderColor',
		'insideColor',
		'boundingBox'
	],
	#category : #'ST80-Framework'
}

{ #category : #'subView inserting' }
View >> addSubView: aView [ 
	"Remove aView from the tree of Views it is in (if any) and adds it to the 
	rear of the list of subViews of the receiver. Set the superView of aView 
	to be the receiver. It is typically used to build up a hierarchy of Views 
	(a structured picture). An error notification is generated if aView is the 
	same as the receiver or its superView, and so on."

	self addSubView: aView ifCyclic: [self error: 'cycle in subView structure.']
]

{ #category : #'subView inserting' }
View >> addSubView: aSubView above: lowerView [
	"Adds aView (see View|addSubView:) so that it lies above topView."

	self addSubView: aSubView
		align: aSubView viewport bottomLeft
		with: lowerView viewport topLeft
]

{ #category : #'subView inserting' }
View >> addSubView: aSubView align: aPoint1 with: aPoint2 [ 
	"Add aView to the receiver's list of subViews (see View|addSubView:) 
	and translate aView so that aPoint1 coincides with aPoint2. It is typically 
	used to build up a hierarchy of Views (a structured picture). Normally, 
	aPoint1 is a point on aView's viewport (e.g. aView viewport topLeft), 
	and aPoint2 is either an arbitrary point in the receiver's coordinate 
	system or a point on the receiver's window (e.g., self window topRight)."

	self addSubView: aSubView.
	aSubView align: aPoint1 with: aPoint2
]

{ #category : #'subView inserting' }
View >> addSubView: aSubView below: lowerView [
	"Add the argument, aSubView, (see View|addSubView:) so that it lies 
	below the view, topView."

	self addSubView: aSubView
		align: aSubView viewport topLeft
		with: lowerView viewport bottomLeft
]

{ #category : #'subView inserting' }
View >> addSubView: aView ifCyclic: exceptionBlock [ 
	"Remove aView from the tree of Views it is in (if any) and add it to the 
	rear of the list of subViews of the receiver. Set the superView of aView 
	to be the receiver. It is typically used to build up a hierarchy of Views 
	(a structured picture). An error notification is generated if aView is the 
	same as the receiver or its superView, and so on."

	(self isCyclic: aView)
		ifTrue: [exceptionBlock value]
		ifFalse: 
			[aView removeFromSuperView.
			subViews addLast: aView.
			aView superView: self]
]

{ #category : #'subView inserting' }
View >> addSubView: aSubView toLeftOf: rightView [
	"Adds aView (see addSubView:) so that it lies to the right of rightView."

	self addSubView: aSubView
		align: aSubView viewport topRight
		with:  rightView viewport topLeft
]

{ #category : #'subView inserting' }
View >> addSubView: aSubView toRightOf: leftView [
	"Add the argument, aSubView, (see View|addSubView:) so that it lies to 
	the right of the view, leftView."

	self addSubView: aSubView
		align: aSubView viewport topLeft
		with: leftView viewport topRight
]

{ #category : #'subView inserting' }
View >> addSubView: aView viewport: aViewport [ 
	"Add aView to the receiver's list of subViews (see View|addSubView:) and 
	applies to aView a scale and translation computed from its window and 
	aViewport (such that its window fills aViewport)."

	self addSubView: aView.
	aView window: aView window viewport: aViewport
]

{ #category : #'subView inserting' }
View >> addSubView: aView window: aWindow viewport: aViewport [ 
	"Add aView to the receiver's list of subViews (see View|addSubView:) 
	and applies to aView a scale and translation computed from aWindow 
	and aViewport (such that aWindow fills aViewport)."

	self addSubView: aView.
	aView window: aWindow viewport: aViewport
]

{ #category : #transforming }
View >> align: aPoint1 with: aPoint2 [ 
	"Add a translation of (aPoint2 - aPoint1) to the receiver's local 
	transformation. The point in the receiver's coordinate system that 
	previously was transformed to aPoint1 in the superView's coordinate 
	system will now be transformed to aPoint2 in the superView's coordinate 
	system. Other points will be translated by the same amount. It is 
	normally used when adding subViews to their superView in order to 
	line up the Viewport of one subView with that of another subView (see 
	View|addSubView:align:with:). aPoint1 and aPoint2 are usually points on 
	the viewports that are to be aligned. For example, 'subView2 align: 
	subView2 viewport topLeft with: subView1 viewport topRight' would be 
	used to place the viewport of subView2 next to the viewport of 
	subView1 with the topLeft and topRight corners, respectively, 
	coinciding. It is also possible to align the viewport of a subView with 
	the window of the superView, e.g., 'subView align: subView viewport 
	center with: superView window center'. View|align:with: assumes that 
	the view has been properly scaled, if necessary, to match its superView 
	(see View|scaleBy:). Typically, the coordinate systems of the receiver 
	and its superView will differ only by a translation offset so that no 
	scaling is necessary."

	self setTransformation: (transformation align: aPoint1 with: aPoint2)
]

{ #category : #'display box access' }
View >> apparentDisplayBox [
	^self insetDisplayBox expandBy: 2 @ 2
]

{ #category : #bordering }
View >> backgroundColor [
	Display depth <= 2 ifTrue: [^ Color white].
	insideColor ifNotNil: [^ Color colorFrom: insideColor].
	^ superView == nil
		ifFalse: [superView backgroundColor]
		ifTrue:	[Color white]
]

{ #category : #bordering }
View >> backgroundColor: aColor [
	Display depth = 1 ifTrue:
		[(aColor ~= nil and: [aColor isTransparent not]) ifTrue:
			["Avoid stipple due to attempts to match non-whites"
			^ insideColor := Color white]].
	insideColor := aColor
]

{ #category : #'morphic compatibility' }
View >> balloonText: aString [
	"Unfortunately we just ignore this help text because we are not morphic"

]

{ #category : #bordering }
View >> borderWidth [
	"Answer either 0, indicating no border, or a Rectangle whose left value is 
	the width in display coordinates of the receiver's left border. Right, top, 
	and bottom widths are analogous. The border width is initially 0. A 
	View with a border width of 0 will not have any border displayed."

	^borderWidth
]

{ #category : #bordering }
View >> borderWidth: anInteger [
	"Set the four border widths of the receiver to anInteger."

	self
		borderWidthLeft: anInteger
		right: anInteger
		top: anInteger
		bottom: anInteger
]

{ #category : #bordering }
View >> borderWidthLeft: anInteger1 right: anInteger2 top: anInteger3 bottom: anInteger4 [
	"Set the border widths of the receiver. These arguments represent the left, 
	right, top, and bottom border widths."

	borderWidth :=
			Rectangle
				left: anInteger1
				right: anInteger2
				top: anInteger3
				bottom: anInteger4.
	self unlock
]

{ #category : #'display box access' }
View >> boundingBox [
	"Answer the bounding box which for the default case is the rectangular 
	area surrounding the bounding boxes of all the subViews."

	boundingBox ~~ nil
		ifTrue: [^boundingBox]
		ifFalse: [^self computeBoundingBox]
]

{ #category : #testing }
View >> canDiscardEdits [
	"Return true if this pane is not dirty."

	^ true

]

{ #category : #clearing }
View >> clear [
	"Use the border color to paint the display box (including the border, see 
	View|displayBox) of the receiver."

	borderColor ~= nil ifTrue: [self clear: Color black]
]

{ #category : #clearing }
View >> clear: aColor [ 
	"Use aColor to paint the display box (including the border, see 
	View|displayBox) of the receiver."

	aColor ~= nil ifTrue: [Display fill: self displayBox fillColor: aColor]
]

{ #category : #clearing }
View >> clearInside [
	"Use the inside color to paint the inset display box (excluding the border, 
	see View|insetDisplayBox) of the receiver."

	self clearInside: self backgroundColor
]

{ #category : #clearing }
View >> clearInside: aColor [ 
	"Use aColor to paint the inset display box (excluding the border, see 
	View|insetDisplayBox) of the receiver."

	aColor ~~ nil ifTrue: [Display fill: self insetDisplayBox fillColor: aColor]
]

{ #category : #miscellaneous }
View >> clipRect [
	^ superView clipRect
]

{ #category : #miscellaneous }
View >> clipRect: r [
	superView clipRect: r
]

{ #category : #displaying }
View >> clippingTo: rect do: aBlock [

	superView clippingTo: rect do: aBlock
]

{ #category : #'display box access' }
View >> computeBoundingBox [
	"Answer the minimum Rectangle that encloses the bounding boxes of the 
	receiver's subViews. If the receiver has no subViews, then the bounding 
	box is the receiver's window. Subclasses should redefine 
	View|boundingBox if a more suitable default for the case of no subViews 
	is available."

	| aRectangle |
	subViews isEmpty ifTrue: [^self getWindow].
	aRectangle := (self firstSubView transform: self firstSubView boundingBox) copy.
	subViews do: 
		[:aView | 
		aRectangle swallow: (aView transform: aView boundingBox).].
	^aRectangle expandBy: borderWidth
]

{ #category : #private }
View >> computeDisplayTransformation [
	"Answer a WindowingTransformation that transforms the coordinate 
	system of the View into that of the display screen. The transformation is 
	computed by composing the View's transformation with all transformations 
	along its superView chain. It is sent by View|displayTransformation when
	the View is unlocked (see View|unlock)."

	self isTopView
		ifTrue: [^transformation]
		ifFalse: [^superView displayTransformation compose: transformation]
]

{ #category : #private }
View >> computeInsetDisplayBox [
	"Compute the View's inset display box by intersecting the superView's
	inset display box with the View's window transformed to display
	coordinates and then inseting the result by the border width. It is sent by 
	View|insetDisplayBox if the inset display box is nil.

	The insetDisplayBox points are truncated to prevent sending floating point numbers to QuickDraw which will die."

	self isTopView
		ifTrue:
			[^((self displayTransform: self getWindow) insetBy: borderWidth) truncated]
		ifFalse:
			[^(superView insetDisplayBox
				intersect: (self displayTransform: self getWindow)) truncated
						insetBy: borderWidth]
]

{ #category : #testing }
View >> containsPoint: aPoint [
	"Answer whether aPoint is within the receiver's display box. It is sent to 
	a View's subViews by View|subViewAt: in order to determine which 
	subView contains the cursor point (so that, for example, control can be 
	pass down to that subView's controller)."

	^ self insetDisplayBox containsPoint: aPoint
]

{ #category : #'controller access' }
View >> controller [
	"If the receiver's controller is nil (the default case), answer an initialized 
	instance of the receiver's default controller. If the receiver does not 
	allow a controller, answer the symbol #NoControllerAllowed."

	controller == nil ifTrue: [self controller: self defaultController].
	^controller
]

{ #category : #'controller access' }
View >> controller: aController [ 
	"Set the receiver's controller to aController. #NoControllerAllowed can be 
	specified to indicate that the receiver will not have a controller. The 
	model of aController is set to the receiver's model."

	self model: model controller: aController
]

{ #category : #deEmphasizing }
View >> deEmphasize [
	"Modify the emphasis (highlighting, special tabs) of the receiver. This 
	includes objects such as labels, lines, and boxes. Typically used so that 
	the receiver is not presented as active. Do this for the receiver and then 
	for each of the receiver's subViews."

	self deEmphasizeView.
	self deEmphasizeSubViews
]

{ #category : #deEmphasizing }
View >> deEmphasizeForDebugger [
	"Overridden by StandardSystemView. This default behavior does nothing."

]

{ #category : #deEmphasizing }
View >> deEmphasizeSubViews [
	"Send the deEmphasize message to each of the receiver's subviews."

	subViews do: [:aSubView | aSubView deEmphasize]
]

{ #category : #deEmphasizing }
View >> deEmphasizeView [
	"Subclasses should redefine View|deEmphasizeView in order to modify 
	the emphasis (highlighting, special tabs) of particular objects associated 
	with the View such as labels, lines, and boxes."

	^self
]

{ #category : #'initialize-release' }
View >> defaultBackgroundColor [

	^ self userInterfaceTheme color
]

{ #category : #'controller access' }
View >> defaultController [
	"Answer an initialized instance of the receiver's default controller. 
	Subclasses should redefine this message only if the default controller 
	instances need to be initialized in a nonstandard way."

	^self defaultControllerClass new
]

{ #category : #'controller access' }
View >> defaultControllerClass [
	"Answer the class of the default controller for the receiver. Subclasses 
	should redefine View|defaultControllerClass if the class of the default 
	controller is not Controller."

	^Controller
]

{ #category : #'initialize-release' }
View >> defaultForegroundColor [

	^ self userInterfaceTheme borderColor
]

{ #category : #'window access' }
View >> defaultWindow [
	"Build the minimum Rectangle that encloses all the windows of the 
	receiver's subViews. The answer is a Rectangle obtained by expanding 
	this minimal Rectangle by the borderWidth of the receiver. If the 
	receiver has no subViews, then a Rectangle enclosing the entire display 
	screen is answered. It is used internally by View methods if no window 
	has been specified for the View. Specialized subclasses of View should 
	redefine View|defaultWindow to handle the default case for instances 
	that have no subViews."

	| aRectangle |
	subViews isEmpty ifTrue: [^DisplayScreen boundingBox].
	aRectangle := self firstSubView viewport copy.
	subViews do: [:aView | aRectangle swallow: aView viewport].
	^aRectangle expandBy: borderWidth
]

{ #category : #displaying }
View >> display [
	"Display the receiver's border, display the receiver, then display the 
	subViews of the receiver. Can be sent to the top View of a structured 
	picture in order to display the entire structure, or to any particular View 
	in the structure in order to display that View and its subViews. It is 
	typically sent in response to an update request to a View."

	Display deferUpdatesIn: self displayBox while: [
		self displayBorder.
		self displayView.
		self displaySubViews]
]

{ #category : #displaying }
View >> displayBorder [
	"Display the receiver's border (using the receiver's borderColor)."

	borderWidth = 0
		ifTrue:
			[insideColor == nil
				ifFalse: 
					[Display fill: self displayBox fillColor: self backgroundColor]]
		ifFalse:
			[Display
				border: self displayBox
				widthRectangle: borderWidth
				rule: Form over
				fillColor: self foregroundColor.
			insideColor == nil ifFalse:
				[Display fill: self insetDisplayBox fillColor: self backgroundColor]]
]

{ #category : #'display box access' }
View >> displayBox [
	"Answer the receiver's inset display box (see View|insetDisplayBox) 
	expanded by the borderWidth. The display box represents the region of 
	the display screen in which the receiver (including the border) is 
	displayed. If the receiver is totally clipped by the display screen and its 
	superView, the resulting Rectangle will be invalid."

	^self insetDisplayBox expandBy: borderWidth
]

{ #category : #displaying }
View >> displayClippingTo: rect [

	| bigRect |
	bigRect := rect insetBy: -1.
	self clippingTo: bigRect do: [Display clippingTo: bigRect do: [self display]]

]

{ #category : #displaying }
View >> displayDeEmphasized [
	self display; deEmphasize
]

{ #category : #displaying }
View >> displaySubViews [
	"Display all the subViews of the receiver."

	subViews do: [:aSubView | aSubView display]
]

{ #category : #'display transformation' }
View >> displayTransform: anObject [ 
	"Apply the display transformation of the receiver to anObject (see 
	View|displayTransformation) and answer the resulting scaled, translated 
	object. It is normally applied to Rectangles, Points, and other objects with 
	coordinates defined in the View's local coordinate system in order to get 
	a corresponding object in display coordinates."

	^(self displayTransformation applyTo: anObject) rounded
]

{ #category : #'display transformation' }
View >> displayTransformation [
	"Answer a WindowingTransformation that is the result of composing all 
	local transformations in the receiver's superView chain with the 
	receiver's own local transformation. The resulting transformation 
	transforms objects in the receiver's coordinate system into objects in the 
	display screen coordinate system."

	displayTransformation == nil
		ifTrue: [displayTransformation := self computeDisplayTransformation].
	^displayTransformation
]

{ #category : #displaying }
View >> displayView [
	"Subclasses should redefine View|displayView in order to display 
	particular objects associated with the View such as labels, lines, and 
	boxes."

	^self
]

{ #category : #displaying }
View >> displayViewDeEmphasized [
	self displayView; deEmphasizeView
]

{ #category : #deEmphasizing }
View >> emphasize [
	"Modify the emphasis (highlighting, special tabs) of the receiver. This 
	includes objects such as labels, lines, and boxes. Typically used so that 
	the receiver is presented as active. Do this for the receiver and then 
	for each of the receiver's subViews."

	self emphasizeView.
	self emphasizeSubViews
]

{ #category : #deEmphasizing }
View >> emphasizeSubViews [
	"Send the emphasize message to each of the receiver's subviews."

	subViews do: [:aSubView | aSubView emphasize]
]

{ #category : #deEmphasizing }
View >> emphasizeView [
	"Subclasses should redefine View|emphasizeView in order to modify 
	the emphasis (highlighting, special tabs) of particular objects associated 
	with the View such as labels, lines, and boxes."

	^self
]

{ #category : #'subView access' }
View >> firstSubView [
	"Answer the first subView in the receiver's list of subViews if it is not 
	empty, else nil."

	subViews isEmpty
		ifTrue: [^nil]
		ifFalse: [^subViews first]
]

{ #category : #indicating }
View >> flash [
	"Cause the inset display box (the display box excluding the border, see 
	View|insetDisplayBox) of the receiver to complement twice in succession."

	Display flash: self insetDisplayBox
]

{ #category : #bordering }
View >> foregroundColor [
	borderColor ifNotNil: [^ Color colorFrom: borderColor].
	^ superView == nil
		ifFalse: [superView foregroundColor]
		ifTrue:	[Color black]
]

{ #category : #bordering }
View >> foregroundColor: aColor [
	borderColor := aColor
]

{ #category : #private }
View >> getController [
	"Answer the View's controller if one exists. nil indicates that the default
	controller is to be used."

	^controller
]

{ #category : #private }
View >> getViewport [
	"Answer the Rectangle representing the View's viewport (in the
	coordinate system of the superclass). If no viewport has been specified,
	the View's window transformed into the superView's coordinate system is
	saved and returned. It should be used by methods of View and subclasses
	(instead of directly referring to the viewport) unless it is known that a
	viewport actually exists. It should not be used outside of View or
	subclasses because the viewport is not sharable."

	viewport == nil ifTrue: [viewport := (self transform: self getWindow) truncated].
	^viewport
]

{ #category : #private }
View >> getWindow [
	"Answer the Rectangle that represents the window of this View. If no
	window has been specified, a default window (see View|defaultWindow)
	is created, saved, and returned. Should be used by methods of View and
	subclasses to access the View window instead of directly accessing the
	field unless it is known that a window actually exists. It is not to be used
	outside of View (or subclasses) because the window is not sharable.
	View|window should be used for outside access to the window."

	window == nil ifTrue: [self setWindow: self defaultWindow].
	^window
]

{ #category : #miscellaneous }
View >> gridSpacing [
	^ superView gridSpacing
]

{ #category : #testing }
View >> hasUnacceptedEdits [
	"Return true if this view has unaccepted edits."

	^ false

]

{ #category : #indicating }
View >> highlight [
	"Cause the inset display box (the display box excluding the border, see 
	View|insetDisplayBox) of the receiver to complement."

	Display reverse: self insetDisplayBox
]

{ #category : #'initialize-release' }
View >> initialize [
	"Initialize the state of the receiver. Subclasses should include 'super 
	initialize' when redefining this message to insure proper initialization."

	self resetSubViews.
	transformation := WindowingTransformation identity.
	self borderWidth: 0
]

{ #category : #'display box access' }
View >> insetDisplayBox [
	"Answer the receiver's inset display box. The inset display box is the 
	intersection of the receiver's window, tranformed to display coordinates, 
	and the inset display box of the superView, inset by the border width. 
	The inset display box represents the region of the display screen in 
	which the inside of the receiver (all except the border) is displayed. If 
	the receiver is totally clipped by the display screen and its superView, 
	the resulting Rectangle will be invalid."

	insetDisplayBox ifNil: [insetDisplayBox := self computeInsetDisplayBox].
	^insetDisplayBox
]

{ #category : #'window access' }
View >> insetWindow [
	"Answer a Rectangle that is obtained by insetting the receiver's window 
	rectangle by the border width."

	^self getWindow insetBy: borderWidth
]

{ #category : #bordering }
View >> insideColor: aColor [ 
	^ self backgroundColor: aColor
]

{ #category : #displaying }
View >> inspectFirstSubView [
	subViews notNil ifTrue:
		[subViews size > 0 ifTrue:
			[(subViews at: 1) inspect]]
]

{ #category : #displaying }
View >> inspectModel [
	model notNil
		ifTrue: [^ model inspect]
		ifFalse: [self flash]
]

{ #category : #displaying }
View >> inspectView [
	^self inspect
]

{ #category : #'display transformation' }
View >> inverseDisplayTransform: aPoint [ 
	"Answer a Point that is obtained from the argument, aPoint, by applying 
	to it the inverse of the receiver's display transformation. It is typically 
	used by the Controller of the receiver in order to convert a point in 
	display coordinates, such as the cursor point, to the local coordinate 
	system of the receiver."

	^self displayTransformation applyInverseTo: aPoint
]

{ #category : #private }
View >> isCyclic: aView [ 
	"Answer true if aView is the same as this View or its superView, false 
	otherwise."

	self == aView ifTrue: [^true].
	self isTopView ifTrue: [^false].
	^superView isCyclic: aView
]

{ #category : #'lock access' }
View >> isLocked [
	"Answer whether the receiver is locked. A View is 'locked' if its display 
	transformation and inset display box are defined. If these are undefined, 
	the View is 'unlocked'. The display transformation and inset display box 
	become undefined when the transformation of the View (or the 
	transformation of a View in its superView chain) is changed, or when 
	the superView of the View is changed, or any other change to the View 
	that affects the display screen coordinates of the View. The locking and 
	unlocking of a View is handled automatically by the internal methods of 
	the View, but can also be done explicitly if desired (see View|lock, and 
	View|unlock)."

	displayTransformation == nil | (insetDisplayBox == nil)
		ifTrue: [^false]
		ifFalse: [^true]
]

{ #category : #testing }
View >> isObscured [

	| topController displayRect |
	(topController := self topView controller)
		== ScheduledControllers activeController
			ifTrue: [^false].
	displayRect := self insetDisplayBox.
	ScheduledControllers scheduledControllers do: [:ctrlr |
		ctrlr == topController ifTrue: [^false].
		(displayRect intersects: ctrlr view insetDisplayBox)
			ifTrue: [^true]].
	self error: 'not in ScheduledControllers'.
	^false
]

{ #category : #'superView access' }
View >> isTopView [
	"Answer whether the receiver is a top view, that is, if it has no 
	superView."

	^superView == nil
]

{ #category : #'lock access' }
View >> isUnlocked [
	"Answer whether the receiver is unlocked. See comment in 
	View|isLocked."

	^displayTransformation == nil & (insetDisplayBox == nil)
]

{ #category : #'subView access' }
View >> lastSubView [
	"Answer the last subView in the receiver's list of subViews if it is not 
	empty, else nil."

	subViews isEmpty
		ifTrue: [^nil]
		ifFalse: [^subViews last]
]

{ #category : #'lock access' }
View >> lock [
	"'Lock' the receiver and all of its subViews (see View|isLocked). This has 
	the effect of computing and storing the display transformation (see 
	View|displayTransformation) and inset display box (see 
	View|insetDisplayBox) of the receiver and all its subViews. The locking 
	and unlocking of a View is handled automatically by the internal 
	methods of the View, but can also be done explicitly if desired."

	self isLocked ifTrue: [^self].
	displayTransformation := self computeDisplayTransformation.
	insetDisplayBox := self computeInsetDisplayBox.
	subViews do: [:aSubView | aSubView lock]
]

{ #category : #displaying }
View >> maximumSize [
	"Answer the maximum size of the receiver."

	^ 10000 @ 10000
	
]

{ #category : #displaying }
View >> minimumSize [
	"Answer the minimum size of the receiver."
	^ 10 @ 10
	
]

{ #category : #'model access' }
View >> model [
	"Answer the receiver's model."

	^model
]

{ #category : #'model access' }
View >> model: aModel [ 
	"Set the receiver's model to aModel. The model of the receiver's controller 
	is also set to aModel."

	self model: aModel controller: controller
]

{ #category : #'controller access' }
View >> model: aModel controller: aController [ 
	"Set the receiver's model to aModel, add the receiver to aModel's list of 
	dependents, and set the receiver's controller to aController. Subsequent 
	changes to aModel (see Model|change) will result in View|update: 
	messages being sent to the receiver. #NoControllerAllowed for the value 
	of aController indicates that no default controller is available; nil for the 
	value of aController indicates that the default controller is to be used 
	when needed. If aController is neither #NoControllerAllowed nor nil, its 
	view is set to the receiver and its model is set to aModel."

	model ~~ nil & (model ~~ aModel)
		ifTrue: [model removeDependent: self].
	aModel ~~ nil & (aModel ~~ model)
		ifTrue: [aModel addDependent: self].
	model := aModel.
	aController ~~ nil
		ifTrue: 
			[aController view: self.
			aController model: aModel].
	controller := aController.
	
	self setDefaultForegroundColor.
	self setDefaultBackgroundColor.
]

{ #category : #miscellaneous }
View >> nestedViewport [

	"The viewport size used to control scaling of nested user views."

	^ (0@0 extent: self viewport extent)
			insetBy: 16 @ 16
]

{ #category : #miscellaneous }
View >> printViewSpecOn: strm nested: level [
	"Print window and viewport specs
	of this and all nested views."
	strm crtab: level; nextPutAll: self class name.
	strm crtab: level; nextPutAll: 'window: '; print: self window.
	strm crtab: level; nextPutAll: 'viewport: '; print: self viewport.
	strm crtab: level; nextPutAll: 'displayBox: '; print: self displayBox.
	strm crtab: level; nextPutAll: 'border: '; print: self borderWidth.
	subViews do: [:v | v printViewSpecOn: strm nested: level+1]
]

{ #category : #'initialize-release' }
View >> release [
	"Remove the receiver from its model's list of dependents (if the model
	exists), and release all of its subViews. It is used to break possible cycles
	in the receiver and should be sent when the receiver is no longer needed.
	Subclasses should include 'super release.' when redefining release."

	model removeDependent: self.
	model := nil.
	controller release.
	controller := nil.
	subViews ~~ nil ifTrue: [subViews do: [:aView | aView release]].
	subViews := nil.
	superView := nil
]

{ #category : #'subView removing' }
View >> releaseSubView: aView [ 
	"Delete aView from the receiver's list of subViews and send it the 
	message 'release' (so that it can break up cycles with subViews, etc.)."

	self removeSubView: aView.
	aView release
]

{ #category : #'subView removing' }
View >> releaseSubViews [
	"Release (see View|releaseSubView:) all subViews in the receiver's list of 
	subViews."

	subViews do: [:aView | aView release].
	self resetSubViews
]

{ #category : #'subView removing' }
View >> removeFromSuperView [
	"Delete the receiver from its superView's collection of subViews."

	superView ~= nil ifTrue: [superView removeSubView: self]
]

{ #category : #'subView removing' }
View >> removeSubView: aView [ 
	"Delete aView from the receiver's list of subViews. If the list of subViews 
	does not contain aView, create an error notification."

	subViews remove: aView.
	aView superView: nil.
	aView unlock
]

{ #category : #'subView removing' }
View >> removeSubViews [
	"Delete all the receiver's subViews."

	subViews do: 
		[:aView | 
		aView superView: nil.
		aView unlock].
	self resetSubViews
]

{ #category : #'subView access' }
View >> resetSubViews [
	"Set the list of subviews to an empty collection."
	
	subViews := OrderedCollection new
]

{ #category : #transforming }
View >> scale: aScale translation: aTranslation [ 
	"The x component of aScale (a Point) specifies the scale (translation) in 
	the x direction; the y component specifies the scale (translation) in the y 
	direction. aScale can optionally be an instance of Integer or Float in 
	order to specify uniform scaling in both directions. Create a new local 
	transformation for the receiver with a scale factor of aScale and a 
	translation offset of aTranslation. When the transformation is applied (see 
	View|transform:), the scale is applied first, followed by the translation. It 
	is typically used when building a superView from its subViews in order 
	to line up the viewports of the subViews in the desired way. If no 
	scaling is required between subView and superView, then 
	View|align:with: is often more convenient to use."

	self setTransformation:
		(WindowingTransformation scale: aScale translation: aTranslation)
]

{ #category : #transforming }
View >> scaleBy: aScale [ 
	"The x component of aScale (a Point) specifies the scale in the x 
	direction; the y component specifies the scale in the y direction. aScale 
	can, optionally, be an instance of Integer or Float in order to specify 
	uniform scaling in both directions. Scales the View by aScale. The scale 
	is concatenated with the current transformation of the receiver and is 
	applied when View|transform is sent. This happens automatically in the 
	process of displaying the receiver, for example."

	self setTransformation: (transformation scaleBy: aScale)
]

{ #category : #scrolling }
View >> scrollBy: aPoint [ 
	"The x component of aPoint specifies the amount of scrolling in the x 
	direction; the y component specifies the amount of scrolling in the y 
	direction. The amounts are specified in the receiver's local coordinate 
	system. Scroll the receiver up or down, left or right. The window of the 
	receiver is kept stationary and the subViews and other objects in the 
	receiver are translated relative to it. Scrolling doesn't change the 
	insetDisplayBox or the viewport since the change in the transformation 
	is canceled by the change in the window. In other words, all display 
	objects in the view, except the window, are translated by the scrolling 
	operation.
	Note: subclasses may override to return false if no scrolling takes place."

	| aRectangle |
	aRectangle := insetDisplayBox.
	transformation := transformation scrollBy: aPoint.
	window := self getWindow translateBy: aPoint x negated @ aPoint y negated.
	self unlock.
	insetDisplayBox := aRectangle.
	^ true
]

{ #category : #'morphic compatibility' }
View >> setBalloonText: aString [

	self flag: #deprecated. "mt: Use #balloonText: or just remove."
]

{ #category : #'initialize-release' }
View >> setDefaultBackgroundColor [
	"Obtain the background color from the receiver's model.
	The preferences make sure whether this is a colorful or uniform
	look."

	self backgroundColor: self defaultBackgroundColor
]

{ #category : #'initialize-release' }
View >> setDefaultForegroundColor [

	self foregroundColor: self defaultForegroundColor
]

{ #category : #private }
View >> setTransformation: aTransformation [ 
	"Set the View's local transformation to aTransformation, unlock the View 
	(see View|unlock), and set the viewport to undefined (this forces it to be 
	recomputed when needed). Should be used instead of setting the 
	transformation directly."

	transformation := aTransformation.
	self unlock.
	viewport := nil
]

{ #category : #private }
View >> setWindow: aWindow [ 
	"Set the View's window to aWindow and unlock the View (see
	View|unlock). View|setWindow should be used by methods of View and
	subclasses to set the View window (rather than directly setting the
	instance variable) to insure that the View is unlocked."

	window := aWindow.
	viewport := nil.
	self unlock
]

{ #category : #miscellaneous }
View >> stretchFrame: newFrameBlock startingWith: startFrame [ 
	"Track the outline of a newFrame as long as mouse drags it.
	Maintain max and min constraints throughout the drag"
	| frame newFrame click delay |
	delay := Delay forMilliseconds: 10.
	frame := startFrame origin extent: ((startFrame extent min: self maximumSize)
											max: self minimumSize).
	Display border: frame width: 2 rule: Form reverse fillColor: Color gray.
	click := false.
	[click and: [Sensor noButtonPressed]] whileFalse: 
		[delay wait.
		click := click | Sensor anyButtonPressed.
		newFrame := newFrameBlock value: frame.
		newFrame := newFrame topLeft extent: ((newFrame extent min: self maximumSize)
											max: self minimumSize).
		newFrame = frame ifFalse:
			[Display border: frame width: 2 rule: Form reverse fillColor: Color gray.
			Display border: newFrame width: 2 rule: Form reverse fillColor: Color gray.
			frame := newFrame]].
	Display border: frame width: 2 rule: Form reverse fillColor: Color gray.
	^ frame
]

{ #category : #'subView access' }
View >> subViewContaining: aPoint [ 
	"Answer the first subView that contains aPoint within its window and 
	answer nil, otherwise. It is typically sent from a Controller in order to 
	determine where to pass control (usually to the Controller of the View 
	returned by View|subViewContaining:)."

	subViews reverseDo: 
		[:aSubView | 
		(aSubView displayBox containsPoint: aPoint) ifTrue: [^aSubView]].
	^nil
]

{ #category : #'subView access' }
View >> subViewSatisfying: aBlock [
	"Return the first subview that satisfies aBlock, or nil if none does.  1/31/96 sw"

	^subViews detect: aBlock ifNone: [ nil ]
]

{ #category : #'basic control sequence' }
View >> subViewWantingControl [
	"Answer the first subView that has a controller that now wants control."

	subViews reverseDo: 
		[:aSubView | aSubView controller isControlWanted ifTrue: [^aSubView]].
	^nil
]

{ #category : #'subView access' }
View >> subViews [
	"Answer the receiver's collection of subViews."

	^subViews
]

{ #category : #'superView access' }
View >> superView [
	"Answer the superView of the receiver."

	^superView
]

{ #category : #private }
View >> superView: aView [ 
	"Set the View's superView to aView and unlock the View (see
	View|unlock). It is sent by View|addSubView: in order to properly set all
	the links."

	superView := aView.
	self unlock
]

{ #category : #'subView access' }
View >> textEditorView [
	"Return the first view in the receiver whose controller is a ParagraphEdior, or nil if none.  1/31/96 sw"

	(controller isKindOf: ParagraphEditor) ifTrue: [^ self].
	^ self subViewSatisfying:
		[:v | v textEditorView ~~ nil]
]

{ #category : #'superView access' }
View >> topView [
	"Answer the root of the tree of Views in which the receiver is a node. 
	The root of the tree is found by going up the superView path until 
	reaching a View whose superView is nil."

	superView == nil
		ifTrue: [^self]
		ifFalse: [^superView topView]
]

{ #category : #transforming }
View >> transform: anObject [ 
	"Apply the local transformation of the receiver to anObject and answer 
	the resulting transformation. It is used to get the superView coordinates 
	of an object. For example, the viewport is equal to the window 
	transformed."

	^transformation applyTo: anObject
]

{ #category : #transforming }
View >> transformation [
	"Answer a copy of the receiver's local transformation."

	^transformation copy
]

{ #category : #transforming }
View >> transformation: aTransformation [ 
	"Set the receiver's local transformation to a copy of aTransformation, 
	unlock the receiver (see View|unlock) and set the viewport to undefined 
	(this forces it to be recomputed when needed)."

	self setTransformation: aTransformation copy
]

{ #category : #transforming }
View >> translateBy: aPoint [ 
	"Translate the receiver by aPoint. The translation is concatenated with 
	the current transformation of the receiver and is applied when 
	View|transform is sent. This happens automatically in the process of 
	displaying the receiver."

	self setTransformation: (transformation translateBy: aPoint)
]

{ #category : #'lock access' }
View >> unlock [
	"Unlock the receiver and all of its subViews (see View|isUnlocked). This 
	has the effect of forcing the display transformation (see 
	View|displayTransformation) and inset display box (see 
	View|insetDisplayBox) of the receiver and all its subViews to be 
	recomputed the next time they are referenced. The locking and 
	unlocking of a View is handled automatically by the internal methods of 
	the View, but can also be done explicitly if desired."

	self isUnlocked ifTrue: [^self].
	displayTransformation := nil.
	insetDisplayBox := nil.
	subViews do: [:aSubView | aSubView unlock]
]

{ #category : #updating }
View >> update [
	"Normally sent by the receiver's model in order to notify the receiver of 
	a change in the model's state. Subclasses implement this message to do 
	particular update actions. A typical action that might be required is to 
	redisplay the receiver."

	self update: self
]

{ #category : #updating }
View >> update: aParameter [ 
	"Normally sent by the receiver's model in order to notify the receiver of 
	a change in the model's state. Subclasses implement this message to do 
	particular update actions. A typical action that might be required is to 
	redisplay the receiver."

	^self
]

{ #category : #'viewport access' }
View >> viewport [
	"Answer a copy of the receiver's viewport."

	^self getViewport copy
]

{ #category : #'window access' }
View >> window [
	"Answer a copy of the receiver's window."

	^self getWindow copy
]

{ #category : #'window access' }
View >> window: aWindow [ 
	"Set the receiver's window to a copy of aWindow."

	self setWindow: aWindow copy
]

{ #category : #transforming }
View >> window: aWindow viewport: aViewport [ 
	"Set the receiver's window to aWindow, set its viewport to aViewport, and 
	create a new local transformation for the receiver based on aWindow and 
	aViewport. The receiver is scaled and translated so that aWindow, when 
	transformed, coincides with aViewport. It is used to position a subView's 
	window within some specific region of its superView's area. For example, 
	'subView window: aRectangle1 viewport: aRectangle2' sets subView's 
	window to aRectangle1, its viewport to aRectangle2, and its local 
	transformation to one that transforms aRectangle1 to aRectange2."

	self window: aWindow.
	self setTransformation:
		(WindowingTransformation window: aWindow viewport: aViewport).
	self getViewport
]
