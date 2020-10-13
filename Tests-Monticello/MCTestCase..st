"
Abstract superclass for Monticello tests
Monticello is the distributed source code management system.
"
Class {
	#name : #MCTestCase,
	#superclass : #TestCase,
	#category : #'Tests-Monticello'
}

{ #category : #testing }
MCTestCase class >> isAbstract [
	^ self = MCTestCase
]

{ #category : #accessing }
MCTestCase class >> resources [
	^ Array with: MCSnapshotResource
]

{ #category : #asserting }
MCTestCase >> assertPackage: actual matches: expected [
	self assert: actual = expected

]

{ #category : #asserting }
MCTestCase >> assertSnapshot: actual matches: expected [
	| diff |
	diff := actual patchRelativeToBase: expected.
	self assert: diff isEmpty

]

{ #category : #asserting }
MCTestCase >> assertVersion: actual matches: expected [
	self assertPackage: actual package matches: expected package.	
	self assertVersionInfo: actual info matches: expected info.
	self assertSnapshot: actual snapshot matches: expected snapshot.
]

{ #category : #asserting }
MCTestCase >> assertVersionInfo: actual matches: expected [
	self assert: actual name = expected name.
	self assert: actual message = expected message.
	self assert: actual ancestors size = expected ancestors size.
	actual ancestors with: expected ancestors do: [:a :e | self assertVersionInfo: a matches: e]
	
]

{ #category : #compiling }
MCTestCase >> change: aSelector toReturn: anObject [
	self 
		compileClass: self mockClassA 
		source: aSelector, ' ^ ', anObject printString 
		category: 'numeric'
]

{ #category : #running }
MCTestCase >> clearPackageCache [
	"Remove all mock packages created during the tests from the package cache."

	| directory |
	directory := MCCacheRepository default directory.
	(directory fileNamesMatching: self mockVersionName, '*') do: [ :each |
		directory deleteFileNamed: each ]
]

{ #category : #mocks }
MCTestCase >> commentForClass: name [
	^ 'This is a comment for ', name
]

{ #category : #mocks }
MCTestCase >> commentStampForClass: name [
	^ 'tester-', name,  ' 1/1/2000 00:00'
]

{ #category : #compiling }
MCTestCase >> compileClass: aClass source: source category: category [
	aClass compileSilently: source classified: category
]

{ #category : #mocks }
MCTestCase >> mockCategoryName [
	^ 'Tests-Monticello-Mocks'
]

{ #category : #mocks }
MCTestCase >> mockClass: className super: superclassName [
	^ MCClassDefinition
		name:  className
		superclassName:  superclassName
		category: self mockCategoryName
		instVarNames: #()
		classVarNames: #()
		poolDictionaryNames: #()
		classInstVarNames: #()
		type: ((Smalltalk classNamed: className asSymbol)
				ifNil: [#normal]
				ifNotNil: [:class| class typeOfClass])
		comment: (self commentForClass: className)
		commentStamp: (self commentStampForClass: className)
]

{ #category : #mocks }
MCTestCase >> mockClassA [
	^ Smalltalk at: #MCMockClassA
]

{ #category : #mocks }
MCTestCase >> mockClassB [
	^ Smalltalk at: #MCMockClassB
]

{ #category : #mocks }
MCTestCase >> mockDependencies [
	^ Array with: (MCVersionDependency package: self mockEmptyPackage info: (self mockVersionInfo: 'x'))
]

{ #category : #mocks }
MCTestCase >> mockEmptyPackage [
	^ MCPackage named: (MCEmptyPackageInfo new packageName)
]

{ #category : #mocks }
MCTestCase >> mockExtensionMethodCategory [
	^ MCMockPackageInfo new methodCategoryPrefix.
]

{ #category : #mocks }
MCTestCase >> mockInstanceA [
	^ self mockClassA new
]

{ #category : #mocks }
MCTestCase >> mockMessageString [
	^ 'A version generated for testing purposes.'
]

{ #category : #mocks }
MCTestCase >> mockMethod: aSymbol class: className source: sourceString meta: aBoolean [
	^ MCMethodDefinition
		className: className
		classIsMeta: aBoolean
		selector:  aSymbol
		category: 'as yet unclassified'
		timeStamp: ''
		source: sourceString
]

{ #category : #mocks }
MCTestCase >> mockOverrideMethodCategory [
	^ self mockExtensionMethodCategory, '-override'
]

{ #category : #mocks }
MCTestCase >> mockPackage [
	^ MCSnapshotResource mockPackage
]

{ #category : #mocks }
MCTestCase >> mockSnapshot [
	^ MCSnapshotResource current snapshot
]

{ #category : #mocks }
MCTestCase >> mockToken: aSymbol [
	^ MCMockDefinition token: aSymbol
]

{ #category : #mocks }
MCTestCase >> mockVersion [
	^ MCVersion 
		package: self mockPackage
		info: self mockVersionInfo
		snapshot: self mockSnapshot
]

{ #category : #mocks }
MCTestCase >> mockVersionInfo [
	^ self treeFrom: #(d ((b ((a))) (c)))
]

{ #category : #mocks }
MCTestCase >> mockVersionInfo: tag [ 
	^ MCVersionInfo
		name: self mockVersionName, '-', tag asString
		id: UUID new
		message: self mockMessageString, '-', tag asString
		date: Date today
		time: Time now
		author: Utilities authorInitials 
		ancestors: #()

]

{ #category : #mocks }
MCTestCase >> mockVersionInfoWithAncestor: aVersionInfo [ 
	^ MCVersionInfo
		name: aVersionInfo name, '-child'
		id: UUID new
		message: self mockMessageString
		date: Date today
		time: Time now
		author: Utilities authorInitials 
		ancestors: {aVersionInfo}

]

{ #category : #mocks }
MCTestCase >> mockVersionName [
	^ 'MonticelloTest-xxx.1'
]

{ #category : #mocks }
MCTestCase >> mockVersionWithAncestor: aMCVersion [ 
	^ MCVersion
		package: self mockPackage
		info: (self mockVersionInfoWithAncestor: aMCVersion info)
		snapshot: self mockPackage snapshot
]

{ #category : #mocks }
MCTestCase >> mockVersionWithDependencies [
	^ MCVersion 
		package: self mockPackage
		info: self mockVersionInfo
		snapshot: self mockSnapshot
		dependencies: self mockDependencies
]

{ #category : #private }
MCTestCase >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #compiling }
MCTestCase >> restoreMocks [
	self mockSnapshot updatePackage: self mockPackage
]

{ #category : #running }
MCTestCase >> tearDown [

	self clearPackageCache
]

{ #category : #mocks }
MCTestCase >> treeFrom: anArray [
	| name id |
	name := anArray first.
	id := '00000000-0000-0000-0000-0000000000', (name asString size = 1 ifTrue: [name asString, '0'] ifFalse: [name asString]).
	^ MCVersionInfo
		name: name
		id: (UUID fromString: id)
		message: ''
		date: nil
		time: nil
		author: ''
		ancestors: (anArray size > 1 ifTrue: [(anArray second collect: [:ea | self treeFrom: ea])] ifFalse: [#()])
]
