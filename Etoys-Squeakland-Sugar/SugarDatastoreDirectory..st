Class {
	#name : #SugarDatastoreDirectory,
	#superclass : #Object,
	#instVars : [
		'query',
		'extension'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #'instance creation' }
SugarDatastoreDirectory class >> mimetype: mimeString extension: extString [
	^self new
		query: ({'mime_type' -> mimeString} as: Dictionary);
		extension: extString
]

{ #category : #'instance creation' }
SugarDatastoreDirectory class >> query: aDictionaryOrString [
	^self new query: aDictionaryOrString
]

{ #category : #testing }
SugarDatastoreDirectory >> acceptsUploads [
	"answer whatever the receiver accepts uploads"
	^ true
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> assureExistence [
	"Make sure the current directory exists. If necessary, create all parts inbetween"
	
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> createDirectory: localName [ 
	"Create a new sub directory within the current one"
	^ self inform: 'operation not supported' translated
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> deleteDirectory: localName [
	"Delete the sub directory within the current one.  Call needs to ask user to confirm."
	^ self inform: 'operation not supported' translated
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> deleteFileNamed: localFileName [ 
	"Delete the file with the given name in this directory."
	^ self inform: 'Use the journal to delete entries' translated
]

{ #category : #accessing }
SugarDatastoreDirectory >> directories [
	"No hierarchies in datastore - otherwise the path parts"
	^#()
]

{ #category : #accessing }
SugarDatastoreDirectory >> directory [
	"No hierarchies in datastore"
	^''
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> directoryNamed: aString [ 
	"Return the subdirectory of this directory with the given name."
	^ self halt
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> directoryNames [
	"Return a collection of names for the subdirectories of this directory. "
	^ #()
]

{ #category : #accessing }
SugarDatastoreDirectory >> directoryWrapperClass [
	"answer the class to be used as a wrapper in FileList2"
	^ FileDirectoryWrapper
]

{ #category : #accessing }
SugarDatastoreDirectory >> downloadUrl [
	"The url under which files will be accessible - ending in a slash"
	^'sugar:///'
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> entries [
	"Return a collection of directory entries for the files and 
	directories in this directory."

	^(SugarLauncher current
		findJournalEntries: self query properties: #('uid' 'title' 'ctime' 'mtime' 'file-size'))
		collect: [:props |
			props keysAndValuesDo: [:key :value | props at: key put: value asString].
			DirectoryEntry
				name: (((props at: 'title') copyReplaceAll: '/' with: '\') contractTo: 64) utf8ToSqueak, '-', (props at: 'uid'), self extension
				creationTime: ([(DateAndTime fromString: (props at: 'ctime')) asSeconds] ifError: [0])
				modificationTime: ([(DateAndTime fromString: (props at: 'mtime')) asSeconds] ifError: [0])
				isDirectory: false
				fileSize: (props at: 'file-size' ifAbsent: [42])
		]
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> exists [
	^SugarLauncher isRunningInSugar
]

{ #category : #accessing }
SugarDatastoreDirectory >> extension [
	^extension ifNil: ['']
]

{ #category : #accessing }
SugarDatastoreDirectory >> extension: aString [
	extension := aString
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> fileAndDirectoryNames [
	"Return a collection of names for all files and directories in this directory."
	^ self entries collect: [:entry | entry name]
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> fileExists: fileName [
	^ self fileNames includes: fileName
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> fileNames [
	"Return a collection of names for the files (but not directories) in this directory."
	^ self entries collect: [:entry | entry name]
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> fullNameFor: aString [
	^aString
]

{ #category : #accessing }
SugarDatastoreDirectory >> groupName [

	^self moniker
]

{ #category : #testing }
SugarDatastoreDirectory >> hasEToyUserList [
	^false
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> includesKey: localName [
	"Answer true if this directory includes a file or directory of the given name. Note that the name should be a local file name, in contrast with fileExists:, which takes either local or full-qualified file names."

	^ self fileAndDirectoryNames includes: localName

]

{ #category : #testing }
SugarDatastoreDirectory >> isProjectSwiki [
	"answer whatever the receiver is a project swiki"
	^ true
]

{ #category : #testing }
SugarDatastoreDirectory >> isRemoteDirectory [
	"answer whatever the receiver is a remote directory"
	^ false
]

{ #category : #testing }
SugarDatastoreDirectory >> isSearchable [
	"answer whatever the receiver is searchable super-swiki"
	^false
]

{ #category : #accessing }
SugarDatastoreDirectory >> moniker [
	"a plain language name for this directory"
	^ 'Journal' translated
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> newFileNamed: localName [ 
	^ self notYetImplemented 
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> oldFileNamed: aName [
	^ self readOnlyFileNamed: aName
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> oldFileOrNoneNamed: aName [
	^ self readOnlyFileNamed: aName
]

{ #category : #accessing }
SugarDatastoreDirectory >> pathName [
	^self downloadUrl
]

{ #category : #accessing }
SugarDatastoreDirectory >> pathParts [
	"No hierarchies in datastore"
	^#()
]

{ #category : #accessing }
SugarDatastoreDirectory >> query [
	^query ifNil: ['']
]

{ #category : #accessing }
SugarDatastoreDirectory >> query: aDictionaryOrString [
	query := aDictionaryOrString
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> readOnlyFileNamed: aName [ 
	"aName contains the object id as last 36 chars before the extension"
	| id |
	id := (aName allButLast: self extension size) last: 36.
	^SugarLauncher current getFile: id.

]

{ #category : #accessing }
SugarDatastoreDirectory >> realUrl [
	"a fully expanded version of the url we represent, but without final slash"
	^ String streamContents: [:stream |
			stream nextPutAll: 'sugar:///'.
			query ifNotNil: [
				stream nextPutAll: '?'.
				query isString
					ifTrue: [stream nextPutAll: query encodeForHTTP]
					ifFalse: [query associations sort
						do: [:each | stream
							nextPutAll: each key encodeForHTTP;
							nextPut: $=;
							nextPutAll: each value encodeForHTTP]
						separatedBy: [stream nextPut: $&]]]]
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> rename: fullName toBe: newName [ 
	"Rename a remote file. fullName is just be a fileName, or can 
	be directory path that includes name of the server. newName 
	is just a fileName"
	^ self inform: 'operation not supported' translated
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> reset [
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> sleep [
	"Leave the FileList window."
	^ self
]

{ #category : #'file directory' }
SugarDatastoreDirectory >> wakeUp [
	"Entering a FileList window"
	^ self
]

{ #category : #projects }
SugarDatastoreDirectory >> writeProject: aProject inFileNamed: fileNameString fromDirectory: localDirectory [ 
	"write aProject (a file version can be found in the file named fileNameString in localDirectory)"

	SugarLauncher current
		makeJournalEntryFor: aProject
		filename: (localDirectory fullNameFor: fileNameString)
		mimetype: 'application/x-squeak-project'.
	^true
]
