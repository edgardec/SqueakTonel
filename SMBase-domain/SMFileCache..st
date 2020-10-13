"
A repository for SMSqueakMap downloads. This behaves like a Set, responding to add: and include:, but also package contents may be forcibly refreshed with download:.

The SqueakMap determines what path the cache resides at. Within the cache, there is a 'packages' directory containing UUID-based directories for each package containing further directories for each release. A 'resources' directory stores UUID-based directories for each Resource, with the file stored within that by its original name. Because the cache follows a Set protocol, it can be automatically traversed within Smalltalk's collection protocol, avoiding manual hassles.
"
Class {
	#name : #SMFileCache,
	#superclass : #Object,
	#instVars : [
		'map'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMFileCache class >> newFor: aMap [
	"This is the default creation method, responsible for ensuring the
	paths and such exist, and filling in defaults."

	^self new forMap: aMap

]

{ #category : #services }
SMFileCache >> add: aDownloadable [ 
	"Conditionally download the downloadable object into the cache.
	Return true on success, otherwise false."
	aDownloadable downloadFileName isEmptyOrNil ifTrue: [ ^ false ].
	^(self includes: aDownloadable)
		ifTrue: [true]
		ifFalse: [self download: aDownloadable]
]

{ #category : #private }
SMFileCache >> cacheUrlFor: aDownloadable [
	"Find a cache URL for this downloadable.
	Returns nil if no server is available.
	Could use #relativeUrl also."

	| server |
	server := aDownloadable map class findServer.
	server ifNil: [^ nil].
	^'http://', server, '/object/', aDownloadable id asString, '/cache'
]

{ #category : #services }
SMFileCache >> contents: anSMObject [
	"Return contents of the file for the object
	or nil if not in cache."

	anSMObject isCached
		ifTrue: [^(anSMObject cacheDirectory readOnlyFileNamed: anSMObject downloadFileName) binary; contentsOfEntireFile]
		ifFalse: [^nil]
		
]

{ #category : #accessing }
SMFileCache >> directory [
	^map packageCacheDirectory
]

{ #category : #accessing }
SMFileCache >> directoryForPackage: aPackage [
	"Returns the local path for storing the package cache's package file area.
	This also ensures that the path exists."

	| slash path dir |
	slash := FileDirectory slash.
	path := 'packages' , slash , aPackage id asString36 , slash.
	dir := FileDirectory default on: self directory fullName, slash, path.
	dir assureExistence.
	^dir
]

{ #category : #accessing }
SMFileCache >> directoryForPackageRelease: aPackageRelease [
	"Returns the local path for storing the package cache's version of a  
	package file. This also ensures that the path exists."

	| slash path dir |
	slash := FileDirectory slash.
	path := 'packages' , slash , aPackageRelease package id asString36 , slash , aPackageRelease automaticVersionString.
	dir := FileDirectory default on: self directory fullName, slash, path.
	dir assureExistence.
	^dir
]

{ #category : #accessing }
SMFileCache >> directoryForResource: aResource [
	"Returns the local path for storing the package cache's version of a  
	resource file. This also ensures that the path exists."

	| slash path dir |
	slash := FileDirectory slash.
	path := 'resources' , slash , aResource id asString36.
	dir := FileDirectory default on: self directory fullName, slash, path.
	dir assureExistence.
	^dir
]

{ #category : #services }
SMFileCache >> download: aDownloadable [ 
	"Download the file for this SMObject into the local file cache.
	If the file already exists, delete it.
	No unpacking or installation into the running image."

	| stream file fileName dir |
	[fileName := aDownloadable downloadFileName.
	fileName
		ifNil: [self inform: 'No download url, can not download.'.
			^ false].
	fileName isEmpty
		ifTrue: [self inform: 'Download url lacks filename, can not download.'.
			^ false].
	dir := aDownloadable cacheDirectory.
	[stream := self getStream: aDownloadable.
	stream ifNil: [^ false].
	(dir fileExists: fileName)
		ifTrue: [dir deleteFileNamed: fileName].
	file := dir newFileNamed: fileName.
	file binary; nextPutAll: stream contents]
		ensure: [file ifNotNil: [file close]]]
		on: Error
		do: [^ false].
	^ true
]

{ #category : #initialize }
SMFileCache >> forMap: aMap [
	"Initialize the ache, make sure the cache dir exists."

	map := aMap
]

{ #category : #private }
SMFileCache >> getStream: aDownloadable [ 
	"Get the stream, either from the original url
	or if that fails, from the server cache - unless
	this is the actual server of course. :)
	We also verify that the sha1sum is correct."

	| stream |
	[stream := aDownloadable downloadUrl asUrl retrieveContents contentStream binary.
	(aDownloadable correctSha1sum: stream contents)
		ifFalse: [self error: 'Incorrect SHA checksum of file from original URL']]
		on: Error do: [:ex |
			Transcript show: 'Download from original url (', aDownloadable downloadUrl, ') failed with this exception: ', ex messageText;cr.
			SMUtilities isServer
				ifTrue: [^nil]
				ifFalse: [
					Transcript show: 'Trying server cache instead.'; cr.
					[stream := (self cacheUrlFor: aDownloadable) asUrl retrieveContents contentStream binary.
					(stream contents size = 21 and: [stream contents asString = 'SMFILEMISSINGONSERVER'])
						ifTrue: [self error: 'File missing in server cache'].
					(stream contents size = 24 and: [stream contents asString = 'SMRELEASENOTDOWNLOADABLE'])
						ifTrue: [self error: 'Release not downloadable'].
					(aDownloadable correctSha1sum: stream contents)
						ifFalse: [self error: 'Incorrect SHA checksum of file from server']]
							on: Error do: [:ex2 | | msg |
								msg := 'Download from server cache of ', aDownloadable printName, ' failed with this exception: ', ex2 messageText.
								Transcript show: msg; cr.
								self error: msg]]].
	^ stream
]

{ #category : #services }
SMFileCache >> includes: anSMObject [ 
	"Check if the cache holds the file for the object."
	^ anSMObject downloadFileName notNil and: [ anSMObject cacheDirectory fileExists: anSMObject downloadFileName ]
]

{ #category : #accessing }
SMFileCache >> map [
	^ map
]

{ #category : #services }
SMFileCache >> remove: aDownloadable [ 
	"Remove aDownloadable from the cache, if it exists."
	(self includes: aDownloadable) ifTrue:
		[ aDownloadable cacheDirectory deleteFileNamed: aDownloadable downloadFileName ]
]
