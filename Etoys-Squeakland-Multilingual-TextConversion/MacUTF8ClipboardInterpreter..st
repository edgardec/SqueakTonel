Class {
	#name : #MacUTF8ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
MacUTF8ClipboardInterpreter >> fromSystemClipboard: aString [
	^ aString convertFromWithConverter: UTF8TextConverter new
]

{ #category : #'as yet unclassified' }
MacUTF8ClipboardInterpreter >> toSystemClipboard: text [

	| string |
	string := text asString.
	string isAsciiString ifTrue: [^ string asOctetString].
	string isOctetString ifTrue: [^ string ].
	^ string convertToWithConverter: UTF8TextConverter new .

]
