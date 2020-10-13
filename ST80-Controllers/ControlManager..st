"
I represent the top level control over scheduling which controller of a view on the screen the user is actively using. ScheduledControllers is the global reference to an instance of me, the one attached to the Project currently being used.
"
Class {
	#name : #ControlManager,
	#superclass : #Object,
	#instVars : [
		'scheduledControllers',
		'activeController',
		'activeControllerProcess',
		'screenController',
		'newTopClicked'
	],
	#classVars : [
		'DeferredActionQueue'
	],
	#category : #'ST80-Controllers'
}

{ #category : #'class initialization' }
ControlManager class >> addDeferredUIMessage: valuableObject [ 
	"Arrange for valuableObject to be evaluated the next time the controlActivity in any controller becomes active."

	self deferredActionQueue nextPut: valuableObject.
]

{ #category : #'class initialization' }
ControlManager class >> deferredActionQueue [

	^DeferredActionQueue ifNil: [DeferredActionQueue := SharedQueue new]
]

{ #category : #'class initialization' }
ControlManager class >> lastDeferredUIMessage [
	"Answer the most recently scheduled deferredUIMessage."

	^self deferredActionQueue peekLast
]

{ #category : #exchange }
ControlManager class >> newScheduler: controlManager [
	"When switching projects, the control scheduler has to be exchanged. The 
	active one is the one associated with the current project."

	Smalltalk at: #ScheduledControllers put: controlManager.
	ScheduledControllers restore.
	controlManager searchForActiveController
]

{ #category : #scheduling }
ControlManager >> activateController: aController [
	"Make aController, which must already be a scheduled controller, the active window.  5/8/96 sw"

	self activeController: aController.
	(activeController view labelDisplayBox
		intersect: Display boundingBox) area < 200
			ifTrue: [activeController move].
	Processor terminateActive
]

{ #category : #scheduling }
ControlManager >> activateTranscript [
	"There is known to be a Transcript open in the current project; activate it.  2/5/96 sw"

	| itsController |
	itsController := scheduledControllers detect:
			[:controller | controller model == Transcript]
		ifNone:
			[^ self].

	self activeController: itsController.
	(activeController view labelDisplayBox
			intersect: Display boundingBox) area < 200
				ifTrue: [activeController move].
	Processor terminateActive
]

{ #category : #accessing }
ControlManager >> activeController [
	"Answer the currently active controller."

	^activeController
]

{ #category : #accessing }
ControlManager >> activeController: aController [ 
	"Set aController to be the currently active controller. Give the user 
	control in it."
	<primitive: 19> "Simulation guard"
	activeController := aController.
	(activeController == screenController)
		ifFalse: [self promote: activeController].
	activeControllerProcess := 
			[activeController startUp.
			self searchForActiveController] newProcess.
	activeControllerProcess priority: Processor userSchedulingPriority.
	activeControllerProcess resume
]

{ #category : #accessing }
ControlManager >> activeController: aController andProcess: aProcess [
	"Set aController to be the currently active controller and aProcess to be the the process that handles controller scheduling activities in the system. ndProcess: in that it 
	does not send controlTerminate to the currently active controller."

	self inActiveControllerProcess
		ifTrue: [
			aController ifNotNil: [:c |
				(scheduledControllers includes: c)
					ifTrue: [self promote: c]
					ifFalse: [self error: 'Old controller not scheduled']].
			activeController ifNotNil: [:c | c controlTerminate].
			activeController := aController.
			activeController ifNotNil: [:c | c controlInitialize].
			
			aProcess resume.
			
			activeController
				ifNil: [self searchForActiveController]
				ifNotNil: [
					"Assume that given controller matches the process."
					activeControllerProcess := aProcess.
					Processor terminateActive]]
		ifFalse: 
			[self error: 'New active controller process must be set from old one'] 
]

{ #category : #accessing }
ControlManager >> activeControllerNoTerminate: aController andProcess: aProcess [
	"Set aController to be the currently active controller and aProcess to be 
	the the process that handles controller scheduling activities in the 
	system. This message differs from activeController:andProcess: in that it 
	does not send controlTerminate to the currently active controller."

	self inActiveControllerProcess
		ifTrue: 
			[aController~~nil
				ifTrue: [(scheduledControllers includes: aController)
							ifTrue: [self promote: aController]
							ifFalse: [self error: 'Old controller not scheduled']].
			activeController := aController.
			activeController == nil
				ifFalse: [activeController controlInitialize].
			activeControllerProcess := aProcess.
			activeControllerProcess resume]
		ifFalse: 
			[self error: 'New active controller process must be set from old one'] 
]

{ #category : #accessing }
ControlManager >> activeControllerProcess [
	"Answer the process that is currently handling controller scheduling 
	activities in the system."

	^activeControllerProcess
]

{ #category : #displaying }
ControlManager >> backgroundForm: aForm [
	screenController view model: aForm.
	ScheduledControllers restore
"
	QDPen new mandala: 30 diameter: 640.
	ScheduledControllers backgroundForm:
		(Form fromDisplay: Display boundingBox).

	ScheduledControllers backgroundForm:
		(InfiniteForm with: Form gray).
"
]

{ #category : #accessing }
ControlManager >> controllerSatisfying: aBlock [
	"Return the first scheduled controller which satisfies the 1-argument boolean-valued block, or nil if none.  7/25/96 sw"

	scheduledControllers do:
		[:aController | (aBlock value: aController) == true ifTrue: [^ aController]].
	^ nil
]

{ #category : #accessing }
ControlManager >> controllerWhoseModelSatisfies: aBlock [
	"Return the first scheduled controller whose model satisfies the 1-argument boolean-valued block, or nil if none.  5/6/96 sw"

	scheduledControllers do:
		[:aController | (aBlock value: aController model) == true ifTrue: [^ aController]].
	^ nil
]

{ #category : #accessing }
ControlManager >> controllersSatisfying: aBlock [
	"Return a list of scheduled controllers satisfying aBlock"

	^ (scheduledControllers ifNil: [^ #()]) select:
		[:aController | (aBlock value: aController) == true]
]

{ #category : #displaying }
ControlManager >> displayWorld [ 

	screenController view window: Display boundingBox; displayDeEmphasized.
	self scheduledWindowControllers reverseDo:
		[:aController | aController view displayDeEmphasized].

]

{ #category : #private }
ControlManager >> emergencyCollapse [

	self screenController emergencyCollapse.
]

{ #category : #scheduling }
ControlManager >> findWindow [
	"Present a menu of window titles, and activate the one that gets chosen."

	^ self findWindowSatisfying: [:c | true]
]

{ #category : #scheduling }
ControlManager >> findWindowSatisfying: aBlock [
	"Present a menu of window titles, and activate the one that gets chosen"

	| sortAlphabetically controllers labels index |
	sortAlphabetically := Sensor shiftPressed.
	controllers := OrderedCollection new.
	scheduledControllers do: [:controller |
		controller == screenController ifFalse:
			[(aBlock value: controller) ifTrue: [controllers addLast: controller]]].
	controllers size = 0 ifTrue: [^ self].
	sortAlphabetically ifTrue: [controllers sort: [:a :b | a view label < b view label]].
	labels := String streamContents:
		[:strm | 
			controllers do: [:controller | strm nextPutAll: (controller view label contractTo: 40); cr].
		strm skip: -1  "drop last cr"].
	index := (UIManager default chooseFrom: labels lines).
	index > 0 ifTrue:
		[self activateController: (controllers at: index)].

]

{ #category : #scheduling }
ControlManager >> inActiveControllerProcess [
	"Answer whether the active scheduling process is the actual active 
	process in the system."

	^activeControllerProcess == Processor activeProcess
]

{ #category : #accessing }
ControlManager >> includes: aController [
	^ scheduledControllers includes: aController
]

{ #category : #'initialize-release' }
ControlManager >> initialize [
	"Initialize the receiver to refer to only the background controller."
	| screenView |
	screenController := ScreenController new.
	screenView := FormView new.
	screenView model: (InfiniteForm with: Color gray) controller: screenController.
	screenView window: Display boundingBox.
	scheduledControllers := OrderedCollection with: screenController
]

{ #category : #private }
ControlManager >> nextActiveController [
	"Answer the controller that would like control.  
	If there was a click outside the active window, it's the top window
	that now has the mouse, otherwise it's just the top window."

	(newTopClicked notNil and: [newTopClicked])
		ifTrue: [newTopClicked := false.
				^ scheduledControllers 
					detect: [:aController | aController isControlWanted]
					ifNone: [scheduledControllers first]]
		ifFalse: [^ scheduledControllers first]
]

{ #category : #accessing }
ControlManager >> noteNewTop [
	newTopClicked := true
]

{ #category : #scheduling }
ControlManager >> processDeferredActions [

	[self class deferredActionQueue isEmpty]
		whileFalse: [self class deferredActionQueue next value].
]

{ #category : #scheduling }
ControlManager >> promote: aController [
	"Make aController be the first scheduled controller in the ordered 
	collection."
	
	scheduledControllers remove: aController.
	scheduledControllers addFirst: aController
]

{ #category : #'initialize-release' }
ControlManager >> release [ 
	"Refer to the comment in Object|release."

	scheduledControllers == nil
		ifFalse: 
			[scheduledControllers 
				do: [:controller | (controller isKindOf: Controller)
								ifTrue: [controller view release]
								ifFalse: [controller release]].
			scheduledControllers := nil]
]

{ #category : #scheduling }
ControlManager >> resetActiveController [
	"When saving a morphic project whose parent is mvc, we need to set this up first"

	activeController := nil.
	activeControllerProcess := Processor activeProcess.

]

{ #category : #displaying }
ControlManager >> restore [ 
	"Clear the screen to gray and then redisplay all the scheduled views.  Try to be a bit intelligent about the view that wants control and not display it twice if possible."

	self unCacheWindows.  "assure refresh"
	self unschedule: screenController; scheduleOnBottom: screenController.
	self displayWorld.
]

{ #category : #displaying }
ControlManager >> restore: aRectangle [
	"Restore all windows visible in aRectangle"
	^ self restore: aRectangle without: nil
]

{ #category : #displaying }
ControlManager >> restore: aRectangle below: index without: aView [
	"Restore all windows visible in aRectangle, but without aView"
	| view | 
	view := (scheduledControllers at: index) view.
	view == aView ifTrue: 
		[index >= scheduledControllers size ifTrue: [^ self].
		^ self restore: aRectangle below: index+1 without: aView].
	view displayOn: ((BitBlt toForm: Display) clipRect: aRectangle).
	index >= scheduledControllers size ifTrue: [^ self].
	(aRectangle areasOutside: view windowBox) do:
		[:rect | self restore: rect below: index + 1 without: aView]
]

{ #category : #displaying }
ControlManager >> restore: aRectangle without: aView [
	"Restore all windows visible in aRectangle"
	Display deferUpdates: true.
	self restore: aRectangle below: 1 without: aView.
	Display deferUpdates: false; forceToScreen: aRectangle
]

{ #category : #scheduling }
ControlManager >> scheduleActive: aController [ 
	"Make aController be scheduled as the active controller. Presumably the 
	active scheduling process asked to schedule this controller and that a 
	new process associated this controller takes control. So this is the last act 
	of the active scheduling process."
	<primitive: 19> "Simulation guard"
	self scheduleActiveNoTerminate: aController.
	Processor terminateActive
]

{ #category : #scheduling }
ControlManager >> scheduleActiveNoTerminate: aController [ 
	"Make aController be the active controller. Presumably the process that 
	requested the new active controller wants to keep control to do more 
	activites before the new controller can take control. Therefore, do not 
	terminate the currently active process."

	self schedulePassive: aController.
	self scheduled: aController
		from: Processor activeProcess
]

{ #category : #scheduling }
ControlManager >> scheduleOnBottom: aController [ 
	"Make aController be scheduled as a scheduled controller, but not the 
	active one. Put it at the end of the ordered collection of controllers."

	scheduledControllers addLast: aController
]

{ #category : #scheduling }
ControlManager >> schedulePassive: aController [ 
	"Make aController be scheduled as a scheduled controller, but not the 
	active one. Put it at the beginning of the ordered collection of 
	controllers."

	scheduledControllers addFirst: aController
]

{ #category : #private }
ControlManager >> scheduled: aController from: aProcess [

	activeControllerProcess==aProcess
		ifTrue: 
			[activeController ~~ nil
					ifTrue: [activeController controlTerminate].
			aController centerCursorInView.
			self activeController: aController]
]

{ #category : #accessing }
ControlManager >> scheduledControllers [
	"Answer a copy of the ordered collection of scheduled controllers."

	^scheduledControllers copy
]

{ #category : #accessing }
ControlManager >> scheduledWindowControllers [
	"Same as scheduled controllers, but without ScreenController.
	Avoids null views just after closing, eg, a debugger."

	^ scheduledControllers select:
		[:c | c ~~ screenController and: [c view ~~ nil]]
]

{ #category : #accessing }
ControlManager >> screenController [
	^ screenController
]

{ #category : #scheduling }
ControlManager >> searchForActiveController [
	"Find a scheduled controller that wants control and give control to it. If 
	none wants control, then see if the System Menu has been requested."
	activeController := nil.
	activeControllerProcess := Processor activeProcess.
	self activeController: self nextActiveController.
	Processor terminateActive
]

{ #category : #scheduling }
ControlManager >> spawnNewProcess [

	self activeController: self screenController
]

{ #category : #private }
ControlManager >> unCacheWindows [
	scheduledControllers ifNotNil: [scheduledControllers do:
		[:aController | aController view uncacheBits]]
]

{ #category : #scheduling }
ControlManager >> unschedule: aController [
	"Remove the view, aController, from the collection of scheduled 
	controllers."

	scheduledControllers remove: aController ifAbsent: []
]

{ #category : #displaying }
ControlManager >> updateGray [
	"From Georg Gollmann - 11/96.  tell the Screen Controller's model to use the currently-preferred desktop color."

	"ScheduledControllers updateGray"
	(screenController view model isMemberOf: InfiniteForm)
		ifTrue: [screenController view model: (InfiniteForm with:
Preferences desktopColor)]
]

{ #category : #scheduling }
ControlManager >> windowFromUser [
	"Present a menu of window titles, and returns the StandardSystemController belonging to the one that gets chosen, or nil if none"
	| controllers labels index |
	controllers := OrderedCollection new.
	labels := String streamContents:
		[:strm |
		scheduledControllers do:
			[:controller | controller == screenController ifFalse:
				[controllers addLast: controller.
				strm nextPutAll: (controller view label contractTo: 40); cr]].
		strm skip: -1  "drop last cr"].
	index := (UIManager default chooseFrom: labels lines).
	^ index > 0
		ifTrue:
			[controllers at: index]
		ifFalse:
			[nil]
]

{ #category : #accessing }
ControlManager >> windowOriginsInUse [
	"Answer a collection of the origins of windows currently on the screen in the current project.  5/21/96 sw"

	^ self scheduledWindowControllers collect: [:aController | aController view displayBox origin].
]
