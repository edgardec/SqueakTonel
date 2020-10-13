Class {
	#name : #ClipboardInterpreter,
	#superclass : #Object,
	#category : #'Multilingual-TextConversion'
}

{ #category : #'conversion-clipboard' }
ClipboardInterpreter >> fromSystemClipboard: aString [

	self subclassResponsibility.

]

{ #category : #'conversion-clipboard' }
ClipboardInterpreter >> toSystemClipboard: aString [

	self subclassResponsibility.

]
