Class {
	#name : #MCMockDefinition,
	#superclass : #MCDefinition,
	#instVars : [
		'token'
	],
	#category : #'Tests-Monticello-Utils'
}

{ #category : #'as yet unclassified' }
MCMockDefinition class >> token: aString [

	^ self new token: aString
]

{ #category : #'as yet unclassified' }
MCMockDefinition class >> wantsChangeSetLogging [
	^ false
]

{ #category : #comparing }
MCMockDefinition >> = definition [
	^definition token = token
]

{ #category : #converting }
MCMockDefinition >> asString [

	^ token
]

{ #category : #comparing }
MCMockDefinition >> description [

	^ token first
]

{ #category : #comparing }
MCMockDefinition >> hash [

	^ token hash
]

{ #category : #printing }
MCMockDefinition >> printString [

	^ token
]

{ #category : #printing }
MCMockDefinition >> summary [

	^ token
]

{ #category : #accessing }
MCMockDefinition >> token [

	^ token
]

{ #category : #accessing }
MCMockDefinition >> token: aString [

	token := aString
]
