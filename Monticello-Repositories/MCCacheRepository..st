Class {
	#name : #MCCacheRepository,
	#superclass : #MCDirectoryRepository,
	#instVars : [
		'packageCaches',
		'seenFiles'
	],
	#classInstVars : [
		'default'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #accessing }
MCCacheRepository class >> cacheDirectory [
	^ (FileDirectory default directoryNamed: 'package-cache')
		assureExistence;
		yourself
]

{ #category : #'initialize-release' }
MCCacheRepository class >> cleanUp: aggressive [
	self reset
]

{ #category : #accessing }
MCCacheRepository class >> default [
	(default isNil or: [ default directory exists not ]) ifTrue: [ default := self new directory: self cacheDirectory ].
	^ default
]

{ #category : #accessing }
MCCacheRepository class >> description [
	^ nil
]

{ #category : #'initialize-release' }
MCCacheRepository class >> reset [
	default := nil
]

{ #category : #private }
MCCacheRepository >> basicStoreVersion: aVersion [
	(aVersion isCacheable not or: [self allFileNames includes: aVersion fileName])
		ifFalse: [super basicStoreVersion: aVersion]

]

{ #category : #caching }
MCCacheRepository >> cacheForPackage: aPackage [
	packageCaches ifNil: [packageCaches := Dictionary new].
	^ packageCaches at: aPackage ifAbsentPut: [MCPackageCache new]
]

{ #category : #accessing }
MCCacheRepository >> newFileNames [ 
	^ self allFileNames difference: self seenFileNames
]

{ #category : #private }
MCCacheRepository >> rescan [

	self flag: #todo. "This method seems to be unused --pre"
	self newFileNames do:
		[:ea |
		self versionReaderForFileNamed: ea do:
			[:reader |
			(self cacheForPackage: reader package)
				recordVersionInfo: reader info
				forFileNamed: ea.
			self seenFileNames add: ea]]
		displayingProgress: 'Scanning cache...'
]

{ #category : #accessing }
MCCacheRepository >> seenFileNames [
	^ seenFiles ifNil: [seenFiles := OrderedCollection new]
]

{ #category : #caching }
MCCacheRepository >> versionInfoForFileNamed: aString [
	^ cache at: aString ifAbsentPut: [self versionReaderForFileNamed: aString do: [:r | r info]]
]
