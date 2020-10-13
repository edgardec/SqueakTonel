Class {
	#name : #MCEmptyPackageInfo,
	#superclass : #PackageInfo,
	#category : #'Tests-Monticello-Utils'
}

{ #category : #'as yet unclassified' }
MCEmptyPackageInfo class >> initialize [
	[self new register] on: MessageNotUnderstood do: []
]

{ #category : #'as yet unclassified' }
MCEmptyPackageInfo class >> wantsChangeSetLogging [
	^ false
]

{ #category : #listing }
MCEmptyPackageInfo >> classes [
	^ #()
]

{ #category : #listing }
MCEmptyPackageInfo >> methods [
	^ #()
]

{ #category : #naming }
MCEmptyPackageInfo >> packageName [
	^ 'MCEmptyPackage'
]
