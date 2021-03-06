"
ZipNewFileMember instances are used to represent files that are going to be written to a ZipArchive.
Their data comes from external file streams.
"
Class {
	#name : #ZipNewFileMember,
	#superclass : #ZipArchiveMember,
	#instVars : [
		'externalFileName',
		'stream'
	],
	#category : #'Compression-Archives'
}

{ #category : #'instance creation' }
ZipNewFileMember class >> newNamed: aFileName [
	^(self new) from: aFileName
]

{ #category : #initialization }
ZipNewFileMember >> close [
	stream ifNotNil:[stream close].
]

{ #category : #initialization }
ZipNewFileMember >> from: aFileName [
	| entry |
	compressionMethod := CompressionStored.
	"Now get the size, attributes, and timestamps, and see if the file exists"
	stream := StandardFileStream readOnlyFileNamed: aFileName.
	self localFileName: (externalFileName := stream name).
	entry := stream directoryEntry.
	compressedSize := uncompressedSize := entry fileSize.
	desiredCompressionMethod := compressedSize > 0 ifTrue: [ CompressionDeflated ] ifFalse: [ CompressionStored ].
	self setLastModFileDateTimeFrom: entry modificationTime.
	stream close
]

{ #category : #initialization }
ZipNewFileMember >> initialize [
	super initialize.
	externalFileName := ''.
]

{ #category : #'private-writing' }
ZipNewFileMember >> openStreamWhile: aBlock [ 
	stream open.
	^ aBlock ensure: [ stream close ]
]

{ #category : #private }
ZipNewFileMember >> readRawChunk: n [
	^stream next: n
]

{ #category : #'private-writing' }
ZipNewFileMember >> rewindData [
	super rewindData.
	readDataRemaining := stream size.
	stream position: 0.
]

{ #category : #testing }
ZipNewFileMember >> usesFileNamed: aFileName [
	"Do I require aFileName? That is, do I care if it's clobbered?"
	^(FileDirectory default fullNameFor: externalFileName) = (FileDirectory default fullNameFor: aFileName)
]
