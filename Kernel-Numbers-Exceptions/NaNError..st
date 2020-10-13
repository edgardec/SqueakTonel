"
NaNError is signaled by various operations that would either result in or operate on an NaN input.
"
Class {
	#name : #NaNError,
	#superclass : #ArithmeticError,
	#category : #'Kernel-Numbers-Exceptions'
}

{ #category : #testing }
NaNError >> isResumable [
	"NaNError is always resumable"
	^true
]

{ #category : #accessing }
NaNError >> messageText [
	"Return an exception's message text."

	^messageText ifNil:['This operation would result in NaN ']
]
