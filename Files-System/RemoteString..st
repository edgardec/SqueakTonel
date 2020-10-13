"
My instances provide an external file reference to a piece of text.  It may be the sourceCode of a method, or the class comments of a class.

The changes file or file-in file usually has a chunk that is just the source string of a method:

max: aNumber
	^ self > aNumber ifTrue: [self] ifFalse: [aNumber]!

I can return either a String or a Text.  Some a chunk is followed by a second chunk (beginning with ]style[) containing style information.  The encoding is like this:

max: aNumber
	^ self > aNumber ifTrue: [self] ifFalse: [aNumber]!
]style[(14 50 312)f1,f1b,f1LInteger +;i!

Allowed TextAttributes are TextFontChange, TextEmphasis, TextColor, TextDoIt, TextKern, TextLink, TextURL.  TextFontReference and TextAnchor are not supported.

See PositionableStream nextChunkText and RunArray class scanFrom:.
"
Class {
	#name : #RemoteString,
	#superclass : #Object,
	#instVars : [
		'sourceFileNumber',
		'filePositionHi'
	],
	#classVars : [
		'CurrentTextAttStructure',
		'CurrentTextAttVersion',
		'TextAttributeStructureVersions'
	],
	#category : #'Files-System'
}

{ #category : #accessing }
RemoteString class >> currentTextAttVersion [
	"The current configuration of the TextAttributes classes has a structures array describing the inst vars of the classes (SmartRefStream instVarInfo:).  Return tag that indexes the TextAttributeStructureVersions dictionary (4 random characters)."

	^ CurrentTextAttVersion
	"Be sure to run makeNewTextAttVersion when any TextAttributes class changes inst vars"
]

{ #category : #'class initialization' }
RemoteString class >> initialize [
	"Derive the current TextAttributes classes object structure"

	self new makeNewTextAttVersion
]

{ #category : #'instance creation' }
RemoteString class >> newFileNumber: sourceIndex position: anInteger [ 
	"Answer an instance of me for a file indexed by sourceIndex, at the 
	position anInteger. Assume that the string is already stored on the file 
	and the instance will be used to access it."

	^self new fileNumber: sourceIndex position: anInteger
]

{ #category : #'instance creation' }
RemoteString class >> newString: aString onFileNumber: sourceIndex [ 
	"Answer an instance of me for string, aString, on file indexed by 
	sourceIndex. Put the string on the file and create the remote reference."

	^self new string: aString onFileNumber: sourceIndex
]

{ #category : #'instance creation' }
RemoteString class >> newString: aString onFileNumber: sourceIndex toFile: aFileStream [
	"Answer an instance of me for string, aString, on file indexed by 
	sourceIndex. Put the string on the file, aFileStream, and create the 
	remote reference. Assume that the index corresponds properly to 
	aFileStream."

	^self new string: aString onFileNumber: sourceIndex toFile: aFileStream
]

{ #category : #accessing }
RemoteString class >> structureAt: styleVersion [

	^ TextAttributeStructureVersions at: styleVersion ifAbsent: [nil]
]

{ #category : #private }
RemoteString >> checkSum: aString [
	"Construct a checksum of the string.  A three byte number represented as Base64 characters."
	| sum shift bytes |
	sum := aString size.
	shift := 0.
	aString do: [:char |
		(shift := shift + 7) > 16 ifTrue: [shift := shift - 17].
			"shift by 7 to keep a change of adjacent chars from xoring to same value"
		sum := sum bitXor: (char asInteger bitShift: shift)
	].
	bytes := ByteArray new: 3.
	sum := sum + 16r10000000000.
	1 to: 3 do: [:ind | bytes at: ind put: (sum digitAt: ind)].
	^bytes base64Encoded
]

{ #category : #private }
RemoteString >> fileNumber: fileNumber position: position [ 

	sourceFileNumber := fileNumber.
	filePositionHi := position
]

{ #category : #accessing }
RemoteString >> fileStream [ 
	"Answer the file stream with position set at the beginning of my string"

	| theFile |
	(sourceFileNumber == nil or: [(SourceFiles at: sourceFileNumber) == nil]) ifTrue: [^ nil].
	theFile := SourceFiles at: sourceFileNumber.
	theFile position: filePositionHi.
	^ theFile
]

{ #category : #accessing }
RemoteString >> last [
	^self string ifNotNil: [ :s | s last ]
]

{ #category : #private }
RemoteString >> makeNewTextAttVersion [
	"Create a new TextAttributes version because some inst var has changed.  If no change, don't make a new one."
	"Don't delete this method even though it has no callers!!!!!"

| obj struct tag |
"Note that TextFontReference and TextAnchor are forbidden."
obj := #(RunArray TextDoIt TextLink TextURL TextColor TextEmphasis TextFontChange TextKern TextLinkToImplementors 3 'a string') collect: [:each | | cls | 
		cls := Smalltalk at: each ifAbsent: [nil].
		cls ifNil: [each] ifNotNil: [cls new]].
struct := (SmartRefStream on: (RWBinaryOrTextStream on: String new)) instVarInfo: obj.
tag := self checkSum: struct printString.
TextAttributeStructureVersions ifNil: [TextAttributeStructureVersions := Dictionary new].
(struct = CurrentTextAttStructure) & (tag = CurrentTextAttVersion) 
	ifTrue: [^ false].
CurrentTextAttStructure := struct.
CurrentTextAttVersion := tag.
TextAttributeStructureVersions at: tag put: struct.
^ true
]

{ #category : #accessing }
RemoteString >> position [ 
	"Answer the location of the string on a file."

	^ filePositionHi
]

{ #category : #accessing }
RemoteString >> setSourcePointer: aSourcePointer [
	sourceFileNumber := SourceFiles fileIndexFromSourcePointer: aSourcePointer.
	filePositionHi := SourceFiles filePositionFromSourcePointer: aSourcePointer
]

{ #category : #accessing }
RemoteString >> sourceFileNumber [
	"Answer the index of the file on which the string is stored."

	^sourceFileNumber
]

{ #category : #accessing }
RemoteString >> sourcePointer [
	sourceFileNumber ifNil: [^ 0].
	^SourceFiles sourcePointerFromFileIndex: sourceFileNumber andPosition: filePositionHi
]

{ #category : #accessing }
RemoteString >> string [ 
	"Answer the receiver's string if remote files are enabled."
	| theFile |
	(sourceFileNumber == nil or: [(SourceFiles at: sourceFileNumber) == nil]) ifTrue: [^''].
	theFile := SourceFiles at: sourceFileNumber.
	theFile position: filePositionHi.
	^ theFile nextChunk
]

{ #category : #private }
RemoteString >> string: aString onFileNumber: fileNumber [
	"Store this as my string if source files exist."
	(SourceFiles at: fileNumber) ifNotNil: [:theFile |
		theFile isReadOnly ifTrue: [^ nil].
		theFile setToEnd; cr.
		self string: aString onFileNumber: fileNumber toFile: theFile].
]

{ #category : #private }
RemoteString >> string: aStringOrText onFileNumber: fileNumber toFile: aFileStream [ 
	"Store this as the receiver's text if source files exist. If aStringOrText is a Text, store a marker with the string part, and then store the runs of TextAttributes in the next chunk."

	| position |
	position := aFileStream position.
	self fileNumber: fileNumber position: position.
	aFileStream nextChunkPutWithStyle: aStringOrText
	"^ self		(important)"
]

{ #category : #accessing }
RemoteString >> text [ 
	"Answer the receiver's string asText if remote files are enabled."

	| theFile |
	theFile := (CurrentReadOnlySourceFiles at: (sourceFileNumber ifNil: [ ^nil ])) ifNil: [ ^nil ].
	theFile size <= filePositionHi ifTrue: [ 
		 "SourceFiles might have been appended to since theFile was opened. Flush the written data and reopen theFile to make it see the changes."
		(SourceFiles at: sourceFileNumber) flush.
		theFile reopen. "Currently the only way to re-read the size field of a read-only file on unix..." ].
	theFile size < filePositionHi ifTrue: [
		self error: 'RemoteString past end of file' ].
	^theFile
		position: filePositionHi;
		nextChunkText
]
