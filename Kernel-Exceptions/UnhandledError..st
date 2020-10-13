"
This is a wrapper for an unhandled error. Having this, process stepping is able to correctly fire other unhandled errors. See Process >> #stepToHome: for further explanations.
"
Class {
	#name : #UnhandledError,
	#superclass : #Exception,
	#instVars : [
		'exception'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #'as yet unclassified' }
UnhandledError class >> signalForException: anError [
	"Very important entry point for analysis stack when stepping in a debugging session. See Process >> #stepToHome: for further explanations."
	
	^ self new
		exception: anError;
		signal
]

{ #category : #'priv handling' }
UnhandledError >> defaultAction [
	"The current computation is terminated. The cause of the error should be logged or reported to the user. If the program is operating in an interactive debugging environment the computation should be suspended and the debugger activated."
	
	^ (Smalltalk classNamed: #ToolSet)
		ifNotNil: [:ts | ts handleError: self exception]
		ifNil: [Processor activeProcess terminate]
]

{ #category : #accessing }
UnhandledError >> exception [

	^ exception
]

{ #category : #accessing }
UnhandledError >> exception: anError [

	exception := anError
]

{ #category : #'priv handling' }
UnhandledError >> isResumable [
	
	^ false
]
