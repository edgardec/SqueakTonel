"
An MCConfiguration specifies the configuration of a set of related Monticello packages. It maintains an ordered list of package versions and a list of repositories in which the packages may be found.

An MCConfiguration may be filed out for storage as an array specification, and new instances can be created from a stored array specification.

"
Class {
	#name : #MCConfiguration,
	#superclass : #Object,
	#instVars : [
		'name',
		'dependencies',
		'repositories',
		'log'
	],
	#classVars : [
		'DefaultLog',
		'EnsureOpenTranscript',
		'ExtraProgressInfo',
		'LogToFile',
		'UpgradeIsMerge'
	],
	#category : #MonticelloConfigurations
}

{ #category : #private }
MCConfiguration class >> concreteClassFor: configArray [
	^ (configArray includes: #mcmVersion)
		ifTrue: [MCConfigurationExtended]
		ifFalse: [MCConfiguration].


]

{ #category : #private }
MCConfiguration class >> copyWithoutKeyPrefix: configArray [
	"Tokens in the version history portion of configArray are prefixed with $X to
	prevent them being parsed in the original implementation of MCConfiguration.
	Here we remove the prefixes prior to processing in the current implementation
	with MCConfigurationExtended support. See #contentsOn:keyPrefix: for the
	prefix writer."
	| strm |
	strm := #() writeStream.
	configArray do: [ :token |
		token caseOf: {
				[#Xname ] -> [ strm nextPut: #name] .
				[#Xrepository ] -> [ strm nextPut: #repository] .
				[#Xdependency ] -> [ strm nextPut: #dependency] .
				[#XmcmVersion] -> [ strm nextPut: #mcmVersion] .
				[#Xid] -> [ strm nextPut: #id] .
				[#XauthorInitials ] -> [ strm nextPut: #authorInitials] .
				[#XtimeStamp ] -> [ strm nextPut: #timeStamp] .
				[#Xcomment ] -> [ strm nextPut: #comment]
			}
			otherwise: [ strm nextPut: token]


	].
	^ strm contents.


]

{ #category : #accessing }
MCConfiguration class >> defaultLog [
	"Answer the default configuration log"
	^DefaultLog
]

{ #category : #accessing }
MCConfiguration class >> defaultLog: aStream [
	"Set the default configuration log"
	DefaultLog := aStream.
]

{ #category : #converting }
MCConfiguration class >> dependencyFromArray: anArray [
	^MCVersionDependency
		package: (MCPackage named: anArray first)
		info: (
			MCVersionInfo
			name: anArray second
			id: (UUID fromString: anArray third)
			message: nil
			date: nil
			time: nil
			author: nil
			ancestors: nil)
]

{ #category : #converting }
MCConfiguration class >> dependencyToArray: aDependency [
	^ {
		aDependency package name . 
		aDependency versionInfo name . 
		aDependency versionInfo id asString }
]

{ #category : #preferences }
MCConfiguration class >> ensureOpenTranscript [

	<preference: 'Ensure Open Transcript' 
		category: 'Monticello' 
		description: 'When logging, a transcript will be opened automatically if no one is visible. This setting has no effect when logging to a file.' 
		type: #Boolean>
		
	^EnsureOpenTranscript ifNil:[true]
]

{ #category : #preferences }
MCConfiguration class >> ensureOpenTranscript: aBoolean [

	EnsureOpenTranscript := aBoolean.
]

{ #category : #preferences }
MCConfiguration class >> extraProgressInfo [
	"Answer true for additional progress info during load. 
	With the newly added MC down/upload operations this seems unnecessary
	but some people might disagree, so let's leave it as a preference right now"
	<preference: 'Extra Progress Info' 
		category: 'Monticello' 
		description: 'If true, additional progress information is displayed when loading MC configurations (i.e., during updates)' 
		type: #Boolean>
	^ExtraProgressInfo ifNil:[false]
]

{ #category : #preferences }
MCConfiguration class >> extraProgressInfo: aBool [
	"Whether to display for additional progress info during load."
	ExtraProgressInfo := aBool.

]

{ #category : #'instance creation' }
MCConfiguration class >> fromArray: anArray [
	| array |
	array := self copyWithoutKeyPrefix: anArray.
	^ (self versionsFromStream: array readStream) first.

]

{ #category : #preferences }
MCConfiguration class >> logToFile [
	"Whether to log configuration info to files by default.
	If true, logs to a file named after the configuration (config.nn.log).
	If false, logs to the transcript."
	<preference: 'Log config info to disk' 
		category: 'Monticello' 
		description: 'If true, configuration information (such as change logs) are logged to disk instead of the Transcript. The log file is named after the configuration map (config.nn.log)' 
		type: #Boolean>
	^LogToFile ifNil:[true].
]

{ #category : #preferences }
MCConfiguration class >> logToFile: aBool [
	"Whether to log configuration info to files by default.
		MCConfiguration logToFile: true.
		MCConfiguration logToFile: false.
	"
	LogToFile := aBool
]

{ #category : #private }
MCConfiguration class >> nextArrayFrom: configStream [
	"Each config array starts with #name. The appearance of another token of
	that value indicates the beginning of a new configuration map for a prior
	version of the configuration."
	| oc |
	oc := OrderedCollection new.
	oc add: configStream next.
	[configStream atEnd not and: [#name ~= configStream peek]]
		whileTrue: [oc add: configStream next].
	^ oc

]

{ #category : #private }
MCConfiguration class >> nextFrom: configStream [

	| configArray configuration |
	configArray := self nextArrayFrom: configStream.
	configuration := (self concreteClassFor: configArray) new.
	configArray pairsDo: [:key :value |
		configuration initializeFromKey: key value: value].
	^ configuration.

]

{ #category : #private }
MCConfiguration class >> oldVersionOfFromArray: anArray [
	"For verifying backward compatability. This is the implementation
	of #fromArray: prior to introduction of MCConfigurationExtended."
	| configuration |
	configuration := self new.
	anArray pairsDo: [:key :value |
		key = #repository
			ifTrue: [configuration repositories add: (self repositoryFromArray: value)].
		key = #dependency
			ifTrue: [configuration dependencies add: (self dependencyFromArray: value)].
		key = #name
			ifTrue: [configuration name: value].
	].
	^configuration
]

{ #category : #converting }
MCConfiguration class >> repositoryFromArray: anArray [
	^ MCRepositoryGroup default repositories
		detect: [:repo | repo description = anArray first]
		ifNone: [
			MCHttpRepository
				location: anArray first
				user: ''
				password: '']
]

{ #category : #converting }
MCConfiguration class >> repositoryToArray: aRepository [
	^ {aRepository description}
]

{ #category : #preferences }
MCConfiguration class >> upgradeIsMerge [
	"Answer true if you wish to merge upstream changes whenever you upgrade."
	<preference: 'Upgrade is merge'
		category: 'updates'
		description: 'When upgrading packages, use merge instead of load'
		type: #Boolean>
	^UpgradeIsMerge ifNil: [true]
]

{ #category : #preferences }
MCConfiguration class >> upgradeIsMerge: aBoolean [
	UpgradeIsMerge := aBoolean.
]

{ #category : #private }
MCConfiguration class >> versionsFromStream: arrayStream [
	"Answer all versions with history list populated in each version."
	| configuration history |
	arrayStream atEnd ifTrue: [ ^ #() ].
	configuration := self nextFrom: arrayStream.
	history := self versionsFromStream: arrayStream.
	history do: [ :ver | configuration addPriorVersion: ver ].
	^ { configuration }, history.

]

{ #category : #comparing }
MCConfiguration >> = configuration [
	^ ((configuration class = self class
		and: [configuration name = name])
			and: [configuration dependencies = dependencies])
				and: [configuration repositories = repositories]
]

{ #category : #initialize }
MCConfiguration >> addPriorVersion: mcConfig [
	"Do nothing, the original MCConfiguration format does not maintain history"
]

{ #category : #actions }
MCConfiguration >> browse [
	| browser |
	browser := MCConfigurationBrowser new configuration: self copyForEdit.
	name ifNotNil: [:nm | browser label: browser defaultLabel , ' ' , nm].
	browser show
]

{ #category : #private }
MCConfiguration >> cacheAllFileNamesDuring: aBlock [
	^ (repositories
		inject: aBlock
		into: [ :innerBlock :repository |
			[ repository cacheAllFileNamesDuring: innerBlock ]
		]) value
	

]

{ #category : #faking }
MCConfiguration >> changes [
	^MCPatch operations: #()
]

{ #category : #printing }
MCConfiguration >> contentsOn: aStream [
	self contentsOn: aStream keyPrefix: ''.

]

{ #category : #printing }
MCConfiguration >> contentsOn: aStream keyPrefix: prefix [
	"Prepend prefix to key values. If the prefix is a non-empty string, the resulting
	key values will be ignored when parsing an original format MCConfiguration
	from an extended format MCM file. This provides backward compatibility for
	older images that need to read newer format MCM files."

	name ifNotNil: [:n |
		aStream cr.
		aStream nextPutAll: prefix,'name '. 
		aStream print: n].

	repositories do: [:ea | 
		aStream cr.
		aStream nextPutAll: prefix,'repository '.
		(MCConfiguration repositoryToArray: ea) printElementsOn: aStream].

	dependencies do: [:ea | 
		aStream cr.
		aStream nextPutAll: prefix,'dependency '.
		(MCConfiguration dependencyToArray: ea) printElementsOn: aStream].

]

{ #category : #copying }
MCConfiguration >> copyForEdit [
	"Preparing to edit a configuration. Answer a new copy with the original
	instance saved in version history, and with no author initials or timestamp.
	The initials and timestamp are to be set immediately prior to saving an edited
	version."
	| config |
	config := MCConfigurationExtended new.
	config name: name copy.
	config dependencies: dependencies copy.
	config repositories: repositories copy.
	config priorVersions addFirst: self.
	^ config
]

{ #category : #copying }
MCConfiguration >> copyWithoutHistory [
	^ self copy

]

{ #category : #accessing }
MCConfiguration >> dependencies [
	^dependencies ifNil: [dependencies := OrderedCollection new]
]

{ #category : #accessing }
MCConfiguration >> dependencies: aCollection [
	dependencies := aCollection
]

{ #category : #private }
MCConfiguration >> depsSatisfying: selectBlock versionDo: verBlock displayingProgress: progressString [ 
	| count selectedVersions cleanWorkingCopies |
	self cacheAllFileNamesDuring: [
		self repositories do: [ :eachRepository |
			MCRepositoryGroup default addRepository: eachRepository ].
		"First, download selected versions"
		count := 0.
		selectedVersions := OrderedCollection new.
		self withProgress: progressString in: self dependencies do: [ :dep | | verName repo |
			verName := dep versionInfo name.
			self class extraProgressInfo ifTrue:
				[ ProgressNotification signal: '' extra: 'Downloading ' , verName ].
			repo := self repositories
				detect: [ :eachRepository | eachRepository includesVersionNamed: verName ]
				ifNone: 	[ self logError: 'Version ' , verName , ' not found in any repository'.
					self logError: 'Aborting'.
					^ count ].
			(selectBlock value: dep) ifTrue: [ | version |
				version := self versionNamed: verName for: dep from: repo.
				version ifNil: [ self logError: 'Could not download version ' , verName , ' from ' , repo description.
					self logError: 'Aborting'.
					^ count ].
				dep package workingCopy newRepositoryGroupIfDefault. "fix old working copies"
				dep package workingCopy repositoryGroup addRepository: repo.
				selectedVersions add: version]].
		"Then, process only those definitions that moved from one package to another, to avoid order dependence"
		cleanWorkingCopies := MCWorkingCopy allManagers select:
			[ :wc | wc modified not and:
				[ selectedVersions anySatisfy: [ :v | wc package = v package ] ] ].
		MCReorganizationPreloader preloadMovesBetween: selectedVersions.
		"Finally, load/merge selected versions"
		self withProgress: progressString in: selectedVersions do: [ :version |
			self logUpdate: version package with: version.
			self class extraProgressInfo ifTrue:
				[ ProgressNotification signal: '' extra: 'Installing ' , version info name ].
			verBlock value: version.
			count := count + 1 ].
		"Clean up packages made dirty by MCReorganizationPreloader"
		cleanWorkingCopies
			select: [ :wc | wc modified ]
			thenDo: [ :wc | wc checkModified ].
	].
	^ count
]

{ #category : #private }
MCConfiguration >> diffBaseFor: aDependency [
	| wc |
	aDependency package hasWorkingCopy ifFalse: [^nil].
	wc := aDependency package workingCopy.
	wc ancestors ifEmpty: [^nil].
	^wc ancestors first versionName
]

{ #category : #accessing }
MCConfiguration >> fileName [
	^ self name, '.', self writerClass extension

]

{ #category : #printing }
MCConfiguration >> fileOutOn: aStream [
	self fileOutOn: aStream keyPrefix: ''

]

{ #category : #printing }
MCConfiguration >> fileOutOn: aStream keyPrefix: prefix [

	aStream nextPut: $(.
	self contentsOn: aStream keyPrefix: prefix.
	aStream cr.
	aStream nextPut: $).

]

{ #category : #comparing }
MCConfiguration >> hash [
	^ (name hash bitXor: (dependencies hash)) bitXor: repositories hash

]

{ #category : #faking }
MCConfiguration >> info [
	^MCVersionInfo new
]

{ #category : #initialize }
MCConfiguration >> initialize [
	super initialize.
	log := DefaultLog.
]

{ #category : #initialize }
MCConfiguration >> initializeFromKey: key value: value [
	key = #repository
		ifTrue: [self repositories add: (MCConfiguration repositoryFromArray: value)].
	key = #dependency
		ifTrue: [self dependencies add: (MCConfiguration dependencyFromArray: value)].
	key = #name
		ifTrue: [self name: value].

]

{ #category : #testing }
MCConfiguration >> isCacheable [
	^false
]

{ #category : #actions }
MCConfiguration >> load [
	^self depsSatisfying: [:dep | dep isCurrent not]
		versionDo: [:ver | ver load]
		displayingProgress: 'loading packages'

]

{ #category : #accessing }
MCConfiguration >> log [
	"Answer the receiver's log. If no log exist use the default log"
	
	^log ifNil: [
		(name notNil and: [ self class logToFile ]) ifFalse: [
			self class ensureOpenTranscript ifTrue: [Transcript openIfNone].
			^Transcript ].
		self log: ((FileStream fileNamed: self logFileName) setToEnd; yourself).
		log ]
]

{ #category : #accessing }
MCConfiguration >> log: aStream [
	log := aStream.
]

{ #category : #private }
MCConfiguration >> logError: aString [
	self log
		cr; nextPutAll: 'ERROR: ';
		nextPutAll: aString; cr;
		flush.

]

{ #category : #accessing }
MCConfiguration >> logFileName [

	^self name, '-', (FileDirectory localNameFor: Smalltalk imageName), '.log'
	
]

{ #category : #private }
MCConfiguration >> logUpdate: aPackage with: aVersion [
	self log
		cr; nextPutAll: '========== ', aVersion info name, ' =========='; cr;
		cr; nextPutAll: aVersion info message asString; cr;
		flush.

	aPackage hasWorkingCopy ifFalse: [^self].

	aPackage workingCopy ancestors do: [:each |
		(aVersion info hasAncestor: each)
			ifTrue: [(aVersion info allAncestorsOnPathTo: each)
				do: [:ver | self log cr; nextPutAll: '>>> ', ver name, ' <<<'; cr;
							nextPutAll: ver message; cr; flush]]]
]

{ #category : #private }
MCConfiguration >> logWarning: aString [
	self log
		cr; nextPutAll: 'WARNING: ';
		nextPutAll: aString; cr;
		flush.

]

{ #category : #actions }
MCConfiguration >> merge [
	^self depsSatisfying: [:dep | dep isFulfilledByAncestors not]
		versionDo: [:ver | ver merge]
		displayingProgress: 'merging packages'

]

{ #category : #private }
MCConfiguration >> mustMerge: aVersion [
	"answer true if we have to do a full merge and false if we can simply load instead"
	
	| pkg wc current |
	(pkg := aVersion package) hasWorkingCopy ifFalse: [^false "no wc -> load"].
	(wc := pkg workingCopy) modified ifTrue: [^true "modified -> merge"].
	wc ancestors isEmpty ifTrue: [^true "no ancestor info -> merge"].
	current := wc ancestors first.
	(aVersion info hasAncestor: current) ifTrue: [^false "direct descendant of wc -> load"].
	"new branch -> merge"
	^true
]

{ #category : #accessing }
MCConfiguration >> name [
	^name
]

{ #category : #accessing }
MCConfiguration >> name: aString [
	name := aString
]

{ #category : #accessing }
MCConfiguration >> repositories [
	^repositories ifNil: [repositories := OrderedCollection new]
]

{ #category : #accessing }
MCConfiguration >> repositories: aCollection [
	repositories := aCollection
]

{ #category : #updating }
MCConfiguration >> setSystemVersion [
	"Set the current system version date to the latest date found in my configuration (or the associated working copy). Also set the highest update number to the sum of version numbers in my configuration."

	| versionNumbers versionDates |
	versionNumbers := self dependencies collect: [:d |
		(d versionInfo name copyAfterLast: $.) asInteger].
	versionDates := self dependencies collect: [:d |
		d versionInfo date
			ifNil: [d package workingCopy ancestors first date]].
	SystemVersion current
		date: versionDates max;
		highestUpdate: versionNumbers sum.
]

{ #category : #printing }
MCConfiguration >> storeOn: aStream [
	aStream nextPut: $(;
		nextPutAll: self class name;
		nextPutAll: ' fromArray: #'.
	self fileOutOn: aStream.
	aStream nextPut: $)
]

{ #category : #private }
MCConfiguration >> suggestedNameOfNextVersion [
	"Suggest a name for the next version of this configuration. The format is assumed to be name-authorInitials.version. Automatically increments the version, takes author initials from Utilities."
	^'{1}-{2}.{3}' format: {
		name
			ifNil: [ 'newConfiguration' ]
			ifNotNil: [ name asMCVersionName packageName ].
		Utilities authorInitials.
		name
			ifNil: [ 1 ]
			ifNotNil: [ name asMCVersionName versionNumber + 1 ] }
]

{ #category : #accessing }
MCConfiguration >> summary [
	^String streamContents: [:stream |
		self dependencies
			do: [:ea | stream nextPutAll: ea versionInfo name; cr ]]
]

{ #category : #updating }
MCConfiguration >> updateFromImage [
	self dependencies: (self dependencies collect: [:dep |
		dep package hasWorkingCopy
			ifTrue: [
				dep package workingCopy in: [:wc |
					MCVersionDependency package: wc package info: wc ancestors first]]
			ifFalse: [dep]]).

]

{ #category : #updating }
MCConfiguration >> updateFromImage: packageIndex [
	| dep newDeps |
	dep := self dependencies at: packageIndex.
	newDeps := self dependencies copy.
	newDeps
		at: packageIndex put: (dep package hasWorkingCopy
			ifTrue: [dep package workingCopy in: [:wc |
					MCVersionDependency package: wc package info: wc ancestors first]]
			ifFalse: [dep]).
	self dependencies: newDeps.

]

{ #category : #updating }
MCConfiguration >> updateFromRepositories [

	self cacheAllFileNamesDuring: [ self updateFromRepositoriesWithoutCaching ]
]

{ #category : #updating }
MCConfiguration >> updateFromRepositories: packageIndex [

	self cacheAllFileNamesDuring: [ self updateFromRepositoriesWithoutCaching: packageIndex ]
]

{ #category : #updating }
MCConfiguration >> updateFromRepositoriesWithoutCaching [

	| oldNames newNames sortedNames newDeps |
	oldNames := self dependencies collect: [:dep | dep versionInfo versionName].
	newNames := Dictionary new.
	self repositories
		do: [:repo | 
			ProgressNotification signal: '' extra: 'Checking ', repo description.
			(repo possiblyNewerVersionsOfAnyOf: oldNames)
				do: [:newName | newNames at: newName put: repo]]
		displayingProgress: 'Searching new versions'.

	sortedNames := newNames keys asArray sort:
		[:a :b | a versionNumber > b versionNumber].

	newDeps := OrderedCollection new: self dependencies size.
	self dependencies
		do: [:dep |
			newDeps add: (sortedNames
				detect: [:each | each packageAndBranchName = dep packageAndBranchName]
				ifFound: [ :newName |
					| repo |
					repo := newNames at: newName.
					(self versionInfoNamed: newName for: dep from: repo)
						ifNil: [ dep ]
						ifNotNil: [ :info |
							MCVersionDependency package: dep package info: info ] ]
				ifNone: [ dep ]) ]
		displayingProgress: 'Downloading new versions ...' translated.

	self dependencies: newDeps.

]

{ #category : #updating }
MCConfiguration >> updateFromRepositoriesWithoutCaching: packageIndex [

	| oldNames newNames sortedNames newDeps dep |
	dep := dependencies at: packageIndex.
	oldNames := {dep versionInfo versionName}.
	newNames := Dictionary new.
	self repositories
		do: [:repo | 
			ProgressNotification signal: '' extra: 'Checking ', repo description.
			(repo possiblyNewerVersionsOfAnyOf: oldNames)
				do: [:newName | newNames at: newName put: repo]]
		displayingProgress: 'Searching new versions'.

	sortedNames := newNames keys asArray sort:
		[:a :b | a versionNumber > b versionNumber].

	newDeps := self dependencies copy.
	newDeps at: packageIndex put: (
		sortedNames
				detect: [:each | each packageAndBranchName = dep packageAndBranchName]
				ifFound: [ :newName |
					| repo |
					repo := newNames at: newName.
					(self versionInfoNamed: newName for: dep from: repo)
						ifNil: [ dep ]
						ifNotNil: [ :info |
							MCVersionDependency package: dep package info: info ] ]
				ifNone: [ dep ]).

	self dependencies: newDeps.

]

{ #category : #actions }
MCConfiguration >> upgrade [
	^self depsSatisfying:
			[:dep | dep isFulfilledByAncestors not]
		versionDo:
			[:ver | 
			(self class upgradeIsMerge and: [ver shouldMerge])
				ifFalse: [ver load]
				ifTrue:
					[[ver merge]
						on: MCNoChangesException
						do: [:req| req resume ]
						on: MCMergeResolutionRequest
						do: [:request |
							request merger conflicts isEmpty
								ifTrue: [request resume: true]
								ifFalse: [request pass]]
						on: Deprecation
						do: [:req| req resume ]]]
		displayingProgress: 'upgrading packages'
]

{ #category : #private }
MCConfiguration >> versionInfoNamed: newName for: dep from: repo [
	"Retrieves the version info instead of the version. Searches in-image first, in case the desired version is part of an already loaded package (usual case when doing a partial update). If not present defaults to versionNamed:for:from: an uses its result."
	MCWorkingCopy registry at: dep package ifPresent:[:workingCopy| | seen |
		"Don't use allAncestorsDo: - apparently this can loop indefinitely.
		Rather keep track of the versions that we've seen and make sure we don't loop."
		seen := Set new.
		workingCopy ancestry ancestorsDoWhileTrue:[:vInfo|
			vInfo name = newName ifTrue:[^vInfo].
			(seen includes: vInfo) ifTrue:[false] ifFalse:[seen add: vInfo. false]
		].
	].
	^(self versionNamed: newName for: dep from: repo) info
]

{ #category : #private }
MCConfiguration >> versionNamed: aMCVersionName for: aDependency from: repo [

	| baseName fileName ver |
	(repo filterFileNames: repo cachedFileNames forVersionNamed: aMCVersionName) ifNotEmptyDo: [:cachedNames |
		fileName := cachedNames anyOne.
		self class extraProgressInfo
			ifTrue:[ProgressNotification signal: '' extra: 'Using cached ', fileName].
		ver := repo versionNamed: fileName].
	ver ifNil: [
		baseName := self diffBaseFor: aDependency.
		(baseName notNil and: [baseName ~= aMCVersionName and: [repo includesVersionNamed: baseName]]) ifTrue: [
			fileName := (MCDiffyVersion nameForVer: aMCVersionName base: baseName), '.mcd'.
			self class extraProgressInfo
				ifTrue:[ProgressNotification signal: '' extra: 'Downloading ', fileName].
			ver := [repo versionNamed: fileName] ifError: []]].
	ver ifNil: [
		fileName := aMCVersionName versionName, '.mcz'.
		self class extraProgressInfo
			ifTrue:[ProgressNotification signal: '' extra: 'Downloading ', fileName].
		ver := repo versionNamed: fileName].
	^ver
]

{ #category : #private }
MCConfiguration >> withProgress: progressString in: aCollection do: aBlock [
	^self class extraProgressInfo
		ifTrue: [ aCollection do: aBlock displayingProgress: progressString ]
		ifFalse: [ aCollection do: aBlock ]


]

{ #category : #accessing }
MCConfiguration >> writerClass [
	^ MCMcmWriter 
]
