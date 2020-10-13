Class {
	#name : #EtoysError,
	#superclass : #Error,
	#category : #'Etoys-Squeakland-System-Exceptions Kernel'
}

{ #category : #all }
EtoysError >> defaultAction [
	"See Error>>defaultAction for comments."

	EtoysUnhandledError signalForException: self
]

{ #category : #all }
EtoysError >> description [
	"Return a textual description of the exception."

	| desc mt |
	desc := self class name asString.
	^(mt := self messageText) == nil
		ifTrue: [desc]
		ifFalse: [mt copyUpTo: $\]
]
