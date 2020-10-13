Class {
	#name : #MCSnapshotResource,
	#superclass : #TestResource,
	#instVars : [
		'snapshot'
	],
	#category : #'Tests-Monticello'
}

{ #category : #'as yet unclassified' }
MCSnapshotResource class >> mockPackage [
	^ (MCPackage new name: self mockPackageName)
]

{ #category : #'as yet unclassified' }
MCSnapshotResource class >> mockPackageName [
	^ MCMockPackageInfo new packageName
]

{ #category : #'as yet unclassified' }
MCSnapshotResource class >> takeSnapshot [
	^ self mockPackage snapshot
]

{ #category : #accessing }
MCSnapshotResource >> definitions [
	^ snapshot definitions
]

{ #category : #running }
MCSnapshotResource >> setUp [
	snapshot := self class takeSnapshot.
]

{ #category : #accessing }
MCSnapshotResource >> snapshot [
	^ snapshot
]
