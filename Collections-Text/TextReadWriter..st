"
Subclasses of me provide means to create instances of Text from various document formats such as HTML (Hyper Text Markup Language), DOCX (Microsoft Word Document), ODF (Open Document Format), and RTF (Rich Text Format). They should also be able to write such formats.
"
Class {
	#name : #TextReadWriter,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Collections-Text'
}

{ #category : #'instance creation' }
TextReadWriter class >> on: stream [

	^ self new on: stream
]

{ #category : #'instance creation' }
TextReadWriter class >> textFromFileNamed: fileName [

	^ self textFromStream: (FileStream readOnlyFileNamed: fileName)
]

{ #category : #'instance creation' }
TextReadWriter class >> textFromStream: aBinaryStream [
	
	| reader readerClass text |
	readerClass := self. "no auto-detection yet"
	aBinaryStream reset.
	reader := readerClass new on: aBinaryStream.
	Cursor read showWhile: [
		text := reader nextText.
		reader close].
	^ text

]

{ #category : #'initialize-release' }
TextReadWriter >> close [

	stream close.
]

{ #category : #accessing }
TextReadWriter >> nextPutText: aText [
	"Encoding aText on stream."
	
	self subclassResponsibility.
]

{ #category : #accessing }
TextReadWriter >> nextText [
	"Decoding a text object on stream and answer that text object."
	
	^ self subclassResponsibility.
]

{ #category : #'initialize-release' }
TextReadWriter >> on: aStream [

	stream := aStream.
]
