"
Provides a simple, platform-independent, interface to a file system. The instance variable rwmode, inherited from class PositionableStream, here is used to hold a Boolean -- true means opened for read-write, false means opened for read-only.  2/12/96 sw

I implement a simple read buffering scheme with the variables defined in PositionableStream (which are unused in me otherwise) in the following way:
	collection	<ByteString> or <ByteArray>	This is the buffer.
	position	<Integer>	The relative position in the buffer. Greater or equal to zero.
	readLimit	<Integer>	The number of bytes buffered. Greater or equal to zero.
Read buffering is enabled with #enableReadBuffering, disabled with #disableReadBuffering and it is enabled by default. The buffer is filled when a read attempt of an unbuffered absolute position is requested, or when a negative repositioning is made (with #position: with an argument < than the current absolute position) to an absolute position which is not buffered. In the first case, the buffer is positioned to the given absolute position. In the latter case the repositioning is made to the requested absolute position minus fourth of the buffer size. This means that further small negative repositionings won't result in buffer flushing. This is really useful when filing in code.
The read buffer is flushed (#flushReadBuffer) whenever a write attempt is made.
The buffer state is valid if and only if collection is not nil and position < readLimit.
"
Class {
	#name : #StandardFileStream,
	#superclass : #FileStream,
	#instVars : [
		'name',
		'fileID',
		'buffer1',
		'lastWritten'
	],
	#classVars : [
		'Registry'
	],
	#category : #'Files-Kernel'
}

