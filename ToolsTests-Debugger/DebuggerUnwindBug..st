Class {
	#name : #DebuggerUnwindBug,
	#superclass : #TestCase,
	#category : #'ToolsTests-Debugger'
}

{ #category : #tests }
DebuggerUnwindBug >> testUnwindBlock [
	"test if unwind blocks work properly"
	| sema process |
	sema := Semaphore forMutualExclusion.
	self assert: sema isSignaled.
	"deadlock on the semaphore"
	process := [sema critical:[sema wait]] forkAt: Processor userInterruptPriority.
	self deny: sema isSignaled.
	"terminate process"
	process terminate.
	self assert: sema isSignaled.

]

{ #category : #tests }
DebuggerUnwindBug >> testUnwindDebugger [
	"test if unwind blocks work properly when a debugger is closed"
	| sema process debugger top |
	sema := Semaphore forMutualExclusion.
	self assert: sema isSignaled.
	process := [sema critical:[sema wait]] forkAt: Processor userInterruptPriority.
	self deny: sema isSignaled.

	"everything set up here - open a debug notifier"
	debugger := process debugWithTitle: 'test' full: false.
	"get into the debugger"
	debugger debug.
	top := debugger topView.
	"set top context"
	debugger toggleContextStackIndex: 1.
	"close debugger"
	top delete.

	"and see if unwind protection worked"
	self assert: sema isSignaled.
]
