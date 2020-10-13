"
Halt is provided to support Object>>halt.
"
Class {
	#name : #Halt,
	#superclass : #Exception,
	#category : #'Kernel-Exceptions'
}

{ #category : #'priv handling' }
Halt >> defaultAction [
	"No one has handled this error, but now give them a chance to decide how to debug it.  If none handle this either then open debugger (see UnhandedError-defaultAction)"

	UnhandledError signalForException: self
]

{ #category : #description }
Halt >> isResumable [

	^true
]
