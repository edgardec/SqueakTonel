Class {
	#name : #WinKSX1001ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
WinKSX1001ClipboardInterpreter >> fromSystemClipboard: aString [

	^ aString squeakToMac convertFromSystemString.

]

{ #category : #'conversion-clipboard' }
WinKSX1001ClipboardInterpreter >> toSystemClipboard: text [

	| string |
	"self halt."
	string := text asString.
	string isAsciiString ifTrue: [^ string asOctetString].
	string isOctetString ifTrue: [^ string "hmm"].
	^ string convertToSystemString squeakToMac.

]
