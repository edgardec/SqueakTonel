"
This class is private to the EHS implementation.  Its use allows for ensured execution to survive code such as:

[self doThis.
^nil]
	ensure: [self doThat]

Signaling or handling this exception is not recommended.
"
Class {
	#name : #BlockCannotReturn,
	#superclass : #Error,
	#instVars : [
		'result',
		'deadHome'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #accessing }
BlockCannotReturn >> deadHome [

	^ deadHome
]

{ #category : #accessing }
BlockCannotReturn >> deadHome: context [

	deadHome := context
]

{ #category : #exceptionDescription }
BlockCannotReturn >> defaultAction [

	self messageText: 'Block cannot return'.
	^super defaultAction
]

{ #category : #exceptionDescription }
BlockCannotReturn >> isResumable [

	^true
]

{ #category : #accessing }
BlockCannotReturn >> result [

	^result
]

{ #category : #accessing }
BlockCannotReturn >> result: r [

	result := r
]
