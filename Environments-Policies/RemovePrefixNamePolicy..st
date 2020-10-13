Class {
	#name : #RemovePrefixNamePolicy,
	#superclass : #NamePolicy,
	#instVars : [
		'prefix'
	],
	#category : #'Environments-Policies'
}

{ #category : #'instance creation' }
RemovePrefixNamePolicy class >> prefix: aString [
	^ self basicNew initializeWithPrefix: aString
]

{ #category : #'initialize-release' }
RemovePrefixNamePolicy >> initializeWithPrefix: aString [
	self initialize.
	prefix := aString
]

{ #category : #naming }
RemovePrefixNamePolicy >> name: aSymbol do: aBlock [
	^ (aSymbol beginsWith: prefix) 
		ifTrue: [aBlock value: (aSymbol allButFirst: prefix size) asSymbol]
]
