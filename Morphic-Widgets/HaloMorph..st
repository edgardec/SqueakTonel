"
This morph provides a halo of handles for its target morph. Dragging, duplicating, rotating, and resizing to be done by mousing down on the appropriate handle. There are also handles for help and for a menu of infrequently used operations.
"
Class {
	#name : #HaloMorph,
	#superclass : #SimpleHaloMorph,
	#instVars : [
		'innerTarget',
		'angleOffset',
		'minExtent',
		'growingOrRotating',
		'directionArrowAnchor',
		'haloBox',
		'simpleMode',
		'originalExtent'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #initialization }
HaloMorph >> acceptNameEdit [
	"If the name is currently under edit, accept the changes"

	| label |
	(label := self findA: NameStringInHalo) ifNotNil:
		[label hasFocus ifTrue:
			[label lostFocusWithoutAccepting]]
]

{ #category : #handles }
HaloMorph >> addChooseGraphicHandle: haloSpec [
	"If the target is a sketch morph, and if the governing preference is set, add a halo handle allowing the user to select a new graphic"

	(Preferences showChooseGraphicHaloHandle and: [innerTarget isSketchMorph]) ifTrue:
		[self addHandle: haloSpec
				on: #mouseDown send: #chooseNewGraphicFromHalo to: innerTarget]

]

{ #category : #private }
HaloMorph >> addCircleHandles [
	| box |
	simpleMode := false.
	target isWorldMorph ifTrue: [^ self addHandlesForWorldHalos].

	self removeAllMorphs.  "remove old handles, if any"
	self bounds: target renderedMorph worldBoundsForHalo.  "update my size"
	box := self basicBox.

	target addHandlesTo: self box: box.

	self addName.
	growingOrRotating := false.
	self layoutChanged.
	self changed.

]

{ #category : #handles }
HaloMorph >> addCollapseHandle: handleSpec [
	"Add the collapse handle, with all of its event handlers set up, unless the target's owner is not the world or the hand."

	| collapseHandle |
	(target owner notNil "nil happens, amazingly"
			and: [target owner isWorldOrHandMorph])
		ifFalse: [^ self].
	collapseHandle := self addHandle: handleSpec
		on: #mouseDown send: #mouseDownInCollapseHandle:with: to: self.
	collapseHandle on: #mouseUp send: #maybeCollapse:with: to: self.
	collapseHandle on: #mouseMove send: #setDismissColor:with: to: self

]

{ #category : #handles }
HaloMorph >> addDebugHandle: handleSpec [
	Preferences debugHaloHandle ifTrue:
		[self addHandle: handleSpec
			on: #mouseDown send: #doDebug:with: to: self]

]

{ #category : #private }
HaloMorph >> addDirectionHandles [

	| centerHandle d w directionShaft patch patchColor crossHairColor |
	self showingDirectionHandles ifFalse: [^ self].

	directionArrowAnchor := (target point: target referencePosition in: self world) rounded.
	patch := target imageFormForRectangle: (Rectangle center: directionArrowAnchor extent: 3@3).
	patchColor := patch colorAt: 1@1.

	(directionShaft := LineMorph newSticky makeForwardArrow)
		borderWidth: 2; borderColor: (Color green orColorUnlike: patchColor).
	self positionDirectionShaft: directionShaft.
	self addMorphFront: directionShaft.
	directionShaft setCenteredBalloonText: 'Set forward direction' translated;
		on: #mouseDown send: #doDirection:with: to: self;
		on: #mouseMove send: #trackDirectionArrow:with: to: self;
		on: #mouseUp send: #setDirection:with: to: self.

	d := 15.  "diameter"  w := 3.  "borderWidth"
	crossHairColor := Color red orColorUnlike: patchColor.
	(centerHandle := EllipseMorph newBounds: (0@0 extent: d@d) color: Color transparent)
			borderWidth: w; borderColor: (Color blue orColorUnlike: patchColor);
			addMorph: (LineMorph from: (d//2)@w to: (d//2)@(d-w-1) color: crossHairColor width: 1) lock;
			addMorph: (LineMorph from: w@(d//2) to: (d-w-1)@(d//2) color: crossHairColor width: 1) lock;
			align: centerHandle bounds center with: directionArrowAnchor.
	centerHandle wantsYellowButtonMenu: false.
	self addMorph: centerHandle.
	centerHandle setCenteredBalloonText: 'Rotation center (hold down the shift key and drag from here to change it)' translated;
			on: #mouseDown send: #prepareToTrackCenterOfRotation:with: to: self;
			on: #mouseMove send: #trackCenterOfRotation:with: to: self;
			on: #mouseUp send: #setCenterOfRotation:with: to: self

]

{ #category : #handles }
HaloMorph >> addDismissHandle: handleSpec [
	"Add the dismiss handle according to the spec, unless selectiveHalos is on and my target resists dismissal"

	| dismissHandle |
	(target okayToAddDismissHandle or: [Preferences selectiveHalos not]) ifTrue:
		[dismissHandle := self addHandle: handleSpec
			on: #mouseDown send: #mouseDownInDimissHandle:with: to: self.
		dismissHandle on: #mouseUp send: #maybeDismiss:with: to: self.
		dismissHandle on: #mouseDown send: #setDismissColor:with: to: self.
		dismissHandle on: #mouseMove send: #setDismissColor:with: to: self]

]

{ #category : #handles }
HaloMorph >> addDragHandle: haloSpec [
	(self addHandle: haloSpec on: #mouseDown send: #startDrag:with: to: self)
		on: #mouseMove send: #doDrag:with: to: self



]

{ #category : #handles }
HaloMorph >> addDupHandle: haloSpec [
	"Add the halo that offers duplication, or, when shift is down, make-sibling"

 	| aSelector |
	aSelector := innerTarget couldMakeSibling
		ifTrue:
			[#doDupOrMakeSibling:with:]
		ifFalse:
			[#doDup:with:].

	self addHandle: haloSpec on: #mouseDown send: aSelector to: self


]

{ #category : #handles }
HaloMorph >> addFewerHandlesHandle: haloSpec [
	self addHandle: haloSpec on: #mouseDown send: #addSimpleHandles to: self

]

{ #category : #handles }
HaloMorph >> addFontEmphHandle: haloSpec [ 
	(innerTarget isTextMorph) 
		ifTrue: 
			[self 
				addHandle: haloSpec
				on: #mouseUp
				send: #chooseEmphasisOrAlignment
				to: innerTarget]
]

{ #category : #handles }
HaloMorph >> addFontSizeHandle: haloSpec [ 
	(innerTarget isTextMorph) 
		ifTrue: 
			[self 
				addHandle: haloSpec
				on: #mouseUp
				send: #chooseFont
				to: innerTarget]
]

{ #category : #handles }
HaloMorph >> addFontStyleHandle: haloSpec [ 
	(innerTarget isTextMorph) 
		ifTrue: 
			[self 
				addHandle: haloSpec
				on: #mouseUp
				send: #chooseStyle
				to: innerTarget]
]

{ #category : #private }
HaloMorph >> addFullHandles [
	"Later, obey a preference to choose between circle-iconic and solid-circles"
	self addCircleHandles
]

{ #category : #handles }
HaloMorph >> addGrabHandle: haloSpec [
	"If appropriate, add the black halo handle for picking up the target"

	innerTarget okayToAddGrabHandle ifTrue:
		[self addHandle: haloSpec on: #mouseDown send: #doGrab:with: to: self]


]

{ #category : #private }
HaloMorph >> addGraphicalHandle: formKey at: aPoint on: eventName send: selector to: recipient [
	"Add the supplied form as a graphical handle centered at the given point, and set it up to respond to the given event by sending the given selector to the given recipient.  Return the handle."
	| handle |
	handle := self addGraphicalHandleFrom: formKey at: aPoint.
	handle on: eventName send: selector to: recipient.
	handle setBalloonText: (target balloonHelpTextForHandle: handle) translated.
	^ handle

]

{ #category : #private }
HaloMorph >> addGraphicalHandleFrom: formKey at: aPoint [
	"Add the supplied form as a graphical handle centered at the given point.  Return the handle."
	| handle aForm |
	aForm := (ScriptingSystem formAtKey: formKey) ifNil: [ScriptingSystem formAtKey: #SolidMenu].
	handle := ImageMorph new image: aForm; bounds: (Rectangle center: aPoint extent: aForm extent).
	handle wantsYellowButtonMenu: false.
	self addMorph: handle.
	handle on: #mouseUp send: #endInteraction: to: self.
	^ handle

]

{ #category : #handles }
HaloMorph >> addGrowHandle: haloSpec [
	target isFlexMorph ifFalse: 
		[(self addHandle: haloSpec
				on: #mouseDown send: #startGrow:with: to: self)
				on: #mouseMove send: #doGrow:with: to: self]
	"This or addScaleHandle:, but not both, will prevail at any one time"

]

{ #category : #private }
HaloMorph >> addHandle: handleSpec on: eventName send: selector to: recipient [ 
	"Add a handle within the halo box as per the haloSpec, and set 
	it up to respond to the given event by sending the given 
	selector to the given recipient. Return the handle."
	| handle aPoint |

	aPoint := self
				positionIn: haloBox
				horizontalPlacement: handleSpec horizontalPlacement
				verticalPlacement: handleSpec verticalPlacement.

	handle := self
				addHandleAt: aPoint
				color: (Color colorFrom: handleSpec color)
				icon: handleSpec iconSymbol
				on: eventName
				send: selector
				to: recipient.

	^ handle
]

{ #category : #private }
HaloMorph >> addHandleAt: aPoint color: aColor icon: iconName on: eventName send: selector to: recipient [ 
	"Add a handle centered at the given point with the given color, 
	and set it up to respond to the given event by sending the 
	given selector to the given recipient. Return the handle."
	| handle |
	handle := self createHandleAt: aPoint color: (aColor alpha: 0.8) iconName: iconName.
	self addMorph: handle.

	handle on: #mouseUp send: #endInteraction: to: self.
	handle on: eventName send: selector to: recipient.
	handle setBalloonText: (target balloonHelpTextForHandle: handle) translated.

	^ handle 
]

{ #category : #private }
HaloMorph >> addHandleAt: aPoint color: aColor on: eventName send: selector to: recipient [
	^ self addHandleAt: aPoint color: aColor icon: nil on: eventName send: selector to: recipient

]

{ #category : #private }
HaloMorph >> addHandles [
	simpleMode == true
		ifTrue:
			[self addSimpleHandles]
		ifFalse:
			[self addCircleHandles]

]

{ #category : #private }
HaloMorph >> addHandlesForWorldHalos [
	"Add handles for world halos, like the man said"

	| box w |
	w := self world ifNil:[target world].
	self removeAllMorphs.  "remove old handles, if any"
	self bounds: target bounds.
	box := w bounds insetBy: self handleSize // 2.
	target addWorldHandlesTo: self box: box.

	Preferences uniqueNamesInHalos ifTrue:
		[innerTarget assureExternalName].
	self
		addNameBeneath: ((box insetBy: (0@0 corner: 0@10))
			scaleBy: RealEstateAgent scaleFactor)
		string: innerTarget externalName.
	growingOrRotating := false.
	self layoutChanged.
	self changed.

]

{ #category : #handles }
HaloMorph >> addHelpHandle: haloSpec [
	target balloonText ifNotNil:
		[(self addHandle: haloSpec on: #mouseDown send: #mouseDownOnHelpHandle: to: innerTarget)
			on: #mouseUp send: #deleteBalloon to: innerTarget]

]

{ #category : #handles }
HaloMorph >> addMakeSiblingHandle: haloSpec [
	"Add the halo handle that allows a sibling instance to be torn off, or, if the shift key is down, for a deep-copy duplicate to be made."

	self addHandle: haloSpec on: #mouseDown send: #doMakeSiblingOrDup:with: to: self


]

{ #category : #handles }
HaloMorph >> addMenuHandle: haloSpec [
	self addHandle: haloSpec on: #mouseDown send: #doMenu:with: to: self
]

{ #category : #private }
HaloMorph >> addName [
	"Add a name readout at the bottom of the halo."

	Preferences uniqueNamesInHalos ifTrue:
		[target assureExternalName].

	self addNameBeneath: self basicBox string: target externalName

]

{ #category : #private }
HaloMorph >> addNameBeneath: outerRectangle string: aString [
	"Add a name display centered beneath the bottom of the outer rectangle. Return the handle."

	| nameMorph namePosition w |
	w := self world ifNil:[target world].
	nameMorph := NameStringInHalo contents: aString font: Preferences standardHaloLabelFont.
	nameMorph wantsYellowButtonMenu: false.
	nameMorph color: Color black.
	nameMorph useStringFormat; target: innerTarget; putSelector: #tryToRenameTo:.
	namePosition := outerRectangle bottomCenter -
		((nameMorph width // 2) @ (self handleSize negated // 2 - 1)).
	nameMorph position: (namePosition min: w viewBox bottomRight - nameMorph extent y + 2).
	nameMorph balloonTextSelector: #objectNameInHalo.
	self addMorph: nameMorph.
	^ nameMorph
]

{ #category : #handles }
HaloMorph >> addPaintBgdHandle: haloSpec [
	(innerTarget isKindOf: PasteUpMorph) ifTrue:
		[self addHandle: haloSpec
				on: #mouseDown send: #paintBackground to: innerTarget].

]

{ #category : #handles }
HaloMorph >> addPoohHandle: handleSpec [
	(innerTarget isKindOf: (Smalltalk at: #WonderlandCameraMorph ifAbsent:[nil])) ifTrue:
		[self addHandle: handleSpec on: #mouseDown send: #strokeMode to: innerTarget]

]

{ #category : #handles }
HaloMorph >> addRecolorHandle: haloSpec [
	"Add a recolor handle to the receiver, if appropriate"

	| recolorHandle |

	"since this halo now opens a more general properties panel, allow it in all cases"
	"innerTarget canSetColor ifTrue:"

	recolorHandle := self addHandle: haloSpec on: #mouseUp send: #doRecolor:with: to: self.
	recolorHandle on: #mouseUp send: #doRecolor:with: to: self


]

{ #category : #handles }
HaloMorph >> addRepaintHandle: haloSpec [
	(innerTarget isSketchMorph) ifTrue:
		[self addHandle: haloSpec
				on: #mouseDown send: #editDrawing to: innerTarget]

]

{ #category : #handles }
HaloMorph >> addRotateHandle: haloSpec [
	(self addHandle: haloSpec on: #mouseDown send: #startRot:with: to: self)
		on: #mouseMove send: #doRot:with: to: self


]

{ #category : #handles }
HaloMorph >> addScaleHandle: haloSpec [
	
	(target isFlexMorph and: [target renderedMorph ~~ target])
		ifTrue: [(self addHandle: haloSpec
					on: #mouseDown send: #startScale:with: to: self)
					on: #mouseMove send: #doScale:with: to: self]
		ifFalse: [(self addHandle: haloSpec
					on: #mouseDown send: #startGrow:with: to: self)
					on: #mouseMove send: #doGrow:with: to: self].

]

{ #category : #handles }
HaloMorph >> addScriptHandle: haloSpec [
	"If the halo's innerTarget claims it wants a Script handle, add one to the receiver, forming it as per haloSpec"

	innerTarget wantsScriptorHaloHandle ifTrue:
		[self addHandle: haloSpec
				on: #mouseUp send: #editButtonsScript to: innerTarget]

]

{ #category : #private }
HaloMorph >> addSimpleHandles [
	target isWorldMorph ifTrue: [^ self addHandlesForWorldHalos].
	self removeAllMorphs.  "remove old handles, if any"
	self bounds: target renderedMorph worldBoundsForHalo.  "update my size"
	self innerTarget addSimpleHandlesTo: self box: self basicBoxForSimpleHalos


]

{ #category : #private }
HaloMorph >> addSimpleHandlesForWorldHalos [
	"Nothing special at present here -- just use the regular handles.  Cannot rotate or resize world"

	self addHandlesForWorldHalos

]

{ #category : #'halos and balloon help' }
HaloMorph >> addSimpleHandlesTo: aHaloMorph box: aBox [
	| aHandle |
	simpleMode := true.

	target isWorldMorph ifTrue: [^ self addSimpleHandlesForWorldHalos].

	self removeAllMorphs.  "remove old handles, if any"
	
	self bounds: target renderedMorph worldBoundsForHalo.  "update my size"
	
	self addHandleAt: (((aBox topLeft + aBox leftCenter) // 2) + self simpleFudgeOffset) color: Color paleBuff icon: 'Halo-MoreHandles'
		on: #mouseDown send: #addFullHandles to: self.

	aHandle := self addGraphicalHandle: #Rotate at: aBox bottomLeft on: #mouseDown send: #startRot:with: to: self.
	aHandle on: #mouseMove send: #doRot:with: to: self.

	(target isFlexMorph and: [target renderedMorph ~~ target])
		ifTrue: [(self addGraphicalHandle: #Scale at: aBox bottomRight  on: #mouseDown send: #startScale:with: to: self)
				on: #mouseMove send: #doScale:with: to: self]
		ifFalse: [(self addGraphicalHandle: #Scale at: aBox bottomRight on: #mouseDown send: #startGrow:with: to: self)
				on: #mouseMove send: #doGrow:with: to: self].

	innerTarget wantsSimpleSketchMorphHandles ifTrue:
		[self addSimpleSketchMorphHandlesInBox: aBox].

	growingOrRotating := false.
	self layoutChanged.
	self changed.

]

{ #category : #private }
HaloMorph >> addSimpleSketchMorphHandlesInBox: box [

	self addGraphicalHandle: #PaintTab at: box bottomCenter on: #mouseDown send: #editDrawing to: self innerTarget.

	self addDirectionHandles
]

{ #category : #handles }
HaloMorph >> addTileHandle: haloSpec [
	"Add the 'tear-off-tile' handle from the spec"

	self addHandle: haloSpec on: #mouseDown send: #tearOffTileForTarget:with: to: self

]

{ #category : #handles }
HaloMorph >> addViewHandle: haloSpec [
	"Add the 'open viewer' handle from the halo spec"

	self addHandle: haloSpec
		on: #mouseDown send: #openViewerForTarget:with: to: self



]

{ #category : #handles }
HaloMorph >> addViewingHandle: haloSpec [
	"If appropriate, add a special Viewing halo handle to the receiver.  On 26 Sept 07, we decided to eliminate this item from the UI, so the code of is method is now commented out...

	(innerTarget isKindOf: PasteUpMorph) ifTrue:
		[self addHandle: haloSpec
				on: #mouseDown send: #presentViewMenu to: innerTarget].
"

]

{ #category : #private }
HaloMorph >> basicBox [
	| minSide outset anExtent aBox w |
	minSide := 4 * self handleSize.
	outset := 8 * RealEstateAgent scaleFactor.
	anExtent := (self extent + self handleSize + outset) max: minSide asPoint.
	aBox := Rectangle center: self center extent: anExtent.
	w := self world ifNil:[target outermostWorldMorph].
	^ w
		ifNil:
			[aBox]
		ifNotNil:
			[aBox intersect: (w viewBox insetBy: self handleSize // 2)]

]

{ #category : #private }
HaloMorph >> basicBoxForSimpleHalos [
	| w |
	w := self world ifNil:[target outermostWorldMorph].
	^ (target topRendererOrSelf worldBoundsForHalo expandBy: self handleAllowanceForIconicHalos)
			intersect: (w bounds insetBy: 8@8)

]

{ #category : #updating }
HaloMorph >> changed [
	"Quicker to invalidate handles individually if target is large (especially the world)"

	self extent > (200@200)
		ifTrue: [(target notNil and: [target ~~ self world]) ifTrue:
					["Invalidate 4 outer strips first, thus subsuming separate damage."
					(self fullBounds areasOutside: target bounds) do:
						[:r | self invalidRect: r]].
				self submorphsDo: [:m | m changed]]
		ifFalse: [super changed].

]

{ #category : #'objects from disk' }
HaloMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	simpleMode ifNil: [simpleMode := false].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #private }
HaloMorph >> createHandleAt: aPoint color: aColor iconName: iconName [ 
	| bou handle |
	bou := Rectangle center: aPoint extent: self handleSize asPoint.
	Preferences alternateHandlesLook
		ifTrue: [handle := RectangleMorph newBounds: bou color: aColor.
			handle useRoundedCorners.
			self setColor: aColor toHandle: handle]
		ifFalse: [handle := EllipseMorph newBounds: bou color: aColor].
	handle borderWidth: 0;
		 wantsYellowButtonMenu: false.
	""
	iconName isNil
		ifFalse: [| form |
			form := ScriptingSystem formAtKey: iconName.
			form isNil
				ifFalse: [| image |
					image := ImageMorph new.
					image image: form scaleIconToDisplay.
					image color: aColor makeForegroundColor.
					image lock.
					handle addMorphCentered: image]].
	""
	^ handle
]

{ #category : #initialization }
HaloMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.6
		g: 0.8
		b: 1.0
]

{ #category : #'submorphs-add\/remove' }
HaloMorph >> delete [
	"Delete the halo.  Tell the target that it no longer has the halo; accept any pending edits to the name; and then either actually delete myself or start to fade out"

	self acceptNameEdit.
	self isMagicHalo: false.
	
	Preferences haloTransitions
		ifFalse: [super delete]
		ifTrue: [
			self
				stopStepping;
				startStepping;
				startSteppingSelector: #fadeOutFinally].
		
]

{ #category : #private }
HaloMorph >> directionArrowLength [
	^ 25
]

{ #category : #private }
HaloMorph >> dismiss [
	"Remove my target from the world Seems to be EToy specific."

	| w |
	w := self world.
	w ifNotNil: [w stopStepping: target].
	self delete.
	target dismissViaHalo
]

{ #category : #private }
HaloMorph >> doDebug: evt with: menuHandle [
	"Ask hand to invoke the a debugging menu for my inner target.  If shift key is down, immediately put up an inspector on the inner target"

	| menu |
	evt shiftPressed ifTrue: [
		evt hand removeHalo.
		^ innerTarget inspectInMorphic: evt].

	menu := innerTarget buildDebugMenu: evt hand.
	menu addTitle: (innerTarget externalName truncateWithElipsisTo: 40).
	menu popUpEvent: evt in: self world.
	evt hand removeHalo.
]

{ #category : #private }
HaloMorph >> doDirection: anEvent with: directionHandle [
	"The mouse went down on the forward-direction halo handle; respond appropriately."

	anEvent hand obtainHalo: self.
	anEvent shiftPressed
		ifTrue:
			[directionArrowAnchor := (target point: target referencePosition in: self world) rounded.
			self positionDirectionShaft: directionHandle.
			self removeAllHandlesBut: directionHandle.
			directionHandle setProperty: #trackDirectionArrow toValue: true]
		 ifFalse:
			[self currentHand spawnBalloonFor: directionHandle]
]

{ #category : #private }
HaloMorph >> doDrag: evt with: dragHandle [
	| thePoint |
	evt hand obtainHalo: self.
	thePoint := target point: evt position - positionOffset from: owner.
	target setConstrainedPosition:(target griddedPoint: thePoint) hangOut: true.

]

{ #category : #private }
HaloMorph >> doDup: evt with: dupHandle [
	"Ask hand to duplicate my target."

	(target isSelectionMorph) ifTrue:
		[^ target doDup: evt fromHalo: self handle: dupHandle].

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: dupHandle.
	self setTarget: (target duplicateMorph: evt).
	evt hand grabMorph: target.
	self step. "update position if necessary"
	evt hand addMouseListener: self. "Listen for the drop"
]

{ #category : #handles }
HaloMorph >> doDupOrMakeSibling: evt with: dupHandle [
	"Ask hand to duplicate my target, if shift key *not* pressed, or make a sibling if shift key *is* pressed"

	^ (evt shiftPressed and: [target couldMakeSibling])
		ifTrue:
			[dupHandle color: Color green muchDarker.
			self doMakeSibling: evt with: dupHandle]
		ifFalse:
			[self doDup: evt with: dupHandle]
]

{ #category : #private }
HaloMorph >> doGrab: evt with: grabHandle [
	"Ask hand to grab my target."

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: grabHandle.
	evt hand grabMorph: target.
	self step. "update position if necessary"
	evt hand addMouseListener: self. "Listen for the drop"
]

{ #category : #private }
HaloMorph >> doGrow: evt with: growHandle [
	"Called while the mouse is down in the grow handle"

	| newExtent extentToUse scale |
	evt hand obtainHalo: self.
	newExtent := (target pointFromWorld: (target griddedPoint: evt cursorPoint - positionOffset))
								- target topLeft.
	evt shiftPressed ifTrue: [
		scale := (newExtent x / (originalExtent x max: 1)) min:
					(newExtent y / (originalExtent y max: 1)).
		newExtent := (originalExtent x * scale) asInteger @ (originalExtent y * scale) asInteger
	].
	(newExtent x < 1 or: [newExtent y < 1 ]) ifTrue: [^ self].
	target renderedMorph setExtentFromHalo: (extentToUse := newExtent).
	growHandle position: evt cursorPoint - (growHandle extent // 2).
	self layoutChanged.
	(self valueOfProperty: #commandInProgress) ifNotNil:  
		[:cmd | "Update the final extent"
			cmd redoTarget: target renderedMorph selector: #setFlexExtentFromHalo: argument: extentToUse]

]

{ #category : #private }
HaloMorph >> doMakeSibling: evt with: dupHandle [
	"Ask hand to make a sibling of my target.  Only reachable if target is of a uniclass"

	target couldMakeSibling ifFalse: [^ self].

	target assuredPlayer assureUniClass.
	self obtainHaloForEvent: evt andRemoveAllHandlesBut: dupHandle.
	self setTarget: (target makeSiblings: 1) first.
	evt hand grabMorph: target.
	self step. "update position if necessary"
	evt hand addMouseListener: self. "Listen for the drop"
]

{ #category : #handles }
HaloMorph >> doMakeSiblingOrDup: evt with: dupHandle [
	"Ask hand to duplicate my target, if shift key *is* pressed, or make a sibling if shift key *not* pressed"

	^ (evt shiftPressed or: [target couldMakeSibling not])
		ifFalse:
			[self doMakeSibling: evt with: dupHandle]
		ifTrue:
			[dupHandle color: Color green.
			self doDup: evt with: dupHandle]
]

{ #category : #private }
HaloMorph >> doMenu: evt with: menuHandle [
	"Ask hand to invoke the halo menu for my inner target."

	| menu |
	menu := innerTarget buildHandleMenu: evt hand.
	innerTarget addTitleForHaloMenu: menu.
	menu popUpEvent: evt in: self world.
	evt hand removeHalo.

]

{ #category : #private }
HaloMorph >> doRecolor: evt with: aHandle [
	"The mouse went down in the 'recolor' halo handle.  Allow the user to change the color of the innerTarget"

	evt hand obtainHalo: self.
	(aHandle containsPoint: evt cursorPoint)
		ifFalse:  "only do it if mouse still in handle on mouse up"
			[self delete.
			target addHalo: evt]
		ifTrue:
			[(Preferences propertySheetFromHalo == evt shiftPressed)
				ifFalse:	[innerTarget openAPropertySheet]
				ifTrue:	[innerTarget changeColor].
			self showingDirectionHandles ifTrue: [self addHandles]]
]

{ #category : #'dragging or resizing' }
HaloMorph >> doResizeTarget: evt [ 
	| newExtent |
	newExtent := originalExtent + (evt position - positionOffset * 2).
	(newExtent x > 1 and: [ newExtent y > 1 ]) ifTrue:
		[ | oldExtent dockingBarBottom newPosition |
		oldExtent := target extent.
		dockingBarBottom := owner mainDockingBars
			inject: 0
			into: [ : bottomMostBottom : each | bottomMostBottom max: each bottom ].
		target setExtentFromHalo: (newExtent min: owner extent x @ (owner extent y - dockingBarBottom)).
		newPosition := target position - (target extent - oldExtent // 2).
		newPosition := (newPosition x
			min: owner extent x - newExtent x
			max: 0) @
			(newPosition y
				min: owner extent y - newExtent y
				max: dockingBarBottom).
		target
			setConstrainedPosition: newPosition
			hangOut: true ].
	self bounds: self target worldBoundsForHalo
]

{ #category : #private }
HaloMorph >> doRot: evt with: rotHandle [
	"Update the rotation of my target if it is rotatable.  Keep the relevant command object up to date."

	| degrees |
	evt hand obtainHalo: self.
	degrees := (evt cursorPoint - (target pointInWorld: target referencePosition)) degrees.
	degrees := degrees - angleOffset degrees.
	degrees := degrees detentBy: 10.0 atMultiplesOf: 90.0 snap: false.
	degrees = 0.0
		ifTrue: [self setColor: Color lightBlue toHandle: rotHandle]
		ifFalse: [self setColor: Color blue toHandle: rotHandle].
	rotHandle submorphsDo:
		[:m | m color: rotHandle color makeForegroundColor].
	self removeAllHandlesBut: rotHandle.
	self showingDirectionHandles ifFalse:
		[self showDirectionHandles: true addHandles: false].
	self addDirectionHandles.

	target rotationDegrees: degrees.

	rotHandle position: evt cursorPoint - (rotHandle extent // 2).
	(self valueOfProperty: #commandInProgress) ifNotNil:
		[:cmd | "Update the final rotation"
		cmd redoTarget: target renderedMorph selector: #heading: argument: degrees].
	self layoutChanged
]

{ #category : #private }
HaloMorph >> doScale: evt with: scaleHandle [
	"Update the scale of my target if it is scalable."
	| newHandlePos colorToUse |
	evt hand obtainHalo: self.
	newHandlePos := evt cursorPoint - (scaleHandle extent // 2).
	target scaleToMatch: newHandlePos.
	colorToUse := target scale = 1.0
						ifTrue: [Color yellow]
						ifFalse: [Color orange].
	self setColor: colorToUse toHandle: scaleHandle.
	scaleHandle
		submorphsDo: [:m | m color: colorToUse makeForegroundColor].
	scaleHandle position: newHandlePos.
	self layoutChanged.

	(self valueOfProperty: #commandInProgress) ifNotNil:[:cmd |
		"Update the final extent"
		cmd redoTarget: target renderedMorph selector: #setFlexExtentFromHalo: argument: target extent
	].

]

{ #category : #drawing }
HaloMorph >> drawSubmorphsOn: aCanvas [
	| alpha |
	((alpha := self magicAlpha) = 1.0)
		ifTrue:[^super drawSubmorphsOn: aCanvas].
	^super drawSubmorphsOn: (aCanvas asAlphaBlendingCanvas: alpha)
]

{ #category : #private }
HaloMorph >> endInteraction: event [
	"Clean up after a user interaction with the a halo control"

	| m |
	self isMagicHalo: false.	"no longer"
	self magicAlpha: 1.0.
	(target isInWorld not or: [owner isNil]) ifTrue: [^self].
	[target isFlexMorph and: [target hasNoScaleOrRotation]] whileTrue: 
			[m := target firstSubmorph.
			target removeFlexShell.
			target := m].
	self isInWorld 
		ifTrue: 
			["make sure handles show in front, even if flex shell added"
			self flag: #tofix. "mt: Try to avoid deleting and re-creating an event handler (here: the handle) while handling the event."
			self comeToFront.
			self addHandles.
			event hand newMouseFocus: self].
	(self valueOfProperty: #commandInProgress) ifNotNil: 
			[:cmd | 
			self rememberCommand: cmd.
			self removeProperty: #commandInProgress].
]

{ #category : #stepping }
HaloMorph >> fadeIn [
	self magicAlpha >= 1.0 ifTrue:[self stopSteppingSelector: #fadeIn].
	self magicAlpha: ((self magicAlpha + 0.1) min: 1.0)

]

{ #category : #stepping }
HaloMorph >> fadeInInitially [
	| max |
	max := self isMagicHalo ifTrue:[0.3] ifFalse:[1.0].
	self magicAlpha >= max ifTrue:[self stopSteppingSelector: #fadeInInitially].
	self magicAlpha: ((self magicAlpha + (max * 0.1)) min: max)

]

{ #category : #stepping }
HaloMorph >> fadeOut [
	self magicAlpha <= 0.3 ifTrue:[self stopSteppingSelector: #fadeOut].
	self magicAlpha: ((self magicAlpha - 0.1) max: 0.3)

]

{ #category : #stepping }
HaloMorph >> fadeOutFinally [
	self magicAlpha <= 0.05 ifTrue:[^super delete].
	self magicAlpha <= 0.3 ifTrue:[
		^self magicAlpha: (self magicAlpha - 0.03 max: 0.0)].
	self magicAlpha: ((self magicAlpha * 0.5) max: 0.0)

]

{ #category : #accessing }
HaloMorph >> haloBox: aBox [
	haloBox := aBox
]

{ #category : #private }
HaloMorph >> handleAllowanceForIconicHalos [
	^ 12
]

{ #category : #stepping }
HaloMorph >> handleEntered [
	self isMagicHalo ifFalse:[^self].
	self stopStepping; startStepping.
	self startSteppingSelector: #fadeIn.

]

{ #category : #stepping }
HaloMorph >> handleLeft [
	self isMagicHalo ifFalse:[^self].
	self stopStepping; startStepping.
	self startSteppingSelector: #fadeOut.
]

{ #category : #events }
HaloMorph >> handleListenEvent: anEvent [
	"We listen for possible drop events here to add back those handles after a dup/grab operation"

	(anEvent isMouse and:[anEvent isMove not]) ifFalse:[^ self]. "not interested"
	anEvent hand removeMouseListener: self. "done listening"
	(self world ifNil: [target world]) ifNil: [^ self].
	self addHandles  "and get those handles back"
]

{ #category : #private }
HaloMorph >> handleSize [
	^ (Preferences biggerHandles
		ifTrue: [30]
		ifFalse: [16]) * RealEstateAgent scaleFactor
]

{ #category : #initialization }
HaloMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	growingOrRotating := false.
	simpleMode := Preferences simpleHalosInForce 
]

{ #category : #accessing }
HaloMorph >> innerTarget [

	^ innerTarget

]

{ #category : #accessing }
HaloMorph >> isMagicHalo [
	^self valueOfProperty: #isMagicHalo ifAbsent:[false].
]

{ #category : #accessing }
HaloMorph >> isMagicHalo: aBool [
	self setProperty: #isMagicHalo toValue: aBool.
	aBool
		ifTrue: [
			self on: #mouseEnter send: #handleEntered to: self.
			self on: #mouseLeave send: #handleLeft to: self]
		ifFalse:[
			"Reset everything"
			self eventHandler ifNotNil: [:eh |
				eh forgetDispatchesTo: #handleEntered;
					forgetDispatchesTo: #handleLeft].
			self stopStepping. "get rid of all"
			self startStepping. "only those of interest"].
]

{ #category : #stepping }
HaloMorph >> localHaloBoundsFor: aMorph [

	"aMorph may be in the hand and perhaps not in our world"

	| r |

	r := aMorph worldBoundsForHalo truncated.
	aMorph world = self world ifFalse: [^r].
	^((self transformFromOutermostWorld) globalBoundsToLocal: r) truncated
]

{ #category : #accessing }
HaloMorph >> magicAlpha [
	^self valueOfProperty: #magicAlpha ifAbsent:[1.0]
]

{ #category : #accessing }
HaloMorph >> magicAlpha: alpha [
	self setProperty: #magicAlpha toValue: alpha.
	self changed.
]

{ #category : #private }
HaloMorph >> maybeCollapse: evt with: collapseHandle [ 
	"Ask hand to collapse my target if mouse comes up in it."

	evt hand obtainHalo: self.
	self delete.
	(collapseHandle containsPoint: evt cursorPoint) 
		ifFalse: 
			[
			target addHalo: evt]
		ifTrue: 
			[
			target collapse]
]

{ #category : #private }
HaloMorph >> maybeDismiss: evt with: dismissHandle [
	"Ask hand to dismiss my target if mouse comes up in it."

	evt hand obtainHalo: self.
	(dismissHandle containsPoint: evt cursorPoint)
		ifFalse: [
			self delete.
			target addHalo: evt]
		ifTrue: [
			target resistsRemoval ifTrue:
				[(UIManager default chooseFrom: {
					'Yes' translated.
					'Um, no, let me reconsider' translated.
				} title: 'Really throw this away?' translated) = 1 ifFalse: [^ self]].
			evt hand removeHalo.
			self delete.
			target dismissViaHalo.
			self currentWorld presenter flushPlayerListCache].
]

{ #category : #private }
HaloMorph >> maybeDoDup: evt with: dupHandle [
	evt hand obtainHalo: self.
	^ target okayToDuplicate ifTrue:
		[self doDup: evt with: dupHandle]
]

{ #category : #'WiW support' }
HaloMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^7		"Halos are very front-like things"
]

{ #category : #events }
HaloMorph >> mouseDown: event [

	self isMagicHalo ifTrue: [
		self isMagicHalo: false.
		self magicAlpha: 1.0].
		
	super mouseDown: event.
]

{ #category : #private }
HaloMorph >> mouseDownInCollapseHandle: evt with: collapseHandle [
	"The mouse went down in the collapse handle; collapse the morph"

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: collapseHandle.
	self setDismissColor: evt with: collapseHandle
]

{ #category : #private }
HaloMorph >> mouseDownInDimissHandle: evt with: dismissHandle [
	evt hand obtainHalo: self.
	SoundService soundEnabled ifTrue: [TrashCanMorph playMouseEnterSound].
	self removeAllHandlesBut: dismissHandle.
	self setColor: Color darkGray toHandle: dismissHandle.

]

{ #category : #events }
HaloMorph >> mouseMove: evt [
	
	growingOrRotating
		ifTrue: [self doResizeTarget: evt]
		ifFalse: [self doDragTarget: evt].
]

{ #category : #private }
HaloMorph >> obtainHaloForEvent: evt andRemoveAllHandlesBut: aHandle [
	"Make sure the event's hand correlates with the receiver, and remove all handles except the given one.  If nil is provided as the handles argument, the result is that all handles are removed.  Note that any pending edits to the name-string in the halo are accepted at this time."

	evt hand obtainHalo: self.
	self acceptNameEdit.
	self removeAllHandlesBut: aHandle
]

{ #category : #handles }
HaloMorph >> openViewerForTarget: evt with: aHandle [ 
	"Open a viewer for my inner target or if shift pressed make a snapshot of morph."
	self obtainHaloForEvent: evt andRemoveAllHandlesBut: nil.
	evt shiftPressed
		ifTrue: [target duplicateMorphImage: evt]
		ifFalse: [innerTarget openViewerForArgument]
]

{ #category : #'pop up' }
HaloMorph >> popUpFor: morph at: position hand: hand [
 
	super popUpFor: morph at: position hand: hand.
	
	self startStepping.
	(Preferences haloTransitions or: [self isMagicHalo]) 
		ifTrue: [
			self magicAlpha: 0.0.
			self startSteppingSelector: #fadeInInitially].
]

{ #category : #'pop up' }
HaloMorph >> popUpMagicallyFor: aMorph hand: aHand [
	"Programatically pop up a halo for a given hand."

	super
		popUpMagicallyFor: aMorph
		hand: aHand.
		
	Preferences magicHalos
		ifTrue: [self isMagicHalo: true].
	(Preferences haloTransitions not and: [self isMagicHalo])
		ifTrue: [self magicAlpha: 0.2].

]

{ #category : #geometry }
HaloMorph >> position: pos [
	"Halos display imprefectly if their coordinates are non-integral
		-- especially the direction handles."

	^ super position: pos asIntegerPoint
]

{ #category : #private }
HaloMorph >> positionDirectionShaft: shaft [
	"Position the shaft."
	| alphaRadians unitVector |
	"Pretty crude and slow approach at present, but a stake in the ground"
	alphaRadians := target heading degreesToRadians.
	unitVector := alphaRadians sin  @ alphaRadians cos negated.
	shaft setVertices: {unitVector * 6 + directionArrowAnchor.  "6 = radius of deadeye circle"
					unitVector * self directionArrowLength + directionArrowAnchor}

]

{ #category : #handles }
HaloMorph >> positionIn: aBox horizontalPlacement: horiz verticalPlacement: vert [
	| xCoord yCoord |

	horiz == #left
		ifTrue:	[xCoord := aBox left].
	horiz == #leftCenter
		ifTrue:	[xCoord := aBox left + (aBox width // 4)].
	horiz == #center
		ifTrue:	[xCoord := (aBox left + aBox right) // 2].
	horiz == #rightCenter
		ifTrue:	[xCoord := aBox left + ((3 * aBox width) // 4)].
	horiz == #right
		ifTrue:	[xCoord := aBox right].

	vert == #top
		ifTrue:	[yCoord := aBox top].
	vert == #topCenter
		ifTrue:	[yCoord := aBox top + (aBox height // 4)].
	vert == #center
		ifTrue:	[yCoord := (aBox top + aBox bottom) // 2].
	vert == #bottomCenter
		ifTrue:	[yCoord := aBox top + ((3 * aBox height) // 4)].
	vert == #bottom
		ifTrue:	[yCoord := aBox bottom].

	^ xCoord asInteger @ yCoord asInteger
]

{ #category : #private }
HaloMorph >> prepareToTrackCenterOfRotation: evt with: rotationHandle [
	"The mouse went down on the center of rotation."

	evt hand obtainHalo: self.
	evt shiftPressed
		ifTrue:
			[self removeAllHandlesBut: rotationHandle.
			rotationHandle setProperty: #trackCenterOfRotation toValue: true.
			evt hand showTemporaryCursor: Cursor blank]
		ifFalse:
			[self currentHand spawnBalloonFor: rotationHandle]
]

{ #category : #private }
HaloMorph >> removeAllHandlesBut: h [
	"Remove all handles except h."
	(Preferences maintainHalos and:[h isNil])
		ifTrue:[self removeHalo]
		ifFalse:[
			submorphs copy do:
				[:m | m == h ifFalse: [m delete]]
		].

]

{ #category : #private }
HaloMorph >> setCenterOfRotation: evt with: rotationHandle [
	| localPt |
	evt hand obtainHalo: self.
	evt hand showTemporaryCursor: nil.
	(rotationHandle hasProperty: #trackCenterOfRotation) ifTrue:
		[localPt  :=  innerTarget transformFromWorld globalPointToLocal: rotationHandle center.
		innerTarget setRotationCenterFrom: localPt].
	
	rotationHandle removeProperty: #trackCenterOfRotation.
	self endInteraction: evt.
]

{ #category : #private }
HaloMorph >> setColor: aColor toHandle: aHandle [ 
	"private - change the color to the given handle, applying the 
	alternate look if corresponds"
	aHandle color: aColor.
	Preferences alternateHandlesLook
		ifTrue: [| fill | 
			fill := GradientFillStyle ramp: {0.0 -> aColor muchLighter. 1.0 -> aColor darker}.
			fill origin: aHandle topLeft.
			fill direction: aHandle extent.
			aHandle fillStyle: fill] 
]

{ #category : #private }
HaloMorph >> setDirection: anEvent with: directionHandle [
	"The user has let up after having dragged the direction arrow; now set the forward direction of the actual SketchMorph accordingly"
	(directionHandle hasProperty: #trackDirectionArrow) ifTrue:
		[anEvent hand obtainHalo: self.
		target setDirectionFrom: directionHandle center.
		directionHandle removeProperty: #trackDirectionArrow.
		self endInteraction: anEvent]
]

{ #category : #private }
HaloMorph >> setDismissColor: evt with: dismissHandle [
	"Called on mouseStillDown in the dismiss handle; set the color appropriately."

	| colorToUse |
	evt hand obtainHalo: self.
	colorToUse :=  (dismissHandle containsPoint: evt cursorPoint)
		ifFalse:
			[Color red muchLighter]
		ifTrue:
			[Color lightGray].
	self setColor: colorToUse toHandle: dismissHandle.

]

{ #category : #accessing }
HaloMorph >> setTarget: aMorph [
	"Private! Set the target without adding handles."

	target := aMorph topRendererOrSelf.
	innerTarget := target renderedMorph.
	innerTarget wantsDirectionHandles
		ifTrue: [self showDirectionHandles: true addHandles: false].
	target hasHalo: true.


]

{ #category : #private }
HaloMorph >> showDirectionHandles: wantToShow [

	self showDirectionHandles: wantToShow addHandles: true  "called from menu"

]

{ #category : #private }
HaloMorph >> showDirectionHandles: wantToShow addHandles: needHandles [ 
	directionArrowAnchor := wantToShow 
				ifTrue: [target referencePositionInWorld	"not nil means show"]
				ifFalse: [nil].
	needHandles ifTrue: [self addHandles] 
]

{ #category : #private }
HaloMorph >> showingDirectionHandles [
	^directionArrowAnchor notNil
]

{ #category : #private }
HaloMorph >> simpleFudgeOffset [
	"account for the difference in basicBoxes between regular and simple handles"

	^ 0@0

]

{ #category : #private }
HaloMorph >> startDrag: evt with: dragHandle [
	"Drag my target without removing it from its owner."

	| itsOwner |
	self obtainHaloForEvent: evt andRemoveAllHandlesBut: dragHandle.
	positionOffset := dragHandle center - (target point: target position in: owner).

	 ((itsOwner := target topRendererOrSelf owner) notNil and:
			[itsOwner automaticViewing]) ifTrue:
				[target openViewerForArgument]
]

{ #category : #'dragging or resizing' }
HaloMorph >> startDragTarget: event [

	event controlKeyPressed
		ifTrue: [self startResizeTarget: event]
		ifFalse: [
			growingOrRotating := false.
			super startDragTarget: event].
]

{ #category : #private }
HaloMorph >> startGrow: evt with: growHandle [
	"Initialize resizing of my target.  Launch a command representing it, to support Undo"

	| botRt |
	self obtainHaloForEvent: evt andRemoveAllHandlesBut: growHandle.
	botRt := target point: target bottomRight in: owner.
	positionOffset := (self world viewBox containsPoint: botRt)
		ifTrue: [evt cursorPoint - botRt]
		ifFalse: [0@0].

	self setProperty: #commandInProgress toValue:
		(Command new
			cmdWording: ('resize ' translated, target nameForUndoWording);
			undoTarget: target renderedMorph selector: #setFlexExtentFromHalo: argument: target extent).

	originalExtent := target extent
]

{ #category : #'dragging or resizing' }
HaloMorph >> startResizeTarget: event [
	"Begin resizing the target"
	growingOrRotating := true.
	positionOffset := event position.
	originalExtent := target extent.
	self removeAllHandlesBut: nil.
	event hand newMouseFocus: self.
	event hand addMouseListener: self. "add handles back on mouse-up"
]

{ #category : #private }
HaloMorph >> startRot: evt with: rotHandle [
	"Initialize rotation of my target if it is rotatable.  Launch a command object to represent the action"

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: rotHandle.
	target isFlexMorph ifFalse: 
		[target isInWorld ifFalse: [self setTarget: target player costume].
		target addFlexShellIfNecessary].
	growingOrRotating := true.

	self removeAllHandlesBut: rotHandle.  "remove all other handles"
	angleOffset := evt cursorPoint - (target pointInWorld: target referencePosition).
	angleOffset := Point
			r: angleOffset r
			degrees: angleOffset degrees - target rotationDegrees.
	self setProperty: #commandInProgress toValue:
		(Command new
			cmdWording: ('rotate ' translated, target nameForUndoWording);
			undoTarget: target renderedMorph selector: #heading: argument: target rotationDegrees)


]

{ #category : #private }
HaloMorph >> startScale: evt with: scaleHandle [
	"Initialize scaling of my target."

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: scaleHandle.
	target isFlexMorph ifFalse: [target addFlexShellIfNecessary].
	growingOrRotating := true.
	positionOffset := 0@0.

	self setProperty: #commandInProgress toValue:
		(Command new
			cmdWording: ('resize ' translated, target nameForUndoWording);
			undoTarget: target renderedMorph selector: #setFlexExtentFromHalo: argument: target extent).
	originalExtent := target extent

]

{ #category : #stepping }
HaloMorph >> step [
	| newBounds |
	target
		ifNil: [^ self].
	newBounds := target isWorldMorph
				ifTrue: [target bounds]
				ifFalse: [self localHaloBoundsFor: target renderedMorph].
	newBounds = self bounds
		ifTrue: [^ self].
	newBounds extent = self bounds extent
		ifTrue: [^ self position: newBounds origin].
	growingOrRotating
		ifFalse: [submorphs size > 1
				ifTrue: [self addHandles]].
	"adjust halo bounds if appropriate"
	self bounds: newBounds
]

{ #category : #stepping }
HaloMorph >> stepTime [

	^ 0  "every cycle"

]

{ #category : #accessing }
HaloMorph >> target: aMorph [

	self setTarget: aMorph.
	target ifNotNil: [self addHandles].

]

{ #category : #handles }
HaloMorph >> tearOffTileForTarget: evt with: aHandle [
	"Tear off a tile representing my inner target.  If shift key is down, open up an instance browser on the morph itself, not the player, with tiles showing, instead"

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: nil.
	innerTarget tearOffTile
]

{ #category : #private }
HaloMorph >> trackCenterOfRotation: anEvent with: rotationHandle [
	(rotationHandle hasProperty: #dragByCenterOfRotation) 
		ifTrue:[^self doDrag: anEvent with: rotationHandle].
	(rotationHandle hasProperty: #trackCenterOfRotation)
		ifTrue:
			[anEvent hand obtainHalo: self.
			rotationHandle center: anEvent cursorPoint]
]

{ #category : #private }
HaloMorph >> trackDirectionArrow: anEvent with: shaft [
	(shaft hasProperty: #trackDirectionArrow) ifTrue:
		[anEvent hand obtainHalo: self.
		shaft setVertices: {directionArrowAnchor. anEvent cursorPoint}.
		self layoutChanged]
]

{ #category : #copying }
HaloMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
innerTarget := deepCopier references at: innerTarget ifAbsent: [innerTarget].

]

{ #category : #copying }
HaloMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	"target := target.		Weakly copied"
	"innerTarget := innerTarget.		Weakly copied"
	positionOffset := positionOffset veryDeepCopyWith: deepCopier.
	angleOffset := angleOffset veryDeepCopyWith: deepCopier.
	growingOrRotating := growingOrRotating veryDeepCopyWith: deepCopier.
	directionArrowAnchor := directionArrowAnchor.
	simpleMode := simpleMode.
	haloBox := haloBox.
	originalExtent := originalExtent

]

{ #category : #events }
HaloMorph >> wantsKeyboardFocusFor: aSubmorph [
	"to allow the name to be edited in the halo in the old tty way; when we morphic-text-ize the name editing, presumably this method should be removed"
	^ true
]

{ #category : #accessing }
HaloMorph >> wantsToBeTopmost [
	"Answer if the receiver want to be one of the topmost objects in 
	its owner"
	^ true
]

{ #category : #menu }
HaloMorph >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ false
]
