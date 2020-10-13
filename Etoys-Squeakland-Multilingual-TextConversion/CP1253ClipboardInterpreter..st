Class {
	#name : #CP1253ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
CP1253ClipboardInterpreter >> fromSystemClipboard: aString [

	| result converter |
	result := WriteStream on: (String new: aString size).
	converter := CP1253TextConverter new.
	aString do: [:each |
		result nextPut: (converter toSqueak: each macToSqueak) asCharacter.
	].
	^ result contents.

]

{ #category : #'as yet unclassified' }
CP1253ClipboardInterpreter >> toSystemClipboard: aString [

	| result converter r |
	aString isAsciiString ifTrue: [^ aString asOctetString]. "optimization"

	result := WriteStream on: (String new: aString size).
	converter := CP1253TextConverter new.
	aString do: [:each |
		r := converter fromSqueak: each.
		r charCode < 255 ifTrue: [
		result nextPut: r squeakToMac]].
	^ result contents.

]
