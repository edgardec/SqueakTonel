Class {
	#name : #MCFileInTest,
	#superclass : #MCTestCase,
	#instVars : [
		'stream',
		'expected',
		'diff'
	],
	#category : #'Tests-Monticello'
}

{ #category : #private }
MCFileInTest >> alterInitialState [
	self mockClassA touchCVar
]

{ #category : #asserting }
MCFileInTest >> assertFileOutFrom: writerClass canBeFiledInWith: aBlock [
	(writerClass on: stream) writeSnapshot: self mockSnapshot.
	self alterInitialState.
	self assertSuccessfulLoadWith: aBlock.
	self mockPackage unload.
	self assertSuccessfulLoadWith: aBlock.

]

{ #category : #asserting }
MCFileInTest >> assertInitializersCalled [
	| cvar |
	cvar := self mockClassA cVar.
	self assert: cvar = #initialized
]

{ #category : #asserting }
MCFileInTest >> assertNoChange [
	| actual |
	actual := MCSnapshotResource takeSnapshot.
	diff := actual patchRelativeToBase: expected.
	self assert: diff isEmpty
]

{ #category : #asserting }
MCFileInTest >> assertSuccessfulLoadWith: aBlock [
	stream reset.
	aBlock value.
	self assertNoChange.
	self assertInitializersCalled.
]

{ #category : #running }
MCFileInTest >> setUp [
	expected := self mockSnapshot.
	stream := RWBinaryOrTextStream on: String new.
]

{ #category : #running }
MCFileInTest >> tearDown [

	super tearDown.
	(diff isNil or: [diff isEmpty not])
		 ifTrue: [expected updatePackage: self mockPackage].
	SystemOrganizer default removeEmptyCategories
]

{ #category : #tests }
MCFileInTest >> testStWriter [
	<timeout: 30> "takes a little longer"
	self
		assertFileOutFrom: MCStWriter
		canBeFiledInWith: [stream fileIn].

]
