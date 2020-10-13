"
Subinstances of me are members in a ZipArchive.
They represent different data sources:
	* ZipDirectoryMember -- a directory to be added to a zip file
	* ZipFileMember -- a file or directory that is already in a zip file
	* ZipNewFilemember -- a file that is to be added to a zip file
	* ZipStringMember -- a string that is to be added to a zip file

They can write their data to another stream either copying, compressing,
or decompressing as desired.
"
Class {
	#name : #ZipArchiveMember,
	#superclass : #ArchiveMember,
	#instVars : [
		'lastModFileDateTime',
		'fileAttributeFormat',
		'versionMadeBy',
		'versionNeededToExtract',
		'bitFlag',
		'compressionMethod',
		'desiredCompressionMethod',
		'desiredCompressionLevel',
		'internalFileAttributes',
		'externalFileAttributes',
		'cdExtraField',
		'localExtraField',
		'fileComment',
		'crc32',
		'compressedSize',
		'uncompressedSize',
		'writeLocalHeaderRelativeOffset',
		'readDataRemaining'
	],
	#pools : [
		'ZipFileConstants'
	],
	#category : #'Compression-Archives'
}

{ #category : #'instance creation' }
ZipArchiveMember class >> newFromDirectory: aFileName [
	^ZipDirectoryMember newNamed: aFileName
]

{ #category : #'instance creation' }
ZipArchiveMember class >> newFromFile: aFileName [
	^ZipNewFileMember newNamed: aFileName
]

{ #category : #'instance creation' }
ZipArchiveMember class >> newFromString: aString named: aFileName [
	^ZipStringMember newFrom: aString named: aFileName
]

{ #category : #'instance creation' }
ZipArchiveMember class >> newFromZipFile: stream named: fileName [
	^ZipFileMember newFrom: stream named: fileName
]

{ #category : #private }
ZipArchiveMember >> asDirectory [
	^ZipDirectoryMember new copyFrom: self
]

{ #category : #accessing }
ZipArchiveMember >> centralDirectoryHeaderSize [

	| systemFileName systemFileComment systemCdExtraField |
	systemFileName := fileName asVmPathName.
	systemFileComment := fileComment convertToSystemString.
	systemCdExtraField := cdExtraField.
	^ 46 + systemFileName size + systemCdExtraField size + systemFileComment size

]

{ #category : #accessing }
ZipArchiveMember >> clearExtraFields [
	cdExtraField := ''.
	localExtraField := ''.
]

{ #category : #'private-writing' }
ZipArchiveMember >> compressDataTo: aStream [
	"Copy my deflated data to the given stream."
	| encoder startPos endPos |

	encoder := ZipWriteStream on: aStream.
	startPos := aStream position.

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data := self readRawChunk: (4096 min: readDataRemaining).
		encoder nextPutAll: data asByteArray.
		readDataRemaining := readDataRemaining - data size.
	].
	encoder finish. "not close!"
	endPos := aStream position.
	compressedSize := endPos - startPos.
	crc32 := encoder crc.

]

{ #category : #accessing }
ZipArchiveMember >> compressedSize [
	"Return the compressed size for this member.
	This will not be set for members that were constructed from strings
	or external files until after the member has been written."
	^compressedSize
]

{ #category : #accessing }
ZipArchiveMember >> compressionMethod [
	"Returns my compression method. This is the method that is
	currently being used to compress my data.

	This will be CompressionStored for added string or file members,
	or CompressionStored or CompressionDeflated (others are possible but not handled)"

	^compressionMethod
]

{ #category : #accessing }
ZipArchiveMember >> contentStream [
	"Answer my contents as a text stream.
	Default is no conversion, since we don't know what the bytes mean."

	^self contentStreamFromEncoding: 'latin1'

]

{ #category : #accessing }
ZipArchiveMember >> contentStreamFromEncoding: encodingName [
	"Answer my contents as a text stream.
	Interpret the raw bytes with given encodingName"

	| s |
	s := MultiByteBinaryOrTextStream on: (String new: self uncompressedSize).
	s converter:  (TextConverter newForEncoding: encodingName).
	self extractTo: s.
	s reset.
	^ s

]

{ #category : #reading }
ZipArchiveMember >> contents [
	"Answer my contents as a string - assuming a Latin1 encoding."
	| s |
	s := (ByteArray new: self uncompressedSize) writeStream.
	self extractTo: s.
	^s contents asString
]

{ #category : #reading }
ZipArchiveMember >> contentsFrom: start to: finish [
	"Answer part of my contents as a string - assuming a Latin1 encoding.."
	| s |
	s := (ByteArray new: finish - start + 1) writeStream.
	self extractTo: s from: start to: finish.
	^s contents asString
]

{ #category : #'private-writing' }
ZipArchiveMember >> copyDataTo: aStream [

	compressionMethod = CompressionStored ifTrue: [ ^self copyDataWithCRCTo: aStream ].

	self copyRawDataTo: aStream.
]

{ #category : #'private-writing' }
ZipArchiveMember >> copyDataWithCRCTo: aStream [
	"Copy my data to aStream. Also set the CRC-32.
	Only used when compressionMethod = desiredCompressionMethod = CompressionStored"

	uncompressedSize := compressedSize := readDataRemaining.

	crc32 := 16rFFFFFFFF.

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data := self readRawChunk: (4096 min: readDataRemaining).
		aStream nextPutAll: data.
		crc32 := ZipWriteStream updateCrc: crc32 from: 1 to: data size in: data.
		readDataRemaining := readDataRemaining - data size.
	].

	crc32 := crc32 bitXor: 16rFFFFFFFF.

]

{ #category : #'private-writing' }
ZipArchiveMember >> copyRawDataTo: aStream [

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data := self readRawChunk: (4096 min: readDataRemaining).
		aStream nextPutAll: data.
		readDataRemaining := readDataRemaining - data size.
	].

]

{ #category : #'private-writing' }
ZipArchiveMember >> copyRawDataTo: aStream from: start to: finish [

	readDataRemaining := readDataRemaining min: finish - start + 1.

	self readRawChunk: start - 1.

	[ readDataRemaining > 0 ] whileTrue: [ | data |
		data := self readRawChunk: (32768 min: readDataRemaining).
		aStream nextPutAll: data.
		readDataRemaining := readDataRemaining - data size.
	].

]

{ #category : #accessing }
ZipArchiveMember >> crc32 [
	^crc32
]

{ #category : #accessing }
ZipArchiveMember >> crc32String [
	| hexString |
	hexString := crc32 storeStringHex.
	^('00000000' copyFrom: 1 to: 11 - (hexString size)) , (hexString copyFrom: 4 to: hexString size)
]

{ #category : #accessing }
ZipArchiveMember >> desiredCompressionLevel [
	^desiredCompressionLevel
]

{ #category : #accessing }
ZipArchiveMember >> desiredCompressionLevel: aNumber [
	"Set my desiredCompressionLevel
	This is the method that will be used to write.
	Returns prior desiredCompressionLevel.

	Valid arguments are 0 (CompressionLevelNone) through 9,
	including 6 (CompressionLevelDefault).

	0 (CompressionLevelNone) will change the desiredCompressionMethod
	to CompressionStored. All other arguments will change the
	desiredCompressionMethod to CompressionDeflated."

	| old |
	old := desiredCompressionLevel.
	desiredCompressionLevel := aNumber.
	desiredCompressionMethod := (aNumber > 0)
		ifTrue: [ CompressionDeflated ]
		ifFalse: [ CompressionStored ].
	^old
]

{ #category : #accessing }
ZipArchiveMember >> desiredCompressionMethod [
	"Get my desiredCompressionMethod.
	This is the method that will be used to write"

	^desiredCompressionMethod
]

{ #category : #accessing }
ZipArchiveMember >> desiredCompressionMethod: aNumber [
	"Set my desiredCompressionMethod
	This is the method that will be used to write.
	Answers prior desiredCompressionMethod.

	Only CompressionDeflated or CompressionStored are valid arguments.

	Changing to CompressionStored will change my desiredCompressionLevel
	to CompressionLevelNone; changing to CompressionDeflated will change my
	desiredCompressionLevel to CompressionLevelDefault."

	| old |
	old := desiredCompressionMethod.
	desiredCompressionMethod := aNumber.
	desiredCompressionLevel := (aNumber = CompressionDeflated)
			ifTrue: [ CompressionLevelDefault ]
			ifFalse: [ CompressionLevelNone ].
	compressionMethod = CompressionStored ifTrue: [ compressedSize := uncompressedSize ].
	^old.
]

{ #category : #private }
ZipArchiveMember >> dosToSqueakTime: dt [
	"DOS years start at 1980, so add 1980."
	| year mon mday hour min sec date time |

	year := (( dt bitShift: -25 ) bitAnd: 16r7F ).
	mon := (( dt bitShift: -21 ) bitAnd: 16r0F ).
	mday := (( dt bitShift: -16 ) bitAnd: 16r1F ).
	date := Date newDay: mday month: mon year: year+1980.

	hour := (( dt bitShift: -11 ) bitAnd: 16r1F ).
	min := (( dt bitShift: -5 ) bitAnd: 16r3F ).
	sec := (( dt bitShift: 1 ) bitAnd: 16r3E ).
	time := ((( hour * 60 ) + min ) * 60 ) + sec.

	^date asSeconds + time

	
]

{ #category : #private }
ZipArchiveMember >> endRead [
	readDataRemaining := 0.
]

{ #category : #extraction }
ZipArchiveMember >> extractInDirectory: dir [
	self extractToFileNamed: self localFileName inDirectory: dir

]

{ #category : #extraction }
ZipArchiveMember >> extractInDirectory: aDirectory overwrite: overwriteAll [
	"Extract this entry into the given directory. Answer #okay, #failed, #abort, or #retryWithOverwrite."
	| path fileDir file index localName |
	path := fileName findTokens:'/'.
	localName := path last.
	fileDir := path allButLast inject: aDirectory into:[:base :part| base directoryNamed: part].
	fileDir assureExistence.
	file := [fileDir newFileNamed: localName] on: FileExistsException do:[:ex| ex return: nil].
	file ifNil:[
		overwriteAll ifFalse:[
			[index := UIManager default chooseFrom: {
						'Yes, overwrite'. 
						'No, don''t overwrite'. 
						'Overwrite ALL files'.
						'Cancel operation'
					} lines: #(2) title: fileName, ' already exists. Overwrite?'.
			index == nil] whileTrue.
			index = 4 ifTrue:[^#abort].
			index = 3 ifTrue:[^#retryWithOverwrite].
			index = 2 ifTrue:[^#okay].
		].
		file := [fileDir forceNewFileNamed: localName] on: Error do:[:ex| ex return].
		file ifNil:[^#failed].
	].
	self extractTo: file.
	file close.
	^#okay
]

{ #category : #extraction }
ZipArchiveMember >> extractTo: aStream [
	| oldCompression |
	self isEncrypted ifTrue: [ self error: 'encryption is unsupported' ].
	aStream binary.
	oldCompression := self desiredCompressionMethod: CompressionStored.
	self rewindData.
	self writeDataTo: aStream.
	self desiredCompressionMethod: oldCompression.
	self endRead.
]

{ #category : #extraction }
ZipArchiveMember >> extractTo: aStream from: start to: finish [
	| oldCompression |
	self isEncrypted ifTrue: [ self error: 'encryption is unsupported' ].
	aStream binary.
	oldCompression := self desiredCompressionMethod: CompressionStored.
	self rewindData.
	self writeDataTo: aStream from: start to: finish.
	self desiredCompressionMethod: oldCompression.
	self endRead.
]

{ #category : #extraction }
ZipArchiveMember >> extractToFileNamed: aFileName [
	self extractToFileNamed: aFileName inDirectory: FileDirectory default.
]

{ #category : #accessing }
ZipArchiveMember >> extractToFileNamed: aLocalFileName inDirectory: dir [
	| stream fullName fullDir |
	self isEncrypted ifTrue: [ ^self error: 'encryption unsupported' ].
	fullName := dir fullNameFor: aLocalFileName.
	fullDir := FileDirectory forFileName: fullName.
	fullDir assureExistence.
	self isDirectory ifFalse: [
		stream := fullDir forceNewFileNamed: (FileDirectory localNameFor: fullName).
		self extractTo: stream.
		stream close.
	] ifTrue: [ fullDir assureExistence ]

]

{ #category : #accessing }
ZipArchiveMember >> fileComment [
	^fileComment
]

{ #category : #accessing }
ZipArchiveMember >> fileComment: aString [
	fileComment := aString
]

{ #category : #testing }
ZipArchiveMember >> hasDataDescriptor [
	^ (bitFlag bitAnd: 8)	~= 0 "GPBF:=HAS:=DATA:=DESCRIPTOR:=MASK"
]

{ #category : #initialization }
ZipArchiveMember >> initialize [
	super initialize.
	lastModFileDateTime := 0.
	fileAttributeFormat := FaUnix.
	versionMadeBy := 20.
	versionNeededToExtract := 20.
	bitFlag := 0.
	compressionMethod := CompressionStored.
	desiredCompressionMethod := CompressionDeflated.
	desiredCompressionLevel := CompressionLevelDefault.
	internalFileAttributes := 0.
	externalFileAttributes := 0.
	fileName := ''.
	cdExtraField := ''.
	localExtraField := ''.
	fileComment := ''.
	crc32 := 0.
	compressedSize := 0.
	uncompressedSize := 0.
	self unixFileAttributes: DefaultFilePermissions.
]

{ #category : #testing }
ZipArchiveMember >> isDirectory [
	^false
]

{ #category : #testing }
ZipArchiveMember >> isEncrypted [
	"Return true if this member is encrypted (this is unsupported)"
	^ (bitFlag bitAnd: 1) ~= 0
]

{ #category : #testing }
ZipArchiveMember >> isTextFile [
	"Returns true if I am a text file.
	Note that this module does not currently do anything with this flag
	upon extraction or storage.
	That is, bytes are stored in native format whether or not they came
	from a text file."
	^ (internalFileAttributes bitAnd: 1) ~= 0

]

{ #category : #testing }
ZipArchiveMember >> isTextFile: aBoolean [
	"Set whether I am a text file.
	Note that this module does not currently do anything with this flag
	upon extraction or storage.
	That is, bytes are stored in native format whether or not they came
	from a text file."
	internalFileAttributes := aBoolean
		ifTrue: [ internalFileAttributes bitOr: 1 ]
		ifFalse: [ internalFileAttributes bitAnd: 1 bitInvert ]

]

{ #category : #accessing }
ZipArchiveMember >> lastModTime [
	"Return my last modification date/time stamp,
	converted to Squeak seconds"

	^self dosToSqueakTime: lastModFileDateTime
]

{ #category : #accessing }
ZipArchiveMember >> localFileName [
	"Answer my fileName in terms of the local directory naming convention"
	| localName |
	localName := fileName copyReplaceAll: '/' with: FileDirectory slash.
	^(fileName first = $/)
		ifTrue: [ FileDirectory default class makeAbsolute: localName ]
		ifFalse: [ FileDirectory default class makeRelative: localName ]
]

{ #category : #testing }
ZipArchiveMember >> looksLikeDirectory [
	^false
]

{ #category : #private }
ZipArchiveMember >> mapPermissionsFromUnix: unixPerms [
	^ unixPerms bitShift: 16.
]

{ #category : #private }
ZipArchiveMember >> mapPermissionsToUnix: dosPerms [
	^ dosPerms bitShift: -16.
]

{ #category : #'private-writing' }
ZipArchiveMember >> openStreamWhile: aBlock [
	^ aBlock value
]

{ #category : #private }
ZipArchiveMember >> readRawChunk: n [
	self subclassResponsibility
]

{ #category : #'private-writing' }
ZipArchiveMember >> refreshLocalFileHeaderTo: aStream [
	"Re-writes my local header to the given stream.
	To be called after writing the data stream.
	Assumes that fileName and localExtraField sizes didn't change since last written."

	| here systemFileName |
	here := aStream position.
	systemFileName := fileName asVmPathName.
	aStream position: writeLocalHeaderRelativeOffset.

	aStream nextPutAll: LocalFileHeaderSignature.
	aStream nextLittleEndianNumber: 2 put: versionNeededToExtract.
	aStream nextLittleEndianNumber: 2 put: bitFlag.
	aStream nextLittleEndianNumber: 2 put: desiredCompressionMethod.
	aStream nextLittleEndianNumber: 4 put: lastModFileDateTime.
	aStream nextLittleEndianNumber: 4 put: crc32.
	aStream nextLittleEndianNumber: 4 put: (desiredCompressionMethod = CompressionStored
												ifTrue: [ uncompressedSize ] ifFalse: [ compressedSize ]).
	aStream nextLittleEndianNumber: 4 put: uncompressedSize.
	aStream nextLittleEndianNumber: 2 put: systemFileName size.
	aStream nextLittleEndianNumber: 2 put: localExtraField size.

	aStream position: here.

]

{ #category : #private }
ZipArchiveMember >> rewindData [
	readDataRemaining :=  (desiredCompressionMethod = CompressionDeflated
		and: [ compressionMethod = CompressionDeflated ])
			ifTrue: [ compressedSize ]
			ifFalse: [ uncompressedSize ].

]

{ #category : #accessing }
ZipArchiveMember >> setLastModFileDateTimeFrom: aSmalltalkTime [

	lastModFileDateTime := self squeakToDosTime: aSmalltalkTime
]

{ #category : #accessing }
ZipArchiveMember >> splitFileName [
	"Answer my name split on slash boundaries. A directory will have a trailing empty string."
	^ fileName findTokens: '/'.
]

{ #category : #private }
ZipArchiveMember >> squeakToDosTime: secs [
	| dosTime dateTime |

	dateTime := Time dateAndTimeFromSeconds: secs.
	dosTime := (dateTime second seconds) bitShift: -1.
	dosTime := dosTime + ((dateTime second minutes) bitShift: 5).
	dosTime := dosTime + ((dateTime second hours) bitShift: 11).
	dosTime := dosTime + ((dateTime first dayOfMonth) bitShift: 16).
	dosTime := dosTime + ((dateTime first monthIndex) bitShift: 21).
	dosTime := dosTime + (((dateTime first year) - 1980) bitShift: 25).
	^dosTime

]

{ #category : #accessing }
ZipArchiveMember >> uncompressedSize [
	"Return the uncompressed size for this member."
	^uncompressedSize
]

{ #category : #accessing }
ZipArchiveMember >> unixFileAttributes [
	^self mapPermissionsToUnix: externalFileAttributes.
]

{ #category : #accessing }
ZipArchiveMember >> unixFileAttributes: perms [
	| oldPerms newPerms |
	oldPerms := self mapPermissionsToUnix: externalFileAttributes.
	newPerms :=  self isDirectory
			ifTrue: [ (perms bitAnd: FileAttrib bitInvert) bitOr: DirectoryAttrib ]
			ifFalse: [ (perms bitAnd: DirectoryAttrib bitInvert) bitOr: FileAttrib ].
	externalFileAttributes := self mapPermissionsFromUnix: newPerms.
	^oldPerms.
]

{ #category : #'private-writing' }
ZipArchiveMember >> writeCentralDirectoryFileHeaderTo: aStream [
	"C2 v3 V4 v5 V2"

	| systemFileName systemFileComment systemCdExtraField |
	systemFileName := fileName asVmPathName.
	systemFileComment := fileComment convertToSystemString.
	systemCdExtraField := cdExtraField.
	aStream nextPutAll: CentralDirectoryFileHeaderSignature.
	aStream nextLittleEndianNumber: 1 put: versionMadeBy.
	aStream nextLittleEndianNumber: 1 put: fileAttributeFormat.

	aStream nextLittleEndianNumber: 2 put: versionNeededToExtract.
	aStream nextLittleEndianNumber: 2 put: bitFlag.
	aStream nextLittleEndianNumber: 2 put: desiredCompressionMethod.

	aStream nextLittleEndianNumber: 4 put: lastModFileDateTime.

	"These next 3 should have been updated during the write of the data"
	aStream nextLittleEndianNumber: 4 put: crc32.
	aStream nextLittleEndianNumber: 4 put: (desiredCompressionMethod = CompressionStored
												ifTrue: [ uncompressedSize ] ifFalse: [ compressedSize ]).
	aStream nextLittleEndianNumber: 4 put: uncompressedSize.

	aStream nextLittleEndianNumber: 2 put: systemFileName size.
	aStream nextLittleEndianNumber: 2 put: systemCdExtraField size.
	aStream nextLittleEndianNumber: 2 put: systemFileComment size.
	aStream nextLittleEndianNumber: 2 put: 0.		"diskNumberStart"
	aStream nextLittleEndianNumber: 2 put: internalFileAttributes.

	aStream nextLittleEndianNumber: 4 put: externalFileAttributes.
	aStream nextLittleEndianNumber: 4 put: writeLocalHeaderRelativeOffset.

	aStream nextPutAll: systemFileName asByteArray.
	aStream nextPutAll: systemCdExtraField asByteArray.
	aStream nextPutAll: systemFileComment asByteArray.
]

{ #category : #'private-writing' }
ZipArchiveMember >> writeDataDescriptorTo: aStream [
	"This writes a data descriptor to the given stream.
	Assumes that crc32, writeOffset, and uncompressedSize are
	set correctly (they should be after a write).
	Further, the local file header should have the
	GPBF:=HAS:=DATA:=DESCRIPTOR:=MASK (8) bit set."

	aStream nextLittleEndianNumber: 4 put: crc32.
	aStream nextLittleEndianNumber: 4 put: compressedSize.
	aStream nextLittleEndianNumber: 4 put: uncompressedSize.
]

{ #category : #'private-writing' }
ZipArchiveMember >> writeDataTo: aStream [
	"Copy my (possibly inflated or deflated) data to the given stream.
	This might do compression, decompression, or straight copying, depending
	on the values of compressionMethod and desiredCompressionMethod"

	"Note: Do not shortcut this method if uncompressedSize = 0. Even in this case
	data may be produced by the compressor (i.e., '' zipped size > 0) and must
	be stored in the file or else other utilities will treat the zip file as corrupt."

	(compressionMethod = CompressionStored and: [ desiredCompressionMethod = CompressionDeflated ])
		ifTrue: [ ^self compressDataTo: aStream ].

	(compressionMethod = CompressionDeflated and: [ desiredCompressionMethod = CompressionStored ])
		ifTrue: [ ^self uncompressDataTo: aStream ].

	self copyDataTo: aStream.
]

{ #category : #'private-writing' }
ZipArchiveMember >> writeDataTo: aStream from: start to: finish [
	"Copy my (possibly inflated or deflated) data to the given stream.
	But only the specified byte range.
	This might do decompression, or straight copying, depending
	on the values of compressionMethod and desiredCompressionMethod"

	uncompressedSize = 0 ifTrue: [ ^self ].	"nothing to do because no data"
	start > finish ifTrue: [ ^self ].
	start > uncompressedSize ifTrue: [ ^self ].

	(compressionMethod = CompressionStored and: [ desiredCompressionMethod = CompressionDeflated ])
		ifTrue: [ ^self error: 'only supports uncompression or copying right now' ].

	(compressionMethod = CompressionDeflated and: [ desiredCompressionMethod = CompressionStored ])
		ifTrue: [ ^self uncompressDataTo: aStream from: start to: finish ].

	self copyRawDataTo: aStream from: start to: finish.
]

{ #category : #'private-writing' }
ZipArchiveMember >> writeLocalFileHeaderTo: aStream [
	"Write my local header to a file handle.
	Stores the offset to the start of the header in my
	writeLocalHeaderRelativeOffset member."

	| systemFileName |
	systemFileName := fileName asVmPathName.
	aStream nextPutAll: LocalFileHeaderSignature.
	aStream nextLittleEndianNumber: 2 put: versionNeededToExtract.
	aStream nextLittleEndianNumber: 2 put: bitFlag.
	aStream nextLittleEndianNumber: 2 put: desiredCompressionMethod.

	aStream nextLittleEndianNumber: 4 put: lastModFileDateTime.
	aStream nextLittleEndianNumber: 4 put: crc32.
	aStream nextLittleEndianNumber: 4 put: (desiredCompressionMethod = CompressionStored
												ifTrue: [ uncompressedSize ] ifFalse: [ compressedSize ]).
	aStream nextLittleEndianNumber: 4 put: uncompressedSize.

	aStream nextLittleEndianNumber: 2 put: systemFileName size.
	aStream nextLittleEndianNumber: 2 put: localExtraField size.

	aStream nextPutAll: systemFileName asByteArray.
	aStream nextPutAll: localExtraField asByteArray.

]

{ #category : #writing }
ZipArchiveMember >> writeTo: aStream [ 
	self openStreamWhile:
		[ self rewindData.
		writeLocalHeaderRelativeOffset := aStream position.
		self
			 writeLocalFileHeaderTo: aStream ;
			 writeDataTo: aStream ;
			 refreshLocalFileHeaderTo: aStream ]
]
