"
The state of a Morphic world.  (This needs some serious commenting!!)


The MinCycleLapse variable holds the minimum amount of time that a morphic cycle is allowed to take.  If a cycle takes less than this, then interCyclePause: will wait until the full time has been used up.
"
Class {
	#name : #WorldState,
	#superclass : #Object,
	#instVars : [
		'hands',
		'activeHand',
		'viewBox',
		'canvas',
		'damageRecorder',
		'stepList',
		'lastStepTime',
		'lastStepMessage',
		'lastCycleTime',
		'commandHistory',
		'alarms',
		'lastAlarmTime',
		'remoteServer',
		'multiCanvas',
		'interCycleDelay'
	],
	#classVars : [
		'CanSurrenderToOS',
		'DeferredUIMessages',
		'DisableDeferredUpdates',
		'LastCycleTime',
		'MinCycleLapse'
	],
	#category : #'Morphic-Worlds'
}

{ #category : #'class initialization' }
WorldState class >> addDeferredUIMessage: valuableObject [

	self deferredUIMessages nextPut: valuableObject.


]

{ #category : #accessing }
WorldState class >> canSurrenderToOS: aBoolean [

	CanSurrenderToOS := aBoolean
]

{ #category : #'objects from disk' }
WorldState class >> classVersion [

	^2		"force cleanup of alarms and stepList"
]

{ #category : #'class initialization' }
WorldState class >> cleanUp [
	"Reset command histories"

	self allInstances do: [ :ea | ea clearCommandHistory ].
]

{ #category : #accessing }
WorldState class >> deferredExecutionTimeLimit [
	"Answer the maximum time in milliseconds that should be spent dispatching deferred UI messages in WorldState>>runStepMethodsIn:."

	^ 200
]

{ #category : #'class initialization' }
WorldState class >> deferredUIMessages [

	^DeferredUIMessages ifNil: [DeferredUIMessages := SharedQueue new].

]

{ #category : #'class initialization' }
WorldState class >> initialize [
	"WorldState initialize"

	MinCycleLapse := 20.		"allows 50 frames per second..."
	DisableDeferredUpdates := false.
	DeferredUIMessages := SharedQueue new.
]

{ #category : #accessing }
WorldState class >> lastCycleTime [

	^LastCycleTime
]

{ #category : #'class initialization' }
WorldState class >> lastDeferredUIMessage [
	"Answer the most recently scheduled deferredUIMessage."

	^self deferredUIMessages peekLast
]

{ #category : #'objects from disk' }
WorldState class >> withClassVersion: aVersion [
	aVersion <= self classVersion ifTrue: [^self].
	^super withClassVersion: aVersion
]

{ #category : #alarms }
WorldState >> addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime [
	"Add a new alarm with the given set of parameters"
	self lockAlarmsDuring: [:locked |
		locked add:	(MorphicAlarm 
						scheduledAt: scheduledTime
						receiver: aTarget
						selector: aSelector
						arguments: argArray).
	]
]

{ #category : #hands }
WorldState >> addHand: aHandMorph [
	"Add the given hand to the list of hands for this world."

	hands := (hands copyWithout: aHandMorph) copyWith: aHandMorph.

]

{ #category : #'Nebraska support' }
WorldState >> addRemoteCanvas: c [
	self canvas: nil. "force recomputation"
]

{ #category : #alarms }
WorldState >> adjustAlarmTimes: nowTime [
	"Adjust the alarm times after some clock weirdness (such as roll-over, image-startup etc)"
	
	| deltaTime |
	(deltaTime := nowTime - lastAlarmTime) = 0 ifTrue: [ ^self ].
	self lockAlarmsDuring: [ :locked | locked incrementScheduledTimesBy: deltaTime ]
]

{ #category : #stepping }
WorldState >> adjustWakeupTimes: now [
	"Fix the wakeup times in my step list. This is necessary when this world has been restarted after a pause, say because some other view had control, after a snapshot, or because the millisecond clock has wrapped around. (The latter is a rare occurence with a 32-bit clock!)"
	| deltaTime |
	deltaTime := now - lastStepTime.
	stepList do:[:entry| entry scheduledTime: entry scheduledTime + deltaTime].
	lastStepTime := now.

]

{ #category : #stepping }
WorldState >> adjustWakeupTimesIfNecessary [
	"Fix the wakeup times in my step list if necessary. This is needed after a snapshot, after a long pause (say because some other view had control or because the user was selecting from an MVC-style menu) or when the millisecond clock wraps around (a very rare occurence with a 32-bit clock!)."

	| now |
	now := Time millisecondClockValue.
	((now < lastStepTime) or: [(now - lastStepTime) > 5000])
		 ifTrue: [self adjustWakeupTimes: now].  "clock slipped"

]

{ #category : #alarms }
WorldState >> alarms [

	^alarms ifNil: [alarms := MorphicAlarmQueue new]
]

{ #category : #canvas }
WorldState >> assuredCanvas [
	remoteServer ifNotNil:[^self assuredRemoteCanvas].
	(canvas isNil or: [(canvas extent ~= viewBox extent) or: [canvas form depth ~= Display depth]])
		ifTrue:
			["allocate a new offscreen canvas the size of the window"
			self canvas: (Display defaultCanvasClass extent: viewBox extent)].
	^ self canvas
]

{ #category : #'Nebraska support' }
WorldState >> assuredRemoteCanvas [
	| newCanvas |
	(self canvas notNil) ifTrue: [ ^self canvas ].
	newCanvas := MultiCanvas new.
	newCanvas depth: 32.
	newCanvas extent: viewBox extent.
	self remoteCanvasesDo: [ :c | newCanvas addCanvas: c ].
	newCanvas addCanvas: Display getCanvas.

	"newCanvas := CachingCanvas on: newCanvas."
	self canvas: newCanvas.
	^newCanvas
]

{ #category : #canvas }
WorldState >> canvas [

	^ canvas
]

{ #category : #canvas }
WorldState >> canvas: x [ 
	canvas := x.
	damageRecorder isNil 
		ifTrue: [damageRecorder := DamageRecorder new]
		ifFalse: [damageRecorder doFullRepaint]
]

{ #category : #'update cycle' }
WorldState >> checkIfUpdateNeeded [

	damageRecorder updateIsNeeded ifTrue: [^true].
	hands do: [:h | (h hasChanged and: [h needsToBeDrawn]) ifTrue: [^true]].
	^false  "display is already up-to-date"

]

{ #category : #stepping }
WorldState >> cleanseStepListForWorld: aWorld [
	"Remove morphs from the step list that are not in this World.  Often were in a flap that has moved on to another world."

	| deletions |
	deletions := nil.
	stepList do: [:entry |
		entry receiver world == aWorld ifFalse: [
			(deletions ifNil: [ deletions := OrderedCollection new ])
				addLast: entry ] ].

	deletions ifNotNil:[
		deletions do: [:entry|
			self stopStepping: entry receiver]].

	self lockAlarmsDuring: [:locked |
		locked alarmsDoSafely: [ :entry |
			| morphToStep |
			morphToStep := entry receiver.
			(morphToStep isMorph and: [morphToStep world == aWorld]) ifFalse: [
				locked removeAlarmWithReceiver: entry receiver selector: entry selector ] ] ]
]

{ #category : #'undo support' }
WorldState >> clearCommandHistory [

	"useful prior to project saves"
	commandHistory := nil
]

{ #category : #undo }
WorldState >> commandHistory [
	^commandHistory ifNil:[commandHistory := CommandHistory new]
]

{ #category : #'object fileIn' }
WorldState >> convertAlarms [
	"We now store the alarms in a MorphicAlarmQueue, rather than a Heap.
	 Make sure we have a fresh one.  If it is already a MorphicAlarmQueue
	 updating it will ensure any block to method references are fresh."
	alarms ifNotNil:
		[:oldAlarms|
		 alarms class == MorphicAlarmQueue
			ifTrue:
				[alarms := MorphicAlarmQueue new.
				 oldAlarms alarmsDoSafely: [:alarm | alarms add: alarm]]
			ifFalse:
				[alarms := MorphicAlarmQueue new.
				 oldAlarms do: [:alarm | alarms add: alarm]]]
]

{ #category : #'object fileIn' }
WorldState >> convertStepList [
	"Convert the old-style step list (an Array of Arrays) into the new-style StepMessage heap"

	| newList |
	(stepList isKindOf: Heap) 
		ifTrue: 
			[^stepList sortBlock: self stepListSortBlock	"ensure that we have a cleaner block"].
	newList := Heap sortBlock: self stepListSortBlock.
	stepList do: 
			[:entry | | wakeupTime morphToStep | 
			wakeupTime := entry second.
			morphToStep := entry first.
			newList add: (StepMessage 
						scheduledAt: wakeupTime
						stepTime: nil
						receiver: morphToStep
						selector: #stepAt:
						arguments: nil)].
	stepList := newList
]

{ #category : #'objects from disk' }
WorldState >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	"Convert the old to new step lists"
	self convertStepList.
	self convertAlarms.
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #'update cycle' }
WorldState >> displayWorld: aWorld submorphs: submorphs [
	"Update this world's display."

	| deferredUpdateMode handsToDraw allDamage handDamageRects worldDamageRects |

	aWorld fullBounds. "send #ownerChanged to submorphs."
	submorphs do: [:m | m fullBounds].  "force re-layout if needed"
	self checkIfUpdateNeeded ifFalse: [^ self].  "display is already up-to-date"

	deferredUpdateMode := self doDeferredUpdatingFor: aWorld.
	deferredUpdateMode ifFalse: [self assuredCanvas].

	worldDamageRects := self drawWorld: aWorld submorphs: submorphs invalidAreasOn: self assuredCanvas.  "repair world's damage on canvas"
	"self handsDo:[:h| h noticeDamageRects: worldDamageRects]."
	handsToDraw := self selectHandsToDrawForDamage: worldDamageRects.
	handDamageRects := handsToDraw collect: [:h | h savePatchFrom: canvas].
	allDamage := worldDamageRects, handDamageRects.

	handsToDraw reverseDo: [:h | canvas fullDrawMorph: h].  "draw hands onto world canvas"

	"*make this true to flash damaged areas for testing*"
	Preferences debugShowDamage ifTrue: [aWorld flashRects: allDamage color: Color black].

	canvas finish: allDamage.

	"quickly copy altered rects of canvas to Display:"
	deferredUpdateMode
		ifTrue: [self forceDamageToScreen: allDamage]
		ifFalse: [canvas showAt: aWorld viewBox origin invalidRects: allDamage].
	handsToDraw do: [:h | h restoreSavedPatchOn: canvas].  "restore world canvas under hands"
	Display deferUpdates: false; forceDisplayUpdate.

]

{ #category : #'update cycle' }
WorldState >> displayWorldSafely: aWorld [
	"Update this world's display and keep track of errors during draw methods."

	| finished classesWithErrors |
	finished := false.
	
	[finished] whileFalse: [
		[aWorld displayWorld. finished := true] on: Error, Halt, Warning do: [:ex |
			"Handle a drawing error"
			| err rcvr errCtx errMorph |
			err := ex description.
			rcvr := ex receiver.

			errCtx := thisContext.
			[
				errCtx := errCtx sender.
				"Search the sender chain to find the morph causing the problem"
				[errCtx notNil and:[(errCtx receiver isMorph) not]] 
					whileTrue:[errCtx := errCtx sender].
				"If we're at the root of the context chain then we have a fatal drawing problem"
				errCtx ifNil:[^Project current fatalDrawingError: err].
				errMorph := errCtx receiver.
				"If the morph causing the problem has already the #drawError flag set,
				then search for the next morph above in the caller chain."
				errMorph hasProperty: #errorOnDraw
			] whileTrue.
			errMorph setProperty: #errorOnDraw toValue: true.

			"Catch all errors, one for each receiver class."
			classesWithErrors ifNil: [classesWithErrors := IdentitySet new].
			(classesWithErrors includes: rcvr class) ifFalse: [
				classesWithErrors add: rcvr class.
				ToolSet debugException: ex].

			"Repaint all to catch all errors now and not if the debugger will appear."
			aWorld fullRepaintNeeded.
		]].
]

{ #category : #'update cycle' }
WorldState >> doDeferredUpdatingFor: aWorld [
        "If this platform supports deferred updates, then make my canvas be the Display (or a rectangular portion of it), set the Display to deferred update mode, and answer true. Otherwise, do nothing and answer false. One can set the class variable DisableDeferredUpdates to true to completely disable the deferred updating feature."
	| properDisplay |
	PasteUpMorph disableDeferredUpdates ifTrue: [^ false].
	(Display deferUpdates: true) ifNil: [^ false].  "deferred updates not supported"
	remoteServer ifNotNil:[
		self assuredCanvas.
		^true].
	properDisplay := canvas notNil and: [canvas form == Display].
	aWorld == Project current world ifTrue: [  "this world fills the entire Display"
		properDisplay ifFalse: [
			aWorld viewBox: Display boundingBox.    "do first since it may clear canvas"
			self canvas: (Display getCanvas copyClipRect: Display boundingBox).
		]
	].
	^ true

]

{ #category : #canvas }
WorldState >> doFullRepaint [

	damageRecorder doFullRepaint

]

{ #category : #'update cycle' }
WorldState >> doOneCycleFor: aWorld [
	"Do one cycle of the interaction loop. This method is called repeatedly when the world is running.

This is a moderately private method; a better alternative is usually either to wait for events or to check the state of things from #step methods."

	self interCyclePause: (Preferences higherPerformance ifTrue: [1] ifFalse: [MinCycleLapse]).
	self doOneCycleNowFor: aWorld.
]

{ #category : #'update cycle' }
WorldState >> doOneCycleNowFor: aWorld [
	"Immediately do one cycle of the interaction loop.
	This should not be called directly, but only via doOneCycleFor:"

	| capturingGesture |
	DisplayScreen checkForNewScreenSize.
	capturingGesture := false.
	"self flag: #bob.	"	"need to consider remote hands in lower worlds"
	
	"process user input events"
	LastCycleTime := Time millisecondClockValue.
	self handsDo: [:hand |
		hand becomeActiveDuring: [
			hand processEvents.
			capturingGesture := capturingGesture or: [hand isCapturingGesturePoints]]].
	
	"The gesture recognizer needs enough points to be accurate.
	Therefore morph stepping is disabled while capturing points for the recognizer"
	capturingGesture ifFalse: [
		aWorld runStepMethods.		"there are currently some variations here"
		self displayWorldSafely: aWorld].
]

{ #category : #'update cycle' }
WorldState >> doOneSubCycleFor: aWorld [

	self flag: #deprecate. "ct: Historically, global state was preserved here. Since the introduction of ActiveHandVariable, this is no longer necessary, so this is equivalent to #doOneCycleFor:. However, let's keep this possibly valuable hook for now."

	^ self doOneCycleFor: aWorld
]

{ #category : #'update cycle' }
WorldState >> drawWorld: aWorld submorphs: submorphs invalidAreasOn: aCanvas [ 
	"Redraw the damaged areas of the given canvas and clear the damage list. Return a collection of the areas that
were redrawn."

	| rectList n morphs rects validList |
	rectList := damageRecorder invalidRectsFullBounds: aWorld viewBox.
	"sort by areas to draw largest portions first"
	rectList := rectList asArray sort: [:r1 :r2 | r1 area > r2 area].
	damageRecorder reset.
	n := submorphs size.
	morphs := OrderedCollection new: n * 2.
	rects := OrderedCollection new: n * 2.
	validList := OrderedCollection new: n * 2.

	"This is added in case we are drawing to a form that is to be used as a texture, and we want the background to be translucent."
	aWorld color isTranslucent ifTrue:
		[rectList do: [:r | aCanvas form fill: r fillColor: aWorld color]].

	rectList do: 
			[:dirtyRect | 
			dirtyRect allAreasOutsideList: validList
				do: 
					[:r | | mm rectToFill remnants c rect i | 
					"Experimental top-down drawing --
			Traverses top to bottom, stopping if the entire area is filled.
			If only a single rectangle remains, then continue with the reduced rectangle."

					rectToFill := r.
					i := 1.
					[rectToFill isNil or: [i > n]] whileFalse: 
							[mm := submorphs at: i.
							((mm fullBounds intersects: r) and: [mm visible]) 
								ifTrue: 
									[morphs addLast: mm.
									rects addLast: rectToFill.
									remnants := mm areasRemainingToFill: rectToFill.
									remnants size = 1 ifTrue: [rectToFill := remnants first].
									remnants isEmpty ifTrue: [rectToFill := nil]].
							i := i + 1].

					"Now paint from bottom to top, but using the reduced rectangles."
					rectToFill 
						ifNotNil: [(c := aCanvas copyClipRect: rectToFill) drawMorph: aWorld].
					[morphs isEmpty] whileFalse: 
							[(rect := rects removeLast) == rectToFill 
								ifFalse: [c := aCanvas copyClipRect: (rectToFill := rect)].
							c fullDrawMorph: morphs removeLast].
					morphs reset.
					rects reset.
					validList add: r]].
	^validList
]

{ #category : #'update cycle' }
WorldState >> forceDamageToScreen: allDamage [

	"here for the convenience of NebraskaWorldState"
	Display forceDamageToScreen: allDamage.
	self remoteCanvasesDo: [ :each | 
		allDamage do: [:r | each forceToScreen: r].
		each displayIsFullyUpdated.
	].
]

{ #category : #hands }
WorldState >> hands [

	^ hands
]

{ #category : #hands }
WorldState >> handsDo: aBlock [

	^ hands do: aBlock
]

{ #category : #hands }
WorldState >> handsReverseDo: aBlock [

	^ hands reverseDo: aBlock
]

{ #category : #initialization }
WorldState >> initialize [

	hands := Array new.
	damageRecorder:= DamageRecorder new.
	stepList := Heap sortBlock: self stepListSortBlock.
	lastStepTime := 0.
	lastAlarmTime := 0.
]

{ #category : #'update cycle' }
WorldState >> interCyclePause: milliSecs [
	"delay enough that the previous cycle plus the amount of delay will equal milliSecs.  If the cycle is already expensive, then no delay occurs.  However, if the system is idly waiting for interaction from the user, the method will delay for a proportionally long time and cause the overall CPU usage of Squeak to be low.
	If the preference #serverMode is enabled, always do a complete delay of 50ms, independant of my argument. This prevents the freezing problem described in Mantis #6581"

	| millisecondsToWait |
	millisecondsToWait := Preferences serverMode
		ifTrue: [ 50 ]
		ifFalse: [
			(lastCycleTime isNil or: [ CanSurrenderToOS == false ])
				ifTrue: [ 0 ]
				ifFalse: [ milliSecs - (Time millisecondsSince: lastCycleTime) ] ].
	(Preferences serverMode or: [millisecondsToWait > 0 and: [millisecondsToWait <= milliSecs]])
		ifTrue: [
			(interCycleDelay isNil or: [ interCycleDelay beingWaitedOn ])
				ifTrue: [ interCycleDelay := Delay forMilliseconds: millisecondsToWait ]
				ifFalse: [ interCycleDelay delayDuration: millisecondsToWait ].
			interCycleDelay wait ].
	lastCycleTime := Time millisecondClockValue.
	CanSurrenderToOS := true.
]

{ #category : #stepping }
WorldState >> isStepping: aMorph [
	"Return true if the given morph is in the step list."
	lastStepMessage ifNotNil:[(lastStepMessage receiver == aMorph) ifTrue:[^true]].
	stepList do:[:entry| entry receiver == aMorph ifTrue:[^true]].
	^ false
]

{ #category : #stepping }
WorldState >> isStepping: aMorph selector: aSelector [
	"Return true if the given morph is in the step list."
	lastStepMessage ifNotNil:[
		(lastStepMessage receiver == aMorph and:[lastStepMessage selector == aSelector])
			ifTrue:[^true]].
	stepList do:[:entry| (entry receiver == aMorph and:[entry selector == aSelector]) ifTrue:[^true]].
	^ false
]

{ #category : #stepping }
WorldState >> listOfSteppingMorphs [
	^stepList collect:[:entry| entry receiver].

]

{ #category : #alarms }
WorldState >> lockAlarmsDuring: actionBlock [
	"All accesses to the alarms queue is synchronized by a mutex.  Answer the result of evaluating the 1-argument 'actionBlock'."
	alarms ifNil: [alarms := MorphicAlarmQueue new].
	^alarms mutex critical: [
		actionBlock value: alarms
	]
]

{ #category : #hands }
WorldState >> primaryHand [

	self flag: #deprecated. "ct: Send #primaryHand to #currentWorld instead."
	^ self currentWorld primaryHand
]

{ #category : #canvas }
WorldState >> recordDamagedRect: damageRect [

	damageRecorder ifNotNil: [damageRecorder recordInvalidRect: damageRect truncated]

]

{ #category : #'Nebraska support' }
WorldState >> releaseRemoteServer [
	"My server has been transferred to some other world. Release pending references"
	remoteServer := nil.
	self canvas: nil.
]

{ #category : #'Nebraska support' }
WorldState >> remoteCanvasesDo: aBlock [
	remoteServer ifNil:[^self].
	^remoteServer clients do:[:client| aBlock value: client canvas]
]

{ #category : #'Nebraska support' }
WorldState >> remoteServer [
	^remoteServer
]

{ #category : #'Nebraska support' }
WorldState >> remoteServer: aNebraskaServer [
	remoteServer ifNotNil:[remoteServer destroy].
	remoteServer := aNebraskaServer.
	self canvas: nil.
]

{ #category : #alarms }
WorldState >> removeAlarm: aSelector for: aTarget [ 
	"Remove the alarm with the given selector"
	self lockAlarmsDuring: [:locked |
		locked removeAlarmWithReceiver: aTarget selector: aSelector ]
]

{ #category : #hands }
WorldState >> removeHand: aHandMorph [
	"Remove the given hand from the list of hands for this world."

	(hands includes: aHandMorph) ifFalse: [^ self].
	self currentHand == aHandMorph ifTrue: [
		self flag: #invalidate. "ct: Should we try to clear ActiveHandVariable here or doesn't this matter? In past, ActiveHand was set to nil at this point."].
	hands := hands copyWithout: aHandMorph.
]

{ #category : #'Nebraska support' }
WorldState >> removeRemoteCanvas: c [
	self canvas: nil.	"force withdrawal of remote from MultiCanvas"

]

{ #category : #canvas }
WorldState >> resetDamageRecorder [

	damageRecorder reset

]

{ #category : #stepping }
WorldState >> runLocalStepMethodsIn: aWorld [ 
	"Run morph 'step' methods (LOCAL TO THIS WORLD) whose time has come. Purge any morphs that are no longer in this world.
	ar 3/13/1999: Remove buggy morphs from the step list so that they don't raise repeated errors."

	| now morphToStep stepTime |
	now := Time millisecondClockValue.
	
	aWorld becomeActiveDuring: [ 
		self triggerAlarmsBefore: now.
		
		stepList ifEmpty: [^ self].
		
		(now < lastStepTime or: [now - lastStepTime > 5000]) ifTrue: [
			self adjustWakeupTimes: now].	"clock slipped"
		
		[stepList notEmpty and: [stepList first scheduledTime < now]] whileTrue: [
			lastStepMessage := stepList removeFirst.
			morphToStep := lastStepMessage receiver.
			(morphToStep shouldGetStepsFrom: aWorld) ifTrue: [
				lastStepMessage value: now.
				lastStepMessage ifNotNil: [
					stepTime := lastStepMessage stepTime ifNil: [morphToStep stepTime].
					lastStepMessage scheduledTime: now + (stepTime max: 1).
					stepList add: lastStepMessage]].
			lastStepMessage := nil].
		
		lastStepTime := now].
]

{ #category : #stepping }
WorldState >> runStepMethodsIn: aWorld [
	"Perform periodic activity inbetween event cycles"
	| queue msg limit stamp |
	"Limit processing of deferredUIMessages to a max. amount of time"
	limit := self class deferredExecutionTimeLimit.
	stamp := Time millisecondClockValue.
	queue := self class deferredUIMessages.
	[(Time millisecondsSince: stamp) >= limit 
		or:[(msg := queue nextOrNil) == nil]] 
			whileFalse: [msg value].
	self runLocalStepMethodsIn: aWorld.

]

{ #category : #hands }
WorldState >> selectHandsToDrawForDamage: damageList [
	"Select the set of hands that must be redrawn because either (a) the hand itself has changed or (b) the hand intersects some damage rectangle."

	| result |
	result := OrderedCollection new.
	hands do: [:h |
		h needsToBeDrawn ifTrue: [
			h hasChanged
				ifTrue: [result add: h]
				ifFalse: [
					| hBnds |
					hBnds := h fullBounds.
					(damageList anySatisfy: [:r | r intersects: hBnds])
						ifTrue: [result add: h]]]].
	^ result

]

{ #category : #stepping }
WorldState >> startStepping: aMorph at: scheduledTime selector: aSelector arguments: args stepTime: stepTime [
	"Add the given morph to the step list. Do nothing if it is already being stepped."

	self stopStepping: aMorph selector: aSelector.
	self adjustWakeupTimesIfNecessary.
	stepList add:(
		StepMessage 
			scheduledAt: scheduledTime
			stepTime: stepTime
			receiver: aMorph
			selector: aSelector
			arguments: args)
]

{ #category : #initialization }
WorldState >> stepListSize [
	^ stepList size
]

{ #category : #initialization }
WorldState >> stepListSortBlock [
	^[ :stepMsg1 :stepMsg2 | 
		stepMsg1 scheduledTime <= stepMsg2 scheduledTime.
	]
]

{ #category : #stepping }
WorldState >> stopStepping: aMorph [
	"Remove the given morph from the step list."
	lastStepMessage ifNotNil:[
		(lastStepMessage receiver == aMorph) ifTrue:[lastStepMessage := nil]].
	stepList removeAll: (stepList select:[:stepMsg| stepMsg receiver == aMorph]).

]

{ #category : #stepping }
WorldState >> stopStepping: aMorph selector: aSelector [
	"Remove the given morph from the step list."
	lastStepMessage ifNotNil:[
		(lastStepMessage receiver == aMorph and:[lastStepMessage selector == aSelector])
			ifTrue:[lastStepMessage := nil]].
	stepList removeAll: (stepList select:[:stepMsg| stepMsg receiver == aMorph and:[stepMsg selector == aSelector]]).
]

{ #category : #alarms }
WorldState >> triggerAlarmsBefore: nowTime [
	"Trigger all pending alarms that are to be executed before nowTime."
	| triggered |
	lastAlarmTime ifNil:[lastAlarmTime := nowTime].
	(nowTime < lastAlarmTime or:[nowTime - lastAlarmTime > 10000])
		ifTrue:[self adjustAlarmTimes: nowTime].
	triggered := self lockAlarmsDuring: [:pending |
		pending removeAllAlarmsBefore: nowTime ].
	triggered do: [:alarm | alarm value: nowTime].
	lastAlarmTime := nowTime.
]

{ #category : #canvas }
WorldState >> viewBox [

	^ viewBox
]

{ #category : #canvas }
WorldState >> viewBox: x [

	viewBox := x
]
