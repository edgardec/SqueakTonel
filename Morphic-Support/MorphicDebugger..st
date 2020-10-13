Class {
	#name : #MorphicDebugger,
	#superclass : #Debugger,
	#instVars : [
		'errorWasInUIProcess'
	],
	#category : #'Morphic-Support'
}

{ #category : #opening }
MorphicDebugger class >> openOn: processToDebug context: context label: title contents: contentsStringOrNil fullView: full [ 
	
	| debugger uiBlock |
	debugger := self new
		process: processToDebug context: context;
		errorWasInUIProcess: (Project current spawnNewProcessIfThisIsUI: processToDebug).
	
	uiBlock := [
		full
			ifTrue: [debugger openFullNoSuspendLabel: title]
			ifFalse: [debugger openNotifierNoSuspendContents: contentsStringOrNil label: title].
	
		"Try drawing the debugger tool at least once to avoid freeze."
		debugger topView ifNotNil: [:window | window world displayWorld. "Not safely!"].
	].
		
	"Schedule debugging in a deferred UI message if necessary. Note that only the ui process should execute ui code."
	(Project current uiProcess isActiveProcess not or: [processToDebug isActiveProcess])
		ifTrue: [Project current addDeferredUIMessage: uiBlock]
		ifFalse: uiBlock.
	
	processToDebug suspend.
	
	"Get here only if active process is not the process-to-debug. So in tests, use a helper process if you want to access this return value."
	^ debugger
]

{ #category : #accessing }
MorphicDebugger >> errorWasInUIProcess [

	^ errorWasInUIProcess
]

{ #category : #accessing }
MorphicDebugger >> errorWasInUIProcess: boolean [

	errorWasInUIProcess := boolean
]

{ #category : #initialize }
MorphicDebugger >> initialize [

	super initialize.
	
	errorWasInUIProcess := false.
]

{ #category : #initialize }
MorphicDebugger >> openFullFromNotifier: notifierWindow [
	"Create, schedule and answer a full debugger with the given label. Do not terminate the current active process."

	super openFullFromNotifier: notifierWindow.
	
	notifierWindow delete.
	
	^ ToolBuilder default
		open: self
		label: notifierWindow label
]

{ #category : #initialize }
MorphicDebugger >> openFullNoSuspendLabel: aString [
	"Create, schedule and answer a full debugger with the given label. Do not terminate the current active process."

	super openFullNoSuspendLabel: aString.
	
	^ ToolBuilder default
		open: self
		label: aString
]

{ #category : #initialize }
MorphicDebugger >> openNotifierNoSuspendContents: msgString label: label [

	| builder spec |
	super openNotifierNoSuspendContents: msgString label: label.
	
	builder := ToolBuilder default.
	spec := self buildNotifierWith: builder label: label message: msgString.

	^ ToolBuilder default open: spec
]

{ #category : #private }
MorphicDebugger >> resumeProcess: processToResume [ 

	processToResume isTerminated ifFalse: [
		errorWasInUIProcess ifTrue: [Project current uiProcess: processToResume].
		processToResume resume.
		errorWasInUIProcess ifTrue: [Processor terminateActive]].
]

{ #category : #initialize }
MorphicDebugger >> windowIsClosing [
	"Keep track of last debugger extent."

	interruptedProcess ifNil: [ ^ self ].

	SavedExtent ifNotNil:
		[ self dependents
			detect:
				[ : each | each isWindowForModel: self ]
			ifFound:
				[ : topWindow | | isDebuggerNotNotifier |
				isDebuggerNotNotifier := self dependents anySatisfy:
					[ : each | each isTextView ].
				isDebuggerNotNotifier ifTrue: [
					SavedExtent := (topWindow extent / RealEstateAgent scaleFactor) rounded ] ]
			ifNone: [ "do nothing" ] ].

	super windowIsClosing.
]
