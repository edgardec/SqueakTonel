"
An ExceptionSet is a grouping of exception handlers which acts as a single handler.  Within the group, the most recently added handler will be the last handler found during a handler search (in the case where more than one handler in the group is capable of handling a given exception). 
"
Class {
	#name : #ExceptionSet,
	#superclass : #Object,
	#instVars : [
		'exceptions'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #exceptionSelector }
ExceptionSet >> , anException [
	"Return an exception set that contains the receiver and the argument exception. This is commonly used to specify a set of exception selectors for an exception handler."

	self add: anException.
	^self
]

{ #category : #private }
ExceptionSet >> add: anException [

	^exceptions add: anException
]

{ #category : #exceptionSelector }
ExceptionSet >> handles: anException [
	"Determine whether an exception handler will accept a signaled exception."

	exceptions do:
		[:ex |
		(ex handles: anException)
			ifTrue: [^true]].
	^false
]

{ #category : #private }
ExceptionSet >> initialize [

	exceptions := OrderedCollection new
]
