"
My subclasses (not instances of them) keep state specific to the current process.

There are two kinds of process-specific variables: process-local (state available
for read and write in all methods inside the process), and dynamic variables
(implementing dynamic scope).
"
Class {
	#name : #ProcessSpecificVariable,
	#superclass : #Object,
	#classInstVars : [
		'hash'
	],
	#category : #'Kernel-Processes-Variables'
}

{ #category : #accessing }
ProcessSpecificVariable class >> default [
	"Answer the default value for the variable. The default for the default value is nil."
	^nil
]

{ #category : #accessing }
ProcessSpecificVariable class >> hash [
	
	^hash ifNil: [ hash := super hash ]
]

{ #category : #accessing }
ProcessSpecificVariable class >> value [
	"Answer the current value for this variable in the current context."
	^Processor activeProcess environmentAt: self ifAbsent: [self default].
]
