Class {
	#name : #MCWorkingCopy,
	#superclass : #MCPackageManager,
	#instVars : [
		'versionInfo',
		'ancestry',
		'counter',
		'repositoryGroup',
		'requiredPackages',
		'environment'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #operations }
MCWorkingCopy class >> adoptVersionInfoFrom: anInstaller [
	|viCache|
	viCache := Dictionary new.
	anInstaller versionInfo keysAndValuesDo: [:packageName :info |
		(self forPackage: (MCPackage named: packageName))
			versionInfo: (self infoFromDictionary:  info cache: viCache)].
	[anInstaller clearVersionInfo] on: Error do: ["backwards compat"].
]

{ #category : #operations }
MCWorkingCopy class >> ancestorsFromArray: anArray cache: aDictionary [
	^ anArray ifNotNil: [anArray collect: [:dict | self infoFromDictionary: dict cache: aDictionary]]
]

{ #category : #operations }
MCWorkingCopy class >> checkModified: thorough [
	"Verify that all working copies with a modified flag are really modified, by comparing them to their stored snapshot. If the 'thorough' argument is true, check all packages, even unmodified ones."
	"MCWorkingCopy checkModified: true"
	| workingCopies |
	workingCopies := self allManagers.
	thorough ifFalse: [
		workingCopies := workingCopies select: [:wc | wc modified]].
	workingCopies do: [:wc | wc checkModified]
		displayingProgress: [:wc | 'Checking package {1} for changes ...' translated format: {wc packageName}]
]

{ #category : #'class initialization' }
MCWorkingCopy class >> cleanUp [ 
	self
"		 stubAllAncestry ;"
		 flushObsoletePackageInfos
]

{ #category : #cleanup }
MCWorkingCopy class >> flushObsoletePackageInfos [
	PackageOrganizer default flushObsoletePackages: [ : eachPackageInfo | eachPackageInfo class isObsolete ]
]

{ #category : #operations }
MCWorkingCopy class >> infoFromDictionary: aDictionary cache: cache [
	| id |
	id := (aDictionary at: #id) asString.
	^ cache at: id ifAbsentPut:
		[MCVersionInfo
			name: (aDictionary at: #name ifAbsent: [''])
			id: (UUID fromString: id)
			message: (aDictionary at: #message ifAbsent: [''])
			date: ([Date fromString: (aDictionary at: #date)] ifError: [nil])
			time: ([Time fromString: (aDictionary at: #time)] ifError: [nil])
			author: (aDictionary at: #author ifAbsent: [''])
			ancestors: (self ancestorsFromArray: (aDictionary at: #ancestors ifAbsent: []) cache: cache)
			stepChildren: (self ancestorsFromArray: (aDictionary at: #stepChildren ifAbsent: []) cache: cache)]
]

{ #category : #'class initialization' }
MCWorkingCopy class >> initialize [
	Smalltalk 
		at: #MczInstaller
		ifPresent: [:installer | self adoptVersionInfoFrom: installer].
	self updateInstVars.
	"Temporary conversion code -- remove later"
	registry ifNotNil:[registry rehash]. "changed #="
	self allInstancesDo:[:each| "moved notifications"
		Smalltalk at: #SystemChangeNotifier ifPresent:[:cls|
			cls uniqueInstance noMoreNotificationsFor: each.
		].
	].
	self registerForNotifications.
	Smalltalk addToStartUpList: self
]

{ #category : #'system startup' }
MCWorkingCopy class >> startUp: resuming [
	"Ensure Monticello is receiving system change notifications."

	resuming ifTrue:
		[Smalltalk
			at: #SystemChangeNotifier
			ifPresent: [:scn| self reregisterForNotificationsWith: scn uniqueInstance]]

]

{ #category : #cleanup }
MCWorkingCopy class >> stubAllAncestry [
	"Replace VersionInfo instances which are more than 10 versions behind with a MCInfoProxy which will dynamically re-retrieve them from the current repository if necessary."
	MCWorkingCopy allManagers do: [ : each | each stubAncestry ]
]

{ #category : #'system maintenance' }
MCWorkingCopy class >> updateInstVars [
	self allInstances do: [:ea | ea updateInstVars]
]

{ #category : #operations }
MCWorkingCopy >> adopt: aVersion [
	ancestry addAncestor: aVersion info.
	self changed.
]

{ #category : #accessing }
MCWorkingCopy >> ancestors [
	^ ancestry ancestors
]

{ #category : #accessing }
MCWorkingCopy >> ancestry [
	^ ancestry
]

{ #category : #operations }
MCWorkingCopy >> backportChangesTo: aVersionInfo [
	| baseVersion fullPatch currentVersionInfo currentVersion newSnapshot newAncestry |
	currentVersionInfo := self currentVersionInfo.
	baseVersion := self repositoryGroup versionWithInfo: aVersionInfo.
	currentVersion := self repositoryGroup versionWithInfo: currentVersionInfo.
	fullPatch := currentVersion snapshot patchRelativeToBase: baseVersion snapshot.
	(MCChangeSelectionRequest new
		patch: fullPatch;
		label: 'Changes to Backport';
		signal ) ifNotNil:
		[:partialPatch |
		newSnapshot := MCPatcher apply: partialPatch to: baseVersion snapshot.
		newAncestry := MCWorkingAncestry new
							addAncestor: aVersionInfo;
							addStepChild: currentVersionInfo;
							yourself.
		MCPackageLoader updatePackage: package withSnapshot: newSnapshot.
		ancestry := newAncestry.
		self modified: false; modified: true]
]

{ #category : #ui }
MCWorkingCopy >> browse [

	(MCSnapshotBrowser forSnapshot: self package snapshot)
			label: 'Snapshot Browser: ', self packageName;
			show.
]

{ #category : #operations }
MCWorkingCopy >> changesRelativeToRepository: aRepository [ 
	| ancestorVersion ancestorSnapshot |
	ancestorVersion := aRepository withCache
		closestAncestorVersionFor: ancestry
		ifNone: [ nil ].
	ancestorSnapshot := ancestorVersion
		ifNil: [ MCSnapshot empty ]
		ifNotNil: [ ancestorVersion snapshot ].
	^ package snapshot patchRelativeToBase: ancestorSnapshot
]

{ #category : #operations }
MCWorkingCopy >> checkModified [
	self ancestors size = 1
		ifFalse: [
			self modified: true]
		ifTrue: [
			| cleanSnapshot currentSnapshot modification |
			cleanSnapshot := self findSnapshotWithVersionInfo: self ancestors first.
			currentSnapshot := self package snapshot.
			modification := currentSnapshot patchRelativeToBase: cleanSnapshot.
			self modified: modification isEmpty not].

]

{ #category : #accessing }
MCWorkingCopy >> clearRequiredPackages [
	requiredPackages := nil
]

{ #category : #accessing }
MCWorkingCopy >> currentVersionInfo [
	^ (self needsSaving or: [ancestry ancestors isEmpty])
		ifTrue: [self newVersion info]
		ifFalse: [ancestry ancestors first]
]

{ #category : #accessing }
MCWorkingCopy >> description [
	^ self packageNameWithStar, ' (', (ancestry ancestorStringWithout: self packageName), ')'
]

{ #category : #accessing }
MCWorkingCopy >> environment [
	^ environment ifNil: [Smalltalk globals]
]

{ #category : #accessing }
MCWorkingCopy >> environment: anEnvironment [
	"Anything that is loaded to me should go into anEnvironment from now on."
	environment := anEnvironment.
	package := package inEnvironment: anEnvironment.
]

{ #category : #private }
MCWorkingCopy >> findSnapshotWithVersionInfo: aVersionInfo [
	^ aVersionInfo
		ifNil: [MCSnapshot empty]
		ifNotNil: [(self repositoryGroup versionWithInfo: aVersionInfo)
			ifNil: [MCSnapshot empty]
			ifNotNil: [:aVersion | aVersion snapshot]]
]

{ #category : #private }
MCWorkingCopy >> initialize [
	super initialize.
	ancestry := MCWorkingAncestry new
]

{ #category : #operations }
MCWorkingCopy >> loaded: aVersion [
	ancestry := MCWorkingAncestry new addAncestor: aVersion info.
	requiredPackages := OrderedCollection withAll: (aVersion dependencies collect: [:ea | ea package]).
	self modified: false.
	self changed
]

{ #category : #operations }
MCWorkingCopy >> merge: targetVersion [
	| ancestorInfo merger ancestorSnapshot packageSnapshot |
	targetVersion dependencies do: [:ea | ea resolve merge].
	ancestorInfo := targetVersion info commonAncestorWith: ancestry.
	
	ancestorInfo = targetVersion info ifTrue: [^ MCNoChangesException signal].
	
	packageSnapshot := package snapshot.
	ancestorSnapshot := ancestorInfo
							ifNotNil: [(self findSnapshotWithVersionInfo: ancestorInfo)]
							ifNil: [self notifyNoCommonAncestorWith: targetVersion.  MCSnapshot empty].
	
	(ancestry ancestors size = 1
		and: [ancestry ancestors first = ancestorInfo
		and: [(packageSnapshot patchRelativeToBase: ancestorSnapshot) isEmpty]])
				ifTrue: [^ targetVersion load].
	
	merger := MCThreeWayMerger 
				base: packageSnapshot
				target: targetVersion snapshot
				ancestor: ancestorSnapshot.
	((MCMergeResolutionRequest new merger: merger)
		signal: 'Merging ', targetVersion info name) = true ifTrue:
			[merger loadWithNameLike: targetVersion info name.
			ancestry addAncestor: targetVersion info].
	self changed
]

{ #category : #operations }
MCWorkingCopy >> merged: aVersion [
	ancestry addAncestor: aVersion info.
	self changed
]

{ #category : #accessing }
MCWorkingCopy >> needsSaving [
	^ self modified or: [self requiredPackages anySatisfy: [:ea | ea workingCopy needsSaving]]
]

{ #category : #repositories }
MCWorkingCopy >> newRepositoryGroupIfDefault [
	repositoryGroup == MCRepositoryGroup default
		ifTrue: [repositoryGroup := MCRepositoryGroup new].
	^ repositoryGroup
]

{ #category : #operations }
MCWorkingCopy >> newVersion [
	| packageSnapshot parentSnapshot patch patchBlock |
	parentSnapshot := self parentSnapshot.
	patchBlock :=  [patch := (packageSnapshot := package snapshot) patchRelativeToBase: parentSnapshot].
	patchBlock value. "Ensure that this is called at least once."
	^ (self requestVersionNameAndMessageWithSuggestion: self uniqueVersionName
		initialMessage: self patchMessageSuggestion
		patchBlock: patchBlock
	) ifNotNil: [:tuple |
		self newVersionWithName: tuple first withBlanksTrimmed
			message: (self patchMessageStripped: tuple second)
			snapshot: ((tuple size >= 3 and: [tuple third notNil and: [tuple third notEmpty]])
				ifTrue: [	MCPatcher apply: (patch ignoring: tuple third) to: parentSnapshot]
				ifFalse: [packageSnapshot])]
]

{ #category : #operations }
MCWorkingCopy >> newVersionWithName: nameString message: messageString [
	^self newVersionWithName: nameString message: messageString snapshot: package snapshot
]

{ #category : #operations }
MCWorkingCopy >> newVersionWithName: nameString message: messageString snapshot: aSnapshot [
	| info deps clean |
	info := ancestry infoWithName: nameString message: messageString.
	ancestry := MCWorkingAncestry new addAncestor: info.
	clean := (package snapshot patchRelativeToBase: aSnapshot) isEmpty.
	self modified: clean; modified: clean not. "hack to ensure label is updated"
	
	deps := self requiredPackages collect:
		[:ea | 
		MCVersionDependency
			package: ea
			info: ea workingCopy currentVersionInfo].

	^ MCVersion
		package: package
		info: info
		snapshot: aSnapshot
		dependencies: deps
]

{ #category : #private }
MCWorkingCopy >> nextVersionName [
	| branch oldName |
	ancestry ancestors isEmpty
		ifTrue:
			[ counter ifNil: [ counter := 0 ].
			branch := package name ]
		ifFalse:
			[ oldName := ancestry ancestors first versionName.
			branch := oldName packageAndBranchName.
			counter ifNil:
				[ counter := (ancestry ancestors detectMax:
					[ : eachVersionInfo | eachVersionInfo versionNumber ])
					ifNil: [ 0 ]
					ifNotNil:
						[ : highestNumbered | highestNumbered versionNumber ] ] ].
	counter := counter + 1.
	^ branch , '-' , Utilities authorInitials , '.' , counter asString
]

{ #category : #operations }
MCWorkingCopy >> notifyNoCommonAncestorWith: aVersion [
	self notify:
'Could not find a common ancestor between (',
aVersion info name,
') and (',
ancestry ancestorString, ').
Proceeding with this merge may cause spurious conflicts.'
]

{ #category : #private }
MCWorkingCopy >> parentSnapshot [
	"prefer parent in selected repository"
	MCRepositoryRequest signal ifNotNil: [:repo |
		self ancestors do: [:ancestor |
			(repo versionWithInfo: ancestor)
				ifNotNil: [:ver | ^ver snapshot]]].
	"otherwise, look in all repositories"
	self ancestors do: [:ancestor |
		(self repositoryGroup versionWithInfo: ancestor)
			ifNotNil: [:ver | ^ver snapshot]].
	"otherwise"
	^MCSnapshot empty
]

{ #category : #operations }
MCWorkingCopy >> patchMessageAncestry [
	^ String streamContents: [:strm |
		strm nextPutAll:	ancestry summary; cr.
		self ancestors do: [:ancestor |
			strm cr.
			strm nextPutAll: ancestor name; nextPut: $:; crtab.
			strm nextPutAll: ancestor message; cr.]]

]

{ #category : #operations }
MCWorkingCopy >> patchMessageChanges [
	| changes |
	changes := package snapshot patchRelativeToBase: self parentSnapshot.
	^ (MCPatchMessage new patch: changes) message
]

{ #category : #operations }
MCWorkingCopy >> patchMessageChangesDelimiter [
	^'=== text below is ignored ==='
]

{ #category : #operations }
MCWorkingCopy >> patchMessageChangesHeader [
	^ancestry summary, String cr,
	'Added, Modified, Deleted',
	(self ancestors ifEmpty: [''] ifNotEmpty: [' vs. ', self ancestors first name]), ':'
]

{ #category : #operations }
MCWorkingCopy >> patchMessageDefault [
	^ 'empty log message'
]

{ #category : #operations }
MCWorkingCopy >> patchMessageStripped: aString [
	| pos |
	pos := aString findString: self patchMessageChangesDelimiter.
	^ (pos > 0
		ifTrue: [aString first: pos - 1]
		ifFalse: [aString]) withBlanksTrimmed
]

{ #category : #operations }
MCWorkingCopy >> patchMessageSuggestion [
	^ String streamContents: [:strm | strm
		nextPutAll: self patchMessageDefault; cr;cr;
		nextPutAll: self patchMessageChangesDelimiter; cr;
		nextPutAll: self patchMessageAncestry; cr; cr;
		nextPutAll: self patchMessageChanges]
]

{ #category : #private }
MCWorkingCopy >> possiblyNewerVersions [

	^Array streamContents: [:strm |
		self repositoryGroup repositories do: [:repo |
			strm nextPutAll: (self possiblyNewerVersionsIn: repo)]]
]

{ #category : #private }
MCWorkingCopy >> possiblyNewerVersionsIn: aRepository [ 
	^ aRepository possiblyNewerVersionsOfAnyOf:
		((self ancestors collect: [:each | each versionName])
			ifEmpty: [Array empty]
			ifNotEmpty: [:ancestors | {ancestors detectMax: [:v | v versionNumber ]}])
]

{ #category : #accessing }
MCWorkingCopy >> printOn: stream [
	super printOn: stream.
	stream
		nextPut: $(;
		nextPutAll: self packageName;
		nextPut: $)
]

{ #category : #operations }
MCWorkingCopy >> renameToBe: newPackageName [ 
	| newWorkingCopy definitions |
	self modified ifTrue: [ self error: 'Should only rename an unmodified package.' ].
	(MCWorkingCopy allManagers anySatisfy:
		[ : each | each packageName = newPackageName ]) ifTrue: [ self error: newPackageName , ' is already taken.' ].
	definitions := self package snapshot definitions.
	PackageInfo registerPackageName: newPackageName.
	newWorkingCopy := (MCWorkingCopy forPackage: (MCPackage new name: newPackageName))
		 repositoryGroup: self repositoryGroup ;
		 requiredPackages: self requiredPackages copy ;
		 modified: true ;
		 yourself.
	definitions do:
		[ : each | each
			handlePackageRename: self package name
			to: newPackageName ].
	self ancestors do:
		[ : each | newWorkingCopy ancestry addAncestor: each ].
	newWorkingCopy package snapshot definitions size = definitions size ifTrue:
		[ PackageOrganizer default unregisterPackage: (PackageInfo named: self packageName).
		self unregister ].
	^ newWorkingCopy
]

{ #category : #operations }
MCWorkingCopy >> reparent: aVersion [ 
	"Let aNode be the sole parent of this version"
	ancestry reparent: aVersion info.
	self
		 checkModified ;
		 changed
]

{ #category : #repositories }
MCWorkingCopy >> repositoryGroup [
	^ repositoryGroup ifNil: [repositoryGroup := MCRepositoryGroup new]
]

{ #category : #repositories }
MCWorkingCopy >> repositoryGroup: aRepositoryGroup [
	repositoryGroup := aRepositoryGroup
]

{ #category : #private }
MCWorkingCopy >> requestVersionNameAndMessageWithSuggestion: nameString initialMessage: msgString patchBlock: aPatchBlock [
	^ (MCVersionNameAndMessageRequest new
		suggestedName: nameString;
		initialMessage: msgString;
		patchBlock: aPatchBlock
		) signal
]

{ #category : #accessing }
MCWorkingCopy >> requirePackage: aPackage [
	(self requiredPackages includes: aPackage) ifFalse: [requiredPackages add: aPackage]
]

{ #category : #accessing }
MCWorkingCopy >> requiredPackages [
	^ requiredPackages ifNil: [requiredPackages := OrderedCollection new]
]

{ #category : #private }
MCWorkingCopy >> requiredPackages: aCollection [
	requiredPackages := aCollection
]

{ #category : #operations }
MCWorkingCopy >> stubAncestry [
	"Stub all but the most recent 10 of my ancestry tree to save memory with a proxy which can be transparently accessed later, if necessary."
	self ancestors ifEmpty: [ ^ self ].
	repositoryGroup ifNotNil:
		[ | tenAgo count |
		count := 0.
		ancestry ancestorsDoWhileTrue:
			[ : each | tenAgo := each.
			(count := count + 1) < 10 ].
		tenAgo
			stubAncestryFor: self
			using: repositoryGroup ]
]

{ #category : #private }
MCWorkingCopy >> uniqueVersionName [
	|versionName|
	counter := nil.
	[versionName := self nextVersionName.
	(MCRepository packageCache includesVersionNamed: versionName)
		or: [self repositoryGroup includesVersionNamed: versionName]] whileTrue.
	^ versionName
]

{ #category : #operations }
MCWorkingCopy >> unload [
	self withEnvironmentActiveDo: [MCPackageLoader unloadPackage: self package].
	self unregisterSubpackages.
	self unregister.
]

{ #category : #migration }
MCWorkingCopy >> updateInstVars [
	ancestry ifNil:
		[ancestry := MCWorkingAncestry new.
		versionInfo ifNotNil:
			[versionInfo ancestors do: [:ea | ancestry addAncestor: ea].
			versionInfo := nil]]
]

{ #category : #accessing }
MCWorkingCopy >> versionInfo: aVersionInfo [
	ancestry := MCWorkingAncestry new addAncestor: aVersionInfo
]

{ #category : #private }
MCWorkingCopy >> versionSeparator [
	^ $_
]

{ #category : #private }
MCWorkingCopy >> withEnvironmentActiveDo: aBlock [
	^ self environment beCurrentDuring: aBlock
]
