"
I represent a Stream that accesses a FilePage from a File. One use for my instance is to access larger ""virtual Strings"" than can be stored contiguously in main memory. I restrict the objects stored and retrieved to be Integers or Characters. An end of file pointer terminates reading; it can be extended by writing past it, or the file can be explicitly truncated.
	
To use the file system for most applications, you typically create a FileStream. This is done by sending a message to a FileDirectory (file:, oldFile:, newFile:, rename:newName:) which creates an instance of me. Accesses to the file are then done via my instance.

*** On DOS, files cannot be shortened!  ***  To overwrite a file with a shorter one, first delete the old file (FileDirectory deleteFilePath: 'Hard Disk:aFolder:dataFolder:foo') or (aFileDirectory deleteFileNamed: 'foo').  Then write your new shorter version.
"
Class {
	#name : #FileStream,
	#superclass : #ReadWriteStream,
	#instVars : [
		'rwmode'
	],
	#classVars : [
		'EncodeAndDecodeStdioFiles',
		'Stderr',
		'Stdin',
		'StdioFiles',
		'Stdout',
		'TheStdioHandles'
	],
	#category : #'Files-Kernel'
}

{ #category : #'concrete classes' }
FileStream class >> concreteStream [
	"Who should we really direct class queries to?  "
	^ MultiByteFileStream.

]

{ #category : #'file reader services' }
FileStream class >> cs [

	^'cs' shallowCopy
]

{ #category : #'instance creation' }
FileStream class >> detectFile: aBlockOrFileStream do: anotherBlock [

	^aBlockOrFileStream value "Assume that FileStreams return self for #value."
		ifNotNil: [ :file | [ anotherBlock value: file ] ensure: [ file close ] ]
]

{ #category : #stdio }
FileStream class >> encodeAndDecodeStdioFiles [
	
	<preference: 'Encode and decode the contents of stdio files.'
		category: 'Files'
		description: 'If true, then the contents of stdin, stdout and stderr are encoded/decoded using the system default text converter.'
		type: #Boolean>
	^EncodeAndDecodeStdioFiles ifNil: [ true ]
]

{ #category : #stdio }
FileStream class >> encodeAndDecodeStdioFiles: aBoolean [
	
	EncodeAndDecodeStdioFiles := aBoolean.
	self updateStdioFiles
]

{ #category : #'instance creation' }
FileStream class >> fileNamed: fileName [ 
	^ self concreteStream fileNamed: (self fullName: fileName)
]

{ #category : #'instance creation' }
FileStream class >> fileNamed: fileName do: aBlock [
	"Avi Bryant says, ''This idiom is quite common in other languages that make heavy use of closures (i.e. Lisp (with-file 'foo' (f) ...) and Ruby (File.open('foo'){|f|...})).  It's time Squeak had it, too.''
	
	Returns the result of aBlock."
	
	^self detectFile: (self fileNamed: fileName) do: aBlock
]

{ #category : #'file reader services' }
FileStream class >> fileReaderServicesForFile: fullName suffix: suffix [
	"Answer services for the given file"

	"Check whether the given path points to a directory or file."
	(FileDirectory default directoryExists: fullName) ifTrue: [^ #()].
		
	^ self servicesWithSuffixes
		select: [:spec | spec key anySatisfy: [:pattern | suffix = '*' or: [pattern match: suffix]]]
		thenCollect: [:spec | spec value]
]

{ #category : #stdio }
FileStream class >> flushAndVoidStdioFiles [

	StdioFiles ifNotNil: [
		StdioFiles do: [ :file |
			file ifNotNil: [ 
				file isReadOnly ifFalse: [
					[ file flush ]
						on: Error
						do: [ :ex | "care less" ] ] ] ].
		self voidStdioFiles ]
]

{ #category : #'instance creation' }
FileStream class >> forceNewFileNamed: fileName [
 	"Create a new file with the given name, and answer a stream opened for writing on that file. If the file already exists, delete it without asking before creating the new file."

	^self concreteStream forceNewFileNamed: fileName
]

{ #category : #'instance creation' }
FileStream class >> forceNewFileNamed: fileName do: aBlock [
	"Avi Bryant says, ''This idiom is quite common in other languages that make heavy use of closures (i.e. Lisp (with-file 'foo' (f) ...) and Ruby (File.open('foo'){|f|...})).  It's time Squeak had it, too.''
	
	Returns the result of aBlock."
	
	^self detectFile: (self forceNewFileNamed: fileName) do: aBlock
]

{ #category : #'instance creation' }
FileStream class >> fullName: fileName [
	^ FileDirectory default fullNameFor: fileName
]

{ #category : #'initialize-release' }
FileStream class >> initialize [

	FileServices registerFileReader: self.
	EncodeAndDecodeStdioFiles := true.
	TheStdioHandles := Array new: 3.
	Smalltalk
		addToStartUpList: self after: SecurityManager; "the intent being before: AutoStart"
		addToShutDownList: self after: SecurityManager
]

{ #category : #'instance creation' }
FileStream class >> isAFileNamed: fName [
	"return whether a file exists with the given name"
	^self concreteStream isAFileNamed: (self fullName: fName)
]

{ #category : #'file reader services' }
FileStream class >> isSourceFileSuffix: suffix [

	^ FileStream sourceFileSuffixes includes: suffix

]

{ #category : #'file reader services' }
FileStream class >> multiCs [

	^'mcs' shallowCopy
]

{ #category : #'file reader services' }
FileStream class >> multiSt [

	^'mst' shallowCopy
]

{ #category : #stdio }
FileStream class >> new [

	^self basicNew initialize
]

{ #category : #'instance creation' }
FileStream class >> newFileNamed: fileName [ 
	^ self concreteStream newFileNamed: (self fullName: fileName)
]

{ #category : #'instance creation' }
FileStream class >> newFileNamed: fileName do: aBlock [
	"Avi Bryant says, ''This idiom is quite common in other languages that make heavy use of closures (i.e. Lisp (with-file 'foo' (f) ...) and Ruby (File.open('foo'){|f|...})).  It's time Squeak had it, too.''
	
	Returns the result of aBlock."
	
	^self detectFile: (self newFileNamed: fileName) do: aBlock
]

{ #category : #stdio }
FileStream class >> newForStdio [
	"This is a hook for subclasses to initialize themselves properly."

	^self new
]

{ #category : #'instance creation' }
FileStream class >> oldFileNamed: fileName [ 
	^ self concreteStream oldFileNamed: (self fullName: fileName)
]

{ #category : #'instance creation' }
FileStream class >> oldFileNamed: fileName do: aBlock [
	"Avi Bryant says, ''This idiom is quite common in other languages that make heavy use of closures (i.e. Lisp (with-file 'foo' (f) ...) and Ruby (File.open('foo'){|f|...})).  It's time Squeak had it, too.''
	
	Returns the result of aBlock."
	
	^self detectFile: (self oldFileNamed: fileName) do: aBlock
]

{ #category : #'instance creation' }
FileStream class >> oldFileOrNoneNamed: fileName [
	"If the file exists, answer a read-only FileStream on it. If it doesn't, answer nil."

	| fullName |
	fullName := self fullName: fileName.
	(self concreteStream isAFileNamed: fullName)
		ifTrue: [^ self concreteStream readOnlyFileNamed: fullName]
		ifFalse: [^ nil].

]

{ #category : #'dnd requests' }
FileStream class >> primDropRequestFileName: dropIndex [
	"Primitive. Return the file name for some file that was just dropped onto Squeak.
	Fail if dropIndex is out of range or the primitive is not supported."
	<primitive: 'primitiveDropRequestFileName' module:'DropPlugin'>
	^nil
]

{ #category : #'instance creation' }
FileStream class >> readOnlyFileNamed: fileName [ 
	^ self concreteStream readOnlyFileNamed: (self fullName: fileName)
]

{ #category : #'instance creation' }
FileStream class >> readOnlyFileNamed: fileName do: aBlock [
	"Avi Bryant says, ''This idiom is quite common in other languages that make heavy use of closures (i.e. Lisp (with-file 'foo' (f) ...) and Ruby (File.open('foo'){|f|...})).  It's time Squeak had it, too.''
	
	Returns the result of aBlock."
	
	^self detectFile: (self readOnlyFileNamed: fileName) do: aBlock
]

{ #category : #'file reader services' }
FileStream class >> removeLineFeeds: fullName [
	| fileContents |
	fileContents := ((FileStream readOnlyFileNamed: fullName) wantsLineEndConversion: true) contentsOfEntireFile.
	(FileStream newFileNamed: fullName) 
		nextPutAll: fileContents;
		close.
]

{ #category : #'dnd requests' }
FileStream class >> requestDropStream: dropIndex [
	"Request a read-only stream for some file that was dropped onto Squeak"
	^self concreteStream new requestDropStream: dropIndex.
]

{ #category : #'file reader services' }
FileStream class >> serviceFileIn [
	"Answer a service for filing in an entire file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'fileIn entire file' translatedNoop
		selector: #fileIn:
		description: 'file in the entire contents of the file, which is expected to contain Smalltalk code in fileout ("chunk") format' translatedNoop
		buttonLabel: 'filein' translatedNoop
]

{ #category : #'file reader services' }
FileStream class >> serviceFileInSuffixes [

	^ self sourceFileSuffixes
]

{ #category : #'file reader services' }
FileStream class >> serviceRemoveLineFeeds [
	"Answer a service for removing linefeeds from a file"

	^ FileModifyingSimpleServiceEntry
		provider: self 
		label: 'remove line feeds' translatedNoop
		selector: #removeLineFeeds:	
		description: 'remove line feeds in file' translatedNoop
		buttonLabel: 'remove lfs' translatedNoop
]

{ #category : #'file reader services' }
FileStream class >> serviceRemoveLineFeedsSuffixes [

	^ self sourceFileSuffixes
]

{ #category : #'file reader services' }
FileStream class >> services [

	^ (((self class selectors copyWithout: #services)
		select: [:symbol | symbol beginsWith: #service])
		reject: [:symbol | symbol endsWith: #Suffixes])
		collect: [:selector | self perform: selector]
]

{ #category : #'file reader services' }
FileStream class >> servicesWithSuffixes [

	^ (((self class selectors copyWithout: #services)
		select: [:symbol | symbol beginsWith: #service])
		reject: [:symbol | symbol endsWith: #Suffixes])
		collect: [:selector | 
			(self perform: (selector, #Suffixes) asSymbol) -> (self perform: selector)]
]

{ #category : #'system startup' }
FileStream class >> shutDown: quitting [

	quitting ifTrue: [ self flushAndVoidStdioFiles ]
]

{ #category : #'file reader services' }
FileStream class >> sourceFileSuffixes [

	^ {FileStream st. FileStream sources. FileStream cs. FileStream multiSt. FileStream multiCs} asSet asArray.


]

{ #category : #'file reader services' }
FileStream class >> sources [

	^'sources' shallowCopy
]

{ #category : #'file reader services' }
FileStream class >> st [

	^'st' shallowCopy
]

{ #category : #stdio }
FileStream class >> standardIOStreamNamed: moniker forWrite: forWrite [
	
	| index |
	index := #(stdin stdout stderr) identityIndexOf: moniker.
	^((StdioFiles ifNil: [ StdioFiles := Array new: 3 ]) at: index)
		ifNil: [
			StdioFiles
				at: index 
				put: (
					(TheStdioHandles at: index)
						ifNil: [ ^self error: moniker, ' is unavailable' ]
						ifNotNil: [ :handle |
							self stdioStreamClass newForStdio
								openOnHandle: handle
								name: moniker
								forWrite: forWrite ]) ]

]

{ #category : #'system startup' }
FileStream class >> startUp: resuming [
	
	resuming ifTrue: [
		self voidStdioFiles.
		[ TheStdioHandles := self stdioHandles ]
			on: Error
			do: [:ex|
				TheStdioHandles isArray ifFalse: [
					TheStdioHandles := Array new: 3 ] ].
		(Smalltalk classNamed: 'TranscriptStream')
			ifNotNil: [ :t | "Reestablish dependency for stdout Transcript view"
				t redirectToStdOut: t redirectToStdOut ] ]

]

{ #category : #stdio }
FileStream class >> stderr [

	^Stderr ifNil: [ Stderr := self standardIOStreamNamed: #stderr forWrite: true ]
]

{ #category : #stdio }
FileStream class >> stdin [

	^Stdin ifNil: [ Stdin := self standardIOStreamNamed: #stdin forWrite: false ]
]

{ #category : #stdio }
FileStream class >> stdioHandles [
	<primitive: 'primitiveFileStdioHandles' module: 'FilePlugin' error: ec>
	self primitiveFailed
]

{ #category : #stdio }
FileStream class >> stdioStreamClass [

	^self encodeAndDecodeStdioFiles
		ifTrue: [ MultiByteFileStream ]
		ifFalse: [ StandardFileStream ]
]

{ #category : #stdio }
FileStream class >> stdout [

	^Stdout ifNil: [ Stdout := self standardIOStreamNamed: #stdout forWrite: true ]
]

{ #category : #'class initialization' }
FileStream class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #stdio }
FileStream class >> updateStdioFiles [
	"Make sure that all existing stdio files are instances of #stdioStreamClass."

	StdioFiles ifNil: [ ^self ].
	Stdin := Stdout := Stderr := nil.
	StdioFiles := StdioFiles collect: [ :file |
		file ifNotNil: [
			file class == self stdioStreamClass
				ifTrue: [ file ]
				ifFalse: [
					self stdioStreamClass newForStdio
						copyFrom: file;
						yourself ] ] ]

]

{ #category : #stdio }
FileStream class >> voidStdioFiles [

	 Stdin := Stdout := Stderr := StdioFiles := nil
]

{ #category : #'file reader services' }
FileStream class >> writeSourceCodeFrom: aStream baseName: baseName isSt: stOrCsFlag useHtml: useHtml [
	"Write the source code from aStream into a file. 
	Uses ChangeSet defaultChangeSetDirectory for consistency."

	^(ChangeSet defaultChangeSetDirectory)
		writeSourceCodeFrom: aStream 
		baseName: baseName 
		isSt: stOrCsFlag 
		useHtml: useHtml
]

{ #category : #converting }
FileStream >> asBinaryOrTextStream [
	"I can switch between binary and text data"

	^ self
]

{ #category : #'file modes' }
FileStream >> ascii [
	"Set this file to ascii (text) mode."

	self subclassResponsibility

]

{ #category : #testing }
FileStream >> atEnd [
	"Answer true if the current position is >= the end of file position.
	 1/31/96 sw: subclassResponsibility"

	self subclassResponsibility
]

{ #category : #'file modes' }
FileStream >> binary [
	"Set this file to binary mode."

	self subclassResponsibility

]

{ #category : #'file open\/close' }
FileStream >> close [
	"Close this file."

	self subclassResponsibility

]

{ #category : #'file open\/close' }
FileStream >> closed [
	"Answer true if this file is closed."

	self subclassResponsibility

]

{ #category : #accessing }
FileStream >> contents [
	"Return the contents of the receiver. Do not close or otherwise touch the receiver. Return data in whatever mode the receiver is in (e.g., binary or text)."
	| s savePos |
	savePos := self position.
	self position: 0.
	s := self next: self size.
	self position: savePos.
	^s
]

{ #category : #accessing }
FileStream >> contentsOfEntireFile [
	"Read all of the contents of the receiver."

	| s binary |
	self readOnly.
	binary := self isBinary.
	self reset.	"erases knowledge of whether it is binary"
	binary ifTrue: [self binary].
	s := self next: self size.
	self close.
	^s
]

{ #category : #'remote file compatibility' }
FileStream >> dataIsValid [

	self flag: #bob.		"we needed this if a remote stream, but could be local as well"
]

{ #category : #accessing }
FileStream >> directoryEntry [
	^self directory entryAt: self localName
]

{ #category : #'file accessing' }
FileStream >> file [
	"Answer the file for the page the receiver is streaming over.
	 1/31/96 sw: made subclass responsibility"

	self subclassResponsibility
]

{ #category : #'fileIn\/Out' }
FileStream >> fileIn [
	"Guarantee that the receiver is readOnly before fileIn for efficiency and
	to eliminate remote sharing conflicts."

	self readOnly.
	self fileInAnnouncing: 'Loading ', self localName
]

{ #category : #'fileIn\/Out' }
FileStream >> fileInObjectAndCode [
	"Read the file directly, do not use an RWBinaryOrTextStream."

	self text.
	^ super fileInObjectAndCode

]

{ #category : #'file open\/close' }
FileStream >> flush [
	"When writing, flush the current buffer out to disk."

	self subclassResponsibility

]

{ #category : #'file accessing' }
FileStream >> localName [

	^ FileDirectory localNameFor: self name

]

{ #category : #printing }
FileStream >> longPrintOn: aStream [
	"Do nothing, so it will print short.  Called to print the error file.  If the error was in a file operation, we can't read the contents of that file.  Just print its name instead."

]

{ #category : #printing }
FileStream >> longPrintOn: aStream limitedTo: sizeLimit indent: indent [

	"Do nothing, so it will print short.  Called to print the error file.  If the error was in a file operation, we can't read the contents of that file.  Just print its name instead."

	aStream cr
]

{ #category : #accessing }
FileStream >> mimeTypes [
	^FileDirectory default mimeTypesFor: self name.
]

{ #category : #'file accessing' }
FileStream >> name [
	"Answer the name of the file for the page the receiver is streaming over.  1/31/96 sw: made subclassResponsibility"

	self subclassResponsibility
]

{ #category : #accessing }
FileStream >> next [

	(position >= readLimit and: [self atEnd])
		ifTrue: [^nil]
		ifFalse: [^collection at: (position := position + 1)]
]

{ #category : #accessing }
FileStream >> next: anInteger [

	| newCollection howManyRead increment |
	newCollection := self collectionSpecies new: anInteger.
	howManyRead := 0.
	[howManyRead < anInteger] whileTrue:
		[self atEnd ifTrue:
			[(howManyRead + 1) to: anInteger do: [:i | newCollection at: i put: (self next)].
			^newCollection].
		increment := (readLimit - position) min: (anInteger - howManyRead).
		newCollection replaceFrom: (howManyRead + 1)
			to: (howManyRead := howManyRead + increment)
			with: collection
			startingAt: (position + 1).
		position := position + increment].
	^newCollection
]

{ #category : #accessing }
FileStream >> nextPut: aByte [
	"1/31/96 sw: subclassResponsibility"

	self subclassResponsibility
]

{ #category : #accessing }
FileStream >> nextPutAll: aCollection [
	"1/31/96 sw: made subclass responsibility"

	self subclassResponsibility
]

{ #category : #positioning }
FileStream >> position [
	"Answer the current character position in the file.
	 1/31/96 sw: subclassResponsibility"

	self subclassResponsibility
]

{ #category : #positioning }
FileStream >> position: pos [
	"Set the current character position in the file to pos.
	 1/31/96 sw: made subclassResponsibility"

	self subclassResponsibility
]

{ #category : #printing }
FileStream >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' on '.
	self file printOn: aStream
]

{ #category : #'file modes' }
FileStream >> readOnly [
	"Set this file's mode to read-only."

	self subclassResponsibility

]

{ #category : #'file modes' }
FileStream >> readOnlyStream [
	^self readOnly
]

{ #category : #'file modes' }
FileStream >> readWrite [
	"Set this file's mode to read-write."

	self subclassResponsibility

]

{ #category : #'file open\/close' }
FileStream >> reopen [
	"Ensure that the receiver is open, re-open it if necessary."
	"Details: Files that were open when a snapshot occurs are no longer valid when the snapshot is resumed. This operation re-opens the file if that has happened."

	self subclassResponsibility

]

{ #category : #positioning }
FileStream >> reset [
	"Set the current character position to the beginning of the file.
	 1/31/96 sw: subclassResponsibility"

	self subclassResponsibility
]

{ #category : #positioning }
FileStream >> setToEnd [
	"Set the current character position to the end of the File. The same as
	self position: self size.  1/31/96 sw: made subclassResponsibility"

	self subclassResponsibility
]

{ #category : #accessing }
FileStream >> size [
	"Answer the size of the file in characters.
	 1/31/96 sw: made subclass responsibility"

	self subclassResponsibility
]

{ #category : #positioning }
FileStream >> skip: n [
	"Set the character position to n characters from the current position.
	Error if not enough characters left in the file
	1/31/96 sw: made subclassResponsibility."
 
	self subclassResponsibility
]

{ #category : #'file open\/close' }
FileStream >> sync [
	"sync the current buffer out to disk."

	self subclassResponsibility

]

{ #category : #'file modes' }
FileStream >> text [
	"Set this file to text (ascii) mode."

	self ascii.

]

{ #category : #positioning }
FileStream >> truncate: pos [
	"Truncate file to pos"

	self subclassResponsibility
]
