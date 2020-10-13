"
The central class to access the external file.  The interface of this object is similar to good old StandardFileStream, but internally it asks the converter, which is a sub-instance of TextConverter, and do the text conversion.

  It also combined the good old CrLfFileStream.  CrLfFileStream class>>new now returns an instance of MultiByteFileStream.

  There are several pitfalls:

  * You always have to be careful about the binary/text distinction.  In #text mode, it usually interpret the bytes.
  * A few file pointer operations treat the file as uninterpreted byte no matter what.  This means that if you use 'fileStream skip: -1', 'fileStream position: x', etc. in #text mode, the file position can be in the middle of multi byte character.  If you want to implement some function similar to #peek for example, call the saveStateOf: and restoreStateOf: methods to be able to get back to the original state.
  * #lineEndConvention: and #wantsLineEndConversion: (and #binary) can cause some puzzling situation because the inst var lineEndConvention and wantsLineEndConversion are mutated.  If you have any suggestions to clean up the protocol, please let me know.
"
Class {
	#name : #MultiByteFileStream,
	#superclass : #StandardFileStream,
	#instVars : [
		'converter',
		'lineEndConvention',
		'wantsLineEndConversion'
	],
	#classVars : [
		'Cr',
		'CrLf',
		'Lf',
		'LineEndDefault',
		'LineEndStrings',
		'LookAheadCount'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #'class initialization' }
MultiByteFileStream class >> defaultToCR [

	"MultiByteFileStream defaultToCR"
	LineEndDefault := #cr.

]

