Class {
	#name : #TestCaseDebugger,
	#superclass : #Debugger,
	#instVars : [
		'doneSemaphore'
	],
	#category : #'Etoys-Squeakland-SUnit'
}

{ #category : #'as yet unclassified' }
TestCaseDebugger >> doneSemaphore: aSemaphore [
	doneSemaphore := aSemaphore.
]

{ #category : #'as yet unclassified' }
TestCaseDebugger >> windowIsClosing [
	super windowIsClosing.
	doneSemaphore ifNotNil: [ doneSemaphore signal ]
]
