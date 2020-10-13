"
A FileDirectory represents a folder or directory in the underlying platform's file system. It carries a fully-qualified path name for the directory it represents, and can enumerate the files and directories within that directory.

A FileDirectory can be thought of as a Dictionary whose keys are the local names of files in that directory, and whose values are directory ""entries"". Each entry is an array of five items:

	<name> <creationTime> <modificationTime> <dirFlag> <fileSize>

The times are given in seconds, and can be converted to a time and date via Time>dateAndTimeFromSeconds:. See the comment in lookupEntry:... which provides primitive access to this information.

"
Class {
	#name : #FileDirectory,
	#superclass : #Object,
	#instVars : [
		'pathName'
	],
	#classVars : [
		'DefaultDirectory',
		'DirectoryClass',
		'StandardMIMEMappings'
	],
	#category : #'Files-Directories'
}

{ #category : #private }
FileDirectory class >> activeDirectoryClass [
	"Return the concrete FileDirectory subclass for the platform on which we are currently running."

	FileDirectory allSubclasses do: [:class |
		class isActiveDirectoryClass ifTrue: [^ class]].

	"no responding subclass; use FileDirectory"
	^ FileDirectory

]

{ #category : #'name utilities' }
FileDirectory class >> baseNameFor: fileName [
	"Return the given file name without its extension, if any. We have to remember that many (most?) OSs allow extension separators within directory names and so the leaf filename needs to be extracted, trimmed and rejoined. Yuck"
	"The test is 
		FileDirectory baseNameFor: ((FileDirectory default directoryNamed: 'foo.bar') fullNameFor:'blim.blam') 
		should end 'foo.bar/blim' (or as appropriate for your platform AND
		FileDirectory baseNameFor: ((FileDirectory default directoryNamed: 'foo.bar') fullNameFor:'blim')
		should be the same and NOT  'foo'
		Oh, and FileDirectory baseNameFor: 'foo.bar' should be 'foo' not '/foo' "

	self splitName: fileName to: [:path : fn|
		| delim i leaf |
		delim := DirectoryClass extensionDelimiter.
		i := fn findLast: [:c | c = delim].
		leaf := i = 0
			ifTrue: [fn]
			ifFalse: [fn copyFrom: 1 to: i - 1].
		path isEmpty ifTrue:[^leaf].
		^path, self slash, leaf]

]

{ #category : #'name utilities' }
FileDirectory class >> changeSuffix [
"if 'changes' is not suitable, override this message to return something that is ok"
	^'changes'
]

{ #category : #'name utilities' }
FileDirectory class >> checkName: fileName fixErrors: flag [
	"Check a string fileName for validity as a file name on the current default file system. Answer the original file name if it is valid. If the name is not valid (e.g., it is too long or contains illegal characters) and fixing is false, raise an error. If fixing is true, fix the name (usually by truncating and/or tranforming characters), and answer the corrected name. The default behavior is to truncate the name to 31 chars. Subclasses can do any kind of checking and correction appropriate to the underlying platform."

	^ DefaultDirectory
		checkName: fileName
		fixErrors: flag

]

{ #category : #'platform specific' }
FileDirectory class >> currentDirectoryNickname [
	"Answer the nick-name for the current directory (e.g. '.' on Unix and Windows).
	 Answer the common default."
	^'.'
]

{ #category : #'instance creation' }
FileDirectory class >> default [
	"Answer the default directory."

	^ DefaultDirectory

]

{ #category : #'create\/delete file' }
FileDirectory class >> deleteFilePath: fullPathToAFile [
	"Delete the file after finding its directory"

	| dir |
	dir := self on: (self dirPathFor: fullPathToAFile).
	dir deleteFileNamed: (self localNameFor: fullPathToAFile).

]

{ #category : #'name utilities' }
FileDirectory class >> dirPathFor: fullName [ 
	"Return the directory part the given name."
	DirectoryClass
		splitName: fullName
		to: [:dirPath :localName | ^ dirPath]
]

{ #category : #'name utilities' }
FileDirectory class >> directoryEntryFor: filenameOrPath [
	^self default directoryEntryFor: filenameOrPath
]

{ #category : #'platform specific' }
FileDirectory class >> dot [
	"Return a one-character string containing the filename extension delimiter for this platform (i.e., the local equivalent of 'dot')"

	^ self extensionDelimiter asString

]

{ #category : #'platform specific' }
FileDirectory class >> extensionDelimiter [
	"Return the character used to delimit filename extensions on this platform. Most platforms use the period (.) character."

	^ $.

]

{ #category : #'name utilities' }
FileDirectory class >> extensionFor: fileName [
	"Return the extension of given file name, if any."

	| delim i |
	delim := DirectoryClass extensionDelimiter.
	i := fileName findLast: [:c | c = delim].
	i = 0
		ifTrue: [^ '']
		ifFalse: [^ fileName copyFrom: i + 1 to: fileName size].

]

{ #category : #'name utilities' }
FileDirectory class >> fileName: fileName extension: fileExtension [
	| extension |
	extension := FileDirectory dot , fileExtension.
	^(fileName endsWith: extension)
		ifTrue: [fileName]
		ifFalse: [fileName , extension].
]

{ #category : #'file reader services' }
FileDirectory class >> fileReaderServicesForFile: fullName suffix: suffix [

	^ (self on: fullName) exists
		ifTrue: [self services]
		ifFalse: [#()].
]

{ #category : #'instance creation' }
FileDirectory class >> forFileName: aString [

	| path |
	path := self dirPathFor: aString.
	path isEmpty ifTrue: [^ self default].
	^ self on: path

]

{ #category : #'name utilities' }
FileDirectory class >> imageSuffix [
"if 'image' is not suitable, override this message to return something that is ok"
	^'image'
]

{ #category : #'class initialization' }
FileDirectory class >> initialize [

	FileServices registerFileReader: self.
]

{ #category : #'class initialization' }
FileDirectory class >> initializeStandardMIMETypes [
	"FileDirectory initializeStandardMIMETypes"
	StandardMIMEMappings := Dictionary new.
	#(
		(gif		('image/gif'))
		(pdf	('application/pdf'))
		(aiff	('audio/aiff'))
		(bmp	('image/bmp'))
		(png	('image/png'))
		(swf	('application/x-shockwave-flash'))
		(htm	('text/html' 'text/plain'))
		(html	('text/html' 'text/plain'))
		(jpg	('image/jpeg'))
		(jpeg	('image/jpeg'))
		(mid	('audio/midi'))
		(midi	('audio/midi'))
		(mp3	('audio/mpeg'))
		(mpeg	('video/mpeg'))
		(mpg	('video/mpg'))
		(txt		('text/plain'))
		(text	('text/plain'))
		(mov	('video/quicktime'))
		(qt		('video/quicktime'))
		(tif		('image/tiff'))
		(tiff	('image/tiff'))
		(ttf		('application/x-truetypefont'))
		(wrl	('model/vrml'))
		(vrml	('model/vrml'))
		(wav	('audio/wav'))
	) do:[:spec|
		StandardMIMEMappings at: spec first asString put: spec last.
	].
]

{ #category : #private }
FileDirectory class >> isActiveDirectoryClass [
	"Does this class claim to be that properly active subclass of FileDirectory for this platform?
	Default test is whether the primPathNameDelimiter matches the one for this class. Other tests are possible"

	^self pathNameDelimiter = self primPathNameDelimiter

]

{ #category : #'platform specific' }
FileDirectory class >> isCaseSensitive [
	"Return true if file names are treated case sensitive"
	^true
]

{ #category : #'name utilities' }
FileDirectory class >> isLegalFileName: fullName [
	"Return true if the given string is a legal file name."

	^ DefaultDirectory isLegalFileName: (self localNameFor: fullName)

]

{ #category : #'name utilities' }
FileDirectory class >> localNameFor: fullName [ 
	"Return the local part the given name."
	DirectoryClass
		splitName: fullName
		to: [:dirPath :localName | ^ localName]
]

{ #category : #'create\/delete file' }
FileDirectory class >> lookInUsualPlaces: fileName [
	"Check the default directory, the imagePath, and the vmPath (and the vmPath's owner) for this file."

	| vmp |
	(FileDirectory default fileExists: fileName)
		ifTrue: [^ FileDirectory default fileNamed: fileName].

	((vmp := FileDirectory on: Smalltalk imagePath) fileExists: fileName)
		ifTrue: [^ vmp fileNamed: fileName].

	((vmp := FileDirectory on: Smalltalk vmPath) fileExists: fileName)
		ifTrue: [^ vmp fileNamed: fileName].

	((vmp := vmp containingDirectory) fileExists: fileName)
		ifTrue: [^ vmp fileNamed: fileName].

	^ nil
]

{ #category : #'platform specific' }
FileDirectory class >> makeAbsolute: path [
	"Ensure that path looks like an absolute path"
	^path first = self pathNameDelimiter
		ifTrue: [ path ]
		ifFalse: [ self slash, path ]
]

{ #category : #'platform specific' }
FileDirectory class >> makeRelative: path [
	"Ensure that path looks like an relative path"
	^path first = self pathNameDelimiter
		ifTrue: [ path copyWithoutFirst ]
		ifFalse: [ path ]
]

{ #category : #'platform specific' }
FileDirectory class >> maxFileNameLength [

	^ 31

]

{ #category : #'instance creation' }
FileDirectory class >> on: pathString [
	"Return a new file directory for the given path, of the appropriate FileDirectory subclass for the current OS platform."

	| pathName |
	DirectoryClass ifNil: [self setDefaultDirectoryClass].
	"If path ends with a delimiter (: or /) then remove it"
	pathName := pathString.
	(pathName at: pathName size ifAbsent: nil) = self pathNameDelimiter ifTrue:
		[pathName := pathName allButLast].
	DirectoryClass parentDirectoryNickname ifNotNil:
		[:parentName|
		(pathName beginsWith: parentName) ifTrue:
			[pathName = parentName ifTrue:
				[^self default containingDirectory].
			 (pathName at: parentName size + 1 ifAbsent: nil) = self pathNameDelimiter ifTrue:
				[^self default containingDirectory on: (pathName allButFirst: parentName size + 1)]]].
	^DirectoryClass new setPathName: pathName
]

{ #category : #'platform specific' }
FileDirectory class >> parentDirectoryNickname [
	"Answer the nick-name for the parent directory (e.g. '..' on Unix and Windows).
	 Answer the common default."
	^'..'
]

{ #category : #'platform specific' }
FileDirectory class >> pathNameDelimiter [
"return the active directory class's directory seperator character"
	^ DirectoryClass pathNameDelimiter
]

{ #category : #private }
FileDirectory class >> primPathNameDelimiter [
	"Return the path delimiter for the underlying platform's file system."

 	<primitive: 'primitiveDirectoryDelimitor' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #'dnd requests' }
FileDirectory class >> requestDropDirectory: dropIndex [

	| potentialDirectory | 
	potentialDirectory := self on: (FileStream primDropRequestFileName: dropIndex).
	^ potentialDirectory exists ifTrue: [potentialDirectory]

]

{ #category : #'instance creation' }
FileDirectory class >> root [
	"Answer the root directory."

	^ self on: ''

]

{ #category : #'file reader services' }
FileDirectory class >> services [

	^ (self class selectors copyWithout: #services)
		select: [:symbol | symbol beginsWith: #service]
		thenCollect: [:selector | self perform: selector]
]

{ #category : #'system start up' }
FileDirectory class >> setDefaultDirectoryClass [
	"Initialize the default directory class to suit this platform. This method is called when the image starts up - it needs to be right at the front of the list of the startup sequence"

	DirectoryClass := self activeDirectoryClass

]

{ #category : #'system start up' }
FileDirectory class >> shutDown [

	Smalltalk closeSourceFiles.

]

{ #category : #'platform specific' }
FileDirectory class >> slash [
	^ self pathNameDelimiter asString
]

{ #category : #'name utilities' }
FileDirectory class >> splitName: fullName to: pathAndNameBlock [
	"Take the file name and convert it to the path name of a directory and a local file name within that directory. FileName must be of the form: <dirPath><delimiter><localName>, where <dirPath><delimiter> is optional. The <dirPath> part may contain delimiters."

	| delimiter i dirName localName |
	delimiter := self pathNameDelimiter.
	(i := fullName findLast: [:c | c = delimiter]) = 0
		ifTrue:
			[dirName := String new.
			localName := fullName]
		ifFalse:
			[dirName := fullName copyFrom: 1 to: (i - 1 max: 1).
			localName := fullName copyFrom: i + 1 to: fullName size].

	^ pathAndNameBlock value: dirName value: localName
]

{ #category : #'name utilities' }
FileDirectory class >> startUp [
	"Establish the platform-specific FileDirectory subclass. Do any platform-specific startup."
	self setDefaultDirectoryClass.

	self setDefaultDirectory: (self dirPathFor: Smalltalk imageName).

	Preferences startInUntrustedDirectory 
		ifTrue:[	"The SecurityManager may override the default directory to prevent unwanted write access etc."
				self setDefaultDirectory: SecurityManager default untrustedUserDirectory.
				"Make sure we have a place to go to"
				DefaultDirectory assureExistence].
	Smalltalk openSourceFiles.

]

{ #category : #'name utilities' }
FileDirectory class >> urlForFileNamed: aFilename [ 
	"Create a URL for the given fully qualified file name"
	"FileDirectory urlForFileNamed: 
	'C:\Home\andreasr\Squeak\DSqueak3\DSqueak3:=1.1\DSqueak3.1.image' "
	| path localName |
	DirectoryClass
		splitName: aFilename
		to: [:p :n | 
			path := p.
			localName := n].
	^ localName asUrlRelativeTo: (self on: path) url asUrl
]

{ #category : #'path access' }
FileDirectory >> / aString [ 
	"Answer a FileDirectory on a subdirectory named aString, of the receiver.  If there is already a file named aString in the receiver directory, answer its Entry."
	| dir |
	dir := FileDirectory on: (self fullNameFor: aString).
	^ dir exists
		ifTrue: [ dir ]
		ifFalse:
			[ self
				entryAt: aString
				ifAbsent: [ dir ] ]
]

{ #category : #comparing }
FileDirectory >> = aDirectory [
	"Compare two FileDirectory instances."
	
	^(aDirectory isKindOf: FileDirectory) and: [
		(pathName asString 
			compare: aDirectory pathName asString 
			caseSensitive: (self isCaseSensitive or: [ aDirectory isCaseSensitive ])) = 2 ]
]

{ #category : #testing }
FileDirectory >> acceptsUploads [
	^true
]

{ #category : #'file directory' }
FileDirectory >> assureAbsence [
	self exists ifTrue: [ self recursiveDelete ]
]

{ #category : #'file directory' }
FileDirectory >> assureExistence [
	"Make sure the current directory exists. If necessary, create all parts in between"
	self exists ifFalse:
		[ self containingDirectory
			 assureExistence ;
			 createDirectory: self localName.
		self exists ifFalse: [ Error signal: self fullName, ' could not be created.  Permissions?' ] ]
]

{ #category : #'file directory' }
FileDirectory >> assureExistenceOfPath: lPath [
	"Make sure the local directory exists. If necessary, create all parts in between"
	| localPath |
	localPath := lPath.
	localPath isEmpty ifTrue: [ ^self ]. "Assumed to exist"
	self assureExistence.
	(self directoryExists: localPath) ifTrue: [^ self]. "exists"
	self createDirectory: localPath
]

{ #category : #'file name utilities' }
FileDirectory >> checkName: aFileName fixErrors: fixing [
	"Check a string aFileName for validity as a file name. Answer the original file name if it is valid. If the name is not valid (e.g., it is too long or contains illegal characters) and fixing is false, raise an error. If fixing is true, fix the name (usually by truncating and/or tranforming characters), and answer the corrected name. The default behavior is just to truncate the name to the maximum length for this platform. Subclasses can do any kind of checking and correction appropriate for their platform."

	| maxLength |
	aFileName size = 0 ifTrue: [self error: 'zero length file name'].
	maxLength := self class maxFileNameLength.
	aFileName size > maxLength ifTrue: [
		fixing
			ifTrue: [^ aFileName contractTo: maxLength]
			ifFalse: [self error: 'file name is too long']].

	^ aFileName

]

{ #category : #enumeration }
FileDirectory >> containingDirectory [
	"Return the directory containing this directory."

	^ FileDirectory on: (FileDirectory dirPathFor: pathName asSqueakPathName)

]

{ #category : #'file operations' }
FileDirectory >> copyFile: fileStream1 toFile: fileStream2 [ 
	| buffer |
	fileStream1 position: 0.
	fileStream2 truncate.
	buffer := String new: 50000.
	[ fileStream1 atEnd ] whileFalse: [ fileStream2 nextPutAll: (fileStream1 nextInto: buffer) ].
	fileStream2 position < fileStream1 size ifTrue: [ self error: 'File copy failed' ]
]

{ #category : #'file operations' }
FileDirectory >> copyFileNamed: fileName1 toFileNamed: fileName2 [
	"Copy the contents of the existing file with the first name into a new file with the second name. Both files are assumed to be in this directory."
	"FileDirectory default copyFileNamed: 'todo.txt' toFileNamed: 'todocopy.txt'"

	| file1 file2 |
	file1 := (self readOnlyFileNamed: fileName1) binary.
	file2 := (self newFileNamed: fileName2) binary.
	self copyFile: file1 toFile: file2.
	file1 close.
	file2 close.

]

{ #category : #'file operations' }
FileDirectory >> copyFileWithoutOverwriteConfirmationNamed: fileName1 toFileNamed: fileName2 [
	"Copy the contents of the existing file with the first name into a file with the second name (which may or may not exist). If the second file exists, force an overwrite without confirming.  Both files are assumed to be in this directory."
	"FileDirectory default copyFileWithoutOverwriteConfirmationNamed: 'todo.txt' toFileNamed: 'todocopy.txt'"

	| file1 file2 |
	fileName1 = fileName2 ifTrue: [^ self].
	file1 := (self readOnlyFileNamed: fileName1) binary.
	file2 := (self forceNewFileNamed: fileName2) binary.
	self copyFile: file1 toFile: file2.
	file1 close.
	file2 close.
]

{ #category : #'file operations' }
FileDirectory >> copyHere: aDirectoryEntryFile [ 
	"Copy aDirectoryEntryFile, which represents a file, to the directory I represent."
	aDirectoryEntryFile readStream in: 
		[ : readStream | 
		[ self 
			putFile: readStream
			named: aDirectoryEntryFile name ] ensure: [ readStream close ] ]
]

{ #category : #'file operations' }
FileDirectory >> createDirectory: localFileName [
	"Create a directory with the given name in this directory. Fail if the name is bad or if a file or directory with that name already exists."

 	self primCreateDirectory: (self fullNameFor: localFileName) asVmPathName

]

{ #category : #'file operations' }
FileDirectory >> deleteDirectory: localDirName [
	"Delete the directory with the given name in this directory. Fail if the path is bad or if a directory by that name does not exist."

 	self primDeleteDirectory: (self fullNameFor: localDirName) asVmPathName.

]

{ #category : #'file operations' }
FileDirectory >> deleteFileNamed: localFileName [
	"Delete the file with the given name in this directory."

	self deleteFileNamed: localFileName ifAbsent: [].

]

{ #category : #'file operations' }
FileDirectory >> deleteFileNamed: localFileName ifAbsent: failBlock [
	"Delete the file of the given name if it exists, else evaluate failBlock.
	If the first deletion attempt fails do a GC to force finalization of any lost references. ar 3/21/98 17:53"
	| fullName |
	fullName := self fullNameFor: localFileName.
	(StandardFileStream 
		retryWithGC:[self primDeleteFileNamed: (self fullNameFor: localFileName) asVmPathName]
		until:[:result| result notNil]
		forFileNamed: fullName) == nil
			ifTrue: [^failBlock value].

]

{ #category : #'file operations' }
FileDirectory >> deleteLocalFiles [
	"Delete the local files in this directory."

	self fileNames do:[:fn| self deleteFileNamed: fn ifAbsent: [(CannotDeleteFileException new
			messageText: 'Could not delete the old version of file ' , (self fullNameFor: fn)) signal]]

]

{ #category : #private }
FileDirectory >> directoryContentsFor: fullPath [
	"Return a collection of directory entries for the files and directories in the directory with the given path. See primLookupEntryIn:index: for further details."
	"FileDirectory default directoryContentsFor: ''"

	^Array new: 200 streamContents: [:stream |
		self directoryContentsFor: fullPath do: [:ea | stream nextPut: ea]].
]

{ #category : #private }
FileDirectory >> directoryContentsFor: fullPath do: aBlock [
	"Do aBlock for the files and directories in the directory with the given path. See primLookupEntryIn:index: for further details."
	"FileDirectory default directoryContentsFor: '' do: [ :each | Transcript show: each; cr ]"

	| vmPath entryArray index |
	vmPath := fullPath asVmPathName.
	index := 1.
	entryArray := (self primLookupEntryIn: vmPath index: index) ifNil: [ ^self ].
	#badDirectoryPath == entryArray ifTrue: [
		^(InvalidDirectoryError pathName: fullPath) signal ].
	[
		aBlock value: (DirectoryEntry fromArray: entryArray directory: self) convertFromSystemName.
		entryArray := (self primLookupEntryIn: vmPath index: (index := index + 1)) ifNil: [ ^self ] ] repeat
]

{ #category : #enumeration }
FileDirectory >> directoryEntries [
	"Return a collection of full entries for the subdirectories of this directory."
	"FileDirectory default directoryEntries"

	^Array streamContents: [ :stream |
		self entriesDo: [ :entry |
			entry isDirectory ifTrue: [
				stream nextPut: entry ]]]
]

{ #category : #enumeration }
FileDirectory >> directoryEntry [
	^self containingDirectory entryAt: self localName
]

{ #category : #enumeration }
FileDirectory >> directoryEntryFor: filenameOrPath [
	"Answer the directory entry for the given file or path."
	^ DirectoryClass
		splitName: filenameOrPath
		to:
			[ : filePath : name | | filename directory |
			filename := name.
			directory := filePath isEmpty
				ifTrue: [ self ]
				ifFalse: [ FileDirectory on: filePath ].
			 directory
				entryAt: filename
				ifAbsent: [ nil ] ]
]

{ #category : #private }
FileDirectory >> directoryEntryForName: aFileName [

	"Return a single DirectoryEntry for the given (non-path) entry name,
	 or nil if the entry could not be found.
	 Raises InvalidDirectoryError if this directory's path does not identify a directory."

	| entryArray sysPath sysName |

	sysPath := pathName asVmPathName.
	sysName := aFileName asVmPathName.

	"New linear-time primitive."
	entryArray := self primLookupEntryIn: sysPath name: sysName.
	entryArray == #primFailed ifFalse:[
		^ entryArray ifNotNil: [(DirectoryEntry fromArray: entryArray directory: self) convertFromSystemName]
	].

	"(InvalidDirectoryError pathName: pathName) signal.
	^nil"

	"If the new primitive fails, use the old slow method. 
	 (This fallback can be changed to signal InvalidDirectoryError once
	  VM's with FilePlugin #primitiveDirectoryEntry have been distributed everywhere;
	  the new primitive was introduced 6/13/2007."

	self isCaseSensitive 
		ifTrue: [ self entriesDo: [ :entry | entry name = aFileName ifTrue: [ ^entry ] ] ] 
		ifFalse: [ self entriesDo: [ :entry | (entry name sameAs: aFileName) ifTrue: [ ^entry ] ] ].
	^nil
]

{ #category : #testing }
FileDirectory >> directoryExists: filenameOrPath [
	"Answer true if a directory of the given name exists. The given name may be either a full path name or a local directory within this directory."
	"FileDirectory default directoryExists: FileDirectory default pathName"

	| fName dir |
	DirectoryClass
		splitName: filenameOrPath
		to: [:filePath :name |
			fName := name.
			dir := filePath isEmpty
					ifTrue: [self]
					ifFalse: [FileDirectory on: filePath]].

	^dir exists
	  and: [(dir directoryEntryForName: fName)
			ifNotNil: [:e| e isDirectory]
			ifNil: [false]]
]

{ #category : #enumeration }
FileDirectory >> directoryNamed: localFileName [
	"Return the subdirectory of this directory with the given name."

	^ FileDirectory on: (self fullNameFor: localFileName)

]

{ #category : #enumeration }
FileDirectory >> directoryNames [
	"Return a collection of names for the subdirectories of this directory."
	"FileDirectory default directoryNames"

	^Array streamContents: [ :stream |
		self entriesDo: [ :entry |
			entry isDirectory ifTrue: [
				stream nextPut: entry name ] ] ]
]

{ #category : #'file name utilities' }
FileDirectory >> directoryNamesMatching: pat [
	"
	FileDirectory default directoryNamesMatching: '*'
	FileDirectory default directoryNamesMatching: '*_segs'
	"
	
	| directories directoryNames |
	directories := OrderedCollection new.
	directoryNames := self directoryNames.
	(pat findTokens: ';', String crlf) do:
		[:tok | 
		directories addAll: (directoryNames select: [:name | tok match: name])].
	^directories
]

{ #category : #squeaklets }
FileDirectory >> directoryObject [

	^self
]

{ #category : #enumeration }
FileDirectory >> directoryTreeDo: oneArgBlock [ 
	"For each file and directory in my tree, value oneArgBlock with an OrderedCollection of the path of DirectoryEntry's leading to the current node.  The first element in the collection will be the DirectoryEntryDirectory for myself, the last is the currentNode (a DirectoryEntry)."
	|myEntry|
	myEntry := OrderedCollection with: self directoryEntry.
	oneArgBlock value: myEntry.
	self 
		directoryTreeDo: oneArgBlock
		entries: myEntry
]

{ #category : #enumeration }
FileDirectory >> directoryTreeDo: oneArgBlock entries: entriesCollection [ 
	"Value oneArgBlock with the path (an OrderedCollection of FileDirectory's) to each DirectoryEntry and the DirectoryEntry itself."

	self entriesDo:  [ :entry | 
		entriesCollection addLast: entry.
		oneArgBlock value: entriesCollection.
		entry isDirectory ifTrue: [
			entry asFileDirectory
				directoryTreeDo: oneArgBlock
				entries: entriesCollection ].
		entriesCollection removeLast ]
]

{ #category : #squeaklets }
FileDirectory >> downloadUrl [
	^''
]

{ #category : #enumeration }
FileDirectory >> entries [
	"Return a collection of DirectoryEntry's for the files and directories in this directory.  See primLookupEntryIn:index: for further details."
	"FileDirectory default entries"
	^ self directoryContentsFor: pathName

]

{ #category : #enumeration }
FileDirectory >> entriesDo: aBlock [
	"Evaluate aBlock with DirectoryEntry's for the files and directories in this directory.  See primLookupEntryIn:index: for further details."
	
	^self directoryContentsFor: pathName do: aBlock

]

{ #category : #'file status' }
FileDirectory >> entryAt: fileName [  
	"find the entry with local name fileName"

	^self entryAt: fileName ifAbsent: [ self error: 'file not in directory: ', fileName ].
]

{ #category : #'file status' }
FileDirectory >> entryAt: fileName ifAbsent: aBlock [
	"Find the entry with local name fileName and answer it.
	 If not found, answer the result of evaluating aBlock."

	self exists ifFalse: [^aBlock value].

	^(self directoryEntryForName: fileName) ifNil: [ aBlock value ]

]

{ #category : #testing }
FileDirectory >> exists [
"Answer whether the directory exists"

	| result |
	result := self primLookupEntryIn: pathName asVmPathName index: 1.
	^ result ~= #badDirectoryPath

]

{ #category : #enumeration }
FileDirectory >> fileAndDirectoryNames [
	"FileDirectory default fileAndDirectoryNames"
	
	^Array streamContents: [ :stream |
		self entriesDo: [ :entry |
			stream nextPut: entry name ] ]
]

{ #category : #enumeration }
FileDirectory >> fileEntries [
	"Return a collection of the full entries for the files (but not directories) in this directory."
	"FileDirectory default fileEntries"

	^Array streamContents: [ :stream |
		self entriesDo: [ :entry |
			entry isDirectory ifFalse: [
				stream nextPut: entry ]]]
]

{ #category : #testing }
FileDirectory >> fileExists: filenameOrPath [
	"Answer true if a file of the given name exists. The given name may be either a full path name or a local file within this directory."
	"FileDirectory default fileExists: Smalltalk sourcesName"

	| fName dir |
	DirectoryClass
		splitName: filenameOrPath
		to: [:filePath :name |
			fName := name.
			dir := filePath isEmpty
					ifTrue: [self]
					ifFalse: [FileDirectory on: filePath]].
	
	^(dir directoryEntryForName: fName)
		ifNotNil: [:e| e isDirectory not]
		ifNil: [false]
		
]

{ #category : #'file stream creation' }
FileDirectory >> fileNamed: localFileName [
	"Open the file with the given name in this directory for writing."

	^ FileStream concreteStream fileNamed: (self fullNameFor: localFileName)

]

{ #category : #'file stream creation' }
FileDirectory >> fileNamed: localFileName do: aBlock [
	"Open the file with the given name in this directory for writing and pass it as argument to aBlock."

	^ FileStream concreteStream fileNamed: (self fullNameFor: localFileName) do: aBlock

]

{ #category : #enumeration }
FileDirectory >> fileNames [
	"Return a collection of names for the files (but not directories) in this directory."
	"FileDirectory default fileNames"

	^Array streamContents: [ :stream |
		self entriesDo: [ :entry |
			entry isDirectory ifFalse: [
				stream nextPut: entry name ] ] ]
]

{ #category : #'file name utilities' }
FileDirectory >> fileNamesMatching: pat [
	"
	FileDirectory default fileNamesMatching: '*'
	FileDirectory default fileNamesMatching: '*.image;*.changes'
	"
	
	| files fileNames |
	files := OrderedCollection new.
	fileNames := self fileNames.
	(pat findTokens: ';', String crlf) do:
		[:tok | 
		files addAll: (fileNames select: [:name | tok match: name])].
	^files
]

{ #category : #'file operations' }
FileDirectory >> fileOrDirectoryExists: filenameOrPath [
	"Answer true if either a file or a directory file of the given name exists. The given name may be either a full path name or a local name within this directory."
	"FileDirectory default fileOrDirectoryExists: Smalltalk sourcesName"

	| fName dir |
	DirectoryClass splitName: filenameOrPath to:
		[:filePath :name |
			fName := name.
			filePath isEmpty
				ifTrue: [dir := self]
				ifFalse: [dir := FileDirectory on: filePath]].

	^ (dir includesKey: fName) or: [ fName = '' and:[ dir entries size > 1]]
]

{ #category : #searching }
FileDirectory >> filesContaining: searchString caseSensitive: aBoolean [
	| aList |
	"Search the contents of all files in the receiver and its subdirectories for the search string.  Return a list of paths found.  Make the search case sensitive if aBoolean is true."

	aList := OrderedCollection new.
	self withAllFilesDo: [:stream |
			(stream contentsOfEntireFile includesSubstring: searchString caseSensitive: aBoolean)
				ifTrue:	[aList add: stream name]]
		andDirectoriesDo: [:d | d pathName].
	^ aList

"FileDirectory default filesContaining: 'includesSubstring:'  caseSensitive: true"
]

{ #category : #'file stream creation' }
FileDirectory >> forceNewFileNamed: localFileName [
	"Open the file with the given name in this directory for writing.  If it already exists, delete it first without asking."

	^ FileStream concreteStream forceNewFileNamed: (self fullNameFor: localFileName)

]

{ #category : #'file stream creation' }
FileDirectory >> forceNewFileNamed: localFileName do: aBlock [
	"Open the file with the given name in this directory for writing.  If it already exists, delete it first without asking and pass it as argument to aBlock."

	^ FileStream concreteStream forceNewFileNamed: (self fullNameFor: localFileName) do: aBlock

]

{ #category : #enumeration }
FileDirectory >> fullName [
	"Return the full name of this directory."

	^pathName asSqueakPathName

]

{ #category : #'file name utilities' }
FileDirectory >> fullNameFor: fileName [
	"Return a corrected, fully-qualified name for the given file name. If the given name is already a full path (i.e., it contains a delimiter character), assume it is already a fully-qualified name. Otherwise, prefix it with the path to this directory. In either case, correct the local part of the file name."
	"Details: Note that path relative to a directory, such as '../../foo' are disallowed by this algorithm.  Also note that this method is tolerent of a nil argument -- is simply returns nil in this case."

	| correctedLocalName prefix |
	fileName ifNil: [^ nil].
	DirectoryClass splitName: fileName to:
		[:filePath :localName |
			correctedLocalName := localName isEmpty 
				ifFalse: [self checkName: localName fixErrors: true]
				ifTrue: [localName].
			prefix := self fullPathFor: filePath].
	prefix isEmpty
		ifTrue: [^correctedLocalName].
	prefix last = self pathNameDelimiter
		ifTrue:[^ prefix, correctedLocalName]
		ifFalse:[^ prefix, self slash, correctedLocalName]
]

{ #category : #enumeration }
FileDirectory >> fullNamesOfAllFilesInSubtree [
	"Answer a collection containing the full names of all the files in the subtree of the file system whose root is this directory."

	| result todo dir |
	result := OrderedCollection new: 100.
	todo := OrderedCollection with: self.
	[todo size > 0] whileTrue: [
		dir := todo removeFirst.
		dir fileNames do: [:n | result add: (dir fullNameFor: n)].
		dir directoryNames do: [:n | todo add: (dir directoryNamed: n)]].
	^ result asArray

]

{ #category : #'path access' }
FileDirectory >> fullPathFor: path [
	^path isEmpty ifTrue:[pathName asSqueakPathName] ifFalse:[path]
]

{ #category : #'file operations' }
FileDirectory >> getMacFileTypeAndCreator: fileName [ 
	| results typeString creatorString |
	"get the Macintosh file type and creator info for the file with the given name. Fails if the file does not exist or if the type and creator type arguments are not strings of length 4. Does nothing on other platforms (where the underlying primitive is a noop)."
	"FileDirectory default getMacFileNamed: 'foo'"

	typeString := ByteArray new: 4 withAll: ($? asInteger).
	creatorString := ByteArray new: 4 withAll: ($? asInteger).
	[self primGetMacFileNamed: (self fullNameFor: fileName) asVmPathName
		type: typeString
		creator: creatorString.] ensure: 
		[typeString := typeString asString. 
		creatorString := creatorString asString].
	results := Array with: typeString convertFromSystemString with: creatorString convertFromSystemString.
	^results

]

{ #category : #private }
FileDirectory >> hasEntries [
	"Return true if this directory has entries or false."
	"FileDirectory default hasEntries"

	^(self primLookupEntryIn: pathName asVmPathName index: 1) ~~ nil
]

{ #category : #testing }
FileDirectory >> hasFiles [
	"Return true if we find an entry that is a file, false otherwise"
	"FileDirectory default hasFiles"

	self entriesDo: [ :entry |entry isDirectory ifFalse: [^true] ] .
	^false
]

{ #category : #testing }
FileDirectory >> hasSubDirectories [
	"Return true if we find an entry that is a directory, false otherwise"
	"FileDirectory default hasSubDirectories"

	self entriesDo: [ :entry |entry isDirectory ifTrue: [^true] ] .
	^false
]

{ #category : #comparing }
FileDirectory >> hash [
	"Hash is reimplemented because #= is reimplemented"
	^pathName asString asLowercase hash
]

{ #category : #testing }
FileDirectory >> includesKey: localName [
	"Answer true if this directory includes a file or directory of the given name. Note that the name should be a local file name, in contrast with fileExists:, which takes either local or full-qualified file names."
	"(FileDirectory on: Smalltalk vmPath) includesKey: 'SqueakV2.sources'"
	^(self directoryEntryForName: localName) notNil
]

{ #category : #testing }
FileDirectory >> isAFileNamed: fName [
	^FileStream isAFileNamed: (self fullNameFor: fName)
]

{ #category : #testing }
FileDirectory >> isCaseSensitive [
	"Return true if file names are treated case sensitive"
	^self class isCaseSensitive
]

{ #category : #'file name utilities' }
FileDirectory >> isLegalFileName: aString [ 
	"Answer true if the given string is a legal file name."

	^ (self checkName: aString fixErrors: true) = aString

]

{ #category : #testing }
FileDirectory >> isRemoteDirectory [
	"answer whatever the receiver is a remote directory"
	^ false
]

{ #category : #'file name utilities' }
FileDirectory >> isTypeFile [
	^true
]

{ #category : #enumeration }
FileDirectory >> keysDo: nameBlock [
	"Evaluate the given block for each file or directory name in this directory."

	^ self fileAndDirectoryNames do: nameBlock

]

{ #category : #'file name utilities' }
FileDirectory >> lastNameFor: baseFileName extension: extension [
	"Assumes a file name includes a version number encoded as '.' followed by digits 
	preceding the file extension.  Increment the version number and answer the new file name.
	If a version number is not found, set the version to 1 and answer a new file name"

	| files splits |

	files := self fileNamesMatching: (baseFileName,'*', self class dot, extension).
	splits := files 
			collect: [:file | self splitNameVersionExtensionFor: file]
			thenSelect: [:split | (split at: 1) = baseFileName].
	splits isEmpty ifTrue: [ ^nil ].
	^(baseFileName, '.', ((splits detectMax: [ :each | each at: 2]) at: 2) asString, self class dot, extension) asFileName
]

{ #category : #enumeration }
FileDirectory >> localName [
	"Return the local name of this directory."

	^FileDirectory localNameFor: pathName asSqueakPathName
]

{ #category : #'file directory' }
FileDirectory >> localNameFor: fullName [
	"Return the local part the given name."

	^self class localNameFor: fullName
]

{ #category : #enumeration }
FileDirectory >> matchingEntries: criteria [
	"Ignore the filter criteria for now"
	^self entries
]

{ #category : #'path access' }
FileDirectory >> mimeTypes [

	^ #('text/directory')
]

{ #category : #'file operations' }
FileDirectory >> mimeTypesFor: fileName [
	"Return a list of MIME types applicable to the receiver. This default implementation uses the file name extension to figure out what we're looking at but specific subclasses may use other means of figuring out what the type of some file is. Some systems like the macintosh use meta data on the file to indicate data type"

	| idx ext dot |
	ext := ''.
	dot := self class extensionDelimiter.
	idx := fileName findLast: [:ch| ch = dot].
	idx = 0 ifFalse: [ext := fileName copyFrom: idx+1 to: fileName size].
	^ StandardMIMEMappings at: ext asLowercase ifAbsent: [nil]
]

{ #category : #'path access' }
FileDirectory >> name [
	"Compatibility with StandardFileStream >> #name to be used, for example, for drop event handling."
	
	^ self fullName
]

{ #category : #'file stream creation' }
FileDirectory >> newFileNamed: localFileName [
	"Create a new file with the given name in this directory."

	^ FileStream concreteStream newFileNamed: (self fullNameFor: localFileName)

]

{ #category : #'file stream creation' }
FileDirectory >> newFileNamed: localFileName do: aBlock [
	"Create a new file with the given name in this directory and pass it as argument to aBlock."

	^ FileStream concreteStream newFileNamed: (self fullNameFor: localFileName) do: aBlock

]

{ #category : #'file name utilities' }
FileDirectory >> nextNameFor: baseFileName extension: extension [
	"Assumes a file name includes a version number encoded as '.' followed by digits 
	preceding the file extension.  Increment the version number and answer the new file name.
	If a version number is not found, set the version to 1 and answer a new file name"

	| files splits version |

	files := self fileNamesMatching: (baseFileName,'*', self class dot, extension).
	splits := files 
			collect: [:file | self splitNameVersionExtensionFor: file]
			thenSelect:
					[:split |
					 self isCaseSensitive 
						ifTrue:[(split at: 1) = baseFileName]
						ifFalse:[(split at: 1) match: baseFileName]].
	version := splits isEmpty 
				ifTrue: [1]
				ifFalse: [((splits detectMax: [ :each | each at: 2 ]) at: 2) + 1].
	^ (baseFileName, '.', version asString, self class dot, extension) asFileName
]

{ #category : #'file stream creation' }
FileDirectory >> oldFileNamed: localFileName [
	"Open the existing file with the given name in this directory."

	^ FileStream concreteStream oldFileNamed: (self fullNameFor: localFileName)

]

{ #category : #'file stream creation' }
FileDirectory >> oldFileNamed: localFileName do: aBlock [
	"Open the existing file with the given name in this directory and pass it as argument to aBlock."

	^ FileStream concreteStream oldFileNamed: (self fullNameFor: localFileName) do: aBlock

]

{ #category : #'file stream creation' }
FileDirectory >> oldFileOrNoneNamed: localFileName [
	"If the file exists, answer a read-only FileStream on it. If it doesn't, answer nil."

	^ FileStream concreteStream oldFileOrNoneNamed: (self fullNameFor: localFileName)

]

{ #category : #'path access' }
FileDirectory >> on: path [
	"Answer another instance"

	^self class on: (self fullPathFor: path)
]

{ #category : #'path access' }
FileDirectory >> pathFromUrl: aFileUrl [
	
	^String streamContents: [ :s | | first |
		first := false.
		aFileUrl path do: [ :p |
			first ifTrue: [ s nextPut: self pathNameDelimiter ].
			first := true.
			s nextPutAll: p ] ].
]

{ #category : #'path access' }
FileDirectory >> pathName [
	"Return the path from the root of the file system to this directory."

	^ pathName asSqueakPathName.


]

{ #category : #'path access' }
FileDirectory >> pathNameDelimiter [
	"Return the delimiter character for this kind of directory. This depends on the current platform."

	^ self class pathNameDelimiter

]

{ #category : #'path access' }
FileDirectory >> pathParts [
	"Return the path from the root of the file system to this directory as an array of directory names."

	^ pathName asSqueakPathName findTokens: self pathNameDelimiter asString
]

{ #category : #private }
FileDirectory >> primCreateDirectory: fullPath [
	"Create a directory named by the given path. Fail if the path is bad or if a file or directory by that name already exists."

 	<primitive: 'primitiveDirectoryCreate' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #private }
FileDirectory >> primDeleteDirectory: fullPath [
	"Delete the directory named by the given path. Fail if the path is bad or if a directory by that name does not exist."

 	<primitive: 'primitiveDirectoryDelete' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #private }
FileDirectory >> primDeleteFileNamed: aFileName [
	"Delete the file of the given name. Return self if the primitive succeeds, nil otherwise."

	<primitive: 'primitiveFileDelete' module: 'FilePlugin'>
	^ nil

]

{ #category : #private }
FileDirectory >> primGetMacFileNamed: fileName type: typeString creator: creatorString [
	"Get the Macintosh file type and creator info for the file with the given name. Fails if the file does not exist or if the type and creator type arguments are not strings of length 4. This primitive is Mac specific; it is a noop on other platforms."

 	<primitive: 'primitiveDirectoryGetMacTypeAndCreator' module: 'FilePlugin'>


]

{ #category : #private }
FileDirectory >> primLookupEntryIn: fullPath index: index [
	"Look up the index-th entry of the directory with the given fully-qualified path (i.e., starting from the root of the file hierarchy) and return an array containing:

	<name> <creationTime> <modificationTime> <dirFlag> <fileSize>

	The empty string enumerates the top-level files or drives. (For example, on Unix, the empty path enumerates the contents of '/'. On Macs and PCs, it enumerates the mounted volumes/drives.)

	The creation and modification times are in seconds since the start of the Smalltalk time epoch. DirFlag is true if the entry is a directory. FileSize the file size in bytes or zero for directories. The primitive returns nil when index is past the end of the directory. It fails if the given path is bad."

 	<primitive: 'primitiveDirectoryLookup' module: 'FilePlugin'>
	^ #badDirectoryPath


]

{ #category : #private }
FileDirectory >> primLookupEntryIn: fullPath name: fName [

	"Look up <fName> (a simple file name) in the directory identified by <fullPath>
 	 and return an array containing:

	<fName> <creationTime> <modificationTime> <dirFlag> <fileSize>

	On Unix, the empty path denotes '/'. 
      On Macs and PCs, it is the container of the system volumes.)

	The creation and modification times are in seconds since the start of the Smalltalk time epoch. DirFlag is true if the entry is a directory. FileSize the file size in bytes or zero for directories. The primitive returns nil when index is past the end of the directory. It fails if the given path is bad."

 	<primitive: 'primitiveDirectoryEntry' module: 'FilePlugin'>

	^ #primFailed		"to distinguish from nil"


]

{ #category : #private }
FileDirectory >> primRename: oldFileFullName to: newFileFullName [ 
	"Rename the file of the given name to the new name. Fail if there is no file of the old name or if there is an existing file with the new name.
	Changed to return nil instead of failing ar 3/21/98 18:04"

	<primitive: 'primitiveFileRename' module: 'FilePlugin'>
	^nil
]

{ #category : #private }
FileDirectory >> primSetMacFileNamed: fileName type: typeString creator: creatorString [
	"Set the Macintosh file type and creator info for the file with the given name. Fails if the file does not exist or if the type and creator type arguments are not strings of length 4. This primitive is Mac specific; it is a noop on other platforms."

 	<primitive: 'primitiveDirectorySetMacTypeAndCreator' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #printing }
FileDirectory >> printOn: aStream [ 
	"Refer to the comment in Object|printOn:."

	aStream nextPutAll: self class name.
	aStream nextPutAll: ' on '.
	pathName asSqueakPathName printOn: aStream.

]

{ #category : #'file operations' }
FileDirectory >> putFile: file1 named: destinationFileName [
	"Copy the contents of the existing fileStream into the file destinationFileName in this directory.  fileStream can be anywhere in the fileSystem."

	| file2 |
	file1 binary.
	(file2 := self newFileNamed: destinationFileName) ifNil: [^ false].
	file2 binary.
	self copyFile: file1 toFile: file2.
	file1 close.
	file2 close.
	^ true

]

{ #category : #'file operations' }
FileDirectory >> putFile: file1 named: destinationFileName retry: aBool [
	"Copy the contents of the existing fileStream into the file destinationFileName in this directory.  fileStream can be anywhere in the fileSystem.  No retrying for local file systems."

	^ self putFile: file1 named: destinationFileName

]

{ #category : #'file stream creation' }
FileDirectory >> readOnlyFileNamed: localFileName [
	"Open the existing file with the given name in this directory for read-only access."

	^ FileStream concreteStream readOnlyFileNamed: (self fullNameFor: localFileName)

]

{ #category : #'file stream creation' }
FileDirectory >> readOnlyFileNamed: localFileName do: aBlock [
	"Open the existing file with the given name in this directory for read-only access and pass it as argument to aBlock."

	^ FileStream concreteStream readOnlyFileNamed: (self fullNameFor: localFileName) do: aBlock

]

{ #category : #'file name utilities' }
FileDirectory >> realUrl [
	"Senders expect url without trailing slash - #url returns slash"
	| url |
	url := self url.
	url last = $/ ifTrue:[^url copyFrom: 1 to: url size-1].
	^url
]

{ #category : #'file operations' }
FileDirectory >> recursiveDelete [
	"Delete the this directory, recursing down its tree."
	self directoryNames
		do: [:dn | (self directoryNamed: dn) recursiveDelete].
	self deleteLocalFiles.
	"should really be some exception handling for directory deletion, but no 
	support for it yet"
	self containingDirectory deleteDirectory: self localName
]

{ #category : #'file name utilities' }
FileDirectory >> relativeNameFor: aFileName [
	"Return the full name for aFileName, assuming that aFileName is a name relative to me."
	aFileName isEmpty ifTrue: [ ^pathName asSqueakPathName].
	^aFileName first = self pathNameDelimiter
		ifTrue: [ pathName asSqueakPathName, aFileName ]
		ifFalse: [ pathName asSqueakPathName, self slash, aFileName ]

]

{ #category : #'file name utilities' }
FileDirectory >> relativeNameIfAbsoluteFor: aFileName [
	"Answer either the relative name for aFileName, if aFileName names a file in me or
	 subdirectories, or aFileName's absolute path if it isn't in me or subdirectories.
	 P.S. Ths is what I'd expect relativeNameFor: to do, but it is taken and means
	 exactly the opposite, i.e. the absolute path for a relative name."
	| fullNameSize fullName fileNameSize |
	(aFileName isEmpty or: [aFileName first ~= self pathNameDelimiter]) ifTrue:
		[self error: 'this method expects an absolute filename'].
	fullNameSize := (fullName := self fullName) size.
	fileNameSize := aFileName size.
	^(aFileName beginsWith: fullName)
		ifTrue: [(fileNameSize = fullNameSize
				or: [fileNameSize - 1 = fullNameSize
					and: [(aFileName at: fileNameSize) = self pathNameDelimiter]])
					ifTrue: [self class currentDirectoryNickname]
					ifFalse: [aFileName copyFrom: fullNameSize + 2 to: fileNameSize]]
		ifFalse: [aFileName]

	"SourceFiles asArray collect: [:sf| FileDirectory default relativeNameIfAbsoluteFor: sf fullName]"
	"FileDirectory default relativeNameIfAbsoluteFor: FileDirectory default fullName" "should be dot"
	"FileDirectory default relativeNameIfAbsoluteFor: FileDirectory default fullName, FileDirectory default slash" "should also be dot"
]

{ #category : #'file operations' }
FileDirectory >> rename: oldFileName toBe: newFileName [ 
	"Rename the file of the given name to the new name. Fail if there is no file of the old name or if there is an existing file with the new name."
	"Modified for retry after GC ar 3/21/98 18:09"
	| replaceIt oldName newName |
	oldName := self fullNameFor: oldFileName.
	newName := self fullNameFor: newFileName.
	((self fileExists: oldFileName) or: [ (self directoryExists: oldFileName) ]) ifFalse: [ ^ self error: 'Attempt to rename a non-existent file or directory.' ].
	(self fileExists: newFileName) ifTrue:
		[replaceIt := (ReplaceExistingFileException fileName: newFileName) signal.
		replaceIt ifTrue: [ self deleteFileNamed: newFileName ]	ifFalse: [ ^ self ]].
	(self directoryExists: newFileName) ifTrue: [ FileExistsException signal: newFileName, ' already exists.' ].
	(StandardFileStream
		retryWithGC:
			[ self
				primRename: oldName asVmPathName
				to: newName asVmPathName ]
		until: [ : result | result notNil ]
		forFileNamed: oldName) ~~ nil ifTrue: [ ^ self ].
	^ self error: 'Failed to rename file'
]

{ #category : #'file operations' }
FileDirectory >> setMacFileNamed: fileName type: typeString creator: creatorString [
	"Set the Macintosh file type and creator info for the file with the given name. Fails if the file does not exist or if the type and creator type arguments are not strings of length 4. Does nothing on other platforms (where the underlying primitive is a noop)."
	"FileDirectory default setMacFileNamed: 'foo' type: 'TEXT' creator: 'ttxt'"

 	self primSetMacFileNamed: (self fullNameFor: fileName) asVmPathName
		type: typeString convertToSystemString
		creator: creatorString convertToSystemString.

]

{ #category : #private }
FileDirectory >> setPathName: pathString [

	pathName := FilePath pathName: pathString.

]

{ #category : #'path access' }
FileDirectory >> slash [
	^self class slash
]

{ #category : #'file directory' }
FileDirectory >> sleep [
	"Leave the FileList window.  Do nothing.  Disk directories do not have to be shut down."

]

{ #category : #'file name utilities' }
FileDirectory >> splitNameVersionExtensionFor: fileName [
	" answer an array with the root name, version # and extension.
	See comment in nextSequentialNameFor: for more details"

	| baseName version extension i j |

	baseName := self class baseNameFor: fileName.
	extension := self class extensionFor: fileName.
	i := j := baseName findLast: [:c | c isDigit not].
	i = 0
		ifTrue: [version := 0]
		ifFalse:
			[(baseName at: i) = $.
				ifTrue:
					[version := (baseName copyFrom: i+1 to: baseName size) asNumber.
					j := j - 1]
				ifFalse: [version := 0].
			baseName := baseName copyFrom: 1 to: j].
	^ Array with: baseName with: version with: extension
]

{ #category : #enumeration }
FileDirectory >> statsForDirectoryTree: rootedPathName [
	"Return the size statistics for the entire directory tree starting at the given root. The result is a three element array of the form: (<number of folders><number of files><total bytes in all files>). This method also serves as an example of how recursively enumerate a directory tree."
	"FileDirectory default statsForDirectoryTree: '\smalltalk'"

	| dirs files bytes todo entries p |
	dirs := files := bytes := 0.
	todo := OrderedCollection with: rootedPathName.
	[todo isEmpty] whileFalse: [
		p := todo removeFirst.
		entries := self directoryContentsFor: p.
		entries do: [:entry |
			entry isDirectory
				ifTrue: [
					todo addLast: p , self pathNameDelimiter asString , entry name.
					dirs := dirs + 1]
				ifFalse: [
					files := files + 1.
					bytes := bytes + entry fileSize]]].
	^ Array with: dirs with: files with: bytes

]

{ #category : #private }
FileDirectory >> storeServerEntryOn: stream [
	
	stream
		nextPutAll: 'name:'; tab; nextPutAll: self localName; cr;
		nextPutAll: 'directory:'; tab; nextPutAll: self pathName; cr;
		nextPutAll: 'type:'; tab; nextPutAll: 'file'; cr
]

{ #category : #'file operations' }
FileDirectory >> upLoadProject: projectFile named: destinationFileName resourceUrl: resUrl retry: aBool [
	"Copy the contents of the existing fileStream into the file destinationFileName in this directory.  fileStream can be anywhere in the fileSystem.  No retrying for local file systems."

	| result |
	result := self putFile: projectFile named: destinationFileName.
	[self
		setMacFileNamed: destinationFileName
		type: 'SOBJ'
		creator: 'FAST']
		on: Error
		do: [ "ignore" ].
	^result
]

{ #category : #squeaklets }
FileDirectory >> updateProjectInfoFor: aProject [

	"only swiki servers for now"
]

{ #category : #'file directory' }
FileDirectory >> wakeUp [
	"Entering a FileList window.  Do nothing.  Disk directories do not have to be awakened."

]

{ #category : #searching }
FileDirectory >> withAllFilesDo: fileStreamBlock andDirectoriesDo: directoryBlock [

	"For the receiver and all it's subdirectories evaluate directoryBlock.
	For a read only file stream on each file within the receiver 
	and it's subdirectories evaluate fileStreamBlock."

	| todo dir |

	todo := OrderedCollection with: self.
	[todo size > 0] whileTrue: [
		dir := todo removeFirst.
		directoryBlock value: dir.
		dir fileNames do: [: n | 
			fileStreamBlock value: 
				(FileStream readOnlyFileNamed: (dir fullNameFor: n))].
		dir directoryNames do: [: n | 
			todo add: (dir directoryNamed: n)]]


]

{ #category : #enumeration }
FileDirectory >> withAllSubdirectoriesCollect: aBlock [
	"Evaluate aBlock with each of the directories in the subtree of the file system whose root is this directory.
	Answer the results of these evaluations."

	| result todo dir |
	result := OrderedCollection new: 100.
	todo := OrderedCollection with: self.
	[todo size > 0] whileTrue: [
		dir := todo removeFirst.
		result add: (aBlock value: dir).
		dir directoryNames do: [:n | todo add: (dir directoryNamed: n)]].
	^ result

]

{ #category : #squeaklets }
FileDirectory >> writeProject: aProject inFileNamed: fileNameString fromDirectory: localDirectory [ 
	"write aProject (a file version can be found in the file named fileNameString in localDirectory)"
	aProject
		writeFileNamed: fileNameString
		fromDirectory: localDirectory
		toServer: self
]

{ #category : #utilities }
FileDirectory >> writeSourceCodeFrom: aStream baseName: baseName isSt: stOrCsFlag useHtml: useHtml [
	"Write the source code from aStream into a file.'foo $🖕'"

	| extension  fileName |

	stOrCsFlag ifTrue: [
		extension := (FileDirectory dot, FileStream st).
	] ifFalse: [
		extension := (FileDirectory dot, FileStream cs).
	].
	useHtml ifTrue: [extension := FileDirectory dot, 'html'].
	
	fileName := baseName , extension. "oh, for a decent file name system"
	self newFileNamed: fileName do:[:f|
		f nextPutAll: aStream contents]
]
