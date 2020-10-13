"
I do ""quoted printable"" MIME decoding as specified in RFC 2045 ""MIME Part One: Format of Internet Message Bodies"".

Short version of RFC2045, Sect. 6.7:

	(1) Any octet, except a CR or LF that is part of a CRLF line break of the canonical (standard) form of the data being encoded, may be represented by an ""="" followed by a two digit hexadecimal representation of the octet's value. [...]

	(2) Octets with decimal values of 33 through 60 inclusive, and 62 through 126, inclusive, MAY be represented as the US-ASCII characters which correspond to those octets [...].

	(3) Octets with values of 9 and 32 MAY be represented as US-ASCII TAB (HT) and SPACE characters,
 respectively, but MUST NOT be so represented at the end of an encoded line.  [...]

	(4) A line break in a text body, represented as a CRLF sequence in the text canonical form, must be represented by a (RFC 822) line break, which is also a CRLF sequence, in the Quoted-Printable encoding.  [...]

	(5) The Quoted-Printable encoding REQUIRES that encoded lines be no more than 76 characters long.  If longer lines are to be encoded with the Quoted-Printable encoding, ""soft"" line breaks
 must be used.  An equal sign as the last character on a encoded line indicates such a non-significant (""soft"") line break in the encoded text.

--bf 11/27/1998 16:50

(2) simply states that 33 to 126 can be represented by US-ASCII except of the equal-sign itself

--pre
"
Class {
	#name : #QuotedPrintableMimeConverter,
	#superclass : #MimeConverter,
	#category : #'Collections-Streams'
}

{ #category : #conversion }
QuotedPrintableMimeConverter >> conversionNeededFor: aCharacter [

	^ ((aCharacter asciiValue between: 32 and: 127) not and: [aCharacter asciiValue ~= 9])
		or: [self reservedCharacters includes: aCharacter]
]

{ #category : #'as yet unclassified' }
QuotedPrintableMimeConverter >> encodeChar: aChar to: aStream [

	(self conversionNeededFor: aChar)
			ifFalse: [aStream nextPut: aChar]
			ifTrue: [aStream nextPut: $=;
						nextPut: (Character digitValue: aChar asciiValue // 16);
						nextPut: (Character digitValue: aChar asciiValue \\ 16)].
			
	

]

{ #category : #conversion }
QuotedPrintableMimeConverter >> mimeDecode [
	"Do conversion reading from mimeStream writing to dataStream"

	| line lineStream c1 v1 c2 v2 |
	[(line := mimeStream nextLine) isNil] whileFalse: [
		line := line withoutTrailingBlanks.
		line 
			ifEmpty: [dataStream cr]
			ifNotEmpty: [
				lineStream := ReadStream on: line.
				[dataStream nextPutAll: (lineStream upTo: $=).
				lineStream atEnd] whileFalse: [
					c1 := lineStream next. v1 := c1 digitValue.
					((v1 between: 0 and: 15) and: [lineStream atEnd not])
						ifFalse: [dataStream nextPut: $=; nextPut: c1]
						ifTrue: [c2 := lineStream next. v2 := c2 digitValue.
							(v2 between: 0 and: 15)
								ifFalse: [dataStream nextPut: $=; nextPut: c1; nextPut: c2]
								ifTrue: [dataStream nextPut: (Character value: v1 * 16 + v2)]]].
				(line last ~= $= and: [mimeStream atEnd not]) ifTrue: [dataStream cr]]].
	^ dataStream
]

{ #category : #conversion }
QuotedPrintableMimeConverter >> mimeEncode [
	"Do conversion reading from dataStream writing to mimeStream. Break long lines and escape non-7bit chars."

	| currentCharacter line lineStream linePosition |
	currentCharacter := nil.
	[(line := dataStream nextLine) isNil] whileFalse: [
		lineStream := ReadStream on: line.
		linePosition := 0.
		
		[lineStream atEnd] whileFalse: [
			currentCharacter := lineStream next.
			self encodeChar: currentCharacter to: mimeStream.
			linePosition := linePosition + 1.
			linePosition = 73 ifTrue: [mimeStream nextPut: $=; crlf. linePosition := 0]].
		dataStream atEnd ifFalse: [mimeStream crlf]].
	^ mimeStream
]

{ #category : #'as yet unclassified' }
QuotedPrintableMimeConverter >> reservedCharacters [

	^ '=' 
]
