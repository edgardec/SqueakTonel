Class {
	#name : #WeakRegistryTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Weak'
}

{ #category : #tests }
WeakRegistryTest >> testFinalization [

	| w finalized block object |
	w := WeakRegistry new: 1.
	finalized := false.
	block := [ :v | finalized := v ].
	object := ObjectFinalizer "an object that responds to #finalize"
		receiver: block
		selector: #value:
		argument: true.
	w add: object.
	object := nil. "let it go"
	Smalltalk garbageCollect. "finalize it"

	"This is an odd issue. It seems that in some situations the finalization
	process doesn't run 'in time' for the isEmpty assertion below to succeed.
	This really *shouldn't* happen since isEmpty is full of real sends and
	there ought to be an interrupt check in there somewhere. However,
	since there are no real-time guarantees about finalization, it's fair to
	just wait a little to ensure that the finalization process has been run."
	(Delay forMilliseconds: 100) wait.

	self assert: w isEmpty.
	self assert: finalized
]

{ #category : #tests }
WeakRegistryTest >> testFinalizationWithMultipleFinalizersPerObject [

	| object registry counter |
	registry := WeakRegistry new.
	object := Object new.
	counter := 0.
	5 timesRepeat: [
		registry add: object executor: (ObjectFinalizer
			receiver: [ counter := counter + 1 ]
			selector: #value) ].
	self assert: registry size = 1.
	object := nil. 
	Smalltalk garbageCollect.
	registry finalizeValues.
	self assert: registry isEmpty.
	self assert: counter = 5

]

{ #category : #tests }
WeakRegistryTest >> testGrowingByAHighPriorityProcessDoesntLeak [

	| w finalized block object executor semaphore |
	w := WeakRegistry new: 1.
	finalized := false.
	block := [ :v | finalized := v ].
	object := Object new.
	executor := ObjectFinalizer
		receiver: block
		selector: #value:
		argument: true.
	w add: object executor: executor.
	semaphore := Semaphore new.
	[ 
		object := nil. "let it go"
		w addAll: (1 to: 1000). "force growing"
		semaphore signal ] 
			forkAt: WeakArray runningFinalizationProcess priority + 1.
	semaphore wait.
	Smalltalk garbageCollect. "finalize it"
	self assert: w size = 1000.
	self assert: finalized
]

{ #category : #tests }
WeakRegistryTest >> testGrowingDoesntLeak [

	| w finalized block object executor |
	w := WeakRegistry new: 1.
	finalized := false.
	block := [ :v | finalized := v ].
	object := Object new.
	executor := ObjectFinalizer
		receiver: block
		selector: #value:
		argument: true.
	w add: object executor: executor.
	object := nil. "let it go"
	w addAll: (1 to: 1000). "force growing"
	Smalltalk garbageCollect. "finalize it"
	self assert: w size = 1000.
	self assert: finalized
]

{ #category : #tests }
WeakRegistryTest >> testRemovingByAHighPriorityProcessDoesntLeak [

	| w finalized block hash object executor semaphore |
	w := WeakRegistry new: 1.
	finalized := false.
	block := [ :v | finalized := v ].
	object := Object new.
	executor := ObjectFinalizer
		receiver: block
		selector: #value:
		argument: true.
	hash := object hash.
	w add: hash.
	w add: object executor: executor.
	semaphore := Semaphore new.
	[ 
		object := nil. "let it go"
		w remove: hash.
		semaphore signal ] 
			forkAt: WeakArray runningFinalizationProcess priority + 1.
	semaphore wait.
	Smalltalk garbageCollect. "finalize it"
	self assert: w isEmpty.
	self assert: finalized
]

{ #category : #tests }
WeakRegistryTest >> testRemovingDoesntLeak [

	| w finalized block hash object executor |
	w := WeakRegistry new: 1.
	finalized := false.
	block := [ :v | finalized := v ].
	object := Object new.
	executor := ObjectFinalizer
		receiver: block
		selector: #value:
		argument: true.
	hash := object hash.
	w add: hash.
	w add: object executor: executor.
	object := nil. "let it go"
	w remove: hash.
	Smalltalk garbageCollect. "finalize it"
	self assert: w isEmpty.
	self assert: finalized
]

{ #category : #tests }
WeakRegistryTest >> testVileFinalizer [
	" this test checks that manipulation (or accessing) weak registry 
	does not leads to deadlock, when performed from within #finalize implementation"
	
	| reg villian proc locked |
	
	reg := WeakRegistry new.
	WeakArray removeWeakDependent: reg.  "to prevent test interference with finalization process"
	
	villian := VileFinalizer new initialize: reg.  "add object with vile finalization to registry"
	
	locked := true. "be pessimistic"

	proc := [ reg finalizeValues. locked := false ] newProcess.
	villian := nil.	
	Smalltalk garbageCollect.
	
	proc resume.
	100 milliSeconds asDelay wait. "give chance for created process to run "
	
	proc isTerminated ifFalse: [ proc terminate ].

	self assert: locked == false.

]
