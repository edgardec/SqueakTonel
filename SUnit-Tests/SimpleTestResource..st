Class {
	#name : #SimpleTestResource,
	#superclass : #TestResource,
	#instVars : [
		'runningState',
		'hasRun',
		'hasSetup',
		'hasRanOnce'
	],
	#category : #'SUnit-Tests'
}

{ #category : #testing }
SimpleTestResource >> hasRun [
	^hasRun
			
]

{ #category : #testing }
SimpleTestResource >> hasSetup [
	^hasSetup
			
]

{ #category : #testing }
SimpleTestResource >> isAvailable [
	
	^self runningState == self startedStateSymbol
			
]

{ #category : #accessing }
SimpleTestResource >> runningState [

	^runningState
			
]

{ #category : #accessing }
SimpleTestResource >> runningState: aSymbol [

	runningState := aSymbol
			
]

{ #category : #running }
SimpleTestResource >> setRun [
	hasRun := true
			
]

{ #category : #running }
SimpleTestResource >> setUp [
	
	self runningState: self startedStateSymbol.
	hasSetup := true
			
]

{ #category : #running }
SimpleTestResource >> startedStateSymbol [

	^#started
			
]

{ #category : #running }
SimpleTestResource >> stoppedStateSymbol [

	^#stopped
			
]

{ #category : #running }
SimpleTestResource >> tearDown [

	self runningState: self stoppedStateSymbol
			
]
