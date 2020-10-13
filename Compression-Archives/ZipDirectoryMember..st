"
ZipFileMember instances represent directories inside ZipArchives.
They don't do much other than hold names and permissions (and extra fields).

You can add files in subdirectories to a ZipArchive without using any ZipDirectoryMembers.
"
Class {
	#name : #ZipDirectoryMember,
	#superclass : #ZipFileMember,
	#category : #'Compression-Archives'
}

{ #category : #'as yet unclassified' }
ZipDirectoryMember class >> newNamed: aFileName [
	^(self new) localFileName: aFileName; yourself
]

{ #category : #private }
ZipDirectoryMember >> asDirectory [
	^self
]

{ #category : #accessing }
ZipDirectoryMember >> desiredCompressionMethod: aNumber [
]

{ #category : #initialization }
ZipDirectoryMember >> initialize [
	super initialize.
	super desiredCompressionMethod: CompressionStored.
]

{ #category : #testing }
ZipDirectoryMember >> isDirectory [
	^true
]

{ #category : #accessing }
ZipDirectoryMember >> localFileName: aString [
	| dir entry parent fsPath |
	super localFileName: aString.
	fileName last = $/ ifFalse: [ fileName := fileName, '/' ].
	parent := FileDirectory default.
	aString last = parent pathNameDelimiter
		ifTrue: [fsPath := parent fullNameFor: aString]
		ifFalse: [fsPath := parent fullNameFor: aString, parent slash].
	(parent directoryExists: fsPath) ifTrue: [
		dir := FileDirectory on: fsPath.
		entry := dir directoryEntry.
		self setLastModFileDateTimeFrom: entry modificationTime
	]

]

{ #category : #private }
ZipDirectoryMember >> rewindData [
]

{ #category : #testing }
ZipDirectoryMember >> usesFileNamed: aName [
	^false
]

{ #category : #private }
ZipDirectoryMember >> writeDataTo: aStream [
       "Write nothing. Directories have no contents to write."
]
