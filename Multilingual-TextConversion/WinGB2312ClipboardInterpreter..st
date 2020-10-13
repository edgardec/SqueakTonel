Class {
	#name : #WinGB2312ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
WinGB2312ClipboardInterpreter >> fromSystemClipboard: aString [

	^ aString squeakToMac convertFromSystemString.

]

{ #category : #'conversion-clipboard' }
WinGB2312ClipboardInterpreter >> toSystemClipboard: text [

	| string |
	"self halt."
	string := text asString.
	string isAsciiString ifTrue: [^ string asOctetString].
	string isOctetString ifTrue: [^ string "hmm"].
	^ string convertToSystemString squeakToMac.

]
