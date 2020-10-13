Class {
	#name : #UnhandledWarning,
	#superclass : #UnhandledError,
	#category : #'Kernel-Exceptions'
}

{ #category : #'priv handling' }
UnhandledWarning >> defaultAction [

	^ (Smalltalk classNamed: #ToolSet)
		ifNotNil: [:ts | ts handleWarning: self exception]
		ifNil: ["Ignore like a Notification." nil]
]
