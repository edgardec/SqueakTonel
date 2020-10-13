Class {
	#name : #UnixJPClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
UnixJPClipboardInterpreter >> fromSystemClipboard: aString [
	^ aString convertFromSystemString
]

{ #category : #'conversion-clipboard' }
UnixJPClipboardInterpreter >> toSystemClipboard: text [

	| string |
	"self halt."
	string := text asString.
	string isAsciiString ifTrue: [^ string asOctetString].
	string isOctetString ifTrue: [^ string "hmm"].
	^ string convertToSystemString .

]