{ #category : #'file creation' }
StandardFileStream class >> fileNamed: fileName [
	"Open a file with the given name for reading and writing. If the name has no directory part, then the file will be created in the default directory. If the file already exists, its prior contents may be modified or replaced, but the file will not be truncated on close."

	^ self new open: (self fullName: fileName) forWrite: true

]

{ #category : #'file creation' }
StandardFileStream class >> forceNewFileNamed: fileName [ 
	"Create a new file with the given name, and answer a stream opened 
	for writing on that file. If the file already exists, delete it without 
	asking before creating the new file."
	| dir localName fullName f |
	fullName := self fullName: fileName.
	(self isAFileNamed: fullName)
		ifFalse: 
			[f := self new open: fullName forWrite: true.
			^ f
				ifNil: ["Failed to open the file"
					(FileDoesNotExistException fileName: fullName) signal]].
	dir := FileDirectory forFileName: fullName.
	localName := FileDirectory localNameFor: fullName.
	dir
		deleteFileNamed: localName
		ifAbsent: [(CannotDeleteFileException new
			messageText: 'Could not delete the old version of file ' , fullName) signal].
	f := self new open: fullName forWrite: true.
	^ f
		ifNil: ["Failed to open the file"
			(FileDoesNotExistException fileName: fullName) signal]
]

{ #category : #'file creation' }
StandardFileStream class >> isAFileNamed: fileName [
	"Answer true if a file of the given name exists."

	^ FileDirectory default fileExists: fileName
]

{ #category : #'file creation' }
StandardFileStream class >> newFileNamed: fileName [
 	"Create a new file with the given name, and answer a stream opened for writing on that file. If the file already exists, ask the user what to do."

	| fullName |
	fullName := self fullName: fileName.

	^(self isAFileNamed: fullName)
		ifTrue: ["file already exists:"
			(FileExistsException fileName: fullName fileClass: self) signal]
		ifFalse: [self new open: fullName forWrite: true]


]

{ #category : #'file creation' }
StandardFileStream class >> oldFileNamed: fileName [
	"Open an existing file with the given name for reading and writing. If the name has no directory part, then the file will be created in the default directory. If the file already exists, its prior contents may be modified or replaced, but the file will not be truncated on close."

	| fullName |
	fullName := self fullName: fileName.

	^(self isAFileNamed: fullName)
		ifTrue: [self new open: fullName forWrite: true]
		ifFalse: ["File does not exist..."
			(FileDoesNotExistException fileName: fullName) signal]
]

{ #category : #'file creation' }
StandardFileStream class >> readOnlyFileNamed: fileName [ 
	"Open an existing file with the given name for reading."

	| fullName f |
	fullName := self fullName: fileName.
	f := self new open: fullName forWrite: false.
	^ f
		ifNil: ["File does not exist..."
			((FileDoesNotExistException fileName: fullName) readOnly: true) signal].

	"StandardFileStream readOnlyFileNamed: 'kjsd.txt' "
]

{ #category : #registry }
StandardFileStream class >> register: anObject [
	
	^self registry add: anObject
]

{ #category : #registry }
StandardFileStream class >> registry [
	
	^Registry ifNil: [ Registry := WeakRegistry new ]
]

{ #category : #registry }
StandardFileStream class >> retryWithGC: execBlock until: testBlock forFileNamed: fullName [
	"Re-implemented to only force GC if a file with the given name exists"
	| blockValue foundIt |
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue:[^blockValue].
	"See if we have a file with the given name"
	foundIt := Registry keys "hold on strongly for now" 
		anySatisfy:[:file| file name sameAs: fullName].
	foundIt ifFalse:[^blockValue].
	Smalltalk garbageCollectMost.
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue:[^blockValue].
	Smalltalk garbageCollect.
	^execBlock value.
]

{ #category : #registry }
StandardFileStream class >> unregister: anObject [
	
	^self registry remove: anObject ifAbsent: nil
]

{ #category : #printing }
StandardFileStream >> << aCollection [
	aCollection putOn: self
]

{ #category : #finalization }
StandardFileStream >> actAsExecutor [
	super actAsExecutor.
	name := nil.
]

{ #category : #'properties-setting' }
StandardFileStream >> ascii [
	"Read and/or write in ASCII mode."
	buffer1
		ifNil: [ buffer1 := ByteString new: 1 ]
		ifNotNil: [ ByteString adoptInstance: buffer1 ].
	collection ifNotNil: [ ByteString adoptInstance: collection ].
	lastWritten ifNotNil:
		[ lastWritten isInteger ifTrue: [ lastWritten := lastWritten asCharacter ] ]
]

{ #category : #'read, write, position' }
StandardFileStream >> atEnd [
	"Answer whether the receiver is at its end.  "
	
	collection ifNotNil: [
		position < readLimit ifTrue: [ ^false ] ].
	^self primAtEnd: fileID
]

{ #category : #'read, write, position' }
StandardFileStream >> basicNext [
	"Answer the next byte from this file, or nil if at the end of the file."
	
	| count |
	<primitive: 65>
	collection ifNotNil: [
		position < readLimit 
			ifFalse: [ 
				readLimit := self primRead: fileID into: collection startingAt: 1 count: collection size.
				position := 0.
				readLimit = 0 ifTrue: [ ^nil ] ].
		^collection at: (position := position + 1) ].	
	count := self primRead: fileID into: buffer1 startingAt: 1 count: 1.
	count = 1
		ifTrue: [ ^buffer1 at: 1 ]
		ifFalse: [ ^nil ]
]

{ #category : #'properties-setting' }
StandardFileStream >> binary [
	"Read and/or write in binary mode."
	buffer1
		ifNil: [ buffer1 := ByteArray new: 1 ]
		ifNotNil: [ ByteArray adoptInstance: buffer1 ].
	collection ifNotNil: [ ByteArray adoptInstance: collection ].
	lastWritten ifNotNil:
		[ lastWritten isCharacter ifTrue: [ lastWritten := lastWritten asInteger ] ]
]

{ #category : #'open\/close' }
StandardFileStream >> close [
	"Close this file."

	fileID ifNotNil: [
		collection ifNotNil: [
			readLimit := position := 0 ].
		self primClose: fileID.
		self unregister.
		fileID := nil].

]

{ #category : #'open\/close' }
StandardFileStream >> closed [
	"Answer true if this file is closed."

	^ fileID == nil or: [ (self primSizeNoError: fileID) == nil ]

]

{ #category : #private }
StandardFileStream >> collectionSpecies [
	"Answer the species of collection into which the receiver can stream"
	
	^buffer1 species
]

{ #category : #access }
StandardFileStream >> directory [
	"Return the directory containing this file."

	^ FileDirectory forFileName: self fullName

]

{ #category : #access }
StandardFileStream >> directoryUrl [

	^ self directory url
]

{ #category : #private }
StandardFileStream >> disableReadBuffering [

	collection ifNotNil: [
		position < readLimit
			ifTrue: [
				| currentPosition |
				currentPosition := self position.
				collection := readLimit := position := nil.
				self position: currentPosition ]
			ifFalse: [
				collection := readLimit := position := nil ] ]
		
]

{ #category : #private }
StandardFileStream >> enableReadBuffering [

	collection ifNil: [
		buffer1 ifNotNil: [
			collection := self collectionSpecies new: 2048 ] ].
	readLimit := position := 0
]

{ #category : #'open\/close' }
StandardFileStream >> ensureOpen [
	"Make sure that this file really is open."

	self closed ifTrue: [^ self reopen].
	(self primSizeNoError: fileID) ifNotNil: [^ self].
	self reopen.

]

{ #category : #access }
StandardFileStream >> file [
	"Answer the object representing the receiver's file.  Need for compatibility with some calls -- check senders.  2/14/96 sw"

	^ self
]

{ #category : #finalization }
StandardFileStream >> finalize [
	self primCloseNoError: fileID.
]

{ #category : #'read, write, position' }
StandardFileStream >> findString: string [
	"Fast version of #upToAll: to find a String in a file starting from the beginning.
	Returns the position and also sets the position there.
	If string is not found 0 is returned and position is unchanged."

	| pos buffer count oldPos sz |
	oldPos := self position.
	self reset.
	sz := self size.
	pos := 0.
	buffer := String new: 2000.
	[ buffer := self nextInto: buffer.
	(count := buffer findString: string) > 0
		ifTrue: ["Found the string part way into buffer"
			self position: pos.
			self next: count - 1.
			^self position ].
	pos := ((pos + 2000 - string size) min: sz).
	self position: pos.
	pos = sz] whileFalse.
	"Never found it, and hit end of file"
	self position: oldPos.
	^0
]

{ #category : #'read, write, position' }
StandardFileStream >> findStringFromEnd: string [
	"Fast version to find a String in a file starting from the end.
	Returns the position and also sets the position there.
	If string is not found 0 is returned and position is unchanged."

	| pos buffer count oldPos |
	oldPos := self position.
	self setToEnd.
	pos := self position.
	[ pos := ((pos - 2000 + string size) max: 0).  "the [+ string size] allows for the case where the end of the search string is at the beginning of the current buffer"
	self position: pos.
	buffer := self next: 2000.
	(count := buffer findString: string) > 0
		ifTrue: ["Found the string part way into buffer"
			self position: pos.
			self next: count-1.  "use next instead of position:, so that CrLfFileStream can do its magic if it is being used"
			^self position].
	pos = 0] whileFalse.
	"Never found it, and hit beginning of file"
	self position: oldPos.
	^0
]

{ #category : #'read, write, position' }
StandardFileStream >> flush [
	"Flush pending changes"
	^self primFlush: fileID
]

{ #category : #private }
StandardFileStream >> flushReadBuffer [

	collection ifNotNil: [
		position < readLimit ifTrue: [
			| currentPosition |
			currentPosition := self position.
			position := readLimit := 0.
			self primSetPosition: fileID to: currentPosition ] ]
]

{ #category : #access }
StandardFileStream >> fullName [
	"Answer this file's full path name."

	^ name

]

{ #category : #'properties-setting' }
StandardFileStream >> getFileType [
	"On the Macintosh, get the file type and creator of this file. On other platforms, do nothing."

	^FileDirectory default
		getMacFileTypeAndCreator: self fullName
		

]

{ #category : #'properties-setting' }
StandardFileStream >> insertLineFeeds [
	"(FileStream oldFileNamed: 'BBfix2.st') insertLineFeeds"
	| s crLf f |
	crLf := String crlf.
	s := self next: self size.
	self close.
	f := FileStream newFileNamed: self name.
	s linesDo: [:line | f nextPutAll: line; nextPutAll: crLf].
	f close
]

{ #category : #'properties-setting' }
StandardFileStream >> isBinary [
	^buffer1 isString not
]

{ #category : #access }
StandardFileStream >> isDirectory [
	"Answer whether the receiver represents a directory.  For the post-transition case, uncertain what to do.  2/14/96 sw"
	^ false
]

{ #category : #'properties-setting' }
StandardFileStream >> isReadOnly [

	^ rwmode not

]

{ #category : #access }
StandardFileStream >> localName [
	^ name ifNotNil: [(name findTokens: FileDirectory pathNameDelimiter asString) last]
]

{ #category : #access }
StandardFileStream >> name [
	"Answer this file's full path name."

	^ name

]

{ #category : #'read, write, position' }
StandardFileStream >> next [
	"Answer the next byte from this file, or nil if at the end of the file."

	^ self basicNext
]

{ #category : #'read, write, position' }
StandardFileStream >> next: n [
	"Return a string with the next n characters of the filestream in it.  1/31/96 sw"
	^ self nextInto: (self collectionSpecies new: n)
]

{ #category : #'read, write, position' }
StandardFileStream >> next: anInteger putAll: aString startingAt: startIndex [
	"Store the next anInteger elements from the given collection."
	rwmode ifFalse: [^ self error: 'Cannot write a read-only file'].
	anInteger > 0 ifFalse: [ ^aString ].
	collection ifNotNil: [
		position < readLimit ifTrue: [ self flushReadBuffer ] ].	
	self primWrite: fileID from: aString startingAt: startIndex count: anInteger.
	^aString
]

{ #category : #'read, write, position' }
StandardFileStream >> nextPut: element [
	"Write the given element (character or integer) to this file."

	rwmode ifFalse: [^ self error: 'Cannot write a read-only file'].
	collection ifNotNil:
		[position < readLimit ifTrue: [ self flushReadBuffer ] ].
	buffer1 at: 1 put: element.
	self primWrite: fileID from: buffer1 startingAt: 1 count: 1.
	lastWritten := element.
	^ element

]

{ #category : #'read, write, position' }
StandardFileStream >> nextPutAll: aCollection [
	"Write all the elements of the given collection (a String or IntegerArray of some kind) to this file."
	| size |
	rwmode ifFalse: [^ self error: 'Cannot write a read-only file'].
	collection ifNotNil:
		[position < readLimit ifTrue: [ self flushReadBuffer]].
	(size := aCollection basicSize) > 0 ifTrue:
		[self primWrite: fileID from: aCollection startingAt: 1 count: size.
		 lastWritten := aCollection at: size].
	^ aCollection
]

{ #category : #'read, write, position' }
StandardFileStream >> nextWordsInto: aBitmap [
	"Note: The file primitives automatically adjust for word based objects."

	self next: aBitmap basicSize into: aBitmap startingAt: 1.
	aBitmap restoreEndianness.
	^ aBitmap
]

{ #category : #'open\/close' }
StandardFileStream >> open [
	"For compatibility with a few existing things.  2/14/96 sw"

	^ self reopen
]

{ #category : #'open\/close' }
StandardFileStream >> open: fileName forWrite: writeMode [ 
	"Open the file with the given name. If writeMode is true, allow writing, otherwise open the file in read-only mode."
	"Changed to do a GC and retry before failing ar 3/21/98 17:25"
	| f |
	f := fileName asVmPathName.

	fileID := StandardFileStream retryWithGC:[self primOpen: f writable: writeMode] 
					until:[:id| id notNil] 
					forFileNamed: fileName.
	fileID ifNil: [^ nil].  "allows sender to detect failure"
	name := fileName.
	self register.
	rwmode := writeMode.
	buffer1 := String new: 1.
	self enableReadBuffering
	
]

{ #category : #'open\/close' }
StandardFileStream >> openOnHandle: aFileID name: streamName forWrite: writeMode [
	"Initialize the file with the given handle. If writeMode is true then
	 allow writing, otherwise put the file in read-only mode.
	 N.B. Do _not_ register the stream.  We do not want it to be
	 closed implicitly (e.g. on GC).  There may be multiple instances
	 accessing the same stream.  The stream is not a file."
	fileID := aFileID.
	name := streamName.
	rwmode := writeMode.
	buffer1 := String new: 1.
	self enableReadBuffering
]

{ #category : #'open\/close' }
StandardFileStream >> openReadOnly [
	"Open the receiver as a read-only file.  1/31/96 sw"

	^ self open: name forWrite: false
]

{ #category : #'read, write, position' }
StandardFileStream >> padToEndWith: aChar [
	"On the Mac, files do not truncate.  One can delete the old file and write a new one, but sometime deletion fails (file still open? file stale?).  This is a sad compromise.  Just let the file be the same length but pad it with a harmless character."

	| pad |
	self atEnd ifTrue: [^ self].
	pad := self isBinary 
		ifTrue: [aChar asCharacter asciiValue]	"ok for char or number"
		ifFalse: [aChar asCharacter].
	self nextPutAll: (self collectionSpecies new: ((self size - self position) min: 20000) 
							withAll: pad).
]

{ #category : #'read, write, position' }
StandardFileStream >> peek [
	"Answer what would be returned if the message next were sent to the receiver. If the receiver is at the end, answer nil."
	
	| next |
	next := self basicNext ifNil: [ ^nil ].
	collection ifNotNil: [
		"#basicNext ensures that this is enough"
		position := position - 1.
		^next ].
	self skip: -1.
	^next
]

{ #category : #access }
StandardFileStream >> peekFor: item [ 
	"Answer false and do not advance if the next element is not equal to item, or if this stream is at the end.  If the next element is equal to item, then advance over it and return true"

	"self atEnd ifTrue: [^ false]. -- SFStream will give nil"
	(self next ifNil: [ ^false ]) = item ifTrue: [ ^true ].
	self skip: -1.
	^ false
]

{ #category : #'read, write, position' }
StandardFileStream >> peekLast [
	"Answer the item just put at the end of the stream, if any."

	^lastWritten
]

{ #category : #'read, write, position' }
StandardFileStream >> position [
	"Return the receiver's current file position.  2/12/96 sw"

	collection ifNotNil: [
		position < readLimit ifTrue: [
			^(self primGetPosition: fileID) - readLimit + position ] ].
	^self primGetPosition: fileID
]

{ #category : #'read, write, position' }
StandardFileStream >> position: pos [
	"Set the receiver's position as indicated.  2/12/96 sw"

	collection ifNotNil: [
		position < readLimit ifTrue: [
			| newPosition |
			newPosition := pos - (self primGetPosition: fileID) + readLimit.
			newPosition < 0 ifTrue: [
					| offsetPos |
					self primSetPosition: fileID to: (offsetPos := pos - (collection size // 4) max: 0).
					readLimit := self primRead: fileID into: collection startingAt: 1 count: collection size.
					position := pos - offsetPos.
					^self ].
			newPosition < readLimit 
				ifTrue: [
					position := newPosition.
					^self ]
				ifFalse: [
					readLimit := position := 0 ] ] ].
	^self primSetPosition: fileID to: pos
]

{ #category : #primitives }
StandardFileStream >> primAtEnd: id [
	"Answer true if the file position is at the end of the file."

	<primitive: 'primitiveFileAtEnd' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
StandardFileStream >> primClose: id [
	"Close this file."

	<primitive: 'primitiveFileClose' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
StandardFileStream >> primCloseNoError: id [
	"Close this file. Don't raise an error if the primitive fails."

	<primitive: 'primitiveFileClose' module: 'FilePlugin'>

]

{ #category : #'dnd requests' }
StandardFileStream >> primDropRequestFileHandle: dropIndex [
	"Primitive. Return the (read-only) file handle for some file that was just dropped onto Squeak.
	Fail if dropIndex is out of range or the primitive is not supported."
	<primitive: 'primitiveDropRequestFileHandle' module:'DropPlugin'>
	^nil
]

{ #category : #primitives }
StandardFileStream >> primFlush: id [
	"Flush pending changes to the disk"
	| p |
	<primitive: 'primitiveFileFlush' module: 'FilePlugin'>
	"In some OS's seeking to 0 and back will do a flush"
	p := self position.
	self position: 0; position: p
]

{ #category : #primitives }
StandardFileStream >> primGetPosition: id [
	"Get this files current position."

	<primitive: 'primitiveFileGetPosition' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
StandardFileStream >> primOpen: fileName writable: writableFlag [
	"Open a file of the given name, and return the file ID obtained.
	If writableFlag is true, then
		if there is none with this name, then create one
		else prepare to overwrite the existing from the beginning
	otherwise
		if the file exists, open it read-only
		else return nil"

	<primitive: 'primitiveFileOpen' module: 'FilePlugin'>
	^ nil

]

{ #category : #primitives }
StandardFileStream >> primRead: id into: byteArray startingAt: startIndex count: count [
	"Read up to count bytes of data from this file into the given string or byte array starting at the given index. Answer the number of bytes actually read."

	<primitive: 'primitiveFileRead' module: 'FilePlugin'>
	self closed ifTrue: [^ self error: 'File is closed'].
	self error: 'File read failed'.

]

{ #category : #primitives }
StandardFileStream >> primSetPosition: id to: anInteger [
	"Set this file to the given position."

	<primitive: 'primitiveFileSetPosition' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
StandardFileStream >> primSize: id [
	"Answer the size of this file."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
StandardFileStream >> primSizeNoError: id [
	"Answer the size of this file. Answer nil if the primitive fails; this indicates that the file handle has become stale."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	^ nil

]

{ #category : #primitives }
StandardFileStream >> primSync: id [
	"Call fsync to really, really, flush pending changes to the disk"
	| p |
	<primitive: 'primitiveFileSync' module: 'FilePlugin'>
	"In some OS's seeking to 0 and back will do a flush. Maybe that will help if we dont have the primitives"
	p := self position.
	self position: 0; position: p
]

{ #category : #primitives }
StandardFileStream >> primTruncate: id to: anInteger [
	"Truncate this file to the given position."

	<primitive: 'primitiveFileTruncate' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
StandardFileStream >> primWrite: id from: stringOrByteArray startingAt: startIndex count: count [
	"Write count bytes onto this file from the given string or byte array starting at the given index. Answer the number of bytes written."

	<primitive: 'primitiveFileWrite' module: 'FilePlugin'>
	(FileWriteError fileName: name)
		signal: (self closed
			ifTrue: [ 'File ', name, ' is closed' ]
			ifFalse: [ 'File ', name, ' write failed' ])
]

{ #category : #access }
StandardFileStream >> printOn: aStream [
	"Put a printed version of the receiver onto aStream.  1/31/96 sw"

	aStream nextPutAll: self class name; nextPutAll: ': '; print: name
]

{ #category : #'read, write, position' }
StandardFileStream >> readInto: byteArray startingAt: startIndex count: count [
	"Read into the given array as specified, and return the count
	actually transferred.  index and count are in units of bytes or
	longs depending on whether the array is Bitmap, String or ByteArray"
	
	| nRead newN newStartIndex |
	collection 
		ifNil: [ 
			newN := count.
			newStartIndex := startIndex ]
		ifNotNil: [
			byteArray class isBytes 
				ifFalse: [ 
					position < readLimit ifTrue: [ self flushReadBuffer ].
					newN := count.
					newStartIndex := startIndex ]
				ifTrue: [
					| available |
					(available := readLimit - position) > 0 
						ifFalse: [ available := 0 ]
						ifTrue: [
							| bufferedCount |
							bufferedCount := count min: available.
							byteArray
								replaceFrom: startIndex
								to: startIndex + bufferedCount - 1
								with: collection
								startingAt: position + 1.
							position := position + bufferedCount.
							bufferedCount = count ifTrue: [ ^count ] ].
					newN := count - available.
					newStartIndex := startIndex + available ] ].
	nRead := self primRead: fileID into: byteArray startingAt: newStartIndex count: newN.
	^nRead + (count - newN)
]

{ #category : #'properties-setting' }
StandardFileStream >> readOnly [
	"Make this file read-only."

	rwmode := false.

]

{ #category : #'read, write, position' }
StandardFileStream >> readOnlyCopy [
	self flush.	"Some linux open a truncated readOnlyCopy. Force it to take latest bytes written into account."
	^ self class readOnlyFileNamed: self name.

]

{ #category : #'properties-setting' }
StandardFileStream >> readWrite [
	"Make this file writable."

	rwmode := true.

]

{ #category : #registry }
StandardFileStream >> register [
	^self class register: self
]

{ #category : #'open\/close' }
StandardFileStream >> reopen [
	"Close and reopen this file. The file position is reset to zero."
	"Details: Files that were open when a snapshot occurs are no longer valid when the snapshot is resumed. This operation re-opens the file if that has happened."

	fileID ifNotNil: [
		collection ifNotNil: [
			position < readLimit ifTrue: [
				self flushReadBuffer ] ].
		self primCloseNoError: fileID ].
	self open: name forWrite: rwmode.

]

{ #category : #'dnd requests' }
StandardFileStream >> requestDropStream: dropIndex [
	"Return a read-only stream for some file the user has just dropped onto Squeak."
	| rawName |
	rawName := self class primDropRequestFileName: dropIndex.
	name := rawName vmPathToSqueakPath.
	fileID := self primDropRequestFileHandle: dropIndex.
	fileID == nil ifTrue:[^nil].
	self register.
	rwmode := false.
	buffer1 := String new: 1.
	self enableReadBuffering

]

{ #category : #access }
StandardFileStream >> reset [
	self ensureOpen.
	self position: 0.
]

{ #category : #'properties-setting' }
StandardFileStream >> setFileTypeToObject [
	"On the Macintosh, set the file type and creator of this file to be a Squeak object file. On other platforms, do nothing. Setting the file type allows Squeak object files to be sent as email attachments and launched by double-clicking. On other platforms, similar behavior is achieved by creating the file with the '.sqo' file name extension."

	FileDirectory default
		setMacFileNamed: self fullName
		type: 'SOBJ'
		creator: 'FAST'.

]

{ #category : #'read, write, position' }
StandardFileStream >> setToEnd [
	"Set the position of the receiver to the end of file.  1/31/96 sw"

	self position: self size
]

{ #category : #access }
StandardFileStream >> size [
	"Answer the size of the file in characters.  2/12/96 sw"

	^ self primSize: fileID
]

{ #category : #'read, write, position' }
StandardFileStream >> skip: n [
	"Set the character position to n characters from the current position.
	Error if not enough characters left in the file.  1/31/96 sw"

	collection ifNotNil: [
		position < readLimit ifTrue: [
			| newPosition |
			((newPosition := position + n) >= 0 and: [ newPosition < readLimit ])
				ifTrue: [ 
					position := newPosition.
					^self ] ] ].
	self position: self position + n
]

{ #category : #'read, write, position' }
StandardFileStream >> sync [
	"Really, really, flush pending changes"
	^self flush; primSync: fileID
]

{ #category : #'read, write, position' }
StandardFileStream >> truncate [
	"Truncate to zero"

	^ self truncate: 0
]

{ #category : #'read, write, position' }
StandardFileStream >> truncate: pos [
	"Truncate to this position"

	self position: pos.
	^self primTruncate: fileID to: pos
]

{ #category : #registry }
StandardFileStream >> unregister [
	^self class unregister: self
]

{ #category : #'read, write, position' }
StandardFileStream >> upTo: delimiter [

	| pos |
	collection ifNotNil: [
		(position < readLimit and: [
			(pos := collection indexOf: delimiter startingAt: position + 1) <= readLimit and: [
				pos > 0 ] ]) ifTrue: [
					^collection copyFrom: position + 1 to: (position := pos) - 1 ] ].
	^self collectionSpecies streamContents: [ :stream |
		| buffer bytesRead |
		buffer := collection 
			ifNil: [ self collectionSpecies new: 2000 ]
			ifNotNil: [
				position < readLimit ifTrue: [
					stream next: readLimit - position putAll: collection startingAt: position + 1.
					position := readLimit ].
				collection ].
		[
			bytesRead := self readInto: buffer startingAt: 1 count: buffer size.
			((pos := buffer indexOf: delimiter startingAt: 1) = 0 or: [ pos > bytesRead ])
				ifTrue: [ 
					stream next: bytesRead putAll: buffer startingAt: 1.
					bytesRead > 0 "Try again if we could read something last time." ]
				ifFalse: [
					stream next: pos - 1 putAll: buffer startingAt: 1.
					collection 
						ifNil: [ self skip: pos - bytesRead ]
						ifNotNil: [
							position := pos.
							readLimit := bytesRead ].
					false "Found the delimiter." ] ] whileTrue ]
]

{ #category : #'read, write, position' }
StandardFileStream >> upToAnyOf: delimiters do: aBlock [

	| pos |
	collection ifNotNil: [
		(position < readLimit and: [
			(pos := collection indexOfAnyOf: delimiters startingAt: position + 1) <= readLimit and: [
				pos > 0 ] ]) ifTrue: [
					| result |
					result := collection copyFrom: position + 1 to: (position := pos) - 1 .
					aBlock value: (collection at: position).
					^result ] ].
	^self collectionSpecies streamContents: [ :stream |
		| buffer bytesRead |
		buffer := collection 
			ifNil: [ self collectionSpecies new: 2000 ]
			ifNotNil: [
				position < readLimit ifTrue: [
					stream next: readLimit - position putAll: collection startingAt: position + 1.
					position := readLimit ].
				collection ].
		[
			bytesRead := self readInto: buffer startingAt: 1 count: buffer size.
			((pos := buffer indexOfAnyOf: delimiters startingAt: 1) = 0 or: [ pos > bytesRead ])
				ifTrue: [ 
					stream next: bytesRead putAll: buffer startingAt: 1.
					bytesRead > 0 "Try again if we could read something last time." ]
				ifFalse: [
					stream next: pos - 1 putAll: buffer startingAt: 1.
					collection 
						ifNil: [ self skip: pos - bytesRead ]
						ifNotNil: [
							position := pos.
							readLimit := bytesRead ].
					false "Found the delimiter." ] ] whileTrue.
		bytesRead = 0 ifFalse: [
			aBlock value: (buffer at: pos) ] ]
]

{ #category : #'read, write, position' }
StandardFileStream >> upToEnd [
	"Answer a subcollection from the current access position through the last element of the receiver."

	^self collectionSpecies streamContents: [ :newStream |
		| next |
		[ (next := self next) == nil ] whileFalse: [
			newStream nextPut: next ] ]
]

{ #category : #updating }
StandardFileStream >> update: aParameter [
	super update: aParameter.
	aParameter == #appendEntry 
		ifTrue: [self flush]. "Transcript is being redirected to this steam, stdout"
	
]

{ #category : #'read, write, position' }
StandardFileStream >> verbatim: aString [
	"A version of nextPutAll that can be called knowing it won't call nextPut: "

	^ self nextPutAll: aString

]
