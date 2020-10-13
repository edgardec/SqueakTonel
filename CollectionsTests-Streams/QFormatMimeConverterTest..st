Class {
	#name : #QFormatMimeConverterTest,
	#superclass : #TestCase,
	#instVars : [
		'message'
	],
	#category : #'CollectionsTests-Streams'
}

{ #category : #running }
QFormatMimeConverterTest >> setUp [
	message := 'Hü Thörä!' readStream.

]

{ #category : #tests }
QFormatMimeConverterTest >> testDecode [

	| encodedString decodedString |
	encodedString := '=E0'.
	decodedString := QEncodingMimeConverter mimeDecode: encodedString as: WideString.
	self assert: 'à' equals: decodedString.
	
	encodedString := 'H=FC_Th=F6r=E4!'.
	decodedString := QEncodingMimeConverter mimeDecode: encodedString as: WideString.
	self assert: 'Hü Thörä!' equals: decodedString.
	
	encodedString := 'H=FC=20Th=F6r=E4!'.
	decodedString := QEncodingMimeConverter mimeDecode: encodedString as: WideString.
	self assert: 'Hü Thörä!' equals: decodedString.
]

{ #category : #tests }
QFormatMimeConverterTest >> testEncodeSimpleString [

	| encodedString |
	encodedString := QEncodingMimeConverter mimeEncode: message.
	self assert: '=?UTF-8?Q?H=C3=BC?= =?UTF-8?Q?Th=C3=B6r=C3=A4!?=' equals: encodedString.
	
]

{ #category : #tests }
QFormatMimeConverterTest >> testEncodeSimpleStringWithQuestionMark [

	| encodedString |
	encodedString := QEncodingMimeConverter mimeEncode: 'Is üt?'.
	self assert: 'Is =?UTF-8?Q?=C3=BCt=3F?=' equals: encodedString.
	
]

{ #category : #tests }
QFormatMimeConverterTest >> testRoundtrip [

	| result start |
	start := 'Is üt?'.
	result := ((QEncodingMimeConverter mimeEncode: start) as: String) decodeMimeHeader.
	self assert: start equals: result.
	
]
