"
The abstract class for all different type of text converters.  nextFromStream: and nextPut:toStream: are the public accessible methods.  If you are going to make a subclass for a stateful text conversion, you should override restoreStateOf:with: and saveStateOf: along the line of CompoundTextConverter.

"
Class {
	#name : #TextConverter,
	#superclass : #Object,
	#instVars : [
		'latin1Map',
		'latin1Encodings'
	],
	#pools : [
		'EventSensorConstants'
	],
	#classInstVars : [
		'latin1Map',
		'latin1Encodings'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #utilities }
TextConverter class >> allEncodingNames [
	"TextConverter allEncodingNames"
	| encodingNames |
	encodingNames := Set new.
	self allSubclasses
		do: [:each | 
			| names | 
			names := each encodingNames.
			names notEmpty
				ifTrue: [encodingNames add: names first asSymbol]].
	^encodingNames
]

{ #category : #'instance creation' }
TextConverter class >> default [

	^ UTF8TextConverter new.

]

{ #category : #'instance creation' }
TextConverter class >> defaultConverterClassForEncoding: encodingName [
	"TextConverter defaultConverterClassForEncoding: 'shift-jis'"

	^ self allSubclasses
		detect: [:class | class encodingNames includes: encodingName]
		ifNone: []

]

{ #category : #'instance creation' }
TextConverter class >> defaultSystemConverter [

	^LanguageEnvironment defaultSystemConverter
]

{ #category : #utilities }
TextConverter class >> encodingNames [ 

	^ #() copy.

]

{ #category : #'class initialization' }
TextConverter class >> initializeLatin1MapAndEncodings [
	"Initialize the latin1Map and latin1Encodings.
	These variables ensure that conversions from latin1 ByteString is reasonably fast."
	
	self subclassResponsibility
	
	
]

{ #category : #'class initialization' }
TextConverter class >> initializeTables [

	self initializeLatin1MapAndEncodings
]

{ #category : #accessing }
TextConverter class >> latin1Encodings [
	"Answer an Array mapping latin1 characters to conversion string"

	^latin1Encodings
]

{ #category : #accessing }
TextConverter class >> latin1Map [
	"Answer a ByteArray map telling if latin1 characters needs conversion or not"

	^latin1Map
]

{ #category : #'instance creation' }
TextConverter class >> newForEncoding: aString [ 
	| class encoding |
	aString ifNil: [^ ISO88591TextConverter new].
	encoding := aString asLowercase.
	class := self allSubclasses
				detect: [:each | each encodingNames includes: encoding]
				ifNone: [].
	class isNil
		ifTrue: [NoConverterFound signalFor: aString. ^ nil].
	^ class new
]

{ #category : #query }
TextConverter >> accepts: aSymbol [

	self subclassResponsibility.

]

{ #category : #conversion }
TextConverter >> backFromStream: aStream [

	self subclassResponsibility

]

{ #category : #friend }
TextConverter >> currentCharSize [

	self subclassResponsibility.

]

{ #category : #conversion }
TextConverter >> decodeString: aString [

	| result |
	result := String new: aString size streamContents: [ :stream |
		| readStream character |
		readStream := aString readStream.
		[ (character := self nextFromStream: readStream) == nil ]
			whileFalse: [ stream nextPut: character ] ].
	self class latin1Encodings == latin1Encodings ifTrue: [ ^result ].
	^result withSqueakLineEndings
]

{ #category : #friend }
TextConverter >> emitSequenceToResetStateIfNeededOn: aStream [

]

{ #category : #conversion }
TextConverter >> encodeString: aString [

	^String new: aString size streamContents: [ :stream | 
		self 
			nextPutAll: aString
			toStream: stream ]
]

{ #category : #utilities }
TextConverter >> encodingNames [

	^ self class encodingNames
]

{ #category : #'initialize-release' }
TextConverter >> initialize [
	super initialize.
	latin1Map := self class latin1Map.
	latin1Encodings := self class latin1Encodings.
]

{ #category : #'initialize-release' }
TextConverter >> installLineEndConvention: lineEndStringOrNil [

	latin1Map := self class latin1Map.
	latin1Encodings := self class latin1Encodings.
	lineEndStringOrNil ifNotNil: [ | convertedLineEndString |
		latin1Encodings := latin1Encodings copy.
		convertedLineEndString := String streamContents: [:stream | 
			lineEndStringOrNil readStream do: [:c |
				self nextPut: c toStream: stream]].
		latin1Encodings at: Character cr asciiValue + 1 put: convertedLineEndString.
		latin1Map := latin1Map copy.
		latin1Map at: Character cr asciiValue + 1 put: 1]
]

{ #category : #conversion }
TextConverter >> next: anInteger putAll: aString startingAt: startIndex toStream: aStream [
	"Handle fast conversion if ByteString"
	
	| lastIndex nextIndex |
	anInteger > 0 ifFalse: [ ^aString ].
	aStream isBinary ifTrue: [
		aStream basicNext: anInteger putAll: aString startingAt: startIndex.
		^aString ].
	aString class == ByteString ifFalse: [
		startIndex to: startIndex + anInteger - 1 do: [ :index |
			self nextPut: (aString at: index) toStream: aStream ].
		^aString ].
	lastIndex := startIndex.
	[ (nextIndex := ByteString 
		findFirstInString: aString
		inSet: latin1Map
		startingAt: lastIndex) = 0 or: [ anInteger + startIndex <= nextIndex ] ] whileFalse: [ | latin1EncodedCharacter |
			aStream basicNext: nextIndex - lastIndex putAll: aString startingAt: lastIndex.
			latin1EncodedCharacter := latin1Encodings at: (aString byteAt: nextIndex) + 1.
			latin1EncodedCharacter
				ifNil: [UndefinedConversion signalFor: (aString byteAt: nextIndex) toEncoding: self class ]
				ifNotNil: [aStream basicNextPutAll: latin1EncodedCharacter].
			lastIndex := nextIndex + 1 ].
	aStream basicNext: anInteger - lastIndex + startIndex putAll: aString startingAt: lastIndex.
	^aString
]

{ #category : #'fileIn\/Out' }
TextConverter >> nextChunkFromStream: input [
	"Answer the contents of input, up to the next terminator character. Doubled terminators indicate an embedded terminator character."
	
	input skipSeparators.
	^self
		parseLangTagFor: (
			String new: 1000 streamContents: [ :output |
				| character state |
				[ 
					(character := self nextFromStream: input) == nil or: [ 
						character == $! and: [ 
							state := self saveStateOf: input.
							(self nextFromStream: input) ~~ $! ] ] ] 
					whileFalse: [ output nextPut: character ].
				character ifNotNil: [ 
					self restoreStateOf: input with: state ] ])
		fromStream: input
]

{ #category : #'fileIn\/Out' }
TextConverter >> nextChunkTextFromStream: input [
	"Deliver the next chunk as a Text.  Decode the following ]style[ chunk if present.  Position at start of next real chunk."
	
	| chunk state runs |
	chunk := self nextChunkFromStream: input.
	state := self saveStateOf: input.
	(input skipSeparatorsAndPeekNext == $] and: [
		(input next: 7) = ']style[' ])
			ifTrue: [
				runs := RunArray scanFrom: (self nextChunkFromStream: input) readStream ]
			ifFalse: [
				self restoreStateOf: input with: state.
				runs := RunArray new: chunk size withAll: #() ].
	^Text string: chunk runs: runs
]

{ #category : #conversion }
TextConverter >> nextFromStream: aStream [

	self subclassResponsibility.

]

{ #category : #conversion }
TextConverter >> nextPut: aCharacter toStream: aStream [

	self subclassResponsibility.

]

{ #category : #conversion }
TextConverter >> nextPutAll: aString toStream: aStream [
	"Handle fast conversion if ByteString"
	
	^self next: aString size putAll: aString startingAt: 1 toStream: aStream
]

{ #category : #'fileIn\/Out' }
TextConverter >> parseLangTagFor: aString fromStream: stream [

	| state |
	state := self saveStateOf: stream.
	"Test for ]lang[ tag"
	(stream skipSeparatorsAndPeekNext == $] and: [
		(stream next: 6) = ']lang[' ]) ifTrue: [
			^stream
				decodeString: aString
				andRuns: (self nextChunkFromStream: stream) ].
	"no tag"
	self restoreStateOf: stream with: state.
	^aString
			
]

{ #category : #friend }
TextConverter >> restoreStateOf: aStream with: aConverterState [

	aStream position: aConverterState.

]

{ #category : #friend }
TextConverter >> saveStateOf: aStream [

	^ aStream position.

]

{ #category : #'fileIn\/Out' }
TextConverter >> skipSeparatorsAndPeekNextFrom: aStream [
	"Same as #skipSeparators, but returns the next character after the separators if such exists."

	| state character |
	[ 
		state := self saveStateOf: aStream.
		(character := aStream next) 
			ifNil: [ false ]
			ifNotNil: [ character isSeparator ] ] whileTrue.
	character ifNotNil: [ 
		self restoreStateOf: aStream with: state.
		^character ].
	^aStream
	
]

{ #category : #'fileIn\/Out' }
TextConverter >> skipSeparatorsFrom: aStream [

	| state character |
	[ 
		state := self saveStateOf: aStream.
		(character := aStream next) 
			ifNil: [ false ]
			ifNotNil: [ character isSeparator ] ] whileTrue.
	character ifNotNil: [ 
		self restoreStateOf: aStream with: state ]
	
]
