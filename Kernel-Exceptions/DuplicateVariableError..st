"
DuplicateVariableError is signaled when a (class or instance) variable name is used in both super and subclass.
"
Class {
	#name : #DuplicateVariableError,
	#superclass : #Error,
	#instVars : [
		'superclass',
		'variable'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #testing }
DuplicateVariableError >> isResumable [
	^true
]

{ #category : #accessing }
DuplicateVariableError >> superclass [
	"The superclass in which the variable is defined"
	^superclass
]

{ #category : #accessing }
DuplicateVariableError >> superclass: aClass [
	"The superclass in which the variable is defined"
	superclass := aClass
]

{ #category : #accessing }
DuplicateVariableError >> variable [
	"Name of the duplicate variable"
	^variable
]

{ #category : #accessing }
DuplicateVariableError >> variable: aString [
	"Name of the duplicate variable"
	variable := aString
]
