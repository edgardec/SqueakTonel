"
My single instance, named Processor, coordinates the use of the physical processor by all Processes requiring service.
"
Class {
	#name : #ProcessorScheduler,
	#superclass : #Object,
	#instVars : [
		'quiescentProcessLists',
		'activeProcess'
	],
	#classVars : [
		'BackgroundProcess',
		'HighIOPriority',
		'LowIOPriority',
		'SystemBackgroundPriority',
		'SystemRockBottomPriority',
		'TimingPriority',
		'UserBackgroundPriority',
		'UserInterruptPriority',
		'UserSchedulingPriority'
	],
	#category : #'Kernel-Processes'
}

{ #category : #'background process' }
ProcessorScheduler class >> idleProcess [
	"A default background process which is invisible."

	[self relinquishProcessorForMicroseconds: 1000] repeat
]

{ #category : #'class initialization' }
ProcessorScheduler class >> initialize [
     
	SystemRockBottomPriority := 10.
	SystemBackgroundPriority := 20.
	UserBackgroundPriority := 30.
	UserSchedulingPriority := 40.
	UserInterruptPriority := 50.
	LowIOPriority := 60.
	HighIOPriority := 70.
	TimingPriority := 80.

	"ProcessorScheduler initialize."
]

{ #category : #'background process' }
ProcessorScheduler class >> installIdleProcess [
	"Install a background process of the lowest possible priority that is always runnable."
	"Details: The virtual machine requires that there is aways some runnable process that
	 can be scheduled; this background process ensures that this is the case."

	BackgroundProcess ifNotNil: [BackgroundProcess terminate].
	BackgroundProcess := [self idleProcess] newProcess.
	BackgroundProcess priority: SystemRockBottomPriority.
	BackgroundProcess resume.
]

{ #category : #'instance creation' }
ProcessorScheduler class >> new [
	"New instances of ProcessorScheduler should not be created."

	self error:
'New ProcessSchedulers should not be created since
the integrity of the system depends on a unique scheduler'
]

{ #category : #'background process' }
ProcessorScheduler class >> relinquishProcessorForMicroseconds: anInteger [
	"Platform specific. This primitive is used to return processor cycles to the host operating system when Squeak's idle process is running (i.e., when no other Squeak process is runnable). On some platforms, this primitive causes the entire Squeak application to sleep for approximately the given number of microseconds. No Squeak process can run while the Squeak application is sleeping, even if some external event makes it runnable. On the Macintosh, this primitive simply calls GetNextEvent() to give other applications a chance to run. On platforms without a host operating system, it does nothing. This primitive should not be used to add pauses to a Squeak process; use a Delay instead."

	<primitive: 230>
	"don't fail if primitive is not implemented, just do nothing"

]

{ #category : #'background process' }
ProcessorScheduler class >> startUp: resuming [

	Smalltalk processPreemptionYields ifTrue: [
		Smalltalk processPreemptionYields: false].

	resuming ifTrue: [
		Smalltalk installLowSpaceWatcher.
		self installIdleProcess].
]

{ #category : #accessing }
ProcessorScheduler >> activePriority [
	"Answer the priority level of the currently running Process."

	^activeProcess effectiveProcess priority
]

{ #category : #accessing }
ProcessorScheduler >> activeProcess [
	"Answer the currently running Process."

	^activeProcess effectiveProcess
]

{ #category : #private }
ProcessorScheduler >> anyProcessesAbove: highestPriority [ 
	"Do any instances of Process exist with higher priorities?"

	^(Process allSubInstances select: [:aProcess | 
		aProcess priority > highestPriority]) isEmpty
		"If anyone ever makes a subclass of Process, be sure to use allSubInstances."
]

{ #category : #accessing }
ProcessorScheduler >> backgroundProcess [
	"Answer the background process"
	^ BackgroundProcess
]

{ #category : #'priority names' }
ProcessorScheduler >> highIOPriority [
	"Answer the priority at which the most time critical input/output 
	processes should run. An example is the process handling input from a 
	network."

	^HighIOPriority
]

{ #category : #accessing }
ProcessorScheduler >> highestPriority [
	"Answer the number of priority levels currently available for use."

	^quiescentProcessLists size
]

{ #category : #accessing }
ProcessorScheduler >> highestPriority: newHighestPriority [
	"Change the number of priority levels currently available for use."

	| newProcessLists |
	(quiescentProcessLists size > newHighestPriority
		and: [self anyProcessesAbove: newHighestPriority])
			ifTrue: [self error: 'There are processes with priority higher than '
													,newHighestPriority printString].
	newProcessLists := Array new: newHighestPriority.
	1 to: ((quiescentProcessLists size) min: (newProcessLists size)) do: 
		[:priority | newProcessLists at: priority put: (quiescentProcessLists at: priority)].
	(quiescentProcessLists size max: 1) to: newProcessLists size do: 
		[:priority | newProcessLists at: priority put: LinkedList new].
	quiescentProcessLists := newProcessLists
]

{ #category : #'priority names' }
ProcessorScheduler >> lowIOPriority [
	"Answer the priority at which most input/output processes should run. 
	Examples are the process handling input from the user (keyboard, 
	pointing device, etc.) and the process distributing input from a network."

	^LowIOPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> lowestPriority [
	"Return the lowest priority that is allowed with the scheduler"
	^SystemRockBottomPriority
]

{ #category : #'CPU usage tally' }
ProcessorScheduler >> nextReadyProcess [
	quiescentProcessLists reverseDo: [ :list |
		list isEmpty ifFalse: [ | proc |
			proc := list first.
			proc suspendedContext ifNotNil: [ ^proc ]]].
	^nil
]

{ #category : #'objects from disk' }
ProcessorScheduler >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a path to me in the other system instead."

	dp := DiskProxy global: #Processor selector: #yourself args: #().
	refStrm replace: self with: dp.
	^ dp

]

{ #category : #accessing }
ProcessorScheduler >> preemptedProcess [
	"Return the process that the currently active process just preempted."
	
	self activeProcess priority to: 1 by: -1 do: [:priority |
		(quiescentProcessLists at: priority) ifNotEmpty: [:list |
			^ Smalltalk processPreemptionYields
				ifTrue: [list last]
				ifFalse: [list first]]].
	^ nil
	
	"Processor preemptedProcess"
]

{ #category : #removing }
ProcessorScheduler >> remove: aProcess ifAbsent: aBlock [ 
	"Remove aProcess from the list on which it is waiting for the processor 
	and answer aProcess. If it is not waiting, evaluate aBlock."

	(quiescentProcessLists at: aProcess priority)
		remove: aProcess ifAbsent: aBlock.
	^aProcess
]

{ #category : #'process state change' }
ProcessorScheduler >> suspendFirstAt: aPriority [ 
	"Suspend the first Process that is waiting to run with priority aPriority."

	^self suspendFirstAt: aPriority
		  ifNone: [self error: 'No Process to suspend']
]

{ #category : #'process state change' }
ProcessorScheduler >> suspendFirstAt: aPriority ifNone: noneBlock [ 
	"Suspend the first Process that is waiting to run with priority aPriority. If 
	no Process is waiting, evaluate the argument, noneBlock."

	| aList |
	aList := quiescentProcessLists at: aPriority.
	aList isEmpty
		ifTrue: [^noneBlock value]
		ifFalse: [^aList first suspend]
]

{ #category : #'priority names' }
ProcessorScheduler >> systemBackgroundPriority [
	"Answer the priority at which system background processes should run. 
	Examples are an incremental garbage collector or status checker."

	^SystemBackgroundPriority
]

{ #category : #'CPU usage tally' }
ProcessorScheduler >> tallyCPUUsageFor: seconds [
	"Start a high-priority process that will tally the next ready process for the given
	number of seconds. Answer a Block that will return the tally (a Bag) after the task
	is complete" 
	^self tallyCPUUsageFor: seconds every: 10

]

{ #category : #'CPU usage tally' }
ProcessorScheduler >> tallyCPUUsageFor: seconds every: msec [
	"Start a high-priority process that will tally the next ready process for the given
	number of seconds. Answer a Block that will return the tally (a Bag) after the task
	is complete" 
	| tally sem delay endDelay |
	tally := IdentityBag new: 200.
	delay := Delay forMilliseconds: msec truncated.
	endDelay := Delay forSeconds: seconds.
	endDelay schedule.
	sem := Semaphore new.
	[
		[ endDelay isExpired ] whileFalse: [
			delay wait.
			tally add: Processor nextReadyProcess
		].
		sem signal.
	] forkAt: self highestPriority.

	^[ sem wait. tally ]
]

{ #category : #'process state change' }
ProcessorScheduler >> terminateActive [
	"Terminate the process that is currently running."

	activeProcess effectiveProcess terminate
]

{ #category : #'priority names' }
ProcessorScheduler >> timingPriority [
	"Answer the priority at which the system processes keeping track of real 
	time should run."

	^TimingPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> userBackgroundPriority [
	"Answer the priority at which user background processes should run."

	^UserBackgroundPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> userInterruptPriority [
	"Answer the priority at which user processes desiring immediate service 
	should run. Processes run at this level will preempt the window 
	scheduler and should, therefore, not consume the processor forever."

	^UserInterruptPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> userSchedulingPriority [
	"Answer the priority at which the window scheduler should run."

	^UserSchedulingPriority
]

{ #category : #accessing }
ProcessorScheduler >> waitingProcessesAt: aPriority [
	"Return the list of processes at the given priority level."
	^quiescentProcessLists at: aPriority
]

{ #category : #'process state change' }
ProcessorScheduler >> yield [
	"Give other Processes at the current priority a chance to run."

	| semaphore |

	<primitive: 167>
	semaphore := Semaphore new.
	[semaphore signal] fork.
	semaphore wait
]
