"
Change Set:		ProcessBrowser
Date:			14 March 2000
Author:			Ned Konz

email: ned@bike-nomad.com

This is distributed under the Squeak License.

Added 14 March:
	CPUWatcher integration
	automatically start and stop CPUWatcher
	added CPUWatcher to process list menu

Added 29 October:
	MVC version
	2.8, 2.7 compatibility
	rearranged menus
	added pointer inspection and chasing
	added suspend/resume
	recognized more well-known processes
	misc. bug fixes

Added 26 October: highlight pc in source code
Added 27 October: added 'signal semaphore'
added 'inspect receiver', 'explore receiver', 'message tally' to stack list menu
added 'find context', 'next context' to process list menu
added 'change priority' and 'debug' choices to process list menu

27 October mods by Bob Arning:

alters process display in Ned's ProcessBrowser to 
- show process priority
- drop 'a Process in' that appears on each line
- show in priority order
- prettier names for known processes
- fix to Utilities to forget update downloading process when it ends (1 less dead
process)
- correct stack dump for the active process

"
Class {
	#name : #ProcessBrowser,
	#superclass : #Model,
	#instVars : [
		'selectedProcess',
		'selectedContext',
		'methodText',
		'processList',
		'processListIndex',
		'stackList',
		'stackListIndex',
		'sourceMap',
		'selectedClass',
		'selectedSelector',
		'searchString',
		'autoUpdateProcess',
		'lastUpdate',
		'startedCPUWatcher'
	],
	#classVars : [
		'Browsers',
		'SuspendedProcesses',
		'WellKnownProcesses'
	],
	#category : #'Tools-Process Browser'
}

