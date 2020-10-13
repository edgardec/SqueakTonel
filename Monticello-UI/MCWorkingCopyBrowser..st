Class {
	#name : #MCWorkingCopyBrowser,
	#superclass : #MCTool,
	#instVars : [
		'workingCopy',
		'workingCopyWrapper',
		'repository',
		'defaults'
	],
	#classVars : [
		'CheckForNewerVersionsBeforeSave',
		'ExternalMenuEntries'
	],
	#category : #'Monticello-UI'
}

{ #category : #hooks }
MCWorkingCopyBrowser class >> addMenuSpec: aMCMenuSpec [
	"Register a context menu entry in the monticello browser from an external package.
	 The MCWorkingCopyBrowser model is passed as argument."
	self externalMenuEntries 
		remove: aMCMenuSpec 
		ifAbsent: ["Remove any previous entry with description string"];
		add: aMCMenuSpec.
]

{ #category : #preferences }
MCWorkingCopyBrowser class >> checkForNewerVersionsBeforeSave [
	"Preference accessor"
	<preference: 'Check for new versions before save'
		category: 'Monticello'
		description: 'If true, MC will warn before committing to repositories that have possibly newer versions of the package being saved.'
		type: #Boolean>
	^CheckForNewerVersionsBeforeSave ifNil:[true]
]

{ #category : #preferences }
MCWorkingCopyBrowser class >> checkForNewerVersionsBeforeSave: aBool [
	"Sets the CheckForNewerVersionsBeforeSave preference"
	CheckForNewerVersionsBeforeSave := aBool
]

{ #category : #hooks }
MCWorkingCopyBrowser class >> externalMenuEntries [
	
	ExternalMenuEntries ifNil: [ExternalMenuEntries := Set new].
	^ ExternalMenuEntries
]

{ #category : #'class initialization' }
MCWorkingCopyBrowser class >> initialize [
	 (TheWorldMenu respondsTo: #registerOpenCommand:)
         ifTrue: [TheWorldMenu registerOpenCommand: {'Monticello Browser'. {self. #open}}]
]

{ #category : #'instance creation' }
MCWorkingCopyBrowser class >> new [
	^ self basicNew initialize
]

{ #category : #'instance creation' }
MCWorkingCopyBrowser class >> open [
	self new show
]

{ #category : #actions }
MCWorkingCopyBrowser >> addPackageRepository [

	workingCopy ifNotNil:
		[
		(self pickRepositorySatisfying: [ :repos | (workingCopy repositoryGroup includes: repos) not ])
			ifNotNil:
				[:repos |
					workingCopy repositoryGroup addRepository: repos.
					self repository: repos.	
					self
						changed: #repositoryList;
						changed: #repositorySelection.
					self changedButtons]]
]

{ #category : #actions }
MCWorkingCopyBrowser >> addRepository [
	self newRepository ifNotNil:
		[:repos | self addRepository: repos ].

]

{ #category : #actions }
MCWorkingCopyBrowser >> addRepository: aRepository [
	self repository: aRepository.
	self repositoryGroup addRepository: aRepository.
	self changed: #repositoryList; changed: #repositorySelection.
	self changedButtons.
]

{ #category : #actions }
MCWorkingCopyBrowser >> addRepositoryToPackage [
	self repository ifNotNil:
		[:repos |
		(self pickWorkingCopySatisfying: [ :p | (p repositoryGroup includes: repos) not ]) ifNotNil:
			[:wc |
			workingCopy := wc.
			workingCopy repositoryGroup addRepository: repos.
			self repository: repos.	
			self
				changed: #workingCopySelection;
				changed: #repositoryList;
				changed: #repositorySelection.
			self changedButtons]]
]

{ #category : #actions }
MCWorkingCopyBrowser >> addRepositoryToWorkingCopy [
	workingCopy ifNotNil:
		[:wc |
			workingCopy repositoryGroup addRepository: self repository.
			self
				changed: #workingCopySelection;
				changed: #repositoryList;
				changed: #repositorySelection.
			self changedButtons]
]

{ #category : #actions }
MCWorkingCopyBrowser >> addRequiredPackage [
	| chosen |
	workingCopy ifNotNil:
		[:wc |
		chosen := self pickWorkingCopySatisfying: 
			[:ea | ea ~= wc and: [(wc requiredPackages includes: ea package) not]].
		chosen ifNotNil:
			[wc requirePackage: chosen package.
			self workingCopyListChanged]]
]

{ #category : #actions }
MCWorkingCopyBrowser >> addWorkingCopy [
	|name|
	name := UIManager default request: 'Name of package:'.
	name isEmptyOrNil ifFalse:
		[PackageInfo registerPackageName: name.
		workingCopy := MCWorkingCopy forPackage: (MCPackage new name: name).
		workingCopyWrapper := nil.
		self repositorySelection: 0].
	self workingCopyListChanged; changed: #workingCopySelection; changed: #repositoryList.
	self changedButtons.
]

{ #category : #actions }
MCWorkingCopyBrowser >> backportChanges [
	self canBackport ifFalse: [^self].
	workingCopy ifNotNil:
		[workingCopy needsSaving ifTrue: [^ self inform: 'You must save the working copy before backporting.'].
		self pickAncestorVersionInfo ifNotNil:
			[:baseVersionInfo |
			workingCopy backportChangesTo: baseVersionInfo]]
]

{ #category : #actions }
MCWorkingCopyBrowser >> browseWorkingCopy [
	workingCopy ifNotNil: [:wc | wc browse].
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> buttonSpecs [
       ^ #(
               ('+Package' addWorkingCopy 'Add a new package and make it the working copy')
               (Browse browseWorkingCopy 'Browse the working copy of the selected package' hasWorkingCopy)
               (Scripts editLoadScripts 'Edit the load/unload scripts of this package' hasWorkingCopy)
               (History viewHistory 'View the working copy''s history' hasWorkingCopy)
               (Changes viewChanges 'View the working copy''s changes relative to the installed version from the repository' canSave)
               (Backport backportChanges 'Backport the working copy''s changes to an ancestor' canBackport)
               (Save saveVersion 'Save the working copy as a new version to the selected repository' canSave)
             ('+Repository' addRepository 'Add an existing repository to the list of those visible')
               (Open openRepository 'Open a browser on the selected repository' hasRepository)
               )
]

{ #category : #actions }
MCWorkingCopyBrowser >> canBackport [
	^ self hasWorkingCopy and: [workingCopy needsSaving not]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> canSave [
	^ self hasWorkingCopy and: [self hasRepository]
]

{ #category : #actions }
MCWorkingCopyBrowser >> changeEnvironment [
	workingCopy ifNil: [^ self].
	workingCopy environment: EnvironmentRequest signal
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> changedButtons [
	self changed: #hasWorkingCopy.
	self changed: #canSave.
	self changed: #canBackport.
	self changed: #hasRepository.

]

{ #category : #actions }
MCWorkingCopyBrowser >> checkAllPackages [
	MCWorkingCopy checkModified: true.

]

{ #category : #actions }
MCWorkingCopyBrowser >> checkForNewerVersions [
	| newer |
	newer := workingCopy possiblyNewerVersionsIn: self repository.
	^ newer isEmpty or: [
		self confirm: 'CAUTION! These versions in the repository may be newer:', 
			String cr, ((newer asCommaString withNoLineLongerThan:  150) truncateWithElipsisTo: 5 * 149), String cr,
			'Do you really want to save this version?'].
]

{ #category : #actions }
MCWorkingCopyBrowser >> clearRequiredPackages [
	workingCopy ifNotNil:
		[:wc |
		wc clearRequiredPackages.
		self workingCopyListChanged]
]

{ #category : #actions }
MCWorkingCopyBrowser >> copyImageVersions [
	self repository ifNotNil: [ : repos | repos copyImageVersions ]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> defaultExtent [
	^ 550@200
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> defaultLabel [
	^ 'Monticello Browser'
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> defaults [
	^ defaults ifNil: [defaults := Dictionary new]
]

{ #category : #actions }
MCWorkingCopyBrowser >> deleteWorkingCopy [
	workingCopy unregister.
	self workingCopySelection: 0.
	self workingCopyListChanged.
]

{ #category : #actions }
MCWorkingCopyBrowser >> demoteRepository [
	self repository ifNotNil:
		[ : repo | self repositoryGroup demoteRepository: repo.
		self
			 changed: #repositoryList ;
			 changed: #repositorySelection ]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> editLoadScripts [

	| arg |
	self hasWorkingCopy ifFalse: [^self].
	arg := UIManager default
		chooseFrom: #('edit preamble' 'edit postscript' 'edit preambleOfRemoval' 'edit postscriptOfRemoval')
		values: #(#preamble #postscript #preambleOfRemoval #postscriptOfRemoval).

	arg ifNotNil: [
		self editScript: arg].
]

{ #category : #actions }
MCWorkingCopyBrowser >> editRepository [
	| newRepo |
	
	newRepo := self repository openAndEditTemplateCopy.
	newRepo ifNotNil: [ 
		newRepo class = self repository class
			ifTrue: [
				self repository copyFrom: newRepo.
				self changed: #repositoryList ]
			ifFalse: [self inform: 'Must not change repository type!']]

]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> editScript: scriptSymbol [

| script |
script := workingCopy packageInfo perform: scriptSymbol.
script openLabel: scriptSymbol asString, ' of the Package ', workingCopy package name.
]

{ #category : #actions }
MCWorkingCopyBrowser >> flushCachedVersions [
	| beforeBytes afterBytes beforeVersions afterVersions |
	Cursor wait showWhile: [
		Smalltalk garbageCollect.
		beforeBytes := Smalltalk bytesLeft: true.
		beforeVersions := MCVersion allSubInstances size.
		MCFileBasedRepository flushAllCaches.
		afterBytes := Smalltalk bytesLeft: true.
		afterVersions := MCVersion allSubInstances size.
	].
	^self inform: (beforeVersions - afterVersions) asString, ' versions flushed', String cr,
 		(beforeBytes - afterBytes) asBytesDescription, ' bytes reclaimed'
]

{ #category : #actions }
MCWorkingCopyBrowser >> flushCachedVersionsAncestry [
	| beforeBytes afterBytes beforeVersions afterVersions beforeInfos afterInfos |
	Cursor wait showWhile: 
		[ beforeBytes := Smalltalk garbageCollect.
		beforeVersions := MCVersion allSubInstances size.
		beforeInfos := MCVersionInfo instanceCount.
		MCFileBasedRepository flushAllCaches.
		MCWorkingCopy stubAllAncestry.
		afterBytes := Smalltalk garbageCollect.
		afterVersions := MCVersion allSubInstances size.
		afterInfos := MCVersionInfo instanceCount ].
	self inform: 
		(beforeVersions-afterVersions) asString, ' versions flushed',
		String cr, (beforeInfos-afterInfos), ' infos flushed',
	 	String cr, (afterBytes-beforeBytes) asBytesDescription, ' reclaimed'
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> hasRepository [
	^ self repository notNil
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> hasWorkingCopy [
	^ workingCopy notNil
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> initialize [
	MCWorkingCopy addDependent: self.
	self workingCopies do: [:ea | ea addDependent: self].
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> insertExternalMenuEntries: aMenu [
	
	self class externalMenuEntries ifNotEmpty: [
		aMenu addLine.
		self class externalMenuEntries do: [:each |
			aMenu 
				add: each entry 
				target: each target
				selector: each selector
				argument: self]].
]

{ #category : #actions }
MCWorkingCopyBrowser >> inspectWorkingCopy [
	workingCopy ifNotNil: [workingCopy inspect]
]

{ #category : #actions }
MCWorkingCopyBrowser >> loadRepositories [
	FileStream fileIn: 'MCRepositories.st'.
	self changed: #repositoryList.
	self changedButtons.

]

{ #category : #actions }
MCWorkingCopyBrowser >> newRepository [
	| types index |
	types := MCRepository allConcreteSubclasses asArray.
	index := UIManager default chooseFrom: (types collect: [:ea | ea description])
				title: 'Repository type:'.
	^ index = 0 ifFalse: [(types at: index) morphicConfigure]
]

{ #category : #actions }
MCWorkingCopyBrowser >> openRepository [
	self repository ifNotNil: [:repos | repos morphicOpen: workingCopy ]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> pickAncestorVersionInfo [
	| ancestors index |
	ancestors := workingCopy ancestry breadthFirstAncestors.
	index := UIManager default chooseFrom: (ancestors collect: [:ea | ea name])
				title: 'Ancestor:'.
	^ index = 0 ifFalse: [ ancestors at: index]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> pickRepositorySatisfying: aBlock [
	| repos index |
	repos := MCRepositoryGroup default repositories select: aBlock.
	index := UIManager default chooseFrom: (repos collect: [:ea | ea description])
				title: 'Repository:'.
	^ index = 0 ifFalse: [repos at: index]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> pickWorkingCopy [
	^self pickWorkingCopySatisfying: [ :c | true ]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> pickWorkingCopySatisfying: aBlock [
	| copies index |
	copies := self workingCopies select: aBlock.
	copies isEmpty ifTrue: [ ^nil ].
	index := UIManager default chooseFrom: (copies collect: [:ea | ea packageName])
				title: 'Package:'.
	^ index = 0 ifFalse: [ copies at: index]
]

{ #category : #actions }
MCWorkingCopyBrowser >> recompilePackage [
	(workingCopy withEnvironmentActiveDo: [workingCopy package packageInfo methods])
		do: [:ea | ea actualClass recompile: ea methodSymbol]
		displayingProgress: 'Recompiling...'
]

{ #category : #actions }
MCWorkingCopyBrowser >> removeRepository [
	self repository ifNotNil:
		[:repos |
		self repositoryGroup removeRepository: repos.
		self repositorySelection: (1 min: self repositories size)].
	self changed: #repositoryList.
	self changedButtons.

]

{ #category : #actions }
MCWorkingCopyBrowser >> renamePackage [
	| newName |
	workingCopy ifNil:
		[ UIManager inform: 'Please select a package to be renamed.'.
		^ self ].
	workingCopy modified ifTrue:
		[ UIManager inform: 'Only unmodified packages should be renamed.'.
		^ self ].
	newName := UIManager default
		request: 'New name of package:'
		initialAnswer: workingCopy packageName.
	newName isEmptyOrNil ifFalse:
		[ | newWorkingCopy |
		newWorkingCopy := workingCopy renameToBe: newName.
		workingCopy package snapshot definitions
			ifEmpty:
				[ "It worked."
				workingCopy unregister.
				workingCopy := newWorkingCopy.
				self repositorySelection: 0.
				self
					 workingCopyListChanged ;
					 changed: #workingCopySelection ;
					 changed: #repositoryList.
				self changedButtons ]
			ifNotEmpty: 
				[ "It didn't work, browse the remaining definitions."
				self browseWorkingCopy ] ]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> repositories [
	^ self repositoryGroup repositories
]

{ #category : #actions }
MCWorkingCopyBrowser >> repository [
	workingCopy ifNotNil: [repository := self defaults at: workingCopy ifAbsent: []].
	^ repository
]

{ #category : #actions }
MCWorkingCopyBrowser >> repository: aRepository [
	repository := aRepository.
	workingCopy ifNotNil: [self defaults at: workingCopy put: aRepository]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> repositoryGroup [
	^ workingCopy
		ifNil: [MCRepositoryGroup default]
		ifNotNil: [workingCopy repositoryGroup]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> repositoryList [
	^ self repositories collect: [:ea | ea description]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> repositoryListMenu: aMenu [
	"first add repository-specific commands"
	self repository ifNotNil:
		[ self
			fillMenu: aMenu
			fromSpecs:
				#(('open repository' #openRepository)
				('edit repository info' #editRepository)
				('add to package...' #addRepositoryToPackage)
				('remove repository' #removeRepository)
				('demote to bottom' #demoteRepository)
				('copy image versions here' #copyImageVersions)).
		aMenu
			add:
				(self repository alwaysStoreDiffs
					ifTrue: ['store full versions']
					ifFalse: ['store diffs'])
				target: self
				selector: #toggleDiffs ;
			addLine ].
	"then the non-specific commands"
	^self fillMenu: aMenu fromSpecs:
		#(	('load repositories' #loadRepositories)
		 	('save repositories' #saveRepositories)
			('flush cached versions' #flushCachedVersions))
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> repositorySelection [
	^ self repositories indexOf: self repository
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> repositorySelection: aNumber [
	aNumber = 0
		ifTrue: [self repository: nil]
		ifFalse: [self repository: (self repositories at: aNumber)].
	self changed: #repositorySelection.
	self changedButtons.

]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> representsSameBrowseeAs: anotherModel [
	^ self class = anotherModel class
]

{ #category : #actions }
MCWorkingCopyBrowser >> revertPackage [
	self pickAncestorVersionInfo ifNotNil: [:info |
		(self repositoryGroup versionWithInfo: info
			ifNone: [^self inform: 'No repository found for ', info name]
		) load]
]

{ #category : #actions }
MCWorkingCopyBrowser >> saveRepositories [
	FileStream forceNewFileNamed: 'MCRepositories.st' do: [:f |
		MCRepositoryGroup default repositoriesDo: [:r |
			r asCreationTemplate ifNotNil: [:template |
				f nextPutAll: 'MCRepositoryGroup default addRepository: (', template , ')!'; cr]]]
]

{ #category : #actions }
MCWorkingCopyBrowser >> saveVersion [
	| repo |
	self canSave ifFalse: [^self].
	self checkForNewerVersions ifFalse: [^self].
	repo := self repository.
	(repo == MCRepository trunk and: [SystemVersion current isFeatureFreeze])
		ifTrue: [self inform: 'FEATURE FREEZE. A new release is being prepared.\Please do only do bugfixes, but no new features.' translated withCRs].
	(repo == MCRepository trunk and: [SystemVersion current isCodeFreeze])
		ifTrue: [self inform: 'CODE FREEZE. The new release is almost ready.\Please do only do URGENT fixes, if any.' translated withCRs].
				
	(self withRepository: repo do: [workingCopy newVersion]) ifNotNil:
		[:v |
		(MCVersionInspector new version: v) show.
		Cursor wait showWhile: [repo storeVersion: v].
		MCCacheRepository default cacheAllFileNamesDuring: 
			[repo cacheAllFileNamesDuring: 
				[v allAvailableDependenciesDo:
					[:dep |
					(repo includesVersionNamed: dep info name)
						ifFalse: [repo storeVersion: dep]]]]]
]

{ #category : #actions }
MCWorkingCopyBrowser >> searchHistory [
	workingCopy ifNotNil:
		[(UIManager default
			edit: (String streamContents:
					[:s|
					"Ignore the initial MCWorkingAncestry instance."
					workingCopy ancestry topologicalAncestors allButFirst
						do: [:versionInfo|
							s nextPutAll: versionInfo summary]
						separatedBy: [s cr; cr"; next: 32 put: $-; cr; cr"]])
			label: 'Version History: ',  workingCopy packageName)
				extent: (0.6@1) * Display height * 0.9]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> toggleDiffs [
	self repository alwaysStoreDiffs
		ifTrue: [self repository doNotAlwaysStoreDiffs]
		ifFalse: [self repository doAlwaysStoreDiffs]
]

{ #category : #actions }
MCWorkingCopyBrowser >> unloadPackage [
	workingCopy unload.
	self workingCopySelection: 0.
	self workingCopyListChanged.
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> unsortedWorkingCopies [
	^ MCWorkingCopy allManagers 
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> update: aSymbol [
	self unsortedWorkingCopies do: [:ea | ea addDependent: self].
	self workingCopyListChanged.
]

{ #category : #actions }
MCWorkingCopyBrowser >> viewChanges [
	| patch |
	self canSave ifTrue:
		[patch := workingCopy changesRelativeToRepository: self repository withCache.
		patch isNil ifTrue: [ ^self ].
		patch isEmpty
			ifTrue: [ workingCopy modified: false.
				self inform: 'No changes' ]
			ifFalse:
				[ workingCopy modified: true.
				(MCPatchBrowser forPatch: patch)
					label: 'Patch Browser: ', workingCopy description;
					environmentInDisplayingImage: workingCopy environment;
					show ] ]
]

{ #category : #actions }
MCWorkingCopyBrowser >> viewHistory [
	workingCopy ifNotNil:
		[(MCWorkingHistoryBrowser new
				ancestry: workingCopy ancestry;
				package: workingCopy package)
			label:  'Version History: ',  workingCopy packageName;
			show]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> widgetSpecs [
	^ #(
		((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight))
		((treeOrListMorph: workingCopy) (0 0 0.5 1) (0 defaultButtonPaneHeight 0 0))
		((listMorph: repository) (0.5 0 1 1) (0 defaultButtonPaneHeight 0 0))
		)
]

{ #category : #actions }
MCWorkingCopyBrowser >> withRepository: aRepository do: aBlock [
	^aBlock
		on: MCRepositoryRequest
		do: [:req | req resume: aRepository]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopies [
	^ MCWorkingCopy allManagers sort:
		[ :a :b | a package name <= b package name ]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopy: wc [
	workingCopy := wc.
	self
		changed: #workingCopySelection;
		changed: #repositoryList;
		changed: #repositorySelection.
	self changedButtons.

]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopyList [
	^ self workingCopies collect:
		[:ea |
		(workingCopy notNil and: [workingCopy requiredPackages includes: ea package])
			ifTrue: [Text string: ea description emphasis: { TextEmphasis bold }]
			ifFalse: [ea description]]
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopyListChanged [
	self changed: #workingCopyList.
	self changed: #workingCopyTree.
	self changedButtons.

]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopyListMenu: aMenu [
	workingCopy ifNil: [^ aMenu].
	self fillMenu: aMenu fromSpecs:
		#(('add required package' #addRequiredPackage)
			('clear required packages' #clearRequiredPackages)
			('add repository...' #addPackageRepository)
			('browse package' #browseWorkingCopy)
			('view changes' #viewChanges)
			('view history' #viewHistory)
			('search history' #searchHistory)
			('recompile package' #recompilePackage)
			('revert package...' #revertPackage)
			('unload package' #unloadPackage)
			('delete working copy' #deleteWorkingCopy)
			('inspect working copy' #inspectWorkingCopy)
			('rename package...' #renamePackage)
			('change environment...' #changeEnvironment)).
	(Smalltalk includesKey: #SARMCPackageDumper) ifTrue: [
		aMenu add: 'make SAR' target: self selector: #fileOutAsSAR
	].
	self fillMenu: aMenu fromSpecs:
		#(	addLine
			('check all packages for changes' #checkAllPackages)).
	self insertExternalMenuEntries: aMenu.
	^aMenu
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopySelection [
	^ self workingCopies indexOf: workingCopy
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopySelection: aNumber [
	self workingCopy: 
		(aNumber = 0 
			ifTrue:[nil]
			ifFalse:[self workingCopies at: aNumber]).	
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopySelectionWrapper [
	^workingCopyWrapper
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopySelectionWrapper: aWrapper [
	workingCopyWrapper := aWrapper.
	self changed: #workingCopySelectionWrapper.
	self workingCopy: (aWrapper ifNotNil:[aWrapper item])
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopyTree [
	^ self workingCopies collect:[:each| MCDependentsWrapper with: each model: self].
]

{ #category : #'morphic ui' }
MCWorkingCopyBrowser >> workingCopyTreeMenu: aMenu [
	^self workingCopyListMenu: aMenu

]
