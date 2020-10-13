Class {
	#name : #GZipReadStream,
	#superclass : #FastInflateStream,
	#pools : [
		'GZipConstants'
	],
	#category : #'Compression-Streams'
}

{ #category : #'fileIn\/Out' }
GZipReadStream class >> fileIn: fullFileName [
	"FileIn the contents of a gzipped file"
	| zipped unzipped |
	zipped := self on: (FileStream readOnlyFileNamed: fullFileName).
	unzipped := MultiByteBinaryOrTextStream with: (zipped contents asString).
	unzipped reset.
	unzipped fileIn.

]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> fileIntoNewChangeSet: fullFileName [
	"FileIn the contents of a gzipped file"
	| zipped unzipped cs |
	cs := Smalltalk at: #ChangesOrganizer ifAbsent: [ ^self ].
	zipped := self on: (FileStream readOnlyFileNamed: fullFileName).
	unzipped := MultiByteBinaryOrTextStream with: zipped contents asString.
	unzipped reset.
	cs newChangesFromStream: unzipped named: (FileDirectory localNameFor: fullFileName)

]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> fileReaderServicesForFile: fullName suffix: suffix [ 
	| services |
	(suffix = 'gz') | (suffix = '*')
		ifFalse: [^ #()].
	services := OrderedCollection new.
	(suffix = '*') | (fullName asLowercase endsWith: '.cs.gz') | (fullName asLowercase endsWith: '.mcs.gz')
		ifTrue: [services add: self serviceFileIn.
			(Smalltalk includesKey: #ChangSet)
				ifTrue: [services add: self serviceFileIntoNewChangeSet]].
	services addAll: self services.
	^ services
]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> saveContents: fullFileName [
	"Save the contents of a gzipped file"
	| zipped buffer unzipped newName |
	newName := fullFileName copyUpToLast: FileDirectory extensionDelimiter.
	unzipped := FileStream newFileNamed: newName.
	unzipped binary.
	zipped := GZipReadStream on: (FileStream readOnlyFileNamed: fullFileName).
	buffer := ByteArray new: 50000.
	'Extracting ' , fullFileName
		displayProgressFrom: 0
		to: zipped sourceStream size
		during: 
			[:bar | 
			[zipped atEnd]
				whileFalse: 
					[bar value: zipped sourceStream position.
					unzipped nextPutAll: (zipped nextInto: buffer)].
			zipped close.
			unzipped close].
	^ newName
]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> serviceDecompressToFile [

	^ FileModifyingSimpleServiceEntry 
				provider: self 
				label: 'decompress to file' translatedNoop
				selector: #saveContents:
				description: 'decompress to file' translatedNoop
]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> serviceFileIn [
	"Answer a service for filing in an entire file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'fileIn entire file' translatedNoop
		selector: #fileIn:
		description: 'file in the entire decompressed contents of the file, which is expected to contain Smalltalk code in fileout ("chunk") format' translatedNoop
		buttonLabel: 'filein' translatedNoop


]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> serviceFileIntoNewChangeSet [
	"Answer a service for filing in an entire file"
	^ SimpleServiceEntry
		provider: self
		label: 'install into new change set' translatedNoop
		selector: #fileIntoNewChangeSet:
		description: 'install the decompressed contents of the file as a body of code in the image: create a new change set and file-in the selected file into it' translatedNoop
		buttonLabel: 'install' translatedNoop
]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> services [

	^ Array 
		with: self serviceViewDecompress
		with: self serviceDecompressToFile
	
]

{ #category : #'fileIn\/Out' }
GZipReadStream class >> uncompressedFileName: fullName [
	^((fullName endsWith: '.gz') and: [self confirm: ('{1}
appears to be a compressed file.
Do you want to uncompress it?' translated format:{fullName})])
		ifFalse: [fullName]
		ifTrue:[self saveContents: fullName]
]

{ #category : #'class initialization' }
GZipReadStream class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #initialize }
GZipReadStream >> on: aCollection from: firstIndex to: lastIndex [
	"Check the header of the GZIP stream."
	| method magic flags length |
	super on: aCollection from: firstIndex to: lastIndex.
	crc := 16rFFFFFFFF.
	magic := self nextBits: 16.
	(magic = GZipMagic) 
		ifFalse:[^self error:'Not a GZipped stream'].
	method := self nextBits: 8.
	(method = GZipDeflated)
		ifFalse:[^self error:'Bad compression method'].
	flags := self nextBits: 8.
	(flags anyMask: GZipEncryptFlag) 
		ifTrue:[^self error:'Cannot decompress encrypted stream'].
	(flags anyMask: GZipReservedFlags)
		ifTrue:[^self error:'Cannot decompress stream with unknown flags'].
	"Ignore stamp, extra flags, OS type"
	self nextBits: 16; nextBits: 16. "stamp"
	self nextBits: 8. "extra flags"
	self nextBits: 8. "OS type"
	(flags anyMask: GZipContinueFlag) "Number of multi-part archive - ignored"
		ifTrue:[self nextBits: 16]. 
	(flags anyMask: GZipExtraField) "Extra fields - ignored"
		ifTrue:[	length := self nextBits: 16.
				1 to: length do:[:i| self nextBits: 8]].
	(flags anyMask: GZipNameFlag) "Original file name - ignored"
		ifTrue:[[(self nextBits: 8) = 0] whileFalse].
	(flags anyMask: GZipCommentFlag) "Comment - ignored"
		ifTrue:[[(self nextBits: 8) = 0] whileFalse].

]

{ #category : #crc }
GZipReadStream >> updateCrc: oldCrc from: start to: stop in: aCollection [
	"Answer an updated CRC for the range of bytes in aCollection"
	^ZipWriteStream updateCrc: oldCrc from: start to: stop in: aCollection.
]

{ #category : #crc }
GZipReadStream >> verifyCrc [
	| stored |
	stored := 0.
	0 to: 24 by: 8 do: [ :i |
		sourcePos >= sourceLimit ifTrue: [ ^ self crcError: 'No checksum (proceed to ignore)' ].
		stored := stored + (self nextByte bitShift: i) ].
	stored := stored bitXor: 16rFFFFFFFF.
	stored = crc ifFalse: [ ^ self crcError: 'Wrong checksum (proceed to ignore)' ].
	^stored
]
