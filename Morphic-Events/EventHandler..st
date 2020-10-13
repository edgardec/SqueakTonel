"
Events in Morphic originate in a Hand, pass to a target morph, and are then dispatched by an EventHandler.  EventHandlers support redirection of mouse and keyboard activity by specifying and independent recipient object and message selector for each of the possible events.  In addition each eventHandler can supply an optional value parameter for distinguishing between, eg, events from a number of otherwise identical source morphs.

The basic protocol of an event handler is to receive a message of the form
	mouseDown: event in: targetMorph
and redirect this as one of
	mouseDownRecipient perform: mouseDownSelector0
	mouseDownRecipient perform: mouseDownSelector1 with: event
	mouseDownRecipient perform: mouseDownSelector2 with: event with: targetMorph
	mouseDownRecipient perform: mouseDownSelector3 with: event with: targetMorph with: valueParameter
depending on the arity of the mouseDownSelector.

"
Class {
	#name : #EventHandler,
	#superclass : #Object,
	#instVars : [
		'mouseDownRecipient',
		'mouseDownSelector',
		'mouseMoveRecipient',
		'mouseMoveSelector',
		'mouseStillDownRecipient',
		'mouseStillDownSelector',
		'mouseUpRecipient',
		'mouseUpSelector',
		'mouseEnterRecipient',
		'mouseEnterSelector',
		'mouseLeaveRecipient',
		'mouseLeaveSelector',
		'mouseEnterDraggingRecipient',
		'mouseEnterDraggingSelector',
		'mouseLeaveDraggingRecipient',
		'mouseLeaveDraggingSelector',
		'mouseWheelRecipient',
		'mouseWheelSelector',
		'keyStrokeRecipient',
		'keyStrokeSelector',
		'keyUpRecipient',
		'keyUpSelector',
		'keyDownRecipient',
		'keyDownSelector',
		'valueParameter',
		'startDragRecipient',
		'startDragSelector',
		'doubleClickSelector',
		'doubleClickRecipient',
		'doubleClickTimeoutSelector',
		'doubleClickTimeoutRecipient',
		'clickSelector',
		'clickRecipient',
		'keyboardFocusChangeRecipient',
		'keyboardFocusChangeSelector',
		'wantsEveryMouseMove'
	],
	#category : #'Morphic-Events'
}