{ #category : #'class initialization' }
MultiByteFileStream class >> defaultToCRLF [

	"MultiByteFileStream defaultToCRLF"
	LineEndDefault := #crlf.
]

{ #category : #'class initialization' }
MultiByteFileStream class >> defaultToLF [

	"MultiByteFileStream defaultToLF"
	LineEndDefault := #lf.

]

{ #category : #'system startup' }
MultiByteFileStream class >> guessDefaultLineEndConvention [
	"Lets try to guess the line end convention from what we know about the
	path name delimiter from FileDirectory."
	FileDirectory pathNameDelimiter = $:
		ifTrue: [^ self defaultToCR].
	FileDirectory pathNameDelimiter = $/
		ifTrue: [((Smalltalk osVersion)
					beginsWith: 'darwin')
				ifTrue: [^ self defaultToCR]
				ifFalse: [^ self defaultToLF]].
	FileDirectory pathNameDelimiter = $\
		ifTrue: [^ self defaultToCRLF].
	"in case we don't know"
	^ self defaultToCR
]

{ #category : #'class initialization' }
MultiByteFileStream class >> initialize [

	"MultiByteFileStream initialize"
	Cr := Character cr.
	Lf := Character lf.
	CrLf := String with: Cr with: Lf.
	LineEndStrings := Dictionary new.
	LineEndStrings at: #cr put: (String with: Character cr).
	LineEndStrings at: #lf put: (String with: Character lf).
	LineEndStrings at: #crlf put: (String with: Character cr with: Character lf).
	LookAheadCount := 2048.
	Smalltalk addToStartUpList: self.
	self startUp.

]

{ #category : #accessing }
MultiByteFileStream class >> lineEndDefault [
	"Answer the default line-ending convention that will be used by default, which was determined at start-up by looking at platform atributes."
	^ LineEndDefault
]

{ #category : #stdio }
MultiByteFileStream class >> newForStdio [
	"Use crlf as line end convention on windows, lf on all other platforms. Also make sure that the converter is initialized."
	
	| lineEndConvention |
	lineEndConvention := self lineEndDefault.
	lineEndConvention == #crlf ifFalse: [
		lineEndConvention := #lf ].
	^self new
		lineEndConvention: lineEndConvention;
		initializeConverter;
		yourself
]

{ #category : #'instance creation' }
MultiByteFileStream class >> newFrom: aFileStream [

	| rw n |
	n := aFileStream name.
	rw := aFileStream isReadOnly not.
	aFileStream close.
	^self new open: n forWrite: rw.

]

{ #category : #'system startup' }
MultiByteFileStream class >> startUp: resuming [

	resuming ifTrue: [ self guessDefaultLineEndConvention ]

]

{ #category : #remnant }
MultiByteFileStream >> accepts: aSymbol [

 	^ converter accepts: aSymbol.

]

{ #category : #accessing }
MultiByteFileStream >> ascii [

	super ascii.
	self detectLineEndConvention.

]

{ #category : #public }
MultiByteFileStream >> back [

	^converter backFromStream: self
]

{ #category : #'crlf private' }
MultiByteFileStream >> bareNext [

	self deprecated: 'Don''t use this method anymore.'.
	^converter nextFromStream: self.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicBack [

	self position = 0 ifTrue: [ self errorCantGoBack ].
	self skip: -1.
	^self basicPeek

]

{ #category : #'private basic' }
MultiByteFileStream >> basicNext: anInteger [

	^self basicNextInto: (self collectionSpecies new: anInteger)
]

{ #category : #'private basic' }
MultiByteFileStream >> basicNext: n into: aString [

	^ super next: n into: aString.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicNext: anInteger putAll: aCollection startingAt: startIndex [

	^super next: anInteger putAll: aCollection startingAt: startIndex
]

{ #category : #'private basic' }
MultiByteFileStream >> basicNextInto: aString [

	^ super nextInto: aString.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicNextPut: char [

	^ super nextPut: char.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicNextPutAll: aString [

	^ super nextPutAll: aString.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicPeek [

	^ super peek

]

{ #category : #'private basic' }
MultiByteFileStream >> basicPosition [

	^ super position.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicPosition: pos [

	^ super position: pos.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicReadInto: byteArray startingAt: startIndex count: count [

	^ super readInto: byteArray startingAt: startIndex count: count.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicSetToEnd [

	^ super setToEnd.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicSkip: n [

	^ super skip: n.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicUpTo: delim [

	^ super upTo: delim.

]

{ #category : #'private basic' }
MultiByteFileStream >> basicVerbatim: aString [

	^ super verbatim: aString.

]

{ #category : #accessing }
MultiByteFileStream >> binary [

	super binary.
	self lineEndConvention: nil
]

{ #category : #'crlf private' }
MultiByteFileStream >> convertStringFromCr: aString [ 
	| inStream outStream |
	
	self deprecated: 'This method is obsolete and private, don''t use it!'.
	lineEndConvention ifNil: [^ aString].
	lineEndConvention == #cr ifTrue: [^ aString].
	lineEndConvention == #lf ifTrue: [^ aString copy replaceAll: Cr with: Lf].
	"lineEndConvention == #crlf"
	inStream := ReadStream on: aString.
	outStream := WriteStream on: (String new: aString size).
	[inStream atEnd]
		whileFalse: 
			[outStream nextPutAll: (inStream upTo: Cr).
			(inStream atEnd not or: [aString last = Cr])
				ifTrue: [outStream nextPutAll: CrLf]].
	^ outStream contents
]

{ #category : #'crlf private' }
MultiByteFileStream >> convertStringToCr: aString [ 
	| inStream outStream |
	
	self deprecated: 'This method is obsolete and private, don''t use it!'.
	lineEndConvention ifNil: [^ aString].
	lineEndConvention == #cr ifTrue: [^ aString].
	lineEndConvention == #lf ifTrue: [^ aString copy replaceAll: Lf with: Cr].
	"lineEndConvention == #crlf"
	inStream := ReadStream on: aString.
	outStream := WriteStream on: (String new: aString size).
	[inStream atEnd]
		whileFalse: 
			[outStream nextPutAll: (inStream upTo: Cr).
			(inStream atEnd not or: [aString last = Cr])
				ifTrue: 
					[outStream nextPut: Cr.
					inStream peek = Lf ifTrue: [inStream next]]].
	^ outStream contents
]

{ #category : #accessing }
MultiByteFileStream >> converter [

	^converter ifNil: [
		self initializeConverter.
		converter ]
]

{ #category : #accessing }
MultiByteFileStream >> converter: aConverter [

	converter := aConverter.
	self installLineEndConventionInConverter

]

{ #category : #'crlf private' }
MultiByteFileStream >> detectLineEndConvention [
	"Detect the line end convention used in this stream. The result may be either #cr, #lf or #crlf."
	| char numRead state |
	self isBinary ifTrue: [^ self error: 'Line end conventions are not used on binary streams'].
	wantsLineEndConversion ifFalse: [self lineEndConvention: nil.
					^lineEndConvention].
	self closed ifTrue: [self lineEndConvention: LineEndDefault.
					^lineEndConvention].

	"Default if nothing else found"
	numRead := 0.
	state := converter saveStateOf: self.
	lineEndConvention := nil.
	[super atEnd not and: [numRead < LookAheadCount]]
		whileTrue: 
			[char := self next.
			char = Lf
				ifTrue: 
					[converter restoreStateOf: self with: state.
					self lineEndConvention: #lf.
					^lineEndConvention].
			char = Cr
				ifTrue: 
					[self peek = Lf
						ifTrue: [self lineEndConvention: #crlf]
						ifFalse: [self lineEndConvention: #cr].
					converter restoreStateOf: self with: state.
					^ lineEndConvention].
			numRead := numRead + 1].
	converter restoreStateOf: self with: state.
	self lineEndConvention: LineEndDefault.
	^ lineEndConvention
]

{ #category : #'crlf private' }
MultiByteFileStream >> doConversion [

	^wantsLineEndConversion and: [ lineEndConvention notNil ]
]

{ #category : #'fileIn\/Out' }
MultiByteFileStream >> fileIn [

	self setConverterForCode.
	super fileIn.

]

{ #category : #accessing }
MultiByteFileStream >> fileInEncodingName: aString [

	self converter: (TextConverter newForEncoding: aString).
	super fileIn.

]

{ #category : #'fileIn\/Out' }
MultiByteFileStream >> fileInObjectAndCodeForProject [
	"This file may contain:
1) a fileIn of code  
2) just an object in SmartReferenceStream format 
3) both code and an object.
	File it in and return the object.  Note that self must be a FileStream or RWBinaryOrTextStream.  Maybe ReadWriteStream incorporate RWBinaryOrTextStream?"
	| refStream object |
	self text.
	self peek asciiValue = 4
		ifTrue: [  "pure object file"
			self binary.
			refStream := SmartRefStream on: self.
			object := refStream nextAndClose]
		ifFalse: [  "objects mixed with a fileIn"
			self fileInProject.  "reads code and objects, then closes the file"
			self binary.
			object := SmartRefStream scannedObject].	"set by side effect of one of the chunks"
	SmartRefStream scannedObject: nil.  "clear scannedObject"
	^ object
]

{ #category : #'fileIn\/Out' }
MultiByteFileStream >> fileInProject [

	self setConverterForCodeForProject.
	super fileIn.

]

{ #category : #'fileIn\/Out' }
MultiByteFileStream >> fileOutClass: extraClass andObject: theObject [ 
	self binary.
	UTF8TextConverter writeBOMOn: self.
	self text.
	^ super fileOutClass: extraClass andObject: theObject
]

{ #category : #remnant }
MultiByteFileStream >> filterFor: aFileStream [

	| rw |
	name := aFileStream name.
	rw := aFileStream isReadOnly not.
	aFileStream close.
	self open: name forWrite: rw.
	^self.

]

{ #category : #'initialize-release' }
MultiByteFileStream >> initialize [

	super initialize.
	wantsLineEndConversion := false.
	self initializeConverter
]

{ #category : #'initialize-release' }
MultiByteFileStream >> initializeConverter [

	self converter: TextConverter defaultSystemConverter
]

{ #category : #private }
MultiByteFileStream >> installLineEndConventionInConverter [

	converter ifNotNil: [
		converter installLineEndConvention: (
			(wantsLineEndConversion and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
				ifTrue: [ LineEndStrings at: lineEndConvention ]
				ifFalse: [ nil ]) ]
]

{ #category : #accessing }
MultiByteFileStream >> lineEndConvention [

	^lineEndConvention
]

{ #category : #accessing }
MultiByteFileStream >> lineEndConvention: aSymbol [

	(lineEndConvention := aSymbol) ifNotNil: [wantsLineEndConversion := true].
	self installLineEndConventionInConverter
]

{ #category : #public }
MultiByteFileStream >> next [

	| char |
	char := converter nextFromStream: self.
	"#doConversion is inlined here"
	(wantsLineEndConversion and: [ lineEndConvention notNil ]) ifTrue: [
		char == Cr ifTrue: [
			| state |
			state := converter saveStateOf: self.
			(converter nextFromStream: self) ifNotNil: [ :secondChar |
				secondChar == Lf ifFalse: [
					converter restoreStateOf: self with: state ] ].
			^Cr ].
		char == Lf ifTrue: [
			^Cr ] ].
	^char.


]

{ #category : #public }
MultiByteFileStream >> next: anInteger [ 

	| multiString |
	self isBinary ifTrue: [^ super next: anInteger].
	multiString := String new: anInteger.
	1 to: anInteger do: [:index |
		| character |
		(character := self next)
			ifNotNil: [ multiString at: index put: character ]
			ifNil: [
				multiString := multiString copyFrom: 1 to: index - 1.
				(wantsLineEndConversion and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
					ifFalse: [ ^multiString ].
				^self next: anInteger innerFor: multiString ] ].
	(wantsLineEndConversion and: [ lineEndConvention notNil ]) "#doConversion is inlined here"
		 ifFalse: [ ^multiString ].

	multiString := self next: anInteger innerFor: multiString.
	(multiString size = anInteger or: [self atEnd]) ifTrue: [ ^ multiString].
	^ multiString, (self next: anInteger - multiString size).

]

{ #category : #'crlf private' }
MultiByteFileStream >> next: n innerFor: aString [

	aString size = 0 ifTrue: [^ aString].
	"if we just read a CR, and the next character is an LF, then skip the LF"
	aString last == Cr ifTrue: [
		| state |
		state := converter saveStateOf: self.
		(converter nextFromStream: self) ifNotNil: [ :peekChar |
			peekChar == Lf ifFalse: [
				converter restoreStateOf: self with: state ] ] ].
	^aString withSqueakLineEndings

]

{ #category : #public }
MultiByteFileStream >> next: anInteger putAll: aCollection startingAt: startIndex [

	(self isBinary or: [ aCollection class == ByteArray ]) ifTrue: [
		^super next: anInteger putAll: aCollection startingAt: startIndex ].
	^converter next: anInteger putAll: aCollection startingAt: startIndex toStream: self
]

{ #category : #'fileIn\/Out' }
MultiByteFileStream >> nextChunk [
	"Answer the contents of the receiver, up to the next terminator character. Doubled terminators indicate an embedded terminator character."

	^converter nextChunkFromStream: self
]

{ #category : #'fileIn\/Out' }
MultiByteFileStream >> nextChunkText [
	"Deliver the next chunk as a Text.  Decode the following ]style[ chunk if present.  Position at start of next real chunk."
	
	^converter nextChunkTextFromStream: self
]

{ #category : #public }
MultiByteFileStream >> nextDelimited: terminator [

	| out ch save |
	out := WriteStream on: (String new: 1000).
	self atEnd ifTrue: [^ ''].
	save := converter saveStateOf: self.

	self next = terminator ifFalse: [
		"absorb initial terminator"
		converter restoreStateOf: self with: save.
	].
	[(ch := self next) == nil] whileFalse: [
		(ch = terminator) ifTrue: [
			self peek = terminator ifTrue: [
				self next.  "skip doubled terminator"
			] ifFalse: [
				^ out contents  "terminator is not doubled; we're done!"
			].
		].
		out nextPut: ch.
	].
	^ out contents.

]

{ #category : #public }
MultiByteFileStream >> nextMatchAll: aColl [

    | save |
    save := converter saveStateOf: self.
    aColl do: [:each |
       (self next) = each ifFalse: [
            converter restoreStateOf: self with: save.
            ^ false.
		].
	].
    ^ true.

]

{ #category : #public }
MultiByteFileStream >> nextPut: aCharacter [

	aCharacter isInteger ifTrue: [ ^super nextPut: aCharacter ].
	^converter nextPut: aCharacter toStream: self
]

{ #category : #public }
MultiByteFileStream >> nextPutAll: aCollection [

	(self isBinary or: [aCollection class == ByteArray]) ifTrue: [
		^ super nextPutAll: aCollection.
	].
	aCollection class == WordArrayForSegment ifTrue: [
		^ super nextPutAll: (Bitmap withAll: aCollection) asByteArray
	].
	^converter nextPutAll: aCollection toStream: self
]

{ #category : #'open\/close' }
MultiByteFileStream >> open: fileName forWrite: writeMode [ 
	| result |
	result := super open: fileName forWrite: writeMode.
	result ifNotNil: [
			converter ifNil: [self converter: UTF8TextConverter new].
			lineEndConvention ifNil: [ self detectLineEndConvention ]
	].
	^result
]

{ #category : #public }
MultiByteFileStream >> peek [
	"Answer what would be returned if the message next were sent to the receiver. If the receiver is at the end, answer nil.  "

	| next state |
	state := converter saveStateOf: self.
	next := self next.
	converter restoreStateOf: self with: state.
	^next

]

{ #category : #public }
MultiByteFileStream >> peekFor: item [ 

	| state |
	"self atEnd ifTrue: [^ false]. -- SFStream will give nil"
	state := converter saveStateOf: self.
	(self next ifNil: [ ^false ]) = item ifTrue: [ ^true ].
	converter restoreStateOf: self with: state.
	^ false.

]

{ #category : #private }
MultiByteFileStream >> requestDropStream: dropIndex [
	"Needs to install proper converter"

	| result |
	result := super requestDropStream: dropIndex.
	result ifNotNil: [
		converter ifNil: [self converter: UTF8TextConverter new].
		lineEndConvention ifNil: [ self detectLineEndConvention ]
	].
	^result
]

{ #category : #'open\/close' }
MultiByteFileStream >> reset [

	super reset.
	converter ifNil: [
		self converter: UTF8TextConverter new.
	].

]

{ #category : #private }
MultiByteFileStream >> setConverterForCode [

	| currentPosition |
	(SourceFiles at: 2)
		ifNotNil: [self fullName = (SourceFiles at: 2) fullName ifTrue: [^ self]].
	currentPosition := self position.
	self position: 0.
	self binary.
	((self next: 3) = #[ 16rEF 16rBB 16rBF ]) ifTrue: [
		self converter: UTF8TextConverter new
	] ifFalse: [
		self converter: MacRomanTextConverter new.
	].
	self position: currentPosition.
	self text.

]

{ #category : #private }
MultiByteFileStream >> setConverterForCodeForProject [

	self converter: UTF8TextConverter new.

]

{ #category : #public }
MultiByteFileStream >> skipSeparators [

	converter skipSeparatorsFrom: self
]

{ #category : #public }
MultiByteFileStream >> skipSeparatorsAndPeekNext [
	"A special function to make nextChunk fast. Same as #skipSeparators, but returns the next character after the separators if such exists."
	
	^converter skipSeparatorsAndPeekNextFrom: self
]

{ #category : #public }
MultiByteFileStream >> upTo: delimiter [

	^self collectionSpecies new: 1000 streamContents: [ :stream |
		| ch |
		[ (ch := self next) == nil or: [ ch = delimiter ] ] 
			whileFalse: [ stream nextPut: ch ] ]

]

{ #category : #public }
MultiByteFileStream >> upToAnyOf: delimiters do: aBlock [

	^self collectionSpecies new: 1000 streamContents: [ :stream |
		| ch |
		[ (ch := self next) == nil or: [ (delimiters includes: ch) and: [aBlock value: ch. true] ] ] 
			whileFalse: [ stream nextPut: ch ] ]
]

{ #category : #public }
MultiByteFileStream >> upToEnd [

	^self collectionSpecies
		new: self size - self position
		streamContents: [ :stream |
			| element |
			[ (element := self next) == nil ] whileFalse: [
				stream nextPut: element ] ]

]

{ #category : #accessing }
MultiByteFileStream >> upToPosition: anInteger [
	"Answer a subcollection containing items starting from the current position and ending including the given position. Usefully different to #next: in that positions measure *bytes* from the file, where #next: wants to measure *characters*."
	^self collectionSpecies new: 1000 streamContents: [ :stream |
		| ch |
		[ (self position >= anInteger) or: [(ch := self next) == nil] ]
			whileFalse: [ stream nextPut: ch ] ]
]

{ #category : #'crlf private' }
MultiByteFileStream >> wantsLineEndConversion [

	^wantsLineEndConversion
]

{ #category : #remnant }
MultiByteFileStream >> wantsLineEndConversion: aBoolean [
	
	wantsLineEndConversion := aBoolean.
	lineEndConvention ifNil: [ self detectLineEndConvention ]
]
