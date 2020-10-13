Class {
	#name : #MCWriteOnlyRepository,
	#superclass : #MCRepository,
	#category : #'Monticello-Repositories'
}

{ #category : #versions }
MCWriteOnlyRepository >> includesVersionNamed: aString [
	^ false
]

{ #category : #'user interface' }
MCWriteOnlyRepository >> morphicOpen: aWorkingCopy [
	self inform: 'This repository is write-only'
]

{ #category : #versions }
MCWriteOnlyRepository >> versionNamesForPackageNamed: aString [
	"Answer a collection of MCVersionNames whose Package is named aString."
	^{}
]

{ #category : #versions }
MCWriteOnlyRepository >> versionWithInfo: aVersionInfo ifAbsent: aBlock [
	^ aBlock value
]
