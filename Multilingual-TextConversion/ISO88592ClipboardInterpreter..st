Class {
	#name : #ISO88592ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
ISO88592ClipboardInterpreter >> fromSystemClipboard: aString [

	^ aString convertFromWithConverter: ISO88592TextConverter new.

]

{ #category : #'conversion-clipboard' }
ISO88592ClipboardInterpreter >> toSystemClipboard: aString [

	| result converter |

	aString isAsciiString ifTrue: [^ aString asOctetString]. "optimization"

	result := WriteStream on: (String new: aString size).
	converter := ISO88592TextConverter new.
	aString do: [:each | | r |
		r := converter fromSqueak: each.].
	^ result contents.

]
