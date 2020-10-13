"
An MVCProject is a project with an MVC user interface. It stores its control manager in the world instance variable, and its UI manager is an MVCUIManager. It uses an MVCToolBuilder to create the views for various tools.

"
Class {
	#name : #MVCProject,
	#superclass : #Project,
	#category : #'ST80-Support'
}

{ #category : #'class initialization' }
MVCProject class >> convertOldProjects [
	"Convert old MVC projects to be MVCProjects"
	Project allInstancesDo:[:p|
		(p world isKindOf: ControlManager) 
			ifTrue:[p primitiveChangeClassTo: self basicNew]].
]

{ #category : #'class initialization' }
MVCProject class >> initialize [
	super initialize.
	CurrentProject ifNil:
		["This is the Top Project."
		CurrentProject := super new initialProject].

]

{ #category : #utilities }
MVCProject class >> releaseProjectReferences: outgoingProject [

	ProjectController allInstancesDo: [:pvc |
		[pvc model == outgoingProject ifTrue: [pvc closeAndUnscheduleNoTerminate]]
			on: Error do: [:ex | 
				"Unschedule the bad controller from all managers."
				ControlManager allInstancesDo: [:m | m unschedule: pvc]]].
]

{ #category : #shrinking }
MVCProject class >> unloadMVC [
	"Completely remove MVC from the system. All MVC projects will be destroyed.
	To reinstall MVC, load all of the ST80 and MVCToolbuilder packages."

	"MVCProject unloadMVC"

	Project current isMVC ifTrue: [
		^ Error signal: 'You can only unload MVC from within another kind of project.'].

	MVCProject removeProjectsFromSystem.
	
	Smalltalk globals removeKey: #ScheduledControllers.
	{ 'ToolBuilder-MVC' . 'ST80Tests' . 'ST80Tools' . 'ST80' }
		do: [ :package | (MCPackage named: package) unload ].


]

{ #category : #'file in\/out' }
MVCProject >> acceptProjectDetails: details [
	"Ignored; here for MorphicProject compatibility."
]

{ #category : #'scheduling & debugging' }
MVCProject >> addDeferredUIMessage: valuableObject [ 
	"Arrange for valuableObject to be evaluated at a time when the user interface
	is in a coherent state."

	self flag: #discuss. "mt: Why are deferred UI messages shared among all MVC projects?"
	ControlManager addDeferredUIMessage: valuableObject.
]

{ #category : #utilities }
MVCProject >> addItem: item toMenu: menu selection: action color: aColor thumbnail: aForm [
	"Add menu item representing the sender to a menu. Morphic projects use
	aColor and aForm for menu items."

	menu add: item action: action
]

{ #category : #'sub-projects & hierarchy' }
MVCProject >> addProject: project [

	| view |
	super addProject: project.

	view := ProjectView new
		model: project;
		minimumSize: 50@30;
		borderWidth: 2;
		resizeInitially;
		yourself.
	view controller status: #open.
]

{ #category : #'file in\/out' }
MVCProject >> armsLengthCommand: aCommand withDescription: aString [
	| pvm |
	"Set things up so that this aCommand is sent to self as a message
after jumping to the parentProject.  For things that can't be executed
while in this project, such as saveAs, loadFromServer, storeOnServer.  See
ProjectViewMorph step."

	parentProject ifNil: [^ self inform: 'The top project can''t do that'].
	pvm := parentProject findProjectView: self.
	pvm armsLengthCommand: {self. aCommand}.
	self exit

]

{ #category : #editors }
MVCProject >> bitEdit: aForm [
	"Create and schedule a view located in an area designated by the user 
	that contains a view of aForm magnified by 8@8 that can be modified using
	a bit editor. It also contains a view of the original form."

	BitEditor openOnForm: aForm

	"Note that using direct messages to BitEditor, fixed locations and scales can be created.
	That is, also try:
		BitEditor openOnForm: self at: <some point>
		BitEditor openOnForm: self at: <some point> scale: <some point>"
]

{ #category : #editors }
MVCProject >> bitEdit: aForm at: magnifiedFormLocation scale: scaleFactor [
	"Create and schedule a view whose top left corner is magnifiedLocation 
	and that contains a view of aForm magnified by scaleFactor that  can be
	modified using the Bit Editor. It also contains a view of the original form."

	BitEditor openOnForm: aForm at: magnifiedFormLocation scale: scaleFactor 
]

{ #category : #accessing }
MVCProject >> color [

	^ self world isInMemory
		ifTrue: [Color veryVeryDarkGray]
		ifFalse: [Color blue]
]

{ #category : #utilities }
MVCProject >> composeDisplayTextIntoForm: displayText [

	^ displayText asParagraph asForm
]

{ #category : #protocols }
MVCProject >> currentVocabulary [
	"Answer the currently-prevailing default vocabulary."

	Smalltalk at: #Vocabulary ifPresent: [:v | ^ v fullVocabulary].
	self error: 'package Protocols not present in this image'

]

{ #category : #'scheduling & debugging' }
MVCProject >> debuggerClass [

	^ Smalltalk classNamed: #MVCDebugger
]

{ #category : #release }
MVCProject >> deletingProject: outgoingProject [

	"Clean-up my project views."
	(self world controllersSatisfying: [:m | m model = outgoingProject]) 
		do: [:projectController | 
			self world unschedule: projectController.
			projectController view
				model: nil;
				release].
			
	super deletingProject: outgoingProject.
]

{ #category : #transcripter }
MVCProject >> displayTranscripter: transcripter [
	"A transcripter is a minimal user interface to support an emergency evaluator.
	An MVC project uses class Paragraph."
	transcripter mvcDisplayText
]

{ #category : #utilities }
MVCProject >> do: aBlock withProgressInfoOn: aMorphOrNil label: aString [
	"Evaluate aBlock with a labeled progress bar. Use a simple progress
	bar set to 50% progress. In Morphic, progress is displayed with a
	ComplexProgressIndicator."

	aString
		displayProgressFrom: 0 to: 2
		during: [:bar |  bar value: 1.
				aBlock value]


]

{ #category : #editors }
MVCProject >> editCharacter: character ofFont: strikeFont [
	"Open a bit editor on a character in the given strike font. Note that you must
	do an accept (in the option menu of the bit editor) if you want this work. 
	Accepted edits will not take effect in the font until you leave or close the bit editor. 
	Also note that unaccepted edits will be lost when you leave or close."
	"Note that BitEditor only works in MVC currently."

	"(TextStyle default fontAt: 1) edit: $="

	| charForm editRect scaleFactor bitEditor savedForm r |
	charForm := strikeFont characterFormAt: character.
	editRect := Rectangle locateMagnifiedView: charForm scale: (scaleFactor := 8 @ 8).
	bitEditor := BitEditor
				bitEdit: charForm
				at: editRect topLeft
				scale: scaleFactor
				remoteView: nil.
	savedForm := Form fromDisplay: (r := bitEditor displayBox
							expandBy: (0 @ 23 corner: 0 @ 0)).
	bitEditor controller startUp.
	bitEditor release.
	savedForm displayOn: Display at: r topLeft.
	strikeFont characterFormAt: character put: charForm
]

{ #category : #'file in\/out' }
MVCProject >> exportSegmentWithCatagories: catList classes: classList fileName: aFileName directory: aDirectory [
	"Store my project out on the disk as an *exported* ImageSegment.  All outPointers will be in a form that can be resolved in the target image.  Name it <project name>.extSeg.  What do we do about subProjects, especially if they are out as local image segments?  Force them to come in?
	Player classes are included automatically."

	self flag: #toRemove.
	self halt.  "unused"
	"world == World ifTrue: [^ false]."
	"self inform: 'Can''t send the current world out'."
	self projectParameters at: #isMVC put: true.
	^ false	"Only Morphic projects for now"

]

{ #category : #'file in\/out' }
MVCProject >> exportSegmentWithChangeSet: aChangeSetOrNil fileName: aFileName
directory: aDirectory [
	"Store my project out on the disk as an *exported*
ImageSegment.  All outPointers will be in a form that can be resolved
in the target image.  Name it <project name>.extSeg.  Whatdo we do
about subProjects, especially if they are out as local image
segments?  Force them to come in?
	Player classes are included automatically."

	"Files out a changeSet first, so that a project can contain
its own classes"
	self projectParameters at: #isMVC put: true.
	^ false	"Only Morphic projects for now"

]

{ #category : #enter }
MVCProject >> finalEnterActions: leavingProject [

	ScheduledControllers := world.
]

{ #category : #enter }
MVCProject >> finalExitActions: enteringProject [

	super finalExitActions: enteringProject.

	self world unCacheWindows.
	EventSensor default flushEvents.
	
	ScheduledControllers := nil.
]

{ #category : #utilities }
MVCProject >> findAFolderForProject: aProject label: dialogLabel [
	"Find a folder for saving or loading a project"

	^PluggableFileList getFolderDialog openLabel: dialogLabel

]

{ #category : #utilities }
MVCProject >> findProjectView: projectDescription [
	"In this world, find the ProjectController for the project described by projectDescription."

	| pName |
	pName := (projectDescription isString) 
		ifTrue: [projectDescription]
		ifFalse: [projectDescription name].
	world scheduledControllers do: [:cont | | proj dpName |
		(cont isKindOf: ProjectController) ifTrue: [
			((proj := cont model) class == Project and: 
				[proj name = pName]) ifTrue: [^ cont view].
			proj class == DiskProxy ifTrue: [ 
				dpName := proj constructorArgs first.
				dpName := (dpName findTokens: '/') last.
				dpName := (Project parseProjectFileName: dpName unescapePercents) first.
				dpName = pName ifTrue: [^ cont view]]]].
	^ nil
]

{ #category : #editors }
MVCProject >> formEdit: aForm [
	"Start up an instance of the FormEditor on a form. Typically the form 
	is not visible on the screen. The editor menu is located at the bottom of 
	the form editing frame. The form is displayed centered in the frame. 
	YellowButtonMenu accept is used to modify the form to reflect the 
	changes made on the screen version; cancel restores the original form to 
	the screen. Note that the changes are clipped to the original size of the 
	form."
 
	FormEditor openOnForm: aForm
]

{ #category : #editors }
MVCProject >> formViewClass [
	"Answer a class suitable for a view on a form or collection of forms"

	^ FormInspectView
]

{ #category : #initialize }
MVCProject >> initialize [
	super initialize.
	world := ControlManager new.
	uiManager := (Smalltalk classNamed: #MVCUIManager) ifNotNil: [:mgrClass | mgrClass new].
	CurrentProject ifNil:
		[CurrentProject := super new initialProject].

]

{ #category : #transcripter }
MVCProject >> initializeParagraphForTranscripter: transcripter [
	"A transcripter is a minimal user interface to support an emergency evaluator.
	An MVC project uses class Paragraph."
	transcripter mvcInitializeParagraph: Paragraph
]

{ #category : #'project parameters' }
MVCProject >> initializeProjectPreferences [
	"Initialize the project's preferences from currently-prevailing preferences that are currently being held in projects in this system"
	
	self flapsSuppressed: true.
	super initializeProjectPreferences

]

{ #category : #'scheduling & debugging' }
MVCProject >> interruptCleanUpFor: interruptedProcess [

	super interruptCleanUpFor: interruptedProcess.
	
	(world activeController ~~ nil and: [world activeController ~~ world screenController]) ifTrue: [
		interruptedProcess == self uiProcess
			ifTrue: [
				world activeController view topView deEmphasizeForDebugger]
			ifFalse: [
				world activeController controlTerminate]].
]

{ #category : #display }
MVCProject >> invalidate [
	"Invalidate the entire project so that a redraw will be forced later."

	world
		unCacheWindows;
		unschedule: world screenController;
		scheduleOnBottom: world screenController.
]

{ #category : #testing }
MVCProject >> isMVC [

	^ true
]

{ #category : #utilities }
MVCProject >> jumpToProject [
	"Present a list of potential projects and enter the one selected.
	We use mvcStartUpLeftFlush for possibly no longer valid historical reasons"

	"Project current jumpToProject"

	self jumpToSelection: (self buildJumpToMenu: CustomMenu new) startUp
]

{ #category : #'scheduling & debugging' }
MVCProject >> lastDeferredUIMessage [
	"Answer the most recently scheduled deferredUIMessage."

	^ControlManager lastDeferredUIMessage
]

{ #category : #utilities }
MVCProject >> offerMenu: menuSelector from: aModel shifted: aBoolean [
	"Pop up a menu whose target is aModel and whose contents are provided
	by sending the menuSelector to the model. The menuSelector takes two
	arguments: a menu, and a boolean representing the shift state."

	| aMenu |
	aMenu := CustomMenu new.
	aModel perform: menuSelector with: aMenu with: aBoolean.
	aMenu invokeOn: aModel
]

{ #category : #release }
MVCProject >> okToChange [
	"If there is no open window, we are fine to close."
	
	^ (self parent ~~ Project current
		or: [self world scheduledControllers size <= 1])
		or: [super okToChange]
]

{ #category : #editors }
MVCProject >> openImage: aForm name: fullName saveResource: aBoolean [
	"Open a view on an image. Do not save project resource in an MVC project."

	FormView open: aForm named: fullName
]

{ #category : #initialize }
MVCProject >> openProject: aProject [
	"Create a new for a new project in the context of the receiver"
	ProjectView openAndEnter: aProject.
]

{ #category : #display }
MVCProject >> restore [
	"Redraw the entire Project. Ignore errors to keep system responsive."

	[world displayWorld] on: Error do: [:ex | "Ignore."].
]

{ #category : #enter }
MVCProject >> scheduleProcessForEnter [
	"Complete the enter: by launching a new process. Note that we have to use a helper process because MVC will terminate the current process immediately when searching for an active controller. There might, however, be other code to be executed when returning from this call."

	[world searchForActiveController] newProcess
		priority: Processor userSchedulingPriority;
		resume.
]

{ #category : #utilities }
MVCProject >> setAsBackground: aForm [
	"Set aForm as a background image."

	world screenController model form: aForm.
	Display restore.
]

{ #category : #utilities }
MVCProject >> showImage: aForm named: imageName [
	"Show an image, possibly attached to the pointer for positioning"

	FormView open: aForm named: imageName

]

{ #category : #'active process' }
MVCProject >> spawnNewProcessIfThisIsUI: suspendedProcess [
	"In MVC the debugger does not require special handling to start a new UI process
	when the active controller process is interrupted in the debugger."
	^true
]

{ #category : #'file in\/out' }
MVCProject >> storeSegment [
	"Store my project out on the disk as an ImageSegment.  Keep the outPointers in memory.  Name it <project name>.seg.  *** Caller must be holding (Project alInstances) to keep subprojects from going out. ***"

	(Project current world == world) ifTrue: [^ false]. 
	"self inform: 'Can''t send the current world out'."
	world isInMemory ifFalse: [^ false].  "already done"
	self projectParameters at: #isMVC put: true.
	^ false	"Only Morphic projects for now"

]

{ #category : #'file in\/out' }
MVCProject >> storeSegmentNoFile [
	"For testing.  Make an ImageSegment.  Keep the outPointers in memory.  Also useful if you want to enumerate the objects in the segment afterwards (allObjectsDo:)"

	(Project current world == world) ifTrue: [^ self].		" inform: 'Can''t send the current world out'."
	world isInMemory ifFalse: [^ self].  "already done"
	self projectParameters at: #isMVC put: true.
	^ self	"Only Morphic projects for now"

]

{ #category : #utilities }
MVCProject >> subProjects [
	"Answer a list of all the subprojects  of the receiver. "
	
	^ (super subProjects, ((self world controllersSatisfying: [:m | m model isKindOf: Project]) 
		collect: [:controller | controller model])) asSet asArray
]

{ #category : #'scheduling & debugging' }
MVCProject >> syntaxError: aSyntaxErrorNotification [

	super syntaxError: aSyntaxErrorNotification.
	Cursor normal show.
	Processor activeProcess suspend.
]

{ #category : #enter }
MVCProject >> terminateProcessForLeave [
	"There is only one active controller at a time. Kill it's process."
	
	self assert: Processor activeProcess == world activeControllerProcess.
	Processor terminateActive.
]

{ #category : #utilities }
MVCProject >> textWindows [
	"Answer a dictionary of all system windows for text display keyed by window title.
	Generate new window titles as required to ensure unique keys in the dictionary."

	| aDict windows title |
	aDict := Dictionary new.
	windows := world controllersSatisfying:
		[:c | (c model isKindOf: StringHolder)].
	windows do:
		[:aController | | textToUse aTextView | 
			aTextView := aController view subViews detect: [:m | m isKindOf: PluggableTextView] ifNone: [nil].
			textToUse := aTextView
				ifNil:		[aController model contents]
				ifNotNil:	[aTextView controller text].  "The latest edits, whether accepted or not"
				title := aController view label.
				(aDict includesKey: title) ifTrue: [ | newKey | "Ensure unique keys in aDict"
					(1 to: 100) detect: [:e |
							newKey := title, '-', e asString.
							(aDict includesKey: newKey) not].
					title := newKey].
			aDict at: title put: textToUse].
	^ aDict
]

{ #category : #'active process' }
MVCProject >> uiProcess [
	
	^ world activeControllerProcess
]

{ #category : #display }
MVCProject >> viewLocFor: exitedProject [ 
	"Look for a view of the exitedProject, and return its center"

	^ (world controllerWhoseModelSatisfies: [:p | p == exitedProject])
		ifNil: [super viewLocFor: exitedProject]
		ifNotNil: [:ctlr | ^ctlr view windowBox center]
]
