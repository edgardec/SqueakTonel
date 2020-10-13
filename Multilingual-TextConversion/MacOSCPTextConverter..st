Class {
	#name : #MacOSCPTextConverter,
	#superclass : #ByteTextConverter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'class initialization' }
MacOSCPTextConverter class >> initializeDecodeTable [
	decodeTable := (0 to: 255) asArray
]
