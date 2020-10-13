"
I'm the script that prepares a trunk image for release.

Just do ""ReleaseBuilder doNextStep"" repeatedly until the next release is done.

For the final release step:
- If you want to try it locally, change #releaseLocally to return true.
- Most of the code operates (read-only) on the #buildRepository, which is usually the trunk. For releases, there is a #releaseRepository, to which some package versions will be copied from trunk.
"
Class {
	#name : #ReleaseBuilder,
	#superclass : #Object,
	#classVars : [
		'DeferredTask',
		'NextMajorVersion',
		'NextMinorVersion',
		'NextTask',
		'QAndA'
	],
	#category : #ReleaseBuilder
}

{ #category : #'scripts - support' }
ReleaseBuilder class >> addAdditionalRepositories [

	MCRepositoryGroup default addRepository: self inboxRepository.

	#(
		'http://www.squeaksource.com/MetacelloRepository'
		'http://www.hpi.uni-potsdam.de/hirschfeld/squeaksource/MetacelloRepository'
			) collect: [:url |
				MCRepositoryGroup default addRepository: (MCHttpRepository
					location: url
					user: 'squeak'
					password: 'squeak')].
]

{ #category : #preparing }
ReleaseBuilder class >> askInAdvance [
	"Preload QAndA with answers to any questions that will be asked during saving."
	"ReleaseBuilder askInAdvance"
	(self systemNavigation allCallsOn: #confirm:orCancel:title: localTo: self class) do:
		[:methodRef|
		 methodRef compiledMethod methodNode nodesDo:
			[:node|
			 (node isMessage
			  and: [node selector key == #confirm:orCancel:title:
			  and: [node receiver isVariableNode
			  and: [node receiver key = 'self']]]) ifTrue:
				[[:questionNode :ingored :titleNode|
				  QAndA
					at: titleNode key
					put: (Project uiManager
							confirm: questionNode key translated
							orCancel: [^self]
							title: titleNode key translated)]
								valueWithArguments: node arguments asArray]]]
]

{ #category : #manual }
ReleaseBuilder class >> assureReleaseRepositoryReadAccess: repo [

	self releaseLocally ifTrue: [
		(FileDirectory on: repo description) assureExistence.
		^ true].
	
	[repo allFileNames] on: NetworkError do: [
		UserDialogBoxMorph
			inform: ('Please create the release repository:\{1}\...and ensure that you have global read access to it.' withCRs
				format: {repo description}) title: 'Release Builder - Manual Step Required'.
		^ false].
	^ true
]

{ #category : #manual }
ReleaseBuilder class >> assureReleaseRepositoryWriteAccess: repo [

	self releaseLocally ifTrue: [^ self].
	
	repo
		user: (UIManager default
			request: 'Enter user for ', repo description
			initialAnswer: (repo user ifEmpty: [Utilities authorInitials]));
		password: (UIManager default
			requestPassword: 'Enter password for ' , repo description).
]

{ #category : #accessing }
ReleaseBuilder class >> buildConfiguration [

	^ self lastConfigurationIn: self buildRepository map: MCMcmUpdater updateMapName
]

{ #category : #accessing }
ReleaseBuilder class >> buildRepository [
	^ MCRepository trunk
]

{ #category : #accessing }
ReleaseBuilder class >> buildRepositoryUrl [
	^ self buildRepository description
]

{ #category : #'scripts - changes' }
ReleaseBuilder class >> changesBetween: startConfiguration and: endConfiguration [
	
	| a b d |
	a := startConfiguration.
	b := endConfiguration.
	d := OrderedDictionary new.

	b dependencies do: [:dep |
		| begin end finished started |
		finished := false. started := false.
		begin := a dependencies
			detect: [:ea | ea package = dep package]
			ifFound: [:x | x versionInfo]
			ifNone: [nil].
		end := dep versionInfo.
		
		d at: dep package put: OrderedDictionary new.
		dep package workingCopy ancestry allAncestorsDo: [:ver |
			started := started or: [(ver name findTokens: '.') last asNumber <= (end name findTokens: '.') last asNumber].
			finished := finished or: [begin notNil and: [(ver name findTokens: '.') last asNumber <= (begin name findTokens: '.') last asNumber]].
			started & finished not ifTrue: [(d at: dep package) at: ver put: ver message]]].
	^ d
]

{ #category : #'scripts - changes' }
ReleaseBuilder class >> changesBetweenReleases [
	
	| repos configs result |
	repos :=#(52) collect: [:ea |
		(MCHttpRepository
		    location: 'http://source.squeak.org/squeak', ea
		    user: 'squeak'
		    password: 'squeak')].
	configs := repos collect: [:ea | ea description -> (self firstConfigurationIn: ea map: 'update')].
	configs := configs, {(self buildRepository description -> self buildConfiguration)}.
	
	result := OrderedDictionary new.
	configs overlappingPairsDo: [:c1 :c2 |
		result
			at: c2 key
			put: (self changesBetween: c1 value and: c2 value)].
		
	^ result
		
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> checkForDirtyPackages [

	| modifiedWorkingCopies unmergedWorkingCopies |
	MCWorkingCopy checkModified: true.
	modifiedWorkingCopies := MCWorkingCopy allManagers
		select: [:wc | wc ancestors size = 1 and: [wc modified] ].
	unmergedWorkingCopies := MCWorkingCopy allManagers
		select: [:wc | (wc ancestors size = 1) not ].

	unmergedWorkingCopies ifNotEmpty: [
		"Sort to simplify exploration. MC browser does also show packages sorted."
		(unmergedWorkingCopies sorted: [:wc1 :wc2 | wc1 packageName <= wc2 packageName]) explore.
		Warning signal: 'There are unmerged packages.'].

	modifiedWorkingCopies ifNotEmpty: [
		"Sort to simplify exploration. MC browser does also show packages sorted."
		(modifiedWorkingCopies sorted: [:wc1 :wc2 | wc1 packageName <= wc2 packageName]) explore.
		
		(self
			confirm: 'Do you want to discard all local changes?'
			orCancel: [^ Error signal: 'Release building canceled.']
			title: 'Dirty Packages Found')
				ifTrue: [modifiedWorkingCopies do: [:wc |
					[(self buildRepository versionWithInfo: wc ancestors first) load]
						on: Warning do: [:warning | warning resume]]]].
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> checkForNilCategories [

	| nilClasses nilMethods |
	nilClasses := OrderedCollection new.
	nilMethods := OrderedCollection new.
	
	SystemNavigation default allClasses
		do: [:cls |
			cls category ifNil: [nilClasses add: cls].
			{cls. cls class} do: [:b | b selectorsAndMethodsDo: [:selector :method |
				(method methodClass organization categoryOfElement: selector) in: [:category |
					(category isNil or: [category = 'nil']) ifTrue: [
						nilMethods add: method methodReference]]]]]
		displayingProgress: [:behavior | 'Checking for invalid categories...'].

	nilMethods ifNotEmpty: [
		SystemNavigation default browseMessageList: nilMethods name: 'Messages with invalid categories ', nilMethods size autoSelect: nil].
	nilClasses ifNotEmpty: [
		nilClasses explore].

	(nilClasses notEmpty or: [nilMethods notEmpty]) ifTrue: [
		Warning signal: 'There are classes or methods with invalid categories!'].
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> checkForUndeclaredSymbols [
	"Parses through all source code in the image and looks for undeclard symbols in those."
	
	| msgs |
	msgs := OrderedCollection new.
	
	SystemNavigation default allClasses
		do: [:cls |
			{cls. cls class} do: [:b | b selectorsAndMethodsDo: [:selector :method |
				| parser ranges |
				parser := SHParserST80 new.
				parser parseAMethod: true.
				ranges := parser
					rangesIn: method getSource
					classOrMetaClass: method methodClass
					workspace: nil
					environment: method methodClass environment.
				(ranges anySatisfy: [:range | range type = #undefinedIdentifier])
					ifTrue: [msgs add: method methodReference]]]]
		displayingProgress: [:behavior | 'Checking for undeclared symbols...'].
	
	msgs ifNotEmpty: [
		SystemNavigation default browseMessageList: msgs name: 'Invalid Messages ', msgs size autoSelect: nil.
		Warning signal: 'There is source code with undeclared symbols!'].
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> cleanUpBitstreamVeraSans [

	| descriptions |
	descriptions := Dictionary new.

	TTFontDescription allInstancesDo: [:tt |
		(tt familyName beginsWith: 'Bitstream Vera')
			ifTrue: [(descriptions at: tt name ifAbsentPut: [Set new]) add: tt]].
	
	TTCFont registry removeAll.
	TTFontDescription clearDefault; clearDescriptions.
	
	descriptions keysAndValuesDo: [:name :tts |
		TextConstants removeKey: name ifAbsent: [].
		tts do: [:ea | TTFontDescription addToDescription: ea]].
	
	TTFontDescription setDefault.
		
	descriptions valuesDo: [:tts |
		(FontImporterTool new importFontFamily: tts) in: [:textStyle |
			TTCFont
				register: textStyle fontArray
				at: textStyle defaultFont name asSymbol]].
]

{ #category : #scripts }
ReleaseBuilder class >> clearCaches [
	"Clear caches, discard unused references, free space."

	"1) Explicit clean-up of FONT-related stuff."
	self cleanUpBitstreamVeraSans.
	StrikeFont initialize.

	"2) FIRST PHASE of explicit clean-up of CODE-related stuff."
	self discardUserObjects.
	MCFileBasedRepository flushAllCaches.

	"3) Now clean-up all STATE-related stuff."
	Smalltalk cleanUp: true.	

	"4) SECOND PHASE of explicit clean-up of CODE-related stuff. As late as possible to get rid of all references before running this."
	Smalltalk garbageCollect.
	Environment allInstancesDo: [:environment | environment purgeUndeclared ].
	Undeclared removeUnreferencedKeys.
	
	
]

{ #category : #preparing }
ReleaseBuilder class >> clearQAndA [
	"Get rid of any previous answers to questions"
	QAndA := Dictionary new
]

{ #category : #scripts }
ReleaseBuilder class >> configureDesktop [
	"Open tools, multimedia content, etc."

	self setDisplayExtent: 1024 @ 768.
	self setProjectBackground: Color darkGray.
	(UserInterfaceTheme named: 'Squeak') apply.
	
	self deleteAllWindows.
	self deleteAllOtherMorphs.

	"Avoid strange drawing issues."
	Project current world allMorphsDo: [:m | m removeProperty: #errorOnDraw].

	"Replace docking bar instance in case its code has changed."
	Project current removeMainDockingBar.
	TheWorldMainDockingBar updateInstances.
]

{ #category : #scripts }
ReleaseBuilder class >> configureProjects [
	"Set up the desired configuration of projects, which might be a single project, multiple projects..."
	
	| homeProject rootProject |
	homeProject := Project current.
	rootProject := homeProject.
	
	homeProject isMorphic ifFalse: [
		Warning signal: 'The current project is not Morphic. Please create a new Morphic project, enter it, and restart the release building process.'].
	
	"The home project is a single Morphic project. Let the home project have a parent MVC project as the root of the project tree. The MVC project supports emergency debugging in the event of unrecoverable Morphic problems, and will fall back on the traditional emergency evaluator if MVC debugging fails. If MVC is not installed in the image, then do nothing."
	Project current removeAllOtherProjects.
	(Smalltalk classNamed: #MVCProject)
		ifNil: [Warning signal: 'MVC must be installed in the release image.']
		ifNotNil: [:mvc | rootProject := mvc new].
		
	rootProject name: 'RootProject'.
	homeProject name: 'HomeProject'. 

	self
		assert: homeProject isTopProject;
		assert: rootProject isTopProject not.

	rootProject beTopProject.

	self
		assert: rootProject isTopProject;
		assert: homeProject isTopProject not.
	
	self
		assert: rootProject subProjects size = 1;
		assert: homeProject parent == rootProject;
		assert: rootProject isMVC.
]

{ #category : #scripts }
ReleaseBuilder class >> configureTools [
	"Initialize well-known tools and other resources."

	FileList initialize. 
	FileServices initialize. "register file reader services"
	RealEstateAgent standardSize: 600 @ 400.
	SMLoaderPlus setDefaultFilters: #(filterSafelyAvailable).
	
	"Default applications and tools."
	SystemBrowser default: Browser.
	MailSender default: nil.
	SoundService default: BaseSoundSystem.
	ToolSet default: StandardToolSet.
	WebBrowser default: nil.

]

{ #category : #'scripts - ui' }
ReleaseBuilder class >> confirm: aString orCancel: cancelBlock title: titleString [
	"Allow questions to be answered in advance."
	^QAndA
		at: titleString
		ifAbsent:
			[Project uiManager
				confirm: aString translated
				orCancel: cancelBlock
				title: titleString translated]
]

{ #category : #manual }
ReleaseBuilder class >> copyPackages [
	"For bootstrapping the contents of the release repository."
	
	self copyPackagesFrom: self buildRepository to: self releaseRepository depth: 1.
]

{ #category : #manual }
ReleaseBuilder class >> copyPackagesFrom: sourceRepository to: targetRepository depth: historyDepth [
	"Copy the packages currently loaded in the image from the source repository to a target repository. Follow ancestry up to the depth specified."
	
	| currentDepth nextVersions currentVersions ignoredVersions |
	currentDepth := 0.
	nextVersions := (MCWorkingCopy allManagers gather: [:wc | wc ancestors]) asOrderedCollection.
	ignoredVersions := OrderedCollection new.

	[nextVersions notEmpty] whileTrue: [
		currentVersions := nextVersions.
		nextVersions := OrderedCollection new.
		currentDepth := currentDepth + 1.
		
		currentVersions do: [:versionInfo | 
			(targetRepository includesVersionNamed: versionInfo versionName)
				ifTrue: [Transcript showln: ('[ReleaseBuilder] Version {1} already exists in {2}'
					format: {versionInfo versionName. targetRepository description})]
				ifFalse: [(sourceRepository versionWithInfo: versionInfo)
					ifNil: [ignoredVersions add: versionInfo]
					ifNotNil: [:version | targetRepository storeVersion: version ] ].
			currentDepth < historyDepth ifTrue: [
				nextVersions addAll: versionInfo ancestors]]].

	ignoredVersions ifNotEmpty: [
		ignoredVersions explore.
		Warning signal: 'There were versions not found in the source repository.'].
]

{ #category : #manual }
ReleaseBuilder class >> copyUpdateMap [
	"For bootstrapping the contents of the release repository."
	
	self copyUpdateMap: self buildConfiguration to: self releaseRepository.
]

{ #category : #manual }
ReleaseBuilder class >> copyUpdateMap: configuration to: targetRepository [

	| newConfig |
	newConfig := MCConfiguration new.
	newConfig repositories add: targetRepository.
	newConfig dependencies addAll: configuration dependencies.
	newConfig name: configuration name.
	
	targetRepository storeVersion: newConfig.
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> deleteAllOtherMorphs [

	Project current world removeAllMorphs.
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> deleteAllWindows [
	(SystemWindow
		windowsIn: Project current world
		satisfying:
			[ : window | true ]) do:
				[ : window | [ window makeClosable; delete ]
					on: ProvideAnswerNotification
					do: [ : noti | noti resume: true ] ]
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> discardUserObjects [

	"Remove the classes."
	Player removeUninstantiatedSubclassesSilently.
	MorphicModel removeUninstantiatedSubclassesSilently.

	"Clean-up environment hick-ups."
	Environment default allClassesDo: [:cls |
		(cls isUniClass and: [cls environment ~~ Environment default])
			ifTrue: [Environment default forgetClass: cls logged: false]].
	Environment default declarations
		select: [:binding | (binding value isBehavior and: [binding value isUniClass]) and: [binding value isObsolete]]
		thenDo: [:binding |
			SystemOrganization removeElement: binding key.
			Environment default removeKey: binding key].		

	"Remove auto-generated accessors. See Preferences."
	(MCPackage named: 'Autogenerated') unload.

	"Remove empty categories for user objects. See Object class >> #categoryForUniclasses."
	SystemOrganizer cleanUp: true.
]

{ #category : #'manual - steps' }
ReleaseBuilder class >> doNextStep [
	"Use this call to perform the manual steps in the release process."
	
	| versionString |
	SystemVersion current isRelease ifTrue: [
		^ self inform: 'This is a release image. Please use a trunk image to prepare the next release'].
	
	versionString := SystemVersion current version.
	
	SystemVersion current isAlpha ifTrue: [^ self step1FeatureFreeze].
	(SystemVersion current isFeatureFreeze and: [SystemVersion current isCodeFreeze not]) ifTrue: [^ self step2CodeFreeze].
	SystemVersion current isReleaseCandidate ifTrue: [
		"Still code freeze and another RC? Or do the release?"
		(UIManager default
			chooseFrom: #('Create next release candidate' 'Create next release' 'Do nothing') lines: #(2)
			title: versionString) in: [:answer |
				answer = 1 ifTrue: [^ self step3NextReleaseCandidate].
				answer = 2 ifTrue: [^ self step4Release]].
		^ self].
]

{ #category : #'scripts - changes' }
ReleaseBuilder class >> fileOutChangesBetweenReleases [
	"Generate mark-down files with all commit messages by release. To be used to write release notes."
	
	| fileNames |
	fileNames := OrderedCollection new.
	
	self changesBetweenReleases keysAndValuesDo: [:location :c |
		fileNames add: ('commits-{1}.md' format: {(location findTokens: '/') last}).
		FileStream forceNewFileNamed: fileNames last do: [:strm |
		c keysAndValuesDo: [:pkg :changes |
			strm nextPutAll: '# '; nextPutAll: pkg name; cr.
			changes keysAndValuesDo: [:ver :msg |
				msg linesDo: [:line | line withBlanksTrimmed ifNotEmpty: [:m |
					(m first isDigit or: [{$*. $-} includes: m first])
						ifTrue: [strm nextPutAll: '   ', m]
						ifFalse: [strm nextPutAll: ' - ', m].
					strm cr]].
				strm nextPutAll: '------------------'; cr]]]].

	self inform: 'Files written:\' withCRs, (fileNames joinSeparatedBy: String cr).
]

{ #category : #'scripts - changes' }
ReleaseBuilder class >> firstConfigurationIn: repo map: map [

	| min versionName |
	min := 999999999.
	versionName := ''.
	
	(repo versionNamesForPackageNamed: map) do: [:nm |
		((nm findTokens: $.) atLast: 2) asInteger in: [:versionNumber |
			versionNumber < min ifTrue: [min := versionNumber. versionName := nm]]].
	
	^ repo versionNamed: versionName 

]

{ #category : #'scripts - ui' }
ReleaseBuilder class >> getBalloonForm [

	^ (FileDirectory default fileExists: 'balloon.png')
		ifFalse: [nil]
		ifTrue: [Form fromFileNamed: 'balloon.png']
]

{ #category : #accessing }
ReleaseBuilder class >> inboxRepository [
	^ MCRepository inbox
]

{ #category : #'class initialization' }
ReleaseBuilder class >> initialize [

	QAndA ifNil: [self clearQAndA].

	"We have to be after AutoStart so that Morphic is up and running."
	Smalltalk addToStartUpList: ReleaseBuilder after: AutoStart.

	SystemVersion newVersion: 'Squeak6.0alpha'
]

{ #category : #'class initialization' }
ReleaseBuilder class >> initializeTemplate [
	
	^ 'initialize

	QAndA ifNil: [self clearQAndA].

	"We have to be after AutoStart so that Morphic is up and running."
	Smalltalk addToStartUpList: ReleaseBuilder after: AutoStart.

	SystemVersion newVersion: ''{1}'''
]

{ #category : #'scripts - changes' }
ReleaseBuilder class >> lastConfigurationIn: repo map: map [

	| max versionName |
	max := 0.
	versionName := ''.
	
	(repo versionNamesForPackageNamed: map) do: [:nm |
		((nm findTokens: $.) atLast: 2) asInteger in: [:versionNumber |
			versionNumber > max ifTrue: [max := versionNumber. versionName := nm]]].
	
	^ repo versionNamed: versionName 

]

{ #category : #'scripts - support' }
ReleaseBuilder class >> loadWellKnownPackages [
	"Load into the release image those packages that have been stripped from Trunk, but still deemed necessary for a release artifact."

	"Not ready yet."
	"Installer new merge: #squeakRelease"
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> openWelcomeWorkspaces [

	self openWelcomeWorkspacesWith: nil.
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> openWelcomeWorkspacesWith: balloonForm [

	| t browser balloon |
	t := HelpTopic title: 'Welcome to Squeak' readOnlyContents: 'Please choose a topic from the left sidebar.'.

	t subtopics
		add: (SqueakHelp asHelpTopic subtopics detect: [:ea | ea key = #introduction]);
		add: SqueakLicenseHelp asHelpTopic;
		add: (SqueakProjectHelp asHelpTopic subtopics detect: [:ea | ea key = #squeakUserInterface]);
		add: (SqueakProjectHelp asHelpTopic subtopics detect: [:ea | ea key = #workingWithSqueak]);
		add: SqueakReleaseNotes asHelpTopic.
	
	browser := HelpBrowser openOn: t.
	browser extent: browser world extent * 0.6.
	browser center: browser world center.
	browser model showFirstTopic.
	
	balloonForm ifNil: [^ self].
	balloon := balloonForm asMorph.
	browser addMorphFront: balloon.
	balloon layoutFrame: (LayoutFrame
		fractions: (0@1 corner: 0@1)
		offsets: (balloon width // 1.7 negated @ (balloon height * 0.9) negated corner: 0@0)).
]

{ #category : #preparing }
ReleaseBuilder class >> prepareEnvironment [
	"Prepare everything that should be done for a new image build. Clear caches, passwords, etc."
	
	| balloon |
	
	self
		clearCaches;
		configureProjects;
		configureTools;
		setPreferences;
		configureDesktop.
	
	balloon := self getBalloonForm. "Get now because later the file might be missing."
	DeferredTask := [
		self openWelcomeWorkspacesWith: balloon.
		PreferenceWizardMorph open].
	
	"If you save-and-quit the image after calling #prepareEnvironment, ensure that the next image startup will be fast."
	Project current world doOneCycle.
]

{ #category : #preparing }
ReleaseBuilder class >> prepareProcesses [
	"Re-start running processes if necessary. Call this at late as possible in the release process. Only required to processes that are not reset at image #startUp."
	
	Delay startTimerEventLoop.
]

{ #category : #preparing }
ReleaseBuilder class >> prepareSourceCode [
	"Update packages. Remove foreign packages. Recompile."

	CurrentReadOnlySourceFiles cacheDuring:
		[self
			updateCorePackages;
			unloadForeignPackages;
			checkForDirtyPackages;
			loadWellKnownPackages;
			checkForUndeclaredSymbols;
			checkForNilCategories;
			recompileAll]
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> recompileAll [

	(Smalltalk classNamed: #EncoderForSistaV1) ifNotNil:
		[:sistaBytecodeSet|
		 CompiledCode preferredBytecodeSetEncoderClass ~~ sistaBytecodeSet ifTrue:
			[(self
				confirm: 'Do you want to make it the default in this release?'
				orCancel: [false]
				title: 'The SistaV1 Bytecode Set Is Available') ifTrue:
					[CompiledCode
						installSecondaryBytecodeSet: sistaBytecodeSet;
						preferredBytecodeSetEncoderClass: sistaBytecodeSet]]].

	Compiler recompileAll
]

{ #category : #accessing }
ReleaseBuilder class >> releaseLocally [
	"If true, use a local, directory-based repository. Usually in the working directory."
	
	^ false
]

{ #category : #accessing }
ReleaseBuilder class >> releaseRepository [

	(MCRepositoryGroup default repositories
		detect: [:repo | repo description = self releaseRepositoryUrl]
		ifNone: [MCRepository location: self releaseRepositoryUrl])
			in: [:repo |
				MCRepositoryGroup default addRepository: repo.
				(self assureReleaseRepositoryReadAccess: repo)
					ifFalse: [ReleaseBuilderFailed signal: 'Could not build the release.'].
				^ repo]
]

{ #category : #accessing }
ReleaseBuilder class >> releaseRepositoryName [

	^ (self versionString copyWithout: $.) asLowercase
]

{ #category : #accessing }
ReleaseBuilder class >> releaseRepositoryUrl [

	^ self releaseLocally
		ifFalse: [self serverUrl, '/', self releaseRepositoryName]
		ifTrue: [(FileDirectory default on: 'repositories', FileDirectory slash, self releaseRepositoryName) fullName]
]

{ #category : #accessing }
ReleaseBuilder class >> releaseVersionMajor [

	^ NextMajorVersion ifNil: [SystemVersion current majorVersionNumber]
]

{ #category : #accessing }
ReleaseBuilder class >> releaseVersionMinor [

	^ NextMinorVersion ifNil: [SystemVersion current minorVersionNumber]
]

{ #category : #manual }
ReleaseBuilder class >> requestNextReleaseVersion [
	"self requestNextReleaseVersion"
	
	| nextMinor nextMajor current |
	current := {
		SystemVersion current majorVersionNumber.
		SystemVersion current minorVersionNumber}.
	nextMinor := {
		current first.
		current second + 1}.
	nextMajor := {
		current first + 1.
		0}.

	(UIManager default
		chooseFrom: {
			'{1}.{2}' format: {nextMinor first. nextMinor second}.
			'{1}.{2}' format: {nextMajor first. nextMajor second}}
		title: 'Please Choose Next Version') in: [:answer |
			answer ifNil: [^ self requestNextReleaseVersion].
			answer = 1 ifTrue: [
				NextMinorVersion := nextMinor second].
			answer = 2 ifTrue: [
				NextMajorVersion := nextMajor first.
				NextMinorVersion := 0]].
]

{ #category : #saving }
ReleaseBuilder class >> saveAndQuit [

	Smalltalk condenseChanges.
	Smalltalk snapshot: true "Important to sync changes and image!" andQuit: false.
	
	"Finally, we have to make sure that all method activations are up to date."
	self prepareProcesses.
	
	"Start new UI process; terminate current one."
	self assert: Processor activeProcess == Project current uiProcess.
	Project current
		addDeferredUIMessage: [Smalltalk snapshot: true andQuit: true];
		spawnNewProcessIfThisIsUI: Processor activeProcess.
	Processor activeProcess terminate.
]

{ #category : #saving }
ReleaseBuilder class >> saveAsNewClean [
	"Use this to create clean up the current image and save it under a new name."

	| fileName |
	(Project uiManager
		confirm: 'This will update and clean-up the current image,\which is then saved under a new name.\\Do you want to continue?' withCRs
		title: 'Prepare Clean Image') == true ifFalse: [^ self].

	"Prepare first so that we can propose an appropriate file name."
	self
		prepareSourceCode;
		prepareEnvironment.

	fileName := ('{1}-{2}-{3}-{4}bit-i{5}.image' format: {
		SystemVersion current version.
		SystemVersion current highestUpdate.
		CompiledCode preferredBytecodeSetEncoderClass name allButFirst: 'EncoderFor' size.
		Smalltalk wordSize * 8.
		Smalltalk imageFormatVersion}).
	
	fileName := Project uiManager
		saveFilenameRequest: 'Save clean image as...' translated
		initialAnswer: fileName.
	fileName ifNil: [^ self].
	
	Smalltalk saveAs: fileName.
	self saveAndQuit.
]

{ #category : #saving }
ReleaseBuilder class >> saveAsNewRelease [
	"Use this to create a new release image to be used in the automated release artifact building process on http://www.github.com/squeak-smalltalk/squeak-app."

	| fileName |
	self setNewSystemVersion: self versionString.
	self assert: self versionString = SystemVersion current version.
	
	fileName := ('squeak-{1}.{2}{3}' format: {
		SystemVersion current majorVersionNumber.
		SystemVersion current minorVersionNumber.
		self releaseLocally ifTrue: ['-offline'] ifFalse: ['']}).
	Smalltalk saveAs: fileName.

	"Update the image state."
	self
		prepareSourceCode;
		prepareEnvironment;
		switchToNewRepository: self releaseRepository;
		addAdditionalRepositories.
	
	self saveAndQuit.
]

{ #category : #saving }
ReleaseBuilder class >> saveAsNewTrunk [
	"Use this to create a new release image to be used in the automated release artifact building process on http://www.github.com/squeak-smalltalk/squeak-app."

	| fileName |	
	fileName := ('squeak-trunk{1}' format: {
		self releaseLocally ifTrue: ['-offline'] ifFalse: ['']}).
	Smalltalk saveAs: fileName.
	
	self
		prepareSourceCode;
		prepareEnvironment;
		switchToNewRepository: self buildRepository.
	
	self saveAndQuit.
]

{ #category : #saving }
ReleaseBuilder class >> saveClean [
	"Use this to create clean up the current image and save it under a new name."

	(Project uiManager
		confirm: 'This will update and clean-up the current (!) image,\which is then saved under the same (!) name.\\Do you want to continue?' withCRs
		title: 'Clean Image') == true ifFalse: [^ self].

	self
		prepareSourceCode;
		prepareEnvironment.
		
	self saveAndQuit.
]

{ #category : #accessing }
ReleaseBuilder class >> serverUrl [ 
	^ 'http://source.squeak.org'
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> setDisplayExtent: extent [

	[
		DisplayScreen
			fullScreenOff;
			setNewScreenSize: extent.
	] on: Error do: [:err | 
		Transcript showln: ('[ReleaseBuilder] Failed to set display extent to: {1}. Keep {2}.' format: {extent. Display extent})].
]

{ #category : #manual }
ReleaseBuilder class >> setNewSystemVersion: version [

	| implementingClass initializeMethodSource |
	initializeMethodSource := self initializeTemplate format: {version}.
	implementingClass := self class whichClassIncludesSelector: #initialize.
	(implementingClass >> #initialize) getSource asString ~= initializeMethodSource ifTrue:
		[implementingClass
			compile: initializeMethodSource
			classified: 'class initialization'].

	self initialize.
	self assert: (SystemVersion current version beginsWith: self versionString).
	
	SystemVersion current isRelease ifFalse: [
		self inform: ('You just changed the system version to {1}.\Please upload the changed ''ReleaseBuilder'' package to\\   {2}\\so that this version change will be official.' translated withCRs format: {SystemVersion current version. self buildRepository description})]
]

{ #category : #scripts }
ReleaseBuilder class >> setPreferences [
	"Preferences class defaultValueTableForCurrentRelease"

"	Preferences outOfTheBox."  "<-- uncomment after #defaultValueTableForCurrentRelease is fixed up."

	"General User interaction"
	Preferences
		enable: #generalizedYellowButtonMenu ;
		enable: #swapMouseButtons;
		disable: #mouseOverForKeyboardFocus.
	Morph indicateKeyboardFocus: true.
	Project uiManager openToolsAttachedToMouseCursor: false.
	SearchBar useScratchPad: false.
	
	HandMorph sendMouseWheelToKeyboardFocus: false.
	HandMorph synthesizeMouseWheelEvents: true.
	
	"Text input."
	TextEditor
		 autoEnclose: true ;
		 autoIndent: true ;
		 encloseSelection: false ;
		 destructiveBackWord: false ;
		 blinkingCursor: true ;
		 dumbbellCursor: false.
	PluggableTextMorph simpleFrameAdornments: false.
	TextMorphForEditView draggableTextSelection: true.
	
	"Windows"
	SystemWindow reuseWindows: false.
	SystemWindow windowsRaiseOnClick: true.
	SystemWindow windowTitleActiveOnFirstClick: true.
	Model windowActiveOnFirstClick: false. "Not good for little screen real estate."
	Model useColorfulWindows: false. 

	Preferences
		disable: #fastDragWindowForMorphic.
	AbstractResizerMorph
		gripThickness: 4;
		handleLength: 25.
	CornerGripMorph
		drawCornerResizeHandles: false;
		drawEdgeResizeHandles: false.
	ProportionalSplitterMorph
		showSplitterHandles: false;
		smartHorizontalSplitters: false;
		smartVerticalSplitters: false.

	"Scroll bars."
	Preferences
		enable: #scrollBarsNarrow;
		enable: #scrollBarsOnRight;
		enable: #alwaysHideHScrollbar;
		disable: #alwaysShowHScrollbar;
		disable: #alwaysShowVScrollbar.
	ScrollBar
		scrollBarsWithoutArrowButtons: true;
		scrollBarsWithoutMenuButton: true.
	ScrollPane
		useRetractableScrollBars: false.

	"Rounded corners."
	Morph preferredCornerRadius: 8.
	SystemWindow roundedWindowCorners: false.
	DialogWindow roundedDialogCorners: false.
	MenuMorph roundedMenuCorners: false.
	PluggableButtonMorph roundedButtonCorners: false.
	ScrollBar roundedScrollBarLook: false.
	
	"Gradients."
	SystemWindow gradientWindow: false.
	DialogWindow gradientDialog: false.
	MenuMorph gradientMenu: false.
	PluggableButtonMorph gradientButton: false.
	ScrollBar gradientScrollBar: false.

	"Shadows"
	Preferences enable: #menuAppearance3d.
	Morph useSoftDropShadow: true.
	
	"Lists and Trees"
	PluggableListMorph
		filterableLists: true;
		clearFilterAutomatically: false;
		clearFilterDelay: 500;
		highlightHoveredRow: true;
		highlightPreSelection: false;
		menuRequestUpdatesSelection: true.
	PluggableTreeMorph
		filterByLabelsOnly: false;
		maximumSearchDepth: 1.
	
	"Standard Tools"
	TheWorldMainDockingBar
		showWorldMainDockingBar: true;
		showSecondsInClock: true;
		twentyFourHourClock: true.
	SearchBar useSmartSearch: true.
	Workspace shouldStyle: false.
	TranscriptStream
		forceUpdate: true;
		redirectToStdOut: false;
		characterLimit: 20000.
	Browser
		listClassesHierarchically: true;
		showClassIcons: true;
		showMessageIcons: true;
		sortMessageCategoriesAlphabetically: true.
	MessageSet useUnifiedMessageLabels: true.
	Preferences enable: #annotationPanes;
		 enable: #optionalButtons;
		 disable: #diffsWithPrettyPrint;
		 enable: #traceMessages;
		 enable: #alternativeBrowseIt;
		 enable: #menuWithIcons;
		 enable: #visualExplorer.
	Preferences disable: #debugLogTimestamp.

	"Halo"
	Preferences
		enable: #showBoundsInHalo ;
		disable: #alternateHandlesLook;
		disable: #showDirectionHandles.
	Morph
		haloForAll: true;
		metaMenuForAll: true.

	"System"
	NetNameResolver enableIPv6: false.
	Scanner
		allowUnderscoreAsAssignment: true;
		prefAllowUnderscoreSelectors: true.
		
	Deprecation showDeprecationWarnings: true

	"that's all, folks"
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> setProjectBackground: aFormOrColorOrFillStyle [

	| world |
	world := Project current world.
	world fillStyle: aFormOrColorOrFillStyle.
	MorphicProject defaultFill: world fillStyle.
	world removeProperty: #hasCustomBackground.
]

{ #category : #'class initialization' }
ReleaseBuilder class >> startUp: resuming [
	resuming
		ifTrue: [DeferredTask ifNotNil: [:task | DeferredTask := nil. task value]]
		ifFalse: [NextTask ifNotNil: [:task | NextTask := nil. task value]].
]

{ #category : #'manual - steps' }
ReleaseBuilder class >> step0AssureAlpha [
	"Re-open the trunk again."
	
	self requestNextReleaseVersion.
	self setNewSystemVersion: self versionString, 'alpha'.
]

{ #category : #'manual - steps' }
ReleaseBuilder class >> step1FeatureFreeze [

	(UIManager default
		confirm: ('Do you really want to feature-freeze the trunk\in preparation for the next release {1}?\Bugfixes only after this.' withCRs format: {self versionString})
		title: 'Release Builder Step 1 of 4: Feature Freeze') ifFalse: [^ self].

	self setNewSystemVersion: self versionString, 'beta'.
]

{ #category : #'manual - steps' }
ReleaseBuilder class >> step2CodeFreeze [
	"Creates the first release candidate."
	
	(UIManager default
		confirm: ('Do you really want to code-freeze the trunk\in preparation for the next release {1}?\Urgent fixes only after this.' withCRs format: {self versionString})
		title: 'Release Builder Step 2 of 4: Code Freeze') ifFalse: [^ self].
	
	self setNewSystemVersion: self versionString, 'rc', (SystemVersion current releaseCandidateNumber + 1) asString.
]

{ #category : #'manual - steps' }
ReleaseBuilder class >> step3NextReleaseCandidate [
	"Creates additional release candidates."
	"update version, update post load script, add stuff commit"
	
	(UIManager default
		confirm: ('Do you want create another release candidate\for the next release {1}?\Urgent fixes still possible.' withCRs format: {self versionString})
		title: 'Release Builder Step 3 of 4: Release Candidate') ifFalse: [^ self].
	
	self setNewSystemVersion: self versionString, 'rc', (SystemVersion current releaseCandidateNumber + 1) asString.
]

{ #category : #'manual - steps' }
ReleaseBuilder class >> step4Release [
	"Creates the release. New file, clean-ed up."
	
	(UIManager default
		confirm: ('Do you want release {1}{2}?' withCRs format: {
						self versionString.
						(self releaseLocally ifTrue: [' locally'] ifFalse: [''])})
		title: 'Release Builder Step 4 of 4: The Release')
		 ifFalse: [^ self].
	
	"If you re-open the current trunk image again, it will be an alpha version for the next release."
	DeferredTask := [self step0AssureAlpha].
	
	"We continue with preparing the release image."
	NextTask := [self saveAsNewRelease].
	
	"Now save it but do not quit."
	Smalltalk snapshot: true andQuit: false.
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> switchToNewRepository: anMCRepository [ 
	MCMcmUpdater defaultUpdateURL: anMCRepository description.
	MCRepositoryGroup reset.
	MCRepositoryGroup default addRepository: anMCRepository.
	MCWorkingCopy allManagers do:
		[ : each | each repositoryGroup:
			(MCRepositoryGroup new
				 addRepository: anMCRepository ;
				 addRepository: MCRepository inbox ;
				 addRepository: MCRepository treated ;
				 yourself) ]
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> unloadForeignPackages [
	"Removes all packages that are not present in the build configuration."
	
	self buildConfiguration in: [:config |
		MCWorkingCopy allManagers
			reject: [:wc | config dependencies anySatisfy: [:dep | dep package name = wc package name]]
			thenDo: [:wc | wc unload]].
]

{ #category : #'scripts - support' }
ReleaseBuilder class >> updateCorePackages [
	"Update code."

	MCMcmUpdater
		defaultUpdateURL: self buildRepository description;
		updateMissingPackages: true;
		enableUpdatesForAllPackages.

	TestCase new ensureInternetConnectionTo: self buildRepository description.
	
	"Flush all caches. If a previous download failed this is often helpful"
	MCFileBasedRepository flushAllCaches.

	"Save the current default updater, clear the registry, and re-register the current updater"
	MCMcmUpdater clearRegistry.

	[MCMcmUpdater default doUpdate: false "non-interactive"]
		on: MCEmptyVersion
		do: [:warning | warning resume]
]

{ #category : #manual }
ReleaseBuilder class >> uploadNewSystemVersion [
	"TODO: Just commit changes in the ReleaseBuilder because #initialize will change the system version:"
	
	UIManager default
		confirm: 'Do you want to set the new system version for all?'
		title: 'Publish New System Version'.
		
		
	self inform: 'Upload not implemented.'.
]

{ #category : #accessing }
ReleaseBuilder class >> versionString [
	"Result format is specified in SystemVersion."
	^ 'Squeak{1}.{2}' format: {self releaseVersionMajor. self releaseVersionMinor}
]

{ #category : #accessing }
ReleaseBuilder class >> versionStringAlpha [
	"Result format is specified in SystemVersion."
	^ 'Squeak{1}.{2}alpha' format: {self releaseVersionMajor. self releaseVersionMinor+1}
]
