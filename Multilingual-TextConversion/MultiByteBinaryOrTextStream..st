"
It is similar to MultiByteFileStream, but works on in memory stream.
"
Class {
	#name : #MultiByteBinaryOrTextStream,
	#superclass : #ReadWriteStream,
	#instVars : [
		'isBinary',
		'converter'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #defaults }
MultiByteBinaryOrTextStream class >> defaultConverter [
	^ ISO88591TextConverter new.

]

{ #category : #'instance creation' }
MultiByteBinaryOrTextStream class >> on: aCollection encoding: encodingName [ 
	| aTextConverter |
	encodingName isNil
		ifTrue: [aTextConverter := TextConverter default]
		ifFalse: [aTextConverter := TextConverter newForEncoding: encodingName].
	^ (self on: aCollection)
		converter: aTextConverter
]

{ #category : #'instance creation' }
MultiByteBinaryOrTextStream class >> with: aCollection encoding: encodingName [ 
	| aTextConverter |
	encodingName isNil
		ifTrue: [aTextConverter := TextConverter default]
		ifFalse: [aTextConverter := TextConverter newForEncoding: encodingName].
	^ (self with: aCollection)
		converter: aTextConverter
]

{ #category : #converting }
MultiByteBinaryOrTextStream >> asBinaryOrTextStream [

	^ self

]

{ #category : #accessing }
MultiByteBinaryOrTextStream >> ascii [
	isBinary := false

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicNext [

	^ super next 

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicNext: anInteger [

	^ super next: anInteger.

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicNext: n into: aString [

	^ super next: n into: aString.

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicNext: anInteger putAll: aCollection startingAt: startIndex [

	^super next: anInteger putAll: aCollection startingAt: startIndex
]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicNextInto: aString [

	^ super nextInto: aString.

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicNextPut: char [

	^ super nextPut: char.

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicNextPutAll: aString [

	^ super nextPutAll: aString.

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicPeek [

	^ super peek

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicPosition [

	^ super position.

]

{ #category : #'private basic' }
MultiByteBinaryOrTextStream >> basicPosition: pos [

	^ super position: pos.

]

{ #category : #accessing }
MultiByteBinaryOrTextStream >> binary [
	isBinary := true

]

{ #category : #public }
MultiByteBinaryOrTextStream >> contents [
	| ret state |
	state := converter saveStateOf: self.
	self position: 0.
	ret := self upToEnd.
	converter restoreStateOf: self with: state.
	^ ret

]

{ #category : #accessing }
MultiByteBinaryOrTextStream >> converter [

	converter ifNil: [converter := self class defaultConverter].
	^ converter

]

{ #category : #accessing }
MultiByteBinaryOrTextStream >> converter: aConverter [

	converter := aConverter.

]

{ #category : #'fileIn\/Out' }
MultiByteBinaryOrTextStream >> fileIn [

	self setConverterForCode.
	super fileIn.

]

{ #category : #'fileIn\/Out' }
MultiByteBinaryOrTextStream >> fileInObjectAndCode [
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
			self fileIn.  "reads code and objects, then closes the file"
			self binary.
			object := SmartRefStream scannedObject].	"set by side effect of one of the chunks"
	SmartRefStream scannedObject: nil.  "clear scannedObject"
	^ object
]

{ #category : #'fileIn\/Out' }
MultiByteBinaryOrTextStream >> fileInObjectAndCodeForProject [
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
MultiByteBinaryOrTextStream >> fileInProject [

	self setConverterForCodeForProject.
	super fileIn.

]

{ #category : #'fileIn\/Out' }
MultiByteBinaryOrTextStream >> fileOutClass: extraClass andObject: theObject [ 
	UTF8TextConverter writeBOMOn: self.
	^ super fileOutClass: extraClass andObject: theObject
]

{ #category : #private }
MultiByteBinaryOrTextStream >> guessConverter [
	^ (self originalContents includesSubstring: #[27 36] asString)
		ifTrue: [CompoundTextConverter new]
		ifFalse: [self class defaultConverter ]
]

{ #category : #accessing }
MultiByteBinaryOrTextStream >> isBinary [
	^ isBinary
]

{ #category : #public }
MultiByteBinaryOrTextStream >> next [

	| n |
	n := self converter nextFromStream: self.
	n ifNil: [^ nil].
	isBinary and: [n isCharacter ifTrue: [^ n asciiValue]].
	^ n.

]

{ #category : #public }
MultiByteBinaryOrTextStream >> next: anInteger [ 

	| multiString |
	"self halt."
	self isBinary ifTrue: [^ (super next: anInteger) asByteArray].
	multiString := WideString new: anInteger.
	1 to: anInteger do: [:index |
		| character |
		(character := self next) ifNotNil: [
			multiString at: index put: character
		] ifNil: [
			multiString := multiString copyFrom: 1 to: index - 1.
			^ multiString
		]
	].
	^ multiString.

]

{ #category : #public }
MultiByteBinaryOrTextStream >> next: anInteger putAll: aCollection startingAt: startIndex [

	(self isBinary or: [ aCollection class == ByteArray ]) ifTrue: [
		^super next: anInteger putAll: aCollection startingAt: startIndex ].
	^self converter next: anInteger putAll: aCollection startingAt: startIndex toStream: self

]

{ #category : #public }
MultiByteBinaryOrTextStream >> nextDelimited: terminator [

	| out ch pos |
	out := WriteStream on: (String new: 1000).
	self atEnd ifTrue: [^ ''].
	pos := self position.
	self next = terminator ifFalse: [
		"absorb initial terminator"
		self position: pos.
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
MultiByteBinaryOrTextStream >> nextMatchAll: aColl [

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
MultiByteBinaryOrTextStream >> nextPut: aCharacter [

	aCharacter isInteger ifTrue: [^ super nextPut: aCharacter asCharacter].
	self converter nextPut: aCharacter toStream: self.
	^aCharacter

]

{ #category : #public }
MultiByteBinaryOrTextStream >> nextPutAll: aCollection [

	self isBinary ifTrue: [
		^ super nextPutAll: aCollection.
	].
	^aCollection do: [:e | self nextPut: e].

]

{ #category : #public }
MultiByteBinaryOrTextStream >> peek [
	"Answer what would be returned if the message next were sent to the receiver. If the receiver is at the end, answer nil.  "

	| next pos |
	self atEnd ifTrue: [^ nil].
	pos := self position.
	next := self next.
	self position: pos.
	^ next.


]

{ #category : #public }
MultiByteBinaryOrTextStream >> peekFor: item [ 

	| state |
	"self atEnd ifTrue: [^ false]. -- SFStream will give nil"
	state := converter saveStateOf: self.
	(self next ifNil: [ ^false ]) = item ifTrue: [ ^true ].
	converter restoreStateOf: self with: state.
	^ false.

]

{ #category : #public }
MultiByteBinaryOrTextStream >> reset [

	super reset.
	isBinary ifNil: [isBinary := false].
	collection class == ByteArray ifTrue: ["Store as String and convert as needed."
		collection := collection asString.
		isBinary := true].

	self converter. "ensure that we have a converter."
]

{ #category : #'fileIn\/Out' }
MultiByteBinaryOrTextStream >> setConverterForCode [

	| current |
	current := converter saveStateOf: self.
	self position: 0.
	self binary.
	((self next: 3) = #[ 16rEF 16rBB 16rBF ]) ifTrue: [
		self converter: UTF8TextConverter new
	] ifFalse: [
		self converter: MacRomanTextConverter new.
	].
	converter restoreStateOf: self with: current.
	self text.

]

{ #category : #private }
MultiByteBinaryOrTextStream >> setConverterForCodeForProject [

	self converter: UTF8TextConverter new.

]

{ #category : #'fileIn\/Out' }
MultiByteBinaryOrTextStream >> setEncoderForSourceCodeNamed: streamName [

	| l |
	l := streamName asLowercase.
"	((l endsWith: FileStream multiCs) or: [
		(l endsWith: FileStream multiSt) or: [
			(l endsWith: (FileStream multiSt, '.gz')) or: [
				(l endsWith: (FileStream multiCs, '.gz'))]]]) ifTrue: [
					self converter: UTF8TextConverter new.
					^ self.
	].
"
	((l endsWith: FileStream cs) or: [
		(l endsWith: FileStream st) or: [
			(l endsWith: (FileStream st, '.gz')) or: [
				(l endsWith: (FileStream cs, '.gz'))]]]) ifTrue: [
					self converter: MacRomanTextConverter new.
					^ self.
	].

	self converter: UTF8TextConverter new.

]

{ #category : #'properties-setting' }
MultiByteBinaryOrTextStream >> setFileTypeToObject [
	"do nothing.  We don't have a file type"
]

{ #category : #public }
MultiByteBinaryOrTextStream >> skipSeparators [

	[self atEnd] whileFalse: [
		self basicNext isSeparator ifFalse: [
			^ self position: self position - 1]]


]

{ #category : #public }
MultiByteBinaryOrTextStream >> skipSeparatorsAndPeekNext [

	"A special function to make nextChunk fast"
	| peek pos |
	[self atEnd] whileFalse: [
		pos := self position.
		(peek := self next) isSeparator ifFalse: [
			self position: pos.
			^ peek.
		].
	].

]

{ #category : #accessing }
MultiByteBinaryOrTextStream >> text [
	isBinary := false

]

{ #category : #public }
MultiByteBinaryOrTextStream >> upTo: delim [ 

	| out ch |
	out := WriteStream on: (String new: 1000).
	self atEnd ifTrue: [^ ''].
	[(ch := self next) == nil] whileFalse: [
		(ch = delim) ifTrue: [
			^ out contents  "terminator is not doubled; we're done!"
		].
		out nextPut: ch.
	].
	^ out contents.

]

{ #category : #public }
MultiByteBinaryOrTextStream >> upToEnd [

	| newStream element newCollection |
	newCollection := self isBinary
				ifTrue: [ByteArray new: 100]
				ifFalse: [String new: 100].
	newStream := WriteStream on: newCollection.
	[(element := self next) notNil]
		whileTrue: [newStream nextPut: element].
	^ newStream contents

]
