Class {
	#name : #HTTPServerDirectory,
	#superclass : #ProjectSwikiServer,
	#category : #'Network-RemoteDirectory'
}

{ #category : #accessing }
HTTPServerDirectory >> dirListUrl [
	| listURL |
	listURL := self altUrl
				ifNil: [^ nil].
	^ listURL last ~= $/
		ifTrue: [listURL , '/']
		ifFalse: [listURL]
]

{ #category : #accessing }
HTTPServerDirectory >> directoryNamed: localFileName [
	| newDir |
	newDir := super directoryNamed: localFileName.
	newDir altUrl: (self altUrl , '/' , localFileName).
	^newDir
]

{ #category : #'file directory' }
HTTPServerDirectory >> directoryNames [
	| dirNames projectNames entries |
	"Return a collection of names for the subdirectories of this directory but filter out project directories."

	entries := self entries.
	dirNames := (entries select: [:entry | entry isDirectory])
		collect: [:entry | entry name].
	projectNames := Set new.
	entries do: [:entry | 
		(entry isDirectory not
			and: ['*.pr' match: entry name])
			ifTrue: [projectNames add: (entry name copyFrom: 1 to: entry name size - 3)]].
	^dirNames reject: [:each | projectNames includes: each]

]

{ #category : #'file directory' }
HTTPServerDirectory >> entries [ 
	| answer ftpEntries |
	answer := HTTPSocket httpGetDocument: self dirListUrl.
	answer isString
		ifTrue: [^self error: 'Listing failed: ' , answer]
		ifFalse: [answer := answer content].
	answer first = $<
		ifTrue: [self error: 'Listing failed: ' , answer].
	ftpEntries := answer lines.
	^ ftpEntries 
		collect:[:ftpEntry | self class parseFTPEntry: ftpEntry]
		thenSelect: [:entry | entry notNil]
]

{ #category : #'file directory' }
HTTPServerDirectory >> fileNames [
	"Return a collection of names for the files (but not directories) in this directory."
	"(ServerDirectory serverNamed: 'UIUCArchive') fileNames"

	self dirListUrl
		ifNil: [^self error: 'No URL set for fetching the directory listing.'	].
	^(self entries select: [:entry | entry isDirectory not])
		collect: [:entry | entry name]

]

{ #category : #'file directory' }
HTTPServerDirectory >> oldFileNamed: aName [

	|  contents |
	contents := HTTPLoader default retrieveContentsFor: (self altUrl , '/' , aName).
	^(SwikiPseudoFileStream with: contents content)
		reset;
		directory: self;
		localName: aName;
		yourself

]

{ #category : #'file directory' }
HTTPServerDirectory >> pathName [
	"Path name as used in reading the file.  with slashes for ftp, with local file delimiter (:) for a file: url"

	urlObject ifNotNil: [^ urlObject pathForFile].
	directory size = 0 ifTrue: [^ server].
	^(directory at: 1) = self pathNameDelimiter
		ifTrue: [server, directory]
		ifFalse: [user
			ifNil: [server, self pathNameDelimiter asString, directory]
			ifNotNil: [user, '@', server, self pathNameDelimiter asString, directory]]
]

{ #category : #'file directory' }
HTTPServerDirectory >> readOnlyFileNamed: aName [

	^self oldFileNamed: aName
]

{ #category : #accessing }
HTTPServerDirectory >> typeForPrefs [

	^'http'
]
