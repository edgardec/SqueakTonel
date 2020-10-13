"
I'm a tonel monticello repository
"
Class {
	#name : #TonelRepository,
	#superclass : #MCDirectoryRepository,
	#category : #'MonticelloTonel-Core'
}

{ #category : #'instance creation' }
TonelRepository class >> basicFromUrl: anUrl [
	"remove 'tonel://' and go"
	^ self new directory: (anUrl asString allButFirst: self description size) asFileReference
]

{ #category : #'metacello support' }
TonelRepository class >> createRepositoryFromSpec: aRepositorySpec on: aPlatform [
	^ aPlatform createTonelRepository: aRepositorySpec
]

{ #category : #accessing }
TonelRepository class >> description [
    ^ 'tonel://'
]

{ #category : #files }
TonelRepository class >> directoryNameFromFileName: aString [
	"Answer the name of the directory represented by the 'file name'."
	| suffix |
	suffix := TonelReader generatedVersionSuffix.
	(aString endsWith: suffix) ifFalse: [^ aString].
	^ aString allButLast: suffix size
]

{ #category : #files }
TonelRepository class >> fileNameFromDirectory: aDirectoryReference [
	"Answer the 'file name' for the directory which contains a package."
	^ aDirectoryReference basename, TonelReader generatedVersionSuffix
]

{ #category : #'metacello support' }
TonelRepository class >> isAvailableFor: type [
	^ type = 'tonel'
]

{ #category : #'metacello support' }
TonelRepository class >> isFiletreeAlternateFormat: aRepositorySpec [
	| location propRef |
	
	location := (aRepositorySpec description allButFirst: ('filetree://' size)) asFileReference.
	propRef := location / '.properties'.
	propRef exists ifFalse: [ ^ false ].
	
	^ propRef readStreamDo:[ :stream | 
		((STONJSON fromStream: stream) at: #format ifAbsent: []) = #tonel ]
]

{ #category : #accessing }
TonelRepository class >> urlSchemes [
	^ #(tonel)
]

{ #category : #accessing }
TonelRepository >> allFileNames [

	^directory entries 
		sort: [ :a :b | a name >= b name ];
		replace: [ :ea | (self fileNameFromDirectory: ea asReference) asMCVersionName ]
]

{ #category : #accessing }
TonelRepository >> allFileNamesForVersionNamed: aString [
	^ self 
		filterFileNames: self readableFileNames 
		forVersionNamed: aString
]

{ #category : #accessing }
TonelRepository >> asRepositorySpecFor: aMetacelloMCProject [
    ^ aMetacelloMCProject repositorySpec
        description: self description;
        type: 'tonel';
        yourself
]

{ #category : #accessing }
TonelRepository >> basicStoreVersion: aVersion [
  TonelWriter 
	fileOut: aVersion 
	on: self directory
]

{ #category : #'private-files' }
TonelRepository >> canReadFileNamed: aString [
    ^ (self directoryFromFileName: aString) isDirectory
]

{ #category : #'user interface' }
TonelRepository >> description [
	^ directory fullName
]

{ #category : #accessing }
TonelRepository >> directory: aDirectory [
	directory := aDirectory asFSReference
]

{ #category : #'private-files' }
TonelRepository >> directoryFromFileName: aString [
	"Answer the reference to the directory represented by the 'file name'."
	^ self fileUtils
		directoryFromPath: (self class directoryNameFromFileName: aString)
		relativeTo: self directory
]

{ #category : #accessing }
TonelRepository >> fileDirectoryOn: directoryPath [
	^ self fileUtils 
		directoryFromPath: directoryPath 
		relativeTo: self directory
]

{ #category : #'private-files' }
TonelRepository >> fileNameFromDirectory: aDirectoryReference [
	"Answer the 'file name' for the directory which contains a package."
	^ self class fileNameFromDirectory: aDirectoryReference
]

{ #category : #accessing }
TonelRepository >> fileUtils [
	^ TonelFileUtils current
]

{ #category : #accessing }
TonelRepository >> filterFileNames: aCollection forVersionNamed: aString [
	^ aCollection select: [:ea | (self versionNameFromFileName: ea) = aString]
]

{ #category : #'metacello support' }
TonelRepository >> goferVersionFrom: aVersionReference [
	"Simillar hack than FileTree repositories."

	(self readableFileNames collect: [ :fileName | self fileDirectoryOn: fileName ])
		do: [ :packageDirectory |
			((self fileUtils directoryExists: packageDirectory )
			and: [(self versionInfoForPackageDirectory: packageDirectory) name = aVersionReference name])
				ifTrue: [ ^ self loadVersionFromFileNamed: (self fileUtils directoryName: packageDirectory) ] ].
	^nil
]

{ #category : #accessing }
TonelRepository >> loadAllFileNames [
	^ super loadAllFileNames 
		select: [ :each | 
			self fileUtils 
				filePathExists: each, '/package.st' 
				relativeTo: self directory ]
]

{ #category : #accessing }
TonelRepository >> packageDescriptionFromPackageDirectory: packageDirectory [
    | filename |
    filename := self fileUtils directoryName: packageDirectory.
    ^ {filename. 'tonel'. 1. filename}
]

{ #category : #accessing }
TonelRepository >> packageDescriptionsFromReadableFileNames [
    ^ ((self readableFileNames 
		collect: [ :each | self fileUtils directoryFromPath: each relativeTo: self directory ])
		select: [ :each | self fileUtils directoryExists: each ])
		collect: [ :each | self packageDescriptionFromPackageDirectory: each ]
]

{ #category : #actions }
TonelRepository >> readStreamForFileNamed: aString do: aBlock [
    ^ aBlock value: self directory
]

{ #category : #accessing }
TonelRepository >> readableFileNames [
	| all cached new |

	all := self allFileNames. "in disk"
	all := all reject: [ :each | each beginsWith: '.' ].
	cached := self cachedFileNames. "in memory"
	new := all difference: cached.
	^ (cached asArray, new) select: [:ea | self canReadFileNamed: ea]
]

{ #category : #accessing }
TonelRepository >> readableFileReferences [
	^ self readableFileNames collect: [ :each | self directoryFromFileName: each ]
]

{ #category : #accessing }
TonelRepository >> versionFrom: aVersionReferenceString [
    "until we no longer find .tree directories in the wild"

   	^ self readableFileReferences
		detect: [ :each | 
			(self fileUtils directoryExists: each)
			and: [ 
				each basename = aVersionReferenceString 
				or: [ (self versionInfoForPackageDirectory: each) name = aVersionReferenceString ] ] ]
		ifFound: [ :packageDirectory | 
			self loadVersionFromFileNamed: (self fileUtils directoryName: packageDirectory) ]
		ifNone: [ 
			nil ].
]

{ #category : #accessing }
TonelRepository >> versionFromFileNamed: aString [
	^ self versionFrom: aString
]

{ #category : #versions }
TonelRepository >> versionInfoForPackageDirectory: packageDirectory [
	^ ((MCReader readerClassForFileNamed: (self fileUtils directoryName: packageDirectory))
		on: (self fileUtils parentDirectoryOf: packageDirectory)
		fileName: (self fileUtils directoryName: packageDirectory))
		loadVersionInfo;
		info
]

{ #category : #versions }
TonelRepository >> versionInfoFromVersionNamed: aString [
	^ self versionInfoForPackageDirectory: (self fileDirectoryOn: aString)
]

{ #category : #versions }
TonelRepository >> versionNameFromFileName: aString [
	"Currently, the 'file names' are faked to be version names, so the MCFileRepositoryInspector can handle Tonel repositories."
	^ aString
]

{ #category : #versions }
TonelRepository >> versionWithInfo: aVersionInfo ifAbsent: errorBlock [
	(self allFileNamesForVersionNamed: aVersionInfo name)
		ifNotEmpty: [ :aCollection | ^ self versionFromFileNamed: aCollection first ].
	^ errorBlock value
]
