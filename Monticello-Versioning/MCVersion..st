Class {
	#name : #MCVersion,
	#superclass : #Object,
	#instVars : [
		'package',
		'info',
		'snapshot',
		'dependencies'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #'instance creation' }
MCVersion class >> package: aPackage [
	^ self package: aPackage info: MCVersionInfo new
]

{ #category : #'instance creation' }
MCVersion class >> package: aPackage info: aVersionInfo [
	^ self package: aPackage info: aVersionInfo snapshot: aPackage snapshot
]

{ #category : #'instance creation' }
MCVersion class >> package: aPackage info: aVersionInfo snapshot: aSnapshot [
	^ self package: aPackage info: aVersionInfo snapshot: aSnapshot dependencies: #()
]

{ #category : #'instance creation' }
MCVersion class >> package: aPackage info: aVersionInfo snapshot: aSnapshot dependencies: aCollection [
	^ self new initializeWithPackage: aPackage info: aVersionInfo snapshot: aSnapshot dependencies: aCollection
]

{ #category : #actions }
MCVersion >> addToCache [
	MCCacheRepository default storeVersion: self
]

{ #category : #actions }
MCVersion >> adopt [
	self workingCopy adopt: self
]

{ #category : #enumerating }
MCVersion >> allAvailableDependenciesDo: aBlock [
	
	self dependencies do:
		[:ea |
		[ | version |
		version := ea resolve.
		version allAvailableDependenciesDo: aBlock.
		aBlock value: version]
			on: Error do: []]
]

{ #category : #enumerating }
MCVersion >> allDependenciesDo: aBlock [
	self allDependenciesDo: aBlock ifUnresolved: [:ignored | true]
]

{ #category : #enumerating }
MCVersion >> allDependenciesDo: aBlock ifUnresolved: failBlock [
	| dict |
	dict := Dictionary new.
	self allDependenciesNotIn: dict do: aBlock ifUnresolved: failBlock
]

{ #category : #enumerating }
MCVersion >> allDependenciesNotIn: aDictionary do: aBlock ifUnresolved: failBlock [
	
	self dependencies do: 
		[:ea | | version | 
		version := aDictionary at: ea ifAbsent: [ea resolve].
		version 
			ifNil: [failBlock value: ea]
			ifNotNil: [(aDictionary includes: version) ifFalse:
						[aDictionary at: ea put: version.
						version 
							allDependenciesNotIn: aDictionary 
							do: aBlock
							ifUnresolved: failBlock.
						aBlock value: version]]]
]

{ #category : #converting }
MCVersion >> asDiffAgainst: aVersion [
	aVersion info = self info ifTrue: [self error: 'Cannot diff against self!'].
	^ MCDiffyVersion
		package: self package
		info: self info
		snapshot: self snapshot
		dependencies: self dependencies
		baseVersion: aVersion
]

{ #category : #actions }
MCVersion >> browse [
	(MCSnapshotBrowser forSnapshot: self snapshot)
		label: 'Snapshot of ', self fileName;
		show
]

{ #category : #testing }
MCVersion >> canOptimizeLoading [
	"Answer wether I can provide a patch for the working copy without the usual diff pass"
	^false
]

{ #category : #accessing }
MCVersion >> changes [
	^ self snapshot patchRelativeToBase: package snapshot
]

{ #category : #accessing }
MCVersion >> dependencies [
	^ dependencies ifNil: [#()]
]

{ #category : #accessing }
MCVersion >> fileName [
	|rawName cookedName|

	rawName := info name.
	"care for invalid filename characters"
	cookedName := rawName copy 
						replaceAll: $/ with: $_;
						replaceAll: $: with: $_..
	^ (cookedName, '.', self writerClass extension) asMCVersionName
]

{ #category : #actions }
MCVersion >> fileOutOn: aStream [
	self writerClass fileOut: self on: aStream
]

{ #category : #accessing }
MCVersion >> info [
	^ info
]

{ #category : #'initialize-release' }
MCVersion >> initializeWithPackage: aPackage info: aVersionInfo snapshot: aSnapshot dependencies: aCollection [ 
	self
		setPackage: aPackage
		info: aVersionInfo
		snapshot: aSnapshot
		dependencies: aCollection.
	self addToCache
]

{ #category : #testing }
MCVersion >> isCacheable [
	^true
]

{ #category : #testing }
MCVersion >> isDiffy [
	^ false
]

{ #category : #actions }
MCVersion >> load [
	self workingCopy withEnvironmentActiveDo: [MCVersionLoader loadVersion: self]
]

{ #category : #printing }
MCVersion >> logLoadingOn: aStream [
	aStream
		nextPutAll: '========== ', self info name, ' =========='; cr;
		nextPutAll: self info message asString; cr;
		flush.

	package hasWorkingCopy ifFalse: [^self].

	package workingCopy ancestors do: [:each |
		(self info hasAncestor: each)
			ifTrue: [(self info allAncestorsOnPathTo: each)
				do: [:ver | aStream cr; nextPutAll: '>>> ', ver name, ' <<<'; cr;
							nextPutAll: ver message; cr; flush]]]
]

{ #category : #actions }
MCVersion >> merge [
	self workingCopy withEnvironmentActiveDo: [MCVersionMerger mergeVersion: self]
]

{ #category : #actions }
MCVersion >> open [
	(MCVersionInspector new version: self) show
]

{ #category : #accessing }
MCVersion >> package [
	^ package
]

{ #category : #printing }
MCVersion >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self info name.
	aStream nextPut: $).
]

{ #category : #actions }
MCVersion >> reparent [
	"Let aNode be the sole parent of this version"
	self workingCopy reparent: self
]

{ #category : #'initialize-release' }
MCVersion >> setPackage: aPackage info: aVersionInfo snapshot: aSnapshot dependencies: aCollection [
	package := aPackage.
	info := aVersionInfo.
	snapshot := aSnapshot.
	dependencies := aCollection
]

{ #category : #testing }
MCVersion >> shouldMerge [
	"answer true if we have to do a full merge and false if we can simply load instead"
	| pkg wc current |
	(pkg := self package) hasWorkingCopy ifFalse: [^false "no wc -> load"].
	(wc := pkg workingCopy) modified ifTrue: [^true "modified -> merge"].
	wc ancestors isEmpty ifTrue: [^true "no ancestor info -> merge"].
	current := wc ancestors first.
	(self info hasAncestor: current) ifTrue: [^false "direct descendant of wc -> load"].
	"new branch -> merge"
	^true
]

{ #category : #accessing }
MCVersion >> snapshot [
	^ snapshot
]

{ #category : #accessing }
MCVersion >> summary [
	^ String streamContents:
		[:s |
		s nextPutAll: info summaryHeader.
		(dependencies isNil or: [dependencies isEmpty]) ifFalse:
			[s cr; nextPutAll: 'Dependencies: '.
			dependencies
				do: [:ea | s nextPutAll: ea versionInfo name]
				separatedBy: [s nextPutAll: ', ']].
		s cr; cr; nextPutAll: info message]
]

{ #category : #enumerating }
MCVersion >> withAllDependenciesDo: aBlock [
	self allDependenciesDo: aBlock ifUnresolved: [:ignored].
	aBlock value: self
]

{ #category : #enumerating }
MCVersion >> withAllDependenciesDo: aBlock ifUnresolved: failBlock [
	| dict |
	dict := Dictionary new.
	self allDependenciesNotIn: dict do: aBlock ifUnresolved: failBlock.
	aBlock value: self
]

{ #category : #accessing }
MCVersion >> workingCopy [
	^ package workingCopy
]

{ #category : #accessing }
MCVersion >> writerClass [
	^ MCMczWriter 
]
