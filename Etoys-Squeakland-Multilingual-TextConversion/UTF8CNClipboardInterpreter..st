Class {
	#name : #UTF8CNClipboardInterpreter,
	#superclass : #UTF8ClipboardInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
UTF8CNClipboardInterpreter >> fromSystemClipboard: aString [
	^aString convertFromWithConverter: UTF8TextConverter new.
]
