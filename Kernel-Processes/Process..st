"
I represent an independent path of control in the system. This path of control may be stopped (by sending the message suspend) in such a way that it can later be restarted (by sending the message resume). When any one of several paths of control can be advanced, the single instance of ProcessorScheduler named Processor determines which one will actually be advanced, partly using the value of priority.

Instance Variables: N.B. The first four are used by the virtual machine. They must be defined, and defined in this order,
	suspendedContext:		<Context|nil>
	priority:					<Integer>
	myList:					<LinkedList|nil>
	threadId:				<Integer|nil>
	effectiveProcess:		<Process|nil>
	name:					<String|nil>
	island:					<Island|nil>
	env:					<Dictionary|nil>

effectiveProcess
	- if not nil effectiveProcess is the process the receiver is running on behalf of.  Used by the execution smulation machinery (used by the debugger) to ensure that Processor activeProcess et al answer the expected result when simulating execution (e.g. when debugging).  See evaluate:onBehalfOf: and senders.

env
	- if not nil this is a Dictionary providing process-specific variables.  See e.g. environmentAt:*, DynamicVariable and ProcessSpecificVariable.

island
	- used by Tweak and Croquet to partition the image into multiple address spaces

myList
	- if nil, the receiver is either suspended or the active process.  If not nil it is either some condition variable (Semaphore, Mutex) that the receiver is blocked waiting on, or it is the LinkedList in ProcessorScheduler quiescentProcesses that holds the processes for the receiver's priority that are not the current active process but are still runnable.

name
	- if not nil this is the name of the process, used for information, see e.g. the names of processes displayed in the ProcessBrowser

priority
	- the priority of the process, which corresponds to the index in ProcessorScheduler quiescentProcesses that holds the LinkedList of processes at this priority.  If running but quiescent, changing priority involves changing priority and myList.

suspendedContext
	- if nil, then the receiver is either the active process or has been terminated.  If not nil it is the Context at the hot end of the receiver's stack

threadId
	- if not nil then the receiver is bound to some native thread and the VM will ensure that when executing the receiver, the VM will be running on that native thread.  Set by the VM.  Not to be set manually.  Meaningful only on threaded VMs (which do not mean VMs with a threaded heartbeat).  It is required to be the fourth instance variable. See SmalltalkImage >> #processHasThreadIdInstVar: for further information.
"
Class {
	#name : #Process,
	#superclass : #Link,
	#instVars : [
		'suspendedContext',
		'priority',
		'myList',
		'threadId',
		'effectiveProcess',
		'name',
		'island',
		'env'
	],
	#category : #'Kernel-Processes'
}

