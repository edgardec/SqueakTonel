"
MCMcmUpdater provides utility methods for updating Monticello packages from Monticello configurations.

When Monticello configurations are stored in a repository (or repositories), MCMcmUpdater acts as an update stream. It first ensures that each configuration map has been loaded in sequence, then updates the last configuration map to the most recent version for each specified package, and finally loads these versions to produce a fully updated configuration.

Currently if a set of packages are unloaded from the image, using this class to reload them may cause problems, depending on what dependencies those classes have.  Success is not assured.  Removing packages via SmalltalkImage>>unloadAllKnownPackages will be successful, it flags the packages removed so that they are not loaded by this utility.

If you wish to not have MCMcmUpdater update packages, there are two ways to handle this:

1) To have MCMcmUpdater not update any packages not currently in the image set the UpdateMissingPackages preference to false:
		MCMcmUpdater updateMissingPackages: false
	Note that any new packages added to the repositories will not be picked up when this is turned off.
2) To have MCMcmUpdater not update a specific package, evaluate
		MCMcmUpdater disableUpdatesOfPackage: <packageName>

Class Variables definitions:

DefaultUpdateURL - String: the URL that will be checked by default for updates.  This would be set for a common standard location to check.

Repository - A registry of known MCMcmUpdater instances identified by repository URL and update map name.

SkipPackages - Set of Strings: names of packages to not update in MCMcmUpdater (empty by default).

UpdateMissingPackages - Boolean: if true (default), new packages in the update config map will be loaded unless they are in SkipPackages.  If false, packages not currently loaded in the image will not be loaded by MCMcmUpdater.  (This can be dangerous if packages are split - use at your own risk).

Instance Variables:

updateMapName - Base name of the files used for this updater, typically a name such as 'update' or 'update.spur'.

repository - URL of the repository in which the update maps are located.

lastUpdateMap - Dictionary of Integer: version number of the last loaded update map per repository.  Keeps track of the last configuration map, so that the utility will not have to run through the full history in the repositories each time you ask to update.

"
Class {
	#name : #MCMcmUpdater,
	#superclass : #Object,
	#instVars : [
		'repository',
		'updateMapName',
		'lastUpdateMap'
	],
	#classVars : [
		'DefaultUpdateMap',
		'DefaultUpdateURL',
		'Registry',
		'SkipPackages',
		'UpdateFromServerAtStartup',
		'UpdateMissingPackages'
	],
	#category : #MonticelloConfigurations
}

