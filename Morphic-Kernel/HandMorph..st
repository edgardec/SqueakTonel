"
The cursor may be thought of as the HandMorph.  The hand's submorphs hold anything being carried by dragging.  

There is some minimal support for multiple hands in the same world.
"
Class {
	#name : #HandMorph,
	#superclass : #Morph,
	#instVars : [
		'mouseFocus',
		'keyboardFocus',
		'eventListeners',
		'mouseListeners',
		'keyboardListeners',
		'eventCaptureFilters',
		'mouseCaptureFilters',
		'keyboardCaptureFilters',
		'mouseClickState',
		'mouseOverHandler',
		'targetOffset',
		'lastMouseEvent',
		'damageRecorder',
		'cacheCanvas',
		'cachedCanvasHasHoles',
		'temporaryCursor',
		'temporaryCursorOffset',
		'hardwareCursor',
		'hasChanged',
		'savedPatch',
		'userInitials',
		'lastEventBuffer',
		'genieGestureProcessor',
		'keyboardInterpreter'
	],
	#classVars : [
		'CompositionWindowManager',
		'DoubleClickTime',
		'DragThreshold',
		'EventStats',
		'MinimalWheelDelta',
		'NewEventRules',
		'NormalCursor',
		'PasteBuffer',
		'SendMouseWheelToKeyboardFocus',
		'ShowEvents',
		'SynthesizeMouseWheelEvents'
	],
	#pools : [
		'EventSensorConstants'
	],
	#category : #'Morphic-Kernel'
}

