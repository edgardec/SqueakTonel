"
A pseudo stream that allows SmartRefStream to write directly to a gzipped file. There are some peculiarities of the project exporting process that require:

1. We ignore #close since the file is closed and may be reopened to continue writing. We implement #reallyClose for when we know that all writing is over.

2. We use a BitBlt to write WordArrayForSegment objects. Bit of a hack, but there it is.

| fileStream wa |

wa := WordArrayForSegment new: 30000.
1 to: wa size do: [ :i | wa at: i put: i].
fileStream := GZipSurrogateStream newFileNamed: 'xxx3.gz' inDirectory: FileDirectory default.
fileStream nextPutAll: 'this is a test'.
fileStream nextPutAll: wa.
fileStream reallyClose.

"
Class {
	#name : #GZipSurrogateStream,
	#superclass : #Object,
	#instVars : [
		'gZipStream',
		'zippedFileStream',
		'bufferStream',
		'positionThusFar'
	],
	#category : #'Compression-Streams'
}

{ #category : #'as yet unclassified' }
GZipSurrogateStream class >> newFileNamed: fName inDirectory: aDirectory [

	^self new newFileNamed: fName inDirectory: aDirectory
]

{ #category : #accessing }
GZipSurrogateStream >> ascii [

	self bufferStream ascii
]

{ #category : #accessing }
GZipSurrogateStream >> binary [

	self bufferStream binary
]

{ #category : #private }
GZipSurrogateStream >> bufferStream [

	^bufferStream ifNil: [bufferStream := RWBinaryOrTextStream on: (ByteArray new: 5000)].

]

{ #category : #'open\/close' }
GZipSurrogateStream >> close [
	
	"we don't want to until user is really done"
	


]

{ #category : #'open\/close' }
GZipSurrogateStream >> closed [

	^false
]

{ #category : #writing }
GZipSurrogateStream >> command: aString [
	"Overridden by HtmlFileStream to append commands directly without translation.  4/5/96 tk"
	"We ignore any HTML commands.  Do nothing"
]

{ #category : #writing }
GZipSurrogateStream >> cr [

	self bufferStream cr
]

{ #category : #writing }
GZipSurrogateStream >> fileOutClass: extraClass andObject: theObject [
	"Write a file that has both the source code for the named class and an object as bits.  Any instance-specific object will get its class written automatically."

	| class srefStream |

	self timeStamp.

	extraClass ifNotNil: [
		class := extraClass.	"A specific class the user wants written"
		class sharedPools size > 0 ifTrue: [
			class shouldFileOutPools ifTrue: [class fileOutSharedPoolsOn: self]
		].
		class fileOutOn: self moveSource: false toFile: 0
	].

	"Append the object's raw data"
	srefStream := SmartRefStream on: self.
	srefStream nextPut: theObject.  "and all subobjects"
	srefStream close.		"also closes me - well it thinks it does, anyway"

]

{ #category : #private }
GZipSurrogateStream >> flushBuffer [

	| data |
	bufferStream ifNil: [^self].
	data := bufferStream contents asByteArray.
	gZipStream nextPutAll: data.
	positionThusFar := positionThusFar + data size.
	bufferStream := nil.

]

{ #category : #writing }
GZipSurrogateStream >> header [

	"ignore"
]

{ #category : #private }
GZipSurrogateStream >> newFileNamed: fName inDirectory: aDirectory [

	positionThusFar := 0.
	zippedFileStream := aDirectory newFileNamed: fName.
	zippedFileStream binary; setFileTypeToObject.
		"Type and Creator not to be text, so can be enclosed in an email"
	gZipStream := GZipWriteStream on: zippedFileStream.

]

{ #category : #reading }
GZipSurrogateStream >> next [

	^self bufferStream next
]

{ #category : #writing }
GZipSurrogateStream >> nextChunkPut: aString [

	self bufferStream nextChunkPut: aString
]

{ #category : #writing }
GZipSurrogateStream >> nextInt32Put: int32 [

	^self bufferStream nextInt32Put: int32

]

{ #category : #writing }
GZipSurrogateStream >> nextNumber: n put: v [ 

	^self bufferStream nextNumber: n put: v 

]

{ #category : #writing }
GZipSurrogateStream >> nextPut: aByte [

	^self bufferStream nextPut: aByte

]

{ #category : #writing }
GZipSurrogateStream >> nextPutAll: aString [

	^aString writeOnGZIPByteStream: self

]

{ #category : #writing }
GZipSurrogateStream >> nextPutAllBytes: aString [

	^self bufferStream nextPutAll: aString

]

{ #category : #writing }
GZipSurrogateStream >> nextPutAllWordArray: aWordArray [

	| ba hackwa hackba blt rowsAtATime sourceOrigin rowsRemaining |

	self flag: #bob.		"do we need to be concerned by bytesPerElement??"
	ba := nil.
	rowsAtATime := 2000.		"or 8000 bytes"
	hackwa := Form new hackBits: aWordArray.
	sourceOrigin := 0@0.
	[(rowsRemaining := hackwa height - sourceOrigin y) > 0] whileTrue: [
		rowsAtATime := rowsAtATime min: rowsRemaining.
		(ba isNil or: [ba size ~= (rowsAtATime * 4)]) ifTrue: [
			ba := ByteArray new: rowsAtATime * 4.
			hackba := Form new hackBits: ba.
			blt := (BitBlt toForm: hackba) sourceForm: hackwa.
		].
		blt 
			combinationRule: Form over;
			sourceOrigin: sourceOrigin;
			destX: 0 destY: 0 width: 4 height: rowsAtATime;
			copyBits.
		self bufferStream nextPutAll: ba.
		self flushBuffer.
		sourceOrigin := sourceOrigin x @ (sourceOrigin y + rowsAtATime).
	].

]

{ #category : #writing }
GZipSurrogateStream >> nextStringPut: s [ 
	"Append the string, s, to the receiver.  Only used by DataStream.  Max size of 64*256*256*256."

	| length |
	(length := s size) < 192
		ifTrue: [self nextPut: length]
		ifFalse: 
			[self nextPut: (length digitAt: 4)+192.
			self nextPut: (length digitAt: 3).
			self nextPut: (length digitAt: 2).
			self nextPut: (length digitAt: 1)].
	self nextPutAll: s.
	^s
]

{ #category : #writing }
GZipSurrogateStream >> nextWordsPutAll: aCollection [
	"Write the argument a word-like object in big endian format on the receiver.
	May be used to write other than plain word-like objects (such as ColorArray)."
	^self nextPutAllWordArray: aCollection
]

{ #category : #reading }
GZipSurrogateStream >> originalContents [

	^''		"used only to determine if we are byte-structured"
]

{ #category : #writing }
GZipSurrogateStream >> padToEndWith: aChar [
	"We don't have pages, so we are at the end, and don't need to pad."
]

{ #category : #positionning }
GZipSurrogateStream >> position [

	^self bufferStream position + positionThusFar
]

{ #category : #'open\/close' }
GZipSurrogateStream >> reallyClose [

	self flushBuffer.
	gZipStream close.

]

{ #category : #'open\/close' }
GZipSurrogateStream >> reopen [

	"ignore"
]

{ #category : #'properties-setting' }
GZipSurrogateStream >> setFileTypeToObject [

	"ignore"
]

{ #category : #positionning }
GZipSurrogateStream >> setToEnd [

	"ignore"
]

{ #category : #positionning }
GZipSurrogateStream >> skip: aNumber [

	^self bufferStream skip: aNumber

]

{ #category : #writing }
GZipSurrogateStream >> timeStamp [
	"Append the current time to the receiver as a String."
	self bufferStream nextChunkPut:	"double string quotes and !s"
		(String streamContents: [:s | Smalltalk timeStamp: s]) printString.
	self bufferStream cr
]

{ #category : #writing }
GZipSurrogateStream >> trailer [

	"ignore"
]
