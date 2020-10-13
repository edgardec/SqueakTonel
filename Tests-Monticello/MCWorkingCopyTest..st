Class {
	#name : #MCWorkingCopyTest,
	#superclass : #MCTestCase,
	#instVars : [
		'savedInitials',
		'workingCopy',
		'repositoryGroup',
		'versions',
		'versions2'
	],
	#category : #'Tests-Monticello'
}

{ #category : #asserting }
MCWorkingCopyTest >> assertNameWhenSavingTo: aRepository is: aString [
	| name |
	name := nil.
	[aRepository storeVersion: workingCopy newVersion]
		on: MCVersionNameAndMessageRequest
		do: [:n | 
			n patchBlock value.
			name := n suggestedName. n resume: (Array with: name with: '' with: Set new)].
	self assert: name = aString
]

{ #category : #asserting }
MCWorkingCopyTest >> assertNumberWhenSavingTo: aRepository is: aNumber [
	| name |
	name := nil.
	[aRepository storeVersion: workingCopy newVersion]
		on: MCVersionNameAndMessageRequest
		do: [:n | 
			n patchBlock value.
			name := n suggestedName. n resume: (Array with: name with: '' with: Set new)].
	self assert: name = (self packageName, '-', Utilities authorInitials, '.', aNumber asString)
]

{ #category : #actions }
MCWorkingCopyTest >> basicMerge: aVersion [
	aVersion merge
]

{ #category : #running }
MCWorkingCopyTest >> clearPackageCache [
	"Remove all mock packages created during the tests from the package cache."

	| directory |
	super clearPackageCache.
	directory := MCCacheRepository default directory.
	(directory fileNamesMatching: self packageName, '*') do: [ :each |
		directory deleteFileNamed: each ]
]

{ #category : #accessing }
MCWorkingCopyTest >> description [
	^ self class name
]

{ #category : #actions }
MCWorkingCopyTest >> load: aVersion [
	aVersion load
]

{ #category : #actions }
MCWorkingCopyTest >> merge: aVersion [
	[[self basicMerge: aVersion]
		on: MCMergeResolutionRequest do: [:n | n resume: true]]
			on: MCNoChangesException do: [:n | ]
]

{ #category : #private }
MCWorkingCopyTest >> packageName [
	^ self mockPackage name
]

{ #category : #running }
MCWorkingCopyTest >> setUp [
	| repos1 repos2 |
	self clearPackageCache.
	repositoryGroup := MCRepositoryGroup new.
	workingCopy := MCWorkingCopy forPackage: self mockPackage.
	versions := Dictionary new.
	versions2 := Dictionary new.
	repos1 := MCDictionaryRepository new dictionary: versions.
	repos2 := MCDictionaryRepository new dictionary: versions2.
	repositoryGroup addRepository: repos1.
	repositoryGroup addRepository: repos2.
	MCRepositoryGroup default removeRepository: repos1; removeRepository: repos2.
	workingCopy repositoryGroup: repositoryGroup.
	savedInitials := Utilities authorInitialsPerSe.
	Utilities authorInitials: 'abc'.
]

{ #category : #actions }
MCWorkingCopyTest >> snapshot [
	| version |
	[version := workingCopy newVersion]
		on: MCVersionNameAndMessageRequest
		do: [:n | 
			n patchBlock value.
			n resume: (Array with: n suggestedName with: '' with: Set new)].
	versions at: version info put: version.
	^ version
]

{ #category : #running }
MCWorkingCopyTest >> tearDown [
	super tearDown.
	workingCopy unregister.
	self restoreMocks.
	SystemOrganizer default removeEmptyCategories.
	MCSnapshotTest organization removeEmptyCategories.
	Utilities authorInitials: savedInitials
]

{ #category : #tests }
MCWorkingCopyTest >> testAncestorMerge [
	<timeout: 30 "seconds">
	| base revA revB revC |

	base := self snapshot.
	self change: #a toReturn: 'a1'.
	revA :=  self snapshot.
	self change: #b toReturn: 'b1'.
	revB :=  self snapshot.	
	self change: #c toReturn: 'c1'.
	revC :=  self snapshot.	

	self should: [self basicMerge: revA] raise: MCNoChangesException.
	
]

{ #category : #tests }
MCWorkingCopyTest >> testBackport [
	<timeout: 30 "seconds">
	| inst base final backported |
	inst := self mockInstanceA.
	base :=  self snapshot.
	self assert: inst one = 1.
	self change: #one toReturn: 2.
	self change: #two toReturn: 3.
	final := self snapshot.
	[workingCopy backportChangesTo: base info]
		on: MCChangeSelectionRequest
		do: [:e | e resume: e patch].
	self assert: inst one = 2.
	self assert: inst two = 3.
	self assert: workingCopy ancestry ancestors size = 1.
	self assert: workingCopy ancestry ancestors first = base info.
	self assert: workingCopy ancestry stepChildren size = 1.
	self assert: workingCopy ancestry stepChildren first = final info.
	backported := self snapshot.
	[workingCopy backportChangesTo: base info]
		on: MCChangeSelectionRequest
		do: [:e | e resume: e patch].
	self assert: workingCopy ancestry ancestors size = 1.
	self assert: workingCopy ancestry ancestors first = base info.
	self assert: workingCopy ancestry stepChildren size = 1.
	self assert: workingCopy ancestry stepChildren first = backported info.
	
]

{ #category : #tests }
MCWorkingCopyTest >> testDoubleRepeatedMerge [
	| base motherA1 motherA2 motherB1 motherB2 inst |
	<timeout: 30> "takes a little longer"
	base := self snapshot.
	self change: #a toReturn: 'a1'.
	motherA1 :=  self snapshot.
	self change: #c toReturn: 'c1'.
	motherA2 :=  self snapshot.	
	
	self load: base.
	self change: #b toReturn: 'b1'.
	motherB1 :=  self snapshot.
	self change: #d toReturn: 'd1'.
	motherB2 :=  self snapshot.
	
	self load: base.
	self merge: motherA1.
	self merge: motherB1.
	self change: #a toReturn: 'a2'.
	self change: #b toReturn: 'b2'.
	self snapshot.

	self merge: motherA2.
	self merge: motherB2.
	
	inst := self mockInstanceA.
	self assert: inst a = 'a2'.
	self assert: inst b = 'b2'.
	self assert: inst c = 'c1'.
	self assert: inst d = 'd1'.
	
]

{ #category : #tests }
MCWorkingCopyTest >> testMergeIntoImageWithNoChanges [
	<timeout: 30 "seconds">
	| base revB revA1 |

	self change: #a toReturn: 'a'.
	base := self snapshot.
	self change: #b toReturn: 'b'.
	revB := self snapshot.
	
	self load: base.
	self change: #a toReturn: 'a1'.
	revA1 := self snapshot.

	self change: #a toReturn: 'a'.
	self snapshot.
	self merge: revB.

	self assert: (workingCopy ancestors size = 2)
	
]

{ #category : #tests }
MCWorkingCopyTest >> testMergeIntoUnmodifiedImage [
	| base revA |

	<timeout: 30 "seconds">
	base := self snapshot.
	self change: #a toReturn: 'a1'.
	revA := self snapshot.
	
	self load: base.

	self merge: revA.

	self assert: (workingCopy ancestors size = 1)
	
]

{ #category : #tests }
MCWorkingCopyTest >> testOptimizedLoad [
	<timeout: 30 "seconds">
	| inst base diffy |
	inst := self mockInstanceA.
	base := self snapshot.
	self change: #one toReturn: 2.
	self assert: inst one = 2.
	diffy := self snapshot asDiffAgainst: base.
	self deny: diffy canOptimizeLoading.
	self load: base.
	self assert: inst one = 1.
	self assert: diffy canOptimizeLoading.
	self load: diffy.
	self assert: inst one = 2.

]

{ #category : #tests }
MCWorkingCopyTest >> testRedundantMerge [
	| base |
	base :=  self snapshot.
	self merge: base.
	
	"This shouldn't throw an exception"
	self merge: base.
]

{ #category : #tests }
MCWorkingCopyTest >> testRepeatedMerge [
	| base mother1 mother2 inst |
	<timeout: 30> "takes a little longer"
	base :=  self snapshot.
	self change: #one toReturn: 2.
	mother1 :=  self snapshot.
	self change: #two toReturn: 3.
	mother2 :=  self snapshot.	
	
	self load: base.
	self change: #truth toReturn: false.
	self snapshot.

	inst := self mockInstanceA.
	self assert: inst one = 1.
	self assert: inst two = 2.	

	self merge: mother1.
	self assert: inst one = 2.
	self assert: inst two = 2.	
	
	self change: #one toReturn: 7.
	self assert: inst one = 7.
	self assert: inst two = 2.
	
	"This shouldn't raise an exception"
	self merge: mother2.
	self assert: inst one = 7.
	self assert: inst two = 3.
]

{ #category : #tests }
MCWorkingCopyTest >> testSelectiveBackport [
	<timeout: 30 "seconds">
	| inst base intermediate final |
	inst := self mockInstanceA.
	base :=  self snapshot.
	self assert: inst one = 1.
	self change: #one toReturn: 2.
	intermediate := self snapshot.
	self change: #two toReturn: 3.
	final := self snapshot.
	[workingCopy backportChangesTo: base info]
		on: MCChangeSelectionRequest
		do: [:e | | selected patch |
			patch := e patch.
			selected := patch operations select: [:ea | ea definition selector = #two].
			e resume: (MCPatch operations: selected)]. 
	self assert: inst one = 1.
	self assert: inst two = 3.
	self assert: workingCopy ancestry ancestors size = 1.
	self assert: workingCopy ancestry ancestors first = base info.
	self assert: workingCopy ancestry stepChildren size = 1.
	self assert: workingCopy ancestry stepChildren first = final info
]

{ #category : #tests }
MCWorkingCopyTest >> testSimpleMerge [
	<timeout: 30 "seconds">
	| mother base inst |
	inst := self mockInstanceA.
	base :=  self snapshot.
	self change: #one toReturn: 2.
	mother :=  self snapshot.
	self load: base.
	self change: #two toReturn: 3.
	self snapshot.
	self assert: inst one = 1.
	self assert: inst two = 3.
	
	self merge: mother.
	self assert: inst one = 2.
	self assert: inst two = 3.
]

{ #category : #tests }
MCWorkingCopyTest >> testSnapshotAndLoad [
	| base inst |
	inst := self mockInstanceA.
	base :=  self snapshot.
	self change: #one toReturn: 2.
	self assert: inst one = 2.
	self load: base.
	self assert: inst one = 1.
]
