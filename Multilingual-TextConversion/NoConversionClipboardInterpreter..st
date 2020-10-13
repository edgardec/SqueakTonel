Class {
	#name : #NoConversionClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
NoConversionClipboardInterpreter >> fromSystemClipboard: aString [

	^ aString.

]

{ #category : #'conversion-clipboard' }
NoConversionClipboardInterpreter >> toSystemClipboard: aString [

	| result |
	aString isOctetString ifTrue: [^ aString asOctetString].

	result := WriteStream on: (String new: aString size).
	aString do: [:each | each value < 256 ifTrue: [result nextPut: each]].
	^ result contents.

]
