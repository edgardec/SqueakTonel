"
A SemaphoreTest is sunit test for simple and multiEx semaphores

Instance Variables none; does not have common test fixture accross all tests (because its testing differenct sorts of semaphores (could refactor into muliple testcases if there were more test conditions.

"
Class {
	#name : #SemaphoreTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Processes'
}

{ #category : #private }
SemaphoreTest >> criticalError [
	Processor activeProcess terminate
]

{ #category : #tests }
SemaphoreTest >> testCritical [
	| lock |
	lock := Semaphore forMutualExclusion.
	[lock critical: [self criticalError]] forkAt: Processor userInterruptPriority.
	self assert: lock isSignaled
]

{ #category : #tests }
SemaphoreTest >> testCriticalIfError [
	| lock |
	lock := Semaphore forMutualExclusion.
	[lock critical: [self criticalError ifError:[]]] forkAt: Processor userInterruptPriority.
	self assert: lock isSignaled
]

{ #category : #tests }
SemaphoreTest >> testSemaAfterCriticalWait [	"self run: #testSemaAfterCriticalWait"
	"This tests whether a semaphore that has just left the wait in Semaphore>>critical:
	leaves it with signaling the associated semaphore."
	| s p |
	s := Semaphore new.
	p := [s critical:[]] forkAt: Processor activePriority-1.
	"wait until p entered the critical section"
	[p suspendingList == s] whileFalse:[(Delay forMilliseconds: 10) wait].
	"Now that p entered it, signal the semaphore. p now 'owns' the semaphore
	but since we are running at higher priority than p it will not get to do
	anything."
	s signal.
	p terminate.
	self assert: 1 equals: s excessSignals
]

{ #category : #tests }
SemaphoreTest >> testSemaCriticalBlockedInEnsure [	"self run: #testSemaCriticalBlockedInEnsure"
	"This tests whether a semaphore that is in ensure: but has yet to evaluate the valueNoContextSwitch
	leaves it with signaling the associated semaphore."
	| decompilation needSignalToEnterEnsure s p |
	"Distinguish between e.g.
		critical: t1 <criticalSection> ^[self wait. t1 value] ensure: [self signal]
	 and
		critical: t1 <criticalSection> self wait. ^t1 ensure: [self signal]"
	decompilation := (Semaphore>>#critical:) decompileString.
	needSignalToEnterEnsure := (decompilation indexOfSubCollection: #wait) < (decompilation indexOf: $[).
	s := Semaphore new.
	needSignalToEnterEnsure ifTrue: [s signal].
	p := [s critical: []] newProcess.
	p priority: Processor activePriority - 1.
	"step until in critical:"
	[p suspendedContext selector == #critical:] whileFalse: [p step].
	"step until in ensure: (can't do this until in critical: cuz ensure: may be in newProcess etc...)"
	[p suspendedContext selector == #ensure:] whileFalse: [p step].
	"Now check that if we needed a signal to enter ensure: it has been consumed."
	self assert: 0 equals: s excessSignals.
	"Now that p is at the right point, resume the process and immediately terminate it."
	p resume; terminate.
	self assert: (needSignalToEnterEnsure ifTrue: [1] ifFalse: [0]) equals: s excessSignals
]

{ #category : #tests }
SemaphoreTest >> testSemaInCriticalWait [	"self run: #testSemaInCriticalWait"
	"This tests whether a semaphore that has entered the wait in Semaphore>>critical:
	leaves it without signaling the associated semaphore."
	| s p |
	s := Semaphore new.
	p := [s critical:[]] fork.
	Processor yield.
	self assert:(p suspendingList == s).
	p terminate.
	self assert: 0 equals: s excessSignals
]

{ #category : #tests }
SemaphoreTest >> testWaitAndWaitTimeoutTogether [
	| semaphore value waitProcess waitTimeoutProcess |
	semaphore := Semaphore new.
	
	waitProcess := [semaphore wait. value := #wait] fork.

	waitTimeoutProcess := [semaphore waitTimeoutMSecs: 50. value := #waitTimeout] fork.

	"Wait for the timeout to happen"
	(Delay forMilliseconds: 100) wait.

	"The waitTimeoutProcess should already have timed out.  This should release the waitProcess"
	semaphore signal.

	[waitProcess isTerminated and: [waitTimeoutProcess isTerminated]]
		whileFalse: [(Delay forMilliseconds: 100) wait].

	self assert: value = #wait.
	
]

{ #category : #tests }
SemaphoreTest >> testWaitTimeoutMSecs [
	"Ensure that waitTimeoutMSecs behaves properly"

	"Ensure that a timed out waitTimeoutMSecs: returns true from the wait"
	self assert: (Semaphore new waitTimeoutMSecs: 50) == true.

	"Ensure that a signaled waitTimeoutMSecs: returns false from the wait"
	self assert: (Semaphore new signal waitTimeoutMSecs: 50) == false.

]
