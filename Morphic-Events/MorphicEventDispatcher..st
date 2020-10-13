"
The class represents a strategy for dispatching events to some immediate child of a morph. It is used by morphs to delegate the somewhat complex action of dispatching events accurately. 
"
Class {
	#name : #MorphicEventDispatcher,
	#superclass : #Object,
	#instVars : [
		'lastType',
		'lastDispatch'
	],
	#category : #'Morphic-Events'
}

{ #category : #specific }
MorphicEventDispatcher >> dispatchDefault: anEvent with: aMorph [
	"Dispatch the given event. The event will be passed to the front-most visible submorph that contains the position wrt. to the event."

	"Try to get out quickly"
	anEvent wasIgnored ifTrue: [^anEvent "propagate the ignored event"].
	(aMorph fullBounds containsPoint: anEvent position) ifFalse:[^#rejected].

	^ self
		dispatchEvent: anEvent
		withHandler: aMorph
		withMorph: aMorph
]

{ #category : #specific }
MorphicEventDispatcher >> dispatchDropEvent: anEvent with: aMorph [
	"Find the appropriate receiver for the event and let it handle it. The dispatch is similar to the default dispatch with one difference: Morphs are given the chance to reject an entire drop operation. If the operation is rejected, no drop will be executed."

	"Try to get out quickly"
	anEvent wasIgnored ifTrue: [^anEvent "propagate the ignored event"].
	(aMorph fullBounds containsPoint: anEvent position) ifFalse:[^#rejected].

	"Give aMorph a chance to repel the dropping morph"
	aMorph rejectDropEvent: anEvent.
	anEvent wasHandled ifTrue:[^anEvent].

	^ self
		dispatchEvent: anEvent
		withHandler: aMorph
		withMorph: aMorph
]

{ #category : #support }
MorphicEventDispatcher >> dispatchEvent: anEvent toSubmorphsOf: aMorph [
	"Dispatch the given event to the submorphs of the given morph. For coordinate transformations, work only with copies. Either return the given event or a copy of any filtered event to employ immutability to some extent. --- PRIVATE!"

	| localEvent filteredEvent |	
	aMorph submorphsDo: [:child |
		localEvent := anEvent transformedBy: (child transformedFrom: aMorph).
		filteredEvent := child processEvent: localEvent.
		filteredEvent == #rejected ifFalse: [ "some event or #rejected symbol or any other object"
			filteredEvent isMorphicEvent ifFalse: [filteredEvent := localEvent].		
			self flag: #overlappingChildren. "mt: We cannot give two overlapping siblings the chance to handle the event!"	
			^ self nextFromOriginal: anEvent local: localEvent filtered: filteredEvent]].

	^ #rejected
]

{ #category : #dispatching }
MorphicEventDispatcher >> dispatchEvent: anEvent with: aMorph [
	"Dispatch the given event for a morph that has chosen the receiver to dispatch its events. The method implements a shortcut for repeated dispatches of events using the same dispatcher."
	anEvent type == lastType ifTrue:[^self perform: lastDispatch with: anEvent with: aMorph].
	"Otherwise classify"
	lastType := anEvent type.
	anEvent isMouse ifTrue:[
		anEvent isMouseDown ifTrue:[
			lastDispatch := #dispatchMouseDown:with:.
			^self dispatchMouseDown: anEvent with: aMorph]].
	anEvent type == #dropEvent ifTrue:[
		lastDispatch := #dispatchDropEvent:with:.
		^self dispatchDropEvent: anEvent with: aMorph].
	anEvent isWindowEvent ifTrue:[
		lastDispatch := #dispatchWindowEvent:with:.
		^self dispatchWindowEvent: anEvent with: aMorph].
	lastDispatch := #dispatchDefault:with:.
	^self dispatchDefault: anEvent with: aMorph
]

{ #category : #support }
MorphicEventDispatcher >> dispatchEvent: anEvent withHandler: aHandler withMorph: aMorph [
	"Perform the actual event dispatch. Use the given object as handler. Ask submorphs first to handle the event. Then bubble up. Stop if ignored. Note that event rejection and event filters are two separete concepts. Filters come from the outside. Rejection is a morph's decision.
	
	* The top-most chain of visible, unlocked morphs containing the event position will get a chance to handle the event.
	* When travelling up, the prospective handler is always executed. The handler needs to check if the event was handled before as well as checking if somebody else's handler has been installed.
	* If another handler has been installed but the event was not handled it means that somebody up in the hierarchy wants to handle the event."
	
	| result filteredEvent |
	
	result := self dispatchEvent: anEvent toSubmorphsOf: aMorph.

	result == #rejected "Anybody?"
		ifFalse: [filteredEvent := result]
		ifTrue: [
			"My submorphs did not want it. Do I want it anyway? It's about locked children..."
			(aMorph containsPoint: anEvent position event: anEvent)
				ifFalse: [^ #rejected].
			filteredEvent := anEvent "there was no filtering, only basic rejects"].
	
	"Receiver is in the top-most unlocked, visible chain."
	(aHandler notNil and: [filteredEvent wasIgnored not])
		ifTrue: [filteredEvent := aHandler handleEvent: filteredEvent].

	^ filteredEvent
]

{ #category : #'focus events' }
MorphicEventDispatcher >> dispatchFocusEvent: anEventWithGlobalPosition with: focusMorph [
	"Dispatch the given event to the given morph. Simulate capturing phase, handle the event, then do bubbling."

	| currentEvent |
	"1) Capturing phase."
	currentEvent := self doCapturingForFocusEvent: anEventWithGlobalPosition with: focusMorph.
	currentEvent == #rejected ifTrue: [
		"See implementors of #rejectsEvent:, which is usually based on receiver state and not event state. Thus, reset foci to avoid unresponsive environment."
		anEventWithGlobalPosition hand
			releaseKeyboardFocus: focusMorph;
			releaseMouseFocus: focusMorph.
		^ #rejected].
	"No need to reset foci here for ignored events because not all events might be ignored. Unlike #rejected."
	currentEvent wasIgnored ifTrue: [^ currentEvent].
	
	"2) No sub-tree processing here. Use #dispatchFocusEventFully:with: if you want that, too."
	
	"3) Let the focus morph handle the event." 
	currentEvent := self doHandlingForFocusEvent: currentEvent with: focusMorph.
	currentEvent wasIgnored ifTrue: [^ currentEvent].
	
	"4) Bubbling phase"
	^ self doBubblingForFocusEvent: currentEvent with: focusMorph
]

{ #category : #'focus events' }
MorphicEventDispatcher >> dispatchFocusEventAllOver: evt with: focusMorph [
	"Like a full event dispatch BUT adds regular dispatch if the focus morph did nothing with the event. This is useful for letting the focusMorph's siblings handle the events instead. Take halo invocation as an example. See senders of me."
	
	| result hand mouseFocus |
	result := self dispatchFocusEventFully: evt with: focusMorph.
	
	evt isMouseOver ifTrue: [^ result]. 
	
	result == #rejected ifTrue: [^ result].
	result wasIgnored ifTrue: [^ result].
	result wasHandled ifTrue: [^ result].

	hand := evt hand.
	mouseFocus := hand mouseFocus.

	[
		"Avoid re-dispatching the event to the focus morph. See Morph >> #rejectsEvent:."
		focusMorph lock.
		hand newMouseFocus: nil.
		
		"Give the event's hand a chance to normally dispatch it."
		^ hand handleEvent: evt
	] ensure: [
		focusMorph unlock.
		hand newMouseFocus: mouseFocus].
]

{ #category : #'focus events' }
MorphicEventDispatcher >> dispatchFocusEventFully: anEventWithGlobalPosition with: focusMorph [
	"Dispatch the given event to the given morph. Do capturing, processing in sub-tree, and bubbling."
	
	| currentEvent |
	"1) Capturing phase."
	currentEvent := self doCapturingForFocusEvent: anEventWithGlobalPosition with: focusMorph.
	currentEvent == #rejected ifTrue: [
		"See implementors of #rejectsEvent:, which is usually based on receiver state and not event state. Thus, reset foci to avoid unresponsive environment."
		anEventWithGlobalPosition hand
			releaseKeyboardFocus: focusMorph;
			releaseMouseFocus: focusMorph.
		^ #rejected].
	"No need to reset foci here for ignored events because not all events might be ignored. Unlike #rejected."
	currentEvent wasIgnored ifTrue: [^ currentEvent].
	
	"2) Sub-tree processing."
	currentEvent := self doProcessingForFocusEvent: currentEvent with: focusMorph.
	currentEvent wasIgnored ifTrue: [^ currentEvent].

	"3) Let the focus morph handle the event. Usually no effect because previous sub-tree processing involved the focus morph already -- at least in the bubbling phase. Skip it?"
	currentEvent := self doHandlingForFocusEvent: currentEvent with: focusMorph.
	currentEvent wasIgnored ifTrue: [^ currentEvent].
	
	"4) Bubbling phase."
	^ self doBubblingForFocusEvent: currentEvent with: focusMorph
]

{ #category : #specific }
MorphicEventDispatcher >> dispatchMouseDown: anEvent with: aMorph [
	"Find the appropriate receiver for the event and let it handle it. When travelling down the hierarchy a prospective handler for the event is installed. This prospective handler can be used by submorphs wishing to handle the mouse down for negotiating who the receiver is."
	
	| handler lastHandler |
	
	"Try to get out quickly"
	anEvent wasIgnored ifTrue: [^anEvent "propagate the ignored event"].
	(aMorph fullBounds containsPoint: anEvent position) ifFalse:[^#rejected].

	"In case the mouse wasn't even in the receiver"
	lastHandler := anEvent handler. 

	"Negotiate and install the actual handler."
	handler := aMorph handlerForMouseDown: anEvent.
	handler ifNotNil: [anEvent handler: handler].

	[^ self
		dispatchEvent: anEvent
		withHandler: handler
		withMorph: aMorph
	] ensure: [
		anEvent handler: lastHandler. "good style"].
]

{ #category : #specific }
MorphicEventDispatcher >> dispatchWindowEvent: anEvent with: aMorph [
	"Host window events do not have a position and are only dispatched to the World"

	anEvent wasIgnored ifTrue: [^anEvent].
	aMorph isWorldMorph ifFalse: [^#rejected].
	anEvent wasHandled ifTrue:[^anEvent].
	^aMorph handleEvent: anEvent
]

{ #category : #support }
MorphicEventDispatcher >> doBubblingForFocusEvent: anEvent with: focusMorph [
	"Simulate real event bubbling up to the focused morph's outermost owner. Applies event bubble filters via Morph >> #handleEvent:. Watch out for coordinate transformations and some globals (ActiveWorld, ...)."

	| currentEvent filteredEvent localEvent referenceMorph |
	currentEvent := anEvent.
	referenceMorph := anEvent hand.

	focusMorph allOwnersDo: [:ownerMorph |
		ownerMorph == anEvent hand ifFalse: [ "Never bubble up to the hand morph but only up to the world."
			localEvent := currentEvent transformedBy: (ownerMorph transformedFrom: referenceMorph).
			filteredEvent := ownerMorph handleEvent: localEvent.
			currentEvent := self nextFromOriginal: currentEvent local: localEvent filtered: filteredEvent.
			currentEvent wasIgnored ifTrue: [^ currentEvent]]].

	^ currentEvent
]

{ #category : #support }
MorphicEventDispatcher >> doCapturingForFocusEvent: anEvent with: focusMorph [
	"Simulate real event capturing down to the focused morph. Apply event capture filters. Watch out for coordinate transformations. Keep the filter-ignore-reject order like in Morph >> #processEvent:using:."

	| currentEvent filteredEvent localEvent referenceMorph |
	currentEvent := anEvent.
	referenceMorph := anEvent hand.

	"Event capturing. Filters only because the capturing phase was bypassed by using the keyboard/mouse focus."
	focusMorph withAllOwners reverseDo: [:ownerMorph | "reverse order to comply with regular dispatching"
		ownerMorph == anEvent hand ifFalse: [ "Never dispatch the hand morph. It already did so."
			localEvent := currentEvent transformedBy: (ownerMorph transformedFrom: referenceMorph).
			
			filteredEvent := ownerMorph sendFilterEventCapture: localEvent for: ownerMorph.
			
			"Ignoring has higher priority but the reject-check must be with local event coodinates."
			(filteredEvent wasIgnored not and: [ownerMorph rejectsEvent: filteredEvent])
				ifTrue: [^ #rejected].
			
			currentEvent := self nextFromOriginal: currentEvent local: localEvent filtered: filteredEvent.
			currentEvent wasIgnored ifTrue: [^ currentEvent]]].
	
	^ currentEvent
]

{ #category : #support }
MorphicEventDispatcher >> doHandlingForFocusEvent: currentEvent with: focusMorph [

	| localEvent filteredEvent |
	localEvent := currentEvent transformedBy: (focusMorph transformedFrom: currentEvent hand).
	filteredEvent := focusMorph handleFocusEvent: localEvent.
	^ self nextFromOriginal: currentEvent local: localEvent filtered: filteredEvent.
]

{ #category : #support }
MorphicEventDispatcher >> doProcessingForFocusEvent: currentEvent with: focusMorph [
	"Sub-tree processing (including capturing from focus morph down to something and bubbling up back to focus morph). Never reject in the end."
	
	| localEvent filteredEvent |
	localEvent := currentEvent transformedBy: (focusMorph transformedFrom: currentEvent hand).
	filteredEvent := focusMorph processEvent: localEvent using: self.
	^ filteredEvent == #rejected
		ifTrue: [currentEvent] "Can happen if you click, e.g., outside the bounds of the focus morph"
		ifFalse: [self nextFromOriginal: currentEvent local: localEvent filtered: filteredEvent]
]

{ #category : #support }
MorphicEventDispatcher >> nextFromOriginal: originalEvent local: localEvent filtered: filteredEvent [
	"Take the filtered event if different but always keep the original coordinates."
	
	filteredEvent == localEvent
		ifTrue: [ "Use original event but keep track of ignored flag."
			localEvent wasHandled ifTrue: [originalEvent copyHandlerState: localEvent].
			originalEvent wasIgnored: localEvent wasIgnored.
			^ originalEvent]
		ifFalse: [ "There was an event transformation. Copy, revert coordinates, keep handler state."
			| result |
			result := filteredEvent copy. "Never mutate position without copying. MouseClickState etc. will break otherwise."
			result translateTo: originalEvent position. "restore to untransformed coordinates"
			result wasHandled ifFalse: [result copyHandlerState: originalEvent].
			^ result].

]
