"
MutexTest provides SUnit tests for Mutex locks. c.f. SemaphoreTest.
"
Class {
	#name : #MutexTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Processes'
}

{ #category : #private }
MutexTest >> criticalError [
	Processor activeProcess terminate
]

{ #category : #tests }
MutexTest >> testCritical [
	| lock |
	lock := Mutex new.
	[lock critical: [self criticalError]] forkAt: Processor userInterruptPriority.
	self deny: lock isOwned
]

{ #category : #tests }
MutexTest >> testCriticalIfError [
	| lock |
	lock := Mutex new.
	[lock critical: [self criticalError ifError: []]] forkAt: Processor userInterruptPriority.
	self deny: lock isOwned
]

{ #category : #tests }
MutexTest >> testMutexAfterCriticalWait [	"self run: #testMutexAfterCriticalWait"
	"This tests whether a process that has just left the primitiveEnterCriticalSection in Mutex>>critical:
	leaves it with the mutex correctly released."
	| lock p |
	lock := Mutex new.
	p := [lock critical: []] newProcess.
	p priority: Processor activePriority - 1.
	lock critical: "We now own it; p can't enter properly"
		[p resume.
		 "wait until p enters the critical section; it doesn't own the Mutex so is blocked..."
		 [p suspendingList == lock] whileFalse: [(Delay forMilliseconds: 10) wait].
		 self deny: lock isEmpty].
	"p is waiting on lock; on our exiting critical: p is now the notional owner. Terminate before it has a chance to run".
	p terminate.
	self deny: lock isOwned.
	self assert: lock isEmpty
]

{ #category : #tests }
MutexTest >> testMutexCriticalBlockedInEnsure [	"self run: #testMutexCriticalBlockedInEnsure"
	"This tests whether a mutex that is in the ensure: in critical: but has yet to evaluate the valueNoContextSwitch
	leaves it with the mutex unlocked."
	| lock proc |
	lock := Mutex new.
	proc := [lock critical: []] newProcess.
	proc priority: Processor activePriority - 1.
	"step until in critical:"
	[proc suspendedContext selector == #critical:] whileFalse: [proc step].
	"step until in ensure: (can't do this until in critical: cuz ensure: may be in newProcess etc...)"
	[proc suspendedContext selector == #ensure:] whileFalse: [proc step].
	"Now check that the lock is owned."
	self assert: lock isOwned.
	"Now that proc is at the right point, resume the process and immediately terminate it."
	proc resume; terminate.
	self deny: lock isOwned.
	self assert: lock isEmpty
]

{ #category : #tests }
MutexTest >> testMutexInCriticalWait [	"self run: #testMutexInCriticalWait"
	"This tests whether a mutex that has got past the primitiveEnterCriticalSection in Mutex>>critical:
	leaves it unowned."
	| lock sock proc |
	lock := Mutex new.
	sock := Semaphore new.
	proc := [lock critical: [sock wait]] fork.
	Processor yield.
	self assert: proc suspendingList == sock.
	proc terminate.
	self deny: lock isOwned.
	self assert: lock isEmpty
]

{ #category : #tests }
MutexTest >> testTerminationOfLowPriorityProcessDoesNotShutOutHighPriorityProcess [
	| m p s |
	m := Mutex new.
	p := [m critical: [Semaphore new wait]] forkAt: Processor activePriority - 10.
	(Delay forMilliseconds: 100) wait. "Allow p to enter critical section, owning m"
	[m critical: [s := #in]] forkAt: Processor activePriority + 10.
	"r := { p suspendedContext pc. p suspendedContext copyStack }."
	p terminate.
	self deny: m isOwned.
	self assert: s == #in.
	"(m isOwned not and: [s == #in]) ifFalse:
		[Debugger openContext: r last label: 'p' contents: nil]"
]

{ #category : #tests }
MutexTest >> testTerminationOfOneOfTwoLowPriorityProcesses [
	| mutex p1 p2 entered1 entered2 |
	mutex := Mutex new.
	entered1 := entered2 := false.
	p1 := [mutex critical:[entered1 := true]]
			forkAt: Processor activePriority - 1.
	p2 := [mutex critical:[entered2 := true]]
			forkAt: Processor activePriority - 2.
	mutex critical:[(Delay forMilliseconds: 100) wait].
	p1 terminate.
	(Delay forMilliseconds: 100) wait.
	self deny: entered1.
	self assert: entered2
]
