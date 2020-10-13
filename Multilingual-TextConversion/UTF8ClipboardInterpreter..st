Class {
	#name : #UTF8ClipboardInterpreter,
	#superclass : #ClipboardInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
UTF8ClipboardInterpreter >> fromSystemClipboard: aString [
	^aString utf8ToSqueak
]

{ #category : #'conversion-clipboard' }
UTF8ClipboardInterpreter >> toSystemClipboard: aString [
	^aString squeakToUtf8

]
