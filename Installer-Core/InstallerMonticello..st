Class {
	#name : #InstallerMonticello,
	#superclass : #Installer,
	#instVars : [
		'mc',
		'root',
		'project'
	],
	#category : #'Installer-Core'
}

{ #category : #'basic interface' }
InstallerMonticello >> basicAvailablePackages [
	^ self mc allPackageNames
]

{ #category : #'basic interface' }
InstallerMonticello >> basicBrowse [
	 "Installer ss project: 'Installer'; browse: 'Installer-Core'."

	| it |
	it := self mcThing.
	
	(it class includesSelector: #browse) ifTrue: [ ^ it browse ].
	
	(it instVarNamed: 'versions') do: [ :each | each browse ].
]

{ #category : #'basic interface' }
InstallerMonticello >> basicInstall [
	 
	self withAnswersDo: [ self mcThing load ].
	self logCR: 'loaded'.

]

{ #category : #'basic interface' }
InstallerMonticello >> basicVersions [

	^ (self availablePackages select: [ :p | ( self package,'-*.mcz' ) match: p ]) collect: [ :p | self copy package: p  ; yourself ].
 
]

{ #category : #'basic interface' }
InstallerMonticello >> basicView [
	 "Installer ss project: 'Installer'; view: 'Installer-Core'. "
	| it |
	
	packages isEmptyOrNil ifTrue: [ self mc morphicOpen: nil ].
	
	it := self mcThing. 
	(it respondsTo: #open) ifTrue: [ ^ it open ].

	"in case an old mc doesnt have #open"
	
	(it instVarNamed: 'versions') do: [ :each | each open ].

]

{ #category : #'instance creation' }
InstallerMonticello >> cache [
	
	mc := self classMCCacheRepository default.
	root := mc directory localName
 
]

{ #category : #'class references' }
InstallerMonticello >> classMCCacheRepository [

	^Smalltalk at: #MCCacheRepository ifAbsent: [ self error: 'Monticello not present' ]
	
]

{ #category : #'class references' }
InstallerMonticello >> classMCDirectoryRepository [

	^Smalltalk at: #MCDirectoryRepository ifAbsent: [ self error: 'Monticello not present' ]
	
]

{ #category : #'class references' }
InstallerMonticello >> classMCFtpRepository [

	^Smalltalk at: #MCFtpRepository ifAbsent: [ self error: 'Monticello not present' ]
	
]

{ #category : #'class references' }
InstallerMonticello >> classMCGOODSRepository [

	^Smalltalk at: #MCGOODSRepository ifAbsent: [ self error: 'Monticello not present' ]
	
]

{ #category : #'class references' }
InstallerMonticello >> classMCHttpRepository [

	^Smalltalk at: #MCHttpRepository ifAbsent: [ self error: 'Monticello not present' ]
	
]

{ #category : #'class references' }
InstallerMonticello >> classMCMagmaRepository [

	^Smalltalk at: #MCMagmaRepository ifAbsent: [ self error: 'Magma not present' ]
	
]

{ #category : #'class references' }
InstallerMonticello >> classMCSmtpRepository [

	^Smalltalk at: #MCSmtpRepository ifAbsent: [ self error: 'Monticello not present' ]
	
]

{ #category : #'class references' }
InstallerMonticello >> classMCVersionLoader [

	^Smalltalk at: #MCVersionLoader  ifAbsent: [ self error: 'Monticello not present' ]
]

{ #category : #'instance creation' }
InstallerMonticello >> directory: dir [

	| directory |
	directory := dir isString 
		ifTrue: [  FileDirectory on: (FileDirectory default fullNameFor: dir) ]
		ifFalse: [ dir ].
		
	mc := self classMCDirectoryRepository new directory: directory; yourself.
 	root := dir
	
 
]

{ #category : #accessing }
InstallerMonticello >> fromUrl: aUrl [

	| url  path |
	
	url := aUrl asUrl.

	self http: url authority.
	
	path := url path.
	
	path size = 2 ifTrue: [ 
		self project: path first.
		path removeFirst.
 	].	
	
	path size = 1 ifTrue: [ self package: path first ].
]

{ #category : #'instance creation' }
InstallerMonticello >> ftp: host directory: dir user: name password: secret [
	"Installer mc ftp: 'mc.gjallar.se' directory: '' user: 'gjallar' password: secret."
	
	mc := self classMCFtpRepository host: host directory: dir user: name password: secret.
	root :=  dir.	
 
]

{ #category : #'instance creation' }
InstallerMonticello >> goods: host port: aport [
	
	mc := (self classMCGOODSRepository new) host: host port: aport; yourself
 
]

{ #category : #'instance creation' }
InstallerMonticello >> http: aUrl [  
	
	self http: aUrl user: '' password: ''
		
 
]

{ #category : #'instance creation' }
InstallerMonticello >> http: aUrl user: name password: secret [
	| url |
	url := (aUrl includesSubstring: '://')
		ifTrue: [aUrl]
		ifFalse: ['http://', aUrl].
	mc := self classMCHttpRepository location: url user: name password: secret.
	root := mc locationWithTrailingSlash	
 
]

{ #category : #'public interface' }
InstallerMonticello >> initialize [
	super initialize.
	mc := MCRepositoryGroup default
]

{ #category : #accessing }
InstallerMonticello >> latest [ 
	| newPackage |
	newPackage := self package copyUpToLast: $-.
	self packages removeLast.
	self package: newPackage
	
"
Installer mc fromUrl: 'http://www.squeaksource.com/Installer/Installer-Core-kph.100.mcz'.
"
]

{ #category : #accessing }
InstallerMonticello >> latestFromUsers: list [

	| newPackage |
	newPackage := self package copyUpToLast: $-.
	self packages removeLast.
	self package: (list collect: [ :ea | newPackage, '-', ea ])
]

{ #category : #'instance creation' }
InstallerMonticello >> magma: host port: aport [
	
	mc := (self classMCMagmaRepository new) host: host port: aport; yourself
 
]

{ #category : #accessing }
InstallerMonticello >> mc [

	^ mc
]

{ #category : #accessing }
InstallerMonticello >> mc: aRepo [

	mc := aRepo
]

{ #category : #monticello }
InstallerMonticello >> mcSortFileBlock [

	^ [:a :b | 
        	[(a findBetweenSubStrs: #($.)) allButLast last asInteger > (b findBetweenSubStrs: #($.)) allButLast last asInteger] 
				on: Error do: [:ex | false]].
]

{ #category : #monticello }
InstallerMonticello >> mcThing [
	| loader |
	loader := self classMCVersionLoader new.

	"several attempts to read files - repository readableFileNames
	sometimes fails"
	self packages
		do: [:pkg |
			| mcVersion versionNames sortedVersions fileToLoad version |
			mcVersion := pkg asMCVersionName .
			versionNames := mc versionNamesForPackageNamed:
				(mcVersion versionNumber = 0 
					ifTrue: [ "Just a package name specified, use it whole." pkg ] 
					ifFalse: [mcVersion packageName]).
			sortedVersions := versionNames sorted: self mcSortFileBlock.
			fileToLoad := self versionToLoad: mcVersion fromVersions: sortedVersions.
			fileToLoad
				ifNotNil: [version := mc versionNamed: fileToLoad.
					(version isKindOf: MCConfiguration)
						ifTrue: [^ version]
						ifFalse: [self normalizedRepositories do: [:repo |
								MCRepositoryGroup default addRepository: repo].
							self normalizedRepositories do: [:repo |
								version workingCopy repositoryGroup addRepository: repo].
							loader addVersion: version].
					self logCR: ' found ' , version fileName , '...']].
	^ loader
]

{ #category : #monticello }
InstallerMonticello >> mcUrl [

	^ self mc description 
	
]

{ #category : #monticello }
InstallerMonticello >> normalizedRepositories [
"Find an existing instance of any active repository so that we use whatever name and password the user usually uses. If not found, answer a copy"
	^ mc repositories replace: [:repo |
		(MCRepositoryGroup default repositories includes: repo)
			ifTrue: [repo]
			ifFalse: [repo copy]]
]

{ #category : #'public interface' }
InstallerMonticello >> open [
	self mc morphicOpen: nil
]

{ #category : #searching }
InstallerMonticello >> packagesMatching: aMatch [
	^ (self availablePackages
		select: [:p | ( aMatch , '.mcz' ) match: p])
		collect: [:p | self copy package: p ; yourself]
]

{ #category : #accessing }
InstallerMonticello >> project [

	^ project
]

{ #category : #accessing }
InstallerMonticello >> project: name [

	project := name.
	packages := nil.
	
	(mc respondsTo: #location:) ifTrue:[ mc := mc copy location: root , name ].
	(mc respondsTo: #directory:) ifTrue: [ mc := mc copy directory: root / name ].
		
	^self copy.
]

{ #category : #'public interface' }
InstallerMonticello >> unload [
	(MCWorkingCopy allManagers select: [ : each | self package match: each package name ]) do:
		[ : each | self logCR: 'Unloading ' , each package name.
		each unload.
		MCMcmUpdater disableUpdatesOfPackage: each package name ].
	self unloadCleanUp
]

{ #category : #'public interface' }
InstallerMonticello >> unload: match [ 

	self addPackage: match.
	self unload.
]

{ #category : #'public interface' }
InstallerMonticello >> unloadCleanUp [
 
	SystemOrganization removeEmptyCategories.

	"Until Mantis 5718 is addressed"
 	Smalltalk at: #PackagePaneBrowser ifPresent: [ :ppbClass | ppbClass allInstancesDo: [ :ppb | ppb updatePackages ]  ].
 	Smalltalk at: #Browser ifPresent: [ :bClass | bClass allInstancesDo: [ :b | b updateSystemCategories ] ].
	Smalltalk fixObsoleteReferences.
]

{ #category : #monticello }
InstallerMonticello >> versionToLoad: mcVersion fromVersions: sortedVersions [
	"From a list of sortedVersions, answer the most recent version or the
	exact version if explicitly specified."
	^ sortedVersions
		detect: [:aMCVersionName | aMCVersionName = mcVersion "explicit version specified"]
		ifNone: [sortedVersions
				detect: [:aMCVersionName | (mcVersion beginsWith: aMCVersionName packageAndBranchName)
						and: [aMCVersionName beginsWith: mcVersion "most recent version that matches"]]
				ifNone: []]
]
