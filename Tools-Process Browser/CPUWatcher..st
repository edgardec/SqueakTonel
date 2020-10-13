"
CPUWatcher implements a simple runaway process monitoring tool
that will suspend a process that is taking up too much of Squeak's
time and allow user interaction. By default it watches for a Process that
is taking more than 80% of the time; this threshold can be changed.

CPUWatcher can also be used to show cpu percentages for each process 
from within the ProcessBrowser.

	CPUWatcher startMonitoring.	""process period 20 seconds, sample rate 100 msec""
	CPUWatcher current monitorProcessPeriod: 10 sampleRate: 20.
	CPUWatcher current threshold: 0.5.	""change from 80% to 50%""
	CPUWatcher stopMonitoring.

"
Class {
	#name : #CPUWatcher,
	#superclass : #Model,
	#instVars : [
		'tally',
		'watcher',
		'threshold'
	],
	#classVars : [
		'CpuWatcherEnabled',
		'CurrentCPUWatcher'
	],
	#category : #'Tools-Process Browser'
}

{ #category : #preferences }
CPUWatcher class >> cpuWatcherEnabled [
	<preference: 'CPU Watcher enabled' category: #('debug' 'performance') description: 'If true, Squeak will monitor processes for CPU usage. If any uses too much CPU, you will get a notification menu that will allow you to debug, resume or terminate the process.' type: #Boolean>
	^ CpuWatcherEnabled ifNil: [false].
]

{ #category : #preferences }
CPUWatcher class >> cpuWatcherEnabled: aBoolean [
	CpuWatcherEnabled := aBoolean.
	self monitorPreferenceChanged.
]

{ #category : #singleton }
CPUWatcher class >> current [
	^CurrentCPUWatcher

]

{ #category : #accessing }
CPUWatcher class >> currentWatcherProcess [
	^CurrentCPUWatcher ifNotNil: [ CurrentCPUWatcher watcherProcess ]

]

{ #category : #monitoring }
CPUWatcher class >> dumpTallyOnTranscript [
	self current ifNotNil: [
		ProcessBrowser dumpTallyOnTranscript: self current tally
	]
]

{ #category : #'class initialization' }
CPUWatcher class >> initialize [
	"CPUWatcher initialize"
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self.
]

{ #category : #monitoring }
CPUWatcher class >> isMonitoring [

	^CurrentCPUWatcher notNil and: [ CurrentCPUWatcher isMonitoring ]

]

{ #category : #preferences }
CPUWatcher class >> monitorPreferenceChanged [
	self cpuWatcherEnabled
		ifTrue: [ self startMonitoring ]
		ifFalse: [ self stopMonitoring ]
]

{ #category : #'system startup' }
CPUWatcher class >> shutDown [
	self stopMonitoring.
]

{ #category : #monitoring }
CPUWatcher class >> startMonitoring [
	"CPUWatcher startMonitoring"

	^self startMonitoringPeriod: 20 rate: 100 threshold: 0.8
]

{ #category : #monitoring }
CPUWatcher class >> startMonitoringPeriod: pd rate: rt threshold: th [
	"CPUWatcher startMonitoring"

	CurrentCPUWatcher ifNotNil: [ ^CurrentCPUWatcher startMonitoring. ].
	CurrentCPUWatcher := (self new)
		monitorProcessPeriod: pd sampleRate: rt;
		threshold: th;
		yourself.
	^CurrentCPUWatcher

]

{ #category : #'system startup' }
CPUWatcher class >> startUp [
	self monitorPreferenceChanged.
]

{ #category : #monitoring }
CPUWatcher class >> stopMonitoring [
	"CPUWatcher stopMonitoring"

	CurrentCPUWatcher ifNotNil: [ CurrentCPUWatcher stopMonitoring. ].
	CurrentCPUWatcher := nil.

]

{ #category : #'porcine capture' }
CPUWatcher >> catchThePig: aProcess [
	| rules |
	"nickname, allow-stop, allow-debug"
	rules := ProcessBrowser nameAndRulesFor: aProcess.

	(ProcessBrowser isUIProcess: aProcess)
		ifTrue: [ "aProcess debugWithTitle: 'Interrupted from the CPUWatcher'." ]
		ifFalse: [ rules second ifFalse: [ ^self ].
				ProcessBrowser suspendProcess: aProcess.
				self openWindowForSuspendedProcess: aProcess ]

]

{ #category : #'process operations' }
CPUWatcher >> debugProcess: aProcess [
	| uiPriority oldPriority |
	uiPriority := Processor activeProcess priority.
	aProcess priority >= uiPriority ifTrue: [
		oldPriority := ProcessBrowser setProcess: aProcess toPriority: uiPriority - 1
	].
	ProcessBrowser debugProcess: aProcess.
]

{ #category : #'process operations' }
CPUWatcher >> debugProcess: aProcess fromMenu: aMenuMorph [
	aMenuMorph delete.
	self debugProcess: aProcess.
]

{ #category : #'porcine capture' }
CPUWatcher >> findThePig [
	"tally has been updated. Look at it to see if there is a bad process.
	This runs at a very high priority, so make it fast"
	| countAndProcess | 
	countAndProcess := tally sortedCounts first.
	(countAndProcess key / tally size > self threshold) ifTrue: [ | proc |
		proc := countAndProcess value.
		proc == Processor backgroundProcess ifTrue: [ ^self ].	"idle process? OK"
		self catchThePig: proc
	].

]

{ #category : #accessing }
CPUWatcher >> isMonitoring [
	^watcher notNil
]

{ #category : #'startup-shutdown' }
CPUWatcher >> monitorProcessPeriod: secs sampleRate: msecs [
	self stopMonitoring.

	watcher := [ [ | promise |
		promise := Processor tallyCPUUsageFor: secs every: msecs.
		tally := promise value.
		promise := nil.
		self findThePig.
	] repeat ] forkAt: Processor highestPriority.
	Processor yield 
]

{ #category : #'porcine capture' }
CPUWatcher >> openMVCWindowForSuspendedProcess: aProcess [
	ProcessBrowser open
]

{ #category : #'porcine capture' }
CPUWatcher >> openMorphicWindowForSuspendedProcess: aProcess [
	| menu rules |
	menu := MenuMorph new.
	"nickname  allow-stop  allow-debug"
	rules := ProcessBrowser nameAndRulesFor: aProcess.
	menu add: 'Dismiss this menu' target: menu selector: #delete; addLine.
	menu add: 'Open Process Browser' target: ProcessBrowser selector: #open.
	menu add: 'Resume'
		target: self
		selector: #resumeProcess:fromMenu:
		argumentList: { aProcess . menu }.
	menu add: 'Terminate'
		target: self
		selector: #terminateProcess:fromMenu:
		argumentList: { aProcess . menu }.
	rules third ifTrue: [
		menu add: 'Debug at a lower priority'
			target: self
			selector: #debugProcess:fromMenu:
			argumentList: { aProcess . menu }.
	].
	menu addTitle: aProcess identityHash asString,
		' ', rules first,
		' is taking too much time and has been suspended.
What do you want to do with it?'.
	menu stayUp: true.
	menu popUpInWorld

]

{ #category : #'porcine capture' }
CPUWatcher >> openWindowForSuspendedProcess: aProcess [

	Smalltalk isMorphic
		ifTrue: [ WorldState addDeferredUIMessage: [ self openMorphicWindowForSuspendedProcess: aProcess ] ]
		ifFalse: [ [ self openMVCWindowForSuspendedProcess: aProcess ] forkAt: Processor userSchedulingPriority ]

]

{ #category : #'process operations' }
CPUWatcher >> resumeProcess: aProcess fromMenu: aMenuMorph [
	aMenuMorph delete.
	ProcessBrowser resumeProcess: aProcess.
]

{ #category : #'startup-shutdown' }
CPUWatcher >> startMonitoring [
	self
		monitorProcessPeriod: 20 sampleRate: 100
]

{ #category : #'startup-shutdown' }
CPUWatcher >> stopMonitoring [
	watcher ifNotNil: [
		ProcessBrowser terminateProcess: watcher.
		watcher := nil.
	]
]

{ #category : #accessing }
CPUWatcher >> tally [
	^tally copy
]

{ #category : #'process operations' }
CPUWatcher >> terminateProcess: aProcess fromMenu: aMenuMorph [
	aMenuMorph delete.
	ProcessBrowser terminateProcess: aProcess.
]

{ #category : #accessing }
CPUWatcher >> threshold [
	"What fraction of the time can a process be the active process before we stop it?"
	^threshold
]

{ #category : #accessing }
CPUWatcher >> threshold: thresh [
	"What fraction of the time can a process be the active process before we stop it?"
	threshold := (thresh max: 0.02) min: 1.0
]

{ #category : #accessing }
CPUWatcher >> watcherProcess [
	^watcher
]
