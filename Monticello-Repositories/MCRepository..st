Class {
	#name : #MCRepository,
	#superclass : #Object,
	#instVars : [
		'creationTemplate',
		'storeDiffs'
	],
	#classVars : [
		'Settings'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #configuring }
MCRepository class >> allConcreteSubclasses [
	^ self withAllSubclasses reject: [:ea | ea isAbstract]
]

{ #category : #'ui-support' }
MCRepository class >> browseClassRevisionsService [
	^ ServiceAction
		id: #browseMcClassRevisions
		text: 'browse revisions'
		button: 'mc'
		description: 'Browse revisions of this class definition from the first-listed HTTP repository of this package.'
		action:
			[ : aBrowserRequestor | aBrowserRequestor browseMcClassRevisions ]
		condition:
			[ : aBrowserRequestor | true ]
]

{ #category : #'ui-support' }
MCRepository class >> browseMethodRevisionsService [
	^ ServiceAction
		id: #browseMcMethodRevisions
		text: 'browse revisions'
		button: 'mc'
		description: 'Browse revisions of this method from the first-listed HTTP repository of this package.'
		action:
			[ : aBrowserRequestor | aBrowserRequestor browseMcMethodRevisions ]
		condition:
			[ : aBrowserRequestor | true ]
]

{ #category : #configuring }
MCRepository class >> creationTemplate [
	self subclassResponsibility.
]

{ #category : #configuring }
MCRepository class >> description [
	^ nil
]

{ #category : #'external settings' }
MCRepository class >> fetchExternalSettingsIn: aDirectory [
	"Scan for settings file"
	"MCRepository fetchExternalSettingsIn: ExternalSettings preferenceDirectory"

	| stream |
	(aDirectory fileExists: self settingsFileName)
		ifFalse: [^self].
	stream := aDirectory readOnlyFileNamed: self settingsFileName.
	stream
		ifNotNil: [
			[Settings := ExternalSettings parseServerEntryArgsFrom: stream]
				ensure: [stream close]].

]

{ #category : #configuring }
MCRepository class >> fillInTheBlankConfigure [
	^ self fillInTheBlankConfigure: self creationTemplate
			
]

{ #category : #configuring }
MCRepository class >> fillInTheBlankConfigure: aTemplateString [
	| chunk repo |
	
	aTemplateString ifNil: [ ^ false ].
	chunk := UIManager default
		multiLineRequest: self fillInTheBlankRequest
		centerAt: Sensor cursorPoint
		initialAnswer: aTemplateString
		answerHeight: 120.
			
	chunk 
		ifNotNil: [ 
			repo := self readFrom: chunk readStream.
			repo creationTemplate: chunk. 
	].

	^ repo
]

{ #category : #configuring }
MCRepository class >> fillInTheBlankRequest [
	self subclassResponsibility.
]

{ #category : #'well-known repositories' }
MCRepository class >> inbox [
	^ MCHttpRepository inbox
]

{ #category : #'class initialization' }
MCRepository class >> initialize [
	"self initialize"

	ExternalSettings registerClient: self.

]

{ #category : #configuring }
MCRepository class >> isAbstract [
	^ self description isNil
]

{ #category : #'instance creation' }
MCRepository class >> location: urlOrPath [
	"Answer an MCRepository for the given url or path. Accepted locations are:
		- http, and ftp urls (i.e., http://source.squeak.org/trunk)
		- directory paths (i.e., C:\Squeak\packages)
		- directory matches (i.e., C:\Squeak\packages\*)
	"

	^self location: urlOrPath username: '' password: ''
]

{ #category : #'instance creation' }
MCRepository class >> location: urlOrPath username: user password: pass [
	"Answer an MCRepository for the given url or path. Accepted locations are:
		- http, and ftp urls (i.e., http://source.squeak.org/trunk)
		- directory paths (i.e., C:\Squeak\packages)
		- directory matches (i.e., C:\Squeak\packages\*)
	If provided, the supplied user name and password will be used."

	| url |
	(urlOrPath findString: '://') > 0 ifTrue:[
		url := urlOrPath asUrl.
		^ url scheme caseOf: {
			['ftp'] -> [MCFtpRepository 
							host: url authority
							 directory: url pathString allButFirst
							user: user 
							password: user].
			['http'] -> [MCHttpRepository 
							location: urlOrPath 
							user: user 
							password: pass].
		} otherwise:[self error: 'Unsupported scheme: ', url scheme].
	].

	(urlOrPath endsWith: '*') ifTrue:[
		^MCSubDirectoryRepository new 
				directory: (FileDirectory on: urlOrPath allButLast)].

	^MCDirectoryRepository
			directory: (FileDirectory on: urlOrPath)
]

{ #category : #configuring }
MCRepository class >> morphicConfigure [
	^ self new
]

{ #category : #'well-known repositories' }
MCRepository class >> packageCache [
	^ MCCacheRepository default
]

{ #category : #'external settings' }
MCRepository class >> releaseExternalSettings [
	Settings := nil.

]

{ #category : #'external settings' }
MCRepository class >> settingsFileName [
	^ 'mcSettings'
]

{ #category : #'well-known repositories' }
MCRepository class >> treated [
	^ MCHttpRepository treated
]

{ #category : #'well-known repositories' }
MCRepository class >> trunk [
	^ MCHttpRepository trunk
]

{ #category : #testing }
MCRepository >> = other [
	^ other species = self species and: [other description = self description]
]

{ #category : #packages }
MCRepository >> allPackageAndBranchNames [
	"Currently this function is only supported by FileBased repositories."
	^ self allPackageNames
]

{ #category : #packages }
MCRepository >> allPackageNames [
	self subclassResponsibility
]

{ #category : #versions }
MCRepository >> allVersionsDo: aBlock [
	self allPackageNames asArray sort
		do:
			[ : eachPackageName | | sortedVersions |
			sortedVersions := (self versionNamesForPackageNamed: eachPackageName) sort:
				[ : a : b | a versionNumber < b versionNumber ].
			sortedVersions
				do:
					[ : eachVersionName | (self versionNamed: eachVersionName) ifNotNil:
						[ : ver | aBlock value: ver ] ]
				displayingProgress:
					[ : eachVersionName | 'Importing ' , eachVersionName ] ]
		displayingProgress:
			[ : eachPackageName | 'Importing versions of ' , eachPackageName ]
]

{ #category : #accessing }
MCRepository >> alwaysStoreDiffs [
	^ storeDiffs ifNil: [false]
]

{ #category : #accessing }
MCRepository >> asCreationTemplate [
	^ self creationTemplate
]

{ #category : #private }
MCRepository >> basicStoreVersion: aVersion [
	self subclassResponsibility
]

{ #category : #private }
MCRepository >> cacheAllFileNamesDuring: aBlock [
	"FileBasedRepository's can only access all version-names, therefore this is provided to allow client-code to direct caching of getting all filenames.  Other types of repositories offer more sophisticated kinds of access, so they don't need to cache, so simply run the block."
	^ aBlock value
]

{ #category : #private }
MCRepository >> cacheAllFilenames [
	"No-op by default.  Subclasses override for performance."
]

{ #category : #accessing }
MCRepository >> closestAncestorVersionFor: anAncestry ifNone: errorBlock [
	anAncestry breadthFirstAncestorsDo:
		[:ancestorInfo |
		(self versionWithInfo: ancestorInfo) ifNotNil: [:v | ^ v]].
	^ errorBlock value
]

{ #category : #versions }
MCRepository >> copyAllFrom: aMCRepository [ 
	"Copy all MCVersions from aMCRepository to the receiver."
	self cacheAllFileNamesDuring:
		[ aMCRepository cacheAllFileNamesDuring:
			[ | pkgCount |
			pkgCount := 0.
			'Copy all package versions from ' , aMCRepository description
				displayProgressFrom: 0
				to: aMCRepository allPackageNames size
				during:
					[ : pkgBar | aMCRepository allPackageNames asArray sort do:
						[ : eachPackageName | | versions verCount |
						verCount := 0.
						versions := (aMCRepository versionNamesForPackageNamed: eachPackageName) difference: (self versionNamesForPackageNamed: eachPackageName).
						'Progress for ' , eachPackageName
							displayProgressFrom: 0
							to: versions size
							during:
								[ : verBar | versions do:
									[ : eachVersionName | (aMCRepository versionNamed: eachVersionName) ifNotNil:
										[ : ver | self storeVersion: ver ].
									verBar value: (verCount := verCount + 1) ].
								pkgBar value: (pkgCount := pkgCount + 1) ] ] ] ] ]
]

{ #category : #versions }
MCRepository >> copyImageVersions [
	"For each package contained in the receiver, copy the version of that package which is currently loaded in this image.  If no version of a package is loaded in the image, nothing is copied for that package."
	self cacheAllFileNamesDuring:
		[ self allPackageNames do:
			[ : eachPkgName | MCWorkingCopy allManagers
				detect: [ : each | each packageName = eachPkgName ]
				ifFound:
					[ : loaded | loaded ancestors do:
						[ : infoToCopy | (self includesVersionNamed: infoToCopy versionName) ifFalse:
							[ (MCRepositoryGroup default versionWithInfo: infoToCopy)
								ifNil: [ Warning signal: infoToCopy name , ' not found in RepositoryGroup default.' ]
								ifNotNilDo:
									[ : ver | self storeVersion: ver ] ] ] ]
				ifNone: [ "Image specifies no version to copy." ] ] ]
]

{ #category : #accessing }
MCRepository >> creationTemplate [
	^ creationTemplate
]

{ #category : #accessing }
MCRepository >> creationTemplate: aString [ 
	creationTemplate := aString
]

{ #category : #'user interface' }
MCRepository >> description [
	^ self class name
]

{ #category : #accessing }
MCRepository >> doAlwaysStoreDiffs [
	storeDiffs := true
]

{ #category : #accessing }
MCRepository >> doNotAlwaysStoreDiffs [
	storeDiffs := false
]

{ #category : #private }
MCRepository >> flushCache [
	"Subclasses override as desired."
]

{ #category : #testing }
MCRepository >> hash [
	^ self description hash
]

{ #category : #versions }
MCRepository >> highestNumberedVersionForPackageNamed: aString [ 
	^ self versionNamed: (self highestNumberedVersionNameForPackageNamed: aString)
]

{ #category : #versions }
MCRepository >> highestNumberedVersionNameForPackageNamed: aString [ 
	^ (self versionNamesForPackageNamed: aString)
		ifEmpty: [ self error: aString , ' not found in ' , self asString ]
		ifNotEmptyDo:
			[ : versionNames | versionNames detectMax:
				[ : each | each versionNumber ] ]
]

{ #category : #versions }
MCRepository >> includesVersionNamed: aString [
	"Subclasses may want to override for better performance."
	^ (self versionNamed: aString) notNil
]

{ #category : #testing }
MCRepository >> isInbox [
	^ false
]

{ #category : #testing }
MCRepository >> isTreated [
	^ false
]

{ #category : #testing }
MCRepository >> isTrunk [
	^ false
]

{ #category : #testing }
MCRepository >> isValid [
	^true
]

{ #category : #versions }
MCRepository >> missingAncestryDo: oneArgBlock [ 
	"Value oneArgBlock with each of the MCVersionInfo ancestry that is missing from this repository."
	self cacheAllFileNamesDuring:
		[ self allPackageNames do:
			[ : each | self
				missingAncestryForPackageNamed: each
				do: oneArgBlock ] ]
]

{ #category : #versions }
MCRepository >> missingAncestryForPackageNamed: packageName do: oneArgBlock [ 
	| start |
	self cacheAllFileNamesDuring:
		[ start := self versionNamed: (self highestNumberedVersionNameForPackageNamed: packageName).
		self cacheAllFileNamesDuring:
			[ start info allAncestorsDo:
				[ : each | (self includesVersionNamed: each versionName) ifFalse: [ oneArgBlock value: each ] ] ] ]
]

{ #category : #'user interface' }
MCRepository >> morphicOpen [
	self morphicOpen: nil
]

{ #category : #'user interface' }
MCRepository >> morphicOpen: aWorkingCopy [
	(MCRepositoryInspector repository: self workingCopy: aWorkingCopy) show
]

{ #category : #accessing }
MCRepository >> normalized [
	^ (MCRepositoryGroup default repositories includes: self)
		ifTrue: [ self ]
		ifFalse: [ self copy ]
]

{ #category : #private }
MCRepository >> normalizedRepositories [
	^{ self normalized }
]

{ #category : #notifying }
MCRepository >> notificationForVersion: aVersion [
	^ MCVersionNotification version: aVersion repository: self
]

{ #category : #notifying }
MCRepository >> notifyList [
	^ #()
]

{ #category : #versions }
MCRepository >> obtainMissingAncestryFrom: sourceRepository [ 
	self cacheAllFileNamesDuring:
		[ self missingAncestryDo:
			[ : each | (sourceRepository includesVersionNamed: each versionName)
				ifTrue: [ self storeVersion: (sourceRepository versionNamed: each versionName) ]
				ifFalse: [ Notification signal: each versionName , ' not present in ' , sourceRepository asString ] ] ]
]

{ #category : #'user interface' }
MCRepository >> openAndEditTemplateCopy [
	^ self class fillInTheBlankConfigure: (self asCreationTemplate ifNil: [^nil])
]

{ #category : #versions }
MCRepository >> possiblyNewerVersionsOfAnyOf: versionNames [ 
	"Answer a collection of MCVersionNames which might be newer versions of the versions identified by versionNames."
	^self cacheAllFileNamesDuring: [
		versionNames
		inject: OrderedCollection new
		into:
			[ : coll : eachVersionName | | eachPackageName |
			eachPackageName := eachVersionName packageAndBranchName.
			(self versionNamesForPackageNamed: eachPackageName) do:
				[ : eachInSelf | (eachPackageName = eachInSelf packageAndBranchName and: [
					eachInSelf versionNumber > eachVersionName versionNumber or:
					[ eachInSelf versionNumber = eachVersionName versionNumber and: [ eachInSelf author ~= eachVersionName author ] ] ]) ifTrue: [ coll add: eachInSelf ] ].
			coll ] ]
]

{ #category : #accessing }
MCRepository >> prepareVersionForStorage: aVersion [
	^ self alwaysStoreDiffs
		ifTrue: [aVersion asDiffAgainst:
				 (self withCache closestAncestorVersionFor: aVersion info ifNone: [^ aVersion])]
		ifFalse: [aVersion]
]

{ #category : #printing }
MCRepository >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self description;
		nextPut: $).
]

{ #category : #accessing }
MCRepository >> refresh [
	"Subclasses override if necessary."
]

{ #category : #accessing }
MCRepository >> repositories [
	^{ self }
]

{ #category : #notifying }
MCRepository >> sendNotificationsForVersion: aVersion [
	| notification notifyList |
	notifyList := self notifyList.
	notifyList isEmpty ifFalse:
		[notification := self notificationForVersion: aVersion.
		notifyList do: [:ea | notification notify: ea]]
]

{ #category : #storing }
MCRepository >> storeVersion: aMCVersionOrConfiguration [
	self basicStoreVersion: (self prepareVersionForStorage: aMCVersionOrConfiguration).
	self sendNotificationsForVersion: aMCVersionOrConfiguration
]

{ #category : #versions }
MCRepository >> versionNamed: aMCVersionName [
	"Answer the MCVersion with name, aMCVersionName, or nil if it doesn't exist in this repository."
	self subclassResponsibility
]

{ #category : #versions }
MCRepository >> versionNamesForPackageNamed: aString [
	"Answer a collection of MCVersionNames whose Package is named aString."
	self subclassResponsibility
]

{ #category : #versions }
MCRepository >> versionWithInfo: aVersionInfo [
	^ self versionWithInfo: aVersionInfo ifAbsent: [nil]
]

{ #category : #versions }
MCRepository >> versionWithInfo: aVersionInfo ifAbsent: aBlock [
	self subclassResponsibility 
]

{ #category : #'user interface' }
MCRepository >> wasRemoved [
	"Subclasses may override to, for example, disconnect a db session."
]

{ #category : #accessing }
MCRepository >> withCache [
	"Answer the receiver with package-cache in front of it."
	^ MCRepositoryGroup with: self
]
