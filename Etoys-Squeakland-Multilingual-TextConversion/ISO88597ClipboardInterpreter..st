Class {
	#name : #ISO88597ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
ISO88597ClipboardInterpreter >> fromSystemClipboard: aString [

	^ aString convertFromWithConverter: ISO88597TextConverter new.

]

{ #category : #'as yet unclassified' }
ISO88597ClipboardInterpreter >> toSystemClipboard: aString [

	| result converter |

	aString isAsciiString ifTrue: [^ aString asOctetString]. "optimization"

	result := WriteStream on: (String new: aString size).
	converter := ISO88597TextConverter new.
	aString do: [:each |
		result nextPut: (converter fromSqueak: each).].
	^ result contents.

]
