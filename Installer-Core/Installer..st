"
Installer is a mechanism for listing, examining and installing software from a variety of sources. It is intended to help in building install scripts for package setups etc.

Currently it can use
	- files; a file specified by a filename. Relative filenames will be treated as based form the current default directory. See InstallerFile.
	- urls; a file specified by a url or a script embedded in a webpage. See InstallerWeb.
	- squeakmap; see InstallerSqueakMap
	- monticello;  by ftp or http access, or a local directory, or a Magma or GOODS database. There is a list of shortcuts to popular repositories in this class protocol 'repositories'. See InstallerMonticello.
	- mantis; accessing code attached to a mantis bug report. See InstallerMantis.

Simple example usages - 
Installer squeakmap install: 'DynamicBindings'.
Installer squeakmap search: '*scratch'.
Installer squeakmap search: 'author:*rowledge'.
Installer squeaksource project: 'ss2'; install: 'TinyWiki'.
Installer ss project: 'Installer'; browse: 'Installer-Core'.

 
useFileIn - flag to load source.st rather than using Monticello
"
Class {
	#name : #Installer,
	#superclass : #Object,
	#instVars : [
		'answers',
		'packages',
		'messagesToSuppress',
		'useFileIn',
		'noiseLevel'
	],
	#classVars : [
		'InstallerBindings',
		'IsSetToTrapErrors',
		'Repositories',
		'SkipLoadingTests',
		'ValidationBlock'
	],
	#classInstVars : [
		'localRepository'
	],
	#category : #'Installer-Core'
}