{ #category : #access }
EventHandler >> allRecipients [
	"Answer a list, without duplication, of all the objects serving as recipients to any of the events I handle.  Intended for debugging/documentation use only"
	| aList |
	aList := OrderedCollection with: mouseDownRecipient with: mouseStillDownRecipient with: mouseUpRecipient with: mouseEnterRecipient with: mouseLeaveRecipient.
	aList addAll: (OrderedCollection with:  mouseEnterDraggingRecipient with: mouseLeaveDraggingRecipient with: doubleClickRecipient with: keyStrokeRecipient).
	aList add: mouseMoveRecipient.
	^ (aList copyWithout: nil) asSet asArray
]

{ #category : #events }
EventHandler >> click: event fromMorph: sourceMorph [ 
	"This message is sent only when double clicks are handled."
	^ self
		send: clickSelector
		to: clickRecipient
		withEvent: event
		fromMorph: sourceMorph
]

{ #category : #'objects from disk' }
EventHandler >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	"20 dec 2000 - only a few (old) conversion exists"

	varDict at: 'mouseEnterLadenRecipient' ifPresent: [ :x | mouseEnterDraggingRecipient := x].
	varDict at: 'mouseEnterLadenSelector' ifPresent: [ :x | mouseEnterDraggingSelector := x].
	varDict at: 'mouseLeaveLadenRecipient' ifPresent: [ :x | mouseLeaveDraggingRecipient := x].
	varDict at: 'mouseLeaveLadenSelector' ifPresent: [ :x | mouseLeaveDraggingSelector := x].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #events }
EventHandler >> doubleClick: event fromMorph: sourceMorph [ 
	^ self
		send: doubleClickSelector
		to: doubleClickRecipient
		withEvent: event
		fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> doubleClickTimeout: event fromMorph: sourceMorph [ 
	^ self
		send: doubleClickTimeoutSelector
		to: doubleClickTimeoutRecipient
		withEvent: event
		fromMorph: sourceMorph
]

{ #category : #access }
EventHandler >> firstMouseSelector [
	"Answer the selector corresponding to the first mouse-handling selector fielded.  Created in support of providing balloon-help for halo handles, triggered by the selector handled"

	mouseDownSelector ifNotNil: [^ mouseDownSelector].
	mouseMoveSelector ifNotNil:[^mouseMoveSelector].
	mouseStillDownSelector ifNotNil: [^ mouseStillDownSelector].
	mouseUpSelector ifNotNil: [^ mouseUpSelector].
	mouseEnterSelector ifNotNil: [^ mouseEnterSelector].
	mouseLeaveSelector ifNotNil: [^ mouseLeaveSelector].
	mouseEnterDraggingSelector ifNotNil: [^ mouseEnterDraggingSelector].
	mouseLeaveDraggingSelector ifNotNil: [^ mouseLeaveDraggingSelector].
	doubleClickSelector ifNotNil: [^ doubleClickSelector].
	^ nil
]

{ #category : #fixups }
EventHandler >> fixReversedValueMessages [
	"ar 3/18/2001: Due to the change in the ordering of the value parameter old event handlers may have messages that need to be fixed up. Do this here."

	self replaceSendsIn: #( renameCharAction:sourceMorph:requestor: makeGetter:from:forPart: makeSetter:from:forPart: newMakeGetter:from:forPart: newMakeSetter:from:forPart: clickOnLine:evt:envelope: limitHandleMoveEvent:from:index: mouseUpEvent:linkMorph:formData: mouseUpEvent:linkMorph:browserAndUrl: mouseDownEvent:noteMorph:pitch: mouseMoveEvent:noteMorph:pitch: mouseUpEvent:noteMorph:pitch: dragVertex:fromHandle:vertIndex: dropVertex:fromHandle:vertIndex: newVertex:fromHandle:afterVert: prefMenu:rcvr:pref: event:arrow:upDown:
newMakeGetter:from:forMethodInterface:)
			with: #( renameCharAction:event:sourceMorph: makeGetter:event:from: makeSetter:event:from: newMakeGetter:event:from: newMakeSetter:event:from: clickOn:evt:from: limitHandleMove:event:from: mouseUpFormData:event:linkMorph: mouseUpBrowserAndUrl:event:linkMorph: mouseDownPitch:event:noteMorph: mouseMovePitch:event:noteMorph: mouseUpPitch:event:noteMorph: dragVertex:event:fromHandle: dropVertex:event:fromHandle: newVertex:event:fromHandle: prefMenu:event:rcvr: upDown:event:arrow: makeUniversalTilesGetter:event:from:).

"sw 3/28/2001 extended Andreas's original lists by one item"
]

{ #category : #testing }
EventHandler >> handlesClickOrDrag: evt [
	clickRecipient ifNotNil:[^true].
	doubleClickRecipient ifNotNil:[^true].
	startDragRecipient ifNotNil:[^true].
	^false
]

{ #category : #testing }
EventHandler >> handlesGestureStart: evt [
	"Does the associated morph want to handle gestures?"
	^false
]

{ #category : #testing }
EventHandler >> handlesKeyboard: evt [
	keyStrokeRecipient ifNotNil: [^ true].
	^ false
]

{ #category : #testing }
EventHandler >> handlesMouseDown: evt [
	mouseDownRecipient ifNotNil: [^ true].
	mouseStillDownRecipient ifNotNil: [^ true].
	mouseUpRecipient ifNotNil: [^ true].
	(self handlesClickOrDrag: evt) ifTrue:[^true].
	^self handlesGestureStart: evt
]

{ #category : #testing }
EventHandler >> handlesMouseMove: evt [
	
	^ self wantsEveryMouseMove == true
		or: [((((mouseMoveRecipient notNil and: [mouseMoveSelector notNil])
			and: [evt hand hasSubmorphs not])
			and: [evt anyButtonPressed])
			and: [evt hand mouseFocus notNil])
			and: [evt hand mouseFocus eventHandler == self]]
]

{ #category : #testing }
EventHandler >> handlesMouseOver: evt [
	mouseEnterRecipient ifNotNil: [^ true].
	mouseLeaveRecipient ifNotNil: [^ true].
	^ false
]

{ #category : #testing }
EventHandler >> handlesMouseOverDragging: evt [
	mouseEnterDraggingRecipient ifNotNil: [^ true].
	mouseLeaveDraggingRecipient ifNotNil: [^ true].
	^ false
]

{ #category : #testing }
EventHandler >> handlesMouseStillDown: evt [
	^mouseStillDownRecipient notNil and:[mouseStillDownSelector notNil]
]

{ #category : #testing }
EventHandler >> handlesMouseWheel: evt [
	mouseWheelRecipient ifNotNil: [^ true].
	^ false
]

{ #category : #events }
EventHandler >> keyDown: event fromMorph: sourceMorph [
	^ self send: keyDownSelector to: keyDownRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> keyStroke: event fromMorph: sourceMorph [
	^ self send: keyStrokeSelector to: keyStrokeRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> keyUp: event fromMorph: sourceMorph [
	^ self send: keyUpSelector to: keyUpRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> keyboardFocusChange: aBoolean fromMorph: sourceMorph [

	^ self
		send: keyboardFocusChangeSelector
		to: keyboardFocusChangeRecipient
		withEvent: aBoolean
		fromMorph: sourceMorph
]

{ #category : #access }
EventHandler >> messageList [
	"Return a list of 'Class selector' for each message I can send. tk 
	9/13/97"
	| list |
	self flag: #mref.
	"is this still needed? I replaced the one use that I could spot with 
	#methodRefList "
	list := OrderedCollection new.
	mouseDownRecipient
		ifNotNil: [list add: (mouseDownRecipient class whichClassIncludesSelector: mouseDownSelector) name , ' ' , mouseDownSelector].
	mouseMoveRecipient
		ifNotNil: [list add: (mouseMoveRecipient class whichClassIncludesSelector: mouseMoveSelector) name , ' ' , mouseMoveSelector].
	mouseStillDownRecipient
		ifNotNil: [list add: (mouseStillDownRecipient class whichClassIncludesSelector: mouseStillDownSelector) name , ' ' , mouseStillDownSelector].
	mouseUpRecipient
		ifNotNil: [list add: (mouseUpRecipient class whichClassIncludesSelector: mouseUpSelector) name , ' ' , mouseUpSelector].
	mouseEnterRecipient
		ifNotNil: [list add: (mouseEnterRecipient class whichClassIncludesSelector: mouseEnterSelector) name , ' ' , mouseEnterSelector].
	mouseLeaveRecipient
		ifNotNil: [list add: (mouseLeaveRecipient class whichClassIncludesSelector: mouseLeaveSelector) name , ' ' , mouseLeaveSelector].
	mouseEnterDraggingRecipient
		ifNotNil: [list add: (mouseEnterDraggingRecipient class whichClassIncludesSelector: mouseEnterDraggingSelector) name , ' ' , mouseEnterDraggingSelector].
	mouseLeaveDraggingRecipient
		ifNotNil: [list add: (mouseLeaveDraggingRecipient class whichClassIncludesSelector: mouseLeaveDraggingSelector) name , ' ' , mouseLeaveDraggingSelector].
	doubleClickRecipient
		ifNotNil: [list add: (doubleClickRecipient class whichClassIncludesSelector: doubleClickSelector) name , ' ' , doubleClickSelector].
	keyStrokeRecipient
		ifNotNil: [list add: (keyStrokeRecipient class whichClassIncludesSelector: keyStrokeSelector) name , ' ' , keyStrokeSelector].
	^ list sort
]

{ #category : #access }
EventHandler >> methodRefList [
	"Return a MethodReference for each message I can send. tk 9/13/97, raa 
	5/29/01 "
	| list adder |
	list := OrderedCollection new.
	adder := [:recip :sel | recip
				ifNotNil: [list
						add: (MethodReference new
								class: (recip class whichClassIncludesSelector: sel)
								selector: sel)]].
	adder value: mouseDownRecipient value: mouseDownSelector.
	adder value: mouseMoveRecipient value: mouseMoveSelector.
	adder value: mouseStillDownRecipient value: mouseStillDownSelector.
	adder value: mouseUpRecipient value: mouseUpSelector.
	adder value: mouseEnterRecipient value: mouseEnterSelector.
	adder value: mouseLeaveRecipient value: mouseLeaveSelector.
	adder value: mouseEnterDraggingRecipient value: mouseEnterDraggingSelector.
	adder value: mouseLeaveDraggingRecipient value: mouseLeaveDraggingSelector.
	adder value: doubleClickRecipient value: doubleClickSelector.
	adder value: keyStrokeRecipient value: keyStrokeSelector.
	^ list sort
]

{ #category : #events }
EventHandler >> mouseDown: event fromMorph: sourceMorph [ 
	"Take double-clicks into account."
	((self handlesClickOrDrag: event) and:[event redButtonPressed]) ifTrue:[
		event hand waitForClicksOrDrag: sourceMorph event: event.
	].
	^self
		send: mouseDownSelector
		to: mouseDownRecipient
		withEvent: event
		fromMorph: sourceMorph.

]

{ #category : #access }
EventHandler >> mouseDownSelector [
	^ mouseDownSelector
]

{ #category : #events }
EventHandler >> mouseEnter: event fromMorph: sourceMorph [
	^ self send: mouseEnterSelector to: mouseEnterRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> mouseEnterDragging: event fromMorph: sourceMorph [
	^ self send: mouseEnterDraggingSelector to: mouseEnterDraggingRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> mouseLeave: event fromMorph: sourceMorph [
	^ self send: mouseLeaveSelector to: mouseLeaveRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> mouseLeaveDragging: event fromMorph: sourceMorph [
	^ self send: mouseLeaveDraggingSelector to: mouseLeaveDraggingRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> mouseMove: event fromMorph: sourceMorph [
	^ self send: mouseMoveSelector to: mouseMoveRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #events }
EventHandler >> mouseStillDown: event fromMorph: sourceMorph [
	^ self send: mouseStillDownSelector to: mouseStillDownRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #access }
EventHandler >> mouseStillDownRecipient [
	^mouseStillDownRecipient
]

{ #category : #access }
EventHandler >> mouseStillDownSelector [
	^mouseStillDownSelector
]

{ #category : #events }
EventHandler >> mouseUp: event fromMorph: sourceMorph [
	^ self send: mouseUpSelector to: mouseUpRecipient withEvent: event fromMorph: sourceMorph
]

{ #category : #access }
EventHandler >> mouseUpSelector [
	^ mouseUpSelector
]

{ #category : #events }
EventHandler >> mouseWheel: event fromMorph: sourceMorph [ 
	^ self
		send: mouseWheelSelector
		to: mouseWheelRecipient
		withEvent: event
		fromMorph: sourceMorph
]

{ #category : #initialization }
EventHandler >> on: eventName send: selector to: recipient [
	eventName == #mouseDown ifTrue:
		[mouseDownRecipient := recipient.  mouseDownSelector := selector. ^ self].
	eventName == #mouseMove ifTrue:
		[mouseMoveRecipient := recipient.  mouseMoveSelector := selector. ^ self].
	eventName == #mouseStillDown ifTrue:
		[mouseStillDownRecipient := recipient.  mouseStillDownSelector := selector. ^ self].
	eventName == #mouseUp ifTrue:
		[mouseUpRecipient := recipient.  mouseUpSelector := selector. ^ self].
	eventName == #mouseEnter ifTrue:
		[mouseEnterRecipient := recipient.  mouseEnterSelector := selector. ^ self].
	eventName == #mouseLeave ifTrue:
		[mouseLeaveRecipient := recipient.  mouseLeaveSelector := selector. ^ self].
	eventName == #mouseEnterDragging ifTrue:
		[mouseEnterDraggingRecipient := recipient.  mouseEnterDraggingSelector := selector. ^ self].
	eventName == #mouseLeaveDragging ifTrue:
		[mouseLeaveDraggingRecipient := recipient.  mouseLeaveDraggingSelector := selector. ^ self].
	eventName == #click ifTrue:
		[clickRecipient := recipient. clickSelector := selector. ^ self].
	eventName == #doubleClick ifTrue:
		[doubleClickRecipient := recipient. doubleClickSelector := selector. ^ self].
	eventName == #doubleClickTimeout ifTrue:
		[doubleClickTimeoutRecipient := recipient. doubleClickTimeoutSelector := selector. ^ self].
	eventName == #startDrag ifTrue:
		[startDragRecipient := recipient. startDragSelector := selector. ^ self].
	eventName == #mouseWheel ifTrue:
		[mouseWheelRecipient := recipient. mouseWheelSelector := selector. ^ self].
	eventName == #keyStroke ifTrue:
		[keyStrokeRecipient := recipient.  keyStrokeSelector := selector. ^ self].
	eventName == #keyUp ifTrue:
		[keyUpRecipient := recipient.  keyUpSelector := selector. ^ self].
	eventName == #keyDown ifTrue:
		[keyDownRecipient := recipient.  keyDownSelector := selector. ^ self].
	eventName == #keyboardFocusChange ifTrue:
		[keyboardFocusChangeRecipient := recipient. keyboardFocusChangeSelector := selector. ^ self].
	eventName == #gesture ifTrue:
		[ ^self onGestureSend: selector to: recipient ].
	self error: 'Event name, ' , eventName , ' is not recognizable.'

]

{ #category : #initialization }
EventHandler >> on: eventName send: selector to: recipient withValue: value [
	selector numArgs = 3 ifFalse:
		[self halt: 'Warning: value parameters are passed as first of 3 arguments'].
	self on: eventName send: selector to: recipient.
	valueParameter := value

]

{ #category : #initialization }
EventHandler >> onGestureSend: selector to: recipient [
]

{ #category : #printing }
EventHandler >> printOn: aStream [ 
	| recipients |
	super printOn: aStream.
	#('mouseDownSelector' 'mouseStillDownSelector' 'mouseUpSelector' 'mouseEnterSelector' 'mouseLeaveSelector' 'mouseEnterDraggingSelector' 'mouseLeaveDraggingSelector' 'mouseWheelSelector' 'doubleClickSelector' 'keyStrokeSelector' 'keyUpSelector' 'keyDownSelector' 'startDragSelector' 'clickSelector' 'keyboardFocusChangeSelector') 
		do: 
			[:aName | | aVal | 
			(aVal := self instVarNamed: aName) notNil 
				ifTrue: [aStream nextPutAll: '; ' , aName , '=' , aVal]].
	(recipients := self allRecipients) notEmpty 
		ifTrue: 
			[aStream nextPutAll: ' recipients: '.
			recipients printOn: aStream]
]

{ #category : #fixups }
EventHandler >> replaceSendsIn: array1 with: array2 [
	"Replace all the sends that occur in array1 with those in array2. Used for fixing old event handlers in files."
	| old index |
	1 to: self class instSize do:[:i|
		old := self instVarAt: i.
		index := array1 identityIndexOf: old.
		index > 0 ifTrue:[self instVarAt: i put: (array2 at: index)]].
]

{ #category : #events }
EventHandler >> send: selector to: recipient withEvent: event fromMorph: sourceMorph [
	| arity |
	recipient ifNil: [^ self].
	arity := selector numArgs.
	arity = 0 ifTrue:
		[^ recipient perform: selector].
	arity = 1 ifTrue:
		[^ recipient perform: selector with: event].
	arity = 2 ifTrue:
		[^ recipient perform: selector with: event with: sourceMorph].
	arity = 3 ifTrue:
		[^ recipient perform: selector with: valueParameter with: event with: sourceMorph].
	self error: 'Event handling selectors must be Symbols and take 0-3 arguments'
]

{ #category : #events }
EventHandler >> startDrag: event fromMorph: sourceMorph [ 
	^ self
		send: startDragSelector
		to: startDragRecipient
		withEvent: event
		fromMorph: sourceMorph
]

{ #category : #copying }
EventHandler >> veryDeepFixupWith: deepCopier [
	| old |
	"ALL inst vars were weakly copied.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
1 to: self class instSize do:
	[:ii | old := self instVarAt: ii.
	self instVarAt: ii put: (deepCopier references at: old ifAbsent: [old])].


]

{ #category : #copying }
EventHandler >> veryDeepInner: deepCopier [
	"ALL fields are weakly copied!  Can't duplicate an object by duplicating a button that activates it.  See DeepCopier."

	super veryDeepInner: deepCopier.
	"just keep old pointers to all fields"

]

{ #category : #access }
EventHandler >> wantsEveryMouseMove [

	^ wantsEveryMouseMove
]

{ #category : #access }
EventHandler >> wantsEveryMouseMove: aBoolean [

	wantsEveryMouseMove := aBoolean.
]
