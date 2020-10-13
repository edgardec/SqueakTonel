"
This is the abstract superclass for file archives. Archives can be read from or written to files, and contain members that represent files and directories.
"
Class {
	#name : #Archive,
	#superclass : #Object,
	#instVars : [
		'members'
	],
	#category : #'Compression-Archives'
}

{ #category : #'archive operations' }
Archive >> addDirectory: aFileName [
	^self addDirectory: aFileName as: aFileName

]

{ #category : #'archive operations' }
Archive >> addDirectory: aFileName as: anotherFileName [
	| newMember |
	newMember := self memberClass newFromDirectory: aFileName.
	self addMember: newMember.
	newMember localFileName: anotherFileName.
	^newMember
]

{ #category : #'archive operations' }
Archive >> addFile: aFileName [
	^self addFile: aFileName as: aFileName
]

{ #category : #'archive operations' }
Archive >> addFile: aFileName as: anotherFileName [
	| newMember |
	newMember := self memberClass newFromFile: aFileName.
	self addMember: newMember.
	newMember localFileName: anotherFileName.
	^newMember
]

{ #category : #'archive operations' }
Archive >> addMember: aMember [
	^members addLast: aMember
]

{ #category : #'archive operations' }
Archive >> addString: aString as: aFileName [
	| newMember |
	newMember := self memberClass newFromString: aString named: aFileName.
	self addMember: newMember.
	newMember localFileName: aFileName.
	^newMember
]

{ #category : #'archive operations' }
Archive >> addTree: aFileNameOrDirectory match: aBlock [ 
	| nameSize |
	nameSize := aFileNameOrDirectory isString
				ifTrue: [aFileNameOrDirectory size]
				ifFalse: [aFileNameOrDirectory pathName size].
	^ self
		addTree: aFileNameOrDirectory
		removingFirstCharacters: nameSize + 1
		match: aBlock
]

{ #category : #'archive operations' }
Archive >> addTree: aFileNameOrDirectory removingFirstCharacters: n [ 
	^ self
		addTree: aFileNameOrDirectory
		removingFirstCharacters: n
		match: [:e | true]
]

{ #category : #'archive operations' }
Archive >> addTree: aFileNameOrDirectory removingFirstCharacters: n match: aBlock [
	| dir fullPath relativePath |
	dir := (aFileNameOrDirectory isString)
		ifTrue: [ FileDirectory on: aFileNameOrDirectory ]
		ifFalse: [ aFileNameOrDirectory ].
	fullPath := dir pathName, dir slash.
	relativePath := fullPath copyFrom: n + 1 to: fullPath size.
	(dir entries select: aBlock)
		do: [ :ea | | fullName newMember |
		fullName := fullPath, ea name.
		newMember := ea isDirectory
				ifTrue: [ self memberClass newFromDirectory: fullName ]
				ifFalse: [ self memberClass newFromFile: fullName ].
		newMember localFileName: relativePath, ea name.
		self addMember: newMember.
		ea isDirectory ifTrue: [ self addTree: fullName removingFirstCharacters: n match: aBlock].
	].

]

{ #category : #'archive operations' }
Archive >> canWriteToFileNamed: aFileName [
	"Catch attempts to overwrite existing zip file"
	^members noneSatisfy: [ :ea | ea usesFileNamed: aFileName ].

]

{ #category : #'archive operations' }
Archive >> contentsOf: aMemberOrName [
	| member |
	member := self member: aMemberOrName.
	member ifNil: [ ^nil ].
	^member contents
]

{ #category : #'archive operations' }
Archive >> extractMember: aMemberOrName [
	| member |
	member := self member: aMemberOrName.
	member ifNil: [ ^nil ].
	member extractToFileNamed: member localFileName inDirectory: FileDirectory default.
]

{ #category : #'archive operations' }
Archive >> extractMember: aMemberOrName toFileNamed: aFileName [
	| member |
	member := self member: aMemberOrName.
	member ifNil: [ ^nil ].
	member extractToFileNamed: aFileName
]

{ #category : #'archive operations' }
Archive >> extractMemberWithoutPath: aMemberOrName [
	self extractMemberWithoutPath: aMemberOrName inDirectory: FileDirectory default.
]

{ #category : #'archive operations' }
Archive >> extractMemberWithoutPath: aMemberOrName inDirectory: dir [
	| member |
	member := self member: aMemberOrName.
	member ifNil: [ ^nil ].
	member extractToFileNamed: (FileDirectory localNameFor: member localFileName) inDirectory: dir
]

{ #category : #initialization }
Archive >> initialize [
	members := OrderedCollection new.
]

{ #category : #private }
Archive >> member: aMemberOrName [
	^(members includes: aMemberOrName)
		ifTrue: [ aMemberOrName ]
		ifFalse: [ self memberNamed: aMemberOrName ].
]

{ #category : #private }
Archive >> memberClass [
	self subclassResponsibility
]

{ #category : #'archive operations' }
Archive >> memberNamed: aString [
	"Return the first member whose zip name or local file name matches aString, or nil"
	^members detect: [ :ea | ea fileName = aString or: [ ea localFileName = aString ]] ifNone: [ ]
]

{ #category : #'archive operations' }
Archive >> memberNames [
	^members collect: [ :ea | ea fileName ]
]

{ #category : #'archive operations' }
Archive >> members [
	^members
]

{ #category : #'archive operations' }
Archive >> membersMatching: aString [
	^members select: [ :ea | (aString match: ea fileName) or: [ aString match: ea localFileName ] ]
]

{ #category : #'archive operations' }
Archive >> numberOfMembers [
	^members size
]

{ #category : #'archive operations' }
Archive >> removeMember: aMemberOrName [
	| member |
	member := self member: aMemberOrName.
	member ifNotNil: [ members remove: member ].
	^member
]

{ #category : #'archive operations' }
Archive >> replaceMember: aMemberOrName with: newMember [
	| member |
	member := self member: aMemberOrName.
	member ifNotNil: [ members replaceAll: member with: newMember ].
	^member
]

{ #category : #'archive operations' }
Archive >> setContentsOf: aMemberOrName to: aString [
	| newMember oldMember |
	oldMember := self member: aMemberOrName.
	newMember := (self memberClass newFromString: aString named: oldMember fileName)
		copyFrom: oldMember.
	self replaceMember: oldMember with: newMember.
]

{ #category : #'archive operations' }
Archive >> writeTo: aStream [
	self subclassResponsibility
]

{ #category : #'archive operations' }
Archive >> writeToFileNamed: aFileName [
	| stream |
	"Catch attempts to overwrite existing zip file"
	(self canWriteToFileNamed: aFileName)
		ifFalse: [ ^self error: (aFileName, ' is needed by one or more members in this archive') ].
	stream := StandardFileStream forceNewFileNamed: aFileName.
	self writeTo: stream.
	stream close.
]