{ #category : #'action report' }
Installer class >> actionMatch: theLine reportOn: report ifNoMatch: aBlock [

	| line |	
	line := theLine withBlanksCondensed.
	self allSubclassesDo: [:class |
		(class canReportLine: line)
		ifTrue: [ ^ class new action: theLine reportOn: report ]].
	^ aBlock value
]

{ #category : #'repository-overrides' }
Installer class >> airplaneMode [
	"Override all remote repositories with the package cache."
	self overrideRemoteRepostoriesWith: MCCacheRepository default
]

{ #category : #documentation }
Installer class >> asHelpTopic [
	^HelpTopic
		title: 'Installer'
		contents: self class comment
]

{ #category : #'action report' }
Installer class >> bootstrapTheRestOfInstaller [

	(Installer url: 'www.squeaksource.com/Installer/Installer-Scripts')  
			fileInSource;
			logCR: 'installer bootstrap - loaded'.
]

{ #category : #mantis }
Installer class >> bug: n fix: filename [

	Transcript cr; show: 'Code script in Mantis:', n asString, ' should read Installer mantis bug: ',n asString, ' fix: ', filename printString,'.'.
	
	^ self mantis bug: n fix: filename
]

{ #category : #monticello }
Installer class >> cache [
	^ self monticello cache
]

{ #category : #'action report' }
Installer class >> canReportLine: line [
	^ false
]

{ #category : #accessing }
Installer class >> cancelSkipLoadingTests [
	"sets a flag to un-ignore loading of the testing portion of scripts embedded in pages"
	
	SkipLoadingTests := false.
 
]

{ #category : #'repository-overrides' }
Installer class >> clearOverrides [
	"Remove all repository overrides and load everthing from the specified default repositories when using #merge:."
	Repositories := Dictionary new
]

{ #category : #debug }
Installer class >> debug [

	IsSetToTrapErrors := false
]

{ #category : #'repository-overrides' }
Installer class >> defaultLocalRepository [
	"Check for a personal, Magma-indexed SqueakSource server first, if none running, the the 'mc' directory in the current directory."
	| localSqueaksource |
	localSqueaksource := Installer monticello http: 'http://localhost:8079'.
	^ localSqueaksource mc isIndexed
		ifTrue: [localSqueaksource]
		ifFalse: [Installer monticello directory: FileDirectory default / 'mc']
]

{ #category : #private }
Installer class >> defaultRepositoryFor: anAssociation [
	"private -- answer the MC repository specified by anAssociation."
	^ (self perform: anAssociation key)
		 project: anAssociation value ;
		 mc
]

{ #category : #'launcher support' }
Installer class >> do: webPageName [

	| rs |
	rs := webPageName readStream.
	[ rs atEnd ] whileFalse: [ self install: (rs upTo: $;) ].

]

{ #category : #scripts }
Installer class >> ensureRecentMetacello [
	"Copied and adapted from https://github.com/Metacello/metacello/blob/master/README.md"
	
	| metacello |
	((Smalltalk classNamed: #WebClient)
		ifNil: [ false ]
		ifNotNil: [ :webClient | 
			[ (webClient httpHead: 'https://github.com') isSuccess ] 
				on: Error
				do: [ false ] ])
		ifFalse: [ ^self inform: 'Could not connect to "https://github.com".\\You need an internet connection and SSL support\to install (or update) Metacello.\\Please fix those issues and try again.' translated withCRs ].
	
	self isMetacelloInstalled ifFalse: [
		"Prepare a clean environment for it."
		Smalltalk globals removeKey: #Metacello.
		"Get the Metacello configuration (for Squeak users)"
		Installer gemsource
			project: 'metacello';
			addPackage: 'ConfigurationOfMetacello';
			install.

		"Bootstrap Metacello Preview, using mcz files (#'previewBootstrap' symbolic version"
		((Smalltalk classNamed: #ConfigurationOfMetacello) project 
			version: #'previewBootstrap') load].

	metacello := Smalltalk classNamed: #Metacello.

	"Now load latest version of Metacello"
	metacello new
		baseline: 'Metacello';
		repository: 'github://Metacello/metacello:master/repository';
		get.
	metacello new
		baseline: 'Metacello';
		repository: 'github://Metacello/metacello:master/repository';
		load: #('default' 'Metacello-Help').

]

{ #category : #file }
Installer class >> file [

	^ InstallerFile new
]

{ #category : #file }
Installer class >> file: fileName [
 
	^ InstallerFile new file: fileName; yourself

]

{ #category : #url }
Installer class >> fromUrl: aUrl [

	"try and pick an Installer appropriate for the Url"
	| inst | 
	((aUrl endsWith: '.mcz') or: [ aUrl endsWith: '.mcm' ])
	ifTrue: [ inst := Installer mc fromUrl: aUrl.
		inst packages isEmpty ifFalse: [ ^ inst ]
	] .
	
	^ Installer url: aUrl 
	
]

{ #category : #repositories }
Installer class >> gemsource [

	^ self monticello http: 'http://seaside.gemtalksystems.com/ss'
]

{ #category : #repositories }
Installer class >> gs [

	^ self gemsource
]

{ #category : #scripts }
Installer class >> installAndOpenGitBrowser [
	self installGitInfrastructure.
	(Smalltalk at: #SquitBrowser) open.
]

{ #category : #file }
Installer class >> installFile: fileName [
 
	^ (self file: fileName) install.

]

{ #category : #scripts }
Installer class >> installGitInfrastructure [
| priorSetting |
"for INIFileTest>>#testComplexRead"
priorSetting := Scanner allowUnderscoreAsAssignment.
Scanner allowUnderscoreAsAssignment: true. 

	(Smalltalk at: #Metacello) new
		  baseline: 'Squot';
		  repository: 'github://hpi-swa/Squot:master/src';
		  load.

Scanner allowUnderscoreAsAssignment: priorSetting

]

{ #category : #url }
Installer class >> installSilentlyUrl: urlString [

	^ SystemChangeNotifier uniqueInstance doSilently: [ self url url: urlString; install ].

]

{ #category : #url }
Installer class >> installUrl: urlString [

	^ self url url: urlString; install.

]

{ #category : #scripts }
Installer class >> isMetacelloInstalled [
	"Squeak is shipped with the global #Metacello referring to lightweight MetacelloStub.  After the first message is sent, the latest Metacello is installed, replacing the stub."
	^ (Smalltalk at: #Metacello) ~= MetacelloStub
]

{ #category : #repositories }
Installer class >> krestianstvo [
	"Krestianstvo SDK code repository."
	^ self monticello http: 'http://sdk.krestianstvo.org/sdk/'
]

{ #category : #'launcher support' }
Installer class >> launchFrom: launcher [

	^self launchWith: launcher getParameters
]

{ #category : #'launcher support' }
Installer class >> launchHelp [

^'path=/dir/*.txt          Specify a search path for the item to install
p=/dir1/*.txt;<url2>/    Multiple items delimited by ;
                         The page name is typically appended to the path string, or
                         if a "*" is present, it will be replaced by the page name.
					
in,i,install=<page>      Page appended to the path to begin the install process
url,u=<url>              Install using an explicit url from which to obtain a script or file
file=<url>                Install using a local file
+debug                   Do not trap errors
view=<page>              Print the script that would have been installed.

For more options use Script eval="Installer ... " 
'

]

{ #category : #'launcher support' }
Installer class >> launchWith: params [

 	params at: 'P' ifPresent: [ :v | params at: 'PATH' put: v ].
 	params at: 'I' ifPresent: [ :v | params at: 'INSTALL' put: v ].
 	params at: 'IN' ifPresent: [ :v | params at: 'INSTALL' put: v ].
 	params at: 'U' ifPresent: [ :v | params at: 'URL' put: v ].

	params at: 'PATH' ifPresent: [ :v | 
		self webSearchPathFrom: v.
	].

	params at: 'USER' ifPresent: [ :v | 
		Utilities authorInitials: v
	].
	params at: 'VERSION' ifPresent: [ :v | 
		SystemVersion current version: v
	].
	params at: 'VIEW' ifPresent: [ :v |
		self view: v
	].

	IsSetToTrapErrors := true.
	params at: 'DEBUG' ifPresent: [ :v | IsSetToTrapErrors := (v == true) not ].

 	params at: 'URL' ifPresent: [ :v | 
		 self installUrl: v
	].

	params at: 'FILE' ifPresent: [ :v | 
		 self installFile: v
	].
 
 	params at: 'INSTALL' ifPresent: [ :v | 
		  self do: v
	].
	params at: 'DO' ifPresent: [ :v | 
		  self do: v
	].
 
	 ^true

	
]

{ #category : #repositories }
Installer class >> local [
	^ self localRepository
]

{ #category : #'repository-overrides' }
Installer class >> localRepository [
	^ localRepository ifNil: [self defaultLocalRepository]
]

{ #category : #'repository-overrides' }
Installer class >> localRepository: aMCRepository [ 
	localRepository := aMCRepository
]

{ #category : #logging }
Installer class >> log: aString [

	Transcript show: aString; cr.
]

{ #category : #repositories }
Installer class >> lukas [

	^ self monticello http: 'http://source.lukas-renggli.ch'
]

{ #category : #mantis }
Installer class >> mantis [

	^ self mantis: 'http://bugs.squeak.org/'
]

{ #category : #mantis }
Installer class >> mantis: host [

	^ InstallerMantis host: host
]

{ #category : #monticello }
Installer class >> mc [

	^ self monticello
]

{ #category : #monticello }
Installer class >> monticello [

	^ InstallerMonticello new
]

{ #category : #debug }
Installer class >> noDebug [

	IsSetToTrapErrors := true
]

{ #category : #during }
Installer class >> noProgressDuring: block [
	[ block value: self ] 
		on: ProgressInitiationException 
		do: [ : note | note sendNotificationsTo: [ :min :max :curr | "ignore" ] ]
]

{ #category : #'repository-overrides' }
Installer class >> overrideRemoteRepostoriesWith: aMCRepositoryOrGroup [
	self remoteRepositories do:
		[ : each | self
			overrideRepository: each
			with: aMCRepositoryOrGroup ]
]

{ #category : #'repository-overrides' }
Installer class >> overrideRepository: scope with: anMCRepository [ 
	"When configuring the image with #merge:, override the standard repository specified by scope with anMCRepository."
"Installer
	override: #ss3->'htmlcssparser'
	with: (MCDirectoryRepository directory: (FileDirectory default / 'mc'))."
"Installer
		override: #ss
		with: #ssMirror."
	self repositories
		at: scope
		put: anMCRepository
]

{ #category : #repositories }
Installer class >> packageCache [
	^ MCCacheRepository default
]

{ #category : #web }
Installer class >> path: aString [
	"convenience abbreviation"
	
	self webSearchPathFrom: aString
]

{ #category : #instanciation }
Installer class >> privateUpgradeTheRest [

	Installer ss project: 'Installer'; 
		installQuietly: 'Installer-Scripts';
		installQuietly: 'Installer-Formats'..
		
	^ self
]

{ #category : #'repository-overrides' }
Installer class >> remoteRepositories [
	^ #(#ss #ss3 #gemsource #gs #krestianstvo #lukas #squeak #squeakfoundation #squeaksource #squeaksource3 #ss #ss3 #swa #swasource #wiresong )
]

{ #category : #'repository-overrides' }
Installer class >> removeOverride: scope [
	"Remove override specified by scope and return to using the default repository for packages within that scope."
	^ self repositories
		removeKey: scope
		ifAbsent: [  ]
]

{ #category : #accessing }
Installer class >> repositories [
	^ Repositories ifNil: [ Repositories := Dictionary new ]
]

{ #category : #monticello }
Installer class >> repository: host [  

	^self monticello http: host 
]

{ #category : #private }
Installer class >> repositoryFor: anAssociation [
	"private -- anAssociation key is the repository selector Symbol understood by Intsaller class.  It's value is the project name within that HTTP repository."
	| rep |
	rep := self repositories
		at: anAssociation  "<-- check for #rep->project overrides first"
		ifAbsent:
			[ self repositories
				at: anAssociation key "<-- override an entire repository."
				ifAbsent: [ ^ self defaultRepositoryFor: anAssociation ]  ].
	^ rep isSymbol
		ifTrue: [ self defaultRepositoryFor: rep -> anAssociation value ]
		ifFalse: [ rep ]
]

{ #category : #documentation }
Installer class >> sf [

	^ self squeakfoundation
 
]

{ #category : #accessing }
Installer class >> skipLoadingTests [
	"sets a flag to ignore loading of the testing portion of scripts embedded in pages"
	
	SkipLoadingTests := true.
 
]

{ #category : #during }
Installer class >> skipLoadingTestsDuring: block [

	| oldValue |

	oldValue := SkipLoadingTests.
	SkipLoadingTests := true.
	
	[ block value: self ] ensure:[ SkipLoadingTests := oldValue ].
]

{ #category : #squeakmap }
Installer class >> sm [

	^ self squeakmap
]

{ #category : #repositories }
Installer class >> squeak [

	^self monticello http: 'source.squeak.org'
]

{ #category : #repositories }
Installer class >> squeakInbox [

	^self squeak project: 'inbox'
]

{ #category : #repositories }
Installer class >> squeakTrunk [

	^self squeak project: 'trunk'
]

{ #category : #repositories }
Installer class >> squeakfoundation [

	^ self monticello http: 'source.squeakfoundation.org'
]

{ #category : #squeakmap }
Installer class >> squeakmap [

	^ InstallerSqueakMap new sm: true; yourself
]

{ #category : #repositories }
Installer class >> squeaksource [

	^ self monticello http: 'http://www.squeaksource.com'
]

{ #category : #repositories }
Installer class >> squeaksource3 [
	^ self monticello http: 'http://ss3.gemtalksystems.com/ss/'
]

{ #category : #repositories }
Installer class >> ss [

	^ self squeaksource
 
]

{ #category : #repositories }
Installer class >> ss3 [
	^ self squeaksource3.
]

{ #category : #'repository-overrides' }
Installer class >> suspendRepositoryOverridesWhile: aBlock [ 
	| priorOverrides |
	[ priorOverrides := Repositories.
	self clearOverrides.
	aBlock value ] ensure: [ Repositories := priorOverrides ]
]

{ #category : #repositories }
Installer class >> swa [

	^ self swasource
]

{ #category : #repositories }
Installer class >> swasource [
	"Visit: https://www.hpi.uni-potsdam.de/hirschfeld/trac/SqueakCommunityProjects
		Installer swasource project: 'MetacelloRepository'; open.
		Installer swasource project: 'SwaUtilities'; open.
	"
		
	^ self monticello http: 'http://www.hpi.uni-potsdam.de/hirschfeld/squeaksource'
]

{ #category : #accessing }
Installer class >> symbolicPackages [
	^ self methodsInCategory: 'package-definitions'
]

{ #category : #instanciation }
Installer class >> upgrade [

	Installer ss project: 'Installer'; 
		installQuietly: 'Installer-Core'.
			 
	self privateUpgradeTheRest.
	
	^ self
]

{ #category : #url }
Installer class >> url [

	^ InstallerUrl new url: ''
]

{ #category : #url }
Installer class >> url: urlString [

	^self url url: urlString; yourself
]

{ #category : #'repository-overrides' }
Installer class >> useLocalRepository [
	self overrideRemoteRepostoriesWith: #local
]

{ #category : #accessing }
Installer class >> validationBlock [

	^ ValidationBlock
]

{ #category : #accessing }
Installer class >> validationBlock: aBlock [

	ValidationBlock := aBlock
]

{ #category : #instanciation }
Installer class >> view: webPageNameOrUrl [

	| theReport |

	theReport := String streamContents: [ :report | 
	(webPageNameOrUrl beginsWith: 'http://') ifTrue: [ 
		self actionMatch: ('Installer installUrl: ', (webPageNameOrUrl printString),'.')  	
			reportOn: report ifNoMatch: []
	]
	ifFalse: [
		self actionMatch: ('Installer install: ', (webPageNameOrUrl printString),'.')  	
			reportOn: report ifNoMatch: []
	]].

	Workspace new contents: (theReport contents); openLabel: webPageNameOrUrl.

	^theReport contents

]

{ #category : #web }
Installer class >> web [ 
	^ InstallerWeb new
]

{ #category : #web }
Installer class >> webInstall: webPageName [

	^ self web install: webPageName

]

{ #category : #web }
Installer class >> webSearchPath [
	"a search path item, has the following format. prefix*suffix"

	^ self web searchPath
]

{ #category : #web }
Installer class >> webSearchPathFrom: string [

	| reader wsp path |
	reader := string readStream.
	wsp := self webSearchPath.
	[ reader atEnd ] whileFalse: [ 
		path := reader upTo: $;.
		(wsp includes: wsp) ifFalse: [ wsp addFirst: path ]].

	 
]

{ #category : #websqueakmap }
Installer class >> websqueakmap [

	^ InstallerWebSqueakMap new wsm: 'http://map.squeak.org'; yourself
]

{ #category : #websqueakmap }
Installer class >> websqueakmap: host [

	^ InstallerWebSqueakMap new wsm: host; yourself
]

{ #category : #repositories }
Installer class >> wiresong [

	^ self monticello http: 'http://source.wiresong.ca'
]

{ #category : #websqueakmap }
Installer class >> wsm [

	^ self websqueakmap
]

{ #category : #configure }
Installer >> addLocalRepositories [
	"For all MC packages defined in my 'package-definitions', add the local directory repository where they reside."
	self class suspendRepositoryOverridesWhile:
		[ self class useLocalRepository.
		self allPackages do:
			[ : each | self addRepositoryFor: each ] ]
]

{ #category : #'public interface' }
Installer >> addPackage: anObject [

	self packages add: anObject
]

{ #category : #configure }
Installer >> addRemoteRepositories [
	"For all MC packages defined in my 'package-definitions', add the remote repository where they reside."
	self allPackages do:
		[ : each | self class suspendRepositoryOverridesWhile: [ self addRepositoryFor: each ] ]
]

{ #category : #configure }
Installer >> addRepositoryFor: structureOrSymbol [
	self
		packageDependenciesFor: structureOrSymbol
		do:
			[ : eachPackageName : eachRepositorySpec | MCWorkingCopy allManagers
				detect: [ : eachWorkingCopy | eachWorkingCopy packageName = eachPackageName ]
				ifFound: [ : foundWorkingCopy | foundWorkingCopy repositoryGroup addRepository: (self class repositoryFor: eachRepositorySpec) ]
				ifNone: [ nil ] ]
]

{ #category : #accessing }
Installer >> allPackages [
	 | installerClasses | installerClasses := self class withAllSuperclasses.
	installerClasses := installerClasses copyFrom: 1 to: (installerClasses indexOf: Installer).
	^ (installerClasses
		inject: OrderedCollection new
		into:
			[ : coll : each | coll
				 addAll: each symbolicPackages ;
				 yourself ]) sort
]

{ #category : #'auto answering' }
Installer >> answer: aString with: anAnswer [

	^self answers add: ( Array with: aString with: anAnswer )
]

{ #category : #accessing }
Installer >> answers [

	^ answers ifNil: [ answers := OrderedCollection new ]
]

{ #category : #accessing }
Installer >> answers: anObject [

	answers := anObject
]

{ #category : #'public interface' }
Installer >> availablePackages [
	
	^ self basicAvailablePackages
]

{ #category : #'basic interface' }
Installer >> basicAvailablePackages [
]

{ #category : #'basic interface' }
Installer >> basicBrowse [
]

{ #category : #'basic interface' }
Installer >> basicInstall [
]

{ #category : #'basic interface' }
Installer >> basicVersions [
]

{ #category : #'basic interface' }
Installer >> basicView [
]

{ #category : #'script bindings' }
Installer >> bindingOf: aString [ 
self isThisEverCalled: 'Want to get rid of this and the class-var'.
	InstallerBindings isNil ifTrue: [ InstallerBindings := Dictionary new].

	(InstallerBindings includesKey: aString)
		ifFalse: [InstallerBindings at: aString put: nil].

	^ InstallerBindings associationAt: aString.
]

{ #category : #'public interface' }
Installer >> bootstrap [
	"keep for compatability"
	
	self deprecatedApi.

	useFileIn := true.
	self install.
]

{ #category : #'package-definitions' }
Installer >> broomMorphsBase [
	"Morph alignment user-interface tool."
	^ { #ss -> 'Connectors'. 
	'BroomMorphs-Base' }
]

{ #category : #'public interface' }
Installer >> browse [
	self logErrorDuring: [self basicBrowse]
]

{ #category : #'public interface' }
Installer >> browse: packageNameCollectionOrDetectBlock [

	self package: packageNameCollectionOrDetectBlock.
	self browse
]

{ #category : #mantis }
Installer >> browse: aFileName from: stream [
	
	| mcThing ext browseSelector |
		 
	self log: ' browsing...'.
 
		mcThing := self classMCReader ifNotNil: [ self mcThing: aFileName from: stream ].
		
		mcThing 
			ifNotNil: [ (mcThing respondsTo: #snapshot) 
						ifTrue: [ mcThing browse ]
				        	ifFalse: [ (MCSnapshotBrowser forSnapshot: mcThing) showLabelled: 'Browsing ', aFileName ]
			]
			ifNil: [ 
		
				ext := aFileName copyAfterLast: $..
				browseSelector := ('browse', ext asUppercase, ':from:') asSymbol.
	
				(self respondsTo: browseSelector)
					ifTrue: [ self perform: browseSelector with: aFileName with: stream ]
					ifFalse: [ self browseDefault: aFileName from: stream ].
			]
]

{ #category : #mantis }
Installer >> browseCS: aFileName from: stream [
 	
	| list |
	
	list := self classChangeList new
			scanFile: stream from: 1 to: stream size.
		 
	self classChangeList open: list name: aFileName
		multiSelect: true.

]

{ #category : #mantis }
Installer >> browseDefault: aFileName from: stream [

	self view: aFileName from: stream
]

{ #category : #mantis }
Installer >> browseGZ: aFileName from: stream [ 
	"FileIn the contents of a gzipped stream"

	| zipped unzipped |
	zipped := self classGZipReadStream on: stream.
	unzipped := MultiByteBinaryOrTextStream with: zipped contents asString.
	unzipped reset.
	ChangeList browseStream: unzipped
	
]

{ #category : #utils }
Installer >> changeSetNamed: aName [

	(ChangeSet respondsTo: #named:)
		ifTrue: [ ^ ChangeSet named: aName ].
		
	^ ChangeSorter changeSetNamed: aName.
]

{ #category : #'class references' }
Installer >> classChangeList [

	^Smalltalk at: #ChangeList  ifAbsent: [ self error: 'ChangeList not present' ]
]

{ #category : #'class references' }
Installer >> classChangeSet [

	^Smalltalk at: #ChangeSet  ifAbsent: [ self error: 'ChangeSet not present' ]
]

{ #category : #'class references' }
Installer >> classChangeSorter [

	^Smalltalk at: #ChangeSorter ifAbsent: [ self error: 'ChangeSorter not present' ]
]

{ #category : #'class references' }
Installer >> classGZipReadStream [

	^Smalltalk at: #GZipReadStream  ifAbsent: [ self error: 'Compression not present' ]
]

{ #category : #'class references' }
Installer >> classMCReader [

	^Smalltalk at: #MCReader ifAbsent: [ nil ]
	
]

{ #category : #'class references' }
Installer >> classMczInstaller [

	^Smalltalk at: #MczInstaller ifAbsent: [ nil ]
	
]

{ #category : #'class references' }
Installer >> classMultiByteBinaryOrTextStream [

	^Smalltalk at: #MultiByteBinaryOrTextStream  ifAbsent: [ self error: 'MultiByteBinaryOrTextStream not present' ]
]

{ #category : #'class references' }
Installer >> classSARInstaller [

	^Smalltalk at: #SARInstaller  ifAbsent: [ self error: 'SARInstaller not present' ]
]

{ #category : #'package-definitions' }
Installer >> connectors [
	"Connect Morphs together.  Make diagrams."
	^ { self broomMorphsBase.
	#ss -> 'Connectors'.
	'CGPrereqs'. 
	'FSM'. 
	'Connectors'. 
	'ConnectorsText'. 
	'ConnectorsShapes'. 
	'ConnectorsTools'. 
	'ConnectorsGraphLayout'. 
	'BroomMorphs-Connectors' }
]

{ #category : #configure }
Installer >> copyLocalVersionsToRemoteFor: structureOrSymbol [
	"Ensure the currently loaded MCVersion is present in each repository which holds the packages represented by structureOrSymbol.  Use as a single 'commit' of all changes across multiple packages (which reside in their own repositories).
	Make sure id's and passwords are already set up on your repositories.  Recommend using the mcSettings file for doing this, see MCHttpRepository>>#userAndPasswordFromSettingsDo: for details."
	(self remoteRepositoriesFor: structureOrSymbol) do:
		[ : each | each copyImageVersions ]
]

{ #category : #'package-definitions' }
Installer >> core [
	"A minimum core capable of expanding itself."
	^ { #squeak -> MCMcmUpdater defaultUpdateURL asUrl path last.
	'Kernel'.
	'Collections'.
	'Exceptions'.
	'Files'.
	'Network'.
	'Monticello'.
	'MonticelloConfigurations'.
	'Installer-Core' }
]

{ #category : #'package-definitions' }
Installer >> curvedSpaceExplorer [
	"Explore curved 3D spaces."
	^ { self openGL.
	#krestianstvo -> 'ccse'.
	'CCSpaceExplorer' }
]

{ #category : #private }
Installer >> depthFirstOf: structure do: oneArgBlock [ 
	self
		depthFirstOf: structure
		do: oneArgBlock
		ifNotIn: Set new
]

{ #category : #private }
Installer >> depthFirstOf: structure do: oneArgBlock ifNotIn: aSet [ 
	(aSet includes: structure) ifTrue: [ ^ self ].
	"Respect all repository directives even if encountered more than once."
	(structure isVariableBinding) ifFalse: [ aSet add: structure ].
	structure isArray
		ifTrue:
			[ structure do:
				[ : each | self
					depthFirstOf: each
					do: oneArgBlock
					ifNotIn: aSet ] ]
		ifFalse: [ oneArgBlock value: structure ]
]

{ #category : #utils }
Installer >> ditchOldChangeSetFor: aFileName [ 

	| changeSetName changeSet |
 	changeSetName := (self validChangeSetName: aFileName) sansPeriodSuffix.
	changeSet := self changeSetNamed: changeSetName.
	
	changeSet ifNotNil: [
		
		(self logCR:'Removing old change set ', changeSetName) cr.
		self  removeChangeSet: changeSet 
	].
]

{ #category : #'package-definitions' }
Installer >> ffi [
	"Foreign Function Interface."
	^ { #squeak -> 'FFI'.
	'FFI-Pools'.
	'FFI-Kernel' }
]

{ #category : #'package-definitions' }
Installer >> ffiTests [
	"Tests for Foreign Function Interface."
	^ { self ffi.
	#squeak -> 'FFI'.
	'FFI-Tests' }
]

{ #category : #'public interface' }
Installer >> fileInSource [

	useFileIn := true.
	self install.
]

{ #category : #'package-definitions' }
Installer >> graphQlEngine [
	^ { #ss -> 'graphql'.
	'GraphQL-Core'.
	'GraphQL-Engine' }
]

{ #category : #'package-definitions' }
Installer >> graphQlTestsEngine [
	^ { self graphQlEngine.
	'GraphQL-Tests-Core'.
	'GraphQL-Tests-Engine' }
]

{ #category : #'package-definitions' }
Installer >> htmlValidator [
	"Validates HTML and CSS pages against W3C DTD."
	^ { #ss3 -> 'htmlcssparser'.
	'HTML' }
]

{ #category : #'public interface' }
Installer >> initialize [

	useFileIn := false..
]

{ #category : #'public interface' }
Installer >> install [
	
	noiseLevel = #quiet ifTrue: [ ^ self installQuietly ].
	noiseLevel = #silent ifTrue: [ ^ self installSilently ].
	
	^ self installLogging
]

{ #category : #'public interface' }
Installer >> install: packageNameCollectionOrDetectBlock [
	"The parameter specifies the package to be installed in one of the following ways:
		- By Name e.g. install: 'Kernel'
		- Acceptable Versions e.g. install: #('Comet-lr' 'Comet-pmm') i.e. either of these
		- Specific version e.g. install: 'Scriptaculous-lr.148'
		- By Predicate e.g. install: [ :packageName | packageName beginsWith: 'Dynamic' ]"

	self addPackage: packageNameCollectionOrDetectBlock.
	self install
]

{ #category : #mantis }
Installer >> install: aFileName from: stream [
	self log: ' installing...'.

	self withAnswersDo: [
		| ext installSelector mcThing |
		mcThing := self classMCReader ifNotNil: [ self mcThing: aFileName from: stream ].
		mcThing 
			ifNotNil: [ (mcThing respondsTo: #install) 
						ifTrue: [ mcThing install ]
				        	ifFalse: [ (mcThing respondsTo: #load) ifTrue: [ mcThing load ] ]
			]
			ifNil: [ 
				ext := (aFileName copyAfterLast: $/) in: [ :path | path isEmpty ifTrue: [ aFileName ] ifFalse: [ path ] ].
				ext :=  ext copyAfterLast: $..
				ext = '' ifTrue: [ ext := 'st' ].
				installSelector := ('install', ext asUppercase, ':from:') asSymbol.
	
				useFileIn ifTrue: [ 
				[
					SystemChangeNotifier uniqueInstance doSilently: [self install: aFileName from: stream using: installSelector ]] 
						on: Warning do: [ :ex | ex resume: true ].
				] ifFalse: [
					self install: aFileName from: stream using: installSelector. 
				]
			]
	]. 

	self log: ' done.'

]

{ #category : #mantis }
Installer >> install: aFileName from: stream using: installSelector [

		(self respondsTo: installSelector)
			ifTrue: [ self perform: installSelector with: aFileName with: stream ]
			ifFalse: [ self installDefault: aFileName from: stream ].

]

{ #category : #mantis }
Installer >> installCS: aFileName from: stream [

 	self ditchOldChangeSetFor: aFileName.
	self newChangeSetFromStream: stream named: (self validChangeSetName: aFileName).

]

{ #category : #mantis }
Installer >> installDefault: aFileName from: stream [
	"Check for UTF-8 input before filing it in"
	| pos |
	pos := stream position.
	(stream next: 3) asByteArray = #[16rEF 16rBB 16rBF]	"BOM"
		ifTrue: [(RWBinaryOrTextStream on: stream upToEnd utf8ToSqueak) fileIn]
		ifFalse: [stream position: pos; fileIn]

]

{ #category : #mantis }
Installer >> installGZ: aFileName from: stream [ 
	"FileIn the contents of a gzipped stream"
	| zipped unzipped |
	zipped := self classGZipReadStream on: stream.
	unzipped := MultiByteBinaryOrTextStream with: zipped contents asString.
	unzipped reset.
	self 
		newChangeSetFromStream: unzipped 
		named: (FileDirectory localNameFor: aFileName)
]

{ #category : #'public interface' }
Installer >> installLogging [

	self logErrorDuring: [
		self basicInstall.
		packages := nil].

]

{ #category : #mantis }
Installer >> installMCZ: aFileName from: stream [ 

	| source pkg wc |
	
	pkg := aFileName copyUpToLast: $-.
	
	wc := Smalltalk at: #MCWorkingCopy ifAbsent: [ nil ].
wc ifNotNil: [ 
	(wc allManagers select:  [:each | each packageName = pkg ]) do: [ :ea | ea unregister ] 
].
	
	self classMczInstaller ifNotNil: [^ self classMczInstaller install: aFileName stream: stream].  

	source :=  ((ZipArchive new readFrom:stream) memberNamed: 'snapshot/source.st') contents.

	[
		SystemChangeNotifier uniqueInstance doSilently: [ 
			source  readStream fileInAnnouncing: 'Booting ' , aFileName.
 		]
	] on: Warning do: [ :ex | ex resume: true ].
]

{ #category : #mantis }
Installer >> installMCZBasic: aFileName from: stream [ 

	| source |
	
 
	self classMczInstaller ifNotNil: [^ self classMczInstaller install: aFileName stream: stream].  

	source :=  ((ZipArchive new readFrom:stream) memberNamed: 'snapshot/source.st') contents.

	[
		SystemChangeNotifier uniqueInstance doSilently: [ 
			source  readStream fileInAnnouncing: 'Booting ' , aFileName.
 		]
	] on: Warning do: [ :ex | ex resume: true ].
]

{ #category : #mantis }
Installer >> installMCcs: aFileName from: stream [ 

	| reader |
	
	reader := Smalltalk at: #MCCsReader ifPresent: [:class | class on: stream].
]

{ #category : #'public interface' }
Installer >> installQuietly [ 

  	[ self installLogging ] on: Warning do: [ :ex | ex resume: true ].
]

{ #category : #'public interface' }
Installer >> installQuietly: packageNameCollectionOrDetectBlock [

	self quietly install: packageNameCollectionOrDetectBlock.
 
]

{ #category : #mantis }
Installer >> installSAR: aFileName from: stream [ 

	| newCS |
	newCS := self classSARInstaller withCurrentChangeSetNamed: aFileName
		do: [:cs | self classSARInstaller new fileInFrom: stream].
	newCS isEmpty ifTrue: [ self removeChangeSet: newCS ]
]

{ #category : #'public interface' }
Installer >> installSilently [

	SystemChangeNotifier uniqueInstance doSilently: [ self installLogging ]

	
]

{ #category : #accessing }
Installer >> isSkipLoadingTestsSet [

	^SkipLoadingTests ifNil: [ false ]
]

{ #category : #'package-definitions' }
Installer >> jsonParser [
	^ { #ss -> 'JSON'.
	'JSON' }
]

{ #category : #logging }
Installer >> log: text [

	^Transcript show: text.
]

{ #category : #logging }
Installer >> logCR: text [

	self validate.
	^ Transcript show: text; cr
]

{ #category : #logging }
Installer >> logErrorDuring: block [

	(IsSetToTrapErrors = true) ifFalse: [ ^ block value ].

	block on: Error 
		do: [ :e |
			self halt. 
			self logCR: '****', e class name, ': ', (e messageText ifNil: [ '']). 
		
			(e isKindOf: MessageNotUnderstood) 
				ifTrue: [ e pass ]
				ifFalse: [ e isResumable ifTrue:[ e resume: true ]]]
]

{ #category : #'package-definitions' }
Installer >> maInstaller [
	"Select from a family of related packages for application development."
	^ { #ss -> 'MaInstaller'.
	'Ma-Installer-Core' }
]

{ #category : #searching }
Installer >> match: aMatch [

	^self packagesMatching: aMatch
]

{ #category : #'package-definitions' }
Installer >> mathMorphs [
	"MathMorphs is a project that combines mathematics and Smalltalk.  See http://www.dm.uba.ar/MathMorphs/ and chapter 10 of the 'new blue book'."
	^ { self morphicWrappers.
	#ss -> 'MathMorphsRevival'.
	'Functions' }
]

{ #category : #mantis }
Installer >> mcThing: aFileName from: stream [
		
	"dont use monticello for .cs or for .st use monticello for .mcs"

	| reader |
	
	useFileIn ifTrue: [ ^ nil ].
	
	reader := self classMCReader readerClassForFileNamed: aFileName.
	reader name = 'MCStReader' ifTrue: [ ^ nil ].
	reader ifNil: [ ^ nil ].
	(reader respondsTo: #on:fileName:) 
		ifTrue: [ reader := reader on: stream fileName: aFileName.
					^ reader version  ]
		ifFalse: [ reader := reader on: stream. 
				    ^ reader snapshot  ].
]

{ #category : #'public interface' }
Installer >> merge: structureOrSymbol [ 
	| toUncache |
	toUncache := Set new.
	self
		packageDependenciesFor: structureOrSymbol
		do:
			[ : eachPackageName : eachRepositorySpec | | repo version |
			(repo := self class repositoryFor: eachRepositorySpec) cacheAllFilenames.
			toUncache add: repo.
			version := self
				primMerge: eachPackageName
				from: repo.
			"Lazy code, polite MC won't add duplicates if they already exist."
			version ifNotNil:
				[ version workingCopy repositoryGroup
					 addRepository: repo ;
					 addRepository: (self class defaultRepositoryFor: eachRepositorySpec) ] ].
	toUncache do: [ : each | each flushAllFilenames ]
]

{ #category : #accessing }
Installer >> messagesToSuppress [

	^ messagesToSuppress ifNil: [ messagesToSuppress := OrderedCollection new ]
]

{ #category : #accessing }
Installer >> messagesToSuppress: anObject [

	messagesToSuppress := anObject
]

{ #category : #'package-definitions' }
Installer >> morphicWrappers [
	"Provides 'type on air' workspaces.  Results of evaluated expressions are represented as domain objects in the world."
	^ { #ss -> 'MathMorphsRevival'.
	'MorphicWrappers' }
]

{ #category : #mantis }
Installer >> newChangeSetFromStream: aStream named: aName [ 

	"This code is based upon ChangeSet-c-#newChangesFromStream:named: which is in 3.9,
	implemented here for previous versions. The second branch is for 3.8, where ChangeSets
	are loaded by ChangeSorter. "

	| oldChanges newName newSet |

	(self classChangeSet respondsTo: #newChangesFromStream:named:) 
		ifTrue: [ ^self classChangeSet newChangesFromStream: aStream named:aName ].

	(self classChangeSorter respondsTo: #newChangesFromStream:named:)
		ifTrue: [ ^self classChangeSorter newChangesFromStream: aStream named: aName ].

	oldChanges := ChangeSet current.
 
	"so a Bumper update can find it"
	newName := aName sansPeriodSuffix.

	newSet := self classChangeSet basicNewNamed: newName.

	[ | newStream |
	newSet
		ifNotNil: [(aStream respondsTo: #converter:)
				ifTrue: [newStream := aStream]
				ifFalse: [newStream := self classMultiByteBinaryOrTextStream with: aStream contentsOfEntireFile.
					newStream reset].
			self classChangeSet newChanges: newSet.
			newStream setConverterForCode.
			newStream fileInAnnouncing: 'Loading ' , newName , '...'.
			Transcript cr; show: 'File ' , aName , ' successfully filed in to change set ' , newName].
	aStream close]
		ensure: [self classChangeSet newChanges: oldChanges].
	 
	^ newSet
]

{ #category : #'package-definitions' }
Installer >> oCompletion [
	"Adds code-completion to the IDE."
	^ { #ss -> 'OCompletion'.
	'OcompletionSqueakCompatibility'.
	'Ocompletion' }
]

{ #category : #'public interface' }
Installer >> open [
]

{ #category : #'package-definitions' }
Installer >> openGL [
	"3D library."
	^ { self threeDtransform.
	#krestianstvo -> 'ccse'.
	'OpenGL-Pools'.
	'OpenGL-Core'.
	'OpenGL-NameManager' }
]

{ #category : #'package-definitions' }
Installer >> osProcess [
	"Launch external executable programs."
	^ { #ss -> 'OSProcess'.
	'OSProcess' }
]

{ #category : #accessing }
Installer >> package [

	^ self packages isEmpty ifTrue: [ nil ] ifFalse: [ self packages last ]
]

{ #category : #accessing }
Installer >> package: anObject [

	self addPackage: anObject.
]

{ #category : #squeakmap }
Installer >> packageAndVersionFrom: pkg [
	| p |
	p := ReadStream on: pkg .
	^{(p upTo: $(). p upTo: $)} collect: [:s | s withBlanksTrimmed].
]

{ #category : #private }
Installer >> packageDependenciesFor: structureOrSymbol do: twoArgBlock [ 
	"Value twoArgBlock with each package name and the currently-specified repository where that package resides."
	| currentRepository |
	structureOrSymbol isSymbol
		ifTrue:
			[ self
				packageDependenciesFor: (self perform: structureOrSymbol)
				do: twoArgBlock ]
		ifFalse:
			[ self
				depthFirstOf: structureOrSymbol
				do:
					[ : each | each isVariableBinding
						ifTrue: [ currentRepository := each ]
						ifFalse:
							[ each isString
								ifTrue:
									[ twoArgBlock
										value: each
										value: currentRepository ]
								ifFalse: [ self error: 'invalid specification' ] ] ] ]
]

{ #category : #accessing }
Installer >> packages [
	
 	^ packages ifNil: [ packages := OrderedCollection new ]
]

{ #category : #accessing }
Installer >> packages: aCollection [ 

	packages := aCollection
]

{ #category : #configure }
Installer >> packagesFor: structureOrSymbol [ 
	^ Array streamContents:
		[ : stream | self
			packageDependenciesFor: structureOrSymbol
			do:
				[ : eachPackageName : eachRepositorySpec | stream nextPut: eachPackageName ] ]
]

{ #category : #searching }
Installer >> packagesMatching: aMatch [
	^'search type not supported'
]

{ #category : #private }
Installer >> primMerge: packageName from: aMCRepository [
	| version |
	version := (aMCRepository includesVersionNamed: packageName)
		ifTrue: [ aMCRepository versionNamed: packageName ]
		ifFalse: [ aMCRepository highestNumberedVersionForPackageNamed: packageName ].
	[ version shouldMerge
		ifTrue: [ version merge ]
		ifFalse: [ version load ] ]
		on: MCNoChangesException
		do: [ : req | req resume ]
		on: MCMergeResolutionRequest
		do:
			[ : request | request merger conflicts isEmpty
				ifTrue: [ request resume: true ]
				ifFalse: [ request pass ] ].
	^ version
]

{ #category : #'public interface' }
Installer >> quietly [

	noiseLevel := #quiet
]

{ #category : #configure }
Installer >> remoteRepositoriesFor: structureOrSymbol [
	| reps |
	reps := Set new.
	self class suspendRepositoryOverridesWhile:
		[ self
			packageDependenciesFor: structureOrSymbol
			do:
				[ : eachPackageName : eachRepositorySpec | | rep |
				rep := self class repositoryFor: eachRepositorySpec.
				"Collect up the repositories in the default MCRepositoryGroup, because those ones will have user and password specified."
				reps add:
					(MCRepositoryGroup default repositories
						detect: [ : each | each = rep ]
						ifNone: [ rep ]) ] ].
	^ reps
]

{ #category : #utils }
Installer >> removeChangeSet: cs [

	(self classChangeSet respondsTo: #removeChangeSet:)
		ifTrue: [ ^ChangeSet removeChangeSet: cs ].
		
	^ self classChangeSorter removeChangeSet: cs .
]

{ #category : #'action report' }
Installer >> reportFor: theLine page: thePage on: report [ 
 	
	[ thePage atEnd ] whileFalse: [ 
		| line |
		line := thePage nextLine.
		Installer actionMatch: line reportOn: report ifNoMatch: [ report nextPutAll: line; cr. ]].
]

{ #category : #'action report' }
Installer >> reportSection: line on: report [
	
	report isEmpty ifFalse: [ report cr ].
	report nextPutAll: '">>>> ' ; nextPutAll: (line copyWithout: $"); nextPut: $"; cr.

	
]

{ #category : #searching }
Installer >> search: aMatch [
	^'search type not supported'
]

{ #category : #'public interface' }
Installer >> silently [

	noiseLevel := #silent
]

{ #category : #'package-definitions' }
Installer >> squeakRelease [
	^ { self system.
	'311Deprecated'.
	'39Deprecated'.
	'45Deprecated'.
	'Nebraska'.
	'SmallLand-ColorTheme'.
	'ST80'.
	'ST80Tools'.
	'SystemReporter'.
	'Universes'.
	'XML-Parser' }
]

{ #category : #'package-definitions' }
Installer >> squeaksource [
	"A source code repository."
	^ { #squeak -> 'ss'.
	'OSProcess'.
	'RFB'.
	'SmaCC'.
	'DynamicBindings'.
	'KomServices'.
	'KomHttpServer'.
	'Seaside2'.
	'Mewa'.
	'TinyWiki'.
	'SqueakSource' }
]

{ #category : #'auto answering' }
Installer >> suppress: aMessage [

	messagesToSuppress add: aMessage
]

{ #category : #'package-definitions' }
Installer >> system [
	"Packages forming the Smalltalk development system."
	^ { self core.
	'System' }
]

{ #category : #'package-definitions' }
Installer >> threeDtransform [
	^ { self ffiTests.
	#ss -> 'CroquetGL'.
	'3DTransform' }
]

{ #category : #'package-definitions' }
Installer >> tools [
	"A minimum core capable of expanding itself."
	^ { self core.
	'ToolBuilder-Kernel'.
	'Tools' }
]

{ #category : #'package-definitions' }
Installer >> updateStream [
	^ { self tools.
	'UpdateStream' }
]

{ #category : #url }
Installer >> validChangeSetName: aFileName [
	" dots in the url confuses the changeset loader. I replace them with dashes"
	
 	(aFileName beginsWith:'http:') ifTrue: [ | asUrl |
		asUrl := Url absoluteFromText: aFileName.
		^String streamContents: [:stream |
			stream nextPutAll: (asUrl authority copyReplaceAll: '.' with: '-').
			asUrl path allButLastDo: [:each |
				stream
					nextPutAll: '/';
					nextPutAll: (each copyReplaceAll: '.' with: '-') ].
			stream
				nextPutAll: '/';
				nextPutAll: asUrl path last ] ].
	^aFileName
]

{ #category : #logging }
Installer >> validate [

	ValidationBlock value = false ifTrue: [ self error: 'Validation failed' ].
]

{ #category : #'public interface' }
Installer >> versions [
	
	^ self basicVersions
]

{ #category : #'public interface' }
Installer >> view [
	self logErrorDuring: [self basicView]
]

{ #category : #'public interface' }
Installer >> view: packageNameCollectionOrDetectBlock [

	self package: packageNameCollectionOrDetectBlock.
	self view
]

{ #category : #mantis }
Installer >> view: aFileName from: stream [
	
	self log: ' viewing...'.
 	
	Workspace new contents: (stream contents); openLabel: aFileName.
 
	 

				 
]

{ #category : #'package-definitions' }
Installer >> webClientSsp [
	"WebClient supports NTLM/SPNEGO authentication via the Microsoft SSP interface (Windows only)."
	^ { self ffiTests. 
	#ss -> 'WebClient'.
	'WebClient-SSP' }
]

{ #category : #'auto answering' }
Installer >> withAnswersDo: aBlock [

	(aBlock respondsTo: #valueSuppressingMessages:supplyingAnswers: )
		ifTrue: [aBlock valueSuppressingMessages: self messagesToSuppress supplyingAnswers: self answers.]
		ifFalse: [ aBlock value ]

]
