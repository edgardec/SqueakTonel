Class {
	#name : #MVCDebugger,
	#superclass : #Debugger,
	#instVars : [
		'interruptedController'
	],
	#category : #'ST80-Support'
}

{ #category : #opening }
MVCDebugger class >> openOn: processToDebug context: context label: title contents: contentsStringOrNil fullView: full [
	"Open a notifier in response to an error, halt, or notify. A notifier view just shows a short view of the sender stack and provides a menu that lets the user open a full debugger."

	| debugger cm ac acp wasActive |
	cm := Project current world. "controller manager"
	ac := cm activeController.
	acp := cm activeControllerProcess. "the ui process"
	wasActive := cm inActiveControllerProcess.
	
	debugger := self new
		process: processToDebug
		"Keep track of the controller if it matches."
		controller: (acp == processToDebug ifTrue: [ac])
		context: context.

	full
		ifTrue: [debugger openFullNoSuspendLabel: title]
		ifFalse: [debugger openNotifierNoSuspendContents: contentsStringOrNil label: title].

	"Try drawing the debugger tool at least once to avoid freeze."
	Project current restoreDisplay.

	"If we are in a helper process, #openNoTerminate WILL NOT activate the debugger's controller. Example: user-interrupt request (cmd+dot)."
	(acp == processToDebug and: [wasActive not])
		ifTrue: [ [cm searchForActiveController] fork ].
	
	"Be sure to suspend the process we want to debug now."
	processToDebug suspend.

	"If we are NOT in a helper process, #openNoTerminate WILL NOT terminate the active controller's process."
	(acp ~~ processToDebug and: [wasActive])
		ifTrue: [ Processor terminateActive ].
	
	"Get here only if active process is not the process-to-debug. Use helper process if you want to access this return value."
	^ debugger
]

{ #category : #initialize }
MVCDebugger >> context: aContext [

	self
		process: Processor activeProcess
		controller: (ScheduledControllers inActiveControllerProcess
						ifTrue: [ScheduledControllers activeController])
		context: aContext.
]

{ #category : #initialize }
MVCDebugger >> openFullFromNotifier: notifierView [
	"Create, schedule and answer a full debugger with the given label. Do not terminate the current active process."

	| fullView |
	super openFullFromNotifier: notifierView.
		
	fullView := ToolBuilder default build: self.
	fullView label: notifierView label. "Keep the label."
	fullView controller openNoTerminate.
	
	notifierView controller closeAndUnscheduleNoTerminate.
	Processor terminateActive.
]

{ #category : #initialize }
MVCDebugger >> openFullNoSuspendLabel: aString [
	"Create, schedule and answer a full debugger with the given label. Do not terminate the current active process."

	| fullView |
	super openFullNoSuspendLabel: aString.
		
	fullView := ToolBuilder default build: self.
	fullView label: aString.
	fullView controller openNoTerminate.
	
	^ fullView
]

{ #category : #initialize }
MVCDebugger >> openNotifierNoSuspendContents: msgString label: label [

	| builder spec view |
	EventSensor default flushEvents.
	super openNotifierNoSuspendContents: msgString label: label.
	
	builder := ToolBuilder default.
	spec := self buildNotifierWith: builder label: label message: msgString.
	
	view := builder build: spec.
	view controller openNoTerminate.

	^ view
]

{ #category : #initialize }
MVCDebugger >> process: aProcess controller: aController context: aContext [

	self process: aProcess context: aContext.
	
	interruptedController := aController.
]

{ #category : #private }
MVCDebugger >> resumeProcess: processToResume [ 
	"Finally free the reference to the controller if any. We cannot do this in #windowIsClosing."
	
	| controllerToReschedule |
	controllerToReschedule := interruptedController.
	interruptedController := nil.
	
	ScheduledControllers
		activeController: controllerToReschedule
		andProcess: processToResume.
]
