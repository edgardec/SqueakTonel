Class {
	#name : #MCChangeNotificationTest,
	#superclass : #MCTestCase,
	#instVars : [
		'workingCopy'
	],
	#category : #'Tests-Monticello'
}

{ #category : #private }
MCChangeNotificationTest >> foreignMethod [
	"see testForeignMethodModified"
]

{ #category : #events }
MCChangeNotificationTest >> modifiedEventFor: aSelector ofClass: aClass [
	| method |
	method := aClass compiledMethodAt: aSelector.
	^ ModifiedEvent 
				methodChangedFrom: method
				to: method
				selector: aSelector
				inClass: aClass.

]

{ #category : #running }
MCChangeNotificationTest >> setUp [
	super setUp.
	workingCopy := MCWorkingCopy forPackage: self mockPackage
]

{ #category : #running }
MCChangeNotificationTest >> tearDown [

	super tearDown.
	workingCopy unregister
]

{ #category : #tests }
MCChangeNotificationTest >> testCoreMethodModified [
	| event |
	workingCopy modified: false.
	event := self modifiedEventFor: #one ofClass: self mockClassA.
	MCWorkingCopy methodModified: event.
	self assert: workingCopy modified
]

{ #category : #tests }
MCChangeNotificationTest >> testExtMethodModified [
	| event mref |
	workingCopy modified: false.
	mref := workingCopy packageInfo extensionMethods first.
	event := self modifiedEventFor: mref methodSymbol ofClass: mref actualClass.
	MCWorkingCopy methodModified: event.
	self assert: workingCopy modified
]

{ #category : #tests }
MCChangeNotificationTest >> testForeignMethodModified [
	| event |
	workingCopy modified: false.
	event := self modifiedEventFor: #foreignMethod ofClass: self class.
	MCWorkingCopy methodModified: event.
	self deny: workingCopy modified
]
