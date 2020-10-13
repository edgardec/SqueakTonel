Class {
	#name : #NullMimeConverter,
	#superclass : #MimeConverter,
	#category : #'Collections-Streams'
}

{ #category : #'as yet unclassified' }
NullMimeConverter >> mimeDecode [

	dataStream nextPutAll: mimeStream upToEnd.
	^ dataStream
]

{ #category : #'as yet unclassified' }
NullMimeConverter >> mimeEncode [

	mimeStream nextPutAll: dataStream upToEnd.
	^ mimeStream

]