{ #category : #'instance creation' }
Process class >> forContext: aContext priority: anInteger [ 
	"Answer an instance of me that has suspended aContext at priority 
	anInteger."

	| newProcess |
	newProcess := self new.
	newProcess suspendedContext: aContext.
	newProcess priority: anInteger.
	^newProcess
]

{ #category : #'changing suspended state' }
Process >> activateReturn: aContext value: value [
	"Activate 'aContext return: value', so execution will return to aContext's sender"

	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext activateReturn: aContext value: value]
		onBehalfOf: self
]

{ #category : #printing }
Process >> browserPrintString [
	^self browserPrintStringWith: suspendedContext
]

{ #category : #printing }
Process >> browserPrintStringWith: anObject [ 
	| stream |
	stream := WriteStream
				on: (String new: 100).
	stream nextPut: $(.
	priority printOn: stream.
	self isSuspended
		ifTrue: [stream nextPut: $s].
	stream nextPutAll: ') '.
	stream nextPutAll: self name.
	stream nextPut: $:.
	stream space.
	stream nextPutAll: anObject asString.
	^ stream contents
]

{ #category : #accessing }
Process >> calleeOf: aContext [
	"Return the context whose sender is aContext.  Return nil if aContext is on top.  Raise error if aContext is not in process chain."

	suspendedContext == aContext ifTrue: [^ nil].
	^ (suspendedContext findContextSuchThat: [:c | c sender == aContext])
		ifNil: [self error: 'aContext not in process chain']
]

{ #category : #'changing suspended state' }
Process >> complete: aContext [ 
	"Run self until aContext is popped or an unhandled error is raised.  Return self's new top context, unless an unhandled error was raised then return the signaler context (rather than open a debugger)."
	
	| ctxt pair error |
	ctxt := suspendedContext.
	suspendedContext := nil.  "disable this process while running its stack in active process below"
	pair := Processor activeProcess
				evaluate: [ctxt runUntilErrorOrReturnFrom: aContext]
				onBehalfOf: self.
	suspendedContext := pair first.
	error := pair second.
	error ifNotNil:
		["Give a debugger a chance to update its title to reflect the new exception"
		 Notification new
			tag: {aContext. error};
			signal.
		 ^error signalerContext].
	^ suspendedContext
]

{ #category : #'changing suspended state' }
Process >> completeStep: aContext [ 
	"Resume self until aContext is on top, or if already on top, complete next step"

	| callee |
	self isTerminated ifTrue:
		[^ nil].
	self suspendedContext == aContext ifFalse:
		[^ self complete: (self calleeOf: aContext)].
	callee := self step.
	callee == aContext ifTrue: [^ callee].
	aContext isDead ifTrue: [^ self suspendedContext].  "returned"
	^ self complete: callee  "finish send"
]

{ #category : #'changing suspended state' }
Process >> completeTo: aContext [ 
	"Resume self until aContext is on top"

	self suspendedContext == aContext ifTrue: [^ aContext].
	^ self complete: (self calleeOf: aContext)
]

{ #category : #accessing }
Process >> copyStack [

	^ self copy install: suspendedContext copyStack
]

{ #category : #accessing }
Process >> effectiveProcess [
	"effectiveProcess is a mechanism to allow process-faithful debugging.  The debugger executes code
	 on behalf of processes, so unless some effort is made the identity of Processor activeProcess is not
	 correctly maintained when debugging code.  The debugger uses evaluate:onBehalfOf: to assign the
	 debugged process as the effectiveProcess of the process executing the code, preserving process
	 identity."
	^effectiveProcess ifNil: [self]
]

{ #category : #'process specific' }
Process >> environmentAt: key [ 
	^ self environmentAt: key ifAbsent: [self environmentKeyNotFound]
]

{ #category : #'process specific' }
Process >> environmentAt: key  ifAbsent: aBlock [
	
	^(env ifNil: [ ^aBlock value ]) at: key ifAbsent: aBlock.
]

{ #category : #'process specific' }
Process >> environmentAt: key ifAbsentPut: aBlock [
	
	^(env ifNil: [ env := Dictionary new ]) at: key ifAbsentPut: aBlock.
]

{ #category : #'process specific' }
Process >> environmentAt: key put: value [
	
	^(env ifNil: [ env := Dictionary new ]) at: key put: value.
]

{ #category : #'process specific' }
Process >> environmentKeyNotFound [ 
	self error: 'Environment key not found'
]

{ #category : #'process specific' }
Process >> environmentRemoveKey: key [
	^ self environmentRemoveKey: key ifAbsent: [self environmentKeyNotFound]
]

{ #category : #'process specific' }
Process >> environmentRemoveKey: key ifAbsent: errorBlock [
	
	^(env ifNil: [ ^errorBlock value ]) removeKey: key ifAbsent: errorBlock
]

{ #category : #private }
Process >> evaluate: aBlock onBehalfOf: aProcess [
	"Evaluate aBlock setting effectiveProcess to aProcess, and all other variables other than
	 the scheduling ones to those of aProcess.  Used in the execution simulation machinery
	 to ensure that Processor activeProcess evaluates correctly when debugging."
	| range savedVariables |
	"range accesses everything after myList, e.g. threadId, effectiveProcess, name, island, env"
	range := 5 to: Process instSize.
	savedVariables := range collect: [:i| self instVarAt: i].
	range do:
		[:i| self instVarAt: i put: (aProcess instVarAt: i)].
	effectiveProcess := aProcess.
	^aBlock ensure:
		["write back any assigned-to variables."
		 range do:
			[:i| | v |
			((v := self instVarAt: i) ~~ (aProcess instVarAt: i)
			 and: [v notNil]) ifTrue:
				[aProcess instVarAt: i put: v]].
		 "restore old values"
		 range with: savedVariables do:
			[:i :var| self instVarAt: i put: var]]
]

{ #category : #'changing suspended state' }
Process >> install: aContext [ 
	"Replace the suspendedContext with aContext."

	self == Processor activeProcess
		ifTrue: [^self error: 'The active process cannot install contexts'].
	suspendedContext := aContext
]

{ #category : #testing }
Process >> isActiveProcess [

	^ self == Processor activeProcess
]

{ #category : #testing }
Process >> isBlocked [
	"A process is blocked if it is waiting on some list (i.e. a Semaphore), other than the runnable process lists."
	| myPriority |
	"Grab my prioirty now.  Even though evaluation is strictly right-to-left, accessing Processor could involve a send."
	myPriority := priority.
	^myList
		ifNil: [false]
		ifNotNil: [:list| list ~~ (Processor waitingProcessesAt: myPriority)]
]

{ #category : #testing }
Process >> isRunnable [
	"A process is runnable if it is the active process or is on one of the runnable process lists."
	| myPriority |
	"Grab my prioirty now.  Even though evaluation is strictly right-to-left, accessing Processor could involve a send."
	myPriority := priority.
	^myList
		ifNil: [^self == Processor activeProcess]
		ifNotNil: [:list| list == (Processor waitingProcessesAt: myPriority)]
]

{ #category : #testing }
Process >> isSuspended [
	"A process is suspended if it has been suspended with the suspend primitive.
	 It is distinguishable from the active process and a terminated process by
	 having a non-nil suspendedContext that is either not the bottom context
	 or has not reached its endPC."
	^nil == myList
	  and: [nil ~~ suspendedContext
	  and: [suspendedContext isBottomContext
			ifTrue: [suspendedContext closure
						ifNil: [suspendedContext methodClass ~~ Process
							or: [suspendedContext selector ~~ #terminate]]
						ifNotNil: [suspendedContext pc < suspendedContext closure endPC]]
			ifFalse: [true]]]
]

{ #category : #testing }
Process >> isTerminated [
	"Answer if the receiver is terminated, or at least terminating."
	self isActiveProcess ifTrue: [^ false].
	^suspendedContext isNil
	  or: ["If the suspendedContext is the bottomContext it is the block in Process>>newProcess.
		   If so, and the pc is at the endPC, the block has already sent and returned
		   from value and there is nothing more to do."
		suspendedContext isBottomContext
		and: [suspendedContext closure
						ifNil: [suspendedContext methodClass == Process
							and: [suspendedContext selector == #terminate]]
						ifNotNil: [suspendedContext pc >= suspendedContext closure endPC]]]
]

{ #category : #printing }
Process >> longPrintOn: stream [

	| ctxt |
	super printOn: stream.
	stream cr.
	ctxt := self suspendedContext.
	[ctxt == nil] whileFalse: [
		stream space.
		ctxt printOn: stream.
		stream cr.
		ctxt := ctxt sender.
	].

]

{ #category : #accessing }
Process >> name [

	^name ifNil: [ self hash asString forceTo: 5 paddingStartWith: $ ]
]

{ #category : #accessing }
Process >> name: aString [

	name := aString
]

{ #category : #'objects from disk' }
Process >> objectForDataStream: refStrm [
	"I am not allowed to be written on an object file."

	refStrm replace: self with: nil.
	^ nil
]

{ #category : #accessing }
Process >> offList [
	"OBSOLETE. Process>>suspend will atomically reset myList if the process is suspended. 
	There should never be a need to send #offList but some older users may not be aware 
	of the changed semantics to suspend and may try the old hickadidoo seen here:

		(suspendingList := process suspendingList) == nil
			ifTrue: [process == Processor activeProcess ifTrue: [process suspend]]
			ifFalse: [suspendingList remove: process ifAbsent:[].
					process offList].

	Usages like the above should be replaced by a simple 'process suspend' "
	myList := nil
]

{ #category : #'changing suspended state' }
Process >> popTo: aContext [ 
	"Pop self down to aContext by remote returning from aContext's callee.  Unwind blocks will be executed on the way.
	This is done by pushing a new context on top which executes 'aContext callee return' then resuming self until aContext is reached.  This way any errors raised in an unwind block will get handled by senders in self and not by senders in the activeProcess.
	If an unwind block raises an error that is not handled then the popping stops at the error and the signalling context is returned, othewise aContext is returned."

	self == Processor activeProcess ifTrue:
		[^self error: 'The active process cannot pop contexts'].
	^(self calleeOf: aContext)
		ifNil: [aContext]  "aContext is on top"
		ifNotNil:
			[:callee|
			 Processor activeProcess
				evaluate: [self return: callee value: callee receiver]
				onBehalfOf: self]
]

{ #category : #'changing suspended state' }
Process >> popTo: aContext value: aValue [
	"Replace the suspendedContext with aContext, releasing all contexts 
	 between the currently suspendedContext and it."

	self == Processor activeProcess ifTrue:
		[^self error: 'The active process cannot pop contexts'].
	^(self calleeOf: aContext)
		ifNil: [aContext]  "aContext is on top"
		ifNotNil:
			[:callee|
			 Processor activeProcess
				evaluate: [self return: callee value: aValue]
				onBehalfOf: self]
]

{ #category : #printing }
Process >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' in '.
	suspendedContext printOn: aStream
]

{ #category : #accessing }
Process >> priority [
	"Answer the priority of the receiver."

	^priority
]

{ #category : #accessing }
Process >> priority: anInteger [ 
	"Set the receiver's priority to anInteger."
	(anInteger >= Processor lowestPriority and:[anInteger <= Processor highestPriority])
		ifTrue: [priority := anInteger]
		ifFalse: [self error: 'Invalid priority: ', anInteger printString]
]

{ #category : #signaling }
Process >> pvtSignal: anException list: aList [
	"Private. This method is used to signal an exception from another
	process...the receiver must be the active process.  If the receiver 
	was previously waiting on a Semaphore, then return the process
	to the waiting state after signaling the exception and if the Semaphore
	has not been signaled in the interim"

	"Since this method is not called in a normal way, we need to take care
	that it doesn't directly return to the caller (because I believe that could
	have the potential to push an unwanted object on the caller's stack)."

	| blocker |
	self isActiveProcess ifFalse: [^self].
	anException signal.
	blocker := Semaphore new.
	[self suspend.
	suspendedContext := suspendedContext swapSender: nil.
	aList class == Semaphore 
		ifTrue:
			[aList isSignaled
				ifTrue: 
					[aList wait.  "Consume the signal that would have restarted the receiver"
					self resume]
				ifFalse:
					["Add us back to the Semaphore's list (and remain blocked)"
					myList := aList.
					aList add: self]]
		ifFalse: [self resume]] fork.
	blocker wait.



]

{ #category : #private }
Process >> releaseCriticalSection: runnable [
	"Figure out if we are terminating a process that is in the ensure: block of a critical section.
	 In this case, if the block has made progress, pop the suspendedContext so that we leave the
	 ensure: block inside the critical: without signaling the semaphore/exiting the primitive section,
	 since presumably this has already happened.  But if it hasn't made progress but is beyond the
	 wait (which we can tell by the oldList being one of the runnable lists, i.e. a LinkedList, not a
	 Semaphore or Mutex, et al), then the ensure: block needs to be run."
	| selectorJustSent |
	(suspendedContext method pragmaAt: #criticalSection) ifNil: [^self].
	selectorJustSent := suspendedContext selectorJustSentOrSelf.

	"Receiver and/or argument blocks of ensure: in Semaphore>>critical: or Mutex>>#critical:"
	suspendedContext isClosureContext ifTrue:
		[suspendedContext sender isUnwindContext ifTrue:
			[| notWaitingButMadeNoProgress |
			"Avoid running the ensure: block twice, popping it if it has already been run. If runnable
			 but at the wait, leave it in place. N.B. No need to check if the block receiver of ensure: has
			 not started to run (via suspendedContext pc = suspendedContext startpc) because ensure:
			 uses valueNoContextSwitch, and so there is no suspension point before the wait."
			 notWaitingButMadeNoProgress :=
				runnable
				and: [selectorJustSent == #wait
				and: [suspendedContext sender selectorJustSentOrSelf == #valueNoContextSwitch]].
			 notWaitingButMadeNoProgress ifFalse:
				[suspendedContext := suspendedContext home]].
		 ^self].

	"Either Semaphore>>critical: or Mutex>>#critical:.  Is the process still blocked?  If so, nothing further to do."
	runnable ifFalse: [^self].

	"If still at the wait the ensure: block has not been activated, so signal to restore."
	selectorJustSent == #wait ifTrue:
		[suspendedContext receiver signal].

	"If still at the lock primitive and the lock primitive just acquired ownership (indicated by it answering false)
	 then the ensure block has not been activated, so explicitly primitiveExitCriticalSection to unlock."
	(selectorJustSent == #primitiveEnterCriticalSection
	 or: [selectorJustSent == #primitiveTestAndSetOwnershipOfCriticalSection]) ifTrue:
		[(suspendedContext stackPtr > 0
		  and: [suspendedContext top == false]) ifTrue:
			[suspendedContext receiver primitiveExitCriticalSection]]
]

{ #category : #'changing suspended state' }
Process >> restartTop [
	"Rollback top context and replace with new method.  Assumes self is suspended"

	suspendedContext privRefresh
]

{ #category : #'changing suspended state' }
Process >> restartTopWith: method [
	"Rollback top context and replace with new method.  Assumes self is suspended"

	method isQuick 
		ifTrue: [self popTo: suspendedContext sender]
		ifFalse:
			[suspendedContext method frameSize >= method frameSize
				ifTrue: [suspendedContext privRefreshWith: method]
				ifFalse:
					[self assert: suspendedContext isExecutingBlock not.
					 suspendedContext := Context
												sender: suspendedContext sender
												receiver: suspendedContext receiver
												method: method
												arguments: ((1 to: method numArgs) collect:
																[:i| suspendedContext tempAt: i])]].

]

{ #category : #'changing process state' }
Process >> resume [
	"Primitive. Allow the process that the receiver represents to continue. Put 
	 the receiver in line to become the activeProcess.  Fail if the receiver is 
	 already waiting in a queue (in a Semaphore or ProcessScheduler).  Fail if
	 the receiver's suspendedContext is not a context.
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 87>
	self primitiveFailed
]

{ #category : #'changing suspended state' }
Process >> return: aContext value: value [
	"Pop thread down to aContext's sender.  Execute any unwind blocks on the way.  See #popTo: comment and #runUntilErrorOrReturnFrom: for more details."

	suspendedContext == aContext ifTrue:
		[^Processor activeProcess
			evaluate: [suspendedContext := aContext return: value from: aContext]
			onBehalfOf: self].
	self activateReturn: aContext value: value.
	^self complete: aContext
]

{ #category : #'changing process state' }
Process >> run [
	"Suspend current process and execute self instead"

	| proc |
	proc := Processor activeProcess.
	[	proc suspend.
		self resume.
	] forkAt: Processor highestPriority
]

{ #category : #signaling }
Process >> signalException: anException [
	"Signal an exception in the receiver process...if the receiver is currently
	suspended, the exception will get signaled when the receiver is resumed.  If 
	the receiver is blocked on a Semaphore, it will be immediately re-awakened
	and the exception will be signaled; if the exception is resumed, then the receiver
	will return to a blocked state unless the blocking Semaphore has excess signals"
	| oldList |
	"If we are the active process, go ahead and signal the exception"
	self isActiveProcess ifTrue: [^anException signal].

	"Suspend myself first to ensure that I won't run away in the
	midst of the following modifications."
	myList ifNotNil:[oldList := self suspend].

	"Add a new method context to the stack that will signal the exception"
	suspendedContext := Context
		sender: suspendedContext
		receiver: self
		method: (self class lookupSelector: #pvtSignal:list:)
		arguments: (Array with: anException with: oldList).

	"If we are on a list to run, then suspend and restart the receiver 
	(this lets the receiver run if it is currently blocked on a semaphore).  If
	we are not on a list to be run (i.e. this process is suspended), then when the
	process is resumed, it will signal the exception"

	oldList ifNotNil: [self resume]
]

{ #category : #'changing suspended state' }
Process >> step [

	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext step]
		onBehalfOf: self
]

{ #category : #'changing suspended state' }
Process >> step: aContext [ 
	"Resume self until aContext is on top, or if already on top, do next step"

	^Processor activeProcess
		evaluate:
			[self suspendedContext == aContext
				ifTrue: [suspendedContext := suspendedContext step]
				ifFalse: [self complete: (self calleeOf: aContext)]]
		onBehalfOf: self
]

{ #category : #'changing suspended state' }
Process >> stepToCallee [
	"Step until top context changes"

	Processor activeProcess
		evaluate:
			[| ctxt |
			ctxt := suspendedContext.
			[ctxt == suspendedContext] whileTrue: [
				suspendedContext := suspendedContext step]]
		onBehalfOf: self.
	^suspendedContext
]

{ #category : #'changing suspended state' }
Process >> stepToHome: aContext [ 
	"Resume self until the home of top context is aContext.  Top context may be a block context.
	 Catch any UnhandledErrors that are created while stepping, answering the relevant signalerContext
	 if so. Note that this will cause weird effects if using through to step through UnhandledError
	 code, but as the doctor ordered, don't do that; use over or into instead."

	^Processor activeProcess
		evaluate:
			[| home anError |
			home := aContext home.
			[suspendedContext := suspendedContext step.
			 home == suspendedContext home or: [home isDead]] whileFalse:
				[(suspendedContext selector == #signalForException:
				 and: [(suspendedContext receiver isBehavior and: [
						suspendedContext receiver includesBehavior: UnhandledError])
				 and: [anError := suspendedContext tempAt: 1.
					   ((suspendedContext objectClass: anError) includesBehavior: Exception)
				 and: [anError canSearchForSignalerContext]]]) ifTrue:
					[anError signalerContext ifNotNil:
						[:unhandledErrorSignalerContext|
						[unhandledErrorSignalerContext == suspendedContext] whileFalse:
							[self completeStep: suspendedContext].
						"Give a debugger a chance to update its title to reflect the new exception"
						 Notification new
							tag: {unhandledErrorSignalerContext. anError};
							signal.
						^unhandledErrorSignalerContext]]].
			suspendedContext]
		onBehalfOf: self
]

{ #category : #'changing suspended state' }
Process >> stepToSendOrReturn [

	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext stepToSendOrReturn]
		onBehalfOf: self
]

{ #category : #'changing process state' }
Process >> suspend [
	"Primitive. Stop the process that the receiver represents in such a way 
	that it can be restarted at a later time (by sending the receiver the 
	message resume). If the receiver represents the activeProcess, suspend it. 
	Otherwise remove the receiver from the list of waiting processes.
	The return value of this method is the list the receiver was previously on (if any)."
	| oldList |
	<primitive: 88>
	"This is fallback code for VMs which only support the old primitiveSuspend which 
	would not accept processes that are waiting to be run."
	myList ifNil:[^nil]. "this allows us to use suspend multiple times"
	oldList := myList.
	myList := nil.
	oldList remove: self ifAbsent:[].
	^oldList
]

{ #category : #accessing }
Process >> suspendedContext [
	"Answer the context the receiver has suspended."

	^suspendedContext
]

{ #category : #private }
Process >> suspendedContext: aContext [

	suspendedContext := aContext
]

{ #category : #accessing }
Process >> suspendingList [
	"Answer the list on which the receiver has been suspended."

	^myList
]

{ #category : #'changing process state' }
Process >> terminate [ 
	"Stop the process that the receiver represents forever.
	 Unwind to execute pending ensure:/ifCurtailed: blocks before terminating.
	 If the process is in the middle of a critical: critical section, release it properly."

	| ctxt unwindBlock oldList |
	self isActiveProcess ifTrue:
		[ctxt := thisContext.
		 [ctxt := ctxt findNextUnwindContextUpTo: nil.
		  ctxt ~~ nil] whileTrue:
			[(ctxt tempAt: 2) ifNil:
				["N.B. Unlike Context>>unwindTo: we do not set complete (tempAt: 2) to true."
				 unwindBlock := ctxt tempAt: 1.
				 thisContext terminateTo: ctxt.
				 unwindBlock value]].
		thisContext terminateTo: nil.
		self suspend.
		"If the process is resumed this will provoke a cannotReturn: error.
		 Would self debug: thisContext title: 'Resuming a terminated process' be better?"
		^self].

	"Always suspend the process first so it doesn't accidentally get woken up.
	 N.B. If oldList is a LinkedList then the process is runnable. If it is a Semaphore/Mutex et al
	 then the process is blocked, and if it is nil then the process is already suspended."
	oldList := self suspend.
	suspendedContext ifNotNil:
		["Release any method marked with the <criticalSection> pragma.
		  The argument is whether the process is runnable."
		 self releaseCriticalSection: (oldList isNil or: [oldList class == LinkedList]).

		"If terminating a process halfways through an unwind, try to complete that unwind block first."
		(suspendedContext findNextUnwindContextUpTo: nil) ifNotNil:
			[:outer|
			 (suspendedContext findContextSuchThat:[:c| c closure == (outer tempAt: 1)]) ifNotNil:
				[:inner| "This is an unwind block currently under evaluation"
				 suspendedContext runUntilErrorOrReturnFrom: inner]].

		ctxt := self popTo: suspendedContext bottomContext.
		ctxt == suspendedContext bottomContext ifFalse:
			[self debug: ctxt title: 'Unwind error during termination'].
		"Set the context to its endPC for the benefit of isTerminated."
		ctxt pc: ctxt endPC]
]
