Class {
	#name : #DirectoryEntryFile,
	#superclass : #DirectoryEntry,
	#category : #'Files-Directories'
}

{ #category : #contents }
DirectoryEntryFile >> contentsFrom: startPosition to: endPosition [ 
	"Answer my contents from startPosition to endPosition."
	^ FileStream 
		detectFile: self readStream
		do: 
			[ : stream | 
			stream
				position: startPosition ;
				next: endPosition - startPosition + 1 ]
]

{ #category : #contents }
DirectoryEntryFile >> contentsTo: endPosition [ 
	"Answer my contents up to endPosition."
	^ self 
		contentsFrom: 0
		to: endPosition
]

{ #category : #'file operations' }
DirectoryEntryFile >> copyTo: targetDirectory [ 
	"Make a copy of me in targetDirectory.  targetDirectory can be a FileDirectory, ServerDirectory or a DirectoryEntryDirectory.  If a file with my name already exists in targetDirectory, signal a FileExistsException."
	^ targetDirectory copyHere: self
]

{ #category : #'file operations' }
DirectoryEntryFile >> delete [
	directory deleteFileNamed: self name
]

{ #category : #enumeration }
DirectoryEntryFile >> directoryTreeDo: oneArgBlock [
	oneArgBlock value: (OrderedCollection with: self)
]

{ #category : #testing }
DirectoryEntryFile >> isDirectory [
	"whether this entry represents a directory, it does not."
	^ false
]

{ #category : #'stream access' }
DirectoryEntryFile >> readStream [
	"Answer a FileStream on my contents that can be read, but not written."
	^ directory readOnlyFileNamed: self name
]

{ #category : #'stream access' }
DirectoryEntryFile >> readStreamDo: aBlock [ 
	"Open a read stream on my contents and answer the value of aBlock with it, ensuring the stream is closed."
	^ FileStream
		detectFile: self readStream
		do: aBlock
]

{ #category : #'stream access' }
DirectoryEntryFile >> readWriteStream [
	"Answer a FileStream on my contents that can be read and written."
	^ directory fileNamed: self name
]

{ #category : #'stream access' }
DirectoryEntryFile >> readWriteStreamDo: aBlock [ 
	"Open a read-write stream on my contents and answer the value of aBlock with it, ensuring the stream is closed."
	^ FileStream
		detectFile: self readWriteStream
		do: aBlock
]
