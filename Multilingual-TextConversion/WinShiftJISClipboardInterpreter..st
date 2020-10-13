Class {
	#name : #WinShiftJISClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
WinShiftJISClipboardInterpreter >> fromSystemClipboard: aString [

	^ aString macToSqueak convertFromSystemString

]

{ #category : #'conversion-clipboard' }
WinShiftJISClipboardInterpreter >> toSystemClipboard: text [

	| string |
	"self halt."
	string := text asString.
	string isAsciiString ifTrue: [^ string asOctetString].
	string isOctetString ifTrue: [^ string "hmm"].
	^ string convertToSystemString squeakToMac.

]
