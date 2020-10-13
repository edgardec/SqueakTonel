"
A MCSnapshot is a snapshot of an MCPackage. It is a collection of MCDefinitions.


"
Class {
	#name : #MCSnapshot,
	#superclass : #Object,
	#instVars : [
		'definitions'
	],
	#category : #'Monticello-Base'
}

{ #category : #'as yet unclassified' }
MCSnapshot class >> empty [
	^ self fromDefinitions: #()
]

{ #category : #'as yet unclassified' }
MCSnapshot class >> fromDefinitions: aCollection [
	^ self new initializeWithDefinitions: aCollection
]

{ #category : #accessing }
MCSnapshot >> = other [
	self == other ifTrue: [ ^ true ].
	self species = other species ifFalse: [ ^ false ].
	^ definitions asArray = other definitions asArray
]

{ #category : #accessing }
MCSnapshot >> definitions [
	^ definitions
]

{ #category : #accessing }
MCSnapshot >> hash [
	^ definitions asArray hash
]

{ #category : #initializing }
MCSnapshot >> initializeWithDefinitions: aCollection [
	definitions := aCollection.
]

{ #category : #loading }
MCSnapshot >> install [
	MCPackageLoader installSnapshot: self
]

{ #category : #patching }
MCSnapshot >> patchRelativeToBase: aSnapshot [
	^ MCPatch fromBase: aSnapshot target: self
]

{ #category : #loading }
MCSnapshot >> updatePackage: aPackage [
	MCPackageLoader updatePackage: aPackage withSnapshot: self
]
