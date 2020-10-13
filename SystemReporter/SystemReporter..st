"
SystemReporter offers a window where information about the system is gathered. This can be easily copied to the clipboard and be attached to a bug report for better identification of the context the bug occured in.

To extend the SystemReporter:
	- add a method
		reportXYZ: aStream
	  to the reporting category
	- insert a line
		add: #XYZ method: #reportXYZ
	  to the initialize method

"
Class {
	#name : #SystemReporter,
	#superclass : #Model,
	#instVars : [
		'categories',
		'categoriesSelected',
		'report',
		'tinyBenchmarksResult',
		'categoryList',
		'testRunner',
		'spaceAnalysisResult'
	],
	#category : #SystemReporter
}

{ #category : #'instance creation' }
SystemReporter class >> open [
	^ ToolBuilder open: self new.
]

{ #category : #'accessing-categories' }
SystemReporter >> add: category method: aSymbol [
	^self categoryList add: (self categories add: category -> aSymbol) key
]

{ #category : #building }
SystemReporter >> buildCategoriesWith: aBuilder [
	^ aBuilder pluggableMultiSelectionListSpec new
		model: self;
		list: #categoryList;
		menu: #categoryMenu:;
		getIndex: #categorySelected;
		setIndex: #categorySelected:;
		getSelectionList: #categoryAt:;
		setSelectionList: #categoryAt:put:;
		yourself.
]

{ #category : #building }
SystemReporter >> buildReportWith: aBuilder [
	^ aBuilder pluggableTextSpec new
		model: self;
		font: Preferences standardFixedFont;
		menu: #reportMenu:;
		getText: #reportText;
		yourself.
]

{ #category : #building }
SystemReporter >> buildWith: aBuilder [
	| window |
	window := aBuilder pluggableWindowSpec new
		model: self; label: self label; extent: self extent;
		children: (OrderedCollection new 
			add: ((self buildCategoriesWith: aBuilder)
				frame: self categoriesFrame;
				yourself);
			add: ((self buildReportWith: aBuilder)
				frame: self reportFrame;
				yourself);
			yourself);
		yourself.
	^ aBuilder build: window.
]

{ #category : #'accessing-categories' }
SystemReporter >> categories [
	^ categories ifNil: [categories := IdentityDictionary new]
]

{ #category : #building }
SystemReporter >> categoriesFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 0.25 offset: 0;
		bottomFraction: 1 offset: 0
]

{ #category : #'accessing-categories' }
SystemReporter >> categoryAt: anIndex [
	^ categoriesSelected includes: (self categoryList at: anIndex ifAbsent: [ ^ false ]).
]

{ #category : #'accessing-categories' }
SystemReporter >> categoryAt: anInteger put: aBoolean [
	categoriesSelected := categoriesSelected
		perform: (aBoolean ifTrue: [ #copyWith: ] ifFalse: [ #copyWithout: ])
		with: (self categoryList at: anInteger ifAbsent: [ ^ self ]).
	self updateReport
]

{ #category : #'accessing-categories' }
SystemReporter >> categoryList [
	^ categoryList ifNil: [categoryList := OrderedCollection new]
]

{ #category : #'accessing-categories' }
SystemReporter >> categoryMenu: aMenu [
	^ aMenu
		title: 'Categories';
		add: 'Select all' action: #selectAllCategories;
		add: 'Select none' action: #selectNoCategories;
		addLine;
		add: 'Refresh' action: #refresh;
		yourself.
]

{ #category : #'accessing-categories' }
SystemReporter >> categorySelected [
	^ 0
]

{ #category : #'accessing-categories' }
SystemReporter >> categorySelected: anInteger [
	self changed: #categorySelected.
]

{ #category : #'accessing-report' }
SystemReporter >> copyReportToClipboard [
	Clipboard clipboardText: self reportText.
	UIManager default inform: 'Copied Report to Clipboard'
]

{ #category : #private }
SystemReporter >> enumerate: aBlock on: aStream [
	self enumerate: aBlock startAt: 0 on: aStream
]

{ #category : #private }
SystemReporter >> enumerate: aBlock startAt: first on: aStream [
	"Utilitymethod to enumerate Options or Parameters from first to 1000"
	| idx value |
	idx := first.
	[value := aBlock value: idx.
	value = nil or: [idx > 1000]] whileFalse: [
		aStream
			nextPut: $#;
			nextPutAll: idx printString;
			tab;
			nextPutAll: value; cr.
		idx := idx + 1
	].
	idx = first ifTrue: [aStream nextPutAll: 'none'; cr]
]

{ #category : #'accessing-ui' }
SystemReporter >> extent [
	^ 640 @ 480
]

{ #category : #'printing-report' }
SystemReporter >> header: aString on: aStream [
	aStream withAttribute: TextEmphasis bold do: [	
		aStream nextPutAll: aString; cr.
		aString size timesRepeat: [aStream nextPut: $-].
		aStream cr]
]

{ #category : #'initialize-release' }
SystemReporter >> initialize [
	self
		add: #'Contributors' method: #reportContributors;
		add: #Image method: #reportImage;
		add: #'Image Parameters' method: #reportImageParameters;
		add: #'Image Sources' method: #reportSources;
		add: #'Image Preferences' method: #reportPreferences;
		add: #'MC Repositories' method: #reportRepositories;
		add: #'MC Working Copies' method: #reportWorkingCopies;
		add: #'VM General' method: #reportVM;
		add: #'VM Options' method: #reportVMOptions;
		add: #'VM Modules' method: #reportModules;
		add: #'VM Parameters' method: #reportVMParameters;
		add: #'VM Stats' method: #reportVMStats.
	Smalltalk os platformName = 'Win32' ifTrue: [
		self
			add: #'VM Configuration' method: #reportWin32VMConfig.
		].
	self
		add: #'OS General' method: #reportOS.
	Smalltalk os platformName = 'Win32' ifTrue: [
		self
			add: #'OS Details' method: #reportWin32OSDetails;
			add: #'Hardware Details' method: #reportWin32HardwareDetails;
			add: #'GFX Hardware Details' method: #reportWin32GFXDetails.
		].
	Smalltalk os osVersion = 'linux' ifTrue: [
		self
			add: #'OS Details' method: #reportLinuxOSDetails
	].
	self
		add: #'Tiny Benchmarks' method: #reportTinyBenchmarks;
		add: #'Space Analysis' method: #reportSpaceAnalysis;
		add: #'SUnit' method: #reportTestRunner;
		add: #'Debug Log' method: #reportDebugLog.
	categoriesSelected := Set with: #Image with: #'VM General'.
	self updateReport

]

{ #category : #'accessing-ui' }
SystemReporter >> label [
	^ 'System Reporter' 
]

{ #category : #private }
SystemReporter >> printDebugExpressionFor: methodSignature on: aStream [ 
	| compiledMethod |
	compiledMethod := Compiler evaluate: methodSignature.
	aStream
		 nextPut: $( ;
		 nextPutAll: compiledMethod methodClass name ;
		 nextPutAll: ' selector: #' ;
		 nextPutAll: compiledMethod selector ;
		 nextPutAll: ') debug.'
]

{ #category : #'accessing-categories' }
SystemReporter >> refresh [
	spaceAnalysisResult := tinyBenchmarksResult := testRunner := nil.
	self updateReport
]

{ #category : #reporting }
SystemReporter >> reportContributors: stream [

	self header: 'Squeak Contributors (alphabetically)' on: stream.
	
	stream withAttribute: (TextColor color: (Color r: 0 g: 0.5 b: 0)) do: [
		stream nextPutAll: 'If we forgot to mention YOU in this list, please report to board@lists.squeakfoundation.org'].
	stream cr; cr.
	
	SystemNavigation authors keys sorted do: [:fullName |
		(SystemNavigation authors at: fullName) in: [:abbreviations |
			stream nextPutAll: ('{1} ({2})' format: {fullName. abbreviations asArray joinSeparatedBy: ' '}); cr]].
]

{ #category : #reporting }
SystemReporter >> reportDebugLog: aStream [
	| logFilename logStream contents |
	self header: 'Debug Logfile' on: aStream.
	logFilename := Smalltalk image squeakErrorFileName.
	logStream := nil.
	[
		[
			logStream := FileStream readOnlyFileNamed: logFilename.
			aStream nextPutAll: logStream name; cr; cr.
			contents := logStream contents.
			aStream
				nextPutAll: 
					((contents isNil or: [contents size = 0])
						ifTrue: ['<empty>']
						ifFalse: [contents]);
				cr
		] on: Error do: [:ex |
			aStream
				nextPutAll: (
					ex class = FileDoesNotExistException
						ifTrue: [logFilename, ' not found']
						ifFalse: [ex description]);
				cr
		]
	] ensure: [
		logStream ifNotNil: [logStream close]
	]
]

{ #category : #building }
SystemReporter >> reportFrame [
	^LayoutFrame new
		leftFraction: 0.25 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 1 offset: 0
]

{ #category : #reporting }
SystemReporter >> reportImage: aStream [
	self header: 'Image' on: aStream.
	aStream 
		nextPutAll: Smalltalk image imageName; cr;
		nextPutAll: SystemVersion current version; cr;
		nextPutAll: Smalltalk image lastUpdateString; cr;
		nextPutAll: Smalltalk image currentChangeSetString; cr.
	[ | imageFormat bitsPerWord |
	imageFormat := Smalltalk image imageFormatVersion.
	bitsPerWord := Smalltalk image wordSize * 8.
	aStream nextPutAll: 'Image format ';
			nextPutAll: imageFormat asString;
			nextPutAll: ' (';
			nextPutAll: bitsPerWord asString;
			nextPutAll: ' bit)'; cr]
		on: Warning
		do: ["primitive not present in VM"].

]

{ #category : #reporting }
SystemReporter >> reportImageParameters: aStream [
	self header: 'Image Commandline Parameters' on: aStream.
	self enumerate: [:idx | Smalltalk image argumentAt: idx] on: aStream.
]

{ #category : #reporting }
SystemReporter >> reportLinuxOSDetails: aStream [
	self header: 'Operating System Details' on: aStream.
	#(
		'/etc/issue'
		'/etc/lsb-release'
		'/proc/version'
	) do: [:path|
		self writeContentsSafelyFromFile: path on: aStream]
]

{ #category : #'accessing-report' }
SystemReporter >> reportMenu: aMenu [
	^ aMenu
		title: 'Report';
		add: 'Copy to Clipboard' action: #copyReportToClipboard;
		yourself.
]

{ #category : #reporting }
SystemReporter >> reportModules: aStream [
	self header: 'Loaded VM Modules' on: aStream.
	SmalltalkImage current listLoadedModules sort do: [:each | aStream nextPutAll: each; cr].


]

{ #category : #reporting }
SystemReporter >> reportOS: aStream [
	self header: 'Operating System/Hardware' on: aStream.
	aStream
		nextPutAll: Smalltalk os platformName; space;
		nextPutAll: Smalltalk os osVersion; space;
		nextPutAll: Smalltalk os platformSubtype; cr

]

{ #category : #reporting }
SystemReporter >> reportPreferences: aStream [
	| booleanPrefs prefs valuePrefs attribute falseTA trueTA |
	prefs := Preferences dictionaryOfPreferences.
	booleanPrefs := prefs select: [:each | each type = #Boolean].
	valuePrefs := prefs select: [:each | each type = #Number or: [each type = #String]].
	trueTA := TextColor black.
	falseTA := TextColor gray.
	booleanPrefs := booleanPrefs sorted: [:a :b | a name <= b name].  
	self header: 'Boolean Preferences' on: aStream.
	booleanPrefs do: [:each | | prefValue |
		[prefValue := each preferenceValue]
			on: Deprecation do: [:ex | ex resume].
		attribute := prefValue ifTrue: [trueTA] ifFalse: [falseTA].
		aStream withAttribute: attribute do: [	
		aStream
			nextPutAll: each name;
			tab;  
			nextPutAll: prefValue printString;
			cr]].
	aStream cr.
	self header: 'Value Preferences' on: aStream.
	valuePrefs do: [:each | | prefValue |
		[prefValue := each preferenceValue]
			on: Deprecation do: [:ex | ex resume].
		aStream
			nextPutAll: each name;
			tab;  
			nextPutAll: prefValue printString;
			cr].

]

{ #category : #reporting }
SystemReporter >> reportRepositories: aStream [
	self header: 'Monticello Repositories' on: aStream.
	MCRepositoryGroup default repositories do: [:each | aStream nextPutAll: each description; cr]
]

{ #category : #reporting }
SystemReporter >> reportSources: aStream [
	self header: 'Image Sources' on: aStream.
	aStream nextPutAll: SourceFiles class printString; cr.
	SourceFiles do: [:each |
		each ifNotNil: [aStream nextPutAll: each printString; cr]]
]

{ #category : #reporting }
SystemReporter >> reportSpaceAnalysis: aStream [

	spaceAnalysisResult ifNil: [
		(UIManager default
			confirm: 'Running the space analysis\might take a few seconds.' withCRs translated
			title: 'Continue?' translated)
				ifFalse: [
					categoriesSelected remove: #'Space Analysis'.
					^ self changed: #categorySelected ].
		
		spaceAnalysisResult := String streamContents: [ :stream |
			SpaceTally new printSpaceAnalysis: 1 onStream: stream ] ].
	self header: 'Space Analysis' on: aStream.
	aStream nextPutAll: spaceAnalysisResult; cr
]

{ #category : #reporting }
SystemReporter >> reportTestRunner: aStream [ 
	
	testRunner ifNil: [ 
		(UIManager default
			confirm: 'Running all tests might\take some minutes.' withCRs translated
			title: 'Continue?')
				ifTrue: [ testRunner := TestRunner new runAll ]
				ifFalse:
					[ categoriesSelected remove: #SUnit.
					^ self changed: #categorySelected ] ].
	self
		header: 'SUnit Results'
		on: aStream.
	aStream nextPutAll: testRunner statusText ; cr ; cr.
	self
		header: 'Failed Tests'
		on: aStream.
	testRunner failedList do:
		[ : each | self
			printDebugExpressionFor: each
			on: aStream.
		aStream cr ].
	aStream cr.
	self
		header: 'Errors'
		on: aStream.
	testRunner errorList do:
		[ : each | self
			printDebugExpressionFor: each
			on: aStream.
		aStream cr ]
]

{ #category : #'accessing-report' }
SystemReporter >> reportText [
	^ (report isNil or: [categoriesSelected isEmpty])
		ifTrue: ['-- Choose any category on the left --']
		ifFalse: [report]
]

{ #category : #reporting }
SystemReporter >> reportTinyBenchmarks: aStream [
	tinyBenchmarksResult ifNil: [
		(UIManager default
			confirm: 'Running all benchmarks\might take a few seconds.' withCRs translated
			title: 'Continue?' translated)
				ifFalse: [
					categoriesSelected remove: #'Tiny Benchmarks'.
					^ self changed: #categorySelected ].
		Cursor wait showWhile: [tinyBenchmarksResult := 0 tinyBenchmarks]].
	self header: 'Tiny Benchmarks' on: aStream.
	aStream nextPutAll: tinyBenchmarksResult; cr
]

{ #category : #reporting }
SystemReporter >> reportVM: aStream [
	| howToBuild |
	self header: 'Virtual Machine' on: aStream.
	aStream
		nextPutAll: Smalltalk vm vmFileName; cr;
		nextPutAll: Smalltalk vm vmVersion; cr.
	Smalltalk vm buildDate
		ifNotNil: [:string | aStream nextPutAll: string; cr].
	[Smalltalk vm platformSourceVersion
		ifNotNil: [:v | aStream nextPutAll: 'platform sources revision ', v; cr]]
			on: Warning do: ["unsupported primitive"].
	[Smalltalk vm interpreterSourceVersion
		ifNotNil: [:v | aStream nextPutAll: 'VMMaker versionString ', v; cr]]
			on: Warning do: ["unsupported primitive"].
	[Smalltalk vm interpreterClass
		ifNotNil: [:string | aStream nextPutAll: string; cr].
	Smalltalk vm cogitClass
		ifNotNil: [:string | aStream nextPutAll: string; cr]
	] on: Error do: ["unsupported primitives"].
	self vmIsOpenSmalltalkVM ifTrue:
		[howToBuild := 'Visit https://github.com/OpenSmalltalk/opensmalltalk-vm; follow the\"Clone or download" instructions, then read the top-level README.md\and HowToBuild files in the top-level build directory for your\platform(s), build.macos64x64/HowToBuild, build.win32x86/HowToBuild, etc.' withCRs].
	howToBuild ifNil: [^self].
	aStream cr.
	self header: 'To Build A Similar Virtual Machine' on: aStream.
	aStream nextPutAll: howToBuild; cr
]

{ #category : #reporting }
SystemReporter >> reportVMOptions: aStream [
	self header: 'Virtual Machine Commandline Options' on: aStream.
	self enumerate: [:idx | Smalltalk vm optionAt: idx] startAt: 1 on: aStream
]

{ #category : #reporting }
SystemReporter >> reportVMParameters: aStream [
	| vmParameters isStack isCog isSpur |
	self header: 'Virtual Machine Parameters' on: aStream.
	vmParameters := Smalltalk vm getVMParameters.
	isStack := (vmParameters at: 42 ifAbsent: [0]) ~= 0. "42 = number of stack pages available"
	isCog := isStack and: [(vmParameters at: 46) ~= 0].  "46 is machine code zone size"
	isSpur := isStack and: [(vmParameters at: 41) anyMask: 2r10000]. "41 is imageFormatVersion for the VM; bit 16 is the Spur bit"
	(isSpur
		ifFalse:
			[#(	1	'size of old space'
				2	'size of young+old space'
				3	'size of memory'
				4	'allocationCount'
				5	'allocations between GCs'
				6	'survivor count tenuring threshold')]
		ifTrue:
			[#(	1	'size of old space'
				2	'used bytes in new space (used eden + used past space)'
				3	'size of heap')]),
	#(	7	'full GCs since startup'
		8	'total milliseconds in full GCs since startup'),
	(isSpur
		ifFalse: [#(	9	'incremental GCs since startup'
					10	'total milliseconds in incremental GCs since startup'
					11	'tenures of surving objects since startup'),
					{12 to: 19. 'specific to the translating VM'}]
		ifTrue: [#(	9	'scavenging GCs since startup'
					10	'total milliseconds in scavenging GCs since startup'
					11	'tenures of surving objects since startup'),
					{12 to: 15. 'reserved for future use'},
				#(	16	'total microseconds in idle since startup'
					17	'proportion of code zone available for use (Sista VMs only; read-write)'
					18	'total milliseconds in full GC compaction since startup (a portion of parameter 8)'
					19	'scavenge threshold; the effective size of eden')]),
	#(	20  'utc microseconds at startup (if non-zero)'
		21	'root/remembered table size (occupancy)'
		22	'root/remembered table overflows since startup'
		23	'bytes of extra memory to reserve for VM buffers, plugins, etc.'
		24	'free memory threshold above which object memory will be shrunk'
		25	'memory headroom when growing object memory'),
	(isStack
		ifFalse:
			[#(	26  'interruptChecksEveryNms - force an ioProcessEvents every N milliseconds, in case the image is not calling getNextEvent often')]
		ifTrue:
			[#(	26  'heartbeat period (ms; see #58)')]),
	(isSpur
		ifFalse:
			[#(	27	'number of times mark loop iterated for current IGC/FGC includes ALL marking'
				28	'number of times sweep loop iterated  for current IGC/FGC'
				29	'number of times make forward loop iterated for current IGC/FGC'
				30	'number of times compact move loop iterated for current IGC/FGC')]
		ifTrue: [#()]),
	#(	31	'number of grow memory requests'
		32	'number of shrink memory requests'),
	(isSpur
		ifFalse:
			[#(	33	'number of root table entries used for current IGC/FGC'
				34	'number of allocations done before current IGC/FGC'
				35	'number of survivor objects after current IGC/FGC'
				36  'millisecond clock when current IGC/FGC completed'
				37  'number of marked objects for Roots of the world, not including Root Table entries for current IGC/FGC'
				38  'milliseconds taken by current IGC'
				39  'Number of finalization signals for Weak Objects pending when current IGC/FGC completed')]
		ifTrue:
			[#(	33	'number of root table entries at last scavenge'
				35	'number of survivor objects at last scavenge (if non-zero)'
				36  'millisecond clock when current scavenge completed'
				38  'milliseconds taken by current scavenge'
				39  'Number of finalization signals for Weak Objects pending when current SGC/FGC completed')]),
	#(	40  'VM word size - 4 or 8'),
	(isStack
		ifTrue:
			[#(
				41	'imageFormatVersion for the VM'
				42	'number of stack pages available'
				43	'desired number of stack pages (stored in image file header, max 65535)'
				44	'size of eden, in bytes'
				45	'desired size of eden, in bytes (stored in image file header)'
				46	'machine code zone size, in bytes (0 in Stack VM)'
				47	'desired machine code zone size (0 => default 1Mb to 2Mb depending on processor)'),
			  {	48.	'Persistent image header flags\		bit 0: implies Process has threadId as its 4th inst var\		bit 1: if set, methods that are interpreted will have the flag bit set in their header\		bit 2: if set, implies preempting a process does not put it to the back of its run queue\		bit 3: if set, implies the GUI should run on the first thread and event queues should not be accessed from other threads\		bit 4: if set, implies the new finalization scheme where WeakArrays are queued\		bit 5: if set, implies wheel events will be delivered as such and not mapped to arrow key events\		bit 6: if set, implies arithmetic primitives will fail if given arguments of different types (float vs int)' withCRs },
			#(	49	'max size the image promises to grow the external semaphore table to'),
			(isSpur
				ifFalse:
					[{	50 to: 51.	'reserved for VM parameters that persist in the image (such as size of eden above)'.
						52 to: 56.	'specific to Spur' }]
				ifTrue:
					[{	50 to: 51.	'reserved for VM parameters that persist in the image (such as size of eden above)' },
					#(	52			'root/remembered table capacity'
						53			'number of old space segments'
						54			'total free old space'
						55			'ratio of growth and image size at or above which a GC will be performed post scavenge')]),
			#(	56	'number of process switches since startup'
				57	'number of ioProcessEvents calls since startup'
				58	'number of forceInterruptCheck calls since startup'
				59	'number of check event calls since startup'
				60	'number of stack page overflows since startup'
				61	'number of stack page divorces since startup'
				62	'compiled code compactions since startup'),
			(isCog
				ifFalse:
					[#()]
				ifTrue:
					[#(	63	'total milliseconds in compiled code compactions since startup'
						64	'the number of methods that currently have jitted machine-code')]),
			{	65.	'Cog feature flags\		bit 0: set if the VM supports MULTIPLE_BYTECODE_SETS.\		bit 1: set if the VM supports read-only objects.\		bit 2: set if the VM has an ITIMER_HEARTBEAT' withCRs.
				66.	'the byte size of a stack page'.},
			(isSpur
				ifFalse:
					[{	67 to: 69.	'reserved for more Cog-related info' }]
				ifTrue:
					[#(	67		'the maximum allowed size of old space (if zero there is no limit)'
						68		'the average number of live stack pages when scanned by scavenge/gc/become'
						69		'the maximum number of live stack pages when scanned by scavenge/gc/become')]),
			#(	70	'the vmProxyMajorVersion (the interpreterProxy VM_MAJOR_VERSION)'
				71	'the vmProxyMinorVersion (the interpreterProxy VM_MINOR_VERSION)')]
		ifFalse:
			[#()])
	pairsDo: [:idx :desc | | value values |
		aStream nextPut: $#.
		idx isInteger
			ifTrue:
				[value := vmParameters at: idx.
				 aStream print: idx; tab: (idx < 10 ifTrue: [2] ifFalse: [1]); nextPutAll: ((value isInteger and: [idx ~= 41]) ifTrue: [value asStringWithCommas] ifFalse: [value printString])]
			ifFalse:
				[value := vmParameters at: idx first.
				 aStream print: idx first; next: 2 put: $.; print: idx last; tab.
				 values := idx collect: [:i| vmParameters at: i].
				 values asSet size = 1
					ifTrue: [aStream print: value]
					ifFalse: [values do: [:v| aStream print: v] separatedBy: [aStream nextPutAll: ', ']]].
		aStream tab; nextPutAll: desc; cr]
]

{ #category : #reporting }
SystemReporter >> reportVMStats: aStream [
	self header: 'Virtual Machine Statistics' on: aStream.
	aStream
		nextPutAll: Smalltalk vm vmStatisticsReportString
]

{ #category : #reporting }
SystemReporter >> reportWin32GFXDetails: aStream [
	self header: 'Graphics Hardware Details' on: aStream.
	aStream nextPutAll: (SmalltalkImage current getSystemAttribute: 10003)
]

{ #category : #reporting }
SystemReporter >> reportWin32HardwareDetails: aStream [
	self header: 'Hardware Details' on: aStream.
	aStream nextPutAll: (SmalltalkImage current getSystemAttribute: 10001)
]

{ #category : #reporting }
SystemReporter >> reportWin32OSDetails: aStream [
	self header: 'Operating System Details' on: aStream.
	aStream nextPutAll: (SmalltalkImage current getSystemAttribute: 10002)
]

{ #category : #reporting }
SystemReporter >> reportWin32VMConfig: aStream [
	| exePath iniPath |
	self header: 'VM Configuration' on: aStream.
	exePath := Smalltalk vm vmFileName.
	iniPath := (exePath copyUpToLast: $.), '.ini'.
	aStream nextPutAll: iniPath; cr.
	self writeContentsSafelyFromFile: iniPath on: aStream.

]

{ #category : #reporting }
SystemReporter >> reportWorkingCopies: aStream [
	| list |
	self header: 'Monticello Working Copies' on: aStream.
	list := MCWorkingCopy allManagers sort: [:a :b | a name <= b name]  .
	list do: [:each | aStream nextPutAll: each description; cr]
]

{ #category : #private }
SystemReporter >> representsSameBrowseeAs: anotherModel [
	^ self class = anotherModel class
]

{ #category : #'accessing-categories' }
SystemReporter >> selectAllCategories [
	categoriesSelected addAll: categoryList.
	self changed: #categorySelected.
	self updateReport
]

{ #category : #'accessing-categories' }
SystemReporter >> selectNoCategories [
	categoriesSelected removeAll.
	self changed: #categorySelected.
	self updateReport
]

{ #category : #updating }
SystemReporter >> updateReport [
	report := Text streamContents: [:stream | 
		self categoryList do: [:each |
			(categoriesSelected includes: each) ifTrue: [
				self perform: ((categories at: each), ':') asSymbol with: stream.
				stream cr]]].
	self changed: #reportText.
]

{ #category : #private }
SystemReporter >> vmIsOpenSmalltalkVM [
	^[#('CoInterpreter' 'StackInterpreter') includes: (Smalltalk vm interpreterClass copyUpTo: Character space)]
		on: Error "unsupported primitives"
		do: [:ex| false]
]

{ #category : #private }
SystemReporter >> writeContentsSafelyFromFile: osPath on: aStream [
	aStream nextPutAll:
		([
			(FileStream readOnlyFileNamed: osPath) upToEnd
		 ] on: Error do: [:ex| ex return: ex printString])
]
