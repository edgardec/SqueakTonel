Class {
	#name : #MCDiffyVersion,
	#superclass : #MCVersion,
	#instVars : [
		'base',
		'patch'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #'name utilities' }
MCDiffyVersion class >> baseNameFrom: diffName [
	| baseId verName |
	baseId := (diffName copyAfter: $() copyUpTo: $).
	baseId ifEmpty: [^baseId].
	(baseId beginsWith: '@')
		ifTrue: [^baseId copyAfter: $@].
	verName := self verNameFrom: diffName.
	^(baseId includes: $.)
		ifTrue: [(verName copyUpToLast: $-), '-', baseId]
		ifFalse: [(verName copyUpToLast: $.), '.', baseId]

]

{ #category : #'name utilities' }
MCDiffyVersion class >> nameForVer: versionName base: baseName [
	| baseId |
	baseId := versionName packageName = baseName packageName
		ifFalse: [ '@' , baseName ] 
		ifTrue: [
			versionName author = baseName author
				ifTrue: [ baseName versionNumber asString ]
				ifFalse: [ baseName author, '.', baseName versionNumber asString ] ].
	^ versionName versionName , '(' , baseId , ')'
]

{ #category : #'instance creation' }
MCDiffyVersion class >> package: aPackage info: aVersionInfo dependencies: aCollection baseInfo: baseVersionInfo patch:
aPatch [
	^ self basicNew initializeWithPackage: aPackage info: aVersionInfo dependencies: aCollection baseInfo: baseVersionInfo patch:
aPatch
]

{ #category : #'instance creation' }
MCDiffyVersion class >> package: aPackage info: aVersionInfo snapshot: aSnapshot dependencies: aCollection baseVersion: aVersion [
	^ self 
		package: aPackage
		info: aVersionInfo
		dependencies: aCollection
		baseInfo: aVersion info
		patch: (aSnapshot patchRelativeToBase: aVersion snapshot)
]

{ #category : #'name utilities' }
MCDiffyVersion class >> verNameFrom: diffName [
	^diffName copyUpTo: $(
]

{ #category : #accessing }
MCDiffyVersion >> baseInfo [
	^ base
]

{ #category : #accessing }
MCDiffyVersion >> baseSnapshot [
	| baseVersion |
	baseVersion := self workingCopy repositoryGroup versionWithInfo: base.
	baseVersion ifNil: [Error signal: 'Missing snapshot: ', self baseInfo name].
	^ baseVersion snapshot
]

{ #category : #testing }
MCDiffyVersion >> canOptimizeLoading [
	"Answer wether I can provide a patch for the working copy without the usual diff pass"
	^ package hasWorkingCopy
		and: [package workingCopy modified not
			and: [package workingCopy ancestors includes: self baseInfo]]
]

{ #category : #accessing }
MCDiffyVersion >> fileName [
	^ ((self class
		nameForVer: info name
		base: base name) , '.' , self writerClass extension) asMCVersionName
]

{ #category : #actions }
MCDiffyVersion >> fileOutOn: aStream [
	"The whole point of diffy versions is to not store the full snapshot, so ensure we don't."
	snapshot:=nil.
	super fileOutOn: aStream
]

{ #category : #'initialize-release' }
MCDiffyVersion >> initializeWithPackage: aPackage info: aVersionInfo dependencies: aCollection baseInfo: baseVersionInfo patch: aPatch [
	patch := aPatch.
	base := baseVersionInfo.
	super initializeWithPackage: aPackage info: aVersionInfo snapshot: nil dependencies: aCollection.

]

{ #category : #testing }
MCDiffyVersion >> isDiffy [
	^ true
]

{ #category : #accessing }
MCDiffyVersion >> patch [
	^ patch
]

{ #category : #accessing }
MCDiffyVersion >> snapshot [
	^ snapshot ifNil: [snapshot := MCPatcher apply: patch to: self baseSnapshot]
]

{ #category : #accessing }
MCDiffyVersion >> summary [
	^ '(Diff against ', self baseInfo name, ')', String cr, super summary
]

{ #category : #accessing }
MCDiffyVersion >> writerClass [
	^ MCMcdWriter 
]
