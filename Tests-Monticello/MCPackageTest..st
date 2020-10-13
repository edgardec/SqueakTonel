Class {
	#name : #MCPackageTest,
	#superclass : #MCTestCase,
	#category : #'Tests-Monticello'
}

{ #category : #running }
MCPackageTest >> tearDown [

	super tearDown.
	self mockSnapshot install
]

{ #category : #tests }
MCPackageTest >> testLoadOrder [

	| snapshot loader additions |
	snapshot := MCMockPackageInfo new mcPackage snapshot.
	loader := MCPackageLoader new.
	loader installSnapshot: snapshot.
	loader analyze.
	additions := loader instVarNamed: #additions.
	self assert: [(additions findLast: [:ea | ea isKindOf: MCPreambleDefinition])
		< (additions findFirst: [:ea | ea isClassDefinition])].
	self assert: [(additions findFirst: [:ea | ea isKindOf: MCPostscriptDefinition])
		> (additions findLast: [:ea | ea isClassDefinition])].
]

{ #category : #tests }
MCPackageTest >> testUnload [
	| mock |
	self mockPackage unload.
	self deny: (Smalltalk hasClassNamed: #MCMockClassA) description: 'Class not removed'.
	self deny: (MCSnapshotTest includesSelector: #mockClassExtension) description: 'Extension method not removed'.

	mock := Smalltalk classNamed: #MCMock.
	self assert: (mock subclasses noneSatisfy: [:c | c name = #MCMockClassA]) description: 'Can still find the "removed" subclass'.
]

{ #category : #tests }
MCPackageTest >> testUnloadOrder [

	| package loader removals |
	package := MCMockPackageInfo new mcPackage.
	loader := MCPackageLoader new.
	loader unloadPackage: package.
	loader analyze.
	removals := loader instVarNamed: #removals.
	self assert: [(removals findLast: [:ea | ea isKindOf: MCRemovalPreambleDefinition])
		< (removals findFirst: [:ea | ea isClassDefinition])].
	self assert: [(removals findFirst: [:ea | ea isKindOf: MCRemovalPostscriptDefinition])
		> (removals findLast: [:ea | ea isClassDefinition])].
]
