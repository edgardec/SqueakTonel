"
I demonstrate that you can load MC snapshots into an environment.
"
Class {
	#name : #MCEnvironmentLoadTest,
	#superclass : #MCTestCase,
	#instVars : [
		'environment'
	],
	#category : #'Tests-Monticello'
}

{ #category : #running }
MCEnvironmentLoadTest >> setUp [
	environment := Environment named: 'MCEnvironmentLoadTest'.
	
	"This is required in order to not importSelf more than once"
	environment stopObserving: environment. 
	
	"This is required to make own declarations visible in environment"
	environment importSelf.
	
	"Import the required PoolDictionary used by the package"
	environment bindingOf: #MCMockAPoolDictionary
		ifAbsent: [environment from: Smalltalk globals import: #MCMockAPoolDictionary].
	environment from: Smalltalk globals import: #(MCMock MCSnapshotTest Object).
]

{ #category : #running }
MCEnvironmentLoadTest >> tearDown [
	(environment allClassesAndTraits sorted: [:a :b |
		(a allSuperclasses includes: b) or: [a name < b name]])
			do: [:each | each removeFromSystem].
	super tearDown
]

{ #category : #tests }
MCEnvironmentLoadTest >> testLoadIntoEnvironment [
	[[MCPackageLoader installSnapshot: self mockSnapshot]
		valueSupplyingAnswers: #(('The pool dictionary*does not exist*automatically created?' true))]
		on: CurrentEnvironment
		do: [:e | e resume: environment].
	self assert: (environment bindingOf: #MCMockClassA) notNil
		description: 'Environment has no binding for MCMockClassA'.
]
