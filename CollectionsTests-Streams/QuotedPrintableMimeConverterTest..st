Class {
	#name : #QuotedPrintableMimeConverterTest,
	#superclass : #TestCase,
	#instVars : [
		'message'
	],
	#category : #'CollectionsTests-Streams'
}

{ #category : #running }
QuotedPrintableMimeConverterTest >> setUp [
	message := 'Hü Thörä!' readStream.

]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testDecode [

	| encodedString decodedString |
	encodedString := '=E0'.
	decodedString := QuotedPrintableMimeConverter mimeDecode: encodedString as: WideString.
	self assert: 'à' equals: decodedString.
	
	encodedString := 'H=FC Th=F6r=E4!'.
	decodedString := QuotedPrintableMimeConverter mimeDecode: encodedString as: WideString.
	self assert: 'Hü Thörä!' equals: decodedString.
]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testDecodeCrLfToCr [

	| encodedString decodedString targetString |
	encodedString := ((WriteStream on: '') 
						<< 'a'; crlf; << 'b') contents.
	decodedString := QuotedPrintableMimeConverter mimeDecode: encodedString as: WideString.
	targetString := encodedString := ((WriteStream on: '') 
						<< 'a'; cr; << 'b') contents.
	self assert: targetString equals: decodedString.
]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testDecodeMultiline [

	| encodedString decodedString |
	encodedString := 'A multiline =
encoded text which isn''t'.
	decodedString := QuotedPrintableMimeConverter mimeDecode: encodedString as: WideString.
	self assert: 'A multiline encoded text which isn''t' equals: decodedString.
	
]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testEncodeEqualSign [

	| encodedString |
	encodedString := QuotedPrintableMimeConverter mimeEncode: 'e=mc2'.
	self assert: 'e=3Dmc2' equals: encodedString.
	
]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testEncodeMultilineString [

	| encodedString sourceString targetString |
	sourceString := 'a multi-
line string'.
	encodedString := QuotedPrintableMimeConverter mimeEncode: sourceString.
	
	targetString := 'a multi-' , String crlf , 'line string'.
	self assert: targetString equals: encodedString.
]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testEncodeSimpleString [

	| encodedString |
	encodedString := QuotedPrintableMimeConverter mimeEncode: message.
	self assert: 'H=FC Th=F6r=E4!' equals: encodedString.
	
]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testEncodeWhitespace [

	| encodedString sourceString targetString |
	sourceString := 'a string	with all the whitespace'.
	encodedString := QuotedPrintableMimeConverter mimeEncode: sourceString.
	
	targetString := 'a string	with all the whitespace'.
	self assert: targetString equals: encodedString.
]

{ #category : #tests }
QuotedPrintableMimeConverterTest >> testEncodingBreaksUpLongLInes [

	| encodedString |
	encodedString := QuotedPrintableMimeConverter mimeEncode: 'This is a very long message which has more than 76 characters due to this additional part of the sentence.'.
	self assert: 'This is a very long message which has more than 76 characters due to this=', String crlf , ' additional part of the sentence.' equals: encodedString.
	
]
