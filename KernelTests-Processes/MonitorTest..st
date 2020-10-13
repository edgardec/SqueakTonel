Class {
	#name : #MonitorTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Processes'
}

{ #category : #tests }
MonitorTest >> testCheckOwnerProcess [
	self should: [Monitor new checkOwnerProcess]
		raise: Error.

	self shouldnt: [| m | m := Monitor new. m critical: [m checkOwnerProcess]]
		raise: Error.

	self should: [| s m |
				m := Monitor new.
				[m critical: [s := #in. Semaphore new wait]] fork.
				Processor yield.
				self assert: #in equals: s.
				m checkOwnerProcess]
		raise: Error
]

{ #category : #tests }
MonitorTest >> testCriticalIfLocked [
	| m s |
	m := Monitor new.
	self assert: #unlocked == (m critical: [#unlocked] ifLocked: [#locked]).
	[m critical: [s := #in. Semaphore new wait]] fork.
	Processor yield.
	self assert: #in equals: s.
	self assert: #locked equals: (m critical: [#unlocked] ifLocked: [#locked])
]

{ #category : #tests }
MonitorTest >> testExample1 [

	| producer1 producer2  monitor goal work counter goalReached finished |
	goal := (1 to: 1000) asOrderedCollection.
	work := OrderedCollection new.
	counter := 0.
	goalReached := false.
	finished := Semaphore new.
	monitor := Monitor new.

	producer1 := [
       [monitor critical:
             [monitor waitUntil: [counter \\5 = 0].
              goalReached or: [work add: (counter := counter + 1)].
              goalReached := counter >= goal size.
              monitor signal
            ].
           goalReached
          ]
             whileFalse.
         finished signal.
	].

	producer2 := [
         [monitor critical:
                [monitor waitWhile: [counter \\5 = 0].
                 goalReached or: [work add: (counter := counter + 1)].
                 goalReached := counter >= goal size.
                 monitor signal].
         goalReached
       ] whileFalse.
     finished signal
	].

	producer1 forkAt: Processor userBackgroundPriority.
	producer2 forkAt: Processor userBackgroundPriority.

	finished wait; wait.
	self assert: goal = work
]

{ #category : #tests }
MonitorTest >> testExample2 [
	"Here is a second version that does not use a semaphore to inform the 
	forking process about termination of both forked processes"

	| producer1 producer2  monitor goal work counter goalReached activeProducers|
	goal := (1 to: 1000) asOrderedCollection.
	work := OrderedCollection new.
	counter := 0.
	goalReached := false.
	activeProducers := 0.
	monitor := Monitor new.

  producer1 :=
      [ monitor critical: [activeProducers := activeProducers + 1].
  [monitor critical:
            [monitor waitUntil: [counter \\5 = 0].
      goalReached or: [work add: (counter := counter + 1)].
     " Transcript show: 'P1  '; show: counter printString; show: '  ';
       show: activeProducers printString; cr."
      goalReached := counter >= goal size.
      monitor signal
            ].
           goalReached
          ]
             whileFalse.
         monitor critical: [activeProducers := activeProducers - 1.
        monitor signal: #finish].
 ] .

 producer2 :=
    [monitor critical: [activeProducers := activeProducers + 1].

  [monitor critical:
          [monitor waitWhile: [counter \\5 = 0].
    goalReached or: [work add: (counter := counter + 1)].
    goalReached := counter >= goal size.
    monitor signal].
         goalReached ] whileFalse.
     monitor critical: [
		activeProducers := activeProducers - 1. 
		monitor signal: #finish].
	].

	producer1 forkAt: Processor userBackgroundPriority.
	producer2  forkAt: Processor userBackgroundPriority.


	monitor critical: [
		monitor waitUntil: [activeProducers = 0 & (goalReached)]
				for: #finish.
  	].

	self assert: goal = work

]
