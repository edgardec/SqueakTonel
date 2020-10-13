Class {
	#name : #AddPrefixNamePolicy,
	#superclass : #NamePolicy,
	#instVars : [
		'prefix'
	],
	#category : #'Environments-Policies'
}

{ #category : #'instance creation' }
AddPrefixNamePolicy class >> prefix: aString [
	^ self basicNew initializeWithPrefix: aString
]

{ #category : #'initialize-release' }
AddPrefixNamePolicy >> initializeWithPrefix: aString [
	self initialize.
	prefix := aString
]

{ #category : #naming }
AddPrefixNamePolicy >> name: aSymbol do: aBlock [
	^ (aSymbol beginsWith: prefix) ifFalse: 
		[aBlock value: (prefix, aSymbol) asSymbol].
	
]
