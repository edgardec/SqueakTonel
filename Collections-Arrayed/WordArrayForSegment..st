Class {
	#name : #WordArrayForSegment,
	#superclass : #WordArray,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #'objects from disk' }
WordArrayForSegment >> restoreEndianness [
	"This word object was just read in from a stream.  Do not correct the Endianness because the load primitive will reverse bytes as needed."

	"^ self"

]

{ #category : #'objects from disk' }
WordArrayForSegment >> writeOn: aByteStream [
	"Write quickly and disregard the endianness of the words.  Store the array of bits onto the argument, aStream.  (leading byte ~= 16r80) identifies this as raw bits (uncompressed)."

	aByteStream nextInt32Put: self size.	"4 bytes"
	aByteStream nextPutAll: self

]
