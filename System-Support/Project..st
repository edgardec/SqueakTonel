"
A Project stores the state of a complete Squeak desktop, including
the windows, and the currently active changeSet.  A project knows who
its parent project is.  When you change projects, whether by entering
or exiting, the screen state of the project being exited is saved in
that project.

A project is retained by its view in the parent world.  It is
effectively named by the name of its changeSet, which can be changed
either by renaming in a changeSorter, or by editing the label of its
view from the parent project.

As the site of major context switch, Projects are the locus of
swapping between the old MVC and the new Morphic worlds.  The
distinction is based on whether the variable 'world' contains a
WorldMorph or a ControlManager.

Saving and Loading
Projects may be stored on the disk in external format.  (Project
named: 'xxx') exportSegment, or choose 'store project on file...'.
Projects may be loaded from a server and stored back.  Storing on a
server never overwrites;  it always makes a new version.  A project
remembers the url of where it lives in urlList.  The list is length
one, for now.  The url may point to a local disk instead of a server.
All projects that the user looks at are cached in the Squeaklet
folder.  Sorted by server.  The cache holds the most recent version
only.

When a project is loaded into Squeak, its objects are converted to
the current version.  There are three levels of conversion.  First,
each object is converted from raw bits to an object in its old
format.  Then it is sent some or all of these messages:
	comeFullyUpOnReload: smartRefStream  		Used to
re-discover an object that already exists in this image, such as a
resource, global variable, Character, or Symbol.  (sent to objects in
outPointers)
	convertToCurrentVersion: varDict refStream: smartRefStrm
		fill in fields that have been added to a class since
the object was stored.  Used to set the extra inst var to a default
value.  Or, return a new object of a different class.  (sent to
objects that changed instance variables)
	fixUponLoad: aProject refStream: smartRefStrm
	change the object due to conventions that have changed on the
project level.  (sent to all objects in the incoming project)

Here is the calling sequence for storing out a Project:
Project saveAs
Project storeOnServer
Project storeOnServerWithProgressInfo
Project storeOnServerInnards
Project exportSegmentFileName:directory:
Project exportSegmentWithChangeSet:fileName:directory:
ImageSegment writeForExportWithSources:inDirectory:changeSet:


"
Class {
	#name : #Project,
	#superclass : #Model,
	#instVars : [
		'world',
		'uiManager',
		'changeSet',
		'transcript',
		'parentProject',
		'previousProject',
		'displayDepth',
		'viewSize',
		'thumbnail',
		'nextProject',
		'projectParameters',
		'version',
		'urlList',
		'lastDirectory',
		'lastSavedAtSeconds',
		'projectPreferenceFlagDictionary',
		'resourceManager'
	],
	#classVars : [
		'AllProjects',
		'CurrentProject',
		'EmergencyRecoveryRequested',
		'GoalFreePercent',
		'GoalNotMoreThan'
	],
	#category : #'System-Support'
}

