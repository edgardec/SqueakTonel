Class {
	#name : #ResourceManager,
	#superclass : #Object,
	#instVars : [
		'resourceMap',
		'loaded',
		'unloaded',
		'stopSemaphore',
		'stopFlag',
		'loaderProcess'
	],
	#classVars : [
		'CachedResources',
		'LocalizedExternalResources'
	],
	#category : #'System-Support'
}

{ #category : #'private-resources' }
ResourceManager class >> addCacheLocation: aString for: urlString [
	| locations |
	locations := CachedResources at: urlString ifAbsentPut: [#()].
	(locations includes: aString)
		ifFalse: [CachedResources at: urlString put: ({aString} , locations)]
]

{ #category : #'resource caching' }
ResourceManager class >> cacheResource: urlString inArchive: archiveName [
	"Remember the given url as residing in the given archive"
	| fd file fullName |
	fullName := 'zip://', archiveName.
	((self resourceCache at: urlString ifAbsent:[#()]) 
		anySatisfy:[:cache| cache = fullName]) ifTrue:[^self]. "don't cache twice"
	fd := Project squeakletDirectory.
	"update cache"
	file := [fd oldFileNamed: self resourceCacheName] 
			on: FileDoesNotExistException
			do:[:ex| fd forceNewFileNamed: self resourceCacheName].
	file setToEnd.
	file nextPutAll: urlString; cr.
	file nextPutAll: fullName; cr.
	file close.
	self addCacheLocation: fullName for: urlString.
]

{ #category : #'resource caching' }
ResourceManager class >> cacheResource: urlString stream: aStream [
	| fd localName file buf |
	
	(self resourceCache at: urlString ifAbsent:[#()]) size > 0 
		ifTrue:[^self]. "don't waste space"
	fd := Project squeakletDirectory.
	localName := fd nextNameFor: 'resource' extension:'cache'.
	file := fd forceNewFileNamed: localName.
	buf := ByteArray new: 10000.
	aStream binary.
	file binary.
	[aStream atEnd] whileFalse:[
		buf := aStream next: buf size into: buf.
		file nextPutAll: buf.
	].
	file close.
	"update cache"
	file := [fd oldFileNamed: self resourceCacheName] 
			on: FileDoesNotExistException
			do:[:ex| fd forceNewFileNamed: self resourceCacheName].
	file setToEnd.
	file nextPutAll: urlString; cr.
	file nextPutAll: localName; cr.
	file close.
	self addCacheLocation: localName for: urlString.
	aStream position: 0.

]

{ #category : #'private-resources' }
ResourceManager class >> loadResource: urlString fromCacheFileNamed: fileName in: dir [
	| archiveName file archive |
	(fileName beginsWith: 'zip://') ifTrue:[
		archiveName := fileName copyFrom: 7 to: fileName size.
		archive := [dir readOnlyFileNamed: archiveName] 
			on: FileDoesNotExistException
			do:[:ex| ex return: nil].
		archive ifNil:[^nil].
		archive isZipArchive ifTrue:[
			archive := ZipArchive new readFrom: archive.
			file := archive members detect:[:any| any fileName = urlString] ifNone:[nil]].
		file ifNotNil:[file := file contentStream].
		archive close.
	] ifFalse:[
		file := [dir readOnlyFileNamed: fileName] 
				on: FileDoesNotExistException
				do:[:ex| ex return: nil].
	].
	^file
]

{ #category : #'private-resources' }
ResourceManager class >> localizedExternalResources [
	^LocalizedExternalResources ifNil:[LocalizedExternalResources := Dictionary new]
]

{ #category : #'resource caching' }
ResourceManager class >> lookupCachedResource: cachedUrlString ifPresentDo: streamBlock [
	"See if we have cached the resource described by the given url and if so, evaluate streamBlock with the cached resource."
	|  urlString candidates url stream |
	CachedResources ifNil:[^self].

	candidates := CachedResources at: cachedUrlString ifAbsent:[nil].
	(self lookupCachedResource: cachedUrlString in: candidates ifPresentDo: streamBlock)
		ifTrue: [^self].

	urlString := self relocatedExternalResource: cachedUrlString.
	urlString ifNil: [^self].
	candidates := CachedResources at: urlString ifAbsent:[nil].
	candidates
		ifNil: [
			(url := urlString asUrl) schemeName = 'file'
				ifTrue: [
					stream := [FileStream readOnlyFileNamed: url pathForFile] 
							on: FileDoesNotExistException do:[:ex| ex return: nil].
					stream
						ifNotNil: [[streamBlock value: stream] ensure: [stream close]]]]
		ifNotNil: [self lookupCachedResource: urlString in: candidates ifPresentDo: streamBlock]
]

{ #category : #'resource caching' }
ResourceManager class >> lookupCachedResource: urlString in: candidates ifPresentDo: streamBlock [
	"See if we have cached the resource described by the given url and if so, evaluate streamBlock with the cached resource."
	| sortedCandidates dir |
	(candidates isNil or:[candidates size = 0])
		ifTrue:[^false].
	"First, try non-zip members (faster since no decompression is involved)"
	sortedCandidates := (candidates reject:[:each| each beginsWith: 'zip://']),
					(candidates select:[:each| each beginsWith: 'zip://']).
	dir := Project squeakletDirectory.
	sortedCandidates do:[:fileName|
		| file |
		file := self loadResource: urlString fromCacheFileNamed: fileName in: dir.
		file ifNotNil:[
			[streamBlock value: file] ensure:[file close].
			^true]].
	^false
]

{ #category : #'resource caching' }
ResourceManager class >> lookupOriginalResourceCacheEntry: resourceFileName for: resourceUrl [
	"See if we have cached the resource described by the given url in an earlier version of the same project on the same server. In that case we don't need to upload it again but rather link to it."
	| resourceBase resourceMatch matchingUrls |
	
	CachedResources ifNil:[^nil].

	"Strip the version number from the resource url"
	resourceBase := resourceUrl copyFrom: 1 to: (resourceUrl lastIndexOf: $.) .
	"Now collect all urls that have the same resource base"
	resourceMatch := resourceBase , '*/' , resourceFileName.
	matchingUrls := self resourceCache keys
		select: [:entry | (resourceMatch match: entry) and: [(entry beginsWith: resourceUrl) not]].
	matchingUrls isEmpty
		ifTrue: [^nil].
	matchingUrls asArray sort do: [:entry | | candidates |
			candidates := (self resourceCache at: entry).
			candidates isEmptyOrNil
				ifFalse: [candidates do: [:candidate |
					candidate = resourceFileName
						ifTrue: [^entry]]]].
	^nil
]

{ #category : #'resource caching' }
ResourceManager class >> reloadCachedResources [	"ResourceManager reloadCachedResources"
	"Reload cached resources from the disk"
	| fd files stream url localName storeBack archiveName |
	CachedResources := Dictionary new.
	LocalizedExternalResources := nil.
	fd := Project squeakletDirectory.
	files := fd fileNames asSet.
	stream := [fd readOnlyFileNamed: self resourceCacheName]
				on: FileDoesNotExistException 
				do:[:ex| fd forceNewFileNamed: self resourceCacheName].
	stream size < 50000 ifTrue:[stream := ReadStream on: stream contentsOfEntireFile].
	storeBack := false.
	[stream atEnd] whileFalse:[
		url := stream nextLine.	
		localName := stream nextLine.
		(localName beginsWith: 'zip://') ifTrue:[
			archiveName := localName copyFrom: 7 to: localName size.
			(files includes: archiveName) 
				ifTrue:[self addCacheLocation: localName for: url]
				ifFalse:[storeBack := true].
		] ifFalse:[
			(files includes: localName) 
				ifTrue:[self addCacheLocation: localName for: url]
				ifFalse:[storeBack := true]
		].
	].
	stream close.
	storeBack ifTrue:[
		stream := fd forceNewFileNamed: self resourceCacheName.
		CachedResources keysAndValuesDo:[:urlString :cacheLocs|
			cacheLocs do:[:cacheLoc|
				stream nextPutAll: urlString; cr.
				stream nextPutAll: cacheLoc; cr].
		].
		stream close.
	].
]

{ #category : #'private-resources' }
ResourceManager class >> relocatedExternalResource: urlString [
	^self localizedExternalResources at: urlString ifAbsent: [nil]
]

{ #category : #'private-resources' }
ResourceManager class >> relocatedExternalResource: urlString to: newUrlString [
	| originalURL |
	originalURL := (self localizedExternalResources includesKey: urlString)
		ifTrue: [self localizedExternalResources at: urlString]
		ifFalse: [urlString].
	self localizedExternalResources at: newUrlString put: originalURL
]

{ #category : #'resource caching' }
ResourceManager class >> renameCachedResource: urlString to: newUrlString [
	"A project was renamed. Reflect this change by duplicating the cache entry to the new url."
	self renameCachedResource: urlString to: newUrlString external: true
]

{ #category : #'resource caching' }
ResourceManager class >> renameCachedResource: urlString to: newUrlString external: isExternal [
	"A project was renamed. Reflect this change by duplicating the cache entry to the new url."
	| candidates |
	CachedResources
		ifNil:[
			isExternal
				ifTrue: [self resourceCache "force init" ]
				ifFalse: [^self]].
	candidates := CachedResources at: urlString ifAbsent:[nil].
	(candidates isNil or:[candidates size = 0])
		ifFalse: [
		candidates do: [:candidate |
			self addCacheLocation: candidate for: newUrlString]].
	isExternal
		ifTrue: [self relocatedExternalResource: urlString to: newUrlString]
]

{ #category : #'resource caching' }
ResourceManager class >> resourceCache [
	^CachedResources ifNil:[
		CachedResources := Dictionary new.
		self reloadCachedResources.
		CachedResources].
]

{ #category : #'resource caching' }
ResourceManager class >> resourceCacheName [
	^'resourceCache.map'
]

{ #category : #private }
ResourceManager >> abandonResourcesThat: matchBlock [
	"Private. Forget resources that match the given argument block"
	resourceMap keys "need copy" do:[:loc|
		(matchBlock value: loc) ifTrue:[
			resourceMap removeKey: loc ifAbsent:[].
			loaded remove: loc ifAbsent:[].
			unloaded remove: loc ifAbsent:[].
		].
	].
]

{ #category : #accessing }
ResourceManager >> addResource: anObject locator: aLocator [
	resourceMap at: aLocator put: anObject.
	loaded add: aLocator.
]

{ #category : #accessing }
ResourceManager >> addResource: anObject url: urlString [
	^self addResource: anObject locator: (ResourceLocator new urlString: urlString)
]

{ #category : #accessing }
ResourceManager >> adjustToDownloadUrl: downloadUrl [
	"Adjust the resource manager to the current download location. A project might have been moved manually to a different location or server."

	downloadUrl isEmptyOrNil ifTrue: [^self].

	self resourceMap
		keysDo:[:locator | locator adjustToDownloadUrl: downloadUrl].
	self resourceMap rehash.
	unloaded rehash
]

{ #category : #accessing }
ResourceManager >> adjustToNewServer: newResourceUrl from: oldResourceUrl [
	"Adjust the resource manager to the current download location. A project might have been moved manually to a different location or server."
	| urlMap |
	newResourceUrl isEmptyOrNil ifTrue: [^self].
	urlMap := Dictionary new.
	self resourceMap
		keysDo: [:locator | 
			"Local file refs are not handled well, so work around here"
			| oldUrl newUrl |
			oldUrl := ResourceLocator make: locator urlString relativeTo: oldResourceUrl.
			newUrl := ResourceLocator make: locator urlString relativeTo: newResourceUrl.
			oldUrl ~= newUrl
				ifTrue: [urlMap at: oldUrl asString unescapePercents put: newUrl asString unescapePercents]].
	self resourceMap rehash.
	unloaded rehash.
	urlMap keysAndValuesDo: [:old :new |
		ResourceManager renameCachedResource: old to: new]
]

{ #category : #accessing }
ResourceManager >> adjustToRename: newName from: oldName [
	"Adjust the resource manager to the current download location. A project might have been moved manually to a different location or server."
	| urlMap |
	newName isEmptyOrNil ifTrue: [^self].
	urlMap := Dictionary new.
	self resourceMap
		keysDo: [:locator | 
			| oldUrl |
			oldUrl := locator urlString.
			locator adjustToRename: newName from: oldName.
			urlMap at: oldUrl put: locator urlString].
	self resourceMap rehash.
	unloaded rehash.
	urlMap keysAndValuesDo: [:old :new |
		ResourceManager renameCachedResource: old to: new]
]

{ #category : #'backward-compatibility' }
ResourceManager >> convertMapNameForBackwardcompatibilityFrom: aString [ 
	(Smalltalk platformName = 'Mac OS' 
		and: ['10*' match: Smalltalk osVersion]) 
			ifTrue: [^aString convertFromWithConverter: ShiftJISTextConverter new].
	^aString convertFromSystemString
]

{ #category : #private }
ResourceManager >> fixJISX0208Resource [
	resourceMap keys do: [:key |
		| value url |
		value := resourceMap at: key.
		url := key urlString copy.
		url isOctetString not ifTrue: [url mutateJISX0208StringToUnicode].
		resourceMap removeKey: key.
		key urlString: url.
		resourceMap at: key put: value.
	].

]

{ #category : #private }
ResourceManager >> formChangedReminder [
	^[Project current world newResourceLoaded].
]

{ #category : #private }
ResourceManager >> hackURL: urlString [
	(urlString findString: '/SuperSwikiProj/') > 0 
		ifTrue:[^urlString copyReplaceAll: '/SuperSwikiProj/' with: '/uploads/']
		ifFalse:[^urlString]
]

{ #category : #initialize }
ResourceManager >> initialize [
	"So resources may get garbage collected if possible"
	self reset.
]

{ #category : #initialize }
ResourceManager >> initializeFrom: aCollector [
	"Initialize the receiver from the given resource collector. None of the resources have been loaded yet, so make register all resources as unloaded."
	aCollector stubMap keysAndValuesDo:[:stub :res|
		| newLoc |
		newLoc := stub locator.
		resourceMap at: newLoc put: res.
		"unloaded add: newLoc."
	].
]

{ #category : #loading }
ResourceManager >> installResource: aResource from: aStream locator: loc [
	| repl |
	aResource ifNil:[^false]. "it went away, so somebody might have deleted it"
	(aStream == nil or:[aStream size = 0]) ifTrue:[^false]. "error?!"
	repl := aResource shallowCopy readResourceFrom: aStream asUnZippedStream.
	repl ifNotNil:[
		aResource replaceByResource: repl.
		unloaded remove: loc.
		loaded add: loc.
		^true
	].
	^false
]

{ #category : #loading }
ResourceManager >> loadCachedResources [
	"Load all the resources that we have cached locally"
	self class reloadCachedResources.
	self prioritizedUnloadedResources do:[:loc|
		self class lookupCachedResource: loc urlString ifPresentDo:[:stream|
			| resource |
			resource := resourceMap at: loc ifAbsent:[nil].
			self installResource: resource
				from: stream
				locator: loc.
			(resource isForm) ifTrue:[
				self formChangedReminder value.
				Project current world displayWorldSafely].
		].
	].
]

{ #category : #loading }
ResourceManager >> loaderProcess [
	| loader requests |
	loader := HTTPLoader default.
	requests := Dictionary new.
	self prioritizedUnloadedResources do:[:loc|
		| req |
		req := HTTPLoader httpRequestClass for: (self hackURL: loc urlString) in: loader.
		loader addRequest: req.
		requests at: req put: loc].
	[stopFlag or:[requests isEmpty]] whileFalse:[
		stopSemaphore waitTimeoutMSecs: 500.
		requests keys "need a copy" do:[:r|
			r isSemaphoreSignaled ifTrue:[
				| locator resource stream |
				locator := requests at: r.
				requests removeKey: r.
				stream := r contentStream.
				resource := resourceMap at: locator ifAbsent:[nil].
				self class cacheResource: locator urlString stream: stream.
				self installResource: resource
					from: stream
					locator: locator.
				(resource isForm) ifTrue:[
					WorldState addDeferredUIMessage: self formChangedReminder]
ifFalse: [self halt].
			].
		].
	].
	"Either done downloading or terminating process"
	stopFlag ifTrue:[loader abort].
	loaderProcess := nil.
	stopSemaphore := nil.
]

{ #category : #private }
ResourceManager >> localizeAllExternalResources [
	"Should be a preference later."
	^true
]

{ #category : #accessing }
ResourceManager >> makeAllProjectResourcesLocalTo: resourceUrl [
	"Change the urls in the resource locators so project specific resources are stored and referenced locally. Project specific resources are all those that are kept locally in any of the project's versions."

	| locators projectBase |
 	"Construct the version neutral project base"
	resourceUrl isEmptyOrNil ifTrue: [^self].
	projectBase := resourceUrl copyFrom: 1 to: (resourceUrl lastIndexOf: $.) - 1.
	locators := OrderedCollection new.
	self resourceMap
		keysAndValuesDo:[:loc :res | res ifNotNil: [locators add: loc]].
	locators do: [:locator |
		| locUrl |
		locUrl := locator urlString.
		locUrl ifNotNil: [
			| lastSlash |
			lastSlash := locUrl lastIndexOf: $/.
			lastSlash > 0
				ifTrue: [
					| locBase localResource isExternal |
					locBase := locUrl copyFrom: 1 to: lastSlash - 1.
					locBase := locBase copyFrom: 1 to: (((locBase lastIndexOf: $.) - 1) max: 0).
					isExternal := projectBase ~= locBase.
					(isExternal not
						or: [self localizeAllExternalResources])
						ifTrue: [
							localResource := locUrl copyFrom: lastSlash+1 to: locUrl size.
							"Update the cache entry to point to the new resource location"
							ResourceManager renameCachedResource: locUrl to: (resourceUrl , localResource) external: isExternal.
							locator urlString: localResource]]]].
	self resourceMap rehash

]

{ #category : #loading }
ResourceManager >> preLoadFromArchive: aZipArchive cacheName: aFileName [
	"Load the resources from the given zip archive"
	| nameMap resMap |
	self class reloadCachedResources.
	resMap := Dictionary new.
	nameMap := Dictionary new.
	unloaded do:[:locator|
		locator localFileName: nil.
		nameMap at: locator urlString put: locator.
		resMap at: locator urlString put: (resourceMap at: locator)].

	aZipArchive members do:[:entry|
		| stream orig loc |
		stream := nil.
		orig := resMap at: (self convertMapNameForBackwardcompatibilityFrom: entry fileName ) ifAbsent:[nil].
		loc := nameMap at: (self convertMapNameForBackwardcompatibilityFrom: entry fileName ) ifAbsent:[nil].
		"note: orig and loc may be nil for non-resource members"
		(orig notNil and:[loc notNil]) ifTrue:[
			stream := entry contentStream.
			self installResource: orig from: stream locator: loc.
			stream reset.
			aFileName 
				ifNil:[self class cacheResource: loc urlString stream: stream]
				ifNotNil:[self class cacheResource: loc urlString inArchive: aFileName]].
	].
]

{ #category : #loading }
ResourceManager >> prioritizedUnloadedResources [
	"Return an array of unloaded resource locators prioritized by some means"
	| list |
	list := unloaded asArray.
	^list sort:[:l1 :l2|
		(l1 resourceFileSize ifNil:[SmallInteger maxVal]) <=
			(l2 resourceFileSize ifNil:[SmallInteger maxVal])]
]

{ #category : #loading }
ResourceManager >> registerUnloadedResources [
	resourceMap keys do: [:newLoc |
		unloaded add: newLoc]

]

{ #category : #initialize }
ResourceManager >> reset [
	"Clean out everything"
	resourceMap := WeakValueDictionary new.
	loaded := Set new.
	unloaded := Set new.
]

{ #category : #accessing }
ResourceManager >> resourceMap [
	^resourceMap
]

{ #category : #loading }
ResourceManager >> startDownload [
	"Start downloading unloaded resources"
	self stopDownload.
	unloaded isEmpty ifTrue:[^self].
	self loadCachedResources.
	unloaded isEmpty ifTrue:[^self].
	stopFlag := false.
	stopSemaphore := Semaphore new.
	loaderProcess := [self loaderProcess] newProcess.
	loaderProcess priority: Processor lowIOPriority.
	loaderProcess resume.
]

{ #category : #loading }
ResourceManager >> stopDownload [
	"Stop downloading unloaded resources"
	loaderProcess ifNil:[^self].
	stopFlag := true.
	stopSemaphore signal.
	[loaderProcess == nil] whileFalse:[(Delay forMilliseconds: 10) wait].
	stopSemaphore := nil.
]

{ #category : #loading }
ResourceManager >> updateResourcesFrom: aCollector [
	"We just assembled all the resources in a project.
	Include all that were newly found"
	self reset. "start clean"
	aCollector stubMap keysAndValuesDo:[:stub :res|
		"update all entries"
		resourceMap at: stub locator put: res.
		loaded add: stub locator.
	].
]
