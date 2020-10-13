Class {
	#name : #MCVersionReader,
	#superclass : #MCReader,
	#instVars : [
		'package',
		'info',
		'definitions',
		'dependencies',
		'stepChildren'
	],
	#category : #'Monticello-Storing'
}

{ #category : #reading }
MCVersionReader class >> file: fileName streamDo: aBlock [

	^FileStream readOnlyFileNamed: fileName do: aBlock
]

{ #category : #'file services' }
MCVersionReader class >> fileReaderServicesForFile: fullName suffix: suffix [
	self isAbstract ifTrue: [^ Array empty].
	^ ((suffix = self extension) or: [ suffix = '*' ])
		ifTrue: [self services]
		ifFalse: [Array empty]
		
]

{ #category : #'file services' }
MCVersionReader class >> initialize [
	"MCVersionReader initialize"
	Smalltalk 
		at: #MczInstaller
		ifPresent: [:installer | FileServices unregisterFileReader: installer].
	self concreteSubclassesDo: [:aClass | FileServices registerFileReader: aClass].

	"get rid of AnObsoleteMCMcReader and AnObsoleteMCMcvReader"
	(FileServices registeredFileReaderClasses  select: [ :ea | ea isObsolete ]) do: 
		[ :ea | FileServices unregisterFileReader: ea ]

]

{ #category : #'file services' }
MCVersionReader class >> loadVersionFile: fileName [ 
	| version |
	version := self versionFromFile: fileName.
	version workingCopy repositoryGroup addRepository: (MCDirectoryRepository path: (FileDirectory dirPathFor: fileName)).
	version load
]

{ #category : #'file services' }
MCVersionReader class >> mergeVersionFile: fileName [
	(self versionFromFile: fileName) merge
]

{ #category : #reading }
MCVersionReader class >> on: s fileName: f [
	^ self on: s
]

{ #category : #'file services' }
MCVersionReader class >> openVersionFile: fileName [
	(self versionFromFile: fileName) open
]

{ #category : #'file services' }
MCVersionReader class >> services [
	^{ 
		self serviceLoadVersion.
		self serviceMergeVersion.
		self serviceOpenVersion }
]

{ #category : #'file services' }
MCVersionReader class >> unload [
	FileServices unregisterFileReader: self 
]

{ #category : #reading }
MCVersionReader class >> versionFromFile: fileName [
	^ self file: fileName streamDo: [:stream | self versionFromStream: stream]
]

{ #category : #reading }
MCVersionReader class >> versionFromStream: aStream [
	^ (self on: aStream) version
]

{ #category : #reading }
MCVersionReader class >> versionInfoFromStream: aStream [
	^ (self on: aStream) info
]

{ #category : #accessing }
MCVersionReader >> basicVersion [
	^ MCVersion
		package: self package
		info: self info
		snapshot: self snapshot
		dependencies: self dependencies
]

{ #category : #accessing }
MCVersionReader >> definitions [
	definitions ifNil: [self loadDefinitions].
	^ definitions
]

{ #category : #accessing }
MCVersionReader >> dependencies [
	dependencies ifNil: [self loadDependencies].
	^ dependencies
]

{ #category : #accessing }
MCVersionReader >> info [
	info ifNil: [self loadVersionInfo].
	^ info
]

{ #category : #lifecycle }
MCVersionReader >> initialize [
]

{ #category : #loading }
MCVersionReader >> loadDefinitions [
	self subclassResponsibility 
]

{ #category : #loading }
MCVersionReader >> loadDependencies [
	self subclassResponsibility 
]

{ #category : #loading }
MCVersionReader >> loadPackage [
	self subclassResponsibility 
]

{ #category : #loading }
MCVersionReader >> loadVersionInfo [
	self subclassResponsibility
]

{ #category : #accessing }
MCVersionReader >> package [
	package ifNil: [self loadPackage].
	^ package
]

{ #category : #accessing }
MCVersionReader >> snapshot [
	^ MCSnapshot fromDefinitions: self definitions
]

{ #category : #accessing }
MCVersionReader >> version [
	^ self basicVersion
]
