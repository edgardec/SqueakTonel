"
Text converter for ISO 8859-1.  An international encoding used in Western Europe.
"
Class {
	#name : #ISO88591TextConverter,
	#superclass : #ISO8859TextConverter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #utilities }
ISO88591TextConverter class >> encodingNames [ 

	^ #('latin-1' 'latin1' 'iso-8859-1' 'us-ascii') copy.

]

{ #category : #'class initialization' }
ISO88591TextConverter class >> initializeDecodeTable [
	decodeTable := (0 to: 255) asIntegerArray
]

{ #category : #conversion }
ISO88591TextConverter >> nextFromStream: aStream [

	^ aStream basicNext.

]
