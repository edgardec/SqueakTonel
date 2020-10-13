Class {
	#name : #Bit7MimeConverter,
	#superclass : #MimeConverter,
	#category : #'Collections-Streams'
}

{ #category : #'as yet unclassified' }
Bit7MimeConverter >> mimeDecode [

	dataStream nextPutAll: mimeStream upToEnd.
	^ dataStream
]

{ #category : #'as yet unclassified' }
Bit7MimeConverter >> mimeEncode [

	| character |
	[dataStream atEnd] whileFalse: [
		character := dataStream next.
		self assert: character asciiValue < 128.
		mimeStream nextPut: character].
	
	^ mimeStream
]
