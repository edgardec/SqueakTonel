"
SMPersonalObject is the abstract base class for things that belong/are owned by a user account in SqueakMap. Most things are personal objects - but the SMCategories aren't for example.

A personal object has a reference to the SMAccount owning it.
"
Class {
	#name : #SMPersonalObject,
	#superclass : #SMRootedObject,
	#instVars : [
		'owner'
	],
	#category : #'SMBase-domain'
}

{ #category : #deletion }
SMPersonalObject >> delete [
	"Disconnect from owner."

	super delete.
	owner removeObject: self
]

{ #category : #accessing }
SMPersonalObject >> owner [
	^owner
]

{ #category : #accessing }
SMPersonalObject >> owner: anAccount [
	owner := anAccount
]
