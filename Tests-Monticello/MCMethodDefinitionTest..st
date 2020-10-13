Class {
	#name : #MCMethodDefinitionTest,
	#superclass : #MCTestCase,
	#instVars : [
		'navigation',
		'isModified',
		'overrideTimestamp',
		'extensionPackage'
	],
	#category : #'Tests-Monticello'
}

{ #category : #mocks }
MCMethodDefinitionTest >> override [ ^ 1
]

{ #category : #running }
MCMethodDefinitionTest >> ownPackage [
	^ MCWorkingCopy forPackage: (MCPackage named: 'Tests')
]

{ #category : #running }
MCMethodDefinitionTest >> setUp [
	extensionPackage := (MCWorkingCopy forPackage: (MCPackage named: 'FooBarBaz')).
	navigation := (Smalltalk hasClassNamed: #SystemNavigation)
		ifTrue: [(Smalltalk at: #SystemNavigation) new]
		ifFalse: [Smalltalk].
	isModified := self ownPackage modified.
	overrideTimestamp := (self class >> #override) timeStamp
]

{ #category : #running }
MCMethodDefinitionTest >> tearDown [

	self restoreMocks.
	extensionPackage unregister.
	extensionPackage := nil.
	MCMockPackageInfo new mcPackage workingCopy unregister.
	self class
		compile: 'override ^ 1'
		classified: 'mocks'
		withStamp: overrideTimestamp
		notifying: nil.
	SystemOrganizer default removeEmptyCategories.
	self ownPackage modified: isModified.
	super tearDown

]

{ #category : #tests }
MCMethodDefinitionTest >> testCannotLoad [
	| definition |
	definition := self mockMethod: #kjahs87 class: 'NoSuchClass' source: 'kjahs87 ^self' meta: false.
	self should: [definition load] raise: Error.
	self assert: (navigation allImplementorsOf: #kjahs87) isEmpty
]

{ #category : #tests }
MCMethodDefinitionTest >> testComparison [
	|d1 d2 d3 d4 d5 |
	d1 := self mockMethod: #one class: 'A' source: '1' meta: false.
	d2 := self mockMethod: #one class: 'A' source: '2' meta: false.
	d3 := self mockMethod: #one class: 'A' source: '1' meta: true.
	d4 := self mockMethod: #two class: 'A' source: '1' meta: false.
	d5 := self mockMethod: #two class: 'A' source: '1' meta: false.
	
	self assert: (d1 isRevisionOf: d2).
	self deny: (d1 isSameRevisionAs: d2).
	
	self deny: (d1 isRevisionOf: d3).
	self deny: (d1 isRevisionOf: d4).
	
	self assert: (d4 isSameRevisionAs: d5).
]

{ #category : #tests }
MCMethodDefinitionTest >> testLoadAndUnload [
	|definition|
	definition := self mockMethod: #one class: 'MCMockClassA' source: 'one ^2' meta: false.
	self assert: self mockInstanceA one = 1.
	definition load.
	self assert: self mockInstanceA one = 2.
	definition unload.
	self deny: (self mockInstanceA respondsTo: #one)
]

{ #category : #tests }
MCMethodDefinitionTest >> testPartiallyRevertOverrideMethod [
	| definition |
	self class compile: 'override ^ 2' classified: '*foobarbaz'.
	self class compile: 'override ^ 3' classified: self mockOverrideMethodCategory.
	self class compile: 'override ^ 4' classified: self mockOverrideMethodCategory.
	definition := (MethodReference class: self class selector: #override) asMethodDefinition.
	self assert: definition isOverrideMethod.
	self assert: self override = 4.
	definition unload.
	self assert: self override = 2.
	self assert: (MethodReference class: self class selector: #override) category = '*foobarbaz'.
	
]

{ #category : #tests }
MCMethodDefinitionTest >> testRevertOldMethod [
	| definition changeRecord |
	Object compile: 'yourself ^ self' classified: self mockOverrideMethodCategory.
	definition := (MethodReference class: Object selector: #yourself) asMethodDefinition.
	changeRecord := definition scanForPreviousVersions first.
	self assert: changeRecord notNil.
	self assert: changeRecord category = 'accessing'.
	changeRecord fileIn.
]

{ #category : #tests }
MCMethodDefinitionTest >> testRevertOverrideMethod [
	| definition |
	self class compile: 'override ^ 2' classified:  '*foobarbaz-override'.
	definition := (MethodReference class: self class selector: #override) asMethodDefinition.
	self assert: definition isOverrideMethod description: 'Method not marked as an override'.
	self assert: 2 equals: self override description: 'Method not overridden'.
	definition unload.
	self assert: 1 equals: self override description: 'Unload didn''t revert method'.
	self assert: 'mocks' equals: (MethodReference class: self class selector: #override) category  description: 'Unload didn''t revert. method classification'.
	
]
