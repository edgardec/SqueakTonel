"
You must be in a Morphic project to run these tests! Note that *ALL* tests construct new processes and leave the current UI process as is. Even errors are injected in helper processes. So, the test runner will not suspend or terminate when running these tests.

Note that many of these tests depend on the StandardToolSet. So, if you have a custom tool set, maybe reset it first.
"
Class {
	#name : #DebuggerTests,
	#superclass : #TestCase,
	#instVars : [
		'process',
		'debugger',
		'window',
		'reset'
	],
	#category : #'ToolsTests-Debugger'
}

{ #category : #support }
DebuggerTests >> doTestUserInterruptFor: block priority: priority [
	"Note that we cannot signal the InterruptSemaphore because there is already the regular process waiting for it. We simulate that semaphore with a custom delay."
	
	| work wait interruptHelper |
	work := Semaphore new.
	wait := Semaphore new. "Maybe not necessary?"
	
	process := [ work wait. block value ] newProcess.
	process priority: priority.
	self assert: process priority >= Processor activeProcess priority. "You cannot interrupt lower priority processes."
	process resume.
	
	interruptHelper := [ wait wait. 10 milliSeconds wait. Smalltalk handleUserInterrupt ] newProcess.
	interruptHelper priority: Processor lowIOPriority.
	self assert: interruptHelper priority > process priority.
	interruptHelper resume.
	
	[wait signal. work signal] valueNoContextSwitch.
	process priority = Processor activeProcess priority ifTrue: [Processor yield].
	
	self assert: interruptHelper isTerminated.

	self ensureDebugger.
]

{ #category : #support }
DebuggerTests >> ensureDebugger [

	debugger ifNotNil: [debugger close].
	
	debugger := nil.
	window := nil.
	
	self assert: process notNil.
	self assert: process isSuspended.

	self findDebugger.	
	
	self assert: window notNil.
	self assert: debugger notNil.
]

{ #category : #support }
DebuggerTests >> findDebugger [

	window := nil.
	debugger := nil.
		
	self findDebuggerWindowFor: process.

	window ifNil: [
		self updateUserInterface.
		self findDebuggerWindowFor: process].

	window ifNotNil: [debugger := window model]
]

{ #category : #support }
DebuggerTests >> findDebuggerWindowFor: process [

	window :=  (Project current world in: [:world | world submorphs, world firstHand submorphs])
		detect: [:m | (m isSystemWindow and: [m model isKindOf: Debugger]) and: [m model interruptedProcess == process]]
		ifNone: [].
]

{ #category : #support }
DebuggerTests >> installToolSet [

	ToolSet default: DebuggerTestsToolSet new.
]

{ #category : #running }
DebuggerTests >> setUp [

	super setUp.
	
	Project current isMorphic ifFalse: [self fail].
	Project current uiProcess isActiveProcess ifFalse: [self fail].

	reset := {
		[:enable | [enable ifTrue: [Preferences enable: #logDebuggerStackToFile]]]
			value: Preferences logDebuggerStackToFile.
		[:ts | [self uninstallToolSet. ToolSet default: ts]]
			value: ToolSet default.
	}.
	
	Preferences disable: #logDebuggerStackToFile.
]

{ #category : #running }
DebuggerTests >> tearDown [

	debugger ifNotNil: [debugger close].
	process ifNotNil: [process terminate].
	
	process := nil.
	debugger := nil.
	window := nil.

	reset do: #value.	
	
	super tearDown.
]

{ #category : #tests }
DebuggerTests >> test01UserInterrupt [
	
	| counter |
	{
		[ [counter := counter + 1] repeat ]. 
		[ [counter := counter + 1. true] whileTrue ]. 
		"[ counter := counter + 1. Smalltalk createStackOverflow ]." "Disabled because VM may actually crash under certain conditions."
	} do: [:workBlock |
		{
			Processor userSchedulingPriority.
			Processor userSchedulingPriority + 1.
			Processor userInterruptPriority
		} do: [:workPriority |
			counter := 0.
			self doTestUserInterruptFor: workBlock priority: workPriority.
			self assert: counter > 0.
			self assert: debugger isNotifier]].
]

{ #category : #tests }
DebuggerTests >> test02UnhandledException [

	| counter |
	{
		[ counter := counter + 1. 7/0 ]. 'ZeroDivide'. 
		[ counter := counter + 1. Halt signal ]. 'Halt'.
		[ counter := counter + 1. Warning signal: 'Test' ]. 'Warning'
	} pairsDo: [:errorBlock :label |
		Processor systemBackgroundPriority
			to: Processor timingPriority
			by: 10
			do: [:priority |
				counter := 0.
	
				process := errorBlock forkAt: priority.
	
				"Let lower priority processes run to raise their exception."
				priority <= Processor activeProcess priority ifTrue: [
					3 timesRepeat: [process isSuspended not ifTrue: [50 milliSeconds wait]]].
				
				self ensureDebugger.
				
				self assert: counter > 0.
				self assert: (window label beginsWith: label).
				self assert: debugger isNotifier]]
]

{ #category : #tests }
DebuggerTests >> test03AsyncronousExceptions [
	"We want to get n different debuggers from n different processes."
	
	((1 to: 3) "... more than 1 ... so ... 3 sounds about right ..."
		collect: [:inc | [ Error signal ] forkAt: Processor userSchedulingPriority + inc])
		do: [:errorProcess |
				"There must be debuggers for all processes."
				process := errorProcess.
				self ensureDebugger];
		in: [:all | debugger close "Just close the last debugger."];
		do: [:errorProcess |
				process := errorProcess.
				self findDebugger.
				
				self assert: debugger isNil.
				self assert: process isTerminated]
]

{ #category : #tests }
DebuggerTests >> test04DebuggerSuspendsProcess [
	"Opening the debugger on a running process means to suspend that process."

	process := [ [3 + 4] repeat ] newProcess.
	
	"Choose a priority lower than the active process so that we can use an endless loop."
	process priority: Processor activeProcess priority - 1.
	process resume. Processor yield.

	self deny: process isSuspended.

	debugger := process debug.
	
	self assert: process isSuspended.
]

{ #category : #tests }
DebuggerTests >> test05DebuggerTerminatesProcess [
	"Closing a debugger on a suspended process means terminating that process."
	
	process := [ [3 + 4] repeat ] newProcess.
	
	"Choose a priority lower than the active process so that we can use an endless loop."
	process priority: Processor activeProcess priority - 1.
	process resume. Processor yield.

	self deny: process isTerminated.

	debugger := process debug.
	debugger close.
	
	self assert: process isTerminated.
]

{ #category : #tests }
DebuggerTests >> test06DebugSpecificContext [
	
	| context |

	process := [ #(1 2 3) collect: [:ea | ea odd ifTrue: [ ea ] ifFalse: [ Processor activeProcess suspend ] ] ] newProcess.
	process priority: Processor activeProcess priority + 1.
	process resume.

	"Find specific context by following #sender chain."
	context := process suspendedContext.
	[context selector = #collect: ] whileFalse: [context := context sender].

	debugger := process debug: context.

	self assert: debugger contextStackTop = context.
]

{ #category : #tests }
DebuggerTests >> test07DebuggerNotifier [
	
	process := [ 3+4 ] newProcess.
	debugger := process debugWithTitle: 'Test' full: false.
	self assert: debugger isNotifier.
]

{ #category : #tests }
DebuggerTests >> test08DebuggerFull [
	
	process := [ 3+4 ] newProcess.
	debugger := process debugWithTitle: 'Test' full: true.
	self assert: debugger isFull.
]

{ #category : #tests }
DebuggerTests >> test09DebuggerNotifierOrFull [
	"Test the defaults."
		
	process := [ 3+4 ] newProcess.
	debugger := process debug.
	self assert: debugger isFull.
	
	debugger close.
	
	process := [ 3+4 ] newProcess.
	debugger := process debugWithTitle: 'Test'.
	self assert: debugger isFull.

	debugger close.
	
	process := [ 3+4 ] newProcess.
	debugger := process debug: process suspendedContext.
	self assert: debugger isNotifier.
]

{ #category : #tests }
DebuggerTests >> test10DebugBlock [
	"Used for debug-it in tools."

	process := Process forBlock: [3+4].
	debugger := process debug.

	self deny: 7 equals: process suspendedContext top.
	debugger stepOver.
	self assert: 7 equals: process suspendedContext top.
]

{ #category : #tests }
DebuggerTests >> test11DebugBlockAtContext [
	"Similar to the run-to feature in the debugger, run the process until a certain condition is met."
	
	process := Process
		forBlock: [(#(1 2 3) collect: [:ea | ea + 1]) in: [:all | all sum]]
		runUntil: [:context | context selector = #sum].
	debugger := process debug.

	self deny: 9 equals: process suspendedContext top.
	debugger stepOver.
	self assert: 9 equals: process suspendedContext top.
]

{ #category : #tests }
DebuggerTests >> test12ToolSetHandleError [
	"Test whether the #handle* callback is reached as expected."
	
	self installToolSet.

	process := [ Error signal ] newProcess.
	process priority: Processor userSchedulingPriority + 1.
	
	self assert: 0 equals: self toolSet handledErrors size.
	process resume.
	self assert: 1 equals: self toolSet handledErrors size.
]

{ #category : #tests }
DebuggerTests >> test13ToolSetHandleWarning [
	"Test whether the #handle* callback is reached as expected."
	
	self installToolSet.

	process := [ Warning signal ] newProcess.
	process priority: Processor userSchedulingPriority + 1.
	
	self assert: 0 equals: self toolSet handledWarnings size.
	process resume.
	self assert: 1 equals: self toolSet handledWarnings size.
]

{ #category : #tests }
DebuggerTests >> test14ToolSetHandleUserInterruptRequest [
	"Test whether the #handle* callback is reached as expected."
	
	self installToolSet.

	process := [ Smalltalk handleUserInterrupt ] newProcess.
	process priority: Processor userSchedulingPriority + 1.
	
	self assert: 0 equals: self toolSet handledUserInterruptRequests size.
	process resume.
	self assert: 1 equals: self toolSet handledUserInterruptRequests size.
]

{ #category : #tests }
DebuggerTests >> test15ToolSetDebugProcess [
	"Test whether the #debug* callback is reached as expected."
	
	self installToolSet.

	process := [ 3+4 ] newProcess.
	
	self assert: 0 equals: self toolSet debuggedProcesses size.
	process debug.
	self assert: 1 equals: self toolSet debuggedProcesses size.
]

{ #category : #support }
DebuggerTests >> toolSet [

	^ ToolSet default
]

{ #category : #support }
DebuggerTests >> uninstallToolSet [

	(ToolSet default isKindOf: DebuggerTestsToolSet) ifTrue: [
		ToolSet unregister: ToolSet default].
]

{ #category : #support }
DebuggerTests >> updateUserInterface [

	Project current world doOneCycle.
]
