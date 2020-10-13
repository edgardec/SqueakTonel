Class {
	#name : #InstallerTest,
	#superclass : #TestCase,
	#instVars : [
		'listOfFileNames',
		'mockAllFileNames',
		'mockConfigurationVersion'
	],
	#category : #'Tests-Installer-Core'
}

{ #category : #'as yet unclassified' }
InstallerTest class >> suiteClass [
	^ InstallerTestSuite
]

{ #category : #'mock MCRepositoryGroup' }
InstallerTest >> allFileNames: listOfNames [
	"mocking support - the list of names is a stand-in for the cache and file name retrieval"
	mockAllFileNames := listOfNames

]

{ #category : #'mock MCRepositoryGroup' }
InstallerTest >> allFileNamesOrCache [
	"mock for MCFileBasedRepository>>allFileNamesOrCache"
	^mockAllFileNames
]

{ #category : #'mock MCConfiguration' }
InstallerTest >> isKindOf: aClass [
	"InstallerMonticello>>mcThing sends isKindOf: MCConfiguration. Let an Instance
	of InstallerTest stand in as a replacement MCConfiguration for purposes of determing
	the return value of #mcThing."
	^(super isKindOf: aClass)
		or: [MCConfiguration withAllSubclasses 
				detect: [ :e | e = MCConfiguration]
				ifNone: false.
			true]

]

{ #category : #'mock MCConfiguration' }
InstallerTest >> mockConfigurationVersion [
	^mockConfigurationVersion
]

{ #category : #'mock MCConfiguration' }
InstallerTest >> mockConfigurationVersion: aVersion [
	mockConfigurationVersion := aVersion

]

{ #category : #running }
InstallerTest >> setUp [
	"A list of version names as might be answered by MCFileBasedRepository>>versionNamesForPackageNamed:"

	listOfFileNames := #('Chronology-Core-dtl.23.mcz' 'Chronology-Core.UTC-dtl.9.mcz' 'Chronology-Core-XXX.8.mcz' 'Chronology-Core-dtl.24.mcz' 'Chronology-Core-XXX.14.mcz' 'Chronology-Core-bf.7.mcz' 'Chronology-Core-dtl.29.mcz' 'Chronology-Core-cmm.15.mcz' 'Chronology-Core-XXX.9.mcz' 'Chronology-Core-dtl.3.mcz' 'Chronology-Core-dtl.16.mcz' 'Chronology-Core.UTC-dtl.28.mcz' 'Chronology-Core-XXX.21.mcz' 'Chronology-Core.UTC-dtl.20.mcz' 'Chronology-Core-XXX.27.mcz' 'Chronology-Core-mt.11.mcz' 'Chronology-Core-dtl.4.mcz' 'Chronology-Core.UTC-dtl.22.mcz' 'Chronology-Core-XXX.3.mcz' 'Chronology-Core.UTC-dtl.27.mcz' 'Chronology-Core-XXX.10.mcz' 'Chronology-Core-dtl.18.mcz' 'Chronology-Core-bf.4.mcz' 'Chronology-Core-cmm.6.mcz' 'Chronology-Core.UTC-dtl.5.mcz' 'Chronology-Core-dtl.6.mcz' 'Chronology-Core.UTC-dtl.3.mcz' 'Chronology-Core-XXX.26.mcz' 'Chronology-Core-dtl.26.mcz' 'Chronology-Core-XXX.23.mcz' 'Chronology-Core.UTC-dtl.19.mcz' 'Chronology-Core-cmm.3.mcz' 'Chronology-Core-XXX.28.mcz' 'Chronology-Core-dtl.20.mcz' 'Chronology-Core-ul.8.mcz' 'Chronology-Core-dtl.27.mcz' 'Chronology-Core-dtl.9.mcz' 'Chronology-Core-dtl.11.mcz' 'Chronology-Core.UTC-dtl.10.mcz' 'Chronology-Core-dtl.28.mcz' 'Chronology-Core-XXX.11.mcz' 'Chronology-Core.UTC-dtl.25.mcz' 'Chronology-Core-XXX.18.mcz' 'Chronology-Core-XXX.30.mcz' 'Chronology-Core-ul.13.mcz' 'Chronology-Core.UTC-dtl.26.mcz' 'Chronology-Core-bf.5.mcz' 'Chronology-Core-XXX.5.mcz' 'Chronology-Core.UTC-dtl.15.mcz' 'Chronology-Core.UTC-dtl.11.mcz' 'Chronology-Core-dtl.8.mcz' 'Chronology-Core.UTC-dtl.21.mcz' 'Chronology-Core.UTC-dtl.24.mcz' 'Chronology-Core.UTC-ul.13.mcz' 'Chronology-Core-cmm.2.mcz' 'Chronology-Core-XXX.29.mcz' 'Chronology-Core-dtl.22.mcz' 'Chronology-Core.UTC-dtl.14.mcz' 'Chronology-Core.UTC-dtl.17.mcz' 'Chronology-Core-dtl.25.mcz' 'Chronology-Core.UTC-dtl.7.mcz' 'Chronology-Core.UTC-dtl.30.mcz' 'Chronology-Core-dtl.21.mcz' 'Chronology-Core-XXX.12.mcz' 'Chronology-Core-dtl.10.mcz' 'Chronology-Core-dtl.15.mcz' 'Chronology-Core-XXX.17.mcz' 'Chronology-Core-XXX.25.mcz' 'Chronology-Core.UTC-dtl.23.mcz' 'Chronology-Core-dtl.12.mcz' 'Chronology-Core-dtl.19.mcz' 'Chronology-Core-XXX.19.mcz' 'Chronology-Core.UTC-dtl.29.mcz' 'Chronology-Core-ul.10.mcz' 'Chronology-Core.UTC-dtl.6.mcz' 'Chronology-Core-XXX.4.mcz' 'Chronology-Core.UTC-dtl.18.mcz' 'Chronology-Core.UTC-dtl.16.mcz' 'Chronology-Core-pre.9.mcz' 'Chronology-Core-tcj.12.mcz' 'Chronology-Core.UTC-dtl.8.mcz' 'Chronology-Core-dtl.30.mcz' 'Chronology-Core-XXX.7.mcz' 'Chronology-Core-XXX.6.mcz' 'Chronology-Core-XXX.15.mcz' 'Chronology-Core.UTC-dtl.12.mcz' 'Chronology-Core-dtl.5.mcz' 'Chronology-Core-dtl.7.mcz' 'Chronology-Core-XXX.22.mcz' 'Chronology-Core.UTC-dtl.4.mcz' 'Chronology-Core-dtl.14.mcz' 'Chronology-Core-XXX.24.mcz' 'Chronology-Core-dtl.17.mcz' 'Chronology-Core-ul.13.mcz' 'Chronology-Core-XXX.20.mcz' 'Chronology-Core-XXX.16.mcz').




]

{ #category : #'tests - package and version' }
InstallerTest >> testPackageAndVersionNameShouldSanitiseInput [
	| installer |
	installer := Installer new.
	self assert: {'Foo'. ''} equals: (installer packageAndVersionFrom: 'Foo').
	self assert: {'Foo'. '1'} equals: (installer packageAndVersionFrom: 'Foo(1)').
	self assert: {'Foo'. 'head'} equals: (installer packageAndVersionFrom: ' Foo ( head ) ').
]

{ #category : #'tests - version selection' }
InstallerTest >> testSelectFullySpecifiedBranchVersion [
	| installer |
	installer := InstallerMonticelloMock new.

	installer setMockCache: listOfFileNames.
	installer packages: { 'Chronology-Core.UTC-dtl.30' }.
	self assert: 'Chronology-Core.UTC-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core.UTC-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.

	installer setMockCache: listOfFileNames.
	installer packages: { 'Chronology-Core.UTC-dtl.30.mcz' }.
	self assert: 'Chronology-Core.UTC-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core.UTC-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.

]

{ #category : #'tests - version selection' }
InstallerTest >> testSelectFullySpecifiedVersion [
	| installer |
	installer := InstallerMonticelloMock new.

	installer packages: { 'Chronology-Core-dtl.30' }.
	installer setMockCache: listOfFileNames.
	self assert: 'Chronology-Core-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.

	installer packages: { 'Chronology-Core-dtl.30.mcz' }.
	installer setMockCache: listOfFileNames.
	self assert: 'Chronology-Core-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core-dtl.30' equals: installer mcThing mockConfigurationVersion versionName.

	installer packages: { 'Chronology-Core-bf.7' }.
	installer setMockCache: listOfFileNames.
	self assert: 'Chronology-Core-bf.7' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core-bf.7' equals: installer mcThing mockConfigurationVersion versionName.

	installer packages: { 'Chronology-Core-bf.7.mcz' }.
	installer setMockCache: listOfFileNames.
	self assert: 'Chronology-Core-bf.7' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core-bf.7' equals: installer mcThing mockConfigurationVersion versionName.


]

{ #category : #'tests - version selection' }
InstallerTest >> testSelectFullySpecifiedVersionWhereVersionNumberMayBeAmbiguous [
	"Documents a bug in earlier versions of the Monticello installer, in which a
	requiest to load version 3 would load the wrong version if a version 30 existed
	in the same repository."

	"(self selector: #testSelectFullySpecifiedVersionWhereVersionNumberMayBeAmbiguous) debug"

	| installer |
	installer := InstallerMonticelloMock new.

	installer packages: { 'Chronology-Core-dtl.3' }.
	installer setMockCache: listOfFileNames.
	self deny: 'Chronology-Core-dtl.30' = installer mcThing mockConfigurationVersion versionName
		description: 'version 3 was specified, but version 30 was selected'.
	self assert: 'Chronology-Core-dtl.3' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self deny: 'Chronology-Core-dtl.30' = installer mcThing mockConfigurationVersion versionName
		description: 'version 3 was specified, but version 30 was selected'.
	self assert: 'Chronology-Core-dtl.3' equals: installer mcThing mockConfigurationVersion versionName.

	installer packages: { 'Chronology-Core-dtl.3.mcz' }.
	self deny: 'Chronology-Core-dtl.30' = installer mcThing mockConfigurationVersion versionName
		description: 'version 3 was specified, but version 30 was selected'.
	self assert: 'Chronology-Core-dtl.3' equals: installer mcThing mockConfigurationVersion versionName.
	installer setMockCache: listOfFileNames reversed.
	self deny: 'Chronology-Core-dtl.30' = installer mcThing mockConfigurationVersion versionName
		description: 'version 3 was specified, but version 30 was selected'.
	self assert: 'Chronology-Core-dtl.3' equals: installer mcThing mockConfigurationVersion versionName.

]

{ #category : #'tests - version selection' }
InstallerTest >> testSelectLatestVersionForPackage [
	"The listOfFileNames test data set contains more than one Chronology-Core-???.30
	version differing by author initials. The first detected in sort order is valid, therefore
	test only for package, branch, and version number."
	| installer |
	installer := InstallerMonticelloMock new.

	installer packages: { 'Chronology-Core' }.
	installer setMockCache: listOfFileNames.
	self assert: 'Chronology-Core' equals: installer mcThing mockConfigurationVersion packageAndBranchName.
	self assert: 30 equals: installer mcThing mockConfigurationVersion versionNumber.

	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core' equals: installer mcThing mockConfigurationVersion packageAndBranchName.
	self assert: 30 equals: installer mcThing mockConfigurationVersion versionNumber.


]

{ #category : #'tests - version selection' }
InstallerTest >> testSelectLatestVersionInBranchForPackage [
	"The listOfFileNames test data set contains more than one Chronology-Core.UTC-???.30
	version differing by author initials. The first detected in sort order is valid, therefore
	test only for package, branch, and version number."
	| installer |
	installer := InstallerMonticelloMock new.

	installer packages: { 'Chronology-Core.UTC' }.
	installer setMockCache: listOfFileNames.
	self assert: 'Chronology-Core.UTC' equals: installer mcThing mockConfigurationVersion packageAndBranchName.
	self assert: 30 equals: installer mcThing mockConfigurationVersion versionNumber.

	installer setMockCache: listOfFileNames reversed.
	self assert: 'Chronology-Core.UTC' equals: installer mcThing mockConfigurationVersion packageAndBranchName.
	self assert: 30 equals: installer mcThing mockConfigurationVersion versionNumber.


]

{ #category : #'mock MCRepositoryGroup' }
InstallerTest >> versionNamed: fileToLoad [
	"mock for MCFileBasedRepository>>versionNamed:"
	^InstallerTest new mockConfigurationVersion: fileToLoad "mock MCConfiguration"
]

{ #category : #'mock MCRepositoryGroup' }
InstallerTest >> versionNamesForPackageNamed: packageName [
	"mock for MCFileBasedRepository>>versionNamesForPackageNamed:"
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
