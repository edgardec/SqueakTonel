Class {
	#name : #MCFileBasedRepository,
	#superclass : #MCRepository,
	#instVars : [
		'cache',
		'allFileNamesCache',
		'allVersionNamesCache'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #release }
MCFileBasedRepository class >> cleanUp [
	"Flush caches"

	self flushAllCaches.
]

{ #category : #release }
MCFileBasedRepository class >> flushAllCaches [
	self allSubInstancesDo: [:ea | ea flushCache]
]

{ #category : #'private-files' }
MCFileBasedRepository >> allFileNames [
	self subclassResponsibility
]

{ #category : #'private-files' }
MCFileBasedRepository >> allFileNamesForVersionNamed: aMCVersionName [ 
	^ self
		filterFileNames: self readableFileNames
		forVersionNamed: aMCVersionName
]

{ #category : #'private-files' }
MCFileBasedRepository >> allFileNamesOrCache [
	
	^allFileNamesCache ifNil: [ self allFileNames ]
]

{ #category : #packages }
MCFileBasedRepository >> allPackageAndBranchNames [
	^ self validNames: #packageAndBranchName
]

{ #category : #packages }
MCFileBasedRepository >> allPackageNames [
	^ self validNames: #packageName
]

{ #category : #'private-files' }
MCFileBasedRepository >> allVersionNames [

	^allVersionNamesCache ifNil: [
		self readableFileNames collect: [ :each | each versionName ] ]
]

{ #category : #private }
MCFileBasedRepository >> basicStoreVersion: aMCVersionOrConfiguration [ 
	self
		writeStreamForFileNamed: aMCVersionOrConfiguration fileName
		do: [ : s | aMCVersionOrConfiguration fileOutOn: s ].
	aMCVersionOrConfiguration isCacheable ifTrue:
		[ cache ifNil: [ cache := Dictionary new ].
		self resizeCache: cache.
		cache
			at: aMCVersionOrConfiguration fileName
			put: aMCVersionOrConfiguration ]
]

{ #category : #private }
MCFileBasedRepository >> cache [
	^ cache ifNil: [cache := Dictionary new]
]

{ #category : #private }
MCFileBasedRepository >> cacheAllFileNamesDuring: aBlock [ 
	"Cache the result of #allFileNames and #allVersionNames during aBlock"
	allFileNamesCache ifNotNil: [ ^ aBlock value ].
	self cacheAllFilenames.
	^ aBlock ensure: [ allFileNamesCache := allVersionNamesCache := nil ]
]

{ #category : #private }
MCFileBasedRepository >> cacheAllFilenames [
	allFileNamesCache ifNil:
		[ allFileNamesCache := self allFileNames.
		allVersionNamesCache := self allVersionNames ]
]

{ #category : #private }
MCFileBasedRepository >> cachedFileNames [
	^cache == nil
		ifTrue: [#()]
		ifFalse: [cache keys]
]

{ #category : #'private-files' }
MCFileBasedRepository >> canReadFileNamed: aString [
	| reader |
	reader := MCVersionReader readerClassForFileNamed: aString.
	^ reader notNil
]

{ #category : #accessing }
MCFileBasedRepository >> closestAncestorVersionFor: anAncestry ifNone: errorBlock [
	^ self cacheAllFileNamesDuring:
		[super closestAncestorVersionFor: anAncestry ifNone: errorBlock]
]

{ #category : #'private-files' }
MCFileBasedRepository >> filterFileNames: aCollection forVersionNamed: aMCVersionName [ 
	^ aCollection select:
		[ : ea | aMCVersionName = ea ]
]

{ #category : #private }
MCFileBasedRepository >> flushAllFilenames [
	allFileNamesCache := allVersionNamesCache := nil
]

{ #category : #private }
MCFileBasedRepository >> flushCache [
	self flushAllFilenames.
	cache := nil
]

{ #category : #versions }
MCFileBasedRepository >> includesVersionNamed: aString [ 

	| comparable |
	comparable := ((aString endsWith: '.mcz') and: [ aString size > 4 ])
		ifTrue: [ aString allButLast: 4 ]
		ifFalse: [ aString ].
	^ self allVersionNames includes: comparable
]

{ #category : #'private-files' }
MCFileBasedRepository >> loadVersionFromFileNamed: aString [
	^ self versionReaderForFileNamed: aString do: [:r | r version]
]

{ #category : #'private-files' }
MCFileBasedRepository >> loadVersionInfoFromFileNamed: aString [
	^ self versionReaderForFileNamed: aString do: [:r | r info]
	
]

{ #category : #private }
MCFileBasedRepository >> maxCacheSize [
	^ 8
]

{ #category : #'user interface' }
MCFileBasedRepository >> morphicOpen: aWorkingCopy [
	(MCFileRepositoryInspector repository: self workingCopy: aWorkingCopy)
		show
]

{ #category : #notifying }
MCFileBasedRepository >> notifyList [
	(self allFileNames includes: 'notify') ifFalse: [^ #()].
	^ self readStreamForFileNamed: 'notify' do:
		[:s |
		s upToEnd lines]
]

{ #category : #'private-files' }
MCFileBasedRepository >> readableFileNames [
	"Answer an Array of MCVersionNames representing every file in this repository; first the ones from the cache (whether or not they still exist in the repository) followed by every other file in this repository that Monticello can read."
	| all cached new |
	all := self allFileNamesOrCache.	"from repository"
	cached := self cachedFileNames.	"in memory"
	"Create a sparse Set, so we can avoid #= for MCVersionNames during the difference calculation."
	new := all difference: (
		(Set new: (cached size * 8 min: all size))
			addAll: cached;
			yourself).
	^ (cached asArray, new)
		select: [:ea | self canReadFileNamed: ea]
]

{ #category : #accessing }
MCFileBasedRepository >> refresh [
	super refresh.
	self flushCache
]

{ #category : #private }
MCFileBasedRepository >> resizeCache: aDictionary [
	[aDictionary size <= self maxCacheSize] whileFalse:
		[aDictionary removeKey: aDictionary keys atRandom]
]

{ #category : #private }
MCFileBasedRepository >> validNames: selectorSymbol [
	| answer |
	answer := Set new.
	self allFileNamesOrCache do:
		[ : each | | versionName |
		versionName := each asMCVersionName.
		versionName isValid ifTrue: [ answer add: (versionName perform: selectorSymbol) ] ].
	^ answer
]

{ #category : #'private-files' }
MCFileBasedRepository >> versionInfoFromFileNamed: aString [
	self cache at: aString ifPresent: [:v | ^ v info].
	^ self loadVersionInfoFromFileNamed: aString
]

{ #category : #versions }
MCFileBasedRepository >> versionNamed: aMCVersionName [ 
	"For FileBased repositories, aMCVersionName must have the appropriate extension!  :-("
	| version |
	version := self cache
		at: aMCVersionName
		ifAbsent:
			[ [ self loadVersionFromFileNamed: aMCVersionName ]
				on: FileDoesNotExistException
				do: [ : err | nil ] ].
	self resizeCache: cache.
	(version notNil and: [ version isCacheable ]) ifTrue:
		[ cache
			at: aMCVersionName asMCVersionName
			put: version ].
	^ version
]

{ #category : #versions }
MCFileBasedRepository >> versionNamesForPackageNamed: packageName [
	^ Array streamContents:
		[ : stream | | wantBranch |
		wantBranch := packageName includes: $..
		self allFileNamesOrCache do:
			[ : each | | mcVersionName branchName |
			mcVersionName := each asMCVersionName.
			branchName := wantBranch
				ifTrue: [mcVersionName packageAndBranchName]
				ifFalse: [mcVersionName packageName].
			packageName = branchName ifTrue: [ stream nextPut: mcVersionName ] ] ]
]

{ #category : #'private-files' }
MCFileBasedRepository >> versionReaderForFileNamed: aString do: aBlock [
	^ self
		readStreamForFileNamed: aString
		do: [:s |
			(MCVersionReader readerClassForFileNamed: aString) ifNotNil:
				[:class | aBlock value: (class on: s fileName: aString)]]

]

{ #category : #versions }
MCFileBasedRepository >> versionWithInfo: aVersionInfo ifAbsent: errorBlock [
	(self allFileNamesForVersionNamed: aVersionInfo versionName) do:
		[:fileName | | version |
		version := self versionNamed: fileName.
		version info = aVersionInfo ifTrue: [^ version]].
	^ errorBlock value
]

{ #category : #'private-files' }
MCFileBasedRepository >> writeStreamForFileNamed: aString do: aBlock [
	^ self writeStreamForFileNamed: aString replace: false do: aBlock
]
