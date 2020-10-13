Class {
	#name : #MacShiftJISClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
MacShiftJISClipboardInterpreter >> fromSystemClipboard: aString [
	^ aString convertFromWithConverter: ShiftJISTextConverter new
]

{ #category : #'conversion-clipboard' }
MacShiftJISClipboardInterpreter >> toSystemClipboard: text [

	| string |
	"self halt."
	string := text asString.
	string isAsciiString ifTrue: [^ string asOctetString].
	string isOctetString ifTrue: [^ string "hmm"].
	^ string convertToWithConverter: ShiftJISTextConverter new .

]
