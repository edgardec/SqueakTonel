Class {
	#name : #WinCPTextConverter,
	#superclass : #ByteTextConverter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'class initialization' }
WinCPTextConverter class >> initializeDecodeTable [
	decodeTable := (0 to: 255) asArray
]
