"
Abstract superclass for Monticello Repository tests

Instance Variables
	repository:		<MCRepository>

repository
	- the instance of MCRepository subclass being tested

"
Class {
	#name : #MCRepositoryTest,
	#superclass : #MCTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Tests-Monticello'
}

{ #category : #'as yet unclassified' }
MCRepositoryTest class >> isAbstract [
	^ self = MCRepositoryTest
]

{ #category : #actions }
MCRepositoryTest >> addVersion: aVersion [
	self subclassResponsibility 
]

{ #category : #actions }
MCRepositoryTest >> addVersionWithSnapshot: aSnapshot name: aString [
	| version |
	version := self versionWithSnapshot: aSnapshot name: aString.
	self addVersion: version.
	^ version info
]

{ #category : #asserting }
MCRepositoryTest >> assertMissing: aVersionInfo [
	self assert: (repository versionWithInfo: aVersionInfo) isNil
]

{ #category : #asserting }
MCRepositoryTest >> assertVersionInfos: aCollection [
	self assert: repository allVersionInfos asSet = aCollection asSet
]

{ #category : #actions }
MCRepositoryTest >> saveSnapshot1 [
	^ self saveSnapshot: self snapshot1 named: 'rev1'
]

{ #category : #actions }
MCRepositoryTest >> saveSnapshot2 [
	^ self saveSnapshot: self snapshot2 named: 'rev2'
]

{ #category : #actions }
MCRepositoryTest >> saveSnapshot: aSnapshot named: aString [
	| version |
	version := self versionWithSnapshot: aSnapshot name: aString.
	repository storeVersion: version.
	^ version info
	
]

{ #category : #building }
MCRepositoryTest >> snapshot1 [
	^ (MCSnapshot fromDefinitions: (Array with: (MCOrganizationDefinition categories: #('y'))))
]

{ #category : #building }
MCRepositoryTest >> snapshot2 [
	^ (MCSnapshot fromDefinitions: (Array with: (MCOrganizationDefinition categories: #('x'))))
]

{ #category : #accessing }
MCRepositoryTest >> snapshotAt: aVersionInfo [
	^ (repository versionWithInfo: aVersionInfo) snapshot
]

{ #category : #tests }
MCRepositoryTest >> testAddAndLoad [
	| node |
	node := self addVersionWithSnapshot: self snapshot1 name: 'rev1'.
	self assert: (self snapshotAt: node) = self snapshot1.

]

{ #category : #tests }
MCRepositoryTest >> testCreationMethods [
	"Tests creation via MCRepository>>location:"

	| repo |

	repo := MCRepository location: FileDirectory default pathName.
	self assert: (repo isKindOf: MCDirectoryRepository).
	self assert: (repo description = FileDirectory default pathName).

	repo := MCRepository location: (FileDirectory default pathName, FileDirectory slash, '*').
	self assert: (repo isKindOf: MCSubDirectoryRepository).
	"XXXX: MCSubDirectoryRepo prints wrongly on Windows"
	self assert: (repo description = (FileDirectory default pathName, FileDirectory slash, '*')).

	repo := MCRepository location: 'http://source.squeak.org/trunk'.
	self assert: (repo isKindOf: MCHttpRepository).
	self assert: (repo description = 'http://source.squeak.org/trunk').

	repo := MCRepository 
		location: 'ftp://source.squeak.org/trunk' 
		username: 'foo' 
		password: 'bar'.
	self assert: (repo isKindOf: MCFtpRepository).
	self assert: (repo description = 'ftp://foo@source.squeak.org/trunk').

]

{ #category : #tests }
MCRepositoryTest >> testIncludesName [
	self deny: (repository includesVersionNamed: 'MonticelloTest-xxx.1-rev1').
	self saveSnapshot1.
	self assert: (repository includesVersionNamed: 'MonticelloTest-xxx.1-rev1').
	self deny: (repository includesVersionNamed: 'MonticelloTest-xxx.1-rev2').
	self saveSnapshot2.
	self assert:  (repository includesVersionNamed: 'MonticelloTest-xxx.1-rev2').
]

{ #category : #tests }
MCRepositoryTest >> testLoadMissingNode [
	| node |
	node := MCVersionInfo new.
	self assertMissing: node
]

{ #category : #tests }
MCRepositoryTest >> testStoreAndLoad [
	| node node2 |
	node := self saveSnapshot1.
	node2 := self saveSnapshot2.
	self assert: (self snapshotAt: node) = self snapshot1.
	self assert: (self snapshotAt: node2) = self snapshot2.
]

{ #category : #building }
MCRepositoryTest >> versionWithSnapshot: aSnapshot name: aString [
	| info |
	info := self mockVersionInfo: aString. 
	^ MCVersion 
		package: (MCPackage new name: aString)
		info: info
		snapshot: aSnapshot
]
