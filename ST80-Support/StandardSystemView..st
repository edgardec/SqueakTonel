"
I represent a view that has a label above its top left corner. The text in the label identifies the kind of view. In addition to a label, I add control over the maximum and minimum size of the display box of my instance. My default controller is StandardSystemController. The elements of ScheduledControllers, the sole instance of ControlManager, are usually controllers for instances of me.
"
Class {
	#name : #StandardSystemView,
	#superclass : #View,
	#instVars : [
		'labelFrame',
		'labelText',
		'isLabelComplemented',
		'savedSubViews',
		'minimumSize',
		'maximumSize',
		'collapsedViewport',
		'expandedViewport',
		'labelBits',
		'windowBits',
		'bitsValid',
		'updatablePanes'
	],
	#classVars : [
		'CacheBits'
	],
	#category : #'ST80-Support'
}

{ #category : #'class initialization' }
StandardSystemView class >> cachingBits [
	^ CacheBits
]

{ #category : #'class initialization' }
StandardSystemView class >> doCacheBits [
	"StandardSystemView doCacheBits - Enable fast window repaint feature"
	CacheBits := true.
	ScheduledControllers ifNotNil: [:sc | sc unCacheWindows; restore]
]

{ #category : #'class initialization' }
StandardSystemView class >> dontCacheBits [
	"StandardSystemView dontCacheBits - Disable fast window repaint feature.
	Return true iff bits were cached, ie if space was been recovered"
	CacheBits ifFalse: [^ false].
	CacheBits := false.
	ScheduledControllers unCacheWindows.
	^ true
]

{ #category : #'class initialization' }
StandardSystemView class >> initialize [		"StandardSystemView initialize"
	self doCacheBits.
]

{ #category : #'class initialization' }
StandardSystemView class >> standardLabelStyle [

	^ (TextStyle fontArray: { Preferences windowTitleFont })
			gridForFont: 1 withLead: 0;
			yourself
]

{ #category : #displaying }
StandardSystemView >> cacheBits [
	| oldLabelState |
	CacheBits ifFalse: [^ self uncacheBits].
	(oldLabelState := isLabelComplemented) ifTrue: [ self deEmphasize ].
	self cacheBitsAsIs.
	(isLabelComplemented := oldLabelState) ifTrue: [ self emphasize ].

]

{ #category : #displaying }
StandardSystemView >> cacheBitsAsIs [

	CacheBits ifFalse: [^ self uncacheBits].
	windowBits := Form fromDisplay: self windowBox using: windowBits.
	bitsValid := true.

]

{ #category : #framing }
StandardSystemView >> chooseCollapsePoint [
	"Answer the point at which to place the collapsed window."
	| pt labelForm beenDown offset |
	labelForm := Form fromDisplay: self labelDisplayBox.
	self uncacheBits.
	self erase.
	beenDown := Sensor anyButtonPressed.
	self isCollapsed ifTrue:
		[offset := self labelDisplayBox topLeft - self growBoxFrame topLeft.
		labelForm follow: [pt := (Sensor cursorPoint + offset max: 0@0) truncateTo: 8]
				while: [Sensor anyButtonPressed
							ifTrue: [beenDown := true]
							ifFalse: [beenDown not]].
		^ pt].
	^ (RealEstateAgent assignCollapseFrameFor: self) origin.

]

{ #category : #framing }
StandardSystemView >> chooseFrame [
	"Answer a new frame, depending on whether the view is currently 
	collapsed or not."
	| labelForm f |
	self isCollapsed & expandedViewport notNil
		ifTrue:
			[labelForm := bitsValid
				ifTrue: [windowBits]
				ifFalse: [Form fromDisplay: self labelDisplayBox].
			bitsValid := false.
			self erase.
			labelForm slideFrom: self labelDisplayBox origin
					to: expandedViewport origin-self labelOffset
					nSteps: 10.
			^ expandedViewport]
		ifFalse:
			[f := self getFrame.
			bitsValid := false.
			self erase.
			^ f topLeft + self labelOffset extent: f extent]
]

{ #category : #framing }
StandardSystemView >> chooseMoveRectangle [
	"Ask the user to designate a new window rectangle."
	| offset |
	offset := Sensor anyButtonPressed "Offset if draggin, eg, label"
		ifTrue: [self windowBox topLeft - Sensor cursorPoint]
		ifFalse: [0@0].
	self isCollapsed
		ifTrue: [^ self labelDisplayBox newRectFrom:
					[:f | | p |
					p := Sensor cursorPoint + offset.
					p := (p max: 0@0) truncateTo: 8.
					p extent: f extent]]
		ifFalse: [^ self windowBox newRectFrom:
					[:f | | p |
					p := Sensor cursorPoint + offset.
					self constrainFrame: (p extent: f extent)]]
]

{ #category : #'clipping box access' }
StandardSystemView >> clippingBox [
	"Answer the rectangular area in which the receiver can show its label."

	^self isTopView
		ifTrue: [self labelDisplayBox]
		ifFalse: [super insetDisplayBox]
]

{ #category : #'label access' }
StandardSystemView >> closeBoxFrame [
	^ Rectangle origin: (self labelDisplayBox leftCenter + (10 @ -5)) extent: (11 @ 11)
]

{ #category : #framing }
StandardSystemView >> collapse [
	"If the receiver is not already collapsed, change its view to be that of its 
	label only."

	self isCollapsed ifFalse:
			[model modelSleep.
			expandedViewport := self viewport.
			savedSubViews := subViews.
			self resetSubViews.
			labelText isNil ifTrue: [self label: nil.  bitsValid := false.].
			self window: (self inverseDisplayTransform:
					((self labelDisplayBox topLeft extent: (labelText extent x + 70) @ self labelHeight)
						 intersect: self labelDisplayBox))]
]

{ #category : #framing }
StandardSystemView >> collapseToPoint: collapsePoint [
	self collapse.
	self align: self displayBox topLeft with: collapsePoint.
	collapsedViewport := self viewport.
	self displayEmphasized
]

{ #category : #framing }
StandardSystemView >> collapsedFrame [
	"Answer the rectangle occupied by this window when collapsed."
	^ collapsedViewport  "NOTE may be nil"
]

{ #category : #'clipping box access' }
StandardSystemView >> constrainFrame: aRectangle [
	"Constrain aRectangle, to the minimum and maximum size
	for this window"

   | adjustmentForLabel |
   adjustmentForLabel := 0 @ (labelFrame height  - labelFrame borderWidth).
	^ aRectangle origin extent:
		((aRectangle extent max: minimumSize + adjustmentForLabel)
		      min: maximumSize + adjustmentForLabel).
]

{ #category : #testing }
StandardSystemView >> containsPoint: aPoint [ 
	"Refer to the comment in View|containsPoint:."

	^(super containsPoint: aPoint) | (self labelContainsPoint: aPoint)
]

{ #category : #'object fileIn' }
StandardSystemView >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	updatablePanes ifNil: [updatablePanes := #()].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #displaying }
StandardSystemView >> deEmphasizeForDebugger [
	"Carefully de-emphasis this window because a debugger is being opened. Care must be taken to avoid invoking potentially buggy window display code that could cause a recursive chain of errors eventually resulting in a virtual machine crash. In particular, do not de-emphasize the subviews."

	self deEmphasizeView.  "de-emphasize this top-level view"
	self uncacheBits.
	Smalltalk garbageCollectMost > 1000000 ifTrue: [
		"if there is enough space, cache current window screen bits"
		self cacheBitsAsIs].

]

{ #category : #displaying }
StandardSystemView >> deEmphasizeLabel [
	"Un-Highlight the label."
	labelFrame height = 0 ifTrue: [^ self].  "no label"
	self displayLabelBackground: false.
	self displayLabelText.
]

{ #category : #deEmphasizing }
StandardSystemView >> deEmphasizeView [ 
	"Refer to the comment in View|deEmphasizeView."

	isLabelComplemented ifTrue:
		[self deEmphasizeLabel.
		isLabelComplemented := false]
]

{ #category : #'initialize-release' }
StandardSystemView >> defaultBackgroundColor [

	^ model
		ifNil: [Color white]
		ifNotNil: [:m | m windowColorToUse]
]

{ #category : #'controller access' }
StandardSystemView >> defaultControllerClass [ 
	"Refer to the comment in View|defaultControllerClass."

	^StandardSystemController
]

{ #category : #'initialize-release' }
StandardSystemView >> defaultForegroundColor [

	^ (self userInterfaceTheme borderColorModifier ifNil: [ [:c | c adjustBrightness: -0.5] ]) value: self defaultBackgroundColor
]

{ #category : #displaying }
StandardSystemView >> display [
	isLabelComplemented
		ifTrue: [self displayEmphasized]
		ifFalse: [self displayDeEmphasized]
]

{ #category : #displaying }
StandardSystemView >> displayDeEmphasized [ 
	"Display this view with emphasis off.
	If windowBits is not nil, then simply BLT if possible,
		but force full display for top window so color is preserved."
	(bitsValid and: [controller ~~ ScheduledControllers activeController])
		ifTrue: [self lock.
				windowBits displayAt: self windowOrigin]
		ifFalse: [Display deferUpdates: true.
				super display.
				Display deferUpdates: false; forceToScreen: self windowBox.
				CacheBits ifTrue: [self cacheBitsAsIs]]

]

{ #category : #displaying }
StandardSystemView >> displayEmphasized [
	"Display with label highlighted to indicate that it is active."

	self displayDeEmphasized; emphasize.
	isLabelComplemented := true
]

{ #category : #displaying }
StandardSystemView >> displayLabelBackground: emphasized [
	"Clear or emphasize the inner region of the label"
	| r1 r2 r3 c3 c2 c1 |
	emphasized ifFalse:
		["Just clear the label if not emphasized"
		^ Display fill: (self labelDisplayBox insetBy: 2) fillColor: self labelColor].
	r1 := self labelDisplayBox insetBy: 2.
	r2 := r1 insetBy: 0@2.
	r3 := r2 insetBy: 0@3.
	c3 := self labelColor.
	c2 := c3 dansDarker.
	c1 := c2 dansDarker.
	Display fill: r1 fillColor: c1.
	Display fill: r2 fillColor: c2.
	Display fill: r3 fillColor: c3.
 
"	Here is the Mac racing stripe code
	stripes := Bitmap with: (self labelColor pixelWordForDepth: Display depth)
					with: (Form black pixelWordForDepth: Display depth).
	self windowOrigin y even ifTrue: [stripes swap: 1 with: 2].
	Display fill: (self labelDisplayBox insetBy: 3) fillColor: stripes.
"
]

{ #category : #displaying }
StandardSystemView >> displayLabelBoxes [
	"closeBox, growBox."
	| aRect smallRect backColor |
	aRect := self closeBoxFrame.
	backColor := self labelColor.
	Display fill: (aRect insetBy: -2) fillColor: backColor.
	Display fillBlack: aRect.
	Display fill: (aRect insetBy: 1) fillColor: backColor.

	aRect := self growBoxFrame.
	smallRect := aRect origin extent: 7@7.
	Display fill: (aRect insetBy: -2) fillColor: backColor.
	aRect := aRect insetOriginBy: 2@2 cornerBy: 0@0.
	Display fillBlack: aRect.
	Display fill: (aRect insetBy: 1) fillColor: backColor.
	Display fillBlack: smallRect.
	Display fill: (smallRect insetBy: 1) fillColor: backColor
]

{ #category : #displaying }
StandardSystemView >> displayLabelText [
	"The label goes in the center of the window"
	| labelRect |
	labelText foregroundColor: self foregroundColor
			backgroundColor: self labelColor.
	labelRect := self labelTextRegion.
	Display fill: (labelRect expandBy: 3@0) fillColor: self labelColor.
	labelText displayOn: Display at: labelRect topLeft clippingBox: labelRect
			rule: labelText rule fillColor: labelText fillColor.
	labelText destinationForm: nil
]

{ #category : #displaying }
StandardSystemView >> displayOn: aPort [
	bitsValid ifFalse:
		[^ Display clippingTo: aPort clipRect do: [super display]].
	windowBits displayOnPort: aPort at: self windowOrigin
]

{ #category : #displaying }
StandardSystemView >> displayRacingStripes [
	"Display Racing Stripes in the label"
	| labelDisplayBox stripes top bottom left box right |
	labelDisplayBox := self labelDisplayBox.
	top := labelDisplayBox top + 3.
	bottom := labelDisplayBox bottom - 3.
	stripes := Bitmap with: (Display pixelWordFor: self labelColor)
			with: (Display pixelWordFor: Color black).
	top even ifFalse: [stripes swap: 1 with: 2].

	left := labelDisplayBox left + 3.

	box := self closeBoxFrame.
	right := box left - 2.
	Display fill: (Rectangle left: left right: right top: top bottom: bottom)
			fillColor: stripes.
	left := box right + 2.

	box := self labelTextRegion.
	right := box left - 3.
	Display fill: (Rectangle left: left right: right top: top bottom: bottom)
			fillColor: stripes.
	left := box right + 2.

	box := self growBoxFrame.
	right := box left - 2.
	Display fill: (Rectangle left: left right: right top: top bottom: bottom)
			fillColor: stripes.
	left := box right + 2.

	right := labelDisplayBox right - 3.
	Display fill: (Rectangle left: left right: right top: top bottom: bottom)
			fillColor: stripes.

]

{ #category : #displaying }
StandardSystemView >> displayView [
	"Refer to the comment in View|displayView. "
	labelFrame height = 0 ifTrue: [^ self].  "no label"
	self displayBox width = labelFrame width ifFalse:
		["recompute label width when window changes size"
		self setLabelRegion].
	(labelFrame align: labelFrame topLeft with: self windowOrigin)
		insideColor: self labelColor;
		displayOn: Display.
	self displayLabelText
]

{ #category : #displaying }
StandardSystemView >> emphasizeLabel [
	"Highlight the label."
	labelFrame height = 0 ifTrue: [^ self].  "no label"
	self displayLabelBackground: true.
	self displayLabelBoxes.
	self displayLabelText.
]

{ #category : #deEmphasizing }
StandardSystemView >> emphasizeView [ 
	"Refer to the comment in View|emphasizeView."

	self emphasizeLabel
]

{ #category : #displaying }
StandardSystemView >> erase [
	"Clear the display box of the receiver to be gray, as the screen background."
	| oldValid |
	CacheBits
		ifTrue:
			[oldValid := bitsValid.
			bitsValid := false.
			ScheduledControllers restore: self windowBox without: self.
			bitsValid := oldValid]
		ifFalse:
			[ScheduledControllers restore: self windowBox without: self]
]

{ #category : #framing }
StandardSystemView >> expand [
	"If the receiver is collapsed, change its view to be that of all of its subviews, not its label alone."
	| newFrame |
	self isCollapsed
		ifTrue:
			[newFrame := self chooseFrame expandBy: borderWidth.
			collapsedViewport := self viewport.
			subViews := savedSubViews.
			labelFrame borderWidthLeft: 2 right: 2 top: 2 bottom: 2.
			savedSubViews := nil.
			self setWindow: nil.
			self resizeTo: newFrame.
			self displayDeEmphasized.
			model modelWakeUpIn: self]
]

{ #category : #framing }
StandardSystemView >> expandedFrame [
	"Answer the rectangle occupied by this window when expanded."
	^ expandedViewport  "NOTE may be nil"
]

{ #category : #framing }
StandardSystemView >> fullScreen [
	"Expand the receiver to fill the screen.  Let the model decide how big is full -- allows for flop-out scrollbar on left if desired"

	self isCollapsed ifFalse:
		[self reframeTo: model fullScreenSize]
]

{ #category : #framing }
StandardSystemView >> getFrame [
	"Ask the user to designate a rectangular area in which
	the receiver should be displayed."
	| minFrame |
	minFrame := Cursor origin showWhile: 
		[(Sensor cursorPoint extent: self minimumSize) newRectFrom:
			[:f | Sensor cursorPoint extent: self minimumSize]].
	self maximumSize <= self minimumSize ifTrue: [^ minFrame].
	^ Cursor corner showWhile:
		[minFrame newRectFrom:
			[:f | self constrainFrame: (f origin corner: Sensor cursorPoint)]]
]

{ #category : #'label access' }
StandardSystemView >> growBoxFrame [
	^ Rectangle origin: (self labelDisplayBox rightCenter + (-22 @ -5)) extent: (11 @ 11)
]

{ #category : #framing }
StandardSystemView >> initialExtent [
	"Answer the desired extent for the receiver when it is first opened on the screen.  "

	^ model initialExtent min: maximumSize max: minimumSize
]

{ #category : #framing }
StandardSystemView >> initialFrame [
        "Find a plausible initial screen area for the receiver, taking into account user preference, the size needed, and other windows currently on the screen.  5/22/96 sw: let RealEstateAgent do it for us"

        ^ RealEstateAgent initialFrameFor: self world: nil
]

{ #category : #'initialize-release' }
StandardSystemView >> initialize [ 
	"Refer to the comment in View|initialize."
	super initialize.
	labelFrame := Quadrangle new.
	labelFrame region: (Rectangle origin: 0 @ 0 extent: 50 @ self labelHeight).
	labelFrame borderWidthLeft: 2 right: 2 top: 2 bottom: 2.
	self label: nil.
	isLabelComplemented := false.
	minimumSize := 50 @ 50.
	maximumSize := Display extent.
	collapsedViewport := nil.
	expandedViewport := nil.
	bitsValid := false.
	updatablePanes := #()
]

{ #category : #testing }
StandardSystemView >> isCollapsed [
	"Answer whether the receiver is collapsed (true) or expanded (false)."

	^savedSubViews ~~ nil
]

{ #category : #testing }
StandardSystemView >> isWindowForModel: aModel [
	"Return true if the receiver acts as the window for the given model"
	^aModel == self model
]

{ #category : #'label access' }
StandardSystemView >> label [
	"Answer the string that appears in the receiver's label."
	labelText isNil
		ifTrue: [^ 'Untitled' copy]
		ifFalse: [^ labelText asString]
]

{ #category : #'label access' }
StandardSystemView >> label: aString [ 
	"Set aString to be the receiver's label."
	labelText := Paragraph
			withText: (Text fromString: ((aString == nil or: [aString isEmpty])
								ifTrue: ['Untitled' copy]
								ifFalse: [aString]))
			style: self class standardLabelStyle.
	insetDisplayBox == nil ifTrue: [^ self].  "wait for further initialization"
	self setLabelRegion
]

{ #category : #'label access' }
StandardSystemView >> labelColor [
	"Answer the color to use as the background for the receiver's label.  By default, this is the same as the background color of the window, but need not be.  7/16/96 sw"

	^ self backgroundColor
]

{ #category : #testing }
StandardSystemView >> labelContainsPoint: aPoint [ 
	"Answer TRUE if aPoint is in the label box."

	^self labelDisplayBox containsPoint: aPoint
]

{ #category : #'label access' }
StandardSystemView >> labelDisplayBox [
	"Answer the rectangle that borders the visible parts of the receiver's label 
	on the display screen."

	^ labelFrame region
		align: labelFrame topLeft
		with: self windowOrigin
]

{ #category : #'label access' }
StandardSystemView >> labelFrame [
	^labelFrame
]

{ #category : #'label access' }
StandardSystemView >> labelHeight [
	^ ((self class standardLabelStyle fontAt: 1) height + 4) max: 20
]

{ #category : #'label access' }
StandardSystemView >> labelOffset [
	^ 0 @ (self labelHeight-2)
]

{ #category : #'label access' }
StandardSystemView >> labelText [
	^labelText
]

{ #category : #'label access' }
StandardSystemView >> labelTextRegion [
	labelText == nil ifTrue: [^ self labelDisplayBox center extent: 0@0].
	^ (labelText boundingBox
			align: labelText boundingBox center
			with: self labelDisplayBox center)
		intersect: (self labelDisplayBox insetBy: 35@0)
]

{ #category : #displaying }
StandardSystemView >> makeMeVisible [

        | newLoc portRect |
        ((Display boundingBox insetBy: (0@0 corner: self labelHeight asPoint))
                containsPoint: self displayBox topLeft) ifTrue: [^ self "OK -- my top left is visible"].

        "window not on screen (probably due to reframe) -- move it now"
        newLoc := self isCollapsed
                ifTrue: [RealEstateAgent assignCollapsePointFor: self]
                ifFalse: [(RealEstateAgent initialFrameFor: self world: nil) topLeft].
        portRect := newLoc + self labelOffset
                                extent: self windowBox extent - self labelOffset.
        self resizeTo: portRect.
        self setLabelRegion.

]

{ #category : #size }
StandardSystemView >> maximumSize [
	"Answer a point representing the maximum width and height of the 
	receiver."

	^maximumSize
]

{ #category : #size }
StandardSystemView >> maximumSize: aPoint [ 
	"Set the argument, aPoint, to be the maximum width and height of the 
	receiver."

	maximumSize := aPoint
]

{ #category : #size }
StandardSystemView >> minimumSize [
	"Answer a point representing the minimum width and height of the 
	receiver."

	^minimumSize
]

{ #category : #size }
StandardSystemView >> minimumSize: aPoint [ 
	"Set the argument, aPoint, to be the minimum width and height of the 
	receiver."

	minimumSize := aPoint
]

{ #category : #framing }
StandardSystemView >> moved [
	"The user has moved the receiver; after a new view rectangle is chosen, this method is called to allow certain views to take note of the change.  6/10/96 sw" 
]

{ #category : #framing }
StandardSystemView >> newFrame: frameChangeBlock [
	self reframeTo: (self windowBox newRectFrom:
		[:f | self constrainFrame: (frameChangeBlock value: f)])
]

{ #category : #'label access' }
StandardSystemView >> noLabel [
	"A label of zero height indicates no label"
	labelFrame height > 0
		ifTrue: [labelFrame region: (labelFrame bottomLeft + (0@1) extent: labelFrame width@0).
				labelFrame borderWidth: 0.
				self uncacheBits]
]

{ #category : #framing }
StandardSystemView >> reframePanesAdjoining: subView along: side to: aDisplayBox [ 
	| delta newRect minDim theMin |
	newRect := aDisplayBox.
	theMin := 16.
	"First check that this won't make any pane smaller than theMin screen dots"
	minDim := ((subViews select: [:sub | sub displayBox bordersOn: subView displayBox along: side])
		collect: [:sub | sub displayBox adjustTo: newRect along: side])
			inject: 999 into: [:was :rect | (was min: rect width) min: rect height].
	"If so, amend newRect as required"
	minDim < theMin ifTrue:
		[delta := minDim - theMin.
		newRect := newRect withSide: side setTo: 
				((newRect perform: side) > (subView displayBox perform: side)
					ifTrue: [(newRect perform: side) + delta]
					ifFalse: [(newRect perform: side) - delta])].
	"Now adjust all adjoining panes for real"
	subViews do:
		[:sub | (sub displayBox bordersOn: subView displayBox along: side) ifTrue:
			[| newBox |
			newBox := sub displayBox adjustTo: newRect along: side.
			sub window: sub window viewport:
				(sub transform: (sub inverseDisplayTransform: newBox)) rounded]].
	"And adjust the growing pane itself"
	subView window: subView window viewport:
			(subView transform: (subView inverseDisplayTransform: newRect)) rounded.

	"Finally force a recomposition of the whole window"
	viewport := nil.
	self resizeTo: self viewport.
	self uncacheBits; displayEmphasized
]

{ #category : #framing }
StandardSystemView >> reframeTo: newFrame [
	"Reframe the receiver to the given screen rectangle.  
	Repaint difference after the change.  "
	| oldBox newBox portRect |
	self uncacheBits.
	oldBox := self windowBox.
	portRect := newFrame topLeft + self labelOffset
				corner: newFrame corner.
	self setWindow: nil.
	self resizeTo: portRect.
	self setLabelRegion.
	newBox := self windowBox.
	(oldBox areasOutside: newBox) do:
		[:rect | ScheduledControllers restore: rect].
	self displayEmphasized
]

{ #category : #'label access' }
StandardSystemView >> relabel: aString [ 
	"A new string for the label.  Window is assumed to be active.
	Window will redisplay only if label bar has to grow."
	| oldRegion oldWidth |
	(model windowReqNewLabel: aString) ifFalse: [^ self].
	oldRegion := self labelTextRegion.
	oldWidth := self insetDisplayBox width.
	self label: aString.
	Display fill: ((oldRegion merge: self labelTextRegion) expandBy: 3@0)
			fillColor: self labelColor.
	self insetDisplayBox width = oldWidth
		ifTrue: [self displayLabelText; emphasizeLabel]
		ifFalse: [self uncacheBits; displayEmphasized].

]

{ #category : #'initialize-release' }
StandardSystemView >> release [

	model windowIsClosing; release.
	self isCollapsed ifTrue: [savedSubViews do: [:v | v release]].
	super release.

]

{ #category : #framing }
StandardSystemView >> resize [
	"Determine the rectangular area for the receiver, adjusted to the 
	minimum and maximum sizes."
	| f |
	f := self getFrame.
	self resizeTo: (f topLeft + self labelOffset extent: f extent)

]

{ #category : #framing }
StandardSystemView >> resizeInitially [
	"Determine the rectangular area for the receiver, adjusted to the 
	minimum and maximum sizes."
	self resizeTo: self initialFrame

]

{ #category : #framing }
StandardSystemView >> resizeMinimumCenteredAt: aPoint [ 
	"Determine the rectangular area for the receiver, adjusted so that it is 
	centered a position, aPoint."
	| aRectangle |
	aRectangle := 0 @ 0 extent: self minimumSize.
	aRectangle := aRectangle align: aRectangle center with: aPoint.
	self resizeTo: aRectangle
]

{ #category : #framing }
StandardSystemView >> resizeTo: aRectangle [
	"Resize this view to aRectangle"

	"First get scaling right inside borders"
	self window: (self window insetBy: borderWidth)
		viewport: (aRectangle insetBy: borderWidth).

	"Then ensure window maps to aRectangle"
	window := transformation applyInverseTo: aRectangle
]

{ #category : #'label access' }
StandardSystemView >> setLabel: aLabel [
	"For compatibility with morphic"

	self relabel: aLabel
]

{ #category : #'label access' }
StandardSystemView >> setLabelRegion [
	"Always follows view width"

	labelFrame region: (0 @ 0 extent: self displayBox width @ self labelHeight).
	labelFrame borderWidth: 2
]

{ #category : #'label access' }
StandardSystemView >> setLabelTo: aString [ 
	"Force aString to be the new label of the receiver, bypassing any logic about whether it is acceptable and about propagating information about the change."

	| oldRegion oldWidth |
	self label: aString.
	self controller isControlActive ifFalse: [^ self].
	oldRegion := self labelTextRegion.
	oldWidth := self insetDisplayBox width.
	Display fill: ((oldRegion merge: self labelTextRegion) expandBy: 3@0)
			fillColor: self labelColor.
	self insetDisplayBox width = oldWidth
		ifTrue: [self displayLabelText; emphasizeLabel]
		ifFalse: [self uncacheBits; displayEmphasized]
]

{ #category : #private }
StandardSystemView >> setTransformation: aTransformation [ 
	"Override to support label size changes "
	super setTransformation: aTransformation.
	self label: self label
]

{ #category : #updating }
StandardSystemView >> setUpdatablePanesFrom: getSelectors [
	"Set my updatablePanes inst var to the list of panes which are list panes with the given get-list selectors.  Order is important here!  Note that the method is robust in the face of panes not found, but a warning is printed in the transcript in each such case"
	| aList |
	aList := OrderedCollection new.
	getSelectors do:
		[:sel | 
			| aPane |
			aPane := self subViewSatisfying:
				[:pane | (pane isKindOf: PluggableListView) and: [pane getListSelector == sel]].
			aPane
				ifNotNil:
					[aList add: aPane]
				ifNil:
					[Transcript cr; show: 'Warning: view ', sel, ' not found.']].
	updatablePanes := aList asArray
]

{ #category : #framing }
StandardSystemView >> standardWindowOffset [
	^ Preferences standardWindowOffset
]

{ #category : #private }
StandardSystemView >> subviewWithLongestSide: sideBlock near: aPoint [ 
	| theSub theSide theLen |
	theLen := 0.
	subViews do:
		[:sub |
		| box |
		box := sub insetDisplayBox.
		box forPoint: aPoint closestSideDistLen:
			[:side :dist :len |
			(dist <= 5 and: [len > theLen]) ifTrue:
				[theSub := sub.
				theSide := side.
				theLen := len]]].
	sideBlock value: theSide.
	^ theSub
]

{ #category : #displaying }
StandardSystemView >> uncacheBits [
	windowBits := nil.
	bitsValid := false.
]

{ #category : #updating }
StandardSystemView >> updatablePanes [
	"Answer the list of panes, in order, which might be sent the #verifyContents message upon window activation or expansion."
	^ updatablePanes ifNil: [updatablePanes := #()]
]

{ #category : #updating }
StandardSystemView >> update: aSymbol [
	aSymbol = #relabel
		ifTrue: [^ self setLabelTo: model labelString].
	aSymbol = #close
		ifTrue: [^ self controller closeAndUnscheduleNoTerminate].
		
	^ super update: aSymbol
]

{ #category : #displaying }
StandardSystemView >> windowBits [
	^ windowBits
]

{ #category : #framing }
StandardSystemView >> windowBox [
	^ self displayBox merge: self labelDisplayBox
]

{ #category : #framing }
StandardSystemView >> windowOrigin [
	^ (self isCollapsed or: [labelFrame height = 0  "no label"])
		ifTrue: [self displayBox topLeft]
		ifFalse: [self displayBox topLeft - self labelOffset]
]
