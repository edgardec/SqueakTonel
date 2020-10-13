Class {
	#name : #MCPackageCache,
	#superclass : #Object,
	#instVars : [
		'sorter',
		'fileNames'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #'instance creation' }
MCPackageCache class >> new [
	^ self basicNew initialize
]

{ #category : #'initialize-release' }
MCPackageCache >> initialize [
	sorter := MCVersionSorter new.
	fileNames := Dictionary new.
]

{ #category : #recording }
MCPackageCache >> recordVersionInfo: aVersionInfo forFileNamed: aString [
	Transcript cr; show: aString.
	fileNames at: aVersionInfo put: aString.
	sorter addVersionInfo: aVersionInfo
]

{ #category : #accessing }
MCPackageCache >> versionInfos [
	^ sorter sortedVersionInfos 
]
