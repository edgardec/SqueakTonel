Class {
	#name : #NonBooleanReceiver,
	#superclass : #Error,
	#instVars : [
		'object'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #signaledException }
NonBooleanReceiver >> isResumable [

	^true
]

{ #category : #accessing }
NonBooleanReceiver >> object [
	^object
]

{ #category : #accessing }
NonBooleanReceiver >> object: anObject [
	object := anObject
]
