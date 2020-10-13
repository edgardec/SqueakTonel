Class {
	#name : #MCVersionMerger,
	#superclass : #Object,
	#instVars : [
		'records',
		'merger'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #merging }
MCVersionMerger class >> mergeVersion: aVersion [
	self new
		addVersion: aVersion;
		mergeWithNameLike: aVersion info name
]

{ #category : #'instance creation' }
MCVersionMerger class >> new [
	^ self basicNew initialize
]

{ #category : #accessing }
MCVersionMerger >> addVersion: aVersion [
	
	records add: (MCMergeRecord version: aVersion).
	aVersion dependencies do:
		[:ea | | dep |
		dep := ea resolve.
		(records anySatisfy: [:r | r version = dep]) ifFalse: [self addVersion: dep]]
]

{ #category : #'initialize-release' }
MCVersionMerger >> initialize [
	records := OrderedCollection new.
	merger := MCThreeWayMerger new.
]

{ #category : #merging }
MCVersionMerger >> merge [
	records do: [:ea | merger addBaseSnapshot: ea packageSnapshot].
	records do: [:ea | merger applyPatch: ea mergePatch].
	self resolveConflicts ifTrue:
		[merger load.
		records do: [:ea | ea updateWorkingCopy]].
]

{ #category : #merging }
MCVersionMerger >> mergeWithNameLike: baseName [
	records do: [:ea | merger addBaseSnapshot: ea packageSnapshot].
	records do: [:ea | merger applyPatch: ea mergePatch].
	self resolveConflicts ifTrue:
		[merger loadWithNameLike: baseName.
		records do: [:ea | ea updateWorkingCopy]].
]

{ #category : #testing }
MCVersionMerger >> resolveConflicts [
	(records allSatisfy: [:ea | ea isAncestorMerge]) ifTrue: [MCNoChangesException signal. ^ false].
	^ ((MCMergeResolutionRequest new merger: merger)
		signal: 'Merging ', records first version info name) = true
]
