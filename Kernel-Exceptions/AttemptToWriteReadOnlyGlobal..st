"
This is a resumable error you get if you try to assign a readonly variable a value.
Name definitions in the module system can be read only and are then created using instances of ReadOnlyVariableBinding instead of Association.
See also LookupKey>>beReadWriteBinding and LookupKey>>beReadOnlyBinding.


"
Class {
	#name : #AttemptToWriteReadOnlyGlobal,
	#superclass : #Error,
	#category : #'Kernel-Exceptions'
}

{ #category : #'as yet unclassified' }
AttemptToWriteReadOnlyGlobal >> description [
	"Return a textual description of the exception."

	| desc mt |
	desc := 'Error'.
	^(mt := self messageText) == nil
		ifTrue: [desc]
		ifFalse: [desc, ': ', mt]
]

{ #category : #'as yet unclassified' }
AttemptToWriteReadOnlyGlobal >> isResumable [
	^true
]
