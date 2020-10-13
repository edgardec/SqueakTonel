Class {
	#name : #MCSnapshotReader,
	#superclass : #MCReader,
	#instVars : [
		'definitions'
	],
	#category : #'Monticello-Storing'
}

{ #category : #converting }
MCSnapshotReader class >> snapshotFromStream: aStream [
	^ (self on: aStream) snapshot
]

{ #category : #loading }
MCSnapshotReader >> definitions [
	definitions ifNil: [self loadDefinitions].
	^ definitions
]

{ #category : #accessing }
MCSnapshotReader >> snapshot [
	^ MCSnapshot fromDefinitions: self definitions
]
