"
an entry in a directory; a reference to either a file or a directory.
"
Class {
	#name : #DirectoryEntry,
	#superclass : #Object,
	#instVars : [
		'directory',
		'name',
		'creationTime',
		'modificationTime',
		'fileSize',
		'attributes'
	],
	#category : #'Files-Directories'
}

{ #category : #'instance creation' }
DirectoryEntry class >> directory: aFileDirectoryOrServerDirectory name: name0 creationTime: creationTime modificationTime: modificationTime fileSize: fileSize [ 
	^ self new 
		setDirectory: aFileDirectoryOrServerDirectory
		name: name0
		creationTime: creationTime
		modificationTime: modificationTime
		fileSize: fileSize
]

{ #category : #'instance creation' }
DirectoryEntry class >> fromArray: array directory: aFileDirectoryOrServerDirectory [ 
	| entryType |
	entryType := (array at: 4) 
		ifTrue: [ DirectoryEntryDirectory ]
		ifFalse: [ DirectoryEntryFile ].
	^ entryType 
		directory: aFileDirectoryOrServerDirectory
		name: (array at: 1)
		creationTime: (array at: 2)
		modificationTime: (array at: 3)
		fileSize: (array at: 5)
]

{ #category : #testing }
DirectoryEntry >> = aDirectoryEntry [ 
	"Answer whether I am equivalent in all of my file-system attributes."
	super = aDirectoryEntry ifTrue: [^ true].
	self species = aDirectoryEntry species ifFalse: [^ false].
	^ self containingDirectory = aDirectoryEntry containingDirectory
		and: [self name = aDirectoryEntry name
				and: [self modificationTime = aDirectoryEntry modificationTime
						and: [self fileSize = aDirectoryEntry fileSize]]]
]

{ #category : #converting }
DirectoryEntry >> asDirectoryEntry [
	^ self
]

{ #category : #access }
DirectoryEntry >> at: index [
	"compatibility interface"
	self deprecated: 'old-style access to DirectoryEntry'.
	index = 1 ifTrue: [ ^self name ].
	index = 2 ifTrue: [ ^self creationTime ].
	index = 3 ifTrue: [ ^self modificationTime ].
	index = 4 ifTrue:[ ^self isDirectory ].
	index = 5 ifTrue:[ ^self fileSize ].
	self error: 'invalid index specified'.

]

{ #category : #access }
DirectoryEntry >> attributeNamed: aString ifAbsent: oneArgBlock [ 
	"Answer the value of attribute named aString.  If no attribute by that name has ever been set, answer oneArgBlock value."
	^ self attributes 
		at: aString
		ifAbsent: oneArgBlock
]

{ #category : #access }
DirectoryEntry >> attributeNamed: aString put: anObject [
	"Set the value of attribute named aString.  This is provided for extension by third-party developers."
	^ self attributes 
		at: aString
		put: anObject
]

{ #category : #'private-initialization' }
DirectoryEntry >> attributes [
	^ attributes ifNil: [ attributes := Dictionary new ]
]

{ #category : #access }
DirectoryEntry >> baseName [
	^ FileDirectory baseNameFor: self name
]

{ #category : #access }
DirectoryEntry >> containingDirectory [
	"Answer the FileDirectory in which I reside."
	^ directory
]

{ #category : #'multilingual system' }
DirectoryEntry >> convertFromSystemName [

	name := name vmPathToSqueakPath
]

{ #category : #'file operations' }
DirectoryEntry >> copyTo: fileOrServerDirectory [ 
	"Copy me to fileOrServerDirectory."
	self subclassResponsibility
]

{ #category : #access }
DirectoryEntry >> creationDateAndTime [
	"The DateAndTime my entry in the file system was created."
	^DateAndTime fromSeconds: creationTime
]

{ #category : #access }
DirectoryEntry >> creationTime [
	"The time the entry was created, as an Integer number of seconds offset from the DateAndTime epoch."
	^creationTime
]

{ #category : #'file operations' }
DirectoryEntry >> delete [
	"Physically remove from the disk."
	self subclassResponsibility
]

{ #category : #access }
DirectoryEntry >> directorySize [
	"Size of all files in that directory and all its sub-directories."
	
	^ 0
]

{ #category : #access }
DirectoryEntry >> directorySizeString [

	^ self directorySize asBytesDescription	
	
]

{ #category : #enumeration }
DirectoryEntry >> directoryTreeDo: oneArgBlock [
	self subclassResponsibility
]

{ #category : #testing }
DirectoryEntry >> exists [
	^ (self containingDirectory
		entryAt: self name
		ifAbsent: [ nil ]) notNil
]

{ #category : #access }
DirectoryEntry >> extension [
	^ FileDirectory extensionFor: self name
]

{ #category : #access }
DirectoryEntry >> fileSize [
	"size of the entry, if it's a file"
	^fileSize
]

{ #category : #access }
DirectoryEntry >> fileSizeString [
	"Answer my file size as an easy-to-read String."
	^ self fileSize asBytesDescription
]

{ #category : #access }
DirectoryEntry >> fullName [
	"The fully-qualified name.
	 Since this method falls into the equality test, make it safe when directory is nil."
	^ directory 
		ifNotNil: [ directory fullNameFor: self name ] 
		ifNil: [ self name ]
]

{ #category : #testing }
DirectoryEntry >> hash [
	"Hashing on directory + name should be sufficient."
	^ (self containingDirectory hash hashMultiply + self name hash) hashMultiply
]

{ #category : #access }
DirectoryEntry >> isDirectory [
	"whether this entry represents a directory"
	self subclassResponsibility
]

{ #category : #access }
DirectoryEntry >> modificationDateAndTime [
	"The DateAndTime my entry in the file system was last modified."
	^ DateAndTime fromSeconds: modificationTime
]

{ #category : #access }
DirectoryEntry >> modificationTime [
	"time the entry was last modified"
	^modificationTime
]

{ #category : #access }
DirectoryEntry >> name [
	"name of the entry"
	^name
]

{ #category : #access }
DirectoryEntry >> printOn: aStream [ 
	super printOn: aStream.
	aStream
		space ;
		nextPutAll: self name
]

{ #category : #services }
DirectoryEntry >> services [
	"Answer the same collection of SimpleServiceEntry's accessed by the FileList."
	^ FileServices itemsForFile: self fullName
]

{ #category : #'private-initialization' }
DirectoryEntry >> setDirectory: aFileOrServerDirectory [ 
	"Set only my (containing) directory.  This is only needed because I couldn't factor ServerDirectory class>>#parseFTPEntry: to the instance-side (because HTTPClient utility uses it).  Therefore, they pass a nil and then set my 'directory' immediately after.."
	directory := aFileOrServerDirectory
]

{ #category : #'private-initialization' }
DirectoryEntry >> setDirectory: aFileDirectoryOrServerDirectory name: name0  creationTime: creationTime0  modificationTime: modificationTime0 fileSize: fileSize0 [
	directory := aFileDirectoryOrServerDirectory.
	name := name0.
	creationTime := creationTime0.
	modificationTime := modificationTime0.
	fileSize := fileSize0
]

{ #category : #access }
DirectoryEntry >> size [
	"For API compatibility with byte objects (for streaming api)."
	^ self fileSize
]

{ #category : #access }
DirectoryEntry >> splitNameVersionExtension [
	" answer an array with the root name, version # and extension."
	^ self directory splitNameVersionExtensionFor: self name
]
