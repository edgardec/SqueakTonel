"
Add support to publish or download projects from Small-Land Project
Repository (SLPR).

The SLPR has virtual folders where the projects appears.  The SLPR can
be acceded from the FileList or from the web interface at
http://repository.small-land.org:8080

Basically it's a type of superswiki (but better ;)).

The features in SMPR not present in SuperSwiki are:

- Both the web interface and the squeak-side interface are full
translatable.   The server has translations for English and Spanish just
now, but it's almost trivial to include other translations... Stef?
Marcus? ;)

- The projects are categorized in ""virtual"" folder.  These folders (By
Category, By Author, By Language, Alphabetical, etc) give us good
searching behaviour just using the FileList and mouse clicks.

- The web interface (also full translatable) has a search a la google.

- All the urls to query the web interface are ""clean enough"" so google
can make a good job indexing our content in .pr files.


It's planned to add ""editing"" features to the web interface to
re-categorize, remove, etc projects.


Enjoy it,

-- 
Diego Gomez Deck
http://www.small-land.org
"
Class {
	#name : #PRServerDirectory,
	#superclass : #Object,
	#instVars : [
		'server',
		'directories'
	],
	#category : #'Network-RemoteDirectory'
}

{ #category : #'instance creation' }
PRServerDirectory class >> fullPath: fullNameString [
	"answer an instance of the receiver on fullName"
	| pathParts |
	pathParts := self pathParts: fullNameString.
	^ self server: pathParts first directories: pathParts allButFirst
]

{ #category : #'instance creation' }
PRServerDirectory class >> pathParts: fullName [ 
	"private - parse fullName in server and directory"
	| url slashPos server directory |
	url := fullName.
	(url beginsWith: 'http://')
		ifTrue: [url := url allButFirst: 7].
	url last = $/
		ifTrue: [url := url allButLast].
	""
	slashPos := url indexOf: $/.
	slashPos isZero
		ifTrue: [^ {'http://' , url}].
	""
	server := url first: slashPos - 1.
	directory := url allButFirst: slashPos.
	""
	^ {'http://' , server. directory}
]

{ #category : #'instance creation' }
PRServerDirectory class >> server: serverString [ 
	"answer a new instance of the receiver on server aString"
	^ self server: serverString directories: #()
]

{ #category : #'instance creation' }
PRServerDirectory class >> server: serverString directories: aCollection [ 
	"answer a new instance of the receiver on server aString"
	^ self new initializeServer: serverString directories: aCollection
]

{ #category : #'instance creation' }
PRServerDirectory class >> server: serverString directory: directoryString [ 
	"answer a new instance of the receiver on server aString"
	^ self new
		initializeServer: serverString
		directories: (directoryString findTokens: '/')
]

{ #category : #testing }
PRServerDirectory >> acceptsUploads [
	"answer whatever the receiver accepts uploads"
	^ true
]

{ #category : #'file directory' }
PRServerDirectory >> createDirectory: localName [ 
	"Create a new sub directory within the current one"
	^ self inform: 'operation not supported' translated
]

{ #category : #'file directory' }
PRServerDirectory >> deleteFileNamed: localFileName [ 
	"Delete the file with the given name in this directory."
	^ self inform: 'operation not supported' translated
]

{ #category : #accessing }
PRServerDirectory >> directories [
	"answer the receiver's directories"
	^ directories
]

{ #category : #accessing }
PRServerDirectory >> directory [
	"answer the receiver's directory"
	| result |
	result := String new writeStream.
	self directories
		do: [:each | result nextPutAll: each]
		separatedBy: [result nextPutAll: self slash].
	^ result contents
]

{ #category : #'file directory' }
PRServerDirectory >> directoryNamed: aString [ 
	"Return the subdirectory of this directory with the given name."
	^ self class server: self server directory: self directory , self slash, aString
]

{ #category : #'file directory' }
PRServerDirectory >> directoryNames [
	"Return a collection of names for the subdirectories of this 
	directory. "
	^ self entries
		select: [:entry | entry isDirectory]
		thenCollect: [:entry | entry name]
]

{ #category : #accessing }
PRServerDirectory >> directoryWrapperClass [
	"answer the class to be used as a wrapper in FileList2"
	^ FileDirectoryWrapper
]

{ #category : #accessing }
PRServerDirectory >> downloadUrl [
	"The url under which files will be accessible."
	^ (self urlFromServer: self server directories: {'programmatic'})
		, self slash
]

{ #category : #'file directory' }
PRServerDirectory >> entries [
	"Return a collection of directory entries for the files and 
	directories in this directory."
	| lines |
	lines := self getLines.
	^ lines isNil
		ifTrue: [#()] ifFalse:[
	
	self parseLines: lines]
]

{ #category : #'file directory' }
PRServerDirectory >> fileNames [
	"Return a collection of names for the files (but not directories) in this directory."
	^ self entries
		select: [:entry | entry isDirectory not]
		thenCollect: [:entry | entry name]
]

{ #category : #'file directory' }
PRServerDirectory >> fullNameFor: aString [ 
"Return a corrected, fully-qualified name for the given file name."
	^ self urlFromServer: self server directories: self directories , {aString}
]

{ #category : #private }
PRServerDirectory >> getFullProjectContents: aString [ 
	"private - get the project content from the server"
	^ self getOnly: nil ofProjectContents: aString
]

{ #category : #private }
PRServerDirectory >> getLines [
	"private - answer a collection of lines with the server response"
	| url lines string |
	url := self urlFromServer: self server directories: {'programmatic'} , self directories.
	url := url , self slash.
	string := Cursor read
				showWhile: [(HTTPSocket httpGetDocument: url) contents].
	(string beginsWith: '--OK--')
		ifFalse: [^ nil].
	lines := OrderedCollection new.
	(string allButFirst: 6)
		linesDo: [:line | lines add: line].

	^ lines
]

{ #category : #'file directory' }
PRServerDirectory >> getOnly: numberOfBytes from: fileNameOnServer [ 
	"Just capture the first numberOfBytes of the file.  
	 
	Goes faster for long files. Return the contents, not a stream."
	| fileName |
	self flag: #todo.
	"use LRUCache"
	fileName := fileNameOnServer
				allButFirst: (fileNameOnServer lastIndexOf: self pathNameDelimiter).
	""
	^ self getOnly: numberOfBytes ofProjectContents: fileName
]

{ #category : #private }
PRServerDirectory >> getOnly: numberOfBytes ofProjectContents: aString [ 
	"private - get numberOfBytes of the project contents"
	| url args contents |
	self flag: #todo.
	"use an LRUCache"
	url := self urlFromServer: self server directories: {'programmatic'. aString}.
	""
	args := numberOfBytes isNil
				ifFalse: ['numberOfBytes=' , numberOfBytes asString].
	""
	contents := Cursor read showWhile: [
			(HTTPSocket httpGetDocument: url args: args) contents].
	""
	(contents beginsWith: '--OK--')
		ifFalse: [^ nil].
	""
	^ contents allButFirst: 6
]

{ #category : #private }
PRServerDirectory >> getPostArgsFromProject: aProject fileNamed: fileNameString fromDirectory: localDirectory [ 
	| args thumbnail uploader |
	args := Dictionary new.

	"args at: 'contents' put: {(localDirectory oldFileNamed: fileNameString) contentsOfEntireFile}."
	args at: 'contents' put: {(StandardFileStream
			readOnlyFileNamed: (localDirectory fullNameFor: fileNameString)) contentsOfEntireFile}.

	args at: 'name' put: {aProject name}.
	args at: 'version' put: {(Project parseProjectFileName: fileNameString) second asString}.
	args at: 'language' put: {aProject naturalLanguage asString}.

	uploader := Utilities authorNamePerSe.
	uploader isEmptyOrNil
		ifTrue: [uploader := Utilities authorInitialsPerSe].
	uploader isEmptyOrNil
		ifFalse: [args at: 'uploader' put: {uploader}].

	self putSmalltalkInfoInto: args.

	thumbnail := self getProjectThumbnail: aProject.
	thumbnail isNil
		ifFalse: [args at: 'thumbnailcontents' put: {thumbnail}].

	self putProjectDetailsFrom: aProject to: args.

	^ args
]

{ #category : #private }
PRServerDirectory >> getPostArgsFromThingsToSearchFor: thingsToSearchForCollection [ 
	| args |
	args := Dictionary new.
	""
	thingsToSearchForCollection
		do: [:each | 
			| pos | 
			pos := each indexOf: $:.
			pos isZero
				ifFalse: [| key value | 
					key := (each first: pos - 1) withBlanksTrimmed.
					value := (each allButFirst: pos) withBlanksTrimmed.
					(value beginsWith: '*')
						ifTrue: [value := value allButFirst].
					(value endsWith: '*')
						ifTrue: [value := value allButLast].
					""
					args at: key put: {value}]].
	""
	^ args
]

{ #category : #private }
PRServerDirectory >> getProjectThumbnail: aProject [ 
	"private - answer a stream with the aProject's thumbnail or nil if none"
	| form stream |
	form := aProject thumbnail.
	form isNil
		ifTrue: [^ nil].
	""
	form unhibernate.
	form := form colorReduced.
	""
	self flag: #todo.
	"use a better image format than GIF"
	stream := ByteArray new writeStream.
	GIFReadWriter putForm: form onStream: stream.
	""
	^ stream contents asString
]

{ #category : #initialization }
PRServerDirectory >> initializeServer: serverString directories: directoriesCollection [ 
	"initialize the receiver's server and directories"
	server := serverString withBlanksTrimmed.
	server last = self pathNameDelimiter
		ifTrue: [server := server allButLast withBlanksTrimmed].
	""
	directories := directoriesCollection
]

{ #category : #testing }
PRServerDirectory >> isProjectSwiki [
	"answer whatever the receiver is a project swiki"
	^ true
]

{ #category : #testing }
PRServerDirectory >> isRemoteDirectory [
	"answer whatever the receiver is a remote directory"
	^ true
]

{ #category : #testing }
PRServerDirectory >> isSearchable [
	"answer whatever the receiver is searchable"
	^ true
]

{ #category : #accessing }
PRServerDirectory >> moniker [
	"a plain language name for this directory"
	^ self server
]

{ #category : #'file directory' }
PRServerDirectory >> oldFileNamed: aName [ "Open the existing file with the given name in this directory."
	^ self oldFileOrNoneNamed: aName
]

{ #category : #'file directory' }
PRServerDirectory >> oldFileOrNoneNamed: fullName [ 
	"If the file exists, answer a read-only FileStream on it. If it  
	doesn't, answer nil."
	| fileName contents |
	fileName := fullName
				allButFirst: (fullName lastIndexOf: self pathNameDelimiter).
	""
	contents := self getFullProjectContents: fileName.
	contents isNil
		ifTrue: [^ nil].
	""
	^ (SwikiPseudoFileStream with: contents) directory: self;
		 localName: fileName;
		 reset;
		 yourself
]

{ #category : #'file directory' }
PRServerDirectory >> on: fullName [ 
	"Answer another ServerDirectory on the partial path name.  
	fullName is directory path, and does include the name of the  
	server."
	^ self class fullPath: fullName
]

{ #category : #private }
PRServerDirectory >> parseLine: aString [ 
"private - parse a line from a server response"
	| tokens |
	tokens := aString findTokens: '|'.
	""
	^ tokens first = 'D'
		ifTrue: 
			[ DirectoryEntryDirectory
				directory: self
				name: tokens second
				creationTime: 0
				modificationTime: 0
				fileSize: 0 ]
		ifFalse: 
			[ DirectoryEntryFile
				directory: self
				name: tokens second
				creationTime: tokens third asInteger
				modificationTime: tokens fourth asInteger
				fileSize: tokens fifth asInteger ]
]

{ #category : #private }
PRServerDirectory >> parseLines: aCollection [ 
"private - parse aCollection of lines from a server response"
	^ aCollection
		collect: [:each | self parseLine: each]
]

{ #category : #'file directory' }
PRServerDirectory >> pathName"Path [ name as used in reading the file. "
	^ self urlFromServer: self server directories: self directories
]

{ #category : #'path access' }
PRServerDirectory >> pathNameDelimiter"Return [ the delimiter character for this kind of directory."
	^ $/
]

{ #category : #'file directory' }
PRServerDirectory >> pathParts [
	"Return the path from the root of the file system to this  
	directory as an array of directory names. On a remote server."
	^ (OrderedCollection with: self server) addAll: self directories;
		 yourself
]

{ #category : #private }
PRServerDirectory >> putProjectDetailsFrom: aProject to: args [ 
	| projectDetails |
	projectDetails := aProject world
				valueOfProperty: #ProjectDetails
				ifAbsent: [^ self].
	""
	self flag: #todo.
	"projectname ?"
	projectDetails
		at: 'projectdescription'
		ifPresent: [:value | args at: 'description' put: {value}].
	projectDetails
		at: 'projectauthor'
		ifPresent: [:value | args at: 'author' put: {value}].
	projectDetails
		at: 'projectcategory'
		ifPresent: [:value | args at: 'category' put: {value}].
	projectDetails
		at: 'projectsubcategory'
		ifPresent: [:value | args at: 'subcategory' put: {value}].
	projectDetails
		at: 'projectkeywords'
		ifPresent: [:value | args at: 'keywords' put: {value}]
]

{ #category : #private }
PRServerDirectory >> putSmalltalkInfoInto: args [ 
	"private - fills args with information from Smalltalk"
	self flag: #todo.
	" 
	lastest small-land changeset / small-land version  
	"
	#(#datedVersion #osVersion #platformName #platformSubtype #vmPath #vmVersion #imageName #changesName #sourcesName #listBuiltinModules #listLoadedModules #getVMParameters )
		do: [:each | 
			| value | 
			value := Smalltalk perform: each.
			args at: 'extra-' , each asString put: {value asString}]
]

{ #category : #testing }
PRServerDirectory >> queryProjectsAndShow: thingsToSearchForCollection [ 
	"query the server for all the projects that match  
	thingsToSearchForCollection"
	| url arguments string |
	url := self urlFromServer: self server directories: {'programmatic'. 'queryprojects'}.
	arguments := self getPostArgsFromThingsToSearchFor: thingsToSearchForCollection.
	""
	string := Cursor read showWhile: [
			"(HTTPClient httpPostDocument: url args:  args) contents."
			(HTTPSocket httpGetDocument: url args: arguments) contents].
	(string beginsWith: '--OK--')
		ifTrue: [^ true].
	""
	self
		inform: ('Server responded: {1}' translated format: {string}).
	^ false
]

{ #category : #'file directory' }
PRServerDirectory >> readOnlyFileNamed: aName [ 
"Open the existing file with the given name in this directory for read-only access."
	^ self oldFileNamed: aName
]

{ #category : #accessing }
PRServerDirectory >> realUrl [
	"a fully expanded version of the url we represent."
	^self urlFromServer: self server directories: self directories
]

{ #category : #'file directory' }
PRServerDirectory >> rename: fullName toBe: newName [ 
	"Rename a remote file. fullName is just be a fileName, or can 
	be directory path that includes name of the server. newName 
	is just a fileName"
	^ self inform: 'operation not supported' translated
]

{ #category : #accessing }
PRServerDirectory >> server [
	"answer the receiver's server"
	^ server
]

{ #category : #'path access' }
PRServerDirectory >> slash [
"answer the recevier 'slash'"
	^ self pathNameDelimiter asString
]

{ #category : #'file directory' }
PRServerDirectory >> sleep"Leave [ the FileList window. Do nothing. "
	^ self
]

{ #category : #private }
PRServerDirectory >> urlFromServer: serverString directories: aCollection [ 
	"private - builds an url for server/directories"
	| result |
	result := String new writeStream.
	""
	{serverString} , aCollection
		do: [:each | ""
			result
				nextPutAll: (each copyReplaceAll: ' ' with: '+')]
		separatedBy: [result nextPutAll: self slash].
	""
	^ result contents
]

{ #category : #'file directory' }
PRServerDirectory >> wakeUp"Entering [ a FileList window. Do nothing."
	^ self
]

{ #category : #squeaklets }
PRServerDirectory >> writeProject: aProject inFileNamed: fileNameString fromDirectory: localDirectory [ 
	"write aProject (a file version can be found in the file named  
	fileNameString in localDirectory)"
	| url arguments string |
	url := self urlFromServer: self server directories: {'programmatic'. 'uploadproject'}.
	arguments := self
				getPostArgsFromProject: aProject
				fileNamed: fileNameString
				fromDirectory: localDirectory.

	string := Cursor read showWhile: [
			(HTTPSocket httpPostDocument: url args: arguments) contents].
	(string beginsWith: '--OK--')
		ifTrue: [^ true].

	self inform: ('Server responded: {1}' translated format: {string}).
	^ false
]