{ #category : #'class initialization' }
ProcessBrowser class >> cleanUp [
"Remove terminated processes from my suspended list"

	self suspendedProcesses keys do: [:ea |
		ea isTerminated ifTrue: [self suspendedProcesses removeKey: ea]]
]

{ #category : #'process control' }
ProcessBrowser class >> debugProcess: aProcess [
	aProcess debugWithTitle: 'Interrupted from the Process Browser'.

]

{ #category : #'CPU utilization' }
ProcessBrowser class >> dumpTallyOnTranscript: tally [
	"tally is from ProcessorScheduler>>tallyCPUUsageFor:
	Dumps lines with percentage of time, hash of process, and a friendly name"

	tally sortedCounts do: [ :assoc | | procName |
		procName := (self nameAndRulesFor: assoc value) first.
		Transcript print: (((assoc key / tally size) * 100.0) roundTo: 1);
			nextPutAll: '%   ';
			print: assoc value identityHash; space;
			nextPutAll: procName;
			cr.
	].
	Transcript flush.
]

{ #category : #'class initialization' }
ProcessBrowser class >> initialize [
	"ProcessBrowser initialize"
	Browsers ifNil: [ Browsers := WeakSet new ].
	SuspendedProcesses ifNil: [ SuspendedProcesses := IdentityDictionary new ].
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self.
	self registerInFlapsRegistry.
	self registerWellKnownProcesses
]

{ #category : #'process control' }
ProcessBrowser class >> isUIProcess: aProcess [
	^aProcess == Project uiProcess

]

{ #category : #'process control' }
ProcessBrowser class >> nameAndRulesFor: aProcess [ 
	"Answer a nickname and two flags: allow-stop, and allow-debug"
	^ [aProcess caseOf: WellKnownProcesses
		 otherwise: 
			[(aProcess priority = Processor timingPriority
					and: [aProcess suspendedContext receiver == Delay])
				ifTrue: [{'the timer interrupt watcher'. false. false}]
				ifFalse: [{aProcess suspendedContext asString. true. true}]]]
		ifError: [:err :rcvr | {aProcess suspendedContext asString. true. true}]
]

{ #category : #'instance creation' }
ProcessBrowser class >> open [
	^ToolBuilder open: self new
]

{ #category : #recompilation }
ProcessBrowser class >> postRecompileAction [
	"Reinitialize the standard WellKnownProcesses.  Each registration includes a couple of
	 block references that need to be freshened post recompile."

	WellKnownProcesses ifNotNil:
		[:oldWKP|
		 self registerWellKnownProcesses.
		 "Attempt to preserve any user additions..."
		 WellKnownProcesses addAllLast: (oldWKP allButFirst: WellKnownProcesses size)]
]

{ #category : #'instance creation' }
ProcessBrowser class >> prototypicalToolWindow [
	"Answer a window representing a prototypical instance of the receiver"

	^ ToolBuilder build: self new
]

{ #category : #'class initialization' }
ProcessBrowser class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | 	cl registerQuad: {#ProcessBrowser. #prototypicalToolWindow.	'Processes' translatedNoop.			'A Process Browser shows you all the running processes' translatedNoop}
						forFlapNamed: 'Tools'.]
]

{ #category : #'process control' }
ProcessBrowser class >> registerWellKnownProcess: aBlockForProcess label: nickname allowStop: allowStop allowDebug: allowDebug [
	"Add an entry to the registry of well known processes. aBlockForProcess
	evaluates to a known process to be identified by nickname, and allowStop
	and allowDebug are flags controlling allowable actions for this process
	in the browser."

	WellKnownProcesses add: aBlockForProcess->[{nickname . allowStop . allowDebug}]
]

{ #category : #'class initialization' }
ProcessBrowser class >> registerWellKnownProcesses [
	"Associate each well-known process with a nickname and two flags: allow-stop, and allow-debug.
	Additional processes may be added to this list as required"

	WellKnownProcesses := OrderedCollection new.
	self registerWellKnownProcess: []
		label: 'no process'
		allowStop: false
		allowDebug: false.
	self registerWellKnownProcess: [Smalltalk lowSpaceWatcherProcess]
		label: 'the low space watcher'
		allowStop: false
		allowDebug: false.
	self registerWellKnownProcess: [WeakArray runningFinalizationProcess]
		label: 'the WeakArray finalization process'
		allowStop: false
		allowDebug: false.
	self registerWellKnownProcess: [Processor activeProcess]
		label: 'the UI process'
		allowStop: false
		allowDebug: true.
	self registerWellKnownProcess: [Processor backgroundProcess]
		label: 'the idle process'
		allowStop: false
		allowDebug: false.
	self registerWellKnownProcess: [Sensor interruptWatcherProcess]
		label: 'the user interrupt watcher'
		allowStop: false
		allowDebug: false.
	self registerWellKnownProcess: [Sensor eventTicklerProcess]
		label: 'the event tickler'
		allowStop: false
		allowDebug: false.
	self registerWellKnownProcess: [Project uiProcess]
		label: 'the inactive Morphic UI process'
		allowStop: false
		allowDebug: false.
"	self registerWellKnownProcess:
			[Smalltalk at: #SoundPlayer ifPresent: [:sp | sp playerProcess]]
		label: 'the Sound Player'
		allowStop: false
		allowDebug: false."
	self registerWellKnownProcess:
			[ScheduledControllers ifNotNil: [ScheduledControllers activeControllerProcess]]
		label: 'the inactive MVC controller process'
		allowStop: false
		allowDebug: true.
	self registerWellKnownProcess:
			[Smalltalk at: #CPUWatcher ifPresent: [:cw | cw currentWatcherProcess]]
		label: 'the CPUWatcher'
		allowStop: false
		allowDebug: false

]

{ #category : #'process control' }
ProcessBrowser class >> resumeProcess: aProcess [
	| priority |
	priority := self suspendedProcesses
				removeKey: aProcess
				ifAbsent: [aProcess priority].
	aProcess priority: priority.
	aProcess suspendedContext ifNotNil: [ aProcess resume ]

]

{ #category : #'process control' }
ProcessBrowser class >> setProcess: aProcess toPriority: priority [
	| oldPriority |
	oldPriority := self suspendedProcesses at: aProcess ifAbsent: [ ].
	oldPriority ifNotNil: [ self suspendedProcesses at: aProcess put: priority ].
	aProcess priority: priority.
	^oldPriority
]

{ #category : #'system startup' }
ProcessBrowser class >> shutDown [
	Browsers do: [ :ea | ea isAutoUpdating ifTrue: [ ea pauseAutoUpdate ]]
]

{ #category : #'system startup' }
ProcessBrowser class >> startUp [
	Browsers
		do: [:ea | ea isAutoUpdatingPaused
				ifTrue: [ea initialize; startAutoUpdate]
				ifFalse: [ea initialize]]
]

{ #category : #'process control' }
ProcessBrowser class >> suspendProcess: aProcess [
	| priority |
	priority := aProcess priority.
	self suspendedProcesses at: aProcess put: priority.
	"Need to take the priority down below the caller's
	so that it can keep control after signaling the Semaphore"
	(aProcess suspendingList isKindOf: Semaphore)
		ifTrue: [aProcess priority: Processor lowestPriority.
			aProcess suspendingList signal].
	[aProcess suspend]
		on: Error
		do: [:ex | self suspendedProcesses removeKey: aProcess].
	aProcess priority: priority.

]

{ #category : #'process control' }
ProcessBrowser class >> suspendedProcesses [
	"Answer a collection of processes that my instances have suspended.  
	This is so that they don't get garbage collected."
	^ SuspendedProcesses
		ifNil: [SuspendedProcesses := IdentityDictionary new]
]

{ #category : #'CPU utilization' }
ProcessBrowser class >> tallyCPUUsageFor: seconds [
	"Compute CPU usage using a 10-msec sample for the given number of seconds,
	then dump the usage statistics on the Transcript. The UI is free to continue, meanwhile"
	"ProcessBrowser tallyCPUUsageFor: 10"
	^self tallyCPUUsageFor: seconds every: 10
]

{ #category : #'CPU utilization' }
ProcessBrowser class >> tallyCPUUsageFor: seconds every: msec [
	"Compute CPU usage using a msec millisecond sample for the given number of seconds,
	then dump the usage statistics on the Transcript. The UI is free to continue, meanwhile"
	"ProcessBrowser tallyCPUUsageFor: 10 every: 100"

	| promise |
	promise := Processor tallyCPUUsageFor: seconds every: msec.

	[ | tally |
		tally := promise value.
		Smalltalk isMorphic
			ifTrue: [ Project current addDeferredUIMessage: [ self dumpTallyOnTranscript: tally ] ]
			ifFalse: [ [ Transcript open ] forkAt: Processor userSchedulingPriority.
					[ (Delay forSeconds: 1) wait.
					self dumpTallyOnTranscript: tally ] forkAt: Processor userSchedulingPriority.]
	] fork.
]

{ #category : #'process control' }
ProcessBrowser class >> terminateProcess: aProcess [
	aProcess ifNotNil: [
		self suspendedProcesses
			removeKey: aProcess
			ifAbsent: [].
		aProcess terminate
	].

]

{ #category : #'class initialization' }
ProcessBrowser class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'process control' }
ProcessBrowser class >> unregisterWellKnownProcess: aProcess [
	"Remove the first registry entry that matches aProcess. Use
	with caution if more than one registry entry may match aProcess."

	"self unregisterWellKnownProcess: Smalltalk lowSpaceWatcherProcess"

	| entry |
	entry := WellKnownProcesses
		detect: [:e | e key value == aProcess]
		ifNone: [^ self].
	WellKnownProcesses remove: entry
]

{ #category : #'process control' }
ProcessBrowser class >> wasProcessSuspendedByProcessBrowser: aProcess [
	^self suspendedProcesses includesKey: aProcess
]

{ #category : #'stack list' }
ProcessBrowser >> browseContext [
	ToolSet browseMethod: selectedContext home method
]

{ #category : #toolbuilder }
ProcessBrowser >> buildWith: builder [
	"Create a pluggable version of me, answer a window"
	| windowSpec listSpec textSpec |
	windowSpec := builder pluggableWindowSpec new.
	windowSpec model: self.
	windowSpec label: 'Process Browser'.
	windowSpec children: OrderedCollection new.

	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #processNameList; 
		getIndex: #processListIndex; 
		setIndex: #processListIndex:; 
		menu: #processListMenu:; 
		keyPress: #processListKey:from:;
		frame: (0 @ 0 extent: 0.5 @ 0.5).
	windowSpec children add: listSpec.

	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #stackNameList; 
		getIndex: #stackListIndex; 
		setIndex: #stackListIndex:; 
		menu: #stackListMenu:; 
		keyPress: #stackListKey:from:;
		frame: (0.5 @ 0.0 extent: 0.5 @ 0.5).
	windowSpec children add: listSpec.

	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #selectedMethod; 
		setText: nil; 
		selection: nil; 
		menu: nil;
		frame: (0 @ 0.5 corner: 1 @ 1).
	windowSpec children add: textSpec.

	^builder build: windowSpec
]

{ #category : #'process actions' }
ProcessBrowser >> changePriority [
	| str newPriority nameAndRules |
	nameAndRules := self nameAndRulesForSelectedProcess.
	nameAndRules third
		ifFalse: [self inform: 'Nope, won''t change priority of ' , nameAndRules first.
			^ self].
	str := UIManager default 
				request: 'New priority' 
		  initialAnswer: selectedProcess priority asString.
	newPriority := str asNumber asInteger.
	newPriority
		ifNil: [^ self].
	(newPriority < 1
			or: [newPriority > Processor highestPriority])
		ifTrue: [self inform: 'Bad priority'.
			^ self].
	self class setProcess: selectedProcess toPriority: newPriority.
	self updateProcessList
]

{ #category : #'stack list' }
ProcessBrowser >> changeStackListTo: aCollection [ 

        stackList := aCollection.
        self changed: #stackNameList.
        self stackListIndex: 0
]

{ #category : #'process actions' }
ProcessBrowser >> chasePointers [
	| saved |
	saved := selectedProcess.
	[selectedProcess := nil.
	(Smalltalk includesKey: #PointerFinder)
		ifTrue: [PointerFinder on: saved]
		ifFalse: [self inspectPointers]]
		ensure: [selectedProcess := saved]
]

{ #category : #'process actions' }
ProcessBrowser >> debugProcess [
	| nameAndRules |
	nameAndRules := self nameAndRulesForSelectedProcess.
	nameAndRules third
		ifFalse: [self inform: 'Nope, won''t debug ' , nameAndRules first.
			^ self].
	self class debugProcess: selectedProcess.
]

{ #category : #'stack list' }
ProcessBrowser >> exploreContext [
	selectedContext explore
]

{ #category : #'process list' }
ProcessBrowser >> exploreProcess [
	selectedProcess explore
]

{ #category : #'stack list' }
ProcessBrowser >> exploreReceiver [
	selectedContext receiver explore
]

{ #category : #'process list' }
ProcessBrowser >> findContext [
	| initialProcessIndex initialStackIndex found |
	initialProcessIndex := self processListIndex.
	initialStackIndex := self stackListIndex.
	searchString := UIManager default 
			request: 'Enter a string to search for in the process stack lists'
	  initialAnswer: searchString.
	searchString isEmpty
		ifTrue: [^ false].
	self processListIndex: 1.
	self stackListIndex: 1.
	found := self nextContext.
	found
		ifFalse: [self processListIndex: initialProcessIndex.
			self stackListIndex: initialStackIndex].
	^ found
]

{ #category : #views }
ProcessBrowser >> hasView [
	^self dependents isEmptyOrNil not
]

{ #category : #'initialize-release' }
ProcessBrowser >> initialize [
	methodText := ''.
	stackListIndex := 0.
	searchString := ''.
	lastUpdate := 0.
	startedCPUWatcher := CPUWatcher cpuWatcherEnabled and: [ self startCPUWatcher ].
	self updateProcessList; processListIndex: 1.
	Browsers add: self
]

{ #category : #'stack list' }
ProcessBrowser >> inspectContext [
	selectedContext inspect
]

{ #category : #'process actions' }
ProcessBrowser >> inspectPointers [
	| tc pointers |
	tc := thisContext.
	pointers := PointerFinder
		pointersTo: selectedProcess
		except: { 
			self processList.
			tc.
			self}.
	pointers isEmpty ifTrue: [^ self].
	ToolSet 
		inspect: pointers
		label: 'Objects pointing to ' , selectedProcess browserPrintString
]

{ #category : #'process list' }
ProcessBrowser >> inspectProcess [
	selectedProcess inspect
]

{ #category : #'stack list' }
ProcessBrowser >> inspectReceiver [
	selectedContext receiver inspect
]

{ #category : #updating }
ProcessBrowser >> isAutoUpdating [
	^autoUpdateProcess notNil and: [ autoUpdateProcess isSuspended  not ]
]

{ #category : #updating }
ProcessBrowser >> isAutoUpdatingPaused [
	^autoUpdateProcess notNil and: [ autoUpdateProcess isSuspended ]
]

{ #category : #'stack list' }
ProcessBrowser >> messageTally [
	| secString secs |
	secString := UIManager default request: 'Profile for how many seconds?' initialAnswer: '4'.
	secString isEmptyOrNil ifTrue: [^ self].
	secs := secString asNumber asInteger.
	(secs isNil or: [secs isZero])
		ifTrue: [^ self].
	[ TimeProfileBrowser spyOnProcess: selectedProcess forMilliseconds: secs * 1000 ] forkAt: selectedProcess priority + 1.
]

{ #category : #'stack list' }
ProcessBrowser >> moreStack [
	self updateStackList: 2000
]

{ #category : #'process actions' }
ProcessBrowser >> nameAndRulesFor: aProcess [ 
	"Answer a nickname and two flags: allow-stop, and allow-debug"
	aProcess == autoUpdateProcess ifTrue: [ ^{'my auto-update process'. true. true} ].
	^self class nameAndRulesFor: aProcess 

]

{ #category : #'process actions' }
ProcessBrowser >> nameAndRulesForSelectedProcess [
	"Answer a nickname and two flags: allow-stop, and allow-debug"
	^self nameAndRulesFor: selectedProcess
]

{ #category : #'process list' }
ProcessBrowser >> nextContext [
	| initialProcessIndex initialStackIndex |
	searchString isEmpty ifTrue: [ ^false ].
	initialProcessIndex := self processListIndex.
	initialStackIndex := self stackListIndex.
	initialProcessIndex
		to: self processList size
		do: [:pi | self processListIndex: pi.
					self stackNameList
						withIndexDo: [:name :si | (pi ~= initialProcessIndex
											or: [si > initialStackIndex])
								ifTrue: [(name includesSubstring: searchString)
										ifTrue: [self stackListIndex: si.
											^true]]]].
	self processListIndex: initialProcessIndex.
	self stackListIndex: initialStackIndex.
	^ false
]

{ #category : #'process list' }
ProcessBrowser >> notify: errorString at: location in: aStream [ 
	"A syntax error happened when I was trying to highlight my pc. 
	Raise a signal so that it can be ignored."
	Warning signal: 'syntax error'
]

{ #category : #updating }
ProcessBrowser >> pauseAutoUpdate [
	self isAutoUpdating
		ifTrue: [ autoUpdateProcess suspend ].
	self updateProcessList
]

{ #category : #'stack list' }
ProcessBrowser >> pcRange [
	"Answer the indices in the source code for the method corresponding to  
	the selected context's program counter value."
	(selectedContext isNil or: [methodText isEmptyOrNil]) ifTrue:
		[^ 1 to: 0].
	^selectedContext debuggerMap
		rangeForPC: (selectedContext pc ifNil: [selectedContext method endPC])
		in: selectedContext method
		contextIsActiveContext: stackListIndex = 1
]

{ #category : #'message handling' }
ProcessBrowser >> perform: selector orSendTo: otherTarget [ 
	"Selector was just chosen from a menu by a user. If can respond, then  
	perform it on myself. If not, send it to otherTarget, presumably the  
	editPane from which the menu was invoked."
	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ super perform: selector orSendTo: otherTarget]
]

{ #category : #'process list' }
ProcessBrowser >> prettyNameForProcess: aProcess [ 
	| nameAndRules |
	aProcess ifNil: [ ^'<nil>' ].
	nameAndRules := self nameAndRulesFor: aProcess.
	^ aProcess browserPrintStringWith: nameAndRules first
]

{ #category : #accessing }
ProcessBrowser >> processList [
	^ processList
]

{ #category : #accessing }
ProcessBrowser >> processListIndex [
	^ processListIndex
]

{ #category : #accessing }
ProcessBrowser >> processListIndex: index [ 
	processListIndex := index.
	selectedProcess := processList
				at: index
				ifAbsent: [].
	self updateStackList.
	self changed: #processListIndex.
]

{ #category : #'process list' }
ProcessBrowser >> processListKey: aKey from: aView [

	aKey
		caseOf: {
			[$f] ->		[^ self findContext].
			[$g] ->	[^ self nextContext].
			[$a] ->	[^ self toggleAutoUpdate].
			[$u] ->	[^ self updateProcessList] }
		otherwise: [].
	selectedProcess ifNil: [^ self changed: #flash].
	^ aKey
		caseOf: {
			[$i] ->		[self inspectProcess].
			[$I] ->		[self exploreProcess].
			[$c] ->	[self chasePointers].
			[$P] ->	[self inspectPointers].
			[$t] ->		[self terminateProcess].
			[$r] ->		[self resumeProcess].
			[$s] ->		[self suspendProcess].
			[$d] ->	[self debugProcess].
			[$p] ->	[self changePriority].
			[$m] ->	[self messageTally].
			[$S] ->	[self signalSemaphore].
			[$k] ->	[self moreStack]}
		otherwise: [self arrowKey: aKey from: aView]
]

{ #category : #'process list' }
ProcessBrowser >> processListMenu: menu [ 
	| pw |

	selectedProcess
		ifNotNil: [| nameAndRules | 
			nameAndRules := self nameAndRulesForSelectedProcess.
			menu addList: {{'inspect (i)'. #inspectProcess}. {'explore (I)'. #exploreProcess}. {'inspect Pointers (P)'. #inspectPointers}}.
	(Smalltalk includesKey: #PointerFinder)
		ifTrue: [ menu add: 'chase pointers (c)' action: #chasePointers.  ].
			nameAndRules second
				ifTrue: [menu add: 'terminate (t)' action: #terminateProcess.
					selectedProcess isSuspended
						ifTrue: [menu add: 'resume (r)' action: #resumeProcess]
						ifFalse: [menu add: 'suspend (s)' action: #suspendProcess]].
			nameAndRules third
				ifTrue: [menu addList: {{'change priority (p)'. #changePriority}. {'debug (d)'. #debugProcess}}].
			menu addList: {{'profile messages (m)'. #messageTally}}.
			(selectedProcess suspendingList isKindOf: Semaphore)
				ifTrue: [menu add: 'signal Semaphore (S)' action: #signalSemaphore].
			menu add: 'full stack (k)' action: #moreStack.
			menu addLine].

	menu addList: {{'find context... (f)'. #findContext}. {'find again (g)'. #nextContext}}.
	menu addLine.

	menu
		add: (self isAutoUpdating
				ifTrue: ['turn off auto-update (a)']
				ifFalse: ['turn on auto-update (a)'])
		action: #toggleAutoUpdate.
	menu add: 'update list (u)' action: #updateProcessList.

	pw := Smalltalk at: #CPUWatcher ifAbsent: [].
	pw ifNotNil: [
		menu addLine.
		pw isMonitoring
				ifTrue: [ menu add: 'stop CPUWatcher' action: #stopCPUWatcher ]
				ifFalse: [ menu add: 'start CPUWatcher' action: #startCPUWatcher  ]
	].

	^ menu
]

{ #category : #'process list' }
ProcessBrowser >> processNameList [
	"since processList is a WeakArray, we have to strengthen the result"
	| pw tally |
	pw := Smalltalk at: #CPUWatcher ifAbsent: [ ].
	tally := pw ifNotNil: [ pw current ifNotNil: [ pw current tally ] ].
	^ (processList asOrderedCollection
		copyWithout: nil)
		collect: [:each | | percent |
			percent := tally
				ifNotNil: [ ((((tally occurrencesOf: each) * 100.0 / tally size) roundTo: 1)
						asString padded: #left to: 2 with: $ ), '% '  ]
				ifNil: [ '' ].
			percent, (self prettyNameForProcess: each)
		] 
]

{ #category : #'process actions' }
ProcessBrowser >> resumeProcess [
	self class resumeProcess: selectedProcess.
	self updateProcessList
]

{ #category : #accessing }
ProcessBrowser >> selectedClass [
	"Answer the class in which the currently selected context's method was  
	found."
	^ selectedClass
		ifNil: [
			selectedContext ifNil: [^ nil].
			selectedClass := selectedContext receiver
				ifNil: [selectedSelector := selectedContext method selector.
					   selectedContext method methodClass]
				ifNotNil: [selectedContext methodClass]]
]

{ #category : #accessing }
ProcessBrowser >> selectedMethod [
	^ methodText ifNil: [methodText := selectedContext
						ifNil: ['']
						ifNotNil: [| pcRange | 
							methodText := [ selectedContext sourceCode ]
								ifError: [ :err :rcvr | 'error getting method text' ].
							pcRange := self pcRange.
							methodText asText
								addAttribute: TextColor red
								from: pcRange first
								to: pcRange last;
								
								addAttribute: TextEmphasis bold
								from: pcRange first
								to: pcRange last]]
]

{ #category : #accessing }
ProcessBrowser >> selectedSelector [
	"Answer the class in which the currently selected context's method was  
	found."
	^ selectedSelector
		ifNil: [selectedSelector := selectedContext receiver
				ifNil: [selectedClass := selectedContext method methodClass
					   selectedContext method selector]
				ifNotNil: [selectedContext selector]]
]

{ #category : #updating }
ProcessBrowser >> setUpdateCallbackAfter: seconds [ 

	[(Delay forSeconds: seconds) wait.
	Project current addDeferredUIMessage: [self updateProcessList]] fork
]

{ #category : #'process actions' }
ProcessBrowser >> signalSemaphore [
	(selectedProcess suspendingList isKindOf: Semaphore)
		ifFalse: [^ self].
	[selectedProcess suspendingList signal] fork.
	(Delay forMilliseconds: 300) wait.
	"Hate to make the UI wait, but it's convenient..."
	self updateProcessList
]

{ #category : #accessing }
ProcessBrowser >> stackList [
	^ stackList
]

{ #category : #accessing }
ProcessBrowser >> stackListIndex [
	^ stackListIndex
]

{ #category : #accessing }
ProcessBrowser >> stackListIndex: index [ 
	stackListIndex := index.
	selectedContext := (stackList notNil
						and: [index > 0]) ifTrue:
							[stackList at: index ifAbsent: []].
	selectedClass := nil.
	selectedSelector := nil.
	methodText := nil.
	self changed: #stackListIndex.
	self changed: #selectedMethod
]

{ #category : #views }
ProcessBrowser >> stackListKey: aKey from: aView [

	selectedContext ifNil: [^ self changed: #flash].
	^ aKey
		caseOf: {
			[$c] ->	[self inspectContext].
			[$C] ->	[self exploreContext].
			[$i] ->		[self inspectReceiver].
			[$I] ->		[self exploreReceiver].
			[$b] ->	[self browseContext]}
		otherwise: [self arrowKey: aKey from: aView]
]

{ #category : #'stack list' }
ProcessBrowser >> stackListMenu: aMenu [ 
	| menu |
	selectedContext
		ifNil: [^ aMenu].
	menu := aMenu
				labels: 'inspect context (c)
explore context (C)
inspect receiver (i)
explore receiver (I)
browse (b)'
				lines: #(2 4 )
				selections: #(#inspectContext #exploreContext #inspectReceiver #exploreReceiver #browseContext ).
	^ menu
]

{ #category : #'stack list' }
ProcessBrowser >> stackNameList [
	^ stackList
		ifNil: [#()]
		ifNotNil: [stackList
				collect: [:each | each asString]]
]

{ #category : #updating }
ProcessBrowser >> startAutoUpdate [
	self isAutoUpdatingPaused
		ifTrue: [^ autoUpdateProcess resume].
	self isAutoUpdating
		ifFalse: [autoUpdateProcess := [[self hasView]
						whileTrue: [(Delay forSeconds: 2) wait.
							Project current addDeferredUIMessage: [self updateProcessList]].
					autoUpdateProcess := nil] fork].
	self updateProcessList

]

{ #category : #'initialize-release' }
ProcessBrowser >> startCPUWatcher [
	"Answers whether I started the CPUWatcher"

	| pw |
	pw := Smalltalk at: #CPUWatcher ifAbsent: [ ^self ].
	pw ifNotNil: [
		pw isMonitoring ifFalse: [
			pw startMonitoringPeriod: 5 rate: 100 threshold: 0.85.
			self setUpdateCallbackAfter: 7.
			^true
		]
	].
	^false

]

{ #category : #updating }
ProcessBrowser >> stopAutoUpdate [
	autoUpdateProcess ifNotNil: [
		autoUpdateProcess terminate.
		autoUpdateProcess := nil].
	self updateProcessList
]

{ #category : #'initialize-release' }
ProcessBrowser >> stopCPUWatcher [
	| pw |
	pw := Smalltalk at: #CPUWatcher ifAbsent: [ ^self ].
	pw ifNotNil: [
		pw stopMonitoring.
		self updateProcessList.
		startedCPUWatcher := false.	"so a manual restart won't be killed later"
	]

]

{ #category : #'process actions' }
ProcessBrowser >> suspendProcess [
	| nameAndRules |
	selectedProcess isSuspended
		ifTrue: [^ self].
	nameAndRules := self nameAndRulesForSelectedProcess.
	nameAndRules second
		ifFalse: [self inform: 'Nope, won''t suspend ' , nameAndRules first.
			^ self].
	self class suspendProcess: selectedProcess.
	self updateProcessList
]

{ #category : #'process actions' }
ProcessBrowser >> terminateProcess [
	| nameAndRules |
	nameAndRules := self nameAndRulesForSelectedProcess.
	nameAndRules second
		ifFalse: [self inform: 'Nope, won''t kill ' , nameAndRules first.
			^ self].
	self class terminateProcess: selectedProcess.	
	self updateProcessList
]

{ #category : #accessing }
ProcessBrowser >> text [
	^methodText
]

{ #category : #updating }
ProcessBrowser >> toggleAutoUpdate [
	self isAutoUpdating
		ifTrue: [ self stopAutoUpdate ]
		ifFalse: [ self startAutoUpdate ].

]

{ #category : #'process list' }
ProcessBrowser >> updateProcessList [
	| oldSelectedProcess newIndex now |
	now := Time millisecondClockValue.
	now - lastUpdate < 500
		ifTrue: [^ self].
	"Don't update too fast"
	lastUpdate := now.
	oldSelectedProcess := selectedProcess.
	processList := selectedProcess := selectedSelector := nil.
	Smalltalk garbageCollectMost.
	"lose defunct processes"

	processList := Process allSubInstances
				reject: [:each | each isTerminated].
	processList := processList
				sorted: [:a :b | a priority >= b priority].
	processList := WeakArray withAll: processList.
	newIndex := processList indexOf: oldSelectedProcess.
	self changed: #processNameList.
	self processListIndex: newIndex
]

{ #category : #'stack list' }
ProcessBrowser >> updateStackList [
	self updateStackList: 20
]

{ #category : #'stack list' }
ProcessBrowser >> updateStackList: depth [ 
	| suspendedContext oldHighlight |
	selectedProcess
		ifNil: [^ self changeStackListTo: nil].
	(stackList notNil and: [ stackListIndex > 0 ])
		ifTrue: [oldHighlight := stackList at: stackListIndex].
	selectedProcess == Processor activeProcess
		ifTrue: [self
				changeStackListTo: (thisContext stackOfSize: depth)]
		ifFalse: [suspendedContext := selectedProcess suspendedContext.
			suspendedContext
				ifNil: [self changeStackListTo: nil]
				ifNotNil: [self
						changeStackListTo: (suspendedContext stackOfSize: depth)]].
	self
		stackListIndex: (stackList
				ifNil: [0]
				ifNotNil: [stackList indexOf: oldHighlight])
]

{ #category : #'process actions' }
ProcessBrowser >> wasProcessSuspendedByProcessBrowser: aProcess [
	^self class suspendedProcesses includesKey: aProcess
]

{ #category : #'initialize-release' }
ProcessBrowser >> windowIsClosing [
	startedCPUWatcher ifTrue: [ CPUWatcher stopMonitoring ]
]
