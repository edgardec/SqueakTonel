Class {
	#name : #GZipWriteStream,
	#superclass : #ZipWriteStream,
	#pools : [
		'GZipConstants'
	],
	#category : #'Compression-Streams'
}

{ #category : #'file list services' }
GZipWriteStream class >> compressFile: fileName [
	"Create a compressed file from the file of the given name"

	(FileStream readOnlyFileNamed: fileName) compressFile
]

{ #category : #'file list services' }
GZipWriteStream class >> fileReaderServicesForFile: fullName suffix: suffix [
	"Don't offer to compress already-compressed files
	sjc 3-May 2003-added jpeg extension"

	^({ 'gz' . 'sar' . 'zip' . 'gif' . 'jpg' . 'jpeg'. 'pr'. 'png'} includes: suffix)
		ifTrue: [ #() ]
		ifFalse: [ self services ]

]

{ #category : #'class initialization' }
GZipWriteStream class >> initialize [
	FileServices registerFileReader: self
]

{ #category : #'file list services' }
GZipWriteStream class >> serviceCompressFile [

	^ FileModifyingSimpleServiceEntry 
				provider: self 
				label: 'compress file' translatedNoop
				selector: #compressFile:
				description: 'compress file using gzip compression, making a new file' translatedNoop
]

{ #category : #'file list services' }
GZipWriteStream class >> services [
	^ { self serviceCompressFile }
]

{ #category : #'class initialization' }
GZipWriteStream class >> unload [
	FileServices unregisterFileReader: self
]

{ #category : #'initialize-release' }
GZipWriteStream >> writeFooter [
	"Write some footer information for the crc"
	super writeFooter.
	0 to: 3 do:[:i| encoder nextBytePut: (crc >> (i*8) bitAnd: 255)].
	0 to: 3 do:[:i| encoder nextBytePut: (bytesWritten >> (i*8) bitAnd: 255)].
]

{ #category : #'initialize-release' }
GZipWriteStream >> writeHeader [
	"Write the GZip header"
	encoder nextBits: 16 put: GZipMagic.
	encoder nextBits: 8 put: GZipDeflated.
	encoder nextBits: 8 put: 0. "No flags"
	encoder nextBits: 32 put: 0. "no time stamp"
	encoder nextBits: 8 put: 0. "No extra flags"
	encoder nextBits: 8 put: 0. "No OS type"

]
