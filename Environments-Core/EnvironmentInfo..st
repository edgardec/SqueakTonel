Class {
	#name : #EnvironmentInfo,
	#superclass : #Object,
	#instVars : [
		'name',
		'organization',
		'packages'
	],
	#category : #'Environments-Core'
}

{ #category : #create }
EnvironmentInfo class >> name: aString [
	^ self 
		name: aString
		organization: (SystemOrganizer defaultList: Array new)
		packages: PackageOrganizer new.
	
]

{ #category : #create }
EnvironmentInfo class >> name: aString organization: aSystemOrganizer packages: aPackageOrganizer [
	^ self basicNew 
		initializeWithName: aString 
		organization: aSystemOrganizer
		packages: aPackageOrganizer
]

{ #category : #initializing }
EnvironmentInfo >> initializeWithName: aString organization: aSystemOrganizer packages: aPackageOrganizer [
	self initialize.
	name := aString asSymbol.
	organization := aSystemOrganizer.
	packages := aPackageOrganizer.
]

{ #category : #access }
EnvironmentInfo >> name [
	^ name
]

{ #category : #access }
EnvironmentInfo >> organization [
	^ organization
]

{ #category : #access }
EnvironmentInfo >> packages [
	^ packages
]

{ #category : #printing }
EnvironmentInfo >> printOn: aStream [
	aStream nextPutAll: name.
	aStream nextPutAll: 'Info'
]