{ #category : #utilities }
Project class >> addingProject: newProject [

	(self allProjects includes: newProject) ifTrue: [^self].
	AllProjects := self allProjects copyWith: newProject.
]

{ #category : #utilities }
Project class >> advanceToNextProject [
	| nextProj |
	(nextProj := CurrentProject nextProject) ifNotNil:
		 [nextProj enter: true revert: false saveForRevert: false]

]

{ #category : #utilities }
Project class >> allNames [

	^(self allProjects collect: [:p | p name]) sort: [:n1 :n2 | n1 caseInsensitiveLessOrEqual: n2]
]

{ #category : #utilities }
Project class >> allNamesAndProjects [

	^(self allProjects
		sorted: [ :p1 :p2 | p1 name caseInsensitiveLessOrEqual: p2 name ])
		replace: [ :aProject | Array with: aProject name with: aProject ]
]

{ #category : #utilities }
Project class >> allProjects [

	^AllProjects ifNil: [
		Smalltalk garbageCollect.
		AllProjects := self allSubInstances select: [:p | p name notNil].
	].
]

{ #category : #utilities }
Project class >> allProjectsOrdered [
	"Answer a list of all projects in hierarchical order, depth first"
	
	| allProjects  |
	allProjects := OrderedCollection new.
	Project topProject withChildrenDo:
		[:p | allProjects add: p].
	^ allProjects

"
Project allProjectsOrdered
"
]

{ #category : #utilities }
Project class >> canWeLoadAProjectNow [

	^ Smalltalk verifyMorphicAvailability

]

{ #category : #utilities }
Project class >> chooseNaturalLanguage [
	"Have the current project choose a new natural language"

	self current chooseNaturalLanguage
]

{ #category : #'class initialization' }
Project class >> cleanUp: agressive [
	"Remove all projects but only when cleaning aggressively"

	agressive ifTrue:[
		self removeAllButCurrent.
		self current resourceManager reset].
]

{ #category : #constants }
Project class >> current [
	"Answer the project that is currently being used."

	^CurrentProject
]

{ #category : #utilities }
Project class >> deletingProject: outgoingProject [
	"Delete the outgoing project and all its sub-projects. Start with the sub-projects."
	
	"Delete all sub-projects."
	outgoingProject subProjects do: [:p | self deletingProject: p].

	"Forget that it ever existed. We have to do that now to avoid other code iterating over the partially removed project."
	self forget: outgoingProject.	

	"Give all registered projects the chance to release their references."
	self allProjects do: [:p | p deletingProject: outgoingProject].
	
	"Really clean-up everything related to the outgoing project."
	self releaseProjectReferences: outgoingProject.
]

{ #category : #utilities }
Project class >> enter: aString [
	"Enter the project with the given name"
	^ ((self named: aString) ifNil: [^ CurrentProject]) enter
]

{ #category : #'squeaklet on server' }
Project class >> enterIfThereOrFind: aProjectName [

	^ self current enterIfThereOrFind: aProjectName

]

{ #category : #utilities }
Project class >> flattenProjectHierarchy [
	"Clean-up project hierarchy. Make all projects be sub-projects of the top project."
	
	self allSubInstancesDo: [:ea | ea setParent: self topProject].
]

{ #category : #utilities }
Project class >> forget: aProject [

	AllProjects := self allProjects copyWithout: aProject.
]

{ #category : #'squeaklet on server' }
Project class >> fromUrl: urlString [
	"Load the project, and make a thumbnail to it in the current project.  Replace the old one if necessary.
To test it, make sure you don't have AAEmptyTest.001.pr in your Squeaklets directory. Then do:
Project fromUrl: 'http://209.143.91.36/super/SuperSwikiProj/AAEmptyTest.001.pr'.
The project should open and you should enter it. Return to the previous project and delete the project. Then do:
Project fromUrl: 'AAEmptyTest.001.pr'.
The project should open again - this time faster - and you should enter it. 
"
	| absoluteUrl projectFilename projName proj serverDir pair |
	Project canWeLoadAProjectNow ifFalse: [^ self].
	absoluteUrl := Url absoluteFromFileNameOrUrlString: urlString.
	projectFilename := absoluteUrl fileName.
	projName := (Project parseProjectFileName: projectFilename unescapePercents) first.
	(proj := Project named: projName) ifNotNil: [
		"it appeared"
		^ProjectEntryNotification signal: proj].

	serverDir := ServerDirectory serverForURL: absoluteUrl directoryUrl asString.
	serverDir ifNotNil: [
		pair := self mostRecent: projectFilename onServer: serverDir.
		"Pair first is name exactly as it is on the server"
		pair first ifNil: [^self current openBlankProjectNamed: projName].
		projectFilename := pair first].

	ProjectLoading
		installRemoteNamed: projectFilename
		from: absoluteUrl asString unescapePercents
		named: projName
		in: CurrentProject
]

{ #category : #utilities }
Project class >> hierarchyOfNamesAndProjects [
	"Answer a list of all project names, with each entry preceded  
	by white space commensurate with its depth beneath the top  
	project"
	^ self allProjectsOrdered
		select: [:project | (#('<no name -- garbage?>' 'Building with Squeak' 'Fun With Music' ) includes: project name) not]
		thenCollect: [:project | Array with: project nameAdjustedForDepth with: project]
]

{ #category : #'class initialization' }
Project class >> initialize [

	Smalltalk addToStartUpList: self after: SecurityManager.
	Smalltalk addToShutDownList: self after: SecurityManager.
]

{ #category : #'squeaklet on server' }
Project class >> isBadNameForStoring: aString [

	| badChars |

	"will the name of this project cause problems when stored on an arbitrary file system?"
	badChars := #( $: $< $> $| $/ $\ $? $* $" $.) asSet.
	^aString size > 24 or: [
		aString anySatisfy: [ :each | 
			each asciiValue < 32 or: [badChars includes: each]
		]
	]

]

{ #category : #utilities }
Project class >> jumpToProject [
	"Project jumpToProject"
	"Present a list of potential projects and enter the one selected."

	self current jumpToProject
]

{ #category : #utilities }
Project class >> jumpToSelection: selection [
	"Enter the project corresponding to this menu selection."

	self flag: #toRemove. "Project current jumpToProject"
	^ self current jumpToSelection: selection

]

{ #category : #'squeaklet on server' }
Project class >> loaderUrl [
	"Return a url that will launch a project in a browser by composing a url like <loaderURL>?<projectURL>"
	^ Smalltalk namedArguments
		at: 'LOADER_URL'
		ifAbsent: [  ]
]

{ #category : #'class initialization' }
Project class >> localeChanged [
	self current class == self
		ifTrue: [self current localeChanged].
]

{ #category : #utilities }
Project class >> maybeForkInterrupt [

	self flag: #toRemove. "unreferenced in image, check eToys"
	Preferences cmdDotEnabled ifFalse: [^self].
	[self current interruptName: 'User Interrupt'] fork

]

{ #category : #'squeaklet on server' }
Project class >> mostRecent: projName onServer: aServerDirectory [
	| stem list max goodName triple num stem1 stem2 rawList nothingFound unEscName |
	"Find the exact fileName of the most recent version of project with the stem name of projName.  Names are of the form 'projName|mm.pr' where mm is a mime-encoded integer version number.
	File names may or may not be HTTP escaped, %20 on the server."

	self flag: #bob.		"do we want to handle unversioned projects as well?"
						"I think we do now - Yoshiki."

	nothingFound := {nil. -1}.
	aServerDirectory ifNil: [^nothingFound].
	"23 sept 2000 - some old projects have periods in name so be more careful"
	unEscName := projName unescapePercents.
	triple := Project parseProjectFileName: unEscName.
	stem := triple first.
	rawList := aServerDirectory fileNames.

	rawList isString ifTrue: [self inform: 'server is unavailable' translated. ^nothingFound].
	list := rawList collect: [:nnn | nnn unescapePercents].
	max := -1.  goodName := nil.
	list withIndexDo: [:aName :ind |
		((aName beginsWith: stem)) ifTrue: [
			((aName endsWith: triple last) or: [triple last = '' and: [aName endsWith: '.pr']]) ifTrue: [
			num := (Project parseProjectFileName: aName) second.
			num > max ifTrue: [max := num.  goodName := (rawList at: ind)]]]].

	max = -1 ifFalse: [^ Array with: goodName with: max].

	"try with underbar for spaces on server"
	(stem includes: $ ) ifTrue: [
		stem1 := stem copyReplaceAll: ' ' with: '_'.
		list withIndexDo: [:aName :ind |
			(aName beginsWith: stem1) ifTrue: [
				num := (Project parseProjectFileName: aName) second.
				num > max ifTrue: [max := num.  goodName := (rawList at: ind)]]]].
	max = -1 ifFalse: [^ Array with: goodName with: max].
	
	"try without the marker | "
	stem1 := stem allButLast, '.pr'.
	stem2 := stem1 copyReplaceAll: ' ' with: '_'.	"and with spaces replaced"
	list withIndexDo: [:aName :ind |
		(aName beginsWith: stem1) | (aName beginsWith: stem2) ifTrue: [
			(triple := aName findTokens: '.') size >= 2 ifTrue: [
				max := 0.  goodName := (rawList at: ind)]]].	"no other versions"
	max = -1 ifFalse: [^ Array with: goodName with: max].

	^nothingFound		"no matches"

]

{ #category : #utilities }
Project class >> named: projName [
	"Answer the project with the given name, or nil if there is no project of that given name."
	"(Project named: 'New Changes') enter"

	^ self allProjects
		detect: [:proj | proj name = projName]
		ifNone: [nil]

]

{ #category : #utilities }
Project class >> named: projName in: aListOfProjects [
	"Answer the project with the given name, or nil if there is no project of that given name."
	"Use given collection for speed until we get faster #allProjects"

	^ aListOfProjects
		detect: [:proj | proj name = projName]
		ifNone: [nil]

]

{ #category : #'squeaklet on server' }
Project class >> namedUrl: urlString [
	| projName |
	"Return project if in, else nil"

	"Ted's fix for unreachable projects"

	projName := (urlString findTokens: '/') last.
	projName := (Project parseProjectFileName: projName unescapePercents) first.
	^ Project named: projName

]

{ #category : #utilities }
Project class >> namedWithDepth: projName [
	"Answer the project with the given name, or nil if there is no project of that given name."
	"(Project named: 'New Changes') enter"

	^ self allProjects
		detect: [:proj | 
			  proj name = projName or:
				[proj nameAdjustedForDepth = projName]]
		ifNone: [nil]
]

{ #category : #utilities }
Project class >> ofWorld: anObject [
	"Find the project of a world."

	"Usually it is the current project"
	CurrentProject world == anObject ifTrue: [^ CurrentProject].

	"Inefficient enumeration if it is not..."
	^ self allProjects detect: [:pr |
		pr world isInMemory 
			ifTrue: [pr world == anObject]
			ifFalse: [false]]
		ifNone: [nil]
]

{ #category : #'squeaklet on server' }
Project class >> parseProjectFileName: aString [
	"It was formerly possible to have periods in projct names and this messed up some parsing methods. Try to handle that more gracefully and allow for a change in scheme at a later time.
	ar 10/11/2000: Switch to a different version encoding scheme. The new scheme is
		baseName.NNN.ext
	where NNN is at least three digits wide and encodes the version in a human readable form.
	Examples:
		Project parseProjectFileName: 'My Project.007.pr'.
		Project parseProjectFileName: 'My.First.Project.042.prj'.
		Project parseProjectFileName: 'My Project.123456.p r o j e c t'.
	The 'dot' is determined on FileDirectory>>dot to compensate for platforms wishing to use something different from a period. Also allows parsing the former encoding of file using Base64 encoded versions of the form
	Project parseProjectFileName: 'aa.bb.cc|AQ.ss'
	"
	| suffix baseName version versionAndSuffix index tokens |
	"answer an array with: 
		1 = basic project name
		2 = version string
		3 = suffix (pr)"

	"First check for the old style versions"
	index := aString findLast:[:ch| ch = $|].
	index = 0 ifFalse:["Old style version"
		baseName := aString copyFrom: 1 to: index-1.
		versionAndSuffix := aString copyFrom: index+1 to: aString size.
		(versionAndSuffix occurrencesOf: $.) = 0 ifTrue: [^ #('no suffix')].
		version := versionAndSuffix copyUpTo: $..
		suffix := versionAndSuffix copyFrom: version size+1 to: versionAndSuffix size.
		"Decode Base64 encoded version"
		version isEmpty
			ifTrue:[version := 0]
			ifFalse:[version := Base64MimeConverter decodeInteger: version unescapePercents].
		^{baseName. version. suffix}].
	"New style versions"
	tokens := aString findTokens: FileDirectory dot.
	tokens size < 2 "Not even a single dot"
		ifTrue:[^{aString. 0. ''}].
	tokens size < 3 ifTrue:["Only one dot"
		self flag: #arNote. "We could allow project file names of the form 'project.001' (e.g., no project extension) or '.001.pr' (without a base name) but I don't think its a good idea."
		^{tokens first. 0. tokens last}].
	suffix := tokens last.
	version := tokens at: tokens size - 1.
	(version anySatisfy:[:ch| ch isDigit not]) ifTrue:[
		"Non-digit version??? I don't think so..."
		baseName := aString copyFrom: 1 to: aString size - suffix size - 1.
		^{baseName. 0. suffix}].
	baseName := aString copyFrom: 1 to: aString size - suffix size - version size - 2.
	version := version asInteger.
	^{baseName. version. suffix}
]

{ #category : #'squeaklet on server' }
Project class >> projectExtension [
	^'pr'
]

{ #category : #utilities }
Project class >> projectHierarchy [
	"Answer a string representing all the projects in the system in  
	hierarchical order."
	"Project projectHierarchy"
	^ String
		streamContents: [:aStream | self hierarchyOfNamesAndProjects
				do: [:aPair | aStream nextPutAll: aPair first;
						 cr]]
]

{ #category : #preferences }
Project class >> publishInSexp [

	^ (Smalltalk classNamed: 'SISSDictionaryForScanning')
		ifNil: [false]
		ifNotNil: [:siss | siss publishInSexp]
]

{ #category : #'class initialization' }
Project class >> rebuildAllProjects [
	"Project rebuildAllProjects"

	AllProjects := nil.
	self allProjects.
]

{ #category : #utilities }
Project class >> releaseProjectReferences: outgoingProject [
	"Give all kinds of projects the chance to do generic clean-up to their best knowledge. Consider image segments first."
	
	Smalltalk garbageCollect.
		
	ImageSegment allSubInstancesDo: [:seg |
		seg ifOutPointer: outgoingProject thenAllObjectsDo: [:obj |
			(obj isKindOf: Project) ifTrue: [obj deletingProject: outgoingProject]]].
	
	self allSubclassesDo: [:projectClass |
		(projectClass selectors includes: #releaseProjectReferences:)
			ifTrue: [projectClass releaseProjectReferences: outgoingProject]].
]

{ #category : #utilities }
Project class >> removeAll: projects [
	"Project removeAll: (Project allSubInstances copyWithout: Project current)"

	AllProjects := nil.
	Smalltalk garbageCollect.

	ProjectHistory currentHistory initialize.
	projects do: [:project |
		Project deletingProject: project.
		StandardScriptingSystem removePlayersIn: project].

	Smalltalk garbageCollect.
	Smalltalk garbageCollect.

]

{ #category : #utilities }
Project class >> removeAllButCurrent [
	"Project removeAllButCurrent"

	self current removeAllOtherProjects.
]

{ #category : #shrinking }
Project class >> removeProjectsFromSystem [
	"Remove all projects of this kind from the system, reorganizing the project hierarchy as needed.
	This method was originally implemented as SmalltalkImage>>zapMVCProjects in earlier
	versions of Squeak."

	"MVCProject removeProjectsFromSystem"
	"MorphicProject removeProjectsFromSystem"

	| projectsToRemove projectsToReorganize |
	
	(Project current isKindOf: self) ifTrue: [
		"We have to enter another project to unload this project kind."
		(Project subclasses detect: [:ea | (ea includesBehavior: self) not] ifNone: [])
			ifNil: [^ Error signal: 'You have to enter another kind of project.']
			ifNotNil: [:projectClass |
				^ projectClass new
					addDeferredUIMessage: [self removeProjectsFromSystem];
					enter]].

	(Project topProject isKindOf: self) ifTrue: [
		"We have to become the top project now."
		Project current beTopProject].
		
	Smalltalk garbageCollect. "So allInstances is precise"
	projectsToRemove := OrderedCollection new.
	projectsToReorganize := OrderedCollection new.
	
	Project allSubInstancesDo: [:proj | 
		(proj isKindOf: self)
			ifTrue: [projectsToRemove add: proj]
			ifFalse: [(proj parent isKindOf: self)
				ifTrue: [projectsToReorganize add: proj]]].
			
	projectsToReorganize do: [:proj |
		"Remove views and refs."
		proj parent deletingProject: proj.
		"Add as sub-project to top project to avoid cycles and confusion. Ignore the current project."
		Project topProject addProject: proj].

	projectsToRemove do: [:proj | proj delete].
]

{ #category : #utilities }
Project class >> resumeProcess: aProcess [
	"Adopt aProcess as the project process -- probably because of proceeding from a debugger"

	self flag: #toRemove. "mt: This seems to be quite specific for MorphicProject... and we have a MorphicDebugger to take care of #resumeProcess: ... Is this hook still needed?"
	self current uiProcess: aProcess.
	aProcess resume
]

{ #category : #utilities }
Project class >> returnToParentProject [

	Project current isTopProject
		ifFalse: [Project current parent enter].
]

{ #category : #utilities }
Project class >> returnToPreviousProject [
	"Return to the project from which this project was entered. Do nothing if the current project has no link to its previous project."

	| prevProj |
	prevProj := CurrentProject previousProject.
	prevProj ifNotNil: [prevProj enter: true revert: false saveForRevert: false].

]

{ #category : #'squeaklet on server' }
Project class >> serverDirectoryFromURL: aURLString [

	| dir |
	self flag: #bob.		"need to include swikis in this - hacked for now"

	(aURLString findString: '/SuperSwikiProj/') > 0 ifTrue: [
		dir := SuperSwikiServer new fullPath: (aURLString copyUpToLast: $/).
		^dir
	].

	^ServerDirectory new fullPath: aURLString
]

{ #category : #'squeaklet on server' }
Project class >> serverFileFromURL: aURLString [

	| dir |
	self flag: #bob.		"need to include swikis in this - hacked for now"

	(aURLString findString: '/SuperSwikiProj/') > 0 ifTrue: [
		dir := SuperSwikiServer new fullPath: (aURLString copyUpToLast: $/).
		^dir readOnlyFileNamed: (aURLString findTokens: '/') last
	].
	^ServerFile new fullPath: aURLString
]

{ #category : #snapshots }
Project class >> shutDown: quitting [

	Project current
		invalidate;
		shrinkDisplay.

	quitting ifTrue: [
		Project current world triggerEvent: #aboutToLeaveWorld].
]

{ #category : #'squeaklet on server' }
Project class >> squeakletDirectory [

	| squeakletDirectoryName |
	squeakletDirectoryName := 'Squeaklets'.
	(FileDirectory default directoryExists: squeakletDirectoryName) ifFalse: [
		FileDirectory default createDirectory: squeakletDirectoryName
	].
	^FileDirectory default directoryNamed: squeakletDirectoryName
]

{ #category : #snapshots }
Project class >> startUp: startAfresh [

	Project current restoreDisplay.

	startAfresh ifTrue: [
		Project current startUpActions.
		Project current world triggerEvent: #aboutToEnterWorld].
	
	Project current restore.
]

{ #category : #utilities }
Project class >> storeAllInSegments [
	"Write out all Projects in this Image.
	Project storeAllInSegments.		"

	| all ff ll |
all := Project allProjects.
Transcript show: 'Initial Space Left: ', (ff := Smalltalk garbageCollect) printString; cr.
all do: [:proj |
	Transcript show: proj name; cr.
	proj storeSegment  "storeSegmentNoFile"].
Transcript show: 'After writing all: ', (ll := Smalltalk garbageCollect) printString; cr.
Transcript show: 'Space gained: ', (ll - ff) printString; cr.
"some will come back in"
]

{ #category : #'squeaklet on server' }
Project class >> sweep: aServerDirectory [
	| repository list parts ind entry projectName versions |
	"On the server, move all but the three most recent versions of each Squeaklet to a folder called 'older'"
	"Project sweep: ((ServerDirectory serverNamed: 'DaniOnJumbo') clone 
				directory: '/vol0/people/dani/Squeaklets/2.7')"

	"Ensure the 'older' directory"
	(aServerDirectory includesKey: 'older') 
		ifFalse: [aServerDirectory createDirectory: 'older'].
	repository := aServerDirectory shallowCopy directory: aServerDirectory directory, '/older'.

	"Collect each name, and decide on versions"
	list := aServerDirectory fileNames.
	list isString ifTrue: [^ self inform: 'server is unavailable' translated].
	list sort.
	parts := list collect: [:en | Project parseProjectFileName: en].
	parts := parts select: [:en | en third = 'pr'].
	ind := 1.
	[entry := list at: ind.
		projectName := entry first asLowercase.
		versions := OrderedCollection new.  versions add: entry.
		[(ind := ind + 1) > list size 
			ifFalse: [(parts at: ind) first asLowercase = projectName 
				ifTrue: [versions add: (parts at: ind).  true]
				ifFalse: [false]]
			ifTrue: [false]] whileTrue.
		aServerDirectory moveYoungest: 3 in: versions to: repository.
		ind > list size] whileFalse.

]

{ #category : #utilities }
Project class >> topProject [
	"Answer the top project.  There is only one"

	^ self allProjects detect: [:p | p isTopProject]
]

{ #category : #'error recovery' }
Project class >> tryEmergencyEvaluatorForRecovery: errorMessage [

	| hasTranscripter transcripter |

	"Make sure to display something."
	Display deferUpdates: false.

	hasTranscripter := (Smalltalk classNamed: #Transcripter)
		ifNotNil: [ :t | transcripter := t. true]
		ifNil: [false].
	(String
		streamContents: 
			[:s |
			| context |
			s nextPutAll: '***System error handling failed***'.
			s cr; nextPutAll: errorMessage.
			context := thisContext sender sender.
			20 timesRepeat: [context == nil ifFalse: [s cr; print: (context := context sender)]].
			s cr; nextPutAll: '-------------------------------'.
			hasTranscripter
				ifTrue: [
					s cr; nextPutAll: 'Type CR to enter an emergency evaluator.'.
					s cr; nextPutAll: 'Type any other character to restart.']
				ifFalse: [
					s cr; nextPutAll: 'Type any character to restart.']])
		displayAt: 0 @ 0.

	[Sensor keyboardPressed] whileFalse.

	Sensor keyboard = Character cr ifTrue: [
		hasTranscripter ifTrue: [transcripter emergencyEvaluator]].
]

{ #category : #'error recovery' }
Project class >> tryOtherProjectForRecovery: errorMessage [
	"Try entering the parent project if it uses a different user interface. We determine this by comparing the project's class."
	
	| safeProject nextProject |
	nextProject := Project current.
	safeProject := nil.
	"Search parent projects for one of a different type"
	[safeProject notNil or: [nextProject isTopProject]] whileFalse: [
		nextProject := nextProject parent.
		(Project current isKindOf: nextProject class)
			ifFalse: [safeProject := nextProject]].
		
	"September 2019 --- Do not cycle between Morphic and MVC if both break."
	"No suitable parent project found, search all projects for any one of different type."
	"safeProject ifNil: [Smalltalk garbageCollect.
		safeProject := Project allSubInstances
			detect: [:proj | (proj isKindOf: Project current class) not] ifNone: []]."
		
	safeProject ifNotNil: [:p | 
		p enterForEmergencyRecovery.
		"Active process will usually suspend after this."].

]

{ #category : #constants }
Project class >> uiManager [

	^ self current uiManager
]

{ #category : #constants }
Project class >> uiProcess [

	^ self current uiProcess
]

{ #category : #utilities }
Project class >> versionForFileName: version [
	"Project versionForFileName: 7"
	
	^String streamContents:[:s| | v |
		v := version printString.
		v size < 3 ifTrue:[v := '0', v].
		v size < 3 ifTrue:[v := '0', v].
		s nextPutAll: v.
	]

]

{ #category : #resources }
Project >> abortResourceLoading [
	"Abort loading resources"
	resourceManager ifNil:[^self].
	resourceManager stopDownload.
]

{ #category : #'scheduling & debugging' }
Project >> addDeferredUIMessage: valuableObject [ 
	"Arrange for valuableObject to be evaluated at a time when the user interface
	is in a coherent state."

	self subclassResponsibility
]

{ #category : #release }
Project >> addDependent: aMorph [

	"Projects do not keep track of their dependents, lest they point into other projects and thus foul up the tree structure for image segmentation."

	^ self  "Ignore this request"
]

{ #category : #utilities }
Project >> addItem: item toMenu: menu selection: action color: aColor thumbnail: aForm [
	"Add menu item representing the sender to a menu"

	self subclassResponsibility
]

{ #category : #'sub-projects & hierarchy' }
Project >> addProject: aProject [
	"Add the given project as sub-project."
	
	aProject setParent: self.
]

{ #category : #printing }
Project >> addSubProjectNamesTo: aStream indentation: anIndentation [
	"Add the names of the receiver and all its subprojects, and all *their* subprojects recursively, to aStream, indenting by the specified number of tab stops "

	self isTopProject ifFalse:  "circumvent an annoying cr at the top "
		[aStream cr].  
	aStream tab: anIndentation; nextPutAll: self name.
	self subProjects do:
		[:p |
			p addSubProjectNamesTo: aStream indentation: anIndentation + 1]
]

{ #category : #'file in\/out' }
Project >> armsLengthCommand: aCommand withDescription: aString [
	"Set things up so that this aCommand is sent to self as a message
after jumping to the parentProject.  For things that can't be executed
while in this project, such as saveAs, loadFromServer, storeOnServer.  See
ProjectViewMorph step."

	self subclassResponsibility
]

{ #category : #'file in\/out' }
Project >> assureIntegerVersion [
	"For converting the project versions"
	self currentVersionNumber. "Does it for us"
]

{ #category : #'menu messages' }
Project >> assureNavigatorPresenceMatchesPreference [
	"Make sure that the current project conforms to the presence/absence of the navigator"

]

{ #category : #'sub-projects & hierarchy' }
Project >> beTopProject [

	| previousTop |
	self isTopProject ifTrue: [^ self].
	
	previousTop := self class topProject.
	
	self parent deletingProject: self. "Just remove views and refs to me."
	self addProject: previousTop. "The current top project will be my child now."
	self setParent: self. "I am the new top project."
]

{ #category : #editors }
Project >> bitEdit: aForm [
	"Create and schedule a view located in an area designated by the user 
	that contains a view of aForm magnified by 8@8 that can be modified using
	a bit editor. It also contains a view of the original form."

	self subclassResponsibility

]

{ #category : #editors }
Project >> bitEdit: aForm at: magnifiedFormLocation scale: scaleFactor [ 
	"Create and schedule a view whose top left corner is magnifiedLocation 
	and that contains a view of aForm magnified by scaleFactor that  can be
	modified using the Bit Editor. It also contains a view of the original form."

	self subclassResponsibility
]

{ #category : #utilities }
Project >> buildJumpToMenu: menu [
	"Make the supplied menu offer a list of potential projects, consisting of:
		*	The previous-project chain
		*	The next project, if any
		*	The parent project, if any
		*	All projects, alphabetically or hierarchically"

	| prev listed i next |
	listed := OrderedCollection with: self.
	i := 0.

	"The previous Project chain"
	prev := self previousProject.
	[(prev ~~ nil and: [(listed includes: prev) not])] whileTrue:
	  [i := i + 1.
		listed add: prev.
		self 	addItem: prev name , ' (', ('back {1}' translated format:{i}  ), ')'
				toMenu: menu 
				selection: ('%back' , i printString) 
				color: prev color
				thumbnail: prev thumbnail.
		prev := prev previousProject].
	i > 0 ifTrue: [menu addLine].


	"Then the next Project"
	(((next := self nextProject) ~~ nil) and: [(listed includes: next) not]) ifTrue:
		[self	addItem: (next name, ' (', ('forward {1}' translated format:{1}), ')') 
				toMenu: menu 
				selection: next name 
				color: next color
				thumbnail: next thumbnail]. 
	next ~~ nil ifTrue: [menu addLine].

	"Then the parent"
	self isTopProject ifFalse: 
		[self	addItem: self parent name , ' (', 'parent' translated, ')' 
				toMenu: menu 
				selection: #parent 
				color: self parent color
				thumbnail: self parent thumbnail.
		  menu addLine].

	"Finally all the projects, in hierarchical or alphabetical order:"
	(Preferences alphabeticalProjectMenu
			ifTrue:
				[Project allNamesAndProjects]
			ifFalse:
				[Project hierarchyOfNamesAndProjects]) do:

		[:aPair | | toAdd | 
			toAdd := aPair last isCurrentProject
				ifTrue:
				  [aPair first, ' (', 'current' translated, ')']
				ifFalse:
				  [aPair first].
			self	addItem: toAdd 
				toMenu: menu 
				selection: aPair first 
				color: aPair last color
				thumbnail: aPair last thumbnail].
	^ menu
]

{ #category : #'file in\/out' }
Project >> bumpVersion: versionNumber [
	"Make a new version after the previous version number"
	versionNumber ifNil:[^0].
	^versionNumber + 1
]

{ #category : #release }
Project >> canDiscardEdits [
	"Don't regard a window of mine as one to be discarded as part of a 'closeUnchangedWindows' sweep"

	^ false
]

{ #category : #accessing }
Project >> changeSet [
	^ changeSet
]

{ #category : #'sub-projects & hierarchy' }
Project >> children [
	"Answer a list of all the subprojects of the receiver"
	
	| children |
	children := OrderedCollection new.
	Project allProjects do: [ :p | 
		(self == p parent and: [self ~~ p]) ifTrue:
			[ children add: p ]].
	^ children

"
Project topProject children
"
]

{ #category : #language }
Project >> chooseNaturalLanguage [
	"Put up a menu allowing the user to choose the natural language for the project"

	"Project current chooseNaturalLanguage"

	self subclassResponsibility

]

{ #category : #release }
Project >> close [
	"Close and delete this project. Try to trigger the close request through the UI first, do manually of not in the UI."

	self topView
		ifNotNil: [self changed: #close]
		ifNil: [
			self okToClose ifTrue: [
				self windowIsClosing; release]].
]

{ #category : #accessing }
Project >> color [
	"Color representation for this project."
	
	^ Color black
]

{ #category : #utilities }
Project >> composeDisplayTextIntoForm: displayText [
	"Compose the given display text into a form. This is at project level so that UI-specific mechanisms can be used. We may want to make this independent from Morphic or MVC in the future. Good-looking text rendering is good for any user interface."
	
	| port form font width height lines |
	font := displayText textStyle defaultFont.
	lines := displayText string lines.
	
	width := lines
		ifEmpty: [1]
		ifNotEmpty: [(lines collect: [:line | font widthOfString: line]) max].
	height := font height * lines size.
	
	form := Form extent: width@height depth: 32.
	port := BitBlt toForm: form.
	
	"1) Fill background."
	port
		fill: form boundingBox
		fillColor: displayText backgroundColor
		rule: Form over.
	
	"2) Draw text lines."
	port combinationRule: Form paint.
	font
		installOn: port
		foregroundColor: displayText foregroundColor
		backgroundColor: Color transparent.
		
	lines withIndexDo: [:line :index |
		font
			displayString: line
			on: port
			from: 1
			to: line size
			at: 0@((index-1) * font height)
			kern: 0].
	
	^ form
]

{ #category : #'file in\/out' }
Project >> couldBeSwappedOut [

	self flag: #bob.		"need a better test in multi-project world"
	^self isCurrentProject not
]

{ #category : #'file in\/out' }
Project >> currentVersionNumber [

	version ifNil: [^0].
	version isInteger ifTrue:[^version].
	version := Base64MimeConverter decodeInteger: version unescapePercents.
	^version
]

{ #category : #protocols }
Project >> currentVocabulary [
	"Answer the currently-prevailing default vocabulary."

	self subclassResponsibility
]

{ #category : #'scheduling & debugging' }
Project >> debuggerClass [

	^ self subclassResponsibility
]

{ #category : #'file in\/out' }
Project >> decideAboutCreatingBlank: otherProjectName [

	| resp |

	"20 Oct - just do it"
	true "version isNil" ifFalse: [	"if saved, then maybe don't create"
		resp := (UIManager default chooseFrom: #('Yes, make it up' 'No, skip it') 
			title: ('I cannot locate the project\',
				otherProjectName,
				'\Would you like me to create a new project\with that name?'
			) withCRs).
		resp = 1 ifFalse: [^ nil]
	].
	^Project current openBlankProjectNamed: otherProjectName
]

{ #category : #release }
Project >> delete [
	"You should not call this method directly. Call #close instead to make relevant checks first and inform users with interactive dialogs."

	self isTopProject ifTrue: [^ self].

	self isCurrentProject ifTrue: [
		self parent
			addDeferredUIMessage: [self delete];
			enter.
		"Execution stops here."
		Error signal].

	self removeChangeSetIfPossible.

	ProjectHistory forget: self.
	Project deletingProject: self.
]

{ #category : #release }
Project >> deletingProject: outgoingProject [
	"Clear my previousProject link if it points at the given Project, which is being deleted."

	parentProject == outgoingProject
		ifTrue: [parentProject := parentProject parent].
	
	previousProject == outgoingProject
		ifTrue: [previousProject := previousProject previousProject].
	previousProject == outgoingProject
		ifTrue: [previousProject := nil].
	
	nextProject == outgoingProject
		ifTrue: [nextProject := nextProject nextProject].
	nextProject == outgoingProject
		ifTrue: [nextProject := nil].
]

{ #category : #'active process' }
Project >> depth [
	"Return the depth of this project from the top.
	 topProject = 0, next = 1, etc."
	"Project current depth."

	| depth project |
	depth := 0.
	project := self.
	
	[project class == DiskProxy ifTrue: [^ depth].
	 project isTopProject]
		whileFalse:
			[project := project parent.
			depth := depth + 1].
	^ depth
]

{ #category : #accessing }
Project >> displayDepth [
	^ displayDepth
]

{ #category : #accessing }
Project >> displayDepth: newDepth [
	displayDepth := newDepth
]

{ #category : #displaying }
Project >> displayDepthChanged [
	"The depth of the display has changed."
	
]

{ #category : #displaying }
Project >> displaySizeChanged [
	"Inform the current project that its display size has changed. Usually, projects invalidate all their drawing caches and restore their graphical contents."

	self invalidate; restore.
]

{ #category : #transcripter }
Project >> displayTranscripter: transcripter [
	"A transcripter is a minimal user interface to support an emergency evaluator.
	Different kinds of project may use different paragraph implementations."
	self subclassResponsibility
]

{ #category : #displaying }
Project >> displayZoom: entering [
	"Show the project transition when entering a new project"
	| newDisplay vanishingPoint |
	"Play the flash transition if any."
	self projectParameters at: #flashTransition ifPresent:[:dict|
		dict at: CurrentProject ifPresent:[:player| ^player playProjectTransitionFrom: CurrentProject to: self entering: entering]].
	"Show animated zoom to new display"
	newDisplay := self imageForm.
	entering
		ifTrue: [vanishingPoint := Sensor cursorPoint]
		ifFalse: [vanishingPoint := self viewLocFor: CurrentProject].
	Display zoomIn: entering orOutTo: newDisplay at: 0@0
			vanishingPoint: vanishingPoint.
]

{ #category : #utilities }
Project >> do: aBlock withProgressInfoOn: aMorphOrNil label: aString [
	"Evaluate aBlock with a labeled progress bar"

	self subclassResponsibility


]

{ #category : #'file in\/out' }
Project >> doArmsLengthCommand: aCommand [

	"We are no longer the active project, so do it"

	[self perform: aCommand]
		ensure: [self enter: #specialReturn.	"re-enter me and forget the temp project"]


]

{ #category : #'menu messages' }
Project >> doWeWantToRename [

	| want |

	self hasBadNameForStoring ifTrue: [^true].
	(self name beginsWith: 'Unnamed' translated) ifTrue: [^true].
	want := world valueOfProperty: #SuperSwikiRename ifAbsent: [false].
	world removeProperty: #SuperSwikiRename.
	^want


]

{ #category : #'file in\/out' }
Project >> downloadUrl [
	"^(self primaryServerIfNil: [^'']) downloadUrl"
	^lastDirectory
		ifNil: [(self primaryServerIfNil: [^'']) downloadUrl]
		ifNotNil: [lastDirectory downloadUrl]
]

{ #category : #editors }
Project >> editCharacter: character ofFont: strikeFont [
	"Open a bit editor on a character in the given strike font."

	self subclassResponsibility 
]

{ #category : #'file in\/out' }
Project >> ensureChangeSetNameUnique [

	| myName |

	myName := self name.
	Project allProjects do: [:pp | 
		pp == self ifFalse: [
			(pp name = myName and: [pp projectChangeSet ~~ changeSet]) ifTrue: [
				(pp parameterAt: #loadingNewerVersion ifAbsent: [false]) ifTrue: [
					pp projectParameters at: #loadingNewerVersion put: false.
				] ifFalse: [
					changeSet ifNil: [^ changeSet := ChangeSet new].
					^changeSet name: (ChangeSet uniqueNameLike: myName)
				].
			]
		]
	]

]

{ #category : #enter }
Project >> enter [
	"Enter the new project"
	self enter: (CurrentProject parent == self) revert: false saveForRevert: false.
]

{ #category : #enter }
Project >> enter: returningFlag [	
	self enter: returningFlag revert: false saveForRevert: false
]

{ #category : #enter }
Project >> enter: returningFlag revert: revertFlag saveForRevert: saveForRevert [
	"Install my ChangeSet, Transcript, and scheduled views as current globals. If returningFlag is true, we will return to the project from whence the current project was entered; don't change its previousProject link in this case.
	If saveForRevert is true, save the ImageSegment of the project being left.
	If revertFlag is true, make stubs for the world of the project being left.
	If revertWithoutAsking is true in the project being left, then always revert."

	| leavingProject forceRevert response seg |

	self isIncompletelyLoaded
		ifTrue: [^ self loadFromServer: true].
	self isCurrentProject
		ifTrue: [^ self].
	
	EmergencyRecoveryRequested := false. "normal project entry clears recursion guard"
	forceRevert := false.
	CurrentProject rawParameters 
		ifNil: [revertFlag ifTrue: [^ self inform: 'nothing to revert to' translated]]
		ifNotNil: [saveForRevert ifFalse: [
				forceRevert := CurrentProject projectParameters 
								at: #revertWithoutAsking ifAbsent: [false]]].
	forceRevert not & revertFlag ifTrue: [
		response := (UIManager default chooseFrom: {
			'Revert to saved version' translated.
			'Cancel' translated.
		} title: 'Are you sure you want to destroy this Project\ and revert to an older version?\\(From the parent project, click on this project''s thumbnail.)' translated withCRs) = 1.
		response ifFalse: [^ self]].

	revertFlag | forceRevert 
		ifTrue: [seg := CurrentProject projectParameters at: #revertToMe ifAbsent: [
					^ self inform: 'nothing to revert to' translated]]
		ifFalse: [
			CurrentProject makeThumbnail.
			returningFlag == #specialReturn
				ifTrue:
					[ProjectHistory forget: CurrentProject.		"this guy is irrelevant"
					Project forget: CurrentProject]
				ifFalse:
					[ProjectHistory remember: CurrentProject]].

	(revertFlag | saveForRevert | forceRevert) ifFalse: [
		(Preferences valueOfFlag: #projectsSentToDisk)
			ifTrue: [
				self inform: 'Project serialization via image segments\does not work at the moment. Disabling the\preference #projectsSentToDisk now...' withCRs.
				Preferences disable: #projectsSentToDisk.
				"self storeToMakeRoom"]].

	"Update display depth for leaving and entring project."
	CurrentProject displayDepth: Display depth.
	displayDepth == nil ifTrue: [displayDepth := Display depth].
	self installNewDisplay: Display extent depth: displayDepth.

	returningFlag == #specialReturn ifTrue: [
		CurrentProject removeChangeSetIfPossible.	"keep this stuff from accumulating"
		nextProject := nil
	] ifFalse: [
		returningFlag
			ifTrue: [nextProject := CurrentProject]
			ifFalse: [previousProject := CurrentProject].
	].

	CurrentProject world triggerEvent: #aboutToLeaveWorld.
	CurrentProject abortResourceLoading.
	CurrentProject finalExitActions: self.
	CurrentProject saveState.
	
	"********** SWITCHING CURRENT PROJECT **********"
	leavingProject := CurrentProject.
	CurrentProject := self.
	ProjectHistory remember: self.
	"********** SWITCHING CURRENT PROJECT **********"

	self loadState.
	self finalEnterActions: leavingProject.
	self addDeferredUIMessage: [self startResourceLoading].
	self world triggerEvent: #aboutToEnterWorld.

	"Save project for revert."
	saveForRevert ifTrue: [
		Smalltalk garbageCollect.	"let go of pointers"
		leavingProject storeSegment.
		"result :=" leavingProject world isInMemory 
			ifTrue: ['Can''t seem to write the project.']
			ifFalse: [leavingProject projectParameters at: #revertToMe put: 
					leavingProject world xxxSegment shallowCopy].
				'Project written.'].
			"original is for coming back in and continuing."
	revertFlag | forceRevert ifTrue: [
		seg shallowCopy revert].	"non-cloned one is for reverting again later"
	self removeParameter: #exportState.
	
	"Now that everything is set up, we can show zoom animation."
	(self showZoom and: [leavingProject displayDepth = self displayDepth])
		ifTrue: [self displayZoom: leavingProject parent ~~ self "Entering?"]
		ifFalse: [self restore].
	
	"Update processes at last."
	self scheduleProcessForEnter.
	leavingProject terminateProcessForLeave.

]

{ #category : #'enter - recovery' }
Project >> enterForEmergencyRecovery [
	"Stripped down verion of #enter:revert:saveForRevert:. More error handling. Less features."
	
	| leavingProject process titleForDebuggerWindow |
	self isCurrentProject ifTrue: [^ self].
	EmergencyRecoveryRequested == true ifTrue: [^ self].
	EmergencyRecoveryRequested := true. "set recursion guard"

	titleForDebuggerWindow := 'FATAL PROJECT ERROR: Project was ''', CurrentProject name, ''''.
	ProjectHistory remember: CurrentProject.
	nextProject := CurrentProject.
	
	[ CurrentProject world triggerEvent: #aboutToLeaveWorld.
	CurrentProject abortResourceLoading.
	CurrentProject finalExitActions: self.
	CurrentProject saveState ] on: Error do: [:ex | "Ignore." ].
	
	"********** SWITCHING CURRENT PROJECT **********"
	leavingProject := CurrentProject.
	CurrentProject := self.
	ProjectHistory remember: self.
	"********** SWITCHING CURRENT PROJECT **********"

	self loadState.
	self finalEnterActions: leavingProject.
	self addDeferredUIMessage: [self startResourceLoading].
	self world triggerEvent: #aboutToEnterWorld.
	
	"Now that everything is set up, we can show zoom animation.
	Do we really need this in case of an emergency?"
	self showZoom
		ifTrue: [self displayZoom: leavingProject parent ~~ self "Entering?"]
		ifFalse: [self restore].
	
	"Update processes at last."
	self scheduleProcessForEnter.
	
	"Do not terminate but suspend the projects ui process to support debugging."
	process := leavingProject uiProcess.
	self addDeferredUIMessage: [process debugWithTitle: titleForDebuggerWindow].
	leavingProject suspendProcessForDebug.
]

{ #category : #'squeaklet on server' }
Project >> enterIfThereOrFind: aProjectName [

	self subclassResponsibility

]

{ #category : #'menu messages' }
Project >> exit [
	"Leave the current project and return to the project in which this one was created."

	self isTopProject ifTrue: [^ self inform: 'Can''t exit the top project' translated].
	parentProject enter: false revert: false saveForRevert: false.

]

{ #category : #'file in\/out' }
Project >> exportSegmentFileName: aFileName directory: aDirectory [

	^ self exportSegmentFileName: aFileName directory: aDirectory withoutInteraction: false
]

{ #category : #'file in\/out' }
Project >> exportSegmentFileName: aFileName directory: aDirectory withoutInteraction: noInteraction [

	| exportChangeSet |

	"An experimental version to fileout a changeSet first so that a project can contain its own classes"

	"Store my project out on the disk as an *exported* ImageSegment.  Put all outPointers in a form that can be resolved in the target image.  Name it <project name>.extSeg.
	Player classes are included automatically."
	exportChangeSet := nil.
	(changeSet notNil and: [changeSet isEmpty not]) ifTrue: [
		(noInteraction or: [self confirm: 
	'Would you like to include all the changes in the change set
	as part of this publishing operation?' translated]) ifTrue: [
				exportChangeSet := changeSet
		].
	].

	Project publishInSexp ifTrue: [
		^ self exportSegmentInSexpWithChangeSet: exportChangeSet fileName: aFileName directory: aDirectory withoutInteraction: noInteraction
	].
	^ self 
		exportSegmentWithChangeSet: exportChangeSet
		fileName: aFileName 
		directory: aDirectory
		withoutInteraction: noInteraction
]

{ #category : #'file in\/out' }
Project >> exportSegmentInSexpWithChangeSet: aChangeSetOrNil fileName: aFileName directory: aDirectory withoutInteraction: noInteraction [

	self subclassResponsibility
]

{ #category : #'file in\/out' }
Project >> exportSegmentWithCatagories: catList classes: classList fileName: aFileName directory: aDirectory [
	"Store my project out on the disk as an *exported* ImageSegment.  All outPointers will be in a form that can be resolved in the target image.  Name it <project name>.extSeg.  What do we do about subProjects, especially if they are out as local image segments?  Force them to come in?
	Player classes are included automatically."

	self flag: #toRemove.
	self subclassResponsibility

]

{ #category : #'file in\/out' }
Project >> exportSegmentWithChangeSet: aChangeSetOrNil fileName: aFileName
directory: aDirectory [
	"Store my project out on the disk as an *exported*
ImageSegment.  All outPointers will be in a form that can be resolved
in the target image.  Name it <project name>.extSeg.  Whatdo we do
about subProjects, especially if they are out as local image
segments?  Force them to come in?
	Player classes are included automatically."

	self subclassResponsibility
]

{ #category : #'menu messages' }
Project >> fileOut [
	changeSet fileOut
]

{ #category : #enter }
Project >> finalEnterActions: leavingProject [


]

{ #category : #enter }
Project >> finalExitActions: enteringProject [

	SoundService stop.
]

{ #category : #utilities }
Project >> findAFolderForProject: aProject label: dialogLabel [
	"Find a folder for saving or loading a project"

	self subclassResponsibility

]

{ #category : #'file in\/out' }
Project >> findAFolderToLoadProjectFrom [

	^ CurrentProject findAFolderForProject: self label: 'Select a folder on a server:'

]

{ #category : #'file in\/out' }
Project >> findAFolderToStoreProjectIn [

	^ CurrentProject findAFolderForProject: self label: 'Select a folder on a server:'

]

{ #category : #accessing }
Project >> findProjectView: projectDescription [
	"In this world, find the morph that holds onto the project described by projectDescription.
	projectDescription can be a project, or the name of a project.  The project may be
	represented by a DiskProxy.  The holder morph may be at any depth in the world.
	Need to fix this if Projects have subclasses, or if a class other than ProjectViewMorph
	can officially hold onto a project.  (Buttons, links, etc)
	If parent is an MVC world, return the ProjectController."

	self flag: #bob.		"read the comment"
	self subclassResponsibility
]

{ #category : #'flaps support' }
Project >> flapsSuppressed [
	"Answer whether flaps are suppressed in this project"

	^ self showSharedFlaps not
]

{ #category : #'flaps support' }
Project >> flapsSuppressed: aBoolean [
	"Make the setting of the flag that governs whether global flaps are suppressed in the project be as indicated and add or remove the actual flaps"

	self projectPreferenceFlagDictionary at: #showSharedFlaps put: aBoolean not.
	self == Project current 
		ifTrue: "Typical case"
			[Preferences setPreference: #showSharedFlaps toValue: aBoolean not]

]

{ #category : #release }
Project >> forget [

	self isCurrentProject
		ifTrue: [^ Error signal: 'Cannot forget the current project.'].

	self class forget: self.
]

{ #category : #accessing }
Project >> forgetExistingURL [
	self resourceManager makeAllProjectResourcesLocalTo: self resourceUrl.
	urlList := nil
]

{ #category : #editors }
Project >> formEdit: aForm [
	"Start up an instance of the form editor on a form."
 
	self subclassResponsibility
]

{ #category : #editors }
Project >> formViewClass [
	"Answer a class suitable for a view on a form or collection of forms"

	self subclassResponsibility
]

{ #category : #'file in\/out' }
Project >> fromMyServerLoad: otherProjectName [
	| pair pr dirToUse |
	"If a newer version of me is on the server, load it."

	(pr := Project named: otherProjectName) ifNotNil: ["it appeared"
		^ pr enter
	].

	dirToUse := self primaryServerIfNil: [
		lastDirectory
			ifNil: [FileDirectory default]
			ifNotNil: [lastDirectory]].

	pair := self class mostRecent: otherProjectName onServer: dirToUse.
	pair first ifNil: [^self decideAboutCreatingBlank: otherProjectName].	"nothing to load"
	^ProjectLoading
		installRemoteNamed: pair first
		from: dirToUse
		named: otherProjectName
		in: self


]

{ #category : #futures }
Project >> future: receiver do: aSelector at: deltaMSecs args: args [
	"Send a message deltaSeconds into the future.  No response is expected."
	| msg |
	msg := MessageSend receiver: receiver selector: aSelector arguments: args.
	deltaMSecs = 0 
		ifTrue: [self addDeferredUIMessage: msg]
		ifFalse: [
			[	(Delay forMilliseconds: deltaMSecs) wait.
				self addDeferredUIMessage: msg.
			] forkAt: Processor userSchedulingPriority + 1.
		]..
	^nil
]

{ #category : #futures }
Project >> future: receiver send: aSelector at: deltaMSecs args: args [
	"Send a message deltaSeconds into the future.  Answers a Promise that will be resolved at some time in the future."
	| pr closure |
	pr := Promise new.
	closure := [pr fulfillWith: [receiver perform: aSelector withArguments: args]].
	deltaMSecs = 0
		ifTrue: [self addDeferredUIMessage: closure]
		ifFalse: [
			[	(Delay forMilliseconds: deltaMSecs) wait.
				self addDeferredUIMessage: 
					closure
			] forkAt: Processor userSchedulingPriority + 1.
		].
	^pr
		
]

{ #category : #'file in\/out' }
Project >> hasBadNameForStoring [

	^Project isBadNameForStoring: self name

]

{ #category : #'file in\/out' }
Project >> htmlPagePrototype [
	"Return the HTML page prototype"
^'<html>
<head>
<title>Squeak Project</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>

<body bgcolor="#FFFFFF">
<EMBED 
	type="application/x-squeak-source"
	ALIGN="CENTER"
	WIDTH="$$WIDTH$$"
	HEIGHT="$$HEIGHT$$"
	src="$$PROJECT$$"
	pluginspage="http://www.squeakland.org/download/">

</EMBED>

</body>
</html>
'
]

{ #category : #displaying }
Project >> imageForm [
	^self imageFormOfSize: Display extent
		depth: (displayDepth ifNil:[Display depth])
]

{ #category : #displaying }
Project >> imageFormOfSize: extentPoint depth: d [
	
	| currentDisplay temporaryDisplay |
	currentDisplay := Display.
	temporaryDisplay := DisplayScreen extent: extentPoint depth: d.	
	[Display := temporaryDisplay. self invalidate; restore]
		ensure: [Display := currentDisplay].
	^ temporaryDisplay
]

{ #category : #initialization }
Project >> initialExtent [
	^ (Display extent // 6) + (0@17)
]

{ #category : #initialization }
Project >> initialProject [
	self saveState.
	parentProject := self.
	previousProject := nextProject := nil
]

{ #category : #initialization }
Project >> initialize [
	"Initialize the project, seting the CurrentProject as my parentProject and initializing my project preferences from those of the CurrentProject"
	Project addingProject: self.
	changeSet := ChangeSet new.
	transcript := TranscriptStream new.
	displayDepth := Display depth.
	parentProject := CurrentProject.
	self initializeProjectPreferences

]

{ #category : #transcripter }
Project >> initializeParagraphForTranscripter: transcripter [
	"A transcripter is a minimal user interface to support an emergency evaluator.
	Different kinds of project may use different paragraph implementations."
	self subclassResponsibility
]

{ #category : #'project parameters' }
Project >> initializeProjectParameters [
	"Initialize the project parameters."

	projectParameters := IdentityDictionary new.
	^ projectParameters
]

{ #category : #'project parameters' }
Project >> initializeProjectPreferences [
	"Initialize the project's preferences from currently-prevailing preferences that are currently being held in projects in this system"
	
	projectPreferenceFlagDictionary := Project current projectPreferenceFlagDictionary deepCopy.    "Project overrides in the new project start out being the same set of overrides in the calling project"

	Preferences allPreferences do:  "in case we missed some"
		[:aPreference |
			aPreference localToProject ifTrue:
				[(projectPreferenceFlagDictionary includesKey: aPreference name) ifFalse:
			[projectPreferenceFlagDictionary at: aPreference name put: aPreference preferenceValue]]].

	(Project current projectParameterAt: #disabledGlobalFlapIDs  ifAbsent: [nil]) ifNotNil:
		[:idList | self projectParameterAt: #disabledGlobalFlapIDs put: idList copy]

]

{ #category : #initialization }
Project >> installNewDisplay: extent depth: depth [
	"When entering a new project, install a new Display if necessary."
	Display setExtent: extent depth: depth.
	Display beDisplay.
]

{ #category : #'menu messages' }
Project >> installProjectPreferences [
	"Install the settings of all preferences presently held individually by projects in the receiver's projectPreferenceFlagDictionary"

	
	Preferences allPreferences do:
		[:aPreference | | localValue | 
			aPreference localToProject ifTrue:
				[localValue := self projectPreferenceFlagDictionary at: aPreference name ifAbsent: [nil].
				localValue ifNotNil:
					[aPreference rawValue: localValue]]]
]

{ #category : #'scheduling & debugging' }
Project >> interruptCleanUpFor: interruptedProcess [
	"Clean up things in case of a process interrupt."
]

{ #category : #'scheduling & debugging' }
Project >> interruptName: labelString [
	"Create a Notifier on the active scheduling process with the given label."

	^ self
		interruptName: labelString
		message: nil
		preemptedProcess: nil
]

{ #category : #'scheduling & debugging' }
Project >> interruptName: labelString message: aMessage [
	"Create a Notifier on the active scheduling process with the given label."

	^ self
		interruptName: labelString
		message: aMessage
		preemptedProcess: nil
]

{ #category : #'scheduling & debugging' }
Project >> interruptName: labelString message: aMessage preemptedProcess: theInterruptedProcess [
	"Create a Notifier on the active scheduling process with the given label."

	| preemptedProcess projectProcess |
	projectProcess := self uiProcess.
	preemptedProcess := theInterruptedProcess ifNil: [Processor preemptedProcess].
	
	"Only debug preempted process if its priority is >= projectProcess' priority"
	preemptedProcess priority < projectProcess priority 
		ifTrue:[preemptedProcess := projectProcess].

	"Give projects a change to clean up."
	self interruptCleanUpFor: preemptedProcess.

	^ preemptedProcess debugWithTitle: labelString full: false contents: aMessage
]

{ #category : #'scheduling & debugging' }
Project >> interruptName: labelString preemptedProcess: theInterruptedProcess [
	
	self
		interruptName: labelString
		message: nil
		preemptedProcess: theInterruptedProcess.
]

{ #category : #displaying }
Project >> invalidate [
	"Invalidate the entire project so that a redraw will be forced later."
	^self subclassResponsibility
]

{ #category : #testing }
Project >> isCurrentProject [

	^self == CurrentProject
]

{ #category : #testing }
Project >> isIncompletelyLoaded [
	"Answer true if project is incomplete and should be loaded from server "

	^ false
]

{ #category : #testing }
Project >> isMorphic [

	self flag: #moveEventually. "mt: Once we manage to remove all calls to this from outside the Morphic package, we can add this as an extension of Morphic to Project."
	^ false
]

{ #category : #'sub-projects & hierarchy' }
Project >> isTopProject [
	"Return true only if this is the top project (its own parent).
	Also include the test here for malformed project hierarchy."

	parentProject == self ifTrue: [^ true].
	parentProject == nil ifTrue: [self error: 'No project should have a nil parent'].
	^ false
]

{ #category : #utilities }
Project >> jumpToProject [
	"Present a list of potential projects and enter the one selected."

	"Project current jumpToProject"

	self subclassResponsibility
]

{ #category : #utilities }
Project >> jumpToSelection: selection [
	"Enter the project corresponding to this menu selection."
	
	"Project jumpToProject"
	| nBack prev pr |
	selection ifNil: [^ self].
	(selection beginsWith: '%back') ifTrue:
		[nBack := (selection copyFrom: 6 to: selection size) asNumber.
		prev := CurrentProject previousProject.
		1 to: nBack-1 do:
			[:i | prev ifNotNil: [prev := prev previousProject]].
		prev ifNotNil: [prev enter: true revert: false saveForRevert: false]].
	selection = #parent ifTrue:
		[CurrentProject parent enter: false revert: false saveForRevert: false.
		^ self].
	(pr := Project namedWithDepth: selection) ifNil: [^ self].
	pr enter: false revert: false saveForRevert: false
]

{ #category : #accessing }
Project >> labelString [
	^ changeSet name
]

{ #category : #'scheduling & debugging' }
Project >> lastDeferredUIMessage [
	"Answer the most recently scheduled deferredUIMessage."

	self subclassResponsibility
]

{ #category : #accessing }
Project >> lastDirectory: aDirectoryOrNil [
	lastDirectory := aDirectoryOrNil
]

{ #category : #accessing }
Project >> lastSavedAtSeconds [

	^lastSavedAtSeconds
]

{ #category : #'sub-projects & hierarchy' }
Project >> liftSubProjects [
	"Lift my sub-projects to my parent project."
	
	self parent ifNil: [^ Error signal: 'Cannot lift sub-project because I have to parent.'].
	
	self subProjects do: [:ea | self parent addProject: ea].
]

{ #category : #'file in\/out' }
Project >> loadFromServer [
	
	^self loadFromServer: false
]

{ #category : #'file in\/out' }
Project >> loadFromServer: newerAutomatically [
	"If a newer version of me is on the server, load it."
	| pair resp server |
	self assureIntegerVersion.

	self isCurrentProject ifTrue: ["exit, then do the command"
		^ self armsLengthCommand: #loadFromServer withDescription: 'Loading' translated
	].
	server := self tryToFindAServerWithMe ifNil: [^ nil].
	pair := self class mostRecent: self name onServer: server.
	pair first ifNil: [^ self inform: ('can''t find file on server for {1}' translated format: {self name})].
	self currentVersionNumber > pair second ifTrue: [
		^ self inform: ('That server has an older version of the project.' translated)].
	version = (Project parseProjectFileName: pair first) second ifTrue: [
		resp := (UIManager default chooseFrom: 
				(Array with: 'Reload anyway' translated 
						with: 'Cancel' translated withCRs) 
				title:  'The only changes are the ones you made here.' translated).
		resp ~= 1 ifTrue: [^ nil]
	] ifFalse: [
		newerAutomatically ifFalse: [
			resp := (UIManager default 
						chooseFrom: #('Load it' 'Cancel') 
						title:  'A newer version exists on the server.').
			resp ~= 1 ifTrue: [^ nil]
		].
	].

	"let's avoid renaming the loaded change set since it will be replacing ours"
	self projectParameters at: #loadingNewerVersion put: true.

	CurrentProject
		do: [ProjectLoading
				installRemoteNamed: pair first
				from: server
				named: self name
				in: parentProject]
		withProgressInfoOn: nil
		label: 'project loading'

]

{ #category : #enter }
Project >> loadState [	

	self installProjectPreferences.
	ChangeSet  newChanges: changeSet.
	thumbnail ifNotNil: [:form | form unhibernate].
	TranscriptStream newTranscript: transcript.

]

{ #category : #language }
Project >> localeChanged [
	"Set the project's natural language as indicated"
	self projectParameterAt: #localeID put: LocaleID current.
	self updateLocaleDependents
]

{ #category : #language }
Project >> localeID [
	"Answer the natural language for the project"

	
	^ self projectParameterAt: #localeID
		ifAbsentPut: [ | prev |
			(prev := self previousProject)
				ifNotNil: [prev projectParameterAt: #localeID ifAbsent: [LocaleID current]]
				ifNil: [LocaleID current]]
]

{ #category : #'menu messages' }
Project >> makeThumbnail [
	"Make a thumbnail image of this project from the Display."

	^ thumbnail := self previewImageForm
]

{ #category : #accessing }
Project >> name [
	changeSet == nil ifTrue: [^ 'no name'].
	^ changeSet name
]

{ #category : #accessing }
Project >> nameAdjustedForDepth [
	"Answer the name of the project, prepended with spaces reflecting the receiver's depth from the top project"
	"	Project current nameAdjustedForDepth	"

	| stream |
	stream := WriteStream on: String new.
	self depth timesRepeat: 
	  [2 timesRepeat: [stream nextPut: $ ]].
	stream nextPutAll: self name.
	^ stream contents
]

{ #category : #language }
Project >> naturalLanguage [
	"Answer the natural language for the project"
	^ self localeID displayName
]

{ #category : #accessing }
Project >> nextProject [
	^ nextProject

]

{ #category : #displaying }
Project >> noDisplayDuring: block [
	"Projects can provide means to bypass screen updates so that graphics code can be updated safely."
]

{ #category : #'project parameters' }
Project >> noteThatParameter: prefSymbol justChangedTo: aBoolean [
	"Provides a hook so that a user's toggling of a project parameter might precipitate some immediate action"


]

{ #category : #'file in\/out' }
Project >> objectForDataStream: refStrm [
	| uu dp |
	"I am about to be written on an object file.  Write a path to me in the other system instead."

	"Use a copy with no parent, previous or next to reduce extra stuff copied"
	refStrm project == self ifTrue: [^ self copy setParent: nil].

	dp := (uu := self url) size > 0 ifTrue: [
		DiskProxy global: #Project selector: #namedUrl: args: {uu}.
	] ifFalse: [
		DiskProxy global: #Project selector: #named: args: {self name}
	].
	refStrm replace: self with: dp.
	^ dp

]

{ #category : #utilities }
Project >> offerMenu: menuSelector from: aModel shifted: aBoolean [
	"Pop up a menu whose target is aModel and whose contents are provided
	by sending the menuSelector to the model. The menuSelector takes two
	arguments: a menu, and a boolean representing the shift state."

	self subclassResponsibility
]

{ #category : #release }
Project >> okToChange [
	"Answer whether the window in which the project is housed can be dismissed -- which is destructive. We never clobber a project without confirmation"

	| answer |
	(self isCurrentProject and: [self isTopProject]) ifTrue: [
		self inform: 'You cannot close the top project.'.
		^ false].
	
	(self confirm: ('Do you really want to delete the project\{1}\and all its content?' withCRs translated format:{self name}))
		ifFalse: [^ false].

	self subProjects ifNotEmpty: [:sp |
		answer := Project uiManager
			chooseFrom: #(
				"1" 'Lift all sub-projects'
				"2" 'Discard all sub-projects (NO UNDO!)'
				"3 or 0" 'Cancel')
			lines: #(2)
			title: ('The project {1}\contains {2} sub-project(s).' withCRs translated format:{self name. sp size}).
		
		(answer = 0 or: [answer = 3]) ifTrue: [^ false].
		answer = 1 ifTrue: [self liftSubProjects. ^ true].
		answer = 2 ifTrue: [^ sp allSatisfy: [:ea | 
				[ea okToChange] valueSuppressingMessages: {'*delete the project*and all its content*'}]]].
	
	^ true
]

{ #category : #'squeaklet on server' }
Project >> openBlankProjectNamed: projName [

	"Project current openBlankProjectNamed: 'My new project'"

	self subclassResponsibility

]

{ #category : #editors }
Project >> openImage: aForm name: fullName saveResource: aBoolean [
	"Open a view on an image. If aBoolean is true, save the image as a project resource."

	self subclassResponsibility
]

{ #category : #initialization }
Project >> openProject: aProject [
	"Create a new for a new project in the context of the receiver"
	^self subclassResponsibility
]

{ #category : #'project parameters' }
Project >> parameterAt: aSymbol [
	^self parameterAt: aSymbol ifAbsent:[nil]
]

{ #category : #'project parameters' }
Project >> parameterAt: aSymbol ifAbsent: aBlock [
	projectParameters ifNil:[^aBlock value].
	^projectParameters at: aSymbol ifAbsent: aBlock
]

{ #category : #'sub-projects & hierarchy' }
Project >> parent [
	^ parentProject
]

{ #category : #utilities }
Project >> pointerMoved [
	"Pointer has moved during a drag operation. Perform any necessary updates."

	^ self
]

{ #category : #release }
Project >> prepareForDelete [
	"The window in which the project is housed is about to deleted. Perform
	any necessary actions to prepare for deletion. For an MVC project, no
	action is required."

]

{ #category : #displaying }
Project >> previewImageForm [

	^ self imageForm scaledToSize: self viewSize
]

{ #category : #accessing }
Project >> previousProject [
	^ previousProject

]

{ #category : #'file in\/out' }
Project >> primaryServer [
	"Return my primary server, that is the one I was downloaded from or are about to be stored on."
	^self primaryServerIfNil: [nil]
]

{ #category : #'file in\/out' }
Project >> primaryServerIfNil: aBlock [
	"Return my primary server, that is the one I was downloaded from or are about to be stored on. If none is set execute the exception block"
	| serverList | 
	serverList := self serverList.
	^serverList isEmptyOrNil
		ifTrue: [aBlock value]
		ifFalse: [serverList first]
]

{ #category : #'scheduling & debugging' }
Project >> primitiveError: errorMessage [
	"System error handling has failed. Try something else to keep the system alive."

	Project tryOtherProjectForRecovery: errorMessage.
	Project tryEmergencyEvaluatorForRecovery: errorMessage.
	
	self restoreDisplay.
]

{ #category : #printing }
Project >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' (', self name, ') in '.
	world printOn: aStream

]

{ #category : #accessing }
Project >> projectChangeSet [
	^ changeSet
]

{ #category : #'file in\/out' }
Project >> projectExtension [
	^self class projectExtension
]

{ #category : #'project parameters' }
Project >> projectParameterAt: aSymbol [
	"Answer the project parameter stored at the given symbol, or nil if none"

	^ self projectParameters at: aSymbol ifAbsent: [nil]
]

{ #category : #'project parameters' }
Project >> projectParameterAt: aSymbol ifAbsent: aBlock [
	"Answer the project parameter stored at the given symbol, or the result of evaluating the block"

	^ self projectParameters at: aSymbol ifAbsent: aBlock
]

{ #category : #'project parameters' }
Project >> projectParameterAt: aKey ifAbsentPut: defaultValueBlock [
	"Return the project parameter setting at the given key.  If there is no entry for this key in the Parameters dictionary, create one with the value of defaultValueBlock as its value"

	^ self projectParameters at: aKey ifAbsentPut: defaultValueBlock
]

{ #category : #'project parameters' }
Project >> projectParameterAt: aSymbol put: aValue [
	"Set the given project parameter to the given value"

	self projectParameters at: aSymbol put: aValue.
	self noteThatParameter: aSymbol justChangedTo: aValue.
	^ aValue
]

{ #category : #'project parameters' }
Project >> projectParameters [
	^ projectParameters ifNil: [self initializeProjectParameters]
]

{ #category : #'project parameters' }
Project >> projectPreferenceAt: aSymbol [
	"Answer the project preference stored at the given symbol.  If there is none in the local preference dictionary, it must be because it was only latterly declared to be a project-local preference, so obtain its initial value instead from the last-known global or default setting"

	
	^ self projectPreferenceAt: aSymbol ifAbsent: 
		[ | aValue |
		aValue := Preferences valueOfFlag: aSymbol.
		self projectPreferenceFlagDictionary at: aSymbol put: aValue.
		^ aValue]
]

{ #category : #'project parameters' }
Project >> projectPreferenceAt: aSymbol ifAbsent: aBlock [
	"Answer the project preference stored at the given symbol, or the result of evaluating the block"

	^ self projectPreferenceFlagDictionary at: aSymbol ifAbsent: aBlock
]

{ #category : #'project parameters' }
Project >> projectPreferenceFlagDictionary [
	"Answer the dictionary that holds the project preferences, creating it if necessary"

	^ projectPreferenceFlagDictionary ifNil: [projectPreferenceFlagDictionary := IdentityDictionary new]
]

{ #category : #'project parameters' }
Project >> rawParameters [
	^ projectParameters
]

{ #category : #'scheduling & debugging' }
Project >> recursiveError: errorMessage [
	"This method is called when the error handling results in a recursion in calling on error: or halt or halt:, which basically means that the debugger cannot be opened."

	self primitiveError: errorMessage.
]

{ #category : #release }
Project >> release [

	self delete.

	world == nil ifFalse: [
		world release.
		world := nil].

	^ super release
]

{ #category : #shrinking }
Project >> removeAllOtherProjects [
	"Remove all other projects from the system, and set the current project as the root
	project. This method was originally implemented as SmalltalkImage>>zapAllOtherProjects
	in earlier versions of Squeak."

	"Project current removeAllOtherProjects"

	Project current == self ifFalse: [
		^ self
			addDeferredUIMessage: [self removeAllOtherProjects];
			enter].
	
	self beTopProject.

	Project rebuildAllProjects.  "Does a GC"
	Project allProjects do: [:p | p == Project current ifFalse: [p delete]].
		
	TheWorldMenu allInstancesDo: [:m | 1 to: m class instSize do: [:i | m instVarAt: i put: nil]].
	ChangeSet classPool at: #AllChangeSets put: nil.
	ProjectHistory currentHistory initialize.
	CommandHistory resetAllHistory.
	ChangeSet initialize.

	self assert: Project current == self.
]

{ #category : #release }
Project >> removeChangeSetIfPossible [

	| itsName |

	changeSet ifNil: [^self].
	changeSet isEmpty ifFalse: [^self].
	(changeSet projectsBelongedTo copyWithout: self) isEmpty ifFalse: [^self].
	itsName := changeSet name.
	ChangeSet removeChangeSet: changeSet.
	"Transcript cr; show: 'project change set ', itsName, ' deleted.'"

]

{ #category : #'project parameters' }
Project >> removeParameter: aKey [
	projectParameters ifNil:[^self].
	projectParameters removeKey: aKey ifAbsent:[].
]

{ #category : #accessing }
Project >> renameTo: newName [
	| oldBase |
	newName = self name
		ifFalse: [
			oldBase := self resourceDirectoryName.
			version := nil.
			self resourceManager adjustToRename: self resourceDirectoryName from: oldBase.
			self changeSet name: newName.
			].
]

{ #category : #resources }
Project >> resourceDirectoryName [
	"Project current resourceDirectoryName"
	^String streamContents:[:s|
		s nextPutAll: self name.
		s nextPutAll: FileDirectory dot.
		s nextPutAll: self versionForFileName.
	]

]

{ #category : #resources }
Project >> resourceManager [
	^resourceManager ifNil:[resourceManager := ResourceManager new]
]

{ #category : #resources }
Project >> resourceManager: aResourceManager [
	resourceManager := aResourceManager
]

{ #category : #resources }
Project >> resourceUrl [
	"compose my base url for resources on the server"
	| firstURL | 
"
	primaryServer := self primaryServerIfNil: [^''].
	firstURL := primaryServer altUrl ifNil: [primaryServer url]."
	firstURL := self downloadUrl.
	firstURL isEmpty
		ifFalse: [firstURL last == $/ ifFalse: [firstURL := firstURL, '/']].
	^ firstURL, self resourceDirectoryName , '/'

]

{ #category : #displaying }
Project >> restore [
	"Redraw the entire project."
	
	self subclassResponsibility.
]

{ #category : #displaying }
Project >> restoreDisplay [ 
	"Force re-initialization of the display. Uses display-changed notification to re-draw everything."

	Display restore.
]

{ #category : #'file in\/out' }
Project >> restoreReferences [

	| refs newPool |
	refs := world valueOfProperty: #References ifAbsent: [nil].
	(refs isMemberOf: OrderedCollection) ifTrue: [
		world removeProperty: #References.
		newPool := world referencePool.
		refs do: [:assoc | newPool add: assoc].
	].

]

{ #category : #'file in\/out' }
Project >> revert [
	| |
	"Exit this project and do not save it.  Warn user unless in dangerous projectRevertNoAsk mode.  Exit to the parent project.  Do a revert on a clone of the segment, to allow later reverts."

	projectParameters ifNil: [^ self inform: 'nothing to revert to' translated].
	parentProject enter: false revert: true saveForRevert: false.
	"does not return!"

]

{ #category : #'file in\/out' }
Project >> saveAs [
	"Forget where stored before, and store.  Will ask user where."

	self forgetExistingURL.
	self storeOnServer.
]

{ #category : #'file in\/out' }
Project >> saveForRevert [
	"Exit to the parent project.  Do a GC.  Save the project in a segment.  Record the ImageSegment object as the revertToMe in Project parameters"

	self isTopProject ifTrue: [^ self inform: 'Can''t exit the top project' translated].
	parentProject enter: false revert: false saveForRevert: true.
	"does not return!"


]

{ #category : #'menu messages' }
Project >> saveProjectPreferences [
	"Preserve the settings of all preferences presently held individually by projects in the receiver's projectPreferenceFlagDictionary"

	Preferences allPreferences do:
		[:aPreference | 
			aPreference localToProject ifTrue:
				[projectPreferenceFlagDictionary at: aPreference name put: aPreference preferenceValue]]
]

{ #category : #enter }
Project >> saveState [
	"Save the current state in me prior to leaving this project"

	self saveProjectPreferences.
	changeSet := ChangeSet current.
	thumbnail ifNotNil: [:form | form hibernate].
	transcript := Transcript.
]

{ #category : #enter }
Project >> scheduleProcessForEnter [
	"Complete the enter: by launching a new process"

	self subclassResponsibility
]

{ #category : #'file in\/out' }
Project >> serverList [
	| servers |
	"Take my list of server URLs and return a list of ServerDirectories to write on."

	urlList isEmptyOrNil ifTrue: [^ nil].
	servers := OrderedCollection new.
	urlList do: [:url | | server |
		server := ServerDirectory serverForURL: url.
		server ifNotNil: [servers add: server].
		server := ServerDirectory serverForURL: url asUrl downloadUrl.
		server ifNotNil: [servers add: server]].
	^servers isEmpty
		ifTrue: [nil]
		ifFalse: [servers]
]

{ #category : #utilities }
Project >> setAsBackground: aForm [
	"Set  aForm as a background image."

	self subclassResponsibility

]

{ #category : #initialization }
Project >> setChangeSet: aChangeSet [

	changeSet := aChangeSet

]

{ #category : #'sub-projects & hierarchy' }
Project >> setParent: newParent [

	parentProject := newParent.
	nextProject := previousProject := nil.
]

{ #category : #initialization }
Project >> setServer [
	"Mark me as a new project.  See if a server is known, remember it."

	self projectParameters at: #exportState put: #nacent.
	urlList isEmptyOrNil ifTrue: [urlList := parentProject urlList].
]

{ #category : #utilities }
Project >> showImage: aForm named: imageName [
	"Show an image, possibly attached to the pointer for positioning"

	self subclassResponsibility

]

{ #category : #'flaps support' }
Project >> showSharedFlaps [
	"Answer whether shared flaps are shown or suppressed in this project"

	| result |
	result := Preferences showSharedFlaps.
	^ self == Project current
		ifTrue:
			[result]
		ifFalse:
			[self projectPreferenceAt: #showSharedFlaps ifAbsent: [result]]
]

{ #category : #displaying }
Project >> showZoom [
	"Decide if user wants a zoom transition, and if there is enough memory to do it."

	^ Preferences projectZoom and:
		"Only show zoom if there is room for both displays plus a megabyte"
		[Smalltalk garbageCollectMost > 
						(Display boundingBox area*displayDepth //8+1000000)]
]

{ #category : #displaying }
Project >> shrinkDisplay [ 

	Display shrink.
]

{ #category : #'active process' }
Project >> spawnNewProcessIfThisIsUI: suspendedProcess [
	"Initialize a UI process if needed. Answer true if suspendedProcess was interrupted
	from a UI process."
	self subclassResponsibility
]

{ #category : #'file in\/out' }
Project >> squeakletDirectory [

	^self class squeakletDirectory
]

{ #category : #resources }
Project >> startResourceLoading [
	"Abort loading resources"
	resourceManager ifNil:[^self].
	resourceManager adjustToDownloadUrl: self resourceUrl.
	resourceManager startDownload
]

{ #category : #enter }
Project >> startUpActions [
	"The image is being newly started, not just snapshotted."
	

]

{ #category : #'file in\/out' }
Project >> storeAttributeKey: key value: value on: aStream [

	(key includes: $:) ifTrue: [self error: 'key should not contain :'].
	aStream nextPutAll: key.
	aStream nextPutAll: ': '.
	aStream nextPutAll: value.
	aStream cr.

]

{ #category : #'file in\/out' }
Project >> storeAttributesOn: aStream [

	| details |
	self storeAttributeKey: 'Squeak-Version' value: SystemVersion current version on: aStream.
	self storeAttributeKey: 'Squeak-LatestUpdate' value: SystemVersion current highestUpdate printString on: aStream.
	self storeAttributeKey: 'File-Name-Encoding' value: LanguageEnvironment defaultFileNameConverter class encodingNames first on: aStream.

	details := self world valueOfProperty: #ProjectDetails ifAbsent: [Dictionary new].
	details associationsDo: [:assoc |
		self storeAttributeKey: assoc key asString value: assoc value asString on: aStream.].

]

{ #category : #'file in\/out' }
Project >> storeDataOn: aDataStream [
	"Write me out.  All references to other projects are weak references.  They only go out if they are written for another reason."
	| cntInstVars cntIndexedVars localInstVars offset |

	cntInstVars := self class instSize.
	cntIndexedVars := self basicSize.
	localInstVars := Project instVarNames.
	offset := Project superclass instSize.
	aDataStream
		beginInstance: self class
		size: cntInstVars + cntIndexedVars.
	1 to: cntInstVars do:
		[:ii | 
		(ii between: offset+1 and: offset + localInstVars size) 
			ifTrue: [(#('parentProject' 'previousProject' 'nextProject') includes: 
				(localInstVars at: ii-offset)) 
					ifTrue: [aDataStream nextPutWeak: (self instVarAt: ii)]
								"owner only written if in our tree"
					ifFalse: [aDataStream nextPut: (self instVarAt: ii)]]
			ifFalse: [aDataStream nextPut: (self instVarAt: ii)]].

	1 to: cntIndexedVars do:
		[:i | aDataStream nextPut: (self basicAt: i)]
]

{ #category : #'file in\/out' }
Project >> storeHtmlPageIn: aFileDirectory [
	"Prepare the HTML wrapper for the current project"
	| file page |
	file := aFileDirectory forceNewFileNamed: (self name, FileDirectory dot,'html').
	file ifNil: [^self].
	file converter: UTF8TextConverter new.
	page := self htmlPagePrototype.
	page := page copyReplaceAll: '$$PROJECT$$' with: self versionedFileName.
	page := page copyReplaceAll: '$$WIDTH$$' with: world bounds width printString.
	page := page copyReplaceAll: '$$HEIGHT$$' with: world bounds height printString.
	page := page copyReplaceAll: String cr with: String lf. "not sure if necessary..."
	file nextPutAll: page.
	file close.
]

{ #category : #'file in\/out' }
Project >> storeManifestFileIn: aFileDirectory [

	| file |
	file := aFileDirectory forceNewFileNamed: (self name, FileDirectory dot,'manifest').
	file ifNil: [^ self].
	file converter: UTF8TextConverter new.
	self storeAttributesOn: file.
	file close.

]

{ #category : #accessing }
Project >> storeNewPrimaryURL: aURLString [
	| oldResourceUrl |
	oldResourceUrl := self resourceUrl.
	urlList isEmptyOrNil ifTrue: [urlList := Array new: 1].
	urlList at: 1 put: aURLString.
	self lastDirectory: nil.
	self resourceManager adjustToNewServer: self resourceUrl from: oldResourceUrl

]

{ #category : #'file in\/out' }
Project >> storeOnServer [

	"Save to disk as an Export Segment.  Then put that file on the server I came from, as a new version.  Version is literal piece of file name.  Mime encoded and http encoded."

	world setProperty: #optimumExtentFromAuthor toValue: world extent.
	self validateProjectNameIfOK: [:details |
		self acceptProjectDetails: details.
		self isCurrentProject ifTrue: ["exit, then do the command"
			^ self 
				armsLengthCommand: #storeOnServerAssumingNameValid
				withDescription: 'Publishing' translated
		].
		self storeOnServerWithProgressInfo.
	].
]

{ #category : #'file in\/out' }
Project >> storeOnServerAssumingNameValid [

	"Save to disk as an Export Segment.  Then put that file on the server I came from, as a new version.  Version is literal piece of file name.  Mime encoded and http encoded."

	world setProperty: #optimumExtentFromAuthor toValue: world extent.
	self isCurrentProject ifTrue: ["exit, then do the command"
		^ self 
			armsLengthCommand: #storeOnServerAssumingNameValid
			withDescription: 'Publishing' translated
	].
	self storeOnServerWithProgressInfo.

]

{ #category : #'file in\/out' }
Project >> storeOnServerInnards [
	"Save to disk as an Export Segment.  Then put that file on the server I came from, as a new version.  Version is literal piece of file name.  Mime encoded and http encoded."

	| resp newName primaryServerDirectory serverVersionPair localDirectory localVersionPair myVersionNumber warning maxNumber suppliedPassword oldResourceUrl |
	self assureIntegerVersion.

	"Find out what version"
	primaryServerDirectory := self primaryServerIfNil: [
		(primaryServerDirectory := self findAFolderToStoreProjectIn) ifNil: [^self].
		oldResourceUrl := self resourceUrl.
		primaryServerDirectory == #localOnly ifTrue: [
			self storeNewPrimaryURL: FileDirectory default url.
			nil
		] ifFalse: [
			self storeNewPrimaryURL: primaryServerDirectory downloadUrl.
			primaryServerDirectory
		].
	].

	localDirectory := self squeakletDirectory.
	serverVersionPair := self class mostRecent: self name onServer: primaryServerDirectory.
	localVersionPair := self class mostRecent: self name onServer: localDirectory.
	maxNumber := myVersionNumber := self currentVersionNumber.

	ProgressNotification signal: '2:versionsDetected'.

	warning := ''.
	myVersionNumber < serverVersionPair second ifTrue: [
		warning := warning,'\There are newer version(s) on the server' translated.
		maxNumber := maxNumber max: serverVersionPair second.
	].
	myVersionNumber < localVersionPair second ifTrue: [
		warning := warning,'\There are newer version(s) in the local directory' translated.
		maxNumber := maxNumber max: localVersionPair second.
	].
	"8 Nov 2000 - only check on the first attempt to publish"
	myVersionNumber = 0 ifTrue: [
		warning isEmpty ifFalse: [
			myVersionNumber = 0 ifTrue: [
				warning := warning,'\THIS PROJECT HAS NEVER BEEN SAVED' translated.
			].
			warning := 'WARNING' translated, '\Project: ' translated, self name,warning.
			resp := (UIManager default 
					chooseFrom: (Array with: 'Store anyway' translated 
										with: 'Cancel' translated)
  					title: (warning, '\Please cancel, rename this project, and see what is there.' translated) withCRs).
				resp ~= 1 ifTrue: [^ nil]
		].
	].
	version := self bumpVersion: maxNumber.

	oldResourceUrl
		ifNotNil: [self resourceManager adjustToNewServer: self resourceUrl from: oldResourceUrl].

	"write locally - now zipped automatically"
	newName := self versionedFileName.
	lastSavedAtSeconds := Time totalSeconds.
	self exportSegmentFileName: newName directory: localDirectory.
	(localDirectory readOnlyFileNamed: newName) setFileTypeToObject; close.

	ProgressNotification signal: '4:localSaveComplete'.	"3 is deep in export logic"

	primaryServerDirectory ifNotNil: [
		suppliedPassword := ''.
		Preferences passwordsOnPublish ifTrue: [
			suppliedPassword := UIManager default requestPassword: 'Project password' translated
		].
		[
		primaryServerDirectory
			writeProject: self
			inFileNamed: newName asFileName
			fromDirectory: localDirectory.
		] on: ProjectPasswordNotification do: [ :ex |
			ex resume: (suppliedPassword ifNil: [''])
		].
	].
	ProgressNotification signal: '9999 save complete'.

	"Later, store with same name on secondary servers.  Still can be race conditions.  All machines will go through the server list in the same order."
	"2 to: servers size do: [:aServer | aServer putFile: local named: newName]."

]

{ #category : #'file in\/out' }
Project >> storeOnServerShowProgressOn: aMorphOrNil forgetURL: forget [

	"Save to disk as an Export Segment.  Then put that file on the server I came from, as a new version.  Version is literal piece of file name.  Mime encoded and http encoded."

	world setProperty: #optimumExtentFromAuthor toValue: world extent.
	self validateProjectNameIfOK: [:details |
		self acceptProjectDetails: details.
		self isCurrentProject ifTrue: ["exit, then do the command"
			forget
				ifTrue: [self forgetExistingURL]
				ifFalse: [urlList isEmptyOrNil ifTrue: [urlList := parentProject urlList copy]].
			^self
				armsLengthCommand: #storeOnServerAssumingNameValid
				withDescription: 'Publishing' translated
		].
		self storeOnServerWithProgressInfoOn: aMorphOrNil.
	].

]

{ #category : #'file in\/out' }
Project >> storeOnServerWithProgressInfo [

	"Save to disk as an Export Segment.  Then put that file on the server I came from, as a new version.  Version is literal piece of file name.  Mime encoded and http encoded."

	CurrentProject
		do: [self storeOnServerInnards]
		withProgressInfoOn: nil
		label: 'project storing'

]

{ #category : #'file in\/out' }
Project >> storeOnServerWithProgressInfoOn: aMorphOrNil [

	"Save to disk as an Export Segment.  Then put that file on the server I came from, as a new version.  Version is literal piece of file name.  Mime encoded and http encoded."

	CurrentProject
		do: [self storeOnServerInnards]
		withProgressInfoOn: aMorphOrNil
		label: 'project storing'

	
]

{ #category : #resources }
Project >> storeResourceList: collector in: fd [
	"Store a list of all used resources in the given directory. Used for maintenance."
	| file rcName |
	rcName := self resourceDirectoryName,'.rc'.
	file := fd forceNewFileNamed: rcName.
	collector locatorsDo:[:loc| file nextPutAll: loc urlString; cr].
	file close.
	file := fd readOnlyFileNamed: rcName.
	file compressFile.
	fd deleteFileNamed: rcName ifAbsent:[].
]

{ #category : #'file in\/out' }
Project >> storeSegment [
	"Store my project out on the disk as an ImageSegment.  Keep the outPointers in memory.  Name it <project name>.seg.  *** Caller must be holding (Project alInstances) to keep subprojects from going out. ***"

	self subclassResponsibility

]

{ #category : #'file in\/out' }
Project >> storeSegmentNoFile [
	"For testing.  Make an ImageSegment.  Keep the outPointers in memory.  Also useful if you want to enumerate the objects in the segment afterwards (allObjectsDo:)"

	self subclassResponsibility

]

{ #category : #'file in\/out' }
Project >> storeSomeSegment [
	"Try all projects to see if any is ready to go out.  Send at most three of them.
	Previous one has to wait for a garbage collection before it can go out."

	| cnt pList start proj gain |
	cnt := 0.
	gain := 0.
	pList := Project allProjects.
	start := pList size atRandom.	"start in a random place"
	start to: pList size + start
		do: 
			[:ii | 
			proj := pList atWrap: ii.
			proj storeSegment 
				ifTrue: 
					["Yes, did send its morphs to the disk"

					gain := gain + (proj projectParameters at: #segmentSize ifAbsent: [0]).	"a guess"
					Beeper beep.
					(cnt := cnt + 1) >= 2 ifTrue: [^gain]]].
	Beeper  beep.
	^gain
]

{ #category : #'file in\/out' }
Project >> storeToMakeRoom [
	"Write out enough projects to fulfill the space goals.
	Include the size of the project about to come in."

	| params memoryEnd goalFree cnt gain proj skip tried |
	GoalFreePercent ifNil: [GoalFreePercent := 33].
	GoalNotMoreThan ifNil: [GoalNotMoreThan := 20000000].
	params := Smalltalk  getVMParameters.
	memoryEnd	:= params at: 3.
"	youngSpaceEnd	:= params at: 2.
	free := memoryEnd - youngSpaceEnd.
"
	goalFree := GoalFreePercent asFloat / 100.0 * memoryEnd.
	goalFree := goalFree min: GoalNotMoreThan.
	world isInMemory ifFalse: ["enough room to bring it in"
		goalFree := goalFree + (self projectParameters at: #segmentSize ifAbsent: [0])].
	cnt := 30.
	gain := Smalltalk garbageCollectMost.
	"skip a random number of projects that are in memory"
	proj := self.  skip := 6 atRandom.
	[proj := proj nextInstance ifNil: [Project someInstance].
		proj world isInMemory ifTrue: [skip := skip - 1].
		skip > 0] whileTrue.
	cnt := 0.  tried := 0.

	[gain > goalFree] whileFalse: [
		proj := proj nextInstance ifNil: [Project someInstance].
		proj storeSegment ifTrue: ["Yes, did send its morphs to the disk"
			gain := gain + (proj projectParameters at: #segmentSize 
						ifAbsent: [20000]).	"a guess"
			Beeper beep.
			(cnt := cnt + 1) > 5 ifTrue: [^ self]].	"put out 5 at most"
		(tried := tried + 1) > 23 ifTrue: [^ self]].	"don't get stuck in a loop"
]

{ #category : #'sub-projects & hierarchy' }
Project >> subProjects [
	"Answer a list of all the subprojects of the receiver. By default, use the list of all projects and traverse the parent."
	
	^ Project allProjects select: [:p | p parent == self and: [p isTopProject not]]
]

{ #category : #'enter - recovery' }
Project >> suspendProcessForDebug [
	"If this project fails, let another project debug this project's main loop/process. Default behavior is terminating the process. Hence, no debugging."
	
	self terminateProcessForLeave.
]

{ #category : #'scheduling & debugging' }
Project >> syntaxError: aSyntaxErrorNotification [

	^ ToolSet debugSyntaxError: aSyntaxErrorNotification
]

{ #category : #SuperSwiki }
Project >> tellAFriend [

	self tellAFriend: nil

]

{ #category : #SuperSwiki }
Project >> tellAFriend: emailAddressOrNil [ 
	"
	Project current tellAFriend
	"
	| urlForLoading |
	(urlForLoading := self urlForLoading)
		ifNil: [urlForLoading := self url
			"fallback for dtp servers"].
	urlForLoading isEmptyOrNil
		ifTrue: [^ self inform: 'Since this project has not been saved yet,
I cannot tell someone where it is.' translated].
	FancyMailComposition new
		celeste: nil
		to: (emailAddressOrNil
				ifNil: ['RECIPIENT.GOESHERE'])
		subject: 'New/Updated Squeak project'
		initialText: 'This is a link to the Squeak project ' , self name , ': ' , String crlf
		theLinkToInclude: urlForLoading;
		 open
]

{ #category : #enter }
Project >> terminateProcessForLeave [
	"Clean-up processes that this project uses."

	self subclassResponsibility.
]

{ #category : #utilities }
Project >> textWindows [
	"Answer a dictionary of all system windows for text display keyed by window title.
	Generate new window titles as required to ensure unique keys in the dictionary."

	self subclassResponsibility
]

{ #category : #accessing }
Project >> thumbnail [
	^ thumbnail
]

{ #category : #accessing }
Project >> thumbnail: aForm [

	thumbnail := aForm.
]

{ #category : #accessing }
Project >> transcript [

	^ transcript
]

{ #category : #'file in\/out' }
Project >> tryToFindAServerWithMe [

	| resp primaryServerDirectory |

	urlList isEmptyOrNil ifTrue: [urlList := parentProject urlList copy].
	[self primaryServer isNil] whileTrue: [
		resp := (UIManager default 
					chooseFrom: #('Try to find a server' 'Cancel')
					title: 'This project thinks it has never been on a server').
		resp ~= 1 ifTrue: [^ nil].
		(primaryServerDirectory := self findAFolderToLoadProjectFrom) ifNil: [^nil].
		self storeNewPrimaryURL: primaryServerDirectory downloadUrl.
	].
	^self primaryServer

]

{ #category : #accessing }
Project >> uiManager [
	"Answer the manager that provides user interface services for this project "
	^ uiManager
		ifNil: [uiManager := Smalltalk
						at: #UIManager
						ifPresent: [:mgr | uiManager := mgr getDefault]]
]

{ #category : #'active process' }
Project >> uiProcess [
	"Answer the most important process of this project."

	self subclassResponsibility.
]

{ #category : #language }
Project >> updateLocaleDependents [
	"Set the project's natural language as indicated"

	LanguageEnvironment localeChanged.
]

{ #category : #'file in\/out' }
Project >> url [
	| firstURL |
	"compose my url on the server"

	urlList isEmptyOrNil ifTrue: [^''].
	firstURL := urlList first.
	firstURL isEmpty
		ifFalse: [
			firstURL last == $/
				ifFalse: [firstURL := firstURL, '/']].
	^ firstURL, self versionedFileName

]

{ #category : #'file in\/out' }
Project >> urlForLoading [
	"compose a url that will load me in someone's browser"
	| myServer serverList myUrl downloadUrl |
	serverList := self serverList.
	serverList isEmptyOrNil
		ifTrue: [
			urlList isEmptyOrNil ifTrue: [^nil].
			downloadUrl := urlList first asUrl downloadUrl]
		ifFalse: [
			myServer := serverList first.
			myUrl := myServer altUrl.
			myUrl last == $/
				ifFalse: [myUrl := myUrl , '/'].
			downloadUrl := myUrl].
	^downloadUrl , (self name, FileDirectory dot,'html') encodeForHTTP

]

{ #category : #accessing }
Project >> urlList [
	^ urlList
]

{ #category : #'menu messages' }
Project >> validateProjectNameIfOK: aBlock [

	| details |

	details := world valueOfProperty: #ProjectDetails.
	details ifNotNil: ["ensure project info matches real project name"
		details at: 'projectname' put: self name.
	].
	self doWeWantToRename ifFalse: [^ aBlock value: details].
	(Smalltalk at: #EToyProjectDetailsMorph) ifNotNil: [:etpdm |
		etpdm
			getFullInfoFor: self 
			ifValid: [:d |
				Project current world displayWorldSafely.
				aBlock value: d
			]
			expandedFormat: false]

]

{ #category : #'file in\/out' }
Project >> versionForFileName [
	"Project current versionForFileName"
	^self class versionForFileName: self currentVersionNumber
]

{ #category : #'file in\/out' }
Project >> versionFrom: aServerFile [
	"Store the version of the file I actually came from.  My stored version was recorded before I knew the latest version number on the server!"
	| theName serverUrl |

	self flag: #bob.		"this may become unnecessary once we get the version before writing"
	self flag: #bob.		"need to recognize swiki servers"

	serverUrl := aServerFile directoryUrl.
	theName := aServerFile localName.
	version := (Project parseProjectFileName: theName) second.
	(serverUrl beginsWith: 'ftp:') ifTrue: ["update our server location"
		self storeNewPrimaryURL: serverUrl
	].

]

{ #category : #'file in\/out' }
Project >> versionedFileName [
	"Project current versionedFileName"
	^String streamContents:[:s|
		s nextPutAll: self name.
		s nextPutAll: FileDirectory dot.
		s nextPutAll: self versionForFileName.
		s nextPutAll: FileDirectory dot.
		s nextPutAll: self projectExtension.
	]

]

{ #category : #displaying }
Project >> viewLocFor: exitedProject [ 
	"Look for a view of the exitedProject, and return its center"

	^ Display center
]

{ #category : #accessing }
Project >> viewSize [
	^ viewSize ifNil: [viewSize := Display extent // 8]
]

{ #category : #accessing }
Project >> viewSize: aPoint [
	viewSize := aPoint
]

{ #category : #enter }
Project >> wakeUpTopWindow [
	"Image has been restarted, and the startUp list has been processed. Perform
	any additional actions needed to restart the user interface."

	^ self
]

{ #category : #initialization }
Project >> windowActiveOnFirstClick [

	^ true
]

{ #category : #release }
Project >> windowIsClosing [

	self prepareForDelete.
]

{ #category : #initialization }
Project >> windowReqNewLabel: newLabel [
	newLabel isEmpty ifTrue: [^ false].
	newLabel = changeSet name ifTrue: [^ true].
	(ChangeSet named: newLabel) == nil
		ifFalse: [self inform: 'Sorry that name is already used'.
				^ false].
	changeSet name: newLabel.
	^ true
]

{ #category : #'sub-projects & hierarchy' }
Project >> withChildrenDo: aBlock [
	"Evaluate the block first with the receiver as argument, then, recursively and depth first, with each of the receiver's children as argument"
	
	aBlock value: self.
	self children do: [:p | 
		p withChildrenDo: aBlock ]
]

{ #category : #accessing }
Project >> world [
	^ world
]

{ #category : #'file in\/out' }
Project >> writeFileNamed: localFileName fromDirectory: localDirectory toServer: primaryServerDirectory [

	| local resp gifFileName f |

	local := localDirectory oldFileNamed: localFileName.
	resp := primaryServerDirectory upLoadProject: local named: localFileName resourceUrl: self resourceUrl retry: false.
	local close.
	resp == true ifFalse: [
		"abandon resources that would've been stored with the project"
		self resourceManager abandonResourcesThat:
			[:loc| loc urlString beginsWith: self resourceUrl].
		self error: 'the primary server of this project seems to be down (',
							resp printString,')'. 
		^ self
	].

	gifFileName := self name,'.gif'.
	localDirectory deleteFileNamed: gifFileName ifAbsent: [].
	local := localDirectory fileNamed: gifFileName.
	thumbnail ifNil: [
		(thumbnail := Form extent: 100@80) fillColor: Color orange
	] ifNotNil: [
		thumbnail unhibernate.
	].
	f := thumbnail colorReduced.  "minimize depth"
	f depth > 8 ifTrue: [
		f := thumbnail asFormOfDepth: 8
	].
	GIFReadWriter putForm: f onStream: local.
	local close.

	[local := StandardFileStream readOnlyFileNamed: (localDirectory fullNameFor: gifFileName).
	(primaryServerDirectory isKindOf: FileDirectory)
		ifTrue: [primaryServerDirectory deleteFileNamed: gifFileName ifAbsent: []].
	primaryServerDirectory putFile: local named: gifFileName retry: false.
	] on: Error do: [:ex |].
	local close.

	primaryServerDirectory updateProjectInfoFor: self.
	primaryServerDirectory sleep.	"if ftp, close the connection"

]

{ #category : #'file in\/out' }
Project >> writeStackText: stacks in: resourceDirectory registerIn: aCollector [
	"The user's text is very valuable.  Write an extra file with just the text.  It can be read in case the Project can't be opened." 
	"Find allText for each stack, storeOn a local file in the resources folder, with a name like myProj.005.myStack.t.  Make the names be unique."

	"get project name and version"
	| resourceURL ind |
	resourceURL := self resourceUrl.
	stacks do: [:stackObj | | sn localName char trial textLoc fs |	"Construct a good file name"
		localName := self versionedFileName allButLast: 2.	"projectName.005."
		stacks size = 1 ifFalse: ["must distinguish between stacks in the project"
			(sn := stackObj knownName) ifNil: [
				sn := stackObj hash printString].	"easy name, or use hash"
			localName := localName , sn, FileDirectory dot]. 	"projectName.005.myStack."
		localName := localName , 't'.
		"See if in use because truncates same as another, fix last char, try again"
		[trial := resourceDirectory checkName: localName fixErrors: true.
		 trial endsWith: '.t'] whileFalse: [
				localName := (localName allButLast: 3) , FileDirectory dot, 't'].
		[resourceDirectory fileExists: trial] whileTrue: [
			char := trial at: (ind := trial size - 3).
			trial at: ind put: (char asciiValue + 1) asCharacter].	"twiddle it a little"
		
		"write allText in file"
		fs := resourceDirectory newFileNamed: trial.
		fs timeStamp; cr; nextPutAll: '''This is the text for a stack in this project.  Use only in an emergency, if the project file is ever unreadable.''.'; cr; cr.
		stackObj getAllText storeOn: fs.    fs close.
		textLoc := (ResourceLocator new) localFileName: trial; 
			urlString: resourceURL, '/', trial.
		aCollector locatorMap at: trial "any distinct object" put: textLoc.
		].
]
