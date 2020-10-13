"
I am a hand for replaying events stored in an EventRecorderMorph.  When there are no more events, I delete myself.
"
Class {
	#name : #HandMorphForReplay,
	#superclass : #HandMorph,
	#instVars : [
		'recorder',
		'suspended'
	],
	#category : #'MorphicExtras-AdditionalSupport'
}

{ #category : #initialization }
HandMorphForReplay >> initialize [
	"Initialize the receiver."

	super initialize.
	suspended := false.
	self showTemporaryCursor: Cursor normal

]

{ #category : #drawing }
HandMorphForReplay >> needsToBeDrawn [

	^true
]

{ #category : #'event handling' }
HandMorphForReplay >> pauseEventRecorderIn: aWorld [
	"Suspend my recorder prior to a project change, and return it.
	It will be resumed after starting the new project."

	^ recorder pauseIn: aWorld
]

{ #category : #'event handling' }
HandMorphForReplay >> processEvents [
	"Play back the next event"

	| evt hadMouse hadAny tracker  |
	suspended == true ifTrue: [^ self].
	hadMouse := hadAny := false.
	tracker := recorder objectTrackingEvents.
	[(evt := recorder nextEventToPlay) isNil] whileFalse: 
			[
			((evt isMemberOf: MouseMoveEvent) and: [evt trail isNil]) ifTrue: [^ self].
			tracker ifNotNil: [tracker currentEventTimeStamp: evt timeStamp].
			evt type == #EOF 
				ifTrue: 
					[recorder pauseIn: self currentWorld.
					^ self].
			evt type == #startSound 
				ifTrue: 
					[recorder perhapsPlaySound: evt argument.
					recorder synchronize.
					^ self].
			evt type == #startEventPlayback 
				ifTrue: 
					[evt argument launchPlayback.
					recorder synchronize.
					^ self].

			evt type == #noteTheatreBounds 
				ifTrue: 
					["The argument holds the content rect --for now we don't make any use of that info in this form."
					^ self].

			evt isMouse ifTrue: [hadMouse := true].
			(evt isMouse or: [evt isKeyboard]) 
				ifTrue: 
					[self handleEvent: (evt setHand: self) resetHandlerFields.
					hadAny := true]].
	(mouseClickState notNil and: [hadMouse not]) 
		ifTrue: 
			["No mouse events during this cycle. Make sure click states time out accordingly"

			mouseClickState handleEvent: lastMouseEvent asMouseMove from: self].
	hadAny 
		ifFalse: 
			["No pending events. Make sure z-order is up to date"

			self mouseOverHandler processMouseOver: lastMouseEvent]
]

{ #category : #initialization }
HandMorphForReplay >> recorder: anEventRecorder [
	recorder := anEventRecorder
]

{ #category : #cursor }
HandMorphForReplay >> showTemporaryCursor: cursorOrNil hotSpotOffset: hotSpotOffset [
	"When I show my cursor, it appears double size,
	unless it is a form such as a paint brush."

	cursorOrNil
	ifNil: ["Setting cursor to nil cannot revert to hardware cursor -- just show normal."
			^ self showTemporaryCursor: Cursor normal hotSpotOffset: Cursor normal offset]
	ifNotNil:
		[(cursorOrNil isKindOf: Cursor)
			ifTrue: ["Show cursors magnified for visibility"
					^ super showTemporaryCursor: (cursorOrNil asCursorForm magnifyBy: 2)
				 				hotSpotOffset: (cursorOrNil offset negated*2) + hotSpotOffset]
			ifFalse: [^ super showTemporaryCursor: cursorOrNil
				 				hotSpotOffset: hotSpotOffset]]
]

{ #category : #copying }
HandMorphForReplay >> veryDeepCopyWith: deepCopier [
	"Handmorph blocks deep copy.  Go up to Morph"

	^ self perform: #veryDeepCopyWith: withArguments: {deepCopier} inSuperclass: Morph
]
