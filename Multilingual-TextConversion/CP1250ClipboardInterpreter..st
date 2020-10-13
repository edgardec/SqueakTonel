Class {
	#name : #CP1250ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
CP1250ClipboardInterpreter >> fromSystemClipboard: aString [

	| result converter |
	result := WriteStream on: (String new: aString size).
	converter := CP1250TextConverter new.
	aString do: [:each |
		result nextPut: (converter toSqueak: each macToSqueak) asCharacter.
	].
	^ result contents.

]

{ #category : #'conversion-clipboard' }
CP1250ClipboardInterpreter >> toSystemClipboard: aString [

	| result converter |
	aString isAsciiString ifTrue: [^ aString asOctetString]. "optimization"

	result := WriteStream on: (String new: aString size).
	converter := CP1250TextConverter new.
	aString do: [:each |
		| r |
		r := converter fromSqueak: each.
		r charCode < 255 ifTrue: [
		result nextPut: r squeakToMac]].
	^ result contents.

]