{ #category : #utilities }
HandMorph class >> attach: aMorph [
	"Attach aMorph the current world's primary hand."

	self currentWorld primaryHand attachMorph: aMorph
]

{ #category : #initialization }
HandMorph class >> cleanUp: aggressive [

	aggressive ifTrue: [EventStats := nil].
]

{ #category : #initialization }
HandMorph class >> clearCompositionWindowManager [

	CompositionWindowManager := nil.

]

{ #category : #initialization }
HandMorph class >> clearInterpreters [

	self allInstances do: [:each | each clearKeyboardInterpreter].

]

{ #category : #'Multilingual-ImmPlugin' }
HandMorph class >> compositionWindowManager [
	self flag: #ImmPlugin.
	CompositionWindowManager ifNotNil: [^CompositionWindowManager].
	Smalltalk platformName = 'Win32' 
		ifTrue: [^CompositionWindowManager := ImmWin32 new].
	(Smalltalk platformName = 'unix' 
		and: [(Smalltalk windowSystemName) = 'X11']) 
			ifTrue: [^CompositionWindowManager := ImmX11 new].
	^CompositionWindowManager := ImmAbstractPlatform new
]

{ #category : #accessing }
HandMorph class >> doubleClickTime [

	^ DoubleClickTime

]

{ #category : #accessing }
HandMorph class >> doubleClickTime: milliseconds [

	DoubleClickTime := milliseconds.

]

{ #category : #accessing }
HandMorph class >> dragThreshold [

	^ DragThreshold

]

{ #category : #accessing }
HandMorph class >> dragThreshold: pixels [

	DragThreshold := pixels
]

{ #category : #'new-morph participation' }
HandMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #'class initialization' }
HandMorph class >> initialize [
	"HandMorph initialize"
	PasteBuffer := nil.
	DoubleClickTime := 350 "milliseconds".
	DragThreshold := 10 "pixels".
	NormalCursor := CursorWithMask normal asCursorForm
]

{ #category : #'class initialization' }
HandMorph class >> localeChanged [
	self startUp.
]

{ #category : #preferences }
HandMorph class >> minimumWheelDelta [
	<preference: 'Minimal Mouse Wheel Detection Threshold'
		categoryList: #(Morphic mouse)
		description: 'Answer the minimal scrolling units taken into account
Defaults to 120 (See #scrollUnitsPerMouseWheelNotch), corresponding to a single mouse wheel notch.
Use a lower value (20 - See #minimalScrollUnitsPerEvent) if wanting smoother scrolling with trackpads.'
		type: #Number>
	^MinimalWheelDelta ifNil: [MouseWheelEvent scrollUnitsPerMouseWheelNotch].
]

{ #category : #preferences }
HandMorph class >> minimumWheelDelta: anInteger [
	MinimalWheelDelta := anInteger ifNotNil: [anInteger
		clampLow: MouseWheelEvent minimalScrollUnitsPerEvent
		high: MouseWheelEvent scrollUnitsPerMouseWheelNotch]
]

{ #category : #utilities }
HandMorph class >> newEventRules: aBool [
	NewEventRules := aBool.
]

{ #category : #preferences }
HandMorph class >> sendMouseWheelToKeyboardFocus [
	<preference: 'Send Mouse Wheel Events to Keyboard Focus'
		categoryList: #(Morphic keyboard mouse)
		description: 'If enabled, follow the behavior known from Microsoft Windows, where the mouse wheel works for the widget that has the keyboard focus. If disabled, follow the Mac OS style, where the mouse wheel is send to the widget under the mouse position'
		type: #Boolean>
	^ SendMouseWheelToKeyboardFocus ifNil: [true]
]

{ #category : #preferences }
HandMorph class >> sendMouseWheelToKeyboardFocus: aBoolean [
	SendMouseWheelToKeyboardFocus := aBoolean.
]

{ #category : #utilities }
HandMorph class >> showEvents: aBool [
	"HandMorph showEvents: true"
	"HandMorph showEvents: false"

	ShowEvents := aBool.
	aBool ifFalse: [
		Project current world invalidRect: (0@0 extent: 250@120)].
]

{ #category : #initialization }
HandMorph class >> startUp [

	self clearCompositionWindowManager.
	self clearInterpreters.

]

{ #category : #preferences }
HandMorph class >> synthesizeMouseWheelEvents [
	<preference: 'Synthesize Mouse Wheel Events from Keyboard Events'
		categoryList: #(Morphic keyboard mouse)
		description: 'If enabled, convert CTRL+Up/Down (keystroke with modifier key) to mouse wheel up/down. Disable this according to the current VM behavior.'
		type: #Boolean>
	^ SynthesizeMouseWheelEvents ifNil: [true]
]

{ #category : #preferences }
HandMorph class >> synthesizeMouseWheelEvents: aBoolean [
	SynthesizeMouseWheelEvents := aBoolean.
]

{ #category : #'balloon help' }
HandMorph >> addBalloonHelp: aBalloonMorph [
	"Associate a new balloon morph with this hand."

	self removeAlarm: #spawnBalloonFor:.
	aBalloonMorph ifNotNil: [:m | self balloonHelpList add: m].
]

{ #category : #'events-listening' }
HandMorph >> addEventListener: anObject [
	"Make anObject a listener for all events. All events will be reported to the object."
	self eventListeners: (self addListener: anObject to: self eventListeners)
]

{ #category : #'events-listening' }
HandMorph >> addKeyboardListener: anObject [
	"Make anObject a listener for keyboard events. All keyboard events will be reported to the object."
	self keyboardListeners: (self addListener: anObject to: self keyboardListeners)
]

{ #category : #'events-listening' }
HandMorph >> addListener: anObject to: aListenerGroup [
	"Add anObject to the given listener group. Return the new group."
	| listeners |
	listeners := aListenerGroup.
	(listeners notNil and:[listeners includes: anObject]) ifFalse:[
		listeners
			ifNil:[listeners := WeakArray with: anObject]
			ifNotNil:[listeners := listeners copyWith: anObject]].
	listeners := listeners copyWithout: nil. "obsolete entries"
	^listeners
]

{ #category : #'events-listening' }
HandMorph >> addMouseListener: anObject [
	"Make anObject a listener for mouse events. All mouse events will be reported to the object."
	self mouseListeners: (self addListener: anObject to: self mouseListeners)
]

{ #category : #accessing }
HandMorph >> anyButtonPressed [
	^lastMouseEvent anyButtonPressed
]

{ #category : #'grabbing\/dropping' }
HandMorph >> attachMorph: m [
	"Position the center of the given morph under this hand, then grab it.
	This method is used to grab far away or newly created morphs."
	| delta |
	self releaseMouseFocus. "Break focus"
	self showTemporaryCursor: nil.
	delta := m bounds extent // 2.
	m position: (self position - delta).
	m formerPosition: m position.
	targetOffset := m position - self position.
	self addMorphBack: m.
]

{ #category : #'genie-stubs' }
HandMorph >> autoFocusRectangleBoundsFor: aMorph [
	^aMorph bounds
]

{ #category : #'balloon help' }
HandMorph >> balloonHelpList [
	"Return all balloon morphs associated with this hand"

	self flag: #performance. "mt: Make it an instance variable because we need to access this on every keystroke in a text field. See senders of #deleteBalloon."
	
	^ self
		valueOfProperty: #balloonHelpMorphs
		ifAbsentPut: [OrderedCollection new]
]

{ #category : #initialization }
HandMorph >> becomeActiveDuring: aBlock [
	"Make the receiver the active hand during the evaluation of aBlock."

	^ ActiveHandVariable value: self during: aBlock
]

{ #category : #updating }
HandMorph >> changed [

	hasChanged := true.

]

{ #category : #multilingual }
HandMorph >> clearKeyboardInterpreter [

	keyboardInterpreter := nil.

]

{ #category : #accessing }
HandMorph >> colorForInsets [
	"Morphs being dragged by the hand use the world's color"
	^ owner colorForInsets
]

{ #category : #'Multilingual-ImmPlugin' }
HandMorph >> compositionWindowManager [

	self flag: #ImmPlugin.
	^ self class compositionWindowManager.
]

{ #category : #'meta-actions' }
HandMorph >> copyToPasteBuffer: aMorph [
	"Save this morph in the paste buffer. This is mostly useful for copying morphs between projects."
	aMorph ifNil:[^PasteBuffer := nil].
	Cursor wait showWhile:[
		PasteBuffer := aMorph topRendererOrSelf veryDeepCopy.
		PasteBuffer privateOwner: nil].


]

{ #category : #cursor }
HandMorph >> cursorBounds [

	^temporaryCursor 
		ifNil: [self position extent: NormalCursor extent]
		ifNotNil: [self position + temporaryCursorOffset extent: temporaryCursor extent]
]

{ #category : #'event handling' }
HandMorph >> cursorPoint [
	"Implemented for allowing embedded worlds in an event cycle to query a hand's position and get it in its coordinates. The same can be achieved by #point:from: but this is simply much more convenient since it will look as if the hand is in the lower world."

	^ self currentWorld point: self position from: owner
]

{ #category : #'balloon help' }
HandMorph >> deleteBalloonTarget: aMorph [
	"Delete any existing balloon help."
	
	self balloonHelpList
		do: [:ea | ea delete];
		removeAll.
]

{ #category : #'genie-stubs' }
HandMorph >> disableGenieFocus [

]

{ #category : #drawing }
HandMorph >> drawOn: aCanvas [ 
	"Draw the hand itself (i.e., the cursor)."

	| userPic |
	temporaryCursor isNil 
		ifTrue: [aCanvas paintImage: NormalCursor at: bounds topLeft]
		ifFalse: [aCanvas paintImage: temporaryCursor at: bounds topLeft].
	self hasUserInformation 
		ifTrue: 
			[aCanvas 
				drawString: userInitials
				at: self cursorBounds topRight + (0 @ 4)
				font: nil
				color: color.
			(userPic := self userPicture) ifNotNil: 
					[aCanvas paintImage: userPic at: self cursorBounds topRight + (0 @ 24)]]
]

{ #category : #'grabbing\/dropping' }
HandMorph >> dropMorph: aMorph event: anEvent [
	"Drop the given morph which was carried by the hand"
	| event dropped |
	(anEvent isMouseUp and:[aMorph shouldDropOnMouseUp not]) ifTrue:[^self].

	"Note: For robustness in drag and drop handling we remove the morph BEFORE we drop him, but we keep his owner set to the hand. This prevents system lockups when there is a problem in drop handling (for example if there's an error in #wantsToBeDroppedInto:). THIS TECHNIQUE IS NOT RECOMMENDED FOR CASUAL USE."
	self privateRemove: aMorph.
	aMorph privateOwner: self.

	dropped := aMorph.
	(dropped hasProperty: #addedFlexAtGrab) 
		ifTrue:[dropped := aMorph removeFlexShell].
	event := DropEvent new setPosition: self position contents: dropped hand: self.
	
	[ "In case of an error, ensure that the morph-to-be-dropped will be disposed. Otherwise it may confuse garbage handler. See the sends of #privateRemove: and #privateOwner: above."
		event := self sendEvent: event focus: nil. "event filters can apply and filtered events will be returned"
		event wasHandled ifFalse: [aMorph rejectDropMorphEvent: event] ]
			ensure: [ aMorph owner == self ifTrue: [aMorph delete] ].
	
	self mouseOverHandler processMouseOver: anEvent.
]

{ #category : #'grabbing\/dropping' }
HandMorph >> dropMorphs [
	"Drop the morphs at the hands position"
	self dropMorphs: lastMouseEvent.
]

{ #category : #'grabbing\/dropping' }
HandMorph >> dropMorphs: anEvent [
	"Drop the morphs at the hands position"
	self submorphsReverseDo:[:m|
		"Drop back to front to maintain z-order"
		self dropMorph: m event: anEvent.
	].
]

{ #category : #'genie-stubs' }
HandMorph >> enableGenie [
	self error: 'Genie is not available for this hand'.
]

{ #category : #'events-filtering-bubbling' }
HandMorph >> eventBubbleFilters [
	Error signal: 'Hand morphs do only have capture filters. Install top-most bubble filters in the world.'
]

{ #category : #'events-filtering-capturing' }
HandMorph >> eventCaptureFilters [
	^ eventCaptureFilters
]

{ #category : #'events-filtering-capturing' }
HandMorph >> eventCaptureFilters: anArrayOrNil [
	eventCaptureFilters := anArrayOrNil
]

{ #category : #'events-listening' }
HandMorph >> eventListeners [
	^eventListeners
]

{ #category : #'events-listening' }
HandMorph >> eventListeners: anArrayOrNil [
	eventListeners := anArrayOrNil
]

{ #category : #'events-filtering' }
HandMorph >> filterEvent: aKeyboardEvent for: aMorphOrNil [
	"Fixes VM behavior. Usually, there are no mouse wheel events generated by the VM but CTRL+UP/DOWN. Convert these into mouse wheel events.
	
	We installed ourself as keyboard filter only! No need to check whether this is a keyboard event or not! See HandMorph >> #initForEvents.
	
	Might be removed in the future if this mapping gets obsolete."
	
	HandMorph synthesizeMouseWheelEvents ifFalse: [^ aKeyboardEvent].
	
	(aKeyboardEvent isKeystroke and: [aKeyboardEvent controlKeyPressed]) ifTrue: [
		aKeyboardEvent keyCharacter caseOf: {
			[Character arrowUp] -> [^ self generateMouseWheelEvent: aKeyboardEvent direction: 2r1000].
			[Character arrowDown] -> [^ self generateMouseWheelEvent: aKeyboardEvent direction: 2r0100].
		} otherwise: [^ aKeyboardEvent]].
	
	^ aKeyboardEvent
]

{ #category : #'event handling' }
HandMorph >> flushEvents [
	"Flush any events that may be pending"
	self flag: #arNote. "Remove it and fix senders"
	Sensor flushEvents.
]

{ #category : #'genie-stubs' }
HandMorph >> focusStartEvent [
	^nil
]

{ #category : #layout }
HandMorph >> fullBounds [
	"Extend my bounds by the shadow offset when carrying morphs."

	| bnds |
	bnds := super fullBounds.
	submorphs isEmpty
		ifTrue: [^ bnds ]
		ifFalse: [^ bnds topLeft corner: bnds bottomRight + self shadowOffset].

]

{ #category : #drawing }
HandMorph >> fullDrawOn: aCanvas [ 
	"A HandMorph has unusual drawing requirements:
		1. the hand itself (i.e., the cursor) appears in front of its submorphs
		2. morphs being held by the hand cast a shadow on the world/morphs below
	The illusion is that the hand plucks up morphs and carries them above the world."

	"Note: This version caches an image of the morphs being held by the hand for
	 better performance. This cache is invalidated if one of those morphs changes."

	| disableCaching subBnds |
	self visible ifFalse: [^self].
	(aCanvas isVisible: self fullBounds) ifFalse: [^self].
	(self hasProperty: #errorOnDraw) ifTrue:[^self drawErrorOn: aCanvas].
	disableCaching := false.
	disableCaching 
		ifTrue: 
			[self nonCachingFullDrawOn: aCanvas.
			^self].
	submorphs isEmpty 
		ifTrue: 
			[cacheCanvas := nil.
			^self drawOn: aCanvas].	"just draw the hand itself"

	"special handling of a single submorph that wants to do its own thing
	when being dragged"
	(submorphs size = 1
			and: [submorphs first handledOwnDraggingBy: self on: aCanvas])
		ifTrue: [^ self drawOn: aCanvas].

	subBnds := Rectangle merging: (submorphs collect: [:m | m fullBounds]).
	self updateCacheCanvas: aCanvas.
	(cacheCanvas isNil 
		or: [cachedCanvasHasHoles and: [cacheCanvas depth = 1]]) 
			ifTrue: 
				["could not use caching due to translucency; do full draw"

				self nonCachingFullDrawOn: aCanvas.
				^self].

	"draw the shadow"
	aCanvas asShadowDrawingCanvas translateBy: self shadowOffset
		during: 
			[:shadowCanvas | 
			cachedCanvasHasHoles 
				ifTrue: 
					["Have to draw the real shadow of the form"

					shadowCanvas paintImage: cacheCanvas form at: subBnds origin]
				ifFalse: 
					["Much faster if only have to shade the edge of a solid rectangle"

					(subBnds areasOutside: (subBnds translateBy: self shadowOffset negated)) 
						do: [:r | shadowCanvas fillRectangle: r color: Color black]]].

	"draw morphs in front of the shadow using the cached Form"
	cachedCanvasHasHoles 
		ifTrue: [aCanvas paintImage: cacheCanvas form at: subBnds origin]
		ifFalse: 
			[aCanvas 
				drawImage: cacheCanvas form
				at: subBnds origin
				sourceRect: cacheCanvas form boundingBox].
	self drawOn: aCanvas	"draw the hand itself in front of morphs"
]

{ #category : #'private events' }
HandMorph >> generateDropFilesEvent: evtBuf [ 
	"Generate the appropriate mouse event for the given raw event buffer"

	"Note: This is still in an experimental phase and will need more work"

	| position buttons modifiers stamp numFiles dragType |
	stamp := evtBuf second.
	stamp = 0 ifTrue: [stamp := Sensor eventTimeNow].
	dragType := evtBuf third.
	position := evtBuf fourth @ evtBuf fifth.
	buttons := 0.
	modifiers := evtBuf sixth.
	buttons := buttons bitOr: (modifiers bitShift: 3).
	numFiles := evtBuf seventh.
	dragType = 4 
		ifTrue: 
			["e.g., drop"

			owner borderWidth: 0.
			^DropFilesEvent new 
				setPosition: position
				contents: numFiles
				hand: self].
	"the others are currently not handled by morphs themselves"
	dragType = 1 
		ifTrue: 
			["experimental drag enter"

			owner
				borderWidth: 4;
				borderColor: owner color asColor negated].
	dragType = 2 
		ifTrue: 
			["experimental drag move"

			].
	dragType = 3 
		ifTrue: 
			["experimental drag leave"

			owner borderWidth: 0].
	^nil
]

{ #category : #'private events' }
HandMorph >> generateKeyboardEvent: evtBuf [
	"Generate the appropriate mouse event for the given raw event buffer"

	| buttons modifiers type pressType stamp keyValue |
	stamp := evtBuf second.
	stamp = 0 ifTrue: [stamp := Sensor eventTimeNow].
	pressType := evtBuf fourth.
	pressType = EventKeyDown ifTrue: [type := #keyDown].
	pressType = EventKeyUp ifTrue: [type := #keyUp].
	pressType = EventKeyChar ifTrue: [type := #keystroke].
	modifiers := evtBuf fifth.
	buttons := (modifiers bitShift: 3) bitOr: (lastMouseEvent buttons bitAnd: 7).
	type = #keystroke
		ifTrue: [keyValue := (self keyboardInterpreter nextCharFrom: Sensor firstEvt: evtBuf) asInteger]
		ifFalse: [keyValue := evtBuf third].
	^ KeyboardEvent new
		setType: type
		buttons: buttons
		position: self position
		keyValue: keyValue
		hand: self
		stamp: stamp.

]

{ #category : #'private events' }
HandMorph >> generateMouseEvent: evtBuf [ 
	"Generate the appropriate mouse event for the given raw event buffer"

	| position buttons modifiers type trail stamp oldButtons evtChanged |
	evtBuf first = lastEventBuffer first 
		ifTrue: 
			["Workaround for Mac VM bug, *always* generating 3 events on clicks"

			evtChanged := false.
			3 to: evtBuf size
				do: [:i | (lastEventBuffer at: i) = (evtBuf at: i) ifFalse: [evtChanged := true]].
			evtChanged ifFalse: [^nil]].
	stamp := evtBuf second.
	stamp = 0 ifTrue: [stamp := Sensor eventTimeNow].
	position := evtBuf third @ evtBuf fourth.
	buttons := evtBuf fifth.
	modifiers := evtBuf sixth.

	type := buttons = 0 
		ifTrue:[
				lastEventBuffer fifth = 0 		
					ifTrue: [#mouseMove] 	"this time no button and previously no button .. just mouse move"
					ifFalse: [#mouseUp]		"this time no button but previously some button ... therefore button was released"
		]
		ifFalse:[
				buttons = lastEventBuffer fifth
						ifTrue: [#mouseMove]		"button states are the same .. now and past .. therfore a mouse movement"
						ifFalse: [					"button states are different .. button was pressed or released"
							buttons > lastEventBuffer fifth
								ifTrue: [#mouseDown]
								ifFalse:[#mouseUp].
						].
		].
	buttons := buttons bitOr: (modifiers bitShift: 3).
	oldButtons := lastEventBuffer fifth 
				bitOr: (lastEventBuffer sixth bitShift: 3).
	lastEventBuffer := evtBuf.
	type == #mouseMove 
		ifTrue: 
			[trail := self mouseTrailFrom: evtBuf.
			^MouseMoveEvent new 
				setType: type
				startPoint: (self position)
				endPoint: trail last
				trail: trail
				buttons: buttons
				hand: self
				stamp: stamp].
	^MouseButtonEvent new 
		setType: type
		position: position
		which: (oldButtons bitXor: buttons)
		buttons: buttons
		nClicks: (evtBuf seventh ifNil: [0])
		hand: self
		stamp: stamp
]

{ #category : #'private events' }
HandMorph >> generateMouseWheelEvent: evtBuf [
	"Generate the appropriate mouse wheel event for the given raw event buffer"

	| buttons modifiers deltaX deltaY stamp nextEvent |
	stamp := evtBuf second.
	stamp = 0 ifTrue: [stamp := Sensor eventTimeNow].
	deltaX := evtBuf third.
	deltaY := evtBuf fourth.
	buttons := evtBuf fifth.
	modifiers := evtBuf sixth.
	[(deltaX abs + deltaY abs < self class minimumWheelDelta)
			and: [(nextEvent := Sensor peekEvent) notNil
			and: [nextEvent first = evtBuf first
			and: [nextEvent fifth = evtBuf fifth 
			and: [nextEvent sixth = evtBuf sixth]
			and: [nextEvent third isZero = evtBuf third isZero "both horizontal or vertical"]]]]]
		whileTrue:
			["nextEvent is similar.  Remove it from the queue, and check the next."
			nextEvent := Sensor nextEvent.
			deltaX := deltaX + nextEvent third.
			deltaY := deltaY + nextEvent fourth].
	^ MouseWheelEvent new
		setType: #mouseWheel
		position: self position
		delta: deltaX@deltaY
		buttons: buttons	
		hand: self
		stamp: stamp
]

{ #category : #'private events' }
HandMorph >> generateMouseWheelEvent: keystrokeEvent direction: direction [
	"Generate the appropriate mouse wheel event from the keystrokeEvent. Before calling this, ensure that the control key is pressed.
	
	This method can be discarded once the VM produces real mouse wheel events."
	
	^ MouseWheelEvent new
		setType: #mouseWheel
		position: keystrokeEvent position
		delta: 0 @ ((direction anyMask: 2r1000 "wheel up") ifTrue: [MouseWheelEvent scrollUnitsPerMouseWheelNotch] ifFalse: [MouseWheelEvent scrollUnitsPerMouseWheelNotch negated])
		direction: direction
		buttons: (keystrokeEvent buttons bitAnd: 2r01111) "drop control key pressed for this conversion"
		hand: keystrokeEvent hand
		stamp: keystrokeEvent timeStamp
]

{ #category : #'private events' }
HandMorph >> generateWindowEvent: evtBuf [ 
	"Generate the appropriate window event for the given raw event buffer"

	| evt |
	evt := WindowEvent new.
	evt setTimeStamp: evtBuf second.
	evt timeStamp = 0 ifTrue: [evt setTimeStamp: Sensor eventTimeNow].
	evt action: evtBuf third.
	evt rectangle: (Rectangle origin: evtBuf fourth @ evtBuf fifth corner: evtBuf sixth @ evtBuf seventh ).
	
	^evt
]

{ #category : #'genie-stubs' }
HandMorph >> genieGestureProcessor [
	^nil
]

{ #category : #'meta-actions' }
HandMorph >> grabMorph: aMorph [
	"Grab the given morph (i.e., add it to this hand and remove it from its current owner) without changing its position. This is used to pick up a morph under the hand's current position, versus attachMorph: which is used to pick up a morph that may not be near this hand."
	| grabbed |
	self releaseMouseFocus. "Break focus"
	self showTemporaryCursor: nil.
	grabbed := aMorph aboutToBeGrabbedBy: self.
	grabbed ifNil:[^self].
	grabbed := grabbed topRendererOrSelf.
	^self grabMorph: grabbed from: grabbed owner
]

{ #category : #'grabbing\/dropping' }
HandMorph >> grabMorph: aMorph from: formerOwner [
	"Grab the given morph (i.e., add it to this hand and remove it from its current owner) without changing its position. This is used to pick up a morph under the hand's current position, versus attachMorph: which is used to pick up a morph that may not be near this hand."

	| grabbed offset targetPoint grabTransform fullTransform |
	self releaseMouseFocus. "Break focus"
	self showTemporaryCursor: nil.
	grabbed := aMorph.
	aMorph keepsTransform ifTrue:[
		grabTransform := fullTransform := IdentityTransform new.
	] ifFalse:[
		"Compute the transform to apply to the grabbed morph"
		grabTransform := formerOwner 
			ifNil:		[IdentityTransform new] 
			ifNotNil:	[formerOwner grabTransform].
		"Compute the full transform for the grabbed morph"
		fullTransform := formerOwner 
			ifNil:		[IdentityTransform new] 
			ifNotNil:	[formerOwner transformFrom: owner].
	].
	"targetPoint is point in aMorphs reference frame"
	targetPoint := fullTransform globalPointToLocal: self position.
	"but current position will be determined by grabTransform, so compute offset"
	offset := targetPoint - (grabTransform globalPointToLocal: self position).
	"apply the transform that should be used after grabbing"
	grabbed := grabbed transformedBy: grabTransform.
	grabbed == aMorph 
		ifFalse:	[grabbed setProperty: #addedFlexAtGrab toValue: true].
	"offset target to compensate for differences in transforms"
	grabbed position: grabbed position - offset asIntegerPoint.
	"And compute distance from hand's position"
	targetOffset := grabbed position - self position.
	self addMorphBack: grabbed.
	grabbed justGrabbedFrom: formerOwner.
]

{ #category : #'gridded cursor' }
HandMorph >> gridPointRaw [
	"return my latest position gridded"
	^self griddedPoint: self currentEvent position
]

{ #category : #'gridded cursor' }
HandMorph >> gridTo: grid origin: offset [
	"set a couple of properties to specify gridding for the temporaryCursor; instvars would be nicer"
	self setProperty: #gridStep toValue: grid;
		setProperty: #gridOffset toValue: offset
]

{ #category : #'gridded cursor' }
HandMorph >> griddedPoint: aPoint [
	"return the equivalent point snapped to the grid, if indeed any gridding is set"
	self valueOfProperty: #gridStep ifPresentDo: [:grid| |offset|
		offset := self valueOfProperty: #gridOffset ifAbsent: [0@0].
		^ offset + (aPoint + (grid //2) - offset truncateTo: grid)].
	^aPoint
]

{ #category : #'halos and balloon help' }
HandMorph >> halo [
	"Return the halo associated with this hand, if any"
	^self valueOfProperty: #halo
]

{ #category : #'halo handling' }
HandMorph >> halo: newHalo [
	"Set halo associated with this hand"

	| oldHalo |
	(oldHalo := self halo) == newHalo ifTrue: [ ^self ].
	oldHalo ifNotNil: [ oldHalo delete ].
	newHalo
		ifNil:[self removeProperty: #halo]
		ifNotNil:[self setProperty: #halo toValue: newHalo]
]

{ #category : #'events-processing' }
HandMorph >> handleEvent: unfilteredEvent [

	| filteredEvent |
	owner ifNil: [^ unfilteredEvent  "not necessary but good style -- see Morph >> #handleEvent:"].
	
	self logEvent: unfilteredEvent.

	"Mouse-over events occur really, really, really often. They are kind of the heart beat of the Morphic UI process."
	unfilteredEvent isMouseOver ifTrue: [^ self sendMouseEvent: unfilteredEvent].

	self showEvent: unfilteredEvent.
	self sendListenEvents: unfilteredEvent.
	
	filteredEvent := self sendFilterEventCapture: unfilteredEvent for: nil.
	"filteredEvent := unfilteredEvent" " <-- use this to disable global capture filters"
	
	filteredEvent wasIgnored ifTrue: [
		self mouseOverHandler processMouseOver: lastMouseEvent.
		^ filteredEvent].
	
	filteredEvent isWindowEvent ifTrue: [
		self sendEvent: filteredEvent focus: nil.
		self mouseOverHandler processMouseOver: lastMouseEvent.
		^ filteredEvent].

	filteredEvent isKeyboard ifTrue:[
		self sendKeyboardEvent: filteredEvent.
		self mouseOverHandler processMouseOver: lastMouseEvent.
		^ filteredEvent].
			
	filteredEvent isDropEvent ifTrue:[
		self sendEvent: filteredEvent focus: nil.
		self mouseOverHandler processMouseOver: lastMouseEvent.
		^ filteredEvent].

	filteredEvent isMouse ifFalse: [
		self mouseOverHandler processMouseOver: lastMouseEvent.
		^ filteredEvent].

	" ********** MOUSE EVENT *********** "

	lastMouseEvent := filteredEvent.

	"Check for pending drag or double click operations."
	mouseClickState ifNotNil:[
		(mouseClickState handleEvent: filteredEvent from: self) ifFalse:[
			"Possibly dispatched #click: or something and will not re-establish otherwise"
			self mouseOverHandler processMouseOver: lastMouseEvent.
			^ filteredEvent]].

	filteredEvent isMouseWheel ifTrue: [
		self class sendMouseWheelToKeyboardFocus
			ifFalse: [self sendMouseEvent: filteredEvent]
			ifTrue: [self sendEvent: filteredEvent focus: self keyboardFocus clear: [self keyboardFocus: nil]].
		self mouseOverHandler processMouseOver: lastMouseEvent.
		^ filteredEvent].

	filteredEvent isMove ifTrue:[
		self position: filteredEvent position.
		self sendMouseEvent: filteredEvent.
		self mouseOverHandler processMouseOver: lastMouseEvent.
		^ filteredEvent].

	"Issue a synthetic move event if we're not at the position of the event"
	filteredEvent position = self position
		ifFalse: [self moveToEvent: filteredEvent].
	
	"Drop submorphs on button events"
	self hasSubmorphs
		ifTrue:[self dropMorphs: filteredEvent]
		ifFalse:[self sendMouseEvent: filteredEvent].

	self mouseOverHandler processMouseOver: lastMouseEvent.
	^ filteredEvent "not necessary but good style -- see Morph >> #handleEvent:"	
]

{ #category : #drawing }
HandMorph >> hasChanged [
	"Return true if this hand has changed, either because it has moved or because some morph it is holding has changed."

	^ hasChanged ifNil: [ true ]

]

{ #category : #drawing }
HandMorph >> hasUserInformation [
	^self userInitials notEmpty or: [self userPicture notNil]
]

{ #category : #initialization }
HandMorph >> initForEvents [
	mouseOverHandler := nil.
	lastMouseEvent := MouseEvent new setType: #mouseMove position: 0@0 buttons: 0 hand: self.
	lastEventBuffer := {1. 0. 0. 0. 0. 0. nil. nil}.
	self resetClickState.
	self addKeyboardCaptureFilter: self. "to convert unusual VM events"
]

{ #category : #initialization }
HandMorph >> initialize [
	super initialize.
	self initForEvents.
	keyboardFocus := nil.
	mouseFocus := nil.
	bounds := 0@0 extent: Cursor normal extent.
	userInitials := ''.
	damageRecorder := DamageRecorder new.
	cachedCanvasHasHoles := false.
	temporaryCursor := temporaryCursorOffset := nil.
	self initForEvents.
]

{ #category : #initialization }
HandMorph >> interrupted [
	"Something went wrong - we're about to bring up a debugger. 
	Release some stuff that could be problematic."
	self releaseAllFoci. "or else debugger might not handle clicks"

]

{ #category : #'change reporting' }
HandMorph >> invalidRect: damageRect from: aMorph [
	"Note that a change has occurred and record the given damage rectangle relative to the origin this hand's cache."
	hasChanged := true.
	aMorph == self ifTrue:[^self].
	damageRecorder recordInvalidRect: damageRect.

]

{ #category : #'events-processing' }
HandMorph >> isCapturingGesturePoints [
	^false
]

{ #category : #'genie-stubs' }
HandMorph >> isGenieAvailable [
	"Answer whether the Genie gesture recognizer is available for this hand"
	^false
]

{ #category : #'genie-stubs' }
HandMorph >> isGenieEnabled [
	"Answer whether the Genie gesture recognizer is enabled for this hand"
	^false
]

{ #category : #'genie-stubs' }
HandMorph >> isGenieFocused [
	"Answer whether the Genie gesture recognizer is auto-focused for this hand"
	^false
]

{ #category : #classification }
HandMorph >> isHandMorph [

	^ true
]

{ #category : #'events-filtering-bubbling' }
HandMorph >> keyboardBubbleFilters [
	Error signal: 'Hand morphs do only have capture filters. Install top-most bubble filters in the world.'
]

{ #category : #'events-filtering-capturing' }
HandMorph >> keyboardCaptureFilters [
	^ keyboardCaptureFilters
]

{ #category : #'events-filtering-capturing' }
HandMorph >> keyboardCaptureFilters: anArrayOrNil [
	keyboardCaptureFilters := anArrayOrNil
]

{ #category : #'focus handling' }
HandMorph >> keyboardFocus [ 
	^ keyboardFocus
]

{ #category : #'focus handling' }
HandMorph >> keyboardFocus: aMorphOrNil [
	keyboardFocus := aMorphOrNil
]

{ #category : #multilingual }
HandMorph >> keyboardInterpreter [

	^keyboardInterpreter ifNil: [keyboardInterpreter := LanguageEnvironment currentPlatform class defaultInputInterpreter]
]

{ #category : #'events-listening' }
HandMorph >> keyboardListeners [
	^keyboardListeners
]

{ #category : #'events-listening' }
HandMorph >> keyboardListeners: anArrayOrNil [
	keyboardListeners := anArrayOrNil
]

{ #category : #accessing }
HandMorph >> lastEvent [
	^ lastMouseEvent
]

{ #category : #'events-debugging' }
HandMorph >> logEvent: anEvent [
	"Update statistics for processed events."
	
	EventStats ifNil:[EventStats := IdentityDictionary new].
	EventStats at: #count put: (EventStats at: #count ifAbsent:[0]) + 1.
	EventStats at: anEvent type put: (EventStats at: anEvent type ifAbsent:[0]) + 1.
]

{ #category : #'events-filtering-bubbling' }
HandMorph >> mouseBubbleFilters [
	Error signal: 'Hand morphs do only have capture filters. Install top-most bubble filters in the world.'
]

{ #category : #'events-filtering-capturing' }
HandMorph >> mouseCaptureFilters [
	^ mouseCaptureFilters
]

{ #category : #'events-filtering-capturing' }
HandMorph >> mouseCaptureFilters: anArrayOrNil [
	mouseCaptureFilters := anArrayOrNil
]

{ #category : #'focus handling' }
HandMorph >> mouseFocus [
	^mouseFocus
]

{ #category : #'focus handling' }
HandMorph >> mouseFocus: aMorphOrNil [
	mouseFocus := aMorphOrNil
]

{ #category : #'events-listening' }
HandMorph >> mouseListeners [
	^mouseListeners
]

{ #category : #'events-listening' }
HandMorph >> mouseListeners: anArrayOrNil [
	mouseListeners := anArrayOrNil
]

{ #category : #accessing }
HandMorph >> mouseOverHandler [
	^mouseOverHandler ifNil:[mouseOverHandler := MouseOverHandler new].
]

{ #category : #'private events' }
HandMorph >> mouseTrailFrom: currentBuf [ 
	"Current event, a mouse event buffer, is about to be processed.  If there are other similar mouse events queued up, then drop them from the queue, and report the positions inbetween."

	| nextEvent trail |
	trail := WriteStream on: (Array new: 1).
	trail nextPut: currentBuf third @ currentBuf fourth.
	[(nextEvent := Sensor peekEvent) isNil] whileFalse: 
			[nextEvent first = currentBuf first 
				ifFalse: [^trail contents	"different event type"].
			nextEvent fifth = currentBuf fifth 
				ifFalse: [^trail contents	"buttons changed"].
			nextEvent sixth = currentBuf sixth 
				ifFalse: [^trail contents	"modifiers changed"].
			"nextEvent is similar.  Remove it from the queue, and check the next."
			nextEvent := Sensor nextEvent.
			trail nextPut: nextEvent third @ nextEvent fourth].
	^trail contents
]

{ #category : #'private events' }
HandMorph >> moveToEvent: anEvent [
	"Issue a mouse move event to make the receiver appear at the given position"
	self handleEvent: (MouseMoveEvent new
		setType: #mouseMove 
		startPoint: self position 
		endPoint: anEvent position 
		trail: (Array with: self position with: anEvent position)
		buttons: anEvent buttons
		hand: self
		stamp: anEvent timeStamp)
]

{ #category : #drawing }
HandMorph >> needsToBeDrawn [
	"Return true if this hand must be drawn explicitely instead of being drawn via the hardware cursor. This is the case if it (a) it is a remote hand, (b) it is showing a temporary cursor, or (c) it is not empty and there are any visible submorphs. If using the software cursor, ensure that the hardware cursor is hidden."
	"Details:  Return true if this hand has a saved patch to ensure that is is processed by the world. This saved patch will be deleted after one final display pass when it becomes possible to start using the hardware cursor again. This trick gives us one last display cycle to allow us to remove the software cursor and shadow from the display."
	(savedPatch notNil
		or: [ (submorphs anySatisfy: [ :ea | ea visible ])
			or: [ (temporaryCursor notNil and: [hardwareCursor isNil])
				or: [ self hasUserInformation ]]])
		ifTrue: [
			"using the software cursor; hide the hardware one"
			self showHardwareCursor: false.
			^ true].
	^ false

]

{ #category : #'focus handling' }
HandMorph >> newKeyboardFocus: aMorphOrNil [
	"Make the given morph the new keyboard focus, canceling the previous keyboard focus if any. If the argument is nil, the current keyboard focus is cancelled."
	
	| oldFocus newFocus |
	oldFocus := self keyboardFocus.
	newFocus := aMorphOrNil ifNotNil: [:m | m keyboardFocusDelegate].
	
	self keyboardFocus: newFocus.
	
	oldFocus == newFocus ifFalse: [
		oldFocus ifNotNil: [:m | m keyboardFocusChange: false].
		newFocus ifNotNil: [:m | m keyboardFocusChange: true]].
	
	self flag: #ImmPlugin.
	"newFocus ifNotNil: [:m |
		self compositionWindowManager keyboardFocusForAMorph: m]."

	^ newFocus

]

{ #category : #'focus handling' }
HandMorph >> newMouseFocus: aMorphOrNil [
	"Make the given morph the new mouse focus, canceling the previous mouse focus if any. If the argument is nil, the current mouse focus is cancelled."
	self mouseFocus: aMorphOrNil.

]

{ #category : #'focus handling' }
HandMorph >> newMouseFocus: aMorph event: event [ 
	aMorph isNil 
		ifFalse: [targetOffset := event cursorPoint - aMorph position].
	^self newMouseFocus: aMorph
]

{ #category : #accessing }
HandMorph >> noButtonPressed [
	"Answer whether any mouse button is not being pressed."

	^self anyButtonPressed not
]

{ #category : #drawing }
HandMorph >> nonCachingFullDrawOn: aCanvas [
	
	"A HandMorph has unusual drawing requirements:
		1. the hand itself (i.e., the cursor) appears in front of its submorphs
		2. morphs being held by the hand cast a shadow on the world/morphs below
	The illusion is that the hand plucks up morphs and carries them above the world."
	"Note: This version does not cache an image of the morphs being held by the hand.
	 Thus, it is slower for complex morphs, but consumes less space."

	submorphs isEmpty ifTrue: [^ self drawOn: aCanvas].  "just draw the hand itself"
	aCanvas asShadowDrawingCanvas
		translateBy: self shadowOffset during:[:shadowCanvas| | shadowForm |
		"Note: We use a shadow form here to prevent drawing
		overlapping morphs multiple times using the transparent
		shadow color."
		shadowForm := self shadowForm.
"
shadowForm displayAt: shadowForm offset negated. Display forceToScreen: (0@0 extent: shadowForm extent).
"
		shadowCanvas paintImage: shadowForm at: shadowForm offset.  "draw shadows"
	].
	"draw morphs in front of shadows"
	self drawSubmorphsOn: aCanvas.
	self drawOn: aCanvas.  "draw the hand itself in front of morphs"

]

{ #category : #'event handling' }
HandMorph >> noticeMouseOver: aMorph event: anEvent [
	mouseOverHandler ifNil:[^self].
	mouseOverHandler noticeMouseOver: aMorph event: anEvent.
]

{ #category : #'objects from disk' }
HandMorph >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a path to me in the other system instead."

	(refStrm project world hands includes: self) ifTrue: [
		^ self].	"owned by the project"
	dp := DiskProxy global: #World selector: #primaryHand args: #().
	refStrm replace: self with: dp.
	^ dp
	"Note, when this file is loaded in an MVC project, this will return nil.  The MenuItemMorph that has this in a field will have that item not work.  Maybe warn the user at load time?"
]

{ #category : #'paste buffer' }
HandMorph >> objectToPaste [
	"It may need to be sent #startRunning by the client"
	^ Cursor wait showWhile: [PasteBuffer veryDeepCopy]

	"PasteBuffer usableDuplicateIn: self world"

]

{ #category : #'halo handling' }
HandMorph >> obtainHalo: aHalo [
	"Used for transfering halos between hands"
	| formerOwner |
	self halo == aHalo ifTrue:[^self].
	"Find former owner"
	formerOwner := self world hands detect:[:h| h halo == aHalo] ifNone:[nil].
	formerOwner ifNotNil:[formerOwner releaseHalo: aHalo].
	self halo: aHalo
]

{ #category : #'paste buffer' }
HandMorph >> pasteBuffer [
	"Return the paste buffer associated with this hand"
	^ PasteBuffer
]

{ #category : #'paste buffer' }
HandMorph >> pasteBuffer: aMorphOrNil [
	"Set the contents of the paste buffer."
	PasteBuffer := aMorphOrNil.


]

{ #category : #'paste buffer' }
HandMorph >> pasteMorph [

	| aPastee |
	PasteBuffer ifNil: [^ self inform: 'Nothing to paste.' translated].
	self attachMorph: (aPastee := self objectToPaste).
	aPastee align: aPastee center with: self position.
	aPastee player ifNotNil: [aPastee player startRunning]

]

{ #category : #geometry }
HandMorph >> position [

	^temporaryCursor
		ifNil: [bounds topLeft]
		ifNotNil: [bounds topLeft - temporaryCursorOffset]
]

{ #category : #geometry }
HandMorph >> position: aPoint [
	"Overridden to align submorph origins to the grid if gridding is on."
	| adjustedPosition delta box |
	adjustedPosition := aPoint.
	temporaryCursor ifNotNil: [adjustedPosition := (self griddedPoint: adjustedPosition) + temporaryCursorOffset].

	"Copied from Morph to avoid owner layoutChanged"
	"Change the position of this morph and and all of its submorphs."
	delta := adjustedPosition - bounds topLeft.
	delta isZero ifTrue: [^ self].  "Null change"
	box := self fullBounds.
	(delta dotProduct: delta) > 100 ifTrue:[
		"e.g., more than 10 pixels moved"
		self invalidRect: box.
		self invalidRect: (box translateBy: delta).
	] ifFalse:[
		self invalidRect: (box merge: (box translateBy: delta)).
	].
	self privateFullMoveBy: delta.

]

{ #category : #'event handling' }
HandMorph >> processEvents [
	"Process user input events from the local input devices."

	| evt evtBuf type hadAny |
	self currentEvent ~= lastMouseEvent ifTrue: [
		"Meaning that we were invoked from within an event response.
		Make sure z-order is up to date."
		self mouseOverHandler processMouseOver: lastMouseEvent].
	
	hadAny := false.
	[(evtBuf := Sensor nextEvent) isNil] whileFalse: 
			[evt := nil.	"for unknown event types"
			type := evtBuf first.
			type = EventTypeMouse
				ifTrue: [evt := self generateMouseEvent: evtBuf].
			type = EventTypeMouseWheel
				ifTrue: [evt := self generateMouseWheelEvent: evtBuf].
			type = EventTypeKeyboard 
				ifTrue: [evt := self generateKeyboardEvent: evtBuf].
			type = EventTypeDragDropFiles 
				ifTrue: [evt := self generateDropFilesEvent: evtBuf].
			type = EventTypeWindow
				ifTrue:[evt := self generateWindowEvent: evtBuf].
			"All other events are ignored"
			(type ~= EventTypeDragDropFiles and: [evt isNil]) ifTrue: [^self].
			evt ifNotNil: ["Finally, handle it."
					self handleEvent: evt.
					hadAny := true.
					
					"For better user feedback, return immediately after a mouse event has been processed."
					evt isMouse ifTrue: [^ self]]].
	
	"note: if we come here we didn't have any mouse events"
	mouseClickState ifNotNil: [
		"No mouse events during this cycle. Make sure click states time out accordingly"
		mouseClickState handleEvent: lastMouseEvent asMouseMove from: self].
	hadAny ifFalse: [
		"No pending events. Make sure z-order is up to date"
		self mouseOverHandler processMouseOver: lastMouseEvent].
]

{ #category : #'focus handling' }
HandMorph >> releaseAllFoci [
	mouseFocus := nil.
	keyboardFocus := nil.

]

{ #category : #caching }
HandMorph >> releaseCachedState [
	| oo ui |
	ui := userInitials.
	super releaseCachedState.
	cacheCanvas := nil.
	oo := owner.
	self removeAllMorphs.
	self initialize.	"nuke everything"
	self privateOwner: oo.
	self releaseAllFoci.
	self userInitials: ui andPicture: (self userPicture).
]

{ #category : #'halo handling' }
HandMorph >> releaseHalo: aHalo [
	"Used for transfering halos between hands"
	self removeProperty: #halo
]

{ #category : #'focus handling' }
HandMorph >> releaseKeyboardFocus [
	"Release the current keyboard focus unconditionally"
	self newKeyboardFocus: nil.

]

{ #category : #'focus handling' }
HandMorph >> releaseKeyboardFocus: aMorph [
	"If the given morph had the keyboard focus before, release it"
	self keyboardFocus == aMorph keyboardFocusDelegate
		ifTrue:[self releaseKeyboardFocus].
]

{ #category : #'focus handling' }
HandMorph >> releaseMouseFocus [
	"Release the current mouse focus unconditionally."
	self newMouseFocus: nil.
]

{ #category : #'focus handling' }
HandMorph >> releaseMouseFocus: aMorph [
	"If the given morph had the mouse focus before, release it"
	self mouseFocus == aMorph ifTrue:[self releaseMouseFocus].
]

{ #category : #'events-listening' }
HandMorph >> removeEventListener: anObject [
	"Remove anObject from the current event listeners."
	self eventListeners: (self removeListener: anObject from: self eventListeners).
]

{ #category : #'halo handling' }
HandMorph >> removeHalo [
	"remove the receiver's halo (if any)"

	self halo ifNotNil: [ :halo |
		halo delete.
		self removeProperty: #halo ]
]

{ #category : #'halo handling' }
HandMorph >> removeHaloFromClick: anEvent on: aMorph [ 
	| halo |
	halo := self halo
				ifNil: [^ self].
	(halo target hasOwner: self)
		ifTrue: [^ self].
	(halo staysUpWhenMouseIsDownIn: aMorph)
		ifFalse: [self removeHalo]
]

{ #category : #'events-listening' }
HandMorph >> removeKeyboardListener: anObject [
	"Remove anObject from the current keyboard listeners."
	self keyboardListeners: (self removeListener: anObject from: self keyboardListeners).
]

{ #category : #'events-listening' }
HandMorph >> removeListener: anObject from: aListenerGroup [ 
	"Remove anObject from the given listener group. Return the new group."

	| listeners |
	aListenerGroup ifNil: [^nil].
	listeners := aListenerGroup.
	listeners := listeners copyWithout: anObject.
	listeners := listeners copyWithout: nil.	"obsolete entries"
	listeners isEmpty ifTrue: [listeners := nil].
	^listeners
]

{ #category : #'events-listening' }
HandMorph >> removeMouseListener: anObject [
	"Remove anObject from the current mouse listeners."
	self mouseListeners: (self removeListener: anObject from: self mouseListeners).
]

{ #category : #'balloon help' }
HandMorph >> removePendingBalloonFor: aMorph [
	"Get rid of pending balloon help or remove the balloon help if already shown."
	
	self flag: #workaround. "mt: We do not track for which morph there is a pending balloon. To avoid cancelling the wrong requests, check whether the given morph wants a balloon or not. Seems to work fine."
	aMorph wantsBalloon ifFalse: [^ self].
	
	self removeAlarm: #spawnBalloonFor:.
	self deleteBalloonTarget: aMorph.
]

{ #category : #'halo handling' }
HandMorph >> removePendingHaloFor: aMorph [
	"Get rid of pending balloon help or halo actions."
	self removeAlarm: #spawnMagicHaloFor:.
]

{ #category : #'balloon help' }
HandMorph >> resetBalloonHelp: aBalloonMorph [
	"Associate a new balloon morph with this hand. Remove all other ones."

	self
		deleteBalloonTarget: nil;
		addBalloonHelp: aBalloonMorph.
]

{ #category : #'double click support' }
HandMorph >> resetClickState [
	"Reset the double-click detection state to normal (i.e., not waiting for a double-click)."
	mouseClickState := nil.
]

{ #category : #initialization }
HandMorph >> resourceJustLoaded [
	"In case resource relates to me"
	cacheCanvas := nil.
]

{ #category : #drawing }
HandMorph >> restoreSavedPatchOn: aCanvas [ 
	"Clear the changed flag and restore the part of the given canvas under this hand from the previously saved patch. If necessary, handle the transition to using the hardware cursor."

	hasChanged := false.
	savedPatch ifNotNil: 
			[aCanvas drawImage: savedPatch at: savedPatch offset.
			self hasUserInformation ifTrue: [^self].	"cannot use hw cursor if so"
			submorphs notEmpty ifTrue: [^self].
			(temporaryCursor notNil and: [hardwareCursor isNil]) ifTrue: [^self].

			"Make the transition to using hardware cursor. Clear savedPatch and
		 report one final damage rectangle to erase the image of the software cursor."
			super invalidRect: (savedPatch offset 
						extent: savedPatch extent + self shadowOffset)
				from: self.
			self showHardwareCursor: true.
			savedPatch := nil]
]

{ #category : #drawing }
HandMorph >> savePatchFrom: aCanvas [ 
	"Save the part of the given canvas under this hand as a Form and return its bounding rectangle."

	"Details: The previously used patch Form is recycled when possible to reduce the burden on storage management."

	| damageRect myBnds |
	damageRect := myBnds := self fullBounds.
	savedPatch ifNotNil: 
			[damageRect := myBnds merge: (savedPatch offset extent: savedPatch extent)].
	(savedPatch isNil or: [savedPatch extent ~= myBnds extent]) 
		ifTrue: 
			["allocate new patch form if needed"

			savedPatch := aCanvas form allocateForm: myBnds extent].
	aCanvas contentsOfArea: (myBnds translateBy: aCanvas origin)
		into: savedPatch.
	savedPatch offset: myBnds topLeft.
	^damageRect
]

{ #category : #'selected object' }
HandMorph >> selectedObject [
	"answer the selected object for the hand or nil is none"
	
	^self halo ifNotNil: [ :halo | halo target renderedMorph ]
]

{ #category : #'private events' }
HandMorph >> sendEvent: anEvent focus: focusHolder [
	"Send the event to the morph currently holding the focus, or if none to the owner of the hand."
	^self sendEvent: anEvent focus: focusHolder clear:[nil]
]

{ #category : #'private events' }
HandMorph >> sendEvent: anEvent focus: focusHolder clear: aBlock [
	"Send the event to the morph currently holding the focus, or if none to the owner of the hand."

	| result w |
	focusHolder ifNotNil:[^self sendFocusEvent: anEvent to: focusHolder clear: aBlock].
	w := self world.
	w becomeActiveDuring: [
		self becomeActiveDuring: [
				anEvent becomeActiveDuring: [
					result := w processEvent: anEvent]]].
	^ result == #rejected ifTrue: [anEvent] ifFalse: [result "filtered event"]
]

{ #category : #'events-processing' }
HandMorph >> sendFilterEventCaptureAgain: anEvent for: anObjectOrNil [
	"Apply keyboard-specific and mouse-specific capturing filters. If a filter changes the event type, filter again. WARNING: This is a powerful mechanism. Filters can create endless loops, which are difficult to debug.
	
	Overwritten to provide keyboard and mouse focus holders to event filters. Note that hence the event target in such global filters can be nil."

	| filteredEvent |
	filteredEvent := anEvent.
	
	filteredEvent isKeyboard ifTrue: [
		filteredEvent := self sendFilterEvent: filteredEvent for: self keyboardFocus to: self keyboardCaptureFilters.
		filteredEvent isKeyboard not ifTrue: [^ self sendFilterEventCaptureAgain: filteredEvent for: anObjectOrNil]].
		
	filteredEvent isMouse ifTrue: [
		filteredEvent := self sendFilterEvent: filteredEvent for: self mouseFocus to: self mouseCaptureFilters.
		filteredEvent isMouse not ifTrue: [^ self sendFilterEventCaptureAgain: filteredEvent for: anObjectOrNil]].

	^ filteredEvent
]

{ #category : #'private events' }
HandMorph >> sendFocusEvent: anEvent to: focusHolder clear: aBlock [
	"Send the event to the morph currently holding the focus"

	| result w |
	w := focusHolder world ifNil: [aBlock value. ^ anEvent].
	w becomeActiveDuring: [
		self becomeActiveDuring: [
			anEvent becomeActiveDuring: [
				result := focusHolder processFocusEvent: anEvent]]].
	^ result == #rejected ifTrue: [anEvent] ifFalse: [result "filtered event"]
]

{ #category : #'private events' }
HandMorph >> sendKeyboardEvent: anEvent [ 
	"Send the event to the morph currently holding the focus, or if none to
	the owner of the hand."
	^ self
		sendEvent: anEvent
		focus: self keyboardFocus
		clear: [self keyboardFocus: nil]
]

{ #category : #'private events' }
HandMorph >> sendListenEvent: anEvent to: listenerGroup [
	"Send the event to the given group of listeners"
	listenerGroup ifNil:[^self].
	listenerGroup do:[:listener| 
		listener ifNotNil:[listener handleListenEvent: anEvent copy]].
]

{ #category : #'private events' }
HandMorph >> sendListenEvents: anEvent [
	"Send the given event to all registered event listeners."
	
	self sendListenEvent: anEvent to: self eventListeners.
	
	anEvent isKeyboard
		ifTrue: [self sendListenEvent: anEvent to: self keyboardListeners].
		
	anEvent isMouse
		ifTrue: [self sendListenEvent: anEvent to: self mouseListeners].
]

{ #category : #'private events' }
HandMorph >> sendMouseEvent: anEvent [
	"Send the event to the morph currently holding the focus, or if none to the owner of the hand."
	^self sendEvent: anEvent focus: self mouseFocus clear:[self mouseFocus: nil]
]

{ #category : #drawing }
HandMorph >> shadowForm [
	"Return a 1-bit shadow of my submorphs.  Assumes submorphs is not empty"
	| bnds canvas |
	bnds := Rectangle merging: (submorphs collect: [:m | m fullBounds]).
	canvas := (Display defaultCanvasClass extent: bnds extent depth: 1) 
		asShadowDrawingCanvas: Color black.
	canvas translateBy: bnds topLeft negated
		during:[:tempCanvas| self drawSubmorphsOn: tempCanvas].
	^ canvas form offset: bnds topLeft
]

{ #category : #'drop shadows' }
HandMorph >> shadowOffset [

	^ 6@8
]

{ #category : #'events-debugging' }
HandMorph >> showEvent: anEvent [
	"Show details about the event on the display form. Useful for debugging."
	
	| message borderWidth |
	ShowEvents == true ifFalse: [^ self].
	
	borderWidth := 5.
	message := String streamContents: [:strm |
		strm
			nextPutAll: '[HandMorph >> #showEvent:]'; cr;
			nextPutAll: 'event'; tab; tab; tab; tab; nextPutAll: anEvent printString; cr;
			nextPutAll: 'keyboard focus'; tab; tab; nextPutAll: self keyboardFocus printString; cr;
			nextPutAll: 'mouse focus'; tab; tab; nextPutAll: self mouseFocus printString].
		
	message := message asDisplayText
		foregroundColor: Color black
		backgroundColor: Color white.
	
	"Offset to support multiple hands debugging."
	Display fill: (0 @ 0 extent: message form extent + (borderWidth asPoint * 2)) rule: Form over fillColor: Color white.
	message displayOn: Display at: borderWidth asPoint + (0 @  ((owner hands indexOf: self) - 1 * message form height)).
]

{ #category : #drawing }
HandMorph >> showHardwareCursor: aBool [
	"Show/hide the current hardware cursor as indicated."
	| cursor |
	cursor :=  hardwareCursor ifNil:[aBool ifTrue:[Cursor normal] ifFalse:[Cursor blank]].
	Cursor currentCursor == cursor ifFalse: [cursor show].

]

{ #category : #cursor }
HandMorph >> showTemporaryCursor: cursorOrNil [
	"Set the temporary cursor to the given Form. If the argument is nil, revert to the normal cursor."

	self showTemporaryCursor: cursorOrNil hotSpotOffset: 0@0

]

{ #category : #cursor }
HandMorph >> showTemporaryCursor: cursorOrNil hotSpotOffset: hotSpotOffset [ 
	"Set the temporary cursor to the given Form.
	If the argument is nil, revert to the normal hardware cursor."

	self changed.
	temporaryCursorOffset 
		ifNotNil: [bounds := bounds translateBy: temporaryCursorOffset negated].
	cursorOrNil isNil 
		ifTrue: [temporaryCursor := temporaryCursorOffset := hardwareCursor := nil]
		ifFalse: 
			[temporaryCursor := cursorOrNil asCursorForm.
			temporaryCursorOffset := temporaryCursor offset - hotSpotOffset.
			(cursorOrNil isKindOf: Cursor) ifTrue: [hardwareCursor := cursorOrNil]].
	bounds := self cursorBounds.
	self
		userInitials: userInitials andPicture: self userPicture;
		layoutChanged;
		changed;
		showHardwareCursor: (temporaryCursor isNil).
]

{ #category : #'balloon help' }
HandMorph >> spawnBalloonFor: aMorph [

	aMorph wantsBalloon ifFalse: [^ self].
	aMorph showBalloon: aMorph balloonText hand: self.
]

{ #category : #'halo handling' }
HandMorph >> spawnMagicHaloFor: aMorph [
	
	self halo ifNotNil: [ :halo |
		halo target == aMorph ifTrue:[ ^self ] ].
	aMorph addMagicHaloFor: self.
]

{ #category : #accessing }
HandMorph >> targetOffset [
	"Return the offset of the last mouseDown location relative to the origin of the recipient morph. During menu interactions, this is the absolute location of the mouse down event that invoked the menu."

	^ targetOffset

]

{ #category : #'grabbing\/dropping' }
HandMorph >> targetOffset: offsetPoint [
	"Set the offset at which we clicked down in the target morph"

	targetOffset := offsetPoint
]

{ #category : #accessing }
HandMorph >> targetPoint [
	"Return the new position of the target.
	I.E. return the position of the hand less 
	the original distance between hand and target position"

	^ self position - targetOffset

]

{ #category : #cursor }
HandMorph >> temporaryCursor [
	^ temporaryCursor
]

{ #category : #'balloon help' }
HandMorph >> triggerBalloonFor: aMorph after: timeOut [
	"Trigger balloon help after the given time out for some morph"
	self addAlarm: #spawnBalloonFor: with: aMorph after: timeOut.
]

{ #category : #'halo handling' }
HandMorph >> triggerHaloFor: aMorph after: timeOut [
	"Trigger automatic halo after the given time out for some morph"
	self addAlarm: #spawnMagicHaloFor: with: aMorph after: timeOut
]

{ #category : #'gridded cursor' }
HandMorph >> turnOffGridding [
	"remove the gridding properties to stop gridding"
	self removeProperty: #gridStep; removeProperty: #gridOffset
]

{ #category : #drawing }
HandMorph >> updateCacheCanvas: aCanvas [ 
	"Update the cached image of the morphs being held by this hand."

	"Note: The following is an attempt to quickly get out if there's no change"

	| subBnds rectList nPix |
	subBnds := Rectangle merging: (submorphs collect: [:m | m fullBounds]).
	rectList := damageRecorder invalidRectsFullBounds: subBnds.
	damageRecorder reset.
	(rectList isEmpty 
		and: [cacheCanvas notNil and: [cacheCanvas extent = subBnds extent]]) 
			ifTrue: [^self].

	"Always check for real translucency -- can't be cached in a form"
	self submorphsDo: 
			[:m | 
			m wantsToBeCachedByHand 
				ifFalse: 
					[cacheCanvas := nil.
					cachedCanvasHasHoles := true.
					^self]].
	(cacheCanvas isNil or: [cacheCanvas extent ~= subBnds extent]) 
		ifTrue: 
			[cacheCanvas := (aCanvas allocateForm: subBnds extent) getCanvas.
			cacheCanvas translateBy: subBnds origin negated
				during: [:tempCanvas | self drawSubmorphsOn: tempCanvas].
			self submorphsDo: 
					[:m | 
					(m areasRemainingToFill: subBnds) isEmpty 
						ifTrue: [^cachedCanvasHasHoles := false]].
			nPix := cacheCanvas form tallyPixelValues first.
			"--> begin rounded corners hack <---"
			cachedCanvasHasHoles := (nPix = 48 
						and: [submorphs size = 1 and: [submorphs first wantsRoundedCorners]]) 
							ifTrue: [false]
							ifFalse: [nPix > 0].
			"--> end rounded corners hack <---"
			^self].

	"incrementally update the cache canvas"
	cacheCanvas translateBy: subBnds origin negated
		during: 
			[:cc | 
			rectList do: 
					[:r | 
					cc clipBy: r
						during: 
							[:c | 
							c fillColor: Color transparent.
							self drawSubmorphsOn: c]]]
]

{ #category : #accessing }
HandMorph >> userInitials [

	^ userInitials
]

{ #category : #geometry }
HandMorph >> userInitials: aString andPicture: aForm [

	| cb pictRect initRect f |

	userInitials := aString.
	pictRect := initRect := cb := self cursorBounds.
	userInitials isEmpty ifFalse: [
		f := TextStyle defaultFont.
		initRect := cb topRight + (0@4) extent: (f widthOfString: userInitials)@(f height).
	].
	self userPicture: aForm.
	aForm ifNotNil: [
		pictRect := (self cursorBounds topRight + (0@24)) extent: aForm extent.
	].
	self bounds: ((cb merge: initRect) merge: pictRect).



]

{ #category : #accessing }
HandMorph >> userPicture [
	^self valueOfProperty: #remoteUserPicture


]

{ #category : #accessing }
HandMorph >> userPicture: aFormOrNil [
	^self setProperty: #remoteUserPicture toValue: aFormOrNil

]

{ #category : #copying }
HandMorph >> veryDeepCopyWith: deepCopier [
	"Return self.  Do not copy hands this way."
	^ self
]

{ #category : #drawing }
HandMorph >> visible: aBoolean [
	self needsToBeDrawn ifFalse: [ ^self ].
	super visible: aBoolean
]

{ #category : #'double click support' }
HandMorph >> waitForClicksOrDrag: aMorph event: evt [
	"Wait for mouse button and movement events, informing aMorph about events interesting to it via callbacks.
	This message is typically sent to the Hand by aMorph when it first receives a mouse-down event.
	The callback methods invoked on aMorph (which are passed a copy of evt) are:
		#click:	sent when the mouse button goes up within doubleClickTime.
		#doubleClick:	sent when the mouse goes up, down, and up again all within DoubleClickTime.
		#doubleClickTimeout:  sent when the mouse does not have a doubleClick within DoubleClickTime.
		#startDrag:	sent when the mouse moves more than 10 pixels from evt's position within DoubleClickTime.
	Note that mouseMove: and mouseUp: events are not sent to aMorph until it becomes the mouse focus,
	which is typically done by aMorph in its click:, doubleClick:, or drag: methods."
	
	^self waitForClicksOrDrag: aMorph event: evt selectors: #( #click: #doubleClick: #doubleClickTimeout: #startDrag:) threshold: HandMorph dragThreshold
]

{ #category : #'double click support' }
HandMorph >> waitForClicksOrDrag: aMorph event: evt selectors: clickAndDragSelectors threshold: threshold [

	"Wait for mouse button and movement events, informing aMorph about events interesting to it via callbacks.
	This message is typically sent to the Hand by aMorph when it first receives a mouse-down event.
	The callback methods, named in clickAndDragSelectors and passed a copy of evt, are:
		1 	(click) sent when the mouse button goes up within doubleClickTime.
		2	(doubleClick) sent when the mouse goes up, down, and up again all within DoubleClickTime.
		3	(doubleClickTimeout) sent when the mouse does not have a doubleClick within DoubleClickTime.
		4	(startDrag) sent when the mouse moves more than threshold pixels from evt's position within DoubleClickTime.
	Note that mouseMove: and mouseUp: events are not sent to aMorph until it becomes the mouse focus,
	which is typically done by aMorph in its click:, doubleClick:, or drag: methods."
	
	mouseClickState := 
		MouseClickState new
			client: aMorph 
			click: clickAndDragSelectors first 
			dblClick: clickAndDragSelectors second 
			dblClickTime: DoubleClickTime 
			dblClickTimeout: clickAndDragSelectors third
			drag: clickAndDragSelectors fourth 
			threshold: threshold 
			event: evt.

]
