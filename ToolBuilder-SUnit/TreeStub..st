Class {
	#name : #TreeStub,
	#superclass : #WidgetStub,
	#instVars : [
		'roots'
	],
	#category : #'ToolBuilder-SUnit'
}

{ #category : #private }
TreeStub >> openPath: anArray [
	| first |
	first := roots detect: [:ea | ea matches: anArray first] ifNone: [^ self].
	first openPath: anArray allButFirst
]

{ #category : #private }
TreeStub >> roots: anArray [
	roots := anArray collect: [:ea | TreeNodeStub fromSpec: spec item: ea].

]

{ #category : #simulating }
TreeStub >> select: anArray [
	self openPath: anArray
]

{ #category : #'initialize-release' }
TreeStub >> setSpec: aSpec [
	super setSpec: aSpec.
	self update: spec roots.
	self update: spec getSelectedPath.
]

{ #category : #events }
TreeStub >> update: anObject [
	anObject == spec roots ifTrue: [^ self updateRoots].
	anObject == spec getSelectedPath ifTrue: [^ self updateSelectedPath].
	(anObject isKindOf: Array) ifTrue: [^ self openPath: anObject allButFirst].
	super update: anObject
	
]

{ #category : #events }
TreeStub >> updateRoots [
	^ self roots: (self model perform: spec roots)

]

{ #category : #events }
TreeStub >> updateSelectedPath [
	| path first |
	path := self model perform: spec getSelectedPath.
	first := roots detect: [:ea | ea item = path first] ifNone: [^ self].
	first selectPath: path allButFirst.
]
