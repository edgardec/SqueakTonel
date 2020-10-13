"
This subclass of PasteUpMorph provides special support for viewing of a world in an inner window (WorldWindow).
"
Class {
	#name : #WiWPasteUpMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'parentWorld',
		'hostWindow',
		'pendingEvent',
		'displayChangeSignatureOnEntry'
	],
	#classVars : [
		'Debug'
	],
	#category : #'Etoys-Squeakland-Morphic-Worlds'
}

{ #category : #'as yet unclassified' }
WiWPasteUpMorph class >> say: x [

	(Debug ifNil: [Debug := OrderedCollection new])
		add: x asString,'
'.
	Debug size > 500 ifTrue: [Debug := Debug copyFrom: 200 to: Debug size]
]

{ #category : #'as yet unclassified' }
WiWPasteUpMorph class >> show [

	Debug inspect.
	Debug := OrderedCollection new.
]

{ #category : #activation }
WiWPasteUpMorph >> becomeTheActiveWorldWith: evt [
	"Make the receiver become the active world, and give its hand the event provided, if not nil"

	| outerWorld |
	Project current world == self ifTrue: [^ self].
	worldState resetDamageRecorder.	"since we may have moved, old data no longer valid"
	hostWindow setStripeColorsFrom: Color green.
	worldState canvas: nil.	"safer to start from scratch"
	displayChangeSignatureOnEntry := Display displayChangeSignature.

	"Messy stuff to clear flaps from outer world"
	Flaps globalFlapTabsIfAny do: [:f | f changed].
	outerWorld := Project current world.
	Project current setWorld: self.
	self installFlaps.
	Project current setWorld: outerWorld.
	outerWorld displayWorld.
	Project current setWorld: self.

	self viewBox: hostWindow panelRect.
	self startSteppingSubmorphsOf: self.
	self changed.
	pendingEvent := nil.
	evt ifNotNil: [self primaryHand handleEvent: (evt setHand: self primaryHand)].


]

{ #category : #'world state' }
WiWPasteUpMorph >> displayWorld [

	"RAA 27 Nov 99 - if we are not active, then the parent should do the drawing"

	self flag: #bob.			"probably not needed"

	Project current world == self ifTrue: [^super displayWorld].
	parentWorld ifNotNil: [^parentWorld displayWorld].
	^super displayWorld		"in case MVC needs it"
]

{ #category : #'update cycle' }
WiWPasteUpMorph >> doDeferredUpdating [
	"If this platform supports deferred updates, then make my canvas be the Display (or a rectangular portion of it), set the Display to deferred update mode, and answer true. Otherwise, do nothing and answer false. One can set the class variable DisableDeferredUpdates to true to completely disable the deferred updating feature."

	PasteUpMorph disableDeferredUpdates ifTrue: [^ false].
	(Display deferUpdates: true) ifNil: [^ false].  "deferred updates not supported"

	self resetViewBox.
	^ true

]

{ #category : #'world state' }
WiWPasteUpMorph >> doOneCycle [

	pendingEvent ifNotNil: [
		self primaryHand handleEvent: (pendingEvent setHand: self primaryHand).
		pendingEvent := nil.
	].
	^super doOneCycle.
]

{ #category : #geometry }
WiWPasteUpMorph >> extent: x [

	super extent: x.
	self resetViewBox.
]

{ #category : #'world state' }
WiWPasteUpMorph >> goBack [
	"Return to the previous project.  For the moment, this is not allowed from inner worlds"

	self inform: 'Project changes are not yet allowed
from inner worlds.'
]

{ #category : #initialization }
WiWPasteUpMorph >> hostWindow: x [

	hostWindow := x.
	worldState canvas: nil.	"safer to start from scratch"
	self viewBox: hostWindow panelRect.

]

{ #category : #initialization }
WiWPasteUpMorph >> initialize [

	super initialize.
	parentWorld := Project current world.

]

{ #category : #'world state' }
WiWPasteUpMorph >> jumpToProject [
	"Jump directly to another project.  However, this is not currently allowed for inner worlds"

	self inform: 'Project changes are not yet allowed
from inner worlds.'
]

{ #category : #'event handling' }
WiWPasteUpMorph >> mouseDown: evt [

	| world |
	world := Project current world.
	(world == self or: [world isNil]) ifTrue: [^ super mouseDown: evt].
	(self bounds containsPoint: evt cursorPoint) ifFalse: [^ self].

	self becomeTheActiveWorldWith: evt.

]

{ #category : #geometry }
WiWPasteUpMorph >> resetViewBox [
	| c |
	(c := worldState canvas) isNil ifTrue: [^self resetViewBoxForReal].
	c form == Display ifFalse: [^self resetViewBoxForReal].
	c origin = (0 @ 0) ifFalse: [^self resetViewBoxForReal].
	c clipRect extent = (self viewBox intersect: parentWorld viewBox) extent 
		ifFalse: [^self resetViewBoxForReal]
]

{ #category : #geometry }
WiWPasteUpMorph >> resetViewBoxForReal [

	| newClip |
	self viewBox ifNil: [^self].
	newClip := self viewBox intersect: parentWorld viewBox.
	worldState canvas: (
		Display getCanvas
			copyOffset:  0@0
			clipRect: newClip
	)
]

{ #category : #'WiW support' }
WiWPasteUpMorph >> restartWorldCycleWithEvent: evt [

	"redispatch that click in outer world"

	pendingEvent := evt.
	CurrentProjectRefactoring currentSpawnNewProcessAndTerminateOld: true

]

{ #category : #'world state' }
WiWPasteUpMorph >> restoreDisplay [

	Project current world ifNotNil: [ :w | w restoreMorphicDisplay].
	"Comment from original method ar 3/18/2001: I don't actually expect this to be called"
]

{ #category : #activation }
WiWPasteUpMorph >> revertToParentWorldWithEvent: evt [

	"RAA 27 Nov 99 - if the display changed while we were in charge, parent may need to redraw"

	worldState resetDamageRecorder.	"Terminate local display"
	Project current setWorld: parentWorld.
	parentWorld assuredCanvas.
	parentWorld installFlaps.
	hostWindow setStripeColorsFrom: Color red.
	(displayChangeSignatureOnEntry = Display displayChangeSignature) ifFalse: [
		parentWorld fullRepaintNeeded; displayWorld
	].
	evt ifNotNil: [parentWorld restartWorldCycleWithEvent: evt].


]

{ #category : #'WiW support' }
WiWPasteUpMorph >> validateMouseEvent: evt [

	evt isMouseDown ifFalse: [^ self].

	"any click outside returns us to our home world"
	(self bounds containsPoint: evt cursorPoint) ifFalse: [
		self revertToParentWorldWithEvent: evt.
	].
]

{ #category : #'project state' }
WiWPasteUpMorph >> viewBox: newViewBox [ 
	| vb |
	worldState resetDamageRecorder.	"since we may have moved, old data no longer valid"
	((vb := self viewBox) isNil or: [vb ~= newViewBox]) 
		ifTrue: [worldState canvas: nil].
	worldState viewBox: newViewBox.
	bounds := newViewBox.
	worldState assuredCanvas.
	"Paragraph problem workaround; clear selections to avoid screen droppings:"
	self flag: #arNote.	"Probably unnecessary"
	worldState handsDo: [:h | h releaseKeyboardFocus].
	self fullRepaintNeeded
]
