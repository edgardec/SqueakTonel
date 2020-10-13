"
I hold test cases for generic Process-related behaviour.
"
Class {
	#name : #ProcessTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Processes'
}

{ #category : #running }
ProcessTest >> tearDown [
	Processor activeProcess environmentRemoveKey: #processTests ifAbsent: []
]

{ #category : #tests }
ProcessTest >> testAtomicSuspend [
	"Test atomic suspend of foreign processes"

	| list p sema |
	sema := Semaphore new.
	p := [sema wait] fork.
	Processor yield.
	list := p suspendPrimitivelyOrFail.
	self assert: list == sema.

]

{ #category : #tests }
ProcessTest >> testEnvironmentAt [
	Processor activeProcess environmentAt: #processTests put: 42.
	self assert: (Processor activeProcess environmentAt: #processTests) = 42.
	self should: [Processor activeProcess environmentAt: #foobar] raise: Error
]

{ #category : #tests }
ProcessTest >> testEnvironmentAtPut [
	self assert: (Processor activeProcess environmentAt: #processTests put: 42) = 42.
]

{ #category : #tests }
ProcessTest >> testEnvironmentRemoveKey [
	Processor activeProcess environmentAt: #processTests put: 42.
	Processor activeProcess environmentRemoveKey: #processTests.
	self assert: (Processor activeProcess environmentAt: #processTests ifAbsent: []) isNil.
	self should: [Processor activeProcess environmentAt: #processTests] raise: Error
]

{ #category : #tests }
ProcessTest >> testProcessStateTests [
	| semaphore |
	self assert: Processor activeProcess isActiveProcess.
	self deny: Processor activeProcess isBlocked.
	self assert: Processor activeProcess isRunnable.
	self deny: Processor activeProcess isSuspended.
	self deny: Processor activeProcess isTerminated.

	semaphore := Semaphore new.

	"These processes are runnable but haven't got to the wait yet because the active process is running."
	self deny: ([semaphore wait] forkAt: Processor activePriority) isActiveProcess.
	self deny: ([semaphore wait] forkAt: Processor activePriority) isBlocked.
	self assert: ([semaphore wait] forkAt: Processor activePriority) isRunnable.
	self deny: ([semaphore wait] forkAt: Processor activePriority) isSuspended.
	self deny: ([semaphore wait] forkAt: Processor activePriority) isTerminated.
	self deny: ([semaphore wait] forkAt: Processor activePriority) suspendingList == semaphore.

	"These processes do get to run because, being higher priority they preempt the active process until yhey wait on the semaphore."
	self deny: ([semaphore wait] forkAt: Processor activePriority + 1) isActiveProcess.
	self assert: ([semaphore wait] forkAt: Processor activePriority + 1) isBlocked.
	self deny: ([semaphore wait] forkAt: Processor activePriority + 1) isRunnable.
	self deny: ([semaphore wait] forkAt: Processor activePriority + 1) isSuspended.
	self deny: ([semaphore wait] forkAt: Processor activePriority + 1) isTerminated.
	self assert: ([semaphore wait] forkAt: Processor activePriority + 1) suspendingList == semaphore.

	"These processes should be suspended, not terminated."
	self deny: ([Processor activeProcess suspend] forkAt: Processor activePriority + 1) isActiveProcess.
	self deny: ([Processor activeProcess suspend] forkAt: Processor activePriority + 1) isBlocked.
	self deny: ([Processor activeProcess suspend] forkAt: Processor activePriority + 1) isRunnable.
	self assert: ([Processor activeProcess suspend] forkAt: Processor activePriority + 1) isSuspended.
	self deny: ([Processor activeProcess suspend] forkAt: Processor activePriority + 1) isTerminated.
	self assert: ([Processor activeProcess suspend] forkAt: Processor activePriority + 1) suspendingList isNil.

	"These processes should be terminated, not suspended."
	self deny: ([Processor activeProcess terminate] forkAt: Processor activePriority + 1) isActiveProcess.
	self deny: ([Processor activeProcess terminate] forkAt: Processor activePriority + 1) isBlocked.
	self deny: ([Processor activeProcess terminate] forkAt: Processor activePriority + 1) isRunnable.
	self deny: ([Processor activeProcess terminate] forkAt: Processor activePriority + 1) isSuspended.
	self assert: ([Processor activeProcess terminate] forkAt: Processor activePriority + 1) isTerminated.
	self assert: ([Processor activeProcess terminate] forkAt: Processor activePriority + 1) suspendingList isNil.

	"These processes should be suspended."
	self deny: (([semaphore wait] forkAt: Processor activePriority) suspend; yourself) isActiveProcess.
	self deny: (([semaphore wait] forkAt: Processor activePriority) suspend; yourself) isBlocked.
	self deny: (([semaphore wait] forkAt: Processor activePriority) suspend; yourself) isRunnable.
	self assert: (([semaphore wait] forkAt: Processor activePriority) suspend; yourself) isSuspended.
	self deny: (([semaphore wait] forkAt: Processor activePriority) suspend; yourself) isTerminated.

	"These processes should be terminated."
	self deny: ([semaphore wait] forkAt: Processor activePriority) terminate isActiveProcess.
	self deny: ([semaphore wait] forkAt: Processor activePriority) terminate isBlocked.
	self deny: ([semaphore wait] forkAt: Processor activePriority) terminate isRunnable.
	self deny: ([semaphore wait] forkAt: Processor activePriority) terminate isSuspended.
	self assert: ([semaphore wait] forkAt: Processor activePriority) terminate isTerminated
]
