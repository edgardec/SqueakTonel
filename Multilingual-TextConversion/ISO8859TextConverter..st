Class {
	#name : #ISO8859TextConverter,
	#superclass : #ByteTextConverter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'class initialization' }
ISO8859TextConverter class >> initializeDecodeTable [
	decodeTable := (0 to: 255) asArray
]
