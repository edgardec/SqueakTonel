Class {
	#name : #UTF8JPClipboardInterpreter,
	#superclass : #UTF8ClipboardInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
UTF8JPClipboardInterpreter >> fromSystemClipboard: aString [
	^aString convertFromWithConverter: UTF8TextConverter new.

]
