"
I do q format MIME decoding as specified in RFC 2047 """"MIME Part Three: Message Header Extensions for Non-ASCII Text"". See String>>decodeMimeHeader
"
Class {
	#name : #QEncodingMimeConverter,
	#superclass : #QuotedPrintableMimeConverter,
	#category : #'Collections-Streams'
}

{ #category : #'private-encoding' }
QEncodingMimeConverter >> encodeChar: aChar to: aStream [

	aChar = Character space
		ifTrue: [^ aStream nextPut: $_].
	^ super encodeChar: aChar to: aStream
]

{ #category : #'private-encoding' }
QEncodingMimeConverter >> encodeWord: aString [

	| characterEncodedString |
	(aString noneSatisfy: [:c | self conversionNeededFor: c])
		ifTrue: [^ aString].
	
	characterEncodedString := aString squeakToUtf8.
		
	^ String streamContents: [:stream |
		stream nextPutAll: '=?UTF-8?Q?'.
		characterEncodedString do: [:c | self encodeChar: c to: stream].
		stream nextPutAll: '?=']
]

{ #category : #conversion }
QEncodingMimeConverter >> mimeDecode [
	"Do conversion reading from mimeStream writing to dataStream. See String>>decodeMimeHeader for the character set handling."

	| c |
	[mimeStream atEnd] whileFalse: [
		c := mimeStream next.
		c = $=
			ifTrue: [c := Character value: mimeStream next digitValue * 16
				+ mimeStream next digitValue]
			ifFalse: [c = $_ ifTrue: [c := $ ]].
		dataStream nextPut: c].
	^ dataStream
]

{ #category : #conversion }
QEncodingMimeConverter >> mimeEncode [
	"Do conversion reading from dataStream writing to mimeStream. Break long lines and escape non-7bit chars."
	
	| currentWord encodedWord |
	
	[dataStream atEnd] whileFalse: [
		self readUpToWordInto: mimeStream.
		currentWord := self readWord.
		encodedWord := self encodeWord: currentWord.
		mimeStream nextPutAll: encodedWord].
	
	^ mimeStream
]

{ #category : #'private-encoding' }
QEncodingMimeConverter >> readUpToWordInto: aStream [

	| currentCharacter |
	[dataStream atEnd] whileFalse:
		[currentCharacter := dataStream peek.
		 currentCharacter isSeparator 
			ifTrue: [aStream nextPut: currentCharacter.
					dataStream next]
			ifFalse: [^ true]]
]

{ #category : #'private-encoding' }
QEncodingMimeConverter >> readWord [

	| strm |
	strm := WriteStream on: (String new: 20).
	[dataStream atEnd] whileFalse: [
		dataStream peek isSeparator 
			ifTrue: [^ strm contents] 
			ifFalse: [strm nextPut: dataStream next]].
	^ strm contents
]

{ #category : #'private-encoding' }
QEncodingMimeConverter >> reservedCharacters [

	^ '?=_ ' 
]