{ #category : #'class initialization' }
MCMcmUpdater class >> clearRegistry [
	"Save the current default updater, clear the registry, and re-register the current updater.
	This is intended for cleaning up an image prior to public release. Assumes that the
	current updater is the one intended for ongoing use in this image."

	"MCMcmUpdater clearRegistry"

	| current |
	current := self default.
	Registry := nil.
	current register.
	^Registry
]

{ #category : #'instance creation' }
MCMcmUpdater class >> default [
	"The default instance for system updates. Uses a default repository and update map
	name that may be set as preferences."

	^self updateMapNamed: self updateMapName repository: self defaultUpdateURL

]

{ #category : #updating }
MCMcmUpdater class >> defaultBaseName [
	"If not otherwise specified, look for update maps with this base name"

	^ 'update'
]

{ #category : #preferences }
MCMcmUpdater class >> defaultUpdateURL [
	"The default update repository URL"

	<preference: 'Update URL'
		category: 'updates'
		description: 'The repository URL for loading updates'
		type: #String>

	^DefaultUpdateURL ifNil:['']
]

{ #category : #preferences }
MCMcmUpdater class >> defaultUpdateURL: aString [
	"The default update repository URL"

	DefaultUpdateURL := aString
]

{ #category : #preferences }
MCMcmUpdater class >> disableUpdatesOfPackage: packageName [
	self skipPackages add: packageName
]

{ #category : #preferences }
MCMcmUpdater class >> enableUpdatesForAllPackages [
	SkipPackages := Set new
]

{ #category : #preferences }
MCMcmUpdater class >> enableUpdatesOfPackage: packageName [
	self skipPackages remove: packageName ifAbsent: [].
]

{ #category : #registry }
MCMcmUpdater class >> forRepository: repository updateMap: basename [
	"Answer the requested updater from the repository, or nil of not found"

	"MCMcmUpdater forRepository: 'http://source.squeak.org/trunk' updateMap: 'update'"
	"MCMcmUpdater forRepository: 'foo' updateMap: 'bar'"

	^ ((Registry ifNil: [Registry := Dictionary new])
		at: repository
		ifAbsent: [^nil])
			at: basename
			ifAbsent: [^nil]
]

{ #category : #'class initialization' }
MCMcmUpdater class >> initialize [
	"MCMcmUpdater initialize"

	DefaultUpdateURL ifNil:[
		DefaultUpdateURL := MCHttpRepository trunkUrlString.
		DefaultUpdateMap := self defaultBaseName.
	].

]

{ #category : #registry }
MCMcmUpdater class >> registry [
	"Private - unit test support"
	^Registry
]

{ #category : #registry }
MCMcmUpdater class >> registry: registry [
	"Private - unit test support"
	Registry := registry
]

{ #category : #'instance creation' }
MCMcmUpdater class >> repository: urlOrDirectoryPath updateMap: baseName [
	"Answer a new instance with empty last update map, not yet registered"

	^ self repository: urlOrDirectoryPath updateMap: baseName lastUpdateMap: Dictionary new
]

{ #category : #'instance creation' }
MCMcmUpdater class >> repository: urlOrDirectoryPath updateMap: baseName lastUpdateMap: dictionary [
	"Answer a new instance, not yet registered"

	^ self new
		repository: urlOrDirectoryPath;
		updateMapName: baseName;
		lastUpdateMap: dictionary
]

{ #category : #preferences }
MCMcmUpdater class >> skipPackages [
	^SkipPackages ifNil: [SkipPackages := Set new]
]

{ #category : #updating }
MCMcmUpdater class >> updateFromRepository: updaterUrlKey [
	"Update using an MCMcmUpdater identified by updaterUrlKey using the default
	update map baseName"

	"MCMcmUpdater updateFromRepository: 'http://squeaksource.com/MCUpdateTest' "

	^ self updateFromRepository: updaterUrlKey baseName: self defaultBaseName

]

{ #category : #updating }
MCMcmUpdater class >> updateFromRepository: updaterUrlKey baseName: baseName [
	"Update using an MCMcmUpdater identified by updaterUrlKey, and using
	update map baseName"

	"MCMcmUpdater
		updateFromRepository: 'http://squeaksource.com/MCUpdateTest'
		baseName: 'update' "

	^ self updateFromRepository: updaterUrlKey baseName: baseName interactive: true
]

{ #category : #updating }
MCMcmUpdater class >> updateFromRepository: updaterUrlKey baseName: baseName interactive: interactive [
	"Update using an MCMcmUpdater identified by updaterUrlKey, and using
	update map baseName"

	"MCMcmUpdater
		updateFromRepository: 'http://squeaksource.com/MCUpdateTest'
		baseName: 'update'
		interactive: false "

	^ (self updateMapNamed: baseName repository: updaterUrlKey)
		doUpdate: interactive
]

{ #category : #updating }
MCMcmUpdater class >> updateFromServer [
	"Update the image by loading all pending updates from the server."

	^self default doUpdate: true

]

{ #category : #preferences }
MCMcmUpdater class >> updateFromServerAtStartup [
	<preference: 'Update from server at startup'
		category: 'updates'
		description: 'If true, the system will check for and load any available updates.'
		type: #Boolean>
	^ UpdateFromServerAtStartup ifNil: [false].
]

{ #category : #preferences }
MCMcmUpdater class >> updateFromServerAtStartup: aBool [
	"Whether to update the image on startup."

	UpdateFromServerAtStartup := aBool.
]

{ #category : #preferences }
MCMcmUpdater class >> updateMapName [
	"The default update map name"

	<preference: 'Update map name'
		category: 'updates'
		description: 'Base name for the update maps'
		type: #String>

	^DefaultUpdateMap ifNil:['']
]

{ #category : #preferences }
MCMcmUpdater class >> updateMapName: mapName [ 
	"The default update map name for the default updater."

	DefaultUpdateMap := mapName
]

{ #category : #'instance creation' }
MCMcmUpdater class >> updateMapNamed: baseName repository: urlOrDirectoryPath [
	"Answer an instance for the given repository URL with a base update name baseName,
	Register a new instance if not present in the registry."

	" | updater1 updater2 |
	updater1 := self updateMapNamed: 'BAR' repository: 'FOO'.
	updater2 := self updateMapNamed: 'BAZ' repository: 'FOO'.
	updater1 unregister.
	updater2 unregister.
	Registry"

	^(self forRepository: urlOrDirectoryPath updateMap: baseName)
		ifNil: [ "register a new updater"
			(self repository: urlOrDirectoryPath updateMap: baseName) register].


]

{ #category : #preferences }
MCMcmUpdater class >> updateMissingPackages [
	"Whether to update missing (unloaded) packages"

	<preference: 'Update missing package'
		category: 'updates'
		description: 'If true, missing (unloaded) packages will be loaded during the update process.'
		type: #Boolean>

	^UpdateMissingPackages ifNil:[true]
]

{ #category : #preferences }
MCMcmUpdater class >> updateMissingPackages: aBool [
	"Whether to update missing (unloaded) packages"

	UpdateMissingPackages := aBool.
]

{ #category : #private }
MCMcmUpdater >> dependentPackages [
	"Answers all packages that are referenced in the update map."
	
	| repo updateList |
	repo := self getRepositoryFromRepositoryGroup.
	updateList := self refreshUpdateMapFor: repo with: (self updateListFor: repo).
	^ updateList gather: [:assoc |
		(repo versionNamed: assoc value) dependencies
			collect: [:dep | dep package]]
		
]

{ #category : #updating }
MCMcmUpdater >> doUpdate: interactive [
	"Update the image by loading all pending updates from the server. If this is
	the default updater for the system, update the system version when complete.
	If interteractive use a modal notifier, otherwise only update the transcript.
	Flush all caches. If a previous download failed this is often helpful"

	| config previousUpdateLevel ensureTranscriptSetting |
	previousUpdateLevel := SystemVersion current highestUpdate.
	MCFileBasedRepository flushAllCaches.	
	ensureTranscriptSetting := MCConfiguration ensureOpenTranscript.
	[ MCConfiguration ensureOpenTranscript: interactive.
	config := self updateFromRepository.
	config ifNil: [
		interactive ifTrue: [ ^self inform: 'Unable to retrieve updates from remote repository.' translated ].
		Transcript cr; show: '==========  Unable to retrieve updates from remote repository. ==========' translated; cr.
		^ self ].
	MCMcmUpdater default == self
		ifTrue: [
			config setSystemVersion.
			interactive ifTrue: [
				self inform: (self updateMessageFor: previousUpdateLevel)].
			Transcript cr;
				show: '==========  Update completed:  ' translated;
				show: previousUpdateLevel;
				show: ' -> ' ;
				show: SystemVersion current highestUpdate;
				show: ' =========='; cr ]
		ifFalse: [
			interactive
				ifTrue: [ self inform: 'Update completed.' ].
			Transcript cr; show: '==========  Update completed. ==========' translated; cr ] ]
		ensure: [ MCConfiguration ensureOpenTranscript: ensureTranscriptSetting].

	
]

{ #category : #updating }
MCMcmUpdater >> doUpdate: interactive upTo: versionNumber [
	"Update the image by loading all pending updates from the server. If this is
	the default updater for the system, update the system version when complete.
	If interteractive use a modal notifier, otherwise only update the transcript.
	Flush all caches. If a previous download failed this is often helpful"

	| config previousUpdateLevel |
	previousUpdateLevel := SystemVersion current highestUpdate.
	MCFileBasedRepository flushAllCaches.
	config := self updateFromRepositories: { self repository } upTo: versionNumber.
	config ifNil: [
		interactive ifTrue: [ ^self inform: 'Unable to retrieve updates from remote repository.' translated ].
		Transcript cr; show: '==========  Unable to retrieve updates from remote repository. ==========' translated; cr.
		^ self ].
	MCMcmUpdater default == self
		ifTrue: [
			config setSystemVersion.
			interactive ifTrue: [
				self inform: (self updateMessageFor: previousUpdateLevel)].
			Transcript cr;
				show: '==========  Update completed:  ' translated;
				show: previousUpdateLevel;
				show: ' -> ' ;
				show: SystemVersion current highestUpdate;
				show: ' =========='; cr ]
		ifFalse: [
			interactive
				ifTrue: [ self inform: 'Update completed.' ].
			Transcript cr; show: '==========  Update completed. ==========' translated; cr ]
	
]

{ #category : #updating }
MCMcmUpdater >> doUpdateUpTo: versionNumber [
	"Update the image by loading all pending updates from the server. If this is
	the default updater for the system, update the system version when complete.
	Flush all caches. If a previous download failed this is often helpful"

	^self doUpdate: true upTo: versionNumber

]

{ #category : #private }
MCMcmUpdater >> getRepositoryFromRepositoryGroup [
	"Answer the repository for this updater, ensuring that it is registered in the default MCRepositoryGroup"

	^ MCRepositoryGroup default repositories
		detect: [:r | r description = repository]
		ifNone: [| r |
			r := self repositoryAt: repository.
			MCRepositoryGroup default addRepository: r.
			r]

]

{ #category : #registry }
MCMcmUpdater >> isRegistered [
	"True if this instance is registered. False if another instance with the same
	repository and updateNameName is registered."
	
	^self == ((Registry
		at: repository
		ifAbsent: [^false])
			at: updateMapName
			ifAbsent: [^false]).


]

{ #category : #accessing }
MCMcmUpdater >> lastUpdateMap [

	^ lastUpdateMap ifNil: [ lastUpdateMap := Dictionary new ]

]

{ #category : #accessing }
MCMcmUpdater >> lastUpdateMap: aDictionary [

	lastUpdateMap := aDictionary

]

{ #category : #printing }
MCMcmUpdater >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' on ''';
		nextPutAll: updateMapName asString;
		nextPutAll:  ''' at ';
		nextPutAll: repository asString
]

{ #category : #updating }
MCMcmUpdater >> refreshUpdateMapFor: r with: updateList [
	"Update the lastUpdateMap and answer a possibly reduced updateList"

	| config |
	(lastUpdateMap at: r description ifAbsent: [0]) = 0 ifTrue: [
		"No update has ever been loaded from this repo. If no package is
		present in the image either, we can skip right to the latest config"
		config := r versionNamed: updateList last value.
		(config dependencies anySatisfy: [:dep | dep package hasWorkingCopy])
			ifFalse: [(self useLatestPackagesFrom: r)
					ifTrue: [lastUpdateMap at: r description put: updateList last key].
				updateList isEmpty
					ifTrue: [^ #()]
					ifFalse: [^ updateList last: 1]]].
	^ updateList

]

{ #category : #registry }
MCMcmUpdater >> register [
	"Register this instance, keyed by repository and update map name. Each update
	 maintains its own lastUpdateMap. The registry permits multilple updaters to be
	maintained, with each updater keeping track of its own last update map."
	
	repository ifNil: [self error: 'repository is ', repository asString].
	updateMapName ifNil: [self error: 'updateMapName is ', updateMapName asString].
	updateMapName isEmpty ifTrue:  [self error: 'updateMapName must be specified'].
	((Registry ifNil: [Registry := Dictionary new])
		at: repository
		ifAbsentPut: [Dictionary new])
			at: updateMapName put: self


]

{ #category : #accessing }
MCMcmUpdater >> repository [
	"URL string of the repository for the update maps"

	^ repository
]

{ #category : #accessing }
MCMcmUpdater >> repository: urlOrDirectoryPath [

	repository := urlOrDirectoryPath
]

{ #category : #private }
MCMcmUpdater >> repositoryAt: urlOrDirectoryPath [
	"Answer a repository, assuming that urlOrDirectoryPath represents
	either an HTTP repository or a local directory repository. The common
	case is an HTTP repository, but a local repository may be useful for
	testing an update stream prior to posting the update maps to a public
	location."

	(FileDirectory default directoryExists: urlOrDirectoryPath)
		ifTrue: [^ MCDirectoryRepository path: urlOrDirectoryPath]
		ifFalse: [^ MCHttpRepository
				location: repository
				user: ''
				password: '']

]

{ #category : #private }
MCMcmUpdater >> skipPackages [
	^SkipPackages ifNil: [SkipPackages := Set new]
]

{ #category : #registry }
MCMcmUpdater >> unregister [
	"If this instance is registered, remove it frorm the registry."
	
	self isRegistered
		ifTrue: [(Registry at: repository) removeKey: updateMapName.
				(Registry at: repository) isEmpty
					ifTrue: [Registry removeKey: repository]]

]

{ #category : #updating }
MCMcmUpdater >> updateFromConfig: config [

	"Skip packages that were specifically unloaded"
	config dependencies: (config dependencies 
		reject: [:dep| self class skipPackages includes: dep package name]).
	self class updateMissingPackages ifFalse:[
		"Skip packages that are not in the image"
		config dependencies: (config dependencies 
			select: [:dep| dep package hasWorkingCopy])].
	(config dependencies allSatisfy:[:dep| dep isFulfilled]) 
		ifFalse:[config upgrade].

]

{ #category : #updating }
MCMcmUpdater >> updateFromRepositories: repositoryUrls upTo: versionNumber [
	"MCMcmUpdater updateFromRepositories: #(
		'http://squeaksource.com/MCUpdateTest'
	)"

	| repos config |
	MCConfiguration upgradeIsMerge: true.
	"The list of repositories to consult in order"
	repos := repositoryUrls collect:[:url| 
		MCRepositoryGroup default repositories 
			detect:[:r| r description = url]
			ifNone:[ | r |
				r := MCHttpRepository location: url user: '' password: ''.
				MCRepositoryGroup default addRepository: r.
				r]].

	"The list of updates-author.version.mcm sorted by version"
	repos do:[ :r | config := self updateFromRepository: r upTo: versionNumber].
	^config
]

{ #category : #updating }
MCMcmUpdater >> updateFromRepository [

	| config repo |
	repo := self getRepositoryFromRepositoryGroup.
	repo cacheAllFileNamesDuring: [ | updateList |
		updateList := self updateListFor: repo.
		"Proceed only if there are updates available at all."
		updateList ifNotEmpty: [
			updateList := self refreshUpdateMapFor: repo with: updateList.
			"Now process each update file. Check if we have all dependencies and if not,
			load the entire configuration (this is mostly to skip older updates quickly)"
			updateList do:[:assoc|
				ProgressNotification signal: '' extra: 'Processing ', assoc value.
				config := repo versionNamed: assoc value.
				self updateFromConfig: config.
				self lastUpdateMap at: repo description put: assoc key.
			] displayingProgress: 'Processing configurations'.
			"We've loaded all the provided update configurations.
			Use the latest configuration to update all the remaining packages."
			(self useLatestPackagesFrom: repo) ifTrue: [
				config updateFromRepositories.
				config upgrade].
		]].
	^ config

]

{ #category : #updating }
MCMcmUpdater >> updateFromRepository: repository upTo: versionNumber [

	| config |
	repository cacheAllFileNamesDuring: [ | updateList |
		updateList := self updateListFor: repository.
		"Proceed only if there are updates available at all."
		updateList ifNotEmpty: [
			updateList := self refreshUpdateMapFor: repository with: updateList.
			"Now process each update file. Check if we have all dependencies and if not,
			load the entire configuration (this is mostly to skip older updates quickly)"
			updateList do:[:assoc|
				assoc key > versionNumber ifTrue: [^config].
				ProgressNotification signal: '' extra: 'Processing ', assoc value.
				config := repository versionNamed: assoc value.
				self updateFromConfig: config.
				self lastUpdateMap at: repository description put: assoc key.
			] displayingProgress: 'Processing configurations'.
		]].
	^config

]

{ #category : #private }
MCMcmUpdater >> updateListFor: repo [

	| updateList allNames minVersion |
	updateList := OrderedCollection new.
	minVersion := self lastUpdateMap at: repo description ifAbsent: [0].
	"Find all the update-*.mcm files"
	allNames := 'Checking ', repo description
		displayProgressFrom: 0 to: 1 during: [:bar| 
			bar value: 0.
			repo allFileNamesOrCache ].
	allNames do: [:fileName | | version |
		((fileName endsWith: '.mcm')
			and: [fileName packageAndBranchName = self updateMapName
				and: [(version := fileName versionNumber) >= minVersion]]) 
					ifTrue: [updateList add: version -> fileName]].
	^updateList sort
]

{ #category : #accessing }
MCMcmUpdater >> updateMapName [
	"Name for update map, without version info"

	^ updateMapName ifNil: [updateMapName := self class updateMapName]
]

{ #category : #accessing }
MCMcmUpdater >> updateMapName: aString [
	"Name for update map, without version info"
	updateMapName := aString
]

{ #category : #private }
MCMcmUpdater >> updateMessageFor: previousUpdateLevel [

	^ ('Update completed.<br><br>Version: {1}<br>Update: {3}<b>{2}</b><br><br>Url: <a href="{4}">{4}</a><br>Map: ''{5}''<br>TravisCI status: <a href="{8}"><img src="{7}" /></a>{6}' translated format: {
			SystemVersion current version.
			SystemVersion current highestUpdate.
			previousUpdateLevel = SystemVersion current highestUpdate
				ifTrue: ['']
				ifFalse: [previousUpdateLevel asString, ' -> '].
			self repository.
			MCMcmUpdater updateMapName.
			SystemVersion current description ifEmpty: [''] ifNotEmpty: [:d |
				'<br><br>', (d copyReplaceAll: String cr with: '<br>')].
			SystemVersion current ciStatusBadgeUrl.
			SystemVersion current ciStatusPageUrl.
				}) asTextFromHtml
]

{ #category : #private }
MCMcmUpdater >> useLatestPackagesFrom: repo [
	"for overriding on a per repository basis"
	^true
]
