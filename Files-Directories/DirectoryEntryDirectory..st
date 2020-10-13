"
an entry in a directory; a reference to a directory.
"
Class {
	#name : #DirectoryEntryDirectory,
	#superclass : #DirectoryEntry,
	#category : #'Files-Directories'
}

{ #category : #access }
DirectoryEntryDirectory >> / aString [ 
	^ self asFileDirectory / aString
]

{ #category : #convert }
DirectoryEntryDirectory >> asFileDirectory [
	"Answer a FileDirectory representing the same directory I represent."

	^directory on: (directory fullNameFor: name)
]

{ #category : #'file operations' }
DirectoryEntryDirectory >> assureAbsence [
	self asFileDirectory assureAbsence
]

{ #category : #'file operations' }
DirectoryEntryDirectory >> copyHere: aDirectoryEntryFile [
	"Copy aDirectoryFileEntry, which represents a file, to the directory I represent."
	^ self asFileDirectory copyHere: aDirectoryEntryFile
]

{ #category : #'file operations' }
DirectoryEntryDirectory >> delete [
	self asFileDirectory recursiveDelete
]

{ #category : #access }
DirectoryEntryDirectory >> directorySize [

	| size |
	size := 0.
	self asFileDirectory entriesDo: [ :entry |
		entry isDirectory
			ifTrue: [ size := size + entry directorySize ]
			ifFalse:[ size := size + entry fileSize ] ].
	^size
]

{ #category : #enumeration }
DirectoryEntryDirectory >> directoryTreeDo: oneArgBlock [
	self asFileDirectory directoryTreeDo: oneArgBlock
]

{ #category : #testing }
DirectoryEntryDirectory >> isDirectory [
	"whether this entry represents a directory, it does."
	^ true
]
