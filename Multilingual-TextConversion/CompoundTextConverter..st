"
Text converter for X Compound Text.
"
Class {
	#name : #CompoundTextConverter,
	#superclass : #TextConverter,
	#instVars : [
		'state',
		'acceptingEncodings'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #utilities }
CompoundTextConverter class >> encodingNames [

	^ #('iso-2022-jp' 'x-ctext') copy

]

{ #category : #query }
CompoundTextConverter >> accepts: aSymbol [

	^ acceptingEncodings includes: aSymbol.

]

{ #category : #friend }
CompoundTextConverter >> currentCharSize [

	^ state charSize.

]

{ #category : #friend }
CompoundTextConverter >> emitSequenceToResetStateIfNeededOn: aStream [

	Latin1 emitSequenceToResetStateIfNeededOn: aStream forState: state.

]

{ #category : #conversion }
CompoundTextConverter >> encodeString: aString [

	^String new: aString size streamContents: [ :stream | 
		self 
			nextPutAll: aString
			toStream: stream.
		Latin1
			emitSequenceToResetStateIfNeededOn: stream
			forState: state ]
]

{ #category : #'initialize-release' }
CompoundTextConverter >> initialize [
	super initialize.
	state := CompoundTextConverterState 
		g0Size: 1 g1Size: 1 g0Leading: 0 g1Leading: 0 charSize: 1 streamPosition: 0.
	acceptingEncodings := #(ascii iso88591 jisx0208 gb2312 ksc5601 ksx1001 ) copy.

]

{ #category : #conversion }
CompoundTextConverter >> nextFromStream: aStream [ 

	| character character2 size leadingChar offset result |
	aStream isBinary ifTrue: [^ aStream basicNext].

	character := aStream basicNext.
	character ifNil: [^ nil].
	character == Character escape ifTrue: [
		self parseShiftSeqFromStream: aStream.
		character := aStream basicNext.
		character ifNil: [^ nil]].
	character asciiValue < 128 ifTrue: [
		size := state g0Size.
		leadingChar := state g0Leading.
		offset := 16r21.
	] ifFalse: [
		size :=state g1Size.
		leadingChar := state g1Leading.
		offset := 16rA1.
	].
	size = 1 ifTrue: [
		leadingChar = 0
			ifTrue: [^ character]
			ifFalse: [^ Character leadingChar: leadingChar code: character asciiValue]
	].
	size = 2 ifTrue: [
		character2 := aStream basicNext.
		character2 ifNil: [^ nil. "self errorMalformedInput"].
		character := character asciiValue - offset.
		character2 := character2 asciiValue - offset.
		result := Character leadingChar: leadingChar code: character * 94 + character2.
		^ self toUnicode: result
	].
	self error: 'unsupported encoding'.

]

{ #category : #conversion }
CompoundTextConverter >> nextPut: aCharacter toStream: aStream [

	| charCode leadingChar class |
	aStream isBinary ifTrue: [^aCharacter storeBinaryOn: aStream].
	aCharacter isTraditionalDomestic ifFalse: [
		class := (EncodedCharSet charsetAt: aCharacter leadingChar) traditionalCharsetClass.
		charCode := (class charFromUnicode: aCharacter asUnicode) charCode.
		leadingChar := class leadingChar.
	] ifTrue: [
		charCode := aCharacter charCode.
		leadingChar := aCharacter leadingChar.
	].
	charCode < 256 ifTrue: [
		(latin1Encodings at: charCode + 1)
			ifNil: [ aStream basicNextPut: aCharacter ]
			ifNotNil: [ :encodedString | aStream basicNextPutAll: encodedString ].
		^aCharacter ].
	self 
		nextPutValue: charCode
		toStream: aStream
		withShiftSequenceIfNeededForLeadingChar: leadingChar.
	^aCharacter

]

{ #category : #private }
CompoundTextConverter >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForLeadingChar: leadingChar [

	| charset |
	charset := EncodedCharSet charsetAt: leadingChar.
	charset ifNotNil: [
		charset nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state.
	] ifNil: [
		"..."
	].

]

{ #category : #private }
CompoundTextConverter >> parseShiftSeqFromStream: aStream [

	| c set target id |
	c := aStream basicNext.
	c = $$ ifTrue: [
		set := #multibyte.
		c := aStream basicNext.
		c = $( ifTrue: [target := 1].
		c = $) ifTrue: [target := 2].
		target ifNil: [target := 1. id := c]
			ifNotNil: [id := aStream basicNext].
	] ifFalse: [
		c = $( ifTrue: [target := 1. set := #nintyfour].
		c = $) ifTrue: [target := 2. set := #nintyfour].
		c = $- ifTrue: [target := 2. set := #nintysix].
		"target = nil ifTrue: [self errorMalformedInput]."
		id := aStream basicNext.
	].
	(set = #multibyte and: [id = $B]) ifTrue: [
		state charSize: 2.
		target = 1 ifTrue: [
			state g0Size: 2.
			state g0Leading: 1.
		] ifFalse: [
			state g1Size: 2.
			state g1Leading: 1.
		].
		^ self
	].
	(set = #multibyte and: [id = $A]) ifTrue: [
		state charSize: 2.
		target = 1 ifTrue: [
			state g0Size: 2.
			state g0Leading: 2.
		] ifFalse: [
			state g1Size: 2.
			state g1Leading: 2.
		].
		^ self
	].

	(set = #nintyfour and: [id = $B or: [id = $J]]) ifTrue: [
		state charSize: 1.
		state g0Size: 1.
		state g0Leading: 0.
		^ self
	].
	(set = #nintysix and: [id = $A]) ifTrue: [
		state charSize: 1.
		state g1Size: 1.
		state g1Leading: 0.
		^ self
	].

	"self errorUnsupported."

]

{ #category : #friend }
CompoundTextConverter >> restoreStateOf: aStream with: aConverterState [

	state := aConverterState copy.
	aStream position: state streamPosition.

]

{ #category : #friend }
CompoundTextConverter >> saveStateOf: aStream [

	| inst |
	inst :=  state shallowCopy.
	inst streamPosition: aStream position.
	^ inst.

]

{ #category : #private }
CompoundTextConverter >> toUnicode: aChar [

	| charset v |
	aChar leadingChar = 0 ifTrue: [^ aChar].
	charset := (EncodedCharSet charsetAt: aChar leadingChar) charsetClass.
	v := charset convertToUnicode: aChar charCode.
	^ Character leadingChar: charset unicodeLeadingChar code: v
]
