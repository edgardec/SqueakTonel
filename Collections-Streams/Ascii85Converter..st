"
I convert between binary data and an Ascii85 text representation of PostScript and PDF fame.
I am a little bit more efficient (~25% overhead) than Base64 (~30% overhead).

Instance Variables
	binary:		<Boolean>	- Tells whether to decode to binary data or characters
	dataStream:		<PositionableStream> - The data stream to decode to or encode from (Typically does not contain Ascii85)
	stringStream:		<PositionableStream> - The text stream to decode from or encode to (Always contains Ascii85)
	number85:		<Integer> - Decoder state, accumulated read number in base85
	tupleSize:		<SmallInteger> - Number of bytes read into number85 already
			
'Hello, World' ascii85Encoded.

'<~87cURD]htuF_+us~>' ascii85Decoded.

"
Class {
	#name : #Ascii85Converter,
	#superclass : #Object,
	#instVars : [
		'dataStream',
		'stringStream',
		'number85',
		'tupleSize',
		'binary'
	],
	#category : #'Collections-Streams'
}

{ #category : #convenience }
Ascii85Converter class >> decode: aStringOrStream as: contentsClass [

	^ contentsClass streamContents:
		[:out | self decode: aStringOrStream to: out]
]

{ #category : #convenience }
Ascii85Converter class >> decode: aStringOrStream to: outStream [

	^ (self stringStream: aStringOrStream readStream dataStream: outStream)
		decode
]

{ #category : #convenience }
Ascii85Converter class >> decodeToBytes: aStringOrStream [
	" Analogous to Base64MimeConverter>>#mimeDecodeToBytes:"
	| expectedSize |
	expectedSize := aStringOrStream size * 4 // 5.
	^ (ByteArray new: expectedSize streamContents:
		[:stream |
			(self stringStream: aStringOrStream readStream dataStream: stream)
				decodeToByteArray]) readStream
]

{ #category : #convenience }
Ascii85Converter class >> decodeToChars: aStringOrStream [
	" Analogous to Base64MimeConverter>>#mimeDecodeToChars:"
	| expectedSize |
	expectedSize := aStringOrStream size * 4 // 5.
	^ (String new: expectedSize streamContents:
		[:stream | self decode: aStringOrStream to: stream]) readStream
]

{ #category : #convenience }
Ascii85Converter class >> encode: aCollectionOrStream [

	^ String streamContents:
		[:out | self encode: aCollectionOrStream to: out]
]

{ #category : #convenience }
Ascii85Converter class >> encode: aCollectionOrStream to: outStream [

	^ (self stringStream: outStream dataStream: aCollectionOrStream readStream)
		encode
]

{ #category : #'instance creation' }
Ascii85Converter class >> stringStream: aStream dataStream: anotherStream [

	^ self new
		stringStream: aStream;
		dataStream: anotherStream;
		yourself
]

{ #category : #accessing }
Ascii85Converter >> ascii [

	binary := false.
]

{ #category : #accessing }
Ascii85Converter >> binary [

	binary := true.
]

{ #category : #accessing }
Ascii85Converter >> dataStream [

	^dataStream
]

{ #category : #accessing }
Ascii85Converter >> dataStream: anObject [

	dataStream := anObject.
]

{ #category : #conversion }
Ascii85Converter >> decode [

	self readBOD ifFalse: [^ self dataStream].

	[self stringStream atEnd] whileFalse: [
		self stringStream skipSeparators.
		self readEOD ifTrue: [^ self endDecode]. "<--- End of data"

		self decodeChar: self stringStream next ifFail: [^ self dataStream]].
	"actually, should not reach, but our failure condition is returning the stream, anyway"		
	^ self dataStream
]

{ #category : #conversion }
Ascii85Converter >> decodeChar: char ifFail: failBlock [

	char = $z ifTrue: [^ self decodeZIfFail: failBlock].
	
	(char between: $! and: $u) ifFalse: [^ failBlock value].

	self incrementTupleSize.
	self incrementNumber85: char asInteger - 33 * (self pow85 at: self tupleSize).
	self tupleSize = 5 ifTrue:
		[self isBinary
			ifTrue: [self writeBytes255: self number85 atMax: 4]
			ifFalse: [self writeChars255: self number85 atMax: 4].
		self resetDecoderState]
]

{ #category : #conversion }
Ascii85Converter >> decodeToByteArray [
	
	self binary.
	^ self decode
]

{ #category : #conversion }
Ascii85Converter >> decodeZIfFail: failBlock [

	self tupleSize ~= 0 ifTrue: [^ failBlock value].
	self dataStream next: 4 put: (self isBinary ifTrue: [0] ifFalse: [Character null]).

]

{ #category : #conversion }
Ascii85Converter >> encode [

	| lineLength  |
	
	lineLength := 0.
	self stringStream nextPutAll: '<~'.
	[self dataStream atEnd] whileFalse: [
		| raw data out |
		lineLength >= 74 ifTrue: [self stringStream cr.  lineLength := 0].
		out := 5.
		raw := (self dataStream next: 4) asByteArray.
		raw size < 4 ifTrue:
			[out := raw size + 1.
			raw := raw, (self padOfSize: 4 - raw size)].
		data := raw unsignedLongAt: 1 bigEndian: true.
		data = 0
			ifTrue: [self stringStream nextPut: $z. lineLength := lineLength + 1]
			ifFalse: [self write85: data atMax: out. lineLength := lineLength + out]].
	self stringStream nextPutAll: '~>'.
	^ self stringStream

]

{ #category : #private }
Ascii85Converter >> endDecode [

	self tupleSize  > 0 ifTrue: 
		[self incrementNumber85: (self pow85 at: self tupleSize).
		self isBinary
			ifTrue: [self writeBytes255: self number85 atMax: self tupleSize - 1]
			ifFalse: [self writeChars255: self number85 atMax: self tupleSize - 1]].
	^ self dataStream
]

{ #category : #private }
Ascii85Converter >> incrementNumber85: aNumber [

	number85 := number85 + aNumber.

	
]

{ #category : #private }
Ascii85Converter >> incrementTupleSize [

	tupleSize := tupleSize + 1.
	
]

{ #category : #'initialize-release' }
Ascii85Converter >> initialize [

	super initialize.
	self ascii.
	self resetDecoderState.
]

{ #category : #testing }
Ascii85Converter >> isBinary [

	^ binary
]

{ #category : #accessing }
Ascii85Converter >> number85 [

	^ number85
]

{ #category : #private }
Ascii85Converter >> padOfSize: anInteger [

	anInteger = 1 ifTrue: [ ^#[0] ].
	anInteger = 2 ifTrue: [ ^#[0 0] ].
	anInteger = 3 ifTrue: [ ^#[0 0 0] ].
	self error: 'Should not reach'
]

{ #category : #private }
Ascii85Converter >> pow85 [
	
	^ #(52200625 614125 7225 85 1) "{85*85*85*85 . 85*85*85 . 85*85 . 85. 1}"
]

{ #category : #private }
Ascii85Converter >> readBOD [

	self stringStream skipSeparators.
	self stringStream peek = $< ifFalse: [^ false] ifTrue:
		[self stringStream next. "ignore"
		self stringStream peek = $~ ifFalse: [^ false] ifTrue:
			[self stringStream next "ignore"]].
	^ true
]

{ #category : #private }
Ascii85Converter >> readEOD [

	self stringStream skipSeparators.
	self stringStream peek = $~ ifFalse: [^ false] ifTrue:
		[self stringStream next. "ignore"
		self stringStream peek = $> ifFalse: [^ false] ifTrue:
			[self stringStream next "ignore"]].
	^ true
]

{ #category : #private }
Ascii85Converter >> resetDecoderState [

	number85 := 0.
	tupleSize := 0.
	
]

{ #category : #accessing }
Ascii85Converter >> stringStream [

	^ stringStream
]

{ #category : #accessing }
Ascii85Converter >> stringStream: anObject [

	stringStream := anObject.
]

{ #category : #accessing }
Ascii85Converter >> tupleSize [

	^ tupleSize
]

{ #category : #writing }
Ascii85Converter >> write85: anInteger atMax: aNumber [

	| c1 c2 c3 c4 c5 remain |
	remain := anInteger.
	c5 := (remain \\ 85 + 33) asCharacter. remain := remain // 85.
	c4 := (remain \\ 85 + 33) asCharacter. remain := remain // 85.
	c3 := (remain \\ 85 + 33) asCharacter. remain := remain // 85.
	c2 := (remain \\ 85 + 33) asCharacter. remain := remain // 85.
	c1 := (remain \\ 85 + 33) asCharacter. remain := remain // 85.
	aNumber > 0 ifTrue: [self stringStream nextPut: c1.
	aNumber > 1 ifTrue: [self stringStream nextPut: c2.
	aNumber > 2 ifTrue: [self stringStream nextPut: c3.
	aNumber > 3 ifTrue: [self stringStream nextPut: c4.
	aNumber > 4 ifTrue: [self stringStream nextPut: c5]]]]].
	
]

{ #category : #writing }
Ascii85Converter >> writeBytes255: anInteger atMax: aNumber [

	(aNumber between: 1 and: 4) ifFalse: [^ self error: 'Unexpected byte count'].
	4 to: (5 - aNumber) by: -1 do:
		[:index | self dataStream nextPut: (anInteger digitAt: index)].

]

{ #category : #writing }
Ascii85Converter >> writeChars255: anInteger atMax: aNumber [

	(aNumber between: 1 and: 4) ifFalse: [^ self error: 'Unexpected byte count'].
	4 to: (5 - aNumber) by: -1 do:
		[:index | self dataStream nextPut: (anInteger digitAt: index) asCharacter].

]
